CREATE OR REPLACE VIEW v_bi_der_physical_booking AS
select iss.corporate_id,
       akc.corporate_name,
       pdm.product_id,
       pdm.product_desc,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       iss.invoiced_qty invoice_quantity,
       qum.qty_unit invoice_quantity_uom,
       nvl(iss.fx_to_base, 1) fx_base,
       nvl(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
       nvl(cpc.profit_center_short_name, cpc1.profit_center_short_name) profit_center,
       akc.base_cur_id,
       cm_akc_base_cur.cur_code base_currency,
       nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
       nvl(pcm.contract_ref_no, 'NA') contract_ref_no,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code pay_in_currency,
       round(iss.total_amount_to_pay, 4) * nvl(iss.fx_to_base, 1) *
       (case
          when nvl(iss.payable_receivable, 'NA') = 'Payable' then
           -1
          when nvl(iss.payable_receivable, 'NA') = 'Receivable' then
           1
          when nvl(iss.payable_receivable, 'NA') = 'NA' then
           (case
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
           -1
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' then
           1
          else
           (case
          when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
           1
          when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
           -1
          else
           1
        end) end) else 1 end) amount_in_base_cur,
       round(iss.total_amount_to_pay, 4) * case
         when (iss.invoice_type = 'Commercial' or
              iss.invoice_type = 'DebitCredit') then
          1
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          -1
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          1
         when nvl(iss.invoice_type_name, 'NA') = 'AdvancePayment' and
              pcm.purchase_sales = 'P' then
          -1
         when nvl(iss.invoice_type_name, 'NA') = 'AdvancePayment' and
              pcm.purchase_sales = 'S' then
          1
       end invoice_amt,
       iss.invoice_issue_date invoice_date,
       iss.payment_due_date invoice_due_date,
       iss.invoice_type_name invoice_type,
       'NA' bill_to_cp_country,
       pcdi.pcdi_id delivery_item_ref_no,
       ivd.vat_amount_in_vat_cur vat_amount,
       ivd.vat_remit_cur_id,
       cm_vat.cur_code vat_remit_currency,
       (nvl(ivd.fx_rate_vc_ic, 1) * nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
       (ivd.vat_amount_in_vat_cur * nvl(ivd.fx_rate_vc_ic, 1) *
       nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
       null commission_value,
       null commission_value_ccy,
       null attribute1,
       null attribute2,
       null attribute3,
       null attribute4,
       null attribute5
  from is_invoice_summary            iss,
       cm_currency_master            cm_p,
       incm_invoice_contract_mapping incm,
       ivd_invoice_vat_details       ivd,
       pcm_physical_contract_main    pcm,
       pcdi_pc_delivery_item         pcdi,
       ak_corporate                  akc,
       cpc_corporate_profit_center   cpc,
       cpc_corporate_profit_center   cpc1,
       pcpd_pc_product_definition    pcpd,
       cm_currency_master            cm_akc_base_cur,
       cm_currency_master            cm_vat,
       pdm_productmaster             pdm,
       phd_profileheaderdetails      phd_contract_cp,
       qum_quantity_unit_master      qum
 where iss.is_active = 'Y'
   and iss.corporate_id is not null
   and iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
   and iss.internal_invoice_ref_no = ivd.internal_invoice_ref_no(+)
   and incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and iss.corporate_id = akc.corporate_id
   and iss.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and iss.profit_center_id = cpc.profit_center_id(+)
   and pcpd.profit_center_id = cpc1.profit_center_id(+)
   and iss.invoice_cur_id = cm_p.cur_id(+)
   and pcpd.product_id = pdm.product_id(+)
   and phd_contract_cp.profileid(+) = iss.cp_id
   and nvl(pcm.partnership_type, 'Normal') = 'Normal'
   and qum.qty_unit_id = pcdi.qty_unit_id
   and iss.is_inv_draft = 'N'
   and iss.invoice_type_name <> 'Profoma'
   and cm_akc_base_cur.cur_id = akc.base_cur_id
   and cm_vat.cur_id(+) = ivd.vat_remit_cur_id
   and pcpd.input_output = 'Input'
   and nvl(iss.total_amount_to_pay, 0) <> 0
---2 Service invoices
union all
select iss.corporate_id,
       ak.corporate_name,
       nvl(pdm.product_id, 'NA'),
       nvl(pdm.product_desc, 'NA'),
       iss.cp_id counter_party_id,
       phd_cp.companyname counter_party_name,
       iss.invoiced_qty invoice_quantity,
       nvl(qum.qty_unit, 'MT') invoice_quantity_uom,
       nvl(iss.fx_to_base, 1) fx_base,
       coalesce(cpc.profit_center_id, cpc1.profit_center_id, 'NA') profit_center_id,
       coalesce(cpc.profit_center_short_name,
                cpc1.profit_center_short_name,
                'NA') profit_center,
       ak.base_cur_id,
       cm_akc_base_cur.cur_code base_currency,
       nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
       nvl(pcm.contract_ref_no, 'NA') contract_ref_no,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code pay_in_currency,
       round(iss.total_amount_to_pay, 4) * nvl(iss.fx_to_base, 1) *
       (case
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
           -1
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' then
           1
          else
           (case
          when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
           1
          when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
           -1
          else
           1
        end) end) amount_in_base_cur,
       round(iss.total_amount_to_pay, 4) * case
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          -1
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          1
       end invoice_amt,
       iss.invoice_issue_date invoice_date,
       iss.payment_due_date invoice_due_date,
       nvl(iss.invoice_type_name, 'NA') invoice_type,
       'NA' bill_to_cp_country,
       nvl(pcdi.pcdi_id, 'NA') delivery_item_ref_no,
       ivd.vat_amount_in_vat_cur vat_amount,
       nvl(ivd.vat_remit_cur_id, 'NA'),
       nvl(cm_vat.cur_code, 'NA') vat_remit_currency,
       (nvl(ivd.fx_rate_vc_ic, 1) * nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
       (ivd.vat_amount_in_vat_cur * nvl(ivd.fx_rate_vc_ic, 1) *
       nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
       null commission_value,
       null commission_value_ccy,
       null attribute1,
       null attribute2,
       null attribute3,
       null attribute4,
       null attribute5
  from is_invoice_summary          iss,
       iam_invoice_action_mapping  iam,
       iid_invoicable_item_details iid,
       axs_action_summary          axs,
       cs_cost_store               cs,
       ivd_invoice_vat_details     ivd,
       cigc_contract_item_gmr_cost cigc,
       gmr_goods_movement_record   gmr,
       pcpd_pc_product_definition  pcpd,
       pcm_physical_contract_main  pcm,
       pcdi_pc_delivery_item       pcdi,
       ak_corporate                ak,
       ak_corporate_user           akcu,
       cpc_corporate_profit_center cpc,
       cpc_corporate_profit_center cpc1,
       phd_profileheaderdetails    phd_cp,
       cm_currency_master          cm_akc_base_cur,
       cm_currency_master          cm_vat,
       cm_currency_master          cm_p,
       pdm_productmaster           pdm,
       qum_quantity_unit_master    qum
 where iss.internal_contract_ref_no is null
   and iss.is_active = 'Y'
   and iss.internal_invoice_ref_no = iam.internal_invoice_ref_no
   and iss.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
   and iss.internal_invoice_ref_no = ivd.internal_invoice_ref_no(+)
   and iam.invoice_action_ref_no = axs.internal_action_ref_no
   and iam.invoice_action_ref_no = cs.internal_action_ref_no(+)
   and cs.cog_ref_no = cigc.cog_ref_no(+)
   and cigc.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
   and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no(+)
   and qum.qty_unit_id(+) = pcdi.qty_unit_id
   and pcm.trader_id = akcu.user_id(+)
   and pcpd.input_output(+) = 'Input'
   and iss.corporate_id = ak.corporate_id
   and iss.profit_center_id = cpc.profit_center_id(+)
   and pcpd.profit_center_id = cpc1.profit_center_id(+)
   and iss.cp_id = phd_cp.profileid
   and cm_akc_base_cur.cur_id = ak.base_cur_id
   and iss.invoice_cur_id = cm_p.cur_id(+)
   and pcpd.product_id = pdm.product_id(+)
   and cm_vat.cur_id(+) = ivd.vat_remit_cur_id
 group by pdm.product_id,
          pdm.product_desc,
          iss.corporate_id,
          iss.cp_id,
          iss.invoiced_qty,
          iss.fx_to_base,
          pcm.contract_ref_no,
          pcdi.pcdi_id,
          iss.invoice_type,
          iss.invoice_ref_no,
          iss.total_amount_to_pay,
          iss.recieved_raised_type,
          iss.invoice_cur_id,
          iss.invoice_issue_date,
          iss.payment_due_date,
          iss.invoice_type_name,
          ak.corporate_name,
          ak.base_cur_id,
          phd_cp.companyname,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          cpc1.profit_center_id,
          cpc1.profit_center_short_name,
          cm_akc_base_cur.cur_code,
          cm_p.cur_code,
          pcm.purchase_sales,
          qum.qty_unit,
          ivd.vat_amount_in_vat_cur,
          ivd.vat_remit_cur_id,
          cm_vat.cur_code,
          ivd.fx_rate_vc_ic;
