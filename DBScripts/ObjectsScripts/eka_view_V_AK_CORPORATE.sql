DROP VIEW V_AK_CORPORATE
/

--/* Formatted on 2011/08/08 15:24 (Formatter Plus v4.8.8) */
CREATE OR REPLACE VIEW v_ak_corporate 
AS
   SELECT akc.corporate_id, akc.corporate_name, pad.address address1,
          NULL address2, cym.country_name country, cim.city_name city,
          pad.phone phone_no, pad.fax fax_no, sm.state_code,
          sm.state_name state, pad.website website, NULL logo_name,
          NULL logo_path, NULL logo, akc.corp_display_name1,
          akc.corp_display_name2
     FROM ak_corporate akc,
          phd_profileheaderdetails phd,
          pad_profile_addresses pad,
          cim_citymaster cim,
          cym_countrymaster cym,
          sm_state_master sm
    WHERE akc.corporate_id = phd.corporate_id
      AND phd.isinternalcompany = 'Y'
      AND phd.profileid = pad.profile_id
      AND pad.address_type = 'Main'
      AND pad.country_id = cym.country_id(+)
      AND pad.city_id = cim.city_id(+)
      AND pad.is_deleted = 'N'
      AND pad.is_default = 'Y'
      --AND akc.corporate_id = cld.corporate_id(+)
   --   AND 'N' = cld.is_deleted(+)
      AND pad.state_id = sm.state_id(+)
      AND phd.is_active = 'Y'
      AND phd.is_deleted = 'N'
/

