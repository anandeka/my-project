-- Created on 7/31/2012
declare
  cursor gmr_product_cur is
    select distinct gmr_inner.internal_gmr_ref_no internal_gmr_ref_no,
                    grd.product_id                product_id
      from grd_goods_record_detail   grd,
           gmr_goods_movement_record gmr_inner
     where gmr_inner.internal_gmr_ref_no = grd.internal_gmr_ref_no
       and gmr_inner.is_deleted = 'N'
          
       and grd.status = 'Active'
       and nvl(gmr_inner.tolling_gmr_type, 'None Tolling') not in
           ('Input Process', 'Output Process', 'Mark For Tolling',
            'Received Materials', 'Pledge', 'Financial Settlement',
            'Return Material', 'Free Metal Utility')
    
    
     group by gmr_inner.internal_gmr_ref_no,
              grd.product_id
    union
    select distinct gmr_inner.internal_gmr_ref_no internal_gmr_ref_no,
                    dgrd.product_id               product_id
      from dgrd_delivered_grd        dgrd,
           gmr_goods_movement_record gmr_inner
     where gmr_inner.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
       and gmr_inner.is_deleted = 'N'
          
       and dgrd.status = 'Active'
       and nvl(gmr_inner.tolling_gmr_type, 'None Tolling') not in
           ('Input Process', 'Output Process', 'Mark For Tolling',
            'Received Materials', 'Pledge', 'Financial Settlement',
            'Return Material', 'Free Metal Utility')
    
    
     group by gmr_inner.internal_gmr_ref_no,
              dgrd.product_id;

begin

  for gmr_product_cur_rows in gmr_product_cur
  loop
    
    update gmr_goods_movement_record gmr
       set gmr.product_id = gmr_product_cur_rows.product_id
     where gmr.internal_gmr_ref_no =
           gmr_product_cur_rows.internal_gmr_ref_no;
  end loop;
end;