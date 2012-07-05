create or replace view v_daily_hedge_correction as
select
         akc.corporate_id,
         akc.corporate_name,
         'Hedge Correction' section,
         7 section_id,
         cpc.profit_center_id,
         cpc.profit_center_short_name profit_center,
         pdm.product_id,
         pdm.product_desc product,
         pcm.contract_type product_type,
         'Y' is_base_metal,
         'N' is_concentrate,
         ppfd.exchange_id,
         ppfd.exchange_name exchange,
         css.strategy_id,
         css.strategy_name strategy,
         decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
         null element_id,
         null element_name,
         pfd.as_of_date trade_date,
         pcm.contract_ref_no,
         pcm.contract_type,
         pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
         gmr.gmr_ref_no gmr_no,
         ((case
            when pcdi.basis_type = 'Arrival' then
                  (case
                   when pcdi.delivery_period_type = 'Date' then
                   pcdi.delivery_to_date
                   else
                   last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                   pcdi.delivery_to_year,'dd-Mon-yyyy'))
                   end) else(case
                   when pcdi.delivery_period_type = 'Date' then
                   pcdi.delivery_to_date
                   else
                   last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                   pcdi.delivery_to_year,'dd-Mon-yyyy'))
                   end) + pcdi.transit_days end))expected_delivery,
         null quality,
         ppfh.formula_description formula,
         null premimum,
         pum.price_unit_id,
         pum.price_unit_name price_unit,
         decode(pcm.purchase_sales, 'P', 1, 'S', -1)*pfd.qty_fixed*
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
         (nvl(pfd.user_price,0)+nvl(pfd.adjustment_price,0)) price,
         cm_pay.cur_code pay_in_ccy,
    (case
     when pfd.is_hedge_correction_during_qp = 'Y' then
      'Within QP'
     else
      'After QP'
         end) sub_section,
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
         null smelter
    from pcdi_pc_delivery_item          pcdi,
         pcm_physical_contract_main     pcm,
         poch_price_opt_call_off_header poch,
         pocd_price_option_calloff_dtls pocd,
         pofh_price_opt_fixation_header pofh,
         pfd_price_fixation_details     pfd,
         pcbpd_pc_base_price_detail     pcbpd,
         ppfh_phy_price_formula_header  ppfh,
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
         pfqpp_phy_formula_qp_pricing   pfqpp,
         gmr_goods_movement_record      gmr,
         ak_corporate                   akc,
         ak_corporate_user              akcu,
         pcpd_pc_product_definition     pcpd,
         css_corporate_strategy_setup   css,
         cpc_corporate_profit_center    cpc,
         pdm_productmaster              pdm,
         cm_currency_master             cm_base,
         cm_currency_master             cm_pay,
         v_ppu_pum                      ppu,
         pum_price_unit_master          pum,
         qum_quantity_unit_master       qum,
         axs_action_summary             axs,
         phd_profileheaderdetails       phd
   where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pocd.pcbpd_id = pcbpd.pcbpd_id
     and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
     and ppfh.ppfh_id = ppfd.ppfh_id(+)
     and ppfh.ppfh_id = pfqpp.ppfh_id(+)
     and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
     and pcm.corporate_id = akc.corporate_id
     and pcm.trader_id = akcu.user_id(+)
     and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
     and pcpd.strategy_id = css.strategy_id
     and pcpd.profit_center_id = cpc.profit_center_id
     and pcpd.product_id = pdm.product_id
     and akc.base_cur_id = cm_base.cur_id
     and pocd.pay_in_cur_id = cm_pay.cur_id
     and pfd.price_unit_id = ppu.product_price_unit_id(+)
     and ppu.price_unit_id = pum.price_unit_id(+)
     and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
     and pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no
     and pcm.cp_id = phd.profileid
     and pcbpd.price_basis <> 'Fixed'
     and pcpd.input_output = 'Input'
     and pcdi.is_active = 'Y'
     and pcm.is_active = 'Y'
     and nvl(gmr.is_deleted, 'N') = 'N'
     and pcm.contract_status <> 'Cancelled'
     and pcm.contract_type = 'BASEMETAL'
     and poch.is_active = 'Y'
     and pocd.is_active = 'Y'
     and pofh.is_active(+) = 'Y'
     and pcbpd.is_active = 'Y'
     and ppfh.is_active(+) = 'Y'
     and pfqpp.is_active(+) = 'Y'
     and pfd.is_hedge_correction = 'Y'
     /*and akc.corporate_id = '{?CorporateID}'
     and pfd.hedge_correction_date = to_date('{?AsOfDate}', 'dd-Mon-yyyy')*/
