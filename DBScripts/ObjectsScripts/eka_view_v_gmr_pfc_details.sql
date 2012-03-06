create or replace view v_gmr_pfc_details as
--common with query for GMR/Elemnt/Deliveryitem infixed qty
with pfc_pofh_data as(select pofh.internal_gmr_ref_no,
       pofh.pocd_id,
       poch.pcdi_id,
       poch.element_id,
       (pofh.qty_to_be_fixed) qty_to_be_fixed,
       pofh.no_of_prompt_days,
       pofh.per_day_pricing_qty,
       round(nvl(pofh.priced_qty, 0), 5) priced_qty,
       round((pofh.qty_to_be_fixed) - round(nvl((pofh.priced_qty), 0), 5),
             5) unpriced_qty,
       pofh.qp_start_date,
       pofh.qp_end_date,
       pocd.qty_to_be_fixed_unit_id qty_fixation_unit_id
  from pofh_price_opt_fixation_header pofh,
       pocd_price_option_calloff_dtls pocd,
       poch_price_opt_call_off_header poch
 where pofh.is_active = 'Y'
   and pofh.internal_gmr_ref_no is not null
   and pofh.pocd_id = pocd.pocd_id
   and pocd.poch_id = poch.poch_id)
-- Base Metal - Purchase GMR   
select pci.product_group_type,
       gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       pci.pcdi_id,
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
       v_gmr.exchange_name,
       pci.incoterm,
       null attribute_id,
       null attribute_name
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       v_gmr_exchange_details       v_gmr,
       pfc_pofh_data                gmr_pfc,
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
       qat_quality_attributes       qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and gmr.internal_gmr_ref_no = gmr_pfc.internal_gmr_ref_no
   and pci.pcdi_id = gmr_pfc.pcdi_id
   and gmr_pfc.element_id is null
   and pci.product_group_type = 'BASEMETAL'
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and upper(nvl(grd.inventory_status, 'NA')) in ('NA', 'IN')
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.internal_gmr_ref_no = v_gmr.internal_gmr_ref_no
   and pci.pcdi_id = v_gmr.pcdi_id
-- and gmr.contract_type = 'Purchase'
 group by pci.product_group_type,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          pci.pcdi_id,
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
          v_gmr.exchange_name,
          pci.incoterm
