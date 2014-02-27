create or replace package pkg_phy_custom_reports is
  procedure sp_call_custom_reports(pc_corporate_id    varchar2,
                                   pd_trade_date      date,
                                   pc_process_id      varchar2,
                                   pc_user_id         varchar2,
                                   pc_process         varchar2,
                                   pc_dbd_id          varchar2,
                                   pc_prev_process_id varchar2,
                                   pc_prev_dbd_id     varchar2);
  procedure sp_derivative_booking_journal(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2,
                                          pc_dbd_id       varchar2);
  procedure sp_physical_booking_journal(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_process      varchar2,
                                        pc_dbd_id       varchar2);

  procedure sp_derivative_contract_journal(pc_corporate_id varchar2,
                                           pc_process      varchar2,
                                           pd_trade_date   date,
                                           pc_user_id      varchar2,
                                           pc_dbd_id       varchar2,
                                           pc_prev_dbd_id  varchar2);
  procedure sp_physical_contract_journal(pc_corporate_id    varchar2,
                                         pc_process         varchar2,
                                         pd_trade_date      date,
                                         pc_user_id         varchar2,
                                         pc_process_id      varchar2,
                                         pc_dbd_id          varchar2,
                                         pc_prev_dbd_id     varchar2,
                                         pc_prev_process_id varchar2);
  procedure sp_fixation_journal(pc_corporate_id    varchar2,
                                pd_trade_date      date,
                                pc_process_id      varchar2,
                                pc_user_id         varchar2,
                                pc_process         varchar2,
                                pc_dbd_id          varchar2,
                                pc_prev_process_id varchar2);

  function f_get_converted_price_pum(pc_corporate_id       varchar2,
                                     pn_price              number,
                                     pc_from_price_unit_id varchar2,
                                     pc_to_price_unit_id   varchar2,
                                     pd_trade_date         date,
                                     pc_product_id         varchar2)
    return number;
  procedure sp_physical_risk_position(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_process      varchar2,
                                      pc_process_id   varchar2,
                                      pc_user_id      varchar2);
  procedure sp_update_strategy_attributes(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process      varchar2,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2);
  procedure sp_contract_market_price(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process      varchar2,
                                     pc_process_id   varchar2,
                                     pc_user_id      varchar2);
  procedure sp_gmr_market_price(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process      varchar2,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2);
  procedure sp_trader_position_report(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_process      varchar2,
                                      pc_process_id   varchar2,
                                      pc_user_id      varchar2);

  procedure sp_unrealized_pnl_bkfx_rate(pc_corporate_id    varchar2,
                                        pd_trade_date      date,
                                        pc_process         varchar2,
                                        pc_process_id      varchar2,
                                        pc_user_id         varchar2,
                                        pc_prev_process_id varchar2);
end; 
 
