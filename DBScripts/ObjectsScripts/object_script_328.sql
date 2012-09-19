CREATE TABLE pyme_payment_term_ext
(
  pymex_id                NUMBER(25),
  base_date               VARCHAR2(50),
  fetch_query             VARCHAR2(4000) NOT NULL,
  is_active               CHAR DEFAULT 'Y' NOT NULL
);