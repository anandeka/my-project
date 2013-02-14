create or replace view v_bi_apf_not_applied_shipment as
select pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.cp_id,
       phd.companyname cpname,
       pcpd.product_id,
       pdm.product_desc product,
       --pcdi.pcdi_id, --Bug 64413
       pcm.contract_ref_no||'-'||pcdi.delivery_item_no pcdi_id,
       pcpq.quality_template_id,
       qat.quality_name,
       diqs.total_qty delivery_item_qty,
       diqs.item_qty_unit_id delivery_item_qty_unit_id,
       diqs_qum.qty_unit delivery_item_qty_unit,
       diqs.gmr_qty arrived_qty,
       dipq.element_id,
       aml.attribute_name element_name,
       dipq.payable_qty,
       dipq.qty_unit_id payable_qty_unit_id,
       dipq_qum.qty_unit payable_qty_unit,
       pcbph.price_description,
       pofh.qp_start_date || ' to ' || pofh.qp_end_date qpperiod,
       pofh.pofh_id,
       axs.action_ref_no price_fixation_no,
       pfd.qty_fixed price_fixed_qty,
       pfd.as_of_date price_fixation_date,
       nvl(pfd.user_price, 0) user_price,
       pfd.price_unit_id,
       ppu.price_unit_name,
       nvl(gpad.allocated_qty, 0) quantity_applied_gmr,
       (pfd.qty_fixed - nvl(gpad.allocated_qty, 0)) quantity_not_applied_gmr,
       sum(pfd.qty_fixed) over(partition by dipq.element_id order by dipq.element_id) total_price_fixed_qty,
       sum(pfd.qty_fixed - nvl(gpad.allocated_qty, 0)) over(partition by dipq.element_id order by dipq.element_id) qty_not_applied_for_shipment,
       nvl((sum(pfd.qty_fixed * pfd.user_price)
            over(partition by dipq.element_id order by dipq.element_id) /
            sum(pfd.qty_fixed)
            over(partition by dipq.element_id order by dipq.element_id)),
           0) weighted_avg_price
  from pcm_physical_contract_main pcm,
       pcmte_pcm_tolling_ext pcmte,
       phd_profileheaderdetails phd,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       pcpq_pc_product_quality pcpq,
       qat_quality_attributes qat,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       qum_quantity_unit_master diqs_qum,
       dipq_delivery_item_payable_qty dipq,
       qum_quantity_unit_master dipq_qum,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pfam_price_fix_action_mapping pfam,
       axs_action_summary axs,
       (select gpad.pfd_id,
               sum(gpad.allocated_qty) allocated_qty
          from gpad_gmr_price_alloc_dtls gpad
         where gpad.is_active = 'Y'
         group by gpad.pfd_id) gpad,
       v_ppu_pum ppu,
       aml_attribute_master_list aml
 where pcm.cp_id = phd.profileid
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pfd.pfd_id = pfam.pfd_id
   and pfam.internal_action_ref_no = axs.internal_action_ref_no
   and pcpq.quality_template_id = qat.quality_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = diqs_qum.qty_unit_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and dipq.qty_unit_id = dipq_qum.qty_unit_id
   and dipq.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and dipq.element_id = poch.element_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and poch.element_id = pcbph.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pfd.pfd_id = gpad.pfd_id(+)
   and pfd.price_unit_id = ppu.product_price_unit_id
   and dipq.element_id = aml.attribute_id
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcpq.is_active = 'Y'
   and pcpd.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pfd.is_active = 'Y'
   and diqs.is_active = 'Y'
   and dipq.is_active = 'Y'
   and pcm.purchase_sales = 'P'
   and pcdi.price_allocation_method = 'Price Allocation'
   and pfd.is_exposure='Y'
   and pocd.is_any_day_pricing = 'Y';