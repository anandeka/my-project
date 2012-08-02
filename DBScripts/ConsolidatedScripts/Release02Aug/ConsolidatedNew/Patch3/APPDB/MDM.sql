set define off;
--insert into ISTM

Insert into ISTM_INSTR_SUB_TYPE_MASTER (INSTRUMENT_SUB_TYPE_ID, INSTRUMENT_SUB_TYPE, INST_SUB_TYPE_DISPLAY_NAME, INSTRUMENT_TYPE_ID, DISPLAY_ORDER, VERSION, IS_ACTIVE, IS_DELETED)
Values ('ISTM-11', 'Asian', 'Asian', 'IRM-2', 11, '1', 'Y', 'N')
/
Insert into ISTM_INSTR_SUB_TYPE_MASTER (INSTRUMENT_SUB_TYPE_ID, INSTRUMENT_SUB_TYPE, INST_SUB_TYPE_DISPLAY_NAME, INSTRUMENT_TYPE_ID, DISPLAY_ORDER,
VERSION, IS_ACTIVE, IS_DELETED) Values ('ISTM-12', 'Asian', 'Asian', 'IRM-3', 12, '1', 'Y', 'N')
/

alter table BCT_BROKER_COMMISSION_TYPES add IS_DEFAULT_COMISSION_TYPE CHAR(1) DEFAULT 'N' NOT NULL
/

alter table BCT_BROKER_COMMISSION_TYPES add INCOME_EXPENSE VARCHAR2 (15 Char) default 'CostExpense'
/

ALTER TABLE BCT_BROKER_COMMISSION_TYPES ADD (
  CONSTRAINT FK_BCT_INCOME_EXPENSE 
 FOREIGN KEY (INCOME_EXPENSE) 
 REFERENCES  SLV_STATIC_LIST_VALUE (VALUE_ID))
/ 

alter table BPA_BP_BANK_ACCOUNTS add IS_DEFAULT_BANK_ACCOUNT CHAR(1) DEFAULT 'N' NOT NULL
/

alter table OBA_OUR_BANK_ACCOUNTS add IS_DEFAULT_BANK_ACCOUNT CHAR(1) DEFAULT 'N' NOT NULL
/

create table BTM_BUSINESS_TYPE_MASTER(
BUSINESS_TYPE_ID VARCHAR2(15) NOT NULL,
BUSINESS_TYPE VARCHAR2(50) NOT NULL,
BUSINESS_TYPE_DESC VARCHAR2(2000) NOT NULL,
GROUP_ID VARCHAR2(15) NOT NULL,
VERSION VARCHAR2(15),
IS_ACTIVE CHAR(1) DEFAULT 'Y' NOT NULL,
IS_DELETED CHAR(1) DEFAULT 'N' NOT NULL
)
/

ALTER TABLE BTM_BUSINESS_TYPE_MASTER ADD (
  CONSTRAINT CHK_BTM_IS_DELETED
CHECK (IS_DELETED IN ('Y','N')),
  CONSTRAINT CHK_BTM_IS_ACTIVE
CHECK (IS_ACTIVE IN ('Y','N')),
  CONSTRAINT PK_BTM
PRIMARY KEY
(BUSINESS_TYPE_ID))
/ 


ALTER TABLE BTM_BUSINESS_TYPE_MASTER ADD (
  CONSTRAINT FK_BTM_GROUP_ID 
 FOREIGN KEY (GROUP_ID) 
 REFERENCES GCD_GROUPCORPORATEDETAILS (GROUPID))
/ 
-- creating sequence

  CREATE SEQUENCE SEQ_BTM
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
     ('PK_BTM', 'BTM', 'SEQ_BTM')
/
--  AXM_ACTION_MASTER insertion

  insert into axm_action_master
    (action_id,
     entity_id,
     action_name,
     is_new_gmr_applicable
     )
  values
    ('BTM_BUSINESS_TYPE_MASTER',
     'MDM',
     'Business Type Master',
     'N'
      )
/


Insert into SML_SETUP_MASTER_LINK_LIST
   (LINK_ID, SECTION_ID, LINK_NAME, LINK_DESC, FEATURE_ID, 
    ACTION_METHOD, SORT_ORDER, ACL_ID)
 Values
   ('SML-26-BTM', 'SSM-26', 'Business Type', 'Business Type Setup', NULL, 
    '/mdm/commonListing.do?method=getCommonListingPage&gridId=BTM_BUSINESS_TYPE_MASTER', 3, NULL)
