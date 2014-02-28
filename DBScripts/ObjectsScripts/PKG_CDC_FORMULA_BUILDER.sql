create or replace package "PKG_CDC_FORMULA_BUILDER" is
  procedure sp_calculate_price(pobj_in_fb_setup            in fb_tbl_setup,
                               pobj_in_fb_instrument_data  in fb_tbl_instrument_data,
                               pobj_out_fb_setup           out fb_tbl_setup,
                               pobj_out_fb_instrument_data out fb_tbl_instrument_data,
                               pobj_out_fb_tbl_error       out fb_tbl_error);
  procedure sp_calculate_price_event(pobj_in_fb_setup            in fb_tbl_setup,
                                     pobj_in_fb_instrument_data  in fb_tbl_instrument_data,
                                     pobj_out_fb_setup           out fb_tbl_setup,
                                     pobj_out_fb_instrument_data out fb_tbl_instrument_data,
                                     pobj_out_fb_tbl_error       out fb_tbl_error,
                                     pd_event_date               in date,
                                     pn_event_before_days        in number,
                                     pn_include_exclude_event    in number,
                                     pn_event_after_days         in number);
  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;
  function f_is_pp_holiday(pc_instrumentid   in varchar2,
                           pc_price_point_id in varchar2,
                           pc_trade_date     date) return boolean;
  procedure sp_calculate_forumla(pobj_fb_setup                in fb_tbl_setup,
                                 pobj_fb_instrument_data      in fb_tbl_instrument_data,
                                 pc_fb_log_id                 out varchar2,
                                 pobj_out_fb_setup            out fb_tbl_setup,
                                 pobj_out_fb_instrument_data  out fb_tbl_instrument_data,
                                 pobj_out_fb_price_by_formula out tp_tbl_formula,
                                 pobj_out_fb_tbl_error        out fb_tbl_error,
                                 pd_event_date                date,
                                 pn_event_before_days         number,
                                 pn_include_exclude_event     number,
                                 pn_event_after_days          number,
                                 pc_is_event_process          varchar2);
  procedure sp_insert_fb_log(pobj_fb_tbl_log in fb_tbl_error);
  procedure sp_insert_fb_data(pobj_in_fb_setup           in fb_tbl_setup,
                              pobj_in_fb_instrument_data in fb_tbl_instrument_data,
                              pc_fb_log_id               in varchar2);
  procedure sp_insert_fbpl_data_by_formula(pobj_fb_formula in tp_tbl_formula,
                                           pc_fb_log_id    in varchar2);
  function f_get_converted_price(p_corporate_id       in varchar2,
                                 p_price              in number,
                                 p_from_price_unit_id in varchar2,
                                 p_to_price_unit_id   in varchar2,
                                 p_trade_date         in date) return number;
  function f_get_converted_currency_amt(pc_corporate_id        in varchar2,
                                        pc_from_cur_id         in varchar2,
                                        pc_to_cur_id           in varchar2,
                                        pd_cur_date            in date,
                                        pn_amt_to_be_converted in number)
    return number;
  function fn_get_drid_name(pc_drid in varchar2) return varchar2;
  function fn_get_substitute_dt_for_npd(pc_del_calendar_id varchar2,
                                        pd_date            date) return date;  
function fn_get_substitute_inst_npd(pc_instrumentid   in varchar2,
                                        pd_date            date) return date;                                         
