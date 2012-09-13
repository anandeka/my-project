INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Internal Movement', 'Internal Movement'
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('bookingbasis', 'Purchase', 'N', 1
            );
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('bookingbasis', 'Sales', 'N', 2
            );
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('bookingbasis', 'Internal Movement', 'N', 3
            );