Delete from REF_REPORTEXPORTFORMAT ref where REF.REPORT_ID in ('213','216','250');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('216', 'EXCEL', 'DailyInventoryUnrealizedPhysicalPnLConc_Cog_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('213', 'EXCEL', 'DailyOpenUnrealizedPhysicalConc_Cog_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('253', 'EXCEL', 'DailyRealizedPNLReportConc_Cog_Excel.rpt');

