create or replace view v_pci_element_qty as
select cipq.internal_contract_item_ref_no,
       cipq.element_id,
       sum(cipq.payable_qty) payable_qty,
       cipq.qty_unit_id
  from cipq_contract_item_payable_qty cipq
 where cipq.is_active = 'Y'
 group by cipq.internal_contract_item_ref_no,
          cipq.element_id,
          cipq.qty_unit_id
/
create or replace view v_gmr_exchange_details as
select pofh.internal_gmr_ref_no,
       ppfd.instrument_id,
       dim.instrument_name,
       pdd.derivative_def_id,
       pdd.derivative_def_name,
       emt.exchange_id,
       emt.exchange_name,
       pcbpd.element_id,
       pofh.qty_to_be_fixed,
       pofh.pofh_id,
       pofh.pocd_id,
       pofh.no_of_prompt_days,
       pofh.per_day_pricing_qty,
       round(nvl(pofh.priced_qty, 0), 5) priced_qty,
       round(pofh.qty_to_be_fixed - round(nvl(pofh.priced_qty, 0), 5), 5) unpriced_qty,
       pofh.qp_start_date,
       pofh.qp_end_date
  from pofh_price_opt_fixation_header pofh,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       pdd_product_derivative_def     pdd,
       emt_exchangemaster             emt
 where pofh.pocd_id = pocd.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.exchange_id = emt.exchange_id(+)
   and pofh.internal_gmr_ref_no is not null
   and pofh.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
 group by pofh.internal_gmr_ref_no,
          ppfd.instrument_id,
          dim.instrument_name,
          pdd.derivative_def_id,
          pdd.derivative_def_name,
          emt.exchange_id,
          emt.exchange_name,
          pcbpd.element_id,
          pofh.qty_to_be_fixed,
          pofh.pofh_id,
          pofh.pocd_id,
          pofh.no_of_prompt_days,
          pofh.per_day_pricing_qty,
          pofh.priced_qty,
          pofh.qty_to_be_fixed,
          pofh.priced_qty,
          pofh.qp_start_date,
          pofh.qp_end_date
/
create or replace view v_gmr_payable_qty as 
select spq.internal_gmr_ref_no,
       spq.stock_type,
       spq.element_id,
       sum(spq.payable_qty) payable_qty,
       spq.qty_unit_id
  from spq_stock_payable_qty spq
 where spq.is_active = 'Y'
 group by spq.internal_gmr_ref_no,
          spq.stock_type,
          spq.element_id,
          spq.qty_unit_id
