DECLARE fetchQueryDGMPayable CLOB := 'INSERT INTO IS_CONC_PAYABLE_CHILD (
  INTERNAL_INVOICE_REF_NO,
  GMR_REF_NO,
  GMR_QUANTITY,
  GMR_QUALITY,
  GMR_QTY_UNIT,
  INVOICED_PRICE_UNIT,
  STOCK_REF_NO,
  STOCK_QTY,
  ELEMENT_NAME,
  INVOICE_PRICE,
  SUB_LOT_NO,
  ELEMENT_INV_AMOUNT,
  ELEMENT_PRICE_UNIT,
  ASSAY_CONTENT,
  ASSAY_CONTENT_UNIT,
  ELEMENT_INVOICED_QTY,
  ELEMENT_INVOICED_QTY_UNIT,
  ELEMENT_ID,
  NET_PAYABLE,
  DRY_QUANTITY,
  INTERNAL_DOC_REF_NO              
)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         gmr.gmr_ref_no AS gmr_ref_no, gmr.qty AS gmr_quantity,
         NVL (qat.quality_name, qat1.quality_name) AS gmr_quality,
         qum.qty_unit AS gmr_qty_unit,
         pum.price_unit_name AS invoiced_price_unit,
         NVL (grd.internal_stock_ref_no,
              dgrd.internal_stock_ref_no
             ) AS stock_ref_no,
         iid.invoiced_qty AS stock_qty, aml.attribute_name AS element_name,
         iied.element_payable_price AS invoice_price,
         iied.sub_lot_no AS sub_lot_no,
         iied.element_payable_amount AS element_inv_amount,
         pepum.price_unit_name AS element_price_unit,
         pqca.typical AS assay_content, rm.ratio_name AS assay_content_unit,
         iied.element_invoiced_qty AS element_invoiced_qty,
         qumiied.qty_unit AS element_invoiced_qty_unit,
         aml.attribute_id AS element_id,
         pqcapd.payable_percentage AS net_payable,
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
                       AND asm_mos.sub_lot_no = iied.sub_lot_no
                       AND aml_mos.attribute_name = ''H2O'')
                 / 100
                )
             ),
             10
            ) AS dry_quantity,
         ?
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
         qat_quality_attributes qat1,
         iied_inv_item_element_details iied,
         aml_attribute_master_list aml,
         ppu_product_price_units pepu,
         pum_price_unit_master pepum,
         ash_assay_header ash,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         iam_invoice_assay_mapping iam,
         rm_ratio_master rm,
         qum_quantity_unit_master qumiied
   WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
     AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
     AND gmr.qty_unit_id = qum.qty_unit_id(+)
     AND iid.invoiced_qty_unit_id = quminv.qty_unit_id(+)
     AND iid.new_invoice_price_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND iid.stock_id = grd.internal_grd_ref_no(+)
     AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
     AND grd.quality_id = qat.quality_id(+)
     AND dgrd.quality_id = qat1.quality_id(+)
     AND iied.internal_invoice_ref_no = invs.internal_invoice_ref_no(+)
     AND aml.attribute_id = iied.element_id(+)
     AND iied.element_payable_price_unit_id = pepu.internal_price_unit_id(+)
     AND pepu.price_unit_id = pepum.price_unit_id(+)
     AND iam.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iam.ash_id = ash.ash_id
     AND ash.ash_id = asm.ash_id
     AND asm.asm_id = pqca.asm_id
     AND iied.element_id = pqca.element_id
     AND pqca.unit_of_measure = rm.ratio_id
     AND pqca.pqca_id = pqcapd.pqca_id
     AND iied.element_inv_qty_unit_id = qumiied.qty_unit_id
     AND iied.grd_id = iam.internal_grd_ref_no
     AND iied.grd_id = iid.stock_id
     AND iid.internal_invoice_ref_no = ?
     AND iied.sub_lot_no = asm.sub_lot_no
