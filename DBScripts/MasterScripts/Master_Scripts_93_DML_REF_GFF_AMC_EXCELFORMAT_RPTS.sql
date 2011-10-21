set define off;
INSERT INTO gff_general_filter_fields (field_id, field_name, tag_name, addnl_tag_attributes)VALUES ('GFF10206', 'Text Box', 'eka:reportTextBox', NULL);
update amc_app_menu_configuration amc set amc.link_called='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=051&ReportName=DailyClearerStatementReport.rpt&ExportFormat=HTML&isEodReport=Y' where amc.menu_id='RPT-D423';
update amc_app_menu_configuration amc set amc.link_called='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=101&ReportName=UpcomingOptionExpiryReport.rpt&ExportFormat=HTML&isEodReport=Y' where amc.menu_id='RPT-D429';
INSERT INTO rfp_rfc_field_parameters(field_id, parameter_display_seq, parameter_description,parameter_id, tag_attribute_name) 
VALUES ('GFF10206', 1, NULL,'RFP100533', 'fieldName');
commit;
delete from ref_reportexportformat ref where ref.report_id in ('51');
delete from rpc_rf_parameter_config rpc where rpc.report_id in('51','051','101');
delete from rfc_report_filter_config rfc where rfc.report_id in('51','051','101');
delete from rml_report_master_list rml where rml.report_id in ('51');
commit;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'MarginReport_Excel.rpt' WHERE REF.report_id = 53;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'DailyDerivativeReport_Excel.rpt' WHERE REF.report_id = 54;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'FXPositionandPnLReport_Excel.rpt' WHERE REF.report_id = 56;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'DailyDerivativesUnRealizedPnLReport_Excel.rpt' WHERE REF.report_id = 59;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'DailyDerivativesRealizedPnLReport_Excel.rpt' WHERE REF.report_id = 58;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'DailyClearerSummaryReport_Excel.rpt' WHERE REF.report_id = 104;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'DailyClearerStatementReport_Excel.rpt' WHERE REF.report_id = 051;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'UpcomingOptionExpiryReport_Excel.rpt' WHERE REF.report_id = 101;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'CurrencyRealizedPnLReport_Excel.rpt' WHERE REF.report_id = 75;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'DailyOpenUnrealizedPhysicalPnL_Excel.rpt' WHERE REF.report_id = 66;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'DailyInventoryUnrealizedPhysicalPnL_Excel.rpt' WHERE REF.report_id = 68;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'DerivativePNLAttributionReport_Excel.rpt' WHERE REF.report_id = 103;
UPDATE ref_reportexportformat REF SET REF.report_file_name = 'FutureOptionSummaryPositionReport_Excel.rpt' WHERE REF.report_id = 52;

INSERT INTO ref_reportexportformat (report_id, export_format, report_file_name )
VALUES (213, 'EXCEL', 'DailyOpenUnrealizedPhysicalConc_Excel.rpt');
INSERT INTO ref_reportexportformat(report_id, export_format, report_file_name)
VALUES (216, 'EXCEL', 'DailyInventoryUnrealizedPhysicalPnLConc_Excel.rpt');
INSERT INTO ref_reportexportformat(report_id, export_format, report_file_name)
VALUES (214, 'EXCEL', 'AgingReport_Excel.rpt');
INSERT INTO ref_reportexportformat(report_id, export_format, report_file_name)
VALUES (218, 'EXCEL', 'DailyDetailPriceExposure_Excel.rpt');
INSERT INTO ref_reportexportformat(report_id, export_format, report_file_name)
VALUES (217, 'EXCEL', 'DailyFXExposureReport_Excel.rpt');
INSERT INTO ref_reportexportformat(report_id, export_format, report_file_name)
VALUES (212, 'EXCEL', 'PositionDeliveryPricing_Excel.rpt');
INSERT INTO ref_reportexportformat(report_id, export_format, report_file_name)
VALUES (219, 'EXCEL', 'ProjectedPriceExposure_Excel.rpt');
INSERT INTO ref_reportexportformat(report_id, export_format, report_file_name)
VALUES (211, 'EXCEL', 'PhysicalPosition_Excel.rpt');

commit;