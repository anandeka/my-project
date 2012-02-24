create or replace view v_in_process_stock as
select gmr.corporate_id,
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
       shm.companyname as warehouse,
       grd.shed_id,
       shm.shed_name,
       nvl(grd.qty, 0) as stock_qty,
       pkg_general.f_get_quantity_unit(grd.qty_unit_id) as qty_unit,
       grd.qty_unit_id as qty_unit_id,
       grd.payable_returnable_type,
       grd.tolling_stock_type,
       to_char(spq.assay_content) as assay_content_qty
  from grd_goods_record_detail      grd,
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
       phd_profileheaderdetails     phd,
       spq_stock_payable_qty        spq
 where grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.tolling_stock_type in
       ('MFT In Process Stock', 'Delta MFT IP Stock')
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and gmr.is_deleted = 'N'
   and wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pci.internal_contract_item_ref_no(+) =
       grd.internal_contract_item_ref_no
   and shm.profile_id = grd.warehouse_profile_id
   and shm.shed_id = grd.shed_id
   and prdm.product_id = grd.product_id
   and qat.quality_id = grd.quality_id
   and aml.attribute_id = grd.element_id
   and spq.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and spq.internal_grd_ref_no = grd.parent_internal_grd_ref_no
   and spq.element_id = grd.element_id
   and spq.is_active = 'Y'
   and phd.profileid = wrd.smelter_cp_id
   and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
union
select gmr.corporate_id,
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
       shm.companyname as warehouse,
       grd.shed_id,
       shm.shed_name,
       nvl(grd.qty, 0) as stock_qty,
       pkg_general.f_get_quantity_unit(grd.qty_unit_id) as qty_unit,
       grd.qty_unit_id as qty_unit_id,
       grd.payable_returnable_type,
       grd.tolling_stock_type,
       '' assay_content_qty
  from grd_goods_record_detail      grd,
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
 where grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.tolling_stock_type in
       ('RM In Process Stock', 'Free Material Stock')
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and gmr.is_deleted = 'N'
   and wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pci.internal_contract_item_ref_no(+) =
       grd.internal_contract_item_ref_no
   and shm.profile_id = grd.warehouse_profile_id
   and shm.shed_id = grd.shed_id
   and prdm.product_id = grd.product_id
   and qat.quality_id = grd.quality_id
   and aml.attribute_id(+) = grd.element_id
   and phd.profileid = wrd.smelter_cp_id
   and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
union
select sbs.corporate_id,
       sbs.sbs_id internal_grd_ref_no,
       '' stock_ref_no,
       '' internal_gmr_ref_no,
       '' gmr_ref_no,
       '' action_id,
       '' action_name,
       '' internal_action_ref_no,
       sbs.activity_date,
       '' action_ref_no,
       '' internal_contract_item_ref_no,
       '' contract_item_ref_no,
       '' internal_contract_ref_no,
       '' contract_ref_no,
       sbs.smelter_cp_id smelter_cp_id,
       phd.companyname smelter_cp_name,
       sbs.product_id,
       pdm.product_desc product_name,
       sbs.quality_id,
       qat.quality_name,
       sbs.element_id,
       aml.attribute_name element_name,
       sbs.warehouse_profile_id,
       shm.companyname as warehouse,
       sbs.shed_id,
       shm.shed_name,
       nvl(sbs.qty, 0) as stock_qty,
       pkg_general.f_get_quantity_unit(sbs.qty_unit_id) as qty_unit,
       sbs.qty_unit_id as qty_unit_id,
       'Returnable' payable_returnable_type,
       'Base Stock' tolling_stock_type,
       '' assay_content_qty
  from sbs_smelter_base_stock    sbs,
       pdm_productmaster         pdm,
       qat_quality_attributes    qat,
       aml_attribute_master_list aml,
       phd_profileheaderdetails  phd,
       v_shm_shed_master         shm
 where pdm.product_id = sbs.product_id
   and qat.quality_id = sbs.quality_id
   and phd.profileid = sbs.smelter_cp_id
   and aml.attribute_id(+) = sbs.element_id
   and sbs.is_active = 'Y'
   and shm.profile_id = sbs.warehouse_profile_id
   and shm.shed_id = sbs.shed_id
