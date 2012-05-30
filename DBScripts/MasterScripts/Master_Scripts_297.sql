update RFC_REPORT_FILTER_CONFIG rfc
set rfc.label = 'Arrival No.'
where rfc.label_id = 'RFC237PHY07';
update RFC_REPORT_FILTER_CONFIG rfc
set rfc.label= 'Contract Ref. No.'
where rfc.label_id = 'RFC237PHY08';
update RFC_REPORT_FILTER_CONFIG rfc
set rfc.label= 'GMR Ref. No.'
where rfc.label_id = 'RFC237PHY09';
update RFC_REPORT_FILTER_CONFIG rfc
set rfc.label = 'From Date'
where rfc.label_id = 'RFC238PHY01';
update RFC_REPORT_FILTER_CONFIG rfc
set rfc.label = 'To Date'
where rfc.label_id = 'RFC238PHY02';
update RFC_REPORT_FILTER_CONFIG rfc
set rfc.label = 'Contract Ref. No.'
where rfc.label_id = 'RFC238PHY07';
update RFC_REPORT_FILTER_CONFIG rfc
set rfc.label= 'Contract Item Ref. No.'
where rfc.label_id = 'RFC238PHY08';
commit;
