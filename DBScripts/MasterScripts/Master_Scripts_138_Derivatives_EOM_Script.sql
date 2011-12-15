DELETE FROM rpc_rf_parameter_config
      WHERE report_id IN ('221','222','229','230','231','232','233');
DELETE FROM rfc_report_filter_config
      WHERE report_id IN ('221','222','229','230','231','232','233');
delete from REF_REPORTEXPORTFORMAT reff where  report_id IN ('221','222','229','230','231','232','233');     
DELETE FROM rml_report_master_list
      WHERE report_id IN ('221','222','229','230','231','232','233');
DELETE FROM amc_app_menu_configuration
      WHERE menu_id IN ('RPT-D43', 'RPT-D431', 'RPT-D432', 'RPT-D433', 'RPT-D434','RPT-D435','RPT-D436','RPT-D437');
COMMIT;
DELETE FROM rpc_rf_parameter_config rpc  WHERE rpc.report_id IN ('223', '224');
DELETE FROM rfc_report_filter_config rfc WHERE rfc.report_id IN ('223', '224');
COMMIT ;
SET DEFINE OFF;
INSERT INTO rml_report_master_list
(report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('221', '93', 'MonthlyDerivativesUnRealizedPnLReport.rpt','Monthly Derivatives UnRealized P&L Report', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
(report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('222', '93', 'MonthlyDerivativesRealizedPnLReport.rpt','Monthly Derivatives Realized P&L Report', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
(report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('229', '93', 'MonthlyClearerSummaryReport.rpt','Monthly Clearer Summary Report', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
(report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('230', '93', 'MonthlyFutureOptionSummaryPositionReport.rpt','Monthly Future Option Summary Position Report', NULL, NULL, NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
(report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('231', '93', 'MonthlyClearerStatementReport.rpt','Monthly Clearer Statement Report', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
(report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('232', '93', 'MonthlyMarginReport.rpt','Monthly Margin Report', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
(report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('233', '93', 'MonthlyUpcomingOptionExpiryReport.rpt','Monthly Upcoming Option Expiry Report', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO amc_app_menu_configuration
(menu_id, menu_display_name, display_seq_no, menu_level_no,link_called, icon_class, menu_parent_id, acl_id, tab_id,FEATURE_ID)
VALUES ('RPT-D43', 'EOM', 13, 3,NULL, NULL, 'RPT-D4', NULL, 'Reports',NULL);
INSERT INTO amc_app_menu_configuration
(menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
VALUES ('RPT-D431', 'Monthly Derivatives UnRealized P&L Report', 11, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=221&ReportName=MonthlyDerivativesUnRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D43', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
(menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
VALUES ('RPT-D432', 'Monthly Derivatives Realized P&L Report', 12, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=222&ReportName=MonthlyDerivativesRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D43', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
(menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
VALUES ('RPT-D435', 'Monthly Clearer Statement Report', 13, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=231&ReportName=MonthlyClearerStatementReport.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D43', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
(menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
VALUES ('RPT-D433', 'Monthly Clearer Summary Report', 14, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=229&ReportName=MonthlyClearerSummaryReport.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D43', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
(menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
VALUES ('RPT-D434', 'Monthly Future Option Summary Position Report', 15, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=230&ReportName=MonthlyFutureOptionSummaryPositionReport.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D43', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
(menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
VALUES ('RPT-D436', 'Monthly Margin Report', 16, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=232&ReportName=MonthlyMarginReport.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D43', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
(menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
VALUES ('RPT-D437', 'Monthly Upcoming Option Expiry Report', 17, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=233&ReportName=MonthlyUpcomingOptionExpiryReport.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D43', NULL, 'Reports', NULL);
COMMIT;
