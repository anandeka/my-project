DROP MATERIALIZED VIEW MV_BI_METAL_ACC_TRANSACTIONS
/
CREATE MATERIALIZED VIEW MV_BI_METAL_ACC_TRANSACTIONS
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE
START WITH TO_DATE('03-Apr-2012 17:18:26','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE+15/1440  
WITH PRIMARY KEY
AS 
select * from v_bi_metal_acc_transactions
/
DROP MATERIALIZED VIEW MV_BI_LOGISTICS
/
CREATE MATERIALIZED VIEW MV_BI_LOGISTICS
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE
START WITH TO_DATE('03-Apr-2012 17:54:20','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE+22/1440  
WITH PRIMARY KEY
AS 
SELECT * FROM V_BI_LOGISTICS
/
