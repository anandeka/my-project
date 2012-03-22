CREATE OR REPLACE VIEW V_BI_PNL_ATTB_BY_PRODUCT AS
select corporate_id,
       product_id,
       product_name,
       sum(pnlc_due_to_attr) pnl,
       base_cur_id,
       base_cur_code,
       cur_eod_date,
       prev_eod_date
  from v_bi_pnl_attb_by_trade
 group by corporate_id,
          product_id,
          product_name,
          base_cur_id,
          base_cur_code,
          cur_eod_date,
          prev_eod_date

