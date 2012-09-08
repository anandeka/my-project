create or replace view v_bi_gmr_strategy_profit as
-- note this view has to return only one strategy,profitcenter per GMR, not more than one should not come in this view
-- this view ised in  jasper domain for strategy attributes, can be used for stock prfitcenter also
select grd.internal_gmr_ref_no,
       max(grd.strategy_id) strategy_id,
       max(grd.profit_center_id) profit_center_id
  from grd_goods_record_detail grd
 where grd.status = 'Active'
 group by grd.internal_gmr_ref_no
/ 
