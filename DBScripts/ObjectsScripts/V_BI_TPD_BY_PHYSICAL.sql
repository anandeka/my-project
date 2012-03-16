create or replace view v_bi_tpd_by_physical as
select corporate_id,
       profit_center_id,
       profit_center_name,
       product_id,
       product_name,
       today_unrealized,
       today_realized,
       today_total,
       month_unrealized,
       month_realized,
       month_total,
       year_unrealized,
       year_realized,
       year_total,
       base_cur_code,
       base_cur_id
  from mv_trpnl_phy_by_product
