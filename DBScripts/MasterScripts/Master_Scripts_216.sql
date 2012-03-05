delete from AMC_APP_MENU_CONFIGURATION amc
where amc.menu_id = 'BI-15';
Commit;

SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('BI-15', 'Hedged UnHedged Position', 10, 2, '/ekaBI/biSpecificAction.do?method=getBIPage&URL_PROPERTY=HUHURL', 
    NULL, 'BI-1', 'APP-ACL-N898', 'Analytics', 'APP-PFL-N-161', 
    'N');
COMMIT;