GROUP BY invs.internal_invoice_ref_no,
         gmr.gmr_ref_no,
         gmr.qty,
         qat.quality_name,
         qat1.quality_name,
         qum.qty_unit,
         pum.price_unit_name,
         grd.internal_stock_ref_no,
         dgrd.internal_stock_ref_no,
         iid.invoiced_qty,
         aml.attribute_name,
         iied.element_payable_price,
         iied.sub_lot_no,
         iied.element_payable_amount,
         pepum.price_unit_name,
         pqca.typical,
         rm.ratio_name,
         iied.element_invoiced_qty,
         qumiied.qty_unit,
         aml.attribute_id,
         pqcapd.payable_percentage,
         ash.ash_id';
         
DECLARE fetchQueryDGMPayable CLOB := 'INSERT INTO IS_CONC_PAYABLE_CHILD (
  INTERNAL_INVOICE_REF_NO,
  GMR_REF_NO,
  GMR_QUANTITY,
  GMR_QUALITY,
  GMR_QTY_UNIT,
  INVOICED_PRICE_UNIT,
  STOCK_REF_NO,
  STOCK_QTY,
  ELEMENT_NAME,
  INVOICE_PRICE,
  SUB_LOT_NO,
  ELEMENT_INV_AMOUNT,
  ELEMENT_PRICE_UNIT,
  ASSAY_CONTENT,
  ASSAY_CONTENT_UNIT,
  ELEMENT_INVOICED_QTY,
  ELEMENT_INVOICED_QTY_UNIT,
  ELEMENT_ID,
  NET_PAYABLE,
  DRY_QUANTITY,
  INTERNAL_DOC_REF_NO              
)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         gmr.gmr_ref_no AS gmr_ref_no, gmr.qty AS gmr_quantity,
         NVL (qat.quality_name, qat1.quality_name) AS gmr_quality,
         qum.qty_unit AS gmr_qty_unit,
         pum.price_unit_name AS invoiced_price_unit,
         NVL (grd.internal_stock_ref_no,
              dgrd.internal_stock_ref_no
             ) AS stock_ref_no,
         iid.invoiced_qty AS stock_qty, aml.attribute_name AS element_name,
         iied.element_payable_price AS invoice_price,
         iied.sub_lot_no AS sub_lot_no,
         iied.element_payable_amount AS element_inv_amount,
         pepum.price_unit_name AS element_price_unit,
         pqca.typical AS assay_content, rm.ratio_name AS assay_content_unit,
         iied.element_invoiced_qty AS element_invoiced_qty,
         qumiied.qty_unit AS element_invoiced_qty_unit,
         aml.attribute_id AS element_id,
         pqcapd.payable_percentage AS net_payable,
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
                       AND asm_mos.sub_lot_no = iied.sub_lot_no
                       AND aml_mos.attribute_name = ''H2O'')
                 / 100
                )
             ),
             10
            ) AS dry_quantity,
         ?
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
         qat_quality_attributes qat1,
         iied_inv_item_element_details iied,
         aml_attribute_master_list aml,
         ppu_product_price_units pepu,
         pum_price_unit_master pepum,
         ash_assay_header ash,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         iam_invoice_assay_mapping iam,
         rm_ratio_master rm,
         qum_quantity_unit_master qumiied
   WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
     AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
     AND gmr.qty_unit_id = qum.qty_unit_id(+)
     AND iid.invoiced_qty_unit_id = quminv.qty_unit_id(+)
     AND iid.new_invoice_price_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND iid.stock_id = grd.internal_grd_ref_no(+)
     AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
     AND grd.quality_id = qat.quality_id(+)
     AND dgrd.quality_id = qat1.quality_id(+)
     AND iied.internal_invoice_ref_no = invs.internal_invoice_ref_no(+)
     AND aml.attribute_id = iied.element_id(+)
     AND iied.element_payable_price_unit_id = pepu.internal_price_unit_id(+)
     AND pepu.price_unit_id = pepum.price_unit_id(+)
     AND iam.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iam.ash_id = ash.ash_id
     AND ash.ash_id = asm.ash_id
     AND asm.asm_id = pqca.asm_id
     AND iied.element_id = pqca.element_id
     AND pqca.unit_of_measure = rm.ratio_id
     AND pqca.pqca_id = pqcapd.pqca_id
     AND iied.element_inv_qty_unit_id = qumiied.qty_unit_id
     AND iied.grd_id = iam.internal_grd_ref_no
     AND iied.grd_id = iid.stock_id
     AND iid.internal_invoice_ref_no = ?
     AND iied.sub_lot_no = asm.sub_lot_no
