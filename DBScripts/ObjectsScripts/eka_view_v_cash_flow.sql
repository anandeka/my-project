CREATE OR REPLACE VIEW V_CASH_FLOW AS
--
-- 1. Invoices - Includes all invoices and credit / debit notes to the extent not paid
--
SELECT 'Invoices to extent not paid' section_name,
       iss.corporate_id,
       akc.corporate_name,
       nvl(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
       nvl(cpc.profit_center_short_name, cpc1.profit_center_short_name) profit_center,
       akc.base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       (CASE
           WHEN nvl(pcm.purchase_sales, 'NA') = 'P' THEN
            'Purchase'
           WHEN nvl(pcm.purchase_sales, 'NA') = 'S' THEN
            'Sales'
           ELSE
            'NA'
       END) contract_type,
       'Invoices' position_type,
       CASE
           WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit') AND
                sign(iss.total_amount_to_pay) = 1 AND pcm.purchase_sales ='P' THEN    'Outflow'
                WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit') AND
                sign(iss.total_amount_to_pay) = 1 AND pcm.purchase_sales ='S' THEN 'Inflow'                 
                WHEN (iss.invoice_type = 'Commercial' OR  iss.invoice_type ='DebitCredit') AND
                sign(iss.total_amount_to_pay) = -1 AND pcm.purchase_sales ='P' THEN    'Inflow'
                WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit') AND
                sign(iss.total_amount_to_pay) = -1 AND pcm.purchase_sales ='S' THEN    'Outflow'
           WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Recieved' THEN 'Outflow'
           WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Raised' THEN 'Inflow'
           WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='P' THEN  'Outflow' 
           WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='S' THEN  'Inflow' 
         --  WHEN nvl(pcm.purchase_sales, 'NA') = 'P' THEN 'Outflow'
         --  WHEN nvl(pcm.purchase_sales, 'NA') = 'S' THEN 'Inflow'
       END payable_receivable,
       nvl(iss.invoice_ref_no, 'NA') AS contract_ref_no,
       (CASE
           WHEN iss.invoice_type_name = 'AdvancePayment' THEN
            'Commercial'
           ELSE
            nvl(iss.invoice_type, 'NA')
       END) invoice_type,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code invoice_cur_code,
       round(iss.total_amount_to_pay, 4) * nvl(iss.fx_to_base, 1) *
       CASE
       WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit')  THEN    1
       WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Recieved' THEN -1
       WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Raised' THEN 1
       WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='P' THEN  -1 
       WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='S' THEN  1 
    --   WHEN nvl(pcm.purchase_sales, 'NA') = 'P' THEN -1
    --  WHEN nvl(pcm.purchase_sales, 'NA') = 'S' THEN 1
   END invoice_amount_in_base_cur,
       round(iss.total_amount_to_pay, 4) *
       CASE
       WHEN (iss.invoice_type = 'Commercial' OR iss.invoice_type ='DebitCredit') THEN    1
       WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Recieved' THEN -1
       WHEN nvl(iss.invoice_type, 'NA') = 'Service'  AND nvl(iss.recieved_raised_type ,'NA') ='Raised' THEN 1
       WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='P' THEN  -1 
       WHEN nvl(iss.invoice_type_name,'NA') = 'AdvancePayment' AND pcm.purchase_sales ='S' THEN  1 
  --       WHEN nvl(pcm.purchase_sales, 'NA') = 'P' THEN -1
  --     WHEN nvl(pcm.purchase_sales, 'NA') = 'S' THEN 1
   END invoice_amt,
       iss.invoice_issue_date activity_date,
       iss.payment_due_date cash_flow_date
FROM   is_invoice_summary            iss,
       cm_currency_master            cm_p,
       incm_invoice_contract_mapping incm,
       pcm_physical_contract_main    pcm,
       ak_corporate                  akc,
       cpc_corporate_profit_center   cpc,
       cpc_corporate_profit_center   cpc1,
       pcpd_pc_product_definition    pcpd,
       cm_currency_master            cm_akc_base_cur,
       css_corporate_strategy_setup  css
WHERE  iss.is_active = 'Y'
AND    iss.corporate_id IS NOT NULL
AND    iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
AND    incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
AND    iss.corporate_id = akc.corporate_id
AND    iss.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    iss.profit_center_id = cpc.profit_center_id(+)
AND    pcpd.profit_center_id = cpc1.profit_center_id(+)
AND    iss.invoice_cur_id = cm_p.cur_id(+)
AND    nvl(pcm.partnership_type, 'Normal') = 'Normal'
and iss.is_inv_draft = 'N'
/*AND    'TRUE' = 
       (CASE WHEN iss.invoice_type_name = 'AdvancePayment' THEN 'TRUE' WHEN
        iss.invoice_type_name = 'Profoma' THEN 'FALSE' WHEN
        iss.invoice_type = 'DebitCredit' THEN 'TRUE'
        ELSE(CASE WHEN nvl(iss.invoice_type, 'NA') = 'Commercial' THEN 'TRUE' WHEN
              nvl(iss.invoice_type, 'NA') = 'Service' THEN 'TRUE' ELSE 'FALSE' END) END)
*/ and iss.invoice_type_name <> 'Profoma'
AND    cm_akc_base_cur.cur_id = akc.base_cur_id
AND    pcpd.strategy_id = css.strategy_id(+)
AND    iss.total_amount_to_pay <> 0

--
-- 2. OTC invoices 
-- 
UNION ALL
SELECT 'OTC invoices',
       dt.corporate_id,
       ak.corporate_name,
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
                                                           SYSDATE,
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
       dis.payment_due_date cash_flow_date
FROM   dt_derivative_trade            dt,
       ak_corporate                   ak,
       cpc_corporate_profit_center    cpc,
       css_corporate_strategy_setup   css,
       cm_currency_master             inv_cur,
       dis_derivative_invoice_summary dis,
       fsh_fin_settlement_header      fsh,
       cm_currency_master             cm_akc_base_cur
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
--
-- 3. Currency Trades
--
UNION ALL
SELECT 'Currency Trades',
       ct.corporate_id,
       ak.corporate_name,
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
       ct.payment_due_date cash_flow_date
FROM   ct_currency_trade            ct,
       ak_corporate                 ak,
       cm_currency_master           akc_cm,
       cpc_corporate_profit_center  cpc,
       cm_currency_master           cpc_cm,
       css_corporate_strategy_setup css,
       crtd_cur_trade_details       crtd,
       cm_currency_master           crtd_cm
WHERE  ct.corporate_id = ak.corporate_id
AND    ak.base_cur_id = akc_cm.cur_id
AND    ct.profit_center_id = cpc.profit_center_id
AND    ct.strategy_id = css.strategy_id(+)
AND    ct.internal_treasury_ref_no = crtd.internal_treasury_ref_no
AND    crtd.cur_id = crtd_cm.cur_id(+)
AND    cpc.profit_center_cur_id = cpc_cm.cur_id(+)
AND    upper(ct.status) = 'VERIFIED'
--
-- 4. Accruals - Expense accruals (remaining), income accrual (remaining)
--
UNION ALL
SELECT 'Accruals ',
       akc.corporate_id,
       akc.corporate_name,
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
       (CASE
           WHEN cm_base_cur.cur_id = cs.transaction_amt_cur_id THEN
            1
           ELSE
            pkg_general.f_get_converted_currency_amt(gmr.corporate_id,
                                                     cs.transaction_amt_cur_id,
                                                     cm_base_cur.cur_id,
                                                     SYSDATE,
                                                     1)
       END) * round(nvl(cs.transaction_amt, 0), 4) * (CASE
           WHEN cs.income_expense = 'Expense' THEN
            -1
           ELSE
            1
       END) invoice_amount_in_base_cur,
       round(nvl(cs.transaction_amt, 0), 4) *
       (CASE
            WHEN cs.income_expense = 'Expense' THEN
             -1
            ELSE
             1
        END) invoice_amount,
       cs.effective_date,
       cs.effective_date
FROM   cigc_contract_item_gmr_cost  cigc,
       cs_cost_store                cs,
       gmr_goods_movement_record    gmr,
       ak_corporate                 akc,
       cm_currency_master           cm_base_cur,
       pcpd_pc_product_definition pcpd,
       cpc_corporate_profit_center  cpc,
       css_corporate_strategy_setup css,
       cm_currency_master           cm_cs_cur,
       scm_service_charge_master scm
WHERE  cs.cog_ref_no = cigc.cog_ref_no
AND    cs.cost_type = 'Accrual'
AND    cigc.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    gmr.corporate_id = akc.corporate_id
AND    akc.base_cur_id = cm_base_cur.cur_id
AND    gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    pcpd.strategy_id = css.strategy_id
AND    cm_cs_cur.cur_id = cs.transaction_amt_cur_id
and    scm.cost_id = cs.cost_component_id
and    scm.cost_type ='SECONDARY_COST'
--
-- 5. Open Contracts(includes shipped title not transferred), title transferrred but not invoiced
--
UNION ALL
SELECT 'Open Contracts',
       mvf.corporate_id,
       mvf.corporate_name,
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
       nvl(mvf.contract_ref_no,'NA') ref_no,
       'Open Contracts' position_type,
       (CASE
           WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) inflow_outflow,
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
                                                           SYSDATE,
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
       mvf.eod_date cash_flow_date
FROM   mv_fact_phy_unreal_fixed_price mvf,
       cpc_corporate_profit_center cpc,
       cm_currency_master          cm
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
        AND    iss.invoice_status = 'Active'
        AND    iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND    iss.corporate_id = mvf.corporate_id
        and    iss.is_inv_draft = 'N'
        AND    instr(mvf.contract_ref_no, gmr.gmr_ref_no, 1) = 1)
--
-- 6. Base Metal Open Uninvoiced GMRs with Fixed Price (Base Metal)
--
UNION ALL
SELECT 'Fixed Price GMRs Base Metal' section_name,
       akc.corporate_id,
       akc.corporate_name,
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
                   END) invoice_amt,
       pcm.issue_date activity_date,
       gmr.eff_date cashflow_date
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
       cm_currency_master cm_pum
WHERE  NOT EXISTS -- Not Invoiced Check
 (SELECT iss.corporate_id,
               iss.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               gmr.gmr_ref_no
        FROM   is_invoice_summary          iss,
               iid_invoicable_item_details iid
        WHERE  iss.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    iss.invoice_status = 'Active'
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

UNION ALL
--
-- 7. Open Contracts Fixed Price Basis (Base Metal)
--
SELECT 'Fixed Price Contracts Base Netal' section_name,
       akc.corporate_id,
       akc.corporate_name,
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
                   END)  invoice_amt,
       pcm.issue_date activity_date,
       pcm.issue_date cashflow_date
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
       pum_price_unit_master         pum
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
/
