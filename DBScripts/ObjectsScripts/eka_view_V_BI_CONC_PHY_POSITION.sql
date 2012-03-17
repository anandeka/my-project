CREATE OR REPLACE VIEW V_BI_CONC_PHY_POSITION AS
SELECT 'Composite' product_type,
          'Concentrates Open Contracts' section_name, pcm.corporate_id,
          akc.corporate_name, blm.business_line_id, blm.business_line_name,
          cpc.profit_center_id, cpc.profit_center_short_name,
          cpc.profit_center_name, css.strategy_id, css.strategy_name,
          pdm.product_id, pdm.product_desc, pgm.product_group_id,
          pgm.product_group_name product_group,
          NVL (qat.product_origin_id, 'NA') origin_id,
          NVL (orm.origin_name, 'NA') origin_name, qat.quality_id,
          qat.quality_name,
          (CASE
              WHEN pcm.purchase_sales = 'P' AND pcm.is_tolling_contract = 'N'
                 THEN 'Purchase Contract'
              WHEN pcm.purchase_sales = 'S' AND pcm.is_tolling_contract = 'N'
                 THEN 'Sales Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through = 'Y'
                 THEN 'Internal Buy Tolling Service Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through = 'N'
                 THEN 'Buy Tolling Service Contract'
              WHEN pcm.purchase_sales = 'S' AND pcm.is_tolling_contract = 'Y'
                 THEN 'Sell Tolling Service Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through IS NULL
                 THEN 'Tolling Service Contract'
           END
          ) contract_type,
          CASE
             WHEN pcm.purchase_sales = 'P'
                THEN 'Physical - Open Purchase'
             ELSE 'Physical - Open Sales'
          END AS position_type_id,
          'Physical' AS position_type,
          CASE
             WHEN pcm.purchase_sales = 'P'
                THEN 'Open Purchase'
             ELSE 'Open Sales'
          END AS position_sub_type,
             pcm.contract_ref_no
          || ','
          || pci.del_distribution_item_no contract_ref_no,
          NVL (pcm.cp_contract_ref_no, 'NA') cp_contract_ref_no,
          pcm.issue_date, pcm.cp_id counter_party_id,
          phd_contract_cp.companyname counter_party_name,
          gab.gabid trader_user_id,
          gab.firstname || ' ' || gab.lastname trader_user_name,
          pcm.partnership_type execution_type, 'NA' broker_profile_id,
          'NA' broker_name, itm.incoterm_id, itm.incoterm,
          pym.payment_term_id, pym.payment_term,
          CASE
             WHEN itm.location_field = 'ORIGINATION'
                THEN pcdb.country_id
             ELSE 'NA'
          END origination_country_id,
          CASE
             WHEN itm.location_field = 'ORIGINATION'
                THEN cym_pcdb.country_name
             ELSE 'NA'
          END origination_country,
          CASE
             WHEN itm.location_field = 'ORIGINATION'
                THEN cim_pcdb.city_id
             ELSE 'NA'
          END origination_city_id,
          CASE
             WHEN itm.location_field = 'ORIGINATION'
                THEN cim_pcdb.city_name
             ELSE 'NA'
          END origination_city,
          NVL (pcdi.item_price_type, 'NA') price_type_name,
          pcm.invoice_currency_id pay_in_cur_id,
          cm_invoice_cur.cur_code pay_in_cur_code, 'NA' item_price_string,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN pcdb.country_id
             ELSE 'NA'
          END dest_country_id,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN cym_pcdb.country_name
             ELSE 'NA'
          END dest_country_name,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN cim_pcdb.city_id
             ELSE 'NA'
          END dest_city_id,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN cim_pcdb.city_name
             ELSE 'NA'
          END dest_city_name,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN sm_pcdb.state_id
             ELSE 'NA'
          END dest_state_id,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN sm_pcdb.state_name
             ELSE 'NA'
          END dest_state_name,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN rem_pcdb.region_name
             ELSE 'NA'
          END dest_loc_group_name,
             pci.expected_delivery_month
          || '-'
          || pci.expected_delivery_year period_month_year,
          CASE
             WHEN pci.delivery_period_type = 'Date'
             AND pci.is_called_off = 'Y'
                THEN pci.delivery_from_date
             ELSE TO_DATE (   '01-'
                           || pci.expected_delivery_month
                           || '-'
                           || pci.expected_delivery_year,
                           'dd-Mon-yyyy'
                          )
          END delivery_from_date,
          CASE
             WHEN pci.delivery_period_type = 'Date'
             AND pci.is_called_off = 'Y'
                THEN pci.delivery_to_date
             ELSE TO_DATE (   '01-'
                           || pci.expected_delivery_month
                           || '-'
                           || pci.expected_delivery_year,
                           'dd-Mon-yyyy'
                          )
          END delivery_to_date,
            ciqs.open_qty
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN   (CASE
                              WHEN rm.ratio_name = '%'
                                 THEN   pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   ciqs.item_qty_unit_id,
                                                   gcd.group_qty_unit_id,
                                                   1
                                                  )
                                      / 100
                              ELSE   pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   ciqs.item_qty_unit_id,
                                                   rm.qty_unit_id_denominator,
                                                   1
                                                  )
                                   * pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   rm.qty_unit_id_numerator,
                                                   gcd.group_qty_unit_id,
                                                   1
                                                  )
                           END
                          )
                        * pqca.typical
                ELSE (pkg_general.f_get_converted_quantity
                                                       (pcpd.product_id,
                                                        ciqs.item_qty_unit_id,
                                                        gcd.group_qty_unit_id,
                                                        1
                                                       )
                     )
             END
            ) qty_in_group_unit,
          qum_gcd.qty_unit group_qty_unit,
            ciqs.open_qty
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN   (CASE
                              WHEN rm.ratio_name = '%'
                                 THEN   pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   ciqs.item_qty_unit_id,
                                                   ciqs.item_qty_unit_id,
                                                   1
                                                  )
                                      / 100
                              ELSE   pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   ciqs.item_qty_unit_id,
                                                   rm.qty_unit_id_denominator,
                                                   1
                                                  )
                                   * pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   rm.qty_unit_id_numerator,
                                                   ciqs.item_qty_unit_id,
                                                   1
                                                  )
                           END
                          )
                        * pqca.typical
                ELSE (pkg_general.f_get_converted_quantity
                                                       (pcpd.product_id,
                                                        ciqs.item_qty_unit_id,
                                                        ciqs.item_qty_unit_id,
                                                        1
                                                       )
                     )
             END
            ) qty_in_ctract_unit,
          qum_ciqs.qty_unit ctract_qty_unit,
          cm_base_cur.cur_code corp_base_cur,
             pci.expected_delivery_month
          || '-'
          || pci.expected_delivery_year delivery_month,
          pcm.invoice_currency_id invoice_cur_id,
          cm_invoice_cur.cur_code invoice_cur_code,
          qum_under.qty_unit base_qty_unit,
            ciqs.open_qty
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN   (CASE
                              WHEN rm.ratio_name = '%'
                                 THEN   pkg_general.f_get_converted_quantity
                                           (NVL (pdm_under.product_id,
                                                 pdm.product_id
                                                ),
                                            ciqs.item_qty_unit_id,
                                            NVL (pdm_under.base_quantity_unit,
                                                 pdm.base_quantity_unit
                                                ),
                                            1
                                           )
                                      / 100
                              ELSE   pkg_general.f_get_converted_quantity
                                            (NVL (pdm_under.product_id,
                                                  pdm.product_id
                                                 ),
                                             ciqs.item_qty_unit_id,
                                             NVL (rm.qty_unit_id_denominator,
                                                  pdm.base_quantity_unit
                                                 ),
                                             1
                                            )
                                   * pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           rm.qty_unit_id_numerator,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                           END
                          )
                        * pqca.typical
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       ciqs.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_base_unit,
             CASE
                WHEN itm.location_field = 'DESTINATION'
                   THEN pcdb.country_id
                ELSE 'NA'
             END
          || ' - '
          || CASE
                WHEN itm.location_field = 'DESTINATION'
                   THEN pcdb.city_id
                ELSE 'NA'
             END comb_destination_id,
             CASE
                WHEN itm.location_field = 'ORIGINATION'
                   THEN pcdb.country_id
                ELSE 'NA'
             END
          || ' - '
          || CASE
                WHEN itm.location_field = 'ORIGINATION'
                   THEN pcdb.city_id
                ELSE 'NA'
             END comb_origination_id,
          pci.m2m_country_id || ' - '
          || pci.m2m_city_id comb_valuation_loc_id,
          pdm_under.product_desc element_name, nvl(phd_wh.profileid,'NA') warehouse_profile_id,
          nvl(phd_wh.companyname,'NA') warehouse_name,
          nvl(sld.storage_loc_id,'NA') shed_id,
          nvl(sld.storage_location_name,'NA') shed_name
     FROM pcdi_pc_delivery_item pcdi,
          pcm_physical_contract_main pcm,
          pci_physical_contract_item pci,
          pcmte_pcm_tolling_ext pcmte,
          poch_price_opt_call_off_header poch,
          aml_attribute_master_list aml,
          pdm_productmaster pdm_under,
          ciqs_contract_item_qty_status ciqs,
          pcpd_pc_product_definition pcpd,
          pcpq_pc_product_quality pcpq,
          pcdb_pc_delivery_basis pcdb,
          ak_corporate akc,
          cpc_corporate_profit_center cpc,
          blm_business_line_master blm,
          css_corporate_strategy_setup css,
          pdm_productmaster pdm,
          pgm_product_group_master pgm,
          qat_quality_attributes qat,
          ak_corporate_user akcu,
          gab_globaladdressbook gab,
          itm_incoterm_master itm,
          pym_payment_terms_master pym,
          cm_currency_master cm_base_cur,
          cm_currency_master cm_invoice_cur,
          phd_profileheaderdetails phd_contract_cp,
          pom_product_origin_master pom,
          orm_origin_master orm,
          cym_countrymaster cym_pcdb,
          cim_citymaster cim_pcdb,
          rem_region_master rem_pcdb,
          sm_state_master sm_pcdb,
          qum_quantity_unit_master qum_ciqs,
          gcd_groupcorporatedetails gcd,
          qum_quantity_unit_master qum_gcd,
          ucm_unit_conversion_master ucm,
          v_ucm_conversion ucm_base,
          ash_assay_header vsh,
          qum_quantity_unit_master qum_under,
          pdtm_product_type_master pdtm,
          asm_assay_sublot_mapping asm,
          pqca_pq_chemical_attributes pqca,
          rm_ratio_master rm,
          phd_profileheaderdetails phd_wh,
          sld_storage_location_detail sld
    WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
      AND pcdi.pcdi_id = pci.pcdi_id
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
      AND pcdi.pcdi_id = poch.pcdi_id
      AND poch.element_id = aml.attribute_id
      AND poch.is_active = 'Y'
      AND aml.underlying_product_id = pdm_under.product_id
      AND pcm.contract_status = 'In Position'
      AND pcm.contract_type = 'CONCENTRATES'
      AND pci.internal_contract_item_ref_no = ciqs.internal_contract_item_ref_no
      AND pci.is_active = 'Y'
      AND pcdi.is_active = 'Y'
      AND ciqs.is_active = 'Y'
      AND ciqs.open_qty > 0
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.is_active = 'Y'
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pcpq.is_active = 'Y'
      AND pci.pcdb_id = pcdb.pcdb_id
      AND pcdb.is_active = 'Y'
      AND pcm.corporate_id = akc.corporate_id
      AND pcpd.profit_center_id = cpc.profit_center_id
      AND cpc.business_line_id = blm.business_line_id
      AND pcpd.strategy_id = css.strategy_id
      AND pcpd.product_id = pdm.product_id
      AND pdm.product_group_id = pgm.product_group_id
      AND pcpq.quality_template_id = qat.quality_id
      AND pcm.trader_id = akcu.user_id
      AND akcu.gabid = gab.gabid
      AND pcdb.inco_term_id = itm.incoterm_id
      AND pcm.payment_term_id = pym.payment_term_id
      AND cm_base_cur.cur_id = akc.base_cur_id
      AND akc.base_cur_id = cm_invoice_cur.cur_id
      AND pcm.cp_id = phd_contract_cp.profileid
      AND qat.product_origin_id = pom.product_origin_id(+)
      AND pcpq.assay_header_id = vsh.ash_id
      AND pom.origin_id = orm.origin_id(+)
      AND cym_pcdb.country_id = pcdb.country_id
      AND cim_pcdb.city_id = pcdb.city_id
      AND sm_pcdb.state_id = pcdb.state_id
      AND cym_pcdb.region_id = rem_pcdb.region_id
      AND ciqs.item_qty_unit_id = qum_ciqs.qty_unit_id
      AND akc.groupid = gcd.groupid
      AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id
      AND ucm.from_qty_unit_id = ciqs.item_qty_unit_id
      AND ucm.to_qty_unit_id = gcd.group_qty_unit_id
      AND ciqs.item_qty_unit_id = ucm_base.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      AND pdm_under.base_quantity_unit = qum_under.qty_unit_id
      AND pcpq.quality_template_id = qat.quality_id
      AND pdm.product_type_id = pdtm.product_type_id
      AND vsh.ash_id = asm.ash_id
      AND asm.asm_id = pqca.asm_id
      AND pcpd.input_output = 'Input'
      AND pqca.element_id = aml.attribute_id
      AND pqca.is_elem_for_pricing = 'Y'
      AND pqca.unit_of_measure = rm.ratio_id(+)
      and pcdb.warehouse_id = phd_wh.profileid(+)
      and pcdb.warehouse_shed_id = sld.storage_loc_id(+)
   UNION ALL
