set define OFF;
update amc_app_menu_configuration amc
   set is_deleted = 'Y'
 where amc.menu_id = 'RPT-D370';

update amc_app_menu_configuration amc
   set amc.menu_display_name = 'Hedge Allocation Report',
       amc.link_called       = '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=371&ReportName=HedgeAllocationReport.rpt&ExportFormat=HTML&isEodReport=Y'
 where amc.menu_id = 'RPT-D371';
 
update amc_app_menu_configuration amc
   set amc.menu_display_name = 'Priced Ordered Stock Valuation Report',
       amc.link_called       = '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=372&ReportName=PricedOrderedStockValuation.rpt&ExportFormat=HTML'
 where amc.menu_id = 'RPT-D372';

update rml_report_master_list rml
   set rml.report_file_name    = 'HedgeAllocationReport.rpt',
       rml.report_display_name = 'Hedge Allocation Report'
 where rml.report_id = '371';
  
update rml_report_master_list rml
   set rml.report_file_name    = 'PricedOrderedStockValuation.rpt',
       rml.report_display_name = 'Priced Ordered Stock Valuation Report'
 where rml.report_id = 372;

 update amc_app_menu_configuration amc
   set amc.menu_display_name = 'Weighted Averages Physical Pricings Report'
 where amc.menu_id = 'RPT-D374';
 
 commit;