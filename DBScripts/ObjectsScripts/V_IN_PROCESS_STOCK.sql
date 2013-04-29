create or replace view v_in_process_stock as
select ips_temp.corporate_id,
       ips_temp.internal_grd_ref_no,
       ips_temp.stock_ref_no,
       ips_temp.internal_gmr_ref_no,
       ips_temp.gmr_ref_no,
       ips_temp.action_id,
       (case
         when ips_temp.action_id = 'RECORD_OUT_PUT_TOLLING' then
          'Receive Material'
         when ips_temp.action_id = 'CREATE_FREE_MATERIAL' then
          'Capture Yield'
         when ips_temp.action_id = 'IN_PROCESS_ADJUSTMENT' then
          'In Process Adjustment'
         else
          ips_temp.action_name
       end) action_name,
       ips_temp.internal_action_ref_no,
       ips_temp.activity_date,
       ips_temp.action_ref_no,
       ips_temp.internal_contract_item_ref_no,
       ips_temp.contract_item_ref_no,
       ips_temp.pcdi_id,
       ips_temp.delivery_item_ref_no,
       ips_temp.internal_contract_ref_no,
       ips_temp.contract_ref_no,
       ips_temp.smelter_cp_id,
       ips_temp.smelter_cp_name,
       ips_temp.product_id,
       ips_temp.product_name,
       ips_temp.quality_id,
       ips_temp.quality_name,
       ips_temp.element_id,
       ips_temp.element_name,
       ips_temp.warehouse_profile_id,
       ips_temp.warehouse,
       ips_temp.shed_id,
       ips_temp.shed_name,
       ips_temp.stock_qty,
       ips_temp.qty_unit,
       ips_temp.qty_unit_id,
       ips_temp.payable_returnable_type,
       (case
         when ips_temp.tolling_stock_type = 'RM In Process Stock' then
          'Receive Material Stock'
         when ips_temp.tolling_stock_type = 'MFT In Process Stock' then
          'In Process Stock'
       /* when ips_temp.tolling_stock_type = 'Free Material Stock' then
       'Free Metal Stock'*/
         when ips_temp.tolling_stock_type = 'Delta MFT IP Stock' then
          'Delta IP Stock'
         when ips_temp.tolling_stock_type = 'In Process Adjustment Stock' then
          'In Process Adjustment Stock'
         else
          ips_temp.tolling_stock_type
       end) tolling_stock_type,
       ips_temp.assay_content_qty,
       ips_temp.is_pass_through,
       ips_temp.element_by_product,
       ips_temp.input_stock_ref_no,
       ips_temp.utility_header_id,
       fmuh.utility_ref_no,
       ips_temp.pool_id,
       pm.pool_name
  from (select gmr.corporate_id,
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
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
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
               grd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_consc.product_desc) element_by_product,
               grd_cloned.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id,
               grd.pool_id
          from grd_goods_record_detail      grd,
               grd_goods_record_detail      grd_cloned,
               pdm_productmaster            pdm_consc,
               gmr_goods_movement_record    gmr,
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
               ('MFT In Process Stock', 'Delta MFT IP Stock')
           and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and pci.internal_contract_item_ref_no =
               grd.internal_contract_item_ref_no
           and shm.profile_id = grd.warehouse_profile_id
           and shm.shed_id = grd.shed_id
           and prdm.product_id = grd.product_id
           and qat.quality_id = grd.quality_id
           and aml.attribute_id = grd.element_id
           and phd.profileid = wrd.smelter_cp_id
           and axs.internal_action_ref_no = grd.first_int_action_ref_no
           and axm.action_id = axs.action_id
           and grd_cloned.internal_grd_ref_no =
               grd.parent_internal_grd_ref_no
           and grd_cloned.is_deleted = 'N'
         AND (   grd_cloned.status = 'Active'
                   OR grd_cloned.is_clone_stock_spilt = 'Y'
                  )
           and pdm_consc.product_id = grd_cloned.product_id
        
        union all
        
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
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
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
               grd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_parent.product_desc) element_by_product,
               grd_parent.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id,
               grd.pool_id
          from grd_goods_record_detail      grd,
               grd_goods_record_detail      grd_parent,
               pdm_productmaster            pdm_parent,
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
           and grd.tolling_stock_type in( 'RM In Process Stock','In Process Adjustment Stock')
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
           and gam.internal_action_ref_no(+) =
               gmr.gmr_first_int_action_ref_no
           and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
           and axs.status(+) = 'Active'
           and axm.action_id(+) = axs.action_id
           and grd_parent.internal_grd_ref_no(+) =
               grd.parent_internal_grd_ref_no
           and grd_parent.is_deleted(+) = 'N'
           and grd_parent.status(+) = 'Active'
           and pdm_parent.product_id(+) = grd_parent.product_id
        
        union all
        select agmr.corporate_id,
               agrd.internal_grd_ref_no,
               agrd.internal_stock_ref_no stock_ref_no,
               agmr.internal_gmr_ref_no,
               agmr.gmr_ref_no,
               axs.action_id,
               axm.action_name action_name,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               pci.internal_contract_item_ref_no,
               pci.contract_item_ref_no,
               pci.pcdi_id pcdi_id,
               pci.delivery_item_ref_no delivery_item_ref_no,
               pci.internal_contract_ref_no,
               pci.contract_ref_no,
               wrd.smelter_cp_id smelter_cp_id,
               phd.companyname smelter_cp_name,
               agrd.product_id,
               prdm.product_desc product_name,
               qat.quality_id,
               qat.quality_name,
               agrd.element_id,
               aml.attribute_name element_name,
               agrd.warehouse_profile_id,
               shm.companyname as warehouse,
               agrd.shed_id,
               shm.shed_name,
               nvl(agrd.qty, 0) as stock_qty,
               pkg_general.f_get_quantity_unit(agrd.qty_unit_id) as qty_unit,
               agrd.qty_unit_id as qty_unit_id,
               agrd.payable_returnable_type,
               agrd.tolling_stock_type,
               agrd.assay_content as assay_content_qty,
               gmr.is_pass_through is_pass_through,
               (aml.attribute_name || '/' || pdm_consc.product_desc) element_by_product,
               agrd_cloned.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id,
               grd.pool_id
          from agrd_action_grd              agrd,
               grd_goods_record_detail      grd,
               agrd_action_grd              agrd_fm,
               agrd_action_grd              agrd_cloned,
               pdm_productmaster            pdm_consc,
               ypd_yield_pct_detail         ypd,
               gmr_goods_movement_record    gmr,
               agmr_action_gmr              agmr,
               axs_action_summary           axs,
               axm_action_master            axm,
               wrd_warehouse_receipt_detail wrd,
               v_pci                        pci,
               v_shm_shed_master            shm,
               pdm_productmaster            prdm,
               qat_quality_attributes       qat,
               aml_attribute_master_list    aml,
               phd_profileheaderdetails     phd
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and gmr.is_deleted = 'N'
           and agrd.tolling_stock_type in
               ('Free Metal IP Stock', 'Delta FM IP Stock')
           and agmr.gmr_latest_action_action_id = 'CREATE_FREE_MATERIAL'
           and agmr.is_deleted = 'N'
           and agmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
           and agmr.action_no = agrd.action_no
           and agrd_fm.tolling_stock_type = 'Free Material Stock'
           and agrd_fm.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agrd_fm.action_no = agmr.action_no
           and agrd_fm.is_deleted = 'N'
           and agrd_fm.status = 'Active'
           and ypd.internal_gmr_ref_no = agrd.internal_gmr_ref_no
           and ypd.action_no = agrd.action_no
           and ypd.element_id = agrd.element_id
           and ypd.is_active = 'Y'
           and agrd.is_deleted = 'N'
           and agrd.status = 'Active'
           and wrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
           and shm.profile_id = agrd.warehouse_profile_id
           and shm.shed_id = agrd.shed_id
           and prdm.product_id = agrd.product_id
           and qat.quality_id = agrd.quality_id
           and aml.attribute_id = agrd.element_id
           and phd.profileid = wrd.smelter_cp_id
           and axs.internal_action_ref_no = agrd.first_int_action_ref_no
           and axs.status = 'Active'
           and axm.action_id = axs.action_id
           and agrd_cloned.internal_grd_ref_no =
               agrd_fm.parent_internal_grd_ref_no
           and agrd_fm.internal_grd_ref_no = agrd.parent_internal_grd_ref_no
           and agrd_cloned.is_deleted = 'N'
           and (agrd_cloned.status = 'Active'
	       or agrd_cloned.is_clone_stock_spilt = 'Y')
           and pdm_consc.product_id = agrd_cloned.product_id
           and grd.internal_grd_ref_no = agrd.internal_grd_ref_no
        
        /* union all
                
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
        '' pcdi_id,
        '' delivery_item_ref_no,
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
        '' assay_content_qty,
        '' is_pass_through,
        '' element_by_product,
        '' input_stock_ref_no,
        '' utility_header_id,
        '' pool_id
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
        and shm.shed_id = sbs.shed_id*/
        ) ips_temp,
       fmuh_free_metal_utility_header fmuh,
       pm_pool_master pm
 where ips_temp.utility_header_id = fmuh.fmuh_id(+)
   and ips_temp.pool_id = pm.pool_id(+)
