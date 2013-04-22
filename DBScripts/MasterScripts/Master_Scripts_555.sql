declare
fetchQryISDOCI CLOB := 'INSERT INTO IS_D(
INTERNAL_INVOICE_REF_NO,
INVOICE_REF_NO,
CP_NAME,
SUPPLIRE_INVOICE_NO,
CP_ADDRESS,
INVOICE_CREATION_DATE,
DUE_DATE,
PAYMENT_TERM,
CONTRACT_TYPE,
internal_comments, invoice_status,invoice_amount, adjustment_amount, invoice_amount_unit, our_person_incharge, internal_doc_ref_no
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PHD.COMPANYNAME as CP_NAME,
INVS.CP_REF_NO as SUPPLIRE_INVOICE_NO,
INVS.BILL_TO_ADDRESS as CP_ADDRESS,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
PYM.PAYMENT_TERM as PAYMENT_TERM,
INVS.RECIEVED_RAISED_TYPE as CONTRACT_TYPE, INVS.INTERNAL_COMMENTS as internal_comments, INVS.INVOICE_STATUS as invoice_status, INVS.TOTAL_AMOUNT_TO_PAY as invoice_amount,
invs.invoice_adjustment_amount As adjustment_amount, cm.cur_code AS invoice_amount_unit, (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) as our_person_incharge, ?
from
IS_INVOICE_SUMMARY invs,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
CM_CURRENCY_MASTER cm,
IAM_INVOICE_ACTION_MAPPING iam,
AXS_ACTION_SUMMARY axs,
AK_CORPORATE_USER akuser,
GAB_GLOBALADDRESSBOOK gab
where
INVS.CP_ID = PHD.PROFILEID
AND INVS.INVOICE_CUR_ID = CM.CUR_ID
and PYM.PAYMENT_TERM_ID = INVS.CREDIT_TERM 
And INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
AND AXS.CREATED_BY = AKUSER.USER_ID
AND AKUSER.GABID = GAB.GABID
and INVS.INTERNAL_INVOICE_REF_NO = ?';

fetchQryISDCFI CLOB :=
'INSERT INTO IS_D(
INVOICE_REF_NO,
INVOICE_TYPE_NAME,
INVOICE_CREATION_DATE,
INVOICE_QUANTITY,
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
IS_FREE_METAL,
IS_PLEDGE,
INTERNAL_COMMENTS,
IS_SELF_BILLING,
our_person_incharge,
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
INVS.AMOUNT_TO_PAY_BEFORE_ADJ as MATERIAL_COST,
INVS.TOTAL_OTHER_CHARGE_AMOUNT as ADDDITIONAL_CHARGES,
INVS.TOTAL_TAX_AMOUNT as TAXES,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
INVS.CP_REF_NO as SUPPLIER_INVOICE_NO,
PCM.ISSUE_DATE as CONTRACT_DATE,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
sum(II.INVOICABLE_QTY) as STOCK_QUANTITY,
stragg(distinct II.STOCK_REF_NO) as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
stragg(distinct GMR.GMR_REF_NO) as GMR_REF_NO,
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
INVS.IS_FREE_METAL as IS_FREE_METAL,
INVS.IS_PLEDGE as IS_PLEDGE,
INVS.INTERNAL_COMMENTS as INTERNAL_COMMENTS, pcm.is_self_billing as SELF_BILLING, (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) as our_person_incharge,
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
GAB_GLOBALADDRESSBOOK gab,
IAM_INVOICE_ACTION_MAPPING iam,
AXS_ACTION_SUMMARY axs,
AK_CORPORATE_USER akuser
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO
and IID.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and IID.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and IID.INVOICABLE_ITEM_ID = II.INVOICABLE_ITEM_ID
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INVOICE_CURRENCY_ID = CM.CUR_ID
and II.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCPD.PCPD_ID = PCPQ.PCPD_ID
and PCI.QUALITY_ID = QAT.QUALITY_ID
and PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and INVS.CP_ID = PHD.PROFILEID
and INVS.CREDIT_TERM = PYM.PAYMENT_TERM_ID
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
and INVS.INVOICED_QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED(+) = ''N''
and PAD.ADDRESS_TYPE(+) = ''Billing''
and INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
and IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
and AXS.CREATED_BY = AKUSER.USER_ID
and AKUSER.GABID = GAB.GABID
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
INVS.IS_FREE_METAL,
INVS.IS_PLEDGE,
pcm.IS_SELF_BILLING,
INVS.INTERNAL_COMMENTS,
GAB.FIRSTNAME,
GAB.LASTNAME';

