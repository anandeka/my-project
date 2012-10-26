Insert into SLV_STATIC_LIST_VALUE(VALUE_ID, VALUE_TEXT) Values   ('Derivatives', 'Derivatives');
Insert into SLV_STATIC_LIST_VALUE(VALUE_ID, VALUE_TEXT) Values   ('MDM', 'MDM');
Insert into SLV_STATIC_LIST_VALUE(VALUE_ID, VALUE_TEXT) Values   ('Contract', 'Contract');
Insert into SLV_STATIC_LIST_VALUE(VALUE_ID, VALUE_TEXT) Values   ('CallOff', 'CallOff');
Insert into SLV_STATIC_LIST_VALUE(VALUE_ID, VALUE_TEXT) Values   ('GMR', 'GMR');


Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER) Values ('EntityList', 'Derivatives', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER) Values ('EntityList', 'MDM', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER) Values ('EntityList', 'Invoice', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER) Values ('EntityList', 'Contract', 'N', 4);
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER) Values ('EntityList', 'CallOff', 'N', 5);
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER) Values ('EntityList', 'Physical', 'N', 6);
Insert into SLS_STATIC_LIST_SETUP (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER) Values ('EntityList', 'GMR', 'N', 7);
