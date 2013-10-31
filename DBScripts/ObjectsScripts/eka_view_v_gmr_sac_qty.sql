create or replace view v_gmr_sac_qty 
as
select   t.internal_gmr_ref_no, sum (t.total_qty_in_wet) total_qty_in_wet,
         sum (t.total_qty_in_dry) total_qty_in_dry,
         sum (t.current_qty_dry) current_qty_dry,
         sum (t.current_qty_wet) current_qty_wet, t.grd_qty_unit_id
    from (select   sac.internal_gmr_ref_no, sac.internal_grd_ref_no,
                   sac.total_qty_in_wet, sac.total_qty_in_dry,
                   sac.current_qty_dry, sac.current_qty_wet,
                   sac.grd_qty_unit_id
              from sac_stock_assay_content sac,
                   grd_goods_record_detail grd
              where sac.internal_grd_ref_no=grd.internal_grd_ref_no
                   and grd.status='Active'
                   and grd.is_deleted='N'                      
          group by sac.internal_gmr_ref_no,
                   sac.internal_grd_ref_no,
                   sac.total_qty_in_wet,
                   sac.total_qty_in_dry,
                   sac.current_qty_dry,
                   sac.current_qty_wet,
                   sac.grd_qty_unit_id) t
group by t.internal_gmr_ref_no, t.grd_qty_unit_id
/