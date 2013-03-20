declare
fetchQryPayable CLOB := 'INSERT INTO IS_CONC_PAYABLE_CHILD (
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
Select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUANTITY,
nvl(QAT.QUALITY_NAME, QAT1.QUALITY_NAME) as GMR_QUALITY,
QUM.QTY_UNIT as GMR_QTY_UNIT,
PUM.PRICE_UNIT_NAME as INVOICED_PRICE_UNIT,
nvl(GRD.INTERNAL_STOCK_REF_NO, DGRD.INTERNAL_STOCK_REF_NO) as STOCK_REF_NO,
IID.INVOICED_QTY as STOCK_QTY,
AML.ATTRIBUTE_NAME AS ELEMENT_NAME,
IIED.ELEMENT_PAYABLE_PRICE AS INVOICE_PRICE,
IIED.SUB_LOT_NO AS SUB_LOT_NO,
IIED.ELEMENT_PAYABLE_AMOUNT AS ELEMENT_INV_AMOUNT,
PEPUM.PRICE_UNIT_NAME AS ELEMENT_PRICE_UNIT,
PQCA.TYPICAL as ASSAY_CONTENT,
RM.RATIO_NAME as ASSAY_CONTENT_UNIT,
IIED.ELEMENT_INVOICED_QTY AS ELEMENT_INVOICED_QTY,
QUMIIED.QTY_UNIT AS ELEMENT_INVOICED_QTY_UNIT,
AML.ATTRIBUTE_ID AS ELEMENT_ID,
PQCAPD.PAYABLE_PERCENTAGE AS NET_PAYABLE,
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
                      AND aml_mos.attribute_name = ''H2O'')
                / 100
               )
            ),
            10
           ) AS dry_quantity,
?
from
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
GMR_GOODS_MOVEMENT_RECORD gmr,
QUM_QUANTITY_UNIT_MASTER qum,
QUM_QUANTITY_UNIT_MASTER quminv,
PPU_PRODUCT_PRICE_UNITS ppu,
PUM_PRICE_UNIT_MASTER pum,
GRD_GOODS_RECORD_DETAIL grd,
DGRD_DELIVERED_GRD dgrd,
QAT_QUALITY_ATTRIBUTES qat,
QAT_QUALITY_ATTRIBUTES qat1,
IIED_INV_ITEM_ELEMENT_DETAILS IIED,
AML_ATTRIBUTE_MASTER_LIST AML,
PPU_PRODUCT_PRICE_UNITS PEPU,
PUM_PRICE_UNIT_MASTER PEPUM,
ASH_ASSAY_HEADER ASH,
ASM_ASSAY_SUBLOT_MAPPING ASM,
PQCA_PQ_CHEMICAL_ATTRIBUTES PQCA,
PQCAPD_PRD_QLTY_CATTR_PAY_DTLS pqcapd,
IAM_INVOICE_ASSAY_MAPPING IAM,
RM_RATIO_MASTER rm,
QUM_QUANTITY_UNIT_MASTER QUMIIED
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO(+)
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
and GMR.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
and IID.INVOICED_QTY_UNIT_ID = QUMINV.QTY_UNIT_ID(+)
and IID.NEW_INVOICE_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID(+)
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
and IID.STOCK_ID = GRD.INTERNAL_GRD_REF_NO(+)
and IID.STOCK_ID = DGRD.INTERNAL_DGRD_REF_NO(+)
and GRD.QUALITY_ID = QAT.QUALITY_ID(+)
and DGRD.QUALITY_ID = QAT1.QUALITY_ID(+)
AND IIED.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO(+)
AND AML.ATTRIBUTE_ID = IIED.ELEMENT_ID(+)
AND IIED.ELEMENT_PAYABLE_PRICE_UNIT_ID = PEPU.INTERNAL_PRICE_UNIT_ID(+)
AND PEPU.PRICE_UNIT_ID = PEPUM.PRICE_UNIT_ID(+)
AND IAM.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO
AND IAM.ASH_ID = ASH.ASH_ID
AND ASH.ASH_ID = ASM.ASH_ID
AND ASM.ASM_ID = PQCA.ASM_ID
AND IIED.ELEMENT_ID = PQCA.ELEMENT_ID
and PQCA.UNIT_OF_MEASURE = RM.RATIO_ID
and PQCA.PQCA_ID = PQCAPD.PQCA_ID
AND IIED.ELEMENT_INV_QTY_UNIT_ID = QUMIIED.QTY_UNIT_ID
and IIED.GRD_ID = IAM.INTERNAL_GRD_REF_NO
and IIED.GRD_ID = IID.STOCK_ID
and IID.INTERNAL_INVOICE_REF_NO = ?';


begin
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryPayable where DGM.DOC_ID IN ('CREATE_PI','CREATE_FI','CREATE_DFI') and DGM.DGM_ID IN ('DGM-PIC-C1','DGM-FIC-C1','DGM-DFIC-C1') and DGM.SEQUENCE_ORDER = 2;
commit;
end;

declare
fetchQryTC CLOB := 'INSERT INTO IS_CONC_TC_CHILD (
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
tc_price,
price_unit,
stock_ref_no,
INTERNAL_DOC_REF_NO
)
SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
       intc.tcharges_amount AS tc_amount, intc.element_id AS element_id,
       cm.cur_code AS amount_unit, intc.sub_lot_no AS sub_lot_no,
       aml.attribute_name AS element_name, intc.lot_qty AS dry_qty,
       qum.qty_unit AS quantity_unit_name, iid.invoiced_qty AS wet_quantity,
       ROUND (((iid.invoiced_qty - intc.lot_qty) * 100) / iid.invoiced_qty,
              5
             ) AS moisture,
       intc.tcharges_price AS tc_price, pum.price_unit_name AS price_unit,
       grd.internal_stock_ref_no AS stock_ref_no, ?
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
   AND invs.internal_invoice_ref_no = ?';


begin
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryTC where DGM.DOC_ID IN ('CREATE_PI','CREATE_FI','CREATE_DFI') and DGM.DGM_ID IN ('DGM-PIC-C2','DGM-FIC-C2','DGM-DFIC-C2') and DGM.SEQUENCE_ORDER = 3;
commit;
end;

declare
fetchQryPenalty CLOB := 'INSERT INTO IS_CONC_PENALTY_CHILD(
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
SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
       iepd.element_penalty_amount AS penalty_amount,
       aml.attribute_name AS element_name, aml.attribute_id AS element_id,
       cm.cur_code AS amount_unit, iepd.element_qty AS penalty_qty,
       pqca.typical AS assay_details, iepd.sub_lot_no AS stock_ref_no,
       rm.ratio_name AS uom, iepd.element_penalty_price AS penalty_rate,
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
   AND iepd.stock_id = grd.internal_grd_ref_no
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
   AND invs.internal_invoice_ref_no = ?';


begin
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryPenalty where DGM.DOC_ID IN ('CREATE_PI','CREATE_FI','CREATE_DFI') and DGM.DGM_ID IN ('DGM-PIC-C4 ','DGM-FIC-C4 ','DGM-DFIC-C4 ') and DGM.SEQUENCE_ORDER = 5;
commit;
end;