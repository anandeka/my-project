--Added New Coloumn TRADING_MINING_COMB_TYPE 

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30));

ALTER TABLE GMRUL_GMR_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30));

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD add (
  CONSTRAINT CHK_GMR_TRADING_MINING_COMB_TYPE
 CHECK (TRADING_MINING_COMB_TYPE IN ('Trading','Mining','Combined')));
 
 
ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE GRD_GOODS_RECORD_DETAIL add (
  CONSTRAINT CHK_GRD_TRADING_MINING_COMB_TYPE
 CHECK (TRADING_MINING_COMB_TYPE IN ('Trading','Mining','Combined')));
 
 
ALTER TABLE DGRD_DELIVERED_GRD ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRDUL_DELIVERED_GRD_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRD_DELIVERED_GRD add (
  CONSTRAINT CHK_DGRD_TRADING_MINING_COMB_TYPE
 CHECK (TRADING_MINING_COMB_TYPE IN ('Trading','Mining','Combined')));



--Added New Coloumn BASE_CONC_MIX_TYPE 

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD (BASE_CONC_MIX_TYPE  VARCHAR2(30));

ALTER TABLE GMRUL_GMR_UL ADD (BASE_CONC_MIX_TYPE  VARCHAR2(30));

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD add (
  CONSTRAINT CHK_GMR_BASE_CONC_MIX_TYPE
 CHECK (BASE_CONC_MIX_TYPE IN ('BASEMETAL','CONCENTRATES','BASECONCMIX')));
 
 
ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD (BASE_CONC_TYPE  VARCHAR2(30)); 

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD (BASE_CONC_TYPE  VARCHAR2(30)); 

ALTER TABLE GRD_GOODS_RECORD_DETAIL add (
CONSTRAINT CHK_GRD_BASE_CONC_TYPE
 CHECK (BASE_CONC_TYPE IN ('BASEMETAL','CONCENTRATES')));
 
 
ALTER TABLE DGRD_DELIVERED_GRD ADD (BASE_CONC_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRDUL_DELIVERED_GRD_UL ADD (BASE_CONC_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRD_DELIVERED_GRD add (
 CONSTRAINT CHK_DGRD_BASE_CONC_TYPE
 CHECK (BASE_CONC_TYPE IN ('BASEMETAL','CONCENTRATES')));