-- For MBV Price Fixation Report we need these AXS to display PF Ref Num

UPDATE AXM_ACTION_MASTER AXM 
SET AXM.IS_REQUIRED_FOR_EODEOM ='Y'
WHERE AXM.ACTION_ID = 'RUN_PRICE_PROCESS';
commit;