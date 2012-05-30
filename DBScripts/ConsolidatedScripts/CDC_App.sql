------------------------------------
------------CDC 1.4.1---------------
------------------------------------
set define off;
drop MATERIALIZED VIEW LOG ON  MNM_MONTH_NAME_MASTER;
CREATE MATERIALIZED VIEW LOG ON  MNM_MONTH_NAME_MASTER;
drop MATERIALIZED VIEW LOG ON  CPC_CORPORATE_PROFIT_CENTER;
CREATE MATERIALIZED VIEW LOG ON  CPC_CORPORATE_PROFIT_CENTER;
delete from RPC_RF_PARAMETER_CONFIG rpc where RPC.REPORT_ID = '54';
delete from RFC_REPORT_FILTER_CONFIG rfc where RFC.REPORT_ID = '54';
commit;
update REF_REPORTEXPORTFORMAT rrf
set RRF.REPORT_FILE_NAME = 'DailyDerivativeReport_Excel.rpt'
where RRF.REPORT_ID = '54';
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
   (cc.corporate_id, '54', 'RFC-CDC-541', 1, 1,     
    'Created Date', 'GFF021', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 1, 2, 
    'Profit Center', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-543', 1, 3, 
    'Exchange ', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-545', 1, 4, 
    'Strategy', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-546', 1, 5, 
    'Trade Type', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-547', 1, 6, 
    'Purpose', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-548', 1, 7, 
    'Nominee', 'GFF1011', 1, 'N');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-541', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-541', 'RFP0026', 'AsOfDate');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 'RFP1045', 'reportProfitcenterList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 'RFP1046', 'Book');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-542', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-543', 'RFP1045', 'exchangelist');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-543', 'RFP1046', 'Exchange');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-543', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-543', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-543', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-543', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-545', 'RFP1045', 'strategyDefinition');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-545', 'RFP1046', 'Strategy');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-545', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-545', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-545', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-545', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-546', 'RFP1045', 'tradeTypeByMasterContract');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-546', 'RFP1046', 'TradeType');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-546', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-546', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-546', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-546', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-547', 'RFP1045', 'setupDerivativeTradePurpose');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-547', 'RFP1046', 'Purpose');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-547', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-547', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-547', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-547', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-548', 'RFP1045', 'corporatebusinesspartner');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-548', 'RFP1046', 'Nominee');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-548', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-548', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-548', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '54', 'RFC-CDC-548', 'RFP1050', '1');
COMMIT;
 end loop;
commit;
end;

CREATE OR REPLACE VIEW V_DAT_DERIVATIVE_AGG_TRADE
AS 
SELECT dat.aggregate_trade_id, dat.aggregate_trade_ref_no,
          dat.leg_1_int_der_ref_no, dat.leg_1_trade_type,
          dat.leg_2_int_der_ref_no, dat.leg_2_trade_type,
          DECODE (dt1.status, 'Settled', 'Closed out', dt1.status) status,
          pkg_general.f_get_corporate_user_name (dt1.created_by) created_by,
          TO_CHAR (dt1.created_date, 'DD-Mon-YYYY') created_date
     FROM dat_derivative_aggregate_trade dat,
          dt_derivative_trade dt1,
          dt_derivative_trade dt2,
          drm_derivative_master drm,
          dim_der_instrument_master dim,
          pm_period_master pm,
          dtm_deal_type_master dtm
    WHERE dat.leg_1_int_der_ref_no = dt1.internal_derivative_ref_no
      AND dat.leg_2_int_der_ref_no = dt2.internal_derivative_ref_no
      AND dt1.is_internal_trade = 'Y'
      AND dt2.is_internal_trade = 'Y'
      AND dt1.status <> 'Delete'
      AND dt2.status <> 'Delete'
      AND dt1.dr_id = drm.dr_id
      AND drm.instrument_id = dim.instrument_id
      AND drm.period_type_id = pm.period_type_id
      AND dtm.deal_type_id = dt1.deal_type_id;
/
/* Formatted on 2012/04/27 14:25 (Formatter Plus v4.8.8) */
declare
begin
  for temp in (select ct.internal_treasury_ref_no,
                      crtd.amount,
                      crtd.cur_id
                 from ct_currency_trade      ct,
                      crtd_cur_trade_details crtd
                where ct.internal_treasury_ref_no =
                      crtd.internal_treasury_ref_no
                  and crtd.leg_no = '1'
                  and crtd.is_base = 'Y'
                  and nvl(ct.outstanding_amount, 0) = 0)
  loop
    update ct_currency_trade ct1
       set ct1.outstanding_amount             = temp.amount,
           ct1.outstanding_amount_currency_id = temp.cur_id
     where ct1.internal_treasury_ref_no = temp.internal_treasury_ref_no;
  end loop;
