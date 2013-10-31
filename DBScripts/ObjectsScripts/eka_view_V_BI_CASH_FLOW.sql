-- This is used only for Cash Flow Doamin
CREATE OR REPLACE VIEW V_BI_CASH_FLOW AS
with costtypewithoutaccrual as
     (select   cs.cost_ref_no,
               sum((case
                       when cs.cost_type in ('Reversal')
                       then cs.transact_amt_sign * cs.transaction_amt
                       else 0
                       end
                   )) reversal,
               sum((case
                       when cs.cost_type in ('Actual', 'Direct Actual')
                       then cs.transact_amt_sign * cs.transaction_amt
                       else 0
                       end
                   )) actual
          from cigc_contract_item_gmr_cost cigc,
               cs_cost_store               cs,
               scm_service_charge_master   scm
         where cs.cost_component_id = scm.cost_id
           and cigc.cog_ref_no = cs.cog_ref_no
           and not cs.cost_type in ('Accrual', 'Estimate')
           and cigc.is_deleted = 'N'
           and cs.is_deleted = 'N'
      group by cs.cost_ref_no)
      --1 Invoices
select 'Invoices to extent not paid' section_name,
       iss.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       iss.invoiced_qty weight,
       'MT' weight_unit,
       nvl(iss.fx_to_base, 1) fx_base,
       iss.invoice_created_date effective_date,
       nvl(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
       nvl(cpc.profit_center_short_name, cpc1.profit_center_short_name) profit_center,
       akc.base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       (case
         when nvl(pcm.purchase_sales, 'NA') = 'P' then
          'Purchase'
         when nvl(pcm.purchase_sales, 'NA') = 'S' then
          'Sales'
         else
          'NA'
       end) contract_type,
       'Invoices' position_type,
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
       nvl(iss.invoice_ref_no, 'NA') as contract_ref_no,
       (case
         when iss.invoice_type_name = 'AdvancePayment' then
          'Commercial'
         else
          nvl(iss.invoice_type, 'NA')
       end) invoice_type,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code invoice_cur_code,
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
        end) end) else 1 end) invoice_amount_in_base_cur,
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
       iss.invoice_issue_date activity_date,
       iss.payment_due_date cash_flow_date,
       iss.invoice_type_name invoice_name
  from is_invoice_summary            iss,
       cm_currency_master            cm_p,
       incm_invoice_contract_mapping incm,
       pcm_physical_contract_main    pcm,
       ak_corporate                  akc,
       cpc_corporate_profit_center   cpc,
       cpc_corporate_profit_center   cpc1,
       pcpd_pc_product_definition    pcpd,
       cm_currency_master            cm_akc_base_cur,
       css_corporate_strategy_setup  css,
       blm_business_line_master      blm,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails      phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab
 where iss.is_active = 'Y'
   and iss.corporate_id is not null
   and iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
   and incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and iss.corporate_id = akc.corporate_id
   and iss.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and iss.profit_center_id = cpc.profit_center_id(+)
   and pcpd.profit_center_id = cpc1.profit_center_id(+)
   and iss.invoice_cur_id = cm_p.cur_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and pcpd.product_id = pdm.product_id(+)
   and pdm.product_group_id = pgm.product_group_id
   and phd_contract_cp.profileid(+) = pcm.cp_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid(+)
   and nvl(pgm.is_active, 'Y') = 'Y'
   and nvl(gab.is_active, 'Y') = 'Y'
   and nvl(pcm.partnership_type, 'Normal') = 'Normal'
   and iss.is_inv_draft = 'N'
   and iss.invoice_type_name <> 'Profoma'
   and cm_akc_base_cur.cur_id = akc.base_cur_id
   and pcpd.input_output = 'Input'
   and pcpd.strategy_id = css.strategy_id(+)
   and iss.total_amount_to_pay <> 0