GROUP BY invs.internal_invoice_ref_no,
         gmr.gmr_ref_no,
         gmr.qty,
         qat.quality_name,
         qat1.quality_name,
         qum.qty_unit,
         pum.price_unit_name,
         grd.internal_stock_ref_no,
         dgrd.internal_stock_ref_no,
         iid.invoiced_qty,
         aml.attribute_name,
         iied.element_payable_price,
         iied.sub_lot_no,
         iied.element_payable_amount,
         pepum.price_unit_name,
         pqca.typical,
         rm.ratio_name,
         iied.element_invoiced_qty,
         qumiied.qty_unit,
         aml.attribute_id,
         pqcapd.payable_percentage,
         ash.ash_id';

DECLARE fetchQueryDGMPayable CLOB := 'INSERT INTO IS_CONC_PAYABLE_CHILD (
  INTERNAL_INVOICE_REF_NO,
  GMR_REF_NO,
  GMR_QUANTITY,
  GMR_QUALITY,
  GMR_QTY_UNIT,
  INVOICED_PRICE_UNIT,
  STOCK_REF_NO,
  STOCK_QTY,
  ELEMENT_NAME,
  INVOICE_PRICE,
  SUB_LOT_NO,
  ELEMENT_INV_AMOUNT,
  ELEMENT_PRICE_UNIT,
  ASSAY_CONTENT,
  ASSAY_CONTENT_UNIT,
  ELEMENT_INVOICED_QTY,
  ELEMENT_INVOICED_QTY_UNIT,
  ELEMENT_ID,
  NET_PAYABLE,
  DRY_QUANTITY,
  INTERNAL_DOC_REF_NO              
)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         gmr.gmr_ref_no AS gmr_ref_no, gmr.qty AS gmr_quantity,
         NVL (qat.quality_name, qat1.quality_name) AS gmr_quality,
         qum.qty_unit AS gmr_qty_unit,
         pum.price_unit_name AS invoiced_price_unit,
         NVL (grd.internal_stock_ref_no,
              dgrd.internal_stock_ref_no
             ) AS stock_ref_no,
         iid.invoiced_qty AS stock_qty, aml.attribute_name AS element_name,
         iied.element_payable_price AS invoice_price,
         iied.sub_lot_no AS sub_lot_no,
         iied.element_payable_amount AS element_inv_amount,
         pepum.price_unit_name AS element_price_unit,
         pqca.typical AS assay_content, rm.ratio_name AS assay_content_unit,
         iied.element_invoiced_qty AS element_invoiced_qty,
         qumiied.qty_unit AS element_invoiced_qty_unit,
         aml.attribute_id AS element_id,
         pqcapd.payable_percentage AS net_payable,
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
                       AND asm_mos.sub_lot_no = iied.sub_lot_no
                       AND aml_mos.attribute_name = ''H2O'')
                 / 100
                )
             ),
             10
            ) AS dry_quantity,
         ?
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
         qat_quality_attributes qat1,
         iied_inv_item_element_details iied,
         aml_attribute_master_list aml,
         ppu_product_price_units pepu,
         pum_price_unit_master pepum,
         ash_assay_header ash,
         asm_assay_sublot_mapping asm,
         pqca_pq_chemical_attributes pqca,
         pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
         iam_invoice_assay_mapping iam,
         rm_ratio_master rm,
         qum_quantity_unit_master qumiied
   WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
     AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
     AND gmr.qty_unit_id = qum.qty_unit_id(+)
     AND iid.invoiced_qty_unit_id = quminv.qty_unit_id(+)
     AND iid.new_invoice_price_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND iid.stock_id = grd.internal_grd_ref_no(+)
     AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
     AND grd.quality_id = qat.quality_id(+)
     AND dgrd.quality_id = qat1.quality_id(+)
     AND iied.internal_invoice_ref_no = invs.internal_invoice_ref_no(+)
     AND aml.attribute_id = iied.element_id(+)
     AND iied.element_payable_price_unit_id = pepu.internal_price_unit_id(+)
     AND pepu.price_unit_id = pepum.price_unit_id(+)
     AND iam.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iam.ash_id = ash.ash_id
     AND ash.ash_id = asm.ash_id
     AND asm.asm_id = pqca.asm_id
     AND iied.element_id = pqca.element_id
     AND pqca.unit_of_measure = rm.ratio_id
     AND pqca.pqca_id = pqcapd.pqca_id
     AND iied.element_inv_qty_unit_id = qumiied.qty_unit_id
     AND iied.grd_id = iam.internal_grd_ref_no
     AND iied.grd_id = iid.stock_id
     AND iid.internal_invoice_ref_no = ?
     AND iied.sub_lot_no = asm.sub_lot_no
