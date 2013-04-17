
ALTER TABLE gpah_gmr_price_alloc_header  ADD  ( internal_pledge_gmr_ref_no    VARCHAR2(15 CHAR)  NULL);


ALTER TABLE gpah_gmr_price_alloc_header ADD (
  CONSTRAINT fk_gpad_pld_igmr_no
 FOREIGN KEY (internal_pledge_gmr_ref_no)
 REFERENCES gmr_goods_movement_record (internal_gmr_ref_no));
 
 
 ALTER TABLE PFD_PRICE_FIXATION_DETAILS  ADD  ( internal_pledge_gmr_ref_no    VARCHAR2(15 CHAR)  NULL);

ALTER TABLE PFD_PRICE_FIXATION_DETAILS ADD (
  CONSTRAINT fk_pfd_pld_igmr_no
 FOREIGN KEY (internal_pledge_gmr_ref_no)
 REFERENCES gmr_goods_movement_record (internal_gmr_ref_no));