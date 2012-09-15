
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('anydayspot', 'Any Day Spot');

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('anyday', 'Any Day ');
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('average', 'Average');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('pricefixationtype', 'anydayspot', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('pricefixationtype', 'anyday', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('pricefixationtype', 'average', 'N', 2);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('SearchRefForFixation', 'GMRRefNo', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('SearchRefForFixation', 'contractRefNo', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('SearchRefForFixation', 'deliveryItemRefNo', 'N', 3);


Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('OverAllocated', 'Over Allocated');

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('PartiallyAllocated', 'Partially Allocated');
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('FullyAllocated', 'Fully Allocated');
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('unAllocated', 'UnAllocated');
  
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('hedgeallocation', 'OverAllocated', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('hedgeallocation', 'PartiallyAllocated', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('hedgeallocation', 'FullyAllocated', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('hedgeallocation', 'unAllocated', 'N', 4);







Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_PRICE_FINALIZATION', 'Physical ', 'CreatePriceFinlization', 'N', 'CreatePriceFinlization', 
    'N', NULL);
    
    
    Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_PRICE_FINALIZATION', 'Physical ', 'CancelPriceFinlization', 'N', 'CancelPriceFinlization', 
    'N', NULL);





