UPDATE ivd_invoice_vat_details ivd
   SET ivd.vat_amount_in_vat_cur =
                                 ivd.vat_amount_in_vat_cur * ivd.fx_rate_vc_ic
 WHERE ivd.is_separate_invoice = 'N'
   AND ivd.vat_remit_cur_id <> ivd.invoice_cur_id
   AND ivd.vat_rate <> 0
   AND ivd.fx_rate_vc_ic IS NOT NULL