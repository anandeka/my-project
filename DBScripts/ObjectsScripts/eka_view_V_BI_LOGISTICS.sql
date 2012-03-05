create or replace view v_bi_logistics as
select gcd.groupid,
       gcd.groupname corporate_group,
       gmr.corporate_id,
       akc.corporate_name,
       pcpd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       css.strategy_id,
       css.strategy_name,
       pdm.product_id,
       pdm.product_desc,
       qat.quality_id,
       qat.quality_name,
       gmr.contract_type,
       phd.companyname counterparty,
       pcm.contract_ref_no,
       pcm.contract_ref_no || '-' || pci.del_distribution_item_no delivery_item_ref_no,
       pcm.contract_ref_no || '-' || substr(pci.del_distribution_item_no,1,1) internal_contract_item_ref_no,
       gmr.gmr_ref_no,
       (case when gmr.gmr_latest_action_action_id = 'landingDetail' then 'Landed'
             when gmr.gmr_latest_action_action_id = 'shipmentDetail' then 'Shipped'
       else ''
       end) gmr_type,
       gmr.bl_date shipment_activity_date,
       agmr.eff_date landing_activity_date,
       wrd.activity_ref_no arrival_no,
       iis.invoice_type_name invoice_status,
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
       ash.assay_type assay_status,
       qum.qty_unit BL_product_base_UoM,
       sum(nvl(grd.shipped_net_qty,0)) BL_Wet_weight,
       sum(CASE WHEN pcpq.unit_of_measure = 'Dry'
             THEN nvl(grd.shipped_net_qty,0)
             ELSE nvl(grd.shipped_net_qty,0)
                 *(1 - (nvl(vdc.typical, 1) / 100))
        END)BL_Dry_weight,
       qum.qty_unit actual_product_base_UoM,
       sum(nvl(grd.landed_net_qty,0)) actual_Wet_weight,
       sum(CASE WHEN pcpq.unit_of_measure = 'Dry'
             THEN  nvl(grd.landed_net_qty,0)
             ELSE  nvl(grd.landed_net_qty,0) * (1 - (nvl(vdc.typical, 1) / 100))
        END)actual_Dry_weight,
       sum(CASE WHEN pcpq.unit_of_measure = 'Dry'
             THEN nvl(grd.shipped_net_qty,0)
             ELSE nvl(grd.shipped_net_qty,0)
                 *(1 - (nvl(vdc.typical, 1) / 100))
        END) - sum(CASE WHEN pcpq.unit_of_measure = 'Dry'
             THEN  nvl(grd.landed_net_qty,0)
             ELSE  nvl(grd.landed_net_qty,0) * (1 - (nvl(vdc.typical, 1) / 100))
        END)dry_qty_diff,
        sum(nvl(grd.shipped_net_qty,0)) - sum(nvl(grd.landed_net_qty,0)) wet_qty_diff,
        (case when sum(nvl(grd.shipped_net_qty,0)) = 0 then 0
        else
        ((sum(nvl(grd.shipped_net_qty,0)) - sum(nvl(grd.landed_net_qty,0)))/ sum(nvl(grd.shipped_net_qty,0)))
        end) wet_ratio ,
       (case when sum(CASE WHEN pcpq.unit_of_measure = 'Dry'
             THEN nvl(grd.shipped_net_qty,0)
             ELSE nvl(grd.shipped_net_qty,0)
                 *(1 - (nvl(vdc.typical, 1) / 100))
        END) = 0 then 0 else
       (sum(CASE WHEN pcpq.unit_of_measure = 'Dry'
             THEN nvl(grd.shipped_net_qty,0)
             ELSE nvl(grd.shipped_net_qty,0)
                 *(1 - (nvl(vdc.typical, 1) / 100))
        END) - sum(CASE WHEN pcpq.unit_of_measure = 'Dry'
             THEN  nvl(grd.landed_net_qty,0)
             ELSE  nvl(grd.landed_net_qty,0) * (1 - (nvl(vdc.typical, 1) / 100))
        END))/  sum(CASE WHEN pcpq.unit_of_measure = 'Dry'
             THEN nvl(grd.shipped_net_qty,0)
             ELSE nvl(grd.shipped_net_qty,0)
                 *(1 - (nvl(vdc.typical, 1) / 100))
        END)
        end)  dry_ratio
  from gmr_goods_movement_record    gmr,
       ak_corporate                 akc,
       grd_goods_record_detail      grd,
       gcd_groupcorporatedetails    gcd,
       pcpd_pc_product_definition   pcpd,
       cpc_corporate_profit_center  cpc,
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
       pcm_physical_contract_main   pcm,
       is_invoice_summary           iis,
       css_corporate_strategy_setup css,
       pcdi_pc_delivery_item        pcdi,
       pci_physical_contract_item   pci,
       pcpq_pc_product_quality      pcpq,
       phd_profileheaderdetails     phd,
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
       v_deductible_value_by_ash_id vdc,
       sam_stock_assay_mapping sam
 where gmr.corporate_id = akc.corporate_id
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and akc.groupid = gcd.groupid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.profit_center_id = cpc.profit_center_id
   and gmr.internal_gmr_ref_no = gmr_gd.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and gmr.gmr_latest_action_action_id = agmr.gmr_latest_action_action_id
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = iis.internal_contract_ref_no(+)
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pci.pcpq_id = pcpq.pcpq_id
   and pcm.cp_id = phd.profileid
   and gmr.internal_gmr_ref_no = wrd.internal_gmr_ref_no(+)
   and wrd.shed_id = sld.storage_loc_id(+)
   and sld.state_id = sm_sld.state_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and sld.country_id = cym_sld.country_id(+)
   and pcpd.product_id = pdm.product_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpd.qty_unit_id = qum.qty_unit_id
   and gmr.loading_state_id = sm_load.state_id(+)
   and gmr.loading_city_id = cim_load.city_id(+)
   and gmr.loading_country_id = cym_load.country_id(+)
   and gmr.discharge_state_id = sm_discharge.state_id(+)
   and gmr.discharge_city_id = cim_discharge.city_id(+)
   and gmr.discharge_country_id = cym_discharge.country_id(+)
  -- and grd.internal_grd_ref_no = ash.internal_grd_ref_no(+)
   and grd.internal_grd_ref_no=sam.internal_grd_ref_no(+)
   and sam.ash_id=ash.ash_id(+)
   and ash.ash_id = vdc.ash_id(+)
  -- and ash.ash_id = sam.ash_id(+)
   and nvl(ash.is_active,'Y') = 'Y'
   and grd.is_afloat = 'N'
   and gmr.is_deleted = 'N'
   and gmr.is_internal_movement = 'N'
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and pcpq.is_active = 'Y'
   and phd.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and gcd.is_active = 'Y'
   and sam.is_latest_pricing_assay = 'Y'
