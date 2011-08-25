
UPDATE dkm_doc_ref_key_master dkm
   SET dkm.validation_query =
          'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
 WHERE dkm.doc_key_id = 'DKM-101'