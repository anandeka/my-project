drop materialized view mv_bi_hedged_unhedged_position;
/
create materialized view mv_bi_hedged_unhedged_position
build immediate
refresh force  
on demand
START WITH TO_DATE('01-Feb-2012 16:57:03','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE+10/1440   
WITH PRIMARY KEY
as select * from v_bi_hedged_unhedged_position;
/