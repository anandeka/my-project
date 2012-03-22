DROP TABLE MV_TRPNL_NET_BY_PROFITCENTER;
DROP MATERIALIZED VIEW MV_TRPNL_NET_BY_PROFITCENTER;
CREATE MATERIALIZED VIEW MV_TRPNL_NET_BY_PROFITCENTER
REFRESH FORCE ON DEMAND as
select t.corporate_id,
       t.profit_center_id,
       t.profit_center_name,
       sum(t.today_unrealized) today_unrealized,
       sum(t.today_realized) today_realized,
       sum(t.today_total) today_total,
       sum(t.month_unrealized) month_unrealized,
       sum(t.month_realized) month_realized,
       sum(t.month_total) month_total,
       sum(t.year_unrealized) year_unrealized,
       sum(t.year_realized) year_realized,
       sum(t.year_total) year_total,
       t.base_cur_code,
       t.base_cur_id
  from (select tpd.corporate_id,
               tpd.profit_center_id,
               tpd.profit_center_name,
               sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) today_unrealized,
               sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_realized,
               sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) +
               sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_total,
               sum(decode(tpd.sub_section,
                          'Unrealized',
                          tpd.month_to_date_pnl,
                          0)) month_unrealized,
               sum(decode(tpd.sub_section,
                          'Realized',
                          tpd.month_to_date_pnl,
                          0)) month_realized,
               sum(decode(tpd.sub_section,
                          'Unrealized',
                          tpd.month_to_date_pnl,
                          0)) + sum(decode(tpd.sub_section,
                                           'Realized',
                                           tpd.month_to_date_pnl,
                                           0)) month_total,
               sum(decode(tpd.sub_section,
                          'Unrealized',
                          tpd.year_to_date_pnl,
                          0)) year_unrealized,
               sum(decode(tpd.sub_section,
                          'Realized',
                          tpd.year_to_date_pnl,
                          0)) year_realized,
               sum(decode(tpd.sub_section,
                          'Unrealized',
                          tpd.year_to_date_pnl,
                          0)) + sum(decode(tpd.sub_section,
                                           'Realized',
                                           tpd.year_to_date_pnl,
                                           0)) year_total,
               tpd.group_cur_code base_cur_code,
               tpd.group_cur_id base_cur_id
          from tpd_trade_pnl_daily@eka_eoddb tpd,
               mv_latest_eod_dates           led
         where tpd.main_section in ('Physical', 'Currency', 'Futures',
                'Forwards', 'Options', 'Average')
           and tpd.process_id = led.latest_process_id(+)
     and tpd.corporate_id = led.corporate_id
         group by tpd.corporate_id,
                  tpd.profit_center_id,
                  tpd.profit_center_name,
                  tpd.group_cur_code,
                  tpd.group_cur_id
        union all
        select tpd.corporate_id,
               tpd.profit_center_id,
               tpd.profit_center_name,
               sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) today_unrealized,
               sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_realized,
               sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) +
               sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_total,
               sum(decode(tpd.sub_section,
                          'Unrealized',
                          tpd.month_to_date_pnl,
                          0)) month_unrealized,
               sum(decode(tpd.sub_section,
                          'Realized',
                          tpd.month_to_date_pnl,
                          0)) month_realized,
               sum(decode(tpd.sub_section,
                          'Unrealized',
                          tpd.month_to_date_pnl,
                          0)) + sum(decode(tpd.sub_section,
                                           'Realized',
                                           tpd.month_to_date_pnl,
                                           0)) month_total,
               sum(decode(tpd.sub_section,
                          'Unrealized',
                          tpd.year_to_date_pnl,
                          0)) year_unrealized,
               sum(decode(tpd.sub_section,
                          'Realized',
                          tpd.year_to_date_pnl,
                          0)) year_realized,
               sum(decode(tpd.sub_section,
                          'Unrealized',
                          tpd.year_to_date_pnl,
                          0)) + sum(decode(tpd.sub_section,
                                           'Realized',
                                           tpd.year_to_date_pnl,
                                           0)) year_total,
               tpd.group_cur_code base_cur_code,
               tpd.group_cur_id base_cur_id
          from dtp_derivative_trade_pnl@eka_eoddb tpd,
               mv_latest_eod_dates                led
         where tpd.main_section in
               ('Currency', 'Futures', 'Forwards', 'Options', 'Average')
           and tpd.process_id = led.latest_process_id(+)
     and tpd.corporate_id = led.corporate_id
         group by tpd.corporate_id,
                  tpd.profit_center_id,
                  tpd.profit_center_name,
                  tpd.group_cur_code,
                  tpd.group_cur_id) t
 group by t.corporate_id,
          t.profit_center_id,
          t.profit_center_name,
          t.base_cur_code,
          t.base_cur_id
