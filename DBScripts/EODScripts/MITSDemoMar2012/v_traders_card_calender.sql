create or replace view v_traders_card_calender as
select 'DIM-11' instrument_id,
       tt.sm_date calender_date,
       (case
         when tt.is_holiday = 'false' then
          'N'
         else
          'Y'
       end) is_holiday
  from ((select t.sm_date,
                f_is_day_holiday('DIM-11', t.sm_date) is_holiday
           from ((select to_date('30-Jun-2010', 'dd-Mon-yyyy') + rownum sm_date
                    from user_objects
                   where rownum < 800)) t)) tt
/