DECLARE fetchQueryISDDraftFI clob := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_quantity, invoiced_qty_unit, internal_invoice_ref_no,
             invoice_amount, material_cost, addditional_charges, taxes,
             due_date, supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, cp_name, cp_address, cp_country, cp_city, cp_state,
             cp_zip, contract_type, inco_term_location, notify_party,
             sales_purchase, invoice_status, is_free_metal, is_pledge,
             internal_comments, total_premium_amount, prov_percentage,
             adjustment_amount, our_person_incharge, is_self_billing,IS_INV_DRAFT, internal_doc_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            invs.invoiced_qty AS invoice_quantity,
            (case when INVS.IS_FREE_METAL = ''Y''
                    then ''''
                 when INVS.IS_PLEDGE = ''Y''
                    then ''''
                 else
                    stragg(distinct qum_gmr.qty_unit)
            end) AS invoiced_qty_unit,
            invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            invs.total_amount_to_pay AS invoice_amount,
            invs.amount_to_pay_before_adj AS material_cost,
            invs.total_other_charge_amount AS addditional_charges,
            invs.total_tax_amount AS taxes, invs.payment_due_date AS due_date,
            invs.cp_ref_no AS supplier_invoice_no,
            pcm.issue_date AS contract_date,
            pcm.contract_ref_no AS contract_ref_no,
            SUM (ii.invoicable_qty) AS stock_quantity,
            stragg (DISTINCT ii.stock_ref_no) AS stock_ref_no,
            cm.cur_code AS invoice_amount_unit,
            stragg (DISTINCT gmr.gmr_ref_no) AS gmr_ref_no,
            SUM (gmr.qty) AS gmr_quality,
            pcpd.qty_max_val AS contract_quantity,
            qum.qty_unit AS contract_qty_unit,
            pcpd.max_tolerance AS contract_tolerance,
            qat.quality_name AS quality, pdm.product_desc AS product,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            pym.payment_term AS payment_term, phd.companyname AS cp_name,
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip, pcm.contract_type AS contract_type,
            pci.terms AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.is_free_metal AS is_free_metal, invs.is_pledge AS is_pledge,
            invs.internal_comments AS internal_comments,
            invs.total_premium_amount AS premium_disc_amt,
            invs.provisional_pymt_pctg AS prov_percentage,
            invs.invoice_adjustment_amount As adjustment_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing, INVS.IS_INV_DRAFT,
            ?
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
            sad_shipment_advice sad,
            sd_shipment_detail sd,
            phd_profileheaderdetails phd1,
            phd_profileheaderdetails phd2,
            qum_quantity_unit_master qum_gmr,
            AK_CORPORATE_USER akuser,
            GAB_GLOBALADDRESSBOOK gab,
            AXS_ACTION_SUMMARY axs,
            IAM_INVOICE_ACTION_MAPPING iam
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND INVS.INVOICE_CUR_ID = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
        AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
        AND AXS.CREATED_BY = AKUSER.USER_ID
        AND AKUSER.GABID = GAB.GABID
        AND pcpd.qty_unit_id = qum.qty_unit_id(+)
        AND pcpd.pcpd_id = pcpq.pcpd_id(+)
        AND pci.quality_id = qat.quality_id(+)
        AND pcpd.product_id = pdm.product_id(+)
        AND invs.cp_id = phd.profileid(+)
        AND INVS.CREDIT_TERM = pym.payment_term_id(+)
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND pad.address_type = bpat.bp_address_type_id(+)
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.notify_party_id = phd1.profileid(+)
        AND sd.notify_party_id = phd2.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND pad.is_deleted(+) = ''N''
        AND pad.address_type(+) = ''Billing''
        AND pcpd.input_output(+) = ''Input''
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
            pcpd.qty_max_val,
            qum.qty_unit,
            pcpd.max_tolerance,
            qat.quality_name,
            pdm.product_desc,
            pcm.cp_contract_ref_no,
            pym.payment_term,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            pci.terms,
            phd1.companyname,
            phd2.companyname,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.is_free_metal,
            invs.is_pledge,
            invs.internal_comments,
            invs.provisional_pymt_pctg,
            invs.total_premium_amount,
            invs.invoice_adjustment_amount,
            pcm.is_self_billing,
            AKUSER.LOGIN_NAME,
            INVS.PROV_PCTG_AMT,
            INVS.IS_INV_DRAFT,
            GAB.FIRSTNAME,
            GAB.LASTNAME';

