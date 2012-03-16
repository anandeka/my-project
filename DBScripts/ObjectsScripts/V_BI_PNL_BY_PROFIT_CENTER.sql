create or replace view v_bi_pnl_by_profit_center as
select mvp.corporate_id,
       mvp.profit_center_id,
       mvp.profit_center_name,
       mvp.current_amount,
       mvp.previous_amount,
       mvp.change change_percentage, -- as per FS change is shown as it's, not by percentage
       mvp.base_cur_code,
       mvp.base_cur_id
  from mv_unpnl_net_by_profitcenter mvp