union all
-- Hedge Correction + Concentrate:
select
         akc.corporate_id,
         akc.corporate_name,
         'Hedge Correction' section,
         7 section_id,
         cpc.profit_center_id,
         cpc.profit_center_short_name profit_center,
         pdm_under.product_id,
         pdm_under.product_desc product,
         pcm.contract_type product_type,
         'Y' is_base_metal,
         'N' is_concentrate,
         ppfd.exchange_id,
         ppfd.exchange_name exchange,
         css.strategy_id,
         css.strategy_name strategy,
         decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
         poch.element_id,
         aml.attribute_name element_name,
         pfd.as_of_date trade_date,
         pcm.contract_ref_no,
         pcm.contract_type,
         pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
         gmr.gmr_ref_no gmr_no,
         ((case
            when pcdi.basis_type = 'Arrival' then
                  (case
                   when pcdi.delivery_period_type = 'Date' then
                   pcdi.delivery_to_date
                   else
                   last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                   pcdi.delivery_to_year,'dd-Mon-yyyy'))
                   end) else(case
                   when pcdi.delivery_period_type = 'Date' then
                   pcdi.delivery_to_date
                   else
                   last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                   pcdi.delivery_to_year,'dd-Mon-yyyy'))
                   end) + pcdi.transit_days end))expected_delivery,
         null quality,
         ppfh.formula_description formula,
         null premimum,
         pum.price_unit_id,
         pum.price_unit_name price_unit,
         decode(pcm.purchase_sales, 'P', 1, 'S', -1)*pfd.qty_fixed*
                                         pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                                                  pdm.product_id),
                                                                                  qum.qty_unit_id,
                                                                                  nvl(pdm_under.base_quantity_unit,
                                                                                  pdm.base_quantity_unit),
                                                                                  1)  qty,
         qum_under.qty_unit_id,
         qum_under.qty_unit,
         qum_under.decimals qty_decimals,
         null instrument,
         null prompt_date,
         null lots,
         (nvl(pfd.user_price,0)+nvl(pfd.adjustment_price,0)) price,
         cm_pay.cur_code pay_in_ccy,
    (case
     when pfd.is_hedge_correction_during_qp = 'Y' then
      'Within QP'
     else
      'After QP'
         end) sub_section,
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
         null smelter
    from pcdi_pc_delivery_item          pcdi,
         pcm_physical_contract_main     pcm,
         poch_price_opt_call_off_header poch,
         aml_attribute_master_list aml,
         pdm_productmaster pdm_under,
         qum_quantity_unit_master qum_under,
         pocd_price_option_calloff_dtls pocd,
         pofh_price_opt_fixation_header pofh,
         pfd_price_fixation_details     pfd,
         pcbpd_pc_base_price_detail     pcbpd,
         ppfh_phy_price_formula_header  ppfh,
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
         pfqpp_phy_formula_qp_pricing   pfqpp,
         gmr_goods_movement_record      gmr,
         ak_corporate                   akc,
         ak_corporate_user              akcu,
         pcpd_pc_product_definition     pcpd,
         css_corporate_strategy_setup   css,
         cpc_corporate_profit_center    cpc,
         pdm_productmaster              pdm,
         cm_currency_master             cm_base,
         cm_currency_master             cm_pay,
         v_ppu_pum                      ppu,
         pum_price_unit_master          pum,
         qum_quantity_unit_master       qum,
         axs_action_summary             axs,
         phd_profileheaderdetails       phd
   where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
     and pcdi.pcdi_id = poch.pcdi_id
     and poch.element_id = aml.attribute_id
     and aml.underlying_product_id = pdm_under.product_id(+)
     and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
     and poch.poch_id = pocd.poch_id
     and pocd.pocd_id = pofh.pocd_id
     and pofh.pofh_id = pfd.pofh_id
     and pocd.pcbpd_id = pcbpd.pcbpd_id
     and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
     and ppfh.ppfh_id = ppfd.ppfh_id(+)
     and ppfh.ppfh_id = pfqpp.ppfh_id(+)
     and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
     and pcm.corporate_id = akc.corporate_id
     and pcm.trader_id = akcu.user_id(+)
     and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
     and pcpd.strategy_id = css.strategy_id
     and pcpd.profit_center_id = cpc.profit_center_id
     and pcpd.product_id = pdm.product_id
     and akc.base_cur_id = cm_base.cur_id
     and pocd.pay_in_cur_id = cm_pay.cur_id
     and pfd.price_unit_id = ppu.product_price_unit_id(+)
     and ppu.price_unit_id = pum.price_unit_id(+)
     and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
     and pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no
     and pcm.cp_id = phd.profileid
     and pcbpd.price_basis <> 'Fixed'
     and pcpd.input_output = 'Input'
     and pcdi.is_active = 'Y'
     and pcm.is_active = 'Y'
     and nvl(gmr.is_deleted, 'N') = 'N'
     and pcm.contract_status <> 'Cancelled'
     and pcm.contract_type = 'CONCENTRATES'
     and poch.is_active = 'Y'
     and pocd.is_active = 'Y'
     and pofh.is_active(+) = 'Y'
     and pcbpd.is_active = 'Y'
     and ppfh.is_active(+) = 'Y'
     and pfqpp.is_active(+) = 'Y'
     and pfd.is_hedge_correction = 'Y'