fetchQueryISChildDraftFI clob :='INSERT INTO is_child_d
            (internal_invoice_ref_no, gmr_ref_no, gmr_quantity, gmr_quality,
             price_as_per_defind_uom, total_price_qty, gmr_qty_unit,
             invoiced_qty_unit, invoiced_price_unit, stock_ref_no, stock_qty,
             fx_rate, item_amount_in_inv_cur, product, yield,
             internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          gmr.gmr_ref_no AS gmr_ref_no, gmr.qty AS gmr_quantity,
          NVL (qat.quality_name, qat1.quality_name) AS gmr_quality,
          iid.new_invoice_price AS price_as_per_defind_uom,
          iid.invoiced_qty AS total_price_qty, qum.qty_unit AS gmr_qty_unit,
          quminv.qty_unit AS invoiced_qty_unit,
          pum.price_unit_name AS invoiced_price_unit,
          NVL (grd.internal_stock_ref_no,
               dgrd.internal_stock_ref_no
              ) AS stock_ref_no,
          iid.invoiced_qty AS stock_qty, iid.fx_rate AS fx_rate,
          iid.invoice_item_amount AS item_amount_in_inv_cur,
          pdm.product_desc AS product, ypd.yield_pct AS yield, ?
     FROM is_invoice_summary invs,
          iid_invoicable_item_details iid,
          gmr_goods_movement_record gmr,
          qum_quantity_unit_master qum,
          qum_quantity_unit_master quminv,
          ppu_product_price_units ppu,
          pum_price_unit_master pum,
          grd_goods_record_detail grd,
          dgrd_delivered_grd dgrd,
          qat_quality_attributes qat,
          pdm_productmaster pdm,
          qat_quality_attributes qat1,
          aml_attribute_master_list aml,
          ypd_yield_pct_detail ypd
    WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
      AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
      AND gmr.qty_unit_id = qum.qty_unit_id(+)
      AND iid.invoiced_qty_unit_id = quminv.qty_unit_id(+)
      AND iid.new_invoice_price_unit_id = ppu.internal_price_unit_id(+)
      AND ppu.price_unit_id = pum.price_unit_id(+)
      AND iid.stock_id = grd.internal_grd_ref_no(+)
      AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
      AND grd.quality_id = qat.quality_id(+)
      AND grd.product_id = pdm.product_id(+)
      AND dgrd.quality_id = qat1.quality_id(+)
      AND grd.element_id = aml.attribute_id(+)
      AND grd.element_id = ypd.element_id(+)
      AND grd.internal_gmr_ref_no = ypd.internal_gmr_ref_no(+)
      AND NVL (ypd.is_active, ''Y'') = ''Y''
      AND iid.internal_invoice_ref_no = ?';
      
fetchQueryISBDSDraftFI clob :='INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, OIPI.REMARKS as remarks, ?
     FROM phd_profileheaderdetails phd,
          oba_our_bank_accounts oba,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi  
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oba.bank_id = phd.profileid
      AND oba.bank_id = oipi.bank_id
      and OIPI.BANK_ACCOUNT_ID = OBA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?';
      
fetchQueryBDPDraftFI clob :='INSERT INTO is_bdp_child_d
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
      
fetchQueryISParentChildDraftFI clob :='INSERT INTO is_parent_child_d
            (internal_invoice_ref_no, invoice_ref_no, invoice_issue_date,
             due_date, invoice_currency, invoice_amount, prov_pymt_percentage,
             invoice_type_name, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          invs.invoice_ref_no AS invoice_ref_no,
          invs.invoice_issue_date AS invoice_issue_date,
          invs.payment_due_date AS due_date, cm.cur_code AS invoice_currency,
          (CASE
              WHEN invs.prov_pctg_amt IS NOT NULL
              AND invs.freight_allowance_amt IS NOT NULL
                 THEN invs.prov_pctg_amt + invs.freight_allowance_amt
              WHEN invs.prov_pctg_amt IS NOT NULL
                 THEN invs.prov_pctg_amt
              WHEN invs.prov_pctg_amt IS NULL
              AND invs.freight_allowance_amt IS NOT NULL
                 THEN   invs.amount_to_pay_before_adj
                      + invs.freight_allowance_amt
              ELSE invs.amount_to_pay_before_adj
           END
          ) AS invoice_amount,
          NVL (TO_CHAR (invs.provisional_pymt_pctg),
               ''100''
              ) AS prov_pymt_percentage,
          invs.invoice_type_name AS invoice_type_name, ?
     FROM is_invoice_summary invs,
          cpcr_commercial_inv_pc_mapping cpcr,
          cm_currency_master cm
    WHERE cpcr.parent_invoice_ref_no = invs.internal_invoice_ref_no
      AND invs.invoice_cur_id = cm.cur_id
      AND cpcr.internal_invoice_ref_no = ?';
      
fetchQueryIOCDraftFI clob :='INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, DESCRIPTION, internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no
                                                   AS internal_invoice_ref_no,
                         NVL
                            (pcmac.addn_charge_name,
                             scm.cost_display_name
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
                         NVL (ioc.flat_amount,
                              ioc.rate_charge
                             ) AS charge_amount_rate,
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
                             WHEN scm.cost_component_name IN
                                                          (''Handling Charge'')
                                THEN cm.cur_code
                             WHEN ioc.charge_type =''Rate''
                                THEN cm_pum.cur_code
                             ELSE cm_ioc.cur_code
                          END
                         ) AS amount_unit,
                         IOC.OTHER_CHARGE_DESC as DESCRIPTION,
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
                         pcmac_pcm_addn_charges pcmac
                   WHERE invs.internal_invoice_ref_no =
                                                   ioc.internal_invoice_ref_no
                     AND ioc.other_charge_cost_id = scm.cost_id(+)
                     AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
                     AND ioc.invoice_cur_id = cm.cur_id(+)
                     AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
                     AND ioc.rate_price_unit = cm_lot.cur_id(+)
                     AND ppu.price_unit_id = pum.price_unit_id(+)
                     AND ioc.qty_unit_id = qum.qty_unit_id(+)
                     AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
                     AND cm_pum.cur_id(+) = pum.cur_id
                     AND ioc.internal_invoice_ref_no = ?)
   SELECT *
     FROM TEST t
    WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
    
fetchQueryITDDraftFI clob := 'INSERT INTO itd_d
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
      
fetchQueryIOCForAllInvoices clob :='INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, DESCRIPTION, internal_doc_ref_no)
WITH TEST AS
     (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                      NVL (scm.cost_display_name,
                           pcmac.addn_charge_name
                          ) AS other_charge_cost_name,
                      ioc.charge_type AS charge_type,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          WHEN (ioc.rate_fx_rate IS NULL)
                          AND (ioc.flat_amount_fx_rate IS NULL)
                             THEN 1
                          WHEN ioc.rate_fx_rate IS NULL
                             THEN ioc.flat_amount_fx_rate
                          ELSE ioc.rate_fx_rate
                       END
                      ) AS fx_rate,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE ioc.quantity
                       END
                      ) AS quantity,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE NVL (ioc.rate_amount, ioc.flat_amount)
                       END
                      ) AS amount,
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
                                  ''Ocular Inspection Charge'', ''Small Lot Charges'')
                          AND ioc.charge_type = ''Rate''
                             THEN nvl(cm_lot.cur_code,cm.cur_code) || ''/'' || ''Lot''
                          ELSE pum.price_unit_name
                       END
                      ) AS rate_price_unit_name,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE NVL (ioc.flat_amount,ioc.rate_charge)
                       END
                      ) AS charge_amount_rate,
                      (CASE
                          WHEN ioc.rate_price_unit = ''Bags''
                             THEN ''Bags''
                          WHEN scm.cost_component_name IN
                                 (''Assay Charge'', ''Sampling Charge'',
                                  ''Ocular Inspection Charge'', ''Small Lot Charges'')
                             THEN ''Lots''
                          WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                             THEN ''Lots''
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE qum.qty_unit
                       END
                      ) AS quantity_unit,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          WHEN scm.cost_component_name IN
                                 (''Assay Charge'',''Sampling Charge'',
                                  ''Ocular Inspection Charge'', ''Small Lot Charges'')
                          AND ioc.charge_type = ''Rate''
                             THEN cm_lot.cur_code
                          WHEN scm.cost_component_name IN (''Handling Charge'')
                             THEN cm.cur_code
                          WHEN ioc.charge_type = ''Rate''
                             THEN cm_pum.cur_code
                          ELSE cm_ioc.cur_code
                       END
                      ) AS amount_unit,
                      IOC.OTHER_CHARGE_DESC as DESCRIPTION,
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
                      pcmac_pcm_addn_charges pcmac
                WHERE invs.internal_invoice_ref_no =
                                                   ioc.internal_invoice_ref_no
                  AND ioc.other_charge_cost_id = scm.cost_id(+)
                  AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
                  AND ioc.invoice_cur_id = cm.cur_id(+)
                  AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
                  AND ioc.rate_price_unit = cm_lot.cur_id(+)
                  AND ppu.price_unit_id = pum.price_unit_id(+)
                  AND ioc.qty_unit_id = qum.qty_unit_id(+)
                  AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
                  AND cm_pum.cur_id(+) = pum.cur_id
                  AND ioc.internal_invoice_ref_no = ?)
