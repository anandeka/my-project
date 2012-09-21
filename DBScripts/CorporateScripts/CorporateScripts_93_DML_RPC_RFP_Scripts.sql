delete from rpc_rf_parameter_config rpc where rpc.label_id in ('RFC236PHY03','RFC237PHY01','RFC237PHY02');
delete from rfc_report_filter_config rfc where rfc.label_id in ('RFC236PHY03','RFC237PHY01','RFC237PHY02');
update rfc_report_filter_config rfc
set rfc.label = 'Vessel Name'
where rfc.label_id = 'RFC237PHY07';
update rpc_rf_parameter_config rpc
set rpc.report_parameter_name =  'VesselName'
where rpc.label_id = 'RFC237PHY07';
commit;
SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
loop
    dbms_output.put_line(cc.corporate_id);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 1, 3, 
    'Warehouse Location', 'GFF1011', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1052', 'WAREHOUSING');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1045', 'warehouseshed');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1046', 'WareHouse');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY03', 'RFP1051', 'multiple');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '237', 'RFC237PHY01', 1, 1, 
    'Landing Date From', 'GFF021', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '237', 'RFC237PHY02', 1, 2, 
    'Landing Date To', 'GFF021', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '237', 'RFC237PHY01', 'RFP0026', 'LandingDateFrom');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '237', 'RFC237PHY01', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '237', 'RFC237PHY02', 'RFP0026', 'LandingDateTo');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '237', 'RFC237PHY02', 'RFP0104', 'SYSTEM');
COMMIT;
  end loop;
commit;
end;
