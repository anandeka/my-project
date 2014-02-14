DECLARE
   CURSOR serviceinvoice
   IS
      SELECT invs.internal_invoice_ref_no, cigc.internal_gmr_ref_no,
             invs.is_active
        FROM is_invoice_summary invs,
             cs_cost_store cs,
             cigc_contract_item_gmr_cost cigc
       WHERE invs.internal_invoice_ref_no NOT IN (
                                        SELECT sigm.internal_inv_ref_no
                                          FROM sigm_service_inv_gmr_mapping sigm)
         AND invs.internal_action_ref_no = cs.internal_action_ref_no
         AND cs.cog_ref_no = cigc.cog_ref_no
         AND invs.invoice_type = 'Service'
         AND invs.invoice_type_name <> 'CancelInvoice';
BEGIN
   FOR si IN serviceinvoice
   LOOP
      INSERT INTO sigm_service_inv_gmr_mapping
                  (sigm_id,
                   internal_inv_ref_no, internal_gmr_ref_no,
                   is_active
                  )
           VALUES ('C' || si.internal_invoice_ref_no,
                   si.internal_invoice_ref_no, si.internal_gmr_ref_no,
                   si.is_active
                  );
   END LOOP;
   COMMIT;
END;