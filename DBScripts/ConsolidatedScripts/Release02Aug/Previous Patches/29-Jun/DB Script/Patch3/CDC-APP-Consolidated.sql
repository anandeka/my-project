SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LIST_FREIGHT_TRADES', 'List of Freight Trades', '[
 {"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},
 {header: "Trade Date", width: 150, sortable: true, dataIndex: "tradeDate"},
 {header: "Trade Ref. No.", width: 150, sortable: true, dataIndex: "tradeRefNo"},
 {header: "Ext Trade Ref.No.", width: 150, sortable: true, dataIndex: "extTradeRefNo"},
 {header: "Counter Party", width: 150, sortable: true, dataIndex: "counterParty"},
 {header: "Instrument", width: 150, sortable: true, dataIndex: "instrument"},
 {header: "Product", width: 150, sortable: true, dataIndex: "productDesc"},
 {header: "Settlement Details", width: 150, sortable: true, dataIndex: "settlementDetails"},
 {header: "Quantity", width: 150, sortable: true, dataIndex: "quantity"},
 {header: "Contract Price", width: 150, sortable: true, dataIndex: "contractPrice"},
 {header: "Broker Name", width: 150, sortable: true, dataIndex: "brokerName"},
 {header: "Broker Commission Type", width: 150, sortable: true, dataIndex: "brokerCommissionType"},
 {header: "Clearer Name", width: 150, sortable: true, dataIndex: "clearerName"},
 {header: "Clearer Commission Type", width: 150, sortable: true, dataIndex: "clearerCommissionType"},
 {header: "Master Agreement", width: 150, sortable: true, dataIndex: "masterAgreement"},
 {header: "Profit Center", width: 150, sortable: true, dataIndex: "profitCenter"},
 {header: "Trader", width: 150, sortable: true, dataIndex: "traderName"},
 {header: "Trade Type", width: 150, sortable: true, dataIndex: "tradeType"},
 {header: "Strategy", width: 150, sortable: true, dataIndex: "strategy"},
 {header: "Status", width: 150, sortable: true, dataIndex: "status"} 
 ]', NULL, '/cdc/commonListing.do?method=getListingData', 
    NULL, NULL, 'trademanagement/freight/ListOfFreightTrades.jsp', '/private/js/trademanagement/freight/ListOfFreightTrades.js')
    /


--gmc

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OCEAN_FREIGHT_TRADES-01', 'LIST_FREIGHT_TRADES', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL)
    /
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OCEAN_FREIGHT_TRADES-03', 'LIST_FREIGHT_TRADES', 'Verify', 1, 2, 
    NULL, 'function(){verifyFreightTrades();}', NULL, 'OCEAN_FREIGHT_TRADES-01', NULL)
    /
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OCEAN_FREIGHT_TRADES-04', 'LIST_FREIGHT_TRADES', 'Unverify', 2, 2, 
    NULL, 'function(){unVerifyFreightTrades();}', NULL, 'OCEAN_FREIGHT_TRADES-01', NULL)
    /
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OCEAN_FREIGHT_TRADES-05', 'LIST_FREIGHT_TRADES', 'Delete', 3, 2, 
    NULL, 'function(){deleteFreightTrades();}', NULL, 'OCEAN_FREIGHT_TRADES-01', NULL)
    /
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OCEAN_FREIGHT_TRADES-06', 'LIST_FREIGHT_TRADES', 'Modify', 4, 2, 
    NULL, 'function(){modifyFreightTrade();}', NULL, 'OCEAN_FREIGHT_TRADES-01', NULL)
    /
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OCEAN_FREIGHT_TRADES-07', 'LIST_FREIGHT_TRADES', 'Copy', 5, 2, 
    NULL, 'function(){copyFreightTrade();}', NULL, 'OCEAN_FREIGHT_TRADES-01', NULL)
    /
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OCEAN_FREIGHT_TRADES-09', 'LIST_FREIGHT_TRADES', 'Allocate', 7, 2, 
    NULL, 'function(){allocateFreightTrade();}', NULL, 'OCEAN_FREIGHT_TRADES-01', NULL)
    /
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OCEAN_FREIGHT_TRADES-08', 'LIST_FREIGHT_TRADES', 'View', 6, 2, 
    NULL, 'function(){viewFreightDetails();}', NULL, 'OCEAN_FREIGHT_TRADES-01', NULL)
    /


ALTER TABLE drm_derivative_master
 ADD CONSTRAINT fk_drm_delivery_period_id
 FOREIGN KEY (delivery_period_id)
 REFERENCES dpd_delivery_period_definition (delivery_period_id);

ALTER TABLE  dq_derivative_quotes
ADD (created_by VARCHAR2(15))
/

UPDATE dq_derivative_quotes dq
   SET dq.created_by = (SELECT ak.user_id
                          FROM ak_corporate_user ak
                         WHERE ak.login_name = 'admin')


/

CREATE TABLE FT_FREIGHT_TRADE
(
  INTERNAL_TRADE_REF_NO             VARCHAR2(15 CHAR) NOT NULL,
  DR_ID                             VARCHAR2(15 CHAR) NOT NULL,
  CORPORATE_ID                      VARCHAR2(15 CHAR) NOT NULL,
  TRADE_REF_NO                      VARCHAR2(30 CHAR) NOT NULL,
  EXTERNAL_REF_NO                   VARCHAR2(50 CHAR),
  DEAL_TYPE_ID                      VARCHAR2(15 CHAR) NOT NULL,
  TRADE_DATE                        DATE          NOT NULL,
  CP_PROFILE_ID                     VARCHAR2(50 CHAR),
  SETTLEMENT_AVG_PERIOD             VARCHAR2(50 CHAR) NOT NULL,
  SETTLEMENT_AVG_DAY                NUMBER(10,5),
  PERIOD_START_DATE 		    DATE,
  PERIOD_END_DATE 		    DATE,
  QUANTITY                          NUMBER(10,5)  NOT NULL,
  QUANTITY_UNIT_ID                  VARCHAR2(15 CHAR) NOT NULL,
  CONTRACT_PRICE                    NUMBER(20,10) NOT NULL,
  CONTRACT_PRICE_UNIT_ID            VARCHAR2(15 CHAR) NOT NULL,
  SETTLEMENT_CUR_ID 		    VARCHAR2(15 CHAR),
  TRADER_ID                         VARCHAR2(15 CHAR) NOT NULL,
  TRADE_TYPE                        VARCHAR2(15 CHAR) NOT NULL,
  BROKER_PROFILE_ID                 VARCHAR2(15 CHAR),
  BROKER_COMM_TYPE_ID               VARCHAR2(15 CHAR),
  BROKER_COMM_AMT                   NUMBER(25,4),
  BROKER_COMM_CUR_ID                VARCHAR2(15 CHAR),
  BROKER_COMM_TRADE_TYPE            VARCHAR2(20 CHAR),
  MASTER_AGGREMENT_ID               VARCHAR2(15 CHAR),
  PROFIT_CENTER_ID                  VARCHAR2(15 CHAR)  NOT NULL,
  STRATEGY_ID                       VARCHAR2(15 CHAR) NOT NULL,
  PURPOSE_ID                        VARCHAR2(15 CHAR) NOT NULL,
  NOMINEE_PROFILE_ID                VARCHAR2(15 CHAR),
  REMARKS                           VARCHAR2(4000 CHAR),
  CREATED_BY                        VARCHAR2(15 CHAR) NOT NULL,
  MODIFIED_BY                       VARCHAR2(15 CHAR) NOT NULL,
  CREATED_DATE                      TIMESTAMP(6)  NOT NULL,
  MODIFIED_DATE                     TIMESTAMP(6)  NOT NULL,
  STATUS                            VARCHAR2(20 CHAR) NOT NULL)
