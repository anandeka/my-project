

SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Slab', 'Slab');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Tier', 'Tier');
COMMIT;

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('slabtier', 'Slab', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('slabtier', 'Tier', 'N', 2);
COMMIT;

SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Base', 'Base');
COMMIT;


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('treatmentChargePricePosition', 'Base', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('treatmentChargePricePosition', 'Range Begining', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('treatmentChargePricePosition', 'Range End', 'N', 2);
COMMIT;

update SLS_STATIC_LIST_SETUP set IS_DEFAULT='N' where LIST_TYPE='chargeBasis' and VALUE_ID='absolute';

update SLS_STATIC_LIST_SETUP set IS_DEFAULT='N' where LIST_TYPE='chargeBasis' and VALUE_ID='fractions Pro-Rata';