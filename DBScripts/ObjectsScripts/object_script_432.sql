
ALTER TABLE gth_gmr_treatment_header
 ADD (internal_action_ref_no  VARCHAR2(15));

ALTER  TABLE gph_gmr_penalty_header
 ADD (internal_action_ref_no  VARCHAR2(15));

ALTER  TABLE grh_gmr_refining_header
 ADD (internal_action_ref_no  VARCHAR2(15));

CREATE  TABLE gthul_gmr_treatment_header_ul
(
  gthul_id                  VARCHAR2(15)        NOT NULL,
  gth_id                    VARCHAR2(15)        NOT NULL,
  entry_type                VARCHAR2(30)        NOT NULL,
  internal_gmr_ref_no       VARCHAR2(15)        NOT NULL,
  pcdi_id                   VARCHAR2(15)        NOT NULL,
  pcth_id                   VARCHAR2(15)        NOT NULL,
  internal_action_ref_no    VARCHAR2(15)        NOT NULL,
  is_active                 CHAR(1)             NOT NULL
);

CREATE SEQUENCE seq_gthul
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
  
CREATE TABLE grhul_gmr_refining_header_ul
(
  grhul_id                  VARCHAR2(15)        NOT NULL,
  grh_id                    VARCHAR2(15)        NOT NULL,
  entry_type                VARCHAR2(30)        NOT NULL,
  internal_gmr_ref_no       VARCHAR2(15)        NOT NULL,
  pcdi_id                   VARCHAR2(15)        NOT NULL,
  pcrh_id                   VARCHAR2(15)        NOT NULL,
  internal_action_ref_no    VARCHAR2(15)        NOT NULL,
  is_active                 CHAR(1)             NOT NULL
);

CREATE SEQUENCE seq_grhul
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
  
CREATE TABLE gphul_gmr_penalty_header_ul
(
  gphul_id                  VARCHAR2(15)        NOT NULL,
  gph_id                    VARCHAR2(15)        NOT NULL,
  entry_type                VARCHAR2(30)        NOT NULL,
  internal_gmr_ref_no       VARCHAR2(15)        NOT NULL,
  pcdi_id                   VARCHAR2(15)        NOT NULL,
  pcaph_id                  VARCHAR2(15)        NOT NULL,
  internal_action_ref_no    VARCHAR2(15)        NOT NULL,
  is_active                 CHAR(1)             NOT NULL
);

CREATE SEQUENCE seq_gphul
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;