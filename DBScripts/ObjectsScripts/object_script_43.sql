ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
    EXPECTED_SALES_CCY VARCHAR2(15),
    CONSTRAINT FK_GRD_EXPECTED_SALES_CCY  FOREIGN KEY (EXPECTED_SALES_CCY) REFERENCES CM_CURRENCY_MASTER (CUR_ID)
);

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD
(
    EXPECTED_SALES_CCY VARCHAR2(15)
);