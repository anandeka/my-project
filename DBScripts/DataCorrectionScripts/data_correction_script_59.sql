DECLARE
   CURSOR updateinvoicetype
   IS
      SELECT   invs.invoice_ref_no, invs.invoice_issue_date,
               iid.internal_gmr_ref_no, 'Y' AS isfinalcreated,
               invs.invoice_cur_id
          FROM is_invoice_summary invs, iid_invoicable_item_details iid
         WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
           AND invs.invoice_type_name IN ('Final', 'DirectFinal')
           AND iid.is_active = 'Y'
           AND (invs.is_commercial_fee = 'N' OR invs.is_commercial_fee IS NULL
               )
           AND invs.is_free_metal IS NULL
      GROUP BY iid.internal_gmr_ref_no,
               invs.internal_invoice_ref_no,
               invs.invoice_type_name,
               iid.internal_gmr_ref_no,
               iid.internal_invoice_ref_no,
               invs.invoice_ref_no,
               invs.invoice_issue_date,
               invs.invoice_cur_id
      UNION ALL
      SELECT   invs.invoice_ref_no, invs.invoice_issue_date,
               iid.internal_gmr_ref_no, 'N' AS isfinalcreated,
               invs.invoice_cur_id
          FROM is_invoice_summary invs, iid_invoicable_item_details iid
         WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
           AND invs.invoice_type_name IN ('Provisional')
           AND invs.is_considered_for_final = 'N'
           AND invs.is_prov_created = 'N'
           AND iid.is_active = 'Y'
           AND (invs.is_commercial_fee = 'N' OR invs.is_commercial_fee IS NULL
               )
           AND invs.is_free_metal IS NULL
      GROUP BY iid.internal_gmr_ref_no,
               invs.internal_invoice_ref_no,
               invs.invoice_type_name,
               iid.internal_gmr_ref_no,
               iid.internal_invoice_ref_no,
               invs.invoice_ref_no,
               invs.invoice_issue_date,
               invs.invoice_cur_id;
BEGIN
   FOR invoicetype IN updateinvoicetype
   LOOP
      UPDATE gmr_goods_movement_record gmr
         SET gmr.invoice_ref_no = invoicetype.invoice_ref_no,
             gmr.invoice_issue_date = invoicetype.invoice_issue_date,
             gmr.is_fi_created = invoicetype.isfinalcreated,
             gmr.invoice_cur_id = invoicetype.invoice_cur_id
       WHERE gmr.internal_gmr_ref_no = invoicetype.internal_gmr_ref_no;
   END LOOP;

   COMMIT;
END;


DECLARE
   CURSOR landingdetails
   IS
      SELECT agmr.internal_gmr_ref_no,
             TO_CHAR (agmr.eff_date, 'dd-Mon-yyyy') landingdate
        FROM agmr_action_gmr agmr
       WHERE agmr.gmr_latest_action_action_id = 'landingDetail'
         AND agmr.is_deleted = 'N';
BEGIN
   FOR landinggmr IN landingdetails
   LOOP
      UPDATE gmr_goods_movement_record gmr
         SET gmr.landing_date = landinggmr.landingdate
       WHERE gmr.internal_gmr_ref_no = landinggmr.internal_gmr_ref_no;
   END LOOP;

   COMMIT;
END;