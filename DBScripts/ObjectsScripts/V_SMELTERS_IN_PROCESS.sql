CREATE OR REPLACE VIEW V_SMELTERS_IN_PROCESS AS
select debt_temp.corporate_id,
       debt_temp.smelter_id smelter_id,
       phd.companyname smelter_name,
       debt_temp.product_id product_id,
       debt_temp.product_name product_name,
       sum(debt_temp.total_qty) total_qty,
       debt_temp.qty_unit_id qty_unit_id,
       qum.qty_unit qty_unit
  from (select returnable_temp.corporate_id,
               returnable_temp.smelter_id smelter_id,
               returnable_temp.product_id,
               returnable_temp.product_name,
               -1 * sum(returnable_temp.total_qty) total_qty,
               returnable_temp.qty_unit_id,
               returnable_temp.qty_type
          from (select axs.corporate_id,
                       prrqs.cp_id smelter_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       sum(prrqs.qty_sign *
                           pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                prrqs.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                prrqs.qty)) total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       prrqs.qty_type qty_type
                  from prrqs_prr_qty_status       prrqs,
                       axs_action_summary         axs,
                       aml_attribute_master_list  aml,
                       pdm_productmaster          pdm,
                       cpm_corporateproductmaster cpm
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and prrqs.cp_type = 'Smelter'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and aml.attribute_id(+) = prrqs.element_id
                   and pdm.product_id = prrqs.product_id
                   and cpm.is_active = 'Y'
                   and cpm.is_deleted = 'N'
                   and cpm.product_id = pdm.product_id
                   and cpm.corporate_id = axs.corporate_id
                 group by axs.corporate_id,
                          prrqs.cp_id,
                          prrqs.product_id,
                          pdm.product_desc,
                          cpm.inventory_qty_unit,
                          prrqs.qty_type
                union
                select axs.corporate_id,
                       spq.smelter_id,
                       product_temp.underlying_product_id product_id,
                       product_temp.product_desc product_name,
                       sum(pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                spq.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                spq.payable_qty)) total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       spq.qty_type qty_type
                  from spq_stock_payable_qty spq,
                       axs_action_summary axs,
                       (select aml.attribute_id,
                               aml.attribute_name,
                               qav.quality_id quality_id,
                               qat.long_desc,
                               qav.comp_quality_id comp_quality_id,
                               aml.underlying_product_id underlying_product_id,
                               pdm.product_desc,
                               ppm.product_id
                          from aml_attribute_master_list      aml,
                               ppm_product_properties_mapping ppm,
                               qav_quality_attribute_values   qav,
                               qat_quality_attributes         qat,
                               pdm_productmaster              pdm
                         where aml.attribute_id = ppm.attribute_id
                           and aml.is_active = 'Y'
                           and aml.is_deleted = 'N'
                           and ppm.is_active = 'Y'
                           and ppm.is_deleted = 'N'
                           and qav.attribute_id = ppm.property_id
                           and qav.is_deleted = 'N'
                           and qat.quality_id = qav.quality_id
                           and qat.product_id = ppm.product_id
                           and qat.is_active = 'Y'
                           and qat.is_deleted = 'N'
                           and aml.underlying_product_id is not null
                           and qav.comp_quality_id is not null
                           and pdm.product_id = aml.underlying_product_id) product_temp,
                       cpm_corporateproductmaster cpm,
                       grd_goods_record_detail grd
                 where spq.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and spq.supplier_id is null
                   and spq.is_active = 'Y'
                   and spq.is_stock_split = 'N'
                   and spq.qty_type = 'Returnable'
                   and grd.internal_grd_ref_no = spq.internal_grd_ref_no
                   and product_temp.attribute_id = spq.element_id
                   and product_temp.product_id = grd.product_id
                   and product_temp.quality_id = grd.quality_id
                   and cpm.is_active = 'Y'
                   and cpm.is_deleted = 'N'
                   and cpm.product_id = product_temp.underlying_product_id
                   and cpm.corporate_id = axs.corporate_id
                 group by axs.corporate_id,
                          spq.smelter_id,
                          product_temp.underlying_product_id,
                          product_temp.product_desc,
                          cpm.inventory_qty_unit,
                          spq.qty_type
                /* UNION
                                --Smelter Base Stock as Returnable(Debt)
                                SELECT sbs.corporate_id,
                                       sbs.smelter_cp_id smelter_id,
                                       sbs.product_id product_id,
                                       pdm.product_desc product_name,
                                       SUM(pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                                sbs.qty_unit_id,
                                                                                cpm.inventory_qty_unit,
                                                                                sbs.qty)) total_qty,
                                       cpm.inventory_qty_unit qty_unit_id,
                                       'Returnable' qty_type
                                FROM   sbs_smelter_base_stock     sbs,
                                       pdm_productmaster          pdm,
                                       cpm_corporateproductmaster cpm
                                WHERE  pdm.product_id = sbs.product_id
                                AND    sbs.is_active = 'Y'
                                AND    cpm.corporate_id = sbs.corporate_id
                                AND    cpm.product_id = pdm.product_id
                                AND    cpm.is_active = 'Y'
                                AND    cpm.is_deleted = 'N'
                                GROUP  BY sbs.corporate_id,
                                          sbs.smelter_cp_id,
                                          sbs.product_id,
                                          pdm.product_desc,
                                          cpm.inventory_qty_unit*/
                ) returnable_temp
         group by returnable_temp.corporate_id,
                  returnable_temp.smelter_id,
                  returnable_temp.product_id,
                  returnable_temp.product_name,
                  returnable_temp.qty_unit_id,
                  returnable_temp.qty_type
        union
        select axs.corporate_id,
               prrqs.cp_id smelter_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               sum(prrqs.qty_sign *
                   pkg_general.f_get_converted_quantity(cpm.product_id,
                                                        prrqs.qty_unit_id,
                                                        cpm.inventory_qty_unit,
                                                        prrqs.qty)) total_qty,
               cpm.inventory_qty_unit qty_unit_id,
               prrqs.qty_type qty_type
          from prrqs_prr_qty_status       prrqs,
               axs_action_summary         axs,
               aml_attribute_master_list  aml,
               pdm_productmaster          pdm,
               cpm_corporateproductmaster cpm
         where prrqs.internal_action_ref_no = axs.internal_action_ref_no
           and prrqs.cp_type = 'Smelter'
           and prrqs.is_active = 'Y'
           and prrqs.qty_type = 'Returned'
           and aml.attribute_id(+) = prrqs.element_id
           and pdm.product_id = prrqs.product_id
           and cpm.is_active = 'Y'
           and cpm.is_deleted = 'N'
           and cpm.product_id = pdm.product_id
           and cpm.corporate_id = axs.corporate_id
         group by axs.corporate_id,
                  prrqs.cp_id,
                  prrqs.product_id,
                  pdm.product_desc,
                  cpm.inventory_qty_unit,
                  prrqs.qty_type) debt_temp,
       phd_profileheaderdetails phd,
       qum_quantity_unit_master qum
 where debt_temp.smelter_id = phd.profileid
   and debt_temp.qty_unit_id = qum.qty_unit_id
 group by debt_temp.corporate_id,
          debt_temp.smelter_id,
          phd.companyname,
          debt_temp.product_id,
          debt_temp.product_name,
          debt_temp.qty_unit_id,
          qum.qty_unit
