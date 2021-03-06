
Delete from DGM_DOCUMENT_GENERATION_MASTER dgm
where DGM.DGM_ID in ('DGM-API-1','DGM-API-1-CONC');



Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-API-1', 'CREATE_API', 'Advance Payment Invoice', 'CREATE_API', 1, 
    'INSERT INTO API_D (
INTERNAL_INVOICE_REF_NO,
CP_NAME,
BUYER,
CP_ITEM_STOCK_REF_NO,
SELF_ITEM_STOCK_REF_NO,
INCO_TERM_LOCATION,
CONTRACT_REF_NO,
CP_CONTRACT_REF_NO,
CONTRACT_DATE,
PRODUCT,
NOTIFY_PARTY,
INVOICE_QUANTITY,
INVOICE_QUANTITY_UNIT,
QUALITY,
PAYMENT_TERM,
PAYMENT_DUE_DATE,
INVOICE_ISSUE_DATE,
INVOICE_AMOUNT_UNIT,
INVOICE_AMOUNT,
INVOICE_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
TOTAL_TAX_AMOUNT,
TOTAL_OTHER_CHARGE_AMOUNT,
PRICE,
PRICE_UNIT,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
PHD.COMPANYNAME as CP_NAME,
'''' as BUYER,
INVS.CP_REF_NO as CP_ITEM_STOCK_REF_NO,
'''' as SELF_ITEM_STOCK_REF_NO,
PCI.TERMS as INCO_TERM_LOCATION,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
TO_CHAR(PCM.ISSUE_DATE,''dd-Mon-yyyy'') as CONTRACT_DATE,
PDM.PRODUCT_DESC as PRODUCT,
'''' as NOTIFY_PARTY,
sum(APID.INVOICE_ITEM_QTY) as INVOICE_QUANTITY,
QUM.QTY_UNIT as INVOICE_QUANTITY_UNIT,
QAT.QUALITY_NAME as QUALITY,
PYM.PAYMENT_TERM as PAYMENT_TERM,
TO_CHAR(INVS.PAYMENT_DUE_DATE,''dd-Mon-yyyy'') as PAYMENT_DUE_DATE,
TO_CHAR(INVS.INVOICE_ISSUE_DATE,''dd-Mon-yyyy'') as INVOICE_ISSUE_DATE,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
PCM.PURCHASE_SALES as SALES_PURCHASE,
INVS.TOTAL_TAX_AMOUNT as TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as TOTAL_OTHER_CHARGE_AMOUNT,
APID.INVOICE_ITEM_PRICE as PRICE,
PUM.PRICE_UNIT_NAME as PRICE_UNIT,
?
from
IS_INVOICE_SUMMARY invs,
APID_ADV_PAYMENT_ITEM_DETAILS apid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd,
CM_CURRENCY_MASTER cm,
PYM_PAYMENT_TERMS_MASTER pym,
QUM_QUANTITY_UNIT_MASTER qum,
PPU_PRODUCT_PRICE_UNITS ppu,
PUM_PRICE_UNIT_MASTER pum
where
INVS.INTERNAL_INVOICE_REF_NO = APID.INTERNAL_INVOICE_REF_NO
and APID.CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCPD.INPUT_OUTPUT = ''Input''
and PCI.QUALITY_ID = QAT.QUALITY_ID
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INVOICE_CUR_ID = CM.CUR_ID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and APID.INVOICE_ITEM_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID(+)
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
PCM.CONTRACT_REF_NO,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
PHD.COMPANYNAME,
INVS.CP_REF_NO,
PCI.TERMS,
PCM.CP_CONTRACT_REF_NO,
PCM.ISSUE_DATE,
INVS.INVOICE_REF_NO,
INVS.INVOICE_ISSUE_DATE,
INVS.PAYMENT_DUE_DATE,
INVS.TOTAL_AMOUNT_TO_PAY,
CM.CUR_CODE,
PYM.PAYMENT_TERM,
PCM.CONTRACT_TYPE,
INVS.INVOICE_STATUS,
PCM.PURCHASE_SALES,
INVS.TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
APID.INVOICE_ITEM_PRICE,
PUM.PRICE_UNIT_NAME,
INVS.INTERNAL_INVOICE_REF_NO,
QUM.QTY_UNIT', 'N');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-API-1-CONC', 'CREATE_API', 'Advance Payment Invoice', 'CREATE_API', 1, 
    'INSERT INTO API_D (
INTERNAL_INVOICE_REF_NO,
CP_NAME,
BUYER,
CP_ITEM_STOCK_REF_NO,
SELF_ITEM_STOCK_REF_NO,
INCO_TERM_LOCATION,
CONTRACT_REF_NO,
CP_CONTRACT_REF_NO,
CONTRACT_DATE,
PRODUCT,
NOTIFY_PARTY,
INVOICE_QUANTITY,
INVOICE_QUANTITY_UNIT,
QUALITY,
PAYMENT_TERM,
PAYMENT_DUE_DATE,
INVOICE_ISSUE_DATE,
INVOICE_AMOUNT_UNIT,
INVOICE_AMOUNT,
INVOICE_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
TOTAL_TAX_AMOUNT,
TOTAL_OTHER_CHARGE_AMOUNT,
PRICE,
PRICE_UNIT,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
PHD.COMPANYNAME as CP_NAME,
'''' as BUYER,
INVS.CP_REF_NO as CP_ITEM_STOCK_REF_NO,
'''' as SELF_ITEM_STOCK_REF_NO,
PCI.TERMS as INCO_TERM_LOCATION,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
TO_CHAR(PCM.ISSUE_DATE,''dd-Mon-yyyy'') as CONTRACT_DATE,
PDM.PRODUCT_DESC as PRODUCT,
'''' as NOTIFY_PARTY,
sum(APID.INVOICE_ITEM_QTY) as INVOICE_QUANTITY,
QUM.QTY_UNIT as INVOICE_QUANTITY_UNIT,
QAT.QUALITY_NAME as QUALITY,
PYM.PAYMENT_TERM as PAYMENT_TERM,
TO_CHAR(INVS.PAYMENT_DUE_DATE,''dd-Mon-yyyy'') as PAYMENT_DUE_DATE,
TO_CHAR(INVS.INVOICE_ISSUE_DATE,''dd-Mon-yyyy'') as INVOICE_ISSUE_DATE,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
PCM.PURCHASE_SALES as SALES_PURCHASE,
INVS.TOTAL_TAX_AMOUNT as TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as TOTAL_OTHER_CHARGE_AMOUNT,
APID.INVOICE_ITEM_PRICE as PRICE,
PUM.PRICE_UNIT_NAME as PRICE_UNIT,
?
from
IS_INVOICE_SUMMARY invs,
APID_ADV_PAYMENT_ITEM_DETAILS apid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd,
CM_CURRENCY_MASTER cm,
PYM_PAYMENT_TERMS_MASTER pym,
QUM_QUANTITY_UNIT_MASTER qum,
PPU_PRODUCT_PRICE_UNITS ppu,
PUM_PRICE_UNIT_MASTER pum
where
INVS.INTERNAL_INVOICE_REF_NO = APID.INTERNAL_INVOICE_REF_NO
and APID.CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCPD.INPUT_OUTPUT = ''Input''
and PCI.QUALITY_ID = QAT.QUALITY_ID
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INVOICE_CUR_ID = CM.CUR_ID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and APID.INVOICE_ITEM_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID(+)
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
PCM.CONTRACT_REF_NO,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
PHD.COMPANYNAME,
INVS.CP_REF_NO,
PCI.TERMS,
PCM.CP_CONTRACT_REF_NO,
PCM.ISSUE_DATE,
INVS.INVOICE_REF_NO,
INVS.INVOICE_ISSUE_DATE,
INVS.PAYMENT_DUE_DATE,
INVS.TOTAL_AMOUNT_TO_PAY,
CM.CUR_CODE,
PYM.PAYMENT_TERM,
PCM.CONTRACT_TYPE,
INVS.INVOICE_STATUS,
PCM.PURCHASE_SALES,
INVS.TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
APID.INVOICE_ITEM_PRICE,
PUM.PRICE_UNIT_NAME,
INVS.INTERNAL_INVOICE_REF_NO,
QUM.QTY_UNIT', 'Y');
