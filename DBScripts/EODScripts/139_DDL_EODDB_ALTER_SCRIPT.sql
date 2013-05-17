drop table PROCESS_GRD;
create table PROCESS_GRD
(
  CORPORATE_ID                   VARCHAR2(15),
  INTERNAL_GRD_REF_NO            VARCHAR2(15),
  INTERNAL_GMR_REF_NO            VARCHAR2(15),
  PRODUCT_ID                     VARCHAR2(15),
  IS_AFLOAT                      CHAR(1) default 'N',
  STATUS                         VARCHAR2(15),
  QTY                            NUMBER(35,10),
  QTY_UNIT_ID                    VARCHAR2(15),
  GROSS_WEIGHT                   NUMBER(35,10),
  TARE_WEIGHT                    NUMBER(35,10),
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15),
  INT_ALLOC_GROUP_ID             VARCHAR2(15),
  PACKING_SIZE_ID                VARCHAR2(15),
  CONTAINER_NO                   VARCHAR2(50),
  SEAL_NO                        VARCHAR2(50),
  MARK_NO                        VARCHAR2(50),
  WAREHOUSE_REF_NO               VARCHAR2(50),
  NO_OF_UNITS                    NUMBER(9),
  QUALITY_ID                     VARCHAR2(15),
  WAREHOUSE_PROFILE_ID           VARCHAR2(15),
  SHED_ID                        VARCHAR2(15),
  ORIGIN_ID                      VARCHAR2(15),
  CROP_YEAR_ID                   VARCHAR2(15),
  PARENT_ID                      VARCHAR2(15),
  IS_RELEASED_SHIPPED            CHAR(1) default 'N',
  RELEASE_SHIPPED_NO_OF_UNITS    NUMBER(9),
  IS_WRITE_OFF                   CHAR(1) default 'N',
  WRITE_OFF_NO_OF_UNITS          NUMBER(9),
  IS_DELETED                     CHAR(1) default 'N',
  IS_MOVED_OUT                   CHAR(1),
  MOVED_OUT_NO_OF_UNITS          NUMBER(9),
  TOTAL_NO_OF_UNITS              NUMBER(9),
  TOTAL_QTY                      NUMBER(35,10),
  MOVED_OUT_QTY                  NUMBER(35,10),
  RELEASE_SHIPPED_QTY            NUMBER(35,10),
  WRITE_OFF_QTY                  NUMBER(35,10),
  TITLE_TRANSFER_OUT_QTY         NUMBER(35,10),
  TITLE_TRANSFER_OUT_NO_OF_UNITS NUMBER(9),
  WAREHOUSE_RECEIPT_NO           VARCHAR2(50),
  WAREHOUSE_RECEIPT_DATE         DATE,
  CONTAINER_SIZE                 VARCHAR2(50),
  REMARKS                        VARCHAR2(3000),
  IS_ADDED_TO_POOL               CHAR(1) default 'N',
  LOADING_DATE                   DATE,
  LOADING_COUNTRY_ID             VARCHAR2(15),
  LOADING_PORT_ID                VARCHAR2(15),
  IS_ENTIRE_ITEM_LOADED          CHAR(1),
  IS_WEIGHT_FINAL                CHAR(1),
  BL_NUMBER                      VARCHAR2(15),
  BL_DATE                        DATE,
  PARENT_INTERNAL_GRD_REF_NO     VARCHAR2(15),
  DISCHARGED_QTY                 NUMBER(35,10),
  IS_VOYAGE_STOCK                CHAR(1),
  ALLOCATED_QTY                  NUMBER(35,10),
  INTERNAL_STOCK_REF_NO          VARCHAR2(30),
  LANDED_NO_OF_UNITS             NUMBER(9),
  LANDED_NET_QTY                 NUMBER(35,10),
  LANDED_GROSS_QTY               NUMBER(35,10),
  SHIPPED_NO_OF_UNITS            NUMBER(9),
  SHIPPED_NET_QTY                NUMBER(35,10),
  SHIPPED_GROSS_QTY              NUMBER(35,10),
  CURRENT_QTY                    NUMBER(35,10),
  STOCK_STATUS                   VARCHAR2(50),
  PRODUCT_SPECS                  VARCHAR2(1000),
  SOURCE_TYPE                    VARCHAR2(20),
  SOURCE_INT_STOCK_REF_NO        VARCHAR2(15),
  SOURCE_INT_PURCHASE_REF_NO     VARCHAR2(15),
  SOURCE_INT_POOL_REF_NO         VARCHAR2(15),
  IS_FULFILLED                   CHAR(1) default 'N',
  INVENTORY_STATUS               VARCHAR2(50),
  TRUCK_RAIL_NUMBER              VARCHAR2(50),
  TRUCK_RAIL_TYPE                VARCHAR2(50),
  INTERNAL_ACTION_REF_NO         VARCHAR2(15),
  PACKING_TYPE_ID                VARCHAR2(15),
  HANDLED_AS                     VARCHAR2(15),
  ALLOCATED_NO_OF_UNITS          NUMBER(9),
  CURRENT_NO_OF_UNITS            NUMBER(9),
  STOCK_CONDITION                VARCHAR2(15),
  GRAVITY_TYPE_ID                VARCHAR2(15),
  GRAVITY                        NUMBER(35,10),
  DENSITY_MASS_QTY_UNIT_ID       VARCHAR2(15),
  DENSITY_VOLUME_QTY_UNIT_ID     VARCHAR2(15),
  GRAVITY_TYPE                   VARCHAR2(30),
  CUSTOMS_ID                     VARCHAR2(15),
  TAX_ID                         VARCHAR2(15),
  DUTY_ID                        VARCHAR2(15),
  CUSTOMER_SEAL_NO               VARCHAR2(50),
  BRAND                          VARCHAR2(50),
  NO_OF_CONTAINERS               NUMBER(9),
  NO_OF_BAGS                     NUMBER(9),
  NO_OF_PIECES                   NUMBER(9),
  RAIL_CAR_NO                    VARCHAR2(50),
  SDCTS_ID                       VARCHAR2(15),
  PARTNERSHIP_TYPE               VARCHAR2(20),
  DBD_ID                         VARCHAR2(15),
  PROCESS_ID                     VARCHAR2(15),
  PAYMENT_DUE_DATE               DATE,
  PROFIT_CENTER_ID               VARCHAR2(15),
  STRATEGY_ID                    VARCHAR2(15),
  IS_WARRANT                     CHAR(1),
  WARRANT_NO                     VARCHAR2(15),
  PCDI_ID                        VARCHAR2(15),
  SUPP_CONTRACT_ITEM_REF_NO      VARCHAR2(15),
  SUPPLIER_PCDI_ID               VARCHAR2(15),
  PAYABLE_RETURNABLE_TYPE        VARCHAR2(10),
  IS_TRANS_SHIP                  CHAR(1),
  IS_MARK_FOR_TOLLING            CHAR(1),
  TOLLING_QTY                    NUMBER(35,10),
  TOLLING_STOCK_TYPE             VARCHAR2(30),
  ELEMENT_ID                     VARCHAR2(15),
  EXPECTED_SALES_CCY             VARCHAR2(15),
  CARRY_OVER_QTY                 NUMBER(35,10),
  SUPP_INTERNAL_GMR_REF_NO       VARCHAR2(15),
  DRY_QTY                        NUMBER(35,10),
  QTY_UNIT                       VARCHAR2(15),
  DRY_WET_RATIO                  NUMBER(25,10),
  GRD_TO_GMR_QTY_FACTOR          NUMBER,
  QUALITY_NAME                   VARCHAR2(200),
  PROFIT_CENTER_SHORT_NAME       VARCHAR2(15),
  PROFIT_CENTER_NAME             VARCHAR2(30),
  ASSAY_HEADER_ID                VARCHAR2(15),
  WEG_AVG_PRICING_ASSAY_ID       VARCHAR2(15),
  CONC_PRODUCT_ID                VARCHAR2(15),
  CONC_PRODUCT_NAME              VARCHAR2(100),
  PRODUCT_NAME                   VARCHAR2(200),
  BASE_QTY_UNIT_ID               VARCHAR2(15),
  BASE_QTY_UNIT                  VARCHAR2(15),
  BASE_QTY_CONV_FACTOR           NUMBER,
  SUPP_GMR_REF_NO                VARCHAR2(30),
  PARENT_GRD_POOL_ID             VARCHAR2(15),
  PARENT_GRD_POOL_NAME           VARCHAR2(50),
  POOL_ID                        VARCHAR2(15),
  POOL_NAME                      VARCHAR2(50),
  INVOICE_CUR_ID                 VARCHAR2(15),
  INVOICE_CUR_CODE               VARCHAR2(15),
  INVOICE_CUR_DECIMALS           NUMBER(2),
  GMR_QTY_UNIT_ID                VARCHAR2(15),
  COT_INT_ACTION_REF_NO          VARCHAR2(30)
);
drop table PROCESS_GMR;
create table PROCESS_GMR
(
  INTERNAL_GMR_REF_NO            VARCHAR2(15),
  GMR_REF_NO                     VARCHAR2(30),
  GMR_FIRST_INT_ACTION_REF_NO    VARCHAR2(15),
  INTERNAL_CONTRACT_REF_NO       VARCHAR2(15),
  GMR_LATEST_ACTION_ACTION_ID    VARCHAR2(30),
  CORPORATE_ID                   VARCHAR2(15),
  CREATED_BY                     VARCHAR2(15),
  CREATED_DATE                   TIMESTAMP(6),
  CONTRACT_TYPE                  VARCHAR2(10),
  STATUS_ID                      VARCHAR2(15),
  QTY                            NUMBER(35,10),
  CURRENT_QTY                    NUMBER(35,10),
  QTY_UNIT_ID                    VARCHAR2(15),
  NO_OF_UNITS                    NUMBER(9) default 0,
  CURRENT_NO_OF_UNITS            NUMBER(9) default 0,
  SHIPPED_QTY                    NUMBER(35,10) default 0,
  LANDED_QTY                     NUMBER(35,10) default 0,
  WEIGHED_QTY                    NUMBER(35,10) default 0,
  PLAN_SHIP_QTY                  NUMBER(35,10) default 0,
  RELEASED_QTY                   NUMBER(35,10) default 0,
  BL_NO                          VARCHAR2(50),
  TRUCKING_RECEIPT_NO            VARCHAR2(50),
  RAIL_RECEIPT_NO                VARCHAR2(50),
  BL_DATE                        DATE,
  TRUCKING_RECEIPT_DATE          DATE,
  RAIL_RECEIPT_DATE              DATE,
  WAREHOUSE_RECEIPT_NO           VARCHAR2(50),
  ORIGIN_CITY_ID                 VARCHAR2(15),
  ORIGIN_COUNTRY_ID              VARCHAR2(15),
  DESTINATION_CITY_ID            VARCHAR2(15),
  DESTINATION_COUNTRY_ID         VARCHAR2(15),
  LOADING_COUNTRY_ID             VARCHAR2(15),
  LOADING_PORT_ID                VARCHAR2(15),
  DISCHARGE_COUNTRY_ID           VARCHAR2(15),
  DISCHARGE_PORT_ID              VARCHAR2(15),
  TRANS_PORT_ID                  VARCHAR2(15),
  TRANS_COUNTRY_ID               VARCHAR2(15),
  WAREHOUSE_PROFILE_ID           VARCHAR2(15),
  SHED_ID                        VARCHAR2(15),
  SHIPPING_LINE_PROFILE_ID       VARCHAR2(15),
  CONTROLLER_PROFILE_ID          VARCHAR2(15),
  VESSEL_NAME                    VARCHAR2(100),
  EFF_DATE                       DATE,
  INVENTORY_NO                   VARCHAR2(50),
  INVENTORY_STATUS               VARCHAR2(10),
  INVENTORY_IN_DATE              DATE,
  INVENTORY_OUT_DATE             DATE,
  IS_FINAL_WEIGHT                CHAR(1) default 'N',
  FINAL_WEIGHT                   NUMBER(35,10) default 0,
  SALES_INT_ALLOC_GROUP_ID       VARCHAR2(15),
  IS_INTERNAL_MOVEMENT           CHAR(1) default 'N',
  IS_DELETED                     CHAR(1) default 'N',
  IS_VOYAGE_GMR                  CHAR(1),
  LOADED_QTY                     NUMBER(35,10),
  DISCHARGED_QTY                 NUMBER(35,10),
  VOYAGE_ALLOC_QTY               NUMBER(35,10),
  FULFILLED_QTY                  NUMBER(35,10),
  VOYAGE_STATUS                  VARCHAR2(15),
  TT_IN_QTY                      NUMBER(35,10),
  TT_OUT_QTY                     NUMBER(35,10),
  TT_UNDER_CMA_QTY               NUMBER(35,10),
  TT_NONE_QTY                    NUMBER(35,10),
  MOVED_OUT_QTY                  NUMBER(35,10),
  IS_SETTLEMENT_GMR              CHAR(1) default 'N',
  WRITE_OFF_QTY                  NUMBER,
  INTERNAL_ACTION_REF_NO         VARCHAR2(15),
  GRAVITY_TYPE_ID                VARCHAR2(15),
  GRAVITY                        NUMBER(35,10),
  DENSITY_MASS_QTY_UNIT_ID       VARCHAR2(15),
  DENSITY_VOLUME_QTY_UNIT_ID     VARCHAR2(15),
  GRAVITY_TYPE                   VARCHAR2(30),
  LOADING_STATE_ID               VARCHAR2(15),
  LOADING_CITY_ID                VARCHAR2(15),
  TRANS_STATE_ID                 VARCHAR2(15),
  TRANS_CITY_ID                  VARCHAR2(15),
  DISCHARGE_STATE_ID             VARCHAR2(15),
  DISCHARGE_CITY_ID              VARCHAR2(15),
  PLACE_OF_RECEIPT_COUNTRY_ID    VARCHAR2(15),
  PLACE_OF_RECEIPT_STATE_ID      VARCHAR2(15),
  PLACE_OF_RECEIPT_CITY_ID       VARCHAR2(15),
  PLACE_OF_DELIVERY_COUNTRY_ID   VARCHAR2(15),
  PLACE_OF_DELIVERY_STATE_ID     VARCHAR2(15),
  PLACE_OF_DELIVERY_CITY_ID      VARCHAR2(15),
  TOTAL_GROSS_WEIGHT             NUMBER(35,10),
  TOTAL_TARE_WEIGHT              NUMBER(35,10),
  DBD_ID                         VARCHAR2(15),
  PROCESS_ID                     VARCHAR2(15),
  TOLLING_QTY                    NUMBER(35,10),
  TOLLING_GMR_TYPE               VARCHAR2(30),
  POOL_ID                        VARCHAR2(15),
  IS_WARRANT                     CHAR(1),
  IS_PASS_THROUGH                CHAR(1),
  PLEDGE_INPUT_GMR               VARCHAR2(15),
  IS_APPLY_FREIGHT_ALLOWANCE     CHAR(1),
  IS_FINAL_INVOICED              VARCHAR2(1) default 'N',
  IS_PROVISIONAL_INVOICED        VARCHAR2(1) default 'N',
  PRODUCT_ID                     VARCHAR2(15),
  LATEST_INTERNAL_INVOICE_REF_NO VARCHAR2(15),
  CARRY_OVER_QTY                 NUMBER(35,10),
  MODE_OF_TRANSPORT              VARCHAR2(15),
  ARRIVAL_DATE                   DATE,
  WNS_STATUS                     VARCHAR2(10),
  IS_APPLY_CONTAINER_CHARGE      VARCHAR2(1),
  LOADING_DATE                   DATE,
  NO_OF_CONTAINERS               NUMBER(9),
  NO_OF_BAGS                     NUMBER(10),
  GMR_TYPE                       VARCHAR2(30),
  CONTRACT_REF_NO                VARCHAR2(30),
  CP_ID                          VARCHAR2(15),
  CP_NAME                        VARCHAR2(100),
  STOCK_CURRENT_QTY              NUMBER(25,5),
  DRY_QTY                        NUMBER(35,10),
  WET_QTY                        NUMBER(35,10),
  INVOICE_REF_NO                 VARCHAR2(15),
  WAREHOUSE_NAME                 VARCHAR2(100),
  IS_NEW_MTD                     VARCHAR2(1) default 'N',
  IS_NEW_YTD                     VARCHAR2(1) default 'N',
  IS_ASSAY_UPDATED_MTD           VARCHAR2(1) default 'N',
  IS_ASSAY_UPDATED_YTD           VARCHAR2(1) default 'N',
  ASSAY_FINAL_STATUS             VARCHAR2(100),
  QUALITY_NAME                   VARCHAR2(200),
  INVOICE_CUR_ID                 VARCHAR2(15),
  INVOICE_CUR_CODE               VARCHAR2(15),
  INVOICE_CUR_DECIMALS           NUMBER(2),
  GMR_STATUS                     VARCHAR2(30),
  SHED_NAME                      VARCHAR2(50),
  LOADING_COUNTRY_NAME           VARCHAR2(50),
  LOADING_CITY_NAME              VARCHAR2(500),
  LOADING_STATE_NAME             VARCHAR2(50),
  LOADING_REGION_ID              VARCHAR2(15),
  LOADING_REGION_NAME            VARCHAR2(50),
  DISCHARGE_COUNTRY_NAME         VARCHAR2(50),
  DISCHARGE_CITY_NAME            VARCHAR2(500),
  DISCHARGE_STATE_NAME           VARCHAR2(50),
  DISCHARGE_REGION_ID            VARCHAR2(15),
  DISCHARGE_REGION_NAME          VARCHAR2(50),
  LOADING_COUNTRY_CUR_ID         VARCHAR2(15),
  LOADING_COUNTRY_CUR_CODE       VARCHAR2(15),
  DISCHARGE_COUNTRY_CUR_ID       VARCHAR2(15),
  DISCHARGE_COUNTRY_CUR_CODE     VARCHAR2(15),
  TOLLING_SERVICE_TYPE           VARCHAR2(1),
  GMR_ARRIVAL_STATUS             VARCHAR2(50),
  FEEDING_POINT_ID               VARCHAR2(15),
  FEEDING_POINT_NAME             VARCHAR2(30),
  NO_OF_STOCKS_WNS_DONE          NUMBER(10),
  IS_NEW_MTD_AR                  VARCHAR2(1) default 'N',
  IS_NEW_YTD_AR                  VARCHAR2(1) default 'N',
  IS_ASSAY_UPDATED_MTD_AR        VARCHAR2(1) default 'N',
  IS_ASSAY_UPDATED_YTD_AR        VARCHAR2(1) default 'N',
  IS_TOLLING_CONTRACT            VARCHAR2(1),
  PCM_CONTRACT_TYPE              VARCHAR2(10),
  IS_NEW_FINAL_INVOICE           VARCHAR2(1) default 'N',
  BASE_CONC_MIX_TYPE             VARCHAR2(30),
  GMR_SHIPMENT_DATE              DATE,
  GMR_LANDED_DATE                DATE,
  IS_NEW_LANDING                 VARCHAR2(1) default 'N',
  IS_NEW_SHIPMENT                VARCHAR2(1) default 'N',
  IS_PAYABLE_QTY_CHANGED_MTD     VARCHAR2(1) default 'N',
  IS_TC_CHANGED_MTD              VARCHAR2(1) default 'N',
  IS_RC_CHANGED_MTD              VARCHAR2(1) default 'N',
  IS_PC_CHANGED_MTD              VARCHAR2(1) default 'N',
  IS_PAYABLE_QTY_CHANGED_YTD     VARCHAR2(1) default 'N',
  IS_TC_CHANGED_YTD              VARCHAR2(1) default 'N',
  IS_RC_CHANGED_YTD              VARCHAR2(1) default 'N',
  IS_PC_CHANGED_YTD              VARCHAR2(1) default 'N',
  IS_NEW_DEBIT_CREDIT_INVOICE    CHAR(1) default 'N',
  DEBIT_CREDIT_INVOICE_NO        VARCHAR2(15),
  PCDI_ID                        VARCHAR2(15)
);
drop table PROCESS_SPQ;
create table PROCESS_SPQ
(
  SPQ_ID                   VARCHAR2(15),
  INTERNAL_GMR_REF_NO      VARCHAR2(15),
  ACTION_NO                NUMBER(2),
  STOCK_TYPE               CHAR(1),
  INTERNAL_GRD_REF_NO      VARCHAR2(15),
  INTERNAL_DGRD_REF_NO     VARCHAR2(15),
  ELEMENT_ID               VARCHAR2(15),
  PAYABLE_QTY              NUMBER(25,10),
  QTY_UNIT_ID              VARCHAR2(15),
  VERSION                  NUMBER(10),
  IS_ACTIVE                CHAR(1) default 'Y',
  DBD_ID                   VARCHAR2(15),
  PROCESS_ID               VARCHAR2(15),
  QTY_TYPE                 VARCHAR2(10),
  ACTIVITY_ACTION_ID       VARCHAR2(30),
  IS_STOCK_SPLIT           CHAR(1),
  SUPPLIER_ID              VARCHAR2(20),
  SMELTER_ID               VARCHAR2(20),
  IN_PROCESS_STOCK_ID      VARCHAR2(20),
  FREE_METAL_STOCK_ID      VARCHAR2(20),
  FREE_METAL_QTY           NUMBER(25,10),
  INTERNAL_ACTION_REF_NO   VARCHAR2(30),
  ASSAY_CONTENT            NUMBER(25,10),
  PLEDGE_STOCK_ID          VARCHAR2(20),
  GEPD_ID                  VARCHAR2(15),
  ASSAY_HEADER_ID          VARCHAR2(15),
  IS_FINAL_ASSAY           CHAR(1) default 'N',
  CORPORATE_ID             VARCHAR2(15),
  WEG_AVG_PRICING_ASSAY_ID VARCHAR2(15),
  WEG_AVG_INVOICE_ASSAY_ID VARCHAR2(15),
  QTY_UNIT                 VARCHAR2(15)
);
drop index IDX_AXS2;
create index IDX_AXS2 on AXS_ACTION_SUMMARY (CORPORATE_ID,PROCESS);

