-- This file contains data correction for Metals report,CDC package ref generator
-- Created on 12/26/2012 by SIVACHALABATHI 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
delete from rpc_rf_parameter_config rpc where rpc.report_id in (212, 257, 260);
delete from rfc_report_filter_config rfc where rfc.report_id in (212, 257, 260);
commit;
for cc in (select akc.corporate_id from ak_corporate akc where akc.is_internal_corporate = 'N')loop

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '212', 'RFC212PHY02', 1, 1, 'Profit Center', 'GFF1011', 1, 'N');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '212', 'RFC212PHY03', 1, 2, 'Quality', 'GFF1011', 1, '');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '212', 'RFC212PHY04', 1, 3, 'INCOTerm', 'GFF1011', 1, '');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '212', 'RFC212PHY05', 1, 4, 'Country', 'GFF1015', 1, '');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '212', 'RFC212PHY06', 1, 5, 'ProductType', 'GFF1011', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '212', 'RFC212PHY07', 1, 6, 'IncludeComposite', 'GFF1012', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '212', 'RFC212PHY08', 1, 7, 'Product', 'GFF1011', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '212', 'RFC212PHY09', 1, 8, 'Corporate', 'GFF1011', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '257', 'RFC257PHY01', 1, 1, 'Year', 'GFF1012', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '257', 'RFC257PHY02', 1, 2, 'Month', 'GFF1012', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '257', 'RFC257PHY03', 1, 3, 'Smelter', 'GFF1001', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '257', 'RFC257PHY04', 1, 5, 'Report Type', 'GFF1012', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '257', 'RFC257PHY05', 1, 6, 'Product', 'GFF1011', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '257', 'RFC257PHY06', 1, 7, 'Quality', 'GFF1011', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '257', 'RFC257PHY08', 1, 4, 'Report Data', 'GFF1012', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '260', 'RFC260PHY01', 1, 1, 'Year', 'GFF1012', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '260', 'RFC260PHY02', 1, 2, 'Month', 'GFF1012', 1, 'Y');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '260', 'RFC260PHY03', 1, 3, 'Counter Party', 'GFF1001', 1, 'N');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '260', 'RFC260PHY04', 1, 4, 'Invoice Pay-in Currency', 'GFF1011', 1, 'N');

insert into rfc_report_filter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
values (cc.corporate_id, '260', 'RFC260PHY05', 1, 5, 'Contract Ref No', 'GFF10206', 1, 'N');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1045', 'reportProfitcenterList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1046', 'ProfitCenter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1051', 'multiple');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1053', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY03', 'RFP1045', 'quality');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY03', 'RFP1046', 'Quality');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY03', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY03', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY03', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY03', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY04', 'RFP1045', 'incoterm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY04', 'RFP1046', 'INCOTerm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY04', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY04', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY04', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY04', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1128', 'countrycity');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1129', 'Country');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1130', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1131', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1132', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1133', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1134', 'City');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1135', '2');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1136', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY05', 'RFP1137', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY06', 'RFP1045', 'productTypeList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY06', 'RFP1046', 'ProductType');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY06', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY06', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY06', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY06', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY07', 'RFP1060', 'Revocable');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY07', 'RFP1061', 'IncludeComposite');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY07', 'RFP1062', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY07', 'RFP1063', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY07', 'RFP1064', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY07', 'RFP1065', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY07', 'RFP1066', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY08', 'RFP1045', 'allProducts');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY08', 'RFP1046', 'Product');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY08', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY08', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY08', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY08', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY09', 'RFP1045', 'corporateList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY09', 'RFP1046', 'CorpID');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY09', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY09', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY09', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY09', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY09', 'RFP1051', 'multiple');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '212', 'RFC212PHY09', 'RFP1053', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1060', 'yearList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1061', 'Year');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1062', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1063', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1064', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1065', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1066', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1060', 'MonthList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1061', 'Month');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1062', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1063', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1064', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1065', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1066', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1001', 'businesspartner');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1002', 'Arrival');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1003', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1004', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1005', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1006', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1008', 'WAREHOUSING');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1060', 'reportList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1061', 'ReportType');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1062', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1063', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1064', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1065', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1066', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1045', 'allProducts');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1046', 'Product');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1051', 'multiple');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1045', 'quality');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1046', 'Quality');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1051', 'multiple');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1060', 'ReportDataList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1061', 'ReportData');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1062', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1063', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1064', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1065', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1066', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY01', 'RFP1060', 'yearList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY01', 'RFP1061', 'Year');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY01', 'RFP1062', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY01', 'RFP1063', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY01', 'RFP1064', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY01', 'RFP1065', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY01', 'RFP1066', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY02', 'RFP1060', 'MonthList');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY02', 'RFP1061', 'Month');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY02', 'RFP1062', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY02', 'RFP1063', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY02', 'RFP1064', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY02', 'RFP1065', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY02', 'RFP1066', 'Yes');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY03', 'RFP1001', 'businesspartner');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY03', 'RFP1002', 'CounterParty');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY03', 'RFP1003', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY03', 'RFP1004', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY03', 'RFP1005', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY03', 'RFP1006', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY03', 'RFP1008', 'BUYER,SELLER');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY04', 'RFP1045', 'currencylist');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY04', 'RFP1046', 'InvoicePayInCurrency');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY04', 'RFP1047', 'No');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY04', 'RFP1048', 'Filter');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY04', 'RFP1049', 'reportForm');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY04', 'RFP1050', '1');

