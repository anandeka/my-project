DROP  MATERIALIZED VIEW MV_FACT_UNREALIZED;
CREATE MATERIALIZED VIEW MV_FACT_UNREALIZED 
TABLESPACE EKA_DATA
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 2012/03/26 12:57 (Formatter Plus v4.8.8) */
SELECT mvp.corporate_id, mvp.corporate_name, mvp.product_type,
       mvp.profit_center_id, mvp.profit_center, mvp.strategy_id,
       mvp.strategy_name, mvp.product_id, mvp.product_name, mvp.quality_id,
       mvp.quality_name, mvp.eod_date,
       TO_CHAR (mvp.eod_date, 'dd-Mon-yyyy') eod_date_str,
       mvp.position_type || ' - ' || mvp.position_sub_type position_type_id,
       mvp.position_type, mvp.position_sub_type, mvp.contract_ref_no,
       mvp.external_ref_no, mvp.issue_trade_date, mvp.cp_id, mvp.cp_name,
       mvp.incoterm, mvp.payment_term, 'NA' derivative_purpose,
       'NA' option_type, 0 strike_price, 'NA' strike_price_unit,
       'NA' allocated_phy_refno, mvp.group_currency, mvp.corp_currency,
       mvp.contract_quantity, mvp.contract_quantity_uom,
       mvp.quantity_in_base_uom, mvp.base_quantity_uom,
       NVL (mvp.quantity_in_lots, 0) quantity_in_lots,
       NVL (mvp.contract_price, 0) contract_price,
       DECODE (mvp.contract_price_unit,
               '/', 'NA',
               NULL, 'NA',
               mvp.contract_price_unit
              ) contract_price_unit,
       mvp.net_contract_value,
       mvp.net_contract_premium_value contract_premium_value,
       mvp.net_sc_cost secondary_cost,
       mvp.contract_treatment_charge contract_treatment_charge,
       mvp.contract_refining_charge contract_refining_charge,
       mvp.contract_penalty_charge contract_penalty_charge,
       mvp.valuation_instrument_id, mvp.valuation_instrument,
       mvp.derivative_def_id, mvp.derivative_def_name, mvp.valuation_month,
       mvp.value_date, mvp.total_cost_in_m2m_currency, mvp.m2m_currency,
       mvp.expected_cog_net_sale_value,
       NVL (mvp.m2m_settlement_price, 0) m2m_settlement_price,
       mvp.settlement_price_unit,
          mvp.valuation_country_id
       || ' - '
       || mvp.valuation_city_id comb_valuation_loc_id,
       mvp.valuation_city_id, mvp.valuation_city, mvp.valuation_country_id,
       mvp.valuation_country, mvp.m2m_basis m2m_basis,
       mvp.m2m_loc_incoterm_deviation,
       mvp.m2m_quality_premium m2m_quality_premium,
       mvp.m2m_product_premium m2m_product_premium,
       mvp.m2m_treatment_charge m2m_treatment_charge,
       mvp.m2m_refining_charge m2m_refining_charge,
       mvp.m2m_penality_charge m2m_penality_charge, mvp.net_settlement_price,
       mvp.market_value_in_val_ccy, mvp.market_value_cur_id,
       mvp.market_value_cur_code, mvp.prev_day_unr_pnl_in_base_cur,
       mvp.unrealized_pnl_in_base_cur, mvp.pnl_change_in_base_cur,
       mvp.base_cur_id, mvp.base_cur_code,
       to_number(TO_CHAR (mvp.eod_date, 'yyyymmdd')) DATE_TO_NUMBER
  FROM mv_fact_physical_unrealized mvp
UNION ALL
SELECT mvd.corporate_id, mvd.corporate_name, mvd.product_type,
       mvd.profit_center_id, mvd.profit_center, mvd.strategy_id,
       mvd.strategy_name, mvd.product_id, mvd.product_name, mvd.quality_id,
       NVL (mvd.quality_name, 'NA') quality_name, mvd.eod_date,
       TO_CHAR (mvd.eod_date, 'dd-Mon-yyyy') eod_date_str,
       mvd.position_type || ' - ' || mvd.position_sub_type position_type_id,
       mvd.position_type, mvd.position_sub_type, mvd.contract_ref_no,
       mvd.external_ref_no, mvd.issue_trade_date, mvd.cp_id, mvd.cp_name,
       'NA' incoterm, NVL (mvd.payment_term, 'NA') payment_term,
       mvd.derivative_purpose, NVL (mvd.option_type, 'NA') option_type,
       DECODE (mvd.strike_price, NULL, 0, mvd.strike_price) strike_price,
       DECODE (mvd.strike_price_unit,
               '/', 'NA',
               NULL, 'NA',
               mvd.strike_price_unit
              ) strike_price_unit,
       mvd.allocated_phy_refno, mvd.group_cur_code group_currency,
       mvd.base_cur_code corp_currency, mvd.contract_quantity,
       mvd.contract_quantity_uom, mvd.quantity_in_base_uom,
       mvd.base_quantity_uom, NVL (mvd.quantity_in_lots, 0) quantity_in_lots,
       NVL (mvd.contract_price, 0) contract_price,
       DECODE (mvd.trade_price_unit,
               '/', 'NA',
               NULL, 'NA',
               mvd.trade_price_unit
              ) contract_price_unit,
       0 net_contract_value, 0 contract_premium_value, 0 secondary_cost,
       0 contract_treatment_charge, 0 contract_refining_charge,
       0 contract_penalty_charge, mvd.valuation_instrument_id,
       mvd.valuation_instrument, mvd.derivative_def_id,
       mvd.derivative_def_name, mvd.valuation_month, mvd.value_date,
       NULL total_cost_in_m2m_currency, NULL m2m_currency,
       NULL expected_cog_net_sale_value, mvd.m2m_settlement_price,
       mvd.settlement_price_unit, 'NA' comb_valuation_loc_id,
       'NA' valuation_city_id, 'NA' valuation_city, 'NA' valuation_country_id,
       'NA' valuation_country, 0 m2m_basis, 0 m2m_loc_incoterm_deviation,
       0 m2m_quality_premium, 0 m2m_product_premium, 0 m2m_treatment_charge,
       0 m2m_refining_charge, 0 m2m_penality_charge, mvd.net_settlement_price,
       0 market_value_in_val_ccy, mvd.market_value_cur_id,
       mvd.market_value_cur_code, 0 prev_day_unr_pnl_in_base_cur,
       mvd.unrealized_pnl_in_base_cur, 0 pnl_change_in_base_cur,
       mvd.base_cur_id, mvd.base_cur_code,
       to_number(TO_CHAR (mvd.eod_date, 'yyyymmdd')) DATE_TO_NUMBER
  FROM mv_fact_derivative_unrealized mvd;


