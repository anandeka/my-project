DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DOC_ID = 'CREATE_DFT_API';

commit;

declare fetchQueryAPIDraft CLOB := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_item_stock_ref_no,
             inco_term_location, contract_ref_no, cp_contract_ref_no,
             contract_date, product, invoice_quantity, invoiced_qty_unit,
             quality, payment_term, due_date, invoice_creation_date,
             invoice_amount, invoice_amount_unit, invoice_ref_no,
             contract_type, invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, internal_comments,
             our_person_incharge, adjustment_amount, is_self_billing, is_inv_draft,
             internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            phd.companyname AS cp_name,
            invs.cp_ref_no AS cp_item_stock_ref_no,
            pci.terms AS inco_term_location,
            pcm.contract_ref_no AS contract_ref_no,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') AS contract_date,
            pdm.product_desc AS product,
            invs.invoiced_qty AS invoice_quantity,
            qum.qty_unit AS invoiced_qty_unit, qat.quality_name AS quality,
            pym.payment_term AS payment_term,
            TO_CHAR (invs.payment_due_date, ''dd-Mon-yyyy'') AS due_date,
            TO_CHAR (invs.invoice_issue_date,
                     ''dd-Mon-yyyy''
                    ) AS invoice_creation_date,
            invs.total_amount_to_pay AS invoice_amount,
            cm.cur_code AS invoice_amount_unit,
            invs.invoice_ref_no AS invoice_ref_no,
            pcm.contract_type AS contract_type,
            invs.invoice_status AS invoice_status,
            pcm.purchase_sales AS sales_purchase,
            invs.total_tax_amount AS total_tax_amount,
            invs.total_other_charge_amount AS total_other_charge_amount,
            invs.internal_comments AS internal_comments,
            (gab.firstname ||'' ''|| gab.lastname) AS our_person_incharge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            pcm.is_self_billing AS is_self_billing, invs.is_inv_draft, ?
       FROM is_invoice_summary invs,
            apid_adv_payment_item_details apid,
            pcm_physical_contract_main pcm,
            v_pci pci,
            phd_profileheaderdetails phd,
            pdm_productmaster pdm,
            qat_quality_attributes qat,
            pcpd_pc_product_definition pcpd,
            cm_currency_master cm,
            pym_payment_terms_master pym,
            qum_quantity_unit_master qum,
            ppu_product_price_units ppu,
            pum_price_unit_master pum,
            ak_corporate_user akuser,
            iam_invoice_action_mapping iam,
            axs_action_summary axs,
            gab_globaladdressbook gab
      WHERE invs.internal_invoice_ref_no = apid.internal_invoice_ref_no
        AND apid.contract_item_ref_no = pci.internal_contract_item_ref_no
        AND invs.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
        AND iam.invoice_action_ref_no = axs.internal_action_ref_no
        AND axs.created_by = akuser.user_id
        AND akuser.gabid = gab.gabid
        AND pcpd.product_id = pdm.product_id
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.input_output = ''Input''
        AND pci.quality_id = qat.quality_id
        AND pcm.cp_id = phd.profileid(+)
        AND invs.invoice_cur_id = cm.cur_id
        AND invs.credit_term(+) = pym.payment_term_id
        AND apid.invoice_item_price_unit_id = ppu.internal_price_unit_id(+)
        AND ppu.price_unit_id = pum.price_unit_id
        AND invs.internal_invoice_ref_no = ?
   GROUP BY pcm.contract_ref_no,
            pdm.product_desc,
            qat.quality_name,
            phd.companyname,
            invs.cp_ref_no,
            pci.terms,
            pcm.cp_contract_ref_no,
            pcm.issue_date,
            invs.invoice_ref_no,
            invs.invoice_issue_date,
            invs.payment_due_date,
            invs.total_amount_to_pay,
            cm.cur_code,
            pym.payment_term,
            pcm.contract_type,
            invs.invoice_status,
            pcm.purchase_sales,
            invs.total_tax_amount,
            invs.total_other_charge_amount,
            pum.price_unit_name,
            invs.internal_invoice_ref_no,
            invs.invoiced_qty,
            qum.qty_unit,
            akuser.login_name,
            invs.internal_comments,
            invs.invoice_adjustment_amount,
            pcm.is_self_billing,
            gab.firstname,
            gab.lastname,
            invs.is_inv_draft';



