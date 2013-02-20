
declare
fetchqry clob := 'Insert into SDD_D
  (ATTENTION,
   BUYER,
   CONTRACT_DATE,
   CONTRACT_ITEM_NO,
   CONTRACT_QTY,
   CONTRACT_QTY_UNIT,
   CONTRACT_REF_NO,
   CP_REF_NO,
   DESTINATION_LOCATION,
   DISCHARGE_COUNTRY,
   DISCHARGE_PORT,
   ETA_END,
   ETA_START,
   FULFILMENT_TYPE,
   GOODS,
   INCO_TERMS,
   INTERNAL_CONTRACT_ITEM_REF_NO,
   INTERNAL_DOC_REF_NO,
   INTERNAL_GMR_REF_NO,
   IS_OTHER_OPTIONAL_PORTS,
   ISSUE_DATE,
   LOADING_COUNTRY,
   LOADING_LOCATION,
   LOADING_PORT,
   OTHER_SHIPMENT_TERMS,
   PACKING_TYPE,
   QTY_OF_GOODS,
   QTY_OF_GOODS_UNIT,
   SELLER,
   TOLERANCE_LEVEL,
   TOLERANCE_MAX,
   TOLERANCE_MIN,
   TOLERANCE_TYPE,
   VESSEL_NAME,
   BL_DATE,
   BL_NUMBER,
   BL_QUANTITY,
   BL_QUANTITY_UNIT,
   OPTIONAL_DESTIN_PORTS,
   OPTIONAL_ORIGIN_PORTS,
   CREATED_DATE,
   PARITY_LOCATION,
   PRODUCTANDQUALITY,
   NOTIFYPARITY,
   SHIPPER,
   NOTES,
   SPECIALINSTRUCTIONS,
   VOYAGENUMBER,
   SHIPPERREFNO,
   TRANSSHIPMENTPORT,
   ETADESTINATIONPORT,
   SHIPPERSINSTRUCTIONS,
   CARRIERAGENTSENDORSEMENTS,
   WHOLENEWREPORT,
   CONTAINER_NOS,
   QUANTITY,
   QUANTITY_UNIT,
   QUANTITY_DECIMALS,
   NET_WEIGNT_GMR,
   NET_WEIGHT_UNIT_GMR,
   DECIMALS,
   BLDATE_BLNO,
   BL_QUANTITY_DECIMALS,
   ACTIVITY_DATE,
   FLIGHT_NUMBER,
   DESTINATION_AIRPORT,
   AWB_DATE,
   AWB_NUMBER,
   AWB_QUANTITY,
   LOADING_AIRPORT,
   LOADING_DATE,
   ENDORSEMENTS,
   OTHER_AIRWAY_BILLING_ITEM,
   NO_OF_PIECES,
   NATURE_OF_GOOD,
   DIMENSIONS,
   STOCK_REF_NO,
   NET_WEIGHT,
   TARE_WEIGHT,
   GROSS_WEIGHT,
   COMMODITY_DESCRIPTION,
   COMMENTS,
   ACTIVITY_REF_NO,
   WEIGHER,
   WEIGHER_NOTE_NO,
   WEIGHING_DATE,
   REMARKS,
   RAIL_NAME_NUMBER,
   RR_DATE,
   RR_NUMBER,
   TOTAL_QTY,
   RR_QTY,
   TRUCK_NUMBER,
   CMR_DATE,
   CMR_NUMBER,
   CMR_QUANTITY,
   OTHER_TRUCKING_TERMS,
   TRUCKING_INSTRUCTIONS,
   CP_ADDRESS,
   CP_LOCATION,
   ISSUER,
   ISSUER_REF_NO,
   ISSUER_ADDRESS,
   CONSIGNEE,
   CONSIGNEE_REF_NO,
   CONSIGNEE_ADDRESS,
   WAREHOUSE_AND_SHED,
   WAREHOUSE_ADDRESS,
   MOVEMENT)

