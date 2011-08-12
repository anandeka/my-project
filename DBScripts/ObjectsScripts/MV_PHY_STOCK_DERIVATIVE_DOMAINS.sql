drop table v_dim_time_date_data;
drop materialized view v_dim_time_date_data;
create materialized view v_dim_time_date_data
refresh force on commit
as
select dim.instrument_id,
       dd.date_id,
       dd.mnth_id,
       dd.mnth_nm,
       to_date(dd.date_id, 'dd/mm/yyyy') date_data,
       to_char(to_date(dd.date_id, 'dd/mm/yyyy'), 'Dy') day_data
  from dim_time                  dd,
       dim_der_instrument_master dim,
       irm_instrument_type_master irm
 where dd.year in ('2010', '2011', '2012')
   and dim.is_active = 'Y'
   and dim.is_deleted = 'N'
   and dim.is_currency_curve = 'N'
   and dim.instrument_type_id = irm.instrument_type_id
   and irm.instrument_type in('Future','Forward')
/

drop materialized view MV_FACT_BM_PHY_OPEN_PNL;
drop table MV_FACT_BM_PHY_OPEN_PNL;
create materialized view MV_FACT_BM_PHY_OPEN_PNL
refresh force on demand
as
select poud.corporate_id corporate_id,
       poud.profit_center_id,
       poud.profit_center_name profit_center,
       poud.strategy_id,
       poud.strategy_name strategy,
       poud.product_id,
       poud.product_name product,
       poud.quality_id,
       poud.quality_name quality,
       poud.eod_trade_date eod_date,
       'Physical' pnl_type,
       'Physical Open Contract' position_type,
       poud.contract_type trade_type,
       poud.internal_contract_item_ref_no cont_item_ref_no,
       poud.contract_issue_date contract_issue_date,
       poud.incoterm_id,
       poud.incoterm incoterm,
       poud.cp_profile_id,
       poud.cp_name counter_party,
       --poud.valuation_dr_id_name,
       poud.valuation_month valuation_month_year,
       md.valuation_city_id valuation_city_id,
       md.valuation_location valuation_city,
       md.valuation_location_country,
       poud.qty_in_base_unit quantity,
       poud.base_qty_unit_id,
       poud.base_qty_unit,
       poud.contract_price contract_price,
       poud.price_unit_cur_code || '/' || poud.price_unit_weight ||
       poud.price_unit_weight_unit contract_price_unit,
       poud.contract_value_in_price_cur contract_value,
       poud.price_main_cur_id contract_value_cur_id,
       poud.price_main_cur_code contract_value_cur_code,
       poud.sc_in_base_cur secondary_cost_in_base,
       poud.expected_cog_net_sale_value net_sale,
       md.m2m_sett_price_available_date settlement_price_avl_date,
       md.valuation_basis m2m_basics,
       poud.contract_premium_value,
       md.m2m_settlement_price,
       md.m2m_price_unit_cur_code || '/' || md.m2m_price_unit_weight ||
       md.m2m_price_unit_weight_unit m2m_price_unit,
       md.m2m_quality_premium,
       md.m2m_product_premium,
       md.m2m_loc_incoterm_deviation m2m_location_diff,
       poud.m2m_amt market_value,
       poud.expected_cog_net_sale_value total_cost_base_cur,
       poud.unrealized_pnl_in_base_cur unrealized_pnl_in_base_cur,
       poud.trade_day_pnl_in_base_cur,
       poud.prev_day_unr_pnl_in_base_cur
  from poud_phy_open_unreal_daily@eka_eoddb poud,
       md_m2m_daily@eka_eoddb md,
       tdc_trade_date_closure@eka_eoddb tdc,
       (select tdc.corporate_id,
               max(tdc.trade_date) max_date
          from tdc_trade_date_closure@eka_eoddb tdc
         where tdc.process = 'EOD'
         group by tdc.corporate_id) tdc_max
 where poud.process_id = tdc.process_id
   and poud.corporate_id = tdc.corporate_id
   and poud.md_id = md.md_id
   and poud.corporate_id = md.corporate_id
   and poud.process_id = md.process_id
   and md.process_id = tdc.process_id
   and md.corporate_id = tdc.corporate_id
   and tdc_max.corporate_id = md.corporate_id
   and poud.unrealized_type = 'Unrealized'
   and tdc.process = 'EOD'
   and tdc.corporate_id = tdc_max.corporate_id
   and tdc.trade_date = tdc_max.max_date
