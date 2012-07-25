--List of Fx Exposure

INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url, default_record_model_state, other_url,
             screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('LOFE', 'List of FX Exposure',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\"></div>","hideable":false,"id":"checker","sortable":false,"width":20},
   {"dataIndex":"product","header":"Product","id":1,"sortable":true,"width":150},
   {"dataIndex":"priceFixationRefNo","header":"Price Fixation Ref.No.","id":2,"sortable":true,"width":150},
   {"dataIndex":"contractType","header":"Contract Type","id":3,"sortable":true,"width":150},
   {"dataIndex":"deliveryItemRefNo","header":"Dl Ref.No.","id":4,"sortable":true,"width":150},
   {"dataIndex":"profitCenter","header":"Profit Center","id":5,"sortable":true,"width":150},
   {"dataIndex":"priceFixationDate","header":"Price Fixation Date","id":6,"sortable":true,"width":150},
   {"dataIndex":"price","header":"Price","id":7,"sortable":true,"width":150},
   {"dataIndex":"qpPeriod","header":"QP Period","id":8,"sortable":true,"width":150},
   {"dataIndex":"qtyPriced","header":"Qty.Priced","id":9,"sortable":true,"width":150},
   {"dataIndex":"gmrAllocatedQty","header":"GMR Allocated Qty.","id":10,"sortable":true,"width":150},
   {"dataIndex":"cpName","header":"CP Name","id":11,"sortable":true,"width":150},
   {"dataIndex":"deliveryItemPeriod","header":"Dl Period","id":12,"sortable":true,"width":150},
   {"dataIndex":"hedgeAllocationStatus","header":"Hedge Allocation Status","id":13,"sortable":true,"width":150},
   {"dataIndex":"hedgeAmount","header":"Hedge Amount","id":13,"sortable":true,"width":150},
   {"dataIndex":"fXCorrectionDate","header":"FX Correction Date","id":13,"sortable":true,"width":150},
   {"dataIndex":"fXFixationDate","header":"FX Fixation Date","id":13,"sortable":true,"width":150}]',
             NULL, '/metals/loadListOfFXExposure.action', '[', NULL,
             'physical/derivative/listing/listOfFXExposure.jsp',
             '/private/js/physical/derivative/listing/listOfFXExposure.js'
            );
            
            
INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called, icon_class,
             menu_parent_id, acl_id, tab_id, FEATURE_ID, is_deleted
            )
     VALUES ('MINING_LOFE', 'List of FX Exposure', '5', '3',
             '/metals/loadListOfFXExposure.action?gridId=LOFE', NULL,
             'PE1.3', NULL, 'Period End', 'APP-PFL-N-196','N'
            );

INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('LOFE_1', 'LOFE', 'Operation', '1',
             '1', NULL, NULL, NULL,
             NULL, NULL
            );

INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('LOFE_2', 'LOFE', 'Allocate Hedge', '1',
             '2', NULL, NULL, NULL,
             NULL, NULL
            );


--delete Generate Contract Document,Mark as closed, update Cost&Valuation
delete from GMC_GRID_MENU_CONFIGURATION gmc where GMC.MENU_ID='MIN_1_6';
delete from GMC_GRID_MENU_CONFIGURATION gmc where GMC.MENU_ID='MIN_1_7'; 
delete from GMC_GRID_MENU_CONFIGURATION gmc where GMC.MENU_ID='MIN_1_8';