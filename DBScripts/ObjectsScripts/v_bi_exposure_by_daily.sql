create or replace view v_bi_exposure_by_daily as
select vbi.corporate_id,
       vbi.product_id,
       vbi.product_name,
       vbi.dispay_order,
       vbi.pricing_by,
       sum(vbi.to_be_fixed_or_fixed_qty)to_be_fixed_or_fixed_qty,
       vbi.font_bold,
       vbi.base_qty_unit_id,
       vbi.base_qty_unit
  from v_bi_daily_price_exposure vbi
  group by vbi.corporate_id,
       vbi.product_id,
       vbi.product_name,
       vbi.dispay_order,
       vbi.pricing_by,
       vbi.font_bold,
       vbi.base_qty_unit_id,
       vbi.base_qty_unit
order by vbi.corporate_id,vbi.product_name,vbi.dispay_order
