create or replace view v_bi_derivative as
select temp.derivative_ref_no,
       temp.origional_trade_ref_no,
       temp.parent_int_derivative_ref_no,
       temp.external_ref_no,
       temp.internal_derivative_ref_no,
       temp.underlying_instrument_id,
       temp.master_contract_id,
       temp.trade_date,
       temp. trade_year_month,
       temp.trade_year,
       temp.trader,
       temp.deal_type,
       temp.instrument_name,
       temp.deal_quantity_in_base_unit,
       temp.base_quantity_unit,
       temp.total_lots,
       temp.open_lots,
       temp.closed_lots,
       temp.exercised_lots,
       temp.expired_lots,
       temp.status,
       temp.deal_price,
       temp.deal_price_unit,
       temp.strike_price,
       temp.strike_price_unit,
       temp.premium_discount,
       temp.premium_discount_price_unit,
       temp.period_type_name,
       temp.prompt_date,
       temp.prompt_year_month,
       temp.prompt_year,
       temp.clearer,
       temp.clearer_comm_type,
       temp.account_name,
       temp.clearer_commission,
       temp.clearer_commission_unit,
       temp.broker,
       temp.broker_comm_type,
       temp.broker_commission,
       temp.broker_commission_ccy,
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
       null attribute5

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
               dt.trade_type deal_type,
               dim.instrument_name,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) *
               round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                     pdm_qum.decimals) deal_quantity_in_base_unit,
               pdm_qum.qty_unit base_quantity_unit,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.total_lots total_lots,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.open_lots open_lots,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.closed_lots closed_lots,
               null exercised_lots,
               null expired_lots,
               dt.status,
               dt.trade_price deal_price,
               pum.price_unit_name deal_price_unit,
               null strike_price,
               null strike_price_unit,
               null premium_discount,
               null premium_discount_price_unit,
               pm.period_type_name,
               drm.prompt_date prompt_date,
               to_char(drm.prompt_date, 'yyyy-mm') prompt_year_month,
               to_char(drm.prompt_date, 'yyyy') prompt_year,
               nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
               /*bcs.clearing_fee || (case
                                when bcs.trade_type = 'Percentage' then
                                 '% ' || bct.settlement_type
                                else
                                 pum_clear.price_unit_name||' ' ||bct.settlement_type
                              end)*/
               bct.commission_type_name clearer_comm_type,
               bca.account_name,
               dt.clearer_comm_amt clearer_commission,
               cm_cl_comm.cur_code clearer_commission_unit,
               nvl(phd_broker.company_long_name1, phd_broker.companyname) broker,
               bct.settlement_type broker_comm_type,
               dt.broker_comm_amt broker_commission,
               cm_comm.cur_code broker_commission_ccy,
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
                 when dt.trade_type = 'Sell' then
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
               dt.total_quantity trade_qty,
               dt.quantity_unit_id trade_qty_unit_id,
               qum.qty_unit trade_qty_unit,
               null priced_qty, --CIQS
               null unprice_qt
          from dt_derivative_trade          dt,
               cpc_corporate_profit_center  cpc,
               blm_business_line_master     blm,
               css_corporate_strategy_setup css,
               ak_corporate                 ak,
               drm_derivative_master        drm,
               phd_profileheaderdetails     phd_broker,
               phd_profileheaderdetails     phd_clr,
               dim_der_instrument_master    dim,
               /*dim_der_instrument_master dim_under,*/
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
                  from scd_sub_currency_detail scd, cm_currency_master cm
                 where scd.cur_id = cm.cur_id) scd,
               emt_exchangemaster emt,
               ak_corporate_user akcu,
               bca_broker_clearer_account bca,
               dpm_derivative_purpose_master dpm,
               cm_currency_master cmak,
               bct_broker_commission_types bct,
               bcs_broker_commission_setup bcs,
               ps_price_source ps,
               pp_price_point pp,
               pum_price_unit_master pum_sett,
               phd_profileheaderdetails phd_nomine,
               phd_profileheaderdetails phd_cp,
               ucm_unit_conversion_master ucm,
               pum_price_unit_master pum_clear
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
           and irmf.is_active = 'Y'
           and irmf.is_deleted = 'N'
           and dt.status = 'Verified'
              /*and emt.exchange_code = 'LME' */
           and pdd.exchange_id = emt.exchange_id
           and akcu.user_id = dt.trader_id
           and bca.account_id = dt.clearer_account_id
           and dpm.purpose_id = dt.purpose_id
           and cmak.cur_id = ak.base_cur_id
           and dt.clearer_comm_type_id = bct.commission_type_id(+)
           and bct.commission_type_id = bcs.commission_type_id(+)
           and dim.instrument_type_id = bcs.future_option_type
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
           and bcs.price_unit_id = pum_clear.price_unit_id(+)
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
               t. trader,
               t.deal_type,
               t.instrument_name,
               t.deal_quantity_in_base_unit,
               t.base_quantity_unit,
               t.total_lots,
               t.open_lots,
               t.closed_lots,
               t.exercised_lots,
               t.expired_lots,
               t.status,
               t.deal_price,
               t.deal_price_unit,
               t.strike_price,
               t.strike_price_unit,
               t.premium_discount,
               t.premium_discount_price_unit,
               t.period_type_name,
               t. prompt_date,
               t. trade_year_month,
               t.prompt_year,
               t. clearer,
               /*bcs.clearing_fee || (case
                                when bcs.trade_type = 'Percentage' then
                                 '% ' || t.settlement_type
                                else
                                 pum_clear.price_unit_name||' '|| t.settlement_type
                              end)*/
               t.commission_type_name clearer_comm_type,
               t.account_name,
               t.clearer_commission,
               t.clearer_commission_unit,
               t. broker,
               t. broker_comm_type,
               t. broker_commission,
               t. broker_commission_ccy,
               t. option_type,
               t.expiry_date,
               t. expiry_month_year,
               t. product,
               t.quality_name,
               t. market_location,
               t. counter_party,
               t.average_from_date,
               t.average_to_date,
               t.payment_term,
               t.payment_due_date,
               t. internal_trade_no,
               t. pay_details,
               t. receive_details,
               t.profit_center_id,
               t.profit_center_name,
               t.profit_center_short_name,
               t. trade_basics,
               t.price_source_name,
               t.price_point_name,
               t.sett_ccy,
               t.instrument_type,
               t. nominee,
               t. purpose_name,
               t.corporate_id cor_id,
               t.corporate_name,
               t.business_line_name,
               t.strategy_id,
               t.strategy_name,
               t.remarks,
               null exchnage_name,
               t. contract_value,
               t. contract_value_unit,
               t.base_ccy,
               t. fx_to_base,
               t.trade_qty,
               t.trade_qty_unit_id,
               t.trade_qty_unit,
               t. priced_qty,
               t. unprice_qt
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
                       dt.trade_type deal_type,
                       dim.instrument_name,
                       (case
                         when dt.trade_type = 'Sell' then
                          -1
                         else
                          1
                       end) * round((dt.total_quantity *
                                    nvl(ucm.multiplication_factor, 1)),
                                    pdm_qum.decimals) deal_quantity_in_base_unit,
                       pdm_qum.qty_unit base_quantity_unit,
                       (case
                         when dt.trade_type = 'Sell' then
                          -1
                         else
                          1
                       end) * dt.total_lots total_lots,
                       (case
                         when dt.trade_type = 'Sell' then
                          -1
                         else
                          1
                       end) * dt.open_lots open_lots,
                       (case
                         when dt.trade_type = 'Sell' then
                          -1
                         else
                          1
                       end) * dt.closed_lots closed_lots,
                       dt.exercised_lots,
                       dt.expired_lots,
                       dt.status,
                       dt.trade_price deal_price,
                       pum.price_unit_name deal_price_unit,
                       dt.strike_price,
                       pum_strik.price_unit_name strike_price_unit,
                       dt.premium_discount,
                       pum_pd.price_unit_name premium_discount_price_unit,
                       pm.period_type_name,
                       drm.prompt_date prompt_date,
                       to_char(drm.prompt_date, 'yyyy-mm') prompt_year_month,
                       to_char(drm.prompt_date, 'yyyy') prompt_year,
                       nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
                       bct.settlement_type,
                       bca.account_name,
                       dt.clearer_comm_amt clearer_commission,
                       cm_cl_comm.cur_code clearer_commission_unit,
                       nvl(phd_broker.company_long_name1,
                           phd_broker.companyname) broker,
                       bct.settlement_type broker_comm_type,
                       dt.broker_comm_amt broker_commission,
                       cm_comm.cur_code broker_commission_ccy,
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
                       dt.payment_term,
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
                         when dt.trade_type = 'Sell' then
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
                       dt.total_quantity trade_qty,
                       dt.quantity_unit_id trade_qty_unit_id,
                       qum.qty_unit trade_qty_unit,
                       null priced_qty,
                       null unprice_qt
                
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
                       cim_citymaster cim
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
                   and irmf.is_active = 'Y'
                   and irmf.is_deleted = 'N'
                   and dt.status = 'Verified'
                   and akcu.user_id = dt.trader_id
                   and dt.clearer_account_id = bca.account_id(+)
                   and dpm.purpose_id = dt.purpose_id
                   and cmak.cur_id = ak.base_cur_id
                   and dt.clearer_comm_type_id = bct.commission_type_id(+)
                   and dt.quality_id = qat.quality_id(+)
                      /*and qat.instrument_id = pdd.derivative_def_id
                                                                                                                                                                     and pdm.product_id = qat.product_id
                                                                                                                                                                     and qat.instrument_id = pdd.derivative_def_id(+)*/
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
                   and dt.market_location_city = cim.city_id(+)) t,
               bcs_broker_commission_setup bcs,
               pum_price_unit_master pum_clear
         where t.commission_type_id = bcs.commission_type_id(+)
           and bcs.price_unit_id = pum_clear.price_unit_id(+)
           and t.corporate_id = bcs.corporate_id(+)
           and bcs.future_option_type(+) = t.instrument_type_id) temp,
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