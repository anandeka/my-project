CREATE OR REPLACE VIEW V_METAL_ACCOUNTS_TRANSACTIONS
AS 
SELECT mat_temp.unique_id,
       mat_temp.corporate_id,
       mat_temp.internal_contract_ref_no,
       mat_temp.contract_ref_no,
       mat_temp.internal_contract_item_ref_no,
       mat_temp.contract_item_ref_no,
       mat_temp.pcdi_id,
       mat_temp.delivery_item_ref_no,
       mat_temp.stock_id,
       mat_temp.stock_ref_no,
       mat_temp.internal_gmr_ref_no,
       mat_temp.gmr_ref_no,
       mat_temp.activity_action_id,
       axm.action_name activity_action_name,
       mat_temp.supplier_id,
       phd.companyname supplier_name,
       mat_temp.debt_supplier_id,
       phd_debt.companyname debt_supplier_name,
       mat_temp.product_id,
       mat_temp.product_name,
       mat_temp.debt_qty,
       mat_temp.debt_qty_unit_id,
       qum.qty_unit debt_qty_unit,
       mat_temp.internal_action_ref_no,
       to_char(mat_temp.activity_date,
               'dd-Mon-yyyy') activity_date,
       (CASE
           WHEN ash_pa_fa.assay_type IS NOT NULL THEN
            ash_pa_fa.assay_type
           ELSE
            'Contractual Assay'
       END) assay_type
FROM   (SELECT retn_temp.unique_id,
               retn_temp.corporate_id,
               retn_temp.internal_contract_ref_no,
               retn_temp.contract_ref_no,
               retn_temp.internal_contract_item_ref_no,
               retn_temp.contract_item_ref_no,
               retn_temp.pcdi_id,
               retn_temp.delivery_item_ref_no,
               retn_temp.stock_id,
               retn_temp.stock_ref_no,
               retn_temp.internal_gmr_ref_no,
               retn_temp.gmr_ref_no,
               retn_temp.activity_action_id,
               retn_temp.supplier_id,
               retn_temp.to_supplier_id debt_supplier_id,
               retn_temp.product_id,
               retn_temp.product_name,
               (-1 * retn_temp.qty) debt_qty,
               retn_temp.qty_unit_id debt_qty_unit_id,
               retn_temp.internal_action_ref_no,
               retn_temp.activity_date
        FROM   (SELECT spq.spq_id unique_id,
                       axs.corporate_id,
                       pci.internal_contract_ref_no,
                       pci.contract_ref_no,
                       pci.internal_contract_item_ref_no,
                       pci.contract_item_ref_no,
                       pci.pcdi_id,
                       pci.delivery_item_ref_no,
                       spq.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       spq.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       spq.activity_action_id,
                       spq.supplier_id,
                       '' to_supplier_id,
                       product_temp.underlying_product_id product_id,
                       product_temp.product_desc product_name,
                       spq.payable_qty qty,
                       spq.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date
                FROM   spq_stock_payable_qty spq,
                       grd_goods_record_detail grd,
                       v_pci pci,
                       gmr_goods_movement_record gmr,
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
                        AND    pdm.product_id = aml.underlying_product_id) product_temp
                WHERE  spq.internal_action_ref_no = axs.internal_action_ref_no
                AND    spq.smelter_id IS NULL
                AND    spq.is_active = 'Y'
                AND    spq.is_stock_split = 'N'
                AND    spq.qty_type = 'Returnable'
                AND    product_temp.attribute_id = spq.element_id
                AND    product_temp.product_id = grd.product_id
                AND    grd.internal_grd_ref_no = spq.internal_grd_ref_no
                AND    gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
                AND    pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                UNION
                SELECT prrqs.prrqs_id unique_id,
                       axs.corporate_id,
                       '' internal_contract_ref_no,
                       '' contract_ref_no,
                       '' internal_contract_item_ref_no,
                       '' contract_item_ref_no,
                       '' pcdi_id,
                       '' delivery_item_ref_no,
                       '' stock_id,
                       '' stock_ref_no,
                       '' internal_gmr_ref_no,
                       '' gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.supplier_cp_id supplier_id,
                       prrqs.to_supplier_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date
                FROM   prrqs_prr_qty_status prrqs,
                       axs_action_summary   axs,
                       pdm_productmaster    pdm
                WHERE  prrqs.internal_action_ref_no = axs.internal_action_ref_no
                AND    prrqs.smelter_cp_id IS NULL
                AND    prrqs.is_active = 'Y'
                AND    prrqs.qty_type = 'Returnable'
                AND    pdm.product_id = prrqs.product_id) retn_temp
        UNION
        SELECT prrqs.prrqs_id unique_id,
               axs.corporate_id,
               '' internal_contract_ref_no,
               '' contract_ref_no,
               '' internal_contract_item_ref_no,
               '' contract_item_ref_no,
               '' pcdi_id,
               '' delivery_item_ref_no,
               dgrd.internal_dgrd_ref_no stock_id,
               dgrd.internal_stock_ref_no stock_ref_no,
               prrqs.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               prrqs.activity_action_id,
               prrqs.supplier_cp_id supplier_id,
               prrqs.to_supplier_cp_id debt_supplier_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               (prrqs.qty_sign * prrqs.qty) debt_qty,
               prrqs.qty_unit_id debt_qty_unit_id,
               axs.internal_action_ref_no,
               axs.eff_date activity_date
        FROM   prrqs_prr_qty_status      prrqs,
               axs_action_summary        axs,
               pdm_productmaster         pdm,
               dgrd_delivered_grd        dgrd,
               gmr_goods_movement_record gmr
        WHERE  prrqs.internal_action_ref_no = axs.internal_action_ref_no
        AND    prrqs.smelter_cp_id IS NULL
        AND    prrqs.is_active = 'Y'
        AND    prrqs.qty_type = 'Returned'
        AND    pdm.product_id = prrqs.product_id
        AND    dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
        AND    gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no) mat_temp,
       axm_action_master axm,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_debt,
       qum_quantity_unit_master qum,
       (SELECT ash.ash_id,
               ash.assay_type,
               sam.internal_grd_ref_no
        FROM   sam_stock_assay_mapping sam,
               ash_assay_header        ash
        WHERE  ash.pricing_assay_ash_id = sam.ash_id
        AND    sam.is_latest_pricing_assay = 'Y'
        AND    ash.assay_type in ('Weighing and Sampling Assay','Provisional Assay')
        AND    sam.is_active = 'Y') ash_pa_fa
WHERE  axm.action_id = mat_temp.activity_action_id
AND    phd.profileid = mat_temp.supplier_id
AND    phd_debt.profileid(+) = mat_temp.debt_supplier_id
AND    qum.qty_unit_id = mat_temp.debt_qty_unit_id
AND    ash_pa_fa.internal_grd_ref_no(+) = mat_temp.stock_id
ORDER  BY mat_temp.activity_date DESC;
