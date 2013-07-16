--trades card report filter
delete from RFC_REPORT_FILTER_CONFIG rfc where RFC.REPORT_ID=210;
delete from RPC_RF_PARAMETER_CONFIG rpc where rpc.REPORT_ID=210;
commit;

set define off;    
update AMC_APP_MENU_CONFIGURATION amc set amc.link_called = '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=210&ReportName=LMETraderCard.rpt&ExportFormat=HTML'
where amc.menu_id = 'RPT-D412';
update rml_report_master_list rml set rml.report_display_name ='LME Traders Card',
       rml.report_file_name = 'LMETraderCard.rpt' where rml.report_id = '210';
update REF_REPORTEXPORTFORMAT ref1 set ref1.REPORT_FILE_NAME = 'LMETraderCard.rpt' where ref1.report_id = '210';
delete from rpc_rf_parameter_config rpc where rpc.report_id = '210';
delete from rfc_report_filter_config rfc where rfc.report_id = '210';       

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
   (cc.corporate_id, '210', 'RFC210CDC01', 1, 1, 
    'EOD Date', 'GFF021', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 1, 2, 
    'Profit Center', 'GFF1011', 1, NULL);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '210', 'RFC210CDC03', 1, 3, 
    'Future Contract', 'GFF1001', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC01', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC01', 'RFP0026', 'AsOfDate');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 'RFP1045', 'reportProfitcenterList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 'RFP1046', 'Book');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 'RFP1051', 'multiple');    
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC03', 'RFP1001', 'setupUnderlyingInstrument');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC03', 'RFP1002', 'FutureContract');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC03', 'RFP1003', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC03', 'RFP1004', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC03', 'RFP1005', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC03', 'RFP1006', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC03', 'RFP1007', 'multiple');
COMMIT;   
 end loop;
commit;
end;