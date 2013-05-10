create or replace view v_doc_invoice as
with separate_vat_info as
(
    select vpcm.internal_invoice_ref_no, ivd.cp_vat_no, ivd.our_vat_no
      from vpcm_vat_parent_child_map vpcm, ivd_invoice_vat_details ivd
     where vpcm.vat_internal_invoice_ref_no = ivd.internal_invoice_ref_no
       and ivd.is_separate_invoice = 'Y'
)   
select 'Invoice' section_name,
       'Invoice' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       (case
         when (isd.is_free_metal = 'Y' or isd.is_pledge = 'Y' or isd.contract_type = 'BASEMETAL') then
          nvl(iscd.product, isd.product)
         else
          iscp.element_name
       end) metal,
       (case
         when (isd.is_free_metal = 'Y' or isd.is_pledge = 'Y' or isd.contract_type = 'BASEMETAL') then
          iscd.stock_ref_no
         else
          iscp.stock_ref_no
       end) stock_ref_no_lot_no,
       iscp.dry_quantity dry_qty,
       iscp.gmr_qty_unit dry_qty_unit,
       iscp.sub_lot_no || ' : ' || iscp.assay_content || ' ' ||
       iscp.assay_content_unit assay_details,
       iscp.net_payable net_payable_percentage,
       null net_payable_percentage_unit,
       (case
          when (isd.is_free_metal = 'Y' or isd.is_pledge = 'Y' or isd.contract_type = 'BASEMETAL') then
           (case
          when iscd.total_price_qty is null or iscd.total_price_qty = '' then
           0
          else
           to_number(iscd.total_price_qty)
        end) else(case
         when iscp.element_invoiced_qty is null or
              iscp.element_invoiced_qty = '' then
          0
         else
          to_number(iscp.element_invoiced_qty)
       end) end) payable_penalty_qty,
       (case
         when (isd.is_free_metal = 'Y' or isd.is_pledge = 'Y' or isd.contract_type = 'BASEMETAL') then
          iscd.invoiced_qty_unit
         else
          iscp.element_invoiced_qty_unit
       end) Payable_penalty_qty_unit,
       (case
          when (isd.is_free_metal = 'Y' or isd.is_pledge = 'Y' or isd.contract_type = 'BASEMETAL') then
           (case
          when iscd.price_as_per_defind_uom is null or
               iscd.price_as_per_defind_uom = '' then
           0
          else
           to_number(iscd.price_as_per_defind_uom)
        end) else(case
         when iscp.invoice_price is null or
              iscp.invoice_price = '' then
          0
         else
          to_number(iscp.invoice_price)end)
       end) price,
       (case
         when (isd.is_free_metal = 'Y' or isd.is_pledge = 'Y' or isd.contract_type = 'BASEMETAL') then
          iscd.invoiced_price_unit
         else
          iscp.element_price_unit
       end)  price_unit,
       (case
          when (isd.is_free_metal = 'Y' or isd.is_pledge = 'Y' or isd.contract_type = 'BASEMETAL') then
           (case
          when iscd.item_amount_in_inv_cur is null or iscd.item_amount_in_inv_cur = '' then
           0
          else
           to_number(iscd.item_amount_in_inv_cur)
        end) else(case
         when iscp.element_inv_amount is null or
              iscp.element_inv_amount = '' then
          0
         else
          to_number(iscp.element_inv_amount)
       end) end)total_amount,
       isd.invoice_amount_unit total_amount_unit,
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
       null provisional_API_Amount,
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
  from is_d                  isd,
       is_conc_payable_child iscp,
       ds_document_summary   ds,
       v_ak_corporate        akc,
       is_child_d            iscd
 where isd.internal_doc_ref_no = iscp.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
   and isd.internal_doc_ref_no = iscd.internal_doc_ref_no(+)
