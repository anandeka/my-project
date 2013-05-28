DROP MATERIALIZED VIEW MV_FACT_PHY_UNREAL_FIXED_PRICE;
CREATE MATERIALIZED VIEW MV_FACT_PHY_UNREAL_FIXED_PRICE
REFRESH FORCE ON DEMAND
AS
SELECT poud.corporate_id, poud.corporate_name,
       poud.trade_user_id trader_user_id,
       poud.trade_user_name trader_name,
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
   AND poud.price_type_id <> 'Fixed'
UNION ALL
SELECT pss.corporate_id, akc.corporate_name, pss.trader_id trader_user_id,
       pss.trader_name trader_name,pdm.product_type_id product_type,
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
   AND pss.price_type_id <> 'Fixed'
UNION ALL
SELECT poud.corporate_id, poud.corporate_name,
       poud.trade_user_id trader_user_id,
       poud.trade_user_name trader_name,
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
     --------------------  poud.expected_cog_net_sale_value total_cost_in_m2m_currency,
       poud.net_contract_value_in_base_cur total_cost_in_m2m_currency,
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
SELECT pss.corporate_id, akc.corporate_name,pss.trader_id trader_user_id,
       pss.trader_name trader_name, pdm.product_type_id product_type,
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
  -- AND pss.price_type_id <> 'Fixed' remove the condition to get both fixed and variable price contract for concentrate 
