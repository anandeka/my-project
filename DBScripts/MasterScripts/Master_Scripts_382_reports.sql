delete from RPC_RF_PARAMETER_CONFIG rpc where rpc.REPORT_ID = '360';
delete from RFC_REPORT_FILTER_CONFIG rfc where rfc.REPORT_ID = '360';
delete from AMC_APP_MENU_CONFIGURATION amc where amc.MENU_ID = 'RPT-D360';
delete from ref_reportexportformat where REPORT_ID = '360';
delete from RML_REPORT_MASTER_LIST rml where RML.REPORT_ID = '360';
commit;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('360', '21', 'TradersPositionReport.rpt', 'Traders Position Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');

insert into ref_reportexportformat
  (report_id, export_format, report_file_name)
values
  ('360', 'EXCEL', 'TradersPositionReport.rpt');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D360', 'Traders Position Report', 25, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=360&ReportName=TradersPositionReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D22', '', 'Reports', '', 
    'N');
commit;