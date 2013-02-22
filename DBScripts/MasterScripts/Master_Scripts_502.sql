Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('236', 'EXCEL', 'PurchaseAccrualReport_Excel.rpt');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('247', 'EXCEL', 'MetalBalanceSummaryReport_Excel.rpt');

UPDATE AMC_APP_MENU_CONFIGURATION
SET IS_DELETED = 'Y'
where  MENU_ID IN('RPT-D237','RPT-D215');

Commit;