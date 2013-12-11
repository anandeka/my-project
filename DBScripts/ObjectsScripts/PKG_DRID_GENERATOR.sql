create or replace package "PKG_DRID_GENERATOR" is
  -- Author  : ANU K
  -- Created : 12/06/2010 10:42:19 AM
  -- Purpose : Dr Id generation package for derivative
  -- Global Variables
  pc_period_type varchar2(15);
  pc_dr_id varchar2(15);
  pc_instr_id varchar2(15);
  pc_del_period_id varchar2(15);
  --Global Cursors
  cursor cr_instrument is
    select d.instrument_id,
           d.instrument_name,
           d.instrument_type_id,
           d.product_derivative_id,
           d.instrument_symbol,
           d.holiday_calender_id,
           d.delivery_calender_id,
           d.is_auto_generate,
           d.is_manual_generate,
           d.prompt_date_defn,
           d.prompt_days,
           d.warrant_tollerence,
           d.instrument_sub_type_id,
           d.underlying_instrument_id,
           d.is_cash_settlement,
           d.is_physical_settlement,
           d.settlement_type,
           d.spot_frequency,
           d.m2m_instrument_id,
           d.display_order,
           d.version,
           d.is_active,
           d.is_deleted,
           d.is_currency_curve,
           p.prompt_delivery_calendar_name,
           p.is_daily_cal_applicable,
           p.is_weekly_cal_applicable,
           p.is_monthly_cal_applicable,
           p.is_quarterly_cal_applicable,
           p.is_season_cal_applicable,
           p.is_yearly_cal_applicable,
           i.instrument_type
      from dim_der_instrument_master    d,
           pdc_prompt_delivery_calendar p,
           irm_instrument_type_master   i
     where d.delivery_calender_id = p.prompt_delivery_calendar_id
       and d.instrument_type_id = i.instrument_type_id
       and d.is_deleted = 'N'
       and d.is_active = 'Y'
       and p.is_active = 'Y'
       and p.is_deleted = 'N'
       and i.is_deleted = 'N'
       and d.instrument_id = pc_instr_id;
  cursor cr_delivery_period is
    select *
      from dpd_delivery_period_definition dpd
     where dpd.delivery_period_id = pc_del_period_id
       and dpd.instrument_id = pc_instr_id
       and dpd.is_deleted = 'N'
       and dpd.is_active = 'Y';
  cr_instrument_rec cr_instrument%rowtype;
  cr_delivery_period_rec cr_delivery_period%rowtype;
  ----------------------------------------------------------------------------
  ------------- Main Function which is used to generate dr id ----------------
  ----------------------------------------------------------------------------
  function f_get_drid(pc_trade_date           in date,
                      pc_instrumentid         in varchar2,
                      pc_price_point_id       in varchar2,
                      pc_delivery_period_id   in varchar2,
                      pc_period_type_id       in varchar2,
                      pc_date                 in date,
                      pc_month                in varchar2,
                      pc_year                 in number,
                      pc_start_date           in date,
                      pc_end_date             in date,
                      pc_strike_price         in number,
                      pc_strike_price_unit_id in varchar2,
                      pd_avg_wk_start_date    in date,
                      pd_avg_wk_end_date      in date) return varchar2;
 ----------------------------------------------------------------------------
  ----------------- Function used to Process the dr id -----------------------
  ----------------------------------------------------------------------------
  function f_process_drid(pc_trade_date           in date,
                          pc_instrumentid         in varchar2,
                          pc_price_point_id       in varchar2,
                          pc_delivery_period_id   in varchar2,
                          pc_period_type_id       in varchar2,
                          pc_date                 in date,
                          pc_month                in varchar2,
                          pc_year                 in number,
                          pc_start_date           in date,
                          pc_end_date             in date,
                          pc_strike_price         in number,
                          pc_strike_price_unit_id in varchar2,
                          pd_avg_wk_start_date    in date,
                          pd_avg_wk_end_date      in date) return varchar2;
  ----------------------------------------------------------------------------
  --------------- Function used to generate DRIDs for Quotes -----------------
  ----------------------------------------------------------------------------
  function f_generate_drid_for_quotes(pc_trade_date           in date,
                                      pc_instrumentid         in varchar2,
                                      pc_price_source_id      in varchar2,
                                      pc_strike_price         in number,
                                      pc_strike_price_unit_id in varchar2)
    return varchar2;
  ----------------------------------------------------------------------------
  ----------------- Private Function used to create the DR-ID ----------------
  ----------------------------------------------------------------------------
  function f_create_drid(pc_instrument_id               in varchar2,
                         pc_price_point_id              in varchar2,
                         pc_period_type_id              in varchar2,
                         pc_prompt_delivery_calendar_id in varchar2,
                         pc_delivery_period_id          in varchar2,
                         pc_prompt_date                 in date,
                         pc_period_date                 in date,
                         pc_period_month                in varchar2,
                         pc_period_year                 in number,
                         pc_period_start_date           in date,
                         pc_period_end_date             in date,
                         pc_strike_price                in number,
                         pc_strike_price_unit_id        in varchar2,
                         pc_first_notice_date           in date,
                         pc_last_notice_date            in date,
                         pc_first_tradable_date         in date,
                         pc_last_tradable_date          in date,
                         pc_expiry_date                 in date)
    return varchar2;
  ----------------------------------------------------------------------------
  ------ Private Function used to get existing DR-ID for a Period Type  ------
  ----------------------------------------------------------------------------
  function f_get_existing_drid(pc_instrument_id        in varchar2,
                               pc_price_point_id       in varchar2,
                               pc_date                 in date,
                               pc_period_month         in varchar2,
                               pc_period_year          in number,
                               pc_start_date           in date,
                               pc_end_date             in date,
                               pc_strike_price         in number,
                               pc_strike_price_unit_id in varchar2)
    return varchar2;
  ----------------------------------------------------------------------------
  ------ Private Function used to get prompt day for given Delivery Period ---
  ----------------------------------------------------------------------------
  function f_get_prompt_date(pc_delivery_period_id in varchar2,
                             pc_month              in varchar2,
                             pc_year               in number,
                             pc_start_date         in date,
                             pc_end_date           in date) return date;
  ----------------------------------------------------------------------------
  --------- Private Procedure used to validate the inputs --------------------
  ----------------------------------------------------------------------------
  procedure p_validate_data(pc_trade_date           in date,
                            pc_instrumentid         in varchar2,
                            pc_price_point_id       in varchar2,
                            pc_delivery_period_id   in varchar2,
                            pc_period_type_id       in varchar2,
                            pc_date                 in date,
                            pc_month                in varchar2,
                            pc_year                 in number,
                            pc_start_date           in date,
                            pc_end_date             in date,
                            pc_strike_price         in number,
                            pc_strike_price_unit_id in varchar2,
                            pc_error_code           out varchar2);
  ----------------------------------------------------------------------------
  ---------  Private function to check if a date is tradable -----------------
  ----------------------------------------------------------------------------
  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;
  ----------------------------------------------------------------------------
  -----  Private function to check if a date and price point is tradable -----
  ----------------------------------------------------------------------------
  function f_is_pp_holiday(pc_instrumentid   in varchar2,
                           pc_price_point_id in varchar2,
                           pc_trade_date     date) return boolean;                            
  ----------------------------------------------------------------------------
  ---------  Private function to return a specific day in a month ------------
  ----------------------------------------------------------------------------
  function f_get_next_day(p_date     in date,
                          p_day      in varchar2,
                          p_position in number) return date;
  ----------------------------------------------------------------------------
  ---------  Private function to return a tradable day for a given date ------
  ----------------------------------------------------------------------------
  function f_get_next_tradable_day(pc_instrumentid in varchar2,
                                   pc_date         date) return date;
  ----------------------------------------------------------------------------
  --------- Private Procedure to Open Instrument Cursor ----------------------
  ----------------------------------------------------------------------------
  procedure p_open_instrument_cursor(pc_instrumentid in varchar2);
  ----------------------------------------------------------------------------
  --------- Private Procedure to Close Instrument Cursor ----------------------
  ----------------------------------------------------------------------------
  procedure p_close_instrument_cursor;
  ----------------------------------------------------------------------------
  --------- Private Procedure to Open Delivery Period Cursor -----------------
  ----------------------------------------------------------------------------
  procedure p_open_del_period_cursor(pc_instrumentid       in varchar2,
                                     pc_delivery_period_id in varchar2);
  ----------------------------------------------------------------------------
  --------- Private Procedure to Close Delivery Period Cursor ----------------
  ----------------------------------------------------------------------------
  procedure p_close_del_period_cursor;
  --
  function fn_get_child_drid(pc_drid                    in varchar2,
                             pc_underlying_instrumentid in varchar2,
                             pc_und_delivery_period_id  in varchar2,
                             pd_avg_wk_start_date       in date,
                             pd_avg_wk_end_date         in date)
    return varchar2;
  function fn_is_date(vc_datetext in varchar2) return number;
  ----------------------------------------------------------------------------
  ------ Public Function used to get existing DR-ID for a Quotes import
  ----------------------------------------------------------------------------
  function f_get_drid_for_import(pc_instrument_id    in varchar2,
                                 pd_trade_date       in date,
                                 pc_prompt_date_name in varchar2)
    return varchar2;
 
  function fn_is_npd(pc_instrumentid in varchar2, pc_date date)
    return boolean;
  function fn_get_substitute_dt_for_npd(pc_del_calendar_id varchar2,
                                        pc_date            date) return date;    
