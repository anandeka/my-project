DECLARE
   CURSOR is_temp_iam
   IS
      SELECT *
        FROM iam_invoice_action_mapping;
BEGIN
   FOR is_temp IN is_temp_iam
   LOOP
      UPDATE is_ul_invoice_summary_ul isul
         SET isul.internal_action_ref_no = is_temp.invoice_action_ref_no
       WHERE isul.internal_invoice_ref_no = is_temp.internal_invoice_ref_no;
   END LOOP;
END;
\
DECLARE
   CURSOR is_temp_axs
   IS
      SELECT *
        FROM axs_action_summary;
BEGIN
   FOR is_temp IN is_temp_axs
   LOOP
      UPDATE is_ul_invoice_summary_ul isul
         SET isul.modified_by = is_temp.updated_by,
             isul.modified_date = is_temp.updated_date
       WHERE isul.internal_action_ref_no = is_temp.internal_action_ref_no
         AND isul.entry_type = 'update';
   END LOOP;
END;
\
DECLARE
   CURSOR is_temp_axs
   IS
      SELECT invs.internal_invoice_ref_no, axs.updated_by, axs.updated_date
        FROM is_invoice_summary invs,
             iam_invoice_action_mapping iam,
             is_ul_invoice_summary_ul isul,
             axs_action_summary axs
       WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
         AND iam.invoice_action_ref_no = axs.internal_action_ref_no
         AND invs.internal_invoice_ref_no = isul.internal_invoice_ref_no
         AND isul.entry_type = 'update';
BEGIN
   FOR is_temp IN is_temp_axs
   LOOP
      UPDATE is_invoice_summary invs
         SET invs.modified_by = is_temp.updated_by,
             invs.modified_date = is_temp.updated_date
       WHERE invs.internal_invoice_ref_no = is_temp.internal_invoice_ref_no;
   END LOOP;
END;
\