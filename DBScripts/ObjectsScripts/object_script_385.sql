drop materialized view MV_FACT_BROKER_MARGIN_UTIL;
drop table MV_FACT_BROKER_MARGIN_UTIL;
create materialized view MV_FACT_BROKER_MARGIN_UTIL
refresh force on demand
as
select tdc.process_id,
       tdc.trade_date eod_date,
       tdc.corporate_id,
       tdc.process eod_eom_flag,
       bmu.corporate_name,
       bmu.broker_profile_id,
       bmu.broker_name,
       bmu.instrument_id,
       bmu.instrument_name,
       bmu.exchange_id,
       bmu.exchange_name,
       bmu.product_name,
       bmu.margin_cur_id,
       bmu.margin_cur_code,
       bmu.initial_margin_limit,
       bmu.current_credit_limit,
       bmu.variation_margin_limit,
       bmu.maintenance_margin,
       bmu.margin_calculation_method,
       bmu.base_cur_id,
       bmu.base_cur_code,
       bmu.fx_rate_margin_cur_to_base_cur,
       bmu.initial_margin_limit_in_base,
       bmu.current_credit_limit_in_base,
       bmu.variation_margin_limit_in_base,
       bmu.maintenance_margin_in_base,
       bmu.no_of_lots,
       bmu.net_no_of_lots,
       bmu.gross_no_of_lots,
       bmu.initial_margin_rate_cur_id,
       bmu.initial_margin_rate_cur_code,
       bmu.initial_margin_rate,
       bmu.initial_margin_requirement,
       bmu.fx_rate_imr_cur_to_base_cur,
       bmu.initial_margin_req_in_base,
       bmu.under_over_utilized_im,
       bmu.under_over_utilized_im_flag,
       bmu.trade_value_in_base,
       bmu.market_value_in_base,
       bmu.open_no_of_lots,
       bmu.lot_size,
       bmu.lot_size_unit,
       bmu.variation_margin_requirement,
       bmu.under_over_utilized_vm,
       bmu.under_over_utilized_vm_flag,
       bmu.section_name,
       bmu.prev_imr_in_base,
       bmu.prev_vmr_in_base,
       bmu.change_in_imr,
       bmu.change_in_vmr,
       bmu.im_head_room,
       bmu.vm_head_room,
       bmu.prev_eod_date
  from bmu_broker_margin_utilization@eka_eoddb bmu,
       tdc_trade_date_closure@eka_eoddb        tdc
 where bmu.corporate_id = tdc.corporate_id
   and bmu.process_id = tdc.process_id;


