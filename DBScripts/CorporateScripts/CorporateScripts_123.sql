/* Formatted on 2013/06/17 11:12 (Formatter Plus v4.8.8) */
-- Bulk Pricing Document.
SET define off;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      --CDC
         -- GMR
      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id,
                   doc_id, doc_template_name,
                   doc_template_name_de, doc_template_name_es,
                   doc_print_name, doc_print_name_de, doc_print_name_es,
                   doc_rpt_file_name, is_active, doc_auto_generate
                  )
           VALUES ('BPFDG-' || cc.corporate_id, cc.corporate_id,
                   'BULK_PRICE_FIXATION_GMR', 'Bulk Price Fixation - GMR',
                   NULL, NULL,
                   NULL, NULL, NULL,
                   'BulkPricingDocument.rpt', 'Y', 'Y'
                  );

--MFT GMR
      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id,
                   doc_id,
                   doc_template_name, doc_template_name_de,
                   doc_template_name_es, doc_print_name, doc_print_name_de,
                   doc_print_name_es, doc_rpt_file_name, is_active,
                   doc_auto_generate
                  )
           VALUES ('BPFDMFTG-' || cc.corporate_id, cc.corporate_id,
                   'BULK_PRICE_FIXATION_MFTGMR',
                   'Bulk Price Fixation - MFT GMR', NULL,
                   NULL, NULL, NULL,
                   NULL, 'BulkPricingDocument.rpt', 'Y',
                   'Y'
                  );

--Pledge GMR
      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id,
                   doc_id,
                   doc_template_name, doc_template_name_de,
                   doc_template_name_es, doc_print_name, doc_print_name_de,
                   doc_print_name_es, doc_rpt_file_name, is_active,
                   doc_auto_generate
                  )
           VALUES ('BPFDPLG-' || cc.corporate_id, cc.corporate_id,
                   'BULK_PRICE_FIXATION_PLGMR',
                   'Bulk Price Fixation - Pledge GMR', NULL,
                   NULL, NULL, NULL,
                   NULL, 'BulkPricingDocument.rpt', 'Y',
                   'Y'
                  );

      --DC
      INSERT INTO dc_document_configuration
                  (activity_id, corporate_id, is_generate_doc_reqd,
                   is_upload_doc_reqd,
                   doc_validation_query,
                   navigation
                  )
           VALUES ('BULK_PRICE_FIXATION_GMR', cc.corporate_id, 'Y',
                   'N',
                   'select count(*) as countRow
from BPFD_BULK_PFD_D bpfd_d
where bpfd_d.INTERNAL_DOC_REF_NO = ?',
                   '/metals/listingOfGMR.do?method=loadListOfGMR&gridId=LOG'
                  );

--MFT GMR
      INSERT INTO dc_document_configuration
                  (activity_id, corporate_id, is_generate_doc_reqd,
                   is_upload_doc_reqd,
                   doc_validation_query,
                   navigation
                  )
           VALUES ('BULK_PRICE_FIXATION_MFTGMR', cc.corporate_id, 'Y',
                   'N',
                   'select count(*) as countRow
from BPFD_BULK_PFD_D bpfd_d
where bpfd_d.INTERNAL_DOC_REF_NO = ?',
                   '/metals/loadListOfMiningTollingGMR.action?gridId=MTGMR_LIST'
                  );

      --Pledge GMR
      INSERT INTO dc_document_configuration
                  (activity_id, corporate_id, is_generate_doc_reqd,
                   is_upload_doc_reqd,
                   doc_validation_query,
                   navigation
                  )
           VALUES ('BULK_PRICE_FIXATION_PLGMR', cc.corporate_id, 'Y',
                   'N',
                   'select count(*) as countRow
from BPFD_BULK_PFD_D bpfd_d
where bpfd_d.INTERNAL_DOC_REF_NO = ?',
                   '/metals/loadListofPledgeMaterial.action?gridId=PM_LIST'
                  );

      -- DRF , DRFM
      -- GMR
      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-BD-GM-' || cc.corporate_id, 'BFPD-GMR',
                   cc.corporate_id, 'BPFDG-', 0,
                   0, '-' || cc.corporate_id, NULL, 'N'
                  );

      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id,
                   doc_id, doc_key_id, is_deleted
                  )
           VALUES ('DRFM-BD-GM-' || cc.corporate_id, cc.corporate_id,
                   'BULK_PRICE_FIXATION_GMR', 'BFPD-GMR', 'N'
                  );

-- MFT GMR
      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-BD-MG-' || cc.corporate_id, 'BFPD-MTGMR',
                   cc.corporate_id, 'BPFDMG-', 0,
                   0, '-' || cc.corporate_id, NULL, 'N'
                  );

      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id,
                   doc_id, doc_key_id, is_deleted
                  )
           VALUES ('DRFM-BD-MG-' || cc.corporate_id, cc.corporate_id,
                   'BULK_PRICE_FIXATION_MFTGMR', 'BFPD-MTGMR', 'N'
                  );

-- Pledge GMR
      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-BD-PG-' || cc.corporate_id, 'BFPD-PLGMR',
                   cc.corporate_id, 'BPFDG-', 0,
                   0, '-' || cc.corporate_id, NULL, 'N'
                  );

      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id,
                   doc_id, doc_key_id, is_deleted
                  )
           VALUES ('DRFM-BD-PG-' || cc.corporate_id, cc.corporate_id,
                   'BULK_PRICE_FIXATION_PLGMR', 'BFPD-PLGMR', 'N'
                  );
   END LOOP;
END;
/