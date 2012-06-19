Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('LOFMU', 'List Of Free Metal Utility', 10, 3, '/metals/loadListOfFreeMetalUtility.action?gridId=LOFM_UTILITY', 
    NULL, 'F2', 'APP-ACL-N1085', 'Finance', 'APP-PFL-N-187', 
    'N');

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOFM_UTILITY', 'List Of Free Metal Utility', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"freeMetalUtilityRefNo","header":"Free Metal Utility Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"cpName","header":"Smelter","id":2,"sortable":true,"width":150},{"header":"Free Metal","id":3,"sortable":false,"width":150},{"dataIndex":"qpMonthYear","header":"QP Pricing","id":4,"sortable":false,"width":150},{"dataIndex":"yearMonthOfConsumption","header":"Consumption Month/Year","id":5,"sortable":true,"width":150},{"dataIndex":"runBy","header":"Run By","id":6,"sortable":true,"width":150},{"dataIndex":"runOn","header":"Run On","id":7,"sortable":true,"width":150},{"dataIndex":"status","header":"Status","id":8,"sortable":true,"width":150}]', 'Finance', '/metals/loadListOfFreeMetalUtility.action', 
    '[ {name : ''utilityHeaderId'',mapping : ''utilityHeaderId''}, 
  {name : ''freeMetalUtilityRefNo'',mapping : ''freeMetalUtilityRefNo''},
  {name : ''cpName'',mapping : ''cpName''},
  {name : ''qpMonthYear'',mapping : ''qpMonthYear''},
  {name : ''yearMonthOfConsumption'',mapping : ''yearMonthOfConsumption''},
  {name : ''runBy'',mapping : ''runBy''},
  {name : ''runOn'',mapping : ''runOn''},
  {name : ''status'',mapping : ''status''} ]', NULL, '/private/jsp/mining/physical/pricing/freemetalpricing/listOfFreeMetalUtility.jsp', '/private/js/mining/physical/pricing/freemetalpricing/listOfFreeMetalUtility.js');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOFMU_1', 'LOFM_UTILITY', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOFMU_4', 'LOFM_UTILITY', 'Roll Back', 3, 2, 
    'APP-PFL-N-187', 'function(){runRollBack();}', NULL, 'LOFMU_1', NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOFMU_2', 'LOFM_UTILITY', 'Run Utility', 1, 2, 
    'APP-PFL-N-187', 'function(){runFreeMetalUtility();}', NULL, 'LOFMU_1', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOFMU_3', 'LOFM_UTILITY', 'Re-run Pricing', 2, 2, 
    'APP-PFL-N-187', 'function(){reRunPricing();}', NULL, 'LOFMU_1', NULL);
