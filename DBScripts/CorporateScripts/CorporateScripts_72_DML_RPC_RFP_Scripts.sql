update RFC_REPORT_FILTER_CONFIG rfc
set RFC.LABEL_ROW_NUMBER = 5
where RFC.LABEL_ID = 'RFC252PHY04';
update RFC_REPORT_FILTER_CONFIG rfc
set RFC.IS_MANDATORY = 'Y'
where RFC.LABEL_ID in ('RFC252PHY02','RFC252PHY03');
commit;

delete from RPC_RF_PARAMETER_CONFIG rpc where RPC.LABEL_ID = 'RFC252PHY05';
delete from RFC_REPORT_FILTER_CONFIG rfc where RfC.LABEL_ID = 'RFC252PHY05';
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
   (cc.corporate_id, '252', 'RFC252PHY05', 1, 4, 
    'Business Line', 'GFF1011', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1045', 'mdmBusinessLine');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1046', 'BusinessLine');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '252', 'RFC252PHY05', 'RFP1050', '1');
COMMIT;
 end loop;
commit;
end;
