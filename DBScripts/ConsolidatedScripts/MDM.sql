----------------------------------------------
--MDM 1.5.8-------------------------------------
------------------------------------------------
set define off;

create table BRKMM_BROKER_MARGIN_MASTER(
BROKER_MARGIN_ID VARCHAR2(15) NOT NULL,
BROKER_PROFILE_ID VARCHAR2(15) NOT NULL,
IS_DELETED CHAR(1) DEFAULT 'N' NOT NULL
)
/
 
 
ALTER TABLE BRKMM_BROKER_MARGIN_MASTER ADD (
  CONSTRAINT CHK_BRKMM_IS_DELETED
CHECK (IS_DELETED IN ('Y','N')),
  CONSTRAINT PK_BRKMM
PRIMARY KEY
(BROKER_MARGIN_ID))
/ 
 
ALTER TABLE BRKMM_BROKER_MARGIN_MASTER ADD (
  CONSTRAINT FK_BRKMM_BROKER_PROFILE_ID
FOREIGN KEY (BROKER_PROFILE_ID) 
REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID))
/ 
 
create table BRKMD_BROKER_MARGIN_DETAIL(
BROKER_MARGIN_DETAIL_ID VARCHAR2(15) NOT NULL,
BROKER_MARGIN_ID VARCHAR2(15) NOT NULL,
INSTRUMENT_ID VARCHAR2(15) NOT NULL,
CURRENCY_ID VARCHAR2(15) NOT NULL,
INTIAL_MARGIN_LIMIT NUMBER(20,5) NOT NULL,
VARIATION_MARGIN_LIMIT NUMBER(20,5) NOT NULL,
CURRENT_CREDIT_LIMIT NUMBER(20,5) NOT NULL,
MAINTENANCE_MARGIN NUMBER(20,5),
MARGIN_CALCULATION_ID VARCHAR2(50) NOT NULL,
IS_DELETED CHAR(1) DEFAULT 'N' NOT NULL
)
/ 
 
ALTER TABLE BRKMD_BROKER_MARGIN_DETAIL ADD (
  CONSTRAINT CHK_BRKMD_IS_DELETED
CHECK (IS_DELETED IN ('Y','N')),
  CONSTRAINT PK_BRKMD
PRIMARY KEY
(BROKER_MARGIN_DETAIL_ID))
/ 
 
  ALTER TABLE BRKMD_BROKER_MARGIN_DETAIL ADD (
  CONSTRAINT FK_BRKMD_BROKER_MARGIN_ID
FOREIGN KEY (BROKER_MARGIN_ID) 
REFERENCES BRKMM_BROKER_MARGIN_MASTER (BROKER_MARGIN_ID))
/ 
 
  ALTER TABLE BRKMD_BROKER_MARGIN_DETAIL ADD (
  CONSTRAINT FK_BRKMD_INSTRUMENT_ID
FOREIGN KEY (INSTRUMENT_ID) 
REFERENCES DIM_DER_INSTRUMENT_MASTER (INSTRUMENT_ID))
/ 
 
 
  ALTER TABLE BRKMD_BROKER_MARGIN_DETAIL ADD (
  CONSTRAINT FK_BRKMD_CURRENCY_ID
FOREIGN KEY (CURRENCY_ID) 
REFERENCES CM_CURRENCY_MASTER (CUR_ID))
/ 
  ALTER TABLE BRKMD_BROKER_MARGIN_DETAIL ADD (
  CONSTRAINT FK_BRKMD_MARGIN_CALCULATION_ID
FOREIGN KEY (MARGIN_CALCULATION_ID) 
REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID))
/
-- creating sequence


  CREATE SEQUENCE SEQ_BRKMM
  START WITH 121
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
/

-- IRC_INTERNAL_REF_NO_CONFIG insertion


   insert into irc_internal_ref_no_config
     (internal_ref_no_key, prefix, seq_name)
   values
     ('PK_BRKMM', 'BRKMM', 'SEQ_BRKMM')
/

--  AXM_ACTION_MASTER insertion


  insert into axm_action_master
    (action_id,
     entity_id,
     action_name,
     is_new_gmr_applicable
     )
  values
    ('BRKMM_BROKER_MARGIN_MASTER',
     'MDM',
     'Broker Margin Master',
     'N'
      )
/

-- creating sequence


  CREATE SEQUENCE SEQ_BRKMD
  START WITH 121
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
/

-- IRC_INTERNAL_REF_NO_CONFIG insertion


   insert into irc_internal_ref_no_config
     (internal_ref_no_key, prefix, seq_name)
   values
     ('PK_BRKMD', 'BRKMD', 'SEQ_BRKMD')
