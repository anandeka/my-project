SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('84', '21', 'DailyOpenUnrealizedPhysicalPnl_Cog.rpt', 'Daily Open Unrealized Physical P&L (Cog)-BM', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('85', '21', 'DailyRealizedPNLReport.rpt', 'Daily Realized Physical PNL', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('86', '21', 'DailyInventoryUnrealizedPhysicalPnL_cog.rpt', 'Daily Inventory Unrealized PnL(Cog)-BM', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('65', '21', 'TradePnLReport.rpt', 'Trade PnL Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');    
    


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D226', 'Daily Open Unrealized Physical P&L (Cog)-BM', 16, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=84&ReportName=DailyOpenUnrealizedPhysicalPnl_Cog.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL);

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D227', 'Daily Realized Physical PNL', 18, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=85&ReportName=DailyRealizedPNLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL);
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D228', 'Daily Inventory Unrealized PnL(Cog)-BM', 17, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=86&ReportName=DailyInventoryUnrealizedPhysicalPnL_cog.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL);    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D229', 'Trade P&L Report', 19, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=65&ReportName=TradePnLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL);
    
COMMIT;    