end pkg_drid_generator; 
/
create or replace package body "PKG_DRID_GENERATOR" is

  ------------------------------------------------------------------------------
  /* Function used to generate dr id */
  ------------------------------------------------------------------------------
  function f_get_drid(pc_trade_date           in date,
                      pc_instrumentid         in varchar2,
                      pc_price_point_id       in varchar2,
                      pc_delivery_period_id   in varchar2,
                      pc_period_type_id       in varchar2,
                      pc_date                 in date,
                      pc_month                in varchar2,
                      pc_year                 in number,
                      pc_start_date           in date,
                      pc_end_date             in date,
                      pc_strike_price         in number,
                      pc_strike_price_unit_id in varchar2,
                      pd_avg_wk_start_date    in date,
                      pd_avg_wk_end_date      in date) return varchar2 is
    -- Note:  pd_avg_wk_start_date, pd_avg_wk_end_date params added to generate the avg drid's undelying selected as week,
    -- in this case avg trade also will have start date,end date, week prompt date also will have start date,end date
    vc_underlying_instrument_id varchar2(15);
    vc_instrument_type          varchar2(50);
    vc_und_drid                 varchar2(15);
    vc_drid                     varchar2(15);
    vc_und_delivery_period_id   varchar2(15);
  begin
    begin
      select pm.period_type_name
        into pc_period_type
        from pm_period_master pm
       where pm.period_type_id = pc_period_type_id
         and pm.is_deleted = 'N';
    end;
    /* Printing Input Arguments */
    /*  dbms_output.put_line('<!--------DRID Generator called with arguments: pc_period_type= ' ||
    pc_period_type || ', pc_trade_date= ' ||
    pc_trade_date || ', pc_instrumentid= ' ||
    pc_instrumentid || ', pc_delivery_period_id= ' ||
    pc_delivery_period_id || ', pc_period_type_id= ' ||
    pc_period_type_id || ', pc_date= ' || pc_date ||
    ', pc_month= ' || pc_month || ', pc_year= ' ||
    pc_year || ', pc_start_date= ' || pc_start_date ||
    ', pc_end_date= ' || pc_end_date ||
    ', pc_strike_price= ' || pc_strike_price ||
    ', pc_price_point_id ' || pc_price_point_id ||
    ', pc_strike_price_unit_id= ' ||
    pc_strike_price_unit_id || ' -------->');*/
    /* Opening the Instrument Cursor */
    p_open_instrument_cursor(pc_instrumentid);
    /* Opening the Delivery Period Cursor */
    p_open_del_period_cursor(pc_instrumentid, pc_delivery_period_id);
    /** Process DR-ID **/
    pc_dr_id := f_process_drid(pc_trade_date,
                               pc_instrumentid,
                               pc_price_point_id,
                               pc_delivery_period_id,
                               pc_period_type_id,
                               pc_date,
                               pc_month,
                               pc_year,
                               pc_start_date,
                               pc_end_date,
                               pc_strike_price,
                               pc_strike_price_unit_id,
                               pd_avg_wk_start_date,
                               pd_avg_wk_end_date);
    vc_drid  := pc_dr_id;
    -- Get the underlying instrument id and current instument type, for Options instruments underlying DRID has to be generated
    vc_underlying_instrument_id := nvl(cr_instrument_rec.underlying_instrument_id,
                                       'NA');
    vc_und_delivery_period_id   := nvl(cr_delivery_period_rec.underlying_delivery_period_id,
                                       pc_delivery_period_id);
    if vc_underlying_instrument_id = pc_instrumentid then
      vc_underlying_instrument_id := 'NA';
    end if;
    vc_instrument_type := nvl(cr_instrument_rec.instrument_type, 'NA');
    /* Closing the Instrument Cursor */
    p_close_instrument_cursor;
    /* Closing the Delivery Period Cursor */
    p_close_del_period_cursor;
    --dbms_output.put_line('DrID Generated: ' || pc_dr_id);
    -- calculate for Options instruments underlying DRID
    if vc_instrument_type in ('Option Put', 'Option Call') and
       vc_underlying_instrument_id <> 'NA' and pc_dr_id is not null then
      vc_und_drid := fn_get_child_drid(vc_drid,
                                       vc_underlying_instrument_id,
                                       vc_und_delivery_period_id,
                                       pc_start_date,
                                       pc_end_date);
      --dbms_output.put_line('child_drid Generated: ' || vc_und_drid);
    end if;
    if vc_instrument_type = 'Average' and
       vc_underlying_instrument_id <> 'NA' and pc_dr_id is not null then
      vc_und_drid := fn_get_child_drid(vc_drid,
                                       vc_underlying_instrument_id,
                                       vc_und_delivery_period_id,
                                       pd_avg_wk_start_date,
                                       pd_avg_wk_end_date);
      --dbms_output.put_line('child_drid Generated: ' || vc_und_drid);
    end if;
    return vc_drid;
  end f_get_drid;

  ------------------------------------------------------------------------------
  /* Function used to Process the dr id */
  ------------------------------------------------------------------------------
  function f_process_drid(pc_trade_date           in date,
                          pc_instrumentid         in varchar2,
                          pc_price_point_id       in varchar2,
                          pc_delivery_period_id   in varchar2,
                          pc_period_type_id       in varchar2,
                          pc_date                 in date,
                          pc_month                in varchar2,
                          pc_year                 in number,
                          pc_start_date           in date,
                          pc_end_date             in date,
                          pc_strike_price         in number,
                          pc_strike_price_unit_id in varchar2,
                          pd_avg_wk_start_date    in date,
                          pd_avg_wk_end_date      in date) return varchar2 is
    --
    --Variables
    pc_curr_start_date     date;
    pc_curr_end_date       date;
    pc_prompt_date         date;
    pc_curr_date           date;
    pc_curr_month          varchar2(15);
    pc_curr_year           number(4);
    pc_first_notice_date   date;
    pc_last_notice_date    date;
    pc_first_tradable_date date;
    pc_last_tradable_date  date;
    pc_error_code          varchar2(15);
    vn_cal_npd_count       number;
    --Exceptions
    exception_input_missing exception;
    exception_day_not_tradable exception;
    exception_month_not_tradable exception;
    exception_month_not_setup exception;
    exception_day_is_holiday exception;
  begin
    vn_cal_npd_count := 0;
    if (pc_delivery_period_id is not null) then
      pc_curr_date           := cr_delivery_period_rec.period_date;
      pc_curr_month          := cr_delivery_period_rec.period_month;
      pc_curr_year           := cr_delivery_period_rec.period_year;
      pc_curr_start_date     := cr_delivery_period_rec.period_start_date;
      pc_curr_end_date       := cr_delivery_period_rec.period_end_date;
      pc_first_notice_date   := cr_delivery_period_rec.first_notice_date;
      pc_last_notice_date    := cr_delivery_period_rec.last_notice_date;
      pc_first_tradable_date := cr_delivery_period_rec.first_trading_date;
      pc_last_tradable_date  := cr_delivery_period_rec.last_trading_date;
    else
      pc_curr_date       := pc_date;
      pc_curr_month      := pc_month;
      pc_curr_year       := pc_year;
      pc_curr_start_date := pc_start_date;
      pc_curr_end_date   := pc_end_date;
      --TODO How to get the FND, LND, FTD, LTD for Auto Mode
    end if;
    /* Run Validations */
    p_validate_data(pc_trade_date,
                    pc_instrumentid,
                    pc_price_point_id,
                    pc_delivery_period_id,
                    pc_period_type_id,
                    pc_curr_date,
                    pc_curr_month,
                    pc_curr_year,
                    pc_curr_start_date,
                    pc_curr_end_date,
                    pc_strike_price,
                    pc_strike_price_unit_id,
                    pc_error_code);
    if (pc_error_code = '-20001') then
      raise exception_input_missing;
    end if;
    if (pc_error_code = '-20002') then
      raise exception_month_not_setup;
    end if;
    if (pc_error_code = '-20003') then
      raise exception_month_not_tradable;
    end if;
    if (pc_error_code = '-20004') then
      raise exception_day_not_tradable;
    end if;
    if (pc_error_code = '-20005') then
      raise exception_day_is_holiday;
    end if;
    begin
      select count(*)
        into vn_cal_npd_count
        from npd_non_prompt_calendar_days npd
       where npd.prompt_delivery_calendar_id =
             cr_instrument_rec.delivery_calender_id
             and npd.is_deleted = 'N';
    exception
      when no_data_found then
        vn_cal_npd_count := 0;
      when others then
        vn_cal_npd_count := 0;
    end;
    if (pc_period_type = 'Day') then
      pc_prompt_date := pc_curr_date;
      if vn_cal_npd_count <> 0 then
        pc_prompt_date := fn_get_substitute_dt_for_npd(cr_instrument_rec.delivery_calender_id,
                                                       pc_prompt_date);
        pc_curr_date := pc_prompt_date;
      end if;
      pc_dr_id := f_get_existing_drid(pc_instrumentid,
                                      pc_price_point_id,
                                      --pc_curr_date,
                                      pc_prompt_date,
                                      null,
                                      null,
                                      pc_curr_start_date,
                                      pc_curr_end_date,
                                      pc_strike_price,
                                      pc_strike_price_unit_id);
    end if;
    if (pc_period_type = 'Month') then
      pc_prompt_date := f_get_prompt_date(pc_delivery_period_id,
                                          pc_curr_month,
                                          pc_curr_year,
                                          null,
                                          null);
      if vn_cal_npd_count <> 0 then
        pc_prompt_date := fn_get_substitute_dt_for_npd(cr_instrument_rec.delivery_calender_id,
                                                       pc_prompt_date);
      end if;
      pc_dr_id := f_get_existing_drid(pc_instrumentid,
                                      pc_price_point_id,
                                      null,
                                      pc_curr_month,
                                      pc_curr_year,
                                      pc_curr_start_date,
                                      pc_curr_end_date,
                                      pc_strike_price,
                                      pc_strike_price_unit_id);
    end if;
    if (pc_period_type = 'Week') then
      if cr_instrument_rec.instrument_type = 'Average' then
        pc_prompt_date := f_get_prompt_date(pc_delivery_period_id,
                                            null,
                                            null,
                                            pd_avg_wk_start_date,
                                            pd_avg_wk_end_date);
      else
        pc_prompt_date := f_get_prompt_date(pc_delivery_period_id,
                                            null,
                                            null,
                                            pc_curr_start_date,
                                            pc_curr_end_date);
      end if;
      --    Adding code to handle Non Prompt Day logic      ::2nd May 2013                              ..Raj
      if vn_cal_npd_count <> 0 then
        pc_prompt_date := fn_get_substitute_dt_for_npd(cr_instrument_rec.delivery_calender_id,
                                                       pc_prompt_date);
      end if;

      pc_dr_id := f_get_existing_drid(pc_instrumentid,
                                      pc_price_point_id,
                                      pc_prompt_date,
                                      null,
                                      null,
                                      pc_curr_start_date,
                                      pc_curr_end_date,
                                      pc_strike_price,
                                      pc_strike_price_unit_id);
    end if;
    if (pc_period_type in ('Quarter', 'Year') and
       pc_delivery_period_id is not null) then
      pc_prompt_date := f_get_prompt_date(pc_delivery_period_id,
                                          pc_curr_month,
                                          pc_curr_year,
                                          null,
                                          null);
      pc_dr_id       := f_get_existing_drid(pc_instrumentid,
                                            pc_price_point_id,
                                            pc_prompt_date,
                                            pc_curr_month,
                                            pc_curr_year,
                                            pc_curr_start_date,
                                            pc_curr_end_date,
                                            pc_strike_price,
                                            pc_strike_price_unit_id);
    end if;
    /* Generating DRID since it is returned NULL */
    if (pc_dr_id is null) then
      /* Generate DRID for the Delevery Period Passed */
      pc_dr_id := f_create_drid(pc_instrumentid,
                                pc_price_point_id,
                                pc_period_type_id,
                                cr_instrument_rec.delivery_calender_id,
                                pc_delivery_period_id,
                                pc_prompt_date,
                                pc_curr_date,
                                pc_curr_month,
                                pc_curr_year,
                                pc_curr_start_date,
                                pc_curr_end_date,
                                pc_strike_price,
                                pc_strike_price_unit_id,
                                pc_first_notice_date,
                                pc_last_notice_date,
                                pc_first_tradable_date,
                                pc_last_tradable_date,
                                pc_last_tradable_date);
    end if;
    return pc_dr_id;
    /* Catching Exceptions */
  exception
    when exception_input_missing then
      /* Closing the Instrument Cursor */
      p_close_instrument_cursor;
      /* Closing the Delivery Period Cursor */
      p_close_del_period_cursor;
      raise_application_error(-20001,
                              'Inputs missing to complete derivative processing');
    when exception_month_not_setup then
      /* Closing the Instrument Cursor */
      p_close_instrument_cursor;
      /* Closing the Delivery Period Cursor */
      p_close_del_period_cursor;
      raise_application_error(-20002,
                              'The selected month is not setup for this instrument');
    when exception_month_not_tradable then
      /* Closing the Instrument Cursor */
      p_close_instrument_cursor;
      /* Closing the Delivery Period Cursor */
      p_close_del_period_cursor;
      raise_application_error(-20003,
                              'The selected Month/Year is not tradable for this instrument');
    when exception_day_not_tradable then
      /* Closing the Instrument Cursor */
      p_close_instrument_cursor;
      /* Closing the Delivery Period Cursor */
      p_close_del_period_cursor;
      raise_application_error(-20004,
                              'The selected day is not tradable for this instrument');
    when exception_day_is_holiday then
      /* Closing the Instrument Cursor */
      p_close_instrument_cursor;
      /* Closing the Delivery Period Cursor */
      p_close_del_period_cursor;
      raise_application_error(-20005,
                              'The selected day is an exchange holiday');
    when others then
      /* Closing the Instrument Cursor */
      p_close_instrument_cursor;
      /* Closing the Delivery Period Cursor */
      p_close_del_period_cursor;
      raise_application_error(-20100,
                              'Error occured in pkg_drid_gen. Msg: ' ||
                              sqlerrm);
  end f_process_drid;

  ------------------------------------------------------------------------------
  /* Function used to generate DRIDs for Quotes */
  ------------------------------------------------------------------------------
  function f_generate_drid_for_quotes(pc_trade_date           in date,
                                      pc_instrumentid         in varchar2,
                                      pc_price_source_id      in varchar2,
                                      pc_strike_price         in number,
                                      pc_strike_price_unit_id in varchar2)
    return varchar2 is
    dridarray                  drid_varray := drid_varray();
    pc_prompt_del_id           varchar2(15);
    pc_start_date              date;
    pc_end_date                date;
    pc_period_from             number(10);
    pc_period_to               number(10);
    pc_equ_period_type         number(5);
    pc_pdc_period_type_id      varchar2(15);
    pc_month_prompt_start_date date;
    pc_varray_count            number(10);
    loop_index                 number(10);
    pc_quote_id                varchar2(15);
    pc_dr_id                   varchar2(15);
    pc_spot_frequency          varchar2(15);
    pc_price_point_type        varchar2(50);
    pc_price_point_applicable  char(1);
    vc_price_source_id         varchar2(15);
    vc_period_type_id          varchar2(15);
    vc_daily_valid_till        varchar2(100);
    vc_monthly_valid_till      varchar2(100);
    vc_weekly_valid_till       varchar2(100);
    vd_new_wk_startdate        date;
    vd_new_wk_enddate          date;
    vd_previous_prompt_date    date;
    vd_current_prompt_date     date;
    vn_prompt_count            number;
    vn_calender_npd_count      number;
    cursor cr_del_period_list is
      select dpd.delivery_period_id
        from dpd_delivery_period_definition dpd
       where dpd.instrument_id = pc_instrumentid
         and dpd.is_deleted = 'N'
         and dpd.is_active = 'Y';
    cursor cr_price_point_list is
      select dipp.price_point_id,
             pp.price_point_name,
             pp.forward_count,
             pp.forward_count_type_id,
             pp.display_order,
             pm.period_type_id,
             pm.period_type_name,
             pm.equivalent_days
        from dip_der_instrument_pricing   dip,
             dipp_der_ins_pricing_prpoint dipp,
             pp_price_point               pp,
             pm_period_master             pm
       where dip.instrument_id = pc_instrumentid
         and dip.price_source_id = vc_price_source_id
         and dip.price_point_type = 'PRICE_POINT'
         and dip.is_deleted = 'N'
         and dip.instrument_pricing_id = dipp.instrument_pricing_id
         and dipp.is_deleted = 'N'
         and dipp.price_point_id = pp.price_point_id
         and pp.is_active = 'Y'
         and pp.is_deleted = 'N'
         and pp.forward_count_type_id = pm.period_type_id
         and pm.is_deleted = 'N'
       order by pp.display_order desc;
    cursor cr_daily_prompt_rule is
      select dpc.*
        from dpc_daily_prompt_calendar dpc
       where dpc.prompt_delivery_calendar_id = pc_prompt_del_id
         and dpc.is_deleted = 'N';
    cursor cr_weekly_prompt_rule is
      select wpc.*
        from wpc_weekly_prompt_calendar wpc
       where wpc.prompt_delivery_calendar_id = pc_prompt_del_id
         and wpc.is_deleted = 'N';
    cursor cr_monthly_prompt_rule is
      select mpc.*
        from mpc_monthly_prompt_calendar mpc
       where mpc.prompt_delivery_calendar_id = pc_prompt_del_id
         and mpc.is_deleted = 'N';
    cursor cr_applicable_months is
      select mpcm.*
        from mpcm_monthly_prompt_cal_month mpcm,
             mnm_month_name_master         mnm
       where mpcm.prompt_delivery_calendar_id = pc_prompt_del_id
         and mpcm.applicable_month = mnm.month_name_id
         and mpcm.is_deleted = 'N'
         and mnm.is_deleted = 'N'
       order by mnm.display_order;
    cr_daily_prompt_rule_rec   cr_daily_prompt_rule%rowtype;
    cr_weekly_prompt_rule_rec  cr_weekly_prompt_rule%rowtype;
    cr_monthly_prompt_rule_rec cr_monthly_prompt_rule%rowtype;
  begin
    vn_calender_npd_count     := 0;
    pc_price_point_applicable := 'N';
    p_open_instrument_cursor(pc_instrumentid);
    --added by siva on 25-Apr-2011 for Quotes using price source and price points for LME
    --checking, given instument and price source input is applicable for Price Points or not
    vc_price_source_id := pc_price_source_id;
    begin
      if vc_price_source_id is null then
        pc_price_point_applicable := 'N';
      else
        select dip.price_point_type
          into pc_price_point_type
          from dip_der_instrument_pricing dip
         where dip.instrument_id = pc_instrumentid
           and dip.price_source_id = vc_price_source_id
           and dip.is_deleted = 'N';
        if pc_price_point_type = 'PRICE_POINT' then
          pc_price_point_applicable := 'Y';
        else
          pc_price_point_applicable := 'N';
        end if;
      end if;
    exception
      when no_data_found then
        pc_price_point_applicable := 'N';
      when others then
        pc_price_point_applicable := 'N';
    end;
    --Checking if the instrument is spot
    if (cr_instrument_rec.instrument_type = 'Spot') then
      begin
        select pm.period_type_name
          into pc_spot_frequency
          from pm_period_master pm
         where pm.period_type_id = cr_instrument_rec.spot_frequency
           and pm.is_deleted = 'N';
      end;
      pc_period_type := 'Day';
      if (pc_spot_frequency = 'Month') then
        pc_start_date := to_date(to_char((sysdate -
                                         to_char(pc_trade_date, 'dd') + 1),
                                         'dd-mon-yyyy'));
      else
        pc_start_date := pc_trade_date;
      end if;
      pc_start_date := f_get_next_tradable_day(pc_instrumentid,
                                               pc_start_date);
      pc_dr_id      := f_get_existing_drid(pc_instrumentid,
                                           null,
                                           pc_start_date,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null);
      if (pc_dr_id is null) then
        pc_dr_id := f_create_drid(pc_instrumentid,
                                  null,
                                  'PM-1',
                                  cr_instrument_rec.delivery_calender_id,
                                  null,
                                  pc_start_date,
                                  pc_start_date,
                                  null,
                                  null,
                                  null,
                                  null,
                                  null,
                                  null,
                                  null,
                                  null,
                                  null,
                                  null,
                                  last_day(pc_start_date)); --TODO
      end if;
      dridarray.extend();
      dridarray(dridarray.count) := pc_dr_id;
    else
      if pc_price_point_applicable = 'N' then
        if (cr_instrument_rec.is_manual_generate = 'Y') then
          /* Manual Generated DR ID*/
          --dbms_output.put_line('Quote Generation Starts for Manual ');
          for cr_del_period_list_rec in cr_del_period_list
          loop
            p_open_del_period_cursor(pc_instrumentid,
                                     cr_del_period_list_rec.delivery_period_id);
            pc_dr_id := f_get_drid(pc_trade_date,
                                   pc_instrumentid,
                                   null,
                                   cr_delivery_period_rec.delivery_period_id,
                                   cr_delivery_period_rec.period_type_id,
                                   cr_delivery_period_rec.period_date,
                                   cr_delivery_period_rec.period_month,
                                   cr_delivery_period_rec.period_year,
                                   cr_delivery_period_rec.period_start_date,
                                   cr_delivery_period_rec.period_end_date,
                                   pc_strike_price,
                                   pc_strike_price_unit_id,
                                   null,
                                   null);
            dridarray.extend();
            dridarray(dridarray.count) := pc_dr_id;
            p_close_del_period_cursor;
          end loop;
        else
          vc_weekly_valid_till := null;
          vn_prompt_count      := 0;

          /* Auto Generate DR ID*/
          --dbms_output.put_line('Quote Generation Starts for Automatic ');
          pc_month_prompt_start_date := pc_trade_date;
          if (cr_instrument_rec.is_daily_cal_applicable = 'Y') then
            --dbms_output.put_line('Generating Daily Quotes ');
            begin
              select pm.period_type_id
                into pc_pdc_period_type_id
                from pm_period_master pm
               where pm.period_type_name = 'Day'
                 and pm.is_deleted = 'N';
            end;
            pc_prompt_del_id := cr_instrument_rec.delivery_calender_id;
            begin
              select count(*)
                into vn_calender_npd_count
                from npd_non_prompt_calendar_days npd
               where npd.prompt_delivery_calendar_id = pc_prompt_del_id
               and npd.is_deleted = 'N';
            exception
              when no_data_found then
                vn_calender_npd_count := 0;
              when others then
                vn_calender_npd_count := 0;
            end;
            open cr_daily_prompt_rule;
            fetch cr_daily_prompt_rule
              into cr_daily_prompt_rule_rec;
            pc_period_from := cr_daily_prompt_rule_rec.period_from;
            pc_period_from := pc_period_from - 1;
            pc_period_to   := cr_daily_prompt_rule_rec.period_to;
            begin
              select pm.equivalent_days
                into pc_equ_period_type
                from pm_period_master pm
               where pm.period_type_id =
                     cr_daily_prompt_rule_rec.period_type_id
                 and pm.is_deleted = 'N';
            end;
            pc_start_date := pc_trade_date +
                             (pc_period_from * pc_equ_period_type);
            pc_end_date   := pc_trade_date +
                             (pc_period_to * pc_equ_period_type);
            if (cr_daily_prompt_rule_rec.valid_till =
               'LAST DAY OF THE MONTH') then
              pc_end_date := last_day(pc_end_date);
            end if;
            vc_daily_valid_till := cr_daily_prompt_rule_rec.valid_till;
            if vn_calender_npd_count = 0 then
              pc_start_date := f_get_next_tradable_day(pc_instrumentid,
                                                       pc_start_date);
              pc_end_date   := f_get_next_tradable_day(pc_instrumentid,
                                                       pc_end_date);
            else
              --   Adding code to handle Non Prompt Day(NPD) logic         ::2nd May 2013                  --Raj
              loop
                pc_start_date := f_get_next_tradable_day(pc_instrumentid,
                                                         pc_start_date);
                exit when not fn_is_npd(pc_instrumentid, pc_start_date);
                pc_start_date := pc_start_date + 1;
              end loop;
              pc_end_date := f_get_next_tradable_day(pc_instrumentid,
                                                     pc_end_date);
              for rc in (select npcd.substitute_day
                           from dim_der_instrument_master    dim,
                                npd_non_prompt_calendar_days npcd
                          where dim.instrument_id = pc_instrumentid
                            and dim.delivery_calender_id =
                                npcd.prompt_delivery_calendar_id
                            and npcd.non_prompt_day >= pc_start_date
                            and npcd.non_prompt_day <= pc_end_date
                            and npcd.substitute_day > pc_end_date
                            and dim.is_deleted = 'N'
                            and npcd.is_deleted = 'N')
              loop
                pc_dr_id := f_get_drid(pc_trade_date,
                                       pc_instrumentid,
                                       null,
                                       null,
                                       pc_pdc_period_type_id,
                                       rc.substitute_day,
                                       null,
                                       null,
                                       null,
                                       null,
                                       pc_strike_price,
                                       pc_strike_price_unit_id,
                                       null,
                                       null);
                dridarray.extend();
                dridarray(dridarray.count) := pc_dr_id;
              end loop;
            end if;
            --           End of code on 2nd May 2013

            while (pc_start_date <= pc_end_date)
            loop
              pc_dr_id := f_get_drid(pc_trade_date,
                                     pc_instrumentid,
                                     null,
                                     null,
                                     pc_pdc_period_type_id,
                                     pc_start_date,
                                     null,
                                     null,
                                     null,
                                     null,
                                     pc_strike_price,
                                     pc_strike_price_unit_id,
                                     null,
                                     null);
              dridarray.extend();
              dridarray(dridarray.count) := pc_dr_id;
              if vn_calender_npd_count = 0 then
                pc_start_date := pc_start_date + 1;
                pc_start_date := f_get_next_tradable_day(pc_instrumentid,
                                                         pc_start_date);
              else
                loop
                  pc_start_date := pc_start_date + 1;
                  pc_start_date := f_get_next_tradable_day(pc_instrumentid,
                                                           pc_start_date);
                  exit when not fn_is_npd(pc_instrumentid, pc_start_date);
                end loop;
              end if;
            end loop;
            -- added to avoid overlap the prompt date in the screen -- siva on 28-Sep-2012
            select drm.prompt_date
              into vd_previous_prompt_date
              from drm_derivative_master drm
             where drm.dr_id = pc_dr_id;
            -- ends here
            pc_month_prompt_start_date := pc_end_date;
            close cr_daily_prompt_rule;
          end if;
          if (cr_instrument_rec.is_weekly_cal_applicable = 'Y') then
            --dbms_output.put_line('Generating Weekly Quotes ');
            begin
              select pm.period_type_id
                into pc_pdc_period_type_id
                from pm_period_master pm
               where pm.period_type_name = 'Week'
                 and pm.is_deleted = 'N';
            end;
            pc_prompt_del_id := cr_instrument_rec.delivery_calender_id;
            open cr_weekly_prompt_rule;
            fetch cr_weekly_prompt_rule
              into cr_weekly_prompt_rule_rec;
            pc_period_from := cr_weekly_prompt_rule_rec.period_from;
            pc_period_to   := cr_weekly_prompt_rule_rec.period_to;
            begin
              select pm.equivalent_days
                into pc_equ_period_type
                from pm_period_master pm
               where pm.period_type_id =
                     cr_weekly_prompt_rule_rec.period_type_id
                 and pm.is_deleted = 'N';
            end;

            --            Added to avoid overlap the prompt date in the screen    ::2nd May 2013          ..Raj
            if vd_previous_prompt_date is not null then
              pc_start_date := pc_start_date + 1;
            else
              pc_start_date := pc_trade_date +
                               (pc_period_from * pc_equ_period_type);
            end if;
            --            pc_start_date := pc_trade_date +
            --                             (pc_period_from * pc_equ_period_type);
            pc_end_date := pc_trade_date +
                           (pc_period_to * pc_equ_period_type);
            if (cr_weekly_prompt_rule_rec.valid_till =
               'LAST DAY OF THE MONTH') then
              pc_end_date := last_day(pc_end_date);
            end if;
            vc_weekly_valid_till := cr_weekly_prompt_rule_rec.valid_till;
            while (pc_start_date <= pc_end_date)
            loop
              -- vd_new_wk_startdate,vd_new_wk_enddate
              select trunc((pc_start_date), 'IW') - 1,
                     next_day(trunc((pc_start_date), 'IW'), 'SATURDAY')
                into vd_new_wk_startdate,
                     vd_new_wk_enddate
                from dual;

              pc_dr_id := f_get_drid(pc_trade_date,
                                     pc_instrumentid,
                                     null,
                                     null,
                                     pc_pdc_period_type_id,
                                     null,
                                     null,
                                     null,
                                     vd_new_wk_startdate,
                                     vd_new_wk_enddate,
                                     pc_strike_price,
                                     pc_strike_price_unit_id,
                                     null,
                                     null);

              -- added to avoid overlap the prompt date in the screen -- siva on 28-Sep-2012
              vn_prompt_count := vn_prompt_count + 1;
              if vn_prompt_count = 1 then
                select drm.prompt_date
                  into vd_current_prompt_date
                  from drm_derivative_master drm
                 where drm.dr_id = pc_dr_id;
                if vd_previous_prompt_date is not null and
                   vd_current_prompt_date > vd_previous_prompt_date then
                  dridarray.extend();
                  dridarray(dridarray.count) := pc_dr_id;
                end if;
              else
                -- ends here
                dridarray.extend();
                dridarray(dridarray.count) := pc_dr_id;
              end if;
              pc_start_date := pc_start_date + 7;
            end loop;
            select drm.prompt_date
              into vd_previous_prompt_date
              from drm_derivative_master drm
             where drm.dr_id = pc_dr_id;
            vn_prompt_count            := 0;
            pc_month_prompt_start_date := pc_end_date;
            close cr_weekly_prompt_rule;
          end if;
          if (cr_instrument_rec.is_monthly_cal_applicable = 'Y') then
            --dbms_output.put_line('Generating Monthly Quotes ');
            begin
              select pm.period_type_id
                into pc_pdc_period_type_id
                from pm_period_master pm
               where pm.period_type_name = 'Month'
                 and pm.is_deleted = 'N';
            end;
            pc_prompt_del_id := cr_instrument_rec.delivery_calender_id;
            open cr_monthly_prompt_rule;
            fetch cr_monthly_prompt_rule
              into cr_monthly_prompt_rule_rec;
            pc_period_to := cr_monthly_prompt_rule_rec.period_for;
            begin
              select pm.equivalent_days
                into pc_equ_period_type
                from pm_period_master pm
               where pm.period_type_id =
                     cr_monthly_prompt_rule_rec.period_type_id
                 and pm.is_deleted = 'N';
            end;
            if vc_weekly_valid_till is not null and
               vc_weekly_valid_till = 'LAST DAY OF THE MONTH' then
              pc_month_prompt_start_date := pc_month_prompt_start_date + 1;
            end if;
            pc_start_date := pc_month_prompt_start_date;
            pc_end_date   := pc_month_prompt_start_date +
                             (pc_period_to * pc_equ_period_type);
            for cr_applicable_months_rec in cr_applicable_months
            loop
              pc_month_prompt_start_date := to_date(('01-' ||
                                                    cr_applicable_months_rec.applicable_month || '-' ||
                                                    to_char(pc_start_date,
                                                             'YYYY')),
                                                    'dd/mm/yyyy');
              loop
                if (pc_month_prompt_start_date >=
                   to_date(('01-' || to_char(pc_start_date, 'Mon-YYYY')),
                            'dd/mm/yyyy') and
                   pc_month_prompt_start_date <= pc_end_date) then
                  pc_dr_id := f_get_drid(pc_trade_date,
                                         pc_instrumentid,
                                         null,
                                         null,
                                         pc_pdc_period_type_id,
                                         null,
                                         to_char(pc_month_prompt_start_date,
                                                 'Mon'),
                                         to_char(pc_month_prompt_start_date,
                                                 'YYYY'),
                                         null,
                                         null,
                                         pc_strike_price,
                                         pc_strike_price_unit_id,
                                         null,
                                         null);
                  -- added to avoid overlap the prompt date in the screen -- siva on 28-Sep-2012
                  vn_prompt_count := vn_prompt_count + 1;
                  if vn_prompt_count = 1 then
                    select drm.prompt_date
                      into vd_current_prompt_date
                      from drm_derivative_master drm
                     where drm.dr_id = pc_dr_id;
                    if vd_previous_prompt_date is not null and
                       vd_current_prompt_date > vd_previous_prompt_date then
                      dridarray.extend();
                      dridarray(dridarray.count) := pc_dr_id;
                    end if;
                    --   dbms_output.put_line('After month vd_previous_prompt_date '||vd_previous_prompt_date || 'vd_current_prompt_date '||vd_current_prompt_date);
                  else
                    -- ends here
                    dridarray.extend();
                    dridarray(dridarray.count) := pc_dr_id;
                  end if;
                end if;
                pc_month_prompt_start_date := add_months(pc_month_prompt_start_date,
                                                         12);
                exit when pc_month_prompt_start_date > pc_end_date;
              end loop;
              vn_prompt_count := 0;
            end loop;
            close cr_monthly_prompt_rule;
          end if;
        end if;
      else
        --Generage DRID using price points, for price points day,month, weeks are not applicable,
        -- these are just point(text), we no need to generate promt date for this.
        --quotes has to be entered every day using old DRID's which created at first time
        for cr_pp in cr_price_point_list
        loop
          pc_start_date := pc_trade_date;
          begin
            select pm.period_type_name,
                   pm.period_type_id
              into pc_period_type,
                   vc_period_type_id
              from pm_period_master pm
             where upper(pm.period_type_name) = 'CUSTOM'
               and pm.is_active = 'Y'
               and pm.is_deleted = 'N';
          exception
            when no_data_found then
              pc_period_type    := 'Custom';
              vc_period_type_id := 'PM-6';
          end;
          if pc_period_type = 'Custom' then
            pc_start_date := pc_trade_date;
            pc_start_date := f_get_next_tradable_day(pc_instrumentid,
                                                     pc_start_date);
            pc_dr_id      := f_get_existing_drid(pc_instrumentid,
                                                 cr_pp.price_point_id,
                                                 pc_start_date,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null);
            if (pc_dr_id is null) then
              pc_dr_id := f_create_drid(pc_instrumentid,
                                        cr_pp.price_point_id,
                                        vc_period_type_id,
                                        cr_instrument_rec.delivery_calender_id,
                                        null,
                                        pc_start_date,
                                        pc_start_date,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        last_day(pc_start_date)); --TODO
            end if;
            dridarray.extend();
            dridarray(dridarray.count) := pc_dr_id;
          end if;
          if pc_period_type = 'Day' then
            pc_start_date := pc_trade_date +
                             (cr_pp.forward_count * cr_pp.equivalent_days);
            pc_start_date := f_get_next_tradable_day(pc_instrumentid,
                                                     pc_start_date);
            pc_dr_id      := f_get_existing_drid(pc_instrumentid,
                                                 cr_pp.price_point_id,
                                                 pc_start_date,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null);
            if (pc_dr_id is null) then
              pc_dr_id := f_create_drid(pc_instrumentid,
                                        cr_pp.price_point_id,
                                        'PM-1',
                                        cr_instrument_rec.delivery_calender_id,
                                        null,
                                        pc_start_date,
                                        pc_start_date,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        last_day(pc_start_date)); --TODO
            end if;
            dridarray.extend();
            dridarray(dridarray.count) := pc_dr_id;
          end if;
          if pc_period_type = 'Month' then
            pc_pdc_period_type_id := cr_pp.period_type_id;
            pc_prompt_del_id      := cr_instrument_rec.delivery_calender_id;
            pc_start_date         := pc_trade_date + (cr_pp.forward_count *
                                     cr_pp.equivalent_days);
            pc_end_date           := pc_start_date;
            pc_dr_id              := f_get_drid(pc_trade_date,
                                                pc_instrumentid,
                                                cr_pp.price_point_id,
                                                null,
                                                pc_pdc_period_type_id,
                                                null,
                                                to_char(pc_start_date, 'Mon'),
                                                to_char(pc_start_date,
                                                        'YYYY'),
                                                null,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null);
            dridarray.extend();
            dridarray(dridarray.count) := pc_dr_id;
          end if;
        end loop;
      end if;
    end if;
    p_close_instrument_cursor;
    /* Inserting to the Quotes Table */
    delete x_quotes_drid;
    select seq_quote_drid.nextval into pc_quote_id from dual;
    pc_quote_id := 'DQ-DR-' || pc_quote_id;
    dbms_output.put_line('pc_quote_id ' || pc_quote_id);
    pc_varray_count := dridarray.count;
    loop_index      := 0;
    while (loop_index < pc_varray_count)
    loop
      loop_index := loop_index + 1;
      dridarray.extend();
      pc_dr_id := dridarray(loop_index);
      dbms_output.put_line('DrID Array for ' || loop_index || ': ' ||
                           pc_dr_id);
      insert into x_quotes_drid
      values
        (pc_quote_id, pc_dr_id, systimestamp);
    end loop;
    return pc_quote_id;
  end f_generate_drid_for_quotes;

  ------------------------------------------------------------------------------
  /* Private Function used to create the DR-ID */
  ------------------------------------------------------------------------------
  function f_create_drid(pc_instrument_id               in varchar2,
                         pc_price_point_id              in varchar2,
                         pc_period_type_id              in varchar2,
                         pc_prompt_delivery_calendar_id in varchar2,
                         pc_delivery_period_id          in varchar2,
                         pc_prompt_date                 in date,
                         pc_period_date                 in date,
                         pc_period_month                in varchar2,
                         pc_period_year                 in number,
                         pc_period_start_date           in date,
                         pc_period_end_date             in date,
                         pc_strike_price                in number,
                         pc_strike_price_unit_id        in varchar2,
                         pc_first_notice_date           in date,
                         pc_last_notice_date            in date,
                         pc_first_tradable_date         in date,
                         pc_last_tradable_date          in date,
                         pc_expiry_date                 in date)
    return varchar2 is
    pc_drid_name        varchar2(30);
    pc_drid             varchar2(15);
    pc_drid_seq         varchar2(15);
    pc_price_point_name varchar2(50);
  begin
    /* Generate DRID */
    select seq_drm.nextval into pc_drid_seq from dual;
    pc_drid := 'DR-' || pc_drid_seq;
    /* Get price point name */
    begin
      select pp.price_point_name
        into pc_price_point_name
        from pp_price_point pp
       where pp.price_point_id = pc_price_point_id
         and pp.is_deleted = 'N';
    exception
      when no_data_found then
        pc_price_point_name := '';
      when others then
        pc_price_point_name := '';
    end;
    if (pc_delivery_period_id is null) then
      if (pc_period_type = 'Day') then
        pc_drid_name := to_char(pc_period_date, 'dd-Mon-YYYY');
      end if;
      if (pc_period_type = 'Month') then
        pc_drid_name := pc_period_month || '-' || pc_period_year;
      end if;
      if (pc_period_type = 'Year') then
        pc_drid_name := pc_period_year;
      end if;
      if (pc_period_type = 'Week' or pc_period_type = 'Quarter' or
         pc_period_type = 'Season' or pc_period_type = 'Custom' or
         pc_period_type = 'Average') then
        pc_drid_name := to_char(pc_prompt_date, 'dd-Mon-YYYY');
      end if;
      if pc_price_point_id is not null and pc_period_type = 'Custom' then
        pc_drid_name := pc_price_point_name;
      else
        pc_drid_name := pc_drid_name;
      end if;
    else
      pc_drid_name := cr_delivery_period_rec.delivery_period_name;
    end if;
    insert into drm_derivative_master
      (dr_id,
       dr_id_name,
       instrument_id,
       price_point_id,
       period_type_id,
       prompt_delivery_calendar_id,
       delivery_period_id,
       prompt_date,
       period_date,
       period_month,
       period_year,
       period_start_date,
       period_end_date,
       strike_price,
       strike_price_unit_id,
       first_notice_date,
       last_notice_date,
       first_tradable_date,
       last_tradable_date,
       expiry_date,
       created_date,
       is_expired,
       is_deleted)
    values
      (pc_drid,
       pc_drid_name,
       pc_instrument_id,
       pc_price_point_id,
       pc_period_type_id,
       pc_prompt_delivery_calendar_id,
       pc_delivery_period_id,
       pc_prompt_date,
       pc_period_date,
       pc_period_month,
       pc_period_year,
       pc_period_start_date,
       pc_period_end_date,
       pc_strike_price,
       pc_strike_price_unit_id,
       pc_first_notice_date,
       pc_last_notice_date,
       pc_first_tradable_date,
       pc_last_tradable_date,
       pc_expiry_date,
       systimestamp,
       'N',
       'N');
    return pc_drid;
  end f_create_drid;

  ------------------------------------------------------------------------------
  /* Private Function used to get existing DR-ID for a given Period Type */
  ------------------------------------------------------------------------------
  function f_get_existing_drid(pc_instrument_id        in varchar2,
                               pc_price_point_id       in varchar2,
                               pc_date                 in date,
                               pc_period_month         in varchar2,
                               pc_period_year          in number,
                               pc_start_date           in date,
                               pc_end_date             in date,
                               pc_strike_price         in number,
                               pc_strike_price_unit_id in varchar2)
    return varchar2 is
    pc_drid varchar2(15);
  begin
    if cr_instrument_rec.instrument_type = 'Average' then
      if (pc_period_type = 'Day') then
        begin
          select drm.dr_id
            into pc_drid
            from drm_derivative_master drm,
                 pm_period_master      pm
           where drm.instrument_id = pc_instrument_id
             and drm.period_type_id = pm.period_type_id
             and pm.period_type_name = pc_period_type
             and drm.price_point_id = pc_price_point_id
             and drm.period_start_date = pc_start_date
             and drm.period_end_date = pc_end_date
             and drm.period_date = pc_date
             and drm.is_deleted = 'N'
             and pm.is_deleted = 'N';
        exception
          when no_data_found then
            pc_drid := null;
        end;
      end if;
      if (pc_period_type = 'Month') then
        begin
          select drm.dr_id
            into pc_drid
            from drm_derivative_master drm,
                 pm_period_master      pm
           where drm.instrument_id = pc_instrument_id
             and drm.period_type_id = pm.period_type_id
             and pm.period_type_name = pc_period_type
             and drm.price_point_id = pc_price_point_id
             and drm.period_start_date = pc_start_date
             and drm.period_end_date = pc_end_date
             and drm.period_month = pc_period_month
             and drm.period_year = pc_period_year
             and drm.is_deleted = 'N'
             and pm.is_deleted = 'N';
        exception
          when no_data_found then
            pc_drid := null;
        end;
      end if;
      if (pc_period_type = 'Week') then
        begin
          select drm.dr_id
            into pc_drid
            from drm_derivative_master drm,
                 pm_period_master      pm
           where drm.instrument_id = pc_instrument_id
             and drm.period_type_id = pm.period_type_id
             and pm.period_type_name = pc_period_type
             and drm.period_start_date = pc_start_date
             and drm.period_end_date = pc_end_date
             and drm.price_point_id = pc_price_point_id
             and drm.prompt_date = pc_date
             and drm.is_deleted = 'N'
             and pm.is_deleted = 'N';
        exception
          when no_data_found then
            pc_drid := null;
        end;
      end if;
    elsif cr_instrument_rec.instrument_type in
          ('Option Put', 'Option Call') then
      if (pc_period_type = 'Day') then

        if (pc_strike_price_unit_id is null or
           pc_strike_price_unit_id <> '') then
          begin
            select drm.dr_id
              into pc_drid
              from drm_derivative_master drm,
                   pm_period_master      pm
             where drm.instrument_id = pc_instrument_id
               and drm.period_type_id = pm.period_type_id
               and pm.period_type_name = pc_period_type
               and drm.price_point_id is null
               and drm.strike_price = pc_strike_price
               and drm.period_date = pc_date
               and drm.is_deleted = 'N'
               and pm.is_deleted = 'N';
          exception
            when no_data_found then
              pc_drid := null;
          end;
        else
          begin
            select drm.dr_id
              into pc_drid
              from drm_derivative_master drm,
                   pm_period_master      pm
             where drm.instrument_id = pc_instrument_id
               and drm.period_type_id = pm.period_type_id
               and pm.period_type_name = pc_period_type
               and drm.price_point_id is null
               and drm.strike_price = pc_strike_price
               and drm.strike_price_unit_id = pc_strike_price_unit_id
               and drm.period_date = pc_date
               and drm.is_deleted = 'N'
               and pm.is_deleted = 'N';
          exception
            when no_data_found then
              pc_drid := null;
          end;
        end if;
      end if;
      if (pc_period_type = 'Month') then
        begin
          select drm.dr_id
            into pc_drid
            from drm_derivative_master drm,
                 pm_period_master      pm
           where drm.instrument_id = pc_instrument_id
             and drm.period_type_id = pm.period_type_id
             and pm.period_type_name = pc_period_type
             and drm.price_point_id is null
             and drm.strike_price = pc_strike_price
             and drm.strike_price_unit_id = pc_strike_price_unit_id
             and drm.period_month = pc_period_month
             and drm.period_year = pc_period_year
             and drm.is_deleted = 'N'
             and pm.is_deleted = 'N';
        exception
          when no_data_found then
            pc_drid := null;
        end;
      end if;
      if (pc_period_type = 'Week') then
        begin
          select drm.dr_id
            into pc_drid
            from drm_derivative_master drm,
                 pm_period_master      pm
           where drm.instrument_id = pc_instrument_id
             and drm.period_type_id = pm.period_type_id
             and pm.period_type_name = pc_period_type
             and drm.strike_price = pc_strike_price
             and drm.strike_price_unit_id = pc_strike_price_unit_id
             and drm.price_point_id is null
             and drm.prompt_date = pc_date
             and drm.is_deleted = 'N'
             and pm.is_deleted = 'N';
        exception
          when no_data_found then
            pc_drid := null;
        end;
      end if;
    else
      if pc_price_point_id is null then
        if (pc_period_type = 'Day') then
          begin
            select drm.dr_id
              into pc_drid
              from drm_derivative_master drm,
                   pm_period_master      pm
             where drm.instrument_id = pc_instrument_id
               and drm.period_type_id = pm.period_type_id
               and pm.period_type_name = pc_period_type
               and drm.price_point_id is null
               and drm.period_date = pc_date
               and drm.is_deleted = 'N'
               and pm.is_deleted = 'N';
          exception
            when no_data_found then
              pc_drid := null;
          end;
        end if;
        if (pc_period_type = 'Month') then
          begin
            select drm.dr_id
              into pc_drid
              from drm_derivative_master drm,
                   pm_period_master      pm
             where drm.instrument_id = pc_instrument_id
               and drm.period_type_id = pm.period_type_id
               and pm.period_type_name = pc_period_type
               and drm.price_point_id is null
               and drm.period_month = pc_period_month
               and drm.period_year = pc_period_year
               and drm.is_deleted = 'N'
               and pm.is_deleted = 'N';
          exception
            when no_data_found then
              pc_drid := null;
          end;
        end if;
        if (pc_period_type = 'Week') then
          begin
            select drm.dr_id
              into pc_drid
              from drm_derivative_master drm,
                   pm_period_master      pm
             where drm.instrument_id = pc_instrument_id
               and drm.period_type_id = pm.period_type_id
               and pm.period_type_name = pc_period_type
               and drm.price_point_id is null
               and drm.prompt_date = pc_date
               and drm.is_deleted = 'N'
               and pm.is_deleted = 'N';
          exception
            when no_data_found then
              pc_drid := null;
          end;
        end if;
        -- Quarter,Year added for the manual generated DRID,s not for the auto
        if (pc_period_type = 'Quarter') then
          begin
            select drm.dr_id
              into pc_drid
              from drm_derivative_master drm,
                   pm_period_master      pm
             where drm.instrument_id = pc_instrument_id
               and drm.period_type_id = pm.period_type_id
               and pm.period_type_name = pc_period_type
               and drm.price_point_id is null
               and drm.prompt_date = pc_date
               and drm.is_deleted = 'N'
               and pm.is_deleted = 'N';
          exception
            when no_data_found then
              pc_drid := null;
          end;
        end if;
        if (pc_period_type = 'Year') then
          begin
            select drm.dr_id
              into pc_drid
              from drm_derivative_master drm,
                   pm_period_master      pm
             where drm.instrument_id = pc_instrument_id
               and drm.period_type_id = pm.period_type_id
               and pm.period_type_name = pc_period_type
               and drm.price_point_id is null
               and drm.prompt_date = pc_date
               and drm.is_deleted = 'N'
               and pm.is_deleted = 'N';
          exception
            when no_data_found then
              pc_drid := null;
          end;
        end if;
      else
        -- get DRID using price points
        begin
          select drm.dr_id
            into pc_drid
            from drm_derivative_master drm
           where drm.instrument_id = pc_instrument_id -- this instumnet should be future only
             and drm.price_point_id = pc_price_point_id
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            pc_drid := null;
        end;
        -- end if;
      end if;
    end if;
    return pc_drid;
  end f_get_existing_drid;

  function f_get_prompt_date(pc_delivery_period_id in varchar2,
                             pc_month              in varchar2,
                             pc_year               in number,
                             pc_start_date         in date,
                             pc_end_date           in date) return date is
    pc_prompt_date      date;
    pc_day_of_the_month number(2);
    pc_day_order        varchar2(15);
    pc_prompt_day       varchar2(15);
    pc_month_year       varchar2(15);
    pc_day_order_number number(1);
    workings_days       number;
    pd_date             date;
  begin
    if (pc_delivery_period_id is not null) then
      if (cr_instrument_rec.prompt_date_defn = 'First Notice Date' or
         cr_instrument_rec.prompt_date_defn = 'First_Notice_Date') then
        pc_prompt_date := cr_delivery_period_rec.first_notice_date +
                          nvl(cr_instrument_rec.prompt_days, 0);
      end if;
      if (cr_instrument_rec.prompt_date_defn = 'Last Notice Date' or
         cr_instrument_rec.prompt_date_defn = 'Last_Notice_Date') then
        pc_prompt_date := cr_delivery_period_rec.last_notice_date +
                          nvl(cr_instrument_rec.prompt_days, 0);
      end if;
      if (cr_instrument_rec.prompt_date_defn = 'Last Trading Date' or
         cr_instrument_rec.prompt_date_defn = 'Last_Trading_Date') then
        pc_prompt_date := cr_delivery_period_rec.last_trading_date +
                          nvl(cr_instrument_rec.prompt_days, 0);
      end if;
    else
      if (pc_period_type = 'Month') then
        begin
          pc_month_year := '01-' || pc_month || '-' || pc_year;
          pd_date       := pc_month_year;
          select mpc.day_of_the_month,
                 mpc.day_order,
                 mpc.prompt_day
            into pc_day_of_the_month,
                 pc_day_order,
                 pc_prompt_day
            from mpc_monthly_prompt_calendar mpc
           where mpc.prompt_delivery_calendar_id =
                 cr_instrument_rec.delivery_calender_id
             and mpc.is_deleted = 'N';

          if (pc_day_of_the_month is not null) then
            begin
              select to_date(pc_month_year, 'dd-Mon-YYYY') +
                     (pc_day_of_the_month - 1)
                into pc_prompt_date
                from dual;
            end;
          else
            if pc_prompt_day <> 'BD' then
              if (pc_day_order = 'First') then
                pc_day_order_number := 1;
              end if;
              if (pc_day_order = 'Second') then
                pc_day_order_number := 2;
              end if;
              if (pc_day_order = 'Third') then
                pc_day_order_number := 3;
              end if;
              if (pc_day_order = 'Fourth') then
                pc_day_order_number := 4;
              end if;
              select f_get_next_day(to_date(pc_month_year, 'dd-Mon-YYYY'),
                                    upper(substr(pc_prompt_day, 1, 3)),
                                    pc_day_order_number)
                into pc_prompt_date
                from dual;
            else

              if (pc_day_order = 'First') then
                pc_day_order_number := 1;
              end if;
              if (pc_day_order = 'Second') then
                pc_day_order_number := 2;
              end if;
              if (pc_day_order = 'Third') then
                pc_day_order_number := 3;
              end if;
              if (pc_day_order = 'Fourth') then
                pc_day_order_number := 4;
              end if;
              if (pc_day_order_number <= 4) then
                workings_days := 0;
                while workings_days <> pc_day_order_number
                loop
                  if f_is_day_holiday(cr_instrument_rec.instrument_id,
                                      pd_date) then
                    pd_date := pd_date + 1;
                  else
                    workings_days := workings_days + 1;
                    if workings_days <> pc_day_order_number then
                      pd_date := pd_date + 1;
                    end if;
                  end if;
                end loop;
                pc_prompt_date := pd_date;
              end if;

              if (pc_day_order = 'Last') then
                pd_date := last_day(pd_date);
                while true
                loop
                  if f_is_day_holiday(cr_instrument_rec.instrument_id,
                                      pd_date) then
                    pd_date := pd_date - 1;
                  else
                    exit;
                  end if;
                end loop;
                pc_prompt_date := pd_date;
              else
                pd_date := last_day(pd_date);
                while true
                loop
                  if f_is_day_holiday(cr_instrument_rec.instrument_id,
                                      pd_date) then
                    pd_date := pd_date - 1;
                  else
                    exit;
                  end if;
                end loop;
                pc_prompt_date := pd_date;
              end if;

            end if;

          end if;
        end;
      end if;

      if (pc_period_type = 'Week') then
        begin
          select wpc.prompt_day
            into pc_prompt_day
            from wpc_weekly_prompt_calendar wpc
           where wpc.prompt_delivery_calendar_id =
                 cr_instrument_rec.delivery_calender_id
             and wpc.is_deleted = 'N';
          pc_day_order_number := 1;
          loop
            select f_get_next_day(pc_start_date,
                                  upper(substr(pc_prompt_day, 1, 3)),
                                  pc_day_order_number)
              into pc_prompt_date
              from dual;
            if (pc_prompt_date >= pc_start_date and
               pc_prompt_date <= pc_end_date) then
              pc_day_order_number := -1;
            else
              if (pc_day_order_number = 5) then
                pc_day_order_number := -1;
              else
                pc_day_order_number := pc_day_order_number + 1;
              end if;
            end if;
            exit when pc_day_order_number < 0;
          end loop;
        end;
      end if;
    end if;

    pc_prompt_date := f_get_next_tradable_day(cr_instrument_rec.instrument_id,
                                              pc_prompt_date);

    /*--    Adding code to handle Non Prompt Day logic      ::2nd May 2013                              ..Raj
    if pc_period_type = 'Week' then
      pc_prompt_date := f_get_next_tradable_day(cr_instrument_rec.instrument_id,
                                                pc_prompt_date);
      pc_prompt_date := fn_get_substitute_dt_for_npd(cr_instrument_rec.delivery_calender_id,
                                                     pc_prompt_date);
    else
      pc_prompt_date := f_get_next_tradable_day(cr_instrument_rec.instrument_id,
                                                pc_prompt_date);
    end if;*/
    --    End of code on 2nd May 2013

    return pc_prompt_date;
  end f_get_prompt_date;

  ------------------------------------------------------------------------------
  /* Private Procedure used to validate the inputs */
  ------------------------------------------------------------------------------
  procedure p_validate_data(pc_trade_date           in date,
                            pc_instrumentid         in varchar2,
                            pc_price_point_id       in varchar2,
                            pc_delivery_period_id   in varchar2,
                            pc_period_type_id       in varchar2,
                            pc_date                 in date,
                            pc_month                in varchar2,
                            pc_year                 in number,
                            pc_start_date           in date,
                            pc_end_date             in date,
                            pc_strike_price         in number,
                            pc_strike_price_unit_id in varchar2,
                            pc_error_code           out varchar2) is
    --Variables
    pc_day_difference number(10);
    pc_app_month      varchar2(10);
    pc_month_year     varchar2(30);
  begin
    /* Validating Inputs */
    if (pc_trade_date is null or pc_instrumentid is null or
       pc_period_type_id is null) then
      pc_error_code := '-20001';
      return;
    end if;
    if (f_is_day_holiday(pc_instrumentid, pc_trade_date)) then
      pc_error_code := '-20005';
      return;
    end if;
    if (pc_period_type = 'Day') then
      if (pc_delivery_period_id is null and pc_date is null) then
        pc_error_code := '-20001';
        return;
      end if;
      /*begin
        select pc_date -
               (pc_trade_date + dpc.period_to)
          into pc_day_difference
          from dpc_daily_prompt_calendar dpc,
               dim_der_instrument_master dim
         where dpc.prompt_delivery_calendar_id = dim.delivery_calender_id
           and dim.instrument_id = pc_instrumentid
           and dpc.is_deleted = 'N'
           and dim.is_deleted = 'N';
        if (pc_day_difference > 0) then
          pc_error_code := '-20004';
          return;
        end if;
      end;*/
    end if;
    if (pc_period_type = 'Month') then
      if (pc_delivery_period_id is null and
         (pc_month is null or pc_year is null)) then
        pc_error_code := '-20001';
        return;
      end if;
      /* Checking if the month is valid */
      begin
        select mpcm.applicable_month
          into pc_app_month
          from mpcm_monthly_prompt_cal_month mpcm,
               dim_der_instrument_master     dim
         where mpcm.prompt_delivery_calendar_id = dim.delivery_calender_id
           and dim.instrument_id = pc_instrumentid
           and mpcm.applicable_month = pc_month
           and mpcm.is_deleted = 'N'
           and dim.is_deleted = 'N';
      exception
        when no_data_found then
          pc_error_code := '-20002';
          return;
      end;
      begin
        pc_month_year := '01-' || pc_month || '-' || pc_year;
        --dbms_output.put_line('pc_month_year : ' || pc_month_year);
        select to_date(pc_month_year, 'dd-Mon-YYYY') -
               add_months(pc_trade_date, mpc.period_for)
          into pc_day_difference
          from mpc_monthly_prompt_calendar mpc,
               dim_der_instrument_master   dim
         where mpc.prompt_delivery_calendar_id = dim.delivery_calender_id
           and dim.instrument_id = pc_instrumentid
           and mpc.is_deleted = 'N'
           and dim.is_deleted = 'N';
        if (pc_day_difference > 0) then
          --TODO Checking forward count when called from Quotes
          -- RAISE exception_month_not_tradable;
          pc_month_year := '01-' || pc_month || '-' || pc_year;
        end if;
      end;
    end if;
    if cr_instrument_rec.instrument_type in ('Option Put', 'Option Call') then
      if (pc_strike_price is null) then
        pc_error_code := '-20001';
        return;
      end if;
    end if;
  exception
    when others then
      /* Closing the Instrument Cursor */
      p_close_instrument_cursor;
      /* Closing the Delivery Period Cursor */
      p_close_del_period_cursor;
      raise_application_error(-20099,
                              'Error occured in pkg_drid_gen. Msg: ' ||
                              sqlerrm);
  end p_validate_data;

  ------------------------------------------------------------------------------
  /*   Private function to check if a date is holiday */
  ------------------------------------------------------------------------------
  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean is
    pc_counter number(1);
    result_val boolean;
  begin
    --Checking the Week End Holiday List
    begin
      select count(*)
        into pc_counter
        from dual
       where to_char(pc_trade_date, 'Dy') in
             (select clwh.holiday
                from dim_der_instrument_master    dim,
                     clm_calendar_master          clm,
                     clwh_calendar_weekly_holiday clwh
               where dim.holiday_calender_id = clm.calendar_id
                 and clm.calendar_id = clwh.calendar_id
                 and dim.instrument_id = pc_instrumentid
                 and clm.is_deleted = 'N'
                 and clwh.is_deleted = 'N'
                 and dim.is_deleted = 'N');
      if (pc_counter = 1) then
        result_val := true;
      else
        result_val := false;
      end if;
      if (result_val = false) then
        --Checking Other Holiday List
        select count(*)
          into pc_counter
          from dual
         where trim(pc_trade_date) in
               (select trim(hl.holiday_date)
                  from hm_holiday_master         hm,
                       hl_holiday_list           hl,
                       dim_der_instrument_master dim,
                       clm_calendar_master       clm
                 where hm.holiday_id = hl.holiday_id
                   and dim.holiday_calender_id = clm.calendar_id
                   and clm.calendar_id = hm.calendar_id
                   and dim.instrument_id = pc_instrumentid
                   and hm.is_deleted = 'N'
                   and hl.is_deleted = 'N'
                   and dim.is_deleted = 'N'
                   and clm.is_deleted = 'N');
        if (pc_counter = 1) then
          result_val := true;
        else
          result_val := false;
        end if;
      end if;
    end;
    return result_val;
  end f_is_day_holiday;

  ------------------------------------------------------------------------------
  /* Private function to return a tradable day for a given date */
  ------------------------------------------------------------------------------
  function f_get_next_tradable_day(pc_instrumentid in varchar2,
                                   pc_date         date) return date is
    pc_next_tradable_day date;
    is_valid_date        boolean := true;
  begin
    pc_next_tradable_day := pc_date;
    if (f_is_day_holiday(pc_instrumentid, pc_date)) then
      while (is_valid_date = true)
      loop
        pc_next_tradable_day := pc_next_tradable_day + 1;
        if (f_is_day_holiday(pc_instrumentid, pc_next_tradable_day)) then
          is_valid_date := true;
        else
          is_valid_date := false;
        end if;
      end loop;
    end if;
    return pc_next_tradable_day;
  end f_get_next_tradable_day;

  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  function f_get_next_day(p_date     in date,
                          p_day      in varchar2,
                          p_position in number) return date is
    v_position_date      date;
    v_next_position      number;
    v_start_day          varchar2(10);
    v_first_day_position date;
  begin
    begin
      v_next_position := (p_position - 1) * 7;
      v_start_day     := to_char(to_date('01-' ||
                                         to_char(trunc(p_date), 'mon-yyyy'),
                                         'dd-mon-yyyy'),
                                 'dy');
      if upper(trim(v_start_day)) = upper(trim(p_day)) then
        v_first_day_position := to_date('01-' ||
                                        to_char(trunc(p_date), 'mon-yyyy'),
                                        'dd-mon-yyyy');
      else
        v_first_day_position := next_day(to_date('01-' ||
                                                 to_char(p_date, 'mon-yyyy'),
                                                 'dd-mon-yyyy'),
                                         trim(p_day));
      end if;
      if v_next_position <= 1 then
        v_position_date := trunc(v_first_day_position);
      else
        v_position_date := trunc(v_first_day_position) + v_next_position;
      end if;
    exception
      when no_data_found then
        return null;
      when others then
        return null;
    end;
    return v_position_date;
  end f_get_next_day;

  ------------------------------------------------------------------------------
  /* Private Procedure to Open Instrument Cursor */
  ------------------------------------------------------------------------------
  procedure p_open_instrument_cursor(pc_instrumentid in varchar2) is
  begin
    if not cr_instrument%isopen then
      pc_instr_id := pc_instrumentid;
      open cr_instrument;
      fetch cr_instrument
        into cr_instrument_rec;
    end if;
  end p_open_instrument_cursor;

  ------------------------------------------------------------------------------
  /* Private Procedure to Close Instrument Cursor */
  ------------------------------------------------------------------------------
  procedure p_close_instrument_cursor is
  begin
    if cr_instrument%isopen then
      close cr_instrument;
    end if;
  end p_close_instrument_cursor;

  ------------------------------------------------------------------------------
  /* Private Procedure to Open Delivery Period Cursor */
  ------------------------------------------------------------------------------
  procedure p_open_del_period_cursor(pc_instrumentid       in varchar2,
                                     pc_delivery_period_id in varchar2) is
  begin
    if not cr_delivery_period%isopen then
      pc_instr_id      := pc_instrumentid;
      pc_del_period_id := pc_delivery_period_id;
      open cr_delivery_period;
      fetch cr_delivery_period
        into cr_delivery_period_rec;
    end if;
  end p_open_del_period_cursor;

  ------------------------------------------------------------------------------
  /* Private Procedure to Close Delivery Period Cursor */
  ------------------------------------------------------------------------------
  procedure p_close_del_period_cursor is
  begin
    if cr_delivery_period%isopen then
      close cr_delivery_period;
    end if;
  end p_close_del_period_cursor;

  --
  function fn_get_child_drid(pc_drid                    in varchar2,
                             pc_underlying_instrumentid in varchar2,
                             pc_und_delivery_period_id  in varchar2,
                             pd_avg_wk_start_date       in date,
                             pd_avg_wk_end_date         in date)
    return varchar2 is
    vc_drid               varchar2(15);
    vc_child_drid         varchar2(15);
    vc_month              varchar2(5);
    vn_year               number;
    vc_period_type_id     varchar2(30);
    vc_calendar_id        varchar2(15);
    vd_und_prompt_date    date;
    vf_child_drid         varchar2(10) := 'Y';
    vc_delivery_period_id varchar2(15);
  begin
    --dbms_output.put_line('fn_get_child_drid generation process starting...');
    vc_drid               := pc_drid;
    vc_delivery_period_id := pc_und_delivery_period_id;
    begin
      --Checking if the child dr id already exist
      select du.underlying_dr_id
        into vc_child_drid
        from du_derivative_underlying du
       where du.dr_id = vc_drid; --options/average drid
    exception
      when no_data_found then
        vf_child_drid := 'N';
    end;
    if vf_child_drid = 'N' then
      select nvl(drm.period_month, to_char(drm.prompt_date, 'Mon')),
             nvl(drm.period_year, to_char(drm.prompt_date, 'yyyy')),
             drm.prompt_delivery_calendar_id,
             drm.prompt_date,
             pm.period_type_id,
             pm.period_type_name
        into vc_month,
             vn_year,
             vc_calendar_id,
             vd_und_prompt_date,
             vc_period_type_id,
             pc_period_type
        from drm_derivative_master drm,
             pm_period_master      pm
       where drm.dr_id = vc_drid
         and drm.period_type_id = pm.period_type_id
         and drm.is_deleted = 'N'
         and pm.is_deleted = 'N';
      if pc_period_type = 'Day' then
        vc_month := null;
        vn_year  := null;
      end if;
      /* Opening the Instrument Cursor */
      p_open_instrument_cursor(pc_underlying_instrumentid);
      /* Opening the Delivery Period Cursor */
      p_open_del_period_cursor(pc_underlying_instrumentid,
                               vc_delivery_period_id);
      /** Process DR-ID **/
      vc_child_drid := f_process_drid(vd_und_prompt_date,
                                      pc_underlying_instrumentid,
                                      null,
                                      vc_delivery_period_id,
                                      vc_period_type_id,
                                      vd_und_prompt_date,
                                      vc_month,
                                      vn_year,
                                      pd_avg_wk_start_date,
                                      pd_avg_wk_end_date,
                                      null,
                                      null,
                                      null,
                                      null);
      /* Closing the Instrument Cursor */
      p_close_instrument_cursor;
      /* Closing the Delivery Period Cursor */
      p_close_del_period_cursor;
      if pc_drid is not null and vc_child_drid is not null then
        begin
          insert into du_derivative_underlying
            (dr_id, underlying_dr_id)
          values
            (vc_drid, vc_child_drid);
        end;
      end if;
    end if;
    -- end;
    --dbms_output.put_line('f_get_child_drId generation process ending...' || vc_child_drid);
    return vc_child_drid;
  end fn_get_child_drid;
  function fn_is_date(vc_datetext in varchar2) return number is
    v_date1 date;
  begin
    select to_date(vc_datetext) into v_date1 from dual;
    return 1;
  exception
    when others then
      return 0;
  end fn_is_date;
  function f_get_drid_for_import(pc_instrument_id    in varchar2,
                                 pd_trade_date       in date,
                                 pc_prompt_date_name in varchar2)
    return varchar2 is
    --  pd_trade_date    date;
    --  pc_instrument_id varchar2(50);

    cursor cr_instruments is
      select dim.instrument_id,
             dim.instrument_name,
             dim.is_manual_generate,
             dim.delivery_calender_id,
             pdc.is_weekly_cal_applicable,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from dim_der_instrument_master    dim,
             pdd_product_derivative_def   pdd,
             emt_exchangemaster           emt,
             pdc_prompt_delivery_calendar pdc,
             irm_instrument_type_master   irm
       where irm.instrument_type = 'Future'
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id
         and dim.is_deleted = 'N'
         and pdd.is_deleted = 'N'
         and emt.is_deleted = 'N'
         and pdc.prompt_delivery_calendar_id = dim.delivery_calender_id
         and dim.instrument_type_id = irm.instrument_type_id
         and dim.instrument_id = pc_instrument_id;

    cursor cr_daily_prompt_rule(vc_prompt_del_id varchar2) is
      select dpc.*
        from dpc_daily_prompt_calendar dpc
       where dpc.prompt_delivery_calendar_id = vc_prompt_del_id
         and dpc.is_deleted = 'N';

    cursor cr_weekly_prompt_rule(vc_prompt_del_id varchar2) is
      select wpc.*
        from wpc_weekly_prompt_calendar wpc
       where wpc.prompt_delivery_calendar_id = vc_prompt_del_id
         and wpc.is_deleted = 'N';

    cursor cr_monthly_prompt_rule(vc_prompt_del_id varchar2) is
      select mpc.prompt_delivery_calendar_id,
             mpc.period_for,
             mpc.period_type_id,
             mpc.prompt_day,
             decode(mpc.day_order,
                    'First',
                    1,
                    'Second',
                    2,
                    'Third',
                    3,
                    'Fourth',
                    4,
                    5) day_order
        from mpc_monthly_prompt_calendar mpc
       where mpc.prompt_delivery_calendar_id = vc_prompt_del_id
         and mpc.is_deleted = 'N';
    cr_daily_prompt_rule_rec   cr_daily_prompt_rule%rowtype;
    cr_weekly_prompt_rule_rec  cr_weekly_prompt_rule%rowtype;
    cr_monthly_prompt_rule_rec cr_monthly_prompt_rule%rowtype;
    vd_prompt_date             date;
    vc_instrument_id           varchar2(15);
    pd_month_prompt_start_date date;
    vc_pdc_period_type_id      varchar2(15);
    vc_prompt_del_id           varchar2(15);
    vn_period_from             varchar2(15);
    vn_period_to               varchar2(15);
    vn_equ_period_type         varchar2(15);
    pd_start_date              date;
    pd_end_date                date;
    vn_day_order               number;
    vc_day                     varchar2(15);
  --  vd_date                    date;
    --vd_week_end_date           date;
  --  vd_daily_end_date          date;
    vd_valid_trade_date        date;
    --  pc_prompt_date_name        varchar2(50);
    vc_drid           varchar2(50);
    vc_flag_dwm_prmot varchar2(20);

  begin
    --pc_prompt_date_name := '18-Apr-2012';
    --  pc_instrument_id    := 'DIM-53';
    --  pd_trade_date       := to_date('03-Jan-2012', 'dd-Mon-yyyy');
    for cr_instrument_rec in cr_instruments
    loop
      vc_instrument_id           := cr_instrument_rec.instrument_id;
      vd_valid_trade_date        := pd_trade_date;
      pd_month_prompt_start_date := vd_valid_trade_date;
      vc_prompt_del_id           := cr_instrument_rec.delivery_calender_id;
      vc_flag_dwm_prmot          := '';
