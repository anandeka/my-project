UPDATE rpc_rf_parameter_config rpc
   SET rpc.report_parameter_name = 'ProfitCenter'
 WHERE rpc.report_id IN ('213', '216', '253', '226', '228', '254')
   AND rpc.report_parameter_name = 'Book';