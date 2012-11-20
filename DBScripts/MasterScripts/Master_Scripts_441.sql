INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID,
             link_called, icon_class, menu_parent_id,
             acl_id
            )
     VALUES ('LOII_5', 'LOIID_TEST', 'Provisional Invoice(Secondary)', 6,
             2, 'APP-PFL-N-187',
             'function(){loadProvisionalInvoiceSecondary();}', NULL, 'LOII',
             'APP-ACL-N1097'
            );