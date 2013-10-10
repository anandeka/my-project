update PYME_PAYMENT_TERM_EXT pyme set PYME.FETCH_QUERY = 'SELECT MAX (axs.action_date)
  FROM gmr_goods_movement_record gmr,
       axs_action_summary axs,
       agmr_action_gmr agmr,
       gam_gmr_action_mapping gam
 WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   AND gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no
   AND gam.action_no = agmr.action_no
   AND gam.internal_action_ref_no = axs.internal_action_ref_no
   AND gmr.is_deleted = ''N''
   AND agmr.is_deleted = ''N''
   AND agmr.gmr_latest_action_action_id IN
          (''landingDetail'', ''salesLandingDetail'', ''releaseOrder'',
           ''salesWeightNote'', ''weightNote'', ''warehouseReceipt'')
   AND gmr.internal_gmr_ref_no IN (:values)' where PYME.PYMEX_ID = '1';