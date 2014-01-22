DELETE FROM sls_static_list_setup sls
      WHERE sls.list_type = 'PositionStatus'
      and sls.value_id = 'Pending Approval';