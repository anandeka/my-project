update isr_intrastat_grd isr  set isr.corporate_name = (select akc.corporate_name
                               from ak_corporate akc
                              where akc.corporate_id = isr.corporate_id);
commit;

begin
  for cur_cur in (select isr.loading_country_id,
                         cym.national_currency cur_id,
                         cm.cur_code cur_code
                    from isr_intrastat_grd  isr,
                         cym_countrymaster  cym,
                         cm_currency_master cm
                   where isr.loading_country_id is not null
                     and isr.loading_country_cur_id is null
                     and isr.loading_country_id = cym.country_id
                     and cym.national_currency = cm.cur_id)
  loop
    update isr_intrastat_grd isr
       set isr.loading_country_cur_id   = cur_cur.cur_id,
           isr.loading_country_cur_code = cur_cur.cur_code
     where isr.loading_country_id is not null
       and isr.loading_country_cur_id is null
       and isr.loading_country_id = cur_cur.loading_country_id;
  end loop;
  commit;
end;

