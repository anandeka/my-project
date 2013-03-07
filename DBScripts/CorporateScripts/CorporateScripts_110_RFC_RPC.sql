SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Internal', 'Internal');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('External', 'External');

   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('All', 'All');

   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('SupplierTypeList', 'All', 'N', 1);  
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('SupplierTypeList', 'External', 'N', 2);     
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('SupplierTypeList', 'Internal', 'N', 3);
 Commit;
  

    
delete from rpc_rf_parameter_config rpc where rpc.label_id = 'RFC236PHY04';
delete from rfc_report_filter_config rfc where rfc.label_id = 'RFC236PHY04';
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
   (cc.corporate_id, '236', 'RFC236PHY04', 1, 4, 
    'Supplier Type', 'GFF1012', 1, 'N');
    
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY04', 'RFP1060', 'SupplierTypeList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY04', 'RFP1061', 'SupplierType');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY04', 'RFP1062', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY04', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY04', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY04', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY04', 'RFP1066', 'Yes');
 Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '236', 'RFC236PHY04', 'RFP1212', 'Yes');
  end loop;
commit;
end;