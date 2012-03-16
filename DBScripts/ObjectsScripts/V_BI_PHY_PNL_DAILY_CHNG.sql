create or replace view v_bi_phy_pnl_daily_chng as
select corporate_id,
       profit_center_id,
       profit_center_name,
       product_id,
       product_name,
       current_amount,
       previous_amount,
       change change_percentage, -- as per FS change is shown as it's, not by percentage
       base_cur_code,
       base_cur_id
  from mv_unpnl_phy_by_product
