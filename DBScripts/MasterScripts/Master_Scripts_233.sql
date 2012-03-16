DELETE FROM dgm_document_generation_master dgm
      WHERE dgm.dgm_id = 'DGM-VAT-1-CONC';

DELETE FROM dgm_document_generation_master dgm
      WHERE dgm.dgm_id = 'DGM-VAT-1';

DELETE FROM dgm_document_generation_master dgm
      WHERE dgm.dgm_id = 'DGM-API-1';

DELETE FROM dgm_document_generation_master dgm
      WHERE dgm.dgm_id = 'DGM-PFI-1';


      
SET DEFINE OFF;
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-VAT-1-CONC', 'CREATE_VAT', 'VAT Invoice Concentrate',
             'CREATE_VAT', 1,
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
INVOICE_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
INTERNAL_DOC_REF_NO,
VAT_PARENT_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PCI.TERMS as INCO_TERM_LOCATION,
TO_CHAR(PCM.ISSUE_DATE, ''dd-Mon-yyyy'') as CONTRACT_DATE,
PHD.COMPANYNAME as CP_NAME,
'''' as SELLER,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
'''' as CONTRACT_TOLERANCE,
PDM.PRODUCT_DESC as PRODUCT,
QAT.QUALITY_NAME as QUALITY,
'''' as NOTIFY_PARTY,
TO_CHAR(INVS.INVOICE_CREATED_DATE, ''dd-Mon-yyyy'') as INVOICE_CREATION_DATE,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
PCM.PURCHASE_SALES as SALES_PURCHASE,
?,
INVS.VAT_PARENT_REF_NO as VAT_PARENT_REF_NO
from
IS_INVOICE_SUMMARY invs,
IVD_INVOICE_VAT_DETAILS ivd,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd
where
INVS.INTERNAL_INVOICE_REF_NO = IVD.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCPD.INPUT_OUTPUT = ''Input''
and PCI.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCI.QUALITY_ID = QAT.QUALITY_ID
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by 
INVS.INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO,
PCI.TERMS,
PCM.ISSUE_DATE,
PHD.COMPANYNAME,
PCPD.QTY_MAX_VAL,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
INVS.INVOICE_CREATED_DATE,
INVS.INVOICE_REF_NO,
PCM.CONTRACT_TYPE,
INVS.INVOICE_STATUS,
PCM.PURCHASE_SALES,
INVS.VAT_PARENT_REF_NO',
             'Y'
            );


Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-VAT-1', 'CREATE_VAT', 'VAT Invoice', 'CREATE_VAT', 1, 
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
INVOICE_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
INTERNAL_DOC_REF_NO,
VAT_PARENT_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PCI.TERMS as INCO_TERM_LOCATION,
TO_CHAR(PCM.ISSUE_DATE, ''dd-Mon-yyyy'') as CONTRACT_DATE,
PHD.COMPANYNAME as CP_NAME,
'''' as SELLER,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
'''' as CONTRACT_TOLERANCE,
PDM.PRODUCT_DESC as PRODUCT,
QAT.QUALITY_NAME as QUALITY,
'''' as NOTIFY_PARTY,
TO_CHAR(INVS.INVOICE_CREATED_DATE, ''dd-Mon-yyyy'') as INVOICE_CREATION_DATE,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
PCM.PURCHASE_SALES as SALES_PURCHASE,
?,
INVS.VAT_PARENT_REF_NO as VAT_PARENT_REF_NO
from
IS_INVOICE_SUMMARY invs,
IVD_INVOICE_VAT_DETAILS ivd,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd
where
INVS.INTERNAL_INVOICE_REF_NO = IVD.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCI.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCI.QUALITY_ID = QAT.QUALITY_ID
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by 
INVS.INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO,
PCI.TERMS,
PCM.ISSUE_DATE,
PHD.COMPANYNAME,
PCPD.QTY_MAX_VAL,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
INVS.INVOICE_CREATED_DATE,
INVS.INVOICE_REF_NO,
PCM.CONTRACT_TYPE,
INVS.INVOICE_STATUS,
PCM.PURCHASE_SALES,
INVS.VAT_PARENT_REF_NO', 'N');


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-API-1', 'CREATE_API', 'Advance Payment Invoice',
             'CREATE_API', 1,
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
and INVS.CREDIT_TERM = PYM.PAYMENT_TERM_ID
and APID.INVOICE_ITEM_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID(+)
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
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
QUM.QTY_UNIT',
             'N'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-API-4', 'CREATE_API', 'Advance Payment Invoice',
             'CREATE_API', 4,
             'INSERT INTO ITD_D (
