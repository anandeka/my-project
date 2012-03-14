
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('ServiceInvoiceReceived', 'ServiceInvoiceReceived');



Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('ServiceInvoiceRaised', 'ServiceInvoiceRaised');
   
   

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'ServiceInvoiceReceived', 'N', 8);



Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'ServiceInvoiceRaised', 'N', 9);

