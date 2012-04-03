
ALTER TABLE ash_assay_header ADD (use_for_invoice CHAR (1), invoice_ash_id VARCHAR2 (15), prev_invoice_ash_id VARCHAR2(15), wght_avg_invoice_ash_id VARCHAR2(15), prev_wght_avg_invoice_ash_id VARCHAR2(15));

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOAS-UPA', 'LOAD', 'Update Pricing Assay', 6, 2, 
    'APP-PFL-N-160', 'function(){callUpdatePricingAssay()}', NULL, 'LOAS', 'APP-ACL-N884');
