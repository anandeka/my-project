create or replace view v_gmr_exchange_details as
select pofh.internal_gmr_ref_no,
       poch.pcdi_id,
       pofh.pocd_id,
       poch.element_id,
       ppfd.instrument_id,
       dim.instrument_name,
       pdd.derivative_def_id,
       pdd.derivative_def_name,
       emt.exchange_id,
       emt.exchange_name,
       --       pcbpd.element_id,
       pofh.qty_to_be_fixed,
       pofh.pofh_id,
       pofh.pocd_id,
       pofh.no_of_prompt_days,
       pofh.per_day_pricing_qty,
       round(nvl(pofh.priced_qty, 0), 5) priced_qty,
       round(pofh.qty_to_be_fixed - round(nvl(pofh.priced_qty, 0), 5), 5) unpriced_qty,
       pofh.qp_start_date,
       pofh.qp_end_date,
       pocd.qty_to_be_fixed_unit_id qty_fixation_unit_id
  from pofh_price_opt_fixation_header pofh,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       pdd_product_derivative_def     pdd,
       emt_exchangemaster             emt,
       poch_price_opt_call_off_header poch
 where pofh.pocd_id = pocd.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.exchange_id = emt.exchange_id(+)
   and pofh.internal_gmr_ref_no is not null
   and pocd.poch_id = poch.poch_id
   and pofh.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
 group by pofh.internal_gmr_ref_no,
          pocd.qty_to_be_fixed_unit_id,
          poch.element_id,
          ppfd.instrument_id,
          pocd.element_id,
          poch.pcdi_id,
          dim.instrument_name,
          pdd.derivative_def_id,
          pdd.derivative_def_name,
          emt.exchange_id,
          emt.exchange_name,
          pcbpd.element_id,
          pofh.qty_to_be_fixed,
          pofh.pofh_id,
          pofh.pocd_id,
          pofh.no_of_prompt_days,
          pofh.per_day_pricing_qty,
          pofh.priced_qty,
          pofh.qty_to_be_fixed,
          pofh.priced_qty,
          pofh.qp_start_date,
          pofh.qp_end_date