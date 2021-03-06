SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('215', '11', 'PriceExposureReport.rpt', 'Price Exposure Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D218', 'Price Exposure Report', 18, 4, '/mdm/CommonFilter.do?method=populateJRCReport&docType=ONLINE&ReportID=215&ReportName=PriceExposureReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL);
COMMIT;
