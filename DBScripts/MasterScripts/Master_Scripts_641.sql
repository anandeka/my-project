

DECLARE
   fetchqueryisdfor_siconc    CLOB
      := 'INSERT INTO IS_D(
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
IS_INV_DRAFT,
adjustment_amount, 
our_person_incharge, 
is_self_billing,
smelter_location,
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
'''' as CONTRACT_DATE,
stragg(PCM.CONTRACT_REF_NO) as CONTRACT_REF_NO,
sum(GMR.QTY) as STOCK_QUANTITY,
'''' as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
stragg(GMR.GMR_REF_NO) as GMR_REF_NO,
sum(GMR.QTY) as GMR_QUALITY,
sum(PCPD.QTY_MAX_VAL) as CONTRACT_QUANTITY,
QUM.QTY_UNIT as CONTRACT_QTY_UNIT,
stragg(PCPD.MAX_TOLERANCE) as CONTRACT_TOLERANCE,
stragg(QAT.QUALITY_NAME) as QUALITY,
stragg(PDM.PRODUCT_DESC) as PRODUCT,
stragg(PCM.CP_CONTRACT_REF_NO) as CP_CONTRACT_REF_NO,
stragg(PYM.PAYMENT_TERM) as PAYMENT_TERM,
sum(GMR.FINAL_WEIGHT) as GMR_FINALIZE_QTY,
stragg(PHD.COMPANYNAME) as CP_NAME,
stragg(PAD.ADDRESS) as CP_ADDRESS,
stragg(CYM.COUNTRY_NAME) as CP_COUNTRY,
stragg(CIM.CITY_NAME) as CP_CITY,
stragg(SM.STATE_NAME) as CP_STATE,
stragg(PAD.ZIP) as CP_ZIP,
stragg(distinct PCM.CONTRACT_TYPE) as CONTRACT_TYPE,
stragg(CYMLOADING.COUNTRY_NAME) as ORIGIN,
stragg(PCI.TERMS) as INCO_TERM_LOCATION,
stragg(nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME)) as NOTIFY_PARTY, 
stragg(distinct PCI.CONTRACT_TYPE) as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
invs.invoice_adjustment_amount As adjustment_amount,
(GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing as is_self_billing, stragg(phd3.companyname) AS smelter_location,
?
from 
IS_INVOICE_SUMMARY invs,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
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
PHD_PROFILEHEADERDETAILS phd3,
QUM_QUANTITY_UNIT_MASTER qum_gmr,
SIGM_SERVICE_INV_GMR_MAPPING SIGM,
GCIM_GMR_CONTRACT_ITEM_MAPPING GCIM,
AK_CORPORATE_USER akuser,
GAB_GLOBALADDRESSBOOK gab,
AXS_ACTION_SUMMARY axs,
IAM_INVOICE_ACTION_MAPPING IAM
where
INVS.INTERNAL_INVOICE_REF_NO = SIGM.INTERNAL_INV_REF_NO
AND SIGM.IS_ACTIVE = ''Y''
AND SIGM.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
AND GMR.INTERNAL_GMR_REF_NO = GCIM.INTERNAL_GMR_REF_NO
and GCIM.INTERNAL_CONTRACT_ITEM_REF_NO = PCI.INTERNAL_CONTRACT_ITEM_REF_NO
and GMR.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and INVS.INVOICE_CUR_ID = CM.CUR_ID
and PCM.INTERNAL_CONTRACT_REF_NO = PCPD.INTERNAL_CONTRACT_REF_NO
and PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
and PCPD.PCPD_ID = PCPQ.PCPD_ID
and PCI.QUALITY_ID = QAT.QUALITY_ID
and PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCM.CP_ID = PHD.PROFILEID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and PHD.PROFILEID = PAD.PROFILE_ID
and PAD.COUNTRY_ID = CYM.COUNTRY_ID
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
AND PAD.ADDRESS_TYPE(+) = ''Billing''
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.CONSIGNEE_ID = PHD1.PROFILEID(+)
and SD.CONSIGNEE_ID = PHD2.PROFILEID(+)
AND gmr.warehouse_profile_id = phd3.profileid(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED = ''N''
AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
AND AXS.ACTION_ID != ''MODIFY_INVOICE''
AND AXS.CREATED_BY = AKUSER.USER_ID
AND AKUSER.GABID = GAB.GABID
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
CM.CUR_CODE,
QUM.QTY_UNIT,
QUM_GMR.QTY_UNIT,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS, 
INVS.IS_INV_DRAFT,
invs.invoice_adjustment_amount,
GAB.FIRSTNAME,
GAB.LASTNAME,
pcm.is_self_billing';
   fetchqueryisdfor_vatconc   CLOB
      := 'INSERT INTO vat_d
            (internal_invoice_ref_no, contract_ref_no, cp_contract_ref_no,
             inco_term_location, contract_date, cp_name, seller,
             contract_quantity, contract_tolerance, product, quality,
             notify_party, invoice_creation_date, invoice_due_date,
             invoice_ref_no, contract_type, invoice_status, sales_purchase,
             internal_doc_ref_no, vat_parent_ref_no, is_self_billing,
             our_person_incharge, smelter_location)
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
            stragg (phd_ware.companyname) AS warehouse
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
            gab.firstname,
            gab.lastname';
   fetchqueryisdfor_dcconc    CLOB
      := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_quantity, invoiced_qty_unit, internal_invoice_ref_no,
             invoice_amount, material_cost, addditional_charges, taxes,
             due_date, supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             our_person_incharge, internal_comments, is_self_billing,
             smelter_location, internal_doc_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            invs.invoiced_qty AS invoice_quantity,
            qum_gmr.qty_unit AS invoiced_qty_unit,
            invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            invs.total_amount_to_pay AS invoice_amount,
            invs.amount_to_pay_before_adj AS material_cost,
            invs.total_other_charge_amount AS addditional_charges,
            invs.total_tax_amount AS taxes, invs.payment_due_date AS due_date,
            invs.cp_ref_no AS supplier_invoice_no,
            pcm.issue_date AS contract_date,
            pcm.contract_ref_no AS contract_ref_no,
            SUM (ii.invoicable_qty) AS stock_quantity,
            stragg (ii.stock_ref_no) AS stock_ref_no,
            cm.cur_code AS invoice_amount_unit, gmr.gmr_ref_no AS gmr_ref_no,
            gmr.qty AS gmr_quality, pcpd.qty_max_val AS contract_quantity,
            qum.qty_unit AS contract_qty_unit,
            pcpd.max_tolerance AS contract_tolerance,
            qat.quality_name AS quality, pdm.product_desc AS product,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            pym.payment_term AS payment_term,
            gmr.final_weight AS gmr_finalize_qty, phd.companyname AS cp_name,
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip, pcm.contract_type AS contract_type,
            cymloading.country_name AS origin,
            pci.terms AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            NVL (akuser.login_name, '''') AS our_person_incharge,
            invs.internal_comments AS internal_comments,
            pcm.is_self_billing AS is_self_billing,
            phd3.companyname AS smelter_location, ?
       FROM is_invoice_summary invs,
            iid_invoicable_item_details iid,
            pcm_physical_contract_main pcm,
            v_pci pci,
            ii_invoicable_item ii,
            cm_currency_master cm,
            gmr_goods_movement_record gmr,
            pcpd_pc_product_definition pcpd,
            qum_quantity_unit_master qum,
            pcpq_pc_product_quality pcpq,
            qat_quality_attributes qat,
            pdm_productmaster pdm,
            phd_profileheaderdetails phd,
            pym_payment_terms_master pym,
            pad_profile_addresses pad,
            cym_countrymaster cym,
            cim_citymaster cim,
            sm_state_master sm,
            bpat_bp_address_type bpat,
            cym_countrymaster cymloading,
            sad_shipment_advice sad,
            sd_shipment_detail sd,
            phd_profileheaderdetails phd1,
            phd_profileheaderdetails phd2,
            phd_profileheaderdetails phd3,
            qum_quantity_unit_master qum_gmr,
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND iid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND iid.invoicable_item_id = ii.invoicable_item_id
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.invoice_currency_id = cm.cur_id
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.pcpd_id = pcpq.pcpd_id
        AND pci.quality_id = qat.quality_id
        AND pcpq.quality_template_id = qat.quality_id
        AND pcpd.product_id = pdm.product_id
        AND pcm.cp_id = phd.profileid
        AND invs.credit_term(+) = pym.payment_term_id
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND pad.address_type = bpat.bp_address_type_id(+)
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.consignee_id = phd1.profileid(+)
        AND sd.consignee_id = phd2.profileid(+)
        AND gmr.warehouse_profile_id = phd3.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND pad.is_deleted(+) = ''N''
        AND pad.address_type(+) = ''Billing''
        AND invs.internal_invoice_ref_no = ?
   GROUP BY invs.invoice_ref_no,
            invs.invoice_type_name,
            invs.invoice_issue_date,
            invs.invoiced_qty,
            invs.internal_invoice_ref_no,
            invs.total_amount_to_pay,
            invs.total_other_charge_amount,
            invs.total_tax_amount,
            invs.payment_due_date,
            invs.cp_ref_no,
            pcm.issue_date,
            pcm.contract_ref_no,
            cm.cur_code,
            gmr.gmr_ref_no,
            gmr.qty,
            pcpd.qty_max_val,
            qum.qty_unit,
            pcpd.max_tolerance,
            qat.quality_name,
            pdm.product_desc,
            pcm.cp_contract_ref_no,
            pym.payment_term,
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.terms,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            akuser.login_name,
            invs.invoice_status,
            invs.internal_comments,
            is_self_billing,
            phd3.companyname';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqueryisdfor_siconc
    WHERE dgm.doc_id = 'CREATE_SI'
      AND dgm.dgm_id = 'DGM-SIC'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqueryisdfor_vatconc
    WHERE dgm.doc_id = 'CREATE_VAT'
      AND dgm.dgm_id = 'DGM-VAT-1-CONC'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqueryisdfor_dcconc
    WHERE dgm.doc_id = 'CREATE_DC'
      AND dgm.dgm_id = 'DGM-DC-CONC'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';

   COMMIT;
END;