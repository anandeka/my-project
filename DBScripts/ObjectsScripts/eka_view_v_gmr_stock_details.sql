create or replace view v_gmr_stock_details as
with city_country_mapping as(
select 
    cim.city_id,
    cim.city_name, 
    cym.country_id,
    cym.country_name 
from
    cim_citymaster cim,
    cym_countrymaster cym
where cim.country_id = cym.country_id
and cim.is_active = 'Y'
and cim.is_deleted = 'N')
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
        cim_gmr.country_name
       else
        cim_sld.country_name
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
       sum(nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
           nvl(grd.title_transfer_out_qty, 0)) item_open_qty,
       sum(nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
           nvl(grd.title_transfer_out_qty, 0)) open_qty,
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
                cim_gmr.country_id
                 else
                  cim_sld.country_id
               end) country_id,
       (case when grd.is_afloat = 'Y' then gmr.discharge_city_id else sld.city_id end) city_id,      
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
       1 assay_convertion_rate,
       pci.approval_status
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       sld_storage_location_detail  sld,
       city_country_mapping               cim_sld,
       city_country_mapping               cim_gmr,
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
   and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) > 0
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
                  gmr.discharge_city_id
                 else
                  sld.city_id
               end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
(case
       when grd.is_afloat = 'Y' then
        cim_gmr.country_name
       else
        cim_sld.country_name
      end) ,
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
             cim_gmr.country_id
            else
             cim_sld.country_id
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
          pdtm.product_type_id,
          pci.approval_status
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
          cim_gmr.country_name
         else
          cim_sld.country_name
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
       sum((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
           nvl(grd.title_transfer_out_qty, 0))) item_open_qty,
       sum((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
           nvl(grd.title_transfer_out_qty, 0))) open_qty,
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
        cim_gmr.country_id
         else
          cim_sld.country_id
       end) country_id,
       (case when grd.is_afloat = 'Y' then gmr.discharge_city_id else sld.city_id end) city_id,
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
       1 assay_convertion_rate,
       pci.approval_status
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       sld_storage_location_detail  sld,
       city_country_mapping               cim_sld,
       city_country_mapping               cim_gmr,
--       cym_countrymaster            cym_sld,
--       cym_countrymaster            cym_gmr,
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
--   and cim_sld.country_id = cym_sld.country_id(+)
--   and cim_gmr.country_id = cym_gmr.country_id(+)
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
   and grd.strategy_id = css.strategy_id(+)
   and grd.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.is_internal_movement = 'Y'
   and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) > 0
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
                  gmr.discharge_city_id
                 else
                  sld.city_id
               end),
      (case
         when grd.is_afloat = 'Y' then
          cim_gmr.country_name
         else
          cim_sld.country_name
       end),
        (case
         when grd.is_afloat = 'Y' then
          cim_gmr.city_name 
         else
          cim_sld.city_name
       end),
       (case
         when grd.is_afloat = 'Y' then
        cim_gmr.country_id
         else
          cim_sld.country_id
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
          pdtm.product_type_id,
          pci.approval_status 
union all
select (case
         when dgrd.is_afloat = 'Y' then
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
           when dgrd.is_afloat = 'Y' then
            cim_gmr.country_name
           else
            cim_sld.country_name
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
       pkg_general.f_get_converted_quantity(dgrd.product_id,
                                            dgrd.net_weight_unit_id, --qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       null price_fixation_status,
       sum(nvl(dgrd.net_weight, 0)) total_qty, --sum(nvl(dgrd.qty, 0)) total_qty,
       sum(nvl(dgrd.current_qty, 0)) item_open_qty,
       sum(nvl(dgrd.current_qty, 0)) open_qty,
       0 price_fixed_qty,
       0 unfixed_qty,
       dgrd.net_weight_unit_id item_qty_unit_id, --dgrd.qty_unit_id item_qty_unit_id,
       qum.qty_unit,
       pci.contract_ref_no,
       pci.del_distribution_item_no,
       gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       (case
             when dgrd.is_afloat = 'Y' then
            cim_gmr.country_id
             else
              cim_sld.country_id
           end) country_id,
        (case when dgrd.is_afloat = 'Y' then gmr.discharge_city_id else sld.city_id end) city_id,
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
       pkg_general.f_get_converted_quantity(dgrd.product_id,
                                            dgrd.net_weight_unit_id, --qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) compqty_base_conv_rate,
       qum.qty_unit comp_base_qty_unit,
       pdm.base_quantity_unit comp_base_qty_unit_id,
       1 assay_convertion_rate,
       pci.approval_status
  from dgrd_delivered_grd           dgrd,
       gmr_goods_movement_record    gmr,
       sld_storage_location_detail  sld,
       city_country_mapping               cim_sld,
       city_country_mapping               cim_gmr,
--       cym_countrymaster            cym_sld,
--       cym_countrymaster            cym_gmr,
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
 where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and dgrd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and dgrd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
--   and cim_sld.country_id = cym_sld.country_id(+)
--   and cim_gmr.country_id = cym_gmr.country_id(+)
   and dgrd.quality_id = qat.quality_id
   and gmr.corporate_id = qat.corporate_id
   and qat.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
      --and dgrd.is_deleted = 'N'
   and dgrd.status = 'Active'
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.is_internal_movement = 'N'
   and nvl(dgrd.current_qty, 0) > 0
   and nvl(dgrd.inventory_status, 'NA') <> 'Out'
   and gmr.created_by = gab.gabid(+)
 group by pci.internal_contract_ref_no,
          (case
            when dgrd.is_afloat = 'Y' then
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
                 when dgrd.is_afloat = 'Y' then
                  gmr.discharge_city_id
                 else
                  sld.city_id
               end),    
              (case
           when dgrd.is_afloat = 'Y' then
            cim_gmr.country_name
           else
            cim_sld.country_name
         end) ,
         (case
           when dgrd.is_afloat = 'Y' then
            cim_gmr.city_name 
           else
            cim_sld.city_name
         end) ,
        (case
             when dgrd.is_afloat = 'Y' then
            cim_gmr.country_id
             else
              cim_sld.country_id
           end) ,
          (case
            when nvl(gmr.contract_type, 'NA') = 'Purchase' then
             'P'
            when nvl(gmr.contract_type, 'NA') = 'Sales' then
             'S'
            when nvl(gmr.contract_type, 'NA') = 'B2B' then
             nvl(pci.purchase_sales, 'P')
          end),
          dgrd.product_id,
          dgrd.net_weight_unit_id, --dgrd.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          pci.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,         
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
          pdtm.product_type_id,
          pci.approval_status
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
       vgmr.assay_convertion_rate,
       approval_status
  from v_gmr_concentrate_details vgmr
/