end;
/
commit;


/* Formatted on 2012/04/27 14:25 (Formatter Plus v4.8.8) */
declare
begin
  for temp in (
SELECT ctul.internal_treasury_ref_no, crtd.amount, crtd.cur_id
  FROM crtd_cur_trade_details crtd, ctul_currency_trade_ul ctul
 WHERE ctul.internal_treasury_ref_no = crtd.internal_treasury_ref_no
   AND crtd.leg_no = '1'
   AND crtd.is_base = 'Y'
   AND NVL (ctul.outstanding_amount, 0) = 0)
  loop
    update CTUL_CURRENCY_TRADE_UL ctul1
       set ctul1.outstanding_amount             = temp.amount,
           ctul1.outstanding_amount_currency_id = temp.cur_id
     where ctul1.internal_treasury_ref_no = temp.internal_treasury_ref_no;
  end loop;
end;
/
commit;

DROP SNAPSHOT LOG ON  BRKMD_BROKER_MARGIN_DETAIL;
DROP SNAPSHOT LOG ON  BRKMM_BROKER_MARGIN_MASTER;
CREATE MATERIALIZED VIEW LOG ON  BRKMD_BROKER_MARGIN_DETAIL;
CREATE MATERIALIZED VIEW LOG ON  BRKMM_BROKER_MARGIN_MASTER;
UPDATE amc_app_menu_configuration amc
   SET amc.LINK_CALLED = '/cdc/getListingPage.action?gridId=LIST_SETTLEMENT_CLOSEOUT'
 WHERE amc.menu_id = 'CDC-D7'
 /


 Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LIST_SETTLEMENT_CLOSEOUT', 'List of settlement Closeout', '[{header: "Profit Center", width: 100, sortable: true,  dataIndex: ''profitcenter''},
{header: "Exchange Instrument", width: 100, sortable: true,  dataIndex: ''exchangeInst''},
{header: "Strike Price", width: 100, sortable: true,  dataIndex: ''''strikePrice''''},
{header: "Delivery Period", width: 100, sortable: true,  dataIndex: ''delPeriod''},
{header: "Clearer", width: 100, sortable: true,  dataIndex: ''clearer''},
{header: "Clearer Account", width: 100, sortable: true,  dataIndex: ''clearerAcc''},
{header: "Commision Type", width: 100, sortable: true,  dataIndex: ''commisionType''},
{header: "Buy Lots", width: 100, sortable: true,  dataIndex: ''buyLots''},
{header: "Sell Lots", width: 100, sortable: true,  dataIndex: ''sellLots''},
{header: "Available Lots", width: 100, sortable: true,  dataIndex: ''availLots''}', NULL, NULL, 
    NULL, NULL, 'settlements/ListOfSettlementCloseOut.jsp', '/private/js/settlements/ListOfSettlementCloseOut.js')

/
 
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LIST_SETTLEMENT_CLOSEOUT-1', 'LIST_SETTLEMENT_CLOSEOUT', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL)
/

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   (' LIST_SETTLEMENT_CLOSEOUT-2', 'LIST_SETTLEMENT_CLOSEOUT', 'Manual', 2, 2, 
    NULL, 'function(){viewManual();}', NULL, 'LIST_SETTLEMENT_CLOSEOUT-1', NULL)
/

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   (' LIST_SETTLEMENT_CLOSEOUT-3', 'LIST_SETTLEMENT_CLOSEOUT', 'LIFO', 3, 2, 
    NULL, 'function(){viewLIFO();}', NULL, 'LIST_SETTLEMENT_CLOSEOUT-1', NULL)
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   (' LIST_SETTLEMENT_CLOSEOUT-4', 'LIST_SETTLEMENT_CLOSEOUT', 'FIFO', 4, 2, 
    NULL, 'function(){viewFIFO();}', NULL, 'LIST_SETTLEMENT_CLOSEOUT-1', NULL)
/

drop materialized view MV_FACT_BROKER_MARGIN_UTIL;
drop table MV_FACT_BROKER_MARGIN_UTIL;
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
       variation_margin_limit_in_base,
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
/

commit;