end; 
/
create or replace package body "PKG_CDC_FORMULA_BUILDER" is
  procedure sp_calculate_price
  /**************************************************************************************************
    function name                       : sp_calculate_price
    author                              : siva
    created date                        : 05th dec 2010
    purpose                             : to provide the price to formula builder in cdc module
    parameters                          :
    modification history
    modified date  :
    modified by  :
    modify description :
    assumptions
    ***************************************************************************************************/
  (pobj_in_fb_setup            in fb_tbl_setup,
   pobj_in_fb_instrument_data  in fb_tbl_instrument_data,
   pobj_out_fb_setup           out fb_tbl_setup,
   pobj_out_fb_instrument_data out fb_tbl_instrument_data,
   pobj_out_fb_tbl_error       out fb_tbl_error) is
    vlt_fb_setup      fb_tbl_setup;
    vlt_fb_instrument fb_tbl_instrument_data;
    vlt_fb_tbl_error  fb_tbl_error;
    pobj_out_formula  tp_tbl_formula;
    vc_log_id         varchar2(30);
    vn_error_count    number;
    -- vn_count          number := 1;
    -- pk column of transaction table to be excluded
  begin
    --  Settlement
    sp_calculate_forumla(pobj_in_fb_setup,
                         pobj_in_fb_instrument_data,
                         vc_log_id,
                         vlt_fb_setup,
                         vlt_fb_instrument,
                         pobj_out_formula,
                         vlt_fb_tbl_error,
                         null,
                         0,
                         0,
                         0,
                         'N');
    begin
      select count(*)
        into vn_error_count
        from fbpl_formula_builder_price_log
       where fbpl_id = vc_log_id
         and error_type = 'Error';
    exception
      when no_data_found then
        vn_error_count := 0;
      when others then
        vn_error_count := 1;
    end;
    if vn_error_count <> 0 then
      vlt_fb_setup(1).fb_price := 0;
      vlt_fb_setup(1).fb_price_staus := 'Error';
    end if;
    pobj_out_fb_setup           := vlt_fb_setup;
    pobj_out_fb_instrument_data := vlt_fb_instrument;
    pobj_out_fb_tbl_error       := vlt_fb_tbl_error;
    --call fb log data
    dbms_output.put_line('vc_log_id ' || vc_log_id);
    sp_insert_fb_data(pobj_out_fb_setup,
                      pobj_out_fb_instrument_data,
                      vc_log_id);
    sp_insert_fbpl_data_by_formula(pobj_out_formula, vc_log_id);
  exception
    when others then
      raise_application_error(-20003,
                              'Error occured in pkg_cdc_formula_builder.sp_calculate_price ' ||
                              sqlerrm);
  end;
  procedure sp_calculate_price_event
  /**************************************************************************************************
    function name                       : sp_calculate_price
    author                              : siva
    created date                        : 05th dec 2010
    purpose                             : to provide the price to formula builder in cdc module
    parameters                          :
    modification history
    modified date  :
    modified by  :
    modify description :
    assumptions
    ***************************************************************************************************/
  (pobj_in_fb_setup            in fb_tbl_setup,
   pobj_in_fb_instrument_data  in fb_tbl_instrument_data,
   pobj_out_fb_setup           out fb_tbl_setup,
   pobj_out_fb_instrument_data out fb_tbl_instrument_data,
   pobj_out_fb_tbl_error       out fb_tbl_error,
   pd_event_date               in date,
   pn_event_before_days        in number,
   pn_include_exclude_event    in number,
   pn_event_after_days         in number) is
    vlt_fb_setup      fb_tbl_setup;
    vlt_fb_instrument fb_tbl_instrument_data;
    vlt_fb_tbl_error  fb_tbl_error;
    pobj_out_formula  tp_tbl_formula;
    vc_log_id         varchar2(30);
    vn_error_count    number;
    -- vn_count          number := 1;
    -- pk column of transaction table to be excluded
  begin
    --  Settlement
    sp_calculate_forumla(pobj_in_fb_setup,
                         pobj_in_fb_instrument_data,
                         vc_log_id,
                         vlt_fb_setup,
                         vlt_fb_instrument,
                         pobj_out_formula,
                         vlt_fb_tbl_error,
                         pd_event_date,
                         pn_event_before_days,
                         pn_include_exclude_event,
                         pn_event_after_days,
                         'Y');
    begin
      select count(*)
        into vn_error_count
        from fbpl_formula_builder_price_log
       where fbpl_id = vc_log_id
         and error_type = 'Error';
    exception
      when no_data_found then
        vn_error_count := 0;
      when others then
        vn_error_count := 1;
    end;
    if vn_error_count <> 0 then
      vlt_fb_setup(1).fb_price := 0;
      vlt_fb_setup(1).fb_price_staus := 'Error';
    end if;
    pobj_out_fb_setup           := vlt_fb_setup;
    pobj_out_fb_instrument_data := vlt_fb_instrument;
    pobj_out_fb_tbl_error       := vlt_fb_tbl_error;
    --call fb log data
    sp_insert_fb_data(pobj_out_fb_setup,
                      pobj_out_fb_instrument_data,
                      vc_log_id);
    sp_insert_fbpl_data_by_formula(pobj_out_formula, vc_log_id);
  exception
    when others then
      raise_application_error(-20003,
                              'Error occured in pkg_cdc_formula_builder.sp_calculate_price ' ||
                              sqlerrm);
  end;
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
                 and clwh.is_deleted = 'N');
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
                   and hl.is_deleted = 'N');
        if (pc_counter = 1) then
          result_val := true;
        else
          result_val := false;
        end if;
      end if;
    end;
    return result_val;
  end f_is_day_holiday;
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
  procedure sp_calculate_forumla(pobj_fb_setup                fb_tbl_setup,
                                 pobj_fb_instrument_data      fb_tbl_instrument_data,
                                 pc_fb_log_id                 out varchar2,
                                 pobj_out_fb_setup            out fb_tbl_setup,
                                 pobj_out_fb_instrument_data  out fb_tbl_instrument_data,
                                 pobj_out_fb_price_by_formula out tp_tbl_formula,
                                 pobj_out_fb_tbl_error        out fb_tbl_error,
                                 pd_event_date                date,
                                 pn_event_before_days         number,
                                 pn_include_exclude_event     number,
                                 pn_event_after_days          number,
                                 pc_is_event_process          varchar2) as  
    cursor cur_setup is
      select tt.formula_id,
             tt.corporate_id,
             tt.formula_name,
             tt.formula_display,
             tt.formula_internal,
             tt.price_unit_id,
             tt.trade_date,
             (case
               when pum1.price_unit_name is not null then
                pum1.price_unit_name
               else
                pum.price_unit_name
             end) price_unit_name,
             (case
               when pum1.price_unit_name is not null then
                pum1.cur_id
               else
                pum.cur_id
             end) cur_id,
             (case
               when pum1.price_unit_name is not null then
                pum1.weight
               else
                pum.weight
             end) weight,
             (case
               when pum1.price_unit_name is not null then
                pum1.weight_unit_id
               else
                pum.weight_unit_id
             end) weight_unit_id
        from (select formula_id,
                     corporate_id,
                     formula_name,
                     formula_display,
                     formula_internal,
                     price_unit_id,
                     trade_date,
                     fb_price,
                     fb_price_staus,
                     fb_price_qp_status,
                     fb_price_log_id
                from the (select cast(pobj_fb_setup as fb_tbl_setup)
                            from dual)) tt,
             v_ppu_pum pum,
             pum_price_unit_master pum1
       where tt.price_unit_id = pum.product_price_unit_id(+)
         and tt.price_unit_id = pum1.price_unit_id(+);  
    cursor cur_instrument is
      select tt.fb_order_seq,
             tt.formula_id,
             tt.instrument_id orginal_instrument_id,
             (case
               when upper(irm.instrument_type) = 'SPOT' then
                dim.m2m_instrument_id
               else
                tt.instrument_id
             end) instrument_id,
             (case
               when upper(irm.instrument_type) = 'AVERAGE' then
                dim.underlying_instrument_id
             end) underlying_instrument_id,
             (case
               when upper(irm.instrument_type) = 'SPOT' then
                dim.delivery_calender_id
                when upper(irm.instrument_type) = 'AVERAGE' then
                dim_und.delivery_calender_id
               else
                dim.delivery_calender_id
             end)delivery_calender_id,
             tt.price_source_id,
             tt.price_point_id,
             tt.available_price_id,
             tt.fb_period_type,
             tt.fb_period_sub_type,
             tt.period_month,
             tt.period_year,
             tt.period_from_date,
             tt.period_to_date,
             tt.no_of_months,
             tt.no_of_days,
             tt.period_type_id,
             tt.delivery_period_id,
             tt.off_day_price,
             nvl(tt.basis, 0) basis,
             tt.basis_price_unit_id,
             nvl(tt.fx_rate_type, 'Fixed') fx_rate_type,
             nvl(tt.fx_rate, 1) fx_rate,
             dim.instrument_name,
             irm.instrument_type,
             dim_und.instrument_name underlying_instrument_name,
             ps.price_source_name,
             ps.price_source_long_name,
             pp.price_point_name,
             apm.available_price_name,
             apm.available_price_display_name,
             (case
               when pum.price_unit_id is null and
                    pum_ins.price_unit_id is null then
                (case
               when upper(irm.instrument_type) in ('SPOT', 'AVERAGE') then
                div_und.price_unit_id
               else
                div_dim.price_unit_id
             end) when pum.price_unit_id is null and pum_ins.price_unit_id is not null then pum_ins.price_unit_id else pum.price_unit_id end) quotes_price_unit_id,
             nvl(pum.price_unit_name, pum_ins.price_unit_name) price_unit_name,
             pum.cur_id,
             pum.weight,
             pum.weight_unit_id,
             (case
               when upper(irm.instrument_type) = 'SPOT' then
                'Y'
               else
                'N'
             end) is_spot_instrument,
             (case
               when upper(irm.instrument_type) = 'SPOT' then
                tt.instrument_id
               else
                null
             end) spot_instrument_id,
             pdm.product_type_id
        from (select fb_order_seq,
                     formula_id,
                     instrument_id,
                     price_source_id,
                     price_point_id,
                     available_price_id,
                     fb_period_type,
                     fb_period_sub_type,
                     period_month,
                     period_year,
                     period_from_date,
                     period_to_date,
                     no_of_months,
                     no_of_days,
                     period_type_id,
                     delivery_period_id,
                     off_day_price,
                     basis,
                     basis_price_unit_id,
                     fx_rate_type,
                     fx_rate
                from the (select cast(pobj_fb_instrument_data as
                                      fb_tbl_instrument_data)
                            from dual)) tt,
             dim_der_instrument_master dim,
             irm_instrument_type_master irm,
             dim_der_instrument_master dim_und,
             (select *
                from div_der_instrument_valuation div_und
               where div_und.is_deleted = 'N') div_und,
             (select *
                from div_der_instrument_valuation div_und1
               where div_und1.is_deleted = 'N') div_dim,
             v_ppu_pum pum,
             pum_price_unit_master pum_ins, -- has to be used incase instrument level pum id passed instead of ppu
             ps_price_source ps,
             pp_price_point pp,
             apm_available_price_master apm,
             pdd_product_derivative_def pdd,
             pdm_productmaster pdm
       where tt.instrument_id = dim.instrument_id
         and dim.instrument_type_id = irm.instrument_type_id
         and tt.price_source_id = ps.price_source_id(+)
         and tt.price_point_id = pp.price_point_id(+)
         and tt.available_price_id = apm.available_price_id(+)
         and dim.underlying_instrument_id = div_und.instrument_id(+)
         and dim.instrument_id = div_dim.instrument_id
         and dim.underlying_instrument_id = dim_und.instrument_id(+)
         and tt.basis_price_unit_id = pum.product_price_unit_id(+)
         and tt.basis_price_unit_id = pum_ins.price_unit_id(+) -- has to be used incase instrument level pum id passed instead of ppu
         and dim.product_derivative_id = pdd.derivative_def_id(+)
         and pdd.product_id = pdm.product_id(+);
    vc_sql_temp                 varchar2(4000);
    vc_tbl                      tp_tbl_formula;
    vc_tbl_out                  tp_tbl_formula;
    vc_inst_tbl                 fb_tbl_instrument_data;
    vobj_fb_tbl_setup           fb_tbl_setup;
    vc_tbl_daywise              tp_tbl_formula;
    vn_fb_log_id                varchar2(50);
    vc_holiday                  char(1);
    vd_start_date               date;
    vd_end_date                 date;
    vn_row                      number := 1;
    vn_setup_row                number := 1;
    vd_first_wkg_date           date;
    vd_last_wkg_date            date;
    vn_first_count              number;
    vn_last_count               number;
    vn_instrumnet_cnt           number := 0;
    vn_instrument_sum           number := 0;
    vn_instrument_avg           number;
    vn_instrumnet_fxcnt         number := 0;
    vn_instrument_fxsum         number := 0;
    vn_instrument_fxavg         number;
    vc_instrument_id            varchar2(20);
    vd_first_date               date;
    vd_last_date                date;
    vn_avg_cnt                  number := 1;
    vc_formula                  varchar2(500);
    vn_average                  number;
    vn_srt_psn                  number;
    vn_end_psn                  number;
    vobj_fb_log                 fb_tbl_error;
    vn_fb_log_count             number := 1;
    vc_corporate_id             varchar2(15);
    vd_trade_date               date;
    vc_formula_id               varchar(30);
    vc_inst_price_status_flag   varchar2(50);
    vc_final_price_status_flag  varchar2(20) := 'Final';
    --vc_setup_price_status_flag  varchar2(20) := 'Final';
    vc_day_final_price_status   varchar2(20) := 'Final';    
    vc_final_qp_status_flag     varchar2(20) := 'Fixed';
    vc_inst_price_qp_status     varchar2(20);
    vc_calculated_dr_id         varchar2(15);
    vd_drm_last_tradable_date   date;
    vn_instrument_temp_avg      number(10, 3);
    vn_instrument_temp_avg_ret  number(10, 3);
    vn_fxrate                   number;
    vc_fx_formula               varchar2(200);
    vn_srt_fx_psn               number;
    vn_end_fx_psn               number;
    vd_lst_trade_date           date;
    pc_price_name               varchar2(20);
    vc_drid_name                varchar2(50);
    vc_instrument_name          varchar2(100);
    vc_price_date_display       varchar2(20);
    vd_qp_start_date            date;
    vd_qp_end_date              date;
    j                           number;
    vn_inst_total               number := 0;
    vn_daywise_price            number;
    vc_formula_exe              varchar2(1000);
    vn_setup_count              number := 0;
    vn_instrument_count         number := 0;
    vc_instrument_price_unit_id varchar2(15);
    vc_inst_basis_price_unit_id varchar2(15);
    vc_set_basis_price_unit_id  varchar2(15);
    vc_period_month             varchar2(15);
    vc_period_year              number(8);
    vc_prev_day                 varchar2(20);
    vc_record_error             varchar2(1) := 'N';
    vn_no_working_days          number;
    vc_is_event_process         varchar(1);
    vd_event_start_date         date;
    vd_event_end_date           date;
    vc_zero_flag                char(1);
    vn_dummy_price              number;
    vn_counter                  number;
    vc_off_day_price            varchar(50);
    vn_temp_day_price           number;
    vc_inst_holiday_flag        varchar2(5);
    vd_valid_trade_date         date;
    vn_cal_npd_count            number(6);
  begin
    vobj_fb_tbl_setup   := fb_tbl_setup();
    vc_tbl_daywise      := tp_tbl_formula();
    vobj_fb_log         := fb_tbl_error();
    vn_fb_log_count     := 1;
    vc_is_event_process := pc_is_event_process;
    vn_cal_npd_count := 0;
    begin
      select seq_fbpl.nextval into vn_fb_log_id from dual;
    exception
      when no_data_found then
        vn_fb_log_id := to_char(sysdate, 'yyyymmddhh24miss');
      when others then
        vn_fb_log_id := to_char(sysdate, 'yyyymmddhh24miss');
    end;
    /*    if passed setup object has no data  */
    if not pobj_fb_setup.exists(1) then
      vobj_fb_log.extend;
      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                    null,
                                                    null,
                                                    'procedure sp_calculate_formula_price',
                                                    'CDC-002',
                                                    'No data set for Setup  type',
                                                    'L2',
                                                    null,
                                                    sysdate,
                                                    'Error',
                                                    null);
      vn_fb_log_count := vn_fb_log_count + 1;
    end if;
    if not pobj_fb_instrument_data.exists(1) then
      vobj_fb_log.extend;
      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                    null,
                                                    null,
                                                    'procedure sp_calculate_formula_price',
                                                    'CDC-002',
                                                    'No data set for instrumet type',
                                                    'L2',
                                                    null,
                                                    sysdate,
                                                    'Error',
                                                    null);
      vn_fb_log_count := vn_fb_log_count + 1;
    end if;
    vc_inst_tbl := fb_tbl_instrument_data();
    --OPENIG THE FORMULA SET UP CURSOR.
    vn_setup_row := 1;
    --Check the no. of rows in the cur_setup_rows
    --after the select statemet from the cur_setup_type
    select count(*)
      into vn_setup_count
      from (select price_unit_id,
                   corporate_id
              from the (select cast(pobj_fb_setup as fb_tbl_setup) from dual)) tt,
           v_ppu_pum pum
     where tt.price_unit_id = pum.product_price_unit_id(+);
    if vn_setup_count = 0 then
      vobj_fb_log.extend;
      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                    null,
                                                    null,
                                                    'procedure sp_calculate_formula_price',
                                                    'CDC-002',
                                                    'No data set for Setup  type',
                                                    'L2',
                                                    null,
                                                    sysdate,
                                                    'Error',
                                                    null);
      vn_fb_log_count := vn_fb_log_count + 1;
    else
      for cur_setup_rows in cur_setup
      loop
        vc_corporate_id             := cur_setup_rows.corporate_id;
        vd_trade_date               := nvl(cur_setup_rows.trade_date,
                                           sysdate);
        vc_formula_id               := cur_setup_rows.formula_id;
        vc_formula                  := cur_setup_rows.formula_internal;
        vc_fx_formula               := cur_setup_rows.formula_internal;
        vn_avg_cnt                  := 1;
        vc_inst_basis_price_unit_id := null;
        vc_set_basis_price_unit_id  := cur_setup_rows.price_unit_id;      
        --OPENING THE INSTRUMENT SET UP CURSOR.
        --check the no. of rows in the cur_instrument_rows
        --after the select statement from the cur_instrument_type      
        select count(*)
          into vn_instrument_count
          from (select fb_order_seq,
                       instrument_id
                  from the (select cast(pobj_fb_instrument_data as
                                        fb_tbl_instrument_data)
                              from dual)) tt,
               dim_der_instrument_master dim,
               irm_instrument_type_master irm
         where tt.instrument_id = dim.instrument_id
           and dim.instrument_type_id = irm.instrument_type_id;      
        if vn_instrument_count = 0 then
          vobj_fb_log.extend;
          vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                        null,
                                                        null,
                                                        'procedure sp_calculate_formula_price',
                                                        'CDC-002',
                                                        'No data set for instrumet type',
                                                        'L2',
                                                        null,
                                                        sysdate,
                                                        'Error',
                                                        null);
          vn_fb_log_count := vn_fb_log_count + 1;
        else
          for cur_instrument_rows in cur_instrument
          loop
            pc_price_name               := nvl(cur_instrument_rows.available_price_name,
                                               'Settlement');
            vc_inst_price_status_flag   := 'Final';
            vc_inst_price_qp_status     := null;
            vc_instrument_price_unit_id := null;
            vd_lst_trade_date           := null;
            vc_inst_basis_price_unit_id := cur_instrument_rows.basis_price_unit_id;
            vc_calculated_dr_id         := null;
            vd_first_date               := null;
            vd_start_date               := null;
            vd_last_date                := null;
            vd_end_date                 := null;
            if cur_setup_rows.formula_id = cur_instrument_rows.formula_id then
              vc_tbl     := tp_tbl_formula();
              vc_tbl_out := tp_tbl_formula();
              if cur_instrument_rows.fb_period_type is null and
                 cur_instrument_rows.fb_period_sub_type is null then
                -- if    cur_instrument_rows.fb_period_type <>  'Delivered' then
                vc_inst_price_status_flag := 'Error';
                vobj_fb_log.extend;
                vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                              cur_setup_rows.corporate_id,
                                                              cur_setup_rows.trade_date,
                                                              'procedure sp_calculate_formula_price',
                                                              'CDC-002',
                                                              'Formula Period type/sub Type' ||
                                                              ' not set for ' ||
                                                              cur_instrument_rows.instrument_name,
                                                              'L2',
                                                              null,
                                                              sysdate,
                                                              'Error',
                                                              cur_instrument_rows.fb_order_seq);
                vn_fb_log_count := vn_fb_log_count + 1;
                --   end if;
              elsif cur_instrument_rows.fb_period_type is not null and
                    cur_instrument_rows.fb_period_sub_type is null then
                if cur_instrument_rows.fb_period_type not in
                   ('Delivered', 'Custom', 'Event Based', 'Event') then
                  vc_inst_price_status_flag := 'Error';
                  vobj_fb_log.extend;
                  vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                cur_setup_rows.corporate_id,
                                                                cur_setup_rows.trade_date,
                                                                'procedure sp_calculate_formula_price',
                                                                'CDC-002',
                                                                'Formula Period type/sub Type' ||
                                                                ' not set for ' ||
                                                                cur_instrument_rows.instrument_name,
                                                                'L2',
                                                                null,
                                                                sysdate,
                                                                'Error',
                                                                cur_instrument_rows.fb_order_seq);
                  vn_fb_log_count := vn_fb_log_count + 1;
                end if;
              elsif cur_instrument_rows.fb_period_type is null then
                vc_inst_price_status_flag := 'Error';
                vobj_fb_log.extend;
                vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                              cur_setup_rows.corporate_id,
                                                              cur_setup_rows.trade_date,
                                                              'procedure sp_calculate_formula_price',
                                                              'CDC-002',
                                                              'Formula Period type/sub Type' ||
                                                              ' not set for ' ||
                                                              cur_instrument_rows.instrument_name,
                                                              'L2',
                                                              null,
                                                              sysdate,
                                                              'Error',
                                                              cur_instrument_rows.fb_order_seq);
                vn_fb_log_count := vn_fb_log_count + 1;
              end if;
              if vc_inst_price_status_flag <> 'Error' then
                --FINDING THE FIRST DATE AND LAST DATE FROM THE PROMPT  PERIOD TYPE.
                if cur_instrument_rows.fb_period_type = 'Prompt' and
                   cur_instrument_rows.fb_period_sub_type = 'Prompt Month' then
                  if cur_instrument_rows.period_month is null or
                     cur_instrument_rows.period_year is null then
                    vc_inst_price_status_flag := 'Error';
                    vobj_fb_log.extend;
                    vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                  cur_setup_rows.corporate_id,
                                                                  cur_setup_rows.trade_date,
                                                                  'procedure sp_calculate_formula_price',
                                                                  'CDC-002',
                                                                  'Prompt-Prompt Month: period_month/period_year for ' ||
                                                                  cur_instrument_rows.instrument_name,
                                                                  'L3',
                                                                  null,
                                                                  sysdate,
                                                                  'Error',
                                                                  cur_instrument_rows.fb_order_seq);
                    vn_fb_log_count := vn_fb_log_count + 1;
                  end if;
                  vd_start_date := to_date('01-' ||
                                           cur_instrument_rows.period_month || '-' ||
                                           cur_instrument_rows.period_year,
                                           'dd-mon-yyyy');
                  vd_end_date   := last_day(vd_start_date);
                elsif cur_instrument_rows.fb_period_type = 'Prompt' and
                      cur_instrument_rows.fb_period_sub_type =
                      'Delivery Month' then
                  if cur_instrument_rows.period_month is null or
                     cur_instrument_rows.period_year is null then
                    vc_inst_price_status_flag := 'Error';
                    vobj_fb_log.extend;
                    vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                  cur_setup_rows.corporate_id,
                                                                  cur_setup_rows.trade_date,
                                                                  'procedure sp_calculate_formula_price',
                                                                  'CDC-002',
                                                                  'Prompt-Delivery Month: period_month/period_year for ' ||
                                                                  cur_instrument_rows.instrument_name,
                                                                  'L4',
                                                                  null,
                                                                  sysdate,
                                                                  'Error',
                                                                  cur_instrument_rows.fb_order_seq);
                    vn_fb_log_count := vn_fb_log_count + 1;
                  end if;
                  vd_start_date := add_months(to_date('01-' ||
                                                      cur_instrument_rows.period_month || '-' ||
                                                      cur_instrument_rows.period_year,
                                                      'dd-mon-yyyy'),
                                              cur_instrument_rows.no_of_months);
                  vd_end_date   := last_day(vd_start_date);                
                elsif cur_instrument_rows.fb_period_type = 'Prompt' and
                      cur_instrument_rows.fb_period_sub_type =
                      'Specific Period' then                
                  if cur_instrument_rows.period_from_date is null or
                     cur_instrument_rows.period_to_date is null then
                    vc_inst_price_status_flag := 'Error';
                    vobj_fb_log.extend;
                    vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                  cur_setup_rows.corporate_id,
                                                                  cur_setup_rows.trade_date,
                                                                  'procedure sp_calculate_formula_price',
                                                                  'CDC-002',
                                                                  'Prompt-Specific Period: period_from_date/period_to_date for ' ||
                                                                  cur_instrument_rows.instrument_name,
                                                                  'L5',
                                                                  null,
                                                                  sysdate,
                                                                  'Error',
                                                                  cur_instrument_rows.fb_order_seq);
                    vn_fb_log_count := vn_fb_log_count + 1;
                  end if;
                  vd_start_date := cur_instrument_rows.period_from_date;
                  vd_end_date   := cur_instrument_rows.period_to_date;
                elsif cur_instrument_rows.fb_period_type = 'Delivered' then
                  if cur_instrument_rows.period_month is null or
                     cur_instrument_rows.period_year is null then
                    vc_inst_price_status_flag := 'Error';
                    vobj_fb_log.extend;
                    vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                  cur_setup_rows.corporate_id,
                                                                  cur_setup_rows.trade_date,
                                                                  'procedure sp_calculate_formula_price',
                                                                  'CDC-002',
                                                                  'Delivered: period_month/period_year for ' ||
                                                                  cur_instrument_rows.instrument_name,
                                                                  'L6',
                                                                  null,
                                                                  sysdate,
                                                                  'Error',
                                                                  cur_instrument_rows.fb_order_seq);
                    vn_fb_log_count := vn_fb_log_count + 1;
                  end if;
                  begin
                    select nvl(drm.last_tradable_date, drm.prompt_date)
                      into vd_end_date
                      from drm_derivative_master drm
                     where drm.instrument_id =
                           cur_instrument_rows.instrument_id
                       and drm.period_month =
                           cur_instrument_rows.period_month
                       and drm.period_year =
                           cur_instrument_rows.period_year
                       and drm.is_deleted = 'N';
                  exception
                    when others then
                      vc_inst_price_status_flag := 'Error';
                      vd_end_date               := null;
                      vobj_fb_log.extend;
                      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                    cur_setup_rows.corporate_id,
                                                                    cur_setup_rows.trade_date,
                                                                    'procedure sp_calculate_formula_price',
                                                                    'CDC-002',
                                                                    'Instrument master data missing for ' ||
                                                                    cur_instrument_rows.instrument_name || ' ' ||
                                                                    cur_instrument_rows.period_month || '-' ||
                                                                    cur_instrument_rows.period_year,
                                                                    'L6.1',
                                                                    null,
                                                                    sysdate,
                                                                    'Error',
                                                                    cur_instrument_rows.fb_order_seq);
                      vn_fb_log_count := vn_fb_log_count + 1;
                  end;
                  vd_start_date := trunc(vd_end_date - 30);
                  vd_end_date   := vd_end_date;
                elsif cur_instrument_rows.fb_period_type = 'Settlement' and
                      cur_instrument_rows.fb_period_sub_type =
                      'Exchange Calendar' then
                  if cur_instrument_rows.period_month is null or
                     cur_instrument_rows.period_year is null then
                    vc_inst_price_status_flag := 'Error';
                    vobj_fb_log.extend;
                    vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                  cur_setup_rows.corporate_id,
                                                                  cur_setup_rows.trade_date,
                                                                  'procedure sp_calculate_formula_price',
                                                                  'CDC-002',
                                                                  'Settlement-Exchange Calendar: period_month/period_year for ' ||
                                                                  cur_instrument_rows.instrument_name,
                                                                  'L7',
                                                                  null,
                                                                  sysdate,
                                                                  'Error',
                                                                  cur_instrument_rows.fb_order_seq);
                    vn_fb_log_count := vn_fb_log_count + 1;
                  end if;
                  begin
                    select nvl(drm.last_tradable_date, drm.prompt_date) -- nvl added to avoid null error in metal exhcnage
                      into vd_start_date
                      from drm_derivative_master drm,
                           pm_period_master      pm
                     where drm.instrument_id =
                           cur_instrument_rows.instrument_id
                       and drm.period_month =
                           cur_instrument_rows.period_month
                       and drm.period_year =
                           cur_instrument_rows.period_year
                       and drm.period_type_id = pm.period_type_id
                       and drm.is_deleted = 'N'
                       and pm.period_type_name = 'Month';
                  exception
                    when others then
                      vc_inst_price_status_flag := 'Error';
                      vobj_fb_log.extend;
                      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                    cur_setup_rows.corporate_id,
                                                                    cur_setup_rows.trade_date,
                                                                    'procedure sp_calculate_formula_price',
                                                                    'CDC-002',
                                                                    'Instrument master data missing for ' ||
                                                                    cur_instrument_rows.instrument_name || ' ' ||
                                                                    cur_instrument_rows.period_month || '-' ||
                                                                    cur_instrument_rows.period_year,
                                                                    'L8',
                                                                    null,
                                                                    sysdate,
                                                                    'Error',
                                                                    cur_instrument_rows.fb_order_seq);
                      vn_fb_log_count := vn_fb_log_count + 1;
                    
                  end;
                  vd_end_date := vd_start_date;
                  if vd_start_date is null then
                    vc_inst_price_status_flag := 'Error';
                    vobj_fb_log.extend;
                    vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                  cur_setup_rows.corporate_id,
                                                                  cur_setup_rows.trade_date,
                                                                  'procedure sp_calculate_formula_price',
                                                                  'CDC-002',
                                                                  'Instrument last tradable date missing for ' ||
                                                                  cur_instrument_rows.instrument_name || ' ' ||
                                                                  cur_instrument_rows.period_month || '-' ||
                                                                  cur_instrument_rows.period_year,
                                                                  'L9',
                                                                  null,
                                                                  sysdate,
                                                                  'Error',
                                                                  cur_instrument_rows.fb_order_seq);
                    vn_fb_log_count := vn_fb_log_count + 1;
                  
                  end if;
                elsif cur_instrument_rows.fb_period_type = 'Settlement' and
                      cur_instrument_rows.fb_period_sub_type =
                      'Delivery Month' then
                  begin
                    select nvl(drm.last_tradable_date, drm.prompt_date) -- nvl added to avoid null error in metal exhcnage
                      into vd_end_date
                      from drm_derivative_master drm
                     where drm.instrument_id =
                           cur_instrument_rows.instrument_id
                       and drm.period_month =
                           cur_instrument_rows.period_month
                       and drm.is_deleted = 'N'
                       and drm.period_year =
                           cur_instrument_rows.period_year;
                  exception
                    when others then
                      vc_inst_price_status_flag := 'Error';
                      vobj_fb_log.extend;
                      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                    cur_setup_rows.corporate_id,
                                                                    cur_setup_rows.trade_date,
                                                                    'procedure sp_calculate_formula_price',
                                                                    'CDC-002',
                                                                    'Instrument master data missing for ' ||
                                                                    cur_instrument_rows.instrument_name || ' ' ||
                                                                    cur_instrument_rows.period_month || '-' ||
                                                                    cur_instrument_rows.period_year,
                                                                    'L10',
                                                                    null,
                                                                    sysdate,
                                                                    'Error',
                                                                    cur_instrument_rows.fb_order_seq);
                      vn_fb_log_count := vn_fb_log_count + 1;
                  end;
                  vd_start_date := vd_end_date -
                                   nvl(cur_instrument_rows.no_of_days, 0);
                  if vd_end_date is null then
                    vc_inst_price_status_flag := 'Error';
                    vobj_fb_log.extend;
                    vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                  cur_setup_rows.corporate_id,
                                                                  cur_setup_rows.trade_date,
                                                                  'procedure sp_calculate_formula_price',
                                                                  'CDC-002',
                                                                  'Instrument last tradable date missing for ' ||
                                                                  cur_instrument_rows.instrument_name || ' ' ||
                                                                  cur_instrument_rows.period_month || '-' ||
                                                                  cur_instrument_rows.period_year,
                                                                  'L11',
                                                                  null,
                                                                  sysdate,
                                                                  'Error',
                                                                  cur_instrument_rows.fb_order_seq);
                    vn_fb_log_count := vn_fb_log_count + 1;
                  end if;
                else
                  vd_start_date := cur_instrument_rows.period_from_date;
                  vd_end_date   := cur_instrument_rows.period_to_date;
                  if cur_instrument_rows.period_from_date is null or
                     cur_instrument_rows.period_to_date is null then
                    vc_inst_price_status_flag := 'Error';
                    vobj_fb_log.extend;
                    vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                  cur_setup_rows.corporate_id,
                                                                  cur_setup_rows.trade_date,
                                                                  'procedure sp_calculate_formula_price',
                                                                  'CDC-002',
                                                                  cur_instrument_rows.fb_period_type ||
                                                                  'period_from_date/period_to_date for ' ||
                                                                  cur_instrument_rows.instrument_name,
                                                                  'L12',
                                                                  null,
                                                                  sysdate,
                                                                  'Error',
                                                                  cur_instrument_rows.fb_order_seq);
                    vn_fb_log_count := vn_fb_log_count + 1;
                  end if;
                end if;
                --- Added suresh start  
                if pn_event_before_days = 0 and
                   pn_include_exclude_event = 0 and pn_event_after_days = 0 then
                  vc_zero_flag := 'Y';
                else
                  vc_zero_flag := 'N';
                end if;
                if vc_is_event_process = 'Y' and vc_zero_flag = 'N' then
                  if pn_event_before_days = 0 then
                    vd_event_start_date := pd_event_date;
                  else
                    vd_event_start_date := pd_event_date - 1;
                  end if;
                  vn_no_working_days := 0;
                  --- satart Date
                  while vn_no_working_days <> pn_event_before_days
                  loop
                    if pkg_cdc_formula_builder.f_is_day_holiday(cur_instrument_rows.instrument_id,
                                                                vd_event_start_date) then
                      vd_event_start_date := vd_event_start_date - 1;
                    else
                      vn_no_working_days := vn_no_working_days + 1;
                      if vn_no_working_days <> pn_event_before_days then
                        vd_event_start_date := vd_event_start_date - 1;
                      end if;
                    end if;
                  end loop;
                  -- End date
                  if pn_event_after_days = 0 then
                    vd_event_end_date := pd_event_date;
                  else
                    vd_event_end_date := pd_event_date + 1;
                  end if;
                  vn_no_working_days := 0;
                  while vn_no_working_days <> pn_event_after_days
                  loop
                    if pkg_cdc_formula_builder.f_is_day_holiday(cur_instrument_rows.instrument_id,
                                                                vd_event_end_date) then
                      vd_event_end_date := vd_event_end_date + 1;
                    else
                      vn_no_working_days := vn_no_working_days + 1;
                      if vn_no_working_days <> pn_event_after_days then
                        vd_event_end_date := vd_event_end_date + 1;
                      end if;
                    end if;
                  end loop;                
                  vd_start_date := vd_event_start_date;
                  vd_end_date   := vd_event_end_date;
                end if;
                ---- END
              end if;            
              vd_first_date := vd_start_date;
              vd_last_date  := vd_end_date;            
              ---************************************************************************************----------
              ---***** do not modify the vd_qp_start_date/vd_qp_end_date later in this package ********--------
              vd_qp_start_date := vd_start_date; -- to capture the original QP start date,
              vd_qp_end_date   := vd_end_date; -- to capture the original QP end date
              ---************************************************************************************----------
              /*END OF PROMPT PERIOD TYPE. */
              if vc_inst_price_status_flag <> 'Error' then
                --START OF Finding the firsr working day
