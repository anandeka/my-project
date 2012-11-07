CREATE TABLE SBTBM_SHIPMENT_BTB_MAPPING
(
  INTERNAL_SBTBM_NO               VARCHAR2(15),
  PURCHASE_INT_GMR_REF_NO         VARCHAR2(15),
  SALES_INT_GMR_REF_NO            VARCHAR2(15),
  VERSION                         NUMBER(10)
)

ALTER TABLE SBTBM_SHIPMENT_BTB_MAPPING ADD (CONSTRAINT PK_SBTBM PRIMARY KEY(INTERNAL_SBTBM_NO));

ALTER TABLE sbtbm_shipment_btb_mapping  ADD CONSTRAINT fk_purchase_int_gmr_ref_no FOREIGN KEY (purchase_int_gmr_ref_no) REFERENCES gmr_goods_movement_record (internal_gmr_ref_no);

ALTER TABLE sbtbm_shipment_btb_mapping  ADD CONSTRAINT fk_sales_int_gmr_ref_no FOREIGN KEY (sales_int_gmr_ref_no) REFERENCES gmr_goods_movement_record (internal_gmr_ref_no);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD (IS_OPEN_BACK_TO_BACK  CHAR(1) DEFAULT 'N');


CREATE SEQUENCE SEQ_SBTBM
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;