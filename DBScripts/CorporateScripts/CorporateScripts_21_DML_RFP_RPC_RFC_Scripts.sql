update rpc_rf_parameter_config rpc set rpc.report_parameter_name='TradeDate'
where rpc.report_id='101' 
and   rpc.corporate_id='EKA'
and   rpc.label_id='RFC101CDC05'
and   rpc.parameter_id='RFP0026';
update rpc_rf_parameter_config rpc set rpc.report_parameter_name='TradeDate'
where rpc.report_id='101' 
and   rpc.corporate_id='LDE'
and   rpc.label_id='RFC101CDC05'
and   rpc.parameter_id='RFP0026';
commit;