drop materialized view MV_BI_UPAD;
create materialized view MV_BI_UPAD
refresh force on demand
as
select tdc.corporate_id,
       profit_center_id,
       profit_center_name,
       product_id,
       product_name,
       attribution_main_type attribution_type,
       attribution_order,
       contract_ref_no ||'-' ||del_distribution_item_no contract_ref_no ,
       contract_type,
       base_cur_code,
       base_cur_id,
       tdc.trade_date,
       prev_trade_date,
       (case
         when attribution_main_type = 'New Contract' then
          nvl(net_pnlc_in_base, 0)
         else
          nvl(pnlc_due_to_attr, 0)
       end) pnlc_due_to_attr,
       (case
         when attribution_main_type = 'New Contract' then
          nvl(net_pnlc_in_base, 0)
         else
          nvl(delta_pnlc_in_base, 0)
       end) delta_pnlc_in_base,
       nvl(net_pnlc_in_base, 0) net_pnlc_in_base
  from upad_unreal_pnl_attr_detail@eka_eoddb upad,
       tdc_trade_date_closure@eka_eoddb      tdc
 where tdc.process = 'EOD'
   and tdc.corporate_id = upad.corporate_id
   and tdc.process_id = upad.process_id
/*where (upad.corporate_id, upad.trade_date) =
       (select tdc.corporate_id,
               max(tdc.trade_date)
          from tdc_trade_date_closure@eka_eoddb tdc
         where tdc.process = 'EOD'
         group by tdc.corporate_id)*/
