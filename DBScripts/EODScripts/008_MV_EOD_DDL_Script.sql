drop materialized view  spq_stock_payable_qty;
drop table spq_stock_payable_qty;
create materialized view  spq_stock_payable_qty  refresh fast on demand with primary key as  select * from  spq_stock_payable_qty@eka_appdb;
create or replace view  v_gmr_stockpayable_qty as
select   spq.internal_gmr_ref_no,
         spq.internal_grd_ref_no,
         spq.internal_dgrd_ref_no,
         spq.stock_type,
         spq.element_id,
         sum (spq.payable_qty) payable_qty,
         spq.qty_unit_id
       from spq_stock_payable_qty spq
      where spq.is_active = 'y'
   group by spq.internal_gmr_ref_no,
            spq.stock_type,
            spq.element_id,
            spq.qty_unit_id,
            spq.internal_grd_ref_no,
            spq.internal_dgrd_ref_no
/