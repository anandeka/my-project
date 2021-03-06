create or replace view v_bi_logistics as
with v_ash as(select ash.internal_gmr_ref_no,
       ash.internal_grd_ref_no,
       sum(asm.net_weight) actual_wet_weight,
       sum(asm.dry_weight) actual_dry_weight
  from ash_assay_header          ash,
       asm_assay_sublot_mapping  asm
 where ash.assay_type = 'Weighing and Sampling Assay'
   and ash.ash_id = asm.ash_id
   and asm.is_active = 'Y'
   and ash.is_active = 'Y'  
 group by ash.internal_gmr_ref_no,
          ash.internal_grd_ref_no), 
 v_agrd_qty as(select ash.internal_gmr_ref_no,
       sum(asm.net_weight) bl_wet_weight,
       sum(asm.dry_weight) bl_dry_weight
  from  ash_assay_header          ash,
       asm_assay_sublot_mapping  asm
 where ash.assay_type = 'Shipment Assay'
   and ash.ash_id = asm.ash_id
   and ash.is_active = 'Y'
   and asm.is_active = 'Y'
 group by ash.internal_gmr_ref_no)
select t.groupid,
       t.corporate_group,
       t.corporate_id,
       t.corporate_name,
       t.profit_center_id,
       t.profit_center_name,
       t.profit_center_short_name,
       t.strategy_id,
       t.strategy_name,
       t.product_id,
       t.product_desc,
       t.quality_id,
       t.quality_name,
       t.contract_type,
       t.counterparty,
       t.contract_ref_no,
       t.delivery_item_ref_no,
       t.internal_contract_item_ref_no,
       t.gmr_ref_no,
       t.gmr_type,
       t.shipment_activity_date,
       t.landing_activity_date,
       t.arrival_no,
       t.invoice_status,
       t.mode_of_transport,
       t.trip_vehicle,
       t.vessel_name,
       t.loading_city_id,
       t.loading_city_name,
       t.loading_state_id,
       t.loading_state_name,
       t.loading_country_id,
       t.loading_country_name,
       t.discharge_city_id,
       t.discharge_city_name,
       t.discharge_state_id,
       t.discharge_state_name,
       t.discharge_country_id,
       t.discharge_country_name,
       t.warehouse_location_id,
       t.warehouse_location,
       t.warehouse_country_id,
       t.warehouse_country_name,
       t.warehouse_state_id,
       t.warehouse_state_name,
       t.warehouse_city_id,
       t.warehouse_city_name,
       --t.assay_status,
       t.bl_product_base_uom,      
       t.bl_wet_weight,
       t.bl_dry_weight,
       t.actual_product_base_uom,
       t.actual_wet_weight,
       t.actual_dry_weight,
       (t.actual_wet_weight- t.bl_wet_weight) wet_qty_diff,
       (t.actual_dry_weight-t.bl_dry_weight) dry_qty_diff,
       ((t.actual_wet_weight- t.bl_wet_weight)/ t.bl_wet_weight)*100 wet_ratio,
       ((t.actual_dry_weight- t.bl_dry_weight)/ t.actual_wet_weight)*100 dry_ratio   
  from (select gcd.groupid,               
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
               pcm.contract_ref_no || '-' ||
               substr(pci.del_distribution_item_no, 1, 1) internal_contract_item_ref_no,
               gmr.gmr_ref_no,
               (case
                 when gmr.gmr_latest_action_action_id = 'landingDetail' then
                  'Landed'
                 when gmr.gmr_latest_action_action_id = 'shipmentDetail' then
                  'Shipped'
                 else
                  ''
               end) gmr_type,
               axs.eff_date shipment_activity_date,
               agmr.eff_date landing_activity_date,
               wrd.activity_ref_no arrival_no,
               iss.invoice_type_name invoice_status,
               gmr.mode_of_transport,
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
               --ash.assay_type assay_status,
               qum.qty_unit bl_product_base_uom,
               agrd.bl_wet_weight bl_wet_weight,
               agrd.bl_dry_weight bl_dry_weight,
               qum.qty_unit actual_product_base_uom,               
               (case when gmr.wns_status='Completed' then
                sum(asm.actual_wet_weight)
                else
                null
                end) actual_wet_weight,
                 (case when gmr.wns_status='Completed' then
                sum(asm.actual_dry_weight)
                else
                null
                end) actual_dry_weight
          from gmr_goods_movement_record gmr,
               ak_corporate akc,
               grd_goods_record_detail grd,
               gcd_groupcorporatedetails gcd,
               pcpd_pc_product_definition pcpd,
               cpc_corporate_profit_center cpc,
               (select gmr.internal_gmr_ref_no,
                       agmr.eff_date,
                       agmr.bl_no
                  from gmr_goods_movement_record gmr,
                       agmr_action_gmr           agmr
                 where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                   and agmr.gmr_latest_action_action_id = 'landingDetail'
                   and agmr.is_deleted = 'N') agmr,
               pcm_physical_contract_main pcm,
               v_bi_latest_gmr_invoice iis,
               is_invoice_summary iss,
               css_corporate_strategy_setup css,
               pcdi_pc_delivery_item pcdi,
               pci_physical_contract_item pci,
               pcpq_pc_product_quality pcpq,
               phd_profileheaderdetails phd,
               (select wrd.internal_gmr_ref_no,
                       wrd.activity_ref_no,
                       wrd.shed_id
                  from wrd_warehouse_receipt_detail wrd
                 where (wrd.internal_gmr_ref_no, wrd.action_no) in
                       (select wrd.internal_gmr_ref_no,
                               max(action_no)
                          from wrd_warehouse_receipt_detail wrd
                         group by wrd.internal_gmr_ref_no)) wrd,
               sld_storage_location_detail sld,
               sm_state_master sm_sld,
               cim_citymaster cim_sld,
               cym_countrymaster cym_sld,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               qum_quantity_unit_master qum,
               sm_state_master sm_load,
               cim_citymaster cim_load,
               cym_countrymaster cym_load,
               sm_state_master sm_discharge,
               cim_citymaster cim_discharge,
               cym_countrymaster cym_discharge,         
               v_ash asm,            
               axs_action_summary axs,           
               v_agrd_qty agrd
         where gmr.corporate_id = akc.corporate_id
           and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
           and akc.groupid = gcd.groupid
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
           and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and gmr.internal_gmr_ref_no = iis.internal_gmr_ref_no(+)
           and iis.internal_invoice_ref_no = iss.internal_invoice_ref_no(+)
           and pcpd.strategy_id = css.strategy_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
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
           and grd.internal_gmr_ref_no=asm.internal_gmr_ref_no(+)
           and grd.internal_grd_ref_no=asm.internal_grd_ref_no(+)
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
           and pcpd.input_output = 'Input'
           and grd.status = 'Active'
           and gmr.internal_gmr_ref_no=agrd.internal_gmr_ref_no 
           and grd.tolling_stock_type in('None Tolling','Clone Stock')
         group by gcd.groupid,
                  gcd.groupname,
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
                  phd.companyname,
                  pcm.contract_ref_no,
                  pci.del_distribution_item_no,
                  gmr.gmr_ref_no,
                  gmr.gmr_latest_action_action_id,
                  axs.eff_date,
                  agmr.eff_date,
                  wrd.activity_ref_no,
                  iss.invoice_type_name,
                  gmr.mode_of_transport,
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
                  agrd.bl_wet_weight,
                  agrd.bl_dry_weight,
                  sld.city_id,              
                  cim_sld.city_name, 
                  gmr.wns_status,
                  qum.qty_unit,
                  pcpq.unit_of_measure,
                  qum.qty_unit
        union all -- sales 
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
               pcm.contract_ref_no || '-' ||
               substr(pci.del_distribution_item_no, 1, 1) internal_contract_item_ref_no,
               gmr.gmr_ref_no,
               (case
                 when gmr.gmr_latest_action_action_id = 'salesLandingDetail' then
                  'Landed'
                 when gmr.gmr_latest_action_action_id = 'shipmentAdvise' then
                  'Shipped'
                 else
                  ''
               end) gmr_type,
               axs.eff_date shipment_activity_date,
               agmr.eff_date landing_activity_date,
               wrd.activity_ref_no arrival_no,
               iss.invoice_type_name invoice_status,
               gmr.mode_of_transport,
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
               --ash.assay_type assay_status,
               qum.qty_unit bl_product_base_uom,
               agrd.bl_wet_weight bl_wet_weight,
               agrd.bl_dry_weight bl_dry_weight,
               qum.qty_unit actual_product_base_uom,
               (case
                 when gmr.wns_status = 'Completed' then
                  sum(asm.actual_wet_weight)
                 else
                  null
               end) actual_wet_weight,
               (case
                 when gmr.wns_status = 'Completed' then
                  sum(asm.actual_dry_weight)
                 else
                  null
               end) actual_dry_weight
          from gmr_goods_movement_record gmr,
               ak_corporate akc,
               dgrd_delivered_grd dgrd,
               gcd_groupcorporatedetails gcd,
               pcpd_pc_product_definition pcpd,
               cpc_corporate_profit_center cpc,
               (select gmr.internal_gmr_ref_no,
                       agmr.eff_date,
                       agmr.bl_no
                  from gmr_goods_movement_record gmr,
                       agmr_action_gmr           agmr
                 where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                   and agmr.gmr_latest_action_action_id = 'salesLandingDetail'
                   and agmr.is_deleted = 'N') agmr,
               pcm_physical_contract_main pcm,
               v_bi_latest_gmr_invoice iis,
               is_invoice_summary iss,
               css_corporate_strategy_setup css,
               pcdi_pc_delivery_item pcdi,
               pci_physical_contract_item pci,
               pcpq_pc_product_quality pcpq,
               phd_profileheaderdetails phd,
               (select wrd.internal_gmr_ref_no,
                       wrd.activity_ref_no,
                       wrd.shed_id
                  from wrd_warehouse_receipt_detail wrd
                 where (wrd.internal_gmr_ref_no, wrd.action_no) in
                       (select wrd.internal_gmr_ref_no,
                               max(action_no)
                          from wrd_warehouse_receipt_detail wrd
                         group by wrd.internal_gmr_ref_no)) wrd,
               sld_storage_location_detail sld,
               sm_state_master sm_sld,
               cim_citymaster cim_sld,
               cym_countrymaster cym_sld,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               qum_quantity_unit_master qum,
               sm_state_master sm_load,
               cim_citymaster cim_load,
               cym_countrymaster cym_load,
               sm_state_master sm_discharge,
               cim_citymaster cim_discharge,
               cym_countrymaster cym_discharge,
               v_ash asm,
               axs_action_summary axs,
               v_agrd_qty agrd
         where gmr.corporate_id = akc.corporate_id
           and gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
           and akc.groupid = gcd.groupid
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
           and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
           and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
           and gmr.internal_gmr_ref_no = iis.internal_gmr_ref_no(+)
           and iis.internal_invoice_ref_no = iss.internal_invoice_ref_no(+)
           and pcpd.strategy_id = css.strategy_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and dgrd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
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
           and dgrd.internal_gmr_ref_no = asm.internal_gmr_ref_no(+)
           and dgrd.internal_grd_ref_no = asm.internal_grd_ref_no(+)
           and dgrd.is_afloat = 'N'
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
           and pcpd.input_output = 'Input'
           and dgrd.status = 'Active'
           and gmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
           and dgrd.tolling_stock_type = 'None Tolling'
         group by gcd.groupid,
                  gcd.groupname,
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
                  phd.companyname,
                  pcm.contract_ref_no,
                  pci.del_distribution_item_no,
                  gmr.gmr_ref_no,
                  gmr.gmr_latest_action_action_id,
                  axs.eff_date,
                  agmr.eff_date,
                  wrd.activity_ref_no,
                  iss.invoice_type_name,
                  gmr.mode_of_transport,
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
                  agrd.bl_wet_weight,
                  agrd.bl_dry_weight,
                  sld.city_id,
                  cim_sld.city_name,
                  gmr.wns_status,
                  qum.qty_unit,
                  pcpq.unit_of_measure,
                  qum.qty_unit) t
/ 
