INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Fully Priced', 'Fully Priced'
            );

INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Price Finalized', 'Price Finalized'
            );


INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Partially Priced', 'Partially Priced'
            );

INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('UnPriced', 'UnPriced'
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestPricingType', 'Fully Priced', 'N', 1
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestPricingType', 'Price Finalized', 'N', 2
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestPricingType', 'Partially Priced', 'N', 3
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestPricingType', 'UnPriced', 'N', 4
            );

Commit;