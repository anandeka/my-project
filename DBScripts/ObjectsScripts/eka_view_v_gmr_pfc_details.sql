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
       v_gmr.exchange_name,
       pci.incoterm
  from grd_goods_record_detail grd,
       gmr_goods_movement_record gmr,
       v_gmr_exchange_details v_gmr,
       (select pofh.internal_gmr_ref_no,
               sum(pofh.qty_to_be_fixed) qty_to_be_fixed,
               pofh.no_of_prompt_days,
               pofh.per_day_pricing_qty,
               round(nvl(pofh.priced_qty, 0), 5) priced_qty,
               round(sum(pofh.qty_to_be_fixed) -
                     round(nvl(sum(pofh.priced_qty), 0), 5),
                     5) unpriced_qty,
               pofh.qp_start_date,
               pofh.qp_end_date
          from pofh_price_opt_fixation_header pofh
         where pofh.is_active = 'Y'
           and pofh.internal_gmr_ref_no is not null
           group by pofh.internal_gmr_ref_no,
                    pofh.qty_to_be_fixed,
                    pofh.no_of_prompt_days,
                    pofh.per_day_pricing_qty,
                    pofh.priced_qty,
                    pofh.qp_start_date,
                    pofh.qp_end_date) gmr_pfc,
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
          v_gmr.exchange_name,
          pci.incoterm
/