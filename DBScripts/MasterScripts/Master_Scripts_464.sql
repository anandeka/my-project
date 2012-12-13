DELETE FROM sls_static_list_setup sls
      WHERE sls.list_type = 'invoiceType'
        AND sls.value_id = 'Commercial Fee'
        AND sls.display_order = 12;
        
DELETE FROM slv_static_list_value slv
      WHERE slv.value_id = 'Commercial Fee';
      
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('isCommercialFee', 'Commercial Fee');
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceSubType', 'isCommercialFee', 'N', 3);