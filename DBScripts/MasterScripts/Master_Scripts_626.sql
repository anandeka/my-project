update RML_REPORT_MASTER_LIST rml set RML.REPORT_DISPLAY_NAME='Traders Card Report' where RML.REPORT_ID=210;
update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME='Traders Card Report' where AMC.MENU_ID='RPT-D412';
COMMIT;