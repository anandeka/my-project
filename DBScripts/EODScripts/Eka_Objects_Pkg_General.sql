create or replace package pkg_general is

  -- All general packages and procedures
  function f_get_converted_currency_amt(pc_corporate_id        in varchar2,
                                        pc_from_cur_id         in varchar2,
                                        pc_to_cur_id           in varchar2,
                                        pd_cur_date            in date,
                                        pn_amt_to_be_converted in number)
    return number;

  function f_get_converted_quantity(pc_product_id          in varchar2,
                                    pc_from_qty_unit_id    in varchar2,
                                    pc_to_qty_unit_id      in varchar2,
                                    pn_qty_to_be_converted in number)
    return number;

  function f_get_is_derived_qty_unit(pc_qty_unit_id in varchar2)
    return varchar2;

  procedure sp_forward_cur_exchange_rate(pc_corporate_id         in varchar2,
                                         pd_trade_date           in date,
                                         pc_maturity_date        in date,
                                         pc_from_cur_id          in varchar2,
                                         pc_to_cur_id            in varchar2,
                                         pc_settlement_price     out number,
                                         pc_sum_of_forward_point out number);

  function f_get_base_cur_id(pc_cur_id varchar2) return varchar2;

  procedure sp_get_base_cur_detail(pc_cur_id            varchar2,
                                   pc_base_cur_id       out varchar2,
                                   pc_base_cur_code     out varchar2,
                                   pn_sub_cur_id_factor out number);

  procedure sp_get_main_cur_detail(pc_cur_id            varchar2,
                                   pc_base_cur_id       out varchar2,
                                   pc_base_cur_code     out varchar2,
                                   pn_sub_cur_id_factor out number,
                                   pn_base_cur_decimals out number);

  procedure sp_spot_cur_exchange_rate(pc_corporate_id         in varchar2,
                                      pd_trade_date           in date,
                                      pc_from_cur_id          in varchar2,
                                      pc_to_cur_id            in varchar2,
                                      pc_settlement_price     out number,
                                      pc_sum_of_forward_point out number);

  procedure sp_ltst_spot_cur_exchange_rate(pc_corporate_id         in varchar2,
                                           pd_trade_date           in date,
                                           pc_from_cur_id          in varchar2,
                                           pc_to_cur_id            in varchar2,
                                           pc_settlement_price     out number,
                                           pc_sum_of_forward_point out number);
  procedure sp_forward_cur_exchange_new(pc_corporate_id         in varchar2,
                                        pd_trade_date           in date,
                                        pc_maturity_date        in date,
                                        pc_from_cur_id          in varchar2,
                                        pc_to_cur_id            in varchar2,
                                        pc_max_deviation        in number,
                                        pc_settlement_price     out number,
                                        pc_sum_of_forward_point out number);

  procedure sp_forward_cur_exchange_old(pc_corporate_id         in varchar2,
                                        pd_trade_date           in date,
                                        pc_maturity_date        in date,
                                        pc_from_cur_id          in varchar2,
                                        pc_to_cur_id            in varchar2,
                                        pc_max_deviation        in number,
                                        pc_settlement_price     out number,
                                        pc_sum_of_forward_point out number);

  procedure sp_forward_cur_exchange_sub(pc_corporate_id         in varchar2,
                                        pd_trade_date           in date,
                                        pc_maturity_date        in date,
                                        pc_from_cur_id          in varchar2,
                                        pc_to_cur_id            in varchar2,
                                        pc_max_deviation        in number,
                                        pc_settlement_price     out number,
                                        pc_sum_of_forward_point out number);

  function fn_forward_interest_rate(pc_corporate_id      in varchar2,
                                    pd_trade_date        in date,
                                    pc_payment_due_date  in date,
                                    pc_ir_id             in varchar2,
                                    pc_interest_curve_id in varchar2)
    return number;

  function f_get_currency_pair(pc_corporate_id  varchar2,
                               pc_from_cur_id   in varchar2,
                               pc_from_cur_code in varchar2,
                               pc_to_cur_id     in varchar2,
                               pc_to_cur_code   in varchar2) return varchar2;

  function f_get_currency_pair_decimals(pc_from_cur_id in varchar2,
                                        pc_to_cur_id   in varchar2)
    return number;
  function f_get_is_same_classification(pc_from_qty_unit_id in varchar2,
                                        pc_to_qty_unit_id   in varchar2)
  
   return varchar2;

  function f_get_conv_factor(pc_from_qty_unit_id in varchar2,
                             pc_to_qty_unit_id   in varchar2,
                             pc_product_id       varchar2) return number;
  function fn_mass_volume_qty_conversion(pc_product_id                 in varchar2,
                                         pc_from_qty_unit_id           in varchar2,
                                         pc_to_qty_unit_id             in varchar2,
                                         pn_qty_to_be_converted        in number,
                                         pn_gravity                    in number,
                                         pc_gravity_type               in varchar2,
                                         pc_density_mass_qty_unit_id   in varchar2,
                                         pc_density_volume_qty_unit_id in varchar2)
    return number;
  procedure sp_bank_fx_rate(pc_corporate_id         in varchar2,
                            pd_trade_date           in date,
                            pd_maturity_date        in date,
                            pc_from_cur_id          in varchar2,
                            pc_to_cur_id            in varchar2,
                            pc_max_deviation        in number,
                            pc_from_where           in varchar2,
                            pc_process              in varchar2,
                            pc_settlement_price     out number,
                            pc_sum_of_forward_point out number);
  function fn_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                         pd_trade_date       date)
    return date;
  procedure sp_bank_fx_rate_spot(pc_corporate_id     in varchar2,
                                 pd_trade_date       in date,
                                 pc_from_cur_id      in varchar2,
                                 pc_to_cur_id        in varchar2,
                                 pc_from_where       in varchar2,
                                 pc_process          in varchar2,
                                 pc_settlement_price out number);
  procedure sp_bank_fx_rate_spot_fw_points(pc_corporate_id         in varchar2,
                                           pd_trade_date           in date,
                                           pd_maturity_date        in date,
                                           pc_from_cur_id          in varchar2,
                                           pc_to_cur_id            in varchar2,
                                           pc_from_where           in varchar2,
                                           pc_process              in varchar2,
                                           pc_settlement_price     out number,
                                           pc_sum_of_forward_point out number);
