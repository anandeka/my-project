fetchQryISDAPIBM CLOB := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_item_stock_ref_no,
             inco_term_location, contract_ref_no, cp_contract_ref_no,
             contract_date, product, invoice_quantity, invoiced_qty_unit,
             quality, payment_term, due_date, invoice_creation_date,
             invoice_amount, invoice_amount_unit, invoice_ref_no,
             contract_type, invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, internal_comments,
             our_person_incharge, adjustment_amount, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            phd.companyname AS cp_name,
            invs.cp_ref_no AS cp_item_stock_ref_no,
            pci.terms AS inco_term_location,
            pcm.contract_ref_no AS contract_ref_no,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') AS contract_date,
            pdm.product_desc AS product,
            invs.invoiced_qty AS invoice_quantity,
            qum.qty_unit AS invoiced_qty_unit, qat.quality_name AS quality,
            pym.payment_term AS payment_term,
            TO_CHAR (invs.payment_due_date, ''dd-Mon-yyyy'') AS due_date,
            TO_CHAR (invs.invoice_issue_date,
                     ''dd-Mon-yyyy''
                    ) AS invoice_creation_date,
            invs.total_amount_to_pay AS invoice_amount,
            cm.cur_code AS invoice_amount_unit,
            invs.invoice_ref_no AS invoice_ref_no,
            pcm.contract_type AS contract_type,
            invs.invoice_status AS invoice_status,
            pcm.purchase_sales AS sales_purchase,
            invs.total_tax_amount AS total_tax_amount,
            invs.total_other_charge_amount AS total_other_charge_amount,
            invs.internal_comments AS internal_comments,
            akuser.login_name AS our_person_incharge,
            invs.INVOICE_ADJUSTMENT_AMOUNT AS adjustment_amount, ?
       FROM is_invoice_summary invs,
            apid_adv_payment_item_details apid,
            pcm_physical_contract_main pcm,
            v_pci pci,
            phd_profileheaderdetails phd,
            pdm_productmaster pdm,
            qat_quality_attributes qat,
            pcpd_pc_product_definition pcpd,
            cm_currency_master cm,
            pym_payment_terms_master pym,
            qum_quantity_unit_master qum,
            ppu_product_price_units ppu,
            pum_price_unit_master pum,
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = apid.internal_invoice_ref_no
        AND apid.contract_item_ref_no = pci.internal_contract_item_ref_no
        AND invs.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND pcm.internal_contract_ref_no = akuser.user_id(+)
        AND pcpd.product_id = pdm.product_id
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.input_output = ''Input''
        AND pci.quality_id = qat.quality_id
        AND pcm.cp_id = phd.profileid(+)
        AND invs.invoice_cur_id = cm.cur_id
        AND invs.credit_term(+) = pym.payment_term_id
        AND apid.invoice_item_price_unit_id = ppu.internal_price_unit_id(+)
        AND ppu.price_unit_id = pum.price_unit_id
        AND invs.internal_invoice_ref_no = ?
   GROUP BY pcm.contract_ref_no,
            pdm.product_desc,
            qat.quality_name,
            phd.companyname,
            invs.cp_ref_no,
            pci.terms,
            pcm.cp_contract_ref_no,
            pcm.issue_date,
            invs.invoice_ref_no,
            invs.invoice_issue_date,
            invs.payment_due_date,
            invs.total_amount_to_pay,
            cm.cur_code,
            pym.payment_term,
            pcm.contract_type,
            invs.invoice_status,
            pcm.purchase_sales,
            invs.total_tax_amount,
            invs.total_other_charge_amount,
            pum.price_unit_name,
            invs.internal_invoice_ref_no,
            invs.invoiced_qty,
            qum.qty_unit,
            akuser.login_name,
            invs.internal_comments,
            invs.INVOICE_ADJUSTMENT_AMOUNT';


