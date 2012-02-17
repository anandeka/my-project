delete from rpc_rf_parameter_config rpc where rpc.report_id in ('235','236','237','238');
delete from rfc_report_filter_config rfc where rfc.report_id in ('235','236','237','238');
delete from amc_app_menu_configuration amc where amc.menu_id in ('RPT-D235','RPT-D2111','RPT-D2112','RPT-D2113');
delete from rml_report_master_list rml where report_id in ('235','236','237','238');
commit;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('236', '31', 'PurchaseAccrualReport.rpt', 'Purchase Accrual Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('235', '11', 'UnpricedQuantityReport.rpt', 'Unpriced Quantity Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('237', '11', 'ArrivalReport.rpt', 'Arrival Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('238', '11', 'ContractedVsDeliveredReport.rpt', 'Contracted Vs Delivered Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
COMMIT;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D235', 'Purchase Accrual Report', 15, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=236&ReportName=PurchaseAccrualReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL);
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D2112', 'Arrival Report', 24, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=237&ReportName=ArrivalReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL);
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D2113', 'Contracted Vs Delivered Report', 25, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=238&ReportName=ContractedVsDeliveredReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL);
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D2111', 'Unpriced Quantity Report', 23, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=235&ReportName=UnpricedQuantityReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL);
COMMIT;