--      dbms_output.put_line('Instrument name : ' ||  cr_instrument_rec.instrument_name);
   --   dbms_output.put_line('Trade Date : ' || vd_valid_trade_date);
      if cr_instrument_rec.is_manual_generate = 'Y' then
        begin
          select drm.dr_id
            into vc_drid
            from drm_derivative_master drm
           where drm.instrument_id = vc_instrument_id
             and drm.dr_id_name = pc_prompt_date_name
             and drm.is_deleted = 'N'
             and rownum <= 1;
        exception
          when no_data_found then
            vc_drid := null;
          when others then
            vc_drid := null;
        end;
      else
        if fn_is_date(pc_prompt_date_name) = 0 then
          -- ie: for month prompt or other prompt name use drid_name to get the promt id
          -- not a date input, use dr_id name to get the drid
          begin
            select drm.dr_id,drm.prompt_date
              into vc_drid,vd_prompt_date
              from drm_derivative_master drm
             where drm.instrument_id = vc_instrument_id
               and drm.dr_id_name = pc_prompt_date_name
               and drm.is_deleted = 'N'
               and rownum <= 1;
          exception
            when no_data_found then
              vc_drid := null;
              vd_prompt_date := null;
            when others then
              vc_drid := null;
              vd_prompt_date := null;
          end;
     --     dbms_output.put_line('Month prompt passed : vc_drid is : ' || vc_drid || ' prompt dt is: ' ||vd_prompt_date);          
        else
        -- valid promot date passed to
          vd_prompt_date := to_date(pc_prompt_date_name, 'dd-Mon-yyyy');
          vc_drid := null;
      --    dbms_output.put_line('Inside valid prompt, prompt date is :  ' || vd_prompt_date || ' drid is null '||vc_drid);
        end if;
        if vd_prompt_date is not null then
          -- valid promot date passed to ;;
       --   vd_prompt_date := to_date(pc_prompt_date_name, 'dd-Mon-yyyy');
