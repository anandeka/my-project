--------------------------------------------------------------
-----QR Entries For Logistics    (All Action Ids)
--------------------------------------------------------------

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1100, 'select cym.country_name  from cym_countrymaster cym where cym.country_id = ?');

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1101, 'select  sm.state_name from sm_state_master sm where sm.state_id = ?');

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1102, 'select cim.city_name from cim_citymaster cim where cim.city_id = ?');

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1103, 'select phd.companyname from phd_profileheaderdetails phd where phd.profileid = ?');

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1104, 'select pdm.product_desc from pdm_productmaster pdm where pdm.product_id = ?');
   
Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1105, 'select qum.qty_unit from qum_quantity_unit_master qum where qum.qty_unit_id = ?');
   
Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1106, 'select cpc.profit_center_name from cpc_corporate_profit_center cpc where cpc.profit_center_id = ?');
   
Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1107, 'select css.strategy_name from css_corporate_strategy_setup css where css.strategy_id = ?');

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1108, 'select pm.pool_name from pm_pool_master pm where pm.pool_id = ?');
    
Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1109, 'select qat.quality_name   from qat_quality_attributes qat where qat.quality_id = ?');

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1110, 'select agh.alloc_group_name   from agh_alloc_group_header agh where agh.int_alloc_group_id = ?');

------------------------------------------------------------
----AXED Entries
------------------------------------------------------------

------------------------------------------------------------
----- ShipmentDetails/InternalShipment Entries---
----------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1100, 'shipmentDetail', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1101, 'shipmentDetail', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1102, 'shipmentDetail', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1000, 'shipmentDetail', '', 'activityDate', 'Activity Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1001, 'shipmentDetail', '', 'blDate', 'BL Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1002, 'shipmentDetail', '', 'blNo', 'BL No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1003, 'shipmentDetail', '', 'sendersRefNo', 'Senders Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1004, 'shipmentDetail', '', 'sendersAddress', 'Senders Address', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1006, 'shipmentDetail', '', 'senderId', 'Sender Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1007, 'shipmentDetail', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1008, 'shipmentDetail', '', 'consigneeAddress', 'Consignee Address', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1009, 'shipmentDetail', '', 'consigneeId', 'Consignee Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1010, 'shipmentDetail', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1011, 'shipmentDetail', '', 'notifyPartyAddress', 'Notify Party Adderss', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1012, 'shipmentDetail', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1013, 'shipmentDetail', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');

    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1014, 'shipmentDetail', '', 'isFinalWeight', 'Is Weight Final', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1015, 'shipmentDetail', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1016, 'shipmentDetail', '', 'internalRemarks', 'Internal Remarks', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1017, 'shipmentDetail', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1018, 'shipmentDetail', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1019, 'shipmentDetail', '', 'productId', 'Product Name', 
    '1104');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1020, 'shipmentDetail', '', 'totalQtyId', 'Quantity Unit', 
    '1105');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1020, 'shipmentDetail', '', 'totalQtyId', 'Quantity Unit', 
    '1105');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1021, 'shipmentDetail', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1022, 'shipmentDetail', '', 'strategyId', 'Strategy', 
    '1107');
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1023, 'shipmentDetail', '', 'containerServiceType', 'Container Service Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1024, 'shipmentDetail', '', 'entryType', 'Entry Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1025, 'shipmentDetail', '', 'inputItemType', 'Input Item Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1026, 'shipmentDetail', '', 'totalQty', 'Total Quantity', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1027, 'shipmentDetail', '', 'actionId', 'Current Action Id', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1028, 'shipmentDetail', '', 'intAllocGroupIdForTolCheck', 'Allocation Group Id To Check Tolerance', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1029, 'shipmentDetail', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1030, 'shipmentDetail', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1031, 'shipmentDetail', '', 'isStocksModified', 'Is Stock Section Modified', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1032, 'shipmentDetail', '', 'markForConsignment', 'Mark For Consignment', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1033, 'shipmentDetail', '', 'originId', 'Origin', 
    '');
    
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1034, 'shipmentDetail', '', 'productType', 'Product Type', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1035, 'shipmentDetail', 'VoyageDetailDO', 'vesselVoyageName', 'Vessel Name', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1036, 'shipmentDetail', 'VoyageDetailDO', 'voyageNumber', 'Voyage Number', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1037, 'shipmentDetail', 'VoyageDetailDO', 'bookingRefNo', 'Booking Ref No', 
    '');

------------------------------------------------------------
----- TruckDetails Entries---
----------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1200, 'truckDetail', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1201, 'truckDetail', '', 'actionId', 'Activity Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1202, 'truckDetail', '', 'consigneeAddress', 'Consignee Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1203, 'truckDetail', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1204, 'truckDetail', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1205, 'truckDetail', '', 'inputItemType', 'Input Item Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1206, 'truckDetail', '', 'intAllocGroupIdForTolCheck', 'Internal AllocGroupId For Tolerance Check', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1207, 'truckDetail', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1208, 'truckDetail', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1209, 'truckDetail', '', 'internalRemarks', 'Internal Remarks', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1210, 'truckDetail', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1211, 'truckDetail', '', 'isStocksModified', 'Is Stocks Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1212, 'truckDetail', '', 'markForConsignment', 'Mark For Consignment', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1213, 'truckDetail', '', 'notifyPartyAddress', 'Notify Party Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1214, 'truckDetail', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1215, 'truckDetail', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1216, 'truckDetail', '', 'productId', 'Product', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1217, 'truckDetail', '', 'productType', 'Product Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1218, 'truckDetail', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1219, 'truckDetail', '', 'senderId', 'Sender Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1220, 'truckDetail', '', 'sendersAddress', 'Sender Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1221, 'truckDetail', '', 'sendersRefNo', 'Sender Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1222, 'truckDetail', '', 'strategyId', 'Strategy', 
    '1107');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1223, 'truckDetail', '', 'totalQty', 'Total Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1224, 'truckDetail', '', 'totalQtyId', 'Qty Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1226, 'truckDetail', '', 'blDate', 'CMR Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1227, 'truckDetail', '', 'blNo', 'CMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1228, 'truckDetail', '', 'isFinalWeight', 'Is Weight Final', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1229, 'truckDetail', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1230, 'truckDetail', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1231, 'truckDetail', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1232, 'truckDetail', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1233, 'truckDetail', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1234, 'truckDetail', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1235, 'truckDetail', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');