/
create or replace view v_gmr_pfc_details as
select gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       nvl(blm.business_line_name, 'NA') business_line,
       gmr.corporate_id,
       nvl(cpc.profit_center_short_name, 'NA') profit_center,
       nvl(css.strategy_name, 'NA') strategy,
       pdm.product_desc product_name,
       qat.quality_name quality,
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
       gmr.qty gmr_qty,
       gmr_pfc.qty_to_be_fixed,
       gmr_pfc.priced_qty,
       gmr_pfc.unpriced_qty,
       gmr_pfc.qp_start_date,
       gmr_pfc.qp_end_date,
       gmr_pfc.no_of_prompt_days,
       gmr_pfc.per_day_pricing_qty,
       pkg_general.f_get_converted_quantity(grd.product_id,
                                            gmr.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       sum(nvl(grd.qty, 0)) total_qty,
       sum(nvl(grd.current_qty, 0)) open_qty,
       grd.qty_unit_id item_qty_unit_id,
       qum.qty_unit,
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
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       pdm.product_id,
       qat.quality_id,
       pdtm.product_type_id,
       v_gmr.instrument_id,
       v_gmr.instrument_name,
       v_gmr.derivative_def_id,
       v_gmr.derivative_def_name,
       v_gmr.exchange_id,
       v_gmr.exchange_name
  from grd_goods_record_detail grd,
       gmr_goods_movement_record gmr,
       v_gmr_exchange_details v_gmr,
       (select pofh.internal_gmr_ref_no,
               pofh.qty_to_be_fixed,
               pofh.no_of_prompt_days,
               pofh.per_day_pricing_qty,
               round(nvl(pofh.priced_qty, 0), 5) priced_qty,
               round(pofh.qty_to_be_fixed -
                     round(nvl(pofh.priced_qty, 0), 5),
                     5) unpriced_qty,
               pofh.qp_start_date,
               pofh.qp_end_date
          from pofh_price_opt_fixation_header pofh
         where pofh.is_active = 'Y'
           and pofh.internal_gmr_ref_no is not null) gmr_pfc,
       sld_storage_location_detail sld,
       cim_citymaster cim_sld,
       cim_citymaster cim_gmr,
       cym_countrymaster cym_sld,
       cym_countrymaster cym_gmr,
       v_pci_pcdi_details pci,
       pdm_productmaster pdm,
       pdtm_product_type_master pdtm,
       qum_quantity_unit_master qum,
       itm_incoterm_master itm,
       qat_quality_attributes qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center cpc,
       blm_business_line_master blm,
       ak_corporate akc
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and gmr.internal_gmr_ref_no = gmr_pfc.internal_gmr_ref_no
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.internal_gmr_ref_no = v_gmr.internal_gmr_ref_no
 group by gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          nvl(blm.business_line_name, 'NA'),
          gmr.corporate_id,
          nvl(cpc.profit_center_short_name, 'NA'),
          nvl(css.strategy_name, 'NA'),
          gmr.qty_unit_id,
          pdm.product_desc,
          qat.quality_name,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_name
            else
             cym_sld.country_name
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
          gmr.contract_type,
          pci.purchase_sales,
          grd.product_id,
          grd.qty_unit_id,
          pdm.base_quantity_unit,
          grd.qty_unit_id,
          qum.qty_unit,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_id
            else
             cym_sld.country_id
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_id
            else
             cim_sld.city_id
          end),
          pdtm.product_type_name,
          blm.business_line_id,
          cpc.profit_center_id,
          css.strategy_id,
          pdm.product_id,
          gmr.qty,
          gmr_pfc.qty_to_be_fixed,
          gmr_pfc.no_of_prompt_days,
          gmr_pfc.per_day_pricing_qty,
          gmr_pfc.priced_qty,
          gmr_pfc.unpriced_qty,
          gmr_pfc.qp_start_date,
          gmr_pfc.qp_end_date,
          qat.quality_id,
          pdtm.product_type_id,
          v_gmr.instrument_id,
          v_gmr.instrument_name,
          v_gmr.derivative_def_id,
          v_gmr.derivative_def_name,
          v_gmr.exchange_id,
          v_gmr.exchange_name
/
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
       sum(item_open_qty) item_open_qty,
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
       position_type,
       assay_convertion_rate
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
               (pkg_general.f_get_converted_quantity(grd.product_id,
                                                     grd.qty_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1)) compqty_base_conv_rate,
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
               'CONCENTRATES' position_type,
                pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           1,
                                                           grd.qty_unit_id) assay_convertion_rate
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
               (pkg_general.f_get_converted_quantity(grd.product_id,
                                                     grd.net_weight_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1)) compqty_base_conv_rate,
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
               'CONCENTRATES' position_type,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           1,
                                                           grd.net_weight_unit_id) assay_convertion_rate
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
          baseqty_conv_rate,
          compqty_base_conv_rate,
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
          attribute_id,
          comp_product_name,
          comp_quality,
          attribute_name,
          element_qty_unit_id,
          underlying_product_id,
          base_quantity_unit_id,
          position_type,assay_convertion_rate
/

