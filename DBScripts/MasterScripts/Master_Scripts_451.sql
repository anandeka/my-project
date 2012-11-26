DECLARE
fetchQuery1 CLOB :='INSERT INTO IGD_INV_GMR_DETAILS_D(
INTERNAL_INVOICE_REF_NO,
GMR_REF_NO,
CONTAINER_NAME,
MODE_OF_TRANSPORT,
BL_DATE,
origin_city,
origin_country,
WET_QTY,
WET_QTY_UNIT_NAME,
DRY_QTY,
DRY_QTY_UNIT_NAME,
MOISTURE,
MOISTURE_UNIT_NAME,
INTERNAL_DOC_REF_NO
)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         gmr.gmr_ref_no AS gmr_ref_no, 
         stragg(grd.container_no) AS container_name,
         NVL (gmr.mode_of_transport, '''') AS mode_of_transport,
         gmr.bl_date AS bl_date,
         NVL(CIM.CITY_NAME,'''') AS origin_city,
         NVL(CYM.COUNTRY_NAME,'''') AS origin_country,
         gmr.qty AS wet_qty, 
         QUM.QTY_UNIT AS wet_qty_unit_name,
         SUM (asm.dry_weight) AS dry_qty, 
         QUM.QTY_UNIT AS dry_qty_unit_name,
         ROUND(((gmr.qty - SUM (asm.dry_weight)) / gmr.qty) * 100,5) AS moisture,
         QUM.QTY_UNIT AS moisture_unit_name, ?
    FROM is_invoice_summary invs,
         iid_invoicable_item_details iid,
         grd_goods_record_detail grd,
         gmr_goods_movement_record gmr,
         asm_assay_sublot_mapping asm,
         ash_assay_header ash,
         iam_invoice_assay_mapping iam,
         CYM_COUNTRYMASTER cym,
         CIM_CITYMASTER cim,
         QUM_QUANTITY_UNIT_MASTER qum
   WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     AND gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
     AND iid.stock_id = grd.internal_grd_ref_no
     AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
     AND iid.stock_id = iam.internal_grd_ref_no
     AND iam.ash_id = ash.ash_id
     AND ash.ash_id = asm.ash_id
     and QUM.QTY_UNIT_ID = ASM.NET_WEIGHT_UNIT
     AND CYM.COUNTRY_ID(+) = gmr.loading_country_id
     and CIM.CITY_ID(+) = gmr.loading_city_id
     AND invs.internal_invoice_ref_no = ?
GROUP BY gmr.internal_gmr_ref_no,
         gmr.qty,
         invs.internal_invoice_ref_no,
         grd.container_no,
         gmr.mode_of_transport,
         gmr.bl_date,
         gmr.gmr_ref_no,
         CYM.COUNTRY_NAME,
         CIM.CITY_NAME,
         QUM.QTY_UNIT'; 
BEGIN
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-FIC-IGD', 'CREATE_FI', 'Concentrate Final Invoice', 'CREATE_FI', 14, 
    fetchQuery1, 'Y');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFIC-IGD', 'CREATE_DFI', 'Concentrate Direct Final Invoice', 'CREATE_DFI', 14, 
    fetchQuery1, 'Y');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-PIC-IGD', 'CREATE_PI', 'Concentrate Provisional Invoice', 'CREATE_PI', 12, 
    fetchQuery1, 'Y');
commit;
END;


DECLARE
fetchQuery1 CLOB :='INSERT INTO IS_CONC_TC_CHILD (
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
       intc.tcharges_amount AS tc_amount,
       intc.element_id AS element_id,
       cm.cur_code AS amount_unit,
       intc.sub_lot_no AS sub_lot_no,
       aml.attribute_name AS element_name,
       intc.lot_qty AS dry_qty,
       qum.qty_unit AS QUANTITY_UNIT_NAME,
       grd.qty AS WET_QUANTITY,
       ((grd.qty - intc.lot_qty) * 100) / grd.qty AS moisture,
       intc.tcharges_price AS tc_price,
       pum.price_unit_name AS price_unit,
       GRD.INTERNAL_STOCK_REF_NO as stock_ref_no,
       ?
  FROM is_invoice_summary invs,
       intc_inv_treatment_charges intc,
       cm_currency_master cm,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       aml_attribute_master_list aml,
       grd_goods_record_detail grd,
       qum_quantity_unit_master qum
 WHERE invs.internal_invoice_ref_no = intc.internal_invoice_ref_no(+)
   AND invs.invoice_cur_id = cm.cur_id(+)
   AND intc.tcharges_price_unit_id = ppu.internal_price_unit_id(+)
   AND ppu.price_unit_id = pum.price_unit_id(+)
   AND intc.element_id = aml.attribute_id
   AND intc.grd_id = grd.internal_grd_ref_no
   AND grd.qty_unit_id = qum.qty_unit_id
   AND invs.internal_invoice_ref_no = ?';
BEGIN
    update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQuery1 where DGM.DOC_ID IN ('CREATE_FI','CREATE_DFI','CREATE_PI') AND DGM.IS_CONCENTRATE='Y' AND DGM.SEQUENCE_ORDER = 3;
commit;
END;


DECLARE
fetchQuery1 CLOB :='INSERT INTO IS_CONC_RC_CHILD(
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
        price_name,
        assay_uom,
        STOCK_REF_NO,
        INTERNAL_DOC_REF_NO
        )
 SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
       inrc.rcharges_amount AS rc_amount, aml.attribute_name AS element_name,
       aml.attribute_id AS element_id, cm.cur_code AS amount_unit,
       inrc.sub_lot_no AS sub_lot_no, inrc.lot_qty AS dry_quantity,
       qum.qty_unit AS quantity_unit_name,
       pqcapd.payable_percentage AS assay_details,
       inrc.rcharges_price AS rc_es_ds, pum.price_unit_name AS price_name,
       rm.ratio_name AS assay_uom, GRD.INTERNAL_STOCK_REF_NO AS STOCK_REF_NO,
       ?
  FROM is_invoice_summary invs,
       inrc_inv_refining_charges inrc,
       aml_attribute_master_list aml,
       cm_currency_master cm,
       iam_invoice_assay_mapping iam,
       grd_goods_record_detail grd,
       qum_quantity_unit_master qum,
       ash_assay_header ash,
       asm_assay_sublot_mapping asm,
       pqca_pq_chemical_attributes pqca,
       pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       rm_ratio_master rm
WHERE invs.internal_invoice_ref_no = inrc.internal_invoice_ref_no(+)
   AND inrc.element_id = aml.attribute_id(+)
   AND invs.invoice_cur_id = cm.cur_id
   AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
   AND inrc.grd_id = iam.internal_grd_ref_no
   AND iam.internal_grd_ref_no = grd.internal_grd_ref_no
   AND grd.internal_grd_ref_no = inrc.grd_id
   AND grd.qty_unit_id = qum.qty_unit_id
   AND iam.ash_id = ash.ash_id
   AND ash.ash_id = asm.ash_id
   AND asm.asm_id = pqca.asm_id
   AND pqca.pqca_id = pqcapd.pqca_id
   AND pqca.element_id = inrc.element_id
   AND inrc.rcharges_price_unit_id = ppu.internal_price_unit_id
   AND ppu.price_unit_id = pum.price_unit_id
   AND pqca.unit_of_measure = rm.ratio_id
   AND invs.internal_invoice_ref_no = ?';
BEGIN
    update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQuery1 where DGM.DOC_ID IN ('CREATE_FI','CREATE_DFI','CREATE_PI')  AND DGM.IS_CONCENTRATE='Y' AND DGM.SEQUENCE_ORDER = 4;
commit;
END;


DECLARE
fetchQuery1 CLOB :='INSERT INTO IS_CONC_PENALTY_CHILD(
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
select 
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
IEPD.ELEMENT_PENALTY_AMOUNT as PENALTY_AMOUNT,
AML.ATTRIBUTE_NAME as ELEMENT_NAME,
AML.ATTRIBUTE_ID as ELEMENT_ID,
CM.CUR_CODE as AMOUNT_UNIT,
IEPD.ELEMENT_QTY as penalty_qty,
PQCA.TYPICAL as assay_details,
IEPD.SUB_LOT_NO as STOCK_REF_NO,
RM.RATIO_NAME as UOM,
IEPD.ELEMENT_PENALTY_PRICE as penalty_rate,
PUM.PRICE_UNIT_NAME as price_name,
GRD.QTY as wet_qty,
ASM.DRY_WEIGHT AS DRY_QUANTITY,
QUM.QTY_UNIT as QUANTITY_UOM,
?
from
IS_INVOICE_SUMMARY invs,
IEPD_INV_EPENALTY_DETAILS iepd,
AML_ATTRIBUTE_MASTER_LIST aml,
CM_CURRENCY_MASTER cm,
IAM_INVOICE_ASSAY_MAPPING iam,
PQCA_PQ_CHEMICAL_ATTRIBUTES pqca,
ASH_ASSAY_HEADER ash,
ASM_ASSAY_SUBLOT_MAPPING asm,
GRD_GOODS_RECORD_DETAIL grd,
RM_RATIO_MASTER rm,
PPU_PRODUCT_PRICE_UNITS ppu,
QUM_QUANTITY_UNIT_MASTER qum,
PUM_PRICE_UNIT_MASTER pum
where
INVS.INTERNAL_INVOICE_REF_NO = IEPD.INTERNAL_INVOICE_REF_NO
and IEPD.ELEMENT_ID = AML.ATTRIBUTE_ID(+)
and INVS.INVOICE_CUR_ID = CM.CUR_ID
and INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
and IAM.INTERNAL_GRD_REF_NO = IEPD.STOCK_ID
and IEPD.STOCK_ID = GRD.INTERNAL_GRD_REF_NO
and AML.ATTRIBUTE_ID = PQCA.ELEMENT_ID
and IAM.ASH_ID = ASH.ASH_ID
and ASH.ASH_ID = ASM.ASH_ID
and ASM.ASM_ID = PQCA.ASM_ID
and ASM.NET_WEIGHT_UNIT = QUM.QTY_UNIT_ID
and PQCA.UNIT_OF_MEASURE = RM.RATIO_ID
and IEPD.ELEMENT_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?'; 
BEGIN
    update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQuery1 where DGM.DOC_ID IN('CREATE_FI','CREATE_DFI','CREATE_PI') AND DGM.IS_CONCENTRATE='Y' AND DGM.SEQUENCE_ORDER = 5;
commit;
END;


DECLARE
fetchQuery1 CLOB :='INSERT INTO IS_CONC_PAYABLE_CHILD (
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
and ASM.SUB_LOT_NO = IIED.SUB_LOT_NO
and IIED.GRD_ID = IAM.INTERNAL_GRD_REF_NO
and IIED.GRD_ID = IID.STOCK_ID
and IID.INTERNAL_INVOICE_REF_NO = ?'; 
BEGIN
    update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQuery1 where DGM.DOC_ID IN ('CREATE_DFI','CREATE_FI','CREATE_PI') AND DGM.IS_CONCENTRATE='Y' AND DGM.SEQUENCE_ORDER = 2;
commit;
END;

DECLARE
fetchQry1  clob := 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_DRY_QUANTITY,
INVOICE_WET_QUANTITY,
MOISTURE,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
MATERIAL_COST,
ADDDITIONAL_CHARGES,
TAXES,
DUE_DATE,
SUPPLIRE_INVOICE_NO,
CONTRACT_DATE,
CONTRACT_REF_NO,
STOCK_QUANTITY,
STOCK_REF_NO,
INVOICE_AMOUNT_UNIT,
GMR_REF_NO,
GMR_QUALITY,
CONTRACT_QUANTITY,
CONTRACT_QTY_UNIT,
CONTRACT_TOLERANCE,
QUALITY,
PRODUCT,
CP_CONTRACT_REF_NO,
PAYMENT_TERM,
GMR_FINALIZE_QTY,
CP_NAME,
CP_ADDRESS,
CP_COUNTRY,
CP_CITY,
CP_STATE,
CP_ZIP,
CONTRACT_TYPE,
ORIGIN,
INCO_TERM_LOCATION,
NOTIFY_PARTY,
SALES_PURCHASE,
INVOICE_STATUS,
FREIGHT_CHARGE,
ADJUSTMENT_AMOUNT,
TOTAL_PREMIUM_AMOUNT,
INTERNAL_DOC_REF_NO
)
with test as (select invs.INTERNAL_INVOICE_REF_NO, sum(ASM.NET_WEIGHT) as wet,
sum(ASM.DRY_WEIGHT) as dry
from 
IS_INVOICE_SUMMARY invs,
ASH_ASSAY_HEADER ash,
ASM_ASSAY_SUBLOT_MAPPING asm,
IAM_INVOICE_ASSAY_MAPPING iam
where
INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
and IAM.ASH_ID = ASH.ASH_ID
and ASH.ASH_ID = ASM.ASH_ID
group by invs.INTERNAL_INVOICE_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
t.DRY as INVOICE_DRY_QUANTITY,
t.WET as INVOICE_WET_QUANTITY,
ROUND((((t.WET - t.DRY)/t.WET)*100),2) as MOISTURE,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ as MATERIAL_COST,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
stragg(DISTINCT II.STOCK_REF_NO) as STOCK_REF_NO,
NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
stragg(DISTINCT GMR.GMR_REF_NO) as GMR_REF_NO,
sum(GMR.QTY) as GMR_QUALITY,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
QUM.QTY_UNIT as CONTRACT_QTY_UNIT,
PCPD.MAX_TOLERANCE as CONTRACT_TOLERANCE,
QAT.QUALITY_NAME as QUALITY,
PDM.PRODUCT_DESC as PRODUCT,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM as PAYMENT_TERM,
GMR.FINAL_WEIGHT as GMR_FINALIZE_QTY,
PHD.COMPANYNAME as CP_NAME,
PAD.ADDRESS as CP_ADDRESS,
CYM.COUNTRY_NAME as CP_COUNTRY,
CIM.CITY_NAME as CP_CITY,
SM.STATE_NAME as CP_STATE,
PAD.ZIP as CP_ZIP,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME as ORIGIN,
PCI.TERMS as INCO_TERM_LOCATION,
nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME) as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.FREIGHT_ALLOWANCE_AMT as FREIGHT_CHARGE,
INVS.INVOICE_ADJUSTMENT_AMOUNT as ADJUSTMENT_AMOUNT,
INVS.TOTAL_PREMIUM_AMOUNT as TOTAL_PREMIUM_AMOUNT,
?
from 
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
II_INVOICABLE_ITEM ii,
CM_CURRENCY_MASTER cm,
GMR_GOODS_MOVEMENT_RECORD gmr,
PCPD_PC_PRODUCT_DEFINITION pcpd,
QUM_QUANTITY_UNIT_MASTER qum,
PCPQ_PC_PRODUCT_QUALITY pcpq,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
PAD_PROFILE_ADDRESSES pad,
CYM_COUNTRYMASTER cym,
CIM_CITYMASTER cim,
SM_STATE_MASTER sm,
BPAT_BP_ADDRESS_TYPE bpat,
CYM_COUNTRYMASTER cymloading,
SAD_SHIPMENT_ADVICE sad,
SD_SHIPMENT_DETAIL sd,
PHD_PROFILEHEADERDETAILS phd1,
PHD_PROFILEHEADERDETAILS phd2,
QUM_QUANTITY_UNIT_MASTER qum_gmr,
cm_currency_master cm_pct,
test t
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO(+)
and IID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO(+)
and IID.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO(+)
and IID.INVOICABLE_ITEM_ID = II.INVOICABLE_ITEM_ID(+)
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INVOICE_CURRENCY_ID = CM.CUR_ID(+)
and II.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO(+)
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
and PCPD.PCPD_ID = PCPQ.PCPD_ID(+)
and PCI.QUALITY_ID = QAT.QUALITY_ID(+)
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and INVS.CP_ID = PHD.PROFILEID(+)
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID(+)
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.NOTIFY_PARTY_ID = PHD1.PROFILEID(+)
and SD.NOTIFY_PARTY_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and invs.invoice_cur_id = cm_pct.cur_id(+)
and PAD.ADDRESS_TYPE(+) = ''Billing''
and PAD.IS_DELETED(+) = ''N''
and PCPD.INPUT_OUTPUT in (''Input'')
and t.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE,
INVS.INVOICED_QTY,
INVS.INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
INVS.TOTAL_TAX_AMOUNT,
INVS.PAYMENT_DUE_DATE,
INVS.CP_REF_NO,
PCM.ISSUE_DATE,
PCM.CONTRACT_REF_NO,
CM.CUR_CODE,
PCPD.QTY_MAX_VAL,
QUM.QTY_UNIT,
PCPD.MAX_TOLERANCE,
QAT.QUALITY_NAME,
PDM.PRODUCT_DESC,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
GMR.FINAL_WEIGHT,
PHD.COMPANYNAME,
PAD.ADDRESS,
CYM.COUNTRY_NAME,
CIM.CITY_NAME,
SM.STATE_NAME,
PAD.ZIP,
PCM.CONTRACT_TYPE,
CYMLOADING.COUNTRY_NAME,
PCI.TERMS,
PHD1.COMPANYNAME,
PHD2.COMPANYNAME,
QUM_GMR.QTY_UNIT,
PCI.CONTRACT_TYPE,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS,
INVS.FREIGHT_ALLOWANCE_AMT,
INVS.INVOICE_ADJUSTMENT_AMOUNT,
INVS.TOTAL_PREMIUM_AMOUNT,
cm_pct.cur_code,
t.DRY,
t.WET';
BEGIN
    UPDATE dgm_document_generation_master dgm
   SET dgm.fetch_query = fetchqry1
 WHERE dgm.doc_id IN ('CREATE_DFI', 'CREATE_FI', 'CREATE_PI')
   AND dgm.is_concentrate = 'Y'
   AND dgm.sequence_order = 1;
    commit;
END; 
