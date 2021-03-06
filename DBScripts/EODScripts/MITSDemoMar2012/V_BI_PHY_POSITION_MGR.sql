CREATE OR REPLACE VIEW V_BI_PHY_POSITION_MGR
(product_type, section_name, corporate_id, corporate_name, business_line_id, business_line_name, profit_center_id, profit_center_short_name, profit_center_name, strategy_id, strategy_name, product_id, product_desc, product_group_id, product_group, origin_id, origin_name, quality_id, quality_name, contract_type, position_type_id, position_type, position_sub_type, contract_ref_no, cp_contract_ref_no, issue_date, counter_party_id, counter_party_name, trader_user_id, trader_user_name, execution_type, broker_profile_id, broker_name, incoterm_id, incoterm, payment_term_id, payment_term, origination_country_id, origination_country, origination_city_id, origination_city, price_type_name, pay_in_cur_id, pay_in_cur_code, item_price_string, dest_country_id, dest_country_name, dest_city_id, dest_city_name, dest_state_id, dest_state_name, dest_loc_group_name, period_month_year, delivery_from_date, delivery_to_date, qty_in_group_unit, group_qty_unit, qty_in_ctract_unit, ctract_qty_unit, corp_base_cur, delivery_month, invoice_cur_id, invoice_cur_code, base_qty_unit, qty_in_base_unit, comb_destination_id, comb_origination_id, comb_valuation_loc_id, element_name, warehouse_profile_id, warehouse_name, shed_id, shed_name)
AS
WITH ucm_mfact AS
        (SELECT ucm.from_qty_unit_id, ucm.to_qty_unit_id,
                qum_from.qty_unit qum_from_qty_unit,
                qum_to.qty_unit qum_to_qty_unit, ucm.multiplication_factor
           FROM ucm_unit_conversion_master ucm,
                qum_quantity_unit_master qum_to,
                qum_quantity_unit_master qum_from
          WHERE ucm.from_qty_unit_id = qum_from.qty_unit_id
            AND ucm.to_qty_unit_id = qum_to.qty_unit_id
            AND ucm.is_active = 'Y'
            AND qum_from.is_deleted = 'N'
            AND qum_to.is_deleted = 'N')
