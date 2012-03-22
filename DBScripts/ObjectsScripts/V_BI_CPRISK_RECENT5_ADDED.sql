CREATE OR REPLACE VIEW V_BI_CPRISK_RECENT5_ADDED AS
select 'EKA' corporate_id,
       phd.profileid,
       phd.companyname,
       rownum order_id,
       to_char(sysdate - rownum, 'dd-Mon-yyyy') added_date
  from phd_profileheaderdetails phd
 where rownum <= 5
 order by phd.profileid asc
