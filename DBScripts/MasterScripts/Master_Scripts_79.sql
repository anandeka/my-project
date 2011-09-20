Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID)
 Values
   ('salesWeightNote', 'Weight Note Sales', 59, NULL, 'Y', 
    'N', NULL);

Insert into ADM_ACTION_DOCUMENT_MASTER
   (ADM_ID, ACTION_ID, DOC_ID, IS_DELETED)
 Values
   ('ADM-SWN-1', 'salesWeightNote', 'salesWeightNote', 'N');


Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('SWN_KEY_1', 'Weight Note Sales', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');


Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('17', 'salesWeightNote', 'Sales Weight Note', 'salesWeightNote', 1, 
    'null', 'N');


/******************************************************************************/
Fetch Query For DGM_ID =17 (Sales Weight Note)
/********************************************************************************/

INSERT INTO SAD_D(
ATTENTION,
BUYER,
CONTRACT_DATE,
CONTRACT_ITEM_NO,
CONTRACT_QTY,
CONTRACT_QTY_UNIT,
CONTRACT_REF_NO,
CP_REF_NO,
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
SELECT '''',
       phd.companyname buyer,
       to_char(pcm.issue_date,
               'dd-Mon-yyyy') contractdate,
       (SELECT f_string_aggregate(pci.contract_item_ref_no)
        FROM   v_pci           pci,
               adgrd_action_dgrd adgrd
        WHERE  pci.internal_contract_item_ref_no =
               adgrd.internal_contract_item_ref_no
        AND    adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active'  ) contractitemno,
       pcpd.qty_max_val contractqty,
       qum.qty_unit contractqtyunit,
       pcm.contract_ref_no contractrefno,
       pcm.cp_contract_ref_no,
       cym.country_name dischargecountry,
       pmt.port_name,
       to_char(vd.etd,
               'dd-Mon-yyyy') etaend,
       to_char(vd.eta,
               'dd-Mon-yyyy') etastart,
       '''',
       (SELECT f_string_aggregate(qat.quality_name)
        FROM   qat_quality_attributes qat,
               adgrd_action_dgrd        adgrd
        WHERE  adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active'
        AND    qat.quality_id = adgrd.quality_id) goods,
       (SELECT f_string_aggregate(itm.incoterm)
        FROM   adgrd_action_dgrd            adgrd,
               pci_physical_contract_item pci,
               pcdb_pc_delivery_basis     pcdb,
               itm_incoterm_master        itm
        WHERE  adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active'
        AND    pci.internal_contract_item_ref_no =
               adgrd.internal_contract_item_ref_no
        AND    pcdb.pcdb_id = pci.pcdb_id
        AND    itm.incoterm_id = pcdb.inco_term_id) incoterm,
       (SELECT f_string_aggregate(pci.internal_contract_item_ref_no)
        FROM   v_pci           pci,
               adgrd_action_dgrd adgrd
        WHERE  pci.internal_contract_item_ref_no =
               adgrd.internal_contract_item_ref_no
        AND    adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active') internalcontractitemrefno,
       ?,
       gmr.internal_gmr_ref_no internalgmrrefno,
       '''',
       to_char(wn.issue_date,
               'dd-Mon-yyyy') issue_date,
       cyml.country_name loadingcountry,
       pmtl.port_name loadingport,
       '''',
       '''',
       (SELECT SUM(pkg_general.f_get_converted_quantity(adgrd.product_id,
                                                        adgrd.net_weight_unit_id,
                                                        gmr.qty_unit_id,
                                                        adgrd.net_weight))
        FROM   adgrd_action_dgrd adgrd
        WHERE  adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active') qty_of_goods,
       qumbl.qty_unit,
       ak.corporate_name seller,
       '''',
       pcpd.max_tolerance maxtolerance,
       pcpd.min_tolerance mintolerance,
       pcpd.tolerance_type tolerancetype,
       vd.vessel_voyage_name vesselname,
       to_char(gmr.bl_date,
               'dd-Mon-yyyy') bldate,
       gmr.bl_no blnumber,
       gmr.qty blqty,
       qumbl.qty_unit blqtyunit,
       '''',
       '''',
       to_char(gmr.created_date,
               'dd-Mon-yyyy') createddate,
       (SELECT f_string_aggregate(pci.incoterm_location)
        FROM   v_pci           pci,
               adgrd_action_dgrd adgrd
        WHERE  pci.internal_contract_item_ref_no =
               adgrd.internal_contract_item_ref_no
        AND    adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active') parity_location,
       (SELECT f_string_aggregate(pdm.product_desc || ' ' || qat.quality_name)
        FROM   pdm_productmaster      pdm,
               qat_quality_attributes qat,
               adgrd_action_dgrd        adgrd
        WHERE  adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active'
        AND    pdm.product_id = adgrd.product_id
        AND    qat.quality_id = adgrd.quality_id) product_quality,
       '''',
       '''',
       vd.notes notes,
       vd.special_instructions specialinst,
       vd.voyage_number voyagenumber,
       vd.shippers_ref_no shipperrefno,
       pmtts.port_name transport,
       '''',
       '''',
       '''',
       '''',
       '''',
       gmr.qty quantity,
       qumbl.qty_unit quantity_unit,
       qumbl.decimals quantity_decimals,
       gmr.current_qty net_weignt_gmr,
       qumbl.qty_unit net_weight_unit_gmr,
       qumbl.decimals decimals,
       ((to_char(gmr.bl_date,
                 'dd-Mon-yyyy')) || ' ' || gmr.bl_no) bldate_blno,
       qumbl.decimals bl_quantity_decimals,
       to_char(agmr.eff_date,
               'dd-Mon-yyyy') activity_date,
       vd.voyage_number flight_number,
       '''',
       '''',
       '''',
       gmr.qty awb_quantity,
       '''',
       vd.loading_date loading_date,
       '''',
       '''',
       '''',
       '''',
       '''',
       (SELECT f_string_aggregate(adgrd.internal_stock_ref_no)
        FROM   adgrd_action_dgrd adgrd
        WHERE  adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active') stock_ref_no,
       (SELECT SUM(pkg_general.f_get_converted_quantity(adgrd.product_id,
                                                        adgrd.net_weight_unit_id,
                                                        gmr.qty_unit_id,
                                                        adgrd.net_weight)) net_weight
        FROM   adgrd_action_dgrd adgrd
        WHERE  adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active') net_weight,
       (SELECT SUM(pkg_general.f_get_converted_quantity(adgrd.product_id,
                                                        adgrd.net_weight_unit_id,
                                                        gmr.qty_unit_id,
                                                        adgrd.tare_weight)) tare_weight
        FROM   adgrd_action_dgrd adgrd
        WHERE  adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active') tare_weight,
       (SELECT SUM(pkg_general.f_get_converted_quantity(adgrd.product_id,
                                                        adgrd.net_weight_unit_id,
                                                        gmr.qty_unit_id,
                                                        adgrd.gross_weight)) gross_weight
        FROM   adgrd_action_dgrd adgrd
        WHERE  adgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        AND    adgrd.action_no = agmr.action_no
        AND    adgrd.status = 'Active') gross_weight,
       '''',
       '''',
       wn.activity_ref_no,
       phd_w.companyname weigher,
       wn.weight_note_no,
       to_char(wn.weighing_date,
               'dd-Mon-yyyy') weighing_date,
       '''',
       '''',
       '''',
       '''',
       gmr.qty total_qty,
       gmr.qty rr_qty,
       '''',
       '''',
       '''',
       gmr.qty cmr_quantity,
       '''',
       ''''
FROM   pcm_physical_contract_main pcm,
       pcpd_pc_product_definition pcpd,
       gmr_goods_movement_record  gmr,
       agmr_action_gmr            agmr,
       phd_profileheaderdetails   phd,
       phd_profileheaderdetails   phd_w,
       qum_quantity_unit_master   qumbl,
       qum_quantity_unit_master   qum,
       ak_corporate               ak,
       wnd_weight_note_detail     wn,
       pmt_portmaster             pmt,
       vd_voyage_detail           vd,
       cym_countrymaster          cym,
       cym_countrymaster          cyml,
       pmt_portmaster             pmtl,
       pmt_portmaster             pmtts
WHERE  gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
AND    agmr.gmr_latest_action_action_id = 'salesWeightNote'
AND    agmr.is_deleted = 'N'
AND    pcm.internal_contract_ref_no = agmr.internal_contract_ref_no
AND    phd.profileid = pcm.cp_id
AND    pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
AND    pcpd.is_active = 'Y'
AND    qum.qty_unit_id = pcpd.qty_unit_id
AND    gmr.discharge_country_id = cym.country_id
AND    gmr.qty_unit_id = qumbl.qty_unit_id
AND    ak.corporate_id = gmr.corporate_id
AND    gmr.discharge_port_id = pmt.port_id(+)
AND    gmr.loading_country_id = cyml.country_id(+)
AND    gmr.loading_port_id = pmtl.port_id(+)
AND    vd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    vd.trans_shipment_port_id = pmtts.port_id(+)
AND    wn.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    wn.action_no = agmr.action_no
AND    wn.weigher_profile_id = phd_w.profileid(+)
AND    gmr.internal_gmr_ref_no = ?