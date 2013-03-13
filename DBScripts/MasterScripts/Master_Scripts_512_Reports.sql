set define off;
update rml_report_master_list rml set rml.report_display_name = 'Physical Position' where rml.report_id ='211';
update rml_report_master_list rml set rml.report_display_name = 'Position - Delivery/Pricing' where rml.report_id ='212';
update rml_report_master_list rml set rml.report_display_name = 'Position - Delivery Pricing Derivative' where rml.report_id ='234';
update rml_report_master_list rml set rml.report_display_name = 'Daily Derivative Trades Report' where rml.report_id ='54';
update rml_report_master_list rml set rml.report_display_name = 'Daily Clearer Statement Report' where rml.report_id ='051';
update rml_report_master_list rml set rml.report_display_name = 'Day End Summary Position By Clearer' where rml.report_id ='104';
update rml_report_master_list rml set rml.report_display_name = 'Daily Derivatives Realized P&L Report' where rml.report_id ='58';
update rml_report_master_list rml set rml.report_display_name = 'Daily Derivatives Unrealized P&L Report' where rml.report_id ='59';
update rml_report_master_list rml set rml.report_display_name = 'Monthly FX Position and P&L Report' where rml.report_id ='223';
update rml_report_master_list rml set rml.report_display_name = 'Monthly Currency Realized P&L Report' where rml.report_id ='224';
update rml_report_master_list rml set rml.report_display_name = 'FX Position and P&L Report' where rml.report_id ='56';
update rml_report_master_list rml set rml.report_display_name = 'Currency Realized P&L Report' where rml.report_id ='75';
------------------------------------------------
update rml_report_master_list rml set rml.report_display_name = 'Monthly Open Unrealized Physical P&L' where rml.report_id ='225';
update rml_report_master_list rml set rml.report_display_name = 'Monthly Inventory Unrealized Physical P&L' where rml.report_id ='227';
update rml_report_master_list rml set rml.report_display_name = 'Daily Open Unrealized Physical P&L (Conc)' where rml.report_id ='213';
update rml_report_master_list rml set rml.report_display_name = 'Daily Inventory Unrealized Physical P&L (Conc)' where rml.report_id ='216';
update rml_report_master_list rml set rml.report_display_name = 'Daily Realized PNL Report P&L (Conc)' where rml.report_id ='253';
update rml_report_master_list rml set rml.report_display_name = 'Trade P&L Report' where rml.report_id ='65';
update rml_report_master_list rml set rml.report_display_name = 'Daily Overall Realized Physical P&L' where rml.report_id ='67';
update rml_report_master_list rml set rml.report_display_name = 'Daily Open Unrealized Physical P&L' where rml.report_id ='84';
update rml_report_master_list rml set rml.report_display_name = 'Daily Realized Physical P&L' where rml.report_id ='85';
update rml_report_master_list rml set rml.report_display_name = 'Daily Inventory Unrealized Physical P&L' where rml.report_id ='86';
update rml_report_master_list rml set rml.report_display_name = 'Derivative P&L Attribution Report' where rml.report_id ='103';


update rml_report_master_list rml set rml.report_display_name = 'Monthly FX Exposure Report' where rml.report_id ='220';
update rml_report_master_list rml set rml.report_display_name = 'Daily Detail Price Exposure Report' where rml.report_id ='218';
update rml_report_master_list rml set rml.report_display_name = 'Customs Report' where rml.report_id ='248';
update rml_report_master_list rml set rml.report_display_name = 'Feed Consumption Report' where rml.report_id ='256';
update rml_report_master_list rml set rml.report_display_name = 'Contract Status Report' where rml.report_id ='260';
update rml_report_master_list rml set rml.report_display_name = 'FX Position and P&L Report"' where rml.report_id ='56';
update rml_report_master_list rml set rml.report_display_name = 'Monthly FX Position and P&L Report' where rml.report_id ='223';
-----
update amc_app_menu_configuration amc set amc.menu_display_name ='Monthly FX Exposure Report' where amc.menu_id='RPT-D213';
update amc_app_menu_configuration amc set amc.menu_display_name ='Daily Detail Price Exposure Report' where amc.menu_id='RPT-D220';
update amc_app_menu_configuration amc set amc.menu_display_name ='Customs Report' where amc.menu_id='RPT-D240';
update amc_app_menu_configuration amc set amc.menu_display_name ='Feed Consumption Report' where amc.menu_id='RPT-D256';
update amc_app_menu_configuration amc set amc.menu_display_name ='Contract Status Report' where amc.menu_id='RPT-D260';
update amc_app_menu_configuration amc set amc.menu_display_name ='FX Position and P&L Report"' where amc.menu_id='RPT-D521';
update amc_app_menu_configuration amc set amc.menu_display_name ='Monthly FX Position and P&L Report' where amc.menu_id='RPT-D531';

commit;
set define on;
