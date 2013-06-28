set define off;

Begin
  for rc in 
      (select 
    akc.corporate_id corp_id, akc.corporate_name 
    from ak_corporate akc where akc.is_internal_corporate = 'N')
  loop
  
  ----------------------------------------------------------------------------------------------------------------------------
  
  Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (rc.corp_id, '375', 'RFC375PHY01', 1, 1, 
    'Year', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (rc.corp_id, '375', 'RFC375PHY02', 1, 2, 
    'Month', 'GFF1012', 1, 'Y');

Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (rc.corp_id, '375', 'RFC375PHY03', 1, 3, 
    'Exposure CCY', 'GFF1011', 1, 'Y');


  -----------------------------------------------------------------------------------------------------------------
  

    --Year Filter    
       
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY01', 'RFP1060', 'yearList');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY01', 'RFP1062', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY01', 'RFP1063', 'Filter');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY01', 'RFP1064', 'reportForm');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY01', 'RFP1065', '1');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY01', 'RFP1066', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY01', 'RFP1061', 'Year');
       
    --Month  Filter
    
       
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY02', 'RFP1060', 'MonthList');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY02', 'RFP1062', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY02', 'RFP1061', 'Month');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY02', 'RFP1063', 'Filter');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY02', 'RFP1064', 'reportForm');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY02', 'RFP1065', '1');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '375', 'RFC375PHY02', 'RFP1066', 'Yes');
       
     
       
-- exposure currenecy

Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (rc.corp_id, '375', 'RFC375PHY03', 'RFP1045', 'currencylist');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (rc.corp_id, '375', 'RFC375PHY03', 'RFP1046', 'ExposureCCY');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (rc.corp_id, '375', 'RFC375PHY03', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (rc.corp_id, '375', 'RFC375PHY03', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (rc.corp_id, '375', 'RFC375PHY03', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (rc.corp_id, '375', 'RFC375PHY03', 'RFP1050', '1');


    COMMIT;
  END LOOP;
END;
/