union all
--- 2 Service invoices
select 'Invoices to extent not paid' section_name,
       iss.corporate_id,
       ak.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       'NA' product_id,
       'NA' product_desc,
       'NA' product_group_id,
       'NA' product_group,
       iss.cp_id  counter_party_id,
       phd_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       iss.invoiced_qty weight,
       'MT' weight_unit,
       nvl(iss.fx_to_base, 1) fx_base,
       iss.invoice_created_date effective_date,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center,
       ak.base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       (case
         when nvl(pcm.purchase_sales, 'NA') = 'P' then
          'Purchase'
         when nvl(pcm.purchase_sales, 'NA') = 'S' then
          'Sales'
         else
          'NA'
       end) contract_type,
       'Invoices' position_type,
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
       end) end) payable_receivable,
       nvl(iss.invoice_ref_no, 'NA') as contract_ref_no,
       (case
         when iss.invoice_type_name = 'AdvancePayment' then
          'Commercial'
         else
          nvl(iss.invoice_type, 'NA')
       end) invoice_type,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code invoice_cur_code,
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
        end) end) invoice_amount_in_base_cur,
       round(iss.total_amount_to_pay, 4) * case
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          -1
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          1
       end invoice_amt,
       iss.invoice_issue_date activity_date,
       iss.payment_due_date cash_flow_date,
       iss.invoice_type_name invoice_name       
  from is_invoice_summary           iss,
       iam_invoice_action_mapping   iam,
       iid_invoicable_item_details  iid,
       axs_action_summary           axs,
       cs_cost_store                cs,
       cigc_contract_item_gmr_cost  cigc,
       gmr_goods_movement_record    gmr,
       pcpd_pc_product_definition   pcpd,
       pcm_physical_contract_main   pcm,
       css_corporate_strategy_setup css,
       ak_corporate                 ak,
       ak_corporate_user            akcu,
       gab_globaladdressbook        gab,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       phd_profileheaderdetails     phd_cp,
       cm_currency_master           cm_akc_base_cur,
       cm_currency_master           cm_p
 where iss.internal_contract_ref_no is null
   and iss.is_active = 'Y'
   and iss.internal_invoice_ref_no = iam.internal_invoice_ref_no
   and iss.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
   and iam.invoice_action_ref_no = axs.internal_action_ref_no
   and iam.invoice_action_ref_no = cs.internal_action_ref_no(+)
   and cs.cog_ref_no = cigc.cog_ref_no(+)
   and cigc.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
   and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid(+)
   and pcpd.input_output(+) = 'Input'
   and pcpd.strategy_id = css.strategy_id(+)
   and iss.corporate_id = ak.corporate_id
   and iss.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and iss.cp_id = phd_cp.profileid
   and cm_akc_base_cur.cur_id = ak.base_cur_id
   and iss.invoice_cur_id = cm_p.cur_id(+)
 group by iss.corporate_id,
          iss.cp_id,
          iss.invoiced_qty,
          iss.fx_to_base,
          iss.invoice_created_date,
          iss.recieved_raised_type,
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
          blm.business_line_id,
          blm.business_line_name,
          phd_cp.companyname,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          cm_akc_base_cur.cur_code,
          cm_p.cur_code,
          css.strategy_id,
          css.strategy_name,
          gab.gabid,
          gab.firstname || ' ' || gab.lastname,
          pcm.purchase_sales
