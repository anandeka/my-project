insert into eem_eka_exception_master
  (exception_code, exception_module, exception_desc, is_active)
  values
  ('PHY-102',
   'Physical M2M',
   'Treatment charge  not available for the Product,Element,Valuation Point,Quality,Month-year','Y');
   
   insert into eem_eka_exception_master
  (exception_code, exception_module, exception_desc, is_active)
  values
  ('PHY-103',
   'Physical M2M',
   'Refine charge  not available for the Product,Element,Valuation Point,Quality,Month-year','Y');
   
   insert into eem_eka_exception_master
  (exception_code, exception_module, exception_desc, is_active)
  values
  ('PHY-104',
   'Physical M2M',
   'Penalty  charge  not available for the Product,Element,Valuation Point,Quality,Month-year','Y');
COMMIT;