-- This is for Base Metal Only
-- 1) Open Contracts
   SELECT 'Standard' product_type, 'Base Metal Open Contracts' section_name,
          pcm.corporate_id, akc.corporate_name, blm.business_line_id,
          blm.business_line_name, cpc.profit_center_id,
          cpc.profit_center_short_name, cpc.profit_center_name,
          css.strategy_id, css.strategy_name, pdm.product_id,
          pdm.product_desc, pgm.product_group_id,               -- Newly Added
          pgm.product_group_name product_group,                 -- Newly Added
          NVL (qat.product_origin_id, 'NA') origin_id,
          NVL (orm.origin_name, 'NA') origin_name, qat.quality_id,
          qat.quality_name,
          (CASE
              WHEN pcm.purchase_sales = 'P'
                 THEN 'Physical - Open Purchase'
              ELSE 'Physical - Open Sales'
           END
          ) position_type_id,
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
          'Physical' position_type,
             'Open '
          || DECODE (pcm.purchase_sales, 'P', 'Purchase', 'Sales')
                                                            position_sub_type,
             pcm.contract_ref_no
          || ','
          || pci.del_distribution_item_no contract_ref_no,
          NVL (pcm.cp_contract_ref_no, 'NA'), pcm.issue_date,
          pcm.cp_id counter_party_id,
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
          END dest_state_id,                                    -- Newly Added
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN sm_pcdb.state_name
             ELSE 'NA'
          END dest_state_name,                                  -- Newly Added
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN rem_pcdb.region_name
             ELSE 'NA'
          END dest_loc_group_name,                              -- Newly Added
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
          ((CASE
              WHEN pcm.purchase_sales = 'S' then -1 else 1 end)*
          ciqs.open_qty * ucm.multiplication_factor) qty_in_group_unit,
          qum_gcd.qty_unit group_qty_unit, 
         ( (CASE
              WHEN pcm.purchase_sales = 'S' then -1 else 1 end)* ciqs.open_qty) qty_in_ctract_unit,
          qum_ciqs.qty_unit ctract_qty_unit,
          cm_base_cur.cur_code corp_base_cur,
             pci.expected_delivery_month
          || '-'
          || pci.expected_delivery_year delivery_month,
          pcm.invoice_currency_id invoice_cur_id,
          cm_invoice_cur.cur_code invoice_cur_code,
          ucm_base.qum_to_qty_unit base_qty_unit,
         ( (CASE
              WHEN pcm.purchase_sales = 'S' then -1 else 1 end)*
            ciqs.open_qty
          * pkg_general.f_get_converted_quantity (pcpd.product_id,
                                                  pci.item_qty_unit_id,
                                                  pdm.base_quantity_unit,
                                                  1
                                                 )) qty_in_base_unit,
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
          'NA' element_name, NVL (phd_wh.profileid,
                                  'NA') warehouse_profile_id,
          NVL (phd_wh.companyname, 'NA') warehouse_name,
          NVL (sld.storage_loc_id, 'NA'),
          NVL (sld.storage_location_name, 'NA')
     FROM pci_physical_contract_item pci,
          pcm_physical_contract_main pcm,
          pcmte_pcm_tolling_ext pcmte,                          -- Newly Added
          pcdi_pc_delivery_item pcdi,
          ak_corporate akc,
          pcpd_pc_product_definition pcpd,
          cpc_corporate_profit_center cpc,
          blm_business_line_master blm,
          css_corporate_strategy_setup css,
          pdm_productmaster pdm,
          pgm_product_group_master pgm,                         -- Newly Added
          pcpq_pc_product_quality pcpq,
          qat_quality_attributes qat,
          ak_corporate_user akcu,
          gab_globaladdressbook gab,
          itm_incoterm_master itm,
          pcdb_pc_delivery_basis pcdb,
          pym_payment_terms_master pym,
          ciqs_contract_item_qty_status ciqs,
          cm_currency_master cm_base_cur,
          cm_currency_master cm_invoice_cur,
          phd_profileheaderdetails phd_contract_cp,
          pom_product_origin_master pom,
          orm_origin_master orm,
          cym_countrymaster cym_pcdb,
          rem_region_master rem_pcdb,                            --Newly Added
          cim_citymaster cim_pcdb,
          sm_state_master sm_pcdb,                              -- Newly Added
          qum_quantity_unit_master qum_ciqs,
          gcd_groupcorporatedetails gcd,
          qum_quantity_unit_master qum_gcd,
          ucm_unit_conversion_master ucm,
          ucm_mfact ucm_base,
          phd_profileheaderdetails phd_wh,
          sld_storage_location_detail sld
    WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
                                                                -- Newly Added
      AND pcdi.pcdi_id = pci.pcdi_id
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pcm.contract_status = 'In Position'
      AND pcm.corporate_id = akc.corporate_id
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.profit_center_id = cpc.profit_center_id
      AND cpc.business_line_id = blm.business_line_id
      AND pcpd.strategy_id = css.strategy_id
      AND pcpd.product_id = pdm.product_id
      AND pdm.product_group_id = pgm.product_group_id           -- Newly Added
      AND pcpd.pcpd_id = pcpq.pcpd_id
      AND pcpq.is_active = 'Y'
      AND pci.is_active = 'Y'
      AND pcdi.is_active = 'Y'
      AND ciqs.is_active = 'Y'
      AND pcdb.is_active = 'Y'
      AND pcpq.quality_template_id = qat.quality_id
      AND pcm.trader_id = akcu.user_id
      AND akcu.gabid = gab.gabid
      AND pci.pcdb_id = pcdb.pcdb_id
      AND pcdb.internal_contract_ref_no = pcdi.internal_contract_ref_no
      AND pcdb.inco_term_id = itm.incoterm_id
      AND pcm.payment_term_id = pym.payment_term_id
      AND pci.internal_contract_item_ref_no =
                                            ciqs.internal_contract_item_ref_no
      AND pci.pcpq_id = pcpq.pcpq_id
      AND pci.pcdb_id = pcdb.pcdb_id
      AND cm_base_cur.cur_id = akc.base_cur_id
      AND cm_invoice_cur.cur_id = akc.base_cur_id
      AND phd_contract_cp.profileid = pcm.cp_id
      AND qat.product_origin_id = pom.product_origin_id(+)
      AND pom.origin_id = orm.origin_id(+)
      AND ciqs.open_qty > 0
      AND cym_pcdb.country_id = pcdb.country_id
      AND cym_pcdb.region_id = rem_pcdb.region_id               -- Newly Added
      AND cim_pcdb.city_id = pcdb.city_id
      AND sm_pcdb.state_id = pcdb.state_id                      -- Newly Added
      AND qum_ciqs.qty_unit_id = ciqs.item_qty_unit_id
      AND akc.groupid = gcd.groupid
      AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id
      AND ucm.from_qty_unit_id = ciqs.item_qty_unit_id
      AND ucm.to_qty_unit_id = gcd.group_qty_unit_id
      AND pcm.contract_type = 'BASEMETAL'
      AND pcpq.quality_template_id = qat.quality_id
      AND ciqs.item_qty_unit_id = ucm_base.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      AND pcdb.warehouse_id = phd_wh.profileid(+)
      AND pcdb.warehouse_shed_id = sld.storage_loc_id(+)