create or replace view v_gmr_stock_details as
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
       pdm.product_desc product_name,
       qat.quality_name quality,
       gab.firstname || ' ' || gab.lastname trader,
       pdd.derivative_def_name instrument_name,
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
       pkg_general.f_get_converted_quantity(grd.product_id,
                                            grd.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       null price_fixation_status,
       sum(nvl(grd.qty, 0)) total_qty,
       sum(nvl(grd.current_qty, 0)) item_open_qty,
       sum(nvl(grd.current_qty, 0)) open_qty,
       0 price_fixed_qty,
       0 unfixed_qty,
       grd.qty_unit_id item_qty_unit_id,
       qum.qty_unit,
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
       pdm.product_id,
       qat.quality_id,
       gab.gabid trader_id,
       pdd.derivative_def_id,
       qat.instrument_id,
       pdtm.product_type_id,
       null assay_header_id,
       null unit_of_measure,
       null attribute_id,
       null attribute_name,
       null element_qty_unit_id,
       null underlying_product_id,
       'BASEMETAL' position_type,
       1 contract_row,
       pkg_general.f_get_converted_quantity(grd.product_id,
                                            grd.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) compqty_base_conv_rate,
       qum.qty_unit comp_base_qty_unit,
       pdm.base_quantity_unit comp_base_qty_unit_id,
       1 assay_convertion_rate
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       sld_storage_location_detail  sld,
       cim_citymaster               cim_sld,
       cim_citymaster               cim_gmr,
       cym_countrymaster            cym_sld,
       cym_countrymaster            cym_gmr,
       v_pci_pcdi_details           pci,
       pdm_productmaster            pdm,
       pdtm_product_type_master     pdtm,
       qum_quantity_unit_master     qum,
       itm_incoterm_master          itm,
       v_qat_quality_valuation      qat,
       pdd_product_derivative_def   pdd,
       dim_der_instrument_master    dim,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       gcd_groupcorporatedetails    gcd,
       gab_globaladdressbook        gab
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = qat.corporate_id
   and qat.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
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
 group by pci.internal_contract_ref_no,
          (case
            when grd.is_afloat = 'Y' then
             'Afloat'
            else
             'Stock'
          end),
          pci.internal_contract_ref_no,
          pci.inco_term_id,
          pci.pcdi_id,
          pci.internal_contract_item_ref_no,
          gcd.groupname,
          nvl(blm.business_line_name, 'NA'),
          gmr.corporate_id,
          akc.corporate_name,
          nvl(cpc.profit_center_short_name, 'NA'),
          nvl(css.strategy_name, 'NA'),
          pdm.product_desc,
          qat.quality_name,
          gab.firstname || ' ' || gab.lastname,
          pdd.derivative_def_name,
          itm.incoterm,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_name
            else
             cym_sld.country_name
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
          (case
            when nvl(gmr.contract_type, 'NA') = 'Purchase' then
             'P'
            when nvl(gmr.contract_type, 'NA') = 'Sales' then
             'S'
            when nvl(gmr.contract_type, 'NA') = 'B2B' then
             nvl(pci.purchase_sales, 'P')
          end),
          grd.product_id,
          grd.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          pci.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_id
            else
             cym_sld.country_id
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_id
            else
             cim_sld.city_id
          end),
          pdtm.product_type_name,
          gcd.groupid,
          blm.business_line_id,
          cpc.profit_center_id,
          css.strategy_id,
          pdm.product_id,
          qat.quality_id,
          gab.gabid,
          pdd.derivative_def_id,
          qat.instrument_id,
          pdtm.product_type_id
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
       pdm.product_desc product_name,
       qat.quality_name quality,
       gab.firstname || ' ' || gab.lastname trader,
       pdd.derivative_def_name instrument_name,
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
       pkg_general.f_get_converted_quantity(grd.product_id,
                                            grd.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       null price_fixation_status,
       sum(nvl(grd.qty, 0)) total_qty,
       sum(nvl(grd.current_qty, 0)) item_open_qty,
       sum(nvl(grd.current_qty, 0)) open_qty,
       0 price_fixed_qty,
       0 unfixed_qty,
       grd.qty_unit_id item_qty_unit_id,
       qum.qty_unit,
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
       pdm.product_id,
       qat.quality_id,
       gab.gabid trader_id,
       pdd.derivative_def_id,
       qat.instrument_id,
       pdtm.product_type_id,
       null assay_header_id,
       null unit_of_measure,
       null attribute_id,
       null attribute_name,
       null element_qty_unit_id,
       null underlying_product_id,
       'BASEMETAL' position_type,
       1 contract_row,
       pkg_general.f_get_converted_quantity(grd.product_id,
                                            grd.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) compqty_base_conv_rate,
       qum.qty_unit comp_base_qty_unit,
       pdm.base_quantity_unit comp_base_qty_unit_id,
       1 assay_convertion_rate
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       sld_storage_location_detail  sld,
       cim_citymaster               cim_sld,
       cim_citymaster               cim_gmr,
       cym_countrymaster            cym_sld,
       cym_countrymaster            cym_gmr,
       v_pci_pcdi_details           pci,
       pdm_productmaster            pdm,
       pdtm_product_type_master     pdtm,
       qum_quantity_unit_master     qum,
       itm_incoterm_master          itm,
       v_qat_quality_valuation      qat,
       pdd_product_derivative_def   pdd,
       dim_der_instrument_master    dim,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       gcd_groupcorporatedetails    gcd,
       gab_globaladdressbook        gab
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = qat.corporate_id
   and qat.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
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
   and gmr.is_internal_movement = 'Y'
   and nvl(grd.current_qty, 0) > 0
   and gmr.created_by = gab.gabid(+)
 group by pci.internal_contract_ref_no,
          (case
            when grd.is_afloat = 'Y' then
             'Afloat'
            else
             'Stock'
          end),
          pci.internal_contract_ref_no,
          pci.inco_term_id,
          pci.pcdi_id,
          pci.internal_contract_item_ref_no,
          gcd.groupname,
          nvl(blm.business_line_name, 'NA'),
          gmr.corporate_id,
          akc.corporate_name,
          nvl(cpc.profit_center_short_name, 'NA'),
          nvl(css.strategy_name, 'NA'),
          pdm.product_desc,
          qat.quality_name,
          gab.firstname || ' ' || gab.lastname,
          pdd.derivative_def_name,
          itm.incoterm,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_name
            else
             cym_sld.country_name
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
          (case
            when nvl(gmr.contract_type, 'NA') = 'Purchase' then
             'P'
            when nvl(gmr.contract_type, 'NA') = 'Sales' then
             'S'
            when nvl(gmr.contract_type, 'NA') = 'B2B' then
             nvl(pci.purchase_sales, 'P')
          end),
          grd.product_id,
          grd.qty_unit_id,
          pdm.base_quantity_unit,
          pdtm.product_type_name,
          qum.qty_unit,
          pci.contract_ref_no,
          pci.del_distribution_item_no,
          pci.internal_contract_item_ref_no,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_id
            else
             cym_sld.country_id
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_id
            else
             cim_sld.city_id
          end),
          pdtm.product_type_name,
          gcd.groupid,
          blm.business_line_id,
          cpc.profit_center_id,
          css.strategy_id,
          pdm.product_id,
          qat.quality_id,
          gab.gabid,
          pdd.derivative_def_id,
          qat.instrument_id,
          pdtm.product_type_id
