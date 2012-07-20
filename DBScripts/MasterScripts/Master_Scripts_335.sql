SET DEFINE OFF;
delete from AMC_APP_MENU_CONFIGURATION amc where AMC.MENU_ID='RPT-D257';
delete from RPC_RF_PARAMETER_CONFIG rpc where RPC.REPORT_ID='257';
delete from RFC_REPORT_FILTER_CONFIG rfc where RFC.REPORT_ID='257';
delete from REF_REPORTEXPORTFORMAT ref where REF.REPORT_ID in('257','243');
delete from RML_REPORT_MASTER_LIST rml where RML.REPORT_ID ='257';
commit;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('257', '31', 'MonthlyContractStatusReport.rpt', 'Monthly Contract Status Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D257', 'Monthly Contract Status Report', 23, 5, 

'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=257&ReportName=MonthlyContractStatusReport.rp

t&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
commit;