/
drop materialized view MV_FACT_BM_PHY_STOCK_PNL;
drop table MV_FACT_BM_PHY_STOCK_PNL;
create materialized view MV_FACT_BM_PHY_STOCK_PNL
refresh force on demand
as
select psu.corporate_id corporate_id,
       akc.corporate_name,
       psu.profit_center_id,
       cpc.profit_center_name profit_center,
       psu.strategy_id,
       psu.strategy_name strategy,
       psu.product_id,
       psu.product_name product,
       psu.quality_id,
       psu.quality_name quality,
       tdc.trade_date eod_date,
       'Physical' pnl_type,
       'Physical Stock  Contract' position_type,
       psu.contract_type trade_type,
       psu.internal_contract_item_ref_no cont_item_ref_no,
       psu.valuation_month valuation_month_year,
       md.valuation_city_id valuation_city_id,
       md.valuation_location valuation_city,
       md.valuation_location_country,
       psu.qty_in_base_unit quantity,
       psu.qty_unit_id base_qty_unit_id,
       psu.qty_unit base_qty_unit,
       psu.contract_price,
       psu.price_unit_cur_code || '/' || psu.price_unit_weight ||
       psu.price_unit_weight contract_price_unit,
       psu.contract_value_in_price_cur contract_value,
       psu.contract_price_cur_id contract_value_cur_id,
       psu.contract_price_cur_code contract_value_cur_code,
       psu.sc_in_base_cur sc_cost_in_base_cur,
       psu.expected_cog_in_base_cur net_sale,
       md.m2m_sett_price_available_date settlement_price_avl_date,
       md.valuation_basis m2m_basics,
       psu.contract_premium_value,
       md.m2m_settlement_price,
       md.m2m_price_unit_cur_code || '/' || md.m2m_price_unit_weight ||
       md.m2m_price_unit_weight_unit m2m_price_unit,
       md.m2m_quality_premium,
       md.m2m_product_premium,
       md.m2m_loc_incoterm_deviation m2m_location_diff,
       psu.m2m_amt market_value,
       psu.expected_cog_in_base_cur total_cost_base_cur,
       psu.pnl_in_base_cur unrealized_pnl_in_base_cur,
       psu.trade_day_pnl_in_base_cur,
       psu.prev_day_pnl_in_base_cur
  from psu_phy_stock_unrealized@eka_eoddb psu,
       tdc_trade_date_closure@eka_eoddb tdc,
       cpc_corporate_profit_center@eka_eoddb cpc,
       ak_corporate@eka_eoddb                akc,
       md_m2m_daily@eka_eoddb md,
       (select tdc.corporate_id,
               max(tdc.trade_date) max_date
          from tdc_trade_date_closure@eka_eoddb tdc
         where tdc.process = 'EOD'
         group by tdc.corporate_id) tdc_max
 where psu.process_id = tdc.process_id
   and psu.corporate_id = tdc.corporate_id
   and psu.pnl_type = 'Unrealized'
   and psu.profit_center_id = cpc.profit_center_id
   and psu.corporate_id = cpc.corporateid
   and psu.md_id = md.md_id
   and psu.process_id = md.process_id
   and psu.corporate_id = md.corporate_id
   and psu.corporate_id = akc.corporate_id
   and tdc.process = 'EOD'
   and tdc.corporate_id = tdc_max.corporate_id
   and tdc.trade_date = tdc_max.max_date
/
drop materialized view MV_FACT_DERIVATIVE_UNREALIZED;
drop table MV_FACT_DERIVATIVE_UNREALIZED;
create materialized view MV_FACT_DERIVATIVE_UNREALIZED
refresh force on demand
as
select dpd.corporate_id,
       dpd.profit_center_short_name profit_center,
       dpd.strategy_desc,
       dpd.product_name,
       dpd.eod_trade_date,
       'Derivative' pl_type,
       dpd.instrument_type,
       dpd.deal_type_display_name derivative_type, --
       dpd.trade_type trade_type,
       dpd.derivative_ref_no trade_ref_no,
       dpd.trade_date,
       dpd.expiry_date,
       dpd.clearer_name,
       dpd.period_month || '-' || dpd.period_year valuation_month_year,
       dpd.period_date value_date,
       dpd.total_quantity derivative_qty,
       dpd.quantity_unit,
       to_char(dpd.prompt_date, 'Mon-YYYY') delivary_month,
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
       dpd.trade_price,
       dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
       dpd.trade_price_weight_unit trade_price_unit,
       dpd.settlement_price,
       dpd.sett_price_cur_code || '/' || dpd.sett_price_weight ||
       dpd.sett_price_weight_unit settlement_price_unit,
       dpd.open_lots open_qty_in_lots,
       dpd.pnl_in_base_cur unrealized_pnl_base_currency
  from dpd_derivative_pnl_daily@eka_eoddb dpd,
       tdc_trade_date_closure@eka_eoddb tdc,
       (select tdc.corporate_id,
               max(tdc.trade_date) max_date
          from tdc_trade_date_closure@eka_eoddb tdc
         where tdc.process = 'EOD'
         group by tdc.corporate_id) tdc_max
 where dpd.pnl_type = 'Unrealized'
   and dpd.process_id = tdc.process_id
   and dpd.corporate_id = tdc.corporate_id
   and tdc.process = 'EOD'
   and tdc.corporate_id = tdc_max.corporate_id
   and tdc.trade_date = tdc_max.max_date;
