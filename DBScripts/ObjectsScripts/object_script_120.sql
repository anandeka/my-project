ALTER TABLE GRD_GOODS_RECORD_DETAIL
drop CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE;


ALTER TABLE GRD_GOODS_RECORD_DETAIL
add CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE
   CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','In Process Stock','Received In Process Stock','Received Out Process Stock','Process Activity','Clone Stock','Input Process','Output Process'));
   
   

ALTER TABLE AGRD_ACTION_GRD
drop CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE;


ALTER TABLE AGRD_ACTION_GRD
add CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE
   CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','In Process Stock','Received In Process Stock','Received Out Process Stock','Process Activity','Clone Stock','Input Process','Output Process'));
   



ALTER TABLE GMR_GOODS_MOVEMENT_RECORD
drop CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE;


ALTER TABLE GMR_GOODS_MOVEMENT_RECORD
add CONSTRAINT CHK_GMR_TOLLING_GMR_TYPE
   CHECK (TOLLING_GMR_TYPE IN ('Input Process','Received Process','Output Process','Process Activity'));
