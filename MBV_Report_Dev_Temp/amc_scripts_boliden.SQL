SET DEFINE OFF;

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D370', 'Physical Position Report', 98, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=370&ReportName=PhysicalPositionReport.rpt&ExportFormat=HTML', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');
-------------------------------------------------------------------------------------------------------------------------------------------------------

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D372', 'Physical Diff Report', 100, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=372&ReportName=PhysicalDiffReport.rpt&ExportFormat=HTML', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');
------------------------------------------------------------------------------------------------------------------------------------------------------------

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D369', 'Derivative Diff. Report', 97, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=369&ReportName=DerivativeDiffReport.rpt&ExportFormat=HTML&isEodReport=Y', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');
-------------------------------------------------------------------------------------------------------------------------------------------------------------

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D371', 'Allocation Report', 99, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=371&ReportName=AllocationReport.rpt&ExportFormat=HTML&isEodReport=Y', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');
  
COMMIT;

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D373', 'Metal Balance Valuation Report', 101, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=373&ReportName=MetalBalanceValuationReport.rpt&ExportFormat=HTML', 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 'N');

commit;