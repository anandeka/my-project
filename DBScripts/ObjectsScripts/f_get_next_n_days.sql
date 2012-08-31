create or replace function f_get_next_n_days(pc_instrument_id varchar2,
                                             pd_start_date    date,
                                             pn_days_forward  number)
  return date is
  vd_date          date;
  vn_workings_days number := 0;
begin
  vd_date := trunc(pd_start_date) + 1;
  while vn_workings_days <> pn_days_forward
  loop
    if pkg_cdc_formula_builder.f_is_day_holiday(pc_instrument_id, vd_date) then
      vd_date := vd_date + 1;
    else
      vn_workings_days := vn_workings_days + 1;
      if vn_workings_days <> pn_days_forward then
        vd_date := vd_date + 1;
      end if;
    end if;
  end loop;
  return vd_date;
exception
  when others then
    return sysdate + 5;
end;
/
