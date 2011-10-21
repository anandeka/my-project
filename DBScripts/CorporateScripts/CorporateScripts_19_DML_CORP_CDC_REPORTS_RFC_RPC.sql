SET DEFINE OFF;
delete from rpc_rf_parameter_config rpc where rpc.report_id in('51','051','101');
delete from rfc_report_filter_config rfc where rfc.report_id in('51','051','101');
COMMIT;
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '101', 'RFC101CDC01', 1,1, 'EOD Date', 'GFF021', 1, 'Y');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '101', 'RFC101CDC02', 1,2, 'Clearer', 'GFF1001', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '101', 'RFC101CDC03', 1,3, 'Exchange', 'GFF1011', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '101', 'RFC101CDC04', 1,4, 'Instrument Type', 'GFF1011', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '101', 'RFC101CDC05', 1,5, 'Trade Date', 'GFF021', 1, 'N');
commit;
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC01', 'RFP0104','SYSTEM');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC01', 'RFP0026','AsOfDate');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC02', 'RFP1001','businesspartner');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC02', 'RFP1002','ClearerName');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC02', 'RFP1003','No');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC02', 'RFP1004','Filter');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC02', 'RFP1005','reportForm');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC02', 'RFP1006','1');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC02', 'RFP1008','EXCHANGECLEARER,FUTURESBROKER');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC03', 'RFP1045','exchangelist');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC03', 'RFP1046','Exchange');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC03', 'RFP1047','No');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC03', 'RFP1048','Filter');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC03', 'RFP1049','reportForm');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC03', 'RFP1050','1');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC04', 'RFP1046','InstrumentType');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC04', 'RFP1047','No');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC04', 'RFP1045','setupInstrumentType');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC04', 'RFP1048','Filter');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC04', 'RFP1049','reportForm');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC04', 'RFP1050','1');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC04', 'RFP1051','multiple');


INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC05', 'RFP0026','AsOfDate');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '101', 'RFC101CDC05', 'RFP0104','SYSTEM');
----------------------------------------------


INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '051', 'RFC51CDC01', 1,1, 'EOD Date', 'GFF021', 1, 'Y');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '051', 'RFC51CDC02', 1,2, 'Future Contract ', 'GFF1001', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '051', 'RFC51CDC03', 1,3, 'Clearer', 'GFF1001', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '051', 'RFC51CDC04', 1,4, 'Section', 'GFF1011', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '051', 'RFC51CDC05', 1,5, 'Trade Date', 'GFF021', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('EKA', '051', 'RFC51CDC06', 1,6, 'Derivative Ref No', 'GFF10206', 1, 'N');
commit;

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC01', 'RFP0104','SYSTEM');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC01', 'RFP0026','AsOfDate');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC02', 'RFP1001','setupUnderlyingInstrument');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC02', 'RFP1002','FutureContract');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC02', 'RFP1003','No');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC02', 'RFP1004','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC02', 'RFP1005','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC02', 'RFP1006','1');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC02', 'RFP1007','multiple');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC03', 'RFP1001','businesspartner');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC03', 'RFP1002','ClearerName');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC03', 'RFP1003','No');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC03', 'RFP1004','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC03', 'RFP1005','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC03', 'RFP1006','1');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC03', 'RFP1008','EXCHANGECLEARER,FUTURESBROKER');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC04', 'RFP1045','setupInstrumentType');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC04', 'RFP1046','InstrumentType');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC04', 'RFP1047','No');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC04', 'RFP1048','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC04', 'RFP1049','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC04', 'RFP1050','1');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC04', 'RFP1051','multiple');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC05', 'RFP0104','SYSTEM');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC05', 'RFP0026','TradeDate');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('EKA', '051', 'RFC51CDC06', 'RFP100533','DerivativeRefNo');

COMMIT ;

-----LDE CORPORATE
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '101', 'RFC101CDC01', 1,1, 'EOD Date', 'GFF021', 1, 'Y');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '101', 'RFC101CDC02', 1,2, 'Clearer', 'GFF1001', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '101', 'RFC101CDC03', 1,3, 'Exchange', 'GFF1011', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '101', 'RFC101CDC04', 1,4, 'Instrument Type', 'GFF1011', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '101', 'RFC101CDC05', 1,5, 'Trade Date', 'GFF021', 1, 'N');
commit;
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC01', 'RFP0104','SYSTEM');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC01', 'RFP0026','AsOfDate');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC02', 'RFP1001','businesspartner');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC02', 'RFP1002','ClearerName');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC02', 'RFP1003','No');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC02', 'RFP1004','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC02', 'RFP1005','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC02', 'RFP1006','1');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC02', 'RFP1008','EXCHANGECLEARER,FUTURESBROKER');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC03', 'RFP1045','exchangelist');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC03', 'RFP1046','Exchange');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC03', 'RFP1047','No');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC03', 'RFP1048','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC03', 'RFP1049','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC03', 'RFP1050','1');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC04', 'RFP1046','InstrumentType');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC04', 'RFP1047','No');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC04', 'RFP1045','setupInstrumentType');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC04', 'RFP1048','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC04', 'RFP1049','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC04', 'RFP1050','1');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC04', 'RFP1051','multiple');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC05', 'RFP0026','AsOfDate');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '101', 'RFC101CDC05', 'RFP0104','SYSTEM');
----------------------------------------------


INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '051', 'RFC51CDC01', 1,1, 'EOD Date', 'GFF021', 1, 'Y');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '051', 'RFC51CDC02', 1,2, 'Future Contract ', 'GFF1001', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '051', 'RFC51CDC03', 1,3, 'Clearer', 'GFF1001', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '051', 'RFC51CDC04', 1,4, 'Section', 'GFF1011', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '051', 'RFC51CDC05', 1,5, 'Trade Date', 'GFF021', 1, 'N');
INSERT INTO rfc_report_filter_config(corporate_id, report_id, label_id, label_column_number,label_row_number, label, field_id, colspan, is_mandatory)
VALUES ('LDE', '051', 'RFC51CDC06', 1,6, 'Derivative Ref No', 'GFF10206', 1, 'N');
commit;

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC01', 'RFP0104','SYSTEM');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC01', 'RFP0026','AsOfDate');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC02', 'RFP1001','setupUnderlyingInstrument');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC02', 'RFP1002','FutureContract');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC02', 'RFP1003','No');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC02', 'RFP1004','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC02', 'RFP1005','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC02', 'RFP1006','1');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC02', 'RFP1007','multiple');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC03', 'RFP1001','businesspartner');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC03', 'RFP1002','ClearerName');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC03', 'RFP1003','No');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC03', 'RFP1004','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC03', 'RFP1005','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC03', 'RFP1006','1');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC03', 'RFP1008','EXCHANGECLEARER,FUTURESBROKER');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC04', 'RFP1046','InstrumentType');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC04', 'RFP1047','No');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC04', 'RFP1045','setupInstrumentType');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC04', 'RFP1048','Filter');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC04', 'RFP1049','reportForm');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC04', 'RFP1050','1');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC04', 'RFP1051','multiple');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC05', 'RFP0104','SYSTEM');
INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC05', 'RFP0026','TradeDate');

INSERT INTO rpc_rf_parameter_config(corporate_id, report_id, label_id, parameter_id,report_parameter_name)
VALUES ('LDE', '051', 'RFC51CDC06', 'RFP100533','DerivativeRefNo');