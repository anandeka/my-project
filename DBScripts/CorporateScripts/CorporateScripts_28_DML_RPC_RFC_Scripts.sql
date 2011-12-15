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
     (cc.corporate_id, '234', 'RFC234PHY01', 1, 1, 
      'Profit Center', 'GFF1011', 1, 'N');
  Insert into RFC_REPORT_FILTER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
      LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
   Values
     (cc.corporate_id, '234', 'RFC234PHY02', 1, 2, 
      'Product', 'GFF1011', 1, 'Y');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY01', 'RFP1045', 'reportProfitcenterList');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY01', 'RFP1046', 'ProfitCenter');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY01', 'RFP1047', 'No');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY01', 'RFP1048', 'Filter');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY01', 'RFP1049', 'reportForm');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY01', 'RFP1050', '1');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY01', 'RFP1051', 'multiple');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY02', 'RFP1045', 'allProducts');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY02', 'RFP1046', 'Product');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY02', 'RFP1047', 'No');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY02', 'RFP1048', 'Filter');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY02', 'RFP1049', 'reportForm');
  Insert into RPC_RF_PARAMETER_CONFIG
     (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
   Values
     (cc.corporate_id, '234', 'RFC234PHY02', 'RFP1050', '1');
  COMMIT;
  end loop;
commit;
end;