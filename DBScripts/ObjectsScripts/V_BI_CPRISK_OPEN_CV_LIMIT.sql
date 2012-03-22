CREATE OR REPLACE VIEW V_BI_CPRISK_OPEN_CV_LIMIT AS
select 'EKA' corporate_id,
       phd.profileid,
       phd.companyname,
       41563 * rownum alloted_open_cv_limit,
       round(78181 * (rownum / 2), 3) current_open_cv_usage,
       'CM-61' base_cur_id,
       'USD' base_cur_code
  from phd_profileheaderdetails phd
 where rownum <= 5
 order by phd.profileid desc
