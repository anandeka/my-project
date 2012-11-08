set define off;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RM_CORRECTION', 'In-Process Adjustment', 18, 4, '/metals/loadMiningRMCTabs.action?tabId=viewReceiveMaterialCorrection&moduleId=receiveMaterialCorrection&tollingType=Receive Material Correction&is_Fresh_Load=Y', 
    NULL, 'TOL-M1.2.2', 'APP-ACL-N1400', 'Tolling', 'APP-PFL-N-224', 
    'N');
set define on;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SLS/SLV Script for ActivityType Filter in List Of Tolling Input/Output GMR
-------------------------------------------------------------------------------------------------------------
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('IN_PROCESS_ADJUSTMENT', 'In Process Adjustment');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('TollingInputOutputActivity', 'MARK_FOR_TOLLING', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('TollingInputOutputActivity', 'RECORD_OUT_PUT_TOLLING', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('TollingInputOutputActivity', 'IN_PROCESS_ADJUSTMENT', 'N', 4);


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 VALUES
   ('IPARefNo', 'In-Process Adjustment Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('IN_PROCESS_ADJUSTMENT', 'GMR Tolling ', 'In Process Adjustment', 'Y', 'In Process Adjustment','N', NULL);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 VALUES
   ('IN_PROCESS_ADJUSTMENT', 'N', 'N', 'activityDate', 'N', NULL, NULL, 'N', 'N');
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('IN_PROCESS_ADJUSTMENT_CANCEL', 'GMR Tolling ', 'In Process Adjustment Cancel', 'Y', 'In Process Adjustment Cancel','N', NULL);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 VALUES
   ('IN_PROCESS_ADJUSTMENT_CANCEL', 'N', 'N', 'activityDate', 'N', NULL, NULL, 'N', 'N');