GROUP BY invs.internal_invoice_ref_no,
         gmr.gmr_ref_no,
         gmr.qty,
         qat.quality_name,
         qat1.quality_name,
         qum.qty_unit,
         pum.price_unit_name,
         grd.internal_stock_ref_no,
         dgrd.internal_stock_ref_no,
         iid.invoiced_qty,
         aml.attribute_name,
         iied.element_payable_price,
         iied.sub_lot_no,
         iied.element_payable_amount,
         pepum.price_unit_name,
         pqca.typical,
         rm.ratio_name,
         iied.element_invoiced_qty,
         qumiied.qty_unit,
         aml.attribute_id,
         pqcapd.payable_percentage,
         ash.ash_id';
         
DECLARE fetchQueryDGMTC CLOB := 'INSERT INTO IS_CONC_TC_CHILD (
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
         SUM (DISTINCT intc.lot_qty) AS dry_qty,
         NVL (qum.qty_unit, qum_dgrd.qty_unit) AS quantity_unit_name,
         SUM (DISTINCT iid.invoiced_qty) AS wet_quantity,
         ROUND (  ((SUM (iid.invoiced_qty) - SUM (intc.lot_qty)) * 100)
                / SUM (iid.invoiced_qty),
                5
               ) AS moisture,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                              invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.sub_lot_no = intc.sub_lot_no
             AND intc_inner.baseescdesc_type = ''Esc/Desc''
             AND intc_inner.element_id = intc.element_id) AS esc_desc_amount,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                                      invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.sub_lot_no = intc.sub_lot_no
             AND intc_inner.baseescdesc_type = ''Base''
             AND intc_inner.element_id = intc.element_id) AS base_tc,
         NVL (grd.internal_stock_ref_no,
              dgrd.internal_stock_ref_no
             ) AS stock_ref_no,
         stragg (DISTINCT intc.baseescdesc_type) AS baseescdesc_type, ?
    FROM is_invoice_summary invs,
         intc_inv_treatment_charges intc,
         cm_currency_master cm,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         aml_attribute_master_list aml,
         grd_goods_record_detail grd,
         dgrd_delivered_grd dgrd,
         qum_quantity_unit_master qum,
         iid_invoicable_item_details iid,
         qum_quantity_unit_master qum_dgrd
   WHERE invs.internal_invoice_ref_no = intc.internal_invoice_ref_no(+)
     AND invs.invoice_cur_id = cm.cur_id(+)
     AND intc.tcharges_price_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND intc.element_id = aml.attribute_id
     AND intc.grd_id = grd.internal_grd_ref_no(+)
     AND intc.grd_id = dgrd.internal_dgrd_ref_no(+)
     AND grd.qty_unit_id = qum.qty_unit_id(+)
     AND dgrd.net_weight_unit_id = qum_dgrd.qty_unit_id(+)
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
         intc.grd_id,
         qum_dgrd.qty_unit,
         dgrd.internal_stock_ref_no';

