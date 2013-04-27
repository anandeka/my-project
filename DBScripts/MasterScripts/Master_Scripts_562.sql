declare
fetchISTC CLOB := 'INSERT INTO IS_CONC_TC_CHILD (
INTERNAL_INVOICE_REF_NO,
TC_AMOUNT,
ELEMENT_ID,
AMOUNT_UNIT,
SUB_LOT_NO,
ELEMENT_NAME,
DRY_QUANTITY,
QUANTITY_UNIT_NAME,
WET_QUANTITY,
moisture,
ESC_DESC_AMOUNT,
BASE_TC,
stock_ref_no,
BASEESCDESC_TYPE,
INTERNAL_DOC_REF_NO
)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         SUM (intc.tcharges_amount) AS tc_amount,
         intc.element_id AS element_id, cm.cur_code AS amount_unit,
         intc.sub_lot_no AS sub_lot_no, aml.attribute_name AS element_name,
         SUM (intc.lot_qty) AS dry_qty, qum.qty_unit AS quantity_unit_name,
         SUM (iid.invoiced_qty) AS wet_quantity,
         ROUND (  ((SUM (iid.invoiced_qty) - SUM (intc.lot_qty)) * 100)
                / SUM (iid.invoiced_qty),
                5
               ) AS moisture,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                              invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.baseescdesc_type = ''Esc/Desc''
             AND intc_inner.element_id = intc.element_id) AS esc_desc_amount,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                                      invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.baseescdesc_type = ''Base''
             AND intc_inner.element_id = intc.element_id) AS base_tc,
         grd.internal_stock_ref_no AS stock_ref_no,
         stragg (DISTINCT intc.baseescdesc_type) AS baseescdesc_type, ?
    FROM is_invoice_summary invs,
         intc_inv_treatment_charges intc,
         cm_currency_master cm,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         aml_attribute_master_list aml,
         grd_goods_record_detail grd,
         qum_quantity_unit_master qum,
         iid_invoicable_item_details iid
   WHERE invs.internal_invoice_ref_no = intc.internal_invoice_ref_no(+)
     AND invs.invoice_cur_id = cm.cur_id(+)
     AND intc.tcharges_price_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND intc.element_id = aml.attribute_id
     AND intc.grd_id = grd.internal_grd_ref_no
     AND grd.qty_unit_id = qum.qty_unit_id
     AND iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iid.stock_id = intc.grd_id
     AND invs.internal_invoice_ref_no = ?
GROUP BY invs.internal_invoice_ref_no,
         intc.element_id,
         cm.cur_code,
         intc.sub_lot_no,
         aml.attribute_name,
         qum.qty_unit,
         grd.internal_stock_ref_no,
         intc.grd_id';

begin
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchISTC where DGM.DOC_ID IN ('CREATE_PI','CREATE_FI','CREATE_DFI') and DGM.DGM_ID IN ('DGM-PIC-C2','DGM-FIC-C2','DGM-DFIC-C2') and DGM.SEQUENCE_ORDER = 3 and DGM.IS_CONCENTRATE = 'Y';
commit;
end;