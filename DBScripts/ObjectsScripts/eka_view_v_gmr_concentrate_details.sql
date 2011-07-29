create or replace view v_gmr_concentrate_details as
select subsectionname,
       internal_contract_ref_no,
       inco_term_id,
       pcdi_id,
       internal_contract_item_ref_no,
       corporate_group,
       business_line,
       corporate_id,
       corporate_name,
       profit_center,
       strategy,
       comp_product_name,
       comp_quality,
       product_name,
       quality,
       trader,
       instrument_name,
       incoterm,
       country_name,
       city_name,
       delivery_date,
       purchase_sales,
       baseqty_conv_rate,
       compqty_base_conv_rate,
       comp_base_qty_unit,
       comp_base_qty_unit_id,
       price_fixation_status,
       sum(total_qty) total_qty,
       sum(item_open_qty)item_open_qty,
       sum(open_qty) open_qty,
       sum(price_fixed_qty) price_fixed_qty,
       sum(unfixed_qty) unfixed_qty,
       item_qty_unit_id,
       qty_unit,
       contract_ref_no,
       del_distribution_item_no,
       gmr_ref_no,
       internal_gmr_ref_no,
       country_id,
       city_id,
       product_type_name,
       groupid,
       business_line_id,
       profit_center_id,
       strategy_id,
       product_id,
       quality_id,
       trader_id,
       derivative_def_id,
       instrument_id,
       product_type_id,
       assay_header_id,
       unit_of_measure,
       attribute_id,
       attribute_name,
       element_qty_unit_id,
       underlying_product_id,
       base_quantity_unit_id,
       position_type
  from (select (case
                 when grd.is_afloat = 'Y' then
                  'Afloat'
                 else
                  'Stock'
               end) subsectionname,
               pci.internal_contract_ref_no,
               pci.inco_term_id,
               pci.pcdi_id,
               pci.internal_contract_item_ref_no,
               gcd.groupname corporate_group,
               nvl(blm.business_line_name, 'NA') business_line,
               gmr.corporate_id,
               akc.corporate_name,
               nvl(cpc.profit_center_short_name, 'NA') profit_center,
               nvl(css.strategy_name, 'NA') strategy,
               pdm.product_desc comp_product_name,
               qat.quality_name comp_quality,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_desc, pdm.product_desc)
                 else
                  pdm.product_desc
               end) product_name,
               nvl(qav_qat.quality_name, qat.quality_name) quality,
               gab.firstname || ' ' || gab.lastname trader,
               null instrument_name,
               itm.incoterm,
               (case
                 when grd.is_afloat = 'Y' then
                  cym_gmr.country_name
                 else
                  cym_sld.country_name
               end) country_name,
               (case
                 when grd.is_afloat = 'Y' then
                  cim_gmr.city_name
                 else
                  cim_sld.city_name
               end) city_name,
               to_date('01-Feb-1900', 'dd-Mon-yyyy') delivery_date,
               (case
                 when nvl(gmr.contract_type, 'NA') = 'Purchase' then
                  'P'
                 when nvl(gmr.contract_type, 'NA') = 'Sales' then
                  'S'
                 when nvl(gmr.contract_type, 'NA') = 'B2B' then
                  nvl(pci.purchase_sales, 'P')
               end) purchase_sales,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  (case
                 when rm.ratio_name = '%' then
                  pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                           pdm.product_id),
                                                       grd.qty_unit_id,
                                                       nvl(pdm_under.base_quantity_unit,
                                                           pdm.base_quantity_unit),
                                                       1)
                 else
                  pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                           pdm.product_id),
                                                       rm.qty_unit_id_numerator,
                                                       nvl(pdm_under.base_quantity_unit,
                                                           pdm.base_quantity_unit),
                                                       1)
               end) else(pkg_general.f_get_converted_quantity(grd.product_id, grd.qty_unit_id, pdm.base_quantity_unit, 1)) end) baseqty_conv_rate,
             (pkg_general.f_get_converted_quantity(grd.product_id, grd.qty_unit_id, pdm.base_quantity_unit, 1)) compqty_base_conv_rate,
             qum.qty_unit comp_base_qty_unit,
             qum.qty_unit_id comp_base_qty_unit_id,
               null price_fixation_status,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.qty,
                                                           grd.qty_unit_id) total_qty,
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                               sam.ash_id,
                                               grd.current_qty,
                                               grd.qty_unit_id) item_open_qty,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.current_qty,
                                                           grd.qty_unit_id) open_qty,
               0 price_fixed_qty,
               0 unfixed_qty,
               grd.qty_unit_id item_qty_unit_id,
               nvl(qum_under.qty_unit, qum.qty_unit) qty_unit,
               pci.contract_ref_no,
               pci.del_distribution_item_no,
               gmr.gmr_ref_no,
               gmr.internal_gmr_ref_no,
               (case
                 when grd.is_afloat = 'Y' then
                  cym_gmr.country_id
                 else
                  cym_sld.country_id
               end) country_id,
               (case
                 when grd.is_afloat = 'Y' then
                  cim_gmr.city_id
                 else
                  cim_sld.city_id
               end) city_id,
               pdtm.product_type_name,
               gcd.groupid,
               blm.business_line_id,
               cpc.profit_center_id,
               css.strategy_id,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_id, pdm.product_id)
                 else
                  pdm.product_id
               end) product_id,
               nvl(qav_qat.quality_id, qat.quality_id) quality_id,
               gab.gabid trader_id,
               null derivative_def_id,
               null instrument_id,
               pdtm.product_type_id,
               sam.ash_id assay_header_id,
               'Wet' unit_of_measure,
               aml.attribute_id,
               aml.attribute_name,
               (case
                 when rm.ratio_name = '%' then
                  grd.qty_unit_id
                 else
                  rm.qty_unit_id_numerator
               end) element_qty_unit_id,
               aml.underlying_product_id,
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_quantity_unit_id,
               'CONCENTRATES' position_type
          from grd_goods_record_detail        grd,
               gmr_goods_movement_record      gmr,
               sld_storage_location_detail    sld,
               cim_citymaster                 cim_sld,
               cim_citymaster                 cim_gmr,
               cym_countrymaster              cym_sld,
               cym_countrymaster              cym_gmr,
               v_pci_pcdi_details             pci,
               pdm_productmaster              pdm,
               pdtm_product_type_master       pdtm,
               qum_quantity_unit_master       qum,
               itm_incoterm_master            itm,
               sam_stock_assay_mapping        sam,
               ash_assay_header               ash,
               asm_assay_sublot_mapping       asm,
               aml_attribute_master_list      aml,
               pqca_pq_chemical_attributes    pqca,
               rm_ratio_master                rm,
               ppm_product_properties_mapping ppm,
               qav_quality_attribute_values   qav,
               qat_quality_attributes         qav_qat,
               qat_quality_attributes         qat,
               pdm_productmaster              pdm_under,
               qum_quantity_unit_master       qum_under,
               css_corporate_strategy_setup   css,
               cpc_corporate_profit_center    cpc,
               blm_business_line_master       blm,
               ak_corporate                   akc,
               gcd_groupcorporatedetails      gcd,
               gab_globaladdressbook          gab
         where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and grd.product_id = pdm.product_id
           and pdm.product_type_id = pdtm.product_type_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and grd.shed_id = sld.storage_loc_id(+)
           and sld.city_id = cim_sld.city_id(+)
           and gmr.discharge_city_id = cim_gmr.city_id(+)
           and cim_sld.country_id = cym_sld.country_id(+)
           and cim_gmr.country_id = cym_gmr.country_id(+)
           and grd.internal_grd_ref_no = sam.internal_grd_ref_no
           and sam.stock_type = 'P'
           and sam.ash_id = ash.ash_id
           and ash.ash_id = asm.ash_id
           and ash.is_active = 'Y'
           and nvl(ash.is_delete, 'N') = 'N'
           and nvl(asm.is_active, 'Y') = 'Y'
           and sam.is_active = 'Y'
           and asm.asm_id = pqca.asm_id
           and pqca.element_id = aml.attribute_id
           and pqca.is_elem_for_pricing = 'Y'
           and pqca.unit_of_measure = rm.ratio_id
              -----
           and grd.product_id = ppm.product_id
           and aml.attribute_id = ppm.attribute_id
           and ppm.is_active = 'Y'
           and ppm.is_deleted = 'N'
           and ppm.property_id = qav.attribute_id
           and grd.quality_id = qav.quality_id
           and qav.is_deleted = 'N'
           and qav.comp_quality_id = qav_qat.quality_id(+)
           and grd.quality_id = qat.quality_id(+)
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
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
           and gmr.is_internal_movement = 'N'
           and nvl(grd.current_qty, 0) > 0
           and gmr.created_by = gab.gabid(+)
        union all
        select (case
                 when grd.is_afloat = 'Y' then
                  'Afloat'
                 else
                  'Stock'
               end) subsectionname,
               pci.internal_contract_ref_no,
               pci.inco_term_id,
               pci.pcdi_id,
               pci.internal_contract_item_ref_no,
               gcd.groupname corporate_group,
               nvl(blm.business_line_name, 'NA') business_line,
               gmr.corporate_id,
               akc.corporate_name,
               nvl(cpc.profit_center_short_name, 'NA') profit_center,
               nvl(css.strategy_name, 'NA') strategy,
               pdm.product_desc comp_product_name,
               qat.quality_name comp_quality,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_desc, pdm.product_desc)
                 else
                  pdm.product_desc
               end) product_name,
               nvl(qav_qat.quality_name, qat.quality_name) quality,
               gab.firstname || ' ' || gab.lastname trader,
               null instrument_name,
               itm.incoterm,
               (case
                 when grd.is_afloat = 'Y' then
                  cym_gmr.country_name
                 else
                  cym_sld.country_name
               end) country_name,
               (case
                 when grd.is_afloat = 'Y' then
                  cim_gmr.city_name
                 else
                  cim_sld.city_name
               end) city_name,
               to_date('01-Feb-1900', 'dd-Mon-yyyy') delivery_date,
               (case
                 when nvl(gmr.contract_type, 'NA') = 'Purchase' then
                  'P'
                 when nvl(gmr.contract_type, 'NA') = 'Sales' then
                  'S'
                 when nvl(gmr.contract_type, 'NA') = 'B2B' then
                  nvl(pci.purchase_sales, 'P')
               end) purchase_sales,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  (case
                 when rm.ratio_name = '%' then
                  pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                           pdm.product_id),
                                                       grd.net_weight_unit_id,
                                                       nvl(pdm_under.base_quantity_unit,
                                                           pdm.base_quantity_unit),
                                                       1)
                 else
                  pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                           pdm.product_id),
                                                       rm.qty_unit_id_numerator,
                                                       nvl(pdm_under.base_quantity_unit,
                                                           pdm.base_quantity_unit),
                                                       1)
               end) else(pkg_general.f_get_converted_quantity(grd.product_id, grd.net_weight_unit_id, pdm.base_quantity_unit, 1)) end) baseqty_conv_rate,
             (pkg_general.f_get_converted_quantity(grd.product_id, grd.net_weight_unit_id, pdm.base_quantity_unit, 1)) compqty_base_conv_rate,
             qum.qty_unit comp_base_qty_unit,
             qum.qty_unit_id comp_base_qty_unit_id,
               null price_fixation_status,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.net_weight,
                                                           grd.net_weight_unit_id) total_qty,
              pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                               sam.ash_id,
                                               grd.current_qty,
                                               grd.net_weight_unit_id) item_open_qty,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.current_qty,
                                                           grd.net_weight_unit_id) open_qty,
               0 price_fixed_qty,
               0 unfixed_qty,
               grd.net_weight_unit_id item_qty_unit_id,
               nvl(qum_under.qty_unit, qum.qty_unit) qty_unit,
               pci.contract_ref_no,
               pci.del_distribution_item_no,
               gmr.gmr_ref_no,
               gmr.internal_gmr_ref_no,
               (case
                 when grd.is_afloat = 'Y' then
                  cym_gmr.country_id
                 else
                  cym_sld.country_id
               end) country_id,
               (case
                 when grd.is_afloat = 'Y' then
                  cim_gmr.city_id
                 else
                  cim_sld.city_id
               end) city_id,
               pdtm.product_type_name,
               gcd.groupid,
               blm.business_line_id,
               cpc.profit_center_id,
               css.strategy_id,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_id, pdm.product_id)
                 else
                  pdm.product_id
               end) product_id,
               nvl(qav_qat.quality_id, qat.quality_id) quality_id,
               gab.gabid trader_id,
               null derivative_def_id,
               null instrument_id,
               pdtm.product_type_id,
               sam.ash_id assay_header_id,
               'Wet' unit_of_measure,
               aml.attribute_id,
               aml.attribute_name,
               (case
                 when rm.ratio_name = '%' then
                  grd.net_weight_unit_id
                 else
                  rm.qty_unit_id_numerator
               end) element_qty_unit_id,
               aml.underlying_product_id,
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_quantity_unit_id,
               'CONCENTRATES' position_type
          from dgrd_delivered_grd             grd,
               gmr_goods_movement_record      gmr,
               sld_storage_location_detail    sld,
               cim_citymaster                 cim_sld,
               cim_citymaster                 cim_gmr,
               cym_countrymaster              cym_sld,
               cym_countrymaster              cym_gmr,
               v_pci_pcdi_details             pci,
               pdm_productmaster              pdm,
               pdtm_product_type_master       pdtm,
               qum_quantity_unit_master       qum,
               itm_incoterm_master            itm,
               sam_stock_assay_mapping        sam,
               ash_assay_header               ash,
               asm_assay_sublot_mapping       asm,
               aml_attribute_master_list      aml,
               pqca_pq_chemical_attributes    pqca,
               rm_ratio_master                rm,
               ppm_product_properties_mapping ppm,
               qav_quality_attribute_values   qav,
               qat_quality_attributes         qav_qat,
               qat_quality_attributes         qat,
               pdm_productmaster              pdm_under,
               qum_quantity_unit_master       qum_under,
               css_corporate_strategy_setup   css,
               cpc_corporate_profit_center    cpc,
               blm_business_line_master       blm,
               ak_corporate                   akc,
               gcd_groupcorporatedetails      gcd,
               gab_globaladdressbook          gab
         where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and grd.product_id = pdm.product_id
           and pdm.product_type_id = pdtm.product_type_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and grd.shed_id = sld.storage_loc_id(+)
           and sld.city_id = cim_sld.city_id(+)
           and gmr.discharge_city_id = cim_gmr.city_id(+)
           and cim_sld.country_id = cym_sld.country_id(+)
           and cim_gmr.country_id = cym_gmr.country_id(+)
           and grd.internal_dgrd_ref_no = sam.internal_dgrd_ref_no
           and sam.stock_type = 'S'
           and sam.ash_id = ash.ash_id
           and ash.ash_id = asm.ash_id
           and ash.is_active = 'Y'
           and nvl(ash.is_delete, 'N') = 'N'
           and nvl(asm.is_active, 'Y') = 'Y'
           and sam.is_active = 'Y'
           and asm.asm_id = pqca.asm_id
           and pqca.element_id = aml.attribute_id
           and pqca.is_elem_for_pricing = 'Y'
           and pqca.unit_of_measure = rm.ratio_id
              -----
           and grd.product_id = ppm.product_id
           and aml.attribute_id = ppm.attribute_id
           and ppm.is_active = 'Y'
           and ppm.is_deleted = 'N'
           and ppm.property_id = qav.attribute_id
           and grd.quality_id = qav.quality_id
           and qav.is_deleted = 'N'
           and qav.comp_quality_id = qav_qat.quality_id(+)
           and grd.quality_id = qat.quality_id(+)
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and gmr.corporate_id = akc.corporate_id
           and akc.groupid = gcd.groupid
           and grd.status = 'Active'
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no(+)
           and pci.inco_term_id = itm.incoterm_id(+)
           and pci.strategy_id = css.strategy_id(+)
           and pci.profit_center_id = cpc.profit_center_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.is_internal_movement = 'N'