insert into rpc_rf_parameter_config (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
values (cc.corporate_id, '260', 'RFC260PHY05', 'RFP100533', 'ContractRefNo');
end loop;
commit;
  
end;
/
declare
begin
  for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
    dbms_output.put_line(cc.corporate_id);
    update arf_action_ref_number_format arf
       set arf.is_deleted = 'Y'
     where arf.action_ref_number_format_id =
           'ARF-GUF-1-' || cc.corporate_id;
    update arf_action_ref_number_format arf
       set arf.is_deleted = 'Y'
     where arf.action_ref_number_format_id =
           'ARF-GUF-2-' || cc.corporate_id;
    update arf_action_ref_number_format arf
       set arf.is_deleted = 'Y'
     where arf.action_ref_number_format_id =
           'ARF-GUF-3-' || cc.corporate_id;
    update arf_action_ref_number_format arf
       set arf.is_deleted = 'Y'
     where arf.action_ref_number_format_id =
           'ARF-GUF-4-' || cc.corporate_id;
    update arf_action_ref_number_format arf
       set arf.is_deleted = 'Y'
     where arf.action_ref_number_format_id =
           'ARF-GUF-5-' || cc.corporate_id;
  end loop;
end;
/
CREATE OR REPLACE PACKAGE "PKG_REFERENCE_NO_GENERATOR" IS
  pvn_ref_no_length NUMBER := 30;

  -- Maximum allowance length for reference number
  PROCEDURE sp_action_formatted_id(pc_corporate_id     VARCHAR2,
                                   pc_action_id        VARCHAR2,
                                   pc_reference_no     VARCHAR2,
                                   pc_prefix           OUT VARCHAR2,
                                   pc_middle_no        OUT VARCHAR2,
                                   pc_suffix           OUT VARCHAR2,
                                   pc_auto_generate_id OUT VARCHAR2);

  PROCEDURE sp_document_formatted_id(pc_corporate_id     VARCHAR2,
                                     pc_doc_id           VARCHAR2,
                                     pc_reference_no     VARCHAR2,
                                     pc_prefix           OUT VARCHAR2,
                                     pc_middle_no        OUT VARCHAR2,
                                     pc_suffix           OUT VARCHAR2,
                                     pc_auto_generate_id OUT VARCHAR2);

  FUNCTION f_get_general_reference_no(pc_external_ref_no_key VARCHAR2,
                                      pc_corporate_id        VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION f_gen_internal_sequence_number(pc_int_ref_key VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION f_get_seq_no_without_prefix(pc_int_ref_key VARCHAR2)
    RETURN VARCHAR2;
END; 
/
CREATE OR REPLACE PACKAGE BODY "PKG_REFERENCE_NO_GENERATOR" IS
  PROCEDURE sp_action_formatted_id
  /**************************************************************************************************
    Function Name                       : sp_action_formatted_id
    Author                              : Janna
    Created Date                        : 19th Aug 2008
    Purpose                             : Generate Reference Number for Actions
    
    Parameters                          :
    
    pc_corporate_id                     : Corporate ID
    pc_action_id                        : Action ID
    pc_reference_no                     : Reference Number if the user has keyed in for validation
                                          If this is already exists in database error will be thrown else
                                          the same number will be passed back to the user
    
    
    Returns                             :
    
    pc_prefix                           : Prefix if available
    pc_middle_no                        : Middle Number
    pc_suffix                           : Suffix if available
    pc_auto_generate_id                 : New auto generated ID if Reference Number was not passed
    
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id     VARCHAR2,
   pc_action_id        VARCHAR2,
   pc_reference_no     VARCHAR2,
   pc_prefix           OUT VARCHAR2,
   pc_middle_no        OUT VARCHAR2,
   pc_suffix           OUT VARCHAR2,
   pc_auto_generate_id OUT VARCHAR2) IS
    excep_ref_no_alreasy_exists EXCEPTION;
    excep_ref_no_length_exceeded EXCEPTION;
    vc_action_key_id    VARCHAR2(15);
    vc_validation_query VARCHAR2(500);
    vn_record_count     NUMBER;
  
    vc_continuous_middle_no_req char(1) := 'Y';
  
  BEGIN
  
    select axm.is_continuous_middle_no_req
      into vc_continuous_middle_no_req
      from axm_action_master axm
      where axm.action_id=pc_action_id;
  
    -- Get the Action Key ID for the given Action ID
    SELECT arfm.action_key_id
      INTO vc_action_key_id
      FROM arfm_action_ref_no_mapping arfm
     WHERE arfm.corporate_id = pc_corporate_id
       AND arfm.action_id = pc_action_id
       and arfm.is_deleted ='N';
  
    -- Get the Validation Query for the Action Key ID
    SELECT akm.validation_query
      INTO vc_validation_query
      FROM akm_action_ref_key_master akm
     WHERE akm.action_key_id = vc_action_key_id;
  
    -- If refererence number was passed from the user then validate
    -- if reference number exists then raise error
    -- Else pass the same number back as Auto Generated ID
    IF (pc_reference_no IS NOT NULL) THEN
      IF LENGTH(pc_reference_no) > pvn_ref_no_length THEN
        RAISE excep_ref_no_length_exceeded;
      END IF;
    
      -- Execute and check for the result
      EXECUTE IMMEDIATE vc_validation_query
        INTO vn_record_count
        USING pc_reference_no, pc_corporate_id;
    
      -- Throw error as it exist in the database
      IF (vn_record_count > 0) THEN
        RAISE excep_ref_no_alreasy_exists;
      ELSE
        -- Pass the original number as is since it is valid
        pc_auto_generate_id := pc_reference_no;
      END IF;
    ELSE
      -- Generate the new number, If it is existing in database increment the number till
      -- we get a valid one which can be used for the transaction
      -- If the next number(s) is/are used probably because of manual entry
      -- skip the number and get the next number
      LOOP
      
        if (vc_continuous_middle_no_req = 'Y') then
          SELECT arf.prefix || TO_CHAR(arf.middle_no_last_used_value + 1) ||
                 arf.suffix,
                 arf.prefix,
                 arf.middle_no_last_used_value + 1,
                 arf.suffix
            INTO pc_auto_generate_id, pc_prefix, pc_middle_no, pc_suffix
            FROM arf_action_ref_number_format arf
           WHERE arf.action_key_id = vc_action_key_id
             AND arf.corporate_id = pc_corporate_id
             and arf.is_deleted ='N'
             FOR UPDATE;
        else
          SELECT arf.prefix || TO_CHAR(arf.middle_no_last_used_value + 1) ||
                 arf.suffix,
                 arf.prefix,
                 arf.middle_no_last_used_value + 1,
                 arf.suffix
            INTO pc_auto_generate_id, pc_prefix, pc_middle_no, pc_suffix
            FROM arf_action_ref_number_format arf
           WHERE arf.action_key_id = vc_action_key_id
             AND arf.corporate_id = pc_corporate_id
             and arf.is_deleted ='N';
        
        end if;
        DBMS_OUTPUT.put_line(vc_validation_query);
        DBMS_OUTPUT.put_line(pc_auto_generate_id);
        DBMS_OUTPUT.put_line(pc_corporate_id);
      
        EXECUTE IMMEDIATE vc_validation_query
          INTO vn_record_count
          USING pc_auto_generate_id, pc_corporate_id;
      
        -- Update the table with middle number incremented by 1 for the next use
        UPDATE arf_action_ref_number_format arf
           SET arf.middle_no_last_used_value = arf.middle_no_last_used_value + 1
         WHERE arf.action_key_id = vc_action_key_id
           AND arf.corporate_id = pc_corporate_id
           and arf.is_deleted ='N';
      
        EXIT WHEN vn_record_count = 0;
      END LOOP;
    
      IF LENGTH(pc_auto_generate_id) > pvn_ref_no_length THEN
        RAISE excep_ref_no_length_exceeded;
      END IF;
    END IF;
  EXCEPTION
    WHEN excep_ref_no_alreasy_exists THEN
      raise_application_error(-20001,
                              'The reference number ' || pc_reference_no ||
                              ' already exists in the database');
    WHEN excep_ref_no_length_exceeded THEN
      raise_application_error(-20001,
                              'The length of the reference number exceeds ' ||
                              TO_CHAR(pvn_ref_no_length) || 'characters');
  END;

  PROCEDURE sp_document_formatted_id
  /**************************************************************************************************
    Function Name                       : sp_document_formatted_id
    Author                              : Janna
    Created Date                        : 19th Aug 2008
    Purpose                             : Generate Reference Number for Documents
    
    Parameters                          :
    
    pc_corporate_id                     : Corporate ID
    pc_action_id                        : Document ID
    pc_reference_no                     : Reference Number if the user has keyed in for validation
                                          If this is already exists in database error will be thrown else
                                          the same number will be passed back to the user
    
    
    Returns                             :
    
    pc_prefix                           : Prefix if available
    pc_middle_no                        : Middle Number
    pc_suffix                           : Suffix if available
    pc_auto_generate_id                 : New auto generated ID if Reference Number was not passed
    
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id     VARCHAR2,
   pc_doc_id           VARCHAR2,
   pc_reference_no     VARCHAR2,
   pc_prefix           OUT VARCHAR2,
   pc_middle_no        OUT VARCHAR2,
   pc_suffix           OUT VARCHAR2,
   pc_auto_generate_id OUT VARCHAR2) IS
    excep_ref_no_alreasy_exists EXCEPTION;
    excep_ref_no_length_exceeded EXCEPTION;
    vc_doc_key_id       VARCHAR2(15);
    vc_validation_query VARCHAR2(500);
    vn_record_count     NUMBER;
  
    vc_continuous_middle_no_req char(1) := 'Y';
  
  BEGIN
  
    select dm.is_continuous_middle_no_req
      into vc_continuous_middle_no_req
      from dm_document_master dm
      where dm.doc_id=pc_doc_id;
      
    -- Get the Action Key ID for the given Action ID
    SELECT drfm.doc_key_id
      INTO vc_doc_key_id
      FROM drfm_doc_ref_no_mapping drfm
     WHERE drfm.corporate_id = pc_corporate_id
       AND drfm.doc_id = pc_doc_id;
  
    -- Get the Validation Query for the Action Key ID
    SELECT dkm.validation_query
      INTO vc_validation_query
      FROM dkm_doc_ref_key_master dkm
     WHERE dkm.doc_key_id = vc_doc_key_id;
  
    -- If refererence number was passed from the user then validate
    -- if reference number exists then raise error
    -- Else pass the same number back as Auto Generated ID
    IF (pc_reference_no IS NOT NULL) THEN
      IF LENGTH(pc_reference_no) > pvn_ref_no_length THEN
        RAISE excep_ref_no_length_exceeded;
      END IF;
    
      -- Execute and check for the result
      EXECUTE IMMEDIATE vc_validation_query
        INTO vn_record_count
        USING pc_reference_no, pc_corporate_id;
    
      -- Throw error as it exist in the database
      IF (vn_record_count > 0) THEN
        RAISE excep_ref_no_alreasy_exists;
      ELSE
        -- Pass the original number as is since it is valid
        pc_auto_generate_id := pc_reference_no;
      END IF;
    ELSE
      -- Generate the new number, If it is existing in database increment the number till
      -- we get a valid one which can be used for the transaction
      -- If the next number(s) is/are used probably because of manual entry
      -- skip the number and get the next number
      LOOP
      
        if (vc_continuous_middle_no_req = 'Y') then
          SELECT drf.prefix || TO_CHAR(drf.middle_no_last_used_value + 1) ||
                 drf.suffix,
                 drf.prefix,
                 drf.middle_no_last_used_value + 1,
                 drf.suffix
            INTO pc_auto_generate_id, pc_prefix, pc_middle_no, pc_suffix
            FROM drf_doc_ref_number_format drf
           WHERE drf.doc_key_id = vc_doc_key_id
             AND drf.corporate_id = pc_corporate_id
             FOR UPDATE;
        else
          SELECT drf.prefix || TO_CHAR(drf.middle_no_last_used_value + 1) ||
                 drf.suffix,
                 drf.prefix,
                 drf.middle_no_last_used_value + 1,
                 drf.suffix
            INTO pc_auto_generate_id, pc_prefix, pc_middle_no, pc_suffix
            FROM drf_doc_ref_number_format drf
           WHERE drf.doc_key_id = vc_doc_key_id
             AND drf.corporate_id = pc_corporate_id;
        
        end if;
      
        EXECUTE IMMEDIATE vc_validation_query
          INTO vn_record_count
          USING pc_auto_generate_id, pc_corporate_id;
      
        -- Update the table with middle number incremented by 1 for the next use
        UPDATE drf_doc_ref_number_format drf
           SET drf.middle_no_last_used_value = drf.middle_no_last_used_value + 1
         WHERE drf.doc_key_id = vc_doc_key_id
           AND drf.corporate_id = pc_corporate_id;
      
        EXIT WHEN vn_record_count = 0;
      END LOOP;
    
      IF LENGTH(pc_auto_generate_id) > pvn_ref_no_length THEN
        RAISE excep_ref_no_length_exceeded;
      END IF;
    END IF;
  EXCEPTION
    WHEN excep_ref_no_alreasy_exists THEN
      raise_application_error(-20001,
                              'The reference number ' || pc_reference_no ||
                              ' already exists in the database');
    WHEN excep_ref_no_length_exceeded THEN
      raise_application_error(-20001,
                              'The length of the reference number exceeds ' ||
                              TO_CHAR(pvn_ref_no_length) || 'characters');
  END;

  FUNCTION f_get_general_reference_no(pc_external_ref_no_key VARCHAR2,
                                      pc_corporate_id        VARCHAR2)
    RETURN VARCHAR2 IS
    /**************************************************************************************************
    Function Name              : F_GET_GENERAL_REFERENCE_NO
    Author                     : Anu K
    Created Date               : 6th Sep 2008
    Purpose                    : Generate reference number creation for a ref no key
    
    Parameters                 : pc_externalRefNoKey,pc_corporateId
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
    vc_external_ref_no          VARCHAR2(30);
    vc_prefix                   VARCHAR2(10);
    vc_middle_no_latest_count   NUMBER(20);
    vc_suffix                   VARCHAR2(10);
    vc_continuous_middle_no_req char(1) := 'Y';
  BEGIN
  
    select erc.is_continuous_middle_no_req
      into vc_continuous_middle_no_req
      from erc_external_ref_no_config erc
     where erc.corporate_id = pc_corporate_id
       and erc.external_ref_no_key = pc_external_ref_no_key;
    if (vc_continuous_middle_no_req = 'Y') then
      SELECT erc.prefix, erc.middle_no_last_used_value, erc.suffix
        INTO vc_prefix, vc_middle_no_latest_count, vc_suffix
        FROM erc_external_ref_no_config erc
       WHERE erc.corporate_id = pc_corporate_id
         AND erc.external_ref_no_key = pc_external_ref_no_key
         FOR UPDATE;
    else
    
      SELECT erc.prefix, erc.middle_no_last_used_value, erc.suffix
        INTO vc_prefix, vc_middle_no_latest_count, vc_suffix
        FROM erc_external_ref_no_config erc
       WHERE erc.corporate_id = pc_corporate_id
         AND erc.external_ref_no_key = pc_external_ref_no_key;
    
    end if;
  
    vc_middle_no_latest_count := vc_middle_no_latest_count + 1;
  
    IF (vc_prefix IS NOT NULL) THEN
      vc_external_ref_no := vc_prefix;
    END IF;
  
    vc_external_ref_no := vc_external_ref_no || vc_middle_no_latest_count;
  
    IF (vc_suffix IS NOT NULL) THEN
      vc_external_ref_no := vc_external_ref_no || vc_suffix;
    END IF;
  
    BEGIN
      UPDATE erc_external_ref_no_config erc1
         SET erc1.middle_no_last_used_value = vc_middle_no_latest_count
       WHERE erc1.external_ref_no_key = pc_external_ref_no_key
         AND erc1.corporate_id = pc_corporate_id;
    END;
  
    RETURN(vc_external_ref_no);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001,
                              'Error in Stored Procedure F_GET_GENERAL_REFERENCE_NO. Error Message is : ' ||
                              SQLERRM);
  END;

  FUNCTION f_gen_internal_sequence_number(pc_int_ref_key VARCHAR2)
    RETURN VARCHAR2 IS
    /**************************************************************************************************
    Function Name              : f_gen_internal_sequence_number
    Author                     : Janna
    Created Date               : 12th Aug 2008
    Purpose                    : Generate Sequence Value for a given ID
    
    Parameters                 : pc_int_ref_key
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
    vc_return   VARCHAR2(50);
    vc_query    VARCHAR2(200);
    vc_prefix   VARCHAR2(30);
    pc_seq_name VARCHAR2(30);
  BEGIN
    BEGIN
      SELECT irc.seq_name, irc.prefix
        INTO pc_seq_name, vc_prefix
        FROM irc_internal_ref_no_config irc
       WHERE irc.internal_ref_no_key = pc_int_ref_key;
    END;
  
    BEGIN
      vc_query := 'SELECT ' || pc_seq_name || '.NEXTVAL from DUAL';
    
      EXECUTE IMMEDIATE vc_query
        INTO vc_return;
    
      vc_return := vc_prefix || '-' || vc_return;
    END;
  
    RETURN(vc_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001,
                              'Error in Stored Procedure f_gen_internal_sequence_number. Error Message is : ' ||
                              SQLERRM);
  END;

  FUNCTION f_get_seq_no_without_prefix(pc_int_ref_key VARCHAR2)
    RETURN VARCHAR2 IS
    /**************************************************************************************************
    Function Name              : f_get_seq_no_without_prefix
    Author                     : Rakesh
    Created Date               : 30th Aug 2012
    Purpose                    : Sequence Value for a given ID without any prefix
    
    Parameters                 : pc_int_ref_key
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
    vc_return VARCHAR2(50);
    vc_query  VARCHAR2(200);
  
    pc_seq_name VARCHAR2(30);
  BEGIN
    BEGIN
      SELECT irc.seq_name
        INTO pc_seq_name
        FROM irc_internal_ref_no_config irc
       WHERE irc.internal_ref_no_key = pc_int_ref_key;
    END;
  
    BEGIN
      vc_query := 'SELECT ' || pc_seq_name || '.NEXTVAL from DUAL';
    
      EXECUTE IMMEDIATE vc_query
        INTO vc_return;
    
    END;
  
    RETURN(vc_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001,
                              'Error in Stored Procedure f_get_seq_no_without_prefix. Error Message is : ' ||
                              SQLERRM);
  END;
END; 
/
