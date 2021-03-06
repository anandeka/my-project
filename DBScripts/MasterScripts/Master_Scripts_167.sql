INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('pledgeTransfer', 'GMR Tolling ', 'Pledge Transfer', 'Y', 'Pledge Transfer GMR','N', NULL);


INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('cancelPledgeTransfer', 'GMR Tolling ', 'Cancel Pledge Transfer', 'Y', 'Cancel Pledge Transfer GMR','N', NULL);


INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('metalBalanceTransfer', 'GMR Tolling ', 'Metal Balance Transfer', 'Y', 'Metal Balance Transfer','N', NULL);
   
INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('financialSettlement', 'GMR Tolling ', 'Financial Settlement', 'Y', 'Financial Settlement GMR','N', NULL);

INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('cancelFinancialSettlement', 'GMR Tolling ', 'Cancel Financial Settlement', 'Y', 'Cancel Financial Settlement GMR','N', NULL);
   

INSERT INTO CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 VALUES
   ('pledgeTransfer', 'N', 'N', 'activityDate', 'N', NULL, NULL, 'N', 'N');

INSERT INTO CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 VALUES
   ('cancelPledgeTransfer', 'N', 'N', 'activityDate', 'N', NULL, NULL, 'N', 'N');
   
INSERT INTO CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 VALUES
   ('metalBalanceTransfer', 'N', 'N', 'activityDate', 'N', NULL, NULL, 'N', 'N');

   
   
   
INSERT INTO CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 VALUES
   ('financialSettlement', 'N', 'N', 'activityDate', 'N', NULL, NULL, 'N', 'N');

INSERT INTO CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 VALUES
   ('cancelFinancialSettlement', 'N', 'N', 'activityDate', 'N', NULL, NULL, 'N', 'N');

   
INSERT INTO AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 VALUES
   ('PTRefNo', 'Pledge Transfer Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

INSERT INTO AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 VALUES
   ('MBTRefNo', 'MBT Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');