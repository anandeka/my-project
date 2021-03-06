DROP TABLE SDD_D;

CREATE TABLE SDD_D
(
  ATTENTION                      VARCHAR2(30),
  BUYER                          VARCHAR2(65),
  CONTRACT_DATE                  VARCHAR2(30),
  CONTRACT_ITEM_NO               VARCHAR2(100),
  CONTRACT_QTY                   NUMBER(20,5),
  CONTRACT_QTY_UNIT              VARCHAR2(30),
  CONTRACT_REF_NO                VARCHAR2(50),
  CP_REF_NO                      VARCHAR2(50),
  DESTINATION_LOCATION           VARCHAR2(30),
  DISCHARGE_COUNTRY              VARCHAR2(30),
  DISCHARGE_PORT                 VARCHAR2(500),
  ETA_END                        VARCHAR2(30),
  ETA_START                      VARCHAR2(30),
  FULFILMENT_TYPE                VARCHAR2(30),
  GOODS                          VARCHAR2(30),
  INCO_TERMS                     VARCHAR2(30),
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(30),
  INTERNAL_DOC_REF_NO            VARCHAR2(30),
  INTERNAL_GMR_REF_NO            VARCHAR2(30),
  IS_OTHER_OPTIONAL_PORTS        VARCHAR2(30),
  ISSUE_DATE                     VARCHAR2(30),
  LOADING_COUNTRY                VARCHAR2(30),
  LOADING_LOCATION               VARCHAR2(30),
  LOADING_PORT                   VARCHAR2(500),
  OTHER_SHIPMENT_TERMS           VARCHAR2(30),
  PACKING_TYPE                   VARCHAR2(30),
  QTY_OF_GOODS                   NUMBER(20,5),
  QTY_OF_GOODS_UNIT              VARCHAR2(30),
  SELLER                         VARCHAR2(100),
  TOLERANCE_LEVEL                VARCHAR2(30),
  TOLERANCE_MAX                  NUMBER(25,5),
  TOLERANCE_MIN                  NUMBER(25,5),
  TOLERANCE_TYPE                 VARCHAR2(30),
  VESSEL_NAME                    VARCHAR2(100),
  BL_DATE                        VARCHAR2(30),
  BL_NUMBER                      VARCHAR2(50),
  BL_QUANTITY                    NUMBER(20,5),
  BL_QUANTITY_UNIT               VARCHAR2(30),
  OPTIONAL_DESTIN_PORTS          VARCHAR2(30),
  OPTIONAL_ORIGIN_PORTS          VARCHAR2(30),
  CREATED_DATE                   VARCHAR2(30),
  PARITY_LOCATION                VARCHAR2(1000),
  PRODUCTANDQUALITY              VARCHAR2(230),
  NOTIFYPARITY                   VARCHAR2(40),
  SHIPPER                        VARCHAR2(65),
  NOTES                          VARCHAR2(4000),
  SPECIALINSTRUCTIONS            VARCHAR2(4000),
  VOYAGENUMBER                   VARCHAR2(50),
  SHIPPERREFNO                   VARCHAR2(50),
  TRANSSHIPMENTPORT              VARCHAR2(500),
  ETADESTINATIONPORT             VARCHAR2(500),
  SHIPPERSINSTRUCTIONS           VARCHAR2(4000),
  CARRIERAGENTSENDORSEMENTS      VARCHAR2(4000),
  WHOLENEWREPORT                 VARCHAR2(30),
  CONTAINER_NOS                  VARCHAR2(50),
  QUANTITY                       NUMBER(20,5),
  QUANTITY_UNIT                  VARCHAR2(50),
  QUANTITY_DECIMALS              VARCHAR2(30),
  NET_WEIGNT_GMR                 NUMBER(20,5),
  NET_WEIGHT_UNIT_GMR            VARCHAR2(30),
  DECIMALS                       VARCHAR2(30),
  BLDATE_BLNO                    VARCHAR2(80),
  BL_QUANTITY_DECIMALS           VARCHAR2(30),
  ACTIVITY_DATE                  VARCHAR2(30),
  FLIGHT_NUMBER                  VARCHAR2(50),
  DESTINATION_AIRPORT            VARCHAR2(30),
  AWB_DATE                       VARCHAR2(30),
  AWB_NUMBER                     VARCHAR2(50),
  AWB_QUANTITY                   NUMBER(20,5),
  LOADING_AIRPORT                VARCHAR2(30),
  LOADING_DATE                   VARCHAR2(30),
  ENDORSEMENTS                   VARCHAR2(4000),
  OTHER_AIRWAY_BILLING_ITEM      VARCHAR2(30),
  NO_OF_PIECES                   VARCHAR2(50),
  NATURE_OF_GOOD                 VARCHAR2(100),
  DIMENSIONS                     VARCHAR2(100),
  STOCK_REF_NO                   VARCHAR2(100),
  NET_WEIGHT                     NUMBER(25,5),
  TARE_WEIGHT                    NUMBER(20,5),
  GROSS_WEIGHT                   NUMBER(20,5),
  COMMODITY_DESCRIPTION          VARCHAR2(4000),
  COMMENTS                       VARCHAR2(1000),
  ACTIVITY_REF_NO                VARCHAR2(30),
  WEIGHER                        VARCHAR2(65),
  WEIGHER_NOTE_NO                VARCHAR2(50),
  WEIGHING_DATE                  VARCHAR2(30),
  REMARKS                        VARCHAR2(30),
  RAIL_NAME_NUMBER               VARCHAR2(150),
  RR_DATE                        VARCHAR2(30),
  RR_NUMBER                      VARCHAR2(50),
  TOTAL_QTY                      NUMBER(20,5),
  RR_QTY                         NUMBER(20,5),
  TRUCK_NUMBER                   VARCHAR2(50),
  CMR_DATE                       VARCHAR2(30),
  CMR_NUMBER                     VARCHAR2(50),
  CMR_QUANTITY                   NUMBER(20,5),
  OTHER_TRUCKING_TERMS           VARCHAR2(30),
  TRUCKING_INSTRUCTIONS          VARCHAR2(4000)
);