/
  
  ALTER TABLE FT_FREIGHT_TRADE ADD (
    CONSTRAINT CHK_FT_TRADE_TYPE
    CHECK (TRADE_TYPE IN ('Buy', 'Sell')),
    CONSTRAINT CHK_FT_STATUS
    CHECK (STATUS IN ('None', 'Delete','Settled','Verified')),
    CONSTRAINT FK_FT_DEAL_TYPE_ID 
    FOREIGN KEY (DEAL_TYPE_ID) 
    REFERENCES DTM_DEAL_TYPE_MASTER (DEAL_TYPE_ID), 
    CONSTRAINT FK_FT_CP_PROFILE_ID 
 FOREIGN KEY (CP_PROFILE_ID) 
 REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
 CONSTRAINT FK_FT_BROKER_PROFILE_ID 
 FOREIGN KEY (BROKER_PROFILE_ID) 
 REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
 CONSTRAINT FK_FT_NOMINEE_PROFILE_ID 
 FOREIGN KEY (NOMINEE_PROFILE_ID) 
 REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID),
 CONSTRAINT FK_FT_PURPOSE_ID 
 FOREIGN KEY (PURPOSE_ID) 
 REFERENCES DPM_DERIVATIVE_PURPOSE_MASTER (PURPOSE_ID),
  CONSTRAINT FK_FT_DR_ID 
 FOREIGN KEY (DR_ID) 
 REFERENCES DRM_DERIVATIVE_MASTER (DR_ID),
 CONSTRAINT FK_FT_PROFIT_CENTER_ID 
 FOREIGN KEY (PROFIT_CENTER_ID) 
 REFERENCES CPC_CORPORATE_PROFIT_CENTER (PROFIT_CENTER_ID),
  CONSTRAINT FK_FT_STRATEGY_ID 
 FOREIGN KEY (STRATEGY_ID) 
 REFERENCES CSS_CORPORATE_STRATEGY_SETUP (STRATEGY_ID),
 CONSTRAINT FK_FT_SETTLEMENT_CUR_ID 
 FOREIGN KEY (SETTLEMENT_CUR_ID)
 REFERENCES CM_CURRENCY_MASTER (CUR_ID),
  CONSTRAINT FK_FT_CORPORATE_ID 
 FOREIGN KEY (CORPORATE_ID) 
 REFERENCES AK_CORPORATE (CORPORATE_ID),
  CONSTRAINT FK_FT_CREATED_BY 
 FOREIGN KEY (CREATED_BY) 
 REFERENCES AK_CORPORATE_USER (USER_ID),
  CONSTRAINT FK_FT_TRADER_ID 
 FOREIGN KEY (TRADER_ID) 
 REFERENCES AK_CORPORATE_USER (USER_ID),
  CONSTRAINT FK_FT_MODIFIED_BY 
 FOREIGN KEY (MODIFIED_BY) 
 REFERENCES AK_CORPORATE_USER (USER_ID), 
  CONSTRAINT PK_FT
 PRIMARY KEY
 (INTERNAL_TRADE_REF_NO))
/



CREATE TABLE FTUL_FREIGHT_TRADE_UL
(
  INTERNAL_ACTION_REF_NO            VARCHAR2(15 CHAR) NOT NULL,
  INTERNAL_TRADE_REF_NO             VARCHAR2(15 CHAR) NOT NULL,
  ENTRY_TYPE                        VARCHAR2(30 CHAR) NOT NULL,
  IS_DELETED                        VARCHAR2(15 CHAR) DEFAULT 'N' NOT NULL,
  DR_ID                             VARCHAR2(15 CHAR),
  CORPORATE_ID                      VARCHAR2(15 CHAR),
  TRADE_REF_NO                      VARCHAR2(30 CHAR),
  EXTERNAL_REF_NO                   VARCHAR2(50 CHAR),
  DEAL_TYPE_ID                      VARCHAR2(15 CHAR),
  TRADE_DATE                        VARCHAR2(30 CHAR),
  CP_PROFILE_ID                     VARCHAR2(50 CHAR),
  PERIOD_START_DATE 		    VARCHAR2(30 Char),
  PERIOD_END_DATE 		    VARCHAR2(30 Char),
  SETTLEMENT_AVG_PERIOD             VARCHAR2(15 CHAR),
  SETTLEMENT_AVG_DAY                VARCHAR2(15 CHAR),
  QUANTITY                          VARCHAR2(15 CHAR),
  QUANTITY_UNIT_ID                  VARCHAR2(15 CHAR),
  CONTRACT_PRICE                    VARCHAR2(20 CHAR),
  CONTRACT_PRICE_UNIT_ID            VARCHAR2(15 CHAR),
  SETTLEMENT_CUR_ID 		    VARCHAR2(15 CHAR),
  TRADER_ID                         VARCHAR2(15 CHAR),
  TRADE_TYPE                        VARCHAR2(15 CHAR),
  BROKER_PROFILE_ID                 VARCHAR2(15 CHAR),
  BROKER_COMM_TYPE_ID               VARCHAR2(15 CHAR),
  BROKER_COMM_AMT                   VARCHAR2(30 CHAR),
  BROKER_COMM_CUR_ID                VARCHAR2(15 CHAR),
  BROKER_COMM_TRADE_TYPE            VARCHAR2(20 CHAR),
  MASTER_AGGREMENT_ID               VARCHAR2(15 CHAR),
  PROFIT_CENTER_ID                  VARCHAR2(15 CHAR),
  STRATEGY_ID                       VARCHAR2(15 CHAR),
  PURPOSE_ID                        VARCHAR2(15 CHAR),
  NOMINEE_PROFILE_ID                VARCHAR2(15 CHAR),
  REMARKS                           VARCHAR2(4000 CHAR),
  CREATED_BY                        VARCHAR2(15 CHAR),
  MODIFIED_BY                       VARCHAR2(15 CHAR),
  CREATED_DATE                      VARCHAR2(50 CHAR),
  MODIFIED_DATE                     VARCHAR2(50 CHAR),
  STATUS                            VARCHAR2(20 CHAR))
/
  
  
  ALTER TABLE FTUL_FREIGHT_TRADE_UL ADD (
  CONSTRAINT FK_FTUL_INT_ACTION_REF_NO 
 FOREIGN KEY (INTERNAL_ACTION_REF_NO) 
 REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO))
/
 
 
 ALTER TABLE FTUL_FREIGHT_TRADE_UL ADD (
  CONSTRAINT PK_FTUL
 PRIMARY KEY
 (INTERNAL_ACTION_REF_NO, INTERNAL_TRADE_REF_NO))
/



CREATE TABLE FQ_FREIGHT_QUOTES
(
  FQ_ID            VARCHAR2(15 CHAR)            NOT NULL,
  TRADE_DATE       DATE                         NOT NULL,
  CORPORATE_ID     VARCHAR2(15 CHAR)            NOT NULL,
  INSTRUMENT_ID    VARCHAR2(15 CHAR)            NOT NULL,
  PRICE_SOURCE_ID  VARCHAR2(15 CHAR)            NOT NULL,
  SPOT_PRICE               NUMBER(25,5),
  SPOT_PRICE_UNIT_ID       VARCHAR2(15 CHAR)    NOT NULL,
  CREATED_DATE     TIMESTAMP(6)                 NOT NULL,
  UPDATED_DATE     TIMESTAMP(6)                 NOT NULL,
  VERSION          NUMBER(4)                    NOT NULL,
  IS_DELETED       CHAR(1 CHAR)                 DEFAULT 'N'                   NOT NULL,
  IS_MANUAL      CHAR(1 CHAR)
)
/

ALTER TABLE FQ_FREIGHT_QUOTES ADD (
 CONSTRAINT FK_FQ_PRICE_SOURCE_ID 
 FOREIGN KEY (PRICE_SOURCE_ID) 
 REFERENCES PS_PRICE_SOURCE (PRICE_SOURCE_ID),
  CONSTRAINT FK_FQ_INSTRUMENT_ID 
 FOREIGN KEY (INSTRUMENT_ID) 
 REFERENCES DIM_DER_INSTRUMENT_MASTER (INSTRUMENT_ID),
  CONSTRAINT FK_FQ_CORPORATE_ID 
 FOREIGN KEY (CORPORATE_ID) 
 REFERENCES AK_CORPORATE (CORPORATE_ID),
 CONSTRAINT FK_FQ_PRICE_UNIT_ID 
 FOREIGN KEY (SPOT_PRICE_UNIT_ID) 
 REFERENCES PUM_PRICE_UNIT_MASTER (PRICE_UNIT_ID), 
  CONSTRAINT PK_FQ
 PRIMARY KEY
 (FQ_ID))
