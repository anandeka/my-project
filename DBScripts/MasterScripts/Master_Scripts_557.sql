declare
fetchQrybds CLOB := 'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, OIPI.REMARKS as remarks, ?
     FROM phd_profileheaderdetails phd,
          oba_our_bank_accounts oba,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi  
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oba.bank_id = phd.profileid
      AND oba.bank_id = oipi.bank_id
      and OIPI.BANK_ACCOUNT_ID = OBA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?';

begin
    UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQrybds where DGM.DOC_ID IN ('CREATE_API','CREATE_CFI','CREATE_DC','CREATE_DFI','CREATE_DFT_API','CREATE_DFT_DFI','CREATE_DFT_FI','CREATE_DFT_PI','CREATE_FI','CREATE_OCI','CREATE_PFI','CREATE_PI','CREATE_SI') and DGM.DGM_ID IN ('CREATE_DFT_APIC_3','CREATE_DFT_API_3','CREATE_DFT_DFIC_6','CREATE_DFT_FIC_6','CREATE_DFT_PIC_6','DGM-API-2','DGM-API-2-CONC','DGM-CFI-C3','DGM-DC-CONC-BDS','DGM-DFI-C3','DGM-DFIC-C5','DGM-DFT-DFI-C3','DGM-DFT-FI-C3','DGM-DFT-PI-C3','DGM-FI-C3','DGM-FIC-C5','DGM-PFI-3','DGM-PFI-3-CONC','DGM-PI-C3','DGM-PIC-C5','DGM-SI-3','DGM-SIC-3','DGM_OCI_BDS');
commit;
end;