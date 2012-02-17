SET DEFINE OFF;

update AMC_APP_MENU_CONFIGURATION amc set AMC.DISPLAY_SEQ_NO = AMC.DISPLAY_SEQ_NO + 1
where AMC.MENU_PARENT_ID = 'BI-1' and AMC.TAB_ID = 'Analytics';
commit;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('BI-14', 'Physical Position Dashboard', 1, 2, '/metalPhysicalPositionDashboardForwardServlet', 
    NULL, 'BI-1', NULL, 'Analytics', NULL);
COMMIT;
