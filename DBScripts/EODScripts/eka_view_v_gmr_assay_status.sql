create or replace view v_gmr_assay_status as 
select gmr.process_id,
       gmr.internal_gmr_ref_no,    
       case when  count(distinct grd.internal_grd_ref_no)=
       sum(case
             when ash.is_final_assay_fully_finalized = 'Y' then
              1
             else
              0
           end)  then
      'Assay Finalized'
      when
       sum(case
             when ash.is_final_assay_fully_finalized = 'Y' then
              1
             else
              0
           end)<>0  then
      'Partial Assay Finalized'
      else
      'Not Assay Finalized'
      end assay_final_status
  from gmr_goods_movement_record gmr,
       grd_goods_record_detail   grd,
       ash_assay_header ash
 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
   and grd.internal_grd_ref_no = ash.internal_grd_ref_no
   and gmr.process_id=grd.process_id
   and gmr.is_deleted = 'N'
   and grd.status = 'Active'
   and ash.is_active = 'Y'   
    group by gmr.internal_gmr_ref_no,
            gmr.process_id