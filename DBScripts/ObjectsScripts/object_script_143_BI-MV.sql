CREATE OR REPLACE view  v_dim_pdm_productmaster (product_id,
                                                      product_desc)
AS
   SELECT pdm.product_id, pdm.product_desc
     FROM pdm_productmaster pdm
    WHERE pdm.is_deleted = 'N';

DROP MATERIALIZED VIEW MV_DIM_PDM_PRODUCTMASTER ;
CREATE MATERIALIZED VIEW MV_DIM_PDM_PRODUCTMASTER 
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
REFRESH FORCE
START WITH TO_DATE('11-Nov-2011 12:06:14','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE+10/1440 
WITH PRIMARY KEY
AS 
/* Formatted on 2011/11/11 12:02 (Formatter Plus v4.8.8) */
SELECT *
FROM v_dim_pdm_productmaster;

COMMENT ON MATERIALIZED VIEW MV_DIM_PDM_PRODUCTMASTER IS 'snapshot table for snapshot MV_DIM_PDM_PRODUCTMASTER';

DROP MATERIALIZED VIEW MV_FACT_PHY_UNREAL_FIXED_PRICE;
DROP TABLE MV_FACT_PHY_UNREAL_FIXED_PRICE;
CREATE MATERIALIZED VIEW MV_FACT_PHY_UNREAL_FIXED_PRICE 
AS 
SELECT poud.corporate_id, poud.corporate_name,
       pdm.product_type_id product_type, poud.profit_center_id,
       poud.profit_center_short_name profit_center, poud.strategy_id,
       poud.strategy_name, poud.product_id product_id,
       poud.product_name product_name, poud.quality_id quality_id,
       poud.quality_name quality_name, poud.eod_trade_date eod_date,
       'Physical' position_type,
       (CASE
           WHEN poud.contract_type = 'P'
              THEN 'Open Purchase'
           ELSE 'Open Sales'
        END
       ) position_sub_type,
          poud.contract_ref_no
       || '('
       || poud.delivery_item_no
       || ')' contract_ref_no,
       'NA' external_ref_no, poud.contract_issue_date issue_trade_date,
       poud.cp_profile_id cp_id, poud.cp_name cp_name, poud.incoterm,
       poud.payment_term, poud.group_cur_code group_currency,
       poud.base_cur_code corp_currency,
         (CASE
             WHEN poud.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * poud.item_qty contract_quantity,
       poud.qty_unit contract_quantity_uom,
         (CASE
             WHEN poud.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * poud.qty_in_base_unit quantity_in_base_uom,
       0 quantity_in_lots, poud.contract_price,
          poud.price_unit_cur_code
       || '/'
       || DECODE (poud.price_unit_weight,
                  1, NULL,
                  0, NULL,
                  poud.price_unit_weight
                 )
       || poud.price_unit_weight_unit contract_price_unit,
       poud.contract_value_in_price_cur net_contract_value, --in base currency
       poud.contract_premium_value net_contract_premium_value,
       poud.sc_in_base_cur net_sc_cost, 0 contract_treatment_charge,
       0 contract_refining_charge, 0 contract_penalty_charge,
       md.instrument_id valuation_instrument_id,      --valuation_instument_id
       dim.instrument_name valuation_instrument,
       md.derivative_def_id derivative_def_id,
       md.derivative_def_name derivative_def_name,
       md.valuation_month valuation_month, md.valuation_date value_date,
       poud.expected_cog_in_val_cur total_cost_in_m2m_currency,
       poud.m2m_amt_cur_code m2m_currency,
       poud.expected_cog_net_sale_value expected_cog_net_sale_value,
       --m2m valuation details
       (CASE
           WHEN md.valuation_method = 'DIFFERENTIAL'
              THEN md.m2m_settlement_price
           ELSE 0
        END
       ) m2m_settlement_price,
          poud.m2m_price_cur_code
       || '/'
       || DECODE (poud.m2m_price_weight,
                  1, NULL,
                  0, NULL,
                  poud.m2m_price_weight
                 )
       || poud.m2m_price_weight_unit settlement_price_unit,
       md.valuation_city_id, md.valuation_location valuation_city,
       cim.country_id valuation_country_id,
       md.valuation_location_country valuation_country, md.m2m_diff m2m_basis,
       (  NVL (md.m2m_loc_incoterm_deviation, 0)
        + NVL (md.m2m_location_deviation, 0)
        + NVL (md.m2m_incoterm_deviation, 0)
       ) m2m_loc_incoterm_deviation,
       NVL (md.m2m_quality_premium, 0) m2m_quality_premium,
       NVL (md.m2m_product_premium, 0) m2m_product_premium,
       0 m2m_treatment_charge, 0 m2m_refining_charge, 0 m2m_penality_charge,
       poud.net_m2m_price net_settlement_price,
       poud.m2m_amt market_value_in_val_ccy,
       poud.m2m_amt_cur_id market_value_cur_id,
       poud.m2m_amt_cur_code market_value_cur_code,
       NVL (poud.prev_day_unr_pnl_in_base_cur,
            0) prev_day_unr_pnl_in_base_cur,
       NVL (poud.unrealized_pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       NVL (poud.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       poud.base_cur_id base_cur_id, poud.base_cur_code base_cur_code,
       poud.base_qty_unit base_quantity_uom
  FROM poud_phy_open_unreal_daily@eka_eoddb poud,
       md_m2m_daily@eka_eoddb md,
       dim_der_instrument_master@eka_eoddb dim,
       tdc_trade_date_closure@eka_eoddb tdc,
       cim_citymaster@eka_eoddb cim,
       qat_quality_attributes@eka_eoddb qat,
       pdm_productmaster@eka_eoddb pdm
 WHERE poud.process_id = tdc.process_id
   AND poud.md_id = md.md_id
   AND poud.process_id = md.process_id
   AND md.instrument_id = dim.instrument_id(+)
   AND md.valuation_city_id = cim.city_id
   AND poud.quality_id = qat.quality_id
   AND poud.product_id = pdm.product_id
   AND tdc.process = 'EOD'
   and poud.price_type_id <> 'Fixed'
UNION ALL
SELECT pss.corporate_id, akc.corporate_name, pdm.product_type_id product_type,
       pss.profit_center_id, cpc.profit_center_short_name profit_center,
       pss.strategy_id, pss.strategy_name, pss.product_id product_id,
       pss.product_name product_name, pss.quality_id quality_id,
       pss.quality_name quality_name, tdc.trade_date eod_date,
       'Physical' position_type,
       (CASE
           WHEN pss.section_name IN ('Shipped NTT', 'Stock NTT')
              THEN (CASE
                       WHEN pss.contract_type = 'P'
                          THEN 'Shipped but title not transferred on Purchase'
                       ELSE 'Shipped but title not transferred on Sales'
                    END
                   )
           WHEN pss.section_name IN
                         ('Shipped TT', 'Stock TT', 'Shipped IN', 'Stock IN')
              THEN (CASE
                       WHEN pss.contract_type = 'P'
                          THEN 'Inventory Purchase'
                       ELSE 'Inventory Sales'
                    END
                   )
        END
       ) position_sub_type,
       pss.gmr_ref_no || '- ' || pss.stock_ref_no contract_ref_no,
       'NA' external_ref_no, NULL issue_date, 'NA' cp_id, 'NA' cp_name,
       'NA' incoterm, 'NA' payment_term, cm.cur_code group_currency,
       pss.base_cur_code corp_currency,
         (CASE
             WHEN pss.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * pss.stock_qty contract_quantity,
       pss.qty_unit contract_quantity_uom,
         (CASE
             WHEN pss.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * pss.qty_in_base_unit quantity_in_base_uom,
       0 quantity_in_lots, pss.contract_price,
          pss.price_unit_cur_code
       || '/'
       || DECODE (pss.price_unit_weight,
                  1, NULL,
                  0, NULL,
                  pss.price_unit_weight
                 )
       || pss.price_unit_weight_unit contract_price_unit,
       pss.contract_value_in_price_cur net_contract_value,  --in base currency
       pss.contract_premium_value net_contract_premium_value,
       NVL (pss.sc_in_base_cur, 0) net_sc_cost, 0 contract_treatment_charge,
       0 contract_refining_charge, 0 contract_penalty_charge,
       md.instrument_id valuation_instrument_id,      --valuation_instument_id
       dim.instrument_name valuation_instrument,
       md.derivative_def_id derivative_def_id,
       md.derivative_def_name derivative_def_name,
       md.valuation_month valuation_month, md.valuation_date value_date,
       pss.expected_cog_in_val_cur total_cost_in_m2m_currency,
       pss.m2m_amt_cur_code m2m_currency,
       pss.expected_cog_in_base_cur expected_cog_net_sale_value,
       
       --m2m valuation details
       (CASE
           WHEN md.valuation_method = 'DIFFERENTIAL'
              THEN md.m2m_settlement_price
           ELSE 0
        END
       ) m2m_settlement_price,
       pss.m2m_price_unit_str settlement_price_unit, md.valuation_city_id,
       md.valuation_location valuation_city,
       cim.country_id valuation_country_id,
       md.valuation_location_country valuation_country, md.m2m_diff m2m_basis,
       (  NVL (md.m2m_loc_incoterm_deviation, 0)
        + NVL (md.m2m_location_deviation, 0)
        + NVL (md.m2m_incoterm_deviation, 0)
       ) m2m_loc_incoterm_deviation,
       NVL (md.m2m_quality_premium, 0) m2m_quality_premium,
       NVL (md.m2m_product_premium, 0) m2m_product_premium,
       0 m2m_treatment_charge, 0 m2m_refining_charge, 0 m2m_penality_charge,
       pss.net_m2m_price net_settlement_price,
       
       --unrealized pnl
       pss.m2m_amt market_value_in_val_ccy,
       pss.m2m_amt_cur_id market_value_cur_id,
       pss.m2m_amt_cur_code market_value_cur_code,
       NVL (pss.prev_day_pnl_in_base_cur, 0) prev_day_unr_pnl_in_base_cur,
       NVL (pss.pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       NVL (pss.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       pss.base_cur_id base_cur_id, pss.base_cur_code base_cur_code,
       pss.prod_base_unit base_quantity_uom
  FROM psu_phy_stock_unrealized@eka_eoddb pss,
       ak_corporate@eka_eoddb akc,
       gcd_groupcorporatedetails@eka_eoddb gcd,
       cpc_corporate_profit_center@eka_eoddb cpc,
       cm_currency_master@eka_eoddb cm,
       md_m2m_daily@eka_eoddb md,
       cim_citymaster@eka_eoddb cim,
       dim_der_instrument_master@eka_eoddb dim,
       tdc_trade_date_closure@eka_eoddb tdc,
       pdm_productmaster@eka_eoddb pdm
 WHERE pss.process_id = tdc.process_id
   AND pss.corporate_id = tdc.corporate_id
   AND pss.md_id = md.md_id
   AND pss.process_id = md.process_id
   AND pss.profit_center_id = cpc.profit_center_id
   AND md.instrument_id = dim.instrument_id(+)
   AND pss.corporate_id = akc.corporate_id
   AND akc.groupid = gcd.groupid
   AND gcd.group_cur_id = cm.cur_id(+)
   AND md.valuation_city_id = cim.city_id
   AND pss.product_id = pdm.product_id
   AND tdc.process = 'EOD'
   and pss.price_type_id <> 'Fixed'
UNION ALL
SELECT poud.corporate_id, poud.corporate_name,
       pdm.product_type_id product_type, poud.profit_center_id,
       poud.profit_center_short_name profit_center, poud.strategy_id,
       poud.strategy_name, poud.product_id product_id,
       poud.product_name product_name, poud.quality_id quality_id,
       poud.quality_name quality_name, poud.process_trade_date eod_date,
       'Physical' position_type,
       (CASE
           WHEN poud.contract_type = 'P'
              THEN 'Open Purchase'
           ELSE 'Open Sales'
        END
       ) position_sub_type,
          poud.contract_ref_no
       || '('
       || poud.delivery_item_no
       || ')' contract_ref_no,
       'NA' external_ref_no, poud.contract_issue_date issue_trade_date,
       poud.cp_profile_id cp_id, poud.cp_name cp_name, poud.incoterm,
       poud.payment_term, poud.group_cur_code group_currency,
       poud.base_cur_code corp_currency,
         (CASE
             WHEN poud.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * poud.item_dry_qty contract_quantity,
       poud.qty_unit contract_quantity_uom,
         (CASE
             WHEN poud.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * NVL (poud.item_dry_qty, 0)
       * NVL (ucm.multiplication_factor, 0) quantity_in_base_uom,
       0 quantity_in_lots, 0 contract_price,
       poud.contract_price_string contract_price_unit,
       poud.net_contract_prem_in_base_cur net_contract_value,
                                                            --in base currency
       0 net_contract_premium_value, poud.net_sc_in_base_cur net_sc_cost,
       NVL (poud.net_contract_treatment_charge, 0) contract_treatment_charge,
       NVL (poud.net_contract_refining_charge, 0) contract_refining_charge,
       NVL (poud.penalty_charge, 0) contract_penalty_charge,
       'NA' valuation_instrument_id,                  --valuation_instument_id
                                    'NA' valuation_instrument,
       'NA' derivative_def_id, 'NA' derivative_def_name, 'NA' valuation_month,
       NULL value_date,
       poud.expected_cog_net_sale_value total_cost_in_m2m_currency,
       poud.base_cur_code m2m_currency,                        --base currency
       poud.expected_cog_net_sale_value expected_cog_net_sale_value,
       
       --m2m valuation details
       0 m2m_settlement_price, poud.m2m_price_string settlement_price_unit,
       'NA' valuation_city_id, 'NA' valuation_city, 'NA' valuation_country_id,
       'NA' valuation_country, 0 m2m_basis,
       NVL (m2m_loc_diff_premium, 0) m2m_loc_incoterm_deviation,
       0 m2m_quality_premium, 0 m2m_product_premium,
       NVL (poud.net_m2m_treatment_charge, 0) m2m_treatment_charge,
       NVL (poud.net_m2m_refining_charge, 0) m2m_refining_charge,
       NVL (poud.m2m_penalty_charge, 0) m2m_penality_charge,
       0 net_settlement_price,
       
       --unrealized pnl
       poud.net_m2m_amt_in_base_cur market_value_in_val_ccy,
       poud.base_cur_id market_value_cur_id,
       poud.base_cur_code market_value_cur_code,
       NVL (poud.prev_day_unr_pnl_in_base_cur,
            0) prev_day_unr_pnl_in_base_cur,
       NVL (poud.unrealized_pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       NVL (poud.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       poud.base_cur_id base_cur_id, poud.base_cur_code base_cur_code,
       poud.base_qty_unit base_quantity_uom
  FROM poue_phy_open_unreal_element@eka_eoddb poud,
       tdc_trade_date_closure@eka_eoddb tdc,
       ucm_unit_conversion_master@eka_eoddb ucm,
       pdm_productmaster@eka_eoddb pdm
 WHERE poud.process_id = tdc.process_id
   AND poud.corporate_id = tdc.corporate_id
   AND ucm.from_qty_unit_id = poud.qty_unit_id
   AND ucm.to_qty_unit_id = poud.base_qty_unit_id
   AND poud.product_id = pdm.product_id
   AND ucm.is_active = 'Y'
   AND tdc.process = 'EOD'
UNION ALL
SELECT pss.corporate_id, akc.corporate_name, pdm.product_type_id product_type,
       pss.profit_center_id, cpc.profit_center_short_name profit_center,
       pss.strategy_id, pss.strategy_name, pss.product_id conc_product_id,
       pss.product_name conc_product_name, pss.quality_id conc_quality_id,
       pss.quality_name conc_quality_name, tdc.trade_date eod_date,
       'Physical' position_type,
       (CASE
           WHEN pss.section_name IN ('Shipped NTT', 'Stock NTT')
              THEN (CASE
                       WHEN pss.contract_type = 'P'
                          THEN 'Shipped but title not transferred on Purchase'
                       ELSE 'Shipped but title not transferred on Sales'
                    END
                   )
           WHEN pss.section_name IN
                         ('Shipped TT', 'Stock TT', 'Shipped IN', 'Stock IN')
              THEN (CASE
                       WHEN pss.contract_type = 'P'
                          THEN 'Inventory Purchase'
                       ELSE 'Inventory Sales'
                    END
                   )
        END
       ) position_sub_type,
       pss.gmr_ref_no || '- ' || pss.stock_ref_no contract_ref_no,
       'NA' external_ref_no, NULL issue_date, 'NA' cp_id, 'NA' cp_name,
       'NA' incoterm, 'NA' payment_term, cm.cur_code group_currency,
       pss.base_cur_code corp_currency,
         (CASE
             WHEN pss.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * pss.stock_dry_qty contract_quantity,
       pss.qty_unit contract_quantity_uom,
         (CASE
             WHEN pss.contract_type = 'S'
                THEN -1
             ELSE 1
          END)
       * NVL (pss.stock_dry_qty, 0)
       * NVL (ucm.multiplication_factor, 0) quantity_in_base_uom,
       0 quantity_in_lots, 0 contract_price,
       pss.contract_price_string contract_price_unit,
       pss.net_contract_value_in_base_cur net_contract_value,
       0 net_contract_premium_value, 0 net_sc_cost,
       0 contract_treatment_charge, 0 contract_refining_charge,
       0 contract_penalty_charge, 'NA' valuation_instrument_id,
       'NA' valuation_instrument, 'NA' derivative_def_id,
       'NA' derivative_def_name, 'NA' valuation_month, NULL value_date,
       pss.net_contract_value_in_base_cur total_cost_in_m2m_currency,
       pss.base_cur_code m2m_currency,
       pss.net_contract_value_in_base_cur expected_cog_net_sale_value,
       0 m2m_settlement_price, pss.m2m_price_string settlement_price_unit,
       'NA' valuation_city_id, 'NA' valuation_city, 'NA' valuation_country_id,
       'NA' valuation_country, 0 m2m_basis,
       NVL (m2m_loc_diff_premium, 0) m2m_loc_incoterm_deviation,
       0 m2m_quality_premium, 0 m2m_product_premium,
       NVL (pss.m2m_treatment_charge, 0) m2m_treatment_charge,
       NVL (pss.m2m_refining_charge, 0) m2m_refining_charge,
       NVL (pss.m2m_penalty_charge, 0) m2m_penality_charge,
       0 net_settlement_price,
       pss.net_m2m_amount_in_base_cur market_value_in_val_ccy,
       pss.base_cur_id market_value_cur_id,
       pss.base_cur_code market_value_cur_code,
       NVL (pss.prev_day_pnl_in_base_cur, 0) prev_day_unr_pnl_in_base_cur,
       NVL (pss.pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       NVL (pss.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       pss.base_cur_id base_cur_id, pss.base_cur_code base_cur_code,
       pss.prod_base_qty_unit base_quantity_uom
  FROM psue_phy_stock_unrealized_ele@eka_eoddb pss,
       ak_corporate@eka_eoddb akc,
       cpc_corporate_profit_center@eka_eoddb cpc,
       cm_currency_master@eka_eoddb cm,
       gcd_groupcorporatedetails@eka_eoddb gcd,
       tdc_trade_date_closure@eka_eoddb tdc,
       ucm_unit_conversion_master@eka_eoddb ucm,
       pdm_productmaster@eka_eoddb pdm
 WHERE pss.process_id = tdc.process_id
   AND pss.corporate_id = tdc.corporate_id
   AND pss.corporate_id = akc.corporate_id
   AND pss.profit_center_id = cpc.profit_center_id
   AND akc.groupid = gcd.groupid
   AND gcd.group_cur_id = cm.cur_id(+)
   AND ucm.from_qty_unit_id = pss.qty_unit_id
   AND ucm.to_qty_unit_id = pss.prod_base_qty_unit_id
   AND pss.product_id = pdm.product_id
   AND ucm.is_active = 'Y'
   AND tdc.process = 'EOD'
   AND pss.price_type_id <> 'Fixed' ;
/
DROP MATERIALIZED VIEW MV_FACT_PHYSICAL_UNREALIZED;
DROP TABLE MV_FACT_PHYSICAL_UNREALIZED;
CREATE MATERIALIZED VIEW MV_FACT_PHYSICAL_UNREALIZED 
nocache
logging
nocompress
noparallel
build immediate
refresh force on demand
with primary key
as  
select poud.corporate_id,
       poud.corporate_name,
       pdm.product_type_id product_type,
       poud.profit_center_id,
       poud.profit_center_short_name profit_center,
       poud.strategy_id,
       poud.strategy_name,
       poud.product_id product_id,
       poud.product_name product_name,
       poud.quality_id quality_id,
       poud.quality_name quality_name,
       poud.eod_trade_date eod_date,
       'Physical' position_type,
       (case
         when poud.contract_type = 'P' then
          'Open Purchase'
         else
          'Open Sales'
       end) position_sub_type,
       poud.contract_ref_no || '(' || poud.delivery_item_no || ')'
       
       contract_ref_no,
       'NA' external_ref_no,
       poud.contract_issue_date issue_trade_date,
       poud.cp_profile_id cp_id,
       poud.cp_name cp_name,
       poud.incoterm,
       poud.payment_term,
       poud.group_cur_code group_currency,
       poud.base_cur_code corp_currency,
       (case
         when poud.contract_type = 'S' then
          -1
         else
          1
       end) * poud.item_qty contract_quantity,
       poud.qty_unit contract_quantity_uom,
       (case
         when poud.contract_type = 'S' then
          -1
         else
          1
       end) * poud.qty_in_base_unit quantity_in_base_uom,
       0 quantity_in_lots,
       poud.contract_price,
       poud.price_unit_cur_code || '/' ||
       decode(poud.price_unit_weight,
              1,
              null,
              0,
              null,
              poud.price_unit_weight) || poud.price_unit_weight_unit contract_price_unit,
       poud.contract_value_in_price_cur net_contract_value, --in base currency
       poud.contract_premium_value net_contract_premium_value,
       poud.sc_in_base_cur net_sc_cost,
       0 contract_treatment_charge,
       0 contract_refining_charge,
       0 contract_penalty_charge,
       md.instrument_id valuation_instrument_id, --valuation_instument_id
       dim.instrument_name valuation_instrument,
       md.derivative_def_id derivative_def_id,
       md.derivative_def_name derivative_def_name,
       md.valuation_month valuation_month,
       md.valuation_date value_date,
       poud.expected_cog_in_val_cur total_cost_in_m2m_currency,
       poud.m2m_amt_cur_code m2m_currency,
       poud.expected_cog_net_sale_value expected_cog_net_sale_value,
       
       --m2m valuation details
       (case
         when md.valuation_method = 'DIFFERENTIAL' then
          md.m2m_settlement_price
         else
          0
       end) m2m_settlement_price,
       poud.m2m_price_cur_code || '/' ||
       decode(poud.m2m_price_weight,
              1,
              null,
              0,
              null,
              poud.m2m_price_weight) || poud.m2m_price_weight_unit settlement_price_unit,
       md.valuation_city_id,
       md.valuation_location valuation_city,
       cim.country_id valuation_country_id,
       md.valuation_location_country valuation_country,
       md.m2m_diff m2m_basis,
       (nvl(md.m2m_loc_incoterm_deviation, 0) +
       nvl(md.m2m_location_deviation,
            
            0) + nvl(md.m2m_incoterm_deviation, 0)) m2m_loc_incoterm_deviation,
       nvl(md.m2m_quality_premium, 0) m2m_quality_premium,
       nvl(md.m2m_product_premium, 0) m2m_product_premium,
       0 m2m_treatment_charge,
       0 m2m_refining_charge,
       0 m2m_penality_charge,
       poud.net_m2m_price net_settlement_price,
       --unrealized pnl
       poud.m2m_amt market_value_in_val_ccy,
       poud.m2m_amt_cur_id market_value_cur_id,
       poud.m2m_amt_cur_code market_value_cur_code,
       nvl(poud.prev_day_unr_pnl_in_base_cur, 0) prev_day_unr_pnl_in_base_cur,
       nvl(poud.unrealized_pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       nvl(poud.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       poud.base_cur_id base_cur_id,
       poud.base_cur_code base_cur_code,
       poud.base_qty_unit base_quantity_uom
  from poud_phy_open_unreal_daily@eka_eoddb poud,
       md_m2m_daily@eka_eoddb               md,
       dim_der_instrument_master@eka_eoddb  dim,
       tdc_trade_date_closure@eka_eoddb     tdc,
       cim_citymaster@eka_eoddb             cim,
       qat_quality_attributes@eka_eoddb     qat,
       pdm_productmaster@eka_eoddb          pdm
 where poud.process_id = tdc.process_id
   and poud.md_id = md.md_id
   and poud.process_id = md.process_id
   and md.instrument_id = dim.instrument_id(+)
   and md.valuation_city_id = cim.city_id
   and poud.quality_id = qat.quality_id
   and poud.product_id=pdm.product_id
   and tdc.process = 'EOD'
union all
select pss.corporate_id,
       akc.corporate_name,
       pdm.product_type_id product_type,
       pss.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pss.strategy_id,
       pss.strategy_name,
       pss.product_id product_id,
       pss.product_name product_name,
       pss.quality_id quality_id,
       pss.quality_name quality_name,
       tdc.trade_date eod_date,
       'Physical' position_type,
       (case
          when pss.section_name in ('Shipped NTT', 'Stock NTT') then
           (case
          when pss.contract_type = 'P' then
           'Shipped but title not transferred on Purchase'
          else
           'Shipped but title not transferred on Sales'
        end) when pss.section_name in ('Shipped TT', 'Stock TT', 'Shipped IN', 'Stock IN') then(case
         when pss.contract_type = 'P' then
          'Inventory Purchase'
         else
          'Inventory Sales'
       end) end) position_sub_type,
       pss.gmr_ref_no || '- ' || pss.stock_ref_no contract_ref_no,
       'NA' external_ref_no,
       null issue_date,
       'NA' cp_id,
       'NA' cp_name,
       'NA' incoterm,
       'NA' payment_term,
       cm.cur_code group_currency,
       pss.base_cur_code corp_currency,
       (case
         when pss.contract_type = 'S' then
          -1
         else
          1
       end) * pss.stock_qty contract_quantity,
       pss.qty_unit contract_quantity_uom,
       (case
         when pss.contract_type = 'S' then
          -1
         else
          1
       end) * pss.qty_in_base_unit quantity_in_base_uom,
       0 quantity_in_lots,
       pss.contract_price,
       pss.price_unit_cur_code || '/' ||
       decode(pss.price_unit_weight,
              1,
              null,
              0,
              null,
              pss.price_unit_weight) || pss.price_unit_weight_unit contract_price_unit,
       pss.contract_value_in_price_cur net_contract_value, --in base currency
       pss.contract_premium_value net_contract_premium_value,
       nvl(pss.sc_in_base_cur, 0) net_sc_cost,
       0 contract_treatment_charge,
       0 contract_refining_charge,
       0 contract_penalty_charge,
       md.instrument_id valuation_instrument_id, --valuation_instument_id
       dim.instrument_name valuation_instrument,
       md.derivative_def_id derivative_def_id,
       md.derivative_def_name derivative_def_name,
       md.valuation_month valuation_month,
       md.valuation_date value_date,
       pss.expected_cog_in_val_cur total_cost_in_m2m_currency,
       pss.m2m_amt_cur_code m2m_currency,
       pss.expected_cog_in_base_cur expected_cog_net_sale_value,
       
       --m2m valuation details
       (case
         when md.valuation_method = 'DIFFERENTIAL' then
          md.m2m_settlement_price
         else
          0
       end) m2m_settlement_price,
       pss.m2m_price_unit_str settlement_price_unit,
       md.valuation_city_id,
       md.valuation_location valuation_city,
       cim.country_id valuation_country_id,
       md.valuation_location_country valuation_country,
       md.m2m_diff m2m_basis,
       (nvl(md.m2m_loc_incoterm_deviation, 0) +
       nvl(md.m2m_location_deviation,
            
            0) + nvl(md.m2m_incoterm_deviation, 0)) m2m_loc_incoterm_deviation,
       nvl(md.m2m_quality_premium, 0) m2m_quality_premium,
       nvl(md.m2m_product_premium, 0) m2m_product_premium,
       0 m2m_treatment_charge,
       0 m2m_refining_charge,
       0 m2m_penality_charge,
       pss.net_m2m_price net_settlement_price,
       --unrealized pnl
       pss.m2m_amt market_value_in_val_ccy,
       pss.m2m_amt_cur_id market_value_cur_id,
       pss.m2m_amt_cur_code market_value_cur_code,
       nvl(pss.prev_day_pnl_in_base_cur, 0) prev_day_unr_pnl_in_base_cur,
       nvl(pss.pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       nvl(pss.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       pss.base_cur_id base_cur_id,
       pss.base_cur_code base_cur_code,
       pss.prod_base_unit base_quantity_uom
  from psu_phy_stock_unrealized@eka_eoddb    pss,
       ak_corporate@eka_eoddb                akc,
       gcd_groupcorporatedetails@eka_eoddb   gcd,
       cpc_corporate_profit_center@eka_eoddb cpc,
       cm_currency_master@eka_eoddb          cm,
       md_m2m_daily@eka_eoddb                md,
       cim_citymaster@eka_eoddb              cim,
       dim_der_instrument_master@eka_eoddb   dim,
       tdc_trade_date_closure@eka_eoddb      tdc,
       pdm_productmaster@eka_eoddb           pdm
 where pss.process_id = tdc.process_id
   and pss.corporate_id = tdc.corporate_id
   and pss.md_id = md.md_id
   and pss.process_id = md.process_id
   and pss.profit_center_id = cpc.profit_center_id
   and md.instrument_id = dim.instrument_id(+)
   and pss.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and gcd.group_cur_id = cm.cur_id(+)
   and md.valuation_city_id = cim.city_id
   and pss.product_id=pdm.product_id
   and tdc.process = 'EOD'
union all
select poud.corporate_id,
       poud.corporate_name,
       pdm.product_type_id product_type,
       poud.profit_center_id,
       poud.profit_center_short_name profit_center,
       poud.strategy_id,
       poud.strategy_name,
       poud.product_id product_id,
       poud.product_name product_name,
       poud.quality_id quality_id,
       poud.quality_name quality_name,
       poud.process_trade_date eod_date,
       'Physical' position_type,
       (case
         when poud.contract_type = 'P' then
          'Open Purchase'
         else
          'Open Sales'
       end) position_sub_type,
       poud.contract_ref_no || '(' || poud.delivery_item_no || ')'
       
       contract_ref_no,
       'NA' external_ref_no,
       poud.contract_issue_date issue_trade_date,
       poud.cp_profile_id cp_id,
       poud.cp_name cp_name,
       poud.incoterm,
       poud.payment_term,
       poud.group_cur_code group_currency,
       poud.base_cur_code corp_currency,
       (case
         when poud.contract_type = 'S' then
          -1
         else
          1
       end) * poud.item_dry_qty contract_quantity,
       poud.qty_unit contract_quantity_uom,
       (case
         when poud.contract_type = 'S' then
          -1
         else
          1
       end) * nvl(poud.item_dry_qty,0)*nvl(ucm.multiplication_factor,0) quantity_in_base_uom,
       0 quantity_in_lots,
       0 contract_price,
       poud.contract_price_string contract_price_unit,
       poud.net_contract_prem_in_base_cur net_contract_value, --in base currency
       0 net_contract_premium_value,
       poud.net_sc_in_base_cur net_sc_cost,
       nvl(poud.net_contract_treatment_charge, 0) contract_treatment_charge,
       nvl(poud.net_contract_refining_charge, 0) contract_refining_charge,
       nvl(poud.penalty_charge, 0) contract_penalty_charge,
       'NA' valuation_instrument_id, --valuation_instument_id
       'NA' valuation_instrument,
       'NA' derivative_def_id,
       'NA' derivative_def_name,
       'NA' valuation_month,
       null value_date,
       poud.expected_cog_net_sale_value total_cost_in_m2m_currency,
       poud.base_cur_code m2m_currency, --base currency
       poud.expected_cog_net_sale_value expected_cog_net_sale_value,
       --m2m valuation details
       0 m2m_settlement_price,
       poud.m2m_price_string settlement_price_unit,
       'NA' valuation_city_id,
       'NA' valuation_city,
       'NA' valuation_country_id,
       'NA' valuation_country,
       0 m2m_basis,
       nvl(m2m_loc_diff_premium, 0) m2m_loc_incoterm_deviation,
       0 m2m_quality_premium,
       0 m2m_product_premium,
       nvl(poud.net_m2m_treatment_charge, 0) m2m_treatment_charge,
       nvl(poud.net_m2m_refining_charge, 0) m2m_refining_charge,
       nvl(poud.m2m_penalty_charge, 0) m2m_penality_charge,
       0 net_settlement_price,
       --unrealized pnl
       poud.net_m2m_amt_in_base_cur market_value_in_val_ccy,
       poud.base_cur_id market_value_cur_id,
       poud.base_cur_code market_value_cur_code,
       nvl(poud.prev_day_unr_pnl_in_base_cur, 0) prev_day_unr_pnl_in_base_cur,
       nvl(poud.unrealized_pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       nvl(poud.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       poud.base_cur_id base_cur_id,
       poud.base_cur_code base_cur_code,
       poud.base_qty_unit base_quantity_uom
  from poue_phy_open_unreal_element@eka_eoddb poud,
       tdc_trade_date_closure@eka_eoddb       tdc,
       ucm_unit_conversion_master@eka_eoddb   ucm,
       pdm_productmaster@eka_eoddb            pdm
 where poud.process_id = tdc.process_id
   and poud.corporate_id = tdc.corporate_id
   and ucm.from_qty_unit_id =poud.qty_unit_id
   and ucm.to_qty_unit_id = poud.base_qty_unit_id
   and poud.product_id=pdm.product_id
   and ucm.is_active = 'Y'
   and tdc.process = 'EOD'
union all
select pss.corporate_id,
       akc.corporate_name,
       pdm.product_type_id product_type,
       pss.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pss.strategy_id,
       pss.strategy_name,
       pss.product_id conc_product_id,
       pss.product_name conc_product_name,
       pss.quality_id conc_quality_id,
       pss.quality_name conc_quality_name,
       tdc.trade_date eod_date,
       'Physical' position_type,
       (case
          when pss.section_name in ('Shipped NTT', 'Stock NTT') then
           (case
          when pss.contract_type = 'P' then
           'Shipped but title not transferred on Purchase'
          else
           'Shipped but title not transferred on Sales'
        end) when pss.section_name in ('Shipped TT', 'Stock TT', 'Shipped IN', 'Stock IN') then(case
         when pss.contract_type = 'P' then
          'Inventory Purchase'
         else
          'Inventory Sales'
       end) end) position_sub_type,
       pss.gmr_ref_no || '- ' || pss.stock_ref_no contract_ref_no,
       'NA' external_ref_no,
       null issue_date,
       'NA' cp_id,
       'NA' cp_name,
       'NA' incoterm,
       'NA' payment_term,
       cm.cur_code group_currency,
       pss.base_cur_code corp_currency,
       (case
         when pss.contract_type = 'S' then
          -1
         else
          1
       end) * pss.stock_dry_qty contract_quantity,
       pss.qty_unit contract_quantity_uom,
       (case
         when pss.contract_type = 'S' then
          -1
         else
          1
       end) *nvl(pss.stock_dry_qty,0)*nvl(ucm.multiplication_factor,0) quantity_in_base_uom,
       0 quantity_in_lots,
       0 contract_price,
       pss.contract_price_string contract_price_unit,
       pss.net_contract_value_in_base_cur net_contract_value, --in base currency
       0 net_contract_premium_value,
       0 net_sc_cost,
       0 contract_treatment_charge,
       0 contract_refining_charge,
       0 contract_penalty_charge,
       'NA' valuation_instrument_id, --valuation_instument_id
       'NA' valuation_instrument,
       'NA' derivative_def_id,
       'NA' derivative_def_name,
       'NA' valuation_month,
       null value_date,
       pss.net_contract_value_in_base_cur total_cost_in_m2m_currency,
       pss.base_cur_code m2m_currency,
       pss.net_contract_value_in_base_cur expected_cog_net_sale_value,
       
       --m2m valuation details
       0 m2m_settlement_price,
       pss.m2m_price_string settlement_price_unit,
       'NA' valuation_city_id,
       'NA' valuation_city,
       'NA' valuation_country_id,
       'NA' valuation_country,
       0 m2m_basis,
       nvl(m2m_loc_diff_premium, 0) m2m_loc_incoterm_deviation,
       0 m2m_quality_premium,
       0 m2m_product_premium,
       nvl(pss.m2m_treatment_charge, 0) m2m_treatment_charge,
       nvl(pss.m2m_refining_charge, 0) m2m_refining_charge,
       nvl(pss.m2m_penalty_charge, 0) m2m_penality_charge,
       0 net_settlement_price,
       --unrealized pnl
       pss.net_m2m_amount_in_base_cur market_value_in_val_ccy,
       pss.base_cur_id market_value_cur_id,
       pss.base_cur_code market_value_cur_code,
       nvl(pss.prev_day_pnl_in_base_cur, 0) prev_day_unr_pnl_in_base_cur,
       nvl(pss.pnl_in_base_cur, 0) unrealized_pnl_in_base_cur,
       nvl(pss.trade_day_pnl_in_base_cur, 0) pnl_change_in_base_cur,
       pss.base_cur_id base_cur_id,
       pss.base_cur_code base_cur_code,
       pss.prod_base_qty_unit base_quantity_uom
  from psue_phy_stock_unrealized_ele@eka_eoddb pss,
       ak_corporate@eka_eoddb                  akc,
       cpc_corporate_profit_center@eka_eoddb   cpc,
       cm_currency_master@eka_eoddb            cm,
       gcd_groupcorporatedetails@eka_eoddb     gcd,
       tdc_trade_date_closure@eka_eoddb        tdc,
       ucm_unit_conversion_master@eka_eoddb    ucm,
       pdm_productmaster@eka_eoddb            pdm
 where pss.process_id = tdc.process_id
   and pss.corporate_id = tdc.corporate_id
   and pss.corporate_id = akc.corporate_id
   and pss.profit_center_id = cpc.profit_center_id
   and akc.groupid = gcd.groupid
   and gcd.group_cur_id = cm.cur_id(+)
   and ucm.from_qty_unit_id =pss.qty_unit_id
   and ucm.to_qty_unit_id = pss.prod_base_qty_unit_id
   and pss.product_id=pdm.product_id
   and ucm.is_active = 'Y'
   and tdc.process = 'EOD';
/
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
       dpd.instrument_type || ' ' || dpd.trade_type position_sub_type,
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
       
       --0 market_value_in_val_ccy, not available now
       dpd.base_cur_id   market_value_cur_id,
       dpd.base_cur_code market_value_cur_code,
       
       --       0 prev_day_unr_pnl_in_base_cur,not available now
       dpd.pnl_in_base_cur unrealized_pnl_in_base_cur,
       -- 0  pnl_change_in_base_cur, not available now
       dpd.base_cur_id,
       dpd.base_cur_code,
       dpd.base_qty_unit base_quantity_uom
  from dpd_derivative_pnl_daily@eka_eoddb dpd,
       tdc_trade_date_closure@eka_eoddb   tdc,
       pdm_productmaster@eka_eoddb        pdm
 where dpd.pnl_type = 'Unrealized'
   and dpd.process_id = tdc.process_id
   and dpd.corporate_id = tdc.corporate_id
   and dpd.product_id=pdm.product_id
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
       cm_group_cur.cur_code group_cur_code,
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
       cpd.home_cur_id market_value_cur_id,
       cpd.home_currency market_value_cur_code,
       cpd.pnl_value_in_home_currency unrealized_pnl_in_base_cur,
       cpd.home_cur_id base_cur_id,
       cpd.home_currency base_cur_code,
       cpd.home_currency base_quantity_uom
  from cpd_currency_pnl_daily@eka_eoddb        cpd,
       tdc_trade_date_closure@eka_eoddb        tdc,
       ct_currency_trade@eka_eoddb             ct,
       pym_payment_terms_master@eka_eoddb      pym,
       dpm_derivative_purpose_master@eka_eoddb dpm,
       ak_corporate@eka_eoddb                  ak,
       gcd_groupcorporatedetails@eka_eoddb     gcd_group_id,
       cm_currency_master@eka_eoddb            cm_group_cur,
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
   and cpd.product_name=pdm.product_desc;
/
DROP MATERIALIZED VIEW MV_FACT_UNREALIZED;
DROP TABLE MV_FACT_UNREALIZED;
CREATE MATERIALIZED VIEW MV_FACT_UNREALIZED
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 

select mvp.corporate_id,
       mvp.corporate_name,
       mvp.product_type,
       mvp.profit_center_id,
       mvp.profit_center,
       mvp.strategy_id,
       mvp.strategy_name,
       mvp.product_id,
       mvp.product_name,
       mvp.quality_id,
       mvp.quality_name,
       mvp.eod_date,
	   to_char(mvp.eod_date,'dd-Mon-yyyy') eod_date_str,
       mvp.position_type || ' - ' || mvp.position_sub_type position_type_id,
       mvp.position_type,
       mvp.position_sub_type,
       mvp.contract_ref_no,
       mvp.external_ref_no,
       mvp.issue_trade_date,
       mvp.cp_id,
       mvp.cp_name,
       mvp.incoterm,
       mvp.payment_term,
       'NA' derivative_purpose,
       'NA' option_type,
       0 strike_price,
       'NA' strike_price_unit,
       'NA' allocated_phy_refno,
       mvp.group_currency,
       mvp.corp_currency,
       mvp.contract_quantity,
       mvp.contract_quantity_uom,
       mvp.quantity_in_base_uom,
       mvp.base_quantity_uom,
       nvl(mvp.quantity_in_lots, 0) quantity_in_lots,
       nvl(mvp.contract_price, 0) contract_price,
       decode(mvp.contract_price_unit,
              '/',
              'NA',
              null,
              'NA',
              mvp.contract_price_unit) contract_price_unit,
       mvp.net_contract_value,
       mvp.net_contract_premium_value contract_premium_value,
       mvp.net_sc_cost secondary_cost,
       mvp.contract_treatment_charge contract_treatment_charge,
       mvp.contract_refining_charge contract_refining_charge,
       mvp.contract_penalty_charge contract_penalty_charge,
       mvp.valuation_instrument_id,
       mvp.valuation_instrument,
       mvp.derivative_def_id,
       mvp.derivative_def_name,
       mvp.valuation_month,
       mvp.value_date,
       mvp.total_cost_in_m2m_currency,
       mvp.m2m_currency,
       mvp.expected_cog_net_sale_value,
       nvl(mvp.m2m_settlement_price, 0) m2m_settlement_price,
       mvp.settlement_price_unit,
       mvp.valuation_country_id || ' - ' || mvp.valuation_city_id comb_valuation_loc_id,
       mvp.valuation_city_id,
       mvp.valuation_city,
       mvp.valuation_country_id,
       mvp.valuation_country,
       mvp.m2m_basis m2m_basis,
       mvp.m2m_loc_incoterm_deviation,
       mvp.m2m_quality_premium  m2m_quality_premium,
       mvp.m2m_product_premium  m2m_product_premium,
       mvp.m2m_treatment_charge m2m_treatment_charge,
       mvp.m2m_refining_charge  m2m_refining_charge,
       mvp.m2m_penality_charge  m2m_penality_charge,
       mvp.net_settlement_price,
       mvp.market_value_in_val_ccy,
       mvp.market_value_cur_id,
       mvp.market_value_cur_code,
       mvp.prev_day_unr_pnl_in_base_cur,
       mvp.unrealized_pnl_in_base_cur,
       mvp.pnl_change_in_base_cur,
       mvp.base_cur_id,
       mvp.base_cur_code
  from mv_fact_physical_unrealized mvp
union all
select mvd.corporate_id,
       mvd.corporate_name,
       mvd.product_type,
       mvd.profit_center_id,
       mvd.profit_center,
       mvd.strategy_id,
       mvd.strategy_name,
       mvd.product_id,
       mvd.product_name,
       mvd.quality_id,
       nvl(mvd.quality_name, 'NA') quality_name,
       mvd.eod_date,
	   to_char(mvd.eod_date,'dd-Mon-yyyy') eod_date_str,
       mvd.position_type || ' - ' || mvd.position_sub_type position_type_id,
       mvd.position_type,
       mvd.position_sub_type,
       mvd.contract_ref_no,
       mvd.external_ref_no,
       mvd.issue_trade_date,
       mvd.cp_id,
       mvd.cp_name,
       'NA' incoterm,
       nvl(mvd.payment_term, 'NA') payment_term,
       mvd.derivative_purpose,
       nvl(mvd.option_type, 'NA') option_type,
       decode(mvd.strike_price, null, 0, mvd.strike_price) strike_price,
       decode(mvd.strike_price_unit,
              '/',
              'NA',
              null,
              'NA',
              mvd.strike_price_unit) strike_price_unit,
       mvd.allocated_phy_refno,
       mvd.group_cur_code group_currency,
       mvd.base_cur_code corp_currency,
       mvd.contract_quantity,
       mvd.contract_quantity_uom,
       mvd.quantity_in_base_uom,
       mvd.base_quantity_uom,
       nvl(mvd.quantity_in_lots, 0) quantity_in_lots,
       nvl(mvd.contract_price, 0) contract_price,
       decode(mvd.trade_price_unit,
              '/',
              'NA',
              null,
              'NA',
              mvd.trade_price_unit) contract_price_unit,
       0 net_contract_value,
       0 contract_premium_value,
       0 secondary_cost,
       0 contract_treatment_charge,
       0 contract_refining_charge,
       0 contract_penalty_charge,
       mvd.valuation_instrument_id,
       mvd.valuation_instrument,
       mvd.derivative_def_id,
       mvd.derivative_def_name,
       mvd.valuation_month,
       mvd.value_date,
       null total_cost_in_m2m_currency,
       null m2m_currency,
       null expected_cog_net_sale_value,
       mvd.m2m_settlement_price,
       mvd.settlement_price_unit,
       'NA' comb_valuation_loc_id,
       'NA' valuation_city_id,
       'NA' valuation_city,
       'NA' valuation_country_id,
       'NA' valuation_country,
       0 m2m_basis,
       0 m2m_loc_incoterm_deviation,
       0 m2m_quality_premium,
       0 m2m_product_premium,
       0 m2m_treatment_charge,
       0 m2m_refining_charge,
       0 m2m_penality_charge,
       mvd.net_settlement_price,
       0 market_value_in_val_ccy,
       mvd.market_value_cur_id,
       mvd.market_value_cur_code,
       0 prev_day_unr_pnl_in_base_cur,
       mvd.unrealized_pnl_in_base_cur,
       0 pnl_change_in_base_cur,
       mvd.base_cur_id,
       mvd.base_cur_code
  from mv_fact_derivative_unrealized mvd;
/
DROP MATERIALIZED VIEW MV_POSITION_MGR;
CREATE MATERIALIZED VIEW MV_POSITION_MGR
REFRESH FORCE ON DEMAND
START WITH TO_DATE('10-Nov-2011 21:44:01','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 10/1440 
WITH PRIMARY KEY
AS 
SELECT * FROM v_position_mgr
/
drop MATERIALIZED VIEW MV_CASH_FLOW;
drop TABLE MV_CASH_FLOW;
CREATE MATERIALIZED VIEW MV_CASH_FLOW
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE
START WITH TO_DATE('10-Nov-2011 21:44:01','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE+10/1440 
WITH PRIMARY KEY
AS 
SELECT * FROM v_cash_flow
/

