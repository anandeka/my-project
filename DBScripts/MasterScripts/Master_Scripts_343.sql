
INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable, is_ref_no_gen_applicable
            )
     VALUES ('MODIFY_WNS_ASSAY', 'WS Assay ', 'Modify WS Assay', 'Y',
             'Modify WS Assay', 'N', NULL
            );

INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('MODIFY_WNS_ASSAY', 'Y', 'N',
             'activityDate', 'N', '2',
             'In Warehouse', 'N', 'N'
            );