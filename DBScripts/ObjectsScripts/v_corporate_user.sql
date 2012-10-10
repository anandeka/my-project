create or replace view v_corporate_user as
select aku.user_id,
       aku.login_name,
       gab.firstname,
       gab.lastname,
       gab.firstname || ' ' || gab.lastname user_name
  from ak_corporate_user     aku,
       gab_globaladdressbook gab
 where aku.gabid = gab.gabid
/