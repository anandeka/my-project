set define off;
Update AMC_APP_MENU_CONFIGURATION amc
set AMC.LINK_CALLED = '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=253&ReportName=DailyRealizedPNLReportConc_Cog.rpt.rpt&ExportFormat=HTML&isEodReport=Y'
where AMC.MENU_ID = 'RPT-D253';
commit;

