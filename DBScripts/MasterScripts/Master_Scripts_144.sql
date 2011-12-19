update rfc_report_filter_config  rfc
set rfc.label = 'EOM Month'
where rfc.report_id = '231' and
      rfc.label_id = 'RFC231CDC01'; 
      
delete from rpc_rf_parameter_config rpc
where rpc.report_id = '230'
and rpc.report_parameter_name in ('AsOfDate','SYSTEM');
Commit;