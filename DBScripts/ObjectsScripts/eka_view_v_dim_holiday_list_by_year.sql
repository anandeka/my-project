create or replace view v_dim_holiday_list_by_year as
select v_dim.instrument_id,
       to_char(v_dim.date_id, 'dd/mm/yyyy')date_id,
     --  v_dim.date_id,
       v_dim.date_data,
       to_char(v_dim.date_data, 'dd-Mon-yyyy') date_str,
       to_char(v_dim.date_data, 'Mon-yyyy') month_year,
       to_char(v_dim.date_data, 'dd') day_str,
       dwh.weekly_holiday_list,
       v_dim.day_data,
       instr(dwh.weekly_holiday_list, v_dim.day_data) test,
       (case when dhd.holiday_date is not null then
           (case when to_char(v_dim.date_id,'dd-Mon-yyyy') = to_char(dhd.holiday_date, 'dd-Mon-yyyy') then
                     'Y'
            else
                     'N' end)
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
   and v_dim.date_id = dhd.holiday_date(+)
/
