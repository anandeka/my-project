create or replace view  v_gmr_stockpayable_qty 
AS
   SELECT   spq.process_id,spq.internal_gmr_ref_no, spq.internal_grd_ref_no,
            spq.internal_dgrd_ref_no, spq.stock_type, spq.element_id,
            SUM (spq.payable_qty) payable_qty, spq.qty_unit_id
       FROM spq_stock_payable_qty spq
      WHERE spq.is_active = 'Y'
   GROUP BY spq.process_id,
            spq.internal_gmr_ref_no,
            spq.stock_type,
            spq.element_id,
            spq.qty_unit_id,
            spq.internal_grd_ref_no,
            spq.internal_dgrd_ref_no;