-- 2) Shipped But Not TT for Purchase GMRs
   UNION ALL
   SELECT 'Standard' product_type,
          'Base Metal Shipped But Not TT for Purchase GMRs' section_name,
          gmr.corporate_id corporate_id, akc.corporate_name corporate_name,
          blm.business_line_id business_line_id,
          blm.business_line_name business_line_name,
          cpc.profit_center_id profit_center_id,
          cpc.profit_center_short_name profit_center_short_name,
          cpc.profit_center_name profit_center_name,
          css.strategy_id strategy_id, css.strategy_name strategy_name,
          grd.product_id product_id, pdm.product_desc product_desc,
          pgm.product_group_id,                                 -- Newly Added
                               pgm.product_group_name product_group,
          
          -- Newly Added
          'NA' origin_id, 'NA' origin_name, grd.quality_id quality_id,
          qat.quality_name quality_name,
          'Physical - Open Purchase' position_type_id,
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
          'Physical' position_type, 'Open Purchase' position_sub_type,
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
          NVL (pci.item_price_type, 'NA') price_type_name,
          pci.invoice_currency_id pay_in_cur_id,
          cm_invoice_currency.cur_code pay_in_cur_code,
          'NA' item_price_string,            -- do not need for GMR and Stocks
          NVL (cym_gmr.country_id, 'NA') dest_country_id,
          NVL (cym_gmr.country_name, 'NA') dest_country_name,
          NVL (cim_gmr.city_id, 'NA') dest_city_id,
          NVL (cim_gmr.city_name, 'NA') dest_city_name,
          NVL (sm_gmr.state_id, 'NA') dest_state_id,            -- Newly Added
          NVL (sm_gmr.state_name, 'NA') dest_state_name,        -- Newly Added
          NVL (rem_gmr.region_name, 'NA') dest_loc_group_name,  -- Newly Added
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
            (  NVL (grd.current_qty, 0)
             + NVL (grd.release_shipped_qty, 0)
             - NVL (grd.title_transfer_out_qty, 0)
            )
          * ucm.multiplication_factor qty_in_group_unit,
          qum_gcd.qty_unit group_qty_unit,
          (  NVL (grd.current_qty, 0)
           + NVL (grd.release_shipped_qty, 0)
           - NVL (grd.title_transfer_out_qty, 0)
          ) qty_in_ctract_unit,
          qum_grd.qty_unit ctract_qty_unit,
          cm_base_currency.cur_code corp_base_cur,
             pci.expected_delivery_month
          || '-'
          || pci.expected_delivery_year delivery_month,
          pci.invoice_currency_id invoice_cur_id,
          cm_invoice_currency.cur_code invoice_cur_code,
          ucm_base.qum_to_qty_unit base_qty_unit,
            (  NVL (grd.current_qty, 0)
             + NVL (grd.release_shipped_qty, 0)
             - NVL (grd.title_transfer_out_qty, 0)
            )
          *               /*ucm_base.multiplication_factor qty_in_base_unit,*/
            pkg_general.f_get_converted_quantity (pcpd.product_id,
                                                  pci.item_qty_unit_id,
                                                  pdm.base_quantity_unit,
                                                  1
                                                 ) qty_in_base_unit,
          cym_gmr.country_id || ' - ' || cim_gmr.city_id comb_destination_id,
          'NA' comb_origination_id,
          NVL
             (   CASE
                    WHEN grd.is_afloat = 'Y'
                       THEN cym_gmr.country_id
                    ELSE cym_sld.country_id
                 END
              || ' - '
              || CASE
                    WHEN grd.is_afloat = 'Y'
                       THEN cim_gmr.city_id
                    ELSE cim_sld.city_id
                 END,
              'NA'
             ) comb_valuation_loc_id,
          'NA' element_name, NVL (phd_wh.profileid, 'NA'),
          NVL (phd_wh.companyname, 'NA'), NVL (sld.storage_loc_id, 'NA'),
          NVL (sld.storage_location_name, 'NA')
     FROM grd_goods_record_detail grd,
          gmr_goods_movement_record gmr,
          pcm_physical_contract_main pcm,                       -- Newly Added
          pcmte_pcm_tolling_ext pcmte,                          -- Newly Added
          pcpd_pc_product_definition pcpd,                      -- Newly Added
          sld_storage_location_detail sld,
          cim_citymaster cim_sld,
          cim_citymaster cim_gmr,
          sm_state_master sm_gmr,                               -- Newly Added
          cym_countrymaster cym_sld,
          cym_countrymaster cym_gmr,
          rem_region_master rem_gmr,                            -- Newly Added
          v_pci_pcdi_details pci,
          pdm_productmaster pdm,
          pgm_product_group_master pgm,                         -- Newly Added
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
          qum_quantity_unit_master qum_gcd,
          ucm_unit_conversion_master ucm,
          cm_currency_master cm_base_currency,
          ucm_mfact ucm_base,
          ak_corporate_user aku,
          qat_quality_attributes qat,
          qum_quantity_unit_master qum_grd,
          phd_profileheaderdetails phd_wh
    WHERE grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND grd.product_id = pdm.product_id
      AND pcm.internal_contract_ref_no =
                                    gmr.internal_contract_ref_no
                                                                -- Newly Added
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
                                                                -- Newly Added
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pdm.product_group_id = pgm.product_group_id           -- Newly Added
      AND pdm.product_type_id = pdtm.product_type_id
      AND pdm.base_quantity_unit = qum.qty_unit_id
      AND grd.shed_id = sld.storage_loc_id(+)
      AND sld.city_id = cim_sld.city_id(+)
      AND gmr.discharge_city_id = cim_gmr.city_id(+)
      AND gmr.discharge_state_id = sm_gmr.state_id(+)           -- Newly Added
      AND cim_sld.country_id = cym_sld.country_id(+)
      AND cim_gmr.country_id = cym_gmr.country_id(+)
      AND cym_gmr.region_id = rem_gmr.region_id(+)              -- Newly Added
      AND grd.quality_id = qat.quality_id
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
      AND pdtm.product_type_name = 'Standard'
      AND phd_pcm_cp.profileid(+) = pci.cp_id
      AND pym.payment_term_id(+) = pci.payment_term_id
      AND gmr.inventory_status = 'In'
      AND cm_invoice_currency.cur_id(+) = pci.invoice_currency_id
      AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id
      AND grd.qty_unit_id = ucm.from_qty_unit_id
      AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
      AND cm_base_currency.cur_id = akc.base_cur_id
      AND grd.qty_unit_id = ucm_base.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      AND grd.qty_unit_id = qum_grd.qty_unit_id
      AND grd.warehouse_profile_id = phd_wh.profileid(+)
   UNION ALL
