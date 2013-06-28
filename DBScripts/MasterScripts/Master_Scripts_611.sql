SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D375', 'FX Allocation Report', 103, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=375&ReportName=FXAllocationReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D24', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 
    'N');

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('375', '31', 'FXAllocationReport.rpt', 'FX Allocation Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('375', 'EXCEL', 'FXAllocationReport_Excel.rpt');

COMMIT;


