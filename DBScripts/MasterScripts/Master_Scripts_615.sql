DECLARE
   fetchqueryforBMBDSDetails   CLOB
      := 'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,iban,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, OIPI.REMARKS as remarks,OBA.IBAN as IBAN, ?
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
   UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchqueryforBMBDSDetails WHERE DGM.DOC_ID IN ('CREATE_FI','CREATE_PI','CREATE_DFI','CREATE_API','CREATE_PFI') AND DGM.DGM_ID IN ('DGM-FI-C3','DGM-PI-C3','DGM-DFI-C3','DGM-API-2','DGM-PFI-3') AND DGM.SEQUENCE_ORDER = 3 AND DGM.IS_CONCENTRATE='N';

   UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchqueryforBMBDSDetails WHERE DGM.DOC_ID IN ('CREATE_DC') AND DGM.DGM_ID IN ('DGM-BDS-DC_BM') AND DGM.SEQUENCE_ORDER = 5 AND DGM.IS_CONCENTRATE='N';

   COMMIT;
END;