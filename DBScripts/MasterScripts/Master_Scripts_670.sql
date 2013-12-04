/* Formatted on 2013/12/04 15:50 (Formatter Plus v4.8.8) */
INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Partial Provisional Assay', 'Partial Provisional Assay'
            );

INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Weighing and Sampling Assay', 'Weighing and Sampling Assay'
            );

INSERT INTO slv_static_list_value
            (value_id,
             value_text
            )
     VALUES ('Partial Weighing and Sampling Assay',
             'Partial Weighing and Sampling Assay'
            );

INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Partial Self Assay', 'Partial Self Assay'
            );

INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('Partial Final Assay', 'Partial Final Assay'
            );


INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestAssayType', 'Provisional Assay', 'N', 1
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestAssayType', 'Partial Provisional Assay', 'N', 2
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestAssayType', 'Weighing and Sampling Assay', 'N', 3
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestAssayType', 'Partial Weighing and Sampling Assay', 'N', 4
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestAssayType', 'Self Assay', 'N', 5
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestAssayType', 'Partial Self Assay', 'N', 6
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestAssayType', 'Final Assay', 'N', 7
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestAssayType', 'Partial Final Assay', 'N', 8
            );


INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestInvoiceType', 'Provisional', 'N', 1
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestInvoiceType', 'Final', 'N', 2
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('LatestInvoiceType', 'DirectFinal', 'N', 3
            );