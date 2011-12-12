CREATE OR REPLACE VIEW V_FUTURE_OPTION_POSITION AS
WITH ucm_mfact AS
        (SELECT ucm.from_qty_unit_id, ucm.to_qty_unit_id,
                qum_from.qty_unit qum_from_qty_unit,
                qum_to.qty_unit qum_to_qty_unit, ucm.multiplication_factor
           FROM ucm_unit_conversion_master ucm,
                qum_quantity_unit_master qum_to,
                qum_quantity_unit_master qum_from
          WHERE ucm.from_qty_unit_id = qum_from.qty_unit_id
            AND ucm.to_qty_unit_id = qum_to.qty_unit_id
            AND ucm.is_active = 'Y'
            AND qum_from.is_deleted = 'N'
            AND qum_to.is_deleted = 'N')

         SELECT (CASE
                        WHEN dpm.purpose_name = 'EFP'
                           THEN 'Futures'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Futures'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Futures'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'Futures'
                        WHEN dpm.purpose_name= 'Net Hedge'
                           THEN 'Futures'
                        ELSE 'Futures'
                     END
                    ) entity,
                    'Net' mastersectionname,
                    (CASE
                        WHEN dpm.purpose_name IN
                                               ('White Premium', 'Net Hedge')
                           THEN 'Net'
                        ELSE 'Net Pricing'
                     END
                    ) mainsectionname,
                    (CASE
                        WHEN dpm.purpose_name IN ('Speculation', 'Net Hedge')
                           THEN 'Speculation-White Premium'
                        ELSE 'EFP-Hedging'
                     END
                    ) sectionname,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN    'Pricing'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN    'Hedging'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN    'Strategic'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN    'White Premium'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN    'Net Hedge'
                                || '('
                                || DECODE (dt.trade_type,
                                           'Buy', 'B',
                                           'Sell', 'S'
                                          )
                                || ')'
                        ELSE 'Futures'
                     END
                    ) subsectionname,
                    (CASE
                        WHEN dpm.purpose_name = 'EFP'
                           THEN 2
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 3
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 5
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 4
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 6
                        ELSE 99
                     END
                    ) subsectionorder,
                    dt.corporate_id corporate_id, ak.corporate_name,
                    dt.trade_price_type_id price_type_id,
                    dt.derivative_ref_no contract_ref_no,
                    TO_CHAR
                       (dt.internal_derivative_ref_no
                       ) internal_contract_item_ref_no,
                    dt.trade_type contract_type, dt.trade_date issue_date,
                    dt.leg_no item_no, cpc.profit_center_id profit_center_id,
                    cpc.profit_center_name profit_center_name,
                    cpc.profit_center_short_name profit_center_short_name,
                    pdm.product_id product_id, pdm.product_desc product_desc,
                    css.strategy_id, css.strategy_name,
                    pdm.base_quantity_unit base_quantity_unit,
                    drm.dr_id price_future_contract_id,
                    emt.exchange_id exchange_id,
                    emt.exchange_name exchange_name, drm.instrument_id,
                    dim.instrument_name instrument_name,
                    drm.period_date period_date,
                    drm.period_date min_period_date,
                    drm.period_date period_date_diff,
                    drm.period_month period_month,
                    drm.period_year period_year,
                    pdd.derivative_def_id derivative_def_id,
                    pdd.derivative_def_name derivative_def_name,
                    irm.instrument_type_id instrument_type_id,
                    irm.instrument_type instrument_type,
                    dt.quantity_unit_id qty_unit,
                    (CASE
                        WHEN dt.status = 'None'
                           THEN 'Y'
                        ELSE 'N'
                     END
                    ) is_not_verified,
                    dt.is_what_if is_wif_contract,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN 'Pricing Trades'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Hedge Trades'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Strategic Trades'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'White Premium Trades'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 'Net Hedge Trades'
                        ELSE 'Derivative Trades'
                     END
                    ) position_type,
                    (CASE
                        WHEN irm.instrument_type = 'Future'
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Futures'
                        WHEN irm.instrument_type = 'Future'
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Futures'
                        ELSE 'Future'
                     END
                    ) position_sub_type,
                    'NA' origin_id, 'NA' origin_name, 'NA' quality_id,
                    'NA' quality_name, dt.cp_profile_id counter_party_id,
                    phd_cp.companyname counter_party_name,
                    dt.external_ref_no external_reference_no,
                    dt.trader_id trader_user_id,
                    gab.firstname || ' ' || gab.lastname trader_name,
                    phd_broker.profileid broker_profile_id,
                    phd_broker.companyname broker_name, 'NA' incoterm_id,
                    'NA' incoterm, 'NA' payment_term_id, 'NA' payment_term,
                    'NA' price_type_name, 'NA' pay_in_cur_id,
                    'NA' pay_in_cur_code, drm.period_date delivery_from_date,
                    drm.expiry_date delivery_to_date,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) valuation_month,
                    dt.trade_price_unit_id,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END)
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm.multiplication_factor, 0) qty,
                    ucm.qum_to_qty_unit group_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0) qty_in_ctract_unit,
                    qum_act.qty_unit ctract_qty_unit,
                      (CASE
                          WHEN dt.trade_type = 'Buy'
                             THEN -1
                          ELSE 1
                       END
                      )
                    * NVL (dt.open_quantity, 0)
                    * NVL (ucm_base.multiplication_factor, 0)
                                                             qty_in_base_unit,
                    ucm_base.qum_to_qty_unit base_qty_unit,
                    blm.business_line_id, blm.business_line_name,
                    'NA' item_price_string, 'NA' origination_country_id,
                    'NA' origination_country, 'NA' origination_city_id,
                    'NA' origination_city, 'NA' location_group_id,
                    'NA' location_group_name, 'NA' loc_group_type_id,
                    'NA' loc_group_type_name, 'NA' destination_city_id,
                    'NA' destination_country_id, 'NA' destination_state_id,
                    'NA' destination_region_id, 'NA' cym_dest_country_name,
                    'NA' cim_dest_city_name, 'NA' sm_dest_state_name,
                    'NA' valuation_city_id, 'NA' valuation_city_name,
                    'NA' valuation_country_id, 'NA' valuation_country_name,
                    'NA' val_loc_group_id, 'NA' val_loc_group_name,
                    'NA' val_loc_group_type_id, 'NA' val_loc_group_type_name,
                    0 contract_price_group_unit,
                    cm_gcd.cur_code group_cur_code,
                    0 contract_price_base_unit,
                    cm_base.cur_code base_cur_code,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) delivery_month
               FROM dt_derivative_trade dt,
                    ak_corporate ak,
                    ak_corporate_user aku,
                    gab_globaladdressbook gab,
                    cpc_corporate_profit_center cpc,
                    drm_derivative_master drm,
                    dim_der_instrument_master dim,
                    irm_instrument_type_master irm,
                    istm_instr_sub_type_master istm,
                    pdd_product_derivative_def pdd,
                    pdm_productmaster pdm,
                    emt_exchangemaster emt,
                    qum_quantity_unit_master qum,
                    qum_quantity_unit_master qum_act,
                    pp_price_point pp,
                    pm_period_master pm,
                    dtm_deal_type_master dtm,
                    css_corporate_strategy_setup css,
                    sdm_strategy_definition_master sdm,
                    gcd_groupcorporatedetails gcd,
                    dpm_derivative_purpose_master dpm,
                    blm_business_line_master blm,
                    phd_profileheaderdetails phd_cp,
                    phd_profileheaderdetails phd_broker,
                    ucm_mfact ucm,
                    ucm_mfact ucm_base,
                    gcd_groupcorporatedetails gcd_group,
                    cm_currency_master cm_gcd,
                    cm_currency_master cm_base,
                    pum_price_unit_master pum_trade
              WHERE dt.corporate_id = ak.corporate_id
                AND dt.trader_id = aku.user_id
                AND aku.gabid = gab.gabid
                AND dt.profit_center_id = cpc.profit_center_id
                AND dt.dr_id = drm.dr_id(+)
                AND drm.instrument_id = dim.instrument_id(+)
                AND dim.instrument_type_id = irm.instrument_type_id(+)
                AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
                AND dim.product_derivative_id = pdd.derivative_def_id(+)
                AND pdd.product_id = pdm.product_id(+)
                AND pdd.exchange_id = emt.exchange_id(+)
                AND pdd.lot_size_unit_id = qum.qty_unit_id(+)
                AND drm.price_point_id = pp.price_point_id(+)
                AND drm.period_type_id = pm.period_type_id(+)
                AND dt.quantity_unit_id = qum_act.qty_unit_id(+)
                AND dt.deal_type_id = dtm.deal_type_id
                AND dt.strategy_id = css.strategy_id
                AND css.strategy_def_id = sdm.strategy_def_id
                AND ak.groupid = gcd.groupid
                AND dt.purpose_id = dpm.purpose_id
                AND cpc.business_line_id = blm.business_line_id(+)
                AND dt.cp_profile_id = phd_cp.profileid(+)
                AND dt.broker_profile_id = phd_broker.profileid(+)
                AND irm.instrument_type = 'Future'
                AND dtm.deal_type_display_name NOT LIKE '%Swap%'
                AND UPPER (dt.status) IN ('NONE', 'VERIFIED')
                AND nvl(DT.TRADED_ON,'Exchange')='Exchange'
                AND NVL (dt.is_internal_trade, 'N') = 'N'
                AND dt.quantity_unit_id = ucm.from_qty_unit_id
                AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
                AND dt.quantity_unit_id = ucm_base.from_qty_unit_id
                AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
                AND ak.groupid = gcd_group.groupid
                AND gcd_group.group_cur_id = cm_gcd.cur_id
                AND ak.base_cur_id = cm_base.cur_id(+)
                AND dt.trade_price_unit_id = pum_trade.price_unit_id(+)
             UNION ALL
             SELECT 'Options' entity, 'Net' mastersectionname,
                    'Net' mainsectionname, 'Options' sectionname,
                    'Option Delta' subsectionname, 5 subsectionorder,
                    dt.corporate_id corporate_id, ak.corporate_name,
                    'Fixed' price_type_id,
                    dt.derivative_ref_no contract_ref_no,
                    TO_CHAR
                       (dt.internal_derivative_ref_no
                       ) internal_contract_item_ref_no,
                    dt.trade_type contract_type, dt.trade_date issue_date,
                    dt.leg_no item_no, cpc.profit_center_id profit_center_id,
                    cpc.profit_center_name profit_center_name,
                    cpc.profit_center_short_name profit_center_short_name,
                    pdm.product_id product_id, pdm.product_desc product_desc,
                    css.strategy_id, css.strategy_name,
                    pdm.base_quantity_unit base_quantity_unit,
                    drm.dr_id price_future_contract_id,
                    emt.exchange_id exchange_id,
                    emt.exchange_name exchange_name, drm.instrument_id,
                    dim.instrument_name instrument_name,
                    drm.period_date period_date,
                    drm.period_date min_period_date,
                    drm.period_date period_date_diff,
                    drm.period_month period_month,
                    drm.period_year period_year,
                    pdd.derivative_def_id derivative_def_id,
                    pdd.derivative_def_name derivative_def_name,
                    irm.instrument_type_id instrument_type_id,
                    irm.instrument_type instrument_type,
                    dt.quantity_unit_id qty_unit,
                    (CASE
                        WHEN dt.status = 'None'
                           THEN 'Y'
                        ELSE 'N'
                     END
                    ) is_not_verified,
                    dt.is_what_if is_wif_contract,
                    (CASE
                        WHEN dpm.purpose_name in('EFP','Pricing')
                           THEN 'Pricing Trades'
                        WHEN dpm.purpose_name = 'Hedging'
                           THEN 'Hedge Trades'
                        WHEN dpm.purpose_name = 'Speculation'
                           THEN 'Strategic Trades'
                        WHEN dpm.purpose_name = 'White Premium'
                           THEN 'White Premium Trades'
                        WHEN dpm.purpose_name = 'Net Hedge'
                           THEN 'Net Hedge Trades'
                        ELSE 'Derivative Trades'
                     END
                    ) position_type,
                    (CASE
                        WHEN irm.instrument_type = 'Option Put'
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Puts'
                        WHEN irm.instrument_type = 'Option Put'
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Puts'
                        WHEN irm.instrument_type = 'Option Call'
                        AND dt.trade_type = 'Buy'
                           THEN 'Long Calls'
                        WHEN irm.instrument_type = 'Option Call'
                        AND dt.trade_type = 'Sell'
                           THEN 'Short Calls'
                        ELSE 'Options'
                     END
                    ) position_sub_type,
                    'NA' origin_id, 'NA' origin_name, 'NA' quality_id,
                    'NA' quality_name, dt.cp_profile_id counter_party_id,
                    phd_cp.companyname counter_party_name,
                    dt.external_ref_no external_reference_no,
                    dt.trader_id trader_user_id,
                    gab.firstname || ' ' || gab.lastname trader_name,
                    phd_broker.profileid broker_profile_id,
                    phd_broker.companyname broker_name, 'NA' incoterm_id,
                    'NA' incoterm, 'NA' payment_term_id, 'NA' payment_term,
                    'NA' price_type_name, 'NA' pay_in_cur_id,
                    'NA' pay_in_cur_code, drm.period_date delivery_from_date,
                    drm.expiry_date delivery_to_date,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) valuation_month,
                    dt.strike_price_unit_id,
                      (  (CASE
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Buy'
                                THEN 1
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Sell'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Buy'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Sell'
                                THEN 1
                             ELSE 1
                          END
                         )
                       * NVL (dt.open_quantity, 0)
                      -- * NVL (vlq.delta, 0)
                      )
                    * NVL (ucm.multiplication_factor, 0) qty,
                    ucm.qum_to_qty_unit group_qty_unit,
                      (  (CASE
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Buy'
                                THEN 1
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Sell'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Buy'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Sell'
                                THEN 1
                             ELSE 1
                          END
                         )
                       --* NVL (vlq.delta, 0)
                      )
                    * NVL (dt.open_quantity, 0) qty_in_ctract_unit,
                    qum_act.qty_unit ctract_qty_unit,
                      (  (CASE
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Buy'
                                THEN 1
                             WHEN irm.instrument_type = 'Option Put'
                             AND dt.trade_type = 'Sell'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Buy'
                                THEN -1
                             WHEN irm.instrument_type = 'Option Call'
                             AND dt.trade_type = 'Sell'
                                THEN 1
                             ELSE 1
                          END
                         )
                       * NVL (dt.open_quantity, 0)
                      -- * NVL (vlq.delta, 0)
                      )
                    * NVL (ucm_base.multiplication_factor, 0)
                                                             qty_in_base_unit,
                    ucm_base.qum_to_qty_unit base_qty_unit,
                    blm.business_line_id, blm.business_line_name,
                    'NA' item_price_string, 'NA' origination_country_id,
                    'NA' origination_country, 'NA' origination_city_id,
                    'NA' origination_city, 'NA' location_group_id,
                    'NA' location_group_name, 'NA' loc_group_type_id,
                    'NA' loc_group_type_name, 'NA' destination_city_id,
                    'NA' destination_country_id, 'NA' destination_state_id,
                    'NA' destination_region_id, 'NA' cym_dest_country_name,
                    'NA' cim_dest_city_name, 'NA' sm_dest_state_name,
                    'NA' valuation_city_id, 'NA' valuation_city_name,
                    'NA' valuation_country_id, 'NA' valuation_country_name,
                    'NA' val_loc_group_id, 'NA' val_loc_group_name,
                    'NA' val_loc_group_type_id, 'NA' val_loc_group_type_name,
                    0 contract_price_group_unit,
                    cm_gcd.cur_code group_cur_code,
                    0 contract_price_base_unit,
                    cm_base.cur_code base_cur_code,
                    (CASE
                        WHEN pm.period_type_name IN ('Day', 'Week')
                           THEN TO_CHAR (drm.period_date, 'Mon-yyyy')
                        ELSE drm.period_month || '-' || drm.period_year
                     END
                    ) delivery_month
               FROM dt_derivative_trade dt,
                    ak_corporate ak,
                    ak_corporate_user aku,
                    gab_globaladdressbook gab,
                    cpc_corporate_profit_center cpc,
                    drm_derivative_master drm,
                    dim_der_instrument_master dim,
                    irm_instrument_type_master irm,
                    istm_instr_sub_type_master istm,
                    pdd_product_derivative_def pdd,
                    pdm_productmaster pdm,
                    emt_exchangemaster emt,
                    qum_quantity_unit_master qum,
                    qum_quantity_unit_master qum_act,
                    pp_price_point pp,
                    pm_period_master pm,
                    dtm_deal_type_master dtm,
                    css_corporate_strategy_setup css,
                    sdm_strategy_definition_master sdm,
                    gcd_groupcorporatedetails gcd,
                    dpm_derivative_purpose_master dpm,
                    blm_business_line_master blm,
                    phd_profileheaderdetails phd_cp,
                    phd_profileheaderdetails phd_broker,
                    ucm_mfact ucm,
                    ucm_mfact ucm_base,
                    gcd_groupcorporatedetails gcd_group,
                    cm_currency_master cm_gcd,
                    cm_currency_master cm_base,
                    pum_price_unit_master pum_strike,
                    v_latest_option_quotes    vlq
              WHERE dt.corporate_id = ak.corporate_id
                AND dt.trader_id = aku.user_id
                AND aku.gabid = gab.gabid
                AND dt.profit_center_id = cpc.profit_center_id
                AND dt.dr_id = drm.dr_id(+)
                AND drm.instrument_id = dim.instrument_id(+)
                AND dim.instrument_type_id = irm.instrument_type_id(+)
                AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
                AND dim.product_derivative_id = pdd.derivative_def_id(+)
                AND pdd.product_id = pdm.product_id(+)
                AND pdd.exchange_id = emt.exchange_id(+)
                AND pdd.lot_size_unit_id = qum.qty_unit_id(+)
                AND drm.price_point_id = pp.price_point_id(+)
                AND drm.period_type_id = pm.period_type_id(+)
                AND dt.quantity_unit_id = qum_act.qty_unit_id(+)
                AND dt.deal_type_id = dtm.deal_type_id
                AND dt.strategy_id = css.strategy_id
                AND css.strategy_def_id = sdm.strategy_def_id
                AND ak.groupid = gcd.groupid
                AND dt.purpose_id = dpm.purpose_id
                AND cpc.business_line_id = blm.business_line_id(+)
                AND dt.cp_profile_id = phd_cp.profileid(+)
                AND dt.broker_profile_id = phd_broker.profileid(+)
                AND irm.instrument_type IN ('Option Put', 'Option Call')
                AND UPPER (dt.status) IN ('NONE', 'VERIFIED')
                AND NVL (dt.is_internal_trade, 'N') = 'N'
                AND dt.quantity_unit_id = ucm.from_qty_unit_id
                AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
                AND dt.quantity_unit_id = ucm_base.from_qty_unit_id
                AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
                AND ak.groupid = gcd_group.groupid
                AND gcd_group.group_cur_id = cm_gcd.cur_id
                AND ak.base_cur_id = cm_base.cur_id(+)
                AND dt.strike_price_unit_id = pum_strike.price_unit_id(+)
                AND dt.dr_id = vlq.dr_id(+)
                AND dt.corporate_id = vlq.corporate_id(+)

