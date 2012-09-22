update cs_cost_store cs set cs.income_expense='Expense' where cs.cost_type='Estimate';


UPDATE pfd_price_fixation_details pfd
   SET pfd.hedge_correction_date = pfd.as_of_date,
       pfd.fx_correction_date = pfd.as_of_date
 WHERE pfd.pofh_id IN (
          SELECT pofh.pofh_id
            FROM pocd_price_option_calloff_dtls pocd,
                 pofh_price_opt_fixation_header pofh
           WHERE pocd.pocd_id = pofh.pocd_id
             AND pocd.fx_conversion_method IS NULL)
   AND pfd.user_price IS NOT NULL
   AND (pfd.fx_correction_date IS NULL OR pfd.hedge_correction_date IS NULL);


UPDATE pfd_price_fixation_details pfd
   SET pfd.hedge_correction_date = pfd.as_of_date,
       pfd.fx_correction_date = pfd.as_of_date
 WHERE pfd.pofh_id IN (
          SELECT pofh.pofh_id
            FROM pocd_price_option_calloff_dtls pocd,
                 pofh_price_opt_fixation_header pofh
           WHERE pocd.pocd_id = pofh.pocd_id
             AND pocd.fx_conversion_method IS NOT NULL)
   AND pfd.user_price IS NOT NULL
   AND (pfd.fx_correction_date IS NULL OR pfd.hedge_correction_date IS NULL)
   AND pfd.fx_rate IS NOT NULL
   AND pfd.fx_fixation_date IS NULL;