update SLS_STATIC_LIST_SETUP sls set SLS.IS_DEFAULT ='N' where SLS.LIST_TYPE ='productQtyMinOP' and SLS.VALUE_ID='>';
update SLS_STATIC_LIST_SETUP sls set SLS.IS_DEFAULT ='Y' where SLS.LIST_TYPE ='productQtyMinOP' and SLS.VALUE_ID='>=';

update SLS_STATIC_LIST_SETUP sls set SLS.IS_DEFAULT ='N' where SLS.LIST_TYPE ='productQtyMaxOP' and SLS.VALUE_ID='<';
update SLS_STATIC_LIST_SETUP sls set SLS.IS_DEFAULT ='Y' where SLS.LIST_TYPE ='productQtyMaxOP' and SLS.VALUE_ID='<=';