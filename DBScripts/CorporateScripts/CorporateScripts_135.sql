SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
    dbms_output.put_line(cc.corporate_id);    
DELETE FROM RFC_REPORT_FILTER_CONFIG RFC WHERE RFC.LABEL_ID = 'RFC256PHY09' AND RFC.REPORT_ID = '256' AND RFC.CORPORATE_ID = cc.corporate_id;
COMMIT;
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY09', 1, 8, 
    'FeedingPoint', 'GFF1011', 1, 'N');
------------
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY09', 'RFP1045', 'feedingPointList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY09', 'RFP1046', 'FeedingPoint');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY09', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY09', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY09', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY09', 'RFP1050', '1');
end loop;
commit;
end;

