Insert into ACL_ACCESS_CONTROL_LIST
	   (ACL_ID, ACL_NAME, ACL_DESCRIPTION, ACTIVITY_ID, ACL_CHECK_FLAG, 
	    ACL_CATEGORY_MASTER_ID)
	 Values
	   ('APP-ACL-N1401', 'Export To Excel', 'Export To Excel', 'APP-ACM-N226', 'Y', 
    NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
	   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
	    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
	 Values
	   ('LOI_9', 'LOII_TEST', 'Export To Excel', 9, 2, 
	    'APP-PFL-N-187', 'function(){exportSelectedInvoiceToExcel();}', NULL, 'LOI_1', 'APP-ACL-N1401');
	