drop materialized view MV_CASH_FLOW_REPORT
/
create materialized view MV_CASH_FLOW_REPORT
refresh force on demand
start with to_date('11-08-2011 14:48:54', 'dd-mm-yyyy hh24:mi:ss') next SYSDATE+1/1440 
as
select iss.corporate_id,
       akc.groupid,
       cpc.profit_center_id,
       cpc.profit_center_name,
       cpc.business_line_id,
       pci.strategy_id strategy_id,
       pci.strategy_name,
       nvl(pcm.partnership_type, 'Normal') execution_type,
       pci.product_id,
       pci.product_name,
       pdm.product_type_id,
       (case
         when nvl(pci.contract_type, 'NA') = 'P' then
          'Purchase'
         when nvl(pci.contract_type, 'NA') = 'S' then
          'Sales'
         else
          'NA'
       end) contract_type,
       iss.internal_invoice_ref_no,
       iss.internal_contract_ref_no,
       iss.invoice_ref_no,
       (case
         when iss.invoice_type_name = 'AdvancePayment' then
          'Commercial'
         else
          iss.invoice_type
       end) invoice_type,
       iss.invoice_type_name,
       phd.profileid cp_id,
       phd.companyname cp_name,
       pad.city_id,
       cim.city_name,
       pad.country_id,
       cym.country_name,
       round(iss.total_invoice_item_amount, 4) *
       (case
          when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
           1
          when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
           -1
          else
           (case
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
           -1
          else
           1
        end) end) invoice_amount,
       (case
         when iss.payment_due_date is not null then
          to_char(iss.payment_due_date, 'dd/mm/yyyy')
         else
          ''
       end) payment_due_date,
       (case
         when iss.invoice_issue_date is not null then
          to_char(iss.invoice_issue_date, 'dd/mm/yyyy')
         else
          ''
       end) invoice_issue_date,
       iss.cp_ref_no,
       iss.credit_term,
       round(iss.total_amount_to_pay, 4) *
       (case
          when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
           1
          when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
           -1
          else
           (case
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
           -1
          else
           1
        end) end) invoice_amount_in_payin_cur,
       iss.invoice_cur_id invoice_pay_in_cur_id,
       iss.fx_to_base,
       round(iss.total_amount_to_pay, 4) * nvl(iss.fx_to_base, 1) *
       (case
          when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
           1
          when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
           -1
          else
           (case
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
           -1
          else
           1
        end) end) invoice_amount_in_base_cur,
       akc.base_cur_id,
       (case
         when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          'Inflow'
         when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          'Outflow'
         else
          (case
         when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
          'Outflow'
         when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' then
          'Inflow'
         else
          ''
       end) end) payable_receivable,
       cm_p.cur_code pay_in_cur_code
  from is_invoice_summary            iss,
       cm_currency_master            cm_p,
       incm_invoice_contract_mapping incm,
       pcm_physical_contract_main    pcm,
       phd_profileheaderdetails      phd,
       ak_corporate                  akc,
       cpc_corporate_profit_center   cpc,
       v_pci                         pci,
       pdm_productmaster             pdm,
       pad_profile_addresses         pad,
       bpat_bp_address_type          bpat,
       cim_citymaster                cim,
       cym_countrymaster             cym
 where iss.is_active = 'Y'
   and iss.corporate_id is not null
   and iss.cp_id = phd.profileid
   and iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
   and incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and iss.corporate_id = akc.corporate_id
   and iss.profit_center_id = cpc.profit_center_id(+)
   and iss.internal_contract_ref_no = pci.internal_contract_item_ref_no(+)
   and pci.product_id = pdm.product_id(+)
   and iss.cp_id = pad.profile_id
   and pad.address_type = bpat.bp_address_type_id
   and bpat.bp_address_type = 'Main Address'
   and pad.city_id = cim.city_id(+)
   and pad.country_id = cym.country_id(+)
   and iss.invoice_cur_id = cm_p.cur_id(+)
   and 'TRUE' =
       (case when iss.invoice_type_name = 'AdvancePayment' then 'TRUE'
        else(case when nvl(iss.invoice_type, 'NA') = 'Commercial' then
             'TRUE' when nvl(iss.invoice_type, 'NA') = 'Service' then 'TRUE' else
             'FALSE' end) end)
/
