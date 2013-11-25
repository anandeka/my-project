DECLARE
   fetchqryis_bds_child_d   CLOB
      := 'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks, iban, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, OIPI.REMARKS as remarks, oba.iban, ?
     FROM phd_profileheaderdetails phd,
          oba_our_bank_accounts oba,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi  
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oba.bank_id = phd.profileid
      AND oba.bank_id = oipi.bank_id
      and OIPI.BANK_ACCOUNT_ID = OBA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?';
BEGIN
   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM-PIC-C5'
      AND dgm.doc_id = 'CREATE_PI'
      AND dgm.sequence_order = 6
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM-FIC-C5'
      AND dgm.doc_id = 'CREATE_FI'
      AND dgm.sequence_order = 6
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM-DFIC-C5'
      AND dgm.doc_id = 'CREATE_DFI'
      AND dgm.sequence_order = 6
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM-DC-CONC-BDS'
      AND dgm.doc_id = 'CREATE_DC'
      AND dgm.sequence_order = 6
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM-API-2-CONC'
      AND dgm.doc_id = 'CREATE_API'
      AND dgm.sequence_order = 3
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM-SIC-3'
      AND dgm.doc_id = 'CREATE_SI'
      AND dgm.sequence_order = 5
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM-PFI-3-CONC'
      AND dgm.doc_id = 'CREATE_PFI'
      AND dgm.sequence_order = 3
      AND dgm.is_concentrate = 'Y';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM-CFI-C3'
      AND dgm.doc_id = 'CREATE_CFI'
      AND dgm.sequence_order = 3
      AND dgm.is_concentrate = 'N';

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryis_bds_child_d
    WHERE dgm.dgm_id = 'DGM_OCI_BDS'
      AND dgm.doc_id = 'CREATE_OCI'
      AND dgm.sequence_order = 4
      AND dgm.is_concentrate = 'N';

   COMMIT;
END;