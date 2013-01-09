/* Formatted on 2013/01/09 19:11 (Formatter Plus v4.8.8) */
DECLARE
   CURSOR gmr_temp
   IS
      SELECT gmr_union.senders_ref_no, gmr_union.internal_gmr_ref_no
        FROM (SELECT sd.senders_ref_no, sd.internal_gmr_ref_no
                FROM sd_shipment_detail sd, gmr_goods_movement_record gmr
               WHERE sd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 AND gmr.is_deleted = 'N'
                 AND sd.senders_ref_no IS NOT NULL
              UNION ALL
              SELECT sad.senders_ref_no, sad.internal_gmr_ref_no
                FROM sad_shipment_advice sad, gmr_goods_movement_record gmr
               WHERE sad.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 AND gmr.is_deleted = 'N'
                 AND sad.senders_ref_no IS NOT NULL
              UNION ALL
              SELECT wrd.senders_ref_no, wrd.internal_gmr_ref_no
                FROM wrd_warehouse_receipt_detail wrd,
                     gmr_goods_movement_record gmr
               WHERE wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 AND gmr.is_deleted = 'N'
                 AND wrd.senders_ref_no IS NOT NULL) gmr_union;
BEGIN
   FOR gmr_row IN gmr_temp
   LOOP
      UPDATE gmr_goods_movement_record gmr
         SET gmr.senders_ref_no = gmr_row.senders_ref_no
       WHERE gmr.internal_gmr_ref_no = gmr_row.internal_gmr_ref_no;
   END LOOP;
END;