
UPDATE gmc_grid_menu_configuration gmc
   SET gmc.link_called = 'function(){loadWeighingAndSampling();}'
 WHERE gmc.menu_id = '107';

DELETE FROM gmc_grid_menu_configuration gmc
      WHERE gmc.menu_id = 'LOGA-3';

UPDATE gmc_grid_menu_configuration gmc
   SET gmc.display_seq_no = '2'
 WHERE gmc.menu_id = 'LOGA-2'