-- 3. OTC invoices
UNION ALL
SELECT 'OTC invoices',
       dt.corporate_id,
       ak.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       dt.cp_profile_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       dt.broker_profile_id,
       '' broker,
       'NA' cost_type_name,
       dt.total_quantity weight,
       qum.qty_unit weight_unit,
       pkg_general.f_get_converted_currency_amt(dis.corporate_id,
                                                dis.invoice_cur_id,
                                                ak.base_cur_id,
                                                dis.issue_date,
                                                1) FX_Base,
       null effective_date,
       dt.profit_center_id,
       cpc.profit_center_short_name,
       cm_akc_base_cur.cur_id base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       dt.strategy_id strategy_id,
       css.strategy_name,
       (CASE
           WHEN dt.trade_type LIKE '%Buy%' THEN
            'Purchase'
           ELSE
            'Sales'
       END) contract_type,
       'Invoices' position_type,
       (CASE
           WHEN dt.trade_type LIKE '%Buy%' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) inflow_outflow,
       dt.derivative_ref_no ref_no,
       nvl(dis.invoice_type,'NA') invoice_type,
       inv_cur.cur_id invoice_cur_id,
       inv_cur.cur_code invoice_cur_code,
       round((CASE
                 WHEN ak.base_cur_id = dis.invoice_cur_id THEN
                  1
                 ELSE
                  pkg_general.f_get_converted_currency_amt(dis.corporate_id,
                                                           dis.invoice_cur_id,
                                                           ak.base_cur_id,
                                                           dis.issue_date,
                                                           1)
             END) * round(dis.amt_to_pay, 4) * (CASE
                 WHEN nvl(dis.received_raised_type, 'NA') = 'Raised' THEN
                  1
                 WHEN nvl(dis.received_raised_type, 'NA') = 'Received' THEN
                  -1
                 ELSE
                  1
             END),
             4) invoice_amount_in_base_cur,
       round(dis.amt_to_pay, 4) * (CASE
                                       WHEN nvl(dis.received_raised_type, 'NA') = 'Raised' THEN
                                        1
                                       WHEN nvl(dis.received_raised_type, 'NA') = 'Received' THEN
                                        -1
                                       ELSE
                                        1
                                   END),
       dis.issue_date activity_date,
       dis.payment_due_date cash_flow_date,
       nvl(dis.invoice_type_name,'NA') invoice_name
FROM   dt_derivative_trade            dt,
       ak_corporate                   ak,
       cpc_corporate_profit_center    cpc,
       css_corporate_strategy_setup   css,
       cm_currency_master             inv_cur,
       dis_derivative_invoice_summary dis,
       fsh_fin_settlement_header      fsh,
       cm_currency_master             cm_akc_base_cur,
       blm_business_line_master      blm,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       qum_quantity_unit_master      qum
WHERE  ak.corporate_id = dt.corporate_id
AND    cpc.profit_center_id = dt.profit_center_id
AND    css.strategy_id = dt.strategy_id
AND    inv_cur.cur_id = dis.invoice_cur_id
AND    dt.internal_derivative_ref_no = fsh.internal_derivative_ref_no
AND    fsh.fsh_id = dis.internal_settlement_ref_no
AND    dis.invoice_status = 'Active'
AND    fsh.is_deleted = 'N'
AND    dt.is_what_if = 'N'
AND    inv_cur.is_active = 'Y'
AND    css.is_active = 'Y'
AND    cpc.is_active = 'Y'
AND    ak.is_active = 'Y'
AND    cm_akc_base_cur.cur_id = ak.base_cur_id
AND    cpc.business_line_id = blm.business_line_id(+)
AND    dt.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = dt.cp_profile_id
AND    dt.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    dt.quantity_unit_id = qum.qty_unit_id(+)
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y'
-- 4. Currency Trades
UNION ALL
SELECT 'Currency Trades',
       ct.corporate_id,
       ak.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       ct.counter_party_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       0 weight,
       '' weight_unit,
       ct.exchange_rate FX_Base,
       null effective_date,
       ct.profit_center_id,
       cpc.profit_center_short_name,
       akc_cm.cur_id base_cur_id,
       akc_cm.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       crtd.trade_type contract_type,
       'Currency Trades' position_type,
       (CASE
           WHEN upper(crtd.trade_type) = 'BUY' THEN
            'Inflow'
           ELSE
            'Outflow'
       END) inflow_outflow,
       nvl(crtd.internal_treasury_ref_no,'NA') contract_ref_no,
       'NA' invoice_type,
       crtd.cur_id invoice_cur_id,
       crtd_cm.cur_code invoice_cur_code,
       round(crtd.amount, 4) * (CASE
                                    WHEN upper(crtd.trade_type) = 'BUY' THEN
                                     1
                                    ELSE
                                     -1
                                END) * ct.exchange_rate cash_flow_amount,
       round(crtd.amount, 4) * (CASE
                                    WHEN upper(crtd.trade_type) = 'BUY' THEN
                                     1
                                    ELSE
                                     -1
                                END),
       ct.trade_date activity_date,
       ct.payment_due_date cash_flow_date,
       'NA' invoice_name
