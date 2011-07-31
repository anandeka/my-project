update CDC_CORPORATE_DOC_CONFIG cdc set CDC.DOC_RPT_FILE_NAME = 'InvoiceDocument.rpt'
where
cdc.DOC_ID in ('CREATE_PI','CREATE_FI','CREATE_DFI');