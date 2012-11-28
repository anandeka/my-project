
ALTER TABLE pcbph_pc_base_price_header MODIFY(is_balance_pricing  CHAR(1 CHAR) DEFAULT 'N');

ALTER TABLE pfd_price_fixation_details MODIFY(is_balance_pricing  CHAR(1 CHAR) DEFAULT 'N',is_fx_by_request CHAR(1 CHAR) DEFAULT 'N',is_hedge_correction CHAR(1 CHAR) DEFAULT 'N',is_hedge_correction_during_qp CHAR(1 CHAR) DEFAULT 'N',is_cancel CHAR(1 CHAR) DEFAULT 'N');

ALTER TABLE poch_price_opt_call_off_header MODIFY(is_balance_pricing  CHAR(1 CHAR) DEFAULT 'N');

ALTER TABLE pcmte_pcm_tolling_ext MODIFY(is_free_metal_applicable CHAR(1 CHAR) DEFAULT 'N');

ALTER TABLE pcbpd_pc_base_price_detail MODIFY(is_fx_by_request CHAR(1 CHAR) DEFAULT 'N');

ALTER TABLE pcbpdul_pc_base_price_dtl_ul MODIFY(is_fx_by_request CHAR(1 CHAR) DEFAULT 'N');

ALTER TABLE pofh_price_opt_fixation_header MODIFY(is_provesional_assay_exist CHAR(1 CHAR) DEFAULT 'N');