UPDATE scm_service_charge_master scm
   SET scm.is_active = 'N'
 WHERE scm.cost_component_name IN ('Premium', 'Commercial Fees');