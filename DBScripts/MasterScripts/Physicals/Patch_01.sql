
SET DEFINE OFF;

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Mutually Agreed', 'Mutually Agreed');

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listOfTradePriceTypesConc', 'Fixed', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listOfTradePriceTypesConc', 'Formula', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listOfTradePriceTypesConc', 'Index', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listOfTradePriceTypesConc', 'Mutually Agreed', 'N', 4);
COMMIT;



update GMC_GRID_MENU_CONFIGURATION set LINK_CALLED = 'function(){modifyContract();}'
where MENU_ID= 'LOC_1_2';


  SET DEFINE OFF;
 update AMC_APP_MENU_CONFIGURATION set LINK_CALLED = '/metals/loadContractForCreation.action?tabId=general&contractType=S&productGroupType=BASEMETAL&actionType=current' where MENU_ID = 'P32';

 update AMC_APP_MENU_CONFIGURATION set LINK_CALLED = '/metals/loadContractForCreation.action?tabId=general&contractType=P&productGroupType=BASEMETAL&actionType=current' where MENU_ID = 'P22';

 
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('MODIFY_PC', 'Contract', 'Modify Purchase Contract', 'N', 'Purchase Contract modified', 
    'N');
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('MODIFY_SC', 'Contract', 'Modify Sales Contract', 'N', 'Sales Contract modified', 
    'N');