/



CREATE TABLE FQD_FREIGHT_QUOTE_DETAIL
(
  FQD_ID              VARCHAR2(15 CHAR)         NOT NULL,
  FQ_ID               VARCHAR2(15 CHAR)         NOT NULL,
  DR_ID               VARCHAR2(15 CHAR)         NOT NULL,
  SETTLEMENT_PRICE               NUMBER(25,5),
  SETTLEMENT_PRICE_UNIT_ID       VARCHAR2(15 CHAR)         NOT NULL,
  IS_DELETED          CHAR(1 CHAR)              DEFAULT 'N'                   NOT NULL,
  CREATED_DATE        TIMESTAMP(6),
  UPDATED_DATE        TIMESTAMP(6),
  IS_MANUAL      CHAR(1 CHAR)
)
/


ALTER TABLE FQD_FREIGHT_QUOTE_DETAIL ADD (
 CONSTRAINT FK_FQD_FQ_ID 
 FOREIGN KEY (FQ_ID) 
 REFERENCES FQ_FREIGHT_QUOTES (FQ_ID),
  CONSTRAINT FK_FQD_DR_ID 
 FOREIGN KEY (DR_ID) 
 REFERENCES DRM_DERIVATIVE_MASTER (DR_ID),  
 CONSTRAINT FK_FQD_PRICE_UNIT_ID 
 FOREIGN KEY (SETTLEMENT_PRICE_UNIT_ID) 
 REFERENCES PUM_PRICE_UNIT_MASTER (PRICE_UNIT_ID), 
  CONSTRAINT PK_FQD
 PRIMARY KEY
 (FQD_ID))
/



CREATE TABLE FAM_FREIGHT_ACTION_AMAPPING
(
  INTERNAL_ACTION_REF_NO      VARCHAR2(15 CHAR),
  INTERNAL_TRADE_REF_NO       VARCHAR2(15 CHAR)
)
/

ALTER TABLE FAM_FREIGHT_ACTION_AMAPPING ADD (
  CONSTRAINT PK_FAM
 PRIMARY KEY
 (INTERNAL_ACTION_REF_NO, INTERNAL_TRADE_REF_NO))
/
 
 ALTER TABLE FAM_FREIGHT_ACTION_AMAPPING ADD (
  CONSTRAINT FK_FAM_INTERNAL_ACTION_REF_NO 
 FOREIGN KEY (INTERNAL_ACTION_REF_NO) 
 REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO))
/
 
 ALTER TABLE FAM_FREIGHT_ACTION_AMAPPING ADD (
  CONSTRAINT FK_FAM_INTERNAL_TRADE_REF_NO 
 FOREIGN KEY (INTERNAL_TRADE_REF_NO) 
 REFERENCES FT_FREIGHT_TRADE (INTERNAL_TRADE_REF_NO))
/

CREATE SEQUENCE SEQ_FT
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER
/

CREATE SEQUENCE SEQ_FTQ
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
/

 CREATE SEQUENCE SEQ_FTQD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
/


ALTER TABLE CFQ_CURRENCY_FORWARD_QUOTES ADD 
CONSTRAINT UNIQUE_CFQ
UNIQUE (CORPORATE_ID, TRADE_DATE, INSTRUMENT_ID, PRICE_SOURCE_ID,IS_DELETED)
/

ALTER TABLE DQ_DERIVATIVE_QUOTES ADD 
CONSTRAINT UNIQUE_DQ
UNIQUE (TRADE_DATE, CORPORATE_ID, INSTRUMENT_ID, PRICE_SOURCE_ID, IS_DELETED)
/

ALTER TABLE COQ_CURRENCY_OPTION_QUOTES ADD 
CONSTRAINT UNIQUE_COQ
UNIQUE (TRADE_DATE, CORPORATE_ID, INSTRUMENT_ID, IS_DELETED, PRICE_SOURCE_ID)
/

ALTER TABLE FQ_FREIGHT_QUOTES ADD 
CONSTRAINT UNIQUE_FQ
UNIQUE (CORPORATE_ID, TRADE_DATE, INSTRUMENT_ID, PRICE_SOURCE_ID,SPOT_PRICE_UNIT_ID,IS_DELETED)
/

INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable, is_ref_no_gen_applicable
            )
     VALUES ('CDC_FT_VERIFY_TRADE', 'Freight', 'Freight Trade Verify', 'N',
             'Freight Trade Verify', 'N', NULL
            );
/
INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable, is_ref_no_gen_applicable
            )
     VALUES ('CDC_FT_DELETE_TRADE', 'Freight', 'Freight Trade Delete', 'N',
             'Freight Trade Delete', 'N', NULL
            );
/
INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable, is_ref_no_gen_applicable
            )
     VALUES ('CDC_FT_CREATE_TRADE', 'Freight', 'Freight Trade Creation', 'N',
             'Freight Trade Creation', 'N', NULL
            );
/
INSERT INTO axm_action_master
            (action_id, entity_id, action_name,
             is_new_gmr_applicable, action_desc, is_generate_doc_applicable,
             is_ref_no_gen_applicable
            )
     VALUES ('CDC_FT_UNVERIFY_TRADE', 'Freight', 'Freight Trade UnVerify',
             'N', 'Freight Trade UnVerify', 'N',
             NULL
            );
/
INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable, is_ref_no_gen_applicable
            )
     VALUES ('CDC_FT_MODIFY_TRADE', 'Freight', 'Freight Trade Modify', 'N',
             'Freight Trade Modify', 'N', NULL
            );
/
INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('CDC_FT_UNVERIFY_TRADE', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );
/
INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('CDC_FT_DELETE_TRADE', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );
/
INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('CDC_FT_MODIFY_TRADE', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );
/
INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('CDC_FT_CREATE_TRADE', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );
/
INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('CDC_FT_VERIFY_TRADE', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );
/
INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('CDC_Freight_Mod', 'Freight Trade Modify',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );
/
INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('CDC_Freight_Ver', 'Freight Trade Verify',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );
/
INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('CDC_Freight_UnV', 'Freight Trade UnVerify',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );
/
INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('CDC_Freight_Del', 'Freight Trade Delete',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );
/
INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('CDC_Freight_Cre', 'Freight Trade Creation',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            )
/




INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called, icon_class, menu_parent_id, acl_id,
             tab_id, FEATURE_ID, is_deleted
            )
     VALUES ('CDC-M92', 'FFA Quotes', 20, 2,
             '/cdc/loadFreightQuotes.action', NULL, 'CDC-M1', NULL,
             'Market Data', NULL, 'N'
            );
/
INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called, icon_class,
             menu_parent_id, acl_id, tab_id, FEATURE_ID, is_deleted
            )
     VALUES ('T13', 'Ocean Freight', 2, 2,
             '/cdc/getListingPage.action?gridId=LIST_FREIGHT_TRADES', NULL,
             'CDC-D1', NULL, 'Derivative', NULL, 'N'
            );
/
INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called, icon_class,
             menu_parent_id, acl_id, tab_id, FEATURE_ID, is_deleted
            )
     VALUES ('T131', 'FFA', 1, 3,
             '/cdc/getListingPage.action?gridId=LIST_FREIGHT_TRADES', NULL,
             'T13', NULL, 'Derivative', NULL, 'N'
            );
/
INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called,
             icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID,
             is_deleted
            )
     VALUES ('T1311', 'New', 1, 4,
             '/cdc/newFrwdFreightTrade.action?dealTypeId=DTM-19&gridId=OTCFF',
             NULL, 'T131', NULL, 'Derivative', NULL,
             'N'
            );