DROP MATERIALIZED VIEW MV_FACT_DERIVATIVE_UNREALIZED;
DROP TABLE MV_FACT_DERIVATIVE_UNREALIZED;
create materialized view MV_FACT_DERIVATIVE_UNREALIZED
refresh force on demand
as
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
       tdc.process eod_eom_flag,
       'Derivatives' position_type,
       dpd.instrument_type || ' ' || (case
         when dpd.trade_type = 'Buy' then
          'Long'
         else
          'Short'
       end) position_sub_type,
       dpd.derivative_ref_no contract_ref_no,
       dpd.external_ref_no,
       dpd.trade_date issue_trade_date,
       nvl(dpd.clearer_profile_id, dpd.cp_profile_id) cp_id,
       nvl(dpd.clearer_name, dpd.cp_name) cp_name,
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
       dpd.qty_sign * dpd.open_quantity contract_quantity,
       dpd.quantity_unit contract_quantity_uom,
       dpd.qty_sign * dpd.trade_qty_in_exch_unit quantity_in_base_uom,
       dpd.open_lots quantity_in_lots,
       dpd.trade_price contract_price,
       dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
       dpd.trade_price_weight_unit trade_price_unit,
       dpd.instrument_id valuation_instrument_id, --valuation_instument_id
       dpd.instrument_name valuation_instrument,
       dpd.derivative_def_id,
       dpd.derivative_def_name,
       to_char(nvl(dpd.period_date, dpd.prompt_date), 'Mon-yyyy') valuation_month,
       nvl(dpd.period_date, dpd.prompt_date) value_date,
       dpd.settlement_price m2m_settlement_price,
       dpd.settlement_price net_settlement_price,
       dpd.sett_price_cur_code || '/' || dpd.sett_price_weight ||
       dpd.sett_price_weight_unit settlement_price_unit,
       dpd.market_value_in_trade_cur market_value_in_val_ccy, -- used trade cur code, as mv convetred into trade currency and stored
       dpd.trade_main_cur_id market_value_cur_id,
       dpd.trade_main_cur_code market_value_cur_code,
       dpd.prev_day_unr_pnl_in_base_cur,
       dpd.pnl_in_base_cur unrealized_pnl_in_base_cur,
       dpd.trade_day_pnl_in_base_cur pnl_change_in_base_currency,
       dpd.base_cur_id,
       dpd.base_cur_code,
       dpd.base_qty_unit base_quantity_uom,
       dpd.average_from_date average_period_from,
       dpd.average_to_date average_period_to,
       dpd.premium_discount premium,
       (case
         when dpd.pd_price_cur_code is not null then
          dpd.pd_price_cur_code || '/' || dpd.pd_price_weight ||
          dpd.pd_price_weight_unit
         else
          'NA'
       end) premium_price_unit,
       dpd.clearer_comm_amt commision_value,
       dpd.clearer_comm_cur_code commission_value_currency,
       dpd.expiry_date,
       dpd.prompt_date,
       dpd.dr_id_name prompt_details,
       to_char((case
                 when dpd.period_date is null then
                  (case
                 when dpd.period_month is not null and dpd.period_year is not null then
                  to_date('01-' || dpd.period_month || '-' || dpd.period_year,
                          'dd-Mon-yyyy')
                 else
                  dpd.prompt_date
               end) else dpd.period_date end), 'Mon-YYYY') prompt_month_year,
       to_char((case
                 when dpd.period_date is null then
                  (case
                 when dpd.period_month is not null and dpd.period_year is not null then
                  to_date('01-' || dpd.period_month || '-' || dpd.period_year,
                          'dd-Mon-yyyy')
                 else
                  dpd.prompt_date
               end) else dpd.period_date end), 'YYYY') prompt_year,
       msa.attribute_value_1,
       msa.attribute_value_2,
       msa.attribute_value_3,
       msa.attribute_value_4,
       msa.attribute_value_5,
       dpd.fixed_avg_price,
       dpd.unfixed_avg_price,
       dpd.clearer_comm_in_base,
       dpd.clearer_exch_rate clearer_cur_to_base,
       dpd.trade_value_in_base,
       dpd.market_value_in_base,
       dpd.trade_type,
       dpd.instrument_type,
       dpd.instrument_sub_type,
       dpd.pnl_in_trade_cur,
       dpd.trade_cur_code,
       dpd.trade_cur_to_base_exch_rate      
  from dpd_derivative_pnl_daily@eka_eoddb dpd,
       tdc_trade_date_closure@eka_eoddb   tdc,
       pdm_productmaster                  pdm,
       ak_corporate                       akc,
       cm_currency_master                 cm_corp,
       mv_bi_strategy_attribute           msa
 where dpd.pnl_type = 'Unrealized'
   and dpd.process_id = tdc.process_id
   and dpd.corporate_id = tdc.corporate_id
   and dpd.derivative_prodct_id = pdm.product_id
   and dpd.corporate_id = akc.corporate_id
   and akc.is_active = 'Y'
   and cm_corp.cur_id = akc.base_cur_id
      -- and tdc.process = 'EOD'
   and dpd.strategy_id = msa.startegy_id(+)
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
       tdc.process eod_eom_flag,
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
       null pnl_change_in_base_currency,
       cpd.home_cur_id base_cur_id,
       cpd.home_currency base_cur_code,
       cpd.home_currency base_quantity_uom,
       null average_period_from,
       null average_period_to,
       null premium,
       'NA' premium_price_unit,
       null commision_value,
       'NA' commission_value_currency,
       null expiry_date,
       cpd.prompt_date,
       null prompt_details,
       to_char(cpd.prompt_date, 'Mon-YYYY') prompt_month_year,
       to_char(cpd.prompt_date, 'YYYY') prompt_year,
       msa.attribute_value_1,
       msa.attribute_value_2,
       msa.attribute_value_3,
       msa.attribute_value_4,
       msa.attribute_value_5,
       0 fixed_avg_price,
       0 unfixed_avg_price,
       0 clearer_comm_in_base,
       0 clearer_cur_to_base,
       0 trade_value_in_base,
       0 market_value_in_base,
       'NA' trade_type,
       'Forward' instrument_type,
       'NA' instrument_sub_type,
       null pnl_in_trade_cur,
       null trade_cur_code,
       null trade_cur_to_base_exch_rate 
       
  from cpd_currency_pnl_daily@eka_eoddb        cpd,
       tdc_trade_date_closure@eka_eoddb        tdc,
       ct_currency_trade@eka_eoddb             ct,
       pym_payment_terms_master@eka_eoddb      pym,
       dpm_derivative_purpose_master@eka_eoddb dpm,
       ak_corporate@eka_eoddb                  ak,
       gcd_groupcorporatedetails@eka_eoddb     gcd_group_id,
       cm_currency_master@eka_eoddb            cm_group_cur,
       cm_currency_master                      cm_corp,
       pdm_productmaster@eka_eoddb             pdm,
       mv_bi_strategy_attribute                msa
 where upper(cpd.pnl_type) = 'UNREALIZED'
   and cpd.process_id = tdc.process_id
   and cpd.corporate_id = tdc.corporate_id
   and ct.internal_treasury_ref_no = cpd.ct_internal_ref_no
   and ct.process_id = cpd.process_id
   and pym.payment_term_id(+) = ct.payment_terms_id
   and dpm.purpose_id = ct.purpose_id
      -- and tdc.process = 'EOD'
   and cpd.corporate_id = ak.corporate_id
   and ak.corporate_id = tdc.corporate_id
   and gcd_group_id.groupid = ak.groupid
   and cm_group_cur.cur_id = gcd_group_id.group_cur_id
   and ak.base_cur_id = cm_corp.cur_id
   and cpd.product_name = pdm.product_desc
   and cpd.strategy_id = msa.startegy_id(+)
/
