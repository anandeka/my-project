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
  from traxys_crc_dev.rle_risk_limit_exposure rle,
       traxys_crc_dev.rlt_risk_limit_type     rlt,
       traxys_crc_dev.cle_cp_limit_exposure   cle
 where rle.is_delted = 'N'
   and rle.rlt_id = rlt.rlt_id
   and rlt.risk_type = 'CP RISK LIMIT'
   and rle.cle_id = cle.cle_id(+)
/
