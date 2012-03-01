SET DEFINE OFF;

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D330', 'Daily Overall Realized Physical Pnl', 20, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=67&ReportName=DailyOverallRealizedPhysicalPnl.rptt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL, 
    'N');

commit;