--          dbms_output.put_line('Inside valid prompt check, prompt date is :  ' ||        vd_prompt_date);
          if (cr_instrument_rec.is_daily_cal_applicable = 'Y') then
            begin
              select pm.period_type_id
                into vc_pdc_period_type_id
                from pm_period_master pm
               where pm.period_type_name = 'Day'
                 and pm.is_deleted = 'N';
            end;
            open cr_daily_prompt_rule(vc_prompt_del_id);
            fetch cr_daily_prompt_rule
              into cr_daily_prompt_rule_rec;
            vn_period_from := cr_daily_prompt_rule_rec.period_from;
            vn_period_from := vn_period_from - 1;
            vn_period_to   := cr_daily_prompt_rule_rec.period_to;
            begin
              select pm.equivalent_days
                into vn_equ_period_type
                from pm_period_master pm
               where pm.period_type_id =
                     cr_daily_prompt_rule_rec.period_type_id
                 and pm.is_deleted = 'N';
            end;
            pd_start_date := vd_valid_trade_date +
                             (vn_period_from * vn_equ_period_type);
            pd_end_date   := vd_valid_trade_date +
                             (vn_period_to * vn_equ_period_type);
            if (cr_daily_prompt_rule_rec.valid_till =
               'LAST DAY OF THE MONTH') then
              pd_end_date := last_day(pd_end_date);
            end if;
            pd_start_date := f_get_next_tradable_day(vc_instrument_id,
                                                                        pd_start_date);
            pd_end_date   := f_get_next_tradable_day(vc_instrument_id,
                                                                        pd_end_date);

            pd_month_prompt_start_date := pd_end_date;
            close cr_daily_prompt_rule;
