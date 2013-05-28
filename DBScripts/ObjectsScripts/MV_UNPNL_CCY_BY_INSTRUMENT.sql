DROP TABLE MV_UNPNL_CCY_BY_INSTRUMENT;
DROP MATERIALIZED VIEW MV_UNPNL_CCY_BY_INSTRUMENT;
CREATE MATERIALIZED VIEW MV_UNPNL_CCY_BY_INSTRUMENT
REFRESH FORCE ON DEMAND as
select aa.corporate_id,
       aa.profit_center_id,
       aa.profit_center_name,
       aa.product_name,
       aa.currency_def_id cur_pair_id,
       aa.derivative_name cur_pair_name,
       aa.corp_cur_id,
       aa.corp_currency,
       sum(decode(aa.process_id,
                  led.latest_process_id,
                  aa.pnl_in_corp_currency,
                  0)) current_amount,
       sum(decode(aa.process_id,
                  led.previous_process_id,
                  aa.pnl_in_corp_currency,
                  0)) previous_amount,
       sum(decode(aa.process_id,
                  led.latest_process_id,
                  aa.pnl_in_corp_currency,
                  0)) - sum(decode(aa.process_id,
                                   led.previous_process_id,
                                   aa.pnl_in_corp_currency,
                                   0)) change
  from cpd_currency_pnl_daily@eka_eoddb aa,
       mv_latest_eod_dates              led
 where aa.corporate_id = led.corporate_id
   and (aa.process_id = led.latest_process_id or
       aa.process_id = led.previous_process_id)
   and pnl_type = 'UNREALIZED'
 group by aa.corporate_id,
          aa.profit_center_id,
          aa.profit_center_name,
          aa.product_name,
          currency_def_id,
          derivative_name,
          aa.corp_cur_id,
          aa.corp_currency
/
