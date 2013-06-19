INSERT INTO axm_action_master
            (action_id, entity_id,
             action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable,
             is_ref_no_gen_applicable, is_event_publish_applicable,
             is_continuous_middle_no_req, is_required_for_eodeom,
             is_activity_log_applicable, is_recent_record_applicable,
             navigation_url
            )
     VALUES ('RECEIVE_MATERIAL_MODIFY', 'GMR Tolling ',
             'Receive Material Modify', 'Y',
             'GMR Receive Material Modification', 'N',
             NULL, 'N',
             'N', 'Y',
             'Y', 'Y',
             NULL
            );

INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('RECEIVE_MATERIAL_MODIFY', 'Y', 'N',
             'activityDate', 'N', '2',
             'In Warehouse', 'N', 'N'
            );