CREATE OR REPLACE FORCE VIEW v_metal_accounts_transactions
AS
   SELECT   mat_temp.unique_id, mat_temp.corporate_id, mat_temp.contract_type,
            mat_temp.internal_contract_ref_no, mat_temp.contract_ref_no,
            mat_temp.contract_middle_no,
            mat_temp.internal_contract_item_ref_no,
            mat_temp.contract_item_ref_no, mat_temp.pcdi_id,
            mat_temp.delivery_item_no, mat_temp.del_distribution_item_no,
            mat_temp.delivery_item_ref_no, mat_temp.stock_id,
            mat_temp.stock_ref_no, mat_temp.internal_gmr_ref_no,
            mat_temp.gmr_ref_no, mat_temp.activity_action_id,
            axm.action_name activity_action_name, mat_temp.supplier_id,
            phd.companyname supplier_name, mat_temp.debt_supplier_id,
            phd_debt.companyname debt_supplier_name, mat_temp.product_id,
            mat_temp.product_name, mat_temp.debt_qty,
            NVL (mat_temp.ext_debt_qty, 0) ext_debt_qty,
            mat_temp.debt_qty_unit_id, qum.qty_unit debt_qty_unit,
            mat_temp.internal_action_ref_no,
            TO_CHAR (mat_temp.activity_date, 'dd-Mon-yyyy') activity_date,
            mat_temp.assay_content,
            NVL (mat_temp.ext_assay_content, 0) ext_assay_content,
            NVL (mat_temp.assay_finalized, 'N') assay_finalized,
            mat_temp.due_date, mat_temp.invoice_ref_no,
            mat_temp.invoice_issue_date, mat_temp.landing_date,
            mat_temp.is_warrant
       FROM (SELECT retn_temp.unique_id, retn_temp.corporate_id,
                    retn_temp.contract_type,
                    retn_temp.internal_contract_ref_no,
                    retn_temp.contract_ref_no, retn_temp.contract_middle_no,
                    retn_temp.internal_contract_item_ref_no,
                    retn_temp.contract_item_ref_no, retn_temp.pcdi_id,
                    retn_temp.delivery_item_no,
                    retn_temp.del_distribution_item_no,
                    retn_temp.delivery_item_ref_no, retn_temp.stock_id,
                    retn_temp.stock_ref_no, retn_temp.internal_gmr_ref_no,
                    retn_temp.gmr_ref_no, retn_temp.activity_action_id,
                    retn_temp.supplier_id,
                    retn_temp.to_supplier_id debt_supplier_id,
                    retn_temp.product_id, retn_temp.product_name,
                    (-1 * retn_temp.qty) debt_qty,
                    (-1 * retn_temp.ext_qty) ext_debt_qty,
                    retn_temp.qty_unit_id debt_qty_unit_id,
                    retn_temp.internal_action_ref_no, retn_temp.activity_date,
                    (-1 * retn_temp.assay_content) assay_content,
                    (-1 * retn_temp.ext_assay_content) ext_assay_content,
                    retn_temp.assay_finalized, retn_temp.due_date,
                    retn_temp.invoice_ref_no, retn_temp.invoice_issue_date,
                    retn_temp.landing_date, retn_temp.is_warrant
               FROM (SELECT spq.spq_id unique_id, spq.corporate_id,
                            pci.contract_type, pci.internal_contract_ref_no,
                            pci.contract_ref_no,
                            pci.middle_no contract_middle_no,
                            pci.internal_contract_item_ref_no,
                            pci.contract_item_ref_no, pci.pcdi_id,
                            pci.delivery_item_no,
                            pci.del_distribution_item_no,
                            pci.delivery_item_ref_no,
                            spq.internal_grd_ref_no stock_id,
                            grd.internal_stock_ref_no stock_ref_no,
                            spq.internal_gmr_ref_no internal_gmr_ref_no,
                            gmr.gmr_ref_no gmr_ref_no, axs.action_id activity_action_id,
                            spq.supplier_id, '' to_supplier_id,
                            bvc_product.base_product_id product_id,
                            bvc_product.base_product_name product_name,
                            spq.payable_qty qty, spq.ext_payable_qty ext_qty,
                            spq.qty_unit_id qty_unit_id,
                            axs.internal_action_ref_no,
                            axs.eff_date activity_date, spq.assay_content,
                            spq.ext_assay_content ext_assay_content,
                            spq.is_final_assay assay_finalized, spq.due_date,
                            gmr.invoice_ref_no, gmr.invoice_issue_date,
                            gmr.landing_date,
                            (CASE
                                WHEN (grd.is_warrant = 'Y')
                                   THEN 'Yes'
                                ELSE 'No'
                             END
                            ) is_warrant
                       FROM spq_stock_payable_qty spq,
                            grd_goods_record_detail grd,
                            v_pci pci,
                            gmr_goods_movement_record gmr,
                            axs_action_summary axs,
                            v_list_base_vs_conc_product bvc_product
                      WHERE spq.internal_action_ref_no =
                                                    axs.internal_action_ref_no
                        AND spq.smelter_id IS NULL
                        AND spq.is_active = 'Y'
                        AND spq.is_stock_split = 'N'
                        AND spq.qty_type = 'Returnable'
                        AND grd.stock_status = 'In Warehouse'
                        AND bvc_product.element_id = spq.element_id
                        AND bvc_product.product_id = grd.product_id
                        AND bvc_product.quality_id = grd.quality_id
                        AND grd.internal_grd_ref_no = spq.internal_grd_ref_no
                        AND gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
                        AND pci.internal_contract_item_ref_no =
                                             grd.internal_contract_item_ref_no
                     UNION
                     SELECT prrqs.prrqs_id unique_id, prrqs.corporate_id,
                            pci.contract_type,
                            pci.internal_contract_ref_no
                                                     internal_contract_ref_no,
                            pci.contract_ref_no contract_ref_no,
                            pci.middle_no contract_middle_no,
                            grd.internal_contract_item_ref_no
                                                internal_contract_item_ref_no,
                            pci.contract_item_ref_no contract_item_ref_no,
                            pci.pcdi_id pcdi_id, pci.delivery_item_no,
                            pci.del_distribution_item_no,
                            pci.delivery_item_ref_no delivery_item_ref_no,
                            prrqs.internal_grd_ref_no stock_id,
                            grd.internal_stock_ref_no stock_ref_no,
                            prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                            gmr.gmr_ref_no gmr_ref_no,
                            prrqs.activity_action_id, prrqs.cp_id supplier_id,
                            prrqs.to_cp_id to_supplier_id,
                            prrqs.product_id product_id,
                            pdm.product_desc product_name,
                            (prrqs.qty_sign * prrqs.qty) qty,
                            (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                            prrqs.qty_unit_id qty_unit_id,
                            axs.internal_action_ref_no,
                            axs.eff_date activity_date,
                            (prrqs.qty_sign * prrqs.assay_content
                            ) assay_content,
                            (prrqs.qty_sign * 0) ext_assay_content,
                            '' assay_finalized, prrqs.due_date,
                            gmr.invoice_ref_no, gmr.invoice_issue_date,
                            '' landing_date, 'No' is_warrant
                       FROM prrqs_prr_qty_status prrqs,
                            axs_action_summary axs,
                            pdm_productmaster pdm,
                            grd_goods_record_detail grd,
                            gmr_goods_movement_record gmr,
                            v_pci pci
                      WHERE prrqs.internal_action_ref_no =
                                                    axs.internal_action_ref_no
                        AND gmr.internal_gmr_ref_no =
                                                     prrqs.internal_gmr_ref_no
                        AND grd.internal_grd_ref_no =
                                                     prrqs.internal_grd_ref_no
                        AND grd.internal_gmr_ref_no =
                                                     prrqs.internal_gmr_ref_no
                        AND pci.internal_contract_item_ref_no =
                                             grd.internal_contract_item_ref_no
                        AND prrqs.cp_type = 'Supplier'
                        AND prrqs.is_active = 'Y'
                        AND prrqs.qty_type = 'Returnable'
                        AND pdm.product_id = prrqs.product_id
                        AND prrqs.activity_action_id IN
                                    ('pledgeTransfer', 'financialSettlement')
                     UNION
                     SELECT prrqs.prrqs_id unique_id, prrqs.corporate_id,
                            pci.contract_type,
                            pci.internal_contract_ref_no
                                                     internal_contract_ref_no,
                            pci.contract_ref_no contract_ref_no,
                            pci.middle_no contract_middle_no,
                            dgrd.internal_contract_item_ref_no
                                                internal_contract_item_ref_no,
                            pci.contract_item_ref_no contract_item_ref_no,
                            pci.pcdi_id pcdi_id, pci.delivery_item_no,
                            pci.del_distribution_item_no,
                            pci.delivery_item_ref_no delivery_item_ref_no,
                            prrqs.internal_grd_ref_no stock_id,
                            dgrd.internal_stock_ref_no stock_ref_no,
                            prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                            gmr.gmr_ref_no gmr_ref_no,
                            prrqs.activity_action_id, prrqs.cp_id supplier_id,
                            prrqs.to_cp_id to_supplier_id,
                            prrqs.product_id product_id,
                            pdm.product_desc product_name,
                            (prrqs.qty_sign * prrqs.qty) qty,
                            (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                            prrqs.qty_unit_id qty_unit_id,
                            axs.internal_action_ref_no,
                            axs.eff_date activity_date,
                            (prrqs.qty_sign * prrqs.assay_content
                            ) assay_content,
                            (prrqs.qty_sign * 0) ext_assay_content,
                            '' assay_finalized, prrqs.due_date,
                            gmr.invoice_ref_no, gmr.invoice_issue_date,
                            '' landing_date, 'No' is_warrant
                       FROM prrqs_prr_qty_status prrqs,
                            axs_action_summary axs,
                            pdm_productmaster pdm,
                            dgrd_delivered_grd dgrd,
                            gmr_goods_movement_record gmr,
                            v_pci pci
                      WHERE prrqs.internal_action_ref_no =
                                                    axs.internal_action_ref_no
                        AND gmr.internal_gmr_ref_no =
                                                     prrqs.internal_gmr_ref_no
                        AND dgrd.internal_dgrd_ref_no =
                                                    prrqs.internal_dgrd_ref_no
                        AND dgrd.internal_gmr_ref_no =
                                                     prrqs.internal_gmr_ref_no
                        AND pci.internal_contract_item_ref_no =
                                            dgrd.internal_contract_item_ref_no
                        AND prrqs.cp_type = 'Supplier'
                        AND prrqs.is_active = 'Y'
                        AND prrqs.qty_type = 'Returnable'
                        AND pdm.product_id = prrqs.product_id
                        AND prrqs.activity_action_id = 'financialSettlement'
                     UNION
                     SELECT prrqs.prrqs_id unique_id, prrqs.corporate_id,
                            '' contract_type, '' internal_contract_ref_no,
                            '' contract_ref_no, 0 contract_middle_no,
                            '' internal_contract_item_ref_no,
                            '' contract_item_ref_no, '' pcdi_id,
                            '' delivery_item_no, 0 del_distribution_item_no,
                            '' delivery_item_ref_no,
                            prrqs.internal_grd_ref_no stock_id,
                            '' stock_ref_no,
                            prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                            '' gmr_ref_no, prrqs.activity_action_id,
                            prrqs.cp_id supplier_id,
                            prrqs.to_cp_id to_supplier_id,
                            prrqs.product_id product_id,
                            pdm.product_desc product_name,
                            (prrqs.qty_sign * prrqs.qty) qty,
                            (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                            prrqs.qty_unit_id qty_unit_id,
                            axs.internal_action_ref_no,
                            axs.eff_date activity_date,
                            (prrqs.qty_sign * prrqs.assay_content
                            ) assay_content,
                            (prrqs.qty_sign * 0) ext_assay_content,
                            '' assay_finalized, prrqs.due_date,
                            '' invoice_ref_no, '' invoice_issue_date,
                            '' landing_date, 'No' is_warrant
                       FROM prrqs_prr_qty_status prrqs,
                            axs_action_summary axs,
                            pdm_productmaster pdm
                      WHERE prrqs.internal_action_ref_no =
                                                    axs.internal_action_ref_no
                        AND prrqs.cp_type = 'Supplier'
                        AND prrqs.is_active = 'Y'
                        AND prrqs.qty_type = 'Returnable'
                        AND pdm.product_id = prrqs.product_id
                        AND prrqs.activity_action_id = 'metalBalanceTransfer') retn_temp
             UNION
             SELECT prrqs.prrqs_id unique_id, prrqs.corporate_id,
                    '' contract_type, '' internal_contract_ref_no,
                    '' contract_ref_no, 0 contract_middle_no,
                    '' internal_contract_item_ref_no, '' contract_item_ref_no,
                    '' pcdi_id, '' delivery_item_no,
                    0 del_distribution_item_no, '' delivery_item_ref_no,
                    dgrd.internal_dgrd_ref_no stock_id,
                    dgrd.internal_stock_ref_no stock_ref_no,
                    prrqs.internal_gmr_ref_no, gmr.gmr_ref_no,
                    prrqs.activity_action_id, prrqs.cp_id supplier_id,
                    prrqs.to_cp_id debt_supplier_id,
                    prrqs.product_id product_id,
                    pdm.product_desc product_name,
                    (prrqs.qty_sign * prrqs.qty) debt_qty,
                    (prrqs.qty_sign * prrqs.ext_qty) ext_debt_qty,
                    prrqs.qty_unit_id debt_qty_unit_id,
                    axs.internal_action_ref_no, axs.eff_date activity_date,
                    (prrqs.qty_sign * prrqs.assay_content) assay_content,
                    (prrqs.qty_sign * 0) ext_assay_content,
                    '' assay_finalized, prrqs.due_date, gmr.invoice_ref_no,
                    gmr.invoice_issue_date, '' landing_date,
                    (CASE
                        WHEN (dgrd.is_warrant = 'Y')
                           THEN 'Yes'
                        ELSE 'No'
                     END
                    ) is_warrant
               FROM prrqs_prr_qty_status prrqs,
                    axs_action_summary axs,
                    pdm_productmaster pdm,
                    dgrd_delivered_grd dgrd,
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
            qum_quantity_unit_master qum
      WHERE axm.action_id = mat_temp.activity_action_id
        AND phd.profileid = mat_temp.supplier_id
        AND phd_debt.profileid(+) = mat_temp.debt_supplier_id
        AND qum.qty_unit_id = mat_temp.debt_qty_unit_id
   ORDER BY mat_temp.activity_date DESC;
