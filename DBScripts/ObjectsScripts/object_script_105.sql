CREATE TABLE PCDT_PHY_CON_DRAFT_TEMPLATE
(
  ID                      VARCHAR2(15 BYTE)     NOT NULL,
  DRAFT_TEMPLATE_TYPE     VARCHAR2(15 BYTE),
  DRAFT_TEMPLATE_NAME     VARCHAR2(15 BYTE),
  CP_NAME                 VARCHAR2(20 BYTE),
  TYPE                    VARCHAR2(15 BYTE),
  JAVA_OBJECT             BLOB,
  INTERNAL_ACTION_REF_NO  VARCHAR2(15 BYTE)     NOT NULL,
  PROFIT_CENTER           VARCHAR2(20 BYTE),
  DRAFT_NO                VARCHAR2(15 BYTE)     NOT NULL,
  IS_ACTIVE               CHAR(1 BYTE)          DEFAULT 'Y'                   NOT NULL,
  CORPORATE_ID            VARCHAR2(15 BYTE),
  TRADER                  VARCHAR2(15 BYTE),
  EXECUTION_TYPE          VARCHAR2(15 BYTE),
  STRATEGY                VARCHAR2(15 BYTE),
  CONTRACT_ISSUE_DATE     DATE,
  PRODUCT                 VARCHAR2(15 BYTE)
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


CREATE UNIQUE INDEX PK_PCDT_ID ON PCDT_PHY_CON_DRAFT_TEMPLATE
(ID)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


ALTER TABLE PCDT_PHY_CON_DRAFT_TEMPLATE ADD (
  CONSTRAINT PK_PCDT_ID
 PRIMARY KEY
 (ID)
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


CREATE SEQUENCE SEQ_PCDT
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;