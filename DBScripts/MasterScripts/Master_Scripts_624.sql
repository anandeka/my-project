DECLARE fetchQueryISPCDC CLOB := 'INSERT INTO is_parent_child_d
            (internal_invoice_ref_no, invoice_ref_no, invoice_issue_date,
             due_date, invoice_currency, invoice_amount, prov_pymt_percentage,
             invoice_type_name, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
       invs.invoice_ref_no AS invoice_ref_no,
       invs.invoice_issue_date AS invoice_issue_date,
       invs.payment_due_date AS due_date, cm.cur_code AS invoice_currency,
       (CASE
           WHEN invs.prov_pctg_amt IS NOT NULL
           AND invs.freight_allowance_amt IS NOT NULL
           AND invs.invoice_adjustment_amount IS NOT NULL
              THEN   invs.prov_pctg_amt
                   + invs.freight_allowance_amt
                   + invs.invoice_adjustment_amount
           WHEN invs.prov_pctg_amt IS NOT NULL
           AND invs.invoice_adjustment_amount IS NOT NULL
              THEN invs.prov_pctg_amt + invs.invoice_adjustment_amount
           WHEN invs.prov_pctg_amt IS NOT NULL
           AND invs.freight_allowance_amt IS NOT NULL
              THEN invs.prov_pctg_amt + invs.freight_allowance_amt
           WHEN invs.prov_pctg_amt IS NOT NULL
              THEN invs.prov_pctg_amt
           WHEN invs.prov_pctg_amt IS NULL
           AND invs.freight_allowance_amt IS NOT NULL
           AND invs.invoice_adjustment_amount IS NOT NULL
              THEN   invs.amount_to_pay_before_adj
                   + invs.freight_allowance_amt
                   + invs.invoice_adjustment_amount
           WHEN invs.invoice_adjustment_amount IS NOT NULL
              THEN   invs.amount_to_pay_before_adj
                   + invs.invoice_adjustment_amount
           WHEN invs.freight_allowance_amt IS NOT NULL
              THEN invs.amount_to_pay_before_adj + invs.freight_allowance_amt
           ELSE invs.amount_to_pay_before_adj
        END
       ) AS invoice_amount,
       NVL (TO_CHAR (invs.provisional_pymt_pctg),
            ''100''
           ) AS prov_pymt_percentage,
       invs.invoice_type_name AS invoice_type_name, ?
  FROM is_invoice_summary invs,
       cpcr_commercial_inv_pc_mapping cpcr,
       cm_currency_master cm
 WHERE cpcr.parent_invoice_ref_no = invs.internal_invoice_ref_no
   AND invs.invoice_cur_id = cm.cur_id
   AND cpcr.internal_invoice_ref_no = ?';

fetchQueryISPCDBM CLOB :='INSERT INTO is_parent_child_d
            (internal_invoice_ref_no, invoice_ref_no, invoice_issue_date,
             due_date, invoice_currency, invoice_amount, prov_pymt_percentage,
             invoice_type_name, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
       invs.invoice_ref_no AS invoice_ref_no,
       invs.invoice_issue_date AS invoice_issue_date,
       invs.payment_due_date AS due_date, cm.cur_code AS invoice_currency,
       (CASE
           WHEN invs.prov_pctg_amt IS NOT NULL
           AND invs.freight_allowance_amt IS NOT NULL
              THEN invs.prov_pctg_amt + invs.freight_allowance_amt
           WHEN invs.prov_pctg_amt IS NOT NULL
              THEN invs.prov_pctg_amt
           WHEN invs.prov_pctg_amt IS NULL
           AND invs.freight_allowance_amt IS NOT NULL
              THEN invs.amount_to_pay_before_adj + invs.freight_allowance_amt
           WHEN invs.freight_allowance_amt IS NOT NULL
              THEN invs.amount_to_pay_before_adj + invs.freight_allowance_amt
           ELSE invs.amount_to_pay_before_adj
        END
       ) AS invoice_amount,
       NVL (TO_CHAR (invs.provisional_pymt_pctg),
            ''100''
           ) AS prov_pymt_percentage,
       invs.invoice_type_name AS invoice_type_name, ?
  FROM is_invoice_summary invs,
       cpcr_commercial_inv_pc_mapping cpcr,
       cm_currency_master cm
 WHERE cpcr.parent_invoice_ref_no = invs.internal_invoice_ref_no
   AND invs.invoice_cur_id = cm.cur_id
   AND cpcr.internal_invoice_ref_no = ?';

BEGIN
    UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryISPCDC WHERE DGM.DGM_ID IN ('DGM-PIC-C7','DGM-FIC-C7','DGM-DFIC-C7') AND DGM.DOC_ID IN ('CREATE_PI','CREATE_FI','CREATE_DFI') AND DGM.SEQUENCE_ORDER IN (8) AND DGM.IS_CONCENTRATE = 'Y';

    UPDATE DGM_DOCUMENT_GENERATION_MASTER DGM SET DGM.FETCH_QUERY=fetchQueryISPCDC WHERE DGM.DGM_ID IN ('DGM-DFI-C5','DGM-FI-C5','DGM-PI-C5') AND DGM.DOC_ID IN ('CREATE_DFI','CREATE_FI','CREATE_PI') AND DGM.SEQUENCE_ORDER IN (5) AND DGM.IS_CONCENTRATE = 'N';

COMMIT;
END;