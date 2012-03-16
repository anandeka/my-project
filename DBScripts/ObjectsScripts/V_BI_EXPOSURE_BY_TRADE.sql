create or replace view V_BI_EXPOSURE_BY_TRADE as
-- Fixed contracts
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.issue_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       dim.instrument_id,
       dim.instrument_name,
       diqs.total_qty price_fixed_qty,
       0 unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pcpq_pc_product_quality        pcpq,
       v_bi_qat_quality_valuation     qat,
       dim_der_instrument_master      dim,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       qum_quantity_unit_master       qum
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpd.input_output = 'Input'
   and qat.instrument_id = dim.instrument_id
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.price_type = 'Fixed'
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.issue_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       dim.instrument_id,
       dim.instrument_name,
       0 price_fixed_qty,
       0 unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pcpq_pc_product_quality        pcpq,
       v_bi_qat_quality_valuation     qat,
       dim_der_instrument_master      dim,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       qum_quantity_unit_master       qum
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpd.input_output = 'Input'
   and qat.instrument_id = dim.instrument_id
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.price_type = 'Fixed'
union all
-- varibale contracts with out event based
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.issue_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       nvl(pofh.priced_qty, 0) price_fixed_qty,
       0 unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       qum_quantity_unit_master       qum
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type not in ('Event')
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pofh.qp_end_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       0 price_fixed_qty,
       pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       qum_quantity_unit_master       qum
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type not in ('Event')
union all
--event based  with out GMR creation 
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.issue_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       diqs.gmr_qty price_fixed_qty,
       0 unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       qum_quantity_unit_master       qum,
       di_del_item_exp_qp_details     di
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pcdi.pcdi_id = di.pcdi_id
   and di.is_active = 'Y'
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type = 'Event'
   and pofh.internal_gmr_ref_no is null
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       di.expected_qp_end_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       0 price_fixed_qty,
       diqs.total_qty - diqs.gmr_qty unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       qum_quantity_unit_master       qum,
       di_del_item_exp_qp_details     di
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pcdi.pcdi_id = di.pcdi_id
   and di.is_active = 'Y'
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type = 'Event'
   and pofh.internal_gmr_ref_no is null
union all
-- event based  with GMR created
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.issue_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       nvl(pofh.priced_qty, 0) price_fixed_qty,
       0 unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       qum_quantity_unit_master       qum
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type = 'Event'
   and pofh.internal_gmr_ref_no is not null
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pofh.qp_end_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       0 price_fixed_qty,
       pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       qum_quantity_unit_master       qum
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type = 'Event'
   and pofh.internal_gmr_ref_no is not null
