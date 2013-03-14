create or replace view v_projected_price_exposure as
with pfqpp_table as (select pci.pcdi_id,
       pcbph.internal_contract_ref_no,
       pfqpp.qp_pricing_period_type,
       pfqpp.qp_period_from_date,
       pfqpp.qp_period_to_date,
       pfqpp.qp_month,
       pfqpp.qp_year,
       pfqpp.qp_date,
       pfqpp.is_qp_any_day_basis,
       pfqpp.event_name,
       pfqpp.no_of_event_months,
       ppfh.ppfh_id,
       ppfh.formula_description,
       pfqpp.is_spot_pricing,
       pcbpd.pcbpd_id
  from pci_physical_contract_item    pci,
       pcipf_pci_pricing_formula     pcipf,
       pcbph_pc_base_price_header    pcbph,
       pcbpd_pc_base_price_detail    pcbpd,
       ppfh_phy_price_formula_header ppfh,
       pfqpp_phy_formula_qp_pricing  pfqpp
 where pci.internal_contract_item_ref_no =
       pcipf.internal_contract_item_ref_no
   and pcipf.pcbph_id = pcbph.pcbph_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.pcbpd_id = pcbpd.pcbpd_id
   and ppfh.is_active = 'Y'
   and pfqpp.is_active = 'Y'
   and pci.is_active = 'Y'
   and pcipf.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and pcbph.is_active = 'Y'
 group by pci.pcdi_id,
          pcbph.internal_contract_ref_no,
          pcbpd.price_basis,
          pcbpd.price_value,
          pcbpd.price_unit_id,
          pcbpd.tonnage_basis,
          pcbpd.fx_to_base,
          pcbpd.qty_to_be_priced,
          pcbph.price_description,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_date,
          pfqpp.event_name,
          pfqpp.no_of_event_months,
          is_qp_any_day_basis,
          ppfh.price_unit_id,
          ppfh.ppfh_id,
          ppfh.formula_description,
          pfqpp.is_spot_pricing,
       pcbpd.pcbpd_id),
pofh_header_data as
        (select *
           from pofh_price_opt_fixation_header pofh
          where pofh.internal_gmr_ref_no is null
            and pofh.qty_to_be_fixed is not null
            and pofh.is_active = 'Y'),
        pfd_fixation_data as
        (select   pfd.pofh_id,
                  round (sum (nvl (pfd.qty_fixed, 0)), 5) qty_fixed
             from pfd_price_fixation_details pfd
            where pfd.is_active = 'Y'
            and pfd.is_exposure='Y'
         group by pfd.pofh_id),
ppfd as
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
                  emt.exchange_name),
--Adding code  on 22nd Feb 2013         ::Raj               
pcbpd_id_wise_str_dt_info as(
    select * from table(f_get_pricing_mth_strt_end_dt))
--End of code on 22nd Feb 2013                                  
--1 Any Day Pricing Base Metal +Contract + Not Called Off + Excluding Event Based          
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
         to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year)
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end)   qp_start_date,
       to_char((case
         when pfqpp.qp_pricing_period_type = 'Month' then
         last_day(to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year))
        when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_to_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end),'dd-Mon-yyyy')   qp_end_date,
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
       --qat.quality_name quality,
       null          quality,     
       pfqpp.formula_description formula,
       vp.premium,       
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (
        nvl(diqs.open_qty,0) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1))
                                              qty,
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
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       ppfd ppfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp, 
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no  
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pfqpp.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
     and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
union all
-- 2 Any Day Pricing Base Metal +Contract + Not Called Off + Event Based
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,       
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       di.expected_qp_start_date  qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy')   qp_end_date,
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
       --qat.quality_name quality,
       null          quality,     
       pfqpp.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (
        nvl(diqs.open_qty,0) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             qum.qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1))
                                              qty,
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
       di_del_item_exp_qp_details di,
       diqs_delivery_item_qty_status diqs,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       ppfd ppfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp, 
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id=di.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and di.is_active='Y'
   and pfqpp.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type =  'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   union all
-- 3 Any Day Pricing Base Metal +Contract + Called Off + Not Applicable
 select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,       
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,       
       --f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       pstrt.start_date qp_start_date,
--       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,       
       to_char(pstrt.end_date,'dd-Mon-rrrr') qp_end_date,
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
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,       
       vp.premium,
       null price_unit_id,
       null price_unit,       
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
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       pofh_header_data pofh,
       ppfd ppfd,
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp,
       pfqpp_table pfqpp,
       qum_quantity_unit_master qum,
       pcbpd_id_wise_str_dt_info pstrt
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   --and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
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
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pfqpp.pcdi_id=pcdi.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and pocd.pcbpd_id = pstrt.pcbpd_id(+)
   and pocd.poch_id = pstrt.poch_id(+)
