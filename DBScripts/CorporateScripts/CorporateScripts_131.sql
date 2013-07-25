update rpc_rf_parameter_config rpc
   set rpc.report_parameter_name = 'Smelter'
 where rpc.report_id = 255
   and rpc.label_id = 'RFC255PHY03'
   and rpc.parameter_id = 'RFP1002';
update rpc_rf_parameter_config rpc
   set rpc.report_parameter_name = 'Smelter'
 where rpc.report_id = 256
   and rpc.label_id = 'RFC256PHY03'
   and rpc.parameter_id = 'RFP1002';
update rpc_rf_parameter_config rpc
   set rpc.report_parameter_name = 'Smelter'
 where rpc.report_id = 257
   and rpc.label_id = 'RFC257PHY03'
   and rpc.parameter_id = 'RFP1002';
commit;
