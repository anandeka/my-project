ALTER TABLE PCPCH_PC_PAYBLE_CONTENT_HEADER
 ADD (DUE_DATE_DAYS  NUMBER(25,10));
ALTER TABLE PCPCH_PC_PAYBLE_CONTENT_HEADER
 ADD (DUE_DATE_ACTIVITY  VARCHAR2(20 CHAR));

ALTER TABLE PCPCHUL_PAYBLE_CONTNT_HEADR_UL
 ADD (DUE_DATE_DAYS  VARCHAR2(30 CHAR));
ALTER TABLE PCPCHUL_PAYBLE_CONTNT_HEADR_UL
 ADD (DUE_DATE_ACTIVITY  VARCHAR2(20 CHAR));



Insert into SLV_STATIC_LIST_VALUE (VALUE_ID,VALUE_TEXT) values('Landing','Landing');
Insert into SLV_STATIC_LIST_VALUE (VALUE_ID,VALUE_TEXT) values('Sampling','Sampling');
Insert into SLV_STATIC_LIST_VALUE (VALUE_ID,VALUE_TEXT) values('Assay Finalization','Assay Finalization');

Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values('ReturnableDateActivity','Shipment','N','1');
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values('ReturnableDateActivity','Landing','N','2');
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values('ReturnableDateActivity','Sampling','N','3');
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values('ReturnableDateActivity','Assay Finalization','N','4');