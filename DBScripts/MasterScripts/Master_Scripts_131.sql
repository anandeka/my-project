
set define off;
UPDATE gmc_grid_menu_configuration gmc
   SET gmc.link_called = 'function(){loadListOfPriceFixation();}'
 WHERE gmc.grid_id = 'MLODI' AND gmc.menu_id = 'MLODI_1_1';