/

--  AXM_ACTION_MASTER insertion


  insert into axm_action_master
    (action_id,
     entity_id,
     action_name,
     is_new_gmr_applicable
     )
  values
    ('BRKMD_BROKER_MARGIN_DETAIL',
     'MDM',
     'Broker Margin Detail',
     'N'
      )
/


-- SML

update SML_SETUP_MASTER_LINK_LIST sml set SML.SORT_ORDER = 5 where SML.LINK_ID = 'SML-17-OVS-CUS'
/


Insert into SML_SETUP_MASTER_LINK_LIST
   (LINK_ID, SECTION_ID, LINK_NAME, LINK_DESC, FEATURE_ID, 
    ACTION_METHOD, SORT_ORDER, ACL_ID)
 Values
   ('SML-17-BMS', 'SSM-17', 'Broker Margin', 'Broker Margin Setup', NULL, 
    '/mdm/commonListing.do?method=getCommonListingPage&gridId=BRKMM_BROKER_MARGIN_MASTER', 4, NULL)
/

-- Insert GM

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('BRKMM_BROKER_MARGIN_MASTER', 'Broker Margin', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20}, {header: "Broker", width: 150, sortable: true, dataIndex: "brokerProfileName"}, {header: "Is Active", width: 150, sortable: true, dataIndex: "isActive"}]', NULL, '/mdm/commonListing.do?method=getListingData', 
    NULL, NULL, '/private/jsp/masterdatasetup/BrokerMarginMasterListing.jsp', '/mdm/private/js/masterdatasetup/BrokerMarginMasterListing.js,    /mdm/private/js/masterdatasetup/BrokerMarginMasterListingCustomValidation.js,    /mdm/private/js/masterdatasetup/MasterDataSetupListingCommonFunctions.js,    /mdm/private/js/masterdatasetup/BrokerMarginMasterCustomValidation.js,    /mdm/private/js/masterdatasetup/BrokerMarginMaster.js')
/

-- Insert GMC

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BRKMM_BROKER_MARGIN_MASTER-01', 'BRKMM_BROKER_MARGIN_MASTER', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BRKMM_BROKER_MARGIN_MASTER-02', 'BRKMM_BROKER_MARGIN_MASTER', 'Add / Modify', 1, 2, 
    NULL, 'function(){addModifyBrokerMargin();}', NULL, 'BRKMM_BROKER_MARGIN_MASTER-01', NULL)
/

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BRKMM_BROKER_MARGIN_MASTER-03', 'BRKMM_BROKER_MARGIN_MASTER', 'View', 2, 2, 
    NULL, 'function(){callView();}', NULL, 'BRKMM_BROKER_MARGIN_MASTER-01', NULL)
/


-- SLS/SLV

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('NET_LOTS', 'Net Lots')
/
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('GROSS_LOTS', 'Gross Lots')
/

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('MarginCalType', 'NET_LOTS', 'N', 1)
/
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('MarginCalType', 'GROSS_LOTS', 'N', 2)
/
----------------------------------------------
--MDM 1.5.9-------------------------------------
------------------------------------------------
Insert into RNC_REFERENCE_TABLE_NOT_REQ
   (TABLE_NAME, REF_TABLE_NAME)
 Values
   ('ASL_APPROVAL_SUB_LEVEL', 'ASLUD_ASL_USER_DETAIL')
/
CREATE TABLE AUMHP_ANALYTICS_UMHP(
    AUMHP_ID                VARCHAR2(15)    NOT NULL,
    PORTLET_CATEGORY_ID     VARCHAR2(15)    NOT NULL,
    PANEL_NAME              VARCHAR2(2000)   NOT NULL,
    INTERNAL_URL            VARCHAR2(2000),
    EXTERNAL_URL            VARCHAR2(2000),
    CONFIG                  CLOB,
    IS_DELETED              CHAR(1),
    ACL_ID                  VARCHAR2(20)
)
/

ALTER TABLE AUMHP_ANALYTICS_UMHP ADD (CONSTRAINT PK_AUMHP PRIMARY KEY (AUMHP_ID))
/

ALTER TABLE AUMHP_ANALYTICS_UMHP ADD (
  CONSTRAINT FK_AUMHP_PORTLET_CATEGORY_ID 
 FOREIGN KEY (PORTLET_CATEGORY_ID) 
 REFERENCES PC_PORTLET_CATEGORY (PORTLET_CATEGORY_ID))
/

ALTER TABLE AUMHP_ANALYTICS_UMHP ADD (
  CONSTRAINT FK_AUMHP_ACL_ID 
 FOREIGN KEY (ACL_ID) 
 REFERENCES ACL_ACCESS_CONTROL_LIST (ACL_ID))
