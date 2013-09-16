SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D376', 'Arrival Report-All Elements', 104, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=376&ReportName=MonthlyArrivalReport_Elements.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D377', 'Feed Consumption Report-All Elements', 105, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=377&ReportName=MonthlyFeedConsumptionReport_Elements.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');


Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('376', '31', 'MonthlyArrivalReport_Elements.rpt', 'Arrival Report-All Elements', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');


Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('377', '31', 'MonthlyFeedConsumptionReport_Elements.rpt', 'Feed Consumption Report-All Elements', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');
COMMIT;
