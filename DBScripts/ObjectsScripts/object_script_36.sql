CREATE MATERIALIZED VIEW mv_dm_phy_open
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS
          (SELECT poud.corporate_id, poud.contract_ref_no, poud.contract_type,
          poud.internal_contract_item_ref_no, poud.pcdi_id,
          poud.delivery_item_no, poud.product_name, poud.item_qty,
          poud.qty_unit, poud.qty_unit_id, poud.qty_in_base_unit,
          poud.base_qty_unit_id, poud.base_qty_unit, poud.contract_price,
          poud.unrealized_pnl_in_base_cur pnl_in_base, poud.base_cur_id,
          poud.base_cur_code
     FROM poud_phy_open_unreal_daily@eka_eoddb poud,
          tdc_trade_date_closure@eka_eoddb tdc,
          (SELECT   tdc.corporate_id, MAX (tdc.trade_date) max_date
               FROM tdc_trade_date_closure@eka_eoddb tdc
              WHERE tdc.process = 'EOD'
           GROUP BY tdc.corporate_id) tdc_max
    WHERE poud.process_id = tdc.process_id
      AND poud.corporate_id = tdc.corporate_id
      AND tdc.process = 'EOD'
      AND tdc.corporate_id = tdc_max.corporate_id
      AND tdc.trade_date = tdc_max.max_date);

CREATE MATERIALIZED VIEW mv_dm_phy_stock
BUILD IMMEDIATE
REFRESH ON DEMAND AS
SELECT psu.psu_id, psu.corporate_id, pcm.contract_ref_no,
          psu.internal_contract_item_ref_no, psu.contract_type,
          psu.gmr_ref_no, psu.stock_qty, psu.qty_unit, psu.qty_unit_id,
          psu.stock_ref_no, psu.qty_in_base_unit, psu.contract_price,
          psu.pnl_in_base_cur pnl_in_base, psu.base_cur_id, psu.base_cur_code
     FROM psu_phy_stock_unrealized@eka_eoddb psu,
          tdc_trade_date_closure@eka_eoddb tdc,
          (SELECT   tdc.corporate_id, MAX (tdc.trade_date) max_date
               FROM tdc_trade_date_closure@eka_eoddb tdc
              WHERE tdc.process = 'EOD'
           GROUP BY tdc.corporate_id) tdc_max,
          gmr_goods_movement_record@eka_eoddb gmr,
          pcm_physical_contract_main@eka_eoddb pcm
    WHERE psu.process_id = tdc.process_id
      AND psu.corporate_id = tdc.corporate_id
      AND tdc.process = 'EOD'
      AND tdc.corporate_id = tdc_max.corporate_id
      AND tdc.trade_date = tdc_max.max_date
      AND gmr.internal_gmr_ref_no = psu.internal_gmr_ref_no
      AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND gmr.process_id = tdc.process_id
      AND pcm.process_id = tdc.process_id;

CREATE MATERIALIZED VIEW mv_dm_phy_derivative
BUILD IMMEDIATE
REFRESH ON DEMAND AS
SELECT dpd.corporate_id, dpd.derivative_ref_no,
          dpd.internal_derivative_ref_no, dpd.eod_trade_date,
          dpd.exchange_name, dpd.product_name, dpd.prompt_date, dpd.status,
          dpd.instrument_name, dpd.broker_name, dpd.trade_type,
          dpd.trade_price, dpd.open_quantity quantity, dpd.base_qty_unit_id,
          dpd.quantity_unit, dpd.quantity_unit_id, dpd.pnl_in_base_cur,
          dpd.base_cur_id, dpd.base_cur_code
     FROM dpd_derivative_pnl_daily@eka_eoddb dpd,
          tdc_trade_date_closure@eka_eoddb tdc,
          (SELECT   tdc.corporate_id, MAX (tdc.trade_date) max_date
               FROM tdc_trade_date_closure@eka_eoddb tdc
              WHERE tdc.process = 'EOD'
           GROUP BY tdc.corporate_id) tdc_max
    WHERE dpd.process_id = tdc.process_id
      AND dpd.corporate_id = tdc.corporate_id
      AND tdc.process = 'EOD'
      AND dpd.pnl_type = 'Unrealized'
      AND tdc.corporate_id = tdc_max.corporate_id
      AND tdc.trade_date = tdc_max.max_date
   UNION ALL
   SELECT dpd.corporate_id, dpd.derivative_ref_no,
          dpd.internal_derivative_ref_no, dpd.eod_trade_date,
          dpd.exchange_name, dpd.product_name, dpd.prompt_date, dpd.status,
          dpd.instrument_name, dpd.broker_name, dpd.trade_type,
          dpd.trade_price, dpd.open_quantity quantity, dpd.base_qty_unit_id,
          dpd.quantity_unit, dpd.quantity_unit_id, dpd.pnl_in_base_cur,
          dpd.base_cur_id, dpd.base_cur_code
     FROM dpd_derivative_pnl_daily@eka_eoddb dpd,
          tdc_trade_date_closure@eka_eoddb tdc
    WHERE dpd.process_id = tdc.process_id
      AND dpd.corporate_id = tdc.corporate_id
      AND tdc.process = 'EOD'
      AND dpd.pnl_type = 'Realized';