ALTER TABLE PRRQS_PRR_QTY_STATUS ADD
(
  CP_TYPE                 VARCHAR2(8)      DEFAULT 'Supplier'   NOT NULL,
  CONSTRAINT CHK_PRRQS_CP_TYPE CHECK ( CP_TYPE IN ('Supplier', 'Smelter'))
);

ALTER TABLE PRRQS_PRR_QTY_STATUS DROP COLUMN SMELTER_CP_ID;
ALTER TABLE PRRQS_PRR_QTY_STATUS DROP COLUMN TO_SMELTER_CP_ID;

ALTER TABLE PRRQS_PRR_QTY_STATUS RENAME COLUMN SUPPLIER_CP_ID TO CP_ID;
ALTER TABLE PRRQS_PRR_QTY_STATUS MODIFY(CP_ID  NOT NULL);
ALTER TABLE PRRQS_PRR_QTY_STATUS RENAME COLUMN TO_SUPPLIER_CP_ID TO TO_CP_ID;


ALTER TABLE PRRQS_PRR_QTY_STATUS DROP CONSTRAINT FK_PRRQS_SUPPLIER_CP_ID;
ALTER TABLE PRRQS_PRR_QTY_STATUS DROP CONSTRAINT FK_PRRQS_TO_SUPPLIER_CP_ID;

