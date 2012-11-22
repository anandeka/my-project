/*
Setting XL file RPT file info. for Broker Margin Report...
*/
update ref_reportexportformat
set report_file_name = 'BrokerMarginReport_Excel.rpt'
where report_id = '258';