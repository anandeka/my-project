CREATE OR REPLACE PROCEDURE "PREPAREAMENDCONTRACTOUTPUTDOC" ( 
   p_contractno    VARCHAR2,
   p_docrefno      VARCHAR2,
   p_activity_id   VARCHAR2
)
IS
   docid                      VARCHAR2 (15);
   contractsection            VARCHAR2 (50)   := 'Contract Buyer Section';
   issuedate                  VARCHAR2 (50);
   amendmentdate              VARCHAR2 (50);
   contractrefno              VARCHAR2 (50);
   cpcontractrefno            VARCHAR2 (50);
   corporateid                VARCHAR2 (20);
   corporatename              VARCHAR2 (100);
   contracttype               VARCHAR2 (20);
   cpid                       VARCHAR2 (20);
   counterparty               VARCHAR2 (200);
   traxystrader               VARCHAR2 (200);
   cpcontactpersoson          VARCHAR2 (200);
   buyer                      VARCHAR2 (200);
   seller                     VARCHAR2 (200);
   cpaddress                  VARCHAR2 (4000);
   executiontype              VARCHAR2 (20);
   agencydetails              VARCHAR2 (4000);
   jvdetails                  VARCHAR2 (4000);
   productdef                 VARCHAR2 (4000);
   display_order              NUMBER (10)     := 1;
   pcdi_count                 NUMBER (10)     := 1;
   deliveryschedulecomments   VARCHAR2 (4000) := '';
   paymentdetails             VARCHAR2 (4000) := '';
   paymenttext                VARCHAR2 (4000) := '';
   taxes                      VARCHAR2 (4000) := '';
   insuranceterms             VARCHAR2 (4000) := '';
   otherterms                 VARCHAR2 (4000) := '';
   product_group_type         VARCHAR2 (50)   := '';
   qualityprintnamereq        VARCHAR2 (15)   := '';
   qualityprintname           VARCHAR2 (1000) := '';
   p_doc_type                 VARCHAR2 (15)   := '';
   old_doc_id                 VARCHAR2 (15)   := '';
   timeofdelivery varchar2(30);
   istollingcontract          VARCHAR2 (1)    := '';
   
   CURSOR cr_delivery
   IS
      SELECT   pcdi.pcdi_id pcdi_id,
               (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
               ) AS delivery_item_ref_no
          FROM pcdi_pc_delivery_item pcdi, pcm_physical_contract_main pcm
         WHERE pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           AND pcm.internal_contract_ref_no = p_contractno
           AND pcdi.is_active = 'Y'
      ORDER BY TO_NUMBER (pcdi.delivery_item_no);
