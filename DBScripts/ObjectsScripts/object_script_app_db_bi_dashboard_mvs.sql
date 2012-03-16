DROP TABLE MV_LATEST_EOD_DATES;
DROP MATERIALIZED VIEW MV_LATEST_EOD_DATES;
CREATE MATERIALIZED VIEW MV_LATEST_EOD_DATES
REFRESH FORCE ON DEMAND as
select aa.process,
       aa.corporate_id,
       aa.trade_date lastest_eod,
       aa.process_id latest_process_id,
       bb.trade_date previous_eod,
       bb.process_id previous_process_id
  from (select process,
               corporate_id,
               trade_date,
               process_id
          from (select process,
                       corporate_id,
                       trade_date,
                       process_id,
                       rank() over(partition by process, corporate_id order by trade_date desc) rank
                  from tdc_trade_date_closure@eka_eoddb)
         where rank in (1, 2)) aa,
       (select process,
               corporate_id,
               trade_date,
               process_id
          from (select process,
                       corporate_id,
                       trade_date,
                       process_id,
                       rank() over(partition by process, corporate_id order by trade_date desc) rank
                  from tdc_trade_date_closure@eka_eoddb)
         where rank in (1, 2)) bb
 where aa.process = bb.process
   and aa.corporate_id = bb.corporate_id
   and aa.trade_date > bb.trade_date
   and aa.process_id <> bb.process_id
   and aa.process = 'EOD'
/
------------
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
DROP TABLE MV_UNPNL_PHY_BY_PRODUCT;
DROP MATERIALIZED VIEW MV_UNPNL_PHY_BY_PRODUCT;
CREATE MATERIALIZED VIEW MV_UNPNL_PHY_BY_PRODUCT
REFRESH FORCE ON DEMAND as
select aa.corporate_id,
       aa.profit_center_id,
       aa.profit_center_name,
       aa.product_id,
       aa.product_name,
       aa.base_cur_id,
       aa.base_cur_code,
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
                                   0)) change
  from poud_phy_open_unreal_daily@eka_eoddb aa,
       mv_latest_eod_dates                  led
 where aa.corporate_id = led.corporate_id
   and (aa.process_id = led.latest_process_id or
       aa.process_id = led.previous_process_id)
 group by aa.corporate_id,
          aa.profit_center_id,
          aa.profit_center_name,
          aa.product_id,
          aa.product_name,
          aa.base_cur_id,
          aa.base_cur_code
union
select aa.corporate_id,
       aa.profit_center_id,
       aa.profit_center_name,
       aa.product_id,
       aa.product_name,
       aa.base_cur_id,
       aa.base_cur_code,
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
                                   0)) change
  from poue_phy_open_unreal_element@eka_eoddb aa,
       mv_latest_eod_dates                    led
 where aa.corporate_id = led.corporate_id
   and (aa.process_id = led.latest_process_id or
       aa.process_id = led.previous_process_id)
 group by aa.corporate_id,
          aa.profit_center_id,
          aa.profit_center_name,
          aa.product_id,
          aa.product_name,
          aa.base_cur_id,
          aa.base_cur_code
/
-----------
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
--------------
DROP TABLE MV_UNPNL_DRT_BY_INSTRUMENT;
DROP MATERIALIZED VIEW MV_UNPNL_DRT_BY_INSTRUMENT;
CREATE MATERIALIZED VIEW MV_UNPNL_DRT_BY_INSTRUMENT
REFRESH FORCE ON DEMAND as
select aa.corporate_id,
       aa.profit_center_id,
       aa.profit_center_name,
       aa.instrument_id,
       aa.instrument_name,
       aa.base_cur_id,
       aa.base_cur_code,
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
                                   0)) change
  from dpd_derivative_pnl_daily@eka_eoddb aa,
       mv_latest_eod_dates                led
 where aa.corporate_id = led.corporate_id
   and (aa.process_id = led.latest_process_id or
       aa.process_id = led.previous_process_id)
   and pnl_type = 'Unrealized'
 group by aa.corporate_id,
          aa.profit_center_id,
          aa.profit_center_name,
          aa.instrument_id,
          aa.instrument_name,
          aa.base_cur_id,
          aa.base_cur_code
