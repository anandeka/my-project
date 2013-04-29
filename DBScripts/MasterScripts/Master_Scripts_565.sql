-----------------------------------------------------------------
-- Delete AXED unnecessary entries
--------------------------------------------------------------------

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('1024', '1025', '1027', '1028', '1029', '1030', '1031',
                '1033', '1034')
        AND axed.action_id = 'shipmentDetail';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('1201', '1204', '1205', '1206', '1207', '1208', '1211',
                '1217')
        AND axed.action_id = 'truckDetail';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('1301', '1304', '1305', '1306', '1307', '1308', '1311',
                '1317')
        AND axed.action_id = 'airDetail';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('1401', '1404', '1405', '1406', '1407', '1408', '1411',
                '1417')
        AND axed.action_id = 'railDetail';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('2027', '2028', '2030', '2031', '2032', '2033', '2037',
                '2038', '2045', '2049')
        AND axed.action_id = 'shipmentAdvise';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('2101', '2104', '2105', '2106', '2107', '2108', '2117',
                '2138', '2142', '2143', '2145', '2149')
        AND axed.action_id = 'truckAdvice';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('2201', '2204', '2205', '2206', '2207', '2208', '2217',
                '2238', '2242', '2243', '2245', '2249')
        AND axed.action_id = 'airAdvice';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('2301', '2304', '2305', '2306', '2307', '2308', '2317',
                '2338', '2342', '2343', '2345', '2349')
        AND axed.action_id = 'railAdvice';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
                     ('1808', '1809', '1810', '1811', '1812', '1813', '1819')
        AND axed.action_id = 'landingDetail';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
                     ('2608', '2609', '2610', '2611', '2612', '2613', '2619')
        AND axed.action_id = 'salesLandingDetail';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
                     ('1927', '1928', '1930', '1931', '1932', '1933', '1937')
        AND axed.action_id = 'weightNote';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
                     ('2727', '2728', '2730', '2731', '2732', '2733', '2737')
        AND axed.action_id = 'salesWeightNote';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
               ('2827', '2828', '2830', '2831', '2832', '2833', '2837',
                '2838')
        AND axed.action_id = 'transshipDetail';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN
                     ('2427', '2428', '2430', '2431', '2432', '2433', '2437')
        AND axed.action_id = 'shipmentBackToBack';

DELETE FROM axed_action_entity_details axed
      WHERE axed.ID IN ('2521', '2522', '2523', '2524', '2525', '2532')
        AND axed.action_id = 'releaseOrder';

---------------------------------------------------------------

Insert into QR_QUERY_REFERENCE
   (QUERY_ID, QUERY_STRING)
 Values
   (1111, 'SELECT sld.storage_location_name FROM sld_storage_location_detail sld WHERE sld.storage_loc_id = ?');

update AXED_ACTION_ENTITY_DETAILS axed set AXED.QUERY_REF_ID = '1103' where AXED.ID = '1802';

update AXED_ACTION_ENTITY_DETAILS axed set AXED.QUERY_REF_ID = '1111' where AXED.ID = '1803';

update AXED_ACTION_ENTITY_DETAILS axed set AXED.QUERY_REF_ID = '1103' where AXED.ID = '2602';

update AXED_ACTION_ENTITY_DETAILS axed set AXED.QUERY_REF_ID = '1111' where AXED.ID = '2603';

update AXED_ACTION_ENTITY_DETAILS axed set AXED.QUERY_REF_ID = '1103' where AXED.ID = '1504';

update AXED_ACTION_ENTITY_DETAILS axed set AXED.QUERY_REF_ID = '1111' where AXED.ID = '1505';

update AXED_ACTION_ENTITY_DETAILS axed set AXED.QUERY_REF_ID = '1103' where AXED.ID = '2505';

update AXED_ACTION_ENTITY_DETAILS axed set AXED.QUERY_REF_ID = '1111' where AXED.ID = '2506';

