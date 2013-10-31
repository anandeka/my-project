create or replace view v_cp_exposure_limit as
select crc.limit_id profile_id,
       crc.org_id corporate_id,
       crc.limit_label corporate_name,
       crc.org_level_id,
       sum(nvl(crc.net_exposure_limit, 0)) net_exposure_limit,
       crc.exposure_curr_id,
       sum((case
             when nvl(crc.net_exposure_limit, 0) <> 0 then
              (case
             when crc.exposure_curr_id <> akc.base_cur_id then
              pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                       crc.exposure_curr_id,
                                                       akc.base_cur_id,
                                                       sysdate,
                                                       1)
             else
              1
           end) * nvl(crc.net_exposure_limit, 0) else 0 end)) net_exposure_limit_in_base_cur,
       akc.base_cur_id
  from v_crc_cp_risk_limits crc,
       ak_corporate         akc
 where crc.org_level_id = 'Corporate'
   and crc.org_id = akc.corporate_id
 group by crc.limit_id,
          crc.org_id,
          crc.limit_label,
          crc.org_level_id,
          crc.exposure_curr_id,
          akc.base_cur_id
union all
select crc.limit_id profile_id,
       cpc.corporateid corporate_id,
       akc.corporate_name corporate_name,
       'Corporate' org_level_id,
       sum(nvl(crc.net_exposure_limit, 0)) net_exposure_limit,
       crc.exposure_curr_id,
       sum((case
             when nvl(crc.net_exposure_limit, 0) <> 0 then
              (case
             when crc.exposure_curr_id <> akc.base_cur_id then
              pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                       crc.exposure_curr_id,
                                                       akc.base_cur_id,
                                                       sysdate,
                                                       1)
             else
              1
           end) * nvl(crc.net_exposure_limit, 0) else 0 end)) net_exposure_limit_in_base_cur,
       akc.base_cur_id
  from v_crc_cp_risk_limits        crc,
       cpc_corporate_profit_center cpc,
       ak_corporate                akc
 where crc.org_level_id = 'ProfitCenter'
   and crc.org_id = cpc.profit_center_id
   and cpc.corporateid = akc.corporate_id
 group by crc.limit_id,
          cpc.corporateid,
          akc.corporate_name,
          crc.exposure_curr_id,
          akc.base_cur_id
/