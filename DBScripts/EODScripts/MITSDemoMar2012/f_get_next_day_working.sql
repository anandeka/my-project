CREATE OR REPLACE function f_get_next_day_working(pd_date          date,
                                                  pc_day           varchar2,
                                                  pn_position      number,
                                                  pc_instrument_id varchar2)
  return date is
  vd_position_date date;
begin
  select next_day((trunc(pd_date, 'Mon') - 1), pc_day) +
         ((pn_position * 7) - 7)
    into vd_position_date
    from dual;

  while true
  loop
    if f_is_day_holiday(pc_instrument_id, vd_position_date) = 'true' then
      vd_position_date := vd_position_date + 1;
    else
      exit;
    end if;
  end loop;

  return vd_position_date;
end;
/
