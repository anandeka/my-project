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