BEGIN
   SELECT seq_amend_doc.NEXTVAL
     INTO docid
     FROM DUAL;

   BEGIN
      SELECT TO_CHAR (pcm.issue_date, 'dd-Mon-YYYY'), pcm.contract_ref_no,
             NVL (pcm.cp_contract_ref_no, 'NA'), (pad.address_name || ' ' || pad.address),
             ak.corporate_id, pcm.purchase_sales, phd.companyname,
             pcm.cp_id, pcm.product_group_type,
             TO_CHAR (par.amendment_date, 'dd-Mon-YYYY'),
             pcm.partnership_type, pcm.is_tolling_contract
        INTO issuedate, contractrefno,
             cpcontractrefno, corporatename,
             corporateid, contracttype, counterparty,
             cpid, product_group_type,
             amendmentdate,
             executiontype,
             istollingcontract
        FROM pcm_physical_contract_main pcm,
             ak_corporate ak,
             phd_profileheaderdetails phd,
             par_physical_amend_reason par,
             PAD_PROFILE_ADDRESSES pad
       WHERE pcm.corporate_id = ak.corporate_id
         AND PHD.PROFILEID = PAD.PROFILE_ID
         AND phd.profileid = pcm.cp_id
         AND pad.address_type = 'Main'
         AND pad.is_deleted = 'N'
         AND par.internal_contract_ref_no(+) = pcm.internal_contract_ref_no
         AND pcm.internal_contract_ref_no = p_contractno;
         
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         issuedate := '';
         contractrefno := '';
         cpcontractrefno := '';
         corporatename := '';
         corporateid := '';
         contracttype := '';
         counterparty := '';
         cpid := '';
         product_group_type := '';
         amendmentdate := '';
         executiontype := '';
   END;

   IF (contracttype = 'P')
   THEN
      buyer := corporatename;
      seller := counterparty;
      contractsection := 'Contract Buyer Section';
   ELSE
      buyer := counterparty;
      seller := corporatename;
      contractsection := 'Contract Seller Section';
   END IF;

   IF (p_activity_id = 'CONTRACT_APPROVED')
   THEN
      p_doc_type := 'ORIGINAL';
   ELSE
      p_doc_type := 'AMENDED';

      SELECT acs.doc_id
        INTO old_doc_id
        FROM acs_amend_contract_summary acs
       WHERE acs.internal_contract_ref_no = p_contractno
         AND acs.status = 'Active'
         AND acs.created_date =
                    (SELECT MAX (created_date)
                       FROM acs_amend_contract_summary acs_inner
                      WHERE acs_inner.internal_contract_ref_no = p_contractno);
   END IF;

   INSERT INTO acs_amend_contract_summary
               (doc_id, doc_type, template_type, template_name,
                internal_doc_ref_no, ver_no, issue_date, is_amendment,
                status, created_by, created_date, updated_by, updated_date,
                cancelled_by, cancelled_date, send_date, received_date,
                internal_contract_ref_no, contract_ref_no, contract_type,
                corporate_id, contract_signing_date, approval_type,
                amendment_no, watermark, amendment_date, document_print_type
               )
        VALUES (docid, p_doc_type, NULL, NULL,
                p_docrefno, 1, issuedate, 'N',
                'Active', NULL, SYSTIMESTAMP, NULL, NULL,
                NULL, NULL, NULL, NULL,
                p_contractno, contractrefno, contracttype,
                corporateid, NULL, NULL,
                NULL, NULL, NULL, 'Full Contract'
               );

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Contract Ref No', 'Y', NULL,
                NULL, contractrefno, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

--   display_order := display_order + 1;

--   INSERT INTO acd_amend_contract_details
--               (doc_id, display_order, field_layout_id, section_name,
--                field_name, is_print_reqd, pre_content_text_id,
--                post_content_text_id, contract_content, pre_content_text,
--                post_content_text, is_custom_section, is_footer_section,
--                is_amend_section, print_type, is_changed
--               )
--        VALUES (docid, display_order, NULL, contractsection,
--                'Counterparty Contract Ref No', 'Y', NULL,
--                NULL, cpcontractrefno, NULL,
--                NULL, 'N', 'N',
--                'N', 'FULL', 'N'
--               );

   BEGIN
      SELECT NVL ((gab.firstname || ' ' || gab.lastname), 'NA')
        INTO traxystrader
        FROM ak_corporate_user aku, gab_globaladdressbook gab
       WHERE gab.gabid = aku.gabid
         AND aku.user_id IN (
                             SELECT pcm.trader_id
                               FROM pcm_physical_contract_main pcm
                              WHERE pcm.internal_contract_ref_no =
                                                                  p_contractno);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         traxystrader := NULL;
   END;

   BEGIN
      SELECT gab.firstname || ' ' || gab.lastname
        INTO cpcontactpersoson
        FROM gab_globaladdressbook gab
       WHERE gab.gabid = (SELECT pcm.cp_person_in_charge_id
                            FROM pcm_physical_contract_main pcm
                           WHERE pcm.internal_contract_ref_no = p_contractno);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         cpcontactpersoson := NULL;
   END;

--   display_order := display_order + 1;

--   INSERT INTO acd_amend_contract_details
--               (doc_id, display_order, field_layout_id, section_name,
--                field_name, is_print_reqd, pre_content_text_id,
--                post_content_text_id, contract_content, pre_content_text,
--                post_content_text, is_custom_section, is_footer_section,
--                is_amend_section, print_type, is_changed
--               )
--        VALUES (docid, display_order, NULL, contractsection,
--                'Traxys Trader', 'Y', NULL,
--                NULL, traxystrader, NULL,
--                NULL, 'N', 'N',
--                'N', 'FULL', 'N'
--               );

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                ' CP Trader name', 'Y', NULL,
                NULL, cpcontactpersoson, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

--   display_order := display_order + 1;

