
CREATE TABLE SAM_STOCK_ASSAY_MAPPING
(
  SAM_ID               VARCHAR2(15 BYTE)        NOT NULL,
  internal_grd_ref_no                VARCHAR2(15 BYTE),
  internal_dgrd_ref_no                VARCHAR2(15 BYTE),
  ash_id                              VARCHAR2(15 BYTE) not null,
  version              number(10), 
  IS_ACTIVE            CHAR(1 BYTE)  default 'Y'   NOT NULL 
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE SAM_STOCK_ASSAY_MAPPING ADD (
  
  PRIMARY KEY
 (SAM_ID)
    USING INDEX 
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));
               
               
               CREATE SEQUENCE SEQ_SAM
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;