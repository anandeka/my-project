DROP MATERIALIZED VIEW MV_DM_PHY_STOCK;
CREATE MATERIALIZED VIEW MV_DM_PHY_STOCK 
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
select psu.psu_id,
       psu.corporate_id,
       pcm.contract_ref_no,
       psu.internal_contract_item_ref_no,
       psu.contract_type,
       psu.gmr_ref_no,
       psu.stock_qty,
       psu.qty_unit,
       psu.qty_unit_id,
       psu.stock_ref_no,
       psu.qty_in_base_unit,
       to_char(psu.contract_price),
       psu.pnl_in_base_cur pnl_in_base,
       psu.base_cur_id,
       psu.base_cur_code
  from psu_phy_stock_unrealized@eka_eoddb psu,
       tdc_trade_date_closure@eka_eoddb tdc,
       (select tdc.corporate_id,
               max(tdc.trade_date) max_date
          from tdc_trade_date_closure@eka_eoddb tdc
         where tdc.process = 'EOD'
         group by tdc.corporate_id) tdc_max,
       gmr_goods_movement_record@eka_eoddb gmr,
       pcm_physical_contract_main@eka_eoddb pcm
 where psu.process_id = tdc.process_id
   and psu.corporate_id = tdc.corporate_id
   and tdc.process = 'EOD'
   and tdc.corporate_id = tdc_max.corporate_id
   and tdc.trade_date = tdc_max.max_date
   and gmr.internal_gmr_ref_no = psu.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and gmr.process_id = tdc.process_id
   and pcm.process_id = tdc.process_id
union all
select psue.psu_id,
       psue.corporate_id,
       pcm.contract_ref_no,
       psue.internal_contract_item_ref_no,
       psue.contract_type,
       psue.gmr_ref_no,
       psue. stock_wet_qty stock_qty,
       psue.qty_unit,
       psue.qty_unit_id,
       psue.stock_ref_no,
       psue.qty_in_base_unit,
       psue.contract_price_string contract_price,
       psue.pnl_in_base_cur pnl_in_base,
       psue.base_cur_id,
       psue.base_cur_code
  from psue_phy_stock_unrealized_ele@eka_eoddb psue,
       tdc_trade_date_closure@eka_eoddb tdc,
       (select tdc.corporate_id,
               max(tdc.trade_date) max_date
          from tdc_trade_date_closure@eka_eoddb tdc
         where tdc.process = 'EOD'
         group by tdc.corporate_id) tdc_max,
       gmr_goods_movement_record@eka_eoddb gmr,
       pcm_physical_contract_main@eka_eoddb pcm
 where psue.process_id = tdc.process_id
   and psue.corporate_id = tdc.corporate_id
   and tdc.process = 'EOD'
   and tdc.corporate_id = tdc_max.corporate_id
   and tdc.trade_date = tdc_max.max_date
   and gmr.internal_gmr_ref_no = psue.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and gmr.process_id = tdc.process_id
   and pcm.process_id = tdc.process_id;
/
