declare
fetchqry clob := 'INSERT INTO SDD_D(
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
TOLERANCE_UNIT,
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
select '''',
       akc.corporate_name buyer,
       pcm.issue_date contractdate,
       (select f_string_aggregate(pci.contract_item_ref_no)
        from   v_pci           pci,
               agrd_action_grd agrd
        where  pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
        and    agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        and    agrd.action_no = agmr.action_no
        and    agrd.is_deleted = ''N'') contractitemno,
       f_format_to_char (pcpd.qty_max_val,4) contractqty,
       qum.qty_unit contractqtyunit,
       pcm.contract_ref_no contractrefno,
       pcm.cp_contract_ref_no,
       cym.country_name destination_location,
       cym.country_name dischargecountry,
       cim.city_name,
       vd.etd etaend,
       vd.eta etastart,
       '''',
       '''',
       (select f_string_aggregate(pci.incoterm)
        from   v_pci           pci,
               agrd_action_grd agrd
        where  pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
        and    agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        and    agrd.action_no = agmr.action_no
        and    agrd.is_deleted = ''N'') incoterm,
       (select f_string_aggregate(pci.internal_contract_item_ref_no)
        from   v_pci           pci,
               agrd_action_grd agrd
        where  pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
        and    agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        and    agrd.action_no = agmr.action_no
        and    agrd.is_deleted = ''N'') internalcontractitemrefno,
       ?,
       gmr.internal_gmr_ref_no internalgmrrefno,
       '''',
       to_char(sd.bl_date, ''dd-Mon-yyyy'') issue_date,
       cyml.country_name loadingcountry,
       cyml.country_name loading_location,
       cim_load.city_name loadingport,
       sd.internal_remarks other_shipment_terms,
       '''' packing_type,
       f_format_to_char((select sum(pkg_general.f_get_converted_quantity(agrd.product_id,
                                                        agrd.qty_unit_id,
                                                        gmr.qty_unit_id,
                                                        agrd.qty))
        from   agrd_action_grd agrd
        where  agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        and    agrd.action_no = agmr.action_no
        and    agrd.is_deleted = ''N''),4) qty_of_goods,
       qumbl.qty_unit,
       phd.companyname seller,
       '''',
       nvl(pcpd.tolerance_unit_id,''%'') tolerance_unit,
       nvl(pcpd.max_tolerance,0) tolerance_max,
       nvl(pcpd.min_tolerance,0) tolerance_min,
       nvl(pcpd.tolerance_type,''Approx'') tolerance_type,
       vd.vessel_voyage_name vesselname,
       gmr.bl_date bldate,
       gmr.bl_no blnumber,
        f_format_to_char (gmr.qty,4) blqty,
       qumbl.qty_unit blqtyunit,
       '''',
       '''',
       gmr.created_date createddate,
       (select f_string_aggregate(pci.incoterm_location)
        from   v_pci           pci,
               agrd_action_grd agrd
        where  pci.internal_contract_item_ref_no =
               agrd.internal_contract_item_ref_no
        and    agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        and    agrd.action_no = agmr.action_no
        and    agrd.is_deleted = ''N'') parity_location,
       
       (select f_string_aggregate(pdm.product_desc || '' , '' || qat.quality_name)
        from   pdm_productmaster      pdm,
               qat_quality_attributes qat,
               agrd_action_grd        agrd
        where  agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        and    agrd.action_no = agmr.action_no
        and    agrd.is_deleted = ''N''
        and    pdm.product_id = agrd.product_id
        and    qat.quality_id = agrd.quality_id) productandquality,
       phdnp.companyname notifyparty,
       phd_ship.companyname shipper,
       vd.notes notes,
       vd.special_instructions specialinst,
       vd.voyage_number voyagenumber,
       vd.shippers_ref_no shipperrefno,
       cim_trans.city_name transport,
       to_char(vd.eta, ''dd-Mon-yyyy'') etadestinationport,
       vd.shippers_instructions shippersinstructions,
       vd.carriers_agents_endorsements carrieragentsendorsements,
       '''',
       (select f_string_aggregate(agrd.container_no)
        from   agrd_action_grd agrd
        where  agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        and    agrd.action_no = agmr.action_no
        and    agrd.is_deleted = ''N'') container_nos,
       f_format_to_char(gmr.qty,4) quantity,
       qum_gmr.qty_unit quantity_unit,
       qum_gmr.decimals quantity_decimals,
       f_format_to_char(gmr.current_qty,4) net_weignt_gmr,
       qum_gmr.qty_unit net_weight_unit_gmr,
       qum_gmr.decimals decimals,
       ((to_char(gmr.bl_date,
                 ''dd-Mon-yyyy'')) || '' '' || gmr.bl_no) bldate_blno,
       qum_gmr.decimals bl_quantity_decimals,
       to_char(axs.action_date,
               ''dd-Mon-yyyy'') activity_date,
       vd.voyage_number flight_number,
       cym_vd.country_name destination_airport,
       to_char(sd.bl_date,
               ''dd-Mon-yyyy'') awb_date,
       sd.bl_no awb_number,
      f_format_to_char(gmr.qty,4) awb_quantity,
       cym_vdl.country_name loading_airport,
       vd.loading_date loading_date,
       '''',
       '''',
       vd.no_of_pieces no_of_pieces,
       vd.nature_of_goods nature_of_good,
       vd.dimensions dimensions,
       (select f_string_aggregate(grd.internal_stock_ref_no)
          from grd_goods_record_detail grd
         where grd.internal_gmr_ref_no = agmr.internal_gmr_ref_no) stock_ref_no,
       f_format_to_char((select sum(pkg_general.f_get_converted_quantity(agrd.product_id,
                                                        agrd.qty_unit_id,
                                                        qum.qty_unit_id,
                                                        agrd.qty))
          from agrd_action_grd agrd
         where agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agrd.status = ''Active''
           and agrd.action_no = agmr.action_no),4) net_weight,
       f_format_to_char((select sum(pkg_general.f_get_converted_quantity(agrd.product_id,
                                                        agrd.qty_unit_id,
                                                        qum.qty_unit_id,
                                                        agrd.tare_weight))
          from agrd_action_grd agrd
         where agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agrd.status = ''Active''
           and agrd.action_no = agmr.action_no),4) tare_weight,
        f_format_to_char((select sum(pkg_general.f_get_converted_quantity(agrd.product_id,
                                                        agrd.qty_unit_id,
                                                        qum.qty_unit_id,
                                                        agrd.gross_weight))
          from agrd_action_grd agrd
         where agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agrd.status = ''Active''
           and agrd.action_no = agmr.action_no),4) gross_weight,
       (select f_string_aggregate(agrd.remarks)
        from   agrd_action_grd agrd
        where  agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
        and    agrd.action_no = agmr.action_no
        and    agrd.is_deleted = ''N'') commodity_description,
       vd.comments comments,
       '''',
       '''',
       '''',
       '''',
       '''',
       (vd.vessel_voyage_name || '' '' || vd.voyage_number) rail_name_number,
       to_char(sd.bl_date,
               ''dd-Mon-yyyy'') rr_date,
       sd.bl_no rr_number,
       f_format_to_char(gmr.qty,4) total_qty,
       f_format_to_char(gmr.qty,4) rr_qty,
       vd.shippers_ref_no truck_number,
       sd.bl_date cmr_date,
       sd.bl_no cmr_number,
       f_format_to_char(gmr.qty,4) cmr_quantity,
       sd.internal_remarks other_trucking_terms,
       vd.shippers_instructions trucking_instructions
