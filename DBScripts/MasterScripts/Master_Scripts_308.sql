set define off;
UPDATE RML_REPORT_MASTER_LIST rml set RML.REPORT_display_NAME = 'Monthly Open Unrealized Physical Conc Cog' , RML.REPORT_FILE_NAME = 'MonthlyOpenUnrealizedPhysicalConc_Cog.rpt' 
 where RML.REPORT_ID = '226';
 
 
UPDATE RML_REPORT_MASTER_LIST rml set RML.REPORT_display_NAME = 'Monthly Inventory Unrealized Physical PnL Conc Cog' , RML.REPORT_FILE_NAME = 'MonthlyInventoryUnrealizedPhysicalPnLConc_Cog.rpt' 
 where RML.REPORT_ID = '228';
 
DELETE FROM AMC_APP_MENU_CONFIGURATION amc
  where AMC.MENU_ID = 'RPT-D232';
  
DELETE FROM AMC_APP_MENU_CONFIGURATION amc
  where AMC.MENU_ID = 'RPT-D234';
  
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D232', 'Monthly Open Unrealized Physical Conc Cog', 12, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=226&ReportName=MonthlyOpenUnrealizedPhysicalConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y', 'RPT-D23', 'APP-ACL-N1302', 'Reports', 'APP-PFL-N-215', 'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, IS_DELETED)
 Values
   ('RPT-D234', 'Monthly Inventory Unrealized Physical PnL Conc Cog', 14, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=228&ReportName=MonthlyInventoryUnrealizedPhysicalPnLConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y', 'RPT-D23', 'APP-ACL-N1304', 'Reports', 'APP-PFL-N-215', 'N');

-- update AMC_APP_MENU_CONFIGURATION amc set AMC.DISPLAY_SEQ_NO = '21' where AMC.MENU_ID = 'RPT-D235';
 
  
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('254', '31', 'MonthlyRealizedPNLReportConc_Cog.rpt', 'Monthly Realized PNL Report Conc Cog', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D254', 'Monthly Realized PNL Report Conc Cog',21, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=250&ReportName=MonthlyRealizedPNLReportConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', 'APP-ACL-N1304', 'Reports', 'APP-PFL-N-215', 
    'N');

COMMIT;