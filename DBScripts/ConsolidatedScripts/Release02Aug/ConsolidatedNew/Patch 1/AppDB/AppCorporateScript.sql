SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
 
    dbms_output.put_line(cc.corporate_id);
/*Insert into CDC_CORPORATE_DOC_CONFIG
   (DOC_TEMPLATE_ID, CORPORATE_ID, DOC_ID, DOC_TEMPLATE_NAME, DOC_TEMPLATE_NAME_DE, 
    DOC_TEMPLATE_NAME_ES, DOC_PRINT_NAME, DOC_PRINT_NAME_DE, DOC_PRINT_NAME_ES, DOC_RPT_FILE_NAME, 
    IS_ACTIVE, DOC_AUTO_GENERATE)
 Values
   ('CDC-GEPD-3', cc.corporate_id, 'pledgeTransfer', 'Pledge Letter', NULL, 
    NULL, NULL, NULL, NULL, 'PledgeLetterFormat.rpt', 
    'Y', 'Y');
    
Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-GEPD-'||cc.corporate_id, 'GEPD_KEY_3', cc.corporate_id, 'GEPD-', 0, 
    0, '-'||cc.corporate_id, 1, 'N');
      
Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-GEPD-'||cc.corporate_id, cc.corporate_id, 'pledgeTransfer', 'GEPD_KEY_3', 'N'); 
*/
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '211', 'RFC211PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '234', 'RFC234PHY01', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '212', 'RFC212PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '215', 'RFC215PHY03', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '217', 'RFC217PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '218', 'RFC218PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '219', 'RFC219PHY03', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '220', 'RFC220PHY03', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '245', 'RFC245PHY04', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '213', 'RFC213PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '216', 'RFC216PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '84', 'RFC84PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '86', 'RFC86PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '85', 'RFC85PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '65', 'RFC65PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '67', 'RFC67PHY03', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '225', 'RFC225PHY03', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '226', 'RFC226PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '227', 'RFC227PHY03', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '228', 'RFC228PHY03', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '247', 'RFC247PHY04', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '56', 'RFC56PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '75', 'RFC75PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '223', 'RFC-CDC-2233', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '224', 'RFC-CDC-2243', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '210', 'RFC210CDC02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '59', 'RFC-CDC-592', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '58', 'RFC-CDC-582', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '051', 'RFC51CDC04', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '051', 'RFC51CDC02', 'RFP1000', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '52', 'RFC-CDC-522', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '53', 'RFC-CDC-532', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '101', 'RFC101CDC04', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '221', 'RFC-CDC-2213', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '222', 'RFC-CDC-2223', 'RFP1053', 'Yes');

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-ASYM-'||cc.corporate_id, 'ASYMRefNo', cc.corporate_id, 'ASY-', 1, 
    0, '-'||cc.corporate_id, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-ASYM-'||cc.corporate_id, cc.corporate_id, 'MODIFY_ASSAY', 'ASYMRefNo', 'N');


Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (cc.corporate_id, 'MODIFY_ASSAY', 'ASY-', 0, '-'||cc.corporate_id);

   
 end loop;
commit;
end;


/************** 29th May**********************/

SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
 
    dbms_output.put_line(cc.corporate_id);
insert into rfc_report_filter_config
   (corporate_id, report_id, label_id, label_column_number, label_row_number, 
    label, field_id, colspan, is_mandatory)
 values
   (cc.corporate_id, '249', 'RFC249PHY03', 1, 3, 
    'Counter Party', 'GFF1001', 1, 'N');
insert into rfc_report_filter_config
   (corporate_id, report_id, label_id, label_column_number, label_row_number, 
    label, field_id, colspan, is_mandatory)
 values
   (cc.corporate_id, '249', 'RFC249PHY01', 1, 1, 
    'From Date', 'GFF021', 1, 'Y');
insert into rfc_report_filter_config
   (corporate_id, report_id, label_id, label_column_number, label_row_number, 
    label, field_id, colspan, is_mandatory)
 values
   (cc.corporate_id, '249', 'RFC249PHY02', 1, 2, 
    'To Date', 'GFF021', 1, 'Y');

insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY03', 'RFP1001', 'businesspartner');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY03', 'RFP1002', 'CPName');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY03', 'RFP1003', 'No');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY03', 'RFP1004', 'Filter');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY03', 'RFP1005', 'reportForm');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY03', 'RFP1006', '1');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY03', 'RFP1008', 'BUYER,SELLER');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY01', 'RFP0104', 'SYSTEM');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY01', 'RFP0026', 'FromDate');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY02', 'RFP0104', 'SYSTEM');
insert into rpc_rf_parameter_config
   (corporate_id, report_id, label_id, parameter_id, report_parameter_name)
 values
   (cc.corporate_id, '249', 'RFC249PHY02', 'RFP0026', 'ToDate');

 end loop;
commit;
end;

/

SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
  loop
 
    dbms_output.put_line(cc.corporate_id);

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (cc.corporate_id, 'UTIL_INV_REF_NO', 'UTIL-', 8, '-'||cc.corporate_id);

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-5550-'||cc.corporate_id, cc.corporate_id, 'CREATE_UTIL_INV', 'UtilInvRefNo', 'N');

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-5550-'||cc.corporate_id, 'UtilInvRefNo', cc.corporate_id, 'UTIL-', 1, 
    8, '-'||cc.corporate_id, NULL, 'N');

end loop;
commit;
end;

/

commit;