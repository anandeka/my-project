CREATE OR REPLACE VIEW V_METAL_ACCOUNTS
AS
SELECT debt_temp.corporate_id,
       debt_temp.supplier_id supplier_id,
       phd.companyname supplier_name,
       debt_temp.product_id product_id,
       debt_temp.product_name product_name,
       SUM(debt_temp.total_qty) total_qty,
       debt_temp.qty_unit_id qty_unit_id,
       qum.qty_unit qty_unit
FROM   (SELECT returnable_temp.corporate_id,
               returnable_temp.supplier_id supplier_id,
               returnable_temp.product_id,
               returnable_temp.product_name,
               -1 * SUM(returnable_temp.total_qty) total_qty,
               returnable_temp.qty_unit_id,
               returnable_temp.qty_type
        FROM   (SELECT axs.corporate_id,
                       prrqs.supplier_cp_id supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       SUM(prrqs.qty_sign *
                           pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                prrqs.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                prrqs.qty)) total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       prrqs.qty_type qty_type
                FROM   prrqs_prr_qty_status       prrqs,
                       axs_action_summary         axs,
                       aml_attribute_master_list  aml,
                       pdm_productmaster          pdm,
                       cpm_corporateproductmaster cpm
                WHERE  prrqs.internal_action_ref_no = axs.internal_action_ref_no
                AND    prrqs.smelter_cp_id IS NULL
                AND    prrqs.is_active = 'Y'
                AND    prrqs.qty_type = 'Returnable'
                AND    aml.attribute_id(+) = prrqs.element_id
                AND    pdm.product_id = prrqs.product_id
                AND    cpm.is_active = 'Y'
                AND    cpm.is_deleted = 'N'
                AND    cpm.product_id = pdm.product_id
                AND    cpm.corporate_id = axs.corporate_id
                GROUP  BY axs.corporate_id,
                          prrqs.supplier_cp_id,
                          prrqs.product_id,
                          pdm.product_desc,
                          cpm.inventory_qty_unit,
                          prrqs.qty_type
                UNION
                SELECT axs.corporate_id,
                       spq.supplier_id,
                       product_temp.underlying_product_id product_id,
                       product_temp.product_desc product_name,
                       SUM(pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                spq.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                spq.payable_qty)) total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       spq.qty_type qty_type
                FROM   spq_stock_payable_qty spq,
                       axs_action_summary axs,
                       (SELECT aml.attribute_id,
                               aml.attribute_name,
                               qav.quality_id quality_id,
                               qat.long_desc,
                               qav.comp_quality_id comp_quality_id,
                               aml.underlying_product_id underlying_product_id,
                               pdm.product_desc,
                               ppm.product_id
                        FROM   aml_attribute_master_list      aml,
                               ppm_product_properties_mapping ppm,
                               qav_quality_attribute_values   qav,
                               qat_quality_attributes         qat,
                               pdm_productmaster              pdm
                        WHERE  aml.attribute_id = ppm.attribute_id
                        AND    aml.is_active = 'Y'
                        AND    aml.is_deleted = 'N'
                        AND    ppm.is_active = 'Y'
                        AND    ppm.is_deleted = 'N'
                        AND    qav.attribute_id = ppm.property_id
                        AND    qav.is_deleted = 'N'
                        AND    qat.quality_id = qav.quality_id
                        AND    qat.product_id = ppm.product_id
                        AND    qat.is_active = 'Y'
                        AND    qat.is_deleted = 'N'
                        AND    aml.underlying_product_id IS NOT NULL
                        AND    qav.comp_quality_id IS NOT NULL
                        AND    pdm.product_id = aml.underlying_product_id) product_temp,
                       cpm_corporateproductmaster cpm,
                       grd_goods_record_detail grd
                WHERE  spq.internal_action_ref_no = axs.internal_action_ref_no
                AND    spq.smelter_id IS NULL
                AND    spq.is_active = 'Y'
                AND    spq.is_stock_split = 'N'
                AND    spq.qty_type = 'Returnable'
                AND    grd.internal_grd_ref_no = spq.internal_grd_ref_no
                AND    product_temp.attribute_id = spq.element_id
                AND    product_temp.product_id = grd.product_id
                AND    cpm.is_active = 'Y'
                AND    cpm.is_deleted = 'N'
                AND    cpm.product_id = product_temp.underlying_product_id
                AND    cpm.corporate_id = axs.corporate_id
                GROUP  BY axs.corporate_id,
                          spq.supplier_id,
                          product_temp.underlying_product_id,
                          product_temp.product_desc,
                          cpm.inventory_qty_unit,
                          spq.qty_type) returnable_temp
        GROUP  BY returnable_temp.corporate_id,
                  returnable_temp.supplier_id,
                  returnable_temp.product_id,
                  returnable_temp.product_name,
                  returnable_temp.qty_unit_id,
                  returnable_temp.qty_type
        UNION
        SELECT axs.corporate_id,
               prrqs.supplier_cp_id supplier_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               SUM(prrqs.qty_sign *
                   pkg_general.f_get_converted_quantity(cpm.product_id,
                                                        prrqs.qty_unit_id,
                                                        cpm.inventory_qty_unit,
                                                        prrqs.qty)) total_qty,
               cpm.inventory_qty_unit qty_unit_id,
               prrqs.qty_type qty_type
        FROM   prrqs_prr_qty_status       prrqs,
               axs_action_summary         axs,
               aml_attribute_master_list  aml,
               pdm_productmaster          pdm,
               cpm_corporateproductmaster cpm
        WHERE  prrqs.internal_action_ref_no = axs.internal_action_ref_no
        AND    prrqs.smelter_cp_id IS NULL
        AND    prrqs.is_active = 'Y'
        AND    prrqs.qty_type = 'Returned'
        AND    aml.attribute_id(+) = prrqs.element_id
        AND    pdm.product_id = prrqs.product_id
        AND    cpm.is_active = 'Y'
        AND    cpm.is_deleted = 'N'
        AND    cpm.product_id = pdm.product_id
        AND    cpm.corporate_id = axs.corporate_id
        GROUP  BY axs.corporate_id,
                  prrqs.supplier_cp_id,
                  prrqs.product_id,
                  pdm.product_desc,
                  cpm.inventory_qty_unit,
                  prrqs.qty_type) debt_temp,
       phd_profileheaderdetails phd,
       qum_quantity_unit_master qum
WHERE  debt_temp.supplier_id = phd.profileid
AND    debt_temp.qty_unit_id = qum.qty_unit_id
GROUP  BY debt_temp.corporate_id,
          debt_temp.supplier_id,
          phd.companyname,
          debt_temp.product_id,
          debt_temp.product_name,
          debt_temp.qty_unit_id,
          qum.qty_unit;