------------------------------------------------------------
----- RailDetails Entries---
----------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1400, 'railDetail', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1401, 'railDetail', '', 'actionId', 'Activity Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1402, 'railDetail', '', 'consigneeAddress', 'Consignee Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1403, 'railDetail', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1404, 'railDetail', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1405, 'railDetail', '', 'inputItemType', 'Input Item Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1406, 'railDetail', '', 'intAllocGroupIdForTolCheck', 'Internal AllocGroupId For Tolerance Check', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1407, 'railDetail', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1408, 'railDetail', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1409, 'railDetail', '', 'internalRemarks', 'Internal Remarks', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1410, 'railDetail', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1411, 'railDetail', '', 'isStocksModified', 'Is Stocks Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1412, 'railDetail', '', 'markForConsignment', 'Mark For Consignment', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1413, 'railDetail', '', 'notifyPartyAddress', 'Notify Party Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1414, 'railDetail', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1415, 'railDetail', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1416, 'railDetail', '', 'productId', 'Product', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1417, 'railDetail', '', 'productType', 'Product Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1418, 'railDetail', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1419, 'railDetail', '', 'senderId', 'Sender Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1420, 'railDetail', '', 'sendersAddress', 'Sender Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1421, 'railDetail', '', 'sendersRefNo', 'Sender Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1422, 'railDetail', '', 'strategyId', 'Strategy', 
    '1107');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1423, 'railDetail', '', 'totalQty', 'Total Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1424, 'railDetail', '', 'totalQtyId', 'Qty Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1426, 'railDetail', '', 'blDate', 'R R Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1427, 'railDetail', '', 'blNo', 'R R Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1428, 'railDetail', '', 'isFinalWeight', 'Is Weight Final', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1429, 'railDetail', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1430, 'railDetail', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1431, 'railDetail', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1432, 'railDetail', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1433, 'railDetail', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1434, 'railDetail', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1435, 'railDetail', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');
------------------------------------------------------------
----- AirDetails Entries---
----------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1300, 'airDetail', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1301, 'airDetail', '', 'actionId', 'Activity Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1302, 'airDetail', '', 'consigneeAddress', 'Consignee Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1303, 'airDetail', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1304, 'airDetail', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1305, 'airDetail', '', 'inputItemType', 'Input Item Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1306, 'airDetail', '', 'intAllocGroupIdForTolCheck', 'Internal AllocGroupId For Tolerance Check', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1307, 'airDetail', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1308, 'airDetail', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1309, 'airDetail', '', 'internalRemarks', 'Internal Remarks', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1310, 'airDetail', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1311, 'airDetail', '', 'isStocksModified', 'Is Stocks Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1312, 'airDetail', '', 'markForConsignment', 'Mark For Consignment', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1313, 'airDetail', '', 'notifyPartyAddress', 'Notify Party Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1314, 'airDetail', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1315, 'airDetail', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1316, 'airDetail', '', 'productId', 'Product', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1317, 'airDetail', '', 'productType', 'Product Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1318, 'airDetail', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1319, 'airDetail', '', 'senderId', 'Sender Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1320, 'airDetail', '', 'sendersAddress', 'Sender Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1321, 'airDetail', '', 'sendersRefNo', 'Sender Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1322, 'airDetail', '', 'strategyId', 'Strategy', 
    '1107');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1323, 'airDetail', '', 'totalQty', 'Total Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1324, 'airDetail', '', 'totalQtyId', 'Qty Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1326, 'airDetail', '', 'blDate', 'AirWay Bill Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1327, 'airDetail', '', 'blNo', 'AirWay Bill Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1328, 'airDetail', '', 'isFinalWeight', 'Is Weight Final', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1329, 'airDetail', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1330, 'airDetail', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1331, 'airDetail', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1332, 'airDetail', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1333, 'airDetail', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1334, 'airDetail', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1335, 'airDetail', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');
