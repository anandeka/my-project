create or replace view v_bi_exposure_by_trade as
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.issue_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       dim.instrument_id,
       dim.instrument_name,
       diqs.total_qty * ucm.multiplication_factor price_fixed_qty,
       0 unpriced_qty,
       qum.qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pcdiqd_di_quality_details      pcdiqd,
       pcpq_pc_product_quality        pcpq,
       v_bi_qat_quality_valuation     qat,
       dim_der_instrument_master      dim,
       pdm_productmaster              pdm,
       diqs_delivery_item_qty_status  diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       qum_quantity_unit_master       qum,
       ucm_unit_conversion_master     ucm
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcdiqd.is_active = 'Y'
   and pcpq.quality_template_id = qat.quality_id(+)
   and pcpd.input_output = 'Input'
   and qat.instrument_id = dim.instrument_id(+)
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.price_type = 'Fixed'
   and diqs.item_qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and ucm.is_active = 'Y'
union all
-- 2nd varibale contracts with out event based( Price_fixed_qty)
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pfd.as_of_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       nvl(pfd.qty_fixed, 0) * ucm.multiplication_factor price_fixed_qty,
       0 unpriced_qty,
       qum.qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       diqs_delivery_item_qty_status diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       dim_der_instrument_master dim,
       qum_quantity_unit_master qum,
       pfd_price_fixation_details pfd,
       ucm_unit_conversion_master ucm
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
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
   and pfd.pofh_id = pofh.pofh_id
   and pfd.is_active = 'Y'
   and diqs.item_qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and ucm.is_active = 'Y'
union all
--3rd varibale contracts with out event based( un_priced_qty)
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
       (pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0)) *
       ucm.multiplication_factor unpriced_qty,
       qum.qty_unit_id qty_unit_id,
       qum.qty_unit

  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       diqs_delivery_item_qty_status diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       dim_der_instrument_master dim,
       qum_quantity_unit_master qum,
       ucm_unit_conversion_master ucm
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
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
   and diqs.item_qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and ucm.is_active = 'Y'
union all
-- 4th event based contract unfixed qty for qty not deliveryed
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
       (diqs.total_qty - nvl(diqs.gmr_qty, 0)) * ucm.multiplication_factor unpriced_qty,
       qum.qty_unit_id qty_unit_id,
       qum.qty_unit

  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       diqs_delivery_item_qty_status diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       dim_der_instrument_master dim,
       qum_quantity_unit_master qum,
       di_del_item_exp_qp_details di,
       ucm_unit_conversion_master ucm
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = diqs.pcdi_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
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

union all
-- 5th event based  with GMR created(price_fixed_Qty)
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pfd.as_of_date price_date,
       pcdi.pcdi_id,
       pcpd.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       nvl(pfd.qty_fixed, 0) * ucm.multiplication_factor price_fixed_qty,
       0 unpriced_qty,
       qum.qty_unit_id qty_unit_id,
       qum.qty_unit

  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       diqs_delivery_item_qty_status diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       dim_der_instrument_master dim,
       qum_quantity_unit_master qum,
       pfd_price_fixation_details pfd,
       ucm_unit_conversion_master ucm
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
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
   and pofh.pofh_id = pfd.pofh_id
   and pfd.is_active = 'Y'
   and diqs.item_qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and ucm.is_active = 'Y'
--6th event based  with GMR created(un_fixed_Qty)
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
       (pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0)) *
       ucm.multiplication_factor unpriced_qty,
       diqs.item_qty_unit_id qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       diqs_delivery_item_qty_status diqs,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       dim_der_instrument_master dim,
       qum_quantity_unit_master qum,
       ucm_unit_conversion_master ucm
 where pcm.contract_type = 'BASEMETAL'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
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
   and pofh.is_active = 'Y'--------------added for Bug 80208 
   and diqs.item_qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and ucm.is_active = 'Y'

--7th Fixed Conc contracts
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.issue_date price_date,
       pcdi.pcdi_id,
       qat.product_id,
       pdm.product_desc productname,
       dim.instrument_id,
       dim.instrument_name,
       ((case
         when dipq.qty_type = 'Payable' then
          nvl(dipq.payable_qty, 0)
         else
          nvl(dipq.returnable_qty, 0)
       end) * pkg_general.f_get_converted_quantity(qat.product_id,
                                                    dipq.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    1)) price_fixed_qty,
       0 unpriced_qty,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pcdiqd_di_quality_details      pcdiqd,
       pcpq_pc_product_quality        pcpq,
       v_bi_conc_qat_valuation        qat,
       dim_der_instrument_master      dim,
       pdm_productmaster              pdm,
       dipq_delivery_item_payable_qty dipq,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       qum_quantity_unit_master       qum
 where pcm.contract_type = 'CONCENTRATES'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpq.quality_template_id = qat.conc_quality_id
   and pcpd.input_output = 'Input'
   and qat.instrument_id = dim.instrument_id
   and qat.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and dipq.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and qat.attribute_id = dipq.element_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and poch.element_id = dipq.element_id
   and pocd.price_type = 'Fixed'
