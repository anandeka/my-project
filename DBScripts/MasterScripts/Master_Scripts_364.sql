set define off;
update rml_report_master_list rml
set rml.report_file_name = 'ArrivedandNotPricedReport.rpt',
    rml.report_display_name = 'Arrived & Not Priced Report'
where rml.report_id = '235';
update amc_app_menu_configuration amc
set amc.menu_display_name = 'Arrived & Not Priced Report',
amc.link_called = '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=235&ReportName=ArrivedandNotPricedReport.rpt&ExportFormat=HTML'
where amc.menu_id = 'RPT-D2111';
update ref_reportexportformat ref
set ref.report_file_name = 'ArrivedandNotPricedReport_Excel.rpt'
where ref.report_id = '235';
commit;