-- 2. shipped but not tt for purchase gmrs
   SELECT 'Composite' product_type,
          'Concentrates Shipped But Not TT for Purchase GMRs' section_name,
          gmr.corporate_id corporate_id, akc.corporate_name corporate_name,
          blm.business_line_id business_line_id,
          blm.business_line_name business_line_name,
          cpc.profit_center_id profit_center_id,
          cpc.profit_center_short_name profit_center_short_name,
          cpc.profit_center_name profit_center_name,
          css.strategy_id strategy_id, css.strategy_name strategy_name,
          grd.product_id product_id, pdm.product_desc product_desc,
          pgm.product_group_id, pgm.product_group_name product_group,
          'NA' origin_id, 'NA' origin_name, grd.quality_id quality_id,
          qat.quality_name quality_name,
          (CASE
              WHEN pcm.purchase_sales = 'P' AND pcm.is_tolling_contract = 'N'
                 THEN 'Purchase Contract'
              WHEN pcm.purchase_sales = 'S' AND pcm.is_tolling_contract = 'N'
                 THEN 'Sales Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through = 'Y'
                 THEN 'Internal Buy Tolling Service Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through = 'N'
                 THEN 'Buy Tolling Service Contract'
              WHEN pcm.purchase_sales = 'S' AND pcm.is_tolling_contract = 'Y'
                 THEN 'Sell Tolling Service Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through IS NULL
                 THEN 'Tolling Service Contract'
           END
          ) contract_type,
          CASE
             WHEN pci.purchase_sales = 'P'
                THEN 'Physical - Open Purchase'
             ELSE 'Physical - Open Sales'
          END position_type_id,
          'Physical' position_type,
          CASE
             WHEN pci.purchase_sales = 'P'
                THEN 'Open Purchase'
             ELSE 'Open Sales'
          END position_sub_type,
          CASE
             WHEN pci.contract_ref_no IS NOT NULL
                THEN    gmr.gmr_ref_no
                     || ','
                     || pci.contract_ref_no
                     || ','
                     || pci.del_distribution_item_no
             ELSE gmr.gmr_ref_no
          END contract_ref_no,
          NVL (pci.cp_contract_ref_no, 'NA') external_reference_no,
          gmr.eff_date issue_date, pci.cp_id counter_party_id,
          phd_pcm_cp.companyname counter_party_name, gab.gabid trader_user_id,
          gab.firstname || ' ' || gab.lastname trader_name,
          pcm.partnership_type execution_type, 'NA' broker_profile_id,
          'NA' broker_name, pci.incoterm_id incoterm_id,
          itm.incoterm incoterm, pci.payment_term_id payment_term_id,
          pym.payment_term payment_term, 'NA' origination_country_id,
          'NA' origination_country, 'NA' origination_city_id,
          'NA' origination_city,
          NVL (pcdi.item_price_type, 'NA') price_type_name,
          pci.invoice_currency_id pay_in_cur_id,
          cm_invoice_currency.cur_code pay_in_cur_code,
          'NA' item_price_string,
          NVL (cym_gmr_dest_country.country_id, 'NA') dest_country_id,
          NVL (cym_gmr_dest_country.country_name, 'NA') dest_country_name,
          NVL (cim_gmr_dest_city.city_id, 'NA') dest_city_id,
          NVL (cim_gmr_dest_city.city_name, 'NA') dest_city_name,
          NVL (sm_gmr.state_id, 'NA') dest_state_id,
          NVL (sm_gmr.state_name, 'NA') dest_state_name,
          NVL (rem_gmr_dest_region.region_name, 'NA') dest_loc_group_name,
          '' period_month_year,
          CASE
             WHEN pci.delivery_period_type = 'Date'
             AND pci.is_called_off = 'Y'
                THEN pci.delivery_from_date
             ELSE TO_DATE (   '01-'
                           || pci.expected_delivery_month
                           || '-'
                           || pci.expected_delivery_year,
                           'dd-Mon-yyyy'
                          )
          END delivery_from_date,
          CASE
             WHEN pci.delivery_period_type = 'Date'
             AND pci.is_called_off = 'Y'
                THEN pci.delivery_from_date
             ELSE TO_DATE (   '01-'
                           || pci.expected_delivery_month
                           || '-'
                           || pci.expected_delivery_year,
                           'dd-Mon-yyyy'
                          )
          END delivery_to_date,
            pkg_report_general.fn_get_element_assay_qty
                        (aml.attribute_id,
                         vsp.ash_id,
                         'Wet',
                         (  NVL (grd.current_qty, 0)
                          + NVL (grd.release_shipped_qty, 0)
                          - NVL (grd.title_transfer_out_qty, 0)
                         ),
                         grd.qty_unit_id
                        )
          * ucm_base.multiplication_factor
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   rm.qty_unit_id_numerator,
                                                   qum_gcd.qty_unit_id,
                                                   1
                                                  )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_group_unit,
          qum_gcd.qty_unit group_qty_unit,
            pkg_report_general.fn_get_element_assay_qty
                       (aml.attribute_id,
                        vsp.ash_id,
                        'Wet',
                        (  NVL (grd.current_qty, 0)
                         + NVL (grd.release_shipped_qty, 0)
                         - NVL (grd.title_transfer_out_qty, 0)
                        ),
                        grd.qty_unit_id
                       )
          * ucm.multiplication_factor
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                grd.qty_unit_id
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   rm.qty_unit_id_numerator,
                                                   grd.qty_unit_id,
                                                   1
                                                  )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_ctract_unit,
          grd.qty_unit_id ctract_qty_unit,
          cm_base_currency.cur_code corp_base_cur,
             pci.expected_delivery_month
          || '-'
          || pci.expected_delivery_year delivery_month,
          pci.invoice_currency_id invoice_cur_id,
          cm_invoice_currency.cur_code invoice_cur_code,
          qum_under.qty_unit base_qty_unit,
            pkg_report_general.fn_get_element_assay_qty
                         (aml.attribute_id,
                          vsp.ash_id,
                          'Wet',
                          (  NVL (grd.current_qty, 0)
                           + NVL (grd.release_shipped_qty, 0)
                           - NVL (grd.title_transfer_out_qty, 0)
                          ),
                          grd.qty_unit_id
                         )
          * ucm_base.multiplication_factor
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           rm.qty_unit_id_numerator,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_base_unit,
             NVL (cym_gmr_dest_country.country_id, 'NA')
          || ' - '
          || NVL (cim_gmr_dest_city.city_id, 'NA') comb_destination_id,
          'NA-NA' comb_origination_id,
             NVL
                (CASE
                    WHEN grd.is_afloat = 'Y'
                       THEN cym_gmr.country_id
                    ELSE cym_sld.country_id
                 END,
                 'NA'
                )
          || ' - '
          || NVL (CASE
                     WHEN grd.is_afloat = 'Y'
                        THEN cim_gmr.city_id
                     ELSE cim_sld.city_id
                  END,
                  'NA'
                 ) comb_valuation_loc_id,
          pdm_under.product_desc element_name, nvl(phd_wh.profileid,'NA'),
          nvl(phd_wh.companyname,'NA'),
          nvl(sld.storage_loc_id,'NA'),
          nvl(sld.storage_location_name,'NA')
     FROM grd_goods_record_detail grd,
          gmr_goods_movement_record gmr,
          pcm_physical_contract_main pcm,
          pcmte_pcm_tolling_ext pcmte,
          pcpd_pc_product_definition pcpd,
          ppm_product_properties_mapping ppm,
          qav_quality_attribute_values qav,
          pcpq_pc_product_quality pcpq,
          sld_storage_location_detail sld,
          cim_citymaster cim_sld,
          cim_citymaster cim_gmr,
          cym_countrymaster cym_sld,
          cym_countrymaster cym_gmr,
          sm_state_master sm_gmr,
          v_pci_pcdi_details pci,
          pdm_productmaster pdm,
          pgm_product_group_master pgm,
          pdtm_product_type_master pdtm,
          qum_quantity_unit_master qum,
          itm_incoterm_master itm,
          css_corporate_strategy_setup css,
          cpc_corporate_profit_center cpc,
          blm_business_line_master blm,
          ak_corporate akc,
          gcd_groupcorporatedetails gcd,
          gab_globaladdressbook gab,
          phd_profileheaderdetails phd_pcm_cp,
          pym_payment_terms_master pym,
          cm_currency_master cm_invoice_currency,
          cim_citymaster cim_gmr_dest_city,
          cym_countrymaster cym_gmr_dest_country,
          rem_region_master rem_gmr_dest_region,
          qum_quantity_unit_master qum_gcd,
          ucm_unit_conversion_master ucm,
          cm_currency_master cm_base_currency,
          pcdi_pc_delivery_item pcdi,
          qum_quantity_unit_master qum_under,
          poch_price_opt_call_off_header poch,
          aml_attribute_master_list aml,
          pdm_productmaster pdm_under,
          v_ucm_conversion ucm_base,
          v_stock_position_assay_id vsp,
          ash_assay_header vdc,
          ak_corporate_user aku,
          qat_quality_attributes qat,
          asm_assay_sublot_mapping asm,
          pqca_pq_chemical_attributes pqca,
          rm_ratio_master rm,
          phd_profileheaderdetails phd_wh
    WHERE grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.product_id = ppm.product_id
      AND pqca.element_id = ppm.attribute_id
      AND ppm.is_active = 'Y'
      AND ppm.is_deleted = 'N'
      AND ppm.property_id = qav.attribute_id
      AND pci.pcpq_id = pcpq.pcpq_id(+)
      AND pcpq.quality_template_id = qav.quality_id
      AND qav.is_deleted = 'N'
      AND grd.product_id = pdm.product_id
      AND pdm.product_group_id = pgm.product_group_id
      AND pdm.product_type_id = pdtm.product_type_id
      AND pdm.base_quantity_unit = qum.qty_unit_id
      AND grd.shed_id = sld.storage_loc_id(+)
      AND sld.city_id = cim_sld.city_id(+)
      AND gmr.discharge_city_id = cim_gmr.city_id(+)
      AND cim_sld.country_id = cym_sld.country_id(+)
      AND cim_gmr.country_id = cym_gmr.country_id(+)
      AND cim_gmr_dest_city.state_id = sm_gmr.state_id(+)
      AND grd.quality_id = qat.quality_id(+)
      AND gmr.corporate_id = akc.corporate_id
      AND akc.groupid = gcd.groupid
      AND grd.is_deleted = 'N'
      AND grd.status = 'Active'
      AND grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
      AND pci.inco_term_id = itm.incoterm_id(+)
      AND pci.strategy_id = css.strategy_id(+)
      AND pci.profit_center_id = cpc.profit_center_id(+)
      AND cpc.business_line_id = blm.business_line_id(+)
      AND (  NVL (grd.current_qty, 0)
           + NVL (grd.release_shipped_qty, 0)
           - NVL (grd.title_transfer_out_qty, 0)
          ) > 0
      AND gmr.created_by = aku.user_id
      AND aku.gabid = gab.gabid(+)
      AND pdtm.product_type_name = 'Composite'
      AND pci.cp_id = phd_pcm_cp.profileid(+)
      AND pci.payment_term_id = pym.payment_term_id(+)
      AND NVL (gmr.inventory_status, 'NA') = 'In'
      AND pci.invoice_currency_id = cm_invoice_currency.cur_id(+)
      AND cym_gmr_dest_country.country_id(+) = gmr.discharge_country_id
      AND cym_gmr_dest_country.region_id = rem_gmr_dest_region.region_id(+)
      AND cim_gmr_dest_city.city_id(+) = gmr.discharge_city_id
      AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id
      AND grd.qty_unit_id = ucm.from_qty_unit_id
      AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
      AND cm_base_currency.cur_id = akc.base_cur_id
      AND pci.pcdi_id = pcdi.pcdi_id
      AND pcdi.internal_contract_ref_no = pci.internal_contract_ref_no
      AND pcdi.pcdi_id = poch.pcdi_id
      AND poch.element_id = aml.attribute_id
      AND poch.is_active = 'Y'
      AND aml.underlying_product_id = pdm_under.product_id
      AND grd.qty_unit_id = ucm_base.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      AND grd.internal_grd_ref_no = vsp.internal_grd_ref_no
      AND vsp.ash_id = vdc.ash_id
      AND pdm_under.base_quantity_unit = qum_under.qty_unit_id
      AND vdc.ash_id = asm.ash_id
      AND asm.asm_id = pqca.asm_id
      AND pcpd.input_output = 'Input'
      AND pqca.element_id = aml.attribute_id
      AND pqca.is_elem_for_pricing = 'Y'
      AND pqca.unit_of_measure = rm.ratio_id(+)
      AND grd.warehouse_profile_id = phd_wh.profileid(+)
