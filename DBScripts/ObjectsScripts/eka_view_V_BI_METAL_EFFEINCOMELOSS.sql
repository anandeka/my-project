CREATE OR REPLACE VIEW V_BI_METAL_EFFEINCOMELOSS AS
select axs.action_ref_no as pricefixationrefno,
       pfd.pfd_id,
       pcm.corporate_id,
       akc.corporate_name,       
       pcm.contract_ref_no,
       nvl(pdm.product_desc,aml.attribute_name) element_name,
       (case
         when pcm.purchase_sales = 'P' then
          'Buy'
         else
          'Sell'
       end) fixation_type,
       pcdi.delivery_period_type,
       (pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no) di_ref_no,
       (case
         when pcdi.delivery_period_type = 'Date' then
          to_char(pcdi.delivery_to_date, 'Mon-YYYY')
         else
          (pcdi.delivery_to_month || '-' || pcdi.delivery_to_year)
       end) delivery_period,
       to_char(pfd.as_of_date, 'dd-Mon-YYYY') price_fixation_date,
       (to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy')) as qpperiod,
       phd.companyname cp_name,
       pum.price_unit_name,
       ppu.decimals price_decimal,
       pfd.user_price,
       pkg_general.f_get_converted_price(base_cur_tab.corporate_id,
                                         pfd.user_price,
                                         pum.price_unit_id,
                                         base_cur_tab.base_price_unit_id,
                                         sysdate) price_in_base_unit,
       dt.derivative_ref_no internal_trade_ref_no,
       (tad.allocated_qty *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                             tad.allocated_qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1)) allocated_qty,
       qum.qty_unit allocated_qty_unit,
       pfd.qty_fixed *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            pocd.qty_to_be_fixed_unit_id, --pcdi.qty_unit_id, Bug 64031 Fix
                                            pdm.base_quantity_unit,
                                            1) price_fixation_qty,
       qum.qty_unit price_fixation_qty_unit,
       dim.instrument_name exchange_instrument_name,
       dt.trade_type,
       to_char(drm.prompt_date, 'dd-Mon-YYYY') prompt_date,
       dt.trade_price,
       pum_dt.price_unit_name trade_price_unit,
       base_cur_tab.base_price_unit,
       pkg_general.f_get_converted_price --function changed
       (base_cur_tab.corporate_id,
        dt.trade_price,
        dt.trade_price_unit_id,
        base_cur_tab.base_price_unit_id,
        sysdate) trade_price_in_base_price_unit,
       ((pkg_general.f_get_converted_price(base_cur_tab.corporate_id,
                                           dt.trade_price,
                                           dt.trade_price_unit_id,
                                           base_cur_tab.base_price_unit_id,
                                           sysdate) -
       pkg_general.f_get_converted_price(base_cur_tab.corporate_id,
                                           pfd.user_price,
                                           pum.price_unit_id,
                                           base_cur_tab.base_price_unit_id,
                                           sysdate)) * tad.allocated_qty *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                             tad.allocated_qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1)) value_difference
  from pfd_price_fixation_details pfd,
       pfam_price_fix_action_mapping pfam,
       tad_trade_allocation_details tad,
       axs_action_summary axs,
       pofh_price_opt_fixation_header pofh,
       pocd_price_option_calloff_dtls pocd,
       poch_price_opt_call_off_header poch,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       phd_profileheaderdetails phd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       aml_attribute_master_list aml,
       dt_derivative_trade dt,
       drm_derivative_master drm,
       dim_der_instrument_master dim,
       pum_price_unit_master pum_dt,
       qum_quantity_unit_master qum,
       pdm_productmaster pdm,
       (select pum.price_unit_id base_price_unit_id,
               pum.price_unit_name base_price_unit,
               pdm.product_id product_id,
               ppu.cur_id base_cur_id,
               ppu.weight_unit_id weight_unit_id,
               akc.corporate_id
          from v_ppu_pum                ppu,
               pdm_productmaster        pdm,
               ak_corporate             akc,
               qum_quantity_unit_master qum,
               pum_price_unit_master    pum
         where ppu.product_id = pdm.product_id
           and ppu.cur_id = akc.base_cur_id
           and ppu.weight_unit_id = qum.qty_unit_id
           and ppu.price_unit_id = pum.price_unit_id) base_cur_tab,
           ak_corporate      akc
 where tad.price_fixation_id = pfd.pfd_id
   and pfd.pfd_id = pfam.pfd_id
   and pfam.internal_action_ref_no = axs.internal_action_ref_no
   and pfd.pofh_id = pofh.pofh_id
   and pofh.pocd_id = pocd.pocd_id
   and pocd.poch_id = poch.poch_id
   and poch.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.cp_id = phd.profileid
   and pfd.price_unit_id = ppu.internal_price_unit_id
   and ppu.price_unit_id = pum.price_unit_id
   and poch.element_id = aml.attribute_id
   and tad.internal_derivative_ref_no = dt.internal_derivative_ref_no
   and dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and dt.trade_price_unit_id = pum_dt.price_unit_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and aml.underlying_product_id = pdm.product_id(+)
   and pcm.contract_type <> 'BASEMETAL'
   and pcm.corporate_id = base_cur_tab.corporate_id
   and base_cur_tab.product_id = pdm.product_id
   and base_cur_tab.weight_unit_id = qum.qty_unit_id
   and pcm.corporate_id=akc.corporate_id
   and pfd.is_active = 'Y'
   and tad.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pocd.is_active = 'Y'
   and poch.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and phd.is_active = 'Y'
   and ppu.is_active = 'Y'
   and pum.is_active = 'Y'
   and drm.is_deleted = 'N'
   and dim.is_active = 'Y'
