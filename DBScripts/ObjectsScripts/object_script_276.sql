CREATE TABLE FMUH_FREE_METAL_UTILITY_HEADER
(
  FMUH_ID                     VARCHAR2(15 CHAR),
  UTILITY_REF_NO              VARCHAR2(15 CHAR),
  SMELTER_ID                  VARCHAR2(15 CHAR),
  CONSUMPTION_MONTH           VARCHAR2 (15 CHAR),
  CONSUMPTION_YEAR            VARCHAR2 (15 CHAR),
  QP_START_DATE               DATE,
  QP_END_DATE                 DATE,
  INTERNAL_ACTION_REF_NO      VARCHAR2(15 CHAR),
  VERSION                     NUMBER(10),
  IS_ACTIVE                   CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMUH ON FMUH_FREE_METAL_UTILITY_HEADER
(FMUH_ID);

ALTER TABLE FMUH_FREE_METAL_UTILITY_HEADER ADD (
  CONSTRAINT PK_FMUH
 PRIMARY KEY (FMUH_ID));


CREATE TABLE FMED_FREE_METAL_ELEMT_DETAILS
(
  FMED_ID                  VARCHAR2(15 CHAR),
  FMUH_ID                  VARCHAR2(15 CHAR),
  ELEMENT_ID               VARCHAR2(15 CHAR),
  ELEMENT_NAME             VARCHAR2(30 CHAR),
  PRICE_BASIS              VARCHAR2(15 CHAR),
  PRICE_UNIT_ID            VARCHAR2(15 CHAR),
  FORMULA_ID               VARCHAR2(15 CHAR),
  FORMULA_NAME             VARCHAR2(50 CHAR),
  FORMULA_DESCRIPTION      VARCHAR2(100 CHAR),
  INTERNAL_FORMULA_DESC    VARCHAR2(100 CHAR),
  VERSION                  NUMBER(10),
  IS_ACTIVE                CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMED ON FMED_FREE_METAL_ELEMT_DETAILS
(FMED_ID);

ALTER TABLE FMED_FREE_METAL_ELEMT_DETAILS ADD (
  CONSTRAINT PK_FMED
 PRIMARY KEY (FMED_ID));

ALTER TABLE FMED_FREE_METAL_ELEMT_DETAILS ADD (
 CONSTRAINT FMED_UTILITY_HEADER_ID 
 FOREIGN KEY (FMUH_ID) 
 REFERENCES FMUH_FREE_METAL_UTILITY_HEADER (FMUH_ID),
 CONSTRAINT FMED_PRICE_UNIT_ID 
 FOREIGN KEY (PRICE_UNIT_ID) 
 REFERENCES PPU_PRODUCT_PRICE_UNITS (INTERNAL_PRICE_UNIT_ID));

  
CREATE TABLE FMEIFD_INDEX_FORMULA_DETAILS
(
  FMEIFD_ID                VARCHAR2(15 CHAR),
  FMED_ID                  VARCHAR2(15 CHAR),
  INSTRUMENT_ID            VARCHAR2(15 CHAR),
  INSTRUMENT_NAME          VARCHAR2(50 CHAR),
  PRICE_SOURCE_ID          VARCHAR2(15 CHAR),
  PRICE_POINT_ID           VARCHAR2(15 CHAR),
  AVAILABLE_PRICE_TYPE_ID  VARCHAR2(15 CHAR),
  VALUE_DATE_TYPE          VARCHAR2(30 CHAR),
  VALUE_DATE               DATE,
  VALUE_MONTH              VARCHAR2(15 CHAR),
  VALUE_YEAR               VARCHAR2(15 CHAR),
  OFF_DAY_PRICE            VARCHAR2(30 CHAR),
  VERSION                  NUMBER(10),
  IS_ACTIVE                CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMEIFD ON FMEIFD_INDEX_FORMULA_DETAILS
(FMEIFD_ID);

ALTER TABLE FMEIFD_INDEX_FORMULA_DETAILS ADD (
  CONSTRAINT PK_FMEIFD
 PRIMARY KEY (FMEIFD_ID));
  
ALTER TABLE FMEIFD_INDEX_FORMULA_DETAILS ADD (
  CONSTRAINT FMEIFD_AVAILABLE_PRICE_TYPE_ID 
 FOREIGN KEY (AVAILABLE_PRICE_TYPE_ID) 
 REFERENCES APM_AVAILABLE_PRICE_MASTER (AVAILABLE_PRICE_ID),
  CONSTRAINT FMEIFD_INSTRUMENT_ID 
 FOREIGN KEY (INSTRUMENT_ID) 
 REFERENCES DIM_DER_INSTRUMENT_MASTER (INSTRUMENT_ID),
  CONSTRAINT FMEIFD_ELEMENT_ID 
 FOREIGN KEY (FMED_ID) 
 REFERENCES FMED_FREE_METAL_ELEMT_DETAILS (FMED_ID),
  CONSTRAINT FMEIFD_PRICE_POINT_ID 
 FOREIGN KEY (PRICE_POINT_ID) 
 REFERENCES PP_PRICE_POINT (PRICE_POINT_ID),
  CONSTRAINT FMEIFD_PRICE_SOURCE_ID 
 FOREIGN KEY (PRICE_SOURCE_ID) 
 REFERENCES PS_PRICE_SOURCE (PRICE_SOURCE_ID));

CREATE TABLE FMPFH_PRICE_FIXATION_HEADER
(
  FMPFH_ID                    VARCHAR2(15 CHAR),
  FMED_ID                     VARCHAR2(15 CHAR),
  ELEMENT_ID                  VARCHAR2(15 CHAR),
  QTY_TO_BE_FIXED             NUMBER(25,10),
  PRICED_QTY                  NUMBER(25,10),
  NO_OF_PROMPT_DAYS           NUMBER(25,10),
  PER_DAY_PRICING_QTY         NUMBER(25,10),
  AVG_FINAL_PRICE             NUMBER(25,10),
  FINALIZE_DATE               DATE,
  NO_OF_PROMPT_DAYS_FIXED     NUMBER(25,10)     DEFAULT 0,
  AVG_PRICE_IN_PRICE_IN_CUR	  NUMBER (25,10),		
  AVG_FX	                  NUMBER (25,10),	
  FINAL_PRICE_IN_PRICING_CUR  NUMBER (25,10),
  VERSION                     NUMBER(10),
  IS_ACTIVE                   CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMPFH ON FMPFH_PRICE_FIXATION_HEADER
(FMPFH_ID);

ALTER TABLE FMPFH_PRICE_FIXATION_HEADER ADD (
  CONSTRAINT PK_FMPFH
 PRIMARY KEY (FMPFH_ID));
 
ALTER TABLE FMPFH_PRICE_FIXATION_HEADER ADD (
  CONSTRAINT FMPFH_FMED_ID 
 FOREIGN KEY (FMED_ID) 
 REFERENCES FMED_FREE_METAL_ELEMT_DETAILS (FMED_ID));

CREATE TABLE FMPFD_PRICE_FIXATION_DETAILS
(
  FMPFD_ID             VARCHAR2(15 CHAR),
  FMPFH_ID             VARCHAR2(15 CHAR),
  FPD_ID               VARCHAR2(15 CHAR),
  AS_OF_DATE           DATE,
  QTY_FIXED            NUMBER(25,10),
  USER_PRICE           NUMBER(25,10),
  PRICE_UNIT_ID        VARCHAR2(15 CHAR),
  FX_RATE              NUMBER(25,10),
  FX_TO_BASE           NUMBER(25,10),
  VERSION              NUMBER(10),
  IS_ACTIVE            CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMPFD ON FMPFD_PRICE_FIXATION_DETAILS
(FMPFD_ID);

ALTER TABLE FMPFD_PRICE_FIXATION_DETAILS ADD (
  CONSTRAINT PK_FMPFD
 PRIMARY KEY (FMPFD_ID));
 
ALTER TABLE FMPFD_PRICE_FIXATION_DETAILS ADD (
  CONSTRAINT FMPFD_FMPFH_ID 
 FOREIGN KEY (FMPFH_ID) 
 REFERENCES FMPFH_PRICE_FIXATION_HEADER (FMPFH_ID));

CREATE TABLE FMPFAM_PRICE_ACTION_MAPPING
(
  FMPFAM_ID                 VARCHAR2(15 CHAR),
  FMPFD_ID                  VARCHAR2(15 CHAR),
  INTERNAL_ACTION_REF_NO  VARCHAR2(15 CHAR),
  VERSION                 NUMBER(10),
  IS_ACTIVE               CHAR(1 CHAR)
);

CREATE UNIQUE INDEX PK_FMPFAM_ID ON FMPFAM_PRICE_ACTION_MAPPING
(FMPFAM_ID);

ALTER TABLE FMPFAM_PRICE_ACTION_MAPPING ADD (
  CONSTRAINT PK_FMPFAM_ID
 PRIMARY KEY
 (FMPFAM_ID));

ALTER TABLE FMPFAM_PRICE_ACTION_MAPPING ADD (
  CONSTRAINT FMPFAM_INT_ACTION_REF_NO 
 FOREIGN KEY (INTERNAL_ACTION_REF_NO) 
 REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO));


CREATE SEQUENCE SEQ_FMUH
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
  

CREATE SEQUENCE SEQ_FMED
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
  

CREATE SEQUENCE SEQ_FMPFH
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


CREATE SEQUENCE SEQ_FMPFD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

CREATE SEQUENCE SEQ_FMPFAM
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

 CREATE SEQUENCE SEQ_FMEIFD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
  
alter table PPL_PRICE_PROCESS_LIST add  FMUH_ID varchar2(15);
alter table PPLI_PRICE_PROCESS_ITEM_LIST add fmpfh_id varchar2(15);
alter table FMUH_FREE_METAL_UTILITY_HEADER add corporate_id varchar2(15);
alter table FMED_FREE_METAL_ELEMT_DETAILS add qty_unit_id varchar2(15);
alter table FMUH_FREE_METAL_UTILITY_HEADER add STATUS varchar2(30);
alter table FMPFH_PRICE_FIXATION_HEADER add HEDGE_CORRECTION_DATE DATE;
alter table FMED_FREE_METAL_ELEMT_DETAILS add INTERNAL_GMR_REF_NO varchar2(15);
alter table FMUH_FREE_METAL_UTILITY_HEADER add IS_FULLY_PRICE_FIXED varchar2(15);
alter table FMUH_FREE_METAL_UTILITY_HEADER add BASE_CUR_ID varchar2(15);