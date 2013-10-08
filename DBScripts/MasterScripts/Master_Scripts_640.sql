UPDATE cdc_corporate_doc_config cdc
   SET cdc.doc_rpt_file_name = 'QP_confirmation_Document.rpt'
 WHERE cdc.doc_id = 'QPC_DOC';