--            dbms_output.put_line('Daily Start/end date : ' ||  pd_start_date || '  ::  ' || pd_end_date);
            if vd_prompt_date >= pd_start_date and
               vd_prompt_date <= pd_end_date then
              vc_flag_dwm_prmot := 'Day';
            end if;
          end if;
          if (cr_instrument_rec.is_weekly_cal_applicable = 'Y') then
            begin
              select pm.period_type_id
                into vc_pdc_period_type_id
                from pm_period_master pm
               where pm.period_type_name = 'Week'
                 and pm.is_deleted = 'N';
            end;
            vc_prompt_del_id := cr_instrument_rec.delivery_calender_id;
            open cr_weekly_prompt_rule(vc_prompt_del_id);
            fetch cr_weekly_prompt_rule
              into cr_weekly_prompt_rule_rec;
            vn_period_from := cr_weekly_prompt_rule_rec.period_from;
            vn_period_to   := cr_weekly_prompt_rule_rec.period_to;
            begin
              select pm.equivalent_days
                into vn_equ_period_type
                from pm_period_master pm
               where pm.period_type_id =
                     cr_weekly_prompt_rule_rec.period_type_id
                 and pm.is_deleted = 'N';
            end;
            pd_start_date := vd_valid_trade_date +
                             (vn_period_from * vn_equ_period_type);
            pd_end_date   := vd_valid_trade_date +
                             (vn_period_to * vn_equ_period_type);
            if (cr_weekly_prompt_rule_rec.valid_till =
               'LAST DAY OF THE MONTH') then
              pd_end_date := last_day(pd_end_date);
            end if;
            close cr_weekly_prompt_rule;