-- 3. shipped but not tt sales gmrs
   UNION ALL
   SELECT 'Composite' product_type,
          'Concentrates Shipped But Not TT for Sales GMRs' section_name,
          akc.corporate_id corporate_id, akc.corporate_name corporate_name,
          blm.business_line_id business_line_id,
          blm.business_line_name business_line_name,
          cpc.profit_center_id profit_center_id,
          cpc.profit_center_short_name profit_center_short_name,
          cpc.profit_center_name profit_center_name,
          css.strategy_id strategy_id, css.strategy_name strategy_name,
          pdm.product_id product_id, pdm.product_desc product_desc,
          pgm.product_group_id, pgm.product_group_name product_group,
          'NA' origin_id, 'NA' origin_name, qat.quality_id quality_id,
          qat.quality_name quality_name,
          (CASE
              WHEN pcm.purchase_sales = 'P' AND pcm.is_tolling_contract = 'N'
                 THEN 'Purchase Contract'
              WHEN pcm.purchase_sales = 'S' AND pcm.is_tolling_contract = 'N'
                 THEN 'Sales Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through = 'Y'
                 THEN 'Internal Buy Tolling Service Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through = 'N'
                 THEN 'Buy Tolling Service Contract'
              WHEN pcm.purchase_sales = 'S' AND pcm.is_tolling_contract = 'Y'
                 THEN 'Sell Tolling Service Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through IS NULL
                 THEN 'Tolling Service Contract'
           END
          ) contract_type,
          'Physical - Open Sales' position_type_id, 'Physical' position_type,
          'Open Sales' position_sub_type,
          CASE
             WHEN pci.contract_ref_no IS NOT NULL
                THEN    gmr.gmr_ref_no
                     || ','
                     || pci.contract_ref_no
                     || ','
                     || pci.del_distribution_item_no
             ELSE gmr.gmr_ref_no
          END contract_ref_no,
          NVL (pci.cp_contract_ref_no, 'NA') external_reference_no,
          pci.issue_date issue_date, pci.cp_id counter_party_id,
          phd_pcm_cp.companyname counter_party_name, gab.gabid trader_user_id,
          gab.firstname || ' ' || gab.lastname trader_name,
          pcm.partnership_type execution_type, 'NA' broker_profile_id,
          'NA' broker_name, itm.incoterm_id incoterm_id,
          itm.incoterm incoterm, pym.payment_term_id payment_term_id,
          pym.payment_term payment_term, 'NA' origination_country_id,
          'NA' origination_country, 'NA' origination_city_id,
          'NA' origination_city, 'NA' price_type_name,
          cm_invoice_curreny.cur_id pay_in_cur_id,
          cm_invoice_curreny.cur_code pay_in_cur_code, 'NA' item_price_string,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN pcdb.country_id
             ELSE 'NA'
          END destination_country_id,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN cym_pcdb.country_name
             ELSE 'NA'
          END destination_country,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN cim_pcdb.city_id
             ELSE 'NA'
          END destination_city_id,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN cim_pcdb.city_name
             ELSE 'NA'
          END destination_city,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN sm_pcdb.state_id
             ELSE 'NA'
          END dest_state_id,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN sm_pcdb.state_name
             ELSE 'NA'
          END dest_state_name,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN rem_gmr.region_name
             ELSE 'NA'
          END dest_loc_group_name,
          '' period_month_year,
          CASE
             WHEN pci.delivery_period_type = 'Date'
             AND pci.is_called_off = 'Y'
                THEN pci.delivery_from_date
             ELSE TO_DATE (   '01-'
                           || pci.expected_delivery_month
                           || '-'
                           || pci.expected_delivery_year,
                           'dd-Mon-yyyy'
                          )
          END delivery_from_date,
          CASE
             WHEN pci.delivery_period_type = 'Date'
             AND pci.is_called_off = 'Y'
                THEN pci.delivery_to_date
             ELSE TO_DATE (   '01-'
                           || pci.expected_delivery_month
                           || '-'
                           || pci.expected_delivery_year,
                           'dd-Mon-yyyy'
                          )
          END delivery_to_date,
            pkg_report_general.fn_get_element_assay_qty
                                   (aml.attribute_id,
                                    vsp.ash_id,
                                    'Wet',
                                    dgrd.current_qty,
                                    dgrd.net_weight_unit_id
                                   )
          * ucm_base.multiplication_factor
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   rm.qty_unit_id_numerator,
                                                   qum_gcd.qty_unit_id,
                                                   1
                                                  )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_group_unit,
          qum_gcd.qty_unit group_qty_unit,
            pkg_report_general.fn_get_element_assay_qty
                                  (aml.attribute_id,
                                   vsp.ash_id,
                                   'Wet',
                                   dgrd.current_qty,
                                   dgrd.net_weight_unit_id
                                  )
          * ucm.multiplication_factor
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                dgrd.net_weight_unit_id
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   rm.qty_unit_id_numerator,
                                                   dgrd.net_weight_unit_id,
                                                   1
                                                  )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_ctract_unit,
          qum_dgrd.qty_unit ctract_qty_unit,
          cm_base_cur.cur_code corp_base_cur,
          TO_CHAR (SYSDATE, 'Mon-yyyy') delivery_month,
          cm_invoice_curreny.cur_id invoice_cur_id,
          cm_invoice_curreny.cur_code invoice_cur_code,
          qum_under.qty_unit base_qty_unit,
            pkg_report_general.fn_get_element_assay_qty
                                    (aml.attribute_id,
                                     vsp.ash_id,
                                     'Wet',
                                     dgrd.current_qty,
                                     dgrd.net_weight_unit_id
                                    )
          * ucm_base.multiplication_factor
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           rm.qty_unit_id_numerator,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_base_unit,
             CASE
                WHEN itm.location_field = 'DESTINATION'
                   THEN pcdb.country_id
                ELSE 'NA'
             END
          || ' - '
          || CASE
                WHEN itm.location_field = 'DESTINATION'
                   THEN pcdb.city_id
                ELSE 'NA'
             END comb_destination_id,
          'NA' comb_origination_id, '' comb_valuation_loc_id,
          pdm_under.product_desc element_name, nvl(phd_wh.profileid,'NA'),
          nvl(phd_wh.companyname,'NA'),
          nvl(sld.storage_loc_id,'NA'),
          nvl(sld.storage_location_name,'NA')
     FROM dgrd_delivered_grd dgrd,
          gmr_goods_movement_record gmr,
          pcm_physical_contract_main pcm,
          pcmte_pcm_tolling_ext pcmte,
          pcpd_pc_product_definition pcpd,
          ppm_product_properties_mapping ppm,
          qav_quality_attribute_values qav,
          pcpq_pc_product_quality pcpq,
          sld_storage_location_detail sld,
          cim_citymaster cim_sld,
          cim_citymaster cim_gmr,
          cym_countrymaster cym_sld,
          cym_countrymaster cym_gmr,
          rem_region_master rem_gmr,
          v_pci_pcdi_details pci,
          poch_price_opt_call_off_header poch,
          aml_attribute_master_list aml,
          pdm_productmaster pdm_under,
          pdm_productmaster pdm,
          pgm_product_group_master pgm,
          pdtm_product_type_master pdtm,
          qum_quantity_unit_master qum,
          itm_incoterm_master itm,
          css_corporate_strategy_setup css,
          cpc_corporate_profit_center cpc,
          blm_business_line_master blm,
          ak_corporate akc,
          gcd_groupcorporatedetails gcd,
          gab_globaladdressbook gab,
          ak_corporate_user aku,
          pym_payment_terms_master pym,
          phd_profileheaderdetails phd_pcm_cp,
          cm_currency_master cm_invoice_curreny,
          pcdb_pc_delivery_basis pcdb,
          cim_citymaster cim_pcdb,
          cym_countrymaster cym_pcdb,
          sm_state_master sm_pcdb,
          qum_quantity_unit_master qum_gcd,
          qum_quantity_unit_master qum_dgrd,
          cm_currency_master cm_base_cur,
          ucm_unit_conversion_master ucm,
          v_ucm_conversion ucm_base,
          qat_quality_attributes qat,
          v_stock_position_assay_id vsp,
          ash_assay_header vdc,
          qum_quantity_unit_master qum_under,
          asm_assay_sublot_mapping asm,
          pqca_pq_chemical_attributes pqca,
          rm_ratio_master rm,
          phd_profileheaderdetails phd_wh
    WHERE dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.product_id = ppm.product_id
      AND pqca.element_id = ppm.attribute_id
      AND ppm.is_active = 'Y'
      AND ppm.is_deleted = 'N'
      AND ppm.property_id = qav.attribute_id
      AND pci.pcpq_id = pcpq.pcpq_id(+)
      AND pcpq.quality_template_id = qav.quality_id
      AND qav.is_deleted = 'N'
      AND dgrd.shed_id = sld.storage_loc_id(+)
      AND sld.city_id = cim_sld.city_id(+)
      AND gmr.discharge_city_id = cim_gmr.city_id(+)
      AND cim_sld.country_id = cym_sld.country_id(+)
      AND cim_gmr.country_id = cym_gmr.country_id(+)
      AND cym_gmr.region_id = rem_gmr.region_id(+)
      AND dgrd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
      AND dgrd.product_id = pdm.product_id
      AND pdm.product_group_id = pgm.product_group_id
      AND pdm.product_type_id = pdtm.product_type_id
      AND pdtm.product_type_name = 'Composite'
      AND pdm.base_quantity_unit = qum.qty_unit_id
      AND pci.inco_term_id = itm.incoterm_id(+)
      AND pci.strategy_id = css.strategy_id(+)
      AND pci.profit_center_id = cpc.profit_center_id(+)
      AND cpc.business_line_id = blm.business_line_id(+)
      AND NVL (dgrd.current_qty, 0) > 0
      AND NVL (dgrd.inventory_status, 'NA') <> 'Out'
      AND gmr.corporate_id = akc.corporate_id
      AND akc.groupid = gcd.groupid
      AND dgrd.status = 'Active'
      AND gmr.created_by = aku.user_id
      AND aku.gabid = gab.gabid(+)
      AND pci.payment_term_id = pym.payment_term_id(+)
      AND pci.cp_id = phd_pcm_cp.profileid(+)
      AND pci.invoice_currency_id = cm_invoice_curreny.cur_id(+)
      AND pcdb.internal_contract_ref_no = pci.internal_contract_ref_no
      AND pci.pcdb_id = pcdb.pcdb_id
      AND pcdb.is_active = 'Y'
      AND pci.pcdi_id = poch.pcdi_id
      AND poch.is_active = 'Y'
      AND poch.element_id = aml.attribute_id
      AND aml.underlying_product_id = pdm_under.product_id
      AND pcdb.city_id = cim_pcdb.city_id(+)
      AND pcdb.state_id = sm_pcdb.state_id(+)
      AND pcdb.country_id = cym_pcdb.country_id(+)
      AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id
      AND ucm.from_qty_unit_id = dgrd.net_weight_unit_id
      AND ucm.to_qty_unit_id = gcd.group_qty_unit_id
      AND cm_base_cur.cur_id = akc.base_cur_id
      AND qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id
      AND dgrd.net_weight_unit_id = ucm_base.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      AND qat.quality_id = dgrd.quality_id
      AND dgrd.internal_dgrd_ref_no = vsp.internal_grd_ref_no
      AND vsp.ash_id = vdc.ash_id
      AND pdm_under.base_quantity_unit = qum_under.qty_unit_id
      AND vdc.ash_id = asm.ash_id
      AND asm.asm_id = pqca.asm_id
      AND pcpd.input_output = 'Input'
      AND pqca.element_id = aml.attribute_id
      AND pqca.is_elem_for_pricing = 'Y'
      AND pqca.unit_of_measure = rm.ratio_id(+)
      AND dgrd.warehouse_profile_id = phd_wh.profileid(+)
   UNION ALL
