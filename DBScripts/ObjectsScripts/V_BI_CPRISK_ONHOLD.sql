CREATE OR REPLACE VIEW V_BI_CPRISK_ONHOLD AS
select akc.corporate_id corporate_id,
       phd.profileid,
       phd.companyname,
       rownum order_id
  from phd_profileheaderdetails  phd,
       gcd_groupcorporatedetails gcd,
       ak_corporate              akc
 where phd.group_id = gcd.groupid
   and phd.isinternalcompany = 'N'
   and gcd.groupid = akc.groupid
   and nvl(phd.is_credit_hold, 'N') = 'Y'
-- and rownum <= 5
-- order by phd.profileid asc