fetchQueryAPIDraft_D CLOB :=
'INSERT INTO API_D (
INTERNAL_INVOICE_REF_NO,
CONTRACT_REF_NO,
PRODUCT,
INVOICE_QUANTITY,
INVOICE_QUANTITY_UNIT,
QUALITY,
INVOICE_AMOUNT_UNIT,
INVOICE_AMOUNT,
PRICE,
PRICE_UNIT,
INVOICE_ITEM_AMOUNT,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
PDM.PRODUCT_DESC as PRODUCT,
APID.INVOICE_ITEM_QTY as INVOICE_QUANTITY,
QUM.QTY_UNIT as INVOICE_QUANTITY_UNIT,
QAT.QUALITY_NAME as QUALITY,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
INVS.TOTAL_AMOUNT_TO_PAY as INVOICE_AMOUNT,
APID.INVOICE_ITEM_PRICE as PRICE,
PUM.PRICE_UNIT_NAME as PRICE_UNIT,
APID.INVOICE_ITEM_AMOUNT as INVOICE_ITEM_AMOUNT,
?
from
IS_INVOICE_SUMMARY invs,
APID_ADV_PAYMENT_ITEM_DETAILS apid,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
V_PCI pci,
PDM_PRODUCTMASTER pdm,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd,
CM_CURRENCY_MASTER cm,
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
and INVS.INVOICE_CUR_ID = CM.CUR_ID
and APID.INVOICE_ITEM_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID(+)
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by
PCM.CONTRACT_REF_NO,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
INVS.TOTAL_AMOUNT_TO_PAY,
CM.CUR_CODE,
INVS.INVOICE_STATUS,
INVS.TOTAL_TAX_AMOUNT,
INVS.TOTAL_OTHER_CHARGE_AMOUNT,
APID.INVOICE_ITEM_PRICE,
PUM.PRICE_UNIT_NAME,
INVS.INTERNAL_INVOICE_REF_NO,
QUM.QTY_UNIT,
INVOICE_ITEM_AMOUNT,
APID.INVOICE_ITEM_QTY';


