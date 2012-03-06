CREATE OR REPLACE VIEW V_CASH_FLOW_REPORT AS
--used in Online Aging Report
select iss.corporate_id,
       akc.groupid,
       NVL(cpc.profit_center_id, 'NA') profit_center_id,
       NVL(cpc.profit_center_name, 'NA') profit_center_name,
       NVL(cpc.business_line_id, 'NA') business_line_id,
       NVL(pcm.partnership_type, 'Normal') execution_type,
       (CASE
         WHEN NVL(pcm.purchase_sales, 'NA') = 'P' THEN
          'Purchase'
         WHEN NVL(pcm.purchase_sales, 'NA') = 'S' THEN
          'Sales'
         ELSE
          'NA'
       END) contract_type,
       iss.internal_invoice_ref_no,
       iss.internal_contract_ref_no,
       iss.invoice_ref_no,
       (CASE
         WHEN iss.invoice_type_name = 'AdvancePayment' THEN
          'Commercial'
         ELSE
          iss.invoice_type
       END) invoice_type,
       iss.invoice_type_name,
       phd.profileid cp_id,
       phd.companyname cp_name,
       pad.city_id,
       cim.city_name,
       pad.country_id,
       cym.country_name,
       ROUND(iss.total_invoice_item_amount, 4) *
       (CASE
          WHEN NVL(iss.recieved_raised_type, 'NA') = 'Raised' THEN
           1
          WHEN NVL(iss.recieved_raised_type, 'NA') = 'Received' THEN
           -1
          ELSE
           (CASE
          WHEN NVL(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' THEN
           -1
          WHEN NVL(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' THEN
           1
          ELSE
           (CASE
          WHEN NVL(pcm.purchase_sales, 'NA') = 'P' THEN
           -1
          WHEN NVL(pcm.purchase_sales, 'NA') = 'S' THEN
           1
        END) END) END) invoice_amount,
       (CASE
         WHEN iss.payment_due_date IS NOT NULL THEN
          TO_CHAR(iss.payment_due_date, 'dd/mm/yyyy')
         ELSE
          ''
       END) payment_due_date,
       (CASE
         WHEN iss.invoice_issue_date IS NOT NULL THEN
          TO_CHAR(iss.invoice_issue_date, 'dd/mm/yyyy')
         ELSE
          ''
       END) invoice_issue_date,
       iss.cp_ref_no,
       pym.payment_term credit_term,
       ROUND(iss.total_amount_to_pay, 4) *
       (CASE
          WHEN NVL(iss.recieved_raised_type, 'NA') = 'Raised' THEN
           1
          WHEN NVL(iss.recieved_raised_type, 'NA') = 'Received' THEN
           -1
          ELSE
           (CASE
          WHEN NVL(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' THEN
           -1
          ELSE
           1
        END) END) invoice_amount_in_payin_cur,
       iss.invoice_cur_id invoice_pay_in_cur_id,
       (CASE
         WHEN NVL(iss.invoice_cur_id, 'NA') = akc.base_cur_id THEN
          1
         ELSE
          NVL(iss.fx_to_base, 1)
       END) fx_to_base,
       ROUND(iss.total_amount_to_pay, 4) *
       (CASE
          WHEN NVL(iss.invoice_cur_id, 'NA') = akc.base_cur_id THEN
           1
          ELSE
           NVL(iss.fx_to_base, 1)
        END) * (case
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
               end) end) else 1 end) invoice_amount_in_base_cur,
       akc.base_cur_id,
        (case
         when nvl(iss.payable_receivable, 'NA') = 'Payable' then
          'Outflow'
         when nvl(iss.payable_receivable, 'NA') = 'Receivable' then
          'Inflow'
         when nvl(iss.payable_receivable, 'NA') = 'NA' then
          (case
         when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
          'Outflow'
         when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' then
          'Inflow'
         else
          (case
         when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          'Inflow'
         when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          'Outflow'
         else
          'Inflow'
       end) end) else 'Inflow' end) payable_receivable,
       cm_p.cur_code pay_in_cur_code
  FROM is_invoice_summary iss,
       cm_currency_master cm_p,
       incm_invoice_contract_mapping incm,
       pcm_physical_contract_main pcm,
       phd_profileheaderdetails phd,
       ak_corporate akc,
       cpc_corporate_profit_center cpc,
       (SELECT pad.address_id,
               pad.address_type,
               pad.profile_id,
               pad.city_id,
               pad.country_id,
               pad.address_name
          FROM pad_profile_addresses pad, bpat_bp_address_type bb
         WHERE bb.bp_address_type = 'Main Address'
           AND bb.is_active = 'Y'
           AND bb.is_deleted = 'N'
           AND pad.address_type = bb.bp_address_type_id
           AND pad.is_deleted = 'N') pad,
       cim_citymaster cim,
       cym_countrymaster cym,
       pym_payment_terms_master pym
 WHERE iss.corporate_id IS NOT NULL
   AND iss.cp_id = phd.profileid
   AND iss.is_inv_draft = 'N'
   AND iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
   AND incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   AND iss.corporate_id = akc.corporate_id
   AND iss.profit_center_id = cpc.profit_center_id(+)
   AND iss.cp_id = pad.profile_id(+)
   AND iss.credit_term = pym.payment_term_id(+)
   AND pad.city_id = cim.city_id(+)
   AND pad.country_id = cym.country_id(+)
   AND iss.invoice_cur_id = cm_p.cur_id(+)
   AND NVL(pcm.partnership_type, 'Normal') = 'Normal'
   AND 'TRUE' =
       (CASE WHEN iss.invoice_type_name = 'AdvancePayment' THEN 'TRUE' WHEN
        iss.invoice_type_name = 'Profoma' THEN 'FALSE'
        ELSE(CASE WHEN NVL(iss.invoice_type, 'NA') = 'Commercial' THEN
             'TRUE' WHEN NVL(iss.invoice_type, 'NA') = 'Service' THEN 'TRUE' when
             nvl(iss.invoice_type, 'NA') = 'DebitCredit' then 'TRUE' ELSE
             'FALSE' END) END) 
