delete from ref_reportexportformat where report_id = '234';
delete from amc_app_menu_configuration where menu_id = 'RPT-D214';
delete from rpc_rf_parameter_config where report_id = '234';
delete from rfc_report_filter_config where report_id = '234';
delete from rml_report_master_list where report_id = '234';
commit;
update RPC_RF_PARAMETER_CONFIG
set REPORT_PARAMETER_NAME = 'ProfitCenter'
where report_id in ('211','212')
and parameter_id = 'RFP1046'
and label_id in ('RFC211PHY02','RFC212PHY02');
commit;

SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('234', '11', 'PositionDeliveryPricingDerivative.rpt', 'Position Delivery Pricing Derivative Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('RPT-D214', 'Position - Delivery Pricing Derivative', 13, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=234&ReportName=PositionDeliveryPricingDerivative.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL);
 Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('234', 'EXCEL', 'PositionDeliveryPricingDerivative_Excel.rpt');
COMMIT;
