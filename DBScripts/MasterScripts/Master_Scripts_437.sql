----update the trades position report filter label to eod date
update rfc_report_filter_config rfc
set rfc.label = 'EOD Date'
where rfc.label_id = 'RFC360PHY01';
commit;
