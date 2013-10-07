-- DGM SCRIPTS FOR Assay (Purchase) Population
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_SD_ASSAY_D', 'shipmentDetail', 'Shipment Detail',
             'shipmentDetail', 3, 'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM_RD_ASSAY_D', 'railDetail', 'Rail Detail', 'railDetail', 3,
             'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM_AD_ASSAY_D', 'airDetail', 'Air Detail', 'airDetail', 3,
             'Query', 'N'
            );
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_TD_ASSAY_D', 'truckDetail', 'Truck Detail', 'truckDetail',
             3, 'Query', 'N'
            );
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_WR_ASSAY_D', 'warehouseReceipt', 'Warehouse Receipt',
             'warehouseReceipt', 3, 'Query', 'N'
            );

-- DGM SCRIPTS FOR Assay (Sales) Population
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_SA_ASSAY_D', 'shipmentAdvise', 'Shipment Advice',
             'shipmentAdvise', 3, 'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM_RA_ASSAY_D', 'railAdvice', 'Rail Advice', 'railAdvice', 3,
             'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM_AA_ASSAY_D', 'airAdvice', 'Air Advice', 'airAdvice', 3,
             'Query', 'N'
            );
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_TA_ASSAY_D', 'truckAdvice', 'Truck Advice', 'truckAdvice',
             3, 'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_RO_ASSAY_D', 'releaseOrder', 'Release Order',
             'releaseOrder', 3, 'Query', 'N'
            );

-- DGM SCRIPTS FOR Purcahse Phyical Attribute Population At Stock Level
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_SD_PQPA_D', 'shipmentDetail', 'Shipment Detail',
             'shipmentDetail', 4, 'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM_RD_PQPA_D', 'railDetail', 'Rail Detail', 'railDetail', 4,
             'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM_AD_PQPA_D', 'airDetail', 'Air Detail', 'airDetail', 4,
             'Query', 'N'
            );
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_TD_PQPA_D', 'truckDetail', 'Truck Detail', 'truckDetail',
             4, 'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_WR_PQPA_D', 'warehouseReceipt', 'Warehouse Receipt',
             'warehouseReceipt', 4, 'Query', 'N'
            );

-- DGM SCRIPTS FOR Sales Phyical Attribute Population At Stock Level
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_SA_PQPA_D', 'shipmentAdvise', 'Shipment Advice',
             'shipmentAdvise', 4, 'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM_RA_PQPA_D', 'railAdvice', 'Rail Advice', 'railAdvice', 4,
             'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM_AA_PQPA_D', 'airAdvice', 'Air Advice', 'airAdvice', 4,
             'Query', 'N'
            );
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id,
             sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_TA_PQPA_D', 'truckAdvice', 'Truck Advice', 'truckAdvice',
             4, 'Query', 'N'
            );

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name,
             activity_id, sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM_RO_PQPA_D', 'releaseOrder', 'Release Order',
             'releaseOrder', 4, 'Query', 'N'
            );


-- For All Purchse Side First Activity (Ship,Rail,Truck,Air)

DECLARE
   fetchquerysdd   CLOB
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
   SELECT '''', akc.corporate_name buyer, pcm.issue_date contractdate,
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
          cym.country_name dischargecountry, cim.city_name, vd.etd etaend,
          vd.eta etastart, '''', '''',
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
          vd.vessel_voyage_name vesselname, gmr.bl_date bldate,
          gmr.bl_no blnumber, f_format_to_char (gmr.qty, 4) blqty,
          qumbl.qty_unit blqtyunit, '''', '''', gmr.created_date createddate,
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
          cym_vdl.country_name loading_airport, vd.loading_date loading_date,
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
          vd.shippers_ref_no truck_number, sd.bl_date cmr_date,
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
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysdd
    WHERE dgm.dgm_id IN ('5', '8', '9', '7');
END;

-- For WareHouse Receipt

DECLARE
   fetchquerysdd_wrd   CLOB
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
   SELECT '''' attention, akc.corporate_name buyer, pcm.issue_date contractdate,
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
          wrd.storage_date bldate, gmr.bl_no blnumber, gmr.qty blqty,
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
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysdd_wrd
    WHERE dgm.dgm_id IN ('6');
