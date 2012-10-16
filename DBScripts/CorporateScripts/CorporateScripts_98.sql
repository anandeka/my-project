
BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      DELETE FROM dc_document_configuration dc
            WHERE dc.activity_id = 'salesLandingDetail'
              AND dc.corporate_id = cc.corporate_id;

      INSERT INTO dc_document_configuration
                  (activity_id, corporate_id, is_generate_doc_reqd,
                   is_upload_doc_reqd,
                   doc_validation_query,
                   navigation
                  )
           VALUES ('salesLandingDetail', cc.corporate_id, 'N',
                   'Y',
                   'select count(*) as countRow 
        from SAD_D sad
        where SAD.INTERNAL_DOC_REF_NO = ?',
                   '/metals/listingOfGMR.do?method=loadListOfGMR&gridId=LOG'
                  );
   END LOOP;
END;