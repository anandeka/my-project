
DECLARE
   fetchqueryischildfordc   CLOB
      := 'INSERT INTO IS_DC_CONC_CHILD_D(
INTERNAL_INV_REF_NO,
ELEMENT_ID,
ELEMENT_NAME,
OLD_INVOICED_QTY,
OLD_INVOICED_QTY_UNIT,
OLD_PAYABLE_PRICE,
OLD_PAYABLE_PRICE_UNIT,
OLD_PAYABLE_AMOUNT,
AMOUNT_UNIT,
NEW_INVOICED_QTY,
NEW_INVOICED_QTY_UNIT,
NEW_PAYABLE_PRICE,
NEW_PAYABLE_PRICE_UNIT,
NEW_PAYABLE_AMOUNT,
OLD_FX_RATE,
NEW_FX_RATE,
NEW_RC_AMOUNT,
OLD_RC_AMOUNT,
NEW_TC_AMOUNT,
OLD_TC_AMOUNT,
NEW_PENALTY_AMOUNT,
OLD_PENALTY_AMOUNT,
STOCK_REF_NO,
LOT_REF_NO,
INTERNAL_DOC_REF_NO
)
SELECT INVS.INTERNAL_INVOICE_REF_NO as  INTERNAL_INV_REF_NO, iied.element_id AS element_id, aml.attribute_name AS element_name,
       iied.element_invoiced_qty AS old_invoiced_qty,
       qum.qty_unit AS old_invoiced_qty_unit,
       iied.element_payable_price AS old_payable_price,
       pum.price_unit_name AS old_payable_price_unit,
       iied.element_payable_amount AS old_payable_amount,
       cm.cur_code AS amount_unit, iied.new_invoiced_qty AS new_invoiced_qty,
       qum.qty_unit AS new_invoiced_qty_unit,
       iied.new_price AS new_payable_price,
       pum.price_unit_name AS new_payable_price_unit,
       iied.new_payable_amount AS new_payable_amount,
       iied.fx_rate AS old_fx_rate, iied.new_fx_rate AS new_fx_rate,
       (SELECT sum(INRC.RCHARGES_AMOUNT)
             FROM inrc_inv_refining_charges inrc
            WHERE INRC.ELEMENT_ID = AML.ATTRIBUTE_ID
              AND inrc.internal_invoice_ref_no = INVS.INTERNAL_INVOICE_REF_NO) as NEW_RC_AMOUNT,
       (SELECT sum(INRC.RCHARGES_AMOUNT)
             FROM inrc_inv_refining_charges inrc, CPCR_COMMERCIAL_INV_PC_MAPPING cpcr
            WHERE INRC.ELEMENT_ID = AML.ATTRIBUTE_ID
              AND cpcr.internal_invoice_ref_no = INVS.INTERNAL_INVOICE_REF_NO
              AND CPCR.PARENT_INVOICE_REF_NO = INRC.INTERNAL_INVOICE_REF_NO) as OLD_RC_AMOUNT,
       (SELECT sum(INTC.TCHARGES_AMOUNT)
             FROM INTC_INV_TREATMENT_CHARGES intc
            WHERE intc.ELEMENT_ID = AML.ATTRIBUTE_ID
              AND intc.internal_invoice_ref_no = INVS.INTERNAL_INVOICE_REF_NO) as NEW_TC_AMOUNT,
       (SELECT sum(INTC.TCHARGES_AMOUNT)
             FROM INTC_INV_TREATMENT_CHARGES intc, CPCR_COMMERCIAL_INV_PC_MAPPING cpcr
            WHERE intc.ELEMENT_ID = AML.ATTRIBUTE_ID
              AND cpcr.internal_invoice_ref_no = INVS.INTERNAL_INVOICE_REF_NO
              AND CPCR.PARENT_INVOICE_REF_NO = intc.INTERNAL_INVOICE_REF_NO) as OLD_TC_AMOUNT,
       (SELECT sum(IEPD.ELEMENT_PENALTY_AMOUNT)
             FROM IEPD_INV_EPENALTY_DETAILS iepd
            WHERE iepd.ELEMENT_ID = AML.ATTRIBUTE_ID
              AND iepd.internal_invoice_ref_no = INVS.INTERNAL_INVOICE_REF_NO) as NEW_PENALTY_AMOUNT,
       (SELECT sum(IEPD.ELEMENT_PENALTY_AMOUNT)
             FROM IEPD_INV_EPENALTY_DETAILS iepd, CPCR_COMMERCIAL_INV_PC_MAPPING cpcr
            WHERE iepd.ELEMENT_ID = AML.ATTRIBUTE_ID
              AND cpcr.internal_invoice_ref_no = INVS.INTERNAL_INVOICE_REF_NO
              AND CPCR.PARENT_INVOICE_REF_NO = iepd.INTERNAL_INVOICE_REF_NO) as OLD_PENALTY_AMOUNT,
        grd.internal_stock_ref_no AS stock_ref_no,
       iied.sub_lot_no AS lot_ref_no,?    
  FROM is_invoice_summary invs,
       iied_inv_item_element_details iied,
       aml_attribute_master_list aml,
       pum_price_unit_master pum,
       ppu_product_price_units ppu,
       cm_currency_master cm,
       grd_goods_record_detail grd,
       qum_quantity_unit_master qum,
       CPCR_COMMERCIAL_INV_PC_MAPPING cpcr
 WHERE iied.internal_invoice_ref_no = invs.internal_invoice_ref_no
   AND iied.element_id = aml.attribute_id
   AND iied.element_inv_qty_unit_id = qum.qty_unit_id
   AND iied.element_payable_price_unit_id = ppu.internal_price_unit_id
   AND ppu.price_unit_id = pum.price_unit_id
   AND cm.cur_id = invs.invoice_cur_id
   AND iied.grd_id = grd.internal_grd_ref_no
   AND INVS.INTERNAL_INVOICE_REF_NO = CPCR.INTERNAL_INVOICE_REF_NO
   AND invs.internal_invoice_ref_no = ?';
BEGIN
   DELETE FROM dgm_document_generation_master dgm
         WHERE dgm.dgm_id = 'DGM-DC-CONC-C1'
           AND dgm.doc_id = 'CREATE_DC'
           AND dgm.sequence_order = 2
           AND dgm.is_concentrate = 'Y';

   INSERT INTO dgm_document_generation_master
               (dgm_id, doc_id, doc_name, activity_id,
                sequence_order, fetch_query, is_concentrate
               )
        VALUES ('DGM-DC-CONC-C1', 'CREATE_DC', 'Debit Credit', 'CREATE_DC',
                2, fetchqueryischildfordc, 'Y'
               );

   COMMIT;
END;