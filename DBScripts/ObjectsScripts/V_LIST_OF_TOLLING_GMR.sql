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
          vts.productid AS product_id, vts.product_desc AS product_name,
          vts.quality_id AS quality_id, vts.quality_name AS quality_name,
          gmr.qty AS gmr_qty, gmr.qty_unit_id AS qty_unit_id,
          qum.qty_unit AS qty_unit, wrd.smelter_cp_id AS cp_profile_id,
          phd_cp.companyname AS cp_name,
          cp.price_allocation_method AS price_allocation_method,
          cp.internal_contract_item_ref_no AS internal_contract_item_ref_no,
          cp.contract_item_ref_no AS contract_item_ref_no,
          cp.internal_contract_ref_no AS internal_contract_ref_no,
          cp.contract_ref_no AS contract_ref_no,
          gmr.free_material_status is_free_material, cp.pcdi_id pcdi_id,
          cp.delivery_item_ref_no AS delivery_item_ref_no,
          wrd.feeding_point_id, cp.contract_status, sfp.feeding_point_name,
          axs.created_date, aku_create.login_name created_by,
          (CASE
           WHEN (   gmr.latest_assay_type IS NOT NULL
                 OR gmr.latest_assay_type = ''
                )
              THEN gmr.latest_assay_type
           ELSE 'N/A'
          END
      	 )latest_assay_type,
       (CASE
           WHEN (   gmr.latest_invoice_type IS NOT NULL
                 OR gmr.latest_invoice_type = ''
                )
              THEN gmr.latest_invoice_type
           ELSE 'N/A'
        END
       ) latest_invoice_type
     FROM gmr_goods_movement_record gmr,
          gam_gmr_action_mapping gam,
          ak_corporate_user aku_create,
          axs_action_summary axs,
          axm_action_master axm,
          axm_action_master axm_latest,
          v_shm_shed_master shm,
          v_tolling_stocks vts,
          (SELECT pci.internal_contract_item_ref_no
                                             AS internal_contract_item_ref_no,
                  pcm.internal_contract_ref_no AS internal_contract_ref_no,
                  pcm.contract_ref_no AS contract_ref_no,
                  (   pcm.contract_ref_no
                   || ' '
                   || 'Item No.'
                   || ' '
                   || pci.del_distribution_item_no
                  ) contract_item_ref_no,
                  pcpd.product_id AS product_id,
                  pdm.product_desc AS product_name,
                  pcpq.quality_template_id AS quality_id,
                  qat.quality_name AS quality_name, pci.pcdi_id AS pcdi_id,
                  pcdi.price_allocation_method,
                  (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
                  ) AS delivery_item_ref_no,
                  gcim.internal_gmr_ref_no internal_gmr_ref_no,
                  pcm.contract_status contract_status
             FROM pci_physical_contract_item pci,
                  pcm_physical_contract_main pcm,
                  pcdi_pc_delivery_item pcdi,
                  pcpd_pc_product_definition pcpd,
                  pdm_productmaster pdm,
                  qat_quality_attributes qat,
                  pcpq_pc_product_quality pcpq,
                  gcim_gmr_contract_item_mapping gcim
            WHERE pci.pcdi_id = pcdi.pcdi_id
              AND pci.pcpq_id = pcpq.pcpq_id
              AND pcpq.pcpq_id = pci.pcpq_id
              AND qat.quality_id = pcpq.quality_template_id
              AND qat.product_id = pdm.product_id
              AND pdm.product_id = pcpd.product_id
              AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
              AND pci.is_active = 'Y'
              AND pcpq.is_active = 'Y'
              AND pcm.contract_status IN ('In Position','Closed')
              AND (   pci.is_called_off = 'Y'
                   OR pcdi.is_phy_optionality_present = 'N'
                  )
              AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
              AND pci.internal_contract_item_ref_no =
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
      AND axm_latest.action_id = gmr.gmr_latest_action_action_id
      AND qum.qty_unit_id = gmr.qty_unit_id
      AND vts.internal_gmr_ref_no = gmr.internal_gmr_ref_no;
