set define off;
delete from rpc_rf_parameter_config rpc where rpc.report_id='249';
delete from rfc_report_filter_config rfc where rfc.report_id='249';
delete from ref_reportexportformat ref where ref.report_id='249';
delete from amc_app_menu_configuration amc where amc.menu_id='RPT-D2495';
delete from rml_report_master_list rml where rml.report_id='249';
commit;

insert into amc_app_menu_configuration
   (menu_id, menu_display_name, display_seq_no, menu_level_no, link_called, 
    icon_class, menu_parent_id, acl_id, tab_id, feature_id, 
    is_deleted)
 values
   ('RPT-D2495', 'TC RC Distribution Report', 30, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=249&ReportName=TCRCDistributionReport.rpt&ExportFormat=HTML', 
    null, 'RPT-D21', null, 'Reports', null, 
    'N');
insert into rml_report_master_list
   (report_id, section_id, report_file_name, report_display_name, feature_id, 
    report_display_name_de, report_display_name_es, action_method, report_type, is_active)
 values
   ('249', '11', 'TCRCDistributionReport.rpt', 'TC RC Distribution Report', null, 
    null, null, 'populateFilter', 'ONLINE', 'Y');
insert into rfc_report_filter_config
   (corporate_id, report_id, label_id, label_column_number, label_row_number, 
    label, field_id, colspan, is_mandatory)
 values
   ('BLD', '249', 'RFC249PHY03', 1, 3, 
    'Counter Party', 'GFF1001', 1, 'N');
insert into rfc_report_filter_config
   (corporate_id, report_id, label_id, label_column_number, label_row_number, 
    label, field_id, colspan, is_mandatory)
 values
   ('BLD', '249', 'RFC249PHY01', 1, 1, 
    'From Date', 'GFF021', 1, 'Y');
insert into rfc_report_filter_config
   (corporate_id, report_id, label_id, label_column_number, label_row_number, 
    label, field_id, colspan, is_mandatory)
 values
   ('BLD', '249', 'RFC249PHY02', 1, 2, 
    'To Date', 'GFF021', 1, 'Y');

insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY03', 'RFP1001', 'businesspartner');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY03', 'RFP1002', 'CPName');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY03', 'RFP1003', 'No');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY03', 'RFP1004', 'Filter');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY03', 'RFP1005', 'reportForm');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY03', 'RFP1006', '1');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY03', 'RFP1008', 'BUYER,SELLER');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY01', 'RFP0104', 'SYSTEM');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY01', 'RFP0026', 'FromDate');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY02', 'RFP0104', 'SYSTEM');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   ('BLD', '249', 'RFC249PHY02', 'RFP0026', 'ToDate');

insert into ref_reportexportformat
   (report_id, export_format, report_file_name)
 values
   ('249', 'EXCEL', 'TCRCDistributionReport_Excel.rpt');
commit;