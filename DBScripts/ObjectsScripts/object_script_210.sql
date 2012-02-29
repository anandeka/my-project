ALTER TABLE SPQ_STOCK_PAYABLE_QTY ADD
(
CORPORATE_ID            VARCHAR2(15),
CONSTRAINT FK_SPQ_CORPORATE_ID FOREIGN KEY (CORPORATE_ID) REFERENCES AK_CORPORATE (CORPORATE_ID)
);

ALTER TABLE PRRQS_PRR_QTY_STATUS ADD
(
CORPORATE_ID            VARCHAR2(15),
CONSTRAINT FK_PRRQS_CORPORATE_ID FOREIGN KEY (CORPORATE_ID) REFERENCES AK_CORPORATE (CORPORATE_ID)
);