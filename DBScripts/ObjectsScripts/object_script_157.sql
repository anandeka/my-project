ALTER TABLE SAM_STOCK_ASSAY_MAPPING
 ADD (IS_PROPAGATED_ASSAY  CHAR(1 CHAR)             DEFAULT 'N');

update SLS_STATIC_LIST_SETUP set IS_DEFAULT='Y' where LIST_TYPE='PriceAllocationMethod' and VALUE_ID='Weighted Average Price';
