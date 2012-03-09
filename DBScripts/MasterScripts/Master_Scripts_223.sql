delete from rpc_rf_parameter_config rpc where rpc.report_id = '244';
delete from rfc_report_filter_config rfc where rfc.report_id = '244';
delete from rml_report_master_list rml where rml.report_id = '244';
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D2115';
commit;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('244', '11', 'DeltaPricingReport.rpt', 'Delta Pricing Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D2115', 'Delta Pricing Report', 27, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=244&ReportName=DeltaPricingReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL, 
    'N');
COMMIT;
