
UPDATE gm_grid_master gm
   SET gm.grid_name = 'List Of Arrived And Priced By GMR',
       gm.screen_specific_jsp =
                '/private/jsp/invoice/listing/listOfArrivedAndPricedByGmr.jsp',
       gm.screen_specific_js =
                 '/private/js/invoice/listing/listOfArrivedAndPricedByGmr.js'
 WHERE gm.grid_id = 'LPANI';
 
 
 
 UPDATE gm_grid_master gm
   SET gm.grid_name = 'List Of Arrived Priced And Provisional Invoiced',
       gm.screen_specific_jsp =
                '/private/jsp/invoice/listing/listOfArrivedPricedAndProvInv.jsp',
       gm.screen_specific_js =
                 '/private/js/invoice/listing/listOfArrivedPricedAndProvInv.js'
 WHERE gm.grid_id = 'PPI';