------------------------------------------------------------
----- ShipmentAdvice Entries---
----------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2000, 'shipmentAdvise', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2001, 'shipmentAdvise', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2002, 'shipmentAdvise', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2003, 'shipmentAdvise', '', 'activityDate', 'Activity Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2004, 'shipmentAdvise', '', 'blDate', 'BL Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2005, 'shipmentAdvise', '', 'blNo', 'BL No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2006, 'shipmentAdvise', '', 'sendersRefNo', 'Senders Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2007, 'shipmentAdvise', '', 'sendersAddress', 'Senders Address', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2008, 'shipmentAdvise', '', 'senderId', 'Sender Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2009, 'shipmentAdvise', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2010, 'shipmentAdvise', '', 'consigneeAddress', 'Consignee Address', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2011, 'shipmentAdvise', '', 'consigneeId', 'Consignee Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2012, 'shipmentAdvise', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2013, 'shipmentAdvise', '', 'notifyPartyAddress', 'Notify Party Adderss', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2014, 'shipmentAdvise', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2015, 'shipmentAdvise', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');

    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2016, 'shipmentAdvise', '', 'isFinalWeight', 'Is Weight Final', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2017, 'shipmentAdvise', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2018, 'shipmentAdvise', '', 'internalRemarks', 'Internal Remarks', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2019, 'shipmentAdvise', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2020, 'shipmentAdvise', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2021, 'shipmentAdvise', '', 'productId', 'Product Name', 
    '1104');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2022, 'shipmentAdvise', '', 'totalQtyId', 'Quantity Unit', 
    '1105');

    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2024, 'shipmentAdvise', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2025, 'shipmentAdvise', '', 'strategyId', 'Strategy', 
    '1107');
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2026, 'shipmentAdvise', '', 'containerServiceType', 'Container Service Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2027, 'shipmentAdvise', '', 'entryType', 'Entry Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2028, 'shipmentAdvise', '', 'inputItemType', 'Input Item Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2029, 'shipmentAdvise', '', 'totalQty', 'Total Quantity', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2030, 'shipmentAdvise', '', 'actionId', 'Current Action Id', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2031, 'shipmentAdvise', '', 'intAllocGroupIdForTolCheck', 'Allocation Group Id To Check Tolerance', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2032, 'shipmentAdvise', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2033, 'shipmentAdvise', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2034, 'shipmentAdvise', '', 'isStocksModified', 'Is Stock Section Modified', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2035, 'shipmentAdvise', '', 'markForConsignment', 'Mark For Consignment', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2036, 'shipmentAdvise', '', 'originId', 'Origin', 
    '');
    
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2037, 'shipmentAdvise', '', 'productType', 'Product Type', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2038, 'shipmentAdvise', '', 'actionNo', 'Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2039, 'shipmentAdvise', '', 'calculatedPrice', 'Calculated Price', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2040, 'shipmentAdvise', '', 'counterPartyId', 'Counter Party Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2041, 'shipmentAdvise', '', 'cpCurrentExp', 'Cp Current Exp', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2042, 'shipmentAdvise', '', 'latestActionNo', 'Latest Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2043, 'shipmentAdvise', '', 'oldAllocationGroupId', 'Old Allocation GroupId', 
    '1110'); 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2044, 'shipmentAdvise', '', 'plannedQty', 'Planned Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2045, 'shipmentAdvise', '', 'productSpecs', 'Product Specs', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2046, 'shipmentAdvise', '', 'qualityId', 'Quality', 
    '1109');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2047, 'shipmentAdvise', '', 'salesGmrQtyUnitId', 'Sales GMR Quantity Unit', 
    '1105');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2048, 'shipmentAdvise', '', 'salesInternalAllocationGroupId', 'Sales Allocation Group Name', 
    '1110');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2049, 'shipmentAdvise', '', 'salesInternalContractItemRefNo', 'Sales Internal Contract Item Ref No', 
    ''); 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2050, 'shipmentAdvise', '', 'totalGrossPurchaseWeight', 'Total Gross Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2051, 'shipmentAdvise', '', 'totalGrossWeight', 'Total Gross Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2052, 'shipmentAdvise', '', 'totalNetPurchaseWeight', 'Total Net Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2053, 'shipmentAdvise', '', 'totalNetWeight', 'Total Net Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2054, 'shipmentAdvise', '', 'totalTarePurchaseWeight', 'Total Tare Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2055, 'shipmentAdvise', '', 'totalTareWeight', 'Total Tare Weight', 
    '');    
------------------------------------------------------------
----- TruckAdvice Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2100, 'truckAdvice', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2101, 'truckAdvice', '', 'actionId', 'Activity Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2102, 'truckAdvice', '', 'consigneeAddress', 'Consignee Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2103, 'truckAdvice', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2104, 'truckAdvice', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2105, 'truckAdvice', '', 'inputItemType', 'Input Item Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2106, 'truckAdvice', '', 'intAllocGroupIdForTolCheck', 'Internal AllocGroupId For Tolerance Check', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2107, 'truckAdvice', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2108, 'truckAdvice', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2109, 'truckAdvice', '', 'internalRemarks', 'Internal Remarks', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2110, 'truckAdvice', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2111, 'truckAdvice', '', 'isStocksModified', 'Is Stocks Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2112, 'truckAdvice', '', 'markForConsignment', 'Mark For Consignment', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2113, 'truckAdvice', '', 'notifyPartyAddress', 'Notify Party Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2114, 'truckAdvice', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2115, 'truckAdvice', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2116, 'truckAdvice', '', 'productId', 'Product', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2117, 'truckAdvice', '', 'productType', 'Product Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2118, 'truckAdvice', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2119, 'truckAdvice', '', 'senderId', 'Sender Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2120, 'truckAdvice', '', 'sendersAddress', 'Sender Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2121, 'truckAdvice', '', 'sendersRefNo', 'Sender Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2122, 'truckAdvice', '', 'strategyId', 'Strategy', 
    '1107');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2123, 'truckAdvice', '', 'totalQty', 'Total Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2124, 'truckAdvice', '', 'totalQtyId', 'Qty Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2126, 'truckAdvice', '', 'blDate', 'CMR Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2127, 'truckAdvice', '', 'blNo', 'CMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2128, 'truckAdvice', '', 'isFinalWeight', 'Is Weight Final', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2129, 'truckAdvice', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2130, 'truckAdvice', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2131, 'truckAdvice', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2132, 'truckAdvice', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2133, 'truckAdvice', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2134, 'truckAdvice', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2135, 'truckAdvice', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2138, 'truckAdvice', '', 'actionNo', 'Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2139, 'truckAdvice', '', 'calculatedPrice', 'Calculated Price', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2140, 'truckAdvice', '', 'counterPartyId', 'Counter Party Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2141, 'truckAdvice', '', 'cpCurrentExp', 'Cp Current Exp', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2142, 'truckAdvice', '', 'latestActionNo', 'Latest Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2143, 'truckAdvice', '', 'oldAllocationGroupId', 'Old Allocation GroupId', 
    '1110'); 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2144, 'truckAdvice', '', 'plannedQty', 'Planned Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2145, 'truckAdvice', '', 'productSpecs', 'Product Specs', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2146, 'truckAdvice', '', 'qualityId', 'Quality', 
    '1109');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2147, 'truckAdvice', '', 'salesGmrQtyUnitId', 'Sales GMR Quantity Unit', 
    '1105');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2148, 'truckAdvice', '', 'salesInternalAllocationGroupId', 'Sales Allocation Group Name', 
    '1110');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2149, 'truckAdvice', '', 'salesInternalContractItemRefNo', 'Sales Internal Contract Item Ref No', 
    ''); 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2150, 'truckAdvice', '', 'totalGrossPurchaseWeight', 'Total Gross Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2151, 'truckAdvice', '', 'totalGrossWeight', 'Total Gross Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2152, 'truckAdvice', '', 'totalNetPurchaseWeight', 'Total Net Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2153, 'truckAdvice', '', 'totalNetWeight', 'Total Net Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2154, 'truckAdvice', '', 'totalTarePurchaseWeight', 'Total Tare Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2155, 'truckAdvice', '', 'totalTareWeight', 'Total Tare Weight', 
    '');    
 ------------------------------------------------------------
