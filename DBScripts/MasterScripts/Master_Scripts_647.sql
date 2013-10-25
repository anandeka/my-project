DECLARE
   fetchquerysddfor_truckdetail     CLOB
      := 'INSERT INTO sdd_d
            (attention, buyer, contract_date, contract_item_no, contract_qty,
             contract_qty_unit, contract_ref_no, cp_ref_no,
             destination_location, discharge_country, discharge_port, eta_end,
             eta_start, fulfilment_type, goods, inco_terms,
             internal_contract_item_ref_no, internal_doc_ref_no,
             internal_gmr_ref_no, is_other_optional_ports, issue_date,
             loading_country, loading_location, loading_port,
             other_shipment_terms, packing_type, qty_of_goods,
             qty_of_goods_unit, seller, tolerance_level, tolerance_unit,
             tolerance_max, tolerance_min, tolerance_type, vessel_name,
             bl_date, bl_number, bl_quantity, bl_quantity_unit,
             optional_destin_ports, optional_origin_ports, created_date,
             parity_location, productandquality, notifyparity, shipper, notes,
             specialinstructions, voyagenumber, shipperrefno,
             transshipmentport, etadestinationport, shippersinstructions,
             carrieragentsendorsements, wholenewreport, container_nos,
             quantity, quantity_unit, quantity_decimals, net_weignt_gmr,
             net_weight_unit_gmr, decimals, bldate_blno, bl_quantity_decimals,
             activity_date, flight_number, destination_airport, awb_date,
             awb_number, awb_quantity, loading_airport, loading_date,
             endorsements, other_airway_billing_item, no_of_pieces,
             nature_of_good, dimensions, stock_ref_no, net_weight,
             tare_weight, gross_weight, commodity_description, comments,
             activity_ref_no, weigher, weigher_note_no, weighing_date,
             remarks, rail_name_number, rr_date, rr_number, total_qty, rr_qty,
             truck_number, cmr_date, cmr_number, cmr_quantity,
             other_trucking_terms, trucking_instructions, loading_state,
             destination_state, trans_shipment_country, trans_shipment_state,
             supp_rep, mode_of_transport)
   SELECT '''', akc.corporate_name buyer, TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') contractdate,
          (SELECT f_string_aggregate (pci.contract_item_ref_no)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                            agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') contractitemno,
          f_format_to_char (pcpd.qty_max_val, 4) contractqty,
          qum.qty_unit contractqtyunit, pcm.contract_ref_no contractrefno,
          pcm.cp_contract_ref_no, cym.country_name destination_location,
          cym.country_name dischargecountry, cim.city_name, TO_CHAR (vd.etd, ''dd-Mon-yyyy'') etaend,
          TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etastart, '''', '''',
          (SELECT f_string_aggregate (pci.incoterm)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                                  agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') incoterm,
          (SELECT f_string_aggregate
                     (pci.internal_contract_item_ref_no
                     )
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                                            agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') internalcontractitemrefno,
          ?, gmr.internal_gmr_ref_no internalgmrrefno, '''',
          TO_CHAR (sd.bl_date, ''dd-Mon-yyyy'') issue_date,
          cyml.country_name loadingcountry,
          cyml.country_name loading_location, cim_load.city_name loadingport,
          sd.internal_remarks other_shipment_terms, '''' packing_type,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                            (agrd.product_id,
                                                             agrd.qty_unit_id,
                                                             gmr.qty_unit_id,
                                                             agrd.qty
                                                            )
                         )
                 FROM agrd_action_grd agrd
                WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND agrd.action_no = agmr.action_no
                  AND agrd.is_deleted = ''N''),
              4
             ) qty_of_goods,
          qumbl.qty_unit, phd.companyname seller, '''',
          NVL (pcpd.tolerance_unit_id, ''%'') tolerance_unit,
          NVL (pcpd.max_tolerance, 0) tolerance_max,
          NVL (pcpd.min_tolerance, 0) tolerance_min,
          NVL (pcpd.tolerance_type, ''Approx'') tolerance_type,
          vd.vessel_voyage_name vesselname, TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'') bldate,
          gmr.bl_no blnumber, f_format_to_char (gmr.qty, 4) blqty,
          qumbl.qty_unit blqtyunit, '''', '''', TO_CHAR (gmr.created_date, ''dd-Mon-yyyy'') createddate,
          (SELECT f_string_aggregate (pci.incoterm_location)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                           agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') parity_location,
          (SELECT f_string_aggregate (   pdm.product_desc
                                      || '' , ''
                                      || qat.quality_name
                                     )
             FROM pdm_productmaster pdm,
                  qat_quality_attributes qat,
                  agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N''
              AND pdm.product_id = agrd.product_id
              AND qat.quality_id = agrd.quality_id) productandquality,
          phdnp.companyname notifyparty, phd_ship.companyname shipper,
          vd.notes notes, vd.special_instructions specialinst,
          vd.voyage_number voyagenumber, vd.shippers_ref_no shipperrefno,
          cim_trans.city_name transport,
          TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etadestinationport,
          vd.shippers_instructions shippersinstructions,
          vd.carriers_agents_endorsements carrieragentsendorsements, '''',
          (SELECT f_string_aggregate (agrd.container_no)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                       agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') container_nos,
          f_format_to_char (gmr.qty, 4) quantity,
          qum_gmr.qty_unit quantity_unit, qum_gmr.decimals quantity_decimals,
          f_format_to_char (gmr.current_qty, 4) net_weignt_gmr,
          qum_gmr.qty_unit net_weight_unit_gmr, qum_gmr.decimals decimals,
          ((TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'')) || '' '' || gmr.bl_no
          ) bldate_blno,
          qum_gmr.decimals bl_quantity_decimals,
          TO_CHAR (axs.action_date, ''dd-Mon-yyyy'') activity_date,
          vd.voyage_number flight_number,
          cym_vd.country_name destination_airport,
          TO_CHAR (sd.bl_date, ''dd-Mon-yyyy'') awb_date, sd.bl_no awb_number,
          f_format_to_char (gmr.qty, 4) awb_quantity,
          cym_vdl.country_name loading_airport, TO_CHAR (vd.loading_date, ''dd-Mon-yyyy'') loading_date,
          '''', '''', vd.no_of_pieces no_of_pieces,
          vd.nature_of_goods nature_of_good, vd.dimensions dimensions,
          (SELECT f_string_aggregate (grd.internal_stock_ref_no)
             FROM grd_goods_record_detail grd
            WHERE grd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no)
                                                                 stock_ref_no,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                            (agrd.product_id,
                                                             agrd.qty_unit_id,
                                                             qum.qty_unit_id,
                                                             agrd.qty
                                                            )
                         )
                 FROM agrd_action_grd agrd
                WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND agrd.status = ''Active''
                  AND agrd.action_no = agmr.action_no),
              4
             ) net_weight,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                            (agrd.product_id,
                                                             agrd.qty_unit_id,
                                                             qum.qty_unit_id,
                                                             agrd.tare_weight
                                                            )
                         )
                 FROM agrd_action_grd agrd
                WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND agrd.status = ''Active''
                  AND agrd.action_no = agmr.action_no),
              4
             ) tare_weight,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                            (agrd.product_id,
                                                             agrd.qty_unit_id,
                                                             qum.qty_unit_id,
                                                             agrd.gross_weight
                                                            )
                         )
                 FROM agrd_action_grd agrd
                WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND agrd.status = ''Active''
                  AND agrd.action_no = agmr.action_no),
              4
             ) gross_weight,
          (SELECT f_string_aggregate (agrd.remarks)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                               agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') commodity_description,
          vd.comments comments, '''', '''', '''', '''', '''',
          (vd.vessel_voyage_name || '' '' || vd.voyage_number
          ) rail_name_number, TO_CHAR (sd.bl_date, ''dd-Mon-yyyy'') rr_date,
          sd.bl_no rr_number, f_format_to_char (gmr.qty, 4) total_qty,
          f_format_to_char (gmr.qty, 4) rr_qty,
          vd.shippers_ref_no truck_number, TO_CHAR (sd.bl_date, ''dd-Mon-yyyy'') cmr_date,
          sd.bl_no cmr_number, f_format_to_char (gmr.qty, 4) cmr_quantity,
          sd.internal_remarks other_trucking_terms,
          vd.shippers_instructions trucking_instructions,
          sm_load.state_name loading_state,
          sm_dis.state_name destination_state,
          cym_tran.country_name trans_shipment_country,
          sm_tran.state_name trans_shipment_state,
          phd_supp.companyname supp_rep, gmr.mode_of_transport
     FROM gmr_goods_movement_record gmr,
          ak_corporate akc,
          agmr_action_gmr agmr,
          sd_shipment_detail sd,
          pcm_physical_contract_main pcm,
          phd_profileheaderdetails phd,
          phd_profileheaderdetails phd_ship,
          phd_profileheaderdetails phd_seller,
          vd_voyage_detail vd,
          pcpd_pc_product_definition pcpd,
          qum_quantity_unit_master qum,
          qum_quantity_unit_master qum_gmr,
          qum_quantity_unit_master qumbl,
          cym_countrymaster cym,
          cym_countrymaster cyml,
          axs_action_summary axs,
          phd_profileheaderdetails phdnp,
          phd_profileheaderdetails phd_supp,
          cim_citymaster cim_trans,
          cim_citymaster cim_load,
          cim_citymaster cim,
          cym_countrymaster cym_vd,
          cym_countrymaster cym_vdl,
          sm_state_master sm_load,
          sm_state_master sm_dis,
          sm_state_master sm_tran,
          cym_countrymaster cym_tran
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.gmr_latest_action_action_id IN
                 (''shipmentDetail'', ''airDetail'', ''truckDetail'', ''railDetail'')
      AND agmr.is_deleted = ''N''
      AND akc.corporate_id = gmr.corporate_id
      AND sd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND sd.action_no = agmr.action_no
      AND vd.internal_gmr_ref_no = sd.internal_gmr_ref_no
      AND vd.action_no = sd.action_no
      AND agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcm.cp_id = phd.profileid
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.qty_unit_id = qum.qty_unit_id
      AND gmr.discharge_country_id = cym.country_id
      AND gmr.loading_country_id = cyml.country_id
      AND gmr.qty_unit_id = qumbl.qty_unit_id
      AND gmr.internal_action_ref_no = axs.internal_action_ref_no
      AND sd.notify_party_id = phdnp.profileid(+)
      AND sd.supp_rep_id = phd_supp.profileid(+)
      AND sd.consignee_id = phd_seller.profileid(+)
      AND vd.trans_shipment_city_id = cim_trans.city_id(+)
      AND vd.loading_city_id = cim_load.city_id(+)
      AND vd.discharge_city_id = cim.city_id(+)
      AND vd.discharge_country_id = cym_vd.country_id(+)
      AND vd.loading_country_id = cym_vdl.country_id(+)
      AND vd.loading_state_id = sm_load.state_id(+)
      AND vd.discharge_state_id = sm_dis.state_id(+)
      AND vd.trans_shipment_state_id = sm_tran.state_id(+)
      AND vd.trans_shipment_country_id = cym_tran.country_id(+)
      AND gmr.shipping_line_profile_id = phd_ship.profileid
      AND gmr.qty_unit_id = qum_gmr.qty_unit_id
      AND gmr.internal_gmr_ref_no = ?';
   fetchquerysddfor_whreceipt       CLOB
      := 'INSERT INTO sdd_d
            (attention, buyer, contract_date, contract_item_no, contract_qty,
             contract_qty_unit, contract_ref_no, cp_ref_no,
             destination_location, discharge_country, discharge_port, eta_end,
             eta_start, fulfilment_type, goods, inco_terms,
             internal_contract_item_ref_no, internal_doc_ref_no,
             internal_gmr_ref_no, is_other_optional_ports, issue_date,
             loading_country, loading_location, loading_port,
             other_shipment_terms, packing_type, qty_of_goods,
             qty_of_goods_unit, seller, tolerance_level, tolerance_max,
             tolerance_min, tolerance_type, vessel_name, bl_date, bl_number,
             bl_quantity, bl_quantity_unit, optional_destin_ports,
             optional_origin_ports, created_date, parity_location,
             productandquality, notifyparity, shipper, notes,
             specialinstructions, voyagenumber, shipperrefno,
             transshipmentport, etadestinationport, shippersinstructions,
             carrieragentsendorsements, wholenewreport, container_nos,
             quantity, quantity_unit, quantity_decimals, net_weignt_gmr,
             net_weight_unit_gmr, decimals, bldate_blno, bl_quantity_decimals,
             activity_date, flight_number, destination_airport, awb_date,
             awb_number, awb_quantity, loading_airport, loading_date,
             endorsements, other_airway_billing_item, no_of_pieces,
             nature_of_good, dimensions, stock_ref_no, net_weight,
             tare_weight, gross_weight, commodity_description, comments,
             activity_ref_no, weigher, weigher_note_no, weighing_date,
             remarks, rail_name_number, rr_date, rr_number, total_qty, rr_qty,
             truck_number, cmr_date, cmr_number, cmr_quantity,
             other_trucking_terms, trucking_instructions, cp_address,
             cp_location, issuer, issuer_ref_no, issuer_address, consignee,
             consignee_ref_no, consignee_address, warehouse_and_shed,
             warehouse_address, MOVEMENT, supp_rep, mode_of_transport)
   SELECT '''' attention, akc.corporate_name buyer, TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') contractdate,
          (SELECT f_string_aggregate (pci.contract_item_ref_no)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                            agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') contractitemno,
          pcpd.qty_max_val contractqty, qum.qty_unit contractqtyunit,
          pcm.contract_ref_no contractrefno, pcm.cp_contract_ref_no,
          '''' destination_location, '''' dischargecountry, '''' discharge_port,
          '''' etaend, '''' etastart, '''' fulfilment_type, '''' goods,
          (SELECT f_string_aggregate (pci.incoterm)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                                  agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') incoterm,
          (SELECT f_string_aggregate
                     (pci.internal_contract_item_ref_no
                     )
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                                            agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') internalcontractitemrefno,
          ?, gmr.internal_gmr_ref_no internalgmrrefno,
          '''' is_other_optional_ports, wrd.issue_date issue_date,
          '''' loadingcountry, '''' loading_location, '''' loadingport,
          '''' other_shipment_terms, '''' packing_type,
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity (agrd.product_id,
                                                            agrd.qty_unit_id,
                                                            gmr.qty_unit_id,
                                                            agrd.qty
                                                           )
                     )
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') qty_of_goods,
          qumbl.qty_unit, phdnp.companyname seller, '''' tolerance_level,
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, '''' vesselname,
          TO_CHAR (wrd.storage_date, ''dd-Mon-yyyy'') bldate, gmr.bl_no blnumber, gmr.qty blqty,
          qumbl.qty_unit blqtyunit, '''' optional_destin_ports,
          '''' optional_origin_ports,
          TO_CHAR (gmr.created_date, ''dd-Mon-yyyy'') createddate,
          (SELECT f_string_aggregate (pci.incoterm_location)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                           agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') parity_location,
          (SELECT f_string_aggregate (   pdm.product_desc
                                      || '' , ''
                                      || qat.quality_name
                                     )
             FROM pdm_productmaster pdm,
                  qat_quality_attributes qat,
                  agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N''
              AND pdm.product_id = agrd.product_id
              AND qat.quality_id = agrd.quality_id) productandquality,
          phdnp.companyname notifyparty, '''' shipper, wrd.notes notes,
          wrd.special_instructions specialinst, '''' voyagenumber,
          wrd.senders_ref_no shipperrefno, '''' transport,
          '''' etadestinationport, '''' shippersinstructions,
          '''' carrieragentsendorsements, '''' wholenewreport,
          (SELECT f_string_aggregate (agrd.no_of_containers)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                       agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') container_nos,
          gmr.qty quantity, qum_gmr.qty_unit quantity_unit,
          qum_gmr.decimals quantity_decimals, gmr.current_qty net_weignt_gmr,
          qum_gmr.qty_unit net_weight_unit_gmr, qum_gmr.decimals decimals,
          (   (TO_CHAR (wrd.arrival_date, ''dd-Mon-yyyy''))
           || '' , ''
           || wrd.warehouse_receipt_no
          ) bldate_blno,
          qum_gmr.decimals bl_quantity_decimals,
          TO_CHAR (axs.action_date, ''dd-Mon-yyyy'') activity_date,
          '''' flight_number, '''' destination_airport, '''' awb_date,
          '''' awb_number, gmr.qty awb_quantity, '''' loading_airport,
          '''' loading_date, '''' endorsements, '''' other_airway_billing_item,
          '''' no_of_pieces, '''' nature_of_good, '''' dimensions, '''',
          gmr.qty net_weight, gmr.total_tare_weight tare_weight,
          gmr.total_gross_weight gross_weight, '''' commodity_description,
          wrd.internal_remarks comments, wrd.activity_ref_no activity_ref_no,
          '''' weigher, '''' weigher_note_no, '''' weighing_date, wrd.notes remarks,
          '''' rail_name_number, '''' rr_date, '''' rr_number, gmr.qty total_qty,
          gmr.qty rr_qty, '''' truck_number, '''' cmr_date, '''' cmr_number,
          gmr.qty cmr_quantity, '''' other_trucking_terms,
          '''' trucking_instructions,
          (SELECT MAX (pad.address)
             FROM pad_profile_addresses pad
            WHERE pad.profile_id = pcm.cp_id
              AND pad.address_type = ''Main'') cp_address,
          (SELECT MAX (cim.city_name || '','' || cym.country_name)
             FROM pad_profile_addresses pad,
                  cim_citymaster cim,
                  cym_countrymaster cym
            WHERE pad.profile_id = pcm.cp_id
              AND pad.address_type = ''Main''
              AND pad.city_id = cim.city_id(+)
              AND pad.country_id = cym.country_id(+)) cp_location,
          phdi.companyname issuer, wrd.carriers_ref_no issuerrefno,
          wrd.issuers_address issueraddress, phdc.companyname consignee,
          wrd.consignees_ref_no consigneerefno,
          wrd.consignee_address consigneeaddress,
          shm.companyname || '','' || shm.shed_name warehouseandshed,
          '''' warehouseaddress, wrd.container_service_type MOVEMENT,
          phd_supp.companyname supp_rep, gmr.mode_of_transport
     FROM gmr_goods_movement_record gmr,
          ak_corporate akc,
          wrd_warehouse_receipt_detail wrd,
          agmr_action_gmr agmr,
          axs_action_summary axs,
          phd_profileheaderdetails phd,
          phd_profileheaderdetails phdnp,
          pcm_physical_contract_main pcm,
          pcpd_pc_product_definition pcpd,
          qum_quantity_unit_master qum,
          qum_quantity_unit_master qumbl,
          qum_quantity_unit_master qum_gmr,
          phd_profileheaderdetails phdi,
          phd_profileheaderdetails phdc,
          v_shm_shed_master shm,
          cym_countrymaster cym_shm,
          cim_citymaster cim_shm,
          sm_state_master sm_shm,
          phd_profileheaderdetails phd_supp
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND akc.corporate_id = gmr.corporate_id
      AND wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND wrd.action_no = agmr.action_no
      AND gmr.internal_action_ref_no = axs.internal_action_ref_no
      AND agmr.gmr_latest_action_action_id = ''warehouseReceipt''
      AND agmr.is_deleted = ''N''
      AND agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcm.cp_id = phd.profileid
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.qty_unit_id = qum.qty_unit_id
      AND gmr.qty_unit_id = qumbl.qty_unit_id
      AND wrd.sender_id = phdnp.profileid(+)
      AND wrd.supp_rep_id = phd_supp.profileid(+)
      AND gmr.qty_unit_id = qum_gmr.qty_unit_id
      AND phdi.profileid(+) = wrd.sender_id
      AND phdc.profileid(+) = wrd.consignee_id
      AND shm.profile_id = wrd.warehouse_profile_id
      AND shm.shed_id = wrd.shed_id
      AND shm.country_id = cym_shm.country_id
      AND sm_shm.state_id(+) = shm.state_id
      AND shm.city_id = cim_shm.city_id
      AND gmr.internal_gmr_ref_no = ?';
   fetchquerysddfor_landingdetail   CLOB
      := 'INSERT INTO sdd_d
            (attention, buyer, contract_date, contract_item_no, contract_qty,
             contract_qty_unit, contract_ref_no, cp_ref_no,
             destination_location, discharge_country, discharge_port, eta_end,
             eta_start, fulfilment_type, goods, inco_terms,
             internal_contract_item_ref_no, internal_doc_ref_no,
             internal_gmr_ref_no, is_other_optional_ports, issue_date,
             loading_country, loading_location, loading_port,
             other_shipment_terms, packing_type, qty_of_goods,
             qty_of_goods_unit, seller, tolerance_level, tolerance_max,
             tolerance_min, tolerance_type, vessel_name, bl_date, bl_number,
             bl_quantity, bl_quantity_unit, optional_destin_ports,
             optional_origin_ports, created_date, parity_location,
             productandquality, notifyparity, shipper, notes,
             specialinstructions, voyagenumber, shipperrefno,
             transshipmentport, etadestinationport, shippersinstructions,
             carrieragentsendorsements, wholenewreport, container_nos,
             quantity, quantity_unit, quantity_decimals, net_weignt_gmr,
             net_weight_unit_gmr, decimals, bldate_blno, bl_quantity_decimals,
             activity_date, flight_number, destination_airport, awb_date,
             awb_number, awb_quantity, loading_airport, loading_date,
             endorsements, other_airway_billing_item, no_of_pieces,
             nature_of_good, dimensions, stock_ref_no, net_weight,
             tare_weight, gross_weight, commodity_description, comments,
             activity_ref_no, weigher, weigher_note_no, weighing_date,
             remarks, rail_name_number, rr_date, rr_number, total_qty, rr_qty,
             truck_number, cmr_date, cmr_number, cmr_quantity,
             other_trucking_terms, trucking_instructions, cp_address,
             cp_location, mode_of_transport)
   SELECT '''' attention, phd.companyname buyer,
          TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') contractdate,
          (SELECT f_string_aggregate (pci.contract_item_ref_no)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                            agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') contractitemno,
          pcpd.qty_max_val contractqty, qum.qty_unit contractqtyunit,
          pcm.contract_ref_no contractrefno, pcm.cp_contract_ref_no,
          cym.country_name destination_location,
          cym.country_name dischargecountry, cim.city_name,
          TO_CHAR (vd.etd, ''dd-Mon-yyyy'') etaend,
          TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etastart, '''' fulfilment_type,
          '''' goods,
          (SELECT f_string_aggregate (pci.incoterm)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                                  agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') incoterm,
          (SELECT f_string_aggregate
                     (pci.internal_contract_item_ref_no
                     )
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                                            agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') internalcontractitemrefno,
          ?, gmr.internal_gmr_ref_no internalgmrrefno,
          '''' is_other_optional_ports, '''' issue_date,
          cyml.country_name loadingcountry,
          cyml.country_name loading_location, cim_load.city_name loadingport,
          '''' other_shipment_terms, '''' packing_type,
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity (agrd.product_id,
                                                            agrd.qty_unit_id,
                                                            gmr.qty_unit_id,
                                                            agrd.qty
                                                           )
                     )
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') qty_of_goods,
          qumbl.qty_unit, phdnp.companyname seller, '''' tolerance_level,
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, vd.vessel_voyage_name vesselname,
          TO_CHAR (wrd.storage_date, ''dd-Mon-yyyy'') bldate,
          gmr.bl_no blnumber, gmr.qty blqty, qumbl.qty_unit blqtyunit,
          '''' optional_destin_ports, '''' optional_origin_ports,
          TO_CHAR (gmr.created_date, ''dd-Mon-yyyy'') createddate,
          (SELECT f_string_aggregate (pci.incoterm_location)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                           agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') parity_location,
          (SELECT f_string_aggregate (   pdm.product_desc
                                      || '' , ''
                                      || qat.quality_name
                                     )
             FROM pdm_productmaster pdm,
                  qat_quality_attributes qat,
                  agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N''
              AND pdm.product_id = agrd.product_id
              AND qat.quality_id = agrd.quality_id) productandquality,
          phdnp.companyname notifyparty, '''' shipper, vd.notes notes,
          vd.special_instructions specialinst, vd.voyage_number voyagenumber,
          vd.shippers_ref_no shipperrefno, '''' transport,
          TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etadestinationport,
          vd.shippers_instructions shippersinstructions,
          vd.carriers_agents_endorsements carrieragentsendorsements,
          '''' wholenewreport,
          (SELECT f_string_aggregate (agrd.no_of_containers)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                       agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') container_nos,
          gmr.qty quantity, qum_gmr.qty_unit quantity_unit,
          qum_gmr.decimals quantity_decimals, gmr.current_qty net_weignt_gmr,
          qum_gmr.qty_unit net_weight_unit_gmr, qum_gmr.decimals decimals,
          ((TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'')) || '' '' || gmr.bl_no
          ) bldate_blno,
          qum_gmr.decimals bl_quantity_decimals,
          TO_CHAR (axs.eff_date, ''dd-Mon-yyyy'') activity_date,
          vd.voyage_number flight_number,
          cym_vd.country_name destination_airport, '''' awb_date, '''' awb_number,
          gmr.qty awb_quantity, cym_vdl.country_name loading_airport,
          TO_CHAR (vd.loading_date, ''dd-Mon-yyyy'') loading_date,
          '''' endorsements, '''' other_airway_billing_item,
          vd.no_of_pieces no_of_pieces, vd.nature_of_goods nature_of_good,
          vd.dimensions dimensions, '''', gmr.qty net_weight,
          gmr.total_tare_weight tare_weight,
          gmr.total_gross_weight gross_weight, '''' commodity_description,
          wrd.internal_remarks comments, wrd.activity_ref_no activity_ref_no,
          '''' weigher, '''' weigher_note_no, '''' weighing_date, wrd.notes remarks,
          (vd.vessel_voyage_name || '' '' || vd.voyage_number
          ) rail_name_number, '''' rr_date, '''' rr_number, gmr.qty total_qty,
          gmr.qty rr_qty, vd.shippers_ref_no truck_number, '''' cmr_date,
          '''' cmr_number, gmr.qty cmr_quantity, '''' other_trucking_terms,
          vd.comments trucking_instructions,
          (SELECT MAX (pad.address)
             FROM pad_profile_addresses pad
            WHERE pad.profile_id = pcm.cp_id
              AND pad.address_type = ''Main'') cp_address,
          (SELECT MAX (cim.city_name || '','' || cym.country_name)
             FROM pad_profile_addresses pad,
                  cim_citymaster cim,
                  cym_countrymaster cym
            WHERE pad.profile_id = pcm.cp_id
              AND pad.address_type = ''Main''
              AND pad.city_id = cim.city_id(+)
              AND pad.country_id = cym.country_id(+)) cp_location,
          gmr.mode_of_transport mode_of_transport
     FROM gmr_goods_movement_record gmr,
          vd_voyage_detail vd,
          wrd_warehouse_receipt_detail wrd,
          agmr_action_gmr agmr,
          axs_action_summary axs,
          phd_profileheaderdetails phd,
          phd_profileheaderdetails phdnp,
          pcm_physical_contract_main pcm,
          pcpd_pc_product_definition pcpd,
          qum_quantity_unit_master qum,
          cym_countrymaster cym,
          cym_countrymaster cyml,
          cym_countrymaster cym_vd,
          cym_countrymaster cym_vdl,
          cim_citymaster cim,
          cim_citymaster cim_load,
          qum_quantity_unit_master qumbl,
          qum_quantity_unit_master qum_gmr
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND vd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND wrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND wrd.action_no = agmr.action_no
      AND gmr.internal_action_ref_no = axs.internal_action_ref_no
      AND agmr.gmr_latest_action_action_id = ''landingDetail''
      AND agmr.is_deleted = ''N''
      AND agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcm.cp_id = phd.profileid
      AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.qty_unit_id = qum.qty_unit_id
      AND gmr.discharge_country_id = cym.country_id
      AND gmr.loading_country_id = cyml.country_id
      AND gmr.loading_country_id = cym_vd.country_id
      AND gmr.loading_country_id = cym_vdl.country_id
      AND vd.discharge_city_id = cim.city_id(+)
      AND vd.loading_city_id = cim_load.city_id(+)
      AND gmr.qty_unit_id = qumbl.qty_unit_id
      AND wrd.sender_id = phdnp.profileid(+)
      AND gmr.qty_unit_id = qum_gmr.qty_unit_id
      AND gmr.internal_gmr_ref_no = ?';
   fetchquerysddfor_weightnote      CLOB
      := 'INSERT INTO sdd_d
            (attention, buyer, contract_date, contract_item_no, contract_qty,
             contract_qty_unit, contract_ref_no, cp_ref_no, discharge_country,
             discharge_port, eta_end, eta_start, fulfilment_type, goods,
             inco_terms, internal_contract_item_ref_no, internal_doc_ref_no,
             internal_gmr_ref_no, is_other_optional_ports, issue_date,
             loading_country, loading_port, other_shipment_terms,
             packing_type, qty_of_goods, qty_of_goods_unit, seller,
             tolerance_level, tolerance_max, tolerance_min, tolerance_type,
             vessel_name, bl_date, bl_number, bl_quantity, bl_quantity_unit,
             optional_destin_ports, optional_origin_ports, created_date,
             parity_location, productandquality, notifyparity, shipper, notes,
             specialinstructions, voyagenumber, shipperrefno,
             transshipmentport, etadestinationport, shippersinstructions,
             carrieragentsendorsements, wholenewreport, container_nos,
             quantity, quantity_unit, quantity_decimals, net_weignt_gmr,
             net_weight_unit_gmr, decimals, bldate_blno, bl_quantity_decimals,
             activity_date, flight_number, destination_airport, awb_date,
             awb_number, awb_quantity, loading_airport, loading_date,
             endorsements, other_airway_billing_item, no_of_pieces,
             nature_of_good, dimensions, stock_ref_no, net_weight,
             tare_weight, gross_weight, commodity_description, comments,
             activity_ref_no, weigher, weigher_note_no, weighing_date,
             remarks, rail_name_number, rr_date, rr_number, total_qty, rr_qty,
             truck_number, cmr_date, cmr_number, cmr_quantity,
             other_trucking_terms, trucking_instructions)
   SELECT '''', phd.companyname buyer,
          TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') contractdate,
          (SELECT f_string_aggregate (pci.contract_item_ref_no)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                            agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') contractitemno,
          pcpd.qty_max_val contractqty, qum.qty_unit contractqtyunit,
          pcm.contract_ref_no contractrefno, pcm.cp_contract_ref_no,
          cym.country_name dischargecountry, pmt.port_name,
          TO_CHAR (vd.etd, ''dd-Mon-yyyy'') etaend,
          TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etastart, '''',
          (SELECT f_string_aggregate (qat.quality_name)
             FROM qat_quality_attributes qat, agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N''
              AND qat.quality_id = agrd.quality_id) goods,
          (SELECT f_string_aggregate (itm.incoterm)
             FROM agrd_action_grd agrd,
                  pci_physical_contract_item pci,
                  pcdb_pc_delivery_basis pcdb,
                  itm_incoterm_master itm
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N''
              AND pci.internal_contract_item_ref_no =
                                            agrd.internal_contract_item_ref_no
              AND pcdb.pcdb_id = pci.pcdb_id
              AND itm.incoterm_id = pcdb.inco_term_id) incoterm,
          (SELECT f_string_aggregate
                     (pci.internal_contract_item_ref_no
                     )
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                                            agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') internalcontractitemrefno,
          ?, gmr.internal_gmr_ref_no internalgmrrefno, '''',
          TO_CHAR (wn.issue_date, ''dd-Mon-yyyy'') issue_date,
          cyml.country_name loadingcountry, pmtl.port_name loadingport, '''',
          '''',
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity (agrd.product_id,
                                                            agrd.qty_unit_id,
                                                            gmr.qty_unit_id,
                                                            agrd.qty
                                                           )
                     )
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') qty_of_goods,
          qumbl.qty_unit, ak.corporate_name seller, '''',
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, vd.vessel_voyage_name vesselname,
          TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'') bldate, gmr.bl_no blnumber,
          gmr.qty blqty, qumbl.qty_unit blqtyunit, '''', '''',
          TO_CHAR (gmr.created_date, ''dd-Mon-yyyy'') createddate,
          (SELECT f_string_aggregate (pci.incoterm_location)
             FROM v_pci pci, agrd_action_grd agrd
            WHERE pci.internal_contract_item_ref_no =
                           agrd.internal_contract_item_ref_no
              AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N'') parity_location,
          (SELECT f_string_aggregate (   pdm.product_desc
                                      || '' , ''
                                      || qat.quality_name
                                     )
             FROM pdm_productmaster pdm,
                  qat_quality_attributes qat,
                  agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.is_deleted = ''N''
              AND pdm.product_id = agrd.product_id
              AND qat.quality_id = agrd.quality_id) product_quality,
          '''', '''', vd.notes notes, vd.special_instructions specialinst,
          vd.voyage_number voyagenumber, vd.shippers_ref_no shipperrefno,
          pmtts.port_name transport, '''', '''', '''', '''', '''', gmr.qty quantity,
          qumbl.qty_unit quantity_unit, qumbl.decimals quantity_decimals,
          gmr.current_qty net_weignt_gmr, qumbl.qty_unit net_weight_unit_gmr,
          qumbl.decimals decimals,
          ((TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'')) || '' '' || gmr.bl_no
          ) bldate_blno,
          qumbl.decimals bl_quantity_decimals,
          TO_CHAR (agmr.eff_date, ''dd-Mon-yyyy'') activity_date,
          vd.voyage_number flight_number, '''', '''', '''', gmr.qty awb_quantity,
          '''', TO_CHAR (vd.loading_date, ''dd-Mon-yyyy'') loading_date, '''', '''', '''', '''', '''',
          (SELECT f_string_aggregate (agrd.internal_stock_ref_no)
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.status = ''Active'') stock_ref_no,
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity (agrd.product_id,
                                                            agrd.qty_unit_id,
                                                            gmr.qty_unit_id,
                                                            agrd.qty
                                                           )
                     ) net_weight
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                          agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.status = ''Active'') net_weight,
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity (agrd.product_id,
                                                            agrd.qty_unit_id,
                                                            gmr.qty_unit_id,
                                                            agrd.tare_weight
                                                           )
                     ) tare_weight
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                         agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.status = ''Active'') tare_weight,
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity (agrd.product_id,
                                                            agrd.qty_unit_id,
                                                            gmr.qty_unit_id,
                                                            agrd.gross_weight
                                                           )
                     ) gross_weight
             FROM agrd_action_grd agrd
            WHERE agrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no
              AND agrd.action_no = agmr.action_no
              AND agrd.status = ''Active'') gross_weight,
          '''', '''', wn.activity_ref_no, phd_w.companyname weigher,
          wn.weight_note_no,
          TO_CHAR (wn.weighing_date, ''dd-Mon-yyyy'') weighing_date, '''', '''', '''',
          '''', gmr.qty total_qty, gmr.qty rr_qty, '''', '''', '''',
          gmr.qty cmr_quantity, '''', ''''
     FROM pcm_physical_contract_main pcm,
          pcpd_pc_product_definition pcpd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          phd_profileheaderdetails phd,
          phd_profileheaderdetails phd_w,
          qum_quantity_unit_master qumbl,
          qum_quantity_unit_master qum,
          ak_corporate ak,
          wnd_weight_note_detail wn,
          pmt_portmaster pmt,
          vd_voyage_detail vd,
          cym_countrymaster cym,
          cym_countrymaster cyml,
          pmt_portmaster pmtl,
          pmt_portmaster pmtts
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.gmr_latest_action_action_id = ''weightNote''
      AND agmr.is_deleted = ''N''
      AND pcm.internal_contract_ref_no = agmr.internal_contract_ref_no
      AND phd.profileid = pcm.cp_id
      AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcpd.is_active = ''Y''
      AND qum.qty_unit_id = pcpd.qty_unit_id
      AND gmr.discharge_country_id = cym.country_id
      AND gmr.qty_unit_id = qumbl.qty_unit_id
      AND ak.corporate_id = gmr.corporate_id
      AND gmr.discharge_port_id = pmt.port_id(+)
      AND gmr.loading_country_id = cyml.country_id(+)
      AND gmr.loading_port_id = pmtl.port_id(+)
      AND vd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND vd.trans_shipment_port_id = pmtts.port_id(+)
      AND wn.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND wn.action_no = agmr.action_no
      AND wn.weigher_profile_id = phd_w.profileid(+)
      AND gmr.internal_gmr_ref_no = ?';
   fetchquerysadfor_sadvise         CLOB
      := 'INSERT INTO sad_d
            (attention, buyer, contract_date, contract_item_no, contract_qty,
             contract_qty_unit, contract_ref_no, cp_ref_no, discharge_country,
             discharge_port, eta_end, eta_start, fulfilment_type, goods,
             inco_terms, internal_contract_item_ref_no, internal_doc_ref_no,
             internal_gmr_ref_no, is_other_optional_ports, issue_date,
             loading_country, loading_port, other_shipment_terms,
             packing_type, qty_of_goods, qty_of_goods_unit, seller,
             tolerance_level, tolerance_max, tolerance_min, tolerance_type,
             vessel_name, bl_date, bl_number, bl_quantity, bl_quantity_unit,
             optional_destin_ports, optional_origin_ports, created_date,
             parity_location, productandquality, notifyparity, shipper, notes,
             specialinstructions, voyagenumber, shipperrefno,
             transshipmentport, etadestinationport, shippersinstructions,
             carrieragentsendorsements, wholenewreport, container_nos,
             quantity, quantity_unit, quantity_decimals, net_weignt_gmr,
             net_weight_unit_gmr, decimals, bldate_blno, bl_quantity_decimals,
             activity_date, flight_number, destination_airport, awb_date,
             awb_number, awb_quantity, loading_airport, loading_date,
             endorsements, other_airway_billing_item, no_of_pieces,
             nature_of_good, dimensions, stock_ref_no, net_weight,
             tare_weight, gross_weight, commodity_description, comments,
             activity_ref_no, weigher, weigher_note_no, weighing_date,
             remarks, rail_name_number, rr_date, rr_number, total_qty, rr_qty,
             truck_number, cmr_date, cmr_number, cmr_quantity,
             other_trucking_terms, trucking_instructions, loading_state,
             destination_state, trans_shipment_country, trans_shipment_state,
             supp_rep, mode_of_transport)
   SELECT '''', pci.cp_name buyer,
          TO_CHAR (pci.issue_date, ''dd-Mon-yyyy'') contractdate,
          pci.contract_item_ref_no contractitemno,
          f_format_to_char (pcpd.qty_max_val, 4) contractqty,
          qum.qty_unit contractqtyunit, pci.contract_ref_no contractrefno,
          pci.cp_contract_ref_no, cym.country_name dischargecountry,
          cim.city_name port_name, TO_CHAR (vd.etd, ''dd-Mon-yyyy'') etaend,
          TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etastart, '''', '''',
          pci.incoterm incoterm,
          pci.internal_contract_item_ref_no internalcontractitemrefno, ?,
          gmr.internal_gmr_ref_no internalgmrrefno, '''',
          TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') issue_date,
          cyml.country_name loadingcountry, cim_load.city_name loadingport,
          '''', '''' packing_type, f_format_to_char (gmr.qty, 4) qty_of_goods,
          qumbl.qty_unit qty_of_goods_unit, akc.corporate_name seller, '''',
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, vd.vessel_voyage_name vesselname,
          TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'') bldate, gmr.bl_no blnumber,
          f_format_to_char (gmr.qty, 4) blqty, qumbl.qty_unit blqtyunit, '''',
          '''', TO_CHAR (gmr.created_date, ''dd-Mon-yyyy'') createddate,
          pci.incoterm_location parity_location,
          pci.product_name || '','' || pci.quality_name productandquality,
          phdnp.companyname notifyparty, phd_shipper.companyname shipper,
          vd.notes notes, vd.special_instructions specialinst,
          vd.voyage_number voyagenumber, vd.shippers_ref_no shipperrefno,
          cim_trans.city_name transport,
          TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etadestinationport,
          vd.shippers_instructions shippersinstructions,
          vd.carriers_agents_endorsements carrieragentsendorsements,
          vd.voyage_ref_no,
          (SELECT f_string_aggregate (dgrd.container_no)
             FROM dgrd_delivered_grd dgrd
            WHERE dgrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no)
                                                                 container_no,
          f_format_to_char (gmr.qty, 4) quantity,
          qumbl.qty_unit quantity_unit, '''',
          f_format_to_char (gmr.qty, 4) net_weignt_gmr,
          qumbl.qty_unit net_weight_unit_gmr, '''',
          (TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') || '' '' || sad.bl_no
          ) bldate_blno,
          '''', TO_CHAR (axs.action_date, ''dd-Mon-yyyy'') activity_date,
          vd.voyage_number flight_number,
          cym_vd.country_name destination_airport,
          TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') awb_date, sad.bl_no awb_number,
          f_format_to_char (gmr.qty, 4) awb_quantity, '''',
          TO_CHAR (vd.loading_date, ''dd-Mon-yyyy'') loading_date,
          vd.carriers_agents_endorsements, '''', vd.no_of_pieces no_of_pieces,
          vd.nature_of_goods nature_of_good, vd.dimensions dimensions,
          (SELECT f_string_aggregate (dgrd.internal_stock_ref_no)
             FROM dgrd_delivered_grd dgrd
            WHERE dgrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no)
                                                                 stock_ref_no,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qum.qty_unit_id,
                                                     adgrd.net_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) net_weight,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qum.qty_unit_id,
                                                     adgrd.tare_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) tare_weight,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qum.qty_unit_id,
                                                     adgrd.gross_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) gross_weight,
          vd.handling_instructions, sad.internal_remarks comments, '''', '''', '''',
          '''', '''',
          (vd.vessel_voyage_name || '' '' || vd.voyage_number
          ) rail_name_number, TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') rr_date,
          sad.bl_no rr_number, f_format_to_char (gmr.qty, 4) total_qty,
          f_format_to_char (gmr.qty, 4) rr_qty,
          vd.shippers_ref_no truck_number,
          TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') cmr_date, sad.bl_no cmr_number,
          f_format_to_char (gmr.qty, 4) cmr_quantity, '''',
          vd.comments trucking_instructions, sm_load.state_name loading_state,
          sm_dis.state_name destination_state,
          cym_tran.country_name trans_shipment_country,
          sm_tran.state_name trans_shipment_state,
          phd_supp.companyname supp_rep,
          gmr.mode_of_transport mode_of_transport
     FROM gmr_goods_movement_record gmr,
          sad_shipment_advice sad,
          ak_corporate akc,
          v_pci pci,
          gcim_gmr_contract_item_mapping gcim,
          phd_profileheaderdetails phd,
          vd_voyage_detail vd,
          pcpd_pc_product_definition pcpd,
          qum_quantity_unit_master qum,
          qum_quantity_unit_master qumbl,
          cym_countrymaster cym,
          pmt_portmaster pmt,
          cym_countrymaster cyml,
          pmt_portmaster pmtl,
          axs_action_summary axs,
          phd_profileheaderdetails phdnp,
          phd_profileheaderdetails phd_seller,
          pmt_portmaster pmt_vd,
          cym_countrymaster cym_vd,
          cim_citymaster cim,
          cim_citymaster cim_load,
          cim_citymaster cim_trans,
          phd_profileheaderdetails phd_shipper,
          phd_profileheaderdetails phd_supp,
          cim_citymaster cim_arrival,
          agmr_action_gmr agmr,
          sm_state_master sm_load,
          sm_state_master sm_dis,
          sm_state_master sm_tran,
          cym_countrymaster cym_tran
    WHERE gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no
      AND gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no
      AND sad.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND vd.action_no = agmr.action_no
      AND sad.action_no = agmr.action_no
      AND vd.status = ''Active''
      AND gcim.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
      AND pci.contract_type = ''S''
      AND pci.cp_id = phd.profileid
      AND gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.qty_unit_id = qum.qty_unit_id
      AND gmr.discharge_country_id = cym.country_id
      AND gmr.discharge_port_id = pmt.port_id(+)
      AND gmr.loading_country_id = cyml.country_id
      AND gmr.loading_port_id = pmtl.port_id(+)
      AND gmr.qty_unit_id = qumbl.qty_unit_id
      AND gmr.internal_action_ref_no = axs.internal_action_ref_no
      AND sad.consignee_id = phd_seller.profileid(+)
      AND vd.shipping_line_profile_id = phd_shipper.profileid(+)
      AND sad.notify_party_id = phdnp.profileid(+)
      AND sad.supp_rep_id = phd_supp.profileid(+)
      AND vd.discharge_port_id = pmt_vd.port_id(+)
      AND vd.discharge_country_id = cym_vd.country_id(+)
      AND vd.discharge_city_id = cim.city_id(+)
      AND vd.loading_city_id = cim_load.city_id(+)
      AND vd.trans_shipment_city_id = cim_trans.city_id(+)
      AND vd.loading_state_id = sm_load.state_id(+)
      AND vd.discharge_state_id = sm_dis.state_id(+)
      AND vd.trans_shipment_state_id = sm_tran.state_id(+)
      AND vd.trans_shipment_country_id = cym_tran.country_id(+)
      AND sad.port_of_arrival_city_id = cim_arrival.city_id(+)
      AND gmr.corporate_id = akc.corporate_id
      AND agmr.is_deleted = ''N''
      AND agmr.gmr_latest_action_action_id IN
                 (''airAdvice'', ''shipmentAdvise'', ''truckAdvice'', ''railAdvice'')
      AND gmr.internal_gmr_ref_no = ?';
   fetchquerysadfor_releaseorder    CLOB
      := 'INSERT INTO sad_d
            (attention, buyer, contract_date, contract_item_no, contract_qty,
             contract_qty_unit, contract_ref_no, cp_ref_no, inco_terms,
             internal_contract_item_ref_no, internal_doc_ref_no,
             internal_gmr_ref_no, is_other_optional_ports, issue_date,
             loading_country, loading_port, other_shipment_terms,
             packing_type, qty_of_goods, qty_of_goods_unit, seller,
             tolerance_level, tolerance_max, tolerance_min, tolerance_type,
             created_date, parity_location, productandquality, notifyparity,
             shipper, notes, specialinstructions, quantity, quantity_unit,
             activity_date, flight_number, destination_airport, awb_date,
             awb_number, awb_quantity, loading_airport, loading_date,
             endorsements, other_airway_billing_item, no_of_pieces,
             nature_of_good, dimensions, stock_ref_no, net_weight,
             tare_weight, gross_weight, commodity_description, comments,
             activity_ref_no, remarks, rail_name_number, rr_date, rr_number,
             issuer, issuer_ref_no, issuer_address, consignee,
             consignee_ref_no, consignee_address, warehouse_and_shed,
             warehouse_address, supp_rep, mode_of_transport)
   SELECT '''', pci.cp_name buyer, TO_CHAR (pci.issue_date, ''dd-Mon-yyyy'') contractdate,
          pci.contract_item_ref_no contractitemno,
          f_format_to_char (pcpd.qty_max_val, 4) contractqty,
          qum.qty_unit contractqtyunit, pci.contract_ref_no contractrefno,
          pci.cp_contract_ref_no cprefno, pci.incoterm incoterm,
          pci.internal_contract_item_ref_no internalcontractitemrefno, ?,
          gmr.internal_gmr_ref_no internalgmrrefno, '''',
          TO_CHAR (rod.release_date, ''dd-Mon-yyyy'') issue_date, '''', '''', '''',
          '''' packing_type, f_format_to_char (gmr.qty, 4) qty_of_goods,
          qumbl.qty_unit qty_of_goods_unit, akc.corporate_name seller, '''',
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, TO_CHAR (gmr.created_date, ''dd-Mon-yyyy'') createddate,
          pci.incoterm_location parity_location,
          pci.product_name || '','' || pci.quality_name productandquality, '''',
          phdi.companyname issuer, rod.notes notes,
          rod.special_instructions specialinst,
          f_format_to_char (gmr.qty, 4) quantity,
          qumbl.qty_unit quantity_unit,
          TO_CHAR (axs.action_date, ''dd-Mon-yyyy'') activity_date, '''', '''', '''',
          '''', '''', '''', '''', '''', '''', '''', '''', '''',
          (SELECT f_string_aggregate (dgrd.internal_stock_ref_no)
             FROM dgrd_delivered_grd dgrd
            WHERE dgrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no)
                                                                 stock_ref_no,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qumbl.qty_unit_id,
                                                     adgrd.net_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) net_weight,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qumbl.qty_unit_id,
                                                     adgrd.tare_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) tare_weight,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qumbl.qty_unit_id,
                                                     adgrd.gross_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) gross_weight,
          '''', rod.comments comments, rod.activity_ref_no activityrefno, '''',
          '''', '''', rod.receipt_no receiptno, phdi.companyname issuer,
          rod.issuers_ref_no issuerrefno, rod.issuers_address issueraddress,
          phdc.companyname consignee, rod.consignees_ref_no consigneerefno,
          rod.consignee_address consigneeaddress,
          shm.companyname || '','' || shm.shed_name warehouseandshed,
          (CASE
              WHEN sm_shm.state_id IS NULL
                 THEN    shm.address
                      || '' , ''
                      || cim_shm.city_name
                      || '' , ''
                      || cym_shm.country_name
              ELSE    shm.address
                   || '' , ''
                   || cim_shm.city_name
                   || '' , ''
                   || sm_shm.state_name
                   || '' , ''
                   || cym_shm.country_name
           END
          ) warehouseaddress,
          phd_supp.companyname supp_rep,
          gmr.mode_of_transport mode_of_transport
     FROM v_pci pci,
          qum_quantity_unit_master qum,
          qum_quantity_unit_master qumbl,
          pcpd_pc_product_definition pcpd,
          gmr_goods_movement_record gmr,
          rod_release_order_detail rod,
          phd_profileheaderdetails phdi,
          phd_profileheaderdetails phdc,
          ak_corporate akc,
          axs_action_summary axs,
          agmr_action_gmr agmr,
          gcim_gmr_contract_item_mapping gcim,
          v_shm_shed_master shm,
          cym_countrymaster cym_shm,
          cim_citymaster cim_shm,
          sm_state_master sm_shm,
          phd_profileheaderdetails phd_supp
    WHERE gmr.internal_gmr_ref_no = rod.internal_gmr_ref_no
      AND gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND rod.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND rod.action_no = agmr.action_no
      AND gcim.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
      AND pci.contract_type = ''S''
      AND phdi.profileid(+) = rod.issue_id
      AND phdc.profileid(+) = rod.consignee_id
      AND pcpd.internal_contract_ref_no = pci.internal_contract_ref_no
      AND pcpd.product_id = pci.product_id
      AND pcpd.qty_unit_id = qum.qty_unit_id
      AND gmr.corporate_id = akc.corporate_id
      AND agmr.is_deleted = ''N''
      AND agmr.gmr_latest_action_action_id IN (''releaseOrder'')
      AND gmr.qty_unit_id = qumbl.qty_unit_id
      AND gmr.internal_action_ref_no = axs.internal_action_ref_no
      AND shm.profile_id = rod.warehouse_profile_id
      AND shm.shed_id = rod.warehouse_shed_id
      AND shm.country_id = cym_shm.country_id
      AND sm_shm.state_id(+) = shm.state_id
      AND shm.city_id = cim_shm.city_id
      AND rod.supp_rep_id = phd_supp.profileid(+)
      AND gmr.internal_gmr_ref_no = ?';
   fetchquerysadfor_swnote          CLOB
      := 'INSERT INTO sad_d
            (attention, buyer, contract_date, contract_item_no, contract_qty,
             contract_qty_unit, contract_ref_no, cp_ref_no, discharge_country,
             discharge_port, eta_end, eta_start, fulfilment_type, goods,
             inco_terms, internal_contract_item_ref_no, internal_doc_ref_no,
             internal_gmr_ref_no, is_other_optional_ports, issue_date,
             loading_country, loading_port, other_shipment_terms,
             packing_type, qty_of_goods, qty_of_goods_unit, seller,
             tolerance_level, tolerance_max, tolerance_min, tolerance_type,
             vessel_name, bl_date, bl_number, bl_quantity, bl_quantity_unit,
             optional_destin_ports, optional_origin_ports, created_date,
             parity_location, productandquality, notifyparity, shipper, notes,
             specialinstructions, voyagenumber, shipperrefno,
             transshipmentport, etadestinationport, shippersinstructions,
             carrieragentsendorsements, wholenewreport, container_nos,
             quantity, quantity_unit, quantity_decimals, net_weignt_gmr,
             net_weight_unit_gmr, decimals, bldate_blno, bl_quantity_decimals,
             activity_date, flight_number, destination_airport, awb_date,
             awb_number, awb_quantity, loading_airport, loading_date,
             endorsements, other_airway_billing_item, no_of_pieces,
             nature_of_good, dimensions, stock_ref_no, net_weight,
             tare_weight, gross_weight, commodity_description, comments,
             activity_ref_no, weigher, weigher_note_no, weighing_date,
             remarks, rail_name_number, rr_date, rr_number, total_qty, rr_qty,
             truck_number, cmr_date, cmr_number, cmr_quantity,
             other_trucking_terms, trucking_instructions)
   SELECT '''', phd.companyname buyer,
          TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') contractdate,
          (SELECT f_string_aggregate (pci.contract_item_ref_no)
             FROM v_pci pci, adgrd_action_dgrd adgrd
            WHERE pci.internal_contract_item_ref_no =
                           adgrd.internal_contract_item_ref_no
              AND adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active'') contractitemno,
          pcpd.qty_max_val contractqty, qum.qty_unit contractqtyunit,
          pcm.contract_ref_no contractrefno, pcm.cp_contract_ref_no,
          cym.country_name dischargecountry, pmt.port_name,
          TO_CHAR (vd.etd, ''dd-Mon-yyyy'') etaend,
          TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etastart, '''',
          (SELECT f_string_aggregate (qat.quality_name)
             FROM qat_quality_attributes qat, adgrd_action_dgrd adgrd
            WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active''
              AND qat.quality_id = adgrd.quality_id) goods,
          (SELECT f_string_aggregate (itm.incoterm)
             FROM adgrd_action_dgrd adgrd,
                  pci_physical_contract_item pci,
                  pcdb_pc_delivery_basis pcdb,
                  itm_incoterm_master itm
            WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active''
              AND pci.internal_contract_item_ref_no =
                                           adgrd.internal_contract_item_ref_no
              AND pcdb.pcdb_id = pci.pcdb_id
              AND itm.incoterm_id = pcdb.inco_term_id) incoterm,
          (SELECT f_string_aggregate
                     (pci.internal_contract_item_ref_no
                     )
             FROM v_pci pci, adgrd_action_dgrd adgrd
            WHERE pci.internal_contract_item_ref_no =
                                           adgrd.internal_contract_item_ref_no
              AND adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active'') internalcontractitemrefno,
          ?, gmr.internal_gmr_ref_no internalgmrrefno, '''',
          TO_CHAR (wn.issue_date, ''dd-Mon-yyyy'') issue_date,
          cyml.country_name loadingcountry, pmtl.port_name loadingport, '''',
          '''',
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     gmr.qty_unit_id,
                                                     adgrd.net_weight
                                                    )
                     )
             FROM adgrd_action_dgrd adgrd
            WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active'') qty_of_goods,
          qumbl.qty_unit, ak.corporate_name seller, '''',
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, vd.vessel_voyage_name vesselname,
          TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'') bldate, gmr.bl_no blnumber,
          gmr.qty blqty, qumbl.qty_unit blqtyunit, '''', '''',
          TO_CHAR (gmr.created_date, ''dd-Mon-yyyy'') createddate,
          (SELECT f_string_aggregate (pci.incoterm_location)
             FROM v_pci pci, adgrd_action_dgrd adgrd
            WHERE pci.internal_contract_item_ref_no =
                          adgrd.internal_contract_item_ref_no
              AND adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active'') parity_location,
          (SELECT f_string_aggregate (   pdm.product_desc
                                      || '' ''
                                      || qat.quality_name
                                     )
             FROM pdm_productmaster pdm,
                  qat_quality_attributes qat,
                  adgrd_action_dgrd adgrd
            WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active''
              AND pdm.product_id = adgrd.product_id
              AND qat.quality_id = adgrd.quality_id) product_quality,
          '''', '''', vd.notes notes, vd.special_instructions specialinst,
          vd.voyage_number voyagenumber, vd.shippers_ref_no shipperrefno,
          pmtts.port_name transport, '''', '''', '''', '''', '''',
          gmr.qty quantity, qumbl.qty_unit quantity_unit,
          qumbl.decimals quantity_decimals, gmr.current_qty net_weignt_gmr,
          qumbl.qty_unit net_weight_unit_gmr, qumbl.decimals decimals,
          ((TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'')) || '' '' || gmr.bl_no
          ) bldate_blno,
          qumbl.decimals bl_quantity_decimals,
          TO_CHAR (agmr.eff_date, ''dd-Mon-yyyy'') activity_date,
          vd.voyage_number flight_number, '''', '''', '''',
          gmr.qty awb_quantity, '''', TO_CHAR (vd.loading_date, ''dd-Mon-yyyy'') loading_date, '''',
          '''', '''', '''', '''',
          (SELECT f_string_aggregate
                                    (adgrd.internal_stock_ref_no)
             FROM adgrd_action_dgrd adgrd
            WHERE adgrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active'') stock_ref_no,
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     gmr.qty_unit_id,
                                                     adgrd.net_weight
                                                    )
                     ) net_weight
             FROM adgrd_action_dgrd adgrd
            WHERE adgrd.internal_gmr_ref_no =
                                          agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active'') net_weight,
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     gmr.qty_unit_id,
                                                     adgrd.tare_weight
                                                    )
                     ) tare_weight
             FROM adgrd_action_dgrd adgrd
            WHERE adgrd.internal_gmr_ref_no =
                                         agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active'') tare_weight,
          (SELECT SUM
                     (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     gmr.qty_unit_id,
                                                     adgrd.gross_weight
                                                    )
                     ) gross_weight
             FROM adgrd_action_dgrd adgrd
            WHERE adgrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no
              AND adgrd.action_no = agmr.action_no
              AND adgrd.status = ''Active'') gross_weight,
          '''', '''', wn.activity_ref_no, phd_w.companyname weigher,
          wn.weight_note_no,
          TO_CHAR (wn.weighing_date, ''dd-Mon-yyyy'') weighing_date, '''', '''',
          '''', '''', gmr.qty total_qty, gmr.qty rr_qty, '''', '''', '''',
          gmr.qty cmr_quantity, '''', ''''
     FROM pcm_physical_contract_main pcm,
          pcpd_pc_product_definition pcpd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          phd_profileheaderdetails phd,
          phd_profileheaderdetails phd_w,
          qum_quantity_unit_master qumbl,
          qum_quantity_unit_master qum,
          ak_corporate ak,
          wnd_weight_note_detail wn,
          pmt_portmaster pmt,
          vd_voyage_detail vd,
          cym_countrymaster cym,
          cym_countrymaster cyml,
          pmt_portmaster pmtl,
          pmt_portmaster pmtts
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.gmr_latest_action_action_id = ''salesWeightNote''
      AND agmr.is_deleted = ''N''
      AND pcm.internal_contract_ref_no = agmr.internal_contract_ref_no
      AND phd.profileid = pcm.cp_id
      AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcpd.is_active = ''Y''
      AND qum.qty_unit_id = pcpd.qty_unit_id
      AND gmr.discharge_country_id = cym.country_id(+)
      AND gmr.qty_unit_id = qumbl.qty_unit_id
      AND ak.corporate_id = gmr.corporate_id
      AND gmr.discharge_port_id = pmt.port_id(+)
      AND gmr.loading_country_id = cyml.country_id(+)
      AND gmr.loading_port_id = pmtl.port_id(+)
      AND vd.internal_gmr_ref_no(+) = gmr.internal_gmr_ref_no
      AND vd.trans_shipment_port_id = pmtts.port_id(+)
      AND wn.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND wn.action_no = agmr.action_no
      AND wn.weigher_profile_id = phd_w.profileid(+)
      AND gmr.internal_gmr_ref_no = ?';
   fetchquerysadfor_sbacktoback     CLOB
      := 'INSERT INTO sad_d
            (attention, buyer, contract_date, contract_item_no, contract_qty,
             contract_qty_unit, contract_ref_no, cp_ref_no, discharge_country,
             discharge_port, eta_end, eta_start, fulfilment_type, goods,
             inco_terms, internal_contract_item_ref_no, internal_doc_ref_no,
             internal_gmr_ref_no, is_other_optional_ports, issue_date,
             loading_country, loading_port, other_shipment_terms,
             packing_type, qty_of_goods, qty_of_goods_unit, seller,
             tolerance_level, tolerance_max, tolerance_min, tolerance_type,
             vessel_name, bl_date, bl_number, bl_quantity, bl_quantity_unit,
             optional_destin_ports, optional_origin_ports, created_date,
             parity_location, productandquality, notifyparity, shipper, notes,
             specialinstructions, voyagenumber, shipperrefno,
             transshipmentport, etadestinationport, shippersinstructions,
             carrieragentsendorsements, wholenewreport, container_nos,
             quantity, quantity_unit, quantity_decimals, net_weignt_gmr,
             net_weight_unit_gmr, decimals, bldate_blno, bl_quantity_decimals,
             activity_date, flight_number, destination_airport, awb_date,
             awb_number, awb_quantity, loading_airport, loading_date,
             endorsements, other_airway_billing_item, no_of_pieces,
             nature_of_good, dimensions, stock_ref_no, net_weight,
             tare_weight, gross_weight, commodity_description, comments,
             activity_ref_no, weigher, weigher_note_no, weighing_date,
             remarks, rail_name_number, rr_date, rr_number, total_qty, rr_qty,
             truck_number, cmr_date, cmr_number, cmr_quantity,
             other_trucking_terms, trucking_instructions)
   SELECT '''', pci.cp_name buyer, TO_CHAR (pci.issue_date, ''dd-Mon-yyyy'') contractdate,
          pci.contract_item_ref_no contractitemno,
          f_format_to_char (pcpd.qty_max_val, 4) contractqty,
          qum.qty_unit contractqtyunit, pci.contract_ref_no contractrefno,
          pci.cp_contract_ref_no, cym.country_name dischargecountry,
          cim.city_name port_name, TO_CHAR (vd.etd, ''dd-Mon-yyyy'') etaend, TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etastart, '''', '''',
          pci.incoterm incoterm,
          pci.internal_contract_item_ref_no internalcontractitemrefno, ?,
          gmr.internal_gmr_ref_no internalgmrrefno, '''',
          TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') issue_date,
          cyml.country_name loadingcountry, cim_load.city_name loadingport,
          '''', '''' packing_type, f_format_to_char (gmr.qty, 4) qty_of_goods,
          qumbl.qty_unit qty_of_goods_unit, akc.corporate_name seller, '''',
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, vd.vessel_voyage_name vesselname,
          TO_CHAR (gmr.bl_date, ''dd-Mon-yyyy'') bldate, gmr.bl_no blnumber,
          f_format_to_char (gmr.qty, 4) blqty, qumbl.qty_unit blqtyunit, '''',
          '''', TO_CHAR (gmr.created_date, ''dd-Mon-yyyy'') createddate,
          pci.incoterm_location parity_location,
          pci.product_name || '','' || pci.quality_name productandquality,
          phdnp.companyname notifyparty, phd_shipper.companyname shipper,
          vd.notes notes, vd.special_instructions specialinst,
          vd.voyage_number voyagenumber, vd.shippers_ref_no shipperrefno,
          cim_trans.city_name transport, TO_CHAR (vd.eta, ''dd-Mon-yyyy'') etadestinationport,
          vd.shippers_instructions shippersinstructions,
          vd.carriers_agents_endorsements carrieragentsendorsements,
          vd.voyage_ref_no,
          (SELECT f_string_aggregate (dgrd.container_no)
             FROM dgrd_delivered_grd dgrd
            WHERE dgrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no)
                                                                 container_no,
          f_format_to_char (gmr.qty, 4) quantity,
          qumbl.qty_unit quantity_unit, '''',
          f_format_to_char (gmr.qty, 4) net_weignt_gmr,
          qumbl.qty_unit net_weight_unit_gmr, '''',
          (TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') || '' '' || sad.bl_no
          ) bldate_blno,
          '''', TO_CHAR (axs.action_date, ''dd-Mon-yyyy'') activity_date,
          vd.voyage_number flight_number,
          cym_vd.country_name destination_airport,
          TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') awb_date, sad.bl_no awb_number,
          f_format_to_char (gmr.qty, 4) awb_quantity, '''',
          TO_CHAR (vd.loading_date, ''dd-Mon-yyyy'') loading_date, vd.carriers_agents_endorsements, '''',
          vd.no_of_pieces no_of_pieces, vd.nature_of_goods nature_of_good,
          vd.dimensions dimensions,
          (SELECT f_string_aggregate (dgrd.internal_stock_ref_no)
             FROM dgrd_delivered_grd dgrd
            WHERE dgrd.internal_gmr_ref_no =
                                        agmr.internal_gmr_ref_no)
                                                                 stock_ref_no,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qum.qty_unit_id,
                                                     adgrd.net_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) net_weight,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qum.qty_unit_id,
                                                     adgrd.tare_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) tare_weight,
          f_format_to_char
             ((SELECT SUM
                         (pkg_general.f_get_converted_quantity
                                                    (adgrd.product_id,
                                                     adgrd.net_weight_unit_id,
                                                     qum.qty_unit_id,
                                                     adgrd.gross_weight
                                                    )
                         )
                 FROM adgrd_action_dgrd adgrd
                WHERE adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
                  AND adgrd.status = ''Active''
                  AND adgrd.action_no = agmr.action_no),
              4
             ) gross_weight,
          vd.handling_instructions, sad.internal_remarks comments, '''', '''', '''',
          '''', '''',
          (vd.vessel_voyage_name || '' '' || vd.voyage_number
          ) rail_name_number, TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') rr_date,
          sad.bl_no rr_number, f_format_to_char (gmr.qty, 4) total_qty,
          f_format_to_char (gmr.qty, 4) rr_qty,
          vd.shippers_ref_no truck_number, TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') cmr_date,
          sad.bl_no cmr_number, f_format_to_char (gmr.qty, 4) cmr_quantity,
          '''', vd.comments trucking_instructions
     FROM gmr_goods_movement_record gmr,
          sad_shipment_advice sad,
          ak_corporate akc,
          v_pci pci,
          gcim_gmr_contract_item_mapping gcim,
          phd_profileheaderdetails phd,
          vd_voyage_detail vd,
          pcpd_pc_product_definition pcpd,
          qum_quantity_unit_master qum,
          qum_quantity_unit_master qumbl,
          cym_countrymaster cym,
          pmt_portmaster pmt,
          cym_countrymaster cyml,
          pmt_portmaster pmtl,
          axs_action_summary axs,
          phd_profileheaderdetails phdnp,
          phd_profileheaderdetails phd_seller,
          pmt_portmaster pmt_vd,
          cym_countrymaster cym_vd,
          cim_citymaster cim,
          cim_citymaster cim_load,
          cim_citymaster cim_trans,
          phd_profileheaderdetails phd_shipper,
          cim_citymaster cim_arrival,
          agmr_action_gmr agmr
    WHERE gmr.internal_gmr_ref_no = sad.internal_gmr_ref_no
      AND gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no
      AND sad.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND vd.action_no = agmr.action_no
      AND sad.action_no = agmr.action_no
      AND vd.status = ''Active''
      AND gcim.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND gcim.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
      AND pci.contract_type = ''S''
      AND pci.cp_id = phd.profileid
      AND gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no
      AND pcpd.qty_unit_id = qum.qty_unit_id
      AND gmr.discharge_country_id = cym.country_id
      AND gmr.discharge_port_id = pmt.port_id(+)
      AND gmr.loading_country_id = cyml.country_id
      AND gmr.loading_port_id = pmtl.port_id(+)
      AND gmr.qty_unit_id = qumbl.qty_unit_id
      AND gmr.internal_action_ref_no = axs.internal_action_ref_no
      AND sad.consignee_id = phd_seller.profileid(+)
      AND vd.shipping_line_profile_id = phd_shipper.profileid(+)
      AND sad.notify_party_id = phdnp.profileid(+)
      AND vd.discharge_port_id = pmt_vd.port_id(+)
      AND vd.discharge_country_id = cym_vd.country_id(+)
      AND vd.discharge_city_id = cim.city_id(+)
      AND vd.loading_city_id = cim_load.city_id(+)
      AND vd.trans_shipment_city_id = cim_trans.city_id(+)
      AND sad.port_of_arrival_city_id = cim_arrival.city_id(+)
      AND gmr.corporate_id = akc.corporate_id
      AND agmr.is_deleted = ''N''
      AND agmr.gmr_latest_action_action_id = ''shipmentBackToBack''
      AND gmr.internal_gmr_ref_no = ?';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysddfor_truckdetail
    WHERE dgm.doc_id = 'airDetail'
      AND dgm.dgm_id = '9'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysddfor_truckdetail
    WHERE dgm.doc_id = 'railDetail'
      AND dgm.dgm_id = '7'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysddfor_truckdetail
    WHERE dgm.doc_id = 'shipmentDetail'
      AND dgm.dgm_id = '5'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysddfor_truckdetail
    WHERE dgm.doc_id = 'truckDetail'
      AND dgm.dgm_id = '8'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysddfor_whreceipt
    WHERE dgm.doc_id = 'warehouseReceipt'
      AND dgm.dgm_id = '6'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysddfor_landingdetail
    WHERE dgm.doc_id = 'landingDetail'
      AND dgm.dgm_id = '24'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysddfor_weightnote
    WHERE dgm.doc_id = 'weightNote'
      AND dgm.dgm_id = '18'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysadfor_sadvise
    WHERE dgm.doc_id = 'airAdvice'
      AND dgm.dgm_id = '2'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysadfor_sadvise
    WHERE dgm.doc_id = 'railAdvice'
      AND dgm.dgm_id = '3'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysadfor_sadvise
    WHERE dgm.doc_id = 'shipmentAdvise'
      AND dgm.dgm_id = '1'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysadfor_sadvise
    WHERE dgm.doc_id = 'truckAdvice'
      AND dgm.dgm_id = '4'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysadfor_releaseorder
    WHERE dgm.doc_id = 'releaseOrder'
      AND dgm.dgm_id = 'DGM_RO_SAD_D'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysadfor_swnote
    WHERE dgm.doc_id = 'salesWeightNote'
      AND dgm.dgm_id = '17'
      AND dgm.sequence_order = 1;

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysadfor_sbacktoback
    WHERE dgm.doc_id = 'shipmentBackToBack'
      AND dgm.dgm_id = '20'
      AND dgm.sequence_order = 1;

   COMMIT;
END;