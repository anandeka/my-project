DELETE FROM SLS_STATIC_LIST_SETUP SLS WHERE SLS.LIST_TYPE='ChargeNames' AND SLS.VALUE_ID = 'Fixed RC Charges';
DELETE FROM SLS_STATIC_LIST_SETUP SLS WHERE SLS.LIST_TYPE='ChargeNames' AND SLS.VALUE_ID = 'Fixed TC Charges';
DELETE FROM SLS_STATIC_LIST_SETUP SLS WHERE SLS.LIST_TYPE='ChargeNames' AND SLS.VALUE_ID = 'Premium';


DELETE FROM SLV_STATIC_LIST_VALUE SLV WHERE SLV.VALUE_ID = 'Fixed RC Charges' AND SLV.VALUE_TEXT = 'Fixed RC Charges';
DELETE FROM SLV_STATIC_LIST_VALUE SLV WHERE SLV.VALUE_ID = 'Fixed TC Charges' AND SLV.VALUE_TEXT = 'Fixed TC Charges';