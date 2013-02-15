declare

fetchQryBM CLOB := 'INSERT INTO is_d
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
             adjustment_amount, our_person_incharge, internal_doc_ref_no)
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
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '') AS our_person_incharge, ?
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
            GAB_GLOBALADDRESSBOOK gab
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.invoice_currency_id = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND PCM.OUR_PERSON_IN_CHARGE_ID = AKUSER.USER_ID(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id(+)
        AND pcpd.pcpd_id = pcpq.pcpd_id(+)
        AND pci.quality_id = qat.quality_id(+)
        AND pcpd.product_id = pdm.product_id(+)
        AND invs.cp_id = phd.profileid(+)
        AND pcm.payment_term_id = pym.payment_term_id(+)
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
        and AKUSER.GABID = GAB.GABID(+)
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
            qum_gmr.qty_unit,
            pci.contract_type,
            invs.amount_to_pay_before_adj,
            invs.invoice_status,
            invs.is_free_metal,
            invs.is_pledge,
            invs.internal_comments,
            invs.provisional_pymt_pctg,
            invs.total_premium_amount,
            invs.invoice_adjustment_amount,
            GAB.FIRSTNAME,
            GAB.LASTNAME';

fetchQryConcforFIs CLOB := 'INSERT INTO is_d
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
             our_person_incharge, internal_doc_ref_no)
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
            pci.terms AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '') AS our_person_incharge, ?
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
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.invoice_currency_id = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id(+)
        AND pcpd.pcpd_id = pcpq.pcpd_id(+)
        AND pci.quality_id = qat.quality_id(+)
        AND pcpd.product_id = pdm.product_id(+)
        AND invs.cp_id = phd.profileid(+)
        AND pcm.payment_term_id = pym.payment_term_id(+)
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
        and AKUSER.GABID = GAB.GABID(+)
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
            pci.terms,
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
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            t.dry,
            t.wet';

fetchQryConcforPIs clob := 'INSERT INTO is_d
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
             prov_percentage, our_person_incharge, internal_doc_ref_no)
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
            pci.terms AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            invs.freight_allowance_amt AS freight_charge,
            invs.invoice_adjustment_amount AS adjustment_amount,
            invs.total_premium_amount AS total_premium_amount,
            invs.provisional_pymt_pctg AS prov_percentage,
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '') AS our_person_incharge, ?
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
            TEST t
      WHERE invs.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
        AND iid.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
        AND iid.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
        AND iid.invoicable_item_id = ii.invoicable_item_id(+)
        AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.invoice_currency_id = cm.cur_id(+)
        AND ii.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
        AND pcm.our_person_in_charge_id = akuser.user_id(+)
        AND pcpd.qty_unit_id = qum.qty_unit_id(+)
        AND pcpd.pcpd_id = pcpq.pcpd_id(+)
        AND pci.quality_id = qat.quality_id(+)
        AND pcpd.product_id = pdm.product_id(+)
        AND invs.cp_id = phd.profileid(+)
        AND pcm.payment_term_id = pym.payment_term_id(+)
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
        and AKUSER.GABID = GAB.GABID(+)
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
            pci.terms,
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
            invs.provisional_pymt_pctg,
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            t.dry,
            t.wet';

fetchQryDC CLOB := 'INSERT INTO is_d
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
             our_person_incharge, internal_doc_ref_no)
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
            pci.terms AS inco_term_location,
            NVL (phd1.companyname, phd2.companyname) AS notify_party,
            pci.contract_type AS sales_purchase,
            invs.invoice_status AS invoice_status,
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '') AS our_person_incharge, ?
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
            ak_corporate_user akuser,
            GAB_GLOBALADDRESSBOOK gab
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
        AND pcm.payment_term_id = pym.payment_term_id
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
        and AKUSER.GABID = GAB.GABID(+)
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
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            invs.invoice_status';

fetchQryAPI CLOB := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_item_stock_ref_no,
             inco_term_location, contract_ref_no, cp_contract_ref_no,
             contract_date, product, invoice_quantity, invoiced_qty_unit,
             quality, payment_term, due_date, invoice_creation_date,
             invoice_amount, invoice_amount_unit, invoice_ref_no,
             contract_type, invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, internal_comments,
             our_person_incharge, internal_doc_ref_no)
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
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '') AS our_person_incharge, ?
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
            GAB_GLOBALADDRESSBOOK gab
      WHERE invs.internal_invoice_ref_no = apid.internal_invoice_ref_no
        AND apid.contract_item_ref_no = pci.internal_contract_item_ref_no
        AND invs.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND pcm.internal_contract_ref_no = akuser.user_id(+)
        AND pcpd.product_id = pdm.product_id
        AND pcpd.qty_unit_id = qum.qty_unit_id
        and AKUSER.GABID = GAB.GABID(+)
        AND pcpd.input_output = ''Input''
        AND pci.quality_id = qat.quality_id
        AND pcm.cp_id = phd.profileid(+)
        AND invs.invoice_cur_id = cm.cur_id
        AND pcm.payment_term_id = pym.payment_term_id
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
            GAB.FIRSTNAME,
            GAB.LASTNAME,
            invs.internal_comments';            

fetchQryPFI clob := 'INSERT INTO pfi_d
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
            NVL (GAB.FIRSTNAME||'' ''||GAB.LASTNAME, '') AS our_person_incharge, ?
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
            GAB_GLOBALADDRESSBOOK gab
      WHERE invs.internal_invoice_ref_no = pfid.internal_invoice_ref_no
        AND pfid.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
        AND pcm.internal_contract_ref_no = invs.internal_contract_ref_no
        AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND pcm.internal_contract_ref_no = akuser.user_id(+)
        AND pcpd.product_id = pdm.product_id
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pci.quality_id = qat.quality_id
        and AKUSER.GABID = GAB.GABID(+)
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
    --For Base Metal PI, FI, DFI and DC 
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryBM where DGM.DOC_ID IN ('CREATE_DFI','CREATE_FI','CREATE_PI') and DGM.IS_CONCENTRATE = 'N' and DGM.SEQUENCE_ORDER = 1;
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryDC where DGM.DOC_ID IN ('CREATE_DC') and DGM.IS_CONCENTRATE = 'N' and DGM.SEQUENCE_ORDER = 1;
    --For Concentrates PI, FI, DFI and DC 
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryConcforFIs where DGM.DOC_ID IN ('CREATE_DFI','CREATE_FI') and DGM.IS_CONCENTRATE = 'Y' and DGM.SEQUENCE_ORDER = 1;
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryConcforPIs where DGM.DOC_ID IN ('CREATE_PI') and DGM.IS_CONCENTRATE = 'Y' and DGM.SEQUENCE_ORDER = 1;
    --For Both Base Metal & Concentrates PI, FI, DFI and DC 
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryAPI where DGM.DOC_ID IN ('CREATE_API') and DGM.SEQUENCE_ORDER = 1;
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryPFI where DGM.DOC_ID IN ('CREATE_PFI') and DGM.SEQUENCE_ORDER = 1;
    commit;
end;