/
drop materialized view MV_FACT_DERIVATIVE_REALIZED;
drop table MV_FACT_DERIVATIVE_REALIZED;
create materialized view MV_FACT_DERIVATIVE_REALIZED
refresh force on demand
as
--Daily Derivative realised pnl
select dpd.corporate_name,
       dpd.profit_center_name profit_center_name,
       dpd.strategy_desc strategy,
       dpd.product_name,
       dpd.eod_trade_date,
       dpd.trade_type, --future/forward added
       dpd.trade_date trade_date,
       dpd.derivative_ref_no,
       dpd.expiry_date,
       dpd.clearer_name,
       dpd.deal_type_display_name derivative_type,
       dpd.period_date, --
       to_char(dpd.prompt_date, 'Mon-yyyy') delivery_month,
       (case
         when dpd.instrument_type = 'Option Put' then
          'Put'
         when dpd.instrument_type = 'Option Call' then
          'Call'
         else
          ''
       end) option_type,
       dpd.strike_price,
       dpd.strike_price_cur_code || '/' || dpd.strike_price_weight ||
       dpd.strike_price_weight_unit strike_price_unit,
       dpd.trade_price,
       dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
       dpd.trade_price_weight_unit trade_price_unit,
       dpd.settlement_price,
       dpd.sett_price_cur_code || '/' || dpd.sett_price_weight ||
       dpd.sett_price_weight_unit settlement_price_unit,
       dpd.open_lots open_qty_in_lots,
       dpd.pnl_in_base_cur unrealized_pnl_base_currency
 from dpd_derivative_pnl_daily@eka_eoddb dpd,
       tdc_trade_date_closure@eka_eoddb tdc,
       (select tdc.corporate_id,
               max(tdc.trade_date) max_date
          from tdc_trade_date_closure@eka_eoddb tdc
         where tdc.process = 'EOD'
         group by tdc.corporate_id) tdc_max
 where dpd.pnl_type = 'Realized'
   and dpd.process_id = tdc.process_id
   and dpd.corporate_id = tdc.corporate_id
   and tdc.process = 'EOD'
   and tdc.corporate_id = tdc_max.corporate_id
   and tdc.trade_date = tdc_max.max_date
union all
select dpd.corporate_name,
       dpd.profit_center_name profit_center_name,
       dpd.strategy_desc strategy,
       dpd.product_name,
       dpd.eod_trade_date,
       dpd.trade_type,
       dpd.trade_date trade_date,
       dpd.derivative_ref_no,
       dpd.expiry_date,
       dpd.clearer_name,
       dpd.deal_type_display_name derivative_type,
       dpd.period_date,
       to_char(dpd.prompt_date, 'Mon-yyyy') delivery_month,
       (case
         when dpd.instrument_type = 'Option Put' then
          'Put'
         when dpd.instrument_type = 'Option Call' then
          'Call'
         else
          ''
       end) option_type,
       dpd.strike_price,
       dpd.strike_price_cur_code || '/' || dpd.strike_price_weight ||
       dpd.strike_price_weight_unit strike_price_unit,
       dpd.trade_price,
       dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
       dpd.trade_price_weight_unit trade_price_unit,
       dpd.settlement_price,
       dpd.sett_price_cur_code || '/' || dpd.sett_price_weight ||
       dpd.sett_price_weight_unit settlement_price_unit,
       dpd.open_lots open_qty_in_lots,
       dpd.pnl_in_base_cur unrealized_pnl_base_currency
 from dpd_derivative_pnl_daily@eka_eoddb dpd,
       tdc_trade_date_closure@eka_eoddb tdc,
       (select tdc.corporate_id,
               max(tdc.trade_date) max_date
          from tdc_trade_date_closure@eka_eoddb tdc
         where tdc.process = 'EOD'
         group by tdc.corporate_id) tdc_max
 where dpd.pnl_type = 'Reverse Realized'
   and dpd.process_id = tdc.process_id
   and dpd.corporate_id = tdc.corporate_id
   and tdc.process = 'EOD'
   and tdc.corporate_id = tdc_max.corporate_id
   and tdc.trade_date = tdc_max.max_date
/   
