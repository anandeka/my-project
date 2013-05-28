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
