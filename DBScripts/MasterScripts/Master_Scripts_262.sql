DELETE FROM rpc_rf_parameter_config
      WHERE report_id = '247';
DELETE FROM rfc_report_filter_config
      WHERE report_id = '247';
DELETE FROM rml_report_master_list
      WHERE report_id = '247';
DELETE FROM amc_app_menu_configuration
      WHERE menu_id = 'RPT-D239';
COMMIT;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('247', '31', 'MetalBalanceSummaryReport.rpt', 'Metal Balance Summary Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
COMMIT;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D239', 'Metal Balance Summary Report', 19, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=247&ReportName=MetalBalanceSummaryReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
COMMIT;

