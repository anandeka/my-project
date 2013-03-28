
CREATE OR REPLACE FORCE VIEW v_gmr_exchange_detail 
AS
   SELECT   pofh.internal_gmr_ref_no,
            ppfd.instrument_id,
            dim.instrument_name,
            pdd.derivative_def_id,
            pdd.derivative_def_name,
            emt.exchange_id,
            emt.exchange_name,
            pcbpd.element_id
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
        AND ppfd.instrument_id = dim.instrument_id
        AND dim.product_derivative_id = pdd.derivative_def_id
        AND pdd.exchange_id = emt.exchange_id(+)
        AND pofh.internal_gmr_ref_no IS NOT NULL
        AND pofh.is_active = 'Y'
        AND pocd.is_active = 'Y'
        AND pcbpd.is_active = 'Y'
        AND ppfh.is_active = 'Y'
        AND ppfd.is_active = 'Y'
   GROUP BY pofh.internal_gmr_ref_no,
            ppfd.instrument_id,
            dim.instrument_name,
            pdd.derivative_def_id,
            pdd.derivative_def_name,
            emt.exchange_id,
            emt.exchange_name,
            pcbpd.element_id;

