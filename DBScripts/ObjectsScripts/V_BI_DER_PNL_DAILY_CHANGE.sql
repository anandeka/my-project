create or replace view v_bi_der_pnl_daily_change as
select corporate_id,
       profit_center_id,
       profit_center_name,
       instrument_id,
       instrument_name,
       current_amount,
       previous_amount,
       change change_percentage, -- as per FS change is shown as it's, not by percentage
       base_cur_code,
       base_cur_id
  from mv_unpnl_drt_by_instrument
