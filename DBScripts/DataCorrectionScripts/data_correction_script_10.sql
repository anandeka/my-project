-- Created on 8/07/2012
declare
  cursor gmr_fm_status_cur is
    select gmr.internal_gmr_ref_no,
           (case
             when (select distinct ypd.internal_gmr_ref_no
                     from ypd_yield_pct_detail ypd
                    where ypd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                      and ypd.is_active = 'Y'
                      and gmr.is_pass_through = 'Y') is not null then
              'Y'
             when gmr.is_pass_through = 'N' then
              'N/A'
             else
              'N'
           end) free_material_status
      from gmr_goods_movement_record gmr
     where nvl(gmr.tolling_gmr_type, 'None Tolling') in
           ('Mark For Tolling', 'Received Materials', 'Return Material')
       and gmr.is_deleted = 'N';

begin

  for gmr_fms_rows in gmr_fm_status_cur
  loop
  
    update gmr_goods_movement_record gmr
       set gmr.free_material_status = gmr_fms_rows.free_material_status
     where gmr.internal_gmr_ref_no = gmr_fms_rows.internal_gmr_ref_no;
  end loop;
end;