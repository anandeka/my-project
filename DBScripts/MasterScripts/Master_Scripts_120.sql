Insert into SLS_STATIC_LIST_SETUP
        (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
        Values
        ('EventPricing', 'Event', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
       (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
       Values
       ('PayableContentBasis', 'Assay', 'Y', 1);
       Insert into SLS_STATIC_LIST_SETUP
       (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
       Values
       ('PayableContentBasis', 'Flat', 'N', 2);
Insert into SLV_STATIC_LIST_VALUE
       (VALUE_ID, VALUE_TEXT)
       Values
       ('Payable', 'Payable');
Insert into SLV_STATIC_LIST_VALUE
       (VALUE_ID, VALUE_TEXT)
       Values
       ('Returnable', 'Returnable');
Insert into SLS_STATIC_LIST_SETUP
       (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
       Values
       ('PayableReturnable', 'Payable', 'Y', 1);
       Insert into SLS_STATIC_LIST_SETUP
       (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
       Values
       ('PayableReturnable', 'Returnable', 'N', 2);
