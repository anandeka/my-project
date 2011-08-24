SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('216', '21', 'DailyInventoryUnrealizedPhysicalPnLConc.rpt', 'Daily Inventory Unrealized Physical P&L(Concentrate)', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D225', 'Daily Inventory Unrealized Physical P&L(Concentrate)', 15, 4, '/mdm/CommonFilter.do?method=populateJRCReport&docType=EOD&ReportID=216&ReportName=DailyInventoryUnrealizedPhysicalPnLConc.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL);
Insert into RPD_REPORT_PARAMETER_DATA
   (CORPORATE_ID, REPORT_ID, REPORT_PARAMETER_NAME, REPORT_PARAM_ID)
 Values
   ('EKA', '216', 'AsOfDate', 'RPQ-003');
Insert into RPD_REPORT_PARAMETER_DATA
   (CORPORATE_ID, REPORT_ID, REPORT_PARAMETER_NAME, REPORT_PARAM_ID)
 Values
   ('LDE', '216', 'AsOfDate', 'RPQ-003');
COMMIT;
