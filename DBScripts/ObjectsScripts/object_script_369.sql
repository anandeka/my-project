ALTER TABLE IUD_INVOICE_UTILITY_DETAIL ADD PAYABLE_QTY_DISPLAY2 CLOB;
UPDATE IUD_INVOICE_UTILITY_DETAIL SET PAYABLE_QTY_DISPLAY2 = PAYABLE_QTY_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL DROP COLUMN PAYABLE_QTY_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL RENAME COLUMN PAYABLE_QTY_DISPLAY2 TO PAYABLE_QTY_DISPLAY;

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL ADD FREE_METAL_QTY_DISPLAY2 CLOB;
UPDATE IUD_INVOICE_UTILITY_DETAIL SET FREE_METAL_QTY_DISPLAY2 = FREE_METAL_QTY_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL DROP COLUMN FREE_METAL_QTY_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL RENAME COLUMN FREE_METAL_QTY_DISPLAY2 TO FREE_METAL_QTY_DISPLAY;

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL ADD TC_AMOUNT_DISPLAY2 CLOB;
UPDATE IUD_INVOICE_UTILITY_DETAIL SET TC_AMOUNT_DISPLAY2 = TC_AMOUNT_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL DROP COLUMN TC_AMOUNT_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL RENAME COLUMN TC_AMOUNT_DISPLAY2 TO TC_AMOUNT_DISPLAY;

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL ADD RC_AMOUNT_DISPLAY2 CLOB;
UPDATE IUD_INVOICE_UTILITY_DETAIL SET RC_AMOUNT_DISPLAY2 = RC_AMOUNT_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL DROP COLUMN RC_AMOUNT_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL RENAME COLUMN RC_AMOUNT_DISPLAY2 TO RC_AMOUNT_DISPLAY;

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL ADD PENALTY_AMOUNT_DISPLAY2 CLOB;
UPDATE IUD_INVOICE_UTILITY_DETAIL SET PENALTY_AMOUNT_DISPLAY2 = PENALTY_AMOUNT_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL DROP COLUMN PENALTY_AMOUNT_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL RENAME COLUMN PENALTY_AMOUNT_DISPLAY2 TO PENALTY_AMOUNT_DISPLAY;

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL ADD FREE_METAL_AMOUNT_DISPLAY2 CLOB;
UPDATE IUD_INVOICE_UTILITY_DETAIL SET FREE_METAL_AMOUNT_DISPLAY2 = FREE_METAL_AMOUNT_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL DROP COLUMN FREE_METAL_AMOUNT_DISPLAY;
ALTER TABLE IUD_INVOICE_UTILITY_DETAIL RENAME COLUMN FREE_METAL_AMOUNT_DISPLAY2 TO FREE_METAL_AMOUNT_DISPLAY;

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(FEED_QTY VARCHAR2(100 CHAR));