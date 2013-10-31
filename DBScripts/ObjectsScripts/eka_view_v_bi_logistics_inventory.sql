CREATE OR REPLACE VIEW V_BI_LOGISTICS_INVENTORY AS
with v_ash as(SELECT   ash.ash_id, SUM (NVL (pqca.typical, 0)) typical
       FROM ash_assay_header ash,
            asm_assay_sublot_mapping asm,
            pqca_pq_chemical_attributes pqca
      WHERE ash.ash_id = asm.ash_id
        AND asm.asm_id = pqca.asm_id
        AND pqca.is_active = 'Y'
   GROUP BY ash.ash_id )
select gmr.corporate_id,
       akc.corporate_name,
       grd.product_id,
       pdm.product_desc,
       grd.quality_id,
       qat.quality_name,
       gmr.gmr_ref_no,
       (case when gmr.gmr_latest_action_action_id = 'landingDetail' then 'Landed'
             when gmr.gmr_latest_action_action_id = 'shipmentDetail' then 'Shipped'
       else ''
       end) gmr_type,
       gmr.bl_date shipment_activity_date,
       agmr.eff_date landing_activity_date,
       wrd.activity_ref_no arrival_no,
       gmr_gd.mode_of_transport,
       agmr.bl_no trip_vehicle,
       gmr.vessel_name,
       cim_load.city_id loading_city_id,
       cim_load.city_name loading_city_name,
       sm_load.state_id loading_state_id,
       sm_load.state_name loading_state_name,
       cym_load.country_id loading_country_id,
       cym_load.country_name loading_country_name,
       cim_discharge.city_id discharge_city_id,
       cim_discharge.city_name discharge_city_name,
       sm_discharge.state_id discharge_state_id,
       sm_discharge.state_name discharge_state_name,
       cym_discharge.country_id discharge_country_id,
       cym_discharge.country_name discharge_country_name,
       sld.storage_loc_id warehouse_location_id,
       sld.storage_location_name warehouse_location,
       sld.country_id warehouse_country_id,
       cym_sld.country_name warehouse_country_name,
       sld.state_id warehouse_state_id,
       sm_sld.state_name warehouse_state_name,
       sld.city_id warehouse_city_id,
       cim_sld.city_name warehouse_city_name,
       qum.qty_unit product_base_UoM,
       sum(nvl(grd.shipped_net_qty,0)) BL_Wet_weight,
       sum(case
            when pcpq.unit_of_measure = 'Wet' then
             pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                     sam.ash_id,
                                                     nvl(grd.shipped_net_qty,0),
                                                     grd.qty_unit_id)
            else
              nvl(grd.shipped_net_qty,0)
          end) BL_Dry_weight,
       qum.qty_unit actual_product_base_UoM,
       sum(nvl(grd.landed_net_qty,0)) actual_Wet_weight,
       sum(case
            when pcpq.unit_of_measure = 'Wet' then
             pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                     sam.ash_id,
                                                     nvl(grd.landed_net_qty,0),
                                                     grd.qty_unit_id)
            else
             nvl(grd.landed_net_qty,0)
          end)actual_Dry_weight
  from gmr_goods_movement_record    gmr,
       ak_corporate                 akc,
       grd_goods_record_detail      grd,
       pci_physical_contract_item   pci,
       pcdi_pc_delivery_item        pcdi,
       pcm_physical_contract_main   pcm,
       pcpd_pc_product_definition   pcpd,
       pcpq_pc_product_quality      pcpq,
       ( select gmr.internal_gmr_ref_no,
                agmr.current_qty,
                agmr.released_qty release_shipped_qty,
                agmr.tt_out_qty title_transfer_out_qty,
                (case when agmr.gmr_latest_action_action_id = 'shipmentDetail'
                      then 'Ship'
                      when agmr.gmr_latest_action_action_id = 'railDetail'
                      then 'Rail'
                      when agmr.gmr_latest_action_action_id = 'truckDetail'
                      then 'Truck'
                      when agmr.gmr_latest_action_action_id = 'airDetail'
                      then 'Air'
                      else ''
                end
                )mode_of_transport
                 from  gmr_goods_movement_record gmr,
                       agmr_action_gmr agmr
                 where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                   and agmr.action_no = 1
      )gmr_gd,
       agmr_action_gmr              agmr,
       wrd_warehouse_receipt_detail wrd,
       sld_storage_location_detail  sld,
       sm_state_master              sm_sld,
       cim_citymaster               cim_sld,
       cym_countrymaster            cym_sld,
       pdm_productmaster            pdm,
       qat_quality_attributes       qat,
       qum_quantity_unit_master     qum,
       sm_state_master              sm_load,
       cim_citymaster               cim_load,
       cym_countrymaster            cym_load,
       sm_state_master              sm_Discharge,
       cim_citymaster               cim_Discharge,
       cym_countrymaster            cym_Discharge,
       ash_assay_header             ash,
       v_ash  vdc,
       sam_stock_assay_mapping sam
 where gmr.corporate_id = akc.corporate_id
   and gmr.is_deleted = 'N'
   and gmr.is_internal_movement = 'Y'
   and gmr.gmr_latest_action_action_id <> 'warehouseReceipt'
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and nvl(grd.is_afloat,'N') = 'N'
   and grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
   and pci.is_active = 'Y'
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.is_active = 'Y'
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and pcm.is_active = 'Y'
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.pcpd_id = pcpq.pcpd_id(+)
   and pcpd.pcpd_id = pcpq.pcpd_id(+)
   and pcpq.is_active = 'Y'
   and gmr.internal_gmr_ref_no = gmr_gd.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and gmr.gmr_latest_action_action_id = agmr.gmr_latest_action_action_id
   and gmr.internal_gmr_ref_no = wrd.internal_gmr_ref_no(+)
   and wrd.shed_id = sld.storage_loc_id(+)
   and sld.state_id = sm_sld.state_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and sld.country_id = cym_sld.country_id(+)
   and pcpd.product_id = pdm.product_id(+)
   and pcpq.quality_template_id = qat.quality_id(+)
   and qat.is_active = 'Y'
   and grd.qty_unit_id = qum.qty_unit_id
   and qum.is_active = 'Y'
   and gmr.loading_state_id = sm_load.state_id(+)
   and gmr.loading_city_id = cim_load.city_id(+)
   and gmr.loading_country_id = cym_load.country_id(+)
   and gmr.discharge_state_id = sm_discharge.state_id(+)
   and gmr.discharge_city_id = cim_discharge.city_id(+)
   and gmr.discharge_country_id = cym_discharge.country_id(+)
   and grd.internal_grd_ref_no=sam.internal_grd_ref_no
   and sam.ash_id=ash.ash_id
   and ash.ash_id = vdc.ash_id
   and nvl(sam.is_latest_pricing_assay,'Y') = 'Y'
group by
          gmr.corporate_id,
          akc.corporate_name,
          grd.product_id,
          pdm.product_desc,
          grd.quality_id,
          qat.quality_name,
          gmr.gmr_ref_no,
          gmr.gmr_latest_action_action_id,
          gmr.bl_date,
          agmr.eff_date,
          wrd.activity_ref_no,
          gmr_gd.mode_of_transport,
          agmr.bl_no,
          gmr.vessel_name,
          cim_load.city_id,
          cim_load.city_name,
          sm_load.state_id,
          sm_load.state_name,
          cym_load.country_id,
          cym_load.country_name,
          cim_discharge.city_id,
          cim_discharge.city_name,
          sm_discharge.state_id,
          sm_discharge.state_name,
          cym_discharge.country_id,
          cym_discharge.country_name,
          sld.storage_loc_id,
          sld.storage_location_name,
          sld.country_id,
          cym_sld.country_name,
          sld.state_id,
          sm_sld.state_name,
          sld.city_id,
          cim_sld.city_name,
          qum.qty_unit
/