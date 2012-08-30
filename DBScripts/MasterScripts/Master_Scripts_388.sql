SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Price Fixation Ref. No.', 'Price Fixation Ref. No.');
COMMIT;
   
SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('DI Ref. No.', 'DI Ref. No.');
COMMIT;


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('FXExposureFilter', 'Price Fixation Ref. No.', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('FXExposureFilter', 'DI Ref. No.', 'N', 2);
COMMIT;


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('conType', 'Purchase', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('conType', 'Sales', 'N', 2);
COMMIT;


SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Hedge Correction', 'Hedge Correction');
COMMIT;
   
   SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Price Fixation', 'Price Fixation');
COMMIT;


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('exposureType', 'Hedge Correction', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('exposureType', 'Price Fixation', 'N', 2);
COMMIT;