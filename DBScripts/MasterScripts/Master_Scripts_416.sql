delete SLS_STATIC_LIST_SETUP sls where SLS.VALUE_ID = 'Title_Transfer_Date' and SLS.LIST_TYPE = 'BaseDate';
delete SLV_STATIC_LIST_VALUE slv where SLV.VALUE_ID = 'Title_Transfer_Date';

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Arrival_Date', 'Arrival Date');
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('BaseDate', 'Arrival_Date', 'N', 2);