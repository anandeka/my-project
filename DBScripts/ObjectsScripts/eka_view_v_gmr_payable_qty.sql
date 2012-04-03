create or replace view v_gmr_payable_qty as
select spq.internal_gmr_ref_no,
       spq.stock_type,
       spq.element_id,
       sum(spq.payable_qty) payable_qty,
       spq.qty_unit_id
  from spq_stock_payable_qty spq
 where spq.is_active = 'Y'
  and spq.is_stock_split='N'
 group by spq.internal_gmr_ref_no,
          spq.stock_type,
          spq.element_id,
          spq.qty_unit_id;
 
 
 
 
 
 