END;

-- For Landing 

DECLARE
   fetchquery_lan   CLOB
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
   SELECT '''' attention, phd.companyname buyer, pcm.issue_date contractdate,
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
          cym.country_name dischargecountry, cim.city_name, vd.etd etaend,
          vd.eta etastart, '''' fulfilment_type, '''' goods,
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
          wrd.storage_date bldate, gmr.bl_no blnumber, gmr.qty blqty,
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
          vd.loading_date loading_date, '''' endorsements,
          '''' other_airway_billing_item, vd.no_of_pieces no_of_pieces,
          vd.nature_of_goods nature_of_good, vd.dimensions dimensions, '''',
          gmr.qty net_weight, gmr.total_tare_weight tare_weight,
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
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquery_lan
    WHERE dgm.dgm_id IN ('24');
END;

-- For sddpqpa_d Poulation Purchase DGM QUERY (shipDetail,RailDetail,TruckDetail,AirDetail,WarhouseReceipt)

DECLARE
   fetchquery_pqpa   CLOB
      := 'INSERT INTO sddpqpa_d
            (internal_doc_ref_no, internal_gmr_ref_no, internal_grd_ref_no,stock_ref_no,
             attribute_id, attribute_name, attribute_value)
   SELECT ?, gmr.internal_gmr_ref_no internal_gmr_ref_no,
          agrd.internal_grd_ref_no,agrd.internal_stock_ref_no stock_ref_no ,pqpa.attribute_id, aml.attribute_name,
          pqpa.attribute_value
     FROM agrd_action_grd agrd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          pqpa_pq_physical_attributes pqpa,
          aml_attribute_master_list aml
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND pqpa.phy_attribute_group_no(+) = agrd.pqpa_phy_attribute_group_no
      AND aml.attribute_id = pqpa.attribute_id
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.action_no = agrd.action_no
      AND agmr.gmr_latest_action_action_id IN
             (''shipmentDetail'', ''airDetail'', ''truckDetail'', ''railDetail'',
              ''warehouseReceipt'')
      AND agmr.is_deleted = ''N''
      AND agrd.is_deleted = ''N''
      AND agmr.internal_gmr_ref_no = ?';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquery_pqpa
    WHERE dgm.dgm_id IN
             ('DGM_SD_PQPA_D', 'DGM_TD_PQPA_D', 'DGM_RD_PQPA_D',
              'DGM_AD_PQPA_D', 'DGM_WR_PQPA_D');
END;

-- For All Sales Side First Activity (ShipAdvise,Rail,Truck,Air)

