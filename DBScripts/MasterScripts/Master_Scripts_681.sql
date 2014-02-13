
DECLARE
   fetchqryis_d_piconc       CLOB
      := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_dry_quantity, invoice_wet_quantity, moisture,
             invoiced_qty_unit, internal_invoice_ref_no, invoice_amount,
             material_cost, addditional_charges, taxes, due_date,
             supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             freight_charge, adjustment_amount, total_premium_amount,
             our_person_incharge, internal_comments, is_self_billing,
             prov_percentage, provisional_invoice_amount, smelter_location, internal_doc_ref_no)
   WITH TEST AS
        (SELECT   invs.internal_invoice_ref_no, SUM (asm.net_weight) AS wet,
                  SUM (asm.dry_weight) AS dry
             FROM is_invoice_summary invs,
                  ash_assay_header ash,
                  asm_assay_sublot_mapping asm,
                  iam_invoice_assay_mapping iam
            WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
              AND iam.ash_id = ash.ash_id
              AND ash.ash_id = asm.ash_id
         GROUP BY invs.internal_invoice_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            t.dry AS invoice_dry_quantity, t.wet AS invoice_wet_quantity,
            ROUND ((((t.wet - t.dry) / t.wet) * 100), 2) AS moisture,
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
            stragg (DISTINCT ii.stock_ref_no) AS stock_ref_no,
            NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
            stragg (DISTINCT gmr.gmr_ref_no) AS gmr_ref_no,
            SUM (gmr.qty) AS gmr_quality,
            pcpd.qty_max_val AS contract_quantity,
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            (gab.firstname || '' '' || gab.lastname) AS our_person_incharge,
            invs.internal_comments AS internal_comments, pcm.is_self_billing,
            invs.provisional_pymt_pctg,
            invs.prov_pctg_amt AS provisional_invoice_amount, phd3.companyname AS smelter_location, ?
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
            cm_currency_master cm_pct,
            ak_corporate_user akuser,
            gab_globaladdressbook gab,
            axs_action_summary axs,
            iam_invoice_action_mapping iam,
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
        AND iam.invoice_action_ref_no = axs.internal_action_ref_no
        AND axs.action_id != ''MODIFY_INVOICE''
        AND axs.created_by = akuser.user_id
        AND akuser.gabid = gab.gabid
        AND pcpd.qty_unit_id = qum.qty_unit_id(+)
        AND pcpd.pcpd_id = pcpq.pcpd_id(+)
        AND pci.quality_id = qat.quality_id(+)
        AND pcpd.product_id = pdm.product_id(+)
        AND invs.cp_id = phd.profileid(+)
        AND invs.credit_term = pym.payment_term_id(+)
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND pad.address_type = bpat.bp_address_type_id(+)
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.notify_party_id = phd1.profileid(+)
        AND sd.notify_party_id = phd2.profileid(+)
        AND gmr.warehouse_profile_id = phd3.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND invs.invoice_cur_id = cm_pct.cur_id(+)
        AND pad.address_type(+) = ''Billing''
        AND pad.is_deleted(+) = ''N''
        AND pcpd.input_output IN (''Input'')
        AND t.internal_invoice_ref_no = invs.internal_invoice_ref_no
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
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.freight_allowance_amt,
            invs.invoice_adjustment_amount,
            invs.total_premium_amount,
            cm_pct.cur_code,
            akuser.login_name,
            t.dry,
            t.wet,
            pcm.is_self_billing,
            invs.internal_comments,
            gab.firstname,
            gab.lastname,
            invs.provisional_pymt_pctg,
            invs.prov_pctg_amt,
            phd3.companyname';
   fetchqryis_d_dficonc      CLOB
      := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_dry_quantity, invoice_wet_quantity, moisture,
             invoiced_qty_unit, internal_invoice_ref_no, invoice_amount,
             material_cost, addditional_charges, taxes, due_date,
             supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             freight_charge, adjustment_amount, total_premium_amount,
             our_person_incharge, internal_comments, is_self_billing, smelter_location, internal_doc_ref_no)
   WITH TEST AS
        (SELECT   invs.internal_invoice_ref_no, SUM (asm.net_weight) AS wet,
                  SUM (asm.dry_weight) AS dry
             FROM is_invoice_summary invs,
                  ash_assay_header ash,
                  asm_assay_sublot_mapping asm,
                  iam_invoice_assay_mapping iam
            WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
              AND iam.ash_id = ash.ash_id
              AND ash.ash_id = asm.ash_id
         GROUP BY invs.internal_invoice_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            t.dry AS invoice_dry_quantity, t.wet AS invoice_wet_quantity,
            ROUND ((((t.wet - t.dry) / t.wet) * 100), 2) AS moisture,
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
            stragg (DISTINCT ii.stock_ref_no) AS stock_ref_no,
            NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
            stragg (DISTINCT gmr.gmr_ref_no) AS gmr_ref_no,
            SUM (gmr.qty) AS gmr_quality,
            pcpd.qty_max_val AS contract_quantity,
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge,INVS.INTERNAL_COMMENTS as internal_comments, pcm.is_self_billing, phd3.companyname AS smelter_location, ?
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
            cm_currency_master cm_pct,
            ak_corporate_user akuser,
            GAB_GLOBALADDRESSBOOK gab,
            AXS_ACTION_SUMMARY axs,
            IAM_INVOICE_ACTION_MAPPING iam,
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
        AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
        AND AXS.ACTION_ID != ''MODIFY_INVOICE''
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
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.notify_party_id = phd1.profileid(+)
        AND sd.notify_party_id = phd2.profileid(+)
        AND gmr.warehouse_profile_id = phd3.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND invs.invoice_cur_id = cm_pct.cur_id(+)
        AND pad.address_type(+) = ''Billing''
        AND pad.is_deleted(+) = ''N''
        AND pcpd.input_output IN (''Input'')
        AND t.internal_invoice_ref_no = invs.internal_invoice_ref_no
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
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.freight_allowance_amt,
            invs.invoice_adjustment_amount,
            invs.total_premium_amount,
            cm_pct.cur_code,
            akuser.login_name,
            t.dry,
            t.wet,
            pcm.is_self_billing,
            INVS.INTERNAL_COMMENTS,
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            phd3.companyname';
   fetchqryis_d_ficonc       CLOB
      := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_dry_quantity, invoice_wet_quantity, moisture,
             invoiced_qty_unit, internal_invoice_ref_no, invoice_amount,
             material_cost, addditional_charges, taxes, due_date,
             supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             freight_charge, adjustment_amount, total_premium_amount,
             our_person_incharge, internal_comments, is_self_billing, smelter_location, internal_doc_ref_no)
   WITH TEST AS
        (SELECT   invs.internal_invoice_ref_no, SUM (asm.net_weight) AS wet,
                  SUM (asm.dry_weight) AS dry
             FROM is_invoice_summary invs,
                  ash_assay_header ash,
                  asm_assay_sublot_mapping asm,
                  iam_invoice_assay_mapping iam
            WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
              AND iam.ash_id = ash.ash_id
              AND ash.ash_id = asm.ash_id
         GROUP BY invs.internal_invoice_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            t.dry AS invoice_dry_quantity, t.wet AS invoice_wet_quantity,
            ROUND ((((t.wet - t.dry) / t.wet) * 100), 2) AS moisture,
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
            stragg (DISTINCT ii.stock_ref_no) AS stock_ref_no,
            NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
            stragg (DISTINCT gmr.gmr_ref_no) AS gmr_ref_no,
            SUM (gmr.qty) AS gmr_quality,
            pcpd.qty_max_val AS contract_quantity,
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge,INVS.INTERNAL_COMMENTS as internal_comments, pcm.is_self_billing, phd3.companyname AS smelter_location, ?
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
            cm_currency_master cm_pct,
            ak_corporate_user akuser,
            GAB_GLOBALADDRESSBOOK gab,
            AXS_ACTION_SUMMARY axs,
            IAM_INVOICE_ACTION_MAPPING iam,
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
        AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
        AND AXS.ACTION_ID != ''MODIFY_INVOICE''
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
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.notify_party_id = phd1.profileid(+)
        AND sd.notify_party_id = phd2.profileid(+)
        AND gmr.warehouse_profile_id = phd3.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND invs.invoice_cur_id = cm_pct.cur_id(+)
        AND pad.address_type(+) = ''Billing''
        AND pad.is_deleted(+) = ''N''
        AND pcpd.input_output IN (''Input'')
        AND t.internal_invoice_ref_no = invs.internal_invoice_ref_no
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
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.freight_allowance_amt,
            invs.invoice_adjustment_amount,
            invs.total_premium_amount,
            cm_pct.cur_code,
            akuser.login_name,
            t.dry,
            t.wet,
            pcm.is_self_billing,
            INVS.INTERNAL_COMMENTS,
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            phd3.companyname';
   fetchqryis_d_dcconc       CLOB
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
            pci.incoterm_location AS inco_term_location,
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
        AND invs.INVOICE_CUR_ID = cm.cur_id
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
            pci.incoterm_location,
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
   fetchqryis_d_siconc       CLOB
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
stragg(PCI.incoterm_location) as INCO_TERM_LOCATION,
stragg(nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME)) as NOTIFY_PARTY, 
stragg(distinct PCI.CONTRACT_TYPE) as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
invs.invoice_adjustment_amount As adjustment_amount,
(GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing as is_self_billing, F_STRING_AGGREGATE(phd3.companyname) AS smelter_location,
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
   fetchqryis_d_apiconc      CLOB
      := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, cp_item_stock_ref_no,
             inco_term_location, contract_ref_no, cp_contract_ref_no,
             contract_date, product, invoice_quantity, invoiced_qty_unit,
             quality, payment_term, due_date, invoice_creation_date,
             invoice_amount, invoice_amount_unit, invoice_ref_no,
             contract_type, invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, internal_comments,
             our_person_incharge, adjustment_amount, is_self_billing,
             internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         phd.companyname AS cp_name, pad.address AS cp_address,
         cym.country_name AS cp_country, cim.city_name AS cp_city,
         sm.state_name AS cp_state, pad.zip AS cp_zip,
         invs.cp_ref_no AS cp_item_stock_ref_no,
         (   itm.incoterm
           || '', ''
           || cim.city_name
           || '', ''
           || cym.country_name
          ) AS inco_term_location,
         pcm.contract_ref_no AS contract_ref_no,
         pcm.cp_contract_ref_no AS cp_contract_ref_no,
         TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') AS contract_date,
         pdm.product_desc AS product, invs.invoiced_qty AS invoice_quantity,
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
         (gab.firstname || '' '' || gab.lastname) AS our_person_incharge,
         invs.invoice_adjustment_amount AS adjustment_amount,
         pcm.is_self_billing AS is_self_billing, ?
    FROM is_invoice_summary invs,
         apid_adv_payment_item_details apid,
         pcm_physical_contract_main pcm,
         pci_physical_contract_item pci,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qat_quality_attributes qat,
         pcpd_pc_product_definition pcpd,
         pcpq_pc_product_quality pcpq,
         pcdb_pc_delivery_basis pcdb,
         itm_incoterm_master itm,
         cm_currency_master cm,
         pym_payment_terms_master pym,
         qum_quantity_unit_master qum,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         ak_corporate_user akuser,
         iam_invoice_action_mapping iam,
         axs_action_summary axs,
         gab_globaladdressbook gab,
         pad_profile_addresses pad,
         cym_countrymaster cym,
         cim_citymaster cim,
         sm_state_master sm
   WHERE invs.internal_invoice_ref_no = apid.internal_invoice_ref_no
     AND apid.contract_item_ref_no = pci.internal_contract_item_ref_no
     AND invs.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
     AND iam.invoice_action_ref_no = axs.internal_action_ref_no
     AND axs.action_id != ''MODIFY_INVOICE''
     AND axs.created_by = akuser.user_id
     AND akuser.gabid = gab.gabid
     AND pcpd.product_id = pdm.product_id
     AND pcpd.qty_unit_id = qum.qty_unit_id
     AND pcpd.input_output = ''Input''
     AND pci.pcpq_id = pcpq.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND invs.credit_term = pym.payment_term_id
     AND pci.pcdb_id = pcdb.pcdb_id
     AND pcdb.inco_term_id = itm.incoterm_id
     AND pcm.cp_id = phd.profileid(+)
     AND phd.profileid = pad.profile_id(+)
     AND pad.country_id = cym.country_id(+)
     AND pad.address_type(+) = ''Billing''
     AND pad.state_id = sm.state_id(+)
     AND pad.country_id = sm.country_id(+)
     AND pad.city_id = cim.city_id(+)
     AND pad.state_id = sm.state_id(+)
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
         pad.address,
         cym.country_name,
         cim.city_name,
         sm.state_name,
         pad.zip,
         pym.payment_term,
         itm.incoterm';
   fetchqryis_d_pficonc      CLOB
      := 'INSERT INTO pfi_d
            (internal_invoice_ref_no, invoice_ref_no, cp_name,
             cp_address, cp_country,
             cp_city, cp_state, cp_zip,
             inco_term_location, invoice_quantity, invoice_quantity_unit,
             invoice_amount, invoice_amount_unit, payment_term,
             cp_item_stock_ref_no, self_item_stock_ref_no, document_date,
             internal_comments, product, quality, notify_party,
             invoice_issue_date, origin, contract_type,
             invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, our_person_incharge, IS_INV_DRAFT, 
             internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            invs.invoice_ref_no AS invoice_ref_no, phd.companyname AS cp_name,
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip,
            stragg (pci.incoterm_location) AS inco_term_location,
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
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '''') AS our_person_incharge, INVS.IS_INV_DRAFT as IS_INV_DRAFT, ?
       FROM pfid_profoma_invoice_details pfid,
            is_invoice_summary invs,
            pcm_physical_contract_main pcm,
            v_pci pci,
            phd_profileheaderdetails phd,
            pad_profile_addresses pad,
            cym_countrymaster cym,
            cim_citymaster cim,
            sm_state_master sm,
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
        AND AXS.ACTION_ID != ''MODIFY_INVOICE''
        and AXS.CREATED_BY = AKUSER.USER_ID
        and AKUSER.GABID = GAB.GABID
        AND pcpd.input_output = ''Input''
        AND pcm.cp_id = phd.profileid(+)
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND PAD.ADDRESS_TYPE(+) = ''Billing''
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
            qum.qty_unit,
            INVS.IS_INV_DRAFT,
            pad.address, 
            cym.country_name,
            cim.city_name, 
            sm.state_name,
            pad.zip';
   fetchqryis_d_pi           CLOB
      := 'INSERT INTO is_d
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
             internal_comments, total_premium_amount, prov_percentage, PROVISIONAL_INVOICE_AMOUNT,
             adjustment_amount, our_person_incharge, is_self_billing, internal_doc_ref_no)
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.is_free_metal AS is_free_metal, invs.is_pledge AS is_pledge,
            invs.internal_comments AS internal_comments,
            invs.total_premium_amount AS premium_disc_amt,
            invs.provisional_pymt_pctg AS prov_percentage, INVS.PROV_PCTG_AMT as PROVISIONAL_INVOICE_AMOUNT,
            invs.invoice_adjustment_amount As adjustment_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing, 
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
            pci.incoterm_location,
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
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            INVS.PROV_PCTG_AMT';
   fetchqryis_d_dfi          CLOB
      := 'INSERT INTO is_d
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
             adjustment_amount, our_person_incharge, is_self_billing, internal_doc_ref_no)
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.is_free_metal AS is_free_metal, invs.is_pledge AS is_pledge,
            invs.internal_comments AS internal_comments,
            invs.total_premium_amount AS premium_disc_amt,
            invs.provisional_pymt_pctg AS prov_percentage,
            invs.invoice_adjustment_amount As adjustment_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing, 
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
            pci.incoterm_location,
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
            GAB.FIRSTNAME,
            GAB.LASTNAME';
   fetchqryis_d_fi           CLOB
      := 'INSERT INTO is_d
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
             adjustment_amount, our_person_incharge, is_self_billing, internal_doc_ref_no)
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.is_free_metal AS is_free_metal, invs.is_pledge AS is_pledge,
            invs.internal_comments AS internal_comments,
            invs.total_premium_amount AS premium_disc_amt,
            invs.provisional_pymt_pctg AS prov_percentage,
            invs.invoice_adjustment_amount As adjustment_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing, 
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
            pci.incoterm_location,
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
            GAB.FIRSTNAME,
            GAB.LASTNAME';
   fetchqryis_d_dc           CLOB
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
             our_person_incharge, internal_comments, is_self_billing, internal_doc_ref_no)
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
            stragg(ii.stock_ref_no) AS stock_ref_no,
            cm.cur_code AS invoice_amount_unit, stragg(gmr.gmr_ref_no) AS gmr_ref_no,
            sum(gmr.qty) AS gmr_quality, pcpd.qty_max_val AS contract_quantity,
            qum.qty_unit AS contract_qty_unit,
            pcpd.max_tolerance AS contract_tolerance,
            qat.quality_name AS quality, pdm.product_desc AS product,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            pym.payment_term AS payment_term,
            sum(gmr.final_weight) AS gmr_finalize_qty, phd.companyname AS cp_name,
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip, pcm.contract_type AS contract_type,
            cymloading.country_name AS origin,
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            NVL (akuser.login_name, '''') AS our_person_incharge, INVS.INTERNAL_COMMENTS as internal_comments, pcm.is_self_billing as IS_SELF_BILLING, ?
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
            qum_quantity_unit_master qum_gmr,
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND iid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND iid.invoicable_item_id = ii.invoicable_item_id
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.pcpd_id = pcpq.pcpd_id
        AND pci.quality_id = qat.quality_id
        AND pcpq.quality_template_id = qat.quality_id
        AND pcpd.product_id = pdm.product_id
        AND pcm.cp_id = phd.profileid
        AND INVS.CREDIT_TERM(+) = pym.payment_term_id
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
            cymloading.country_name,
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            akuser.login_name,
            invs.invoice_status,
            pcm.is_self_billing,
            INVS.INTERNAL_COMMENTS';
   fetchqryis_d_si           CLOB
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
stragg(PCI.incoterm_location) as INCO_TERM_LOCATION,
stragg(nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME)) as NOTIFY_PARTY, 
stragg(distinct PCI.CONTRACT_TYPE) as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
invs.invoice_adjustment_amount As adjustment_amount,
(GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing as is_self_billing,
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
AND invs.INVOICE_CUR_ID  = CM.CUR_ID
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
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED = ''N''
AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
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
   fetchqryis_d_api          CLOB
      := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, cp_item_stock_ref_no,
             inco_term_location, contract_ref_no, cp_contract_ref_no,
             contract_date, product, invoice_quantity, invoiced_qty_unit,
             quality, payment_term, due_date, invoice_creation_date,
             invoice_amount, invoice_amount_unit, invoice_ref_no,
             contract_type, invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, internal_comments,
             our_person_incharge, adjustment_amount, is_self_billing,
             internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         phd.companyname AS cp_name, pad.address AS cp_address,
         cym.country_name AS cp_country, cim.city_name AS cp_city,
         sm.state_name AS cp_state, pad.zip AS cp_zip,
         invs.cp_ref_no AS cp_item_stock_ref_no,
         (   itm.incoterm
           || '', ''
           || cim.city_name
           || '', ''
           || cym.country_name
          ) AS inco_term_location,
         pcm.contract_ref_no AS contract_ref_no,
         pcm.cp_contract_ref_no AS cp_contract_ref_no,
         TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') AS contract_date,
         pdm.product_desc AS product, invs.invoiced_qty AS invoice_quantity,
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
         (gab.firstname || '' '' || gab.lastname) AS our_person_incharge,
         invs.invoice_adjustment_amount AS adjustment_amount,
         pcm.is_self_billing AS is_self_billing, ?
    FROM is_invoice_summary invs,
         apid_adv_payment_item_details apid,
         pcm_physical_contract_main pcm,
         pci_physical_contract_item pci,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qat_quality_attributes qat,
         pcpd_pc_product_definition pcpd,
         pcpq_pc_product_quality pcpq,
         pcdb_pc_delivery_basis pcdb,
         itm_incoterm_master itm,
         cm_currency_master cm,
         pym_payment_terms_master pym,
         qum_quantity_unit_master qum,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         ak_corporate_user akuser,
         iam_invoice_action_mapping iam,
         axs_action_summary axs,
         gab_globaladdressbook gab,
         pad_profile_addresses pad,
         cym_countrymaster cym,
         cim_citymaster cim,
         sm_state_master sm
   WHERE invs.internal_invoice_ref_no = apid.internal_invoice_ref_no
     AND apid.contract_item_ref_no = pci.internal_contract_item_ref_no
     AND invs.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
     AND iam.invoice_action_ref_no = axs.internal_action_ref_no
     AND axs.action_id != ''MODIFY_INVOICE''
     AND axs.created_by = akuser.user_id
     AND akuser.gabid = gab.gabid
     AND pcpd.product_id = pdm.product_id
     AND pcpd.qty_unit_id = qum.qty_unit_id
     AND pcpd.input_output = ''Input''
     AND pci.pcpq_id = pcpq.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND invs.credit_term = pym.payment_term_id
     AND pci.pcdb_id = pcdb.pcdb_id
     AND pcdb.inco_term_id = itm.incoterm_id
     AND pcm.cp_id = phd.profileid(+)
     AND phd.profileid = pad.profile_id(+)
     AND pad.country_id = cym.country_id(+)
     AND pad.address_type(+) = ''Billing''
     AND pad.state_id = sm.state_id(+)
     AND pad.country_id = sm.country_id(+)
     AND pad.city_id = cim.city_id(+)
     AND pad.state_id = sm.state_id(+)
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
         pad.address,
         cym.country_name,
         cim.city_name,
         sm.state_name,
         pad.zip,
         pym.payment_term,
         itm.incoterm';
   fetchqrypfi_d_pfi         CLOB
      := 'INSERT INTO pfi_d
            (internal_invoice_ref_no, invoice_ref_no, cp_name,
             cp_address, cp_country,
             cp_city, cp_state, cp_zip,
             inco_term_location, invoice_quantity, invoice_quantity_unit,
             invoice_amount, invoice_amount_unit, payment_term,
             cp_item_stock_ref_no, self_item_stock_ref_no, document_date,
             internal_comments, product, quality, notify_party,
             invoice_issue_date, origin, contract_type,
             invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, our_person_incharge, IS_INV_DRAFT, 
             internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            invs.invoice_ref_no AS invoice_ref_no, phd.companyname AS cp_name,
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip,
            stragg (pci.incoterm_location) AS inco_term_location,
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
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '''') AS our_person_incharge, INVS.IS_INV_DRAFT as IS_INV_DRAFT, ?
       FROM pfid_profoma_invoice_details pfid,
            is_invoice_summary invs,
            pcm_physical_contract_main pcm,
            v_pci pci,
            phd_profileheaderdetails phd,
            pad_profile_addresses pad,
            cym_countrymaster cym,
            cim_citymaster cim,
            sm_state_master sm,
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
        AND AXS.ACTION_ID != ''MODIFY_INVOICE''
        and AXS.CREATED_BY = AKUSER.USER_ID
        and AKUSER.GABID = GAB.GABID
        AND pcpd.input_output = ''Input''
        AND pcm.cp_id = phd.profileid(+)
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
        AND PAD.ADDRESS_TYPE(+) = ''Billing''
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
            qum.qty_unit,
            INVS.IS_INV_DRAFT,
            pad.address, 
            cym.country_name,
            cim.city_name, 
            sm.state_name,
            pad.zip';
   fetchqryis_d_cfi          CLOB
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
IS_FREE_METAL,
IS_PLEDGE,
INTERNAL_COMMENTS,
IS_SELF_BILLING,
our_person_incharge,
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
PCI.incoterm_location as INCO_TERM_LOCATION,
nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME) as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_FREE_METAL as IS_FREE_METAL,
INVS.IS_PLEDGE as IS_PLEDGE,
INVS.INTERNAL_COMMENTS as INTERNAL_COMMENTS, pcm.is_self_billing as SELF_BILLING, (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) as our_person_incharge, phd3.companyname AS smelter_location,
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
phd_profileheaderdetails phd3,
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
and invs.INVOICE_CUR_ID = CM.CUR_ID
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
AND gmr.warehouse_profile_id = phd3.profileid(+)
and INVS.INVOICED_QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED(+) = ''N''
and PAD.ADDRESS_TYPE(+) = ''Billing''
and INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
and IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
AND AXS.ACTION_ID != ''MODIFY_INVOICE''
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
pci.incoterm_location,
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
GAB.LASTNAME,
phd3.companyname';
   fetchqryis_d_dftpiconc    CLOB
      := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_dry_quantity, invoice_wet_quantity, moisture,
             invoiced_qty_unit, internal_invoice_ref_no, invoice_amount,
             material_cost, addditional_charges, taxes, due_date,
             supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             freight_charge, adjustment_amount, total_premium_amount,
             our_person_incharge, internal_comments, is_self_billing,PROV_PERCENTAGE, IS_INV_DRAFT, internal_doc_ref_no)
   WITH TEST AS
        (SELECT   invs.internal_invoice_ref_no, SUM (asm.net_weight) AS wet,
                  SUM (asm.dry_weight) AS dry
             FROM is_invoice_summary invs,
                  ash_assay_header ash,
                  asm_assay_sublot_mapping asm,
                  iam_invoice_assay_mapping iam
            WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
              AND iam.ash_id = ash.ash_id
              AND ash.ash_id = asm.ash_id
         GROUP BY invs.internal_invoice_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            t.dry AS invoice_dry_quantity, t.wet AS invoice_wet_quantity,
            ROUND ((((t.wet - t.dry) / t.wet) * 100), 2) AS moisture,
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
            stragg (DISTINCT ii.stock_ref_no) AS stock_ref_no,
            NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
            stragg (DISTINCT gmr.gmr_ref_no) AS gmr_ref_no,
            SUM (gmr.qty) AS gmr_quality,
            pcpd.qty_max_val AS contract_quantity,
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge,INVS.INTERNAL_COMMENTS as internal_comments, pcm.is_self_billing,INVS.PROV_PCTG_AMT,
            INVS.IS_INV_DRAFT, ?
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
            qum_quantity_unit_master qum_gmr,
            cm_currency_master cm_pct,
            ak_corporate_user akuser,
            GAB_GLOBALADDRESSBOOK gab,
            AXS_ACTION_SUMMARY axs,
            IAM_INVOICE_ACTION_MAPPING iam,
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
        AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
        AND AXS.ACTION_ID != ''MODIFY_INVOICE''
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
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.notify_party_id = phd1.profileid(+)
        AND sd.notify_party_id = phd2.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND invs.invoice_cur_id = cm_pct.cur_id(+)
        AND pad.address_type(+) = ''Billing''
        AND pad.is_deleted(+) = ''N''
        AND pcpd.input_output IN (''Input'')
        AND t.internal_invoice_ref_no = invs.internal_invoice_ref_no
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
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.freight_allowance_amt,
            invs.invoice_adjustment_amount,
            invs.total_premium_amount,
            cm_pct.cur_code,
            akuser.login_name,
            t.dry,
            t.wet,
            pcm.is_self_billing,
            INVS.INTERNAL_COMMENTS,
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            INVS.PROV_PCTG_AMT,
            IS_INV_DRAFT';
   fetchqryis_d_dftdficonc   CLOB
      := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_dry_quantity, invoice_wet_quantity, moisture,
             invoiced_qty_unit, internal_invoice_ref_no, invoice_amount,
             material_cost, addditional_charges, taxes, due_date,
             supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             freight_charge, adjustment_amount, total_premium_amount,
             our_person_incharge, internal_comments, is_self_billing,PROV_PERCENTAGE, IS_INV_DRAFT, internal_doc_ref_no)
   WITH TEST AS
        (SELECT   invs.internal_invoice_ref_no, SUM (asm.net_weight) AS wet,
                  SUM (asm.dry_weight) AS dry
             FROM is_invoice_summary invs,
                  ash_assay_header ash,
                  asm_assay_sublot_mapping asm,
                  iam_invoice_assay_mapping iam
            WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
              AND iam.ash_id = ash.ash_id
              AND ash.ash_id = asm.ash_id
         GROUP BY invs.internal_invoice_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            t.dry AS invoice_dry_quantity, t.wet AS invoice_wet_quantity,
            ROUND ((((t.wet - t.dry) / t.wet) * 100), 2) AS moisture,
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
            stragg (DISTINCT ii.stock_ref_no) AS stock_ref_no,
            NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
            stragg (DISTINCT gmr.gmr_ref_no) AS gmr_ref_no,
            SUM (gmr.qty) AS gmr_quality,
            pcpd.qty_max_val AS contract_quantity,
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge,INVS.INTERNAL_COMMENTS as internal_comments, pcm.is_self_billing,INVS.PROV_PCTG_AMT,
            INVS.IS_INV_DRAFT, ?
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
            qum_quantity_unit_master qum_gmr,
            cm_currency_master cm_pct,
            ak_corporate_user akuser,
            GAB_GLOBALADDRESSBOOK gab,
            AXS_ACTION_SUMMARY axs,
            IAM_INVOICE_ACTION_MAPPING iam,
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
        AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
        AND AXS.ACTION_ID != ''MODIFY_INVOICE''
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
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.notify_party_id = phd1.profileid(+)
        AND sd.notify_party_id = phd2.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND invs.invoice_cur_id = cm_pct.cur_id(+)
        AND pad.address_type(+) = ''Billing''
        AND pad.is_deleted(+) = ''N''
        AND pcpd.input_output IN (''Input'')
        AND t.internal_invoice_ref_no = invs.internal_invoice_ref_no
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
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.freight_allowance_amt,
            invs.invoice_adjustment_amount,
            invs.total_premium_amount,
            cm_pct.cur_code,
            akuser.login_name,
            t.dry,
            t.wet,
            pcm.is_self_billing,
            INVS.INTERNAL_COMMENTS,
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            INVS.PROV_PCTG_AMT,
            IS_INV_DRAFT';
   fetchqryis_d_dftficonc    CLOB
      := 'INSERT INTO is_d
            (invoice_ref_no, invoice_type_name, invoice_creation_date,
             invoice_dry_quantity, invoice_wet_quantity, moisture,
             invoiced_qty_unit, internal_invoice_ref_no, invoice_amount,
             material_cost, addditional_charges, taxes, due_date,
             supplire_invoice_no, contract_date, contract_ref_no,
             stock_quantity, stock_ref_no, invoice_amount_unit, gmr_ref_no,
             gmr_quality, contract_quantity, contract_qty_unit,
             contract_tolerance, quality, product, cp_contract_ref_no,
             payment_term, gmr_finalize_qty, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, contract_type, origin,
             inco_term_location, notify_party, sales_purchase, invoice_status,
             freight_charge, adjustment_amount, total_premium_amount,
             our_person_incharge, internal_comments, is_self_billing,PROV_PERCENTAGE, IS_INV_DRAFT, internal_doc_ref_no)
   WITH TEST AS
        (SELECT   invs.internal_invoice_ref_no, SUM (asm.net_weight) AS wet,
                  SUM (asm.dry_weight) AS dry
             FROM is_invoice_summary invs,
                  ash_assay_header ash,
                  asm_assay_sublot_mapping asm,
                  iam_invoice_assay_mapping iam
            WHERE invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
              AND iam.ash_id = ash.ash_id
              AND ash.ash_id = asm.ash_id
         GROUP BY invs.internal_invoice_ref_no)
   SELECT   invs.invoice_ref_no AS invoice_ref_no,
            invs.invoice_type_name AS invoice_type_name,
            invs.invoice_issue_date AS invoice_creation_date,
            t.dry AS invoice_dry_quantity, t.wet AS invoice_wet_quantity,
            ROUND ((((t.wet - t.dry) / t.wet) * 100), 2) AS moisture,
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
            stragg (DISTINCT ii.stock_ref_no) AS stock_ref_no,
            NVL (cm_pct.cur_code, cm.cur_code) AS invoice_amount_unit,
            stragg (DISTINCT gmr.gmr_ref_no) AS gmr_ref_no,
            SUM (gmr.qty) AS gmr_quality,
            pcpd.qty_max_val AS contract_quantity,
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            (GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge,INVS.INTERNAL_COMMENTS as internal_comments, pcm.is_self_billing,INVS.PROV_PCTG_AMT,
            INVS.IS_INV_DRAFT, ?
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
            qum_quantity_unit_master qum_gmr,
            cm_currency_master cm_pct,
            ak_corporate_user akuser,
            GAB_GLOBALADDRESSBOOK gab,
            AXS_ACTION_SUMMARY axs,
            IAM_INVOICE_ACTION_MAPPING iam,
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND INVS.INTERNAL_INVOICE_REF_NO = IAM.INTERNAL_INVOICE_REF_NO
        AND IAM.INVOICE_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
        AND AXS.ACTION_ID != ''MODIFY_INVOICE''
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
        AND cymloading.country_id(+) = gmr.loading_country_id
        AND gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no(+)
        AND gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
        AND sad.notify_party_id = phd1.profileid(+)
        AND sd.notify_party_id = phd2.profileid(+)
        AND gmr.qty_unit_id = qum_gmr.qty_unit_id(+)
        AND invs.invoice_cur_id = cm_pct.cur_id(+)
        AND pad.address_type(+) = ''Billing''
        AND pad.is_deleted(+) = ''N''
        AND pcpd.input_output IN (''Input'')
        AND t.internal_invoice_ref_no = invs.internal_invoice_ref_no
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
            gmr.final_weight,
            phd.companyname,
            pad.address,
            cym.country_name,
            cim.city_name,
            sm.state_name,
            pad.zip,
            pcm.contract_type,
            cymloading.country_name,
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.freight_allowance_amt,
            invs.invoice_adjustment_amount,
            invs.total_premium_amount,
            cm_pct.cur_code,
            akuser.login_name,
            t.dry,
            t.wet,
            pcm.is_self_billing,
            INVS.INTERNAL_COMMENTS,
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            INVS.PROV_PCTG_AMT,
            IS_INV_DRAFT';
   fetchqryis_d_dftdcconc    CLOB
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
             our_person_incharge, internal_comments, is_self_billing,is_inv_draft, internal_doc_ref_no)
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
            stragg(ii.stock_ref_no) AS stock_ref_no,
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            NVL (akuser.login_name, '' '') AS our_person_incharge, INVS.INTERNAL_COMMENTS as internal_comments,pcm.is_self_billing as is_self_billing,INVS.IS_INV_DRAFT as is_inv_draft, ?
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
            qum_quantity_unit_master qum_gmr,
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND iid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND iid.invoicable_item_id = ii.invoicable_item_id
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.pcpd_id = pcpq.pcpd_id
        AND pci.quality_id = qat.quality_id
        AND pcpq.quality_template_id = qat.quality_id
        AND pcpd.product_id = pdm.product_id
        AND pcm.cp_id = phd.profileid
        AND INVS.CREDIT_TERM(+) = pym.payment_term_id
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
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            akuser.login_name,
            invs.invoice_status,
            INVS.INTERNAL_COMMENTS, 
            pcm.is_self_billing,
            INVS.IS_INV_DRAFT';
   fetchqryis_d_dftsiconc    CLOB
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
stragg(PCI.incoterm_location) as INCO_TERM_LOCATION,
stragg(nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME)) as NOTIFY_PARTY, 
stragg(distinct PCI.CONTRACT_TYPE) as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
invs.invoice_adjustment_amount As adjustment_amount,
(GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing as is_self_billing,
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
and invs.INVOICE_CUR_ID = CM.CUR_ID
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
   fetchqryis_d_dftapiconc   CLOB
      := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_address, cp_country,
                cp_city, cp_state, cp_zip, cp_item_stock_ref_no,
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
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip,
            invs.cp_ref_no AS cp_item_stock_ref_no,
            pci.incoterm_location AS inco_term_location,
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
            gab_globaladdressbook gab,
            pad_profile_addresses pad,
            cym_countrymaster cym,
            cim_citymaster cim,
            sm_state_master sm
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
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        and PAD.ADDRESS_TYPE(+) = ''Billing''
        AND PAD.STATE_ID = SM.STATE_ID(+)
        and PAD.COUNTRY_ID = SM.COUNTRY_ID(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
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
            pci.incoterm_location,
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
            invs.is_inv_draft,
            pad.address, 
            cym.country_name,
            cim.city_name, 
            sm.state_name,
            pad.zip';
   fetchqryis_d_dftpi        CLOB
      := 'INSERT INTO is_d
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
             internal_comments, total_premium_amount, prov_percentage, PROVISIONAL_INVOICE_AMOUNT,
             adjustment_amount, our_person_incharge, is_self_billing, IS_INV_DRAFT, internal_doc_ref_no)
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.is_free_metal AS is_free_metal, invs.is_pledge AS is_pledge,
            invs.internal_comments AS internal_comments,
            invs.total_premium_amount AS premium_disc_amt,
            invs.provisional_pymt_pctg AS prov_percentage, INVS.PROV_PCTG_AMT as PROVISIONAL_INVOICE_AMOUNT,
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
            pci.incoterm_location,
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
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            INVS.PROV_PCTG_AMT,
            INVS.IS_INV_DRAFT';
   fetchqryis_d_dftdfi       CLOB
      := 'INSERT INTO is_d
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
            pci.incoterm_location AS inco_term_location,
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
            pci.incoterm_location,
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
   fetchqryis_d_dftfi        CLOB
      := 'INSERT INTO is_d
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
            pci.incoterm_location AS inco_term_location,
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
            pci.incoterm_location,
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
   fetchqryis_d_dftdc        CLOB
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
             our_person_incharge, internal_comments, is_self_billing,is_inv_draft, internal_doc_ref_no)
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
            stragg(ii.stock_ref_no) AS stock_ref_no,
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
            pci.incoterm_location AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            NVL (akuser.login_name, '' '') AS our_person_incharge, INVS.INTERNAL_COMMENTS as internal_comments,pcm.is_self_billing as is_self_billing,INVS.IS_INV_DRAFT as is_inv_draft, ?
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
            qum_quantity_unit_master qum_gmr,
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND iid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND iid.invoicable_item_id = ii.invoicable_item_id
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND invs.INVOICE_CUR_ID = cm.cur_id
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.pcpd_id = pcpq.pcpd_id
        AND pci.quality_id = qat.quality_id
        AND pcpq.quality_template_id = qat.quality_id
        AND pcpd.product_id = pdm.product_id
        AND pcm.cp_id = phd.profileid
        AND INVS.CREDIT_TERM(+) = pym.payment_term_id
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
            pci.incoterm_location,
            phd1.companyname,
            phd2.companyname,
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            akuser.login_name,
            invs.invoice_status,
            INVS.INTERNAL_COMMENTS, 
            pcm.is_self_billing,
            INVS.IS_INV_DRAFT';
   fetchqryis_d_dftsi        CLOB
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
stragg(PCI.incoterm_location) as INCO_TERM_LOCATION,
stragg(nvl(PHD1.COMPANYNAME, PHD2.COMPANYNAME)) as NOTIFY_PARTY, 
stragg(distinct PCI.CONTRACT_TYPE) as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
invs.invoice_adjustment_amount As adjustment_amount,
(GAB.FIRSTNAME||'' ''||GAB.LASTNAME) AS our_person_incharge, pcm.is_self_billing as is_self_billing,
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
and invs.INVOICE_CUR_ID = CM.CUR_ID
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
   fetchqryis_d_dftapi       CLOB
      := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_address, cp_country,
                cp_city, cp_state, cp_zip, cp_item_stock_ref_no,
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
            pad.address AS cp_address, cym.country_name AS cp_country,
            cim.city_name AS cp_city, sm.state_name AS cp_state,
            pad.zip AS cp_zip,
            invs.cp_ref_no AS cp_item_stock_ref_no,
            pci.incoterm_location AS inco_term_location,
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
            gab_globaladdressbook gab,
            pad_profile_addresses pad,
            cym_countrymaster cym,
            cim_citymaster cim,
            sm_state_master sm
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
        AND phd.profileid = pad.profile_id(+)
        AND pad.country_id = cym.country_id(+)
        and PAD.ADDRESS_TYPE(+) = ''Billing''
        AND PAD.STATE_ID = SM.STATE_ID(+)
        and PAD.COUNTRY_ID = SM.COUNTRY_ID(+)
        AND pad.city_id = cim.city_id(+)
        AND pad.state_id = sm.state_id(+)
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
            pci.incoterm_location,
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
            invs.is_inv_draft,
            pad.address, 
            cym.country_name,
            cim.city_name, 
            sm.state_name,
            pad.zip';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_piconc
    WHERE dgm.dgm_id = 'DGM-PIC'
      AND dgm.doc_id = 'CREATE_PI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dficonc
    WHERE dgm.dgm_id = 'DGM-DFIC'
      AND dgm.doc_id = 'CREATE_DFI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_ficonc
    WHERE dgm.dgm_id = 'DGM-FIC'
      AND dgm.doc_id = 'CREATE_FI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dcconc
    WHERE dgm.dgm_id = 'DGM-DC-CONC'
      AND dgm.doc_id = 'CREATE_DC'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_siconc
    WHERE dgm.dgm_id = 'DGM-SIC'
      AND dgm.doc_id = 'CREATE_SI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_apiconc
    WHERE dgm.dgm_id = 'DGM-API-1-1-CONC'
      AND dgm.doc_id = 'CREATE_API'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_pficonc
    WHERE dgm.dgm_id = 'DGM-PFI-1-CONC'
      AND dgm.doc_id = 'CREATE_PFI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_pi
    WHERE dgm.dgm_id = '11'
      AND dgm.doc_id = 'CREATE_PI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dfi
    WHERE dgm.dgm_id = '12'
      AND dgm.doc_id = 'CREATE_DFI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_fi
    WHERE dgm.dgm_id = '10'
      AND dgm.doc_id = 'CREATE_FI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dc
    WHERE dgm.dgm_id = 'DGM-DC'
      AND dgm.doc_id = 'CREATE_DC'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_si
    WHERE dgm.dgm_id = 'DGM-SI'
      AND dgm.doc_id = 'CREATE_SI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_api
    WHERE dgm.dgm_id = 'DGM-API-1-1'
      AND dgm.doc_id = 'CREATE_API'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqrypfi_d_pfi
    WHERE dgm.dgm_id = 'DGM-PFI-1'
      AND dgm.doc_id = 'CREATE_PFI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_cfi
    WHERE dgm.dgm_id = 'CREATE_CFI'
      AND dgm.doc_id = 'CREATE_CFI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftpiconc
    WHERE dgm.dgm_id = 'CREATE_DFT_PIC_1'
      AND dgm.doc_id = 'CREATE_DFT_PI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftdficonc
    WHERE dgm.dgm_id = 'CREATE_DFT_DFIC_1'
      AND dgm.doc_id = 'CREATE_DFT_DFI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftficonc
    WHERE dgm.dgm_id = 'CREATE_DFT_FIC_1'
      AND dgm.doc_id = 'CREATE_DFT_FI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftdcconc
    WHERE dgm.dgm_id = 'DGM-DFT-DC-CONC'
      AND dgm.doc_id = 'CREATE_DFT_DC'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftsiconc
    WHERE dgm.dgm_id = 'DGM-DFT-SIC'
      AND dgm.doc_id = 'CREATE_DFT_SI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftapiconc
    WHERE dgm.dgm_id = 'CREATE_DFT_APIC_1'
      AND dgm.doc_id = 'CREATE_DFT_API'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'Y';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftpi
    WHERE dgm.dgm_id = 'DGM-DFT-PI'
      AND dgm.doc_id = 'CREATE_DFT_PI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftdfi
    WHERE dgm.dgm_id = '12'
      AND dgm.doc_id = 'CREATE_DFT_DFI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftfi
    WHERE dgm.dgm_id = 'DGM-DFT-FI-ISD'
      AND dgm.doc_id = 'CREATE_DFT_FI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftdc
    WHERE dgm.dgm_id = 'DGM-DFT-DC'
      AND dgm.doc_id = 'CREATE_DFT_DC'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftsi
    WHERE dgm.dgm_id = 'DGM-DFT-SI'
      AND dgm.doc_id = 'CREATE_DFT_SI'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_d_dftapi
    WHERE dgm.dgm_id = 'CREATE_DFT_API_1'
      AND dgm.doc_id = 'CREATE_DFT_API'
      AND dgm.sequence_order = 1
      AND dgm.is_concentrate = 'N';
   COMMIT;
END;