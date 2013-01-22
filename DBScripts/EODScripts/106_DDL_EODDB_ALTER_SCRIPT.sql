CREATE TABLE FCO_FEED_CONSUMPTION_ORIGINAL(
PROCESS_ID                  VARCHAR2(15 ),
EOD_TRADE_DATE              DATE,
CORPORATE_ID                VARCHAR2(15 ),
CORPORATE_NAME              VARCHAR2(100 ),
GMR_REF_NO                  VARCHAR2(30 ),
INTERNAL_GMR_REF_NO         VARCHAR2(15 ),
INTERNAL_GRD_REF_NO         VARCHAR2(15 ),
STOCK_REF_NO                VARCHAR2(50 ),
PRODUCT_ID                  VARCHAR2(15 ),
PRODUCT_NAME                VARCHAR2(200 ),
QUALITY_ID                  VARCHAR2(15 ),
QUALITY_NAME                VARCHAR2(50 ),
PILE_NAME                   VARCHAR2(50 ),
PARENT_GMR_REF_NO           VARCHAR2(30 ),
WAREHOUSE_ID                VARCHAR2(50 ),
WAREHOUSE_NAME              VARCHAR2(100 ),
SHED_ID                     VARCHAR2(15 ),
SHED_NAME                   VARCHAR2(50 ),
GRD_WET_QTY                 NUMBER(25,5),
GRD_DRY_QTY                 NUMBER(25,5),
GRD_QTY_UNIT_ID             VARCHAR2(15 ),
GRD_QTY_UNIT                VARCHAR2(15 ),
CONC_BASE_QTY_UNIT_ID       VARCHAR2(15 ),
CONC_BASE_QTY_UNIT          VARCHAR2(15 ),
ORIGINAL_GRD_QTY            NUMBER(25,10),
ORIGINAL_GRD_QTY_UNIT_ID    VARCHAR2(15 ),
DRY_WET_QTY_RATIO           NUMBER(25,10),
PAY_CUR_ID                  VARCHAR2(15 ),
PAY_CUR_CODE                VARCHAR2(15 ),
PAY_CUR_DECIMAL             NUMBER(2),
PARENT_INTERNAL_GMR_REF_NO  VARCHAR2(15 ),
PARENT_INTERNAL_GRD_REF_NO  VARCHAR2(15 ),
OTHER_CHARGES_AMT           NUMBER(38,18),        
GRD_TO_GMR_QTY_FACTOR       NUMBER,        
GMR_QTY                     NUMBER(25,10),
FEEDING_POINT_ID            VARCHAR2(15),
FEEDING_POINT_NAME          VARCHAR2(30),
PCDI_ID                     VARCHAR2(15) );

CREATE TABLE FCEO_FEED_CON_ELEMENT_ORIGINAL(
PROCESS_ID                    VARCHAR2(15),
INTERNAL_GMR_REF_NO           VARCHAR2(15),
INTERNAL_GRD_REF_NO           VARCHAR2(15),
ELEMENT_ID                    VARCHAR2(15),
ELEMENT_NAME                  VARCHAR2(15),
ASSAY_QTY                     NUMBER(25,5),
ASAAY_QTY_UNIT_ID             VARCHAR2(15),
ASAAY_QTY_UNIT                VARCHAR2(15),
PAYABLE_QTY                   NUMBER(25,5),
PAYABLE_QTY_UNIT_ID           VARCHAR2(15),
PAYABLE_QTY_UNIT              VARCHAR2(15),
UNDERLYING_PRODUCT_ID         VARCHAR2(15),
UNDERLYING_BASE_QTY_UNIT_ID   VARCHAR2(15),
ORIGINAL_ASAAY_QTY_UNIT_ID    VARCHAR2(15),
ORIGINAL_PAYABLE_QTY_UNIT_ID  VARCHAR2(15),
PAYABLE_RETURNABLE_TYPE       VARCHAR2(30),
ORIGINAL_PAYABLE_QTY          NUMBER(25,10),
PARENT_INTERNAL_GMR_REF_NO    VARCHAR2(15),
PARENT_INTERNAL_GRD_REF_NO    VARCHAR2(15),
SECTION_NAME                  VARCHAR2(15),        
QTY_TYPE                      VARCHAR2(10),        
PRICE                         NUMBER(25,5),        
PRICE_UNIT_ID                 VARCHAR2(15),        
PAYABLE_AMT_PRICE_CCY         NUMBER(38,18),        
PAYABLE_AMT_PAY_CCY           NUMBER(38,18),        
FX_RATE_PRICE_TO_PAY          NUMBER(38,18),        
BASE_TC_CHARGES_AMT           NUMBER(38,18),        
ESC_DESC_TC_CHARGES_AMT       NUMBER(38,18),        
RC_CHARGES_AMT                NUMBER(38,18),        
PC_CHARGES_AMT                NUMBER(38,18),        
ELEMENT_BASE_QTY_UNIT_ID      VARCHAR2(15),        
ELEMENT_BASE_QTY_UNIT         VARCHAR2(15),
PCDI_ID                     VARCHAR2(15));    

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD SUPP_GMR_REF_NO VARCHAR2(30);

