create or replace view v_gmr_sac_qty as
select internal_gmr_ref_no,
       total_qty_in_wet,
       total_qty_in_dry,
       grd_qty_unit_id
  from (select sac.internal_gmr_ref_no,
               sum(sac.total_qty_in_wet) over(partition by sac.internal_gmr_ref_no order by sac.internal_gmr_ref_no) total_qty_in_wet,
               sum(sac.total_qty_in_dry) over(partition by sac.internal_gmr_ref_no order by sac.internal_gmr_ref_no) total_qty_in_dry,
               sac.grd_qty_unit_id
          from sac_stock_assay_content sac)
 group by internal_gmr_ref_no,
          total_qty_in_wet,
          total_qty_in_dry,
          grd_qty_unit_id