union all
--BASEMETAL SECTION
select axs.action_ref_no as pricefixationrefno,
       pfd.pfd_id,
       pcm.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no,
       pdm.product_desc element_name,
       (case
         when pcm.purchase_sales = 'P' then
          'Buy'
         else
          'Sell'
       end) fixation_type,
       pcdi.delivery_period_type,
       (pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no) di_ref_no,
       (case
         when pcdi.delivery_period_type = 'Date' then
          to_char(pcdi.delivery_to_date, 'Mon-YYYY')
         else
          (pcdi.delivery_to_month || '-' || pcdi.delivery_to_year)
       end) delivery_period,
       to_char(pfd.as_of_date, 'dd-Mon-YYYY') price_fixation_date,
       (to_char(pofh.qp_start_date, 'dd-Mon-yyyy') || ' to ' ||
       to_char(pofh.qp_end_date, 'dd-Mon-yyyy')) as qpperiod,
       phd.companyname cp_name,
       pum.price_unit_name,
       ppu.decimals price_decimal,
       pfd.user_price,
       pkg_general.f_get_converted_price(base_cur_tab.corporate_id,
                                         pfd.user_price,
                                         pum.price_unit_id,
                                         base_cur_tab.base_price_unit_id,
                                         sysdate) price_in_base_unit,
       dt.derivative_ref_no internal_trade_ref_no,
       (tad.allocated_qty *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                             tad.allocated_qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1)) allocated_qty,
       qum.qty_unit allocated_qty_unit,
       pfd.qty_fixed *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            pocd.qty_to_be_fixed_unit_id, --pcdi.qty_unit_id, Bug 64031 Fix
                                            pdm.base_quantity_unit,
                                            1) price_fixation_qty,
       qum.qty_unit price_fixation_qty_unit,
       dim.instrument_name exchange_instrument_name,
       dt.trade_type,
       to_char(drm.prompt_date, 'dd-Mon-YYYY') prompt_date,
       dt.trade_price,
       pum_dt.price_unit_name trade_price_unit,
       base_cur_tab.base_price_unit,
       pkg_general.f_get_converted_price --function changed
       (base_cur_tab.corporate_id,
        dt.trade_price,
        dt.trade_price_unit_id,
        base_cur_tab.base_price_unit_id,
        sysdate) trade_price_in_base_price_unit,
       ((pkg_general.f_get_converted_price(base_cur_tab.corporate_id,
                                           dt.trade_price,
                                           dt.trade_price_unit_id,
                                           base_cur_tab.base_price_unit_id,
                                           sysdate) -
       pkg_general.f_get_converted_price(base_cur_tab.corporate_id,
                                           pfd.user_price,
                                           pum.price_unit_id,
                                           base_cur_tab.base_price_unit_id,
                                           sysdate)) * tad.allocated_qty *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                             tad.allocated_qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1)) value_difference
  from pfd_price_fixation_details pfd,
       pfam_price_fix_action_mapping pfam,
       tad_trade_allocation_details tad,
       axs_action_summary axs,
       pofh_price_opt_fixation_header pofh,
       pocd_price_option_calloff_dtls pocd,
       poch_price_opt_call_off_header poch,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       phd_profileheaderdetails phd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       pcpd_pc_product_definition pcpd,
       dt_derivative_trade dt,
       drm_derivative_master drm,
       dim_der_instrument_master dim,
       pum_price_unit_master pum_dt,
       qum_quantity_unit_master qum,
       pdm_productmaster pdm,
       (select pum.price_unit_id base_price_unit_id,
               pum.price_unit_name base_price_unit,
               pdm.product_id product_id,
               ppu.cur_id base_cur_id,
               ppu.weight_unit_id weight_unit_id,
               akc.corporate_id
          from v_ppu_pum                ppu,
               pdm_productmaster        pdm,
               ak_corporate             akc,
               qum_quantity_unit_master qum,
               pum_price_unit_master    pum
         where ppu.product_id = pdm.product_id
           and ppu.cur_id = akc.base_cur_id
           and ppu.weight_unit_id = qum.qty_unit_id
           and ppu.price_unit_id = pum.price_unit_id) base_cur_tab,
           ak_corporate           akc
 where tad.price_fixation_id = pfd.pfd_id
   and pfd.pfd_id = pfam.pfd_id
   and pfam.internal_action_ref_no = axs.internal_action_ref_no
   and pfd.pofh_id = pofh.pofh_id
   and pofh.pocd_id = pocd.pocd_id
   and pocd.poch_id = poch.poch_id
   and poch.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcm.cp_id = phd.profileid
   and pfd.price_unit_id = ppu.internal_price_unit_id
   and ppu.price_unit_id = pum.price_unit_id
   and tad.internal_derivative_ref_no = dt.internal_derivative_ref_no
   and dt.dr_id = drm.dr_id
   and drm.instrument_id = dim.instrument_id
   and dt.trade_price_unit_id = pum_dt.price_unit_id
   and pcpd.product_id = pdm.product_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.input_output = 'Input'
   and pcm.contract_type <> 'CONCENTRATES'
   and pcm.corporate_id = base_cur_tab.corporate_id
   and base_cur_tab.product_id = pdm.product_id
   and base_cur_tab.weight_unit_id = qum.qty_unit_id
   and pcm.corporate_id=akc.corporate_id
   and pfd.is_active = 'Y'
   and tad.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pocd.is_active = 'Y'
   and poch.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and phd.is_active = 'Y'
   and ppu.is_active = 'Y'
   and pum.is_active = 'Y'
   and drm.is_deleted = 'N'
   and dim.is_active = 'Y';
