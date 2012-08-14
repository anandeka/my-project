delete from SLS_STATIC_LIST_SETUP sls where SLS.LIST_TYPE = 'GMRListingStatus';
delete from SLV_STATIC_LIST_VALUE slv where SLV.VALUE_ID = 'Landed';
commit;
SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Landed', 'Landed');
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('GMRListingStatus', 'Shipped', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('GMRListingStatus', 'Landed', 'N', 3);
COMMIT;