/
INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called, icon_class,
             menu_parent_id, acl_id, tab_id, FEATURE_ID, is_deleted
            )
     VALUES ('T1312', 'List All', 2, 4,
             '/cdc/getListingPage.action?gridId=LIST_FREIGHT_TRADES', NULL,
             'T131', NULL, 'Derivative', NULL, 'N'
            );
/
INSERT INTO dtm_deal_type_master
            (deal_type_id, deal_type_name, deal_type_display_name,
             is_multiple_leg_involved, display_order, VERSION, is_active,
             is_deleted
            )
     VALUES ('DTM-19', 'OTCFF', 'OTC Freight Forward',
             'N', 19, '1', 'N',
             'Y'
            );
/
INSERT INTO ddpm_der_deal_purpose_mapping
            (deal_type_id, purpose_id, entity, is_deleted
            )
     VALUES ('DTM-19', 'DPM-1', 'Derivative', 'N'
            );
/
INSERT INTO ddpm_der_deal_purpose_mapping
            (deal_type_id, purpose_id, entity, is_deleted
            )
     VALUES ('DTM-19', 'DPM-3', 'Derivative', 'N'
            );
/
INSERT INTO ddpm_der_deal_purpose_mapping
            (deal_type_id, purpose_id, entity, is_deleted
            )
     VALUES ('DTM-19', 'DPM-4', 'Derivative', 'N'
            )
/


INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Contract Period', 'Contract Period'
            );
/
INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Reduced Period', 'Reduced Period'
            );
/
INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('ISDA', 'ISDA'
            );
/
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('settlementAveragePeriods', 'Contract Period', 'N', 1
            );
/
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('settlementAveragePeriods', 'Reduced Period', 'N', 2
            );
/
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('masterAgreementList', 'ISDA', 'N', 1
            )
/


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_FT', 'FT', 'SEQ_FT')
/

Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_FTQ', 'FQ', 'SEQ_FTQ')
/

Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_FTQD', 'FQD', 'SEQ_FTQD')
/

