-- Script to insert WSISM mapping for WnS created through interface.
DECLARE
   CURSOR migrated_gmrs
   IS
      SELECT gmr.gmr_ref_no, phd.companyname,
             TO_CHAR (axs.created_date, 'day') createdday, axs.created_date,
             axs.internal_action_ref_no, gmr.internal_gmr_ref_no
        FROM gmr_goods_movement_record gmr,
             phd_profileheaderdetails phd,
             (SELECT DISTINCT ash.internal_gmr_ref_no
                         FROM ash_assay_header ash) ash1,
             axs_action_summary axs
       WHERE gmr.warehouse_profile_id = phd.profileid
         AND gmr.internal_gmr_ref_no = ash1.internal_gmr_ref_no
         AND phd.companyname = 'BOLIDEN RONNSKAR'
         AND gmr.is_deleted = 'N'
         AND gmr.internal_action_ref_no = axs.internal_action_ref_no
         AND axs.created_date > TO_DATE ('15-Mar-2013');

   assay_id   VARCHAR2 (15);
   cnt        NUMBER;
BEGIN
   cnt := 0;

-- for all migrated gmrs
   FOR mig_gmr IN migrated_gmrs
   LOOP
      DBMS_OUTPUT.put_line ('GMR :::: ' || mig_gmr.gmr_ref_no);

-- for all input stock and output assay combination
      FOR wns_stk IN
         (SELECT input_stk_t.wns_group_id,
                 input_stk_t.internal_grd_dgrd_ref_no input_stk,
                 output_stk_t.output_ash_id output_stk
            FROM (SELECT   ash.wns_group_id, wsism.internal_grd_dgrd_ref_no
                      FROM gmr_goods_movement_record gmr,
                           ash_assay_header ash,
                           wsism_ws_input_stock_mapping wsism
                     WHERE gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
                       AND gmr.gmr_ref_no = mig_gmr.gmr_ref_no
                       AND ash.assay_type = 'Weighing and Sampling Assay'
                       AND ash.is_sublots_as_stock = 'Y'
                       AND ash.is_active = 'Y'
                       AND ash.ash_id = wsism.ash_id
                  GROUP BY ash.wns_group_id, wsism.internal_grd_dgrd_ref_no) input_stk_t,
                 (SELECT   ash.wns_group_id, ash.ash_id output_ash_id
                      FROM gmr_goods_movement_record gmr,
                           ash_assay_header ash
                     WHERE gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
                       AND gmr.gmr_ref_no = mig_gmr.gmr_ref_no
                       AND ash.assay_type = 'Weighing and Sampling Assay'
                       AND ash.is_sublots_as_stock = 'Y'
                       AND ash.is_active = 'Y'
                  GROUP BY ash.wns_group_id, ash.ash_id) output_stk_t
           WHERE input_stk_t.wns_group_id = output_stk_t.wns_group_id)
      LOOP
         assay_id := NULL;
         DBMS_OUTPUT.put_line (   wns_stk.wns_group_id
                               || '.....'
                               || wns_stk.input_stk
                               || '.....'
                               || wns_stk.output_stk
                              );

         BEGIN
            SELECT wsism.ash_id
              INTO assay_id
              FROM wsism_ws_input_stock_mapping wsism
             WHERE wsism.ash_id = wns_stk.output_stk
               AND wsism.internal_grd_dgrd_ref_no = wns_stk.input_stk;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               DBMS_OUTPUT.put_line ('Insert Record');

               INSERT INTO wsism_ws_input_stock_mapping
                           (ash_id, internal_grd_dgrd_ref_no, is_active
                           )
                    VALUES (wns_stk.output_stk, wns_stk.input_stk, 'Y'
                           );

               cnt := cnt + 1;
         END;

         IF assay_id IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('Record exists');
         END IF;
      END LOOP;
   END LOOP;

   DBMS_OUTPUT.put_line ('Records inserted : ' || cnt);
END;
/