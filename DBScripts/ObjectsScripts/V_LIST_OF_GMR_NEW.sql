create or replace view v_list_of_gmr_new as
select gmr.corporate_id,
       cp.contract_ref_no contract_ref_no,
       gmr.trucking_receipt_no trucking_receipt_no,
       gmr.rail_receipt_no rail_receipt_no,
       to_char(gmr.trucking_receipt_date, 'dd-Mon-yyyy') trucking_receipt_date,
       to_char(gmr.rail_receipt_date, 'dd-Mon-yyyy') rail_receipt_date,
       axs.action_id,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no activity_ref_no,
       gmr.warehouse_receipt_no warehouse_receipt_no,
       gmr.warehouse_profile_id warehouse_profile_id,
       phd_warehouse.companyname warehouse,
       gmr.shed_id shed_id,
       sld.storage_location_name shed_name,
       (case
         when gmr.is_internal_movement = 'Y' then
          (select f_string_aggregate(qat_sub.long_desc)
             from grd_goods_record_detail grd_sub,
                  qat_quality_attributes  qat_sub
            where grd_sub.internal_gmr_ref_no = gmr.internal_gmr_ref_no
              and qat_sub.quality_id = grd_sub.quality_id
              and grd_sub.is_deleted = 'N')
         else
          cp.product_specs
       end) productspec,
       nvl(nvl(gmr.current_qty, 0) - nvl(moved_out_qty, 0) -
           nvl(gmr.write_off_qty, 0),
           0) current_qty,
       gmr.qty_unit_id,
       qum.qty_unit,
       gmr.status_id,
       gsm.status status,
       gmr.inventory_status is_title_transfered,
       (select vcd.vessel_name
          from vcd_vessel_creation_detail vcd
         where vcd.vessel_id = vd.vessel_id) vessel_name,
       gmr.gmr_latest_action_action_id latest_action_id,
       (select axm.action_name
          from axm_action_master axm
         where axm.action_id = gmr.gmr_latest_action_action_id) latest_action_name,
       axm.action_name first_action_name,
       axs.action_ref_no,
       gmr.is_internal_movement,
       (case
         when gmr.contract_type = 'Purchase' then
          'P'
         when gmr.contract_type = 'Sales' then
          'S'
         else
          ''
       end) contract_type,
       cp.contract_party_profile_id cp_profile_id,
       cp.cp_name,
       cp.contract_item_ref_no item_nos,
       nvl(gmr.tt_in_qty, 0) tt_in_qty,
       nvl(gmr.tt_out_qty, 0) tt_out_qty,
       nvl(gmr.tt_none_qty, 0) tt_none_qty,
       vd.vessel_voyage_name,
       vd.booking_ref_no,
       gmr.internal_contract_ref_no,
       bl_details.bl_no bl_no,
       bl_details.bl_date bl_date,
       axs.created_date,
       (select aku_sub.login_name
          from ak_corporate_user aku_sub
         where aku_sub.user_id = axs.created_by) created_by,
       axs_last.updated_date,
       (select aku_sub.login_name
          from ak_corporate_user aku_sub
         where aku_sub.user_id = axs_last.created_by) updated_by,
       gmr.is_final_weight is_final_weight,
       gmr.is_warrant is_warrant,
       gmr.tolling_qty tolling_qty,
       cp.price_allocation_method,
       to_char(vd.eta, 'dd-Mon-yyyy') eta,
       gmr.mode_of_transport,
       gmr.wns_status wns_status
  from gmr_goods_movement_record gmr,
       gam_gmr_action_mapping gam,
       axs_action_summary axs,
       axs_action_summary axs_last,
       gsm_gmr_stauts_master gsm,
       qum_quantity_unit_master qum,
       axm_action_master axm,
       phd_profileheaderdetails phd_warehouse,
       sld_storage_location_detail sld,
       vd_voyage_detail vd,
       (select gcim.internal_gmr_ref_no internal_gmr_ref_no,
               f_string_aggregate(pci.contract_ref_no) contract_ref_no,
               f_string_aggregate(pci.cp_id) contract_party_profile_id,
               f_string_aggregate(pci.cp_name) as cp_name,
               f_string_aggregate(pci.contract_item_ref_no) contract_item_ref_no,
               f_string_aggregate(pci.product_specs) product_specs,
               f_string_aggregate(pci.price_allocation_method) as price_allocation_method
          from v_pci_new                      pci,
               gcim_gmr_contract_item_mapping gcim
         where pci.internal_contract_item_ref_no =
               gcim.internal_contract_item_ref_no
         group by gcim.internal_gmr_ref_no) cp,
       (select sd.internal_gmr_ref_no,
               sd.bl_no bl_no,
               sd.bl_date bl_date
          from sd_shipment_detail sd) bl_details
 where gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
   and gmr.is_deleted = 'N'
   and gmr.status_id = gsm.status_id
   and gmr.qty_unit_id = qum.qty_unit_id
   and gmr.warehouse_profile_id = phd_warehouse.profileid(+)
   and gmr.shed_id = sld.storage_loc_id(+)
   and gmr.internal_gmr_ref_no = cp.internal_gmr_ref_no(+)
   and gmr.internal_gmr_ref_no = bl_details.internal_gmr_ref_no(+)
   and nvl(gmr.is_settlement_gmr, 'N') = 'N'
   and nvl(gmr.tolling_gmr_type, 'None Tolling') not in
       ('Input Process', 'Output Process', 'Mark For Tolling',
        'Received Materials', 'Pledge', 'Financial Settlement',
        'Return Material', 'Free Metal Utility')
   and gam.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and vd.status(+) = 'Active'
   and axs_last.internal_action_ref_no = gmr.internal_action_ref_no
