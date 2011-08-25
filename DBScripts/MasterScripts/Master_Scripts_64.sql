

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('WandSRef No', 'WandSRef No');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('OurRef No', 'OurRef No');

   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('ExtRef No', 'ExtRef No');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('GMR Activity Ref No', 'GMR Activity Ref No');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfWSAssaySearchCriteria', 'Lot No', 'N', 1);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfWSAssaySearchCriteria', 'WandSRef No', 'N', 2);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfWSAssaySearchCriteria', 'OurRef No', 'N', 3);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfWSAssaySearchCriteria', 'ExtRef No', 'N', 4);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfWSAssaySearchCriteria', 'GMR Ref No', 'N', 5);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfWSAssaySearchCriteria', 'GMR Activity Ref No', 'N', 6);

  Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Contract Item Ref No', 'Contract Item Ref No');
   
  
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfAssaySearchCriteria', 'GMR Activity Ref No', 'N', 1);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfAssaySearchCriteria', 'Contract Ref No', 'N', 2);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfAssaySearchCriteria', 'DeliveryItemRefNo', 'N', 3);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfAssaySearchCriteria', 'Contract Item Ref No', 'N', 4);

   

    Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfAssaySearchCriteria', 'GMR Ref No', 'N', 5);


 Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Self', 'Self');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Counterparty', 'Counterparty');
   
    Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Umpire', 'Umpire');
   

   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteria', 'Self', 'N', 1);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteria', 'Counterparty', 'N', 2);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteria', 'Umpire', 'N', 3);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteria', 'Final', 'N', 4);

 
