
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RM-MINES', 'Receive Material from Mines', 7, 2, '/metals/loadMiningTollingTabs.action?tabId=MinesReceiveMaterial&moduleId=receiveMaterialFromMines&tollingType=Mines Receive Material', 
    NULL, 'L1', 'APP-ACL-N1065', 'Tolling', 'APP-PFL-N-184', 
    'N');