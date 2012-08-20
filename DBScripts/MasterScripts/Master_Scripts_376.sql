SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Commercial Fee For Additional Charges', 'Commercial Fee');
COMMIT;

UPDATE sls_static_list_setup
   SET value_id = 'Commercial Fee For Additional Charges'
 WHERE list_type = 'ChargeNames'
   AND value_id = 'Commercial Fee';
COMMIT ;