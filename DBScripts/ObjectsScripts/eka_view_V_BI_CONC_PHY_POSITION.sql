create or replace view v_bi_conc_phy_position as
select 'Composite' product_type,
       'Concentrates Open Contracts' section_name,
       pcm.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       css.strategy_id,
       css.strategy_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       nvl(qat.product_origin_id, 'NA') origin_id,
       nvl(orm.origin_name, 'NA') origin_name,
       qat.quality_id,
       qat.quality_name,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       case
         when pcm.purchase_sales = 'P' then
          'Physical - Open Purchase'
         else
          'Physical - Open Sales'
       end as position_type_id,
       'Open' as position_type,
       case
         when pcm.purchase_sales = 'P' then
          'Purchase'
         else
          'Sales'
       end as position_sub_type,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no contract_ref_no,
       nvl(pcm.cp_contract_ref_no, 'NA') cp_contract_ref_no,
       pcm.issue_date,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       pcm.partnership_type execution_type,
       'NA' broker_profile_id,
       'NA' broker_name,
       itm.incoterm_id,
       itm.incoterm,
       pym.payment_term_id,
       pym.payment_term,
       case
         when itm.location_field = 'ORIGINATION' then
          pcdb.country_id
         else
          'NA'
       end origination_country_id,
       case
         when itm.location_field = 'ORIGINATION' then
          cym_pcdb.country_name
         else
          'NA'
       end origination_country,
       case
         when itm.location_field = 'ORIGINATION' then
          cim_pcdb.city_id
         else
          'NA'
       end origination_city_id,
       case
         when itm.location_field = 'ORIGINATION' then
          cim_pcdb.city_name
         else
          'NA'
       end origination_city,
       nvl(pcdi.item_price_type, 'NA') price_type_name,
       pcm.invoice_currency_id pay_in_cur_id,
       cm_invoice_cur.cur_code pay_in_cur_code,
       'NA' item_price_string,
       case
         when itm.location_field = 'DESTINATION' then
          pcdb.country_id
         else
          'NA'
       end dest_country_id,
       case
         when itm.location_field = 'DESTINATION' then
          cym_pcdb.country_name
         else
          'NA'
       end dest_country_name,
       case
         when itm.location_field = 'DESTINATION' then
          cim_pcdb.city_id
         else
          'NA'
       end dest_city_id,
       case
         when itm.location_field = 'DESTINATION' then
          cim_pcdb.city_name
         else
          'NA'
       end dest_city_name,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_id
         else
          'NA'
       end dest_state_id,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_name
         else
          'NA'
       end dest_state_name,
       case
         when itm.location_field = 'DESTINATION' then
          rem_pcdb.region_name
         else
          'NA'
       end dest_loc_group_name,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year period_month_year,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_from_date,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_to_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_to_date,
       (ciqs.open_qty * (asm.dry_wet_qty_ratio / 100)) * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               gcd.group_qty_unit_id,
                                               1) / 100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               rm.qty_unit_id_denominator,
                                               1) *
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               gcd.group_qty_unit_id,
                                               1)
       end) * pqca.typical qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (ciqs.open_qty * (asm.dry_wet_qty_ratio / 100)) * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               ciqs.item_qty_unit_id,
                                               1) / 100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               rm.qty_unit_id_denominator,
                                               1) *
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               ciqs.item_qty_unit_id,
                                               1)
       end) *pqca.typical qty_in_ctract_unit,
       qum_ciqs.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pcm.invoice_currency_id invoice_cur_id,
       cm_invoice_cur.cur_code invoice_cur_code,
       qum_under.qty_unit base_qty_unit,
       (ciqs.open_qty * (asm.dry_wet_qty_ratio / 100)) * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1) / 100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               nvl(rm.qty_unit_id_denominator,
                                                   pdm.base_quantity_unit),
                                               1) *
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
       end) * pqca.typical qty_in_base_unit,
       case
         when itm.location_field = 'DESTINATION' then
          pcdb.country_id
         else
          'NA'
       end || ' - ' || case
         when itm.location_field = 'DESTINATION' then
          pcdb.city_id
         else
          'NA'
       end comb_destination_id,
       case
         when itm.location_field = 'ORIGINATION' then
          pcdb.country_id
         else
          'NA'
       end || ' - ' || case
         when itm.location_field = 'ORIGINATION' then
          pcdb.city_id
         else
          'NA'
       end comb_origination_id,
       pci.m2m_country_id || ' - ' || pci.m2m_city_id comb_valuation_loc_id,
       pdm_under.product_desc element_name,
       nvl(phd_wh.profileid, 'NA') warehouse_profile_id,
       nvl(phd_wh.companyname, 'NA') warehouse_name,
       nvl(sld.storage_loc_id, 'NA') shed_id,
       nvl(sld.storage_location_name, 'NA') shed_name
  from pcdi_pc_delivery_item          pcdi,
       pcm_physical_contract_main     pcm,
       pci_physical_contract_item     pci,
       pcmte_pcm_tolling_ext          pcmte,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       ciqs_contract_item_qty_status  ciqs,
       pcpd_pc_product_definition     pcpd,
       pcpq_pc_product_quality        pcpq,
       pcdb_pc_delivery_basis         pcdb,
       ak_corporate                   akc,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       css_corporate_strategy_setup   css,
       pdm_productmaster              pdm,
       pgm_product_group_master       pgm,
       qat_quality_attributes         qat,
       ak_corporate_user              akcu,
       gab_globaladdressbook          gab,
       itm_incoterm_master            itm,
       pym_payment_terms_master       pym,
       cm_currency_master             cm_base_cur,
       cm_currency_master             cm_invoice_cur,
       phd_profileheaderdetails       phd_contract_cp,
       pom_product_origin_master      pom,
       orm_origin_master              orm,
       cym_countrymaster              cym_pcdb,
       cim_citymaster                 cim_pcdb,
       rem_region_master              rem_pcdb,
       sm_state_master                sm_pcdb,
       qum_quantity_unit_master       qum_ciqs,
       gcd_groupcorporatedetails      gcd,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       v_ucm_conversion               ucm_base,
       ash_assay_header               vsh,
       qum_quantity_unit_master       qum_under,
       pdtm_product_type_master       pdtm,
       asm_assay_sublot_mapping       asm,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       phd_profileheaderdetails       phd_wh,
       sld_storage_location_detail    sld
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and poch.is_active = 'Y'
   and aml.underlying_product_id = pdm_under.product_id
   and pcm.contract_status = 'In Position'
   and pcm.contract_type = 'CONCENTRATES'
   and pci.internal_contract_item_ref_no =
       ciqs.internal_contract_item_ref_no
   and pci.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and ciqs.is_active = 'Y'
   and ciqs.open_qty > 0
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.is_active = 'Y'
   and pci.pcpq_id = pcpq.pcpq_id
   and pcpq.is_active = 'Y'
   and pci.pcdb_id = pcdb.pcdb_id
   and pcdb.is_active = 'Y'
   and pcm.corporate_id = akc.corporate_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id(+)
   and pcpd.strategy_id = css.strategy_id
   and pcpd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id
   and pcpq.quality_template_id = qat.quality_id
   and pcm.trader_id = akcu.user_id
   and akcu.gabid = gab.gabid
   and pcdb.inco_term_id = itm.incoterm_id
   and pcm.payment_term_id = pym.payment_term_id
   and cm_base_cur.cur_id = akc.base_cur_id
   and akc.base_cur_id = cm_invoice_cur.cur_id
   and pcm.cp_id = phd_contract_cp.profileid
   and qat.product_origin_id = pom.product_origin_id(+)
   and pcpq.assay_header_id = vsh.ash_id
   and pom.origin_id = orm.origin_id(+)
   and cym_pcdb.country_id = pcdb.country_id
   and cim_pcdb.city_id = pcdb.city_id
   and sm_pcdb.state_id = pcdb.state_id
   and cym_pcdb.region_id = rem_pcdb.region_id
   and ciqs.item_qty_unit_id = qum_ciqs.qty_unit_id
   and akc.groupid = gcd.groupid
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and ucm.from_qty_unit_id = ciqs.item_qty_unit_id
   and ucm.to_qty_unit_id = gcd.group_qty_unit_id
   and ciqs.item_qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id
   and pcpq.quality_template_id = qat.quality_id
   and pdm.product_type_id = pdtm.product_type_id
   and vsh.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pcpd.input_output = 'Input'
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id(+)
   and pcdb.warehouse_id = phd_wh.profileid(+)
   and pcdb.warehouse_shed_id = sld.storage_loc_id(+)
  -- and pcm.contract_ref_no like '%533%'
