DELETE FROM rpc_rf_parameter_config
      WHERE REPORT_ID in('239','240','241','242','243');
DELETE FROM rfc_report_filter_config
      WHERE REPORT_ID in('239','240','241','242','243');
DELETE FROM rml_report_master_list
      WHERE REPORT_ID in('239','240','241','242','243');
DELETE FROM amc_app_menu_configuration
      WHERE menu_id IN ('RPT-D2221', 'RPT-D237', 'RPT-D238', 'RPT-D2114', 'RPT-D236');
COMMIT;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('241', '31', 'FeedConsumptionReport.rpt', 'Feed Consumption Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('242', '31', 'YTDMTDYIELD.rpt', 'YTD MTD YIELD Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('243', '21', 'ContractStatusReport.rpt', 'Contract Status Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('239', '11', 'CustomsReport.rpt', 'Customs Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('240', '31', 'IntrastatReport.rpt', 'Intrastat Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D2221', 'Contract Status Report', 21, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=243&ReportName=ContractStatusReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL);
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D237', 'Feed Consumption Report', 18, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=241&ReportName=FeedConsumptionReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL);
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D238', 'YTD MTD Yield Report', 17, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=242&ReportName=YTDMTDYIELD.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL);
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D2114', 'Customs Report', 26, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=239&ReportName=CustomsReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL);
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D236', 'Intrastat Report', 16, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=240&ReportName=IntrastatReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL);
COMMIT;

