create or replace view v_projected_price_exposure as
---for Base Metals
   WITH pofh_header_data AS
        (SELECT *
           FROM pofh_price_opt_fixation_header pofh
          WHERE pofh.internal_gmr_ref_no IS NULL
            AND pofh.qty_to_be_fixed IS NOT NULL
            AND pofh.is_active = 'Y'),
        pfd_fixation_data AS
        (SELECT   pfd.pofh_id,
                  ROUND (SUM (NVL (pfd.qty_fixed, 0)), 5) qty_fixed
             FROM pfd_price_fixation_details pfd
            WHERE pfd.is_active = 'Y'
         GROUP BY pfd.pofh_id)
--Any Day Pricing Base Metal +Contract
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       
       -----
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (((case
          when pfqpp.qp_pricing_period_type = 'Event' then
           (diqs.total_qty - diqs.gmr_qty - diqs.fulfilled_qty)
          else
           pofh.qty_to_be_fixed
        end) - nvl(pfd.qty_fixed, 0)) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1)) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       pcdiqd_di_quality_details pcdiqd,
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
       pofh_header_data pofh,
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
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp,
       pfqpp_phy_formula_qp_pricing pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpq.pcpq_id = vp.pcpq_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pofh_id = pfd.pofh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
      --   and pcm.internal_contract_ref_no = vp.internal_contract_ref_no
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
      -- and pcm.contract_ref_no = 'SC-14-EKA'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
union all
--Any Day Pricing Base Metal +GMR
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * pofh.qty_to_be_fixed -
       sum(nvl(pfd.qty_fixed, 0)) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
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
       qum_quantity_unit_master qum
 where --pcm.internal_contract_ref_no = gmr.internal_contract_ref_no  and
 ak.corporate_id = pcm.corporate_id
 and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
 and pcdi.pcdi_id = pcdiqd.pcdi_id
 and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
 and pcpd.pcpd_id = pcpq.pcpd_id
 and pcdiqd.pcpq_id = pcpq.pcpq_id
 and pcpd.strategy_id = css.strategy_id
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
 and pofh.pofh_id = pfd.pofh_id(+)
 and pofh.internal_gmr_ref_no is not null
 and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
 and pcpd.profit_center_id = cpc.profit_center_id
 and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
 and nvl(vd.status, 'NA') in ('Active', 'NA')
 and ppfh.ppfh_id = pfqpp.ppfh_id
 and ppfh.ppfh_id = ppfd.ppfh_id
--  and pcm.internal_contract_ref_no = vp.internal_contract_ref_no
 and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
 and pdm.base_quantity_unit = qum.qty_unit_id
 and pcm.is_active = 'Y'
 and pcm.contract_type = 'BASEMETAL'
 and pcm.approval_status = 'Approved'
 and pcdi.is_active = 'Y'
 and gmr.is_deleted = 'N'
 and pdm.is_active = 'Y'
 and qum.is_active = 'Y'
 and qat.is_active = 'Y'
 and pofh.is_active = 'Y'
 and poch.is_active = 'Y'
 and pocd.is_active = 'Y'
 and ppfh.is_active = 'Y'
--and ak.corporate_id = '{?CorporateID}'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          pocd.pcbpd_id,
          pcm.contract_type,
          css.strategy_id,
          css.strategy_name,
          pofh.qp_start_date,
          to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy'),
          pcm.purchase_sales,
          pcm.issue_date,
          (case
            when pfqpp.qp_pricing_period_type = 'Month' then
             pfqpp.qp_month || ' - ' || pfqpp.qp_year
            when pfqpp.qp_pricing_period_type = 'Event' then
             pfqpp.no_of_event_months || ' ' || pfqpp.event_name
            when pfqpp.qp_pricing_period_type = 'Period' then
             to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
             to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
            when pfqpp.qp_pricing_period_type = 'Date' then
             to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
          end),
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no,
          gmr.gmr_ref_no,
          pofh.qty_to_be_fixed,
          vd.eta,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit_id,
          qum.qty_unit,
          qum.decimals,
          ppfh.formula_description,
          ppfd.exchange_id,
          ppfd.exchange_name,
          ppfd.instrument_id,
          vp.premium,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status,
          qat.quality_name
union all
--Average Pricing Base Metal+Contract
select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       --  pofh.pofh_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
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
       pofh_header_data pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpd.strategy_id = css.strategy_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpq.pcpq_id = vp.pcpq_id(+)
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pocd.pocd_id = pofh.pocd_id
      -- and pofh.pofh_id = pfd.pofh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
      -- and pcm.internal_contract_ref_no = vp.internal_contract_ref_no
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
--and ak.corporate_id = '{?CorporateID}'
union all
--Average Pricing Base Metal+GMR
select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       -- pofh.pofh_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
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
       vd_voyage_detail vd,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpq.pcpq_id = vp.pcpq_id(+)
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      --  AND pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and pofh.internal_gmr_ref_no is not null
   and nvl(vd.status, 'NA') in ('NA', 'Active')
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
      --  and pcm.internal_contract_ref_no = vp.internal_contract_ref_no
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and gmr.is_deleted = 'N'
--and ak.corporate_id = '{?CorporateID}'
union all
--Fixed by Price Request Base Metal +Contract
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
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
       pfqpp_phy_formula_qp_pricing pfqpp
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
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
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is null
   and pofh.qty_to_be_fixed is not null
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
      --   and pcm.internal_contract_ref_no = vp.internal_contract_ref_no
   and pcpd.profit_center_id = cpc.profit_center_id
      --and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate) --siva
--and ak.corporate_id = '{?CorporateID}'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          css.strategy_id,
          ppfd.instrument_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          qat.quality_name,
          pfd.as_of_date,
          pocd.pcbpd_id,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          --vd.eta,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          qum.qty_unit_id,
          qum.decimals,
          ppfh.formula_description,
          vp.premium,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pcdi.transit_days,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status,
          qat.quality_name
union all
----Fixed by Price Request Base Metal +GMR
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when pcdi.is_price_optionality_present = 'Y' and
              pcdi.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when pcdi.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
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
       vd_voyage_detail vd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
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
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is not null
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      -- AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and nvl(vd.status, 'NA') in ('NA', 'Active')
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
      -- and pcm.internal_contract_ref_no = vp.internal_contract_ref_no
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
      --and ak.corporate_id = '{?CorporateID}'
      -- and  pfd.as_of_date >= sysdate
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate)
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm.product_id,
          pdm.product_desc,
          css.strategy_id,
          ppfd.instrument_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          qat.quality_name,
          pfd.as_of_date,
          pocd.pcbpd_id,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          vd.eta,
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          qum.qty_unit_id,
          qum.decimals,
          ppfh.formula_description,
          vp.premium,
          ppfd.exchange_id,
          pofh.qp_start_date,
          pofh.qp_end_date,
          gmr.gmr_ref_no,
          ppfd.exchange_name,
          pcdi.basis_type,
          pcdi.transit_days,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status,
          qat.quality_name
