create or replace function f_get_quote_3rd_wed(pc_corporate_id  varchar2,
                                               pd_prompt_date   date,
                                               pd_trade_date    date,
                                               pc_instrument_id varchar2)
  return number is
  vn_result number;
begin
  begin
    select dqd.price
      into vn_result
      from dqd_derivative_quote_detail dqd,
           dq_derivative_quotes        dq,
           drm_derivative_master       drm
     where dq.dq_id = dqd.dq_id
       and dqd.dr_id = drm.dr_id
       and drm.prompt_date = pd_prompt_date
       and dq.instrument_id = pc_instrument_id
       and dq.price_source_id = 'PS-17'
       and dq.corporate_id = pc_corporate_id
       and rownum <= 1
       and dq.trade_date =
           (select max(dq.trade_date)
              from dqd_derivative_quote_detail dqd,
                   dq_derivative_quotes        dq,
                   drm_derivative_master       drm
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = drm.dr_id
               and drm.prompt_date = pd_prompt_date
               and dq.instrument_id = pc_instrument_id
               and dq.trade_date < = pd_trade_date
               and dq.corporate_id = pc_corporate_id
               and dq.price_source_id = 'PS-17');
  exception
    when no_data_found then
      begin
        select dqd.price
          into vn_result
          from dqd_derivative_quote_detail dqd,
               dq_derivative_quotes        dq,
               drm_derivative_master       drm
         where dq.dq_id = dqd.dq_id
           and dqd.dr_id = drm.dr_id
           and drm.period_month = to_char(pd_prompt_date, 'Mon')
           and drm.period_year = to_char(pd_prompt_date, 'YYYY')
           and dq.corporate_id = pc_corporate_id
           and dq.instrument_id = pc_instrument_id
           and rownum <= 1
           and dq.price_source_id = 'PS-17'
           and dq.trade_date =
               (select max(dq.trade_date)
                  from dqd_derivative_quote_detail dqd,
                       dq_derivative_quotes        dq,
                       drm_derivative_master       drm
                 where dq.dq_id = dqd.dq_id
                   and dqd.dr_id = drm.dr_id
                   and drm.period_month = to_char(pd_prompt_date, 'Mon')
                   and drm.period_year = to_char(pd_prompt_date, 'YYYY')
                   and dq.instrument_id = pc_instrument_id
                   and dq.trade_date < = pd_trade_date
                   and dq.corporate_id = pc_corporate_id
                   and dq.price_source_id = 'PS-17');
      exception
        when others then
          return 0;
        
      end;
    
  end;
  return vn_result;
exception
  when others then
    return 0;
end;
/