/

ALTER TABLE PRLTD_PORTLET_DETAIL
 ADD (ACL_ID  VARCHAR2(20 CHAR))
/

ALTER TABLE PRLTD_PORTLET_DETAIL ADD (
  CONSTRAINT FK_PRLTD_ACL_ID 
 FOREIGN KEY (ACL_ID) 
 REFERENCES ACL_ACCESS_CONTROL_LIST (ACL_ID))
/

Insert into PFG_PRODUCTFEATUREGROUP
   (FEATURE_GROUP_ID, FEATURE_GROUP_NAME)
 Values
   ('HOME-PFG-1', 'Home Page')
/


Insert into PFL_PRODUCTFEATURELIST
   (FEATURE_ID, FEATURE_TITLE, FEATURE_TYPE, FEATURE_DESCRIPTION, FEATURE_GROUP_ID, 
    ACTION_ID)
 Values
   ('HOME-PFL-1', 'Quick Search', 'STANDARD', 'Quick Search', 'HOME-PFG-1', 
    NULL)
/
    
Insert into PFL_PRODUCTFEATURELIST
   (FEATURE_ID, FEATURE_TITLE, FEATURE_TYPE, FEATURE_DESCRIPTION, FEATURE_GROUP_ID, 
    ACTION_ID)
 Values
   ('HOME-PFL-2', 'Alerts and Remainders', 'STANDARD', 'Alerts and Remainders', 'HOME-PFG-1', 
    NULL)
/
    
Insert into PFL_PRODUCTFEATURELIST
   (FEATURE_ID, FEATURE_TITLE, FEATURE_TYPE, FEATURE_DESCRIPTION, FEATURE_GROUP_ID, 
    ACTION_ID)
 Values
   ('HOME-PFL-3', 'Contracts', 'STANDARD', 'Contracts', 'HOME-PFG-1', 
    NULL)
/
    
Insert into PFL_PRODUCTFEATURELIST
   (FEATURE_ID, FEATURE_TITLE, FEATURE_TYPE, FEATURE_DESCRIPTION, FEATURE_GROUP_ID, 
    ACTION_ID)
 Values
   ('HOME-PFL-4', 'Position Dashboard', 'STANDARD', 'Position Dashboard', 'HOME-PFG-1', 
    NULL)
/


Insert into PFL_PRODUCTFEATURELIST
   (FEATURE_ID, FEATURE_TITLE, FEATURE_TYPE, FEATURE_DESCRIPTION, FEATURE_GROUP_ID, 
    ACTION_ID)
 Values
   ('HOME-PFL-5', 'PnL', 'STANDARD', 'PnL', 'HOME-PFG-1', 
    NULL)
/

Insert into PFL_PRODUCTFEATURELIST
   (FEATURE_ID, FEATURE_TITLE, FEATURE_TYPE, FEATURE_DESCRIPTION, FEATURE_GROUP_ID, 
    ACTION_ID)
 Values
   ('HOME-PFL-6', 'Exposure', 'STANDARD', 'Exposure', 'HOME-PFG-1', 
    NULL)
/


Insert into MODULE_MASTER
   (MODULE_ID, MODULE_NAME, MODULE_SORT_ID, SECTION_ID)
 Values
   ('HOME-MM-1', 'Home Page', 1, 'RSM-4')
/


Insert into ACM_ACTIVITY_MASTER
   (ACTIVITY_ID, ACTIVITY_NAME, ACTIVITY_DESCRIPTION, MODULE_ID, FEATURE_ID, 
    ACTIVITY_SORT_ID, ACTIVITY_NAME_DE, ACTIVITY_NAME_ES)
 Values
   ('HOME-ACM-1', 'Quick Search', 'Quick Search', 'HOME-MM-1', 'HOME-PFL-1', 
    1, NULL, NULL)
/
    
Insert into ACM_ACTIVITY_MASTER
   (ACTIVITY_ID, ACTIVITY_NAME, ACTIVITY_DESCRIPTION, MODULE_ID, FEATURE_ID, 
    ACTIVITY_SORT_ID, ACTIVITY_NAME_DE, ACTIVITY_NAME_ES)
 Values
   ('HOME-ACM-2', 'Alerts and Remainders', 'Alerts and Remainders', 'HOME-MM-1', 'HOME-PFL-2', 
    2, NULL, NULL)
