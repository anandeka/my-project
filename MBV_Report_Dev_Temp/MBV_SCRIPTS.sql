CREATE TABLE PFRH_PRICE_FIX_REPORT_HEADER(
PROCESS_ID                         VARCHAR2(15),
EOD_TRADE_DATE                     DATE,
CORPORATE_ID                       VARCHAR2(15),
CORPORATE_NAME                     VARCHAR2(100),
PRODUCT_ID                         VARCHAR2(15),
PRODUCT_NAME                       VARCHAR2(200),
INSTRUMENT_ID                      VARCHAR2(15),
INSTRUMENT_NAME                    VARCHAR2(200),
PRICED_ARRIVED_QTY                 NUMBER(25,5),
PRICED_DELIVERED_QTY               NUMBER(25,5),
REALIZED_QTY                       NUMBER(25,5),
REALIZED_QTY_PREV_MONTH            NUMBER(25,5),
REALIZED_QTY_CURRENT_MONTH         NUMBER(25,5),
REALIZED_VALUE                     NUMBER(25,5),
PURCHASE_PRICE_FIX_QTY             NUMBER(25,5),
WAP_PURCHASE_PRICE_FIXATIONS       NUMBER(25,5),
SALES_PRICE_FIXATION_QTY           NUMBER(25,5),
WAP_SALES_PRICE_FIXATIONS          NUMBER(25,5),
PRICE_FIX_QTY_PURCHASE_OB          NUMBER(25,5),
PRICE_FIX_QTY_SALES_OB             NUMBER(25,5),
PRICE_FIX_QTY_PURCHASE_NEW         NUMBER(25,5),
PRICE_FIX_QTY_SALES_NEW            NUMBER(25,5));

CREATE TABLE PFRD_PRICE_FIX_REPORT_DETAIL(
PROCESS_ID                         VARCHAR2(15),
EOD_TRADE_DATE                     DATE,
SECTION_NAME                       VARCHAR2(100),
PURCHASE_SALES                     VARCHAR2(10),                      
CORPORATE_ID                       VARCHAR2(15),
CORPORATE_NAME                     VARCHAR2(100),
PRODUCT_ID                         VARCHAR2(15),
PRODUCT_NAME                       VARCHAR2(200),
ELEMENT_ID                         VARCHAR2(15),
INSTRUMENT_ID                      VARCHAR2(15),
INSTRUMENT_NAME                    VARCHAR2(200),
CP_ID                              VARCHAR2(15),
CP_NAME                            VARCHAR2(100),
INTERNAL_CONTRACT_REF_NO           VARCHAR2(15),
DELIVERY_ITEM_NO                   VARCHAR2(20),
CONTRACT_TYPE                      VARCHAR2(20),
PCDI_ID                            VARCHAR2(15),
CONTRACT_REF_NO_DEL_ITEM_NO        VARCHAR2(50),
INTERNAL_GMR_REF_NO                VARCHAR2(15),
GMR_REF_NO                         VARCHAR2(15),
PRICE_FIXED_DATE                   DATE,    
INTERNAL_ACTION_REF_NO             VARCHAR2(15),
PFD_ID                             VARCHAR2(15),
IS_NEW_PFC                         VARCHAR2(1),
PF_REF_NO                          VARCHAR2(100),
FIXED_QTY                          NUMBER(25,10),
FIXED_UNIT_BASE_QTY_FACTOR         NUMBER,
PRICE                              NUMBER(25,10),
PRICE_UNIT_ID                      VARCHAR2(15),
PRICE_UNIT_CUR_ID                  VARCHAR2(15),    
PRICE_UNIT_CUR_CODE                VARCHAR2(15),    
PRICE_UNIT_WEIGHT_UNIT_ID          VARCHAR2(15),    
PRICE_UNIT_WEIGHT_UNIT             VARCHAR2(15),    
PRICE_UNIT_WEIGHT                  NUMBER(7,2),
PRICE_UNIT_NAME                    VARCHAR2(50),
FX_PRICE_TO_BASE_CUR               NUMBER(25,10),
PRICE_IN_BASE_CUR                  NUMBER(25,10),
CONSUMED_QTY                       NUMBER(25,10),
FIXATION_VALUE                     NUMBER(25,10));


