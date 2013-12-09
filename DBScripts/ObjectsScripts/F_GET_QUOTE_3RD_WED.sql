create or replace function "F_GET_QUOTE_3RD_WED"(pc_corporate_id  varchar2,
                                                 pd_prompt_date   date,
                                                 pd_trade_date    date,
                                                 pc_instrument_id varchar2)
  return number is
  vn_result number;
begin
  begin
    select dqd.price
      into vn_result
      from dqd_derivative_quote_detail  dqd,
           dq_derivative_quotes         dq,
           drm_derivative_master        drm,
           div_der_instrument_valuation div
     where dq.dq_id = dqd.dq_id
       and dqd.dr_id = drm.dr_id
       and drm.prompt_date = pd_prompt_date
       and dq.instrument_id = pc_instrument_id
       and drm.instrument_id = div.instrument_id
       and div.is_deleted = 'N'
       and dq.price_source_id = div.price_source_id
       and dq.corporate_id = pc_corporate_id
       and rownum <= 1
       and dq.trade_date =
           (select max(dq.trade_date)
              from dqd_derivative_quote_detail  dqd,
                   dq_derivative_quotes         dq,
                   drm_derivative_master        drm,
                   div_der_instrument_valuation div
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = drm.dr_id
               and drm.prompt_date = pd_prompt_date
               and drm.instrument_id = div.instrument_id
               and div.is_deleted = 'N'
               and dq.instrument_id = pc_instrument_id
               and dq.trade_date < = pd_trade_date
               and dq.corporate_id = pc_corporate_id
               and dq.price_source_id = div.price_source_id);
  exception
    when no_data_found then
      begin
        select dqd.price
          into vn_result
          from dqd_derivative_quote_detail  dqd,
               dq_derivative_quotes         dq,
               drm_derivative_master        drm,
               div_der_instrument_valuation div
         where dq.dq_id = dqd.dq_id
           and dqd.dr_id = drm.dr_id
           and drm.period_month = to_char(pd_prompt_date, 'Mon')
           and drm.period_year = to_char(pd_prompt_date, 'YYYY')
           and dq.corporate_id = pc_corporate_id
           and dq.instrument_id = pc_instrument_id
           and drm.instrument_id = div.instrument_id
           and div.is_deleted = 'N'
           and rownum <= 1
           and dq.price_source_id = div.price_source_id
           and dq.trade_date =
               (select max(dq.trade_date)
                  from dqd_derivative_quote_detail  dqd,
                       dq_derivative_quotes         dq,
                       drm_derivative_master        drm,
                       div_der_instrument_valuation div
                 where dq.dq_id = dqd.dq_id
                   and dqd.dr_id = drm.dr_id
                   and drm.period_month = to_char(pd_prompt_date, 'Mon')
                   and drm.period_year = to_char(pd_prompt_date, 'YYYY')
                   and dq.instrument_id = pc_instrument_id
                   and dq.trade_date < = pd_trade_date
                   and dq.corporate_id = pc_corporate_id
                   and drm.instrument_id = div.instrument_id
                   and div.is_deleted = 'N'
                   and dq.price_source_id = div.price_source_id);
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