-----------------------------------------------------
-- Shipment Details Entry
----------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1040, 'shipmentDetail', 'dischargeCountryId', 'Discharge(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1041, 'shipmentDetail', 'dischargeStateId', 'Discharge(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1042, 'shipmentDetail', 'dischargeCityId', 'Discharge(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1043, 'shipmentDetail', 'placeOfReceiptCountryId', 'Place Of Receipt(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1044, 'shipmentDetail', 'placeOfReceiptStateId', 'Place Of Receipt(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1045, 'shipmentDetail', 'placeOfReceiptCityId', 'Place Of Receipt(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1046, 'shipmentDetail', 'placeOfDeliveryCountryId', 'Place Of Delivery(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1047, 'shipmentDetail', 'placeOfDeliveryStateId', 'Place Of Delivery(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1048, 'shipmentDetail', 'placeOfDeliveryCityId', 'Place Of Delivery(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1049, 'shipmentDetail', 'loadingCountryId', 'Loading(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1050, 'shipmentDetail', 'loadingStateId', 'Loading(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1051, 'shipmentDetail', 'loadingCityId', 'Loading(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1052, 'shipmentDetail', 'transShipmentCountryId', 'Transshipment(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1053, 'shipmentDetail', 'transShipmentStateId', 'Transshipment(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1054, 'shipmentDetail', 'transShipmentCityId', 'Transshipment(City)', 1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1055, 'shipmentDetail', 'shipperAddress', 'Shipper Address', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1056, 'shipmentDetail', 'shippersInstructions', 'Shippers Instructions', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1057, 'shipmentDetail', 'shippersRefNo', 'Shippers Ref No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1058, 'shipmentDetail', 'shippingLineProfileId', 'Shipping Line', 1103);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1059, 'shipmentDetail', 'specialInstructions', 'Special Instructions', '');  

   

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1060, 'shipmentDetail', 'markNo', 'Mark No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1061, 'shipmentDetail', 'noOfBags', 'No Of Bags', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1062, 'shipmentDetail', 'noOfContainers', 'No Of Containers', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1063, 'shipmentDetail', 'noOfPieces', 'No Of Pieces', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1064, 'shipmentDetail', 'purchaseCpName', 'Purchse CP Name', '');  
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1065, 'shipmentDetail', 'qty', 'Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1066, 'shipmentDetail', 'remarks', 'Remarks', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1067, 'shipmentDetail', 'sealNo', 'Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1068, 'shipmentDetail', 'shippedGrossQty', 'Shipped Gross Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1069, 'shipmentDetail', 'shippedNetQty', 'Shipped Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1070, 'shipmentDetail', 'stockStatus', 'Stock Status', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1071, 'shipmentDetail', 'unallocatedQty', 'Un Allocated Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1072, 'shipmentDetail', 'isStocksModified', 'Is Stock Modified', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1073, 'shipmentDetail', 'totalGrossWeight', 'Total Gross Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1074, 'shipmentDetail', 'totalNetWeight', 'Total Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1075, 'shipmentDetail', 'totalTareWeight', 'Total Tare Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1076, 'shipmentDetail', 'brand', 'Brand', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1077, 'shipmentDetail', 'containerNo', 'Container No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1078, 'shipmentDetail', 'containerSize', 'Container Size', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1079, 'shipmentDetail', 'customerSealNo', 'Customer Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1080, 'shipmentDetail', 'grossWeight', 'Gross Weight', '');   

-----------------------------------------------------------------
-- Warehouse Receipt Entry
------------------------------------------------------------------

   

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1547, 'warehouseReceipt', 'markNo', 'Mark No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1548, 'warehouseReceipt', 'noOfBags', 'No Of Bags', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1549, 'warehouseReceipt', 'noOfContainers', 'No Of Containers', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1550, 'warehouseReceipt', 'noOfPieces', 'No Of Pieces', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1551, 'warehouseReceipt', 'purchaseCpName', 'Purchse CP Name', '');  
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1552, 'warehouseReceipt', 'qty', 'Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1553, 'warehouseReceipt', 'remarks', 'Remarks', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1554, 'warehouseReceipt', 'sealNo', 'Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1555, 'warehouseReceipt', 'shippedGrossQty', 'Shipped Gross Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1556, 'warehouseReceipt', 'shippedNetQty', 'Shipped Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1557, 'warehouseReceipt', 'stockStatus', 'Stock Status', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1558, 'warehouseReceipt', 'unallocatedQty', 'Un Allocated Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1559, 'warehouseReceipt', 'isStocksModified', 'Is Stock Modified', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1560, 'warehouseReceipt', 'totalGrossWeight', 'Total Gross Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1561, 'warehouseReceipt', 'totalNetWeight', 'Total Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1562, 'warehouseReceipt', 'totalTareWeight', 'Total Tare Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1563, 'warehouseReceipt', 'brand', 'Brand', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1564, 'warehouseReceipt', 'containerNo', 'Container No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1565, 'warehouseReceipt', 'containerSize', 'Container Size', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1566, 'warehouseReceipt', 'customerSealNo', 'Customer Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1567, 'warehouseReceipt', 'grossWeight', 'Gross Weight', '');

-------------------------------------------------------------
-- Truck Details
-------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1236, 'truckDetail', 'dischargeCountryId', 'Discharge(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1237, 'truckDetail', 'dischargeStateId', 'Discharge(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1238, 'truckDetail', 'dischargeCityId', 'Discharge(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1239, 'truckDetail', 'placeOfReceiptCountryId', 'Place Of Receipt(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1240, 'truckDetail', 'placeOfReceiptStateId', 'Place Of Receipt(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1241, 'truckDetail', 'placeOfReceiptCityId', 'Place Of Receipt(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1242, 'truckDetail', 'placeOfDeliveryCountryId', 'Place Of Delivery(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1243, 'truckDetail', 'placeOfDeliveryStateId', 'Place Of Delivery(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1244, 'truckDetail', 'placeOfDeliveryCityId', 'Place Of Delivery(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1245, 'truckDetail', 'loadingCountryId', 'Loading(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1246, 'truckDetail', 'loadingStateId', 'Loading(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1247, 'truckDetail', 'loadingCityId', 'Loading(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1248, 'truckDetail', 'transShipmentCountryId', 'Transshipment(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1249, 'truckDetail', 'transShipmentStateId', 'Transshipment(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1250, 'truckDetail', 'transShipmentCityId', 'Transshipment(City)', 1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1251, 'truckDetail', 'shipperAddress', 'Trucker Address', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1252, 'truckDetail', 'shippersInstructions', 'Truckers Instructions', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1253, 'truckDetail', 'shippersRefNo', 'Trucker Ref No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1254, 'truckDetail', 'shippingLineProfileId', 'Trucker', 1103);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1256, 'truckDetail', 'specialInstructions', 'Special Instructions', '');  

   

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1257, 'truckDetail', 'markNo', 'Mark No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1258, 'truckDetail', 'noOfBags', 'No Of Bags', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1259, 'truckDetail', 'noOfContainers', 'No Of Containers', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1260, 'truckDetail', 'noOfPieces', 'No Of Pieces', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1261, 'truckDetail', 'purchaseCpName', 'Purchse CP Name', '');  
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1262, 'truckDetail', 'qty', 'Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1263, 'truckDetail', 'remarks', 'Remarks', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1264, 'truckDetail', 'sealNo', 'Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1265, 'truckDetail', 'shippedGrossQty', 'Shipped Gross Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1266, 'truckDetail', 'shippedNetQty', 'Shipped Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1267, 'truckDetail', 'stockStatus', 'Stock Status', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1268, 'truckDetail', 'unallocatedQty', 'Un Allocated Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1269, 'truckDetail', 'isStocksModified', 'Is Stock Modified', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1270, 'truckDetail', 'totalGrossWeight', 'Total Gross Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1271, 'truckDetail', 'totalNetWeight', 'Total Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1272, 'truckDetail', 'totalTareWeight', 'Total Tare Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1273, 'truckDetail', 'brand', 'Brand', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1274, 'truckDetail', 'containerNo', 'Container No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1275, 'truckDetail', 'containerSize', 'Container Size', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1276, 'truckDetail', 'customerSealNo', 'Customer Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1277, 'truckDetail', 'grossWeight', 'Gross Weight', '');   
---------------------------------------------------------------------------
--AirDetails
-----------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1336, 'airDetail', 'dischargeCountryId', 'Discharge(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1337, 'airDetail', 'dischargeStateId', 'Discharge(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1338, 'airDetail', 'dischargeCityId', 'Discharge(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1339, 'airDetail', 'placeOfReceiptCountryId', 'Place Of Receipt(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1340, 'airDetail', 'placeOfReceiptStateId', 'Place Of Receipt(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1341, 'airDetail', 'placeOfReceiptCityId', 'Place Of Receipt(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1342, 'airDetail', 'placeOfDeliveryCountryId', 'Place Of Delivery(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1343, 'airDetail', 'placeOfDeliveryStateId', 'Place Of Delivery(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1344, 'airDetail', 'placeOfDeliveryCityId', 'Place Of Delivery(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1345, 'airDetail', 'loadingCountryId', 'Airport of Departure(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1346, 'airDetail', 'loadingStateId', 'Airport of Departure(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1347, 'airDetail', 'loadingCityId', 'Airport of Departure(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1348, 'airDetail', 'transShipmentCountryId', 'Transshipment(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1349, 'airDetail', 'transShipmentStateId', 'Transshipment(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1350, 'airDetail', 'transShipmentCityId', 'Transshipment(City)', 1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1351, 'airDetail', 'shipperAddress', 'Shipper Address', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1352, 'airDetail', 'shippersInstructions', 'Shipper Instructions', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1353, 'airDetail', 'shippersRefNo', 'Flight No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1354, 'airDetail', 'shippingLineProfileId', 'Shipper', 1103);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1356, 'airDetail', 'specialInstructions', 'Handling Instructions', '');  

   

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1357, 'airDetail', 'markNo', 'Mark No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1358, 'airDetail', 'noOfBags', 'No Of Bags', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1359, 'airDetail', 'noOfContainers', 'No Of Containers', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1360, 'airDetail', 'noOfPieces', 'No Of Pieces', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1361, 'airDetail', 'purchaseCpName', 'Purchse CP Name', '');  
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1362, 'airDetail', 'qty', 'Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1363, 'airDetail', 'remarks', 'Remarks', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1364, 'airDetail', 'sealNo', 'Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1365, 'airDetail', 'shippedGrossQty', 'Shipped Gross Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1366, 'airDetail', 'shippedNetQty', 'Shipped Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1367, 'airDetail', 'stockStatus', 'Stock Status', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1368, 'airDetail', 'unallocatedQty', 'Un Allocated Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1369, 'airDetail', 'isStocksModified', 'Is Stock Modified', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1370, 'airDetail', 'totalGrossWeight', 'Total Gross Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1371, 'airDetail', 'totalNetWeight', 'Total Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1372, 'airDetail', 'totalTareWeight', 'Total Tare Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1373, 'airDetail', 'brand', 'Brand', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1374, 'airDetail', 'containerNo', 'Container No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1375, 'airDetail', 'containerSize', 'Container Size', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1376, 'airDetail', 'customerSealNo', 'Customer Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1377, 'airDetail', 'grossWeight', 'Gross Weight', '');     
-----------------------------------------------------------------
--Rail Details
------------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1436, 'railDetail', 'dischargeCountryId', 'Discharge(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1437, 'railDetail', 'dischargeStateId', 'Discharge(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1438, 'railDetail', 'dischargeCityId', 'Discharge(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1439, 'railDetail', 'placeOfReceiptCountryId', 'Place Of Receipt(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1440, 'railDetail', 'placeOfReceiptStateId', 'Place Of Receipt(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1441, 'railDetail', 'placeOfReceiptCityId', 'Place Of Receipt(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1442, 'railDetail', 'placeOfDeliveryCountryId', 'Place Of Delivery(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1443, 'railDetail', 'placeOfDeliveryStateId', 'Place Of Delivery(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1444, 'railDetail', 'placeOfDeliveryCityId', 'Place Of Delivery(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1445, 'railDetail', 'loadingCountryId', 'Loading(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1446, 'railDetail', 'loadingStateId', 'Loading(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1447, 'railDetail', 'loadingCityId', 'Loading(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1448, 'railDetail', 'transShipmentCountryId', 'Transshipment(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1449, 'railDetail', 'transShipmentStateId', 'Transshipment(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1450, 'railDetail', 'transShipmentCityId', 'Transshipment(City)', 1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1451, 'railDetail', 'shipperAddress', 'Shipper Address', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1452, 'railDetail', 'shippersInstructions', 'Shipper Instructions', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1453, 'railDetail', 'shippersRefNo', 'Rail No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1454, 'railDetail', 'shippingLineProfileId', 'Rail Name', 1103);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1456, 'railDetail', 'specialInstructions', 'Special Instructions', '');  

   

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1457, 'railDetail', 'markNo', 'Mark No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1458, 'railDetail', 'noOfBags', 'No Of Bags', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1459, 'railDetail', 'noOfContainers', 'No Of Containers', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1460, 'railDetail', 'noOfPieces', 'No Of Pieces', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1461, 'railDetail', 'purchaseCpName', 'Purchse CP Name', '');  
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1462, 'railDetail', 'qty', 'Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1463, 'railDetail', 'remarks', 'Remarks', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1464, 'railDetail', 'sealNo', 'Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1465, 'railDetail', 'shippedGrossQty', 'Shipped Gross Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1466, 'railDetail', 'shippedNetQty', 'Shipped Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1467, 'railDetail', 'stockStatus', 'Stock Status', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1468, 'railDetail', 'unallocatedQty', 'Un Allocated Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1469, 'railDetail', 'isStocksModified', 'Is Stock Modified', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1470, 'railDetail', 'totalGrossWeight', 'Total Gross Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1471, 'railDetail', 'totalNetWeight', 'Total Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1472, 'railDetail', 'totalTareWeight', 'Total Tare Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1473, 'railDetail', 'brand', 'Brand', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1474, 'railDetail', 'containerNo', 'Container No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1475, 'railDetail', 'containerSize', 'Container Size', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1476, 'railDetail', 'customerSealNo', 'Customer Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (1477, 'railDetail', 'grossWeight', 'Gross Weight', '');   
-----------------------------------------------------------------------------------------
-- ShipmentAdvice
-------------------------------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2056, 'shipmentAdvise', 'dischargeCountryId', 'Discharge(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2057, 'shipmentAdvise', 'dischargeStateId', 'Discharge(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2058, 'shipmentAdvise', 'dischargeCityId', 'Discharge(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2059, 'shipmentAdvise', 'placeOfReceiptCountryId', 'Place Of Receipt(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2060, 'shipmentAdvise', 'placeOfReceiptStateId', 'Place Of Receipt(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2061, 'shipmentAdvise', 'placeOfReceiptCityId', 'Place Of Receipt(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2062, 'shipmentAdvise', 'placeOfDeliveryCountryId', 'Place Of Delivery(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2063, 'shipmentAdvise', 'placeOfDeliveryStateId', 'Place Of Delivery(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2064, 'shipmentAdvise', 'placeOfDeliveryCityId', 'Place Of Delivery(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2065, 'shipmentAdvise', 'loadingCountryId', 'Loading(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2066, 'shipmentAdvise', 'loadingStateId', 'Loading(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2067, 'shipmentAdvise', 'loadingCityId', 'Loading(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2068, 'shipmentAdvise', 'transShipmentCountryId', 'Transshipment(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2069, 'shipmentAdvise', 'transShipmentStateId', 'Transshipment(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2070, 'shipmentAdvise', 'transShipmentCityId', 'Transshipment(City)', 1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2071, 'shipmentAdvise', 'shipperAddress', 'Shipper Address', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2072, 'shipmentAdvise', 'shippersInstructions', 'Shippers Instructions', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2073, 'shipmentAdvise', 'shippersRefNo', 'Shippers Ref No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2074, 'shipmentAdvise', 'shippingLineProfileId', 'Shipping Line', 1103);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2075, 'shipmentAdvise', 'specialInstructions', 'Special Instructions', '');  

   
-----------------------------------------------------------------------------------------
-- Truck Advice
----------------------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2156, 'truckAdvice', 'dischargeCountryId', 'Discharge(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2157, 'truckAdvice', 'dischargeStateId', 'Discharge(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2158, 'truckAdvice', 'dischargeCityId', 'Discharge(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2159, 'truckAdvice', 'placeOfReceiptCountryId', 'Place Of Receipt(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2160, 'truckAdvice', 'placeOfReceiptStateId', 'Place Of Receipt(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2161, 'truckAdvice', 'placeOfReceiptCityId', 'Place Of Receipt(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2162, 'truckAdvice', 'placeOfDeliveryCountryId', 'Place Of Delivery(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2163, 'truckAdvice', 'placeOfDeliveryStateId', 'Place Of Delivery(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2164, 'truckAdvice', 'placeOfDeliveryCityId', 'Place Of Delivery(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2165, 'truckAdvice', 'loadingCountryId', 'Loading(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2166, 'truckAdvice', 'loadingStateId', 'Loading(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2167, 'truckAdvice', 'loadingCityId', 'Loading(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2168, 'truckAdvice', 'transShipmentCountryId', 'Transshipment(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2169, 'truckAdvice', 'transShipmentStateId', 'Transshipment(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2170, 'truckAdvice', 'transShipmentCityId', 'Transshipment(City)', 1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2171, 'truckAdvice', 'shipperAddress', 'Trucker Address', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2172, 'truckAdvice', 'shippersInstructions', 'Trucker Instructions', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2173, 'truckAdvice', 'shippersRefNo', 'Trucker Ref No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2174, 'truckAdvice', 'shippingLineProfileId', 'Trucker', 1103);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2175, 'truckAdvice', 'specialInstructions', 'Special Instructions', '');  

   
-------------------------------------------------------------------
-- Air Advice
--------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2256, 'airAdvice', 'dischargeCountryId', 'Discharge(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2257, 'airAdvice', 'dischargeStateId', 'Discharge(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2258, 'airAdvice', 'dischargeCityId', 'Discharge(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2259, 'airAdvice', 'placeOfReceiptCountryId', 'Place Of Receipt(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2260, 'airAdvice', 'placeOfReceiptStateId', 'Place Of Receipt(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2261, 'airAdvice', 'placeOfReceiptCityId', 'Place Of Receipt(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2262, 'airAdvice', 'placeOfDeliveryCountryId', 'Place Of Delivery(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2263, 'airAdvice', 'placeOfDeliveryStateId', 'Place Of Delivery(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2264, 'airAdvice', 'placeOfDeliveryCityId', 'Place Of Delivery(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2265, 'airAdvice', 'loadingCountryId', 'Loading(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2266, 'airAdvice', 'loadingStateId', 'Loading(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2267, 'airAdvice', 'loadingCityId', 'Loading(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2268, 'airAdvice', 'transShipmentCountryId', 'Transshipment(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2269, 'airAdvice', 'transShipmentStateId', 'Transshipment(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2270, 'airAdvice', 'transShipmentCityId', 'Transshipment(City)', 1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2271, 'airAdvice', 'shipperAddress', 'Shipper Address', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2272, 'airAdvice', 'shippersInstructions', 'Shipper Instructions', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2273, 'airAdvice', 'shippersRefNo', 'Flight Ref No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2274, 'airAdvice', 'shippingLineProfileId', 'Flight No', 1103);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2275, 'airAdvice', 'specialInstructions', 'Special Instructions', '');  

   
---------------------------------------------------------------
-- Rail Advice
---------------------------------------------------------------
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2356, 'railAdvice', 'dischargeCountryId', 'Discharge(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2357, 'railAdvice', 'dischargeStateId', 'Discharge(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2358, 'railAdvice', 'dischargeCityId', 'Discharge(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2359, 'railAdvice', 'placeOfReceiptCountryId', 'Place Of Receipt(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2360, 'railAdvice', 'placeOfReceiptStateId', 'Place Of Receipt(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2361, 'railAdvice', 'placeOfReceiptCityId', 'Place Of Receipt(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2362, 'railAdvice', 'placeOfDeliveryCountryId', 'Place Of Delivery(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2363, 'railAdvice', 'placeOfDeliveryStateId', 'Place Of Delivery(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2364, 'railAdvice', 'placeOfDeliveryCityId', 'Place Of Delivery(City)', 1102);


Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2365, 'railAdvice', 'loadingCountryId', 'Loading(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2366, 'railAdvice', 'loadingStateId', 'Loading(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2367, 'railAdvice', 'loadingCityId', 'Loading(City)', 1102);
   
   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2368, 'railAdvice', 'transShipmentCountryId', 'Transshipment(Country)', 1100);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2369, 'railAdvice', 'transShipmentStateId', 'Transshipment(State)', 1101);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2370, 'railAdvice', 'transShipmentCityId', 'Transshipment(City)', 1102);

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2371, 'railAdvice', 'shipperAddress', 'Shipper Address', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2372, 'railAdvice', 'shippersInstructions', 'Shipper Instructions', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2373, 'railAdvice', 'shippersRefNo', 'Shipper Ref No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2374, 'railAdvice', 'shippingLineProfileId', 'Rail No', 1103);
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2375, 'railAdvice', 'specialInstructions', 'Special Instructions', '');  

   
------------------------------------------------------------------------------
-- Release Order
---------------------------------------------------------------------

   

Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2547, 'releaseOrder', 'markNo', 'Mark No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2548, 'releaseOrder', 'noOfBags', 'No Of Bags', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2549, 'releaseOrder', 'noOfContainers', 'No Of Containers', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2550, 'releaseOrder', 'noOfPieces', 'No Of Pieces', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2551, 'releaseOrder', 'purchaseCpName', 'Purchse CP Name', '');  
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2552, 'releaseOrder', 'qty', 'Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2553, 'releaseOrder', 'remarks', 'Remarks', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2554, 'releaseOrder', 'sealNo', 'Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2555, 'releaseOrder', 'shippedGrossQty', 'Shipped Gross Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2556, 'releaseOrder', 'shippedNetQty', 'Shipped Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2557, 'releaseOrder', 'stockStatus', 'Stock Status', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2558, 'releaseOrder', 'unallocatedQty', 'Un Allocated Qty', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2559, 'releaseOrder', 'isStocksModified', 'Is Stock Modified', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2560, 'releaseOrder', 'totalGrossWeight', 'Total Gross Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2561, 'releaseOrder', 'totalNetWeight', 'Total Net Weight', '');   
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2562, 'releaseOrder', 'totalTareWeight', 'Total Tare Weight', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2563, 'releaseOrder', 'brand', 'Brand', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2564, 'releaseOrder', 'containerNo', 'Container No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2565, 'releaseOrder', 'containerSize', 'Container Size', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2566, 'releaseOrder', 'customerSealNo', 'Customer Seal No', '');
Insert into AXED_ACTION_ENTITY_DETAILS
   (ID, ACTION_ID, FIELD_NAME, LABEL, QUERY_REF_ID)
 Values
   (2567, 'releaseOrder', 'grossWeight', 'Gross Weight', '');