from   gmr_goods_movement_record  gmr,
       ak_corporate akc,
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
       axs_action_summary         axs,
       phd_profileheaderdetails   phdnp,
       cim_citymaster           cim_trans,
       cim_citymaster          cim_load,
       cim_citymaster          cim,
       cym_countrymaster          cym_vd,
       cym_countrymaster          cym_vdl
where  gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
and    agmr.gmr_latest_action_action_id in
       (''shipmentDetail'', ''airDetail'', ''truckDetail'', ''railDetail'')
and    agmr.is_deleted = ''N''
and    akc.corporate_id = gmr.corporate_id
and    sd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
and    sd.action_no = agmr.action_no
and    vd.internal_gmr_ref_no = sd.internal_gmr_ref_no
and    vd.action_no = sd.action_no
and    agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
and    pcm.cp_id = phd.profileid
and    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
and    pcpd.qty_unit_id = qum.qty_unit_id
and    gmr.discharge_country_id = cym.country_id
and    gmr.loading_country_id = cyml.country_id
and    gmr.qty_unit_id = qumbl.qty_unit_id
and    gmr.internal_action_ref_no = axs.internal_action_ref_no
and    sd.notify_party_id = phdnp.profileid(+)
and    sd.consignee_id = phd_seller.profileid(+)
and    vd.trans_shipment_city_id = cim_trans.city_id(+)
and    vd.loading_city_id = cim_load.city_id(+)
and    vd.discharge_city_id = cim.city_id(+)
and    vd.discharge_country_id = cym_vd.country_id(+)
and    vd.loading_country_id = cym_vdl.country_id(+)
and    gmr.shipping_line_profile_id = phd_ship.profileid
and    gmr.qty_unit_id = qum_gmr.qty_unit_id
and    gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry where DGM_ID IN ('5','7','8','9');
  
end;
