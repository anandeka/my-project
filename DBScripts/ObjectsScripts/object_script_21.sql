DROP TABLE VCA_VALUATION_CURVE_ATTRIBUTE CASCADE CONSTRAINTS;

CREATE TABLE VCA_VALUATION_CURVE_ATTRIBUTE
(
  VCA_ID         VARCHAR2(15 BYTE)              NOT NULL,
  VCS_ID         VARCHAR2(15 BYTE)              NOT NULL,
  ATTRIBUTE_ID   VARCHAR2(15 BYTE),
  PRICE_UNIT_ID  VARCHAR2(50 BYTE)
);


ALTER TABLE VCA_VALUATION_CURVE_ATTRIBUTE ADD (
  CONSTRAINT PK_VCA_ID
 PRIMARY KEY
 (VCA_ID));


DROP TABLE VCS_VALUATION_CURVE_SETUP CASCADE CONSTRAINTS;

CREATE TABLE VCS_VALUATION_CURVE_SETUP
(
  VCS_ID          VARCHAR2(15 BYTE)             NOT NULL,
  CORPORATE_ID    VARCHAR2(15 BYTE)             NOT NULL,
  PRODUCT_ID      VARCHAR2(15 BYTE)             NOT NULL,
  CURVE_NAME      VARCHAR2(50 BYTE)             NOT NULL,
  APPLICABLE_ID   VARCHAR2(15 BYTE)             NOT NULL,
  IS_CONCENTRATE  CHAR(1 BYTE),
  IS_ACTIVE       CHAR(1 BYTE)                  DEFAULT 'Y'                   NOT NULL,
  IS_DELETE       CHAR(1 BYTE)                  DEFAULT 'N'                   NOT NULL
);


ALTER TABLE VCS_VALUATION_CURVE_SETUP ADD (
  CONSTRAINT PK_VCS_ID
 PRIMARY KEY
 (VCS_ID));

 ALTER TABLE SAM_STOCK_ASSAY_MAPPING ADD  STOCK_TYPE            VARCHAR2(10 BYTE) NOT NULL;