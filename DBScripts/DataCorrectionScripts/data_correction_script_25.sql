
UPDATE pcbph_pc_base_price_header pcbph
   SET pcbph.is_balance_pricing = 'N'
 WHERE pcbph.is_balance_pricing IS NULL;

UPDATE pfd_price_fixation_details pfd
   SET pfd.is_balance_pricing = 'N'
 WHERE pfd.is_balance_pricing IS NULL;
 
 UPDATE pfd_price_fixation_details pfd
   SET pfd.is_fx_by_request = 'N'
 WHERE pfd.is_fx_by_request IS NULL;
 
  UPDATE pfd_price_fixation_details pfd
   SET pfd.is_hedge_correction = 'N'
 WHERE pfd.is_hedge_correction IS NULL;

 UPDATE pfd_price_fixation_details pfd
   SET pfd.is_hedge_correction_during_qp = 'N'
 WHERE pfd.is_hedge_correction_during_qp IS NULL;
 
  UPDATE pfd_price_fixation_details pfd
   SET pfd.is_cancel = 'N'
 WHERE pfd.is_cancel IS NULL;
 
 UPDATE poch_price_opt_call_off_header poch
   SET poch.is_balance_pricing = 'N'
 WHERE poch.is_balance_pricing IS NULL;

UPDATE pcmte_pcm_tolling_ext pcmte
   SET pcmte.is_free_metal_applicable = 'N'
 WHERE pcmte.is_free_metal_applicable IS NULL;

UPDATE pcbpd_pc_base_price_detail pcbpd
   SET pcbpd.is_fx_by_request = 'N'
 WHERE pcbpd.is_fx_by_request IS NULL;

UPDATE pcbpdul_pc_base_price_dtl_ul pcbpd_ul
   SET pcbpd_ul.is_fx_by_request = 'N'
 WHERE pcbpd_ul.is_fx_by_request IS NULL;

UPDATE pofh_price_opt_fixation_header pofh
   SET pofh.is_provesional_assay_exist = 'N'
 WHERE pofh.is_provesional_assay_exist IS NULL;
 
 