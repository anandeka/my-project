update rfc_report_filter_config rfc set rfc.label = 'QP Start Date' where rfc.label_id = 'RFC235PHY01'and rfc.report_id='235';
update rfc_report_filter_config rfc set rfc.label = 'QP End Date' where rfc.label_id = 'RFC235PHY02' and rfc.report_id='235';
update rfc_report_filter_config rfc set rfc.label = 'Counter Party' where rfc.label_id = 'RFC235PHY03' and rfc.report_id='235';
update rfc_report_filter_config rfc set rfc.label = 'Shipping Status' where rfc.label_id = 'RFC235PHY05' and rfc.report_id='235';
update rfc_report_filter_config rfc set rfc.label = 'Pricing Option' where rfc.label_id = 'RFC235PHY06' and rfc.report_id='235';
update rfc_report_filter_config rfc set rfc.label = 'GMR Ref No' where rfc.label_id = 'RFC235PHY07' and rfc.report_id='235';
update rfc_report_filter_config rfc set rfc.is_mandatory = 'N' where rfc.REPORT_ID = '235'and rfc.LABEL_ID = 'RFC235PHY01';
commit;