union all
select 'Invoice' section_name,
       'GMR' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
       isd.internal_comments comments,
       isd.invoice_creation_date invoice_issue_date,
       isd.due_date payment_due_date,
       isd.payment_term,
       isd.inco_term_location delivery_terms,
       -- Delivery Details
       igd.gmr_ref_no igd_gmr_ref_no,
       igd.container_name || (case when igd.mode_of_transport = '' then '' else  ', ' || igd.mode_of_transport end) igd_container_name,
       igd.bl_date igd_bl_date,
       igd.origin_city || ', ' ||igd.origin_country igd_origin,
       igd.wet_qty igd_wet_qty,
       igd.wet_qty_unit_name igd_wet_qty_unit_name,
       igd.moisture igd_moisture,
       igd.moisture_unit_name igd_moisture_unit_name,
       igd.dry_qty igd_dry_qty,
       igd.dry_qty_unit_name igd_dry_qty_unit_name,
       -- Payable Details
       null metal,
       null stock_ref_no_lot_no,
       null dry_qty,
       null dry_qty_unit,
       null assay_details,
       null net_payable_percentage,
       null net_payable_percentage_unit,
       null payable_penalty_qty,
       null Payable_penalty_qty_unit,
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
       vat.fx_rate_vc_ic fx_rate,
       vat.vat_amount_in_vat_cur amount_in_charge_tax_vat_ccy,
       null charge_tax_vat_ccy,
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
       null provisional_API_Amount,
       -- VAT Details
       nvl2(vat.internal_invoice_ref_no, vat.our_vat_no, svi.our_vat_no) our_vat_reg_no,
       nvl2(vat.internal_invoice_ref_no, vat.cp_vat_no, svi.cp_vat_no) cp_vat_reg_no,
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
       igd_inv_gmr_details_d   igd,
       ds_document_summary     ds,
       v_ak_corporate          akc,
       ivd_invoice_vat_details vat,
       separate_vat_info svi/*,
       cm_currency_master      vat_cm*/
 where isd.internal_doc_ref_no = igd.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
   and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
   and vat.is_separate_invoice(+) = 'N'
   and isd.internal_invoice_ref_no = svi.internal_invoice_ref_no(+)
union all
select 'Invoice' section_name,
       'Treatment Charge' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       ictc.element_name metal,
       ictc.stock_ref_no stock_ref_no_lot_no,
       ictc.dry_quantity dry_qty,
       ictc.quantity_unit_name dry_qty_unit,
       ictc.sub_lot_no assay_details,
       null net_payable_percentage,
       null net_payable_percentage_unit,
       null payable_penalty_qty,
       null Payable_penalty_qty_unit,
       null price,
       null price_unit,
       (case
         when ictc.tc_amount is null or ictc.tc_amount = '' then
          0
         else
          to_number(ictc.tc_amount)
       end) total_amount,
       isd.invoice_amount_unit total_amount_unit,
       -- TC Details
       ictc.wet_quantity wet_qty,
       ictc.quantity_unit_name wet_qty_unit,
       ictc.moisture,
       '%' moisture_unit,
       (case when nvl(ictc.baseescdesc_type,'NA') in ('Fixed','Assay','NA') then
            ''
         else 
            ictc.base_tc
         end) fixed_tc_amount,
       isd.invoice_amount_unit fixed_tc_amount_unit,
       (case when nvl(ictc.baseescdesc_type,'NA') in ('Fixed','Assay','NA') then
            ''
         else 
            ictc.esc_desc_amount
         end) escalator_descalator,
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
       null provisional_API_Amount,
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
       is_conc_tc_child    ictc,
       ds_document_summary ds,
       v_ak_corporate      akc
 where isd.internal_doc_ref_no = ictc.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
union all
select 'Invoice' section_name,
       'Refining Charge' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       icrc.element_name metal,
       icrc.stock_ref_no stock_ref_no_lot_no,
       icrc.dry_quantity dry_qty,
       icrc.quantity_unit_name dry_qty_unit,
       icrc.sub_lot_no || ' : ' || icrc.assay_details || ' ' ||
       icrc.assay_uom assay_details,
       null net_payable_percentage,
       null net_payable_percentage_unit,
       (case
         when icrc.payable_qty is null then
          0
         else
          to_number(icrc.payable_qty)
       end) payable_penalty_qty,
       icrc.payable_qty_unit Payable_penalty_qty_unit,
       null price,
       null price_unit,
       (case
         when icrc.rc_amount is null or icrc.rc_amount = '' then
          0
         else
          to_number(icrc.rc_amount)
       end) total_amount,
       isd.invoice_amount_unit total_amount_unit,
       -- TC Details
       icrc.payable_qty wet_qty,
       icrc.payable_qty_unit wet_qty_unit,
       null moisture,
       null moisture_unit,
       (case when nvl(icrc.baseescdesc_type,'NA') in ('Fixed','Assay','NA') then
            ''
         else 
            icrc.base_rc
         end) fixed_tc_amount,
       isd.invoice_amount_unit fixed_tc_amount_unit,
       (case when nvl(icrc.baseescdesc_type,'NA') in ('Fixed','Assay','NA') then
            ''
         else 
            icrc.rc_es_ds
         end) escalator_descalator,
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
       null provisional_API_Amount,
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
       is_conc_rc_child    icrc,
       ds_document_summary ds,
       v_ak_corporate      akc
 where isd.internal_doc_ref_no = icrc.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
