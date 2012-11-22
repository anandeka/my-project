DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO is_parent_child_d
            (internal_invoice_ref_no, invoice_ref_no, invoice_issue_date,
             due_date, invoice_currency, invoice_amount, prov_pymt_percentage,
             invoice_type_name, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          invs.invoice_ref_no AS invoice_ref_no,
          invs.invoice_issue_date AS invoice_issue_date,
          invs.payment_due_date AS due_date, cm.cur_code AS invoice_currency,
          (CASE
              WHEN invs.prov_pctg_amt IS NOT NULL
              AND invs.freight_allowance_amt IS NOT NULL
                 THEN invs.prov_pctg_amt + invs.freight_allowance_amt
              WHEN invs.prov_pctg_amt IS NOT NULL
                 THEN invs.prov_pctg_amt
              WHEN invs.prov_pctg_amt IS NULL
              AND invs.freight_allowance_amt IS NOT NULL
                 THEN   invs.amount_to_pay_before_adj
                      + invs.freight_allowance_amt
              ELSE invs.amount_to_pay_before_adj
           END
          ) AS invoice_amount,
          NVL (TO_CHAR (invs.provisional_pymt_pctg),
               ''100''
              ) AS prov_pymt_percentage,
          invs.invoice_type_name AS invoice_type_name, ?
     FROM is_invoice_summary invs,
          cpcr_commercial_inv_pc_mapping cpcr,
          cm_currency_master cm
    WHERE cpcr.parent_invoice_ref_no = invs.internal_invoice_ref_no
      AND invs.invoice_cur_id = cm.cur_id
      AND cpcr.internal_invoice_ref_no = ?';
      
   fetchqry2   CLOB := 'INSERT INTO is_child_d
            (internal_invoice_ref_no, gmr_ref_no, gmr_quantity, gmr_quality,
             price_as_per_defind_uom, total_price_qty, gmr_qty_unit,
             invoiced_qty_unit, invoiced_price_unit, stock_ref_no, stock_qty,
             fx_rate, item_amount_in_inv_cur, product, yield,
             internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          gmr.gmr_ref_no AS gmr_ref_no, gmr.qty AS gmr_quantity,
          NVL (qat.quality_name, qat1.quality_name) AS gmr_quality,
          iid.new_invoice_price AS price_as_per_defind_uom,
          iid.invoiced_qty AS total_price_qty, qum.qty_unit AS gmr_qty_unit,
          quminv.qty_unit AS invoiced_qty_unit,
          pum.price_unit_name AS invoiced_price_unit,
          NVL (grd.internal_stock_ref_no,
               dgrd.internal_stock_ref_no
              ) AS stock_ref_no,
          iid.invoiced_qty AS stock_qty, iid.fx_rate AS fx_rate,
          iid.invoice_item_amount AS item_amount_in_inv_cur,
          pdm.product_desc AS product, ypd.yield_pct AS yield, ?
     FROM is_invoice_summary invs,
          iid_invoicable_item_details iid,
          gmr_goods_movement_record gmr,
          qum_quantity_unit_master qum,
          qum_quantity_unit_master quminv,
          ppu_product_price_units ppu,
          pum_price_unit_master pum,
          grd_goods_record_detail grd,
          dgrd_delivered_grd dgrd,
          qat_quality_attributes qat,
          pdm_productmaster pdm,
          qat_quality_attributes qat1,
          aml_attribute_master_list aml,
          ypd_yield_pct_detail ypd
    WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
      AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
      AND gmr.qty_unit_id = qum.qty_unit_id(+)
      AND iid.invoiced_qty_unit_id = quminv.qty_unit_id(+)
      AND iid.new_invoice_price_unit_id = ppu.internal_price_unit_id(+)
      AND ppu.price_unit_id = pum.price_unit_id(+)
      AND iid.stock_id = grd.internal_grd_ref_no(+)
      AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
      AND grd.quality_id = qat.quality_id(+)
      AND grd.product_id = pdm.product_id(+)
      AND dgrd.quality_id = qat1.quality_id(+)
      AND grd.element_id = aml.attribute_id(+)
      AND grd.element_id = ypd.element_id(+)
      AND grd.internal_gmr_ref_no = ypd.internal_gmr_ref_no(+)
      AND NVL (ypd.is_active, ''Y'') = ''Y''
      AND iid.internal_invoice_ref_no = ?';
   
   fetchQry3  clob := 'INSERT INTO vat_child_d
            (internal_invoice_ref_no, vat_no, cp_vat_no, vat_code, vat_rate,
             vat_amount, vat_amount_cur, main_inv_vat_code, vat_inv_vat_code,
             internal_doc_ref_no)
   SELECT ivd.internal_invoice_ref_no AS internal_invoice_ref_no,
          ivd.our_vat_no AS vat_no, ivd.cp_vat_no AS cp_vat_no,
          tm.tax_code AS vat_code, ivd.vat_rate AS vat_rate,
          ivd.vat_amount_in_vat_cur AS vat_amount,
          cm.cur_code AS vat_amount_cur,
          main_inv_vat_code AS main_inv_vat_code,
          vat_inv_vat_code AS vat_inv_vat_code, ?
     FROM ivd_invoice_vat_details ivd,
          is_invoice_summary invs,
          cm_currency_master cm,
          tm_tax_master tm
    WHERE invs.internal_invoice_ref_no = ivd.internal_invoice_ref_no
      AND ivd.vat_remit_cur_id = cm.cur_id
      AND ivd.vat_code = tm.tax_id
      AND invs.internal_invoice_ref_no = ?';
      
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry1
    WHERE dgm.doc_id IN ('CREATE_PI', 'CREATE_DFI', 'CREATE_FI')
      AND dgm.is_concentrate = 'Y'
      AND dgm.sequence_order = 8;
      
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry1
    WHERE dgm.doc_id IN ('CREATE_PI', 'CREATE_DFI', 'CREATE_FI')
      AND dgm.is_concentrate = 'N'
      AND dgm.sequence_order = 5;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry2
    WHERE dgm.doc_id IN ('CREATE_PI', 'CREATE_DFI', 'CREATE_FI')
      AND dgm.is_concentrate = 'N'
      AND dgm.sequence_order = 2;
   
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry3
    WHERE dgm.doc_id IN ('CREATE_VAT')
      AND dgm.sequence_order = 2;
      
      commit;
      
END;
