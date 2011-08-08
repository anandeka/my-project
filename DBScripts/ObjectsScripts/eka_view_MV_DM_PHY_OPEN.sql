DROP MATERIALIZED VIEW MV_DM_PHY_OPEN;
CREATE MATERIALIZED VIEW MV_DM_PHY_OPEN 

NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 

SELECT poud.corporate_id, poud.contract_ref_no, poud.contract_type,
        poud.internal_contract_item_ref_no, poud.pcdi_id,
        poud.delivery_item_no, poud.product_name, poud.item_qty,
        poud.qty_unit, poud.qty_unit_id, poud.qty_in_base_unit,
        poud.base_qty_unit_id, poud.base_qty_unit, poud.contract_price ||' ' ||poud.PRICE_UNIT_CUR_CODE||'/'||poud.PRICE_UNIT_WEIGHT||poud.PRICE_UNIT_WEIGHT_UNIT contract_price,
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
    AND tdc.trade_date = tdc_max.max_date
    
UNION ALL

SELECT poue.corporate_id, poue.contract_ref_no, poue.contract_type,
        poue.internal_contract_item_ref_no, poue.pcdi_id,
        poue.delivery_item_no, poue.product_name, poue.ITEM_DRY_QTY item_qty,
        poue.qty_unit, poue.qty_unit_id, poue.qty_in_base_unit,
        poue.base_qty_unit_id, poue.base_qty_unit, poue.CONTRACT_PRICE_STRING contract_price,
        poue.unrealized_pnl_in_base_cur pnl_in_base, poue.base_cur_id,
        poue.base_cur_code
   FROM POUE_PHY_OPEN_UNREAL_ELEMENT@eka_eoddb poue,
        tdc_trade_date_closure@eka_eoddb tdc,
        (SELECT   tdc.corporate_id, MAX (tdc.trade_date) max_date
             FROM tdc_trade_date_closure@eka_eoddb tdc
            WHERE tdc.process = 'EOD'
         GROUP BY tdc.corporate_id) tdc_max
  WHERE poue.process_id = tdc.process_id
    AND poue.corporate_id = tdc.corporate_id
    AND tdc.process = 'EOD'
    AND tdc.corporate_id = tdc_max.corporate_id
    AND tdc.trade_date = tdc_max.max_date;