-- 3) Shipped But Not TT for Sales GMRs
   SELECT 'Standard' product_type,
          'Base Metal Shipped But Not TT for Sales GMRs' section_name,
          akc.corporate_id corporate_id, akc.corporate_name corporate_name,
          blm.business_line_id business_line_id,
          blm.business_line_name business_line_name,
          cpc.profit_center_id profit_center_id,
          cpc.profit_center_short_name profit_center_short_name,
          cpc.profit_center_name profit_center_name,
          css.strategy_id strategy_id, css.strategy_name strategy_name,
          pdm.product_id product_id, pdm.product_desc product_desc,
          pgm.product_group_id,                                 -- Newly Added
                               pgm.product_group_name product_group,
          
          -- Newly Added
          'NA' origin_id, 'NA' origin_name, qat.quality_id quality_id,
          qat.quality_name quality_name,
          'Physical - Open Sales' position_type_id,
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
          'Physical' position_type, 'Open Sales' position_sub_type,
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
          cm_invoice_curreny.cur_code pay_in_cur_code,
          pcbph.price_description item_price_string,
          NVL
             (CASE
                 WHEN itm.location_field = 'DESTINATION'
                    THEN pcdb.country_id
                 ELSE 'NA'
              END,
              'NA'
             ) destination_country_id,
          NVL
             (CASE
                 WHEN itm.location_field = 'DESTINATION'
                    THEN cym_pcdb.country_name
                 ELSE 'NA'
              END,
              'NA'
             ) destination_country,
          NVL
             (CASE
                 WHEN itm.location_field = 'DESTINATION'
                    THEN cim_pcdb.city_id
                 ELSE 'NA'
              END,
              'NA'
             ) destination_city_id,
          NVL
             (CASE
                 WHEN itm.location_field = 'DESTINATION'
                    THEN cim_pcdb.city_name
                 ELSE 'NA'
              END,
              'NA'
             ) destination_city,
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN sm_pcdb.state_id
             ELSE 'NA'
          END dest_state_id,                                    -- Newly Added
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN sm_pcdb.state_name
             ELSE 'NA'
          END dest_state_name,                                  -- Newly Added
          CASE
             WHEN itm.location_field = 'DESTINATION'
                THEN rem_pcdb.region_name
             ELSE 'NA'
          END dest_loc_group_name,                              -- Newly Added
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
          dgrd.current_qty * ucm.multiplication_factor * -1 qty_in_group_unit,
          qum_gcd.qty_unit group_qty_unit,
          dgrd.current_qty * -1 qty_in_ctract_unit,
          qum_dgrd.qty_unit ctract_qty_unit,
          cm_base_cur.cur_code corp_base_cur,
          TO_CHAR (SYSDATE, 'Mon-yyyy') delivery_month,
          cm_invoice_curreny.cur_id invoice_cur_id,
          cm_invoice_curreny.cur_code invoice_cur_code,
          ucm_base.qum_to_qty_unit base_qty_unit,
            dgrd.current_qty
          * pkg_general.f_get_converted_quantity (pcpd.product_id,
                                                  pci.item_qty_unit_id,
                                                  pdm.base_quantity_unit,
                                                  1
                                                 )
          * -1 qty_in_base_unit,
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
          'NA' element_name, NVL (phd_wh.profileid, 'NA'),
          NVL (phd_wh.companyname, 'NA'), NVL (sld.storage_loc_id, 'NA'),
          NVL (sld.storage_location_name, 'NA')
     FROM dgrd_delivered_grd dgrd,
          gmr_goods_movement_record gmr,
          pcm_physical_contract_main pcm,                       -- Newly Added
          pcmte_pcm_tolling_ext pcmte,                          -- Newly Added
          pcpd_pc_product_definition pcpd,                      -- Newly Added
          sld_storage_location_detail sld,
          cim_citymaster cim_sld,
          cim_citymaster cim_gmr,
          cym_countrymaster cym_sld,
          cym_countrymaster cym_gmr,
          v_pci_pcdi_details pci,
          pdm_productmaster pdm,
          pgm_product_group_master pgm,                         -- Newly Added
          pdtm_product_type_master pdtm,
          qum_quantity_unit_master qum,
          itm_incoterm_master itm,
          qat_quality_attributes qat,
          css_corporate_strategy_setup css,
          cpc_corporate_profit_center cpc,
          blm_business_line_master blm,
          ak_corporate akc,
          gcd_groupcorporatedetails gcd,
          gab_globaladdressbook gab,
          pym_payment_terms_master pym,
          phd_profileheaderdetails phd_pcm_cp,
          cm_currency_master cm_invoice_curreny,
          pcbph_pc_base_price_header pcbph,
          pcdb_pc_delivery_basis pcdb,
          cim_citymaster cim_pcdb,
          rem_region_master rem_pcdb,                           -- Newly Added
          cym_countrymaster cym_pcdb,
          sm_state_master sm_pcdb,                              -- Newly Added
          qum_quantity_unit_master qum_gcd,
          qum_quantity_unit_master qum_dgrd,
          cm_currency_master cm_base_cur,
          ucm_unit_conversion_master ucm,
          ucm_mfact ucm_base,
          ak_corporate_user aku,
          phd_profileheaderdetails phd_wh
    WHERE dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND dgrd.product_id = pdm.product_id
      AND pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
      -- Newly Added
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
      -- Newly Added
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      -- Newly Added
      AND pdm.product_group_id = pgm.product_group_id           -- Newly Added
      AND pdm.product_type_id = pdtm.product_type_id
      AND pdtm.product_type_name = 'Standard'
      AND pdm.base_quantity_unit = qum.qty_unit_id
      AND dgrd.shed_id = sld.storage_loc_id(+)
      AND sld.city_id = cim_sld.city_id(+)
      AND gmr.discharge_city_id = cim_gmr.city_id(+)
      AND cim_sld.country_id = cym_sld.country_id(+)
      AND cim_gmr.country_id = cym_gmr.country_id(+)
      AND dgrd.quality_id = qat.quality_id
      AND gmr.corporate_id = akc.corporate_id
      AND akc.groupid = gcd.groupid
      AND dgrd.status = 'Active'
      AND pcbph.is_active = 'Y'
      AND pcdb.is_active = 'Y'
      AND dgrd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no(+)
      AND pci.inco_term_id = itm.incoterm_id(+)
      AND pci.strategy_id = css.strategy_id(+)
      AND pci.profit_center_id = cpc.profit_center_id(+)
      AND cpc.business_line_id = blm.business_line_id(+)
      AND NVL (dgrd.current_qty, 0) > 0
      AND NVL (dgrd.inventory_status, 'NA') <> 'Out'
      AND aku.gabid = gab.gabid(+)
      AND gmr.created_by = aku.user_id
      AND phd_pcm_cp.profileid(+) = pci.cp_id
      AND pym.payment_term_id(+) = pci.payment_term_id
      AND pci.invoice_currency_id = cm_invoice_curreny.cur_id(+)
      AND pcbph.internal_contract_ref_no(+) = pci.internal_contract_ref_no
      AND pcdb.internal_contract_ref_no = pci.internal_contract_ref_no
      AND pcdb.country_id = cym_pcdb.country_id(+)
      AND cym_pcdb.region_id = rem_pcdb.region_id(+)            -- Newly Added
      AND pcdb.city_id = cim_pcdb.city_id(+)
      AND pcdb.state_id = sm_pcdb.state_id(+)                   -- Newly Added
      AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id
      AND qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id
      AND cm_base_cur.cur_id = akc.base_cur_id
      AND ucm.from_qty_unit_id = dgrd.net_weight_unit_id
      AND ucm.to_qty_unit_id = gcd.group_qty_unit_id
      AND dgrd.net_weight_unit_id = ucm_base.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      AND dgrd.warehouse_profile_id = phd_wh.profileid(+)
      AND dgrd.shed_id = sld.storage_loc_id(+)
   UNION ALL
