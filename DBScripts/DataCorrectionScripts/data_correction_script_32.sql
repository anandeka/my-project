UPDATE spql_stock_payable_qty_log spql
   SET spql.weg_avg_pricing_assay_id =
          (SELECT ash.ash_id
             FROM ash_assay_header ash
            WHERE (   ash.pricing_assay_ash_id = spql.assay_header_id
                   OR ash.ash_id = spql.assay_header_id
                  )
              AND ash.assay_type = 'Weighted Avg Pricing Assay')
 WHERE spql.weg_avg_pricing_assay_id IS NULL