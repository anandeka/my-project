
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('AssayRefNo', 'Assay Ref. No.');

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ListOfAssaySearchCriteria', 'AssayRefNo', 'N', 7);
   

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('ProvisionalAssay', 'Provisional');


set define off;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('WSAssay', 'W&S');

  

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteria', 'ProvisionalAssay', 'N', 5);


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteria', 'WSAssay', 'N', 6);


set define off;
UPDATE slv_static_list_value
   SET value_text = 'W&S Ref. No.'
 WHERE value_id = 'WandSRef No';
 
 
UPDATE slv_static_list_value
   SET value_text = 'Our Ref. No.'
 WHERE value_id = 'OurRef No';
 

UPDATE slv_static_list_value
   SET value_text = 'Ext Ref. No.'
 WHERE value_id = 'ExtRef No';
 


