CREATE OR REPLACE VIEW V_DAILY_HEDGE_CORRECTION AS
SELECT akc.corporate_id,
       akc.corporate_name,
       pcdi.pcdi_id,
       'Hedge Correction' section,
       7 section_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       aml.underlying_product_id product,
       pdm.product_desc underlying_product,
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
       gmr.gmr_ref_no gmr_no,
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
       ppfh.formula_description formula,
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
       pfd.user_price price,
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
       NULL smelter
  FROM pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcbpd_pc_base_price_detail pcbpd,
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
       phd_profileheaderdetails phd
 WHERE pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND pcdi.pcdi_id = poch.pcdi_id
   AND poch.element_id = aml.attribute_id
   AND aml.is_active = 'Y'
   AND poch.poch_id = pocd.poch_id
   AND pocd.pocd_id = pofh.pocd_id
   AND pofh.pofh_id = pfd.pofh_id
   AND pocd.pcbpd_id = pcbpd.pcbpd_id
   AND pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   AND ppfh.ppfh_id = ppfd.ppfh_id(+)
   AND ppfh.ppfh_id = pfqpp.ppfh_id(+)
   AND pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
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
/*and akc.corporate_id = '{?CorporateID}'
   and pfd.hedge_correction_date = to_date('{?AsOfDate}', 'dd-Mon-yyyy')*/
UNION ALL
SELECT akc.corporate_id,
       akc.corporate_name,
       pcdi.pcdi_id,
       'Cancelled Fixations' section,
       9 section_id,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       aml.underlying_product_id product_id,
       pdm.product_desc product,
       pdm.product_desc underlying_product,
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
       gmr.gmr_ref_no gmr_no,
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
       ppfh.formula_description formula,
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
       pfd.user_price price,
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
       NULL smelter
  FROM pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pcbpd_pc_base_price_detail pcbpd,
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
       phd_profileheaderdetails phd
 WHERE pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND pcdi.pcdi_id = poch.pcdi_id
   AND poch.element_id = aml.attribute_id
   AND aml.is_active = 'Y'
   AND poch.poch_id = pocd.poch_id
   AND pocd.pocd_id = pofh.pocd_id
   AND pofh.pofh_id = pfd.pofh_id
   AND pocd.pcbpd_id = pcbpd.pcbpd_id
   AND pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   AND ppfh.ppfh_id = ppfd.ppfh_id(+)
   AND ppfh.ppfh_id = pfqpp.ppfh_id(+)
   AND pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
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
   AND pfd.is_cancel = 'Y'

