create or replace view V_BI_DAILY_PRICE_EXPOSURE AS
with main_q as (
        -- Average Pricing for the  base 
        select ak.corporate_id,
                pdm.product_id,
                pdm.product_desc product_name,
                1 dispay_order,
                'Average Exposure' pricing_by,
                decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
                pofh.per_day_pricing_qty *
                pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                     qum.qty_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1) to_be_fixed_or_fixed_qty,
                'N' font_bold,
                pdm.base_quantity_unit base_qty_unit_id,
                qum_pdm.qty_unit base_qty_unit
          from pcm_physical_contract_main pcm,
                pcdi_pc_delivery_item pcdi,
                ak_corporate ak,
                gmr_goods_movement_record gmr,
                pcpd_pc_product_definition pcpd,
                pdm_productmaster pdm,
                css_corporate_strategy_setup css,
                pcpq_pc_product_quality pcpq,
                qat_quality_attributes qat,
                poch_price_opt_call_off_header poch,
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
                qum_quantity_unit_master qum,
                pofh_price_opt_fixation_header pofh,
                cpc_corporate_profit_center cpc,
                vd_voyage_detail vd,
                pfqpp_phy_formula_qp_pricing pfqpp,
                v_pci_multiple_premium vp,
                qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.product_id = pdm.product_id
           and pcpd.strategy_id = css.strategy_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pcpq.quality_template_id = qat.quality_id
           and pcpq.pcpq_id = vp.pcpq_id(+)
           and pdm.product_id = qat.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.poch_id = pocd.poch_id
           and pcm.internal_contract_ref_no = pcbph.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pocd.pocd_id = pofh.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and nvl(vd.status, 'Active') = 'Active'
           and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'BASEMETAL'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pofh.qp_start_date <= trunc(sysdate)
           and pofh.qp_end_date >= trunc(sysdate)
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
        union all
        -- Average Pricing for the  Concentrate  
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc,
               1 section_id,
               'Average Exposure',
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               pofh.per_day_pricing_qty *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               qum_quantity_unit_master qum,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
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
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pcpd.product_id = pdm.product_id
           and pcpq.quality_template_id = qat.quality_id
           and pdm.product_id = qat.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.poch_id = pocd.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and poch.pcbph_id = pcbph.pcbph_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pocd.pocd_id = pofh.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pocd_id = pocd.pocd_id
           and poch.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbph.element_id = poch.element_id
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'CONCENTRATES'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pofh.qp_start_date <= trunc(sysdate)
           and pofh.qp_end_date >= trunc(sysdate)
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
        
        --Fixed by Price Request base
        union all
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product,
               2 display_order,
               'Fixed by Price Request',
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed) *
               pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                    qum.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    1) qty,
               'N',
               pdm.base_quantity_unit,
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               qum_quantity_unit_master qum,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               css_corporate_strategy_setup css,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
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
               v_pci_multiple_premium vp,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpd.strategy_id = css.strategy_id
           and pcpq.quality_template_id = qat.quality_id
           and pcpq.pcpq_id = vp.pcpq_id(+)
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pofh.pocd_id = pocd.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and pfqpp.ppfh_id = ppfh.ppfh_id
           and pcm.contract_type = 'BASEMETAL'
           and pfqpp.is_qp_any_day_basis = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'N' --added to handle spot as separate
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and pfd.is_price_request = 'Y'
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  pcpd.product_id,
                  qum.qty_unit_id,
                  pdm.base_quantity_unit,
                  pdm.base_quantity_unit,
                  qum_pdm.qty_unit
        union all
        --Fixed by Price Request Concentrates
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product,
               2 section_id,
               'Fixed by Price Request' section,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               ak_corporate ak,
               qum_quantity_unit_master qum,
               pcdi_pc_delivery_item pcdi,
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
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.pcpd_id = pcpq.pcpd_id
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
           and pofh.pofh_id = pfd.pofh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and pfqpp.ppfh_id = ppfh.ppfh_id
           and ppfh.is_active = 'Y'
           and pfqpp.is_qp_any_day_basis = 'Y'
           and pcm.contract_type = 'CONCENTRATES'
           and pcm.contract_status <> 'Cancelled'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'N' --added to handle spot as separate
           and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and pfd.is_price_request = 'Y'
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  qum_pdm.qty_unit
        -- Spot base metal
        union all
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product,
               3 section_id,
               'Spot Exposure' section,
               (decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed)) qty,
               'N',
               qum.qty_unit_id,
               qum.qty_unit
          from pcm_physical_contract_main pcm,
               pcdi_pc_delivery_item pcdi,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
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
               pfd_price_fixation_details pfd,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpd.strategy_id = css.strategy_id
           and pcpq.quality_template_id = qat.quality_id
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pofh.pocd_id = pocd.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'Y'
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcm.contract_type = 'BASEMETAL'
           and pcdi.qty_unit_id = qum.qty_unit_id
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and pfd.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date = trunc(sysdate)
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  qum.qty_unit_id,
                  qum.qty_unit
        
        union all --spot concentrate
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product,
               3 section_id,
               'Spot Exposure' section,
               ((decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed)) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                         pdm.product_id),
                                                     qum.qty_unit_id,
                                                     nvl(pdm_under.base_quantity_unit,
                                                         pdm.base_quantity_unit),
                                                     1)) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               pcdi_pc_delivery_item pcdi,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcpd_pc_product_definition pcpd,
               pcpq_pc_product_quality pcpq,
               css_corporate_strategy_setup css,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
               pocd_price_option_calloff_dtls pocd,
               pcbph_pc_base_price_header pcbph,
               pcbpd_pc_base_price_detail pcbpd,
               ppfh_phy_price_formula_header ppfh,
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
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
               pfd_price_fixation_details pfd,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.contract_type = 'CONCENTRATES'
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pcpd.strategy_id = css.strategy_id
           and pdm.product_id = pcpd.product_id
           and pcpq.quality_template_id = qat.quality_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.element_id = poch.element_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pofh.pocd_id = pocd.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and pfd.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pcbph.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  qum_pdm.qty_unit
        
        union all
        --any day base metal
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               5 display_order,
               'Any Day Exposure' pricing_by,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               (pofh.qty_to_be_fixed - nvl(sum(pfd.qty_fixed), 0)) *
               pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                    qum.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    1) to_be_fixed_or_fixed_qty,
               'N' font_bold,
               pdm.base_quantity_unit base_qty_unit_id,
               qum_pdm.qty_unit base_qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
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
               pfd_price_fixation_details pfd,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               v_pci_multiple_premium vp,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpq.quality_template_id = qat.quality_id
           and pcpq.pcpq_id = vp.pcpq_id(+)
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pofh.pocd_id = pocd.pocd_id(+)
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'BASEMETAL'
           and pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) > 0
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date(+) <= sysdate
           and trunc(sysdate) between pofh.qp_start_date and pofh.qp_end_date
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  pofh.qty_to_be_fixed,
                  pcpd.product_id,
                  qum.qty_unit_id,
                  pdm.base_quantity_unit,
                  pdm.base_quantity_unit,
                  qum_pdm.qty_unit
        union all
        --any day concentrate
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product_name,
               5 display_order,
               'Any Day Exposure' pricing_by,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               (pofh.qty_to_be_fixed - nvl(sum(pfd.qty_fixed), 0)) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N' font_bold,
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_qty_unit_id,
               qum_pdm.qty_unit_id base_qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
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
               pfd_price_fixation_details pfd,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               qum_quantity_unit_master qum,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpq.quality_template_id = qat.quality_id
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.element_id = poch.element_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pofh.pocd_id = pocd.pocd_id(+)
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id(+)
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'CONCENTRATES'
           and pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) > 0
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date(+) <= sysdate
           and trunc(sysdate) between pofh.qp_start_date and pofh.qp_end_date
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  pofh.qty_to_be_fixed,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  qum_pdm.qty_unit_id,
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               1 dispay_order,
               'Average Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               2 dispay_order,
               'Fixed by Price Request',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               3 dispay_order,
               'Spot Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               5 dispay_order,
               'Any Day Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
         ) 
select corporate_id,
       product_id,
       product_name,
       dispay_order,
       pricing_by,
       to_be_fixed_or_fixed_qty,
       font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
union all
select corporate_id,
       product_id,
       product_name,
       4 dispay_order,
       'Total Exposure' pricing_by,
       sum(to_be_fixed_or_fixed_qty),
       'Y' font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
 where dispay_order in (1, 2, 3)
 group by corporate_id,
          product_id,
          product_name,
          base_qty_unit_id,
          base_qty_unit
union all
select corporate_id,
       product_id,
       product_name,
       6 dispay_order,
       'Total Exposure With Any Day' pricing_by,
       sum(to_be_fixed_or_fixed_qty),
       'Y' font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
 group by corporate_id,
          product_id,
          product_name,
          base_qty_unit_id,
          base_qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       7 dispay_order,
       'Net Hedge Exposure' pricing_by,
       sum(drt.hedge_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       8 dispay_order,
       'Net Strategic Exposure' pricing_by,
       sum(drt.strategic_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       9 dispay_order,
       'Net Derivative' pricing_by,
       sum(drt.trade_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit
