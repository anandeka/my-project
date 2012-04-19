DELETE FROM SLS_STATIC_LIST_SETUP sls
WHERE SLS.LIST_TYPE='valuationMethod' and 
 SLS.VALUE_ID in ('VMLIFO','VMmovingAverage');