/
create or replace package body pkg_phy_custom_reports is

  procedure sp_call_custom_reports(pc_corporate_id    varchar2,
                                   pd_trade_date      date,
                                   pc_process_id      varchar2,
                                   pc_user_id         varchar2,
                                   pc_process         varchar2,
                                   pc_dbd_id          varchar2,
                                   pc_prev_process_id varchar2,
                                   pc_prev_dbd_id     varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_call_custom_reports
    --        Author                                    : Siva
    --        Created Date                              : 25-Jul-2012
    --        Purpose                                   : this package is for custom report client specific..
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : Trade Date
    --        pc_user_id                                : User ID
    --        pc_process                                : Process EOD or EOM
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_logno           number := 200;
    vc_err_msg         varchar2(200);
  begin
  
    vn_logno   := vn_logno + 1;
    vc_err_msg := 'sp_contract_market_price ';
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_contract_market_price');
    sp_contract_market_price(pc_corporate_id,
                             pd_trade_date,
                             pc_process,
                             pc_process_id,
                             pc_user_id);
  
    vn_logno   := vn_logno + 1;
    vc_err_msg := 'sp_contract_market_price ';
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_gmr_market_price');
    sp_gmr_market_price(pc_corporate_id,
                        pd_trade_date,
                        pc_process,
                        pc_process_id,
                        pc_user_id);
    --------
    vn_logno   := vn_logno + 1;
    vc_err_msg := 'sp_derivative_booking_journal ';
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_derivative_booking_journal');
    sp_derivative_booking_journal(pc_corporate_id,
                                  pd_trade_date,
                                  pc_process_id,
                                  pc_user_id,
                                  pc_process,
                                  pc_dbd_id);
    vn_logno   := vn_logno + 1;
    vc_err_msg := 'sp_Physical_booking_journal ';
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_physical_booking_journal');
    sp_physical_booking_journal(pc_corporate_id,
                                pd_trade_date,
                                pc_process_id,
                                pc_user_id,
                                pc_process,
                                pc_dbd_id);
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_fixation_journal');
    vc_err_msg := 'sp_fixation_journal ';
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    sp_fixation_journal(pc_corporate_id,
                        pd_trade_date,
                        pc_process_id,
                        pc_user_id,
                        pc_process,
                        pc_dbd_id,
                        pc_prev_process_id);
    vc_err_msg := 'sp_physical_contract_journal ';
    vn_logno   := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_physical_contract_journal');
    sp_physical_contract_journal(pc_corporate_id,
                                 pc_process,
                                 pd_trade_date,
                                 pc_user_id,
                                 pc_process_id,
                                 pc_dbd_id,
                                 pc_prev_dbd_id,
                                 pc_prev_process_id);
  
    vc_err_msg := 'sp_derivative_contract_journal';
    vn_logno   := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_derivative_contract_journal');
  
    sp_derivative_contract_journal(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date,
                                   pc_user_id,
                                   pc_dbd_id,
                                   pc_prev_dbd_id);
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_physical_risk_position');
    sp_physical_risk_position(pc_corporate_id,
                              pd_trade_date,
                              pc_process,
                              pc_process_id,
                              pc_user_id);
  
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_trader_position_report');
    sp_trader_position_report(pc_corporate_id,
                              pd_trade_date,
                              pc_process,
                              pc_process_id,
                              pc_user_id);
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_insert_pnl');
  
    sp_unrealized_pnl_bkfx_rate(pc_corporate_id,
                                pd_trade_date,
                                pc_process,
                                pc_process_id,
                                pc_user_id,
                                pc_prev_process_id);
  
    ----Note:  keep sp_update_strategy_attributes update procedue at end of custom reports call
    sp_update_strategy_attributes(pc_corporate_id,
                                  pd_trade_date,
                                  pc_process,
                                  pc_process_id,
                                  pc_user_id);
    <<cancel_process>>
    dbms_output.put_line('EOD/EOM Process Cancelled while journal calculation');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_custom_reports.sp_call_custom_reports',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_err_msg,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_derivative_booking_journal(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2,
                                          pc_dbd_id       varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_derivative_booking_journal
    --        Author                                    : Siva
    --        Created Date                              : 25-Jul-2012
    --        Purpose                                   :
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : Trade Date
    --        pc_user_id                                : User ID
    --        pc_process                                : Process EOD or EOM
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    --  vn_conv_factor              number;
    vn_contract_value           number;
    vn_contract_value_in_base   number;
    vn_clearer_comm_amt         number;
    vn_clearer_comm_amt_in_base number;
    vc_trade_cur_id             varchar2(15);
    vc_trade_main_cur_id        varchar2(15);
    vc_trade_main_cur_code      varchar2(15);
    vn_trade_main_cur_conv_rate number;
    vn_trade_main_decimals      number;
    vn_trade_to_base_fx_rate    number;
    cursor cr_cdc_closeout is
      select dcoh.internal_close_out_ref_no,
             'Deleted' journal_type,
             'Closeout' book_type,
             dcoh.corporate_id,
             akc.corporate_name,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dcoh.close_out_ref_no,
             dcoh.close_out_date,
             dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             dt.external_ref_no,
             dt.trade_type,
             phd.companyname clearer,
             gab_akc.firstname || ' ' || gab_akc.lastname created,
             (case
               when dt.trade_type = 'Sell' then
                -1
               else
                1
             end)*dcod.quantity_closed quantity,
             dcod.quantity_closed,
             dcod.quantity_unit_id,
             qum.qty_unit quantity_unit,
             (case
               when nvl(dcod.clearer_comm_amt, 0) = 0 then
                nvl(dt.clearer_comm_amt, 0)
               else
                nvl(dcod.clearer_comm_amt, 0)
             end) clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clr.cur_code clearer_comm_cur_code,
             pkg_general.f_get_base_cur_id(pum_tp.cur_id) trade_currency,
             1 trade_to_corp_fx_rate,
             0 trade_amount_in_base_ccy,
             0 clearer_comm_in_base_ccy,
             cm_akc.cur_id base_cur_id,
             cm_akc.cur_code base_cur_code,
             pdd.product_id,
             pdm.product_desc,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_tp.price_unit_name,
             pum_tp.cur_id price_cur_id,
             cm_tp.cur_code price_cur_code,
             pum_tp.weight price_weight,
             pum_tp.weight_unit_id price_weight_unit_id,
             qum_tp.qty_unit price_weight_unit,
             dt.strategy_id
        from dcoh_der_closeout_header    dcoh,
             dcod_der_closeout_detail    dcod,
             dt_derivative_trade         dt,
             phd_profileheaderdetails    phd,
             ak_corporate                akc,
             cpc_corporate_profit_center cpc,
             cm_currency_master          cm_akc,
             cm_currency_master          cm_clr,
             qum_quantity_unit_master    qum,
             drm_derivative_master       drm,
             dim_der_instrument_master   dim,
             pdd_product_derivative_def  pdd,
             pdm_productmaster           pdm,
             pum_price_unit_master       pum_tp,
             qum_quantity_unit_master    qum_tp,
             cm_currency_master          cm_tp,
             ak_corporate_user           akcu,
             gab_globaladdressbook       gab_akc
       where dcoh.internal_close_out_ref_no =
             dcod.internal_close_out_ref_no
         and dcoh.dbd_id = dcod.dbd_id
         and dcod.internal_derivative_ref_no =
             dt.internal_derivative_ref_no
       --  and dcod.process_id = dt.process_id
         and dt.clearer_profile_id = phd.profileid
         and dt.corporate_id = akc.corporate_id
         and dt.profit_center_id = cpc.profit_center_id
         and akc.base_cur_id = cm_akc.cur_id
         and dt.clearer_comm_cur_id = cm_clr.cur_id(+)
         and dcod.quantity_unit_id = qum.qty_unit_id
         and dt.dr_id = drm.dr_id
         and drm.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.product_id = pdm.product_id
         and dt.trade_price_unit_id = pum_tp.price_unit_id(+)
         and dcoh.is_rolled_back = 'Y'
         and dcoh.undo_closeout_dbd_id = pc_dbd_id
         and pum_tp.weight_unit_id = qum_tp.qty_unit_id(+)
         and pum_tp.cur_id = cm_tp.cur_id(+)
         and dcoh.created_by = akcu.user_id
         and akcu.gabid = gab_akc.gabid
         and dt.dbd_id = pc_dbd_id
      union all
      select dcoh.internal_close_out_ref_no,
             'New' journal_type,
             'Closeout' book_type,
             dcoh.corporate_id,
             akc.corporate_name,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             dcoh.close_out_ref_no,
             dcoh.close_out_date,
             dt.internal_derivative_ref_no,
             dt.derivative_ref_no,
             dt.external_ref_no,
             dt.trade_type,
             phd.companyname clearer,
             gab_akc.firstname || ' ' || gab_akc.lastname created,
              (case
               when dt.trade_type = 'Sell' then
                -1
               else
                1
             end)*dcod.quantity_closed quantity,
             dcod.quantity_closed,
             dcod.quantity_unit_id,
             qum.qty_unit quantity_unit,
             (case
               when nvl(dcod.clearer_comm_amt, 0) = 0 then
                nvl(dt.clearer_comm_amt, 0)
               else
                nvl(dcod.clearer_comm_amt, 0)
             end) clearer_comm_amt,
             dt.clearer_comm_cur_id,
             cm_clr.cur_code clearer_comm_cur_code,
             pkg_general.f_get_base_cur_id(pum_tp.cur_id) trade_currency,
             1 trade_to_corp_fx_rate,
             0 trade_amount_in_base_ccy,
             0 clearer_comm_in_base_ccy,
             cm_akc.cur_id base_cur_id,
             cm_akc.cur_code base_cur_code,
             pdd.product_id,
             pdm.product_desc,
             dt.trade_price,
             dt.trade_price_unit_id,
             pum_tp.price_unit_name,
             pum_tp.cur_id price_cur_id,
             cm_tp.cur_code price_cur_code,
             pum_tp.weight price_weight,
             pum_tp.weight_unit_id price_weight_unit_id,
             qum_tp.qty_unit price_weight_unit,
             dt.strategy_id
        from dcoh_der_closeout_header    dcoh,
             dcod_der_closeout_detail    dcod,
             dt_derivative_trade         dt,
             phd_profileheaderdetails    phd,
             ak_corporate                akc,
             cpc_corporate_profit_center cpc,
             cm_currency_master          cm_akc,
             cm_currency_master          cm_clr,
             qum_quantity_unit_master    qum,
             drm_derivative_master       drm,
             dim_der_instrument_master   dim,
             pdd_product_derivative_def  pdd,
             pdm_productmaster           pdm,
             pum_price_unit_master       pum_tp,
             qum_quantity_unit_master    qum_tp,
             cm_currency_master          cm_tp,
             ak_corporate_user           akcu,
             gab_globaladdressbook       gab_akc
       where dcoh.internal_close_out_ref_no =
             dcod.internal_close_out_ref_no
       --  and dcoh.process_id = dcod.process_id
         and dcod.internal_derivative_ref_no = dt.internal_derivative_ref_no
         and dcoh.dbd_id = dcod.dbd_id
         and dcoh.dbd_id = pc_dbd_id
       --  and dcod.process_id = dt.process_id
         and dt.clearer_profile_id = phd.profileid
         and dt.corporate_id = akc.corporate_id
         and dt.profit_center_id = cpc.profit_center_id
         and akc.base_cur_id = cm_akc.cur_id
         and dt.clearer_comm_cur_id = cm_clr.cur_id(+)
         and dcod.quantity_unit_id = qum.qty_unit_id
         and dt.dr_id = drm.dr_id
         and drm.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.product_id = pdm.product_id
         and dt.trade_price_unit_id = pum_tp.price_unit_id(+)
        -- and dcoh.is_rolled_back = 'N'
         and pum_tp.weight_unit_id = qum_tp.qty_unit_id(+)
         and pum_tp.cur_id = cm_tp.cur_id(+)
         and dcoh.created_by = akcu.user_id
         and akcu.gabid = gab_akc.gabid
         and dt.dbd_id = pc_dbd_id;
  
  begin
    for cr_cdc_row in cr_cdc_closeout
    loop
      vc_trade_cur_id := nvl(cr_cdc_row.price_cur_id,
                             cr_cdc_row.base_cur_id);
      begin
        pkg_general.sp_get_main_cur_detail(vc_trade_cur_id,
                                           vc_trade_main_cur_id,
                                           vc_trade_main_cur_code,
                                           vn_trade_main_cur_conv_rate,
                                           vn_trade_main_decimals);
        vn_contract_value := (cr_cdc_row.trade_price * cr_cdc_row.quantity_closed *
                             nvl(pkg_general.f_get_converted_quantity(cr_cdc_row.product_id,
                                                                       cr_cdc_row.quantity_unit_id,
                                                                       cr_cdc_row.price_weight_unit_id,
                                                                       1),
                                  1)) * vn_trade_main_cur_conv_rate;
      exception
        when others then
          vn_contract_value := 0;
      end;
      vn_contract_value := round(vn_contract_value * (case when cr_cdc_row.trade_type = 'Sell' then 1 else - 1 end), vn_trade_main_decimals);
      begin
        vn_trade_to_base_fx_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                             vc_trade_main_cur_id,
                                                                             cr_cdc_row.base_cur_id,
                                                                             pd_trade_date,
                                                                             1);
      exception
        when others then
          vn_trade_to_base_fx_rate := 0;
      end;
      vn_clearer_comm_amt := nvl(cr_cdc_row.clearer_comm_amt, 0);
      if cr_cdc_row.clearer_comm_cur_id is not null and
         cr_cdc_row.clearer_comm_cur_id <> cr_cdc_row.base_cur_id then
        vn_clearer_comm_amt_in_base := vn_clearer_comm_amt *
                                       pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                cr_cdc_row.clearer_comm_cur_id,
                                                                                cr_cdc_row.base_cur_id,
                                                                                pd_trade_date,
                                                                                1);
      else
        vn_clearer_comm_amt_in_base := vn_clearer_comm_amt;
      end if;
      vn_contract_value_in_base := round(nvl(vn_contract_value, 0) *
                                         nvl(vn_trade_to_base_fx_rate, 1),
                                         vn_trade_main_decimals);
      insert into eod_eom_booking_journal
        (internal_close_out_ref_no,
         journal_type,
         book_type,
         corporate_id,
         corporate_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         close_out_ref_no,
         close_out_date,
         internal_derivative_ref_no,
         derivative_ref_no,
         external_ref_no,
         trade_type,
         clearer,
         created_by,
         quantity,
         quantity_unit_id,
         quantity_unit,
         clearer_comm_amt,
         clearer_comm_cur_id,
         clearer_comm_cur_code,
         trade_amount,
         trade_currency,
         trade_to_corp_fx_rate,
         trade_amount_in_base_ccy,
         clearer_comm_in_base_ccy,
         base_cur_id,
         base_cur_code,
         product_id,
         product_desc,
         eod_eom_date,
         process,
         process_id,
         dbd_id,
         trade_price,
         trade_price_unit_id,
         trade_price_unit,
         price_cur_id,
         price_cur_code,
         price_weight,
         price_weight_unit_id,
         price_weight_unit,
         strategy_id)
      values
        (cr_cdc_row.internal_close_out_ref_no,
         cr_cdc_row.journal_type,
         cr_cdc_row.book_type,
         cr_cdc_row.corporate_id,
         cr_cdc_row.corporate_name,
         cr_cdc_row.profit_center_id,
         cr_cdc_row.profit_center_name,
         cr_cdc_row.profit_center_short_name,
         cr_cdc_row.close_out_ref_no,
         cr_cdc_row.close_out_date,
         cr_cdc_row.internal_derivative_ref_no,
         cr_cdc_row.derivative_ref_no,
         cr_cdc_row.external_ref_no,
         cr_cdc_row.trade_type,
         cr_cdc_row.clearer,
         cr_cdc_row.created,
         cr_cdc_row.quantity,
         cr_cdc_row.quantity_unit_id,
         cr_cdc_row.quantity_unit,
         vn_clearer_comm_amt, --by variable
         cr_cdc_row.clearer_comm_cur_id,
         cr_cdc_row.clearer_comm_cur_code,
         vn_contract_value, --by variable
         vc_trade_main_cur_code,
         vn_trade_to_base_fx_rate, --by variable
         vn_contract_value_in_base, --by variable
         vn_clearer_comm_amt_in_base, --by variable
         cr_cdc_row.base_cur_id,
         cr_cdc_row.base_cur_code,
         cr_cdc_row.product_id,
         cr_cdc_row.product_desc,
         pd_trade_date,
         pc_process,
         pc_process_id,
         pc_dbd_id,
         cr_cdc_row.trade_price,
         cr_cdc_row.trade_price_unit_id,
         cr_cdc_row.price_unit_name,
         cr_cdc_row.price_cur_id,
         cr_cdc_row.price_cur_code,
         cr_cdc_row.price_weight,
         cr_cdc_row.price_weight_unit_id,
         cr_cdc_row.price_weight_unit,
         cr_cdc_row.strategy_id);
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_derivative_journal',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_physical_booking_journal(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_process      varchar2,
                                        pc_dbd_id       varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_Physical_booking_journal
    --        Author                                    : Ashok
    --        Created Date                              : 25-Jul-2012
    --        Purpose                                   :
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : Trade Date
    --        pc_user_id                                : User ID
    --        pc_process                                : Process EOD or EOM
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    delete from temp_ii ii where ii.corporate_id = pc_corporate_id;
    commit;
     insert into temp_ii
       (corporate_id, internal_invoice_ref_no, delivery_item_ref_no)
       select pc_corporate_id,
              iss.internal_invoice_ref_no,
              iid.delivery_item_ref_no
         from is_invoice_summary iss,
              (select iid.internal_invoice_ref_no,
                      f_string_aggregate(ii.delivery_item_ref_no) delivery_item_ref_no
                 from iid_invoicable_item_details iid,
                      ii_invoicable_item          ii
                where ii.invoicable_item_id = iid.invoicable_item_id
                  and iid.is_active = 'Y'
                  and ii.is_active = 'Y'
                group by iid.internal_invoice_ref_no) iid
        where iss.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
          and iss.process_id = pc_process_id
          and iss.corporate_id = pc_corporate_id;
        --  and iss.is_active = 'Y';
    commit;
    sp_gather_table_stats('temp_ii');
    for cur_temp_ii in (select iss.internal_invoice_ref_no,
                               axs.created_by,
                               gab.firstname || '  ' || gab.lastname created_name
                          from is_invoice_summary         iss,
                               iam_invoice_action_mapping iam,
                               axs_action_summary         axs,
                               dbd_database_dump          dbd,
                               ak_corporate_user          ak,
                               gab_globaladdressbook      gab
                         where iss.internal_invoice_ref_no =
                               iam.internal_invoice_ref_no
                           and iss.process_id = pc_process_id
                           and iss.corporate_id = pc_corporate_id
                     --      and iss.is_active = 'Y'
                           and iam.invoice_action_ref_no =
                               axs.internal_action_ref_no
                           and axs.dbd_id = dbd.dbd_id
                           and axs.corporate_id = pc_corporate_id
                           and dbd.process = pc_process
                           and axs.created_by = ak.user_id
                           and ak.gabid = gab.gabid)
    loop
      update temp_ii ii
         set ii.created_user_id   = cur_temp_ii.created_by,
             ii.created_user_name = cur_temp_ii.created_name
       where ii.internal_invoice_ref_no =
             cur_temp_ii.internal_invoice_ref_no
         and ii.corporate_id = pc_corporate_id;
    end loop;
    commit;
    -- removed corporate name,base cur,code ,eod run count,run time
    for cc_phy in (select 'New' section_name,
                          iss.corporate_id,
                          pdm.product_id,
                          pdm.product_desc,
                          pcm.cp_id counter_party_id,
                          phd_contract_cp.companyname counter_party_name,
                          iss.invoiced_qty invoice_quantity,
                          qum.qty_unit invoice_quantity_uom,
                          nvl(iss.fx_to_base, 1) fx_base,
                          nvl(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
                          nvl(cpc.profit_center_short_name,
                              cpc1.profit_center_short_name) profit_center,
                          pcpd.strategy_id,
                          css.strategy_name,
                          nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
                          nvl(pcm.contract_ref_no, 'NA') contract_ref_no,
                          nvl(pcm.internal_contract_ref_no, 'NA') internal_contract_ref_no,
                          iss.invoice_cur_id invoice_cur_id,
                          cm_p.cur_code pay_in_currency,
                          round(iss.total_amount_to_pay, 4) *
                          nvl(iss.fx_to_base, 1) *
                          (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end) amount_in_base_cur,
                          round(iss.total_amount_to_pay, 4) * (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end) invoice_amt,
                          iss.invoice_issue_date invoice_date,
                          iss.payment_due_date invoice_due_date,
                          iss.invoice_type_name invoice_type,
                          iss.bill_to_address bill_to_cp_country,
                          pcm.contract_ref_no || '-' ||
                          ii.delivery_item_ref_no delivery_item_ref_no,
                          ivd.vat_amount_in_vat_cur vat_amount,
                          ivd.vat_remit_cur_id,
                          cm_vat.cur_code vat_remit_currency,
                          (nvl(ivd.fx_rate_vc_ic, 1) *
                          nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
                          (ivd.vat_amount_in_vat_cur *
                          nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
                          null commission_value,
                          null commission_value_ccy,
                          ii.created_user_id,
                          ii.created_user_name
                     from is_invoice_summary                      iss,
                          cm_currency_master                      cm_p,
                          incm_invoice_contract_mapping@eka_appdb incm,
                          ivd_invoice_vat_details@eka_appdb       ivd,
                          pcm_physical_contract_main              pcm,
                          temp_ii                                 ii,
                          cpc_corporate_profit_center             cpc,
                          cpc_corporate_profit_center             cpc1,
                          pcpd_pc_product_definition              pcpd,
                          cm_currency_master                      cm_vat,
                          pdm_productmaster                       pdm,
                          phd_profileheaderdetails                phd_contract_cp,
                          qum_quantity_unit_master                qum,
                          css_corporate_strategy_setup            css
                    where iss.is_active = 'Y'
                      and iss.corporate_id is not null
                      and iss.internal_invoice_ref_no =
                          incm.internal_invoice_ref_no(+)
                      and iss.internal_invoice_ref_no =
                          ivd.internal_invoice_ref_no(+)
                      and incm.internal_contract_ref_no =
                          pcm.internal_contract_ref_no(+)
                      and ii.internal_invoice_ref_no =
                          iss.internal_invoice_ref_no
                      and ii.corporate_id = iss.corporate_id
                      and iss.internal_contract_ref_no =
                          pcpd.internal_contract_ref_no
                      and iss.profit_center_id = cpc.profit_center_id(+)
                      and pcpd.profit_center_id = cpc1.profit_center_id(+)
                      and iss.invoice_cur_id = cm_p.cur_id(+)
                      and pcpd.product_id = pdm.product_id(+)
                      and phd_contract_cp.profileid(+) = iss.cp_id
                      and nvl(pcm.partnership_type, 'Normal') = 'Normal'
                      and iss.invoiced_qty_unit_id = qum.qty_unit_id(+)
                      and iss.is_inv_draft = 'N'
                      and iss.invoice_type_name not in
                          ('Profoma', 'Service')
                      and ivd.vat_remit_cur_id = cm_vat.cur_id(+)
                      and pcpd.input_output = 'Input'
                      and nvl(iss.total_amount_to_pay, 0) <> 0
                      and pcpd.strategy_id = css.strategy_id
                      and iss.process_id = pc_process_id
                      and pcm.process_id = pc_process_id
                      and pcpd.process_id = pc_process_id
                      and phd_contract_cp.is_active = 'Y'
                      and iss.is_invoice_new = 'Y'
                      and iss.corporate_id = pc_corporate_id
                   ---2 Service invoices
                   union all
                   select 'New' section_name,
                          iss.corporate_id,
                          nvl(pdm.product_id, 'NA'),
                          nvl(pdm.product_desc, 'NA'),
                          iss.cp_id counter_party_id,
                          phd_cp.companyname counter_party_name,
                          iss.invoiced_qty invoice_quantity,
                          nvl(qum.qty_unit, 'NA') invoice_quantity_uom,
                          nvl(iss.fx_to_base, 1) fx_base,
                          coalesce(cpc.profit_center_id,
                                   cpc1.profit_center_id,
                                   'NA') profit_center_id,
                          coalesce(cpc.profit_center_short_name,
                                   cpc1.profit_center_short_name,
                                   'NA') profit_center,
                          pcpd.strategy_id,
                          css.strategy_name,
                          nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
                          nvl(pcm.contract_ref_no, 'NA') contract_ref_no,
                          nvl(pcm.internal_contract_ref_no, 'NA') internal_contract_ref_no,
                          iss.invoice_cur_id invoice_cur_id,
                          cm_p.cur_code pay_in_currency,
                          round(iss.total_amount_to_pay, 4) *
                          nvl(iss.fx_to_base, 1) *
                          (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end) amount_in_base_cur,
                          round(iss.total_amount_to_pay, 4) * (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end)invoice_amt,
                          iss.invoice_issue_date invoice_date,
                          iss.payment_due_date invoice_due_date,
                          nvl(iss.invoice_type_name, 'NA') invoice_type,
                          iss.bill_to_address bill_to_cp_country,
                          pcm.contract_ref_no || '-' ||
                          ii.delivery_item_ref_no delivery_item_ref_no,
                          ivd.vat_amount_in_vat_cur vat_amount,
                          nvl(ivd.vat_remit_cur_id, 'NA'),
                          nvl(cm_vat.cur_code, 'NA') vat_remit_currency,
                          (nvl(ivd.fx_rate_vc_ic, 1) *
                          nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
                          (ivd.vat_amount_in_vat_cur *
                          nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
                          null commission_value,
                          null commission_value_ccy,
                          ii.created_user_id,
                          ii.created_user_name
                     from is_invoice_summary                iss,
                          iam_invoice_action_mapping        iam,
                          iid_invoicable_item_details       iid,
                          axs_action_summary                axs,
                          cs_cost_store                     cs,
                          ivd_invoice_vat_details@eka_appdb ivd,
                          cigc_contract_item_gmr_cost       cigc,
                          gmr_goods_movement_record         gmr,
                          pcpd_pc_product_definition        pcpd,
                          pcm_physical_contract_main        pcm,
                          temp_ii                           ii,
                          cpc_corporate_profit_center       cpc,
                          cpc_corporate_profit_center       cpc1,
                          phd_profileheaderdetails          phd_cp,
                          cm_currency_master                cm_vat,
                          cm_currency_master                cm_p,
                          pdm_productmaster                 pdm,
                          qum_quantity_unit_master          qum,
                          css_corporate_strategy_setup      css,
                          dbd_database_dump                 dbd
                    where iss.internal_contract_ref_no is null
                      and iss.is_active = 'Y'
                      and iss.internal_invoice_ref_no =
                          iam.internal_invoice_ref_no
                      and iss.internal_invoice_ref_no =
                          iid.internal_invoice_ref_no(+)
                      and iss.internal_invoice_ref_no =
                          ivd.internal_invoice_ref_no(+)
                      and iam.invoice_action_ref_no =
                          axs.internal_action_ref_no
                      and iam.invoice_action_ref_no =
                          cs.internal_action_ref_no(+)
                      and cs.cog_ref_no = cigc.cog_ref_no(+)
                      and cigc.internal_gmr_ref_no =
                          gmr.internal_gmr_ref_no(+)
                      and gmr.internal_contract_ref_no =
                          pcpd.internal_contract_ref_no(+)
                      and pcpd.internal_contract_ref_no =
                          pcm.internal_contract_ref_no(+)
                      and ii.internal_invoice_ref_no =
                          iss.internal_invoice_ref_no
                      and ii.corporate_id = iss.corporate_id
                      and iss.invoiced_qty_unit_id = qum.qty_unit_id(+)
                      and pcpd.input_output(+) = 'Input'
                      and iss.invoice_type_name = 'Service'
                      and iss.profit_center_id = cpc.profit_center_id(+)
                      and pcpd.profit_center_id = cpc1.profit_center_id(+)
                      and iss.cp_id = phd_cp.profileid
                      and iss.invoice_cur_id = cm_p.cur_id(+)
                      and pcpd.product_id = pdm.product_id(+)
                      and ivd.vat_remit_cur_id = cm_vat.cur_id(+)
                      and pcpd.strategy_id = css.strategy_id
                      and iss.process_id = pc_process_id
                      and pcm.process_id = pc_process_id
                      and pcpd.process_id = pc_process_id
                      and iss.is_invoice_new = 'Y'
                      and pcm.corporate_id = pc_corporate_id
                      and iss.corporate_id = pc_corporate_id
                      and axs.dbd_id = dbd.dbd_id
                      and dbd.corporate_id = pc_corporate_id
                      and dbd.trade_date <= pd_trade_date
                      and dbd.process = pc_process
                    group by pdm.product_id,
                             pdm.product_desc,
                             iss.corporate_id,
                             iss.cp_id,
                             iss.invoiced_qty,
                             iss.fx_to_base,
                             pcm.contract_ref_no,
                             pcm.internal_contract_ref_no,
                             iss.invoice_type,
                             iss.invoice_ref_no,
                             iss.total_amount_to_pay,
                             iss.recieved_raised_type,
                             iss.bill_to_address,
                             iss.invoice_cur_id,
                             iss.invoice_issue_date,
                             iss.payment_due_date,
                             iss.invoice_type_name,
                             phd_cp.companyname,
                             cpc.profit_center_id,
                             cpc.profit_center_short_name,
                             cpc1.profit_center_id,
                             cpc1.profit_center_short_name,
                             cm_p.cur_code,
                             pcm.purchase_sales,
                             qum.qty_unit,
                             ivd.vat_amount_in_vat_cur,
                             ivd.vat_remit_cur_id,
                             cm_vat.cur_code,
                             ivd.fx_rate_vc_ic,
                             ii.delivery_item_ref_no,
                             pcpd.strategy_id,
                             css.strategy_name,
                             ii.created_user_id,
                             ii.created_user_name,
                             iss.payable_receivable
                   union all
                   --For Cancelled INV
                   select 'Delete' section_name,
                          iss.corporate_id,
                          pdm.product_id,
                          pdm.product_desc,
                          pcm.cp_id counter_party_id,
                          phd_contract_cp.companyname counter_party_name,
                          iss.invoiced_qty invoice_quantity,
                          qum.qty_unit invoice_quantity_uom,
                          nvl(iss.fx_to_base, 1) fx_base,
                          nvl(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
                          nvl(cpc.profit_center_short_name,
                              cpc1.profit_center_short_name) profit_center,
                          pcpd.strategy_id,
                          css.strategy_name,
                          nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
                          nvl(pcm.contract_ref_no, 'NA') contract_ref_no,
                          nvl(pcm.internal_contract_ref_no, 'NA') internal_contract_ref_no,
                          iss.invoice_cur_id invoice_cur_id,
                          cm_p.cur_code pay_in_currency,
                          round(iss.total_amount_to_pay, 4) *
                          nvl(iss.fx_to_base, 1) *
                          (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end) amount_in_base_cur,
                          round(iss.total_amount_to_pay, 4) * (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end)invoice_amt,
                          iss.invoice_issue_date invoice_date,
                          iss.payment_due_date invoice_due_date,
                          iss.invoice_type_name invoice_type,
                          iss.bill_to_address bill_to_cp_country,
                          pcm.contract_ref_no || '-' ||
                          ii.delivery_item_ref_no delivery_item_ref_no,
                          ivd.vat_amount_in_vat_cur vat_amount,
                          ivd.vat_remit_cur_id,
                          cm_vat.cur_code vat_remit_currency,
                          (nvl(ivd.fx_rate_vc_ic, 1) *
                          nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
                          (ivd.vat_amount_in_vat_cur *
                          nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
                          null commission_value,
                          null commission_value_ccy,
                          ii.created_user_id,
                          ii.created_user_name
                     from is_invoice_summary                      iss,
                          cm_currency_master                      cm_p,
                          incm_invoice_contract_mapping@eka_appdb incm,
                          ivd_invoice_vat_details@eka_appdb       ivd,
                          pcm_physical_contract_main              pcm,
                          temp_ii                                 ii,
                          cpc_corporate_profit_center             cpc,
                          cpc_corporate_profit_center             cpc1,
                          pcpd_pc_product_definition              pcpd,
                          cm_currency_master                      cm_vat,
                          pdm_productmaster                       pdm,
                          phd_profileheaderdetails                phd_contract_cp,
                          qum_quantity_unit_master                qum,
                          css_corporate_strategy_setup            css
                    where iss.is_active = 'N'
                      and iss.is_cancelled_today = 'Y'
                      and iss.corporate_id is not null
                      and iss.internal_invoice_ref_no =
                          incm.internal_invoice_ref_no(+)
                      and iss.internal_invoice_ref_no =
                          ivd.internal_invoice_ref_no(+)
                      and incm.internal_contract_ref_no =
                          pcm.internal_contract_ref_no(+)
                      and iss.internal_invoice_ref_no =
                          ii.internal_invoice_ref_no
                      and iss.corporate_id = ii.corporate_id
                      and iss.internal_contract_ref_no =
                          pcpd.internal_contract_ref_no
                      and iss.profit_center_id = cpc.profit_center_id(+)
                      and pcpd.profit_center_id = cpc1.profit_center_id(+)
                      and iss.invoice_cur_id = cm_p.cur_id(+)
                      and pcpd.product_id = pdm.product_id(+)
                      and iss.cp_id = phd_contract_cp.profileid(+)
                      and nvl(pcm.partnership_type, 'Normal') = 'Normal'
                      and iss.invoiced_qty_unit_id = qum.qty_unit_id(+)
                      and iss.is_inv_draft = 'N'
                      and iss.invoice_type_name not in
                          ('Profoma', 'Service')
                      and ivd.vat_remit_cur_id = cm_vat.cur_id(+)
                      and pcpd.input_output = 'Input'
                      and nvl(iss.total_amount_to_pay, 0) <> 0
                      and pcpd.strategy_id = css.strategy_id
                      and iss.process_id = pc_process_id
                      and pcm.process_id = pc_process_id
                      and pcpd.process_id = pc_process_id
                      and phd_contract_cp.is_active = 'Y'
                      and iss.corporate_id = pc_corporate_id
                   ---2 Service invoices
                   --For Cancelled INV
                   union all
                   select 'Delete' section_name,
                          iss.corporate_id,
                          nvl(pdm.product_id, 'NA'),
                          nvl(pdm.product_desc, 'NA'),
                          iss.cp_id counter_party_id,
                          phd_cp.companyname counter_party_name,
                          iss.invoiced_qty invoice_quantity,
                          nvl(qum.qty_unit, 'MT') invoice_quantity_uom,
                          nvl(iss.fx_to_base, 1) fx_base,
                          coalesce(cpc.profit_center_id,
                                   cpc1.profit_center_id,
                                   'NA') profit_center_id,
                          coalesce(cpc.profit_center_short_name,
                                   cpc1.profit_center_short_name,
                                   'NA') profit_center,
                          pcpd.strategy_id,
                          css.strategy_name,
                          nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
                          nvl(pcm.contract_ref_no, 'NA') contract_ref_no,
                          nvl(pcm.internal_contract_ref_no, 'NA') internal_contract_ref_no,
                          iss.invoice_cur_id invoice_cur_id,
                          cm_p.cur_code pay_in_currency,
                          round(iss.total_amount_to_pay, 4) *
                          nvl(iss.fx_to_base, 1) *
                          (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end) amount_in_base_cur,
                          round(iss.total_amount_to_pay, 4) *(case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end) invoice_amt,
                          iss.invoice_issue_date invoice_date,
                          iss.payment_due_date invoice_due_date,
                          nvl(iss.invoice_type_name, 'NA') invoice_type,
                          iss.bill_to_address bill_to_cp_country,
                          pcm.contract_ref_no || '-' ||
                          ii.delivery_item_ref_no delivery_item_ref_no,
                          ivd.vat_amount_in_vat_cur vat_amount,
                          nvl(ivd.vat_remit_cur_id, 'NA'),
                          nvl(cm_vat.cur_code, 'NA') vat_remit_currency,
                          (nvl(ivd.fx_rate_vc_ic, 1) *
                          nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
                          (ivd.vat_amount_in_vat_cur *
                          nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
                          null commission_value,
                          null commission_value_ccy,
                          ii.created_user_id,
                          ii.created_user_name
                     from is_invoice_summary                iss,
                          iam_invoice_action_mapping        iam,
                          iid_invoicable_item_details       iid,
                          axs_action_summary                axs,
                          cs_cost_store                     cs,
                          ivd_invoice_vat_details@eka_appdb ivd,
                          cigc_contract_item_gmr_cost       cigc,
                          gmr_goods_movement_record         gmr,
                          pcpd_pc_product_definition        pcpd,
                          pcm_physical_contract_main        pcm,
                          temp_ii                           ii,
                          cpc_corporate_profit_center       cpc,
                          cpc_corporate_profit_center       cpc1,
                          phd_profileheaderdetails          phd_cp,
                          cm_currency_master                cm_vat,
                          cm_currency_master                cm_p,
                          pdm_productmaster                 pdm,
                          qum_quantity_unit_master          qum,
                          css_corporate_strategy_setup      css,
                          dbd_database_dump                 dbd
                    where iss.internal_contract_ref_no is null
                      and iss.is_active = 'N'
                      and iss.is_cancelled_today = 'Y'
                      and iss.internal_invoice_ref_no =
                          iam.internal_invoice_ref_no
                      and iss.internal_invoice_ref_no =
                          iid.internal_invoice_ref_no(+)
                      and iss.internal_invoice_ref_no =
                          ivd.internal_invoice_ref_no(+)
                      and iam.invoice_action_ref_no =
                          axs.internal_action_ref_no
                      and iam.invoice_action_ref_no =
                          cs.internal_action_ref_no(+)
                      and cs.cog_ref_no = cigc.cog_ref_no(+)
                      and cigc.internal_gmr_ref_no =
                          gmr.internal_gmr_ref_no(+)
                      and gmr.internal_contract_ref_no =
                          pcpd.internal_contract_ref_no(+)
                      and pcpd.internal_contract_ref_no =
                          pcm.internal_contract_ref_no(+)
                      and ii.internal_invoice_ref_no =
                          iss.internal_invoice_ref_no
                      and ii.corporate_id = iss.corporate_id
                      and iss.invoiced_qty_unit_id = qum.qty_unit_id(+)
                      and pcpd.input_output(+) = 'Input'
                      and iss.invoice_type_name = 'Service'
                      and iss.profit_center_id = cpc.profit_center_id(+)
                      and pcpd.profit_center_id = cpc1.profit_center_id(+)
                      and iss.cp_id = phd_cp.profileid
                      and iss.invoice_cur_id = cm_p.cur_id(+)
                      and pcpd.product_id = pdm.product_id(+)
                      and ivd.vat_remit_cur_id = cm_vat.cur_id(+)
                      and pcpd.strategy_id = css.strategy_id
                      and iss.process_id = pc_process_id
                      and pcm.process_id = pc_process_id
                      and pcpd.process_id = pc_process_id
                      and iss.corporate_id = pc_corporate_id
                      and axs.dbd_id = dbd.dbd_id
                      and dbd.corporate_id = pc_corporate_id
                      and dbd.trade_date <= pd_trade_date
                      and dbd.process = pc_process
                    group by pdm.product_id,
                             pdm.product_desc,
                             iss.corporate_id,
                             iss.cp_id,
                             cm_p.cur_code,
                             iss.invoiced_qty,
                             iss.fx_to_base,
                             pcm.contract_ref_no,
                             pcm.internal_contract_ref_no,
                             iss.invoice_type,
                             iss.invoice_ref_no,
                             iss.total_amount_to_pay,
                             iss.recieved_raised_type,
                             iss.invoice_cur_id,
                             iss.invoice_issue_date,
                             iss.payment_due_date,
                             iss.invoice_type_name,
                             iss.bill_to_address,
                             phd_cp.companyname,
                             cpc.profit_center_id,
                             cpc.profit_center_short_name,
                             cpc1.profit_center_id,
                             cpc1.profit_center_short_name,
                             pcm.purchase_sales,
                             qum.qty_unit,
                             ivd.vat_amount_in_vat_cur,
                             ivd.vat_remit_cur_id,
                             cm_vat.cur_code,
                             ivd.fx_rate_vc_ic,
                             ii.delivery_item_ref_no,
                             pcpd.strategy_id,
                             css.strategy_name,
                             ii.created_user_id,
                             ii.created_user_name,
                             iss.payable_receivable)
    loop
      insert into eod_eom_phy_booking_journal
        (section_name,
         corporate_id,
         product_id,
         product_desc,
         counter_party_id,
         counter_party_name,
         invoice_quantity,
         invoice_quantity_uom,
         fx_base,
         profit_center_id,
         profit_center,
         strategy_id,
         strategy_name,
         invoice_ref_no,
         contract_ref_no,
         internal_contract_ref_no,
         invoice_cur_id,
         pay_in_currency,
         amount_in_base_cur,
         invoice_amt,
         invoice_date,
         invoice_due_date,
         invoice_type,
         bill_to_cp_country,
         delivery_item_ref_no,
         vat_amount,
         vat_remit_cur_id,
         vat_remit_currency,
         fx_rate_for_vat,
         vat_amount_base_currency,
         commission_value,
         commission_value_ccy,
         process_id,
         process,
         created_user_id,
         created_user_name)
      values
        (cc_phy.section_name,
         cc_phy.corporate_id,
         cc_phy.product_id,
         cc_phy.product_desc,
         cc_phy.counter_party_id,
         cc_phy.counter_party_name,
         cc_phy.invoice_quantity,
         cc_phy.invoice_quantity_uom,
         cc_phy.fx_base,
         cc_phy.profit_center_id,
         cc_phy.profit_center,
         cc_phy.strategy_id,
         cc_phy.strategy_name,
         cc_phy.invoice_ref_no,
         cc_phy.contract_ref_no,
         cc_phy.internal_contract_ref_no,
         cc_phy.invoice_cur_id,
         cc_phy.pay_in_currency,
         cc_phy.amount_in_base_cur,
         cc_phy.invoice_amt,
         cc_phy.invoice_date,
         cc_phy.invoice_due_date,
         cc_phy.invoice_type,
         cc_phy.bill_to_cp_country,
         cc_phy.delivery_item_ref_no,
         cc_phy.vat_amount,
         cc_phy.vat_remit_cur_id,
         cc_phy.vat_remit_currency,
         cc_phy.fx_rate_for_vat,
         cc_phy.vat_amount_base_currency,
         cc_phy.commission_value,
         cc_phy.commission_value_ccy,
         pc_process_id,
         pc_process,
         cc_phy.created_user_id,
         cc_phy.created_user_name);
    end loop;
    commit;
    for cc_phy in (select 'Modified' section_name,
                          iss.corporate_id,
                          pdm.product_id,
                          pdm.product_desc,
                          pcm.cp_id counter_party_id,
                          phd_contract_cp.companyname counter_party_name,
                          iss.invoiced_qty invoice_quantity,
                          qum.qty_unit invoice_quantity_uom,
                          nvl(iss.fx_to_base, 1) fx_base,
                          nvl(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
                          nvl(cpc.profit_center_short_name,
                              cpc1.profit_center_short_name) profit_center,
                          pcpd.strategy_id,
                          css.strategy_name,
                          nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
                          nvl(pcm.contract_ref_no, 'NA') contract_ref_no,
                          nvl(pcm.internal_contract_ref_no, 'NA') internal_contract_ref_no,
                          iss.invoice_cur_id invoice_cur_id,
                          cm_p.cur_code pay_in_currency,
                          round(iss.total_amount_to_pay, 4) *
                          nvl(iss.fx_to_base, 1) *
                          (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end) amount_in_base_cur,
                          round(iss.total_amount_to_pay, 4) * (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end)invoice_amt,
                          iss.invoice_issue_date invoice_date,
                          iss.payment_due_date invoice_due_date,
                          iss.invoice_type_name invoice_type,
                          iss.bill_to_address bill_to_cp_country,
                          pcm.contract_ref_no || '-' ||
                          ii.delivery_item_ref_no delivery_item_ref_no,
                          ivd.vat_amount_in_vat_cur vat_amount,
                          ivd.vat_remit_cur_id,
                          cm_vat.cur_code vat_remit_currency,
                          (nvl(ivd.fx_rate_vc_ic, 1) *
                          nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
                          (ivd.vat_amount_in_vat_cur *
                          nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
                          null commission_value,
                          null commission_value_ccy,
                          ii.created_user_id,
                          ii.created_user_name
                     from is_invoice_summary                      iss,
                          cm_currency_master                      cm_p,
                          incm_invoice_contract_mapping@eka_appdb incm,
                          ivd_invoice_vat_details@eka_appdb       ivd,
                          pcm_physical_contract_main              pcm,
                          temp_ii                                 ii,
                          cpc_corporate_profit_center             cpc,
                          cpc_corporate_profit_center             cpc1,
                          pcpd_pc_product_definition              pcpd,
                          cm_currency_master                      cm_vat,
                          pdm_productmaster                       pdm,
                          phd_profileheaderdetails                phd_contract_cp,
                          qum_quantity_unit_master                qum,
                          css_corporate_strategy_setup            css
                    where iss.is_active = 'Y'
                      and iss.corporate_id is not null
                      and iss.internal_invoice_ref_no =
                          incm.internal_invoice_ref_no(+)
                      and iss.internal_invoice_ref_no =
                          ivd.internal_invoice_ref_no(+)
                      and incm.internal_contract_ref_no =
                          pcm.internal_contract_ref_no(+)
                      and ii.internal_invoice_ref_no =
                          iss.internal_invoice_ref_no
                      and ii.corporate_id = iss.corporate_id
                      and iss.internal_contract_ref_no =
                          pcpd.internal_contract_ref_no
                      and iss.profit_center_id = cpc.profit_center_id(+)
                      and pcpd.profit_center_id = cpc1.profit_center_id(+)
                      and iss.invoice_cur_id = cm_p.cur_id(+)
                      and pcpd.product_id = pdm.product_id(+)
                      and phd_contract_cp.profileid(+) = iss.cp_id
                      and nvl(pcm.partnership_type, 'Normal') = 'Normal'
                      and iss.invoiced_qty_unit_id = qum.qty_unit_id(+)
                      and iss.is_inv_draft = 'N'
                      and iss.invoice_type_name not in
                          ('Profoma', 'Service')
                      and ivd.vat_remit_cur_id = cm_vat.cur_id(+)
                      and pcpd.input_output = 'Input'
                      and nvl(iss.total_amount_to_pay, 0) <> 0
                      and pcpd.strategy_id = css.strategy_id
                      and iss.process_id = pc_process_id
                      and pcm.process_id = pc_process_id
                      and pcpd.process_id = pc_process_id
                      and phd_contract_cp.is_active = 'Y'
                      and iss.is_modified_today = 'Y'
                      and iss.corporate_id = pc_corporate_id
                   ---2 Service invoices
                   union all
                   select 'Modified' section_name,
                          iss.corporate_id,
                          nvl(pdm.product_id, 'NA'),
                          nvl(pdm.product_desc, 'NA'),
                          iss.cp_id counter_party_id,
                          phd_cp.companyname counter_party_name,
                          iss.invoiced_qty invoice_quantity,
                          nvl(qum.qty_unit, 'NA') invoice_quantity_uom,
                          nvl(iss.fx_to_base, 1) fx_base,
                          coalesce(cpc.profit_center_id,
                                   cpc1.profit_center_id,
                                   'NA') profit_center_id,
                          coalesce(cpc.profit_center_short_name,
                                   cpc1.profit_center_short_name,
                                   'NA') profit_center,
                          pcpd.strategy_id,
                          css.strategy_name,
                          nvl(iss.invoice_ref_no, 'NA') as invoice_ref_no,
                          nvl(pcm.contract_ref_no, 'NA') contract_ref_no,
                          nvl(pcm.internal_contract_ref_no, 'NA') internal_contract_ref_no,
                          iss.invoice_cur_id invoice_cur_id,
                          cm_p.cur_code pay_in_currency,
                          round(iss.total_amount_to_pay, 4) *
                          nvl(iss.fx_to_base, 1) *
                          (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end) amount_in_base_cur,
                          round(iss.total_amount_to_pay, 4) * (case
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Payable' then
                              -1
                             when nvl(iss.payable_receivable, 'NA') =
                                  'Receivable' then
                              1
                             when nvl(iss.payable_receivable, 'NA') = 'NA' then
                              (case
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceReceived' then
                              -1
                             when nvl(iss.invoice_type_name, 'NA') =
                                  'ServiceInvoiceRaised' then
                              1
                             else
                              (case
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Raised' then
                              1
                             when nvl(iss.recieved_raised_type, 'NA') =
                                  'Received' then
                              -1
                             else
                              1
                           end) end) else 1 end)invoice_amt,
                          iss.invoice_issue_date invoice_date,
                          iss.payment_due_date invoice_due_date,
                          nvl(iss.invoice_type_name, 'NA') invoice_type,
                          iss.bill_to_address bill_to_cp_country,
                          pcm.contract_ref_no || '-' ||
                          ii.delivery_item_ref_no delivery_item_ref_no,
                          ivd.vat_amount_in_vat_cur vat_amount,
                          nvl(ivd.vat_remit_cur_id, 'NA'),
                          nvl(cm_vat.cur_code, 'NA') vat_remit_currency,
                          (nvl(ivd.fx_rate_vc_ic, 1) *
                          nvl(iss.fx_to_base, 1)) fx_rate_for_vat,
                          (ivd.vat_amount_in_vat_cur *
                          nvl(iss.fx_to_base, 1)) vat_amount_base_currency,
                          null commission_value,
                          null commission_value_ccy,
                          ii.created_user_id,
                          ii.created_user_name
                     from is_invoice_summary                iss,
                          iam_invoice_action_mapping        iam,
                          iid_invoicable_item_details       iid,
                          axs_action_summary                axs,
                          cs_cost_store                     cs,
                          ivd_invoice_vat_details@eka_appdb ivd,
                          cigc_contract_item_gmr_cost       cigc,
                          gmr_goods_movement_record         gmr,
                          pcpd_pc_product_definition        pcpd,
                          pcm_physical_contract_main        pcm,
                          temp_ii                           ii,
                          cpc_corporate_profit_center       cpc,
                          cpc_corporate_profit_center       cpc1,
                          phd_profileheaderdetails          phd_cp,
                          cm_currency_master                cm_vat,
                          cm_currency_master                cm_p,
                          pdm_productmaster                 pdm,
                          qum_quantity_unit_master          qum,
                          css_corporate_strategy_setup      css,
                          dbd_database_dump                 dbd
                    where iss.internal_contract_ref_no is null
                      and iss.is_active = 'Y'
                      and iss.internal_invoice_ref_no =
                          iam.internal_invoice_ref_no
                      and iss.internal_invoice_ref_no =
                          iid.internal_invoice_ref_no(+)
                      and iss.internal_invoice_ref_no =
                          ivd.internal_invoice_ref_no(+)
                      and iam.invoice_action_ref_no =
                          axs.internal_action_ref_no
                      and iam.invoice_action_ref_no =
                          cs.internal_action_ref_no(+)
                      and cs.cog_ref_no = cigc.cog_ref_no(+)
                      and cigc.internal_gmr_ref_no =
                          gmr.internal_gmr_ref_no(+)
                      and gmr.internal_contract_ref_no =
                          pcpd.internal_contract_ref_no(+)
                      and pcpd.internal_contract_ref_no =
                          pcm.internal_contract_ref_no(+)
                      and ii.internal_invoice_ref_no =
                          iss.internal_invoice_ref_no
                      and ii.corporate_id = iss.corporate_id
                      and iss.invoiced_qty_unit_id = qum.qty_unit_id(+)
                      and pcpd.input_output(+) = 'Input'
                      and iss.invoice_type_name = 'Service'
                      and iss.profit_center_id = cpc.profit_center_id(+)
                      and pcpd.profit_center_id = cpc1.profit_center_id(+)
                      and iss.cp_id = phd_cp.profileid
                      and iss.invoice_cur_id = cm_p.cur_id(+)
                      and pcpd.product_id = pdm.product_id(+)
                      and ivd.vat_remit_cur_id = cm_vat.cur_id(+)
                      and pcpd.strategy_id = css.strategy_id
                      and iss.process_id = pc_process_id
                      and pcm.process_id = pc_process_id
                      and pcpd.process_id = pc_process_id
                      and iss.is_modified_today = 'Y'
                      and pcm.corporate_id = pc_corporate_id
                      and iss.corporate_id = pc_corporate_id
                      and axs.dbd_id = dbd.dbd_id
                      and dbd.corporate_id = pc_corporate_id
                      and dbd.trade_date <= pd_trade_date
                      and dbd.process = pc_process
                    group by pdm.product_id,
                             pdm.product_desc,
                             iss.corporate_id,
                             iss.cp_id,
                             iss.invoiced_qty,
                             iss.fx_to_base,
                             pcm.contract_ref_no,
                             pcm.internal_contract_ref_no,
                             iss.invoice_type,
                             iss.invoice_ref_no,
                             iss.total_amount_to_pay,
                             iss.recieved_raised_type,
                             iss.bill_to_address,
                             iss.invoice_cur_id,
                             iss.invoice_issue_date,
                             iss.payment_due_date,
                             iss.invoice_type_name,
                             phd_cp.companyname,
                             cpc.profit_center_id,
                             cpc.profit_center_short_name,
                             cpc1.profit_center_id,
                             cpc1.profit_center_short_name,
                             cm_p.cur_code,
                             pcm.purchase_sales,
                             qum.qty_unit,
                             ivd.vat_amount_in_vat_cur,
                             ivd.vat_remit_cur_id,
                             cm_vat.cur_code,
                             ivd.fx_rate_vc_ic,
                             ii.delivery_item_ref_no,
                             pcpd.strategy_id,
                             css.strategy_name,
                             ii.created_user_id,
                             ii.created_user_name,
                             iss.payable_receivable)
    loop
      insert into eod_eom_phy_booking_journal
        (section_name,
         corporate_id,
         product_id,
         product_desc,
         counter_party_id,
         counter_party_name,
         invoice_quantity,
         invoice_quantity_uom,
         fx_base,
         profit_center_id,
         profit_center,
         strategy_id,
         strategy_name,
         invoice_ref_no,
         contract_ref_no,
         internal_contract_ref_no,
         invoice_cur_id,
         pay_in_currency,
         amount_in_base_cur,
         invoice_amt,
         invoice_date,
         invoice_due_date,
         invoice_type,
         bill_to_cp_country,
         delivery_item_ref_no,
         vat_amount,
         vat_remit_cur_id,
         vat_remit_currency,
         fx_rate_for_vat,
         vat_amount_base_currency,
         commission_value,
         commission_value_ccy,
         process_id,
         process,
         created_user_id,
         created_user_name)
      values
        (cc_phy.section_name,
         cc_phy.corporate_id,
         cc_phy.product_id,
         cc_phy.product_desc,
         cc_phy.counter_party_id,
         cc_phy.counter_party_name,
         cc_phy.invoice_quantity,
         cc_phy.invoice_quantity_uom,
         cc_phy.fx_base,
         cc_phy.profit_center_id,
         cc_phy.profit_center,
         cc_phy.strategy_id,
         cc_phy.strategy_name,
         cc_phy.invoice_ref_no,
         cc_phy.contract_ref_no,
         cc_phy.internal_contract_ref_no,
         cc_phy.invoice_cur_id,
         cc_phy.pay_in_currency,
         cc_phy.amount_in_base_cur,
         cc_phy.invoice_amt,
         cc_phy.invoice_date,
         cc_phy.invoice_due_date,
         cc_phy.invoice_type,
         cc_phy.bill_to_cp_country,
         cc_phy.delivery_item_ref_no,
         cc_phy.vat_amount,
         cc_phy.vat_remit_cur_id,
         cc_phy.vat_remit_currency,
         cc_phy.fx_rate_for_vat,
         cc_phy.vat_amount_base_currency,
         cc_phy.commission_value,
         cc_phy.commission_value_ccy,
         pc_process_id,
         pc_process,
         cc_phy.created_user_id,
         cc_phy.created_user_name);
    end loop;
    commit;
    sp_gather_table_stats('eod_eom_phy_booking_journal');
    --this code has to be placed before exception....
    for cc in (select akc.corporate_id,
                      akc.corporate_name,
                      akc.base_cur_id,
                      akc.base_currency_name
                 from ak_corporate akc
                where akc.corporate_id = pc_corporate_id)
    loop
      update eod_eom_phy_booking_journal tt
         set tt.corporate_name = cc.corporate_name,
             tt.base_cur_id    = cc.base_cur_id,
             tt.base_currency  = cc.base_currency_name
       where tt.corporate_id = pc_corporate_id
         and tt.process_id = pc_process_id
         and tt.process = pc_process;
    end loop;
    commit;
    for cc in (select tdc.corporate_id,
                      tdc.process_id,
                      tdc.trade_date,
                      tdc.created_date,
                      tdc.process_run_count
                 from tdc_trade_date_closure tdc
                where tdc.process_id = pc_process_id)
    loop
      update eod_eom_phy_booking_journal tt
         set tt.eod_date          = cc.trade_date,
             tt.eod_run_date      = cc.created_date,
             tt.process_run_count = cc.process_run_count
       where tt.corporate_id = pc_corporate_id
         and tt.process_id = pc_process_id
         and tt.process = pc_process;
    end loop;
    commit;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_physical_journal',
                                                           'CDC-004',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_physical_contract_journal(pc_corporate_id    varchar2,
                                         pc_process         varchar2,
                                         pd_trade_date      date,
                                         pc_user_id         varchar2,
                                         pc_process_id      varchar2,
                                         pc_dbd_id          varchar2,
                                         pc_prev_dbd_id     varchar2,
                                         pc_prev_process_id varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_physical_contract_journal
    --        Author                                    : saurabraj
    --        Created Date                              : 25-Jul-2012
    --        Purpose                                   :
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : Trade Date
    --        pc_user_id                                : User ID
    --        pc_process                                : Process EOD or EOM
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    for cr_phy_jornal in (select 'New' catogery,
                                 'Physical' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 null inco_term_id,
                                 null inco_term,
                                 null inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 null element_id,
                                 null element,
                                 diqs.total_qty del_item_qty,
                                 diqs.item_qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 pcbpd.price_basis,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_value
                                   else
                                    0
                                 end) price,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_unit_id
                                   else
                                    null
                                 end) price_unit_id,
                                 ppu_pum_price.price_unit_name,
                                 pcqpd.premium_disc_value,
                                 pcqpd.premium_disc_unit_id,
                                 pcqpd.pd_price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                          
                            from pcm_physical_contract_main    pcm,
                                 pcdi_pc_delivery_item         pcdi,
                                 phd_profileheaderdetails      phd,
                                 ak_corporate_user             ak_trader,
                                 pcpd_pc_product_definition    pcpd,
                                 pdm_productmaster             pdm,
                                 diqs_delivery_item_qty_status diqs,
                                 qum_quantity_unit_master      qum_del,
                                 /*pcqpd_pc_qual_premium_discount pcqpd,*/
                                 (select pcm.contract_ref_no,
                                         pcm.internal_contract_ref_no,
                                         pum.price_unit_id premium_disc_unit_id,
                                         pum.price_unit_name pd_price_unit_name,
                                         sum(pci.item_qty *
                                             pcqpd.premium_disc_value) /
                                         sum(pci.item_qty) premium_disc_value
                                    from pcm_physical_contract_main     pcm,
                                         pcdi_pc_delivery_item          pcdi,
                                         pci_physical_contract_item     pci,
                                         pcqpd_pc_qual_premium_discount pcqpd,
                                         ppu_product_price_units        ppu,
                                         pum_price_unit_master          pum,
                                         pcpdqd_pd_quality_details      pcpdqd
                                   where pcm.internal_contract_ref_no =
                                         pcdi.internal_contract_ref_no
                                     and pcdi.pcdi_id = pci.pcdi_id
                                     and pci.pcpq_id = pcpdqd.pcpq_id
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.internal_contract_ref_no =
                                         pcqpd.internal_contract_ref_no(+)
                                     and pcqpd.premium_disc_unit_id =
                                         ppu.internal_price_unit_id(+)
                                     and ppu.price_unit_id =
                                         pum.price_unit_id(+)
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.process_id = pc_process_id
                                     and pcdi.process_id = pc_process_id
                                     and pci.process_id = pc_process_id
                                     and pcqpd.process_id = pc_process_id
                                     and pcm.corporate_id = pc_corporate_id
                                     and pcm.is_active = 'Y'
                                     and pcqpd.is_active = 'Y'
                                   group by pcm.contract_ref_no,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_id,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_name) pcqpd,
                                 --v_ppu_pum                      ppu_pum,
                                 ak_corporate                   akc,
                                 pcbph_pc_base_price_header     pcbph,
                                 poch_price_opt_call_off_header poch,
                                 pcbpd_pc_base_price_detail     pcbpd,
                                 pocd_price_option_calloff_dtls pocd,
                                 pffxd_phy_formula_fx_details   pffxd,
                                 v_ppu_pum                      ppu_pum_price,
                                 cqs_contract_qty_status        cqs,
                                 qum_quantity_unit_master       qum_cont,
                                 cpc_corporate_profit_center    cpc,
                                 css_corporate_strategy_setup   css
                          
                           where pcm.contract_type = 'BASEMETAL'
                             and pcm.process_id = pc_process_id
                             and pcm.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcpd.product_id = pdm.product_id
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = diqs.pcdi_id
                             and diqs.process_id = pc_process_id
                             and diqs.is_active = 'Y'
                             and diqs.item_qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcm.corporate_id = akc.corporate_id
                             and pcm.internal_contract_ref_no =
                                 pcbph.internal_contract_ref_no
                             and pcbph.process_id = pc_process_id
                             and pcdi.pcdi_id = poch.pcdi_id
                             and poch.pcbph_id = pcbph.pcbph_id
                             and poch.is_active = 'Y'
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and poch.poch_id = pocd.poch_id
                             and pocd.pcbpd_id = pcbpd.pcbpd_id
                             and pocd.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.contract_status <> 'Cancelled'
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and css.is_active = 'Y'
                             and pcm.approval_status = 'Approved'
                             and pcdi.price_option_call_off_status in
                                 ('Not Applicable', 'Called Off')
                             and not exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm.internal_contract_ref_no =
                                         pcm_in.internal_contract_ref_no
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.process_id =
                                         pc_prev_process_id)
                          union all
                          select 'New' catogery,
                                 'Physical' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 null inco_term_id,
                                 null inco_term,
                                 null inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 null element_id,
                                 null element,
                                 diqs.total_qty del_item_qty,
                                 diqs.item_qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 --For not called off , no need to show the pricing details
                                 /*pcbpd.price_basis,
                                                                                                                                                                                                                                                                        (case
                                                                                                                                                                                                                                                                          when pcbpd.price_basis = 'Fixed' then
                                                                                                                                                                                                                                                                           pcbpd.price_value
                                                                                                                                                                                                                                                                          else
                                                                                                                                                                                                                                                                           0
                                                                                                                                                                                                                                                                        end) price,
                                                                                                                                                                                                                                                                        (case
                                                                                                                                                                                                                                                                          when pcbpd.price_basis = 'Fixed' then
                                                                                                                                                                                                                                                                           pcbpd.price_unit_id
                                                                                                                                                                                                                                                                          else
                                                                                                                                                                                                                                                                           null
                                                                                                                                                                                                                                                                        end) price_unit_id,
                                                                                                                                                                                                                                                                        ppu_pum_price.price_unit_name,*/
                                 null price_basis,
                                 0 price,
                                 null price_unit_id,
                                 null price_unit_name,
                                 pcqpd.premium_disc_value,
                                 pcqpd.premium_disc_unit_id,
                                 pcqpd.pd_price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                          
                            from pcm_physical_contract_main    pcm,
                                 pcdi_pc_delivery_item         pcdi,
                                 phd_profileheaderdetails      phd,
                                 ak_corporate_user             ak_trader,
                                 pcpd_pc_product_definition    pcpd,
                                 pdm_productmaster             pdm,
                                 diqs_delivery_item_qty_status diqs,
                                 qum_quantity_unit_master      qum_del,
                                 /*pcqpd_pc_qual_premium_discount pcqpd,*/
                                 (select pcm.contract_ref_no,
                                         pcm.internal_contract_ref_no,
                                         pum.price_unit_id premium_disc_unit_id,
                                         pum.price_unit_name pd_price_unit_name,
                                         sum(pci.item_qty *
                                             pcqpd.premium_disc_value) /
                                         sum(pci.item_qty) premium_disc_value
                                    from pcm_physical_contract_main     pcm,
                                         pcdi_pc_delivery_item          pcdi,
                                         pci_physical_contract_item     pci,
                                         pcqpd_pc_qual_premium_discount pcqpd,
                                         ppu_product_price_units        ppu,
                                         pum_price_unit_master          pum,
                                         pcpdqd_pd_quality_details      pcpdqd
                                   where pcm.internal_contract_ref_no =
                                         pcdi.internal_contract_ref_no
                                     and pcdi.pcdi_id = pci.pcdi_id
                                     and pci.pcpq_id = pcpdqd.pcpq_id
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.internal_contract_ref_no =
                                         pcqpd.internal_contract_ref_no(+)
                                     and pcqpd.premium_disc_unit_id =
                                         ppu.internal_price_unit_id(+)
                                     and ppu.price_unit_id =
                                         pum.price_unit_id(+)
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.process_id = pc_process_id
                                     and pcdi.process_id = pc_process_id
                                     and pci.process_id = pc_process_id
                                     and pcqpd.process_id = pc_process_id
                                     and pcm.corporate_id = pc_corporate_id
                                     and pcm.is_active = 'Y'
                                     and pcqpd.is_active = 'Y'
                                   group by pcm.contract_ref_no,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_id,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_name) pcqpd,
                                 --v_ppu_pum                      ppu_pum,
                                 ak_corporate                 akc,
                                 pci_physical_contract_item   pci,
                                 pcipf_pci_pricing_formula    pcipf,
                                 pcbph_pc_base_price_header   pcbph,
                                 pcbpd_pc_base_price_detail   pcbpd,
                                 pffxd_phy_formula_fx_details pffxd,
                                 v_ppu_pum                    ppu_pum_price,
                                 cqs_contract_qty_status      cqs,
                                 qum_quantity_unit_master     qum_cont,
                                 cpc_corporate_profit_center  cpc,
                                 css_corporate_strategy_setup css
                          
                           where pcm.contract_type = 'BASEMETAL'
                             and pcm.process_id = pc_process_id
                             and pcm.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcpd.product_id = pdm.product_id
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = diqs.pcdi_id
                             and diqs.process_id = pc_process_id
                             and diqs.is_active = 'Y'
                             and diqs.item_qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcm.corporate_id = akc.corporate_id
                             and pcdi.pcdi_id = pci.pcdi_id
                             and pci.process_id = pc_process_id
                             and pci.is_active = 'Y'
                             and pci.internal_contract_item_ref_no =
                                 pcipf.internal_contract_item_ref_no
                             and pcipf.process_id = pc_process_id
                             and pcipf.is_active = 'Y'
                             and pcipf.pcbph_id = pcbph.pcbph_id
                                /*and pcm.internal_contract_ref_no =
                                                                                                                                                                 pcbph.internal_contract_ref_no*/
                             and pcbph.process_id = pc_process_id
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.contract_status <> 'Cancelled'
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and css.is_active = 'Y'
                             and pcm.approval_status = 'Approved'
                             and pcdi.price_option_call_off_status in
                                 ('Not Called Off')
                             and not exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm.internal_contract_ref_no =
                                         pcm_in.internal_contract_ref_no
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.process_id =
                                         pc_prev_process_id)
                          union all
                          select 'Deleted' catogery,
                                 'Physical' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 null inco_term_id,
                                 null inco_term,
                                 null inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 null element_id,
                                 null element,
                                 diqs.total_qty del_item_qty,
                                 diqs.item_qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 --For not called off , no need to show the pricing
                                 /*pcbpd.price_basis,
                                                                                                                                                                                                                                       (case
                                                                                                                                                                                                                                         when pcbpd.price_basis = 'Fixed' then
                                                                                                                                                                                                                                          pcbpd.price_value
                                                                                                                                                                                                                                         else
                                                                                                                                                                                                                                          0
                                                                                                                                                                                                                                       end) price,
                                                                                                                                                                                                                                       (case
                                                                                                                                                                                                                                         when pcbpd.price_basis = 'Fixed' then
                                                                                                                                                                                                                                          pcbpd.price_unit_id
                                                                                                                                                                                                                                         else
                                                                                                                                                                                                                                          null
                                                                                                                                                                                                                                       end) price_unit_id,
                                                                                                                                                                                                                                       ppu_pum_price.price_unit_name,*/
                                 null price_basis,
                                 0 price,
                                 null price_unit_id,
                                 null price_unit_name,
                                 pcqpd.premium_disc_value,
                                 pcqpd.premium_disc_unit_id,
                                 pcqpd.pd_price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                            from pcm_physical_contract_main    pcm,
                                 pcdi_pc_delivery_item         pcdi,
                                 phd_profileheaderdetails      phd,
                                 ak_corporate_user             ak_trader,
                                 pcpd_pc_product_definition    pcpd,
                                 pdm_productmaster             pdm,
                                 diqs_delivery_item_qty_status diqs,
                                 qum_quantity_unit_master      qum_del,
                                 /*pcqpd_pc_qual_premium_discount pcqpd,*/
                                 (select pcm.contract_ref_no,
                                         pcm.internal_contract_ref_no,
                                         pum.price_unit_id premium_disc_unit_id,
                                         pum.price_unit_name pd_price_unit_name,
                                         sum(pci.item_qty *
                                             pcqpd.premium_disc_value) /
                                         sum(pci.item_qty) premium_disc_value
                                  
                                    from pcm_physical_contract_main     pcm,
                                         pcdi_pc_delivery_item          pcdi,
                                         pci_physical_contract_item     pci,
                                         pcqpd_pc_qual_premium_discount pcqpd,
                                         ppu_product_price_units        ppu,
                                         pum_price_unit_master          pum,
                                         pcpdqd_pd_quality_details      pcpdqd
                                   where pcm.internal_contract_ref_no =
                                         pcdi.internal_contract_ref_no
                                     and pcdi.pcdi_id = pci.pcdi_id
                                     and pci.pcpq_id = pcpdqd.pcpq_id
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.internal_contract_ref_no =
                                         pcqpd.internal_contract_ref_no(+)
                                     and pcqpd.premium_disc_unit_id =
                                         ppu.internal_price_unit_id(+)
                                     and ppu.price_unit_id =
                                         pum.price_unit_id(+)
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.process_id = pc_process_id
                                     and pcdi.process_id = pc_process_id
                                     and pci.process_id = pc_process_id
                                     and pcqpd.process_id = pc_process_id
                                     and pcm.corporate_id = pc_corporate_id
                                     and pcm.is_active = 'Y'
                                     and pcqpd.is_active = 'Y'
                                   group by pcm.contract_ref_no,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_id,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_name) pcqpd,
                                 --v_ppu_pum                      ppu_pum,
                                 ak_corporate                 akc,
                                 pci_physical_contract_item   pci,
                                 pcipf_pci_pricing_formula    pcipf,
                                 pcbph_pc_base_price_header   pcbph,
                                 pcbpd_pc_base_price_detail   pcbpd,
                                 pffxd_phy_formula_fx_details pffxd,
                                 v_ppu_pum                    ppu_pum_price,
                                 cqs_contract_qty_status      cqs,
                                 qum_quantity_unit_master     qum_cont,
                                 cpc_corporate_profit_center  cpc,
                                 css_corporate_strategy_setup css
                           where pcm.contract_type = 'BASEMETAL'
                             and pcm.process_id = pc_process_id
                             and pcm.is_active = 'Y'
                             and pcm.contract_status = 'Cancelled'
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcpd.product_id = pdm.product_id
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = diqs.pcdi_id
                             and diqs.process_id = pc_process_id
                             and diqs.is_active = 'Y'
                             and diqs.item_qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcm.corporate_id = akc.corporate_id
                                /* and pcm.internal_contract_ref_no =
                                                                                                                                                                 pcbph.internal_contract_ref_no*/
                             and pcdi.pcdi_id = pci.pcdi_id
                             and pci.process_id = pc_process_id
                             and pci.is_active = 'Y'
                             and pci.internal_contract_item_ref_no =
                                 pcipf.internal_contract_item_ref_no
                             and pcipf.process_id = pc_process_id
                             and pcipf.is_active = 'Y'
                             and pcipf.pcbph_id = pcbph.pcbph_id
                             and pcbph.process_id = pc_process_id
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and css.is_active = 'Y'
                             and pcm.approval_status = 'Approved'
                             and pcdi.price_option_call_off_status in
                                 ('Not Called Off')
                             and exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm_in.internal_contract_ref_no =
                                         pcm.internal_contract_ref_no
                                     and pcm_in.process_id =
                                         pc_prev_process_id
                                     and pcm_in.corporate_id =
                                         pc_corporate_id
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.contract_status <>
                                         'Cancelled')
                          union all
                          select 'Deleted' catogery,
                                 'Physical' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 null inco_term_id,
                                 null inco_term,
                                 null inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 null element_id,
                                 null element,
                                 diqs.total_qty del_item_qty,
                                 diqs.item_qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 pcbpd.price_basis,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_value
                                   else
                                    0
                                 end) price,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_unit_id
                                   else
                                    null
                                 end) price_unit_id,
                                 ppu_pum_price.price_unit_name,
                                 pcqpd.premium_disc_value,
                                 pcqpd.premium_disc_unit_id,
                                 pcqpd.pd_price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                            from pcm_physical_contract_main    pcm,
                                 pcdi_pc_delivery_item         pcdi,
                                 phd_profileheaderdetails      phd,
                                 ak_corporate_user             ak_trader,
                                 pcpd_pc_product_definition    pcpd,
                                 pdm_productmaster             pdm,
                                 diqs_delivery_item_qty_status diqs,
                                 qum_quantity_unit_master      qum_del,
                                 /*pcqpd_pc_qual_premium_discount pcqpd,*/
                                 (select pcm.contract_ref_no,
                                         pcm.internal_contract_ref_no,
                                         pum.price_unit_id premium_disc_unit_id,
                                         pum.price_unit_name pd_price_unit_name,
                                         sum(pci.item_qty *
                                             pcqpd.premium_disc_value) /
                                         sum(pci.item_qty) premium_disc_value
                                  
                                    from pcm_physical_contract_main     pcm,
                                         pcdi_pc_delivery_item          pcdi,
                                         pci_physical_contract_item     pci,
                                         pcqpd_pc_qual_premium_discount pcqpd,
                                         ppu_product_price_units        ppu,
                                         pum_price_unit_master          pum,
                                         pcpdqd_pd_quality_details      pcpdqd
                                   where pcm.internal_contract_ref_no =
                                         pcdi.internal_contract_ref_no
                                     and pcdi.pcdi_id = pci.pcdi_id
                                     and pci.pcpq_id = pcpdqd.pcpq_id
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.internal_contract_ref_no =
                                         pcqpd.internal_contract_ref_no(+)
                                     and pcqpd.premium_disc_unit_id =
                                         ppu.internal_price_unit_id(+)
                                     and ppu.price_unit_id =
                                         pum.price_unit_id(+)
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.process_id = pc_process_id
                                     and pcdi.process_id = pc_process_id
                                     and pci.process_id = pc_process_id
                                     and pcqpd.process_id = pc_process_id
                                     and pcm.corporate_id = pc_corporate_id
                                     and pcm.is_active = 'Y'
                                     and pcqpd.is_active = 'Y'
                                   group by pcm.contract_ref_no,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_id,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_name) pcqpd,
                                 --v_ppu_pum                      ppu_pum,
                                 ak_corporate                   akc,
                                 pcbph_pc_base_price_header     pcbph,
                                 poch_price_opt_call_off_header poch,
                                 pcbpd_pc_base_price_detail     pcbpd,
                                 pocd_price_option_calloff_dtls pocd,
                                 pffxd_phy_formula_fx_details   pffxd,
                                 v_ppu_pum                      ppu_pum_price,
                                 cqs_contract_qty_status        cqs,
                                 qum_quantity_unit_master       qum_cont,
                                 cpc_corporate_profit_center    cpc,
                                 css_corporate_strategy_setup   css
                           where pcm.contract_type = 'BASEMETAL'
                             and pcm.process_id = pc_process_id
                             and pcm.is_active = 'Y'
                             and pcm.contract_status = 'Cancelled'
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcpd.product_id = pdm.product_id
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = diqs.pcdi_id
                             and diqs.process_id = pc_process_id
                             and diqs.is_active = 'Y'
                             and diqs.item_qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcm.corporate_id = akc.corporate_id
                             and pcm.internal_contract_ref_no =
                                 pcbph.internal_contract_ref_no
                             and pcbph.process_id = pc_process_id
                             and pcdi.pcdi_id = poch.pcdi_id
                             and poch.pcbph_id = pcbph.pcbph_id
                             and poch.is_active = 'Y'
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and poch.poch_id = pocd.poch_id
                             and pocd.pcbpd_id = pcbpd.pcbpd_id
                             and pocd.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and css.is_active = 'Y'
                             and pcm.approval_status = 'Approved'
                             and pcdi.price_option_call_off_status in
                                 ('Not Applicable', 'Called Off')
                             and exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm_in.internal_contract_ref_no =
                                         pcm.internal_contract_ref_no
                                     and pcm_in.process_id =
                                         pc_prev_process_id
                                     and pcm_in.corporate_id =
                                         pc_corporate_id
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.contract_status <>
                                         'Cancelled')
                          union all
                          select 'Modified' catogery,
                                 'Physical' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 null inco_term_id,
                                 null inco_term,
                                 null inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 null element_id,
                                 null element,
                                 diqs.total_qty del_item_qty,
                                 diqs.item_qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 --Not called off So no price details
                                 /*pcbpd.price_basis,
                                                                                                                                                                                                                                       (case
                                                                                                                                                                                                                                         when pcbpd.price_basis = 'Fixed' then
                                                                                                                                                                                                                                          pcbpd.price_value
                                                                                                                                                                                                                                         else
                                                                                                                                                                                                                                          0
                                                                                                                                                                                                                                       end) price,
                                                                                                                                                                                                                                       (case
                                                                                                                                                                                                                                         when pcbpd.price_basis = 'Fixed' then
                                                                                                                                                                                                                                          pcbpd.price_unit_id
                                                                                                                                                                                                                                         else
                                                                                                                                                                                                                                          null
                                                                                                                                                                                                                                       end) price_unit_id,
                                                                                                                                                                                                                                       ppu_pum_price.price_unit_name,*/
                                 null price_basis,
                                 0 price,
                                 null price_unit_id,
                                 null price_unit_name,
                                 pcqpd.premium_disc_value,
                                 pcqpd.premium_disc_unit_id,
                                 pcqpd.pd_price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                            from pcm_physical_contract_main    pcm,
                                 pcdi_pc_delivery_item         pcdi,
                                 phd_profileheaderdetails      phd,
                                 ak_corporate_user             ak_trader,
                                 pcpd_pc_product_definition    pcpd,
                                 pdm_productmaster             pdm,
                                 diqs_delivery_item_qty_status diqs,
                                 qum_quantity_unit_master      qum_del,
                                 /*pcqpd_pc_qual_premium_discount pcqpd,*/
                                 (select pcm.contract_ref_no,
                                         pcm.internal_contract_ref_no,
                                         pum.price_unit_id premium_disc_unit_id,
                                         pum.price_unit_name pd_price_unit_name,
                                         sum(pci.item_qty *
                                             pcqpd.premium_disc_value) /
                                         sum(pci.item_qty) premium_disc_value
                                    from pcm_physical_contract_main     pcm,
                                         pcdi_pc_delivery_item          pcdi,
                                         pci_physical_contract_item     pci,
                                         pcqpd_pc_qual_premium_discount pcqpd,
                                         ppu_product_price_units        ppu,
                                         pum_price_unit_master          pum,
                                         pcpdqd_pd_quality_details      pcpdqd
                                   where pcm.internal_contract_ref_no =
                                         pcdi.internal_contract_ref_no
                                     and pcdi.pcdi_id = pci.pcdi_id
                                     and pci.pcpq_id = pcpdqd.pcpq_id
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.internal_contract_ref_no =
                                         pcqpd.internal_contract_ref_no(+)
                                     and pcqpd.premium_disc_unit_id =
                                         ppu.internal_price_unit_id(+)
                                     and ppu.price_unit_id =
                                         pum.price_unit_id(+)
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.process_id = pc_process_id
                                     and pcdi.process_id = pc_process_id
                                     and pci.process_id = pc_process_id
                                     and pcqpd.process_id = pc_process_id
                                     and pcm.corporate_id = pc_corporate_id
                                     and pcm.is_active = 'Y'
                                     and pcqpd.is_active = 'Y'
                                   group by pcm.contract_ref_no,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_id,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_name) pcqpd,
                                 --v_ppu_pum                      ppu_pum,
                                 ak_corporate                 akc,
                                 pci_physical_contract_item   pci,
                                 pcipf_pci_pricing_formula    pcipf,
                                 pcbph_pc_base_price_header   pcbph,
                                 pcbpd_pc_base_price_detail   pcbpd,
                                 pffxd_phy_formula_fx_details pffxd,
                                 v_ppu_pum                    ppu_pum_price,
                                 cqs_contract_qty_status      cqs,
                                 qum_quantity_unit_master     qum_cont,
                                 cpc_corporate_profit_center  cpc,
                                 css_corporate_strategy_setup css
                           where pcm.contract_type = 'BASEMETAL'
                             and pcm.process_id = pc_process_id
                             and pcm.contract_status = 'In Position'
                             and pcm.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcpd.product_id = pdm.product_id
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = diqs.pcdi_id
                             and diqs.process_id = pc_process_id
                             and diqs.is_active = 'Y'
                             and diqs.item_qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcm.corporate_id = akc.corporate_id
                                /*and pcm.internal_contract_ref_no =
                                                                                                                                                                 pcbph.internal_contract_ref_no*/
                             and pcdi.pcdi_id = pci.pcdi_id
                             and pci.process_id = pc_process_id
                             and pci.is_active = 'Y'
                             and pci.internal_contract_item_ref_no =
                                 pcipf.internal_contract_item_ref_no
                             and pcipf.process_id = pc_process_id
                             and pcipf.is_active = 'Y'
                             and pcipf.pcbph_id = pcbph.pcbph_id
                             and pcbph.process_id = pc_process_id
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and css.is_active = 'Y'
                             and pcm.approval_status = 'Approved'
                             and pcdi.price_option_call_off_status in
                                 ('Not Called Off')
                             and exists
                           (select pca.internal_contract_ref_no
                              from pca_physical_contract_action pca
                            where pca.internal_contract_ref_no=pcm.internal_contract_ref_no
                             and pca.process_id=pc_process_id
                             union
                             select cod.contract_ref_no
                              from cod_call_off_details cod
                                   where cod.contract_ref_no = pcm.internal_contract_ref_no
                                   and cod.process_id=pc_process_id)
                             and exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm_in.internal_contract_ref_no =
                                         pcm.internal_contract_ref_no
                                     and pcm_in.process_id =
                                         pc_prev_process_id -------prev
                                     and pcm_in.corporate_id =
                                         pc_corporate_id
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.contract_status <>
                                         'Cancelled')
                          union all
                          select 'Modified' catogery,
                                 'Physical' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 null inco_term_id,
                                 null inco_term,
                                 null inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 null element_id,
                                 null element,
                                 diqs.total_qty del_item_qty,
                                 diqs.item_qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 pcbpd.price_basis,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_value
                                   else
                                    0
                                 end) price,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_unit_id
                                   else
                                    null
                                 end) price_unit_id,
                                 ppu_pum_price.price_unit_name,
                                 pcqpd.premium_disc_value,
                                 pcqpd.premium_disc_unit_id,
                                 pcqpd.pd_price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                            from pcm_physical_contract_main    pcm,
                                 pcdi_pc_delivery_item         pcdi,
                                 phd_profileheaderdetails      phd,
                                 ak_corporate_user             ak_trader,
                                 pcpd_pc_product_definition    pcpd,
                                 pdm_productmaster             pdm,
                                 diqs_delivery_item_qty_status diqs,
                                 qum_quantity_unit_master      qum_del,
                                 /*pcqpd_pc_qual_premium_discount pcqpd,*/
                                 (select pcm.contract_ref_no,
                                         pcm.internal_contract_ref_no,
                                         pum.price_unit_id premium_disc_unit_id,
                                         pum.price_unit_name pd_price_unit_name,
                                         sum(pci.item_qty *
                                             pcqpd.premium_disc_value) /
                                         sum(pci.item_qty) premium_disc_value
                                    from pcm_physical_contract_main     pcm,
                                         pcdi_pc_delivery_item          pcdi,
                                         pci_physical_contract_item     pci,
                                         pcqpd_pc_qual_premium_discount pcqpd,
                                         ppu_product_price_units        ppu,
                                         pum_price_unit_master          pum,
                                         pcpdqd_pd_quality_details      pcpdqd
                                   where pcm.internal_contract_ref_no =
                                         pcdi.internal_contract_ref_no
                                     and pcdi.pcdi_id = pci.pcdi_id
                                     and pci.pcpq_id = pcpdqd.pcpq_id
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.internal_contract_ref_no =
                                         pcqpd.internal_contract_ref_no(+)
                                     and pcqpd.premium_disc_unit_id =
                                         ppu.internal_price_unit_id(+)
                                     and ppu.price_unit_id =
                                         pum.price_unit_id(+)
                                     and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                     and pcm.process_id = pc_process_id
                                     and pcdi.process_id = pc_process_id
                                     and pci.process_id = pc_process_id
                                     and pcqpd.process_id = pc_process_id
                                     and pcm.corporate_id = pc_corporate_id
                                     and pcm.is_active = 'Y'
                                     and pcqpd.is_active = 'Y'
                                   group by pcm.contract_ref_no,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_id,
                                            pcm.internal_contract_ref_no,
                                            pum.price_unit_name) pcqpd,
                                 --v_ppu_pum                      ppu_pum,
                                 ak_corporate                   akc,
                                 pcbph_pc_base_price_header     pcbph,
                                 poch_price_opt_call_off_header poch,
                                 pcbpd_pc_base_price_detail     pcbpd,
                                 pocd_price_option_calloff_dtls pocd,
                                 pffxd_phy_formula_fx_details   pffxd,
                                 v_ppu_pum                      ppu_pum_price,
                                 cqs_contract_qty_status        cqs,
                                 qum_quantity_unit_master       qum_cont,
                                 cpc_corporate_profit_center    cpc,
                                 css_corporate_strategy_setup   css
                           where pcm.contract_type = 'BASEMETAL'
                             and pcm.process_id = pc_process_id
                             and pcm.contract_status = 'In Position'
                             and pcm.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcpd.product_id = pdm.product_id
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = diqs.pcdi_id
                             and diqs.process_id = pc_process_id
                             and diqs.is_active = 'Y'
                             and diqs.item_qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcm.corporate_id = akc.corporate_id
                             and pcm.internal_contract_ref_no =
                                 pcbph.internal_contract_ref_no
                             and pcbph.process_id = pc_process_id
                             and pcdi.pcdi_id = poch.pcdi_id
                             and poch.pcbph_id = pcbph.pcbph_id
                             and poch.is_active = 'Y'
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and poch.poch_id = pocd.poch_id
                             and pocd.pcbpd_id = pcbpd.pcbpd_id
                             and pocd.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and css.is_active = 'Y'
                             and pcdi.price_option_call_off_status in
                                 ('Not Applicable', 'Called Off')
                             and exists
                           (select pca.internal_contract_ref_no
                              from pca_physical_contract_action pca
                            where pca.internal_contract_ref_no=pcm.internal_contract_ref_no
                             and pca.process_id=pc_process_id
                             union
                             select cod.contract_ref_no
                              from cod_call_off_details cod
                                   where cod.contract_ref_no = pcm.internal_contract_ref_no
                                   and cod.process_id=pc_process_id)
                             and exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm_in.internal_contract_ref_no =
                                         pcm.internal_contract_ref_no
                                     and pcm_in.process_id =
                                         pc_prev_process_id -------prev
                                     and pcm_in.corporate_id =
                                         pc_corporate_id
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.contract_status <>
                                         'Cancelled')
                          --for Concentrate
                          union all
                          select 'New' catogery,
                                 'Physical' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 pcdb.inco_term_id,
                                 itm.incoterm inco_term,
                                 cim_inco.city_name inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 cipq.element_id,
                                 null element,
                                 cipq.payable_qty del_item_qty,
                                 cipq.qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 pcbpd.price_basis,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_value
                                   else
                                    0
                                 end) price,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_unit_id
                                   else
                                    null
                                 end) price_unit_id,
                                 ppu_pum_price.price_unit_name,
                                 pcqpd.premium_disc_value, ---here we need to sum  premium of all delivery_item for a contract,same for inco_term
                                 pcqpd.premium_disc_unit_id,
                                 ppu_pum.price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                            from pcm_physical_contract_main     pcm,
                                 pcdi_pc_delivery_item          pcdi,
                                 phd_profileheaderdetails       phd,
                                 ak_corporate_user              ak_trader,
                                 pcdb_pc_delivery_basis         pcdb,
                                 pcpd_pc_product_definition     pcpd,
                                 itm_incoterm_master            itm,
                                 pdm_productmaster              pdm,
                                 pci_physical_contract_item     pci,
                                 cipq_contract_item_payable_qty cipq,
                                 qum_quantity_unit_master       qum_del,
                                 pcqpd_pc_qual_premium_discount pcqpd,
                                 v_ppu_pum                      ppu_pum,
                                 ak_corporate                   akc,
                                 pcbph_pc_base_price_header     pcbph,
                                 pcbpd_pc_base_price_detail     pcbpd,
                                 pffxd_phy_formula_fx_details   pffxd,
                                 v_ppu_pum                      ppu_pum_price,
                                 cqs_contract_qty_status        cqs,
                                 qum_quantity_unit_master       qum_cont,
                                 cpc_corporate_profit_center    cpc,
                                 css_corporate_strategy_setup   css,
                                 cim_citymaster                 cim_inco
                           where pcm.contract_type = 'CONCENTRATES'
                             and pcm.is_tolling_contract = 'N'
                             and pcm.process_id = pc_process_id
                             and pcm.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcdb.internal_contract_ref_no
                             and pcdb.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcdb.inco_term_id = itm.incoterm_id
                             and itm.is_active = 'Y'
                             and itm.is_deleted = 'N'
                             and pcpd.product_id = pdm.product_id
                             and pcpd.input_output = 'Input'
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = pci.pcdi_id
                             and pci.internal_contract_item_ref_no =
                                 cipq.internal_contract_item_ref_no
                             and cipq.is_active = 'Y'
                             and cipq.qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcqpd.process_id(+) = pc_process_id
                             and pcqpd.premium_disc_unit_id =
                                 ppu_pum.product_price_unit_id(+)
                             and pcm.corporate_id = akc.corporate_id
                             and pcm.internal_contract_ref_no =
                                 pcbph.internal_contract_ref_no
                             and cipq.element_id = pcbph.element_id
                             and pcbph.process_id = pc_process_id
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcqpd.pffxd_id = pffxd.pffxd_id
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.contract_status <> 'Cancelled'
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and cim_inco.city_id = pcdb.city_id
                             and css.is_active = 'Y'
                             and pcm.approval_status = 'Approved'
                             and not exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm.internal_contract_ref_no =
                                         pcm_in.internal_contract_ref_no
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.process_id =
                                         pc_prev_process_id)
                          union all
                          select 'Modified' catogery,
                                 'Physical ' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 pcdb.inco_term_id,
                                 itm.incoterm inco_term,
                                 cim_inco.city_name inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 cipq.element_id,
                                 null element,
                                 cipq.payable_qty del_item_qty,
                                 cipq.qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 pcbpd.price_basis,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_value
                                   else
                                    0
                                 end) price,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_unit_id
                                   else
                                    null
                                 end) price_unit_id,
                                 ppu_pum_price.price_unit_name,
                                 pcqpd.premium_disc_value,
                                 pcqpd.premium_disc_unit_id,
                                 ppu_pum.price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                            from pcm_physical_contract_main     pcm,
                                 pcmul_phy_contract_main_ul     pcmul,
                                 axs_action_summary             axs,
                                 pcdi_pc_delivery_item          pcdi,
                                 phd_profileheaderdetails       phd,
                                 ak_corporate_user              ak_trader,
                                 pcdb_pc_delivery_basis         pcdb,
                                 pcpd_pc_product_definition     pcpd,
                                 itm_incoterm_master            itm,
                                 pdm_productmaster              pdm,
                                 pci_physical_contract_item     pci,
                                 cipq_contract_item_payable_qty cipq,
                                 qum_quantity_unit_master       qum_del,
                                 pcqpd_pc_qual_premium_discount pcqpd,
                                 v_ppu_pum                      ppu_pum,
                                 ak_corporate                   akc,
                                 pcbph_pc_base_price_header     pcbph,
                                 pcbpd_pc_base_price_detail     pcbpd,
                                 pffxd_phy_formula_fx_details   pffxd,
                                 v_ppu_pum                      ppu_pum_price,
                                 cqs_contract_qty_status        cqs,
                                 qum_quantity_unit_master       qum_cont,
                                 cpc_corporate_profit_center    cpc,
                                 css_corporate_strategy_setup   css,
                                 cim_citymaster                 cim_inco
                           where pcm.internal_contract_ref_no =
                                 pcmul.internal_contract_ref_no
                             and pcm.contract_type = 'CONCENTRATES'
                             and pcm.is_tolling_contract = 'N'
                             and pcm.process_id = pc_process_id
                             and pcmul.dbd_id = pc_dbd_id
                             and pcmul.contract_status = 'In Position'
                             and pcm.is_active = 'Y'
                             and pcmul.is_active = 'Y'
                             and pcmul.entry_type = 'Update'
                             and pcmul.internal_action_ref_no =
                                 axs.internal_action_ref_no
                             and axs.dbd_id = pc_dbd_id
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcdb.internal_contract_ref_no
                             and pcdb.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcdb.inco_term_id = itm.incoterm_id
                             and itm.is_active = 'Y'
                             and itm.is_deleted = 'N'
                             and pcpd.product_id = pdm.product_id
                             and pcpd.input_output = 'Input'
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = pci.pcdi_id
                             and pci.internal_contract_item_ref_no =
                                 cipq.internal_contract_item_ref_no
                             and cipq.is_active = 'Y'
                             and cipq.qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcqpd.process_id(+) = pc_process_id
                             and pcqpd.dbd_id(+) = pc_dbd_id
                             and pcqpd.premium_disc_unit_id =
                                 ppu_pum.product_price_unit_id(+)
                             and pcm.corporate_id = akc.corporate_id
                             and pcm.internal_contract_ref_no =
                                 pcbph.internal_contract_ref_no
                             and cipq.element_id = pcbph.element_id
                             and pcbph.process_id = pc_process_id
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcqpd.pffxd_id = pffxd.pffxd_id
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and cim_inco.city_id = pcdb.city_id
                             and css.is_active = 'Y'
                             and pcm.approval_status = 'Approved'
                             and exists
                           (select pcmul.internal_contract_ref_no
                                    from pcmul_phy_contract_main_ul pcmul
                                   where pcmul.dbd_id = pc_dbd_id
                                     and pcmul.internal_contract_ref_no =
                                         pcm.internal_contract_ref_no
                                     and pcmul.entry_type = 'Update'
                                     and pcm.approval_status = 'Approved'
                                     and nvl(pcmul.contract_status, 'none') <>
                                         'Cancelled')
                             and exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm_in.internal_contract_ref_no =
                                         pcm.internal_contract_ref_no
                                     and pcm_in.process_id =
                                         pc_prev_process_id -------prev
                                     and pcm_in.corporate_id =
                                         pc_corporate_id
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.contract_status <>
                                         'Cancelled')
                          union all
                          select 'Deleted' catogery,
                                 'Physical ' book_type,
                                 pcm.corporate_id,
                                 akc.corporate_name,
                                 pcm.contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no del_item_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.cp_id,
                                 phd.companyname,
                                 pcm.trader_id,
                                 ak_trader.login_name trader,
                                 pcdb.inco_term_id,
                                 itm.incoterm inco_term,
                                 cim_inco.city_name inco_term_location,
                                 pcm.issue_date,
                                 pcpd.product_id,
                                 pdm.product_desc,
                                 cipq.element_id,
                                 null element,
                                 cipq.payable_qty del_item_qty,
                                 cipq.qty_unit_id del_item_qty_unit_id,
                                 qum_del.qty_unit del_item_qty_unit,
                                 (case
                                   when pcdi.delivery_to_date is null then
                                    last_day('01-' || pcdi.delivery_to_month || '-' ||
                                             pcdi.delivery_to_year)
                                   else
                                    pcdi.delivery_to_date
                                 end) del_date,
                                 pcbpd.price_basis,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_value
                                   else
                                    0
                                 end) price,
                                 (case
                                   when pcbpd.price_basis = 'Fixed' then
                                    pcbpd.price_unit_id
                                   else
                                    null
                                 end) price_unit_id,
                                 ppu_pum_price.price_unit_name,
                                 pcqpd.premium_disc_value,
                                 pcqpd.premium_disc_unit_id,
                                 ppu_pum.price_unit_name,
                                 cqs.total_qty contract_qty,
                                 cqs.item_qty_unit_id cont_qty_unit_id,
                                 qum_cont.qty_unit contract_qty_unit,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_short_name,
                                 cpc.profit_center_name,
                                 (case
                                   when pcdi.delivery_period_type = 'Month' then
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year || 'To ' ||
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                   when pcdi.delivery_period_type = 'Date' then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy') || ' To ' ||
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                 end) del_quota_period,
                                 pcpd.strategy_id,
                                 css.strategy_name strategy
                            from pcm_physical_contract_main     pcm,
                                 pcdi_pc_delivery_item          pcdi,
                                 phd_profileheaderdetails       phd,
                                 ak_corporate_user              ak_trader,
                                 pcdb_pc_delivery_basis         pcdb,
                                 pcpd_pc_product_definition     pcpd,
                                 itm_incoterm_master            itm,
                                 pdm_productmaster              pdm,
                                 pci_physical_contract_item     pci,
                                 cipq_contract_item_payable_qty cipq,
                                 qum_quantity_unit_master       qum_del,
                                 pcqpd_pc_qual_premium_discount pcqpd,
                                 v_ppu_pum                      ppu_pum,
                                 ak_corporate                   akc,
                                 pcbph_pc_base_price_header     pcbph,
                                 pcbpd_pc_base_price_detail     pcbpd,
                                 pffxd_phy_formula_fx_details   pffxd,
                                 v_ppu_pum                      ppu_pum_price,
                                 cqs_contract_qty_status        cqs,
                                 qum_quantity_unit_master       qum_cont,
                                 cpc_corporate_profit_center    cpc,
                                 css_corporate_strategy_setup   css,
                                 cim_citymaster                 cim_inco
                           where pcm.contract_type = 'CONCENTRATES'
                             and pcm.is_tolling_contract = 'N'
                             and pcm.process_id = pc_process_id
                             and pcm.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcdi.process_id = pc_process_id
                             and pcdi.is_active = 'Y'
                             and pcm.cp_id = phd.profileid
                             and pcm.trader_id = ak_trader.user_id
                             and pcm.internal_contract_ref_no =
                                 pcdb.internal_contract_ref_no
                             and pcdb.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcdb.inco_term_id = itm.incoterm_id
                             and itm.is_active = 'Y'
                             and itm.is_deleted = 'N'
                             and pcpd.product_id = pdm.product_id
                             and pcpd.input_output = 'Input'
                             and pdm.is_active = 'Y'
                             and pcdi.pcdi_id = pci.pcdi_id
                             and pci.internal_contract_item_ref_no =
                                 cipq.internal_contract_item_ref_no
                             and cipq.is_active = 'Y'
                             and cipq.qty_unit_id = qum_del.qty_unit_id
                             and qum_del.is_deleted = 'N'
                             and qum_del.is_active = 'Y'
                             and pcm.internal_contract_ref_no =
                                 pcqpd.internal_contract_ref_no(+)
                             and pcqpd.process_id(+) = pc_process_id
                             and pcqpd.dbd_id(+) = pc_dbd_id
                             and pcqpd.premium_disc_unit_id =
                                 ppu_pum.product_price_unit_id(+)
                             and pcm.corporate_id = akc.corporate_id
                             and pcm.internal_contract_ref_no =
                                 pcbph.internal_contract_ref_no
                             and cipq.element_id = pcbph.element_id
                             and pcbph.process_id = pc_process_id
                             and pcbph.pcbph_id = pcbpd.pcbph_id
                             and pcbpd.process_id = pc_process_id
                             and pcm.internal_contract_ref_no =
                                 pffxd.internal_contract_ref_no
                             and pffxd.pffxd_id = pcbpd.pffxd_id
                             and pffxd.process_id = pc_process_id
                             and pffxd.is_active = 'Y'
                             and pcbpd.price_unit_id =
                                 ppu_pum_price.product_price_unit_id(+)
                             and pcm.contract_status = 'Cancelled'
                             and pcm.internal_contract_ref_no =
                                 cqs.internal_contract_ref_no
                             and cqs.process_id = pc_process_id
                             and cqs.item_qty_unit_id = qum_cont.qty_unit_id
                             and qum_cont.is_active = 'Y'
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and cpc.is_active = 'Y'
                             and pcpd.strategy_id = css.strategy_id
                             and cim_inco.city_id = pcdb.city_id
                             and css.is_active = 'Y'
                             and pcm.approval_status = 'Approved'
                             and exists
                           (select pcm_in.internal_contract_ref_no
                                    from pcm_physical_contract_main pcm_in
                                   where pcm_in.internal_contract_ref_no =
                                         pcm.internal_contract_ref_no
                                     and pcm_in.process_id =
                                         pc_prev_process_id
                                     and pcm_in.corporate_id =
                                         pc_corporate_id
                                     and pcm.approval_status = 'Approved'
                                     and pcm_in.contract_status <>
                                         'Cancelled'))
    loop
      insert into eod_eom_phy_contract_journal
        (catogery,
         book_type,
         corporate_id,
         corporate_name,
         contract_ref_no,
         del_item_ref_no,
         internal_contract_ref_no,
         cp_id,
         companyname,
         trader_id,
         trader,
         inco_term_id,
         inco_term,
         inco_term_location,
         issue_date,
         product_id,
         product_desc,
         element_id,
         element,
         del_item_qty,
         del_item_qty_unit_id,
         del_item_qty_unit,
         del_date,
         price_basis,
         price,
         price_unit_id,
         price_unit_name,
         premium_disc_value,
         premium_disc_unit_id,
         pd_price_unit_name,
         eod_eom_date,
         process,
         process_id,
         contract_qty,
         cont_qty_unit_id,
         cont_qty_unit,
         profit_center_id,
         profit_center_short_name,
         profit_center_name,
         del_quota_period,
         strategy_id,
         strategy)
      values
        (cr_phy_jornal.catogery,
         cr_phy_jornal.book_type,
         cr_phy_jornal.corporate_id,
         cr_phy_jornal.corporate_name,
         cr_phy_jornal.contract_ref_no,
         cr_phy_jornal.del_item_ref_no,
         cr_phy_jornal.internal_contract_ref_no,
         cr_phy_jornal.cp_id,
         cr_phy_jornal.companyname,
         cr_phy_jornal.trader_id,
         cr_phy_jornal.trader,
         cr_phy_jornal.inco_term_id,
         cr_phy_jornal.inco_term,
         cr_phy_jornal.inco_term_location,
         cr_phy_jornal.issue_date,
         cr_phy_jornal.product_id,
         cr_phy_jornal.product_desc,
         cr_phy_jornal.element_id,
         cr_phy_jornal.element,
         cr_phy_jornal.del_item_qty,
         cr_phy_jornal.del_item_qty_unit_id,
         cr_phy_jornal.del_item_qty_unit,
         cr_phy_jornal.del_date,
         cr_phy_jornal.price_basis,
         cr_phy_jornal.price,
         cr_phy_jornal.price_unit_id,
         cr_phy_jornal.price_unit_name,
         cr_phy_jornal.premium_disc_value,
         cr_phy_jornal.premium_disc_unit_id,
         cr_phy_jornal.pd_price_unit_name,
         pd_trade_date,
         pc_process,
         pc_process_id,
         cr_phy_jornal.contract_qty,
         cr_phy_jornal.cont_qty_unit_id,
         cr_phy_jornal.contract_qty_unit,
         cr_phy_jornal.profit_center_id,
         cr_phy_jornal.profit_center_short_name,
         cr_phy_jornal.profit_center_name,
         cr_phy_jornal.del_quota_period,
         cr_phy_jornal.strategy_id,
         cr_phy_jornal.strategy);
    
    end loop;
    commit;
    --update incoterm and incoterm location
    for cc in (select pcm.internal_contract_ref_no,
                      stragg(itm.incoterm_id) incoterm_id,
                      stragg(itm.incoterm) incoterm,
                      stragg(cim.city_name) city_name
                 from pcm_physical_contract_main pcm,
                      pcdb_pc_delivery_basis     pcdb,
                      itm_incoterm_master        itm,
                      cim_citymaster             cim,
                      pcdi_pc_delivery_item      pcdi,
                      pci_physical_contract_item pci
                where pcdb.internal_contract_ref_no =
                      pcm.internal_contract_ref_no
                  and pcdb.inco_term_id = itm.incoterm_id
                  and pcdb.city_id = cim.city_id
                  and pcdi.internal_contract_ref_no =
                      pcm.internal_contract_ref_no
                  and pcdi.pcdi_id = pci.pcdi_id
                  and pci.pcdb_id = pcdb.pcdb_id
                  and pcm.internal_contract_ref_no in
                      (select tt.internal_contract_ref_no
                         from eod_eom_phy_contract_journal tt
                        where tt.process_id = pc_process_id
                          and tt.corporate_id = pc_corporate_id
                        group by tt.internal_contract_ref_no)
                  and pcdi.process_id = pc_process_id
                  and pci.process_id = pc_process_id
                  and pcm.process_id = pc_process_id
                  and pcdb.process_id = pc_process_id
                  and pcm.corporate_id = pc_corporate_id
                  and itm.is_active = 'Y'
                  and itm.is_deleted = 'N'
                group by pcm.internal_contract_ref_no)
    loop
    
      update eod_eom_phy_contract_journal t1
         set t1.inco_term_id       = cc.incoterm_id,
             t1.inco_term          = cc.incoterm,
             t1.inco_term_location = cc.city_name
       where t1.internal_contract_ref_no = cc.internal_contract_ref_no
         and t1.corporate_id = pc_corporate_id
         and t1.process_id = pc_process_id
         and t1.process = pc_process;
    end loop;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_pysical_journal',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  function f_get_converted_price_pum(pc_corporate_id       varchar2,
                                     pn_price              number,
                                     pc_from_price_unit_id varchar2,
                                     pc_to_price_unit_id   varchar2,
                                     pd_trade_date         date,
                                     pc_product_id         varchar2)
    return number is
    vn_result number;
  
  begin
    if pc_from_price_unit_id = pc_to_price_unit_id then
      return pn_price;
    else
    
      select nvl(round(nvl(pn_price, 0) *
                       pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                pum1.cur_id,
                                                                pum2.cur_id,
                                                                pd_trade_date,
                                                                1) *
                       pkg_general.f_get_converted_quantity(pc_product_id,
                                                            pum1.weight_unit_id,
                                                            pum2.weight_unit_id,
                                                            1) *
                       nvl(pum1.weight, 1) / nvl(pum2.weight, 1),
                       5),
                 0)
        into vn_result
        from pum_price_unit_master pum1,
             pum_price_unit_master pum2
       where pum1.price_unit_id = pc_from_price_unit_id
         and pum2.price_unit_id = pc_to_price_unit_id
         and pum1.is_deleted = 'N'
         and pum2.is_deleted = 'N';
      return vn_result;
    end if;
  exception
    when others then
      return 0;
  end;
  procedure sp_derivative_contract_journal(pc_corporate_id varchar2,
                                           pc_process      varchar2,
                                           pd_trade_date   date,
                                           pc_user_id      varchar2,
                                           pc_dbd_id       varchar2,
                                           pc_prev_dbd_id  varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_derivative_contract_journal
    --        Author                                    : saurabraj
    --        Created Date                              : 25-Jul-2012
    --        Purpose                                   :
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : Trade Date
    --        pc_user_id                                : User ID
    --        pc_process                                : Process EOD or EOM
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    cursor derv_jour is(
      select 'New' catogery,
             dt.derivative_ref_no,
             nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
             gab.firstname || ' ' || gab.lastname trader,
             css.strategy_id,
             css.strategy_name,
             dt.trade_type,
             dt.trade_date,
             pdm.product_desc product,
             drm.prompt_date prompt_date,
             round((dt.total_quantity * dt.qty_sign *
                   nvl(ucm.multiplication_factor, 1)),
                   pdm_qum.decimals) quantity_in_base_unit,
             pdm_qum.qty_unit uom,
             dt.trade_price,
             pum.price_unit_name,
             dt.strike_price,
             pum_strik.price_unit_name strike_price_unit,
             dt.premium_discount,
             (case
               when irmf.instrument_type in ('Option Put', 'OTC Put Option') then
                'PUT'
               else
                (case
               when irmf.instrument_type in
                    ('Option Call', 'OTC Call Option') then
                'CALL'
               else
                null
             end) end) put_call,
             pum_pd.price_unit_name premium_discount_price_unit,
             dt.option_expiry_date declaration_date,
             dt.clearer_comm_amt clearer_commission,
             (case
               when irmf.instrument_type = 'Average' then
                dt.premium_discount
               else
                null
             end) average_premium,
             dt.average_from_date,
             dt.average_to_date,
             pp.price_point_name,
             dt.status,
             dt.internal_derivative_ref_no,
             ak.corporate_id,
             ak.corporate_name,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             tdc.process_id,
             irmf.instrument_type,
             drm.instrument_id,
             dim.instrument_name,
             dt.total_quantity * dt.qty_sign total_quantity,
             qum.qty_unit total_qty_unit,
             nvl(dt.expired_lots, 0) expired_lots,
             nvl(dt.exercised_lots, 0) exercised_lots,
             nvl(dt.expired_quantity, 0) * dt.qty_sign expired_quantity,
             nvl(dt.exercised_quantity, 0) * dt.qty_sign exercised_quantity,
             dt.external_ref_no ext_trade_ref_no,
             dt.int_trade_parent_der_ref_no int_trade_ref_no,
             cdcmc.master_contract_ref_no master_cont_ref_no,
             bct.commission_type_name clearer_comm_type,
             round((case
                     when dt.clearer_comm_amt <> 0 then
                      dt.clearer_comm_amt /
                      round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                            pdm_qum.decimals)
                     else
                      0
                   end),
                   4) clearer_comm_perunit,
             (case
               when dt.clearer_comm_cur_id is not null then
                cmcl.cur_code || '/' || pdm_qum.qty_unit
               else
                null
             end) clearer_comm_unit,
             dt.remarks,
             emt.exchange_name,
             pm.period_type_name
        from dt_derivative_trade              dt,
             cpc_corporate_profit_center      cpc,
             ak_corporate                     ak,
             drm_derivative_master            drm,
             phd_profileheaderdetails         phd_broker,
             phd_profileheaderdetails         phd_clr,
             dim_der_instrument_master        dim,
             css_corporate_strategy_setup     css,
             qum_quantity_unit_master         pdm_qum,
             irm_instrument_type_master       irmf,
             pdd_product_derivative_def       pdd,
             tdc_trade_date_closure           tdc,
             pdm_productmaster                pdm,
             pp_price_point                   pp,
             pum_price_unit_master            pum,
             pum_price_unit_master            pum_strik,
             pum_price_unit_master            pum_pd,
             ak_corporate_user                akcu,
             gab_globaladdressbook            gab,
             ucm_unit_conversion_master       ucm,
             qum_quantity_unit_master         qum,
             emt_exchangemaster               emt,
             bct_broker_commission_types      bct,
             cdc_mc_master_contract@eka_appdb cdcmc,
             cm_currency_master               cmcl,
             pm_period_master                 pm
       where drm.dr_id = dt.dr_id
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.clearer_profile_id = phd_clr.profileid(+)
         and drm.instrument_id = dim.instrument_id
         and dim.instrument_type_id = irmf.instrument_type_id
         and dt.corporate_id = ak.corporate_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.product_id = pdm.product_id
         and dt.strategy_id = css.strategy_id(+)
         and dt.profit_center_id = cpc.profit_center_id
         and dt.trade_price_unit_id = pum.price_unit_id(+)
         and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
         and pdm.base_quantity_unit = pdm_qum.qty_unit_id
         and akcu.user_id = dt.trader_id
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and dt.price_point_id = pp.price_point_id(+)
         and nvl(dt.status, 'None') <> 'Delete'
         and irmf.is_active = 'Y'
         and irmf.is_deleted = 'N'
         and dt.quantity_unit_id = ucm.from_qty_unit_id
         and pdm.base_quantity_unit = ucm.to_qty_unit_id
         and dt.is_new_trade = 'Y'
         and dt.dbd_id = pc_dbd_id
         and dt.process_id = tdc.process_id
         and tdc.process = pc_process
         and ak.corporate_id = pc_corporate_id
         and akcu.gabid = gab.gabid
         and dt.quantity_unit_id = qum.qty_unit_id
         and pdd.exchange_id = emt.exchange_id(+)
         and dt.clearer_comm_type_id = bct.commission_type_id(+)
         and dt.master_contract_id = cdcmc.internal_contract_ref_no(+)
         and dt.clearer_comm_cur_id = cmcl.cur_id(+)
         and drm.period_type_id=pm.period_type_id
      
      union all
      select 'Deleted' catogery,
             dt.derivative_ref_no,
             nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
             gab.firstname || ' ' || gab.lastname trader,
             css.strategy_id,             
             css.strategy_name,
             dt.trade_type,
             dt.trade_date,
             pdm.product_desc product,
             drm.prompt_date prompt_date,
             round((dt.total_quantity * dt.qty_sign *
                   nvl(ucm.multiplication_factor, 1)),
                   pdm_qum.decimals) quantity_in_base_unit,
             pdm_qum.qty_unit uom,
             dt.trade_price,
             pum.price_unit_name,
             dt.strike_price,
             pum_strik.price_unit_name strike_price_unit,
             dt.premium_discount,
             (case
               when irmf.instrument_type in ('Option Put', 'OTC Put Option') then
                'PUT'
               else
                (case
               when irmf.instrument_type in
                    ('Option Call', 'OTC Call Option') then
                'CALL'
               else
                null
             end) end) put_call,
             pum_pd.price_unit_id premium_discount_price_unit,
             dt.option_expiry_date declaration_date,
             dt.clearer_comm_amt clearer_commission,
             (case
               when irmf.instrument_type = 'Average' then
                dt.premium_discount
               else
                null
             end) average_premium,
             dt.average_from_date,
             dt.average_to_date,
             pp.price_point_name,
             dt.status,
             dt.internal_derivative_ref_no,
             ak.corporate_id,
             ak.corporate_name,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             tdc.process_id,
             irmf.instrument_type,
             drm.instrument_id,
             dim.instrument_name,
             dt.total_quantity * dt.qty_sign total_quantity,
             qum.qty_unit total_qty_unit,
             nvl(dt.expired_lots, 0) expired_lots,
             nvl(dt.exercised_lots, 0) exercised_lots,
             nvl(dt.expired_quantity, 0) * dt.qty_sign expired_quantity,
             nvl(dt.exercised_quantity, 0) * dt.qty_sign exercised_quantity,
             dt.external_ref_no ext_trade_ref_no,
             dt.int_trade_parent_der_ref_no int_trade_ref_no,
             cdcmc.master_contract_ref_no master_cont_ref_no,
             bct.commission_type_name clearer_comm_type,
             round((case
                     when dt.clearer_comm_amt <> 0 then
                      dt.clearer_comm_amt /
                      round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                            pdm_qum.decimals)
                     else
                      0
                   end),
                   4) clearer_comm_perunit,
             (case
               when dt.clearer_comm_cur_id is not null then
                cmcl.cur_code || '/' || pdm_qum.qty_unit
               else
                null
             end) clearer_comm_unit,
             dt.remarks,
             emt.exchange_name,
             pm.period_type_name
        from dt_derivative_trade              dt,
             cpc_corporate_profit_center      cpc,
             ak_corporate                     ak,
             drm_derivative_master            drm,
             phd_profileheaderdetails         phd_broker,
             phd_profileheaderdetails         phd_clr,
             dim_der_instrument_master        dim,
             css_corporate_strategy_setup     css,
             qum_quantity_unit_master         pdm_qum,
             irm_instrument_type_master       irmf,
             tdc_trade_date_closure           tdc,
             pdd_product_derivative_def       pdd,
             pdm_productmaster                pdm,
             pp_price_point                   pp,
             pum_price_unit_master            pum,
             pum_price_unit_master            pum_strik,
             pum_price_unit_master            pum_pd,
             ak_corporate_user                akcu,
             ucm_unit_conversion_master       ucm,
             gab_globaladdressbook            gab,
             qum_quantity_unit_master         qum,
             emt_exchangemaster               emt,
             bct_broker_commission_types      bct,
             cdc_mc_master_contract@eka_appdb cdcmc,
             cm_currency_master               cmcl,
             pm_period_master                 pm
       where drm.dr_id = dt.dr_id
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.clearer_profile_id = phd_clr.profileid(+)
         and drm.instrument_id = dim.instrument_id
         and dim.instrument_type_id = irmf.instrument_type_id
         and dt.corporate_id = ak.corporate_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.product_id = pdm.product_id
         and dt.strategy_id = css.strategy_id(+)
         and dt.trade_price_unit_id = pum.price_unit_id(+)
         and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
         and pdm.base_quantity_unit = pdm_qum.qty_unit_id
         and dt.profit_center_id = cpc.profit_center_id
         and akcu.user_id = dt.trader_id
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and dt.price_point_id = pp.price_point_id(+)
         and dt.status = 'Delete'
         and irmf.is_active = 'Y'
         and irmf.is_deleted = 'N'
         and dt.quantity_unit_id = ucm.from_qty_unit_id
         and pdm.base_quantity_unit = ucm.to_qty_unit_id
         and dt.dbd_id = pc_dbd_id
         and dt.process_id = tdc.process_id
         and tdc.process = pc_process
         and ak.corporate_id = pc_corporate_id
         and akcu.gabid = gab.gabid
         and dt.quantity_unit_id = qum.qty_unit_id
         and pdd.exchange_id = emt.exchange_id(+)
         and dt.clearer_comm_type_id = bct.commission_type_id(+)
         and dt.master_contract_id = cdcmc.internal_contract_ref_no(+)
         and dt.clearer_comm_cur_id = cmcl.cur_id(+)
         and drm.period_type_id=pm.period_type_id
         and exists (select dt_in.internal_derivative_ref_no
                from dt_derivative_trade dt_in
               where dt_in.dbd_id = pc_prev_dbd_id
                 and dt_in.internal_derivative_ref_no =
                     dt.internal_derivative_ref_no
                 and dt_in.status = 'Verified')
      union all
      select 'Modified' catogery,
             dt.derivative_ref_no,
             nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
             gab.firstname || ' ' || gab.lastname trader,
             css.strategy_id,             
             css.strategy_name,
             dt.trade_type,
             dt.trade_date,
             pdm.product_desc product,
             drm.prompt_date prompt_date,
             round((dt.total_quantity * dt.qty_sign *
                   nvl(ucm.multiplication_factor, 1)),
                   pdm_qum.decimals) quantity_in_base_unit,
             pdm_qum.qty_unit uom,
             dt.trade_price,
             pum.price_unit_name,
             dt.strike_price,
             pum_strik.price_unit_name strike_price_unit,
             dt.premium_discount,
             (case
               when irmf.instrument_type in ('Option Put', 'OTC Put Option') then
                'PUT'
               else
                (case
               when irmf.instrument_type in
                    ('Option Call', 'OTC Call Option') then
                'CALL'
               else
                null
             end) end) put_call,
             pum_pd.price_unit_id premium_discount_price_unit,
             dt.option_expiry_date declaration_date,
             dt.clearer_comm_amt clearer_commission,
             (case
               when irmf.instrument_type = 'Average' then
                dt.premium_discount
               else
                null
             end) average_premium,
             dt.average_from_date,
             dt.average_to_date,
             pp.price_point_name,
             dt.status,
             dt.internal_derivative_ref_no,
             ak.corporate_id,
             ak.corporate_name,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             tdc.process_id,
             irmf.instrument_type,
             drm.instrument_id,
             dim.instrument_name,
             dt.total_quantity * dt.qty_sign total_quantity,
             qum.qty_unit total_qty_unit,
             nvl(dt.expired_lots, 0) expired_lots,
             nvl(dt.exercised_lots, 0) exercised_lots,
             nvl(dt.expired_quantity, 0) * dt.qty_sign expired_quantity,
             nvl(dt.exercised_quantity, 0) * dt.qty_sign exercised_quantity,
             dt.external_ref_no ext_trade_ref_no,
             dt.int_trade_parent_der_ref_no int_trade_ref_no,
             cdcmc.master_contract_ref_no master_cont_ref_no,
             bct.commission_type_name clearer_comm_type,
             round((case
                     when dt.clearer_comm_amt <> 0 then
                      dt.clearer_comm_amt /
                      round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                            pdm_qum.decimals)
                     else
                      0
                   end),
                   4) clearer_comm_perunit,
             (case
               when dt.clearer_comm_cur_id is not null then
                cmcl.cur_code || '/' || pdm_qum.qty_unit
               else
                null
             end) clearer_comm_unit,
             dt.remarks,
             emt.exchange_name,
             pm.period_type_name
        from dt_derivative_trade              dt,
             cpc_corporate_profit_center      cpc,
             ak_corporate                     ak,
             drm_derivative_master            drm,
             phd_profileheaderdetails         phd_broker,
             phd_profileheaderdetails         phd_clr,
             dim_der_instrument_master        dim,
             css_corporate_strategy_setup     css,
             qum_quantity_unit_master         pdm_qum,
             irm_instrument_type_master       irmf,
             tdc_trade_date_closure           tdc,
             pdd_product_derivative_def       pdd,
             pdm_productmaster                pdm,
             pp_price_point                   pp,
             pum_price_unit_master            pum,
             pum_price_unit_master            pum_strik,
             pum_price_unit_master            pum_pd,
             ak_corporate_user                akcu,
             gab_globaladdressbook            gab,
             ucm_unit_conversion_master       ucm,
             qum_quantity_unit_master         qum,
             emt_exchangemaster               emt,
             bct_broker_commission_types      bct,
             cdc_mc_master_contract@eka_appdb cdcmc,
             cm_currency_master               cmcl,
             pm_period_master                 pm
       where drm.dr_id = dt.dr_id
         and dt.broker_profile_id = phd_broker.profileid(+)
         and dt.clearer_profile_id = phd_clr.profileid(+)
         and drm.instrument_id = dim.instrument_id
         and dim.instrument_type_id = irmf.instrument_type_id
         and dt.corporate_id = ak.corporate_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.product_id = pdm.product_id
         and dt.strategy_id = css.strategy_id(+)
         and dt.profit_center_id = cpc.profit_center_id
         and dt.trade_price_unit_id = pum.price_unit_id(+)
         and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
         and pdm.base_quantity_unit = pdm_qum.qty_unit_id
         and akcu.user_id = dt.trader_id
         and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
         and dt.price_point_id = pp.price_point_id(+)
         and dt.status = 'Verified'
         and nvl(dt.is_new_trade, 'N') <> 'Y'
         and irmf.is_active = 'Y'
         and irmf.is_deleted = 'N'
         and dt.quantity_unit_id = ucm.from_qty_unit_id
         and pdm.base_quantity_unit = ucm.to_qty_unit_id
         and dt.dbd_id = pc_dbd_id
         and dt.process_id = tdc.process_id
         and tdc.process = pc_process
         and ak.corporate_id = pc_corporate_id
         and akcu.gabid = gab.gabid
         and dt.quantity_unit_id = qum.qty_unit_id
         and pdd.exchange_id = emt.exchange_id(+)
         and dt.clearer_comm_type_id = bct.commission_type_id(+)
         and dt.master_contract_id = cdcmc.internal_contract_ref_no(+)
         and dt.clearer_comm_cur_id = cmcl.cur_id(+)
         and drm.period_type_id=pm.period_type_id
         and exists
       (select dtul.internal_derivative_ref_no
                from dtul_derivative_trade_ul dtul
               where dtul.dbd_id = pc_dbd_id
                 and dtul.internal_derivative_ref_no =
                     dt.internal_derivative_ref_no
                 and dtul.entry_type = 'Update'
                 and nvl(dtul.status, 'none') <> 'delete'));
  
  begin
  
    for dvj in derv_jour
    loop
      insert into eod_eom_derivative_journal
        (internal_derivative_ref_no,
         journal_type,
         book_type,
         corporate_id,
         corporate_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         catogery,
         derivative_ref_no,
         clearer,
         trader,
         strategy_id,
         strategy_name,
         trade_type,
         trade_date,
         product,
         prompt_date,
         quantity,
         quantity_uom,
         trade_price,
         price_unit,
         strike_price,
         strike_price_unit,
         premium_discount,
         put_call,
         pd_price_unit,
         declaration_date,
         clearer_commission,
         average_premium,
         average_from_date,
         average_to_date,
         price_point_name,
         status,
         attribute_1,
         attribute_2,
         attribute_3,
         attribute_4,
         attribute_5,
         eod_eom_date,
         process,
         process_id,
         dbd_id,
         instrument_id,
         instrument_name,
         instrument_type,
         trade_quantity,
         trade_quantity_unit,
         exercised_expired_lots,
         exercised_expired_quantity,
         ext_trade_ref_no,
         int_trade_ref_no,
         master_cont_ref_no,
         clearer_comm_type,
         clearer_comm_perunit,
         clearer_comm_unit,
         exchange,
         remarks,
         period_type)
      values
        (dvj.internal_derivative_ref_no,
         dvj.catogery,
         'Derivative',
         dvj.corporate_id,
         dvj.corporate_name,
         dvj.profit_center_id,
         dvj.profit_center_name,
         dvj.profit_center_short_name,
         dvj.catogery,
         dvj.derivative_ref_no,
         dvj.clearer,
         dvj.trader,
         dvj.strategy_id,
         dvj.strategy_name,
         dvj.trade_type,
         dvj.trade_date,
         dvj.product,
         dvj.prompt_date,
         dvj.quantity_in_base_unit,
         dvj.uom,
         dvj.trade_price,
         dvj.price_unit_name,
         dvj.strike_price,
         dvj.strike_price_unit,
         dvj.premium_discount,
         dvj.put_call,
         dvj.premium_discount_price_unit,
         dvj.declaration_date,
         dvj.clearer_commission,
         dvj.average_premium,
         dvj.average_from_date,
         dvj.average_to_date,
         dvj.price_point_name,
         dvj.status,
         null,
         null,
         null,
         null,
         null,
         pd_trade_date,
         pc_process,
         dvj.process_id,
         pc_dbd_id,
         dvj.instrument_id,
         dvj.instrument_name,
         dvj.instrument_type,
         dvj.total_quantity,
         dvj.total_qty_unit,
         dvj.expired_lots + dvj.exercised_lots,
         dvj.expired_quantity + dvj.exercised_quantity,
         dvj.ext_trade_ref_no,
         dvj.int_trade_ref_no,
         dvj.master_cont_ref_no,
         dvj.clearer_comm_type,
         dvj.clearer_comm_perunit,
         dvj.clearer_comm_unit,
         dvj.exchange_name,
         dvj.remarks,
         dvj.period_type_name);
    
    end loop;
 -- added Suresh
  for cur_update in (select eod_eom.internal_derivative_ref_no,
                            dt_ref.derivative_ref_no
                       from eod_eom_derivative_journal    eod_eom,
                            dt_derivative_trade@eka_appdb dt,
                            dt_derivative_trade@eka_appdb dt_ref
                      where eod_eom.internal_derivative_ref_no =
                            dt.internal_derivative_ref_no
                        and dt.underlying_instr_ref_no =
                            dt_ref.internal_derivative_ref_no
                        and eod_eom.dbd_id =pc_dbd_id
                        and dt.underlying_instr_ref_no is not null)
  
  loop
    update eod_eom_derivative_journal eod_eom
       set eod_eom.underlying_derivative_ref_no = cur_update.derivative_ref_no
     where eod_eom.internal_derivative_ref_no =
           cur_update.internal_derivative_ref_no
       and eod_eom.dbd_id = pc_dbd_id;
  end loop;
commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_derivative_journal',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_fixation_journal(pc_corporate_id    varchar2,
                                pd_trade_date      date,
                                pc_process_id      varchar2,
                                pc_user_id         varchar2,
                                pc_process         varchar2,
                                pc_dbd_id          varchar2,
                                pc_prev_process_id varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_derivative_booking_journal
    --        Author                                    : Ashok
    --        Created Date                              : 01-Aug-2012
    --        Purpose                                   :
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : Trade Date
    --        pc_user_id                                : User ID
    --        pc_process                                : Process EOD or EOM
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    cursor cr_cdc_fixation is
      select 'New' journal_type, -- Section name
             'Derivative' book_type, --Price Fixation Type
             dpd.process_id,
             dpd.eod_trade_date,
             dpd.corporate_id,
             dpd.corporate_name,
             dpd.product_id,
             dpd.product_name,
             dpd.profit_center_id,
             dpd.profit_center_name,
             dpd.profit_center_short_name,
             dpd.settlement_ref_no price_fixation_refno,
             dpd.internal_derivative_ref_no,
             null delivery_item_ref_no,
             null delivery_item_qty,
             null delivery_item_qty_unit,
             dpd.derivative_ref_no contract_ref_no,
             dpd.clearer_profile_id,
             dpd.clearer_name,
             dpd.trader_name,
             fsh.settlement_date price_fixation_date, --settlement_date
             dpd.open_quantity fixed_quantity,
             dpd.quantity_unit,
             dpd.trade_price,
             dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
             dpd.trade_price_weight_unit price_unit,
             0 adjustment,
             1 fx_rate,
             dpd.premium_discount contract_premium,
             dpd.pd_price_cur_code || '/' || dpd.pd_price_weight ||
             dpd.pd_price_weight_unit contract_premium_unit,
             --    null total_price,
             --   null total_price_unit,
             dpd.trade_date contract_issue_date,
             dpd.average_from_date,
             dpd.average_to_date,
             dpd.settlement_price,
             fsh.settlement_date,
             dpd.strategy_id,
             dpd.strategy_name,
             null attribute_1,
             null attribute_2,
             null attribute_3,
             null attribute_4,
             null attribute_5,
             dpd.base_cur_id,
             dpd.base_cur_code,
             dpd.trade_price_unit_id,
             dpd.premium_discount_price_unit_id,
             dpd.trade_price_cur_id,
             dpd.trade_price_cur_code,
             dpd.trade_price_weight,
             dpd.trade_price_weight_unit_id,
             dpd.trade_price_weight_unit,
             dpd.pd_price_cur_id,
             dpd.pd_price_cur_code,
             dpd.pd_price_weight,
             dpd.pd_price_weight_unit_id,
             dpd.pd_price_weight_unit,
             dpd.base_qty_unit_id,
             dpd.base_qty_unit,
             dpd.price_point_id,
             dpd.price_point_name
        from dpd_derivative_pnl_daily dpd,
             (select fsh.internal_derivative_ref_no,
                     fsh.settlement_ref_no,
                     fsh.settlement_date
                from fsh_fin_settlement_header fsh
               where fsh.process_id = pc_process_id
                 and fsh.is_settled = 'Y'
               group by fsh.internal_derivative_ref_no,
                        fsh.settlement_ref_no,
                        fsh.settlement_date) fsh
       where dpd.pnl_type = 'Realized'
         and dpd.instrument_type = 'Average'
         and dpd.corporate_id = pc_corporate_id
         and dpd.process_id = pc_process_id
         and dpd.internal_derivative_ref_no =
             fsh.internal_derivative_ref_no(+)
         and dpd.settlement_ref_no = fsh.settlement_ref_no(+)
      union all
      select 'Deleted' journal_type, -- Section name
             'Derivative' book_type, --Price Fixation Type
             dpd.process_id,
             dpd.eod_trade_date,
             dpd.corporate_id,
             dpd.corporate_name,
             dpd.product_id,
             dpd.product_name,
             dpd.profit_center_id,
             dpd.profit_center_name,
             dpd.profit_center_short_name,
             dpd.settlement_ref_no price_fixation_refno,
             dpd.internal_derivative_ref_no,
             null delivery_item_ref_no,
             null delivery_item_qty,
             null delivery_item_qty_unit,
             dpd.derivative_ref_no contract_ref_no,
             dpd.clearer_profile_id,
             dpd.clearer_name,
             dpd.trader_name,
             fsh.settlement_date price_fixation_date, --settlement_date
             dpd.open_quantity fixed_quantity,
             dpd.quantity_unit,
             dpd.trade_price,
             dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
             dpd.trade_price_weight_unit price_unit,
             0 adjustment,
             1 fx_rate,
             dpd.premium_discount contract_premium,
             dpd.pd_price_cur_code || '/' || dpd.pd_price_weight ||
             dpd.pd_price_weight_unit contract_premium_unit,
             --             null total_price,
             --           null total_price_unit,
             dpd.trade_date contract_issue_date,
             dpd.average_from_date,
             dpd.average_to_date,
             dpd.settlement_price,
             fsh.settlement_date,
             dpd.strategy_id,
             dpd.strategy_name,
             null attribute_1,
             null attribute_2,
             null attribute_3,
             null attribute_4,
             null attribute_5,
             dpd.base_cur_id,
             dpd.base_cur_code,
             dpd.trade_price_unit_id,
             dpd.premium_discount_price_unit_id,
             dpd.trade_price_cur_id,
             dpd.trade_price_cur_code,
             dpd.trade_price_weight,
             dpd.trade_price_weight_unit_id,
             dpd.trade_price_weight_unit,
             dpd.pd_price_cur_id,
             dpd.pd_price_cur_code,
             dpd.pd_price_weight,
             dpd.pd_price_weight_unit_id,
             dpd.pd_price_weight_unit,
             dpd.base_qty_unit_id,
             dpd.base_qty_unit,
             dpd.price_point_id,
             dpd.price_point_name
        from dpd_derivative_pnl_daily dpd,
             (select fsh.internal_derivative_ref_no,
                     fsh.settlement_ref_no,
                     fsh.settlement_date
                from fsh_fin_settlement_header fsh
               where fsh.process_id = pc_process_id
              --and fsh.is_settled = 'Y'
               group by fsh.internal_derivative_ref_no,
                        fsh.settlement_ref_no,
                        fsh.settlement_date) fsh
       where dpd.pnl_type = 'Reverse Realized'
         and dpd.instrument_type = 'Average'
         and dpd.corporate_id = pc_corporate_id
         and dpd.process_id = pc_process_id
         and dpd.internal_derivative_ref_no =
             fsh.internal_derivative_ref_no(+)
         and dpd.settlement_ref_no = fsh.settlement_ref_no(+);
    cursor cr_phy_fixation is
      select 'New' journal_type,
             'Physical' book_type,
             pofh.corporate_id,
             akc.corporate_name,
             null product_id,
             null product_name,
             null profit_center_id,
             null profit_center_name,
             null profit_center_short_name,
             pofh.latest_pfc_no price_fixation_refno,
             pofh.pcdi_id internal_derivative_ref_no,
             (case
               when gmr.gmr_ref_no is not null then
                gmr.gmr_ref_no
               else
                pcm.contract_ref_no || '-' || pcdi.delivery_item_no
             end) delivery_item_ref_no, --bug id 69221
             diqs.total_qty delivery_item_qty,
             qum_diqs.qty_unit delivery_item_qty_unit,
             /*(case
                                                                                                                       when gmr.gmr_ref_no is not null then
                                                                                                                        gmr.gmr_ref_no
                                                                                                                       else
                                                                                                                        pcm.contract_ref_no
                                                                                                                     end) contract_ref_no,*/
             pcm.contract_ref_no, --bug id 69221
             pcm.cp_id clearer_profile_id,
             phd_cp.companyname clearer_name,
             gab.firstname || ' ' || gab.lastname trader_name,
             pofh.finalize_date price_fixation_date,
             pofh.latest_fixed_qty fixed_quantity,
             qum_fxd.qty_unit quantity_unit,
             pofh.final_price trade_price, --has to use finalized price stored in pay-in currency for calculation, not the avg price
             ppu_pum_pay.price_unit_name price_unit, --pay in currency unit
             pofh.latest_adj_price,
             round(pkg_general.f_get_converted_currency_amt(pcm.corporate_id,
                                                            ppu_pum_pay.cur_id,
                                                            akc.base_cur_id,
                                                            pd_trade_date,
                                                            1),
                   10) pay_to_base_fx_rate, --payin currency to base
             0 contract_premium, --inside formula
             ppu_pum.price_unit_name contract_premium_unit, --inside variable
             pcm.issue_date contract_issue_date,
             (case
               when pocd.is_any_day_pricing = 'N' then
                to_char(pofh.qp_start_date, 'dd-Mon-yyyy')
               else
                null
             end) average_from_date,
             (case
               when pocd.is_any_day_pricing = 'N' then
                to_char(pofh.qp_end_date, 'dd-Mon-yyyy')
               else
                null
             end) average_to_date,
             round(pofh.final_price_in_pricing_cur, 6) settlement_price,
             pofh.latest_pfc_date settlement_date,
             null strategy_id,
             null strategy_name,
             null attribute_1,
             null attribute_2,
             null attribute_3,
             null attribute_4,
             null attribute_5,
             akc.base_cur_id,
             cm_base.cur_code base_cur_code,
             ppu_pum_pay.price_unit_id trade_price_unit_id,
             ppu_pum.price_unit_id premium_discount_price_unit_id,
             ppu_pum_pay.cur_id trade_price_cur_id,
             cm_pay.cur_code trade_price_cur_code,
             ppu_pum_pay.weight trade_price_weight,
             ppu_pum_pay.weight_unit_id trade_price_weight_unit_id,
             qum_pay.qty_unit trade_price_weight_unit,
             ppu_pum.cur_id pd_price_cur_id,
             cm_ppu.cur_code pd_price_cur_code,
             ppu_pum.weight pd_price_weight,
             ppu_pum.weight_unit_id pd_price_weight_unit_id,
             qum_ppu.qty_unit pd_price_weight_unit,
             pofh.pofh_id,
             aml.attribute_id,
             aml.attribute_name,
             pofh.final_price, -- this price has to be used for calculation
             pocd.pay_in_price_unit_id, -- this price has to be used for calculation
             ppu_pum_pay.price_unit_name pay_in_price_unit, -- this price has to be used for calculation
             cm_pay.cur_code pay_in_cur_code
        from pofh_history                   pofh,
             pocd_price_option_calloff_dtls pocd,
             pcdi_pc_delivery_item          pcdi,
             diqs_delivery_item_qty_status  diqs,
             qum_quantity_unit_master       qum_diqs,
             gmr_goods_movement_record      gmr,
             pcm_physical_contract_main     pcm,
             phd_profileheaderdetails       phd_cp,
             ak_corporate_user              ak_trader,
             gab_globaladdressbook          gab,
             qum_quantity_unit_master       qum_fxd,
             v_ppu_pum                      ppu_pum,
             cm_currency_master             cm_ppu,
             qum_quantity_unit_master       qum_ppu,
             ak_corporate                   akc,
             cm_currency_master             cm_base,
             aml_attribute_master_list      aml,
             v_ppu_pum                      ppu_pum_pay,
             cm_currency_master             cm_pay,
             qum_quantity_unit_master       qum_pay
       where pofh.is_new = 'Y'
         and pofh.is_active = 'Y'
            --  and pofh.is_deleted is null
         and pofh.pcdi_id = pcdi.pcdi_id
         and pofh.pocd_id = pocd.pocd_id
         and pofh.pcdi_id = diqs.pcdi_id
         and pocd.element_id = aml.attribute_id(+)
         and diqs.item_qty_unit_id = qum_diqs.qty_unit_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
         and pofh.process_id = gmr.process_id(+)
         and pcm.cp_id = phd_cp.profileid
         and pcm.trader_id = ak_trader.user_id
         and ak_trader.gabid = gab.gabid
         and pocd.qty_to_be_fixed_unit_id = qum_fxd.qty_unit_id(+)
         and pofh.latest_price_unit_id = ppu_pum.product_price_unit_id(+)
         and pcm.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm_base.cur_id
         and ppu_pum.cur_id = cm_ppu.cur_id(+)
         and ppu_pum.weight_unit_id = qum_ppu.qty_unit_id(+)
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pofh.corporate_id = pc_corporate_id
         and pofh.process_id = pc_process_id
         and pofh.process = pc_process
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id
         and pocd.pay_in_price_unit_id = ppu_pum_pay.product_price_unit_id
         and ppu_pum_pay.weight_unit_id = qum_pay.qty_unit_id(+)
         and pocd.pay_in_cur_id = cm_pay.cur_id(+)
         and pcm.contract_status = 'In Position'
      -- and cm_pay.is_active = 'Y'
      union all
      select 'Deleted' journal_type,
             'Physical' book_type,
             pofh.corporate_id,
             akc.corporate_name,
             null product_id,
             null product_name,
             null profit_center_id,
             null profit_center_name,
             null profit_center_short_name,
             pofh.latest_pfc_no price_fixation_refno,
             pofh.pcdi_id internal_derivative_ref_no,
             (case
               when gmr.gmr_ref_no is not null then
                gmr.gmr_ref_no
               else
                pcm.contract_ref_no || '-' || pcdi.delivery_item_no
             end) delivery_item_ref_no, --bug id 69221
             diqs.total_qty delivery_item_qty,
             qum_diqs.qty_unit delivery_item_qty_unit,
             /*(case
                                                                                                                       when gmr.gmr_ref_no is not null then
                                                                                                                        gmr.gmr_ref_no
                                                                                                                       else
                                                                                                                        pcm.contract_ref_no
                                                                                                                     end) contract_ref_no,*/
             pcm.contract_ref_no, --bug id 69221
             pcm.cp_id clearer_profile_id,
             phd_cp.companyname clearer_name,
             gab.firstname || ' ' || gab.lastname trader_name,
             pofh.finalize_date price_fixation_date,
             pofh.latest_fixed_qty fixed_quantity,
             qum_fxd.qty_unit quantity_unit,
             pofh.final_price trade_price, --has to use finalized price stored in pay-in currency for calculation, not the avg price
             ppu_pum_pay.price_unit_name price_unit,
             pofh.latest_adj_price,
             round(pkg_general.f_get_converted_currency_amt(pcm.corporate_id,
                                                            ppu_pum_pay.cur_id,
                                                            akc.base_cur_id,
                                                            pd_trade_date,
                                                            1),
                   10) pay_to_base_fx_rate,
             0 contract_premium, --inside formula
             ppu_pum.price_unit_name contract_premium_unit, --inside variable
             pcm.issue_date contract_issue_date,
             (case
               when pocd.is_any_day_pricing = 'N' then
                to_char(pofh.qp_start_date, 'dd-Mon-yyyy')
               else
                null
             end) average_from_date,
             (case
               when pocd.is_any_day_pricing = 'N' then
                to_char(pofh.qp_end_date, 'dd-Mon-yyyy')
               else
                null
             end) average_to_date,
             round(pofh.final_price_in_pricing_cur, 6) settlement_price,
             pofh.latest_pfc_date settlement_date,
             null strategy_id,
             null strategy_name,
             null attribute_1,
             null attribute_2,
             null attribute_3,
             null attribute_4,
             null attribute_5,
             akc.base_cur_id,
             cm_base.cur_code base_cur_code,
             ppu_pum_pay.price_unit_id trade_price_unit_id,
             ppu_pum.price_unit_id premium_discount_price_unit_id,
             ppu_pum_pay.cur_id trade_price_cur_id,
             cm_pay.cur_code trade_price_cur_code,
             ppu_pum_pay.weight trade_price_weight,
             ppu_pum_pay.weight_unit_id trade_price_weight_unit_id,
             qum_pay.qty_unit trade_price_weight_unit,
             ppu_pum.cur_id pd_price_cur_id,
             cm_ppu.cur_code pd_price_cur_code,
             ppu_pum.weight pd_price_weight,
             ppu_pum.weight_unit_id pd_price_weight_unit_id,
             qum_ppu.qty_unit pd_price_weight_unit,
             pofh.pofh_id,
             aml.attribute_id,
             aml.attribute_name,
             pofh.final_price,
             pocd.pay_in_price_unit_id,
             ppu_pum_pay.price_unit_name,
             cm_pay.cur_code pay_in_cur_code
        from pofh_history                   pofh,
             pocd_price_option_calloff_dtls pocd,
             aml_attribute_master_list      aml,
             pcdi_pc_delivery_item          pcdi,
             diqs_delivery_item_qty_status  diqs,
             qum_quantity_unit_master       qum_diqs,
             gmr_goods_movement_record      gmr,
             pcm_physical_contract_main     pcm,
             phd_profileheaderdetails       phd_cp,
             ak_corporate_user              ak_trader,
             gab_globaladdressbook          gab,
             qum_quantity_unit_master       qum_fxd,
             v_ppu_pum                      ppu_pum,
             cm_currency_master             cm_ppu,
             qum_quantity_unit_master       qum_ppu,
             ak_corporate                   akc,
             cm_currency_master             cm_base,
             v_ppu_pum                      ppu_pum_pay,
             qum_quantity_unit_master       qum_pay,
             cm_currency_master             cm_pay
       where pofh.is_deleted = 'Y'
         and pofh.pcdi_id = pcdi.pcdi_id
         and pofh.pocd_id = pocd.pocd_id
         and pofh.pcdi_id = diqs.pcdi_id
         and pocd.element_id = aml.attribute_id(+)
         and diqs.item_qty_unit_id = qum_diqs.qty_unit_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
         and pofh.process_id = gmr.process_id(+)
         and pcm.cp_id = phd_cp.profileid
         and pcm.trader_id = ak_trader.user_id
         and ak_trader.gabid = gab.gabid
         and pocd.qty_to_be_fixed_unit_id = qum_fxd.qty_unit_id(+)
         and pofh.latest_price_unit_id = ppu_pum.product_price_unit_id(+)
         and pcm.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm_base.cur_id
         and ppu_pum.cur_id = cm_ppu.cur_id(+)
         and ppu_pum.weight_unit_id = qum_ppu.qty_unit_id(+)
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pofh.corporate_id = pc_corporate_id
         and pofh.process_id = pc_process_id
         and pofh.process = pc_process
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id
         and pocd.pay_in_price_unit_id = ppu_pum_pay.product_price_unit_id
         and pocd.pay_in_cur_id = cm_pay.cur_id(+)
         and ppu_pum_pay.weight_unit_id = qum_pay.qty_unit_id
         and cm_pay.is_active = 'Y'
         and pcm.contract_status = 'In Position'
      union all
      select 'Modified' journal_type,
             'Physical' book_type,
             pofh.corporate_id,
             akc.corporate_name,
             null product_id,
             null product_name,
             null profit_center_id,
             null profit_center_name,
             null profit_center_short_name,
             pofh.latest_pfc_no price_fixation_refno,
             pofh.pcdi_id internal_derivative_ref_no,
             (case
               when gmr.gmr_ref_no is not null then
                gmr.gmr_ref_no
               else
                pcm.contract_ref_no || '-' || pcdi.delivery_item_no
             end) delivery_item_ref_no, --bug id 69221
             diqs.total_qty delivery_item_qty,
             qum_diqs.qty_unit delivery_item_qty_unit,
             /*(case
                                                                                                                       when gmr.gmr_ref_no is not null then
                                                                                                                        gmr.gmr_ref_no
                                                                                                                       else
                                                                                                                        pcm.contract_ref_no
                                                                                                                     end) contract_ref_no,*/
             pcm.contract_ref_no, --bug id 69221
             pcm.cp_id clearer_profile_id,
             phd_cp.companyname clearer_name,
             gab.firstname || ' ' || gab.lastname trader_name,
             pofh.finalize_date price_fixation_date,
             pofh.latest_fixed_qty fixed_quantity,
             qum_fxd.qty_unit quantity_unit,
             pofh.final_price trade_price, --has to use finalized price stored in pay-in currency for calculation, not the avg price
             ppu_pum_pay.price_unit_name price_unit,
             pofh.latest_adj_price,
             round(pkg_general.f_get_converted_currency_amt(pcm.corporate_id,
                                                            ppu_pum_pay.cur_id,
                                                            akc.base_cur_id,
                                                            pd_trade_date,
                                                            1),
                   10) pay_to_base_fx_rate,
             0 contract_premium, --inside formula
             ppu_pum.price_unit_name contract_premium_unit, --inside variable
             pcm.issue_date contract_issue_date,
             (case
               when pocd.is_any_day_pricing = 'N' then
                to_char(pofh.qp_start_date, 'dd-Mon-yyyy')
               else
                null
             end) average_from_date,
             (case
               when pocd.is_any_day_pricing = 'N' then
                to_char(pofh.qp_end_date, 'dd-Mon-yyyy')
               else
                null
             end) average_to_date,
             round(pofh.final_price_in_pricing_cur, 6) settlement_price,
             pofh.latest_pfc_date settlement_date,
             null strategy_id,
             null strategy_name,
             null attribute_1,
             null attribute_2,
             null attribute_3,
             null attribute_4,
             null attribute_5,
             akc.base_cur_id,
             cm_base.cur_code base_cur_code,
             ppu_pum_pay.price_unit_id trade_price_unit_id,
             ppu_pum.price_unit_id premium_discount_price_unit_id,
             ppu_pum_pay.cur_id trade_price_cur_id,
             cm_pay.cur_code trade_price_cur_code,
             ppu_pum_pay.weight trade_price_weight,
             ppu_pum_pay.weight_unit_id trade_price_weight_unit_id,
             qum_pay.qty_unit trade_price_weight_unit,
             ppu_pum.cur_id pd_price_cur_id,
             cm_ppu.cur_code pd_price_cur_code,
             ppu_pum.weight pd_price_weight,
             ppu_pum.weight_unit_id pd_price_weight_unit_id,
             qum_ppu.qty_unit pd_price_weight_unit,
             pofh.pofh_id,
             aml.attribute_id,
             aml.attribute_name,
             pofh.final_price,
             pocd.pay_in_price_unit_id,
             ppu_pum_pay.price_unit_name,
             cm_pay.cur_code pay_in_cur_code
        from pofh_history                   pofh,
             pocd_price_option_calloff_dtls pocd,
             aml_attribute_master_list      aml,
             pcdi_pc_delivery_item          pcdi,
             diqs_delivery_item_qty_status  diqs,
             qum_quantity_unit_master       qum_diqs,
             gmr_goods_movement_record      gmr,
             pcm_physical_contract_main     pcm,
             phd_profileheaderdetails       phd_cp,
             ak_corporate_user              ak_trader,
             gab_globaladdressbook          gab,
             qum_quantity_unit_master       qum_fxd,
             v_ppu_pum                      ppu_pum,
             cm_currency_master             cm_ppu,
             qum_quantity_unit_master       qum_ppu,
             ak_corporate                   akc,
             cm_currency_master             cm_base,
             v_ppu_pum                      ppu_pum_pay,
             cm_currency_master             cm_pay,
             qum_quantity_unit_master       qum_pay
       where pofh.is_modified = 'Y'
         and pofh.pcdi_id = pcdi.pcdi_id
         and pofh.pocd_id = pocd.pocd_id
         and pofh.pcdi_id = diqs.pcdi_id
         and pocd.element_id = aml.attribute_id(+)
         and diqs.item_qty_unit_id = qum_diqs.qty_unit_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
         and pofh.process_id = gmr.process_id(+)
         and pcm.cp_id = phd_cp.profileid
         and pcm.trader_id = ak_trader.user_id
         and ak_trader.gabid = gab.gabid
         and pocd.qty_to_be_fixed_unit_id = qum_fxd.qty_unit_id(+)
         and pofh.latest_price_unit_id = ppu_pum.product_price_unit_id(+)
         and pcm.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm_base.cur_id
         and ppu_pum.cur_id = cm_ppu.cur_id(+)
         and ppu_pum.weight_unit_id = qum_ppu.qty_unit_id(+)
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pofh.corporate_id = pc_corporate_id
         and pofh.process_id = pc_process_id
         and pofh.process = pc_process
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id
         and pocd.pay_in_price_unit_id = ppu_pum_pay.product_price_unit_id
         and pocd.pay_in_cur_id = cm_pay.cur_id(+)
         and ppu_pum_pay.weight_unit_id = qum_pay.qty_unit_id
         and pcm.contract_status = 'In Position'
         and cm_pay.is_active = 'Y';
  
    vc_trade_cur_id        varchar2(15);
    vn_total_price         number(35, 5);
    vc_total_price_unit    varchar2(50);
    vn_pd_to_price_fx_rate number(35, 10);
    vn_pd_convertion_rate  number(35, 10);
    vn_prem_base_conv_rate number(35, 10);
    vn_prem_in_base        number(35, 10);
    vn_tp_in_base          number(35, 10);
    vn_tp_conv_rate        number(35, 10);
    vn_error_no            number := 0;
  
  begin
    for cr_cdc_row in cr_cdc_fixation
    loop
      vc_trade_cur_id := nvl(cr_cdc_row.trade_price_cur_id,
                             cr_cdc_row.base_cur_id);
      /* begin
        pkg_general.sp_get_main_cur_detail(vc_trade_cur_id,
                                           vc_trade_main_cur_id,
                                           vc_trade_main_cur_code,
                                           vn_trade_main_cur_conv_rate,
                                           vn_trade_main_decimals);
      exception
        when others then
          null;
      end;*/
    
      begin
        if vc_trade_cur_id is not null and
           cr_cdc_row.pd_price_cur_id is not null and
           vc_trade_cur_id <> cr_cdc_row.pd_price_cur_id then
          vn_pd_to_price_fx_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                             vc_trade_cur_id,
                                                                             cr_cdc_row.pd_price_cur_id,
                                                                             pd_trade_date,
                                                                             1);
        
        else
          vn_pd_to_price_fx_rate := 1;
        end if;
        if cr_cdc_row.trade_price_unit_id is not null and
           cr_cdc_row.premium_discount_price_unit_id is not null and
           cr_cdc_row.trade_price_unit_id <>
           cr_cdc_row.premium_discount_price_unit_id then
          vn_pd_convertion_rate := f_get_converted_price_pum(pc_corporate_id,
                                                             1,
                                                             cr_cdc_row.premium_discount_price_unit_id,
                                                             cr_cdc_row.trade_price_unit_id,
                                                             pd_trade_date,
                                                             null);
        else
          vn_pd_convertion_rate := 1;
        end if;
      exception
        when others then
          vn_pd_to_price_fx_rate := 1;
          vn_pd_convertion_rate  := 1;
      end;
      --      if cr_cdc_row.
      vn_total_price      := cr_cdc_row.trade_price +
                             (nvl(cr_cdc_row.contract_premium, 0) *
                             vn_pd_convertion_rate); --cr_cdc_row.total_price, -- be a variable
      vc_total_price_unit := cr_cdc_row.price_unit;
      vn_error_no         := 1;
      insert into eod_eom_fixation_journal
        (journal_type,
         book_type,
         process_id,
         process,
         eod_trade_date,
         corporate_id,
         corporate_name,
         product_id,
         product_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         price_fixation_refno,
         internal_derivative_ref_no,
         delivery_item_ref_no,
         delivery_item_qty,
         delivery_item_qty_unit,
         contract_ref_no,
         clearer_profile_id,
         clearer_name,
         trader_name,
         price_fixation_date,
         fixed_quantity,
         quantity_unit,
         trade_price,
         price_unit,
         adjustment,
         fx_rate,
         contract_premium,
         contract_premium_unit,
         total_price,
         total_price_unit,
         contract_issue_date,
         average_from_date,
         average_to_date,
         settlement_price,
         settlement_date,
         strategy_id,
         strategy_name,
         attribute_1,
         attribute_2,
         attribute_3,
         attribute_4,
         attribute_5,
         base_cur_id,
         base_cur_code,
         price_to_base_conv_rate,
         prem_to_base_conv_rate,
         price_in_base_unit,
         premium_in_base_unit,
         base_price_unit,
         base_price_unit_id,
         trade_price_unit_id,
         prem_price_unit_id,
         base_qty_unit,
         base_qty_unit_id,
         price_point_id,
         price_point_name)
      values
        (cr_cdc_row.journal_type,
         cr_cdc_row.book_type,
         pc_process_id,
         pc_process,
         pd_trade_date,
         cr_cdc_row.corporate_id,
         cr_cdc_row.corporate_name,
         cr_cdc_row.product_id,
         cr_cdc_row.product_name,
         cr_cdc_row.profit_center_id,
         cr_cdc_row.profit_center_name,
         cr_cdc_row.profit_center_short_name,
         cr_cdc_row.price_fixation_refno,
         cr_cdc_row.internal_derivative_ref_no,
         cr_cdc_row.delivery_item_ref_no,
         cr_cdc_row.delivery_item_qty,
         cr_cdc_row.delivery_item_qty_unit,
         cr_cdc_row.contract_ref_no,
         cr_cdc_row.clearer_profile_id,
         cr_cdc_row.clearer_name,
         cr_cdc_row.trader_name,
         cr_cdc_row.price_fixation_date,
         cr_cdc_row.fixed_quantity,
         cr_cdc_row.quantity_unit,
         cr_cdc_row.trade_price,
         cr_cdc_row.price_unit,
         cr_cdc_row.adjustment,
         vn_pd_to_price_fx_rate, --need to be a variable
         cr_cdc_row.contract_premium,
         cr_cdc_row.contract_premium_unit,
         vn_total_price, --cr_cdc_row.total_price, -- be a variable
         vc_total_price_unit, -- cr_cdc_row.total_price_unit, --variable
         cr_cdc_row.contract_issue_date,
         cr_cdc_row.average_from_date,
         cr_cdc_row.average_to_date,
         cr_cdc_row.settlement_price,
         cr_cdc_row.settlement_date,
         cr_cdc_row.strategy_id,
         cr_cdc_row.strategy_name,
         cr_cdc_row.attribute_1,
         cr_cdc_row.attribute_2,
         cr_cdc_row.attribute_3,
         cr_cdc_row.attribute_4,
         cr_cdc_row.attribute_5,
         cr_cdc_row.base_cur_id,
         cr_cdc_row.base_cur_code,
         null, --price_to_base_conv_rate,
         null, --prem_to_base_conv_rate,
         null, --price_in_base_unit,
         null, --premium_in_base_unit,
         null, --base_price_unit,
         null, --base_price_unit_id,
         cr_cdc_row.trade_price_unit_id,
         cr_cdc_row.premium_discount_price_unit_id,
         cr_cdc_row.base_qty_unit,
         cr_cdc_row.base_qty_unit_id,
         cr_cdc_row.price_point_id,
         cr_cdc_row.price_point_name);
    end loop;
    commit;
    ---derivative price fixation ends here
    ---derivative price fixation ends here
    vn_error_no := 2;
    insert into pofh_history
      (corporate_id,
       process,
       process_id,
       trade_date,
       pcdi_id,
       pofh_id,
       pocd_id,
       internal_gmr_ref_no,
       qp_start_date,
       qp_end_date,
       qty_to_be_fixed,
       priced_qty,
       no_of_prompt_days,
       per_day_pricing_qty,
       final_price,
       finalize_date,
       version,
       is_active,
       avg_price_in_price_in_cur,
       avg_fx,
       no_of_prompt_days_fixed,
       event_name,
       delta_priced_qty,
       final_price_in_pricing_cur,
       internal_action_ref_no,
       hedge_correction_qty,
       qp_start_qty,
       is_provesional_assay_exist,
       balance_priced_qty,
       per_day_hedge_correction_qty,
       total_hedge_corrected_qty)
      select pc_corporate_id,
             pc_process,
             pc_process_id,
             pd_trade_date,
             pcdi.pcdi_id,
             pofh.pofh_id,
             pofh.pocd_id,
             pofh.internal_gmr_ref_no,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.qty_to_be_fixed,
             pofh.priced_qty,
             pofh.no_of_prompt_days,
             pofh.per_day_pricing_qty,
             pofh.final_price,
             pofh.finalize_date,
             pofh.version,
             pofh.is_active,
             pofh.avg_price_in_price_in_cur,
             pofh.avg_fx,
             pofh.no_of_prompt_days_fixed,
             pofh.event_name,
             pofh.delta_priced_qty,
             pofh.final_price_in_pricing_cur,
             pofh.internal_action_ref_no,
             pofh.hedge_correction_qty,
             pofh.qp_start_qty,
             pofh.is_provesional_assay_exist,
             pofh.balance_priced_qty,
             pofh.per_day_hedge_correction_qty,
             pofh.total_hedge_corrected_qty
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             poch_price_opt_call_off_header poch,
             pcdi_pc_delivery_item          pcdi,
             pcm_physical_contract_main     pcm
       where pofh.pocd_id = pocd.pocd_id
         and pocd.poch_id = poch.poch_id
         and poch.pcdi_id = pcdi.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.corporate_id = pc_corporate_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id;
    --  and pcm.process_id = pc_process_id
    --  and pcdi.process_id = pc_process_id;
    commit;
    for cc in (select pfd.pofh_id,
                      max(axs.action_ref_no) price_fixation_no,
                      max(pfd.as_of_date) price_fixation_date,
                      round(sum(pfd.qty_fixed), 6) fixed_qty,
                      round(sum(pfd.qty_fixed * pfd.user_price) /
                            sum(pfd.qty_fixed),
                            6) avg_price,
                      max(pfd.price_unit_id) price_unit,
                      max(pfd.adjustment_price) adjustment_price
                 from pfd_price_fixation_details              pfd,
                      pfam_price_fix_action_mapping@eka_appdb pfam,
                      axs_action_summary@eka_appdb            axs
                where nvl(pfd.is_hedge_correction, 'N') = 'N'
                  and pfd.pfd_id = pfam.pfd_id
                  and pfam.internal_action_ref_no =
                      axs.internal_action_ref_no
                  and pfd.is_active = 'Y'
                  and pfam.is_active = 'Y'
                     --  and pfd.user_price is not null -- removed this check, as latest avg price not used, only qty fixed, pfc no to be shown
                  and axs.corporate_id = pc_corporate_id
                group by pfd.pofh_id)
    loop
      update pofh_history ppf
         set ppf.latest_pfc_no            = cc.price_fixation_no,
             ppf.latest_pfc_date          = cc.price_fixation_date,
             ppf.latest_fixed_qty         = cc.fixed_qty,
             ppf.latest_avg_price         = cc.avg_price, -- latest_avg_price this column should not be used for any calculation, as this logic changed to use the finalied price recorded in app
             ppf.latest_price_unit_id     = cc.price_unit,
             ppf.latest_adj_price         = nvl(cc.adjustment_price, 0),
             ppf.latest_adj_price_unit_id = cc.price_unit
       where ppf.corporate_id = pc_corporate_id
         and ppf.process = pc_process
         and ppf.process_id = pc_process_id
         and ppf.pofh_id = cc.pofh_id;
    end loop;
    commit;
  
    update pofh_history ppf
       set ppf.is_new = null, ppf.is_deleted = null
     where ppf.process_id = pc_process_id
       and ppf.corporate_id = pc_corporate_id
       and ppf.process = pc_process;
  
    commit;
    update pofh_history ppf
       set ppf.is_new = 'Y'
     where ppf.process_id = pc_process_id
       and ppf.corporate_id = pc_corporate_id
       and ppf.process = pc_process
       and ppf.final_price is not null
       and exists (select ppf1.pofh_id
              from pofh_history ppf1
             where ppf1.process_id = pc_prev_process_id
               and ppf1.corporate_id = pc_corporate_id
               and ppf1.process = pc_process
               and ppf1.pofh_id = ppf.pofh_id
               and ppf1.final_price is null);
    commit;
    update pofh_history ppf
       set ppf.is_new = 'Y'
     where ppf.process_id = pc_process_id
       and ppf.corporate_id = pc_corporate_id
       and ppf.process = pc_process
       and ppf.final_price is not null
       and not exists (select ppf1.pofh_id
              from pofh_history ppf1
             where ppf1.process_id = pc_prev_process_id
               and ppf1.corporate_id = pc_corporate_id
               and ppf1.process = pc_process
               and ppf1.pofh_id = ppf.pofh_id);
    commit;
    update pofh_history ppf
       set ppf.is_deleted = 'Y'
     where ppf.process_id = pc_process_id
       and ppf.corporate_id = pc_corporate_id
       and ppf.process = pc_process
       and ppf.final_price is null
       and exists (select ppf1.pofh_id
              from pofh_history ppf1
             where ppf1.process_id = pc_prev_process_id
               and ppf1.corporate_id = pc_corporate_id
               and ppf1.process = pc_process
               and ppf1.pofh_id = ppf.pofh_id
               and ppf1.final_price is not null);
    commit;
    --- check final price updated between last eod and current eod
    update pofh_history ppf
       set ppf.is_modified = 'Y'
     where ppf.process_id = pc_process_id
       and ppf.corporate_id = pc_corporate_id
       and ppf.process = pc_process
       and ppf.final_price is not null
       and exists (select ppf1.pofh_id
              from pofh_history ppf1
             where ppf1.process_id = pc_prev_process_id
               and ppf1.corporate_id = pc_corporate_id
               and ppf1.process = pc_process
               and ppf1.pofh_id = ppf.pofh_id
               and ppf1.final_price is not null
               and ppf1.final_price <> ppf.final_price);
    ---Physical price fixation starts here
    for cr_cdc_row in cr_phy_fixation
    loop
      vc_trade_cur_id := nvl(cr_cdc_row.trade_price_cur_id,
                             cr_cdc_row.base_cur_id);
    
      vn_error_no := 3;
      insert into eod_eom_fixation_journal
        (journal_type,
         book_type,
         process_id,
         process,
         eod_trade_date,
         corporate_id,
         corporate_name,
         product_id,
         product_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         price_fixation_refno,
         internal_derivative_ref_no,
         delivery_item_ref_no,
         delivery_item_qty,
         delivery_item_qty_unit,
         contract_ref_no,
         clearer_profile_id,
         clearer_name,
         trader_name,
         price_fixation_date,
         fixed_quantity,
         quantity_unit,
         trade_price,
         price_unit,
         adjustment,
         fx_rate,
         contract_premium,
         contract_premium_unit,
         total_price,
         total_price_unit,
         contract_issue_date,
         average_from_date,
         average_to_date,
         settlement_price,
         settlement_date,
         strategy_id,
         strategy_name,
         attribute_1,
         attribute_2,
         attribute_3,
         attribute_4,
         attribute_5,
         base_cur_id,
         base_cur_code,
         price_to_base_conv_rate,
         prem_to_base_conv_rate,
         price_in_base_unit,
         premium_in_base_unit,
         base_price_unit,
         base_price_unit_id,
         trade_price_unit_id,
         prem_price_unit_id,
         attribute_id,
         attribute_name,
         price_in_pay_in_currency,
         pay_in_ccy_unit,
         pay_in_price_unit)
      values
        (cr_cdc_row.journal_type,
         cr_cdc_row.book_type,
         pc_process_id,
         pc_process,
         pd_trade_date,
         cr_cdc_row.corporate_id,
         cr_cdc_row.corporate_name,
         cr_cdc_row.product_id,
         cr_cdc_row.product_name,
         cr_cdc_row.profit_center_id,
         cr_cdc_row.profit_center_name,
         cr_cdc_row.profit_center_short_name,
         cr_cdc_row.price_fixation_refno,
         cr_cdc_row.internal_derivative_ref_no,
         cr_cdc_row.delivery_item_ref_no,
         cr_cdc_row.delivery_item_qty,
         cr_cdc_row.delivery_item_qty_unit,
         cr_cdc_row.contract_ref_no,
         cr_cdc_row.clearer_profile_id,
         cr_cdc_row.clearer_name,
         cr_cdc_row.trader_name,
         cr_cdc_row.price_fixation_date,
         cr_cdc_row.fixed_quantity,
         cr_cdc_row.quantity_unit,
         cr_cdc_row.trade_price,
         cr_cdc_row.price_unit,
         cr_cdc_row.latest_adj_price,
         cr_cdc_row.pay_to_base_fx_rate,
         cr_cdc_row.contract_premium,
         cr_cdc_row.contract_premium_unit,
         null, --cr_cdc_row.total_price, -- be a variable
         null, --cr_cdc_row.total_price_unit, --variable
         cr_cdc_row.contract_issue_date,
         cr_cdc_row.average_from_date,
         cr_cdc_row.average_to_date,
         cr_cdc_row.settlement_price,
         cr_cdc_row.settlement_date,
         cr_cdc_row.strategy_id,
         cr_cdc_row.strategy_name,
         cr_cdc_row.attribute_1,
         cr_cdc_row.attribute_2,
         cr_cdc_row.attribute_3,
         cr_cdc_row.attribute_4,
         cr_cdc_row.attribute_5,
         cr_cdc_row.base_cur_id,
         cr_cdc_row.base_cur_code,
         cr_cdc_row.pay_to_base_fx_rate, --price_to_base_conv_rate,
         null, --prem_to_base_conv_rate,
         null, --price_in_base_unit,
         null, --premium_in_base_unit,
         null, --base_price_unit,
         null, --base_price_unit_id,
         cr_cdc_row.trade_price_unit_id,
         cr_cdc_row.premium_discount_price_unit_id,
         cr_cdc_row.attribute_id,
         cr_cdc_row.attribute_name,
         cr_cdc_row.final_price,
         cr_cdc_row.pay_in_cur_code,
         cr_cdc_row.pay_in_price_unit);
    end loop;
    commit;
    vn_error_no := 4;
    for cc1 in (select pcdi.pcdi_id,
                       cpc.profit_center_id,
                       cpc.profit_center_name,
                       cpc.profit_center_short_name,
                       css.strategy_id,
                       css.strategy_name,
                       pdm.product_id,
                       pdm.product_desc product_name,
                       pdm.base_quantity_unit base_qty_unit_id,
                       qum.qty_unit base_qty_unit
                  from pcm_physical_contract_main   pcm,
                       pcdi_pc_delivery_item        pcdi,
                       pci_physical_contract_item   pci,
                       pcdb_pc_delivery_basis       pcdb,
                       pdm_productmaster            pdm,
                       pcpq_pc_product_quality      pcpq,
                       css_corporate_strategy_setup css,
                       pcpd_pc_product_definition   pcpd,
                       cpc_corporate_profit_center  cpc,
                       qum_quantity_unit_master     qum
                 where pcm.internal_contract_ref_no =
                       pcdi.internal_contract_ref_no
                   and pcdi.pcdi_id = pci.pcdi_id
                   and pci.pcpq_id = pcpq.pcpq_id
                   and pci.pcdb_id = pcdb.pcdb_id
                   and pcpq.pcpd_id = pcpd.pcpd_id
                   and pcm.internal_contract_ref_no =
                       pcdb.internal_contract_ref_no
                   and pcm.internal_contract_ref_no =
                       pcpd.internal_contract_ref_no
                   and pcpd.profit_center_id = cpc.profit_center_id
                   and pcpd.product_id = pdm.product_id
                   and pcpd.strategy_id = css.strategy_id
                   and pdm.base_quantity_unit = qum.qty_unit_id
                   and pcm.contract_status = 'In Position'
                   and pcm.contract_type = 'BASEMETAL'
                   and pcm.process_id = pc_process_id
                   and pcdi.process_id = pc_process_id
                   and pci.process_id = pc_process_id
                   and pcdb.process_id = pc_process_id
                   and pcpq.process_id = pc_process_id
                   and pcpd.process_id = pc_process_id
                   and nvl(pcm.is_tolling_contract, 'N') = 'N'
                   and pci.is_active = 'Y'
                   and pcm.is_active = 'Y'
                   and pcdi.is_active = 'Y'
                   and pcdi.pcdi_id in
                       (select eej.internal_derivative_ref_no
                          from eod_eom_fixation_journal eej
                         where eej.process_id = pc_process_id
                           and eej.corporate_id = pc_corporate_id
                           and eej.process = pc_process
                           and eej.book_type = 'Physical')
                 group by pcdi.pcdi_id,
                          cpc.profit_center_id,
                          cpc.profit_center_name,
                          cpc.profit_center_short_name,
                          css.strategy_id,
                          css.strategy_name,
                          pdm.product_id,
                          pdm.product_desc,
                          pdm.base_quantity_unit,
                          qum.qty_unit)
    loop
      update eod_eom_fixation_journal eej
         set eej.product_id               = cc1.product_id,
             eej.product_name             = cc1.product_name,
             eej.profit_center_id         = cc1.profit_center_id,
             eej.profit_center_name       = cc1.profit_center_name,
             eej.profit_center_short_name = cc1.profit_center_short_name,
             eej.strategy_id              = cc1.strategy_id,
             eej.strategy_name            = cc1.strategy_name,
             eej.base_qty_unit            = cc1.base_qty_unit,
             eej.base_qty_unit_id         = cc1.base_qty_unit_id
       where eej.process_id = pc_process_id
         and eej.corporate_id = pc_corporate_id
         and eej.process = pc_process
         and eej.book_type = 'Physical'
         and eej.internal_derivative_ref_no = cc1.pcdi_id;
    end loop;
    commit;
    for cr_premium in (select pcm.contract_ref_no,
                              pcdi.pcdi_id,
                              pcm.internal_contract_ref_no,
                              pum.price_unit_id premium_unit_id,
                              pum.price_unit_name premium_unit,
                              sum(pci.item_qty * pcqpd.premium_disc_value) /
                              sum(pci.item_qty) avg_premium
                       
                         from pcm_physical_contract_main     pcm,
                              pcdi_pc_delivery_item          pcdi,
                              pci_physical_contract_item     pci,
                              pcqpd_pc_qual_premium_discount pcqpd,
                              ppu_product_price_units        ppu,
                              pum_price_unit_master          pum,
                              pcpdqd_pd_quality_details      pcpdqd
                        where pcm.internal_contract_ref_no =
                              pcdi.internal_contract_ref_no
                          and pcdi.pcdi_id = pci.pcdi_id
                          and pci.pcpq_id = pcpdqd.pcpq_id
                          and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                          and pcm.internal_contract_ref_no =
                              pcqpd.internal_contract_ref_no(+)
                          and pcqpd.premium_disc_unit_id =
                              ppu.internal_price_unit_id(+)
                          and ppu.price_unit_id = pum.price_unit_id(+)
                          and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                          and pcm.process_id = pc_process_id
                          and pcdi.process_id = pc_process_id
                          and pci.process_id = pc_process_id
                          and pcqpd.process_id = pc_process_id
                          and pcm.corporate_id = pc_corporate_id
                          and pcm.is_active = 'Y'
                          and pcqpd.is_active = 'Y'
                        group by pcm.contract_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pum.price_unit_id,
                                 pcdi.pcdi_id,
                                 pcm.internal_contract_ref_no,
                                 pum.price_unit_name)
    loop
    
      update eod_eom_fixation_journal eod_eom
         set eod_eom.prem_price_unit_id    = cr_premium.premium_unit_id,
             eod_eom.contract_premium      = cr_premium.avg_premium,
             eod_eom.contract_premium_unit = cr_premium.premium_unit
       where eod_eom.process_id = pc_process_id
         and eod_eom.corporate_id = pc_corporate_id
         and eod_eom.internal_derivative_ref_no = cr_premium.pcdi_id;
    end loop;
    commit;
    vn_error_no := 5;
    for cr_base in (select pum.price_unit_id,
                           pum.price_unit_name,
                           eod_eom.base_cur_id,
                           eod_eom.base_qty_unit_id
                      from eod_eom_fixation_journal eod_eom,
                           pum_price_unit_master    pum
                     where eod_eom.corporate_id = pc_corporate_id
                       and eod_eom.process_id = pc_process_id
                       and eod_eom.base_cur_id = pum.cur_id
                       and eod_eom.base_qty_unit_id = pum.weight_unit_id
                       and pum.weight is null
                       and pum.is_active = 'Y'
                       and pum.is_deleted = 'N'
                     group by pum.price_unit_id,
                              pum.price_unit_name,
                              eod_eom.base_cur_id,
                              eod_eom.base_qty_unit_id)
    loop
      update eod_eom_fixation_journal eod_eom
         set eod_eom.base_price_unit_id = cr_base.price_unit_id,
             eod_eom.base_price_unit    = cr_base.price_unit_name
       where eod_eom.process_id = pc_process_id
         and eod_eom.corporate_id = pc_corporate_id
         and eod_eom.base_cur_id = cr_base.base_cur_id
         and eod_eom.base_qty_unit_id = cr_base.base_qty_unit_id;
    end loop;
    commit;
    vn_error_no := 6;
    for cr_eod_eom in (select eod_eom.journal_type,
                              eod_eom.book_type,
                              eod_eom.prem_price_unit_id,
                              eod_eom.base_price_unit_id,
                              eod_eom.trade_price_unit_id,
                              eod_eom.product_id,
                              eod_eom.contract_premium,
                              eod_eom.trade_price, -- this price also in pay in currency
                              eod_eom.price_in_pay_in_currency,
                              eod_eom.internal_derivative_ref_no,
                              eod_eom.base_price_unit
                         from eod_eom_fixation_journal eod_eom
                        where eod_eom.corporate_id = pc_corporate_id
                          and eod_eom.process_id = pc_process_id
                       --and eod_eom.book_type = 'Physical'
                       )
    loop
    
      vn_prem_base_conv_rate := round(pkg_phy_custom_reports.f_get_converted_price_pum(pc_corporate_id,
                                                                                       1,
                                                                                       cr_eod_eom.prem_price_unit_id,
                                                                                       cr_eod_eom.base_price_unit_id,
                                                                                       pd_trade_date,
                                                                                       cr_eod_eom.product_id),
                                      4);
      vn_prem_in_base        := nvl(vn_prem_base_conv_rate *
                                    cr_eod_eom.contract_premium,
                                    0);
      vn_tp_conv_rate        := round(pkg_phy_custom_reports.f_get_converted_price_pum(pc_corporate_id,
                                                                                       1,
                                                                                       cr_eod_eom.trade_price_unit_id,
                                                                                       cr_eod_eom.base_price_unit_id,
                                                                                       pd_trade_date,
                                                                                       cr_eod_eom.product_id),
                                      4);
      /*vn_tp_in_base          := nvl(vn_tp_conv_rate *
      cr_eod_eom.trade_price,
      0);*/
      -- Note: here the trade price considered for physical is in pay-incurrency
      vn_tp_in_base := nvl(vn_tp_conv_rate * cr_eod_eom.trade_price, --don't use price_in_pay_in_currency column, this will not have data for derivative section
                           0); --bug id 68531,6859
    
      vn_total_price      := vn_tp_in_base + vn_prem_in_base;
      vc_total_price_unit := cr_eod_eom.base_price_unit;
      if cr_eod_eom.book_type = 'Physical' then
        update eod_eom_fixation_journal eod_eom
           set eod_eom.prem_to_base_conv_rate = vn_prem_base_conv_rate,
               --eod_eom.price_to_base_conv_rate = vn_tp_conv_rate,-- already added in insert query
               eod_eom.premium_in_base_unit = vn_prem_in_base,
               eod_eom.price_in_base_unit   = vn_tp_in_base,
               eod_eom.total_price          = vn_total_price,
               eod_eom.total_price_unit     = vc_total_price_unit
         where eod_eom.internal_derivative_ref_no =
               cr_eod_eom.internal_derivative_ref_no
           and eod_eom.process_id = pc_process_id
           and eod_eom.corporate_id = pc_corporate_id;
      else
        update eod_eom_fixation_journal eod_eom
           set eod_eom.prem_to_base_conv_rate  = vn_prem_base_conv_rate,
               eod_eom.fx_rate                 = vn_tp_conv_rate,
               eod_eom.price_to_base_conv_rate = vn_tp_conv_rate,
               eod_eom.premium_in_base_unit    = vn_prem_in_base,
               eod_eom.price_in_base_unit      = vn_tp_in_base,
               eod_eom.total_price             = vn_total_price,
               eod_eom.total_price_unit        = vc_total_price_unit
         where eod_eom.internal_derivative_ref_no =
               cr_eod_eom.internal_derivative_ref_no
           and eod_eom.process_id = pc_process_id
           and eod_eom.corporate_id = pc_corporate_id;
      end if;
    end loop;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_fixation_journal',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm || ' No ' ||
                                                           vn_error_no,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_physical_risk_position(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_process      varchar2,
                                      pc_process_id   varchar2,
                                      pc_user_id      varchar2) as
  
    vn_total_amount             number(30, 5);
    vn_total_amount_in_base_ccy number(30, 5);
    vn_total_market_price       number(25, 5);
    vn_total_di_price           number(25, 5);
    vn_exchnage_rate            number;
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;    
  begin
  
    for cur_di_detail in (select pcm.corporate_id,
                                 pc_process_id process_id,
                                 ak.corporate_name corporate,
                                 pcm.cp_id,
                                 phd.companyname counter_party,
                                 (case
                                   when pcm.purchase_sales = 'P' then
                                    'Purchase'
                                   when pcm.purchase_sales = 'S' then
                                    'Sale'
                                 end) trade_type,
                                 pcm.contract_ref_no,
                                 pcm.internal_contract_ref_no,
                                 pcm.contract_ref_no || '-' ||
                                 pcdi.delivery_item_no di_item_ref_no,
                                 pcdi.pcdi_id,
                                 pcpd.product_id,
                                 pdm.product_desc product_name,
                                 pcm.contract_type product_type,
                                 pcm.product_group_type,
                                 null element_id,
                                 null element_name,
                                 pcpd.profit_center_id,
                                 cpc.profit_center_name,
                                 cpc.profit_center_short_name,
                                 (case
                                   when pcdi.delivery_from_month is null and
                                        pcdi.delivery_from_year is null then
                                    to_char(pcdi.delivery_from_date,
                                            'dd-Mon-yyyy')
                                   else
                                    pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year
                                 end) del_from_date,
                                 (case
                                   when pcdi.delivery_to_month is null and
                                        pcdi.delivery_to_year is null then
                                    to_char(pcdi.delivery_to_date,
                                            'dd-Mon-yyyy')
                                   else
                                    pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year
                                 end) del_to_date,
                                 ---
                                  (case
                                   when pcdi.delivery_from_month is null and
                                        pcdi.delivery_from_year is null then
                                    pcdi.delivery_from_date
                                   else
                                    to_date('01-'||pcdi.delivery_from_month || '-' ||
                                    pcdi.delivery_from_year,'dd-Mon-yyyy')
                                 end) delivery_from_date,
                                                                   
                                  (case
                                   when pcdi.delivery_to_month is null and
                                        pcdi.delivery_to_year is null then
                                    pcdi.delivery_to_date
                                   else
                                   last_day(to_date('01-'||pcdi.delivery_to_month || '-' ||
                                    pcdi.delivery_to_year,'dd-Mon-yyyy'))
                                 end) delivery_to_date,
                                 -----
                                 diqs.total_qty*pcbpd.qty_to_be_priced/100 del_item_total_qty,
                                 (case
                                   when pcm.purchase_sales = 'P' then
                                    (diqs.total_qty - diqs.final_invoiced_qty)
                                   when pcm.purchase_sales = 'S' then
                                    (-1) *
                                    (diqs.total_qty - diqs.final_invoiced_qty)
                                 end) *pcbpd.qty_to_be_priced/100 del_item_qty,
                                 diqs.item_qty_unit_id di_qty_unit_id,
                                 qum_di.qty_unit di_qty_unit,
                                 cym.country_name || ' , ' || sm.state_name ||
                                 ' , ' || cm_city.city_name stock_location,
                                 pcdb.duty_status duty_status,
                                 ak.base_cur_id,
                                 cm_base.cur_code base_ccy,
                                 pocd.pricing_cur_id,
                                 pocd.qp_period_type,
                                 1 fx_rate,
                                 1 contract_pp_to_price_fx_rate,
                                 1 m2m_price_to_price_fx_rate,
                                 1 m2m_premium_to_price_fx_rate,
                                 pocd.price_type
                          
                            from pcm_physical_contract_main     pcm,
                                 pcdi_pc_delivery_item          pcdi,
                                 ak_corporate                   ak,
                                 phd_profileheaderdetails       phd,
                                 pcpd_pc_product_definition     pcpd,
                                 pdm_productmaster              pdm,
                                 cpc_corporate_profit_center    cpc,
                                 diqs_delivery_item_qty_status  diqs,
                                 qum_quantity_unit_master       qum_di,
                                 pcdiob_di_optional_basis       pcdiob,
                                 pcdb_pc_delivery_basis         pcdb,
                                 cym_countrymaster              cym,
                                 sm_state_master                sm,
                                 cim_citymaster                 cm_city,
                                 cm_currency_master             cm_base,
                                 poch_price_opt_call_off_header poch,
                                 pocd_price_option_calloff_dtls pocd,
                                 pcbpd_pc_base_price_detail     pcbpd                        
                           where pcm.internal_contract_ref_no =
                                 pcdi.internal_contract_ref_no
                             and pcm.is_active = 'Y'
                             and pcdi.is_active = 'Y'
                             and pcm.process_id = pc_process_id
                             and pcdi.process_id = pc_process_id
                             and pcm.corporate_id = ak.corporate_id
                             and pcm.cp_id = phd.profileid
                             and pcm.internal_contract_ref_no =
                                 pcpd.internal_contract_ref_no
                             and pcpd.process_id = pc_process_id
                             and pcpd.is_active = 'Y'
                             and pcpd.product_id = pdm.product_id
                             and pcpd.profit_center_id =
                                 cpc.profit_center_id
                             and pcdi.pcdi_id = diqs.pcdi_id
                             and diqs.is_active = 'Y'
                             and diqs.process_id = pc_process_id
                             and diqs.item_qty_unit_id = qum_di.qty_unit_id
                            /* and pcm.internal_contract_ref_no =
                                 pcdb.internal_contract_ref_no*/
                             and pcdi.pcdi_id = pcdiob.pcdi_id
                             and pcdiob.process_id = pc_process_id
                             and pcdiob.is_active = 'Y'
                             and pcdb.pcdb_id = pcdiob.pcdb_id
                             and pcdb.is_active = 'Y'
                             and pcdb.process_id = pc_process_id
                             and pcdb.country_id = cym.country_id
                             and pcdb.state_id = sm.state_id
                             and pcdb.city_id = cm_city.city_id
                             and cym.country_id = sm.country_id
                             and ak.base_cur_id = cm_base.cur_id
                             and pcm.corporate_id = pc_corporate_id
                             and pcm.contract_type = 'BASEMETAL'
                             and pcm.contract_status = 'In Position'
                             and pcdi.pcdi_id = poch.pcdi_id
                                --  and pocd.price_type <> 'Fixed'
                             and (diqs.total_qty - diqs.final_invoiced_qty-diqs.fulfilled_qty) > 0
                             and poch.is_active = 'Y'
                             and poch.poch_id = pocd.poch_id
                             and pocd.is_active = 'Y'
                             and pocd.pcbpd_id=pcbpd.pcbpd_id
                             and pcbpd.process_id=pc_process_id
                             and pcbpd.is_active='Y')
    
    loop
    
      insert into prp_physical_risk_position
        (corporate_id,
         corporate,
         cp_id,
         counter_party,
         trade_type,
         cont_ref_no,
         int_cont_ref_no,
         di_item_ref_no,
         pcdi_id,
         product_id,
         product_name,
         product_type,
         product_group,
         element_id,
         element_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         del_from_date,
         del_to_date,
         del_item_qty,
         di_qty_unit_id,
         di_qty_unit,
         stock_location,
         duty_status,
         base_cur_id,
         base_ccy,
         fx_rate,
         process_id,
         process,
         qp_period_type,
         contract_price_cur_id,
         contract_pp_to_price_fx_rate,
         m2m_price_to_price_fx_rate,
         m2m_premium_to_price_fx_rate,
         price_type,
         delivery_from_date,
         delivery_to_date)
      values
        (cur_di_detail.corporate_id,
         cur_di_detail.corporate,
         cur_di_detail.cp_id,
         cur_di_detail.counter_party,
         cur_di_detail.trade_type,
         cur_di_detail.contract_ref_no,
         cur_di_detail.internal_contract_ref_no,
         cur_di_detail.di_item_ref_no,
         cur_di_detail.pcdi_id,
         cur_di_detail.product_id,
         cur_di_detail.product_name,
         cur_di_detail.product_type,
         cur_di_detail.product_group_type,
         cur_di_detail.element_id,
         cur_di_detail.element_name,
         cur_di_detail.profit_center_id,
         cur_di_detail.profit_center_name,
         cur_di_detail.profit_center_short_name,
         cur_di_detail.del_from_date,
         cur_di_detail.del_to_date,
         cur_di_detail.del_item_qty,
         cur_di_detail.di_qty_unit_id,
         cur_di_detail.di_qty_unit,
         cur_di_detail.stock_location,
         cur_di_detail.duty_status,
         cur_di_detail.base_cur_id,
         cur_di_detail.base_ccy,
         cur_di_detail.fx_rate,
         cur_di_detail.process_id,
         pc_process,
         cur_di_detail.qp_period_type,
         cur_di_detail.pricing_cur_id,
         cur_di_detail.contract_pp_to_price_fx_rate,
         cur_di_detail.m2m_price_to_price_fx_rate,
         cur_di_detail.m2m_premium_to_price_fx_rate,
         cur_di_detail.price_type,
         cur_di_detail.delivery_from_date,
         cur_di_detail.delivery_to_date);
    end loop;
    commit;
  
    -- update priced qty all DI item
  
    for cur_priced_qty in (select pcdi.pcdi_id,
                                  pocd.qty_to_be_fixed_unit_id qty_unit_id,
                                  qum.qty_unit,
                                  sum(pofh.priced_qty) priced_qty
                             from pcdi_pc_delivery_item          pcdi,
                                  poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  qum_quantity_unit_master       qum
                            where pcdi.pcdi_id = poch.pcdi_id
                              and pcdi.process_id = pc_process_id
                              and pcdi.is_active = 'Y'
                              and poch.poch_id = pocd.poch_id
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.is_active = 'Y'
                              and pocd.qty_to_be_fixed_unit_id =
                                  qum.qty_unit_id
                              and pofh.final_price is not null
                            group by pcdi.pcdi_id,
                                     pocd.qty_to_be_fixed_unit_id,
                                     qum.qty_unit)
    
    loop
      update prp_physical_risk_position prp
         set prp.priced_qty         = (case when prp.trade_type = 'Purchase' then ---
              nvl(cur_priced_qty.priced_qty, 0) --
              else --
              (-1) * nvl(cur_priced_qty.priced_qty, 0) --
              end),
             prp.priced_qty_unit_id = cur_priced_qty.qty_unit_id,
             prp.price_qty_unit     = cur_priced_qty.qty_unit
       where cur_priced_qty.pcdi_id = prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process
         and prp.product_type = 'BASEMETAL';
    end loop;
    commit;
    
    --- update the priced qty for Fixed contracts.
    update prp_physical_risk_position prp
          set prp.priced_qty=prp.del_item_qty,
              prp.priced_qty_unit_id=prp.di_qty_unit_id,
              prp.price_qty_unit=prp.di_qty_unit
          where prp.process_id=pc_process_id
            and prp.price_type='Fixed'
            and prp.product_type = 'BASEMETAL';          
    commit;
  
    --contract price with out event based
    for cur_cont_price in (select cipd.pcdi_id,
                                  cipd.contract_price di_item_price,
                                  ppu_pum.product_price_unit_id di_item_price_unit_id,
                                  ppu_pum.price_unit_name di_item_price_unit,
                                  cipd.price_unit_cur_id,
                                  cipd.price_unit_cur_code
                             from cipd_contract_item_price_daily cipd,
                                  v_ppu_pum                      ppu_pum
                            where cipd.price_unit_id =
                                  ppu_pum.product_price_unit_id
                              and cipd.process_id = pc_process_id
                              and cipd.corporate_id = pc_corporate_id
                            group by cipd.pcdi_id,
                                     cipd.contract_price,
                                     ppu_pum.product_price_unit_id,
                                     ppu_pum.price_unit_name,
                                     cipd.price_unit_cur_id,
                                     cipd.price_unit_cur_code)
    loop
      update prp_physical_risk_position prp
         set prp.di_price         = cur_cont_price.di_item_price,
             prp.di_price_unit_id = cur_cont_price.di_item_price_unit_id,
             prp.di_price_unit    = cur_cont_price.di_item_price_unit,
             prp.total_amount_cur_id=cur_cont_price.price_unit_cur_id,
             prp.total_amount_cur_code=cur_cont_price.price_unit_cur_code
       where cur_cont_price.pcdi_id = prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process
         and nvl(prp.qp_period_type, 'NA') not in ('Event')
         and prp.product_type = 'BASEMETAL';
    end loop;
    commit;
  
    -- contract price with event based
  
    for cur_cont_price_event in (select t.pcdi_id,
                                       (case when sum(qty)=0 then 0
                                       else
                                       sum(t.price * qty) / sum(qty)
                                       end) weight_avg_price,
                                        t.price_unit_id di_item_price_unit_id,
                                        t.price_unit_name di_item_price_unit,
                                        t.price_unit_cur_id,
                                        t.price_unit_cur_code
                                   from (select pcdi.pcdi_id,
                                                (case when  sum(pofh.qty_to_be_fixed)=0 then 0
                                                else
                                                sum(gpd.contract_price *
                                                    pofh.qty_to_be_fixed) /
                                                sum(pofh.qty_to_be_fixed)
                                                end) price,
                                                sum(pofh.qty_to_be_fixed) qty,
                                                gpd.price_unit_id,
                                                pum.price_unit_name,
                                                gpd.price_unit_cur_id,
                                                gpd.price_unit_cur_code
                                           from pcdi_pc_delivery_item          pcdi,
                                                poch_price_opt_call_off_header poch,
                                                pocd_price_option_calloff_dtls pocd,
                                                pofh_price_opt_fixation_header pofh,
                                                gmr_goods_movement_record      gmr,
                                                gpd_gmr_price_daily            gpd,
                                                diqs_delivery_item_qty_status  diqs,
                                                v_ppu_pum                      pum
                                          where pcdi.pcdi_id = poch.pcdi_id
                                            and pcdi.process_id =
                                                pc_process_id
                                            and pcdi.is_active = 'Y'
                                            and poch.poch_id = pocd.poch_id
                                            and poch.is_active = 'Y'
                                            and pocd.is_active = 'Y'
                                            and pocd.pocd_id = pofh.pocd_id
                                            and pofh.internal_gmr_ref_no =
                                                gmr.internal_gmr_ref_no
                                            and gmr.process_id =
                                                pc_process_id
                                            and pofh.is_active = 'Y'
                                            and gmr.is_deleted = 'N'
                                            and gmr.internal_gmr_ref_no =
                                                gpd.internal_gmr_ref_no
                                            and gpd.process_id =
                                                pc_process_id
                                            and pcdi.pcdi_id = diqs.pcdi_id
                                            and diqs.process_id =
                                                pc_process_id
                                            and diqs.is_active = 'Y'
                                            and gpd.price_unit_id =
                                                pum.product_price_unit_id
                                          group by pcdi.pcdi_id,
                                                   gpd.price_unit_id,
                                                   pum.price_unit_name,
                                                   gpd.price_unit_cur_id,
                                                   gpd.price_unit_cur_code
                                         union all
                                         select pcdi.pcdi_id,
                                                cipd.contract_price price,
                                                (diqs.total_qty -
                                                diqs.final_invoiced_qty) qty,
                                                cipd.price_unit_id,
                                                pum.price_unit_name,
                                                cipd.price_unit_cur_id,
                                                cipd.price_unit_cur_code
                                         
                                           from pcdi_pc_delivery_item          pcdi,
                                                diqs_delivery_item_qty_status  diqs,
                                                cipd_contract_item_price_daily cipd,
                                                v_ppu_pum                      pum
                                          where pcdi.pcdi_id = diqs.pcdi_id
                                            and pcdi.is_active = 'Y'
                                            and diqs.is_active = 'Y'
                                            and pcdi.pcdi_id = cipd.pcdi_id
                                            and pcdi.process_id =
                                                pc_process_id
                                            and diqs.process_id =
                                                pc_process_id
                                            and cipd.process_id =
                                                pc_process_id
                                            and cipd.price_unit_id =
                                                pum.product_price_unit_id
                                          group by pcdi.pcdi_id,
                                                   (diqs.total_qty -
                                                   diqs.final_invoiced_qty),
                                                   cipd.contract_price,
                                                   cipd.price_unit_id,
                                                   pum.price_unit_name,
                                                   cipd.price_unit_cur_id,
                                                   cipd.price_unit_cur_code) t
                                  group by t.pcdi_id,
                                           t.price_unit_id,
                                           t.price_unit_name,
                                           t.price_unit_cur_id,
                                           t.price_unit_cur_code)
    
    loop
      update prp_physical_risk_position prp
         set prp.di_price         = cur_cont_price_event.weight_avg_price,
             prp.di_price_unit_id = cur_cont_price_event.di_item_price_unit_id,
             prp.di_price_unit    = cur_cont_price_event.di_item_price_unit,
             prp.total_amount_cur_id=cur_cont_price_event.price_unit_cur_id,
             prp.total_amount_cur_code=cur_cont_price_event.price_unit_cur_code
       where cur_cont_price_event.pcdi_id = prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process
         and prp.qp_period_type = 'Event'
         and prp.product_type = 'BASEMETAL';
    end loop;
    commit;
  
    -- contract price with fixed contracts
    for cur_fixed in (select t.pcdi_id,
                            (case when sum(qty)=0 then 0
                             else                             
                             sum(t.price * qty) / sum(qty)
                             end) market_price,
                             t.market_price_unit_id,
                             t.market_price_unit,
                             t.market_price_cur_id
                        from (select nvl(tmpc.pcdi_id, grd.pcdi_id) pcdi_id,
                                     (case when sum(grd.current_qty *
                                         ucm.multiplication_factor)=0 then 0
                                        else                                         
                                     sum(grd.current_qty *
                                         ucm.multiplication_factor *
                                         md.m2m_settlement_price) /
                                     sum(grd.current_qty *
                                         ucm.multiplication_factor)
                                      end) price,
                                     sum(grd.current_qty *
                                         ucm.multiplication_factor) qty,
                                     md.m2m_price_unit_id market_price_unit_id,
                                     pum.price_unit_name market_price_unit,
                                     pum.cur_id  market_price_cur_id
                                from gmr_goods_movement_record  gmr,
                                     grd_goods_record_detail    grd,
                                     tmpc_temp_m2m_pre_check    tmpc,
                                     md_m2m_daily               md,
                                     pcdi_pc_delivery_item      pcdi,
                                     ucm_unit_conversion_master ucm,
                                     pum_price_unit_master      pum
                               where gmr.internal_gmr_ref_no =
                                     grd.internal_gmr_ref_no
                                 and gmr.process_id = pc_process_id
                                 and grd.process_id = pc_process_id
                                 and gmr.is_deleted = 'N'
                                 and grd.status = 'Active'
                                 and tmpc.internal_gmr_ref_no =
                                     gmr.internal_gmr_ref_no
                                 and tmpc.internal_grd_ref_no =
                                     grd.internal_grd_ref_no
                                 and tmpc.section_name <> 'OPEN'
                                 and pcdi.pcdi_id = grd.pcdi_id
                                 and pcdi.process_id = pc_process_id
                                 and tmpc.internal_m2m_id = md.md_id
                                 and md.process_id = pc_process_id
                                 and pcdi.is_active = 'Y'
                                 and ucm.is_active = 'Y'
                                 and ucm.from_qty_unit_id = grd.qty_unit_id
                                 and ucm.to_qty_unit_id = pcdi.qty_unit_id
                                 and md.m2m_price_unit_id = pum.price_unit_id
                               group by nvl(tmpc.pcdi_id, grd.pcdi_id),
                                        md.m2m_price_unit_id,
                                        pum.price_unit_name,
                                        pum.cur_id
                              union
                              select pcdi.pcdi_id,
                                     md.m2m_settlement_price price,
                                     diqs.open_qty  qty,
                                     md.m2m_price_unit_id market_price_unit_id,
                                     pum.price_unit_name market_price_unit,
                                     pum.cur_id  market_price_cur_id
                                from pcdi_pc_delivery_item         pcdi,
                                     diqs_delivery_item_qty_status diqs,
                                     tmpc_temp_m2m_pre_check       tmpc,
                                     pum_price_unit_master         pum,
                                     md_m2m_daily                  md
                               where pcdi.process_id = pc_process_id
                                 and diqs.pcdi_id = pcdi.pcdi_id
                                 and diqs.process_id = pc_process_id
                                 and pcdi.is_active = 'Y'
                                 and diqs.is_active = 'Y'
                                 and tmpc.pcdi_id = pcdi.pcdi_id
                                 and tmpc.section_name = 'OPEN'
                                 and tmpc.internal_m2m_id = md.md_id
                                 and md.process_id = pc_process_id
                                 and md.m2m_price_unit_id = pum.price_unit_id
                               group by pcdi.pcdi_id,
                                        diqs.open_qty,
                                        md.m2m_settlement_price,
                                        md.m2m_price_unit_id,
                                        pum.price_unit_name,
                                        pum.cur_id) t
                       group by t.pcdi_id,
                                t.market_price_unit_id,
                                t.market_price_unit,
                                t.market_price_cur_id)
    loop
      update prp_physical_risk_position prp
         set prp.market_price         = cur_fixed.market_price,
             prp.market_price_unit_id = cur_fixed.market_price_unit_id,
             prp.market_price_unit    = cur_fixed.market_price_unit,
             prp.m2m_price_cur_id     = cur_fixed.market_price_cur_id
       where cur_fixed.pcdi_id = prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process
         and prp.price_type = 'Fixed'
         and prp.product_type = 'BASEMETAL';
    end loop;
    commit;
  
    -- contract premium  with all di Items
    for cur_cont_premium in (select pcm.contract_ref_no,
                                    pcdi.pcdi_id,
                                    pcm.internal_contract_ref_no,
                                    pum.price_unit_id premium_unit_id,
                                    pum.price_unit_name premium_unit,
                                    pum.cur_id premium_cur_id,
                                    (case when sum(pci.item_qty) =0 then 0
                                    else                                    
                                    sum(pci.item_qty *
                                        pcqpd.premium_disc_value) /
                                    sum(pci.item_qty)
                                    end) avg_premium

                               from pcm_physical_contract_main     pcm,
                                    pcdi_pc_delivery_item          pcdi,
                                    pci_physical_contract_item     pci,
                                    pcqpd_pc_qual_premium_discount pcqpd,
                                    ppu_product_price_units        ppu,
                                    pum_price_unit_master          pum,
                                    pcpdqd_pd_quality_details      pcpdqd
                              where pcm.internal_contract_ref_no =
                                    pcdi.internal_contract_ref_no
                                and pcdi.pcdi_id = pci.pcdi_id
                                and pci.pcpq_id = pcpdqd.pcpq_id
                                and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                and pcm.internal_contract_ref_no =
                                    pcqpd.internal_contract_ref_no(+)
                                and pcqpd.premium_disc_unit_id =
                                    ppu.internal_price_unit_id(+)
                                and ppu.price_unit_id = pum.price_unit_id(+)
                                and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                                and pcm.process_id = pc_process_id
                                and pcdi.process_id = pc_process_id
                                and pci.process_id = pc_process_id
                                and pcqpd.process_id = pc_process_id
                                and pcm.corporate_id = pc_corporate_id
                                and pcm.is_active = 'Y'
                                and pcqpd.is_active = 'Y'
                              group by pcm.contract_ref_no,
                                       pcdi.pcdi_id,
                                       pcm.internal_contract_ref_no,
                                       pum.price_unit_id,
                                       pum.price_unit_name,
                                       pum.cur_id)
    loop
      update prp_physical_risk_position prp
         set prp.contract_premium         = cur_cont_premium.avg_premium,
             prp.contract_premium_unit_id = cur_cont_premium.premium_unit_id,
             prp.contract_premium_unit    = cur_cont_premium.premium_unit,
             prp.contract_premium_cur_id  = cur_cont_premium.premium_cur_id
       where cur_cont_premium.pcdi_id = prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process
         and prp.product_type = 'BASEMETAL';
      commit;
    end loop;
  
    --- Market Price With out Event  Based
    for cur_mar_price in (select cmp.pcdi_id,
                                 cmp.price market_price,
                                 ppu_pum.product_price_unit_id market_price_unit_id,
                                 ppu_pum.price_unit_name market_price_unit,
                                 ppu_pum.cur_id market_price_cur_id
                            from cmp_contract_market_price cmp,
                                 v_ppu_pum                 ppu_pum
                           where cmp.price_unit_id =
                                 ppu_pum.product_price_unit_id
                             and cmp.process_id = pc_process_id
                           group by cmp.pcdi_id,
                                    cmp.price,
                                    ppu_pum.product_price_unit_id,
                                    ppu_pum.price_unit_name,
                                    ppu_pum.cur_id)
    loop
      update prp_physical_risk_position prp
         set prp.market_price         = cur_mar_price.market_price,
             prp.market_price_unit_id = cur_mar_price.market_price_unit_id,
             prp.market_price_unit    = cur_mar_price.market_price_unit,
             prp.m2m_price_cur_id     = cur_mar_price.market_price_cur_id
       where cur_mar_price.pcdi_id = prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process
         and nvl(prp.qp_period_type, 'NA') not in ('Event')
         and prp.product_type = 'BASEMETAL';
    end loop;
    commit;
  
    -- Market price Event Based contracts
  
    for cur_mar_price_event in (select t.pcdi_id,
                                       (case when sum(qty)=0 then 0
                                       else
                                       sum(t.price * qty) / sum(qty)
                                       end) weight_avg_price,
                                       t.price_unit_id market_price_unit_id,
                                       t.price_unit_name market_price_unit,
                                       t.cur_id market_price_cur_id
                                  from (select pcdi.pcdi_id,
                                               (case when sum(pofh.qty_to_be_fixed)=0 then 0
                                               else
                                               sum(gpd.contract_price *
                                                   pofh.qty_to_be_fixed) /
                                               sum(pofh.qty_to_be_fixed)
                                               end) price,
                                               sum(pofh.qty_to_be_fixed) qty,
                                               gpd.price_unit_id,
                                               pum.price_unit_name,
                                               pum.cur_id
                                          from pcdi_pc_delivery_item          pcdi,
                                               poch_price_opt_call_off_header poch,
                                               pocd_price_option_calloff_dtls pocd,
                                               pofh_price_opt_fixation_header pofh,
                                               gmr_goods_movement_record      gmr,
                                               gpd_gmr_price_daily            gpd,
                                               diqs_delivery_item_qty_status  diqs,
                                               v_ppu_pum                      pum
                                         where pcdi.pcdi_id = poch.pcdi_id
                                           and pcdi.process_id =
                                               pc_process_id
                                           and pcdi.is_active = 'Y'
                                           and poch.poch_id = pocd.poch_id
                                           and poch.is_active = 'Y'
                                           and pocd.is_active = 'Y'
                                           and pocd.pocd_id = pofh.pocd_id
                                           and pofh.internal_gmr_ref_no =
                                               gmr.internal_gmr_ref_no
                                           and gmr.process_id = pc_process_id
                                           and pofh.is_active = 'Y'
                                           and gmr.is_deleted = 'N'
                                           and gmr.internal_gmr_ref_no =
                                               gpd.internal_gmr_ref_no
                                           and gpd.process_id = pc_process_id
                                           and pcdi.pcdi_id = diqs.pcdi_id
                                           and diqs.process_id =
                                               pc_process_id
                                           and diqs.is_active = 'Y'
                                           and gpd.price_unit_id =
                                               pum.product_price_unit_id
                                         group by pcdi.pcdi_id,
                                                  gpd.price_unit_id,
                                                  pum.price_unit_name,
                                                  pum.cur_id
                                        union all
                                        select pcdi.pcdi_id,
                                               cipd.contract_price price,
                                               (diqs.total_qty -
                                               diqs.final_invoiced_qty) qty,
                                               cipd.price_unit_id,
                                               pum.price_unit_name,
                                               pum.cur_id
                                        
                                          from pcdi_pc_delivery_item          pcdi,
                                               diqs_delivery_item_qty_status  diqs,
                                               cipd_contract_item_price_daily cipd,
                                               v_ppu_pum                      pum
                                         where pcdi.pcdi_id = diqs.pcdi_id
                                           and pcdi.is_active = 'Y'
                                           and diqs.is_active = 'Y'
                                           and pcdi.pcdi_id = cipd.pcdi_id
                                           and pcdi.process_id =
                                               pc_process_id
                                           and diqs.process_id =
                                               pc_process_id
                                           and cipd.process_id =
                                               pc_process_id
                                           and cipd.price_unit_id =
                                               pum.product_price_unit_id
                                         group by pcdi.pcdi_id,
                                                  (diqs.total_qty -
                                                  diqs.final_invoiced_qty),
                                                  cipd.contract_price,
                                                  cipd.price_unit_id,
                                                  pum.price_unit_name,
                                                  pum.cur_id) t
                                 group by t.pcdi_id,
                                          t.price_unit_id,
                                          t.price_unit_name,
                                          t.cur_id)
    
    loop
      update prp_physical_risk_position prp
         set prp.market_price         = cur_mar_price_event.weight_avg_price,
             prp.market_price_unit_id = cur_mar_price_event.market_price_unit_id,
             prp.market_price_unit    = cur_mar_price_event.market_price_unit,
             prp.m2m_price_cur_id     = cur_mar_price_event.market_price_cur_id
       where cur_mar_price_event.pcdi_id = prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process
         and prp.qp_period_type = 'Event'
         and prp.product_type = 'BASEMETAL';
    end loop;
    commit;
  
    --   For updating the m2m Premium   
  
    for cc_m2m_premium in (select t.pcdi_id,
                                 (case when  sum(qty)=0 then 0
                                 else
                                  sum(t.quality_premium * qty) / sum(qty) +
                                  sum(t.product_premium * qty) / sum(qty)
                                  end) market_premium,
                                  t.market_premium_price_unit_id,
                                  t.market_premium_price_unit
                             from (select nvl(tmpc.pcdi_id, grd.pcdi_id) pcdi_id,
                                          (case when sum(grd.current_qty *
                                              ucm.multiplication_factor)=0 then 0
                                            else
                                          sum(grd.current_qty *
                                              ucm.multiplication_factor *
                                              tmpc.m2m_qp_in_corporate_fx_rate) /
                                          sum(grd.current_qty *
                                              ucm.multiplication_factor)
                                           end) quality_premium,
                                          (case when sum(grd.current_qty *
                                              ucm.multiplication_factor)=0 then 0
                                            else
                                          sum(grd.current_qty *
                                              ucm.multiplication_factor *
                                              tmpc.m2m_pp_in_corporate_fx_rate) /
                                          sum(grd.current_qty *
                                              ucm.multiplication_factor)
                                           end) product_premium,
                                          sum(grd.current_qty *
                                              ucm.multiplication_factor) qty,
                                          tmpc.base_price_unit_id_in_ppu market_premium_price_unit_id,
                                          pum.price_unit_name market_premium_price_unit
                                   
                                     from gmr_goods_movement_record  gmr,
                                          grd_goods_record_detail    grd,
                                          tmpc_temp_m2m_pre_check    tmpc,
                                          pcdi_pc_delivery_item      pcdi,
                                          ucm_unit_conversion_master ucm,
                                          v_ppu_pum                  pum
                                    where gmr.internal_gmr_ref_no =
                                          grd.internal_gmr_ref_no
                                      and gmr.process_id = pc_process_id
                                      and grd.process_id = pc_process_id
                                      and gmr.is_deleted = 'N'
                                      and grd.status = 'Active'
                                      and tmpc.internal_gmr_ref_no =
                                          gmr.internal_gmr_ref_no
                                      and tmpc.internal_grd_ref_no =
                                          grd.internal_grd_ref_no
                                      and tmpc.section_name <> 'OPEN'
                                      and pcdi.pcdi_id = grd.pcdi_id
                                      and pcdi.process_id = pc_process_id
                                      and pcdi.is_active = 'Y'
                                      and ucm.is_active = 'Y'
                                      and ucm.from_qty_unit_id =
                                          grd.qty_unit_id
                                      and ucm.to_qty_unit_id =
                                          pcdi.qty_unit_id
                                      and tmpc.base_price_unit_id_in_ppu =
                                          pum.product_price_unit_id
                                    group by nvl(tmpc.pcdi_id, grd.pcdi_id),
                                             tmpc.base_price_unit_id_in_ppu,
                                             pum.price_unit_name
                                   union
                                   select pcdi.pcdi_id,
                                          tmpc.m2m_qp_in_corporate_fx_rate quality_premium,
                                          tmpc.m2m_pp_in_corporate_fx_rate product_premium,
                                          diqs.open_qty  qty,
                                          tmpc.base_price_unit_id_in_ppu market_premium_price_unit_id,
                                          pum.price_unit_name market_premium_price_unit
                                     from pcdi_pc_delivery_item         pcdi,
                                          diqs_delivery_item_qty_status diqs,
                                          tmpc_temp_m2m_pre_check       tmpc,
                                          v_ppu_pum                     pum
                                    where pcdi.process_id = pc_process_id
                                      and diqs.pcdi_id = pcdi.pcdi_id
                                      and diqs.process_id = pc_process_id
                                      and pcdi.is_active = 'Y'
                                      and diqs.is_active = 'Y'
                                      and tmpc.pcdi_id = pcdi.pcdi_id
                                      and tmpc.section_name = 'OPEN'
                                      and tmpc.base_price_unit_id_in_ppu =
                                          pum.product_price_unit_id
                                    group by pcdi.pcdi_id,
                                             diqs.open_qty,
                                             tmpc.m2m_qp_in_corporate_fx_rate,
                                             tmpc.m2m_pp_in_corporate_fx_rate,
                                             tmpc.base_price_unit_id_in_ppu,
                                             pum.price_unit_name) t
                            group by t.pcdi_id,
                                     t.market_premium_price_unit_id,
                                     t.market_premium_price_unit)
    loop
      update prp_physical_risk_position prp
         set prp.market_premium        = cc_m2m_premium.market_premium,
             prp.market_premium_cur_id = cc_m2m_premium.market_premium_price_unit_id,
             prp.market_premium_ccy    = cc_m2m_premium.market_premium_price_unit
      
       where cc_m2m_premium.pcdi_id = prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process
         and prp.product_type = 'BASEMETAL';
    end loop;
    commit;
  
    --- Update FX rate
    
    for cc_prp_fx_rate in (select prp.contract_price_cur_id to_cur_id,
                                  prp.contract_premium_cur_id from_cur_id
                             from prp_physical_risk_position prp
                            where prp.contract_price_cur_id <>
                                  prp.contract_premium_cur_id
                              and prp.corporate_id = pc_corporate_id
                              and prp.process_id = pc_process_id
                              and prp.process = pc_process
                            group by prp.contract_price_cur_id,
                                     prp.contract_premium_cur_id
                           union
                           select prp.contract_price_cur_id,
                                  prp.m2m_price_cur_id
                             from prp_physical_risk_position prp
                            where prp.contract_price_cur_id <>
                                  prp.m2m_price_cur_id
                              and prp.corporate_id = pc_corporate_id
                              and prp.process_id = pc_process_id
                              and prp.process = pc_process
                            group by prp.contract_price_cur_id,
                                     prp.m2m_price_cur_id
                           union
                           select prp.base_cur_id, -- M2m Premium cur_id
                                  prp.contract_price_cur_id
                             from prp_physical_risk_position prp
                            where prp.contract_price_cur_id <>
                                  prp.base_cur_id
                              and prp.corporate_id = pc_corporate_id
                              and prp.process_id = pc_process_id
                              and prp.process = pc_process
                            group by prp.contract_price_cur_id,
                                     prp.base_cur_id)
    loop
      vn_exchnage_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                   cc_prp_fx_rate.from_cur_id,
                                                                   cc_prp_fx_rate.to_cur_id,
                                                                   pd_trade_date,
                                                                   1);
      update prp_physical_risk_position prp
         set prp.contract_pp_to_price_fx_rate = vn_exchnage_rate
       where prp.contract_price_cur_id = cc_prp_fx_rate.from_cur_id
         and prp.contract_premium_cur_id = cc_prp_fx_rate.to_cur_id
         and prp.corporate_id = pc_corporate_id
         and prp.process_id = pc_process_id
         and prp.process = pc_process;
      commit;
      update prp_physical_risk_position prp
         set prp.m2m_price_to_price_fx_rate = vn_exchnage_rate
       where prp.contract_price_cur_id = cc_prp_fx_rate.from_cur_id
         and prp.m2m_price_cur_id = cc_prp_fx_rate.to_cur_id
         and prp.corporate_id = pc_corporate_id
         and prp.process_id = pc_process_id
         and prp.process = pc_process;
      commit;
      update prp_physical_risk_position prp
         set prp.m2m_premium_to_price_fx_rate = vn_exchnage_rate,
             prp.fx_rate                      = vn_exchnage_rate
       where prp.contract_price_cur_id = cc_prp_fx_rate.to_cur_id
         and prp.base_cur_id =cc_prp_fx_rate.from_cur_id 
         and prp.corporate_id = pc_corporate_id
         and prp.process_id = pc_process_id
         and prp.process = pc_process;
      commit;
    end loop;
    commit;
  
    --Calculate total
    for cc_prp in (select nvl(prp.market_premium, 0) market_premium,
                          prp.m2m_premium_to_price_fx_rate,
                          nvl(prp.contract_premium, 0) contract_premium,
                          prp.contract_pp_to_price_fx_rate,
                          nvl(prp.market_price, 0) market_price,
                          prp.m2m_price_to_price_fx_rate,
                          nvl(prp.di_price, 0) di_price,
                          prp.del_item_qty,
                          prp.fx_rate,
                          prp.pcdi_id
                     from prp_physical_risk_position prp
                    where prp.corporate_id = pc_corporate_id
                      and prp.process_id = pc_process_id
                      and prp.process = pc_process)
    loop
    
      vn_total_market_price := (cc_prp.market_price *
                               cc_prp.m2m_price_to_price_fx_rate) +
                               (cc_prp.market_premium *
                               cc_prp.m2m_premium_to_price_fx_rate);
    
      vn_total_di_price := cc_prp.di_price +
                           (cc_prp.contract_premium *
                           cc_prp.contract_pp_to_price_fx_rate);
    
      vn_total_amount             := round(cc_prp.del_item_qty *
                                           (vn_total_market_price -
                                           vn_total_di_price),
                                           4);
      vn_total_amount_in_base_ccy := vn_total_amount * cc_prp.fx_rate;
    
      update prp_physical_risk_position prp
         set prp.total_amount      = vn_total_amount,
             prp.total_in_base_ccy = vn_total_amount_in_base_ccy
       where prp.pcdi_id = cc_prp.pcdi_id
         and prp.process_id = pc_process_id
         and prp.corporate_id = pc_corporate_id
         and prp.process = pc_process;
    end loop;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_physical_risk_position',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_update_strategy_attributes(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process      varchar2,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_update_strategy_attributes
    --        Author                                    : Siva
    --        Created Date                              : 01-Aug-2012
    --        Purpose                                   :
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : Trade Date
    --        pc_user_id                                : User ID
    --        pc_process                                : Process EOD or EOM
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_error_no        number := 0;
  
    cursor stg is
      select tt.corporate_startegy_id startegy_id,
             tt.strategy_name,
             max(case
                   when tt.order_seq = 1 then
                    tt.attribute_name
                   else
                    null
                 end) attribute_name_1,
             max(case
                   when tt.order_seq = 1 then
                    tt.attribute_value
                   else
                    null
                 end) attribute_value_1,
             ----------
             max(case
                   when tt.order_seq = 2 then
                    tt.attribute_name
                   else
                    null
                 end) attribute_name_2,
             max(case
                   when tt.order_seq = 2 then
                    tt.attribute_value
                   else
                    null
                 end) attribute_value_2,
             ---------
             max(case
                   when tt.order_seq = 3 then
                    tt.attribute_name
                   else
                    null
                 end) attribute_name_3,
             max(case
                   when tt.order_seq = 3 then
                    tt.attribute_value
                   else
                    null
                 end) attribute_value_3,
             ----
             max(case
                   when tt.order_seq = 4 then
                    tt.attribute_name
                   else
                    null
                 end) attribute_name_4,
             max(case
                   when tt.order_seq = 4 then
                    tt.attribute_value
                   else
                    null
                 end) attribute_value_4,
             max(case
                   when tt.order_seq = 5 then
                    tt.attribute_name
                   else
                    null
                 end) attribute_name_5,
             max(case
                   when tt.order_seq = 5 then
                    tt.attribute_value
                   else
                    null
                 end) attribute_value_5
        from (select eam.entity_value_id corporate_startegy_id,
                     css.strategy_name,
                     etm.entity_type_name,
                     adm.attribute_def_id,
                     adm.attribute_name,
                     avm.attribute_value,
                     nvl(avm.attribute_value_desc, avm.attribute_value) attribute_value_desc,
                     rank() over(partition by eam.entity_value_id order by adm.attribute_name asc) order_seq
                from eam_entity_attribute_mapping@eka_appdb eam,
                     etm_entity_type_master@eka_appdb       etm,
                     adm_attribute_def_master@eka_appdb     adm,
                     avm_attribute_value_master@eka_appdb   avm,
                     css_corporate_strategy_setup           css
               where upper(etm.entity_type_name) = 'STRATEGY'
                 and eam.attribute_value_id = avm.attribute_value_id
                 and eam.attribute_def_id = adm.attribute_def_id
                 and eam.entity_type_id = etm.entity_type_id
                 and eam.entity_value_id = css.strategy_id
                 and css.corporate_id = pc_corporate_id
                 and css.is_active = 'Y'
                 and css.is_deleted = 'N'
                 and eam.is_deleted = 'N') tt
       where tt.order_seq <= 5
       group by tt.corporate_startegy_id,
                tt.strategy_name;
  
  begin
    for stg_rwo in stg
    loop
      update eod_eom_booking_journal eod
         set eod.attribute_1 = stg_rwo.attribute_value_1,
             eod.attribute_2 = stg_rwo.attribute_value_2,
             eod.attribute_3 = stg_rwo.attribute_value_3,
             eod.attribute_4 = stg_rwo.attribute_value_4,
             eod.attribute_5 = stg_rwo.attribute_value_5,
             eod.strategy_name = stg_rwo.strategy_name
       where eod.corporate_id = pc_corporate_id
         and eod.process_id = pc_process_id
         and eod.strategy_id = stg_rwo.startegy_id;
      commit;
      update eod_eom_derivative_journal eod
         set eod.attribute_1 = stg_rwo.attribute_value_1,
             eod.attribute_2 = stg_rwo.attribute_value_2,
             eod.attribute_3 = stg_rwo.attribute_value_3,
             eod.attribute_4 = stg_rwo.attribute_value_4,
             eod.attribute_5 = stg_rwo.attribute_value_5
       where eod.corporate_id = pc_corporate_id
         and eod.process_id = pc_process_id
         and eod.strategy_id = stg_rwo.startegy_id;
      commit;
      update eod_eom_fixation_journal eod
         set eod.attribute_1 = stg_rwo.attribute_value_1,
             eod.attribute_2 = stg_rwo.attribute_value_2,
             eod.attribute_3 = stg_rwo.attribute_value_3,
             eod.attribute_4 = stg_rwo.attribute_value_4,
             eod.attribute_5 = stg_rwo.attribute_value_5
       where eod.corporate_id = pc_corporate_id
         and eod.process_id = pc_process_id
         and eod.strategy_id = stg_rwo.startegy_id;
      commit;
      update eod_eom_phy_contract_journal eod
         set eod.attribute_1 = stg_rwo.attribute_value_1,
             eod.attribute_2 = stg_rwo.attribute_value_2,
             eod.attribute_3 = stg_rwo.attribute_value_3,
             eod.attribute_4 = stg_rwo.attribute_value_4,
             eod.attribute_5 = stg_rwo.attribute_value_5
       where eod.corporate_id = pc_corporate_id
         and eod.process_id = pc_process_id
         and eod.strategy_id = stg_rwo.startegy_id;
      commit;
       update bdp_bi_dertivative_pnl bdp
         set bdp.attribute_1 = stg_rwo.attribute_value_1,
             bdp.attribute_2 = stg_rwo.attribute_value_2,
             bdp.attribute_3 = stg_rwo.attribute_value_3,
             bdp.attribute_4 = stg_rwo.attribute_value_4,
             bdp.attribute_5 = stg_rwo.attribute_value_5
       where bdp.corporate_id = pc_corporate_id
         and bdp.process_id = pc_process_id
         and bdp.strategy_id = stg_rwo.startegy_id;
      commit;      
    end loop;
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_update_strategy_attributes',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm ||
                                                           vn_error_no,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_contract_market_price(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_process      varchar2,
                                     pc_process_id   varchar2,
                                     pc_user_id      varchar2) as
  
    cursor cur_mar_price is
      select pcdi.pcdi_id,
             pocd.pcbpd_id,
             pcm.contract_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             div.price_source_id,
             ps.price_source_name,
             div.available_price_id,
             apm.available_price_name,
             div.price_unit_id,
             pum.price_unit_name,
          --   ppfh.price_unit_id ppu_price_unit_id,
             ppu.product_price_unit_id ppu_price_unit_id,
             dim.delivery_calender_id
      
        from pcm_physical_contract_main     pcm,
             pcdi_pc_delivery_item          pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd,
             dim_der_instrument_master      dim,
             div_der_instrument_valuation   div,
             ps_price_source                ps,
             apm_available_price_master     apm,
             pum_price_unit_master          pum,
             pdd_product_derivative_def     pdd,
             v_ppu_pum                      ppu
      
       where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcm.process_id = pc_process_id
         and pcm.contract_status = 'In Position'
         and pcdi.pcdi_id = poch.pcdi_id
         and pcdi.is_active = 'Y'
         and poch.poch_id = pocd.poch_id
         and pocd.price_type <> 'Fixed'
         and poch.is_active = 'Y'
         and pcdi.process_id = pc_process_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.is_active = 'Y'
         and pcbpd.process_id = pc_process_id
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.is_active = 'Y'
         and ppfh.process_id = pc_process_id
         and ppfh.ppfh_id = ppfd.ppfh_id
         and ppfd.is_active = 'Y'
         and ppfd.process_id = pc_process_id
         and ppfd.instrument_id = dim.instrument_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.product_derivative_id=pdd.derivative_def_id
         and div.price_unit_id=ppu.price_unit_id
         and pdd.product_id=ppu.product_id
       group by pcdi.pcdi_id,
                pocd.pcbpd_id,
                pcm.contract_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                div.price_source_id,
                ps.price_source_name,
                div.available_price_id,
                apm.available_price_name,
                div.price_unit_id,
                pum.price_unit_name,
                ppu.product_price_unit_id,
                dim.delivery_calender_id;
  
    vn_price            number;
    vc_price_unit_id    varchar2(15);
    vd_3rd_wed_of_qp    date;
    vc_price_dr_id      varchar2(15);
    vobj_error_log      tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count  number := 1;
    vd_valid_quote_date date;
    vd_qp_start_date    date;
    vd_qp_end_date      date;
    vd_quotes_date      date;
    workings_days       number;
  
  begin
    for cur_mar_price_rows in cur_mar_price
    loop
    
      for cc1 in (select pocd.qp_period_type,
                         pofh.qp_start_date,
                         pofh.qp_end_date,
                         pocd.final_price_unit_id,
                         pofh.finalize_date,
                         nvl(pofh.final_price_in_pricing_cur, 0) final_price
                    from poch_price_opt_call_off_header poch,
                         pocd_price_option_calloff_dtls pocd,
                         (select *
                            from pofh_price_opt_fixation_header pfh
                           where pfh.internal_gmr_ref_no is null
                             and pfh.is_active = 'Y') pofh
                   where poch.poch_id = pocd.poch_id
                     and pocd.pocd_id = pofh.pocd_id(+)
                     and poch.is_active = 'Y'
                     and pocd.is_active = 'Y'
                        -- and pofh.is_active(+) = 'Y'
                     and poch.pcdi_id = cur_mar_price_rows.pcdi_id)
      loop
      
        if cc1.qp_period_type = 'Period' then
          vd_qp_start_date := cc1.qp_start_date;
          vd_qp_end_date   := cc1.qp_end_date;
        elsif cc1.qp_period_type = 'Month' then
          vd_qp_start_date := cc1.qp_start_date;
          vd_qp_end_date   := cc1.qp_end_date;
        elsif cc1.qp_period_type = 'Date' then
          vd_qp_start_date := cc1.qp_start_date;
          vd_qp_end_date   := cc1.qp_end_date;
        elsif cc1.qp_period_type = 'Event' then
          begin
            select dieqp.expected_qp_start_date,
                   dieqp.expected_qp_end_date
              into vd_qp_start_date,
                   vd_qp_end_date
              from di_del_item_exp_qp_details dieqp
             where dieqp.pcdi_id = cur_mar_price_rows.pcdi_id
               and dieqp.pcbpd_id = cur_mar_price_rows.pcbpd_id
               and dieqp.is_active = 'Y';
          exception
            when no_data_found then
              vd_qp_start_date := cc1.qp_start_date;
              vd_qp_end_date   := cc1.qp_end_date;
            when others then
              vd_qp_start_date := cc1.qp_start_date;
              vd_qp_end_date   := cc1.qp_end_date;
          end;
        else
          vd_qp_start_date := cc1.qp_start_date;
          vd_qp_end_date   := cc1.qp_end_date;
        end if;
        
          vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                                'Wed',
                                                                3);
          while true
          loop
            if pkg_metals_general.f_is_day_holiday(cur_mar_price_rows.instrument_id,
                                                   vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
          --- get 3rd wednesday  before QP period 
          -- Get the quotation date = Trade Date +2 working Days
          if vd_3rd_wed_of_qp <= pd_trade_date then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if pkg_metals_general.f_is_day_holiday(cur_mar_price_rows.instrument_id,
                                                     vd_quotes_date) then
                vd_quotes_date := vd_quotes_date + 1;
              else
                workings_days := workings_days + 1;
                if workings_days <> 2 then
                  vd_quotes_date := vd_quotes_date + 1;
                end if;
              end if;
            end loop;
            vd_3rd_wed_of_qp := vd_quotes_date;
          end if;
           -- Added Suresh for NPD
         if pkg_cdc_pre_check_process.fn_is_npd(pc_corporate_id,
                                                 cur_mar_price_rows.delivery_calender_id,
                                                 vd_3rd_wed_of_qp)=true then
         
         vd_3rd_wed_of_qp:= pkg_cdc_pre_check_process.fn_get_npd_substitute_day(pc_corporate_id,
                                                    cur_mar_price_rows.delivery_calender_id,
                                                    vd_3rd_wed_of_qp);
          end if;
          --end
        
          ---- get the dr_id             
          begin
            select drm.dr_id
              into vc_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_mar_price_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              if vd_3rd_wed_of_qp is not null then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure sp_contract_market_price',
                                                                     'PHY-002',
                                                                     'DR_ID missing for ' ||
                                                                     cur_mar_price_rows.instrument_name ||
                                                                     ',Price Source:' ||
                                                                     cur_mar_price_rows.price_source_name ||
                                                                     ' Contract Ref No: ' ||
                                                                     cur_mar_price_rows.contract_ref_no ||
                                                                     ',Price Unit:' ||
                                                                     cur_mar_price_rows.price_unit_name || ',' ||
                                                                     cur_mar_price_rows.available_price_name ||
                                                                     ' Price,Prompt Date:' ||
                                                                     vd_3rd_wed_of_qp,
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              end if;
          end;
        
          --get the price              
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_price,
                   vc_price_unit_id
              from dq_derivative_quotes        dq,
                   dqd_derivative_quote_detail dqd,
                   cdim_corporate_dim          cdim
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_price_dr_id
               and dq.process_id = pc_process_id
               and dq.instrument_id = cur_mar_price_rows.instrument_id
               and dq.process_id = dqd.process_id
               and dqd.available_price_id =
                   cur_mar_price_rows.available_price_id
               and dq.price_source_id = cur_mar_price_rows.price_source_id
               and dqd.price_unit_id = cur_mar_price_rows.price_unit_id
               and dq.trade_date = cdim.valid_quote_date
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and rownum <= 1
               and cdim.corporate_id = pc_corporate_id
               and cdim.instrument_id = dq.instrument_id;
          exception
            when no_data_found then
              select cdim.valid_quote_date
                into vd_valid_quote_date
                from cdim_corporate_dim cdim
               where cdim.corporate_id = pc_corporate_id
                 and cdim.instrument_id = cur_mar_price_rows.instrument_id;
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id, --
                                                                   'procedure sp_contract_market_price',
                                                                   'PHY-002', --
                                                                   'Price missing for ' ||
                                                                   cur_mar_price_rows.instrument_name ||
                                                                   ',Price Source:' ||
                                                                   cur_mar_price_rows.price_source_name || --
                                                                   ' Contract Ref No: ' ||
                                                                   cur_mar_price_rows.contract_ref_no ||
                                                                   ',Price Unit:' ||
                                                                   cur_mar_price_rows.price_unit_name || ',' ||
                                                                   cur_mar_price_rows.available_price_name ||
                                                                   ' Price,Prompt Date:' ||
                                                                   vd_3rd_wed_of_qp ||
                                                                   ' Trade Date :' ||
                                                                   vd_valid_quote_date,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            
          end;
          vc_price_unit_id := cur_mar_price_rows.ppu_price_unit_id;
        
      
        insert into cmp_contract_market_price
          (process_id,
           contract_ref_no,
           pcdi_id,
           qp_start_date,
           qp_end_date,
           price,
           price_unit_id)
        values
          (pc_process_id,
           cur_mar_price_rows.contract_ref_no,
           cur_mar_price_rows.pcdi_id,
           vd_qp_start_date,
           vd_qp_end_date,
           vn_price,
           vc_price_unit_id);
        commit;
      end loop;
    end loop;
  end;
  procedure sp_gmr_market_price(pc_corporate_id varchar2,
                                pd_trade_date   date,
                                pc_process      varchar2,
                                pc_process_id   varchar2,
                                pc_user_id      varchar2) as
    cursor cur_mar_gmr_price is
      select gmr.gmr_ref_no,
             poch.pcdi_id,
             pofh.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pofh.qp_start_date,
             pofh.qp_end_date,
             nvl(pofh.final_price_in_pricing_cur, 0) final_price,
             pocd.final_price_unit_id,
             div.price_source_id,
             ps.price_source_name,
             div.available_price_id,
             apm.available_price_name,
             div.price_unit_id,
             pum.price_unit_name,
          --   ppfh.price_unit_id ppu_price_unit_id
             ppu.product_price_unit_id ppu_price_unit_id,
             dim.delivery_calender_id
      
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             poch_price_opt_call_off_header poch,
             pcbpd_pc_base_price_detail     pcbpd,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd,
             dim_der_instrument_master      dim,
             div_der_instrument_valuation   div,
             ps_price_source                ps,
             apm_available_price_master     apm,
             pum_price_unit_master          pum,
             gmr_goods_movement_record      gmr,
             pdd_product_derivative_def     pdd,
             v_ppu_pum                      ppu
      
       where pofh.pocd_id = pocd.pocd_id
         and pocd.poch_id = poch.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.ppfh_id = ppfd.ppfh_id
         and pcbpd.process_id = ppfh.process_id
         and ppfh.process_id = ppfd.process_id
         and ppfd.instrument_id = dim.instrument_id
         and pcbpd.process_id = pc_process_id
         and ppfh.process_id = pc_process_id
         and ppfd.process_id = pc_process_id
         and pofh.internal_gmr_ref_no is not null
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and ppfh.is_active = 'Y'
         and ppfd.is_active = 'Y'
         and poch.is_active = 'Y'
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and gmr.is_deleted = 'N'
         and dim.product_derivative_id=pdd.derivative_def_id
         and div.price_unit_id=ppu.price_unit_id
         and pdd.product_id=ppu.product_id
       group by gmr.gmr_ref_no,
                poch.pcdi_id,
                pofh.internal_gmr_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                pofh.qp_start_date,
                pofh.qp_end_date,
                nvl(pofh.final_price_in_pricing_cur, 0),
                pocd.final_price_unit_id,
                div.price_source_id,
                ps.price_source_name,
                div.available_price_id,
                apm.available_price_name,
                div.price_unit_id,
                pum.price_unit_name,
                ppu.product_price_unit_id,
                dim.delivery_calender_id;
    vn_price            number;
    vc_price_unit_id    varchar2(15);
    vd_3rd_wed_of_qp    date;
    workings_days       number;
    vd_quotes_date      date;
    vc_price_dr_id      varchar2(15);
    vobj_error_log      tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count  number := 1;
    vd_valid_quote_date date;
  begin
    for cur_mar_gmr_price_rows in cur_mar_gmr_price
    loop     
        vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(cur_mar_gmr_price_rows.qp_end_date,
                                                              'Wed',
                                                              3);
        while true
        loop
          if pkg_metals_general.f_is_day_holiday(cur_mar_gmr_price_rows.instrument_id,
                                                 vd_3rd_wed_of_qp) then
            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
          else
            exit;
          end if;
        end loop;
        --- get 3rd wednesday  before QP period 
        -- Get the quotation date = Trade Date +2 working Days
        if vd_3rd_wed_of_qp <= pd_trade_date then
          workings_days  := 0;
          vd_quotes_date := pd_trade_date + 1;
          while workings_days <> 2
          loop
            if pkg_metals_general.f_is_day_holiday(cur_mar_gmr_price_rows.instrument_id,
                                                   vd_quotes_date) then
              vd_quotes_date := vd_quotes_date + 1;
            else
              workings_days := workings_days + 1;
              if workings_days <> 2 then
                vd_quotes_date := vd_quotes_date + 1;
              end if;
            end if;
          end loop;
          vd_3rd_wed_of_qp := vd_quotes_date;
        end if;
          -- Added Suresh for NPD
         if pkg_cdc_pre_check_process.fn_is_npd(pc_corporate_id,
                                                 cur_mar_gmr_price_rows.delivery_calender_id,
                                                 vd_3rd_wed_of_qp)=true then
         
         vd_3rd_wed_of_qp:= pkg_cdc_pre_check_process.fn_get_npd_substitute_day(pc_corporate_id,
                                                    cur_mar_gmr_price_rows.delivery_calender_id,
                                                    vd_3rd_wed_of_qp);
          end if;
          --end
      
        ---- get the dr_id             
        begin
          select drm.dr_id
            into vc_price_dr_id
            from drm_derivative_master drm
           where drm.instrument_id = cur_mar_gmr_price_rows.instrument_id
             and drm.prompt_date = vd_3rd_wed_of_qp
             and rownum <= 1
             and drm.price_point_id is null
             and drm.is_deleted = 'N';
        exception
          when no_data_found then
            if vd_3rd_wed_of_qp is not null then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure sp_gmr_market_price',
                                                                   'PHY-002',
                                                                   'DR_ID missing for ' ||
                                                                   cur_mar_gmr_price_rows.instrument_name ||
                                                                   ',Price Source:' ||
                                                                   cur_mar_gmr_price_rows.price_source_name ||
                                                                   ' Contract Ref No: ' ||
                                                                   cur_mar_gmr_price_rows.gmr_ref_no ||
                                                                   ',Price Unit:' ||
                                                                   cur_mar_gmr_price_rows.price_unit_name || ',' ||
                                                                   cur_mar_gmr_price_rows.available_price_name ||
                                                                   ' Price,Prompt Date:' ||
                                                                   vd_3rd_wed_of_qp,
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            end if;
        end;
      
        --get the price              
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_price,
                 vc_price_unit_id
            from dq_derivative_quotes        dq,
                 dqd_derivative_quote_detail dqd,
                 cdim_corporate_dim          cdim
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_price_dr_id
             and dq.process_id = pc_process_id
             and dq.instrument_id = cur_mar_gmr_price_rows.instrument_id
             and dq.process_id = dqd.process_id
             and dqd.available_price_id =
                 cur_mar_gmr_price_rows.available_price_id
             and dq.price_source_id =
                 cur_mar_gmr_price_rows.price_source_id
             and dqd.price_unit_id = cur_mar_gmr_price_rows.price_unit_id
             and dq.trade_date = cdim.valid_quote_date
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N'
             and rownum <= 1
             and cdim.corporate_id = pc_corporate_id
             and cdim.instrument_id = dq.instrument_id;
        exception
          when no_data_found then
            select cdim.valid_quote_date
              into vd_valid_quote_date
              from cdim_corporate_dim cdim
             where cdim.corporate_id = pc_corporate_id
               and cdim.instrument_id =
                   cur_mar_gmr_price_rows.instrument_id;
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id, --
                                                                 'procedure sp_gmr_market_price',
                                                                 'PHY-002', --
                                                                 'Price missing for ' ||
                                                                 cur_mar_gmr_price_rows.instrument_name ||
                                                                 ',Price Source:' ||
                                                                 cur_mar_gmr_price_rows.price_source_name || --
                                                                 ' GMR Ref No: ' ||
                                                                 cur_mar_gmr_price_rows.gmr_ref_no ||
                                                                 ',Price Unit:' ||
                                                                 cur_mar_gmr_price_rows.price_unit_name || ',' ||
                                                                 cur_mar_gmr_price_rows.available_price_name ||
                                                                 ' Price,Prompt Date:' ||
                                                                 vd_3rd_wed_of_qp ||
                                                                 ' Trade Date :' ||
                                                                 vd_valid_quote_date,
                                                                 '',
                                                                 pc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
          
        end;
        vc_price_unit_id := cur_mar_gmr_price_rows.ppu_price_unit_id;
   
      insert into gmp_gmr_market_price
        (process_id,
         internal_gmr_ref_no,
         pcdi_id,
         qp_start_date,
         qp_end_date,
         price,
         price_unit_id)
      values
        (pc_process_id,
         cur_mar_gmr_price_rows.internal_gmr_ref_no,
         cur_mar_gmr_price_rows.pcdi_id,
         cur_mar_gmr_price_rows.qp_start_date,
         cur_mar_gmr_price_rows.qp_end_date,
         vn_price,
         vc_price_unit_id);
      commit;
    
    end loop;
  end;

  procedure sp_trader_position_report(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_process      varchar2,
                                      pc_process_id   varchar2,
                                      pc_user_id      varchar2) as
    --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_trader_position_report
    --        Author                                    : Siva
    --        Created Date                              : 10-Nov-2012
    --        Purpose                                   :
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : Trade Date
    --        pc_user_id                                : User ID
    --        pc_process                                : Process EOD or EOM
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    i                  integer;
    --  vn_conv_factor              number;
    vn_total_amount             number(30, 5);
    vn_total_amount_in_base_ccy number(30, 5);
    vn_total_market_price       number(25, 5);
    vn_total_di_price           number(25, 5);
    vn_exchnage_rate            number;
    vn_logno                    number;
  
  begin
    i        := 0;
    vn_logno := 200;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR - insert temp_tpr for basmetal started');
    delete from temp_tpr where corporate_id = pc_corporate_id;
    commit;
    -- Variable contracts
    insert into temp_tpr
      (corporate_id,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select pcm.corporate_id,
             'Physical Total' section_name,
             '13' section_id,
             pcpd.product_id,
             pdm.product_desc,
             pcpd.profit_center_id,
             cpc.profit_center_short_name,
             cpc.profit_center_name,
             trunc(pcdi.shipment_date, 'Mon') delivery_date,
             to_char(pcdi.shipment_date, 'Mon-YYYY') delivery_month,
             sum((case
                   when pcm.purchase_sales = 'P' then
                    1
                   else
                    -1
                 end) * ucm.multiplication_factor * diqs.price_fixed_qty) qty,
             qum_base.qty_unit_id,
             qum_base.qty_unit,
             null strategy_id,
             'Physical Total' strategy_name,
             nvl(pcm.approval_status, 'Approved') approval_status
        from pcm_physical_contract_main    pcm,
             pcdi_pc_delivery_item         pcdi,
             diqs_delivery_item_qty_status diqs,
             pcpd_pc_product_definition    pcpd,
             pdm_productmaster             pdm,
             qum_quantity_unit_master      qum_base,
             cpc_corporate_profit_center   cpc,
             qum_quantity_unit_master      qum,
             ucm_unit_conversion_master    ucm
       where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcdi.pcdi_id = diqs.pcdi_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.input_output = 'Input'
         and pcpd.process_id = pc_process_id
         and pcpd.product_id = pdm.product_id
         and pcpd.profit_center_id = cpc.profit_center_id
         and diqs.item_qty_unit_id = qum.qty_unit_id
         and pdm.base_quantity_unit = qum_base.qty_unit_id
         and pcm.contract_type = 'BASEMETAL'
         and ucm.from_qty_unit_id = qum.qty_unit_id
         and ucm.to_qty_unit_id = qum_base.qty_unit_id
         and nvl(pcm.contract_status, 'NA') <> 'Cancelled'
         and pcdi.item_price_type<>'Fixed'
         and pcm.corporate_id = pc_corporate_id
         and round(nvl(diqs.price_fixed_qty, 0), 4) <> 0-- diqs.total_qty -----added that only fully priced contract should come 05-Sep-2012
         -- above changes modified, as per the request from manish once price fixed qty has to be consider, it's not necessory full qty has to be fixed
         -- changes done as on 16-jul-2013, bug id:80551
         and pcm.is_active = 'Y'
         and pcdi.shipment_date is not null
         and pcdi.shipment_date >= pd_trade_date
       group by pcm.corporate_id,
                pcpd.product_id,
                pdm.product_desc,
                pcpd.profit_center_id,
                cpc.profit_center_short_name,
                cpc.profit_center_name,
                trunc(pcdi.shipment_date, 'Mon'),
                to_char(pcdi.shipment_date, 'Mon-YYYY'),
                qum_base.qty_unit_id,
                qum_base.qty_unit,
                nvl(pcm.approval_status, 'Approved');
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR - insert temp_tpr for conent started');
     ---- fixed contracts
     insert into temp_tpr
      (corporate_id,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select pcm.corporate_id,
             'Physical Total' section_name,
             '13' section_id,
             pcpd.product_id,
             pdm.product_desc,
             pcpd.profit_center_id,
             cpc.profit_center_short_name,
             cpc.profit_center_name,
             trunc(pcdi.shipment_date, 'Mon') delivery_date,
             to_char(pcdi.shipment_date, 'Mon-YYYY') delivery_month,
             sum((case
                   when pcm.purchase_sales = 'P' then
                    1
                   else
                    -1
                 end) * ucm.multiplication_factor * diqs.total_qty) qty,
             qum_base.qty_unit_id,
             qum_base.qty_unit,
             null strategy_id,
             'Physical Total' strategy_name,
             nvl(pcm.approval_status, 'Approved') approval_status
        from pcm_physical_contract_main    pcm,
             pcdi_pc_delivery_item         pcdi,
             diqs_delivery_item_qty_status diqs,
             pcpd_pc_product_definition    pcpd,
             pdm_productmaster             pdm,
             qum_quantity_unit_master      qum_base,
             cpc_corporate_profit_center   cpc,
             qum_quantity_unit_master      qum,
             ucm_unit_conversion_master    ucm
       where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcdi.pcdi_id = diqs.pcdi_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.input_output = 'Input'
         and pcpd.process_id = pc_process_id
         and pcpd.product_id = pdm.product_id
         and pcpd.profit_center_id = cpc.profit_center_id
         and diqs.item_qty_unit_id = qum.qty_unit_id
         and pdm.base_quantity_unit = qum_base.qty_unit_id
         and pcm.contract_type = 'BASEMETAL'
         and ucm.from_qty_unit_id = qum.qty_unit_id
         and ucm.to_qty_unit_id = qum_base.qty_unit_id
         and nvl(pcm.contract_status, 'NA') <> 'Cancelled'
         and pcdi.item_price_type='Fixed'
         and pcm.corporate_id = pc_corporate_id         
         and pcm.is_active = 'Y'
         and pcdi.shipment_date is not null
         and pcdi.shipment_date >= pd_trade_date
       group by pcm.corporate_id,
                pcpd.product_id,
                pdm.product_desc,
                pcpd.profit_center_id,
                cpc.profit_center_short_name,
                cpc.profit_center_name,
                trunc(pcdi.shipment_date, 'Mon'),
                to_char(pcdi.shipment_date, 'Mon-YYYY'),
                qum_base.qty_unit_id,
                qum_base.qty_unit,
                nvl(pcm.approval_status, 'Approved');
    commit;                     
                          
                          
    insert into temp_tpr
      (corporate_id,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select pcm.corporate_id,
             'Physical Total' section_name,
             '13' section_id,
             pcpd.product_id,
             pdm.product_desc,
             pcpd.profit_center_id,
             cpc.profit_center_short_name,
             cpc.profit_center_name,
             trunc(pcdi.shipment_date, 'Mon') delivery_date,
             to_char(pcdi.shipment_date, 'Mon-YYYY') delivery_month,
             sum((case
                   when pcm.purchase_sales = 'P' then
                    1
                   else
                    -1
                 end) * ucm.multiplication_factor * round(pofh.priced_qty, 4)) qty,
             qum_base.qty_unit_id,
             qum_base.qty_unit,
             null strategy_id,
             'Physical Total' strategy_name,
             nvl(pcm.approval_status, 'Approved') approval_status
        from pcm_physical_contract_main     pcm,
             pcdi_pc_delivery_item          pcdi,
             pofh_history                   pofh,
             pci_physical_contract_item     pci,
             cipq_contract_item_payable_qty cipq,
             aml_attribute_master_list      aml,
             pcpd_pc_product_definition     pcpd,
             pdm_productmaster              pdm,
             cpc_corporate_profit_center    cpc,
             qum_quantity_unit_master       qum_base,
             ucm_unit_conversion_master     ucm
       where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pci.pcdi_id = pcdi.pcdi_id
         and cipq.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and cipq.element_id = aml.attribute_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and cipq.process_id = pc_process_id
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.input_output = 'Input'
         and pcpd.process_id = pc_process_id
         and aml.underlying_product_id = pdm.product_id
         and pcpd.profit_center_id = cpc.profit_center_id
         and pdm.base_quantity_unit = qum_base.qty_unit_id
         and ucm.from_qty_unit_id = cipq.qty_unit_id
         and ucm.to_qty_unit_id = pdm.base_quantity_unit
         and pofh.pcdi_id = pcdi.pcdi_id
         and pofh.process_id = pcdi.process_id
       --  and round(pofh.qty_to_be_fixed, 4) = round(pofh.priced_qty, 4) -----added that only fully priced contract should come 05-Sep-2012
       -- above check removed for the bug id:80551
         and round(pofh.priced_qty, 4) <> 0
         and pcm.contract_type = 'CONCENTRATES'
         and pcm.corporate_id = pc_corporate_id
         and cipq.qty_type = 'Payable'
         and nvl(pcm.contract_status, 'NA') <> 'Cancelled'
         and pcdi.shipment_date >= pd_trade_date
         and pcdi.shipment_date is not null
         and pcm.is_active = 'Y'
         and pcdi.is_active = 'Y'
       group by pcm.corporate_id,
                pcpd.product_id,
                pdm.product_desc,
                pcpd.profit_center_id,
                cpc.profit_center_short_name,
                cpc.profit_center_name,
                trunc(pcdi.shipment_date, 'Mon'),
                to_char(pcdi.shipment_date, 'Mon-YYYY'),
                qum_base.qty_unit_id,
                qum_base.qty_unit,
                nvl(pcm.approval_status, 'Approved');
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR - insert temp_tpr for futures/forwards started');
    insert into temp_tpr
      (corporate_id,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select dpd.corporate_id,
             'Derivative' section_name,
             '1' section_id,
             dpd.derivative_prodct_id,
             dpd.derivative_prodct_name,
             dpd.profit_center_id,
             dpd.profit_center_short_name,
             dpd.profit_center_name,
             trunc(dpd.prompt_date, 'Mon') delivery_date,
             to_char(dpd.prompt_date, 'Mon-YYYY') delivery_month,
             sum(dpd.open_quantity * ucm.multiplication_factor *
                 dpd.qty_sign) qty,
             dpd.base_qty_unit_id,
             dpd.base_qty_unit,
             'Strategy' strategy_id,
             dpd.strategy_name,
             'Approved' approval_status
        from dpd_derivative_pnl_daily   dpd,
             ucm_unit_conversion_master ucm
       where dpd.process_id = pc_process_id
         and ucm.from_qty_unit_id = dpd.quantity_unit_id
         and ucm.to_qty_unit_id = dpd.base_qty_unit_id
         and dpd.corporate_id = pc_corporate_id
         and dpd.instrument_type in ('Future', 'Forward')
         and dpd.pnl_type = 'Unrealized'
         and dpd.prompt_date > pd_trade_date
       group by dpd.corporate_id,
                dpd.derivative_prodct_id,
                dpd.derivative_prodct_name,
                dpd.profit_center_id,
                dpd.profit_center_short_name,
                dpd.profit_center_name,
                trunc(dpd.prompt_date, 'Mon'),
                to_char(dpd.prompt_date, 'Mon-YYYY'),
                dpd.base_qty_unit_id,
                dpd.base_qty_unit,
                dpd.strategy_name;
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR - insert temp_tpr for option (buy call) trades started');
 -- as per the latests FS  Chnaged options logic                         
    insert into temp_tpr
      (corporate_id,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select dpd.corporate_id,
             'Options' section_name,
             '15' section_id,
             dpd.derivative_prodct_id,
             dpd.derivative_prodct_name,
             dpd.profit_center_id,
             dpd.profit_center_short_name,
             dpd.profit_center_name,
             trunc(dpd.option_expiry_date, 'Mon') delivery_date,
             to_char(dpd.option_expiry_date, 'Mon-YYYY') delivery_month,
            (case when dpd.in_out_at_money_status='Out of the Money' then
             0
             else
             sum(dpd.open_quantity * ucm.multiplication_factor *
                 dpd.qty_sign)
             end) qty,
             dpd.base_qty_unit_id,
             dpd.base_qty_unit,
             null strategy_id,
             'Options' strategy_name,
             'Approved' approval_status
        from dpd_derivative_pnl_daily   dpd,
             ucm_unit_conversion_master ucm
       where dpd.process_id = pc_process_id
         and ucm.from_qty_unit_id = dpd.quantity_unit_id
         and ucm.to_qty_unit_id = dpd.base_qty_unit_id
         and dpd.corporate_id = pc_corporate_id
         and dpd.instrument_type in ('Option Call', 'OTC Call Option','Option Put', 'OTC Put Option')
         and dpd.pnl_type = 'Unrealized'
         and nvl(dpd.in_out_at_money_status, 'NA') in
             ('At the Money', 'In the Money','Out of the Money')
         and dpd.option_expiry_date > pd_trade_date
         and dpd.option_expiry_date is not null
       group by dpd.corporate_id,
                dpd.derivative_prodct_id,
                dpd.derivative_prodct_name,
                dpd.profit_center_id,
                dpd.profit_center_short_name,
                dpd.profit_center_name,
                trunc(dpd.option_expiry_date, 'Mon'),
                to_char(dpd.option_expiry_date, 'Mon-YYYY'),
                dpd.base_qty_unit_id,
                dpd.base_qty_unit,
                dpd.in_out_at_money_status;
    commit;    
    
    -- variable contracts                      
    
insert into temp_tpr
  (corporate_id,
   section_name,
   section_id,
   product_id,
   product_desc,
   profit_center_id,
   profit_center_short_name,
   profit_center_name,
   delivery_date,
   delivery_month_display,
   quantity,
   quantity_unit_id,
   quantity_unit,
   strategy_id,
   strategy_name,
   approval_status)
  select t.corporate_id,
         t.section_name,
         t.section_id,
         t.product_id,
         t.product_desc,
         t.profit_center_id,
         t.profit_center_short_name,
         t.profit_center_name,
         t.delivery_date,
         t.delivery_month,
         sum(t.priced_arrived_qty + t.price_not_arrived_qty +
             t.priced_delivered_qty + t.price_not_delivered_qty),
         t.qty_unit_id,
         t.qty_unit,
         t.strategy_id,
         t.strategy_name,
         t.approval_status
    from (select pcm.corporate_id,
                 'Physical Total' section_name,
                 '13' section_id,
                 pcpd.product_id,
                 pdm.product_desc,
                 pcpd.profit_center_id,
                 cpc.profit_center_short_name,
                 cpc.profit_center_name,
                 trunc(to_date('01-' || 'Jan-1900'), 'Mon') delivery_date,
                 'Opening Balance' delivery_month,
                /* sum(ucm.multiplication_factor *
                 round(least(diqs.gmr_qty, diqs.price_fixed_qty), 4)) qty,*/
                 sum(ucm.multiplication_factor*case
                       when nvl(diqs.gmr_qty, 0) < nvl(diqs.price_fixed_qty, 0) then
                        nvl(diqs.gmr_qty, 0)
                       else
                        nvl(diqs.price_fixed_qty, 0)
                     end)  priced_arrived_qty,
                 
                 sum(ucm.multiplication_factor*(nvl(diqs.price_fixed_qty, 0) -
                     (case
                        when nvl(diqs.gmr_qty, 0) < nvl(diqs.price_fixed_qty, 0) then
                         nvl(diqs.gmr_qty, 0)
                        else
                         nvl(diqs.price_fixed_qty, 0)
                      end)))  price_not_arrived_qty,
                 0 priced_delivered_qty,
                 0 price_not_delivered_qty,
                 qum_base.qty_unit_id,
                 qum_base.qty_unit,
                 null strategy_id,
                 'Physical Total' strategy_name,
                 nvl(pcm.approval_status, 'Approved') approval_status
            from pcm_physical_contract_main    pcm,
                 pcdi_pc_delivery_item         pcdi,
                 diqs_delivery_item_qty_status diqs,
                 pcpd_pc_product_definition    pcpd,
                 pdm_productmaster             pdm,
                 qum_quantity_unit_master      qum_base,
                 cpc_corporate_profit_center   cpc,
                 qum_quantity_unit_master      qum,
                 ucm_unit_conversion_master    ucm
           where pcdi.internal_contract_ref_no =
                 pcm.internal_contract_ref_no
             and pcdi.pcdi_id = diqs.pcdi_id
             and pcm.process_id = pc_process_id
             and pcdi.process_id = pc_process_id
             and diqs.process_id = pc_process_id
             and pcm.internal_contract_ref_no =
                 pcpd.internal_contract_ref_no
             and pcpd.input_output = 'Input'
             and pcpd.process_id = pc_process_id
             and pcpd.product_id = pdm.product_id
             and pcpd.profit_center_id = cpc.profit_center_id
             and diqs.item_qty_unit_id = qum.qty_unit_id
             and pdm.base_quantity_unit = qum_base.qty_unit_id
             and pcm.contract_type = 'BASEMETAL'
             and pcdi.item_price_type <> 'Fixed'
             and ucm.from_qty_unit_id = qum.qty_unit_id
             and ucm.to_qty_unit_id = qum_base.qty_unit_id
             and nvl(pcm.contract_status, 'NA') <> 'Cancelled'
             and pcm.purchase_sales = 'P'
             and pcm.corporate_id = pc_corporate_id
             and pcm.is_active = 'Y'
             and pcdi.shipment_date is not null
             and pcdi.shipment_date < pd_trade_date
           group by pcm.corporate_id,
                    pcpd.product_id,
                    pdm.product_desc,
                    pcpd.profit_center_id,
                    cpc.profit_center_short_name,
                    cpc.profit_center_name,
                    trunc(pcdi.shipment_date, 'Mon'),
                    to_char(pcdi.shipment_date, 'Mon-YYYY'),
                    qum_base.qty_unit_id,
                    qum_base.qty_unit,
                    nvl(pcm.approval_status, 'Approved')
          union all
          select pcm.corporate_id,
                 'Physical Total' section_name,
                 '13' section_id,
                 pcpd.product_id,
                 pdm.product_desc,
                 pcpd.profit_center_id,
                 cpc.profit_center_short_name,
                 cpc.profit_center_name,
                 trunc(to_date('01-' || 'Jan-1900'), 'Mon') delivery_date,
                 'Opening Balance' delivery_month,
                /*sum((case
                   when round(diqs.price_fixed_qty, 4) - diqs.gmr_qty > 0 then
                    round(diqs.price_fixed_qty, 4) - diqs.gmr_qty
                   else
                    0
                 end) * -1 * ucm.multiplication_factor) qty,*/                 
                 0 priced_arrived_qty,
                 0 price_not_arrived_qty,
                 sum(ucm.multiplication_factor*case
                       when nvl(diqs.gmr_qty, 0) < nvl(diqs.price_fixed_qty, 0) then
                        nvl(diqs.gmr_qty, 0)
                       else
                        nvl(diqs.price_fixed_qty, 0)
                     end)*-1 priced_delivered_qty,
                 
               sum(ucm.multiplication_factor*(nvl(diqs.price_fixed_qty, 0) -
                     (case
                        when nvl(diqs.gmr_qty, 0) < nvl(diqs.price_fixed_qty, 0) then
                         nvl(diqs.gmr_qty, 0)
                        else
                         nvl(diqs.price_fixed_qty, 0)
                      end))) *-1   priced_not_delivered_qty,                 
                 qum_base.qty_unit_id,
                 qum_base.qty_unit,
                 null strategy_id,
                 'Physical Total' strategy_name,
                 nvl(pcm.approval_status, 'Approved') approval_status
            from pcm_physical_contract_main    pcm,
                 pcdi_pc_delivery_item         pcdi,
                 diqs_delivery_item_qty_status diqs,
                 pcpd_pc_product_definition    pcpd,
                 pdm_productmaster             pdm,
                 qum_quantity_unit_master      qum_base,
                 cpc_corporate_profit_center   cpc,
                 qum_quantity_unit_master      qum,
                 ucm_unit_conversion_master    ucm
           where pcdi.internal_contract_ref_no =
                 pcm.internal_contract_ref_no
             and pcdi.pcdi_id = diqs.pcdi_id
             and pcm.process_id = pc_process_id
             and pcdi.process_id = pc_process_id
             and diqs.process_id = pc_process_id
             and pcm.internal_contract_ref_no =
                 pcpd.internal_contract_ref_no
             and pcpd.input_output = 'Input'
             and pcpd.process_id = pc_process_id
             and pcpd.product_id = pdm.product_id
             and pcpd.profit_center_id = cpc.profit_center_id
             and diqs.item_qty_unit_id = qum.qty_unit_id
             and pdm.base_quantity_unit = qum_base.qty_unit_id
             and pcm.contract_type = 'BASEMETAL'
             and pcdi.item_price_type <> 'Fixed'
             and ucm.from_qty_unit_id = qum.qty_unit_id
             and ucm.to_qty_unit_id = qum_base.qty_unit_id
             and nvl(pcm.contract_status, 'NA') <> 'Cancelled'
             and pcm.purchase_sales = 'S'
             and pcm.corporate_id = pc_corporate_id
             and pcm.is_active = 'Y'
             and pcdi.shipment_date is not null
             and pcdi.shipment_date < pd_trade_date
           group by pcm.corporate_id,
                    pcpd.product_id,
                    pdm.product_desc,
                    pcpd.profit_center_id,
                    cpc.profit_center_short_name,
                    cpc.profit_center_name,
                    trunc(pcdi.shipment_date, 'Mon'),
                    to_char(pcdi.shipment_date, 'Mon-YYYY'),
                    qum_base.qty_unit_id,
                    qum_base.qty_unit,
                    nvl(pcm.approval_status, 'Approved')) t
   group by t.corporate_id,
            t.section_name,
            t.section_id,
            t.product_id,
            t.product_desc,
            t.profit_center_id,
            t.profit_center_short_name,
            t.profit_center_name,
            t.delivery_date,
            t.delivery_month,
            t.qty_unit_id,
            t.qty_unit,
            t.strategy_id,
            t.strategy_name,
            t.approval_status;
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR - insert temp_tpr for dummy section started');
     -- fixed contracts
     insert into temp_tpr
      (corporate_id,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select pcm.corporate_id,
             'Physical Total' section_name,
             '13' section_id,
             pcpd.product_id,
             pdm.product_desc,
             pcpd.profit_center_id,
             cpc.profit_center_short_name,
             cpc.profit_center_name,
             trunc(to_date('01-' || 'Jan-1900'), 'Mon') delivery_date,
             'Opening Balance' delivery_month,
             sum(ucm.multiplication_factor *
                 round(least(diqs.gmr_qty, diqs.total_qty), 4)) qty,
             qum_base.qty_unit_id,
             qum_base.qty_unit,
             null strategy_id,
             'Physical Total' strategy_name,
             nvl(pcm.approval_status, 'Approved') approval_status
        from pcm_physical_contract_main    pcm,
             pcdi_pc_delivery_item         pcdi,
             diqs_delivery_item_qty_status diqs,
             pcpd_pc_product_definition    pcpd,
             pdm_productmaster             pdm,
             qum_quantity_unit_master      qum_base,
             cpc_corporate_profit_center   cpc,
             qum_quantity_unit_master      qum,
             ucm_unit_conversion_master    ucm
       where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcdi.pcdi_id = diqs.pcdi_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.input_output = 'Input'
         and pcpd.process_id = pc_process_id
         and pcpd.product_id = pdm.product_id
         and pcpd.profit_center_id = cpc.profit_center_id
         and diqs.item_qty_unit_id = qum.qty_unit_id
         and pdm.base_quantity_unit = qum_base.qty_unit_id
         and pcm.contract_type = 'BASEMETAL'
         and pcdi.item_price_type='Fixed'
         and ucm.from_qty_unit_id = qum.qty_unit_id
         and ucm.to_qty_unit_id = qum_base.qty_unit_id
         and nvl(pcm.contract_status, 'NA') <> 'Cancelled'
         and pcm.purchase_sales = 'P'
         and pcm.corporate_id = pc_corporate_id
         and pcm.is_active = 'Y'
         and pcdi.shipment_date is not null
         and pcdi.shipment_date < pd_trade_date
       group by pcm.corporate_id,
                pcpd.product_id,
                pdm.product_desc,
                pcpd.profit_center_id,
                cpc.profit_center_short_name,
                cpc.profit_center_name,
                trunc(pcdi.shipment_date, 'Mon'),
                to_char(pcdi.shipment_date, 'Mon-YYYY'),
                qum_base.qty_unit_id,
                qum_base.qty_unit,
                nvl(pcm.approval_status, 'Approved')
      union all
      select pcm.corporate_id,
             'Physical Total' section_name,
             '13' section_id,
             pcpd.product_id,
             pdm.product_desc,
             pcpd.profit_center_id,
             cpc.profit_center_short_name,
             cpc.profit_center_name,
             trunc(to_date('01-' || 'Jan-1900'), 'Mon') delivery_date,
             'Opening Balance' delivery_month,
             sum((case
                   when round(diqs.total_qty, 4) - diqs.gmr_qty > 0 then
                    round(diqs.total_qty, 4) - diqs.gmr_qty
                   else
                    0
                 end) * -1 * ucm.multiplication_factor) qty,
             qum_base.qty_unit_id,
             qum_base.qty_unit,
             null strategy_id,
             'Physical Total' strategy_name,
             nvl(pcm.approval_status, 'Approved') approval_status
        from pcm_physical_contract_main    pcm,
             pcdi_pc_delivery_item         pcdi,
             diqs_delivery_item_qty_status diqs,
             pcpd_pc_product_definition    pcpd,
             pdm_productmaster             pdm,
             qum_quantity_unit_master      qum_base,
             cpc_corporate_profit_center   cpc,
             qum_quantity_unit_master      qum,
             ucm_unit_conversion_master    ucm
       where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcdi.pcdi_id = diqs.pcdi_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.input_output = 'Input'
         and pcpd.process_id = pc_process_id
         and pcpd.product_id = pdm.product_id
         and pcpd.profit_center_id = cpc.profit_center_id
         and diqs.item_qty_unit_id = qum.qty_unit_id
         and pdm.base_quantity_unit = qum_base.qty_unit_id
         and pcm.contract_type = 'BASEMETAL'
         and pcdi.item_price_type='Fixed'
         and ucm.from_qty_unit_id = qum.qty_unit_id
         and ucm.to_qty_unit_id = qum_base.qty_unit_id
         and nvl(pcm.contract_status, 'NA') <> 'Cancelled'
         and pcm.purchase_sales = 'S'
         and pcm.corporate_id = pc_corporate_id
         and pcm.is_active = 'Y'
         and pcdi.shipment_date is not null
         and pcdi.shipment_date < pd_trade_date
       group by pcm.corporate_id,
                pcpd.product_id,
                pdm.product_desc,
                pcpd.profit_center_id,
                cpc.profit_center_short_name,
                cpc.profit_center_name,
                trunc(pcdi.shipment_date, 'Mon'),
                to_char(pcdi.shipment_date, 'Mon-YYYY'),
                qum_base.qty_unit_id,
                qum_base.qty_unit,
                nvl(pcm.approval_status, 'Approved');
    commit;                     
                          
                          
    ----************* insert dummy sections -----------
    for cc in (select t2.corporate_id,
                      t1.profit_center_id,
                      t1.profit_center_name,
                      t1.profit_center_short_name,
                      t2.product_id,
                      t2.product_desc,
                      t2.qty_unit_id,
                      t2.qty_unit
                 from (select cpc.corporateid,
                              cpc.profit_center_id,
                              cpc.profit_center_name,
                              cpc.profit_center_short_name
                         from cpc_corporate_profit_center cpc
                        where cpc.corporateid = pc_corporate_id
                          and cpc.is_active = 'Y'
                          and cpc.is_deleted = 'N') t1,
                      (select cpm.corporate_id,
                              pdm.product_id,
                              pdm.product_desc,
                              qum.qty_unit_id,
                              qum.qty_unit
                         from cpm_corporateproductmaster cpm,
                              pdm_productmaster          pdm,
                              qum_quantity_unit_master   qum
                        where cpm.corporate_id = pc_corporate_id
                          and cpm.is_active = 'Y'
                          and cpm.is_deleted = 'N'
                          and cpm.product_id = pdm.product_id
                          and pdm.base_quantity_unit = qum.qty_unit_id) t2
                where t1.corporateid = t2.corporate_id)
    loop
      i := 0;
      --Physical total
      insert into temp_tpr
        (corporate_id,
         section_name,
         section_id,
         product_id,
         product_desc,
         profit_center_id,
         profit_center_short_name,
         profit_center_name,
         delivery_date,
         delivery_month_display,
         quantity,
         quantity_unit_id,
         quantity_unit,
         strategy_id,
         strategy_name,
         approval_status)
      values
        (cc.corporate_id,
         'Physical Total',
         '13',
         cc.product_id,
         cc.product_desc,
         cc.profit_center_id,
         cc.profit_center_short_name,
         cc.profit_center_name,
         trunc(to_date('01-' || 'Jan-1900'), 'Mon'),
         'Opening Balance',
         0,
         cc.qty_unit_id,
         cc.qty_unit,
         null,
         'Physical Total',
         'Approved');
      -- for dumy months--------
      --Physical total
      /*while i <= 9
      loop
        insert into temp_tpr
          (corporate_id,
           section_name,
           section_id,
           product_id,
           product_desc,
           profit_center_id,
           profit_center_short_name,
           profit_center_name,
           delivery_date,
           delivery_month_display,
           quantity,
           quantity_unit_id,
           quantity_unit,
           strategy_id,
           strategy_name,
           approval_status)
        values
          (cc.corporate_id,
           'Physical Total',
           '13',
           cc.product_id,
           cc.product_desc,
           cc.profit_center_id,
           cc.profit_center_short_name,
           cc.profit_center_name,
           trunc(add_months(pd_trade_date, i), 'Mon'),
           to_char(add_months(pd_trade_date, i), 'Mon-YYYY'),
           0,
           cc.qty_unit_id,
           cc.qty_unit,
           null,
           'Physical Total',
           'Approved');
        i := i + 1;
      end loop;*/
      --Options total
      insert into temp_tpr
        (corporate_id,
         section_name,
         section_id,
         product_id,
         product_desc,
         profit_center_id,
         profit_center_short_name,
         profit_center_name,
         delivery_date,
         delivery_month_display,
         quantity,
         quantity_unit_id,
         quantity_unit,
         strategy_id,
         strategy_name,
         approval_status)
      values
        (cc.corporate_id,
         'Options',
         '15',
         cc.product_id,
         cc.product_desc,
         cc.profit_center_id,
         cc.profit_center_short_name,
         cc.profit_center_name,
         trunc(to_date('01-' || 'Jan-1900'), 'Mon'),
         'Opening Balance',
         0,
         cc.qty_unit_id,
         cc.qty_unit,
         null,
         'Options',
         'Approved');
      --for derivate strategy section
      for cc1 in (select css.corporate_id,
                         css.strategy_name
                    from css_corporate_strategy_setup css
                   where css.corporate_id = pc_corporate_id
                     and css.is_active = 'Y'
                     and css.is_deleted = 'N')
      loop
        insert into temp_tpr
          (corporate_id,
           section_name,
           section_id,
           product_id,
           product_desc,
           profit_center_id,
           profit_center_short_name,
           profit_center_name,
           delivery_date,
           delivery_month_display,
           quantity,
           quantity_unit_id,
           quantity_unit,
           strategy_id,
           strategy_name,
           approval_status)
        values
          (cc.corporate_id,
           'Derivative',
           '1',
           cc.product_id,
           cc.product_desc,
           cc.profit_center_id,
           cc.profit_center_short_name,
           cc.profit_center_name,
           trunc(to_date('01-' || 'Jan-1900'), 'Mon'),
           'Opening Balance',
           0,
           cc.qty_unit_id,
           cc.qty_unit,
           'Strategy',
           cc1.strategy_name,
           'Approved');
      end loop;
      commit;
    end loop;
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR - insert temp_tpr for dummy section ends');
    ---dummy section ends here 
    --data to main table started....
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR Main table insert - derivative by strategy started');
  
    --- derivative trade by strategy
    insert into tpr_traders_position_report
      (corporate_id,
       process_id,
       process,
       eod_date,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select corporate_id,
             pc_process_id,
             pc_process,
             pd_trade_date,
             section_name,
             section_id,
             product_id,
             product_desc,
             profit_center_id,
             profit_center_short_name,
             profit_center_name,
             delivery_date,
             delivery_month_display,
             sum(quantity),
             quantity_unit_id,
             quantity_unit,
             strategy_id,
             strategy_name,
             approval_status
        from temp_tpr tpr
       where tpr.corporate_id = pc_corporate_id
         and tpr.section_name in ('Derivative')
       group by corporate_id,
                section_name,
                section_id,
                product_id,
                product_desc,
                profit_center_id,
                profit_center_short_name,
                profit_center_name,
                delivery_date,
                delivery_month_display,
                quantity_unit_id,
                quantity_unit,
                strategy_id,
                strategy_name,
                approval_status;
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR Main table insert - derivative by summary section started');
    --- total sum of derivative trade
    insert into tpr_traders_position_report
      (corporate_id,
       process_id,
       process,
       eod_date,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select corporate_id,
             pc_process_id,
             pc_process,
             pd_trade_date,
             'Derivative' section_name,
             '12' section_id,
             product_id,
             product_desc,
             profit_center_id,
             profit_center_short_name,
             profit_center_name,
             delivery_date,
             delivery_month_display,
             sum(quantity),
             quantity_unit_id,
             quantity_unit,
             null strategy_id,
             'Derivative' strategy_name,
             approval_status
        from temp_tpr tpr
       where tpr.corporate_id = pc_corporate_id
         and tpr.section_name in ('Derivative')
       group by corporate_id,
                product_id,
                product_desc,
                profit_center_id,
                profit_center_short_name,
                profit_center_name,
                delivery_date,
                delivery_month_display,
                quantity_unit_id,
                quantity_unit,
                approval_status;
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR Main table insert - Physical Total section started');
    insert into tpr_traders_position_report
      (corporate_id,
       process_id,
       process,
       eod_date,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select corporate_id,
             pc_process_id,
             pc_process,
             pd_trade_date,
             'Physical Total' section_name,
             '13' section_id,
             product_id,
             product_desc,
             profit_center_id,
             profit_center_short_name,
             profit_center_name,
             delivery_date,
             delivery_month_display,
             sum(quantity),
             quantity_unit_id,
             quantity_unit,
             null strategy_id,
             'Physical Total' strategy_name,
             approval_status
        from temp_tpr tpr
       where tpr.corporate_id = pc_corporate_id
         and tpr.section_name in ('Physical Total')
       group by corporate_id,
                product_id,
                product_desc,
                profit_center_id,
                profit_center_short_name,
                profit_center_name,
                delivery_date,
                delivery_month_display,
                quantity_unit_id,
                quantity_unit,
                approval_status;
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR Main table insert - Balance section started');
  
    insert into tpr_traders_position_report
      (corporate_id,
       process_id,
       process,
       eod_date,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select corporate_id,
             pc_process_id,
             pc_process,
             pd_trade_date,
             'Balance' section_name,
             '14' section_id,
             product_id,
             product_desc,
             profit_center_id,
             profit_center_short_name,
             profit_center_name,
             delivery_date,
             delivery_month_display,
             sum(quantity),
             quantity_unit_id,
             quantity_unit,
             null strategy_id,
             'Balance' strategy_name,
             approval_status
        from temp_tpr tpr
       where tpr.corporate_id = pc_corporate_id
         and tpr.section_name in ('Derivative', 'Physical Total')
       group by corporate_id,
                product_id,
                product_desc,
                profit_center_id,
                profit_center_short_name,
                profit_center_name,
                delivery_date,
                delivery_month_display,
                quantity_unit_id,
                quantity_unit,
                approval_status;
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR Main table insert - Options section started');
  
    insert into tpr_traders_position_report
      (corporate_id,
       process_id,
       process,
       eod_date,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select corporate_id,
             pc_process_id,
             pc_process,
             pd_trade_date,
             'Options' section_name,
             '15' section_id,
             product_id,
             product_desc,
             profit_center_id,
             profit_center_short_name,
             profit_center_name,
             delivery_date,
             delivery_month_display,
             sum(quantity),
             quantity_unit_id,
             quantity_unit,
             null strategy_id,
             'Options' strategy_name,
             approval_status
        from temp_tpr tpr
       where tpr.corporate_id = pc_corporate_id
         and tpr.section_name in ('Options')
       group by corporate_id,
                product_id,
                product_desc,
                profit_center_id,
                profit_center_short_name,
                profit_center_name,
                delivery_date,
                delivery_month_display,
                quantity_unit_id,
                quantity_unit,
                approval_status;
    commit;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'TPR Main table insert - Total section started');
  
    insert into tpr_traders_position_report
      (corporate_id,
       process_id,
       process,
       eod_date,
       section_name,
       section_id,
       product_id,
       product_desc,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       delivery_date,
       delivery_month_display,
       quantity,
       quantity_unit_id,
       quantity_unit,
       strategy_id,
       strategy_name,
       approval_status)
      select corporate_id,
             pc_process_id,
             pc_process,
             pd_trade_date,
             'Total' section_name,
             '16' section_id,
             product_id,
             product_desc,
             profit_center_id,
             profit_center_short_name,
             profit_center_name,
             delivery_date,
             delivery_month_display,
             sum(quantity),
             quantity_unit_id,
             quantity_unit,
             null strategy_id,
             'Total' strategy_name,
             approval_status
        from temp_tpr tpr
       where tpr.corporate_id = pc_corporate_id
         and tpr.section_name in
             ('Derivative', 'Physical Total', 'Options')
       group by corporate_id,
                product_id,
                product_desc,
                profit_center_id,
                profit_center_short_name,
                profit_center_name,
                delivery_date,
                delivery_month_display,
                quantity_unit_id,
                quantity_unit,
                approval_status;
    commit;
    for cc2 in (select akc.corporate_name,
                       akc.base_cur_id,
                       akc.base_currency_name
                  from ak_corporate akc
                 where akc.corporate_id = pc_corporate_id)
    loop
      update tpr_traders_position_report tpr
         set tpr.corporate_name = cc2.corporate_name
       where tpr.corporate_id = pc_corporate_id
         and tpr.process_id = pc_process_id;
    end loop;
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'traders position report completed');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_trader_position_report',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_unrealized_pnl_bkfx_rate(pc_corporate_id    varchar2,
                                        pd_trade_date      date,
                                        pc_process         varchar2,
                                        pc_process_id      varchar2,
                                        pc_user_id         varchar2,
                                        pc_prev_process_id varchar2) as
    cursor cur_unrealized is
      select dpd.process_id,
             dpd.corporate_id,
             dpd.corporate_name,
             pdm.product_type_id product_type,
             dpd.profit_center_id,
             dpd.profit_center_short_name profit_center,
             dpd.strategy_id,
             dpd.strategy_name,
             dpd.product_id,
             dpd.product_name,
             dpd.quality_id,
             dpd.quality_name,
             dpd.eod_trade_date eod_date,
             tdc.process eod_eom_flag,
             'Derivatives' position_type,
             dpd.instrument_type || ' ' || (case
               when dpd.trade_type = 'Buy' then
                'Long'
               else
                'Short'
             end) position_sub_type,
             dpd.derivative_ref_no contract_ref_no,
             dpd.external_ref_no,
             dpd.trade_date issue_trade_date,
             nvl(dpd.clearer_profile_id, dpd.cp_profile_id) cp_id,
             nvl(dpd.clearer_name, dpd.cp_name) cp_name,
             dpd.payment_term,
             dpd.purpose_name derivative_purpose,
             (case
               when dpd.instrument_type = 'Option Call' then
                'Call'
               when dpd.instrument_type = 'Option Put' then
                'Put'
               else
                ''
             end) option_type,
             dpd.strike_price strike_price,
             dpd.strike_price_cur_code || '/' || dpd.strike_price_weight ||
             dpd.strike_price_weight_unit strike_price_unit,
             'NA' allocated_phy_refno,
             dpd.group_cur_code,
             cm_corp.cur_code corporate_base_currency,
             dpd.qty_sign * dpd.open_quantity contract_quantity,
             dpd.quantity_unit contract_quantity_uom,
             dpd.qty_sign * dpd.trade_qty_in_exch_unit quantity_in_base_uom,
             dpd.open_lots quantity_in_lots,
             dpd.trade_price contract_price,
             dpd.trade_price_cur_code || '/' || dpd.trade_price_weight ||
             dpd.trade_price_weight_unit trade_price_unit,
             dpd.instrument_id valuation_instrument_id, 
             dpd.instrument_name valuation_instrument,
             dpd.derivative_def_id,
             dpd.derivative_def_name,
             to_char(nvl(dpd.period_date, dpd.prompt_date), 'Mon-yyyy') valuation_month,
             nvl(dpd.period_date, dpd.prompt_date) value_date,
             dpd.settlement_price m2m_settlement_price,
             dpd.settlement_price net_settlement_price,
             dpd.sett_price_cur_code || '/' || dpd.sett_price_weight ||
             dpd.sett_price_weight_unit settlement_price_unit,
             dpd.market_value_in_trade_cur market_value_in_val_ccy, 
             dpd.trade_main_cur_id market_value_cur_id,
             dpd.trade_main_cur_code market_value_cur_code,
             null prev_day_unr_pnl_in_base_cur,
             null unrealized_pnl_in_base_cur,
             null pnl_change_in_base_currency,
             dpd.base_cur_id,
             dpd.base_cur_code,
             dpd.base_qty_unit base_quantity_uom,
             dpd.average_from_date average_period_from,
             dpd.average_to_date average_period_to,
             dpd.premium_discount premium,
             (case
               when dpd.pd_price_cur_code is not null then
                dpd.pd_price_cur_code || '/' || dpd.pd_price_weight ||
                dpd.pd_price_weight_unit
               else
                'NA'
             end) premium_price_unit,
             dpd.clearer_comm_amt commision_value,
             dpd.clearer_comm_cur_code commission_value_currency,
             dpd.expiry_date,
             dpd.prompt_date,
             dpd.dr_id_name prompt_details,
             to_char((case
                       when dpd.period_date is null then
                        (case
                       when dpd.period_month is not null and
                            dpd.period_year is not null then
                        to_date('01-' || dpd.period_month || '-' || dpd.period_year,
                                'dd-Mon-yyyy')
                       else
                        dpd.prompt_date
                     end) else dpd.period_date end), 'Mon-YYYY') prompt_month_year,
             to_char((case
                       when dpd.period_date is null then
                        (case
                       when dpd.period_month is not null and
                            dpd.period_year is not null then
                        to_date('01-' || dpd.period_month || '-' || dpd.period_year,
                                'dd-Mon-yyyy')
                       else
                        dpd.prompt_date
                     end) else dpd.period_date end), 'YYYY') prompt_year,
             null attribute_value_1,
             null attribute_value_2,
             null attribute_value_3,
             null attribute_value_4,
             null attribute_value_5,
             dpd.fixed_avg_price,
             dpd.unfixed_avg_price,
             dpd.clearer_comm_in_base,
             dpd.clearer_exch_rate clearer_cur_to_base,
             dpd.trade_value_in_base,
             dpd.market_value_in_base,
             dpd.trade_type,
             dpd.instrument_type,
             dpd.instrument_sub_type,
             dpd.pnl_in_trade_cur,
             dpd.trade_cur_id,
             dpd.trade_cur_code,
             dpd.trade_cur_to_base_exch_rate,
             dpd.sett_price_weight,
             dpd.sett_price_cur_id,
             dpd.pd_price_cur_id,
             dpd.pd_price_weight_unit_id,
             dpd.sett_price_weight_unit_id,
             dpd.quantity_unit_id,
             dpd.clearer_comm_cur_id,
             dpd.clearer_comm_amt,
             dpd.qty_sign,
             tdc.process      
        from dpd_derivative_pnl_daily dpd,
             tdc_trade_date_closure   tdc,
             pdm_productmaster        pdm,
             ak_corporate             akc,
             cm_currency_master       cm_corp
       where dpd.pnl_type = 'Unrealized'
         and dpd.process_id = tdc.process_id
         and dpd.corporate_id = tdc.corporate_id
         and dpd.derivative_prodct_id = pdm.product_id
         and dpd.corporate_id = akc.corporate_id
         and cm_corp.cur_id = akc.base_cur_id
         and dpd.process_id = pc_process_id
      union all
      select cpd.process_id,
             cpd.corporate_id,
             cpd.corporate_name,
             pdm.product_type_id product_type,
             cpd.profit_center_id,
             cpd.profit_center_short_name profit_center,
             cpd.strategy_id,
             cpd.strategy_name,
             'NA' product_id,
             'NA' product_name,
             'NA' quality_id,
             'NA' quality_name,
             cpd.eod_trade_date eod_date,
             tdc.process eod_eom_flag,
             'Fx' position_type,
             'Fx  ' || cpd.home_cur_buy_sell position_sub_type,
             cpd.ct_ref_no contract_ref_no,
             ct.external_ref_no external_ref_no,
             cpd.trade_date issue_trade_date,
             'NA' cp_id,
             'NA' cp_name,
             pym.payment_term,
             dpm.purpose_name derivative_purpose,
             'NA' option_type,
             0 strike_price,
             'NA' strike_price_unit,
             'NA' allocated_phy_refno,
             cm_group_cur.cur_code,
             cm_corp.cur_code corporate_base_currency,
             (case
               when cpd.home_cur_buy_sell = 'Sell' then
                -1
               else
                1
             end) * cpd.fx_currency_amount contract_quantity,
             cpd.fx_currency contract_quantity_uom,
             (case
               when cpd.home_cur_buy_sell = 'Sell' then
                -1
               else
                1
             end) * cpd.home_currency_amount quantity_in_base_uom,
             0 quantity_in_lots,
             cpd.original_exchange_rate contract_price,
             cpd.fx_currency || ' to ' || cpd.home_currency trade_price_unit,
             cpd.instrument_id valuation_instrument_id,
             cpd.instrument_name valuation_instrument,
             cpd.currency_def_id derivative_def_id,
             cpd.derivative_name derivative_def_name,
             'NA' valuation_month,
             cpd.prompt_date value_date,
             cpd.market_exchange_rate m2m_settlement_price,
             cpd.market_exchange_rate net_settlement_price,
             cpd.fx_currency || ' to ' || cpd.home_currency settlement_price_unit,
             null market_value_in_val_ccy,
             cpd.home_cur_id market_value_cur_id,
             cpd.home_currency market_value_cur_code,
             null prev_day_unr_pnl_in_base_cur,
             cpd.pnl_value_in_home_currency unrealized_pnl_in_base_cur,
             null pnl_change_in_base_currency,
             cpd.home_cur_id base_cur_id,
             cpd.home_currency base_cur_code,
             cpd.home_currency base_quantity_uom,
             null average_period_from,
             null average_period_to,
             null premium,
             'NA' premium_price_unit,
             null commision_value,
             'NA' commission_value_currency,
             null expiry_date,
             cpd.prompt_date,
             null prompt_details,
             to_char(cpd.prompt_date, 'Mon-YYYY') prompt_month_year,
             to_char(cpd.prompt_date, 'YYYY') prompt_year,
             null attribute_value_1,
             null attribute_value_2,
             null attribute_value_3,
             null attribute_value_4,
             null attribute_value_5,
             0 fixed_avg_price,
             0 unfixed_avg_price,
             0 clearer_comm_in_base,
             0 clearer_cur_to_base,
             0 trade_value_in_base,
             0 market_value_in_base,
             'NA' trade_type,
             'Forward' instrument_type,
             'NA' instrument_sub_type,
             null pnl_in_trade_cur,
             null trade_cur_id,
             null trade_cur_code,
             null trade_cur_to_base_exch_rate,
             null sett_price_weight,
             null sett_price_cur_id,
             null pd_price_cur_id,
             null pd_price_weight_unit_id,
             null sett_price_weight_unit_id,
             null quantity_unit_id,
             null clearer_comm_cur_id,
             null clearer_comm_amt,
             null qty_sign,
             tdc.process
      
        from cpd_currency_pnl_daily        cpd,
             tdc_trade_date_closure        tdc,
             ct_currency_trade             ct,
             pym_payment_terms_master      pym,
             dpm_derivative_purpose_master dpm,
             ak_corporate                  ak,
             gcd_groupcorporatedetails     gcd_group_id,
             cm_currency_master            cm_group_cur,
             cm_currency_master            cm_corp,
             pdm_productmaster             pdm
       where upper(cpd.pnl_type) = 'UNREALIZED'
         and cpd.process_id = tdc.process_id
         and cpd.corporate_id = tdc.corporate_id
         and ct.internal_treasury_ref_no = cpd.ct_internal_ref_no
         and ct.process_id = cpd.process_id
         and pym.payment_term_id(+) = ct.payment_terms_id
         and dpm.purpose_id = ct.purpose_id
         and cpd.corporate_id = ak.corporate_id
         and ak.corporate_id = tdc.corporate_id
         and gcd_group_id.groupid = ak.groupid
         and cm_group_cur.cur_id = gcd_group_id.group_cur_id
         and ak.base_cur_id = cm_corp.cur_id
         and cpd.product_name = pdm.product_desc
         and cpd.process_id = pc_process_id
         and ct.process_id = pc_process_id;
  
    vn_trade_to_base_bank_fxrate   number;
    vn_pnl_base_cur_cp_fxrate      number;
    vn_market_price_in_trade_cur   number;
    vn_qty_in_trade_wt_unit        number;
    vc_trade_main_cur_id           varchar2(15);
    vc_trade_main_cur_code         varchar2(15);
    vn_trade_sub_cur_id_factor     number;
    vn_trade_cur_decimals          number;
    vn_total_trade_value_trade_cur number;
    vn_pnl_value_in_trade_cur      number;
    vn_total_market_val_trade_cur  number;
    vn_clearer_to_base_bank_fxrate number;
    vn_clearer_to_base             number;
    
  begin
    for cur_unrealized_rows in cur_unrealized
    loop
      -- calucalting pnl in trade cur only for options else take pnl_in_trade_cur from DPD Table
      if cur_unrealized_rows.instrument_type in
         ('Option Put', 'Option Call', 'OTC Put Option', 'OTC Call Option') then
        vn_qty_in_trade_wt_unit := pkg_general.f_get_converted_quantity(null, --product id
                                                                        cur_unrealized_rows.quantity_unit_id,
                                                                        cur_unrealized_rows.pd_price_weight_unit_id,
                                                                        cur_unrealized_rows.contract_quantity);
      
        pkg_general.sp_get_main_cur_detail(cur_unrealized_rows.pd_price_cur_id,
                                           vc_trade_main_cur_id,
                                           vc_trade_main_cur_code,
                                           vn_trade_sub_cur_id_factor,
                                           vn_trade_cur_decimals);
      
        vn_total_trade_value_trade_cur := vn_qty_in_trade_wt_unit *
                                          cur_unrealized_rows.premium *
                                          vn_trade_sub_cur_id_factor;
      
        vn_market_price_in_trade_cur  := ((cur_unrealized_rows.m2m_settlement_price /
                                         nvl(cur_unrealized_rows.sett_price_weight,
                                               1)) *
                                         pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                   cur_unrealized_rows.sett_price_cur_id,
                                                                                   cur_unrealized_rows.pd_price_cur_id,
                                                                                   pd_trade_date,
                                                                                   1)) /
                                         (pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                               cur_unrealized_rows.sett_price_weight_unit_id,
                                                                               cur_unrealized_rows.pd_price_weight_unit_id,
                                                                               1));
        vn_total_market_val_trade_cur := vn_market_price_in_trade_cur *
                                         vn_qty_in_trade_wt_unit *
                                         vn_trade_sub_cur_id_factor;
                                         
                                         
         vn_pnl_value_in_trade_cur :=(vn_total_market_val_trade_cur -
                                       vn_total_trade_value_trade_cur)* cur_unrealized_rows.qty_sign ;
        
      
      else
        vn_pnl_value_in_trade_cur := cur_unrealized_rows.pnl_in_trade_cur;
      end if;
    
      ----- pnl in base with bank fx rate
      if cur_unrealized_rows.trade_cur_id is not null and cur_unrealized_rows.base_cur_id is not null then
      pkg_cdc_derivatives_process.sp_cdc_bank_fx_rate(cur_unrealized_rows.corporate_id,
                          pd_trade_date,
                          cur_unrealized_rows.trade_cur_id,
                          cur_unrealized_rows.base_cur_id,
                          pc_process,
                          vn_trade_to_base_bank_fxrate);
      end if;
                          
      if cur_unrealized_rows.position_type = 'Derivatives' then
        vn_pnl_base_cur_cp_fxrate := vn_pnl_value_in_trade_cur *
                                     vn_trade_to_base_bank_fxrate;
      else
      -- currency Trades  as same in CPD table taken
        vn_pnl_base_cur_cp_fxrate := cur_unrealized_rows.unrealized_pnl_in_base_cur;
      end if;
      
      -- clearer come to base with bank fx rate
      if cur_unrealized_rows.clearer_comm_cur_id is not null and cur_unrealized_rows.base_cur_id is not null then
      pkg_cdc_derivatives_process.sp_cdc_bank_fx_rate(cur_unrealized_rows.corporate_id,
                          pd_trade_date,
                          cur_unrealized_rows.clearer_comm_cur_id,
                          cur_unrealized_rows.base_cur_id,
                          pc_process,
                          vn_clearer_to_base_bank_fxrate);
      end if;
      if cur_unrealized_rows.position_type = 'Derivatives' then
      vn_clearer_to_base:= cur_unrealized_rows.clearer_comm_amt*vn_clearer_to_base_bank_fxrate;
      else
      vn_clearer_to_base:=0;  
      end if;                       
    
      insert into bdp_bi_dertivative_pnl
        (process_id,
         corporate_id,
         corporate_name,
         product_type,
         profit_center_id,
         profit_center,
         strategy_id,
         strategy_name,
         product_id,
         product_name,
         quality_id,
         quality_name,
         eod_date,
         eod_eom_flag,
         position_type,
         position_sub_type,
         contract_ref_no,
         external_ref_no,
         issue_trade_date,
         cp_id,
         cp_name,
         payment_term,
         derivative_purpose,
         option_type,
         strike_price,
         strike_price_unit,
         allocated_phy_refno,
         group_cur_code,
         corporate_base_currency,
         contract_quantity,
         contract_quantity_uom,
         quantity_in_base_uom,
         quantity_in_lots,
         contract_price,
         trade_price_unit,
         valuation_instrument_id,
         valuation_instrument,
         derivative_def_id,
         derivative_def_name,
         valuation_month,
         value_date,
         m2m_settlement_price,
         net_settlement_price,
         settlement_price_unit,
         market_value_in_val_ccy,
         market_value_cur_id,
         market_value_cur_code,
         prev_day_unr_pnl_in_base_cur,
         unrealized_pnl_in_base_cur,
         pnl_change_in_base_currency,
         base_cur_id,
         base_cur_code,
         base_quantity_uom,
         average_period_from,
         average_period_to,
         premium,
         premium_price_unit,
         commision_value,---
         commission_value_currency,---
         expiry_date,
         prompt_date,
         prompt_details,
         prompt_month_year,
         prompt_year,
         attribute_1,
         attribute_2,
         attribute_3,
         attribute_4,
         attribute_5,
         fixed_avg_price,
         unfixed_avg_price,
         clearer_comm_in_base,
         clearer_cur_to_base,
         trade_value_in_base,
         market_value_in_base,
         trade_type,
         instrument_type,
         instrument_sub_type,
         pnl_in_trade_cur,
         pnl_in_trade_cur_id,
         pnl_in_trade_cur_code,
         trade_cur_to_base_exch_rate,
         trade_cur_to_base_bank_fx_rate,
         clearer_cur_to_base_bk_fx_rate,
         trade_clearer_comm_amt,
         process)
      values
        (cur_unrealized_rows.process_id,
         cur_unrealized_rows.corporate_id,
         cur_unrealized_rows.corporate_name,
         cur_unrealized_rows.product_type,
         cur_unrealized_rows.profit_center_id,
         cur_unrealized_rows.profit_center,
         cur_unrealized_rows.strategy_id,
         cur_unrealized_rows.strategy_name,
         cur_unrealized_rows.product_id,
         cur_unrealized_rows.product_name,
         cur_unrealized_rows.quality_id,
         cur_unrealized_rows.quality_name,
         cur_unrealized_rows.eod_date,
         cur_unrealized_rows.eod_eom_flag,
         cur_unrealized_rows.position_type,
         cur_unrealized_rows.position_sub_type,
         cur_unrealized_rows.contract_ref_no,
         cur_unrealized_rows.external_ref_no,
         cur_unrealized_rows.issue_trade_date,
         cur_unrealized_rows.cp_id,
         cur_unrealized_rows.cp_name,
         cur_unrealized_rows.payment_term,
         cur_unrealized_rows.derivative_purpose,
         cur_unrealized_rows.option_type,
         cur_unrealized_rows.strike_price,
         cur_unrealized_rows.strike_price_unit,
         cur_unrealized_rows.allocated_phy_refno,
         cur_unrealized_rows.group_cur_code,
         cur_unrealized_rows.corporate_base_currency,
         cur_unrealized_rows.contract_quantity,
         cur_unrealized_rows.contract_quantity_uom,
         cur_unrealized_rows.quantity_in_base_uom,
         cur_unrealized_rows.quantity_in_lots,
         cur_unrealized_rows.contract_price,
         cur_unrealized_rows.trade_price_unit,
         cur_unrealized_rows.valuation_instrument_id,
         cur_unrealized_rows.valuation_instrument,
         cur_unrealized_rows.derivative_def_id,
         cur_unrealized_rows.derivative_def_name,
         cur_unrealized_rows.valuation_month,
         cur_unrealized_rows.value_date,
         cur_unrealized_rows.m2m_settlement_price,
         cur_unrealized_rows.net_settlement_price,
         cur_unrealized_rows.settlement_price_unit,
         cur_unrealized_rows.market_value_in_val_ccy,
         cur_unrealized_rows.market_value_cur_id,
         cur_unrealized_rows.market_value_cur_code,
         cur_unrealized_rows.prev_day_unr_pnl_in_base_cur,
         vn_pnl_base_cur_cp_fxrate, ---
         cur_unrealized_rows.pnl_change_in_base_currency,
         cur_unrealized_rows.base_cur_id,
         cur_unrealized_rows.base_cur_code,
         cur_unrealized_rows.base_quantity_uom,
         cur_unrealized_rows.average_period_from,
         cur_unrealized_rows.average_period_to,
         cur_unrealized_rows.premium,
         cur_unrealized_rows.premium_price_unit,
         vn_clearer_to_base,---
         cur_unrealized_rows.commission_value_currency,--
         cur_unrealized_rows.expiry_date,
         cur_unrealized_rows.prompt_date,
         cur_unrealized_rows.prompt_details,
         cur_unrealized_rows.prompt_month_year,
         cur_unrealized_rows.prompt_year,
         cur_unrealized_rows.attribute_value_1,
         cur_unrealized_rows.attribute_value_2,
         cur_unrealized_rows.attribute_value_3,
         cur_unrealized_rows.attribute_value_4,
         cur_unrealized_rows.attribute_value_5,
         cur_unrealized_rows.fixed_avg_price,
         cur_unrealized_rows.unfixed_avg_price,
         cur_unrealized_rows.clearer_comm_in_base,
         cur_unrealized_rows.clearer_cur_to_base,
         cur_unrealized_rows.trade_value_in_base,
         cur_unrealized_rows.market_value_in_base,
         cur_unrealized_rows.trade_type,
         cur_unrealized_rows.instrument_type,
         cur_unrealized_rows.instrument_sub_type,
         vn_pnl_value_in_trade_cur,
         cur_unrealized_rows.trade_cur_id,
         cur_unrealized_rows.trade_cur_code,
         cur_unrealized_rows.trade_cur_to_base_exch_rate,
         vn_trade_to_base_bank_fxrate,
         vn_clearer_to_base_bank_fxrate,
         cur_unrealized_rows.clearer_comm_amt,
         cur_unrealized_rows.process);
    end loop;
    commit;
    -- update previous unrealized pnl base cur with Bank FX rate
    begin
      for cur_update in (select bdp_prev_day.contract_ref_no,
                                bdp_prev_day.unrealized_pnl_in_base_cur
                           from bdp_bi_dertivative_pnl bdp_prev_day
                          where bdp_prev_day.process_id = pc_prev_process_id
                            and corporate_id = pc_corporate_id)
      loop
        update bdp_bi_dertivative_pnl bdp_today
           set bdp_today.prev_day_unr_pnl_in_base_cur = nvl(cur_update.unrealized_pnl_in_base_cur,
                                                            0)
         where bdp_today.contract_ref_no = cur_update.contract_ref_no
           and bdp_today.process_id = pc_process_id;
      end loop;
    end;
    commit;
    -- update change in PNL with Bank Fx Rate
    update bdp_bi_dertivative_pnl bdp
       set bdp.pnl_change_in_base_currency = nvl(unrealized_pnl_in_base_cur,
                                                 0) - nvl(prev_day_unr_pnl_in_base_cur,
                                                          0)
     where bdp.process_id = pc_process_id;
    commit;
  
  end;
end pkg_phy_custom_reports; 
/