union all
-- 4 Any Day Pricing Base Metal +GMR
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
       null quality,
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
       --pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       cpc_corporate_profit_center cpc,
       vd_voyage_detail vd,
       pfqpp_table  pfqpp,
       v_pci_multiple_premium vp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id
 and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
 --and pcdi.pcdi_id = pcdiqd.pcdi_id
 and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
 and pcpd.strategy_id = css.strategy_id
 and pdm.product_id = pcpd.product_id
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
 and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
 and pfqpp.pcdi_id=pcdi.pcdi_id
 and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
 and nvl(vd.status, 'NA') in ('Active', 'NA')
 and ppfh.ppfh_id = pfqpp.ppfh_id
 and ppfh.ppfh_id = ppfd.ppfh_id
 and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
 and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
 and pdm.base_quantity_unit = qum.qty_unit_id
 and pcm.is_active = 'Y'
 and pcm.contract_type = 'BASEMETAL'
 and pcm.approval_status = 'Approved'
 and pcdi.is_active = 'Y'
 and gmr.is_deleted = 'N'
 and pdm.is_active = 'Y'
 and qum.is_active = 'Y'
 and pofh.is_active = 'Y'
 and poch.is_active = 'Y'
 and pocd.is_active = 'Y'
 and ppfh.is_active = 'Y'
 and pfd.is_exposure='Y'
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
          pcdi.price_option_call_off_status
   union all
-- 5 Average Pricing Base Metal+Contract + Not Called Off + Excluding Event Based
select   ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
      (case
         when pfqpp.qp_pricing_period_type = 'Month' then
         to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year)
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end)   qp_start_date,
       to_char((case
         when pfqpp.qp_pricing_period_type = 'Month' then
         last_day(to_date('01-'|| pfqpp.qp_month || ' - ' || pfqpp.qp_year))
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_to_date
         when pfqpp.qp_pricing_period_type = 'Date' then
          pfqpp.qp_date
       end),'dd-Mon-yyyy')   qp_end_date,
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
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
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
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(diqs.open_qty,0) *
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
       diqs_delivery_item_qty_status diqs,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       pfqpp_table pfqpp,    
       ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'   
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'  
   and ppfh.is_active = 'Y' 
-- 6 Average Pricing Base Metal+Contract + Not Called Off + Event Based
union all
select   ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       di.expected_qp_start_date qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy') qp_end_date,
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
       null trade_date,
       pfqpp.no_of_event_months || ' ' || pfqpp.event_name qp_options,
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
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       nvl(diqs.open_qty,0) *
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
       diqs_delivery_item_qty_status diqs,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       di_del_item_exp_qp_details di,
       pfqpp_table pfqpp,    
       ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc,
       v_pci_multiple_premium vp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.is_active = 'Y'
   and pcdi.pcdi_id = di.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+) 
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type = 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'  
   and ppfh.is_active = 'Y' 
 union all 
-- 7 Average Pricing Base Metal+Contract + Called Off + Not Applicable
   select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,       
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       --f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       pstrt.start_date qp_start_date,
--       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,       
       to_char(pstrt.end_date,'dd-Mon-rrrr') qp_end_date,
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
       --qat.quality_name quality,
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (nvl(pofh.per_day_hedge_correction_qty,0)+ nvl(pofh.per_day_pricing_qty,0)) *
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
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,      
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table pfqpp,
       ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       qum_quantity_unit_master qum,
       pofh_header_data pofh,
       cpc_corporate_profit_center cpc,
       --pfqpp_phy_formula_qp_pricing pfqpp,
       v_pci_multiple_premium vp,
       pcbpd_id_wise_str_dt_info pstrt
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id   
   and pcpd.strategy_id = css.strategy_id   
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id=pocd.poch_id
   and pcm.internal_contract_ref_no = pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pocd.pocd_id = pofh.pocd_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'   
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'   
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y' 
   and pocd.pcbpd_id = pstrt.pcbpd_id(+)
    and pocd.poch_id = pstrt.poch_id(+)
-- 8 Average Pricing Base Metal+GMR
   union all
   select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
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
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (nvl(pofh.per_day_hedge_correction_qty,0)+ nvl(pofh.per_day_pricing_qty,0)) *
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
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table pfqpp,
       ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       qum_quantity_unit_master qum,
       vd_voyage_detail vd,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,       
       v_pci_multiple_premium vp
       
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id = pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id
   and ppfh.ppfh_id=ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pofh.internal_gmr_ref_no is not null
   and nvl(vd.status, 'NA') in ('NA', 'Active')  
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'   
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and gmr.is_deleted = 'N'
 -- 9 Fixed by Price Request Base Metal +Contract + Not Called Off + Excluding Event Based 8
 union all
 select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       --f_get_pricing_month_start_date(pfqpp.pcbpd_id) qp_start_date,
       pstrt.start_date qp_start_date,
       --f_get_pricing_month(pfqpp.pcbpd_id) qp_end_date,
       to_char(pstrt.end_date,'dd-Mon-rrrr') qp_end_date,
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
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
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
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * nvl(diqs.open_qty,0) *
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
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
      pcpd_pc_product_definition pcpd,
      pdm_productmaster pdm,
      css_corporate_strategy_setup css,
      pfqpp_table pfqpp,     
      ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum ,      
       pcbpd_id_wise_str_dt_info pstrt
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id   
  and ppfh.ppfh_id = ppfd.ppfh_id(+)
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pdm.base_quantity_unit
   and pfqpp.pcbpd_id = pstrt.pcbpd_id(+)
   and pstrt.poch_id is null
