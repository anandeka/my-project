alter table PFD_PRICE_FIXATION_DETAILS add HEDGE_CORRECTION_ID varchar2(30);
            
 alter table ASH_ASSAY_HEADER add(CONSTRAINT fk_ash_internal_gmr_ref_no FOREIGN KEY     
  (internal_gmr_ref_no) REFERENCES gmr_goods_movement_record (internal_gmr_ref_no),
      CONSTRAINT fk_internal_contract_ref_no FOREIGN KEY(internal_contract_ref_no) REFERENCES 
      PCM_PHYSICAL_CONTRACT_MAIN(internal_contract_ref_no));
