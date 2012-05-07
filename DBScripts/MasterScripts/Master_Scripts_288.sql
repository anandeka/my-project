delete from rpc_rf_parameter_config rpc where rpc.parameter_id in ('RFP1053','RFP1000');
delete from rfp_rfc_field_parameters rfp where rfp.parameter_id in ('RFP1053','RFP1000');
commit;
SET DEFINE OFF;
Insert into RFP_RFC_FIELD_PARAMETERS
   (FIELD_ID, PARAMETER_DISPLAY_SEQ, PARAMETER_DESCRIPTION, PARAMETER_ID, TAG_ATTRIBUTE_NAME)
 Values
   ('GFF1011', 1, NULL, 'RFP1053', 'removeSelect');
Insert into RFP_RFC_FIELD_PARAMETERS
   (FIELD_ID, PARAMETER_DISPLAY_SEQ, PARAMETER_DESCRIPTION, PARAMETER_ID, TAG_ATTRIBUTE_NAME)
 Values
   ('GFF1001', 1, NULL, 'RFP1000', 'removeSelect');
COMMIT;
