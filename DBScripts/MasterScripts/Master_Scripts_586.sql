

DECLARE

fetchQueryISDForDC clob:='INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_quantity, invoiced_qty_unit, internal_invoice_ref_no,
             invoice_amount, material_cost, addditional_charges, taxes,
             due_date, supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             our_person_incharge, internal_comments, is_self_billing,is_inv_draft,internal_doc_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            invs.invoiced_qty AS invoice_quantity,
            qum_gmr.qty_unit AS invoiced_qty_unit,
            invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            invs.total_amount_to_pay AS invoice_amount,
            invs.amount_to_pay_before_adj AS material_cost,
            invs.total_other_charge_amount AS addditional_charges,
            invs.total_tax_amount AS taxes, invs.payment_due_date AS due_date,
            invs.cp_ref_no AS supplier_invoice_no,
            pcm.issue_date AS contract_date,
            pcm.contract_ref_no AS contract_ref_no,
            SUM (ii.invoicable_qty) AS stock_quantity,
            stragg(ii.stock_ref_no) AS stock_ref_no,
            cm.cur_code AS invoice_amount_unit, gmr.gmr_ref_no AS gmr_ref_no,
            gmr.qty AS gmr_quality, pcpd.qty_max_val AS contract_quantity,
            qum.qty_unit AS contract_qty_unit,
            pcpd.max_tolerance AS contract_tolerance,
            qat.quality_name AS quality, pdm.product_desc AS product,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            pym.payment_term AS payment_term,
            gmr.final_weight AS gmr_finalize_qty, phd.companyname AS cp_name,
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip, pcm.contract_type AS contract_type,
            cymloading.country_name AS origin,
            pci.terms AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            NVL (akuser.login_name, '' '') AS our_person_incharge, INVS.INTERNAL_COMMENTS as internal_comments, pcm.is_self_billing as IS_SELF_BILLING,INVS.IS_INV_DRAFT as is_inv_draft, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            pcm_physical_contract_main pcm,
            v_pci pci,
            ii_invoicable_item ii,
            cm_currency_master cm,
            gmr_goods_movement_record gmr,
            pcpd_pc_product_definition pcpd,
            qum_quantity_unit_master qum,
            pcpq_pc_product_quality pcpq,
            qat_quality_attributes qat,
            pdm_productmaster pdm,
            phd_profileheaderdetails phd,
            pym_payment_terms_master pym,
            pad_profile_addresses pad,
            cym_countrymaster cym,
            cim_citymaster cim,
            sm_state_master sm,
            bpat_bp_address_type bpat,
            cym_countrymaster cymloading,
            sad_shipment_advice sad,
            sd_shipment_detail sd,
            phd_profileheaderdetails phd1,
            phd_profileheaderdetails phd2,
            qum_quantity_unit_master qum_gmr,
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND iid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND iid.invoicable_item_id = ii.invoicable_item_id
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.invoice_currency_id = cm.cur_id
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.pcpd_id = pcpq.pcpd_id
        AND pci.quality_id = qat.quality_id
        AND pcpq.quality_template_id = qat.quality_id
        AND pcpd.product_id = pdm.product_id
        AND pcm.cp_id = phd.profileid
        AND INVS.CREDIT_TERM(+) = pym.payment_term_id
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND pad.address_type = bpat.bp_address_type_id(+)
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.consignee_id = phd1.profileid(+)
        AND sd.consignee_id = phd2.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND pad.is_deleted(+) = ''N''
        AND pad.address_type(+) = ''Billing''
        AND invs.internal_invoice_ref_no = ?
   GROUP BY invs.invoice_ref_no,
            invs.invoice_type_name,
            invs.invoice_issue_date,
            invs.invoiced_qty,
            invs.internal_invoice_ref_no,
            invs.total_amount_to_pay,
            invs.total_other_charge_amount,
            invs.total_tax_amount,
            invs.payment_due_date,
            invs.cp_ref_no,
            pcm.issue_date,
            pcm.contract_ref_no,
            cm.cur_code,
            gmr.gmr_ref_no,
            gmr.qty,
            pcpd.qty_max_val,
            qum.qty_unit,
            pcpd.max_tolerance,
            qat.quality_name,
            pdm.product_desc,
            pcm.cp_contract_ref_no,
            pym.payment_term,
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.terms,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            akuser.login_name,
            invs.invoice_status,
        pcm.is_self_billing,
            INVS.INTERNAL_COMMENTS,
            INVS.IS_INV_DRAFT';
            
