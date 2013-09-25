

DECLARE
   CURSOR invsummaryupdate
   IS
      SELECT   iam.internal_invoice_ref_no, axs.internal_action_ref_no,
               axs.action_id
          FROM iam_invoice_action_mapping iam,
               is_invoice_summary invs,
               axs_action_summary axs
         WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
           AND iam.invoice_action_ref_no = axs.internal_action_ref_no
           AND axs.action_id NOT IN ('MODIFY_INVOICE')
      GROUP BY iam.internal_invoice_ref_no,
               axs.internal_action_ref_no,
               axs.action_id;
BEGIN
   FOR invsupdate IN invsummaryupdate
   LOOP
      UPDATE is_invoice_summary invs
         SET invs.internal_action_ref_no = invsupdate.internal_action_ref_no,
             invs.action_id = invsupdate.action_id
       WHERE invs.internal_invoice_ref_no = invsupdate.internal_invoice_ref_no;
   END LOOP;

   COMMIT;
END;