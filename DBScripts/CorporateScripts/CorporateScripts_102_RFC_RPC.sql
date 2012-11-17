delete from rpc_rf_parameter_config rpc where rpc.label_id = 'RFC361CDC09';
delete from rfc_report_filter_config rfc where rfc.label_id = 'RFC361CDC09';
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
   (cc.corporate_id, '361', 'RFC361CDC09', 1, 9, 
    'Currency', 'GFF1011', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '361', 'RFC361CDC09', 'RFP1045', 'currencylist');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '361', 'RFC361CDC09', 'RFP1046', 'Currency');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '361', 'RFC361CDC09', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '361', 'RFC361CDC09', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '361', 'RFC361CDC09', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '361', 'RFC361CDC09', 'RFP1050', '1');
  end loop;
commit;
end;