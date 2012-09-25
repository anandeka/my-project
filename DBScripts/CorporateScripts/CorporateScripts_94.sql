
UPDATE drf_doc_ref_number_format drf
         SET drf.suffix = '-' || drf.corporate_id
       WHERE drf.doc_key_id = 'DKMRO-1';