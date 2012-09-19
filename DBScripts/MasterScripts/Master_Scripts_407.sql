INSERT INTO pyme_payment_term_ext (pymex_id, base_date, fetch_query, is_active)
VALUES(1,'Arrival_Date','SELECT Max(axs.action_date)
  FROM gmr_goods_movement_record gmr, axs_action_summary axs
 WHERE gmr.internal_action_ref_no = axs.internal_action_ref_no
   AND gmr.gmr_latest_action_action_id = ''landingDetail''
   AND gmr.internal_gmr_ref_no in (:values)','Y');