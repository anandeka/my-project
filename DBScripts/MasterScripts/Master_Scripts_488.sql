delete from ref_reportexportformat where REPORT_ID in('240','247','236');
commit;
SET DEFINE OFF;
insert into ref_reportexportformat(report_id, export_format, report_file_name)
values ('240', 'EXCEL', 'IntrastatReport_Excel.rpt');
insert into ref_reportexportformat(report_id, export_format, report_file_name)
values ('247', 'EXCEL', 'MetalBalanceSummaryReport_Excel.rpt');
insert into ref_reportexportformat(report_id, export_format, report_file_name)
values ('236', 'EXCEL', 'PurchaseAccrualReport_Excel.rpt');

commit;