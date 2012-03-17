CREATE OR REPLACE function f_get_working_day(pd_date          date,
                                             pc_instrument_id varchar2)
  return date is
  vd_position_date date;
  vc_ok            varchar2(10);
begin
  vd_position_date := pd_date;
  vc_ok            := 'false';

  while vc_ok = 'false'
  loop
    vc_ok := f_is_day_holiday(pc_instrument_id, vd_position_date);
    if vc_ok = 'true' then
      vd_position_date := vd_position_date - 1;
      vc_ok            := 'false';
    else
      exit;
    end if;
  end loop;

  return vd_position_date;
end;
/
