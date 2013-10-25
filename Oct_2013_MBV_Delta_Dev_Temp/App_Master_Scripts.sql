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
    set amc.menu_display_name = 'Open Derivative Valuation Report',
        amc.link_called       = '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=369&ReportName=OpenDerivativeValuationReport.rpt&ExportFormat=HTML&isEodReport=Y'
  where amc.menu_id = 'RPT-D369';
 
 update rml_report_master_list rml
    set rml.report_file_name    = 'OpenDerivativeValuationReport.rpt',
        rml.report_display_name = 'Open Derivative Valuation Report'
  where rml.report_id = '369';

 update amc_app_menu_configuration amc
   set amc.menu_display_name = 'Weighted Averages Physical Pricings Report',
   amc.link_called       = '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=374&ReportName=WeightedAveragesPhysicalPricingsReport.rpt&ExportFormat=HTML&isEodReport=Y'
 where amc.menu_id = 'RPT-D374';

update rml_report_master_list rml
   set rml.report_file_name    = 'WeightedAveragesPhysicalPricingsReport.rpt',
       rml.report_display_name = 'Weighted Averages Physical Pricings Report'
 where rml.report_id = '374';

UPDATE REF_REPORTEXPORTFORMAT REF
SET REF.REPORT_FILE_NAME ='WeightedAveragesPhysicalPricingsReport_Excel.rpt'
WHERE REPORT_ID = '374';

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D400', 'Derivative Realized PnL Report', 98, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=400&ReportName=DerivativeRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D24', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('400', '31', 'DerivativeRealizedPnLReport.rpt', 'Derivative Realized PnL Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');
COMMIT;