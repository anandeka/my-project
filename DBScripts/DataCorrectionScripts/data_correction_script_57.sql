/* Formatted on 2013/12/10 20:26 (Formatter Plus v4.8.8) */
DECLARE
   CURSOR updateinvoicetype
   IS
      SELECT   invs.invoice_type_name, iid.internal_gmr_ref_no,
               iid.internal_invoice_ref_no, invs.invoice_ref_no
          FROM is_invoice_summary invs, iid_invoicable_item_details iid
         WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
           AND invs.invoice_type_name IN ('Final','DirectFinal')
           AND iid.is_active = 'Y'
           AND (invs.is_commercial_fee = 'N' OR invs.is_commercial_fee IS NULL
               )
           AND invs.is_free_metal IS NULL
      GROUP BY iid.internal_gmr_ref_no,
               invs.internal_invoice_ref_no,
               invs.invoice_type_name,
               iid.internal_gmr_ref_no,
               iid.internal_invoice_ref_no,
               invs.invoice_ref_no
      UNION ALL
      SELECT   invs.invoice_type_name, iid.internal_gmr_ref_no,
               iid.internal_invoice_ref_no, invs.invoice_ref_no
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
               invs.invoice_ref_no;
BEGIN
   FOR invoicetype IN updateinvoicetype
   LOOP
      UPDATE gmr_goods_movement_record gmr
         SET gmr.latest_invoice_type = invoicetype.invoice_type_name,
             gmr.latest_invoice_ref_no = invoicetype.invoice_ref_no,
             gmr.latest_internal_invoice_ref_no =
                                           invoicetype.internal_invoice_ref_no
       WHERE gmr.internal_gmr_ref_no = invoicetype.internal_gmr_ref_no;
   END LOOP;

   COMMIT;
END;