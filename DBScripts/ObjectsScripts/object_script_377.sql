

INSERT INTO gmc_grid_menu_configuration
                (menu_id, grid_id, menu_display_name, display_seq_no,
                 menu_level_no, FEATURE_ID, link_called,
                 icon_class, menu_parent_id, acl_id
                )
         VALUES ('MIN_1_6', 'MIN_LOC', 'Clone As Opposite', 6,
                 2, 'APP-PFL-N-220', 'function(){cloneAsOpposite();}',
                 NULL, 'MIN_1', 'APP-ACL-N1379'
            );


INSERT INTO gmc_grid_menu_configuration
                (menu_id, grid_id, menu_display_name, display_seq_no,
                 menu_level_no, FEATURE_ID, link_called,
                 icon_class, menu_parent_id, acl_id
                )
         VALUES ('LOC_1_8', 'PHY_LOC', 'Clone as Sales Contract', 12,
                 2, 'APP-PFL-N-191', 'function(){cloneAsSalesContract();}',
                 NULL, 'LOC_1', 'APP-ACL-N1131'
            );


 UPDATE gmc_grid_menu_configuration gmc
    SET gmc.menu_display_name = 'Clone as Purchase Contract',gmc.link_called = 'function(){cloneAsPurchaseContract();}'
 WHERE gmc.menu_id = 'LOC_1_7';