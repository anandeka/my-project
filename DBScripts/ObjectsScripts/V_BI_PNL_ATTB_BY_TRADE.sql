create or replace view v_bi_pnl_attb_by_trade as
select mvb.corporate_id,
       mvb.profit_center_id,
       mvb.profit_center_name,
       mvb.product_id,
       mvb.product_name,
      /* mvb.attribution_type,
       mvb.attribution_order,*/
     (case
         when mvb.attribution_type = 'Derivative Prices' then
          'Market Price'
         else
          mvb.attribution_type
       end) attribution_type,
       (case
         when mvb.attribution_type = 'New Contract' then
          1
         when mvb.attribution_type = 'Quantity' then
          2
         when mvb.attribution_type = 'Pricing' then
          3
         when mvb.attribution_type = 'Derivative Prices' then
          4
         when mvb.attribution_type = 'Estimates' then
          5
         when mvb.attribution_type = 'Location differentials' then
          6
         else
          mvb.attribution_order
       end) attribution_order,       
       mvb.contract_ref_no,
       mvb.contract_type,
       mvb.base_cur_code,
       mvb.base_cur_id,
         (case
         when mvb.trade_date is not null then
          to_char(mvb.trade_date, 'dd-Mon-yyyy')
         else
          ''
       end) cur_eod_date,
       (case
         when mvb.prev_trade_date is not null then
          to_char(mvb.prev_trade_date, 'dd-Mon-yyyy')
         else
          ''
       end) prev_eod_date,
       mvb.pnlc_due_to_attr,
       mvb.delta_pnlc_in_base,
       mvb.net_pnlc_in_base
  from mv_bi_upad mvb
