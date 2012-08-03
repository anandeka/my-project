SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('258', '11', 'BrokerMarginReport.rpt', 'Broker Margin  Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
COMMIT;

insert into ref_reportexportformat (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
values ('258', 'EXCEL', 'BrokerMarginReport.rpt');


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D258', 'Broker Margin  Report', 33, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=258&ReportName=BrokerMarginReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D22', NULL, 'Reports', NULL, 
    'N');
COMMIT;
drop materialized view MV_FACT_BROKER_MARGIN_UTIL;
create materialized view MV_FACT_BROKER_MARGIN_UTIL
refresh force on demand
as
select tdc.process_id,
       tdc.trade_date eod_date,
       tdc.corporate_id,
       bmu.corporate_name,
       bmu.broker_profile_id,
       bmu.broker_name,
       bmu.instrument_id,
       bmu.instrument_name,
       bmu.exchange_id,
       bmu.exchange_name,
       bmu.margin_cur_id,
       bmu.margin_cur_code,
       bmu.initial_margin_limit,
       bmu.current_credit_limit,
       bmu.variation_margin_limit,
       bmu.maintenance_margin,
       bmu.margin_calculation_method,
       bmu.base_cur_id,
       bmu.base_cur_code,
       bmu.fx_rate_margin_cur_to_base_cur,
       bmu.initial_margin_limit_in_base,
       bmu.current_credit_limit_in_base,
       bmu.variation_margin_limit_in_base,
       bmu.maintenance_margin_in_base,
       bmu.no_of_lots,
       bmu.net_no_of_lots,
       bmu.gross_no_of_lots,
       bmu.initial_margin_rate_cur_id,
       bmu.initial_margin_rate_cur_code,
       bmu.initial_margin_rate,
       bmu.initial_margin_requirement,
       bmu.fx_rate_imr_cur_to_base_cur,
       bmu.initial_margin_req_in_base,
       bmu.under_over_utilized_im,
       bmu.under_over_utilized_im_flag,
       bmu.trade_value_in_base,
       bmu.market_value_in_base,
       bmu.open_no_of_lots,
       bmu.lot_size,
       bmu.lot_size_unit,
       bmu.variation_margin_requirement,
       bmu.under_over_utilized_vm,
       bmu.under_over_utilized_vm_flag
  from bmu_broker_margin_utilization@eka_eoddb bmu,
       tdc_trade_date_closure@eka_eoddb        tdc
 where bmu.corporate_id = tdc.corporate_id
   and bmu.process_id = tdc.process_id;