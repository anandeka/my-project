

UPDATE amc_app_menu_configuration amc
   SET amc.menu_display_name = 'Other Charges Setup List Of Contracts',
       amc.display_seq_no = 14,
       amc.menu_parent_id = 'LRPTS',
       amc.tab_id = 'Reports'
 WHERE amc.menu_id = 'OC';