fetchQryVAT CLOB :=
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
VAT_PARENT_REF_NO,
IS_SELF_BILLING,
our_person_incharge
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
INVS.VAT_PARENT_REF_NO as VAT_PARENT_REF_NO,
PCM.IS_SELF_BILLING as IS_SELF_BILLING,
(GAB.FIRSTNAME||'' ''||GAB.LASTNAME) as our_person_incharge
from
IS_INVOICE_SUMMARY invs,
IVD_INVOICE_VAT_DETAILS ivd,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
PYM_PAYMENT_TERMS_MASTER pym,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd,
IAM_INVOICE_ACTION_MAPPING iam,
AXS_ACTION_SUMMARY axs,
AK_CORPORATE_USER akuser,
GAB_GLOBALADDRESSBOOK gab
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
and INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
and AXS.CREATED_BY = AKUSER.USER_ID
and AKUSER.GABID = GAB.GABID
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
INVS.VAT_PARENT_REF_NO,
PCM.IS_SELF_BILLING,
GAB.FIRSTNAME,
GAB.LASTNAME';

fetchQryPFI CLOB :=
'INSERT INTO pfi_d
            (internal_invoice_ref_no, invoice_ref_no, cp_name,
             inco_term_location, invoice_quantity, invoice_quantity_unit,
             invoice_amount, invoice_amount_unit, payment_term,
             cp_item_stock_ref_no, self_item_stock_ref_no, document_date,
             internal_comments, product, quality, notify_party,
             invoice_issue_date, origin, contract_type,
             invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, our_person_incharge,
             internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            invs.invoice_ref_no AS invoice_ref_no, phd.companyname AS cp_name,
            stragg (pci.terms) AS inco_term_location,
            SUM (pfid.invoiced_qty) AS invoice_quantity,
            qum.qty_unit AS invoice_quantity_unit,
            SUM (invs.total_amount_to_pay) AS invoice_amount,
            cm.cur_code AS invoice_amount_unit,
            pym.payment_term AS payment_term,
            invs.cp_ref_no AS cp_item_stock_ref_no,
            '''' AS self_item_stock_ref_no,
            TO_CHAR (invs.invoice_issue_date, ''dd-Mon-yyyy'') AS document_date,
            invs.internal_comments AS internal_comments,
            pdm.product_desc AS product, qat.quality_name AS quality,
            '''' AS notify_party,
            TO_CHAR (invs.invoice_issue_date,
                     ''dd-Mon-yyyy''
                    ) AS invoice_issue_date,
            '''' AS origin,
            pcm.contract_type AS contract_type,
            invs.invoice_status AS invoice_status,
            pcm.purchase_sales AS sales_purchase,
            invs.total_tax_amount AS total_tax_amount,
            invs.total_other_charge_amount AS total_other_charge_amount,
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '''') AS our_person_incharge, ?
       FROM pfid_profoma_invoice_details pfid,
            is_invoice_summary invs,
            pcm_physical_contract_main pcm,
            v_pci pci,
            phd_profileheaderdetails phd,
            pcpd_pc_product_definition pcpd,
            pym_payment_terms_master pym,
            cm_currency_master cm,
            qat_quality_attributes qat,
            pdm_productmaster pdm,
            qum_quantity_unit_master qum,
            ak_corporate_user akuser,
            GAB_GLOBALADDRESSBOOK gab,
            IAM_INVOICE_ACTION_MAPPING iam,
            AXS_ACTION_SUMMARY axs
      WHERE invs.internal_invoice_ref_no = pfid.internal_invoice_ref_no
        AND pfid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND pcm.internal_contract_ref_no = invs.internal_contract_ref_no
        AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
       AND pcpd.product_id = pdm.product_id
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pci.quality_id = qat.quality_id
        and INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
        and IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
        and AXS.CREATED_BY = AKUSER.USER_ID
        and AKUSER.GABID = GAB.GABID
        AND pcpd.input_output = ''Input''
        AND pcm.cp_id = phd.profileid(+)
        AND invs.invoice_cur_id = cm.cur_id
        AND invs.credit_term = pym.payment_term_id
        AND invs.internal_invoice_ref_no = ?
   GROUP BY invs.internal_invoice_ref_no,
            invs.invoice_ref_no,
            pym.payment_term,
            phd.companyname,
            invs.cp_ref_no,
            invs.invoice_issue_date,
            invs.internal_comments,
            pdm.product_desc,
            qat.quality_name,
            pcm.contract_type,
            pcm.purchase_sales,
            invs.invoice_status,
            invs.total_tax_amount,
            invs.total_other_charge_amount,
            cm.cur_code,
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            qum.qty_unit';

begin
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryISDOCI where DGM.DOC_ID IN ('CREATE_OCI') and DGM.DGM_ID IN ('DGM_OCI_1') and DGM.SEQUENCE_ORDER = 1;

    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryISDCFI where DGM.DOC_ID IN ('CREATE_CFI') and DGM.DGM_ID IN ('CREATE_CFI') and DGM.SEQUENCE_ORDER = 1;

    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryVAT where DGM.DOC_ID IN ('CREATE_VAT') and DGM.DGM_ID IN ('DGM-VAT-1','DGM-VAT-1-CONC') and DGM.SEQUENCE_ORDER = 1;

    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryPFI where DGM.DOC_ID IN ('CREATE_PFI') and DGM.DGM_ID IN ('DGM-PFI-1-CONC','DGM-PFI-1') and DGM.SEQUENCE_ORDER = 1;
commit;
end;