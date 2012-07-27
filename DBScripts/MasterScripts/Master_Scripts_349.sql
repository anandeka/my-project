delete from rpc_rf_parameter_config rpc
where rpc.label_id = 'RFC235PHY06';
delete from rfc_report_filter_config rfc
where rfc.label_id = 'RFC235PHY06';
update rfc_report_filter_config rfc
set rfc.label_row_number = '6'
where rfc.label_id = 'RFC235PHY07';
commit;