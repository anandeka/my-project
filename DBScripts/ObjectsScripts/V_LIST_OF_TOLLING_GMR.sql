CREATE OR REPLACE FORCE VIEW v_list_of_tolling_gmr
AS
   SELECT gmr.corporate_id AS corporate_id,
          gmr.internal_gmr_ref_no AS internal_gmr_ref_no,
          gmr.qty || ' ' || qum.qty_unit AS gmr_qty_string,
          gmr.gmr_ref_no AS gmr_ref_no,
          gmr.is_pass_through AS is_pass_through,
          gmr.tolling_gmr_type AS process_type, gam.action_no AS action_no,
          axs.internal_action_ref_no AS internal_action_ref_no,
          (CASE
              WHEN axm.action_id = 'RECORD_OUT_PUT_TOLLING'
                 THEN 'Receive Material'
              ELSE axm.action_name
           END
          ) activity,
          axs.eff_date AS activity_date, axs.action_ref_no AS activity_ref_no,
          gmr.gmr_latest_action_action_id AS latest_action_id,
          (CASE
              WHEN axm_latest.action_id = 'RECORD_OUT_PUT_TOLLING'
                 THEN 'Receive Material'
              ELSE axm_latest.action_name
           END
          ) latest_action_name,
          gmr.warehouse_profile_id AS warehouse_profile_id,
          shm.companyname AS warehouse, shm.shed_name AS shed_name,
          (CASE
              WHEN axm.action_id IN
                        ('RECORD_OUT_PUT_TOLLING', 'RECEIVE_MATERIAL_MODIFY')
                 THEN (SELECT f_string_aggregate (grd_rm.product_id)
                         FROM grd_goods_record_detail grd_rm
                        WHERE grd_rm.tolling_stock_type =
                                                        'RM Out Process Stock'
                          AND grd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              WHEN axm.action_id = 'CREATE_RETURN_MATERIAL'
                 THEN (SELECT f_string_aggregate (dgrd_rm.product_id)
                         FROM dgrd_delivered_grd dgrd_rm
                        WHERE dgrd_rm.tolling_stock_type =
                                                       'Return Material Stock'
                          AND dgrd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              WHEN axm.action_id = 'IN_PROCESS_ADJUSTMENT'
                 THEN (SELECT f_string_aggregate (grd_rm.product_id)
                         FROM grd_goods_record_detail grd_rm
                        WHERE grd_rm.tolling_stock_type =
                                                 'In Process Adjustment Stock'
                          AND grd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              ELSE cp.product_id
           END
          ) AS product_id,
          (CASE
              WHEN axm.action_id IN
                        ('RECORD_OUT_PUT_TOLLING', 'RECEIVE_MATERIAL_MODIFY')
                 THEN (SELECT f_string_aggregate (pdm_in.product_desc)
                         FROM grd_goods_record_detail grd_rm,
                              pdm_productmaster pdm_in
                        WHERE pdm_in.product_id = grd_rm.product_id
                          AND grd_rm.tolling_stock_type =
                                                        'RM Out Process Stock'
                          AND grd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              WHEN axm.action_id = 'CREATE_RETURN_MATERIAL'
                 THEN (SELECT f_string_aggregate (pdm_in.product_desc)
                         FROM dgrd_delivered_grd dgrd_rm,
                              pdm_productmaster pdm_in
                        WHERE pdm_in.product_id = dgrd_rm.product_id
                          AND dgrd_rm.tolling_stock_type =
                                                       'Return Material Stock'
                          AND dgrd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              WHEN axm.action_id = 'IN_PROCESS_ADJUSTMENT'
                 THEN (SELECT f_string_aggregate (DISTINCT pdm_in.product_desc)
                         FROM grd_goods_record_detail grd_rm,
                              pdm_productmaster pdm_in
                        WHERE pdm_in.product_id = grd_rm.product_id
                          AND grd_rm.tolling_stock_type =
                                                 'In Process Adjustment Stock'
                          AND grd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              ELSE cp.product_name
           END
          ) AS product_name,
          (CASE
              WHEN axm.action_id IN
                        ('RECORD_OUT_PUT_TOLLING', 'RECEIVE_MATERIAL_MODIFY')
                 THEN (SELECT f_string_aggregate (grd_rm.quality_id)
                         FROM grd_goods_record_detail grd_rm
                        WHERE grd_rm.tolling_stock_type =
                                                        'RM Out Process Stock'
                          AND grd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              WHEN axm.action_id = 'CREATE_RETURN_MATERIAL'
                 THEN (SELECT f_string_aggregate (dgrd_rm.quality_id)
                         FROM dgrd_delivered_grd dgrd_rm
                        WHERE dgrd_rm.tolling_stock_type =
                                                       'Return Material Stock'
                          AND dgrd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              WHEN axm.action_id = 'IN_PROCESS_ADJUSTMENT'
                 THEN (SELECT f_string_aggregate (grd_rm.quality_id)
                         FROM grd_goods_record_detail grd_rm
                        WHERE grd_rm.tolling_stock_type =
                                                 'In Process Adjustment Stock'
                          AND grd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              ELSE cp.quality_id
           END
          ) AS quality_id,
          (CASE
              WHEN axm.action_id IN
                        ('RECORD_OUT_PUT_TOLLING', 'RECEIVE_MATERIAL_MODIFY')
                 THEN (SELECT f_string_aggregate (qat_in.quality_name)
                         FROM grd_goods_record_detail grd_rm,
                              qat_quality_attributes qat_in
                        WHERE qat_in.quality_id = grd_rm.quality_id
                          AND grd_rm.tolling_stock_type =
                                                        'RM Out Process Stock'
                          AND grd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              WHEN axm.action_id = 'CREATE_RETURN_MATERIAL'
                 THEN (SELECT f_string_aggregate (qat_in.quality_name)
                         FROM dgrd_delivered_grd dgrd_rm,
                              qat_quality_attributes qat_in
                        WHERE qat_in.quality_id = dgrd_rm.quality_id
                          AND dgrd_rm.tolling_stock_type =
                                                       'Return Material Stock'
                          AND dgrd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              WHEN axm.action_id = 'IN_PROCESS_ADJUSTMENT'
                 THEN (SELECT f_string_aggregate (DISTINCT qat_in.quality_name)
                         FROM grd_goods_record_detail grd_rm,
                              qat_quality_attributes qat_in
                        WHERE qat_in.quality_id = grd_rm.quality_id
                          AND grd_rm.tolling_stock_type =
                                                 'In Process Adjustment Stock'
                          AND grd_rm.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
              ELSE cp.quality_name
           END
          ) AS quality_name,
          gmr.qty AS gmr_qty, gmr.qty_unit_id AS qty_unit_id,
          qum.qty_unit AS qty_unit, wrd.smelter_cp_id AS cp_profile_id,
          phd_cp.companyname AS cp_name,
          cp.price_allocation_method AS price_allocation_method,
          cp.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          cp.contract_item_ref_no AS contract_item_ref_no,
          cp.internal_contract_ref_no AS internal_contract_ref_no,
          cp.contract_ref_no AS contract_ref_no,
          gmr.free_material_status is_free_material, cp.pcdi_id pcdi_id,
          cp.deliveryitemrefno AS delivery_item_ref_no, wrd.feeding_point_id,
          sfp.feeding_point_name, cp.contract_status, axs.created_date,
          aku_create.login_name created_by, axs_last.updated_date,
          aku_last.login_name updated_by
     FROM gmr_goods_movement_record gmr,
          gam_gmr_action_mapping gam,
          ak_corporate_user aku_create,
          axs_action_summary axs,
          axm_action_master axm,
          axm_action_master axm_latest,
          ak_corporate_user aku_last,
          axs_action_summary axs_last,
          v_shm_shed_master shm,
          (SELECT pci.internal_contract_ref_no internal_contract_ref_no,
                  pci.contract_ref_no contract_ref_no,
                  pci.internal_contract_item_ref_no
                                                internal_contract_item_ref_no,
                  pci.contract_item_ref_no contract_item_ref_no,
                  pci.product_id product_id, pci.product_name product_name,
                  pci.quality_id quality_id, pci.quality_name quality_name,
                  gcim.internal_gmr_ref_no internal_gmr_ref_no,
                  pci.price_allocation_method AS price_allocation_method,
                  pci.pcdi_id pcdi_id,
                  pci.delivery_item_ref_no deliveryitemrefno,
                  pci.contract_status contract_status
             FROM v_pci pci, gcim_gmr_contract_item_mapping gcim
            WHERE pci.internal_contract_item_ref_no =
                                            gcim.internal_contract_item_ref_no) cp,
          wrd_warehouse_receipt_detail wrd,
          phd_profileheaderdetails phd_cp,
          sfp_smelter_feeding_point sfp,
          qum_quantity_unit_master qum
    WHERE gmr.internal_gmr_ref_no = wrd.internal_gmr_ref_no
      AND gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
      AND gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
      AND axs.internal_action_ref_no(+) = gam.internal_action_ref_no
      AND axs.status(+) = 'Active'
      AND axm.action_id(+) = axs.action_id
      AND aku_create.user_id = axs.created_by
      AND gmr.is_deleted = 'N'
      AND wrd.warehouse_profile_id = shm.profile_id(+)
      AND wrd.shed_id = shm.shed_id(+)
      AND phd_cp.profileid = wrd.smelter_cp_id
      AND sfp.feeding_point_id(+) = wrd.feeding_point_id
      AND gmr.internal_gmr_ref_no = cp.internal_gmr_ref_no(+)
      AND NVL (gmr.tolling_gmr_type, 'None Tolling') IN
             ('Mark For Tolling', 'Received Materials', 'Return Material',
              'In Process Adjustment')
      AND axs_last.internal_action_ref_no = gmr.internal_action_ref_no
      AND aku_last.user_id = axs_last.created_by
      AND axm_latest.action_id = gmr.gmr_latest_action_action_id
      AND qum.qty_unit_id = gmr.qty_unit_id;
