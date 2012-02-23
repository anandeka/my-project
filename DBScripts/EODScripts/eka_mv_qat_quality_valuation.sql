drop materialized view mv_qat_quality_valuation; 
CREATE MATERIALIZED VIEW mv_qat_quality_valuation NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY AS 
select cpm.corporate_id,
       qat.quality_id,
       pdd.product_id,
       qat.quality_name,
       dim.instrument_id,
       pdd.derivative_def_id derivative_def_id,
       dim.product_derivative_id product_derivative_id,
       qat.eval_basis,
       qat.date_type,
       qat.ship_arrival_date,
       qat.ship_arrival_days,
       nvl(qat.exch_valuation_month, 'Closest') exch_valuation_month
  from qat_quality_attributes qat,
       pdd_product_derivative_def pdd,
       pdtm_product_type_master pdtm,
       pdm_productmaster pdm,
       (select dim.product_derivative_id,
               dim.instrument_id
          from dim_der_instrument_master  dim,
               pdd_product_derivative_def pdd,
               irm_instrument_type_master irm
         where pdd.derivative_def_id = dim.product_derivative_id
           and dim.instrument_type_id = irm.instrument_type_id
           and irm.instrument_type = 'Future'
           and dim.is_active = 'Y'
           and dim.is_deleted = 'N'
           and irm.is_active = 'Y'
           and irm.is_deleted = 'N'
         group by dim.product_derivative_id,
                  dim.instrument_id) dim,
       cpm_corporateproductmaster cpm
 where qat.product_id = pdd.product_id
   and qat.instrument_id = pdd.derivative_def_id
   and pdd.derivative_def_id = dim.product_derivative_id(+)
   and qat.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdtm.product_type_name = 'Standard'
   and pdd.product_id = cpm.product_id
   and qat.is_active = 'Y'
   and qat.is_deleted = 'N'
   and pdd.is_active = 'Y'
   and pdd.is_deleted = 'N'
   and cpm.is_active = 'Y'
   and cpm.is_deleted = 'N'
   and qat.eval_basis = 'DIFFERENTIAL'
union all
select cpm.corporate_id,
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
       nvl(qat.exch_valuation_month, 'Closest') exch_valuation_month
  from qat_quality_attributes     qat,
       pdm_productmaster          pdm,
       pdtm_product_type_master   pdtm,
       cpm_corporateproductmaster cpm
 where qat.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdtm.product_type_name = 'Standard'
   and pdm.product_id = cpm.product_id
   and qat.is_active = 'Y'
   and qat.is_deleted = 'N'
   and pdm.is_active = 'Y'
   and pdm.is_deleted = 'N'
   and cpm.is_active = 'Y'
   and cpm.is_deleted = 'N'
   and qat.eval_basis = 'FIXED';
