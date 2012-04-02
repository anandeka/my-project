update RML_REPORT_MASTER_LIST rml
set RML.REPORT_TYPE = 'EOD', RML.SECTION_ID = '21'
where RML.REPORT_ID = '239';
commit;
SET DEFINE OFF;
delete from AMC_APP_MENU_CONFIGURATION amc where AMC.MENU_ID = 'RPT-D2222';
commit;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D2222', 'Customs Report', 22, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=239&ReportName=CustomsReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL, 
    'N');
COMMIT;
delete from RPC_RF_PARAMETER_CONFIG rpc where RPC.REPORT_ID = '248';
delete from RFC_REPORT_FILTER_CONFIG rpc where RPC.REPORT_ID = '248';
delete from RML_REPORT_MASTER_LIST rml where RML.REPORT_ID = '248';
delete from AMC_APP_MENU_CONFIGURATION amc where AMC.MENU_ID = 'RPT-D240';
commit;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('248', '31', 'MonthlyCustomsReport.rpt', 'Monthly Customs Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D240', 'Monthly Customs Report', 20, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=248&ReportName=MonthlyCustomsReport.rpt.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
COMMIT;