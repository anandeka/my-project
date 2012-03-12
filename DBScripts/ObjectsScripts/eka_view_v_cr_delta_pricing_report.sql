create or replace view v_cr_delta_pricing_report as
select 'Event Based Pricing based on Shipment' section_name,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       pcdi.pcdi_id,
       pofh.pofh_id,
       pocd.pocd_id,
       aml.attribute_id,
       aml.attribute_name,
       pcm.cp_id cp_id,
       phd.companyname cp_name,
       pcpd.product_id,
       pdm.product_desc product,
       pcpq.quality_template_id quality_id,
       qat.quality_name,
       sac.total_qty_in_wet gmr_wet_qty,
       sac.total_qty_in_dry gmr_dry_qty,
       0 di_qty,
       null qty_basis,
       qum.qty_unit_id,
       qum.qty_unit gmr_qty_unit,
       pofh.qp_start_date,
       pofh.qp_end_date,
       round(nvl(pofh.priced_qty, 0), 5) priced_qty,
       round(nvl(pofh.qty_to_be_fixed, 0), 5) total_payable_qty,
       round(nvl(pofh.qty_to_be_fixed, 0), 5) -
       round(nvl(pofh.priced_qty, 0), 5) over_under_priced_qty,
       pocd.qty_to_be_fixed_unit_id priced_qty_unit_id,
       qum_aml.qty_unit priced_qty_unit,
       pocd.is_any_day_pricing
  from pofh_price_opt_fixation_header pofh,
       pcm_physical_contract_main     pcm,
       ak_corporate                   akc,
       pcdi_pc_delivery_item          pcdi,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       v_gmr_sac_qty                  sac,
       v_gmr_assay_finalized_status   v_gmr,
       gmr_goods_movement_record      gmr,
       qum_quantity_unit_master       qum,
       phd_profileheaderdetails       phd,
       aml_attribute_master_list      aml,
       dipch_di_payablecontent_header dipch,
       pcpch_pc_payble_content_header pcpch,
       pcpd_pc_product_definition     pcpd,
       pcpq_pc_product_quality        pcpq,
       pdm_productmaster              pdm,
       qat_quality_attributes         qat,
       qum_quantity_unit_master       qum_aml
 where pofh.pocd_id = pocd.pocd_id
   and pocd.poch_id = poch.poch_id
   and poch.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pofh.internal_gmr_ref_no = sac.internal_gmr_ref_no
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pofh.final_price is null
   and sac.grd_qty_unit_id = qum.qty_unit_id
   and pocd.qty_to_be_fixed_unit_id = qum_aml.qty_unit_id
   and gmr.internal_gmr_ref_no = v_gmr.internal_gmr_ref_no
   and pcm.cp_id = phd.profileid
   and poch.element_id = aml.attribute_id
   and pcdi.pcdi_id = dipch.pcdi_id
   and dipch.is_active = 'Y'
   and dipch.pcpch_id = pcpch.pcpch_id
   and pcpch.element_id = poch.element_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.quality_id
   and nvl(pcpch.payable_type, 'Payable') = 'Payable'
   and pofh.internal_gmr_ref_no is not null
   and pofh.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pocd.qp_period_type = 'Event'
   and phd.is_active = 'Y'
   and phd.is_deleted = 'N'
   and v_gmr.assay_finalized = 'Y'
union all
select 'Pricing based Pre-defined QP' section_name,
       akc.corporate_id,
       akc.corporate_name,
       pcm.contract_ref_no,
       pcm.contract_ref_no || '-' || pcdi.delivery_item_no contract_item_ref_no,
       null internal_gmr_ref_no,
       null gmr_ref_no,
       pcdi.pcdi_id,
       pofh.pofh_id,
       pocd.pocd_id,
       aml.attribute_id,
       aml.attribute_name,
       pcm.cp_id cp_id,
       phd.companyname cp_name,
       pcpd.product_id,
       pdm.product_desc product,
       pcpq.quality_template_id quality_id,
       qat.quality_name,
       0 gmr_wet_qty,
       0 gmr_dry_qty,
       diqs.total_qty di_qty,
       nvl(pcpq.unit_of_measure,'Dry') qty_basis,
       qum.qty_unit_id,
       qum.qty_unit gmr_qty_unit,
       pofh.qp_start_date,
       pofh.qp_end_date,
       round(nvl(pofh.priced_qty, 0), 5) priced_qty,
       round(nvl(pofh.qty_to_be_fixed, 0), 5) total_payable_qty,
       round(nvl(pofh.qty_to_be_fixed, 0), 5) -
       round(nvl(pofh.priced_qty, 0), 5) over_under_priced_qty,
       pocd.qty_to_be_fixed_unit_id priced_qty_unit_id,
       qum_aml.qty_unit priced_qty_unit,
       pocd.is_any_day_pricing
  from pofh_price_opt_fixation_header pofh,
       pcm_physical_contract_main     pcm,
       ak_corporate                   akc,
       pcdi_pc_delivery_item          pcdi,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       v_gmr_assay_finalized_status   v_gmr,
       diqs_delivery_item_qty_status diqs,
       qum_quantity_unit_master       qum,
       phd_profileheaderdetails       phd,
       aml_attribute_master_list      aml,
       dipch_di_payablecontent_header dipch,
       pcpch_pc_payble_content_header pcpch,
       pcpd_pc_product_definition     pcpd,
       pcpq_pc_product_quality        pcpq,
       pdm_productmaster              pdm,
       qat_quality_attributes         qat,
       qum_quantity_unit_master       qum_aml
 where pofh.pocd_id = pocd.pocd_id
   and pocd.poch_id = poch.poch_id
   and poch.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pofh.internal_gmr_ref_no = v_gmr.internal_gmr_ref_no
   and pofh.final_price is null
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pocd.qty_to_be_fixed_unit_id = qum_aml.qty_unit_id
   and pcm.cp_id = phd.profileid
   and poch.element_id = aml.attribute_id
   and pcdi.pcdi_id = dipch.pcdi_id
   and dipch.is_active = 'Y'
   and dipch.pcpch_id = pcpch.pcpch_id
   and pcpch.element_id = poch.element_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.quality_id
   and nvl(pcpch.payable_type, 'Payable') = 'Payable'
   and pofh.internal_gmr_ref_no is not null
   and pofh.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pocd.qp_period_type <> 'Event'
   and phd.is_active = 'Y'
   and phd.is_deleted = 'N'
   and v_gmr.assay_finalized = 'Y'