group by
         gcd.groupid,
         gcd.groupname ,
         gmr.corporate_id,
          akc.corporate_name,
          pcpd.profit_center_id,
          cpc.profit_center_name,
          cpc.profit_center_short_name,
          css.strategy_id,
          css.strategy_name,
          pdm.product_id,
          pdm.product_desc,
          qat.quality_id,
          qat.quality_name,
          gmr.contract_type,
          phd.companyname ,
          pcm.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.gmr_latest_action_action_id,
          gmr.bl_date ,
          agmr.eff_date ,
          wrd.activity_ref_no ,
          iis.invoice_type_name ,
           gmr_gd.mode_of_transport,
          agmr.bl_no ,
          gmr.vessel_name,
          cim_load.city_id ,
          cim_load.city_name ,
          sm_load.state_id ,
          sm_load.state_name ,
          cym_load.country_id ,
          cym_load.country_name ,
          cim_discharge.city_id ,
          cim_discharge.city_name ,
          sm_discharge.state_id ,
          sm_discharge.state_name ,
          cym_discharge.country_id ,
          cym_discharge.country_name ,
          sld.storage_loc_id ,
          sld.storage_location_name ,
          sld.country_id ,
          cym_sld.country_name ,
          sld.state_id ,
          sm_sld.state_name ,
          sld.city_id ,
          cim_sld.city_name ,
          ash.assay_type ,
          qum.qty_unit ,
          pcpq.unit_of_measure,
          vdc.typical,
          qum.qty_unit ,
          gmr.landed_qty