end;
/
create or replace package body pkg_general is

  function f_get_converted_currency_amt
  /**************************************************************************************************
    Function Name                       : f_get_converted_currency_amt
    Author                              : Janna
    Created Date                        : 19th Aug 2008
    Purpose                             : To convert a given amount between two currencies as on a given date
    
    Parameters                          :
    
    pc_corporate_id                     : Corporate ID
    pc_from_cur_id                      : From Currency
    pc_to_cur_id                        : To Currency
    pd_cur_date                         : Currency Date
    pn_amt_to_be_converted              : Amount to be converted
    
    Returns                             :
    
    Number                              : Converted amount
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id        in varchar2,
   pc_from_cur_id         in varchar2,
   pc_to_cur_id           in varchar2,
   pd_cur_date            in date,
   pn_amt_to_be_converted in number) return number is
    vn_result                    number;
    vc_base_cur_id               varchar2(30);
    vc_from_main_cur_id          varchar2(30);
    vc_to_main_cur_id            varchar2(30);
    vn_from_rate                 number;
    vn_from_main_currency_factor number := 1;
    vn_to_main_currency_factor   number := 1;
    vn_to_rate                   number;
  begin
    vn_from_rate        := 1;
    vn_to_rate          := 1;
    vc_from_main_cur_id := pc_from_cur_id;
    vc_to_main_cur_id   := pc_to_cur_id;
    -- Get the Base Currency ID of the corporate
    -- This is used to determine if one of the currencies given is the base currency itself
    -- Since AK_CORPORATE is not having Currency ID column and we are not changing it now
    -- We are joining CUR_CODE of CM with BASE_CURRENCY_NAME of AK_CORPORATE
    -- When AK_CORPORATE table is revamped change this code
    begin
      select base_cur_id
        into vc_base_cur_id
        from ak_corporate akc
       where akc.corporate_id = pc_corporate_id;
    
    exception
      when no_data_found then
        return - 1;
    end;
    -- Check if the currency passed is a sub-currency if yes take into account
    -- the sub currency factor...
    begin
      select scd.cur_id,
             scd.factor
        into vc_from_main_cur_id,
             vn_from_main_currency_factor
        from cm_currency_master      cm,
             scd_sub_currency_detail scd
       where cm.cur_id = scd.cur_id
         and scd.sub_cur_id = pc_from_cur_id;
    exception
      when no_data_found then
        vn_from_main_currency_factor := 1;
        vc_from_main_cur_id          := pc_from_cur_id;
    end;
    begin
      select scd.cur_id,
             scd.factor
        into vc_to_main_cur_id,
             vn_to_main_currency_factor
        from cm_currency_master      cm,
             scd_sub_currency_detail scd
       where cm.cur_id = scd.cur_id
         and scd.sub_cur_id = pc_to_cur_id;
    exception
      when no_data_found then
        vn_to_main_currency_factor := 1;
        vc_to_main_cur_id          := pc_to_cur_id;
    end;
    if vc_base_cur_id = vc_from_main_cur_id and
       vc_base_cur_id = vc_to_main_cur_id then
      vn_from_rate := 1;
      vn_to_rate   := 1;
    else
      begin
        -- Get the From Currency Exchange rate
        if pc_to_cur_id = pc_from_cur_id then
          return(pn_amt_to_be_converted);
        else
          if vc_from_main_cur_id != vc_base_cur_id then
            select cq.close_rate
              into vn_from_rate
              from cq_currency_quote cq
             where cq.cur_id = vc_from_main_cur_id
               and cq.corporate_id = pc_corporate_id
               and cq.cur_date =
                   (select max(cq1.cur_date)
                      from cq_currency_quote cq1
                     where cq1.cur_id = vc_from_main_cur_id
                       and cq1.corporate_id = pc_corporate_id
                       and cq1.cur_date <= pd_cur_date);
          end if;
          -- Get the To Currency Exchange rate
          if vc_to_main_cur_id != vc_base_cur_id then
            select cq.close_rate
              into vn_to_rate
              from cq_currency_quote cq
             where cq.cur_id = upper(vc_to_main_cur_id)
               and cq.corporate_id = pc_corporate_id
               and cq.cur_date =
                   (select max(cq1.cur_date)
                      from cq_currency_quote cq1
                     where cq1.cur_id = upper(vc_to_main_cur_id)
                       and cq1.corporate_id = pc_corporate_id
                       and cq1.cur_date <= pd_cur_date);
          end if;
        end if;
      exception
        when no_data_found then
          return - 1;
      end;
    end if;
    vn_result := pn_amt_to_be_converted *
                 ((vn_to_rate / vn_to_main_currency_factor) /
                 (vn_from_rate / vn_from_main_currency_factor));
    return(vn_result);
  exception
    when no_data_found then
      return - 1;
  end;

  function f_get_is_derived_qty_unit(pc_qty_unit_id in varchar2)
    return varchar2 is
    vc_is_derived_unit varchar2(1);
  begin
    select qum.is_derrived
      into vc_is_derived_unit
      from qum_quantity_unit_master qum
     where qum.qty_unit_id = pc_qty_unit_id
       and is_deleted = 'N'
       and is_active = 'Y';
    return vc_is_derived_unit;
  exception
    when no_data_found then
      return 'N';
    when others then
      return 'N';
  end;

  function f_get_is_same_classification(pc_from_qty_unit_id in varchar2,
                                        pc_to_qty_unit_id   in varchar2)
    return varchar2 is
    vc_result             varchar2(1) := 'N';
    vc_from_qty_unit_type varchar2(15);
    vc_to_qty_unit_type   varchar2(15);
  begin
  
    select unit_type
      into vc_from_qty_unit_type
      from qum_quantity_unit_master
     where qty_unit_id = pc_from_qty_unit_id
       and is_active = 'Y'
       and is_deleted = 'N';
  
    select unit_type
      into vc_to_qty_unit_type
      from qum_quantity_unit_master
     where qty_unit_id = pc_to_qty_unit_id
       and is_active = 'Y'
       and is_deleted = 'N';
  
    if (vc_from_qty_unit_type = vc_to_qty_unit_type) then
      vc_result := 'Y';
    end if;
  
    return vc_result;
  exception
    when no_data_found then
      return 'X';
    when others then
      return 'X';
  end;
  function f_get_conv_factor(pc_from_qty_unit_id in varchar2,
                             pc_to_qty_unit_id   in varchar2,
                             pc_product_id       in varchar2) return number
  
   is
  
    vc_conv_factor           number(16, 8);
    vc_base_from_qty_unit_id varchar2(15) := pc_from_qty_unit_id;
    vc_base_to_qty_unit_id   varchar2(15) := pc_to_qty_unit_id;
    vc_from_to_der_factor    number(20, 5) := 1;
    vc_to_to_der_factor      number(20, 5) := 1;
    vc_is_from_der_qty_unit  varchar2(1);
    vc_is_to_der_qty_unit    varchar2(1);
  
  begin
  
    vc_is_from_der_qty_unit := f_get_is_derived_qty_unit(pc_from_qty_unit_id);
    vc_is_to_der_qty_unit   := f_get_is_derived_qty_unit(pc_to_qty_unit_id);
  
    if (vc_is_from_der_qty_unit = 'Y') then
    
      select dqu.qty_unit_id,
             dqu.qty
        into vc_base_from_qty_unit_id,
             vc_from_to_der_factor
        from dqu_derived_quantity_unit dqu
       where dqu.derrived_qty_unit_id = pc_from_qty_unit_id
         and dqu.product_id = pc_product_id
         and dqu.is_deleted = 'N';
    end if;
  
    if (vc_is_to_der_qty_unit = 'Y') then
      select dqu.qty_unit_id,
             dqu.qty
        into vc_base_to_qty_unit_id,
             vc_to_to_der_factor
        from dqu_derived_quantity_unit dqu
       where dqu.derrived_qty_unit_id = pc_to_qty_unit_id
         and dqu.product_id = pc_product_id
         and dqu.is_deleted = 'N';
    end if;
  
    if (vc_base_from_qty_unit_id = vc_base_to_qty_unit_id)
    
     then
      vc_conv_factor := vc_from_to_der_factor / vc_to_to_der_factor;
    
    else
    
      select multiplication_factor
        into vc_conv_factor
        from ucm_unit_conversion_master
       where from_qty_unit_id = vc_base_from_qty_unit_id
         and to_qty_unit_id = vc_base_to_qty_unit_id;
    
      vc_conv_factor := vc_conv_factor *
                        (vc_from_to_der_factor / vc_to_to_der_factor);
    
    end if;
  
    return vc_conv_factor;
  
  exception
    when no_data_found then
      return - 1;
    when others then
      return - 1;
  end;
  function f_get_converted_quantity(pc_product_id          in varchar2,
                                    pc_from_qty_unit_id    in varchar2,
                                    pc_to_qty_unit_id      in varchar2,
                                    pn_qty_to_be_converted in number)
    return number is
    vn_conv_factor             number;
    vn_converted_qty           number;
    vc_is_from_der_qty_unit_id varchar2(1);
    vc_is_to_der_qty_unit_id   varchar2(1);
    vc_base_form_qty_unit_id   varchar2(15) := pc_from_qty_unit_id;
    vn_from_der_to_base_conv   number(20, 5) := 1;
    vc_base_to_qty_unit_id     varchar2(15) := pc_to_qty_unit_id;
    vn_to_der_to_base_conv     number(20, 5) := 1;
  begin
    begin
      vc_is_from_der_qty_unit_id := f_get_is_derived_qty_unit(pc_from_qty_unit_id);
      vc_is_to_der_qty_unit_id   := f_get_is_derived_qty_unit(pc_to_qty_unit_id);
      if (vc_is_from_der_qty_unit_id = 'Y') then
        select dqu.qty_unit_id,
               dqu.qty
          into vc_base_form_qty_unit_id,
               vn_from_der_to_base_conv
          from dqu_derived_quantity_unit dqu
         where dqu.derrived_qty_unit_id = pc_from_qty_unit_id
           and dqu.product_id = pc_product_id
           and rownum < 2;
      end if;
      if (vc_is_to_der_qty_unit_id = 'Y') then
        select dqu.qty_unit_id,
               dqu.qty
          into vc_base_to_qty_unit_id,
               vn_to_der_to_base_conv
          from dqu_derived_quantity_unit dqu
         where dqu.derrived_qty_unit_id = pc_to_qty_unit_id
           and dqu.product_id = pc_product_id
           and rownum < 2;
      end if;
      select ucm.multiplication_factor
        into vn_conv_factor
        from ucm_unit_conversion_master ucm
       where ucm.from_qty_unit_id = vc_base_form_qty_unit_id
         and ucm.to_qty_unit_id = vc_base_to_qty_unit_id;
      vn_converted_qty := round(vn_from_der_to_base_conv /
                                vn_to_der_to_base_conv * vn_conv_factor *
                                pn_qty_to_be_converted,
                                15);
      return vn_converted_qty;
    exception
      when no_data_found then
        return - 1;
      when others then
        return - 1;
    end;
  end;

  procedure sp_forward_cur_exchange_rate
  /**************************************************************************************************
    Function Name                       : sp_forward_cur_exchange_rate
    Author                              : Janna
    Created Date                        : 1st Mar 2009
    Purpose                             : To get forward cexchange rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id         in varchar2,
   pd_trade_date           in date,
   pc_maturity_date        in date,
   pc_from_cur_id          in varchar2,
   pc_to_cur_id            in varchar2,
   pc_settlement_price     out number,
   pc_sum_of_forward_point out number) is
    vd_lower_date      date;
    vd_upper_date      date;
    vd_maturity_date   date;
    vn_lower_date_diff number;
    vn_upper_date_diff number;
  begin
    --Package modeified to by assuming from currency as Any currency other than Base corporate Currency
    -- To Currency is always the Base currency
    if pc_from_cur_id <> pc_to_cur_id then
      begin
        select max(cfq.prompt_date)
          into vd_maturity_date
          from mv_cfq_currency_forward_quotes cfq
         where cfq.prompt_date = pc_maturity_date
           and cfq.base_cur_id = pc_to_cur_id
           and cfq.quote_cur_id = pc_from_cur_id;
      exception
        when no_data_found then
          vd_maturity_date := null;
      end;
      if vd_maturity_date is null then
        begin
          select max(cfq.prompt_date)
            into vd_lower_date
            from mv_cfq_currency_forward_quotes cfq
           where cfq.prompt_date < pc_maturity_date
             and cfq.base_cur_id = pc_to_cur_id
             and cfq.quote_cur_id = pc_from_cur_id;
        exception
          when no_data_found then
            null;
        end;
        begin
          select min(cfq.prompt_date)
            into vd_upper_date
            from mv_cfq_currency_forward_quotes cfq
           where cfq.prompt_date > pc_maturity_date
             and cfq.base_cur_id = pc_to_cur_id
             and cfq.quote_cur_id = pc_from_cur_id;
        exception
          when no_data_found then
            null;
        end;
        vn_lower_date_diff := abs(pc_maturity_date - vd_lower_date);
        vn_upper_date_diff := abs(pc_maturity_date - vd_upper_date);
        if vn_lower_date_diff < vn_upper_date_diff then
          vd_maturity_date := vd_lower_date;
        else
          vd_maturity_date := vd_upper_date;
        end if;
      end if;
      --If the maturity date is configured for the currency pair get the exchange rate
      if vd_maturity_date is not null then
        select t.settlement_price,
               t.sum_forward_point
          into pc_settlement_price,
               pc_sum_of_forward_point
          from (select row_number() over(partition by cfq.trade_date order by cfq.trade_date desc) seq,
                        cfq.rate settlement_price, -- it's included with spot and forward now
                       0 sum_forward_point
                  from mv_cfq_currency_forward_quotes cfq
                 where cfq.corporate_id = pc_corporate_id
                   and cfq.trade_date <= pd_trade_date
                   and cfq.prompt_date = vd_maturity_date
                   and cfq.base_cur_id = pc_to_cur_id
                   and cfq.quote_cur_id = pc_from_cur_id) t
         where seq = 1;
      else
        pc_settlement_price     := 0;
        pc_sum_of_forward_point := 0;
      end if;
    else
      pc_settlement_price     := 1;
      pc_sum_of_forward_point := 0;
    end if;
  exception
    when no_data_found then
      pc_settlement_price     := 0;
      pc_sum_of_forward_point := 0;
    when others then
      dbms_output.put_line(sqlerrm);
  end;

  function f_get_base_cur_id(pc_cur_id varchar2) return varchar2 is
    /**************************************************************************************************
    Function Name                       : f_get_base_cur_id
    Author                              : Janna
    Created Date                        : 9th Mar 2009
    Purpose                             : To get the base currency for a given currency
    
    Parameters                          :
    
    pc_cur_id                           : Sub Currency or Main Currency
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
    vc_base_cur_id varchar2(15);
  begin
    select (case
             when cm.is_sub_cur = 'Y' then
              scd.cur_id
             else
              cm.cur_id
           end) base_currency_id
      into vc_base_cur_id
      from cm_currency_master      cm,
           scd_sub_currency_detail scd,
           cm_currency_master      cm_1
     where cm.cur_id = pc_cur_id
       and cm.cur_id = scd.sub_cur_id(+)
       and scd.cur_id = cm_1.cur_id(+);
    return vc_base_cur_id;
  end;

  procedure sp_get_base_cur_detail(pc_cur_id            varchar2,
                                   pc_base_cur_id       out varchar2,
                                   pc_base_cur_code     out varchar2,
                                   pn_sub_cur_id_factor out number) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_get_base_cur_detail
    --        Author                                    : Janna
    --        Created Date                              : 31st Mar 2009
    --        Purpose                                   : Get Base currency details for a sub currency
    --
    --        Parameters
    --        pc_cur_id                                 : Sub Currency ID ID
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  begin
    select (case
             when cm.is_sub_cur = 'Y' then
              scd.cur_id
             else
              cm.cur_id
           end) base_currency_id,
           (case
             when cm.is_sub_cur = 'Y' then
              cm_1.cur_code
             else
              cm.cur_code
           end) cur_code,
           nvl(scd.factor, 1) factor
      into pc_base_cur_id,
           pc_base_cur_code,
           pn_sub_cur_id_factor
      from cm_currency_master      cm,
           scd_sub_currency_detail scd,
           cm_currency_master      cm_1
     where cm.cur_id = pc_cur_id
       and cm.cur_id = scd.sub_cur_id(+)
       and scd.cur_id = cm_1.cur_id(+);
  exception
    when no_data_found then
      pn_sub_cur_id_factor := 1;
      pc_base_cur_id       := pc_cur_id;
      select cm.cur_code
        into pc_base_cur_code
        from cm_currency_master cm
       where cm.cur_id = pc_cur_id;
  end;

  procedure sp_get_main_cur_detail(pc_cur_id            varchar2,
                                   pc_base_cur_id       out varchar2,
                                   pc_base_cur_code     out varchar2,
                                   pn_sub_cur_id_factor out number,
                                   pn_base_cur_decimals out number) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_get_main_cur_detail
    --        Author                                    : Janna
    --        Created Date                              : 31st Mar 2009
    --        Purpose                                   : Get Base currency details for a sub currency
    --
    --        Parameters
    --        pc_cur_id                                 : Sub Currency ID ID
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  begin
    --write_log(null,'pc_cur_id'||pc_cur_id);
    select (case
             when cm.is_sub_cur = 'Y' then
              scd.cur_id
             else
              cm.cur_id
           end) base_currency_id,
           (case
             when cm.is_sub_cur = 'Y' then
              cm_1.cur_code
             else
              cm.cur_code
           end) cur_code,
           nvl(scd.factor, 1) factor,
           (case
             when cm.is_sub_cur = 'Y' then
              cm_1.decimals
             else
              cm.decimals
           end)
      into pc_base_cur_id,
           pc_base_cur_code,
           pn_sub_cur_id_factor,
           pn_base_cur_decimals
      from cm_currency_master      cm,
           scd_sub_currency_detail scd,
           cm_currency_master      cm_1
     where cm.cur_id = pc_cur_id
       and cm.cur_id = scd.sub_cur_id(+)
       and scd.cur_id = cm_1.cur_id(+);
    --write_log(null,'sp_get_main_cur_detail');
  exception
    when no_data_found then
      dbms_output.put_line('pc_cur_id' || pc_cur_id);
      --   pn_sub_cur_id_factor := 1;
    --    pc_base_cur_id       := pc_cur_id;
  
    when others then
      pn_sub_cur_id_factor := 1;
      pc_base_cur_id       := pc_cur_id;
      select cm.cur_code
        into pc_base_cur_code
        from cm_currency_master cm
       where cm.cur_id = pc_cur_id;
      --write_log(null,'sp_get_main_cur_detail');
  end;

  procedure sp_spot_cur_exchange_rate
  /**************************************************************************************************
    Function Name                       : sp_spot_cur_exchange
    Author                              : Lalit
    Created Date                        : 16 Sep 2009
    Purpose                             : To get Spot rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id         in varchar2,
   pd_trade_date           in date,
   pc_from_cur_id          in varchar2,
   pc_to_cur_id            in varchar2,
   pc_settlement_price     out number,
   pc_sum_of_forward_point out number) is
  begin
    if pc_from_cur_id = pc_to_cur_id then
      pc_settlement_price     := 1;
      pc_sum_of_forward_point := 0;
    else
      begin
        select t.settlement_price,
               t.sum_forward_point
          into pc_settlement_price,
               pc_sum_of_forward_point
          from (select cfq.rate settlement_price,
                       nvl(cfq.forward_point, 0) sum_forward_point
                  from mv_cfq_currency_forward_quotes cfq
                 where cfq.corporate_id = pc_corporate_id
                   and cfq.trade_date = pd_trade_date
                   and cfq.is_spot = 'Y'
                   and cfq.base_cur_id = pc_from_cur_id
                   and cfq.quote_cur_id = pc_to_cur_id) t;
      exception
        when no_data_found then
          select decode(nvl(t.settlement_price, 0),
                        0,
                        0,
                        1 / t.settlement_price),
                 t.sum_forward_point
            into pc_settlement_price,
                 pc_sum_of_forward_point
            from (select cfq.rate settlement_price,
                         nvl(cfq.forward_point, 0) sum_forward_point
                    from mv_cfq_currency_forward_quotes cfq
                   where cfq.corporate_id = pc_corporate_id
                     and cfq.trade_date = pd_trade_date
                     and cfq.is_spot = 'Y'
                     and cfq.base_cur_id = pc_to_cur_id
                     and cfq.quote_cur_id = pc_from_cur_id) t;
      end;
    end if;
  exception
    when others then
      pc_settlement_price     := 0;
      pc_sum_of_forward_point := 0;
  end;

  procedure sp_ltst_spot_cur_exchange_rate
  /**************************************************************************************************
    Function Name                       : sp_spot_cur_exchange
    Author                              : Lalit
    Created Date                        : 16 Sep 2009
    Purpose                             : To get Spot rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id         in varchar2,
   pd_trade_date           in date,
   pc_from_cur_id          in varchar2,
   pc_to_cur_id            in varchar2,
   pc_settlement_price     out number,
   pc_sum_of_forward_point out number) is
  begin
    if pc_from_cur_id = pc_to_cur_id then
      pc_settlement_price     := 1;
      pc_sum_of_forward_point := 0;
    else
      begin
        select t.settlement_price,
               t.sum_forward_point
          into pc_settlement_price,
               pc_sum_of_forward_point
          from (select cfq.rate settlement_price,
                       nvl(cfq.forward_point, 0) sum_forward_point
                  from mv_cfq_currency_forward_quotes cfq
                 where cfq.corporate_id = pc_corporate_id
                   and cfq.trade_date <= pd_trade_date
                   and cfq.is_spot = 'Y'
                   and cfq.base_cur_id = pc_from_cur_id
                   and cfq.quote_cur_id = pc_to_cur_id
                 order by cfq.trade_date desc) t
         where rownum = 1;
      exception
        when no_data_found then
          select decode(nvl(t.settlement_price, 0),
                        0,
                        0,
                        1 / t.settlement_price),
                 t.sum_forward_point
            into pc_settlement_price,
                 pc_sum_of_forward_point
            from (select cfq.rate settlement_price,
                         nvl(cfq.forward_point, 0) sum_forward_point
                    from mv_cfq_currency_forward_quotes cfq
                   where cfq.corporate_id = pc_corporate_id
                     and cfq.trade_date <= pd_trade_date
                     and cfq.is_spot = 'Y'
                     and cfq.base_cur_id = pc_to_cur_id
                     and cfq.quote_cur_id = pc_from_cur_id
                   order by cfq.trade_date desc) t
           where rownum = 1;
      end;
    end if;
  exception
    when others then
      pc_settlement_price     := 0;
      pc_sum_of_forward_point := 0;
  end;

  procedure sp_forward_cur_exchange_new
  /**************************************************************************************************
    Function Name                       : sp_forward_cur_exchange_rate
    Author                              : Suresh Gottipati
    Created Date                        : 03rd Feb 2012
    Purpose                             : To get forward cexchange rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id         in varchar2,
   pd_trade_date           in date,
   pc_maturity_date        in date,
   pc_from_cur_id          in varchar2,
   pc_to_cur_id            in varchar2,
   pc_max_deviation        in number,
   pc_settlement_price     out number,
   pc_sum_of_forward_point out number) is
    vd_lower_date      date;
    vd_upper_date      date;
    vd_maturity_date   date;
    vn_lower_date_diff number;
    vn_upper_date_diff number;
    --vc_base_cur_id               varchar2(30);
    --pc_settlement_price_from     number;
    --pc_sum_of_forward_point_from number;
    --pc_settlement_price_to number;
    --pc_sum_of_forward_point_to   number;
    vc_insturment_id    varchar2(15);
    vd_valid_quote_date date;
  begin
  
    if pc_from_cur_id is not null and pc_to_cur_id is not null and
       pc_from_cur_id <> pc_to_cur_id then
      begin
        select cci.instrument_id,
               cdim.valid_quote_date
          into vc_insturment_id,
               vd_valid_quote_date
          from cci_corp_currency_instrument cci,
               cdim_corporate_dim           cdim,
               dim_der_instrument_master    dim,
               pdd_product_derivative_def   pdd,
               pdm_productmaster            pdm
         where cci.corporate_id = pc_corporate_id
           and cci.instrument_id = cdim.instrument_id
           and dim.instrument_id = cdim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.product_id = pdm.product_id
           and pdm.base_cur_id = pc_from_cur_id
           and pdm.quote_cur_id = pc_to_cur_id
           and cci.is_deleted = 'N'
           and cdim.is_active = 'Y'
           and pdm.is_active = 'Y'
           and pdd.is_active = 'Y'
           and dim.is_active = 'Y'
           and cdim.corporate_id = pc_corporate_id;
      exception
        when no_data_found then
          select cci.instrument_id,
                 cdim.valid_quote_date
            into vc_insturment_id,
                 vd_valid_quote_date
            from cci_corp_currency_instrument cci,
                 cdim_corporate_dim           cdim,
                 dim_der_instrument_master    dim,
                 pdd_product_derivative_def   pdd,
                 pdm_productmaster            pdm
           where cci.corporate_id = pc_corporate_id
             and cci.instrument_id = cdim.instrument_id
             and dim.instrument_id = cdim.instrument_id
             and dim.product_derivative_id = pdd.derivative_def_id
             and pdd.product_id = pdm.product_id
             and pdm.base_cur_id = pc_to_cur_id
             and pdm.quote_cur_id = pc_from_cur_id
             and cci.is_deleted = 'N'
             and cdim.is_active = 'Y'
             and dim.is_active = 'Y'
             and pdd.is_active = 'Y'
             and pdm.is_active = 'Y'
             and cdim.corporate_id = pc_corporate_id;
      end;
    
      if pc_from_cur_id <> pc_to_cur_id then
        begin
          select max(cfq.prompt_date)
            into vd_maturity_date
            from mv_cfq_cci_cur_forward_quotes cfq,
                 div_der_instrument_valuation  div
           where cfq.corporate_id = pc_corporate_id
             and cfq.trade_date = nvl(vd_valid_quote_date, pd_trade_date)
             and cfq.instrument_id = div.instrument_id
             and cfq.price_source_id = div.price_source_id
             and div.is_deleted = 'N'
             and cfq.prompt_date = pc_maturity_date
             and cfq.base_cur_id = pc_from_cur_id
             and cfq.quote_cur_id = pc_to_cur_id;
        exception
          when no_data_found then
            vd_maturity_date := null;
        end;
        if vd_maturity_date is null then
          begin
            select max(cfq.prompt_date)
              into vd_lower_date
              from mv_cfq_cci_cur_forward_quotes cfq,
                   div_der_instrument_valuation  div
             where cfq.corporate_id = pc_corporate_id
               and cfq.trade_date = nvl(vd_valid_quote_date, pd_trade_date)
               and cfq.instrument_id = div.instrument_id
               and cfq.price_source_id = div.price_source_id
               and div.is_deleted = 'N'
               and cfq.prompt_date <= pc_maturity_date
               and abs(pc_maturity_date - cfq.prompt_date) <=
                   pc_max_deviation --lalit
               and cfq.base_cur_id = pc_from_cur_id
               and cfq.quote_cur_id = pc_to_cur_id;
          exception
            when no_data_found then
              vd_lower_date := null;
          end;
          begin
            select min(cfq.prompt_date)
              into vd_upper_date
              from mv_cfq_cci_cur_forward_quotes cfq,
                   div_der_instrument_valuation  div
             where cfq.corporate_id = pc_corporate_id
               and cfq.trade_date = nvl(vd_valid_quote_date, pd_trade_date)
               and cfq.instrument_id = div.instrument_id
               and cfq.price_source_id = div.price_source_id
               and div.is_deleted = 'N'
               and cfq.prompt_date >= pc_maturity_date
               and abs(pc_maturity_date - cfq.prompt_date) <=
                   pc_max_deviation --Lalit
               and cfq.base_cur_id = pc_from_cur_id
               and cfq.quote_cur_id = pc_to_cur_id;
          exception
            when no_data_found then
              vd_upper_date := null;
          end;
          vn_lower_date_diff := nvl(abs(pc_maturity_date - vd_lower_date),
                                    999);
          vn_upper_date_diff := nvl(abs(pc_maturity_date - vd_upper_date),
                                    999);
          if vd_lower_date is null and vd_upper_date is null then
            vd_maturity_date    := null;
            pc_settlement_price := 0;
          else
            if vn_lower_date_diff <= vn_upper_date_diff then
              vd_maturity_date := vd_lower_date;
            else
              vd_maturity_date := vd_upper_date;
            end if;
          end if;
        end if;
        --If the maturity date is configured for the currency pair get the exchange rate
        if vd_maturity_date is not null then
          begin
            select t.settlement_price,
                   t.sum_forward_point
              into pc_settlement_price,
                   pc_sum_of_forward_point
              from (select cfq.rate settlement_price,
                           nvl(cfq.forward_point, 0) sum_forward_point
                      from mv_cfq_cci_cur_forward_quotes cfq,
                           div_der_instrument_valuation  div
                     where cfq.corporate_id = pc_corporate_id
                       and cfq.trade_date =
                           nvl(vd_valid_quote_date, pd_trade_date)
                       and cfq.instrument_id = div.instrument_id
                       and cfq.price_source_id = div.price_source_id
                       and div.is_deleted = 'N'
                       and cfq.prompt_date = vd_maturity_date
                       and cfq.base_cur_id = pc_from_cur_id
                       and cfq.quote_cur_id = pc_to_cur_id) t;
          exception
            when no_data_found then
              pc_settlement_price     := 0;
              pc_sum_of_forward_point := 0;
          end;
        else
          pc_settlement_price     := 0;
          pc_sum_of_forward_point := 0;
        end if;
        if pc_settlement_price = 0 then
          -- its likely that the pair is not configured.
          --try reverse pair
          begin
            select max(cfq.prompt_date)
              into vd_maturity_date
              from mv_cfq_cci_cur_forward_quotes cfq,
                   div_der_instrument_valuation  div
             where cfq.corporate_id = pc_corporate_id
               and cfq.trade_date = nvl(vd_valid_quote_date, pd_trade_date)
               and cfq.prompt_date = pc_maturity_date
               and cfq.instrument_id = div.instrument_id
               and cfq.price_source_id = div.price_source_id
               and div.is_deleted = 'N'
               and cfq.base_cur_id = pc_to_cur_id
               and cfq.quote_cur_id = pc_from_cur_id;
          exception
            when no_data_found then
              vd_maturity_date := null;
          end;
        
          if vd_maturity_date is null then
            begin
              select max(cfq.prompt_date)
                into vd_lower_date
                from mv_cfq_cci_cur_forward_quotes cfq,
                     div_der_instrument_valuation  div
               where cfq.corporate_id = pc_corporate_id
                 and cfq.trade_date =
                     nvl(vd_valid_quote_date, pd_trade_date)
                 and cfq.prompt_date <= pc_maturity_date
                 and cfq.instrument_id = div.instrument_id
                 and cfq.price_source_id = div.price_source_id
                 and div.is_deleted = 'N'
                 and abs(pc_maturity_date - cfq.prompt_date) <=
                     pc_max_deviation --lalit
                 and cfq.base_cur_id = pc_to_cur_id
                 and cfq.quote_cur_id = pc_from_cur_id;
            exception
              when no_data_found then
                vd_lower_date := null;
            end;
            begin
              select min(cfq.prompt_date)
                into vd_upper_date
                from mv_cfq_cci_cur_forward_quotes cfq,
                     div_der_instrument_valuation  div
               where cfq.corporate_id = pc_corporate_id
                 and cfq.trade_date =
                     nvl(vd_valid_quote_date, pd_trade_date)
                 and cfq.instrument_id = div.instrument_id
                 and cfq.price_source_id = div.price_source_id
                 and div.is_deleted = 'N'
                 and cfq.prompt_date >= pc_maturity_date
                 and abs(pc_maturity_date - cfq.prompt_date) <=
                     pc_max_deviation --Lalit
                 and cfq.base_cur_id = pc_to_cur_id
                 and cfq.quote_cur_id = pc_from_cur_id;
            exception
              when no_data_found then
                vd_upper_date := null;
            end;
            vn_lower_date_diff := nvl(abs(pc_maturity_date - vd_lower_date),
                                      999);
            vn_upper_date_diff := nvl(abs(pc_maturity_date - vd_upper_date),
                                      999);
            if vd_lower_date is null and vd_upper_date is null then
              vd_maturity_date    := null;
              pc_settlement_price := 0;
            else
              if vn_lower_date_diff <= vn_upper_date_diff then
                vd_maturity_date := vd_lower_date;
              else
                vd_maturity_date := vd_upper_date;
              end if;
            end if;
          end if;
        
          if vd_maturity_date is not null then
            begin
              select 1 / t.settlement_price,
                     t.sum_forward_point
                into pc_settlement_price,
                     pc_sum_of_forward_point
                from (select cfq.rate settlement_price,
                             nvl(cfq.forward_point, 0) sum_forward_point
                        from mv_cfq_cci_cur_forward_quotes cfq,
                             div_der_instrument_valuation  div
                       where cfq.corporate_id = pc_corporate_id
                         and cfq.trade_date =
                             nvl(vd_valid_quote_date, pd_trade_date)
                         and cfq.instrument_id = div.instrument_id
                         and cfq.price_source_id = div.price_source_id
                         and div.is_deleted = 'N'
                         and cfq.prompt_date = vd_maturity_date
                         and cfq.base_cur_id = pc_to_cur_id
                         and cfq.quote_cur_id = pc_from_cur_id) t;
            exception
              when no_data_found then
                pc_settlement_price     := 0;
                pc_sum_of_forward_point := 0;
            end;
          else
            pc_settlement_price     := 0;
            pc_sum_of_forward_point := 0;
          end if;
        end if;
        pc_settlement_price := round(nvl(pc_settlement_price, 0), 10);
      else
        pc_settlement_price     := 1;
        pc_sum_of_forward_point := 0;
      end if;
    else
      pc_settlement_price     := 1;
      pc_sum_of_forward_point := 0;
    end if;
  exception
    when others then
      pc_settlement_price     := 0;
      pc_sum_of_forward_point := 0;
  end;

  procedure sp_forward_cur_exchange_old
  /**************************************************************************************************
    Function Name                       : sp_forward_cur_exchange_rate
    Author                              : Janna
    Created Date                        : 1st Mar 2009
    Purpose                             : To get forward cexchange rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id         in varchar2,
   pd_trade_date           in date,
   pc_maturity_date        in date,
   pc_from_cur_id          in varchar2,
   pc_to_cur_id            in varchar2,
   pc_max_deviation        in number,
   pc_settlement_price     out number,
   pc_sum_of_forward_point out number) is
    vd_lower_date                date;
    vd_upper_date                date;
    vd_maturity_date             date;
    vn_lower_date_diff           number;
    vn_upper_date_diff           number;
    vc_base_cur_id               varchar2(30);
    pc_settlement_price_from     number;
    pc_sum_of_forward_point_from number;
    pc_settlement_price_to       number;
    pc_sum_of_forward_point_to   number;
  begin
    begin
      select akc.base_cur_id
        into vc_base_cur_id
        from ak_corporate akc
       where akc.corporate_id = pc_corporate_id;
    
    end;
    if pc_from_cur_id <> pc_to_cur_id then
      begin
        select max(cfq.prompt_date)
          into vd_maturity_date
          from mv_cfq_currency_forward_quotes cfq
         where cfq.corporate_id = pc_corporate_id
           and cfq.trade_date = pd_trade_date
           and cfq.prompt_date = pc_maturity_date
           and cfq.base_cur_id = pc_from_cur_id
           and cfq.quote_cur_id = pc_to_cur_id;
      exception
        when no_data_found then
          vd_maturity_date := null;
      end;
      if vd_maturity_date is null then
        begin
          select max(cfq.prompt_date)
            into vd_lower_date
            from mv_cfq_currency_forward_quotes cfq
           where cfq.corporate_id = pc_corporate_id
             and cfq.trade_date = pd_trade_date
             and cfq.prompt_date <= pc_maturity_date
             and abs(pc_maturity_date - cfq.prompt_date) <=
                 pc_max_deviation --lalit
             and cfq.base_cur_id = pc_from_cur_id
             and cfq.quote_cur_id = pc_to_cur_id;
        exception
          when no_data_found then
            vd_lower_date := null;
        end;
        begin
          select min(cfq.prompt_date)
            into vd_upper_date
            from mv_cfq_currency_forward_quotes cfq
           where cfq.corporate_id = pc_corporate_id
             and cfq.trade_date = pd_trade_date
             and cfq.prompt_date >= pc_maturity_date
             and abs(pc_maturity_date - cfq.prompt_date) <=
                 pc_max_deviation --Lalit
             and cfq.base_cur_id = pc_from_cur_id
             and cfq.quote_cur_id = pc_to_cur_id;
        exception
          when no_data_found then
            vd_upper_date := null;
        end;
        vn_lower_date_diff := nvl(abs(pc_maturity_date - vd_lower_date),
                                  999);
        vn_upper_date_diff := nvl(abs(pc_maturity_date - vd_upper_date),
                                  999);
        if vd_lower_date is null and vd_upper_date is null then
          vd_maturity_date    := null;
          pc_settlement_price := 0;
        else
          if vn_lower_date_diff <= vn_upper_date_diff then
            vd_maturity_date := vd_lower_date;
          else
            vd_maturity_date := vd_upper_date;
          end if;
        end if;
      end if;
      --If the maturity date is configured for the currency pair get the exchange rate
      if vd_maturity_date is not null then
        begin
          select t.settlement_price,
                 t.sum_forward_point
            into pc_settlement_price,
                 pc_sum_of_forward_point
            from (select cfq.rate settlement_price,
                         nvl(cfq.forward_point, 0) sum_forward_point
                    from mv_cfq_currency_forward_quotes cfq
                   where cfq.corporate_id = pc_corporate_id
                     and cfq.trade_date = pd_trade_date
                     and cfq.prompt_date = vd_maturity_date
                     and cfq.base_cur_id = pc_from_cur_id
                     and cfq.quote_cur_id = pc_to_cur_id) t;
        exception
          when no_data_found then
            pc_settlement_price     := 0;
            pc_sum_of_forward_point := 0;
        end;
      else
        pc_settlement_price     := 0;
        pc_sum_of_forward_point := 0;
      end if;
      if vd_lower_date is null and vd_upper_date is null and
         pc_settlement_price = 0 then
        -- its likely that the pair is not configured.
        --try reverse pair
        if pc_from_cur_id != vc_base_cur_id then
          sp_forward_cur_exchange_sub(pc_corporate_id,
                                      pd_trade_date,
                                      pc_maturity_date,
                                      pc_from_cur_id,
                                      vc_base_cur_id,
                                      pc_max_deviation,
                                      pc_settlement_price_from,
                                      pc_sum_of_forward_point_from);
        else
          pc_settlement_price_from     := 1;
          pc_sum_of_forward_point_from := 0;
        end if;
        if pc_to_cur_id != vc_base_cur_id then
          sp_forward_cur_exchange_sub(pc_corporate_id,
                                      pd_trade_date,
                                      pc_maturity_date,
                                      pc_to_cur_id,
                                      vc_base_cur_id,
                                      pc_max_deviation,
                                      pc_settlement_price_to,
                                      pc_sum_of_forward_point_to);
        else
          pc_settlement_price_to     := 1;
          pc_sum_of_forward_point_to := 0;
        end if;
        if nvl(pc_settlement_price_from, 0) <> 0 and
           nvl(pc_settlement_price_to, 0) <> 0 then
          pc_settlement_price     := pc_settlement_price_from /
                                     pc_settlement_price_to;
          pc_sum_of_forward_point := pc_sum_of_forward_point_from; --Fix for automation-- /pc_sum_of_forward_point_to;
        else
          sp_forward_cur_exchange_sub(pc_corporate_id,
                                      pd_trade_date,
                                      pc_maturity_date,
                                      pc_to_cur_id,
                                      pc_from_cur_id,
                                      pc_max_deviation,
                                      pc_settlement_price,
                                      pc_sum_of_forward_point);
          if nvl(pc_settlement_price, 0) = 0 then
            if pc_to_cur_id != vc_base_cur_id then
              sp_forward_cur_exchange_sub(pc_corporate_id,
                                          pd_trade_date,
                                          pc_maturity_date,
                                          pc_to_cur_id,
                                          vc_base_cur_id,
                                          pc_max_deviation,
                                          pc_settlement_price_from,
                                          pc_sum_of_forward_point_from);
            else
              pc_settlement_price_from     := 1;
              pc_sum_of_forward_point_from := 0;
            end if;
            if pc_from_cur_id != vc_base_cur_id then
              sp_forward_cur_exchange_sub(pc_corporate_id,
                                          pd_trade_date,
                                          pc_maturity_date,
                                          pc_from_cur_id,
                                          vc_base_cur_id,
                                          pc_max_deviation,
                                          pc_settlement_price_to,
                                          pc_sum_of_forward_point_to);
            else
              pc_settlement_price_to     := 1;
              pc_sum_of_forward_point_to := 0;
            end if;
            if nvl(pc_settlement_price_from, 0) <> 0 and
               nvl(pc_settlement_price_to, 0) <> 0 then
              pc_settlement_price     := pc_settlement_price_from /
                                         pc_settlement_price_to;
              pc_sum_of_forward_point := pc_sum_of_forward_point_from;
            else
              pc_settlement_price     := 0;
              pc_sum_of_forward_point := 0;
            end if;
          end if;
        end if;
      end if;
    else
      pc_settlement_price     := 1;
      pc_sum_of_forward_point := 0;
    end if;
    --pc_settlement_price     := 1;
    --pc_sum_of_forward_point := 0;
  exception
    when others then
      pc_settlement_price     := 0;
      pc_sum_of_forward_point := 0;
  end;

  procedure sp_forward_cur_exchange_sub
  /**************************************************************************************************
    Function Name                       : sp_forward_cur_exchange_rate
    Author                              : Janna
    Created Date                        : 1st Mar 2009
    Purpose                             : To get forward cexchange rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id         in varchar2,
   pd_trade_date           in date,
   pc_maturity_date        in date,
   pc_from_cur_id          in varchar2,
   pc_to_cur_id            in varchar2,
   pc_max_deviation        in number,
   pc_settlement_price     out number,
   pc_sum_of_forward_point out number) is
    vd_lower_date      date;
    vd_upper_date      date;
    vd_maturity_date   date;
    vn_lower_date_diff number;
    vn_upper_date_diff number;
    vc_base_cur_id     varchar2(30);
    --pc_settlement_price_from     NUMBER;
    --pc_sum_of_forward_point_from NUMBER;
    --pc_settlement_price_to       NUMBER;
    --pc_sum_of_forward_point_to   NUMBER;
  begin
    begin
      select akc.base_cur_id
        into vc_base_cur_id
        from ak_corporate akc
       where akc.corporate_id = pc_corporate_id;
    end;
    if pc_from_cur_id <> pc_to_cur_id then
      begin
        select max(cfq.prompt_date)
          into vd_maturity_date
          from mv_cfq_currency_forward_quotes cfq
         where cfq.corporate_id = pc_corporate_id
              --AND    cfq.groupid = akc.groupid preeti
           and cfq.trade_date = pd_trade_date
           and cfq.prompt_date = pc_maturity_date
           and cfq.base_cur_id = pc_from_cur_id
           and cfq.quote_cur_id = pc_to_cur_id;
      exception
        when no_data_found then
          vd_maturity_date := null;
      end;
      if vd_maturity_date is null then
        begin
          select max(cfq.prompt_date)
            into vd_lower_date
            from mv_cfq_currency_forward_quotes cfq
           where cfq.corporate_id = pc_corporate_id
                --AND    cfq.groupid = akc.groupid preeti
             and cfq.trade_date = pd_trade_date
             and cfq.prompt_date <= pc_maturity_date
             and abs(pc_maturity_date - cfq.prompt_date) <=
                 pc_max_deviation --lalit
             and cfq.base_cur_id = pc_from_cur_id
             and cfq.quote_cur_id = pc_to_cur_id;
        exception
          when no_data_found then
            vd_lower_date := null;
        end;
        begin
          select min(cfq.prompt_date)
            into vd_upper_date
            from mv_cfq_currency_forward_quotes cfq
           where cfq.corporate_id = pc_corporate_id
             and cfq.trade_date = pd_trade_date
             and cfq.prompt_date >= pc_maturity_date
             and abs(pc_maturity_date - cfq.prompt_date) <=
                 pc_max_deviation --Lalit
             and cfq.base_cur_id = pc_from_cur_id
             and cfq.quote_cur_id = pc_to_cur_id;
        exception
          when no_data_found then
            vd_upper_date := null;
        end;
        vn_lower_date_diff := nvl(abs(pc_maturity_date - vd_lower_date),
                                  999);
        vn_upper_date_diff := nvl(abs(pc_maturity_date - vd_upper_date),
                                  999);
        if vd_lower_date is null and vd_upper_date is null then
          vd_maturity_date    := null;
          pc_settlement_price := 0;
        else
          if vn_lower_date_diff <= vn_upper_date_diff then
            vd_maturity_date := vd_lower_date;
          else
            vd_maturity_date := vd_upper_date;
          end if;
        end if;
      end if;
      --If the maturity date is configured for the currency pair get the exchange rate
      if vd_maturity_date is not null then
        select t.settlement_price,
               t.sum_forward_point
          into pc_settlement_price,
               pc_sum_of_forward_point
          from (select cfq.rate settlement_price,
                       nvl(cfq.forward_point, 0) sum_forward_point
                  from mv_cfq_currency_forward_quotes cfq
                 where cfq.corporate_id = pc_corporate_id
                      --AND    cfq.groupid = akc.groupid preeti
                   and cfq.trade_date = pd_trade_date
                   and cfq.prompt_date = vd_maturity_date
                   and cfq.base_cur_id = pc_from_cur_id
                   and cfq.quote_cur_id = pc_to_cur_id) t;
      else
        pc_settlement_price     := 0;
        pc_sum_of_forward_point := 0;
      end if;
    else
      pc_settlement_price     := 1;
      pc_sum_of_forward_point := 0;
    end if;
  exception
    when others then
      pc_settlement_price     := 0;
      pc_sum_of_forward_point := 0;
  end;

  function fn_forward_interest_rate
  /**************************************************************************************************
    Function Name                       : sp_forward_Interest_rate
    Author                              : LALIT
    Created Date                        : 1st Mar 2009
    Purpose                             : To get forward Interest rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id      in varchar2,
   pd_trade_date        in date,
   pc_payment_due_date  in date,
   pc_ir_id             in varchar2,
   pc_interest_curve_id in varchar2) return number is
    vd_lower_date      date;
    vd_upper_date      date;
    vd_maturity_date   date;
    vn_lower_date_diff number;
    vn_upper_date_diff number;
    vn_interest_rate   number;
  begin
    begin
      select max(icd.maturity_date)
        into vd_lower_date
        from ich_interest_curve_header@eka_appdb ich,
             icd_interest_curve_detail@eka_appdb icd
       where icd.maturity_date < pc_payment_due_date
         and icd.ir_id = ich.ir_id
         and ich.interest_curve_id = pc_interest_curve_id
         and icd.ir_id = pc_ir_id
         and ich.trade_date = pd_trade_date;
    end;
    begin
      select min(icd.maturity_date)
        into vd_lower_date
        from ich_interest_curve_header@eka_appdb ich,
             icd_interest_curve_detail@eka_appdb icd
       where icd.maturity_date > pc_payment_due_date
         and icd.ir_id = ich.ir_id
         and ich.interest_curve_id = pc_interest_curve_id
         and icd.ir_id = pc_ir_id
         and ich.trade_date = pd_trade_date;
    end;
    vn_lower_date_diff := abs(pc_payment_due_date - vd_lower_date);
    vn_upper_date_diff := abs(pc_payment_due_date - vd_upper_date);
    if vn_lower_date_diff < vn_upper_date_diff then
      vd_maturity_date := vd_lower_date;
    else
      vd_maturity_date := vd_upper_date;
    end if;
    select icd.market_rate
      into vn_interest_rate
      from ich_interest_curve_header@eka_appdb ich,
           icd_interest_curve_detail@eka_appdb icd
     where icd.maturity_date = vd_maturity_date
       and icd.ir_id = ich.ir_id
       and ich.interest_curve_id = pc_interest_curve_id
       and icd.ir_id = pc_ir_id
       and ich.trade_date = pd_trade_date;
    return(vn_interest_rate);
  end;

  function f_get_currency_pair(pc_corporate_id  varchar2,
                               pc_from_cur_id   in varchar2,
                               pc_from_cur_code in varchar2,
                               pc_to_cur_id     in varchar2,
                               pc_to_cur_code   in varchar2) return varchar2 is
    vc_result        varchar2(100);
    vc_base_cur_id   varchar2(15);
    vc_base_cur_code varchar2(15);
    vc_result1       varchar2(50);
    vc_result2       varchar2(50);
  begin
    select cm.cur_id,
           cm.cur_code
      into vc_base_cur_id,
           vc_base_cur_code
      from ak_corporate       akc,
           cm_currency_master cm
     where akc.corporate_id = pc_corporate_id
       and akc.base_currency_name = cm.cur_code;
    if pc_from_cur_id <> pc_to_cur_id then
      --
      -- Check the to currency in the currency pair
      -- If it is Base currency then we need to get the exchange rate directly
      --
      if pc_to_cur_id = vc_base_cur_id then
        vc_result := pc_from_cur_code || '/' || pc_to_cur_code;
      else
        -- Get Exchange Rate from 'From Currency ID' to Base Currency ID = X
        -- Get Exchange Rate from 'To Currency ID' to Base Currency ID = Y
        -- Exchange Rate and Forward Point = X/Y
        if pc_from_cur_id <> vc_base_cur_id then
          vc_result1 := pc_from_cur_code || '/' || vc_base_cur_code;
        else
          vc_result1 := '';
        end if;
        if pc_to_cur_id <> vc_base_cur_id then
          vc_result2 := pc_to_cur_code || '/' || vc_base_cur_code;
        else
          vc_result2 := '';
        end if;
        if vc_result1 is not null and vc_result2 is not null then
          vc_result := vc_result1 || ', ' || vc_result2;
        elsif vc_result1 is null and vc_result2 is not null then
          vc_result := vc_result2;
        elsif vc_result1 is not null and vc_result2 is null then
          vc_result := vc_result1;
        else
          vc_result := '';
        end if;
      end if;
    else
      vc_result := '';
    end if;
    return(vc_result);
  exception
    when no_data_found then
      vc_result := '';
      return(vc_result);
    when others then
      vc_result := '';
      return(vc_result);
  end;

  function f_get_currency_pair_decimals(pc_from_cur_id in varchar2,
                                        pc_to_cur_id   in varchar2)
    return number is
    vn_cur_decimal number;
  begin
    begin
      vn_cur_decimal := 8;
      /* SELECT nvl(fcm.factor, 8)
       INTO vn_cur_decimal
       FROM fcm_forex_conversion_master fcm
      WHERE fcm.from_cur_unit_id = pc_from_cur_id
        AND fcm.to_cur_unit_id = pc_to_cur_id;*/
    exception
      when no_data_found then
        vn_cur_decimal := 8;
      when others then
        vn_cur_decimal := 8;
    end;
    return(vn_cur_decimal);
  end;
  function fn_mass_volume_qty_conversion(
                                         
                                         pc_product_id                 in varchar2,
                                         pc_from_qty_unit_id           in varchar2,
                                         pc_to_qty_unit_id             in varchar2,
                                         pn_qty_to_be_converted        in number,
                                         pn_gravity                    in number,
                                         pc_gravity_type               in varchar2,
                                         pc_density_mass_qty_unit_id   in varchar2,
                                         pc_density_volume_qty_unit_id in varchar2)
    return number is
    vn_conv_factor            number;
    vn_converted_qty          number;
    vc_is_same_classification varchar2(1);
    vn_gravity_to_use         number;
    vn_api_gravity_dividend   number(20, 5) := 141.5;
    vn_api_gravity_add        number(20, 5) := 131.5;
    vn_temp_result            number;
  begin
  
    vc_is_same_classification := f_get_is_same_classification(pc_from_qty_unit_id,
                                                              pc_to_qty_unit_id);
  
    if (vc_is_same_classification = 'Y') then
    
      vn_conv_factor   := f_get_conv_factor(pc_from_qty_unit_id,
                                            pc_to_qty_unit_id,
                                            pc_product_id);
      vn_converted_qty := pn_qty_to_be_converted * vn_conv_factor;
    
    else
      if (pc_gravity_type = 'SG') then
        vn_gravity_to_use := pn_gravity;
      else
        vn_gravity_to_use := vn_api_gravity_dividend /
                             (pn_gravity + vn_api_gravity_add);
      end if;
    
      vc_is_same_classification := f_get_is_same_classification(pc_from_qty_unit_id,
                                                                pc_density_mass_qty_unit_id);
      if (vc_is_same_classification = 'Y') then
        vn_conv_factor   := f_get_conv_factor(pc_from_qty_unit_id,
                                              pc_density_mass_qty_unit_id,
                                              pc_product_id);
        vn_temp_result   := pn_qty_to_be_converted * vn_conv_factor;
        vn_temp_result   := vn_temp_result / vn_gravity_to_use;
        vn_converted_qty := vn_temp_result *
                            f_get_conv_factor(pc_density_volume_qty_unit_id,
                                              pc_to_qty_unit_id,
                                              pc_product_id);
      else
        vn_conv_factor   := f_get_conv_factor(pc_from_qty_unit_id,
                                              pc_density_volume_qty_unit_id,
                                              pc_product_id);
        vn_temp_result   := pn_qty_to_be_converted * vn_conv_factor;
        vn_temp_result   := vn_temp_result * vn_gravity_to_use;
        vn_converted_qty := vn_temp_result *
                            f_get_conv_factor(pc_density_mass_qty_unit_id,
                                              pc_to_qty_unit_id,
                                              pc_product_id);
      end if;
    
    end if;
  
    return vn_converted_qty;
  
  exception
    when no_data_found then
      return - 1;
    when others then
      return - 1;
    
  end;

  procedure sp_bank_fx_rate
  /**************************************************************************************************
    Function Name                       : sp_bank_fx_rate
    Author                              : Suresh Gottipati
    Created Date                        : 03rd Feb 2012
    Purpose                             : To get forward exchange rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id         in varchar2,
   pd_trade_date           in date,
   pd_maturity_date        in date,
   pc_from_cur_id          in varchar2,
   pc_to_cur_id            in varchar2,
   pc_max_deviation        in number,
   pc_from_where           in varchar2,
   pc_process              in varchar2,
   pc_settlement_price     out number,
   pc_sum_of_forward_point out number) is
    vd_lower_date       date;
    vd_upper_date       date;
    vd_maturity_date    date;
    vn_lower_date_diff  number;
    vn_upper_date_diff  number;
    vobj_error_log      tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count  number := 1;
    vc_from_cur_code    varchar2(15);
    vc_to_cur_code      varchar2(15);
    vc_insturment_id    varchar2(15);
    vd_valid_quote_date date;
  begin
    if pc_from_cur_id = pc_to_cur_id then
      pc_settlement_price     := 1;
      pc_sum_of_forward_point := 0;
    else
      begin
        select cm.cur_code
          into vc_from_cur_code
          from cm_currency_master cm
         where cm.cur_id = pc_from_cur_id;
        select cm.cur_code
          into vc_to_cur_code
          from cm_currency_master cm
         where cm.cur_id = pc_to_cur_id;
        begin
          select cci.instrument_id,
                 cdim.valid_quote_date
            into vc_insturment_id,
                 vd_valid_quote_date
            from cci_corp_currency_instrument cci,
                 cdim_corporate_dim           cdim,
                 dim_der_instrument_master    dim,
                 pdd_product_derivative_def   pdd,
                 pdm_productmaster            pdm
           where cci.corporate_id = pc_corporate_id
             and cci.instrument_id = cdim.instrument_id
             and dim.instrument_id = cdim.instrument_id
             and dim.product_derivative_id = pdd.derivative_def_id
             and pdd.product_id = pdm.product_id
             and pdm.base_cur_id = pc_from_cur_id
             and pdm.quote_cur_id = pc_to_cur_id
             and cci.is_deleted = 'N'
             and cdim.is_active = 'Y'
             and pdm.is_active = 'Y'
             and pdd.is_active = 'Y'
             and dim.is_active = 'Y'
             and cdim.corporate_id = pc_corporate_id;
        exception
          when no_data_found then
            select cci.instrument_id,
                   cdim.valid_quote_date
              into vc_insturment_id,
                   vd_valid_quote_date
              from cci_corp_currency_instrument cci,
                   cdim_corporate_dim           cdim,
                   dim_der_instrument_master    dim,
                   pdd_product_derivative_def   pdd,
                   pdm_productmaster            pdm
             where cci.corporate_id = pc_corporate_id
               and cci.instrument_id = cdim.instrument_id
               and dim.instrument_id = cdim.instrument_id
               and dim.product_derivative_id = pdd.derivative_def_id
               and pdd.product_id = pdm.product_id
               and pdm.base_cur_id = pc_to_cur_id
               and pdm.quote_cur_id = pc_from_cur_id
               and cci.is_deleted = 'N'
               and cdim.is_active = 'Y'
               and dim.is_active = 'Y'
               and pdd.is_active = 'Y'
               and pdm.is_active = 'Y'
               and cdim.corporate_id = pc_corporate_id;
        end;
      
        if pc_from_cur_id <> pc_to_cur_id then
          begin
            select max(cfq.prompt_date)
              into vd_maturity_date
              from mv_cfq_cci_cur_forward_quotes cfq,
                   div_der_instrument_valuation  div
             where cfq.corporate_id = pc_corporate_id
               and cfq.instrument_id = vc_insturment_id
               and cfq.trade_date = nvl(vd_valid_quote_date, pd_trade_date)
               and cfq.prompt_date = pd_maturity_date
               and cfq.base_cur_id = pc_from_cur_id
               and cfq.quote_cur_id = pc_to_cur_id
               and cfq.instrument_id = div.instrument_id
               and cfq.price_source_id = div.price_source_id
               and div.is_deleted = 'N';
          exception
            when no_data_found then
              vd_maturity_date := null;
          end;
          if vd_maturity_date is null then
            begin
              select max(cfq.prompt_date)
                into vd_lower_date
                from mv_cfq_cci_cur_forward_quotes cfq,
                     div_der_instrument_valuation  div
               where cfq.corporate_id = pc_corporate_id
                 and cfq.instrument_id = vc_insturment_id
                 and cfq.trade_date =
                     nvl(vd_valid_quote_date, pd_trade_date)
                 and cfq.prompt_date <= pd_maturity_date
                 and abs(pd_maturity_date - cfq.prompt_date) <=
                     pc_max_deviation --lalit
                 and cfq.base_cur_id = pc_from_cur_id
                 and cfq.quote_cur_id = pc_to_cur_id
                 and cfq.instrument_id = div.instrument_id
                 and cfq.price_source_id = div.price_source_id
                 and div.is_deleted = 'N';
            exception
              when no_data_found then
                vd_lower_date := null;
            end;
            begin
              select min(cfq.prompt_date)
                into vd_upper_date
                from mv_cfq_cci_cur_forward_quotes cfq,
                     div_der_instrument_valuation  div
               where cfq.corporate_id = pc_corporate_id
                 and cfq.instrument_id = vc_insturment_id
                 and cfq.trade_date =
                     nvl(vd_valid_quote_date, pd_trade_date)
                 and cfq.prompt_date >= pd_maturity_date
                 and abs(pd_maturity_date - cfq.prompt_date) <=
                     pc_max_deviation --Lalit
                 and cfq.base_cur_id = pc_from_cur_id
                 and cfq.quote_cur_id = pc_to_cur_id
                 and cfq.instrument_id = div.instrument_id
                 and cfq.price_source_id = div.price_source_id
                 and div.is_deleted = 'N';
            exception
              when no_data_found then
                vd_upper_date := null;
            end;
            vn_lower_date_diff := nvl(abs(pd_maturity_date - vd_lower_date),
                                      999);
            vn_upper_date_diff := nvl(abs(pd_maturity_date - vd_upper_date),
                                      999);
            if vd_lower_date is null and vd_upper_date is null then
              vd_maturity_date    := null;
              pc_settlement_price := 0;
            else
              if vn_lower_date_diff <= vn_upper_date_diff then
                vd_maturity_date := vd_lower_date;
              else
                vd_maturity_date := vd_upper_date;
              end if;
            end if;
          end if;
          --If the maturity date is configured for the currency pair get the exchange rate
          if vd_maturity_date is not null then
            begin
              select t.settlement_price,
                     t.sum_forward_point
                into pc_settlement_price,
                     pc_sum_of_forward_point
                from (select cfq.rate settlement_price,
                             nvl(cfq.forward_point, 0) sum_forward_point
                        from mv_cfq_cci_cur_forward_quotes cfq,
                             div_der_instrument_valuation  div
                       where cfq.corporate_id = pc_corporate_id
                         and cfq.instrument_id = vc_insturment_id
                         and cfq.trade_date =
                             nvl(vd_valid_quote_date, pd_trade_date)
                         and cfq.prompt_date = vd_maturity_date
                         and cfq.base_cur_id = pc_from_cur_id
                         and cfq.quote_cur_id = pc_to_cur_id
                         and cfq.instrument_id = div.instrument_id
                         and cfq.price_source_id = div.price_source_id
                         and div.is_deleted = 'N') t;
            exception
              when no_data_found then
                pc_settlement_price     := 0;
                pc_sum_of_forward_point := 0;
            end;
          else
            pc_settlement_price     := 0;
            pc_sum_of_forward_point := 0;
          end if;
          if pc_settlement_price = 0 then
            -- its likely that the pair is not configured.
            --try reverse pair
            begin
              select max(cfq.prompt_date)
                into vd_maturity_date
                from mv_cfq_currency_forward_quotes cfq,
                     div_der_instrument_valuation   div
               where cfq.corporate_id = pc_corporate_id
                 and cfq.instrument_id = vc_insturment_id
                 and cfq.trade_date =
                     nvl(vd_valid_quote_date, pd_trade_date)
                 and cfq.prompt_date = pd_maturity_date
                 and cfq.base_cur_id = pc_to_cur_id
                 and cfq.quote_cur_id = pc_from_cur_id
                 and cfq.instrument_id = div.instrument_id
                 and cfq.price_source_id = div.price_source_id
                 and div.is_deleted = 'N';
            exception
              when no_data_found then
                vd_maturity_date := null;
            end;
          
            if vd_maturity_date is null then
              begin
                select max(cfq.prompt_date)
                  into vd_lower_date
                  from mv_cfq_cci_cur_forward_quotes cfq,
                       div_der_instrument_valuation  div
                 where cfq.corporate_id = pc_corporate_id
                   and cfq.instrument_id = vc_insturment_id
                   and cfq.trade_date =
                       nvl(vd_valid_quote_date, pd_trade_date)
                   and cfq.prompt_date <= pd_maturity_date
                   and abs(pd_maturity_date - cfq.prompt_date) <=
                       pc_max_deviation --lalit
                   and cfq.base_cur_id = pc_to_cur_id
                   and cfq.quote_cur_id = pc_from_cur_id
                   and cfq.instrument_id = div.instrument_id
                   and cfq.price_source_id = div.price_source_id
                   and div.is_deleted = 'N';
              exception
                when no_data_found then
                  vd_lower_date := null;
              end;
              begin
                select min(cfq.prompt_date)
                  into vd_upper_date
                  from mv_cfq_cci_cur_forward_quotes cfq,
                       div_der_instrument_valuation  div
                 where cfq.corporate_id = pc_corporate_id
                   and cfq.instrument_id = vc_insturment_id
                   and cfq.trade_date =
                       nvl(vd_valid_quote_date, pd_trade_date)
                   and cfq.prompt_date >= pd_maturity_date
                   and abs(pd_maturity_date - cfq.prompt_date) <=
                       pc_max_deviation --Lalit
                   and cfq.base_cur_id = pc_to_cur_id
                   and cfq.quote_cur_id = pc_from_cur_id
                   and cfq.instrument_id = div.instrument_id
                   and cfq.price_source_id = div.price_source_id
                   and div.is_deleted = 'N';
              exception
                when no_data_found then
                  vd_upper_date := null;
              end;
              vn_lower_date_diff := nvl(abs(pd_maturity_date -
                                            vd_lower_date),
                                        999);
              vn_upper_date_diff := nvl(abs(pd_maturity_date -
                                            vd_upper_date),
                                        999);
              if vd_lower_date is null and vd_upper_date is null then
                vd_maturity_date    := null;
                pc_settlement_price := 0;
              else
                if vn_lower_date_diff <= vn_upper_date_diff then
                  vd_maturity_date := vd_lower_date;
                else
                  vd_maturity_date := vd_upper_date;
                end if;
              end if;
            end if;
          
            if vd_maturity_date is not null then
              begin
                select 1 / t.settlement_price,
                       t.sum_forward_point
                  into pc_settlement_price,
                       pc_sum_of_forward_point
                  from (select cfq.rate settlement_price,
                               nvl(cfq.forward_point, 0) sum_forward_point
                          from mv_cfq_cci_cur_forward_quotes cfq,
                               div_der_instrument_valuation  div
                         where cfq.corporate_id = pc_corporate_id
                           and cfq.instrument_id = vc_insturment_id
                           and cfq.trade_date =
                               nvl(vd_valid_quote_date, pd_trade_date)
                           and cfq.prompt_date = vd_maturity_date
                           and cfq.base_cur_id = pc_to_cur_id
                           and cfq.quote_cur_id = pc_from_cur_id
                           and cfq.instrument_id = div.instrument_id
                           and cfq.price_source_id = div.price_source_id
                           and div.is_deleted = 'N') t;
              exception
                when no_data_found then
                  pc_settlement_price     := 0;
                  pc_sum_of_forward_point := 0;
              end;
            else
              pc_settlement_price     := 0;
              pc_sum_of_forward_point := 0;
            end if;
          end if;
        else
          pc_settlement_price     := 1;
          pc_sum_of_forward_point := 0;
        end if;
      exception
        when others then
          pc_settlement_price     := 0;
          pc_sum_of_forward_point := 0;
      end;
    end if;
    pc_settlement_price := round(nvl(pc_settlement_price, 0), 10);
  
    if pc_settlement_price = 0 or pc_settlement_price is null then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           pc_from_where,
                                                           'PHY-005',
                                                           vc_from_cur_code ||
                                                           ' to ' ||
                                                           vc_to_cur_code || ' (' ||
                                                           to_char(pd_maturity_date,
                                                                   'dd-Mon-yyyy') || ') ' ||
                                                           'Trade date:' || ' ' ||
                                                           to_char(vd_valid_quote_date,
                                                                   'dd-Mon-yyyy'),
                                                           '', -- trade_ref_no
                                                           pc_process,
                                                           null, -- pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    end if;
  end;

  function fn_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                         pd_trade_date       date)
    return date is
    cursor cr_monthly_prompt_rule is
      select mpc.*
        from mpc_monthly_prompt_calendar mpc
       where mpc.prompt_delivery_calendar_id = pc_promp_del_cal_id;
  
    cursor cr_applicable_months is
      select mpcm.*
        from mpcm_monthly_prompt_cal_month mpcm,
             mnm_month_name_master         mnm
       where mpcm.prompt_delivery_calendar_id = pc_promp_del_cal_id
         and mpcm.applicable_month = mnm.month_name_id
       order by mnm.display_order;
  
    pc_pdc_period_type_id      varchar2(15);
    pc_month_prompt_start_date date;
    pc_equ_period_type         number;
    cr_monthly_prompt_rule_rec cr_monthly_prompt_rule%rowtype;
    pc_period_to               number;
    pc_start_date              date;
    pc_end_date                date;
    pc_month                   varchar2(15);
    pc_year                    number;
    pn_month_count             number(5);
    vc_prompt_date             date;
  begin
    pc_month_prompt_start_date := pd_trade_date;
    pn_month_count             := 0;
    begin
      select pm.period_type_id
        into pc_pdc_period_type_id
        from pm_period_master pm
       where pm.period_type_name = 'Month';
    end;
  
    open cr_monthly_prompt_rule;
  
    fetch cr_monthly_prompt_rule
      into cr_monthly_prompt_rule_rec;
  
    pc_period_to := cr_monthly_prompt_rule_rec.period_for; --no of forward months required
  
    begin
      select pm.equivalent_days
        into pc_equ_period_type
        from pm_period_master pm
       where pm.period_type_id = cr_monthly_prompt_rule_rec.period_type_id;
    end;
    pc_start_date := pc_month_prompt_start_date;
    pc_end_date   := pc_month_prompt_start_date +
                     (pc_period_to * pc_equ_period_type);
    for cr_applicable_months_rec in cr_applicable_months
    loop
      pc_month_prompt_start_date := to_date(('01-' ||
                                            cr_applicable_months_rec.applicable_month || '-' ||
                                            to_char(pc_start_date, 'YYYY')),
                                            'dd/mm/yyyy');
      --------------------
      dbms_output.put_line('pc_month_prompt_start_date ' ||
                           pc_month_prompt_start_date);
      if (pc_month_prompt_start_date >=
         to_date(('01-' || to_char(pc_start_date, 'Mon-YYYY')),
                  'dd/mm/yyyy') and
         pc_month_prompt_start_date <= pc_end_date) then
        pn_month_count := pn_month_count + 1;
        if pn_month_count = 1 then
          pc_month := to_char(pc_month_prompt_start_date, 'Mon');
          pc_year  := to_char(pc_month_prompt_start_date, 'YYYY');
        end if;
      end if;
      exit when pn_month_count > 1;
      dbms_output.put_line('pc_month pc_year ' || pc_month || '-' ||
                           pc_year);
      ---------------
    end loop;
    close cr_monthly_prompt_rule;
    if pc_month is not null and pc_year is not null then
      vc_prompt_date := to_date('01-' || pc_month || '-' || pc_year,
                                'dd-Mon-yyyy');
    end if;
    return vc_prompt_date;
  end;
  procedure sp_bank_fx_rate_spot
  /**************************************************************************************************
    Function Name                       : sp_bank_fx_rate
    Author                              : Suresh Gottipati
    Created Date                        : 9th Oct 2012
    Purpose                             : Get Spot Exchange Rate
    
    Parameters                          :
    
    Returns                             :
    
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id     in varchar2,
   pd_trade_date       in date,
   pc_from_cur_id      in varchar2,
   pc_to_cur_id        in varchar2,
   pc_from_where       in varchar2,
   pc_process          in varchar2,
   pc_settlement_price out number) is
    vobj_error_log      tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count  number := 1;
    vc_from_cur_code    varchar2(15);
    vc_to_cur_code      varchar2(15);
    vc_insturment_id    varchar2(15);
    vd_valid_quote_date date;
  begin
    if pc_from_cur_id = pc_to_cur_id then
      pc_settlement_price := 1;
    else
      begin
        select cm.cur_code
          into vc_from_cur_code
          from cm_currency_master cm
         where cm.cur_id = pc_from_cur_id;
        select cm.cur_code
          into vc_to_cur_code
          from cm_currency_master cm
         where cm.cur_id = pc_to_cur_id;
        -- Get Instrument and Valid Quote Date
        begin
          select cci.instrument_id,
                 cdim.valid_quote_date
            into vc_insturment_id,
                 vd_valid_quote_date
            from cci_corp_currency_instrument cci,
                 cdim_corporate_dim           cdim,
                 dim_der_instrument_master    dim,
                 pdd_product_derivative_def   pdd,
                 pdm_productmaster            pdm
           where cci.corporate_id = pc_corporate_id
             and cci.instrument_id = cdim.instrument_id
             and dim.instrument_id = cdim.instrument_id
             and dim.product_derivative_id = pdd.derivative_def_id
             and pdd.product_id = pdm.product_id
             and pdm.base_cur_id = pc_from_cur_id
             and pdm.quote_cur_id = pc_to_cur_id
             and cci.is_deleted = 'N'
             and cdim.is_active = 'Y'
             and pdm.is_active = 'Y'
             and pdd.is_active = 'Y'
             and dim.is_active = 'Y'
             and cdim.corporate_id = pc_corporate_id;
        exception
          when no_data_found then
            select cci.instrument_id,
                   cdim.valid_quote_date
              into vc_insturment_id,
                   vd_valid_quote_date
              from cci_corp_currency_instrument cci,
                   cdim_corporate_dim           cdim,
                   dim_der_instrument_master    dim,
                   pdd_product_derivative_def   pdd,
                   pdm_productmaster            pdm
             where cci.corporate_id = pc_corporate_id
               and cci.instrument_id = cdim.instrument_id
               and dim.instrument_id = cdim.instrument_id
               and dim.product_derivative_id = pdd.derivative_def_id
               and pdd.product_id = pdm.product_id
               and pdm.base_cur_id = pc_to_cur_id
               and pdm.quote_cur_id = pc_from_cur_id
               and cci.is_deleted = 'N'
               and cdim.is_active = 'Y'
               and dim.is_active = 'Y'
               and pdd.is_active = 'Y'
               and pdm.is_active = 'Y'
               and cdim.corporate_id = pc_corporate_id;
          when others then
            pc_settlement_price := 0;
        end;
        -- Get the quote either from the same currency pair or reverse pair
        begin
          select t.settlement_price
            into pc_settlement_price
            from (select cfq.rate settlement_price
                    from mv_cfq_cci_cur_forward_quotes cfq,
                         div_der_instrument_valuation  div
                   where cfq.corporate_id = pc_corporate_id
                     and cfq.instrument_id = vc_insturment_id
                     and cfq.trade_date =
                         nvl(vd_valid_quote_date, pd_trade_date)
                     and cfq.prompt_date =
                         nvl(vd_valid_quote_date, pd_trade_date)
                     and cfq.base_cur_id = pc_from_cur_id
                     and cfq.quote_cur_id = pc_to_cur_id
                     and cfq.instrument_id = div.instrument_id
                     and cfq.price_source_id = div.price_source_id
                     and div.is_deleted = 'N') t;
        exception
          when no_data_found then
            pc_settlement_price := 0;
        end;
        if pc_settlement_price = 0 then
          -- its likely that the pair is not configured, try reverse pair
          begin
            select 1 / t.settlement_price
              into pc_settlement_price
              from (select cfq.rate settlement_price
                      from mv_cfq_cci_cur_forward_quotes cfq,
                           div_der_instrument_valuation  div
                     where cfq.corporate_id = pc_corporate_id
                       and cfq.instrument_id = vc_insturment_id
                       and cfq.trade_date =
                           nvl(vd_valid_quote_date, pd_trade_date)
                       and cfq.prompt_date =
                           nvl(vd_valid_quote_date, pd_trade_date)
                       and cfq.base_cur_id = pc_to_cur_id
                       and cfq.quote_cur_id = pc_from_cur_id
                       and cfq.instrument_id = div.instrument_id
                       and cfq.price_source_id = div.price_source_id
                       and div.is_deleted = 'N') t;
          exception
            when no_data_found then
              pc_settlement_price := 0;
            when others then
              pc_settlement_price := 0;
          end;
        end if;
      exception
        when others then
          pc_settlement_price := 0;
      end;
    end if;
    pc_settlement_price := round(nvl(pc_settlement_price, 0), 10);
    if pc_settlement_price = 0 or pc_settlement_price is null then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           pc_from_where,
                                                           'PHY-005',
                                                           vc_from_cur_code ||
                                                           ' to ' ||
                                                           vc_to_cur_code || '(' ||
                                                           to_char(vd_valid_quote_date,
                                                                   'dd-Mon-yyyy') || ')' ||
                                                           ' Trade date:' || ' ' ||
                                                           to_char(vd_valid_quote_date,
                                                                   'dd-Mon-yyyy'),
                                                           '', -- trade_ref_no
                                                           pc_process,
                                                           null, -- pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    end if;
  end;
  procedure sp_bank_fx_rate_spot_fw_points
  /**************************************************************************************************
    Function Name                       : sp_bank_fx_rate_spot_fw_points
    Author                              : Suresh Gottipati
    Created Date                        : 03rd Feb 2012
    Purpose                             : To get forward exchange rates
    
    Parameters                          :
    
    Returns                             :
    
    Number                              : Converted Qty
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id         in varchar2,
   pd_trade_date           in date,
   pd_maturity_date        in date,
   pc_from_cur_id          in varchar2,
   pc_to_cur_id            in varchar2,
   pc_from_where           in varchar2,
   pc_process              in varchar2,
   pc_settlement_price     out number,
   pc_sum_of_forward_point out number) is
    vd_maturity_date    date;
    vobj_error_log      tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count  number := 1;
    vc_from_cur_code    varchar2(15);
    vc_to_cur_code      varchar2(15);
    vc_insturment_id    varchar2(15);
    vd_valid_quote_date date;
  begin
    if pc_from_cur_id = pc_to_cur_id then
      pc_settlement_price     := 1;
      pc_sum_of_forward_point := 0;
    else
      begin
        select cm.cur_code
          into vc_from_cur_code
          from cm_currency_master cm
         where cm.cur_id = pc_from_cur_id;
        select cm.cur_code
          into vc_to_cur_code
          from cm_currency_master cm
         where cm.cur_id = pc_to_cur_id;
        begin
          select cci.instrument_id,
                 cdim.valid_quote_date
            into vc_insturment_id,
                 vd_valid_quote_date
            from cci_corp_currency_instrument cci,
                 cdim_corporate_dim           cdim,
                 dim_der_instrument_master    dim,
                 pdd_product_derivative_def   pdd,
                 pdm_productmaster            pdm
           where cci.corporate_id = pc_corporate_id
             and cci.instrument_id = cdim.instrument_id
             and dim.instrument_id = cdim.instrument_id
             and dim.product_derivative_id = pdd.derivative_def_id
             and pdd.product_id = pdm.product_id
             and pdm.base_cur_id = pc_from_cur_id
             and pdm.quote_cur_id = pc_to_cur_id
             and cci.is_deleted = 'N'
             and cdim.is_active = 'Y'
             and pdm.is_active = 'Y'
             and pdd.is_active = 'Y'
             and dim.is_active = 'Y'
             and cdim.corporate_id = pc_corporate_id;
          select nvl(max(cfq.prompt_date), vd_valid_quote_date) -- If no forward points then look at Spot Only
            into vd_maturity_date
            from mv_cfq_cci_cur_forward_quotes cfq,
                 div_der_instrument_valuation  div
           where cfq.corporate_id = pc_corporate_id
             and cfq.instrument_id = vc_insturment_id
             and cfq.trade_date = nvl(vd_valid_quote_date, pd_trade_date)
             and cfq.prompt_date <= pd_maturity_date
             and cfq.base_cur_id = pc_from_cur_id
             and cfq.quote_cur_id = pc_to_cur_id
             and cfq.instrument_id = div.instrument_id
             and cfq.price_source_id = div.price_source_id
             and div.is_deleted = 'N';
          begin
            select t.settlement_price,
                   t.sum_forward_point
              into pc_settlement_price,
                   pc_sum_of_forward_point
              from (select cfq.rate settlement_price,
                           nvl(cfq.forward_point, 0) sum_forward_point
                      from mv_cfq_cci_cur_forward_quotes cfq,
                           div_der_instrument_valuation  div
                     where cfq.corporate_id = pc_corporate_id
                       and cfq.instrument_id = vc_insturment_id
                       and cfq.trade_date =
                           nvl(vd_valid_quote_date, pd_trade_date)
                       and cfq.prompt_date = vd_maturity_date
                       and cfq.base_cur_id = pc_from_cur_id
                       and cfq.quote_cur_id = pc_to_cur_id
                       and cfq.instrument_id = div.instrument_id
                       and cfq.price_source_id = div.price_source_id
                       and div.is_deleted = 'N') t;
          end;
        exception
          -- its likely that the pair is not configured, try reverse pair
          when no_data_found then
            select cci.instrument_id,
                   cdim.valid_quote_date
              into vc_insturment_id,
                   vd_valid_quote_date
              from cci_corp_currency_instrument cci,
                   cdim_corporate_dim           cdim,
                   dim_der_instrument_master    dim,
                   pdd_product_derivative_def   pdd,
                   pdm_productmaster            pdm
             where cci.corporate_id = pc_corporate_id
               and cci.instrument_id = cdim.instrument_id
               and dim.instrument_id = cdim.instrument_id
               and dim.product_derivative_id = pdd.derivative_def_id
               and pdd.product_id = pdm.product_id
               and pdm.base_cur_id = pc_to_cur_id
               and pdm.quote_cur_id = pc_from_cur_id
               and cci.is_deleted = 'N'
               and cdim.is_active = 'Y'
               and dim.is_active = 'Y'
               and pdd.is_active = 'Y'
               and pdm.is_active = 'Y'
               and cdim.corporate_id = pc_corporate_id;
            begin
              select nvl(max(cfq.prompt_date), vd_valid_quote_date) -- If no forward points then look at Spot Only
                into vd_maturity_date
                from mv_cfq_currency_forward_quotes cfq,
                     div_der_instrument_valuation   div
               where cfq.corporate_id = pc_corporate_id
                 and cfq.instrument_id = vc_insturment_id
                 and cfq.trade_date =
                     nvl(vd_valid_quote_date, pd_trade_date)
                 and cfq.prompt_date <= pd_maturity_date
                 and cfq.base_cur_id = pc_to_cur_id
                 and cfq.quote_cur_id = pc_from_cur_id
                 and cfq.instrument_id = div.instrument_id
                 and cfq.price_source_id = div.price_source_id
                 and div.is_deleted = 'N';
              begin
                select 1 / t.settlement_price,
                       t.sum_forward_point
                  into pc_settlement_price,
                       pc_sum_of_forward_point
                  from (select cfq.rate settlement_price,
                               nvl(cfq.forward_point, 0) sum_forward_point
                          from mv_cfq_cci_cur_forward_quotes cfq,
                               div_der_instrument_valuation  div
                         where cfq.corporate_id = pc_corporate_id
                           and cfq.instrument_id = vc_insturment_id
                           and cfq.trade_date =
                               nvl(vd_valid_quote_date, pd_trade_date)
                           and cfq.prompt_date = vd_maturity_date
                           and cfq.base_cur_id = pc_to_cur_id
                           and cfq.quote_cur_id = pc_from_cur_id
                           and cfq.instrument_id = div.instrument_id
                           and cfq.price_source_id = div.price_source_id
                           and div.is_deleted = 'N') t;
              exception
                when no_data_found then
                  pc_settlement_price     := 0;
                  pc_sum_of_forward_point := 0;
              end;
            end;
        end;
      exception
        when others then
          pc_settlement_price     := 0;
          pc_sum_of_forward_point := 0;
      end;
    end if;
    pc_settlement_price := round(nvl(pc_settlement_price, 0), 10);
    if pc_settlement_price = 0 or pc_settlement_price is null then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           pc_from_where,
                                                           'PHY-005',
                                                           vc_from_cur_code ||
                                                           ' to ' ||
                                                           vc_to_cur_code || '(' ||
                                                           to_char(pd_maturity_date,
                                                                   'dd-Mon-yyyy') || ') ' ||
                                                           'Trade date:' || ' ' ||
                                                           to_char(vd_valid_quote_date,
                                                                   'dd-Mon-yyyy'),
                                                           '', -- trade_ref_no
                                                           pc_process,
                                                           null, -- pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    end if;
  end;
end;
/
