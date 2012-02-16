create materialized view  cci_corp_currency_instrument  refresh fast on demand with primary key as  select * from  cci_corp_currency_instrument@eka_appdb;

create materialized view mv_cfq_cci_cur_forward_quotes 
nocache
logging
nocompress
noparallel
build immediate
refresh force on demand
with primary key
as 
select cfq.corporate_id,
       drm.prompt_date,
       drm.dr_id_name,
       cfqd.dr_id,
       cfq.trade_date,
       cfq.instrument_id,
       dim.instrument_name,
       cfq.price_source_id,
       pdm.product_id,
       pdm.product_desc currency_pair,
       pdm.base_cur_id,
       pdm.quote_cur_id,
       cfqd.rate,
       cfqd.forward_point,
       cfqd.is_spot
  from cfq_currency_forward_quotes    cfq,
       dim_der_instrument_master      dim,
       pdd_product_derivative_def     pdd,
       pdm_productmaster              pdm,
       ps_price_source                ps,
       drm_derivative_master          drm,
       cfqd_currency_fwd_quote_detail cfqd,
       cci_corp_currency_instrument   cci
 where cfq.instrument_id = dim.instrument_id
   and cfq.price_source_id = ps.price_source_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.product_id = pdm.product_id
   and cfqd.dr_id = drm.dr_id
   and cfqd.cfq_id = cfq.cfq_id
   and cfq.corporate_id = cci.corporate_id
   and cci.instrument_id = dim.instrument_id
   and cci.is_deleted = 'N'
   and cfqd.is_deleted = 'N'
   and cfq.is_deleted = 'N'
   and dim.is_active = 'Y'
   and pdd.is_active = 'Y'
   and pdm.is_active = 'Y';