/


    
Insert into ACM_ACTIVITY_MASTER
   (ACTIVITY_ID, ACTIVITY_NAME, ACTIVITY_DESCRIPTION, MODULE_ID, FEATURE_ID, 
    ACTIVITY_SORT_ID, ACTIVITY_NAME_DE, ACTIVITY_NAME_ES)
 Values
   ('HOME-ACM-3', 'Contracts', 'Contracts', 'HOME-MM-1', 'HOME-PFL-3', 
    3, NULL, NULL)
/

    
Insert into ACM_ACTIVITY_MASTER
   (ACTIVITY_ID, ACTIVITY_NAME, ACTIVITY_DESCRIPTION, MODULE_ID, FEATURE_ID, 
    ACTIVITY_SORT_ID, ACTIVITY_NAME_DE, ACTIVITY_NAME_ES)
 Values
   ('HOME-ACM-4', 'Position Dashboard', 'Position Dashboard', 'HOME-MM-1', 'HOME-PFL-4', 
    4, NULL, NULL)
/

Insert into ACM_ACTIVITY_MASTER
   (ACTIVITY_ID, ACTIVITY_NAME, ACTIVITY_DESCRIPTION, MODULE_ID, FEATURE_ID, 
    ACTIVITY_SORT_ID, ACTIVITY_NAME_DE, ACTIVITY_NAME_ES)
 Values
   ('HOME-ACM-5', 'PnL', 'PnL', 'HOME-MM-1', 'HOME-PFL-5', 
    5, NULL, NULL)
/

Insert into ACM_ACTIVITY_MASTER
   (ACTIVITY_ID, ACTIVITY_NAME, ACTIVITY_DESCRIPTION, MODULE_ID, FEATURE_ID, 
    ACTIVITY_SORT_ID, ACTIVITY_NAME_DE, ACTIVITY_NAME_ES)
 Values
   ('HOME-ACM-6', 'Exposure', 'Exposure', 'HOME-MM-1', 'HOME-PFL-6', 
    6, NULL, NULL)
/


Insert into ACL_ACCESS_CONTROL_LIST
   (ACL_ID, ACL_NAME, ACL_DESCRIPTION, ACTIVITY_ID, ACL_CHECK_FLAG, 
    ACL_CATEGORY_MASTER_ID)
 Values
   ('HOME-ACL-1', 'Quick Search', 'Quick Search', 'HOME-ACM-1', 'Y', 
    NULL)
/


Insert into ACL_ACCESS_CONTROL_LIST
   (ACL_ID, ACL_NAME, ACL_DESCRIPTION, ACTIVITY_ID, ACL_CHECK_FLAG, 
    ACL_CATEGORY_MASTER_ID)
 Values
   ('HOME-ACL-2', 'Alerts and Remainders', 'Alerts and Remainders', 'HOME-ACM-2', 'Y', 
    NULL)
/


Insert into ACL_ACCESS_CONTROL_LIST
   (ACL_ID, ACL_NAME, ACL_DESCRIPTION, ACTIVITY_ID, ACL_CHECK_FLAG, 
    ACL_CATEGORY_MASTER_ID)
 Values
   ('HOME-ACL-3', 'Contracts', 'Contracts', 'HOME-ACM-3', 'Y', 
    NULL)
/


Insert into ACL_ACCESS_CONTROL_LIST
   (ACL_ID, ACL_NAME, ACL_DESCRIPTION, ACTIVITY_ID, ACL_CHECK_FLAG, 
    ACL_CATEGORY_MASTER_ID)
 Values
   ('HOME-ACL-4', 'Position Dashboard', 'Position Dashboard', 'HOME-ACM-4', 'Y', 
    NULL)
/

Insert into ACL_ACCESS_CONTROL_LIST
   (ACL_ID, ACL_NAME, ACL_DESCRIPTION, ACTIVITY_ID, ACL_CHECK_FLAG, 
    ACL_CATEGORY_MASTER_ID)
 Values
   ('HOME-ACL-5', 'PnL', 'PnL', 'HOME-ACM-5', 'Y', 
    NULL)
/
    
Insert into ACL_ACCESS_CONTROL_LIST
   (ACL_ID, ACL_NAME, ACL_DESCRIPTION, ACTIVITY_ID, ACL_CHECK_FLAG, 
    ACL_CATEGORY_MASTER_ID)
 Values
   ('HOME-ACL-6', 'Exposure', 'Exposure', 'HOME-ACM-6', 'Y', 
    NULL)
/

Insert into PC_PORTLET_CATEGORY
   (PORTLET_CATEGORY_ID, PORTLET_CATEGORY_NAME)
 Values
   ('PC-4', 'Analytics')
/