--8th  Variable contracts with out event based(price_fixed_qty)
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pfd.as_of_date price_date,
       pcdi.pcdi_id,
       qat.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       sum(nvl(pfd.qty_fixed, 0)) *
       pkg_general.f_get_converted_quantity(qat.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1) price_fixed_qty,
       0 unpriced_qty,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pcpd_pc_product_definition     pcpd,
       pcpq_pc_product_quality        pcpq,
       v_bi_conc_qat_valuation        qat,
       dim_der_instrument_master      dim,
       pdm_productmaster              pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       qum_quantity_unit_master       qum,
       pfd_price_fixation_details     pfd
 where pcm.contract_type = 'CONCENTRATES'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.conc_quality_id
   and pcpd.input_output = 'Input'
   and ppfd.instrument_id = dim.instrument_id
   and qat.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and qat.attribute_id = poch.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type not in ('Event')
   and pofh.pofh_id = pfd.pofh_id
   and pfd.is_active = 'Y'
   and pofh.is_active = 'Y'--------------added for Bug 80208 
 group by pcm.corporate_id,
          pcm.contract_ref_no,
          pcm.internal_contract_ref_no,
          pfd.as_of_date,
          pcdi.pcdi_id,
          qat.product_id,
          pdm.product_desc,
          ppfd.instrument_id,
          dim.instrument_name,
          pocd.qty_to_be_fixed_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit

--9th Variable contracts with out event based(un_fixed_qty)
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pofh.qp_end_date price_date,
       pcdi.pcdi_id,
       qat.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       0 price_fixed_qty,
       pkg_general.f_get_converted_quantity(qat.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            pofh.qty_to_be_fixed -
                                            nvl(pofh.priced_qty, 0)
                                            -nvl(pofh.total_hedge_corrected_qty,0)) unpriced_qty,--for Bug 82962
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       v_bi_conc_qat_valuation qat,
       dim_der_instrument_master dim,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       qum_quantity_unit_master qum
 where pcm.contract_type = 'CONCENTRATES'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.conc_quality_id
   and pcpd.input_output = 'Input'
   and ppfd.instrument_id = dim.instrument_id
   and qat.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and qat.attribute_id = poch.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type not in ('Event')
   and pofh.is_active = 'Y'--------------added for Bug 80208 
   and pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) > 0
union all
-- 10th variable contract event based with GMR created (price_fixed_qty)
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.issue_date price_date,
       pcdi.pcdi_id,
       qat.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       pkg_general.f_get_converted_quantity(qat.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            nvl(pofh.priced_qty, 0)) price_fixed_qty,
       0 unpriced_qty,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       v_bi_conc_qat_valuation qat,
       dim_der_instrument_master dim,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       qum_quantity_unit_master qum
 where pcm.contract_type = 'CONCENTRATES'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.conc_quality_id
   and pcpd.input_output = 'Input'
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and qat.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and qat.attribute_id = poch.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type = 'Event'
   and pofh.is_active = 'Y'--------------added for Bug 80208 
   and pofh.internal_gmr_ref_no is not null
--11th variable contract event based with GMR created (un_fixed_qty)
union all
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pofh.qp_end_date price_date,
       pcdi.pcdi_id,
       qat.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       0 price_fixed_qty,
       (pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0)) *
       pkg_general.f_get_converted_quantity(qat.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1) unpriced_qty,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       v_bi_conc_qat_valuation qat,
       dim_der_instrument_master dim,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       qum_quantity_unit_master qum
 where pcm.contract_type = 'CONCENTRATES'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.conc_quality_id
   and pcpd.input_output = 'Input'
   and ppfd.instrument_id = dim.instrument_id
   and qat.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and qat.attribute_id = poch.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type = 'Event'
   and pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) > 0
   and pofh.internal_gmr_ref_no is not null
union all
---12 th  Event based with Out GMR created
select pcm.corporate_id,
       pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       di.expected_qp_end_date price_date,
       pcdi.pcdi_id,
       qat.product_id,
       pdm.product_desc productname,
       ppfd.instrument_id,
       dim.instrument_name,
       0 price_fixed_qty,
       (pcdi_qty.priced_qty * ucm.multiplication_factor) unpriced_qty,
       pdm.base_quantity_unit qty_unit_id,
       qum.qty_unit
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       v_bi_conc_qat_valuation qat,
       dim_der_instrument_master dim,
       pdm_productmaster pdm,
       ucm_unit_conversion_master ucm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select pofh.pocd_id
          from pofh_price_opt_fixation_header pofh
         group by pofh.pocd_id) pofh,
       (select ppfd.instrument_id,
               ppfd.ppfh_id
          from ppfd_phy_price_formula_details ppfd
         where ppfd.is_active = 'Y'
         group by ppfd.ppfh_id,
                  ppfd.instrument_id) ppfd,
       qum_quantity_unit_master qum,
       di_del_item_exp_qp_details di,
       (select pcdi.pcdi_id,
               pci_ele.element_id,
               pci_ele.qty_unit_id,
               sum(pci_ele.open_payable_qty) priced_qty
          from pcm_physical_contract_main pcm,
               pcdi_pc_delivery_item      pcdi,
               pci_physical_contract_item pci,
               v_pci_element_qty          pci_ele
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pci.pcdi_id = pcdi.pcdi_id
           and pci.internal_contract_item_ref_no =
               pci_ele.internal_contract_item_ref_no
         group by pcdi.pcdi_id,
                  pci_ele.element_id,
                  pci_ele.qty_unit_id) pcdi_qty
 where pcm.contract_type = 'CONCENTRATES'
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.conc_quality_id
   and pcpd.input_output = 'Input'
   and ppfd.instrument_id = dim.instrument_id
   and qat.product_id = pdm.product_id
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'----------Added 
   and pcdi.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and qat.attribute_id = poch.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and di.pcdi_id = pcdi.pcdi_id
   and di.pcbpd_id = pcbpd.pcbpd_id
   and di.is_active = 'Y'
   and pcdi.pcdi_id = pcdi_qty.pcdi_id
   and poch.element_id = pcdi_qty.element_id
   and pocd.price_type not in ('Fixed')
   and pocd.qp_period_type = 'Event'
   and pcdi_qty.qty_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
   and ucm.is_active = 'Y' ;