SELECT '''' ATTENTION,
         akc.corporate_name buyer,
         pcm.issue_date contractdate,
         (SELECT f_string_aggregate(pci.contract_item_ref_no)
            FROM v_pci pci, agrd_action_grd agrd
           WHERE pci.internal_contract_item_ref_no =
                 agrd.internal_contract_item_ref_no
             AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') contractitemno,
         pcpd.qty_max_val contractqty,
         qum.qty_unit contractqtyunit,
         pcm.contract_ref_no contractrefno,
         pcm.cp_contract_ref_no,
         '''' destination_location,
         '''' dischargecountry,
         '''' discharge_port,
         '''' etaend,
         '''' etastart,
         '''' FULFILMENT_TYPE,
         '''' GOODS,
         (SELECT f_string_aggregate(pci.incoterm)
            FROM v_pci pci, agrd_action_grd agrd
           WHERE pci.internal_contract_item_ref_no =
                 agrd.internal_contract_item_ref_no
             AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') incoterm,
         (SELECT f_string_aggregate(pci.internal_contract_item_ref_no)
            FROM v_pci pci, agrd_action_grd agrd
           WHERE pci.internal_contract_item_ref_no =
                 agrd.internal_contract_item_ref_no
             AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') internalcontractitemrefno,
          ?,
         gmr.internal_gmr_ref_no internalgmrrefno,
         '''' IS_OTHER_OPTIONAL_PORTS,
         wrd.issue_date issue_date,
         '''' loadingcountry,
         '''' loading_location,
         '''' loadingport,
         '''' OTHER_SHIPMENT_TERMS,
         '''' packing_type,
         (SELECT SUM(pkg_general.f_get_converted_quantity(agrd.product_id,
                                                          agrd.qty_unit_id,
                                                          gmr.qty_unit_id,
                                                          agrd.qty))
            FROM agrd_action_grd agrd
           WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') qty_of_goods,
         qumbl.qty_unit,
         phdnp.companyname seller,
         '''' TOLERANCE_LEVEL,
         pcpd.max_tolerance maxtolerance,
         pcpd.min_tolerance mintolerance,
         pcpd.tolerance_type tolerancetype,
         '''' vesselname,
         wrd.storage_date bldate,
         gmr.bl_no blnumber,
         gmr.qty blqty,
         qumbl.qty_unit blqtyunit,
         '''' OPTIONAL_DESTIN_PORTS,
         '''' OPTIONAL_ORIGIN_PORTS,
         to_char(gmr.created_date, ''dd-Mon-yyyy'') createddate,
         (SELECT f_string_aggregate(pci.incoterm_location)
            FROM v_pci pci, agrd_action_grd agrd
           WHERE pci.internal_contract_item_ref_no =
                 agrd.internal_contract_item_ref_no
             AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') parity_location,
         
         (SELECT f_string_aggregate(pdm.product_desc || '' , '' ||
                                    qat.quality_name)
            FROM pdm_productmaster      pdm,
                 qat_quality_attributes qat,
                 agrd_action_grd        agrd
           WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N''
             AND pdm.product_id = agrd.product_id
             AND qat.quality_id = agrd.quality_id) productandquality,
         phdnp.companyname notifyparty,
         '''' shipper,
         wrd.notes notes,
         wrd.special_instructions specialinst,
         '''' voyagenumber,
         wrd.senders_ref_no shipperrefno,
         '''' transport,
         '''' etadestinationport,
         '''' shippersinstructions,
         '''' carrieragentsendorsements,
         '''' WHOLENEWREPORT,
         (SELECT f_string_aggregate(agrd.no_of_containers)
            FROM agrd_action_grd agrd
           WHERE agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             AND agrd.action_no = agmr.action_no
             AND agrd.is_deleted = ''N'') container_nos,
         gmr.qty quantity,
         qum_gmr.qty_unit quantity_unit,
         qum_gmr.decimals quantity_decimals,
         gmr.current_qty net_weignt_gmr,
         qum_gmr.qty_unit net_weight_unit_gmr,
         qum_gmr.decimals decimals,
         ((to_char(WRD.ARRIVAL_DATE, ''dd-Mon-yyyy'')) || '' , '' || WRD.WAREHOUSE_RECEIPT_NO) bldate_blno,
         qum_gmr.decimals bl_quantity_decimals,
         to_char(axs.action_date, ''dd-Mon-yyyy'') activity_date,
         '''' flight_number,
         '''' destination_airport,
         '''' awb_date,
         '''' awb_number,
         gmr.qty awb_quantity,
         '''' loading_airport,
         '''' loading_date,
         '''' ENDORSEMENTS,
         '''' OTHER_AIRWAY_BILLING_ITEM,
         '''' no_of_pieces,
         '''' nature_of_good,
         '''' dimensions,
         '''',
         gmr.qty net_weight,
         gmr.total_tare_weight tare_weight,
         gmr.total_gross_weight gross_weight,
         '''' COMMODITY_DESCRIPTION,
         wrd.internal_remarks comments,
         wrd.activity_ref_no ACTIVITY_REF_NO,
         '''' WEIGHER,
         '''' WEIGHER_NOTE_NO,
         '''' WEIGHING_DATE,
         wrd.notes REMARKS,
         '''' rail_name_number,
         '''' rr_date,
         '''' rr_number,
         gmr.qty total_qty,
         gmr.qty rr_qty,
         '''' truck_number,
         '''' cmr_date,
         '''' cmr_number,
         gmr.qty cmr_quantity,
         '''' OTHER_TRUCKING_TERMS,
         '''' trucking_instructions,
         (select max(pad.address)
            from pad_profile_addresses pad
           where pad.profile_id = pcm.cp_id
             and pad.address_type = ''Main'') cp_address,
         (select max(cim.city_name || '','' || cym.country_name)
            from pad_profile_addresses pad,
                 cim_citymaster        cim,
                 cym_countrymaster     cym
           where pad.profile_id = pcm.cp_id
             and pad.address_type = ''Main''
             and pad.city_id = cim.city_id(+)
             and pad.country_id = cym.country_id(+)) cp_location,
       phdi.companyname issuer,
       WRD.CARRIERS_REF_NO issuerrefno,
       WRD.ISSUERS_ADDRESS issueraddress,
       phdc.companyname consignee,
       WRD.CONSIGNEES_REF_NO consigneerefno,
       WRD.CONSIGNEE_ADDRESS consigneeaddress,
       shm.companyname || '','' || shm.shed_name warehouseandshed,
       '''' warehouseaddress,
       wrd.container_service_type movement
    FROM gmr_goods_movement_record    gmr,
         ak_corporate                 akc,
         wrd_warehouse_receipt_detail wrd,
         agmr_action_gmr              agmr,
         axs_action_summary           axs,
         phd_profileheaderdetails     phd,
         phd_profileheaderdetails     phdnp,
         pcm_physical_contract_main   pcm,
         pcpd_pc_product_definition   pcpd,
         qum_quantity_unit_master     qum,
         qum_quantity_unit_master     qumbl,
         qum_quantity_unit_master     qum_gmr,
         phd_profileheaderdetails       phdi,
         phd_profileheaderdetails       phdc,
         v_shm_shed_master              shm,
         cym_countrymaster              cym_shm,
         cim_citymaster                 cim_shm,
         sm_state_master                sm_shm
   WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and AKC.CORPORATE_ID = GMR.CORPORATE_ID
     And WRD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
     And WRD.ACTION_NO = AGMR.ACTION_NO
     And gmr.internal_action_ref_no = axs.internal_action_ref_no
     AND agmr.gmr_latest_action_action_id = ''warehouseReceipt''
     AND agmr.is_deleted = ''N''
     AND agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcm.cp_id = phd.profileid
     AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
     AND pcpd.qty_unit_id = qum.qty_unit_id
     AND gmr.qty_unit_id = qumbl.qty_unit_id
     AND wrd.sender_id = phdnp.profileid(+)
     AND gmr.qty_unit_id = qum_gmr.qty_unit_id
     and phdi.profileid(+) = WRD.SENDER_ID
     and phdc.profileid(+) = WRD.CONSIGNEE_ID
     and shm.profile_id = WRD.WAREHOUSE_PROFILE_ID
     and shm.shed_id = WRD.SHED_ID
     and shm.country_id = cym_shm.country_id
     and sm_shm.state_id(+) = shm.state_id
     and shm.city_id = cim_shm.city_id
     AND gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry where DGM_ID = '6';
  
end;