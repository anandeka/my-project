CREATE OR REPLACE VIEW V_METAL_ACCOUNTS_TRANSACTIONS AS
select mat_temp.unique_id,
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
       to_char(mat_temp.activity_date, 'dd-Mon-yyyy') activity_date,
       nvl(ash_temp.is_final_assay_fully_finalized, 'N') assay_finalized
  from (select retn_temp.unique_id,
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
          from (select spq.spq_id unique_id,
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
                  from spq_stock_payable_qty spq,
                       grd_goods_record_detail grd,
                       v_pci pci,
                       gmr_goods_movement_record gmr,
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
                           and pdm.product_id = aml.underlying_product_id) product_temp
                 where spq.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and spq.smelter_id is null
                   and spq.is_active = 'Y'
                   and spq.is_stock_split = 'N'
                   and spq.qty_type = 'Returnable'
                   and product_temp.attribute_id = spq.element_id
                   and product_temp.product_id = grd.product_id
                   and product_temp.quality_id = grd.quality_id
                   and grd.internal_grd_ref_no = spq.internal_grd_ref_no
                   and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                union
                select prrqs.prrqs_id unique_id,
                       axs.corporate_id,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       grd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date
                  from prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       grd_goods_record_detail   grd,
                       gmr_goods_movement_record gmr,
                       v_pci                     pci
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = prrqs.internal_grd_ref_no
                   and grd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id in
                       ('pledgeTransfer', 'financialSettlement')
                union
                select prrqs.prrqs_id unique_id,
                       axs.corporate_id,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       dgrd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       dgrd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date
                  from prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       dgrd_delivered_grd        dgrd,
                       gmr_goods_movement_record gmr,
                       v_pci                     pci
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and dgrd.internal_dgrd_ref_no = prrqs.internal_grd_ref_no
                   and dgrd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       dgrd.internal_contract_item_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'financialSettlement'
                
                union
                select prrqs.prrqs_id unique_id,
                       axs.corporate_id,
                       '' internal_contract_ref_no,
                       '' contract_ref_no,
                       '' internal_contract_item_ref_no,
                       '' contract_item_ref_no,
                       '' pcdi_id,
                       '' delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       '' stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       '' gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date
                  from prrqs_prr_qty_status prrqs,
                       axs_action_summary   axs,
                       pdm_productmaster    pdm
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'metalBalanceTransfer') retn_temp
        union
        select prrqs.prrqs_id unique_id,
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
               prrqs.cp_id supplier_id,
               prrqs.to_cp_id debt_supplier_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               (prrqs.qty_sign * prrqs.qty) debt_qty,
               prrqs.qty_unit_id debt_qty_unit_id,
               axs.internal_action_ref_no,
               axs.eff_date activity_date
          from prrqs_prr_qty_status      prrqs,
               axs_action_summary        axs,
               pdm_productmaster         pdm,
               dgrd_delivered_grd        dgrd,
               gmr_goods_movement_record gmr
         where prrqs.internal_action_ref_no = axs.internal_action_ref_no
           and prrqs.cp_type = 'Supplier'
           and prrqs.is_active = 'Y'
           and prrqs.qty_type = 'Returned'
           and pdm.product_id = prrqs.product_id
           and dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
           and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no) mat_temp,
       axm_action_master axm,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_debt,
       qum_quantity_unit_master qum,
       (select ash.is_final_assay_fully_finalized,
               ash.internal_grd_ref_no
          from ash_assay_header ash
         where ash.assay_type = 'Final Assay'
           and ash.is_active = 'Y') ash_temp
 where axm.action_id = mat_temp.activity_action_id
   and phd.profileid = mat_temp.supplier_id
   and phd_debt.profileid(+) = mat_temp.debt_supplier_id
   and qum.qty_unit_id = mat_temp.debt_qty_unit_id
   and ash_temp.internal_grd_ref_no(+) = mat_temp.stock_id
 order by mat_temp.activity_date desc;