union all
-- 2. shipped but not tt for purchase gmrs
select 'Composite' product_type,
       'Concentrates Shipped But Not TT for Purchase GMRs' section_name,
       gmr.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       grd.product_id product_id,
       pdm.product_desc product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       case
         when pci.purchase_sales = 'P' then
          'Physical - Open Purchase'
         else
          'Physical - Open Sales'
       end position_type_id,
       'Open' position_type,
       case
         when pci.purchase_sales = 'P' then
          'Purchase'
         else
          'Sales'
       end position_sub_type,
       case
         when pci.contract_ref_no is not null then
          gmr.gmr_ref_no || ',' || pci.contract_ref_no || ',' ||
          pci.del_distribution_item_no
         else
          gmr.gmr_ref_no
       end contract_ref_no,
       nvl(pci.cp_contract_ref_no, 'NA') external_reference_no,
       gmr.eff_date issue_date,
       pci.cp_id counter_party_id,
       phd_pcm_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_name,
       pcm.partnership_type execution_type,
       'NA' broker_profile_id,
       'NA' broker_name,
       pci.incoterm_id incoterm_id,
       itm.incoterm incoterm,
       pci.payment_term_id payment_term_id,
       pym.payment_term payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       nvl(pcdi.item_price_type, 'NA') price_type_name,
       pci.invoice_currency_id pay_in_cur_id,
       cm_invoice_currency.cur_code pay_in_cur_code,
       'NA' item_price_string,
       nvl(cym_gmr_dest_country.country_id, 'NA') dest_country_id,
       nvl(cym_gmr_dest_country.country_name, 'NA') dest_country_name,
       nvl(cim_gmr_dest_city.city_id, 'NA') dest_city_id,
       nvl(cim_gmr_dest_city.city_name, 'NA') dest_city_name,
       nvl(sm_gmr.state_id, 'NA') dest_state_id,
       nvl(sm_gmr.state_name, 'NA') dest_state_name,
       nvl(rem_gmr_dest_region.region_name, 'NA') dest_loc_group_name,
       '' period_month_year,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_from_date,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_to_date,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * (asm.dry_wet_qty_ratio / 100)) *
       ucm_base.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               qum_gcd.qty_unit_id,
                                               1)
       end) *pqca.typical qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * (asm.dry_wet_qty_ratio / 100)) *
       ucm.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   grd.qty_unit_id),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               grd.qty_unit_id,
                                               1)
       end) *pqca.typical qty_in_ctract_unit,
       grd.qty_unit_id ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       qum_under.qty_unit base_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * (asm.dry_wet_qty_ratio / 100)) *
       ucm_base.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
       end) *pqca.typical qty_in_base_unit,
       nvl(cym_gmr_dest_country.country_id, 'NA') || ' - ' ||
       nvl(cim_gmr_dest_city.city_id, 'NA') comb_destination_id,
       'NA-NA' comb_origination_id,
       nvl(case
             when grd.is_afloat = 'Y' then
              cym_gmr.country_id
             else
              cym_sld.country_id
           end,
           'NA') || ' - ' || nvl(case
                                   when grd.is_afloat = 'Y' then
                                    cim_gmr.city_id
                                   else
                                    cim_sld.city_id
                                 end,
                                 'NA') comb_valuation_loc_id,
       pdm_under.product_desc element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       nvl(sld.storage_loc_id, 'NA'),
       nvl(sld.storage_location_name, 'NA')
  from grd_goods_record_detail        grd,
       gmr_goods_movement_record      gmr,
       pcm_physical_contract_main     pcm,
       pcmte_pcm_tolling_ext          pcmte,
       pcpd_pc_product_definition     pcpd,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       pcpq_pc_product_quality        pcpq,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       sm_state_master                sm_gmr,
       v_pci_pcdi_details             pci,
       pdm_productmaster              pdm,
       pgm_product_group_master       pgm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       itm_incoterm_master            itm,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       gab_globaladdressbook          gab,
       phd_profileheaderdetails       phd_pcm_cp,
       pym_payment_terms_master       pym,
       cm_currency_master             cm_invoice_currency,
       cim_citymaster                 cim_gmr_dest_city,
       cym_countrymaster              cym_gmr_dest_country,
       rem_region_master              rem_gmr_dest_region,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       cm_currency_master             cm_base_currency,
       pcdi_pc_delivery_item          pcdi,
       qum_quantity_unit_master       qum_under,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       v_ucm_conversion               ucm_base,
       -- v_stock_position_assay_id      vsp,
       sam_stock_assay_mapping        vsp,
       ash_assay_header               vdc,
       ak_corporate_user              aku,
       qat_quality_attributes         qat,
       asm_assay_sublot_mapping       asm,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       phd_profileheaderdetails       phd_wh
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id = ppm.product_id
   and pqca.element_id = ppm.attribute_id
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and ppm.property_id = qav.attribute_id
   and pci.pcpq_id = pcpq.pcpq_id(+)
   and pcpq.quality_template_id = qav.quality_id
   and qav.is_deleted = 'N'
   and grd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and cim_gmr_dest_city.state_id = sm_gmr.state_id(+)
   and grd.quality_id = qat.quality_id(+)
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) > 0
   and gmr.created_by = aku.user_id
   and aku.gabid = gab.gabid(+)
   and pdtm.product_type_name = 'Composite'
   and pci.cp_id = phd_pcm_cp.profileid(+)
   and pci.payment_term_id = pym.payment_term_id(+)
  -- and nvl(gmr.inventory_status, 'NA') = 'In'
   and nvl(gmr.inventory_status, 'NA') <>'In'
   and pci.invoice_currency_id = cm_invoice_currency.cur_id(+)
   and cym_gmr_dest_country.country_id(+) = gmr.discharge_country_id
   and cym_gmr_dest_country.region_id = rem_gmr_dest_region.region_id(+)
   and cim_gmr_dest_city.city_id(+) = gmr.discharge_city_id
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and gcd.group_qty_unit_id = ucm.to_qty_unit_id
   and cm_base_currency.cur_id = akc.base_cur_id
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pci.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and poch.is_active = 'Y'
   and aml.underlying_product_id = pdm_under.product_id
   and grd.qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and grd.internal_grd_ref_no = vsp.internal_grd_ref_no
   and vsp.is_latest_position_assay = 'Y'
   and vsp.ash_id = vdc.ash_id
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id
   and vdc.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pcpd.input_output = 'Input'
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id(+)
   and grd.warehouse_profile_id = phd_wh.profileid(+)
   and grd.tolling_stock_type ='None Tolling'
