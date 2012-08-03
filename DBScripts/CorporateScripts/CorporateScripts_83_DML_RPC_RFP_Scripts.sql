delete from rpc_rf_parameter_config rpc where rpc.report_id = 258;
delete from rfc_report_filter_config rfc where rfc.report_id = 258;
commit;
SET DEFINE OFF;
begin
for cc in (select  akc.corporate_id  from ak_corporate akc where akc.is_active = 'Y' and akc.is_internal_corporate = 'N')
loop
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '258', 'RFC258PHY01', 1, 1, 
    'EOD Date', 'GFF021', 1, 'Y');

Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '258', 'RFC258PHY01', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '258', 'RFC258PHY01', 'RFP0026', 'AsOfDate');

end loop;
commit;
end;
