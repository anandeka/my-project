delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D257';
delete from ref_reportexportformat ref where ref.report_id in ('235','255','256');
commit;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D257', 'Monthly Closing Balance Report', 24, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=257&ReportName=MonthlyClosingBalanceReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('235', 'EXCEL', 'UnpricedQuantityReport_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('255', 'EXCEL', 'MonthlyArrivalReport_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('256', 'EXCEL', 'MonthlyFeedConsumptionReport_Excel.rpt');
COMMIT;

