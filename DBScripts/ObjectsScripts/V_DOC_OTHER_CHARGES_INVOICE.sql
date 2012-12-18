CREATE OR REPLACE VIEW V_DOC_OTHER_CHARGES_INVOICE
(section_name, sub_section, corporate_id, logo_path, address1, address2, city, state, country, phone_no, fax_no, internal_doc_ref_no, internal_invoice_ref_no, invoice_no, invoice_type, cp_contract_ref_no, our_contract_ref_no, corporate_name, cp_name, sales_purchase, product, quality, cp_address, comments, invoice_issue_date, payment_due_date, payment_term, delivery_terms, igd_gmr_ref_no, igd_container_name, igd_bl_date, igd_origin, igd_wet_qty, igd_wet_qty_unit_name, igd_moisture, igd_moisture_unit_name, igd_dry_qty, igd_dry_qty_unit_name, metal, stock_ref_no_lot_no, dry_qty, dry_qty_unit, assay_details, net_payable_percentage, net_payable_percentage_unit, payable_penalty_qty, payable_penalty_qty_unit, price, price_unit, total_amount, total_amount_unit, wet_qty, wet_qty_unit, mositure, moisture_unit, fixed_tc_amount, fixed_tc_amount_unit, escalator_descalator, penalty_rate, penalty_rate_unit, cost_name, charge_type, amount_rate, amount_rate_unit, fx_rate, amount_in_charge_tax_vat_ccy, charge_tax_vat_ccy, description, tax_code, tax_rate, applicable_on, premium, premium_gmr_ref_no, invoice_ref_no, invoice_description, provisional_percentage, provisional_api_amount, our_vat_reg_no, cp_vat_reg_no, vat_code, vat_rate, vat_amount, beneficiary_name, bank_name, account_no, iban, aba_rtn, instruction, remarks, total_premium_amount, freight_charge, adjustment_amount, pledge, free_metal, invoice_amount)
AS
SELECT 'Other Charges' section_name, 'Other Charges' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality, isd.cp_address, isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, ioc.quantity payable_penalty_qty,
          ioc.quantity_unit payable_penalty_qty_unit, NULL price,
          NULL price_unit, ioc.invoice_amount total_amount,
          ioc.invoice_cur_name total_amount_unit,
                                                 -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
          
          -- Charegs Details
          ioc.other_charge_cost_name cost_name, ioc.charge_type,
          ioc.charge_amount_rate amount_rate,
          ioc.rate_price_unit_name amount_rate_unit, ioc.fx_rate,
          ioc.amount amount_in_charge_tax_vat_ccy,
          ioc.amount_unit charge_tax_vat_ccy, ioc.description,
                                                              -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_rate, NULL vat_amount,
                                         -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount
     FROM is_d isd, ioc_d ioc, ds_document_summary ds, v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = ioc.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Other Taxes' section_name, 'Other Taxes' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality, isd.cp_address, isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN itd.invoice_amount IS NULL OR itd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (itd.invoice_amount)
           END
          ) total_amount,
          itd.invoice_currency total_amount_unit,
                                                 -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, itd.fx_rate,
          itd.amount amount_in_charge_tax_vat_ccy,
          itd.tax_currency charge_tax_vat_ccy, NULL description,
                                                                -- Tax Details
                                                                itd.tax_code,
          itd.tax_rate, NULL applicable_on,
                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_rate, NULL vat_amount,
                                         -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount
     FROM is_d isd, itd_d itd, ds_document_summary ds, v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = itd.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'Payment Details' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality, isd.cp_address, isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          NULL description,
                           -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          (CASE
              WHEN isd.sales_purchase = 'P'
                 THEN ibp.beneficiary_name
              ELSE ibs.beneficiary_name
           END
          ) beneficiary_name,
          (CASE
              WHEN isd.sales_purchase = 'P'
                 THEN ibp.bank_name
              ELSE ibs.bank_name
           END
          ) bank_name,
          (CASE
              WHEN isd.sales_purchase = 'P'
                 THEN ibp.account_no
              ELSE ibs.account_no
           END
          ) account_no,
          (CASE
              WHEN isd.sales_purchase = 'P'
                 THEN ibp.iban
              ELSE ibs.iban
           END) iban,
          (CASE
              WHEN isd.sales_purchase = 'P'
                 THEN ibp.aba_rtn
              ELSE ibs.aba_rtn
           END
          ) aba_rtn,
          (CASE
              WHEN isd.sales_purchase = 'P'
                 THEN ibp.instruction
              ELSE ibs.instruction
           END
          ) instruction,
          (CASE
              WHEN isd.sales_purchase = 'P'
                 THEN ibp.remarks
              ELSE ibs.remarks
           END
          ) remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount
     FROM is_d isd,
          is_bdp_child_d ibp,
          is_bds_child_d ibs,
          ds_document_summary ds,
          v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = ibp.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ibs.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'VAT' sub_section, ds.corporate_id,
          akc.logo_path, akc.address1, akc.address2, akc.city, akc.state,
          akc.country, akc.phone_no, akc.fax_no, isd.internal_doc_ref_no,
          isd.internal_invoice_ref_no,
                                      -- Summary Header Details
                                      isd.invoice_ref_no invoice_no,
          isd.invoice_type_name invoice_type, isd.cp_contract_ref_no,
          isd.contract_ref_no our_contract_ref_no, akc.corporate_name,
          isd.cp_name, isd.sales_purchase, isd.product, isd.quality,
          isd.cp_address, isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount_unit IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          cm_inv.cur_code total_amount_unit,                           -- Need
                                            -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL mositure, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, vat.fx_rate_vc_ic fx_rate,
          vat.vat_amount_in_vat_cur amount_in_charge_tax_vat_ccy,
          cm_vat.cur_code charge_tax_vat_ccy, NULL description,
                                                               -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          vat.our_vat_no our_vat_reg_no, vat.cp_vat_no cp_vat_reg_no,
          vat.main_inv_vat_code vat_code, vat.vat_rate,
          vat.vat_amount_in_inv_cur vat_amount,
                                               -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount
     FROM is_d isd,
          ds_document_summary ds,
          v_ak_corporate akc,
          ivd_invoice_vat_details vat,
          cm_currency_master cm_vat,
          cm_currency_master cm_inv
    WHERE isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
      AND isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
      AND vat.is_separate_invoice(+) = 'N'
      AND vat.vat_remit_cur_id = cm_vat.cur_id
      AND vat.invoice_cur_id = cm_inv.cur_id
   UNION ALL
   SELECT 'Invoice' section_name, 'Summary' sub_section, ds.corporate_id,
          
          -- cross check
          akc.logo_path, akc.address1, akc.address2, akc.city, akc.state,
          akc.country, akc.phone_no, akc.fax_no, isd.internal_doc_ref_no,
          isd.internal_invoice_ref_no,
                                      -- Summary Header Details
                                      isd.invoice_ref_no invoice_no,
          isd.invoice_type_name invoice_type, isd.cp_contract_ref_no,
          isd.contract_ref_no our_contract_ref_no, akc.corporate_name,
          isd.cp_name, isd.sales_purchase, isd.product, isd.quality,
          isd.cp_address, isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount_unit IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,                   -- Need
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL mositure, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          NULL description,
                           -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_rate, NULL vat_amount,
                                         -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount
     FROM is_d isd, ds_document_summary ds, v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
          AND ds.corporate_id = akc.corporate_id(+) 
