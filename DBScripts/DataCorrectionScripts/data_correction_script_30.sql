
DECLARE
   CURSOR gmr_per_grd_table
   IS
      SELECT   gmr.internal_gmr_ref_no, agrd.internal_grd_ref_no,
               agrd.shipped_net_qty, agrd.qty, agrd.shipped_gross_qty,
               agrd.gross_weight
          FROM gmr_goods_movement_record gmr, agrd_action_grd agrd
         WHERE gmr.gmr_latest_action_action_id = 'warehouseReceipt'
           AND gmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
           AND NVL (gmr.is_internal_movement, 'N') = 'N'
           AND agrd.is_deleted = 'N'
           AND gmr.is_deleted = 'N'
      ORDER BY gmr.internal_gmr_ref_no ASC;
      
BEGIN
   FOR gmr_per_grd_table_curr_row IN gmr_per_grd_table
   LOOP
      UPDATE grd_goods_record_detail grd
         SET grd.shipped_net_qty = gmr_per_grd_table_curr_row.qty,
             grd.shipped_gross_qty = gmr_per_grd_table_curr_row.gross_weight
       WHERE grd.internal_grd_ref_no =
                                gmr_per_grd_table_curr_row.internal_grd_ref_no
         AND grd.internal_gmr_ref_no =
                                gmr_per_grd_table_curr_row.internal_gmr_ref_no;

      UPDATE agrd_action_grd agrd
         SET agrd.shipped_net_qty = gmr_per_grd_table_curr_row.qty,
             agrd.shipped_gross_qty = gmr_per_grd_table_curr_row.gross_weight
       WHERE agrd.internal_grd_ref_no =
                                gmr_per_grd_table_curr_row.internal_grd_ref_no
         AND agrd.internal_gmr_ref_no =
                                gmr_per_grd_table_curr_row.internal_gmr_ref_no;
   END LOOP;
END;