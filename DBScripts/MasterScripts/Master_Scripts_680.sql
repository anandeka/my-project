INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('MetalTransactionActivity', 'CREATE_RETURN_MATERIAL', 'N', 10
            );

UPDATE slv_static_list_value slv
   SET slv.value_text = 'Tolling Return Material'
 WHERE slv.value_id = 'CREATE_RETURN_MATERIAL';