----- RailAdvice Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2300, 'railAdvice', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2301, 'railAdvice', '', 'actionId', 'Activity Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2302, 'railAdvice', '', 'consigneeAddress', 'Consignee Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2303, 'railAdvice', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2304, 'railAdvice', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2305, 'railAdvice', '', 'inputItemType', 'Input Item Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2306, 'railAdvice', '', 'intAllocGroupIdForTolCheck', 'Internal AllocGroupId For Tolerance Check', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2307, 'railAdvice', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2308, 'railAdvice', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2309, 'railAdvice', '', 'internalRemarks', 'Internal Remarks', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2310, 'railAdvice', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2311, 'railAdvice', '', 'isStocksModified', 'Is Stocks Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2312, 'railAdvice', '', 'markForConsignment', 'Mark For Consignment', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2313, 'railAdvice', '', 'notifyPartyAddress', 'Notify Party Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2314, 'railAdvice', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2315, 'railAdvice', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2316, 'railAdvice', '', 'productId', 'Product', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2317, 'railAdvice', '', 'productType', 'Product Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2318, 'railAdvice', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2319, 'railAdvice', '', 'senderId', 'Sender Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2320, 'railAdvice', '', 'sendersAddress', 'Sender Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2321, 'railAdvice', '', 'sendersRefNo', 'Sender Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2322, 'railAdvice', '', 'strategyId', 'Strategy', 
    '1107');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2323, 'railAdvice', '', 'totalQty', 'Total Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2324, 'railAdvice', '', 'totalQtyId', 'Qty Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2326, 'railAdvice', '', 'blDate', 'R R Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2327, 'railAdvice', '', 'blNo', 'R R Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2328, 'railAdvice', '', 'isFinalWeight', 'Is Weight Final', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2329, 'railAdvice', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2330, 'railAdvice', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2331, 'railAdvice', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2332, 'railAdvice', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2333, 'railAdvice', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2334, 'railAdvice', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2335, 'railAdvice', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2338, 'railAdvice', '', 'actionNo', 'Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2339, 'railAdvice', '', 'calculatedPrice', 'Calculated Price', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2340, 'railAdvice', '', 'counterPartyId', 'Counter Party Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2341, 'railAdvice', '', 'cpCurrentExp', 'Cp Current Exp', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2342, 'railAdvice', '', 'latestActionNo', 'Latest Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2343, 'railAdvice', '', 'oldAllocationGroupId', 'Old Allocation GroupId', 
    '1110'); 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2344, 'railAdvice', '', 'plannedQty', 'Planned Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2345, 'railAdvice', '', 'productSpecs', 'Product Specs', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2346, 'railAdvice', '', 'qualityId', 'Quality', 
    '1109');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2347, 'railAdvice', '', 'salesGmrQtyUnitId', 'Sales GMR Quantity Unit', 
    '1105');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2348, 'railAdvice', '', 'salesInternalAllocationGroupId', 'Sales Allocation Group Name', 
    '1110');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2349, 'railAdvice', '', 'salesInternalContractItemRefNo', 'Sales Internal Contract Item Ref No', 
    ''); 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2350, 'railAdvice', '', 'totalGrossPurchaseWeight', 'Total Gross Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2351, 'railAdvice', '', 'totalGrossWeight', 'Total Gross Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2352, 'railAdvice', '', 'totalNetPurchaseWeight', 'Total Net Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2353, 'railAdvice', '', 'totalNetWeight', 'Total Net Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2354, 'railAdvice', '', 'totalTarePurchaseWeight', 'Total Tare Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2355, 'railAdvice', '', 'totalTareWeight', 'Total Tare Weight', 
    '');    
  ------------------------------------------------------------
