CREATE OR REPLACE VIEW V_BI_DER_PHYSICAL_BOOKING AS
SELECT iss.corporate_id,
       akc.corporate_name,
       pdm.product_id,
       pdm.product_desc,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       iss.invoiced_qty invoice_quantity,
       qum.qty_unit invoice_quantity_uom,
       NVL(iss.fx_to_base, 1) fx_base,
       NVL(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
       NVL(cpc.profit_center_short_name, cpc1.profit_center_short_name) profit_center,
       akc.base_cur_id,
       cm_akc_base_cur.cur_code base_currency,
       NVL(iss.invoice_ref_no, 'NA') AS invoice_ref_no,
       NVL(pcm.contract_ref_no, 'NA') contract_ref_no,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code pay_in_currency,
       ROUND(iss.total_amount_to_pay, 4) * NVL(iss.fx_to_base, 1) *
       (CASE
          WHEN NVL(iss.payable_receivable, 'NA') = 'Payable' THEN
           -1
          WHEN NVL(iss.payable_receivable, 'NA') = 'Receivable' THEN
           1
          WHEN NVL(iss.payable_receivable, 'NA') = 'NA' THEN
           (CASE
          WHEN NVL(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' THEN
           -1
          WHEN NVL(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' THEN
           1
          ELSE
           (CASE
          WHEN NVL(iss.recieved_raised_type, 'NA') = 'Raised' THEN
           1
          WHEN NVL(iss.recieved_raised_type, 'NA') = 'Received' THEN
           -1
          ELSE
           1
        END) END) ELSE 1 END) amount_in_base_cur,
       ROUND(iss.total_amount_to_pay, 4) * CASE
         WHEN (iss.invoice_type = 'Commercial' OR
              iss.invoice_type = 'DebitCredit') THEN
          1
         WHEN NVL(iss.invoice_type, 'NA') = 'Service' AND
              NVL(iss.recieved_raised_type, 'NA') = 'Received' THEN
          -1
         WHEN NVL(iss.invoice_type, 'NA') = 'Service' AND
              NVL(iss.recieved_raised_type, 'NA') = 'Raised' THEN
          1
         WHEN NVL(iss.invoice_type_name, 'NA') = 'AdvancePayment' AND
              pcm.purchase_sales = 'P' THEN
          -1
         WHEN NVL(iss.invoice_type_name, 'NA') = 'AdvancePayment' AND
              pcm.purchase_sales = 'S' THEN
          1
       END invoice_amt,
       iss.invoice_issue_date invoice_date,
       iss.payment_due_date invoice_due_date,
       iss.invoice_type_name invoice_type,
       cp_country.country_name bill_to_cp_country,
       pcdi.pcdi_id delivery_item_ref_no,
       ivd.vat_amount_in_vat_cur vat_amount,
       ivd.vat_remit_cur_id,
       cm_vat.cur_code vat_remit_currency,
       (NVL(ivd.fx_rate_vc_ic, 1) * NVL(iss.fx_to_base, 1)) fx_rate_for_vat,
       (ivd.vat_amount_in_vat_cur * NVL(ivd.fx_rate_vc_ic, 1) *
       NVL(iss.fx_to_base, 1)) vat_amount_base_currency,
       null commission_value,
       null commission_value_ccy,
       null attribute1,
       null attribute2,
       null attribute3,
       null attribute4,
       null attribute5
  FROM is_invoice_summary            iss,
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
       qum_quantity_unit_master      qum,
       pad_profile_addresses         pad,
       cym_countrymaster             cp_country
 WHERE iss.is_active = 'Y'
   AND iss.corporate_id IS NOT NULL
   AND iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
   AND iss.internal_invoice_ref_no = ivd.internal_invoice_ref_no(+)
   AND incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND iss.corporate_id = akc.corporate_id
   AND iss.internal_contract_ref_no = pcpd.internal_contract_ref_no
   AND iss.profit_center_id = cpc.profit_center_id(+)
   AND pcpd.profit_center_id = cpc1.profit_center_id(+)
   AND iss.invoice_cur_id = cm_p.cur_id(+)
   AND pcpd.product_id = pdm.product_id(+)
   AND phd_contract_cp.profileid(+) = pcm.cp_id
   AND NVL(pcm.partnership_type, 'Normal') = 'Normal'
   AND qum.qty_unit_id = pcdi.qty_unit_id
   AND iss.is_inv_draft = 'N'
   AND iss.invoice_type_name <> 'Profoma'
   AND cm_akc_base_cur.cur_id = akc.base_cur_id
   AND cm_vat.cur_id = ivd.vat_remit_cur_id
   AND pcpd.input_output = 'Input'
   AND pad.profile_id = phd_contract_cp.profileid
   AND pad.address_type = 'Billing'
   AND cp_country.country_id = pad.country_id
   AND pad.is_deleted = 'N'
   AND NVL(iss.total_amount_to_pay, 0) <> 0
---2 Service invoices
UNION ALL
SELECT iss.corporate_id,
       ak.corporate_name,
       nvl(pdm.product_id, 'NA'),
       nvl(pdm.product_desc, 'NA'),
       iss.cp_id counter_party_id,
       phd_cp.companyname counter_party_name,
       iss.invoiced_qty invoice_quantity,
       NVL(qum.qty_unit, 'MT') invoice_quantity_uom,
       NVL(iss.fx_to_base, 1) fx_base,
       coalesce(cpc.profit_center_id, cpc1.profit_center_id, 'NA') profit_center_id,
       coalesce(cpc.profit_center_short_name,
                cpc1.profit_center_short_name,
                'NA') profit_center,
       ak.base_cur_id,
       cm_akc_base_cur.cur_code base_currency,
       NVL(iss.invoice_ref_no, 'NA') AS invoice_ref_no,
       NVL(pcm.contract_ref_no, 'NA') contract_ref_no,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code pay_in_currency,
       ROUND(iss.total_amount_to_pay, 4) * NVL(iss.fx_to_base, 1) *
       (CASE
          WHEN NVL(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' THEN
           -1
          WHEN NVL(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' THEN
           1
          ELSE
           (CASE
          WHEN NVL(iss.recieved_raised_type, 'NA') = 'Raised' THEN
           1
          WHEN NVL(iss.recieved_raised_type, 'NA') = 'Received' THEN
           -1
          ELSE
           1
        END) END) amount_in_base_cur,
       ROUND(iss.total_amount_to_pay, 4) * CASE
         WHEN NVL(iss.invoice_type, 'NA') = 'Service' AND
              NVL(iss.recieved_raised_type, 'NA') = 'Received' THEN
          -1
         WHEN NVL(iss.invoice_type, 'NA') = 'Service' AND
              NVL(iss.recieved_raised_type, 'NA') = 'Raised' THEN
          1
       END invoice_amt,
       iss.invoice_issue_date invoice_date,
       iss.payment_due_date invoice_due_date,
       NVL(iss.invoice_type_name, 'NA') invoice_type,
       cp_country.country_name bill_to_cp_country,
       nvl(pcdi.pcdi_id, 'NA') delivery_item_ref_no,
       ivd.vat_amount_in_vat_cur vat_amount,
       nvl(ivd.vat_remit_cur_id, 'NA'),
       nvl(cm_vat.cur_code, 'NA') vat_remit_currency,
       (NVL(ivd.fx_rate_vc_ic, 1) * NVL(iss.fx_to_base, 1)) fx_rate_for_vat,
       (ivd.vat_amount_in_vat_cur * NVL(ivd.fx_rate_vc_ic, 1) *
       NVL(iss.fx_to_base, 1)) vat_amount_base_currency,
       null commission_value,
       null commission_value_ccy,
       null attribute1,
       null attribute2,
       null attribute3,
       null attribute4,
       null attribute5
  FROM is_invoice_summary          iss,
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
       qum_quantity_unit_master    qum,
       pad_profile_addresses       pad,
       cym_countrymaster           cp_country
 WHERE iss.internal_contract_ref_no IS NULL
   AND iss.is_active = 'Y'
   AND iss.internal_invoice_ref_no = iam.internal_invoice_ref_no
   AND iss.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
   AND iss.internal_invoice_ref_no = ivd.internal_invoice_ref_no(+)
   AND iam.invoice_action_ref_no = axs.internal_action_ref_no
   AND iam.invoice_action_ref_no = cs.internal_action_ref_no(+)
   AND cs.cog_ref_no = cigc.cog_ref_no(+)
   AND cigc.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
   AND gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   AND pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no(+)
   AND qum.qty_unit_id(+) = pcdi.qty_unit_id
   AND pcm.trader_id = akcu.user_id(+)
   AND pcpd.input_output(+) = 'Input'
   AND iss.corporate_id = ak.corporate_id
   AND iss.profit_center_id = cpc.profit_center_id(+)
   AND pcpd.profit_center_id = cpc1.profit_center_id(+)
   AND iss.cp_id = phd_cp.profileid
   AND cm_akc_base_cur.cur_id = ak.base_cur_id
   AND iss.invoice_cur_id = cm_p.cur_id(+)
   AND pcpd.product_id = pdm.product_id(+)
   AND cm_vat.cur_id(+) = ivd.vat_remit_cur_id
   AND pad.profile_id = phd_cp.profileid
   AND pad.address_type = 'Billing'
   AND cp_country.country_id = pad.country_id
 GROUP BY pdm.product_id,
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
          cp_country.country_name,
          ivd.vat_amount_in_vat_cur,
          ivd.vat_remit_cur_id,
          cm_vat.cur_code,
          ivd.fx_rate_vc_ic

