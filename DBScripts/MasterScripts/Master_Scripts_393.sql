delete from REF_REPORTEXPORTFORMAT ref where Ref.REPORT_ID in ( '361','362','363');
delete from RPC_RF_PARAMETER_CONFIG rpc 
where RPC.REPORT_ID in ( '361','362','363');
delete from RFC_REPORT_FILTER_CONFIG rfc where RFC.REPORT_ID in ( '361','362','363');
delete from RML_REPORT_MASTER_LIST rml where RML.REPORT_ID in ( '361','362','363');
delete from AMC_APP_MENU_CONFIGURATION amc where AMC.MENU_ID in ('RPT-D361','RPT-D362','RPT-D363');
delete from RPC_RF_PARAMETER_CONFIG rpc 
where RPC.REPORT_ID in ( '361','362','363');

commit;

SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('361', '41', 'PromptListByDate.rpt', 'Prompt List By Date/Month', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('363', '41', 'BrokerList.rpt', 'Broker List', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('362', '11', 'DeliveryScheduleReport.rpt', 'Delivery Schedule Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D361', 'Prompt List By Date/Month', 13, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=361&ReportName=PromptListByDate.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D41', 'APP-ACL-N1309', 'Reports', 'APP-PFL-N-213', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D363', 'Broker List', 14, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=363&ReportName=BrokerList.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D41', NULL, 'Reports', NULL, 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D362', 'Delivery Schedule Report', 31, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=362&ReportName=DeliveryScheduleReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL, 
    'N');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
Values
   ('362', 'EXCEL', 'DeliveryScheduleReport.rpt');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
Values
   ('361', 'EXCEL', 'PromptListByDate.rpt');

Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
Values
   ('363', 'EXCEL', 'BrokerList.rpt');

COMMIT;
