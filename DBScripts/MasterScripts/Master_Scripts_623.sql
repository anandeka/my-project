DECLARE fetchQueryIEPD CLOB := 'INSERT INTO iepd_d
            (internal_invoice_ref_no, invoice_amount, delivery_item_ref_no,
             internal_gmr_ref_no, element_id, element_name, fx_rate,
             gmr_ref_no, invoice_cur_name, invoice_price_unit_name,
             adjustment, price, price_fixation_date, price_fixation_ref_no,
             price_in_pay_in_cur, pricing_cur_name, pricing_price_unit_name,
             pricing_type, product_name, qty_priced, qty_unit_name,
             qp_start_date, qp_end_date, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          iepd.amount_in_pay_in_cur AS invoice_amount,
          iepd.delivery_item_ref_no AS delivery_item_ref_no,
          iepd.internal_gmr_ref_no AS internal_gmr_ref_no,
          iepd.element_id AS element_id, iepd.element_name AS element_name,
          iepd.fx_rate AS fx_rate, gmr.gmr_ref_no AS gmr_ref_no,
          iepd.pay_in_cur_name AS invoice_cur_name,
          iepd.pay_in_price_unit_name AS invoice_price_unit_name,
          iepd.adjustment AS adjustment, iepd.price AS price,
          iepd.price_fixation_date AS price_fixation_date,
          iepd.price_fixation_ref_no AS price_fixation_ref_no,
          iepd.price_in_pay_in_cur AS price_in_pay_in_cur,
          iepd.pricing_cur_name AS pricing_cur_name,
          iepd.pricing_price_unit_name AS pricing_price_unit_name,
          iepd.pricing_type AS pricing_type, pdm.product_desc AS product_name,
          iepd.qty_priced AS qty_priced, iepd.qty_unit_name AS qty_unit_name,
          pofh.qp_start_date AS qp_start_date,
          pofh.qp_end_date AS qp_end_date,
          ?
     FROM is_invoice_summary invs,
          iepd_inv_ele_pricing_detail iepd,
          pdm_productmaster pdm,
          pofh_price_opt_fixation_header pofh,
          gmr_goods_movement_record gmr
    WHERE invs.internal_invoice_ref_no = iepd.internal_invoice_ref_no
      AND iepd.product_id = pdm.product_id(+)
      AND iepd.pofh_id = pofh.pofh_id(+)
      AND iepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
      AND iepd.internal_invoice_ref_no = ?';
BEGIN
UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryIEPD WHERE DGM.DGM_ID IN ('CREATE_DFT_DFIC_13','CREATE_DFT_FIC_13','DGM-DFI-C8','DGM-DFT-DFI-C9','DGM-DFT-FI-C9','DGM-IEPD_BM','DGM-IEPD_C','DGM-IEPD_C') AND DGM.DOC_ID IN ('CREATE_DFI','CREATE_DFT_DFI','CREATE_DFT_FI','CREATE_FI') AND DGM.SEQUENCE_ORDER IN (9,13);
COMMIT;
END;