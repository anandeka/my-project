Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ElementType', 'Payable', 'N', 1);

delete from  SLS_STATIC_LIST_SETUP sls where SLS.LIST_TYPE = 'ElementTyope';