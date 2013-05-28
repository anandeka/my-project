drop materialized view mv_bi_list_of_pledge_gmr;
/
create materialized view mv_bi_list_of_pledge_gmr 
build immediate 
refresh on demand
START WITH TO_DATE('01-Feb-2012 16:57:03','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE+10/1440   
WITH PRIMARY KEY 
as select * from v_bi_list_of_pledge_gmr;
/