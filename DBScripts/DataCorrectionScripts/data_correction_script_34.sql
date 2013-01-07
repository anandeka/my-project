

UPDATE gmr_goods_movement_record gmr
   SET gmr.shipped_qty = gmr.qty
 WHERE gmr.gmr_latest_action_action_id in ('warehouseReceipt')
   AND NVL (gmr.is_internal_movement, 'N') = 'N'
   AND gmr.is_deleted = 'N';
   
UPDATE AGMR_ACTION_GMR agmr
   SET agmr.shipped_qty = agmr.qty
 WHERE agmr.gmr_latest_action_action_id in ('warehouseReceipt')
   AND NVL (agmr.is_internal_movement, 'N') = 'N'
   AND agmr.is_deleted = 'N'