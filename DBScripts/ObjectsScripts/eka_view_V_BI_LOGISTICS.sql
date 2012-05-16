CREATE OR REPLACE VIEW V_BI_LOGISTICS as
with v_ash as(select ash.ash_id,
       sum(asm.net_weight) wet_weight,
       sum(asm.dry_weight)dry_weight
  from ash_assay_header         ash,
       asm_assay_sublot_mapping asm
 where ash.ash_id = asm.ash_id
   and ash.is_active = 'Y'
   and asm.is_active = 'Y'
 group by ash.ash_id)
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
       ash.assay_type assay_status,
       qum.qty_unit bl_product_base_uom,
       sum(nvl(grd.total_qty, 0)) bl_wet_weight,
       sum(case
             when pcpq.unit_of_measure = 'Wet' then
              pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                      sam.ash_id,
                                                      nvl(grd.total_qty, 0),
                                                      grd.qty_unit_id)
             else
              nvl(grd.total_qty, 0)
           end) bl_dry_weight,
       qum.qty_unit actual_product_base_uom,
       sum(asm.wet_weight) actual_wet_weight,
       sum(asm.dry_weight) actual_dry_weight,
       (sum(case
              when pcpq.unit_of_measure = 'Wet' then
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                       sam.ash_id,
                                                       nvl(grd.total_qty,0),
                                                       grd.qty_unit_id)
              else
               nvl(grd.total_qty, 0)
            end) - sum(asm.dry_weight)) dry_qty_diff,
       sum(nvl(grd.total_qty, 0)) - sum(asm.wet_weight) wet_qty_diff,
       (sum(nvl(grd.total_qty, 0)) - sum(asm.wet_weight)) /
       sum(nvl(grd.total_qty, 0)) * 100 wet_ratio,
       (sum(case
              when pcpq.unit_of_measure = 'Wet' then
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                       sam.ash_id,
                                                       nvl(grd.total_qty, 0),
                                                       grd.qty_unit_id)
              else
               nvl(grd.total_qty, 0)
            end) - sum(asm.dry_weight)) /
       sum(case
             when pcpq.unit_of_measure = 'Wet' then
              pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                      sam.ash_id,
                                                      nvl(grd.total_qty, 0),
                                                      grd.qty_unit_id)
             else
              nvl(grd.total_qty, 0)
           end) * 100 dry_ratio
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
       ash_assay_header ash,
       v_ash asm,
       sam_stock_assay_mapping sam,
       axs_action_summary axs
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
   and grd.internal_grd_ref_no = sam.internal_grd_ref_no
   and sam.ash_id = ash.ash_id
   and ash.ash_id = asm.ash_id   
   and nvl(ash.is_active, 'Y') = 'Y'
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
   and pcpd.input_output = 'Input'
   and grd.status = 'Active'
   and grd.tolling_stock_type = 'None Tolling'
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
          sld.city_id,
          cim_sld.city_name,
          ash.assay_type,
          qum.qty_unit,
          pcpq.unit_of_measure,
          qum.qty_unit
/
