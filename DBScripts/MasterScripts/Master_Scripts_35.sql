Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-PI-C3', 'CREATE_PI', 'Provisional Invoice', 'CREATE_PI', 3, 
    'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, ?
     FROM phd_profileheaderdetails phd,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oipi.bank_id = phd.profileid
      AND invs.internal_invoice_ref_no = ?', 'N');
      
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-PI-C4', 'CREATE_PI', 'Provisional Invoice', 'CREATE_PI', 4, 
    'INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, cpipi.bank_account AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction, ?
     FROM phd_profileheaderdetails phd,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = phd.profileid
      AND invs.internal_invoice_ref_no = ?', 'N');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-FI-C3', 'CREATE_FI', 'Final Invoice', 'CREATE_FI', 3, 
    'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, ?
     FROM phd_profileheaderdetails phd,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oipi.bank_id = phd.profileid
      AND invs.internal_invoice_ref_no = ?', 'N');
      
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-FI-C4', 'CREATE_FI', 'Final Invoice', 'CREATE_FI', 4, 
    'INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, cpipi.bank_account AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction, ?
     FROM phd_profileheaderdetails phd,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = phd.profileid
      AND invs.internal_invoice_ref_no = ?', 'N');


Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFI-C3', 'CREATE_DFI', 'Direct Invoice', 'CREATE_DFI', 3, 
    'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, ?
     FROM phd_profileheaderdetails phd,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oipi.bank_id = phd.profileid
      AND invs.internal_invoice_ref_no = ?', 'N');
      
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFI-C4', 'CREATE_DFI', 'Direct Invoice', 'CREATE_DFI', 4, 
    'INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, cpipi.bank_account AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction, ?
     FROM phd_profileheaderdetails phd,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = phd.profileid
      AND invs.internal_invoice_ref_no = ?', 'N');