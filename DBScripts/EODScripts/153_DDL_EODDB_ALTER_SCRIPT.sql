--
-- 9 July 2013
-- Since Process was missing rollback of this table, deleting unwanted data
--
DELETE FROM CSFM_CONT_STATUS_FREE_METAL CSFM
WHERE CSFM.PROCESS_ID NOT IN
(SELECT TDC.PROCESS_ID FROM TDC_TRADE_DATE_CLOSURE TDC);

COMMIT;

ALTER TABLE MBV_METAL_BALANCE_VALUATION ADD BASE_PRICE_UNIT_ID VARCHAR2(15);

Insert into EEM_EKA_EXCEPTION_MASTER
   (EXCEPTION_CODE, EXCEPTION_MODULE, EXCEPTION_DESC, IS_ACTIVE)
 Values
   ('PHY-105', 'Price Fixation', 'Price is not available for below Contracts', 'Y');

COMMIT;