union all
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
       price_fixation_status,
       (total_qty) total_qty,
       (item_open_qty) item_open_qty,
       (open_qty) open_qty,
       (price_fixed_qty) price_fixed_qty,
       (unfixed_qty) unfixed_qty,
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
       position_type,
       row_number() over(partition by internal_gmr_ref_no, internal_contract_item_ref_no order by internal_gmr_ref_no, internal_contract_item_ref_no, attribute_id) contract_row,
       compqty_base_conv_rate,
       comp_base_qty_unit,
       comp_base_qty_unit_id,
       vgmr.assay_convertion_rate
  from v_gmr_concentrate_details vgmr 
/

create or replace view v_phy_price_exposure as
select 'Open Base Metal' section_name,
       pcm.contract_ref_no,
       pcm.corporate_id,
       pcdi.pcdi_id,
       pcdi.internal_contract_ref_no,
       pci.internal_contract_item_ref_no,
       pcm.purchase_sales contract_type,
       null element_id,
       null attribute_name,
       pcdi.delivery_item_no,
       ppfh.price_unit_id,
       pocd.qp_period_type,
       pofh.qp_start_date price_qp_start_date,
       pofh.qp_end_date price_qp_end_date,
       pofh.qty_to_be_fixed,
       pofh.no_of_prompt_days,
       pofh.per_day_pricing_qty,
       pci.item_qty_unit_id,
       pcpd.product_id,
       pdm.product_desc,
       pdm.product_type_id,
       pdm.base_quantity_unit base_qty_unit_id,
       qum.qty_unit base_qty_unit,
       qum.decimals base_qty_unit_decimal,
       pcpd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       pcpd.unit_of_measure,
       pcpd.strategy_id,
       pcpq.quality_template_id,
       qat.quality_name,
       null assay_header_id,
       pcpd.product_id elem_product_id,
       pdm.product_desc elem_product_desc,
       pdm.base_quantity_unit elem_base_qty_unit_id,
       qum.qty_unit elem_qty_unit,
       qum.decimals elem_qty_unit_decimal,
       vpci.instrument_id,
       vpci.instrument_name,
       vpci.derivative_def_id,
       vpci.derivative_def_name,
       vpci.exchange_id,
       vpci.exchange_name,
       ucm.multiplication_factor baseqty_conv_rate,
       1 assay_convertion_rate
  from pcdi_pc_delivery_item          pcdi,
       pci_physical_contract_item     pci,
       pcm_physical_contract_main     pcm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       pfqpp_phy_formula_qp_pricing   pfqpp,
       pcpq_pc_product_quality        pcpq,
       pcpd_pc_product_definition     pcpd,
       pdm_productmaster              pdm,
       qum_quantity_unit_master       qum,
       qat_quality_attributes         qat,
       cpc_corporate_profit_center    cpc,
       v_pci_exchange_details         vpci,
       ucm_unit_conversion_master     ucm
 where pcdi.pcdi_id = pci.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   and ppfh.ppfh_id = pfqpp.ppfh_id(+)
   and pcm.contract_status = 'In Position'
   and pcm.contract_type = 'BASEMETAL'
   and pcbpd.price_basis <> 'Fixed'
   and pocd.qp_period_type <> 'Event'
   and pci.item_qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and pci.item_qty > 0
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active(+) = 'Y'
   and pcbpd.is_active = 'Y'
   and pci.pcpq_id = pcpq.pcpq_id
   and pcpq.pcpd_id = pcpd.pcpd_id
   and pcpq.is_active = 'Y'
   and pcpd.is_active = 'Y'
   and pcpd.product_id = pdm.product_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pci.internal_contract_item_ref_no =
       vpci.internal_contract_item_ref_no
