ALTER TABLE GMR_GOODS_MOVEMENT_RECORD DROP CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE;
ALTER TABLE AGMR_ACTION_GMR DROP CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE;

ALTER TABLE GRD_GOODS_RECORD_DETAIL DROP CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE;
ALTER TABLE AGRD_ACTION_GRD DROP CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE;

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD
(
CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE
 CHECK (TOLLING_GMR_TYPE IN ('None Tolling','Mark For Tolling','Received Materials','Output Process',
                                'Process Activity','Input Process','Pledge','Financial Settlement',
                                'Return Material','Free Metal Utility'))
  
);

ALTER TABLE AGMR_ACTION_GMR ADD (
  CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE
 CHECK (TOLLING_GMR_TYPE IN ('None Tolling','Mark For Tolling','Received Materials','Output Process',
                                'Process Activity','Input Process','Pledge','Financial Settlement',
                                'Return Material','Free Metal Utility'))
);


ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE
 CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock','Free Metal Utility Stock'))
);

ALTER TABLE AGRD_ACTION_GRD ADD
(
CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE
 CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock','Free Metal Utility Stock'))
);


ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD UTILITY_HEADER_ID VARCHAR2(15);
alter table GRD_GOODS_RECORD_DETAIL add 
( 
UTILITY_HEADER_ID varchar2(15),
CONSTRAINT FK_GRD_UTILITY_HEADER_ID FOREIGN KEY (UTILITY_HEADER_ID) REFERENCES FMUH_FREE_METAL_UTILITY_HEADER (FMUH_ID)
);
alter table GRDL_GOODS_RECORD_DETAIL_LOG add utility_header_id varchar2(15);
