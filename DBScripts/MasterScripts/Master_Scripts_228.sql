delete from rpc_rf_parameter_config rpc where rpc.report_id = '245';
delete from rfc_report_filter_config rfc where rfc.report_id = '245';
delete from rml_report_master_list rml where rml.report_id = '245';
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D2116';
commit;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('245', '11', 'YearlyProjectionReport.rpt', 'Yearly Projection Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D2116', 'Yearly Projection Report', 28, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=245&ReportName=YearlyProjectionReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL, 
    'N');
COMMIT;