/*union all
select 'Open Concentrate' section_name,
       pcm.contract_ref_no,
       pcm.corporate_id,
       pcdi.pcdi_id,
       pcdi.internal_contract_ref_no,
       pci.internal_contract_item_ref_no,
       pcm.contract_type,
       poch.element_id,
       aml.attribute_name,
       pcdi.delivery_item_no,
       ppfh.price_unit_id,
       pocd.qp_period_type,
       pofh.qp_start_date price_qp_start_date,
       pofh.qp_end_date price_qp_end_date,
       pofh.qty_to_be_fixed,
       pofh.no_of_prompt_days,
       pofh.per_day_pricing_qty,
       pci.item_qty_unit_id,
       pcpd.product_id,
       pdm.product_desc,
       pdm.product_type_id,
       pdm.base_quantity_unit base_qty_unit_id,
       qum.qty_unit base_qty_unit,
       qum.decimals base_qty_unit_decimal,
       pcpd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       pcpd.unit_of_measure,
       pcpd.strategy_id,
       pcpq.quality_template_id,
       qat.quality_name,
       pcpq.assay_header_id,
       pdm_under.product_id elem_product_id,
       pdm_under.product_desc elem_product_desc,
       pdm_under.base_quantity_unit elem_base_qty_unit_id,
       qum_under.qty_unit elem_qty_unit,
       qum_under.decimals elem_qty_unit_decimal,
       vpci.instrument_id,
       vpci.instrument_name,
       vpci.derivative_def_id,
       vpci.derivative_def_name,
       vpci.exchange_id,
       vpci.exchange_name,
       ucm.multiplication_factor baseqty_conv_rate,
       round(pkg_report_general.fn_get_element_qty(pci.internal_contract_item_ref_no,
                              1,
                              pci.item_qty_unit_id,
                              pcpq.assay_header_id,
                              poch.element_id),10) assay_convertion_rate
  from pcdi_pc_delivery_item          pcdi,
       pci_physical_contract_item     pci,
       pcpq_pc_product_quality        pcpq,
       pcpd_pc_product_definition     pcpd,
       pcm_physical_contract_main     pcm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       pfqpp_phy_formula_qp_pricing   pfqpp,
       pcbph_pc_base_price_header     pcbph,
       pdm_productmaster              pdm,
       qum_quantity_unit_master       qum,
       qat_quality_attributes         qat,
       cpc_corporate_profit_center    cpc,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       qum_quantity_unit_master       qum_under,
       ucm_unit_conversion_master     ucm,
       v_pci_exchange_details         vpci
 where pcdi.pcdi_id = pci.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   and ppfh.ppfh_id = pfqpp.ppfh_id(+)
   and pcm.contract_status = 'In Position'
   and pcm.contract_type <> 'BASEMETAL'
   and pcbpd.price_basis <> 'Fixed'
   and pocd.qp_period_type <> 'Event'
   and pci.item_qty_unit_id = ucm.from_qty_unit_id
   and pdm_under.base_quantity_unit = ucm.to_qty_unit_id
   and pcbpd.element_id = poch.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.poch_id = poch.poch_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and poch.pcbph_id = pcbph.pcbph_id
   and poch.element_id = pcbph.element_id --  = pocd. pcbph.
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = pcbpd.element_id
   and pci.pcpq_id = pcpq.pcpq_id
   and pcpq.pcpd_id = pcpd.pcpd_id
   and pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
      --   and pci.internal_contract_item_ref_no = '163'
   and pci.item_qty > 0
   and pcdi.is_active = 'Y'
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active(+) = 'Y'
   and pcbpd.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and pci.internal_contract_item_ref_no =
       vpci.internal_contract_item_ref_no
   and poch.element_id = vpci.element_id
   and pcpd.product_id = pdm.product_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)*/