union all
--Base metal - Sales GMR
select pci.product_group_type,
       gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       pci.pcdi_id,
       nvl(blm.business_line_name, 'NA') business_line,
       gmr.corporate_id,
       nvl(cpc.profit_center_short_name, 'NA') profit_center,
       nvl(css.strategy_name, 'NA') strategy,
       pdm.product_desc product_name,
       qat.quality_name quality,
       (case
         when dgrd.is_afloat = 'Y' then
          cym_gmr.country_name
         else
          cym_sld.country_name
       end) country_name,
       (case
         when dgrd.is_afloat = 'Y' then
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
       pkg_general.f_get_converted_quantity(dgrd.product_id,
                                            gmr.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       -- sum(nvl(dgrd.qty, 0)) total_qty,
       sum(nvl(dgrd.net_weight, 0)) total_qty,
       sum(nvl(dgrd.current_qty, 0)) open_qty,
       --dgrd.qty_unit_id item_qty_unit_id,
       dgrd.net_weight_unit_id item_qty_unit_id,
       qum.qty_unit,
       (case
         when dgrd.is_afloat = 'Y' then
          cym_gmr.country_id
         else
          cym_sld.country_id
       end) country_id,
       (case
         when dgrd.is_afloat = 'Y' then
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
       v_gmr.exchange_name,
       pci.incoterm,
       null attribute_id,
       null attribute_name
  from dgrd_delivered_grd           dgrd,
       gmr_goods_movement_record    gmr,
       v_gmr_exchange_details       v_gmr,
       pfc_pofh_data                gmr_pfc,
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
       qat_quality_attributes       qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc
 where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and dgrd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and gmr.internal_gmr_ref_no = gmr_pfc.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = gmr_pfc.internal_gmr_ref_no
   and pci.pcdi_id = gmr_pfc.pcdi_id
   and gmr_pfc.element_id is null
   and dgrd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and dgrd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and pci.product_group_type = 'BASEMETAL'
      --and dgrd.is_deleted = 'N'
   and dgrd.status = 'Active'
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.internal_gmr_ref_no = v_gmr.internal_gmr_ref_no
   and pci.pcdi_id = v_gmr.pcdi_id
--  and gmr.contract_type = 'Sales'
-- and upper(nvl(dgrd.inventory_status, 'NA')) in ('NA', 'NONE')
 group by pci.product_group_type,
          pci.pcdi_id,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          nvl(blm.business_line_name, 'NA'),
          gmr.corporate_id,
          nvl(cpc.profit_center_short_name, 'NA'),
          nvl(css.strategy_name, 'NA'),
          gmr.qty_unit_id,
          pdm.product_desc,
          qat.quality_name,
          (case
            when dgrd.is_afloat = 'Y' then
             cym_gmr.country_name
            else
             cym_sld.country_name
          end),
          (case
            when dgrd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
          gmr.contract_type,
          pci.purchase_sales,
          dgrd.product_id,
          pdm.base_quantity_unit,
          dgrd.net_weight_unit_id,
          qum.qty_unit,
          (case
            when dgrd.is_afloat = 'Y' then
             cym_gmr.country_id
            else
             cym_sld.country_id
          end),
          (case
            when dgrd.is_afloat = 'Y' then
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
          v_gmr.exchange_name,
          pci.incoterm
union all
----------
--concentrates          
----------
-- concentrate - Purchase GMR   
select pci.product_group_type,
       gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       pci.pcdi_id,
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
       pkg_general.f_get_converted_quantity(aml.underlying_product_id,
                                            gmr_pfc.qty_fixation_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       sum(nvl(grd.qty, 0)) total_qty,
       sum(nvl(grd.current_qty, 0)) open_qty,
       gmr_pfc.qty_fixation_unit_id item_qty_unit_id,
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
       v_gmr.exchange_name,
       pci.incoterm,
       aml.attribute_id,
       aml.attribute_name
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       v_gmr_exchange_details       v_gmr,
       pfc_pofh_data                gmr_pfc,
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
       qat_quality_attributes       qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       aml_attribute_master_list    aml
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pci.product_group_type = 'CONCENTRATES'
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and upper(nvl(grd.inventory_status, 'NA')) in ('NA', 'IN')
   and nvl(grd.tolling_stock_type,'NA') in('None Tolling','NA')
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.internal_gmr_ref_no = v_gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = gmr_pfc.internal_gmr_ref_no
   and pci.pcdi_id = v_gmr.pcdi_id
   and pci.pcdi_id = gmr_pfc.pcdi_id
   and gmr_pfc.element_id is not null
   and gmr_pfc.element_id = v_gmr.element_id 
   and gmr_pfc.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id   
-- and gmr.contract_type = 'Purchase'
 group by pci.product_group_type,grd.tolling_stock_type,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          pci.pcdi_id,
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
          pdm.base_quantity_unit,
          aml.underlying_product_id,gmr_pfc.qty_fixation_unit_id,
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
          v_gmr.exchange_name,
          pci.incoterm,
       aml.attribute_id,
       aml.attribute_name
union all
--concentrates- Sales GMR
select pci.product_group_type,
       gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       pci.pcdi_id,
       nvl(blm.business_line_name, 'NA') business_line,
       gmr.corporate_id,
       nvl(cpc.profit_center_short_name, 'NA') profit_center,
       nvl(css.strategy_name, 'NA') strategy,
       pdm.product_desc product_name,
       qat.quality_name quality,
       (case
         when dgrd.is_afloat = 'Y' then
          cym_gmr.country_name
         else
          cym_sld.country_name
       end) country_name,
       (case
         when dgrd.is_afloat = 'Y' then
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
       pkg_general.f_get_converted_quantity(aml.underlying_product_id,
                                            gmr_pfc.qty_fixation_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       -- sum(nvl(dgrd.qty, 0)) total_qty,
       sum(nvl(dgrd.net_weight, 0)) total_qty,
       sum(nvl(dgrd.current_qty, 0)) open_qty,
       --dgrd.qty_unit_id item_qty_unit_id,
       gmr_pfc.qty_fixation_unit_id item_qty_unit_id,
       qum.qty_unit,
       (case
         when dgrd.is_afloat = 'Y' then
          cym_gmr.country_id
         else
          cym_sld.country_id
       end) country_id,
       (case
         when dgrd.is_afloat = 'Y' then
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
       v_gmr.exchange_name,
       pci.incoterm,
       aml.attribute_id,
       aml.attribute_name
  from dgrd_delivered_grd           dgrd,
       gmr_goods_movement_record    gmr,
       v_gmr_exchange_details       v_gmr,
       pfc_pofh_data                gmr_pfc,
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
       qat_quality_attributes       qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       aml_attribute_master_list    aml
 where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
 --  and dgrd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and gmr.internal_gmr_ref_no = gmr_pfc.internal_gmr_ref_no
   and pci.pcdi_id = gmr_pfc.pcdi_id
   and gmr_pfc.element_id is not null
   and gmr_pfc.element_id = v_gmr.element_id
   and dgrd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and dgrd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and pci.product_group_type <> 'BASEMETAL'
      --and dgrd.is_deleted = 'N'
   and dgrd.status = 'Active'
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.internal_gmr_ref_no = v_gmr.internal_gmr_ref_no
   and pci.pcdi_id = v_gmr.pcdi_id
   and gmr_pfc.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id   
--  and gmr.contract_type = 'Sales'
-- and upper(nvl(dgrd.inventory_status, 'NA')) in ('NA', 'NONE')
 group by pci.product_group_type,
          pci.pcdi_id,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          nvl(blm.business_line_name, 'NA'),
          gmr.corporate_id,
          nvl(cpc.profit_center_short_name, 'NA'),
          nvl(css.strategy_name, 'NA'),
          gmr.qty_unit_id,aml.underlying_product_id,gmr_pfc.qty_fixation_unit_id,
          pdm.product_desc,
          qat.quality_name,
          (case
            when dgrd.is_afloat = 'Y' then
             cym_gmr.country_name
            else
             cym_sld.country_name
          end),
          (case
            when dgrd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
          gmr.contract_type,
          pci.purchase_sales,
          dgrd.product_id,
          pdm.base_quantity_unit,
          dgrd.net_weight_unit_id,
          qum.qty_unit,
          (case
            when dgrd.is_afloat = 'Y' then
             cym_gmr.country_id
            else
             cym_sld.country_id
          end),
          (case
            when dgrd.is_afloat = 'Y' then
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
          v_gmr.exchange_name,
          pci.incoterm,
       aml.attribute_id,
       aml.attribute_name
