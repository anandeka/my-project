 Create or Replace Force view v_eod_GPAH as select * from gpah_gmr_price_alloc_header@EKA_EODDB;
   
 Create or Replace Force view v_eod_GPAD as select * from gpad_gmr_price_alloc_dtls@EKA_EODDB;
  
  

 Insert into AMC_APP_MENU_CONFIGURATION
    (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
     ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
     IS_DELETED)
  Values
    ('LPANI', 'Arrived And Priced by GMR', 13, 3, '/metals/loadListOfPricedAndNotInvoiced.action?gridId=LPANI', 
     NULL, 'LRPTS', 'APP-ACL-N1085', 'Reports', 'APP-PFL-N-187', 
     'N');
     
     
 
 INSERT INTO gm_grid_master
             (grid_id, grid_name,
              default_column_model_state,
              tab_id,
              url,
              default_record_model_state, other_url,
              screen_specific_jsp,
              screen_specific_js
             )
      VALUES ('LPANI', 'List Of Priced And Not Invoiced',
              '[{"dataIndex":"","gmrRefNo":true,"header":"<div class=\"x-grid3-hd-checker\"><subst>;</div>","id":"checker","sortable":false,"width":20}]',
              'Finance',
              '/metals/loadListOfPricedAndNotInvoiced.do?method=loadPricedAndNotInvoicedList',
              '[{name: ''''gmrRefNo'''', mapping: ''''gmrRefNo''''}]', NULL,
              '/private/jsp/invoice/listing/pricedAndNotInvoiced.jsp',
              '/private/js/invoice/listing/pricedAndNotInvoiced.js'
            );