fetchQueryISDCCHILDDForDC clob:='INSERT INTO is_dc_child_d
            (internal_invoice_ref_no, description, invoiced_weight,
             new_invoiced_weight, invoice_price, new_invoice_price, amount,
             new_amount, old_invoice_amount, new_invoice_amount,
             net_adjustment, old_price_unit_name, new_price_unit_name,
             old_invoice_cur_unit, new_invoice_cur_unit, invoice_cur_unit,
             invoice_qty_unit_name, stock_ref_no,internal_doc_ref_no)
   SELECT iid.internal_invoice_ref_no AS internal_invoice_ref_no,
          gmr.gmr_ref_no AS description, iid.invoiced_qty AS invoiced_weight,
          iid.new_invoiced_qty AS new_invoiced_weight,
          iid.invoiced_price AS invoice_price,
          iid.new_invoice_price AS new_invoice_price,
          iid.item_amount AS amount, iid.invoice_item_amount AS new_amount,
          iid.item_amount AS old_invoice_amount,
          (iid.new_invoiced_qty * iid.new_invoice_price
          ) AS new_invoice_amount,
          (iid.invoice_item_amount - iid.item_amount) AS net_adjustment,
          pum.price_unit_name AS old_price_unit_name,
          pum.price_unit_name AS new_price_unit_name,
          cm.cur_code AS old_invoice_cur_unit,
          cm.cur_code AS new_invoice_cur_unit,
          cm.cur_code AS invoice_cur_unit,
          qum.qty_unit AS invoice_qty_unit_name,
          NVL (grd.internal_stock_ref_no,
               dgrd.internal_stock_ref_no
              ) AS stock_ref_no, ?
     FROM is_invoice_summary invs,
          iid_invoicable_item_details iid,
          qum_quantity_unit_master qum,
          cm_currency_master cm,
          ppu_product_price_units ppu,
          pum_price_unit_master pum,
          gmr_goods_movement_record gmr,
          grd_goods_record_detail grd,
          dgrd_delivered_grd dgrd
    WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
      AND iid.invoice_currency_id = cm.cur_id
      AND iid.invoiced_price_unit_id = ppu.internal_price_unit_id
      AND ppu.price_unit_id = pum.price_unit_id
      AND iid.invoiced_qty_unit_id = qum.qty_unit_id
      AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND iid.stock_id = grd.internal_grd_ref_no(+)
      AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
      AND invs.internal_invoice_ref_no = ?';
      
