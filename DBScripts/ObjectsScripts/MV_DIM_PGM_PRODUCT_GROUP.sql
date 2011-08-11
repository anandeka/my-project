drop materialized view MV_DIM_PGM_PRODUCT_GROUP;
create materialized view MV_DIM_PGM_PRODUCT_GROUP

refresh force on commit
as
select PRODUCT_GROUP_ID,
       PRODUCT_GROUP_NAME
  from PGM_PRODUCT_GROUP_MASTER
/