update SPQL_STOCK_PAYABLE_QTY_LOG spql
set spql.WEG_AVG_PRICING_ASSAY_ID = (select ash.ash_id from ASH_ASSAY_HEADER ash
where ASH.PRICING_ASSAY_ASH_ID=SPQL.ASSAY_HEADER_ID
and ASH.ASSAY_TYPE='Weighted Avg Pricing Assay');