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
  procedure sp_derivative_contract_journal(pc_corporate_id varchar2,
                                           pc_process      varchar2,
                                           pd_trade_date   date,
                                           pc_user_id      varchar2,
                                           pc_dbd_id       varchar2,
                                           pc_prev_dbd_id  varchar2);
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
    --        Purpose                                   : this package is for custom report client specific
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
    vn_logno := vn_logno + 1;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_process_id,
                          vn_logno,
                          'sp_derivative_contract_journal');
    vc_err_msg := 'sp_derivative_contract_journal ';
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    sp_derivative_contract_journal(pc_corporate_id,
                                   pc_process,
                                   pd_trade_date,
                                   pc_user_id,
                                   pc_dbd_id,
                                   pc_prev_dbd_id); --pc_prev_dbd_id
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
    commit;
    <<cancel_process>>
    dbms_output.put_line('EOD/EOM Process Cancelled while journal calculation');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_custom_reports.sp_call_custom_reports',
                                                           'GEN-001',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           'EOD',
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
             dcod.quantity_closed quantity,
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
             ((case
               when dt.trade_type = 'Sell' then
                1
               else
                -1
             end) * (round((dt.trade_price * dcod.quantity_closed *
                            nvl(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                      dcod.quantity_unit_id,
                                                                      pum_tp.weight_unit_id,
                                                                      1),
                                 1)),
                            4))) trade_amount,
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
         and dcoh.process_id = dcod.process_id
         and dcod.internal_derivative_ref_no =
             dt.internal_derivative_ref_no
         and dcod.process_id = dt.process_id
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
         and pum_tp.weight_unit_id = qum_tp.qty_unit_id(+)
         and pum_tp.cur_id = cm_tp.cur_id(+)
         and dcoh.created_by = akcu.user_id
         and akcu.gabid = gab_akc.gabid
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
             dcod.quantity_closed quantity,
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
             ((case
               when dt.trade_type = 'Sell' then
                1
               else
                -1
             end) * (round((dt.trade_price * dcod.quantity_closed *
                            nvl(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                      dcod.quantity_unit_id,
                                                                      pum_tp.weight_unit_id,
                                                                      1),
                                 1)),
                            4))) trade_amount,
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
         and dcoh.process_id = dcod.process_id
         and dcod.internal_derivative_ref_no =
             dt.internal_derivative_ref_no
         and dcod.process_id = dt.process_id
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
         and dcoh.is_rolled_back = 'N'
         and pum_tp.weight_unit_id = qum_tp.qty_unit_id(+)
         and pum_tp.cur_id = cm_tp.cur_id(+)
         and dcoh.created_by = akcu.user_id
         and akcu.gabid = gab_akc.gabid;
  
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
        vn_contract_value := (cr_cdc_row.trade_price * cr_cdc_row.quantity *
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
                                                           'GEN-001',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           'EOD',
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
             css.strategy_name,
             dt.trade_type,
             dt.trade_date,
             pdm.product_desc product,
             drm.prompt_date prompt_date,
             round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
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
             dt.total_quantity,
             qum.qty_unit total_qty_unit,
             nvl(dt.expired_lots, 0) expired_lots,
             nvl(dt.exercised_lots, 0) exercised_lots,
             nvl(dt.expired_quantity, 0) expired_quantity,
             nvl(dt.exercised_quantity, 0) exercised_quantity,
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
             emt.exchange_name
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
             cm_currency_master               cmcl
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
      
      union all
      select 'Deleted' catogery,
             dt.derivative_ref_no,
             nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
             gab.firstname || ' ' || gab.lastname trader,
             css.strategy_name,
             dt.trade_type,
             dt.trade_date,
             pdm.product_desc product,
             drm.prompt_date prompt_date,
             round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
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
             dt.total_quantity,
             qum.qty_unit total_qty_unit,
             nvl(dt.expired_lots, 0) expired_lots,
             nvl(dt.exercised_lots, 0) exercised_lots,
             nvl(dt.expired_quantity, 0) expired_quantity,
             nvl(dt.exercised_quantity, 0) exercised_quantity,
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
             emt.exchange_name
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
             cm_currency_master               cmcl
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
             css.strategy_name,
             dt.trade_type,
             dt.trade_date,
             pdm.product_desc product,
             drm.prompt_date prompt_date,
             round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
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
             dt.total_quantity,
             qum.qty_unit total_qty_unit,
             nvl(dt.expired_lots, 0) expired_lots,
             nvl(dt.exercised_lots, 0) exercised_lots,
             nvl(dt.expired_quantity, 0) expired_quantity,
             nvl(dt.exercised_quantity, 0) exercised_quantity,
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
             emt.exchange_name
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
             cm_currency_master               cmcl
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
         remarks)
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
         dvj.remarks);
    
    end loop;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_derivative_journal',
                                                           'GEN-001',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           'EOD',
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
             dpd.base_qty_unit
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
             fsh.internal_derivative_ref_no
         and dpd.settlement_ref_no = fsh.settlement_ref_no
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
             dpd.base_qty_unit
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
       where dpd.pnl_type = 'Reverse Realized'
         and dpd.instrument_type = 'Average'
         and dpd.corporate_id = pc_corporate_id
         and dpd.process_id = pc_process_id
         and dpd.internal_derivative_ref_no =
             fsh.internal_derivative_ref_no
         and dpd.settlement_ref_no = fsh.settlement_ref_no;
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
             pcm.contract_ref_no || '-' || pcdi.delivery_item_no delivery_item_ref_no,
             diqs.total_qty delivery_item_qty,
             qum_diqs.qty_unit delivery_item_qty_unit,
             (case
               when gmr.gmr_ref_no is not null then
                gmr.gmr_ref_no
               else
                pcm.contract_ref_no
             end) contract_ref_no,
             pcm.cp_id clearer_profile_id,
             phd_cp.companyname clearer_name,
             gab.firstname || ' ' || gab.lastname trader_name,
             pofh.latest_pfc_date price_fixation_date,
             pofh.qp_start_qty fixed_quantity,
             qum_fxd.qty_unit quantity_unit,
             pofh.latest_avg_price trade_price,
             ppu_pum.price_unit_name price_unit,
             pofh.latest_adj_price,
             round(pkg_general.f_get_converted_currency_amt(pcm.corporate_id,
                                                            ppu_pum.cur_id,
                                                            akc.base_cur_id,
                                                            sysdate,
                                                            1),
                   10) fx_rate, --price to base
             0 contract_premium, --inside formula
             ppu_pum.price_unit_name contract_premium_unit, --inside variable
             pcm.issue_date contract_issue_date,
             pofh.qp_start_date average_from_date,
             pofh.qp_end_date average_to_date,
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
             ppu_pum.price_unit_id trade_price_unit_id,
             ppu_pum.price_unit_id premium_discount_price_unit_id,
             ppu_pum.cur_id trade_price_cur_id,
             cm_ppu.cur_code trade_price_cur_code,
             ppu_pum.weight trade_price_weight,
             ppu_pum.weight_unit_id trade_price_weight_unit_id,
             qum_ppu.qty_unit trade_price_weight_unit,
             ppu_pum.cur_id pd_price_cur_id,
             cm_ppu.cur_code pd_price_cur_code,
             ppu_pum.weight pd_price_weight,
             ppu_pum.weight_unit_id pd_price_weight_unit_id,
             qum_ppu.qty_unit pd_price_weight_unit,
             pofh.pofh_id,
             aml.attribute_id,
             aml.attribute_name
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
             aml_attribute_master_list      aml
       where pofh.is_new = 'Y'
         and pofh.is_active = 'Y'
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
         and ppu_pum.cur_id = cm_ppu.cur_id
         and ppu_pum.weight_unit_id = qum_ppu.qty_unit_id
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pofh.corporate_id = pc_corporate_id
         and pofh.process_id = pc_process_id
         and pofh.process = pc_process
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id
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
             pcm.contract_ref_no || '-' || pcdi.delivery_item_no delivery_item_ref_no,
             diqs.total_qty delivery_item_qty,
             qum_diqs.qty_unit delivery_item_qty_unit,
             (case
               when gmr.gmr_ref_no is not null then
                gmr.gmr_ref_no
               else
                pcm.contract_ref_no
             end) contract_ref_no,
             pcm.cp_id clearer_profile_id,
             phd_cp.companyname clearer_name,
             gab.firstname || ' ' || gab.lastname trader_name,
             pofh.latest_pfc_date price_fixation_date,
             pofh.qp_start_qty fixed_quantity,
             qum_fxd.qty_unit quantity_unit,
             pofh.latest_avg_price trade_price,
             ppu_pum.price_unit_name price_unit,
             pofh.latest_adj_price,
             round(pkg_general.f_get_converted_currency_amt(pcm.corporate_id,
                                                            ppu_pum.cur_id,
                                                            akc.base_cur_id,
                                                            sysdate,
                                                            1),
                   10) fx_rate, --price to base
             0 contract_premium, --inside formula
             ppu_pum.price_unit_name contract_premium_unit, --inside variable
             pcm.issue_date contract_issue_date,
             pofh.qp_start_date average_from_date,
             pofh.qp_end_date average_to_date,
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
             ppu_pum.price_unit_id trade_price_unit_id,
             ppu_pum.price_unit_id premium_discount_price_unit_id,
             ppu_pum.cur_id trade_price_cur_id,
             cm_ppu.cur_code trade_price_cur_code,
             ppu_pum.weight trade_price_weight,
             ppu_pum.weight_unit_id trade_price_weight_unit_id,
             qum_ppu.qty_unit trade_price_weight_unit,
             ppu_pum.cur_id pd_price_cur_id,
             cm_ppu.cur_code pd_price_cur_code,
             ppu_pum.weight pd_price_weight,
             ppu_pum.weight_unit_id pd_price_weight_unit_id,
             qum_ppu.qty_unit pd_price_weight_unit,
             pofh.pofh_id,
             aml.attribute_id,
             aml.attribute_name
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
             cm_currency_master             cm_base
       where pofh.is_deleted = 'Y'
            --   and pofh.is_active = 'Y'
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
         and ppu_pum.cur_id = cm_ppu.cur_id
         and ppu_pum.weight_unit_id = qum_ppu.qty_unit_id
         and pcdi.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pofh.corporate_id = pc_corporate_id
         and pofh.process_id = pc_process_id
         and pofh.process = pc_process
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and diqs.process_id = pc_process_id;
  
    --  vn_conv_factor              number;
    --  vn_contract_value           number;
    --   vn_contract_value_in_base   number;
    --  vn_clearer_comm_amt         number;
    --   vn_clearer_comm_amt_in_base number;
    vc_trade_cur_id varchar2(15);
    --vc_trade_main_cur_id        varchar2(15);
    -- vc_trade_main_cur_code      varchar2(15);
    --vn_trade_main_cur_conv_rate number;
    --  vn_trade_main_decimals      number;
    --  vn_trade_to_base_fx_rate    number;
    vn_total_price         number(25, 5);
    vc_total_price_unit    varchar2(50);
    vn_pd_to_price_fx_rate number(25, 10);
    vn_pd_convertion_rate  number(25, 10);
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
         base_qty_unit_id)
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
         cr_cdc_row.base_qty_unit_id);
    end loop;
    commit;
    ---derivative price fixation ends here    
    ---derivative price fixation ends here    
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
                  and pfd.user_price is not null
                  and axs.corporate_id = pc_corporate_id
                group by pfd.pofh_id)
    loop
      update pofh_history ppf
         set ppf.latest_pfc_no            = cc.price_fixation_no,
             ppf.latest_pfc_date          = cc.price_fixation_date,
             ppf.latest_fixed_qty         = cc.fixed_qty,
             ppf.latest_avg_price         = cc.avg_price,
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
               and ppf.final_price is null);
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
               and ppf.final_price is not null);
    commit;
    ---Physical price fixation starts here    
    for cr_cdc_row in cr_phy_fixation
    loop
      vc_trade_cur_id := nvl(cr_cdc_row.trade_price_cur_id,
                             cr_cdc_row.base_cur_id);
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
      vn_total_price      := cr_cdc_row.trade_price +
                             (nvl(cr_cdc_row.contract_premium, 0) *
                             vn_pd_convertion_rate);
      vc_total_price_unit := cr_cdc_row.price_unit;
    
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
         attribute_name)
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
         cr_cdc_row.attribute_id,
         cr_cdc_row.attribute_name);
    end loop;
    commit;
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
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_fixation_journal',
                                                           'GEN-001',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           null,
                                                           'EOD',
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
end;
/