--            dbms_output.put_line('weekly Start/end date : ' || pd_month_prompt_start_date || '  ::  ' || pd_end_date);
            if vd_prompt_date > pd_month_prompt_start_date and
               vd_prompt_date <= pd_end_date then
              vc_flag_dwm_prmot := 'Week';
            end if;
            pd_month_prompt_start_date := pd_end_date;
            dbms_output.put_line(vc_flag_dwm_prmot);
          end if;
          if (cr_instrument_rec.is_monthly_cal_applicable = 'Y') then

            select pm.period_type_id
              into vc_pdc_period_type_id
              from pm_period_master pm
             where pm.period_type_name = 'Month'
               and pm.is_deleted = 'N';
            vc_prompt_del_id := cr_instrument_rec.delivery_calender_id;
            open cr_monthly_prompt_rule(vc_prompt_del_id);
            fetch cr_monthly_prompt_rule
              into cr_monthly_prompt_rule_rec;
            vc_day       := cr_monthly_prompt_rule_rec.prompt_day; -- What day of week
            vn_day_order := cr_monthly_prompt_rule_rec.day_order; -- Which order of week day
            vn_period_to := cr_monthly_prompt_rule_rec.period_for;
            begin
              select pm.equivalent_days
                into vn_equ_period_type
                from pm_period_master pm
               where pm.period_type_id =
                     cr_monthly_prompt_rule_rec.period_type_id
                 and pm.is_deleted = 'N';
            end;
            pd_start_date := pd_month_prompt_start_date;
            pd_end_date   := pd_month_prompt_start_date +
                             (vn_period_to * vn_equ_period_type);