update PRLTD_PORTLET_DETAIL prltd set PRLTD.ACL_ID='HOME-ACL-1'
where PRLTD.PORTLET_ID='PRLTD-1'
/

update PRLTD_PORTLET_DETAIL prltd set PRLTD.ACL_ID='HOME-ACL-2'
where PRLTD.PORTLET_ID='PRLTD-2'
/

update PRLTD_PORTLET_DETAIL prltd set PRLTD.ACL_ID='HOME-ACL-3'
where PRLTD.PORTLET_ID='PRLTD-3'
/


update CUMHP_CUSTOM_UMHP cumhp set CUMHP.IS_DELETED = 'Y'
/

update UMHP_USER_MODULE_HOME_PAGE umhp set UMHP.CONFIG = '{"collapsed":true,"closed":false,"columnIndex":1,"rowIndex":1}'
where UMHP.MHP_ID = 'MHP-1'
/

update UMHP_USER_MODULE_HOME_PAGE umhp set UMHP.CONFIG = '{"collapsed":true,"closed":false,"columnIndex":1,"rowIndex":2}'
where UMHP.MHP_ID = 'MHP-2'
/

update UMHP_USER_MODULE_HOME_PAGE umhp set UMHP.CONFIG = '{"collapsed":true,"closed":false,"columnIndex":1,"rowIndex":3}'
where UMHP.MHP_ID = 'MHP-3'
/

delete from AUMHP_ANALYTICS_UMHP
/


Insert into AUMHP_ANALYTICS_UMHP
   (AUMHP_ID, PORTLET_CATEGORY_ID, PANEL_NAME, INTERNAL_URL, EXTERNAL_URL, 
    CONFIG, IS_DELETED, ACL_ID)
 Values
   ('AUMHP-1', 'PC-4', 'Position Dashboard <a href="/iekaDashboardPage.do?method=getPortalMetadataJson&portalId=PRTLM-2"><img src="/private/images/bidashboard.gif" width="16" height="16"/></a> <a href="/ekaBI/biSpecificAction.do?method=getBIPage&URL_PROPERTY=PMURL"><img src="/private/images/bimanager.png" width="16" height="16"/></a>', '/getPortalListing.do?method=getCustomPortalDetails', '/iekaDashboardPage.do?method=getPortletItemMetadata&ieka=Y&portletId=PRLTM-26&graphicalView=IGVD-26&portalId=PRTLM-2', 
    '{"collapsed":true,"closed":false,"columnIndex":2,"rowIndex":1}', 'N', 'HOME-ACL-4')
/

Insert into AUMHP_ANALYTICS_UMHP
   (AUMHP_ID, PORTLET_CATEGORY_ID, PANEL_NAME, INTERNAL_URL, EXTERNAL_URL, 
    CONFIG, IS_DELETED, ACL_ID)
 Values
   ('AUMHP-2', 'PC-4', 'PnL <a href="/iekaDashboardPage.do?method=getPortalMetadataJson&portalId=PRTLM-101"><img src="/private/images/bidashboard.gif" width="16" height="16"/></a> <a href="/ekaBI/biSpecificAction.do?method=getBIPage&URL_PROPERTY=UMURL"><img src="/private/images/bimanager.png" width="16" height="16"/></a>', '/getPortalListing.do?method=getCustomPortalDetails', '/iekaDashboardPage.do?method=getPortletItemMetadata&ieka=Y&portletId=PRLTM-101&graphicalView=IGVD-101&portalId=PRTLM-101', 
    '{"collapsed":true,"closed":false,"columnIndex":2,"rowIndex":2}', 'N', 'HOME-ACL-5')
/

Insert into AUMHP_ANALYTICS_UMHP
   (AUMHP_ID, PORTLET_CATEGORY_ID, PANEL_NAME, INTERNAL_URL, EXTERNAL_URL, 
    CONFIG, IS_DELETED, ACL_ID)
 Values
   ('AUMHP-3', 'PC-4', 'Exposure <a href="/iekaDashboardPage.do?method=getPortalMetadataJson&portalId=PRTLM-3"><img src="/private/images/bidashboard.gif" width="16" height="16"/></a> <a href="/ekaBI/biSpecificAction.do?method=getBIPage&URL_PROPERTY=EMURL"><img src="/private/images/bimanager.png" width="16" height="16"/></a>', '/getPortalListing.do?method=getCustomPortalDetails', '/iekaDashboardPage.do?method=getPortletItemMetadata&ieka=Y&portletId=PRLTM-32&graphicalView=IGVD-32&portalId=PRTLM-3', 
    '{"collapsed":true,"closed":false,"columnIndex":2,"rowIndex":3}', 'N', 'HOME-ACL-6')
/

