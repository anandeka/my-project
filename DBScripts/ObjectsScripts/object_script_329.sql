CREATE UNIQUE INDEX PYME_PK ON pyme_payment_term_ext(pymex_id);

ALTER TABLE pyme_payment_term_ext MODIFY (pymex_id NUMBER(25) NOT NULL, base_date VARCHAR2(50) NOT NULL);