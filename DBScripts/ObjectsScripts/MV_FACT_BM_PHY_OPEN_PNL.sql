DROP MATERIALIZED VIEW MV_FACT_BM_PHY_OPEN_PNL
/
CREATE MATERIALIZED VIEW MV_FACT_BM_PHY_OPEN_PNL
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
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
       poud.contract_ref_no || ' ('|| poud.delivery_item_no || ')' cont_item_ref_no,
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
