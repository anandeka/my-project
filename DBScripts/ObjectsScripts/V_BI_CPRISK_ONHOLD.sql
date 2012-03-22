CREATE OR REPLACE VIEW V_BI_CPRISK_ONHOLD AS
select 'EKA' corporate_id,
       phd.profileid,
       phd.companyname,
       rownum order_id
  from phd_profileheaderdetails phd
 where rownum <= 5
 order by phd.profileid asc
