DROP MATERIALIZED VIEW MV_FACT_DERIVATIVE_UNREALIZED;
DROP TABLE MV_FACT_DERIVATIVE_UNREALIZED;
CREATE MATERIALIZED VIEW MV_FACT_DERIVATIVE_UNREALIZED 
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
select dpd.corporate_id,
       dpd.corporate_name,
       pdm.product_type_id product_type,
       dpd.profit_center_id,
       dpd.profit_center_short_name profit_center,
       dpd.strategy_id,
       dpd.strategy_name,
       dpd.product_id,
       dpd.product_name,
       dpd.quality_id,
       dpd.quality_name,
       dpd.eod_trade_date eod_date,
       'Derivatives' position_type,
       dpd.instrument_type || ' ' || (case when dpd.trade_type ='Buy' then 'Long' else 'Short' end)  position_sub_type,
       dpd.derivative_ref_no contract_ref_no,
       dpd.external_ref_no,
       dpd.trade_date issue_trade_date,
       dpd.clearer_profile_id cp_id,
       dpd.clearer_name cp_name,
       dpd.payment_term,
       dpd.purpose_name derivative_purpose,
       (case
         when dpd.instrument_type = 'Option Call' then
          'Call'
         when dpd.instrument_type = 'Option Put' then
          'Put'
         else
          ''
       end) option_type,
       dpd.strike_price strike_price,
       dpd.strike_price_cur_code || '/' || dpd.strike_price_weight ||
       dpd.strike_price_weight_unit strike_price_unit,
       'NA' allocated_phy_refno,
       dpd.group_cur_code,
       cm_corp.cur_code corporate_base_currency,
       (case
         when dpd.trade_type = 'Sell' then
          -1
         else
          1
       end) * dpd.open_quantity contract_quantity,
       dpd.quantity_unit contract_quantity_uom,
       (case
         when dpd.trade_type = 'Sell' then
          -1
         else
          1
       end) * dpd.trade_qty_in_exch_unit quantity_in_base_uom,
       (case
         when dpd.trade_type = 'Sell' then
          -1
         else
          1
       end) * dpd.open_lots quantity_in_lots,
       dpd.trade_price contract_price,
       dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
       dpd.trade_price_weight_unit trade_price_unit,
       dpd.instrument_id valuation_instrument_id, --valuation_instument_id
       dpd.instrument_name valuation_instrument,
       dpd.derivative_def_id,
       dpd.derivative_def_name,
       to_char(dpd.period_date, 'Mon-yyyy') valuation_month,
       dpd.period_date value_date,
       dpd.settlement_price m2m_settlement_price,
       dpd.settlement_price net_settlement_price,
       dpd.sett_price_cur_code || '/' || dpd.sett_price_weight ||
       dpd.sett_price_weight_unit settlement_price_unit,
       dpd.market_value_in_trade_cur  market_value_in_val_ccy,
       dpd.base_cur_id   market_value_cur_id,
       dpd.base_cur_code market_value_cur_code,
       dpd.prev_day_unr_pnl_in_base_cur,
       dpd.pnl_in_base_cur unrealized_pnl_in_base_cur,
       dpd.trade_day_pnl_in_base_cur  PnL_change_in_Base_Currency,
       dpd.base_cur_id,
       dpd.base_cur_code,
       dpd.base_qty_unit base_quantity_uom,
        dpd.average_from_date Average_Period_From,
       dpd.average_to_date   Average_Period_to,
       dpd.premium_discount Premium,
       dpd.premium_discount_price_unit_id Premium_price_unit,
       dpd.clearer_comm_amt Commision_Value,
       dpd.clearer_comm_cur_code Commission_Value_Currency,
       dpd.expiry_date,
       dpd.prompt_date,
       dpd.dr_id_name prompt_details,
       to_char( dpd.prompt_date ,'Mon-YYYY') Prompt_Month_Year,
       to_char(dpd.prompt_date ,'YYYY') Prompt_Year
  from dpd_derivative_pnl_daily@eka_eoddb dpd,
       tdc_trade_date_closure@eka_eoddb   tdc,
       pdm_productmaster        pdm,
       ak_corporate                       akc,
       cm_currency_master             cm_corp
 where dpd.pnl_type = 'Unrealized'
   and dpd.process_id = tdc.process_id
   and dpd.corporate_id = tdc.corporate_id
   and dpd.derivative_prodct_id= pdm.product_id
   and dpd.corporate_id = akc.corporate_id
   and akc.is_active = 'Y'
   and cm_corp.cur_id = akc.base_cur_id
   and tdc.process = 'EOD'
