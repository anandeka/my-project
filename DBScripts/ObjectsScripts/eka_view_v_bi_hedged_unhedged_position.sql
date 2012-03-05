create or replace view v_bi_hedged_unhedged_position as
select 'Price Fixations' section_type,
       akc.corporate_id,
       akc.corporate_name,
       aml.attribute_id element_id,
       aml.attribute_name element_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       pcm.internal_contract_ref_no,
       pcm.contract_ref_no derivative_ref_no,
       pfd.qty_fixed fixation_qty,
       (nvl(pfd.qty_fixed, 0) - nvl(tad.allocated_qty, 0))*
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            tad.allocated_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) un_allocated_qty,
       nvl(tad.allocated_qty,0)*
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            tad.allocated_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) allocated_qty,
       qum.qty_unit_id,
       qum.qty_unit allocated_qty_unit,
       '' instrument_name,
       pcm.purchase_sales trade_type,
       to_char(pfd.as_of_date, 'dd-Mon-yyyy') prompt_date,
        nvl(pdm.product_id,pdm_under.product_id) product_id,
       nvl(pdm.product_desc,pdm_under.product_desc) product_desc,
       css.strategy_id,
       css.strategy_name,
       '' prompt_month
from
       pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details     pfd,
       tad_trade_allocation_details   tad,
       qum_quantity_unit_master       qum,
       ak_corporate                   akc,
       pcpd_pc_product_definition     pcpd,
       cpc_corporate_profit_center    cpc,
       pdm_productmaster              pdm,
       css_corporate_strategy_setup   css,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under
 where  pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and poch.pcdi_id = pcdi.pcdi_id
   and poch.poch_id = pocd.poch_id(+)
   and pocd.pocd_id = pofh.pocd_id(+)
   and pofh.pofh_id = pfd.pofh_id(+)
   and pfd.pfd_id = tad.price_fixation_id(+)
   and tad.allocated_qty_unit_id = qum.qty_unit_id(+)
   and pcm.corporate_id = akc.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id(+)
   and pcpd.strategy_id = css.strategy_id
   and poch.element_id = aml.attribute_id(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pfd.qty_fixed <> nvl(tad.allocated_qty, 0)
   and pofh.is_active = 'Y'
   and pocd.is_active = 'Y'
union all
select
       'Derivative' section_type,
       akc.corporate_id,
       akc.corporate_name,
       null element_id,
       null element_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       null internal_contract_ref_no,
       dt_int.derivative_ref_no,
       dt_int.total_quantity fixation_qty,
       dt_int.total_quantity -
       (nvl(tad_int.allocated_qty, 0) + nvl(tad.allocated_qty, 0)) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            tad.allocated_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) un_allocated_qty,
      (nvl(tad_int.allocated_qty, 0) + nvl(tad.allocated_qty, 0)) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            tad.allocated_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) allocated_qty,
       qum.qty_unit_id,
       qum.qty_unit,
       dim.instrument_name,
       dt_int.trade_type,
       to_char(drm.prompt_date, 'dd-Mon-YYYY') prompt_date,
       pdm.product_id,
       pdm.product_desc,
       css.strategy_id,
       css.strategy_name,
       to_char(drm.prompt_date, 'Mon-YYYY') prompt_month

  from dt_derivative_trade          dt_int,
       dt_derivative_trade          dt,
       ak_corporate                 akc,
       cpc_corporate_profit_center  cpc,
       tad_trade_allocation_details tad,
       tad_trade_allocation_details tad_int,
       drm_derivative_master        drm,
       dim_der_instrument_master    dim,
       pdm_productmaster            pdm,
       css_corporate_strategy_setup css,
       qum_quantity_unit_master     qum
 where dt_int.internal_derivative_ref_no =
       tad_int.internal_derivative_ref_no(+)
   and dt.corporate_id = akc.corporate_id
   and dt.profit_center_id = cpc.profit_center_id
   and dt_int.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and dt.product_id = pdm.product_id
   and dt_int.is_internal_trade = 'Y'
   and dt_int.int_trade_parent_der_ref_no =
       dt.internal_derivative_ref_no(+)
   and dt.internal_derivative_ref_no = tad.internal_derivative_ref_no
   and dt_int.total_quantity <>
       (nvl(tad_int.allocated_qty, 0) + nvl(tad.allocated_qty, 0))
   and dt.strategy_id = css.strategy_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and dt_int.status = 'Verified'
   and dt.status = 'Verified'
   and tad.is_active = 'Y'
   and tad_int.is_active = 'Y'
   and drm.is_deleted = 'N'
   and dim.is_active = 'Y'

union all
select
       'Derivative' section_type,
       akc.corporate_id,
       akc.corporate_name,
       null element_id,
       null element_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       null internal_contract_ref_no,
       dt.derivative_ref_no,
       dt.total_quantity,
       dt.total_quantity -
       nvl(tad.allocated_qty, 0) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            tad.allocated_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) un_allocated_qty,
       nvl(tad.allocated_qty, 0) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            tad.allocated_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) allocated_qty,
       qum.qty_unit_id,
       qum.qty_unit,
       dim.instrument_name,
       dt.trade_type,
       to_char(drm.prompt_date, 'dd-Mon-YYYY') prompt_date,
       pdm.product_id,
       pdm.product_desc,
       css.strategy_id,
       css.strategy_name,
       to_char(drm.prompt_date, 'Mon-YYYY') prompt_month

  from dt_derivative_trade          dt,
       tad_trade_allocation_details tad,
       ak_corporate                 akc,
       cpc_corporate_profit_center  cpc,
       drm_derivative_master        drm,
       dim_der_instrument_master    dim,
       pdm_productmaster            pdm,
       css_corporate_strategy_setup css,
       qum_quantity_unit_master     qum
 where dt.internal_derivative_ref_no = tad.internal_derivative_ref_no(+)
   and dt.corporate_id = akc.corporate_id
   and dt.profit_center_id = cpc.profit_center_id
   and dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and dt.product_id = pdm.product_id
   and dt.is_internal_trade is null
   and dt.internal_derivative_ref_no not in
       (select dt_in.int_trade_parent_der_ref_no
          from dt_derivative_trade dt_in
         where dt_in.is_internal_trade = 'Y'
           and dt_in.status = 'Verified')
   and dt.strategy_id = css.strategy_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and dt.total_quantity <> nvl(tad.allocated_qty, 0)
   and dt.status = 'Verified'
   and drm.is_deleted = 'N'
   and dim.is_active = 'Y'

