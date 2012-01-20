create or replace view V_IN_PROCESS_STOCK
as
SELECT gmr.corporate_id,
       grd.internal_grd_ref_no,
       grd.internal_stock_ref_no stock_ref_no,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       axs.action_id,
       axm.action_name action_name,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no,
       pci.internal_contract_item_ref_no,
       pci.contract_item_ref_no,
       pci.internal_contract_ref_no,
       pci.contract_ref_no,
       wrd.smelter_cp_id smelter_cp_id,
       phd.companyname smelter_cp_name,
       grd.product_id,
       prdm.product_desc product_name,
       qat.quality_id,
       qat.quality_name,
       grd.element_id,
       aml.attribute_name element_name,
       grd.warehouse_profile_id,
       shm.companyname AS warehouse,
       grd.shed_id,
       shm.shed_name,
       nvl(grd.qty,
           0) AS stock_qty,
       pkg_general.f_get_quantity_unit(grd.qty_unit_id) AS qty_unit,
       grd.qty_unit_id AS qty_unit_id,
       grd.payable_returnable_type,
       grd.tolling_stock_type
FROM   grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       gam_gmr_action_mapping       gam,
       axs_action_summary           axs,
       axm_action_master            axm,
       wrd_warehouse_receipt_detail wrd,
       v_pci                        pci,
       v_shm_shed_master            shm,
       pdm_productmaster            prdm,
       qat_quality_attributes       qat,
       aml_attribute_master_list    aml,
       phd_profileheaderdetails     phd
WHERE  grd.is_deleted = 'N'
AND    grd.status = 'Active'
AND    grd.tolling_stock_type IN
       ('MFT In Process Stock', 'RM In Process Stock', 'Free Material Stock')
AND    gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
AND    gmr.is_deleted = 'N'
AND    wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    pci.internal_contract_item_ref_no(+) = grd.internal_contract_item_ref_no
AND    shm.profile_id = grd.warehouse_profile_id
AND    shm.shed_id = grd.shed_id
AND    prdm.product_id = grd.product_id
AND    qat.quality_id = grd.quality_id
AND    aml.attribute_id(+) = grd.element_id
AND    phd.profileid = wrd.smelter_cp_id
AND    gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
AND    gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
AND    axs.internal_action_ref_no(+) = gam.internal_action_ref_no
AND    axs.status(+) = 'Active'
AND    axm.action_id(+) = axs.action_id;