DROP TABLE SAD_D;

CREATE TABLE SAD_D
(
  ATTENTION                      VARCHAR2(30),
  BUYER                          VARCHAR2(65),
  CONTRACT_DATE                  VARCHAR2(30),
  CONTRACT_ITEM_NO               VARCHAR2(100),
  CONTRACT_QTY                   NUMBER(20,5),
  CONTRACT_QTY_UNIT              VARCHAR2(30),
  CONTRACT_REF_NO                VARCHAR2(50),
  CP_REF_NO                      VARCHAR2(50),
  DISCHARGE_COUNTRY              VARCHAR2(30),
  DISCHARGE_PORT                 VARCHAR2(500),
  ETA_END                        VARCHAR2(30),
  ETA_START                      VARCHAR2(30),
  FULFILMENT_TYPE                VARCHAR2(30),
  GOODS                          VARCHAR2(30),
  INCO_TERMS                     VARCHAR2(30),
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(30),
  INTERNAL_DOC_REF_NO            VARCHAR2(30),
  INTERNAL_GMR_REF_NO            VARCHAR2(30),
  IS_OTHER_OPTIONAL_PORTS        VARCHAR2(30),
  ISSUE_DATE                     VARCHAR2(30),
  LOADING_COUNTRY                VARCHAR2(30),
  LOADING_PORT                   VARCHAR2(500),
  OTHER_SHIPMENT_TERMS           VARCHAR2(30),
  PACKING_TYPE                   VARCHAR2(30),
  QTY_OF_GOODS                   NUMBER(20,5),
  QTY_OF_GOODS_UNIT              VARCHAR2(30),
  SELLER                         VARCHAR2(100),
  TOLERANCE_LEVEL                VARCHAR2(30),
  TOLERANCE_MAX                  NUMBER(25,5),
  TOLERANCE_MIN                  NUMBER(25,5),
  TOLERANCE_TYPE                 VARCHAR2(30),
  VESSEL_NAME                    VARCHAR2(100),
  BL_DATE                        VARCHAR2(30),
  BL_NUMBER                      VARCHAR2(50),
  BL_QUANTITY                    NUMBER(20,5),
  BL_QUANTITY_UNIT               VARCHAR2(30),
  OPTIONAL_DESTIN_PORTS          VARCHAR2(30),
  OPTIONAL_ORIGIN_PORTS          VARCHAR2(30),
  CREATED_DATE                   VARCHAR2(30),
  PARITY_LOCATION                VARCHAR2(1000),
  PRODUCTANDQUALITY              VARCHAR2(230),
  NOTIFYPARITY                   VARCHAR2(40),
  SHIPPER                        VARCHAR2(65),
  NOTES                          VARCHAR2(4000),
  SPECIALINSTRUCTIONS            VARCHAR2(4000),
  VOYAGENUMBER                   VARCHAR2(50),
  SHIPPERREFNO                   VARCHAR2(50),
  TRANSSHIPMENTPORT              VARCHAR2(500),
  ETADESTINATIONPORT             VARCHAR2(500),
  SHIPPERSINSTRUCTIONS           VARCHAR2(4000),
  CARRIERAGENTSENDORSEMENTS      VARCHAR2(4000),
  WHOLENEWREPORT                 VARCHAR2(30),
  CONTAINER_NOS                  VARCHAR2(50),
  QUANTITY                       NUMBER(20,5),
  QUANTITY_UNIT                  VARCHAR2(50),
  QUANTITY_DECIMALS              VARCHAR2(30),
  NET_WEIGNT_GMR                 NUMBER(20,5),
  NET_WEIGHT_UNIT_GMR            VARCHAR2(30),
  DECIMALS                       VARCHAR2(30),
  BLDATE_BLNO                    VARCHAR2(80),
  BL_QUANTITY_DECIMALS           VARCHAR2(30),
  ACTIVITY_DATE                  VARCHAR2(30),
  FLIGHT_NUMBER                  VARCHAR2(50),
  DESTINATION_AIRPORT            VARCHAR2(30),
  AWB_DATE                       VARCHAR2(30),
  AWB_NUMBER                     VARCHAR2(50),
  AWB_QUANTITY                   NUMBER(20,5),
  LOADING_AIRPORT                VARCHAR2(30),
  LOADING_DATE                   VARCHAR2(30),
  ENDORSEMENTS                   VARCHAR2(4000),
  OTHER_AIRWAY_BILLING_ITEM      VARCHAR2(30),
  NO_OF_PIECES                   VARCHAR2(50),
  NATURE_OF_GOOD                 VARCHAR2(100),
  DIMENSIONS                     VARCHAR2(100),
  STOCK_REF_NO                   VARCHAR2(100),
  NET_WEIGHT                     NUMBER(25,5),
  TARE_WEIGHT                    NUMBER(20,5),
  GROSS_WEIGHT                   NUMBER(20,5),
  COMMODITY_DESCRIPTION          VARCHAR2(4000),
  COMMENTS                       VARCHAR2(1000),
  ACTIVITY_REF_NO                VARCHAR2(30),
  WEIGHER                        VARCHAR2(65),
  WEIGHER_NOTE_NO                VARCHAR2(50),
  WEIGHING_DATE                  VARCHAR2(30),
  REMARKS                        VARCHAR2(30),
  RAIL_NAME_NUMBER               VARCHAR2(150),
  RR_DATE                        VARCHAR2(30),
  RR_NUMBER                      VARCHAR2(50),
  TOTAL_QTY                      NUMBER(20,5),
  RR_QTY                         NUMBER(20,5),
  TRUCK_NUMBER                   VARCHAR2(50),
  CMR_DATE                       VARCHAR2(30),
  CMR_NUMBER                     VARCHAR2(50),
  CMR_QUANTITY                   NUMBER(20,5),
  OTHER_TRUCKING_TERMS           VARCHAR2(30),
  TRUCKING_INSTRUCTIONS          VARCHAR2(4000),
  LOADING_LOCATION               VARCHAR2(30),
  DESTINATION_LOCATION           VARCHAR2(30)
);