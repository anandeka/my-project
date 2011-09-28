SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('219', '11', 'ProjectedPriceExposure.rpt', 'Projected Price Exposure', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D215', 'Projected Price Exposure', 21, 4, '/mdm/CommonFilter.do?method=populateJRCReport&docType=ONLINE&ReportID=219&ReportName=ProjectedPriceExposure.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL);
Insert into RPD_REPORT_PARAMETER_DATA
   (CORPORATE_ID, REPORT_ID, REPORT_PARAMETER_NAME, REPORT_PARAM_ID)
 Values
   ('LDE', '219', 'AsOfDate', 'RPQ-006');
Insert into RPD_REPORT_PARAMETER_DATA
   (CORPORATE_ID, REPORT_ID, REPORT_PARAMETER_NAME, REPORT_PARAM_ID)
 Values
   ('EKA', '219', 'AsOfDate', 'RPQ-006');
COMMIT;