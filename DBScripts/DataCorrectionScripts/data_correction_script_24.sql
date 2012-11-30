
DECLARE
   CURSOR cr_ash_record
   IS
      SELECT   ash.assay_ref_no, ash.internal_gmr_ref_no,
               ash.internal_grd_ref_no
          FROM ash_assay_header ash
         WHERE ash.assay_type = 'Weighing and Sampling Assay'
      GROUP BY ash.assay_ref_no,
               ash.internal_gmr_ref_no,
               ash.internal_grd_ref_no;
BEGIN
   FOR cur_record_rows IN cr_ash_record
   LOOP
      UPDATE ash_assay_header ash
         SET ash.wnsrefno = cur_record_rows.assay_ref_no,
             ash.dry_weight = (SELECT SUM (asm.dry_weight)
                                 FROM asm_assay_sublot_mapping asm
                                WHERE ash.ash_id = asm.ash_id),
             ash.qty_unit_name =
                pkg_general.f_get_quantity_unit
                                        ((SELECT DISTINCT asm.net_weight_unit
                                                     FROM asm_assay_sublot_mapping asm
                                                    WHERE ash.ash_id =
                                                                    asm.ash_id))
       WHERE ash.internal_gmr_ref_no = cur_record_rows.internal_gmr_ref_no
         AND ash.internal_grd_ref_no = cur_record_rows.internal_grd_ref_no
         AND ash.assay_type NOT IN
                 ('Provisional Assay', 'Shipment Assay', 'Contractual Assay');
   END LOOP;
END;
/

DECLARE
   CURSOR ash_cursor
   IS
      SELECT   ash.internal_gmr_ref_no, ash.assay_type,
               ash.internal_grd_ref_no
          FROM ash_assay_header ash
         WHERE ash.assay_type = 'Provisional Assay'
      GROUP BY ash.internal_gmr_ref_no,
               ash.internal_grd_ref_no,
               ash.assay_type;
BEGIN
   FOR ash_cur_rows IN ash_cursor
   LOOP
      UPDATE ash_assay_header ash
         SET ash.dry_weight = (SELECT SUM (asm.dry_weight)
                                 FROM asm_assay_sublot_mapping asm
                                WHERE ash.ash_id = asm.ash_id),
             ash.qty_unit_name =
                pkg_general.f_get_quantity_unit
                                        ((SELECT DISTINCT asm.net_weight_unit
                                                     FROM asm_assay_sublot_mapping asm
                                                    WHERE ash.ash_id =
                                                                    asm.ash_id))
       WHERE ash.internal_gmr_ref_no = ash_cur_rows.internal_gmr_ref_no
         AND ash.internal_grd_ref_no = ash_cur_rows.internal_grd_ref_no
         AND ash.assay_type IN ('Provisional Assay');
   END LOOP;
END;
/