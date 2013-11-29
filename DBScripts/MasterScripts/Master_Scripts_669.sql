 update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME='Monthly TC/RC/Other Charges Summary Report' where AMC.MENU_ID='RPT-D390';
 update AMC_APP_MENU_CONFIGURATION amc set AMC.MENU_DISPLAY_NAME='Monthly TC/RC/Other Charges Detailed Report' where AMC.MENU_ID='RPT-D391';
 commit;