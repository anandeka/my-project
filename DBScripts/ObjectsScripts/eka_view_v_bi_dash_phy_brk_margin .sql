create or replace view v_bi_dash_phy_brk_margin as
select mv_brok.corporate_id,
       mv_brok.process_id,
       mv_brok.eod_date,
       mv_brok.broker_name,
       mv_brok.instrument_name exchange_product,
       mv_brok.initial_margin_limit im_limit,
       mv_brok.initial_margin_requirement im_utilization,
       (mv_brok.initial_margin_limit - mv_brok.initial_margin_requirement) im_headroom
  from mv_fact_broker_margin_util mv_brok;
