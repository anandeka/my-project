CREATE OR REPLACE VIEW V_DOC_OTHER_CHARGES_INVOICE
AS
select 'Other Charges' section_name,
       'Other Charges' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.internal_invoice_ref_no,
       
       -- Summary Header Details
       isd.invoice_ref_no invoice_no,
       isd.invoice_type_name invoice_type,
       isd.cp_contract_ref_no,
       isd.contract_ref_no our_contract_ref_no,
       akc.corporate_name,
       isd.cp_name,
       isd.sales_purchase,
       isd.product,
       isd.quality,
       isd.cp_address,
       isd.internal_comments comments,
       isd.invoice_creation_date invoice_issue_date,
       isd.due_date payment_due_date,
       isd.payment_term,
       isd.inco_term_location delivery_terms,
       -- Delivery Details
       null igd_gmr_ref_no,
       null igd_container_name,
       null igd_bl_date,
       null igd_origin,
       null igd_wet_qty,
       null igd_wet_qty_unit_name,
       null igd_moisture,
       null igd_moisture_unit_name,
       null igd_dry_qty,
       null igd_dry_qty_unit_name,
       -- Payable Details
       null                 metal,
       null                 stock_ref_no_lot_no,
       null                 dry_qty,
       null                 dry_qty_unit,
       null                 assay_details,
       null                 net_payable_percentage,
       null                 net_payable_percentage_unit,
       ioc.quantity         payable_penalty_qty,
       ioc.quantity_unit    payable_penalty_qty_unit,
       null                 price,
       null                 price_unit,
       ioc.invoice_amount   total_amount,
       ioc.invoice_cur_name total_amount_unit,
       -- TC Details
       null wet_qty,
       null wet_qty_unit,
       null moisture,
       null moisture_unit,
       null fixed_tc_amount,
       null fixed_tc_amount_unit,
       null escalator_descalator,
       -- Penalty Details
       null penalty_rate,
       null penalty_rate_unit,
       
       -- Charegs Details
       ioc.other_charge_cost_name cost_name,
       ioc.charge_type,
       ioc.charge_amount_rate amount_rate,
       ioc.rate_price_unit_name amount_rate_unit,
       ioc.fx_rate,
       ioc.amount amount_in_charge_tax_vat_ccy,
       ioc.amount_unit charge_tax_vat_ccy,
       ioc.description,
       -- Tax Details
       null tax_code,
       null tax_rate,
       null applicable_on,
       -- Premium Details
       null premium,
       null premium_gmr_ref_no,
       -- API PI Details
       null invoice_ref_no,
       null invoice_description,
       null provisional_percentage,
       null provisional_api_amount,
       
       -- VAT Details
       null our_vat_reg_no,
       null cp_vat_reg_no,
       null vat_code,
       null vat_rate,
       null vat_amount,
       -- Bank Details
       null beneficiary_name,
       null bank_name,
       null account_no,
       null iban,
       null aba_rtn,
       null instruction,
       null remarks,
       
       -- Summary Details
       isd.total_premium_amount,
       isd.freight_charge,
       isd.adjustment_amount,
       isd.is_pledge pledge,
       isd.is_free_metal free_metal,
       isd.invoice_amount
  from is_d                isd,
       ioc_d               ioc,
       ds_document_summary ds,
       v_ak_corporate      akc
 where isd.internal_doc_ref_no = ioc.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
