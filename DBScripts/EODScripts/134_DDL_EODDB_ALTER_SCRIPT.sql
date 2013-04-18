alter table GMR_GOODS_MOVEMENT_RECORD add is_new_debit_credit_invoice char(1) default 'N';
alter table GMR_GOODS_MOVEMENT_RECORD add debit_credit_invoice_no  varchar2(15);
alter  table rgmrd_realized_gmr_detail add is_new_debit_credit_invoice char(1) default 'N' ;