--4
   SELECT 'Composite' product_type,
          'Concentrates TT out for Purchase  GMRs' section_name,
          gmr.corporate_id corporate_id, akc.corporate_name corporate_name,
          blm.business_line_id business_line_id,
          blm.business_line_name business_line_name,
          cpc.profit_center_id profit_center_id,
          cpc.profit_center_short_name profit_center_short_name,
          cpc.profit_center_name profit_center_name,
          css.strategy_id strategy_id, css.strategy_name strategy_name,
          grd.product_id product_id, pdm.product_desc product_desc,
          pgm.product_group_id, pgm.product_group_name product_group,
          'NA' origin_id, 'NA' origin_name, grd.quality_id quality_id,
          qat.quality_name quality_name,
          (CASE
              WHEN pcm.purchase_sales = 'P' AND pcm.is_tolling_contract = 'N'
                 THEN 'Purchase Contract'
              WHEN pcm.purchase_sales = 'S' AND pcm.is_tolling_contract = 'N'
                 THEN 'Sales Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through = 'Y'
                 THEN 'Internal Buy Tolling Service Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through = 'N'
                 THEN 'Buy Tolling Service Contract'
              WHEN pcm.purchase_sales = 'S' AND pcm.is_tolling_contract = 'Y'
                 THEN 'Sell Tolling Service Contract'
              WHEN pcm.purchase_sales = 'P'
              AND pcm.is_tolling_contract = 'Y'
              AND pcmte.is_pass_through IS NULL
                 THEN 'Tolling Service Contract'
           END
          ) contract_type,
          'Stocks -  Actual Stocks' position_type_id, 'Stocks' position_type,
          'Actual Stocks' position_sub_type,
          grd.internal_grd_ref_no contract_ref_no, 'NA' external_reference_no,
          gmr.eff_date issue_date, 'NA' counter_party_id,
          'NA' counter_party_name, 'NA' trader_user_id, 'NA' trader_name,
          pcm.partnership_type execution_type, 'NA' broker_profile_id,
          'NA' broker_name, 'NA' incoterm_id, 'NA' incoterm,
          'NA' payment_term_id, 'NA' payment_term,
          'NA' origination_country_id, 'NA' origination_country,
          'NA' origination_city_id, 'NA' origination_city,
          'NA' price_type_name, 'NA' pay_in_cur_id, 'NA' pay_in_cur_code,
          'NA' item_price_string,
          cym_gmr_dest_country.country_id dest_country_id,
          cym_gmr_dest_country.country_name dest_country_name,
          cim_gmr_dest_city.city_id dest_city_id,
          cim_gmr_dest_city.city_name dest_city_name,
          sm_gmr_dest_state.state_id dest_state_id,
          sm_gmr_dest_state.state_name dest_state_name,
          rem_gmr_dest_region.region_name dest_loc_group_name,
          '' period_month_year,
          CASE
             WHEN pci.delivery_period_type = 'Date'
             AND pci.is_called_off = 'Y'
                THEN pci.delivery_from_date
             ELSE TO_DATE (   '01-'
                           || pci.expected_delivery_month
                           || '-'
                           || pci.expected_delivery_year,
                           'dd-Mon-yyyy'
                          )
          END delivery_from_date,
          CASE
             WHEN pci.delivery_period_type = 'Date'
             AND pci.is_called_off = 'Y'
                THEN pci.delivery_from_date
             ELSE TO_DATE (   '01-'
                           || pci.expected_delivery_month
                           || '-'
                           || pci.expected_delivery_year,
                           'dd-Mon-yyyy'
                          )
          END delivery_to_date,
            pkg_report_general.fn_get_element_assay_qty
                        (aml.attribute_id,
                         vsp.ash_id,
                         'Wet',
                         (  NVL (grd.current_qty, 0)
                          + NVL (grd.release_shipped_qty, 0)
                          - NVL (grd.title_transfer_out_qty, 0)
                         ),
                         grd.qty_unit_id
                        )
          * ucm_base.multiplication_factor
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   rm.qty_unit_id_numerator,
                                                   qum_gcd.qty_unit_id,
                                                   1
                                                  )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_group_unit,
          qum_gcd.qty_unit group_qty_unit,
            pkg_report_general.fn_get_element_assay_qty
                       (aml.attribute_id,
                        vsp.ash_id,
                        'Wet',
                        (  NVL (grd.current_qty, 0)
                         + NVL (grd.release_shipped_qty, 0)
                         - NVL (grd.title_transfer_out_qty, 0)
                        ),
                        grd.qty_unit_id
                       )
          * ucm.multiplication_factor
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                grd.qty_unit_id
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                                  (NVL (pdm_under.product_id,
                                                        pdm.product_id
                                                       ),
                                                   rm.qty_unit_id_numerator,
                                                   grd.qty_unit_id,
                                                   1
                                                  )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_ctract_unit,
          grd.qty_unit_id ctract_qty_unit,
          cm_base_currency.cur_code corp_base_cur,
             pci.expected_delivery_month
          || '-'
          || pci.expected_delivery_year delivery_month,
          pci.invoice_currency_id invoice_cur_id,
          cm_invoice_currency.cur_code invoice_cur_code,
          qum_under.qty_unit base_qty_unit,
            pkg_report_general.fn_get_element_assay_qty
                         (aml.attribute_id,
                          vsp.ash_id,
                          'Wet',
                          (  NVL (grd.current_qty, 0)
                           + NVL (grd.release_shipped_qty, 0)
                           - NVL (grd.title_transfer_out_qty, 0)
                          ),
                          grd.qty_unit_id
                         )
          * (CASE
                WHEN pdtm.product_type_name = 'Composite'
                   THEN (CASE
                            WHEN rm.ratio_name = '%'
                               THEN pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           pci.item_qty_unit_id,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                            ELSE pkg_general.f_get_converted_quantity
                                          (NVL (pdm_under.product_id,
                                                pdm.product_id
                                               ),
                                           rm.qty_unit_id_numerator,
                                           NVL (pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit
                                               ),
                                           1
                                          )
                         END
                        )
                ELSE (pkg_general.f_get_converted_quantity
                                                      (pcpd.product_id,
                                                       pci.item_qty_unit_id,
                                                       pdm.base_quantity_unit,
                                                       1
                                                      )
                     )
             END
            ) qty_in_base_unit,
             cym_gmr_dest_country.country_id
          || ' - '
          || cim_gmr_dest_city.city_id comb_destination_id,
          'NA' comb_origination_id, '' comb_valuation_loc_id,
          pdm_under.product_desc element_name, nvl(phd_wh.profileid,'NA'),
          nvl(phd_wh.companyname,'NA'),
          nvl(sld.storage_loc_id,'NA'),
          nvl(sld.storage_location_name,'NA')
     FROM grd_goods_record_detail grd,
          gmr_goods_movement_record gmr,
          pcm_physical_contract_main pcm,
          pcmte_pcm_tolling_ext pcmte,
          pcpd_pc_product_definition pcpd,
          ppm_product_properties_mapping ppm,
          qav_quality_attribute_values qav,
          pcpq_pc_product_quality pcpq,
          sld_storage_location_detail sld,
          cim_citymaster cim_gmr,
          cym_countrymaster cym_gmr,
          v_pci_pcdi_details pci,
          poch_price_opt_call_off_header poch,
          aml_attribute_master_list aml,
          pdm_productmaster pdm_under,
          pdm_productmaster pdm,
          pgm_product_group_master pgm,
          pdtm_product_type_master pdtm,
          qum_quantity_unit_master qum,
          qat_quality_attributes qat,
          css_corporate_strategy_setup css,
          cpc_corporate_profit_center cpc,
          blm_business_line_master blm,
          ak_corporate akc,
          gcd_groupcorporatedetails gcd,
          cm_currency_master cm_invoice_currency,
          cim_citymaster cim_gmr_dest_city,
          cym_countrymaster cym_gmr_dest_country,
          rem_region_master rem_gmr_dest_region,
          sm_state_master sm_gmr_dest_state,
          qum_quantity_unit_master qum_gcd,
          ucm_unit_conversion_master ucm,
          cm_currency_master cm_base_currency,
          pcdi_pc_delivery_item pcdi,
          v_ucm_conversion ucm_base,
          v_stock_position_assay_id vsp,
          ash_assay_header vdc,
          qum_quantity_unit_master qum_under,
          asm_assay_sublot_mapping asm,
          pqca_pq_chemical_attributes pqca,
          rm_ratio_master rm,
          phd_profileheaderdetails phd_wh
    WHERE grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.product_id = ppm.product_id
      AND pqca.element_id = ppm.attribute_id
      AND ppm.is_active = 'Y'
      AND ppm.is_deleted = 'N'
      AND ppm.property_id = qav.attribute_id
      AND pci.pcpq_id = pcpq.pcpq_id(+)
      AND pcpq.quality_template_id = qav.quality_id
      AND qav.is_deleted = 'N'
      AND grd.product_id = pdm.product_id
      AND pdm.product_group_id = pgm.product_group_id
      AND pdm.product_type_id = pdtm.product_type_id
      AND pdm.base_quantity_unit = qum.qty_unit_id
      AND grd.shed_id = sld.storage_loc_id(+)
      AND gmr.discharge_city_id = cim_gmr.city_id(+)
      AND cim_gmr.country_id = cym_gmr.country_id(+)
      AND grd.quality_id = qat.quality_id
      AND gmr.corporate_id = akc.corporate_id
      AND akc.groupid = gcd.groupid
      AND grd.is_deleted = 'N'
      AND grd.status = 'Active'
      AND grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
      AND pci.pcdi_id = poch.pcdi_id
      AND poch.is_active = 'Y'
      AND poch.element_id = aml.attribute_id
      AND aml.underlying_product_id = pdm_under.product_id
      AND pci.strategy_id = css.strategy_id(+)
      AND pci.profit_center_id = cpc.profit_center_id(+)
      AND cpc.business_line_id = blm.business_line_id(+)
      AND (  NVL (grd.current_qty, 0)
           + NVL (grd.release_shipped_qty, 0)
           - NVL (grd.title_transfer_out_qty, 0)
          ) > 0
      AND pdtm.product_type_name = 'Composite'
      AND pci.invoice_currency_id = cm_invoice_currency.cur_id(+)
      AND cym_gmr_dest_country.country_id(+) = gmr.discharge_country_id
      AND cym_gmr_dest_country.region_id = rem_gmr_dest_region.region_id(+)
      AND cim_gmr_dest_city.city_id(+) = gmr.discharge_city_id
      AND cim_gmr_dest_city.state_id = sm_gmr_dest_state.state_id(+)
      AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id
      AND grd.qty_unit_id = ucm.from_qty_unit_id
      AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
      AND cm_base_currency.cur_id = akc.base_cur_id
      AND pci.pcdi_id = pcdi.pcdi_id
      AND pcdi.internal_contract_ref_no = pci.internal_contract_ref_no
      AND grd.qty_unit_id = ucm_base.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      AND grd.internal_grd_ref_no = vsp.internal_grd_ref_no
      AND vsp.ash_id = vdc.ash_id
      AND NVL (gmr.inventory_status, 'NA') = 'Out'
      AND pdm_under.base_quantity_unit = qum_under.qty_unit_id
      AND vdc.ash_id = asm.ash_id
      AND asm.asm_id = pqca.asm_id
      AND pcpd.input_output = 'Input'
      AND pqca.element_id = aml.attribute_id
      AND pqca.is_elem_for_pricing = 'Y'
      AND pqca.unit_of_measure = rm.ratio_id(+)
      AND grd.warehouse_profile_id = phd_wh.profileid(+)