--   INSERT INTO acd_amend_contract_details
--               (doc_id, display_order, field_layout_id, section_name,
--                field_name, is_print_reqd, pre_content_text_id,
--                post_content_text_id, contract_content, pre_content_text,
--                post_content_text, is_custom_section, is_footer_section,
--                is_amend_section, print_type, is_changed
--               )
--        VALUES (docid, display_order, NULL, contractsection,
--                'Contract Issue Date', 'Y', NULL,
--                NULL, issuedate, NULL,
--                NULL, 'N', 'N',
--                'N', 'FULL', 'N'
--               );

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Amendment Date', 'Y', NULL,
                NULL, amendmentdate, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Buyer', 'Y', NULL,
                NULL, buyer, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );


   BEGIN
      SELECT    pad.address
             || ','
             || cim.city_name
             || ','
             || sm.state_name
             || ','
             || cym.country_name
        INTO cpaddress
        FROM pad_profile_addresses pad,
             cym_countrymaster cym,
             cim_citymaster cim,
             sm_state_master sm
       WHERE pad.address_type = 'Main'
         AND pad.country_id = cym.country_id
         AND pad.city_id(+) = cim.city_id
         AND cim.state_id(+) = sm.state_id
         AND pad.profile_id = cpid
         AND pad.is_deleted = 'N';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         cpaddress := NULL;
   END;

   display_order := display_order + 1;

  INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Seller', 'Y', NULL,
                NULL, seller || CHR (10) || cpaddress, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );
   
   IF (executiontype = 'Joint Venture')
   THEN
      IF (contracttype = 'P')
      THEN
         jvdetails := getjvdetails (p_contractno);
      ELSE
         jvdetails := 'JV Contract';
      END IF;

      display_order := display_order + 1;

      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'JV',
                   'JV Details', 'Y', NULL,
                   NULL, jvdetails, NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   ELSIF (executiontype = 'Agency')
   THEN
      IF (contracttype = 'P')
      THEN
         BEGIN
            SELECT (   'Agency Counter Party :'
                    || phd.company_long_name1
                    || CHR (10)
                    || 'Commission Details :'
                    || (CASE
                           WHEN pcad.commission_type = 'Fixed'
                              THEN    pcad.commission_value
                                   || ' '
                                   || pum.price_unit_name
                           WHEN pcad.commission_type = 'Formula'
                              THEN pacf.external_formula
                        END
                       )
                    || CHR (10)
                    || 'Basis :'
                    || (itm.incoterm || '-' || cim.city_name)
                   )
              INTO agencydetails
              FROM pcad_pc_agency_detail pcad,
                   phd_profileheaderdetails phd,
                   ppu_product_price_units ppu,
                   pum_price_unit_master pum,
                   pacf_phy_agency_comm_formula pacf,
                   itm_incoterm_master itm,
                   cim_citymaster cim
             WHERE pcad.agency_cp_id = phd.profileid
               AND pcad.commission_unit_id = ppu.internal_price_unit_id(+)
               AND ppu.price_unit_id = pum.price_unit_id(+)
               AND pcad.commission_formula_id = pacf.pacf_id(+)
               AND pcad.basis_incoterm_id = itm.incoterm_id
               AND pcad.basis_city_id = cim.city_id
               AND pcad.internal_contract_ref_no = p_contractno;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               agencydetails := '';
         END;
      ELSE
         agencydetails := 'Agency Contract';
      END IF;

      display_order := display_order + 1;

      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Agency',
                   'Agency', 'Y', NULL,
                   NULL, agencydetails, NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   END IF;

   BEGIN
      SELECT    pdm.product_desc
             || CHR (10)
             || (CASE
                    WHEN pcpd.qty_type = 'Fixed'
                       THEN   pcpd.qty_max_val
                            || ' '
                            || qum.qty_unit_desc
                    ELSE    pcpd.qty_min_operator
                         || ' '
                         || pcpd.qty_min_val
                         || ' '
                         || pcpd.qty_max_operator
                         || ' '
                         || pcpd.qty_max_val
                         || ' '
                         || qum.qty_unit_desc
                 END
                )
        INTO productdef
        FROM pcpd_pc_product_definition pcpd,
             pdm_productmaster pdm,
             qum_quantity_unit_master qum
       WHERE pcpd.product_id = pdm.product_id
         AND pcpd.qty_unit_id = qum.qty_unit_id
         AND pcpd.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         productdef := '';
   END;

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Product and Quantity',
                'Product and Quantity', 'Y', NULL,
                NULL, productdef, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;
   
   DECLARE
   CURSOR pcpd_cursor
   IS SELECT pcpd.is_quality_print_name_req as qualityprintnamereq , pcpd.quality_print_name as qualityprintname
        --INTO qualityprintnamereq, qualityprintname
        FROM pcpd_pc_product_definition pcpd, pcm_physical_contract_main pcm
       WHERE pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
         AND pcpd.internal_contract_ref_no = p_contractno;

  BEGIN
   FOR pcpd_cursor_rows IN pcpd_cursor
   LOOP
    display_order := display_order + 1;
   IF (pcpd_cursor_rows.qualityprintnamereq = 'Y')
   THEN
      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Quality/Qualities',
                   'Quality/Qualities', 'Y', NULL,
                   NULL, pcpd_cursor_rows.qualityprintname, NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   ELSE
      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Quality/Qualities',
                   'Quality/Qualities', 'Y', NULL,
                   NULL, getcontractqualitydetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   END IF;
    END LOOP;
