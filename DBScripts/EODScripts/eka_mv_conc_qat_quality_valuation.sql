drop materialized view mv_conc_qat_quality_valuation;
create materialized view mv_conc_qat_quality_valuation nocache
logging
nocompress
noparallel
build immediate
refresh force on demand
with primary key as 
select ppm.product_id conc_product_id,
       qav.quality_id conc_quality_id,
       ppm.attribute_id,
       cpm.corporate_id,
       qat.quality_id,
       pdd.product_id,
       qat.quality_name,
       dim.instrument_id,
       pdd.derivative_def_id,
       dim.product_derivative_id,
       qat.eval_basis,
       qat.date_type,
       qat.ship_arrival_date,
       qat.ship_arrival_days,
       nvl(qat.exch_valuation_month,'Closest') exch_valuation_month
  from ppm_product_properties_mapping ppm,
       qav_quality_attribute_values qav,
       qat_quality_attributes qat,
       pdd_product_derivative_def pdd,
       dim_der_instrument_master dim,
       irm_instrument_type_master irm,
       cpm_corporateproductmaster cpm
 where ppm.property_id = qav.attribute_id
   and qav.comp_quality_id = qat.quality_id
   and qat.instrument_id = pdd.derivative_def_id
   and qat.product_id = pdd.product_id
   and pdd.derivative_def_id = dim.product_derivative_id
   and pdd.product_id = cpm.product_id
   and dim.instrument_type_id = irm.instrument_type_id
   and irm.instrument_type = 'Future'
   and qat.is_active = 'Y'
   and qat.is_deleted = 'N'
   and pdd.is_active = 'Y'
   and pdd.is_deleted = 'N'
   and dim.is_active = 'Y'
   and dim.is_deleted = 'N'
   and irm.is_active = 'Y'
   and irm.is_deleted = 'N'
   and cpm.is_active = 'Y'
   and cpm.is_deleted = 'N'
   and qav.is_deleted = 'N'
   and qav.is_comp_product_attribute = 'Y'
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and qat.eval_basis='DIFFERENTIAL'  
   union all
   select ppm.product_id conc_product_id,
       qav.quality_id conc_quality_id,
       ppm.attribute_id,
       cpm.corporate_id,
       qat.quality_id, 
       pdm.product_id,
       qat.quality_name,
       null instrument_id,
       null derivative_def_id,
       null product_derivative_id,
       qat.eval_basis,
       qat.date_type,
       qat.ship_arrival_date,
       qat.ship_arrival_days,
       nvl(qat.exch_valuation_month,'Closest') exch_valuation_month
  from ppm_product_properties_mapping ppm,
       qav_quality_attribute_values qav,
       qat_quality_attributes qat,
       pdm_productmaster pdm,
       cpm_corporateproductmaster cpm
 where ppm.property_id = qav.attribute_id
   and qav.comp_quality_id = qat.quality_id
   and qat.product_id=pdm.product_id
   and pdm.product_id=cpm.product_id
   and qat.is_active = 'Y'
   and qat.is_deleted = 'N'
   and cpm.is_active = 'Y'
   and cpm.is_deleted = 'N'
   and qav.is_deleted = 'N'
   and qav.is_comp_product_attribute = 'Y'
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and pdm.is_active='Y'
   and pdm.is_deleted='N'
   and qat.eval_basis='FIXED';
   
