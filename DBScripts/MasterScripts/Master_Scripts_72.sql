/************************************************************************************/
ShipmentDetails,AirDetails,RailDetails and TruckDetails Document's Query for DGM table
/*************************************************************************************/
NOTE:- This below insert query need to put manually for DGM_ID 5,7,8,9  in FETCH_QUERY column.

INSERT INTO SDD_D(
ATTENTION,
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
TRUCKING_INSTRUCTIONS
)

SELECT '',
       phd.companyname buyer,
       pcm.issue_date contractdate,
       (SELECT f_string_aggregate(pci.contract_item_ref_no)
        FROM   v_pci           pci,
               agrd_action_grd agrd
        WHERE  pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
        AND    agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    agrd.action_no = agmr.action_no
        AND    agrd.is_deleted = 'N') contractitemno,
       pcpd.qty_max_val contractqty,
       qum.qty_unit contractqtyunit,
       pcm.contract_ref_no contractrefno,
       pcm.cp_contract_ref_no,
       cym.country_name destination_location,
       cym.country_name dischargecountry,
       cim.city_name port_name,
       vd.etd etaend,
       vd.eta etastart,
       '',
       '',
       (SELECT f_string_aggregate(pci.incoterm)
        FROM   v_pci           pci,
               agrd_action_grd agrd
        WHERE  pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
        AND    agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    agrd.action_no = agmr.action_no
        AND    agrd.is_deleted = 'N') incoterm,
       (SELECT f_string_aggregate(pci.internal_contract_item_ref_no)
        FROM   v_pci           pci,
               agrd_action_grd agrd
        WHERE  pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
        AND    agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    agrd.action_no = agmr.action_no
        AND    agrd.is_deleted = 'N') internalcontractitemrefno,
      ?,
       gmr.internal_gmr_ref_no internalgmrrefno,
       '',
       sd.bl_date issue_date,
       cyml.country_name loadingcountry,
       cyml.country_name loading_location,
       cim_load.city_name loadingport,
       '''',
       '' packing_type,
       (SELECT SUM(pkg_general.f_get_converted_quantity(agrd.product_id,
                                                        agrd.qty_unit_id,
                                                        gmr.qty_unit_id,
                                                        agrd.qty))
        FROM   agrd_action_grd agrd
        WHERE  agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    agrd.action_no = agmr.action_no
        AND    agrd.is_deleted = 'N') qty_of_goods,
       qumbl.qty_unit,
       phd_seller.companyname seller,
       '''',
       pcpd.max_tolerance maxtolerance,
       pcpd.min_tolerance mintolerance,
       pcpd.tolerance_type tolerancetype,
       vd.vessel_voyage_name vesselname,
       gmr.bl_date bldate,
       gmr.bl_no blnumber,
       gmr.qty blqty,
       qumbl.qty_unit blqtyunit,
       '''',
       '''',
       gmr.created_date createddate,
       (SELECT f_string_aggregate(pci.incoterm_location)
        FROM   v_pci           pci,
               agrd_action_grd agrd
        WHERE  pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
        AND    agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    agrd.action_no = agmr.action_no
        AND    agrd.is_deleted = 'N') parity_location,
       
       (SELECT f_string_aggregate(pdm.product_desc || ' ' || qat.quality_name)
        FROM   pdm_productmaster      pdm,
               qat_quality_attributes qat,
               agrd_action_grd        agrd
        WHERE  agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    agrd.action_no = agmr.action_no
        AND    agrd.is_deleted = 'N'
        AND    pdm.product_id = agrd.product_id
        AND    qat.quality_id = agrd.quality_id) productandquality,
       phdnp.companyname notifyparty,
       phd_ship.companyname shipper,
       vd.notes notes,
       vd.special_instructions specialinst,
       vd.voyage_number voyagenumber,
       vd.shippers_ref_no shipperrefno,
       cim_trans.city_name transport,
       TO_CHAR(vd.eta, 'dd-Mon-yyyy') etadestinationport,
       vd.shippers_instructions shippersinstructions,
       vd.carriers_agents_endorsements carrieragentsendorsements,
       '''',
       (SELECT f_string_aggregate(agrd.no_of_containers)
        FROM   agrd_action_grd agrd
        WHERE  agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    agrd.action_no = agmr.action_no
        AND    agrd.is_deleted = 'N') container_nos,
       gmr.qty quantity,
       qum_gmr.qty_unit quantity_unit,
       qum_gmr.decimals quantity_decimals,
       gmr.current_qty net_weignt_gmr,
       qum_gmr.qty_unit net_weight_unit_gmr,
       qum_gmr.decimals decimals,
       ((to_char(gmr.bl_date,
                 'dd-Mon-yyyy')) || ' ' || gmr.bl_no) bldate_blno,
       qum_gmr.decimals bl_quantity_decimals,
       to_char(axs.action_date,
               'dd-Mon-yyyy') activity_date,
       vd.voyage_number flight_number,
       cym_vd.country_name destination_airport,
       to_char(sd.bl_date,
               'dd-Mon-yyyy') awb_date,
       sd.bl_no awb_number,
       gmr.qty awb_quantity,
       cym_vdl.country_name loading_airport,
       vd.loading_date loading_date,
       '''',
       '''',
       vd.no_of_pieces no_of_pieces,
       vd.nature_of_goods nature_of_good,
       vd.dimensions dimensions,
       '',
       gmr.qty net_weight,
       gmr.total_tare_weight tare_weight,
       gmr.total_gross_weight gross_weight,
       '''',
       sd.internal_remarks comments,
       '',
       '',
       '',
       '',
       '',
       (vd.vessel_voyage_name || ' ' || vd.voyage_number) rail_name_number,
       to_char(sd.bl_date,
               'dd-Mon-yyyy') rr_date,
       sd.bl_no rr_number,
       gmr.qty total_qty,
       gmr.qty rr_qty,
       vd.shippers_ref_no truck_number,
       sd.bl_date cmr_date,
       sd.bl_no cmr_number,
       gmr.qty cmr_quantity,
       '''',
       vd.comments trucking_instructions
FROM   gmr_goods_movement_record  gmr,
       agmr_action_gmr            agmr,
       sd_shipment_detail         sd,
       pcm_physical_contract_main pcm,
       phd_profileheaderdetails   phd,
       phd_profileheaderdetails   phd_ship,
       phd_profileheaderdetails   phd_seller,
       vd_voyage_detail           vd,
       pcpd_pc_product_definition pcpd,
       qum_quantity_unit_master   qum,
       qum_quantity_unit_master   qum_gmr,
       qum_quantity_unit_master   qumbl,
       cym_countrymaster          cym,
       cym_countrymaster          cyml,
       pmt_portmaster             pmt_vd,
       axs_action_summary         axs,
       gab_globaladdressbook      gab,
       phd_profileheaderdetails   phdnp,
       CIM_CITYMASTER             cim,
       cim_citymaster             cim_trans,
       cim_citymaster             cim_load,
       cym_countrymaster          cym_vd,
       cym_countrymaster          cym_vdl
WHERE  gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
AND    agmr.gmr_latest_action_action_id IN
       ('shipmentDetail', 'airDetail', 'truckDetail', 'railDetail')
AND    agmr.is_deleted = 'N'
AND    sd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
AND    sd.action_no = agmr.action_no
AND    vd.internal_gmr_ref_no = sd.internal_gmr_ref_no
AND    vd.action_no = sd.action_no
AND    agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
AND    pcm.cp_id = phd.profileid
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.qty_unit_id = qum.qty_unit_id
AND    gmr.discharge_country_id = cym.country_id
AND    vd.discharge_city_id = cim.city_id(+)
AND    gmr.loading_country_id = cyml.country_id
AND    vd.loading_city_id = cim_load.city_id(+)
AND    gmr.qty_unit_id = qumbl.qty_unit_id
AND    gmr.internal_action_ref_no = axs.internal_action_ref_no
AND    sd.notify_party_id = gab.gabid
AND    sd.consignee_id = phd_seller.profileid(+)
AND    gab.profileid = phdnp.profileid(+)
AND    vd.trans_shipment_city_id = cim_trans.city_id(+)
AND    vd.discharge_port_id = pmt_vd.port_id(+)
AND    vd.discharge_country_id = cym_vd.country_id(+)
AND    vd.loading_country_id = cym_vdl.country_id(+)
AND    gmr.shipping_line_profile_id = phd_ship.profileid
AND    gmr.qty_unit_id = qum_gmr.qty_unit_id
AND    gmr.internal_gmr_ref_no = ?
