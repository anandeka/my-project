create or replace view v_rpt_yearly_price_exp_conc as
with pofh_header_data as( select *
  from pofh_price_opt_fixation_header pofh
 where pofh.internal_gmr_ref_no is null
   and pofh.qty_to_be_fixed is not null
   and pofh.is_active = 'Y'),
pfd_fixation_data as(
select pfd.pofh_id, round(sum(nvl(pfd.qty_fixed, 0)), 5) qty_fixed
  from pfd_price_fixation_details pfd
where pfd.is_active = 'Y'
 --and nvl(pfd.is_price_request,'N') ='N'
-- and  pfd.as_of_date > trunc(sysdate)
 group by pfd.pofh_id)
--Any Day Pricing Concentrate +Contract
select 10 section_id,
       'CC-CON-UNFIXED' section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       qat.quality_name quality,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       round((pofh.qty_to_be_fixed - (nvl(pfd.qty_fixed, 0))) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1),5) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_header_data pofh,
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pocd_id = pocd.pocd_id(+)
   and pofh.pofh_id = pfd.pofh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
union all
--Average Pricing Concentrate+Contract
select 11 section_id,
       'CC-CON-UNFIXED' section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       null trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       qat.quality_name quality,
       round(decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (pofh.qty_to_be_fixed - nvl(pofh.priced_qty,0)) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1),5) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pofh_header_data pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and poch.element_id = aml.attribute_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = poch.element_id
   and pofh.pocd_id = pocd.pocd_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
union all
----Fixed by Price Request Concentrate+Contact
select 12 section_id,
       'CC-CON-FIXED' section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       to_char(last_day(pfd.as_of_date),'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       last_day(pfd.as_of_date) trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       qat.quality_name quality,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       qum_quantity_unit_master qum,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum_under,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       cipq_contract_item_payable_qty cipq,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and qat.product_id = pdm.product_id
   and pcpq.quality_template_id = qat.quality_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pofh.pocd_id = pocd.pocd_id
   and pofh.qty_to_be_fixed is not null
   and pofh.internal_gmr_ref_no is null
   and pofh.pofh_id = pfd.pofh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcm.approval_status = 'Approved'
   and pcm.contract_status <> 'Cancelled'
   and cipq.element_id = poch.element_id
   and cipq.qty_unit_id = qum.qty_unit_id
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm_under.product_id,
          pdm_under.product_desc,       to_char(last_day(pfd.as_of_date),'dd-Mon-yyyy'),
          css.strategy_id,last_day(pfd.as_of_date),
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          aml.attribute_name,
          qat.quality_name,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pdm_under.product_id,
          pdm.product_id,
          qum.qty_unit_id,
          pdm_under.base_quantity_unit,
          pdm.base_quantity_unit,
          qum_under.qty_unit,
          qum_under.qty_unit_id,
          qum_under.decimals,
          pum.price_unit_name,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pocd.pcbpd_id,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          ppfd.instrument_id,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          pcdi.transit_days,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          dipq.is_price_optionality_present,
          dipq.price_option_call_off_status,
          qat.quality_name
union all
--Any Day/Avg Pricing Concentrate +GMR
select (case when nvl(poch.is_free_metal_pricing,'NA') = 'Y' then
            14 else 13  end)section_id,
       (case when nvl(poch.is_free_metal_pricing,'NA') = 'Y' then
            'CC-FM-UNFIXED' else 'CC-GMR-UNFIXED'  end)  section_name,
 ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       qat.quality_name quality,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       round((pofh.qty_to_be_fixed - nvl(pofh.priced_qty,0)) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1),5) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pocd_id = pocd.pocd_id(+)
   and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
   and pofh.internal_gmr_ref_no is not null
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and nvl(gmr.is_deleted, 'N') = 'N'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
union all
----Fixed by Price date Concentrate+GMR  + Free metal
select (case when nvl(poch.is_free_metal_pricing,'NA') = 'Y' then
            16 else 15  end)section_id,
       (case when nvl(poch.is_free_metal_pricing,'NA') = 'Y' then
            'CC-FM-FIXED' else 'CC-GMR-FIXED'  end)  section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       to_char(last_day(pfd.as_of_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       last_day(pfd.as_of_date) trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no,
       qat.quality_name quality,
       round(decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1),5) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       qum_quantity_unit_master qum,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum_under,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       cipq_contract_item_payable_qty cipq,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pofh.pocd_id = pocd.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is not null
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcm.contract_type = 'CONCENTRATES'
   and pcm.approval_status = 'Approved'
   and pcm.contract_status <> 'Cancelled'
   and cipq.element_id = poch.element_id
   and poch.element_id = dipq.element_id
   and cipq.qty_unit_id = qum.qty_unit_id
   and ak.corporate_id = pcm.corporate_id
   and pcpd.product_id = pdm.product_id
   and pcpd.strategy_id = css.strategy_id
   and qat.product_id = pdm.product_id
   and pcpq.quality_template_id = qat.quality_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
 group by ak.corporate_id,
          ak.corporate_name,poch.is_free_metal_pricing,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm_under.product_id,
          pdm_under.product_desc,
          css.strategy_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          aml.attribute_name,
          qat.quality_name,last_day(pfd.as_of_date),
          to_char(last_day(pfd.as_of_date), 'dd-Mon-yyyy'),
                pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pdm_under.product_id,
          pdm.product_id,
          qum.qty_unit_id,
          pdm_under.base_quantity_unit,
          pdm.base_quantity_unit,
          qum_under.qty_unit,
          qum_under.qty_unit_id,
          qum_under.decimals,
          pum.price_unit_name,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pocd.pcbpd_id,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          ppfd.instrument_id,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          pcdi.transit_days,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pofh.qp_start_date,
          gmr.gmr_ref_no,
          pofh.qp_end_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          dipq.is_price_optionality_present,
          dipq.price_option_call_off_status,
          qat.quality_name
/