update scm_service_charge_master scm
   set scm.acc_direct_actual    = 'Y',
       scm.acc_original_accrual = 'Y',
       scm.acc_under_accrual    = 'Y',
       scm.acc_over_accrual     = 'Y'
 where scm.cost_type = 'SECONDARY_COST';
COMMIT; 