INTERNAL_INVOICE_REF_NO,
OTHER_CHARGE_COST_NAME,
TAX_RATE,
INVOICE_CURRENCY,
FX_RATE,
AMOUNT,
TAX_CURRENCY,
INVOICE_AMOUNT,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
TM.TAX_CODE as OTHER_CHARGE_COST_NAME,
ITD.TAX_RATE as TAX_RATE,
CM.CUR_CODE as INVOICE_CURRENCY,
ITD.TAX_AMOUNT_FX_RATE as FX_RATE,
ITD.TAX_AMOUNT as AMOUNT,
CM_TAX.CUR_CODE as TAX_CURRENCY,
ITD.TAX_AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
?
from
IS_INVOICE_SUMMARY invs,
ITD_INVOICE_TAX_DETAILS itd,
TM_TAX_MASTER tm,
CM_CURRENCY_MASTER cm,
CM_CURRENCY_MASTER cm_tax
where
INVS.INTERNAL_INVOICE_REF_NO = ITD.INTERNAL_INVOICE_REF_NO
and ITD.TAX_CODE_ID = TM.TAX_ID
and ITD.INVOICE_CUR_ID = CM.CUR_ID
and ITD.TAX_AMOUNT_CUR_ID = CM_TAX.CUR_ID
and ITD.INTERNAL_INVOICE_REF_NO = ?',
             'N'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-API-5', 'CREATE_API', 'Advance Payment Invoice',
             'CREATE_API', 5,
             'INSERT into IOC_D (
    INTERNAL_INVOICE_REF_NO,
    OTHER_CHARGE_COST_NAME,
    CHARGE_TYPE,
    FX_RATE,
    QUANTITY,
    AMOUNT,
    INVOICE_AMOUNT,
    INVOICE_CUR_NAME,
    RATE_PRICE_UNIT_NAME,
    CHARGE_AMOUNT_RATE,
    QUANTITY_UNIT,
    AMOUNT_UNIT,
    INTERNAL_DOC_REF_NO
    )
    select 
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    SCM.COST_DISPLAY_NAME as OTHER_CHARGE_COST_NAME,
    IOC.CHARGE_TYPE as CHARGE_TYPE,
    nvl(IOC.RATE_FX_RATE, IOC.FLAT_AMOUNT_FX_RATE) as FX_RATE,
    IOC.QUANTITY as QUANTITY,
    nvl(IOC.RATE_AMOUNT, IOC.FLAT_AMOUNT) as AMOUNT,
    IOC.AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
    CM.CUR_CODE as INVOICE_CUR_NAME,
    PUM.PRICE_UNIT_NAME as RATE_PRICE_UNIT_NAME,
    nvl(IOC.FLAT_AMOUNT, IOC.RATE_CHARGE) as CHARGE_AMOUNT_RATE,
    QUM.QTY_UNIT as QUANTITY_UNIT,
    CM_IOC.CUR_CODE as AMOUNT_UNIT,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IOC_INVOICE_OTHER_CHARGE ioc,
    CM_CURRENCY_MASTER cm,
    SCM_SERVICE_CHARGE_MASTER scm,
    PPU_PRODUCT_PRICE_UNITS ppu,
    PUM_PRICE_UNIT_MASTER pum,
    QUM_QUANTITY_UNIT_MASTER qum,
    CM_CURRENCY_MASTER cm_ioc
    where
    INVS.INTERNAL_INVOICE_REF_NO = IOC.INTERNAL_INVOICE_REF_NO
    and IOC.OTHER_CHARGE_COST_ID = SCM.COST_ID
    and IOC.INVOICE_CUR_ID = CM.CUR_ID
    and IOC.RATE_PRICE_UNIT = PPU.INTERNAL_PRICE_UNIT_ID(+)
    and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
    and IOC.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
    and IOC.FLAT_AMOUNT_CUR_UNIT_ID = CM_IOC.CUR_ID(+)
    and IOC.INTERNAL_INVOICE_REF_NO = ?',
             'N'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-1', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             1,
             'INSERT into PFI_D(