union all
select 'GMR Base Metal' section_name,
       gmr.gmr_ref_no contract_ref_no,
       gmr.corporate_id,
       null pcdi_id,
       null internal_contract_ref_no,
       null internal_contract_item_ref_no,
       gmr.purchase_sales contract_type,
       gmr.attribute_id element_id,
       gmr.attribute_name,
       null delivery_item_no,
       null price_unit_id,
       null qp_period_type,
       gmr_exc.qp_start_date price_qp_start_date,
       gmr_exc.qp_end_date price_qp_end_date,
       gmr_exc.qty_to_be_fixed,
       gmr_exc.no_of_prompt_days,
       gmr_exc.per_day_pricing_qty,
       gmr.item_qty_unit_id,
       gmr.product_id,
       gmr.product_name product_desc,
       gmr.product_type_id,
       gmr.item_qty_unit_id base_qty_unit_id,
       gmr.qty_unit base_qty_unit,
       4 base_qty_unit_decimal,
       gmr.profit_center_id,
       gmr.profit_center profit_center_name,
       gmr.profit_center profit_center_short_name,
       gmr.unit_of_measure,
       gmr.strategy strategy_id,
       gmr.quality_id quality_template_id,
       gmr.quality quality_name,
       gmr.assay_header_id,
       gmr.product_id elem_product_id,
       gmr.product_name elem_product_desc,
       gmr.item_qty_unit_id elem_base_qty_unit_id,
       gmr.qty_unit elem_qty_unit,
       4 elem_qty_unit_decimal,
       gmr_exc.instrument_id,
       gmr_exc.instrument_name,
       gmr_exc.derivative_def_id,
       gmr_exc.derivative_def_name,
       gmr_exc.exchange_id,
       gmr_exc.exchange_name,
       gmr.baseqty_conv_rate,
       gmr.assay_convertion_rate
  from v_gmr_stock_details    gmr,
       v_gmr_exchange_details gmr_exc
 where gmr.internal_gmr_ref_no = gmr_exc.internal_gmr_ref_no
   and gmr_exc.element_id is null
/*union all
select 'GMR Concentrate' section_name,
       gmr.gmr_ref_no contract_ref_no,
       gmr.corporate_id,
       null pcdi_id,
       null internal_contract_ref_no,
       null internal_contract_item_ref_no,
       gmr.purchase_sales contract_type,
       gmr.attribute_id element_id,
       gmr.attribute_name,
       null delivery_item_no,
       null price_unit_id,
       null qp_period_type,
       gmr_exc.qp_start_date price_qp_start_date,
       gmr_exc.qp_end_date price_qp_end_date,
       gmr_exc.qty_to_be_fixed,
       gmr_exc.no_of_prompt_days,
       gmr_exc.per_day_pricing_qty,
       gmr.item_qty_unit_id,
       gmr.product_id,
       gmr.product_name product_desc,
       gmr.product_type_id,
       gmr.item_qty_unit_id base_qty_unit_id,
       gmr.qty_unit base_qty_unit,
       4 base_qty_unit_decimal,
       gmr.profit_center_id,
       gmr.profit_center profit_center_name,
       gmr.profit_center profit_center_short_name,
       gmr.unit_of_measure,
       gmr.strategy strategy_id,
       gmr.quality_id quality_template_id,
       gmr.quality quality_name,
       gmr.assay_header_id,
       gmr.product_id elem_product_id,
       gmr.product_name elem_product_desc,
       gmr.item_qty_unit_id elem_base_qty_unit_id,
       gmr.qty_unit elem_qty_unit,
       4 elem_qty_unit_decimal,
       gmr_exc.instrument_id,
       gmr_exc.instrument_name,
       gmr_exc.derivative_def_id,
       gmr_exc.derivative_def_name,
       gmr_exc.exchange_id,
       gmr_exc.exchange_name,
       gmr.baseqty_conv_rate,
       gmr.assay_convertion_rate
  from v_gmr_stock_details    gmr,
       v_gmr_exchange_details gmr_exc
 where gmr.internal_gmr_ref_no = gmr_exc.internal_gmr_ref_no
   and gmr_exc.element_id = gmr_exc.element_id
/