/
-----------
DROP TABLE MV_UNPNL_PHY_CHANGE_BY_TRADE;
drop MATERIALIZED VIEW MV_UNPNL_PHY_CHANGE_BY_TRADE;
drop materialized view MV_UNPNL_PHY_CHANGE_BY_TRADE;
create materialized view MV_UNPNL_PHY_CHANGE_BY_TRADE
refresh force on demand
as
select corporate_id,
       profit_center_id,
       profit_center_name,
       internal_contract_item_ref_no,
       contract_ref_no,
       current_per_unit,
       previous_per_unit,
       percentage_value,
       (case
         when percentage_value < -8 then
          -10
         when percentage_value >= -8 and percentage_value < -6 then
          -8
         when percentage_value >= -6 and percentage_value < -4 then
          -6
         when percentage_value >= -4 and percentage_value < -2 then
          -4
         when percentage_value > -2 and percentage_value < 0 then
          -2
         when percentage_value >= 0 and percentage_value < 2 then
          2
         when percentage_value >= 2 and percentage_value < 4 then
          4
         when percentage_value >= 4 and percentage_value < 6 then
          6
         when percentage_value >= 6 and percentage_value < 8 then
          8
         when percentage_value >= 8 then
          10
         else
          0
       end) as change_percentage,
       base_cur_code,
       base_cur_id
  from (select aa.corporate_id,
               aa.profit_center_id,
               aa.profit_center_name,
               aa.internal_contract_item_ref_no internal_contract_item_ref_no,
               aa.contract_ref_no contract_ref_no,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.unreal_pnl_in_base_per_unit,
                          0)) current_per_unit,
               sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.unreal_pnl_in_base_per_unit,
                          0)) previous_per_unit,
               (sum(decode(aa.process_id,
                           led.latest_process_id,
                           aa.unreal_pnl_in_base_per_unit,
                           0)) - sum(decode(aa.process_id,
                                             led.previous_process_id,
                                             aa.unreal_pnl_in_base_per_unit,
                                             0))) * 100 /
               (sum(decode(aa.process_id,
                           led.previous_process_id,
                           aa.unreal_pnl_in_base_per_unit,
                           0))) percentage_value,
               aa.base_cur_code,
               aa.base_cur_id
          from poud_phy_open_unreal_daily@eka_eoddb aa,
               mv_latest_eod_dates                  led
         where aa.corporate_id = led.corporate_id
           and (aa.process_id = led.latest_process_id or
               aa.process_id = led.previous_process_id)
         group by aa.corporate_id,
                  aa.profit_center_id,
                  aa.profit_center_name,
                  aa.internal_contract_item_ref_no,
                  aa.contract_ref_no,
                  aa.base_cur_code,
                  aa.base_cur_id
having  sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.unreal_pnl_in_base_per_unit,
                          0))>0                  
        union
        select aa.corporate_id,
               aa.profit_center_id,
               aa.profit_center_name,
               aa.internal_contract_item_ref_no internal_contract_item_ref_no,
               aa.contract_ref_no,
               sum(decode(aa.process_id,
                          led.latest_process_id,
                          aa.unreal_pnl_in_base_per_unit,
                          0)) current_per_unit,
               sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.unreal_pnl_in_base_per_unit,
                          0)) previous_per_unit,
               (sum(decode(aa.process_id,
                           led.latest_process_id,
                           aa.unreal_pnl_in_base_per_unit,
                           0)) - sum(decode(aa.process_id,
                                             led.previous_process_id,
                                             aa.unreal_pnl_in_base_per_unit,
                                             0))) * 100 /
               sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.unreal_pnl_in_base_per_unit,
                          0)) percentage_value,
               aa.base_cur_code,
               aa.base_cur_id
          from poue_phy_open_unreal_element@eka_eoddb aa,
               mv_latest_eod_dates                    led
         where aa.corporate_id = led.corporate_id
           and (aa.process_id = led.latest_process_id or
               aa.process_id = led.previous_process_id)
         group by aa.corporate_id,
                  aa.profit_center_id,
                  aa.profit_center_name,
                  aa.internal_contract_item_ref_no,
                  aa.contract_ref_no,
                  aa.base_cur_code,
                  aa.base_cur_id
                  having  sum(decode(aa.process_id,
                          led.previous_process_id,
                          aa.unreal_pnl_in_base_per_unit,
                          0)) > 0
                  ) ctab
/
-------------
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
 group by tpd.corporate_id,
          tpd.profit_center_id,
          tpd.profit_center_name,
          tpd.instrument_id,
          tpd.instrument_name,
          tpd.group_cur_code,
          tpd.group_cur_id
/
---------
