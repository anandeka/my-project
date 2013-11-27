alter table HPH_HOLIDAY_PRICING_HEADER drop column CLM_ID;
alter table HPH_HOLIDAY_PRICING_HEADER drop column HOLIDAY_DATE;
alter table HPH_HOLIDAY_PRICING_HEADER drop column CHANGE_TYPE;

alter table HPD_HOLIDAY_PRICING_DETAILS drop column HPH_ID;
alter table HPD_HOLIDAY_PRICING_DETAILS add (HCL_ID varchar2(15));

CREATE TABLE hcl_holiday_calender_list
(
  hcl_id                    VARCHAR2(15)              NOT NULL,
  hph_id                    VARCHAR2(15)             NOT NULL,
  clm_id                    VARCHAR2(15)              NOT NULL,
  holiday_date              DATE                         NOT NULL,
  change_type               VARCHAR2(15)           NOT NULL
 );
 

ALTER  TABLE hcl_holiday_calender_list ADD(CONSTRAINT pk_hcl PRIMARY KEY(hcl_id));


ALTER  TABLE hcl_holiday_calender_list ADD (
  CONSTRAINT fk_hph_id
 FOREIGN KEY (hph_id)
 REFERENCES hph_holiday_pricing_header (hph_id));
 

ALTER  TABLE hcl_holiday_calender_list ADD (
  CONSTRAINT fk_hph_clm_id
 FOREIGN KEY (clm_id)
 REFERENCES clm_calendar_master (calendar_id));

CREATE SEQUENCE SEQ_HCL
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;