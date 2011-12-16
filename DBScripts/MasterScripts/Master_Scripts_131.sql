
set define off;
UPDATE gmc_grid_menu_configuration gmc
   SET gmc.link_called = 'function(){loadListOfPriceFixation();}'
 WHERE gmc.grid_id = 'MLODI' AND gmc.menu_id = 'MLODI_1_1';

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('containerSize', '20 Ft', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('containerSize', '40 Ft', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('containerSize', '60 Ft', 'N', 3);

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('20 Ft', '20 Ft');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('40 Ft', '40 Ft');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('60 Ft', '60 Ft');