fetchQueryIOCDForDC clob:='INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, description, internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no
                                                   AS internal_invoice_ref_no,
                         NVL
                            (scm.cost_display_name,
                             pcmac.addn_charge_name
                            ) AS other_charge_cost_name,
                         ioc.charge_type AS charge_type,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             WHEN (ioc.rate_fx_rate IS NULL)
                             AND (ioc.flat_amount_fx_rate IS NULL)
                                THEN 1
                             WHEN ioc.rate_fx_rate IS NULL
                                THEN ioc.flat_amount_fx_rate
                             ELSE ioc.rate_fx_rate
                          END
                         ) AS fx_rate,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             ELSE ioc.quantity
                          END
                         ) AS quantity,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             ELSE NVL (ioc.rate_amount, ioc.flat_amount)
                          END
                         ) AS amount,
                         ioc.amount_in_inv_cur AS invoice_amount,
                         cm.cur_code AS invoice_cur_name,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             WHEN ioc.rate_price_unit = ''Bags''
                             AND ioc.charge_type = ''Rate''
                                THEN cm.cur_code || ''/'' || ''Bag''
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                                     ''Ocular Inspection Charge'',
                                     ''Small Lot Charges'')
                             AND ioc.charge_type = ''Rate''
                                THEN    NVL (cm_lot.cur_code, cm.cur_code)
                                     || ''/''
                                     || ''Lot''
                             ELSE pum.price_unit_name
                          END
                         ) AS rate_price_unit_name,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             ELSE NVL (ioc.flat_amount, ioc.rate_charge)
                          END
                         ) AS charge_amount_rate,
                         (CASE
                             WHEN ioc.rate_price_unit = ''Bags''
                                THEN ''Bags''
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                     ''Ocular Inspection Charge'',
                                     ''Small Lot Charges'')
                                THEN ''Lots''
                             WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                                THEN ''Lots''
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             ELSE qum.qty_unit
                          END
                         ) AS quantity_unit,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                     ''Ocular Inspection Charge'',
                                     ''Small Lot Charges'')
                             AND ioc.charge_type = ''Rate''
                                THEN cm_lot.cur_code
                             WHEN scm.cost_component_name IN
                                                          (''Handling Charge'')
                                THEN cm.cur_code
                             WHEN ioc.charge_type = ''Rate''
                                THEN cm_pum.cur_code
                             ELSE cm_ioc.cur_code
                          END
                         ) AS amount_unit,
                         ioc.other_charge_desc AS description, ?
                    FROM is_invoice_summary invs,
                         ioc_invoice_other_charge ioc,
                         cm_currency_master cm,
                         scm_service_charge_master scm,
                         ppu_product_price_units ppu,
                         pum_price_unit_master pum,
                         qum_quantity_unit_master qum,
                         cm_currency_master cm_ioc,
                         cm_currency_master cm_pum,
                         cm_currency_master cm_lot,
                         pcmac_pcm_addn_charges pcmac
                   WHERE invs.internal_invoice_ref_no =
                                                   ioc.internal_invoice_ref_no
                     AND ioc.other_charge_cost_id = scm.cost_id(+)
                     AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
                     AND ioc.invoice_cur_id = cm.cur_id(+)
                     AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
                     AND ioc.rate_price_unit = cm_lot.cur_id(+)
                     AND ppu.price_unit_id = pum.price_unit_id(+)
                     AND ioc.qty_unit_id = qum.qty_unit_id(+)
                     AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
                     AND cm_pum.cur_id(+) = pum.cur_id
                     AND ioc.internal_invoice_ref_no = ?)
   SELECT *
     FROM TEST t
    WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
    