/

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('BTM_BUSINESS_TYPE_MASTER', 'Business Type List', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20}, {header: "Business Type Name", width: 150, sortable: true, dataIndex: "businessType"}, {header: "Business Type Description", width: 150, sortable: true, dataIndex: "businessTypeDesc"}, {header: "Is Active", width: 150, sortable: true, dataIndex: "isActive"}]', NULL, '/mdm/commonListing.do?method=getListingData', 
    NULL, NULL, '/private/jsp/masterdatasetup/BusinessTypeMasterListing.jsp', '/mdm/private/js/masterdatasetup/BusinessTypeMasterListing.js,/mdm/private/js/masterdatasetup/BusinessTypeMasterListingCustomValidation.js,/mdm/private/js/masterdatasetup/MasterDataSetupListingCommonFunctions.js,/mdm/private/js/masterdatasetup/BusinessTypeMasterCustomValidation.js,/mdm/private/js/masterdatasetup/BusinessTypeMaster.js')
/


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BTM_BUSINESS_TYPE_MASTER-01', 'BTM_BUSINESS_TYPE_MASTER', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BTM_BUSINESS_TYPE_MASTER-02', 'BTM_BUSINESS_TYPE_MASTER', 'New', 1, 2, 
    NULL, 'function(){callNew();}', NULL, 'BTM_BUSINESS_TYPE_MASTER-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BTM_BUSINESS_TYPE_MASTER-03', 'BTM_BUSINESS_TYPE_MASTER', 'Modify', 2, 2, 
    NULL, 'function(){callModify();}', NULL, 'BTM_BUSINESS_TYPE_MASTER-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BTM_BUSINESS_TYPE_MASTER-04', 'BTM_BUSINESS_TYPE_MASTER', 'Delete', 3, 2, 
    NULL, 'function(){callDelete();}', NULL, 'BTM_BUSINESS_TYPE_MASTER-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BTM_BUSINESS_TYPE_MASTER-05', 'BTM_BUSINESS_TYPE_MASTER', 'Activate', 4, 2, 
    NULL, 'function(){callActivate();}', NULL, 'BTM_BUSINESS_TYPE_MASTER-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BTM_BUSINESS_TYPE_MASTER-06', 'BTM_BUSINESS_TYPE_MASTER', 'DeActivate', 5, 2, 
    NULL, 'function(){callDeActivate();}', NULL, 'BTM_BUSINESS_TYPE_MASTER-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BTM_BUSINESS_TYPE_MASTER-07', 'BTM_BUSINESS_TYPE_MASTER', 'Import', 6, 2, 
    NULL, 'function(){callImport();}', NULL, 'BTM_BUSINESS_TYPE_MASTER-01', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('BTM_BUSINESS_TYPE_MASTER-8', 'BTM_BUSINESS_TYPE_MASTER', 'View', 9, 2, 
    NULL, 'function(){callView();}', NULL, 'BTM_BUSINESS_TYPE_MASTER-01', NULL)
/



Insert into RCDM_REF_COL_DESC_MAPPING
   (TABLE_NAME, REF_COL_NAME, DESC_COL_NAME, IS_CONCAT_STRING, IS_ADDITIONAL_CONDITION_APP, 
    DISPLAY_ORDER_COL_NAME)
 Values
   ('BTM_BUSINESS_TYPE_MASTER', 'BUSINESS_TYPE_ID', 'BUSINESS_TYPE', 'N', 'Y', 
    NULL)
/

Insert into RCDMADC_RCDM_ADDITIONAL_COND
   (TABLE_NAME, COLUMN_NAME, COLUMN_TYPE)
 Values
   ('BTM_BUSINESS_TYPE_MASTER', 'GROUP_ID', 'GROUPID')
/

Insert into DCM_DELEE_CONDITION_MAPPING
   (TABLE_NAME, CONDITION_ID, TABLE_DESC, RETREIVE_CONDITION_REQ)
 Values
   ('BTM_BUSINESS_TYPE_MASTER', 'GEN-2', 'Buisiness Type Master', 'Y')
/

alter table AMC_APP_MENU_CONFIGURATION modify MENU_ID VARCHAR2 (50 Char)
/

alter table AMC_APP_MENU_CONFIGURATION modify MENU_PARENT_ID VARCHAR2 (50 Char)
/
commit;