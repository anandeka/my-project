CREATE OR REPLACE VIEW V_BI_CPRISK_M2M_LIMIT AS
select 'EKA' corporate_id,
       phd.profileid,
       phd.companyname,
       4563 * rownum alloted_m2m_limit,
       7818 * rownum / 2 current_m2m_usage,
       'CM-61' base_cur_id,
       'USD' base_cur_code
  from phd_profileheaderdetails phd
 where rownum <= 5
 order by phd.profileid desc
