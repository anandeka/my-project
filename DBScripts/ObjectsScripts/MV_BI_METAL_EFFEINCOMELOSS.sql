drop materialized view MV_BI_METAL_EFFEINCOMELOSS;
drop table MV_BI_METAL_EFFEINCOMELOSS;
create materialized view MV_BI_METAL_EFFEINCOMELOSS
refresh force on demand
start with sysdate next SYSDATE+5/1440    
as
select * from v_bi_metal_effeincomeloss