union all
select cpd.corporate_id,
       cpd.corporate_name,
       pdm.product_type_id product_type,
       cpd.profit_center_id,
       cpd.profit_center_short_name profit_center,
       cpd.strategy_id,
       cpd.strategy_name,
       'NA' product_id,
       'NA' product_name,
       'NA' quality_id,
       'NA' quality_name,
       cpd.eod_trade_date eod_date,
       'Fx' position_type,
       'Fx  ' || cpd.home_cur_buy_sell position_sub_type,
       cpd.ct_ref_no contract_ref_no,
       ct.external_ref_no external_ref_no,
       cpd.trade_date issue_trade_date,
       'NA' cp_id,
       'NA' cp_name,
       pym.payment_term,
       dpm.purpose_name derivative_purpose,
       'NA' option_type,
       0 strike_price,
       'NA' strike_price_unit,
       'NA' allocated_phy_refno,
       cm_group_cur.cur_code,
       cm_corp.cur_code corporate_base_currency,
       (case
         when cpd.home_cur_buy_sell = 'Sell' then
          -1
         else
          1
       end) * cpd.fx_currency_amount contract_quantity,
       cpd.fx_currency contract_quantity_uom,
       (case
         when cpd.home_cur_buy_sell = 'Sell' then
          -1
         else
          1
       end) * cpd.home_currency_amount quantity_in_base_uom,
       0 quantity_in_lots,
       cpd.original_exchange_rate contract_price,
       cpd.fx_currency || ' to ' || cpd.home_currency trade_price_unit,
       cpd.instrument_id valuation_instrument_id,
       cpd.instrument_name valuation_instrument,
       cpd.currency_def_id derivative_def_id,
       cpd.derivative_name derivative_def_name,
       'NA' valuation_month,
       cpd.prompt_date value_date,
       cpd.market_exchange_rate m2m_settlement_price,
       cpd.market_exchange_rate net_settlement_price,
       cpd.fx_currency || ' to ' || cpd.home_currency settlement_price_unit,
       null market_value_in_val_ccy,
       cpd.home_cur_id market_value_cur_id,
       cpd.home_currency market_value_cur_code,
       null prev_day_unr_pnl_in_base_cur,
       cpd.pnl_value_in_home_currency unrealized_pnl_in_base_cur,
       null PnL_change_in_Base_Currency,
       cpd.home_cur_id base_cur_id,
       cpd.home_currency base_cur_code,
       cpd.home_currency base_quantity_uom,
       null Average_Period_From,
       null Average_Period_to,
       null Premium,
       'NA' Premium_price_unit,
       null Commision_Value,
       'NA' Commission_Value_Currency,
       null expiry_date,
       cpd.prompt_date,
       null prompt_details,
       to_char( cpd.prompt_date ,'Mon-YYYY') Prompt_Month_Year,
       to_char(cpd.prompt_date ,'YYYY') Prompt_Year
  from cpd_currency_pnl_daily@eka_eoddb        cpd,
       tdc_trade_date_closure@eka_eoddb        tdc,
       ct_currency_trade@eka_eoddb             ct,
       pym_payment_terms_master@eka_eoddb      pym,
       dpm_derivative_purpose_master@eka_eoddb dpm,
       ak_corporate@eka_eoddb                  ak,
       gcd_groupcorporatedetails@eka_eoddb     gcd_group_id,
       cm_currency_master@eka_eoddb            cm_group_cur,
       CM_CURRENCY_MASTER                      cm_corp,
       pdm_productmaster@eka_eoddb             pdm
 where upper(cpd.pnl_type) = 'UNREALIZED'
   and cpd.process_id = tdc.process_id
   and cpd.corporate_id = tdc.corporate_id
   and ct.internal_treasury_ref_no = cpd.ct_internal_ref_no
   and ct.process_id = cpd.process_id
   and pym.payment_term_id(+) = ct.payment_terms_id
   and dpm.purpose_id = ct.purpose_id
   and tdc.process = 'EOD'
   and cpd.corporate_id = ak.corporate_id
   and ak.corporate_id = tdc.corporate_id
   and gcd_group_id.groupid = ak.groupid
   and cm_group_cur.cur_id = gcd_group_id.group_cur_id
   and ak.base_cur_id = cm_corp.cur_id
   and cpd.product_name=pdm.product_desc
/
