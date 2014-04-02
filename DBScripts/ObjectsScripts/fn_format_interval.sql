create or replace function fn_format_interval(pd_interval in interval day to second)
  return varchar2 is
  vc_time varchar2(50);
begin
  if pd_interval is not null then
    vc_time := extract(hour from pd_interval) || ':' ||
               extract(minute from pd_interval) || ':' ||
               extract(second from pd_interval);
  end if;
  return vc_time;
end;
/
