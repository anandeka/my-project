alter table API_D add INVOICE_ITEM_AMOUNT varchar2(30);
alter table API_D modify PAYMENT_TERM varchar2(50);
alter table IS_D add (TOTAL_TAX_AMOUNT varchar2(30), TOTAL_OTHER_CHARGE_AMOUNT varchar2(30));