fetchQueryITDDForDC clob:='INSERT INTO itd_d
            (internal_invoice_ref_no, tax_code, tax_rate, invoice_currency,
             fx_rate, amount, tax_currency, invoice_amount, applicable_on,
             internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          tm.tax_code AS tax_code, itd.tax_rate AS tax_rate,
          cm.cur_code AS invoice_currency, itd.fx_rate AS fx_rate,
          itd.tax_amount AS amount, cm_tax.cur_code AS tax_currency,
          itd.tax_amount_in_inv_cur AS invoice_amount,
          itd.applicable_on AS applicable_on, ?
     FROM is_invoice_summary invs,
          itd_invoice_tax_details itd,
          tm_tax_master tm,
          cm_currency_master cm,
          cm_currency_master cm_tax
    WHERE invs.internal_invoice_ref_no = itd.internal_invoice_ref_no
      AND itd.tax_code_id = tm.tax_id
      AND itd.invoice_cur_id = cm.cur_id
      AND itd.tax_amount_cur_id = cm_tax.cur_id
      AND itd.internal_invoice_ref_no = ?';
      
fetchQueryISBDSCHILDDForDC clob:='INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, OIPI.REMARKS as remarks, ?
     FROM phd_profileheaderdetails phd,
          oba_our_bank_accounts oba,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi  
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oba.bank_id = phd.profileid
      AND oba.bank_id = oipi.bank_id
      and OIPI.BANK_ACCOUNT_ID = OBA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?';
      
      
fetchQueryISBDPCHILDDForDC clob:='INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, remarks, iban, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          bpb.bank_name AS bank_name, bpa.account_no AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction,
          cpipi.remarks AS remarks, bpa.iban AS iban,?
     FROM bpa_bp_bank_accounts bpa,
          bpb_business_partner_banks bpb,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = bpa.bank_id
      AND bpa.bank_id = bpb.bank_id
      AND cpipi.bank_account_id = bpa.account_id
      AND invs.internal_invoice_ref_no = ?';
      
fetchQueryISDForConcDC clob:='INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_quantity, invoiced_qty_unit, internal_invoice_ref_no,
             invoice_amount, material_cost, addditional_charges, taxes,
             due_date, supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             our_person_incharge, internal_comments, is_self_billing,is_inv_draft, internal_doc_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            invs.invoiced_qty AS invoice_quantity,
            qum_gmr.qty_unit AS invoiced_qty_unit,
            invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            invs.total_amount_to_pay AS invoice_amount,
            invs.amount_to_pay_before_adj AS material_cost,
            invs.total_other_charge_amount AS addditional_charges,
            invs.total_tax_amount AS taxes, invs.payment_due_date AS due_date,
            invs.cp_ref_no AS supplier_invoice_no,
            pcm.issue_date AS contract_date,
            pcm.contract_ref_no AS contract_ref_no,
            SUM (ii.invoicable_qty) AS stock_quantity,
            stragg(ii.stock_ref_no) AS stock_ref_no,
            cm.cur_code AS invoice_amount_unit, gmr.gmr_ref_no AS gmr_ref_no,
            gmr.qty AS gmr_quality, pcpd.qty_max_val AS contract_quantity,
            qum.qty_unit AS contract_qty_unit,
            pcpd.max_tolerance AS contract_tolerance,
            qat.quality_name AS quality, pdm.product_desc AS product,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            pym.payment_term AS payment_term,
            gmr.final_weight AS gmr_finalize_qty, phd.companyname AS cp_name,
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip, pcm.contract_type AS contract_type,
            cymloading.country_name AS origin,
            pci.terms AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            NVL (akuser.login_name, '' '') AS our_person_incharge, INVS.INTERNAL_COMMENTS as internal_comments,pcm.is_self_billing as is_self_billing,INVS.IS_INV_DRAFT as is_inv_draft, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            pcm_physical_contract_main pcm,
            v_pci pci,
            ii_invoicable_item ii,
            cm_currency_master cm,
            gmr_goods_movement_record gmr,
            pcpd_pc_product_definition pcpd,
            qum_quantity_unit_master qum,
            pcpq_pc_product_quality pcpq,
            qat_quality_attributes qat,
            pdm_productmaster pdm,
            phd_profileheaderdetails phd,
            pym_payment_terms_master pym,
            pad_profile_addresses pad,
            cym_countrymaster cym,
            cim_citymaster cim,
            sm_state_master sm,
            bpat_bp_address_type bpat,
            cym_countrymaster cymloading,
            sad_shipment_advice sad,
            sd_shipment_detail sd,
            phd_profileheaderdetails phd1,
            phd_profileheaderdetails phd2,
            qum_quantity_unit_master qum_gmr,
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND iid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND iid.invoicable_item_id = ii.invoicable_item_id
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.invoice_currency_id = cm.cur_id
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.pcpd_id = pcpq.pcpd_id
        AND pci.quality_id = qat.quality_id
        AND pcpq.quality_template_id = qat.quality_id
        AND pcpd.product_id = pdm.product_id
        AND pcm.cp_id = phd.profileid
        AND INVS.CREDIT_TERM(+) = pym.payment_term_id
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND pad.address_type = bpat.bp_address_type_id(+)
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.consignee_id = phd1.profileid(+)
        AND sd.consignee_id = phd2.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND pad.is_deleted(+) = ''N''
        AND pad.address_type(+) = ''Billing''
        AND invs.internal_invoice_ref_no = ?
   GROUP BY invs.invoice_ref_no,
            invs.invoice_type_name,
            invs.invoice_issue_date,
            invs.invoiced_qty,
            invs.internal_invoice_ref_no,
            invs.total_amount_to_pay,
            invs.total_other_charge_amount,
            invs.total_tax_amount,
            invs.payment_due_date,
            invs.cp_ref_no,
            pcm.issue_date,
            pcm.contract_ref_no,
            cm.cur_code,
            gmr.gmr_ref_no,
            gmr.qty,
            pcpd.qty_max_val,
            qum.qty_unit,
            pcpd.max_tolerance,
            qat.quality_name,
            pdm.product_desc,
            pcm.cp_contract_ref_no,
            pym.payment_term,
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.terms,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            akuser.login_name,
            invs.invoice_status,
            INVS.INTERNAL_COMMENTS, is_self_billing,
            INVS.IS_INV_DRAFT';
            
fetchQueryISDCCONCCHILDDForDC clob:='INSERT INTO is_dc_conc_child_d
            (internal_inv_ref_no, element_id, element_name, old_invoiced_qty,
             old_invoiced_qty_unit, old_payable_price, old_payable_price_unit,
             old_payable_amount, amount_unit, new_invoiced_qty,
             new_invoiced_qty_unit, new_payable_price, new_payable_price_unit,
             new_payable_amount, old_fx_rate, new_fx_rate, new_rc_amount,
             old_rc_amount, new_tc_amount, old_tc_amount, new_penalty_amount,
             old_penalty_amount, stock_ref_no, lot_ref_no,
             internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_inv_ref_no,
          iied.element_id AS element_id, aml.attribute_name AS element_name,
          iied.element_invoiced_qty AS old_invoiced_qty,
          qum.qty_unit AS old_invoiced_qty_unit,
          iied.element_payable_price AS old_payable_price,
          pum.price_unit_name AS old_payable_price_unit,
          iied.element_payable_amount AS old_payable_amount,
          cm.cur_code AS amount_unit,
          iied.new_invoiced_qty AS new_invoiced_qty,
          qum.qty_unit AS new_invoiced_qty_unit,
          iied.new_price AS new_payable_price,
          pum.price_unit_name AS new_payable_price_unit,
          iied.new_payable_amount AS new_payable_amount,
          iied.fx_rate AS old_fx_rate, iied.new_fx_rate AS new_fx_rate,
          (SELECT SUM (inrc.rcharges_amount)
             FROM inrc_inv_refining_charges inrc
            WHERE inrc.element_id = aml.attribute_id
              AND inrc.internal_invoice_ref_no = invs.internal_invoice_ref_no)
                                                             AS new_rc_amount,
          (SELECT SUM (inrc.rcharges_amount)
             FROM inrc_inv_refining_charges inrc,
                  cpcr_commercial_inv_pc_mapping cpcr
            WHERE inrc.element_id = aml.attribute_id
              AND cpcr.internal_invoice_ref_no = invs.internal_invoice_ref_no
              AND cpcr.parent_invoice_ref_no = inrc.internal_invoice_ref_no)
                                                             AS old_rc_amount,
          (SELECT SUM (intc.tcharges_amount)
             FROM intc_inv_treatment_charges intc
            WHERE intc.element_id = aml.attribute_id
              AND intc.internal_invoice_ref_no = invs.internal_invoice_ref_no)
                                                             AS new_tc_amount,
          (SELECT SUM (intc.tcharges_amount)
             FROM intc_inv_treatment_charges intc,
                  cpcr_commercial_inv_pc_mapping cpcr
            WHERE intc.element_id = aml.attribute_id
              AND cpcr.internal_invoice_ref_no = invs.internal_invoice_ref_no
              AND cpcr.parent_invoice_ref_no = intc.internal_invoice_ref_no)
                                                             AS old_tc_amount,
          (SELECT SUM (iepd.element_penalty_amount)
             FROM iepd_inv_epenalty_details iepd
            WHERE iepd.element_id = aml.attribute_id
              AND iepd.internal_invoice_ref_no = invs.internal_invoice_ref_no)
                                                        AS new_penalty_amount,
          (SELECT SUM (iepd.element_penalty_amount)
             FROM iepd_inv_epenalty_details iepd,
                  cpcr_commercial_inv_pc_mapping cpcr
            WHERE iepd.element_id = aml.attribute_id
              AND cpcr.internal_invoice_ref_no = invs.internal_invoice_ref_no
              AND cpcr.parent_invoice_ref_no = iepd.internal_invoice_ref_no)
                                                        AS old_penalty_amount,
          grd.internal_stock_ref_no AS stock_ref_no,
          iied.sub_lot_no AS lot_ref_no, ?
     FROM is_invoice_summary invs,
          iied_inv_item_element_details iied,
          aml_attribute_master_list aml,
          pum_price_unit_master pum,
          ppu_product_price_units ppu,
          cm_currency_master cm,
          grd_goods_record_detail grd,
          qum_quantity_unit_master qum,
          cpcr_commercial_inv_pc_mapping cpcr
    WHERE iied.internal_invoice_ref_no = invs.internal_invoice_ref_no
      AND iied.element_id = aml.attribute_id
      AND iied.element_inv_qty_unit_id = qum.qty_unit_id
      AND iied.element_payable_price_unit_id = ppu.internal_price_unit_id
      AND ppu.price_unit_id = pum.price_unit_id
      AND cm.cur_id = invs.invoice_cur_id
      AND iied.grd_id = grd.internal_grd_ref_no
      AND invs.internal_invoice_ref_no = cpcr.internal_invoice_ref_no
      AND invs.internal_invoice_ref_no = ?';
      
      
fetchQueryIOCDForConcDC clob:='INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, description,internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no
                                                   AS internal_invoice_ref_no,
                         NVL
                            (scm.cost_display_name,
                             pcmac.addn_charge_name
                            ) AS other_charge_cost_name,
                         ioc.charge_type AS charge_type,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             WHEN (ioc.rate_fx_rate IS NULL)
                             AND (ioc.flat_amount_fx_rate IS NULL)
                                THEN 1
                             WHEN ioc.rate_fx_rate IS NULL
                                THEN ioc.flat_amount_fx_rate
                             ELSE ioc.rate_fx_rate
                          END
                         ) AS fx_rate,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             ELSE ioc.quantity
                          END
                         ) AS quantity,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             ELSE NVL (ioc.rate_amount, ioc.flat_amount)
                          END
                         ) AS amount,
                         ioc.amount_in_inv_cur AS invoice_amount,
                         cm.cur_code AS invoice_cur_name,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             WHEN ioc.rate_price_unit = ''Bags''
                             AND ioc.charge_type = ''Rate''
                                THEN cm.cur_code || ''/'' || ''Bag''
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                     ''Ocular Inspection Charge'',
                                     ''Small Lot Charges'')
                             AND ioc.charge_type = ''Rate''
                                THEN    NVL (cm_lot.cur_code, cm.cur_code)
                                     || ''/''
                                     || ''Lot''
                             ELSE pum.price_unit_name
                          END
                         ) AS rate_price_unit_name,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             ELSE NVL (ioc.flat_amount, ioc.rate_charge)
                          END
                         ) AS charge_amount_rate,
                         (CASE
                             WHEN ioc.rate_price_unit = ''Bags''
                                THEN ''Bags''
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                     ''Ocular Inspection Charge'',
                                     ''Small Lot Charges'')
                                THEN ''Lots''
                             WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                                THEN ''Lots''
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             ELSE qum.qty_unit
                          END
                         ) AS quantity_unit,
                         (CASE
                             WHEN (scm.cost_display_name = ''Location Value'')
                                THEN NULL
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                     ''Ocular Inspection Charge'',
                                     ''Small Lot Charges'')
                             AND ioc.charge_type = ''Rate''
                                THEN cm_lot.cur_code
                             WHEN scm.cost_component_name IN
                                                          (''Handling Charge'')
                                THEN cm.cur_code
                             WHEN ioc.charge_type = ''Rate''
                                THEN cm_pum.cur_code
                             ELSE cm_ioc.cur_code
                          END
                         ) AS amount_unit,
                         ioc.other_charge_desc AS description, ?
                    FROM is_invoice_summary invs,
                         ioc_invoice_other_charge ioc,
                         cm_currency_master cm,
                         scm_service_charge_master scm,
                         ppu_product_price_units ppu,
                         pum_price_unit_master pum,
                         qum_quantity_unit_master qum,
                         cm_currency_master cm_ioc,
                         cm_currency_master cm_pum,
                         cm_currency_master cm_lot,
                         pcmac_pcm_addn_charges pcmac
                   WHERE invs.internal_invoice_ref_no =
                                                   ioc.internal_invoice_ref_no
                     AND ioc.other_charge_cost_id = scm.cost_id(+)
                     AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
                     AND ioc.invoice_cur_id = cm.cur_id(+)
                     AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
                     AND ioc.rate_price_unit = cm_lot.cur_id(+)
                     AND ppu.price_unit_id = pum.price_unit_id(+)
                     AND ioc.qty_unit_id = qum.qty_unit_id(+)
                     AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
                     AND cm_pum.cur_id(+) = pum.cur_id
                     AND ioc.internal_invoice_ref_no = ?)
   SELECT *
     FROM TEST t
    WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
    