END;

   FOR delivery_rec IN cr_delivery
   LOOP
      display_order := display_order + 1;

      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name,
                   is_print_reqd, pre_content_text_id, post_content_text_id,
                   contract_content,
                   pre_content_text, post_content_text, is_custom_section,
                   is_footer_section, is_amend_section, print_type,
                   is_changed
                  )
           VALUES (docid, display_order, NULL, 'Time of Shipment',
                   'Delivery Item:' || delivery_rec.delivery_item_ref_no,
                   'Y', NULL, NULL,
                   getdeliveryperioddetails (p_contractno,
                                             delivery_rec.pcdi_id,
                                             istollingcontract,
                                             product_group_type
                                            ),
                   NULL, NULL, 'N',
                   'N', 'N', 'FULL',
                   'N'
                  );
   END LOOP;

 /*display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
          (doc_id, display_order, field_layout_id, section_name,
           field_name,
           is_print_reqd, pre_content_text_id, post_content_text_id,
           contract_content,
           pre_content_text, post_content_text, is_custom_section,
           is_footer_section, is_amend_section, print_type,
           is_changed
          )
   VALUES (docid, display_order, NULL, 'Premium',
           'Premium',
           'Y', NULL, NULL,
           GETQUALITYLOCATIONPREMUIM(p_contractno),
           NULL, NULL, 'N',
           'N', 'N', 'FULL',
           'N'
          );*/
   BEGIN
      SELECT pcm.del_schedule_comments
        INTO deliveryschedulecomments
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         deliveryschedulecomments := '';
   END;

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Time of Shipment',
                'Other Terms', 'Y', NULL,
                NULL, deliveryschedulecomments, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT    cm.cur_code
             || ' ,'
             || pym.payterm_long_name
             || (CASE
                    WHEN pcm.provisional_pymt_pctg IS NULL
                       THEN ''
                    ELSE    ', '
                         || pcm.provisional_pymt_pctg
                         || ' % of Provisional Invoice Amount'
                 END
                )
        INTO paymentdetails
        FROM pcm_physical_contract_main pcm,
             pym_payment_terms_master pym,
             cm_currency_master cm
       WHERE pcm.payment_term_id = pym.payment_term_id
         AND cm.cur_id = pcm.invoice_currency_id
         AND pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         paymentdetails := '';
   END;

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Payment Terms',
                'Payment Terms', 'Y', NULL,
                NULL, paymentdetails, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   IF (product_group_type = 'CONCENTRATES')
   THEN
      display_order := display_order + 1;

      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Payable Content',
                   'Payable Content', 'Y', NULL,
                   NULL, getpayablecontentdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );

      display_order := display_order + 1;

      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Treatment Charges',
                   'Treatment Charges', 'Y', NULL,
                   NULL, gettcdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );

      display_order := display_order + 1;

      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Refining Charges',
                   'Refining Charges', 'Y', NULL,
                   NULL, getrcdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );

      display_order := display_order + 1;

      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Penalties',
                   'Penalties', 'Y', NULL,
                   NULL, getpenaltydetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );

       display_order := display_order + 1;

        INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL,  'Small Lot Charges',
                   'Small Lot Charges', 'Y', NULL,
                   NULL, getslcdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );         
                  
                  
        display_order := display_order + 1;

        INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
        VALUES (docid, display_order, NULL, 'Container Charges',
                   'Container Charges', 'Y', NULL,
                   NULL, getccdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
                  
        display_order := display_order + 1;
                  
        INSERT INTO acd_amend_contract_details
              (doc_id, display_order, field_layout_id, section_name,
               field_name, is_print_reqd, pre_content_text_id,
               post_content_text_id, contract_content, pre_content_text,
               post_content_text, is_custom_section, is_footer_section,
               is_amend_section, print_type, is_changed
              )
        VALUES (docid, display_order, NULL, 'Other Charges',
               'Other Charges', 'Y', NULL,
               NULL, getocdetails (p_contractno), NULL,
               NULL, 'N', 'N',
               'N', 'FULL', 'N'
              );

      display_order := display_order + 1;

      INSERT INTO acd_amend_contract_details
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Assaying Rules',
                   'Assaying Rules', 'Y', NULL,
                   NULL, getassayinrules (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   END IF;

   BEGIN
      SELECT pcm.payment_text
        INTO paymenttext
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         paymenttext := '';
   END;

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Payment Text',
                'Payment Text', 'Y', NULL,
                NULL, paymenttext, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT pcm.taxes
        INTO taxes
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         taxes := '';
   END;

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Taxes, Tarrifs and Duties',
                'Terms ', 'Y', NULL,
                NULL, taxes, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT pcm.insurance
        INTO insuranceterms
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         insuranceterms := '';
   END;

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Insurance',
                'Insurance Terms ', 'Y', NULL,
                NULL, insuranceterms, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT pcm.other_terms
        INTO otherterms
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         otherterms := '';
   END;

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Other Terms',
                'Other Terms ', 'Y', NULL,
                NULL, otherterms, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;

   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'List of Documents',
                'List of Documents', 'Y', NULL,
                NULL, getcontractdocuments (p_contractno), NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );
               
    Begin
      SELECT   (   MIN
                (DECODE
                    (pcdi.delivery_period_type,
                     'Date', (TO_CHAR (MIN (pcdi.delivery_from_date),
                                       'MON-yyyy'
                                      )),
                     'Month', (TO_CHAR
                                  ((MIN
                                       (TO_DATE
                                           (   '01-'
                                            || DECODE
                                                    (pcdi.delivery_from_month,
                                                     NULL, 'Jan',
                                                     pcdi.delivery_from_month
                                                    )
                                            || '-'
                                            || DECODE
                                                     (pcdi.delivery_from_year,
                                                      NULL, '2011',
                                                      pcdi.delivery_from_year
                                                     )
                                           )
                                       )
                                   ),
                                   'MON-yyyy'
                                  )
                      )
                    )
                )
          || ' To '
          || MAX
                (DECODE
                    (pcdi.delivery_period_type,
                     'Month', (TO_CHAR
                                  ((MAX
                                       (TO_DATE
                                           (   '01-'
                                            || DECODE
                                                    (pcdi.delivery_from_month,
                                                     NULL, 'Jan',
                                                     pcdi.delivery_to_month
                                                    )
                                            || '-'
                                            || DECODE
                                                     (pcdi.delivery_from_year,
                                                      NULL, '2011',
                                                      pcdi.delivery_from_year
                                                     )
                                           )
                                       )
                                   ),
                                   'MON-yyyy'
                                  )
                      )
                    )
                )
         ) INTO timeofdelivery
    FROM pcdi_pc_delivery_item pcdi, pcm_physical_contract_main pcm
   WHERE pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcm.internal_contract_ref_no = p_contractno
     AND pcdi.is_active = 'Y'
    GROUP BY pcdi.delivery_period_type;
    end;
    
   display_order := display_order + 1;
   
   INSERT INTO acd_amend_contract_details
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Time Of Delivery',
                'Time Of Delivery', 'Y', NULL,
                NULL, timeOfDelivery, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );           

   IF (p_activity_id = 'CONTRACT_APPROVED')
   THEN
      generatecontractoutputdoc (p_contractno, p_docrefno, p_activity_id);
   ELSE
      generateamendcontractoutputdoc (old_doc_id, docid, p_contractno);
   END IF;
END;
/
