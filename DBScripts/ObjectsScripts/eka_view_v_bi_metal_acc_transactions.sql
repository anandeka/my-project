CREATE OR REPLACE VIEW V_BI_METAL_ACC_TRANSACTIONS AS
select mat_temp.ACTION_REF_NO unique_id,
       mat_temp.unique_id unique_id_internal,
       mat_temp.corporate,
       mat_temp.internal_contract_ref_no,
       mat_temp.contract_ref_no,
       mat_temp.internal_contract_item_ref_no,
       mat_temp.contract_item_ref_no,
       mat_temp.pcdi_id,
       mat_temp.delivery_item_ref_no,
       mat_temp.profit_center,
       mat_temp.stock_id,
       mat_temp.stock_ref_no,
       mat_temp.internal_gmr_ref_no,
       mat_temp.gmr_ref_no,
       mat_temp.activity_action_id,
       axm.action_name activity_action_name,
       mat_temp.supplier_id cp_id,
       phd.companyname cp_name,
       mat_temp.debt_supplier_id,
       phd_debt.companyname debt_supplier_name,
       mat_temp.product_id,
       mat_temp.product_name,
       mat_temp.product_name attribute_name,
       mat_temp.debt_qty,
       qum.qty_unit debt_qty_unit,
       --Bug Fix start
       --mat_temp.debt_qty_unit_id debt_qty_unit_id,
       qum.qty_unit debt_qty_unit_id, -- this is done due to the BI Manager schema refered ID as UOM, now we can't change this in jasper.
       --Bug Fix end
       mat_temp.internal_action_ref_no,
       mat_temp.ACTION_REF_NO,
       to_char(mat_temp.activity_date, 'dd-Mon-yyyy') activity_date,
       'NA' assay_type,
       decode(nvl(mat_temp.is_final_assay, 'N'), 'N', 'No', 'Yes') IS_FINAL_ASSAY
  FROM (SELECT retn_temp.unique_id,
               retn_temp.corporate_id corporate,
               retn_temp.internal_contract_ref_no,
               retn_temp.contract_ref_no,
               retn_temp.internal_contract_item_ref_no,
               retn_temp.contract_item_ref_no,
               retn_temp.pcdi_id,
               retn_temp.delivery_item_ref_no,
               retn_temp.profit_center,
               retn_temp.stock_id,
               retn_temp.stock_ref_no,
               retn_temp.internal_gmr_ref_no,
               retn_temp.gmr_ref_no,
               retn_temp.activity_action_id,
               retn_temp.supplier_id,
               retn_temp.to_supplier_id debt_supplier_id,
               retn_temp.product_id,
               retn_temp.product_name,
               retn_temp.element_name,
               (-1 * retn_temp.qty) debt_qty,
               retn_temp.qty_unit_id debt_qty_unit_id,
               retn_temp.internal_action_ref_no,
               retn_temp.activity_date,
               retn_temp.ACTION_REF_NO,
               retn_temp. is_final_assay
          FROM (SELECT spq.spq_id unique_id,
                       axs.corporate_id,
                       pci.internal_contract_ref_no,
                       pci.contract_ref_no,
                       pci.internal_contract_item_ref_no,
                       pci.contract_item_ref_no,
                       pci.pcdi_id,
                       pci.delivery_item_ref_no,
                       pci.profit_center_name profit_center,
                       spq.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       spq.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       spq.activity_action_id,
                       spq.supplier_id,
                       '' to_supplier_id,
                       bvc_product.base_product_id product_id,
                       bvc_product.base_product_name product_name,
                       bvc_product.element_name,
                       spq.payable_qty qty,
                       spq.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       axs.ACTION_REF_NO,
                       spq.is_final_assay
                  FROM spq_stock_payable_qty       spq,
                       grd_goods_record_detail     grd,
                       v_pci                       pci,
                       gmr_goods_movement_record   gmr,
                       axs_action_summary          axs,
                       v_list_base_vs_conc_product bvc_product
                 WHERE spq.internal_action_ref_no =
                       axs.internal_action_ref_no
                   AND spq.smelter_id IS NULL
                   AND spq.is_active = 'Y'
                   AND spq.is_stock_split = 'N'
                   AND spq.qty_type = 'Returnable'
                   AND bvc_product.element_id = spq.element_id
                   AND bvc_product.product_id = grd.product_id
                   AND bvc_product.quality_id = grd.quality_id
                   AND grd.internal_grd_ref_no = spq.internal_grd_ref_no
                   AND gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
                      --and gmr.inventory_status = 'In'
                   AND pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                   and grd.is_deleted = 'N'
                UNION
                SELECT prrqs.prrqs_id unique_id,
                       axs.corporate_id,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       grd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       pci.profit_center_name profit_center,
                       prrqs.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       aml.attribute_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       axs.action_ref_no,
                       null is_final_assay
                  FROM prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       grd_goods_record_detail   grd,
                       gmr_goods_movement_record gmr,
                       aml_attribute_master_list aml,
                       v_pci                     pci
                 WHERE prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   AND gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and aml.attribute_id = grd.element_id
                   AND grd.internal_grd_ref_no = prrqs.internal_grd_ref_no
                   AND grd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   AND pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                   AND prrqs.cp_type = 'Supplier'
                   AND prrqs.is_active = 'Y'
                   AND prrqs.qty_type = 'Returnable'
                   AND pdm.product_id = prrqs.product_id
                   AND prrqs.activity_action_id in
                       ('pledgeTransfer', 'financialSettlement')
                UNION
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       dgrd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       pci.profit_center_name profit_center,
                       prrqs.internal_grd_ref_no stock_id,
                       dgrd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       null element_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       axs.action_ref_no,
                       null is_final_assay
                  from prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       dgrd_delivered_grd        dgrd,
                       gmr_goods_movement_record gmr,
                       v_pci                     pci
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
                   and dgrd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       dgrd.internal_contract_item_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'financialSettlement'
                union all
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       '' internal_contract_ref_no,
                       '' contract_ref_no,
                       '' internal_contract_item_ref_no,
                       '' contract_item_ref_no,
                       '' pcdi_id,
                       '' delivery_item_ref_no,
                       '' profit_center,
                       prrqs.internal_grd_ref_no stock_id,
                       '' stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       '' gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       null element_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       axs.action_ref_no,
                       null is_final_assay
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
        union all
        SELECT prrqs.prrqs_id unique_id,
               axs.corporate_id corporate,
               '' internal_contract_ref_no,
               '' contract_ref_no,
               '' internal_contract_item_ref_no,
               '' contract_item_ref_no,
               '' pcdi_id,
               '' delivery_item_ref_no,
               '' profit_center,
               dgrd.internal_dgrd_ref_no stock_id,
               dgrd.internal_stock_ref_no stock_ref_no,
               prrqs.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               prrqs.activity_action_id,
               prrqs.cp_id supplier_id,
               prrqs.to_cp_id debt_supplier_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               null element,
               (prrqs.qty_sign * prrqs.qty) debt_qty,
               prrqs.qty_unit_id debt_qty_unit_id,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               null is_final_assay
          FROM prrqs_prr_qty_status      prrqs,
               axs_action_summary        axs,
               pdm_productmaster         pdm,
               dgrd_delivered_grd        dgrd,
               gmr_goods_movement_record gmr
         WHERE prrqs.internal_action_ref_no = axs.internal_action_ref_no
           AND prrqs.cp_type = 'Supplier'
           AND prrqs.is_active = 'Y'
           AND prrqs.qty_type = 'Returned'
           AND pdm.product_id = prrqs.product_id
           AND dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
           AND gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no) mat_temp,
       axm_action_master axm,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_debt,
       qum_quantity_unit_master qum /*,
       (SELECT ash.is_final_assay_fully_finalized,
       ash.assay_type,
       ash.internal_grd_ref_no
            FROM ash_assay_header ash
           WHERE ash.assay_type = 'Final Assay' AND ash.is_active = 'Y') ash_temp*/
 WHERE axm.action_id = mat_temp.activity_action_id
   AND mat_temp.supplier_id = phd.profileid
   AND mat_temp.debt_supplier_id = phd_debt.profileid(+)   
/* AND mat_temp.stock_id = ash_temp.internal_grd_ref_no(+)*/
   AND mat_temp.debt_qty_unit_id = qum.qty_unit_id;
