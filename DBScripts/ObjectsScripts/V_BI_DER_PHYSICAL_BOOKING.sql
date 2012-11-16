CREATE OR REPLACE VIEW v_bi_der_physical_booking AS
with temp_ii as (select iid.internal_invoice_ref_no,
       f_string_aggregate(ii.delivery_item_ref_no) delivery_item_ref_no
  from iid_invoicable_item_details iid,
       ii_invoicable_item          ii,
       is_invoice_summary          iss
 where ii.invoicable_item_id = iid.invoicable_item_id
   and iss.internal_invoice_ref_no = iid.internal_invoice_ref_no 
 group by iid.internal_invoice_ref_no),
 temp_gab as(select iss.internal_invoice_ref_no,
       axs.created_by created_user_id,
       gab.firstname || '  ' || gab.lastname created_user_name
  from is_invoice_summary         iss,
       iam_invoice_action_mapping iam,
       axs_action_summary         axs,
       ak_corporate_user          ak,
       gab_globaladdressbook      gab
 where iss.internal_invoice_ref_no = iam.internal_invoice_ref_no
   and iam.invoice_action_ref_no = axs.internal_action_ref_no
   and axs.created_by = ak.user_id
   and ak.gabid = gab.gabid)
select iss.corporate_id,
       akc.corporate_name,
       pdm.product_id,
       pdm.product_desc,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       (case
         when pcm.purchase_sales = 'P' then
          iss.invoiced_qty
         else
          (-1) * iss.invoiced_qty
       end) invoice_quantity,
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
       round(iss.total_amount_to_pay, 4) *
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
        end) end) else 1 end) invoice_amt,
       iss.invoice_issue_date invoice_date,
       iss.payment_due_date invoice_due_date,
       iss.invoice_type_name invoice_type,
       'NA' bill_to_cp_country,
       ii.delivery_item_ref_no delivery_item_ref_no,
       ivd.vat_amount_in_vat_cur vat_amount,
       ivd.vat_remit_cur_id,
       cm_vat.cur_code vat_remit_currency,
       (nvl(ivd.fx_rate_vc_ic, 1) * nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
       (ivd.vat_amount_in_vat_cur * nvl(ivd.fx_rate_vc_ic, 1) *nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
       null commission_value,
       null commission_value_ccy,
       null attribute1,
       null attribute2,
       null attribute3,
       null attribute4,
       null attribute5,
       gab.created_user_id,
       gab.created_user_name,
       iss.cancel_invoice_ref_no
  from is_invoice_summary iss,
       cm_currency_master cm_p,
       temp_ii             ii,
       temp_gab            gab,
       incm_invoice_contract_mapping incm,
       ivd_invoice_vat_details ivd,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       cpc_corporate_profit_center cpc,
       cpc_corporate_profit_center cpc1,
       pcpd_pc_product_definition pcpd,
       cm_currency_master cm_akc_base_cur,
       cm_currency_master cm_vat,
       pdm_productmaster pdm,
       phd_profileheaderdetails phd_contract_cp,
       qum_quantity_unit_master qum
 where iss.corporate_id is not null
   and iss.internal_invoice_ref_no = ii.internal_invoice_ref_no(+)
   and iss.internal_invoice_ref_no = gab.internal_invoice_ref_no(+)
   and iss.internal_invoice_ref_no = ivd.internal_invoice_ref_no(+)
   and iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
   and incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and iss.corporate_id = akc.corporate_id
   and iss.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and iss.profit_center_id = cpc.profit_center_id(+)
   and pcpd.profit_center_id = cpc1.profit_center_id(+)
   and iss.invoice_cur_id = cm_p.cur_id(+)
   and pcpd.product_id = pdm.product_id(+)
   and phd_contract_cp.profileid(+) = iss.cp_id
   and nvl(pcm.partnership_type, 'Normal') = 'Normal'
   and iss.invoiced_qty_unit_id = qum.qty_unit_id(+)
   and iss.is_inv_draft = 'N'
   and iss.invoice_type_name <> 'Profoma'
   and cm_akc_base_cur.cur_id = akc.base_cur_id
   and cm_vat.cur_id(+) = ivd.vat_remit_cur_id
   and pcpd.input_output = 'Input'
   and nvl(iss.total_amount_to_pay, 0) <> 0
---2 Service invoices
union all
select iss.corporate_id,
       akc.corporate_name,
       'NA' product_id,
       'NA' product_desc,
       iss.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       iss.invoiced_qty invoice_quantity,
       qum.qty_unit invoice_quantity_uom,
       nvl(iss.fx_to_base, 1) fx_base,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center,
       akc.base_cur_id,
       cm_akc_base_cur.cur_code base_currency,
       nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
       'NA' contract_ref_no,
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
       round(iss.total_amount_to_pay, 4) *
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
        end) end) else 1 end) invoice_amt,
       iss.invoice_issue_date invoice_date,
       iss.payment_due_date invoice_due_date,
       iss.invoice_type_name invoice_type,
       'NA' bill_to_cp_country,
       ii.delivery_item_ref_no delivery_item_ref_no,
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
       null attribute5,
       gab.created_user_id,
       gab.created_user_name,
       iss.cancel_invoice_ref_no
  from is_invoice_summary          iss,
       cm_currency_master          cm_p,
       temp_ii                     ii,
       temp_gab                    gab,
       ivd_invoice_vat_details     ivd,
       ak_corporate                akc,
       cpc_corporate_profit_center cpc,
       cm_currency_master          cm_akc_base_cur,
       cm_currency_master          cm_vat,
       phd_profileheaderdetails    phd_contract_cp,
       qum_quantity_unit_master    qum
 where iss.corporate_id is not null
   and iss.internal_invoice_ref_no = ii.internal_invoice_ref_no(+)
   and iss.internal_invoice_ref_no = gab.internal_invoice_ref_no(+)
   and iss.internal_invoice_ref_no = ivd.internal_invoice_ref_no(+)
   and iss.corporate_id = akc.corporate_id
   and iss.profit_center_id = cpc.profit_center_id(+)
   and iss.invoice_cur_id = cm_p.cur_id(+)
   and phd_contract_cp.profileid(+) = iss.cp_id
   and iss.invoiced_qty_unit_id = qum.qty_unit_id(+)
   and iss.is_inv_draft = 'N'
   and cm_akc_base_cur.cur_id = akc.base_cur_id
   and cm_vat.cur_id(+) = ivd.vat_remit_cur_id
   and nvl(iss.total_amount_to_pay, 0) <> 0
   and iss.internal_contract_ref_no is null