DECLARE
BEGIN
   FOR cc IN (SELECT *
                FROM ak_corporate akc
               WHERE akc.is_internal_corporate = 'N')
   LOOP
      DBMS_OUTPUT.put_line (cc.corporate_id);

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('CDC-FT-101-' || cc.corporate_id, cc.corporate_id,
                   'CDC_FT_CREATE_TRADE', 'CDC_Freight_Cre', 'N'
                  );

      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('CDC-FT-01-' || cc.corporate_id, 'CDC_Freight_Cre',
                   cc.corporate_id, 'FT-', 0,
                   0, cc.corporate_id, 1, 'N'
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('CDC-FT-102-' || cc.corporate_id, cc.corporate_id,
                   'CDC_FT_MODIFY_TRADE', 'CDC_Freight_Mod', 'N'
                  );

      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('CDC-FT-02-' || cc.corporate_id, 'CDC_Freight_Mod',
                   cc.corporate_id, 'FT-', 0,
                   0, cc.corporate_id, 1, 'N'
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('CDC-FT-103-' || cc.corporate_id, cc.corporate_id,
                   'CDC_FT_DELETE_TRADE', 'CDC_Freight_Del', 'N'
                  );

      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('CDC-FT-03-' || cc.corporate_id, 'CDC_Freight_Del',
                   cc.corporate_id, 'FT-', 0,
                   0, cc.corporate_id, 1, 'N'
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('CDC-FT-104-' || cc.corporate_id, cc.corporate_id,
                   'CDC_FT_VERIFY_TRADE', 'CDC_Freight_Ver', 'N'
                  );

      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('CDC-FT-04-' || cc.corporate_id, 'CDC_Freight_Ver',
                   cc.corporate_id, 'FT-', 0,
                   0, cc.corporate_id, 1, 'N'
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('CDC-FT-105-' || cc.corporate_id, cc.corporate_id,
                   'CDC_FT_UNVERIFY_TRADE', 'CDC_Freight_UnV', 'N'
                  );

      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('CDC-FT-05-' || cc.corporate_id, 'CDC_Freight_UnV',
                   cc.corporate_id, 'FT-', 0,
                   0, cc.corporate_id, 1, 'N'
                  );

	Insert into ERC_EXTERNAL_REF_NO_CONFIG
	   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
	 Values
	   (cc.corporate_id, 'FREIGHT_REF_NO', 'FT-', 0, '-'|| cc.corporate_id);

   END LOOP;
END;

/

--for doc conf table entries
DECLARE
   doc_id   VARCHAR2 (15);
   display_order   number (15);
BEGIN
   INSERT INTO dkm_doc_ref_key_master
               (doc_key_id, doc_key_desc, validation_query
               )
        VALUES ('DT_D_KEY', 'DERIVATIVE_TRADE_DOCUMENT',
                'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
               );

   doc_id := 'DM-' || seq_dm.NEXTVAL;
   
   SELECT dm.display_order + 1 into display_order
   FROM dm_document_master dm
   WHERE dm.display_order = (SELECT MAX (dm1.display_order)FROM dm_document_master dm1);
   
   
   
   INSERT INTO dm_document_master
               (doc_id, doc_name, display_order, VERSION, is_active,is_deleted
               )
        VALUES (doc_id, 'DERIVATIVE_TRADE_DOCUMENT', display_order, NULL, 'Y','N'
               );

   FOR akc_cursor IN (SELECT akc.corporate_id
                        FROM ak_corporate akc)
   LOOP
      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id,doc_id, doc_key_id, is_deleted
                  )
           VALUES ('DRFM-' || seq_drfm.NEXTVAL, akc_cursor.corporate_id,doc_id, 'DT_D_KEY', 'N'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id,corporate_id, prefix, middle_no_start_value, middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-' || seq_drf.NEXTVAL, 'DT_D_KEY',akc_cursor.corporate_id, 'DT-', 0, 0, '-' || akc_cursor.corporate_id, NULL, 'N'
                  );

      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, 
                  corporate_id, doc_id,
                   doc_template_name, 
                   doc_template_name_de,
                   doc_template_name_es, 
                   doc_print_name, 
                   doc_print_name_de,
                   doc_print_name_es, 
                   doc_rpt_file_name, 
                   is_active,
                   doc_auto_generate
                  )
           VALUES ('CDC-DT', 
                   akc_cursor.corporate_id, 
                   doc_id,
                   'DerivativeTradeDoc', 
                   NULL,
                   NULL, 
                   'DOC', 
                   NULL,
                   NULL, 
                   'SWAP.rpt', 
                   'Y',
                   'Y'
                  );
   END LOOP;
END;
/

--for the print doc operation entry
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OTC_SWAP_TRADES-09', 'LIST_OTC_SWAP_TRADES', 'Print', 7, 2, 
    NULL, 'function(){printDocument();}', NULL, 'OTC_SWAP_TRADES-01', NULL)
/





--for dt_d

CREATE TABLE DT_D
(
  INTERNAL_DOC_REF_NO             VARCHAR2(15 CHAR),
  INTERNAL_DERIVATIVE_REF_NO      NUMBER(5),
  DERIVATIVE_REF_NO               VARCHAR2(30 CHAR),
  CORPORATE                       VARCHAR2(50 CHAR),
  TRADER                          VARCHAR2(50 CHAR),
  DR_ID_NAME                      VARCHAR2(50 CHAR),
  TRADE_TYPE                      VARCHAR2(50 CHAR),
  DEAL_TYPE                       VARCHAR2(50 CHAR),
  PROFIT_CENTER                   VARCHAR2(50 CHAR),
  STRATEGY                        VARCHAR2(50 CHAR),
  PURPOSE                         VARCHAR2(50 CHAR),
  EXTERNAL_REF_NO                 VARCHAR2(50 CHAR),
  TRADE_DATE                      DATE,
  CP_PROFILE                      VARCHAR2(50 CHAR),
  MASTER_CONTRACT                 VARCHAR2(50 CHAR),
  BROKER_PROFILE                  VARCHAR2(50 CHAR),
  BROKER_ACCOUNT                  VARCHAR2(50 CHAR),
  BROKER_COMM_TYPE                VARCHAR2(50 CHAR),
  BROKER_COMM_AMT                 NUMBER(25,4),
  BROKER_COMM_CUR                 VARCHAR2(50 CHAR),
  CLEARER_PROFILE                 VARCHAR2(50 CHAR),
  CLEARER_ACCOUNT                 VARCHAR2(50 CHAR),
  CLEARER_COMM_TYPE               VARCHAR2(50 CHAR),
  CLEARER_COMM_AMT                NUMBER(25,4),
  CLEARER_COMM_CUR                VARCHAR2(50 CHAR),
  PRODUCT                         VARCHAR2(50 CHAR),
  QUALITY                         VARCHAR2(50 CHAR),
  QUANTITY_UNIT                   VARCHAR2(50 CHAR),
  TOTAL_LOTS                      NUMBER(6),
  TOTAL_QUANTITY                  NUMBER(25,5),
  OPEN_LOTS                       NUMBER(6),
  OPEN_QUANTITY                   NUMBER(25,4),
  EXERCISED_LOTS                  NUMBER(6),
  EXERCISED_QUANTITY              NUMBER(25,4),
  EXPIRED_LOTS                    NUMBER(6),
  EXPIRED_QUANTITY                NUMBER(25,4),
  TRADE_PRICE_TYPE                VARCHAR2(50 CHAR),
  TRADE_PRICE                     NUMBER(25,5),
  TRADE_PRICE_UNIT                VARCHAR2(50 CHAR),
  FORMULA                         VARCHAR2(50 CHAR),
  INDEX_INSTRUMENT                VARCHAR2(50 CHAR),
  STRIKE_PRICE                    NUMBER(25,5),
  STRIKE_PRICE_UNIT               VARCHAR2(50 CHAR),
  PREMIUM_DISCOUNT                NUMBER(25,5),
  PREMIUM_DISCOUNT_PRICE_UNIT     VARCHAR2(50 CHAR),
  PREMIUM_DUE_DATE                DATE,
  SETTLEMENT_CUR                  VARCHAR2(50 CHAR),
  NOMINEE_PROFILE                 VARCHAR2(50 CHAR),
  REMARKS                         VARCHAR2(4000 CHAR),
  LEG_NO                          NUMBER(1),
  CREATED_BY                      VARCHAR2(50 CHAR),
  MODIFIED_BY                     VARCHAR2(50 CHAR),
  CREATED_DATE                    TIMESTAMP(6),
  LAST_MODIFIED_DATE              TIMESTAMP(6),
  OPTION_EXPIRY_DATE              DATE,
  PARENT_INT_DERIVATIVE_REF_NO    NUMBER(5),
  STATUS                          VARCHAR2(50 CHAR),
  MARKET_LOCATION_COUNTRY         VARCHAR2(50 CHAR),
  MARKET_LOCATION_STATE           VARCHAR2(50 CHAR),
  MARKET_LOCATION_CITY            VARCHAR2(50 CHAR),
  IS_WHAT_IF                      CHAR(50 CHAR) DEFAULT 'N',
  PAYMENT_TERM                    VARCHAR2(50 CHAR),
  PAYMENT_DUE_DATE                DATE,
  IS_IMPORTED                     CHAR(1 CHAR)  DEFAULT 'N',
  CLOSED_LOTS                     NUMBER(6),
  CLOSED_QUANTITY                 NUMBER(25,4),
  INT_TRADE_PARENT_DER_REF_NO     NUMBER(5),
  IS_INTERNAL_TRADE               CHAR(1 CHAR),
  PRICE_POINT                     VARCHAR2(50 CHAR),
  AVAILABLE_PRICE                 VARCHAR2(50 CHAR),
  AVERAGE_FROM_DATE               DATE,
  AVERAGE_TO_DATE                 DATE,
  SWAP_TYPE_1                     VARCHAR2(50 CHAR),
  SWAP_TRADE_PRICE_TYPE_1         VARCHAR2(50 CHAR),
  SWAP_FLOAT_TYPE_1               VARCHAR2(50 CHAR),
  SWAP_TRADE_PRICE_1              NUMBER(25,5),
  SWAP_TRADE_PRICE_UNIT_1         VARCHAR2(50 CHAR),
  SWAP_INDEX_INSTRUMENT_1         VARCHAR2(50 CHAR),
  SWAP_FORMULA_1                  VARCHAR2(50 CHAR),
  SWAP_TYPE_2                     VARCHAR2(50 CHAR),
  SWAP_TRADE_PRICE_TYPE_2         VARCHAR2(50 CHAR),
  SWAP_FLOAT_TYPE_2               VARCHAR2(50 CHAR),
  SWAP_TRADE_PRICE_2              NUMBER(25,5),
  SWAP_TRADE_PRICE_UNIT_2         VARCHAR2(50 CHAR),
  SWAP_INDEX_INSTRUMENT_2         VARCHAR2(50 CHAR),
  SWAP_FORMULA_2                  VARCHAR2(50 CHAR),
  SWAP_PRODUCT1                   VARCHAR2(50 CHAR),
  SWAP_PRODUCT_QUALITY1           VARCHAR2(50 CHAR),
  SWAP_PRODUCT2                   VARCHAR2(50 CHAR),
  SWAP_PRODUCT_QUALITY2           VARCHAR2(50 CHAR),
  PRICING_INVOICING_STATUS        VARCHAR2(100 CHAR),
  SETTLEMENT_PRICE                NUMBER(25,5),
  SETTLEMENT_PRICE_UNIT           VARCHAR2(50 CHAR),
  APPROVAL_STATUS                 VARCHAR2(50 CHAR),
  TRADING_FEE                     NUMBER(38,5),
  CLEARING_FEE                    NUMBER(38,5),
  TRADING_CLEARING_FEE            NUMBER(38,5),
  CLEARER_COMM_TRADE_TYPE         VARCHAR2(50 CHAR),
  BROKER_COMM_TRADE_TYPE          VARCHAR2(50 CHAR),
  TRADED_ON                       VARCHAR2(50 CHAR),
  PRICE_SOURCE                    VARCHAR2(50 CHAR),
  UNDERLYING_INSTR_REF_NO         NUMBER(5),
  SWAP_PAYMENT_PERIOD_FROM_MONTH  VARCHAR2(3 CHAR),
  SWAP_PAYMENT_PERIOD_FROM_YEAR   NUMBER(4),
  SWAP_PAYMENT_PERIOD_TO_MONTH    VARCHAR2(3 CHAR),
  SWAP_PAYMENT_PERIOD_TO_YEAR     NUMBER(4),
  ALTERNATE_QUANTITY              NUMBER(25,4),
  ALTERNATE_QUANTITY_UNIT         VARCHAR2(50 CHAR),
  FAIR_VALUE_ASSESSMENT           VARCHAR2(50 CHAR),
  LATEST_INTERNAL_ACTION_REF_NO   VARCHAR2(50 CHAR),
  NO_OF_PROMPT_DAYS               NUMBER(5),
  PER_DAY_PRICING_QTY             NUMBER(25,5),
  CORPORATE_SHORT_NAME            VARCHAR2(50 CHAR),
  CP_FIRST_NAME                   VARCHAR2(50 CHAR),
  CP_LAST_NAME                    VARCHAR2(50 CHAR),
  CP_ADDRESS                      VARCHAR2(50 CHAR),
  CP_FAX                          VARCHAR2(50 CHAR),
  CP_COUNTRY                      VARCHAR2(50 CHAR),
  CP_HOME_TELEPHONE               VARCHAR2(50 CHAR),
  CP_MOBILE_NO                    VARCHAR2(50 CHAR),
  CP_PHONE                        VARCHAR2(50 CHAR),
  CORPORATE_ID                    VARCHAR2(50 CHAR),
 CONTACT_PERSON                   VARCHAR2(50 CHAR),
  IS_ACTIVE                       CHAR(1 CHAR)
)
TABLESPACE EKA_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


CREATE UNIQUE INDEX PK_DTD ON DT_D
(INTERNAL_DOC_REF_NO)
LOGGING
TABLESPACE EKA_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL
/


ALTER TABLE DT_D ADD (
  CONSTRAINT PK_DTD
 PRIMARY KEY
 (INTERNAL_DOC_REF_NO)
    USING INDEX 
    TABLESPACE EKA_DATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ))