fetchQueryITDForConcDC clob:='INSERT INTO itd_d
            (internal_invoice_ref_no, tax_code, tax_rate, invoice_currency,
             fx_rate, amount, tax_currency, invoice_amount, applicable_on,
             internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          tm.tax_code AS tax_code, itd.tax_rate AS tax_rate,
          cm.cur_code AS invoice_currency, itd.fx_rate AS fx_rate,
          itd.tax_amount AS amount, cm_tax.cur_code AS tax_currency,
          itd.tax_amount_in_inv_cur AS invoice_amount,
          itd.applicable_on AS applicable_on, ?
     FROM is_invoice_summary invs,
          itd_invoice_tax_details itd,
          tm_tax_master tm,
          cm_currency_master cm,
          cm_currency_master cm_tax
    WHERE invs.internal_invoice_ref_no = itd.internal_invoice_ref_no
      AND itd.tax_code_id = tm.tax_id
      AND itd.invoice_cur_id = cm.cur_id
      AND itd.tax_amount_cur_id = cm_tax.cur_id
      AND itd.internal_invoice_ref_no = ?';
      
      
      
fetchQueryIGDINVGMRDC clob:='INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, dry_qty, dry_qty_unit_name, moisture,
             moisture_unit_name, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            gmr.gmr_ref_no AS gmr_ref_no,
            stragg (grd.container_no) AS container_name,
            NVL (gmr.mode_of_transport, '' '') AS mode_of_transport,
            gmr.bl_date AS bl_date, NVL (cim.city_name, '' '') AS origin_city,
            NVL (cym.country_name, '' '') AS origin_country, gmr.qty AS wet_qty,
            qum.qty_unit AS wet_qty_unit_name,
              gmr.qty
            - ((  gmr.qty
                * (ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                             / SUM (asm.net_weight)
                            )
                          * 100,
                          5
                         )
                  )
                / 100
               )
              ) AS dry_qty,
            qum.qty_unit AS dry_qty_unit_name,
            ROUND (  (  (SUM (asm.net_weight) - SUM (asm.dry_weight))
                      / SUM (asm.net_weight)
                     )
                   * 100,
                   5
                  ) AS moisture,
            qum.qty_unit AS moisture_unit_name, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            grd_goods_record_detail grd,
            gmr_goods_movement_record gmr,
            asm_assay_sublot_mapping asm,
            ash_assay_header ash,
            iam_invoice_assay_mapping iam,
            cym_countrymaster cym,
            cim_citymaster cim,
            qum_quantity_unit_master qum
      WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
        AND iid.stock_id = grd.internal_grd_ref_no
        AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
        AND iid.stock_id = iam.internal_grd_ref_no
        AND iam.ash_id = ash.ash_id
        AND ash.ash_id = asm.ash_id
        AND qum.qty_unit_id = asm.net_weight_unit
        AND cym.country_id(+) = gmr.loading_country_id
        AND cim.city_id(+) = gmr.loading_city_id
        AND invs.internal_invoice_ref_no = ?
   GROUP BY gmr.internal_gmr_ref_no,
            gmr.qty,
            invs.internal_invoice_ref_no,
            grd.container_no,
            gmr.mode_of_transport,
            gmr.bl_date,
            gmr.gmr_ref_no,
            cym.country_name,
            cim.city_name,
            qum.qty_unit';
            
