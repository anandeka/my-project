/* Formatted on 2013/11/04 16:52 (Formatter Plus v4.8.8) */

CREATE OR REPLACE FORCE VIEW v_stock_container_data
AS
   SELECT agrd.internal_gmr_ref_no, agrd.internal_grd_ref_no,
          agrd.container_no, agrd.product_id, agrd.quality_id,
          agrd.internal_stock_ref_no stock_ref_no,
          agmr.is_apply_container_charge
     FROM agmr_action_gmr agmr, agrd_action_grd agrd
    WHERE agrd.action_no = agmr.action_no
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.status = 'Active'
      AND agrd.is_deleted = 'N'
      AND agmr.gmr_latest_action_action_id IN
             ('airDetail', 'railDetail', 'truckDetail', 'shipmentDetail',
              'warehouseReceipt')
      AND agmr.is_internal_movement = 'N'
      AND agmr.is_deleted = 'N'
   UNION
   SELECT agrd.internal_gmr_ref_no, agrd.internal_dgrd_ref_no,
          agrd.container_no, agrd.product_id, agrd.quality_id,
          agrd.internal_stock_ref_no stock_ref_no,
          agmr.is_apply_container_charge
     FROM agmr_action_gmr agmr, adgrd_action_dgrd agrd
    WHERE agrd.action_no = agmr.action_no
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.status = 'Active'
      AND agmr.gmr_latest_action_action_id IN
             ('shipmentAdvise', 'truckAdvice', 'airAdvice', 'railAdvice',
              'releaseOrder')
      AND agmr.is_internal_movement = 'N'
      AND agmr.is_deleted = 'N'