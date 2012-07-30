SET DEFINE OFF;

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('positionAssay', 'Position Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('wtAvgPositionAssay', 'Weighted Avg Position Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('pricingAssay', 'Pricing Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('wtAvgPricingAssay', 'Weighted Avg Pricing Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('invoicingAssay', 'Invoicing Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('wtAvgInvoicingAssay','Weighted Avg Invoice Assay');

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'Self', 'N', 1);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'Counterparty', 'N', 2);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'Umpire', 'N', 3);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'Final', 'N', 4);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'ProvisionalAssay', 'N', 5);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'WSAssay', 'N', 6);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'positionAssay', 'N', 7);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'wtAvgPositionAssay', 'N', 8);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'pricingAssay', 'N', 9);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'wtAvgPricingAssay', 'N', 10);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'invoicingAssay', 'N', 11);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'wtAvgInvoicingAssay', 'N', 12);
   

