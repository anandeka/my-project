Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('MODIFY_PURCHASE_TOLL_SERVICE', 'Tolling ', 'Modify Purchase Tolling Service', 'N', 'Modify Purchase Tolling Service', 
    'Y');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('MODIFY_SALES_TOLL_SERVICE', 'Tolling ', 'Modify Sales Tolling Service', 'N', 'Modify Sales Tolling Service', 
    'Y');
    
    
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('AMEND_PURCHASE_TOLL_SERVICE', 'Tolling ', 'Amend Purchase Tolling Service', 'N', 'Amend Purchase Tolling Service', 
    'Y');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('AMEND_SALES_TOLL_SERVICE', 'Tolling ', 'Amend Sales Tolling Service', 'N', 'Amend Sales Tolling Service', 
    'Y');


UPDATE amc_app_menu_configuration amc
   SET amc.link_called =
          '/metals/loadMiningContractForCreation.action?method=loadMiningContractForCreation&tabId=general&contractType=P&productGroupType=CONCENTRATES&actionType=current&moduleId=miningContract'
 WHERE amc.menu_id = 'TOL-M6_M2';
