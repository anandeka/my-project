ALTER TABLE RFC_REPORT_FILTER_CONFIG ADD (IS_MANDATORY CHAR(1));
ALTER TABLE RFC_REPORT_FILTER_CONFIG MODIFY(IS_MANDATORY  DEFAULT 'N');

ALTER TABLE RPC_RF_PARAMETER_CONFIG DROP PRIMARY KEY CASCADE
/
DROP TABLE RPC_RF_PARAMETER_CONFIG CASCADE CONSTRAINTS
/

CREATE TABLE RPC_RF_PARAMETER_CONFIG
(
  CORPORATE_ID           VARCHAR2(15 CHAR),
  REPORT_ID              VARCHAR2(20 CHAR),
  LABEL_ID               VARCHAR2(20 CHAR),
  PARAMETER_ID           VARCHAR2(20 CHAR),
  REPORT_PARAMETER_NAME  VARCHAR2(50 CHAR)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


CREATE INDEX IDX_FK_RPC_LABEL_ID ON RPC_RF_PARAMETER_CONFIG
(CORPORATE_ID, REPORT_ID, LABEL_ID)
LOGGING
NOPARALLEL
/


CREATE INDEX IDX_FK_RPC_PARAMETER_ID ON RPC_RF_PARAMETER_CONFIG
(PARAMETER_ID)
LOGGING
NOPARALLEL
/


CREATE UNIQUE INDEX PK_RPC ON RPC_RF_PARAMETER_CONFIG
(CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID)
LOGGING
NOPARALLEL
/


ALTER TABLE RPC_RF_PARAMETER_CONFIG ADD (
  CONSTRAINT PK_RPC
 PRIMARY KEY
 (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID))
/

-- Created on 10/4/2011 by SIVACHALABATHI 
declare
  -- Local variables here
  i integer;
begin
  -- Test statements here
  for cc in (select * from rml_report_master_list rml)
  loop
    update ref_reportexportformat ref
       set ref.report_file_name = cc.report_file_name
     where ref.report_id = cc.report_id;
  end loop;
commit;
end;
/
--select * from amc_app_menu_configuration amc where amc.tab_id = 'Reports' and amc.link_called is not null
set define off;
update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=213&ReportName=DailyOpenUnrealizedPhysicalConc.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D224';
update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=216&ReportName=DailyInventoryUnrealizedPhysicalPnLConc.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D225';
update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=66&ReportName=DailyOpenUnrealizedPhysicalPnL.rpt.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D221';
update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=68&ReportName=DailyInventoryUnrealizedPhysicalPnL.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D223';
update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=75&CurrencyRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D522';
update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=56&FXPositionandPnLReport.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D521';

--derivative reports

update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=54&ReportName=DailyDerivativeReport.rpt&ExportFormat=HTML'
where amc.menu_id = 'RPT-D411';

update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=59&ReportName=DailyDerivativesUnRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D421';

update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=58&ReportName=DailyDerivativesRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D422';

update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=104&ReportName=DailyClearerSummaryReport.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D424';

update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=52&ReportName=FutureOptionSummaryPositionReport.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D426';

--Derivative PnL Attribution
update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=103&ReportName=DerivativePNLAttributionReport.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D427';

--Margin Report
update amc_app_menu_configuration amc set amc.link_called ='/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=53&ReportName=MarginReport.rpt&ExportFormat=HTML&isEodReport=Y'
where amc.menu_id = 'RPT-D428';


