delete from ref_reportexportformat rf where rf.report_id = 248;
commit;
SET DEFINE OFF;
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('248', 'EXCEL', 'MonthlyCustomsReport_Excel.rpt');
COMMIT;