FROM   ct_currency_trade            ct,
       ak_corporate                 ak,
       cm_currency_master           akc_cm,
       cpc_corporate_profit_center  cpc,
       cm_currency_master           cpc_cm,
       css_corporate_strategy_setup css,
       crtd_cur_trade_details       crtd,
       cm_currency_master           crtd_cm,
       blm_business_line_master      blm,
       drm_derivative_master        drm,
       dim_der_instrument_master    dim,
       pdd_product_derivative_def   pdd,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab
WHERE  ct.corporate_id = ak.corporate_id
AND    ak.base_cur_id = akc_cm.cur_id
AND    ct.profit_center_id = cpc.profit_center_id
AND    ct.strategy_id = css.strategy_id(+)
AND    ct.internal_treasury_ref_no = crtd.internal_treasury_ref_no
AND    crtd.cur_id = crtd_cm.cur_id(+)
AND    cpc.profit_center_cur_id = cpc_cm.cur_id(+)
AND    upper(ct.status) = 'VERIFIED'
and cpc.business_line_id = blm.business_line_id
and    ct.dr_id = drm.dr_id
and    drm.instrument_id = dim.instrument_id
and    dim.product_derivative_id = pdd.derivative_def_id
and    pdd.product_id = pdm.product_id
and    pdm.product_group_id = pgm.product_group_id(+)
AND    phd_contract_cp.profileid(+) = ct.counter_party_id
AND    ct.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y'
-- 5. Accruals - Expense accruals (remaining), income accrual (remaining)
UNION ALL
SELECT 'Accruals ',
       akc.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       scm.cost_component_name cost_type_name,
       cigc.qty weight,
       qum.qty_unit weight_unit,
       nvl(cs.fx_to_base,1) FX_Base,
       cs.effective_date,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_name profit_center_name,
       akc.base_cur_id,
       cm_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       cs.income_expense contract_type,
       'Accruals' position_type,
       (CASE
           WHEN cs.income_expense = 'Expense' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) payable_receivable,
       gmr.gmr_ref_no ref_no,
       'NA' invoice_type,
       cs.transaction_amt_cur_id invoice_cur_id,
       cm_cs_cur.cur_code invoice_cur_code,
       nvl(cs.fx_to_base,1) */* round(nvl(cs.transaction_amt, 0), 4)*/
       (case
           when   cs.transaction_amt - nvl (cs_act.actual, 0)- nvl (cs_act.reversal, 0) > 0
           then   cs.transaction_amt - nvl (cs_act.actual, 0)- nvl (cs_act.reversal, 0)
           else 0
           end
       ) * (CASE
           WHEN cs.income_expense = 'Expense' THEN
            -1
           ELSE
            1
       END) invoice_amount_in_base_cur,
       /*round(nvl(cs.transaction_amt, 0), 4)*/
       (case
           when   cs.transaction_amt - nvl (cs_act.actual, 0)- nvl (cs_act.reversal, 0) > 0
           then   cs.transaction_amt - nvl (cs_act.actual, 0)- nvl (cs_act.reversal, 0)
           else 0
           end
       ) *
       (CASE
            WHEN cs.income_expense = 'Expense' THEN
             -1
            ELSE
             1
        END) invoice_amount,
       cs.effective_date activity_date,
       cs.effective_date cash_flow_date,
       'NA' invoice_name
