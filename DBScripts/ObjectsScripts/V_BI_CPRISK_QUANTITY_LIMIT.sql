CREATE OR REPLACE VIEW V_BI_CPRISK_QUANTITY_LIMIT AS
select 'EKA' corporate_id,
       phd.profileid,
       phd.companyname,
       5000 * rownum alloted_quantity_limit,
       round(71000 * 1 / rownum, 3) current_quantity_usage,
       'QUM-68' base_qty_unit_id,
       'MT' base_qty_unit
  from phd_profileheaderdetails phd
 where rownum <= 5
 order by phd.profileid desc
