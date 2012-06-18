select gmr.internal_gmr_ref_no as int_mft_ref_no,
       gmr.gmr_ref_no as mft_ref_no,
       axs.eff_date,
       grd.parent_internal_grd_ref_no as consumed_stock,
       parent_grd.internal_stock_ref_no as consumed_stock_ref_no,
       parent_grd.internal_gmr_ref_no as consumed_int_gmr_ref_no,
       parent_gmr.gmr_ref_no as consumed_gmr_ref_no,
       grd.supp_internal_gmr_ref_no as supp_int_gmr_ref_no,
       supp_gmr.gmr_ref_no as supp_gmr_ref_no,
       grd.qty as consumed_qty,
       qum.qty_unit as consumed_qty_unit
  from gmr_goods_movement_record gmr,
       axs_action_summary        axs,
       grd_goods_record_detail   grd,
       grd_goods_record_detail   parent_grd,
       gmr_goods_movement_record parent_gmr,
       gmr_goods_movement_record supp_gmr,
       qum_quantity_unit_master  qum
 where gmr.gmr_latest_action_action_id = 'MARK_FOR_TOLLING'
   and gmr.is_deleted = 'N'
   and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and axs.internal_action_ref_no = gmr.gmr_first_int_action_ref_no
   and grd.tolling_stock_type = 'Clone Stock'
   and grd.is_deleted = 'N'
   and grd.parent_internal_grd_ref_no = parent_grd.internal_grd_ref_no
   and parent_gmr.internal_gmr_ref_no = parent_grd.internal_gmr_ref_no
   and supp_gmr.internal_gmr_ref_no = grd.supp_internal_gmr_ref_no
   and qum.qty_unit_id = grd.qty_unit_id
   --and gmr.internal_gmr_ref_no = 'GMR-844'
   order by mft_ref_no;
