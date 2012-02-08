create or replace view V_LIST_BASE_VS_CONC_PRODUCT
as
SELECT aml.attribute_id element_id,
       aml.attribute_name element_name,
       aml.underlying_product_id base_product_id,
       pdm_base.product_desc base_product_name,
       qav.comp_quality_id base_quality_id,
       qat_base.long_desc base_quality_name,
       ppm.product_id,
       pdm.product_desc product_name,
       qav.quality_id quality_id,
       qat.long_desc quality_name
FROM   aml_attribute_master_list      aml,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       pdm_productmaster              pdm_base,
       qat_quality_attributes         qat_base,
       pdm_productmaster              pdm,
       qat_quality_attributes         qat
WHERE  aml.attribute_id = ppm.attribute_id
AND    aml.is_active = 'Y'
AND    aml.is_deleted = 'N'
AND    ppm.is_active = 'Y'
AND    ppm.is_deleted = 'N'
AND    qav.attribute_id = ppm.property_id
AND    qav.is_deleted = 'N'
AND    pdm.product_id = ppm.product_id
AND    pdm.is_active = 'Y'
AND    pdm.is_deleted = 'N'
AND    qat.quality_id = qav.quality_id
AND    qat.product_id = ppm.product_id
AND    qat.is_active = 'Y'
AND    qat.is_deleted = 'N'
AND    aml.underlying_product_id IS NOT NULL
AND    qav.comp_quality_id IS NOT NULL
AND    pdm_base.product_id = aml.underlying_product_id
AND    pdm_base.is_active = 'Y'
AND    pdm_base.is_deleted = 'N'
AND    qat_base.quality_id = qav.comp_quality_id
AND    qat_base.product_id = aml.underlying_product_id
AND    qat_base.is_active = 'Y'
AND    qat_base.is_deleted = 'N';
