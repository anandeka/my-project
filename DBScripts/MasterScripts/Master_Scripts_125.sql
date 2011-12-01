update GMC_GRID_MENU_CONFIGURATION  gmc set GMC.LINK_CALLED='function(){loadMarkForTolling();}' 
where GMC.GRID_ID='MLOCI' and GMC.MENU_ID='MLOCI_2_1';
--remove fulfillment link
delete from GMC_GRID_MENU_CONFIGURATION where GRID_ID='MLOCI' and MENU_ID='MLOCI_2_2';