fetchQueryISBDSChildDForConcDC clob:='INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction,
          oipi.remarks AS remarks,?
     FROM phd_profileheaderdetails phd,
          oba_our_bank_accounts oba,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oba.bank_id = phd.profileid
      AND oba.bank_id = oipi.bank_id
      AND oipi.bank_account_id = oba.account_id
      AND invs.internal_invoice_ref_no = ?';
      
fetchQueryISBDPChildDForConcDC clob:='INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, remarks, iban, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          bpb.bank_name AS bank_name, bpa.account_no AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction,
          cpipi.remarks AS remarks, bpa.iban AS iban, ?
     FROM bpa_bp_bank_accounts bpa,
          bpb_business_partner_banks bpb,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = bpa.bank_id
      AND bpa.bank_id = bpb.bank_id
      AND cpipi.bank_account_id = bpa.account_id
      AND invs.internal_invoice_ref_no = ?';
            

BEGIN
    
    UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryISDForDC WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-DC' AND DGM.SEQUENCE_ORDER=1 AND DGM.IS_CONCENTRATE='N';
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-DC-C1' AND DGM.SEQUENCE_ORDER=2 AND DGM.IS_CONCENTRATE='N';
    
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-DC-C1', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 2, 
    fetchQueryISDCCHILDDForDC, 'N');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE  DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-IOC_BM' AND DGM.SEQUENCE_ORDER=3 AND DGM.IS_CONCENTRATE='N';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-IOC_BM', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 3, 
    fetchQueryIOCDForDC, 'N');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-ITD_BM' AND DGM.SEQUENCE_ORDER=4 AND DGM.IS_CONCENTRATE='N';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-ITD_BM', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 4, 
    fetchQueryITDDForDC, 'N');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE  DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-BDS-DC_BM' AND DGM.SEQUENCE_ORDER=5 AND DGM.IS_CONCENTRATE='N';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-BDS-DC_BM', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 5, 
    fetchQueryISBDSCHILDDForDC, 'N');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-BDP-DC_BM' AND DGM.SEQUENCE_ORDER=6 AND DGM.IS_CONCENTRATE='N';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-BDP-DC_BM', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 6, 
    fetchQueryISBDPCHILDDForDC, 'N');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-DC-CONC' AND DGM.SEQUENCE_ORDER=1 AND DGM.IS_CONCENTRATE='Y';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-DC-CONC', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 1, 
    fetchQueryISDForConcDC, 'Y');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-DC-CONC-C1' AND DGM.SEQUENCE_ORDER=2 AND DGM.IS_CONCENTRATE='Y';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-DC-CONC-C1', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 2, 
    fetchQueryISDCCONCCHILDDForDC, 'Y');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-IOC-CONC' AND DGM.SEQUENCE_ORDER=3 AND DGM.IS_CONCENTRATE='Y';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-IOC-CONC', 'CREATE_DFT_DC', 'Debit Credit', 'CREATE_DC', 3, 
    fetchQueryIOCDForConcDC, 'Y');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-ITD-CONC' AND DGM.SEQUENCE_ORDER=4 AND DGM.IS_CONCENTRATE='Y';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-ITD-CONC', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 4, 
    fetchQueryITDForConcDC, 'Y');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-FIC-IGD-CONC' AND DGM.SEQUENCE_ORDER=5 AND DGM.IS_CONCENTRATE='Y';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-FIC-IGD-CONC', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 5, 
    fetchQueryIGDINVGMRDC, 'Y');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-DC-CONC-BDS' AND DGM.SEQUENCE_ORDER=6 AND DGM.IS_CONCENTRATE='Y';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-DC-CONC-BDS', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 6, 
    fetchQueryISBDSChildDForConcDC, 'Y');
    
    DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID='CREATE_DFT_DC' AND DGM.DGM_ID='DGM-DFT-DC-CONC-BDP' AND DGM.SEQUENCE_ORDER=7 AND DGM.IS_CONCENTRATE='Y';
 
    INSERT INTO DGM_DOCUMENT_GENERATION_MASTER VALUES('DGM-DFT-DC-CONC-BDP', 'CREATE_DFT_DC', 'Draft Debit Credit Note', 'CREATE_DFT_DC', 7, 
    fetchQueryISBDPChildDForConcDC, 'Y');
    
    
COMMIT;

END;