INTERNAL_INVOICE_REF_NO,
INVOICE_REF_NO,
CP_NAME,
INCO_TERM_LOCATION,
INVOICE_QUANTITY,
INVOICE_QUANTITY_UNIT,
INVOICE_AMOUNT,
INVOICE_AMOUNT_UNIT,
PAYMENT_TERM,
CP_ITEM_STOCK_REF_NO,
SELF_ITEM_STOCK_REF_NO,
DOCUMENT_DATE,
INTERNAL_COMMENTS,
PRODUCT,
QUALITY,
NOTIFY_PARTY,
INVOICE_ISSUE_DATE,
ORIGIN,
DOC_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
TOTAL_TAX_AMOUNT,
TOTAL_OTHER_CHARGE_AMOUNT,
INTERNAL_DOC_REF_NO
)
select INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PHD.COMPANYNAME as CP_NAME, PCI.TERMS as INCO_TERM_LOCATION, 
sum(PFID.INVOICED_QTY) as INVOICE_QUANTITY,
QUM.QTY_UNIT as INVOICE_QUANTITY_UNIT,
sum(PFID.INVOICE_ITEM_AMOUNT) as INVOICE_AMOUNT,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
PYM.PAYMENT_TERM as PAYMENT_TERM,
INVS.CP_REF_NO as CP_ITEM_STOCK_REF_NO,
'''' as SELF_ITEM_STOCK_REF_NO,
TO_CHAR(INVS.INVOICE_ISSUE_DATE,''dd-Mon-yyyy'') as DOCUMENT_DATE,
INVS.INTERNAL_COMMENTS as INTERNAL_COMMENTS,
PDM.PRODUCT_DESC as PRODUCT,
QAT.QUALITY_NAME as QUALITY,
'''' as NOTIFY_PARTY,
TO_CHAR(INVS.INVOICE_ISSUE_DATE,''dd-Mon-yyyy'') as INVOICE_ISSUE_DATE,
'''' as ORIGIN,
'''' as DOC_REF_NO,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
invs.INVOICE_STATUS as INVOICE_STATUS,
PCM.PURCHASE_SALES as SALES_PURCHASE,
INVS.TOTAL_TAX_AMOUNT as TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as TOTAL_OTHER_CHARGE_AMOUNT,
?
from
PFID_PROFOMA_INVOICE_DETAILS pfid,
IS_INVOICE_SUMMARY invs,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PCPD_PC_PRODUCT_DEFINITION pcpd,
PYM_PAYMENT_TERMS_MASTER pym,
CM_CURRENCY_MASTER cm,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
QUM_QUANTITY_UNIT_MASTER qum
where
INVS.INTERNAL_INVOICE_REF_NO = PFID.INTERNAL_INVOICE_REF_NO
and PFID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = INVS.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCI.QUALITY_ID = QAT.QUALITY_ID
and PCPD.INPUT_OUTPUT = ''Input''
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INVOICE_CUR_ID = CM.CUR_ID
and INVS.CREDIT_TERM = PYM.PAYMENT_TERM_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INTERNAL_INVOICE_REF_NO,
INVS.INVOICE_REF_NO,
PFID.INVOICED_QTY,
PYM.PAYMENT_TERM,
PCI.TERMS,
PHD.COMPANYNAME,
INVS.CP_REF_NO,
INVS.INVOICE_ISSUE_DATE,
INVS.INTERNAL_COMMENTS,
PFID.INVOICE_ITEM_AMOUNT,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
PCM.CONTRACT_TYPE,
PCM.PURCHASE_SALES,
INVS.INVOICE_STATUS,
INVS.TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
CM.CUR_CODE,
QUM.QTY_UNIT',
             'N'
            );





INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-3', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             3,
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
      AND invs.internal_invoice_ref_no = ?',
             'N'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-4', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             4,
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
      AND invs.internal_invoice_ref_no = ?',
             'N'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-5', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             5,
             'INSERT INTO ITD_D (
INTERNAL_INVOICE_REF_NO,
OTHER_CHARGE_COST_NAME,
TAX_RATE,
INVOICE_CURRENCY,
FX_RATE,
AMOUNT,
TAX_CURRENCY,
INVOICE_AMOUNT,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
TM.TAX_CODE as OTHER_CHARGE_COST_NAME,
ITD.TAX_RATE as TAX_RATE,
CM.CUR_CODE as INVOICE_CURRENCY,
ITD.TAX_AMOUNT_FX_RATE as FX_RATE,
ITD.TAX_AMOUNT as AMOUNT,
CM_TAX.CUR_CODE as TAX_CURRENCY,
ITD.TAX_AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
?
from
IS_INVOICE_SUMMARY invs,
ITD_INVOICE_TAX_DETAILS itd,
TM_TAX_MASTER tm,
CM_CURRENCY_MASTER cm,
CM_CURRENCY_MASTER cm_tax
where
INVS.INTERNAL_INVOICE_REF_NO = ITD.INTERNAL_INVOICE_REF_NO
and ITD.TAX_CODE_ID = TM.TAX_ID
and ITD.INVOICE_CUR_ID = CM.CUR_ID
and ITD.TAX_AMOUNT_CUR_ID = CM_TAX.CUR_ID
and ITD.INTERNAL_INVOICE_REF_NO = ?',
             'N'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-6', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             6,
             'INSERT into IOC_D (
    INTERNAL_INVOICE_REF_NO,
    OTHER_CHARGE_COST_NAME,
    CHARGE_TYPE,
    FX_RATE,
    QUANTITY,
    AMOUNT,
    INVOICE_AMOUNT,
    INVOICE_CUR_NAME,
    RATE_PRICE_UNIT_NAME,
    CHARGE_AMOUNT_RATE,
    QUANTITY_UNIT,
    AMOUNT_UNIT,
    INTERNAL_DOC_REF_NO
    )
    select 
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    SCM.COST_DISPLAY_NAME as OTHER_CHARGE_COST_NAME,
    IOC.CHARGE_TYPE as CHARGE_TYPE,
    nvl(IOC.RATE_FX_RATE, IOC.FLAT_AMOUNT_FX_RATE) as FX_RATE,
    IOC.QUANTITY as QUANTITY,
    nvl(IOC.RATE_AMOUNT, IOC.FLAT_AMOUNT) as AMOUNT,
    IOC.AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
    CM.CUR_CODE as INVOICE_CUR_NAME,
    PUM.PRICE_UNIT_NAME as RATE_PRICE_UNIT_NAME,
    nvl(IOC.FLAT_AMOUNT, IOC.RATE_CHARGE) as CHARGE_AMOUNT_RATE,
    QUM.QTY_UNIT as QUANTITY_UNIT,
    CM_IOC.CUR_CODE as AMOUNT_UNIT,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IOC_INVOICE_OTHER_CHARGE ioc,
    CM_CURRENCY_MASTER cm,
    SCM_SERVICE_CHARGE_MASTER scm,
    PPU_PRODUCT_PRICE_UNITS ppu,
    PUM_PRICE_UNIT_MASTER pum,
    QUM_QUANTITY_UNIT_MASTER qum,
    CM_CURRENCY_MASTER cm_ioc
    where
    INVS.INTERNAL_INVOICE_REF_NO = IOC.INTERNAL_INVOICE_REF_NO
    and IOC.OTHER_CHARGE_COST_ID = SCM.COST_ID
    and IOC.INVOICE_CUR_ID = CM.CUR_ID
    and IOC.RATE_PRICE_UNIT = PPU.INTERNAL_PRICE_UNIT_ID(+)
    and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
    and IOC.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
    and IOC.FLAT_AMOUNT_CUR_UNIT_ID = CM_IOC.CUR_ID(+)
    and IOC.INTERNAL_INVOICE_REF_NO = ?',
             'N'
            );



INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-API-1-CONC', 'CREATE_API', 'Advance Payment Invoice',
             'CREATE_API', 1,
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
and INVS.CREDIT_TERM = PYM.PAYMENT_TERM_ID
and APID.INVOICE_ITEM_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID(+)
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
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
QUM.QTY_UNIT',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-API-2-CONC', 'CREATE_API', 'Advance Payment Invoice',
             'CREATE_API', 2,
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
      AND invs.internal_invoice_ref_no = ?',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-API-3-CONC', 'CREATE_API', 'Advance Payment Invoice',
             'CREATE_API', 3,
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
      AND invs.internal_invoice_ref_no = ?',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-API-4-CONC', 'CREATE_API', 'Advance Payment Invoice',
             'CREATE_API', 4,
             'INSERT INTO ITD_D (
INTERNAL_INVOICE_REF_NO,
OTHER_CHARGE_COST_NAME,
TAX_RATE,
INVOICE_CURRENCY,
FX_RATE,
AMOUNT,
TAX_CURRENCY,
INVOICE_AMOUNT,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
TM.TAX_CODE as OTHER_CHARGE_COST_NAME,
ITD.TAX_RATE as TAX_RATE,
CM.CUR_CODE as INVOICE_CURRENCY,
ITD.TAX_AMOUNT_FX_RATE as FX_RATE,
ITD.TAX_AMOUNT as AMOUNT,
CM_TAX.CUR_CODE as TAX_CURRENCY,
ITD.TAX_AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
?
from
IS_INVOICE_SUMMARY invs,
ITD_INVOICE_TAX_DETAILS itd,
TM_TAX_MASTER tm,
CM_CURRENCY_MASTER cm,
CM_CURRENCY_MASTER cm_tax
where
INVS.INTERNAL_INVOICE_REF_NO = ITD.INTERNAL_INVOICE_REF_NO
and ITD.TAX_CODE_ID = TM.TAX_ID
and ITD.INVOICE_CUR_ID = CM.CUR_ID
and ITD.TAX_AMOUNT_CUR_ID = CM_TAX.CUR_ID
and ITD.INTERNAL_INVOICE_REF_NO = ?',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-API-5-CONC', 'CREATE_API', 'Advance Payment Invoice',
             'CREATE_API', 5,
             'INSERT into IOC_D (
    INTERNAL_INVOICE_REF_NO,
    OTHER_CHARGE_COST_NAME,
    CHARGE_TYPE,
    FX_RATE,
    QUANTITY,
    AMOUNT,
    INVOICE_AMOUNT,
    INVOICE_CUR_NAME,
    RATE_PRICE_UNIT_NAME,
    CHARGE_AMOUNT_RATE,
    QUANTITY_UNIT,
    AMOUNT_UNIT,
    INTERNAL_DOC_REF_NO
    )
    select 
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    SCM.COST_DISPLAY_NAME as OTHER_CHARGE_COST_NAME,
    IOC.CHARGE_TYPE as CHARGE_TYPE,
    nvl(IOC.RATE_FX_RATE, IOC.FLAT_AMOUNT_FX_RATE) as FX_RATE,
    IOC.QUANTITY as QUANTITY,
    nvl(IOC.RATE_AMOUNT, IOC.FLAT_AMOUNT) as AMOUNT,
    IOC.AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
    CM.CUR_CODE as INVOICE_CUR_NAME,
    PUM.PRICE_UNIT_NAME as RATE_PRICE_UNIT_NAME,
    nvl(IOC.FLAT_AMOUNT, IOC.RATE_CHARGE) as CHARGE_AMOUNT_RATE,
    QUM.QTY_UNIT as QUANTITY_UNIT,
    CM_IOC.CUR_CODE as AMOUNT_UNIT,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IOC_INVOICE_OTHER_CHARGE ioc,
    CM_CURRENCY_MASTER cm,
    SCM_SERVICE_CHARGE_MASTER scm,
    PPU_PRODUCT_PRICE_UNITS ppu,
    PUM_PRICE_UNIT_MASTER pum,
    QUM_QUANTITY_UNIT_MASTER qum,
    CM_CURRENCY_MASTER cm_ioc
    where
    INVS.INTERNAL_INVOICE_REF_NO = IOC.INTERNAL_INVOICE_REF_NO
    and IOC.OTHER_CHARGE_COST_ID = SCM.COST_ID
    and IOC.INVOICE_CUR_ID = CM.CUR_ID
    and IOC.RATE_PRICE_UNIT = PPU.INTERNAL_PRICE_UNIT_ID(+)
    and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
    and IOC.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
    and IOC.FLAT_AMOUNT_CUR_UNIT_ID = CM_IOC.CUR_ID(+)
    and IOC.INTERNAL_INVOICE_REF_NO = ?',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-1-CONC', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             1,
             'INSERT into PFI_D(
