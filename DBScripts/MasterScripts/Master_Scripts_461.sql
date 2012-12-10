 UPDATE spql_stock_payable_qty_log spql
   SET spql.weg_avg_pricing_assay_id = spql.assay_header_id
 WHERE spql.assay_header_id IN (
          SELECT ash.ash_id
            FROM ash_assay_header ash
           WHERE ash.ash_id = spql.assay_header_id
             AND ash.assay_type = 'Weighted Avg Pricing Assay')
   AND spql.weg_avg_pricing_assay_id IS NULL;
   
--script to poulate shipment assay as weighted avg assay
UPDATE spql_stock_payable_qty_log spql
   SET spql.weg_avg_pricing_assay_id = spql.assay_header_id
 WHERE spql.assay_header_id IN (
          SELECT ash.ash_id
            FROM ash_assay_header ash
           WHERE ash.ash_id = spql.assay_header_id
             AND ash.assay_type = 'Shipment Assay')
   AND spql.weg_avg_pricing_assay_id IS NULL;