union all
select 'Other Taxes' section_name,
       'Other Taxes' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.internal_invoice_ref_no,
       
       -- Summary Header Details
       isd.invoice_ref_no invoice_no,
       isd.invoice_type_name invoice_type,
       isd.cp_contract_ref_no,
       isd.contract_ref_no our_contract_ref_no,
       akc.corporate_name,
       isd.cp_name,
       isd.sales_purchase,
       isd.product,
       isd.quality,
       isd.cp_address,
       isd.internal_comments comments,
       isd.invoice_creation_date invoice_issue_date,
       isd.due_date payment_due_date,
       isd.payment_term,
       isd.inco_term_location delivery_terms,
       -- Delivery Details
       null igd_gmr_ref_no,
       null igd_container_name,
       null igd_bl_date,
       null igd_origin,
       null igd_wet_qty,
       null igd_wet_qty_unit_name,
       null igd_moisture,
       null igd_moisture_unit_name,
       null igd_dry_qty,
       null igd_dry_qty_unit_name,
       -- Payable Details
       null metal,
       null stock_ref_no_lot_no,
       null dry_qty,
       null dry_qty_unit,
       null assay_details,
       null net_payable_percentage,
       null net_payable_percentage_unit,
       null payable_penalty_qty,
       null payable_penalty_qty_unit,
       null price,
       null price_unit,
       (case
         when itd.invoice_amount is null or itd.invoice_amount = '' then
          0
         else
          to_number(itd.invoice_amount)
       end) total_amount,
       itd.invoice_currency total_amount_unit,
       -- TC Details
       null wet_qty,
       null wet_qty_unit,
       null moisture,
       null moisture_unit,
       null fixed_tc_amount,
       null fixed_tc_amount_unit,
       null escalator_descalator,
       -- Penalty Details
       null penalty_rate,
       null penalty_rate_unit,
       -- Charegs Details
       null cost_name,
       null charge_type,
       null amount_rate,
       null amount_rate_unit,
       itd.fx_rate,
       itd.amount amount_in_charge_tax_vat_ccy,
       itd.tax_currency charge_tax_vat_ccy,
       null description,
       -- Tax Details
       itd.tax_code,
       itd.tax_rate,
       itd.applicable_on applicable_on,
       -- Premium Details
       null premium,
       null premium_gmr_ref_no,
       -- API PI Details
       null invoice_ref_no,
       null invoice_description,
       null provisional_percentage,
       null provisional_api_amount,
       
       -- VAT Details
       null our_vat_reg_no,
       null cp_vat_reg_no,
       null vat_code,
       null vat_rate,
       null vat_amount,
       -- Bank Details
       null beneficiary_name,
       null bank_name,
       null account_no,
       null iban,
       null aba_rtn,
       null instruction,
       null remarks,
       
       -- Summary Details
       isd.total_premium_amount,
       isd.freight_charge,
       isd.adjustment_amount,
       isd.is_pledge pledge,
       isd.is_free_metal free_metal,
       isd.invoice_amount
  from is_d                isd,
       itd_d               itd,
       ds_document_summary ds,
       v_ak_corporate      akc
 where isd.internal_doc_ref_no = itd.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
union all
select 'Invoice' section_name,
       'Payment Details' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.internal_invoice_ref_no,
       
       -- Summary Header Details
       isd.invoice_ref_no invoice_no,
       isd.invoice_type_name invoice_type,
       isd.cp_contract_ref_no,
       isd.contract_ref_no our_contract_ref_no,
       akc.corporate_name,
       isd.cp_name,
       isd.sales_purchase,
       isd.product,
       isd.quality,
       isd.cp_address,
       isd.internal_comments comments,
       isd.invoice_creation_date invoice_issue_date,
       isd.due_date payment_due_date,
       isd.payment_term,
       isd.inco_term_location delivery_terms,
       -- Delivery Details
       null igd_gmr_ref_no,
       null igd_container_name,
       null igd_bl_date,
       null igd_origin,
       null igd_wet_qty,
       null igd_wet_qty_unit_name,
       null igd_moisture,
       null igd_moisture_unit_name,
       null igd_dry_qty,
       null igd_dry_qty_unit_name,
       -- Payable Details
       null metal,
       null stock_ref_no_lot_no,
       null dry_qty,
       null dry_qty_unit,
       null assay_details,
       null net_payable_percentage,
       null net_payable_percentage_unit,
       null payable_penalty_qty,
       null payable_penalty_qty_unit,
       null price,
       null price_unit,
       (case
         when isd.invoice_amount is null or isd.invoice_amount = '' then
          0
         else
          to_number(isd.invoice_amount)
       end) total_amount,
       isd.invoice_amount_unit total_amount_unit,
       -- TC Details
       null wet_qty,
       null wet_qty_unit,
       null moisture,
       null moisture_unit,
       null fixed_tc_amount,
       null fixed_tc_amount_unit,
       null escalator_descalator,
       -- Penalty Details
       null penalty_rate,
       null penalty_rate_unit,
       -- Charegs Details
       null cost_name,
       null charge_type,
       null amount_rate,
       null amount_rate_unit,
       null fx_rate,
       null amount_in_charge_tax_vat_ccy,
       null charge_tax_vat_ccy,
       null description,
       -- Tax Details
       null tax_code,
       null tax_rate,
       null applicable_on,
       -- Premium Details
       null premium,
       null premium_gmr_ref_no,
       -- API PI Details
       null invoice_ref_no,
       null invoice_description,
       null provisional_percentage,
       null provisional_api_amount,
       
       -- VAT Details
       null our_vat_reg_no,
       null cp_vat_reg_no,
       null vat_code,
       null vat_rate,
       null vat_amount,
       
       -- Bank Details       