INTERNAL_INVOICE_REF_NO,
INVOICE_REF_NO,
CP_NAME,
INCO_TERM_LOCATION,
INVOICE_QUANTITY,
INVOICE_QUANTITY_UNIT,
INVOICE_AMOUNT,
INVOICE_AMOUNT_UNIT,
PAYMENT_TERM,
CP_ITEM_STOCK_REF_NO,
SELF_ITEM_STOCK_REF_NO,
DOCUMENT_DATE,
INTERNAL_COMMENTS,
PRODUCT,
QUALITY,
NOTIFY_PARTY,
INVOICE_ISSUE_DATE,
ORIGIN,
DOC_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
TOTAL_TAX_AMOUNT,
TOTAL_OTHER_CHARGE_AMOUNT,
INTERNAL_DOC_REF_NO
)
select INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PHD.COMPANYNAME as CP_NAME, PCI.TERMS as INCO_TERM_LOCATION, 
sum(PFID.INVOICED_QTY) as INVOICE_QUANTITY,
QUM.QTY_UNIT as INVOICE_QUANTITY_UNIT,
sum(PFID.INVOICE_ITEM_AMOUNT) as INVOICE_AMOUNT,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
PYM.PAYMENT_TERM as PAYMENT_TERM,
INVS.CP_REF_NO as CP_ITEM_STOCK_REF_NO,
'''' as SELF_ITEM_STOCK_REF_NO,
TO_CHAR(INVS.INVOICE_ISSUE_DATE,''dd-Mon-yyyy'') as DOCUMENT_DATE,
INVS.INTERNAL_COMMENTS as INTERNAL_COMMENTS,
PDM.PRODUCT_DESC as PRODUCT,
QAT.QUALITY_NAME as QUALITY,
'''' as NOTIFY_PARTY,
TO_CHAR(INVS.INVOICE_ISSUE_DATE,''dd-Mon-yyyy'') as INVOICE_ISSUE_DATE,
'''' as ORIGIN,
'''' as DOC_REF_NO,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
invs.INVOICE_STATUS as INVOICE_STATUS,
PCM.PURCHASE_SALES as SALES_PURCHASE,
INVS.TOTAL_TAX_AMOUNT as TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as TOTAL_OTHER_CHARGE_AMOUNT,
?
from
PFID_PROFOMA_INVOICE_DETAILS pfid,
IS_INVOICE_SUMMARY invs,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PCPD_PC_PRODUCT_DEFINITION pcpd,
PYM_PAYMENT_TERMS_MASTER pym,
CM_CURRENCY_MASTER cm,
QAT_QUALITY_ATTRIBUTES qat,
PDM_PRODUCTMASTER pdm,
QUM_QUANTITY_UNIT_MASTER qum
where
INVS.INTERNAL_INVOICE_REF_NO = PFID.INTERNAL_INVOICE_REF_NO
and PFID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = INVS.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCI.QUALITY_ID = QAT.QUALITY_ID
and PCPD.INPUT_OUTPUT = ''Input''
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INVOICE_CUR_ID = CM.CUR_ID
and INVS.CREDIT_TERM = PYM.PAYMENT_TERM_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
INVS.INTERNAL_INVOICE_REF_NO,
INVS.INVOICE_REF_NO,
PFID.INVOICED_QTY,
PYM.PAYMENT_TERM,
PCI.TERMS,
PHD.COMPANYNAME,
INVS.CP_REF_NO,
INVS.INVOICE_ISSUE_DATE,
INVS.INTERNAL_COMMENTS,
PFID.INVOICE_ITEM_AMOUNT,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
PCM.CONTRACT_TYPE,
PCM.PURCHASE_SALES,
INVS.INVOICE_STATUS,
INVS.TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
CM.CUR_CODE,
QUM.QTY_UNIT',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-2-CONC', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             2,
             'INSERT INTO PFI_CHILD_D
            (INTERNAL_INVOICE_REF_NO, STOCK_REF_NO, CONTRACT_ITEM_REF_NO, QUANTITY,
             QUANTITY_UNIT, PRICE, PRICE_UNIT, AMOUNT, AMOUNT_UNIT, IS_FROM, INTERNAL_DOC_REF_NO)
   select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
