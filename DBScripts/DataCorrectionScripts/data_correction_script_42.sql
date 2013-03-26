-- Script to update the WnGroupId,AssayRefNo,WnSRefNo of child assays of WnS created using Migration GMR
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

   assay_ref_no_var   VARCHAR2 (15);
   wns_group_id_var   VARCHAR2 (15);
BEGIN
   DBMS_OUTPUT.put_line ('GMRs Corrected');

   FOR mig_gmr IN migrated_gmrs
   LOOP
      assay_ref_no_var := NULL;
      wns_group_id_var := NULL;

      BEGIN
         SELECT ash.assay_ref_no, ash.wns_group_id
           INTO assay_ref_no_var, wns_group_id_var
           FROM gmr_goods_movement_record gmr, ash_assay_header ash
          WHERE gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
            AND gmr.internal_gmr_ref_no = mig_gmr.internal_gmr_ref_no
            AND ash.assay_type = 'Weighing and Sampling Assay'
            AND ash.is_sublots_as_stock = 'Y'
            AND ash.is_active = 'Y'
            AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.put_line ('No data found ' || mig_gmr.gmr_ref_no);
      END;

      IF assay_ref_no_var IS NOT NULL
      THEN
         DBMS_OUTPUT.put_line ('Corrected ' || mig_gmr.gmr_ref_no);

         UPDATE ash_assay_header ash
            SET ash.assay_ref_no = assay_ref_no_var,
                ash.wns_group_id = wns_group_id_var,
                ash.wnsrefno = assay_ref_no_var
          WHERE ash.internal_gmr_ref_no = mig_gmr.internal_gmr_ref_no
            AND ash.ash_id IN (
                   WITH wns_data AS
                        (SELECT ash.ash_id, ash.assay_type, ash.wns_group_id,
                                ash.assay_ref_no, ash.pricing_assay_ash_id,
                                ash.position_assay_ash_id,
                                ash.wght_avg_invoice_ash_id,
                                ash.wt_average_assay_ash_id,
                                ash.wt_average_pricing_ash_id,
                                ash.invoice_ash_id
                           FROM ash_assay_header ash
                          WHERE ash.internal_gmr_ref_no =
                                                   mig_gmr.internal_gmr_ref_no
                            AND ash.assay_type = 'Weighing and Sampling Assay'
                            AND ash.is_sublots_as_stock = 'Y')
                   SELECT wns_data.pricing_assay_ash_id child_ash_id
                     FROM wns_data
                    WHERE wns_data.pricing_assay_ash_id IS NOT NULL
                   UNION
                   SELECT wns_data.position_assay_ash_id child_ash_id
                     FROM wns_data
                    WHERE wns_data.position_assay_ash_id IS NOT NULL
                   UNION
                   SELECT wns_data.wght_avg_invoice_ash_id child_ash_id
                     FROM wns_data
                    WHERE wns_data.wght_avg_invoice_ash_id IS NOT NULL
                   UNION
                   SELECT wns_data.wt_average_assay_ash_id child_ash_id
                     FROM wns_data
                    WHERE wns_data.wt_average_assay_ash_id IS NOT NULL
                   UNION
                   SELECT wns_data.wt_average_pricing_ash_id child_ash_id
                     FROM wns_data
                    WHERE wns_data.wt_average_pricing_ash_id IS NOT NULL
                   UNION
                   SELECT wns_data.invoice_ash_id child_ash_id
                     FROM wns_data
                    WHERE wns_data.invoice_ash_id IS NOT NULL);
      END IF;
   END LOOP;
END;
/