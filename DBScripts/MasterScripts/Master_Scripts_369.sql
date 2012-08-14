delete from REF_REPORTEXPORTFORMAT ref where REF.REPORT_ID = '240';
commit;
SET DEFINE OFF;
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('240', 'EXCEL', 'IntrastatReport.rpt');
COMMIT;
