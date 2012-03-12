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
          from (select prrqs.corporate_id,
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
                       pdm_productmaster          pdm,
                       cpm_corporateproductmaster cpm
                 where prrqs.cp_type = 'Smelter'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and cpm.is_active = 'Y'
                   and cpm.is_deleted = 'N'
                   and cpm.product_id = pdm.product_id
                   and cpm.corporate_id = prrqs.corporate_id
                 group by prrqs.corporate_id,
                          prrqs.cp_id,
                          prrqs.product_id,
                          pdm.product_desc,
                          cpm.inventory_qty_unit,
                          prrqs.qty_type
                union
                select spq.corporate_id,
                       spq.smelter_id,
                       bvc_product.base_product_id product_id,
                       bvc_product.base_product_name product_name,
                       sum(pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                spq.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                spq.payable_qty)) total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       spq.qty_type qty_type
                  from spq_stock_payable_qty       spq,
                       v_list_base_vs_conc_product bvc_product,
                       cpm_corporateproductmaster  cpm,
                       grd_goods_record_detail     grd
                 where spq.supplier_id is null
                   and spq.is_active = 'Y'
                   and spq.is_stock_split = 'N'
                   and spq.qty_type = 'Returnable'
                   and grd.internal_grd_ref_no = spq.internal_grd_ref_no
                   and bvc_product.element_id = spq.element_id
                   and bvc_product.product_id = grd.product_id
                   and bvc_product.quality_id = grd.quality_id
                   and cpm.is_active = 'Y'
                   and cpm.is_deleted = 'N'
                   and cpm.product_id = bvc_product.base_product_id
                   and cpm.corporate_id = spq.corporate_id
                 group by spq.corporate_id,
                          spq.smelter_id,
                          bvc_product.base_product_id,
                          bvc_product.base_product_name,
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
        select prrqs.corporate_id,
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
               pdm_productmaster          pdm,
               cpm_corporateproductmaster cpm
         where prrqs.cp_type = 'Smelter'
           and prrqs.is_active = 'Y'
           and prrqs.qty_type = 'Returned'
           and pdm.product_id = prrqs.product_id
           and cpm.is_active = 'Y'
           and cpm.is_deleted = 'N'
           and cpm.product_id = pdm.product_id
           and cpm.corporate_id = prrqs.corporate_id
         group by prrqs.corporate_id,
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
