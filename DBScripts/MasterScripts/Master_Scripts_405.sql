---------------------------------------------------------------------------
---ADDED FOR RELEASEORDER DOCUMENT
---------------------------------------------------------------------------


Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DKMRO-1', 'Release order', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

--------------------------------------------------------------------------------------------

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_RO_SAD_D', 'releaseOrder', 'Release Order', 'releaseOrder', 1, 
    '1', 'N');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM_RO_CHILD_SAD_D', 'releaseOrder', 'Release Order', 'releaseOrder', 2, 
    '1', 'N');
---------------------------------------------------------------------------
---INSERT INTO MAIN TABLE (SAD_D)
----------------------------------------------------------------------------
declare
fetchqry clob := 'INSERT INTO SAD_D(
ATTENTION,
BUYER,
CONTRACT_DATE,
CONTRACT_ITEM_NO,
CONTRACT_QTY,
CONTRACT_QTY_UNIT,
CONTRACT_REF_NO,
CP_REF_NO,
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
CREATED_DATE,
PARITY_LOCATION,
PRODUCTANDQUALITY,
NOTIFYPARITY,
SHIPPER,
NOTES,
SPECIALINSTRUCTIONS,
QUANTITY,
QUANTITY_UNIT,
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
REMARKS,
RAIL_NAME_NUMBER,
RR_DATE,
RR_NUMBER,
ISSUER,
ISSUER_REF_NO,
ISSUER_ADDRESS,
CONSIGNEE,
CONSIGNEE_REF_NO,
CONSIGNEE_ADDRESS,
WAREHOUSE_AND_SHED,
WAREHOUSE_ADDRESS
)
select '''',
       pci.cp_name buyer,
       pci.issue_date contractdate,
       pci.contract_item_ref_no contractitemno,
       f_format_to_char(pcpd.qty_max_val, 4) contractqty,
       qum.qty_unit contractqtyunit,
       pci.contract_ref_no contractrefno,
       pci.cp_contract_ref_no cprefno,
       pci.incoterm incoterm,
       pci.internal_contract_item_ref_no internalcontractitemrefno,
       
       ?,
       gmr.internal_gmr_ref_no internalgmrrefno,
       '''''''',
       to_char(rod.release_date, ''dd-Mon-yyyy'') issue_date,
       '''',
       '''',
       '''',
       '''' packing_type,
       f_format_to_char(gmr.qty, 4) qty_of_goods,
       qumbl.qty_unit qty_of_goods_unit,
       akc.corporate_name seller,
       '''',
       pcpd.max_tolerance maxtolerance,
       pcpd.min_tolerance mintolerance,
       pcpd.tolerance_type tolerancetype,
       gmr.created_date createddate,
       pci.incoterm_location parity_location,
       pci.product_name || '','' || pci.quality_name productandquality,
       '''',
       phdi.companyname issuer,
       rod.notes notes,
       rod.special_instructions specialinst,
       f_format_to_char(gmr.qty, 4) quantity,
       qumbl.qty_unit quantity_unit,
       to_char(axs.action_date, ''dd-Mon-yyyy'') activity_date,
       '''',
       '''',
       '''',
       '''',
       '''',
       '''''''',
       '''',
       '''',
       '''',
       '''',
       '''',
       '''',
       (select f_string_aggregate(dgrd.internal_stock_ref_no)
          from dgrd_delivered_grd dgrd
         where dgrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no) stock_ref_no,
       f_format_to_char((select sum(pkg_general.f_get_converted_quantity(adgrd.product_id,
                                                                        adgrd.net_weight_unit_id,
                                                                        qumbl.qty_unit_id,
                                                                        adgrd.net_weight))
                          from adgrd_action_dgrd adgrd
                         where adgrd.internal_gmr_ref_no =
                               agmr.internal_gmr_ref_no
                           and adgrd.status = ''Active''
                           and adgrd.action_no = agmr.action_no),
                        4) net_weight,
       f_format_to_char((select sum(pkg_general.f_get_converted_quantity(adgrd.product_id,
                                                                        adgrd.net_weight_unit_id,
                                                                        qumbl.qty_unit_id,
                                                                        adgrd.tare_weight))
                          from adgrd_action_dgrd adgrd
                         where adgrd.internal_gmr_ref_no =
                               agmr.internal_gmr_ref_no
                           and adgrd.status = ''Active''
                           and adgrd.action_no = agmr.action_no),
                        4) tare_weight,
       f_format_to_char((select sum(pkg_general.f_get_converted_quantity(adgrd.product_id,
                                                                        adgrd.net_weight_unit_id,
                                                                        qumbl.qty_unit_id,
                                                                        adgrd.gross_weight))
                          from adgrd_action_dgrd adgrd
                         where adgrd.internal_gmr_ref_no =
                               agmr.internal_gmr_ref_no
                           and adgrd.status = ''Active''
                           and adgrd.action_no = agmr.action_no),
                        4) gross_weight,
       '''',
       rod.comments comments,
       rod.activity_ref_no activityrefno,
       '''',
       '''',
       '''',
       rod.receipt_no receiptno,
       phdi.companyname issuer,
       rod.issuers_ref_no issuerrefno,
       rod.issuers_address issueraddress,
       phdc.companyname consignee,
       rod.consignees_ref_no consigneerefno,
       rod.consignee_address consigneeaddress,
       shm.companyname || '','' || shm.shed_name warehouseandshed,
       (case
         when sm_shm.state_id is null then
          shm.address || '' , '' || cim_shm.city_name || '' , '' ||
          cym_shm.country_name
         else
          shm.address || '' , '' || cim_shm.city_name || '' , '' ||
          sm_shm.state_name || '' , '' || cym_shm.country_name
       end) warehouseaddress
  from v_pci                          pci,
       qum_quantity_unit_master       qum,
       qum_quantity_unit_master       qumbl,
       pcpd_pc_product_definition     pcpd,
       gmr_goods_movement_record      gmr,
       rod_release_order_detail       rod,
       phd_profileheaderdetails       phdi,
       phd_profileheaderdetails       phdc,
       ak_corporate                   akc,
       axs_action_summary             axs,
       agmr_action_gmr                agmr,
       gcim_gmr_contract_item_mapping gcim,
       v_shm_shed_master              shm,
       cym_countrymaster              cym_shm,
       cim_citymaster                 cim_shm,
       sm_state_master                sm_shm
 where gmr.internal_gmr_ref_no = rod.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and rod.internal_gmr_ref_no = agmr.internal_gmr_ref_no
   and rod.action_no = agmr.action_no
   and gcim.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gcim.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and pci.contract_type = ''S''
   and phdi.profileid(+) = rod.issue_id
   and phdc.profileid(+) = rod.consignee_id
   and pcpd.internal_contract_ref_no = pci.internal_contract_ref_no
   and pcpd.product_id = pci.product_id
   and pcpd.qty_unit_id = qum.qty_unit_id
   and gmr.corporate_id = akc.corporate_id
   and agmr.is_deleted = ''N''
   and agmr.gmr_latest_action_action_id in (''releaseOrder'')
   and gmr.qty_unit_id = qumbl.qty_unit_id
   and gmr.internal_action_ref_no = axs.internal_action_ref_no
   and shm.profile_id = rod.warehouse_profile_id
   and shm.shed_id = rod.warehouse_shed_id
   and shm.country_id = cym_shm.country_id
   and sm_shm.state_id(+) = shm.state_id
   and shm.city_id = cim_shm.city_id
   and gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry where DGM_ID = 'DGM_RO_SAD_D';
  
