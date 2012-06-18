set define off;
update RML_REPORT_MASTER_LIST rml  set RML.IS_ACTIVE = 'Y' where RML.REPORT_ID in ( '213','216');

update rml_report_master_list rml set RML.REPORT_FILE_NAME = 'DailyOpenUnrealizedPhysicalConc_Cog.rpt' where RML.REPORT_ID = '213';

update RML_REPORT_MASTER_LIST rml set RML.REPORT_FILE_NAME = 'DailyInventoryUnrealizedPhysicalPnLConc_Cog.rpt' where RML.REPORT_ID = '216';

update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME = 'Daily Open Unrealized Physical P&L (Conc)' , AMC.LINK_CALLED = 
             '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=213&ReportName=DailyOpenUnrealizedPhysicalConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y',AMC.IS_DELETED = 'N'
             where AMC.MENU_ID = 'RPT-D224';
             
update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME = 'Daily Inventory Unrealized Physical P&L (Conc)' , AMC.LINK_CALLED = 
             '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=216&ReportName=DailyInventoryUnrealizedPhysicalPnLConc_Cog.rpt&ExportFormat=HTML&isEodReport=Y' ,AMC.IS_DELETED = 'N'
             where AMC.MENU_ID = 'RPT-D225';             

Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('253', '21', 'DailyRealizedPNLReportConc_Cog.rpt', 'Daily Realized PNL Report Conc_Cog', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');

SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D253', 'Daily Realized PNL Report P&L (Conc)', 23, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=249&ReportName=DailyRealizedPNLReportConc_Cog.rpt.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', 'APP-ACL-N1296', 'Reports', 'APP-PFL-N-214', 
    'N');
