CREATE OR REPLACE VIEW v_gmr_payable_qty (process_id,
                                          internal_gmr_ref_no,
                                          element_id,
                                          payable_qty,
                                          qty_unit_id)
AS
  select spq.process_id,
       spq.internal_gmr_ref_no,
       spq.element_id,
       sum(nvl(spq.payable_qty,0)) payable_qty,
       spq.qty_unit_id
  from spq_stock_payable_qty spq
 where spq.is_active = 'Y'
   and spq.is_stock_split = 'N'
   and spq.payable_qty > 0
 group by spq.process_id,
          spq.internal_gmr_ref_no,
          spq.element_id,
          spq.qty_unit_id;