end;

---------------------------------------------------------------------------
---INSERT INTO MAIN TABLE (SADC_CHILD_DGRD_D)
----------------------------------------------------------------------------
declare
fetchqry clob := 'INSERT INTO sadc_child_dgrd_d
            (internal_gmr_ref_no, internal_dgrd_ref_no,
             internal_contract_item_ref_no, internal_doc_ref_no, stock_ref_no,
             net_weight, tare_weight, gross_weight, p_shipped_net_weight,
             p_shipped_gross_weight, p_shipped_tare_weight, landed_net_qty,
             landed_gross_qty, current_qty, net_weight_unit,
             net_weight_unit_id, container_no, container_size, no_of_bags,
             no_of_containers, no_of_pieces, brand, mark_no, seal_no,
             customer_seal_no, stock_status, remarks)
   SELECT gmr.internal_gmr_ref_no internal_gmr_ref_no,
          agrd.internal_grd_ref_no internal_grd_ref_no,
          agrd.internal_contract_item_ref_no internal_contract_item_ref_no,
          ?, agrd.internal_stock_ref_no internal_stock_ref_no,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.net_weight
                                                    )
              ),
              4
             ) net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.tare_weight
                                                    )
              ),
              4
             ) tare_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.gross_weight
                                                    )
              ),
              4
             ) gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.p_shipped_net_weight
                                                    )
              ),
              4
             ) p_shipped_net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity
                                                  (agrd.product_id,
                                                   agrd.net_weight_unit_id,
                                                   qum_bl.qty_unit_id,
                                                   agrd.p_shipped_gross_weight
                                                  )
              ),
              4
             ) p_shipped_gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity
                                                   (agrd.product_id,
                                                    agrd.net_weight_unit_id,
                                                    qum_bl.qty_unit_id,
                                                    agrd.p_shipped_tare_weight
                                                   )
              ),
              4
             ) p_shipped_tare_weight,
          '''' landed_net_qty, '''' landed_gross_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.current_qty
                                                    )
              ),
              4
             ) current_qty,
          qum_bl.qty_unit net_weight_unit,
          qum_bl.qty_unit_id net_weight_unit_id,
          agrd.container_no container_no, agrd.container_size container_size,
          agrd.no_of_bags no_of_bags, agrd.no_of_containers no_of_containers,
          agrd.no_of_pieces no_of_pieces, agrd.brand brand,
          agrd.mark_no mark_no, agrd.seal_no seal_no,
          agrd.customer_seal_no customer_seal_no,
          agrd.stock_status stock_status, agrd.remarks remarks
     FROM adgrd_action_dgrd agrd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          qum_quantity_unit_master qum_bl
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.action_no = agrd.action_no
      AND qum_bl.qty_unit_id = agrd.net_weight_unit_id
      AND agmr.gmr_latest_action_action_id IN
                 (''releaseOrder'')
      AND agmr.is_deleted = ''N''
      AND agrd.status = ''Active''
      AND gmr.internal_gmr_ref_no = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry where DGM_ID = 'DGM_RO_CHILD_SAD_D';
  
end;
