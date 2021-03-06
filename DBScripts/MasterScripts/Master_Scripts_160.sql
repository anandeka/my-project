Insert into SCST_SERVICE_CHARGE_SUB_TYPE
   (SERVICE_CHARGE_SUB_TYPE_ID, SERVICE_CHARGE_SUB_TYPE, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED)
 Values
   ('DIRECT_COST', 'Direct Cost', 7, NULL, 'Y', 
    'N');

Insert into SCM_SERVICE_CHARGE_MASTER
   (COST_ID, GROUP_ID, COST_COMPONENT_NAME, COST_DISPLAY_NAME, QUOTATION_TYPE_ID, 
    QUOTATION_SUB_TYPE_ID, COST_TYPE, COST_GROUP_ID, IS_AUTO_ACCRUAL, IS_CONTRACT_ACCRUAL_POSSIBLE, 
    IS_GENERAL_ACCRUAL_POSSIBLE, REVERSAL_TYPE, ACC_DIRECT_ACTUAL, ACC_ORIGINAL_ACCRUAL, ACC_UNDER_ACCRUAL, 
    ACC_OVER_ACCRUAL, ALLOW_ACCRUAL_ON_SALES, ALLOW_ACCRUAL_ON_PURCHASES, INC_EXP, INTEREST_CAL_REQ, 
    DISPLAY_ORDER, VERSION, IS_ACTIVE, IS_DELETED, SERVICE_CHARGE_SUB_TYPE_ID)
 Values
   ('SCM-75', 'GCD-1', 'Location Premium', 'Location Premium', NULL, 
    NULL, 'DIRECT_COST', 'CGM-7', 'N', 'Y', 
    'Y', 'CONTRACT', 'N', 'N', 'N', 
    'N', 'Y', 'Y', 'Expense', 'N', 
    26, NULL, 'Y', 'N', NULL);

Insert into SCM_SERVICE_CHARGE_MASTER
   (COST_ID, GROUP_ID, COST_COMPONENT_NAME, COST_DISPLAY_NAME, QUOTATION_TYPE_ID, 
    QUOTATION_SUB_TYPE_ID, COST_TYPE, COST_GROUP_ID, IS_AUTO_ACCRUAL, IS_CONTRACT_ACCRUAL_POSSIBLE, 
    IS_GENERAL_ACCRUAL_POSSIBLE, REVERSAL_TYPE, ACC_DIRECT_ACTUAL, ACC_ORIGINAL_ACCRUAL, ACC_UNDER_ACCRUAL, 
    ACC_OVER_ACCRUAL, ALLOW_ACCRUAL_ON_SALES, ALLOW_ACCRUAL_ON_PURCHASES, INC_EXP, INTEREST_CAL_REQ, 
    DISPLAY_ORDER, VERSION, IS_ACTIVE, IS_DELETED, SERVICE_CHARGE_SUB_TYPE_ID)
 Values
   ('SCM-76', 'GCD-1', 'Quality Premium', 'Quality Premium', NULL, 
    NULL, 'DIRECT_COST', 'CGM-7', 'N', 'Y', 
    'Y', 'CONTRACT', 'N', 'N', 'N', 
    'N', 'Y', 'Y', 'Expense', 'N', 
    27, NULL, 'Y', 'N', NULL);

