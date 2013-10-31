CREATE OR REPLACE VIEW V_BI_HEDGED_UNHEDGED_POSITION AS
with tad_data as(select t.internal_derivative_ref_no,
       sum(t.allocated_qty) allocated_qty,
       t.allocated_qty_unit_id
  from tad_trade_allocation_details t
 where t.is_active = 'Y'
 group by t.internal_derivative_ref_no, t.allocated_qty_unit_id)
select 'Price Fixations' section_type,
       akc.corporate_id,
       akc.corporate_name,
       aml.attribute_id element_id,
       aml.attribute_name element_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       pcm.internal_contract_ref_no,
       axs.action_ref_no derivative_ref_no,
      round(pfd.qty_fixed * ucm.multiplication_factor,5)  fixation_qty,
      round( (nvl(pfd.qty_fixed, 0) * ucm.multiplication_factor )  -
      (NVL(tad.allocated_qty, 0) * pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    nvl(tad.allocated_qty_unit_id,
                                                        pdm.base_quantity_unit),
                                                    pocd.Qty_To_Be_Fixed_Unit_Id,
                                                    1) * ucm.multiplication_factor                                                    
                                                    ),5)  un_allocated_qty,
     round( nvl(tad.allocated_qty, 0) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pocd.Qty_To_Be_Fixed_Unit_Id,
                                            1) * ucm.multiplication_factor,5) allocated_qty,
       qum_ucm.qty_unit_id,
       qum_ucm.qty_unit allocated_qty_unit,
       '' instrument_name,
       pcm.purchase_sales trade_type,
       to_char(pfd.as_of_date, 'dd-Mon-yyyy') prompt_date,
       nvl(pdm.product_id, pdm_under.product_id) product_id,
       nvl(pdm.product_desc, pdm_under.product_desc) product_desc,
       css.strategy_id,
       css.strategy_name,
       to_char(pfd.as_of_date, 'Mon-yyyy') prompt_month
  FROM pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details     pfd,
       pfam_price_fix_action_mapping  pfam,
       axs_action_summary             axs,
       (select t.price_fixation_id,
                 sum(t.allocated_qty) allocated_qty,
                 t.allocated_qty_unit_id
            from tad_trade_allocation_details t
           where t.is_active = 'Y'
           group by t.price_fixation_id, t.allocated_qty_unit_id)   tad,
       ak_corporate                   akc,
       pcpd_pc_product_definition     pcpd,
       cpc_corporate_profit_center    cpc,
       pdm_productmaster              pdm,
       css_corporate_strategy_setup   css,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master qum_ucm,
       qum_quantity_unit_master       qum_qty_unit
 WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   AND poch.pcdi_id = pcdi.pcdi_id
   AND poch.poch_id = pocd.poch_id(+)
   AND pocd.pocd_id = pofh.pocd_id(+)
   AND pofh.pofh_id = pfd.pofh_id(+)
   and pfd.pfd_id = pfam.pfd_id(+)
   and pfam.internal_action_ref_no = axs.internal_action_ref_no(+)
   AND pfd.pfd_id = tad.price_fixation_id(+)
   AND pcm.corporate_id = akc.corporate_id
   AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   AND pcpd.profit_center_id = cpc.profit_center_id
   AND pcpd.product_id = pdm.product_id(+)
   AND pcpd.strategy_id = css.strategy_id
   AND poch.element_id = aml.attribute_id(+)
   AND aml.underlying_product_id = pdm_under.product_id(+)
   AND pocd.Qty_To_Be_Fixed_Unit_Id = qum_qty_unit.qty_unit_id
   and pocd.qty_to_be_fixed_unit_id = ucm.from_qty_unit_id
   and pdm_under.base_quantity_unit = ucm.to_qty_unit_id
   and ucm.to_qty_unit_id = qum_ucm.qty_unit_id
   AND pfd.qty_fixed - nvl(tad.allocated_qty, 0)<>0
   and pcpd.input_output = 'Input' 
   AND pofh.is_active = 'Y'
   AND pocd.is_active = 'Y'   
