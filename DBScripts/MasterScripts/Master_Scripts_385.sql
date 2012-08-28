Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('MODIFY_INVOICE', 'Invoice ', 'Modify Invoice', 'N', 'Invoice Modification', 
    'N', NULL);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (3000, 'MODIFY_INVOICE', NULL, 'paymentDueDate', 'New Due Date', 
    NULL);
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (3001, 'MODIFY_INVOICE', NULL, 'cpRefNo', 'New CP Invoice Ref. No.', 
    NULL);
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (3002, 'MODIFY_INVOICE', NULL, 'billToAddress', 'New Bill To Address', 
    NULL);
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (3003, 'MODIFY_INVOICE', NULL, 'internalComments', 'New Internal Comments', 
    NULL);