----- AirAdvice Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2200, 'airAdvice', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2201, 'airAdvice', '', 'actionId', 'Activity Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2202, 'airAdvice', '', 'consigneeAddress', 'Consignee Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2203, 'airAdvice', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2204, 'airAdvice', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2205, 'airAdvice', '', 'inputItemType', 'Input Item Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2206, 'airAdvice', '', 'intAllocGroupIdForTolCheck', 'Internal AllocGroupId For Tolerance Check', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2207, 'airAdvice', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2208, 'airAdvice', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2209, 'airAdvice', '', 'internalRemarks', 'Internal Remarks', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2210, 'airAdvice', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2211, 'airAdvice', '', 'isStocksModified', 'Is Stocks Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2212, 'airAdvice', '', 'markForConsignment', 'Mark For Consignment', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2213, 'airAdvice', '', 'notifyPartyAddress', 'Notify Party Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2214, 'airAdvice', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2215, 'airAdvice', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2216, 'airAdvice', '', 'productId', 'Product', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2217, 'airAdvice', '', 'productType', 'Product Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2218, 'airAdvice', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2219, 'airAdvice', '', 'senderId', 'Sender Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2220, 'airAdvice', '', 'sendersAddress', 'Sender Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2221, 'airAdvice', '', 'sendersRefNo', 'Sender Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2222, 'airAdvice', '', 'strategyId', 'Strategy', 
    '1107');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2223, 'airAdvice', '', 'totalQty', 'Total Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2224, 'airAdvice', '', 'totalQtyId', 'Qty Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2225, 'airAdvice', '', 'blDate', 'AirWay Bill Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2226, 'airAdvice', '', 'blNo', 'AirWay Bill Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2227, 'airAdvice', '', 'isFinalWeight', 'Is Weight Final', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2228, 'airAdvice', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2229, 'airAdvice', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2230, 'airAdvice', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2231, 'airAdvice', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2232, 'airAdvice', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2233, 'airAdvice', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2234, 'airAdvice', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2238, 'airAdvice', '', 'actionNo', 'Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2239, 'airAdvice', '', 'calculatedPrice', 'Calculated Price', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2240, 'airAdvice', '', 'counterPartyId', 'Counter Party Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2241, 'airAdvice', '', 'cpCurrentExp', 'Cp Current Exp', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2242, 'airAdvice', '', 'latestActionNo', 'Latest Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2243, 'airAdvice', '', 'oldAllocationGroupId', 'Old Allocation GroupId', 
    '1110'); 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2244, 'airAdvice', '', 'plannedQty', 'Planned Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2245, 'airAdvice', '', 'productSpecs', 'Product Specs', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2246, 'airAdvice', '', 'qualityId', 'Quality', 
    '1109');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2247, 'airAdvice', '', 'salesGmrQtyUnitId', 'Sales GMR Quantity Unit', 
    '1105');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2248, 'airAdvice', '', 'salesInternalAllocationGroupId', 'Sales Allocation Group Name', 
    '1110');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2249, 'airAdvice', '', 'salesInternalContractItemRefNo', 'Sales Internal Contract Item Ref No', 
    ''); 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2250, 'airAdvice', '', 'totalGrossPurchaseWeight', 'Total Gross Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2251, 'airAdvice', '', 'totalGrossWeight', 'Total Gross Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2252, 'airAdvice', '', 'totalNetPurchaseWeight', 'Total Net Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2253, 'airAdvice', '', 'totalNetWeight', 'Total Net Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2254, 'airAdvice', '', 'totalTarePurchaseWeight', 'Total Tare Purchase Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2255, 'airAdvice', '', 'totalTareWeight', 'Total Tare Weight', 
    '');    
   ------------------------------------------------------------
----- WarehouserReceipt/DST Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1500, 'warehouseReceipt', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1501, 'warehouseReceipt', '', 'issueDate', 'Issue Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1502, 'warehouseReceipt', '', 'warehouseReceiptNo', 'Warehouse Receipt No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1503, 'warehouseReceipt', '', 'arrivalDate', 'Arrival Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1504, 'warehouseReceipt', '', 'warehouseProfileId', 'Warehouse Profile Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1505, 'warehouseReceipt', '', 'shedId', 'Warehouse Shed', 
    '1106');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1506, 'warehouseReceipt', '', 'senderId', 'Sender Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1507, 'warehouseReceipt', '', 'sendersAddress', 'Sender Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1508, 'warehouseReceipt', '', 'sendersRefNo', 'Sender Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1509, 'warehouseReceipt', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1510, 'warehouseReceipt', '', 'consigneeAddress', 'Consignee Address', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1511, 'warehouseReceipt', '', 'consigneeId', 'Consignee Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1512, 'warehouseReceipt', '', 'containerServiceType', 'Movement', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1513, 'warehouseReceipt', '', 'comments', 'Comments', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1514, 'warehouseReceipt', '', 'notes', 'Notes', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1515, 'warehouseReceipt', '', 'specialInstructions', 'Special Instructions', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1516, 'warehouseReceipt', '', 'isFinalWeight', 'Is Final Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1517, 'warehouseReceipt', '', 'isWarrantCheck', 'Is Warrant Check', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1518, 'warehouseReceipt', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1519, 'warehouseReceipt', '', 'isApplyContainerCharge', 'Is Apply Container Charge', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1520, 'warehouseReceipt', '', 'internalRemarks', 'Internal Remarks', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1521, 'warehouseReceipt', '', 'actionId', 'Action Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1522, 'warehouseReceipt', '', 'actionNo', 'Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1523, 'warehouseReceipt', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1524, 'warehouseReceipt', '', 'inputItemType', 'Input Item Type', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1525, 'warehouseReceipt', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1526, 'warehouseReceipt', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1527, 'warehouseReceipt', '', 'isStocksModified', 'Is Stock Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1528, 'warehouseReceipt', '', 'oldPoolId', 'Old Pool Name', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1529, 'warehouseReceipt', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1530, 'warehouseReceipt', '', 'poolId', 'Pool Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1531, 'warehouseReceipt', '', 'productId', 'Product Name', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1532, 'warehouseReceipt', '', 'productType', 'Product Type', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1533, 'warehouseReceipt', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1534, 'warehouseReceipt', '', 'strategyId', 'Strategy', 
    '1107');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1535, 'warehouseReceipt', '', 'carriersRefNo', 'Carriers Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1536, 'warehouseReceipt', '', 'intAllocGroupIdForTolCheck', 'Internal Alloc GroupId For Tol Check', 
    '1110');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1537, 'warehouseReceipt', '', 'isWarrant', 'Is Warrant', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1538, 'warehouseReceipt', '', 'issuersAddress', 'Issuers Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1539, 'warehouseReceipt', '', 'totalQty', 'Total Qty', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1540, 'warehouseReceipt', '', 'totalQtyId', 'Total Qty Unit', 
    '1105');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1541, 'warehouseReceipt', '', 'freeDaysOfStorage', 'Free Days Of Storage', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1542, 'warehouseReceipt', '', 'navigationType', 'Navigation Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1543, 'warehouseReceipt', '', 'qualityId', 'Quality', 
    '1109');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1544, 'warehouseReceipt', '', 'storageDate', 'Storage Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1545, 'warehouseReceipt', '', 'markForConsignment', 'Mark For Consignment', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1546, 'warehouseReceipt', '', 'movementStartDate', 'Movement Start Date', 
    '');
   ------------------------------------------------------------
