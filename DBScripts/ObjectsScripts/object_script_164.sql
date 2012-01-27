alter table CS_COST_STORE add DELTA_COST_IN_BASE_PRICE_ID NUMBER(25,10);

alter table GRDL_GOODS_RECORD_DETAIL_LOG add (IS_TRANS_SHIP                   CHAR(1 CHAR)  DEFAULT 'N',
  IS_MARK_FOR_TOLLING             CHAR(1 CHAR)  DEFAULT 'N',
  TOLLING_QTY                     NUMBER(20,5),
  TOLLING_STOCK_TYPE              VARCHAR2(30 CHAR) DEFAULT 'None Tolling',
  ELEMENT_ID                      VARCHAR2(15 CHAR),
  EXPECTED_SALES_CCY              VARCHAR2(15 CHAR),
  PROFIT_CENTER_ID                VARCHAR2(15 CHAR),
  STRATEGY_ID                     VARCHAR2(15 CHAR),
  IS_WARRANT                      CHAR(1 CHAR)  DEFAULT 'N',
  WARRANT_NO                      VARCHAR2(15 CHAR),
  PCDI_ID                         VARCHAR2(15 CHAR),
  SUPP_CONTRACT_ITEM_REF_NO       VARCHAR2(15 CHAR),
  SUPPLIER_PCDI_ID                VARCHAR2(15 CHAR),
  PAYABLE_RETURNABLE_TYPE         VARCHAR2(10 CHAR),
  CARRY_OVER_QTY                  NUMBER(20,5));