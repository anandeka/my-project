drop MATERIALIZED VIEW MV_BI_LOGISTICS;
CREATE MATERIALIZED VIEW MV_BI_LOGISTICS
REFRESH FORCE ON DEMAND
START WITH TO_DATE('22-06-2012 16:33:41', 'DD-MM-YYYY HH24:MI:SS') NEXT SYSDATE+5/1440 
AS
SELECT * FROM V_BI_LOGISTICS;
