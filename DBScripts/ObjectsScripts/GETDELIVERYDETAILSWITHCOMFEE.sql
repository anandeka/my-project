CREATE OR REPLACE FUNCTION GETDELIVERYDETAILSWITHCOMFEE (
   p_contractno    VARCHAR2,
   p_delivery_id   VARCHAR2,
   p_cp_id         VARCHAR2,
   p_issue_date    VARCHAR2
)
   RETURN CLOB
IS
   deliverydescription   CLOB            := '';
   deliveryitem          VARCHAR2 (4000) := '';
   quotaperiod           VARCHAR2 (4000) := '';
   qualitydetails        VARCHAR2 (4000) := '';
   quantitydetails       VARCHAR2 (4000) := '';
   incotermdetails       VARCHAR2 (4000) := 'Terms of Delivery:';
   pricingdetails        VARCHAR2 (4000) := 'Pricing Details :';
   qpdeclarationdate     VARCHAR2 (50);
   paymentduedate        VARCHAR2 (50);
   optionality           VARCHAR2 (50);
   minqtyop              VARCHAR2 (15);
   maxqtyop              VARCHAR2 (15);
   minqtyvalue           NUMBER (25, 10);
   maxqtyvalue           NUMBER (25, 10);
   itemqtyunit           VARCHAR2 (50);
   commercialdetails     VARCHAR2 (4000) := '';
   premiumdetails        VARCHAR2 (4000) := '';
   qualitydecs           VARCHAR2 (4000);
   packingtype           VARCHAR2 (4000) := 'Packing Type:';

   CURSOR cr_incoterm
   IS
      SELECT    itm.incoterm
             || ' Incoterm '
             || ' - '
             || cim.city_name
             || (CASE
                    WHEN pcdb.customs IS NULL
                       THEN ''
                    ELSE ' ,Custom ' || pcdb.customs
                 END
                )
             || (CASE
                    WHEN pcdb.duty_status IS NULL
                       THEN ''
                    ELSE ' ,Duty ' || pcdb.duty_status
                 END
                )
             || (CASE
                    WHEN pcdb.tax_status IS NULL
                       THEN ''
                    ELSE ' ,Tax ' || pcdb.tax_status
                 END
                ) incoterm_details
        FROM pcdb_pc_delivery_basis pcdb,
             itm_incoterm_master itm,
             cim_citymaster cim,
             pcdiob_di_optional_basis pcdiob
       WHERE pcdb.inco_term_id = itm.incoterm_id
         AND pcdb.city_id = cim.city_id
         AND pcdiob.pcdb_id = pcdb.pcdb_id
         AND pcdb.is_active = 'Y'
         AND pcdiob.is_active = 'Y'
         AND pcdiob.pcdi_id = p_delivery_id;

   CURSOR cr_pricing
   IS
      SELECT   pcbph.price_description AS price_description,
               pcbph.element_name AS element_name
          FROM pcdipe_di_pricing_elements pcdipe,
               pcbph_pc_base_price_header pcbph
         WHERE pcdipe.pcbph_id = pcbph.pcbph_id
           AND pcdipe.is_active = 'Y'
           AND pcbph.is_active = 'Y'
           AND pcdipe.pcdi_id = p_delivery_id
      ORDER BY pcdipe.pcbph_id;

   CURSOR cr_quality
   IS
      SELECT qat.quality_id AS quality_id, qat.quality_name AS quality_name
        FROM pcpq_pc_product_quality pcpq,
             qat_quality_attributes qat,
             pcdiqd_di_quality_details pcdiqd
       WHERE pcpq.quality_template_id = qat.quality_id
         AND pcdiqd.pcpq_id = pcpq.pcpq_id
         AND pcdiqd.pcdi_id = p_delivery_id;
