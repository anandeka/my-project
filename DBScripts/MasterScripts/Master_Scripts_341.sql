SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('255', '31', 'MonthlyRealizedPNLReport.rpt', 'Monthly Realized PNL Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D255', 'Monthly Realized PNL Report', 22, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=255&ReportName=MonthlyRealizedPNLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', '', 'Reports', '', 
    'N');

