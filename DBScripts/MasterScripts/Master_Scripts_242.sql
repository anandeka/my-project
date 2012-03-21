update rfc_report_filter_config rfc set rfc.label = 'EOD Date' where rfc.label_id = 'RFC243PHY01'and rfc.report_id='243';
update rfc_report_filter_config rfc set rfc.label = 'Counter Party' where rfc.label_id = 'RFC243PHY02' and rfc.report_id='243';
update rfc_report_filter_config rfc set rfc.label = 'Invoice Pay-in Currency' where rfc.label_id = 'RFC243PHY03' and rfc.report_id='243';
update rfc_report_filter_config rfc set rfc.label = 'Contract Ref No' where rfc.label_id = 'RFC243PHY04' and rfc.report_id='243';