drop index IDX_GPHUL1;
CREATE INDEX IDX_GPHUL1 ON GPHUL_GMR_PENALTY_HEADER_UL(GPH_ID,INTERNAL_ACTION_REF_NO);

drop index IDX_GRHUL1;
CREATE INDEX IDX_GRHUL1 ON GRHUL_GMR_REFINING_HEADER_UL(GRH_ID,INTERNAL_ACTION_REF_NO);

drop index IDX_GTHUL1;
CREATE INDEX IDX_GTHUL1 ON GTHUL_GMR_TREATMENT_HEADER_UL(GTH_ID,INTERNAL_GMR_REF_NO);

drop index IDX_SPQL1;
CREATE INDEX IDX_SPQL1 ON SPQL_STOCK_PAYABLE_QTY_LOG(INTERNAL_ACTION_REF_NO,SPQ_ID);

drop index IDX_SPQL2;
create index IDX_SPQL2 on SPQL_STOCK_PAYABLE_QTY_LOG (DBD_ID,PROCESS);

drop index IDX_GRDL1;
CREATE INDEX IDX_GRDL1 ON GRDL_GOODS_RECORD_DETAIL_LOG(DBD_ID,PROCESS);

drop index IDX_GRDL2;
CREATE INDEX IDX_GRDL2 ON GRDL_GOODS_RECORD_DETAIL_LOG(INTERNAL_GRD_REF_NO,INTERNAL_ACTION_REF_NO);

