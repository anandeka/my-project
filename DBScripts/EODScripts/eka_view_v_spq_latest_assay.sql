create or replace view v_spq_latest_assay as
select spq.process_id,
       spq.dbd_id,
       spq.internal_gmr_ref_no,
       spq.internal_grd_ref_no,
       spq.assay_header_id
  from spq_stock_payable_qty spq
 where spq.is_stock_split = 'N'
 group by spq.internal_gmr_ref_no,
          spq.internal_grd_ref_no,
          spq.assay_header_id,
          spq.process_id,
          spq.dbd_id
