
update SLV_STATIC_LIST_VALUE set value_text='Container'  where value_id='Container';

insert INTO SLV_STATIC_LIST_VALUE (VALUE_ID,VALUE_TEXT) values ('Lot','Lot');

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('chargeUnit', 'Dry', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('chargeUnit', 'Wet', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('chargeUnit', 'Lot', 'N', 3);