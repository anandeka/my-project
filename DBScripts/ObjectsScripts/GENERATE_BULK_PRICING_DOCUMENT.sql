/* Formatted on 2013/07/01 11:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PROCEDURE "GENERATE_BULK_PRICING_DOCUMENT" (
   p_internal_gmr_ref_no   VARCHAR2,
   p_docrefno              VARCHAR2,
   p_activity_id           VARCHAR2,
   p_doc_issue_date        VARCHAR2
)
IS
   is_pledge_gmr   CHAR;
BEGIN
-- Check whether the gmr is pledged or not
   SELECT DECODE (COUNT (gepd.internal_gmr_ref_no), 0, 'N', 'Y')
     INTO is_pledge_gmr
     FROM gepd_gmr_element_pledge_detail gepd
    WHERE gepd.is_active = 'Y'
      AND gepd.internal_gmr_ref_no = p_internal_gmr_ref_no;

-- Bulk Price fixation -- Header details
   IF is_pledge_gmr = 'N'
   THEN
      -- Header details for non pledge gmr
      INSERT INTO bpfd_bulk_pfd_d
                  (internal_doc_ref_no, doc_issue_date, corporate_name,
                   cp_address, cp_city, cp_country, cp_zip, cp_state,
                   cp_name, cp_person_in_charge, contract_type,
                   purchase_sales, contract_ref_no, delivery_item_ref_no,
                   pay_in_currency, product, quality, gmr_ref_no,
                   quota_period)
         SELECT DISTINCT p_docrefno, p_doc_issue_date, ak.corporate_name,
                         pad.address, cim.city_name, cym.country_name,
                         pad.zip, sm.state_name, phd.companyname companyname,
                         (gab.firstname || ' ' || gab.lastname
                         ) personincharge,
                         pcm.contract_type,
                         (CASE
                             WHEN pcm.is_tolling_contract = 'Y'
                                THEN CASE
                                       WHEN pcm.purchase_sales = 'P'
                                          THEN 'Sell Tolling'
                                       ELSE 'Buy Tolling'
                                    END
                             ELSE CASE
                             WHEN pcm.purchase_sales = 'P'
                                THEN 'Purchase'
                             ELSE 'Sales'
                          END
                          END
                         ) purchasesales,
                         pcm.contract_ref_no,
                         (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
                         ) deliveryitemno,
                         cm.cur_code, pdm.product_desc,
                         (CASE
                             WHEN pocd.qp_period_type = 'Event'
                                THEN (SELECT   stragg
                                                  (gmrquality.quality_name
                                                  ) AS quality_name
                                          FROM (SELECT DISTINCT qat.quality_name,
                                                                pci.internal_contract_item_ref_no
                                                                   AS internal_contract_item_ref_no,
                                                                gmr_in.internal_gmr_ref_no
                                                                   AS internal_gmr_ref_no
                                                           FROM gmr_goods_movement_record gmr_in,
                                                                grd_goods_record_detail grd,
                                                                pci_physical_contract_item pci,
                                                                pcpq_pc_product_quality pcpq,
                                                                qat_quality_attributes qat
                                                          WHERE gmr_in.internal_gmr_ref_no =
                                                                   grd.internal_gmr_ref_no
                                                            AND grd.internal_contract_item_ref_no =
                                                                   pci.internal_contract_item_ref_no
                                                            AND pcpq.quality_template_id =
                                                                   qat.quality_id
                                                            AND pci.pcpq_id =
                                                                   pcpq.pcpq_id
                                                            AND pcpq.is_active =
                                                                           'Y'
                                                            AND gmr_in.is_deleted =
                                                                           'N'
                                                            AND grd.is_deleted =
                                                                           'N'
                                                            AND grd.status =
                                                                      'Active'
                                                            AND pci.is_active =
                                                                           'Y'
                                                UNION ALL
                                                SELECT DISTINCT qat.quality_name,
                                                                pci.internal_contract_item_ref_no
                                                                   AS internal_contract_item_ref_no,
                                                                gmr_in.internal_gmr_ref_no
                                                                   AS internal_gmr_ref_no
                                                           FROM gmr_goods_movement_record gmr_in,
                                                                dgrd_delivered_grd grd,
                                                                pci_physical_contract_item pci,
                                                                pcpq_pc_product_quality pcpq,
                                                                qat_quality_attributes qat
                                                          WHERE gmr_in.internal_gmr_ref_no =
                                                                   grd.internal_gmr_ref_no
                                                            AND grd.internal_contract_item_ref_no =
                                                                   pci.internal_contract_item_ref_no
                                                            AND pcpq.quality_template_id =
                                                                   qat.quality_id
                                                            AND pci.pcpq_id =
                                                                   pcpq.pcpq_id
                                                            AND pcpq.is_active =
                                                                           'Y'
                                                            AND gmr_in.is_deleted =
                                                                           'N'
                                                            AND grd.status =
                                                                      'Active'
                                                            AND pci.is_active =
                                                                           'Y') gmrquality
                                         WHERE gmrquality.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                                      GROUP BY gmrquality.internal_contract_item_ref_no,
                                               gmrquality.internal_gmr_ref_no)
                             ELSE (SELECT   stragg
                                               (qat.quality_name
                                               ) AS quality_name
                                       FROM qat_quality_attributes qat,
                                            pcdiqd_di_quality_details pcdiqd,
                                            pcdi_pc_delivery_item pcdi_in,
                                            pcpq_pc_product_quality pcpq
                                      WHERE pcdiqd.pcpq_id = pcpq.pcpq_id
                                        AND pcdiqd.pcdi_id = pcdi_in.pcdi_id
                                        AND pcdiqd.is_active = 'Y'
                                        AND pcpq.is_active = 'Y'
                                        AND pcpq.quality_template_id =
                                                                qat.quality_id
                                        AND pcdi_in.pcdi_id = pcdi.pcdi_id
                                   GROUP BY pcdi_in.pcdi_id)
                          END
                         ) quality,
                         gmr.gmr_ref_no,
                         (CASE
                             WHEN pcdi.delivery_period_type = 'Month'
                                THEN CASE
                                       WHEN pcdi.delivery_from_month =
                                                        pcdi.delivery_to_month
                                       AND pcdi.delivery_from_year =
                                                         pcdi.delivery_to_year
                                          THEN    pcdi.delivery_from_month
                                               || ' '
                                               || pcdi.delivery_from_year
                                       ELSE    pcdi.delivery_from_month
                                            || ' '
                                            || pcdi.delivery_from_year
                                            || ' To '
                                            || pcdi.delivery_to_month
                                            || ' '
                                            || pcdi.delivery_to_year
                                    END
                             ELSE CASE
                             WHEN TO_CHAR (pcdi.delivery_from_date,
                                           'dd-Mon-YYYY'
                                          ) =
                                    TO_CHAR (pcdi.delivery_to_date,
                                             'dd-Mon-YYYY'
                                            )
                                THEN TO_CHAR (pcdi.delivery_from_date,
                                              'dd-Mon-YYYY'
                                             )
                             ELSE    TO_CHAR (pcdi.delivery_from_date,
                                              'dd-Mon-YYYY'
                                             )
                                  || ' To '
                                  || TO_CHAR (pcdi.delivery_to_date,
                                              'dd-Mon-YYYY'
                                             )
                          END
                          END
                         ) quotaperiod
                    FROM gmr_goods_movement_record gmr,
                         gcim_gmr_contract_item_mapping gcim,
                         pci_physical_contract_item pci,
                         pcdi_pc_delivery_item pcdi,
                         poch_price_opt_call_off_header poch,
                         pocd_price_option_calloff_dtls pocd,
                         pofh_price_opt_fixation_header pofh,
                         pcbpd_pc_base_price_detail pcbpd,
                         pffxd_phy_formula_fx_details pffxd,
                         ppfh_phy_price_formula_header ppfh,
                         pfqpp_phy_formula_qp_pricing pfqpp,
                         pcm_physical_contract_main pcm,
                         pcpd_pc_product_definition pcpd,
                         pdm_productmaster pdm,
                         ak_corporate ak,
                         cm_currency_master cm,
                         phd_profileheaderdetails phd,
                         pad_profile_addresses pad,
                         cym_countrymaster cym,
                         cim_citymaster cim,
                         sm_state_master sm,
                         gab_globaladdressbook gab
                   WHERE gmr.internal_gmr_ref_no = gcim.internal_gmr_ref_no
                     AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
                     AND pci.pcdi_id = pcdi.pcdi_id
                     AND pcdi.pcdi_id = poch.pcdi_id
                     AND poch.poch_id = pocd.poch_id
                     AND pocd.pocd_id = pofh.pocd_id
                     AND pcdi.is_active = 'Y'
                     AND pocd.is_active = 'Y'
                     AND pofh.is_active = 'Y'
                     AND poch.is_active = 'Y'
                     AND pocd.pcbpd_id = pcbpd.pcbpd_id
                     AND pcbpd.pcbpd_id = ppfh.pcbpd_id
                     AND pfqpp.ppfh_id = ppfh.ppfh_id
                     AND pcbpd.is_active = 'Y'
                     AND ppfh.is_active = 'Y'
                     AND ppfh.ppfh_id = pfqpp.ppfh_id
                     AND pcdi.internal_contract_ref_no =
                                                  pcm.internal_contract_ref_no
                     AND pcm.internal_contract_ref_no =
                                                 pcpd.internal_contract_ref_no
                     AND pcbpd.pffxd_id = pffxd.pffxd_id
                     AND pcpd.product_id = pdm.product_id
                     AND pcpd.input_output = 'Input'
                     AND pcm.corporate_id = ak.corporate_id
                     AND pcm.invoice_currency_id = cm.cur_id
                     AND pcm.cp_id = phd.profileid
                     AND phd.profileid = pad.profile_id(+)
                     AND pad.country_id = cym.country_id(+)
                     AND pad.city_id = cim.city_id(+)
                     AND pad.state_id = sm.state_id(+)
                     AND pad.address_type(+) = 'Main'
                     AND pcm.cp_person_in_charge_id = gab.gabid(+)
                     AND gmr.internal_gmr_ref_no = p_internal_gmr_ref_no;
   ELSIF is_pledge_gmr = 'Y'
   THEN
      -- Header details for non pledge gmr
      INSERT INTO bpfd_bulk_pfd_d
                  (internal_doc_ref_no, doc_issue_date, corporate_name,
                   cp_address, cp_city, cp_country, cp_zip, cp_state,
                   cp_name, cp_person_in_charge, contract_type,
                   purchase_sales, contract_ref_no, delivery_item_ref_no,
                   pay_in_currency, product, quality, gmr_ref_no,
                   quota_period)
         SELECT DISTINCT p_docrefno, p_doc_issue_date, ak.corporate_name,
                         pad.address, cim.city_name, cym.country_name,
                         pad.zip, sm.state_name, phd.companyname companyname,
                         (gab.firstname || ' ' || gab.lastname
                         ) personincharge,
                         pcm.contract_type,
                         (CASE
                             WHEN pcm.is_tolling_contract = 'Y'
                                THEN CASE
                                       WHEN pcm.purchase_sales = 'P'
                                          THEN 'Sell Tolling'
                                       ELSE 'Buy Tolling'
                                    END
                             ELSE CASE
                             WHEN pcm.purchase_sales = 'P'
                                THEN 'Purchase'
                             ELSE 'Sales'
                          END
                          END
                         ) purchasesales,
                         pcm.contract_ref_no,
                         (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
                         ) deliveryitemno,
                         cm.cur_code, pdm.product_desc,
                         (CASE
                             WHEN pocd.qp_period_type = 'Event'
                                THEN (SELECT   stragg
                                                  (gmrquality.quality_name
                                                  ) AS quality_name
                                          FROM (SELECT DISTINCT qat.quality_name,
                                                                pci.internal_contract_item_ref_no
                                                                   AS internal_contract_item_ref_no,
                                                                gmr_in.internal_gmr_ref_no
                                                                   AS internal_gmr_ref_no
                                                           FROM gmr_goods_movement_record gmr_in,
                                                                grd_goods_record_detail grd,
                                                                pci_physical_contract_item pci,
                                                                pcpq_pc_product_quality pcpq,
                                                                qat_quality_attributes qat
                                                          WHERE gmr_in.internal_gmr_ref_no =
                                                                   grd.internal_gmr_ref_no
                                                            AND grd.internal_contract_item_ref_no =
                                                                   pci.internal_contract_item_ref_no
                                                            AND pcpq.quality_template_id =
                                                                   qat.quality_id
                                                            AND pci.pcpq_id =
                                                                   pcpq.pcpq_id
                                                            AND pcpq.is_active =
                                                                           'Y'
                                                            AND gmr_in.is_deleted =
                                                                           'N'
                                                            AND grd.is_deleted =
                                                                           'N'
                                                            AND grd.status =
                                                                      'Active'
                                                            AND pci.is_active =
                                                                           'Y'
                                                UNION ALL
                                                SELECT DISTINCT qat.quality_name,
                                                                pci.internal_contract_item_ref_no
                                                                   AS internal_contract_item_ref_no,
                                                                gmr_in.internal_gmr_ref_no
                                                                   AS internal_gmr_ref_no
                                                           FROM gmr_goods_movement_record gmr_in,
                                                                dgrd_delivered_grd grd,
                                                                pci_physical_contract_item pci,
                                                                pcpq_pc_product_quality pcpq,
                                                                qat_quality_attributes qat
                                                          WHERE gmr_in.internal_gmr_ref_no =
                                                                   grd.internal_gmr_ref_no
                                                            AND grd.internal_contract_item_ref_no =
                                                                   pci.internal_contract_item_ref_no
                                                            AND pcpq.quality_template_id =
                                                                   qat.quality_id
                                                            AND pci.pcpq_id =
                                                                   pcpq.pcpq_id
                                                            AND pcpq.is_active =
                                                                           'Y'
                                                            AND gmr_in.is_deleted =
                                                                           'N'
                                                            AND grd.status =
                                                                      'Active'
                                                            AND pci.is_active =
                                                                           'Y') gmrquality
                                         WHERE gmrquality.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                                      GROUP BY gmrquality.internal_contract_item_ref_no,
                                               gmrquality.internal_gmr_ref_no)
                             ELSE (SELECT   stragg
                                               (qat.quality_name
                                               ) AS quality_name
                                       FROM qat_quality_attributes qat,
                                            pcdiqd_di_quality_details pcdiqd,
                                            pcdi_pc_delivery_item pcdi_in,
                                            pcpq_pc_product_quality pcpq
                                      WHERE pcdiqd.pcpq_id = pcpq.pcpq_id
                                        AND pcdiqd.pcdi_id = pcdi_in.pcdi_id
                                        AND pcdiqd.is_active = 'Y'
                                        AND pcpq.is_active = 'Y'
                                        AND pcpq.quality_template_id =
                                                                qat.quality_id
                                        AND pcdi_in.pcdi_id = pcdi.pcdi_id
                                   GROUP BY pcdi_in.pcdi_id)
                          END
                         ) quality,
                         gmr_pl.gmr_ref_no,
                         (CASE
                             WHEN pcdi.delivery_period_type = 'Month'
                                THEN CASE
                                       WHEN pcdi.delivery_from_month =
                                                        pcdi.delivery_to_month
                                       AND pcdi.delivery_from_year =
                                                         pcdi.delivery_to_year
                                          THEN    pcdi.delivery_from_month
                                               || ' '
                                               || pcdi.delivery_from_year
                                       ELSE    pcdi.delivery_from_month
                                            || ' '
                                            || pcdi.delivery_from_year
                                            || ' To '
                                            || pcdi.delivery_to_month
                                            || ' '
                                            || pcdi.delivery_to_year
                                    END
                             ELSE CASE
                             WHEN TO_CHAR (pcdi.delivery_from_date,
                                           'dd-Mon-YYYY'
                                          ) =
                                    TO_CHAR (pcdi.delivery_to_date,
                                             'dd-Mon-YYYY'
                                            )
                                THEN TO_CHAR (pcdi.delivery_from_date,
                                              'dd-Mon-YYYY'
                                             )
                             ELSE    TO_CHAR (pcdi.delivery_from_date,
                                              'dd-Mon-YYYY'
                                             )
                                  || ' To '
                                  || TO_CHAR (pcdi.delivery_to_date,
                                              'dd-Mon-YYYY'
                                             )
                          END
                          END
                         ) quotaperiod
                    FROM gmr_goods_movement_record gmr,
                         gcim_gmr_contract_item_mapping gcim,
                         pci_physical_contract_item pci,
                         pcdi_pc_delivery_item pcdi,
                         poch_price_opt_call_off_header poch,
                         pocd_price_option_calloff_dtls pocd,
                         pofh_price_opt_fixation_header pofh,
                         pcbpd_pc_base_price_detail pcbpd,
                         pffxd_phy_formula_fx_details pffxd,
                         ppfh_phy_price_formula_header ppfh,
                         pfqpp_phy_formula_qp_pricing pfqpp,
                         pcm_physical_contract_main pcm,
                         pdm_productmaster pdm,
                         ak_corporate ak,
                         cm_currency_master cm,
                         phd_profileheaderdetails phd,
                         pad_profile_addresses pad,
                         cym_countrymaster cym,
                         cim_citymaster cim,
                         sm_state_master sm,
                         gab_globaladdressbook gab,
                         gepd_gmr_element_pledge_detail gepd,
                         gmr_goods_movement_record gmr_pl
                   WHERE gepd.pledge_input_gmr = gmr.internal_gmr_ref_no
                     AND gmr.internal_gmr_ref_no = gcim.internal_gmr_ref_no
                     AND gepd.internal_gmr_ref_no = gmr_pl.internal_gmr_ref_no
                     AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
                     AND pci.pcdi_id = pcdi.pcdi_id
                     AND pcdi.pcdi_id = poch.pcdi_id
                     AND poch.poch_id = pocd.poch_id
                     AND pocd.pocd_id = pofh.pocd_id
                     AND poch.element_id = gepd.element_id
                     AND pcdi.is_active = 'Y'
                     AND pocd.is_active = 'Y'
                     AND pofh.is_active = 'Y'
                     AND poch.is_active = 'Y'
                     AND pocd.pcbpd_id = pcbpd.pcbpd_id
                     AND pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
                     AND ppfh.ppfh_id = pfqpp.ppfh_id(+)
                     AND pcbpd.is_active = 'Y'
                     AND ppfh.is_active = 'Y'
                     AND pcdi.internal_contract_ref_no =
                                                  pcm.internal_contract_ref_no
                     AND pcbpd.pffxd_id = pffxd.pffxd_id(+)
                     AND gepd.product_id = pdm.product_id
                     AND pcm.corporate_id = ak.corporate_id
                     AND pcm.invoice_currency_id = cm.cur_id
                     AND gepd.supplier_cp_id = phd.profileid
                     AND phd.profileid = pad.profile_id(+)
                     AND pad.country_id = cym.country_id(+)
                     AND pad.city_id = cim.city_id(+)
                     AND pad.state_id = sm.state_id(+)
                     AND pad.address_type(+) = 'Main'
                     AND pcm.cp_person_in_charge_id = gab.gabid(+)
                     AND gepd.internal_gmr_ref_no = p_internal_gmr_ref_no;
   END IF;

--- Price fixation details of the GMR.
-- Values are inserted through select statements.
-- 2 set of 3 different select queries
-- Event Based, DI based (non PriceAllocation ) , DI Based Price Allocation (Non Pledge GMR) & same for pledged GMRs
   INSERT INTO bpfde_elmt_dts_d
               (internal_doc_ref_no, pfd_id, element_name,
                price_fixation_ref_no, price_fixation_date, price, price_unit,
                priced_quantity, priced_qty_unit, fx_rate,
                price_unit_in_payin_ccy, price_type, pricing_formula, qp)
      -- Event Basecd for NonPledged GMR Elements
      SELECT p_docrefno, pfd.pfd_id, aml.attribute_name elementname,
             axs.action_ref_no pricefixationrefno,
             TO_CHAR (pfd.as_of_date, 'dd-Mon-YYYY') pricefixationdate,
             NVL (pfd.user_price, 0) price, pum.price_unit_name,
             NVL (pfd.qty_fixed, 0) pricedqty, qum.qty_unit,
             DECODE (pocd.pay_in_cur_id,
                     pocd.pricing_cur_id, 1,
                     pfd.fx_rate
                    ) fx_rate,
             payin_pum.price_unit_name pay_price_unit_name,
                DECODE (pocd.qp_period_type,
                        'Event', 'Event Based ',
                        'DI Based '
                       )
             || DECODE (pocd.is_any_day_pricing,
                        'Y', DECODE (pocd.qp_period_type,
                                     'Event', '- Any Day / Spot',
                                        '- Any Day / Spot - '
                                     || pcdi.price_allocation_method
                                    ),
                        DECODE (pocd.qp_period_type, 'Date', '', '- Average')
                       ) pricetype,
             (   pcbpd.qty_to_be_priced
              || '% of '
              || (CASE
                     WHEN pcbpd.price_basis = 'Formula'
                        THEN    ppfh.formula_name
                             || ' - '
                             || (SELECT   stragg
                                             (   dim.instrument_name
                                              || ' - '
                                              || ps.price_source_name
                                              || ' '
                                              || pp.price_point_name
                                              || ' '
                                              || apm.available_price_display_name
                                             )
                                     FROM dim_der_instrument_master dim,
                                          ppfd_phy_price_formula_details ppfd,
                                          pp_price_point pp,
                                          ps_price_source ps,
                                          apm_available_price_master apm
                                    WHERE dim.instrument_id =
                                                            ppfd.instrument_id
                                      AND ppfd.is_active = 'Y'
                                      AND ppfh.ppfh_id = ppfd.ppfh_id
                                      AND ppfd.price_point_id = pp.price_point_id(+)
                                      AND ppfd.price_source_id =
                                                            ps.price_source_id
                                      AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                                 GROUP BY ppfh.ppfh_id)
                     WHEN pcbpd.price_basis = 'Index'
                        THEN (SELECT    dim.instrument_name
                                     || ' - '
                                     || ps.price_source_name
                                     || ' '
                                     || pp.price_point_name
                                     || ' '
                                     || apm.available_price_display_name
                                FROM dim_der_instrument_master dim,
                                     ppfd_phy_price_formula_details ppfd,
                                     pp_price_point pp,
                                     ps_price_source ps,
                                     apm_available_price_master apm
                               WHERE dim.instrument_id = ppfd.instrument_id
                                 AND ppfd.is_active = 'Y'
                                 AND ppfh.ppfh_id = ppfd.ppfh_id
                                 AND ppfd.price_point_id = pp.price_point_id(+)
                                 AND ppfd.price_source_id = ps.price_source_id
                                 AND ppfd.available_price_type_id =
                                                        apm.available_price_id)
                  END
                 )
              || (CASE
                     WHEN pocd.qp_period_type = 'Event'
                        THEN    ', '
                             || pfqpp.no_of_event_months
                             || ' '
                             || pfqpp.event_name
                  END
                 )
             ) pricingformula,
             (   TO_CHAR (pofh.qp_start_date, 'dd-Mon-yyyy')
              || ' to '
              || TO_CHAR (pofh.qp_end_date, 'dd-Mon-yyyy')
             ) qpperiod
        FROM gmr_goods_movement_record gmr,
             gcim_gmr_contract_item_mapping gcim,
             pci_physical_contract_item pci,
             pcdi_pc_delivery_item pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details pfd,
             aml_attribute_master_list aml,
             qum_quantity_unit_master qum,
             pfam_price_fix_action_mapping pfam,
             axs_action_summary axs,
             pcbpd_pc_base_price_detail pcbpd,
             ppfh_phy_price_formula_header ppfh,
             pfqpp_phy_formula_qp_pricing pfqpp,
             ppu_product_price_units ppu,
             pum_price_unit_master pum,
             ppu_product_price_units payin_ppu,
             pum_price_unit_master payin_pum
       WHERE gmr.internal_gmr_ref_no = gcim.internal_gmr_ref_no
         AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
         AND pci.pcdi_id = pcdi.pcdi_id
         AND pcdi.pcdi_id = poch.pcdi_id
         AND poch.poch_id = pocd.poch_id
         AND pocd.pocd_id = pofh.pocd_id
         AND poch.element_id = aml.attribute_id(+)
         AND pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
         AND pcdi.is_active = 'Y'
         AND poch.is_active = 'Y'
         AND pocd.is_active = 'Y'
         AND pofh.is_active = 'Y'
         AND pofh.pofh_id = pfd.pofh_id
         AND pfd.is_active = 'Y'
         AND pfd.pfd_id = pfam.pfd_id
         AND pfam.internal_action_ref_no = axs.internal_action_ref_no
         AND pfam.is_active = 'Y'
         AND NVL (pfd.is_hedge_correction, 'N') = 'N'
         AND pocd.pcbpd_id = pcbpd.pcbpd_id
         AND pcbpd.pcbpd_id = ppfh.pcbpd_id
         AND pfqpp.ppfh_id = ppfh.ppfh_id
         AND pcbpd.is_active = 'Y'
         AND ppfh.is_active = 'Y'
         AND ppfh.ppfh_id = pfqpp.ppfh_id
         AND pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
         AND pfd.price_unit_id = ppu.internal_price_unit_id
         AND ppu.price_unit_id = pum.price_unit_id
         AND pocd.pay_in_price_unit_id = payin_ppu.internal_price_unit_id
         AND payin_ppu.price_unit_id = payin_pum.price_unit_id
         AND pcdi.price_allocation_method NOT IN ('Price Allocation')
         AND poch.element_id NOT IN (
                SELECT DISTINCT gepd.element_id
                           FROM gepd_gmr_element_pledge_detail gepd
                          WHERE gepd.is_active = 'Y'
                            AND gepd.pledge_input_gmr = p_internal_gmr_ref_no)
         AND gmr.internal_gmr_ref_no = p_internal_gmr_ref_no
      UNION ALL
--Delivery Item based for NonPledged GMR Elements
      SELECT p_docrefno, pfd.pfd_id, aml.attribute_name elementname,
             axs.action_ref_no pricefixationrefno,
             TO_CHAR (pfd.as_of_date, 'dd-Mon-YYYY') pricefixationdate,
             NVL (pfd.user_price, 0) price, pum.price_unit_name,
             NVL (pfd.qty_fixed, 0) pricedqty, qum.qty_unit,
             DECODE (pocd.pay_in_cur_id,
                     pocd.pricing_cur_id, 1,
                     pfd.fx_rate
                    ) fx_rate,
             payin_pum.price_unit_name pay_price_unit_name,
                DECODE (pocd.qp_period_type,
                        'Event', 'Event Based ',
                        'DI Based '
                       )
             || DECODE (pocd.is_any_day_pricing,
                        'Y', DECODE (pocd.qp_period_type,
                                     'Event', 'Any Day / Spot',
                                        'Any Day / Spot '
                                     || pcdi.price_allocation_method
                                    ),
                        DECODE (pocd.qp_period_type, 'Date', '', 'Average')
                       ) pricetype,
             (   pcbpd.qty_to_be_priced
              || '% of '
              || (CASE
                     WHEN pcbpd.price_basis = 'Formula'
                        THEN    ppfh.formula_name
                             || ' - '
                             || (SELECT   stragg
                                             (   dim.instrument_name
                                              || ' - '
                                              || ps.price_source_name
                                              || ' '
                                              || pp.price_point_name
                                              || ' '
                                              || apm.available_price_display_name
                                             )
                                     FROM dim_der_instrument_master dim,
                                          ppfd_phy_price_formula_details ppfd,
                                          pp_price_point pp,
                                          ps_price_source ps,
                                          apm_available_price_master apm
                                    WHERE dim.instrument_id =
                                                            ppfd.instrument_id
                                      AND ppfd.is_active = 'Y'
                                      AND ppfh.ppfh_id = ppfd.ppfh_id
                                      AND ppfd.price_point_id = pp.price_point_id(+)
                                      AND ppfd.price_source_id =
                                                            ps.price_source_id
                                      AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                                 GROUP BY ppfh.ppfh_id)
                     WHEN pcbpd.price_basis = 'Index'
                        THEN (SELECT    dim.instrument_name
                                     || ' - '
                                     || ps.price_source_name
                                     || ' '
                                     || pp.price_point_name
                                     || ' '
                                     || apm.available_price_display_name
                                FROM dim_der_instrument_master dim,
                                     ppfd_phy_price_formula_details ppfd,
                                     pp_price_point pp,
                                     ps_price_source ps,
                                     apm_available_price_master apm
                               WHERE dim.instrument_id = ppfd.instrument_id
                                 AND ppfd.is_active = 'Y'
                                 AND ppfh.ppfh_id = ppfd.ppfh_id
                                 AND ppfd.price_point_id = pp.price_point_id(+)
                                 AND ppfd.price_source_id = ps.price_source_id
                                 AND ppfd.available_price_type_id =
                                                        apm.available_price_id)
                  END
                 )
              || (CASE
                     WHEN pocd.qp_period_type = 'Event'
                        THEN    ', '
                             || pfqpp.no_of_event_months
                             || ' '
                             || pfqpp.event_name
                  END
                 )
             ) pricingformula,
             (   TO_CHAR (pofh.qp_start_date, 'dd-Mon-yyyy')
              || ' to '
              || TO_CHAR (pofh.qp_end_date, 'dd-Mon-yyyy')
             ) qpperiod
        FROM gmr_goods_movement_record gmr,
             gcim_gmr_contract_item_mapping gcim,
             pci_physical_contract_item pci,
             pcdi_pc_delivery_item pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details pfd,
             aml_attribute_master_list aml,
             qum_quantity_unit_master qum,
             pfam_price_fix_action_mapping pfam,
             axs_action_summary axs,
             pcbpd_pc_base_price_detail pcbpd,
             ppfh_phy_price_formula_header ppfh,
             pfqpp_phy_formula_qp_pricing pfqpp,
             ppu_product_price_units ppu,
             pum_price_unit_master pum,
             ppu_product_price_units payin_ppu,
             pum_price_unit_master payin_pum
       WHERE gmr.internal_gmr_ref_no = gcim.internal_gmr_ref_no
         AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
         AND pci.pcdi_id = pcdi.pcdi_id
         AND pcdi.pcdi_id = poch.pcdi_id
         AND poch.poch_id = pocd.poch_id
         AND pocd.pocd_id = pofh.pocd_id
         AND poch.element_id = aml.attribute_id(+)
         AND pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
         AND pcdi.is_active = 'Y'
         AND poch.is_active = 'Y'
         AND pocd.is_active = 'Y'
         AND pofh.is_active = 'Y'
         AND pofh.pofh_id = pfd.pofh_id
         AND pfd.is_active = 'Y'
         AND pfd.pfd_id = pfam.pfd_id
         AND pfam.internal_action_ref_no = axs.internal_action_ref_no
         AND pfam.is_active = 'Y'
         AND NVL (pfd.is_hedge_correction, 'N') = 'N'
         AND pocd.pcbpd_id = pcbpd.pcbpd_id
         AND pcbpd.pcbpd_id = ppfh.pcbpd_id
         AND pfqpp.ppfh_id = ppfh.ppfh_id
         AND pcbpd.is_active = 'Y'
         AND ppfh.is_active = 'Y'
         AND ppfh.ppfh_id = pfqpp.ppfh_id
         AND pfd.price_unit_id = ppu.internal_price_unit_id
         AND ppu.price_unit_id = pum.price_unit_id
         AND pocd.pay_in_price_unit_id = payin_ppu.internal_price_unit_id
         AND payin_ppu.price_unit_id = payin_pum.price_unit_id
         AND pofh.internal_gmr_ref_no IS NULL
         AND pocd.qp_period_type NOT IN ('Event')
         AND pcdi.price_allocation_method NOT IN ('Price Allocation')
         AND poch.element_id NOT IN (
                SELECT DISTINCT gepd.element_id
                           FROM gepd_gmr_element_pledge_detail gepd
                          WHERE gepd.is_active = 'Y'
                            AND gepd.pledge_input_gmr = p_internal_gmr_ref_no)
         AND gmr.internal_gmr_ref_no = p_internal_gmr_ref_no
-- price allocation non pledged gmr elements
-- fixation for non pledged gmr is differentiated by internal_pledge_gmr_ref_no column.
      UNION ALL
      SELECT p_docrefno, pfd.pfd_id, aml.attribute_name elementname,
             axs.action_ref_no pricefixationrefno,
             TO_CHAR (pfd.as_of_date, 'dd-Mon-YYYY') pricefixationdate,
             NVL (pfd.user_price, 0) price, pum.price_unit_name,
             NVL (pfd.qty_fixed, 0) pricedqty, qum.qty_unit,
             DECODE (pocd.pay_in_cur_id,
                     pocd.pricing_cur_id, 1,
                     pfd.fx_rate
                    ) fx_rate,
             payin_pum.price_unit_name pay_price_unit_name,
                DECODE (pocd.qp_period_type,
                        'Event', 'Event Based ',
                        'DI Based '
                       )
             || DECODE (pocd.is_any_day_pricing,
                        'Y', DECODE (pocd.qp_period_type,
                                     'Event', 'Any Day / Spot',
                                        'Any Day / Spot '
                                     || pcdi.price_allocation_method
                                    ),
                        DECODE (pocd.qp_period_type, 'Date', '', 'Average')
                       ) pricetype,
             (   pcbpd.qty_to_be_priced
              || '% of '
              || (CASE
                     WHEN pcbpd.price_basis = 'Formula'
                        THEN    ppfh.formula_name
                             || ' - '
                             || (SELECT   stragg
                                             (   dim.instrument_name
                                              || ' - '
                                              || ps.price_source_name
                                              || ' '
                                              || pp.price_point_name
                                              || ' '
                                              || apm.available_price_display_name
                                             )
                                     FROM dim_der_instrument_master dim,
                                          ppfd_phy_price_formula_details ppfd,
                                          pp_price_point pp,
                                          ps_price_source ps,
                                          apm_available_price_master apm
                                    WHERE dim.instrument_id =
                                                            ppfd.instrument_id
                                      AND ppfd.is_active = 'Y'
                                      AND ppfh.ppfh_id = ppfd.ppfh_id
                                      AND ppfd.price_point_id = pp.price_point_id(+)
                                      AND ppfd.price_source_id =
                                                            ps.price_source_id
                                      AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                                 GROUP BY ppfh.ppfh_id)
                     WHEN pcbpd.price_basis = 'Index'
                        THEN (SELECT    dim.instrument_name
                                     || ' - '
                                     || ps.price_source_name
                                     || ' '
                                     || pp.price_point_name
                                     || ' '
                                     || apm.available_price_display_name
                                FROM dim_der_instrument_master dim,
                                     ppfd_phy_price_formula_details ppfd,
                                     pp_price_point pp,
                                     ps_price_source ps,
                                     apm_available_price_master apm
                               WHERE dim.instrument_id = ppfd.instrument_id
                                 AND ppfd.is_active = 'Y'
                                 AND ppfh.ppfh_id = ppfd.ppfh_id
                                 AND ppfd.price_point_id = pp.price_point_id(+)
                                 AND ppfd.price_source_id = ps.price_source_id
                                 AND ppfd.available_price_type_id =
                                                        apm.available_price_id)
                  END
                 )
              || (CASE
                     WHEN pocd.qp_period_type = 'Event'
                        THEN    ', '
                             || pfqpp.no_of_event_months
                             || ' '
                             || pfqpp.event_name
                  END
                 )
             ) pricingformula,
             (   TO_CHAR (pofh.qp_start_date, 'dd-Mon-yyyy')
              || ' to '
              || TO_CHAR (pofh.qp_end_date, 'dd-Mon-yyyy')
             ) qpperiod
        FROM gmr_goods_movement_record gmr,
             pcdi_pc_delivery_item pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             gpah_gmr_price_alloc_header gpah,
             gpad_gmr_price_alloc_dtls gpad,
             aml_attribute_master_list aml,
             qum_quantity_unit_master qum,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details pfd,
             pfam_price_fix_action_mapping pfam,
             axs_action_summary axs,
             pcbpd_pc_base_price_detail pcbpd,
             ppfh_phy_price_formula_header ppfh,
             pfqpp_phy_formula_qp_pricing pfqpp,
             ppu_product_price_units ppu,
             pum_price_unit_master pum,
             ppu_product_price_units payin_ppu,
             pum_price_unit_master payin_pum
       WHERE gmr.internal_gmr_ref_no = gpah.internal_gmr_ref_no
         AND gpah.pocd_id = pocd.pocd_id
         AND pocd.poch_id = poch.poch_id
         AND poch.pcdi_id = pcdi.pcdi_id
         AND gpah.element_id = aml.attribute_id(+)
         AND gpah.qty_unit_id = qum.qty_unit_id
         AND pofh.pocd_id = gpah.pocd_id
         AND pofh.internal_gmr_ref_no IS NULL
         AND gpah.gpah_id = gpad.gpah_id
         AND gpad.pfd_id = pfd.pfd_id
         AND pfd.pfd_id = pfam.pfd_id
         AND pocd.is_active = 'Y'
         AND poch.is_active = 'Y'
         AND pcdi.is_active = 'Y'
         AND gpah.is_active = 'Y'
         AND gpad.is_active = 'Y'
         AND pfd.is_active = 'Y'
         AND pfam.internal_action_ref_no = axs.internal_action_ref_no
         AND pfam.is_active = 'Y'
         AND NVL (pfd.is_hedge_correction, 'N') = 'N'
         AND pocd.pcbpd_id = pcbpd.pcbpd_id
         AND pcbpd.pcbpd_id = ppfh.pcbpd_id
         AND pfqpp.ppfh_id = ppfh.ppfh_id
         AND pcbpd.is_active = 'Y'
         AND ppfh.is_active = 'Y'
         AND ppfh.ppfh_id = pfqpp.ppfh_id
         AND pfd.price_unit_id = ppu.internal_price_unit_id
         AND ppu.price_unit_id = pum.price_unit_id
         AND pocd.pay_in_price_unit_id = payin_ppu.internal_price_unit_id
         AND payin_ppu.price_unit_id = payin_pum.price_unit_id
         AND pfd.internal_pledge_gmr_ref_no IS NULL
         AND gmr.internal_gmr_ref_no = p_internal_gmr_ref_no
      UNION ALL
      -- Queries related to pledge gmrs
      -- Event Basecd for Pledge GMR Elements
      SELECT p_docrefno, pfd.pfd_id, aml.attribute_name elementname,
             axs.action_ref_no pricefixationrefno,
             TO_CHAR (pfd.as_of_date, 'dd-Mon-YYYY') pricefixationdate,
             NVL (pfd.user_price, 0) price, pum.price_unit_name,
             NVL (pfd.qty_fixed, 0) pricedqty, qum.qty_unit,
             DECODE (pocd.pay_in_cur_id,
                     pocd.pricing_cur_id, 1,
                     pfd.fx_rate
                    ) fx_rate,
             payin_pum.price_unit_name pay_price_unit_name,
                DECODE (pocd.qp_period_type,
                        'Event', 'Event Based ',
                        'DI Based '
                       )
             || DECODE (pocd.is_any_day_pricing,
                        'Y', DECODE (pocd.qp_period_type,
                                     'Event', '- Any Day / Spot',
                                        '- Any Day / Spot - '
                                     || pcdi.price_allocation_method
                                    ),
                        DECODE (pocd.qp_period_type, 'Date', '', '- Average')
                       ) pricetype,
             (   pcbpd.qty_to_be_priced
              || '% of '
              || (CASE
                     WHEN pcbpd.price_basis = 'Formula'
                        THEN    ppfh.formula_name
                             || ' - '
                             || (SELECT   stragg
                                             (   dim.instrument_name
                                              || ' - '
                                              || ps.price_source_name
                                              || ' '
                                              || pp.price_point_name
                                              || ' '
                                              || apm.available_price_display_name
                                             )
                                     FROM dim_der_instrument_master dim,
                                          ppfd_phy_price_formula_details ppfd,
                                          pp_price_point pp,
                                          ps_price_source ps,
                                          apm_available_price_master apm
                                    WHERE dim.instrument_id =
                                                            ppfd.instrument_id
                                      AND ppfd.is_active = 'Y'
                                      AND ppfh.ppfh_id = ppfd.ppfh_id
                                      AND ppfd.price_point_id = pp.price_point_id(+)
                                      AND ppfd.price_source_id =
                                                            ps.price_source_id
                                      AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                                 GROUP BY ppfh.ppfh_id)
                     WHEN pcbpd.price_basis = 'Index'
                        THEN (SELECT    dim.instrument_name
                                     || ' - '
                                     || ps.price_source_name
                                     || ' '
                                     || pp.price_point_name
                                     || ' '
                                     || apm.available_price_display_name
                                FROM dim_der_instrument_master dim,
                                     ppfd_phy_price_formula_details ppfd,
                                     pp_price_point pp,
                                     ps_price_source ps,
                                     apm_available_price_master apm
                               WHERE dim.instrument_id = ppfd.instrument_id
                                 AND ppfd.is_active = 'Y'
                                 AND ppfh.ppfh_id = ppfd.ppfh_id
                                 AND ppfd.price_point_id = pp.price_point_id(+)
                                 AND ppfd.price_source_id = ps.price_source_id
                                 AND ppfd.available_price_type_id =
                                                        apm.available_price_id)
                  END
                 )
              || (CASE
                     WHEN pocd.qp_period_type = 'Event'
                        THEN    ', '
                             || pfqpp.no_of_event_months
                             || ' '
                             || pfqpp.event_name
                  END
                 )
             ) pricingformula,
             (   TO_CHAR (pofh.qp_start_date, 'dd-Mon-yyyy')
              || ' to '
              || TO_CHAR (pofh.qp_end_date, 'dd-Mon-yyyy')
             ) qpperiod
        FROM gmr_goods_movement_record gmr,
             gcim_gmr_contract_item_mapping gcim,
             pci_physical_contract_item pci,
             pcdi_pc_delivery_item pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details pfd,
             aml_attribute_master_list aml,
             qum_quantity_unit_master qum,
             pfam_price_fix_action_mapping pfam,
             axs_action_summary axs,
             pcbpd_pc_base_price_detail pcbpd,
             ppfh_phy_price_formula_header ppfh,
             pfqpp_phy_formula_qp_pricing pfqpp,
             ppu_product_price_units ppu,
             pum_price_unit_master pum,
             ppu_product_price_units payin_ppu,
             pum_price_unit_master payin_pum
       WHERE gmr.internal_gmr_ref_no = gcim.internal_gmr_ref_no
         AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
         AND pci.pcdi_id = pcdi.pcdi_id
         AND pcdi.pcdi_id = poch.pcdi_id
         AND poch.poch_id = pocd.poch_id
         AND pocd.pocd_id = pofh.pocd_id
         AND poch.element_id = aml.attribute_id(+)
         AND pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
         AND pcdi.is_active = 'Y'
         AND poch.is_active = 'Y'
         AND pocd.is_active = 'Y'
         AND pofh.is_active = 'Y'
         AND pofh.pofh_id = pfd.pofh_id
         AND pfd.is_active = 'Y'
         AND pfd.pfd_id = pfam.pfd_id
         AND pfam.internal_action_ref_no = axs.internal_action_ref_no
         AND pfam.is_active = 'Y'
         AND NVL (pfd.is_hedge_correction, 'N') = 'N'
         AND pocd.pcbpd_id = pcbpd.pcbpd_id
         AND pcbpd.pcbpd_id = ppfh.pcbpd_id
         AND pfqpp.ppfh_id = ppfh.ppfh_id
         AND pcbpd.is_active = 'Y'
         AND ppfh.is_active = 'Y'
         AND ppfh.ppfh_id = pfqpp.ppfh_id
         AND pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
         AND pfd.price_unit_id = ppu.internal_price_unit_id
         AND ppu.price_unit_id = pum.price_unit_id
         AND pocd.pay_in_price_unit_id = payin_ppu.internal_price_unit_id
         AND payin_ppu.price_unit_id = payin_pum.price_unit_id
         AND pcdi.price_allocation_method NOT IN ('Price Allocation')
         AND poch.element_id IN (
                SELECT DISTINCT gepd.element_id
                           FROM gepd_gmr_element_pledge_detail gepd
                          WHERE gepd.is_active = 'Y'
                            AND gepd.internal_gmr_ref_no =
                                                         p_internal_gmr_ref_no)
         AND gmr.internal_gmr_ref_no =
                (SELECT DISTINCT gepd.pledge_input_gmr
                            FROM gepd_gmr_element_pledge_detail gepd
                           WHERE gepd.is_active = 'Y'
                             AND gepd.internal_gmr_ref_no =
                                                         p_internal_gmr_ref_no)
      UNION ALL
--Delivery Item based for Pledge GMR Elements
      SELECT p_docrefno, pfd.pfd_id, aml.attribute_name elementname,
             axs.action_ref_no pricefixationrefno,
             TO_CHAR (pfd.as_of_date, 'dd-Mon-YYYY') pricefixationdate,
             NVL (pfd.user_price, 0) price, pum.price_unit_name,
             NVL (pfd.qty_fixed, 0) pricedqty, qum.qty_unit,
             DECODE (pocd.pay_in_cur_id,
                     pocd.pricing_cur_id, 1,
                     pfd.fx_rate
                    ) fx_rate,
             payin_pum.price_unit_name pay_price_unit_name,
                DECODE (pocd.qp_period_type,
                        'Event', 'Event Based ',
                        'DI Based '
                       )
             || DECODE (pocd.is_any_day_pricing,
                        'Y', DECODE (pocd.qp_period_type,
                                     'Event', 'Any Day / Spot',
                                        'Any Day / Spot '
                                     || pcdi.price_allocation_method
                                    ),
                        DECODE (pocd.qp_period_type, 'Date', '', 'Average')
                       ) pricetype,
             (   pcbpd.qty_to_be_priced
              || '% of '
              || (CASE
                     WHEN pcbpd.price_basis = 'Formula'
                        THEN    ppfh.formula_name
                             || ' - '
                             || (SELECT   stragg
                                             (   dim.instrument_name
                                              || ' - '
                                              || ps.price_source_name
                                              || ' '
                                              || pp.price_point_name
                                              || ' '
                                              || apm.available_price_display_name
                                             )
                                     FROM dim_der_instrument_master dim,
                                          ppfd_phy_price_formula_details ppfd,
                                          pp_price_point pp,
                                          ps_price_source ps,
                                          apm_available_price_master apm
                                    WHERE dim.instrument_id =
                                                            ppfd.instrument_id
                                      AND ppfd.is_active = 'Y'
                                      AND ppfh.ppfh_id = ppfd.ppfh_id
                                      AND ppfd.price_point_id = pp.price_point_id(+)
                                      AND ppfd.price_source_id =
                                                            ps.price_source_id
                                      AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                                 GROUP BY ppfh.ppfh_id)
                     WHEN pcbpd.price_basis = 'Index'
                        THEN (SELECT    dim.instrument_name
                                     || ' - '
                                     || ps.price_source_name
                                     || ' '
                                     || pp.price_point_name
                                     || ' '
                                     || apm.available_price_display_name
                                FROM dim_der_instrument_master dim,
                                     ppfd_phy_price_formula_details ppfd,
                                     pp_price_point pp,
                                     ps_price_source ps,
                                     apm_available_price_master apm
                               WHERE dim.instrument_id = ppfd.instrument_id
                                 AND ppfd.is_active = 'Y'
                                 AND ppfh.ppfh_id = ppfd.ppfh_id
                                 AND ppfd.price_point_id = pp.price_point_id(+)
                                 AND ppfd.price_source_id = ps.price_source_id
                                 AND ppfd.available_price_type_id =
                                                        apm.available_price_id)
                  END
                 )
              || (CASE
                     WHEN pocd.qp_period_type = 'Event'
                        THEN    ', '
                             || pfqpp.no_of_event_months
                             || ' '
                             || pfqpp.event_name
                  END
                 )
             ) pricingformula,
             (   TO_CHAR (pofh.qp_start_date, 'dd-Mon-yyyy')
              || ' to '
              || TO_CHAR (pofh.qp_end_date, 'dd-Mon-yyyy')
             ) qpperiod
        FROM gmr_goods_movement_record gmr,
             gcim_gmr_contract_item_mapping gcim,
             pci_physical_contract_item pci,
             pcdi_pc_delivery_item pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details pfd,
             aml_attribute_master_list aml,
             qum_quantity_unit_master qum,
             pfam_price_fix_action_mapping pfam,
             axs_action_summary axs,
             pcbpd_pc_base_price_detail pcbpd,
             ppfh_phy_price_formula_header ppfh,
             pfqpp_phy_formula_qp_pricing pfqpp,
             ppu_product_price_units ppu,
             pum_price_unit_master pum,
             ppu_product_price_units payin_ppu,
             pum_price_unit_master payin_pum
       WHERE gmr.internal_gmr_ref_no = gcim.internal_gmr_ref_no
         AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
         AND pci.pcdi_id = pcdi.pcdi_id
         AND pcdi.pcdi_id = poch.pcdi_id
         AND poch.poch_id = pocd.poch_id
         AND pocd.pocd_id = pofh.pocd_id
         AND poch.element_id = aml.attribute_id(+)
         AND pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
         AND pcdi.is_active = 'Y'
         AND poch.is_active = 'Y'
         AND pocd.is_active = 'Y'
         AND pofh.is_active = 'Y'
         AND pofh.pofh_id = pfd.pofh_id
         AND pfd.is_active = 'Y'
         AND pfd.pfd_id = pfam.pfd_id
         AND pfam.internal_action_ref_no = axs.internal_action_ref_no
         AND pfam.is_active = 'Y'
         AND NVL (pfd.is_hedge_correction, 'N') = 'N'
         AND pocd.pcbpd_id = pcbpd.pcbpd_id
         AND pcbpd.pcbpd_id = ppfh.pcbpd_id
         AND pfqpp.ppfh_id = ppfh.ppfh_id
         AND pcbpd.is_active = 'Y'
         AND ppfh.is_active = 'Y'
         AND ppfh.ppfh_id = pfqpp.ppfh_id
         AND pfd.price_unit_id = ppu.internal_price_unit_id
         AND ppu.price_unit_id = pum.price_unit_id
         AND pocd.pay_in_price_unit_id = payin_ppu.internal_price_unit_id
         AND payin_ppu.price_unit_id = payin_pum.price_unit_id
         AND pofh.internal_gmr_ref_no IS NULL
         AND pocd.qp_period_type NOT IN ('Event')
         AND pcdi.price_allocation_method NOT IN ('Price Allocation')
         AND poch.element_id IN (
                SELECT DISTINCT gepd.element_id
                           FROM gepd_gmr_element_pledge_detail gepd
                          WHERE gepd.is_active = 'Y'
                            AND gepd.internal_gmr_ref_no =
                                                         p_internal_gmr_ref_no)
         AND gmr.internal_gmr_ref_no =
                (SELECT DISTINCT gepd.pledge_input_gmr
                            FROM gepd_gmr_element_pledge_detail gepd
                           WHERE gepd.is_active = 'Y'
                             AND gepd.internal_gmr_ref_no =
                                                         p_internal_gmr_ref_no)
-- price allocation  pledged gmr elements
-- fixation for  pledged gmr is differentiated by internal_pledge_gmr_ref_no column.
      UNION ALL
      SELECT p_docrefno, pfd.pfd_id, aml.attribute_name elementname,
             axs.action_ref_no pricefixationrefno,
             TO_CHAR (pfd.as_of_date, 'dd-Mon-YYYY') pricefixationdate,
             NVL (pfd.user_price, 0) price, pum.price_unit_name,
             NVL (pfd.qty_fixed, 0) pricedqty, qum.qty_unit,
             DECODE (pocd.pay_in_cur_id,
                     pocd.pricing_cur_id, 1,
                     pfd.fx_rate
                    ) fx_rate,
             payin_pum.price_unit_name pay_price_unit_name,
                DECODE (pocd.qp_period_type,
                        'Event', 'Event Based ',
                        'DI Based '
                       )
             || DECODE (pocd.is_any_day_pricing,
                        'Y', DECODE (pocd.qp_period_type,
                                     'Event', 'Any Day / Spot',
                                        'Any Day / Spot '
                                     || pcdi.price_allocation_method
                                    ),
                        DECODE (pocd.qp_period_type, 'Date', '', 'Average')
                       ) pricetype,
             (   pcbpd.qty_to_be_priced
              || '% of '
              || (CASE
                     WHEN pcbpd.price_basis = 'Formula'
                        THEN    ppfh.formula_name
                             || ' - '
                             || (SELECT   stragg
                                             (   dim.instrument_name
                                              || ' - '
                                              || ps.price_source_name
                                              || ' '
                                              || pp.price_point_name
                                              || ' '
                                              || apm.available_price_display_name
                                             )
                                     FROM dim_der_instrument_master dim,
                                          ppfd_phy_price_formula_details ppfd,
                                          pp_price_point pp,
                                          ps_price_source ps,
                                          apm_available_price_master apm
                                    WHERE dim.instrument_id =
                                                            ppfd.instrument_id
                                      AND ppfd.is_active = 'Y'
                                      AND ppfh.ppfh_id = ppfd.ppfh_id
                                      AND ppfd.price_point_id = pp.price_point_id(+)
                                      AND ppfd.price_source_id =
                                                            ps.price_source_id
                                      AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                                 GROUP BY ppfh.ppfh_id)
                     WHEN pcbpd.price_basis = 'Index'
                        THEN (SELECT    dim.instrument_name
                                     || ' - '
                                     || ps.price_source_name
                                     || ' '
                                     || pp.price_point_name
                                     || ' '
                                     || apm.available_price_display_name
                                FROM dim_der_instrument_master dim,
                                     ppfd_phy_price_formula_details ppfd,
                                     pp_price_point pp,
                                     ps_price_source ps,
                                     apm_available_price_master apm
                               WHERE dim.instrument_id = ppfd.instrument_id
                                 AND ppfd.is_active = 'Y'
                                 AND ppfh.ppfh_id = ppfd.ppfh_id
                                 AND ppfd.price_point_id = pp.price_point_id(+)
                                 AND ppfd.price_source_id = ps.price_source_id
                                 AND ppfd.available_price_type_id =
                                                        apm.available_price_id)
                  END
                 )
              || (CASE
                     WHEN pocd.qp_period_type = 'Event'
                        THEN    ', '
                             || pfqpp.no_of_event_months
                             || ' '
                             || pfqpp.event_name
                  END
                 )
             ) pricingformula,
             (   TO_CHAR (pofh.qp_start_date, 'dd-Mon-yyyy')
              || ' to '
              || TO_CHAR (pofh.qp_end_date, 'dd-Mon-yyyy')
             ) qpperiod
        FROM gmr_goods_movement_record gmr,
             pcdi_pc_delivery_item pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             gpah_gmr_price_alloc_header gpah,
             gpad_gmr_price_alloc_dtls gpad,
             aml_attribute_master_list aml,
             qum_quantity_unit_master qum,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details pfd,
             pfam_price_fix_action_mapping pfam,
             axs_action_summary axs,
             pcbpd_pc_base_price_detail pcbpd,
             ppfh_phy_price_formula_header ppfh,
             pfqpp_phy_formula_qp_pricing pfqpp,
             ppu_product_price_units ppu,
             pum_price_unit_master pum,
             ppu_product_price_units payin_ppu,
             pum_price_unit_master payin_pum
       WHERE gmr.internal_gmr_ref_no = gpah.internal_gmr_ref_no
         AND gpah.pocd_id = pocd.pocd_id
         AND pocd.poch_id = poch.poch_id
         AND poch.pcdi_id = pcdi.pcdi_id
         AND gpah.element_id = aml.attribute_id(+)
         AND gpah.qty_unit_id = qum.qty_unit_id
         AND pofh.pocd_id = gpah.pocd_id
         AND pofh.internal_gmr_ref_no IS NULL
         AND gpah.gpah_id = gpad.gpah_id
         AND gpad.pfd_id = pfd.pfd_id
         AND pfd.pfd_id = pfam.pfd_id
         AND pocd.is_active = 'Y'
         AND poch.is_active = 'Y'
         AND pcdi.is_active = 'Y'
         AND gpah.is_active = 'Y'
         AND gpad.is_active = 'Y'
         AND pfd.is_active = 'Y'
         AND pfam.internal_action_ref_no = axs.internal_action_ref_no
         AND pfam.is_active = 'Y'
         AND NVL (pfd.is_hedge_correction, 'N') = 'N'
         AND pocd.pcbpd_id = pcbpd.pcbpd_id
         AND pcbpd.pcbpd_id = ppfh.pcbpd_id
         AND pfqpp.ppfh_id = ppfh.ppfh_id
         AND pcbpd.is_active = 'Y'
         AND ppfh.is_active = 'Y'
         AND ppfh.ppfh_id = pfqpp.ppfh_id
         AND pfd.price_unit_id = ppu.internal_price_unit_id
         AND ppu.price_unit_id = pum.price_unit_id
         AND pocd.pay_in_price_unit_id = payin_ppu.internal_price_unit_id
         AND payin_ppu.price_unit_id = payin_pum.price_unit_id
         AND pfd.internal_pledge_gmr_ref_no IS NOT NULL
         AND gpah.element_id IN (
                SELECT DISTINCT gepd.element_id
                           FROM gepd_gmr_element_pledge_detail gepd
                          WHERE gepd.is_active = 'Y'
                            AND gepd.internal_gmr_ref_no =
                                                         p_internal_gmr_ref_no)
         AND gmr.internal_gmr_ref_no =
                (SELECT DISTINCT gepd.pledge_input_gmr
                            FROM gepd_gmr_element_pledge_detail gepd
                           WHERE gepd.is_active = 'Y'
                             AND gepd.internal_gmr_ref_no =
                                                         p_internal_gmr_ref_no);
END;
/