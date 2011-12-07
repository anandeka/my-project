ALTER TABLE GRD_GOODS_RECORD_DETAIL
drop CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE;


ALTER TABLE GRD_GOODS_RECORD_DETAIL
add CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE
   CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','RM In Process Stock','RM Out Process Stock','Process Activity','Clone Stock','Input Process','Output Process'));  
   

ALTER TABLE AGRD_ACTION_GRD
drop CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE;


ALTER TABLE AGRD_ACTION_GRD
add CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE
   CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','RM In Process Stock','RM Out Process Stock','Process Activity','Clone Stock','Input Process','Output Process'));





ALTER TABLE GMR_GOODS_MOVEMENT_RECORD
drop CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE;


ALTER TABLE GMR_GOODS_MOVEMENT_RECORD
add CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE
   CHECK (TOLLING_GMR_TYPE IN ('Mark For Tolling','Received Materials','Output Process','Process Activity','Input Process'));
   
   

ALTER TABLE AGMR_ACTION_GMR
drop CONSTRAINT CHK_AGMR_TOLLING_GMR_TYPE;


ALTER TABLE GMR_GOODS_MOVEMENT_RECORD
add CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE
   CHECK (TOLLING_GMR_TYPE IN ('Mark For Tolling','Received Materials','Output Process','Process Activity','Input Process'));