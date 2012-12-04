 delete from REF_REPORTEXPORTFORMAT ref where REF.REPORT_ID=227;
 Commit;
 
 SET DEFINE OFF;
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('227', 'EXCEL', 'MonthlyInventoryUnrealizedPhysicalPnL_cog_Excel.rpt');
COMMIT;
