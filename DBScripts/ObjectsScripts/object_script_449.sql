ALTER TABLE IS_D ADD(TOTAL_PREMIUM_AMOUNT_TEMP VARCHAR2(30));

UPDATE IS_D SET TOTAL_PREMIUM_AMOUNT_TEMP=TO_CHAR(TOTAL_PREMIUM_AMOUNT);

ALTER TABLE IS_D DROP COLUMN TOTAL_PREMIUM_AMOUNT;

ALTER TABLE IS_D RENAME COLUMN TOTAL_PREMIUM_AMOUNT_TEMP TO TOTAL_PREMIUM_AMOUNT