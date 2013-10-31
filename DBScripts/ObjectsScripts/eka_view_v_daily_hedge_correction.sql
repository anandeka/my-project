CREATE OR REPLACE VIEW V_DAILY_HEDGE_CORRECTION AS
SELECT akc.corporate_id,
       akc.corporate_name,
       pcdi.pcdi_id,
       'Hedge Correction' section,
       7 section_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       -- aml.underlying_product_id product,
       pdm.product_desc product,
       pdm_contract.product_desc underlying_product,
       pcm.contract_type product_type,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name EXCHANGE,
       css.strategy_id,
       css.strategy_name strategy,
       DECODE(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       aml.attribute_id element_id,
       aml.attribute_name element_name,
       pfd.as_of_date trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       nvl(gmr.gmr_ref_no, pfd.allocated_gmr_ref_no) gmr_no,
       nvl(phd_warehouse.companyname, pfd.alloc_gmr_warehouse_name) Warehouse,
       --gmr.gmr_ref_no gmr_no,
       ((CASE
         WHEN pcdi.basis_type = 'Arrival' THEN
          (CASE
         WHEN pcdi.delivery_period_type = 'Date' THEN
          pcdi.delivery_to_date
         ELSE
          LAST_DAY(TO_DATE('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       END) ELSE(CASE
                   WHEN pcdi.delivery_period_type = 'Date' THEN
                    pcdi.delivery_to_date
                   ELSE
                    LAST_DAY(TO_DATE('01-' || pcdi.delivery_to_month || '-' ||
                                     pcdi.delivery_to_year,
                                     'dd-Mon-yyyy'))
                 END) + pcdi.transit_days END)) expected_delivery,
       NULL quality,
       pcbph.price_description formula,
       NULL premimum,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       DECODE(pcm.purchase_sales, 'P', 1, 'S', -1) * pfd.qty_fixed *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       NULL instrument,
       CAST(NULL AS DATE) prompt_date,
       CAST(NULL AS NUMBER) lots,
       (nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) price,
       cm_pay.cur_code pay_in_ccy,
       (CASE
         WHEN pfd.is_hedge_correction_during_qp = 'Y' THEN
          'Within QP'
         ELSE
          'After QP'
       END) sub_section,
       pfd.hedge_correction_date,
       axs.action_id activity_type,
       axs.eff_date activity_date,
       phd.companyname cpname,
       (CASE
         WHEN pfqpp.qp_pricing_period_type = 'Month' THEN
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         WHEN pfqpp.qp_pricing_period_type = 'Event' THEN
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         WHEN pfqpp.qp_pricing_period_type = 'Period' THEN
          TO_CHAR(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          TO_CHAR(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
       END) qp,
       NULL utility_ref_no,
       NULL smelter,
       NULL status,
       pfd.is_hedge_correction,
       nvl(pfd.is_exposure, 'Y') is_exposure
  FROM pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph, -- Newly Added
       ppfh_phy_price_formula_header ppfh,
       (SELECT ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          FROM ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         WHERE ppfd.is_active = 'Y'
           AND ppfd.instrument_id = dim.instrument_id
           AND dim.product_derivative_id = pdd.derivative_def_id
           AND pdd.exchange_id = emt.exchange_id
         GROUP BY ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pfqpp_phy_formula_qp_pricing pfqpp,
       gmr_goods_movement_record gmr,
       ak_corporate akc,
       ak_corporate_user akcu,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay,
       v_ppu_pum ppu,
       pum_price_unit_master pum,
       qum_quantity_unit_master qum,
       axs_action_summary axs,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_warehouse,
       pdm_productmaster pdm_contract
 WHERE pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND pcdi.pcdi_id = poch.pcdi_id
   AND poch.element_id = aml.attribute_id
   AND aml.is_active = 'Y'
   AND poch.poch_id = pocd.poch_id
   AND pocd.pocd_id = pofh.pocd_id
   AND pofh.pofh_id = pfd.pofh_id
   AND pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and pcbph.is_active = 'Y'
   AND pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   AND ppfh.ppfh_id = ppfd.ppfh_id(+)
   AND ppfh.ppfh_id = pfqpp.ppfh_id(+)
      --AND pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
   and gmr.warehouse_profile_id = phd_warehouse.profileid(+)
   AND pcm.corporate_id = akc.corporate_id
   AND pcm.trader_id = akcu.user_id(+)
   AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   AND pcpd.strategy_id = css.strategy_id
   AND pcpd.profit_center_id = cpc.profit_center_id
   AND aml.underlying_product_id = pdm.product_id
   AND akc.base_cur_id = cm_base.cur_id
   AND pocd.pay_in_cur_id = cm_pay.cur_id
   AND pfd.price_unit_id = ppu.product_price_unit_id(+)
   AND ppu.price_unit_id = pum.price_unit_id(+)
   AND pdm.base_quantity_unit = qum.qty_unit_id
   AND pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no
   and pcpd.product_id = pdm_contract.product_id
   AND pcm.cp_id = phd.profileid
   AND pcbpd.price_basis <> 'Fixed'
   AND pcpd.input_output = 'Input'
   AND pcdi.is_active = 'Y'
   AND pcm.is_active = 'Y'
   AND NVL(gmr.is_deleted, 'N') = 'N'
   AND pcm.contract_status <> 'Cancelled'
   AND poch.is_active = 'Y'
   AND pocd.is_active = 'Y'
   AND pofh.is_active(+) = 'Y'
   AND pcbpd.is_active = 'Y'
   AND ppfh.is_active(+) = 'Y'
   AND pfqpp.is_active(+) = 'Y'
   AND pfd.is_active = 'Y'
   AND pfd.is_hedge_correction = 'Y'
   AND NVL(pfd.is_cancel, 'N') = 'N'
UNION ALL--(for Concentrate Cancelled Fixations)
select akc.corporate_id,
       akc.corporate_name,
       pcdi.pcdi_id,
       'Cancelled Fixations' section,
       9 section_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       aml.underlying_product_id product_id,
       pdm.product_desc product,
       pdm_contract.product_desc underlying_product,
       pcm.contract_type product_type,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       aml.attribute_id element_id,
       aml.attribute_name element_name,
       pfd.as_of_date trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       nvl(gmr.gmr_ref_no, pfd.allocated_gmr_ref_no) gmr_no,
       nvl(phd_warehouse.companyname, pfd.alloc_gmr_warehouse_name) warehouse,
       ((case
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
                 end) + pcdi.transit_days end)) expected_delivery,
       null quality,
       pcbph.price_description formula,
       null premimum,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * pfd.qty_fixed *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       cast(null as date) prompt_date,
       cast(null as number) lots,
       (nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) price,
       cm_pay.cur_code pay_in_ccy,
       null sub_section,
       pfd.hedge_correction_date,
       axs.action_id activity_type,
       axs.eff_date activity_date,
       phd.companyname cpname,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
       end) qp,
       null utility_ref_no,
       null smelter,
       null status,
       pfd.is_hedge_correction,
       nvl(pfd.is_exposure, 'Y') is_exposure
  from pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
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
       pfqpp_phy_formula_qp_pricing pfqpp,
       gmr_goods_movement_record gmr,
       ak_corporate akc,
       ak_corporate_user akcu,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay,
       v_ppu_pum ppu,
       pum_price_unit_master pum,
       qum_quantity_unit_master qum,
       axs_action_summary axs,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_warehouse,
       pdm_productmaster pdm_contract
 where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and aml.is_active = 'Y'
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and pcbph.is_active = 'Y'
   and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and ppfh.ppfh_id = pfqpp.ppfh_id(+)
      --AND pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
   and gmr.warehouse_profile_id = phd_warehouse.profileid(+)
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.strategy_id = css.strategy_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and aml.underlying_product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and pocd.pay_in_cur_id = cm_pay.cur_id
   and pfd.price_unit_id = ppu.product_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no(+)
   and pcpd.product_id = pdm_contract.product_id
   and pcm.cp_id = phd.profileid
   and pcbpd.price_basis <> 'Fixed'
   and pcpd.input_output = 'Input'
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'
      --and pcm.contract_ref_no = 'SCT-486-BLD'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active(+) = 'Y'
   and pfqpp.is_active(+) = 'Y'
   and pfd.is_cancel = 'Y'
union all---added for Bug 82081(for Base Metal Cancelled Fixation)
SELECT akc.corporate_id,
       akc.corporate_name,
       pcdi.pcdi_id,
       'Cancelled Fixations' section,
       9 section_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       aml.underlying_product_id product_id,
       pdm.product_desc product,
       pdm_contract.product_desc underlying_product,
       pcm.contract_type product_type,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name EXCHANGE,
       css.strategy_id,
       css.strategy_name strategy,
       DECODE(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       aml.attribute_id element_id,
       aml.attribute_name element_name,
       pfd.as_of_date trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       NVL(gmr.gmr_ref_no, pfd.allocated_gmr_ref_no) gmr_no,
       NVL(phd_warehouse.companyname, pfd.alloc_gmr_warehouse_name) warehouse,
       ((CASE
         WHEN pcdi.basis_type = 'Arrival' THEN
          (CASE
         WHEN pcdi.delivery_period_type = 'Date' THEN
          pcdi.delivery_to_date
         ELSE
          LAST_DAY(TO_DATE('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       END) ELSE(CASE
                   WHEN pcdi.delivery_period_type = 'Date' THEN
                    pcdi.delivery_to_date
                   ELSE
                    LAST_DAY(TO_DATE('01-' || pcdi.delivery_to_month || '-' ||
                                     pcdi.delivery_to_year,
                                     'dd-Mon-yyyy'))
                 END) + pcdi.transit_days END)) expected_delivery,
       NULL quality,
       pcbph.price_description formula,
       NULL premimum,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       DECODE(pcm.purchase_sales, 'P', 1, 'S', -1) * pfd.qty_fixed *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       NULL instrument,
       CAST(NULL AS DATE) prompt_date,
       CAST(NULL AS NUMBER) lots,
       (NVL(pfd.user_price, 0) + NVL(pfd.adjustment_price, 0)) price,
       cm_pay.cur_code pay_in_ccy,
       NULL sub_section,
       pfd.hedge_correction_date,
       axs.action_id activity_type,
       axs.eff_date activity_date,
       phd.companyname cpname,
       (CASE
         WHEN pfqpp.qp_pricing_period_type = 'Month' THEN
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         WHEN pfqpp.qp_pricing_period_type = 'Event' THEN
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         WHEN pfqpp.qp_pricing_period_type = 'Period' THEN
          TO_CHAR(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          TO_CHAR(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
       END) qp,
       NULL utility_ref_no,
       NULL smelter,
       NULL status,
       pfd.is_hedge_correction,
       NVL(pfd.is_exposure, 'Y') is_exposure
  FROM pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       ppfh_phy_price_formula_header ppfh,
       (SELECT ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          FROM ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         WHERE ppfd.is_active = 'Y'
           AND ppfd.instrument_id = dim.instrument_id
           AND dim.product_derivative_id = pdd.derivative_def_id
           AND pdd.exchange_id = emt.exchange_id
         GROUP BY ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pfqpp_phy_formula_qp_pricing pfqpp,
       gmr_goods_movement_record gmr,
       ak_corporate akc,
       ak_corporate_user akcu,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay,
       v_ppu_pum ppu,
       pum_price_unit_master pum,
       qum_quantity_unit_master qum,
       axs_action_summary axs,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_warehouse,
       pdm_productmaster pdm_contract
 WHERE pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND pcdi.pcdi_id = poch.pcdi_id
      --AND poch.element_id = aml.attribute_id
   AND aml.is_active = 'Y'
   AND poch.poch_id = pocd.poch_id
   AND pocd.pocd_id = pofh.pocd_id
   AND pofh.pofh_id = pfd.pofh_id
   AND pocd.pcbpd_id = pcbpd.pcbpd_id
   AND pcbpd.pcbph_id = pcbph.pcbph_id
   AND pcbph.is_active = 'Y'
   AND pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   AND ppfh.ppfh_id = ppfd.ppfh_id(+)
   AND ppfh.ppfh_id = pfqpp.ppfh_id(+)
      --AND pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
   AND pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
   AND gmr.warehouse_profile_id = phd_warehouse.profileid(+)
   AND pcm.corporate_id = akc.corporate_id
   AND pcm.trader_id = akcu.user_id(+)
   AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   AND pcpd.strategy_id = css.strategy_id
   AND pcpd.profit_center_id = cpc.profit_center_id
   AND aml.underlying_product_id = pdm.product_id
   AND akc.base_cur_id = cm_base.cur_id
   AND pocd.pay_in_cur_id = cm_pay.cur_id
   AND pfd.price_unit_id = ppu.product_price_unit_id(+)
   AND ppu.price_unit_id = pum.price_unit_id(+)
   AND pdm.base_quantity_unit = qum.qty_unit_id
   AND pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no(+)
   AND pcpd.product_id = pdm_contract.product_id
   AND pcm.cp_id = phd.profileid
   AND pcbpd.price_basis <> 'Fixed'
   AND pcpd.input_output = 'Input'
   AND pcdi.is_active = 'Y'
   AND pcm.is_active = 'Y'
   AND pcm.contract_type <> 'CONCENTRATES'
   AND pcm.contract_status <> 'Cancelled'
      --and pcm.contract_ref_no = 'PC-1-BLD'
   AND poch.is_active = 'Y'
   AND pocd.is_active = 'Y'
   AND pcbpd.is_active = 'Y'
   AND ppfh.is_active(+) = 'Y'
   AND pfqpp.is_active(+) = 'Y'
   AND pfd.is_cancel = 'Y'
--and pdm.product_id = 'PDM-321'
union all
select fmuh.corporate_id,
       fmuh.corporate_id corporate_name,
       null pcdi_id,
       'Free Metal' section,
       8 section_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pdm.product_desc underlying_product,
       null product_type,
       'Y' is_base_metal,
       null is_concentrate,
       emt.exchange_id,
       emt.exchange_name exchange,
       null strategy_id,
       'NA' strategy,
       null purchase_sales,
       fmed.element_id,
       fmed.element_name,
       fmpfd.as_of_date trade_date,
       null contract_ref_no,
       null contract_type,
       null delivery_item_ref_no,
       null gmr_no,
       null Warehouse,
       null expected_delivery,
       null quality,
       null formula,
       null premimum,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       sum(fmpfd.qty_fixed) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       fmpfd.user_price price,
       cm.cur_code pay_in_ccy,
       null sub_section,
       fmpfd.hedge_correction_date hedge_correction_date,
       null activity_type,
       null activity_date,
       phd.companyname cpname,
       null qp,
       fmuh.utility_ref_no,
       phd.companyname smelter,
       null status,
       null is_hedge_correction,
       'Y' is_exposure
  from fmuh_free_metal_utility_header fmuh,
       fmed_free_metal_elemt_details  fmed,
       fmeifd_index_formula_details   fmeifd,
       dim_der_instrument_master      dim,
       pdd_product_derivative_def     pdd,
       emt_exchangemaster             emt,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm,
       fmpfh_price_fixation_header    fmpfh,
       fmpfd_price_fixation_details   fmpfd,
       phd_profileheaderdetails       phd,
       qum_quantity_unit_master       qum,
       ppu_product_price_units        ppu,
       pum_price_unit_master          pum,
       cm_currency_master             cm,
       cpc_corporate_profit_center    cpc
 where fmuh.fmuh_id = fmed.fmuh_id
   and fmed.fmed_id = fmeifd.fmed_id
   and fmeifd.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.exchange_id = emt.exchange_id
   and fmed.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id
   and fmed.fmed_id = fmpfh.fmed_id
   and fmpfh.fmpfh_id = fmpfd.fmpfh_id
   and fmuh.smelter_id = phd.profileid
   and fmed.qty_unit_id = qum.qty_unit_id
   and fmed.price_unit_id = ppu.internal_price_unit_id
   and ppu.price_unit_id = pum.price_unit_id
   and pum.cur_id = cm.cur_id
   and fmuh.profit_center_id = cpc.profit_center_id
   and fmpfd.is_active = 'Y'
--and fmuh.corporate_id = '{?CorporateID}'
--and fmpfd.hedge_correction_date = to_date('{?AsOfDate}','dd-Mon-yyyy')
 group by fmuh.corporate_id,
          fmuh.corporate_id,
          pdm.product_id,
          pdm.product_desc,
          pdm.product_desc,
          emt.exchange_id,
          emt.exchange_name,
          fmed.element_id,
          fmed.element_name,
          fmpfd.as_of_date,
          pum.price_unit_id,
          pum.price_unit_name,
          qum.qty_unit_id,
          qum.qty_unit,
          qum.decimals,
          fmpfd.user_price,
          cm.cur_code,
          phd.companyname,
          fmuh.utility_ref_no,
          phd.companyname,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          fmpfd.hedge_correction_date
union all -- cancelled free metal utility
select fmuh.corporate_id,
       fmuh.corporate_id corporate_name,
       null pcdi_id,
       'Free Metal' section,
       8 section_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pdm.product_desc underlying_product,
       null product_type,
       'Y' is_base_metal,
       null is_concentrate,
       emt.exchange_id,
       emt.exchange_name exchange,
       null strategy_id,
       'NA' strategy,
       null purchase_sales,
       fmed.element_id,
       fmed.element_name,
       fmpfd.as_of_date trade_date,
       null contract_ref_no,
       null contract_type,
       null delivery_item_ref_no,
       null gmr_no,
       null Warehouse,
       null expected_delivery,
       null quality,
       null formula,
       null premimum,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       sum(fmpfd.qty_fixed) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       fmpfd.user_price price,
       cm.cur_code pay_in_ccy,
       null sub_section,
       fmpfd.hedge_correction_date hedge_correction_date,
       null activity_type,
       null activity_date,
       phd.companyname cpname,
       null qp,
       fmuh.utility_ref_no,
       phd.companyname smelter,
       'Cancelled' status,
       null is_hedge_correction,
       'Y' is_exposure
  from fmuh_free_metal_utility_header fmuh,
       fmed_free_metal_elemt_details  fmed,
       fmeifd_index_formula_details   fmeifd,
       dim_der_instrument_master      dim,
       pdd_product_derivative_def     pdd,
       emt_exchangemaster             emt,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm,
       fmpfh_price_fixation_header    fmpfh,
       fmpfd_price_fixation_details   fmpfd,
       phd_profileheaderdetails       phd,
       qum_quantity_unit_master       qum,
       ppu_product_price_units        ppu,
       pum_price_unit_master          pum,
       cm_currency_master             cm,
       cpc_corporate_profit_center    cpc
 where fmuh.fmuh_id = fmed.fmuh_id
   and fmed.fmed_id = fmeifd.fmed_id
   and fmeifd.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.exchange_id = emt.exchange_id
   and fmed.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm.product_id
   and fmed.fmed_id = fmpfh.fmed_id
   and fmpfh.fmpfh_id = fmpfd.fmpfh_id
   and fmuh.smelter_id = phd.profileid
   and fmed.qty_unit_id = qum.qty_unit_id
   and fmed.price_unit_id = ppu.internal_price_unit_id
   and ppu.price_unit_id = pum.price_unit_id
   and pum.cur_id = cm.cur_id
   and fmuh.profit_center_id = cpc.profit_center_id
   and fmpfd.is_cancel = 'Y'
 group by fmuh.corporate_id,
          fmuh.corporate_id,
          pdm.product_id,
          pdm.product_desc,
          pdm.product_desc,
          emt.exchange_id,
          emt.exchange_name,
          fmed.element_id,
          fmed.element_name,
          fmpfd.as_of_date,
          pum.price_unit_id,
          pum.price_unit_name,
          qum.qty_unit_id,
          qum.qty_unit,
          qum.decimals,
          fmpfd.user_price,
          cm.cur_code,
          phd.companyname,
          fmuh.utility_ref_no,
          phd.companyname,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          fmpfd.hedge_correction_date;
