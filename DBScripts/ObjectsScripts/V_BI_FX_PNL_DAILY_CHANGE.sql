CREATE OR REPLACE VIEW V_BI_FX_PNL_DAILY_CHANGE AS 
select corporate_id,
       profit_center_id,
       profit_center_name,
       cur_pair_id currency_pair_id,
       cur_pair_name currency_pair_name,
       current_amount,
       previous_amount,
       change change_percentage, -- as per FS change is shown as it's, not by percentage
       corp_cur_id base_cur_code,
       corp_currency base_cur_id
  from mv_unpnl_ccy_by_instrument