--       (case
--         when isd.sales_purchase = 'P' then
--          ibp.beneficiary_name
--         else
--          ibs.beneficiary_name
--       end) beneficiary_name,
       nvl2(ibp.beneficiary_name, ibp.beneficiary_name, ibs.beneficiary_name) beneficiary_name,
--       (case
--         when isd.sales_purchase = 'P' then
--          ibp.bank_name
--         else
--          ibs.bank_name
--       end) bank_name,
       nvl2(ibp.bank_name, ibp.bank_name, ibs.bank_name) bank_name,
--       (case
--         when isd.sales_purchase = 'P' then
--          ibp.account_no
--         else
--          ibs.account_no
--       end) account_no,
        nvl2(ibp.account_no, ibp.account_no, ibs.account_no) account_no,
--       (case
--         when isd.sales_purchase = 'P' then
--          ibp.iban
--         else
--          ibs.iban
--       end) iban,
       nvl2(ibp.iban, ibp.iban, ibs.iban) iban,
--       (case
--         when isd.sales_purchase = 'P' then
--          ibp.aba_rtn
--         else
--          ibs.aba_rtn
--       end) aba_rtn,
       nvl2(ibp.aba_rtn, ibp.aba_rtn, ibs.aba_rtn) aba_rtn,
--       (case
--         when isd.sales_purchase = 'P' then
--          ibp.instruction
--         else
--          ibs.instruction
--       end) instruction,
        nvl2(ibp.instruction, ibp.instruction, ibs.instruction) instruction,
--       (case
--         when isd.sales_purchase = 'P' then
--          ibp.remarks
--         else
--          ibs.remarks
--       end) remarks,
       nvl2(ibp.remarks, ibp.remarks, ibs.remarks) remarks,
       -- Summary Details
       isd.total_premium_amount,
       isd.freight_charge,
       isd.adjustment_amount,
       isd.is_pledge pledge,
       isd.is_free_metal free_metal,
       isd.invoice_amount
  from is_d                isd,
       is_bdp_child_d      ibp,
       is_bds_child_d      ibs,
       ds_document_summary ds,
       v_ak_corporate      akc
 where isd.internal_doc_ref_no = ibp.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ibs.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
union all
select 'Invoice' section_name,
       'VAT' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.internal_invoice_ref_no,
       -- Summary Header Details
       isd.invoice_ref_no invoice_no,
       isd.invoice_type_name invoice_type,
       isd.cp_contract_ref_no,
       isd.contract_ref_no our_contract_ref_no,
       akc.corporate_name,
       isd.cp_name,
       isd.sales_purchase,
       isd.product,
       isd.quality,
       isd.cp_address,
       isd.internal_comments comments,
       isd.invoice_creation_date invoice_issue_date,
       isd.due_date payment_due_date,
       isd.payment_term,
       isd.inco_term_location delivery_terms,
       -- Delivery Details
       null igd_gmr_ref_no,
       null igd_container_name,
       null igd_bl_date,
       null igd_origin,
       null igd_wet_qty,
       null igd_wet_qty_unit_name,
       null igd_moisture,
       null igd_moisture_unit_name,
       null igd_dry_qty,
       null igd_dry_qty_unit_name,
       -- Payable Details
       null metal,
       null stock_ref_no_lot_no,
       null dry_qty,
       null dry_qty_unit,
       null assay_details,
       null net_payable_percentage,
       null net_payable_percentage_unit,
       null payable_penalty_qty,
       null payable_penalty_qty_unit,
       null price,
       null price_unit,
       (case
         when isd.invoice_amount_unit is null or isd.invoice_amount = '' then
          0
         else
          to_number(isd.invoice_amount)
       end) total_amount,
       cm_inv.cur_code total_amount_unit, -- Need
       -- TC Details
       null wet_qty,
       null wet_qty_unit,
       null mositure,
       null moisture_unit,
       null fixed_tc_amount,
       null fixed_tc_amount_unit,
       null escalator_descalator,
       -- Penalty Details
       null penalty_rate,
       null penalty_rate_unit,
       -- Charegs Details
       null                      cost_name,
       null                      charge_type,
       null                      amount_rate,
       null                      amount_rate_unit,
       vat.fx_rate_vc_ic         fx_rate,
       vat.vat_amount_in_vat_cur amount_in_charge_tax_vat_ccy,
       cm_vat.cur_code           charge_tax_vat_ccy,
       null                      description,
       -- Tax Details
       null tax_code,
       null tax_rate,
       null applicable_on,
       -- Premium Details
       null premium,
       null premium_gmr_ref_no,
       -- API PI Details
       null invoice_ref_no,
       null invoice_description,
       null provisional_percentage,
       null provisional_api_amount,
       
       -- VAT Details
       vat.our_vat_no our_vat_reg_no,
       vat.cp_vat_no cp_vat_reg_no,
       vat.main_inv_vat_code vat_code,
       vat.vat_rate,
       vat.vat_amount_in_inv_cur vat_amount,
       -- Bank Details
       null beneficiary_name,
       null bank_name,
       null account_no,
       null iban,
       null aba_rtn,
       null instruction,
       null remarks,
       
       -- Summary Details
       isd.total_premium_amount,
       isd.freight_charge,
       isd.adjustment_amount,
       isd.is_pledge pledge,
       isd.is_free_metal free_metal,
       isd.invoice_amount
  from is_d                    isd,
       ds_document_summary     ds,
       v_ak_corporate          akc,
       ivd_invoice_vat_details vat,
       cm_currency_master      cm_vat,
       cm_currency_master      cm_inv
 where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
   and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
   and vat.is_separate_invoice(+) = 'N'
   and vat.vat_remit_cur_id = cm_vat.cur_id
   and vat.invoice_cur_id = cm_inv.cur_id