-- 4) Stocks
   SELECT 'Standard' product_type, 'Base Metal Stocks' section_name,
          gmr.corporate_id corporate_id, akc.corporate_name corporate_name,
          blm.business_line_id business_line_id,
          blm.business_line_name business_line_name,
          cpc.profit_center_id profit_center_id,
          cpc.profit_center_short_name profit_center_short_name,
          cpc.profit_center_name profit_center_name,
          css.strategy_id strategy_id, css.strategy_name strategy_name,
          grd.product_id product_id, pdm.product_desc product_desc,
          pgm.product_group_id,                                 -- Newly Added
                               pgm.product_group_name product_group,
          
          -- Newly Added
          'NA' origin_id, 'NA' origin_name, grd.quality_id quality_id,
          qat.quality_name quality_name,
          'Stocks -  Actual Stocks' position_type_id,
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
          'Stocks' position_type, 'Actual Stocks' position_sub_type,
          grd.internal_grd_ref_no contract_ref_no, 'NA' external_reference_no,
          gmr.inventory_in_date issue_date, 'NA' counter_party_id,
          'NA' counter_party_name, 'NA', 'NA' trader_name,
          pcm.partnership_type execution_type, 'NA' broker_profile_id,
          'NA' broker_name, 'NA' incoterm_id, 'NA' incoterm,
          'NA' payment_term_id, 'NA' payment_term,
          'NA' origination_country_id, 'NA' origination_country,
          'NA' origination_city_id, 'NA' origination_city,
          'NA' price_type_name, 'NA' pay_in_cur_id, 'NA' pay_in_cur_code,
          'NA' item_price_string,            -- do not need for GMR and Stocks
          cym_gmr_dest_country.country_id dest_country_id,
          cym_gmr_dest_country.country_name dest_country_name,
          cim_gmr_dest_city.city_id dest_city_id,
          cim_gmr_dest_city.city_name dest_city_name,
          sm_gmr_dest_state.state_id dest_state_id,             -- Newly Added
          sm_gmr_dest_state.state_name dest_state_name,         -- Newly Added
          rem_dest.region_name dest_loc_group_name,             -- Newly Added
          TO_CHAR (SYSDATE, 'Mon-yyyy') period_month_year,
          TRUNC (SYSDATE) delivery_from_date, TRUNC (SYSDATE)
                                                             delivery_to_date,
            (  NVL (grd.current_qty, 0)
             + NVL (grd.release_shipped_qty, 0)
             - NVL (grd.title_transfer_out_qty, 0)
            )
          * ucm.multiplication_factor qty_in_group_unit,
          qum_gcd.qty_unit group_qty_unit,
          (  NVL (grd.current_qty, 0)
           + NVL (grd.release_shipped_qty, 0)
           - NVL (grd.title_transfer_out_qty, 0)
          ) qty_in_ctract_unit,
          grd.qty_unit_id ctract_qty_unit,
          cm_base_currency.cur_code corp_base_cur,
          TO_CHAR (SYSDATE, 'Mon-yyyy') delivery_month,
          pci.invoice_currency_id invoice_cur_id,
          cm_invoice_currency.cur_code invoice_cur_code,
          ucm_base.qum_to_qty_unit base_qty_unit,
            (  NVL (grd.current_qty, 0)
             + NVL (grd.release_shipped_qty, 0)
             - NVL (grd.title_transfer_out_qty, 0)
            )
          * pkg_general.f_get_converted_quantity (pcpd.product_id,
                                                  pci.item_qty_unit_id,
                                                  pdm.base_quantity_unit,
                                                  1
                                                 ) qty_in_base_unit,
             cym_gmr_dest_country.country_id
          || ' - '
          || cim_gmr_dest_city.city_id comb_destination_id,
          'NA' comb_origination_id,
             CASE
                WHEN grd.is_afloat = 'Y'
                   THEN cym_gmr.country_id
                ELSE cym_sld.country_id
             END
          || ' - '
          || CASE
                WHEN grd.is_afloat = 'Y'
                   THEN cim_gmr.country_id
                ELSE cim_sld.country_id
             END comb_valuation_loc_id,
          'NA' element_name, NVL (phd_wh.profileid, 'NA'),
          NVL (phd_wh.companyname, 'NA'), sld.storage_loc_id,
          sld.storage_location_name
     FROM grd_goods_record_detail grd,
          gmr_goods_movement_record gmr,
          pcm_physical_contract_main pcm,                       -- Newly Added
          pcmte_pcm_tolling_ext pcmte,                          -- Newly Added
          pcpd_pc_product_definition pcpd,                      -- Newly Added
          sld_storage_location_detail sld,
          cim_citymaster cim_sld,
          cim_citymaster cim_gmr,
          cym_countrymaster cym_sld,
          cym_countrymaster cym_gmr,
          v_pci_pcdi_details pci,
          pdm_productmaster pdm,
          pgm_product_group_master pgm,                         -- Newly Added
          pdtm_product_type_master pdtm,
          qum_quantity_unit_master qum,
          itm_incoterm_master itm,
          qat_quality_attributes qat,
          css_corporate_strategy_setup css,
          cpc_corporate_profit_center cpc,
          blm_business_line_master blm,
          ak_corporate akc,
          gcd_groupcorporatedetails gcd,
          phd_profileheaderdetails phd_pcm_cp,
          cm_currency_master cm_invoice_currency,
          cim_citymaster cim_gmr_dest_city,
          cym_countrymaster cym_gmr_dest_country,
          rem_region_master rem_dest,                           -- Newly Added
          sm_state_master sm_gmr_dest_state,                    -- Newly Added
          qum_quantity_unit_master qum_gcd,
          ucm_unit_conversion_master ucm,
          cm_currency_master cm_base_currency,
          ucm_mfact ucm_base,
          phd_profileheaderdetails phd_wh
    WHERE grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
      -- Newly Added
      AND pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
      -- Newly Added
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND grd.product_id = pdm.product_id
      AND pdm.product_group_id = pgm.product_group_id           -- Newly Added
      AND pdm.product_type_id = pdtm.product_type_id
      AND pdtm.product_type_name = 'Standard'
      AND pdm.base_quantity_unit = qum.qty_unit_id
      AND grd.shed_id = sld.storage_loc_id(+)
      AND sld.city_id = cim_sld.city_id(+)
      AND gmr.discharge_city_id = cim_gmr.city_id(+)
      AND cim_sld.country_id = cym_sld.country_id(+)
      AND cim_gmr.country_id = cym_gmr.country_id(+)
      AND grd.quality_id = qat.quality_id
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
      AND phd_pcm_cp.profileid(+) = pci.cp_id
      AND NVL (grd.inventory_status, 'NA') = 'Out'
      AND cm_invoice_currency.cur_id(+) = pci.invoice_currency_id
      AND cym_gmr_dest_country.country_id(+) = gmr.discharge_country_id
      -- Modified
      AND cim_gmr_dest_city.city_id(+) = gmr.discharge_city_id     -- Modified
      AND cim_gmr_dest_city.state_id = sm_gmr_dest_state.state_id(+)
      -- Newly Added
      AND cym_gmr_dest_country.region_id = rem_dest.region_id(+)
      -- Newly Added
      AND qum_gcd.qty_unit_id = gcd.group_qty_unit_id
      AND grd.qty_unit_id = ucm.from_qty_unit_id
      AND gcd.group_qty_unit_id = ucm.to_qty_unit_id
      AND cm_base_currency.cur_id = akc.base_cur_id
      AND grd.qty_unit_id = ucm_base.from_qty_unit_id
      AND pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      AND grd.warehouse_profile_id = phd_wh.profileid(+)
