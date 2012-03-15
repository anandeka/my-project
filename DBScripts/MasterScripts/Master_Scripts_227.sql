UPDATE rfc_report_filter_config rfc
   SET rfc.is_mandatory = 'N'
 WHERE rfc.REPORT_ID = '235'
 AND rfc.LABEL_ID = 'RFC235PHY02';
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('235', 'EXCEL', 'UnpricedQuantityReport_Excel.rpt');
COMMIT;