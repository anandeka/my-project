delete from SEA_SEARCH_ENTITY_ATTRIBUTE;
delete from SE_SEARCH_ENTITY;

Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-1', 'Contract', '/metals/loadListOfContracts.action?gridId=PHY_LOC&retainFilterValue=Y');
Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-2', 'Contract Items', '/metals/loadListOfContractItem.action?gridId=LOCI&retainFilterValue=Y');
Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-3', 'Allocations', '/metals/commonListing.do?method=getCommonListingPage&gridId=LOA&retainFilterValue=Y');
Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-4', 'Stocks', '/metals/listingOfStocks.do?method=loadListOfStocks&gridId=LOS&retainFilterValue=Y');
Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-5', 'Invoices', '/metals/loadListOfInvoice.action?gridId=LOII_TEST&retainFilterValue=Y');
Insert into SE_SEARCH_ENTITY
   (SE_ID, SEARCH_ENTITY_NAME, LINK_URL)
 Values
   ('SE-6', 'Movements', '/metals/listingOfGMR.do?method=loadListOfGMR&gridId=LOG&retainFilterValue=Y');

Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-1', 'SE-1', 'contractRefNo={#}', 'Contract Ref No', NULL, 
    NULL);
Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-2', 'SE-1', 'cpContractRefNo={#}', 'CP Contract Ref No', NULL, 
    NULL);
Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-5', 'SE-1', 'cpId={#}', 'CP Name', NULL, 
    '{serviceKey:"corporatebusinesspartner",isStatic:"No",attributeOne:"BUYER,SELLER"}');
Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-7', 'SE-1', 'contractIssueFromDate={#}&contractIssueToDate={#}', 'Contract Issue Date', NULL, 
    NULL);
    
    
    
Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-4', 'SE-2', 'refNoType=contractItemRefNo&refNo={#}', 'Item Ref No', NULL, 
    NULL);



Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-16', 'SE-3', 'allocationSearchCriteria=AllocationGroupNo&searchAllocationTextBox={#}', 'Allocation Group No.', NULL, 
    NULL);



Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-15', 'SE-4', 'baleSearchCriteria=StockRefNo&searchTextBox={#}', 'Stocks Ref. No.', NULL, 
    NULL);



Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-6', 'SE-6', 'gmrSearchCriteria=GMR%20Ref%20No&searchTextBox={#}', 'GMR Ref. No.', NULL, 
    NULL);
Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-8', 'SE-6', 'gmrSearchCriteria=B/L%20No&searchTextBox={#}', 'B/L No.', NULL, 
    NULL);
Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-9', 'SE-6', 'gmrSearchCriteria=Warehouse/Cargo%20Receipt%20No&searchTextBox={#}', 'Delivery Receipt. No.', NULL, 
    NULL);


Insert into SEA_SEARCH_ENTITY_ATTRIBUTE
   (SEA_ID, SE_ID, SEA_NAME, DEAULT_DISPLAY_NAME, EXAMPLE_STRING, 
    TAG_CONFIG)
 Values
   ('SEA-13', 'SE-5', 'invoiceRefNo={#}', 'Invoice No.', NULL, 
    NULL);

commit;

