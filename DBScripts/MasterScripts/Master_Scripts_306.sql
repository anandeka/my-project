delete from sls_static_list_setup sls where sls.list_type = 'GroupList';
delete from slv_static_list_value slv where slv.value_id in ('Group','UnGroup');
delete from ref_reportexportformat where report_id = '252';
delete from rpc_rf_parameter_config rpc where rpc.report_id = '252';
delete from rfc_report_filter_config rfc where rfc.report_id = '252';
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D2496';
delete from rml_report_master_list rml where rml.report_id = '252';
commit;
SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Group', 'Group');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('UnGroup', 'UnGroup');
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('GroupList', 'UnGroup', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('GroupList', 'Group', 'N', 2);
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('252', '11', 'GlobalPositionReport.rpt', 'Global Position Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('252', 'EXCEL', 'GlobalPositionReport.rpt');
COMMIT;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D2496', 'Global Position Report', 32, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=252&ReportName=GlobalPositionReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL, 
    'N');
COMMIT;
