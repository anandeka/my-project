update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_QUANTITY,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
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
INTERNAL_DOC_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
INVS.INVOICED_QTY as INVOICE_QUANTITY,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
II.STOCK_REF_NO as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUALITY,
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
QUM_QUANTITY_UNIT_MASTER qum_gmr
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
and PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID(+)
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and PCM.CP_ID = PHD.PROFILEID(+)
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID(+)
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.CONSIGNEE_ID = PHD1.PROFILEID(+)
and SD.CONSIGNEE_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.ADDRESS_TYPE(+) = 'Billing'
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
II.STOCK_REF_NO,
CM.CUR_CODE,
GMR.GMR_REF_NO,
GMR.QTY,
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
PCI.CONTRACT_TYPE'
where
DGM.DOC_ID = 'CREATE_FI'
and DGM.DGM_ID='DGM-FIC';


update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = 'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_QUANTITY,
INVOICED_QTY_UNIT,
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
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
INTERNAL_DOC_REF_NO
)
select
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
INVS.INVOICE_TYPE_NAME as INVOICE_TYPE_NAME,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
INVS.INVOICED_QTY as INVOICE_QUANTITY,
QUM_GMR.QTY_UNIT as INVOICED_QTY_UNIT,
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
II.STOCK_REF_NO as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUALITY,
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
QUM_QUANTITY_UNIT_MASTER qum_gmr
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
and PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID(+)
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and PCM.CP_ID = PHD.PROFILEID(+)
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID(+)
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.CONSIGNEE_ID = PHD1.PROFILEID(+)
and SD.CONSIGNEE_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.ADDRESS_TYPE(+) = 'Billing'
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
II.STOCK_REF_NO,
CM.CUR_CODE,
GMR.GMR_REF_NO,
GMR.QTY,
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
PCI.CONTRACT_TYPE'
where
DGM.DOC_ID = 'CREATE_PI'
and DGM.DGM_ID='DGM-PIC';