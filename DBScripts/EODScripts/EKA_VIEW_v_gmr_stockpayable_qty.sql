create or replace view  v_gmr_stockpayable_qty 
AS
	select spq.process_id,
		   spq.internal_gmr_ref_no,
		   spq.internal_grd_ref_no,
		   spq.internal_dgrd_ref_no,
		   spq.stock_type,
		   spq.element_id,
		   sum(spq.payable_qty) payable_qty,
		   spq.qty_unit_id
	  from spq_stock_payable_qty spq
	 where spq.is_active = 'Y'
	   and spq.is_stock_split = 'N'
	 group by spq.process_id,
			  spq.internal_gmr_ref_no,
			  spq.stock_type,
			  spq.element_id,
			  spq.qty_unit_id,
			  spq.internal_grd_ref_no,
			  spq.internal_dgrd_ref_no;