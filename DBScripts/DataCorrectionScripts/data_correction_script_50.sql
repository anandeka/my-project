create table temp_pfd as
select pfd.pofh_id
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pfam_price_fix_action_mapping pfam,
       axs_action_summary axs,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_aml,
       (select t.pcdi_id,
               t.element_id
          from v_pcdi_exchange_detail t
         group by t.pcdi_id,
                  t.element_id) vped,
       v_ppu_pum ppu,
       cm_currency_master cm,
       qum_quantity_unit_master qum,
       ak_corporate akc,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master qum_qty,
       ucm_unit_conversion_master ucm_price,
       v_ppu_pum ppu_base
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pfd.pfd_id = pfam.pfd_id
   and pfam.internal_action_ref_no = axs.internal_action_ref_no
   and poch.element_id = aml.attribute_id
   and vped.pcdi_id = pcdi.pcdi_id
   and vped.element_id = aml.attribute_id(+)
   and aml.underlying_product_id = pdm_aml.product_id
   and pfd.price_unit_id = ppu.product_price_unit_id
   and ppu.cur_id = cm.cur_id
   and ppu.weight_unit_id = qum.qty_unit_id
   and akc.corporate_id = pcm.corporate_id
   and ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and ucm.to_qty_unit_id = pdm_aml.base_quantity_unit
   and pdm_aml.base_quantity_unit = qum_qty.qty_unit_id
   and pcm.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and pfam.is_active = 'Y'
   and pfd.is_active = 'N'
   and pcm.contract_type = 'CONCENTRATES' 
   and pfd.cancel_action_ref_no is not null
   --   and pfd.hedge_correction_date > vd_prev_eom_date    
   -- and pfd.hedge_correction_date <= pd_trade_date    
   --     and pcm.is_pass_through = 'N'    
   and ucm_price.from_qty_unit_id = pdm_aml.base_quantity_unit    
   and ucm_price.to_qty_unit_id = ppu.weight_unit_id   
    and ucm_price.is_active = 'Y'    
    and ppu_base.product_id = pdm_aml.product_id    
    and ppu_base.cur_id = akc.base_cur_id    
    and ppu_base.weight_unit_id = pdm_aml.base_quantity_unit    
    and pocd.price_type <> 'Fixed'    
    and pfd.is_exposure = 'Y'    
    and pcm.internal_contract_ref_no 
    not in        (select tt.int_contract_ref_no           
    from pcmte_pcm_tolling_ext tt          where tt.is_pass_through = 'Y') 
    and axs.action_ref_no not like '%CANCEL%'
    group by pfd.pofh_id;

UPDATE PFD_PRICE_FIXATION_DETAILS PFD
SET PFD.IS_EXPOSURE='Y'
where pfd.is_hedge_correction='N'
and pfd.pofh_id In (select pofh_id from temp_pfd);

drop table temp_pfd;

