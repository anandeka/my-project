declare
fetchqry1 clob :='INSERT INTO is_parent_child_d
            (internal_invoice_ref_no, invoice_ref_no, invoice_issue_date,
             due_date, invoice_currency, invoice_amount, internal_doc_ref_no)
WITH TEST AS
     (SELECT invs.internal_invoice_ref_no,
             (CASE
                 WHEN invs.prov_pctg_amt IS NOT NULL
                 AND invs.freight_allowance_amt IS NOT NULL
                    THEN invs.prov_pctg_amt + invs.freight_allowance_amt
                 WHEN invs.prov_pctg_amt IS NOT NULL
                 AND invs.freight_allowance_amt IS NULL
                    THEN invs.prov_pctg_amt
                 WHEN invs.amount_to_pay_before_adj IS NOT NULL
                 AND invs.freight_allowance_amt IS NOT NULL
                    THEN   invs.amount_to_pay_before_adj
                         + invs.freight_allowance_amt
                 ELSE invs.amount_to_pay_before_adj
              END
             ) AS invoice_amount
        FROM is_invoice_summary invs)
SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
       invs.invoice_ref_no AS invoice_ref_no,
       invs.invoice_issue_date AS invoice_issue_date,
       invs.payment_due_date AS due_date, cm.cur_code AS invoice_currency,
       (CASE
           WHEN invs.invoice_adjustment_amount IS NOT NULL
              THEN t.invoice_amount + invs.invoice_adjustment_amount
           ELSE t.invoice_amount
        END
       ) AS invoice_amount,
       ?
  FROM is_invoice_summary invs,
       cpcr_commercial_inv_pc_mapping cpcr,
       cm_currency_master cm,
       TEST t
 WHERE cpcr.parent_invoice_ref_no = invs.internal_invoice_ref_no
   AND invs.invoice_cur_id = cm.cur_id
   AND t.internal_invoice_ref_no = invs.internal_invoice_ref_no
   AND cpcr.internal_invoice_ref_no = ?';

BEGIN

 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-PIC-C7','DGM-FIC-C7','DGM-PI-C5','DGM-FI-C5','DGM-DFIC-C7','DGM-DFI-C5');
 commit;
  

END;