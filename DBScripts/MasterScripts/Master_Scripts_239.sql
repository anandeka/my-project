SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID,REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values ('246', '11', 'PremiumPositionReport.rpt', 'Premium Position Report', NULL,NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION  (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED,ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID,IS_DELETED)
 Values ('RPT-D2464', 'Premium Position Report', 29, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=246&ReportName=PremiumPositionReport.rpt&ExportFormat=HTML', NULL, 'RPT-D21', NULL, 'Reports', NULL,'N'); 
Insert into RFC_REPORT_FILTER_CONFIG (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER,LABEL,FIELD_ID, COLSPAN, IS_MANDATORY)
 Values ('EKA', '246', 'RFC246PHY01', 1, 1,'Product', 'GFF1011', 1, NULL);
Insert into RFC_REPORT_FILTER_CONFIG (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER,LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values ('EKA', '246', 'RFC246PHY02', 1, 2,'CCY', 'GFF1011', 1, NULL);
INSERT INTO rpc_rf_parameter_config  (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES ('EKA', '246', 'RFC246PHY01', 'RFP1045','allProducts');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name )
     VALUES ('EKA', '246', 'RFC246PHY01', 'RFP1046','Product');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES ('EKA', '246', 'RFC246PHY01', 'RFP1047','No');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES ('EKA', '246', 'RFC246PHY01', 'RFP1048','Filter');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES ('EKA', '246', 'RFC246PHY01', 'RFP1049','reportForm');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES ('EKA', '246', 'RFC246PHY01', 'RFP1050','1');
 Insert into RFC_REPORT_FILTER_CONFIG (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER,LABEL,FIELD_ID, COLSPAN, IS_MANDATORY)
 Values ('LDE', '246', 'RFC246PHY01', 1, 1,'Product', 'GFF1011', 1, NULL);
Insert into RFC_REPORT_FILTER_CONFIG (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER,LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values ('LDE', '246', 'RFC246PHY02', 1, 2,'CCY', 'GFF1011', 1, NULL);
INSERT INTO rpc_rf_parameter_config  (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES ('LDE', '246', 'RFC246PHY01', 'RFP1045','allProducts');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name )
     VALUES ('LDE', '246', 'RFC246PHY01', 'RFP1046','Product');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES ('LDE', '246', 'RFC246PHY01', 'RFP1047','No');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES ('LDE', '246', 'RFC246PHY01', 'RFP1048','Filter');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES ('LDE', '246', 'RFC246PHY01', 'RFP1049','reportForm');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES ('LDE', '246', 'RFC246PHY01', 'RFP1050','1');
COMMIT;    