union all
-- 10 Fixed by Price Request Base Metal +Contract + Not Called Off + Event Based 9
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
      di.expected_qp_start_date qp_start_date,
       to_char(di.expected_qp_end_date,'dd-Mon-yyyy') qp_end_date,
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
       null trade_date,
       pfqpp.no_of_event_months || ' ' || pfqpp.event_name qp_options,
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
       null quality,
       ppfh.formula_description formula,
       vp.premium,
       null price_unit_id,
       null price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * nvl(diqs.open_qty,0) *
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
       pcdi_pc_delivery_item pcdi,
       di_del_item_exp_qp_details di,
       diqs_delivery_item_qty_status diqs,
      pcpd_pc_product_definition pcpd,
      pdm_productmaster pdm,
      css_corporate_strategy_setup css,
      pfqpp_table pfqpp,     
      ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum       
       
 where ak.corporate_id = pcm.corporate_id   
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = di.pcdi_id -- Newly Added
   and di.is_active = 'Y' 
   and pcdi.pcdi_id = diqs.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id=pfqpp.pcdi_id
   and pfqpp.ppfh_id=ppfh.ppfh_id   
  and  ppfh.ppfh_id = ppfd.ppfh_id(+)
  and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+) 
  and pcdi.pcdi_id = vp.pcdi_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.qp_pricing_period_type <> 'Event'
   and pcdi.price_option_call_off_status = 'Not Called Off'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pdm.base_quantity_unit
union all
--11 Fixed by Price Request Base Metal +Contract + Called Off + Not Applicable 10
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       --f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       pstrt.start_date qp_start_date,
       --f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       to_char(pstrt.end_date,'dd-Mon-rrrr') qp_end_date,
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
       null  quality,
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
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,       
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       
       ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       v_pci_multiple_premium vp,
       cpc_corporate_profit_center cpc,
       qum_quantity_unit_master qum,
       pfqpp_table pfqpp,
       pcbpd_id_wise_str_dt_info pstrt
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id=pdm.product_id
   and pcpd.strategy_id = css.strategy_id      
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pcm.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id = pfqpp.pcdi_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and pocd.pocd_id = pofh.pocd_id 
   and pofh.pofh_id = pfd.pofh_id
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and pofh.internal_gmr_ref_no is null
   and pofh.qty_to_be_fixed is not null   
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.price_option_call_off_status in ('Called Off','Not Applicable')
   and pfqpp.is_qp_any_day_basis = 'Y'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pfd.is_price_request = 'Y'
   and pfd.is_exposure='Y'
   and /*pfd.as_of_date*/pfd.hedge_correction_date > trunc(sysdate) --siva
   and pocd.pcbpd_id = pstrt.pcbpd_id(+)
    and pocd.poch_id = pstrt.poch_id(+)
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
          pstrt.start_date,
          to_char(pstrt.end_date,'dd-Mon-rrrr')
---- 12  Fixed by Price Request Base Metal +GMR 11
union all
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
       null quality,
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
       pcdi_pc_delivery_item pcdi,
       pcpd_pc_product_definition pcpd,       
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,      
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pfqpp_table  pfqpp,       
       ppfh_phy_price_formula_header ppfh,
       ppfd ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       gmr_goods_movement_record gmr,
       vd_voyage_detail vd,
       v_pci_multiple_premium vp,
       qum_quantity_unit_master qum,
       cpc_corporate_profit_center cpc
       
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no  = pcdi.internal_contract_ref_no
   and pcdi.internal_contract_ref_no  = pcpd.internal_contract_ref_no
   and pcpd.product_id = pdm.product_id
   and pcpd.strategy_id = css.strategy_id   
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id=pocd.poch_id
   and pcdi.internal_contract_ref_no=pfqpp.internal_contract_ref_no
   and pcdi.pcdi_id   = pfqpp.pcdi_id
   and pocd.pocd_id=pofh.pocd_id   
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is not null   
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and nvl(vd.status, 'NA') in ('NA', 'Active')   
   and pcpd.profit_center_id = cpc.profit_center_id   
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcdi.internal_contract_ref_no = vp.internal_contract_ref_no(+)
   and pcdi.pcdi_id = vp.pcdi_id(+)
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pfd.is_price_request = 'Y'
   and pfd.is_exposure='Y'
   and /*pfd.as_of_date*/pfd.hedge_correction_date > trunc(sysdate)
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
          pcdi.price_option_call_off_status 
