create or replace view v_latest_pricing_assay as
select sam.internal_grd_ref_no internal_grd_ref_no,
       sam.ash_id,
       sam.prev_pricing_assay_id
  from sam_stock_assay_mapping sam
 where sam.is_active = 'Y'
   and sam.is_latest_pricing_assay = 'Y'
   and sam.internal_grd_ref_no is not null
union all
select sam.internal_dgrd_ref_no internal_grd_ref_no,
       sam.ash_id,
      sam.prev_pricing_assay_id
  from sam_stock_assay_mapping sam
 where sam.is_active = 'Y'
   and sam.is_latest_pricing_assay = 'Y'
   and sam.internal_dgrd_ref_no is not null

