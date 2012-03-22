create or replace view V_BI_CPRISK_CRC_LIMITS AS
select t.profile_id,
       t.corporate_id,
       t.corporate_name,
       t.org_level_id,
       sum(t.qty_exposure) qty_exposure,
       sum(t.value_exposure) value_exposure,
       sum(t.mtm_exposure) mtm_exposure,
       sum(t.net_exposure_limit) net_exposure_limit,
       t.exposure_qty_unit_id,
       t.exposure_curr_id
  from (select crc.limit_id profile_id,
               crc.org_id corporate_id,
               crc.limit_label corporate_name,
               crc.org_level_id,
               sum(nvl(crc.qty_exposure, 0)) qty_exposure,
               sum(nvl(crc.value_exposure, 0)) value_exposure,
               sum(nvl(crc.mtm_exposure, 0)) mtm_exposure,
               sum(nvl(crc.net_exposure_limit, 0)) net_exposure_limit,
               crc.exposure_qty_unit_id,
               crc.exposure_curr_id
          from v_crc_cp_risk_limits crc,
               ak_corporate         akc
         where crc.org_level_id = 'Corporate'
           and crc.org_id = akc.corporate_id
         group by crc.limit_id,
                  crc.org_id,
                  crc.limit_label,
                  crc.org_level_id,
                  crc.exposure_qty_unit_id,
                  crc.exposure_curr_id
        union all
        select crc.limit_id profile_id,
               cpc.corporateid corporate_id,
               akc.corporate_name corporate_name,
               'Corporate' org_level_id,
               sum(nvl(crc.qty_exposure, 0)) qty_exposure,
               sum(nvl(crc.value_exposure, 0)) value_exposure,
               sum(nvl(crc.mtm_exposure, 0)) mtm_exposure,
               sum(nvl(crc.net_exposure_limit, 0)) net_exposure_limit,
               crc.exposure_qty_unit_id,
               crc.exposure_curr_id
          from v_crc_cp_risk_limits        crc,
               cpc_corporate_profit_center cpc,
               ak_corporate                akc
         where crc.org_level_id = 'ProfitCenter'
           and crc.org_id = cpc.profit_center_id
           and cpc.corporateid = akc.corporate_id
         group by crc.limit_id,
                  cpc.corporateid,
                  akc.corporate_name,
                  crc.exposure_qty_unit_id,
                  crc.exposure_curr_id) t
 group by t.profile_id,
          t.corporate_id,
          t.corporate_name,
          t.org_level_id,
          t.exposure_qty_unit_id,
          t.exposure_curr_id
