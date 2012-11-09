DECLARE
fetchQuery1 CLOB :='INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction,'' as remarks, ?
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
    update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQuery1 where DGM.DGM_ID IN('DGM-PIC-C5','DGM-PI-C3','DGM-FI-C3','DGM-FIC-C5','DGM-DFIC-C5','DGM-DFI-C3','DGM-PFI-3','DGM-PFI-3-CONC','DGM-API-2-CONC','DGM-API-2','DGM-SIC-3','DGM-SI-3');
commit;
END;

DECLARE
fetchQuery1 CLOB :='INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          bpb.bank_name AS bank_name, bpa.account_no AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction,'' as remarks, ?
     FROM bpa_bp_bank_accounts bpa,
          bpb_business_partner_banks bpb,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = bpa.bank_id
      AND bpa.bank_id = bpb.bank_id
      and CPIPI.BANK_ACCOUNT_ID = BPA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?'; 
BEGIN
    update DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQuery1 where DGM.DGM_ID IN('DGM-PIC-C6','DGM-PI-C4','DGM-FI-C4','DGM-FIC-C6','DGM-DFIC-C6','DGM-DFI-C4','DGM-PFI-4','DGM-PFI-4-CONC','DGM-API-3-CONC','DGM-API-3','DGM-SIC-2','DGM-SI-2');
commit;
END;