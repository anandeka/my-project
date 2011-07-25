CREATE OR REPLACE VIEW V_LIST_OF_GMR AS
SELECT gmr.corporate_id,
       (SELECT f_string_aggregate(pci.contract_ref_no)
        FROM   gcim_gmr_contract_item_mapping gcim,
               v_pci                          pci
        WHERE  gam.internal_gmr_ref_no = gcim.internal_gmr_ref_no
        AND    gcim.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no) contract_ref_no,
       gmr.trucking_receipt_no trucking_receipt_no,
       gmr.rail_receipt_no rail_receipt_no,
       to_char(gmr.trucking_receipt_date,
               'dd-Mon-yyyy') trucking_receipt_date,
       to_char(gmr.rail_receipt_date,
               'dd-Mon-yyyy') rail_receipt_date,
       axs.action_id,
       gmr.is_voyage_gmr,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       gam.action_no,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no activity_ref_no,
       gmr.warehouse_receipt_no warehouse_receipt_no,
       cim_origin.city_name origin_city,
       cim_origin.city_id origin_city_id,
       cym_origin.country_name origin_country,
       cym_origin.country_id origin_country_id,
       cim_des.city_name des_city,
       cym_des.country_name des_country,
       gmr.warehouse_profile_id warehouse_profile_id,
       phd_warehouse.companyname warehouse,
       sld.storage_location_name shed_name,
       (SELECT f_string_aggregate(pci.product_specs)
        FROM   gcim_gmr_contract_item_mapping gcim,
               v_pci                          pci
        WHERE  gcim.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND    gcim.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no) productspec,
       nvl(nvl(gmr.current_qty,
               0) - nvl(moved_out_qty,
                        0) - nvl(gmr.write_off_qty,
                                 0),
           0) current_qty,
       gmr.qty_unit_id,
       qum.qty_unit,
       gmr.current_no_of_units,
       gmr.status_id,
       gsm.status status,
       gmr.inventory_status is_title_transfered,
       '' accrual_amt,
       '' accrual_currency,
       (SELECT vcd.vessel_name
        FROM   vcd_vessel_creation_detail vcd
        WHERE  vcd.vessel_id = vd.vessel_id) vessel_name,
       gam.delivered_pieces no_of_pieces,
       gam.release_ref_no release_no,
       gmr.gmr_latest_action_action_id latest_action_id,
       (SELECT axm.action_name
        FROM   axm_action_master axm
        WHERE  axm.action_id = gmr.gmr_latest_action_action_id) latest_action_name,
       cim_des.city_id des_city_id,
       cym_des.country_id des_country_id,
       (CASE
           WHEN gmr.is_voyage_gmr = 'Y' THEN
            'Create Vessel Fixation'
           ELSE
            axm.action_name
       END) first_action_name,
       axs.action_ref_no,
       cym_loading.country_name loading_country,
       pmt_loading.port_name loading_port,
       cym_discharge.country_name discharge_country,
       cym_discharge.country_id discharge_country_id,
       pmt_discharge.port_name discharge_port,
       pmt_discharge.port_id discharge_port_id,
       pmt_trans.port_name trans_port_name,
       cym_trans.country_name trans_country_name,
       phd_shipping_line.companyname shipping_line,
       phd_shipping_line.profileid shipping_line_profile_id,
       phd_controller.companyname controller,
       gmr.is_internal_movement,
       (CASE
           WHEN gmr.contract_type = 'Purchase' THEN
            'P'
           WHEN gmr.contract_type = 'Sales' THEN
            'S'
           ELSE
            ''
       END) contract_type,
       cp.contract_party_profile_id cp_profile_id,
       cp.cp_name,
       to_number(substr(gmr.gmr_ref_no,
                        5,
                        (instr(gmr.gmr_ref_no,
                               '-',
                               1,
                               2) - instr(gmr.gmr_ref_no,
                                           '-',
                                           1,
                                           1) - 1))) gmr_middle_no,
       (SELECT f_string_aggregate(pcm.middle_no)
        FROM   gcim_gmr_contract_item_mapping gcim,
               v_pci                          pci,
               pcm_physical_contract_main     pcm
        WHERE  gam.internal_gmr_ref_no = gcim.internal_gmr_ref_no
        AND    gcim.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
        AND    pci.internal_contract_ref_no = pcm.internal_contract_ref_no) conc_middle_no,
       (SELECT f_string_aggregate(pci.internal_contract_item_ref_no)
        FROM   gcim_gmr_contract_item_mapping gcim,
               v_pci                          pci
        WHERE  gam.internal_gmr_ref_no = gcim.internal_gmr_ref_no
        AND    gcim.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no) internal_contract_item_ref_nos,
       (SELECT f_string_aggregate(pci.contract_item_ref_no)
        FROM   gcim_gmr_contract_item_mapping gcim,
               v_pci                          pci
        WHERE  gam.internal_gmr_ref_no = gcim.internal_gmr_ref_no
        AND    gcim.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no) item_nos,
       nvl(gmr.tt_under_cma_qty,
           0) tt_under_cma_qty,
       nvl(gmr.tt_in_qty,
           0) tt_in_qty,
       nvl(gmr.tt_out_qty,
           0) tt_out_qty,
       nvl(gmr.tt_none_qty,
           0) tt_none_qty,
       vd.vessel_voyage_name,
       vd.booking_ref_no,
       gmr.internal_contract_ref_no,
       bl_details.bl_no bl_no,
       bl_details.bl_date bl_date
