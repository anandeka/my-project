create or replace view v_gmr_exchange_detail as
SELECT   pcbpd.process_id, pofh.internal_gmr_ref_no, ppfd.instrument_id,
            dim.instrument_name, pdd.derivative_def_id,
            pdd.derivative_def_name, emt.exchange_id, emt.exchange_name,
            pcbpd.element_id, pofh.qty_to_be_fixed, pofh.pofh_id,
            pofh.pocd_id, pofh.no_of_prompt_days, pofh.per_day_pricing_qty,
            ROUND (NVL (pofh.priced_qty, 0), 5) priced_qty,
            ROUND (pofh.qty_to_be_fixed - ROUND (NVL (pofh.priced_qty, 0), 5),
                   5
                  ) unpriced_qty,
            pofh.qp_start_date, pofh.qp_end_date
       FROM pofh_price_opt_fixation_header pofh,
            pocd_price_option_calloff_dtls pocd,
            pcbpd_pc_base_price_detail pcbpd,
            ppfh_phy_price_formula_header ppfh,
            ppfd_phy_price_formula_details ppfd,
            dim_der_instrument_master dim,
            pdd_product_derivative_def pdd,
            emt_exchangemaster emt
      WHERE pofh.pocd_id = pocd.pocd_id
        AND pocd.pcbpd_id = pcbpd.pcbpd_id
        AND pcbpd.pcbpd_id = ppfh.pcbpd_id
        AND ppfh.ppfh_id = ppfd.ppfh_id
        AND pcbpd.process_id = ppfh.process_id
        AND ppfh.process_id = ppfd.process_id
        AND ppfd.instrument_id = dim.instrument_id
        AND dim.product_derivative_id = pdd.derivative_def_id
        AND pdd.exchange_id = emt.exchange_id(+)
        AND pofh.internal_gmr_ref_no IS NOT NULL
        AND pofh.is_active = 'Y'
        AND pocd.is_active = 'Y'
        AND pcbpd.is_active = 'Y'
        AND ppfh.is_active = 'Y'
        AND ppfd.is_active = 'Y'
   GROUP BY pcbpd.process_id,
            pofh.internal_gmr_ref_no,
            ppfd.instrument_id,
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
            pofh.qp_end_date;