----- LandingDetails Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1800, 'landingDetail', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1801, 'landingDetail', '', 'storageDate', 'Storage Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1802, 'landingDetail', '', 'warehouseProfileId', 'Warehouse Profile Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1803, 'landingDetail', '', 'shedId', 'Warehouse Shed', 
    '1106');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1804, 'landingDetail', '', 'freeDaysOfStorage', 'Free Days Of Storage', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1805, 'landingDetail', '', 'warehouseReceiptNo', 'Warehouse Receipt No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1806, 'landingDetail', '', 'isFinalWeight', 'Is Final Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1807, 'landingDetail', '', 'internalRemarks', 'Internal Remarks', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1808, 'landingDetail', '', 'actionId', 'Action Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1809, 'landingDetail', '', 'actionNo', 'Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1810, 'landingDetail', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1811, 'landingDetail', '', 'inputItemType', 'Input Item Type', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1812, 'landingDetail', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1813, 'landingDetail', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1814, 'landingDetail', '', 'isStocksModified', 'Is Stock Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1815, 'landingDetail', '', 'oldPoolId', 'Old Pool Name', 
    '1108');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1816, 'landingDetail', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1817, 'landingDetail', '', 'poolId', 'Pool Name', 
    '1108');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1818, 'landingDetail', '', 'productId', 'Product Name', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1819, 'landingDetail', '', 'productType', 'Product Type', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1820, 'landingDetail', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1821, 'landingDetail', '', 'strategyId', 'Strategy', 
    '1107');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1822, 'landingDetail', '', 'totalQty', 'Total Quantity', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1823, 'landingDetail', '', 'totalQtyId', 'Quantity Unit', 
    '1105');
   ------------------------------------------------------------
----- SalesLandingDetails Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2600, 'salesLandingDetail', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2601, 'salesLandingDetail', '', 'storageDate', 'Storage Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2602, 'salesLandingDetail', '', 'warehouseProfileId', 'Warehouse Profile Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2603, 'salesLandingDetail', '', 'shedId', 'Warehouse Shed', 
    '1106');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2604, 'salesLandingDetail', '', 'freeDaysOfStorage', 'Free Days Of Storage', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2605, 'salesLandingDetail', '', 'warehouseReceiptNo', 'Warehouse Receipt No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2606, 'salesLandingDetail', '', 'isFinalWeight', 'Is Final Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2607, 'salesLandingDetail', '', 'internalRemarks', 'Internal Remarks', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2608, 'salesLandingDetail', '', 'actionId', 'Action Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2609, 'salesLandingDetail', '', 'actionNo', 'Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2610, 'salesLandingDetail', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2611, 'salesLandingDetail', '', 'inputItemType', 'Input Item Type', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2612, 'salesLandingDetail', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2613, 'salesLandingDetail', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2614, 'salesLandingDetail', '', 'isStocksModified', 'Is Stock Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2615, 'salesLandingDetail', '', 'oldPoolId', 'Old Pool Name', 
    '1108');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2616, 'salesLandingDetail', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2617, 'salesLandingDetail', '', 'poolId', 'Pool Name', 
    '1108');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2618, 'salesLandingDetail', '', 'productId', 'Product Name', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2619, 'salesLandingDetail', '', 'productType', 'Product Type', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2620, 'salesLandingDetail', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2621, 'salesLandingDetail', '', 'strategyId', 'Strategy', 
    '1107');
  Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2622, 'salesLandingDetail', '', 'totalQty', 'Total Quantity', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2623, 'salesLandingDetail', '', 'totalQtyId', 'Quantity Unit', 
    '1105');
   ------------------------------------------------------------