-- 3. shipped but not tt sales gmrs
union all
select 'Composite' product_type,
       'Concentrates Shipped But Not TT for Sales GMRs' section_name,
       akc.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       pdm.product_id product_id,
       pdm.product_desc product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       'NA' origin_id,
       'NA' origin_name,
       qat.quality_id quality_id,
       qat.quality_name quality_name,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       'Physical - Open Sales' position_type_id,
       'Open' position_type,
       'Sales' position_sub_type,
       case
         when pci.contract_ref_no is not null then
          gmr.gmr_ref_no || ',' || pci.contract_ref_no || ',' ||
          pci.del_distribution_item_no
         else
          gmr.gmr_ref_no
       end contract_ref_no,
       nvl(pci.cp_contract_ref_no, 'NA') external_reference_no,
       pci.issue_date issue_date,
       pci.cp_id counter_party_id,
       phd_pcm_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_name,
       pcm.partnership_type execution_type,
       'NA' broker_profile_id,
       'NA' broker_name,
       itm.incoterm_id incoterm_id,
       itm.incoterm incoterm,
       pym.payment_term_id payment_term_id,
       pym.payment_term payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       'NA' price_type_name,
       cm_invoice_curreny.cur_id pay_in_cur_id,
       cm_invoice_curreny.cur_code pay_in_cur_code,
       'NA' item_price_string,
       case
         when itm.location_field = 'DESTINATION' then
          pcdb.country_id
         else
          'NA'
       end destination_country_id,
       case
         when itm.location_field = 'DESTINATION' then
          cym_pcdb.country_name
         else
          'NA'
       end destination_country,
       case
         when itm.location_field = 'DESTINATION' then
          cim_pcdb.city_id
         else
          'NA'
       end destination_city_id,
       case
         when itm.location_field = 'DESTINATION' then
          cim_pcdb.city_name
         else
          'NA'
       end destination_city,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_id
         else
          'NA'
       end dest_state_id,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_name
         else
          'NA'
       end dest_state_name,
       case
         when itm.location_field = 'DESTINATION' then
          rem_gmr.region_name
         else
          'NA'
       end dest_loc_group_name,
      to_char(nvl(dgrd.realized_date,sysdate), 'Mon-yyyy') period_month_year,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_from_date,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_to_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_to_date,
       (dgrd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
       ucm_base.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               qum_gcd.qty_unit_id,
                                               1)
       end) *pqca.typical qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (dgrd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
       ucm.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   dgrd.net_weight_unit_id),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               dgrd.net_weight_unit_id,
                                               1)
       end) * pqca.typical qty_in_ctract_unit,
       qum_dgrd.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       to_char(nvl(dgrd.realized_date,sysdate), 'Mon-yyyy') delivery_month,
       cm_invoice_curreny.cur_id invoice_cur_id,
       cm_invoice_curreny.cur_code invoice_cur_code,
       qum_under.qty_unit base_qty_unit,
       (dgrd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
       ucm_base.multiplication_factor *
       
       (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
       end) * pqca.typical qty_in_base_unit,
       case
         when itm.location_field = 'DESTINATION' then
          pcdb.country_id
         else
          'NA'
       end || ' - ' || case
         when itm.location_field = 'DESTINATION' then
          pcdb.city_id
         else
          'NA'
       end comb_destination_id,
       'NA' comb_origination_id,
       '' comb_valuation_loc_id,
       pdm_under.product_desc element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       nvl(sld.storage_loc_id, 'NA'),
       nvl(sld.storage_location_name, 'NA')
  from dgrd_delivered_grd             dgrd,
       gmr_goods_movement_record      gmr,
       pcm_physical_contract_main     pcm,
       pcmte_pcm_tolling_ext          pcmte,
       pcpd_pc_product_definition     pcpd,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       pcpq_pc_product_quality        pcpq,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       rem_region_master              rem_gmr,
       v_pci_pcdi_details             pci,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       pdm_productmaster              pdm,
       pgm_product_group_master       pgm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       itm_incoterm_master            itm,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       gab_globaladdressbook          gab,
       ak_corporate_user              aku,
       pym_payment_terms_master       pym,
       phd_profileheaderdetails       phd_pcm_cp,
       cm_currency_master             cm_invoice_curreny,
       pcdb_pc_delivery_basis         pcdb,
       cim_citymaster                 cim_pcdb,
       cym_countrymaster              cym_pcdb,
       sm_state_master                sm_pcdb,
       qum_quantity_unit_master       qum_gcd,
       qum_quantity_unit_master       qum_dgrd,
       cm_currency_master             cm_base_cur,
       ucm_unit_conversion_master     ucm,
       v_ucm_conversion               ucm_base,
       qat_quality_attributes         qat,
       --  v_stock_position_assay_id      vsp,
       sam_stock_assay_mapping        vsp,
       ash_assay_header               vdc,
       qum_quantity_unit_master       qum_under,
       asm_assay_sublot_mapping       asm,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       phd_profileheaderdetails       phd_wh
 where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id = ppm.product_id
   and pqca.element_id = ppm.attribute_id
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and ppm.property_id = qav.attribute_id
   and pci.pcpq_id = pcpq.pcpq_id(+)
   and pcpq.quality_template_id = qav.quality_id
   and qav.is_deleted = 'N'
   and dgrd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and cym_gmr.region_id = rem_gmr.region_id(+)
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and dgrd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdtm.product_type_name = 'Composite'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and nvl(dgrd.current_qty, 0) > 0
   and nvl(dgrd.inventory_status, 'NA') <> 'Out'
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and dgrd.status = 'Active'
   and gmr.created_by = aku.user_id
   and aku.gabid = gab.gabid(+)
   and pci.payment_term_id = pym.payment_term_id(+)
   and pci.cp_id = phd_pcm_cp.profileid(+)
   and pci.invoice_currency_id = cm_invoice_curreny.cur_id(+)
   and pcdb.internal_contract_ref_no = pci.internal_contract_ref_no
   and pci.pcdb_id = pcdb.pcdb_id
   and pcdb.is_active = 'Y'
   and pci.pcdi_id = poch.pcdi_id
   and poch.is_active = 'Y'
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id
   and pcdb.city_id = cim_pcdb.city_id(+)
   and pcdb.state_id = sm_pcdb.state_id(+)
   and pcdb.country_id = cym_pcdb.country_id(+)
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and ucm.from_qty_unit_id = dgrd.net_weight_unit_id
   and ucm.to_qty_unit_id = gcd.group_qty_unit_id
   and cm_base_cur.cur_id = akc.base_cur_id
   and qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id
   and dgrd.net_weight_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and qat.quality_id = dgrd.quality_id
   and dgrd.internal_dgrd_ref_no = vsp.internal_dgrd_ref_no
   and vsp.is_latest_pricing_assay = 'Y'
   and vsp.ash_id = vdc.ash_id
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id
   and vdc.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pcpd.input_output = 'Input'
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id(+)
   and dgrd.warehouse_profile_id = phd_wh.profileid(+)
   and dgrd.tolling_stock_type ='None Tolling'
union all
--4
select 'Composite' product_type,
       'Concentrates TT In for Purchase  GMRs' section_name,
       gmr.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       grd.product_id product_id,
       pdm.product_desc product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       'Stocks -  Actual Stocks' position_type_id,
       'Inventory' position_type,
       'Stocks' position_sub_type,
       case
         when pci.contract_ref_no is not null then
          gmr.gmr_ref_no || ',' || pci.contract_ref_no || ',' ||
          pci.del_distribution_item_no
         else
          gmr.gmr_ref_no
       end contract_ref_no,
       'NA' external_reference_no,
       gmr.eff_date issue_date,
       'NA' counter_party_id,
       'NA' counter_party_name,
       'NA' trader_user_id,
       'NA' trader_name,
       pcm.partnership_type execution_type,
       'NA' broker_profile_id,
       'NA' broker_name,
       'NA' incoterm_id,
       'NA' incoterm,
       'NA' payment_term_id,
       'NA' payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       'NA' price_type_name,
       'NA' pay_in_cur_id,
       'NA' pay_in_cur_code,
       'NA' item_price_string,
       cym_gmr_dest_country.country_id dest_country_id,
       cym_gmr_dest_country.country_name dest_country_name,
       cim_gmr_dest_city.city_id dest_city_id,
       cim_gmr_dest_city.city_name dest_city_name,
       sm_gmr_dest_state.state_id dest_state_id,
       sm_gmr_dest_state.state_name dest_state_name,
       rem_gmr_dest_region.region_name dest_loc_group_name,
       to_char(nvl(gmr.inventory_in_date,sysdate), 'Mon-yyyy') period_month_year,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_from_date,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_to_date,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0))* (asm.dry_wet_qty_ratio / 100)) *
       ucm_base.multiplication_factor *
       
       (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               qum_gcd.qty_unit_id,
                                               1)
       end) *pqca.typical qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * (asm.dry_wet_qty_ratio / 100)) *
       ucm.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   grd.qty_unit_id),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               grd.qty_unit_id,
                                               1)
       end) * pqca.typical qty_in_ctract_unit,
       grd.qty_unit_id ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       to_char(nvl(gmr.inventory_in_date,sysdate), 'Mon-yyyy') delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       qum_under.qty_unit base_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0))* (asm.dry_wet_qty_ratio / 100)) *
       
       (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)/100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
       end) * pqca.typical qty_in_base_unit,
       cym_gmr_dest_country.country_id || ' - ' ||
       cim_gmr_dest_city.city_id comb_destination_id,
       'NA' comb_origination_id,
       '' comb_valuation_loc_id,
       pdm_under.product_desc element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       nvl(sld.storage_loc_id, 'NA'),
       nvl(sld.storage_location_name, 'NA')
  from grd_goods_record_detail        grd,
       gmr_goods_movement_record      gmr,
       pcm_physical_contract_main     pcm,
       pcmte_pcm_tolling_ext          pcmte,
       pcpd_pc_product_definition     pcpd,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       pcpq_pc_product_quality        pcpq,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_gmr,
       v_pci_pcdi_details             pci,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       pdm_productmaster              pdm,
       pgm_product_group_master       pgm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       qat_quality_attributes         qat,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       cm_currency_master             cm_invoice_currency,
       cim_citymaster                 cim_gmr_dest_city,
       cym_countrymaster              cym_gmr_dest_country,
       rem_region_master              rem_gmr_dest_region,
       sm_state_master                sm_gmr_dest_state,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       cm_currency_master             cm_base_currency,
       pcdi_pc_delivery_item          pcdi,
       v_ucm_conversion               ucm_base,
       -- v_stock_position_assay_id      vsp,
       sam_stock_assay_mapping        vsp,
       ash_assay_header               vdc,
       qum_quantity_unit_master       qum_under,
       asm_assay_sublot_mapping       asm,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       phd_profileheaderdetails       phd_wh
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id = ppm.product_id
   and pqca.element_id = ppm.attribute_id
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and ppm.property_id = qav.attribute_id
   and pci.pcpq_id = pcpq.pcpq_id(+)
   and pcpq.quality_template_id = qav.quality_id
   and qav.is_deleted = 'N'
   and grd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.pcdi_id = poch.pcdi_id
   and poch.is_active = 'Y'
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) > 0
   and pdtm.product_type_name = 'Composite'
   and pci.invoice_currency_id = cm_invoice_currency.cur_id(+)
   and cym_gmr_dest_country.country_id(+) = gmr.discharge_country_id
   and cym_gmr_dest_country.region_id = rem_gmr_dest_region.region_id(+)
   and cim_gmr_dest_city.city_id(+) = gmr.discharge_city_id
   and cim_gmr_dest_city.state_id = sm_gmr_dest_state.state_id(+)
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and gcd.group_qty_unit_id = ucm.to_qty_unit_id
   and cm_base_currency.cur_id = akc.base_cur_id
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pci.internal_contract_ref_no
   and grd.qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      -- and grd.internal_grd_ref_no = vsp.internal_grd_ref_no
   and grd.internal_grd_ref_no = vsp.internal_grd_ref_no
   and vsp.is_latest_position_assay = 'Y'
   and vsp.ash_id = vdc.ash_id
   and nvl(gmr.inventory_status, 'NA') = 'In'
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id
   and vdc.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pcpd.input_output = 'Input'
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id(+)
   and grd.warehouse_profile_id = phd_wh.profileid(+)
   and grd.tolling_stock_type ='None Tolling';
