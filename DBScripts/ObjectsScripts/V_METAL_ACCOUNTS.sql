create or replace view v_metal_accounts as
select debt_temp.corporate_id,
       debt_temp.supplier_id supplier_id,
       phd.companyname supplier_name,
       debt_temp.product_id product_id,
       debt_temp.product_name product_name,
       sum(debt_temp.total_qty) total_qty,
       sum(nvl(debt_temp.ext_total_qty, 0)) ext_total_qty,
       debt_temp.qty_unit_id qty_unit_id,
       qum.qty_unit qty_unit
  from (select returnable_temp.corporate_id,
               returnable_temp.supplier_id supplier_id,
               returnable_temp.product_id,
               returnable_temp.product_name,
               -1 * sum(returnable_temp.total_qty) total_qty,
               -1 * sum(returnable_temp.ext_total_qty) ext_total_qty,
               returnable_temp.qty_unit_id,
               returnable_temp.qty_type
          from (select prrqs.corporate_id,
                       prrqs.cp_id supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       sum(prrqs.qty_sign *
                           pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                prrqs.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                prrqs.qty)) total_qty,
                       sum(prrqs.qty_sign *
                           pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                prrqs.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                prrqs.ext_qty)) ext_total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       prrqs.qty_type qty_type
                  from prrqs_prr_qty_status       prrqs,
                       pdm_productmaster          pdm,
                       cpm_corporateproductmaster cpm
                 where prrqs.cp_type = 'Supplier'
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
                       spq.supplier_id,
                       bvc_product.base_product_id product_id,
                       bvc_product.base_product_name product_name,
                       sum(pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                spq.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                spq.payable_qty)) total_qty,
                       sum(pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                spq.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                spq.ext_payable_qty)) ext_total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       spq.qty_type qty_type
                  from spq_stock_payable_qty       spq,
                       v_list_base_vs_conc_product bvc_product,
                       cpm_corporateproductmaster  cpm,
                       grd_goods_record_detail     grd
                 where spq.smelter_id is null
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
                          spq.supplier_id,
                          bvc_product.base_product_id,
                          bvc_product.base_product_name,
                          cpm.inventory_qty_unit,
                          spq.qty_type) returnable_temp
         group by returnable_temp.corporate_id,
                  returnable_temp.supplier_id,
                  returnable_temp.product_id,
                  returnable_temp.product_name,
                  returnable_temp.qty_unit_id,
                  returnable_temp.qty_type
        union
        select prrqs.corporate_id,
               prrqs.cp_id supplier_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               sum(prrqs.qty_sign *
                   pkg_general.f_get_converted_quantity(cpm.product_id,
                                                        prrqs.qty_unit_id,
                                                        cpm.inventory_qty_unit,
                                                        prrqs.qty)) total_qty,
               sum(prrqs.qty_sign *
                   pkg_general.f_get_converted_quantity(cpm.product_id,
                                                        prrqs.qty_unit_id,
                                                        cpm.inventory_qty_unit,
                                                        prrqs.ext_qty)) ext_total_qty,
               cpm.inventory_qty_unit qty_unit_id,
               prrqs.qty_type qty_type
          from prrqs_prr_qty_status       prrqs,
               pdm_productmaster          pdm,
               cpm_corporateproductmaster cpm
         where prrqs.cp_type = 'Supplier'
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
 where debt_temp.supplier_id = phd.profileid
   and debt_temp.qty_unit_id = qum.qty_unit_id
 group by debt_temp.corporate_id,
          debt_temp.supplier_id,
          phd.companyname,
          debt_temp.product_id,
          debt_temp.product_name,
          debt_temp.qty_unit_id,
          qum.qty_unit