/

--for dtfbid

/* Formatted on 2012/06/21 12:23 (Formatter Plus v4.8.8) */
CREATE TABLE dt_fbi_d
(
  internal_doc_ref_no          VARCHAR2(15 CHAR),
  dt_fbi_id                   VARCHAR2(15 CHAR) ,
  internal_derivative_ref_no  NUMBER(5)         ,
  index_sequence_number       VARCHAR2(15 CHAR),
  formula_inst             VARCHAR2(15 CHAR),
  formula                 VARCHAR2(15 CHAR),
  instrument              VARCHAR2(15 CHAR),
  price_source            VARCHAR2(15 CHAR),
  price_point            VARCHAR2(15 CHAR),
  available_price          VARCHAR2(15 CHAR),
 
  fb_period_sub_type          VARCHAR2(30 CHAR),
  period_month                VARCHAR2(3 CHAR),
  period_year                 NUMBER(4),
  period_from_date            DATE,
  period_to_date              DATE,
  no_of_months                NUMBER(4),
  no_of_days                  NUMBER(4),
  period_type             VARCHAR2(15 CHAR),
  delivery_period       VARCHAR2(15 CHAR),
  off_day_price               VARCHAR2(30 CHAR),
  basis                       NUMBER(25,5),
  basis_price_unit        VARCHAR2(15 CHAR),
  fx_rate_type                VARCHAR2(15 CHAR),
  fx_rate_                    NUMBER(25,8),
  is_deleted                  CHAR(1 CHAR)    ,
  is_currency_curve           CHAR(1 CHAR),
  fb_period_type           VARCHAR2(15 CHAR),
  monthly_prompt_month    VARCHAR2(15 CHAR),
  leg_no                      CHAR(1 CHAR)

)
TABLESPACE eka_data
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
BUFFER_POOL      DEFAULT
)
LOGGING
NOCOMPRESS
NOCACHE
NOPARALLEL
MONITORING
/


CREATE UNIQUE INDEX pk_dtfbid ON dt_fbi_d
(internal_doc_ref_no,dt_fbi_id)
LOGGING
TABLESPACE eka_data
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
BUFFER_POOL      DEFAULT
)
NOPARALLEL
/


ALTER TABLE dt_fbi_d ADD (
CONSTRAINT pk_dtfbid
PRIMARY KEY
(internal_doc_ref_no,dt_fbi_id)
USING INDEX
TABLESPACE eka_data
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
))
/

--for dsad

/* Formatted on 2012/06/21 12:26 (Formatter Plus v4.8.8) */
CREATE TABLE dsa_d
(
  internal_doc_ref_no          VARCHAR2(15 CHAR),
  internal_der_strategy_acc_id  VARCHAR2(15 CHAR) ,
  internal_derivative_ref_no    NUMBER(5)       ,
  acc                        VARCHAR2(15 CHAR) ,
  acc_qty                       NUMBER(25,4)    ,
  acc_qty_unit               VARCHAR2(15 CHAR),
  profit_center              VARCHAR2(15 CHAR) ,
  buy_sell                      VARCHAR2(15 CHAR) ,
  is_active                     CHAR(1 CHAR)    ,
  allocated_qty                 NUMBER(25,4)

)
TABLESPACE eka_data
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
BUFFER_POOL      DEFAULT
)
LOGGING
NOCOMPRESS
NOCACHE
NOPARALLEL
MONITORING
/


CREATE UNIQUE INDEX pk_dsad ON dsa_d
(internal_doc_ref_no)
LOGGING
TABLESPACE eka_data
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
BUFFER_POOL      DEFAULT
)
NOPARALLEL
/


ALTER TABLE dsa_d ADD (
CONSTRAINT pk_dsad
PRIMARY KEY
(internal_doc_ref_no)
USING INDEX
TABLESPACE eka_data
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
))
/


declare

begin
  for cc in (select tt.internal_derivative_ref_no,
                    tt.dtul_trade_date,
                    tt.dt_trade_date,
                    max(case
                          when dtul.entry_type = 'Insert' then
                           dtul.internal_action_ref_no
                          else
                           null
                        end) insert_internal_axs_no,
                    max(case
                          when dtul.entry_type = 'Update' then
                           dtul.internal_action_ref_no
                          else
                           null
                        end) Update_internal_axs_no,
                    max(case
                          when dtul.entry_type = 'Update' then
                           axs.eff_date
                          else
                           null
                        end) Update_eff_date,
                    max(case
                          when dtul.entry_type = 'Update' then
                           axs.created_date
                          else
                           null
                        end) Update_created_date
               from (SELECT dt.internal_derivative_ref_no,
                            dtul.trade_date dtul_trade_date,
                            to_char(dt.trade_date, 'dd-Mon-yyyy') dt_trade_date
                       FROM DT_DERIVATIVE_TRADE      DT,
                            DTUL_DERIVATIVE_TRADE_UL dtul
                      where dt.internal_derivative_ref_no =
                            dtul.internal_derivative_ref_no
                        and dtul.trade_date is not null
                        and dt.trade_date <>
                            to_date(dtul.trade_date, 'dd-Mon-yyyy')
                        and to_date(dtul.trade_date, 'dd-Mon-yyyy') <
                            dt.trade_date) tt,
                    dtul_derivative_trade_ul dtul,
                    axs_action_summary axs
              where tt.internal_derivative_ref_no =
                    dtul.internal_derivative_ref_no
                and dtul.internal_action_ref_no = axs.internal_action_ref_no
                and dtul.trade_date is not null
              group by tt.internal_derivative_ref_no,
                       tt.dtul_trade_date,
                       tt.dt_trade_date) loop
    update axs_action_summary axs
       set axs.eff_date     = cc.update_eff_date,
           axs.updated_date = cc.update_created_date
     where axs.internal_action_ref_no = cc.insert_internal_axs_no;
  end loop;
end;
/
--for doc conf table entries
DECLARE
   doc_id   VARCHAR2 (15);
   display_order   number (15);
BEGIN
   INSERT INTO dkm_doc_ref_key_master
               (doc_key_id, doc_key_desc, validation_query
               )
        VALUES ('DT_D_KEY', 'DERIVATIVE_TRADE_DOCUMENT',
                'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
               );

   select  'DM-' || seq_dm.NEXTVAL into doc_id from dual;
   
   SELECT dm.display_order + 1 into display_order
   FROM dm_document_master dm
   WHERE dm.display_order = (SELECT MAX (dm1.display_order)FROM dm_document_master dm1);
   
   
   
   INSERT INTO dm_document_master
               (doc_id, doc_name, display_order, VERSION, is_active,is_deleted
               )
        VALUES (doc_id, 'DERIVATIVE_TRADE_DOCUMENT', display_order, NULL, 'Y','N'
               );

   FOR akc_cursor IN (SELECT akc.corporate_id
                        FROM ak_corporate akc)
   LOOP
      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id,doc_id, doc_key_id, is_deleted
                  )
           VALUES ('DRFM-' || seq_drfm.NEXTVAL, akc_cursor.corporate_id,doc_id, 'DT_D_KEY', 'N'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id,corporate_id, prefix, middle_no_start_value, middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-' || seq_drf.NEXTVAL, 'DT_D_KEY',akc_cursor.corporate_id, 'DT-', 0, 0, '-' || akc_cursor.corporate_id, NULL, 'N'
                  );

      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, 
                  corporate_id, doc_id,
                   doc_template_name, 
                   doc_template_name_de,
                   doc_template_name_es, 
                   doc_print_name, 
                   doc_print_name_de,
                   doc_print_name_es, 
                   doc_rpt_file_name, 
                   is_active,
                   doc_auto_generate
                  )
           VALUES ('CDC-DT', 
                   akc_cursor.corporate_id, 
                   doc_id,
                   'DerivativeTradeDoc', 
                   NULL,
                   NULL, 
                   'DOC', 
                   NULL,
                   NULL, 
                   'SWAP.rpt', 
                   'Y',
                   'Y'
                  );
   END LOOP;
