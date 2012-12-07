update rfc_report_filter_config rfc 
set rfc.is_mandatory = null
where rfc.report_id = 236;
commit;
