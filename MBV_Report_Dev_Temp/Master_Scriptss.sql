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

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D370', 'Physical Position Report', 98, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=370&ReportName=PhysicalPositionReport.rpt&ExportFormat=HTML', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');
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

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D372', 'Physical Diff Report', 100, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=372&ReportName=PhysicalDiffReport.rpt&ExportFormat=HTML', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');
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

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D369', 'Derivative Diff. Report', 97, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=369&ReportName=DerivativeDiffReport.rpt&ExportFormat=HTML&isEodReport=Y', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');
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

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D371', 'Allocation Report', 99, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=371&ReportName=AllocationReport.rpt&ExportFormat=HTML&isEodReport=Y', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');
  
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

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D373', 'Metal Balance Valuation Report', 101, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=373&ReportName=MetalBalanceValuationReport.rpt&ExportFormat=HTML', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');

commit;