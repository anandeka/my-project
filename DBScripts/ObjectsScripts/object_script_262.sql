ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
 ADD (IUD_ID  VARCHAR2(15 CHAR));

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
 ADD CONSTRAINT IUD_INVOICE_UTILITY_DETAIL_PK
 PRIMARY KEY
 (IUD_ID);