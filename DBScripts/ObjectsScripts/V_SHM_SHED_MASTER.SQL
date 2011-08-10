CREATE OR REPLACE VIEW V_SHM_SHED_MASTER
AS 
SELECT bpsld.bpsld_id,
       bpsld.profile_id,
       phd.company_long_name1,
       phd.companyname,
       sld.storage_loc_id,
       sld.storage_loc_id shed_id,
       sld.storage_location_name shed_name,
       NULL port_id,
       sld.address address,
       sld.country_id country_id,
       sld.city_id city_id,
       sld.zipcode zipcode,
       sld.is_active is_active,
       sld.state_id state_id,
       sld.phone phone,
       sld.fax fax,
       NULL shed_in_use,
       sld.is_auto_rent_recording is_auto_record_rent,
       sld.warehouse_rent warehouse_rent,
       sld.no_of_free_days free_days,
       sld.warehouse_rent_currency_id warehouse_rent_cur_id,
       sld.warehouse_rent_period_type_id warehouse_rent_period
FROM   bpsld_bp_storage_loc_det    bpsld,
       sld_storage_location_detail sld,
       phd_profileheaderdetails    phd
WHERE  bpsld.storage_loc_id = sld.storage_loc_id
AND    bpsld.profile_id = phd.profileid
AND    bpsld.is_deleted = 'N'
AND    sld.is_deleted = 'N';