BEGIN
   BEGIN
      SELECT    'Delivery Item No :'
             || pcm.contract_ref_no
             || '-'
             || pcdi.delivery_item_no
        INTO deliveryitem
        FROM pcdi_pc_delivery_item pcdi, pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         AND pcdi.pcdi_id = p_delivery_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         deliveryitem := '';
   END;
   
   BEGIN
      SELECT    'Packing Type :'
               || pcdi.packing_type
        INTO packingtype
        FROM pcdi_pc_delivery_item pcdi, pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         AND pcdi.pcdi_id = p_delivery_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         packingtype := '';
   END;

   BEGIN
      SELECT    'Delivery period :'
             || (CASE
                    WHEN pcdi.delivery_period_type = 'Month'
                       THEN    pcdi.delivery_from_month
                            || ' '
                            || pcdi.delivery_from_year
                            || ' To '
                            || pcdi.delivery_to_month
                            || ' '
                            || pcdi.delivery_to_year
                    ELSE    TO_CHAR (pcdi.delivery_from_date, 'dd-Mon-YYYY')
                         || ' To '
                         || TO_CHAR (pcdi.delivery_to_date, 'dd-Mon-YYYY')
                 END
                )
        INTO quotaperiod
        FROM pcdi_pc_delivery_item pcdi
       WHERE pcdi.pcdi_id = p_delivery_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         quotaperiod := '';
   END;

   BEGIN
      SELECT pcdi.qty_min_operator, pcdi.qty_min_val,
             pcdi.qty_max_operator, pcdi.qty_max_val,
             qum.qty_unit_desc
        INTO minqtyop, minqtyvalue,
             maxqtyop, maxqtyvalue,
             itemqtyunit
        FROM pcdi_pc_delivery_item pcdi, qum_quantity_unit_master qum
       WHERE pcdi.qty_unit_id = qum.qty_unit_id
         AND pcdi.pcdi_id = p_delivery_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         quantitydetails := '';
   END;

   IF (minqtyvalue = maxqtyvalue)
   THEN
      quantitydetails := 'Quantity :' || minqtyvalue || ' ' || itemqtyunit;
   ELSE
      quantitydetails :=
            'Quantity :'
         || 'Min '
         || minqtyop
         || ' '
         || minqtyvalue
         || ' Max '
         || maxqtyop
         || ' '
         || maxqtyvalue
         || ' '
         || itemqtyunit;
   END IF;

   FOR incoterm_rec IN cr_incoterm
   LOOP
      incotermdetails :=
            CHR (10) || 'Terms of Delivery :'
            || incoterm_rec.incoterm_details;
   END LOOP;

   FOR pricing_rec IN cr_pricing
   LOOP
      pricingdetails := pricingdetails || CHR (10);

      IF (pricing_rec.element_name IS NOT NULL)
      THEN
         pricingdetails := pricingdetails || pricing_rec.element_name || ' :';
      END IF;

      pricingdetails := pricingdetails || pricing_rec.price_description;
   END LOOP;

   BEGIN
      SELECT NVL (TO_CHAR (pcdi.qp_declaration_date, 'DD-Mon-YYYY'), ''),
             NVL (pcdi.quality_option_type, ''),
             NVL (TO_CHAR (pcdi.payment_due_date, 'DD-Mon-YYYY'), '')
        INTO qpdeclarationdate,
             optionality,
             paymentduedate
        FROM pcdi_pc_delivery_item pcdi
       WHERE pcdi.pcdi_id = p_delivery_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         qpdeclarationdate := '';
         optionality := '';
         paymentduedate := '';
   END;

   BEGIN
      FOR quality_rec IN cr_quality
      LOOP
         qualitydecs := quality_rec.quality_name;

         BEGIN
            SELECT ('Commercial Fee:'
                    || ' '
                    || mcc.charge
                    || ' '
                    || cm.cur_code
                    || (CASE
                    WHEN qum.qty_unit IS NULL
                     THEN ''
                    ELSE '/' || qum.qty_unit
                    END)
                    || ' '
                    || mcc.weight_rate_basis
                    || ' '
                    || 'Basis'
                   )
              INTO commercialdetails
              FROM pcpd_pc_product_definition pcpd,
                   mcc_miscellaneous_comm_charges mcc,
                   cm_currency_master cm,
                   qum_quantity_unit_master qum
             WHERE mcc.cp_id = p_cp_id
               AND mcc.product_id = pcpd.product_id
               AND mcc.charge_cur_id = cm.cur_id
               AND pcpd.internal_contract_ref_no = p_contractno
               AND pcpd.input_output = 'Input'
               AND mcc.qty_unit_id = qum.qty_unit_id(+)
               AND mcc.quality_id = quality_rec.quality_id
               AND mcc.charge_name = 'Commercial Fee'
               AND mcc.is_active = 'Y'
               AND p_issue_date BETWEEN mcc.from_date AND mcc.TO_DATE;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               DBMS_OUTPUT.put_line ('No data found');
               commercialdetails := '';
         END;

         BEGIN
            SELECT (   'Premium:'
                    || ' '
                    || mcc.charge
                    || ' '
                    || cm.cur_code
                    || (CASE
                           WHEN qum.qty_unit IS NULL
                              THEN ''
                           ELSE '/' || qum.qty_unit
                        END
                       )
                   )
              INTO premiumdetails
              FROM pcpd_pc_product_definition pcpd,
                   mcc_miscellaneous_comm_charges mcc,
                   cm_currency_master cm,
                   qum_quantity_unit_master qum
             WHERE mcc.cp_id = p_cp_id
               AND mcc.product_id = pcpd.product_id
               AND mcc.charge_cur_id = cm.cur_id
               AND pcpd.internal_contract_ref_no = p_contractno
               AND pcpd.input_output = 'Input'
               AND mcc.qty_unit_id = qum.qty_unit_id(+)
               AND mcc.quality_id = quality_rec.quality_id
               AND mcc.charge_name = 'Premium'
               AND mcc.is_active = 'Y'
               AND p_issue_date BETWEEN mcc.from_date AND mcc.TO_DATE;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               DBMS_OUTPUT.put_line ('No data found');
               premiumdetails := '';
         END;
      END LOOP;

      IF (commercialdetails IS NULL AND premiumdetails IS NULL)
      THEN
         qualitydecs := qualitydecs;
      END IF;

      IF (commercialdetails IS NOT NULL AND premiumdetails IS NULL)
      THEN
         qualitydecs := qualitydecs || '(' || commercialdetails || ')';
      END IF;

      IF (commercialdetails IS NULL AND premiumdetails IS NOT NULL)
      THEN
         qualitydecs := qualitydecs || '(' || premiumdetails || ')';
      END IF;

      IF (commercialdetails IS NOT NULL AND premiumdetails IS NOT NULL)
      THEN
         qualitydecs :=
               qualitydecs
            || '('
            || commercialdetails
            || ', '
            || premiumdetails
            || ')';
      END IF;
   END;

   deliverydescription :=
         'Quality:'
      || qualitydecs
      || CHR (10)
      || quantitydetails
      || CHR (10)
      || quotaperiod
      || CHR (10)
      || incotermdetails
      || CHR (10)
      || packingtype
      || ' '
      || optionality
      || CHR (10)
      || pricingdetails;

   IF (qpdeclarationdate IS NOT NULL)
   THEN
      deliverydescription :=
            deliverydescription
         || CHR (10)
         || 'QP declaration Date:'
         || qpdeclarationdate;
   END IF;

--   IF (paymentduedate IS NOT NULL)
--   THEN
--      deliverydescription :=
--            deliverydescription
--         || CHR (10)
--         || 'Payment Due Date:'
--         || paymentduedate;
--   END IF;

   RETURN deliverydescription;
END;
/