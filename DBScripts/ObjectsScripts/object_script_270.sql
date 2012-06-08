ALTER TABLE GRD_GOODS_RECORD_DETAIL DROP CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE;
ALTER TABLE AGRD_ACTION_GRD DROP CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE;

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
CONSTRAINT CHK_GRD_TOLLING_STOCK_TYPE
    CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock'))
);        
  
ALTER TABLE AGRD_ACTION_GRD ADD
(
CONSTRAINT CHK_AGRD_TOLLING_STOCK_TYPE
CHECK (TOLLING_STOCK_TYPE IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock'))
);
