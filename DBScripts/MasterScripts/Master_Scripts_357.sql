delete from ref_reportexportformat ref where ref.report_id = 257;
delete from rpc_rf_parameter_config rpc where rpc.report_id = 257;
delete from rfc_report_filter_config rfc where rfc.report_id = 257;
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D257';
delete from rml_report_master_list rml where rml.report_id = 257;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('257', '31', 'MonthlyClosingBalanceReport.rpt', 'Monthly Closing Balance Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('257', 'EXCEL', 'MonthlyClosingBalanceReport.rpt');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D257', 'Monthly Closing Balance Report', 24, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=257&ReportName=MonthlyClosingBalanceReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
COMMIT;