'''' as  STOCK_REF_NO,
PCI.CONTRACT_ITEM_REF_NO as CONTRACT_ITEM_REF_NO,
PFID.INVOICED_QTY as QUANTITY,
QUM.QTY_UNIT as QUANTITY_UNIT,
PFID.NEW_INVOICE_PRICE as PRICE,
PUM.PRICE_UNIT_NAME as PRICE_UNIT,
PFID.INVOICE_ITEM_AMOUNT as AMOUNT,
CM.CUR_CODE as AMOUNT_UNIT,
'''' as IS_FROM,
?
from
PFID_PROFOMA_INVOICE_DETAILS pfid,
IS_INVOICE_SUMMARY invs,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
CM_CURRENCY_MASTER cm,
PPU_PRODUCT_PRICE_UNITS ppu,
PUM_PRICE_UNIT_MASTER pum,
QUM_QUANTITY_UNIT_MASTER qum
where
INVS.INTERNAL_INVOICE_REF_NO = PFID.INTERNAL_INVOICE_REF_NO
and PFID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PFID.INVOICE_CURRENCY_ID = CM.CUR_ID
and PFID.NEW_INVOICE_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
and PFID.INVOICED_QTY_UNIT_ID = QUM.QTY_UNIT_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-3-CONC', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             3,
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
      AND invs.internal_invoice_ref_no = ?',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-4-CONC', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             4,
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
      AND invs.internal_invoice_ref_no = ?',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-5-CONC', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             5,
             'INSERT INTO ITD_D (