CREATE TABLE DDR_DERIVATIVE_DIFF_REPORT(
PROCESS_ID                         VARCHAR2(15),
EOD_TRADE_DATE                     DATE,
CORPORATE_ID                       VARCHAR2(15),
CORPORATE_NAME                     VARCHAR2(100),
PRODUCT_ID                         VARCHAR2(15),
PRODUCT_NAME                       VARCHAR2(200),
EXCHANGE_ID                        VARCHAR2(15),
EXCHANGE_NAME                      VARCHAR2(200),
INSTRUMENT_ID                      VARCHAR2(15),
INSTRUMENT_NAME                    VARCHAR2(200),
TRADE_DATE                         DATE,
INTERNAL_DERIVATIVE_REF_NO         VARCHAR2(10),
DERIVATIVE_REF_NO                  VARCHAR2(30),
EXTERNAL_REF_NO                    VARCHAR2(50),
TRADE_TYPE                         VARCHAR2(4),
TRADE_QTY                          NUMBER(25,5),
TRADE_PRICE                        NUMBER(25,5),
TRADE_PRICE_UNIT                   VARCHAR2(50),
PROMPT_DATE                        VARCHAR2(15),
FX_TRADE_TO_BASE_CCY               NUMBER(25,10),
TRADE_PRICE_IN_BASE_CCY            NUMBER(25,5),
TRADE_VALUE_IN_BASE_CCY           NUMBER(25,5),
VALUATION_PRICE                    NUMBER(25,5),
FX_VALUATION_TO_BASE_CCY           NUMBER(25,10),
VALUATION_PRICE_IN_BASE_CCY        NUMBER(25,5),
MONTH_END_PRICE                    NUMBER(25,5),
MONTH_END_PRICE_IN_BASE_CCY        NUMBER(25,5),
REF_PRICE_DIFF                     NUMBER(25,5),
VALUE_DIFF_REF_PRICE_DIFF          NUMBER(25,5));

ALTER TABLE PCS_PURCHASE_CONTRACT_STATUS ADD INSTRUMENT_ID VARCHAR2(15);
ALTER TABLE TCS2_TEMP_CS_PRICED ADD INSTRUMENT_ID VARCHAR2(15);

ALTER TABLE TCSM_TEMP_CONTRACT_STATUS_MAIN ADD INSTRUMENT_ID VARCHAR2(15);
ALTER TABLE TCS1_TEMP_CS_PAYABLE ADD INSTRUMENT_ID VARCHAR2(15);

CREATE TABLE CSS_CONTRACT_STATUS_SUMMARY(
PROCESS_ID                VARCHAR2(15),
EOD_TRADE_DATE            DATE,
CORPORATE_ID              VARCHAR2(15),
CORPORATE_NAME            VARCHAR2(100),
PRODUCT_ID                VARCHAR2(15),
PRODUCT_NAME              VARCHAR2(200),
CONTRACT_TYPE             VARCHAR2(30),
PURCHASE_SALES            VARCHAR2(1),
INSTRUMENT_ID             VARCHAR2(15),
PRICED_ARRIVED_QTY        NUMBER,
PRICED_UNARRIVED_QTY      NUMBER,
UNPRICED_ARRIVED_QTY      NUMBER,
UNPRICED_UNARRIVED_QTY    NUMBER,
PRICED_DELIVERED_QTY      NUMBER,
PRICED_UNDELIVERED_QTY    NUMBER,
UNPRICED_DELIVERED_QTY    NUMBER,
UNPRICED_UNDELIVERED_QTY  NUMBER,
QTY_UNIT_ID               VARCHAR2(30),
QTY_UNIT                  VARCHAR2(15));

