create or replace view v_dim_holiday_dates as
select dim.instrument_id,
       dim.instrument_name,
       clm.calendar_name,
       hl.holiday_date,
       to_char(hl.holiday_date, 'dd/mm/yyyy') holiday_date_str
  from dim_der_instrument_master dim,
       clm_calendar_master       clm,
       hm_holiday_master         hm,
       hl_holiday_list           hl
 where dim.holiday_calender_id = clm.calendar_id
   and dim.is_active = 'Y'
   and clm.is_active = 'Y'
   and dim.holiday_calender_id = clm.calendar_id
   and clm.calendar_id = hm.calendar_id
   and hm.is_deleted = 'N'
   and hl.is_deleted = 'N'
   and hm.holiday_id = hl.holiday_id
/
drop view v_dim_time_date_data;
drop materialized view v_dim_time_date_data;
--create or replace view v_dim_time_date_data as
create materialized view v_dim_time_date_data
refresh force on commit
as
select dim.instrument_id,
       dd.date_id,
       dd.mnth_id,
       dd.mnth_nm,
       to_date(dd.date_id, 'dd/mm/yyyy') date_data,
       to_char(to_date(dd.date_id, 'dd/mm/yyyy'), 'Dy') day_data
  from dim_time                  dd,
       dim_der_instrument_master dim,
       irm_instrument_type_master irm
 where dd.year in ('2010', '2011', '2012')
   and dim.is_active = 'Y'
   and dim.is_deleted = 'N'
   and dim.is_currency_curve = 'N'
   and dim.instrument_type_id = irm.instrument_type_id
   and irm.instrument_type in('Future','Forward')
/
create or replace view v_dim_weekly_holiday as
select dim.instrument_id,
       dim.instrument_name,
       clm.calendar_name,
       stragg(clwh.holiday) weekly_holiday_list
  from dim_der_instrument_master    dim,
       clm_calendar_master          clm,
       clwh_calendar_weekly_holiday clwh
 where dim.holiday_calender_id = clm.calendar_id
   and clm.calendar_id = clwh.calendar_id
   and dim.is_active = 'Y'
   and clm.is_active = 'Y'
   and clwh.is_deleted = 'N'
 group by dim.instrument_id,
          dim.instrument_name,
          clm.calendar_name
/
create or replace view v_dim_holiday_list_by_year as
select v_dim.instrument_id,
       v_dim.date_id,
       v_dim.date_data,
       to_char(v_dim.date_data, 'dd-Mon-yyyy') date_str,
       to_char(v_dim.date_data, 'Mon-yyyy') month_year,
       to_char(v_dim.date_data, 'dd') day_str,
       dwh.weekly_holiday_list,
       v_dim.day_data,
       instr(dwh.weekly_holiday_list, v_dim.day_data) test,
       (case
         when v_dim.date_id = nvl(dhd.holiday_date_str, 'NA') then
          'Y'
         else
          (case
         when instr(dwh.weekly_holiday_list, v_dim.day_data) <> 0 then
          'Y'
         else
          'N'
       end) end) is_holiday
  from v_dim_time_date_data v_dim,
       v_dim_weekly_holiday dwh,
       v_dim_holiday_dates  dhd
 where v_dim.instrument_id = dwh.instrument_id(+)
   and v_dim.instrument_id = dhd.instrument_id(+)
   and v_dim.date_id = dhd.holiday_date_str(+)
/
