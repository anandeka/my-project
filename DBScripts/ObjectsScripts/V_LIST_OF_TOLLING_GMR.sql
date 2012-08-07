create or replace view v_list_of_tolling_gmr as
select gmr.corporate_id as corporate_id,
       gmr.internal_gmr_ref_no as internal_gmr_ref_no,
       gmr.qty || ' ' || qum.qty_unit as gmr_qty_string,
       gmr.gmr_ref_no as gmr_ref_no,
       gmr.is_pass_through as is_pass_through,
       gmr.tolling_gmr_type as process_type,
       gam.action_no as action_no,
       axs.internal_action_ref_no as internal_action_ref_no,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          'Receive Material'
         else
          axm.action_name
       end) activity,
       axs.eff_date as activity_date,
       axs.action_ref_no as activity_ref_no,
       gmr.gmr_latest_action_action_id as latest_action_id,
       (case
         when axm_latest.action_id = 'RECORD_OUT_PUT_TOLLING' then
          'Receive Material'
         else
          axm_latest.action_name
       end) latest_action_name,
       gmr.warehouse_profile_id as warehouse_profile_id,
       shm.companyname as warehouse,
       shm.shed_name as shed_name,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          (select f_string_aggregate(grd_rm.product_id)
             from grd_goods_record_detail grd_rm
            where grd_rm.tolling_stock_type = 'RM Out Process Stock'
              and grd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         when axm.action_id = 'CREATE_RETURN_MATERIAL' then
          (select f_string_aggregate(dgrd_rm.product_id)
             from dgrd_delivered_grd dgrd_rm
            where dgrd_rm.tolling_stock_type = 'Return Material Stock'
              and dgrd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         else
          cp.product_id
       end) as product_id,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          (select f_string_aggregate(pdm_in.product_desc)
             from grd_goods_record_detail grd_rm,
                  pdm_productmaster       pdm_in
            where pdm_in.product_id = grd_rm.product_id
              and grd_rm.tolling_stock_type = 'RM Out Process Stock'
              and grd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         when axm.action_id = 'CREATE_RETURN_MATERIAL' then
          (select f_string_aggregate(pdm_in.product_desc)
             from dgrd_delivered_grd dgrd_rm,
                  pdm_productmaster  pdm_in
            where pdm_in.product_id = dgrd_rm.product_id
              and dgrd_rm.tolling_stock_type = 'Return Material Stock'
              and dgrd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         else
          cp.product_name
       end) as product_name,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          (select f_string_aggregate(grd_rm.quality_id)
             from grd_goods_record_detail grd_rm
            where grd_rm.tolling_stock_type = 'RM Out Process Stock'
              and grd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         when axm.action_id = 'CREATE_RETURN_MATERIAL' then
          (select f_string_aggregate(dgrd_rm.quality_id)
             from dgrd_delivered_grd dgrd_rm
            where dgrd_rm.tolling_stock_type = 'Return Material Stock'
              and dgrd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         else
          cp.quality_id
       end) as quality_id,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          (select f_string_aggregate(qat_in.quality_name)
             from grd_goods_record_detail grd_rm,
                  qat_quality_attributes  qat_in
            where qat_in.quality_id = grd_rm.quality_id
              and grd_rm.tolling_stock_type = 'RM Out Process Stock'
              and grd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         when axm.action_id = 'CREATE_RETURN_MATERIAL' then
          (select f_string_aggregate(qat_in.quality_name)
             from dgrd_delivered_grd     dgrd_rm,
                  qat_quality_attributes qat_in
            where qat_in.quality_id = dgrd_rm.quality_id
              and dgrd_rm.tolling_stock_type = 'Return Material Stock'
              and dgrd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         else
          cp.quality_name
       end) as quality_name,
       gmr.qty as gmr_qty,
       gmr.qty_unit_id as qty_unit_id,
       qum.qty_unit as qty_unit,
       wrd.smelter_cp_id as cp_profile_id,
       phd_cp.companyname as cp_name,
       cp.price_allocation_method as price_allocation_method,
       cp.internal_contract_item_ref_no as internal_contract_item_ref_no,
       cp.contract_item_ref_no as contract_item_ref_no,
       cp.internal_contract_ref_no as internal_contract_ref_no,
       cp.contract_ref_no as contract_ref_no,
       gmr.free_material_status is_free_material,
       cp.pcdi_id pcdi_id,
       cp.deliveryitemrefno as delivery_item_ref_no,
       wrd.feeding_point_id,
       sfp.feeding_point_name,
       axs.created_date,
       aku_create.login_name created_by,
       axs_last.updated_date,
       aku_last.login_name updated_by
  from gmr_goods_movement_record gmr,
       gam_gmr_action_mapping gam,
       ak_corporate_user aku_create,
       axs_action_summary axs,
       axm_action_master axm,
       axm_action_master axm_latest,
       ak_corporate_user aku_last,
       axs_action_summary axs_last,
       v_shm_shed_master shm,
       (select pci.internal_contract_ref_no      internal_contract_ref_no,
               pci.contract_ref_no               contract_ref_no,
               pci.internal_contract_item_ref_no internal_contract_item_ref_no,
               pci.contract_item_ref_no          contract_item_ref_no,
               pci.product_id                    product_id,
               pci.product_name                  product_name,
               pci.quality_id                    quality_id,
               pci.quality_name                  quality_name,
               gcim.internal_gmr_ref_no          internal_gmr_ref_no,
               pci.price_allocation_method       as price_allocation_method,
               pci.pcdi_id                       pcdi_id,
               pci.delivery_item_ref_no          deliveryitemrefno
          from v_pci                          pci,
               gcim_gmr_contract_item_mapping gcim
         where pci.internal_contract_item_ref_no =
               gcim.internal_contract_item_ref_no) cp,
       wrd_warehouse_receipt_detail wrd,
       phd_profileheaderdetails phd_cp,
       sfp_smelter_feeding_point sfp,
       qum_quantity_unit_master qum
 where gmr.internal_gmr_ref_no = wrd.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
   and aku_create.user_id = axs.created_by
   and gmr.is_deleted = 'N'
   and wrd.warehouse_profile_id = shm.profile_id(+)
   and wrd.shed_id = shm.shed_id(+)
   and phd_cp.profileid = wrd.smelter_cp_id
   and sfp.feeding_point_id(+) = wrd.feeding_point_id
   and gmr.internal_gmr_ref_no = cp.internal_gmr_ref_no(+)
   and nvl(gmr.tolling_gmr_type, 'None Tolling') in
       ('Mark For Tolling', 'Received Materials', 'Return Material')
   and axs_last.internal_action_ref_no = gmr.internal_action_ref_no
   and aku_last.user_id = axs_last.created_by
   and axm_latest.action_id = gmr.gmr_latest_action_action_id
   and qum.qty_unit_id = gmr.qty_unit_id
