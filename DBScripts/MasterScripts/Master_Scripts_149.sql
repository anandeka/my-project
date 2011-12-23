delete from RPC_RF_PARAMETER_CONFIG where report_id in ('217','218','219','220');
delete from RFC_REPORT_FILTER_CONFIG where report_id in ('217','218','219','220');
commit;
set define off;
update AMC_APP_MENU_CONFIGURATION
set LINK_CALLED = '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=217&ReportName=DailyFXExposureReport.rpt&ExportFormat=HTML'
where menu_id = 'RPT-D219';
update AMC_APP_MENU_CONFIGURATION
set LINK_CALLED = '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=219&ReportName=ProjectedPriceExposure.rpt&ExportFormat=HTML'
where menu_id = 'RPT-D215';
update AMC_APP_MENU_CONFIGURATION
set LINK_CALLED = '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=220&ReportName=MonthlyFXExposureReport.rpt&ExportFormat=HTML'
where menu_id = 'RPT-D213';
commit;

