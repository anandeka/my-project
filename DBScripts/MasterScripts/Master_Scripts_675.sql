SET DEFINE OFF;

Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-7', 'Tolling Contract', '/metals/loadListOfMiningContracts.action?gridId=MIN_LOC&retainFilterValue=Y');


Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-17', 'SE-7', 'contractRefNo={#}', 'Contract Ref No', NULL, 
    NULL);


Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-18', 'SE-7', 'cpId={#}', 'CP Name', NULL, 
    '{serviceKey:"corporatebusinesspartner",isStatic:"No",attributeOne:"BUYER,SELLER"}');
    

Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-20', 'SE-7', 'contractIssueFromDate={#}&contractIssueToDate={#}', 'Contract Issue Date', NULL, 
    NULL);


Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-8', 'Tolling Movements', '/metals/loadListOfMiningTollingGMR.action?gridId=MTGMR_LIST&retainFilterValue=Y');


Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-19', 'SE-8', 'gmrRefNo={#}', 'GMR Ref. No.', NULL, 
    NULL);
    

Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-9', 'Tolling Contract Items', '/metals/loadListOfMiningContractItem.action?gridId=MLOCI&retainFilterValue=Y');


Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-21', 'SE-9', 'refNoType=contractItemRefNo&refNo={#}', 'Item Ref.No.', NULL, 
    NULL);
 
Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-10', 'Delivery Items', '/metals/loadListOfDeliveryItems.action?gridId=LODI&retainFilterValue=Y');


Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-22', 'SE-10', 'refNoType=contractRefNo&refNo={#}', 'Contract Ref No.', NULL, 
    NULL);
    
Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-23', 'SE-10', 'refNoType=deliveryItemRefNo&refNo={#}', 'Delivery Item Ref No.', NULL, 
    NULL);
    
Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-11', 'Tolling Delivery Items', '/metals/loadListOfMiningDeliveryItems.action?gridId=MLODI&retainFilterValue=Y');  

Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-24', 'SE-11', 'refNoType=contractRefNo&refNo={#}', 'Contract Ref No.', NULL, 
    NULL);
    
Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-25', 'SE-11', 'refNoType=deliveryItemRefNo&refNo={#}', 'Delivery Item Ref No.', NULL, 
    NULL);
    
COMMIT;
