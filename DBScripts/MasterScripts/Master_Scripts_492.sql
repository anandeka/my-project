UPDATE scm_service_charge_master scm
   SET scm.cost_type = 'AUTOMATIC_CHARGES'
 WHERE scm.cost_component_name IN
          ('Sampling Charge', 'Handling Charge', 'Location Value',
           'Freight Allowance');