FROM   gmr_goods_movement_record gmr,
       gam_gmr_action_mapping gam,
       axs_action_summary axs,
       cim_citymaster cim_origin,
       cym_countrymaster cym_origin,
       cim_citymaster cim_des,
       cym_countrymaster cym_des,
       gsm_gmr_stauts_master gsm,
       qum_quantity_unit_master qum,
       axm_action_master axm,
       pmt_portmaster pmt_loading,
       cym_countrymaster cym_loading,
       pmt_portmaster pmt_discharge,
       cym_countrymaster cym_discharge,
       pmt_portmaster pmt_trans,
       cym_countrymaster cym_trans,
       phd_profileheaderdetails phd_shipping_line,
       phd_profileheaderdetails phd_controller,
       phd_profileheaderdetails phd_warehouse,
       sld_storage_location_detail sld,
       vd_voyage_detail vd,
       (SELECT f_string_aggregate(pci.internal_contract_ref_no) internal_contract_ref_no,
               f_string_aggregate(gcim.internal_gmr_ref_no) internal_gmr_ref_no,
               f_string_aggregate(pci.cp_id) contract_party_profile_id,
               f_string_aggregate(pci.cp_name) AS cp_name
        FROM   v_pci                          pci,
               gcim_gmr_contract_item_mapping gcim
        WHERE  pci.internal_contract_item_ref_no =
               gcim.internal_contract_item_ref_no
        GROUP  BY gcim.internal_gmr_ref_no) cp,
       (SELECT sd.internal_gmr_ref_no,
               sd.bl_no bl_no,
               sd.bl_date bl_date
        FROM   sd_shipment_detail sd) bl_details
WHERE  gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
AND    gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
AND    axs.internal_action_ref_no(+) = gam.internal_action_ref_no
AND    axs.status(+) = 'Active'
AND    axm.action_id(+) = axs.action_id
AND    gmr.is_deleted = 'N'
AND    gmr.status_id = gsm.status_id
AND    gmr.qty_unit_id = qum.qty_unit_id
AND    gmr.origin_city_id = cim_origin.city_id(+)
AND    cim_origin.country_id = cym_origin.country_id(+)
AND    gmr.destination_city_id = cim_des.city_id(+)
AND    cim_des.country_id = cym_des.country_id(+)
AND    gmr.loading_port_id = pmt_loading.port_id(+)
AND    gmr.loading_country_id = cym_loading.country_id(+)
AND    gmr.discharge_port_id = pmt_discharge.port_id(+)
AND    gmr.discharge_country_id = cym_discharge.country_id(+)
AND    gmr.trans_port_id = pmt_trans.port_id(+)
AND    gmr.trans_country_id = cym_trans.country_id(+)
AND    gmr.shipping_line_profile_id = phd_shipping_line.profileid(+)
AND    gmr.controller_profile_id = phd_controller.profileid(+)
AND    gmr.warehouse_profile_id = phd_warehouse.profileid(+)
AND    gmr.shed_id = sld.storage_loc_id(+)
AND    gmr.internal_gmr_ref_no = cp.internal_gmr_ref_no(+)
AND    gmr.internal_gmr_ref_no = bl_details.internal_gmr_ref_no(+)
AND    nvl(gmr.is_settlement_gmr,
           'N') = 'N'
AND    nvl(gmr.tolling_gmr_type,
           'None Tolling') NOT IN ('Input Process', 'Output Process')
AND    gam.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
AND    vd.status(+) = 'Active';