DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO is_d
            (internal_invoice_ref_no, cp_name, cp_address, cp_country,
             cp_city, cp_state, cp_zip, cp_item_stock_ref_no,
             inco_term_location, contract_ref_no, cp_contract_ref_no,
             contract_date, product, invoice_quantity, invoiced_qty_unit,
             quality, payment_term, due_date, invoice_creation_date,
             invoice_amount, invoice_amount_unit, invoice_ref_no,
             contract_type, invoice_status, sales_purchase, total_tax_amount,
             total_other_charge_amount, internal_comments,
             our_person_incharge, adjustment_amount, is_self_billing,
             internal_doc_ref_no)
   SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         phd.companyname AS cp_name, pad.address AS cp_address,
         cym.country_name AS cp_country, cim.city_name AS cp_city,
         sm.state_name AS cp_state, pad.zip AS cp_zip,
         invs.cp_ref_no AS cp_item_stock_ref_no,
         (   itm.incoterm
           || '', ''
           || cim.city_name
           || '', ''
           || cym.country_name
           || '', ''
           || pym.payment_term
          ) AS inco_term_location,
         pcm.contract_ref_no AS contract_ref_no,
         pcm.cp_contract_ref_no AS cp_contract_ref_no,
         TO_CHAR (pcm.issue_date, ''dd-Mon-yyyy'') AS contract_date,
         pdm.product_desc AS product, invs.invoiced_qty AS invoice_quantity,
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
         (gab.firstname || '' '' || gab.lastname) AS our_person_incharge,
         invs.invoice_adjustment_amount AS adjustment_amount,
         pcm.is_self_billing AS is_self_billing, ?
    FROM is_invoice_summary invs,
         apid_adv_payment_item_details apid,
         pcm_physical_contract_main pcm,
         pci_physical_contract_item pci,
         phd_profileheaderdetails phd,
         pdm_productmaster pdm,
         qat_quality_attributes qat,
         pcpd_pc_product_definition pcpd,
         pcpq_pc_product_quality pcpq,
         pcdb_pc_delivery_basis pcdb,
         itm_incoterm_master itm,
         cm_currency_master cm,
         pym_payment_terms_master pym,
         qum_quantity_unit_master qum,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         ak_corporate_user akuser,
         iam_invoice_action_mapping iam,
         axs_action_summary axs,
         gab_globaladdressbook gab,
         pad_profile_addresses pad,
         cym_countrymaster cym,
         cim_citymaster cim,
         sm_state_master sm
   WHERE invs.internal_invoice_ref_no = apid.internal_invoice_ref_no
     AND apid.contract_item_ref_no = pci.internal_contract_item_ref_no
     AND invs.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
     AND iam.invoice_action_ref_no = axs.internal_action_ref_no
     AND axs.action_id != ''MODIFY_INVOICE''
     AND axs.created_by = akuser.user_id
     AND akuser.gabid = gab.gabid
     AND pcpd.product_id = pdm.product_id
     AND pcpd.qty_unit_id = qum.qty_unit_id
     AND pcpd.input_output = ''Input''
     AND pci.pcpq_id = pcpq.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND invs.credit_term = pym.payment_term_id
     AND pci.pcdb_id = pcdb.pcdb_id
     AND pcdb.inco_term_id = itm.incoterm_id
     AND pcm.cp_id = phd.profileid(+)
     AND phd.profileid = pad.profile_id(+)
     AND pad.country_id = cym.country_id(+)
     AND pad.address_type(+) = ''Billing''
     AND pad.state_id = sm.state_id(+)
     AND pad.country_id = sm.country_id(+)
     AND pad.city_id = cim.city_id(+)
     AND pad.state_id = sm.state_id(+)
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
         invs.invoice_adjustment_amount,
         pcm.is_self_billing,
         gab.firstname,
         gab.lastname,
         pad.address,
         cym.country_name,
         cim.city_name,
         sm.state_name,
         pad.zip,
         pym.payment_term,
         itm.incoterm';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id in ('DGM-API-1-1','DGM-API-1-1-CONC') AND doc_id in ('CREATE_API') and SEQUENCE_ORDER = 1;
END;