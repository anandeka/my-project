DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO IS_CONC_PAYABLE_CHILD (
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
nvl(GRD.QTY, DGRD.NET_WEIGHT) as STOCK_QTY,
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
ASM.DRY_WEIGHT AS DRY_QUANTITY,
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
   fetchqry2   CLOB
      := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no
                                                   AS internal_invoice_ref_no,
                         NVL
                            (pcmac.addn_charge_name,
                             scm.cost_display_name
                            ) AS other_charge_cost_name,
                         ioc.charge_type AS charge_type,
                         (CASE
                             WHEN (ioc.rate_fx_rate IS NULL)
                             AND (ioc.flat_amount_fx_rate IS NULL)
                                THEN 1
                             WHEN ioc.rate_fx_rate IS NULL
                                THEN ioc.flat_amount_fx_rate
                             ELSE ioc.rate_fx_rate
                          END
                         ) AS fx_rate,
                         ioc.quantity AS quantity,
                         NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                         ioc.amount_in_inv_cur AS invoice_amount,
                         cm.cur_code AS invoice_cur_name,
                         (CASE
                             WHEN ioc.rate_price_unit = ''Bags''
                             AND ioc.charge_type = ''Rate''
                                THEN cm.cur_code || ''/'' || ''Bag''
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                                     ''Ocular Inspection Charge'')
                             AND ioc.charge_type = ''Rate''
                                THEN cm_lot.cur_code || ''/'' || ''Lot''
                             ELSE pum.price_unit_name
                          END
                         ) AS rate_price_unit_name,
                         NVL (ioc.flat_amount,
                              ioc.rate_charge
                             ) AS charge_amount_rate,
                         (CASE
                             WHEN ioc.rate_price_unit = ''Bags''
                                THEN ''Bags''
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                                     ''Ocular Inspection Charge'')
                                THEN ''Lots''
                             WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                                THEN ''Lots''
                             ELSE qum.qty_unit
                          END
                         ) AS quantity_unit,
                         (CASE
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                                     ''Ocular Inspection Charge'')
                             AND ioc.charge_type = ''Rate''
                                THEN cm_lot.cur_code
                             WHEN scm.cost_component_name IN
                                                          (''Handling Charge'')
                                THEN cm.cur_code
                             WHEN ioc.charge_type =''Rate''
                                THEN cm_pum.cur_code
                             ELSE cm_ioc.cur_code
                          END
                         ) AS amount_unit,
                         ?
                    FROM is_invoice_summary invs,
                         ioc_invoice_other_charge ioc,
                         cm_currency_master cm,
                         scm_service_charge_master scm,
                         ppu_product_price_units ppu,
                         pum_price_unit_master pum,
                         qum_quantity_unit_master qum,
                         cm_currency_master cm_ioc,
                         cm_currency_master cm_pum,
                         cm_currency_master cm_lot,
                         pcmac_pcm_addn_charges pcmac
                   WHERE invs.internal_invoice_ref_no =
                                                   ioc.internal_invoice_ref_no
                     AND ioc.other_charge_cost_id = scm.cost_id(+)
                     AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
                     AND ioc.invoice_cur_id = cm.cur_id(+)
                     AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
                     AND ioc.rate_price_unit = cm_lot.cur_id(+)
                     AND ppu.price_unit_id = pum.price_unit_id(+)
                     AND ioc.qty_unit_id = qum.qty_unit_id(+)
                     AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
                     AND cm_pum.cur_id(+) = pum.cur_id
                     AND ioc.internal_invoice_ref_no = ?)
   SELECT *
     FROM TEST t
    WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry1
    WHERE dgm.doc_id IN ('CREATE_PI', 'CREATE_FI', 'CREATE_DFI')
      AND dgm.dgm_id IN ('DGM-FIC-C1', 'DGM-PIC-C1', 'DGM-DFIC-C1')
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry2
    WHERE dgm.doc_id IN ('CREATE_PI', 'CREATE_FI', 'CREATE_DFI')
      AND dgm.dgm_id IN ('DGM-IOC_C', 'DGM-IOC_BM', 'DGM-DFI-C7');

   COMMIT;
END;