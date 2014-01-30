CREATE OR REPLACE FUNCTION "GETTOLPAYABLECONTENTDETAILS" (
   pcpchid   NUMBER
)
   RETURN CLOB
IS
   pc_details       CLOB            := '';
   elementname      VARCHAR2 (100)  := '';
   payablecontent   VARCHAR2 (4000) := '';

   CURSOR cr_quantity
   IS
      SELECT   pcpch.range_type as rangetype ,(CASE
                   WHEN pcepc.range_min_op IS NULL
                      THEN    ' '
                           || pcepc.range_max_op
                           || ' '
                           || pcepc.range_max_value
                   WHEN pcepc.range_max_op IS NULL
                      THEN    ' '
                           || pcepc.range_min_op
                           || ' '
                           || pcepc.range_min_value
                   ELSE    pcepc.range_min_op
                        || ' '
                        || pcepc.range_min_value
                        || ' to '
                        || pcepc.range_max_op
                        || ' '
                        || pcepc.range_max_value
                END
               ) AS qtyrange,
               rm.ratio_name AS qtyunit, ppf.external_formula AS formula,
               pcepc.payable_content_value || '%' AS payablecontent,
               pcepc.assay_deduction || ' ' ||rm.ratio_name AS assaydeduction,
               (CASE
                   WHEN pcepc.include_ref_charges = 'Y'
                      THEN    f_format_to_char (pcepc.refining_charge_value,
                                                4)
                           || ' '
                           || pum.price_unit_name
                END
               ) AS refiningcharges
          FROM pcpch_pc_payble_content_header pcpch,
               pcepc_pc_elem_payable_content pcepc,
               rm_ratio_master rm,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               ppf_phy_payable_formula ppf
         WHERE pcpch.pcpch_id = pcepc.pcpch_id
           AND pcpch.pcpch_id = pcpchid
           AND rm.ratio_id = pcpch.range_unit_id
           AND pcepc.refining_charge_unit_id = ppu.internal_price_unit_id(+)
           AND ppu.price_unit_id = pum.price_unit_id(+)
           AND ppf.ppf_id = pcepc.payable_formula_id
           AND pcepc.is_active = 'Y'
           AND pcpch.is_active = 'Y'
           AND ppf.is_active = 'Y'
      ORDER BY pcepc.range_max_value;
BEGIN
   BEGIN
      SELECT aml.attribute_name
        INTO elementname
        FROM pcpch_pc_payble_content_header pcpch,
             aml_attribute_master_list aml
       WHERE pcpch.pcpch_id = pcpchid
         AND pcpch.element_id = aml.attribute_id
         AND pcpch.is_active = 'Y'
         AND aml.is_active = 'Y'
         AND aml.is_deleted = 'N';
   END;

   FOR rec_quantity IN cr_quantity
   LOOP
      IF (rec_quantity.rangetype ='Assay')
      THEN
         payablecontent :=
               payablecontent
            || 'Quantity: '
            || rec_quantity.qtyrange
            || ' '
            || rec_quantity.qtyunit
            || CHR (10);
      END IF;

      payablecontent :=
            payablecontent
         || 'Formula: '
         || rec_quantity.formula
         || CHR (10)
         || 'Payable Content: '
         || rec_quantity.payablecontent
         || CHR (10)
         || 'Assay Deduction: '
         || rec_quantity.assaydeduction
         || CHR (10);

      IF (rec_quantity.refiningcharges IS NOT NULL)
      THEN
         payablecontent :=
               payablecontent
            || 'Refining Charge: '
            || rec_quantity.refiningcharges
            || chr(10);
      END IF;
                   
   END LOOP;

   pc_details :=
         pc_details
      || 'Element: '
      || elementname
      || CHR (10)
      || payablecontent
      || CHR (10);
   RETURN pc_details;
END;
/
