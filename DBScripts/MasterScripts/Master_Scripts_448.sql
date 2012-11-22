Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('AUTOMATIC_CHARGES', 'Automatic Charges');      


INSERT INTO scm_service_charge_master
            (cost_id, GROUP_ID, cost_component_name, cost_display_name,
             quotation_type_id, quotation_sub_type_id, cost_type,
             cost_group_id, is_auto_accrual, is_contract_accrual_possible,
             is_general_accrual_possible, reversal_type, acc_direct_actual,
             acc_original_accrual, acc_under_accrual, acc_over_accrual,
             allow_accrual_on_sales, allow_accrual_on_purchases, inc_exp,
             interest_cal_req, display_order, VERSION, is_active, is_deleted,
             service_charge_sub_type_id, is_exclude_from_pnl, is_capitalized
            )
     VALUES ('SCM-91', 'GCD-1', 'Small Lot Charges', 'Small Lot Charges',
             NULL, NULL, 'AUTOMATIC_CHARGES',
             'CGM-7', 'N', 'N',
             'Y', 'CONTRACT', 'N',
             'Y', 'N', 'N',
             'Y', 'Y', 'Expense',
             'N', 33, NULL, 'Y', 'N',
             null, 'N', 'N'
            );


INSERT INTO scm_service_charge_master
            (cost_id, GROUP_ID, cost_component_name, cost_display_name,
             quotation_type_id, quotation_sub_type_id, cost_type,
             cost_group_id, is_auto_accrual, is_contract_accrual_possible,
             is_general_accrual_possible, reversal_type, acc_direct_actual,
             acc_original_accrual, acc_under_accrual, acc_over_accrual,
             allow_accrual_on_sales, allow_accrual_on_purchases, inc_exp,
             interest_cal_req, display_order, VERSION, is_active, is_deleted,
             service_charge_sub_type_id, is_exclude_from_pnl, is_capitalized
            )
     VALUES ('SCM-92', 'GCD-1', 'Container Charges', 'Container Charges',
             NULL, NULL, 'AUTOMATIC_CHARGES',
             'CGM-7', 'N', 'N',
             'Y', 'CONTRACT', 'N',
             'Y', 'N', 'N',
             'Y', 'Y', 'Expense',
             'N', 34, NULL, 'Y', 'N',
             null, 'N', 'N'
            );

DELETE FROM sls_static_list_setup sls
      WHERE sls.value_id IN
               ('Contract Ref No', 'DeliveryItemRefNo',
                'Contract Item Ref No')
        AND sls.list_type = 'ListOfAssaySearchCriteria';
        

UPDATE sls_static_list_setup sls
   SET sls.display_order = 1
 WHERE sls.value_id = 'AssayRefNo'
   AND sls.list_type = 'ListOfAssaySearchCriteria';
   
 UPDATE sls_static_list_setup sls
   SET sls.display_order = 2
 WHERE sls.value_id = 'GMR Ref No'
   AND sls.list_type = 'ListOfAssaySearchCriteria';
   
 UPDATE sls_static_list_setup sls
   SET sls.display_order = 3
 WHERE sls.value_id = 'WandSRef No'
   AND sls.list_type = 'ListOfAssaySearchCriteria';
   
 UPDATE sls_static_list_setup sls
   SET sls.display_order = 4
 WHERE sls.value_id = 'GMR Activity Ref No'
   AND sls.list_type = 'ListOfAssaySearchCriteria';
