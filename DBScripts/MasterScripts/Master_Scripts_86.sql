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
QUM_QUANTITY_UNIT_MASTER qum
where
INVS.INTERNAL_INVOICE_REF_NO = APID.INTERNAL_INVOICE_REF_NO
and APID.CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCI.QUALITY_ID = QAT.QUALITY_ID
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INVOICE_CUR_ID = CM.CUR_ID
and INVS.CREDIT_TERM = PYM.PAYMENT_TERM_ID
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
INVS.INTERNAL_INVOICE_REF_NO,
QUM.QTY_UNIT', 'N');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-API-2', 'CREATE_API', 'Advance Payment Invoice', 'CREATE_API', 2, 
    'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, ?
     FROM phd_profileheaderdetails phd,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oipi.bank_id = phd.profileid
      AND invs.internal_invoice_ref_no = ?', 'N');
      
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-API-3', 'CREATE_API', 'Advance Payment Invoice', 'CREATE_API', 3, 
    'INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, cpipi.bank_account AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction, ?
     FROM phd_profileheaderdetails phd,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = phd.profileid
      AND invs.internal_invoice_ref_no = ?', 'N');
      
      
      
update DC_DOCUMENT_CONFIGURATION dc set DC.IS_GENERATE_DOC_REQD = 'Y', DC.DOC_VALIDATION_QUERY = 'select count(*) as countRow
from API_D isd
where isd.INTERNAL_DOC_REF_NO = ?' where DC.ACTIVITY_ID = 'CREATE_API';



Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID)
 Values
   ('CREATE_API', 'Advance Payment Invoice', 1, NULL, 'Y', 
    'N', NULL);

Insert into ADM_ACTION_DOCUMENT_MASTER
   (ADM_ID, ACTION_ID, DOC_ID, IS_DELETED)
 Values
   ('ADM-API-1', 'CREATE_API', 'CREATE_API', 'N');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('API_KEY_1', 'Advance Payment Invoice', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = 

:pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('API_KEY_2', 'Advance Payment Invoice', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = 

:pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');
