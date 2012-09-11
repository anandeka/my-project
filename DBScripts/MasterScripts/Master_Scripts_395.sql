UPDATE dgm_document_generation_master dgm
   SET dgm.fetch_query =
          'INSERT INTO VAT_D (
INTERNAL_INVOICE_REF_NO,
CONTRACT_REF_NO,
CP_CONTRACT_REF_NO,
INCO_TERM_LOCATION,
CONTRACT_DATE,
CP_NAME,
SELLER,
CONTRACT_QUANTITY,
CONTRACT_TOLERANCE,
PRODUCT,
QUALITY,
NOTIFY_PARTY,
INVOICE_CREATION_DATE,
INVOICE_DUE_DATE,
INVOICE_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
INTERNAL_DOC_REF_NO,
VAT_PARENT_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
nvl(PCM.CONTRACT_REF_NO,'''') as CONTRACT_REF_NO,
nvl(PCM.CP_CONTRACT_REF_NO,'''') as CP_CONTRACT_REF_NO,
nvl(PYM.PAYMENT_TERM,'''') as INCO_TERM_LOCATION,
nvl(TO_CHAR(PCM.ISSUE_DATE, ''dd-Mon-yyyy''),'''') as CONTRACT_DATE,
PHD.COMPANYNAME as CP_NAME,
'''' as SELLER,
nvl(PCPD.QTY_MAX_VAL,'''') as CONTRACT_QUANTITY,
'''' as CONTRACT_TOLERANCE,
nvl(PDM.PRODUCT_DESC,'''') as PRODUCT,
nvl(QAT.QUALITY_NAME,'''') as QUALITY,
'''' as NOTIFY_PARTY,
TO_CHAR(INVS.INVOICE_CREATED_DATE, ''dd-Mon-yyyy'') as INVOICE_CREATION_DATE,
TO_CHAR(INVS.PAYMENT_DUE_DATE, ''dd-Mon-yyyy'') as INVOICE_DUE_DATE,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
nvl(PCM.CONTRACT_TYPE,'''') as CONTRACT_TYPE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
nvl(PCM.PURCHASE_SALES,'''') as SALES_PURCHASE,
?,
INVS.VAT_PARENT_REF_NO as VAT_PARENT_REF_NO
from
IS_INVOICE_SUMMARY invs,
IVD_INVOICE_VAT_DETAILS ivd,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
PYM_PAYMENT_TERMS_MASTER pym,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd
where
INVS.INTERNAL_INVOICE_REF_NO = IVD.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO(+)
and PCPD.INTERNAL_CONTRACT_REF_NO(+) = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and nvl(PCPD.INPUT_OUTPUT,''Input'') = ''Input''
and PCI.INTERNAL_CONTRACT_REF_NO(+) = PCM.INTERNAL_CONTRACT_REF_NO
and PCI.QUALITY_ID = QAT.QUALITY_ID(+)
AND INVS.CP_ID = PHD.PROFILEID(+)
AND INVS.CREDIT_TERM = PYM.PAYMENT_TERM_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by 
INVS.INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
PCM.ISSUE_DATE,
PHD.COMPANYNAME,
PCPD.QTY_MAX_VAL,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
INVS.INVOICE_CREATED_DATE,
INVS.PAYMENT_DUE_DATE,
INVS.INVOICE_REF_NO,
PCM.CONTRACT_TYPE,
INVS.INVOICE_STATUS,
PCM.PURCHASE_SALES,
INVS.VAT_PARENT_REF_NO'
 WHERE dgm.doc_id = 'CREATE_VAT'
   AND dgm.is_concentrate = 'Y'
   AND dgm.dgm_id = 'DGM-VAT-1-CONC';


UPDATE dgm_document_generation_master dgm
   SET dgm.fetch_query =
          'INSERT INTO VAT_D (
INTERNAL_INVOICE_REF_NO,
CONTRACT_REF_NO,
CP_CONTRACT_REF_NO,
INCO_TERM_LOCATION,
CONTRACT_DATE,
CP_NAME,
SELLER,
CONTRACT_QUANTITY,
CONTRACT_TOLERANCE,
PRODUCT,
QUALITY,
NOTIFY_PARTY,
INVOICE_CREATION_DATE,
INVOICE_DUE_DATE,
INVOICE_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
INTERNAL_DOC_REF_NO,
VAT_PARENT_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
nvl(PCM.CONTRACT_REF_NO,'''') as CONTRACT_REF_NO,
nvl(PCM.CP_CONTRACT_REF_NO,'''') as CP_CONTRACT_REF_NO,
nvl(PYM.PAYMENT_TERM,'''') as INCO_TERM_LOCATION,
nvl(TO_CHAR(PCM.ISSUE_DATE, ''dd-Mon-yyyy''),'''') as CONTRACT_DATE,
PHD.COMPANYNAME as CP_NAME,
'''' as SELLER,
nvl(PCPD.QTY_MAX_VAL,'''') as CONTRACT_QUANTITY,
'''' as CONTRACT_TOLERANCE,
nvl(PDM.PRODUCT_DESC,'''') as PRODUCT,
nvl(QAT.QUALITY_NAME,'''') as QUALITY,
'''' as NOTIFY_PARTY,
TO_CHAR(INVS.INVOICE_CREATED_DATE, ''dd-Mon-yyyy'') as INVOICE_CREATION_DATE,
TO_CHAR(INVS.PAYMENT_DUE_DATE, ''dd-Mon-yyyy'') as INVOICE_DUE_DATE,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
nvl(PCM.CONTRACT_TYPE,'''') as CONTRACT_TYPE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
nvl(PCM.PURCHASE_SALES,'''') as SALES_PURCHASE,
?,
INVS.VAT_PARENT_REF_NO as VAT_PARENT_REF_NO
from
IS_INVOICE_SUMMARY invs,
IVD_INVOICE_VAT_DETAILS ivd,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
PYM_PAYMENT_TERMS_MASTER pym,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd
where
INVS.INTERNAL_INVOICE_REF_NO = IVD.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO(+)
and PCPD.INTERNAL_CONTRACT_REF_NO(+) = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and PCI.INTERNAL_CONTRACT_REF_NO(+) = PCM.INTERNAL_CONTRACT_REF_NO
and PCI.QUALITY_ID = QAT.QUALITY_ID(+)
AND INVS.CP_ID = PHD.PROFILEID(+)
AND INVS.CREDIT_TERM = PYM.PAYMENT_TERM_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by 
INVS.INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO,
PYM.PAYMENT_TERM,
PCM.ISSUE_DATE,
PHD.COMPANYNAME,
PCPD.QTY_MAX_VAL,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
INVS.INVOICE_CREATED_DATE,
INVS.PAYMENT_DUE_DATE,
INVS.INVOICE_REF_NO,
PCM.CONTRACT_TYPE,
INVS.INVOICE_STATUS,
PCM.PURCHASE_SALES,
INVS.VAT_PARENT_REF_NO'
 WHERE dgm.doc_id = 'CREATE_VAT'
   AND dgm.is_concentrate = 'N'
   AND dgm.dgm_id = 'DGM-VAT-1';