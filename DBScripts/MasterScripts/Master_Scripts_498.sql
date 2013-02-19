update PYME_PAYMENT_TERM_EXT pyme set PYME.FETCH_QUERY = '
SELECT distinct axs.action_date
  FROM gmr_goods_movement_record gmr,
       axs_action_summary axs,
       agrd_action_grd agrd,
       gam_gmr_action_mapping gam
 WHERE gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no
   AND gam.action_no = agrd.action_no
   AND gam.internal_gmr_ref_no = agrd.internal_gmr_ref_no
   AND gam.internal_action_ref_no = axs.internal_action_ref_no
   AND gmr.is_deleted = ''N''
   AND agrd.is_deleted = ''N''
   AND gmr.gmr_latest_action_action_id = ''landingDetail''
   AND gmr.internal_gmr_ref_no IN (:values)'
where
PYME.BASE_DATE = 'Arrival_Date';
commit;