/
---------
DROP TABLE MV_TRPNL_PHY_BY_PRODUCT;
DROP MATERIALIZED VIEW MV_TRPNL_PHY_BY_PRODUCT;
CREATE MATERIALIZED VIEW MV_TRPNL_PHY_BY_PRODUCT
REFRESH FORCE ON DEMAND as
select tpd.corporate_id,
       tpd.profit_center_id,
       tpd.profit_center_name,
       tpd.instrument_id product_id,
       tpd.instrument_name product_name,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) today_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_total,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.month_to_date_pnl, 0)) month_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.month_to_date_pnl, 0)) month_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.month_to_date_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.month_to_date_pnl, 0)) month_total,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.year_to_date_pnl, 0)) year_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.year_to_date_pnl, 0)) year_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.year_to_date_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.year_to_date_pnl, 0)) year_total,
       tpd.group_cur_code base_cur_code,
       tpd.group_cur_id base_cur_id
  from tpd_trade_pnl_daily@eka_eoddb tpd,
       mv_latest_eod_dates           led
 where tpd.main_section = 'Physical'
   and tpd.process_id = led.latest_process_id(+)
   and tpd.corporate_id = led.corporate_id
 group by tpd.corporate_id,
          tpd.profit_center_id,
          tpd.profit_center_name,
          tpd.instrument_id,
          tpd.instrument_name,
          tpd.group_cur_code,
          tpd.group_cur_id
/
-------------
DROP TABLE MV_TRPNL_DRT_BY_INSTRUMENT;
DROP MATERIALIZED VIEW MV_TRPNL_DRT_BY_INSTRUMENT;
CREATE MATERIALIZED VIEW MV_TRPNL_DRT_BY_INSTRUMENT
REFRESH FORCE ON DEMAND as
--create or replace view v_consol_der_pnl as
select tpd.corporate_id,
       tpd.profit_center_id,
       tpd.profit_center_name,
       tpd.instrument_id,
       tpd.instrument_name,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) today_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_total,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.month_to_date_pnl, 0)) month_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.month_to_date_pnl, 0)) month_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.month_to_date_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.month_to_date_pnl, 0)) month_total,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.year_to_date_pnl, 0)) year_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.year_to_date_pnl, 0)) year_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.year_to_date_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.year_to_date_pnl, 0)) year_total,
       tpd.group_cur_code base_cur_code,
       tpd.group_cur_id base_cur_id
  from dtp_derivative_trade_pnl@eka_eoddb tpd,
       mv_latest_eod_dates      led
 where tpd.main_section in ('Futures', 'Forwards', 'Options', 'Average')
   and tpd.process_id = led.latest_process_id(+)
   and tpd.corporate_id = led.corporate_id
 group by tpd.corporate_id,
          tpd.profit_center_id,
          tpd.profit_center_name,
          tpd.instrument_id,
          tpd.instrument_name,
          tpd.group_cur_code,
          tpd.group_cur_id
/
----------
DROP TABLE MV_TRPNL_CCY_BY_INSTRUMENT;
DROP MATERIALIZED VIEW MV_TRPNL_CCY_BY_INSTRUMENT;
CREATE MATERIALIZED VIEW MV_TRPNL_CCY_BY_INSTRUMENT
REFRESH FORCE ON DEMAND as
select tpd.corporate_id,
       tpd.profit_center_id,
       tpd.profit_center_name,
       tpd.instrument_id currency_pair_id,
       tpd.instrument_name currency_pair_name,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) today_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.today_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.today_pnl, 0)) today_total,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.month_to_date_pnl, 0)) month_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.month_to_date_pnl, 0)) month_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.month_to_date_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.month_to_date_pnl, 0)) month_total,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.year_to_date_pnl, 0)) year_unrealized,
       sum(decode(tpd.sub_section, 'Realized', tpd.year_to_date_pnl, 0)) year_realized,
       sum(decode(tpd.sub_section, 'Unrealized', tpd.year_to_date_pnl, 0)) +
       sum(decode(tpd.sub_section, 'Realized', tpd.year_to_date_pnl, 0)) year_total,
       tpd.group_cur_code base_cur_code,
       tpd.group_cur_id base_cur_id
  from dtp_derivative_trade_pnl@eka_eoddb tpd,
       mv_latest_eod_dates                led
 where tpd.main_section = 'Currency'
   and tpd.process_id = led.latest_process_id(+)
   and tpd.corporate_id = led.corporate_id
 group by tpd.corporate_id,
          tpd.profit_center_id,
          tpd.profit_center_name,
          tpd.instrument_id,
          tpd.instrument_name,
          tpd.group_cur_code,
          tpd.group_cur_id
/
---------
