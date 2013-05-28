DROP TABLE MV_UNPNL_NET_BY_PROFITCENTER;
DROP MATERIALIZED VIEW MV_UNPNL_NET_BY_PROFITCENTER;
CREATE MATERIALIZED VIEW MV_UNPNL_NET_BY_PROFITCENTER
REFRESH FORCE ON DEMAND as
select ctab.corporate_id,
       ctab.profit_center_id,
       ctab.profit_center_name,
       ctab.base_cur_code,
       ctab.base_cur_id,
       sum(ctab.current_amount) current_amount,
       sum(ctab.previous_amount) previous_amount,
       sum(ctab.current_amount) - sum(ctab.previous_amount) change
  from (select aa.corporate_id,
               aa.profit_center_id,
               aa.profit_center_name,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.pnl_in_base_cur,
                          0)) current_amount,
               sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.pnl_in_base_cur,
                          0)) previous_amount,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.pnl_in_base_cur,
                          0)) - sum(decode(aa.process_id,
                                           led.previous_process_id,
                                           aa.pnl_in_base_cur,
                                           0)) change,
               base_cur_code,
               base_cur_id
          from dpd_derivative_pnl_daily@eka_eoddb aa,
               mv_latest_eod_dates       led
         where aa.corporate_id = led.corporate_id
           and (aa.process_id = led.latest_process_id or
               aa.process_id = led.previous_process_id)
           and pnl_type = 'Unrealized'
         group by aa.corporate_id,
                  aa.profit_center_id,
                  aa.profit_center_name,
                  base_cur_code,
                  base_cur_id
        union all
        select aa.corporate_id,
               aa.profit_center_id,
               aa.profit_center_name,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.pnl_value_in_home_currency,
                          0)) current_amount,
               sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.pnl_value_in_home_currency,
                          0)) previous_amount,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.pnl_value_in_home_currency,
                          0)) - sum(decode(aa.process_id,
                                           led.previous_process_id,
                                           aa.pnl_value_in_home_currency,
                                           0)) change,
               aa.home_currency base_cur_code,
               aa.home_cur_id base_cur_id
          from cpd_currency_pnl_daily@eka_eoddb aa,
               mv_latest_eod_dates     led
         where aa.corporate_id = led.corporate_id
           and (aa.process_id = led.latest_process_id or
               aa.process_id = led.previous_process_id)
           and pnl_type = 'UNREALIZED'
         group by aa.corporate_id,
                  aa.profit_center_id,
                  aa.profit_center_name,
                  aa.home_currency,
                  aa.home_cur_id
        union all
        select aa.corporate_id,
               aa.profit_center_id,
               aa.profit_center_name,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.unrealized_pnl_in_base_cur,
                          0)) current_amount,
               sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.unrealized_pnl_in_base_cur,
                          0)) previous_amount,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.unrealized_pnl_in_base_cur,
                          0)) - sum(decode(aa.process_id,
                                           led.previous_process_id,
                                           aa.unrealized_pnl_in_base_cur,
                                           0)) change,
               base_cur_code,
               base_cur_id
          from poud_phy_open_unreal_daily@eka_eoddb aa,
               mv_latest_eod_dates         led
         where aa.corporate_id = led.corporate_id
           and (aa.process_id = led.latest_process_id or
               aa.process_id = led.previous_process_id)
         group by aa.corporate_id,
                  aa.profit_center_id,
                  aa.profit_center_name,
                  base_cur_code,
                  base_cur_id
        union all
        select aa.corporate_id,
               aa.profit_center_id,
               aa.profit_center_name,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.unrealized_pnl_in_base_cur,
                          0)) current_amount,
               sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.unrealized_pnl_in_base_cur,
                          0)) previous_amount,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.unrealized_pnl_in_base_cur,
                          0)) - sum(decode(aa.process_id,
                                           led.previous_process_id,
                                           aa.unrealized_pnl_in_base_cur,
                                           0)) change,
               base_cur_code,
               base_cur_id
          from poue_phy_open_unreal_element@eka_eoddb aa,
               mv_latest_eod_dates           led
         where aa.corporate_id = led.corporate_id
           and (aa.process_id = led.latest_process_id or
               aa.process_id = led.previous_process_id)
         group by aa.corporate_id,
                  aa.profit_center_id,
                  aa.profit_center_name,
                  base_cur_code,
                  base_cur_id) ctab
 group by ctab.corporate_id,
          ctab.profit_center_id,
          ctab.profit_center_name,
          ctab.base_cur_code,
          ctab.base_cur_id
/
----------
