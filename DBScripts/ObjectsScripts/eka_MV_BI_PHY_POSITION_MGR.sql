drop materialized view MV_BI_PHY_POSITION_MGR;

create materialized view MV_BI_PHY_POSITION_MGR
refresh force on demand
start with to_date('17-02-2012 20:24:59', 'dd-mm-yyyy hh24:mi:ss') next SYSDATE+60/1440 
as
select * from v_bi_phy_position_mgr;

