CREATE OR REPLACE VIEW V_BI_EXPOSURE_BY_RECENT_TRADE AS
select vbi.corporate_id,
       vbi.product_id,
       vbi.product_name,
       vbi.contract_ref_no internal_contract_item_ref_no,
       vbi.trade_type trade_type,
       vbi.contract_ref_no,
       vbi.issue_date,
       row_number() over(partition by vbi.corporate_id, vbi.product_id, vbi.trade_type order by vbi.corporate_id, vbi.product_id) dispay_order,
       vbi.position_quantity quantity,
       vbi.qty_unit_id base_qty_unit_id,
       vbi.base_qty_unit
  from v_bi_recent_trades_by_product vbi
