Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID, IS_CONTINUOUS_MIDDLE_NO_REQ)
 Values
   ('CREATE_OCI', 'Output Charge Invoice', 109, NULL, 'Y', 
    'N', NULL, 'Y');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('OCI_KEY_1', 'Output Charge Invoice', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

 Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_OCI_1', 'CREATE_OCI', 'Output Charge Invoice', 'CREATE_OCI', 1, 
    'INSERT INTO IS_D (
internal_invoice_ref_no,
cp_name,
invoice_ref_no,
invoice_creation_date,
due_date,
payment_term,
cp_address,
cp_country,
cp_city,
cp_state,
cp_zip,
invoice_amount,
invoice_amount_unit,
addditional_charges,
taxes,
adjustment_amount,
INTERNAL_DOC_REF_NO
)
SELECT invs.internal_invoice_ref_no as internal_invoice_ref_no, phd.companyname AS cp_name, invs.invoice_ref_no AS invoice_ref_no,
       invs.invoice_issue_date AS invoice_creation_date,
       invs.payment_due_date AS due_date, pym.payment_term AS payment_term,
       pad.address AS cp_address, cym.country_name AS cp_country,
       cim.city_name AS cp_city, sm.state_name AS cp_state, pad.zip AS cp_zip,
       invs.total_amount_to_pay AS invoice_amount,
       cm.cur_code AS invoice_amount_unit,
       invs.total_other_charge_amount AS addditional_charges,
       invs.total_tax_amount AS taxes,
       invs.invoice_adjustment_amount AS adjustment_amount,
       ?
  FROM is_invoice_summary invs,
       phd_profileheaderdetails phd,
       pym_payment_terms_master pym,
       cym_countrymaster cym,
       cim_citymaster cim,
       sm_state_master sm,
       pad_profile_addresses pad,
       bpat_bp_address_type bpat,
       cm_currency_master cm
 WHERE invs.cp_id = phd.profileid
   AND invs.credit_term = pym.payment_term_id
   AND phd.profileid = pad.profile_id(+)
   AND pad.country_id = cym.country_id(+)
   AND pad.city_id = cim.city_id(+)
   AND pad.state_id = sm.state_id(+)
   AND pad.address_type = bpat.bp_address_type_id(+)
   AND invs.invoice_cur_id = cm.cur_id
   AND pad.is_deleted(+) = ''N''
   AND pad.address_type(+) = ''Billing''
   AND invs.internal_invoice_ref_no = ?', 'N');


Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_OCI_IOC', 'CREATE_OCI', 'Output Charge Invoice', 'CREATE_OCI', 2, 
    'a', 'N');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_OCI_ITD', 'CREATE_OCI', 'Output Charge Invoice', 'CREATE_OCI', 3, 
    'INSERT INTO ITD_D (
        INTERNAL_INVOICE_REF_NO,
        TAX_CODE,
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
        TM.TAX_CODE as TAX_CODE,
        ITD.TAX_RATE as TAX_RATE,
        CM.CUR_CODE as INVOICE_CURRENCY,
        ITD.FX_RATE as FX_RATE,
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
        and ITD.INTERNAL_INVOICE_REF_NO = ?', 'N');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_OCI_BDS', 'CREATE_OCI', 'Output Charge Invoice', 'CREATE_OCI', 4, 
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
      AND invs.internal_invoice_ref_no = ?', 'N');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_OCI_BDP', 'CREATE_OCI', 'Output Charge Invoice', 'CREATE_OCI', 5, 
    'INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          bpb.bank_name AS bank_name, bpa.account_no AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction,'''' as remarks, ?
     FROM bpa_bp_bank_accounts bpa,
          bpb_business_partner_banks bpb,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = bpa.bank_id
      AND bpa.bank_id = bpb.bank_id
      and CPIPI.BANK_ACCOUNT_ID = BPA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?', 'N');


DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, description, quantity_unit,
             amount_unit, internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                (CASE
                    WHEN (pcmac.addn_charge_name IS NULL)
                    AND (scm.cost_display_name IS NULL)
                       THEN mcc.charge_name
                    WHEN pcmac.addn_charge_name IS NULL
                       THEN scm.cost_display_name
                    ELSE pcmac.addn_charge_name
                 END
                ) AS other_charge_cost_name,
                ioc.charge_type AS charge_type,
                (CASE
                    WHEN (ioc.rate_fx_rate IS NULL)
                    AND (ioc.flat_amount_fx_rate IS NULL)
                       THEN 1
                    WHEN ioc.rate_fx_rate IS NULL
                       THEN ioc.flat_amount_fx_rate
                    ELSE ioc.rate_fx_rate
                 END
                ) AS fx_rate,
                ioc.quantity AS quantity,
                NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                ioc.amount_in_inv_cur AS invoice_amount,
                cm.cur_code AS invoice_cur_name,
                (CASE
                    WHEN ioc.rate_price_unit = ''Bags''
                    AND ioc.charge_type = ''Rate''
                       THEN cm.cur_code || ''/'' || ''Bag''
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                    AND ioc.charge_type = ''Rate''
                       THEN cm_lot.cur_code || ''/'' || ''Lot''
                    ELSE pum.price_unit_name
                 END
                ) AS rate_price_unit_name,
                NVL (ioc.flat_amount, ioc.rate_charge) AS charge_amount_rate,
                NVL (ioc.other_charge_desc,
                     aml.attribute_name) AS description,
                (CASE
                    WHEN ioc.rate_price_unit = ''Bags''
                       THEN ''Bags''
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                       THEN ''Lots''
                    WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                       THEN ''Lots''
                    ELSE qum.qty_unit
                 END
                ) AS quantity_unit,
                (CASE
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                    AND ioc.charge_type = ''Rate''
                       THEN cm_lot.cur_code
                    WHEN scm.cost_component_name IN (''Handling Charge'')
                       THEN cm.cur_code
                    WHEN ioc.charge_type = ''Rate''
                       THEN cm_pum.cur_code
                    ELSE cm_ioc.cur_code
                 END
                ) AS amount_unit,
                ?
           FROM is_invoice_summary invs,
                ioc_invoice_other_charge ioc,
                cm_currency_master cm,
                scm_service_charge_master scm,
                ppu_product_price_units ppu,
                pum_price_unit_master pum,
                qum_quantity_unit_master qum,
                cm_currency_master cm_ioc,
                cm_currency_master cm_pum,
                cm_currency_master cm_lot,
                pcmac_pcm_addn_charges pcmac,
                mcc_miscellaneous_comm_charges mcc,
                aml_attribute_master_list aml
          WHERE invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
            AND ioc.other_charge_cost_id = scm.cost_id(+)
            AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
            AND ioc.other_charge_cost_id IN (mcc.mcc_id,mcc.charge_id)
            AND mcc.element_id = aml.attribute_id(+)
            AND ioc.invoice_cur_id = cm.cur_id(+)
            AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
            AND ioc.rate_price_unit = cm_lot.cur_id(+)
            AND ppu.price_unit_id = pum.price_unit_id(+)
            AND ioc.qty_unit_id = qum.qty_unit_id(+)
            AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
            AND mcc.charge_name IN ('Fixed RC Charges', 'Fixed TC Charges', 'Premium')
            AND cm_pum.cur_id(+) = pum.cur_id
            AND ioc.internal_invoice_ref_no = ?)
   SELECT *
     FROM TEST t
    WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqry1
    WHERE dgm.is_concentrate = 'N'
      AND dgm.dgm_id IN ('DGM_OCI_IOC');

   COMMIT;
END;