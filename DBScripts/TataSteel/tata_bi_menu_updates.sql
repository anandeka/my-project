update amc_app_menu_configuration amc
   set amc.MENU_DISPLAY_NAME = 'Analytics'
 where amc.menu_id in ('IEKA-1');

update amc_app_menu_configuration amc
   set amc.MENU_DISPLAY_NAME = 'Custom Analytics'
 where amc.menu_id in ('BI-1');
commit;