union all
select 'Invoice' section_name,
       'Penalty' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       icpc.element_name metal,
       icpc.stock_ref_no stock_ref_no_lot_no,
       icpc.dry_quantity dry_qty,
       icpc.quantity_uom dry_qty_unit,
       icpc.assay_details || ' ' || icpc.uom,
       null net_payable_percentage,
       null net_payable_percentage_unit,
       (case
         when icpc.penalty_qty is null or icpc.penalty_qty = '' then
          0
         else
          to_number(icpc.penalty_qty)
       end) payable_penalty_qty,
       icpc.quantity_uom Payable_penalty_qty_unit,
       null price,
       null price_unit,
       (case
         when icpc.penalty_amount is null or icpc.penalty_amount = '' then
          0
         else
          to_number(icpc.penalty_amount)
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
       icpc.penalty_rate,
       icpc.price_name penalty_rate_unit,
       -- Charegs Details
       null cost_name,
       null charge_type,
       null amount_rate,
       null amount_rate_unit,
       null fx_rate,
       null amount_in_charge_tax_vat_ccy,
       null charge_tax_vat_ccy,
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
       null provisional_API_Amount,
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
  from is_d                  isd,
       is_conc_penalty_child icpc,
       ds_document_summary   ds,
       v_ak_corporate        akc
 where isd.internal_doc_ref_no = icpc.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
union all
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
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       ioc.quantity payable_penalty_qty,
       ioc.quantity_unit Payable_penalty_qty_unit,
       null price,
       null price_unit,
       ioc.invoice_amount total_amount,
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
       -- Tax Details
       null tax_code,
       null tax_rate,
       null applicable_on,
       -- Premium Details
       null premium,
       null premium_gmr_ref_no,
       -- API PI Details
       null invoice_ref_no,
       ioc.description invoice_description,
       null provisional_percentage,
       null provisional_API_Amount,
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
  from is_d isd, ioc_d ioc, ds_document_summary ds, v_ak_corporate akc
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
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       null Payable_penalty_qty_unit,
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
       null provisional_API_Amount,
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
  from is_d isd, itd_d itd, ds_document_summary ds, v_ak_corporate akc
 where isd.internal_doc_ref_no = itd.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
union all
select 'Invoice' section_name,
       'API PI' sub_section,
       ds.corporate_id,
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       null Payable_penalty_qty_unit,
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
       -- Tax Details
       null tax_code,
       null tax_rate,
       null applicable_on,
       -- Premium Details
       null premium,
       null premium_gmr_ref_no,
       -- API PI Details
       api_pi.invoice_ref_no,
       api_pi.invoice_description,
       api_pi.provisional_percentage,
       api_pi.invoice_amount provisional_API_Amount,
       -- VAT Details
       null our_vat_reg_no,
       null cp_vat_reg_no,
       null vat_code,
       null vat_rate,
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
  from is_d isd,
       (select api.internal_doc_ref_no,
               api.internal_invoice_ref_no,
               api.api_invoice_ref_no invoice_ref_no,
               'Advance Payment' invoice_description,
               'NA' provisional_percentage,
               (case
                 when api.api_amount_adjusted is null or
                      api.api_amount_adjusted = '' then
                  0
                 else
                  to_number(api.api_amount_adjusted)
               end) invoice_amount
          from api_details_d api
        union all
        select pi.internal_doc_ref_no,
               pi.internal_invoice_ref_no,
               pi.invoice_ref_no,
               pi.invoice_type_name invoice_description,
               (case
                 when pi.prov_pymt_percentage = '' or
                      pi.prov_pymt_percentage is null then
                  '100'
                 else
                  pi.prov_pymt_percentage
               end) provisional_percentage,
               (case
                 when pi.invoice_amount is null or pi.invoice_amount = '' then
                  0
                 else
                  to_number(pi.invoice_amount)
               end) invoice_amount
          from is_parent_child_d pi) api_pi,
       ivd_invoice_vat_details vat,
       ds_document_summary ds,
       v_ak_corporate akc
 where isd.internal_doc_ref_no = api_pi.internal_doc_ref_no(+)
   and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
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
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       null Payable_penalty_qty_unit,
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
       null provisional_API_Amount,
       -- VAT Details
       null our_vat_reg_no,
       null cp_vat_reg_no,
       null vat_code,
       null vat_rate,
       null vat_amount,
       -- Bank Details
       ibp.beneficiary_name beneficiary_name,
       ibp.bank_name bank_name,
       ibp.account_no account_no,
       ibp.iban iban,
       ibp.aba_rtn aba_rtn,
       ibp.instruction instruction,
       ibp.remarks remarks,
       -- Summary Details
       isd.total_premium_amount,
       isd.freight_charge,
       isd.adjustment_amount,
       isd.is_pledge pledge,
       isd.is_free_metal free_metal,
       isd.invoice_amount
  from is_d                isd,
       is_bdp_child_d      ibp,
       ds_document_summary ds,
       v_ak_corporate      akc
 where isd.internal_doc_ref_no = ibp.internal_doc_ref_no(+)
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
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       null Payable_penalty_qty_unit,
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
       null provisional_API_Amount,
       -- VAT Details
       null our_vat_reg_no,
       null cp_vat_reg_no,
       null vat_code,
       null vat_rate,
       null vat_amount,
       -- Bank Details
       ibp.beneficiary_name beneficiary_name,
       ibp.bank_name bank_name,
       ibp.account_no account_no,
       ibp.iban iban,
       ibp.aba_rtn aba_rtn,
       ibp.instruction instruction,
       ibp.remarks remarks,
       -- Summary Details
       isd.total_premium_amount,
       isd.freight_charge,
       isd.adjustment_amount,
       isd.is_pledge pledge,
       isd.is_free_metal free_metal,
       isd.invoice_amount
  from is_d                isd,
       is_bds_child_d      ibp,
       ds_document_summary ds,
       v_ak_corporate      akc
 where isd.internal_doc_ref_no = ibp.internal_doc_ref_no(+)
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
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       null Payable_penalty_qty_unit,
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
       null cost_name,
       null charge_type,
       null amount_rate,
       null amount_rate_unit,
       vat.fx_rate_vc_ic fx_rate,
       vat.vat_amount_in_vat_cur amount_in_charge_tax_vat_ccy,
       cm_vat.cur_code charge_tax_vat_ccy,
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
       null provisional_API_Amount,
       -- VAT Details
       vat.our_vat_no our_vat_reg_no,
       vat.cp_vat_no cp_vat_reg_no,
       vat.vat_code_name vat_code,
       vat.vat_rate,
       vat.vat_amount_in_inv_cur vat_amount,
       -- Bank Details
       null beneficiary_name,
       null bank_name,
       null account_no,
       null iban,
       null aba_rtn,
       vat.special_inst instruction,
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
       cm_currency_master cm_vat,
       cm_currency_master cm_inv
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
       akc.logo_path,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.phone_no,
       akc.fax_no, akc.visiting_address, akc.organisation_no, akc.foot_note,
       akc.address_name,
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
       replace(isd.cp_address || '^' || isd.cp_zip ||'^' || isd.cp_city || '^' || isd.cp_state || '^' ||isd.cp_country,'^',chr(10)) cp_address,
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
       null Payable_penalty_qty_unit,
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
       null provisional_API_Amount,
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
  from is_d                  isd,
       ds_document_summary   ds,
       v_ak_corporate        akc
 where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+) and ds.corporate_id = akc.corporate_id(+) 
