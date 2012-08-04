update REF_REPORTEXPORTFORMAT re 
set RE.REPORT_FILE_NAME = 'MonthlyClosingBalanceReport_Excel'
where RE.REPORT_ID = '257';
commit;