
DECLARE
   fetchqry_vat_d_conc   CLOB
      := 'INSERT INTO vat_d
            (internal_invoice_ref_no, contract_ref_no, cp_contract_ref_no,
             inco_term_location, contract_date, cp_name, seller,
             contract_quantity, contract_tolerance, product, quality,
             notify_party, invoice_creation_date, invoice_due_date,
             invoice_ref_no, contract_type, invoice_status, sales_purchase,
             internal_doc_ref_no, vat_parent_ref_no, is_self_billing,
             our_person_incharge, smelter_location, senders_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            NVL (pcm.contract_ref_no, '''') AS contract_ref_no,
            NVL (pcm.cp_contract_ref_no, '''') AS cp_contract_ref_no,
            NVL (pym.payment_term, '''') AS inco_term_location,
            NVL (TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy''),
                 '''') AS contract_date, phd.companyname AS cp_name,
            '''' AS seller, NVL (pcpd.qty_max_val, '''') AS contract_quantity,
            '''' AS contract_tolerance, NVL (pdm.product_desc, '''') AS product,
            NVL (qat.quality_name, '''') AS quality, '''' AS notify_party,
            TO_CHAR (invs.invoice_created_date,
                     ''dd-Mon-yyyy''
                    ) AS invoice_creation_date,
            TO_CHAR (invs.payment_due_date,
                     ''dd-Mon-yyyy'') AS invoice_due_date,
            invs.invoice_ref_no AS invoice_ref_no,
            NVL (pcm.contract_type, '''') AS contract_type,
            invs.invoice_status AS invoice_status,
            NVL (pcm.purchase_sales, '''') AS sales_purchase, ?,
            invs.vat_parent_ref_no AS vat_parent_ref_no,
            pcm.is_self_billing AS is_self_billing,
            (gab.firstname || '' '' || gab.lastname) AS our_person_incharge,
            F_STRING_AGGREGATE (phd_ware.companyname) AS warehouse, gmr.senders_ref_no
       FROM is_invoice_summary invs,
            ivd_invoice_vat_details ivd,
            pcm_physical_contract_main pcm,
            v_pci pci,
            phd_profileheaderdetails phd,
            pdm_productmaster pdm,
            pym_payment_terms_master pym,
            qat_quality_attributes qat,
            pcpd_pc_product_definition pcpd,
            iam_invoice_action_mapping iam,
            axs_action_summary axs,
            ak_corporate_user akuser,
            gab_globaladdressbook gab,
            vpcm_vat_parent_child_map vpcm,
            gmr_goods_movement_record gmr,
            iid_invoicable_item_details iid,
            phd_profileheaderdetails phd_ware
      WHERE invs.internal_invoice_ref_no = ivd.internal_invoice_ref_no
        AND invs.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND pcpd.internal_contract_ref_no(+) = pcm.internal_contract_ref_no
        AND pcpd.product_id = pdm.product_id(+)
        AND NVL (pcpd.input_output, ''Input'') = ''Input''
        AND pci.internal_contract_ref_no(+) = pcm.internal_contract_ref_no
        AND pci.quality_id = qat.quality_id(+)
        AND invs.cp_id = phd.profileid(+)
        AND invs.credit_term = pym.payment_term_id
        AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
        AND iam.invoice_action_ref_no = axs.internal_action_ref_no
        AND axs.action_id != ''MODIFY_INVOICE''
        AND axs.created_by = akuser.user_id
        AND akuser.gabid = gab.gabid
        AND ivd.internal_invoice_ref_no = vpcm.vat_internal_invoice_ref_no(+)
        AND vpcm.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
        AND gmr.warehouse_profile_id = phd_ware.profileid(+)
        AND invs.internal_invoice_ref_no = ?
   GROUP BY invs.internal_invoice_ref_no,
            pcm.contract_ref_no,
            pcm.cp_contract_ref_no,
            pym.payment_term,
            pcm.issue_date,
            phd.companyname,
            pcpd.qty_max_val,
            pdm.product_desc,
            qat.quality_name,
            invs.invoice_created_date,
            invs.payment_due_date,
            invs.invoice_ref_no,
            pcm.contract_type,
            invs.invoice_status,
            pcm.purchase_sales,
            invs.vat_parent_ref_no,
            pcm.is_self_billing,
            gmr.senders_ref_no,
            gab.firstname,
            gab.lastname';
   fetchqry_vat_d        CLOB
      := 'INSERT INTO VAT_D (
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
our_person_incharge,
senders_ref_no
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
(GAB.FIRSTNAME||'' ''||GAB.LASTNAME) as our_person_incharge, gmr.senders_ref_no
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
gmr.senders_ref_no,
GAB.FIRSTNAME,
GAB.LASTNAME';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry_vat_d_conc
    WHERE dgm.dgm_id = 'DGM-VAT-1-CONC'
      AND dgm.doc_id = 'CREATE_VAT'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry_vat_d
    WHERE dgm.dgm_id = 'DGM-VAT-1'
      AND dgm.doc_id = 'CREATE_VAT'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   COMMIT;
END;