--           and nvl(gmr.inventory_status, 'NA') <> 'Out'
           and nvl(grd.current_qty, 0) > 0
           and gmr.created_by = gab.gabid(+))
 group by subsectionname,
          internal_contract_ref_no,
          inco_term_id,
          pcdi_id,
          internal_contract_item_ref_no,
          corporate_group,
          business_line,
          corporate_id,
          corporate_name,
          profit_center,
          strategy,
          product_name,
          quality,
          trader,
          instrument_name,
          incoterm,
          country_name,
          city_name,
          delivery_date,
          purchase_sales,
          baseqty_conv_rate,   compqty_base_conv_rate,
       comp_base_qty_unit,
       comp_base_qty_unit_id,
          price_fixation_status,
          item_qty_unit_id,
          qty_unit,
          contract_ref_no,
          del_distribution_item_no,
          gmr_ref_no,
          internal_gmr_ref_no,
          country_id,
          city_id,
          product_type_name,
          groupid,
          business_line_id,
          profit_center_id,
          strategy_id,
          product_id,
          quality_id,
          trader_id,
          derivative_def_id,
          instrument_id,
          product_type_id,
          assay_header_id,
          unit_of_measure,
          attribute_id,comp_product_name,
       comp_quality,
          attribute_name,
          element_qty_unit_id,
          underlying_product_id,
          base_quantity_unit_id,
          position_type