CREATE TABLE MBV_METAL_BALANCE_VALUATION(
PROCESS_ID                  VARCHAR2(15),
EOD_TRADE_DATE              DATE,
CORPORATE_ID                VARCHAR2(15 ),
CORPORATE_NAME              VARCHAR2(100 ),
PRODUCT_ID                  VARCHAR2(15 ),
PRODUCT_NAME                VARCHAR2(200 ),
INSTRUMENT_ID               VARCHAR2(15 ),
INSTRUMENT_NAME             VARCHAR2(200 ),
EXCHANGE_ID                 VARCHAR2(15 ),
EXCHANGE_NAME               VARCHAR2(200 ),
PHY_REALIZED_OB             NUMBER(25,5),
PHY_REALIZED_QTY            NUMBER(25,5),
PHY_REALIZED_PNL            NUMBER(25,5),
PHY_REALIZED_CB             NUMBER(25,5),
PHY_UNR_PRICE_INV_PRICE     NUMBER(25,5),
PHY_UNR_PRICE_NA_INV_PRICE  NUMBER(25,5),
PHY_UNR_PRICE_ND_INV_PRICE  NUMBER(25,5),
REFERENTIAL_PRICE_DIFF      NUMBER(25,5),
CONTANGO_BW_DIFF            NUMBER(25,5),
PRICED_ARRIVED_QTY          NUMBER(25,5),
PRICED_NOT_ARRIVED_QTY      NUMBER(25,5),
UNPRICED_ARRIVED_QTY        NUMBER(25,5),
UNPRICED_NOT_ARRIVED_QTY    NUMBER(25,5),
PRICED_DELIVERED_QTY        NUMBER(25,5),
PRICED_NOT_DELIVERED_QTY    NUMBER(25,5),
UNPRICED_DELIVERED_QTY      NUMBER(25,5),
UNPRICED_NOT_DELIVERED_QTY  NUMBER(25,5),
METAL_DEBT_QTY              NUMBER(25,5),
METAL_DEBT_VALUE            NUMBER(25,5),
INVENTORY_UNREAL_PNL        NUMBER(25,5),
MONTH_END_PRICE             NUMBER(25,5),
MONTH_END_PRICE_UNIT_ID     VARCHAR2(15 ),
MONTH_END_PRICE_UNIT_NAME   VARCHAR2(15 ),
DER_REALIZED_QTY            NUMBER(25,5),
DER_REALIZED_PNL            NUMBER(25,5),
DER_UNREALIZED_PNL          NUMBER(25,5),
DER_REALIZED_OB             NUMBER(25,5),
QTY_DECIMALS                NUMBER(2),
CCY_DECIMALS                NUMBER(2),
TOTAL_INV_QTY               NUMBER(25,5),
PRICED_INV_QTY              NUMBER(25,5),
UNPRICED_INV_QTY            NUMBER(25,5),
UNR_PHY_PRICED_INV_PNL      NUMBER(25,5),
UNR_PHY_PRICED_NA_PNL       NUMBER(25,5),
UNR_PHY_PRICED_ND_PNL       NUMBER(25,5),
DER_REF_PRICE_DIFF          NUMBER(25,5),
PHY_REF_PRICE_DIFF          NUMBER(25,5),
CONTANGO_DUETO_QTY_PRICE    NUMBER(25,5),
CONTANGO_DUETO_QTY          NUMBER(25,5),
ACTUAL_HEDGED_QTY           NUMBER(25,5),
HEDGE_EFFECTIVENESS         NUMBER(25,5),
CURRENCY_UNIT               VARCHAR2(15 ),
QTY_UNIT                    VARCHAR2(15),
PRICED_NOT_ARRIVED_BM            NUMBER(25,5),
PRICED_NOT_ARRIVED_RM            NUMBER(25,5),
UNPRICED_ARRIVED_BM        NUMBER(25,5),
UNPRICED_ARRIVED_RM        NUMBER(25,5),
SALES_UNPRICED_DELIVERED_BM    NUMBER(25,5),
SALES_UNPRICED_DELIVERED_RM    NUMBER(25,5),
SALES_PRICED_NOT_DELIVERED_BM    NUMBER(25,5),
SALES_PRICED_NOT_DELIVERED_RM    NUMBER(25,5));

CREATE TABLE DIWAP_DI_WEIGHTED_AVG_PRICE(
PROCESS_ID                   VARCHAR2(15 CHAR),
EOD_TRADE_DATE               DATE,
PURCHASE_SALES               VARCHAR2(10),
CORPORATE_ID                 VARCHAR2(15),
CORPORATE_NAME               VARCHAR2(100),
PRODUCT_ID                   VARCHAR2(15),
PRODUCT_NAME                 VARCHAR2(200),
INSTRUMENT_ID                VARCHAR2(15),
INSTRUMENT_NAME              VARCHAR2(200),
PCDI_ID                      VARCHAR2(15),
CONTRACTT_TYPE               VARCHAR2(15),
WEIGHTED_AVG_PRICE           NUMBER(25,5),
WAP_PRICE_UNIT_ID            VARCHAR2(15),
WAP_PRICE_UNIT_NAME          VARCHAR2(50),
ELEMENT_ID                   VARCHAR2(15),
ELEMENT_NAME                 VARCHAR2(30));


ALTER  TABLE PCM_PHYSICAL_CONTRACT_MAIN ADD IS_PASS_THROUGH VARCHAR2(1) DEFAULT 'N';
