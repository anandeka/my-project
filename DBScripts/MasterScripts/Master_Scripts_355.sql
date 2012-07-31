UPDATE gmc_grid_menu_configuration gmc
   SET gmc.menu_display_name = 'Proforma Invoice'
 WHERE gmc.grid_id = 'MLOCI' AND gmc.menu_id = 'MLOCI_3_1';