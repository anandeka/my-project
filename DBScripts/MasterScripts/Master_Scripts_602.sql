/* Formatted on 2013/06/17 10:48 (Formatter Plus v4.8.8) */
--- Bulk Pricing document Master scripts

-- DM
--GMR
INSERT INTO dm_document_master
            (doc_id, doc_name, display_order, VERSION,
             is_active, is_deleted, activity_id, is_continuous_middle_no_req
            )
     VALUES ('BULK_PRICE_FIXATION_GMR', 'Bulk Price Fixation - GMR', 1, NULL,
             'Y', 'N', NULL, 'Y'
            );

            --MFT GMR
INSERT INTO dm_document_master
            (doc_id, doc_name,
             display_order, VERSION, is_active, is_deleted, activity_id,
             is_continuous_middle_no_req
            )
     VALUES ('BULK_PRICE_FIXATION_MFTGMR', 'Bulk Price Fixation - MFT GMR',
             1, NULL, 'Y', 'N', NULL,
             'Y'
            );

                 --Pledge GMR
INSERT INTO dm_document_master
            (doc_id, doc_name,
             display_order, VERSION, is_active, is_deleted, activity_id,
             is_continuous_middle_no_req
            )
     VALUES ('BULK_PRICE_FIXATION_PLGMR', 'Bulk Price Fixation - Pledge GMR',
             1, NULL, 'Y', 'N', NULL,
             'Y'
            );

--DGM
-- GMR
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id,
             doc_name, activity_id, sequence_order,
             fetch_query, is_concentrate
            )
     VALUES ('DGM-BPFD-1', 'BULK_PRICE_FIXATION_GMR',
             'Bulk Price Fixation - GMR', 'BULK_PRICE_FIXATION_GMR', 1,
             '{call GENERATE_BULK_PRICING_DOCUMENT(?,?,?,?)}', 'N'
            );

--MFT GMR

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id,
             doc_name, activity_id,
             sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM-BPFD-MFTGMR', 'BULK_PRICE_FIXATION_MFTGMR',
             'Bulk Price Fixation - MFT GMR', 'BULK_PRICE_FIXATION_MFTGMR',
             1, '{call GENERATE_BULK_PRICING_DOCUMENT(?,?,?,?)}', 'N'
            );


            --Pledge GMR
INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id,
             doc_name, activity_id,
             sequence_order, fetch_query, is_concentrate
            )
     VALUES ('DGM-BPFD-PLGMR', 'BULK_PRICE_FIXATION_PLGMR',
             'Bulk Price Fixation - Pledge GMR', 'BULK_PRICE_FIXATION_PLGMR',
             1, '{call GENERATE_BULK_PRICING_DOCUMENT(?,?,?,?)}', 'N'
            );

            -- DKM
-- GMR
INSERT INTO dkm_doc_ref_key_master
            (doc_key_id, doc_key_desc,
             validation_query
            )
     VALUES ('BFPD-GMR', 'Bulk Price Fixation - GMR',
             'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
            );
--MFT GMR
INSERT INTO dkm_doc_ref_key_master
            (doc_key_id, doc_key_desc,
             validation_query
            )
     VALUES ('BFPD-MTGMR', 'Bulk Price Fixation - MFT GMR',
             'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
            );
            --Pledge GMR

INSERT INTO dkm_doc_ref_key_master
            (doc_key_id, doc_key_desc,
             validation_query
            )
     VALUES ('BFPD-PLGMR', 'Bulk Price Fixation - Pledge GMR',
             'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
            );