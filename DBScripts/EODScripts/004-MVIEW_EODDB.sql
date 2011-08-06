DROP MATERIALIZED VIEW  ASH_ASSAY_HEADER;
DROP MATERIALIZED VIEW  ASM_ASSAY_SUBLOT_MAPPING;
DROP MATERIALIZED VIEW  PQCA_PQ_CHEMICAL_ATTRIBUTES;
DROP MATERIALIZED VIEW  PQPA_PQ_PHYSICAL_ATTRIBUTES;
DROP MATERIALIZED VIEW  CIPQ_CONTRACT_ITEM_PAYABLE_QTY;
DROP MATERIALIZED VIEW  DIPQ_DELIVERY_ITEM_PAYABLE_QTY;
DROP MATERIALIZED VIEW  RM_RATIO_MASTER;
DROP MATERIALIZED VIEW  AML_ATTRIBUTE_MASTER_LIST;
DROP MATERIALIZED VIEW  PPM_PRODUCT_PROPERTIES_MAPPING;
DROP MATERIALIZED VIEW  QAV_QUALITY_ATTRIBUTE_VALUES;
DROP MATERIALIZED VIEW  MDCD_M2M_DED_CHARGE_DETAILS;
DROP MATERIALIZED VIEW  MDCBM_DED_CHARGES_BY_MONTH;
DROP MATERIALIZED VIEW mv_conc_qat_quality_valuation;

DROP TABLE  ASH_ASSAY_HEADER;
DROP TABLE  ASM_ASSAY_SUBLOT_MAPPING;
DROP TABLE  PQCA_PQ_CHEMICAL_ATTRIBUTES;
DROP TABLE  PQPA_PQ_PHYSICAL_ATTRIBUTES;
DROP TABLE  CIPQ_CONTRACT_ITEM_PAYABLE_QTY;
DROP TABLE  DIPQ_DELIVERY_ITEM_PAYABLE_QTY;
DROP TABLE  RM_RATIO_MASTER;
DROP TABLE  AML_ATTRIBUTE_MASTER_LIST;
DROP TABLE  PPM_PRODUCT_PROPERTIES_MAPPING;
DROP TABLE  QAV_QUALITY_ATTRIBUTE_VALUES;
DROP TABLE  MDCD_M2M_DED_CHARGE_DETAILS;
DROP TABLE  MDCBM_DED_CHARGES_BY_MONTH;
DROP TABLE mv_conc_qat_quality_valuation;

CREATE MATERIALIZED VIEW  ASH_ASSAY_HEADER  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  ASH_ASSAY_HEADER@eka_appdb;
CREATE MATERIALIZED VIEW  ASM_ASSAY_SUBLOT_MAPPING  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  ASM_ASSAY_SUBLOT_MAPPING@eka_appdb;
CREATE MATERIALIZED VIEW  PQCA_PQ_CHEMICAL_ATTRIBUTES  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  PQCA_PQ_CHEMICAL_ATTRIBUTES@eka_appdb;
CREATE MATERIALIZED VIEW  PQPA_PQ_PHYSICAL_ATTRIBUTES  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  PQPA_PQ_PHYSICAL_ATTRIBUTES@eka_appdb;
CREATE MATERIALIZED VIEW  CIPQ_CONTRACT_ITEM_PAYABLE_QTY  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  CIPQ_CONTRACT_ITEM_PAYABLE_QTY@eka_appdb;
CREATE MATERIALIZED VIEW  DIPQ_DELIVERY_ITEM_PAYABLE_QTY  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  DIPQ_DELIVERY_ITEM_PAYABLE_QTY@eka_appdb;
CREATE MATERIALIZED VIEW  RM_RATIO_MASTER  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  RM_RATIO_MASTER@eka_appdb;
CREATE MATERIALIZED VIEW  AML_ATTRIBUTE_MASTER_LIST  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  AML_ATTRIBUTE_MASTER_LIST@eka_appdb;
CREATE MATERIALIZED VIEW  PPM_PRODUCT_PROPERTIES_MAPPING  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  PPM_PRODUCT_PROPERTIES_MAPPING@eka_appdb;
CREATE MATERIALIZED VIEW  QAV_QUALITY_ATTRIBUTE_VALUES  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  QAV_QUALITY_ATTRIBUTE_VALUES@eka_appdb;
CREATE MATERIALIZED VIEW  MDCD_M2M_DED_CHARGE_DETAILS  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  MDCD_M2M_DED_CHARGE_DETAILS@eka_appdb;
CREATE MATERIALIZED VIEW  MDCBM_DED_CHARGES_BY_MONTH  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  MDCBM_DED_CHARGES_BY_MONTH@eka_appdb;
CREATE MATERIALIZED VIEW mv_conc_qat_quality_valuation NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY AS 
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
       cpm.exch_valuation_month
  from ppm_product_properties_mapping         ppm,
       qav_quality_attribute_values           qav,
       qat_quality_attributes                 qat,
       pdd_product_derivative_def             pdd,
       dim_der_instrument_master              dim,
       irm_instrument_type_master             irm,
       cpm_corporateproductmaster             cpm
 where ppm.property_id = qav.attribute_id
   and qav.comp_quality_id = qat.quality_id
   and qat.instrument_id=pdd.derivative_def_id
   and qat.product_id=pdd.product_id
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
   and ppm.is_deleted = 'N';
/