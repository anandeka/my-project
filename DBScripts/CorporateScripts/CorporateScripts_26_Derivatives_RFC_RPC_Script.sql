SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
    dbms_output.put_line(cc.corporate_id);
INSERT INTO rfc_report_filter_config (corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES (cc.corporate_id, '223', 'RFC-CDC-2231', 1,1, 'EOM Month', 'GFF1012', 1, 'Y');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES (cc.corporate_id, '223', 'RFC-CDC-2232', 1,2, 'EOM Year', 'GFF1012', 1, 'Y');
INSERT INTO rfc_report_filter_config (corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES (cc.corporate_id, '223', 'RFC-CDC-2233', 1,3, 'Profit Center', 'GFF1011', 1, 'N');
INSERT INTO rfc_report_filter_config (corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES (cc.corporate_id, '224', 'RFC-CDC-2241', 1,1, 'EOM Month', 'GFF1012', 1, 'Y');
INSERT INTO rfc_report_filter_config (corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES (cc.corporate_id, '224', 'RFC-CDC-2242', 1,2, 'EOM Year', 'GFF1012', 1, 'Y');
INSERT INTO rfc_report_filter_config (corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES (cc.corporate_id, '224', 'RFC-CDC-2243', 1,3, 'Profit Center', 'GFF1011', 1, 'N');
---RPC 
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2231', 'RFP1061','Month');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2231', 'RFP1060', 'MonthList');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2231', 'RFP1062','Yes');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2231', 'RFP1063','Filter');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2231', 'RFP1064','reportForm');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2231', 'RFP1065','1');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2231', 'RFP1066','Yes');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2232', 'RFP1060','yearList');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2232', 'RFP1062','Yes' );
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2232', 'RFP1063','Filter');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2232', 'RFP1064','reportForm');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2232', 'RFP1065', '1');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2232', 'RFP1066', 'Yes');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2232', 'RFP1061','Year');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2233', 'RFP1045','reportProfitcenterList');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2233', 'RFP1046','Book');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2233', 'RFP1047','No');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2233', 'RFP1048','Filter');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2233', 'RFP1049','reportForm');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2233', 'RFP1050','1');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '223', 'RFC-CDC-2233', 'RFP1051','multiple');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2241', 'RFP1061', 'Month' );
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2241', 'RFP1060', 'MonthList');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2241', 'RFP1062','Yes');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2241', 'RFP1063', 'Filter');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2241', 'RFP1064','reportForm');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2241', 'RFP1065','1');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2241', 'RFP1066','Yes');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2242', 'RFP1060','yearList');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2242', 'RFP1062', 'Yes');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2242', 'RFP1063','Filter' );
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2242', 'RFP1064','reportForm' );
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2242', 'RFP1065','1');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2242', 'RFP1066', 'Yes' );
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2242', 'RFP1061','Year' );
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2243', 'RFP1045','reportProfitcenterList');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2243', 'RFP1046','Book');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2243', 'RFP1047','No' );
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2243', 'RFP1048','Filter');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id,report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2243', 'RFP1049','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2243', 'RFP1050', '1');
INSERT INTO rpc_rf_parameter_config (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
     VALUES (cc.corporate_id, '224', 'RFC-CDC-2243', 'RFP1051','multiple');
COMMIT;
  end loop;
commit;
end;