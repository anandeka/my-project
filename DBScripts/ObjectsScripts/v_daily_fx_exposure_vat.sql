create or replace view v_daily_fx_exposure_vat
as
---- for seprate vat invoice
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       '' sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date ,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.vat_parent_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pci.del_distribution_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       iis.payable_receivable,
       (decode(iis.payable_receivable, 'Payable', -1, 'Receivable', 1) *
       ivd.vat_amount_in_vat_cur ) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty) invoiced_qty
          from iid_invoicable_item_details iid
           where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       is_invoice_summary iis1,
       gmr_goods_movement_record gmr,
       pci_physical_contract_item pci,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iis.vat_parent_ref_no = iis1.invoice_ref_no
   and iis1.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and ivd.is_separate_invoice = 'Y'
   and pcm.purchase_sales = 'P'
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and iid.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and ivd.vat_remit_cur_id = cm_pay.cur_id
   and akc.base_cur_id = cm_base.cur_id   
   and nvl(ivd.vat_amount_in_vat_cur,0) <> 0
   and iis.is_active = 'Y'
   and iis1.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all 
 select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       '' sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date ,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.invoice_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pci.del_distribution_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       iis.payable_receivable,
       (decode(iis.payable_receivable, 'Payable', -1, 'Receivable', 1) *
     (case when PCM.PURCHASE_SALES = 'S' then ivd.vat_amount_in_inv_cur else nvl(IVD.VAT_AMOUNT_IN_VAT_CUR,ivd.vat_amount_in_inv_cur) end) ) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty) invoiced_qty
          from iid_invoicable_item_details iid
          where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       gmr_goods_movement_record gmr,
       pci_physical_contract_item pci,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and iid.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and (case when PCM.PURCHASE_SALES = 'S' then ivd.invoice_cur_id else nvl(IVD.VAT_REMIT_CUR_ID,ivd.invoice_cur_id) end ) = cm_pay.cur_id --for purchase exposure in vat cur and
                                                                                                                    --     for sales  eposure in invoice cur
   and akc.base_cur_id = cm_base.cur_id                                                                                
   and iis.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all ---for sales contract when invoice cur and vat cur are not same   outflow 
  select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       '' sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date ,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.invoice_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pci.del_distribution_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       'Payable' payable_receivable,
       (decode(iis.payable_receivable, 'Payable', 1, 'Receivable', -1) *  ---for make outflow sales amount 
      ivd.vat_amount_in_vat_cur ) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty)
          from iid_invoicable_item_details iid
          where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       gmr_goods_movement_record gmr,
       pci_physical_contract_item pci,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and iid.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and ivd.vat_remit_cur_id <> ivd.invoice_cur_id --for invoice exposure of sales 
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and ivd.vat_remit_cur_id =  cm_pay.cur_id 
   and pcm.purchase_sales = 'S'
   and akc.base_cur_id = cm_base.cur_id
   and iis.is_active = 'Y'
   and gmr.is_deleted = 'N'
/