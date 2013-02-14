begin
UPDATE REF_REPORTEXPORTFORMAT SET REPORT_FILE_NAME='IntrastatReport_Excel.rpt'
WHERE REPORT_ID = '240';
-- Increment All Filters After Country Including Country
 update rfc_report_filter_config rfc
     set rfc.LABEL_ROW_NUMBER = rfc.LABEL_ROW_NUMBER +1
   where rfc.report_id ='248' 
   and RFC.LABEL_ID ='RFC248PHY03';

   update rfc_report_filter_config rfc
     set rfc.LABEL_ROW_NUMBER = rfc.LABEL_ROW_NUMBER +1
   where rfc.report_id ='248' 
   and RFC.LABEL_ID ='RFC248PHY04';

   update rfc_report_filter_config rfc
     set rfc.LABEL_ROW_NUMBER = rfc.LABEL_ROW_NUMBER +1
   where rfc.report_id ='248' 
   and RFC.LABEL_ID ='RFC248PHY05';

  update rfc_report_filter_config rfc
     set rfc.LABEL_ROW_NUMBER = rfc.LABEL_ROW_NUMBER +1
   where  rfc.report_id ='248' 
   and RFC.LABEL_ID ='RFC248PHY06';


  update rfc_report_filter_config rfc
     set rfc.LABEL_ROW_NUMBER = rfc.LABEL_ROW_NUMBER +1
   where rfc.report_id ='248' 
   and RFC.LABEL_ID ='RFC248PHY07';


  update rfc_report_filter_config rfc
     set rfc.LABEL_ROW_NUMBER = rfc.LABEL_ROW_NUMBER +1
   where  rfc.report_id ='248' 
   and RFC.LABEL_ID ='RFC248PHY08';


  update rfc_report_filter_config rfc
     set rfc.LABEL_ROW_NUMBER = rfc.LABEL_ROW_NUMBER +1
   where rfc.report_id ='248' 
   and RFC.LABEL_ID ='RFC248PHY09';
   
  for cc in (select akc.corporate_id
               from ak_corporate akc
              where akc.corporate_id <> 'EKA-SYS')
  loop
  
    insert into rfc_report_filter_config
      (corporate_id,
       report_id,
       label_id,
       label_column_number,
       label_row_number,
       label,
       field_id,
       colspan,
       is_mandatory)
    values
      (cc.corporate_id,
       '248',
       'RFC248PHY10',
       1,
       3,
       'Exclude Region',
       'GFF1011',
       1,
       'Y');
  
 Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '248', 'RFC248PHY10', 'RFP1046', 'Region');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '248', 'RFC248PHY10', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '248', 'RFC248PHY10', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '248', 'RFC248PHY10', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '248', 'RFC248PHY10', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '248', 'RFC248PHY10', 'RFP1045', 'regionList');
  end loop;
  commit;
end;

