create or replace package pkg_phy_pre_check_process is

  -- Author  : Janna
  -- Created : 1/11/2009 11:50:17 AM
  -- Purpose : Pre check data for EOD and EOM
  gvc_dbd_id  varchar2(15);
  gvc_process varchar2(3);

  procedure sp_pre_check(pc_corporate_id varchar2,
                         pd_trade_date   date,
                         pc_user_id      varchar2,
                         pc_process      varchar2);

  procedure sp_pre_check_physicals(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2,
                                   pc_process      varchar2);

  procedure sp_calc_m2m_tc_pc_rc_charge(pc_corporate_id         varchar2,
                                        pd_trade_date           date,
                                        pc_conc_product_id      varchar2,
                                        pc_conc_quality_id      varchar2,
                                        pc_valuation_point_id   varchar2,
                                        pc_charge_type          varchar2,
                                        pc_element_id           varchar2,
                                        pc_calendar_month       varchar2,
                                        pc_calendar_year        varchar2,
                                        pn_charge_amt           out number,
                                        pc_charge_price_unit_id out varchar2);

  procedure sp_pre_check_m2m_values(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_dbd_id       varchar2,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2);
  procedure sp_pre_check_m2m_conc_values(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_dbd_id       varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);
  procedure sp_calc_m2m_quality_premimum(pc_corporate_id          varchar2,
                                         pd_trade_date            date,
                                         pc_valuation_point_id    varchar2,
                                         pc_quality_id            varchar2,
                                         pc_product_id            varchar2,
                                         pc_premium_price_unit_id varchar2,
                                         pc_calendar_month        varchar2,
                                         pc_calendar_year         varchar2,
                                         pc_user_id               varchar2,
                                         pc_process               varchar2,
                                         pn_qp_amt                out number);
  procedure sp_calc_m2m_product_premimum(pc_corporate_id          varchar2,
                                         pd_trade_date            date,
                                         pc_product_id            varchar2,
                                         pc_calendar_month        varchar2,
                                         pc_calendar_year         varchar2,
                                         pc_user_id               varchar2,
                                         pc_process               varchar2,
                                         pc_premium_price_unit_id varchar2,
                                         pn_pp_amt                out number);
  function f_get_converted_price_pum(pc_corporate_id       varchar2,
                                     pn_price              number,
                                     pc_from_price_unit_id varchar2,
                                     pc_to_price_unit_id   varchar2,
                                     pd_trade_date         date,
                                     pc_product_id         varchar2)
    return number;
  function f_get_converted_quantity(pc_product_id          in varchar2,
                                    pc_from_qty_unit_id    in varchar2,
                                    pc_to_qty_unit_id      in varchar2,
                                    pn_qty_to_be_converted in number)
    return number;
  function f_get_is_derived_qty_unit(pc_qty_unit_id in varchar2)
    return varchar2;
  function f_get_converted_currency_amt(pc_corporate_id        in varchar2,
                                        pc_from_cur_id         in varchar2,
                                        pc_to_cur_id           in varchar2,
                                        pd_cur_date            in date,
                                        pn_amt_to_be_converted in number)
    return number;

  procedure sp_pre_check_rebuild_stats;

  function fn_get_val_drid(pc_corporate_id       in varchar2,
                           p_instrument_id       in varchar2,
                           p_from_month          in varchar2,
                           p_from_year           in varchar2,
                           p_exec_valution_month in varchar2,
                           p_trade_date          in date,
                           p_trade_type          in varchar2,
                           p_process             in varchar2) return varchar2;
  function f_get_converted_price(p_corporate_id       in varchar2,
                                 p_price              in number,
                                 p_from_price_unit_id in varchar2,
                                 p_to_price_unit_id   in varchar2,
                                 p_trade_date         in date) return number;
  procedure sp_phy_insert_ceqs_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_dbd_id       varchar2,
                                    pc_user_id      varchar2);
