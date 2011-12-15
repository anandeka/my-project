DELETE FROM rpc_rf_parameter_config
      WHERE report_id IN ('225', '226', '227', '228');
DELETE FROM rfc_report_filter_config
      WHERE report_id IN ('225', '226', '227', '228');
delete from REF_REPORTEXPORTFORMAT reff where  report_id IN ('225', '226', '227', '228');
DELETE FROM rml_report_master_list
      WHERE report_id IN ('225', '226', '227', '228');
DELETE FROM amc_app_menu_configuration
      WHERE menu_id IN ('RPT-D23', 'RPT-D231', 'RPT-D232', 'RPT-D233', 'RPT-D234');
COMMIT;
SET DEFINE OFF;
INSERT INTO rml_report_master_list
            (report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('225', '31', 'MonthlyOpenUnrealizedPhysicalPnL.rpt','Monthly Open Unrealized Physical PnL', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
            (report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('226', '31', 'MonthlyOpenUnrealizedPhysicalConc.rpt','Monthly Open Unrealized Physical Conc', NULL, NULL, NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
            (report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('227', '31', 'MonthlyInventoryUnrealizedPhysicalPnL.rpt','Monthly Inventory Unrealized Physical PnL', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO rml_report_master_list
            (report_id, section_id, report_file_name,report_display_name, FEATURE_ID, report_display_name_de,report_display_name_es, action_method, report_type, is_active)
VALUES ('228', '31', 'MonthlyInventoryUnrealizedPhysicalPnLConc.rpt','Monthly Inventory Unrealized Physical PnL Conc', NULL, NULL,NULL, 'populateFilter', 'EOD', 'Y');
INSERT INTO amc_app_menu_configuration
   (menu_id, menu_display_name, display_seq_no, menu_level_no,link_called, icon_class, menu_parent_id, acl_id, tab_id,FEATURE_ID)
   VALUES ('RPT-D23', 'EOM', 13, 3,NULL, NULL, 'RPT-D2', NULL, 'Reports',NULL);

INSERT INTO amc_app_menu_configuration
   (menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
   VALUES ('RPT-D231', 'Monthly Open Unrealized Physical PnL', 11, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=225&ReportName=MonthlyOpenUnrealizedPhysicalPnL.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D23', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
   (menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
   VALUES ('RPT-D232', 'Monthly Open Unrealized Physical Conc', 12, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=226&ReportName=MonthlyOpenUnrealizedPhysicalConc.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D23', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
   (menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
   VALUES ('RPT-D233', 'Monthly Inventory Unrealized Physical PnL', 13, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=227&ReportName=MonthlyInventoryUnrealizedPhysicalPnL.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D23', NULL, 'Reports', NULL);
INSERT INTO amc_app_menu_configuration
   (menu_id, menu_display_name, display_seq_no, menu_level_no,link_called,icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID)
     VALUES ('RPT-D234', 'Monthly Inventory Unrealized Physical PnL Conc', 14, 4,'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=228&ReportName=MonthlyInventoryUnrealizedPhysicalPnLConc.rpt&ExportFormat=HTML&isEodReport=Y',NULL, 'RPT-D23', NULL, 'Reports', NULL);
COMMIT;