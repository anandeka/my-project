update rfc_report_filter_config rfc
set rfc.is_mandatory = 'Y'
 where rfc.report_id = '217'
 and rfc.label_id = 'RFC217PHY05';
 commit;
