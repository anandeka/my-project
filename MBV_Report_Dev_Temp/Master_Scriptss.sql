SET DEFINE OFF;

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('370', '31', 'PhysicalPositionReport.rpt', 'Physical Position Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('370', 'EXCEL', 'PhysicalPositionReport_Excel.rpt');    

-------------------------------------------------------------------------------------------------------------------------------------------------------

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('372', '31', 'PhysicalDiffReport.rpt', 'Physical Diff Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('372', 'EXCEL', 'PhysicalDiffReport_Excel.rpt');    

------------------------------------------------------------------------------------------------------------------------------------------------------------

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('369', '31', 'DerivativeDiffReport.rpt', 'Derivative Diff. Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('369', 'EXCEL', 'DerivativeDiffReportExcel.rpt');    

-------------------------------------------------------------------------------------------------------------------------------------------------------------
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('371', '31', 'AllocationReport.rpt', 'Allocation Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('371', 'EXCEL', 'AllocationReportExcel.rpt');    

COMMIT;

/*
Metal Balance Valuation Report related Master Script...       
*/

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('373', '31', 'MetalBalanceValuationReport.rpt', 'Metal Balance Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('373', 'EXCEL', 'MetalBalanceValuationReport.rpt');    


commit;