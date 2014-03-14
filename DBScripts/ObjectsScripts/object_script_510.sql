CREATE TABLE gld_gmr_link_detail
(
  gld_id                            VARCHAR2(15)     NOT NULL,
  internal_action_ref_no            VARCHAR2(15)     NOT NULL,
  activity_ref_no                   VARCHAR2(30)     NOT NULL,
  activity_date                     TIMESTAMP(6)     NOT NULL,
  product_id                        VARCHAR2(15)     NOT NULL,
  product_name                      VARCHAR2(200)    NOT NULL,
  quality_id                        VARCHAR2(15)     NOT NULL,
  quality_name                      VARCHAR2(50)     NOT NULL,
  source_internal_gmr_ref_no        VARCHAR2(15)     NOT NULL,
  source_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  source_int_contract_ref_no        VARCHAR2(30)     NOT NULL,
  source_contract_ref_no            VARCHAR2(50)     NOT NULL,
  source_int_contract_item_no       VARCHAR2(15)     NOT NULL,
  source_contract_item_ref_no       VARCHAR2(50)     NOT NULL,
  source_contract_type              CHAR(1)          NOT NULL,
  source_corporate_id               VARCHAR2(15)     NOT NULL,
  target_internal_gmr_ref_no        VARCHAR2(15)     NOT NULL,
  target_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  target_int_contract_ref_no        VARCHAR2(30)     NOT NULL,
  target_contract_ref_no            VARCHAR2(50)     NOT NULL,
  target_int_contract_item_no       VARCHAR2(15)     NOT NULL,
  target_contract_item_ref_no       VARCHAR2(50)     NOT NULL,
  target_contract_type              CHAR(1)          NOT NULL,
  target_corporate_id               VARCHAR2(15)     NOT NULL,
  is_active                         CHAR(1)          DEFAULT 'Y'                   NOT NULL,
  created_by                        VARCHAR2(15),
  created_date                      TIMESTAMP(6),
  updated_by                        VARCHAR2(15),
  updated_date                      TIMESTAMP(6),
  VERSION                           NUMBER(10)
);

ALTER TABLE gld_gmr_link_detail ADD (
  CONSTRAINT gld_pk
 PRIMARY KEY
 (gld_id));

ALTER  TABLE gld_gmr_link_detail ADD (
  CONSTRAINT fk_gld_action_ref_no
 FOREIGN KEY (internal_action_ref_no)
 REFERENCES axs_action_summary (internal_action_ref_no));


CREATE  SEQUENCE seq_gld
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

CREATE TABLE gldl_gmr_link_detail_log
(
  gld_id                            VARCHAR2(15)     NOT NULL,
  internal_action_ref_no            VARCHAR2(15)     NOT NULL,
  activity_ref_no                   VARCHAR2(30)     NOT NULL,
  activity_date                     TIMESTAMP(6)     NOT NULL,
  product_id                        VARCHAR2(15)     NOT NULL,
  product_name                      VARCHAR2(200)    NOT NULL,
  quality_id                        VARCHAR2(15)     NOT NULL,
  quality_name                      VARCHAR2(50)     NOT NULL,
  source_internal_gmr_ref_no        VARCHAR2(15)     NOT NULL,
  source_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  source_int_contract_ref_no        VARCHAR2(30)     NOT NULL,
  source_contract_ref_no            VARCHAR2(50)     NOT NULL,
  source_int_contract_item_no       VARCHAR2(15)     NOT NULL,
  source_contract_item_ref_no       VARCHAR2(50)     NOT NULL,
  source_contract_type              CHAR(1)          NOT NULL,
  source_corporate_id               VARCHAR2(15)     NOT NULL,
  target_internal_gmr_ref_no        VARCHAR2(15)     NOT NULL,
  target_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  target_int_contract_ref_no        VARCHAR2(30)     NOT NULL,
  target_contract_ref_no            VARCHAR2(50)     NOT NULL,
  target_int_contract_item_no       VARCHAR2(15)     NOT NULL,
  target_contract_item_ref_no       VARCHAR2(50)     NOT NULL,
  target_contract_type              CHAR(1)          NOT NULL,
  target_corporate_id               VARCHAR2(15)     NOT NULL,
  is_active                         CHAR(1)          DEFAULT 'Y'                   NOT NULL,
  created_by                        VARCHAR2(15 CHAR),
  created_date                      TIMESTAMP(6),
  updated_by                        VARCHAR2(15 CHAR),
  updated_date                      TIMESTAMP(6),
  VERSION                           NUMBER(10),
  entry_type                        VARCHAR2(30)     NOT NULL
);

CREATE TABLE glsm_gmr_link_stock_mapping
(
  glsm_id                           VARCHAR2(15)     NOT NULL,
  gld_id                            VARCHAR2(15)     NOT NULL,
  internal_action_ref_no            VARCHAR2(15)     NOT NULL,
  source_internal_gmr_ref_no        VARCHAR2(15)     NOT NULL,
  source_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  source_internal_stock_ref_no      VARCHAR2(15)     NOT NULL,
  source_stock_ref_no               VARCHAR2(30)     NOT NULL,
  source_stock_qty                  NUMBER (25,10)   NOT NULL,
  source_stock_unit_id              VARCHAR2 (15)    NOT NULL,
  target_internal_gmr_ref_no        VARCHAR2(15)     NOT NULL,
  target_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  target_internal_stock_ref_no      VARCHAR2(15)     NOT NULL,
  target_stock_ref_no               VARCHAR2(30)     NOT NULL,
  target_stock_qty                  NUMBER (25,10)   NOT NULL,
  target_stock_unit_id              VARCHAR2 (15)    NOT NULL,
  is_active                         CHAR(1)          DEFAULT 'Y'                   NOT NULL,
  VERSION                           NUMBER(10)
);

ALTER TABLE glsm_gmr_link_stock_mapping ADD (
  CONSTRAINT glsm_pk
 PRIMARY KEY
 (glsm_id));

ALTER  TABLE glsm_gmr_link_stock_mapping ADD (
 CONSTRAINT fk_gld_id
 FOREIGN KEY (gld_id)
 REFERENCES gld_gmr_link_detail (gld_id));

CREATE  SEQUENCE seq_glsm
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

CREATE TABLE glsml_gmr_link_stock_map_log
(
  glsm_id                           VARCHAR2(15)     NOT NULL,
  gld_id                            VARCHAR2(15)     NOT NULL,
  internal_action_ref_no            VARCHAR2(15)     NOT NULL,
  source_internal_gmr_ref_no        VARCHAR2(15)     NOT NULL,
  source_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  source_internal_stock_ref_no      VARCHAR2(15)     NOT NULL,
  source_stock_ref_no               VARCHAR2(30)     NOT NULL,
  source_stock_qty                  NUMBER (25,10)   NOT NULL,
  source_stock_unit_id              VARCHAR2 (15)    NOT NULL,
  target_internal_gmr_ref_no        VARCHAR2(15)     NOT NULL,
  target_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  target_internal_stock_ref_no      VARCHAR2(15)     NOT NULL,
  target_stock_ref_no               VARCHAR2(30)     NOT NULL,
  target_stock_qty                  NUMBER (25,10)   NOT NULL,
  target_stock_unit_id              VARCHAR2 (15)    NOT NULL,
  is_active                         CHAR(1)          DEFAULT 'Y'                   NOT NULL,
  VERSION                           NUMBER(10),
  entry_type                        VARCHAR2(30)     NOT NULL
);