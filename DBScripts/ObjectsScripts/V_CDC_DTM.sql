create or replace view v_cdc_dtm as
select t.deal_type_id,
       t.deal_type_name,
       t.deal_type_display_name,
       (case
         when t.deal_type_name in ('ENF', 'EPSF', 'ECSF') then
          'Future'
         when t.deal_type_name in ('EPSO', 'ENO', 'ECSO') then
          'Exchange Option'
         when t.deal_type_name in ('EFFS') then
          'Exchange Swap'
         when t.deal_type_name in ('ONF', 'OPSF', 'OCSF') then
          'Forward'
         when t.deal_type_name in ('ONO', 'OSO') then
          'OTC Option'
         when t.deal_type_name in ('OFFS','OBS') then
          'OTC Swap'
         when t.deal_type_name in ('OAF') then
          'Average Forward'
         when t.deal_type_name in ('IT') then
          'Internal Trade'          
         when t.deal_type_name in ('OSwO') then
          'OTC Swaption'
       end) deal_short_name,
       (case
         when t.deal_type_name in ('ENF', 'EPSF', 'ECSF') then
          'Future'
         when t.deal_type_name in ('EPSO', 'ENO', 'ECSO') then
          'Option'
         when t.deal_type_name in ('EFFS') then
          'Swap'
         when t.deal_type_name in ('ONF', 'OPSF', 'OCSF') then
          'Forward'
         when t.deal_type_name in ('ONO', 'OSO') then
          'Option'
         when t.deal_type_name in ('OFFS','OBS') then
          'Swap'
         when t.deal_type_name in ('OAF') then
          'Average'
         when t.deal_type_name in ('IT') then
          'Internal Trade'
         when t.deal_type_name in ('OSwO') then
          'Swap'
       end)deal_short_code
  from dtm_deal_type_master t
  where t.is_deleted = 'N'
  and t.is_active = 'Y';
