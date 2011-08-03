SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Weighted Mean', 'Weighted Mean');


update SLS_STATIC_LIST_SETUP set VALUE_ID='Weighted Mean' where LIST_TYPE='ConversionMethodType' and VALUE_ID='Wieghted Mean';