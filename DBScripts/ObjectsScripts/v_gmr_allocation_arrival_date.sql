-- This view created for the purpose of reports
-- used in daily detailed price exposure report from 14-Mar-2013
create or replace view v_gmr_allocation_arrival_date as 
select gpad.pfd_id,
       agmr.internal_gmr_ref_no,
       max(agmr.eff_date) keep(dense_rank last order by agmr.action_no) over(partition by agmr.internal_gmr_ref_no) arrival_date
  from gpah_gmr_price_alloc_header gpah,
       gpad_gmr_price_alloc_dtls   gpad,
       agmr_action_gmr             agmr
 where gpah.gpah_id = gpad.gpah_id
   and gpah.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and gpah.is_active = 'Y'
   and gpad.is_active = 'Y'
   and gpad.allocated_qty <> 0
   and agmr.gmr_latest_action_action_id in
       ('landingDetail', 'warehouseReceipt')
/