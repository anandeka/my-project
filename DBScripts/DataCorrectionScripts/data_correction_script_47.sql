/* Formatted on 2013/04/23 12:34 (Formatter Plus v4.8.8) */
DECLARE
   CURSOR gmr_gth_temp
   IS
      SELECT gth.gth_id, gth.internal_gmr_ref_no, gth.pcdi_id, gth.pcth_id,
             gmr.gmr_first_int_action_ref_no, gth.is_active
        FROM gth_gmr_treatment_header gth, gmr_goods_movement_record gmr
       WHERE gth.is_active = 'Y'
         AND gmr.internal_gmr_ref_no = gth.internal_gmr_ref_no;
BEGIN
   FOR gth_row IN gmr_gth_temp
   LOOP
      INSERT INTO gthul_gmr_treatment_header_ul
                  (gthul_id, gth_id, entry_type,
                   internal_gmr_ref_no, pcdi_id,
                   pcth_id, internal_action_ref_no,
                   is_active
                  )
           VALUES (seq_gthul.NEXTVAL, gth_row.gth_id, 'Insert',
                   gth_row.internal_gmr_ref_no, gth_row.pcdi_id,
                   gth_row.pcth_id, gth_row.gmr_first_int_action_ref_no,
                   gth_row.is_active
                  );
   END LOOP;
END;



/* Formatted on 2013/04/23 12:38 (Formatter Plus v4.8.8) */
DECLARE
   CURSOR gmr_grh_temp
   IS
      SELECT grh.grh_id, grh.internal_gmr_ref_no, grh.pcdi_id, grh.pcrh_id,
             gmr.gmr_first_int_action_ref_no, grh.is_active
        FROM grh_gmr_refining_header grh, gmr_goods_movement_record gmr
       WHERE grh.is_active = 'Y'
         AND gmr.internal_gmr_ref_no = grh.internal_gmr_ref_no;
BEGIN
   FOR grh_row IN gmr_grh_temp
   LOOP
      INSERT INTO grhul_gmr_refining_header_ul
                  (grhul_id, grh_id, entry_type,
                   internal_gmr_ref_no, pcdi_id,
                   pcrh_id, internal_action_ref_no,
                   is_active
                  )
           VALUES (seq_grhul.NEXTVAL, grh_row.grh_id, 'Insert',
                   grh_row.internal_gmr_ref_no, grh_row.pcdi_id,
                   grh_row.pcrh_id, grh_row.gmr_first_int_action_ref_no,
                   grh_row.is_active
                  );
   END LOOP;
END;



/* Formatted on 2013/04/23 12:43 (Formatter Plus v4.8.8) */
DECLARE
   CURSOR gmr_gph_temp
   IS
      SELECT gph.gph_id, gph.internal_gmr_ref_no, gph.pcdi_id, gph.pcaph_id,
             gmr.gmr_first_int_action_ref_no, gph.is_active
        FROM gph_gmr_penalty_header gph, gmr_goods_movement_record gmr
       WHERE gph.is_active = 'Y'
         AND gmr.internal_gmr_ref_no = gph.internal_gmr_ref_no;
BEGIN
   FOR gph_row IN gmr_gph_temp
   LOOP
      INSERT INTO gphul_gmr_penalty_header_ul
                  (gphul_id, gph_id, entry_type,
                   internal_gmr_ref_no, pcdi_id,
                   pcaph_id, internal_action_ref_no,
                   is_active
                  )
           VALUES (seq_gphul.NEXTVAL, gph_row.gph_id, 'Insert',
                   gph_row.internal_gmr_ref_no, gph_row.pcdi_id,
                   gph_row.pcaph_id, gph_row.gmr_first_int_action_ref_no,
                   gph_row.is_active
                  );
   END LOOP;
END;s