--                'Previous Day Repeat','Next Day Repeat','Last Day Repeat','Skip'
                if cur_instrument_rows.off_day_price = 'Previous Day Repeat' then
                while true
                loop
                  if pkg_cdc_formula_builder.f_is_day_holiday(cur_instrument_rows.instrument_id,
                                                              vd_start_date) then
                    vd_start_date := vd_start_date - 1;
                  else
                    exit;
                  end if;
                end loop;
                end if;
                vd_first_wkg_date := vd_start_date;
                --finding the last working day
               if cur_instrument_rows.off_day_price = 'Next Day Repeat' then
                while true
                loop
                  if pkg_cdc_formula_builder.f_is_day_holiday(cur_instrument_rows.instrument_id,
                                                              vd_end_date) then
                    vd_end_date := vd_end_date + 1;
                  else
                    exit;
                  end if;
                end loop;
                end if;
                vd_last_wkg_date := vd_end_date;
                /*PUTTING THE HOLIDAY STATUS,INSTRUMENT ID ... IN THE TYPE*/
               begin
                    select count(*)
                      into vn_cal_npd_count
                      from npd_non_prompt_calendar_days npd
                     where npd.prompt_delivery_calendar_id =
                           cur_instrument_rows.delivery_calender_id
                           and npd.is_deleted = 'N';
                exception
                    when no_data_found then
                      vn_cal_npd_count := 0;
                    when others then
                      vn_cal_npd_count := 0;
                end;                
                vn_row := 1;
                while vd_last_wkg_date >= vd_first_wkg_date
                loop
                  if cur_instrument_rows.is_spot_instrument = 'Y' then
                    if pkg_cdc_formula_builder.f_is_day_holiday(cur_instrument_rows.spot_instrument_id,
                                                                vd_first_wkg_date) then
                      vc_holiday := 'Y';
                    else
                      vc_holiday := 'N';
                    end if;
                  else
                    if pkg_cdc_formula_builder.f_is_day_holiday(cur_instrument_rows.instrument_id,
                                                                vd_first_wkg_date) then
                      vc_holiday := 'Y';
                    else
                      vc_holiday := 'N';
                    end if;
                  end if;
                  --Price Point holiday check added on 24 Oct 2013
                  -- do not consider the date If specifed on price point holiday
                  -- do not include it in avg no of days also If specifed on price point holiday
                  -- reocord seperately the instrument is holiday or not in vc_inst_holiday_flag
                  -- vc_inst_holiday_flag is used for daily avg calculation,
                  -- vc_inst_holiday_flag stored in tp_tbl_formula exp_cur_id, -- TODO : new columns to be added in this ttpe and used..
                  -- as of now exp_cur_id column used to store this flag, 
                  -- 
                  vc_inst_holiday_flag := vc_holiday;
                  vc_off_day_price     := cur_instrument_rows.off_day_price;
                  if cur_instrument_rows.price_point_id is not null then
                    if cur_instrument_rows.instrument_type = 'Average' then
                      vc_instrument_id := cur_instrument_rows.underlying_instrument_id;
                    else
                      vc_instrument_id := cur_instrument_rows.instrument_id;
                    end if;
                    if vc_holiday <> 'Y' then
                      if pkg_cdc_formula_builder.f_is_pp_holiday(cur_instrument_rows.instrument_id,
                                                                 cur_instrument_rows.price_point_id,
                                                                 vd_first_wkg_date) then
                        vc_holiday       := 'Y';
                        vc_off_day_price := 'Skip';
                      end if;
                    end if;
                  end if;
                  --Price Point holiday check end on 24 Oct 2013                  
                  if vd_first_wkg_date = pd_event_date and
                     pn_include_exclude_event = 0 and
                     vc_is_event_process = 'Y' and vc_zero_flag = 'N' then
                    null;
                  else
                    vc_tbl.extend;
                    vc_tbl(vn_row) := tp_obj_formula(vd_first_wkg_date,
                                                     cur_instrument_rows.instrument_id,
                                                     vc_holiday,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     vc_off_day_price,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     null,
                                                     vc_inst_holiday_flag);
                    vn_row := vn_row + 1;
                  end if;
                  vd_first_wkg_date := vd_first_wkg_date + 1;
                end loop;
                vd_first_wkg_date := vd_start_date; --re-set vd_first_wkg_date as start of the date
                /*END OF INSERTING DATA TO THE TYPE*/
                /*SETTING DR-ID TO THE TYPE*/
                vc_instrument_name := '';
                if cur_instrument_rows.price_point_id is not null then
                  vc_price_date_display := to_char(vd_first_wkg_date,
                                                   'dd-Mon-yyyy');
                  begin
                    if cur_instrument_rows.instrument_type = 'Average' then
                      vc_instrument_name := cur_instrument_rows.underlying_instrument_name;
                      vc_instrument_id   := cur_instrument_rows.underlying_instrument_id;
                      select drm.dr_id
                        into vc_calculated_dr_id
                        from drm_derivative_master drm
                       where drm.instrument_id =
                             cur_instrument_rows.underlying_instrument_id
                         and drm.price_point_id =
                             cur_instrument_rows.price_point_id
                         and drm.is_deleted = 'N';
                    else
                      vc_instrument_name := cur_instrument_rows.instrument_name;
                      vc_instrument_id   := cur_instrument_rows.instrument_id;
                      select drm.dr_id
                        into vc_calculated_dr_id
                        from drm_derivative_master drm
                       where drm.instrument_id =
                             cur_instrument_rows.instrument_id
                         and drm.price_point_id =
                             cur_instrument_rows.price_point_id
                         and drm.is_deleted = 'N';
                    end if;
                  exception
                    when no_data_found then
                      vc_calculated_dr_id := null;
                      vobj_fb_log.extend;
                      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                    cur_setup_rows.corporate_id,
                                                                    cur_setup_rows.trade_date,
                                                                    'procedure sp_calculate_formula_price',
                                                                    'CDC-003',
                                                                    vc_instrument_name || ' ' ||
                                                                    ',Price Source : ' ||
                                                                    cur_instrument_rows.price_source_name || ' ' ||
                                                                    ', Price Point Name :  ' ||
                                                                    cur_instrument_rows.price_point_name ||
                                                                    ' Required Quotes Date  ' ||
                                                                    vc_price_date_display,
                                                                    'Q2',
                                                                    null,
                                                                    sysdate,
                                                                    'Error',
                                                                    cur_instrument_rows.fb_order_seq);
                      vn_fb_log_count := vn_fb_log_count + 1;
                    when others then
                      vc_calculated_dr_id := null;
                  end;
                  /*dbms_output.put_line('The DRID by price point is=  ' ||
                  vc_calculated_dr_id);*/
                  if vc_calculated_dr_id is not null then
                    --Setting the DRID to the type
                    for i in vc_tbl.first .. vc_tbl.last
                    loop
                      vc_tbl(i).drid := vc_calculated_dr_id;
                    end loop;
                  end if;
                else
                  if cur_instrument_rows.fb_period_type in
                     ('Settlement', 'Delivered') then
                    --for Delivered and Settlement
                    begin
                      select drm.dr_id,
                             nvl(drm.last_tradable_date, drm.prompt_date) last_tradable_date
                        into vc_calculated_dr_id,
                             vd_drm_last_tradable_date
                        from drm_derivative_master      drm,
                             pm_period_master           pm,
                             dim_der_instrument_master  dim,
                             irm_instrument_type_master irm
                       where drm.period_type_id = pm.period_type_id
                         and pm.period_type_name = 'Month'
                         and drm.price_point_id is null
                         and drm.instrument_id = dim.instrument_id
                         and dim.instrument_type_id =
                             irm.instrument_type_id
                         and drm.instrument_id =
                             cur_instrument_rows.instrument_id
                         and drm.period_month =
                             cur_instrument_rows.period_month
                         and drm.period_year =
                             cur_instrument_rows.period_year
                         and drm.is_deleted = 'N';
                    exception
                      when no_data_found then
                        vc_inst_price_status_flag := 'Error';
                        vobj_fb_log.extend;
                        vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                      cur_setup_rows.corporate_id,
                                                                      cur_setup_rows.trade_date,
                                                                      'procedure sp_calculate_formula_price',
                                                                      'CDC-002',
                                                                      'Instrument month not available for  ' ||
                                                                      cur_instrument_rows.instrument_name || ',' ||
                                                                      cur_instrument_rows.period_month || '-' ||
                                                                      cur_instrument_rows.period_year,
                                                                      'DRM1',
                                                                      null,
                                                                      sysdate,
                                                                      'Error',
                                                                      cur_instrument_rows.fb_order_seq);
                        vn_fb_log_count := vn_fb_log_count + 1;
                      when others then
                        vc_inst_price_status_flag := 'Error';
                        vobj_fb_log.extend;
                        vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                      cur_setup_rows.corporate_id,
                                                                      cur_setup_rows.trade_date,
                                                                      'procedure sp_calculate_formula_price',
                                                                      'CDC-002',
                                                                      'Instrument month not available for  ' ||
                                                                      cur_instrument_rows.instrument_name || ',' ||
                                                                      cur_instrument_rows.period_month || '-' ||
                                                                      cur_instrument_rows.period_year,
                                                                      'DRM2',
                                                                      null,
                                                                      sysdate,
                                                                      'Error',
                                                                      cur_instrument_rows.fb_order_seq);
                        vn_fb_log_count := vn_fb_log_count + 1;
                    end;
                    if vc_calculated_dr_id is not null then
                      for i in vc_tbl.first .. vc_tbl.last
                      loop
                        vc_tbl(i).drid := vc_calculated_dr_id;
                      end loop;
                    end if;
                    --other than Delivered and Settlement  price types,based on the last tradeable date of each DRID,next drid has
                    --to be calculated                   
                  end if;
                  if cur_instrument_rows.fb_period_type = 'Custom' then
                    vc_period_month := cur_instrument_rows.period_month;
                    vc_period_year  := cur_instrument_rows.period_year;
                    if vc_period_month is not null and
                       vc_period_year is not null then
                      begin
                        select drm.dr_id,
                               nvl(drm.last_tradable_date, drm.prompt_date) last_tradable_date
                          into vc_calculated_dr_id,
                               vd_drm_last_tradable_date
                          from drm_derivative_master      drm,
                               pm_period_master           pm,
                               dim_der_instrument_master  dim,
                               irm_instrument_type_master irm
                         where drm.period_type_id = pm.period_type_id
                           and pm.period_type_name = 'Month'
                           and drm.price_point_id is null
                           and drm.instrument_id = dim.instrument_id
                           and dim.instrument_type_id =
                               irm.instrument_type_id
                           and drm.instrument_id =
                               cur_instrument_rows.instrument_id
                           and drm.period_month =
                               cur_instrument_rows.period_month
                           and drm.period_year =
                               cur_instrument_rows.period_year
                           and drm.is_deleted = 'N';
                        if vc_calculated_dr_id is not null then
                          for i in vc_tbl.first .. vc_tbl.last
                          loop
                            vc_tbl(i).drid := vc_calculated_dr_id;
                          end loop;
                        end if;
                      exception
                        when no_data_found then
                          vc_calculated_dr_id := null;
                      end;
                    end if;
                  end if;
                  if vc_calculated_dr_id is null then
                    vd_first_wkg_date := vd_start_date;
                    for i in vc_tbl.first .. vc_tbl.last
                    loop
                      if i = 1 then
                        begin
                          select t.dr_id,
                                 t.last_tradable_date
                            into vc_calculated_dr_id,
                                 vd_drm_last_tradable_date
                            from (select drm.dr_id,
                                         drm.last_tradable_date,
                                         row_number() over(order by drm.last_tradable_date asc nulls last) as curr_trade_date_seq
                                    from v_cdc_fb_drm drm
                                   where drm.last_tradable_date >
                                         vd_first_wkg_date
                                        --                               and drm.last_tradable_date <= vd_last_wkg_date
                                     and drm.instrument_id =
                                         cur_instrument_rows.instrument_id) t
                           where t.curr_trade_date_seq = 1;
                          vd_lst_trade_date := vd_drm_last_tradable_date;
                          vc_tbl(i).drid := vc_calculated_dr_id;
                        exception
                          when no_data_found then
                            vc_inst_price_status_flag := 'Error';
                            vobj_fb_log.extend;
                            vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                          cur_setup_rows.corporate_id,
                                                                          cur_setup_rows.trade_date,
                                                                          'procedure sp_calculate_formula_price',
                                                                          'CDC-002',
                                                                          'Instrument month not available for  ' ||
                                                                          cur_instrument_rows.instrument_name || ',' ||
                                                                          cur_instrument_rows.period_month || '-' ||
                                                                          cur_instrument_rows.period_year,
                                                                          'DRM3',
                                                                          null,
                                                                          sysdate,
                                                                          'Error',
                                                                          cur_instrument_rows.fb_order_seq);
                            vn_fb_log_count := vn_fb_log_count + 1;
                        end;
                      end if;
                      if vc_tbl(i).tradedate <= vd_lst_trade_date then
                        vc_tbl(i).drid := vc_calculated_dr_id;
                      else
                        begin
                          select t.dr_id,
                                 t.last_tradable_date
                            into vc_calculated_dr_id,
                                 vd_drm_last_tradable_date
                            from (select drm.dr_id,
                                         drm.last_tradable_date,
                                         row_number() over(order by drm.last_tradable_date asc nulls last) as curr_trade_date_seq
                                    from v_cdc_fb_drm drm
                                   where drm.last_tradable_date >
                                         vd_lst_trade_date
                                     and drm.instrument_id =
                                         cur_instrument_rows.instrument_id
                                  --and drm.last_tradable_date <=   vd_last_wkg_date
                                  ) t
                           where t.curr_trade_date_seq = 1;
                          vd_lst_trade_date := vd_drm_last_tradable_date;
                          vc_tbl(i).drid := vc_calculated_dr_id;
                        exception
                          when no_data_found then
                            vc_inst_price_status_flag := 'Error';
                            vobj_fb_log.extend;
                            vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                          cur_setup_rows.corporate_id,
                                                                          cur_setup_rows.trade_date,
                                                                          'procedure sp_calculate_formula_price',
                                                                          'CDC-002',
                                                                          'Instrument month not available for  ' ||
                                                                          cur_instrument_rows.instrument_name || ',' ||
                                                                          cur_instrument_rows.period_month || '-' ||
                                                                          cur_instrument_rows.period_year,
                                                                          'DRM4',
                                                                          null,
                                                                          sysdate,
                                                                          'Error',
                                                                          cur_instrument_rows.fb_order_seq);
                            vn_fb_log_count := vn_fb_log_count + 1;
                        end;
                      end if;
                    end loop;
                  end if;
                end if;
                /*FINDING THE PRICE*/
                vc_prev_day := 'NA';
                for i in vc_tbl.first .. vc_tbl.last
                loop
                  vn_fxrate := 0;
                  --In case of SPOT Instrument,Each day spot price used for the after QP or MID QP period upto period date <=trade date
                  -- Before qp period,use the forward instrument price till qp period comes.
                  /*FINDING THE PRICE*/
                  --SPOT Price Calculation STARTS here
                  if cur_instrument_rows.is_spot_instrument = 'Y' and
                     cur_instrument_rows.product_type_id <> 'Freight' and
                     vc_tbl(i).tradedate <= vd_trade_date then
                    begin
                      if vc_tbl(i).isholiday = 'N' then
                        select dr_id,
                               price,
                               trade_date,
                               price_unit_id,
                               instrument_id
                          into vc_tbl(i) .drid,
                               vc_tbl(i) .price,
                               vc_tbl(i) .vd_avl_price_date,
                               vc_tbl(i) .price_unit_id,
                               vc_tbl(i) .instrumentid
                          from (select drm.dr_id,
                                       dqd.price,
                                       dq.trade_date,
                                       dqd.price_unit_id,
                                       dq.instrument_id,
                                       row_number() over(order by dq.trade_date desc nulls last) as td_rank
                                  from dqd_derivative_quote_detail dqd,
                                       dq_derivative_quotes        dq,
                                       pm_period_master            pm,
                                       apm_available_price_master  apm,
                                       drm_derivative_master       drm
                                 where dqd.dq_id = dq.dq_id
                                   and dqd.available_price_id =
                                       apm.available_price_id
                                   and dqd.dr_id = drm.dr_id
                                   and dqd.price_unit_id =
                                       cur_instrument_rows.quotes_price_unit_id
                                   and dq.corporate_id =
                                       cur_setup_rows.corporate_id
                                   and dq.trade_date <= vc_tbl(i)
                                .tradedate
                                   and dq.instrument_id =
                                       cur_instrument_rows.spot_instrument_id
                                   and dq.trade_date <= vd_trade_date
                                   and dq.price_source_id =
                                       cur_instrument_rows.price_source_id
                                   and dq.instrument_id = drm.instrument_id
                                   and drm.prompt_date <= vc_tbl(i)
                                .tradedate
                                   and drm.period_type_id =
                                       pm.period_type_id
                                   and drm.price_point_id is null
                                   and upper(pm.period_type_name) = 'DAY'
                                   and nvl(dqd.price, 0) <> 0
                                   and dq.is_deleted = 'N'
                                   and dqd.is_deleted = 'N'
                                   and drm.is_deleted = 'N'
                                   and apm.available_price_name =
                                       pc_price_name)
                         where td_rank = 1;
                      
                      else
                        vc_tbl(i).price := 0;
                        vc_tbl(i).vd_avl_price_date := null;
                        vc_tbl(i).price_unit_id := null;
                        vc_tbl(i).instrumentid := cur_instrument_rows.spot_instrument_id;
                      end if;
                      if cur_instrument_rows.fx_rate_type <> 'Fixed' then
                        vn_fxrate := f_get_converted_currency_amt(cur_setup_rows.corporate_id,
                                                                  cur_instrument_rows.cur_id,
                                                                  cur_setup_rows.cur_id,
                                                                  vc_tbl(i)
                                                                  .tradedate,
                                                                  1);
                        vc_tbl(i).fx_rate := vn_fxrate;
                      else
                        vc_tbl(i).fx_rate := cur_instrument_rows.fx_rate;
                      end if;
                      if vc_tbl(i).vd_avl_price_date <> vc_tbl(i)
                      .tradedate and vc_tbl(i).isholiday = 'N' then
                        if vc_inst_price_status_flag <> 'Error' then
                          vc_inst_price_status_flag := 'Provisional';
                        end if;
                        vc_drid_name       := to_char(vc_tbl(i).tradedate,
                                                      'dd-Mon-yyyy');
                        vc_instrument_name := 'Spot,' ||
                                              cur_instrument_rows.instrument_name;
                        vobj_fb_log.extend;
                        vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                      cur_setup_rows.corporate_id,
                                                                      cur_setup_rows.trade_date,
                                                                      'procedure sp_calculate_formula_price',
                                                                      'CDC-003',
                                                                      vc_instrument_name || ', ' ||
                                                                      vc_drid_name ||
                                                                      ', Price Source: ' ||
                                                                      cur_instrument_rows.price_source_name || ',' ||
                                                                      ' Current Quotes available for Date: ' ||
                                                                      to_char(vc_tbl(i)
                                                                              .vd_avl_price_date,
                                                                              'dd-Mon-YYYY') || ',' ||
                                                                      ' Required Quotes for Date: ' ||
                                                                      to_char(vc_tbl(i)
                                                                              .tradedate,
                                                                              'dd-Mon-YYYY'),
                                                                      'Q1',
                                                                      null,
                                                                      sysdate,
                                                                      'Warning',
                                                                      cur_instrument_rows.fb_order_seq);
                        vn_fb_log_count := vn_fb_log_count + 1;
                      end if;
                    exception
                      when no_data_found then
                        if vc_tbl(i).isholiday = 'N' then
                          vc_inst_price_status_flag := 'Error';
                          vc_drid_name              := to_char(vc_tbl(i)
                                                               .tradedate,
                                                               'dd-Mon-yyyy');
                          vc_instrument_name        := 'Spot,' ||
                                                       cur_instrument_rows.instrument_name;
                          vobj_fb_log.extend;
                          vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                        cur_setup_rows.corporate_id,
                                                                        cur_setup_rows.trade_date,
                                                                        'procedure sp_calculate_formula_price',
                                                                        'CDC-003',
                                                                        vc_instrument_name || ', ' ||
                                                                        vc_drid_name ||
                                                                        ', Price Source: ' ||
                                                                        cur_instrument_rows.price_source_name || ',' ||
                                                                        ' Required Quotes for Date: ' ||
                                                                        to_char(vc_tbl(i)
                                                                                .tradedate,
                                                                                'dd-Mon-YYYY'),
                                                                        'Q2',
                                                                        null,
                                                                        sysdate,
                                                                        'Error',
                                                                        cur_instrument_rows.fb_order_seq);
                          vn_fb_log_count := vn_fb_log_count + 1;
                        end if;
                        vc_tbl(i).price := 0;
                        vc_tbl(i).vd_avl_price_date := null;
                      when others then
                        if vc_tbl(i).isholiday = 'N' then
                          vc_inst_price_status_flag := 'Error';
                          vc_drid_name              := to_char(vc_tbl(i)
                                                               .tradedate,
                                                               'dd-Mon-yyyy');
                          vc_instrument_name        := 'Spot , ' ||
                                                       cur_instrument_rows.
                                                       instrument_name;
                          vobj_fb_log.extend;
                          vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                        cur_setup_rows.corporate_id,
                                                                        cur_setup_rows.trade_date,
                                                                        'procedure sp_calculate_formula_price',
                                                                        'CDC-003',
                                                                        vc_instrument_name || ', ' ||
                                                                        vc_drid_name ||
                                                                        ', Price Source: ' ||
                                                                        cur_instrument_rows.price_source_name || ',' ||
                                                                        ' Required Quotes for Date: ' ||
                                                                        to_char(vc_tbl(i)
                                                                                .tradedate,
                                                                                'dd-Mon-YYYY'),
                                                                        'Q3',
                                                                        null,
                                                                        sysdate,
                                                                        'Error',
                                                                        cur_instrument_rows.fb_order_seq);
                          vn_fb_log_count := vn_fb_log_count + 1;
                        end if;
                        vc_tbl(i).price := 0;
                        vc_tbl(i).vd_avl_price_date := null;
                    end;
                    --SPOT Price Calculation ENDS here
                  elsif cur_instrument_rows.is_spot_instrument <> 'Y' and
                        cur_instrument_rows.product_type_id <> 'Freight' then
                    vc_record_error := 'N';
                    if cur_instrument_rows.instrument_type = 'Average' then
                      vc_instrument_id   := cur_instrument_rows.underlying_instrument_id;
                      vc_instrument_name := cur_instrument_rows.underlying_instrument_name;
                    else
                      vc_instrument_id   := cur_instrument_rows.instrument_id;
                      vc_instrument_name := cur_instrument_rows.instrument_name;
                    end if;
                    --get the price as per the instrument defined
                        --non prompt day check added, for npd consider substitute day price if specified
                  if vn_cal_npd_count <> 0  and vc_tbl(i).isholiday = 'N' then
                     vd_valid_trade_date := fn_get_substitute_dt_for_npd(cur_instrument_rows.delivery_calender_id,
                                                       vc_tbl(i).tradedate);
                   else
                     vd_valid_trade_date := vc_tbl(i).tradedate;
                  end if;
                 
                    begin
                      select price,
                             price_unit_id,
                             trade_date
                        into vc_tbl(i) .price,
                             vc_tbl(i) .price_unit_id,
                             vc_tbl(i) .vd_avl_price_date
                        from (select dqd.price,
                                     dqd.price_unit_id,
                                     dq.trade_date,
                                     rank() over(order by dq.trade_date desc nulls last) as td_rank
                                from dqd_derivative_quote_detail dqd,
                                     dq_derivative_quotes        dq,
                                     apm_available_price_master  apm
                               where dqd.dq_id = dq.dq_id
                                 and dqd.available_price_id =
                                     apm.available_price_id
                                 and dq.corporate_id =
                                     cur_setup_rows.corporate_id
                                 and dq.trade_date <= vd_valid_trade_date --vc_tbl(i).tradedate
                                 and dq.instrument_id = vc_instrument_id
                                 and dq.trade_date <= vd_trade_date
                                 and dqd.price_unit_id =
                                     cur_instrument_rows.quotes_price_unit_id
                                 and dq.price_source_id =
                                     cur_instrument_rows.price_source_id
                                 and dqd.dr_id = vc_tbl(i).drid
                                 and dq.is_deleted = 'N'
                                 and dqd.is_deleted = 'N'
                                 and nvl(dqd.price, 0) <> 0
                                 and apm.available_price_name =
                                     pc_price_name)
                       where td_rank = 1;
                      if cur_instrument_rows.fx_rate_type <> 'Fixed' then
                        vn_fxrate := f_get_converted_currency_amt(cur_setup_rows.corporate_id,
                                                                  cur_instrument_rows.cur_id,
                                                                  cur_setup_rows.cur_id,
                                                                  vc_tbl(i).tradedate,
                                                                  1);
                        vc_tbl(i).fx_rate := vn_fxrate;
                      else
                        vc_tbl(i).fx_rate := 0;
                      end if;
                      if vc_tbl(i).vd_avl_price_date <> vd_valid_trade_date and vc_tbl(i).isholiday = 'N' then
                        if vc_inst_price_status_flag <> 'Error' then
                          vc_inst_price_status_flag := 'Provisional';
                        end if;
                        -- vc_instrument_name
                        if vc_tbl(i).drid is not null then
                          vc_drid_name := fn_get_drid_name(vc_tbl(i).drid);
                        else
                          vc_drid_name := vc_tbl(i).drid;
                        end if;
                        vobj_fb_log.extend;
                        vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                      cur_setup_rows.corporate_id,
                                                                      cur_setup_rows.trade_date,
                                                                      'procedure sp_calculate_formula_price',
                                                                      'CDC-003',
                                                                      vc_instrument_name || ', ' ||
                                                                      vc_drid_name ||
                                                                      ', Price Source: ' ||
                                                                      cur_instrument_rows.price_source_name || ',' ||
                                                                      ' Current Quotes available for Date: ' ||
                                                                      to_char(vc_tbl(i).vd_avl_price_date,
                                                                              'dd-Mon-YYYY') || ',' ||
                                                                      ' Required Quotes for Date: ' ||
                                                                      to_char(vd_valid_trade_date,'dd-Mon-YYYY'),
                                                                      'Q1',
                                                                      null,
                                                                      sysdate,
                                                                      'Warning',
                                                                      cur_instrument_rows.fb_order_seq);
                        vn_fb_log_count := vn_fb_log_count + 1;
                      end if;
                    exception
                      when no_data_found then
                        if cur_instrument_rows.off_day_price = 'Skip' then
                          if (vc_tbl(i).tradedate <=  cur_instrument_rows.period_to_date and
                              vc_tbl(i).tradedate >= cur_instrument_rows.period_from_date) then
                            vc_record_error := 'Y';
                          else
                            vc_record_error := 'N';
                          end if;
                        elsif cur_instrument_rows.off_day_price =
                              'Last Day Repeat' then
                          if (vc_tbl(i).tradedate <=
                              cur_instrument_rows.period_to_date and
                              vc_tbl(i).tradedate >=
                              cur_instrument_rows.period_from_date) then
                            vc_record_error := 'Y';
                          else
                            vc_record_error := 'N';
                          end if;
                        else
                          vc_record_error := 'Y';
                        end if;                      
                        if vc_tbl(i)
                        .isholiday = 'N' and vc_record_error = 'Y' then
                          vc_inst_price_status_flag := 'Error';
                          if vc_tbl(i).drid is not null then
                            vc_drid_name := fn_get_drid_name(vc_tbl(i).drid);
                          else
                            vc_drid_name := vc_tbl(i).drid;
                          end if;
                          if vc_drid_name is null then
                            vc_drid_name := 'Month not available';
                            -- vc_drid_name:= to_char(vd_first_wkg_date,'dd-Mon-yyyy')||'-'|| cur_instrument_rows.instrument_id;
                          end if;
                          if vc_tbl(i).tradedate > vd_trade_date then
                            vc_price_date_display := to_char(vd_trade_date,
                                                             'dd-Mon-yyyy');
                          else
                            vc_price_date_display := to_char(vc_tbl(i)
                                                             .tradedate,
                                                             'dd-Mon-yyyy');
                          end if;                        
                          if vc_prev_day <> vc_price_date_display then
                            vc_prev_day := vc_price_date_display;
                            vobj_fb_log.extend;
                            vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                          cur_setup_rows.corporate_id,
                                                                          cur_setup_rows.trade_date,
                                                                          'procedure sp_calculate_formula_price',
                                                                          'CDC-003',
                                                                          vc_instrument_name || ', ' ||
                                                                          vc_drid_name ||
                                                                          ', Price Source: ' ||
                                                                          cur_instrument_rows.price_source_name || ',' ||
                                                                          ' Required Quotes for Date: ' ||
                                                                          vc_price_date_display,
                                                                          'Q2',
                                                                          null,
                                                                          sysdate,
                                                                          'Error',
                                                                          cur_instrument_rows.fb_order_seq);
                            vn_fb_log_count := vn_fb_log_count + 1;
                          end if;
                        end if;                      
                        vc_tbl(i).price := 0;
                        vc_tbl(i).price_unit_id := null;
                        vc_tbl(i).vd_avl_price_date := null;
                      when others then
                        if cur_instrument_rows.off_day_price = 'Skip' then
                          if (vc_tbl(i).tradedate <=
                              cur_instrument_rows.period_to_date and
                              vc_tbl(i).tradedate >=
                              cur_instrument_rows.period_from_date) then
                            vc_record_error := 'Y';
                          else
                            vc_record_error := 'N';
                          end if;
                        elsif cur_instrument_rows.off_day_price =
                              'Last Day Repeat' then
                          if (vc_tbl(i).tradedate <=
                              cur_instrument_rows.period_to_date and
                              vc_tbl(i).tradedate >=
                              cur_instrument_rows.period_from_date) then
                            vc_record_error := 'Y';
                          else
                            vc_record_error := 'N';
                          end if;
                        else
                          vc_record_error := 'Y';
                        end if;                      
                        if vc_tbl(i)
                        .isholiday = 'N' and vc_record_error = 'Y' then
                          vc_inst_price_status_flag := 'Error';
                          if vc_tbl(i).drid is not null then
                            vc_drid_name := fn_get_drid_name(vc_tbl(i).drid);
                          else
                            vc_drid_name := vc_tbl(i).drid;
                          end if;
                          if vc_tbl(i).tradedate > vd_trade_date then
                            vc_price_date_display := to_char(vd_trade_date,
                                                             'dd-Mon-yyyy');
                          else
                            vc_price_date_display := to_char(vc_tbl(i)
                                                             .tradedate,
                                                             'dd-Mon-yyyy');
                          end if;
                          vobj_fb_log.extend;
                          vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                        cur_setup_rows.corporate_id,
                                                                        cur_setup_rows.trade_date,
                                                                        'procedure sp_calculate_formula_price',
                                                                        'CDC-003',
                                                                        vc_instrument_name || ', ' ||
                                                                        vc_drid_name ||
                                                                        ', Price Source: ' ||
                                                                        cur_instrument_rows.price_source_name || ',' ||
                                                                        ' Required Quotes for Date: ' ||
                                                                        vc_price_date_display,
                                                                        'Q3-1',
                                                                        null,
                                                                        sysdate,
                                                                        'Error',
                                                                        cur_instrument_rows.fb_order_seq);
                          vn_fb_log_count := vn_fb_log_count + 1;
                        end if;
                        vc_tbl(i).price := 0;
                        vc_tbl(i).price_unit_id := null;
                        vc_tbl(i).vd_avl_price_date := null;
                    end;
                  else
                    ---- FFA TRades                  
                    begin
                      select spot_price,
                             spot_price_unit_id,
                             trade_date
                        into vc_tbl(i) .price,
                             vc_tbl(i) .price_unit_id,
                             vc_tbl(i) .vd_avl_price_date
                        from (select fq.spot_price,
                                     fq.spot_price_unit_id,
                                     fq.trade_date,
                                     rank() over(order by fq.trade_date desc nulls last) as td_rank
                                from fq_freight_quotes fq
                               where fq.corporate_id =
                                     cur_setup_rows.corporate_id
                                 and fq.trade_date <= vc_tbl(i)
                              .tradedate
                                 and fq.instrument_id =
                                     cur_instrument_rows.instrument_id
                                 and fq.trade_date <= vd_trade_date
                                 and fq.spot_price_unit_id =
                                     cur_instrument_rows.quotes_price_unit_id
                                 and fq.price_source_id =
                                     cur_instrument_rows.price_source_id
                                 and fq.is_deleted = 'N'
                                 and nvl(fq.spot_price, 0) <> 0)
                       where td_rank = 1;
                      if cur_instrument_rows.fx_rate_type <> 'Fixed' then
                        vn_fxrate := f_get_converted_currency_amt(cur_setup_rows.corporate_id,
                                                                  cur_instrument_rows.cur_id,
                                                                  cur_setup_rows.cur_id,
                                                                  vc_tbl(i)
                                                                  .tradedate,
                                                                  1);
                        vc_tbl(i).fx_rate := vn_fxrate;
                      else
                        vc_tbl(i).fx_rate := cur_instrument_rows.fx_rate;
                      end if;
                      if vc_tbl(i).vd_avl_price_date <> vc_tbl(i)
                      .tradedate and vc_tbl(i).isholiday = 'N' then
                        if vc_inst_price_status_flag <> 'Error' then
                          vc_inst_price_status_flag := 'Provisional';
                        end if;
                        vc_drid_name       := to_char(vc_tbl(i).tradedate,
                                                      'dd-Mon-yyyy');
                        vc_instrument_name := cur_instrument_rows.instrument_name;
                        vobj_fb_log.extend;
                        vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                      cur_setup_rows.corporate_id,
                                                                      cur_setup_rows.trade_date,
                                                                      'procedure sp_calculate_formula_price',
                                                                      'CDC-003',
                                                                      vc_instrument_name || ', ' ||
                                                                      vc_drid_name ||
                                                                      ', Price Source: ' ||
                                                                      cur_instrument_rows.price_source_name || ',' ||
                                                                      ' Current Quotes available for Date: ' ||
                                                                      to_char(vc_tbl(i)
                                                                              .vd_avl_price_date,
                                                                              'dd-Mon-YYYY') || ',' ||
                                                                      ' Required Quotes for Date: ' ||
                                                                      to_char(vc_tbl(i)
                                                                              .tradedate,
                                                                              'dd-Mon-YYYY'),
                                                                      'Q1',
                                                                      null,
                                                                      sysdate,
                                                                      'Warning',
                                                                      cur_instrument_rows.fb_order_seq);
                        vn_fb_log_count := vn_fb_log_count + 1;
                      end if;
                    exception
                      when no_data_found then
                        if vc_tbl(i).isholiday = 'N' then
                          vc_inst_price_status_flag := 'Error';
                          vc_drid_name              := to_char(vc_tbl(i)
                                                               .tradedate,
                                                               'dd-Mon-yyyy');
                          vc_instrument_name        := cur_instrument_rows.instrument_name;
                          vobj_fb_log.extend;
                          vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                        cur_setup_rows.corporate_id,
                                                                        cur_setup_rows.trade_date,
                                                                        'procedure sp_calculate_formula_price',
                                                                        'CDC-003',
                                                                        vc_instrument_name || ', ' ||
                                                                        vc_drid_name ||
                                                                        ', Price Source: ' ||
                                                                        cur_instrument_rows.price_source_name || ',' ||
                                                                        ' Required Quotes for Date: ' ||
                                                                        to_char(vc_tbl(i)
                                                                                .tradedate,
                                                                                'dd-Mon-YYYY'),
                                                                        'Q2',
                                                                        null,
                                                                        sysdate,
                                                                        'Error',
                                                                        cur_instrument_rows.fb_order_seq);
                          vn_fb_log_count := vn_fb_log_count + 1;
                        end if;
                        vc_tbl(i).price := 0;
                        vc_tbl(i).vd_avl_price_date := null;
                      when others then
                        if vc_tbl(i).isholiday = 'N' then
                          vc_inst_price_status_flag := 'Error';
                          vc_drid_name              := to_char(vc_tbl(i)
                                                               .tradedate,
                                                               'dd-Mon-yyyy');
                          vc_instrument_name        := cur_instrument_rows.instrument_name;
                          vobj_fb_log.extend;
                          vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                                        cur_setup_rows.corporate_id,
                                                                        cur_setup_rows.trade_date,
                                                                        'procedure sp_calculate_formula_price',
                                                                        'CDC-003',
                                                                        vc_instrument_name || ', ' ||
                                                                        vc_drid_name ||
                                                                        ', Price Source: ' ||
                                                                        cur_instrument_rows.price_source_name || ',' ||
                                                                        ' Required Quotes for Date: ' ||
                                                                        to_char(vc_tbl(i)
                                                                                .tradedate,
                                                                                'dd-Mon-YYYY'),
                                                                        'Q3',
                                                                        null,
                                                                        sysdate,
                                                                        'Error',
                                                                        cur_instrument_rows.fb_order_seq);
                          vn_fb_log_count := vn_fb_log_count + 1;
                        end if;
                        vc_tbl(i).price := 0;
                        vc_tbl(i).vd_avl_price_date := null;
                    end;
                  end if;
                  /*END OF PRICE*/
                end loop;
                vn_row := 1;
                /*PRICE FOR FIRST DAY REPEAT                    */
                if cur_instrument_rows.off_day_price = 'First Day Repeat' then
                  for i in vc_tbl.first .. vc_tbl.last
                  loop
                    vn_first_count := vc_tbl.first;
                    if vc_tbl(i).isholiday = 'Y' then
                      vc_tbl(i).drid := vc_tbl(vn_first_count).drid;
                      vc_tbl(i).price := vc_tbl(vn_first_count).price;
                      vc_tbl(i).price_unit_id := vc_tbl(vn_first_count)
                                                .price_unit_id;
                      vc_tbl(i).vd_avl_price_date := vc_tbl(vn_first_count)
                                                    .vd_avl_price_date;
                    end if;
                  end loop;
                  /*PRICE FOR LAST DAY REPEAT                    */
                elsif cur_instrument_rows.off_day_price = 'Last Day Repeat' then
                  for i in vc_tbl.first .. vc_tbl.last
                  loop
                    vn_last_count := vc_tbl.last;
                    if vc_tbl(i).isholiday = 'Y' then
                      vc_tbl(i).drid := vc_tbl(vn_last_count).drid;
                      vc_tbl(i).price := vc_tbl(vn_last_count).price;
                      vc_tbl(i).price_unit_id := vc_tbl(vn_last_count)
                                                .price_unit_id;
                      vc_tbl(i).vd_avl_price_date := vc_tbl(vn_last_count)
                                                    .vd_avl_price_date;
                    end if;
                  end loop;
                  /*PRICE FOR SKIP REPEAT                    */
                elsif cur_instrument_rows.off_day_price = 'Skip' then
                  vn_dummy_price := 0;
                  vn_counter     := 1;
                  for i in vc_tbl.first .. vc_tbl.last
                  loop
                    if vc_tbl(i).isholiday = 'Y' and vc_tbl(i)
                    .tradedate = pd_event_date then
                    
                      while vn_dummy_price = 0
                      loop
                        vc_tbl(i).drid := vc_tbl(i - vn_counter).drid;
                        vc_tbl(i).price := vc_tbl(i - vn_counter).price;
                        vc_tbl(i).price_unit_id := vc_tbl(i - vn_counter)
                                                  .price_unit_id;
                        vc_tbl(i).vd_avl_price_date := vc_tbl(i -
                                                              vn_counter)
                                                      .vd_avl_price_date;
                        vn_dummy_price := vc_tbl(i - vn_counter).price;
                        if vn_dummy_price is null then
                          vn_dummy_price := 0;
                        end if;
                        vn_counter := vn_counter + 1;
                      end loop;
                    
                    elsif vc_tbl(i).isholiday = 'Y' then
                      vc_tbl(i).drid := vc_tbl(1).drid;
                      vc_tbl(i).price := null;
                      vc_tbl(i).price_unit_id := vc_tbl(1).price_unit_id;
                    end if;
                  end loop;
                  /*PRICE FOR PREVIOUS DAY REPEAT                    */
                elsif cur_instrument_rows.off_day_price =
                      'Previous Day Repeat' then
                  for i in vc_tbl.first .. vc_tbl.last
                  loop
                    if vc_tbl(i).isholiday = 'Y' then
                      vc_tbl(i).drid := vc_tbl(i - 1).drid;
                      vc_tbl(i).price := vc_tbl(i - 1).price;
                      vc_tbl(i).price_unit_id := vc_tbl(i - 1)
                                                .price_unit_id;
                      vc_tbl(i).vd_avl_price_date := vc_tbl(i - 1)
                                                    .vd_avl_price_date;
                    end if;
                  end loop;
                  /*PRICE FOR NEXT DAY REPEAT                    */
                elsif cur_instrument_rows.off_day_price = 'Next Day Repeat' then
                  for i in vc_tbl.first .. vc_tbl.last
                  loop
                    if vc_tbl(i).isholiday = 'Y' then
                      j := i;
                      while true
                      loop
                        if vc_tbl(j).isholiday = 'Y' then
                          j := j + 1;
                        else
                          exit;
                        end if;
                      end loop;
                      vc_tbl(i).drid := vc_tbl(j).drid;
                      vc_tbl(i).price := vc_tbl(j).price;
                      vc_tbl(i).price_unit_id := vc_tbl(j).price_unit_id;
                      vc_tbl(i).vd_avl_price_date := vc_tbl(j)
                                                    .vd_avl_price_date;
                    end if;
                  end loop;
                end if;
                for i in vc_tbl.first .. vc_tbl.last
                loop
                  if vc_tbl(i).tradedate >= vd_qp_start_date and vc_tbl(i)
                  .tradedate <= vd_qp_end_date then
                    --                dbms_output.put_line('i = ' || i || ' trade date ' ||to_char(vc_tbl(i).tradedate,'dd-Mon-yyyy') || ' vc_tbl(i).price '||vc_tbl(i).price  ||' Is holiday : '||vc_tbl(i).isholiday );                
                    if vc_tbl(i).price is not null then
                      vn_instrument_sum           := vn_instrument_sum +
                                                     vc_tbl(i).price;
                      vn_instrumnet_cnt           := vn_instrumnet_cnt + 1;
                      vc_instrument_price_unit_id := vc_tbl(i)
                                                    .price_unit_id;
                      if cur_instrument_rows.fx_rate_type <> 'Fixed' and
                         vc_tbl(i).fx_rate <> 0 then
                        vn_instrument_fxsum := vn_instrument_fxsum +
                                               vc_tbl(i).fx_rate;
                        vn_instrumnet_fxcnt := vn_instrumnet_fxcnt + 1;
                      end if;
                    end if;
                  end if;
                end loop;
                if vn_instrumnet_cnt <> 0 then
                  vn_instrument_avg := round(vn_instrument_sum /
                                             vn_instrumnet_cnt,
                                             4);
                else
                  vn_instrument_avg := 0;
                end if;
              
                if nvl(cur_instrument_rows.fx_rate_type, 'Fixed') <>
                   'Fixed' then
                  if vn_instrumnet_fxcnt <> 0 then
                    vn_instrument_fxavg := nvl(round(vn_instrument_fxsum /
                                                     vn_instrumnet_fxcnt,
                                                     8),
                                               1);
                  else
                    vn_instrument_fxavg := 1;
                  end if;
                else
                  vn_instrument_fxavg := nvl(cur_instrument_rows.fx_rate, 1);
                end if;
              end if; --if vc_inst_price_status_flag <> 'Error' end here --
              if vc_inst_price_status_flag = 'Error' then
                vn_instrument_avg   := 0;
                vn_instrument_fxavg := 0;
              end if;
              if vd_trade_date >= vd_last_date then
                vc_inst_price_qp_status := 'Fixed';
              else
                vc_inst_price_qp_status := 'Not Fixed';
              end if;
              --Ashok S
              begin
                --For Fixed
                if cur_instrument_rows.fx_rate_type = 'Fixed' then
                  vn_instrument_temp_avg     := vn_instrument_avg +
                                                cur_instrument_rows.basis;
                  vn_instrument_temp_avg_ret := vn_instrument_temp_avg *
                                                cur_instrument_rows.fx_rate;
                else
                  vn_instrument_temp_avg := vn_instrument_avg +
                                            cur_instrument_rows.basis;
                  if vn_instrument_fxavg <> 0 then
                    vn_instrument_temp_avg_ret := vn_instrument_temp_avg *
                                                  vn_instrument_fxavg;
                  else
                    vn_instrument_temp_avg_ret := vn_instrument_temp_avg;
                  end if;
                end if;
              exception
                when others then
                  dbms_output.put_line('Error found');
              end;
              --added by siva
              vn_row := 1;
              for i in vc_tbl.first .. vc_tbl.last
              loop
                if vc_tbl(i).tradedate >= vd_qp_start_date and vc_tbl(i)
                .tradedate <= vd_qp_end_date then
                  vc_tbl_out.extend;
                  vc_tbl_out(vn_row) := tp_obj_formula(vc_tbl(i).tradedate,
                                                       vc_tbl(i)
                                                       .instrumentid,
                                                       vc_tbl(i).isholiday,
                                                       vc_tbl(i).drid,
                                                       vc_tbl(i).price,
                                                       vc_tbl(i)
                                                       .vd_avl_price_date,
                                                       vc_tbl(i).fx_rate,
                                                       vc_tbl(i)
                                                       .fb_off_day_price,
                                                       vc_tbl(i)
                                                       .price_unit_id,
                                                       vc_tbl(i).avg_fx_rate,
                                                       vc_tbl(i)
                                                       .price_exp_status,
                                                       vc_tbl(i)
                                                       .exp_quantity,
                                                       vc_tbl(i)
                                                       .exp_quantity_unit_id,
                                                       vc_tbl(i).exp_value,
                                                       vc_tbl(i).exp_cur_id);
                  vn_row := vn_row + 1;
                end if;
              end loop;
              if vc_inst_basis_price_unit_id is null then
                vc_inst_basis_price_unit_id := vc_instrument_price_unit_id;
              end if;            
              vc_inst_tbl.extend;
              vc_inst_tbl(vn_avg_cnt) := fb_typ_instrument_data(cur_instrument_rows.
                                                                fb_order_seq,
                                                                cur_instrument_rows.formula_id,
                                                                cur_instrument_rows.orginal_instrument_id,
                                                                cur_instrument_rows.price_source_id,
                                                                cur_instrument_rows.price_point_id,
                                                                cur_instrument_rows.available_price_id,
                                                                cur_instrument_rows.fb_period_type,
                                                                cur_instrument_rows.fb_period_sub_type,
                                                                cur_instrument_rows.period_month,
                                                                cur_instrument_rows.period_year,
                                                                cur_instrument_rows.period_from_date,
                                                                cur_instrument_rows.period_to_date,
                                                                cur_instrument_rows.no_of_months,
                                                                cur_instrument_rows.no_of_days,
                                                                cur_instrument_rows.period_type_id,
                                                                cur_instrument_rows.delivery_period_id,
                                                                cur_instrument_rows.off_day_price,
                                                                cur_instrument_rows.basis,
                                                                vc_inst_basis_price_unit_id,
                                                                cur_instrument_rows.fx_rate_type, --fixed
                                                                cur_instrument_rows.fx_rate, --2nd
                                                                vn_instrument_avg, -- vn_instrument_avg,
                                                                vn_instrument_fxavg, --inst_avg_fx_rate,
                                                                vn_instrument_temp_avg_ret, -- inst_avg_conv_price,
                                                                vc_inst_price_status_flag,
                                                                vc_inst_price_qp_status,
                                                                vc_tbl_out);
              vn_avg_cnt := vn_avg_cnt + 1;
              vn_instrumnet_cnt := 0;
              vn_instrument_sum := 0;
              /*  for displaying the data in the types            */
            end if;
          end loop; --end of instrument loop
        end if;
        if vc_set_basis_price_unit_id is null then
          vc_set_basis_price_unit_id := vc_inst_basis_price_unit_id;
        end if;
        vobj_fb_tbl_setup.extend;
        vobj_fb_tbl_setup(vn_setup_row) := fb_typ_setup(cur_setup_rows.formula_id,
                                                        cur_setup_rows.corporate_id,
                                                        cur_setup_rows.formula_name,
                                                        cur_setup_rows.formula_display,
                                                        cur_setup_rows.formula_internal,
                                                        vc_set_basis_price_unit_id,
                                                        cur_setup_rows.trade_date,
                                                        null, -- fb_price,
                                                        null, --fb_price_staus,
                                                        null, --fb_price_qp_status,
                                                        null --fb_price_log_id
                                                        );
        vn_setup_row := vn_setup_row + 1;     
      end loop; --end of setup loop
    end if;
    --  vc_setup_price_status_flag := vc_final_price_status_flag;
    if vc_inst_tbl.exists(1) and vobj_fb_tbl_setup.exists(1) then
      for i in vc_inst_tbl.first .. vc_inst_tbl.last
      loop
        if vc_final_price_status_flag <> 'Error' then
          if vc_final_price_status_flag <> 'Provisional' then
            vc_final_price_status_flag := vc_inst_tbl(i).price_status;
          end if;
        end if;
        if vc_final_qp_status_flag <> 'Not Fixed' then
          vc_final_qp_status_flag := vc_inst_tbl(i).price_qp_status;
        end if;
      end loop;
    -- dbms_output.put_line('vc_final_price_status_flag start '|| vc_final_price_status_flag);      
      /*for displaying the price in day wise of the formula*/
      /* calculating the formula for the per day  wise
      calculating the price for the each day of the  instrument*/
      vn_temp_day_price := null;
      begin
        for i in vc_inst_tbl(1).v_tbl_formula.first .. vc_inst_tbl(1)
                                                      .v_tbl_formula.last
        loop
           begin
                select count(*)
                  into vn_cal_npd_count
                  from npd_non_prompt_calendar_days npd,
                       dim_der_instrument_master dim
                 where npd.prompt_delivery_calendar_id = dim.delivery_calender_id
                 and dim.instrument_id = vc_inst_tbl(1).instrument_id
                 and npd.is_deleted = 'N';
           exception
                when no_data_found then
                  vn_cal_npd_count := 0;
                when others then
                  vn_cal_npd_count := 0;
           end;  
          vc_tbl_daywise.extend;
          vc_formula_exe := vc_formula;
          for vn_inst_total in 1 .. vc_inst_tbl.last
          loop
            --    dbms_output.put_line('Day wise start 0 : '|| vc_formula_exe);
            vn_srt_psn := instr(vc_formula_exe, '$', 1);
            vn_end_psn := instr(vc_formula_exe, '$', 1, 2);
            --  dbms_output.put_line('Day wise start 1 : '|| vc_formula_exe);
            if vn_srt_psn > 0 then
              if vc_inst_tbl(vn_inst_total).v_tbl_formula(i)
              .price is null or vc_inst_tbl(vn_inst_total)
              .v_tbl_formula(i).price = '' then
                vn_temp_day_price := null;
              else
                vn_temp_day_price := vc_inst_tbl(vn_inst_total)
                                    .v_tbl_formula(i).price;
              end if;
              if vn_temp_day_price is null then
                vc_formula_exe := substr(vc_formula_exe, 1, vn_srt_psn - 1) ||
                                  'null' ||
                                  substr(vc_formula_exe, vn_end_psn + 1);
              else
                vc_formula_exe := substr(vc_formula_exe, 1, vn_srt_psn - 1) ||
                                  vn_temp_day_price ||
                                  substr(vc_formula_exe, vn_end_psn + 1);
              end if;
            end if;
