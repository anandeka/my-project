
SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Fully Allocated', 'Fully Allocated');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Partially Allocated', 'Partially Allocated');
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Over Allocated', 'Over Allocated');
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('UnAllocated', 'UnAllocated');
COMMIT;

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('HedgeAllocationStatus', 'Fully Allocated', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('HedgeAllocationStatus', 'Partially Allocated', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('HedgeAllocationStatus', 'Over Allocated', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('HedgeAllocationStatus', 'UnAllocated', 'N', 4);
COMMIT;


update SLS_STATIC_LIST_SETUP sls set SLS.VALUE_ID = 'DeliveryItemRefNo' where SLS.VALUE_ID='DI Ref. No.' and SLS.LIST_TYPE='FXExposureFilter';

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('FXExposureFilter', 'GMR Ref No', 'N', 4);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('FXExposureFilter', 'Contract Ref No', 'N', 3);
COMMIT;