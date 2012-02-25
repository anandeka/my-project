alter table IS_CONC_PENALTY_CHILD ADD (
      GMR_REF_NO                    VARCHAR2(15 CHAR),
      ASSAY_CONTENT                 VARCHAR2(50 CHAR),
      DRY_QUANTITY                  VARCHAR2(30 CHAR),
      STOCK_REF_NO                  VARCHAR2(50 CHAR),
      PENALTY_RULE                  VARCHAR2(50 CHAR),
      NET_PENALTY                   VARCHAR2(50 CHAR)
  );

 alter table IS_CONC_RC_CHILD ADD (
      GMR_REF_NO                    VARCHAR2(15 CHAR),
      ASSAY_CONTENT                 VARCHAR2(50 CHAR),
      DRY_QUANTITY                  VARCHAR2(30 CHAR),
      QUANTITY_UNIT_NAME            VARCHAR2(30 CHAR),
      STOCK_REF_NO                  VARCHAR2(50 CHAR),
      DEDUCTION                     VARCHAR2(50 CHAR),
      PAYABLE_CONTENT_PER           VARCHAR2(15 CHAR),
      NET_PAYABLE_CONTENT           VARCHAR2(50 CHAR),
      NET_RC                        VARCHAR2(50 CHAR)
  );

 alter table IS_CONC_TC_CHILD ADD (
  GMR_REF_NO                    VARCHAR2(15 CHAR),
  ASSAY_DETAIL                  VARCHAR2(50 CHAR),
  DRY_QUANTITY                  VARCHAR2(30 CHAR),
  QUANTITY_UNIT_NAME            VARCHAR2(30 CHAR),
  NET_TC                        VARCHAR2(50 CHAR),
  BASE_TC                       VARCHAR2(50 CHAR),
  STOCK_REF_NO                  VARCHAR2(50 CHAR)
);