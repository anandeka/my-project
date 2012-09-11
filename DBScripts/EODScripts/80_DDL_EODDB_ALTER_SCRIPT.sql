CREATE TABLE TCR_TEMP_CR (
CORPORATE_ID                                VARCHAR2(15),
CORPORATE_NAME                              VARCHAR2(100),
INTERNAL_CONTRACT_REF_NO                    VARCHAR2(15),
CONTRACT_REF_NO                             VARCHAR2(30),
DELIVERY_ITEM_NO                            VARCHAR2(30),
SMELTER_ID                                  VARCHAR2(15),
SMELTER_NAME                                VARCHAR2(100),
SUPPLIER_ID                                 VARCHAR2(15),
SUPPLIER_NAME                               VARCHAR2(100),
QUALITY_ID                                  VARCHAR2(15),
QUALITY_NAME                                VARCHAR2(100),
INTERNAL_INVOICE_REF_NO                     VARCHAR2(15),
INVOICE_REF_NO                              VARCHAR2(15),
INVOICE_DATE                                DATE,
INTERNAL_GMR_REF_NO                         VARCHAR2(15),
GMR_REF_NO                                  VARCHAR2(30),
PRODUCT_ID                                  VARCHAR2(15),
PRODUCT_NAME                                VARCHAR2(100),
BL_DATE                                     DATE,
LOADING_COUNTRY_ID                          VARCHAR2(15),
LOADING_COUNTRY                             VARCHAR2(100),
LOADING_STATE_ID                            VARCHAR2(15),
LOADING_STATE                               VARCHAR2(100),
LOADING_CITY_ID                             VARCHAR2(15),
LOADING_CITY                                VARCHAR2(100),
DISCHARGE_COUNTRY_ID                        VARCHAR2(15),
DISCHARGE_COUNTRY                           VARCHAR2(100),
DISCHARGE_STATE_ID                          VARCHAR2(15),
DISCHARGE_STATE                             VARCHAR2(100),
DISCHARGE_CITY_ID                           VARCHAR2(15),
DISCHARGE_CITY                              VARCHAR2(100),
LOADING_NATIONAL_CUR_ID                     VARCHAR2(15),
LOADING_NATIONAL_CUR_CODE                   VARCHAR2(15),
DISCHARGE_NATIONAL_CUR_ID                   VARCHAR2(15),
DISCHARGE_NATIONAL_CUR_CODE                 VARCHAR2(15),
NO_OF_CONTAINERS                            NUMBER(5),
INCOTERM_ID                                 VARCHAR2(15),
INCOTERM                                    VARCHAR2(100),
BASE_CUR_ID                                 VARCHAR2(15),
BASE_CUR_CODE                               VARCHAR2(15),
INVENTORY_CUR_ID                            VARCHAR2(15),
INVENTORY_CUR_CODE                            VARCHAR2(15),
LOADING_COUNTRY_CUR_ID                      VARCHAR2(15),
DISCHARGE_COUNTRY_CUR_ID                    VARCHAR2(15),
PRODUCT_BASE_QTY_UNIT_ID                    VARCHAR2(15),
GRD_QTY                                     NUMBER(25,10),
GRD_QTY_UNIT_ID                             VARCHAR2(15),
GRD_QTY_UNIT                                VARCHAR2(15),
INVOICE_ITEM_AMOUNT                         NUMBER(25,10),
CONTRACT_PRICE                              NUMBER(25,10),
PRICE_UNIT_ID                               VARCHAR2(15),
PRODUCT_PRICE_UNIT_ID                       VARCHAR2(15),
INVOICE_CUR_ID                              VARCHAR2(15),
INVOICE_CUR_CODE                            VARCHAR2(15),
LOADING_DATE                                DATE,
GMR_EFF_DATE                                DATE,
CFX_INV_TO_BASE                             NUMBER(25,10),
CFX_BASE_TO_LOADING_COUNTRY                 NUMBER(25,10),
CFX_BASE_TO_DISCHARGE_COUNTRY               NUMBER(25,10),
GRD_QTY_CONV_FACTOR                         NUMBER(25,10),
CP_TO_PROD_BASE_PRICE_CONV                  NUMBER(25,10),
RECORD_RANK                                 NUMBER(10),
GMR_RANK                                 NUMBER(10),
PAYABLE_QTY                                 NUMBER(25,10),
PAYABLE_QTY_UNIT_ID                         VARCHAR2(15),
UNDERLYING_PRODUCT_ID                       VARCHAR2(15),
UNDERLYING_BASE_QUANTITY_UNIT               VARCHAR2(15),
PAYABLE_QTY_CONV_FACTOR                     NUMBER(25,10),
SECTION_NAME                                VARCHAR2(100));

CREATE INDEX IDX_TCR1 ON TCR_TEMP_CR(CORPORATE_ID, SECTION_NAME);

DROP INDEX IDX_VD;
CREATE INDEX IDX_VD2 ON VD_VOYAGE_DETAIL(PROCESS_ID,STATUS);

CREATE TABLE TCSM_TEMP_CONTRACT_STATUS_MAIN(
INTERNAL_CONTRACT_REF_NO        VARCHAR2(15),
CONTRACT_REF_NO                 VARCHAR2(30),
CORPORATE_ID                    VARCHAR2(15),
CORPORATE_NAME                  VARCHAR2(100),
CP_ID                           VARCHAR2(15),
ELEMENT_ID                      VARCHAR2(15),
ATTRIBUTE_NAME                  VARCHAR2(50),
CP_NAME                         VARCHAR2(100),
CONTRACT_STATUS                 VARCHAR2(30),
PRODUCT_ID                      VARCHAR2(15),
PRODUCT_DESC                    VARCHAR2(100),
OPEN_QTY                        NUMBER(25,5),
QTY_UNIT_ID                     VARCHAR2(15),
QTY_UNIT                        VARCHAR2(15),                     
INVOICE_CUR_ID                  VARCHAR2(15),
INVOICE_CUR_CODE                VARCHAR2(15));

CREATE TABLE TCS1_TEMP_CS_PAYABLE(
CORPORATE_ID                    VARCHAR2(15),
INTERNAL_CONTRACT_REF_NO        VARCHAR2(15),
ELEMENT_ID                      VARCHAR2(15),
LANDED_QTY                      NUMBER(25,5));

CREATE TABLE TCS2_TEMP_CS_PRICED(
CORPORATE_ID                    VARCHAR2(15),
INTERNAL_CONTRACT_REF_NO        VARCHAR2(15),
ELEMENT_ID                      VARCHAR2(15),
PRICED_QTY                      NUMBER(25,5));

CREATE INDEX IDX_TSCM ON TCSM_TEMP_CONTRACT_STATUS_MAIN (Corporate_Id,Internal_Contract_Ref_No,Element_Id);
CREATE INDEX IDX_TSC1 ON TCS1_TEMP_CS_PAYABLE (Corporate_Id,Internal_Contract_Ref_No,Element_Id);
CREATE INDEX IDX_TCS2 ON TCS2_TEMP_CS_PRICED (Corporate_Id,Internal_Contract_Ref_No,Element_Id);