fetchQryISDAPIConc CLOB := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_item_stock_ref_no,
             inco_term_location, contract_ref_no, cp_contract_ref_no,
             contract_date, product, invoice_quantity, invoiced_qty_unit,
             quality, payment_term, due_date, invoice_creation_date,
             invoice_amount, invoice_amount_unit, invoice_ref_no,
             contract_type, invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, internal_comments,
             our_person_incharge, adjustment_amount, internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
            phd.companyname AS cp_name,
            invs.cp_ref_no AS cp_item_stock_ref_no,
            pci.terms AS inco_term_location,
            pcm.contract_ref_no AS contract_ref_no,
            pcm.cp_contract_ref_no AS cp_contract_ref_no,
            TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') AS contract_date,
            pdm.product_desc AS product,
            invs.invoiced_qty AS invoice_quantity,
            qum.qty_unit AS invoiced_qty_unit, qat.quality_name AS quality,
            pym.payment_term AS payment_term,
            TO_CHAR (invs.payment_due_date, ''dd-Mon-yyyy'') AS due_date,
            TO_CHAR (invs.invoice_issue_date,
                     ''dd-Mon-yyyy''
                    ) AS invoice_creation_date,
            invs.total_amount_to_pay AS invoice_amount,
            cm.cur_code AS invoice_amount_unit,
            invs.invoice_ref_no AS invoice_ref_no,
            pcm.contract_type AS contract_type,
            invs.invoice_status AS invoice_status,
            pcm.purchase_sales AS sales_purchase,
            invs.total_tax_amount AS total_tax_amount,
            invs.total_other_charge_amount AS total_other_charge_amount,
            invs.internal_comments AS internal_comments,
            akuser.login_name AS our_person_incharge,
            invs.INVOICE_ADJUSTMENT_AMOUNT AS adjustment_amount, ?
       FROM is_invoice_summary invs,
            apid_adv_payment_item_details apid,
            pcm_physical_contract_main pcm,
            v_pci pci,
            phd_profileheaderdetails phd,
            pdm_productmaster pdm,
            qat_quality_attributes qat,
            pcpd_pc_product_definition pcpd,
            cm_currency_master cm,
            pym_payment_terms_master pym,
            qum_quantity_unit_master qum,
            ppu_product_price_units ppu,
            pum_price_unit_master pum,
            ak_corporate_user akuser
      WHERE invs.internal_invoice_ref_no = apid.internal_invoice_ref_no
        AND apid.contract_item_ref_no = pci.internal_contract_item_ref_no
        AND invs.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
        AND pcm.internal_contract_ref_no = akuser.user_id(+)
        AND pcpd.product_id = pdm.product_id
        AND pcpd.qty_unit_id = qum.qty_unit_id
        AND pcpd.input_output = ''Input''
        AND pci.quality_id = qat.quality_id
        AND pcm.cp_id = phd.profileid(+)
        AND invs.invoice_cur_id = cm.cur_id
        AND invs.credit_term(+) = pym.payment_term_id
        AND apid.invoice_item_price_unit_id = ppu.internal_price_unit_id(+)
        AND ppu.price_unit_id = pum.price_unit_id
        AND invs.internal_invoice_ref_no = ?
   GROUP BY pcm.contract_ref_no,
            pdm.product_desc,
            qat.quality_name,
            phd.companyname,
            invs.cp_ref_no,
            pci.terms,
            pcm.cp_contract_ref_no,
            pcm.issue_date,
            invs.invoice_ref_no,
            invs.invoice_issue_date,
            invs.payment_due_date,
            invs.total_amount_to_pay,
            cm.cur_code,
            pym.payment_term,
            pcm.contract_type,
            invs.invoice_status,
            pcm.purchase_sales,
            invs.total_tax_amount,
            invs.total_other_charge_amount,
            pum.price_unit_name,
            invs.internal_invoice_ref_no,
            invs.invoiced_qty,
            qum.qty_unit,
            akuser.login_name,
            invs.internal_comments,
            invs.INVOICE_ADJUSTMENT_AMOUNT'; 

UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryISDAPIBM where DGM.DOC_ID IN ('CREATE_API') and DGM.DGM_ID IN ('DGM-API-1-1') and DGM.IS_CONCENTRATE = 'N' and DGM.SEQUENCE_ORDER = 1;

UPDATE DGM_DOCUMENT_GENERATION_MASTER dgm set DGM.FETCH_QUERY = fetchQryISDAPIConc where DGM.DOC_ID IN ('CREATE_API') and DGM.DGM_ID IN ('DGM-API-1-1-CONC') and DGM.IS_CONCENTRATE = 'Y' and DGM.SEQUENCE_ORDER = 1;
