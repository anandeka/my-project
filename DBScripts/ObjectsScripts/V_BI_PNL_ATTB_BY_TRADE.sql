CREATE OR REPLACE VIEW V_BI_PNL_ATTB_BY_TRADE
AS
select mvb.corporate_id,
       mvb.profit_center_id,
       mvb.profit_center_name,
       mvb.product_id,
       mvb.product_name,
       mvb.attribution_type,
       mvb.attribution_order,
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