union all
select 'Invoice' section_name,
       'Summary' sub_section,
       ds.corporate_id,
       
       -- cross check
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.internal_invoice_ref_no,
       -- Summary Header Details
       isd.invoice_ref_no invoice_no,
       isd.invoice_type_name invoice_type,
       isd.cp_contract_ref_no,
       isd.contract_ref_no our_contract_ref_no,
       akc.corporate_name,
       isd.cp_name,
       isd.sales_purchase,
       isd.product,
       isd.quality,
       isd.cp_address,
       isd.internal_comments comments,
       isd.invoice_creation_date invoice_issue_date,
       isd.due_date payment_due_date,
       isd.payment_term,
       isd.inco_term_location delivery_terms,
       -- Delivery Details
       null igd_gmr_ref_no,
       null igd_container_name,
       null igd_bl_date,
       null igd_origin,
       null igd_wet_qty,
       null igd_wet_qty_unit_name,
       null igd_moisture,
       null igd_moisture_unit_name,
       null igd_dry_qty,
       null igd_dry_qty_unit_name,
       -- Payable Details
       null metal,
       null stock_ref_no_lot_no,
       null dry_qty,
       null dry_qty_unit,
       null assay_details,
       null net_payable_percentage,
       null net_payable_percentage_unit,
       null payable_penalty_qty,
       null payable_penalty_qty_unit,
       null price,
       null price_unit,
       (case
         when isd.invoice_amount_unit is null or isd.invoice_amount = '' then
          0
         else
          to_number(isd.invoice_amount)
       end) total_amount,
       isd.invoice_amount_unit total_amount_unit, -- Need
       -- TC Details
       null wet_qty,
       null wet_qty_unit,
       null mositure,
       null moisture_unit,
       null fixed_tc_amount,
       null fixed_tc_amount_unit,
       null escalator_descalator,
       -- Penalty Details
       null penalty_rate,
       null penalty_rate_unit,
       -- Charegs Details
       null cost_name,
       null charge_type,
       null amount_rate,
       null amount_rate_unit,
       null fx_rate,
       null amount_in_charge_tax_vat_ccy,
       null charge_tax_vat_ccy,
       null description,
       -- Tax Details
       null tax_code,
       null tax_rate,
       null applicable_on,
       -- Premium Details
       null premium,
       null premium_gmr_ref_no,
       -- API PI Details
       null invoice_ref_no,
       null invoice_description,
       null provisional_percentage,
       null provisional_api_amount,
       
       -- VAT Details
       null our_vat_reg_no,
       null cp_vat_reg_no,
       null vat_code,
       null vat_rate,
       null vat_amount,
       -- Bank Details
       null beneficiary_name,
       null bank_name,
       null account_no,
       null iban,
       null aba_rtn,
       null instruction,
       null remarks,
       
       -- Summary Details
       isd.total_premium_amount,
       isd.freight_charge,
       isd.adjustment_amount,
       isd.is_pledge pledge,
       isd.is_free_metal free_metal,
       isd.invoice_amount
  from is_d                isd,
       ds_document_summary ds,
       v_ak_corporate      akc
 where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
