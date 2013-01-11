DECLARE
   CURSOR vatinvoicedetailcur
   IS
      SELECT   invs.internal_invoice_ref_no AS vatinvoicerefno,
               pdm.product_id AS productid, pdm.product_desc
          FROM is_invoice_summary invs,
               is_invoice_summary invs1,
               iid_invoicable_item_details iid,
               grd_goods_record_detail grd,
               pdm_productmaster pdm,
               vpcm_vat_parent_child_map vpcm
         WHERE invs.invoice_type_name IN ('Vat')
           AND invs.internal_invoice_ref_no = vpcm.vat_internal_invoice_ref_no
           AND invs1.internal_invoice_ref_no = vpcm.internal_invoice_ref_no
           AND invs1.internal_invoice_ref_no = iid.internal_invoice_ref_no
           AND pdm.product_id = grd.product_id
           AND grd.internal_grd_ref_no = iid.stock_id
      GROUP BY invs.internal_invoice_ref_no, pdm.product_id, pdm.product_desc;

   vatinvoicedetailvar   vatinvoicedetailcur%ROWTYPE;
BEGIN
   OPEN vatinvoicedetailcur;

   LOOP
      FETCH vatinvoicedetailcur
       INTO vatinvoicedetailvar;

      EXIT WHEN vatinvoicedetailcur%NOTFOUND;

      UPDATE ivd_invoice_vat_details ivd
         SET ivd.product_id = vatinvoicedetailvar.productid
       WHERE ivd.internal_invoice_ref_no = vatinvoicedetailvar.vatinvoicerefno;

      COMMIT;
   END LOOP;

   CLOSE vatinvoicedetailcur;
END;