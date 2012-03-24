create or replace view v_bi_pnl_attb_by_profitcenter as
select mvb.corporate_id,
       mvb.product_id profit_center_id, --to demo
       mvb.product_name profit_center_name, --to demo
       mvb.product_id,
       mvb.product_name,
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
       sum(mvb.pnlc_due_to_attr) pnl,
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
       end) prev_eod_date
  from mv_bi_upad mvb
 group by mvb.corporate_id,
          mvb.product_id,
          mvb.product_name,
          mvb.base_cur_code,
          mvb.base_cur_id,
          mvb.trade_date,
          mvb.prev_trade_date,
          (case
            when mvb.attribution_type = 'Derivative Prices' then
             'Market Price'
            else
             mvb.attribution_type
          end),
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
          end)
