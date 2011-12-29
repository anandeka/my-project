
SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOID', 'List Of Invoice Draft', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},
   {header: "Draft No", width: 150, sortable: true, renderer:draftNoLink, dataIndex: "draftNo"}, 
                         {header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"},
                         {header: "GMR Ref No", width: 150, sortable: true, dataIndex: "gmrRefNo"},
                         {header: "Quota Month", width: 150, sortable: true, dataIndex: "quotaMonth"},
                         {header: "CP Invoice No", width: 150, sortable: true, dataIndex: "cpInvoiceNo"},
                         {header: "Invoice Date", width: 150, sortable: true, dataIndex: "invoiceDate"},
                         {header: "Invoice Amount", width: 150, sortable: true, dataIndex: "invoiceAmt"},
                         {header: "Due Date", width: 150, sortable: true, dataIndex: "dueDate"},
                         {header: "Payment Status", width: 150, sortable: true, dataIndex: "paymentStatus"},
                         {header: "Invoice Type", width: 150, sortable: true, dataIndex: "invoiceType"},
                         {header: "Parent Invoice Ref No", width: 150, sortable: true, dataIndex: "parentInvRefNo"},
                         {header: "CP Name", width: 150, sortable: true, dataIndex: "cpName"},
                         {header: "BIll To CP Name", width: 150, sortable: true, dataIndex: "billToCpName"},
                         {header: "Utilized Amount", width: 150, sortable: true, dataIndex: "utilizedAmt"},
                         {header: "Balance Amount", width: 150, sortable: true, dataIndex: "balanceAmt"},
                         {header: "Creation Date", width: 150, sortable: true, dataIndex: "creationDate"},
                         {header: "Last Updated Date", width: 150, sortable: true, dataIndex: "lastUpdatedDate"},
                         {header: "User Name", width: 150, sortable: true, dataIndex: "userName"},
                         {header: "Posting Status", width: 150, sortable: true, dataIndex: "postingStatus"},
                         {header: "Invoice Status", width: 150, sortable: true, dataIndex: "invoiceStatus"},
                       	 {header: "Product", width: 150, sortable: true, dataIndex: "product"},
                       	 {header: "Contract No.", width: 150, sortable: true, dataIndex: "contractNo"},
                       	 {header: "Internal Comments", width: 150, sortable: true, renderer:internalCommentsLink, dataIndex: "internalComments"}
   
   ]', NULL, NULL, 
    '[ 
                        {name: "draftNo", mapping: "draftNo"}, 
                        {name: "contractType", mapping: "contractType"}, 
                        {name: "gmrRefNo", mapping: "gmrRefNo"},
                        {name: "quotaMonth", mapping: "quotaMonth"},
                        {name: "cpInvoiceNo", mapping: "cpInvoiceNo"},
                        {name: "invoiceDate", mapping: "invoiceDate"},
                        {name: "invoiceAmt", mapping: "invoiceAmt"},
                        {name: "dueDate", mapping: "dueDate"},
                        {name: "paymentStatus", mapping: "paymentStatus"},
                        {name: "invoiceType", mapping: "invoiceType"},
                        {name: "parentInvRefNo", mapping: "parentInvRefNo"},
                        {name: "cpName", mapping: "cpName"},
                        {name: "billToCpName", mapping: "billToCpName"},
                        {name: "utilizedAmt", mapping: "utilizedAmt"},
                        {name: "balanceAmt", mapping: "balanceAmt"},
                        {name: "creationDate", mapping: "creationDate"},
                        {name: "lastUpdatedDate", mapping: "lastUpdatedDate"},
                        {name: "userName", mapping: "userName"},
                        {name: "postingStatus", mapping: "postingStatus"},
                        {name: "invoiceStatus", mapping: "invoiceStatus"},
                        {name: "product", mapping: "product"},
                        {name: "contractNo", mapping: "contractNo"},
                        {name: "internalComments", mapping: "internalComments"}
                                
     ]', NULL, 'invoice/draft/ListOfInvoiceDraft.jsp', '/private/js/invoice/draft/listOfInvoiceDraft.js');



Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOID_1', 'LOID', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
    

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOID_1_1', 'LOID', 'Modify', 2, 2, 
    NULL, 'function(){modifyInvoiceDraft();}', NULL, 'LOID_1', NULL);   
    
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOID_1_2', 'LOID', 'Approve', 3, 2, 
    NULL, 'function(){approveInvoiceDraft();}', NULL, 'LOID_1', NULL);     
    

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOID_1_3', 'LOID', 'Cancel', 4, 2, 
    NULL, 'function(){cancelInvoiceDraft();}', NULL, 'LOID_1', NULL);    


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('LOID', 'List Of InvoiceDraft', 7, 3, '/metals/loadListOfInvoiceDraft.action?gridId=LOID', 
    NULL, 'F2', NULL, 'Finance', NULL);


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DFT_PI', 'Draft Invoice', 'Create Draft Provisional Invoice', 'N', 'Draft Provisional Invoice Created', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DFT_PI', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DFTPIRefNo', 'DFT PI Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




   CREATE SEQUENCE SEQ_DFT_PI
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_DFT_PI', 'DFT_PI', 'SEQ_DFT_PI');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_DFT_PI', 'Invoice', 'Cancel Draft Provisional Invoice', 'N', 'Draft Provisional Invoice Cancelled', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_DFT_PI', 'N', 'N', 'invCancelDate', 'N', 
    NULL, NULL, NULL, 'N');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DFT_FI', 'Draft Invoice', 'Create Draft Final Invoice', 'N', 'Draft Final Invoice Created', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DFT_FI', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DFTFIRefNo', 'DFT FI Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




   CREATE SEQUENCE SEQ_DFT_FI
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_DFT_FI', 'DFT_FI', 'SEQ_DFT_FI');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_DFT_FI', 'Invoice', 'Cancel Draft Final Invoice', 'N', 'Draft Final Invoice Cancelled', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_DFT_FI', 'N', 'N', 'invCancelDate', 'N', 
    NULL, NULL, NULL, 'N');

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DFT_DFI', 'Draft Invoice', 'Create Draft Direct Final Invoice', 'N', 'Draft Direct Final Invoice Created', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DFT_DFI', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DFTDFIRefNo', 'DFT DFI Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




   CREATE SEQUENCE SEQ_DFT_DFI
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_DFT_DFI', 'DFT_DFI', 'SEQ_DFT_DFI');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_DFT_DFI', 'Invoice', 'Cancel Draft Direct Final Invoice', 'N', 'Draft Direct Final Invoice Cancelled', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_DFT_DFI', 'N', 'N', 'invCancelDate', 'N', 
    NULL, NULL, NULL, 'N');

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DFT_API', 'Draft Invoice', 'Create Draft Advance Payment Invoice', 'N', 'Draft Advance Payment Invoice Created', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DFT_API', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DFTAPIRefNo', 'DFT API Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




   CREATE SEQUENCE SEQ_DFT_API
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_DFT_API', 'DFT_API', 'SEQ_DFT_API');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_DFT_API', 'Invoice', 'Cancel Draft Advace Payment Invoice', 'N', 'Draft Advance Payment Invoice Cancelled', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_DFT_API', 'N', 'N', 'invCancelDate', 'N', 
    NULL, NULL, NULL, 'N');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DFT_DC', 'Draft Invoice', 'Create Draft Debit Credit Note', 'N', 'Draft Debit Credit Note Created', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DFT_DC', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DFTDCRefNo', 'DFT DC Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




   CREATE SEQUENCE SEQ_DFT_DC
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_DFT_DC', 'DFT_DC', 'SEQ_DFT_DC');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_DFT_DC', 'Invoice', 'Cancel Draft Debit Credit Note', 'N', 'Draft Debit Credit Note Cancelled', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_DFT_DC', 'N', 'N', 'invCancelDate', 'N', 
    NULL, NULL, NULL, 'N');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DFT_SI', 'Draft Invoice', 'Create Draft Service Invoice', 'N', 'Draft Service Invoice Created', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DFT_SI', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DFTSIRefNo', 'DFT SI Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




   CREATE SEQUENCE SEQ_DFT_SI
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_DFT_SI', 'DFT_SI', 'SEQ_DFT_SI');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_DFT_SI', 'Invoice', 'Cancel Draft Service Invoice', 'N', 'Draft Service Invoice Cancelled', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_DFT_SI', 'N', 'N', 'invCancelDate', 'N', 
    NULL, NULL, NULL, 'N');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DFT_VAT', 'Draft Invoice', 'Create Draft Vat Invoice', 'N', 'Draft Vat Invoice Created', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DFT_VAT', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DFTVATRefNo', 'DFT VAT Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




   CREATE SEQUENCE SEQ_DFT_VAT
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_DFT_VAT', 'DFT_VAT', 'SEQ_DFT_VAT');


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_DFT_VAT', 'Invoice', 'Cancel Draft Vat Invoice', 'N', 'Draft Vat Invoice Cancelled', 
    'N', NULL);


Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_DFT_VAT', 'N', 'N', 'invCancelDate', 'N', 
    NULL, NULL, NULL, 'N');


