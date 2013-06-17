/* Formatted on 2013/06/17 10:34 (Formatter Plus v4.8.8) */
SET DEFINE OFF;

-- List of GMR
INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('LOG_BFPD', 'LOG', 'Bulk Pricing Document', 13,
             2, NULL, 'function(){generateBulkPricingDocument();}', NULL,
             '102', NULL
            );

-- List of Tolling GMR

INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('MTGMR_BPFD', 'MTGMR_LIST', 'Bulk Pricing Document', 9,
             2, NULL, 'function(){generateBulkPricingDocument();}', NULL,
             'MTGMR_LIST_1', NULL
            );

-- List of Pledge GMR
INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('PM_BPFD', 'PM_LIST', 'Bulk Pricing Document', 2,
             2, NULL, 'function(){generateBulkPricingDocument();}', NULL,
             'PM_LIST_1', NULL
            );