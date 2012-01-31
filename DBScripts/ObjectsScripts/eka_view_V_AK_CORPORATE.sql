create or replace view v_ak_corporate as
select akc.corporate_id,
       akc.corporate_name,
       pad.address address1,
       null address2,
       null address3,
       null address4,
       -- cim.city_name city1,
       -- cym.country_name country1,
       -- cm.cur_name base_currency_name,
       null           city1,
       null           country1,
       cm.cur_name    base_currency_name,
       null           abn_number,
       rm.region_name region,
       --       cym.country_name country,
       --       cim.city_name city,
       null country,
       null city,
       pad.phone phone_no,
       pad.fax fax_no,
       pad.email,
       sm.state_code,
       sm.state_name state,
       pad.website website,
       null logo_name,
       akl.corporate_image logo_path,
       null logo,
       akc.corp_display_name1,
       akc.corp_display_name2,
       pad.zip,
       akl.footeraddress,
       akl.headeraddress
  from ak_corporate             akc,
       phd_profileheaderdetails phd,
       pad_profile_addresses    pad,
       cim_citymaster           cim,
       cym_countrymaster        cym,
       --cld_corporate_logo_detail cld,
       sm_state_master    sm,
       cm_currency_master cm,
       rem_region_master  rm,
       ak_corporate_logo  akl
 where akc.corporate_id = phd.corporate_id
   and phd.profileid = pad.profile_id(+)
   and pad.address_type(+) = 'Main'
   and pad.country_id = cym.country_id(+)
   and pad.city_id = cim.city_id(+)
   and pad.is_deleted(+) = 'N'
   and pad.is_default(+) = 'Y'
   and akc.corporate_id = akl.corporate_id(+)
   and pad.state_id = sm.state_id(+)
   and cym.region_id = rm.region_id(+)
   and phd.is_active = 'Y'
   and phd.isinternalcompany = 'Y'
   and phd.is_deleted = 'N'
   and akc.base_cur_id = cm.cur_id;
