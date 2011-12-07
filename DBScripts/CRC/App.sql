--Run this from App Schema
define CRC_SCHEMA=CRC_SCHEMA.

create or replace view v_crc_cp_risk_limits as
select rle_id,
       rle.cle_id,
       rlt.rlt_id,
       limit_id,
       product_id,
       org_id,
       org_level_id,
       limit_label,
       product_label,
       org_label,
       org_level_label,
       is_aggregate_higher_level,
       contract_type,
       start_date_month,
       start_date_year,
       end_date_month,
       end_date_year,
       nvl(qty_exposure, 0) qty_exposure,
       nvl(value_exposure, 0) value_exposure,
       nvl(mtm_exposure, 0) mtm_exposure,
       mtm_exposure_limit_dur,
       nvl(current_exposure,0)current_exposure,   
       nvl(cle.net_exposure_limit, 0) net_exposure_limit,
       exposure_curr_id,
       exposure_qty_unit_id
  from &CRC_SCHEMA.rle_risk_limit_exposure rle,
       &CRC_SCHEMA.rlt_risk_limit_type     rlt,
      &CRC_SCHEMA.cle_cp_limit_exposure   cle
 where rle.is_delted = 'N'
   and rle.rlt_id = rlt.rlt_id
   and rlt.risk_type = 'CP RISK LIMIT'
   and rle.cle_id = cle.cle_id(+);
/
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
          akc.base_cur_id;
	  
/