----- ReleaseOrderDetails Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2500, 'releaseOrder', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2501, 'releaseOrder', '', 'releaseDate', 'Release Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2502, 'releaseOrder', '', 'issuersRefNo', 'Issuers Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2503, 'releaseOrder', '', 'senderId', 'Sender', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2504, 'releaseOrder', '', 'sendersAddress', 'Senders Address', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2505, 'releaseOrder', '', 'warehouseProfileId', 'Warehouse Shed', 
    '1106');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2506, 'releaseOrder', '', 'warehouseShedId', 'Sender Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2507, 'releaseOrder', '', 'receiptNo', 'Receipt No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2508, 'releaseOrder', '', 'comments', 'Comments', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2509, 'releaseOrder', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2510, 'releaseOrder', '', 'consigneeAddress', 'Consignee Address', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2511, 'releaseOrder', '', 'consigneeId', 'Consignee Name', 
    '1103');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2512, 'releaseOrder', '', 'notes', 'Notes', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2513, 'releaseOrder', '', 'specialInstructions', 'Special Instructions', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2514, 'releaseOrder', '', 'isFinalWeight', 'Is Final Weight', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2515, 'releaseOrder', '', 'isApplyFreightAllowance', 'Is Apply Freight Allowance', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2516, 'releaseOrder', '', 'isApplyContainerCharge', 'Is Apply Container Charge', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2517, 'releaseOrder', '', 'internalRemarks', 'Internal Remarks', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2521, 'releaseOrder', '', 'actionId', 'Action Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2522, 'releaseOrder', '', 'actionNo', 'Action No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2523, 'releaseOrder', '', 'entryType', 'Entry Type', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2524, 'releaseOrder', '', 'inputItemType', 'Input Item Type', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2525, 'releaseOrder', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2526, 'releaseOrder', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2527, 'releaseOrder', '', 'isStocksModified', 'Is Stock Modified', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2528, 'releaseOrder', '', 'oldPoolId', 'Old Pool Name', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2529, 'releaseOrder', '', 'originId', 'Origin', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2530, 'releaseOrder', '', 'poolId', 'Pool Name', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2531, 'releaseOrder', '', 'productId', 'Product Name', 
    '1104');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2532, 'releaseOrder', '', 'productType', 'Product Type', 
    '');
 Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2533, 'releaseOrder', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2534, 'releaseOrder', '', 'strategyId', 'Strategy', 
    '');
   ------------------------------------------------------------
----- ShipmentBackToBackDetails Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2400, 'shipmentBackToBack', '', 'portOfArrivalCountryId', 'Port of Arrival(Country)', 
    1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2401, 'shipmentBackToBack', '', 'portOfArrivalStateId', 'Port of Arrival(State)', 
    1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2402, 'shipmentBackToBack', '', 'portOfArrivalCityId', 'Port of Arrival(City)', 
    1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2403, 'shipmentBackToBack', '', 'activityDate', 'Activity Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2404, 'shipmentBackToBack', '', 'blDate', 'BL Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2405, 'shipmentBackToBack', '', 'blNo', 'BL No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2406, 'shipmentBackToBack', '', 'sendersRefNo', 'Senders Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2407, 'shipmentBackToBack', '', 'sendersAddress', 'Senders Address', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2408, 'shipmentBackToBack', '', 'senderId', 'Sender Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2409, 'shipmentBackToBack', '', 'consigneesRefNo', 'Consignees Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2410, 'shipmentBackToBack', '', 'consigneeAddress', 'Consignee Address', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2411, 'shipmentBackToBack', '', 'consigneeId', 'Consignee Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2412, 'shipmentBackToBack', '', 'notifyPartyId', 'Notify Party Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2413, 'shipmentBackToBack', '', 'notifyPartyAddress', 'Notify Party Adderss', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2414, 'shipmentBackToBack', '', 'forwardingAgentId', 'Forwarding Agent Name', 
    '1103');
    
    Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2415, 'shipmentBackToBack', '', 'forwardingAgentsAddress', 'Forwarding Agents Address', 
    '');

    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2416, 'shipmentBackToBack', '', 'isFinalWeight', 'Is Weight Final', 
    '');
    

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2418, 'shipmentBackToBack', '', 'internalRemarks', 'Internal Remarks', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2419, 'shipmentBackToBack', '', 'arrivalDate', 'Arrival Date', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2420, 'shipmentBackToBack', '', 'cargoPickupLocation', 'Stock Pickup Location', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2421, 'shipmentBackToBack', '', 'productId', 'Product Name', 
    '1104');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2422, 'shipmentBackToBack', '', 'totalQtyId', 'Quantity Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2424, 'shipmentBackToBack', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2425, 'shipmentBackToBack', '', 'strategyId', 'Strategy', 
    '1107');
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2426, 'shipmentBackToBack', '', 'containerServiceType', 'Container Service Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2427, 'shipmentBackToBack', '', 'entryType', 'Entry Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2428, 'shipmentBackToBack', '', 'inputItemType', 'Input Item Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2429, 'shipmentBackToBack', '', 'totalQty', 'Total Quantity', 
    '');
------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2430, 'shipmentBackToBack', '', 'actionId', 'Current Action Id', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2431, 'shipmentBackToBack', '', 'intAllocGroupIdForTolCheck', 'Allocation Group Id To Check Tolerance', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2432, 'shipmentBackToBack', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2433, 'shipmentBackToBack', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2434, 'shipmentBackToBack', '', 'isStocksModified', 'Is Stock Section Modified', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2435, 'shipmentBackToBack', '', 'markForConsignment', 'Mark For Consignment', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2436, 'shipmentBackToBack', '', 'originId', 'Origin', 
    '');
    
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2437, 'shipmentBackToBack', '', 'productType', 'Product Type', 
    '');
   ------------------------------------------------------------
