UPDATE drf_doc_ref_number_format drf
   SET drf.prefix = 'AMDSC-'
 WHERE drf.doc_ref_number_format_id IN
                           ('DRF-565', 'DRF-AMDSC-LDE', 'DRF-685', 'DRF-775');