-- Data correction for Report issue. -- GMR 1952
UPDATE spql_stock_payable_qty_log spql
   SET spql.payable_qty_delta = 0.31464,
       spql.assay_content = 0.37016
 WHERE spql.internal_grd_ref_no = 'GRD-45000'
   AND spql.element_id = 'AML-382'
   AND spql.internal_action_ref_no = 'AXS-463689'
   AND spql.VERSION = '15';

UPDATE spql_stock_payable_qty_log spql
   SET spql.payable_qty_delta = 0.15637,
       spql.assay_content = 0.18397
 WHERE spql.internal_grd_ref_no = 'GRD-45001'
   AND spql.element_id = 'AML-382'
   AND spql.internal_action_ref_no = 'AXS-463689'
   AND spql.VERSION = '15';

UPDATE spql_stock_payable_qty_log spql
   SET spql.payable_qty_delta = -0.37224,
       spql.assay_content = -0.43792
 WHERE spql.internal_grd_ref_no = 'GRD-45002'
   AND spql.element_id = 'AML-382'
   AND spql.internal_action_ref_no = 'AXS-463689'
   AND spql.VERSION = '15';

UPDATE spql_stock_payable_qty_log spql
   SET spql.payable_qty_delta = 0.38272,
       spql.assay_content = 0.45026
 WHERE spql.internal_grd_ref_no = 'GRD-45003'
   AND spql.element_id = 'AML-382'
   AND spql.internal_action_ref_no = 'AXS-463689'
   AND spql.VERSION = '15';