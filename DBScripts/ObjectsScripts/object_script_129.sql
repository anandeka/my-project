

ALTER TABLE PCPDUL_PC_PRODUCT_DEFINTN_UL ADD INPUT_OUTPUT VARCHAR2(15 CHAR);

ALTER TABLE PCBPHUL_PC_BASE_PRC_HEADER_UL ADD IS_FREE_METAL_APPLICABLE CHAR(1 CHAR);

ALTER TABLE DIPQL_DEL_ITM_PAYBLE_QTY_LOG ADD QTY_TYPE VARCHAR2(30 CHAR);

ALTER TABLE CIPQL_CTRT_ITM_PAYABLE_QTY_LOG ADD QTY_TYPE VARCHAR2(30 CHAR);

ALTER TABLE POFHUL_PRICE_OPT_FIXATN_HDR_UL ADD EVENT_NAME varchar2(50);

ALTER TABLE SPQL_STOCK_PAYABLE_QTY_LOG ADD (QTY_TYPE VARCHAR2(10 CHAR),ACTIVITY_ACTION_ID VARCHAR2(30 CHAR),IS_STOCK_SPLIT CHAR(1 CHAR),SUPPLIER_ID VARCHAR2(20 CHAR),SMELTER_ID VARCHAR2(20 CHAR),IN_PROCESS_STOCK_ID VARCHAR2(20 CHAR),FREE_METAL_STOCK_ID VARCHAR2(20 CHAR),FREE_METAL_QTY NUMBER(25,10) );


alter table POFH_PRICE_OPT_FIXATION_HEADER add EVENT_NAME varchar2(50);