INTERNAL_INVOICE_REF_NO,
OTHER_CHARGE_COST_NAME,
TAX_RATE,
INVOICE_CURRENCY,
FX_RATE,
AMOUNT,
TAX_CURRENCY,
INVOICE_AMOUNT,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
TM.TAX_CODE as OTHER_CHARGE_COST_NAME,
ITD.TAX_RATE as TAX_RATE,
CM.CUR_CODE as INVOICE_CURRENCY,
ITD.TAX_AMOUNT_FX_RATE as FX_RATE,
ITD.TAX_AMOUNT as AMOUNT,
CM_TAX.CUR_CODE as TAX_CURRENCY,
ITD.TAX_AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
?
from
IS_INVOICE_SUMMARY invs,
ITD_INVOICE_TAX_DETAILS itd,
TM_TAX_MASTER tm,
CM_CURRENCY_MASTER cm,
CM_CURRENCY_MASTER cm_tax
where
INVS.INTERNAL_INVOICE_REF_NO = ITD.INTERNAL_INVOICE_REF_NO
and ITD.TAX_CODE_ID = TM.TAX_ID
and ITD.INVOICE_CUR_ID = CM.CUR_ID
and ITD.TAX_AMOUNT_CUR_ID = CM_TAX.CUR_ID
and ITD.INTERNAL_INVOICE_REF_NO = ?',
             'Y'
            );


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM-PFI-6-CONC', 'CREATE_PFI', 'Profoma Invoice', 'CREATE_PFI',
             6,
             'INSERT into IOC_D (
    INTERNAL_INVOICE_REF_NO,
    OTHER_CHARGE_COST_NAME,
    CHARGE_TYPE,
    FX_RATE,
    QUANTITY,
    AMOUNT,
    INVOICE_AMOUNT,
    INVOICE_CUR_NAME,
    RATE_PRICE_UNIT_NAME,
    CHARGE_AMOUNT_RATE,
    QUANTITY_UNIT,
    AMOUNT_UNIT,
    INTERNAL_DOC_REF_NO
    )
    select 
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    SCM.COST_DISPLAY_NAME as OTHER_CHARGE_COST_NAME,
    IOC.CHARGE_TYPE as CHARGE_TYPE,
    nvl(IOC.RATE_FX_RATE, IOC.FLAT_AMOUNT_FX_RATE) as FX_RATE,
    IOC.QUANTITY as QUANTITY,
    nvl(IOC.RATE_AMOUNT, IOC.FLAT_AMOUNT) as AMOUNT,
    IOC.AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
    CM.CUR_CODE as INVOICE_CUR_NAME,
    PUM.PRICE_UNIT_NAME as RATE_PRICE_UNIT_NAME,
    nvl(IOC.FLAT_AMOUNT, IOC.RATE_CHARGE) as CHARGE_AMOUNT_RATE,
    QUM.QTY_UNIT as QUANTITY_UNIT,
    CM_IOC.CUR_CODE as AMOUNT_UNIT,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IOC_INVOICE_OTHER_CHARGE ioc,
    CM_CURRENCY_MASTER cm,
    SCM_SERVICE_CHARGE_MASTER scm,
    PPU_PRODUCT_PRICE_UNITS ppu,
    PUM_PRICE_UNIT_MASTER pum,
    QUM_QUANTITY_UNIT_MASTER qum,
    CM_CURRENCY_MASTER cm_ioc
    where
    INVS.INTERNAL_INVOICE_REF_NO = IOC.INTERNAL_INVOICE_REF_NO
    and IOC.OTHER_CHARGE_COST_ID = SCM.COST_ID
    and IOC.INVOICE_CUR_ID = CM.CUR_ID
    and IOC.RATE_PRICE_UNIT = PPU.INTERNAL_PRICE_UNIT_ID(+)
    and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
    and IOC.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
    and IOC.FLAT_AMOUNT_CUR_UNIT_ID = CM_IOC.CUR_ID(+)
    and IOC.INTERNAL_INVOICE_REF_NO = ?',
             'Y'
            );


update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY ='INSERT INTO ITD_D (
INTERNAL_INVOICE_REF_NO,
OTHER_CHARGE_COST_NAME,
TAX_RATE,
INVOICE_CURRENCY,
FX_RATE,
AMOUNT,
TAX_CURRENCY,
INVOICE_AMOUNT,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
TM.TAX_CODE as OTHER_CHARGE_COST_NAME,
ITD.TAX_RATE as TAX_RATE,
CM.CUR_CODE as INVOICE_CURRENCY,
ITD.TAX_AMOUNT_FX_RATE as FX_RATE,
ITD.TAX_AMOUNT as AMOUNT,
CM_TAX.CUR_CODE as TAX_CURRENCY,
ITD.TAX_AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
?
from
IS_INVOICE_SUMMARY invs,
ITD_INVOICE_TAX_DETAILS itd,
TM_TAX_MASTER tm,
CM_CURRENCY_MASTER cm,
CM_CURRENCY_MASTER cm_tax
where
INVS.INTERNAL_INVOICE_REF_NO = ITD.INTERNAL_INVOICE_REF_NO
and ITD.TAX_CODE_ID = TM.TAX_ID
and ITD.INVOICE_CUR_ID = CM.CUR_ID
and ITD.TAX_AMOUNT_CUR_ID = CM_TAX.CUR_ID
and ITD.INTERNAL_INVOICE_REF_NO = ?'
where DGM.DGM_ID in ('DGM-ITD_BM','DGM-ITD_C','DGM-DFI-C6');