FROM   cigc_contract_item_gmr_cost  cigc,
       cs_cost_store                cs,
       gmr_goods_movement_record    gmr,
       ak_corporate                 akc,
       cm_currency_master           cm_base_cur,
       pcpd_pc_product_definition pcpd,
       cpc_corporate_profit_center  cpc,
       css_corporate_strategy_setup css,
       cm_currency_master           cm_cs_cur,
       scm_service_charge_master scm,
       pcm_physical_contract_main    pcm,
       blm_business_line_master      blm,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       qum_quantity_unit_master      qum,
       costtypewithoutaccrual      cs_act,
       (select grd.internal_gmr_ref_no,
        pcdi.internal_contract_ref_no
   from grd_goods_record_detail    grd,
        pci_physical_contract_item pci,
        pcdi_pc_delivery_item      pcdi
  where grd.internal_contract_item_ref_no =
        pci.internal_contract_item_ref_no
    and pci.pcdi_id = pcdi.pcdi_id
    and grd.is_deleted = 'N'
    and pci.is_active = 'Y'
    and pcdi.is_active = 'Y'
  group by grd.internal_gmr_ref_no,
           pcdi.internal_contract_ref_no) contract
WHERE  cs.cog_ref_no = cigc.cog_ref_no
AND    cs.cost_type = 'Accrual'
AND    cigc.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    gmr.corporate_id = akc.corporate_id
AND    akc.base_cur_id = cm_base_cur.cur_id
and gmr.internal_gmr_ref_no=contract.internal_gmr_ref_no
and contract.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    pcpd.strategy_id = css.strategy_id
AND    cm_cs_cur.cur_id = cs.transaction_amt_cur_id
and    scm.cost_id = cs.cost_component_id
and    scm.cost_type ='SECONDARY_COST'
and    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    cpc.business_line_id = blm.business_line_id(+)
AND    pcpd.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = pcm.cp_id
AND    pcm.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    cigc.qty_unit_id = qum.qty_unit_id(+)
and    cs_act.cost_ref_no(+) = cs.cost_ref_no
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y'
and    cs.is_deleted='N'
and    cigc.is_deleted='N'
and    gmr.is_deleted='N'
and    pcm.is_active='Y'
and    pcpd.is_active='Y'
---
-- 6. Open Contracts(includes shipped title not transferred), title transferrred but not invoiced
---
UNION ALL
SELECT 'Open Contracts',
       mvf.corporate_id,
       mvf.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       mvf.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       mvf.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       mvf.contract_quantity weight,
       mvf.contract_quantity_uom weight_unit,
       pkg_general.f_get_converted_currency_amt(mvf.corporate_id,
                                                           mvf.market_value_cur_id,
                                                           mvf.base_cur_id,
                                                           mvf.eod_date,
                                                           1) FX_Base,
       null effective_date,
       mvf.profit_center_id,
       mvf.profit_center,
       mvf.base_cur_id,
       mvf.base_cur_code,
       mvf.strategy_id,
       mvf.strategy_name,
       (CASE
           WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
            'Purchase'
           ELSE
            'Sales'
       END) contract_type,
     
       'Open Contracts' position_type,
       (CASE
           WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) inflow_outflow,
         nvl(mvf.contract_ref_no,'NA') ref_no,
       'NA' invoice_type,
       NULL invoice_cur_id,
       mvf.m2m_currency invoice_cur_code,
       round((CASE
                 WHEN nvl(cm.cur_code, mvf.base_cur_code) = mvf.m2m_currency THEN
                  1
                 ELSE
                  pkg_general.f_get_converted_currency_amt(mvf.corporate_id,
                                                           mvf.market_value_cur_id,
                                                           mvf.base_cur_id,
                                                           mvf.eod_date,
                                                           1)
             END) * round(mvf.total_cost_in_m2m_currency, 4) * (CASE
                 WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
                  -1
                 ELSE
                  1
             END),
             4),
       round(mvf.total_cost_in_m2m_currency, 4) *
       (CASE
            WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
             -1
            ELSE
             1
        END),
       mvf.issue_trade_date activity_date,
       mvf.eod_date cash_flow_date,
       'NA' invoice_name
