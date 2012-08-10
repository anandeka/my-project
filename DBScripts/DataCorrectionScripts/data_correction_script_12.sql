/* Formatted on 2012/08/10 14:37 (Formatter Plus v4.8.8) */
UPDATE pfd_price_fixation_details pfd
   SET pfd.hedge_amount =
            pkg_general.f_get_converted_quantity
                                (NULL,
                                 (SELECT pocd.qty_to_be_fixed_unit_id
                                    FROM pofh_price_opt_fixation_header pofh,
                                         pocd_price_option_calloff_dtls pocd
                                   WHERE pocd.pocd_id = pofh.pocd_id
                                     AND pofh.pofh_id = pfd.pofh_id),
                                 (SELECT pum.weight_unit_id
                                    FROM pofh_price_opt_fixation_header pofh,
                                         pocd_price_option_calloff_dtls pocd,
                                         ppu_product_price_units ppu,
                                         pum_price_unit_master pum
                                   WHERE pocd.pocd_id = pofh.pocd_id
                                     AND pofh.pofh_id = pfd.pofh_id
                                     AND ppu.internal_price_unit_id =
                                                     pocd.pay_in_price_unit_id
                                     AND ppu.price_unit_id = pum.price_unit_id),
                                 pfd.qty_fixed
                                )
          * pfd.user_price
          * NVL (pfd.fx_rate, 1)
 WHERE 
 PFD.HEDGE_AMOUNT IS NULL 
 
 and PFD.POFH_ID IN (select POFH.POFH_ID from POFH_PRICE_OPT_FIXATION_HEADER pofh,POCD_PRICE_OPTION_CALLOFF_DTLS pocd
 where POCD.pocd_id = pofh.pocd_id and POCD.FX_CONVERSION_METHOD is null);