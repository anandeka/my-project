create or replace view v_traders_card_expected_qp as
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.purchase_sales contract_type,
       pcm.issue_date start_price_date,
       pcm.issue_date end_price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       dim.instrument_id,
       dim.instrument_name,
       diqs.total_qty * ucm.multiplication_factor price_fixed_qty,
       qum.qty_unit_id qty_unit_id,
       qum.qty_unit,
       1 no_of_days,
       pcpd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name
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
       qum_quantity_unit_master       qum,
       ucm_unit_conversion_master     ucm,
       cpc_corporate_profit_center cpc
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpd.input_output = 'Input'
   and qat.instrument_id = dim.instrument_id
   and pcpd.product_id = pdm.product_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.price_type = 'Fixed'
   and ucm.from_qty_unit_id = diqs.item_qty_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and pcm.contract_status = 'In Position'
   and ucm.is_active = 'Y'
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.purchase_sales contract_type,       
       pofh.qp_start_date start_price_date,
       pofh.qp_end_date end_price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       pofh.qty_to_be_fixed * ucm.multiplication_factor price_fixed_qty,
       qum.qty_unit_id qty_unit_id,
       qum.qty_unit,
       pofh.no_of_prompt_days no_of_days,
       pcpd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name
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
       ucm_unit_conversion_master     ucm,
       cpc_corporate_profit_center cpc
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
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type not in ('Event')
   and ucm.from_qty_unit_id = diqs.item_qty_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and ucm.is_active = 'Y'
   and pcm.contract_status = 'In Position'
   and pcpd.profit_center_id = cpc.profit_center_id   
union all
--union all
-- event based contract unfixed qty for qty not deliveryed
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.purchase_sales contract_type,       
       di.expected_qp_start_date start_price_date,
       di.expected_qp_end_date end_price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       (diqs.total_qty - nvl(diqs.gmr_qty, 0)) * ucm.multiplication_factor price_fixed_qty,
       qum.qty_unit_id qty_unit_id,
       qum.qty_unit,
       f_get_pricing_days(ppfd.instrument_id,
                          di.expected_qp_start_date,
                          di.expected_qp_end_date) no_of_days,
       pcpd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name
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
       di_del_item_exp_qp_details     di,
       ucm_unit_conversion_master     ucm,
       cpc_corporate_profit_center cpc
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
   and pdm.base_quantity_unit = qum.qty_unit_id
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
   and ucm.from_qty_unit_id = diqs.item_qty_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and ucm.is_active = 'Y'
   and pcm.contract_status = 'In Position'
   and pcpd.profit_center_id = cpc.profit_center_id   
-- and pofh.internal_gmr_ref_no is null
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.purchase_sales contract_type,       
       pofh.qp_start_date start_price_date,
       pofh.qp_end_date end_price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       pofh.qty_to_be_fixed * ucm.multiplication_factor price_fixed_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit,
       pofh.no_of_prompt_days no_of_days,
       pcpd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name
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
       ucm_unit_conversion_master     ucm,
       cpc_corporate_profit_center cpc
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
   and pdm.base_quantity_unit = qum.qty_unit_id
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
   and ucm.from_qty_unit_id = diqs.item_qty_unit_id
   and ucm.to_qty_unit_id = pdm.base_quantity_unit
   and ucm.is_active = 'Y'
   and pcm.contract_status = 'In Position'
   and pcpd.profit_center_id = cpc.profit_center_id
/