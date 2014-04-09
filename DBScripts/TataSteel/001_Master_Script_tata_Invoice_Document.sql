update cdc_corporate_doc_config cdc
set cdc.doc_rpt_file_name = 'TATA_InvoiceDocument.rpt'
where cdc.doc_rpt_file_name = 'InvoiceDocument.rpt';
commit;



Testing commit through GIT