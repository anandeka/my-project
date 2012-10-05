set define off;
--update amc_app_menu_configuration set is_deleted = 'Y' where menu_id = 'RPT-D260';

update amc_app_menu_configuration
   set menu_display_name = 'Daily Realized Physical P&L'
 where menu_id = 'RPT-D227';
 
update amc_app_menu_configuration
   set menu_display_name = 'Monthly Open Unrealized Physical P&L'
 where menu_id = 'RPT-D231'; 

update amc_app_menu_configuration
   set menu_display_name = 'Monthly Inventory Unrealized Physical P&L'
 where menu_id = 'RPT-D233';

update rml_report_master_list rml
set rml.report_file_name = 'MonthlyOpenUnrealizedPhysicalPnl_Cog.rpt'
where rml.report_id = '225';
update rml_report_master_list rml
set rml.report_file_name = 'MonthlyInventoryUnrealizedPhysicalPnL_cog.rpt'
where rml.report_id = '227';
update amc_app_menu_configuration amc
set amc.link_called = '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=225&ReportName=MonthlyOpenUnrealizedPhysicalPnl_Cog.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D231';
update amc_app_menu_configuration amc
set amc.link_called = '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=227&ReportName=MonthlyInventoryUnrealizedPhysicalPnL_cog.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D233';
commit;