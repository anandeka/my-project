UPDATE pocd_price_option_calloff_dtls pocd
   SET pocd.fx_conversion_method =
          (SELECT fx_conversion_method
             FROM pcbpd_pc_base_price_detail pcbpd,
                  pffxd_phy_formula_fx_details pffxd
            WHERE pcbpd.pffxd_id = pffxd.pffxd_id
              AND pffxd.fx_conversion_method IS NOT NULL
              AND pcbpd.pcbpd_id = pocd.pcbpd_id)
 WHERE pocd.pay_in_cur_id != pocd.pricing_cur_id;



/* Formatted on 2012/08/30 16:54 (Formatter Plus v4.8.8) */
UPDATE pfd_price_fixation_details pfd_out
   SET pfd_out.hedge_amount =
          (SELECT pfd.qty_fixed * ucm.multiplication_factor * pfd.user_price
             FROM pocd_price_option_calloff_dtls pocd,
                  pofh_price_opt_fixation_header pofh,
                  pfd_price_fixation_details pfd,
                  ppu_product_price_units ppu,
                  pum_price_unit_master pum,
                  ucm_unit_conversion_master ucm
            WHERE pocd.pocd_id = pofh.pocd_id
              AND pofh.pofh_id = pfd.pofh_id
              AND pfd.is_hedge_correction = 'N'
              AND pofh.is_active = 'Y'
              AND ppu.internal_price_unit_id = pfd.price_unit_id
              AND pum.price_unit_id = ppu.price_unit_id
              AND ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
              AND ucm.to_qty_unit_id = pum.weight_unit_id
              AND pocd.fx_conversion_method IS NULL
              AND pfd.is_hedge_correction = 'N'
              AND pfd.hedge_amount IS NULL
              AND pfd.user_price IS NOT NULL
              and pfd_out.pfd_id =PFD.PFD_ID)
   where PFD_out.POFH_ID IN(SELECT distinct POFH.POFH_ID
             FROM pocd_price_option_calloff_dtls pocd,
                  pofh_price_opt_fixation_header pofh,
                  pfd_price_fixation_details pfd,
                  ppu_product_price_units ppu,
                  pum_price_unit_master pum,
                  ucm_unit_conversion_master ucm
            WHERE pocd.pocd_id = pofh.pocd_id
              AND pofh.pofh_id = pfd.pofh_id
              AND pfd.is_hedge_correction = 'N'
              AND pofh.is_active = 'Y'
              AND ppu.internal_price_unit_id = pfd.price_unit_id
              AND pum.price_unit_id = ppu.price_unit_id
              AND ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
              AND ucm.to_qty_unit_id = pum.weight_unit_id
              AND pocd.fx_conversion_method IS NULL
              AND pfd.is_hedge_correction = 'N'
              AND pfd.hedge_amount IS NULL
              AND pfd.user_price IS NOT NULL
              --and pfd_out.pfd_id =PFD.PFD_ID
              ) 
              and PFD_OUT.IS_HEDGE_CORRECTION='N';   






UPDATE pfd_price_fixation_details pfd_out
   SET pfd_out.hedge_amount =
          (SELECT   pfd.qty_fixed
                  * ucm.multiplication_factor
                  * pfd.user_price
                  * pfd.fx_rate
             FROM pocd_price_option_calloff_dtls pocd,
                  pofh_price_opt_fixation_header pofh,
                  pfd_price_fixation_details pfd,
                  ppu_product_price_units ppu,
                  pum_price_unit_master pum,
                  ucm_unit_conversion_master ucm
            WHERE pocd.pocd_id = pofh.pocd_id
              AND pofh.pofh_id = pfd.pofh_id
              AND pfd.is_hedge_correction = 'N'
              AND pofh.is_active = 'Y'
              AND ppu.internal_price_unit_id = pfd.price_unit_id
              AND pum.price_unit_id = ppu.price_unit_id
              AND ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
              AND ucm.to_qty_unit_id = pum.weight_unit_id
              AND pocd.fx_conversion_method IS NOT NULL
              AND pfd.is_hedge_correction = 'N'
              AND pfd.hedge_amount IS NOT NULL
              AND pfd.user_price IS NOT NULL
              AND pfd.fx_rate IS NOT NULL
              AND pfd_out.pfd_id = pfd.pfd_id)
 WHERE pfd_out.pofh_id IN (
          SELECT DISTINCT pofh.pofh_id
                     FROM pocd_price_option_calloff_dtls pocd,
                          pofh_price_opt_fixation_header pofh,
                          pfd_price_fixation_details pfd,
                          ppu_product_price_units ppu,
                          pum_price_unit_master pum,
                          ucm_unit_conversion_master ucm
                    WHERE pocd.pocd_id = pofh.pocd_id
                      AND pofh.pofh_id = pfd.pofh_id
                      AND pfd.is_hedge_correction = 'N'
                      AND pofh.is_active = 'Y'
                      AND ppu.internal_price_unit_id = pfd.price_unit_id
                      AND pum.price_unit_id = ppu.price_unit_id
                      AND ucm.from_qty_unit_id = pocd.qty_to_be_fixed_unit_id
                      AND ucm.to_qty_unit_id = pum.weight_unit_id
                      AND pocd.fx_conversion_method IS NOT NULL
                      AND pfd.is_hedge_correction = 'N'
                      AND pfd.hedge_amount IS NOT NULL
                      AND pfd.user_price IS NOT NULL
                      AND pfd.fx_rate IS NOT NULL
                                                 --and pfd_out.pfd_id =PFD.PFD_ID
       )
   AND pfd_out.is_hedge_correction = 'N';          