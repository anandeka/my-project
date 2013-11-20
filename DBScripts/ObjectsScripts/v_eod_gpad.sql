create or replace view v_eod_gpad as
select gpad_id,
       gpah_id,
       pfd_id,
       allocated_qty,
       version,
       is_active
  from gpad_gmr_price_alloc_dtls@eka_eoddb
/