drop index IDX_GRD1;
CREATE INDEX IDX_GRD1 ON GRD_GOODS_RECORD_DETAIL (INTERNAL_GRD_REF_NO,STATUS, IS_DELETED);

drop index IDX_GRD2;
CREATE INDEX IDX_GRD2 ON GRD_GOODS_RECORD_DETAIL (PROCESS_ID, DBD_ID);

drop index IDX_PAG1;
CREATE INDEX IDX_PAG1 ON PA_PURCHASE_ACCURAL_GMR(PROCESS_ID, internal_gmr_ref_no);

drop index IDX_GETC1;
CREATE INDEX IDX_GETC1 ON getc_gmr_element_tc_charges(process_id,internal_gmr_ref_no,internal_grd_ref_no,element_id);

drop index idx_cgcp1;
create index idx_cgcp1 on cgcp_conc_gmr_cog_price (process_id,internal_gmr_ref_no,element_id);

drop index idx_fco1;
create index idx_fco1 on fco_feed_consumption_original(process_id,internal_gmr_ref_no,internal_grd_ref_no);
		
drop index idx_fcg1;
create index idx_fcg1 on fcg_feed_consumption_gmr(process_id,internal_gmr_ref_no)
--RAJ
DROP INDEX IDX_PRC_GRD_CORP_ID;
CREATE INDEX IDX_PRC_GRD_CORP_ID ON PROCESS_GRD(CORPORATE_ID);