FROM   mv_fact_phy_unreal_fixed_price mvf,
       cpc_corporate_profit_center cpc,
       cm_currency_master          cm,
       blm_business_line_master      blm,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab
WHERE  mvf.profit_center_id = cpc.profit_center_id
AND    mvf.base_cur_id = cm.cur_id(+)
AND    (mvf.corporate_id, mvf.eod_date) IN
       (SELECT eod.corporate_id,
                MAX(eod.as_of_date)
         FROM   eod_end_of_day_details eod
         WHERE  eod.processing_status IN
                ('EOD Processed Successfully',
                 'EOD Process Success,Awaiting Cost Entry')
         GROUP  BY eod.corporate_id)
AND    NOT EXISTS -- Not Invoiced Check
 (SELECT iss.corporate_id,
               iss.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               gmr.gmr_ref_no
        FROM   is_invoice_summary          iss,
               iid_invoicable_item_details iid,
               gmr_goods_movement_record   gmr
        WHERE  iss.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    iss.is_active ='Y'
        AND    iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND    iss.corporate_id = mvf.corporate_id
        and    iss.is_inv_draft = 'N'
        AND    instr(mvf.contract_ref_no, gmr.gmr_ref_no, 1) = 1)
AND    cpc.business_line_id = blm.business_line_id(+)
AND    mvf.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = mvf.cp_id
AND    mvf.trader_user_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    nvl(pgm.is_active,'Y') = 'Y'
-- 7. Base Metal Open Uninvoiced GMRs with Fixed Price (Base Metal)
UNION ALL
SELECT 'Fixed Price GMRs Base Metal' section_name,
       akc.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
        nvl(grd.title_transfer_out_qty,0))) weight,
       qum.qty_unit weight_unit,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      gmr.eff_date,
                                                      1) FX_Base,
       null effective_date,
       cpc.profit_center_id,
       cpc.profit_center_name,
       akc.base_cur_id base_cur_id,
       cm_base.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') contract_type,
       'Open Contracts' position_type,
       (CASE
           WHEN pcm.purchase_sales = 'P' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) recievable_payable,
       gmr.internal_gmr_ref_no,
       'NA' invoice_type,
       pum.cur_id invoice_cur_id,
       cm_pum.cur_code invoice_cur_code,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      SYSDATE,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   grd.qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ((nvl(grd.current_qty, 0) +
                                                   nvl(grd.release_shipped_qty,
                                                         0) -
                                                   nvl(grd.title_transfer_out_qty,
                                                         0))))),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) cashflow_amt_in_base_cur,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      gmr.eff_date,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   grd.qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ((nvl(grd.current_qty, 0) +
                                                   nvl(grd.release_shipped_qty,
                                                         0) -
                                                   nvl(grd.title_transfer_out_qty,
                                                         0))))),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) invoice_amt,
       pcm.issue_date activity_date,
       gmr.eff_date cashflow_date,
       'NA' invoice_name
FROM   gmr_goods_movement_record    gmr,
       pcm_physical_contract_main   pcm,
       pcdi_pc_delivery_item        pcdi,
       pci_physical_contract_item   pci,
       ak_corporate                 akc,
       grd_goods_record_detail      grd,
       pdm_productmaster            pdm,
       ppu_product_price_units      ppu,
       pum_price_unit_master        pum,
       cpc_corporate_profit_center  cpc,
       css_corporate_strategy_setup css,
       cm_currency_master           cm_base,
       cm_currency_master cm_pum,
       pcpd_pc_product_definition   pcpd,
       blm_business_line_master      blm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       qum_quantity_unit_master      qum
