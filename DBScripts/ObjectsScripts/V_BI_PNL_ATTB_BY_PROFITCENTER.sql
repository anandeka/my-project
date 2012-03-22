CREATE OR REPLACE VIEW V_BI_PNL_ATTB_BY_PROFITCENTER
as
select mvb.corporate_id,
       mvb.profit_center_id,
       mvb.profit_center_name,
       mvb.product_id,
       mvb.product_name,
       mvb.attribution_type,
       mvb.attribution_order,
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
/*       (case
         when t.ss = 1 then
          'New Contract'
         when t.ss = 2 then
          'Quantity'
         when t.ss = 3 then
          'Pricing'
         when t.ss = 4 then
          'Derivative Prices'
         when t.ss = 5 then
          'Location differentials'
         else
          'Others'
       end) attribution_type,*/
  from mv_bi_upad mvb
 group by mvb.corporate_id,
          mvb.profit_center_id,
          mvb.profit_center_name,
          mvb.product_id,
          mvb.product_name,
          mvb.attribution_type,
          mvb.attribution_order,
          mvb.base_cur_code,
          mvb.base_cur_id,
          mvb.trade_date,
          mvb.prev_trade_date