DROP INDEX IDX_PRC_GRD_DBD_ID;
CREATE INDEX IDX_PRC_GRD_DBD_ID ON PROCESS_GRD(PROCESS_ID,DBD_ID);
DROP INDEX IDX_PRC_GMR_CORP_ID;
CREATE INDEX IDX_PRC_GMR_CORP_ID ON PROCESS_GMR(CORPORATE_ID);
DROP INDEX IDX_PRC_GMR_DBD_ID;
CREATE INDEX IDX_PRC_GMR_DBD_ID ON PROCESS_GMR(PROCESS_ID,DBD_ID);

DROP INDEX IDX_PRC_SPQ_CORP_ID;
CREATE INDEX IDX_PRC_SPQ_CORP_ID ON PROCESS_SPQ(CORPORATE_ID);
DROP INDEX IDX_PRC_SPQ_DBD_ID;
CREATE INDEX IDX_PRC_SPQ_DBD_ID ON PROCESS_SPQ(PROCESS_ID,DBD_ID);

DROP INDEX IDX_DGRD_DBD_GRD;
CREATE INDEX IDX_DGRD_DBD_GRD ON DGRD_DELIVERED_GRD(DBD_ID, INTERNAL_DGRD_REF_NO);
DROP INDEX IDX_ARO_GMR_REF_NO;
CREATE INDEX IDX_ARO_GMR_REF_NO ON ARO_AR_ORIGINAL(INTERNAL_GMR_REF_NO);
DROP INDEX IDX_ARG_PROC_ID;
CREATE INDEX IDX_ARG_PROC_ID ON ARG_ARRIVAL_REPORT_GMR(PROCESS_ID);
DROP INDEX IDX_AREO_GMR_REF_NO;
CREATE INDEX IDX_AREO_GMR_REF_NO ON AREO_AR_ELEMENT_ORIGINAL(INTERNAL_GMR_REF_NO);
DROP INDEX IDX_CBT_CORP_ID;
CREATE INDEX IDX_CBT_CORP_ID ON CBT_CB_TEMP(CORPORATE_ID);
DROP INDEX IDX_CBT_PRNT_GMR_NO;
CREATE INDEX IDX_CBT_PRNT_GMR_NO ON CBT_CB_TEMP(PARENT_INTERNAL_GMR_REF_NO);
DROP INDEX IDX_GFOC_PROC_ID;
CREATE INDEX IDX_GFOC_PROC_ID ON GFOC_GMR_FREIGHT_OTHER_CHARGE(PROCESS_ID);
DROP INDEX IDX_SMY_PROC_ID;
CREATE INDEX IDX_SMY_PROC_ID ON STOCK_MONTHLY_YEILD_DATA(PROCESS_ID);
DROP INDEX IDX_MAS_PROC_ID;
CREATE INDEX IDX_MAS_PROC_ID ON MAS_METAL_ACCOUNT_SUMMARY(PROCESS_ID);
DROP INDEX IDX_MAS_SECTION;
CREATE INDEX IDX_MAS_SECTION ON MAS_METAL_ACCOUNT_SUMMARY(STOCK_TYPE,POSITION_TYPE,SECTION_NAME);
DROP INDEX IDX_PCS_PROC_ID;
CREATE INDEX IDX_PCS_PROC_ID ON PCS_PURCHASE_CONTRACT_STATUS(PROCESS_ID);
DROP INDEX IDX_FCEO_PROC_ID;
CREATE INDEX IDX_FCEO_PROC_ID ON FCEO_FEED_CON_ELEMENT_ORIGINAL(PROCESS_ID);
DROP INDEX IDX_FCEO_GMR_NO;
CREATE INDEX IDX_FCEO_GMR_NO ON FCEO_FEED_CON_ELEMENT_ORIGINAL(INTERNAL_GMR_REF_NO);
