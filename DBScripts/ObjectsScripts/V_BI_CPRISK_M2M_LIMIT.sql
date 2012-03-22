CREATE OR REPLACE VIEW V_BI_CPRISK_M2M_LIMIT AS
select tt.corporate_id,
       tt.profileid,
       tt.companyname,
       nvl(cpr.mtm_exposure,0) alloted_m2m_limit,
       tt.current_m2m_usage,
       tt.current_m2m_usage - nvl(cpr.mtm_exposure,0) breach,
       tt.order_id,
       tt.base_cur_id,
       tt.base_cur_code
  from (select t.corporate_id,
               t.cp_id profileid,
               t.cp_name companyname,
               0 alloted_m2m_limit,
               sum(t.unrealized_pnl_in_base_cur) current_m2m_usage,
               rank() over(partition by t.corporate_id order by sum(t.unrealized_pnl_in_base_cur) desc) order_id,
               t.base_cur_id,
               t.base_cur_code
          from mv_fact_physical_unrealized t
         where t.position_sub_type in ('Open Sales', 'Open Purchase')
         group by t.corporate_id,
                  t.corporate_id,
                  t.cp_id,
                  t.cp_name,
                  t.base_cur_id,
                  t.base_cur_code) tt,
       v_bi_cprisk_crc_limits cpr
 where tt.profileid = cpr.profile_id(+)
   and tt.corporate_id = cpr.corporate_id(+)
   and tt.order_id <= 5
 
