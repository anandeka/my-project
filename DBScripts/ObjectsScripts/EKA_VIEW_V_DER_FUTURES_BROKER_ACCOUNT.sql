create or replace view v_der_futures_broker_account as
select ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       blm.business_line_name,
       css.strategy_name,
       dt.external_ref_no,
       dt.internal_derivative_ref_no,
       dt.derivative_ref_no derivative_trade_ref_no,
       dt.trade_date deal_date,
       drm.prompt_date prompt_date,
       drm.period_type_id,
       pm.period_type_name delivery_period_type,
       nvl(phd_broker.company_long_name1, phd_broker.companyname) broker,
       nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
       pdm.product_desc commodity,
       dim.instrument_name instrument,
       dt.trade_type deal_type,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * dt.total_quantity deal_quantity,
       qum.qty_unit deal_quantity_unit,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * dt.total_lots deal_qunatity_in_lots,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * round((dt.total_quantity * nvl(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                                  dt.quantity_unit_id,
                                                                                  pdm.base_quantity_unit,
                                                                                  1),
                                             1)),
                    pdm_qum.decimals) deal_quantity_in_base_unit,
       pdm_qum.qty_unit base_quantity_unit,
       dt.trade_price deal_price,
       pum.price_unit_name deal_price_units,
       dt.clearer_comm_amt clearer_commission,
       dt.broker_comm_amt broker_commission,
       cm_comm.cur_code broker_commission_ccy,
       cm_cl_comm.cur_code clearer_commission_ccy,
       ((case
         when dt.trade_type = 'Sell' then
          1                 --bug 64292
         else
          -1
       end) * (case
         when (cm_val.is_sub_cur = 'Y') then
          round((dt.trade_price * dt.total_quantity * scd.factor *
                nvl(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                          dt.quantity_unit_id,
                                                          pum.weight_unit_id,
                                                          1),
                     1)),
                scd.main_cur_decimal)
         else
          round((dt.trade_price * dt.total_quantity *
                nvl(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                          dt.quantity_unit_id,
                                                          pum.weight_unit_id,
                                                          1),
                     1)),
                cm_val.decimals)
       end)) contract_value,
       (case
         when cm_val.is_sub_cur = 'Y' then
          scd.main_cur_code
         else
          cm_val.cur_code
       end) contract_value_currency,
       irmf.instrument_type,
       --Bug 61800 Fix starts
       emt.exchange_name,
       akcu.login_name,
       bca.account_name,
       dpm.purpose_display_name purpose_name,
       cmak.cur_code
       --Bug 61800 Fix ends
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
       --Bug 61800 Fix starts  
       EMT_EXCHANGEMASTER            emt,
       AK_CORPORATE_USER             akcu,
       bca_broker_clearer_account    bca,
       dpm_derivative_purpose_master dpm,
       cm_currency_master            cmak
--Bug 61800 Fix ends
 where dt.dr_id = drm.dr_id
   and dt.broker_profile_id = phd_broker.profileid(+)
   and dt.clearer_profile_id = phd_clr.profileid(+)
   and dt.product_id = pdm.product_id
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
   and pum.cur_id = cm_val.cur_id
   and irmf.instrument_type = 'Future'
   and dt.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id(+)
   and cm_val.cur_id = scd.sub_cur_id(+)
   and dt.strategy_id = css.strategy_id(+)
      /* and drm.is_deleted = 'N'
               and drm.is_expired = 'N'
               and dim.is_active = 'Y'
               and dim.is_deleted = 'N'*/
   and irmf.is_active = 'Y'
   and irmf.is_deleted = 'N'
      /* and pdd.is_active = 'Y'
               and pdd.is_deleted = 'N'
               and pdm.is_active = 'Y'
               and pdm.is_deleted = 'N'
               and pdd.is_active = 'Y'
               and pdd.is_deleted = 'N'*/
      --  and cm_val.is_active = 'Y'
      --  and cm_val.is_deleted = 'N'
   and dt.status = 'Verified'
      --Bug 61800 Fix starts
   and emt.exchange_code = 'LME' --Bug 63062 Fix   
   and pdd.exchange_id = emt.exchange_id
   and akcu.user_id = dt.trader_id
   and bca.account_id = dt.clearer_account_id
   and dpm.purpose_id = dt.purpose_id
   and cmak.cur_id = ak.base_cur_id
--Bug 61800 Fix end
