delete from rpc_rf_parameter_config rpc
where rpc.label_id = 'RFC210CDC03'
and rpc.parameter_id = 'RFP1007';
commit;
SET DEFINE OFF;
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('210', 'EXCEL', 'LMETraderCard.rpt');
COMMIT;