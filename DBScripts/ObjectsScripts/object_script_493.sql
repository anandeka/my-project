CREATE TABLE hph_holiday_pricing_header
(
  hph_id                    VARCHAR2(15)              NOT NULL,
  clm_id                    VARCHAR2(15)              NOT NULL,
  internal_action_ref_no    VARCHAR2(15)              NOT NULL,
  process_ref_no            VARCHAR2(30)              NOT NULL,
  holiday_date              DATE                      NOT NULL,
  created_by                VARCHAR2(30)              NOT NULL,
  created_date              DATE                      NOT NULL,
  status                    VARCHAR2(30),
  is_active                 CHAR(1)      DEFAULT 'Y'  NOT NULL

);

ALTER TABLE hph_holiday_pricing_header ADD (
  CONSTRAINT chk_hph_is_active
 CHECK (is_active IN ('Y','N')),
  CONSTRAINT pk_hph
 PRIMARY KEY(hph_id));

ALTER  TABLE hph_holiday_pricing_header ADD (
  CONSTRAINT fk_hph_axs_no
 FOREIGN KEY (internal_action_ref_no)
 REFERENCES axs_action_summary (internal_action_ref_no));

ALTER  TABLE hph_holiday_pricing_header ADD (
  CONSTRAINT fk_hph_clm_id
 FOREIGN KEY (clm_id)
 REFERENCES clm_calendar_master (calendar_id));

CREATE TABLE hpd_holiday_pricing_details
(
    hpd_id          VARCHAR2(15)              NOT NULL,
    hph_id          VARCHAR2(15)              NOT NULL,
    pofh_id         VARCHAR2(15)              NOT NULL
);

ALTER TABLE hpd_holiday_pricing_details ADD (
  CONSTRAINT pk_hpd
 PRIMARY KEY(hpd_id));

ALTER   TABLE hpd_holiday_pricing_details ADD (
  CONSTRAINT fk_hpd_hph_id
 FOREIGN KEY (hph_id)
 REFERENCES hph_holiday_pricing_header (hph_id));

ALTER    TABLE hpd_holiday_pricing_details ADD (
  CONSTRAINT fk_hpd_pofh_id
 FOREIGN KEY (pofh_id)
 REFERENCES pofh_price_opt_fixation_header (pofh_id));


CREATE  SEQUENCE seq_hph
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;



CREATE   SEQUENCE seq_hpd
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;