CREATE TABLE EUD_ELEMENT_UNDERLYING_DETAILS(
CORPORATE_ID                VARCHAR2(15),
ELEMENT_ID                  VARCHAR2(15),
ELEMENT_NAME                VARCHAR2(15),
UNDERLYING_PRODUCT_ID       VARCHAR2(15),
UNDERLYING_PRODUCT_NAME     VARCHAR2(100),
UNDERLYING_BASE_QTY_UNIT_ID VARCHAR2(15),
UNDERLYING_BASE_QTY_UNIT    VARCHAR2(15));

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD(
PARENT_GRD_POOL_ID                      VARCHAR2(15),
PARENT_GRD_POOL_NAME                    VARCHAR2(50));

ALTER TABLE PED_PENALTY_ELEMENT_DETAILS ADD(
PARENT_STOCK_REF_NO VARCHAR2(15));

ALTER TABLE FCE_FEED_CONSUMPTION_ELEMENT ADD(
MTD_YTD                       VARCHAR2(3),
SECTION_NAME                  VARCHAR2(15),        
QTY_TYPE                      VARCHAR2(10),        
PRICE                         NUMBER(25,5),        
PRICE_UNIT_ID                 VARCHAR2(15),        
PAYABLE_AMT_PRICE_CCY         NUMBER(38,18),        
PAYABLE_AMT_PAY_CCY           NUMBER(38,18),        
FX_RATE_PRICE_TO_PAY          NUMBER(38,18),        
BASE_TC_CHARGES_AMT           NUMBER(38,18),        
ESC_DESC_TC_CHARGES_AMT       NUMBER(38,18),        
ELEMENT_BASE_QTY_UNIT_ID      VARCHAR2(15),        
ELEMENT_BASE_QTY_UNIT         VARCHAR2(15));

CREATE TABLE FCG_FEED_CONSUMPTION_GMR(
PROCESS_ID              VARCHAR2(15),
INTERNAL_GMR_REF_NO     VARCHAR2(15),
MTD_YTD                 VARCHAR2(3),
PREV_PROCESS_ID         VARCHAR2(15));

ALTER TABLE FC_FEED_CONSUMPTION ADD(
IS_NEW                        VARCHAR2(1),
MTD_YTD                       VARCHAR2(3),
OTHER_CHARGES_AMT             NUMBER(38,18),        
FEEDING_POINT_ID              VARCHAR2(15),
FEEDING_POINT_NAME            VARCHAR2(30));

CREATE TABLE FCOT_FCO_TEMP(
CORPORATE_ID                VARCHAR2(15 ),
CORPORATE_NAME              VARCHAR2(100 ),
INTERNAL_GMR_REF_NO         VARCHAR2(15 ),
INTERNAL_GRD_REF_NO         VARCHAR2(15 ),
GRD_WET_QTY                 NUMBER(25,5),
GRD_DRY_QTY                 NUMBER(25,5),
OTHER_CHARGES_AMT           NUMBER(38,18),
GRD_QTY_UNIT_ID             VARCHAR2(15 ),
GRD_QTY_UNIT                VARCHAR2(15));

CREATE TABLE FCEOT_FCEO_TEMP(
CORPORATE_ID                  VARCHAR2(15),  
INTERNAL_GMR_REF_NO           VARCHAR2(15),
INTERNAL_GRD_REF_NO           VARCHAR2(15),
ELEMENT_ID                    VARCHAR2(15),
ASSAY_QTY                     NUMBER(25,5),
ASAAY_QTY_UNIT_ID             VARCHAR2(15),
PAYABLE_QTY                   NUMBER(25,5),
PAYABLE_QTY_UNIT_ID           VARCHAR2(15),
PAYABLE_AMT_PRICE_CCY         NUMBER(38,18),
PAYABLE_AMT_PAY_CCY           NUMBER(38,18),
BASE_TC_CHARGES_AMT           NUMBER(38,18),
ESC_DESC_TC_CHARGES_AMT       NUMBER(38,18),
RC_CHARGES_AMT                NUMBER(38,18),
PC_CHARGES_AMT                NUMBER(38,18));

