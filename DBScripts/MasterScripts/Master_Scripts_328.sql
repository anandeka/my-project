delete from sls_static_list_setup sls where sls.list_type in ('reportList','ReportDataList');
delete from slv_static_list_value slv where slv.value_id in ('Detailed','Summarized','YTD');
delete from rpc_rf_parameter_config rpc where rpc.report_id = 255;
delete from rfc_report_filter_config rfc where rfc.report_id = 255;
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D255';
delete from rml_report_master_list rml where rml.report_id = 255;
commit;
SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Summarized', 'Summarized');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Detailed', 'Detailed');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('YTD', 'YTD');
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('reportList', 'Detailed', 'Y', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('reportList', 'Summarized', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ReportDataList', 'YTD', 'Y', 1);
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('255', '31', 'MonthlyArrivalReport.rpt', 'Arrival Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');
COMMIT;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D255', 'Stock Recon Report', 22, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=255&ReportName=MonthlyArrivalReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
COMMIT;