-- This is for Concentrate Only(1.Open Contracts,2.Shipped But Not TT,3.Stocks)
   UNION ALL
   SELECT product_type, section_name, corporate_id, corporate_name,
          business_line_id, business_line_name, profit_center_id,
          profit_center_short_name, profit_center_name, strategy_id,
          strategy_name, product_id, product_desc, product_group_id,
          
          -- Newly Added
          product_group,                                        -- Newly Added
                        origin_id, origin_name, quality_id, quality_name,
          contract_type, position_type_id, position_type, position_sub_type,
          contract_ref_no, cp_contract_ref_no, issue_date, counter_party_id,
          counter_party_name, trader_user_id, trader_user_name,
          execution_type, broker_profile_id, broker_name, incoterm_id,
          incoterm, payment_term_id, payment_term, origination_country_id,
          origination_country, origination_city_id, origination_city,
          price_type_name, pay_in_cur_id, pay_in_cur_code, item_price_string,
          dest_country_id, dest_country_name, dest_city_id, dest_city_name,
          dest_state_id,                                        -- Newly Added
                        dest_state_name,                        -- Newly Added
                                        dest_loc_group_name,    -- Newly Added
          period_month_year, delivery_from_date, delivery_to_date,
          qty_in_group_unit, group_qty_unit, qty_in_ctract_unit,
          ctract_qty_unit, corp_base_cur, delivery_month, invoice_cur_id,
          invoice_cur_code, base_qty_unit, qty_in_base_unit,
          comb_destination_id, comb_origination_id, comb_valuation_loc_id,
          element_name, warehouse_profile_id, warehouse_name, shed_id,
          shed_name
     FROM v_bi_conc_phy_position 