ALTER TABLE PRRQS_PRR_QTY_STATUS ADD
(
CONSTRAINT FK_PRRQS_CP_ID FOREIGN KEY (CP_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_PRRQS_TO_CP_ID FOREIGN KEY (TO_CP_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID)
);

CREATE TABLE MTFS_MBT_FIN_SETTLEMENT
(
  MTFS_ID                 VARCHAR2(15)     NOT NULL,
  CORPORATE_ID            VARCHAR2(15)     NOT NULL,
  ACTIVITY_ACTION_ID      VARCHAR2(30)     NOT NULL,
  ACTIVITY_REF_NO         VARCHAR2(30)     NOT NULL,
  ACTIVITY_DATE           DATE             NOT NULL,
  CP_TYPE                 VARCHAR2(8)      DEFAULT 'Supplier'   NOT NULL,
  SOURCE_CP_ID            VARCHAR2(20)     NOT NULL,
  TO_CP_ID                VARCHAR2(20)     NOT NULL,
  PRODUCT_ID              VARCHAR2(15)     NOT NULL,
  ELEMENT_ID              VARCHAR2(15)     NOT NULL,
  QTY                     NUMBER(25,10)    NOT NULL,
  QTY_UNIT_ID             VARCHAR2(15)     NOT NULL,
  INTERNAL_ACTION_REF_NO  VARCHAR2(15)     NOT NULL,
  IS_ACTIVE               CHAR(1)          DEFAULT 'Y'   NOT NULL,
  VERSION                 NUMBER(10),
  CONSTRAINT CHK_MTFS_IS_ACTIVE CHECK ( IS_ACTIVE IN ('Y', 'N')),
  CONSTRAINT CHK_MTFS_CP_TYPE CHECK ( CP_TYPE IN ('Supplier', 'Smelter')),
  CONSTRAINT PK_MTFS PRIMARY KEY (MTFS_ID),
  CONSTRAINT FK_MTFS_CORPORATE_ID FOREIGN KEY (CORPORATE_ID) REFERENCES AK_CORPORATE (CORPORATE_ID),
  CONSTRAINT FK_MTFS_ACTIVITY_ACTION_ID FOREIGN KEY (ACTIVITY_ACTION_ID) REFERENCES AXM_ACTION_MASTER (ACTION_ID),
  CONSTRAINT FK_MTFS_SOURCE_CP_ID FOREIGN KEY (SOURCE_CP_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
  CONSTRAINT FK_MTFS_TO_CP_ID FOREIGN KEY (TO_CP_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
  CONSTRAINT FK_MTFS_PRODUCT_ID FOREIGN KEY (PRODUCT_ID) REFERENCES PDM_PRODUCTMASTER (PRODUCT_ID),
  CONSTRAINT FK_MTFS_ELEMENT_ID FOREIGN KEY (ELEMENT_ID) REFERENCES AML_ATTRIBUTE_MASTER_LIST (ATTRIBUTE_ID),
  CONSTRAINT FK_MTFS_QTY_UNIT_ID FOREIGN KEY (QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
  CONSTRAINT FK_MTFS_INTERNAL_ACTION_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);



CREATE TABLE GEPD_GMR_ELEMENT_PLEDGE_DETAIL
(
GEPD_ID                 VARCHAR2(15)        NOT NULL,
CORPORATE_ID            VARCHAR2(15)        NOT NULL,
ACTIVITY_ACTION_ID      VARCHAR2(30)        NOT NULL,
ACTIVITY_REF_NO         VARCHAR2(30)        NOT NULL,
ACTIVITY_DATE           DATE                NOT NULL,
INTERNAL_GMR_REF_NO     VARCHAR2(15)        NOT NULL,
PLEDGE_INPUT_GMR        VARCHAR2(15)        NOT NULL,
SUPPLIER_CP_ID          VARCHAR2(20)        NOT NULL,
PLEDGE_CP_ID            VARCHAR2(20)        NOT NULL,
PRODUCT_ID              VARCHAR2(15)        NOT NULL,
ELEMENT_ID              VARCHAR2(15)        NOT NULL,
ELEMENT_TYPE            VARCHAR2(11)        NOT NULL,
PLEDGE_QTY              NUMBER(25,10)       NOT NULL,
PLEDGE_QTY_UNIT_ID      VARCHAR2(15)        NOT NULL,
INTERNAL_ACTION_REF_NO  VARCHAR2(15)        NOT NULL,
VERSION                 NUMBER(10),
IS_ACTIVE               CHAR(1)             DEFAULT 'Y'  NOT NULL,
CONSTRAINT CHK_GEPD_IS_ACTIVE CHECK (IS_ACTIVE IN ('Y', 'N')),
CONSTRAINT CHK_GEPD_ELEMENT_TYPE CHECK (ELEMENT_TYPE IN ('Payable','Returnable')),
CONSTRAINT PK_GEPD PRIMARY KEY (GEPD_ID),
CONSTRAINT FK_GEPD_CORPORATE_ID FOREIGN KEY (CORPORATE_ID) REFERENCES AK_CORPORATE (CORPORATE_ID),
CONSTRAINT FK_GEPD_ACTIVITY_ACTION_ID FOREIGN KEY (ACTIVITY_ACTION_ID) REFERENCES AXM_ACTION_MASTER (ACTION_ID),
CONSTRAINT FK_GEPD_INTERNAL_GMR_REF_NO FOREIGN KEY (INTERNAL_GMR_REF_NO) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_GEPD_PLEDGE_INPUT_GMR FOREIGN KEY (PLEDGE_INPUT_GMR) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_GEPD_SUPPLIER_CP_ID FOREIGN KEY (SUPPLIER_CP_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_GEPD_PLEDGE_CP_ID FOREIGN KEY (PLEDGE_CP_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
CONSTRAINT FK_GEPD_ELEMENT_ID FOREIGN KEY (ELEMENT_ID) REFERENCES AML_ATTRIBUTE_MASTER_LIST (ATTRIBUTE_ID),
CONSTRAINT FK_GEPD_PLEDGE_QTY_UNIT_ID FOREIGN KEY (PLEDGE_QTY_UNIT_ID) REFERENCES QUM_QUANTITY_UNIT_MASTER (QTY_UNIT_ID),
CONSTRAINT FK_GEPD_INTERNAL_ACTION_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE PRRQS_PRR_QTY_STATUS ADD
(
  MTFS_ID   VARCHAR2(15),
  GEPD_ID   VARCHAR2(15),
  CONSTRAINT FK_PRRQS_MTFS_ID FOREIGN KEY (MTFS_ID) REFERENCES MTFS_MBT_FIN_SETTLEMENT(MTFS_ID),
  CONSTRAINT FK_PRRQS_GEPD_ID FOREIGN KEY (GEPD_ID) REFERENCES GEPD_GMR_ELEMENT_PLEDGE_DETAIL(GEPD_ID)
);
 

ALTER TABLE SPQ_STOCK_PAYABLE_QTY ADD
(
  PLEDGE_STOCK_ID   VARCHAR2(20),
  GEPD_ID           VARCHAR2(15),
  CONSTRAINT FK_SPQ_PLEDGE_STOCK_ID FOREIGN KEY (PLEDGE_STOCK_ID) REFERENCES GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO),
  CONSTRAINT FK_SPQ_GEPD_ID FOREIGN KEY (GEPD_ID) REFERENCES GEPD_GMR_ELEMENT_PLEDGE_DETAIL(GEPD_ID)
);

ALTER TABLE GRD_GOODS_RECORD_DETAIL DROP CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE;
ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE
 CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','RM In Process Stock','RM Out Process Stock','Process Activity','Clone Stock','Input Process','Output Process','Free Material Stock','Pledge Stock','Financial Settlement Stock'))
);

ALTER TABLE AGRD_ACTION_GRD DROP CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE;
ALTER TABLE AGRD_ACTION_GRD ADD
(
CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE
 CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','RM In Process Stock','RM Out Process Stock','Process Activity','Clone Stock','Input Process','Output Process','Free Material Stock','Pledge Stock','Financial Settlement Stock'))
);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD DROP CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE;
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD
(
CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE CHECK (TOLLING_GMR_TYPE IN ('Mark For Tolling','Received Materials','Output Process','Process Activity','Input Process','Pledge','Financial Settlement'))
);

ALTER TABLE AGMR_ACTION_GMR DROP CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE;
ALTER TABLE AGMR_ACTION_GMR ADD
(
CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE CHECK (TOLLING_GMR_TYPE IN ('Mark For Tolling','Received Materials','Output Process','Process Activity','Input Process','Pledge','Financial Settlement'))
);

ALTER TABLE DGRD_DELIVERED_GRD ADD
(
TOLLING_STOCK_TYPE   VARCHAR2(30) DEFAULT 'None Tolling',
CONSTRAINT CHK_DRD_TOLLING_STOCK_TYPE CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','Financial Settlement Stock'))
);

ALTER TABLE DGRDUL_DELIVERED_GRD_UL ADD
(
TOLLING_STOCK_TYPE   VARCHAR2(30)
);

ALTER TABLE ADGRD_ACTION_DGRD ADD
(
TOLLING_STOCK_TYPE   VARCHAR2(30) DEFAULT 'None Tolling',
CONSTRAINT CHK_ADRD_TOLLING_STOCK_TYPE CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','Financial Settlement Stock'))
);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD
(
CARRY_OVER_GMR          VARCHAR2(15), 
CARRY_OVER_QTY          NUMBER(20,5),
CARRY_OVER_INPUT_GMR    VARCHAR2(15),
CONSTRAINT FK_GMR_CARRY_OVER_GMR FOREIGN KEY (CARRY_OVER_GMR) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO),
CONSTRAINT FK_GMR_CARRY_OVER_INPUT_GMR FOREIGN KEY (CARRY_OVER_INPUT_GMR) REFERENCES GMR_GOODS_MOVEMENT_RECORD (INTERNAL_GMR_REF_NO)
);

ALTER TABLE GMRUL_GMR_UL ADD
(
CARRY_OVER_GMR          VARCHAR2(15), 
CARRY_OVER_QTY          VARCHAR2(25),
CARRY_OVER_INPUT_GMR    VARCHAR2(15)
);

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
CARRY_OVER_QTY          NUMBER(20,5)
);

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD
(
CARRY_OVER_QTY          VARCHAR2(25)
);

ALTER TABLE SPQ_STOCK_PAYABLE_QTY ADD
(
ASSAY_HEADER_ID     VARCHAR(15),
IS_FINAL_ASSAY      CHAR(1)          DEFAULT 'N',
CONSTRAINT FK_SPQ_ASSAY_HEADER_ID FOREIGN KEY (ASSAY_HEADER_ID) REFERENCES ASH_ASSAY_HEADER (ASH_ID),
CONSTRAINT CHK_SPQ_IS_FINAL_ASSAY CHECK (IS_FINAL_ASSAY IN ('Y','N'))
);