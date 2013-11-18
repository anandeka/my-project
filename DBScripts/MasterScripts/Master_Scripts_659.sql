DECLARE fetchQueryCPD CLOB := 'INSERT INTO IS_CONC_PENALTY_CHILD(
INTERNAL_INVOICE_REF_NO,
PENALTY_AMOUNT,
ELEMENT_NAME,
ELEMENT_ID,
AMOUNT_UNIT,
penalty_qty,
assay_details,
STOCK_REF_NO,
uom,
penalty_rate,
price_name,
wet_qty,
DRY_QUANTITY,
QUANTITY_UOM,
INTERNAL_DOC_REF_NO
)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         iepd.element_penalty_amount AS penalty_amount,
         aml.attribute_name AS element_name, aml.attribute_id AS element_id,
         cm.cur_code AS amount_unit, iepd.element_qty AS penalty_qty,
         pqca.typical AS assay_details,
         nvl(grd.internal_stock_ref_no,DGRD.INTERNAL_STOCK_REF_NO) AS stock_ref_no, rm.ratio_name AS uom,
         iepd.element_penalty_price AS penalty_rate,
         pum.price_unit_name AS price_name, iid.invoiced_qty AS wet_qty,
         ROUND
            ((  iid.invoiced_qty
              - (  iid.invoiced_qty
                 * (SELECT pqca_mos.typical
                      FROM pqca_pq_chemical_attributes pqca_mos,
                           aml_attribute_master_list aml_mos,
                           asm_assay_sublot_mapping asm_mos,
                           ash_assay_header ash_mos
                     WHERE pqca_mos.asm_id = asm_mos.asm_id
                       AND ash_mos.ash_id = asm_mos.ash_id
                       AND pqca_mos.element_id = aml_mos.attribute_id
                       AND ash_mos.ash_id = ash.ash_id
                       AND asm_mos.sub_lot_no = iepd.sub_lot_no
                       AND aml_mos.attribute_name = ''H2O'')
                 / 100
                )
             ),
             10
            ) AS dry_quantity,
         qum.qty_unit AS quantity_uom, ?
    FROM is_invoice_summary invs,
         iepd_inv_epenalty_details iepd,
         aml_attribute_master_list aml,
         cm_currency_master cm,
         iam_invoice_assay_mapping iam,
         pqca_pq_chemical_attributes pqca,
         ash_assay_header ash,
         asm_assay_sublot_mapping asm,
         grd_goods_record_detail grd,
         dgrd_delivered_grd dgrd,
         rm_ratio_master rm,
         ppu_product_price_units ppu,
         qum_quantity_unit_master qum,
         pum_price_unit_master pum,
         iid_invoicable_item_details iid
   WHERE invs.internal_invoice_ref_no = iepd.internal_invoice_ref_no
     AND iepd.element_id = aml.attribute_id(+)
     AND invs.invoice_cur_id = cm.cur_id
     AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
     AND iam.internal_grd_ref_no = iepd.stock_id
     AND iepd.stock_id = grd.internal_grd_ref_no(+)
     AND iepd.stock_id = dgrd.internal_dgrd_ref_no(+)
     AND aml.attribute_id = pqca.element_id
     AND iam.ash_id = ash.ash_id
     AND ash.ash_id = asm.ash_id
     AND asm.asm_id = pqca.asm_id
     AND asm.net_weight_unit = qum.qty_unit_id
     AND pqca.unit_of_measure = rm.ratio_id
     AND iepd.element_price_unit_id = ppu.internal_price_unit_id
     AND ppu.price_unit_id = pum.price_unit_id
     AND invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
     AND iid.stock_id = iepd.stock_id
     AND invs.internal_invoice_ref_no = ?
GROUP BY invs.internal_invoice_ref_no,
         iepd.element_penalty_amount,
         aml.attribute_name,
         aml.attribute_id,
         cm.cur_code,
         iepd.element_qty,
         pqca.typical,
         grd.internal_stock_ref_no,
         rm.ratio_name,
         iepd.element_penalty_price,
         pum.price_unit_name,
         iid.invoiced_qty,
         qum.qty_unit,
         ash.ash_id,
         DGRD.INTERNAL_STOCK_REF_NO,
         iepd.sub_lot_no';

fetchQueryCRD CLOB := 'INSERT INTO IS_CONC_RC_CHILD(
        INTERNAL_INVOICE_REF_NO,
        RC_AMOUNT,
        ELEMENT_NAME,
        ELEMENT_ID,
        AMOUNT_UNIT,
        SUB_LOT_NO,
        DRY_QUANTITY,
        QUANTITY_UNIT_NAME,
        assay_details,
        rc_es_ds,
        BASE_RC,
        assay_uom,
        STOCK_REF_NO,
        BASEESCDESC_TYPE,
        PAYABLE_QTY,
        PAYABLE_QTY_UNIT,
        INTERNAL_DOC_REF_NO
        )

SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         SUM (inrc.rcharges_amount) AS rc_amount,
         aml.attribute_name AS element_name, aml.attribute_id AS element_id,
         cm.cur_code AS amount_unit, inrc.sub_lot_no AS sub_lot_no,
         inrc.lot_qty AS dry_quantity,
         NVL (qum.qty_unit, qum_dgrd.qty_unit) AS quantity_unit_name,
         pqcapd.payable_percentage AS assay_details,
         (SELECT   SUM (rcharges_amount)
              FROM inrc_inv_refining_charges inrc_inner
             WHERE inrc_inner.internal_invoice_ref_no =
                                     invs.internal_invoice_ref_no
               AND inrc_inner.grd_id = inrc.grd_id
               AND inrc_inner.baseescdesc_type = ''Esc/Desc''
               AND inrc_inner.baseescdesc_type <> ''Fixed''
               AND inrc_inner.element_id = inrc.element_id
          GROUP BY inrc_inner.element_id) AS rc_es_ds,
         (SELECT   SUM (rcharges_amount)
              FROM inrc_inv_refining_charges inrc_inner
             WHERE inrc_inner.internal_invoice_ref_no =
                                      invs.internal_invoice_ref_no
               AND inrc_inner.grd_id = inrc.grd_id
               AND inrc_inner.baseescdesc_type = ''Base''
               AND inrc_inner.element_id = inrc.element_id
          GROUP BY inrc_inner.element_id) AS base_rc,
         rm.ratio_name AS assay_uom,
         NVL(grd.internal_stock_ref_no,DGRD.INTERNAL_STOCK_REF_NO) AS stock_ref_no,
         stragg (DISTINCT inrc.baseescdesc_type) AS baseescdesc_type,
         inrc.payable_qty AS payable_qty,
         NVL (qum_rm.qty_unit,
              NVL (qum.qty_unit, qum_dgrd.qty_unit)
             ) AS payable_qty_unit,
         ?
    FROM is_invoice_summary invs,
         inrc_inv_refining_charges inrc,
         aml_attribute_master_list aml,
         cm_currency_master cm,
         iam_invoice_assay_mapping iam,
         grd_goods_record_detail grd,
         dgrd_delivered_grd dgrd,
         qum_quantity_unit_master qum,
         ash_assay_header ash,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         rm_ratio_master rm,
         qum_quantity_unit_master qum_rm,
         qum_quantity_unit_master qum_dgrd
   WHERE invs.internal_invoice_ref_no = inrc.internal_invoice_ref_no(+)
     AND inrc.element_id = aml.attribute_id(+)
     AND invs.invoice_cur_id = cm.cur_id
     AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
     AND inrc.grd_id = iam.internal_grd_ref_no
     AND grd.internal_grd_ref_no(+) = inrc.grd_id
     AND dgrd.internal_dgrd_ref_no(+) = inrc.grd_id
     AND dgrd.net_weight_unit_id = qum_dgrd.qty_unit_id(+)
     AND grd.qty_unit_id = qum.qty_unit_id(+)
     AND iam.ash_id = ash.ash_id
     AND ash.ash_id = asm.ash_id
     AND asm.asm_id = pqca.asm_id
     AND pqca.pqca_id = pqcapd.pqca_id
     AND pqca.element_id = inrc.element_id
     AND inrc.rcharges_price_unit_id = ppu.internal_price_unit_id
     AND ppu.price_unit_id = pum.price_unit_id
     AND pqca.unit_of_measure = rm.ratio_id
     AND rm.qty_unit_id_numerator = qum_rm.qty_unit_id(+)
     AND inrc.sub_lot_no = asm.sub_lot_no(+)
     AND invs.internal_invoice_ref_no = ?
GROUP BY invs.internal_invoice_ref_no,
         aml.attribute_name,
         aml.attribute_id,
         cm.cur_code,
         inrc.sub_lot_no,
         qum.qty_unit,
         pqcapd.payable_percentage,
         rm.ratio_name,
         grd.internal_stock_ref_no,
         inrc.grd_id,
         inrc.lot_qty,
         inrc.element_id,
         inrc.payable_qty,
         qum_rm.qty_unit,
         DGRD.INTERNAL_STOCK_REF_NO,
         qum_dgrd.qty_unit';


         
BEGIN
UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryCPD WHERE DGM.DGM_ID IN ('CREATE_DFT_PIC_5','CREATE_DFT_FIC_5','CREATE_DFT_DFIC_5') AND DGM.DOC_ID IN ('CREATE_DFT_PI','CREATE_DFT_FI','CREATE_DFT_DFI') AND DGM.SEQUENCE_ORDER IN (5) AND DGM.IS_CONCENTRATE = 'Y';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryCRD WHERE DGM.DGM_ID IN ('CREATE_DFT_PIC_4','CREATE_DFT_FIC_4','CREATE_DFT_DFIC_4') AND DGM.DOC_ID IN ('CREATE_DFT_PI','CREATE_DFT_FI','CREATE_DFT_DFI') AND DGM.SEQUENCE_ORDER IN (4) AND DGM.IS_CONCENTRATE = 'Y';

COMMIT;
END;