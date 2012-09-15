
CREATE TABLE EVD_ECONOMIC_VALUE_DETAILS
(
  EVD_ID                    VARCHAR2(15),
  INTERNAL_ACTION_REF_NO    VARCHAR2(15),
  WNSREFNO                  VARCHAR2(30),
  SELF_ASSAY_REF_NO         VARCHAR2(30),
  CP_ASSAY_REF_NO           VARCHAR2(30),
  STOCK_ID                  VARCHAR2(30),
  SUBLOT_NO                 VARCHAR2(30),
  SELF_ASSAY_VALUE          NUMBER(25,10),
  CP_ASSAY_VALUE            NUMBER(25,10),
  DIFF_ASSAY_VALUE          NUMBER(25,10),
  DIFF_PAYABLE_QTY          NUMBER(25,10),
  SPLIT_PAYABLE_QTY         NUMBER(25,10),
  PROV_PRICE                NUMBER(25,10),
  ECONOMIC_VALUE            NUMBER(25,10),
  PROV_PRICE_UNIT_ID        VARCHAR2(15),
  QTY_UNIT_ID               VARCHAR2(15),
  CUR_ID                    VARCHAR2(15),
  SELF_ASSAY_SPLIT_LIMIT    NUMBER(25,10),
  CP_ASSAY_SPLIT_LIMIT      NUMBER(25,10),
  ELEMENT_ID                VARCHAR2(15),
  VERSION                   NUMBER(10),
  IS_DELETED                CHAR(1),
  CONSTRAINT PK_EVD PRIMARY KEY (EVD_ID)
);


CREATE SEQUENCE SEQ_EVD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

ALTER TABLE PQCA_PQ_CHEMICAL_ATTRIBUTES ADD (SPLIT_LIMIT  NUMBER(25,10));