SELECT *
  FROM TEST t
 WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
      
BEGIN

DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM-DFT-FI-ISD' AND DGM.DOC_ID='CREATE_DFT_FI' AND DGM.SEQUENCE_ORDER=1 AND DGM.IS_CONCENTRATE='N';

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFT-FI-ISD', 'CREATE_DFT_FI', 'Draft Final Invoice', 'CREATE_DFT_FI', 1, 
    fetchQueryISDDraftFI, 'N');

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryISChildDraftFI, DGM.DOC_NAME='Draft Final Invoice' WHERE DGM.DGM_ID='DGM-DFT-FI-C1' AND DGM.DOC_ID='CREATE_DFT_FI' AND DGM.SEQUENCE_ORDER=2 AND DGM.IS_CONCENTRATE='N';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryISBDSDraftFI WHERE DGM.DGM_ID='DGM-DFT-FI-C3' AND DGM.DOC_ID='CREATE_DFT_FI' AND DGM.SEQUENCE_ORDER=3 AND DGM.IS_CONCENTRATE='N';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryBDPDraftFI WHERE DGM.DGM_ID='DGM-DFT-FI-C4' AND DGM.DOC_ID='CREATE_DFT_FI' AND DGM.SEQUENCE_ORDER=4 AND DGM.IS_CONCENTRATE='N';

DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM-DFT-FI-C5' AND DGM.DOC_ID='CREATE_DFT_FI' AND DGM.SEQUENCE_ORDER=5 AND DGM.IS_CONCENTRATE='N';

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFT-FI-C5', 'CREATE_DFT_FI', 'Draft Final Invoice', 'CREATE_DFT_FI', 5, 
    fetchQueryISParentChildDraftFI, 'N');


DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM-DFT-FI-C6' AND DGM.DOC_ID='CREATE_DFT_FI' AND DGM.SEQUENCE_ORDER=6 AND DGM.IS_CONCENTRATE='N';

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFT-FI-C6', 'CREATE_DFT_FI', 'Draft Final Invoice', 'CREATE_DFT_FI', 6, 
    fetchQueryIOCDraftFI, 'N');
    
DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM-DFT-FI-C7' AND DGM.DOC_ID='CREATE_DFT_FI' AND DGM.SEQUENCE_ORDER=7 AND DGM.IS_CONCENTRATE='N';

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFT-FI-C7', 'CREATE_DFT_FI', 'Draft Final Invoice', 'CREATE_DFT_FI', 7, 
    fetchQueryITDDraftFI, 'N');
    
UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryISDDraftFI WHERE DGM.DGM_ID='12' AND DGM.DOC_ID='CREATE_DFT_DFI' AND DGM.SEQUENCE_ORDER=1 AND DGM.IS_CONCENTRATE='N';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryISChildDraftFI, DGM.DOC_NAME='Draft Direct Final Invoice' WHERE DGM.DGM_ID='DGM-DFT-DFI-C1' AND DGM.DOC_ID='CREATE_DFT_DFI' AND DGM.SEQUENCE_ORDER=2 AND DGM.IS_CONCENTRATE='N';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryISBDSDraftFI, DGM.DOC_NAME='Draft Direct Final Invoice' WHERE DGM.DGM_ID='DGM-DFT-DFI-C3' AND DGM.DOC_ID='CREATE_DFT_DFI' AND DGM.SEQUENCE_ORDER=3 AND DGM.IS_CONCENTRATE='N';

UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryBDPDraftFI, DGM.DOC_NAME='Draft Direct Final Invoice' WHERE DGM.DGM_ID='DGM-DFT-DFI-C4' AND DGM.DOC_ID='CREATE_DFT_DFI' AND DGM.SEQUENCE_ORDER=4 AND DGM.IS_CONCENTRATE='N';

DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM-DFT-DFI-C5' AND DGM.DOC_ID='CREATE_DFT_DFI' AND DGM.SEQUENCE_ORDER=5 AND DGM.IS_CONCENTRATE='N';

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFT-DFI-C5', 'CREATE_DFT_DFI', 'Draft Direct Final Invoice', 'CREATE_DFT_DFI', 5, 
    fetchQueryISParentChildDraftFI, 'N');


DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM-DFT-DFI-C6' AND DGM.DOC_ID='CREATE_DFT_DFI' AND DGM.SEQUENCE_ORDER=6 AND DGM.IS_CONCENTRATE='N';

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFT-DFI-C6', 'CREATE_DFT_DFI', 'Draft Direct Final Invoice', 'CREATE_DFT_DFI', 6, 
    fetchQueryIOCDraftFI, 'N');
    
DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM-DFT-DFI-C7' AND DGM.DOC_ID='CREATE_DFT_DFI' AND DGM.SEQUENCE_ORDER=7 AND DGM.IS_CONCENTRATE='N';

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFT-DFI-C7', 'CREATE_DFT_DFI', 'Draft Direct Final Invoice', 'CREATE_DFT_DFI', 7, 
    fetchQueryITDDraftFI, 'N');
    
UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryIOCForAllInvoices WHERE FETCH_QUERY LIKE '%IOC_D%' OR FETCH_QUERY LIKE '%ioc_d%';
COMMIT;
END;


