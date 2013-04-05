DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM_OCI_1' AND DGM.DOC_ID = 'CREATE_OCI' AND DGM.ACTIVITY_ID='CREATE_OCI' AND DGM.SEQUENCE_ORDER=1;

DELETE FROM DGM_DOCUMENT_GENERATION_MASTER DGM WHERE DGM.DGM_ID='DGM_OCI_IOC' AND DGM.DOC_ID = 'CREATE_OCI' AND DGM.ACTIVITY_ID='CREATE_OCI' AND DGM.SEQUENCE_ORDER=2;



declare fetchQueryOCI CLOB := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, description, quantity_unit,
             amount_unit, internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                (CASE
                    WHEN (scm.cost_display_name IS NULL)
                       THEN mcc.charge_name
                    ELSE scm.cost_display_name
                 END
                ) AS other_charge_cost_name,
                ioc.charge_type AS charge_type,
                (CASE
                    WHEN (ioc.rate_fx_rate IS NULL)
                    AND (ioc.flat_amount_fx_rate IS NULL)
                       THEN 1
                    WHEN ioc.rate_fx_rate IS NULL
                       THEN ioc.flat_amount_fx_rate
                    ELSE ioc.rate_fx_rate
                 END
                ) AS fx_rate,
                ioc.quantity AS quantity,
                NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                ioc.amount_in_inv_cur AS invoice_amount,
                cm.cur_code AS invoice_cur_name,
                (CASE
                    WHEN ioc.rate_price_unit = ''Bags''
                    AND ioc.charge_type = ''Rate''
                       THEN cm.cur_code || ''/'' || ''Bag''
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                    AND ioc.charge_type = ''Rate''
                       THEN cm_lot.cur_code || ''/'' || ''Lot''
                    ELSE pum.price_unit_name
                 END
                ) AS rate_price_unit_name,
                NVL (ioc.flat_amount, ioc.rate_charge) AS charge_amount_rate,
                NVL (ioc.other_charge_desc,
                     aml.attribute_name) AS description,
                (CASE
                    WHEN ioc.rate_price_unit = ''Bags''
                       THEN ''Bags''
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                       THEN ''Lots''
                    WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                       THEN ''Lots''
                    ELSE qum.qty_unit
                 END
                ) AS quantity_unit,
                (CASE
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                    AND ioc.charge_type = ''Rate''
                       THEN cm_lot.cur_code
                    WHEN scm.cost_component_name IN (''Handling Charge'')
                       THEN cm.cur_code
                    WHEN ioc.charge_type = ''Rate''
                       THEN cm_pum.cur_code
                    ELSE cm_ioc.cur_code
                 END
                ) AS amount_unit,
                ?
           FROM is_invoice_summary invs,
                ioc_invoice_other_charge ioc,
                cm_currency_master cm,
                scm_service_charge_master scm,
                ppu_product_price_units ppu,
                pum_price_unit_master pum,
                qum_quantity_unit_master qum,
                cm_currency_master cm_ioc,
                cm_currency_master cm_pum,
                cm_currency_master cm_lot,
                mcc_miscellaneous_comm_charges mcc,
                aml_attribute_master_list aml
          WHERE invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
            AND ioc.other_charge_cost_id = scm.cost_id(+)
            AND ioc.other_charge_cost_id = mcc.mcc_id(+)
            AND mcc.element_id = aml.attribute_id(+)
            AND ioc.invoice_cur_id = cm.cur_id(+)
            AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
            AND ioc.rate_price_unit = cm_lot.cur_id(+)
            AND ppu.price_unit_id = pum.price_unit_id(+)
            AND ioc.qty_unit_id = qum.qty_unit_id(+)
            AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
            AND cm_pum.cur_id(+) = pum.cur_id
            AND ioc.internal_invoice_ref_no = ?)
   SELECT *
     FROM TEST t
    WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';



fetchQueryISOCI CLOB :=
'INSERT INTO IS_D(
INTERNAL_INVOICE_REF_NO,
INVOICE_REF_NO,
CP_NAME,
SUPPLIRE_INVOICE_NO,
CP_ADDRESS,
INVOICE_CREATION_DATE,
DUE_DATE,
PAYMENT_TERM,
CONTRACT_TYPE,
internal_comments, invoice_status,invoice_amount, adjustment_amount, invoice_amount_unit, internal_doc_ref_no
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PHD.COMPANYNAME as CP_NAME,
INVS.CP_REF_NO as SUPPLIRE_INVOICE_NO,
INVS.BILL_TO_ADDRESS as CP_ADDRESS,
INVS.INVOICE_ISSUE_DATE as INVOICE_CREATION_DATE,
INVS.PAYMENT_DUE_DATE as DUE_DATE,
PYM.PAYMENT_TERM as PAYMENT_TERM,
INVS.RECIEVED_RAISED_TYPE as CONTRACT_TYPE, INVS.INTERNAL_COMMENTS as internal_comments, INVS.INVOICE_STATUS as invoice_status, INVS.TOTAL_AMOUNT_TO_PAY as invoice_amount,
invs.invoice_adjustment_amount As adjustment_amount, cm.cur_code AS invoice_amount_unit, ?
from
IS_INVOICE_SUMMARY invs,
PHD_PROFILEHEADERDETAILS phd,
PYM_PAYMENT_TERMS_MASTER pym,
CM_CURRENCY_MASTER cm
where
INVS.CP_ID = PHD.PROFILEID
AND INVS.INVOICE_CUR_ID = CM.CUR_ID
and PYM.PAYMENT_TERM_ID = INVS.CREDIT_TERM 
and INVS.INTERNAL_INVOICE_REF_NO = ?';
      
begin
INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM_OCI_IOC','CREATE_OCI','Output Charge Invoice','CREATE_OCI',2,fetchQueryOCI,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM_OCI_1','CREATE_OCI','Output Charge Invoice','CREATE_OCI',1,fetchQueryISOCI,'N');

commit;
end;