DECLARE
   fetchquerysad_sales   CLOB
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
   SELECT '''''''', pci.cp_name buyer, pci.issue_date contractdate,
          pci.contract_item_ref_no contractitemno,
          f_format_to_char (pcpd.qty_max_val, 4) contractqty,
          qum.qty_unit contractqtyunit, pci.contract_ref_no contractrefno,
          pci.cp_contract_ref_no, cym.country_name dischargecountry,
          cim.city_name port_name, vd.etd etaend, vd.eta etastart, '''', '''',
          pci.incoterm incoterm,
          pci.internal_contract_item_ref_no internalcontractitemrefno, ?,
          gmr.internal_gmr_ref_no internalgmrrefno, '''''''',
          TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') issue_date,
          cyml.country_name loadingcountry, cim_load.city_name loadingport,
          '''', '''' packing_type, f_format_to_char (gmr.qty, 4) qty_of_goods,
          qumbl.qty_unit qty_of_goods_unit, akc.corporate_name seller, '''',
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, vd.vessel_voyage_name vesselname,
          gmr.bl_date bldate, gmr.bl_no blnumber,
          f_format_to_char (gmr.qty, 4) blqty, qumbl.qty_unit blqtyunit, '''',
          '''', gmr.created_date createddate,
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
          '''''''', TO_CHAR (axs.action_date, ''dd-Mon-yyyy'') activity_date,
          vd.voyage_number flight_number,
          cym_vd.country_name destination_airport,
          TO_CHAR (sad.bl_date, ''dd-Mon-yyyy'') awb_date, sad.bl_no awb_number,
          f_format_to_char (gmr.qty, 4) awb_quantity, '''''''',
          vd.loading_date loading_date, vd.carriers_agents_endorsements, '''',
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
          vd.shippers_ref_no truck_number, sad.bl_date cmr_date,
          sad.bl_no cmr_number, f_format_to_char (gmr.qty, 4) cmr_quantity,
          '''', vd.comments trucking_instructions,
          sm_load.state_name loading_state,
          sm_dis.state_name destination_state,
          cym_tran.country_name trans_shipment_country,
          sm_tran.state_name trans_shipment_state, phd_supp.companyname supp_rep,
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
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysad_sales
    WHERE dgm.dgm_id IN ('1', '2', '3', '4');
END;

-- For Release Order 

DECLARE
   fetchquerysad_rosales   CLOB
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
   SELECT '''', pci.cp_name buyer, pci.issue_date contractdate,
          pci.contract_item_ref_no contractitemno,
          f_format_to_char (pcpd.qty_max_val, 4) contractqty,
          qum.qty_unit contractqtyunit, pci.contract_ref_no contractrefno,
          pci.cp_contract_ref_no cprefno, pci.incoterm incoterm,
          pci.internal_contract_item_ref_no internalcontractitemrefno, ?,
          gmr.internal_gmr_ref_no internalgmrrefno, '''''''',
          TO_CHAR (rod.release_date, ''dd-Mon-yyyy'') issue_date, '''', '''', '''',
          '''' packing_type, f_format_to_char (gmr.qty, 4) qty_of_goods,
          qumbl.qty_unit qty_of_goods_unit, akc.corporate_name seller, '''',
          pcpd.max_tolerance maxtolerance, pcpd.min_tolerance mintolerance,
          pcpd.tolerance_type tolerancetype, gmr.created_date createddate,
          pci.incoterm_location parity_location,
          pci.product_name || '','' || pci.quality_name productandquality, '''',
          phdi.companyname issuer, rod.notes notes,
          rod.special_instructions specialinst,
          f_format_to_char (gmr.qty, 4) quantity,
          qumbl.qty_unit quantity_unit,
          TO_CHAR (axs.action_date, ''dd-Mon-yyyy'') activity_date, '''', '''', '''',
          '''', '''', '''''''', '''', '''', '''', '''', '''', '''',
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
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysad_rosales
    WHERE dgm.dgm_id IN ('DGM_RO_SAD_D');
END;

-- For sddpqpa_d Poulation Sales DGM QUERY (shipAdvice,RailAdvice,TruckAdvice,AirAdvice,releaseOrder)

DECLARE
   fetchquerysales_pqpa   CLOB
      := 'INSERT INTO sddpqpa_d
            (internal_doc_ref_no, internal_gmr_ref_no, internal_grd_ref_no,stock_ref_no,
             attribute_id, attribute_name, attribute_value)
     SELECT ?, gmr.internal_gmr_ref_no internal_gmr_ref_no,
       adgrd.internal_dgrd_ref_no internal_grd_ref_no,adgrd.internal_stock_ref_no stock_ref_no, pqpa.attribute_id,
       aml.attribute_name, pqpa.attribute_value
  FROM adgrd_action_dgrd adgrd,
       gmr_goods_movement_record gmr,
       agmr_action_gmr agmr,
       pqpa_pq_physical_attributes pqpa,
       aml_attribute_master_list aml
 WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   AND pqpa.phy_attribute_group_no(+) = adgrd.phy_attribute_group_no
   AND aml.attribute_id = pqpa.attribute_id
   AND adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   AND agmr.action_no = adgrd.action_no
   AND agmr.gmr_latest_action_action_id IN
          (''shipmentAdvise'', ''railAdvice'', ''airAdvice'', ''truckAdvice'',
           ''releaseOrder'')
   AND agmr.is_deleted = ''N''
   AND adgrd.status = ''Active''
   AND agmr.internal_gmr_ref_no = ?';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquerysales_pqpa
    WHERE dgm.dgm_id IN
             ('DGM_SA_PQPA_D', 'DGM_TA_PQPA_D', 'DGM_RA_PQPA_D',
              'DGM_AA_PQPA_D', 'DGM_RO_PQPA_D');
END;

-- For SDDASSAY_D Poulation DGM QUERY  For All Purchase And Sales  

DECLARE
   fetchquery_assay   CLOB
      := 'INSERT INTO sddassay_d
            (internal_doc_ref_no, internal_gmr_ref_no, internal_stock_id,
             stock_ref_no, element_id, element_name, typical, unit_of_measure,
             ratio_name, assay_type, net_weight, dry_weight, qty_unit_name)
         SELECT ?, temp.internal_gmr_ref_no internal_gmr_ref_no,
       temp.internal_stock_id internal_stock_id,
       temp.stock_ref_no stock_ref_no, temp.element_id,
       temp.element_name element_name, temp.typical, temp.unit_of_measure,
       temp.ratio_name, temp.assay_type, temp.net_weight, temp.dry_weight,
       temp.qty_unit_name
  FROM (SELECT '''', gmr.internal_gmr_ref_no internal_gmr_ref_no,
               '''' internal_stock_id, '''' stock_ref_no, pqca.element_id,
               aml.attribute_name element_name, pqca.typical,
               pqca.unit_of_measure, rm.ratio_name, ash.assay_type,
               '''' net_weight, '''' dry_weight, '''' qty_unit_name
          FROM ash_assay_header ash,
               gmr_goods_movement_record gmr,
               asm_assay_sublot_mapping asm,
               pqca_pq_chemical_attributes pqca,
               aml_attribute_master_list aml,
               rm_ratio_master rm
         WHERE asm.ash_id = ash.ash_id
           AND gmr.internal_contract_ref_no = ash.internal_contract_ref_no
           AND pqca.asm_id = asm.asm_id
           AND aml.attribute_id = pqca.element_id
           AND rm.ratio_id = pqca.unit_of_measure
           AND pqca.is_elem_for_pricing = ''Y''
           AND ash.assay_type = ''Contractual Assay''
           AND ash.is_active = ''Y''
        UNION
        SELECT '''', ash.internal_gmr_ref_no internal_gmr_ref_no,
               ash.internal_grd_ref_no internal_stock_id,
               ash.lot_no stock_ref_no, pqca.element_id,
               aml.attribute_name element_name, pqca.typical,
               pqca.unit_of_measure, rm.ratio_name, ash.assay_type,
               TO_CHAR (ash.net_weight) net_weight,
               TO_CHAR (ash.dry_weight) dry_weight,
               ash.qty_unit_name qty_unit_name
          FROM ash_assay_header ash,
               asm_assay_sublot_mapping asm,
               pqca_pq_chemical_attributes pqca,
               aml_attribute_master_list aml,
               rm_ratio_master rm
         WHERE asm.ash_id = ash.ash_id
           AND pqca.asm_id = asm.asm_id
           AND aml.attribute_id = pqca.element_id
           AND rm.ratio_id = pqca.unit_of_measure
           AND ash.assay_type = ''Provisional Assay''
           AND ash.is_active = ''Y'') temp
 WHERE temp.internal_gmr_ref_no = ?';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchquery_assay
    WHERE dgm.dgm_id IN
             ('DGM_SD_ASSAY_D', 'DGM_TD_ASSAY_D', 'DGM_RD_ASSAY_D',
              'DGM_AD_ASSAY_D', 'DGM_WR_ASSAY_D', 'DGM_SA_ASSAY_D',
              'DGM_TA_ASSAY_D', 'DGM_RA_ASSAY_D', 'DGM_AA_ASSAY_D',
              'DGM_RO_ASSAY_D');
END;