--            vc_inst_tbl(vn_inst_total).
            --  dbms_output.put_line(vc_formula_exe);
             if vn_cal_npd_count= 0 then
                vd_valid_trade_date := vc_inst_tbl(vn_inst_total).v_tbl_formula(i).tradedate;
             else
                vd_valid_trade_date := fn_get_substitute_inst_npd(vc_inst_tbl(1).instrument_id,
                vc_inst_tbl(vn_inst_total).v_tbl_formula(i).tradedate);
             end if;
           --  dbms_output.put_line(vc_inst_tbl(vn_inst_total).v_tbl_formula(i).tradedate || ' valid date : '||vd_valid_trade_date);
              if vc_inst_tbl(vn_inst_total).v_tbl_formula(i).vd_avl_price_date = vd_valid_trade_date then
                 if vc_inst_tbl(vn_inst_total).v_tbl_formula(i).isholiday = 'N' then
                    if vc_day_final_price_status <> 'Provisional' then
                      vc_day_final_price_status := 'Final';
                    end if;
                  end if;
              else
                if vc_inst_tbl(vn_inst_total).v_tbl_formula(i).isholiday = 'N' then
                  if vc_day_final_price_status <> 'Provisional' then
                    vc_day_final_price_status := 'Provisional';
                  end if;
                end if;
              end if;
          --   dbms_output.put_line('vc_day_final_price_status '|| vc_day_final_price_status);          
          end loop;
          --    dbms_output.put_line('Day wise : ' || vc_formula_exe);
          if vc_inst_tbl(1).v_tbl_formula(i)
          .exp_cur_id = 'Y' and vc_inst_tbl(1).off_day_price = 'Skip' then
            vn_daywise_price := 0;
          else
            vn_daywise_price := fn_execute_internal_formula(vc_formula_exe);
          end if;
          vc_tbl_daywise(i) := tp_obj_formula(vc_inst_tbl(1)
                                              .v_tbl_formula(i).tradedate,
                                              null,
                                              vc_inst_tbl(1)
                                              .v_tbl_formula(i).exp_cur_id, -- .isholiday, --siva: exp_cur_id column used to store the instrument level hoilday or not 
                                              null,
                                              vn_daywise_price, --price
                                              null,
                                              null,
                                              vc_inst_tbl(1)
                                              .v_tbl_formula(i)
                                              .fb_off_day_price,
                                              vc_inst_tbl(1)
                                              .v_tbl_formula(i).price_unit_id,
                                              vc_inst_tbl(1)
                                              .v_tbl_formula(i).avg_fx_rate,
                                              vc_day_final_price_status,
                                              null,
                                              null,
                                              null,
                                              null);
          /*                 end of setting the values to the formula day wise type     */
        end loop;
      exception
        when others then
          dbms_output.put_line('The error is  ' || sqlerrm);
          -- vn_daywise_price := 0;
      end;
      /* calculating the formula for the whole instrument wise
      calculating the price for the total instrument*/
      for i in vc_inst_tbl.first .. vc_inst_tbl.last
      loop
        vn_srt_psn    := instr(vc_formula, '$', 1);
        vn_end_psn    := instr(vc_formula, '$', 1, 2);
        vn_srt_fx_psn := instr(vc_fx_formula, '$', 1);
        vn_end_fx_psn := instr(vc_fx_formula, '$', 1, 2);
        if vn_srt_psn > 0 then
          vc_formula := substr(vc_formula, 1, vn_srt_psn - 1) ||
                        vc_inst_tbl(i).inst_avg_conv_price ||
                        substr(vc_formula, vn_end_psn + 1);
        end if;
      end loop;
      -- dbms_output.put_line('The fx formula is       ' || vc_fx_formula);
      --Runing the average price formula.
      if vc_final_price_status_flag <> 'Error' then
        begin
          vc_sql_temp := vc_formula;
          --dbms_output.put_line(' Final formula is ' || vc_sql_temp);
          vn_average := fn_execute_internal_formula(vc_sql_temp);
        exception
          when others then
            vn_average := -1;
            vobj_fb_log.extend;
            vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                          vc_corporate_id,
                                                          vd_trade_date,
                                                          'procedure sp_calculate_formula_price',
                                                          'CDC-004',
                                                          'Error while executing SQL Statement : ' ||
                                                          vc_sql_temp,
                                                          'E1',
                                                          null,
                                                          sysdate,
                                                          'Error',
                                                          vc_formula_id);
            vn_fb_log_count := vn_fb_log_count + 1;
        end;
      end if;
      --updating t he object type.
      vobj_fb_tbl_setup(1).fb_price := vn_average;
      vobj_fb_tbl_setup(1).fb_price_log_id := vn_fb_log_id;
      vobj_fb_tbl_setup(1).fb_price_staus := vc_final_price_status_flag;-- vc_final_price_status_flag variable
      vobj_fb_tbl_setup(1).fb_price_qp_status := vc_final_qp_status_flag;
      -- vc_inst_tbl(1).inst_avg_fx_rate := vn_fx_avg; --Storing the fx avg price.
    else
      --updating t he object type.
      vobj_fb_tbl_setup(1).fb_price := 0;
      vobj_fb_tbl_setup(1).fb_price_log_id := vn_fb_log_id;
      vobj_fb_tbl_setup(1).fb_price_staus := 'Error';
      vobj_fb_tbl_setup(1).fb_price_qp_status := 'Not Fixed';
    end if;
    sp_insert_fb_log(vobj_fb_log);
    -- dbms_output.put_line('Error log has ' || vobj_fb_log.count);*/
    pc_fb_log_id      := vn_fb_log_id;
    pobj_out_fb_setup := fb_tbl_setup();
    pobj_out_fb_setup.extend;
    pobj_out_fb_setup            := vobj_fb_tbl_setup;
    pobj_out_fb_instrument_data  := vc_inst_tbl;
    pobj_out_fb_price_by_formula := vc_tbl_daywise;
    pobj_out_fb_tbl_error        := vobj_fb_log;  
  exception
    when no_data_found then
      vobj_fb_log.extend;
      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                    vc_corporate_id,
                                                    vd_trade_date,
                                                    'procedure sp_calculate_formula_price',
                                                    'CDC-004',
                                                    'Error while executing sp_calculate_formula_price, Code:' ||
                                                    sqlcode || 'Message:' ||
                                                    sqlerrm,
                                                    'E2',
                                                    null,
                                                    sysdate,
                                                    'Error',
                                                    vc_formula_id);
      sp_insert_fb_log(vobj_fb_log);
    when others then
      vobj_fb_log.extend;
      vobj_fb_log(vn_fb_log_count) := fb_type_error(vn_fb_log_id,
                                                    vc_corporate_id,
                                                    vd_trade_date,
                                                    'procedure sp_calculate_formula_price',
                                                    'CDC-004',
                                                    'Error while executing sp_calculate_formula_price ' ||
                                                    ' Code:' || sqlcode ||
                                                    'Message:' || sqlerrm,
                                                    'E3',
                                                    null,
                                                    sysdate,
                                                    'Error',
                                                    vc_formula_id);
      sp_insert_fb_log(vobj_fb_log);
  end;
  procedure sp_insert_fb_log
  --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_insert_fb_log
    --        Author                                    : Siva
    --        Created Date                              : 10th Jan 2011
    --        Purpose                                   : Logs error for formula builder price calculation
    --        Parameters
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pobj_fb_tbl_log in fb_tbl_error) is
    pragma autonomous_transaction;
    cursor cur_err_log is
      select *
        from the (select cast(pobj_fb_tbl_log as fb_tbl_error) from dual);
  begin 
    for cur_err_log_rows in cur_err_log
    loop
      -- if (cur_err_log_rows.corporate_id) is not null then   (commentd by ashok )
      insert into fbpl_formula_builder_price_log
        (fbpl_id,
         corporate_id,
         submodule_name,
         exception_code,
         data_missing_for,
         trade_ref_no,
         process_run_by,
         process_run_date,
         trade_date,
         error_type,
         formula_inst_id)
      values
        (cur_err_log_rows.fbpl_id,
         cur_err_log_rows.corporate_id,
         cur_err_log_rows.submodule_name,
         cur_err_log_rows.exception_code,
         cur_err_log_rows.data_missing_for,
         cur_err_log_rows.trade_ref_no,
         cur_err_log_rows.process_run_by,
         cur_err_log_rows.process_run_date,
         cur_err_log_rows.trade_date,
         cur_err_log_rows.error_type,
         cur_err_log_rows.formula_inst_id);
      -- end if;
    end loop;
    commit;
  exception
    when others then
      rollback;
  end;
  procedure sp_insert_fb_data(pobj_in_fb_setup           in fb_tbl_setup,
                              pobj_in_fb_instrument_data in fb_tbl_instrument_data,
                              pc_fb_log_id               in varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_insert_fb_data
    --        Author                                    : Siva
    --        Created Date                              : 11th Mar 2011
    --        Purpose                                   : Logs formula builder price calculation data
    --        Parameters
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    pragma autonomous_transaction;
    cursor cur_fbs_log is
      select *
        from the (select cast(pobj_in_fb_setup as fb_tbl_setup) from dual);
    cursor cur_fbi_log is
      select *
        from the (select cast(pobj_in_fb_instrument_data as
                              fb_tbl_instrument_data)
                    from dual);
    vc_fb_price_status varchar2(25);
  begin
    vc_fb_price_status := null;
    for cur_fbs_log_rows in cur_fbs_log
    loop
      vc_fb_price_status := cur_fbs_log_rows.fb_price_staus;
      insert into fbpl_fb_setup_data_log
        (fbpl_id,
         formula_id,
         price_unit_id,
         trade_date,
         fb_price,
         fb_price_staus,
         fb_price_qp_status)
      values
        (pc_fb_log_id,
         cur_fbs_log_rows.formula_id,
         cur_fbs_log_rows.price_unit_id,
         cur_fbs_log_rows.trade_date,
         cur_fbs_log_rows.fb_price,
         cur_fbs_log_rows.fb_price_staus,
         cur_fbs_log_rows.fb_price_qp_status);
    end loop;
    for cur_fbi_log_rows in cur_fbi_log
    loop
      insert into fbpl_fb_inst_data_log
        (fbpl_id,
         formula_id,
         fb_order_seq,
         instrument_id,
         off_day_price,
         basis,
         basis_price_unit_id,
         fx_rate_type,
         fx_rate,
         inst_avg_price,
         inst_avg_fx_rate,
         inst_avg_conv_price,
         price_status,
         price_qp_status)
      values
        (pc_fb_log_id,
         cur_fbi_log_rows.formula_id,
         cur_fbi_log_rows.fb_order_seq,
         cur_fbi_log_rows.instrument_id,
         cur_fbi_log_rows.off_day_price,
         cur_fbi_log_rows.basis,
         cur_fbi_log_rows.basis_price_unit_id,
         cur_fbi_log_rows.fx_rate_type,
         cur_fbi_log_rows.fx_rate,
         cur_fbi_log_rows.inst_avg_price,
         cur_fbi_log_rows.inst_avg_fx_rate,
         cur_fbi_log_rows.inst_avg_conv_price,
         cur_fbi_log_rows.price_status,
         cur_fbi_log_rows.price_qp_status);
      if nvl(vc_fb_price_status, 'NA') <> 'Error' then
        if cur_fbi_log_rows.v_tbl_formula is not null then
          for cc in (select *
                       from the (select cast(cur_fbi_log_rows.v_tbl_formula as
                                             tp_tbl_formula)
                                   from dual))
          loop
            insert into fbpl_fb_inst_price_data_log
              (fbpl_id,
               fb_order_seq,
               instrument_id,
               price_date,
               dr_id,
               price,
               is_holiday,
               quotes_date,
               avg_fx_rate,
               price_unit_id)
            values
              (pc_fb_log_id,
               cur_fbi_log_rows.fb_order_seq,
               cc.instrumentid,
               cc.tradedate,
               cc.drid,
               cc.price,
               trim(cc.isholiday),
               cc.vd_avl_price_date,
               cc.fx_rate,
               null);
          end loop;
        end if;
      end if;
    end loop;
    commit;
  exception
    when others then
      commit;
  end;
  --inserting the formula data lop to the fbpl table
  procedure sp_insert_fbpl_data_by_formula(pobj_fb_formula in tp_tbl_formula,
                                           pc_fb_log_id    in varchar2) is
    pragma autonomous_transaction;
    cursor cur_fbs_formula is
      select *
        from the (select cast(pobj_fb_formula as tp_tbl_formula) from dual);
  begin
    for cc in cur_fbs_formula
    loop
      insert into fbpl_price_data_by_formula
        (fbpl_id,
         price_date,
         is_holiday,
         price,
         price_unit_id,
         avg_fx_rate,
         off_day_price,
         price_exp_status,
         remarks)
      values
        (pc_fb_log_id,
         cc.tradedate,
         trim(cc.isholiday),
         cc.price,
         cc.price_unit_id,
         cc.avg_fx_rate,
         cc.fb_off_day_price,
         cc.price_exp_status,
         null);
    end loop;
    commit;
  end;
  function f_get_converted_price(p_corporate_id       in varchar2,
                                 p_price              in number,
                                 p_from_price_unit_id in varchar2,
                                 p_to_price_unit_id   in varchar2,
                                 p_trade_date         in date) return number is
    result number;
  begin
    if p_from_price_unit_id = p_to_price_unit_id then
      return p_price;
    else
      select nvl(round(((((nvl((p_price), 0)) *
                       pkg_general.f_get_converted_currency_amt(p_corporate_id,
                                                                   pum1.cur_id,
                                                                   pum2.cur_id,
                                                                   p_trade_date,
                                                                   1)) /
                       ((ucm.multiplication_factor * nvl(pum1.weight, 1)) /
                       nvl(pum2.weight, 1)))),
                       5),
                 0)
        into result
        from ppu_product_price_units    ppu1,
             ppu_product_price_units    ppu2,
             ucm_unit_conversion_master ucm,
             pum_price_unit_master      pum1,
             pum_price_unit_master      pum2
       where /*ppu1.product_id = ppu2.product_id
                                                                                                                                                                                                                                                         and */
       ppu1.price_unit_id = p_from_price_unit_id
       and ppu2.price_unit_id = p_to_price_unit_id
       and pum1.price_unit_id(+) = ppu1.price_unit_id
       and pum2.price_unit_id(+) = ppu2.price_unit_id
       and pum1.weight_unit_id = ucm.from_qty_unit_id
       and pum2.weight_unit_id = ucm.to_qty_unit_id
       and pum1.is_deleted = 'N'
       and pum2.is_deleted = 'N'
       and ppu1.is_deleted = 'N'
       and ppu2.is_deleted = 'N';   
      return(result);
    end if;
  end f_get_converted_price;

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
      select akc.base_cur_id
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
         and scd.sub_cur_id = pc_from_cur_id
         and cm.is_deleted = 'N'
         and scd.is_deleted = 'N';
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
         and scd.sub_cur_id = pc_to_cur_id
         and cm.is_deleted = 'N'
         and scd.is_deleted = 'N';
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
      exception
        when no_data_found then
          return - 1;
      end;
    end if;  
    vn_result := pn_amt_to_be_converted *
                 ((vn_to_rate / vn_to_main_currency_factor) /
                 (vn_from_rate / vn_from_main_currency_factor));
    return(vn_result);
  end;
  function fn_get_drid_name(pc_drid in varchar2) return varchar2 is
  
    /**************************************************************************************************
    Function Name                       : fn_get_drid_name
    Author                              : Siva
    Created Date                        : 27 Feb 2011
    Purpose                             : To return the DRID name for formula builder package
    Parameters                          :
    
    pc_drid                             : DR_ID
    Returns                             :
    varchar2                            : Name of the DRID
    
    Modification History
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/ 
    vc_result varchar2(50);
  begin
    begin
      select drm.dr_id_name
        into vc_result
        from drm_derivative_master drm
       where drm.dr_id = pc_drid;
    exception
      when no_data_found then
        return pc_drid;
    end;
    return(vc_result);
  exception
    when others then
      return pc_drid;
  end;
  function fn_get_substitute_dt_for_npd(pc_del_calendar_id varchar2,
                                        pd_date            date) return date is
    /*
    Function returns substitute date if exists for give date and calendar id otherwise returns same date which has been passed if
    passed date was not a NPD
    */
    vd_date date;
  begin
    select npd.substitute_day
      into vd_date
      from npd_non_prompt_calendar_days npd
     where npd.prompt_delivery_calendar_id = pc_del_calendar_id
       and non_prompt_day = pd_date
       and is_deleted = 'N';
    return vd_date;
  exception
    when others then
      return pd_date;
  end fn_get_substitute_dt_for_npd;
  function fn_get_substitute_inst_npd(pc_instrumentid varchar2, pd_date date)
    return date is
    /*
    Function returns substitute date if exists for given date and instrument id otherwise returns same date which has been passed if
    passed date was not a NPD
    */
    vd_date date;
  begin
    select npd.substitute_day
      into vd_date
      from npd_non_prompt_calendar_days npd,
           dim_der_instrument_master    dim
     where npd.prompt_delivery_calendar_id = dim.delivery_calender_id
       and dim.instrument_id = pc_instrumentid
       and npd.non_prompt_day = pd_date
       and npd.is_deleted = 'N'
       and dim.is_deleted = 'N';
    return vd_date;
  exception
    when others then
      return pd_date;
  end fn_get_substitute_inst_npd;
end; 
/