----- WeightNoteDetails Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1900, 'weightNote', '', 'activityDate', 'Activity Date', 
    );
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1901, 'weightNote', '', 'weighingDate', 'Weighing Date', 
    );
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1902, 'weightNote', '', 'issueDate', 'Issue Date', 
    );

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1903, 'weightNote', '', 'weigherProfileId', 'Weigher Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1904, 'weightNote', '', 'weightNoteNo', 'Weight Note No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1905, 'weightNote', '', 'currencyId', 'Currency', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1906, 'weightNote', '', 'isFinalWeight', 'Is Final Weight', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1907, 'weightNote', '', 'internalRemarks', 'Internal Remarks', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1921, 'weightNote', '', 'productId', 'Product Name', 
    '1104');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1922, 'weightNote', '', 'totalQtyId', 'Quantity Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1924, 'weightNote', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1925, 'weightNote', '', 'strategyId', 'Strategy', 
    '1107');
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1926, 'weightNote', '', 'containerServiceType', 'Container Service Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1927, 'weightNote', '', 'entryType', 'Entry Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1928, 'weightNote', '', 'inputItemType', 'Input Item Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1929, 'weightNote', '', 'totalQty', 'Total Quantity', 
    '');
------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1930, 'weightNote', '', 'actionId', 'Current Action Id', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1931, 'weightNote', '', 'intAllocGroupIdForTolCheck', 'Allocation Group Id To Check Tolerance', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1932, 'weightNote', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1933, 'weightNote', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1934, 'weightNote', '', 'isStocksModified', 'Is Stock Section Modified', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1935, 'weightNote', '', 'markForConsignment', 'Mark For Consignment', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1936, 'weightNote', '', 'originId', 'Origin', 
    '');
    
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (1937, 'weightNote', '', 'productType', 'Product Type', 
    '');

   ------------------------------------------------------------
----- SalesWeightNoteDetails Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2700, 'salesWeightNote', '', 'activityDate', 'Activity Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2701, 'salesWeightNote', '', 'weighingDate', 'Weighing Date', 
    '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2702, 'salesWeightNote', '', 'issueDate', 'Issue Date', 
   '' );

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2703, 'salesWeightNote', '', 'weigherProfileId', 'Weigher Name', 
    '1103');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2704, 'salesWeightNote', '', 'salesWeightNoteNo', 'Weight Note No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2705, 'salesWeightNote', '', 'currencyId', 'Currency', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2706, 'salesWeightNote', '', 'isFinalWeight', 'Is Final Weight', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2707, 'salesWeightNote', '', 'internalRemarks', 'Internal Remarks', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2721, 'salesWeightNote', '', 'productId', 'Product Name', 
    '1104');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2722, 'salesWeightNote', '', 'totalQtyId', 'Quantity Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2724, 'salesWeightNote', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2725, 'salesWeightNote', '', 'strategyId', 'Strategy', 
    '1107');
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2726, 'salesWeightNote', '', 'containerServiceType', 'Container Service Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2727, 'salesWeightNote', '', 'entryType', 'Entry Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2728, 'salesWeightNote', '', 'inputItemType', 'Input Item Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2729, 'salesWeightNote', '', 'totalQty', 'Total Quantity', 
    '');
------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2730, 'salesWeightNote', '', 'actionId', 'Current Action Id', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2731, 'salesWeightNote', '', 'intAllocGroupIdForTolCheck', 'Allocation Group Id To Check Tolerance', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2732, 'salesWeightNote', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2733, 'salesWeightNote', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2734, 'salesWeightNote', '', 'isStocksModified', 'Is Stock Section Modified', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2735, 'salesWeightNote', '', 'markForConsignment', 'Mark For Consignment', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2736, 'salesWeightNote', '', 'originId', 'Origin', 
    '');
    
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2737, 'salesWeightNote', '', 'productType', 'Product Type', 
    '');

   ------------------------------------------------------------
----- TransshipmentDetails Entries---
---------------------------------------------------------------- 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2800, 'transshipDetail', '', 'activityDate', 'Activity Date', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2805, 'transshipDetail', '', 'currencyId', 'Currency', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2807, 'transshipDetail', '', 'internalRemarks', 'Internal Remarks', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2821, 'transshipDetail', '', 'productId', 'Product Name', 
    '1104');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2822, 'transshipDetail', '', 'totalQtyId', 'Quantity Unit', 
    '1105');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2824, 'transshipDetail', '', 'profitCenterId', 'Profit Center Name', 
    '1106');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2825, 'transshipDetail', '', 'strategyId', 'Strategy', 
    '1107');
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2826, 'transshipDetail', '', 'containerServiceType', 'Container Service Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2827, 'transshipDetail', '', 'entryType', 'Entry Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2828, 'transshipDetail', '', 'inputItemType', 'Input Item Type', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2829, 'transshipDetail', '', 'totalQty', 'Total Quantity', 
    '');
------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2830, 'transshipDetail', '', 'actionId', 'Current Action Id', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2831, 'transshipDetail', '', 'intAllocGroupIdForTolCheck', 'Allocation Group Id To Check Tolerance', 
    '');

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2832, 'transshipDetail', '', 'internalActionRefNo', 'Internal Action Ref No', 
    '');
 
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2833, 'transshipDetail', '', 'internalGMRRefNo', 'Internal GMR Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2834, 'transshipDetail', '', 'isStocksModified', 'Is Stock Section Modified', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2835, 'transshipDetail', '', 'markForConsignment', 'Mark For Consignment', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2836, 'transshipDetail', '', 'originId', 'Origin', 
    '');
    
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2837, 'transshipDetail', '', 'productType', 'Product Type', 
    '');

    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2838, 'transshipDetail', '', 'actionNo', 'Action No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2839, 'transshipDetail', '', 'anchorageRefNo', 'Anchorage Ref No', 
    '');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2840, 'transshipDetail', '', 'oldPoolId', 'Old Pile Name', 
    '1108');
    
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, SUB_ENTITY, FIELD_NAME, LABEL, 
    QUERY_REF_ID)
 Values
   (2841, 'transshipDetail', '', 'poolId', 'Pool Name', 
    '1108');