
ALTER TABLE vat_child_d MODIFY vat_amount VARCHAR2(100 CHAR);

ALTER TABLE pfi_child_d MODIFY amount VARCHAR2(100 CHAR);

ALTER TABLE is_conc_penalty_child MODIFY penalty_amount VARCHAR2(100 CHAR);

ALTER TABLE is_parent_child_d MODIFY invoice_amount VARCHAR2(100 CHAR);

ALTER TABLE is_d MODIFY (invoice_amount VARCHAR2(100 CHAR),total_premium_amount VARCHAR2(100 CHAR),adjustment_amount VARCHAR2(100 CHAR),provisional_invoice_amount VARCHAR2(100 CHAR),total_tax_amount VARCHAR2(100 CHAR));


ALTER TABLE is_conc_payable_child MODIFY element_inv_amount VARCHAR2(100 CHAR);

ALTER TABLE pfi_d MODIFY (invoice_amount VARCHAR2(100 CHAR),total_tax_amount VARCHAR2(100 CHAR),total_other_charge_amount VARCHAR2(100 CHAR));

ALTER TABLE is_conc_tc_child MODIFY tc_amount VARCHAR2(100 CHAR);

ALTER TABLE api_d MODIFY (invoice_amount VARCHAR2(100 CHAR),invoice_item_amount VARCHAR2(100 CHAR));

ALTER TABLE is_conc_rc_child MODIFY rc_amount VARCHAR2(100 CHAR);

ALTER TABLE api_details_d MODIFY api_amount_adjusted VARCHAR2(100 CHAR);

ALTER TABLE is_dc_child_d MODIFY (amount VARCHAR2(100 CHAR),new_amount VARCHAR2(100 CHAR),old_invoice_amount VARCHAR2(100 CHAR),new_invoice_amount VARCHAR2(100 CHAR));

ALTER TABLE is_dc_conc_child_d MODIFY (old_payable_amount VARCHAR2(100 CHAR),new_payable_amount VARCHAR2(100 CHAR),new_rc_amount VARCHAR2(100 CHAR),old_rc_amount VARCHAR2(100 CHAR),new_tc_amount VARCHAR2(100 CHAR),old_tc_amount VARCHAR2(100 CHAR),new_penalty_amount VARCHAR2(100 CHAR),old_penalty_amount VARCHAR2(100 CHAR));

ALTER TABLE is_child_si_d MODIFY invoice_amount VARCHAR2(100 CHAR);


ALTER TABLE  is_child_d MODIFY item_amount_in_inv_cur NUMBER(35,10);

ALTER TABLE  ioc_d MODIFY (amount NUMBER(35,10), invoice_amount NUMBER(35,10));

ALTER TABLE  itd_d MODIFY (amount NUMBER(35,10), invoice_amount NUMBER(35,10));

ALTER TABLE  iepd_d MODIFY invoice_amount NUMBER(35,10);