WHERE  NOT EXISTS -- Not Invoiced Check
 (SELECT iss.corporate_id,
               iss.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               gmr.gmr_ref_no
        FROM   is_invoice_summary          iss,
               iid_invoicable_item_details iid
        WHERE  iss.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    iss.is_active ='Y'
        AND    iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
AND    grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
AND    pci.pcdi_id = pcdi.pcdi_id
AND    pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
AND    pcdi.item_price_type = 'Fixed'
AND    gmr.corporate_id = akc.corporate_id
AND    gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
AND    grd.product_id = pdm.product_id
AND    ppu.internal_price_unit_id = pcdi.item_price_unit
AND    ppu.price_unit_id = pum.price_unit_id
AND    grd.profit_center_id = cpc.profit_center_id
AND    grd.strategy_id = css.strategy_id
AND    akc.base_cur_id = cm_base.cur_id
AND    (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -   nvl(grd.title_transfer_out_qty, 0)) > 0
and    cm_pum.cur_id = pum.cur_id
and    pcm.contract_type ='BASEMETAL'
and    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    cpc.business_line_id = blm.business_line_id(+)
aND    pcpd.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = pcm.cp_id
AND    pcm.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    grd.qty_unit_id = qum.qty_unit_id(+)
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y'
-- 8. Open Contracts Fixed Price Basis (Base Metal)
UNION ALL
SELECT 'Fixed Price Contracts Base Metal' section_name,
       akc.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       ciqs.open_qty weight,
       qum.qty_unit weight_unit,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      pcm.issue_date,
                                                      1) FX_Base,
       null effective_date,
       cpc.profit_center_id,
       cpc.profit_center_name,
       cm_base.cur_id,
       cm_base.cur_code,
       css.strategy_id,
       css.strategy_name,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') contract_type,
       'Open Contracts' position_type,
       (CASE
           WHEN pcm.purchase_sales = 'P' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) recievable_payable,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no,
       'NA' invoice_type,
       NULL invoice_cur_id,
       cm_base.cur_code invoice_cur_code,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      SYSDATE,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   ciqs.item_qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ciqs.open_qty)),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) cashflow_amt_in_base_cur,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      pcm.issue_date,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   ciqs.item_qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ciqs.open_qty)),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END)  invoice_amt,
       pcm.issue_date activity_date,
       pcm.issue_date cashflow_date,
       'NA' invoice_name
FROM   pcm_physical_contract_main    pcm,
       pcdi_pc_delivery_item         pcdi,
       pci_physical_contract_item    pci,
       ciqs_contract_item_qty_status ciqs,
       ak_corporate                  akc,
       cpc_corporate_profit_center   cpc,
       pcpd_pc_product_definition    pcpd,
       cm_currency_master            cm_base,
       css_corporate_strategy_setup  css,
       pdm_productmaster             pdm,
       ppu_product_price_units       ppu,
       pum_price_unit_master         pum,
       blm_business_line_master      blm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       qum_quantity_unit_master      qum
WHERE  pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdi.pcdi_id = pci.pcdi_id
AND    pcdi.item_price_type = 'Fixed'
AND    pci.internal_contract_item_ref_no = ciqs.internal_contract_item_ref_no
AND    ciqs.open_qty > 0
AND    pcm.corporate_id = akc.corporate_id
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    akc.base_cur_id = cm_base.cur_id
AND    pcpd.strategy_id = css.strategy_id
AND    pcpd.product_id = pdm.product_id
AND    ppu.internal_price_unit_id = pcdi.item_price_unit
AND    ppu.price_unit_id = pum.price_unit_id
AND    pcm.contract_type ='BASEMETAL'
AND    cpc.business_line_id = blm.business_line_id(+)
aND    pcpd.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = pcm.cp_id
AND    pcm.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    ciqs.item_qty_unit_id = qum.qty_unit_id(+)
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y';