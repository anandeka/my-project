CREATE OR REPLACE VIEW V_BI_CPRISK_CREDIT_LIMIT AS
select 'EKA' corporate_id,
       phd.profileid,
       phd.companyname,
       1000 * rownum alloted_credit_limit,
       700 * rownum current_credit_usage,
       'CM-61' base_cur_id,
       'USD' base_cur_code
  from phd_profileheaderdetails phd
 where rownum <= 5
 order by phd.profileid desc