UNION ALL
select 'Derivative' section_type,
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
       (nvl(tad_int.allocated_qty, 0) + NVL(tad.allocated_qty, 0)) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pdm.base_quantity_unit,
                                            1) un_allocated_qty,
       (nvl(tad_int.allocated_qty, 0) + NVL(tad.allocated_qty, 0)) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
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
  FROM dt_derivative_trade          dt_int,
       dt_derivative_trade          dt,
       ak_corporate                 akc,
       cpc_corporate_profit_center  cpc,
       tad_data                      tad,
       tad_data                       tad_int,
       drm_derivative_master        drm,
       dim_der_instrument_master    dim,
       pdm_productmaster            pdm,
       css_corporate_strategy_setup css,
       qum_quantity_unit_master     qum
 WHERE dt_int.internal_derivative_ref_no =
       tad_int.internal_derivative_ref_no(+)
   AND dt.corporate_id = akc.corporate_id
   AND dt.profit_center_id = cpc.profit_center_id
   AND dt_int.dr_id = drm.dr_id
   AND drm.instrument_id = dim.instrument_id
   AND dt.product_id = pdm.product_id
   AND dt_int.is_internal_trade = 'Y'
   AND dt_int.int_trade_parent_der_ref_no =
       dt.internal_derivative_ref_no(+)
   AND dt.internal_derivative_ref_no = tad.internal_derivative_ref_no
   AND dt_int.total_quantity <>
       (NVL(tad_int.allocated_qty, 0) + NVL(tad.allocated_qty, 0))
   AND dt.strategy_id = css.strategy_id
   AND pdm.base_quantity_unit = qum.qty_unit_id
   AND dt_int.status = 'Verified'
   AND dt.status = 'Verified'
   AND drm.is_deleted = 'N'
   AND dim.is_active = 'Y'
UNION ALL
SELECT 'Derivative' section_type,
       akc.corporate_id,
       akc.corporate_name,
       NULL element_id,
       NULL element_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       NULL internal_contract_ref_no,
       dt.derivative_ref_no,
       dt.total_quantity,
       dt.total_quantity -
       NVL(tad.allocated_qty, 0) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pdm.base_quantity_unit,
                                            1) un_allocated_qty,
       NVL(tad.allocated_qty, 0) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pdm.base_quantity_unit,
                                            1) allocated_qty,
       qum.qty_unit_id,
       qum.qty_unit,
       dim.instrument_name,
       dt.trade_type,
       TO_CHAR(drm.prompt_date, 'dd-Mon-YYYY') prompt_date,
       pdm.product_id,
       pdm.product_desc,
       css.strategy_id,
       css.strategy_name,
       TO_CHAR(drm.prompt_date, 'Mon-YYYY') prompt_month
  FROM dt_derivative_trade          dt,
       tad_data tad,
       ak_corporate                 akc,
       cpc_corporate_profit_center  cpc,
       drm_derivative_master        drm,
       dim_der_instrument_master    dim,
       pdm_productmaster            pdm,
       css_corporate_strategy_setup css,
       qum_quantity_unit_master     qum
 WHERE dt.internal_derivative_ref_no = tad.internal_derivative_ref_no(+)
   AND dt.corporate_id = akc.corporate_id
   AND dt.profit_center_id = cpc.profit_center_id
   AND dt.dr_id = drm.dr_id
   AND drm.instrument_id = dim.instrument_id
   AND dt.product_id = pdm.product_id
   AND dt.is_internal_trade IS NULL
   AND dt.internal_derivative_ref_no NOT IN
       (SELECT dt_in.internal_derivative_ref_no
          FROM dt_derivative_trade dt_in
         WHERE dt_in.is_internal_trade = 'Y'
           AND dt_in.status = 'Verified')
   AND dt.strategy_id = css.strategy_id
   AND pdm.base_quantity_unit = qum.qty_unit_id
   AND dt.total_quantity <> NVL(tad.allocated_qty, 0)
   AND dt.status = 'Verified'
/