CREATE OR REPLACE VIEW v_doc_invoice
AS
   WITH separate_vat_info AS
        (SELECT vpcm.internal_invoice_ref_no, ivd.cp_vat_no, ivd.our_vat_no
           FROM vpcm_vat_parent_child_map vpcm, ivd_invoice_vat_details ivd
          WHERE vpcm.vat_internal_invoice_ref_no = ivd.internal_invoice_ref_no
            AND ivd.is_separate_invoice = 'Y')
   SELECT 'Invoice' section_name, 'Invoice' sub_section, ds.corporate_id,
          akc.logo_path, akc.address1, akc.address2, akc.city, akc.state,
          akc.country, akc.phone_no, akc.fax_no, akc.visiting_address,
          akc.organisation_no, akc.foot_note, akc.address_name,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
          
          -- Payable Details
          (CASE
              WHEN (   isd.is_free_metal = 'Y'
                    OR isd.is_pledge = 'Y'
                    OR isd.contract_type = 'BASEMETAL'
                   )
                 THEN NVL (iscd.product, isd.product)
              ELSE iscp.element_name
           END
          ) metal,
          (CASE
              WHEN (   isd.is_free_metal = 'Y'
                    OR isd.is_pledge = 'Y'
                    OR isd.contract_type = 'BASEMETAL'
                   )
                 THEN iscd.stock_ref_no
              ELSE iscp.stock_ref_no
           END
          ) stock_ref_no_lot_no,
          iscp.dry_quantity dry_qty, iscp.gmr_qty_unit dry_qty_unit,
             iscp.sub_lot_no
          || ' : '
          || iscp.assay_content
          || ' '
          || iscp.assay_content_unit assay_details,
          iscp.net_payable net_payable_percentage,
          iscp.assay_content_unit net_payable_percentage_unit,
          (CASE
              WHEN (   isd.is_free_metal = 'Y'
                    OR isd.is_pledge = 'Y'
                    OR isd.contract_type = 'BASEMETAL'
                   )
                 THEN (CASE
                          WHEN iscd.total_price_qty IS NULL
                           OR iscd.total_price_qty = ''
                             THEN 0
                          ELSE TO_NUMBER (iscd.total_price_qty)
                       END
                      )
              ELSE (CASE
                       WHEN iscp.element_invoiced_qty IS NULL
                        OR iscp.element_invoiced_qty = ''
                          THEN 0
                       ELSE TO_NUMBER (iscp.element_invoiced_qty)
                    END
                   )
           END
          ) payable_penalty_qty,
          (CASE
              WHEN (   isd.is_free_metal = 'Y'
                    OR isd.is_pledge = 'Y'
                    OR isd.contract_type = 'BASEMETAL'
                   )
                 THEN iscd.invoiced_qty_unit
              ELSE iscp.element_invoiced_qty_unit
           END
          ) payable_penalty_qty_unit,
          (CASE
              WHEN (   isd.is_free_metal = 'Y'
                    OR isd.is_pledge = 'Y'
                    OR isd.contract_type = 'BASEMETAL'
                   )
                 THEN (CASE
                          WHEN iscd.price_as_per_defind_uom IS NULL
                           OR iscd.price_as_per_defind_uom = ''
                             THEN 0
                          ELSE TO_NUMBER (iscd.price_as_per_defind_uom)
                       END
                      )
              ELSE (CASE
                       WHEN iscp.invoice_price IS NULL
                        OR iscp.invoice_price = ''
                          THEN 0
                       ELSE TO_NUMBER (iscp.invoice_price)
                    END
                   )
           END
          ) price,
          (CASE
              WHEN (   isd.is_free_metal = 'Y'
                    OR isd.is_pledge = 'Y'
                    OR isd.contract_type = 'BASEMETAL'
                   )
                 THEN iscd.invoiced_price_unit
              ELSE iscp.element_price_unit
           END
          ) price_unit,
          (CASE
              WHEN (   isd.is_free_metal = 'Y'
                    OR isd.is_pledge = 'Y'
                    OR isd.contract_type = 'BASEMETAL'
                   )
                 THEN (CASE
                          WHEN iscd.item_amount_in_inv_cur IS NULL
                           OR iscd.item_amount_in_inv_cur = ''
                             THEN 0
                          ELSE TO_NUMBER (iscd.item_amount_in_inv_cur)
                       END
                      )
              ELSE (CASE
                       WHEN iscp.element_inv_amount IS NULL
                        OR iscp.element_inv_amount = ''
                          THEN 0
                       ELSE TO_NUMBER (iscp.element_inv_amount)
                    END
                   )
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL mositure, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          
          -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd,
          is_conc_payable_child iscp,
          ds_document_summary ds,
          v_ak_corporate akc,
          is_child_d iscd
    WHERE isd.internal_doc_ref_no = iscp.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
      AND isd.internal_doc_ref_no = iscd.internal_doc_ref_no(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'GMR' sub_section, ds.corporate_id,
          akc.logo_path, akc.address1, akc.address2, akc.city, akc.state,
          akc.country, akc.phone_no, akc.fax_no, akc.visiting_address,
          akc.organisation_no, akc.foot_note, akc.address_name,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
          
          -- Delivery Details
          igd.gmr_ref_no igd_gmr_ref_no,
             igd.container_name
          || (CASE
                 WHEN igd.mode_of_transport = ''
                    THEN ''
                 ELSE ', ' || igd.mode_of_transport
              END
             ) igd_container_name,
          igd.bl_date igd_bl_date,
          igd.origin_city || ', ' || igd.origin_country igd_origin,
          igd.wet_qty igd_wet_qty,
          igd.wet_qty_unit_name igd_wet_qty_unit_name,
          igd.moisture igd_moisture,
          igd.moisture_unit_name igd_moisture_unit_name,
          igd.dry_qty igd_dry_qty,
          igd.dry_qty_unit_name igd_dry_qty_unit_name,
                                                      -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount_unit IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,                   -- Need
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL mositure, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, vat.fx_rate_vc_ic fx_rate,
          vat.vat_amount_in_vat_cur amount_in_charge_tax_vat_ccy,
          NULL charge_tax_vat_ccy,
                                  -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NVL2 (vat.internal_invoice_ref_no,
                vat.our_vat_no,
                svi.our_vat_no
               ) our_vat_reg_no,
          NVL2 (vat.internal_invoice_ref_no,
                vat.cp_vat_no,
                svi.cp_vat_no
               ) cp_vat_reg_no,
          vat.main_inv_vat_code vat_code, vat.vat_text, vat.vat_rate,
          vat.vat_amount_in_inv_cur vat_amount,
                                               -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd,
          igd_inv_gmr_details_d igd,
          ds_document_summary ds,
          v_ak_corporate akc,
          ivd_invoice_vat_details vat,
          separate_vat_info svi                                    /*,
                                              cm_currency_master      vat_cm*/
    WHERE isd.internal_doc_ref_no = igd.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
      AND isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
      AND vat.is_separate_invoice(+) = 'N'
      AND isd.internal_invoice_ref_no = svi.internal_invoice_ref_no(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'Treatment Charge' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          akc.visiting_address, akc.organisation_no, akc.foot_note,
          akc.address_name, isd.internal_doc_ref_no,
          isd.internal_invoice_ref_no,
                                      -- Summary Header Details
                                      isd.invoice_ref_no invoice_no,
          isd.invoice_type_name invoice_type, isd.cp_contract_ref_no,
          isd.contract_ref_no our_contract_ref_no, akc.corporate_name,
          isd.cp_name, isd.sales_purchase, isd.product, isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
                                     ictc.element_name metal,
          ictc.stock_ref_no stock_ref_no_lot_no, ictc.dry_quantity dry_qty,
          ictc.quantity_unit_name dry_qty_unit, ictc.sub_lot_no assay_details,
          NULL net_payable_percentage, NULL net_payable_percentage_unit,
          NULL payable_penalty_qty, NULL payable_penalty_qty_unit, NULL price,
          NULL price_unit,
          (CASE
              WHEN ictc.tc_amount IS NULL OR ictc.tc_amount = ''
                 THEN 0
              ELSE TO_NUMBER (ictc.tc_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,
          
          -- TC Details
          ictc.wet_quantity wet_qty, ictc.quantity_unit_name wet_qty_unit,
          ictc.moisture, '%' moisture_unit,
          (CASE
              WHEN NVL (ictc.baseescdesc_type, 'NA') IN
                                                     ('Fixed', 'Assay', 'NA')
                 THEN ''
              ELSE ictc.base_tc
           END
          ) fixed_tc_amount,
          isd.invoice_amount_unit fixed_tc_amount_unit,
          (CASE
              WHEN NVL (ictc.baseescdesc_type, 'NA') IN
                                                     ('Fixed', 'Assay', 'NA')
                 THEN ''
              ELSE ictc.esc_desc_amount
           END
          ) escalator_descalator,
          
          -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          
          -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, ictc.baseescdesc_type
     FROM is_d isd,
          is_conc_tc_child ictc,
          ds_document_summary ds,
          v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = ictc.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'Refining Charge' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          akc.visiting_address, akc.organisation_no, akc.foot_note,
          akc.address_name, isd.internal_doc_ref_no,
          isd.internal_invoice_ref_no,
                                      -- Summary Header Details
                                      isd.invoice_ref_no invoice_no,
          isd.invoice_type_name invoice_type, isd.cp_contract_ref_no,
          isd.contract_ref_no our_contract_ref_no, akc.corporate_name,
          isd.cp_name, isd.sales_purchase, isd.product, isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
                                     icrc.element_name metal,
          icrc.stock_ref_no stock_ref_no_lot_no, icrc.dry_quantity dry_qty,
          icrc.quantity_unit_name dry_qty_unit,
             icrc.sub_lot_no
          || ' : '
          || icrc.assay_details
          || ' '
          || icrc.assay_uom assay_details,
          NULL net_payable_percentage, NULL net_payable_percentage_unit,
          (CASE
              WHEN icrc.payable_qty IS NULL
                 THEN 0
              ELSE TO_NUMBER (icrc.payable_qty)
           END
          ) payable_penalty_qty,
          icrc.payable_qty_unit payable_penalty_qty_unit, NULL price,
          NULL price_unit,
          (CASE
              WHEN icrc.rc_amount IS NULL OR icrc.rc_amount = ''
                 THEN 0
              ELSE TO_NUMBER (icrc.rc_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,
                                                    -- TC Details
                                                    icrc.payable_qty wet_qty,
          icrc.payable_qty_unit wet_qty_unit, NULL moisture,
          NULL moisture_unit,
          (CASE
              WHEN NVL (icrc.baseescdesc_type, 'NA') IN
                                                     ('Fixed', 'Assay', 'NA')
                 THEN ''
              ELSE icrc.base_rc
           END
          ) fixed_tc_amount,
          isd.invoice_amount_unit fixed_tc_amount_unit,
          (CASE
              WHEN NVL (icrc.baseescdesc_type, 'NA') IN
                                                     ('Fixed', 'Assay', 'NA')
                 THEN ''
              ELSE icrc.rc_es_ds
           END
          ) escalator_descalator,
          
          -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          
          -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, icrc.baseescdesc_type
     FROM is_d isd,
          is_conc_rc_child icrc,
          ds_document_summary ds,
          v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = icrc.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'Penalty' sub_section, ds.corporate_id,
          akc.logo_path, akc.address1, akc.address2, akc.city, akc.state,
          akc.country, akc.phone_no, akc.fax_no, akc.visiting_address,
          akc.organisation_no, akc.foot_note, akc.address_name,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
                                     icpc.element_name metal,
          icpc.stock_ref_no stock_ref_no_lot_no, icpc.dry_quantity dry_qty,
          icpc.quantity_uom dry_qty_unit,
          icpc.assay_details || ' ' || icpc.uom, NULL net_payable_percentage,
          NULL net_payable_percentage_unit,
          (CASE
              WHEN icpc.penalty_qty IS NULL OR icpc.penalty_qty = ''
                 THEN 0
              ELSE TO_NUMBER (icpc.penalty_qty)
           END
          ) payable_penalty_qty,
          icpc.quantity_uom payable_penalty_qty_unit, NULL price,
          NULL price_unit,
          (CASE
              WHEN icpc.penalty_amount IS NULL OR icpc.penalty_amount = ''
                 THEN 0
              ELSE TO_NUMBER (icpc.penalty_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
                                    icpc.penalty_rate,
          icpc.price_name penalty_rate_unit,
                                            -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          
          -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd,
          is_conc_penalty_child icpc,
          ds_document_summary ds,
          v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = icpc.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Other Charges' section_name, 'Other Charges' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          akc.visiting_address, akc.organisation_no, akc.foot_note,
          akc.address_name, isd.internal_doc_ref_no,
          isd.internal_invoice_ref_no,
                                      -- Summary Header Details
                                      isd.invoice_ref_no invoice_no,
          isd.invoice_type_name invoice_type, isd.cp_contract_ref_no,
          isd.contract_ref_no our_contract_ref_no, akc.corporate_name,
          isd.cp_name, isd.sales_purchase, isd.product, isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, ioc.quantity payable_penalty_qty,
          ioc.quantity_unit payable_penalty_qty_unit, NULL price,
          NULL price_unit, ioc.invoice_amount total_amount,
          ioc.invoice_cur_name total_amount_unit,
                                                 -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
          
          -- Charegs Details
          ioc.other_charge_cost_name cost_name, ioc.charge_type,
          ioc.charge_amount_rate amount_rate,
          ioc.rate_price_unit_name amount_rate_unit, ioc.fx_rate,
          ioc.amount amount_in_charge_tax_vat_ccy,
          ioc.amount_unit charge_tax_vat_ccy,
                                             -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, ioc.description invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd, ioc_d ioc, ds_document_summary ds, v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = ioc.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Other Taxes' section_name, 'Other Taxes' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          akc.visiting_address, akc.organisation_no, akc.foot_note,
          akc.address_name, isd.internal_doc_ref_no,
          isd.internal_invoice_ref_no,
                                      -- Summary Header Details
                                      isd.invoice_ref_no invoice_no,
          isd.invoice_type_name invoice_type, isd.cp_contract_ref_no,
          isd.contract_ref_no our_contract_ref_no, akc.corporate_name,
          isd.cp_name, isd.sales_purchase, isd.product, isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN itd.invoice_amount IS NULL OR itd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (itd.invoice_amount)
           END
          ) total_amount,
          itd.invoice_currency total_amount_unit,
                                                 -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, itd.fx_rate,
          itd.amount amount_in_charge_tax_vat_ccy,
          itd.tax_currency charge_tax_vat_ccy,
                                              -- Tax Details
                                              itd.tax_code, itd.tax_rate,
          itd.applicable_on applicable_on,
                                          -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd, itd_d itd, ds_document_summary ds, v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = itd.internal_doc_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'API PI' sub_section, ds.corporate_id,
          akc.logo_path, akc.address1, akc.address2, akc.city, akc.state,
          akc.country, akc.phone_no, akc.fax_no, akc.visiting_address,
          akc.organisation_no, akc.foot_note, akc.address_name,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          
          -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
                                                api_pi.invoice_ref_no,
          api_pi.invoice_description, api_pi.provisional_percentage,
          api_pi.invoice_amount provisional_api_amount,
                                                       -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, vat.vat_amount_in_inv_cur vat_amount,
          
          -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd,
          (SELECT api.internal_doc_ref_no, api.internal_invoice_ref_no,
                  api.api_invoice_ref_no invoice_ref_no,
                  'Advance Payment' invoice_description,
                  NULL provisional_percentage,
                  (CASE
                      WHEN api.api_amount_adjusted IS NULL
                       OR api.api_amount_adjusted = ''
                         THEN 0
                      ELSE TO_NUMBER (api.api_amount_adjusted)
                   END
                  ) invoice_amount
             FROM api_details_d api
           UNION ALL
           SELECT pi.internal_doc_ref_no, pi.internal_invoice_ref_no,
                  pi.invoice_ref_no, pi.invoice_type_name invoice_description,
                  (CASE
                      WHEN pi.prov_pymt_percentage = ''
                       OR pi.prov_pymt_percentage IS NULL
                         THEN '100'
                      ELSE pi.prov_pymt_percentage
                   END
                  ) provisional_percentage,
                  (CASE
                      WHEN pi.invoice_amount IS NULL OR pi.invoice_amount = ''
                         THEN 0
                      ELSE TO_NUMBER (pi.invoice_amount)
                   END
                  ) invoice_amount
             FROM is_parent_child_d pi) api_pi,
          ivd_invoice_vat_details vat,
          ds_document_summary ds,
          v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = api_pi.internal_doc_ref_no(+)
      AND isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'Payment Details' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          akc.visiting_address, akc.organisation_no, akc.foot_note,
          akc.address_name, isd.internal_doc_ref_no,
          isd.internal_invoice_ref_no,
                                      -- Summary Header Details
                                      isd.invoice_ref_no invoice_no,
          isd.invoice_type_name invoice_type, isd.cp_contract_ref_no,
          isd.contract_ref_no our_contract_ref_no, akc.corporate_name,
          isd.cp_name, isd.sales_purchase, isd.product, isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          
          -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          ibp.beneficiary_name beneficiary_name, ibp.bank_name bank_name,
          ibp.account_no account_no, ibp.iban iban, ibp.aba_rtn aba_rtn,
          ibp.instruction instruction, ibp.remarks remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd,
          is_bdp_child_d ibp,
          ds_document_summary ds,
          v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = ibp.internal_doc_ref_no
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'Payment Details' sub_section,
          ds.corporate_id, akc.logo_path, akc.address1, akc.address2,
          akc.city, akc.state, akc.country, akc.phone_no, akc.fax_no,
          akc.visiting_address, akc.organisation_no, akc.foot_note,
          akc.address_name, isd.internal_doc_ref_no,
          isd.internal_invoice_ref_no,
                                      -- Summary Header Details
                                      isd.invoice_ref_no invoice_no,
          isd.invoice_type_name invoice_type, isd.cp_contract_ref_no,
          isd.contract_ref_no our_contract_ref_no, akc.corporate_name,
          isd.cp_name, isd.sales_purchase, isd.product, isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL moisture, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          
          -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          ibp.beneficiary_name beneficiary_name, ibp.bank_name bank_name,
          ibp.account_no account_no, ibp.iban iban, ibp.aba_rtn aba_rtn,
          ibp.instruction instruction, ibp.remarks remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd,
          is_bds_child_d ibp,
          ds_document_summary ds,
          v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = ibp.internal_doc_ref_no
      AND isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
   UNION ALL
   SELECT 'Invoice' section_name, 'VAT' sub_section, ds.corporate_id,
          akc.logo_path, akc.address1, akc.address2, akc.city, akc.state,
          akc.country, akc.phone_no, akc.fax_no, akc.visiting_address,
          akc.organisation_no, akc.foot_note, akc.address_name,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount_unit IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          cm_inv.cur_code total_amount_unit,                           -- Need
                                            -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL mositure, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, vat.fx_rate_vc_ic fx_rate,
          vat.vat_amount_in_vat_cur amount_in_charge_tax_vat_ccy,
          cm_vat.cur_code charge_tax_vat_ccy,
                                             -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          vat.our_vat_no our_vat_reg_no, vat.cp_vat_no cp_vat_reg_no,
          vat.vat_code_name vat_code, vat.vat_text, vat.vat_rate,
          vat.vat_amount_in_inv_cur vat_amount,
                                               -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, vat.special_inst instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd,
          ds_document_summary ds,
          v_ak_corporate akc,
          ivd_invoice_vat_details vat,
          cm_currency_master cm_vat,
          cm_currency_master cm_inv
    WHERE isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
      AND ds.corporate_id = akc.corporate_id(+)
      AND isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
      AND vat.is_separate_invoice(+) = 'N'
      AND vat.vat_remit_cur_id = cm_vat.cur_id
      AND vat.invoice_cur_id = cm_inv.cur_id
   UNION ALL
   SELECT 'Invoice' section_name, 'Summary' sub_section, ds.corporate_id,
          akc.logo_path, akc.address1, akc.address2, akc.city, akc.state,
          akc.country, akc.phone_no, akc.fax_no, akc.visiting_address,
          akc.organisation_no, akc.foot_note, akc.address_name,
          isd.internal_doc_ref_no, isd.internal_invoice_ref_no,
          
          -- Summary Header Details
          isd.invoice_ref_no invoice_no, isd.invoice_type_name invoice_type,
          isd.cp_contract_ref_no, isd.contract_ref_no our_contract_ref_no,
          akc.corporate_name, isd.cp_name, isd.sales_purchase, isd.product,
          isd.quality,
          REPLACE (   isd.cp_address
                   || '^'
                   || isd.cp_zip
                   || '^'
                   || isd.cp_city
                   || '^'
                   || isd.cp_state
                   || '^'
                   || isd.cp_country,
                   '^',
                   CHR (10)
                  ) cp_address,
          isd.internal_comments comments,
          isd.invoice_creation_date invoice_issue_date,
          isd.due_date payment_due_date, isd.payment_term,
          isd.inco_term_location delivery_terms,
                                                -- Delivery Details
          NULL igd_gmr_ref_no, NULL igd_container_name, NULL igd_bl_date,
          NULL igd_origin, NULL igd_wet_qty, NULL igd_wet_qty_unit_name,
          NULL igd_moisture, NULL igd_moisture_unit_name, NULL igd_dry_qty,
          NULL igd_dry_qty_unit_name,
                                     -- Payable Details
          NULL metal, NULL stock_ref_no_lot_no, NULL dry_qty,
          NULL dry_qty_unit, NULL assay_details, NULL net_payable_percentage,
          NULL net_payable_percentage_unit, NULL payable_penalty_qty,
          NULL payable_penalty_qty_unit, NULL price, NULL price_unit,
          (CASE
              WHEN isd.invoice_amount_unit IS NULL OR isd.invoice_amount = ''
                 THEN 0
              ELSE TO_NUMBER (isd.invoice_amount)
           END
          ) total_amount,
          isd.invoice_amount_unit total_amount_unit,                   -- Need
                                                    -- TC Details
          NULL wet_qty, NULL wet_qty_unit, NULL mositure, NULL moisture_unit,
          NULL fixed_tc_amount, NULL fixed_tc_amount_unit,
          NULL escalator_descalator,
                                    -- Penalty Details
          NULL penalty_rate, NULL penalty_rate_unit,
                                                    -- Charegs Details
          NULL cost_name, NULL charge_type, NULL amount_rate,
          NULL amount_rate_unit, NULL fx_rate,
          NULL amount_in_charge_tax_vat_ccy, NULL charge_tax_vat_ccy,
          
          -- Tax Details
          NULL tax_code, NULL tax_rate, NULL applicable_on,
                                                           -- Premium Details
          NULL premium, NULL premium_gmr_ref_no,
                                                -- API PI Details
          NULL invoice_ref_no, NULL invoice_description,
          NULL provisional_percentage, NULL provisional_api_amount,
          
          -- VAT Details
          NULL our_vat_reg_no, NULL cp_vat_reg_no, NULL vat_code,
          NULL vat_text, NULL vat_rate, NULL vat_amount,
          
          -- Bank Details
          NULL beneficiary_name, NULL bank_name, NULL account_no, NULL iban,
          NULL aba_rtn, NULL instruction, NULL remarks,
          
          -- Summary Details
          isd.total_premium_amount, isd.freight_charge, isd.adjustment_amount,
          isd.is_pledge pledge, isd.is_free_metal free_metal,
          isd.invoice_amount, NULL baseescdesc_type
     FROM is_d isd, ds_document_summary ds, v_ak_corporate akc
    WHERE isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
          AND ds.corporate_id = akc.corporate_id(+);