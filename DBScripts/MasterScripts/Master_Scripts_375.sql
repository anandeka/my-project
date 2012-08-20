UPDATE amc_app_menu_configuration
   SET display_seq_no = 8
 WHERE menu_id = 'AC' AND menu_parent_id = 'F1';
COMMIT;