CREATE TABLE HCD_HEDGE_CORRECTION_DETAILS
(
  HCD_ID varchar(15),
  INTERNAL_ACTION_REF_NO varchar(30),
  HEDGE_CORRECTION_DATE date,
  QTY NUMBER(25,10),
  PER_DAY_HEDGE_CORRE_QTY NUMBER(25,10),
  TOTAL_NO_OF_PROMT_DAYS number(25,10),
  POFH_ID varchar(15)
)
;


CREATE UNIQUE INDEX METALS_MAIN_DEV.HCD ON HCD_HEDGE_CORRECTION_DETAILS
(HCD_ID)
;
CREATE SEQUENCE SEQ_HCD
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
ALTER TABLE HCD_HEDGE_CORRECTION_DETAILS ADD (
  CONSTRAINT FK_HCD_POFH_ID 
 FOREIGN KEY (POFH_ID) 
 REFERENCES POFH_PRICE_OPT_FIXATION_HEADER (POFH_ID));
alter table PFD_PRICE_FIXATION_DETAILS add FX_FIXATION_DATE DATE ;
alter table PFD_PRICE_FIXATION_DETAILS add IS_HEDGE_CORRE_BEFORE_QP CHAR (1 CHAR) ;
alter table PFD_PRICE_FIXATION_DETAILS add HEDGE_AMOUNT NUMBER (25,10) ;
alter table POCH_PRICE_OPT_CALL_OFF_HEADER add IS_BALANCE_PRICING CHAR (1 CHAR);
alter table POFH_PRICE_OPT_FIXATION_HEADER add HEDGE_CORRECTION_QTY NUMBER (25,10) ;
alter table POFH_PRICE_OPT_FIXATION_HEADER add TOTAT_HEDGE_CORRE_QTY NUMBER (25,10) ;
alter table POFH_PRICE_OPT_FIXATION_HEADER add PER_DAY_HEDGE_CORRE_QTY NUMBER (25,10) ; 
alter table POFH_PRICE_OPT_FIXATION_HEADER add  QP_START_QTY NUMBER (25,10) ;
alter table PCBPH_PC_BASE_PRICE_HEADER add IS_BALANCE_PRICING CHAR (1 CHAR);
alter table PCBPHUL_PC_BASE_PRC_HEADER_UL add IS_BALANCE_PRICING CHAR (1 CHAR);
alter table PFD_PRICE_FIXATION_DETAILS add IS_HEDGE_CORRECTION CHAR (1 CHAR) ;
alter table POFH_PRICE_OPT_FIXATION_HEADER add IS_PROVESIONAL_ASSAY_EXIST  CHAR (1 CHAR);
alter table PFD_PRICE_FIXATION_DETAILS add FX_CORRECTION_DATE date;
alter table PFD_PRICE_FIXATION_DETAILS add IS_BALANCE_PRICING CHAR(1 CHAR);
alter table POFH_PRICE_OPT_FIXATION_HEADER add BALANCE_PRICED_QTY number(25,10);
alter table PFD_PRICE_FIXATION_DETAILS add HEDGE_CORRECTION_DATE date;
alter table  HCD_HEDGE_CORRECTION_DETAILS add VERSION VARCHAR2 (15 Char);