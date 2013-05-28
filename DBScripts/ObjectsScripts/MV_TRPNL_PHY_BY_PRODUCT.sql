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
 group by tpd.corporate_id,
          tpd.profit_center_id,
          tpd.profit_center_name,
          tpd.instrument_id,
          tpd.instrument_name,
          tpd.group_cur_code,
          tpd.group_cur_id
/
