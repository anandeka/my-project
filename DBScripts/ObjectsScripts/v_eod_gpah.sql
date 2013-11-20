create or replace view v_eod_gpah as
select gpah_id,
       internal_gmr_ref_no,
       element_id,
       total_qty_to_be_allocated,
       final_price,
       finalize_date,
       avg_price_in_price_currency,
       avg_fx,
       qty_unit_id,
       pocd_id,
       is_active,
       version,
       total_allocated_qty,
       final_price_in_pricing_cur
  from gpah_gmr_price_alloc_header@eka_eoddb
/