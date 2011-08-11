UPDATE gm_grid_master gm
   SET gm.screen_specific_jsp =
                'physical/paymentInstrument/listing/listofCollateralPopup.jsp'
 WHERE gm.grid_id = 'COLLATERAL_LIST';