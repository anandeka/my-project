DROP MATERIALIZED VIEW MV_DM_PHY_DERIVATIVE
/
CREATE MATERIALIZED VIEW MV_DM_PHY_DERIVATIVE
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
SELECT dpd.corporate_id, dpd.derivative_ref_no,
          dpd.internal_derivative_ref_no, dpd.eod_trade_date,
          dpd.exchange_name, dpd.product_name, dpd.prompt_date, dpd.status,
          dpd.instrument_name, dpd.broker_name, dpd.trade_type,
          dpd.trade_price, dpd.open_quantity quantity, dpd.base_qty_unit_id,
          dpd.quantity_unit, dpd.quantity_unit_id, dpd.pnl_in_base_cur,
          dpd.base_cur_id, dpd.base_cur_code,
          dpd.pnl_type
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
          dpd.trade_price, dpd.total_quantity quantity, dpd.base_qty_unit_id,
          dpd.quantity_unit, dpd.quantity_unit_id, dpd.pnl_in_base_cur,
          dpd.base_cur_id, dpd.base_cur_code,
          dpd.pnl_type
     FROM dpd_derivative_pnl_daily@eka_eoddb dpd,
          tdc_trade_date_closure@eka_eoddb tdc
    WHERE dpd.process_id = tdc.process_id
      AND dpd.corporate_id = tdc.corporate_id
      AND tdc.process = 'EOD'
      AND dpd.pnl_type = 'Realized'
/