END;

/

--for the print doc operation entry
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('OTC_SWAP_TRADES-09', 'LIST_OTC_SWAP_TRADES', 'Print', 7, 2, 
    NULL, 'function(){printDocument();}', NULL, 'OTC_SWAP_TRADES-01', NULL)
/
update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_LEVEL_NO = '3'  where AMC.MENU_ID = 'T113' and AMC.MENU_PARENT_ID = 'T11'
/
update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_LEVEL_NO = '3'  where AMC.MENU_ID = 'T114' and AMC.MENU_PARENT_ID = 'T11'
/
ALTER TABLE drm_derivative_master
 ADD CONSTRAINT fk_drm_delivery_period_id
 FOREIGN KEY (delivery_period_id)
 REFERENCES dpd_delivery_period_definition (delivery_period_id);

 --for dt_d

CREATE TABLE DT_D
(
  INTERNAL_DOC_REF_NO             VARCHAR2(15 CHAR),
  INTERNAL_DERIVATIVE_REF_NO      NUMBER(5),
  DERIVATIVE_REF_NO               VARCHAR2(30 CHAR),
  CORPORATE                       VARCHAR2(50 CHAR),
  TRADER                          VARCHAR2(50 CHAR),
  DR_ID_NAME                      VARCHAR2(50 CHAR),
  TRADE_TYPE                      VARCHAR2(50 CHAR),
  DEAL_TYPE                       VARCHAR2(50 CHAR),
  PROFIT_CENTER                   VARCHAR2(50 CHAR),
  STRATEGY                        VARCHAR2(50 CHAR),
  PURPOSE                         VARCHAR2(50 CHAR),
  EXTERNAL_REF_NO                 VARCHAR2(50 CHAR),
  TRADE_DATE                      DATE,
  CP_PROFILE                      VARCHAR2(50 CHAR),
  MASTER_CONTRACT                 VARCHAR2(50 CHAR),
  BROKER_PROFILE                  VARCHAR2(50 CHAR),
  BROKER_ACCOUNT                  VARCHAR2(50 CHAR),
  BROKER_COMM_TYPE                VARCHAR2(50 CHAR),
  BROKER_COMM_AMT                 NUMBER(25,4),
  BROKER_COMM_CUR                 VARCHAR2(50 CHAR),
  CLEARER_PROFILE                 VARCHAR2(50 CHAR),
  CLEARER_ACCOUNT                 VARCHAR2(50 CHAR),
  CLEARER_COMM_TYPE               VARCHAR2(50 CHAR),
  CLEARER_COMM_AMT                NUMBER(25,4),
  CLEARER_COMM_CUR                VARCHAR2(50 CHAR),
  PRODUCT                         VARCHAR2(50 CHAR),
  QUALITY                         VARCHAR2(50 CHAR),
  QUANTITY_UNIT                   VARCHAR2(50 CHAR),
  TOTAL_LOTS                      NUMBER(6),
  TOTAL_QUANTITY                  NUMBER(25,5),
  OPEN_LOTS                       NUMBER(6),
  OPEN_QUANTITY                   NUMBER(25,4),
  EXERCISED_LOTS                  NUMBER(6),
  EXERCISED_QUANTITY              NUMBER(25,4),
  EXPIRED_LOTS                    NUMBER(6),
  EXPIRED_QUANTITY                NUMBER(25,4),
  TRADE_PRICE_TYPE                VARCHAR2(50 CHAR),
  TRADE_PRICE                     NUMBER(25,5),
  TRADE_PRICE_UNIT                VARCHAR2(50 CHAR),
  FORMULA                         VARCHAR2(50 CHAR),
  INDEX_INSTRUMENT                VARCHAR2(50 CHAR),
  STRIKE_PRICE                    NUMBER(25,5),
  STRIKE_PRICE_UNIT               VARCHAR2(50 CHAR),
  PREMIUM_DISCOUNT                NUMBER(25,5),
  PREMIUM_DISCOUNT_PRICE_UNIT     VARCHAR2(50 CHAR),
  PREMIUM_DUE_DATE                DATE,
  SETTLEMENT_CUR                  VARCHAR2(50 CHAR),
  NOMINEE_PROFILE                 VARCHAR2(50 CHAR),
  REMARKS                         VARCHAR2(4000 CHAR),
  LEG_NO                          NUMBER(1),
  CREATED_BY                      VARCHAR2(50 CHAR),
  MODIFIED_BY                     VARCHAR2(50 CHAR),
  CREATED_DATE                    TIMESTAMP(6),
  LAST_MODIFIED_DATE              TIMESTAMP(6),
  OPTION_EXPIRY_DATE              DATE,
  PARENT_INT_DERIVATIVE_REF_NO    NUMBER(5),
  STATUS                          VARCHAR2(50 CHAR),
  MARKET_LOCATION_COUNTRY         VARCHAR2(50 CHAR),
  MARKET_LOCATION_STATE           VARCHAR2(50 CHAR),
  MARKET_LOCATION_CITY            VARCHAR2(50 CHAR),
  IS_WHAT_IF                      CHAR(50 CHAR) DEFAULT 'N',
  PAYMENT_TERM                    VARCHAR2(50 CHAR),
  PAYMENT_DUE_DATE                DATE,
  IS_IMPORTED                     CHAR(1 CHAR)  DEFAULT 'N',
  CLOSED_LOTS                     NUMBER(6),
  CLOSED_QUANTITY                 NUMBER(25,4),
  INT_TRADE_PARENT_DER_REF_NO     NUMBER(5),
  IS_INTERNAL_TRADE               CHAR(1 CHAR),
  PRICE_POINT                     VARCHAR2(50 CHAR),
  AVAILABLE_PRICE                 VARCHAR2(50 CHAR),
  AVERAGE_FROM_DATE               DATE,
  AVERAGE_TO_DATE                 DATE,
  SWAP_TYPE_1                     VARCHAR2(50 CHAR),
  SWAP_TRADE_PRICE_TYPE_1         VARCHAR2(50 CHAR),
  SWAP_FLOAT_TYPE_1               VARCHAR2(50 CHAR),
  SWAP_TRADE_PRICE_1              NUMBER(25,5),
  SWAP_TRADE_PRICE_UNIT_1         VARCHAR2(50 CHAR),
  SWAP_INDEX_INSTRUMENT_1         VARCHAR2(50 CHAR),
  SWAP_FORMULA_1                  VARCHAR2(50 CHAR),
  SWAP_TYPE_2                     VARCHAR2(50 CHAR),
  SWAP_TRADE_PRICE_TYPE_2         VARCHAR2(50 CHAR),
  SWAP_FLOAT_TYPE_2               VARCHAR2(50 CHAR),
  SWAP_TRADE_PRICE_2              NUMBER(25,5),
  SWAP_TRADE_PRICE_UNIT_2         VARCHAR2(50 CHAR),
  SWAP_INDEX_INSTRUMENT_2         VARCHAR2(50 CHAR),
  SWAP_FORMULA_2                  VARCHAR2(50 CHAR),
  SWAP_PRODUCT1                   VARCHAR2(50 CHAR),
  SWAP_PRODUCT_QUALITY1           VARCHAR2(50 CHAR),
  SWAP_PRODUCT2                   VARCHAR2(50 CHAR),
  SWAP_PRODUCT_QUALITY2           VARCHAR2(50 CHAR),
  PRICING_INVOICING_STATUS        VARCHAR2(100 CHAR),
  SETTLEMENT_PRICE                NUMBER(25,5),
  SETTLEMENT_PRICE_UNIT           VARCHAR2(50 CHAR),
  APPROVAL_STATUS                 VARCHAR2(50 CHAR),
  TRADING_FEE                     NUMBER(38,5),
  CLEARING_FEE                    NUMBER(38,5),
  TRADING_CLEARING_FEE            NUMBER(38,5),
  CLEARER_COMM_TRADE_TYPE         VARCHAR2(50 CHAR),
  BROKER_COMM_TRADE_TYPE          VARCHAR2(50 CHAR),
  TRADED_ON                       VARCHAR2(50 CHAR),
  PRICE_SOURCE                    VARCHAR2(50 CHAR),
  UNDERLYING_INSTR_REF_NO         NUMBER(5),
  SWAP_PAYMENT_PERIOD_FROM_MONTH  VARCHAR2(3 CHAR),
  SWAP_PAYMENT_PERIOD_FROM_YEAR   NUMBER(4),
  SWAP_PAYMENT_PERIOD_TO_MONTH    VARCHAR2(3 CHAR),
  SWAP_PAYMENT_PERIOD_TO_YEAR     NUMBER(4),
  ALTERNATE_QUANTITY              NUMBER(25,4),
  ALTERNATE_QUANTITY_UNIT         VARCHAR2(50 CHAR),
  FAIR_VALUE_ASSESSMENT           VARCHAR2(50 CHAR),
  LATEST_INTERNAL_ACTION_REF_NO   VARCHAR2(50 CHAR),
  NO_OF_PROMPT_DAYS               NUMBER(5),
  PER_DAY_PRICING_QTY             NUMBER(25,5),
  CORPORATE_SHORT_NAME            VARCHAR2(50 CHAR),
  CP_FIRST_NAME                   VARCHAR2(50 CHAR),
  CP_LAST_NAME                    VARCHAR2(50 CHAR),
  CP_ADDRESS                      VARCHAR2(50 CHAR),
  CP_FAX                          VARCHAR2(50 CHAR),
  CP_COUNTRY                      VARCHAR2(50 CHAR),
  CP_HOME_TELEPHONE               VARCHAR2(50 CHAR),
  CP_MOBILE_NO                    VARCHAR2(50 CHAR),
  CP_PHONE                        VARCHAR2(50 CHAR),
  CORPORATE_ID                    VARCHAR2(50 CHAR),
 CONTACT_PERSON                   VARCHAR2(50 CHAR),
  IS_ACTIVE                       CHAR(1 CHAR)
)
TABLESPACE EKA_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