CREATE TABLE FCT_FC_TEMP(
GMR_REF_NO                          VARCHAR2(30),
INTERNAL_GMR_REF_NO                 VARCHAR2(15),
INTERNAL_GRD_REF_NO                 VARCHAR2(15),
INTERNAL_STOCK_REF_NO               VARCHAR2(30),
SUPP_INTERNAL_GMR_REF_NO            VARCHAR2(15),
SUPP_GMR_REF_NO                     VARCHAR2(30),                    
CORPORATE_ID                        VARCHAR2(15),
WAREHOUSE_PROFILE_ID                VARCHAR2(15),
COMPANYNAME                         VARCHAR2(100),
SHED_ID                             VARCHAR2(15),
STORAGE_LOCATION_NAME               VARCHAR2(50),
PRODUCT_ID                          VARCHAR2(15),
PRODUCT_DESC                        VARCHAR2(100),
QUALITY_ID                          VARCHAR2(15),
QUALITY_NAME                        VARCHAR2(100),                      
QTY                                 NUMBER(25,10),
DRY_WET_QTY_RATIO                   NUMBER(25,10),
WET_QTY                             NUMBER(25,10),
DRY_QTY                             NUMBER(25,10),
QTY_UNIT_ID                         VARCHAR2(15),                      
QTY_UNIT                            VARCHAR2(15),
ELEMENT_ID                          VARCHAR2(15),
ATTRIBUTE_NAME                      VARCHAR2(30),
UNDERLYING_PRODUCT_ID               VARCHAR2(15),
UNDERLYING_PRODUCT_NAME             VARCHAR2(100),
BASE_QUANTITY_UNIT_ID               VARCHAR2(15),
BASE_QUANTITY_UNIT                  VARCHAR2(15),
ASSAY_QTY                           NUMBER(25,10),                        
ASSAY_QTY_UNIT_ID                   VARCHAR2(15),                  
ASSAY_QTY_UNIT                      VARCHAR2(15),
PAYABLE_QTY                         NUMBER(25,10),                     
PAYABLE_QTY_UNIT_ID                 VARCHAR2(15),
PAYABLE_QTY_UNIT                    VARCHAR2(15),
POOL_NAME                           VARCHAR2(50),
CONC_BASE_QTY_UNIT_ID               VARCHAR2(15),
CONC_BASE_QTY_UNIT                  VARCHAR2(15),
PAY_CUR_ID                          VARCHAR2(15),
PAY_CUR_CODE                        VARCHAR2(15),
QTY_TYPE                            VARCHAR2(10),
PARENT_INTERNAL_GRD_REF_NO          VARCHAR2(15),
SECTION_NAME                        VARCHAR2(15),
GRD_BASE_QTY_CONV_FACTOR            NUMBER,
PCDI_ID                             VARCHAR2(15),
PAY_CUR_DECIMALS                    NUMBER(2),
FEEDING_POINT_ID                    VARCHAR2(15),
FEEDING_POINT_NAME                  VARCHAR2(30),
GRD_TO_GMR_QTY_FACTOR               NUMBER);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD(
FEEDING_POINT_ID                      VARCHAR2(15),
FEEDING_POINT_NAME                      VARCHAR2(30)); 

CREATE INDEX IDX_FC2 ON FC_FEED_CONSUMPTION(CORPORATE_ID,EOD_TRADE_DATE,MTD_YTD);
CREATE INDEX IDX_FCE2 ON FCE_FEED_CONSUMPTION_ELEMENT (PROCESS_ID, INTERNAL_GMR_REF_NO, INTERNAL_GRD_REF_NO, MTD_YTD, SECTION_NAME);

CREATE INDEX IDX_FCT1 ON FCT_FC_TEMP(CORPORATE_ID);
CREATE INDEX IDX_FCOT1 ON FCOT_FCO_TEMP(CORPORATE_ID);
CREATE INDEX IDX_FCEOT1 ON FCEOT_FCEO_TEMP(CORPORATE_ID);