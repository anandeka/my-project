
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listOfTollingPriceTypes', 'Formula', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listOfTollingPriceTypes', 'Index', 'N', 2);



update GMC_GRID_MENU_CONFIGURATION
set GMC_GRID_MENU_CONFIGURATION.LINK_CALLED='function(){loadMFTGmrDataforPriceAllocation();}'
where GMC_GRID_MENU_CONFIGURATION.MENU_ID='MTGMR_LIST_5';


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MTGMR_LIST_6', 'MTGMR_LIST', 'Speed Pricing', 6, 2, 
    NULL, 'function(){loadMFTGmrDataforSpeedPricing();}', NULL, 'MTGMR_LIST_1', NULL);