CREATE UNIQUE INDEX PK_DTD ON DT_D
(INTERNAL_DOC_REF_NO)
LOGGING
TABLESPACE EKA_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL
/


ALTER TABLE DT_D ADD (
  CONSTRAINT PK_DTD
 PRIMARY KEY
 (INTERNAL_DOC_REF_NO)
    USING INDEX 
    TABLESPACE EKA_DATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ))
/

--for dtfbid

/* Formatted on 2012/06/21 12:23 (Formatter Plus v4.8.8) */
CREATE TABLE dt_fbi_d
(
  internal_doc_ref_no          VARCHAR2(15 CHAR),
  dt_fbi_id                   VARCHAR2(15 CHAR) ,
  internal_derivative_ref_no  NUMBER(5)         ,
  index_sequence_number       VARCHAR2(15 CHAR),
  formula_inst             VARCHAR2(15 CHAR),
  formula                 VARCHAR2(15 CHAR),
  instrument              VARCHAR2(15 CHAR),
  price_source            VARCHAR2(15 CHAR),
  price_point            VARCHAR2(15 CHAR),
  available_price          VARCHAR2(15 CHAR),
 
  fb_period_sub_type          VARCHAR2(30 CHAR),
  period_month                VARCHAR2(3 CHAR),
  period_year                 NUMBER(4),
  period_from_date            DATE,
  period_to_date              DATE,
  no_of_months                NUMBER(4),
  no_of_days                  NUMBER(4),
  period_type             VARCHAR2(15 CHAR),
  delivery_period       VARCHAR2(15 CHAR),
  off_day_price               VARCHAR2(30 CHAR),
  basis                       NUMBER(25,5),
  basis_price_unit        VARCHAR2(15 CHAR),
  fx_rate_type                VARCHAR2(15 CHAR),
  fx_rate_                    NUMBER(25,8),
  is_deleted                  CHAR(1 CHAR)    ,
  is_currency_curve           CHAR(1 CHAR),
  fb_period_type           VARCHAR2(15 CHAR),
  monthly_prompt_month    VARCHAR2(15 CHAR),
  leg_no                      CHAR(1 CHAR)

)
TABLESPACE eka_data
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
BUFFER_POOL      DEFAULT
)
LOGGING
NOCOMPRESS
NOCACHE
NOPARALLEL
MONITORING
/


CREATE UNIQUE INDEX pk_dtfbid ON dt_fbi_d
(internal_doc_ref_no,dt_fbi_id)
LOGGING
TABLESPACE eka_data
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
BUFFER_POOL      DEFAULT
)
NOPARALLEL
/


ALTER TABLE dt_fbi_d ADD (
CONSTRAINT pk_dtfbid
PRIMARY KEY
(internal_doc_ref_no,dt_fbi_id)
USING INDEX
TABLESPACE eka_data
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
))
/

--for dsad

/* Formatted on 2012/06/21 12:26 (Formatter Plus v4.8.8) */
CREATE TABLE dsa_d
(
  internal_doc_ref_no          VARCHAR2(15 CHAR),
  internal_der_strategy_acc_id  VARCHAR2(15 CHAR) ,
  internal_derivative_ref_no    NUMBER(5)       ,
  acc                        VARCHAR2(15 CHAR) ,
  acc_qty                       NUMBER(25,4)    ,
  acc_qty_unit               VARCHAR2(15 CHAR),
  profit_center              VARCHAR2(15 CHAR) ,
  buy_sell                      VARCHAR2(15 CHAR) ,
  is_active                     CHAR(1 CHAR)    ,
  allocated_qty                 NUMBER(25,4)

)
TABLESPACE eka_data
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
BUFFER_POOL      DEFAULT
)
LOGGING
NOCOMPRESS
NOCACHE
NOPARALLEL
MONITORING
/


CREATE UNIQUE INDEX pk_dsad ON dsa_d
(internal_doc_ref_no)
LOGGING
TABLESPACE eka_data
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
BUFFER_POOL      DEFAULT
)
NOPARALLEL
/


ALTER TABLE dsa_d ADD (
CONSTRAINT pk_dsad
PRIMARY KEY
(internal_doc_ref_no)
USING INDEX
TABLESPACE eka_data
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
INITIAL          64 k
MINEXTENTS       1
MAXEXTENTS       UNLIMITED
PCTINCREASE      0
))
/



update FTUL_FREIGHT_TRADE_UL ftul
set FTUL.TRADE_DATE = substr(FTUL.TRADE_DATE,1,instr(FTUL.TRADE_DATE,' '))
where FTUL.TRADE_DATE is not null
/

update FTUL_FREIGHT_TRADE_UL ftul
set FTUL.TRADE_DATE = to_char( to_date(FTUL.TRADE_DATE , 'dd-MM-rrrr') , 'dd-Mon-rrrr' )
where FTUL.TRADE_DATE is not null
/
update GM_GRID_MASTER gm
set GM.SCREEN_SPECIFIC_JS = '/private/js/trademanagement/derivative/ListofDerivativesTrade.js'
where GM.GRID_ID = 'LIST_DER_TRADES'
/
ALTER TABLE DT_FBI_D
MODIFY(INSTRUMENT VARCHAR2(50 CHAR))
/
UPDATE itcm_imp_table_column_mapping itcm
   SET itcm.db_column_name = 'DELIVERY_PERIOD'
 WHERE itcm.file_type_id = 'IMPORT_FX_OPTION_QUOTES'
   AND itcm.db_column_name = 'PERIOD'
/
