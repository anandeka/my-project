create or replace function "F_GET_QUOTE_CASH_3M"(pc_corporate_id  varchar2,
                                                 pd_trade_date    date,
                                                 pc_instrument_id varchar2,
                                                 pc_cash_or_3m    varchar2)
  return number is
  vn_result number;
begin
  begin
    select dqd.price
      into vn_result
      from dqd_derivative_quote_detail   dqd,
           dq_derivative_quotes          dq,
           drm_derivative_master         drm,
           v_dim_price_point_pricesource vps
     where dq.dq_id = dqd.dq_id
       and dqd.dr_id = drm.dr_id
       and dq.instrument_id = pc_instrument_id
       and vps.instrument_id = pc_instrument_id
       and vps.instrument_id = drm.instrument_id
       and dq.price_source_id = vps.price_source_id
       and drm.price_point_id = pc_cash_or_3m
       and dq.corporate_id = pc_corporate_id
       and dq.trade_date = (select max(dq.trade_date)
                              from dqd_derivative_quote_detail   dqd,
                                   dq_derivative_quotes          dq,
                                   drm_derivative_master         drm,
                                   v_dim_price_point_pricesource vps
                             where dq.dq_id = dqd.dq_id
                               and dqd.dr_id = drm.dr_id
                               and dq.instrument_id = pc_instrument_id
                               and dq.trade_date < = pd_trade_date
                               and dq.corporate_id = pc_corporate_id
                               and drm.price_point_id = pc_cash_or_3m
                               and vps.instrument_id = pc_instrument_id
                               and vps.instrument_id = drm.instrument_id
                               and dq.price_source_id = vps.price_source_id
                            
                            );
  exception
    when no_data_found then
      begin
        select dqd.price
          into vn_result
          from dqd_derivative_quote_detail   dqd,
               dq_derivative_quotes          dq,
               drm_derivative_master         drm,
               v_dim_price_point_pricesource vps
         where dq.dq_id = dqd.dq_id
           and dqd.dr_id = drm.dr_id
           and dq.instrument_id = pc_instrument_id
           and vps.instrument_id = pc_instrument_id
           and vps.instrument_id = drm.instrument_id
           and dq.price_source_id = vps.price_source_id
           and drm.price_point_id = pc_cash_or_3m
           and dq.corporate_id = pc_corporate_id
           and dq.trade_date =
               (select max(dq.trade_date)
                  from dqd_derivative_quote_detail   dqd,
                       dq_derivative_quotes          dq,
                       drm_derivative_master         drm,
                       v_dim_price_point_pricesource vps
                 where dq.dq_id = dqd.dq_id
                   and dqd.dr_id = drm.dr_id
                   and dq.instrument_id = pc_instrument_id
                   and dq.trade_date < = pd_trade_date
                   and drm.price_point_id = pc_cash_or_3m
                   and dq.corporate_id = pc_corporate_id
                   and vps.instrument_id = pc_instrument_id
                   and vps.instrument_id = drm.instrument_id
                   and dq.price_source_id = vps.price_source_id
                --and dq.price_source_id = 'PS-12'
                );
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
