delete from amc_app_menu_configuration amc
where amc.menu_id in ('RPT-D231','RPT-D232','RPT-D233','RPT-D234','RPT-D235','RPT-D236','RPT-D237','RPT-D238','RPT-D239','RPT-D240','RPT-D431','RPT-D432','RPT-D531','RPT-D532');
commit;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D431', 'Monthly Derivatives UnRealized P&L Report', 11, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=221&ReportName=MonthlyDerivativesUnRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D43', 'APP-ACL-N1319', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D432', 'Monthly Derivatives Realized P&L Report', 12, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=222&ReportName=MonthlyDerivativesRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D43', 'APP-ACL-N1320', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D532', 'Monthly Currency Realized P&L Report', 12, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=224&MonthlyCurrencyRealizedPnLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D53', 'APP-ACL-N1326', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D531', 'Monthly FX Position and P&L Report', 11, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=223&MonthlyFXPositionandPnLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D53', 'APP-ACL-N1327', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D231', 'Monthly Open Unrealized Physical PnL', 11, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=225&ReportName=MonthlyOpenUnrealizedPhysicalPnL.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', 'APP-ACL-N1301', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D232', 'Monthly Open Unrealized Physical Conc', 12, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=226&ReportName=MonthlyOpenUnrealizedPhysicalConc.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', 'APP-ACL-N1302', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D233', 'Monthly Inventory Unrealized Physical PnL', 13, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=227&ReportName=MonthlyInventoryUnrealizedPhysicalPnL.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', 'APP-ACL-N1303', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D234', 'Monthly Inventory Unrealized Physical PnL Conc', 14, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=228&ReportName=MonthlyInventoryUnrealizedPhysicalPnLConc.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', 'APP-ACL-N1304', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D235', 'Purchase Accrual Report', 15, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=236&ReportName=PurchaseAccrualReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', 'APP-ACL-N1305', 'Reports', 'APP-PFL-N-215', 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D237', 'Feed Consumption Report', 18, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=241&ReportName=FeedConsumptionReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D238', 'YTD MTD Yield Report', 17, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=242&ReportName=YTDMTDYIELD.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D236', 'Intrastat Report', 16, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=240&ReportName=IntrastatReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D240', 'Monthly Customs Report', 20, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=248&ReportName=MonthlyCustomsReport.rpt.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D239', 'Metal Balance Summary Report', 19, 4, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=247&ReportName=MetalBalanceSummaryReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
COMMIT;
