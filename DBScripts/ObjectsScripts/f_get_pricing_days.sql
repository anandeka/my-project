create or replace function f_get_pricing_days(pc_instrumentid varchar2,
                                              pd_from_date    date,
                                              pd_to_date      date)
  return number is
  vn_pricing_days number;
  vd_from_date    date;
  vd_to_date      date;
begin
  vn_pricing_days := 0;
  vd_from_date    := pd_from_date;
  vd_to_date      := pd_to_date;
  if vd_from_date is not null and vd_to_date is not null then
    while vd_from_date <= vd_to_date
    loop
      if not pkg_cdc_formula_builder.f_is_day_holiday(pc_instrumentid,
                                                      vd_from_date) then
        vn_pricing_days := vn_pricing_days + 1;
      end if;
      vd_from_date := vd_from_date + 1;
    end loop;
  end if;
  return vn_pricing_days;
exception
  when others then
    vn_pricing_days := -1;
    return vn_pricing_days;
end;
/