end;
/
create or replace package body pkg_phy_pre_check_process is

  procedure sp_pre_check
  --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_pre_check
    --        author                                    : janna
    --        created date                              : 20th jan 2009
    --        purpose                                   : calls all precheck packages
    --
    --        parameters
    --        pc_corporate_id                           : corporate id
    --        pd_trade_date                             : trade date
    --        pc_user_id                                : user id
    --        pc_process                                : process eod or eom
    --
    --        modification history
    --        modified date                             :
    --        modified by                               :
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_process      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_logno           number := 0;
  begin
    gvc_process := pc_process;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    select max(to_number(dbd.dbd_id))
      into gvc_dbd_id
      from dbd_database_dump dbd
     where dbd.corporate_id = pc_corporate_id
       and dbd.process = pc_process
       and dbd.trade_date = pd_trade_date;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'inside sp_pre_check process !!!!');
  
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'sp_pre_check_m2m_values');
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    sp_pre_check_m2m_values(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            pc_user_id,
                            pc_process);
  
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'sp_pre_check_physicals');
    --***
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    sp_pre_check_m2m_conc_values(pc_corporate_id,
                                 pd_trade_date,
                                 gvc_dbd_id,
                                 pc_user_id,
                                 pc_process);
  
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'sp_pre_check_physicals_concen');
    --**                            
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    sp_pre_check_physicals(pc_corporate_id,
                           pd_trade_date,
                           pc_user_id,
                           pc_process);
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'sp_phy_insert_ceqs_data');
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    sp_phy_insert_ceqs_data(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            pc_user_id);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'sp_pre_check_rebuild_stats');
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
    sp_pre_check_rebuild_stats;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'Precheck Completed Successfully...!!!!!!');
    <<cancel_process>>
    dbms_output.put_line('EOD/EOM Process Cancelled while pnl calculation');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_pre_check',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           gvc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_pre_check_physicals(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2,
                                   pc_process      varchar2) is
    pragma autonomous_transaction;
    /*******************************************************************************************************************************************
    procedure name                            : sp_pre_check_physicals
    author                                    : janna
    created date                              : 12th jan 2009
    purpose                                   : pre check for physical trades
    
    parameters
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_user_id                                : user id
    pc_process                                : process
    
    modification history
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    --vn_forward_exch_rate number := 1;
    --vn_forward_points    number := 0.01;
    --vc_str_cipd          varchar2(4000);
    --vc_str_spot          varchar2(4000);
    --vc_str_m2m           varchar2(4000);
    -- vc_str_corp          varchar2(4000);
    --vn_max_deviation     number;
    --vc_err_code          varchar2(15);
    /*cursor cur_cfq is
    select distinct vw_ccy.main_cur_id contract_cur_id,
                    tmpc.valuation_cur_id,
                    tmpc.shipment_date,
                    akc.base_cur_id base_currency_id,
                    tmpc.valuation_date,
                    tmpc.valuation_dr_id,
                    drm.main_cur_id cur_id,
                    drm.main_cur_code cur_code,
                    akc.base_currency_name,
                    vw_ccy.main_cur_code con_ccy_code,
                    cm_valuation_ccy.cur_code val_ccy_code
      from tmpc_temp_m2m_pre_check tmpc,
           ak_corporate akc,
           (select drm.dr_id,
                   ppu.cur_id,
                   cm.cur_code,
                   vw_ccy.main_cur_id,
                   vw_ccy.main_cur_code
              from drm_derivative_master        drm,
                   div_der_instrument_valuation div,
                   pum_price_unit_master        ppu,
                   cm_currency_master           cm,
                   vw_sub_main_currency         vw_ccy
             where drm.instrument_id = div.instrument_id
               and div.price_unit_id = ppu.price_unit_id
               and ppu.cur_id = cm.cur_id
               and div.is_deleted = 'N'
               and vw_ccy.sub_cur_id = cm.cur_id) drm,
           cm_currency_master cm_valuation_ccy,
           vw_sub_main_currency vw_ccy
     where tmpc.corporate_id = akc.corporate_id
       and drm.dr_id(+) = tmpc.valuation_dr_id
       and tmpc.section_name = 'OPEN'
       and tmpc.valuation_cur_id = cm_valuation_ccy.cur_id
       and vw_ccy.sub_cur_id = tmpc.contract_cur_id
       and tmpc.corporate_id = pc_corporate_id;*/
    /*cursor cur_cfq_stock is
    select distinct vw_ccy.main_cur_id contract_cur_id,
                    tmpc.valuation_cur_id,
                    akc.base_cur_id base_currency_id,
                    tmpc.valuation_dr_id,
                    drm.main_cur_id cur_id,
                    drm.main_cur_code cur_code,
                    akc.base_currency_name,
                    cm_valuation_ccy.cur_code val_ccy_code,
                    vw_ccy.main_cur_code con_ccy_code
      from tmpc_temp_m2m_pre_check tmpc,
           ak_corporate akc,
           (select drm.dr_id,
                   ppu.cur_id,
                   cm.cur_code,
                   vw_ccy.main_cur_id,
                   vw_ccy.main_cur_code
              from drm_derivative_master        drm,
                   div_der_instrument_valuation div,
                   pum_price_unit_master        ppu,
                   cm_currency_master           cm,
                   vw_sub_main_currency         vw_ccy
             where drm.instrument_id = div.instrument_id
               and div.price_unit_id = ppu.price_unit_id
               and ppu.cur_id = cm.cur_id
               and vw_ccy.sub_cur_id = cm.cur_id) drm,
           cm_currency_master cm_valuation_ccy,
           vw_sub_main_currency vw_ccy
     where tmpc.corporate_id = akc.corporate_id
       and drm.dr_id(+) = tmpc.valuation_dr_id
       and tmpc.section_name <> 'OPEN'
       and tmpc.valuation_cur_id = cm_valuation_ccy.cur_id
       and vw_ccy.sub_cur_id =
           decode(tmpc.is_purchase_cma,
                  'Y',
                  akc.base_cur_id,
                  tmpc.contract_cur_id)
       and tmpc.corporate_id = pc_corporate_id;*/
  begin
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck Physical',
                 'in physicals');
    /*-- precheck for risk limit by trader limits
    
    INSERT INTO eel_eod_eom_exception_log eel
        (corporate_id,
         submodule_name,
         exception_code,
         data_missing_for,
         trade_ref_no,
         process,
         process_run_date,
         process_run_by,
         dr_id,
         trade_date)
        SELECT pc_corporate_id,
               'Physicals Pre-Check',
               'PHY-010',
               t.tradername || ', ' || cpc.profit_center_name || '-' ||
               pdm.product_desc,
               '' trade_ref_no,
               gvc_process,
               systimestamp,
               pc_process,
               NULL AS dr_id,
               pd_trade_date
        FROM   trl_trader_risk_limits trl,
               cpc_corporate_profit_center cpc,
               pdm_productmaster pdm,
               (SELECT DISTINCT trl_inner.trader_user_id,
                                gab.firstname || ' ' || gab.lastname tradername
                FROM   trl_trader_risk_limits     trl_inner,
                       pcm_physical_contract_main pcm,
                       pci_physical_contract_item pci,
                       ak_corporate_user          aku,
                       gab_globaladdressbook      gab
                WHERE  trl_inner.trader_user_id = pcm.trader_user_id
                AND    pcm.internal_contract_ref_no =
                       pci.internal_contract_ref_no
                AND    trl_inner.product_id = pci.product_id
                AND    trl_inner.profit_center_id = pcm.profit_center_id
                AND    pci.is_active = 'Y'
                AND    aku.gabid = gab.gabid
                AND    aku.user_id = trl_inner.trader_user_id
                AND    trl_inner.dbd_id = gvc_dbd_id) t
        WHERE  trl.qty_exposure_limit IS NULL
        OR     trl.m2m_exposure_limit IS NULL
        OR     trl.credit_exposure_limit IS NULL
        OR     trl.value_exposure_limit IS NULL
        AND    trl.profit_center_id = cpc.profit_center_id
        AND    trl.product_id = pdm.product_id
        AND    trl.trader_user_id = t.trader_user_id
        AND    trl.dbd_id = gvc_dbd_id;
    INSERT INTO eel_eod_eom_exception_log eel
        (corporate_id,
         submodule_name,
         exception_code,
         data_missing_for,
         trade_ref_no,
         process,
         process_run_date,
         process_run_by,
         dr_id,
         trade_date)
        (SELECT pc_corporate_id,
                'Physicals Pre-Check',
                'PHY-008',
                cym.country_name || ', ' || ', Purchase' || '-' ||
                pdm.product_desc,
                '' trade_ref_no,
                gvc_process,
                systimestamp,
                pc_process,
                NULL AS dr_id,
                pd_trade_date
         FROM   ces_country_exposure_summary ces,
                pdm_productmaster            pdm,
                cym_countrymaster            cym
         WHERE  ces.product_id = pdm.product_id
         AND    pdm.is_active = 'Y'
         AND    ces.country_id = cym.country_id
         AND    ces.contract_type = 'P'
         AND    (ces.qty_exposure_limit IS NULL OR
               ces.m2m_exposure_limit IS NULL OR
               ces.value_exposure_limit IS NULL)
         AND    ces.dbd_id = gvc_dbd_id
         UNION ALL
         SELECT pc_corporate_id,
                'Physicals Pre-Check',
                'PHY-008',
                cym.country_name || ', ' || ', Sales' || '-' ||
                pdm.product_desc,
                '' trade_ref_no,
                gvc_process,
                systimestamp,
                pc_process,
                NULL AS dr_id,
                pd_trade_date
         FROM   ces_country_exposure_summary ces,
                pdm_productmaster            pdm,
                cym_countrymaster            cym
         WHERE  ces.product_id = pdm.product_id
         AND    pdm.is_active = 'Y'
         AND    ces.country_id = cym.country_id
         AND    ces.contract_type = 'S'
         AND    (ces.qty_exposure_limit IS NULL OR
               ces.m2m_exposure_limit IS NULL OR
               ces.value_exposure_limit IS NULL OR
               ces.credit_exposure_limit IS NULL)
         AND    ces.dbd_id = gvc_dbd_id);
    SELECT ep.param_value
    INTO   vn_max_deviation
    FROM   ep_eod_parameters ep
    WHERE  ep.corporate_id = pc_corporate_id
    AND    ep.param_name = 'Max_Deviation';
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck Physical',
                 'Befor cfq loop');*/
    -- for cur_cfq_rows in cur_cfq
    --   loop
    --sp_write_log(pc_corporate_id,pd_trade_date,'sp_pre-check','in cv loop'||cur_cfq_rows.shipment_date||cur_cfq_rows.contract_cur_id||cur_cfq_rows.valuation_cur_id);
    /*if vc_str_cipd is null or
       instr(vc_str_cipd,
             cur_cfq_rows.contract_cur_id || cur_cfq_rows.valuation_cur_id ||
             cur_cfq_rows.shipment_date) <= 0 then
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'Precheck Physical',
                   'before forward' || cur_cfq_rows.contract_cur_id ||
                   cur_cfq_rows.valuation_cur_id ||
                   cur_cfq_rows.shipment_date);
      --use spot if the date is todays date
      if cur_cfq_rows.shipment_date = pd_trade_date then
        vn_forward_exch_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                         cur_cfq_rows.contract_cur_id,
                                                                         cur_cfq_rows.valuation_cur_id,
                                                                         pd_trade_date,
                                                                         1);
        vn_forward_points    := 0;
        vc_err_code          := 'PHY-010';
      else
        vn_forward_exch_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                         cur_cfq_rows.contract_cur_id,
                                                                         cur_cfq_rows.valuation_cur_id,
                                                                         cur_cfq_rows.shipment_date,
                                                                         1);
        vn_forward_points    := 0;
      
        vc_err_code := 'PHY-005';
      end if;
      if vn_forward_exch_rate = 0 then
        insert into eel_eod_eom_exception_log eel
          (corporate_id,
           submodule_name,
           exception_code,
           data_missing_for,
           trade_ref_no,
           process,
           process_run_date,
           process_run_by,
           dr_id,
           trade_date)
        values
          (pc_corporate_id,
           'Physicals Pre-Check',
           vc_err_code,
           cur_cfq_rows.con_ccy_code || ' / ' ||
           cur_cfq_rows.val_ccy_code || ' ' || cur_cfq_rows.shipment_date,
           null,
           pc_process,
           systimestamp,
           pc_user_id,
           null,
           pd_trade_date);
      else
        insert into tmef_temp_eod_fx_rate
          (corporate_id,
           trade_date,
           maturity_date,
           from_cur_id,
           to_cur_id,
           max_deviation,
           cur_fx_rate,
           forward_points,
           currency_type,
           section_type)
        values
          (pc_corporate_id,
           pd_trade_date,
           cur_cfq_rows.shipment_date,
           cur_cfq_rows.contract_cur_id,
           cur_cfq_rows.valuation_cur_id,
           vn_max_deviation,
           vn_forward_exch_rate,
           0,
           'CV',
           'OPEN');
        vc_str_cipd := vc_str_cipd || cur_cfq_rows.contract_cur_id ||
                       cur_cfq_rows.valuation_cur_id ||
                       cur_cfq_rows.shipment_date;
      end if;
    end if;*/
    /*if vc_str_spot is null or
       instr(vc_str_spot,
             cur_cfq_rows.base_currency_id ||
             cur_cfq_rows.valuation_cur_id || pd_trade_date) <= 0 then
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'Precheck Physical',
                   'Before spot' || cur_cfq_rows.base_currency_id ||
                   cur_cfq_rows.valuation_cur_id);
      pkg_general.sp_spot_cur_exchange_rate(pc_corporate_id,
                                            pd_trade_date,
                                            cur_cfq_rows.base_currency_id,
                                            cur_cfq_rows.valuation_cur_id,
                                            vn_forward_exch_rate,
                                            vn_forward_points);
      if vn_forward_exch_rate = 0 then
        insert into eel_eod_eom_exception_log eel
          (corporate_id,
           submodule_name,
           exception_code,
           data_missing_for,
           trade_ref_no,
           process,
           process_run_date,
           process_run_by,
           dr_id,
           trade_date)
        values
          (pc_corporate_id,
           'Physicals Pre-Check',
           'PHY-010',
           cur_cfq_rows.base_currency_name || ' / ' ||
           cur_cfq_rows.val_ccy_code || ' ' || pd_trade_date,
           null,
           pc_process,
           systimestamp,
           pc_user_id,
           null,
           pd_trade_date);
      else
        insert into tmef_temp_eod_fx_rate
          (corporate_id,
           trade_date,
           maturity_date,
           from_cur_id,
           to_cur_id,
           max_deviation,
           cur_fx_rate,
           forward_points,
           currency_type,
           section_type)
        values
          (pc_corporate_id,
           pd_trade_date,
           pd_trade_date,
           cur_cfq_rows.base_currency_id,
           cur_cfq_rows.valuation_cur_id,
           vn_max_deviation,
           vn_forward_exch_rate,
           0,
           'SPOT',
           'OPEN');
        vc_str_spot := vc_str_spot || cur_cfq_rows.base_currency_id ||
                       cur_cfq_rows.valuation_cur_id || pd_trade_date;
      end if;
    end if;*/
    /*if vc_str_corp is null or
       instr(vc_str_corp,
             cur_cfq_rows.valuation_cur_id ||
             cur_cfq_rows.base_currency_id || pd_trade_date) <= 0 then
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'Precheck Physical',
                   'Before corp' || cur_cfq_rows.valuation_cur_id ||
                   cur_cfq_rows.base_currency_id);
      vn_forward_exch_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                       cur_cfq_rows.valuation_cur_id,
                                                                       cur_cfq_rows.base_currency_id,
                                                                       pd_trade_date,
                                                                       1);
      if vn_forward_exch_rate = 0 then
        insert into eel_eod_eom_exception_log eel
          (corporate_id,
           submodule_name,
           exception_code,
           data_missing_for,
           trade_ref_no,
           process,
           process_run_date,
           process_run_by,
           dr_id,
           trade_date)
        values
          (pc_corporate_id,
           'Physicals Pre-Check',
           'PHY-003',
           cur_cfq_rows.val_ccy_code || ' / ' ||
           cur_cfq_rows.base_currency_name || ' ' || pd_trade_date,
           null,
           pc_process,
           systimestamp,
           pc_user_id,
           null,
           pd_trade_date);
      else
        insert into tmef_temp_eod_fx_rate
          (corporate_id,
           trade_date,
           maturity_date,
           from_cur_id,
           to_cur_id,
           max_deviation,
           cur_fx_rate,
           forward_points,
           currency_type,
           section_type)
        values
          (pc_corporate_id,
           pd_trade_date,
           pd_trade_date,
           cur_cfq_rows.valuation_cur_id,
           cur_cfq_rows.base_currency_id,
           vn_max_deviation,
           vn_forward_exch_rate,
           0,
           'CORP',
           'OPEN');
        vc_str_corp := vc_str_corp || cur_cfq_rows.valuation_cur_id ||
                       cur_cfq_rows.base_currency_id || pd_trade_date;
      end if;
    end if;*/
    /*if cur_cfq_rows.valuation_dr_id is not null then
      if vc_str_m2m is null or
         instr(vc_str_m2m,
               cur_cfq_rows.cur_id || cur_cfq_rows.valuation_cur_id ||
               cur_cfq_rows.valuation_date) <= 0 then
        sp_write_log(pc_corporate_id,
                     pd_trade_date,
                     'Precheck Physical',
                     'before mv' || cur_cfq_rows.cur_id ||
                     cur_cfq_rows.valuation_cur_id ||
                     cur_cfq_rows.valuation_date);
        if cur_cfq_rows.valuation_date = pd_trade_date then
          pkg_general.sp_spot_cur_exchange_rate(pc_corporate_id,
                                                pd_trade_date,
                                                cur_cfq_rows.cur_id,
                                                cur_cfq_rows.valuation_cur_id,
                                                vn_forward_exch_rate,
                                                vn_forward_points);
          vc_err_code := 'PHY-010';
        else
          pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                  pd_trade_date,
                                                  cur_cfq_rows.valuation_date,
                                                  cur_cfq_rows.cur_id,
                                                  cur_cfq_rows.valuation_cur_id,
                                                  vn_max_deviation,
                                                  vn_forward_exch_rate,
                                                  vn_forward_points);
          vc_err_code := 'PHY-005';
        end if;
        if vn_forward_exch_rate = 0 then
          insert into eel_eod_eom_exception_log eel
            (corporate_id,
             submodule_name,
             exception_code,
             data_missing_for,
             trade_ref_no,
             process,
             process_run_date,
             process_run_by,
             dr_id,
             trade_date)
          values
            (pc_corporate_id,
             'Physicals Pre-Check',
             vc_err_code,
             cur_cfq_rows.cur_code || ' / ' || cur_cfq_rows.val_ccy_code || ' ' ||
             cur_cfq_rows.valuation_date,
             null,
             pc_process,
             systimestamp,
             pc_user_id,
             null,
             pd_trade_date);
        else
          insert into tmef_temp_eod_fx_rate
            (corporate_id,
             trade_date,
             maturity_date,
             from_cur_id,
             to_cur_id,
             max_deviation,
             cur_fx_rate,
             forward_points,
             currency_type,
             section_type)
          values
            (pc_corporate_id,
             pd_trade_date,
             cur_cfq_rows.valuation_date,
             cur_cfq_rows.cur_id,
             cur_cfq_rows.valuation_cur_id,
             vn_max_deviation,
             vn_forward_exch_rate,
             0,
             'MV',
             'OPEN');
          vc_str_m2m := vc_str_m2m || cur_cfq_rows.cur_id ||
                        cur_cfq_rows.valuation_cur_id ||
                        cur_cfq_rows.valuation_date;
        end if;
      end if;
    end if;*/
    --  null;
    -- end loop;
    --vc_str_m2m  := null;
    --vc_str_spot := null;
    --vc_str_corp := null;
    --vc_str_cipd := null;
  
    commit;
  exception
    when others then
      rollback;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'Precheck Physical',
                   'error');
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_pre_check_physicals',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_pre_check_m2m_values(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_dbd_id       varchar2,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    procedure name                            : sp_pre_check_m2m_values
    author                                    : siva
    created date                              : 17th jan 2009
    purpose                                   : pre check for physicals m2m data
    parameters
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_user_id                                : user id
    pc_process                                : process
    modification history
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    vobj_error_log      tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count  number := 1;
    vc_drid             varchar2(15);
    vn_qty_premimum_amt number(10);
    vn_pp_amt           number(10);
    vc_error_loc        varchar2(100);
  begin
    dbms_mview.refresh('MV_QAT_QUALITY_VALUATION', 'C');
    --added newly to maintain consistency in both physical process and precheck. 28th
    delete from tmpc_temp_m2m_pre_check tmpc
     where corporate_id = pc_corporate_id
       and tmpc.product_type = 'BASEMETAL';
    vc_error_loc := 1;
    /*    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - Before Insert TMEFH @' || systimestamp);
    insert into tmefh_temp_eod_fx_rate_hist
      select tmef.*,
             gvc_dbd_id,
             pc_process
        from tmef_temp_eod_fx_rate tmef;*/
    /*  sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - Before Delete TMEF @' || systimestamp);
    delete from tmef_temp_eod_fx_rate where corporate_id = pc_corporate_id;
    dbms_output.put_line('before inserting into tmpc_temp_m2m_pre_check');*/
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - Before Insert TMPC @' || systimestamp);
    ---check the valuation point for open contracts
    insert into eel_eod_eom_exception_log
      (corporate_id,
       submodule_name,
       exception_code,
       data_missing_for,
       trade_ref_no,
       process,
       process_run_date,
       process_run_by,
       trade_date)
      select t.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-015',
             t.valuation_point,
             substr(f_string_aggregate(t.contract_ref_no), 1, 1000),
             pc_process,
             systimestamp,
             pc_user_id,
             pd_trade_date
        from (select pcm.corporate_id,
                     pcm.contract_ref_no,
                     pdm.product_desc || ',' || cim.city_name || ',' ||
                     cym.country_name valuation_point
                from pci_physical_contract_item pci,
                     pcdi_pc_delivery_item      pcdi,
                     pcm_physical_contract_main pcm,
                     pcpd_pc_product_definition pcpd,
                     pdm_productmaster          pdm,
                     cym_countrymaster          cym,
                     cim_citymaster             cim
               where pci.dbd_id = pc_dbd_id
                 and pci.is_active = 'Y'
                 and pcm.contract_status = 'In Position'
                 and pcm.contract_type = 'BASEMETAL'
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpd.dbd_id = pci.dbd_id
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pci.dbd_id = pcdi.dbd_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcdi.is_active = 'Y'
                 and pcm.issue_date <= pd_trade_date
                 and pcpd.product_id = pdm.product_id
                 and pci.m2m_city_id = cim.city_id
                 and cim.country_id = cym.country_id
                 and not exists
               (select mvp.valuation_point
                        from mvp_m2m_valuation_point      mvp,
                             mvpl_m2m_valuation_point_loc mvpl
                       where mvp.corporate_id = pcm.corporate_id
                         and mvp.product_id = pdm.product_id
                         and mvpl.loc_city_id = pci.m2m_city_id
                         and mvp.mvp_id = mvpl.mvp_id)) t
       group by t.corporate_id,
                t.valuation_point;
    vc_error_loc := 2;
    ---check the valuation point for Stock/GMR
    insert into eel_eod_eom_exception_log
      (corporate_id,
       submodule_name,
       exception_code,
       data_missing_for,
       trade_ref_no,
       process,
       process_run_date,
       process_run_by,
       trade_date)
      select tt.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-015',
             pdm.product_desc || ',' || cim.city_name || ',' ||
             cym.country_name valuation_point,
             substr(f_string_aggregate(tt.contract_ref_no), 1, 1000),
             pc_process,
             sysdate,
             pc_user_id,
             pd_trade_date
        from (select t.corporate_id,
                     t.contract_ref_no,
                     t.product_id,
                     t. city_id,
                     t. quality_id
                from (select pcm.corporate_id,
                             pcm.contract_ref_no,
                             grd.product_id,
                             case
                               when grd.is_afloat = 'Y' then
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                               else
                                shm.city_id
                             end city_id,
                             grd.quality_id quality_id
                        from grd_goods_record_detail     grd,
                             gmr_goods_movement_record   gmr,
                             pci_physical_contract_item  pci,
                             pcm_physical_contract_main  pcm,
                             pcdi_pc_delivery_item       pcdi,
                             sld_storage_location_detail shm
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and grd.internal_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pci.pcdi_id = pcdi.pcdi_id
                         and pcdi.internal_contract_ref_no =
                             pcm.internal_contract_ref_no
                         and pcm.contract_type = 'BASEMETAL'
                         and grd.shed_id = shm.storage_loc_id(+)
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and nvl(grd.inventory_status, 'NA') <> 'Out'
                         and pcm.purchase_sales = 'P'
                      union all
                      select pcm.corporate_id,
                             pcm.contract_ref_no,
                             dgrd.product_id,
                             case
                               when nvl(dgrd.stock_status, 'N') =
                                    'For Invoicing' then
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                               else
                                case
                               when nvl(dgrd.is_afloat, 'N') = 'N' then
                                shm.city_id
                             end end city_id,
                             dgrd.quality_id
                        from gmr_goods_movement_record   gmr,
                             pci_physical_contract_item  pci,
                             pcm_physical_contract_main  pcm,
                             pcdi_pc_delivery_item       pcdi,
                             gsm_gmr_stauts_master       gsm,
                             agh_alloc_group_header      agh,
                             sld_storage_location_detail shm,
                             dgrd_delivered_grd          dgrd
                       where gmr.internal_contract_ref_no =
                             pcm.internal_contract_ref_no(+)
                         and pcm.internal_contract_ref_no =
                             pcdi.internal_contract_ref_no
                         and pcm.contract_type = 'BASEMETAL'
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.is_deleted = 'N'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and dgrd.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.status_id = gsm.status_id
                         and agh.is_deleted = 'N'
                         and upper(agh.realized_status) in
                             ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED',
                              'REVERSEUNDERCMA')
                         and dgrd.status = 'Active'
                         and dgrd.net_weight > 0) t
               where not exists (select mvp.valuation_point
                        from mvp_m2m_valuation_point      mvp,
                             mvpl_m2m_valuation_point_loc mvpl
                       where mvp.corporate_id = t.corporate_id
                         and mvp.product_id = t.product_id
                         and mvpl.loc_city_id = t.city_id
                         and mvp.mvp_id = mvpl.mvp_id)) tt,
             cim_citymaster cim,
             cym_countrymaster cym,
             pdm_productmaster pdm
       where tt.product_id = pdm.product_id
         and tt.city_id = cim.city_id
         and cim.country_id = cym.country_id
       group by tt.corporate_id,
                pdm.product_desc || ',' || cim.city_name || ',' ||
                cym.country_name;
    vc_error_loc := 3;
    ---insert into tmpc for the OPEN Contract
    insert into tmpc_temp_m2m_pre_check
      (corporate_id,
       product_id,
       quality_id,
       mvp_id,
       mvpl_id,
       valuation_region,
       valuation_point,
       valuation_incoterm_id,
       valuation_city_id,
       valuation_basis,
       reference_incoterm,
       refernce_location,
       pcdi_id,
       internal_contract_item_ref_no,
       contract_ref_no,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       section_name,
       value_type,
       derivative_def_id,
       instrument_id,
       m2m_price_unit_id,
       shipment_month,
       shipment_year,
       shipment_date,
       internal_m2m_id,
       product_type)
      (select pcm.corporate_id corporate_id,
              mv_qat.product_id product_id,
              mv_qat.quality_id quality_id,
              mvp.mvp_id mvp_id,
              mvpl.mvpl_id mvpl_id,
              mvp.valuation_region valuation_region,
              mvp.valuation_point valuation_point,
              pci.m2m_inco_term valuation_incoterm_id,
              pci.m2m_city_id valuation_city_id,
              mvp.valuation_basis valuationn_basics,
              mvp.valuation_incoterm_id reference_incoterm,
              mvp.benchmark_city_id refernce_location,
              pci.pcdi_id pcdi_id,
              pci.internal_contract_item_ref_no internal_contract_item_ref_no,
              pcm.contract_ref_no contract_ref_no,
              null internal_gmr_ref_no,
              null internal_grd_ref_no,
              'OPEN' section_name,
              mv_qat.eval_basis value_type,
              mv_qat.derivative_def_id derivative_def_id,
              mv_qat.instrument_id instrument_id,
              vdip.price_unit_id m2m_price_unit_id, --DIV
              pci.expected_delivery_month shipment_month,
              pci.expected_delivery_year shipment_year,
              to_date(('01-' || pci.expected_delivery_month || '-' ||
                      pci.expected_delivery_year),
                      'dd-Mon-yyyy') shipment_date,
              '' internal_m2m_id,
              'BASEMETAL'
         from pcm_physical_contract_main    pcm,
              pci_physical_contract_item    pci,
              pcpq_pc_product_quality       pcpq,
              pcdi_pc_delivery_item         pcdi,
              ciqs_contract_item_qty_status ciqs,
              mvp_m2m_valuation_point       mvp,
              mvpl_m2m_valuation_point_loc  mvpl,
              mv_qat_quality_valuation      mv_qat,
              v_derivatives_val_month       vdvm,
              v_der_instrument_price_unit   vdip
        where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
          and pcm.contract_type = 'BASEMETAL'
          and pcdi.pcdi_id = pci.pcdi_id
          and pci.internal_contract_item_ref_no =
              ciqs.internal_contract_item_ref_no(+)
          and pci.pcpq_id = pcpq.pcpq_id
          and pcm.corporate_id = pc_corporate_id
          and mv_qat.corporate_id = pcm.corporate_id
          and pcm.issue_date <= pd_trade_date
          and pcm.contract_status in ('In Position', 'Pending Approval')
          and pcm.corporate_id = mvp.corporate_id
          and mv_qat.product_id = mvp.product_id(+)
          and mvp.mvp_id = mvpl.mvp_id(+)
          and mvpl.loc_city_id = pci.m2m_city_id
          and pci.internal_contract_item_ref_no =
              vdvm.internal_contract_item_ref_no(+)
          and pcpq.quality_template_id = mv_qat.quality_id
          and mv_qat.instrument_id = vdip.instrument_id(+)
          and ciqs.open_qty <> 0
          and pci.is_active = 'Y'
          and ciqs.is_active = 'Y'
          and pcm.is_active = 'Y'
          and pci.is_active = 'Y'
          and pcm.dbd_id = pc_dbd_id
          and pcdi.dbd_id = pc_dbd_id
          and pci.dbd_id = pc_dbd_id
          and ciqs.dbd_id = pc_dbd_id
          and pcpq.dbd_id = pc_dbd_id
          and pcm.contract_status <> 'Cancelled');
    dbms_output.put_line(sql%rowcount);
    ----end of populate  m2m cost for open contract    
    vc_error_loc := 4;
    insert into tmpc_temp_m2m_pre_check
      (corporate_id,
       product_id,
       quality_id,
       mvp_id,
       mvpl_id,
       valuation_region,
       valuation_point,
       valuation_incoterm_id,
       valuation_city_id,
       valuation_basis,
       reference_incoterm,
       refernce_location,
       pcdi_id,
       internal_contract_item_ref_no,
       contract_ref_no,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       section_name,
       value_type,
       derivative_def_id,
       instrument_id,
       m2m_price_unit_id,
       shipment_month,
       shipment_year,
       shipment_date,
       internal_m2m_id,
       product_type)
      select m2m.corporate_id,
             m2m.product_id,
             m2m.quality_id,
             m2m.mvp_id,
             m2m.mvpl_id,
             m2m.valuation_region,
             m2m.valuation_point,
             m2m.valuation_incoterm_id,
             m2m.valuation_city_id,
             m2m.valuation_basis,
             m2m.reference_incoterm,
             m2m.refernce_location,
             m2m.pcdi_id,
             m2m.internal_contract_item_ref_no,
             m2m. contract_ref_no,
             m2m.internal_gmr_ref_no,
             m2m.internal_grd_ref_no,
             m2m.section_name,
             m2m.value_type,
             m2m.derivative_def_id,
             m2m.instrument_id,
             m2m.valuation_price_unit_id,
             m2m.shipment_month,
             m2m.shipment_year,
             m2m.shipment_date,
             null internal_m2m_id,
             'BASEMETAL'
        from (select temp.corporate_id,
                     temp.product_id,
                     temp.quality_id,
                     mv_qat.eval_basis value_type,
                     mvp.mvp_id,
                     mvpl.mvpl_id,
                     mvp.valuation_region,
                     mvp.valuation_point,
                     case
                       when temp.section_name in ('Stock NTT', 'Stock TT') then
                        nvl(mvp.in_store_incoterm_id, temp.m2m_inco_term)
                       else
                        nvl(mvp.in_transit_incoterm_id, temp.m2m_inco_term)
                     end valuation_incoterm_id,
                     --temp.m2m_inco_term valuation_incoterm_id,
                     temp.city_id valuation_city_id,
                     mvp.valuation_basis,
                     mvp.valuation_incoterm_id reference_incoterm,
                     mvp.benchmark_city_id refernce_location,
                     temp.pcdi_id,
                     mv_qat.instrument_id,
                     mv_qat.derivative_def_id,
                     temp.internal_contract_item_ref_no,
                     temp.contract_ref_no,
                     temp.internal_gmr_ref_no,
                     temp.internal_grd_ref_no,
                     temp.section_name,
                     vdip.price_unit_id valuation_price_unit_id, -- from view
                     to_char(pd_trade_date, 'Mon') shipment_month,
                     to_char(pd_trade_date, 'yyyy') shipment_year,
                     pd_trade_date shipment_date
                from (select case
                               when nvl(grd.is_afloat, 'N') = 'Y' and
                                    nvl(grd.inventory_status, 'NA') in
                                    ('In', 'None', 'NA') then
                                'Shipped NTT'
                               when nvl(grd.is_afloat, 'N') = 'Y' and
                                    nvl(grd.inventory_status, 'NA') = 'Out' then
                                'Shipped TT'
                               when nvl(grd.is_afloat, 'N') = 'N' and
                                    nvl(grd.inventory_status, 'NA') in
                                    ('In', 'None', 'NA') then
                                'Stock NTT'
                               when nvl(grd.is_afloat, 'N') = 'N' and
                                    nvl(grd.inventory_status, 'NA') = 'Out' then
                                'Stock TT'
                               else
                                'Others'
                             end section_name,
                             pcm.corporate_id,
                             pci.internal_contract_item_ref_no,
                             pcm.internal_contract_ref_no,
                             gmr.internal_gmr_ref_no,
                             grd.internal_grd_ref_no,
                             pcm.contract_type,
                             pcm.contract_ref_no,
                             pcdi.pcdi_id,
                             case
                               when grd.is_afloat = 'Y' then
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                               else
                                shm.city_id
                             end city_id,
                             grd.product_id,
                             grd.quality_id quality_id,
                             pci.m2m_inco_term
                        from grd_goods_record_detail     grd,
                             gmr_goods_movement_record   gmr,
                             pci_physical_contract_item  pci,
                             pcm_physical_contract_main  pcm,
                             pcdi_pc_delivery_item       pcdi,
                             sld_storage_location_detail shm
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and grd.internal_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pci.pcdi_id = pcdi.pcdi_id
                         and pcdi.internal_contract_ref_no =
                             pcm.internal_contract_ref_no
                         and grd.shed_id = shm.storage_loc_id(+)
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                            --      and shm.is_deleted = 'N'
                            --   and shm.is_active = 'Y'
                         and nvl(grd.inventory_status, 'NA') <> 'Out'
                         and pcm.purchase_sales = 'P'
                         and pcm.contract_type = 'BASEMETAL'
                         and gmr.is_internal_movement = 'N'
                      union all
                      select case
                               when nvl(gmr.inventory_status, 'NA') =
                                    'Under CMA' then
                                'UnderCMA NTT'
                               when nvl(dgrd.is_afloat, 'N') = 'Y' and
                                    nvl(dgrd.inventory_status, 'NA') in
                                    ('In', 'None', 'NA') then
                                'Shipped NTT'
                               when nvl(dgrd.is_afloat, 'N') = 'Y' and
                                    nvl(dgrd.inventory_status, 'NA') = 'Out' then
                                'Shipped TT'
                               when nvl(dgrd.is_afloat, 'N') = 'N' and
                                    nvl(dgrd.inventory_status, 'NA') in
                                    ('In', 'None', 'NA') then
                                'Stock NTT'
                               when nvl(dgrd.is_afloat, 'N') = 'N' and
                                    nvl(dgrd.inventory_status, 'NA') = 'Out' then
                                'Stock TT'
                               else
                                'Others'
                             end section_name,
                             pcm.corporate_id,
                             pci.internal_contract_item_ref_no,
                             pcm.internal_contract_ref_no,
                             gmr.internal_gmr_ref_no,
                             dgrd.internal_dgrd_ref_no internal_grd_ref_no,
                             pcm.contract_type,
                             pcm.contract_ref_no,
                             pcdi.pcdi_id,
                             case
                               when nvl(dgrd.stock_status, 'N') =
                                    'For Invoicing' then
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                               else
                                case
                               when nvl(dgrd.is_afloat, 'N') = 'N' then
                                shm.city_id
                             end end city_id,
                             dgrd.product_id,
                             dgrd.quality_id,
                             pci.m2m_inco_term
                        from gmr_goods_movement_record   gmr,
                             pci_physical_contract_item  pci,
                             pcm_physical_contract_main  pcm,
                             pcdi_pc_delivery_item       pcdi,
                             gsm_gmr_stauts_master       gsm,
                             agh_alloc_group_header      agh,
                             sld_storage_location_detail shm,
                             dgrd_delivered_grd          dgrd
                       where gmr.internal_contract_ref_no =
                             pcm.internal_contract_ref_no(+)
                         and pcm.internal_contract_ref_no =
                             pcdi.internal_contract_ref_no
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and pcm.contract_type = 'BASEMETAL'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and dgrd.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.status_id = gsm.status_id
                         and agh.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                            --  and shm.is_active = 'Y'
                            --  and shm.is_deleted = 'N'
                         and upper(agh.realized_status) in
                             ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED',
                              'REVERSEUNDERCMA')
                         and dgrd.status = 'Active'
                         and dgrd.net_weight > 0
                         and gmr.is_internal_movement = 'N'
                      union all -- Internal movement
                      select case
                               when nvl(grd.is_afloat, 'N') = 'Y' and
                                    nvl(grd.inventory_status, 'NA') in
                                    ('In', 'None', 'NA') then
                                'Shipped NTT'
                               when nvl(grd.is_afloat, 'N') = 'Y' and
                                    nvl(grd.inventory_status, 'NA') = 'Out' then
                                'Shipped TT'
                               when nvl(grd.is_afloat, 'N') = 'N' and
                                    nvl(grd.inventory_status, 'NA') in
                                    ('In', 'None', 'NA') then
                                'Stock NTT'
                               when nvl(grd.is_afloat, 'N') = 'N' and
                                    nvl(grd.inventory_status, 'NA') = 'Out' then
                                'Stock TT'
                               else
                                'Others'
                             end section_name,
                             gmr.corporate_id,
                             null internal_contract_item_ref_no,
                             null internal_contract_ref_no,
                             gmr.internal_gmr_ref_no,
                             grd.internal_grd_ref_no,
                             null contract_type,
                             null contract_ref_no,
                             null pcdi_id,
                             case
                               when grd.is_afloat = 'Y' then
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                               else
                                shm.city_id
                             end city_id,
                             grd.product_id,
                             grd.quality_id quality_id,
                             null m2m_inco_term
                        from grd_goods_record_detail     grd,
                             gmr_goods_movement_record   gmr,
                             sld_storage_location_detail shm
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and gmr.is_internal_movement = 'Y'
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.shed_id = shm.storage_loc_id(+)
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and nvl(grd.inventory_status, 'NA') <> 'Out') temp,
                     mv_qat_quality_valuation mv_qat,
                     mvp_m2m_valuation_point mvp,
                     mvpl_m2m_valuation_point_loc mvpl,
                     v_der_instrument_price_unit vdip
               where temp.corporate_id = mv_qat.corporate_id
                 and temp.quality_id = mv_qat.quality_id
                 and mv_qat.instrument_id = vdip.instrument_id
                 and temp.corporate_id = mvp.corporate_id
                 and temp.product_id = mvp.product_id
                 and mvp.mvp_id = mvpl.mvp_id
                 and mvpl.loc_city_id = temp.city_id) m2m;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'finished inserting tmpc' || sql%rowcount);
    vc_error_loc := 5;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'start update tmpc shipment month year as per basis month');
    vc_error_loc := 6;
    --End of insert into tmpc for Stock
    --Updating tmpc table , setting the 
    --Shipment month and shipment year
    --to the basis month calculation for open contracts as per the quality setup and product rule 
    --do the update )
    for cc2 in (select t.pcdi_id,
                       t.internal_contract_ref_no,
                       t.internal_contract_item_ref_no,
                       t.basis_type,
                       t.transit_days,
                       t.contract_ref_no,
                       t.expected_delivery_month,
                       t.expected_delivery_year,
                       t.date_type,
                       t.ship_arrival_date,
                       t.ship_arrival_days,
                       t.expected_ship_arrival_date,
                       (case
                         when t.ship_arrival_date = 'Start Date' then
                          to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                   'Mon-yyyy'))
                         when t.ship_arrival_date = 'End Date' then
                          last_day(t.expected_ship_arrival_date)
                         else
                          (to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                    'Mon-yyyy')) +
                          trunc((last_day(t.expected_ship_arrival_date) -
                                 to_date('01-' ||
                                          to_char(t.expected_ship_arrival_date,
                                                  'Mon-yyyy'))) / 2))
                       end) + t.ship_arrival_days basis_month_year
                  from (select pcdi.pcdi_id,
                               pcdi.internal_contract_ref_no,
                               pci.internal_contract_item_ref_no,
                               pcdi.basis_type,
                               nvl(pcdi.transit_days, 0) transit_days,
                               pcm.contract_ref_no,
                               pci.expected_delivery_month,
                               pci.expected_delivery_year,
                               qat.date_type,
                               qat.ship_arrival_date,
                               nvl(qat.ship_arrival_days, 0) ship_arrival_days,
                               (case
                                  when qat.date_type = 'Shipment Date' then
                                   (case
                                  when pcdi.basis_type = 'Shipment' then
                                   last_day('01-' ||
                                            pci.expected_delivery_month || '-' ||
                                            pci.expected_delivery_year)
                                  else
                                   last_day('01-' ||
                                            pci.expected_delivery_month || '-' ||
                                            pci.expected_delivery_year) -
                                   nvl(pcdi.transit_days, 0)
                                end) else(case
                                 when pcdi.basis_type = 'Shipment' then
                                  last_day('01-' ||
                                           pci.expected_delivery_month || '-' ||
                                           pci.expected_delivery_year) +
                                  nvl(pcdi.transit_days, 0)
                                 else
                                  last_day('01-' ||
                                           pci.expected_delivery_month || '-' ||
                                           pci.expected_delivery_year)
                               end) end) expected_ship_arrival_date
                          from pcdi_pc_delivery_item      pcdi,
                               pci_physical_contract_item pci,
                               pcm_physical_contract_main pcm,
                               pcpq_pc_product_quality    pcpq,
                               qat_quality_attributes     qat
                         where pcdi.pcdi_id = pci.pcdi_id
                           and pcdi.internal_contract_ref_no =
                               pcm.internal_contract_ref_no
                           and pcm.contract_status = 'In Position'
                           and pcm.contract_type = 'BASEMETAL'
                           and pcm.corporate_id = pc_corporate_id
                           and pci.item_qty > 0
                           and pci.pcpq_id = pcpq.pcpq_id
                           and pcpq.quality_template_id = qat.quality_id
                           and pci.dbd_id = pc_dbd_id
                           and pcdi.dbd_id = pc_dbd_id
                           and pcm.dbd_id = pc_dbd_id
                           and pcpq.dbd_id = pc_dbd_id
                           and pcdi.is_active = 'Y'
                           and pci.is_active = 'Y'
                           and pcm.is_active = 'Y') t,
                       tmpc_temp_m2m_pre_check tmpc
                 where tmpc.section_name = 'OPEN'
                   and tmpc.corporate_id = pc_corporate_id
                   and tmpc.product_type = 'BASEMETAL'
                   and tmpc.internal_contract_item_ref_no =
                       t.internal_contract_item_ref_no
                   and tmpc.pcdi_id = t.pcdi_id)
    loop
    
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.shipment_month = to_char(cc2.basis_month_year, 'Mon'),
             tmpc.shipment_year  = to_char(cc2.basis_month_year, 'YYYY'),
             tmpc.shipment_date  = cc2.basis_month_year
       where tmpc.pcdi_id = cc2.pcdi_id
         and tmpc.internal_contract_item_ref_no =
             cc2.internal_contract_item_ref_no
         and tmpc.section_name = 'OPEN'
         and tmpc.product_type = 'BASEMETAL'
         and tmpc.corporate_id = pc_corporate_id;
    end loop;
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'start update tmpc shipment month year to trade date month for the expired');
    vc_error_loc := 7;
    --End of insert into tmpc for Stock
    --Updating tmpc table , setting the 
    --Shipment month and shipment year
    --to the eod month and year .(if shipment month ,year is less then the eod date month and year then 
    --do the update )
    for cc in (select tmpc.shipment_date,
                      tmpc.shipment_month,
                      tmpc.shipment_year
                 from tmpc_temp_m2m_pre_check tmpc
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.product_type = 'BASEMETAL'
                group by tmpc.shipment_date,
                         tmpc.shipment_month,
                         tmpc.shipment_year)
    loop
      if to_date('01-' || cc.shipment_month || '-' || cc.shipment_year,
                 'dd-Mon-YYYY') <
         to_date('01-' || to_char(pd_trade_date, 'Mon-yyyy'), 'dd-Mon-yyyy') then
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.shipment_month = to_char(pd_trade_date, 'Mon'),
               tmpc.shipment_year  = to_char(pd_trade_date, 'YYYY'),
               tmpc.shipment_date  = pd_trade_date
         where tmpc.shipment_month = cc.shipment_month
           and tmpc.shipment_year = cc.shipment_year
           and tmpc.product_type = 'BASEMETAL'
           and tmpc.shipment_date = cc.shipment_date;
      end if;
    end loop;
    --End of update
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'finished update tmpc' || sql%rowcount);
  
    vc_error_loc := 8;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'qpbm Fixed' || sql%rowcount);
    --Updating the tmpc table
    --By setting the valuatin_dr_id
    --It is checking for not Fixed contract
    --For this We are calling the  fn_get_val_drid
    for cc in (select tmpc.corporate_id,
                      tmpc.shipment_month,
                      tmpc.shipment_year,
                      tmpc.instrument_id,
                      decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') trade_type,
                      tmpc.quality_id,
                      qat.eval_basis,
                      qat.exch_valuation_month
                 from tmpc_temp_m2m_pre_check  tmpc,
                      mv_qat_quality_valuation qat
                where tmpc.quality_id = qat.quality_id
                  and tmpc.corporate_id = qat.corporate_id
                  and tmpc.corporate_id = pc_corporate_id
                  and tmpc.value_type <> 'FIXED'
                  and tmpc.product_type = 'BASEMETAL'
                group by tmpc.corporate_id,
                         tmpc.shipment_month,
                         tmpc.shipment_year,
                         tmpc.instrument_id,
                         decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK'),
                         tmpc.quality_id,
                         qat.eval_basis,
                         qat.exch_valuation_month)
    loop
      if cc.eval_basis <> 'FIXED' then
        vc_drid := fn_get_val_drid(pc_corporate_id,
                                   cc.instrument_id,
                                   cc.shipment_month,
                                   cc.shipment_year,
                                   cc.exch_valuation_month,
                                   pd_trade_date,
                                   cc.trade_type,
                                   pc_process);
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.valuation_dr_id = vc_drid
         where tmpc.instrument_id = cc.instrument_id
           and tmpc.shipment_month = cc.shipment_month
           and tmpc.shipment_year = cc.shipment_year
           and tmpc.quality_id = cc.quality_id
           and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
               cc.trade_type
           and tmpc.product_type = 'BASEMETAL'
           and tmpc.corporate_id = cc.corporate_id;
      end if;
    end loop;
    commit;
    --update the valuation month,year,prompt date
    for ccv in (select tmpc.corporate_id,
                       tmpc.valuation_dr_id,
                       nvl(drm.period_date, drm.prompt_date) period_date,
                       nvl(drm.period_month, to_char(drm.prompt_date, 'Mon')) period_month,
                       nvl(drm.period_year, to_char(drm.prompt_date, 'yyyy')) period_year,
                       drm.prompt_date
                  from tmpc_temp_m2m_pre_check tmpc,
                       drm_derivative_master   drm
                 where tmpc.corporate_id = pc_corporate_id
                   and tmpc.value_type <> 'FIXED'
                   and tmpc.product_type = 'BASEMETAL'
                   and tmpc.valuation_dr_id = drm.dr_id
                 group by tmpc.corporate_id,
                          drm.period_date,
                          tmpc.valuation_dr_id,
                          drm.period_month,
                          drm.period_year,
                          drm.prompt_date)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.valuation_month = ccv.period_month,
             tmpc.valuation_year  = ccv.period_year,
             tmpc.prompt_date     = ccv.prompt_date,
             tmpc.valuation_date  = ccv.period_date
       where tmpc.valuation_dr_id = ccv.valuation_dr_id
         and tmpc.product_type = 'BASEMETAL'
         and tmpc.corporate_id = ccv.corporate_id;
    end loop;
  
    commit;
    vc_error_loc := 9;
    -----    
    -- get the contract base price Unit id
    /* begin
      select product_price_unit_id
        into vn_contract_base_price_unit_id
        from v_ppu_pum pum
       where pum.cur_id = cur_pcdi_rows.invoice_currency_id
         and pum.weight_unit_id = cur_pcdi_rows.qty_unit_id
         and pum.product_id = cur_pcdi_rows.product_id;
    exception
      when no_data_found then
        vn_contract_base_price_unit_id := null;
    end;*/
    --- - 
    --Updating tmpc table and setting the 
    --base_price_unit_id_in_ppu.
    for cc in (select tmpc.corporate_id,
                      tmpc.product_id,
                      akc.base_cur_id,
                      pdm.base_quantity_unit,
                      ppu.internal_price_unit_id,
                      pum.price_unit_id
                 from tmpc_temp_m2m_pre_check tmpc,
                      ak_corporate            akc,
                      pdm_productmaster       pdm,
                      ppu_product_price_units ppu,
                      pum_price_unit_master   pum
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.corporate_id = akc.corporate_id
                  and tmpc.product_id = pdm.product_id
                  and tmpc.product_type = 'BASEMETAL'
                  and ppu.product_id = pdm.product_id
                  and ppu.is_active = 'Y'
                  and ppu.is_deleted = 'N'
                  and ppu.price_unit_id = pum.price_unit_id
                  and pum.cur_id = akc.base_cur_id
                  and pum.weight_unit_id = pdm.base_quantity_unit
                group by tmpc.corporate_id,
                         tmpc.product_id,
                         akc.base_cur_id,
                         pdm.base_quantity_unit,
                         ppu.internal_price_unit_id,
                         pum.price_unit_id)
    loop
    
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.base_price_unit_id_in_ppu = cc.internal_price_unit_id,
             tmpc.base_price_unit_id_in_pum = cc.price_unit_id
       where tmpc.product_type = 'BASEMETAL';
      commit;
    end loop;
    vc_error_loc := 10;
    --Checking for the Quality premimum is there or not
    --For this  we are calling the sp_calc_m2m_quality_premimum 
    for cc1 in (select tmpc.corporate_id,
                       tmpc.mvp_id,
                       tmpc.valuation_point,
                       tmpc.shipment_month,
                       tmpc.shipment_year,
                       tmpc.instrument_id,
                       tmpc.base_price_unit_id_in_ppu,
                       tmpc.quality_id,
                       tmpc.product_id,
                       pdm.product_desc,
                       qat.quality_name
                  from tmpc_temp_m2m_pre_check tmpc,
                       qat_quality_attributes  qat,
                       pdm_productmaster       pdm
                 where tmpc.corporate_id = pc_corporate_id
                   and tmpc.quality_id = qat.quality_id
                   and tmpc.product_type = 'BASEMETAL'
                   and tmpc.product_id = pdm.product_id
                 group by tmpc.corporate_id,
                          tmpc.mvp_id,
                          tmpc.valuation_point,
                          tmpc.shipment_month,
                          tmpc.shipment_year,
                          tmpc.instrument_id,
                          tmpc.base_price_unit_id_in_ppu,
                          tmpc.quality_id,
                          tmpc.product_id,
                          pdm.product_desc,
                          qat.quality_name)
    loop
      vn_qty_premimum_amt := 0;
      sp_calc_m2m_quality_premimum(pc_corporate_id,
                                   pd_trade_date,
                                   cc1.mvp_id,
                                   cc1.quality_id,
                                   cc1.product_id,
                                   cc1.base_price_unit_id_in_ppu,
                                   cc1.shipment_month,
                                   cc1.shipment_year,
                                   pc_user_id,
                                   pc_process,
                                   vn_qty_premimum_amt);
      --if  vn_qty_premimum_amt is zero or null we have to raise the exception
      --else not
      if vn_qty_premimum_amt is null then
        insert into eel_eod_eom_exception_log
          (corporate_id,
           submodule_name,
           exception_code,
           data_missing_for,
           trade_ref_no,
           process,
           process_run_date,
           process_run_by,
           trade_date)
        values
          (pc_corporate_id,
           'Physicals M2M Pre-Check',
           'PHY-101',
           --           'Quality Premimum for ',
           cc1.product_desc || ',' || cc1.quality_name || ',' ||
           cc1.valuation_point || ',' || cc1.shipment_month || '-' ||
           cc1.shipment_year,
           null,
           pc_process,
           sysdate,
           pc_user_id,
           pd_trade_date);
      end if;
    end loop;
    vc_error_loc := 11;
    --Check the product premimum
    --If Product premimum is not there we will rise the error
    --for this we are calling the sp_calc_product_premimum
    for cc in (select tmpc.corporate_id,
                      tmpc.product_id,
                      pdm.product_desc,
                      tmpc.base_price_unit_id_in_ppu,
                      tmpc.shipment_month,
                      tmpc.shipment_year
                 from tmpc_temp_m2m_pre_check tmpc,
                      pdm_productmaster       pdm
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.product_id = pdm.product_id
                  and tmpc.product_type = 'BASEMETAL'
                group by tmpc.corporate_id,
                         tmpc.product_id,
                         pdm.product_desc,
                         tmpc.base_price_unit_id_in_ppu,
                         tmpc.shipment_month,
                         tmpc.shipment_year)
    loop
      vn_pp_amt := 0;
      pkg_phy_pre_check_process.sp_calc_m2m_product_premimum(cc.corporate_id,
                                                             pd_trade_date,
                                                             cc.product_id,
                                                             cc.shipment_month,
                                                             cc.shipment_year,
                                                             pc_user_id,
                                                             pc_process,
                                                             cc.base_price_unit_id_in_ppu,
                                                             vn_pp_amt);
      if vn_pp_amt is null then
        insert into eel_eod_eom_exception_log
          (corporate_id,
           submodule_name,
           exception_code,
           data_missing_for,
           trade_ref_no,
           process,
           process_run_date,
           process_run_by,
           trade_date)
        values
          (pc_corporate_id,
           'Physicals M2M Pre-Check',
           'PHY-100',
           --  'Product Premimum for ',
           cc.product_desc || ',' || cc.shipment_month || '-' ||
           cc.shipment_year,
           null,
           pc_process,
           sysdate,
           pc_user_id,
           pd_trade_date);
      
      end if;
    end loop;
    vc_error_loc := 12;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - M2M-012 @' || systimestamp);
    insert into eel_eod_eom_exception_log
      (corporate_id,
       submodule_name,
       exception_code,
       data_missing_for,
       trade_ref_no,
       process,
       process_run_date,
       process_run_by,
       trade_date)
      select tmpc.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-012',
             'Settlement Price missing for ' || dim.instrument_name ||
             ',Price Source:' || ps.price_source_name || ',Price Unit:' ||
             pum.price_unit_name || ',' || apm.available_price_name ||
             ' Price,Prompt Date:' || drm.dr_id_name,
             null,
             pc_process,
             systimestamp,
             pc_user_id,
             pd_trade_date
        from tmpc_temp_m2m_pre_check      tmpc,
             div_der_instrument_valuation div,
             dim_der_instrument_master    dim,
             pdd_product_derivative_def   pdd,
             drm_derivative_master        drm,
             ps_price_source              ps,
             apm_available_price_master   apm,
             pum_price_unit_master        pum
       where tmpc.instrument_id = div.instrument_id
         and tmpc.product_id = pdd.product_id
         and div.instrument_id = drm.instrument_id
         and drm.instrument_id = dim.instrument_id
         and tmpc.corporate_id = pc_corporate_id
         and tmpc.valuation_dr_id = drm.dr_id
         and tmpc.product_type = 'BASEMETAL'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and tmpc.value_type <> 'FIXED'
         and div.is_deleted = 'N'
         and not exists
       (select 1
                from eodeom_derivative_quote_detail dqd
               where tmpc.valuation_dr_id = dqd.dr_id
                 and tmpc.product_type = 'BASEMETAL'
                 and div.available_price_id = dqd.available_price_id
                 and div.price_source_id = dqd.price_source_id
                 and div.price_unit_id = dqd.price_unit_id
                 and dqd.dq_trade_date = pd_trade_date
                 and dqd.corporate_id = pc_corporate_id
                 and dqd.dbd_id = gvc_dbd_id
                 and dqd.price is not null)
       group by tmpc.corporate_id,
                'Settlement Price missing for ' || dim.instrument_name ||
                ',Price Source:' || ps.price_source_name || ',Price Unit:' ||
                pum.price_unit_name || ',' || apm.available_price_name ||
                ' Price,Prompt Date:' || drm.dr_id_name;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'Settlement price' || sql%rowcount);
  
    -- settlement price missing for differential contract for price calcuation
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - M2M-012 Second @' || systimestamp);
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - M2M-010 @' || systimestamp);
  
    insert into eel_eod_eom_exception_log
      (corporate_id,
       submodule_name,
       exception_code,
       data_missing_for,
       trade_ref_no,
       process,
       process_run_date,
       process_run_by,
       trade_date)
      select tmpc.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-010',
             pdm.product_desc || ',' || tmpc.valuation_point || ',' ||
             qat.quality_name || ',' || itm.incoterm || ',' ||
             cim.city_name,
             f_string_aggregate(tmpc.contract_ref_no),
             pc_process,
             systimestamp,
             pc_user_id,
             pd_trade_date
        from tmpc_temp_m2m_pre_check tmpc,
             cim_citymaster          cim,
             itm_incoterm_master     itm,
             pdm_productmaster       pdm,
             qat_quality_attributes  qat
       where tmpc.corporate_id = pc_corporate_id
         and tmpc.valuation_city_id = cim.city_id(+)
         and tmpc.valuation_incoterm_id = itm.incoterm_id(+)
         and tmpc.product_id = pdm.product_id
         and tmpc.product_type = 'BASEMETAL'
         and tmpc.quality_id = qat.quality_id
         and not exists
       (select ldh.inco_term_id,
                     ldh.product_id,
                     ldh.valuation_city_id,
                     ldh.valuation_point_id
                from lds_location_diff_setup ldh,
                     ldc_location_diff_cost  ldc
               where ldh.loc_diff_id = ldc.loc_diff_id
                 and ldh.product_id = tmpc.product_id
                 and ldh.valuation_city_id = tmpc.valuation_city_id
                 and ldh.inco_term_id = tmpc.valuation_incoterm_id
                 and ldh.as_on_date <= pd_trade_date
                 and ldh.valuation_point_id = tmpc.mvp_id
                 and ldh.corporate_id = pc_corporate_id)
       group by tmpc.corporate_id,
                pdm.product_desc || ',' || tmpc.valuation_point || ',' ||
                qat.quality_name || ',' || itm.incoterm || ',' ||
                cim.city_name;
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'finished tmpc and i commit now');
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' Before Commit @' || systimestamp);
    commit;
  exception
    when others then
      dbms_output.put_line(sqlerrm);
      rollback;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'Precheck M2M',
                   'is it here ????');
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_pre_check_m2m_values',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;
  /*Start of Concentrate Precheck */
  procedure sp_pre_check_m2m_conc_values(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_dbd_id       varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    procedure name                            : sp_pre_check_m2m_values
    author                                    : siva
    created date                              : 17th jan 2009
    purpose                                   : pre check for physicals m2m data
    
    parameters
    pc_corporate_id                           : corporate id
    pd_trade_date                             : eod date id
    pc_user_id                                : user id
    pc_process                                : process
    
    modification history
    modified date                             :
    modified by                               :
    modify description                        :
    ******************************************************************************************************************************************/
    vobj_error_log          tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count      number := 1;
    vc_drid                 varchar2(15);
    vn_qty_premimum_amt     number(10);
    vn_pp_amt               number(10);
    vc_error_loc            varchar2(100);
    vc_treat_charge         varchar2(50);
    vc_refine_charge        varchar2(50);
    vc_penalty_charge       varchar2(50);
    pn_charge_amt           number;
    pc_charge_price_unit_id varchar2(20);
    vc_charge_type          varchar2(15);
    vc_m2m_id               varchar2(15);
  begin
    dbms_mview.refresh('MV_CONC_QAT_QUALITY_VALUATION', 'C');
    --added newly to maintain consistency in both physical process and precheck. 28th
    delete from tmpc_temp_m2m_pre_check tmpc
     where corporate_id = pc_corporate_id
       and tmpc.product_type = 'CONCENTRATES';
    vc_error_loc := 1;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - Before Insert TMPC @' || systimestamp);
    ---check the valuation point for open contracts for concentrates
    insert into eel_eod_eom_exception_log
      (corporate_id,
       submodule_name,
       exception_code,
       data_missing_for,
       trade_ref_no,
       process,
       process_run_date,
       process_run_by,
       trade_date)
      select t.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-015',
             t.valuation_point,
             substr(f_string_aggregate(t.contract_ref_no), 1, 1000),
             pc_process,
             systimestamp,
             pc_user_id,
             pd_trade_date
        from (select pcm.corporate_id,
                     pcm.contract_ref_no,
                     pdm.product_desc || ',' || cim.city_name || ',' ||
                     cym.country_name valuation_point
                from pci_physical_contract_item pci,
                     pcdi_pc_delivery_item      pcdi,
                     pcm_physical_contract_main pcm,
                     pcpd_pc_product_definition pcpd,
                     pdm_productmaster          pdm,
                     cym_countrymaster          cym,
                     cim_citymaster             cim
               where pci.dbd_id = pc_dbd_id
                 and pci.is_active = 'Y'
                 and pcm.contract_status = 'In Position'
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpd.dbd_id = pci.dbd_id
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pci.dbd_id = pcdi.dbd_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcdi.is_active = 'Y'
                 and pcm.issue_date <= pd_trade_date
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcpd.product_id = pdm.product_id
                 and pci.m2m_city_id = cim.city_id
                 and cim.country_id = cym.country_id
                 and not exists
               (select mvp.valuation_point
                        from mvp_m2m_valuation_point      mvp,
                             mvpl_m2m_valuation_point_loc mvpl
                       where mvp.corporate_id = pcm.corporate_id
                         and mvp.product_id = pdm.product_id
                         and mvpl.loc_city_id = pci.m2m_city_id
                         and mvp.mvp_id = mvpl.mvp_id)) t
       group by t.corporate_id,
                t.valuation_point;
    vc_error_loc := 2;
    ---check the valuation point for Stock/GMR for Concentrate
    insert into eel_eod_eom_exception_log
      (corporate_id,
       submodule_name,
       exception_code,
       data_missing_for,
       trade_ref_no,
       process,
       process_run_date,
       process_run_by,
       trade_date)
      select tt.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-015',
             pdm.product_desc || ',' || cim.city_name || ',' ||
             cym.country_name valuation_point,
             substr(f_string_aggregate(tt.contract_ref_no), 1, 1000),
             pc_process,
             sysdate,
             pc_user_id,
             pd_trade_date
        from (select t.corporate_id,
                     t.contract_ref_no,
                     t.product_id,
                     t. city_id,
                     t. quality_id
                from (select pcm.corporate_id,
                             pcm.contract_ref_no,
                             grd.product_id,
                             case
                               when grd.is_afloat = 'Y' then
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                               else
                                shm.city_id
                             end city_id,
                             grd.quality_id quality_id
                        from grd_goods_record_detail     grd,
                             gmr_goods_movement_record   gmr,
                             pci_physical_contract_item  pci,
                             pcm_physical_contract_main  pcm,
                             pcdi_pc_delivery_item       pcdi,
                             sld_storage_location_detail shm
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and grd.internal_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pci.pcdi_id = pcdi.pcdi_id
                         and pcdi.internal_contract_ref_no =
                             pcm.internal_contract_ref_no
                         and pcm.contract_type = 'CONCENTRATES'
                         and grd.shed_id = shm.storage_loc_id(+)
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and nvl(grd.inventory_status, 'NA') <> 'Out'
                         and pcm.purchase_sales = 'P'
                      union all
                      select pcm.corporate_id,
                             pcm.contract_ref_no,
                             dgrd.product_id,
                             case
                               when nvl(dgrd.stock_status, 'N') =
                                    'For Invoicing' then
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                               else
                                case
                               when nvl(dgrd.is_afloat, 'N') = 'N' then
                                shm.city_id
                             end end city_id,
                             dgrd.quality_id
                        from gmr_goods_movement_record   gmr,
                             pci_physical_contract_item  pci,
                             pcm_physical_contract_main  pcm,
                             pcdi_pc_delivery_item       pcdi,
                             gsm_gmr_stauts_master       gsm,
                             agh_alloc_group_header      agh,
                             sld_storage_location_detail shm,
                             dgrd_delivered_grd          dgrd
                       where gmr.internal_contract_ref_no =
                             pcm.internal_contract_ref_no(+)
                         and pcm.internal_contract_ref_no =
                             pcdi.internal_contract_ref_no
                         and pcm.contract_type = 'CONCENTRATES'
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.is_deleted = 'N'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and dgrd.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.status_id = gsm.status_id
                         and agh.is_deleted = 'N'
                         and upper(agh.realized_status) in
                             ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED',
                              'REVERSEUNDERCMA')
                         and dgrd.status = 'Active'
                         and dgrd.net_weight > 0) t
               where not exists (select mvp.valuation_point
                        from mvp_m2m_valuation_point      mvp,
                             mvpl_m2m_valuation_point_loc mvpl
                       where mvp.corporate_id = t.corporate_id
                         and mvp.product_id = t.product_id
                         and mvpl.loc_city_id = t.city_id
                         and mvp.mvp_id = mvpl.mvp_id)) tt,
             cim_citymaster cim,
             cym_countrymaster cym,
             pdm_productmaster pdm
       where tt.product_id = pdm.product_id
         and tt.city_id = cim.city_id
         and cim.country_id = cym.country_id
       group by tt.corporate_id,
                pdm.product_desc || ',' || cim.city_name || ',' ||
                cym.country_name;
    vc_error_loc := 3;
    ---insert into tmpc for the OPEN Contract
    insert into tmpc_temp_m2m_pre_check
      (corporate_id,
       conc_product_id,
       conc_quality_id,
       product_id,
       quality_id,
       mvp_id,
       mvpl_id,
       valuation_region,
       valuation_point,
       valuation_incoterm_id,
       valuation_city_id,
       valuation_basis,
       reference_incoterm,
       refernce_location,
       pcdi_id,
       internal_contract_item_ref_no,
       contract_ref_no,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       section_name,
       value_type,
       derivative_def_id,
       instrument_id,
       m2m_price_unit_id,
       shipment_month,
       shipment_year,
       shipment_date,
       internal_m2m_id,
       assay_header_id,
       element_id,
       element_name,
       product_type)
      (select pcm.corporate_id corporate_id,
              mv_qat.conc_product_id conc_product_id,
              mv_qat.conc_quality_id conc_quality_id,
              mv_qat.product_id product_id,
              mv_qat.quality_id quality_id,
              mvp.mvp_id mvp_id,
              mvpl.mvpl_id mvpl_id,
              mvp.valuation_region valuation_region,
              mvp.valuation_point valuation_point,
              pci.m2m_inco_term valuation_incoterm_id,
              pci.m2m_city_id valuation_city_id,
              mvp.valuation_basis valuationn_basics,
              mvp.valuation_incoterm_id reference_incoterm,
              mvp.benchmark_city_id refernce_location,
              pci.pcdi_id pcdi_id,
              pci.internal_contract_item_ref_no internal_contract_item_ref_no,
              pcm.contract_ref_no contract_ref_no,
              null internal_gmr_ref_no,
              null internal_grd_ref_no,
              'OPEN' section_name,
              mv_qat.eval_basis value_type,
              mv_qat.derivative_def_id derivative_def_id,
              mv_qat.instrument_id instrument_id,
              vdip.price_unit_id m2m_price_unit_id, --DIV
              pci.expected_delivery_month shipment_month,
              pci.expected_delivery_year shipment_year,
              to_date(('01-' || pci.expected_delivery_month || '-' ||
                      pci.expected_delivery_year),
                      'dd-Mon-yyyy') shipment_date,
              '' internal_m2m_id,
              pcpq.assay_header_id,
              mv_qat.attribute_id,
              aml.attribute_name,
              'CONCENTRATES'
         from pcm_physical_contract_main    pcm,
              pci_physical_contract_item    pci,
              pcpq_pc_product_quality       pcpq,
              pcdi_pc_delivery_item         pcdi,
              ciqs_contract_item_qty_status ciqs,
              mvp_m2m_valuation_point       mvp,
              mvpl_m2m_valuation_point_loc  mvpl,
              mv_conc_qat_quality_valuation mv_qat,
              v_derivatives_val_month       vdvm,
              v_der_instrument_price_unit   vdip,
              aml_attribute_master_list     aml
        where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
          and pcm.contract_type = 'CONCENTRATES'
          and pcdi.pcdi_id = pci.pcdi_id
          and pci.internal_contract_item_ref_no =
              ciqs.internal_contract_item_ref_no(+)
          and pci.pcpq_id = pcpq.pcpq_id
          and pcm.corporate_id = pc_corporate_id
          and mv_qat.corporate_id = pcm.corporate_id
          and pcm.issue_date <= pd_trade_date
          and pcm.contract_status in ('In Position', 'Pending Approval')
          and pcm.corporate_id = mvp.corporate_id
          and mv_qat.conc_product_id = mvp.product_id(+)
          and mv_qat.attribute_id = aml.attribute_id
          and mvp.mvp_id = mvpl.mvp_id(+)
          and mvpl.loc_city_id = pci.m2m_city_id
          and pci.internal_contract_item_ref_no =
              vdvm.internal_contract_item_ref_no(+)
          and pcpq.quality_template_id = mv_qat.conc_quality_id
          and mv_qat.instrument_id = vdip.instrument_id(+)
          and ciqs.open_qty <> 0
          and pci.is_active = 'Y'
          and ciqs.is_active = 'Y'
          and pcm.is_active = 'Y'
          and pci.is_active = 'Y'
          and pcm.dbd_id = pc_dbd_id
          and pcdi.dbd_id = pc_dbd_id
          and pci.dbd_id = pc_dbd_id
          and ciqs.dbd_id = pc_dbd_id
          and pcpq.dbd_id = pc_dbd_id
          and pcm.contract_status <> 'Cancelled');
    vc_error_loc := 4;
    /*insert into tmpc_temp_m2m_pre_check
    (corporate_id,
     product_id,
     quality_id,
     mvp_id,
     mvpl_id,
     valuation_region,
     valuation_point,
     valuation_incoterm_id,
     valuation_city_id,
     valuation_basis,
     reference_incoterm,
     refernce_location,
     pcdi_id,
     internal_contract_item_ref_no,
     contract_ref_no,
     internal_gmr_ref_no,
     internal_grd_ref_no,
     section_name,
     value_type,
     derivative_def_id,
     instrument_id,
     m2m_price_unit_id,
     shipment_month,
     shipment_year,
     shipment_date,
     internal_m2m_id)
    select m2m.corporate_id,
           m2m.product_id,
           m2m.quality_id,
           m2m.mvp_id,
           m2m.mvpl_id,
           m2m.valuation_region,
           m2m.valuation_point,
           m2m.valuation_incoterm_id,
           m2m.valuation_city_id,
           m2m.valuation_basis,
           m2m.reference_incoterm,
           m2m.refernce_location,
           m2m.pcdi_id,
           m2m.internal_contract_item_ref_no,
           m2m. contract_ref_no,
           m2m.internal_gmr_ref_no,
           m2m.internal_grd_ref_no,
           m2m.section_name,
           m2m.value_type,
           m2m.derivative_def_id,
           m2m.instrument_id,
           m2m.valuation_price_unit_id,
           m2m.shipment_month,
           m2m.shipment_year,
           m2m.shipment_date,
           null internal_m2m_id
      from (select temp.corporate_id,
                   temp.product_id,
                   temp.quality_id,
                   mv_qat.eval_basis value_type,
                   mvp.mvp_id,
                   mvpl.mvpl_id,
                   mvp.valuation_region,
                   mvp.valuation_point,
                   case
                     when temp.section_name in ('Stock NTT', 'Stock TT') then
                      nvl(mvp.in_store_incoterm_id, temp.m2m_inco_term)
                     else
                      nvl(mvp.in_transit_incoterm_id, temp.m2m_inco_term)
                   end valuation_incoterm_id,
                   --temp.m2m_inco_term valuation_incoterm_id,
                   temp.city_id valuation_city_id,
                   mvp.valuation_basis,
                   mvp.valuation_incoterm_id reference_incoterm,
                   mvp.benchmark_city_id refernce_location,
                   temp.pcdi_id,
                   mv_qat.instrument_id,
                   mv_qat.derivative_def_id,
                   temp.internal_contract_item_ref_no,
                   temp.contract_ref_no,
                   temp.internal_gmr_ref_no,
                   temp.internal_grd_ref_no,
                   temp.section_name,
                   vdip.price_unit_id valuation_price_unit_id, -- from view
                   to_char(pd_trade_date, 'Mon') shipment_month,
                   to_char(pd_trade_date, 'yyyy') shipment_year,
                   pd_trade_date shipment_date
              from (select case
                             when nvl(grd.is_afloat, 'N') = 'Y' and
                                  nvl(grd.inventory_status, 'NA') in
                                  ('In', 'None', 'NA') then
                              'Shipped NTT'
                             when nvl(grd.is_afloat, 'N') = 'Y' and
                                  nvl(grd.inventory_status, 'NA') = 'Out' then
                              'Shipped TT'
                             when nvl(grd.is_afloat, 'N') = 'N' and
                                  nvl(grd.inventory_status, 'NA') in
                                  ('In', 'None', 'NA') then
                              'Stock NTT'
                             when nvl(grd.is_afloat, 'N') = 'N' and
                                  nvl(grd.inventory_status, 'NA') = 'Out' then
                              'Stock TT'
                             else
                              'Others'
                           end section_name,
                           pcm.corporate_id,
                           pci.internal_contract_item_ref_no,
                           pcm.internal_contract_ref_no,
                           gmr.internal_gmr_ref_no,
                           grd.internal_grd_ref_no,
                           pcm.contract_type,
                           pcm.contract_ref_no,
                           pcdi.pcdi_id,
                           case
                             when grd.is_afloat = 'Y' then
                              nvl(gmr.destination_city_id,
                                  gmr.discharge_city_id)
                             else
                              shm.city_id
                           end city_id,
                           grd.product_id,
                           grd.quality_id quality_id,
                           pci.m2m_inco_term
                      from grd_goods_record_detail     grd,
                           gmr_goods_movement_record   gmr,
                           pci_physical_contract_item  pci,
                           pcm_physical_contract_main  pcm,
                           pcdi_pc_delivery_item       pcdi,
                           sld_storage_location_detail shm
                     where grd.internal_gmr_ref_no =
                           gmr.internal_gmr_ref_no
                       and grd.internal_contract_item_ref_no =
                           pci.internal_contract_item_ref_no
                       and pci.pcdi_id = pcdi.pcdi_id
                       and pcdi.internal_contract_ref_no =
                           pcm.internal_contract_ref_no
                       and grd.shed_id = shm.storage_loc_id(+)
                       and grd.dbd_id = pc_dbd_id
                       and gmr.dbd_id = pc_dbd_id
                       and pci.dbd_id = pc_dbd_id
                       and pci.dbd_id = pc_dbd_id
                       and pcm.dbd_id = pc_dbd_id
                       and pcdi.dbd_id = pc_dbd_id
                       and gmr.corporate_id = pc_corporate_id
                       and grd.status = 'Active'
                       and grd.is_deleted = 'N'
                       and gmr.is_deleted = 'N'
                       and pci.is_active = 'Y'
                       and pcm.is_active = 'Y'
                       and pcdi.is_active = 'Y'
                          --      and shm.is_deleted = 'N'
                          --   and shm.is_active = 'Y'
                       and nvl(grd.inventory_status, 'NA') <> 'Out'
                       and pcm.purchase_sales = 'P'
                    union all
                    select case
                             when nvl(gmr.inventory_status, 'NA') =
                                  'Under CMA' then
                              'UnderCMA NTT'
                             when nvl(dgrd.is_afloat, 'N') = 'Y' and
                                  nvl(dgrd.inventory_status, 'NA') in
                                  ('In', 'None', 'NA') then
                              'Shipped NTT'
                             when nvl(dgrd.is_afloat, 'N') = 'Y' and
                                  nvl(dgrd.inventory_status, 'NA') = 'Out' then
                              'Shipped TT'
                             when nvl(dgrd.is_afloat, 'N') = 'N' and
                                  nvl(dgrd.inventory_status, 'NA') in
                                  ('In', 'None', 'NA') then
                              'Stock NTT'
                             when nvl(dgrd.is_afloat, 'N') = 'N' and
                                  nvl(dgrd.inventory_status, 'NA') = 'Out' then
                              'Stock TT'
                             else
                              'Others'
                           end section_name,
                           pcm.corporate_id,
                           pci.internal_contract_item_ref_no,
                           pcm.internal_contract_ref_no,
                           gmr.internal_gmr_ref_no,
                           dgrd.internal_dgrd_ref_no internal_grd_ref_no,
                           pcm.contract_type,
                           pcm.contract_ref_no,
                           pcdi.pcdi_id,
                           case
                             when nvl(dgrd.stock_status, 'N') =
                                  'For Invoicing' then
                              nvl(gmr.destination_city_id,
                                  gmr.discharge_city_id)
                             else
                              case
                             when nvl(dgrd.is_afloat, 'N') = 'N' then
                              shm.city_id
                           end end city_id,
                           dgrd.product_id,
                           dgrd.quality_id,
                           pci.m2m_inco_term
                      from gmr_goods_movement_record   gmr,
                           pci_physical_contract_item  pci,
                           pcm_physical_contract_main  pcm,
                           pcdi_pc_delivery_item       pcdi,
                           gsm_gmr_stauts_master       gsm,
                           agh_alloc_group_header      agh,
                           sld_storage_location_detail shm,
                           dgrd_delivered_grd          dgrd
                     where gmr.internal_contract_ref_no =
                           pcm.internal_contract_ref_no(+)
                       and pcm.internal_contract_ref_no =
                           pcdi.internal_contract_ref_no
                       and agh.int_sales_contract_item_ref_no =
                           pci.internal_contract_item_ref_no
                       and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                       and dgrd.shed_id = shm.storage_loc_id(+)
                       and pcm.purchase_sales = 'S'
                       and gsm.is_required_for_m2m = 'Y'
                       and gmr.dbd_id = pc_dbd_id
                       and pci.dbd_id = pc_dbd_id
                       and pci.dbd_id = pc_dbd_id
                       and pcm.dbd_id = pc_dbd_id
                       and dgrd.dbd_id = pc_dbd_id
                       and pcdi.dbd_id = pc_dbd_id
                       and gmr.corporate_id = pc_corporate_id
                       and gmr.status_id = gsm.status_id
                       and agh.is_deleted = 'N'
                       and gmr.is_deleted = 'N'
                       and pci.is_active = 'Y'
                       and pcm.is_active = 'Y'
                       and pcdi.is_active = 'Y'
                          --  and shm.is_active = 'Y'
                          --  and shm.is_deleted = 'N'
                       and upper(agh.realized_status) in
                           ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED',
                            'REVERSEUNDERCMA')
                       and dgrd.status = 'Active'
                       and dgrd.net_weight > 0
                    union all -- Internal movement
                    select case
                             when nvl(grd.is_afloat, 'N') = 'Y' and
                                  nvl(grd.inventory_status, 'NA') in
                                  ('In', 'None', 'NA') then
                              'Shipped NTT'
                             when nvl(grd.is_afloat, 'N') = 'Y' and
                                  nvl(grd.inventory_status, 'NA') = 'Out' then
                              'Shipped TT'
                             when nvl(grd.is_afloat, 'N') = 'N' and
                                  nvl(grd.inventory_status, 'NA') in
                                  ('In', 'None', 'NA') then
                              'Stock NTT'
                             when nvl(grd.is_afloat, 'N') = 'N' and
                                  nvl(grd.inventory_status, 'NA') = 'Out' then
                              'Stock TT'
                             else
                              'Others'
                           end section_name,
                           gmr.corporate_id,
                           null internal_contract_item_ref_no,
                           null internal_contract_ref_no,
                           gmr.internal_gmr_ref_no,
                           grd.internal_grd_ref_no,
                           null contract_type,
                           null contract_ref_no,
                           null pcdi_id,
                           case
                             when grd.is_afloat = 'Y' then
                              nvl(gmr.destination_city_id,
                                  gmr.discharge_city_id)
                             else
                              shm.city_id
                           end city_id,
                           grd.product_id,
                           grd.quality_id quality_id,
                           null m2m_inco_term
                    
                      from grd_goods_record_detail     grd,
                           gmr_goods_movement_record   gmr,
                           sld_storage_location_detail shm
                    
                     where grd.internal_gmr_ref_no =
                           gmr.internal_gmr_ref_no
                       and grd.internal_contract_item_ref_no is null
                       and grd.dbd_id = pc_dbd_id
                       and gmr.dbd_id = pc_dbd_id
                       and gmr.corporate_id = pc_corporate_id
                       and gmr.shed_id = shm.storage_loc_id(+)
                       and grd.status = 'Active'
                       and grd.is_deleted = 'N'
                       and gmr.is_deleted = 'N'
                       and nvl(grd.inventory_status, 'NA') <> 'Out') temp,
                   mv_qat_quality_valuation mv_qat,
                   mvp_m2m_valuation_point mvp,
                   mvpl_m2m_valuation_point_loc mvpl,
                   v_der_instrument_price_unit vdip
             where temp.corporate_id = mv_qat.corporate_id
               and temp.quality_id = mv_qat.quality_id
               and mv_qat.instrument_id = vdip.instrument_id
               and temp.corporate_id = mvp.corporate_id
               and temp.product_id = mvp.product_id
               and mvp.mvp_id = mvpl.mvp_id
               and mvpl.loc_city_id = temp.city_id) m2m;*/
    --End of insert into tmpc for Stock Concentrate
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'finished inserting tmpc' || sql%rowcount);
    vc_error_loc := 5;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'start update tmpc shipment month year as per basis month');
    --Updating tmpc table , setting the 
    --Shipment month and shipment year
    --to the basis month calculation for open contracts as per the quality setup and product rule 
    --do the update )
    vc_error_loc := 6;
    for cc2 in (select t.pcdi_id,
                       t.internal_contract_ref_no,
                       t.internal_contract_item_ref_no,
                       t.basis_type,
                       t.transit_days,
                       t.contract_ref_no,
                       t.expected_delivery_month,
                       t.expected_delivery_year,
                       t.date_type,
                       t.ship_arrival_date,
                       t.ship_arrival_days,
                       t.expected_ship_arrival_date,
                       (case
                         when t.ship_arrival_date = 'Start Date' then
                          to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                   'Mon-yyyy'))
                         when t.ship_arrival_date = 'End Date' then
                          last_day(t.expected_ship_arrival_date)
                         else
                          (to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                    'Mon-yyyy')) +
                          trunc((last_day(t.expected_ship_arrival_date) -
                                 to_date('01-' ||
                                          to_char(t.expected_ship_arrival_date,
                                                  'Mon-yyyy'))) / 2))
                       end) + t.ship_arrival_days basis_month_year
                  from (select pcdi.pcdi_id,
                               pcdi.internal_contract_ref_no,
                               pci.internal_contract_item_ref_no,
                               pcdi.basis_type,
                               nvl(pcdi.transit_days, 0) transit_days,
                               pcm.contract_ref_no,
                               pci.expected_delivery_month,
                               pci.expected_delivery_year,
                               qat.date_type,
                               qat.ship_arrival_date,
                               nvl(qat.ship_arrival_days, 0) ship_arrival_days,
                               (case
                                  when qat.date_type = 'Shipment Date' then
                                   (case
                                  when pcdi.basis_type = 'Shipment' then
                                   last_day('01-' ||
                                            pci.expected_delivery_month || '-' ||
                                            pci.expected_delivery_year)
                                  else
                                   last_day('01-' ||
                                            pci.expected_delivery_month || '-' ||
                                            pci.expected_delivery_year) -
                                   nvl(pcdi.transit_days, 0)
                                end) else(case
                                 when pcdi.basis_type = 'Shipment' then
                                  last_day('01-' ||
                                           pci.expected_delivery_month || '-' ||
                                           pci.expected_delivery_year) +
                                  nvl(pcdi.transit_days, 0)
                                 else
                                  last_day('01-' ||
                                           pci.expected_delivery_month || '-' ||
                                           pci.expected_delivery_year)
                               end) end) expected_ship_arrival_date
                          from pcdi_pc_delivery_item      pcdi,
                               pci_physical_contract_item pci,
                               pcm_physical_contract_main pcm,
                               pcpq_pc_product_quality    pcpq,
                               qat_quality_attributes     qat
                         where pcdi.pcdi_id = pci.pcdi_id
                           and pcdi.internal_contract_ref_no =
                               pcm.internal_contract_ref_no
                           and pcm.contract_status = 'In Position'
                           and pcm.contract_type = 'CONCENTRATES'
                           and pcm.corporate_id = pc_corporate_id
                           and pci.item_qty > 0
                           and pci.pcpq_id = pcpq.pcpq_id
                           and pcpq.quality_template_id = qat.quality_id
                           and pci.dbd_id = pc_dbd_id
                           and pcdi.dbd_id = pc_dbd_id
                           and pcm.dbd_id = pc_dbd_id
                           and pcpq.dbd_id = pc_dbd_id
                           and pcdi.is_active = 'Y'
                           and pci.is_active = 'Y'
                           and pcm.is_active = 'Y') t,
                       tmpc_temp_m2m_pre_check tmpc
                 where tmpc.section_name = 'OPEN'
                   and tmpc.corporate_id = pc_corporate_id
                   and tmpc.product_type = 'CONCENTRATES'
                   and tmpc.internal_contract_item_ref_no =
                       t.internal_contract_item_ref_no
                   and tmpc.pcdi_id = t.pcdi_id)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.shipment_month = to_char(cc2.basis_month_year, 'Mon'),
             tmpc.shipment_year  = to_char(cc2.basis_month_year, 'YYYY'),
             tmpc.shipment_date  = cc2.basis_month_year
       where tmpc.pcdi_id = cc2.pcdi_id
         and tmpc.internal_contract_item_ref_no =
             cc2.internal_contract_item_ref_no
         and tmpc.section_name = 'OPEN'
         and tmpc.product_type = 'CONCENTRATES'
         and tmpc.corporate_id = pc_corporate_id;
    end loop;
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'start update tmpc shipment month year to trade date month for the expired');
  
    --End of insert into tmpc for Stock
    --Updating tmpc table , setting the 
    --Shipment month and shipment year
    --to the eod month and year .(if shipment month ,year is less then the eod date month and year then 
    --do the update )
    vc_error_loc := 7;
    for cc in (select tmpc.shipment_date,
                      tmpc.shipment_month,
                      tmpc.shipment_year
                 from tmpc_temp_m2m_pre_check tmpc
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.product_type = 'CONCENTRATES'
                group by tmpc.shipment_date,
                         tmpc.shipment_month,
                         tmpc.shipment_year)
    loop
      if to_date('01-' || cc.shipment_month || '-' || cc.shipment_year,
                 'dd-Mon-YYYY') <
         to_date('01-' || to_char(pd_trade_date, 'Mon-yyyy'), 'dd-Mon-yyyy') then
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.shipment_month = to_char(pd_trade_date, 'Mon'),
               tmpc.shipment_year  = to_char(pd_trade_date, 'YYYY'),
               tmpc.shipment_date  = pd_trade_date
         where tmpc.shipment_month = cc.shipment_month
           and tmpc.shipment_year = cc.shipment_year
           and tmpc.product_type = 'CONCENTRATES'
           and tmpc.shipment_date = cc.shipment_date;
      end if;
    end loop;
    --End of update
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'finished update tmpc' || sql%rowcount);
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'qpbm Fixed' || sql%rowcount);
    --Updating the tmpc table
    --By setting the valuatin_dr_id
    --It is checking for not Fixed contract
    --For this We are calling the  fn_get_val_drid
    vc_error_loc := 8;
    for cc in (select tmpc.corporate_id,
                      tmpc.shipment_month,
                      tmpc.shipment_year,
                      tmpc.instrument_id,
                      decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') trade_type,
                      tmpc.quality_id,
                      qat.eval_basis,
                      qat.exch_valuation_month
                 from tmpc_temp_m2m_pre_check       tmpc,
                      mv_conc_qat_quality_valuation qat
                where tmpc.quality_id = qat.quality_id
                  and tmpc.corporate_id = qat.corporate_id
                  and tmpc.corporate_id = pc_corporate_id
                  and tmpc.value_type <> 'FIXED'
                  and tmpc.product_type = 'CONCENTRATES'
                group by tmpc.corporate_id,
                         tmpc.shipment_month,
                         tmpc.shipment_year,
                         tmpc.instrument_id,
                         decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK'),
                         tmpc.quality_id,
                         qat.eval_basis,
                         qat.exch_valuation_month)
    loop
      if cc.eval_basis <> 'FIXED' then
        vc_drid := fn_get_val_drid(pc_corporate_id,
                                   cc.instrument_id,
                                   cc.shipment_month,
                                   cc.shipment_year,
                                   cc.exch_valuation_month,
                                   pd_trade_date,
                                   cc.trade_type,
                                   pc_process);
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.valuation_dr_id = vc_drid
         where tmpc.instrument_id = cc.instrument_id
           and tmpc.shipment_month = cc.shipment_month
           and tmpc.shipment_year = cc.shipment_year
           and tmpc.quality_id = cc.quality_id
           and decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') =
               cc.trade_type
           and tmpc.product_type = 'CONCENTRATES'
           and tmpc.corporate_id = cc.corporate_id;
      end if;
    end loop;
    commit;
    --update the valuation month,year,prompt date
    for ccv in (select tmpc.corporate_id,
                       tmpc.valuation_dr_id,
                       nvl(drm.period_date, drm.prompt_date) period_date,
                       nvl(drm.period_month, to_char(drm.prompt_date, 'Mon')) period_month,
                       nvl(drm.period_year, to_char(drm.prompt_date, 'yyyy')) period_year,
                       drm.prompt_date
                  from tmpc_temp_m2m_pre_check tmpc,
                       drm_derivative_master   drm
                 where tmpc.corporate_id = pc_corporate_id
                   and tmpc.value_type <> 'FIXED'
                   and tmpc.product_type = 'CONCENTRATES'
                   and tmpc.valuation_dr_id = drm.dr_id
                 group by tmpc.corporate_id,
                          drm.period_date,
                          tmpc.valuation_dr_id,
                          drm.period_month,
                          drm.period_year,
                          drm.prompt_date)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.valuation_month = ccv.period_month,
             tmpc.valuation_year  = ccv.period_year,
             tmpc.prompt_date     = ccv.prompt_date,
             tmpc.valuation_date  = ccv.period_date
       where tmpc.valuation_dr_id = ccv.valuation_dr_id
         and tmpc.product_type = 'CONCENTRATES'
         and tmpc.corporate_id = ccv.corporate_id;
    end loop;
    commit;
    -- get the contract base price Unit id
    /* begin
      select product_price_unit_id
        into vn_contract_base_price_unit_id
        from v_ppu_pum pum
       where pum.cur_id = cur_pcdi_rows.invoice_currency_id
         and pum.weight_unit_id = cur_pcdi_rows.qty_unit_id
         and pum.product_id = cur_pcdi_rows.product_id;
    exception
      when no_data_found then
        vn_contract_base_price_unit_id := null;
    end;*/
    --Updating tmpc table and setting the 
    --base_price_unit_id_in_ppu.
    vc_error_loc := 9;
    for cc in (select tmpc.corporate_id,
                      tmpc.product_id,
                      akc.base_cur_id,
                      pdm.base_quantity_unit,
                      ppu.internal_price_unit_id,
                      pum.price_unit_id
                 from tmpc_temp_m2m_pre_check tmpc,
                      ak_corporate            akc,
                      pdm_productmaster       pdm,
                      ppu_product_price_units ppu,
                      pum_price_unit_master   pum
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.corporate_id = akc.corporate_id
                  and tmpc.product_id = pdm.product_id
                  and tmpc.product_type = 'CONCENTRATES'
                  and ppu.product_id = pdm.product_id
                  and ppu.is_active = 'Y'
                  and ppu.is_deleted = 'N'
                  and ppu.price_unit_id = pum.price_unit_id
                  and pum.cur_id = akc.base_cur_id
                  and pum.weight_unit_id = pdm.base_quantity_unit
                group by tmpc.corporate_id,
                         tmpc.product_id,
                         akc.base_cur_id,
                         pdm.base_quantity_unit,
                         ppu.internal_price_unit_id,
                         pum.price_unit_id)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.base_price_unit_id_in_ppu = cc.internal_price_unit_id,
             tmpc.base_price_unit_id_in_pum = cc.price_unit_id
       where tmpc.product_type = 'CONCENTRATES';
      commit;
    end loop;
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - M2M-012 @' || systimestamp);
    vc_error_loc := 12;
    insert into eel_eod_eom_exception_log
      (corporate_id,
       submodule_name,
       exception_code,
       data_missing_for,
       trade_ref_no,
       process,
       process_run_date,
       process_run_by,
       trade_date)
      select tmpc.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-012',
             'Settlement Price missing for ' || dim.instrument_name ||
             ',Price Source:' || ps.price_source_name || ',Price Unit:' ||
             pum.price_unit_name || ',' || apm.available_price_name ||
             ' Price,Prompt Date:' || drm.dr_id_name,
             null,
             pc_process,
             systimestamp,
             pc_user_id,
             pd_trade_date
        from tmpc_temp_m2m_pre_check      tmpc,
             div_der_instrument_valuation div,
             dim_der_instrument_master    dim,
             pdd_product_derivative_def   pdd,
             drm_derivative_master        drm,
             ps_price_source              ps,
             apm_available_price_master   apm,
             pum_price_unit_master        pum
       where tmpc.instrument_id = div.instrument_id
         and tmpc.product_id = pdd.product_id
         and div.instrument_id = drm.instrument_id
         and drm.instrument_id = dim.instrument_id
         and tmpc.corporate_id = pc_corporate_id
         and tmpc.valuation_dr_id = drm.dr_id
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and tmpc.value_type <> 'FIXED'
         and tmpc.product_type = 'CONCENTRATES'
         and div.is_deleted = 'N'
         and not exists
       (select 1
                from eodeom_derivative_quote_detail dqd
               where tmpc.valuation_dr_id = dqd.dr_id
                 and tmpc.product_type = 'CONCENTRATES'
                 and div.available_price_id = dqd.available_price_id
                 and div.price_source_id = dqd.price_source_id
                 and div.price_unit_id = dqd.price_unit_id
                 and dqd.dq_trade_date = pd_trade_date
                 and dqd.corporate_id = pc_corporate_id
                 and dqd.dbd_id = gvc_dbd_id
                 and dqd.price is not null)
       group by tmpc.corporate_id,
                'Settlement Price missing for ' || dim.instrument_name ||
                ',Price Source:' || ps.price_source_name || ',Price Unit:' ||
                pum.price_unit_name || ',' || apm.available_price_name ||
                ' Price,Prompt Date:' || drm.dr_id_name;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'Settlement price' || sql%rowcount);
  
    -- settlement price missing for differential contract for price calcuation
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - M2M-012 Second @' || systimestamp);
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' - M2M-010 @' || systimestamp);
    --Location Differential
    insert into eel_eod_eom_exception_log
      (corporate_id,
       submodule_name,
       exception_code,
       data_missing_for,
       trade_ref_no,
       process,
       process_run_date,
       process_run_by,
       trade_date)
      select tmpc.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-010',
             pdm.product_desc || ',' || tmpc.valuation_point || ',' ||
             qat.quality_name || ',' || itm.incoterm || ',' ||
             cim.city_name,
             f_string_aggregate(tmpc.contract_ref_no),
             pc_process,
             systimestamp,
             pc_user_id,
             pd_trade_date
        from tmpc_temp_m2m_pre_check tmpc,
             cim_citymaster          cim,
             itm_incoterm_master     itm,
             pdm_productmaster       pdm,
             qat_quality_attributes  qat
       where tmpc.corporate_id = pc_corporate_id
         and tmpc.valuation_city_id = cim.city_id(+)
         and tmpc.valuation_incoterm_id = itm.incoterm_id(+)
         and tmpc.conc_product_id = pdm.product_id
         and tmpc.conc_quality_id = qat.quality_id
         and not exists
       (select ldh.inco_term_id,
                     ldh.product_id,
                     ldh.valuation_city_id,
                     ldh.valuation_point_id
                from lds_location_diff_setup ldh,
                     ldc_location_diff_cost  ldc
               where ldh.loc_diff_id = ldc.loc_diff_id
                 and ldh.product_id = tmpc.conc_product_id
                 and tmpc.product_type = 'CONCENTRATES'
                 and ldh.valuation_city_id = tmpc.valuation_city_id
                 and ldh.inco_term_id = tmpc.valuation_incoterm_id
                 and ldh.as_on_date <= pd_trade_date
                 and ldh.valuation_point_id = tmpc.mvp_id
                    -- and ldc.quality_id = tmpc.quality_id
                 and ldh.corporate_id = pc_corporate_id)
       group by tmpc.corporate_id,
                pdm.product_desc || ',' || tmpc.valuation_point || ',' ||
                qat.quality_name || ',' || itm.incoterm || ',' ||
                cim.city_name;
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'finished tmpc and i commit now');
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' Before Commit @' || systimestamp);
  
    ---***For loop for calling the sp_calc_m2m_tc_pc_rc_charge
    --which will do the precheck for the tc,rc and pc
    begin
      for cc_tmpc in (select tmpc.corporate_id,
                             tmpc.conc_product_id,
                             pdm.product_desc conc_product_desc,
                             tmpc.conc_quality_id,
                             qat.quality_name conc_qat_name,
                             tmpc.element_id,
                             tmpc.element_name,
                             tmpc.base_price_unit_id_in_ppu,
                             tmpc.shipment_month,
                             tmpc.shipment_year,
                             tmpc.mvp_id valuation_point_id,
                             tmpc.valuation_point
                        from tmpc_temp_m2m_pre_check tmpc,
                             pdm_productmaster       pdm,
                             qat_quality_attributes  qat
                       where tmpc.product_type = 'CONCENTRATES'
                         and tmpc.corporate_id = pc_corporate_id
                         and tmpc.conc_product_id = pdm.product_id
                         and tmpc.conc_quality_id = qat.quality_id
                       group by tmpc.corporate_id,
                                tmpc.conc_product_id,
                                pdm.product_desc,
                                tmpc.conc_quality_id,
                                tmpc.base_price_unit_id_in_ppu,
                                tmpc.element_id,
                                tmpc.valuation_point,
                                tmpc.mvp_id,
                                qat.quality_name,
                                tmpc.element_name,
                                tmpc.shipment_month,
                                tmpc.shipment_year)
      loop
        --for treatment charge precheck
        pkg_phy_pre_check_process.sp_calc_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                              pd_trade_date,
                                                              cc_tmpc.conc_product_id,
                                                              cc_tmpc.conc_quality_id,
                                                              cc_tmpc.valuation_point_id, --valuation_id
                                                              'Treatment Charges', --charge_type
                                                              cc_tmpc.element_id,
                                                              cc_tmpc.shipment_month,
                                                              cc_tmpc.shipment_year,
                                                              pn_charge_amt,
                                                              pc_charge_price_unit_id);
      
        if pn_charge_amt = 0 then
          insert into eel_eod_eom_exception_log
            (corporate_id,
             submodule_name,
             exception_code,
             data_missing_for,
             trade_ref_no,
             process,
             process_run_date,
             process_run_by,
             trade_date)
          values
            (pc_corporate_id,
             'Physicals M2M Pre-Check',
             'PHY-102',
             cc_tmpc.conc_product_desc || ',' || cc_tmpc.conc_qat_name || ',' ||
             cc_tmpc.element_name || ',' || cc_tmpc.shipment_month || '-' ||
             cc_tmpc.shipment_year || '-' || cc_tmpc.valuation_point,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             pd_trade_date);
        end if;
        --for refine charge precheck
        pkg_phy_pre_check_process.sp_calc_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                              pd_trade_date,
                                                              cc_tmpc.conc_product_id,
                                                              cc_tmpc.conc_quality_id,
                                                              cc_tmpc.valuation_point_id, --valuation_id
                                                              'Refining Charges', --charge_type
                                                              cc_tmpc.element_id,
                                                              cc_tmpc.shipment_month,
                                                              cc_tmpc.shipment_year,
                                                              pn_charge_amt,
                                                              pc_charge_price_unit_id);
        if pn_charge_amt = 0 then
          insert into eel_eod_eom_exception_log
            (corporate_id,
             submodule_name,
             exception_code,
             data_missing_for,
             trade_ref_no,
             process,
             process_run_date,
             process_run_by,
             trade_date)
          values
            (pc_corporate_id,
             'Physicals M2M Pre-Check',
             'PHY-103',
             cc_tmpc.conc_product_desc || ',' || cc_tmpc.conc_qat_name || ',' ||
             cc_tmpc.element_name || ',' || cc_tmpc.shipment_month || '-' ||
             cc_tmpc.shipment_year || '-' || cc_tmpc.valuation_point,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             pd_trade_date);
        end if;
      end loop;
      --for penalty charge precheck     
      /*for cc_tmpc in (select  tmpc.corporate_id,
              tmpc.conc_product_id,
              tmpc.conc_quality_id,
              pdm.product_desc,
              qat.quality_name,
              tmpc.shipment_month,
              tmpc.shipment_year,
              tmpc.mvp_id,
              tmpc.valuation_point,
              pqca.element_id,
              tmpc.element_name
           from ash_assay_header                    ash,
               asm_assay_sublot_mapping       asm,
               aml_attribute_master_list           aml,
               pqca_pq_chemical_attributes    pqca,
               rm_ratio_master                               rm,
               ppm_product_properties_mapping ppm,
               tmpc_temp_m2m_pre_check        tmpc,
               pdm_productmaster                           pdm,
               qat_quality_attributes                      qat
         where ash.ash_id =tmpc.assay_header_id
           and tmpc.conc_product_id=pdm.product_id
           and ash.ash_id = asm.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.unit_of_measure = rm.ratio_id
           and pqca.element_id = aml.attribute_id
           and ppm.attribute_id = aml.attribute_id
           and tmpc.corporate_id=pc_corporate_id
           and tmpc.conc_quality_id=qat.quality_id
           and pqca.is_elem_for_pricing = 'N'
           and pqca.is_active = 'Y'
           and asm.is_active = 'Y'
           and ppm.product_id =tmpc.conc_product_id
           and nvl(ppm.deduct_for_wet_to_dry, 'N') = 'N'
         group by  tmpc.corporate_id,
              tmpc.conc_product_id,
              tmpc.conc_quality_id,
              pdm.product_desc,
              qat.quality_name,
              tmpc.shipment_month,
              tmpc.shipment_year,
              tmpc.mvp_id,
              tmpc.valuation_point,
              pqca.element_id,
              tmpc.element_name) loop
      
        pkg_phy_pre_check_process.sp_calc_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                              pd_trade_date,
                                                              cc_tmpc.conc_product_id,
                                                              cc_tmpc.conc_quality_id,
                                                               cc_tmpc.mvp_id, --valuation_id
                                                              'Penalties', --charge_type
                                                              cc_tmpc.element_id,
                                                              cc_tmpc.shipment_month,
                                                              cc_tmpc.shipment_year,
                                                              pn_charge_amt,
                                                              pc_charge_price_unit_id);
       if  pn_charge_amt = 0 then
          insert into eel_eod_eom_exception_log
            (corporate_id,
             submodule_name,
             exception_code,
             data_missing_for,
             trade_ref_no,
             process,
             process_run_date,
             process_run_by,
             trade_date)
          values
            (pc_corporate_id,
             'Physicals M2M Pre-Check',
              'PHY-104',
             cc_tmpc.product_desc || ',' ||cc_tmpc.quality_name||','||
             cc_tmpc.element_name||','||
             cc_tmpc.shipment_month || '-' ||
             cc_tmpc.shipment_year || '-' ||
             cc_tmpc.valuation_point,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             pd_trade_date);
       end if;
      end loop;*/
    
    end;
    ---***end of for loop 
    commit;
  exception
    when others then
      dbms_output.put_line(sqlerrm);
      rollback;
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'Precheck M2M',
                   'is it here ????');
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_pre_check_m2m_values',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;
  /*End  of Concentrate Precheck */
  procedure sp_calc_m2m_quality_premimum(pc_corporate_id          varchar2,
                                         pd_trade_date            date,
                                         pc_valuation_point_id    varchar2,
                                         pc_quality_id            varchar2,
                                         pc_product_id            varchar2,
                                         pc_premium_price_unit_id varchar2,
                                         pc_calendar_month        varchar2,
                                         pc_calendar_year         varchar2,
                                         pc_user_id               varchar2,
                                         pc_process               varchar2,
                                         pn_qp_amt                out number) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    select nvl(sum(t.premium * pkg_phy_pre_check_process.
                   f_get_converted_price(t.corporate_id,
                                         1,
                                         t.premium_price_unit_id,
                                         pc_premium_price_unit_id,
                                         pd_trade_date)),
               -1) total_premiumalue
      into pn_qp_amt
      from (select qp.corporate_id,
                   qp.product_id,
                   qpbm.premium,
                   qpbm.premium_price_unit_id,
                   qp.as_on_date,
                   rank() over(order by qp.as_on_date desc nulls last) as latest_record -- as we have to use rank function, if same day, 
            --different curve found, some those premium values into m2m price unit
              from qpbm_quality_premium_by_month qpbm,
                   qp_quality_premium            qp
             where qp.qp_id = qpbm.qp_id
               and qp.corporate_id = pc_corporate_id
               and qp.valuation_point_id = pc_valuation_point_id
               and qp.quality_id = pc_quality_id
               and qpbm.calendar_month = pc_calendar_month
               and qpbm.calendar_year = pc_calendar_year
               and qp.product_id = pc_product_id
               and nvl(qpbm.is_beyond, 'N') = 'N'
               and qp.as_on_date <= pd_trade_date) t
     where t.latest_record = 1;
    --Based on Beyond values
    --dbms_output.put_line('pn_qp_amt' ||pn_qp_amt);
    if pn_qp_amt = -1 then
      begin
        select sum(t.premium * pkg_phy_pre_check_process.
                   f_get_converted_price(t.corporate_id,
                                         1,
                                         t.premium_price_unit_id,
                                         pc_premium_price_unit_id,
                                         pd_trade_date)) total_premiumalue
          into pn_qp_amt
          from (select qp.corporate_id,
                       qp.product_id,
                       qpbm.premium,
                       qpbm.premium_price_unit_id,
                       qp.as_on_date,
                       rank() over(order by qp.as_on_date desc nulls last) as latest_record -- as we have to use rank function, if same day, 
                --different curve found, some those premium values into m2m price unit
                  from qpbm_quality_premium_by_month qpbm,
                       qp_quality_premium            qp
                 where qp.qp_id = qpbm.qp_id
                   and qp.corporate_id = pc_corporate_id
                   and qp.valuation_point_id = pc_valuation_point_id
                   and qp.quality_id = pc_quality_id
                   and to_date('01-' || qpbm.beyond_month || '-' ||
                               qpbm.beyond_year,
                               'dd-Mon-yyyy') <
                       to_date('01-' || pc_calendar_month || '-' ||
                               pc_calendar_year,
                               'dd-Mon-yyyy')
                   and qp.product_id = pc_product_id
                   and nvl(qpbm.is_beyond, 'N') = 'Y'
                   and qp.as_on_date <= pd_trade_date) t
         where t.latest_record = 1;
      exception
        when no_data_found then
          pn_qp_amt := 0;
          --vc_premimum_price_unit_id := null;
      end;
    end if;
  exception
    when no_data_found then
      begin
        select sum(t.premium * pkg_phy_pre_check_process.
                   f_get_converted_price(t.corporate_id,
                                         1,
                                         t.premium_price_unit_id,
                                         pc_premium_price_unit_id,
                                         pd_trade_date)) total_premiumalue
          into pn_qp_amt
          from (select qp.corporate_id,
                       qp.product_id,
                       qpbm.premium,
                       qpbm.premium_price_unit_id,
                       qp.as_on_date,
                       rank() over(order by qp.as_on_date desc nulls last) as latest_record -- as we have to use rank function, if same day, 
                --different curve found, some those premium values into m2m price unit
                  from qpbm_quality_premium_by_month qpbm,
                       qp_quality_premium            qp
                 where qp.qp_id = qpbm.qp_id
                   and qp.corporate_id = pc_corporate_id
                   and qp.valuation_point_id = pc_valuation_point_id
                   and qp.quality_id = pc_quality_id
                   and to_date('01-' || qpbm.beyond_month || '-' ||
                               qpbm.beyond_year,
                               'dd-Mon-yyyy') <
                       to_date('01-' || pc_calendar_month || '-' ||
                               pc_calendar_year,
                               'dd-Mon-yyyy')
                   and qp.product_id = pc_product_id
                   and nvl(qpbm.is_beyond, 'N') = 'Y'
                   and qp.as_on_date <= pd_trade_date) t
         where t.latest_record = 1;
      exception
        when no_data_found then
          pn_qp_amt := 0;
          --vc_premimum_price_unit_id := null;
      end;
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_pre_check_m2m_values',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end sp_calc_m2m_quality_premimum;
  procedure sp_calc_m2m_tc_pc_rc_charge(pc_corporate_id         varchar2,
                                        pd_trade_date           date,
                                        pc_conc_product_id      varchar2,
                                        pc_conc_quality_id      varchar2,
                                        pc_valuation_point_id   varchar2,
                                        pc_charge_type          varchar2,
                                        pc_element_id           varchar2,
                                        pc_calendar_month       varchar2,
                                        pc_calendar_year        varchar2,
                                        pn_charge_amt           out number,
                                        pc_charge_price_unit_id out varchar2) is
  begin
    if pc_charge_type in ('Treatment Charges', 'Refining Charges') then
      select t.charge_value,
             t.charge_unit_id
        into pn_charge_amt,
             pc_charge_price_unit_id
        from (select mdcbm.charge_value,
                     mdcbm.charge_unit_id,
                     rank() over(order by mdcd.as_of_date desc nulls last) as td_rank
                from mdcd_m2m_ded_charge_details mdcd,
                     mdcbm_ded_charges_by_month  mdcbm
               where mdcd.internal_mdcd_ref_no = mdcbm.mdcd_id
                 and mdcd.corporate_id = pc_corporate_id
                 and mdcd.as_of_date <= pd_trade_date
                 and mdcd.product_id = pc_conc_product_id
                 and mdcd.quality_id = pc_conc_quality_id
                 and mdcd.valuation_region_id = pc_valuation_point_id
                 and mdcd.internal_element_id = pc_element_id
                 and mdcbm.calendar_month = pc_calendar_month
                 and mdcbm.calendar_year = pc_calendar_year
                 and mdcd.charge_type = pc_charge_type) t
       where t.td_rank = 1;
    elsif pc_charge_type = 'Penalties' then
      -- pn_charge_amt := 10;
      select t.charge_value,
             t.charge_unit_id
        into pn_charge_amt,
             pc_charge_price_unit_id
        from (select mdcbm.charge_value,
                     mdcbm.charge_unit_id,
                     rank() over(order by mdcd.as_of_date desc nulls last) as td_rank
                from mdcd_m2m_ded_charge_details mdcd,
                     mdcbm_ded_charges_by_month  mdcbm
               where mdcd.internal_mdcd_ref_no = mdcbm.mdcd_id
                 and mdcd.corporate_id = pc_corporate_id
                 and mdcd.as_of_date <= pd_trade_date
                 and mdcd.product_id = pc_conc_product_id
                 and mdcd.quality_id = pc_conc_quality_id
                 and mdcd.valuation_region_id = pc_valuation_point_id
                 and mdcd.internal_element_id = pc_element_id
                 and mdcbm.calendar_month = pc_calendar_month
                 and mdcbm.calendar_year = pc_calendar_year
                 and mdcd.charge_type = pc_charge_type) t
       where t.td_rank = 1;
    end if;
  exception
    when no_data_found then
      pn_charge_amt           := 0;
      pc_charge_price_unit_id := null;
    when others then
      dbms_output.put_line(sqlerrm);
      pn_charge_amt           := -2;
      pc_charge_price_unit_id := '3';
  end;

  procedure sp_calc_m2m_product_premimum(pc_corporate_id          varchar2,
                                         pd_trade_date            date,
                                         pc_product_id            varchar2,
                                         pc_calendar_month        varchar2,
                                         pc_calendar_year         varchar2,
                                         pc_user_id               varchar2,
                                         pc_process               varchar2,
                                         pc_premium_price_unit_id varchar2,
                                         pn_pp_amt                out number) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_premium         number := 0;
    -- vc_premium_status  varchar2(10);
  begin
    --Premium based on the not beyond  values
  
    select nvl(sum(t.premium *
                   pkg_phy_pre_check_process.f_get_converted_price(t.corporate_id,
                                                                   1,
                                                                   t.premium_price_unit_id,
                                                                   pc_premium_price_unit_id,
                                                                   pd_trade_date)),
               -1) total_prod_premimum
      into vn_premium
      from (select ppbm.premium,
                   ppbm.premium_price_unit_id,
                   pp.corporate_id,
                   pp.product_id,
                   pp.as_on_date,
                   rank() over(order by pp.as_on_date desc nulls last) as latest_record
              from pp_product_premium            pp,
                   ppbm_product_premium_by_month ppbm
             where pp.pp_id = ppbm.pp_id
               and pp.corporate_id = pc_corporate_id
               and pp.product_id = pc_product_id
               and ppbm.calendar_month = pc_calendar_month
               and ppbm.calendar_year = pc_calendar_year
               and nvl(ppbm.is_beyond, 'N') = 'N'
               and pp.as_on_date <= pd_trade_date) t
     where t. latest_record = 1;
    if vn_premium = -1 then
      begin
        select sum(t.premium *
                   pkg_phy_pre_check_process.f_get_converted_price(t.corporate_id,
                                                                   1,
                                                                   t.premium_price_unit_id,
                                                                   pc_premium_price_unit_id,
                                                                   pd_trade_date)) total_prod_premimum
          into vn_premium
          from (select ppbm.premium,
                       ppbm.premium_price_unit_id,
                       pp.corporate_id,
                       pp.product_id,
                       pp.as_on_date,
                       rank() over(order by pp.as_on_date desc nulls last) as latest_record
                  from pp_product_premium            pp,
                       ppbm_product_premium_by_month ppbm
                 where pp.pp_id = ppbm.pp_id
                   and pp.corporate_id = pc_corporate_id
                   and pp.product_id = pc_product_id --
                   and to_date('01-' || ppbm.beyond_month || '-' ||
                               ppbm.beyond_year,
                               'dd-Mon-yyyy') <
                       to_date('01-' || pc_calendar_month || '-' ||
                               pc_calendar_year,
                               'dd-Mon-yyyy')
                   and nvl(ppbm.is_beyond, 'N') = 'Y'
                   and pp.as_on_date <= pd_trade_date) t
         where t. latest_record = 1;
      exception
        when no_data_found then
          vn_premium := 0;
          --vc_premium_status := 'NO_DATA';
      end;
    end if;
    pn_pp_amt := vn_premium;
  exception
    when no_data_found then
      --Premium based on the beyond  values
      begin
        select sum(t.premium *
                   pkg_phy_pre_check_process.f_get_converted_price(t.corporate_id,
                                                                   1,
                                                                   t.premium_price_unit_id,
                                                                   pc_premium_price_unit_id,
                                                                   pd_trade_date)) total_prod_premimum
          into vn_premium
          from (select ppbm.premium,
                       ppbm.premium_price_unit_id,
                       pp.corporate_id,
                       pp.product_id,
                       pp.as_on_date,
                       rank() over(order by pp.as_on_date desc nulls last) as latest_record
                  from pp_product_premium            pp,
                       ppbm_product_premium_by_month ppbm
                 where pp.pp_id = ppbm.pp_id
                   and pp.corporate_id = pc_corporate_id
                   and pp.product_id = pc_product_id --
                   and to_date('01-' || ppbm.beyond_month || '-' ||
                               ppbm.beyond_year,
                               'dd-Mon-yyyy') <
                       to_date('01-' || pc_calendar_month || '-' ||
                               pc_calendar_year,
                               'dd-Mon-yyyy')
                   and nvl(ppbm.is_beyond, 'N') = 'Y'
                   and pp.as_on_date <= pd_trade_date) t
         where t. latest_record = 1;
        pn_pp_amt := vn_premium;
      exception
        when no_data_found then
          vn_premium := 0;
          pn_pp_amt  := vn_premium;
      end;
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_pre_check_m2m_values',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end sp_calc_m2m_product_premimum;

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
      --  AND cm.cur_code = akc.base_currency_name;
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
     where qum.qty_unit_id = pc_qty_unit_id;
    return vc_is_derived_unit;
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
                       f_get_converted_currency_amt(pc_corporate_id,
                                                    pum1.cur_id,
                                                    pum2.cur_id,
                                                    pd_trade_date,
                                                    1) *
                       f_get_converted_quantity(pc_product_id,
                                                pum1.weight_unit_id,
                                                pum2.weight_unit_id,
                                                1) * nvl(pum1.weight, 1) /
                       nvl(pum2.weight, 1),
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
  function fn_get_val_drid(pc_corporate_id       in varchar2,
                           p_instrument_id       in varchar2,
                           p_from_month          in varchar2,
                           p_from_year           in varchar2,
                           p_exec_valution_month in varchar2,
                           p_trade_date          in date,
                           p_trade_type          in varchar2,
                           p_process             in varchar2) return varchar2 is
    v_date                  date;
    v_trade_date            date;
    vobj_error_log          tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count      number := 1;
    v_dr_id                 varchar2(10);
    workings_days           number(2);
    msg_display             varchar2(500);
    is_daily_app            varchar2(10);
    is_month_app            varchar2(10);
    vd_value_date           date;
    vc_delivery_calendar_id varchar2(50);
  begin
    v_trade_date := p_trade_date;
    begin
      select pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable,
             pdc.prompt_delivery_calendar_id
        into is_daily_app,
             is_month_app,
             vc_delivery_calendar_id
        from dim_der_instrument_master    dim,
             pdc_prompt_delivery_calendar pdc
       where dim.instrument_id = p_instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id;
    exception
      when others then
        is_daily_app := 'Y';
    end;
    if is_daily_app = 'Y' then
      if p_trade_type = 'OPEN' then
        v_date := to_date('01' || p_from_month || p_from_year, 'dd-mm-yyyy');
        v_date := pkg_cdc_derivatives_process.f_get_next_day(v_date,
                                                             'Wed',
                                                             3);
      
        while true
        loop
          if pkg_cdc_derivatives_process.f_is_day_holiday(p_instrument_id,
                                                          v_date) then
            v_date := v_date + 1;
          else
            exit;
          end if;
        end loop;
        --      dbms_output.put_line('before check  ' || v_date);
        /*if (p_exec_valution_month = 'Closest') then
          v_date := v_date;
        elsif (p_exec_valution_month = 'Next') then
          v_date := v_date + 1;
          while true
          loop
            if pkg_cdc_derivatives_process
            .f_is_day_holiday(p_instrument_id, (v_date)) then
              v_date := v_date + 1;
            else
              exit;
            end if;
          end loop;
          dbms_output.put_line('after next  ' || v_date);
        elsif (p_exec_valution_month = 'Previous') then
          v_date := v_date - 1;
          while true
          loop
            if pkg_cdc_derivatives_process.f_is_day_holiday(p_instrument_id,
                                                            (v_date)) then
              v_date := v_date - 1;
            else
              exit;
            end if;
          end loop;
          --  dbms_output.put_line('after prev  ' || v_date);
        end if;*/
      
        if (p_exec_valution_month = 'Closest') then
          v_date := v_date;
        
        elsif (p_exec_valution_month = 'Next') then
          v_date := pkg_cdc_derivatives_process.f_get_next_day(add_months(v_date,
                                                                          1),
                                                               'Wed',
                                                               3);
          while true
          loop
            if pkg_cdc_derivatives_process.f_is_day_holiday(p_instrument_id,
                                                            (v_date)) then
            
              v_date := v_date + 1;
            else
              exit;
            end if;
          end loop;
        elsif (p_exec_valution_month = 'Previous') then
          v_date := pkg_cdc_derivatives_process.f_get_next_day(add_months(v_date,
                                                                          -1),
                                                               'Wed',
                                                               3);
          while true
          loop
            if pkg_cdc_derivatives_process.f_is_day_holiday(p_instrument_id,
                                                            (v_date)) then
            
              dbms_output.put_line(' inside loop  ' || v_date);
              v_date := v_date - 1;
            else
              exit;
            end if;
          end loop;
        end if;
      else
        -- to get spot drid    
        v_date := p_trade_date;
      end if;
      if v_date <= p_trade_date then
        workings_days := 0;
        v_trade_date  := p_trade_date + 1;
        while workings_days <> 2
        loop
          if pkg_cdc_derivatives_process.f_is_day_holiday(p_instrument_id,
                                                          v_trade_date) then
            v_trade_date := v_trade_date + 1;
          else
            workings_days := workings_days + 1;
            if workings_days <> 2 then
              v_trade_date := v_trade_date + 1;
            end if;
          end if;
        end loop;
      else
        v_trade_date := v_date;
      end if;
      begin
        select drm.dr_id
          into v_dr_id
          from drm_derivative_master drm
         where drm.prompt_date = v_trade_date
           and drm.instrument_id = p_instrument_id
           and drm.price_point_id is null
           and drm.is_deleted = 'N'
           and drm.is_expired = 'N'
           and rownum <= 1;
      
      exception
        when no_data_found then
          v_dr_id := null;
        when others then
          v_dr_id := null;
      end;
    end if;
    if is_daily_app = 'N' and is_month_app = 'Y' then
      begin
        if to_date('01-' || p_from_month || '-' || p_from_year,
                   'dd-Mon-yyyy') <= p_trade_date then
          -- vd_value_date := to_date('01-'||to_char(add_months(p_trade_date,1),'Mon-yyyy'),'dd-Mon-yyyy');
          --  vd_value_date := p_trade_date;
          vd_value_date := pkg_metals_general.fn_get_next_month_prompt_date(vc_delivery_calendar_id,
                                                                            p_trade_date);
        
        else
          vd_value_date := to_date('01-' || p_from_month || '-' ||
                                   p_from_year,
                                   'dd-Mon-yyyy');
        end if;
      
        select drm.dr_id
          into v_dr_id
          from drm_derivative_master drm
         where drm.instrument_id = p_instrument_id
           and drm.price_point_id is null
           and drm.is_deleted = 'N'
           and drm.is_expired = 'N'
           and drm.period_month = to_char(vd_value_date, 'Mon')
           and drm.period_year = to_char(vd_value_date, 'yyyy')
           and rownum <= 1;
      exception
        when no_data_found then
          v_dr_id := null;
        when others then
          v_dr_id := null;
      end;
    end if;
  
    if v_dr_id is null then
      --get the instrument details
      --msg_display
      begin
        select dim.instrument_name || ',Price Source:' ||
               ps.price_source_name || ',Price Unit:' ||
               pum.price_unit_name || ',' || apm.available_price_name ||
               ' Price,Prompt Date:' || (case
                 when is_daily_app = 'N' and is_month_app = 'Y' then
                  to_char(vd_value_date, 'Mon-yyyy')
                 else
                  to_char(v_trade_date, 'dd-Mon-yyyy')
               end)
          into msg_display
          from dim_der_instrument_master    dim,
               div_der_instrument_valuation div,
               ps_price_source              ps,
               pum_price_unit_master        pum,
               apm_available_price_master   apm
         where dim.instrument_id = div.instrument_id
           and div.price_source_id = ps.price_source_id
           and div.price_unit_id = pum.price_unit_id
           and dim.instrument_id = p_instrument_id
           and div.available_price_id = apm.available_price_id
           and div.is_deleted = 'N';
      exception
        when no_data_found then
          msg_display := 'No valuation setup for ' || p_instrument_id;
        when others then
          msg_display := sqlcode || 'Message:' || sqlerrm;
      end;
    
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_pre_check_physicals',
                                                           'PHY-002',
                                                           msg_display,
                                                           '',
                                                           p_process,
                                                           null,
                                                           sysdate,
                                                           p_trade_date);
      sp_insert_error_log(vobj_error_log);
    end if;
    return v_dr_id;
  end;

  procedure sp_pre_check_rebuild_stats is
  begin
    null;
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
       ppu1.internal_price_unit_id = p_from_price_unit_id
       and ppu2.internal_price_unit_id = p_to_price_unit_id
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
  exception
    when no_data_found then
      return - 1;
    when others then
      return - 1;
  end f_get_converted_price;
  procedure sp_phy_insert_ceqs_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_dbd_id       varchar2,
                                    pc_user_id      varchar2) as
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
    cursor cur_qty is
      select pci.internal_contract_item_ref_no,
             cipq.element_id,
             cipq.payable_qty,
             cipq.qty_unit_id,
             pcpq.assay_header_id,
             pqca.typical,
             rm.ratio_name
        from pci_physical_contract_item     pci,
             pcdi_pc_delivery_item          pcdi,
             cipq_contract_item_payable_qty cipq,
             pcpq_pc_product_quality        pcpq,
             ash_assay_header               ash,
             asm_assay_sublot_mapping       asm,
             pqca_pq_chemical_attributes    pqca,
             rm_ratio_master                rm
       where pci.pcdi_id = pcdi.pcdi_id
         and pci.internal_contract_item_ref_no =
             cipq.internal_contract_item_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcpq.assay_header_id = ash.ash_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.element_id = cipq.element_id
         and pqca.unit_of_measure = rm.ratio_id
         and pci.dbd_id = pc_dbd_id
         and pcpq.dbd_id = pc_dbd_id
         and pcdi.dbd_id = pc_dbd_id
         and pci.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and cipq.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and ash.is_active = 'Y'
         and asm.is_active = 'Y'
         and pqca.is_active = 'Y'
         and rm.is_active = 'Y';
    vn_string            varchar2(100);
    vn_srt_psn           number;
    vn_end_psn           number;
    vn_assay_qty         number;
    vn_assay_qty_unit    varchar2(10);
    vn_assay_qty_unit_id varchar2(20);
  
  begin
    for cur_qty_rows in cur_qty
    loop
      vn_string            := pkg_metals_general.
                              fn_element_qty(cur_qty_rows.internal_contract_item_ref_no,
                                             cur_qty_rows.assay_header_id,
                                             cur_qty_rows.element_id,
                                             pc_dbd_id);
      vn_srt_psn           := instr(vn_string, '$', 1);
      vn_end_psn           := instr(vn_string, '$', 1, 2);
      vn_assay_qty         := substr(vn_string, 1, vn_srt_psn - 1);
      vn_assay_qty_unit    := substr(vn_string,
                                     vn_srt_psn + 1,
                                     vn_end_psn - 1);
      vn_assay_qty_unit_id := substr(vn_string, vn_end_psn + 1);
      insert into ceqs_contract_ele_qty_status
        (corporate_id,
         internal_contract_item_ref_no,
         element_id,
         assay_qty,
         assay_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         assay_percentage,
         assay_percentage_unit_id,
         dbd_id)
      values
        (pc_corporate_id,
         cur_qty_rows.internal_contract_item_ref_no,
         cur_qty_rows.element_id,
         vn_assay_qty,
         vn_assay_qty_unit_id,
         cur_qty_rows.payable_qty,
         cur_qty_rows.qty_unit_id,
         cur_qty_rows.typical,
         cur_qty_rows.ratio_name,
         pc_dbd_id);
    end loop;
  end;
end;
/
