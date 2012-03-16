CREATE OR REPLACE VIEW V_BI_PNL_CHANGE_BY_TRADE AS
select corporate_id,
       profit_center_id,
       profit_center_name,
       internal_contract_item_ref_no,
       contract_ref_no,
       current_per_unit current_amount,
       previous_per_unit previous_amount,
       change_percentage,
       percentage_value,
       base_cur_code,
       base_cur_id
  from mv_unpnl_phy_change_by_trade
