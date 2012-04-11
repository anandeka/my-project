SET DEFINE OFF;
delete from REF_REPORTEXPORTFORMAT ref where REF.REPORT_ID in  (220,237,238,239,244,245,246);
commit;
SET DEFINE OFF;
Insert into REF_REPORTEXPORTFORMAT
    (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
Values
    ('237', 'EXCEL', 'ArrivalReport_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('238', 'EXCEL', 'ContractedVsDeliveredReport_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
    (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
Values
    ('239', 'EXCEL', 'CustomsReport_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
    (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
Values
    ('220', 'EXCEL', 'MonthlyFXExposureReport_Excel.rpt');   
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('244', 'EXCEL', 'DeltaPricingReport_Excel.rpt');     
Insert into REF_REPORTEXPORTFORMAT
    (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
Values
    ('245', 'EXCEL', 'YearlyProjectionReport_Excel.rpt');  
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('246', 'EXCEL', 'PremiumPositionReport_Excel.rpt');     
COMMIT;
