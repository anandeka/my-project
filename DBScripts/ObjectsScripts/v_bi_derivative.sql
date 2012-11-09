create or replace view v_bi_derivative as
select temp.derivative_ref_no,
       temp.origional_trade_ref_no,
       temp.parent_int_derivative_ref_no,
       temp.external_ref_no,
       temp.master_contract_id,
       temp.trade_date,
       temp.trade_year_month,
       temp.trade_year,
       temp.trader,
       temp.trade_type,
       temp.deal_type,
       temp.instrument_name,
       temp.trade_quantity_in_base_unit,
       temp.base_quantity_unit,
       temp.total_lots,
       temp.open_lots,
       temp.closed_lots,
       temp.exercised_lots,
       temp.expired_lots,
       temp.status,
       temp.deal_price,
       temp.deal_price_unit,
       temp.deal_price_to_base_fx_rate,
       round(nvl(deal_price_to_base_fx_rate, 1) * nvl(temp.deal_price, 1),
             4) deal_price_in_base_ccy,
       temp.strike_price,
       temp.strike_price_unit,
       temp.strike_price_to_base_fx_rate,
       round(nvl(temp.strike_price, 1) *
             nvl(temp.strike_price_to_base_fx_rate, 1),
             4) strike_price_in_base_ccy,
       temp.premium_discount,
       temp.premium_discount_price_unit,
       temp.premium_price_to_base_fx_rate,
       round(nvl(temp.premium_discount, 1) *
             nvl(temp.premium_price_to_base_fx_rate, 1),
             4) premium_price_in_base_ccy,
       temp.premium_due_date,
       temp.period_type_name,
       temp.prompt_details,
       temp.prompt_date,
       temp.prompt_year_month,
       temp.prompt_year,
       temp.clearer,
       temp.clearer_comm_type,
       temp.account_name,
       temp.clearer_commission,
       temp.clearer_commission_unit,
       temp.clearer_comm_to_base_fx_rate,
       round(nvl(temp.clearer_commission, 0) *
             nvl(temp.clearer_comm_to_base_fx_rate, 1),
             4) clearer_commission_in_base_ccy,
       temp.broker,
       temp.broker_comm_type,
       temp.broker_commission,
       temp.broker_commission_ccy,
       temp.broker_comm_to_base_fx_rate,
       round(nvl(temp.broker_commission, 0) *
             nvl(temp.broker_comm_to_base_fx_rate, 1),
             4) broker_commission_in_base_ccy,
       temp.option_type,
       temp.expiry_date,
       temp.expiry_month_year,
       temp.product,
       temp.quality_name,
       temp.market_location,
       temp.counter_party,
       temp.average_from_date,
       temp.average_to_date,
       temp.payment_term,
       temp.payment_due_date,
       temp.internal_trade_no,
       temp.pay_details,
       temp.receive_details,
       temp.profit_center_id,
       temp.profit_center_name,
       temp.profit_center_short_name,
       temp.trade_basics,
       temp.price_source_name,
       temp.price_point_name,
       temp.sett_ccy,
       temp.instrument_type,
       temp.nominee,
       temp.purpose_name,
       temp.corporate_id,
       temp.corporate_name,
       temp.business_line_name,
       temp.strategy_id,
       temp.strategy_name,
       temp.remarks,
       temp.exchange_name,
       temp.contract_value,
       temp.contract_value_unit,
       temp.base_ccy,
       temp.fx_to_base,
       temp.trade_qty,
       temp.open_quantity,
       temp.closed_quantity,
       temp.trade_qty_unit_id,
       temp.trade_qty_unit,
       round(nvl(temp.contract_value, 1) * nvl(temp.fx_to_base, 1), 4) cont_val_in_base_ccy,
       (case
         when temp.instrument_type = 'Average' then
          t1.fixed_qty
         else
          temp.trade_qty
       end) priced_qty,
       (case
         when temp.instrument_type = 'Average' then
          t1.unfixed_qty
         else
          0
       end) unprice_qty,
       null attribute1,
       null attribute2,
       null attribute3,
       null attribute4,
       null attribute5,
       temp.swap_type_1,
       temp.swap_trade_price_1,
       temp.swap_trade_price_unit_id_1,
       temp.swap_type_2,
       temp.swap_trade_price_2,
       temp.swap_index_instrument_id_2,
       temp.period_type_name period_type,
       temp.period,
       temp.off_day_price,
       temp.basis basics,
       temp.basics_unit,
       round(nvl(temp.contract_value, 1) * nvl(temp.fx_to_base, 1) +
             nvl(temp.clearer_commission *
                 temp.clearer_comm_to_base_fx_rate,
                 0),
             4) total_val_in_base_ccy

  from (select dt.derivative_ref_no,
               dt.int_trade_parent_der_ref_no origional_trade_ref_no,
               dt.parent_int_derivative_ref_no,
               dt.external_ref_no,
               dt.internal_derivative_ref_no,
               dim.underlying_instrument_id,
               null master_contract_id,
               dt.trade_date,
               to_char(dt.trade_date, 'yyyy-mm') trade_year_month,
               to_char(dt.trade_date, 'yyyy') trade_year,
               akcu.login_name trader,
               dt.trade_type,
               dtm.deal_type_display_name deal_type,
               dim.instrument_name,
               (case
                 when irmf.instrument_type in
                      ('Option Put', 'OTC Put Option') and
                      dt.trade_type = 'Buy' then
                  -1
                 when irmf.instrument_type in
                      ('Option Call', 'OTC Call Option') and
                      dt.trade_type = 'Sell' then
                  -1
                 when dt.trade_type = 'Sell' and
                      irmf.instrument_type not in
                      ('Option Call', 'OTC Call Option', 'Option Put',
                       'OTC Put Option') then
                  -1
                 else
                  1
               end) *
               round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                     pdm_qum.decimals) trade_quantity_in_base_unit,
               pdm_qum.qty_unit base_quantity_unit,
               (case
                 when irmf.instrument_type in
                      ('Option Put', 'OTC Put Option') and
                      dt.trade_type = 'Buy' then
                  -1
                 when irmf.instrument_type in
                      ('Option Call', 'OTC Call Option') and
                      dt.trade_type = 'Sell' then
                  -1
                 when dt.trade_type = 'Sell' and
                      irmf.instrument_type not in
                      ('Option Call', 'OTC Call Option', 'Option Put',
                       'OTC Put Option') then
                  -1
                 else
                  1
               end) * dt.total_lots total_lots,
               (case
                 when irmf.instrument_type in
                      ('Option Put', 'OTC Put Option') and
                      dt.trade_type = 'Buy' then
                  -1
                 when irmf.instrument_type in
                      ('Option Call', 'OTC Call Option') and
                      dt.trade_type = 'Sell' then
                  -1
                 when dt.trade_type = 'Sell' and
                      irmf.instrument_type not in
                      ('Option Call', 'OTC Call Option', 'Option Put',
                       'OTC Put Option') then
                  -1
                 else
                  1
               end) * dt.open_lots open_lots,
               (case
                 when irmf.instrument_type in
                      ('Option Put', 'OTC Put Option') and
                      dt.trade_type = 'Buy' then
                  -1
                 when irmf.instrument_type in
                      ('Option Call', 'OTC Call Option') and
                      dt.trade_type = 'Sell' then
                  -1
                 when dt.trade_type = 'Sell' and
                      irmf.instrument_type not in
                      ('Option Call', 'OTC Call Option', 'Option Put',
                       'OTC Put Option') then
                  -1
                 else
                  1
               end) * dt.closed_lots closed_lots,
               null exercised_lots,
               null expired_lots,
               dt.status,
               dt.trade_price deal_price,
               pum.price_unit_name deal_price_unit,
               round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                              nvl(pum.cur_id,
                                                                  pum_sett.cur_id),
                                                              ak.base_cur_id,
                                                              sysdate,
                                                              1),
                     4) deal_price_to_base_fx_rate,
               null strike_price,
               null strike_price_unit,
               0 strike_price_to_base_fx_rate,
               null premium_discount,
               null premium_discount_price_unit,
               0 premium_price_to_base_fx_rate,
               pm.period_type_name,
               pm.period_type_name prompt_details,
               drm.prompt_date prompt_date,
               to_char(drm.prompt_date, 'yyyy-mm') prompt_year_month,
               to_char(drm.prompt_date, 'yyyy') prompt_year,
               nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
               bct.commission_type_name clearer_comm_type,
               bca.account_name,
               dt.clearer_comm_amt clearer_commission,
               cm_cl_comm.cur_code clearer_commission_unit,
               round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                              nvl(cm_cl_comm.cur_id,
                                                                  pum_sett.cur_id),
                                                              ak.base_cur_id,
                                                              sysdate,
                                                              1),
                     4) clearer_comm_to_base_fx_rate,
               
               nvl(phd_broker.company_long_name1, phd_broker.companyname) broker,
               bct.settlement_type broker_comm_type,
               dt.broker_comm_amt broker_commission,
               cm_comm.cur_code broker_commission_ccy,
               round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                              nvl(cm_comm.cur_id,
                                                                  pum_sett.cur_id),
                                                              ak.base_cur_id,
                                                              sysdate,
                                                              1),
                     4) broker_comm_to_base_fx_rate,
               null option_type,
               null expiry_date,
               null expiry_month_year,
               pdm.product_desc product,
               null quality_name,
               null market_location,
               null counter_party,
               null average_from_date,
               null average_to_date,
               null payment_term,
               null payment_due_date,
               null internal_trade_no,
               dt.swap_type_1 pay_details,
               dt.swap_type_2 receive_details,
               cpc.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               null trade_basics,
               null price_source_name,
               null price_point_name,
               null sett_ccy,
               irmf.instrument_type,
               phd_nomine.companyname nominee,
               dpm.purpose_display_name purpose_name,
               ak.corporate_id,
               ak.corporate_name,
               blm.business_line_name,
               css.strategy_id,
               css.strategy_name,
               dt.remarks,
               emt.exchange_name,
               (case
                 when irmf.instrument_type in
                      ('Option Put', 'OTC Put Option') and
                      dt.trade_type = 'Buy' then
                  -1
                 when irmf.instrument_type in
                      ('Option Call', 'OTC Call Option') and
                      dt.trade_type = 'Sell' then
                  -1
                 when dt.trade_type = 'Sell' and
                      irmf.instrument_type not in
                      ('Option Call', 'OTC Call Option', 'Option Put',
                       'OTC Put Option') then
                  -1
                 else
                  1
               end) *
               round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                     pdm_qum.decimals) * dt.trade_price contract_value,
               (case
                 when cm_val.is_sub_cur = 'Y' then
                  scd.main_cur_code
                 else
                  cm_val.cur_code
               end) contract_value_unit,
               cmak.cur_code base_ccy,
               round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                              nvl(pum.cur_id,
                                                                  pum_sett.cur_id),
                                                              ak.base_cur_id,
                                                              sysdate,
                                                              1),
                     4) fx_to_base,
               dt.total_quantity * (case
                 when irmf.instrument_type in
                      ('Option Put', 'OTC Put Option') and
                      dt.trade_type = 'Buy' then
                  -1
                 when irmf.instrument_type in
                      ('Option Call', 'OTC Call Option') and
                      dt.trade_type = 'Sell' then
                  -1
                 when dt.trade_type = 'Sell' and
                      irmf.instrument_type not in
                      ('Option Call', 'OTC Call Option', 'Option Put',
                       'OTC Put Option') then
                  -1
                 else
                  1
               end) trade_qty,
               dt.quantity_unit_id trade_qty_unit_id,
               qum.qty_unit trade_qty_unit,
               dt.open_quantity * (case
                 when irmf.instrument_type in
                      ('Option Put', 'OTC Put Option') and
                      dt.trade_type = 'Buy' then
                  -1
                 when irmf.instrument_type in
                      ('Option Call', 'OTC Call Option') and
                      dt.trade_type = 'Sell' then
                  -1
                 when dt.trade_type = 'Sell' and
                      irmf.instrument_type not in
                      ('Option Call', 'OTC Call Option', 'Option Put',
                       'OTC Put Option') then
                  -1
                 else
                  1
               end),
               dt.closed_quantity * (case
                 when irmf.instrument_type in
                      ('Option Put', 'OTC Put Option') and
                      dt.trade_type = 'Buy' then
                  -1
                 when irmf.instrument_type in
                      ('Option Call', 'OTC Call Option') and
                      dt.trade_type = 'Sell' then
                  -1
                 when dt.trade_type = 'Sell' and
                      irmf.instrument_type not in
                      ('Option Call', 'OTC Call Option', 'Option Put',
                       'OTC Put Option') then
                  -1
                 else
                  1
               end),
               null priced_qty,
               null unprice_qt,
               null premium_due_date,
               dt_leg1.swap_type_1,
               dt_leg1.swap_trade_price_1,
               dt_leg1.swap_trade_price_unit_id_1,
               dt_leg2.swap_type_2,
               dt_leg2.swap_trade_price_2,
               dt_leg2.swap_index_instrument_id_2,
               dt.swap_float_type_2 price_type,
               dt_fb2.period,
               dt_fb2.off_day_price,
               dt_fb2.basis,
               dt_fb2.price_unit_name basics_unit
          from dt_derivative_trade dt,
               cpc_corporate_profit_center cpc,
               blm_business_line_master blm,
               css_corporate_strategy_setup css,
               ak_corporate ak,
               drm_derivative_master drm,
               phd_profileheaderdetails phd_broker,
               phd_profileheaderdetails phd_clr,
               dim_der_instrument_master dim,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master pdm_qum,
               irm_instrument_type_master irmf,
               pm_period_master pm,
               pdd_product_derivative_def pdd,
               pdm_productmaster pdm,
               pum_price_unit_master pum,
               pum_price_unit_master pum_strik,
               pum_price_unit_master pum_pd,
               cm_currency_master cm_comm,
               cm_currency_master cm_cl_comm,
               cm_currency_master cm_val,
               (select cm.cur_code main_cur_code,
                       cm.decimals main_cur_decimal,
                       scd.sub_cur_id,
                       scd.cur_id main_cur_id,
                       scd.factor
                  from scd_sub_currency_detail scd,
                       cm_currency_master      cm
                 where scd.cur_id = cm.cur_id) scd,
               emt_exchangemaster emt,
               ak_corporate_user akcu,
               bca_broker_clearer_account bca,
               dpm_derivative_purpose_master dpm,
               cm_currency_master cmak,
               bct_broker_commission_types bct,
               --bcs_broker_commission_setup bcs,
               ps_price_source            ps,
               pp_price_point             pp,
               pum_price_unit_master      pum_sett,
               phd_profileheaderdetails   phd_nomine,
               phd_profileheaderdetails   phd_cp,
               ucm_unit_conversion_master ucm,
               --pum_price_unit_master pum_clear,
               dtm_deal_type_master dtm,
               (select dt_inner.internal_derivative_ref_no,
                       dt_inner.swap_type_1,
                       dt_inner.swap_trade_price_1,
                       dt_inner.swap_trade_price_unit_id_1
                  from dt_derivative_trade dt_inner
                 where dt_inner.leg_no = 1) dt_leg1,
               (select dt_inner.internal_derivative_ref_no,
                       dt_inner.swap_type_2,
                       dt_inner.swap_trade_price_2,
                       dt_inner.swap_index_instrument_id_2,
                       dt_inner.swap_trade_price_type_2,
                       dt_inner.swap_float_type_2
                  from dt_derivative_trade dt_inner
                 where dt_inner.leg_no = 2) dt_leg2,
               (select dt_fbi.internal_derivative_ref_no,
                       dt_fbi.period_type_id,
                       pm.period_type_name,
                       dt_fbi.period_month || '-' || dt_fbi.period_year period,
                       dt_fbi.off_day_price,
                       dt_fbi.basis,
                       dt_fbi.basis_price_unit_id,
                       ppu.price_unit_name
                
                  from dt_fbi           dt_fbi,
                       pm_period_master pm,
                       v_ppu_pum        ppu
                 where dt_fbi.leg_no = 2
                   and dt_fbi.period_type_id = pm.period_type_id(+)
                   and dt_fbi.basis_price_unit_id = ppu.product_price_unit_id
                   and dt_fbi.is_deleted = 'N') dt_fb2
         where dt.dr_id = drm.dr_id
           and dt.internal_derivative_ref_no =
               dt_leg1.internal_derivative_ref_no(+)
           and dt.internal_derivative_ref_no =
               dt_leg2.internal_derivative_ref_no(+)
           and dt.broker_profile_id = phd_broker.profileid(+)
           and dt.clearer_profile_id = phd_clr.profileid(+)
           and drm.instrument_id = dim.instrument_id
           and dim.instrument_type_id = irmf.instrument_type_id
           and dt.corporate_id = ak.corporate_id
           and drm.period_type_id = pm.period_type_id(+)
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.product_id = pdm.product_id
           and dt.trade_price_unit_id = pum.price_unit_id(+)
           and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
           and dt.broker_comm_cur_id = cm_comm.cur_id(+)
           and dt.clearer_comm_cur_id = cm_cl_comm.cur_id(+)
           and dt.quantity_unit_id = qum.qty_unit_id
           and pdm.base_quantity_unit = pdm_qum.qty_unit_id
           and pum.cur_id = cm_val.cur_id(+)
           and dt.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and cm_val.cur_id = scd.sub_cur_id(+)
           and dt.strategy_id = css.strategy_id(+)
              --  and irmf.is_active = 'Y'
              --    and irmf.is_deleted = 'N'
           and dt.status = 'Verified'
              /*and emt.exchange_code = 'LME' */
           and pdd.exchange_id = emt.exchange_id
           and akcu.user_id = dt.trader_id
           and bca.account_id = dt.clearer_account_id
           and dpm.purpose_id = dt.purpose_id
           and cmak.cur_id = ak.base_cur_id
           and dt.clearer_comm_type_id = bct.commission_type_id(+)
              /*and bct.commission_type_id = bcs.commission_type_id(+)
                                                                   and dim.instrument_type_id = bcs.future_option_type*/
              --  and bct.is_active = 'Y'
           and dt.price_source_id = ps.price_source_id(+)
           and dt.price_point_id = pp.price_point_id(+)
           and dt.settlement_price_unit_id = pum_sett.price_unit_id(+)
           and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
           and dt.traded_on = 'Exchange'
           and nvl(dt.is_internal_trade, 'N') = 'N'
           and dt.nominee_profile_id = phd_nomine.profileid(+)
           and dt.cp_profile_id = phd_cp.profileid(+)
           and dt.quantity_unit_id = ucm.from_qty_unit_id
           and pdm.base_quantity_unit = ucm.to_qty_unit_id
              --and bcs.price_unit_id = pum_clear.price_unit_id(+)
           and dt.deal_type_id = dtm.deal_type_id
           and dt.internal_derivative_ref_no =
               dt_fb2.internal_derivative_ref_no(+)
        union all
        select t.derivative_ref_no,
               t.origional_trade_ref_no,
               t.parent_int_derivative_ref_no,
               t.external_ref_no,
               t.internal_derivative_ref_no,
               t.underlying_instrument_id,
               t.master_contract_id,
               t.trade_date,
               t.trade_year_month,
               t.trade_year,
               t.trader,
               t.trade_type,
               t.deal_type,
               t.instrument_name,
               t.trade_quantity_in_base_unit,
               t.base_quantity_unit,
               t.total_lots,
               t.open_lots,
               t.closed_lots,
               t.exercised_lots,
               t.expired_lots,
               t.status,
               t.deal_price,
               t.deal_price_unit,
               t.deal_price_to_base_fx_rate,
               t.strike_price,
               t.strike_price_unit,
               t.strike_price_to_base_fx_rate,
               t.premium_discount,
               t.premium_discount_price_unit,
               t.premium_price_to_base_fx_rate,
               t.period_type_name,
               t.prompt_details,
               t.prompt_date,
               t.trade_year_month,
               t.prompt_year,
               t.clearer,
               t.commission_type_name clearer_comm_type,
               t.account_name,
               t.clearer_commission,
               t.clearer_commission_unit,
               t.clearer_comm_to_base_fx_rate,
               t.broker,
               t.broker_comm_type,
               t.broker_commission,
               t.broker_commission_ccy,
               t.broker_comm_to_base_fx_rate,
               t.option_type,
               t.expiry_date,
               t.expiry_month_year,
               t.product,
               t.quality_name,
               t.market_location,
               t.counter_party,
               t.average_from_date,
               t.average_to_date,
               t.payment_term,
               t.payment_due_date,
               t.internal_trade_no,
               t.pay_details,
               t.receive_details,
               t.profit_center_id,
               t.profit_center_name,
               t.profit_center_short_name,
               t.trade_basics,
               t.price_source_name,
               t.price_point_name,
               t.sett_ccy,
               t.instrument_type,
               t.nominee,
               t.purpose_name,
               t.corporate_id cor_id,
               t.corporate_name,
               t.business_line_name,
               t.strategy_id,
               t.strategy_name,
               t.remarks,
               null exchnage_name,
               t.contract_value,
               t.contract_value_unit,
               t.base_ccy,
               t.fx_to_base,
               t.trade_qty,
               t.trade_qty_unit_id,
               t.trade_qty_unit,
               t.open_quantity,
               t.closed_quantity,
               t.priced_qty,
               t.unprice_qt,
               t.premium_due_date,
               t.swap_type_1,
               t.swap_trade_price_1,
               t.swap_trade_price_unit_id_1,
               t.swap_type_2,
               t.swap_trade_price_2,
               t.swap_index_instrument_id_2,
               t.price_type,
               t.period,
               t.off_day_price,
               t.basis,
               t.basics_unit
          from (select dt.derivative_ref_no,
                       dt.int_trade_parent_der_ref_no origional_trade_ref_no,
                       dt.parent_int_derivative_ref_no,
                       dt.external_ref_no,
                       dt.internal_derivative_ref_no,
                       dim.underlying_instrument_id,
                       dt.master_contract_id,
                       dt.trade_date,
                       to_char(dt.trade_date, 'yyyy-mm') trade_year_month,
                       to_char(dt.trade_date, 'yyyy') trade_year,
                       akcu.login_name trader,
                       dt.trade_type,
                       dtm.deal_type_display_name deal_type,
                       dim.instrument_name,
                       (case
                         when irmf.instrument_type in
                              ('Option Put', 'OTC Put Option') and
                              dt.trade_type = 'Buy' then
                          -1
                         when irmf.instrument_type in
                              ('Option Call', 'OTC Call Option') and
                              dt.trade_type = 'Sell' then
                          -1
                         when dt.trade_type = 'Sell' and
                              irmf.instrument_type not in
                              ('Option Call', 'OTC Call Option', 'Option Put',
                               'OTC Put Option') then
                          -1
                         else
                          1
                       end) * round((dt.total_quantity *
                                    nvl(ucm.multiplication_factor, 1)),
                                    pdm_qum.decimals) trade_quantity_in_base_unit,
                       pdm_qum.qty_unit base_quantity_unit,
                       (case
                         when irmf.instrument_type in
                              ('Option Put', 'OTC Put Option') and
                              dt.trade_type = 'Buy' then
                          -1
                         when irmf.instrument_type in
                              ('Option Call', 'OTC Call Option') and
                              dt.trade_type = 'Sell' then
                          -1
                         when dt.trade_type = 'Sell' and
                              irmf.instrument_type not in
                              ('Option Call', 'OTC Call Option', 'Option Put',
                               'OTC Put Option') then
                          -1
                         else
                          1
                       end) * dt.total_lots total_lots,
                       (case
                         when irmf.instrument_type in
                              ('Option Put', 'OTC Put Option') and
                              dt.trade_type = 'Buy' then
                          -1
                         when irmf.instrument_type in
                              ('Option Call', 'OTC Call Option') and
                              dt.trade_type = 'Sell' then
                          -1
                         when dt.trade_type = 'Sell' and
                              irmf.instrument_type not in
                              ('Option Call', 'OTC Call Option', 'Option Put',
                               'OTC Put Option') then
                          -1
                         else
                          1
                       end) * dt.open_lots open_lots,
                       (case
                         when irmf.instrument_type in
                              ('Option Put', 'OTC Put Option') and
                              dt.trade_type = 'Buy' then
                          -1
                         when irmf.instrument_type in
                              ('Option Call', 'OTC Call Option') and
                              dt.trade_type = 'Sell' then
                          -1
                         when dt.trade_type = 'Sell' and
                              irmf.instrument_type not in
                              ('Option Call', 'OTC Call Option', 'Option Put',
                               'OTC Put Option') then
                          -1
                         else
                          1
                       end) * dt.closed_lots closed_lots,
                       dt.exercised_lots,
                       dt.expired_lots,
                       dt.status,
                       dt.trade_price deal_price,
                       pum.price_unit_name deal_price_unit,
                       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                      nvl(pum.cur_id,
                                                                          pum_sett.cur_id),
                                                                      ak.base_cur_id,
                                                                      sysdate,
                                                                      1),
                             4) deal_price_to_base_fx_rate,
                       dt.strike_price,
                       pum_strik.price_unit_name strike_price_unit,
                       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                      nvl(pum_strik.cur_id,
                                                                          pum_sett.cur_id),
                                                                      ak.base_cur_id,
                                                                      sysdate,
                                                                      1),
                             4) strike_price_to_base_fx_rate,
                       dt.premium_discount,
                       pum_pd.price_unit_name premium_discount_price_unit,
                       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                      nvl(pum_pd.cur_id,
                                                                          pum_sett.cur_id),
                                                                      ak.base_cur_id,
                                                                      sysdate,
                                                                      1),
                             4) premium_price_to_base_fx_rate,
                       pm.period_type_name,
                       pm.period_type_name prompt_details,
                       drm.prompt_date prompt_date,
                       to_char(drm.prompt_date, 'yyyy-mm') prompt_year_month,
                       to_char(drm.prompt_date, 'yyyy') prompt_year,
                       nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
                       bct.settlement_type,
                       bca.account_name,
                       dt.clearer_comm_amt clearer_commission,
                       cm_cl_comm.cur_code clearer_commission_unit,
                       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                      nvl(cm_cl_comm.cur_id,
                                                                          pum_sett.cur_id),
                                                                      ak.base_cur_id,
                                                                      sysdate,
                                                                      1),
                             4) clearer_comm_to_base_fx_rate,
                       
                       nvl(phd_broker.company_long_name1,
                           phd_broker.companyname) broker,
                       bct.settlement_type broker_comm_type,
                       dt.broker_comm_amt broker_commission,
                       cm_comm.cur_code broker_commission_ccy,
                       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                      nvl(cm_comm.cur_id,
                                                                          pum_sett.cur_id),
                                                                      ak.base_cur_id,
                                                                      sysdate,
                                                                      1),
                             4) broker_comm_to_base_fx_rate,
                       irmf.instrument_type option_type,
                       drm.expiry_date,
                       to_char(drm.expiry_date, 'Mon-yyyy') expiry_month_year,
                       pdm.product_desc product,
                       qat.quality_name,
                       (case
                         when cym.country_name || ',  ' || sm.state_name || ', ' ||
                              cim.city_name = ',  , ' then
                          null
                         else
                          cym.country_name || ',  ' || sm.state_name || ', ' ||
                          cim.city_name
                       end) market_location,
                       phd_cp.companyname counter_party,
                       dt.average_from_date,
                       dt.average_to_date,
                       pym.payment_term,
                       dt.payment_due_date,
                       dt.internal_derivative_ref_no internal_trade_no,
                       dt.swap_type_1 pay_details,
                       dt.swap_type_2 receive_details,
                       cpc.profit_center_id,
                       cpc.profit_center_name,
                       cpc.profit_center_short_name,
                       dt.trade_price_type_id trade_basics,
                       bct.commission_type_id,
                       bct.commission_type_name,
                       dt.corporate_id,
                       dim.instrument_type_id,
                       ps.price_source_name,
                       pp.price_point_name,
                       null sett_ccy,
                       irmf.instrument_type,
                       phd_nomine.companyname nominee, --
                       dpm.purpose_display_name purpose_name,
                       ak.corporate_id cor_id,
                       ak.corporate_name,
                       blm.business_line_name,
                       css.strategy_id,
                       css.strategy_name,
                       dt.remarks,
                       null exchange_name,
                       (case
                         when irmf.instrument_type in
                              ('Option Put', 'OTC Put Option') and
                              dt.trade_type = 'Buy' then
                          -1
                         when irmf.instrument_type in
                              ('Option Call', 'OTC Call Option') and
                              dt.trade_type = 'Sell' then
                          -1
                         when dt.trade_type = 'Sell' and
                              irmf.instrument_type not in
                              ('Option Call', 'OTC Call Option', 'Option Put',
                               'OTC Put Option') then
                          -1
                         else
                          1
                       end) * round((dt.total_quantity *
                                    nvl(ucm.multiplication_factor, 1)),
                                    pdm_qum.decimals) * dt.trade_price contract_value,
                       (case
                         when cm_val.is_sub_cur = 'Y' then
                          scd.main_cur_code
                         else
                          cm_val.cur_code
                       end) contract_value_unit,
                       cmak.cur_code base_ccy,
                       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                                      nvl(pum.cur_id,
                                                                          pum_sett.cur_id),
                                                                      ak.base_cur_id,
                                                                      sysdate,
                                                                      1),
                             4) fx_to_base,
                       dt.total_quantity * (case
                         when irmf.instrument_type in
                              ('Option Put', 'OTC Put Option') and
                              dt.trade_type = 'Buy' then
                          -1
                         when irmf.instrument_type in
                              ('Option Call', 'OTC Call Option') and
                              dt.trade_type = 'Sell' then
                          -1
                         when dt.trade_type = 'Sell' and
                              irmf.instrument_type not in
                              ('Option Call', 'OTC Call Option', 'Option Put',
                               'OTC Put Option') then
                          -1
                         else
                          1
                       end) trade_qty,
                       dt.quantity_unit_id trade_qty_unit_id,
                       qum.qty_unit trade_qty_unit,
                       dt.open_quantity * (case
                         when irmf.instrument_type in
                              ('Option Put', 'OTC Put Option') and
                              dt.trade_type = 'Buy' then
                          -1
                         when irmf.instrument_type in
                              ('Option Call', 'OTC Call Option') and
                              dt.trade_type = 'Sell' then
                          -1
                         when dt.trade_type = 'Sell' and
                              irmf.instrument_type not in
                              ('Option Call', 'OTC Call Option', 'Option Put',
                               'OTC Put Option') then
                          -1
                         else
                          1
                       end),
                       dt.closed_quantity * (case
                         when irmf.instrument_type in
                              ('Option Put', 'OTC Put Option') and
                              dt.trade_type = 'Buy' then
                          -1
                         when irmf.instrument_type in
                              ('Option Call', 'OTC Call Option') and
                              dt.trade_type = 'Sell' then
                          -1
                         when dt.trade_type = 'Sell' and
                              irmf.instrument_type not in
                              ('Option Call', 'OTC Call Option', 'Option Put',
                               'OTC Put Option') then
                          -1
                         else
                          1
                       end),
                       null priced_qty,
                       null unprice_qt,
                       dt.premium_due_date,
                       dt_leg1.swap_type_1,
                       dt_leg1.swap_trade_price_1,
                       dt_leg1.swap_trade_price_unit_id_1,
                       dt_leg2.swap_type_2,
                       dt_leg2.swap_trade_price_2,
                       dt_leg2.swap_index_instrument_id_2,
                       dt.swap_float_type_2 price_type,
                       dt_fbi.period,
                       dt_fbi.off_day_price,
                       dt_fbi.basis,
                       dt_fbi.price_unit_name basics_unit
                
                  from dt_derivative_trade dt,
                       cpc_corporate_profit_center cpc,
                       blm_business_line_master blm,
                       css_corporate_strategy_setup css,
                       ak_corporate ak,
                       drm_derivative_master drm,
                       phd_profileheaderdetails phd_broker,
                       phd_profileheaderdetails phd_clr,
                       dim_der_instrument_master dim,
                       qum_quantity_unit_master qum,
                       qum_quantity_unit_master pdm_qum,
                       irm_instrument_type_master irmf,
                       pm_period_master pm,
                       pdd_product_derivative_def pdd,
                       pdm_productmaster pdm,
                       pum_price_unit_master pum,
                       pum_price_unit_master pum_strik,
                       pum_price_unit_master pum_pd,
                       cm_currency_master cm_comm,
                       cm_currency_master cm_cl_comm,
                       cm_currency_master cm_val,
                       (select cm.cur_code main_cur_code,
                               cm.decimals main_cur_decimal,
                               scd.sub_cur_id,
                               scd.cur_id main_cur_id,
                               scd.factor
                          from scd_sub_currency_detail scd,
                               cm_currency_master      cm
                         where scd.cur_id = cm.cur_id) scd,
                       ak_corporate_user akcu,
                       bca_broker_clearer_account bca,
                       dpm_derivative_purpose_master dpm,
                       cm_currency_master cmak,
                       bct_broker_commission_types bct,
                       qat_quality_attributes qat,
                       ps_price_source ps,
                       pp_price_point pp,
                       pum_price_unit_master pum_sett,
                       phd_profileheaderdetails phd_nomine,
                       phd_profileheaderdetails phd_cp,
                       ucm_unit_conversion_master ucm,
                       cym_countrymaster cym,
                       sm_state_master sm,
                       cim_citymaster cim,
                       dtm_deal_type_master dtm,
                       pym_payment_terms_master pym,
                       (select dt_inner.internal_derivative_ref_no,
                               dt_inner.swap_type_1,
                               dt_inner.swap_trade_price_1,
                               dt_inner.swap_trade_price_unit_id_1
                          from dt_derivative_trade dt_inner
                         where dt_inner.leg_no = 1) dt_leg1,
                       (select dt_inner.internal_derivative_ref_no,
                               dt_inner.swap_type_2,
                               dt_inner.swap_trade_price_2,
                               dt_inner.swap_index_instrument_id_2,
                               null period_type,
                               null period,
                               null off_day_price,
                               null basics,
                               null basics_unit
                          from dt_derivative_trade dt_inner
                         where dt_inner.leg_no = 2) dt_leg2,
                       (select dt_fbi.internal_derivative_ref_no,
                               dt_fbi.period_type_id,
                               pm.period_type_name,
                               dt_fbi.period_month || '-' ||
                               dt_fbi.period_year period,
                               dt_fbi.off_day_price,
                               dt_fbi.basis,
                               dt_fbi.basis_price_unit_id,
                               ppu.price_unit_name
                        
                          from dt_fbi           dt_fbi,
                               pm_period_master pm,
                               v_ppu_pum        ppu
                         where dt_fbi.leg_no = 2
                           and dt_fbi.period_type_id = pm.period_type_id(+)
                           and dt_fbi.basis_price_unit_id =
                               ppu.product_price_unit_id
                           and dt_fbi.is_deleted = 'N') dt_fbi
                 where dt.dr_id = drm.dr_id
                   and dt.broker_profile_id = phd_broker.profileid(+)
                   and dt.clearer_profile_id = phd_clr.profileid(+)
                   and drm.instrument_id = dim.instrument_id
                   and dim.instrument_type_id = irmf.instrument_type_id
                   and dt.corporate_id = ak.corporate_id
                   and drm.period_type_id = pm.period_type_id(+)
                   and dim.product_derivative_id = pdd.derivative_def_id
                   and pdd.product_id = pdm.product_id
                   and dt.trade_price_unit_id = pum.price_unit_id(+)
                   and dt.broker_comm_cur_id = cm_comm.cur_id(+)
                   and dt.clearer_comm_cur_id = cm_cl_comm.cur_id(+)
                   and dt.quantity_unit_id = qum.qty_unit_id
                   and pdm.base_quantity_unit = pdm_qum.qty_unit_id
                   and pum.cur_id = cm_val.cur_id(+)
                   and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
                   and dt.premium_discount_price_unit_id =
                       pum_pd.price_unit_id(+)
                   and dt.profit_center_id = cpc.profit_center_id
                   and cpc.business_line_id = blm.business_line_id(+)
                   and cm_val.cur_id = scd.sub_cur_id(+)
                   and dt.strategy_id = css.strategy_id(+)
                      --   and irmf.is_active = 'Y'
                      --   and irmf.is_deleted = 'N'
                   and dt.status = 'Verified'
                   and akcu.user_id = dt.trader_id
                   and dt.clearer_account_id = bca.account_id(+)
                   and dpm.purpose_id = dt.purpose_id
                   and cmak.cur_id = ak.base_cur_id
                   and dt.clearer_comm_type_id = bct.commission_type_id(+)
                   and dt.quality_id = qat.quality_id(+)
                   and dt.price_source_id = ps.price_source_id(+)
                   and dt.price_point_id = pp.price_point_id(+)
                   and dt.settlement_price_unit_id =
                       pum_sett.price_unit_id(+)
                   and nvl(dt.traded_on, 'OTC') = 'OTC'
                   and dt.nominee_profile_id = phd_nomine.profileid(+)
                   and dt.cp_profile_id = phd_cp.profileid(+)
                   and dt.quantity_unit_id = ucm.from_qty_unit_id
                   and pdm.base_quantity_unit = ucm.to_qty_unit_id
                   and dt.market_location_country = cym.country_id(+)
                   and dt.market_location_state = sm.state_id(+)
                   and dt.market_location_city = cim.city_id(+)
                   and dt.deal_type_id = dtm.deal_type_id
                   and dt.payment_term = pym.payment_term_id(+)
                   and dt.internal_derivative_ref_no =
                       dt_leg1.internal_derivative_ref_no(+)
                   and dt.internal_derivative_ref_no =
                       dt_leg2.internal_derivative_ref_no(+)
                   and dt.internal_derivative_ref_no =
                       dt_fbi.internal_derivative_ref_no(+)) t
        /*bcs_broker_commission_setup bcs,
                                       pum_price_unit_master pum_clear
                                 where t.commission_type_id = bcs.commission_type_id(+)
                                   and bcs.price_unit_id = pum_clear.price_unit_id(+)
                                   and t.corporate_id = bcs.corporate_id(+)
                                   and bcs.future_option_type(+) = t.instrument_type_id*/
        ) temp,
       (select dtavg.internal_derivative_ref_no,
               round(sum((case
                           when dtavg.period_date <= trunc(sysdate) then
                            dtavg.quantity
                           else
                            0
                         end)),
                     2) fixed_qty,
               round(sum((case
                           when dtavg.period_date > trunc(sysdate) then
                            dtavg.quantity
                           else
                            0
                         end)),
                     2) unfixed_qty
          from dt_avg dtavg
         group by dtavg.internal_derivative_ref_no) t1
 where temp.internal_derivative_ref_no = t1.internal_derivative_ref_no(+);
