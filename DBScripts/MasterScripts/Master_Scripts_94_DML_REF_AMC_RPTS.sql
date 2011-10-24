set define off;
update amc_app_menu_configuration amc set amc.link_called = '/mdm/CommonFilter.do?method=populateJRCReport&docType=ONLINE&ReportID=217&ReportName=DailyFXExposureReport.rpt&ExportFormat=HTML'
where amc.menu_id ='RPT-D219';
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('215', 'EXCEL', 'PriceExposureReport.rpt');
COMMIT;