CREATE TABLE ipd_inv_premium_detail
(
  ipd_id                VARCHAR2(15 CHAR),
  internal_invoice_ref_no  VARCHAR2(15 CHAR),
  internal_gmr_ref_no      VARCHAR2(15 CHAR),
  pcdi_id                  VARCHAR2(15 CHAR),
  gmr_ref_no               VARCHAR2(50 CHAR),
  quantity               NUMBER(25,10),
  amount                 NUMBER(25,10),
  premium                  NUMBER(25,10),
  amount_cur_id            VARCHAR2(15 CHAR),
  amount_cur_name            VARCHAR2(30 CHAR),
  qty_unit_id            VARCHAR2(15 CHAR),
  qty_unit_name            VARCHAR2(30 CHAR),
  premium_price_unit_id            VARCHAR2(15 CHAR),
  premium_price_unit_name            VARCHAR2(30 CHAR),
  premium_name              VARCHAR2(50 CHAR)
  );

CREATE SEQUENCE SEQ_IPD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;

ALTER TABLE is_invoice_summary ADD total_premium_amount NUMBER(25,10);