--            dbms_output.put_line('Monthly Start/end date : ' || pd_start_date || '  ::  ' || pd_end_date);
            if vd_prompt_date > pd_start_date and
               vd_prompt_date <= pd_end_date then
              vc_flag_dwm_prmot := 'Month';
            end if;

          end if;
          close cr_monthly_prompt_rule;
          --- get the DRID based on the above flag
--          dbms_output.put_line('Inside valid prompt check, prompt date is :  ' || vd_prompt_date || ' vc_pdc_period_type_id ' ||
--                               vc_pdc_period_type_id ||  ' vc_instrument_id ' || vc_instrument_id);
          begin
            select drm.dr_id
              into vc_drid
              from drm_derivative_master drm,
                   pm_period_master      pm
             where drm.instrument_id = vc_instrument_id
               and drm.prompt_date = vd_prompt_date
               and drm.period_type_id = pm.period_type_id
               and pm.period_type_name = vc_flag_dwm_prmot
               and drm.is_deleted = 'N'
               and rownum <= 1;
          exception
            when no_data_found then
              vc_drid := null;
            when others then
              vc_drid := null;
          end;
        end if; -- pkg_drid_generator.fn_is_date if check ends here
      end if; -- cr_instrument_rec.is_manual_generate check ends here
    end loop;
 --   dbms_output.put_line('DRID Type : ' || vc_flag_dwm_prmot);
  --  dbms_output.put_line('DRID :=' || vc_drid);
    return vc_drid;
  end f_get_drid_for_import;
  function fn_is_npd(pc_instrumentid in varchar2, pc_date date)
    return boolean is
    /*
    Function returns TRUE if passed date for the instrument is a Non Prompt date otherwise returns FALSE
    */
    lv_result char := 'N';
  begin
    select 'Y'
      into lv_result
      from dim_der_instrument_master    dim,
           npd_non_prompt_calendar_days npcd
     where dim.instrument_id = pc_instrumentid
       and dim.delivery_calender_id = npcd.prompt_delivery_calendar_id
       and npcd.non_prompt_day = pc_date
       and dim.is_deleted = 'N'
       and npcd.is_deleted = 'N';
    if lv_result = 'Y' then
      return true;
    else
      return false;
    end if;
  exception
    when others then
      --If no data exists for the given date and instrument that means it is a valid prompt date.
      return false;
  end fn_is_npd;

  function fn_get_substitute_dt_for_npd(pc_del_calendar_id varchar2,
                                        pc_date            date) return date is
    /*
    Function returns substitute date if exists for give date and calendar id otherwise returns same date which has been passed if
    passed date was not a NPD
    */
    pd_date date;
  begin
    select npd.substitute_day
      into pd_date
      from npd_non_prompt_calendar_days npd
     where npd.prompt_delivery_calendar_id = pc_del_calendar_id
       and non_prompt_day = pc_date
       and is_deleted = 'N';
    return pd_date;
  exception
    when others then
      return pc_date;
  end fn_get_substitute_dt_for_npd;
  function f_is_pp_holiday(pc_instrumentid   in varchar2,
                           pc_price_point_id in varchar2,
                           pc_trade_date     date) return boolean is
    pc_counter number(1);
    result_val boolean;
  begin
    --Checking Price Point Holiday List
    select count(*)
      into pc_counter
      from dual
     where trim(pc_trade_date) in
           (select trim(ppha.holiday_date)
              from dim_der_instrument_master  dim,
                   dip_der_instrument_pricing dip,
                   ppha_pp_holiday_applicable ppha
             where dim.instrument_id = pc_instrumentid
               and dim.instrument_id = dip.instrument_id
               and dip.is_pp_holiday_applicable = 'Y'
               and dip.is_deleted = 'N'
               and dip.instrument_pricing_id = ppha.instrument_pricing_id
               and ppha.price_point_id = pc_price_point_id
               and ppha.is_deleted = 'N');
    if (pc_counter = 1) then
      result_val := true;
    else
      result_val := false;
    end if;
    return result_val;
  end f_is_pp_holiday;
end pkg_drid_generator; 
/
