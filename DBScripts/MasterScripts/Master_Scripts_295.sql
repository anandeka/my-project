Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('gmrRefNo', 'GMR Ref. No.');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('deliveryRefNo', 'Delivery Item Ref. No.');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('conItemRefNo', 'Contract Item Ref. No.');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('activityRefNo', 'Activity Ref. No.');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('CancelInvoice', 'Cancel Invoice');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('AdvancePaymentDebitCredit', 'Advance Payment Debit Credit Note');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Output Charge Invoice', 'Receive Material Invoice');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Commercial Fee', 'Commercial Fee Invoice');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('isFreeMetal', 'Free Metal Invoice');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('isPledge', 'Pledge Invoice');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'conItemRefNo', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'gmrRefNo', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'deliveryRefNo', 'N', 4);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'activityRefNo', 'N', 5);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'CancelInvoice', 'N', 10);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'AdvancePaymentDebitCredit', 'N', 11);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'Output Charge Invoice', 'N', 12);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceType', 'Commercial Fee', 'N', 12);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceSubType', 'isFreeMetal', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoiceSubType', 'isPledge', 'N', 2);













 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   ('BLD', 'UTIL_INV_REF_NO', 'UTIL-', 8, '-BLD');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   ('LDE', 'UTIL_INV_REF_NO', 'UTIL-', 10, '-LDE');

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_UTIL_INV', 'Invoice', 'Create Utility Invoice', 'N', 'Utility Invoice Created', 
    'N', NULL);

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('UtilInvRefNo', 'Utility Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  

axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-5550', 'BLD', 'CREATE_UTIL_INV', 'UtilInvRefNo', 'N');
Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-5551', 'LDE', 'CREATE_UTIL_INV', 'UtilInvRefNo', 'N');


Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-5550', 'UtilInvRefNo', 'BLD', 'UTIL-', 1, 
    8, '-BLD', NULL, 'N');
Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-5551', 'UtilInvRefNo', 'LDE', 'UTIL-', 1, 
    5, '-LDE', 1, 'N');

Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_UTIL_INV', 'N', 'N', 'issueDate', 'N', 
    NULL, NULL, NULL, 'Y');