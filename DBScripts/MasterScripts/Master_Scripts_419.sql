/* Formatted on 2012/09/28 11:54 (Formatter Plus v4.8.8) */
INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Finalized', 'Finalized'
            );
INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Not Finalized', 'Not Finalized'
            );


INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('assayFinalizationStatus', 'Finalized', 'N', 1
            );
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('assayFinalizationStatus', 'Not Finalized', 'N', 2
            );