fetchQueryAPIDraft_BDS CLOB :=
'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction,'''' as remarks, ?
     FROM phd_profileheaderdetails phd,
          oba_our_bank_accounts oba,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi  
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oba.bank_id = phd.profileid
      AND oba.bank_id = oipi.bank_id
      and OIPI.BANK_ACCOUNT_ID = OBA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?';

fetchQueryAPIDraft_BDP CLOB :=
'INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, remarks, iban, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          bpb.bank_name AS bank_name, bpa.account_no AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction,
          cpipi.remarks AS remarks, bpa.iban AS iban, ?
     FROM bpa_bp_bank_accounts bpa,
          bpb_business_partner_banks bpb,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = bpa.bank_id
      AND bpa.bank_id = bpb.bank_id
      AND cpipi.bank_account_id = bpa.account_id
      AND invs.internal_invoice_ref_no = ?';

fetchQueryAPIDraft_ITD CLOB :=
'INSERT INTO itd_d
            (internal_invoice_ref_no, tax_code, tax_rate, invoice_currency,
             fx_rate, amount, tax_currency, invoice_amount, applicable_on,
             internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          tm.tax_code AS tax_code, itd.tax_rate AS tax_rate,
          cm.cur_code AS invoice_currency, itd.fx_rate AS fx_rate,
          itd.tax_amount AS amount, cm_tax.cur_code AS tax_currency,
          itd.tax_amount_in_inv_cur AS invoice_amount,
          itd.applicable_on AS applicable_on, ?
     FROM is_invoice_summary invs,
          itd_invoice_tax_details itd,
          tm_tax_master tm,
          cm_currency_master cm,
          cm_currency_master cm_tax
    WHERE invs.internal_invoice_ref_no = itd.internal_invoice_ref_no
      AND itd.tax_code_id = tm.tax_id
      AND itd.invoice_cur_id = cm.cur_id
      AND itd.tax_amount_cur_id = cm_tax.cur_id
      AND itd.internal_invoice_ref_no = ?';

fetchQueryAPIDraft_IOC CLOB :=
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
    DESCRIPTION,
    INTERNAL_DOC_REF_NO
    )
    SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                scm.cost_display_name AS other_charge_cost_name,
                ioc.charge_type AS charge_type,
                NVL (ioc.rate_fx_rate, ioc.flat_amount_fx_rate) AS fx_rate,
                ioc.quantity AS quantity,
                NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                ioc.amount_in_inv_cur AS invoice_amount,
                cm.cur_code AS invoice_cur_name,
                (CASE
                    WHEN (scm.cost_display_name = ''Location Value'')
                       THEN NULL
                    WHEN ioc.rate_price_unit = ''Bags''
                    AND ioc.charge_type = ''Rate''
                       THEN cm.cur_code || ''/'' || ''Bag''
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                    AND ioc.charge_type = ''Rate''
                       THEN nvl(cm_lot.cur_code,cm.cur_code) || ''/'' || ''Lot''
                    ELSE pum.price_unit_name
                 END
                ) AS rate_price_unit_name,
                NVL (ioc.flat_amount, ioc.rate_charge) AS charge_amount_rate,
                qum.qty_unit AS quantity_unit, cm_ioc.cur_code AS amount_unit,
                ioc.other_charge_desc AS description, ?
           FROM is_invoice_summary invs,
                ioc_invoice_other_charge ioc,
                cm_currency_master cm,
                scm_service_charge_master scm,
                ppu_product_price_units ppu,
                pum_price_unit_master pum,
                qum_quantity_unit_master qum,
                cm_currency_master cm_ioc,
                cm_currency_master cm_lot
WHERE           invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
            AND ioc.other_charge_cost_id = scm.cost_id(+)
            AND ioc.invoice_cur_id = cm.cur_id(+)
            AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
            AND ppu.price_unit_id = pum.price_unit_id(+)
            AND ioc.rate_price_unit = cm_lot.cur_id(+)
            AND ioc.qty_unit_id = qum.qty_unit_id(+)
            AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
            AND ioc.internal_invoice_ref_no = ?';
      
begin
INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_API_1','CREATE_DFT_API','Adv Payment Draft Invoice','CREATE_DFT_API',1,fetchQueryAPIDraft,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_API_2','CREATE_DFT_API','Adv Payment Draft Invoice','CREATE_DFT_API',2,fetchQueryAPIDraft_D,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_API_3','CREATE_DFT_API','Adv Payment Draft Invoice','CREATE_DFT_API',3,fetchQueryAPIDraft_BDS,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_API_4','CREATE_DFT_API','Adv Payment Draft Invoice','CREATE_DFT_API',4,fetchQueryAPIDraft_BDP,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_API_5','CREATE_DFT_API','Adv Payment Draft Invoice','CREATE_DFT_API',5,fetchQueryAPIDraft_ITD,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_API_6','CREATE_DFT_API','Adv Payment Draft Invoice','CREATE_DFT_API',6,fetchQueryAPIDraft_IOC,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_APIC_1','CREATE_DFT_API','Conc Adv Payment Draft Invoice','CREATE_DFT_API',1,fetchQueryAPIDraft,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_APIC_2','CREATE_DFT_API','Conc Adv Payment Draft Invoice','CREATE_DFT_API',2,fetchQueryAPIDraft_D,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_APIC_3','CREATE_DFT_API','Conc Adv Payment Draft Invoice','CREATE_DFT_API',3,fetchQueryAPIDraft_BDS,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_APIC_4','CREATE_DFT_API','Conc Adv Payment Draft Invoice','CREATE_DFT_API',4,fetchQueryAPIDraft_BDP,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_APIC_5','CREATE_DFT_API','Conc Adv Payment Draft Invoice','CREATE_DFT_API',5,fetchQueryAPIDraft_ITD,'Y');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('CREATE_DFT_APIC_6','CREATE_DFT_API','Conc Adv Payment Draft Invoice','CREATE_DFT_API',6,fetchQueryAPIDraft_IOC,'Y');

commit;
end;