DECLARE fetchQueryDGMRC CLOB := 'INSERT INTO IS_CONC_TC_CHILD (
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
         SUM (DISTINCT intc.lot_qty) AS dry_qty,
         NVL (qum.qty_unit, qum_dgrd.qty_unit) AS quantity_unit_name,
         SUM (DISTINCT iid.invoiced_qty) AS wet_quantity,
         ROUND (  ((SUM (iid.invoiced_qty) - SUM (intc.lot_qty)) * 100)
                / SUM (iid.invoiced_qty),
                5
               ) AS moisture,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                              invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.sub_lot_no = intc.sub_lot_no
             AND intc_inner.baseescdesc_type = ''Esc/Desc''
             AND intc_inner.element_id = intc.element_id) AS esc_desc_amount,
         (SELECT SUM (intc_inner.tcharges_amount)
            FROM intc_inv_treatment_charges intc_inner
           WHERE intc_inner.internal_invoice_ref_no =
                                      invs.internal_invoice_ref_no
             AND intc_inner.grd_id = intc.grd_id
             AND intc_inner.sub_lot_no = intc.sub_lot_no
             AND intc_inner.baseescdesc_type = ''Base''
             AND intc_inner.element_id = intc.element_id) AS base_tc,
         NVL (grd.internal_stock_ref_no,
              dgrd.internal_stock_ref_no
             ) AS stock_ref_no,
         stragg (DISTINCT intc.baseescdesc_type) AS baseescdesc_type, ?
    FROM is_invoice_summary invs,
         intc_inv_treatment_charges intc,
         cm_currency_master cm,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         aml_attribute_master_list aml,
         grd_goods_record_detail grd,
         dgrd_delivered_grd dgrd,
         qum_quantity_unit_master qum,
         iid_invoicable_item_details iid,
         qum_quantity_unit_master qum_dgrd
   WHERE invs.internal_invoice_ref_no = intc.internal_invoice_ref_no(+)
     AND invs.invoice_cur_id = cm.cur_id(+)
     AND intc.tcharges_price_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND intc.element_id = aml.attribute_id
     AND intc.grd_id = grd.internal_grd_ref_no(+)
     AND intc.grd_id = dgrd.internal_dgrd_ref_no(+)
     AND grd.qty_unit_id = qum.qty_unit_id(+)
     AND dgrd.net_weight_unit_id = qum_dgrd.qty_unit_id(+)
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
         intc.grd_id,
         qum_dgrd.qty_unit,
         dgrd.internal_stock_ref_no';

BEGIN
UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryDGMPayable WHERE DGM.DGM_ID IN ('DGM-PIC-C1','DGM-FIC-C1','DGM-DFIC-C1') AND DGM.DOC_ID IN ('CREATE_PI','CREATE_FI','CREATE_DFI') AND DGM.SEQUENCE_ORDER IN (2) AND DGM.IS_CONCENTRATE = 'Y';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryDGMTC WHERE DGM.DGM_ID IN ('DGM-PIC-C2','DGM-FIC-C2','DGM-DFIC-C2') AND DGM.DOC_ID IN ('CREATE_PI','CREATE_FI','CREATE_DFI') AND DGM.SEQUENCE_ORDER IN (3) AND DGM.IS_CONCENTRATE = 'Y';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryDGMRC WHERE DGM.DGM_ID IN ('DGM-PIC-C3','DGM-FIC-C3','DGM-DFIC-C3') AND DGM.DOC_ID IN ('CREATE_PI','CREATE_FI','CREATE_DFI') AND DGM.SEQUENCE_ORDER IN (4) AND DGM.IS_CONCENTRATE = 'Y';

COMMIT;
END;