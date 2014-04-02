create or replace package pkg_phy_pre_check_process is
  -- precheck for metals
  -- Author  : Janna
  -- Created : 1/11/2009 11:50:17 AM
  -- Purpose : Pre check data for EOD and EOM
  gvc_dbd_id  varchar2(15);
  gvc_process varchar2(3);

  procedure sp_pre_check(pc_corporate_id varchar2,
                         pd_trade_date   date,
                         pc_user_id      varchar2,
                         pc_process      varchar2);

  procedure sp_m2m_tc_pc_rc_charge(pc_corporate_id       varchar2,
                                   pd_trade_date         date,
                                   pc_conc_product_id    varchar2,
                                   pc_conc_quality_id    varchar2,
                                   pc_valuation_point_id varchar2,
                                   pc_charge_type        varchar2,
                                   pc_element_id         varchar2,
                                   pc_calendar_month     varchar2,
                                   pc_calendar_year      varchar2,
                                   pc_price_unit_id      varchar2,
                                   pd_payment_due_date   date,
                                   pn_charge_amt         out number,
                                   pc_exch_rate_string   out varchar2);
  procedure sp_calc_m2m_tc_pc_rc_charge(pc_corporate_id         varchar2,
                                        pd_trade_date           date,
                                        pc_conc_product_id      varchar2,
                                        pc_conc_quality_id      varchar2,
                                        pc_valuation_point_id   varchar2,
                                        pc_charge_type          varchar2,
                                        pc_element_id           varchar2,
                                        pc_calendar_month       varchar2,
                                        pc_calendar_year        varchar2,
                                        pc_price_unit_id        varchar2,
                                        pn_charge_amt           out number,
                                        pc_charge_price_unit_id out varchar2);

  procedure sp_pre_check_m2m_values(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_dbd_id       varchar2,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2);

  procedure sp_update_ld_base_metal(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2);

  procedure sp_update_ld_concentrates(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2,
                                      pc_process      varchar2);

  procedure sp_pre_check_m2m_conc_values(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_dbd_id       varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2);

  procedure sp_pre_check_m2m_tolling_extn(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_dbd_id       varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2);

  procedure sp_m2m_quality_premimum(pc_corporate_id          varchar2,
                                    pd_trade_date            date,
                                    pc_valuation_point_id    varchar2,
                                    pc_quality_id            varchar2,
                                    pc_product_id            varchar2,
                                    pc_premium_price_unit_id varchar2,
                                    pc_calendar_month        varchar2,
                                    pc_calendar_year         varchar2,
                                    pc_user_id               varchar2,
                                    pd_payment_due_date      date,
                                    pc_process               varchar2,
                                    pd_valuation_fx_date     date,
                                    pn_qp_amt                out number,
                                    pn_qp_amt_cp_fx_rate     out number,
                                    pc_exch_rate_string      out varchar2,
                                    pc_exch_rate_missing     out varchar2);
  procedure sp_m2m_product_premimum(pc_corporate_id          varchar2,
                                    pd_trade_date            date,
                                    pc_product_id            varchar2,
                                    pc_calendar_month        varchar2,
                                    pc_calendar_year         varchar2,
                                    pc_user_id               varchar2,
                                    pd_payment_due_date      date,
                                    pc_process               varchar2,
                                    pc_premium_price_unit_id varchar2,
                                    pc_valuation_point_id    varchar2,
                                    pd_valuation_fx_date     date,
                                    pn_pp_amt                out number,
                                    pn_pp_amt_corp_fx_rate   out number,
                                    pc_exch_rate_string      out varchar2,
                                    pc_exch_rate_missing     out varchar2);
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
  procedure sp_update_tmpc_fx_date(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_dbd_id       varchar2,
                                   pc_user_id      varchar2);
procedure sp_mbv_pre_check(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process      varchar2,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_dbd_id       varchar2);                                   
end; 
/
create or replace package body pkg_phy_pre_check_process is

  procedure sp_pre_check
  --------------------------------------------------------------------------------------------------------------------------
    -- precheck for metals
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
    vc_process_id      varchar2(20);
  begin
    gvc_process := pc_process;
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'inside Phy sp_pre_check process !!!!');    
    select dbd.dbd_id
      into gvc_dbd_id
      from dbd_database_dump dbd
     where dbd.corporate_id = pc_corporate_id
       and dbd.process = pc_process
       and dbd.trade_date = pd_trade_date;
    select tdc.process_id
      into vc_process_id
      from tdc_trade_date_closure tdc
     where tdc.corporate_id = pc_corporate_id
       and tdc.trade_date = pd_trade_date
       and tdc.process = pc_process;
 vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'started sp_mbv_pre_check !!!!');        
    sp_mbv_pre_check(pc_corporate_id,
                                     pd_trade_date,
                                     pc_process,
                                     vc_process_id,
                                     pc_user_id,gvc_dbd_id);
  
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
                            'sp_pre_check_m2m_values');
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
    sp_pre_check_m2m_tolling_extn(pc_corporate_id,
                                  pd_trade_date,
                                  gvc_dbd_id,
                                  pc_user_id,
                                  pc_process);
  
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            vn_logno,
                            'sp_pre_check_m2m_tolling_extn');
    --**                          
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
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
    pkg_execute_process.sp_mark_process_time(pc_corporate_id,
                                             pd_trade_date,
                                             pc_user_id,
                                             pc_process,
                                             'PRECHECK');
    commit;
    pkg_execute_process.sp_process_time_display(pc_corporate_id,
                                                 pd_trade_date,
                                                 pc_user_id,
                                                 pc_process,
                                                 'PRECHECK'); 
    commit;                           
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

  procedure sp_pre_check_m2m_values(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_dbd_id       varchar2,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2) is
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
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vc_drid                        varchar2(15);
    vn_qty_premimum_amt            number;
    vn_pp_amt                      number;
    vc_error_loc                   varchar2(100);
    vn_no_loc_diff_count           number;
    vc_quality_exch_rate_string    varchar2(500);
    vc_product_exch_rate_string    varchar2(500);
    vc_exch_rate_missing           varchar2(1);
    vn_qty_premimum_amt_cp_fx_rate number;
    vn_pp_amt_cp_fx_rate           number;
   -- vd_prev_eom_date               date;
  begin
    delete from tmpc_temp_m2m_pre_check tmpc
     where corporate_id = pc_corporate_id;
    commit;
    vc_error_loc := 1;
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
                 and pcpd.input_output = 'Input'
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
    commit;
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
                         and pcdi.dbd_id = pc_dbd_id
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
                               else
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
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
                         and pcdi.pcdi_id = pci.pcdi_id
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.is_deleted = 'N'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
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
    commit;
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
       product_type,
       payment_due_date,
       qp_end_date,
       valuation_fx_date)
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
              'BASEMETAL',
              (case
                when nvl(pcdi.payment_due_date, pd_trade_date) <
                     pd_trade_date then
                 pd_trade_date
                else
                 nvl(pcdi.payment_due_date, pd_trade_date)
              end),
              pci.qp_end_date,
              pd_trade_date
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
    commit;
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
       product_type,
       payment_due_date,
       qp_end_date,
       valuation_fx_date)
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
             'BASEMETAL',
             payment_due_date,
             m2m.qp_end_date,
             pd_trade_date
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
                     pd_trade_date shipment_date,
                     (case
                       when temp.payment_due_date < pd_trade_date then
                        pd_trade_date
                       else
                        temp.payment_due_date
                     end) payment_due_date,
                     temp.qp_end_date
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
                             pci.m2m_inco_term,
                             (case
                               when nvl(grd.inventory_status, 'NA') = 'In' then
                                pd_trade_date
                               else
                                pcdi.payment_due_date
                             end) payment_due_date,
                             pci.qp_end_date
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
                         and pcm.contract_status = 'In Position'
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
                               else
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                             end end city_id,
                             dgrd.product_id,
                             dgrd.quality_id,
                             pci.m2m_inco_term,
                             (case
                               when nvl(dgrd.inventory_status, 'NA') = 'Out' then
                                pd_trade_date
                               else
                                pcdi.payment_due_date
                             end) payment_due_date,
                             pci.qp_end_date
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
                         and pcdi.pcdi_id = pci.pcdi_id
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and pcm.contract_type = 'BASEMETAL'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and agh.dbd_id = pc_dbd_id
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
                         and pcm.contract_status = 'In Position'
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
                             null m2m_inco_term,
                             pd_trade_date payment_due_date,
                             pd_trade_date --- ???
                        from grd_goods_record_detail     grd,
                             gmr_goods_movement_record   gmr,
                             sld_storage_location_detail shm,
                             pdm_productmaster           pdm,
                             pdtm_product_type_master    pdtm
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and gmr.is_internal_movement = 'Y'
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and grd.product_id = pdm.product_id
                         and pdm.product_type_id = pdtm.product_type_id
                         and pdtm.product_type_name = 'Standard'
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
                 and mv_qat.instrument_id = vdip.instrument_id(+)
                 and temp.corporate_id = mvp.corporate_id
                 and temp.product_id = mvp.product_id
                 and mvp.mvp_id = mvpl.mvp_id
                 and mvpl.loc_city_id = temp.city_id) m2m;
    commit;
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
                                                   'Mon-yyyy'),'dd-Mon-yyyy')
                         when t.ship_arrival_date = 'End Date' then
                          last_day(t.expected_ship_arrival_date)
                         else
                          (to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                    'Mon-yyyy'),'dd-Mon-yyyy') +
                          trunc((last_day(t.expected_ship_arrival_date) -
                                 to_date('01-' ||
                                          to_char(t.expected_ship_arrival_date,
                                                  'Mon-yyyy'),'dd-Mon-yyyy')) / 2))
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
    commit;
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
    -- Update data so that we can calculate other M2M Data
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            gvc_dbd_id,
                            10101,
                            'sp_update_tmpc_fx_date');
    sp_update_tmpc_fx_date(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           pc_user_id);
    commit;
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
                       qat.quality_name,
                       tmpc.payment_due_date,
                       tmpc.price_basis,
                       tmpc.valuation_fx_date,
                       tmpc.qp_fx_date,
                       case
                         when tmpc.section_name in ('Shipped IN', 'Stock IN') then
                          'INVM2M'
                         else
                          'UNREAL'
                       end section_name
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
                          qat.quality_name,
                          tmpc.payment_due_date,
                          tmpc.price_basis,
                          tmpc.valuation_fx_date,
                          tmpc.qp_fx_date,
                          case
                            when tmpc.section_name in
                                 ('Shipped IN', 'Stock IN') then
                             'INVM2M'
                            else
                             'UNREAL'
                          end)
    loop
      vn_qty_premimum_amt            := 0;
      vn_qty_premimum_amt_cp_fx_rate := 0;
      sp_m2m_quality_premimum(pc_corporate_id,
                              pd_trade_date,
                              cc1.mvp_id,
                              cc1.quality_id,
                              cc1.product_id,
                              cc1.base_price_unit_id_in_ppu,
                              cc1.shipment_month,
                              cc1.shipment_year,
                              pc_user_id,
                              cc1.payment_due_date,
                              pc_process,
                              cc1.valuation_fx_date,
                              vn_qty_premimum_amt,
                              vn_qty_premimum_amt_cp_fx_rate,
                              vc_quality_exch_rate_string,
                              vc_exch_rate_missing);
      -- If exchange rate was missing and premium became null let us not throw the error                        
      -- Since the procedure already throw an error for exchange rate
      if (vn_qty_premimum_amt is null or vn_qty_premimum_amt = 0) and
         vc_exch_rate_missing = 'N' then
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
           cc1.product_desc || ',' || cc1.quality_name || ',' ||
           cc1.valuation_point || ',' || cc1.shipment_month || '-' ||
           cc1.shipment_year,
           null,
           pc_process,
           sysdate,
           pc_user_id,
           pd_trade_date);
      else
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.m2m_quality_premium         = vn_qty_premimum_amt,
               tmpc.m2m_qp_in_corporate_fx_rate = vn_qty_premimum_amt_cp_fx_rate,
               tmpc.m2m_qp_fw_exch_rate         = vc_quality_exch_rate_string
         where tmpc.corporate_id = pc_corporate_id
           and tmpc.mvp_id = cc1.mvp_id
           and tmpc.quality_id = cc1.quality_id
           and tmpc.product_id = cc1.product_id
           and tmpc.shipment_month = cc1.shipment_month
           and tmpc.shipment_year = cc1.shipment_year
           and tmpc.payment_due_date = cc1.payment_due_date
           and case when
         tmpc.section_name in ('Shipped IN', 'Stock IN') then 'INVM2M' else 'UNREAL' end = cc1.section_name;
      
      end if;
    end loop;
    vc_error_loc := 11;
    --
    -- Check the product premimum
    --
    for cc in (select tmpc.corporate_id,
                      tmpc.product_id,
                      pdm.product_desc,
                      tmpc.base_price_unit_id_in_ppu,
                      tmpc.shipment_month,
                      tmpc.shipment_year,
                      tmpc.payment_due_date,
                      tmpc.mvp_id,
                      tmpc.valuation_point,
                      tmpc.valuation_fx_date,
                      case
                        when tmpc.section_name in ('Shipped IN', 'Stock IN') then
                         'INVM2M'
                        else
                         'UNREAL'
                      end section_name
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
                         tmpc.shipment_year,
                         tmpc.payment_due_date,
                         tmpc.mvp_id,
                         tmpc.valuation_point,
                         tmpc.valuation_fx_date,
                         case
                           when tmpc.section_name in
                                ('Shipped IN', 'Stock IN') then
                            'INVM2M'
                           else
                            'UNREAL'
                         end)
    loop
      vn_pp_amt            := 0;
      vn_pp_amt_cp_fx_rate := 0;
      sp_m2m_product_premimum(cc.corporate_id,
                              pd_trade_date,
                              cc.product_id,
                              cc.shipment_month,
                              cc.shipment_year,
                              pc_user_id,
                              cc.payment_due_date,
                              pc_process,
                              cc.base_price_unit_id_in_ppu,
                              cc.mvp_id,
                              cc.valuation_fx_date,
                              vn_pp_amt,
                              vn_pp_amt_cp_fx_rate,
                              vc_product_exch_rate_string,
                              vc_exch_rate_missing);
      --                              
      -- If exchange rate was missing and premium became null let us not throw the error                        
      -- Since the procedure already throw an error for exchange rate
      --
      if (vn_pp_amt is null or vn_pp_amt = 0) and
         vc_exch_rate_missing = 'N' then
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
           cc.product_desc || ',' || cc.shipment_month || '-' ||
           cc.shipment_year || ', ' || cc.valuation_point,
           null,
           pc_process,
           sysdate,
           pc_user_id,
           pd_trade_date);
      else
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.m2m_product_premium         = vn_pp_amt,
               tmpc.m2m_pp_in_corporate_fx_rate = vn_pp_amt_cp_fx_rate,
               tmpc.m2m_pp_fw_exch_rate         = vc_product_exch_rate_string
         where tmpc.corporate_id = pc_corporate_id
           and tmpc.product_id = cc.product_id
           and tmpc.shipment_month = cc.shipment_month
           and tmpc.shipment_year = cc.shipment_year
           and tmpc.mvp_id = cc.mvp_id
           and case when
         tmpc.section_name in ('Shipped IN', 'Stock IN') then 'INVM2M' else 'UNREAL' end = cc.section_name;
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
             ' Price,Prompt Date:' || drm.dr_id_name || ' Trade Date(' ||
             to_char(cdim.valid_quote_date, 'dd-Mon-yyyy') || ')',
             f_string_aggregate(tmpc.contract_ref_no),
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
             pum_price_unit_master        pum,
             cdim_corporate_dim           cdim
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
         and cdim.corporate_id = pc_corporate_id
         and cdim.instrument_id = dim.instrument_id
         and not exists
       (select 1
                from eodeom_derivative_quote_detail dqd,
                     cdim_corporate_dim             cdim
               where tmpc.valuation_dr_id = dqd.dr_id
                 and tmpc.product_type = 'BASEMETAL'
                 and div.available_price_id = dqd.available_price_id
                 and div.price_source_id = dqd.price_source_id
                 and div.price_unit_id = dqd.price_unit_id
                 and dqd.dq_trade_date = cdim.valid_quote_date
                 and dqd.corporate_id = pc_corporate_id
                 and dqd.dbd_id = gvc_dbd_id
                 and dqd.price is not null
                 and cdim.corporate_id = pc_corporate_id
                 and cdim.instrument_id = dqd.instrument_id
              
              )
       group by tmpc.corporate_id,
                'Settlement Price missing for ' || dim.instrument_name ||
                ',Price Source:' || ps.price_source_name || ',Price Unit:' ||
                pum.price_unit_name || ',' || apm.available_price_name ||
                ' Price,Prompt Date:' || drm.dr_id_name || ' Trade Date(' ||
                to_char(cdim.valid_quote_date, 'dd-Mon-yyyy') || ')';
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
    --
    -- We will do Location Differential Calcualtion only if no data missing for LD
    -- 
    vn_no_loc_diff_count := sql%rowcount;
    commit;
    if vn_no_loc_diff_count = 0 then
      sp_update_ld_base_metal(pc_corporate_id,
                              pd_trade_date,
                              pc_user_id,
                              pc_process);
    end if;
  
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
                                                           sqlerrm || ' ' ||
                                                           vc_error_loc,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;

  procedure sp_update_ld_base_metal
  --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_update_ld_base_metal
    --        Author                                    : janna
    --        Created Date                              : 08th Feb 2012
    --        Purpose                                   : Update Location Differential for Base Metal
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_process      varchar2)
  
   is
    cursor cur_loc_diff is
      select tmpc.mvp_id || tmpc.valuation_city_id ||
             tmpc.valuation_incoterm_id || tmpc.product_id ||
             to_char(tmpc.payment_due_date, 'dd-Mon-yyyy') pk_loc_diff,
             tmpc.mvp_id,
             tmpc.valuation_city_id,
             tmpc.valuation_incoterm_id,
             tmpc.product_id,
             ldc.cost_value cost_value,
             ldc.cost_price_unit_id,
             tmpc.base_price_unit_id_in_ppu,
             tmpc.valuation_fx_date,
             tmpc.section_name
        from lds_location_diff_setup ldh,
             ldc_location_diff_cost ldc,
             (select tmpc.valuation_incoterm_id,
                     tmpc.valuation_city_id,
                     tmpc.product_id,
                     tmpc.payment_due_date,
                     tmpc.mvp_id,
                     base_price_unit_id_in_ppu,
                     tmpc.valuation_fx_date,
                     case
                       when tmpc.section_name in ('Shipped IN', 'Stock IN') then
                        'INVM2M'
                       else
                        'UNREAL'
                     end section_name
                from tmpc_temp_m2m_pre_check tmpc
               where tmpc.product_type = 'BASEMETAL'
                 and tmpc.corporate_id = pc_corporate_id
               group by tmpc.valuation_incoterm_id,
                        tmpc.valuation_city_id,
                        tmpc.product_id,
                        tmpc.payment_due_date,
                        tmpc.mvp_id,
                        base_price_unit_id_in_ppu,
                        tmpc.valuation_fx_date,
                        case
                          when tmpc.section_name in
                               ('Shipped IN', 'Stock IN') then
                           'INVM2M'
                          else
                           'UNREAL'
                        end) tmpc
       where ldh.loc_diff_id = ldc.loc_diff_id
         and ldh.valuation_city_id = tmpc.valuation_city_id
         and tmpc.mvp_id = ldh.valuation_point_id
         and tmpc.product_id = ldh.product_id
         and ldh.inco_term_id = tmpc.valuation_incoterm_id
         and ldh.corporate_id = pc_corporate_id
         and ldh.as_on_date =
             (select max(ldh1.as_on_date)
                from lds_location_diff_setup ldh1
               where ldh1.as_on_date <= pd_trade_date
                 and ldh1.valuation_point_id = ldh.valuation_point_id
                 and ldh1.inco_term_id = ldh.inco_term_id
                 and ldh1.valuation_city_id = ldh.valuation_city_id
                 and ldh1.product_id = ldh.product_id)
      
       order by 1;
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vc_error_loc                 varchar2(10) := '0';
    vc_current_loc_diff_pk       varchar2(100);
    vc_previous_loc_diff_pk      varchar2(100);
    vn_loc_diff                  number := 0;
    vn_total_loc_diff            number := 0;
    vc_ld_exch_rate_string       varchar2(500);
    vc_total_ld_exch_rate_string varchar2(500);
    vc_ld_cur_id                 varchar2(15);
    vc_ld_unit_id                varchar2(15);
    vn_ld_weight                 number;
    vc_ld_main_cur_id            varchar2(15);
    vc_ld_main_cur_code          varchar2(15);
    vc_ld_main_cur_factor        number;
    vc_base_cur_id               varchar2(15);
    vc_base_cur_code             varchar2(15);
    vc_base_weight_unit_id       varchar2(15);
    vn_fw_exch_rate_ld_to_base   number;
    vn_forward_points            number;
    vc_valuation_city_id         varchar2(15);
    vc_valuation_incoterm_id     varchar2(15);
    vc_product_id                varchar2(15);
    --vd_payment_due_date          date;
    vd_valuation_fx_date date;
    vc_mvp_id            varchar2(15);
    vc_data_missing_for  varchar2(100);
    vc_section_name      varchar2(15);
  
  begin
    for cur_loc_diff_rows in cur_loc_diff
    loop
      vc_current_loc_diff_pk := cur_loc_diff_rows.pk_loc_diff;
      -- When the PK changes renitialize the variable
      if (vc_current_loc_diff_pk = vc_previous_loc_diff_pk) or
         vc_previous_loc_diff_pk is null then
        null;
      else
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.m2m_loc_incoterm_deviation = vn_total_loc_diff,
               tmpc.m2m_ld_fw_exch_rate        = vc_total_ld_exch_rate_string
         where tmpc.corporate_id = pc_corporate_id
           and tmpc.valuation_city_id = vc_valuation_city_id
           and tmpc.valuation_incoterm_id = vc_valuation_incoterm_id
           and tmpc.product_id = vc_product_id
           and tmpc.valuation_fx_date = vd_valuation_fx_date
           and tmpc.mvp_id = vc_mvp_id
           and case when
         tmpc.section_name in ('Shipped IN', 'Stock IN') then 'INVM2M' else 'UNREAL' end = vc_section_name;
        vn_loc_diff                  := 0;
        vn_total_loc_diff            := 0;
        vc_ld_exch_rate_string       := null;
        vc_total_ld_exch_rate_string := null;
      end if;
      vc_error_loc := '1';
      if cur_loc_diff_rows.cost_price_unit_id <>
         cur_loc_diff_rows.base_price_unit_id_in_ppu then
        --
        -- Get the Currency of the Premium Price Unit
        --
        vc_error_loc := '2';
        select ppu.cur_id,
               ppu.weight_unit_id,
               nvl(ppu.weight, 1)
          into vc_ld_cur_id,
               vc_ld_unit_id,
               vn_ld_weight
          from v_ppu_pum ppu
         where ppu.product_price_unit_id =
               cur_loc_diff_rows.cost_price_unit_id;
        vc_error_loc := '3';
        --
        -- Get the Main Currency of the Premium Price Unit
        --   
        pkg_general.sp_get_base_cur_detail(vc_ld_cur_id,
                                           vc_ld_main_cur_id,
                                           vc_ld_main_cur_code,
                                           vc_ld_main_cur_factor);
        vc_error_loc := '4';
        --
        -- Get the Details of the Base Currency
        --  
        select ppu.cur_id,
               ppu.weight_unit_id,
               cm.cur_code
          into vc_base_cur_id,
               vc_base_weight_unit_id,
               vc_base_cur_code
          from v_ppu_pum          ppu,
               cm_currency_master cm
         where ppu.product_price_unit_id =
               cur_loc_diff_rows.base_price_unit_id_in_ppu
           and ppu.cur_id = cm.cur_id;
        --
        -- Get the Exchange Rate from Premium Price Currency to Base Currency
        -- 
      
        if cur_loc_diff_rows.valuation_fx_date = pd_trade_date then
          pkg_general.sp_bank_fx_rate_spot(pc_corporate_id,
                                           pd_trade_date,
                                           vc_ld_main_cur_id,
                                           vc_base_cur_id,
                                           'sp_update_ld_base_metal LD to Base Spot',
                                           pc_process,
                                           vn_fw_exch_rate_ld_to_base);
        else
          pkg_general.sp_bank_fx_rate_spot_fw_points(pc_corporate_id,
                                                     pd_trade_date,
                                                     cur_loc_diff_rows.valuation_fx_date,
                                                     vc_ld_main_cur_id,
                                                     vc_base_cur_id,
                                                     'sp_update_ld_base_metal LD to Base FW Rate',
                                                     pc_process,
                                                     vn_fw_exch_rate_ld_to_base,
                                                     vn_forward_points);
        end if;
        vc_error_loc := '5';
        if vn_fw_exch_rate_ld_to_base = 0 then
          vc_data_missing_for := vc_ld_main_cur_code || ' to ' ||
                                 vc_base_cur_code || '(' ||
                                 to_char(cur_loc_diff_rows.valuation_fx_date,
                                         'dd-Mon-yyyy') || ') Trade Date: ' ||
                                 to_char(pd_trade_date, 'dd-Mon-yyyy');
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
             'Physicals Pre-Check BM Location Diff ',
             'PHY-005',
             vc_data_missing_for,
             null,
             pc_process,
             systimestamp,
             pc_user_id,
             null,
             pd_trade_date);
        end if;
        vc_error_loc := '6';
        if vc_base_cur_id <> vc_ld_main_cur_id then
          vc_ld_exch_rate_string := '1 ' || vc_ld_main_cur_code || '=' ||
                                    vn_fw_exch_rate_ld_to_base || ' ' ||
                                    vc_base_cur_code;
          if vc_total_ld_exch_rate_string is null then
            vc_total_ld_exch_rate_string := vc_ld_exch_rate_string;
          else
            if instr(vc_total_ld_exch_rate_string, vc_ld_exch_rate_string) = 0 then
              vc_total_ld_exch_rate_string := vc_total_ld_exch_rate_string || ',' ||
                                              vc_ld_exch_rate_string;
            end if;
          end if;
        end if;
      
        vn_loc_diff := (cur_loc_diff_rows.cost_value / vn_ld_weight) *
                       vc_ld_main_cur_factor * vn_fw_exch_rate_ld_to_base *
                       pkg_general.f_get_converted_quantity(cur_loc_diff_rows.product_id,
                                                            vc_base_weight_unit_id,
                                                            vc_ld_unit_id,
                                                            
                                                            1);
      else
        vn_loc_diff := cur_loc_diff_rows.cost_value;
      end if;
      vn_total_loc_diff := vn_total_loc_diff + vn_loc_diff;
      --
      -- These variable are required since for updation these value are required 
      -- And NOT the cursor values as the record in the cursor is new
      -- 
      vc_previous_loc_diff_pk  := cur_loc_diff_rows.pk_loc_diff;
      vc_valuation_city_id     := cur_loc_diff_rows.valuation_city_id;
      vc_valuation_incoterm_id := cur_loc_diff_rows.valuation_incoterm_id;
      vc_product_id            := cur_loc_diff_rows.product_id;
      vd_valuation_fx_date     := cur_loc_diff_rows.valuation_fx_date;
      vc_mvp_id                := cur_loc_diff_rows.mvp_id;
      vc_section_name          := cur_loc_diff_rows.section_name;
    end loop;
    vc_error_loc := '7';
    update tmpc_temp_m2m_pre_check tmpc
       set tmpc.m2m_loc_incoterm_deviation = vn_total_loc_diff,
           tmpc.m2m_ld_fw_exch_rate        = vc_total_ld_exch_rate_string
     where tmpc.corporate_id = pc_corporate_id
       and tmpc.valuation_city_id = vc_valuation_city_id
       and tmpc.valuation_incoterm_id = vc_valuation_incoterm_id
       and tmpc.product_id = vc_product_id
       and tmpc.valuation_fx_date = vd_valuation_fx_date
       and tmpc.mvp_id = vc_mvp_id
       and case when tmpc.section_name in ('Shipped IN', 'Stock IN') then 'INVM2M' else 'UNREAL' end = vc_section_name;
    vc_error_loc := '8';
    commit;
  exception
    when others then
      rollback;
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_update_ld_base_metal',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_error_loc,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_update_ld_concentrates
  --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_update_ld_concentrates
    --        Author                                    : janna
    --        Created Date                              : 08th Feb 2012
    --        Purpose                                   : Update Location Differential for oncentrates
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_process      varchar2)
  
   is
    cursor cur_loc_diff is
      select tmpc.mvp_id || tmpc.valuation_city_id ||
             tmpc.valuation_incoterm_id || tmpc.conc_product_id ||
             to_char(tmpc.payment_due_date, 'dd-Mon-yyyy') pk_loc_diff,
             tmpc.mvp_id,
             tmpc.valuation_city_id,
             tmpc.valuation_incoterm_id,
             tmpc.conc_product_id,
             ldc.cost_value cost_value,
             ldc.cost_price_unit_id,
             tmpc.payment_due_date,
             tmpc.conc_base_price_unit_id_ppu
        from lds_location_diff_setup ldh,
             ldc_location_diff_cost ldc,
             (select tmpc.valuation_incoterm_id,
                     tmpc.valuation_city_id,
                     tmpc.conc_product_id,
                     tmpc.payment_due_date,
                     tmpc.mvp_id,
                     tmpc.conc_base_price_unit_id_ppu
                from tmpc_temp_m2m_pre_check tmpc
               where tmpc.product_type = 'CONCENTRATES'
                 and tmpc.corporate_id = pc_corporate_id
               group by tmpc.valuation_incoterm_id,
                        tmpc.valuation_city_id,
                        tmpc.conc_product_id,
                        tmpc.payment_due_date,
                        tmpc.mvp_id,
                        tmpc.conc_base_price_unit_id_ppu) tmpc
       where ldh.loc_diff_id = ldc.loc_diff_id
         and ldh.valuation_city_id = tmpc.valuation_city_id
         and tmpc.mvp_id = ldh.valuation_point_id
         and tmpc.conc_product_id = ldh.product_id
         and ldh.inco_term_id = tmpc.valuation_incoterm_id
         and ldh.corporate_id = pc_corporate_id
         and ldh.as_on_date =
             (select max(ldh1.as_on_date)
                from lds_location_diff_setup ldh1
               where ldh1.as_on_date <= pd_trade_date
                 and ldh1.valuation_point_id = ldh.valuation_point_id
                 and ldh1.inco_term_id = ldh.inco_term_id
                 and ldh1.valuation_city_id = ldh.valuation_city_id
                 and ldh1.product_id = ldh.product_id)
      
       order by 1;
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vc_error_loc                 varchar2(10) := '0';
    vc_current_loc_diff_pk       varchar2(100);
    vc_previous_loc_diff_pk      varchar2(100);
    vn_loc_diff                  number := 0;
    vn_total_loc_diff            number := 0;
    vc_ld_exch_rate_string       varchar2(500);
    vc_total_ld_exch_rate_string varchar2(500);
    vc_ld_cur_id                 varchar2(15);
    vc_ld_unit_id                varchar2(15);
    vn_ld_weight                 number;
    vc_ld_main_cur_id            varchar2(15);
    vc_ld_main_cur_code          varchar2(15);
    vc_ld_main_cur_factor        number;
    vc_base_cur_id               varchar2(15);
    vc_base_cur_code             varchar2(15);
    vc_base_weight_unit_id       varchar2(15);
    vn_fw_exch_rate_ld_to_base   number;
    vn_forward_points            number;
    vc_valuation_city_id         varchar2(15);
    vc_valuation_incoterm_id     varchar2(15);
    vc_product_id                varchar2(15);
    vd_payment_due_date          date;
    vc_mvp_id                    varchar2(15);
    vc_data_missing_for          varchar2(100);
  
  begin
    for cur_loc_diff_rows in cur_loc_diff
    loop
      vc_current_loc_diff_pk := cur_loc_diff_rows.pk_loc_diff;
      -- When the PK changes renitialize the variable
      if (vc_current_loc_diff_pk = vc_previous_loc_diff_pk) or
         vc_previous_loc_diff_pk is null then
        null;
      else
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.m2m_loc_incoterm_deviation = vn_total_loc_diff,
               tmpc.m2m_ld_fw_exch_rate        = vc_total_ld_exch_rate_string
         where tmpc.corporate_id = pc_corporate_id
           and tmpc.valuation_city_id = vc_valuation_city_id
           and tmpc.valuation_incoterm_id = vc_valuation_incoterm_id
           and tmpc.conc_product_id = vc_product_id
           and tmpc.payment_due_date = vd_payment_due_date
           and tmpc.mvp_id = vc_mvp_id
           and tmpc.product_type = 'CONCENTRATES';
      
        vn_loc_diff                  := 0;
        vn_total_loc_diff            := 0;
        vc_ld_exch_rate_string       := null;
        vc_total_ld_exch_rate_string := null;
      end if;
      vc_error_loc := '1';
      if cur_loc_diff_rows.cost_price_unit_id <>
         cur_loc_diff_rows.conc_base_price_unit_id_ppu then
        --
        -- Get the Currency of the Premium Price Unit
        --
        vc_error_loc := '2';
        select ppu.cur_id,
               ppu.weight_unit_id,
               nvl(ppu.weight, 1)
          into vc_ld_cur_id,
               vc_ld_unit_id,
               vn_ld_weight
          from v_ppu_pum ppu
         where ppu.product_price_unit_id =
               cur_loc_diff_rows.cost_price_unit_id;
        vc_error_loc := '3';
        --
        -- Get the Main Currency of the Premium Price Unit
        --   
        pkg_general.sp_get_base_cur_detail(vc_ld_cur_id,
                                           vc_ld_main_cur_id,
                                           vc_ld_main_cur_code,
                                           vc_ld_main_cur_factor);
        vc_error_loc := '4';
        --
        -- Get the Details of the Base Currency
        --  
      
        select ppu.cur_id,
               ppu.weight_unit_id,
               cm.cur_code
          into vc_base_cur_id,
               vc_base_weight_unit_id,
               vc_base_cur_code
          from v_ppu_pum          ppu,
               cm_currency_master cm
         where ppu.product_price_unit_id =
               cur_loc_diff_rows.conc_base_price_unit_id_ppu
           and ppu.cur_id = cm.cur_id;
        --
        -- Get the Exchange Rate from Premium Price Currency to Base Currency
        -- 
        pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                pd_trade_date,
                                                cur_loc_diff_rows.payment_due_date,
                                                vc_ld_main_cur_id,
                                                vc_base_cur_id,
                                                30,
                                                vn_fw_exch_rate_ld_to_base,
                                                vn_forward_points);
        vc_error_loc := '5';
        if vn_fw_exch_rate_ld_to_base = 0 then
          vc_data_missing_for := vc_ld_main_cur_code || ' / ' ||
                                 vc_base_cur_code || ' ' ||
                                 to_char(cur_loc_diff_rows.payment_due_date,
                                         'dd-Mon-yyyy');
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
             'Physicals Pre-Check Concentrate Location Diff',
             'PHY-005',
             vc_data_missing_for,
             null,
             pc_process,
             systimestamp,
             pc_user_id,
             null,
             pd_trade_date);
        end if;
        vc_error_loc := '6';
        if vc_base_cur_id <> vc_ld_main_cur_id then
          vc_ld_exch_rate_string := '1 ' || vc_ld_main_cur_code || '=' ||
                                    vn_fw_exch_rate_ld_to_base || ' ' ||
                                    vc_base_cur_code;
          if vc_total_ld_exch_rate_string is null then
            vc_total_ld_exch_rate_string := vc_ld_exch_rate_string;
          else
            if instr(vc_total_ld_exch_rate_string, vc_ld_exch_rate_string) = 0 then
              vc_total_ld_exch_rate_string := vc_total_ld_exch_rate_string || ',' ||
                                              vc_ld_exch_rate_string;
            end if;
          end if;
        end if;
      
        vn_loc_diff := (cur_loc_diff_rows.cost_value / vn_ld_weight) *
                       vc_ld_main_cur_factor * vn_fw_exch_rate_ld_to_base *
                       pkg_general.f_get_converted_quantity(cur_loc_diff_rows.conc_product_id,
                                                            vc_base_weight_unit_id,
                                                            vc_ld_unit_id,
                                                            
                                                            1);
      else
        vn_loc_diff := cur_loc_diff_rows.cost_value;
      end if;
      vn_total_loc_diff := vn_total_loc_diff + vn_loc_diff;
      --
      -- These variable are required since for updation these value are required 
      -- And NOT the cursor values as the record in the cursor is new
      -- 
      vc_previous_loc_diff_pk  := cur_loc_diff_rows.pk_loc_diff;
      vc_valuation_city_id     := cur_loc_diff_rows.valuation_city_id;
      vc_valuation_incoterm_id := cur_loc_diff_rows.valuation_incoterm_id;
      vc_product_id            := cur_loc_diff_rows.conc_product_id;
      vd_payment_due_date      := cur_loc_diff_rows.payment_due_date;
      vc_mvp_id                := cur_loc_diff_rows.mvp_id;
    end loop;
    vc_error_loc := '7';
    update tmpc_temp_m2m_pre_check tmpc
       set tmpc.m2m_loc_incoterm_deviation = vn_total_loc_diff,
           tmpc.m2m_ld_fw_exch_rate        = vc_total_ld_exch_rate_string
     where tmpc.corporate_id = pc_corporate_id
       and tmpc.valuation_city_id = vc_valuation_city_id
       and tmpc.valuation_incoterm_id = vc_valuation_incoterm_id
       and tmpc.conc_product_id = vc_product_id
       and tmpc.payment_due_date = vd_payment_due_date
       and tmpc.mvp_id = vc_mvp_id
       and tmpc.product_type = 'CONCENTRATES';
    vc_error_loc := '8';
    commit;
  exception
    when others then
      rollback;
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_update_ld_concentrates',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_error_loc,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  /*Start of Concentrate Precheck*/
  procedure sp_pre_check_m2m_conc_values(pc_corporate_id varchar2,
                                         pd_trade_date   date,
                                         pc_dbd_id       varchar2,
                                         pc_user_id      varchar2,
                                         pc_process      varchar2) is
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
    vobj_error_log             tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count         number := 1;
    vc_drid                    varchar2(15);
    vc_error_loc               varchar2(100);
    pn_charge_amt              number;
    vn_no_loc_diff_error_count number;
    vc_exch_rate_string        varchar2(100);
  
  begin
    --dbms_mview.refresh('MV_CONC_QAT_QUALITY_VALUATION', 'C');
    --added newly to maintain consistency in both physical process and precheck. 28th
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
                 and pcm.dbd_id = pc_dbd_id
                 and pcpd.dbd_id = pc_dbd_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcdi.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and pcm.issue_date <= pd_trade_date
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcm.is_tolling_contract = 'N'
                 and pcm.is_tolling_extn = 'N'
                 and pcpd.input_output = 'Input'
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
                         and pcm.contract_status = 'In Position'
                         and pcm.is_tolling_contract = 'N'
                         and pcm.is_tolling_extn = 'N'
                         and grd.shed_id = shm.storage_loc_id(+)
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and pcdi.is_active = 'Y'
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
                               else
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
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
                         and pcm.contract_status = 'In Position'
                         and pcm.is_tolling_contract = 'N'
                         and pcm.is_tolling_extn = 'N'
                         and pci.pcdi_id = pcdi.pcdi_id
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
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
       product_type,
       is_tolling_contract,
       is_tolling_extn,
       payment_due_date,
       m2m_treatment_charge,
       m2m_refining_charge)
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
              'CONCENTRATES',
              pcm.is_tolling_contract,
              pcm.is_tolling_extn,
              pcdi.payment_due_date,
              0,
              0
         from pcm_physical_contract_main     pcm,
              pci_physical_contract_item     pci,
              pcpq_pc_product_quality        pcpq,
              pcdi_pc_delivery_item          pcdi,
              ciqs_contract_item_qty_status  ciqs,
              mvp_m2m_valuation_point        mvp,
              mvpl_m2m_valuation_point_loc   mvpl,
              mv_conc_qat_quality_valuation  mv_qat,
              v_derivatives_val_month        vdvm,
              v_der_instrument_price_unit    vdip,
              aml_attribute_master_list      aml,
              pcpch_pc_payble_content_header pcpch
        where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
          and pcm.contract_type = 'CONCENTRATES'
          and pcm.is_tolling_contract = 'N'
          and pcm.is_tolling_extn = 'N'
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
          and pcdi.is_active = 'Y'
          and pcpq.is_active = 'Y'
          and pcm.dbd_id = pc_dbd_id
          and pcdi.dbd_id = pc_dbd_id
          and pci.dbd_id = pc_dbd_id
          and ciqs.dbd_id = pc_dbd_id
          and pcpq.dbd_id = pc_dbd_id
          and pcm.contract_status <> 'Cancelled'
          and pcpch.internal_contract_ref_no = pcm.internal_contract_ref_no
          and pcpch.dbd_id = pc_dbd_id
          and pcpch.element_id = aml.attribute_id
          and aml.is_active = 'Y');
    vc_error_loc := 4;
    --Insert into tmpc for inventory Concentrate
    insert into tmpc_temp_m2m_pre_check
      (corporate_id,
       product_type,
       conc_product_id,
       conc_quality_id,
       product_id,
       quality_id,
       element_id,
       element_name,
       assay_header_id,
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
       is_tolling_contract,
       is_tolling_extn,
       payment_due_date,
       m2m_treatment_charge,
       m2m_refining_charge)
      select m2m.corporate_id,
             m2m.product_group_type,
             m2m.product_id conc_product_id,
             m2m.quality_id conc_quality_id,
             m2m.element_product_id,
             m2m.element_quality_id,
             m2m.element_id,
             m2m.element_name,
             m2m.assay_header_id,
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
             m2m.is_tolling_contract,
             m2m.is_tolling_extn,
             payment_due_date,
             0,
             0
        from (select temp.corporate_id,
                     temp.product_group_type,
                     mv_qat.product_id element_product_id,
                     mv_qat.quality_id element_quality_id,
                     temp.product_id,
                     temp.quality_id,
                     temp.element_id,
                     temp.element_name,
                     temp.assay_header_id,
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
                     vdip.price_unit_id valuation_price_unit_id,
                     to_char(pd_trade_date, 'Mon') shipment_month,
                     to_char(pd_trade_date, 'yyyy') shipment_year,
                     pd_trade_date shipment_date,
                     temp.is_tolling_contract,
                     temp.is_tolling_extn,
                     payment_due_date
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
                             pcm.product_group_type,
                             pcm.issue_date,
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
                             pcpq.assay_header_id,
                             grd.quality_id quality_id,
                             pci.m2m_inco_term,
                             pcm.is_tolling_contract,
                             pcm.is_tolling_extn,
                             pd_trade_date payment_due_date,
                             aml.attribute_id element_id,
                             aml.attribute_name element_name
                        from grd_goods_record_detail        grd,
                             gmr_goods_movement_record      gmr,
                             pci_physical_contract_item     pci,
                             pcm_physical_contract_main     pcm,
                             pcdi_pc_delivery_item          pcdi,
                             sld_storage_location_detail    shm,
                             pcpq_pc_product_quality        pcpq,
                             pcpch_pc_payble_content_header pcpch,
                             aml_attribute_master_list      aml
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and grd.internal_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pci.pcdi_id = pcdi.pcdi_id
                         and pcpq.pcpq_id = pci.pcpq_id
                         and pcdi.internal_contract_ref_no =
                             pcm.internal_contract_ref_no
                         and grd.shed_id = shm.storage_loc_id(+)
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcpq.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                         and pcpq.is_active = 'Y'
                         and nvl(grd.inventory_status, 'NA') <> 'Out'
                         and pcm.purchase_sales = 'P'
                         and pcm.contract_type = 'CONCENTRATES'
                         and pcm.contract_status = 'In Position'
                         and pcm.is_tolling_contract = 'N'
                         and pcm.is_tolling_extn = 'N'
                         and gmr.is_internal_movement = 'N'
                         and pcpch.internal_contract_ref_no =
                             pcm.internal_contract_ref_no
                         and pcpch.dbd_id = pc_dbd_id
                         and pcpch.element_id = aml.attribute_id
                         and aml.is_active = 'Y'
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
                             pcm.product_group_type,
                             pcm.issue_date,
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
                               else
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                             end end city_id,
                             dgrd.product_id,
                             pcpq.assay_header_id,
                             dgrd.quality_id,
                             pci.m2m_inco_term,
                             pcm.is_tolling_contract,
                             pcm.is_tolling_extn,
                             pd_trade_date payment_due_date,
                             aml.attribute_id element_id,
                             aml.attribute_name element_name
                        from gmr_goods_movement_record      gmr,
                             pci_physical_contract_item     pci,
                             pcm_physical_contract_main     pcm,
                             pcdi_pc_delivery_item          pcdi,
                             gsm_gmr_stauts_master          gsm,
                             agh_alloc_group_header         agh,
                             sld_storage_location_detail    shm,
                             dgrd_delivered_grd             dgrd,
                             pcpq_pc_product_quality        pcpq,
                             pcpch_pc_payble_content_header pcpch,
                             aml_attribute_master_list      aml
                       where gmr.internal_contract_ref_no =
                             pcm.internal_contract_ref_no(+)
                         and pcm.internal_contract_ref_no =
                             pcdi.internal_contract_ref_no
                         and pcdi.pcdi_id = pci.pcdi_id
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pcpq.pcpq_id = pci.pcpq_id
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and pcm.contract_type = 'CONCENTRATES'
                         and pcm.contract_status = 'In Position'
                         and pcm.is_tolling_contract = 'N'
                         and pcm.is_tolling_extn = 'N'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and dgrd.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcpq.dbd_id = pc_dbd_id
                         and agh.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.status_id = gsm.status_id
                         and agh.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                         and pcpq.is_active = 'Y'
                         and upper(agh.realized_status) in
                             ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED',
                              'REVERSEUNDERCMA')
                         and dgrd.status = 'Active'
                         and dgrd.net_weight > 0
                         and gmr.is_internal_movement = 'N'
                         and pcpch.internal_contract_ref_no =
                             pcm.internal_contract_ref_no
                         and pcpch.dbd_id = pc_dbd_id
                         and pcpch.element_id = aml.attribute_id
                      union all -- Internal movement Not sure why contract details are null ?? need to check
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
                             null product_group_type,
                             null issue_date,
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
                             null assay_header_id,
                             grd.quality_id quality_id,
                             null m2m_inco_term,
                             null is_tolling_contract,
                             null is_tolling_extn,
                             pd_trade_date payment_due_date,
                             aml.attribute_id element_id,
                             aml.attribute_name element_name
                      
                        from grd_goods_record_detail        grd,
                             gmr_goods_movement_record      gmr,
                             sld_storage_location_detail    shm,
                             pdm_productmaster              pdm,
                             pdtm_product_type_master       pdtm,
                             pci_physical_contract_item     pci,
                             pcdi_pc_delivery_item          pcdi,
                             pcpch_pc_payble_content_header pcpch,
                             aml_attribute_master_list      aml
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and gmr.is_internal_movement = 'Y'
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.shed_id = shm.storage_loc_id(+)
                         and grd.product_id = pdm.product_id
                         and pdm.product_type_id = pdtm.product_type_id
                         and pdtm.product_type_name = 'Composite'
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and nvl(grd.inventory_status, 'NA') <> 'Out'
                         and grd.internal_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pci.pcdi_id = pcdi.pcdi_id
                         and pcdi.internal_contract_ref_no =
                             pcpch.internal_contract_ref_no
                         and pci.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcpch.dbd_id = pc_dbd_id
                         and pcpch.element_id = aml.attribute_id) temp,
                     mv_conc_qat_quality_valuation mv_qat,
                     mvp_m2m_valuation_point mvp,
                     mvpl_m2m_valuation_point_loc mvpl,
                     v_der_instrument_price_unit vdip
               where temp.corporate_id = mv_qat.corporate_id
                 and temp.quality_id = mv_qat.conc_quality_id
                 and mv_qat.instrument_id = vdip.instrument_id(+)
                 and temp.corporate_id = mvp.corporate_id
                 and temp.product_id = mvp.product_id
                 and temp. issue_date <= pd_trade_date
                 and mvp.mvp_id = mvpl.mvp_id
                 and mvpl.loc_city_id = temp.city_id
                 and temp.element_id = mv_qat.attribute_id) m2m;
    --End of insert into tmpc for Inventory  Concentrate
  
    for cur_ppu in (select tmpc.conc_product_id,
                           ppu.product_price_unit_id
                      from tmpc_temp_m2m_pre_check tmpc,
                           pdm_productmaster       pdm,
                           v_ppu_pum               ppu,
                           ak_corporate            akc
                     where tmpc.corporate_id = pc_corporate_id
                       and tmpc.product_type = 'CONCENTRATES'
                       and tmpc.is_tolling_contract = 'N'
                       and tmpc.is_tolling_extn = 'N'
                       and tmpc.conc_product_id = pdm.product_id
                       and ppu.product_id = pdm.product_id
                       and ppu.weight_unit_id = pdm.base_quantity_unit
                       and ppu.cur_id = akc.base_cur_id
                     group by tmpc.conc_product_id,
                              ppu.product_price_unit_id)
    loop
    
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.conc_base_price_unit_id_ppu = cur_ppu.product_price_unit_id
       where tmpc.corporate_id = pc_corporate_id
         and tmpc.product_type = 'CONCENTRATES'
         and tmpc.is_tolling_contract = 'N'
         and tmpc.is_tolling_extn = 'N'
         and tmpc.conc_product_id = cur_ppu.conc_product_id;
    
    end loop;
  
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
    ----------------------------- 
    vc_error_loc := 6;
    for cc2 in (select t.pcdi_id,
                       t.internal_contract_ref_no,
                       t.internal_contract_item_ref_no,
                       t.basis_type,
                       t.transit_days,
                       t.contract_ref_no,
                       t.expected_delivery_month,
                       t.expected_delivery_year,
                       t.element_id,
                       t.date_type,
                       t.ship_arrival_date,
                       t.ship_arrival_days,
                       t.expected_ship_arrival_date,
                       (case
                         when t.ship_arrival_date = 'Start Date' then
                          to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                   'Mon-yyyy'),'dd-Mon-yyyy')
                         when t.ship_arrival_date = 'End Date' then
                          last_day(t.expected_ship_arrival_date)
                         else
                          (to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                    'Mon-yyyy'),'dd-Mon-yyyy') +
                          trunc((last_day(t.expected_ship_arrival_date) -
                                 to_date('01-' ||
                                          to_char(t.expected_ship_arrival_date,
                                                  'Mon-yyyy'),'dd-Mon-yyyy')) / 2))
                       end) + t.ship_arrival_days basis_month_year
                  from (select pcdi.pcdi_id,
                               pcdi.internal_contract_ref_no,
                               pci.internal_contract_item_ref_no,
                               pcdi.basis_type,
                               nvl(pcdi.transit_days, 0) transit_days,
                               pcm.contract_ref_no,
                               pci.expected_delivery_month,
                               pci.expected_delivery_year,
                               pqca.element_id,
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
                          from pcdi_pc_delivery_item         pcdi,
                               pci_physical_contract_item    pci,
                               pcm_physical_contract_main    pcm,
                               pcpd_pc_product_definition    pcpd,
                               pcpq_pc_product_quality       pcpq,
                               ash_assay_header              ash,
                               asm_assay_sublot_mapping      asm,
                               pqca_pq_chemical_attributes   pqca,
                               mv_conc_qat_quality_valuation qat,
                               pdm_productmaster             pdm
                        --qat_quality_attributes     qat
                         where pcdi.pcdi_id = pci.pcdi_id
                           and pcdi.internal_contract_ref_no =
                               pcm.internal_contract_ref_no
                           and pcm.internal_contract_ref_no =
                               pcpd.internal_contract_ref_no
                           and pcpd.product_id = qat.conc_product_id
                           and pcm.contract_status = 'In Position'
                           and pcm.contract_type = 'CONCENTRATES'
                           and pcpd.input_output = 'Input'
                           and pcm.corporate_id = pc_corporate_id
                           and pci.item_qty > 0
                           and pci.pcpq_id = pcpq.pcpq_id
                              --and pcpq.quality_template_id = qat.quality_id
                           and pcpq.assay_header_id = ash.ash_id
                           and ash.ash_id = asm.ash_id
                           and asm.asm_id = pqca.asm_id
                           and pcpq.quality_template_id = qat.conc_quality_id
                           and pqca.element_id = qat.attribute_id
                           and qat.conc_product_id = pdm.product_id
                           and nvl(pdm.valuation_against_underlying, 'Y') = 'Y'
                           and qat.corporate_id = pc_corporate_id
                           and pci.dbd_id = pc_dbd_id
                           and pcdi.dbd_id = pc_dbd_id
                           and pcm.dbd_id = pc_dbd_id
                           and pcpq.dbd_id = pc_dbd_id
                           and pcpd.dbd_id = pc_dbd_id
                           and pcdi.is_active = 'Y'
                           and pci.is_active = 'Y'
                           and pcm.is_active = 'Y'
                           and pcpd.is_active = 'Y'
                           and pcpq.is_active = 'Y') t,
                       tmpc_temp_m2m_pre_check tmpc
                 where tmpc.section_name = 'OPEN'
                   and tmpc.corporate_id = pc_corporate_id
                   and tmpc.product_type = 'CONCENTRATES'
                   and tmpc.is_tolling_contract = 'N'
                   and tmpc.is_tolling_extn = 'N'
                   and tmpc.internal_contract_item_ref_no =
                       t.internal_contract_item_ref_no
                   and tmpc.element_id = t.element_id
                   and tmpc.pcdi_id = t.pcdi_id)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.shipment_month = to_char(cc2.basis_month_year, 'Mon'),
             tmpc.shipment_year  = to_char(cc2.basis_month_year, 'YYYY'),
             tmpc.shipment_date  = cc2.basis_month_year
       where tmpc.pcdi_id = cc2.pcdi_id
         and tmpc.internal_contract_item_ref_no =
             cc2.internal_contract_item_ref_no
         and tmpc.element_id = cc2.element_id
         and tmpc.section_name = 'OPEN'
         and tmpc.product_type = 'CONCENTRATES'
         and tmpc.is_tolling_contract = 'N'
         and tmpc.is_tolling_extn = 'N'
         and tmpc.corporate_id = pc_corporate_id;
    end loop;
    -------------------- 
    commit;
    for cc2 in (select t.pcdi_id,
                       t.internal_contract_ref_no,
                       t.internal_contract_item_ref_no,
                       t.basis_type,
                       t.transit_days,
                       t.contract_ref_no,
                       t.expected_delivery_month,
                       t.expected_delivery_year,
                       t.element_id,
                       t.date_type,
                       t.ship_arrival_date,
                       t.ship_arrival_days,
                       t.expected_ship_arrival_date,
                       (case
                         when t.ship_arrival_date = 'Start Date' then
                          to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                   'Mon-yyyy'),'dd-Mon-yyyy')
                         when t.ship_arrival_date = 'End Date' then
                          last_day(t.expected_ship_arrival_date)
                         else
                          (to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                    'Mon-yyyy'),'dd-Mon-yyyy') +
                          trunc((last_day(t.expected_ship_arrival_date) -
                                 to_date('01-' ||
                                          to_char(t.expected_ship_arrival_date,
                                                  'Mon-yyyy'),'dd-Mon-yyyy')) / 2))
                       end) + t.ship_arrival_days basis_month_year
                  from (select pcdi.pcdi_id,
                               pcdi.internal_contract_ref_no,
                               pci.internal_contract_item_ref_no,
                               pcdi.basis_type,
                               nvl(pcdi.transit_days, 0) transit_days,
                               pcm.contract_ref_no,
                               pci.expected_delivery_month,
                               pci.expected_delivery_year,
                               pqca.element_id,
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
                          from pcdi_pc_delivery_item        pcdi,
                               pci_physical_contract_item   pci,
                               pcm_physical_contract_main   pcm,
                               pcpd_pc_product_definition   pcpd,
                               pcpq_pc_product_quality      pcpq,
                               ash_assay_header             ash,
                               asm_assay_sublot_mapping     asm,
                               pqca_pq_chemical_attributes  pqca,
                               v_conc_qat_quality_valuation qat,
                               pdm_productmaster            pdm
                        --qat_quality_attributes     qat
                         where pcdi.pcdi_id = pci.pcdi_id
                           and pcdi.internal_contract_ref_no =
                               pcm.internal_contract_ref_no
                           and pcm.internal_contract_ref_no =
                               pcpd.internal_contract_ref_no
                           and pcpd.product_id = qat.conc_product_id
                           and pcm.contract_status = 'In Position'
                           and pcm.contract_type = 'CONCENTRATES'
                           and pcpd.input_output = 'Input'
                           and pcm.corporate_id = pc_corporate_id
                           and pci.item_qty > 0
                           and pci.pcpq_id = pcpq.pcpq_id
                              --and pcpq.quality_template_id = qat.quality_id
                           and pcpq.assay_header_id = ash.ash_id
                           and ash.ash_id = asm.ash_id
                           and asm.asm_id = pqca.asm_id
                           and pcpq.quality_template_id = qat.conc_quality_id
                           and pqca.element_id = qat.attribute_id
                           and qat.conc_product_id = pdm.product_id
                           and nvl(pdm.valuation_against_underlying, 'Y') = 'N'
                           and qat.corporate_id = pc_corporate_id
                           and pci.dbd_id = pc_dbd_id
                           and pcdi.dbd_id = pc_dbd_id
                           and pcm.dbd_id = pc_dbd_id
                           and pcpq.dbd_id = pc_dbd_id
                           and pcpd.dbd_id = pc_dbd_id
                           and pcdi.is_active = 'Y'
                           and pci.is_active = 'Y'
                           and pcm.is_active = 'Y'
                           and pcpq.is_active = 'Y'
                           and pcpd.is_active = 'Y') t,
                       tmpc_temp_m2m_pre_check tmpc
                 where tmpc.section_name = 'OPEN'
                   and tmpc.corporate_id = pc_corporate_id
                   and tmpc.product_type = 'CONCENTRATES'
                   and tmpc.is_tolling_contract = 'N'
                   and tmpc.is_tolling_extn = 'N'
                   and tmpc.internal_contract_item_ref_no =
                       t.internal_contract_item_ref_no
                   and tmpc.element_id = t.element_id
                   and tmpc.pcdi_id = t.pcdi_id)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.shipment_month = to_char(cc2.basis_month_year, 'Mon'),
             tmpc.shipment_year  = to_char(cc2.basis_month_year, 'YYYY'),
             tmpc.shipment_date  = cc2.basis_month_year
       where tmpc.pcdi_id = cc2.pcdi_id
         and tmpc.internal_contract_item_ref_no =
             cc2.internal_contract_item_ref_no
         and tmpc.element_id = cc2.element_id
         and tmpc.section_name = 'OPEN'
         and tmpc.product_type = 'CONCENTRATES'
         and tmpc.is_tolling_contract = 'N'
         and tmpc.is_tolling_extn = 'N'
         and tmpc.corporate_id = pc_corporate_id;
    end loop;
    -------
    commit;
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
                  and tmpc.is_tolling_contract = 'N'
                  and tmpc.is_tolling_extn = 'N'
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
           and tmpc.is_tolling_contract = 'N'
           and tmpc.is_tolling_extn = 'N'
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
    begin
      for cc in (select tmpc.conc_product_id,
                        tmpc.conc_quality_id,
                        tmpc.element_id,
                        qat.instrument_id,
                        qat.product_derivative_id,
                        qat.eval_basis,
                        qat.exch_valuation_month,
                        vdip.price_unit_id
                   from tmpc_temp_m2m_pre_check      tmpc,
                        v_conc_qat_quality_valuation qat,
                        v_der_instrument_price_unit  vdip
                  where tmpc.conc_product_id = qat.conc_product_id
                    and tmpc.conc_quality_id = qat.conc_quality_id
                    and tmpc.corporate_id = qat.corporate_id
                    and qat.instrument_id = vdip.instrument_id(+)
                    and tmpc.element_id = qat.attribute_id
                    and tmpc.corporate_id = pc_corporate_id
                    and tmpc.product_type = 'CONCENTRATES'
                    and tmpc.is_tolling_contract = 'N'
                    and tmpc.is_tolling_extn = 'N')
      loop
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.instrument_id     = cc.instrument_id,
               tmpc.value_type        = cc.eval_basis,
               tmpc.derivative_def_id = cc.product_derivative_id,
               tmpc.m2m_price_unit_id = cc.price_unit_id
         where tmpc.product_type = 'CONCENTRATES'
           and tmpc.is_tolling_contract = 'N'
           and tmpc.is_tolling_extn = 'N'
           and tmpc.conc_product_id = cc.conc_product_id
           and tmpc.conc_quality_id = cc.conc_quality_id
           and tmpc.element_id = cc.element_id
           and tmpc.corporate_id = pc_corporate_id;
      end loop;
      commit;
    
    end;
    -----------------------
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
                      mv_conc_qat_quality_valuation qat,
                      pdm_productmaster             pdm
                where tmpc.quality_id = qat.quality_id
                  and tmpc.corporate_id = qat.corporate_id
                  and tmpc.conc_product_id = pdm.product_id
                  and nvl(pdm.valuation_against_underlying, 'Y') = 'Y'
                  and tmpc.corporate_id = pc_corporate_id
                  and tmpc.value_type <> 'FIXED'
                  and tmpc.product_type = 'CONCENTRATES'
                  and tmpc.is_tolling_contract = 'N'
                  and tmpc.is_tolling_extn = 'N'
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
           and tmpc.is_tolling_contract = 'N'
           and tmpc.is_tolling_extn = 'N'
           and tmpc.corporate_id = cc.corporate_id;
      end if;
    end loop;
    commit;
    --------
  
    for cc in (select tmpc.corporate_id,
                      tmpc.shipment_month,
                      tmpc.shipment_year,
                      tmpc.instrument_id,
                      decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') trade_type,
                      tmpc.quality_id,
                      qat.eval_basis,
                      qat.exch_valuation_month
                 from tmpc_temp_m2m_pre_check      tmpc,
                      v_conc_qat_quality_valuation qat,
                      pdm_productmaster            pdm
                where tmpc.conc_quality_id = qat.quality_id
                  and tmpc.conc_product_id = pdm.product_id
                  and nvl(pdm.valuation_against_underlying, 'Y') = 'N'
                  and tmpc.corporate_id = qat.corporate_id
                  and tmpc.corporate_id = pc_corporate_id
                  and tmpc.value_type <> 'FIXED'
                  and tmpc.product_type = 'CONCENTRATES'
                  and tmpc.is_tolling_contract = 'N'
                  and tmpc.is_tolling_extn = 'N'
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
           and tmpc.is_tolling_contract = 'N'
           and tmpc.is_tolling_extn = 'N'
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
                   and tmpc.is_tolling_contract = 'N'
                   and tmpc.is_tolling_extn = 'N'
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
         and tmpc.is_tolling_contract = 'N'
         and tmpc.is_tolling_extn = 'N'
         and tmpc.corporate_id = ccv.corporate_id;
    end loop;
    commit;
  
    vc_error_loc := 9;
  
    for cc in (select tmpc.corporate_id,
                      tmpc.conc_product_id,
                      tmpc.product_id,
                      akc.base_cur_id,
                      pdm.base_quantity_unit,
                      ppu.internal_price_unit_id,
                      pum.price_unit_id,
                      tmpc.element_id
                 from tmpc_temp_m2m_pre_check tmpc,
                      ak_corporate            akc,
                      pdm_productmaster       pdm,
                      pdm_productmaster       pdm_conc,
                      ppu_product_price_units ppu,
                      pum_price_unit_master   pum
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.corporate_id = akc.corporate_id
                  and tmpc.product_id = pdm.product_id
                  and tmpc.product_type = 'CONCENTRATES'
                  and tmpc.is_tolling_contract = 'N'
                  and tmpc.is_tolling_extn = 'N'
                  and tmpc.conc_product_id = pdm_conc.product_id
                  and nvl(pdm_conc.valuation_against_underlying, 'Y') = 'Y'
                  and ppu.product_id = pdm.product_id
                  and ppu.is_active = 'Y'
                  and ppu.is_deleted = 'N'
                  and ppu.price_unit_id = pum.price_unit_id
                  and pum.cur_id = akc.base_cur_id
                  and nvl(pum.weight, 1) = 1
                  and pum.weight_unit_id = pdm.base_quantity_unit
                group by tmpc.corporate_id,
                         tmpc.conc_product_id,
                         tmpc.product_id,
                         akc.base_cur_id,
                         pdm.base_quantity_unit,
                         ppu.internal_price_unit_id,
                         pum.price_unit_id,
                         tmpc.element_id
               union all
               select tmpc.corporate_id,
                      tmpc.conc_product_id,
                      tmpc.product_id,
                      akc.base_cur_id,
                      pdm_conc.base_quantity_unit,
                      ppu.internal_price_unit_id,
                      pum.price_unit_id,
                      tmpc.element_id
                 from tmpc_temp_m2m_pre_check tmpc,
                      ak_corporate            akc,
                      pdm_productmaster       pdm,
                      pdm_productmaster       pdm_conc,
                      ppu_product_price_units ppu,
                      pum_price_unit_master   pum
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.corporate_id = akc.corporate_id
                  and tmpc.product_id = pdm.product_id
                  and tmpc.product_type = 'CONCENTRATES'
                  and tmpc.is_tolling_contract = 'N'
                  and tmpc.is_tolling_extn = 'N'
                  and tmpc.conc_product_id = pdm_conc.product_id
                  and ppu.product_id = pdm_conc.product_id
                  and nvl(pdm_conc.valuation_against_underlying, 'Y') = 'N'
                  and ppu.is_active = 'Y'
                  and ppu.is_deleted = 'N'
                  and ppu.price_unit_id = pum.price_unit_id
                  and pum.cur_id = akc.base_cur_id
                  and nvl(pum.weight, 1) = 1
                  and pum.weight_unit_id = pdm_conc.base_quantity_unit
                group by tmpc.corporate_id,
                         tmpc.product_id,
                         tmpc.conc_product_id,
                         akc.base_cur_id,
                         pdm_conc.base_quantity_unit,
                         ppu.internal_price_unit_id,
                         pum.price_unit_id,
                         tmpc.element_id)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.base_price_unit_id_in_ppu = cc.internal_price_unit_id,
             tmpc.base_price_unit_id_in_pum = cc.price_unit_id
       where tmpc.product_type = 'CONCENTRATES'
         and tmpc.is_tolling_contract = 'N'
         and tmpc.is_tolling_extn = 'N'
         and tmpc.corporate_id = cc.corporate_id
         and tmpc.element_id = cc.element_id
         and tmpc.conc_product_id = cc.conc_product_id
         and tmpc.product_id = cc.product_id;
      commit;
    
    end loop;
    commit;
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
      select t.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-030',
             t.product_name || '(' || t.price_unit_name || ')',
             null,
             pc_process,
             systimestamp,
             pc_user_id,
             pd_trade_date
        from (select tmpc.corporate_id,
                     tmpc.product_id,
                     pdm.product_desc product_name,
                     akc.base_cur_id,
                     pdm.base_quantity_unit,
                     pum.price_unit_id,
                     pum.price_unit_name
                from tmpc_temp_m2m_pre_check tmpc,
                     ak_corporate            akc,
                     pdm_productmaster       pdm,
                     pdm_productmaster       pdm_conc,
                     pum_price_unit_master   pum
               where tmpc.corporate_id = pc_corporate_id
                 and tmpc.corporate_id = akc.corporate_id
                 and tmpc.product_id = pdm.product_id
                 and tmpc.product_type = 'CONCENTRATES'
                 and tmpc.is_tolling_contract = 'N'
                 and tmpc.is_tolling_extn = 'N'
                 and tmpc.conc_product_id = pdm_conc.product_id
                 and nvl(pdm_conc.valuation_against_underlying, 'Y') = 'Y'
                 and pum.cur_id = akc.base_cur_id
                 and nvl(pum.weight, 1) = 1
                 and pum.weight_unit_id = pdm.base_quantity_unit
               group by tmpc.corporate_id,
                        tmpc.product_id,
                        akc.base_cur_id,
                        pdm.base_quantity_unit,
                        pum.price_unit_name,
                        pdm.product_desc,
                        pum.price_unit_id
              union all
              select tmpc.corporate_id,
                     tmpc.conc_product_id product_id,
                     pdm_conc.product_desc product_name,
                     akc.base_cur_id,
                     pdm_conc.base_quantity_unit,
                     pum.price_unit_id,
                     pum.price_unit_name
                from tmpc_temp_m2m_pre_check tmpc,
                     ak_corporate            akc,
                     pdm_productmaster       pdm,
                     pdm_productmaster       pdm_conc,
                     pum_price_unit_master   pum
               where tmpc.corporate_id = pc_corporate_id
                 and tmpc.corporate_id = akc.corporate_id
                 and tmpc.product_id = pdm.product_id
                 and tmpc.product_type = 'CONCENTRATES'
                 and tmpc.is_tolling_contract = 'N'
                 and tmpc.is_tolling_extn = 'N'
                 and tmpc.conc_product_id = pdm_conc.product_id
                 and nvl(pdm_conc.valuation_against_underlying, 'Y') = 'N'
                 and pum.cur_id = akc.base_cur_id
                 and nvl(pum.weight, 1) = 1
                 and pum.weight_unit_id = pdm_conc.base_quantity_unit
               group by tmpc.corporate_id,
                        pum.price_unit_name,
                        tmpc.conc_product_id,
                        akc.base_cur_id,
                        pdm_conc.product_desc,
                        pdm_conc.base_quantity_unit,
                        pum.price_unit_id) t
       where not exists (select 1
                from ppu_product_price_units ppu
               where ppu.product_id = t.product_id
                 and ppu.price_unit_id = t.price_unit_id
                 and ppu.is_active = 'Y'
                 and ppu.is_deleted = 'N');
  
    vc_error_loc := 13;
  
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
             ' Price,Prompt Date:' || drm.dr_id_name || ' Trade Date(' ||
             to_char(cdim.valid_quote_date, 'dd-Mon-yyyy') || ')',
             f_string_aggregate(tmpc.contract_ref_no),
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
             pum_price_unit_master        pum,
             cdim_corporate_dim           cdim
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
         and tmpc.is_tolling_contract = 'N'
         and tmpc.is_tolling_extn = 'N'
         and div.is_deleted = 'N'
         and cdim.corporate_id = pc_corporate_id
         and cdim.instrument_id = dim.instrument_id
         and not exists
       (select 1
                from eodeom_derivative_quote_detail dqd,
                     cdim_corporate_dim             cdim
               where tmpc.valuation_dr_id = dqd.dr_id
                 and tmpc.product_type = 'CONCENTRATES'
                 and tmpc.is_tolling_contract = 'N'
                 and tmpc.is_tolling_extn = 'N'
                 and div.available_price_id = dqd.available_price_id
                 and div.price_source_id = dqd.price_source_id
                 and div.price_unit_id = dqd.price_unit_id
                 and dqd.dq_trade_date = cdim.valid_quote_date
                 and dqd.corporate_id = pc_corporate_id
                 and dqd.dbd_id = gvc_dbd_id
                 and dqd.price is not null
                 and cdim.corporate_id = pc_corporate_id
                 and cdim.instrument_id = dqd.instrument_id)
       group by tmpc.corporate_id,
                'Settlement Price missing for ' || dim.instrument_name ||
                ',Price Source:' || ps.price_source_name || ',Price Unit:' ||
                pum.price_unit_name || ',' || apm.available_price_name ||
                ' Price,Prompt Date:' || drm.dr_id_name || ' Trade Date(' ||
                to_char(cdim.valid_quote_date, 'dd-Mon-yyyy') || ')';
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
    vc_error_loc := 14;
  
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
         and tmpc.is_tolling_contract = 'N'
         and tmpc.is_tolling_extn = 'N'
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
  
    vn_no_loc_diff_error_count := sql%rowcount;
    commit;
  
    vc_error_loc := 15;
  
    if vn_no_loc_diff_error_count = 0 then
      sp_update_ld_concentrates(pc_corporate_id,
                                pd_trade_date,
                                pc_user_id,
                                pc_process);
    end if;
    vc_error_loc := 16;
  
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 'finished tmpc and i commit now');
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Precheck M2M',
                 gvc_process || ' Before Commit @' || systimestamp);
   ---Added Suresh
   delete from temp_pci_treatment_elemnts temp
    where temp.corporate_id = pc_corporate_id;
   commit;
   insert into temp_pci_treatment_elemnts
     (corporate_id, internal_contract_item_ref_no, element_id)
     select pc_corporate_id,
            pci.internal_contract_item_ref_no,
            ted.element_id
       from pci_physical_contract_item    pci,
            pcdi_pc_delivery_item         pcdi,
            dith_di_treatment_header      dith,
            ted_treatment_element_details ted,
            pcth_pc_treatment_header      pcth
      where pci.pcdi_id = pcdi.pcdi_id
        and pcdi.pcdi_id = dith.pcdi_id
        and dith.pcth_id = pcth.pcth_id
        and pcth.pcth_id = ted.pcth_id
        and pci.dbd_id = pc_dbd_id
        and pcdi.dbd_id = pc_dbd_id
        and dith.dbd_id = pc_dbd_id
        and ted.dbd_id = pc_dbd_id
        and pcth.dbd_id = pc_dbd_id
        and pcth.is_active = 'Y'
        and pcdi.is_active = 'Y'
        and pci.is_active = 'Y'
        and ted.is_active = 'Y'
        and dith.is_active = 'Y'
      group by pci.internal_contract_item_ref_no,
               ted.element_id;
      commit;
  
    delete from temp_pci_refine_elemnts temp
     where temp.corporate_id = pc_corporate_id;
   commit;
   insert into temp_pci_refine_elemnts
     (corporate_id, internal_contract_item_ref_no, element_id)
     select pc_corporate_id,
            pci.internal_contract_item_ref_no,
            red.element_id
       from pci_physical_contract_item   pci,
            pcdi_pc_delivery_item        pcdi,
            dirh_di_refining_header      dirh,
            red_refining_element_details red,
            pcrh_pc_refining_header      pcrh
      where pci.pcdi_id = pcdi.pcdi_id
        and pcdi.pcdi_id = dirh.pcdi_id
        and dirh.pcrh_id = pcrh.pcrh_id
        and pcrh.pcrh_id = red.pcrh_id
        and pci.dbd_id = pc_dbd_id
        and pcdi.dbd_id = pc_dbd_id
        and dirh.dbd_id = pc_dbd_id
        and red.dbd_id = pc_dbd_id
        and pcrh.dbd_id = pc_dbd_id
        and pcrh.is_active = 'Y'
        and pcdi.is_active = 'Y'
        and pci.is_active = 'Y'
        and red.is_active = 'Y'
        and dirh.is_active = 'Y'
      group by pci.internal_contract_item_ref_no,
               red.element_id;
      commit;

    ---***For loop for calling the sp_calc_m2m_tc_pc_rc_charge
    --which will do the precheck for the tc,rc and pc
    --  m2m TC chrages
    begin
      for cc_tmpc in (select tmpc.corporate_id,
                             tmpc.conc_product_id,
                             pdm.product_desc conc_product_desc,
                             tmpc.conc_quality_id,
                             qat.quality_name conc_qat_name,
                             tmpc.element_id,
                             tmpc.element_name,
                             tmpc.conc_base_price_unit_id_ppu,
                             tmpc.shipment_month,
                             tmpc.shipment_year,
                             tmpc.mvp_id valuation_point_id,
                             tmpc.valuation_point,
                             tmpc.payment_due_date
                        from tmpc_temp_m2m_pre_check tmpc,
                             pdm_productmaster       pdm,
                             qat_quality_attributes  qat
                       where tmpc.product_type = 'CONCENTRATES'
                         and tmpc.is_tolling_contract = 'N'
                         and tmpc.is_tolling_extn = 'N'
                         and tmpc.corporate_id = pc_corporate_id
                         and tmpc.conc_product_id = pdm.product_id
                         and tmpc.conc_quality_id = qat.quality_id
                         and exists(select * from temp_pci_treatment_elemnts temp
                         where temp.corporate_id=pc_corporate_id
                           and temp.internal_contract_item_ref_no=tmpc.internal_contract_item_ref_no
                           and temp.element_id=tmpc.element_id)
                       group by tmpc.corporate_id,
                                tmpc.conc_product_id,
                                pdm.product_desc,
                                tmpc.conc_quality_id,
                                tmpc.conc_base_price_unit_id_ppu,
                                tmpc.element_id,
                                tmpc.valuation_point,
                                tmpc.mvp_id,
                                qat.quality_name,
                                tmpc.element_name,
                                tmpc.shipment_month,
                                tmpc.shipment_year,
                                tmpc.payment_due_date)
      loop
        --for treatment charge precheck
      
        pkg_phy_pre_check_process.sp_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                         pd_trade_date,
                                                         cc_tmpc.conc_product_id,
                                                         cc_tmpc.conc_quality_id,
                                                         cc_tmpc.valuation_point_id,
                                                         'Treatment Charges',
                                                         cc_tmpc.element_id,
                                                         cc_tmpc.shipment_month,
                                                         cc_tmpc.shipment_year,
                                                         cc_tmpc.conc_base_price_unit_id_ppu,
                                                         cc_tmpc.payment_due_date,
                                                         pn_charge_amt,
                                                         vc_exch_rate_string);
      
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
        else
        
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.m2m_treatment_charge = pn_charge_amt,
                 tmpc.m2m_tc_fw_exch_rate  = vc_exch_rate_string
           where tmpc.corporate_id = pc_corporate_id
             and tmpc.conc_product_id = cc_tmpc.conc_product_id
             and tmpc.conc_quality_id = cc_tmpc.conc_quality_id
             and tmpc.mvp_id = cc_tmpc.valuation_point_id
             and tmpc.element_id = cc_tmpc.element_id
             and tmpc.shipment_month = cc_tmpc.shipment_month
             and tmpc.shipment_year = cc_tmpc.shipment_year
             and tmpc.payment_due_date = cc_tmpc.payment_due_date;
        
        end if;
      end loop;
  
    -- m2m rc charges
      for cc_tmpc in (select tmpc.corporate_id,
                             tmpc.conc_product_id,
                             pdm.product_desc conc_product_desc,
                             tmpc.conc_quality_id,
                             qat.quality_name conc_qat_name,
                             tmpc.element_id,
                             tmpc.element_name,
                             tmpc.conc_base_price_unit_id_ppu,
                             tmpc.shipment_month,
                             tmpc.shipment_year,
                             tmpc.mvp_id valuation_point_id,
                             tmpc.valuation_point,
                             tmpc.payment_due_date
                        from tmpc_temp_m2m_pre_check tmpc,
                             pdm_productmaster       pdm,
                             qat_quality_attributes  qat
                       where tmpc.product_type = 'CONCENTRATES'
                         and tmpc.is_tolling_contract = 'N'
                         and tmpc.is_tolling_extn = 'N'
                         and tmpc.corporate_id = pc_corporate_id
                         and tmpc.conc_product_id = pdm.product_id
                         and tmpc.conc_quality_id = qat.quality_id
                         and exists(select * from temp_pci_refine_elemnts temp
                         where temp.corporate_id=pc_corporate_id
                           and temp.internal_contract_item_ref_no=tmpc.internal_contract_item_ref_no
                           and temp.element_id=tmpc.element_id)
                       group by tmpc.corporate_id,
                                tmpc.conc_product_id,
                                pdm.product_desc,
                                tmpc.conc_quality_id,
                                tmpc.conc_base_price_unit_id_ppu,
                                tmpc.element_id,
                                tmpc.valuation_point,
                                tmpc.mvp_id,
                                qat.quality_name,
                                tmpc.element_name,
                                tmpc.shipment_month,
                                tmpc.shipment_year,
                                tmpc.payment_due_date)
      loop
        pkg_phy_pre_check_process.sp_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                         pd_trade_date,
                                                         cc_tmpc.conc_product_id,
                                                         cc_tmpc.conc_quality_id,
                                                         cc_tmpc.valuation_point_id, --valuation_id
                                                         'Refining Charges', --charge_type
                                                         cc_tmpc.element_id,
                                                         cc_tmpc.shipment_month,
                                                         cc_tmpc.shipment_year,
                                                         cc_tmpc.conc_base_price_unit_id_ppu,
                                                         cc_tmpc.payment_due_date,
                                                         pn_charge_amt,
                                                         vc_exch_rate_string);
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
        else
        
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.m2m_refining_charge = pn_charge_amt,
                 tmpc.m2m_rc_fw_exch_rate = vc_exch_rate_string
           where tmpc.corporate_id = pc_corporate_id
             and tmpc.conc_product_id = cc_tmpc.conc_product_id
             and tmpc.conc_quality_id = cc_tmpc.conc_quality_id
             and tmpc.mvp_id = cc_tmpc.valuation_point_id
             and tmpc.element_id = cc_tmpc.element_id
             and tmpc.shipment_month = cc_tmpc.shipment_month
             and tmpc.shipment_year = cc_tmpc.shipment_year
             and tmpc.payment_due_date = cc_tmpc.payment_due_date;
        end if;
      end loop;
    
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
                                                           'procedure sp_pre_check_m2m_conc_values',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_error_loc,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;
  /*End  of Concentrate Precheck */

  procedure sp_pre_check_m2m_tolling_extn(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_dbd_id       varchar2,
                                          pc_user_id      varchar2,
                                          pc_process      varchar2) is
    /******************************************************************************************************************************************
    procedure name                            : sp_pre_check_m2m_values
    author                                    : Suresh Gottipati
    created date                              : 20th Dec 2011
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
    vc_error_loc            varchar2(100);
    pn_charge_amt           number;
    pc_charge_price_unit_id varchar2(20);
     vc_exch_rate_string        varchar2(100);
  begin
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
                     pcmte_pcm_tolling_ext      pcmte,
                     pcpd_pc_product_definition pcpd,
                     pdm_productmaster          pdm,
                     cym_countrymaster          cym,
                     cim_citymaster             cim
               where pci.dbd_id = pc_dbd_id
                 and pci.is_active = 'Y'
                 and pcm.contract_status = 'In Position'
                 and pcm.internal_contract_ref_no =
                     pcmte.int_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpd.dbd_id = pci.dbd_id
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pci.dbd_id = pcdi.dbd_id
                 and pcm.dbd_id = pc_dbd_id
                 and pcpd.dbd_id = pc_dbd_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcdi.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and pcm.issue_date <= pd_trade_date
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcm.is_tolling_contract = 'Y'
                 and pcm.is_tolling_extn = 'Y'
                 and pcm.is_pass_through='N'
                 and pcpd.input_output = 'Input'
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
                             pcmte_pcm_tolling_ext       pcmte,
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
                         and pcm.internal_contract_ref_no =
                             pcmte.int_contract_ref_no
                         and pcm.is_tolling_contract = 'Y'
                         and pcm.is_tolling_extn = 'Y'
                         and pcm.is_pass_through='N'
                         and grd.shed_id = shm.storage_loc_id(+)
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                         and pcm.is_active = 'Y'
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
                               else
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                             end end city_id,
                             dgrd.quality_id
                        from gmr_goods_movement_record   gmr,
                             pci_physical_contract_item  pci,
                             pcm_physical_contract_main  pcm,
                             pcmte_pcm_tolling_ext       pcmte,
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
                         and pcm.internal_contract_ref_no =
                             pcmte.int_contract_ref_no
                         and pcm.is_tolling_contract = 'Y'
                         and pcm.is_tolling_extn = 'Y'
                         and pcm.is_pass_through='N'
                         and pcdi.pcdi_id = pci.pcdi_id
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.is_deleted = 'N'
                         and agh.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and dgrd.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.status_id = gsm.status_id
                         and agh.is_deleted = 'N'
                         and pcm.contract_status = 'In Position'
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
       product_type,
       is_tolling_contract,
       is_tolling_extn,
       payment_due_date)
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
              'CONCENTRATES',
              pcm.is_tolling_contract,
              pcm.is_tolling_extn,
              pcdi.payment_due_date
         from pcm_physical_contract_main     pcm,
              pcmte_pcm_tolling_ext          pcmte,
              pci_physical_contract_item     pci,
              pcpq_pc_product_quality        pcpq,
              pcdi_pc_delivery_item          pcdi,
              ciqs_contract_item_qty_status  ciqs,
              mvp_m2m_valuation_point        mvp,
              mvpl_m2m_valuation_point_loc   mvpl,
              mv_conc_qat_quality_valuation  mv_qat,
              v_derivatives_val_month        vdvm,
              v_der_instrument_price_unit    vdip,
              aml_attribute_master_list      aml,
              dipch_di_payablecontent_header dipch,
              pcpch_pc_payble_content_header pcpch
        where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
          and pcm.contract_type = 'CONCENTRATES'
          and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no
          and pcdi.pcdi_id = pci.pcdi_id
          and pci.internal_contract_item_ref_no =
              ciqs.internal_contract_item_ref_no(+)
          and pci.pcpq_id = pcpq.pcpq_id
          and pcm.corporate_id = pc_corporate_id
          and mv_qat.corporate_id = pcm.corporate_id
          and pcm.issue_date <= pd_trade_date
          and pcm.contract_status in ('In Position', 'Pending Approval')
          and pcm.is_tolling_contract = 'Y'
          and pcm.is_tolling_extn = 'Y'
          and pcm.is_pass_through='N'
          and pcm.corporate_id = mvp.corporate_id
          and mv_qat.conc_product_id = mvp.product_id(+)
          and mv_qat.attribute_id = aml.attribute_id
          and mvp.mvp_id = mvpl.mvp_id(+)
          and mvpl.loc_city_id = pci.m2m_city_id
          and pci.internal_contract_item_ref_no =
              vdvm.internal_contract_item_ref_no(+)
          and pcpq.quality_template_id = mv_qat.conc_quality_id
          and mv_qat.instrument_id = vdip.instrument_id(+)
          and pcdi.pcdi_id = dipch.pcdi_id
          and dipch.pcpch_id = pcpch.pcpch_id
          and aml.attribute_id = pcpch.element_id
          and pcpch.payable_type = 'Payable'
          and ciqs.open_qty <> 0
          and pcdi.is_active = 'Y'
          and ciqs.is_active = 'Y'
          and pcm.is_active = 'Y'
          and pci.is_active = 'Y'
          and pcpch.is_active = 'Y'
          and dipch.is_active = 'Y'
          and aml.is_active = 'Y'
          and pcpq.is_active = 'Y'
          and pcm.dbd_id = pc_dbd_id
          and pcdi.dbd_id = pc_dbd_id
          and pci.dbd_id = pc_dbd_id
          and ciqs.dbd_id = pc_dbd_id
          and pcpq.dbd_id = pc_dbd_id
          and pcpch.dbd_id = pc_dbd_id
          and dipch.dbd_id = pc_dbd_id
          and pcm.contract_status <> 'Cancelled');
    vc_error_loc := 4;
    --Insert into tmpc for inventory Concentrate
    insert into tmpc_temp_m2m_pre_check
      (corporate_id,
       product_type,
       conc_product_id,
       conc_quality_id,
       product_id,
       quality_id,
       element_id,
       element_name,
       assay_header_id,
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
       is_tolling_contract,
       is_tolling_extn,
       payment_due_date)
      select m2m.corporate_id,
             m2m.product_group_type,
             m2m.product_id conc_product_id,
             m2m.quality_id conc_quality_id,
             m2m.element_product_id,
             m2m.element_quality_id,
             m2m.element_id,
             m2m.element_name,
             m2m.assay_header_id,
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
             m2m.is_tolling_contract,
             m2m.is_tolling_extn,
             payment_due_date
        from (select temp.corporate_id,
                     temp.product_group_type,
                     mv_qat.product_id element_product_id,
                     mv_qat.quality_id element_quality_id,
                     temp.product_id,
                     temp.quality_id,
                     temp.element_id,
                     temp.element_name,
                     temp.assay_header_id,
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
                     vdip.price_unit_id valuation_price_unit_id,
                     to_char(pd_trade_date, 'Mon') shipment_month,
                     to_char(pd_trade_date, 'yyyy') shipment_year,
                     pd_trade_date shipment_date,
                     temp.is_tolling_contract,
                     temp.is_tolling_extn,
                     payment_due_date
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
                             pcm.product_group_type,
                             pcm.issue_date,
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
                             pcpq.assay_header_id,
                             grd.quality_id quality_id,
                             pci.m2m_inco_term,
                             pcm.is_tolling_contract,
                             pcm.is_tolling_extn,
                             pd_trade_date payment_due_date,
                             aml.attribute_id element_id,
                             aml.attribute_name element_name
                        from grd_goods_record_detail        grd,
                             gmr_goods_movement_record      gmr,
                             pci_physical_contract_item     pci,
                             pcm_physical_contract_main     pcm,
                             pcmte_pcm_tolling_ext          pcmte,
                             pcdi_pc_delivery_item          pcdi,
                             sld_storage_location_detail    shm,
                             pcpq_pc_product_quality        pcpq,
                             dipch_di_payablecontent_header dipch,
                             pcpch_pc_payble_content_header pcpch,
                             aml_attribute_master_list      aml
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and grd.internal_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pci.pcdi_id = pcdi.pcdi_id
                         and pcpq.pcpq_id = pci.pcpq_id
                         and pcdi.internal_contract_ref_no =
                             pcm.internal_contract_ref_no
                         and grd.shed_id = shm.storage_loc_id(+)
                         and pcdi.pcdi_id = dipch.pcdi_id
                         and dipch.pcpch_id = pcpch.pcpch_id
                         and pcpch.payable_type = 'Payable'
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcpq.dbd_id = pc_dbd_id
                         and dipch.dbd_id = pc_dbd_id
                         and pcpch.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                         and pcpq.is_active = 'Y'
                         and pcpch.is_active = 'Y'
                         and dipch.is_active = 'Y'
                         and nvl(grd.inventory_status, 'NA') <> 'Out'
                         and pcm.purchase_sales = 'P'
                         and pcm.contract_type = 'CONCENTRATES'
                         and pcm.internal_contract_ref_no =
                             pcmte.int_contract_ref_no
                         and pcm.is_tolling_contract = 'Y'
                         and pcm.is_tolling_extn = 'Y'
                         and pcm.is_pass_through='N'
                         and gmr.is_internal_movement = 'N'
                         and aml.attribute_id = pcpch.element_id
                         and aml.is_active = 'Y'
                         and pcm.contract_status = 'In Position'
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
                             pcm.product_group_type,
                             pcm.issue_date,
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
                               else
                                nvl(gmr.destination_city_id,
                                    gmr.discharge_city_id)
                             end end city_id,
                             dgrd.product_id,
                             pcpq.assay_header_id,
                             dgrd.quality_id,
                             pci.m2m_inco_term,
                             pcm.is_tolling_contract,
                             pcm.is_tolling_extn,
                             pd_trade_date payment_due_date,
                             aml.attribute_id element_id,
                             aml.attribute_name element_name
                        from gmr_goods_movement_record      gmr,
                             pci_physical_contract_item     pci,
                             pcm_physical_contract_main     pcm,
                             pcdi_pc_delivery_item          pcdi,
                             gsm_gmr_stauts_master          gsm,
                             agh_alloc_group_header         agh,
                             sld_storage_location_detail    shm,
                             dgrd_delivered_grd             dgrd,
                             pcpq_pc_product_quality        pcpq,
                             pcpch_pc_payble_content_header pcpch,
                             aml_attribute_master_list      aml,
                             pcmte_pcm_tolling_ext          pcmte
                       where gmr.internal_contract_ref_no =
                             pcm.internal_contract_ref_no(+)
                         and pcm.internal_contract_ref_no =
                             pcdi.internal_contract_ref_no
                         and pcdi.pcdi_id = pci.pcdi_id
                         and agh.int_sales_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pcpq.pcpq_id = pci.pcpq_id
                         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
                         and dgrd.shed_id = shm.storage_loc_id(+)
                         and pcm.purchase_sales = 'S'
                         and pcm.contract_type = 'CONCENTRATES'
                         and pcm.is_tolling_contract = 'Y'
                         and pcm.is_tolling_extn = 'Y'
                         and pcm.is_pass_through='N'
                         and pcm.contract_status = 'In Position'
                         and gsm.is_required_for_m2m = 'Y'
                         and gmr.dbd_id = pc_dbd_id
                         and pci.dbd_id = pc_dbd_id
                         and pcm.dbd_id = pc_dbd_id
                         and dgrd.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcpq.dbd_id = pc_dbd_id
                         and agh.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.status_id = gsm.status_id
                         and agh.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and pci.is_active = 'Y'
                         and pcm.is_active = 'Y'
                         and pcdi.is_active = 'Y'
                         and pcpq.is_active = 'Y'
                         and upper(agh.realized_status) in
                             ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED',
                              'REVERSEUNDERCMA')
                         and dgrd.status = 'Active'
                         and dgrd.net_weight > 0
                         and gmr.is_internal_movement = 'N'
                         and pcpch.internal_contract_ref_no =
                             pcm.internal_contract_ref_no
                         and pcpch.dbd_id = pc_dbd_id
                         and pcpch.element_id = aml.attribute_id
                         and pcm.internal_contract_ref_no =
                             pcmte.int_contract_ref_no
                      union all -- Internal movement Not sure why contract details are null ?? need to check
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
                             null product_group_type,
                             null issue_date,
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
                             null assay_header_id,
                             grd.quality_id quality_id,
                             null m2m_inco_term,
                             null is_tolling_contract,
                             null is_tolling_extn,
                             pd_trade_date payment_due_date,
                             aml.attribute_id element_id,
                             aml.attribute_name element_name
                      
                        from grd_goods_record_detail        grd,
                             gmr_goods_movement_record      gmr,
                             sld_storage_location_detail    shm,
                             pdm_productmaster              pdm,
                             pdtm_product_type_master       pdtm,
                             pci_physical_contract_item     pci,
                             pcdi_pc_delivery_item          pcdi,
                             pcpch_pc_payble_content_header pcpch,
                             aml_attribute_master_list      aml
                       where grd.internal_gmr_ref_no =
                             gmr.internal_gmr_ref_no
                         and gmr.is_internal_movement = 'Y'
                         and grd.dbd_id = pc_dbd_id
                         and gmr.dbd_id = pc_dbd_id
                         and gmr.corporate_id = pc_corporate_id
                         and gmr.shed_id = shm.storage_loc_id(+)
                         and grd.product_id = pdm.product_id
                         and pdm.product_type_id = pdtm.product_type_id
                         and pdtm.product_type_name = 'Composite'
                         and grd.status = 'Active'
                         and grd.is_deleted = 'N'
                         and gmr.is_deleted = 'N'
                         and nvl(grd.inventory_status, 'NA') <> 'Out'
                         and grd.internal_contract_item_ref_no =
                             pci.internal_contract_item_ref_no
                         and pci.pcdi_id = pcdi.pcdi_id
                         and pcdi.internal_contract_ref_no =
                             pcpch.internal_contract_ref_no
                         and pci.dbd_id = pc_dbd_id
                         and pcdi.dbd_id = pc_dbd_id
                         and pcpch.dbd_id = pc_dbd_id
                         and pcpch.element_id = aml.attribute_id) temp,
                     mv_conc_qat_quality_valuation mv_qat,
                     mvp_m2m_valuation_point mvp,
                     mvpl_m2m_valuation_point_loc mvpl,
                     v_der_instrument_price_unit vdip
               where temp.corporate_id = mv_qat.corporate_id
                 and temp.quality_id = mv_qat.conc_quality_id
                 and mv_qat.instrument_id = vdip.instrument_id(+)
                 and temp.corporate_id = mvp.corporate_id
                 and temp.product_id = mvp.product_id
                 and temp. issue_date <= pd_trade_date
                 and mvp.mvp_id = mvpl.mvp_id
                 and mvpl.loc_city_id = temp.city_id
                 and temp.element_id = mv_qat.attribute_id) m2m;
  
    for cur_ppu in (select tmpc.conc_product_id,
                           ppu.product_price_unit_id
                      from tmpc_temp_m2m_pre_check tmpc,
                           pdm_productmaster       pdm,
                           v_ppu_pum               ppu,
                           ak_corporate            akc
                     where tmpc.corporate_id = pc_corporate_id
                       and tmpc.product_type = 'CONCENTRATES'
                       and tmpc.is_tolling_contract = 'Y'
                       and tmpc.is_tolling_extn = 'Y'
                       and tmpc.conc_product_id = pdm.product_id
                       and ppu.product_id = pdm.product_id
                       and ppu.weight_unit_id = pdm.base_quantity_unit
                       and ppu.cur_id = akc.base_cur_id
                     group by tmpc.conc_product_id,
                              ppu.product_price_unit_id)
    loop
    
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.conc_base_price_unit_id_ppu = cur_ppu.product_price_unit_id
       where tmpc.corporate_id = pc_corporate_id
         and tmpc.product_type = 'CONCENTRATES'
         and tmpc.is_tolling_contract = 'Y'
         and tmpc.is_tolling_extn = 'Y'
         and tmpc.conc_product_id = cur_ppu.conc_product_id;
    
    end loop;
  
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
    ----------------------------- 
    vc_error_loc := 6;
    for cc2 in (select t.pcdi_id,
                       t.internal_contract_ref_no,
                       t.internal_contract_item_ref_no,
                       t.basis_type,
                       t.transit_days,
                       t.contract_ref_no,
                       t.expected_delivery_month,
                       t.expected_delivery_year,
                       t.element_id,
                       t.date_type,
                       t.ship_arrival_date,
                       t.ship_arrival_days,
                       t.expected_ship_arrival_date,
                       (case
                         when t.ship_arrival_date = 'Start Date' then
                          to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                   'Mon-yyyy'),'dd-Mon-yyyy')
                         when t.ship_arrival_date = 'End Date' then
                          last_day(t.expected_ship_arrival_date)
                         else
                          (to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                    'Mon-yyyy'),'dd-Mon-yyyy') +
                          trunc((last_day(t.expected_ship_arrival_date) -
                                 to_date('01-' ||
                                          to_char(t.expected_ship_arrival_date,
                                                  'Mon-yyyy'),'dd-Mon-yyyy')) / 2))
                       end) + t.ship_arrival_days basis_month_year
                  from (select pcdi.pcdi_id,
                               pcdi.internal_contract_ref_no,
                               pci.internal_contract_item_ref_no,
                               pcdi.basis_type,
                               nvl(pcdi.transit_days, 0) transit_days,
                               pcm.contract_ref_no,
                               pci.expected_delivery_month,
                               pci.expected_delivery_year,
                               pqca.element_id,
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
                          from pcdi_pc_delivery_item         pcdi,
                               pci_physical_contract_item    pci,
                               pcm_physical_contract_main    pcm,
                               pcpd_pc_product_definition    pcpd,
                               pcpq_pc_product_quality       pcpq,
                               ash_assay_header              ash,
                               asm_assay_sublot_mapping      asm,
                               pqca_pq_chemical_attributes   pqca,
                               mv_conc_qat_quality_valuation qat,
                               pdm_productmaster             pdm
                        --qat_quality_attributes     qat
                         where pcdi.pcdi_id = pci.pcdi_id
                           and pcdi.internal_contract_ref_no =
                               pcm.internal_contract_ref_no
                           and pcm.internal_contract_ref_no =
                               pcpd.internal_contract_ref_no
                           and pcpd.product_id = qat.conc_product_id
                           and pcm.contract_status = 'In Position'
                           and pcm.contract_type = 'CONCENTRATES'
                           and pcpd.input_output = 'Input'
                           and pcm.corporate_id = pc_corporate_id
                           and pci.item_qty > 0
                           and pci.pcpq_id = pcpq.pcpq_id
                              --and pcpq.quality_template_id = qat.quality_id
                           and pcpq.assay_header_id = ash.ash_id
                           and ash.ash_id = asm.ash_id
                           and asm.asm_id = pqca.asm_id
                           and pcpq.quality_template_id = qat.conc_quality_id
                           and pqca.element_id = qat.attribute_id
                           and qat.conc_product_id = pdm.product_id
                           and nvl(pdm.valuation_against_underlying, 'Y') = 'Y'
                           and qat.corporate_id = pc_corporate_id
                           and pci.dbd_id = pc_dbd_id
                           and pcdi.dbd_id = pc_dbd_id
                           and pcm.dbd_id = pc_dbd_id
                           and pcpq.dbd_id = pc_dbd_id
                           and pcpd.dbd_id = pc_dbd_id
                           and pcdi.is_active = 'Y'
                           and pci.is_active = 'Y'
                           and pcm.is_active = 'Y'
                           and pcpd.is_active = 'Y'
                           and pcpq.is_active = 'Y') t,
                       tmpc_temp_m2m_pre_check tmpc
                 where tmpc.section_name = 'OPEN'
                   and tmpc.corporate_id = pc_corporate_id
                   and tmpc.product_type = 'CONCENTRATES'
                   and tmpc.is_tolling_contract = 'Y'
                   and tmpc.is_tolling_extn = 'Y'
                   and tmpc.internal_contract_item_ref_no =
                       t.internal_contract_item_ref_no
                   and tmpc.element_id = t.element_id
                   and tmpc.pcdi_id = t.pcdi_id)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.shipment_month = to_char(cc2.basis_month_year, 'Mon'),
             tmpc.shipment_year  = to_char(cc2.basis_month_year, 'YYYY'),
             tmpc.shipment_date  = cc2.basis_month_year
       where tmpc.pcdi_id = cc2.pcdi_id
         and tmpc.internal_contract_item_ref_no =
             cc2.internal_contract_item_ref_no
         and tmpc.element_id = cc2.element_id
         and tmpc.section_name = 'OPEN'
         and tmpc.product_type = 'CONCENTRATES'
         and tmpc.is_tolling_contract = 'Y'
         and tmpc.is_tolling_extn = 'Y'
         and tmpc.corporate_id = pc_corporate_id;
    end loop;
    -------------------- 
    commit;
    for cc2 in (select t.pcdi_id,
                       t.internal_contract_ref_no,
                       t.internal_contract_item_ref_no,
                       t.basis_type,
                       t.transit_days,
                       t.contract_ref_no,
                       t.expected_delivery_month,
                       t.expected_delivery_year,
                       t.element_id,
                       t.date_type,
                       t.ship_arrival_date,
                       t.ship_arrival_days,
                       t.expected_ship_arrival_date,
                       (case
                         when t.ship_arrival_date = 'Start Date' then
                          to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                   'Mon-yyyy'),'dd-Mon-yyyy')
                         when t.ship_arrival_date = 'End Date' then
                          last_day(t.expected_ship_arrival_date)
                         else
                          (to_date('01-' || to_char(t.expected_ship_arrival_date,
                                                    'Mon-yyyy'),'dd-Mon-yyyy') +
                          trunc((last_day(t.expected_ship_arrival_date) -
                                 to_date('01-' ||
                                          to_char(t.expected_ship_arrival_date,
                                                  'Mon-yyyy'),'dd-Mon-yyyy')) / 2))
                       end) + t.ship_arrival_days basis_month_year
                  from (select pcdi.pcdi_id,
                               pcdi.internal_contract_ref_no,
                               pci.internal_contract_item_ref_no,
                               pcdi.basis_type,
                               nvl(pcdi.transit_days, 0) transit_days,
                               pcm.contract_ref_no,
                               pci.expected_delivery_month,
                               pci.expected_delivery_year,
                               pqca.element_id,
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
                          from pcdi_pc_delivery_item        pcdi,
                               pci_physical_contract_item   pci,
                               pcm_physical_contract_main   pcm,
                               pcpd_pc_product_definition   pcpd,
                               pcpq_pc_product_quality      pcpq,
                               ash_assay_header             ash,
                               asm_assay_sublot_mapping     asm,
                               pqca_pq_chemical_attributes  pqca,
                               v_conc_qat_quality_valuation qat,
                               pdm_productmaster            pdm
                        --qat_quality_attributes     qat
                         where pcdi.pcdi_id = pci.pcdi_id
                           and pcdi.internal_contract_ref_no =
                               pcm.internal_contract_ref_no
                           and pcm.internal_contract_ref_no =
                               pcpd.internal_contract_ref_no
                           and pcpd.product_id = qat.conc_product_id
                           and pcm.contract_status = 'In Position'
                           and pcm.contract_type = 'CONCENTRATES'
                           and pcpd.input_output = 'Input'
                           and pcm.corporate_id = pc_corporate_id
                           and pci.item_qty > 0
                           and pci.pcpq_id = pcpq.pcpq_id
                              --and pcpq.quality_template_id = qat.quality_id
                           and pcpq.assay_header_id = ash.ash_id
                           and ash.ash_id = asm.ash_id
                           and asm.asm_id = pqca.asm_id
                           and pcpq.quality_template_id = qat.conc_quality_id
                           and pqca.element_id = qat.attribute_id
                           and qat.conc_product_id = pdm.product_id
                           and nvl(pdm.valuation_against_underlying, 'Y') = 'N'
                           and qat.corporate_id = pc_corporate_id
                           and pci.dbd_id = pc_dbd_id
                           and pcdi.dbd_id = pc_dbd_id
                           and pcm.dbd_id = pc_dbd_id
                           and pcpq.dbd_id = pc_dbd_id
                           and pcpd.dbd_id = pc_dbd_id
                           and pcdi.is_active = 'Y'
                           and pci.is_active = 'Y'
                           and pcm.is_active = 'Y'
                           and pcpq.is_active = 'Y'
                           and pcpd.is_active = 'Y') t,
                       tmpc_temp_m2m_pre_check tmpc
                 where tmpc.section_name = 'OPEN'
                   and tmpc.corporate_id = pc_corporate_id
                   and tmpc.product_type = 'CONCENTRATES'
                   and tmpc.is_tolling_contract = 'Y'
                   and tmpc.is_tolling_extn = 'Y'
                   and tmpc.internal_contract_item_ref_no =
                       t.internal_contract_item_ref_no
                   and tmpc.element_id = t.element_id
                   and tmpc.pcdi_id = t.pcdi_id)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.shipment_month = to_char(cc2.basis_month_year, 'Mon'),
             tmpc.shipment_year  = to_char(cc2.basis_month_year, 'YYYY'),
             tmpc.shipment_date  = cc2.basis_month_year
       where tmpc.pcdi_id = cc2.pcdi_id
         and tmpc.internal_contract_item_ref_no =
             cc2.internal_contract_item_ref_no
         and tmpc.element_id = cc2.element_id
         and tmpc.section_name = 'OPEN'
         and tmpc.product_type = 'CONCENTRATES'
         and tmpc.is_tolling_contract = 'Y'
         and tmpc.is_tolling_extn = 'Y'
         and tmpc.corporate_id = pc_corporate_id;
    end loop;
    -------
    commit;
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
                  and tmpc.is_tolling_contract = 'Y'
                  and tmpc.is_tolling_extn = 'Y'
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
           and tmpc.is_tolling_contract = 'Y'
           and tmpc.is_tolling_extn = 'Y'
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
    begin
      for cc in (select tmpc.conc_product_id,
                        tmpc.conc_quality_id,
                        tmpc.element_id,
                        qat.instrument_id,
                        qat.product_derivative_id,
                        qat.eval_basis,
                        qat.exch_valuation_month,
                        vdip.price_unit_id
                   from tmpc_temp_m2m_pre_check      tmpc,
                        v_conc_qat_quality_valuation qat,
                        v_der_instrument_price_unit  vdip
                  where tmpc.conc_product_id = qat.conc_product_id
                    and tmpc.conc_quality_id = qat.conc_quality_id
                    and tmpc.corporate_id = qat.corporate_id
                    and qat.instrument_id = vdip.instrument_id(+)
                    and tmpc.element_id = qat.attribute_id
                    and tmpc.corporate_id = pc_corporate_id
                    and tmpc.product_type = 'CONCENTRATES'
                    and tmpc.is_tolling_contract = 'Y'
                    and tmpc.is_tolling_extn = 'Y')
      loop
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.instrument_id     = cc.instrument_id,
               tmpc.value_type        = cc.eval_basis,
               tmpc.derivative_def_id = cc.product_derivative_id,
               tmpc.m2m_price_unit_id = cc.price_unit_id
         where tmpc.product_type = 'CONCENTRATES'
           and tmpc.is_tolling_contract = 'Y'
           and tmpc.is_tolling_extn = 'Y'
           and tmpc.conc_product_id = cc.conc_product_id
           and tmpc.conc_quality_id = cc.conc_quality_id
           and tmpc.element_id = cc.element_id
           and tmpc.corporate_id = pc_corporate_id;
      end loop;
      commit;
    
    end;
    -----------------------
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
                      mv_conc_qat_quality_valuation qat,
                      pdm_productmaster             pdm
                where tmpc.quality_id = qat.quality_id
                  and tmpc.corporate_id = qat.corporate_id
                  and tmpc.conc_product_id = pdm.product_id
                  and nvl(pdm.valuation_against_underlying, 'Y') = 'Y'
                  and tmpc.corporate_id = pc_corporate_id
                  and tmpc.value_type <> 'FIXED'
                  and tmpc.product_type = 'CONCENTRATES'
                  and tmpc.is_tolling_contract = 'Y'
                  and tmpc.is_tolling_extn = 'Y'
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
           and tmpc.is_tolling_contract = 'Y'
           and tmpc.is_tolling_extn = 'Y'
           and tmpc.corporate_id = cc.corporate_id;
      end if;
    end loop;
    commit;
    --------
  
    for cc in (select tmpc.corporate_id,
                      tmpc.shipment_month,
                      tmpc.shipment_year,
                      tmpc.instrument_id,
                      decode(tmpc.section_name, 'OPEN', 'OPEN', 'STOCK') trade_type,
                      tmpc.quality_id,
                      qat.eval_basis,
                      qat.exch_valuation_month
                 from tmpc_temp_m2m_pre_check      tmpc,
                      v_conc_qat_quality_valuation qat,
                      pdm_productmaster            pdm
                where tmpc.conc_quality_id = qat.quality_id
                  and tmpc.conc_product_id = pdm.product_id
                  and nvl(pdm.valuation_against_underlying, 'Y') = 'N'
                  and tmpc.corporate_id = qat.corporate_id
                  and tmpc.corporate_id = pc_corporate_id
                  and tmpc.value_type <> 'FIXED'
                  and tmpc.product_type = 'CONCENTRATES'
                  and tmpc.is_tolling_contract = 'Y'
                  and tmpc.is_tolling_extn = 'Y'
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
           and tmpc.is_tolling_contract = 'Y'
           and tmpc.is_tolling_extn = 'Y'
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
                   and tmpc.is_tolling_contract = 'Y'
                   and tmpc.is_tolling_extn = 'Y'
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
         and tmpc.is_tolling_contract = 'Y'
         and tmpc.is_tolling_extn = 'Y'
         and tmpc.corporate_id = ccv.corporate_id;
    end loop;
    commit;
    --Updating tmpc table and setting the 
    --base_price_unit_id_in_ppu.
    vc_error_loc := 9;
  
    for cc in (select tmpc.corporate_id,
                      tmpc.conc_product_id,
                      tmpc.product_id,
                      akc.base_cur_id,
                      pdm.base_quantity_unit,
                      ppu.internal_price_unit_id,
                      pum.price_unit_id,
                      tmpc.element_id
                 from tmpc_temp_m2m_pre_check tmpc,
                      ak_corporate            akc,
                      pdm_productmaster       pdm,
                      pdm_productmaster       pdm_conc,
                      ppu_product_price_units ppu,
                      pum_price_unit_master   pum
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.corporate_id = akc.corporate_id
                  and tmpc.product_id = pdm.product_id
                  and tmpc.product_type = 'CONCENTRATES'
                  and tmpc.is_tolling_contract = 'Y'
                  and tmpc.is_tolling_extn = 'Y'
                  and tmpc.conc_product_id = pdm_conc.product_id
                  and nvl(pdm_conc.valuation_against_underlying, 'Y') = 'Y'
                  and ppu.product_id = pdm.product_id
                  and ppu.is_active = 'Y'
                  and ppu.is_deleted = 'N'
                  and ppu.price_unit_id = pum.price_unit_id
                  and pum.cur_id = akc.base_cur_id
                  and nvl(pum.weight, 1) = 1
                  and pum.weight_unit_id = pdm.base_quantity_unit
                group by tmpc.corporate_id,
                         tmpc.conc_product_id,
                         tmpc.product_id,
                         akc.base_cur_id,
                         pdm.base_quantity_unit,
                         ppu.internal_price_unit_id,
                         pum.price_unit_id,
                         tmpc.element_id
               union all
               select tmpc.corporate_id,
                      tmpc.conc_product_id,
                      tmpc.product_id,
                      akc.base_cur_id,
                      pdm_conc.base_quantity_unit,
                      ppu.internal_price_unit_id,
                      pum.price_unit_id,
                      tmpc.element_id
                 from tmpc_temp_m2m_pre_check tmpc,
                      ak_corporate            akc,
                      pdm_productmaster       pdm,
                      pdm_productmaster       pdm_conc,
                      ppu_product_price_units ppu,
                      pum_price_unit_master   pum
                where tmpc.corporate_id = pc_corporate_id
                  and tmpc.corporate_id = akc.corporate_id
                  and tmpc.product_id = pdm.product_id
                  and tmpc.product_type = 'CONCENTRATES'
                  and tmpc.is_tolling_contract = 'Y'
                  and tmpc.is_tolling_extn = 'Y'
                  and tmpc.conc_product_id = pdm_conc.product_id
                  and ppu.product_id = pdm_conc.product_id
                  and nvl(pdm_conc.valuation_against_underlying, 'Y') = 'N'
                  and ppu.is_active = 'Y'
                  and ppu.is_deleted = 'N'
                  and ppu.price_unit_id = pum.price_unit_id
                  and pum.cur_id = akc.base_cur_id
                  and nvl(pum.weight, 1) = 1
                  and pum.weight_unit_id = pdm_conc.base_quantity_unit
                group by tmpc.corporate_id,
                         tmpc.product_id,
                         tmpc.conc_product_id,
                         akc.base_cur_id,
                         pdm_conc.base_quantity_unit,
                         ppu.internal_price_unit_id,
                         pum.price_unit_id,
                         tmpc.element_id)
    loop
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.base_price_unit_id_in_ppu = cc.internal_price_unit_id,
             tmpc.base_price_unit_id_in_pum = cc.price_unit_id
       where tmpc.product_type = 'CONCENTRATES'
         and tmpc.is_tolling_contract = 'Y'
         and tmpc.is_tolling_extn = 'Y'
         and tmpc.corporate_id = cc.corporate_id
         and tmpc.element_id = cc.element_id
         and tmpc.conc_product_id = cc.conc_product_id
         and tmpc.product_id = cc.product_id;
      commit;
    
    end loop;
    commit;
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
      select t.corporate_id,
             'Physicals M2M Pre-Check',
             'M2M-030',
             t.product_name || '(' || t.price_unit_name || ')',
             null,
             pc_process,
             systimestamp,
             pc_user_id,
             pd_trade_date
        from (select tmpc.corporate_id,
                     tmpc.product_id,
                     pdm.product_desc product_name,
                     akc.base_cur_id,
                     pdm.base_quantity_unit,
                     pum.price_unit_id,
                     pum.price_unit_name
                from tmpc_temp_m2m_pre_check tmpc,
                     ak_corporate            akc,
                     pdm_productmaster       pdm,
                     pdm_productmaster       pdm_conc,
                     pum_price_unit_master   pum
               where tmpc.corporate_id = pc_corporate_id
                 and tmpc.corporate_id = akc.corporate_id
                 and tmpc.product_id = pdm.product_id
                 and tmpc.product_type = 'CONCENTRATES'
                 and tmpc.is_tolling_contract = 'Y'
                 and tmpc.is_tolling_extn = 'Y'
                 and tmpc.conc_product_id = pdm_conc.product_id
                 and nvl(pdm_conc.valuation_against_underlying, 'Y') = 'Y'
                 and pum.cur_id = akc.base_cur_id
                 and nvl(pum.weight, 1) = 1
                 and pum.weight_unit_id = pdm.base_quantity_unit
               group by tmpc.corporate_id,
                        tmpc.product_id,
                        akc.base_cur_id,
                        pdm.base_quantity_unit,
                        pum.price_unit_name,
                        pdm.product_desc,
                        pum.price_unit_id
              union all
              select tmpc.corporate_id,
                     tmpc.conc_product_id product_id,
                     pdm_conc.product_desc product_name,
                     akc.base_cur_id,
                     pdm_conc.base_quantity_unit,
                     pum.price_unit_id,
                     pum.price_unit_name
                from tmpc_temp_m2m_pre_check tmpc,
                     ak_corporate            akc,
                     pdm_productmaster       pdm,
                     pdm_productmaster       pdm_conc,
                     pum_price_unit_master   pum
               where tmpc.corporate_id = pc_corporate_id
                 and tmpc.corporate_id = akc.corporate_id
                 and tmpc.product_id = pdm.product_id
                 and tmpc.product_type = 'CONCENTRATES'
                 and tmpc.is_tolling_contract = 'Y'
                 and tmpc.is_tolling_extn = 'Y'
                 and tmpc.conc_product_id = pdm_conc.product_id
                 and nvl(pdm_conc.valuation_against_underlying, 'Y') = 'N'
                 and pum.cur_id = akc.base_cur_id
                 and nvl(pum.weight, 1) = 1
                 and pum.weight_unit_id = pdm_conc.base_quantity_unit
               group by tmpc.corporate_id,
                        pum.price_unit_name,
                        tmpc.conc_product_id,
                        akc.base_cur_id,
                        pdm_conc.product_desc,
                        pdm_conc.base_quantity_unit,
                        pum.price_unit_id) t
       where not exists (select 1
                from ppu_product_price_units ppu
               where ppu.product_id = t.product_id
                 and ppu.price_unit_id = t.price_unit_id
                 and ppu.is_active = 'Y'
                 and ppu.is_deleted = 'N');
  
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
             ' Price,Prompt Date:' || drm.dr_id_name || ' Trade Date(' ||
             to_char(cdim.valid_quote_date, 'dd-Mon-yyyy') || ')',
             f_string_aggregate(tmpc.contract_ref_no),
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
             pum_price_unit_master        pum,
             cdim_corporate_dim           cdim
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
         and tmpc.is_tolling_contract = 'Y'
         and tmpc.is_tolling_extn = 'Y'
         and div.is_deleted = 'N'
         and cdim.corporate_id = pc_corporate_id
         and cdim.instrument_id = dim.instrument_id
         and not exists
       (select 1
                from eodeom_derivative_quote_detail dqd,
                     cdim_corporate_dim             cdim
               where tmpc.valuation_dr_id = dqd.dr_id
                 and tmpc.product_type = 'CONCENTRATES'
                 and tmpc.is_tolling_contract = 'Y'
                 and tmpc.is_tolling_extn = 'Y'
                 and div.available_price_id = dqd.available_price_id
                 and div.price_source_id = dqd.price_source_id
                 and div.price_unit_id = dqd.price_unit_id
                 and dqd.dq_trade_date = cdim.valid_quote_date
                 and dqd.corporate_id = pc_corporate_id
                 and dqd.dbd_id = gvc_dbd_id
                 and dqd.price is not null
                 and cdim.corporate_id = pc_corporate_id
                 and cdim.instrument_id = dqd.instrument_id)
       group by tmpc.corporate_id,
                'Settlement Price missing for ' || dim.instrument_name ||
                ',Price Source:' || ps.price_source_name || ',Price Unit:' ||
                pum.price_unit_name || ',' || apm.available_price_name ||
                ' Price,Prompt Date:' || drm.dr_id_name || ' Trade Date(' ||
                to_char(cdim.valid_quote_date, 'dd-Mon-yyyy') || ')';
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
         and tmpc.is_tolling_contract = 'Y'
         and tmpc.is_tolling_extn = 'Y'
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
                             tmpc.conc_base_price_unit_id_ppu,
                             tmpc.shipment_month,
                             tmpc.shipment_year,
                             tmpc.mvp_id valuation_point_id,
                             tmpc.valuation_point,
                             tmpc.payment_due_date
                        from tmpc_temp_m2m_pre_check tmpc,
                             pdm_productmaster       pdm,
                             qat_quality_attributes  qat
                       where tmpc.product_type = 'CONCENTRATES'
                         and tmpc.is_tolling_contract = 'Y'
                         and tmpc.is_tolling_extn = 'Y'
                         and tmpc.corporate_id = pc_corporate_id
                         and tmpc.conc_product_id = pdm.product_id
                         and tmpc.conc_quality_id = qat.quality_id
                       group by tmpc.corporate_id,
                                tmpc.conc_product_id,
                                pdm.product_desc,
                                tmpc.conc_quality_id,
                                tmpc.conc_base_price_unit_id_ppu,
                                tmpc.element_id,
                                tmpc.valuation_point,
                                tmpc.mvp_id,
                                qat.quality_name,
                                tmpc.element_name,
                                tmpc.shipment_month,
                                tmpc.shipment_year,
                                tmpc.payment_due_date)
      loop
        --for treatment charge precheck
      
        pkg_phy_pre_check_process.sp_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                         pd_trade_date,
                                                         cc_tmpc.conc_product_id,
                                                         cc_tmpc.conc_quality_id,
                                                         cc_tmpc.valuation_point_id,
                                                         'Treatment Charges',
                                                         cc_tmpc.element_id,
                                                         cc_tmpc.shipment_month,
                                                         cc_tmpc.shipment_year,
                                                         cc_tmpc.conc_base_price_unit_id_ppu,
                                                         cc_tmpc.payment_due_date,
                                                         pn_charge_amt,
                                                         vc_exch_rate_string);
      
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
        else
        
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.m2m_treatment_charge = pn_charge_amt,
                 tmpc.m2m_tc_fw_exch_rate  = vc_exch_rate_string
           where tmpc.corporate_id = pc_corporate_id
             and tmpc.conc_product_id = cc_tmpc.conc_product_id
             and tmpc.conc_quality_id = cc_tmpc.conc_quality_id
             and tmpc.mvp_id = cc_tmpc.valuation_point_id
             and tmpc.element_id = cc_tmpc.element_id
             and tmpc.shipment_month = cc_tmpc.shipment_month
             and tmpc.shipment_year = cc_tmpc.shipment_year
             and tmpc.payment_due_date = cc_tmpc.payment_due_date;
        
        end if;
        --for refine charge precheck
        pkg_phy_pre_check_process.sp_m2m_tc_pc_rc_charge(cc_tmpc.corporate_id,
                                                         pd_trade_date,
                                                         cc_tmpc.conc_product_id,
                                                         cc_tmpc.conc_quality_id,
                                                         cc_tmpc.valuation_point_id, --valuation_id
                                                         'Refining Charges', --charge_type
                                                         cc_tmpc.element_id,
                                                         cc_tmpc.shipment_month,
                                                         cc_tmpc.shipment_year,
                                                         cc_tmpc.conc_base_price_unit_id_ppu,
                                                         cc_tmpc.payment_due_date,
                                                         pn_charge_amt,
                                                         vc_exch_rate_string);
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
        else
        
          update tmpc_temp_m2m_pre_check tmpc
             set tmpc.m2m_refining_charge = pn_charge_amt,
                 tmpc.m2m_rc_fw_exch_rate = vc_exch_rate_string
           where tmpc.corporate_id = pc_corporate_id
             and tmpc.conc_product_id = cc_tmpc.conc_product_id
             and tmpc.conc_quality_id = cc_tmpc.conc_quality_id
             and tmpc.mvp_id = cc_tmpc.valuation_point_id
             and tmpc.element_id = cc_tmpc.element_id
             and tmpc.shipment_month = cc_tmpc.shipment_month
             and tmpc.shipment_year = cc_tmpc.shipment_year
             and tmpc.payment_due_date = cc_tmpc.payment_due_date;
        end if;
      end loop;
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
                                                           'procedure sp_pre_check_m2m_tolling_extn',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           vc_error_loc,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;

  procedure sp_m2m_quality_premimum(pc_corporate_id          varchar2,
                                    pd_trade_date            date,
                                    pc_valuation_point_id    varchar2,
                                    pc_quality_id            varchar2,
                                    pc_product_id            varchar2,
                                    pc_premium_price_unit_id varchar2,
                                    pc_calendar_month        varchar2,
                                    pc_calendar_year         varchar2,
                                    pc_user_id               varchar2,
                                    pd_payment_due_date      date,
                                    pc_process               varchar2,
                                    pd_valuation_fx_date     date,
                                    pn_qp_amt                out number,
                                    pn_qp_amt_cp_fx_rate     out number,
                                    pc_exch_rate_string      out varchar2,
                                    pc_exch_rate_missing     out varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    cursor cur_data is
      select *
        from (select qp.corporate_id,
                     qp.product_id,
                     qpbm.premium,
                     qpbm.premium_price_unit_id,
                     qp.as_on_date,
                     rank() over(order by qp.as_on_date desc nulls last) as latest_record -- as we have to use rank function, if same day,             --different curve found, some those premium values into m2m price unit
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
    cursor cur_data_beyond is
      select *
        from (select qp.corporate_id,
                     qp.product_id,
                     qpbm.premium,
                     qpbm.premium_price_unit_id,
                     qp.as_on_date,
                     rank() over(order by qp.as_on_date desc nulls last) as latest_record -- as we have to use rank function, if same day,                --different curve found, some those premium values into m2m price unit
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
                 and qpbm.beyond_month is not null
                 and qpbm.beyond_year is not null
                 and qp.as_on_date <= pd_trade_date) t
       where t.latest_record = 1;
    vc_premium_cur_id             varchar2(15);
    vc_premium_weight_unit_id     varchar2(15);
    vn_premium_weight             number;
    vc_premium_main_cur_id        varchar2(15);
    vc_premium_main_cur_code      varchar2(15);
    vc_premium_main_cur_factor    number;
    vn_premium                    number := 0;
    vc_base_cur_id                varchar2(15);
    vc_base_cur_code              varchar2(15);
    vc_base_weight_unit_id        varchar2(15);
    vn_fw_exch_rate_prem_to_base  number;
    vn_forward_points             number;
    vn_total_premium              number := 0;
    vc_exch_rate_string           varchar2(500);
    vc_total_exch_rate_string     varchar2(500);
   -- vc_data_missing_for           varchar2(500);
    vn_exchnage_rate              number;
    vn_premium_corp_fx_rate       number;
    vn_total_premium_corp_fx_rate number := 0;
  begin
    --
    -- Premium based on the not beyond  values
    --
    pc_exch_rate_missing := 'N';
    for cur_data_rows in cur_data
    loop
      if cur_data_rows.premium_price_unit_id <> pc_premium_price_unit_id then
        --
        -- Get the Currency of the Premium Price Unit
        --
        select ppu.cur_id,
               ppu.weight_unit_id,
               nvl(ppu.weight, 1)
          into vc_premium_cur_id,
               vc_premium_weight_unit_id,
               vn_premium_weight
          from v_ppu_pum ppu
         where ppu.product_price_unit_id =
               cur_data_rows.premium_price_unit_id;
        --
        -- Get the Main Currency of the Premium Price Unit
        --   
        pkg_general.sp_get_base_cur_detail(vc_premium_cur_id,
                                           vc_premium_main_cur_id,
                                           vc_premium_main_cur_code,
                                           vc_premium_main_cur_factor);
        --
        -- Get the Details of the Base Currency
        --  
        select ppu.cur_id,
               ppu.weight_unit_id,
               cm.cur_code
          into vc_base_cur_id,
               vc_base_weight_unit_id,
               vc_base_cur_code
          from v_ppu_pum          ppu,
               cm_currency_master cm
         where ppu.product_price_unit_id = pc_premium_price_unit_id
           and ppu.cur_id = cm.cur_id;
        --
        -- Get the Exchange Rate from Premium Price Currency to Base Currency
        -- 
      
        if pd_valuation_fx_date = pd_trade_date then
          pkg_general.sp_bank_fx_rate_spot(pc_corporate_id,
                                           pd_trade_date,
                                           vc_premium_main_cur_id,
                                           vc_base_cur_id,
                                           'sp_m2m_quality_premium QP to Base',
                                           pc_process,
                                           vn_fw_exch_rate_prem_to_base);
        else
          pkg_general.sp_bank_fx_rate_spot_fw_points(pc_corporate_id,
                                                     pd_trade_date,
                                                     pd_valuation_fx_date,
                                                     vc_premium_main_cur_id,
                                                     vc_base_cur_id,
                                                     'sp_m2m_quality_premium QP to Base',
                                                     pc_process,
                                                     vn_fw_exch_rate_prem_to_base,
                                                     vn_forward_points);
        end if;
      
        if vn_fw_exch_rate_prem_to_base = 0 then
          pc_exch_rate_missing := 'Y';
        
        end if;
        if vc_base_cur_id <> vc_premium_main_cur_id then
          vc_exch_rate_string := vc_exch_rate_string || '1 ' ||
                                 vc_premium_main_cur_code || '=' ||
                                 vn_fw_exch_rate_prem_to_base || ' ' ||
                                 vc_base_cur_code;
          if vc_total_exch_rate_string is null then
            vc_total_exch_rate_string := vc_exch_rate_string;
          else
            if instr(vc_total_exch_rate_string, vc_exch_rate_string) = 0 then
              vc_total_exch_rate_string := vc_total_exch_rate_string || ',' ||
                                           vc_exch_rate_string;
            
            end if;
          end if;
        end if;
        -- corp Fx rate( Premium to base for Risk position by Prompt report)  
        if vc_premium_main_cur_id <> vc_base_cur_id then
          vn_exchnage_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                       vc_premium_main_cur_id,
                                                                       vc_base_cur_id,
                                                                       pd_trade_date,
                                                                       1);
        else
          vn_exchnage_rate := 1;
        end if;
      
        vn_premium := (cur_data_rows.premium / vn_premium_weight) *
                      vc_premium_main_cur_factor *
                      vn_fw_exch_rate_prem_to_base *
                      pkg_general.f_get_converted_quantity(pc_product_id,
                                                           vc_base_weight_unit_id,
                                                           
                                                           vc_premium_weight_unit_id,
                                                           1);
      
        vn_premium_corp_fx_rate := (cur_data_rows.premium /
                                   vn_premium_weight) *
                                   vc_premium_main_cur_factor *
                                   vn_exchnage_rate *
                                   pkg_general.f_get_converted_quantity(pc_product_id,
                                                                        vc_base_weight_unit_id,
                                                                        
                                                                        vc_premium_weight_unit_id,
                                                                        1);
      else
        vn_premium              := cur_data_rows.premium;
        vn_premium_corp_fx_rate := cur_data_rows.premium;
      
      end if;
    
      vn_total_premium              := vn_total_premium + vn_premium;
      vn_total_premium_corp_fx_rate := vn_total_premium_corp_fx_rate +
                                       vn_premium_corp_fx_rate;
    end loop;
    if vn_total_premium is null or vn_total_premium = 0 then
      --
      -- Premium based on the not beyond  values
      --  
      for cur_data_rows in cur_data_beyond
      loop
        if cur_data_rows.premium_price_unit_id <> pc_premium_price_unit_id then
        
          --
          -- Get the Currency of the Premium Price Unit
          --
          select ppu.cur_id,
                 ppu.weight_unit_id,
                 nvl(ppu.weight, 1)
            into vc_premium_cur_id,
                 vc_premium_weight_unit_id,
                 vn_premium_weight
            from v_ppu_pum ppu
           where ppu.product_price_unit_id =
                 cur_data_rows.premium_price_unit_id;
          --
          -- Get the Main Currency of the Premium Price Unit
          --   
          pkg_general.sp_get_base_cur_detail(vc_premium_cur_id,
                                             vc_premium_main_cur_id,
                                             vc_premium_main_cur_code,
                                             vc_premium_main_cur_factor);
          --
          -- Get the Details of the Base Currency
          --  
          select ppu.cur_id,
                 ppu.weight_unit_id
            into vc_base_cur_id,
                 vc_base_weight_unit_id
            from v_ppu_pum ppu
           where ppu.product_price_unit_id = pc_premium_price_unit_id;
          --
          -- Get the Exchange Rate from Premium Price Currency to Base Currency
          -- 
        
          if pd_valuation_fx_date = pd_trade_date then
            pkg_general.sp_bank_fx_rate_spot(pc_corporate_id,
                                             pd_trade_date,
                                             vc_premium_main_cur_id,
                                             vc_base_cur_id,
                                             'sp_m2m_quality_premium QP to Base Spot Beyond',
                                             pc_process,
                                             vn_fw_exch_rate_prem_to_base);
          else
            pkg_general.sp_bank_fx_rate_spot_fw_points(pc_corporate_id,
                                                       pd_trade_date,
                                                       pd_valuation_fx_date,
                                                       vc_premium_main_cur_id,
                                                       vc_base_cur_id,
                                                       'sp_m2m_quality_premium QP to Base No Spot Beyond',
                                                       pc_process,
                                                       vn_fw_exch_rate_prem_to_base,
                                                       vn_forward_points);
          end if;
        
          --
          -- Convert Premium to Base
          --  
          -- corp Fx rate( Premium to base for Risk position by Prompt report)          
          if vc_premium_main_cur_id <> vc_base_cur_id then
            vn_exchnage_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                         vc_premium_main_cur_id,
                                                                         vc_base_cur_id,
                                                                         pd_trade_date,
                                                                         1);
          else
            vn_exchnage_rate := 1;
          end if;
        
          vn_premium              := (cur_data_rows.premium /
                                     vn_premium_weight) *
                                     vc_premium_main_cur_factor *
                                     vn_fw_exch_rate_prem_to_base *
                                     pkg_general.f_get_converted_quantity(pc_product_id,
                                                                          vc_premium_weight_unit_id,
                                                                          vc_base_weight_unit_id,
                                                                          1);
          vn_premium_corp_fx_rate := (cur_data_rows.premium /
                                     vn_premium_weight) *
                                     vc_premium_main_cur_factor *
                                     vn_exchnage_rate *
                                     pkg_general.f_get_converted_quantity(pc_product_id,
                                                                          vc_premium_weight_unit_id,
                                                                          vc_base_weight_unit_id,
                                                                          1);
        
          if vc_base_cur_id <> vc_premium_main_cur_id then
            vc_exch_rate_string := vc_exch_rate_string || '1 ' ||
                                   vc_premium_main_cur_id || '=' ||
                                   vn_fw_exch_rate_prem_to_base || ' ' ||
                                   vc_base_cur_id;
            if instr(vc_total_exch_rate_string, vc_exch_rate_string) = 0 then
              vc_total_exch_rate_string := vc_total_exch_rate_string || ',' ||
                                           vc_exch_rate_string;
            
            end if;
          
          end if;
        
        else
          vn_premium              := cur_data_rows.premium;
          vn_premium_corp_fx_rate := cur_data_rows.premium;
        
        end if;
        vn_total_premium              := vn_total_premium + vn_premium;
        vn_total_premium_corp_fx_rate := vn_total_premium_corp_fx_rate +
                                         vn_premium_corp_fx_rate;
      end loop;
    
    end if;
    if vn_total_premium is null then
      vn_total_premium              := 0;
      vn_total_premium_corp_fx_rate := 0;
    end if;
    pn_qp_amt            := vn_total_premium;
    pn_qp_amt_cp_fx_rate := vn_total_premium_corp_fx_rate;
    pc_exch_rate_string  := vc_total_exch_rate_string;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_m2m_quality_premimum',
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
  procedure sp_m2m_tc_pc_rc_charge(pc_corporate_id       varchar2,
                                   pd_trade_date         date,
                                   pc_conc_product_id    varchar2,
                                   pc_conc_quality_id    varchar2,
                                   pc_valuation_point_id varchar2,
                                   pc_charge_type        varchar2,
                                   pc_element_id         varchar2,
                                   pc_calendar_month     varchar2,
                                   pc_calendar_year      varchar2,
                                   pc_price_unit_id      varchar2,
                                   pd_payment_due_date   date,
                                   pn_charge_amt         out number,
                                   pc_exch_rate_string   out varchar2) is
    cursor cur_vcs is
      select *
        from vcs_valuation_curve_setup vcs
       where vcs.product_id = pc_conc_product_id
         and vcs.applicable_id = pc_charge_type
         and vcs.corporate_id = pc_corporate_id
         and vcs.is_active = 'Y';
    cursor cur_data(pc_vcs_id varchar2) is
      select charge_value,
             charge_unit_id
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
                 and nvl(mdcbm.is_beyond, 'N') = 'N'
                 and mdcd.valuation_region_id = pc_valuation_point_id
                 and mdcd.internal_element_id = pc_element_id
                 and mdcbm.calendar_month = pc_calendar_month
                 and mdcbm.calendar_year = pc_calendar_year
                 and mdcd.valuation_curve_id = pc_vcs_id
                 and mdcd.charge_type = pc_charge_type) t
       where t.td_rank = 1;
    cursor cur_data_beyond(pc_vcs_id varchar2) is
      select charge_value,
             charge_unit_id
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
                 and to_date('01-' || mdcbm.beyond_month || '-' ||
                             mdcbm.beyond_year,
                             'dd-Mon-yyyy') <
                     to_date('01-' || pc_calendar_month || '-' ||
                             pc_calendar_year,
                             'dd-Mon-yyyy')
                 and nvl(mdcbm.is_beyond, 'N') = 'Y'
                 and mdcbm.beyond_month is not null
                 and mdcbm.beyond_year is not null
                 and mdcd.valuation_curve_id = pc_vcs_id
                 and mdcd.charge_type = pc_charge_type) t
       where t.td_rank = 1;
    --vc_price_unit_id               varchar2(15);
    vn_total_charge                number;
    vn_charge_amt                  number;
  --  vn_charge_price_unit_id        varchar2(15);
    vc_charge_cur_id               varchar2(15);
    vc_charge_weight_unit_id       varchar2(15);
    vn_charge_weight               number;
    vc_charge_main_cur_id          varchar2(15);
    vc_charge_main_cur_code        varchar2(15);
    vc_charge_main_cur_factor      number;
    vn_fw_exch_rate_charge_to_base number;
    vn_forward_points              number;
    vc_data_missing_for            varchar2(50);
    vc_exch_rate_string            varchar2(50);
    vc_total_exch_rate_string      varchar2(100);
    vc_base_cur_id                 varchar2(15);
    vc_base_cur_code               varchar2(15);
    vc_base_weight_unit_id         varchar2(15);
  begin
    vn_total_charge := 0;
    for cur_vcs_rows in cur_vcs
    loop
      vn_charge_amt := 0;
      --
      -- Charges Based on Not beyond Values
      --  
      for cur_data_rows in cur_data(cur_vcs_rows.vcs_id)
      loop
      
        --
        -- Get the Currency of the Charge Price Unit
        --
        select ppu.cur_id,
               ppu.weight_unit_id,
               nvl(ppu.weight, 1)
          into vc_charge_cur_id,
               vc_charge_weight_unit_id,
               vn_charge_weight
          from v_ppu_pum ppu
         where ppu.product_price_unit_id = cur_data_rows.charge_unit_id;
        --
        -- Get the Main Currency of the Premium Price Unit
        --   
        pkg_general.sp_get_base_cur_detail(vc_charge_cur_id,
                                           vc_charge_main_cur_id,
                                           vc_charge_main_cur_code,
                                           vc_charge_main_cur_factor);
        --
        -- Get the Details of the Base Currency
        --  
        select ppu.cur_id,
               ppu.weight_unit_id,
               cm.cur_code
          into vc_base_cur_id,
               vc_base_weight_unit_id,
               vc_base_cur_code
          from v_ppu_pum          ppu,
               cm_currency_master cm
         where ppu.product_price_unit_id = pc_price_unit_id
           and ppu.cur_id = cm.cur_id;
      
        --
        -- Get the Exchange Rate from Premium Price Currency to Base Currency
        -- 
        if vc_charge_main_cur_id <> vc_base_cur_id then
          pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                  pd_trade_date,
                                                  pd_payment_due_date,
                                                  vc_charge_main_cur_id,
                                                  vc_base_cur_id,
                                                  30,
                                                  vn_fw_exch_rate_charge_to_base,
                                                  vn_forward_points);
        
          if vn_fw_exch_rate_charge_to_base = 0 then
          
            vc_data_missing_for := vc_charge_main_cur_code || ' / ' ||
                                   vc_base_cur_code || ' ' ||
                                   to_char(pd_payment_due_date,
                                           'dd-Mon-yyyy');
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
               'Physicals Pre-Check M2M TC/RC/PC',
               'PHY-005',
               vc_data_missing_for,
               null,
               null, --pc_process,
               systimestamp,
               null, --pc_user_id,
               null,
               pd_trade_date);
          end if;
        
          if vc_base_cur_id <> vc_charge_main_cur_id then
            vc_exch_rate_string := '1 ' || vc_charge_main_cur_code || '=' ||
                                   vn_fw_exch_rate_charge_to_base || ' ' ||
                                   vc_base_cur_code;
            if vc_total_exch_rate_string is null then
            
              vc_total_exch_rate_string := vc_exch_rate_string;
            else
              if instr(vc_total_exch_rate_string, vc_exch_rate_string) = 0 then
                vc_total_exch_rate_string := vc_total_exch_rate_string || ',' ||
                                             vc_exch_rate_string;
              
              end if;
            end if;
          end if;
        else
          vn_fw_exch_rate_charge_to_base := 1;
        end if;
      
        vn_charge_amt := (cur_data_rows.charge_value / vn_charge_weight) *
                         vc_charge_main_cur_factor *
                         vn_fw_exch_rate_charge_to_base *
                         pkg_general.f_get_converted_quantity(pc_conc_product_id,
                                                              vc_base_weight_unit_id,
                                                              vc_charge_weight_unit_id,
                                                              
                                                              1);
      
        vn_total_charge := vn_total_charge + vn_charge_amt;
      
      end loop;
      --
      -- Charges Based on beyond Values
      --  
      if vn_total_charge is null or vn_total_charge = 0 then
        for cur_data_beyond_rows in cur_data_beyond(cur_vcs_rows.vcs_id)
        loop
        
          --
          -- Get the Currency of the Charge Price Unit
          --
          select ppu.cur_id,
                 ppu.weight_unit_id,
                 nvl(ppu.weight, 1)
            into vc_charge_cur_id,
                 vc_charge_weight_unit_id,
                 vn_charge_weight
            from v_ppu_pum ppu
           where ppu.product_price_unit_id =
                 cur_data_beyond_rows.charge_unit_id;
          --
          -- Get the Main Currency of the Premium Price Unit
          --   
          pkg_general.sp_get_base_cur_detail(vc_charge_cur_id,
                                             vc_charge_main_cur_id,
                                             vc_charge_main_cur_code,
                                             vc_charge_main_cur_factor);
          --
          -- Get the Details of the Base Currency
          --  
          select ppu.cur_id,
                 ppu.weight_unit_id,
                 cm.cur_code
            into vc_base_cur_id,
                 vc_base_weight_unit_id,
                 vc_base_cur_code
            from v_ppu_pum          ppu,
                 cm_currency_master cm
           where ppu.product_price_unit_id = pc_price_unit_id
             and ppu.cur_id = cm.cur_id;
        
          --
          -- Get the Exchange Rate from Premium Price Currency to Base Currency
          -- 
          if vc_charge_main_cur_id <> vc_base_cur_id then
            pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                    pd_trade_date,
                                                    pd_payment_due_date,
                                                    vc_charge_main_cur_id,
                                                    vc_base_cur_id,
                                                    30,
                                                    vn_fw_exch_rate_charge_to_base,
                                                    vn_forward_points);
          
            if vn_fw_exch_rate_charge_to_base = 0 then
            
              vc_data_missing_for := vc_charge_main_cur_code || ' / ' ||
                                     vc_base_cur_code || ' ' ||
                                     to_char(pd_payment_due_date,
                                             'dd-Mon-yyyy');
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
                 'Physicals Pre-Check M2M TC/RC/PC Beyond',
                 'PHY-005',
                 vc_data_missing_for,
                 null,
                 null, --pc_process,
                 systimestamp,
                 null, --pc_user_id,
                 null,
                 pd_trade_date);
            end if;
          
            if vc_base_cur_id <> vc_charge_main_cur_id then
              vc_exch_rate_string := '1 ' || vc_charge_main_cur_code || '=' ||
                                     vn_fw_exch_rate_charge_to_base || ' ' ||
                                     vc_base_cur_code;
              if vc_total_exch_rate_string is null then
              
                vc_total_exch_rate_string := vc_exch_rate_string;
              else
                if instr(vc_total_exch_rate_string, vc_exch_rate_string) = 0 then
                  vc_total_exch_rate_string := vc_total_exch_rate_string || ',' ||
                                               vc_exch_rate_string;
                
                end if;
              end if;
            end if;
          else
            vn_fw_exch_rate_charge_to_base := 1;
          end if;
        
          vn_charge_amt := (cur_data_beyond_rows.charge_value /
                           vn_charge_weight) * vc_charge_main_cur_factor *
                           vn_fw_exch_rate_charge_to_base *
                           pkg_general.f_get_converted_quantity(pc_conc_product_id,
                                                                vc_base_weight_unit_id,
                                                                vc_charge_weight_unit_id,
                                                                
                                                                1);
        
          vn_total_charge := vn_total_charge + vn_charge_amt;
        
        end loop;
      
      end if;
      --
    end loop;
    if vn_total_charge is null then
      vn_total_charge := 0;
    end if;
    pn_charge_amt       := vn_total_charge;
    pc_exch_rate_string := vc_total_exch_rate_string;
  exception
    when no_data_found then
      pn_charge_amt := 0;
    when others then
      dbms_output.put_line(sqlerrm);
      pn_charge_amt := 0;
  end;
  procedure sp_calc_m2m_tc_pc_rc_charge(pc_corporate_id         varchar2,
                                        pd_trade_date           date,
                                        pc_conc_product_id      varchar2,
                                        pc_conc_quality_id      varchar2,
                                        pc_valuation_point_id   varchar2,
                                        pc_charge_type          varchar2,
                                        pc_element_id           varchar2,
                                        pc_calendar_month       varchar2,
                                        pc_calendar_year        varchar2,
                                        pc_price_unit_id        varchar2,
                                        pn_charge_amt           out number,
                                        pc_charge_price_unit_id out varchar2) is
    --vc_price_unit_id        varchar2(15);
    vn_total_chagre         number;
    vn_charge_amt           number;
    vn_chagre_price_unit_id varchar2(15);
  
    cursor cur_vcs is
      select *
        from vcs_valuation_curve_setup vcs
       where vcs.product_id = pc_conc_product_id
         and vcs.applicable_id = pc_charge_type
         and vcs.corporate_id = pc_corporate_id
         and vcs.is_active = 'Y';
  
  begin
    vn_total_chagre := 0;
    for cur_vcs_rows in cur_vcs
    loop
      vn_charge_amt := 0;
      if pc_charge_type in ('Treatment Charges', 'Refining Charges') then
        begin
          select nvl(sum(t.charge_value * case
                           when t.charge_unit_id <> pc_price_unit_id then
                            pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                            1,
                                                                            t.charge_unit_id,
                                                                            pc_price_unit_id,
                                                                            pd_trade_date)
                           else
                            1
                         end),
                     0)
            into vn_charge_amt
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
                     and nvl(mdcbm.is_beyond, 'N') = 'N'
                     and mdcd.valuation_region_id = pc_valuation_point_id
                     and mdcd.internal_element_id = pc_element_id
                     and mdcbm.calendar_month = pc_calendar_month
                     and mdcbm.calendar_year = pc_calendar_year
                     and mdcd.valuation_curve_id = cur_vcs_rows.vcs_id
                     and mdcd.charge_type = pc_charge_type) t
           where t.td_rank = 1;
          if vn_charge_amt = 0 then
            begin
              select nvl(sum(t.charge_value * case
                               when t.charge_unit_id <> pc_price_unit_id then
                                pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                                1,
                                                                                t.charge_unit_id,
                                                                                pc_price_unit_id,
                                                                                pd_trade_date)
                               else
                                1
                             end),
                         0)
                into vn_charge_amt
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
                         and mdcd.valuation_region_id =
                             pc_valuation_point_id
                         and mdcd.internal_element_id = pc_element_id
                         and to_date('01-' || mdcbm.beyond_month || '-' ||
                                     mdcbm.beyond_year,
                                     'dd-Mon-yyyy') <
                             to_date('01-' || pc_calendar_month || '-' ||
                                     pc_calendar_year,
                                     'dd-Mon-yyyy')
                         and nvl(mdcbm.is_beyond, 'N') = 'Y'
                         and mdcbm.beyond_month is not null
                         and mdcbm.beyond_year is not null
                         and mdcd.valuation_curve_id = cur_vcs_rows.vcs_id
                         and mdcd.charge_type = pc_charge_type) t
               where t.td_rank = 1;
            end;
          end if;
        end;
        vn_total_chagre         := vn_total_chagre + vn_charge_amt;
        vn_chagre_price_unit_id := pc_price_unit_id;
        --
      elsif pc_charge_type = 'Penalties' then
      
        begin
          select sum(t.charge_value * case
                       when t.charge_unit_id <> pc_price_unit_id then
                        pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                        1,
                                                                        t.charge_unit_id,
                                                                        pc_price_unit_id,
                                                                        pd_trade_date)
                       else
                        1
                     end)
            into vn_charge_amt
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
                     and nvl(mdcbm.is_beyond, 'N') = 'N'
                     and mdcbm.calendar_month = pc_calendar_month
                     and mdcbm.calendar_year = pc_calendar_year
                     and mdcd.valuation_curve_id = cur_vcs_rows.vcs_id
                     and mdcd.charge_type = pc_charge_type) t
           where t.td_rank = 1;
          if vn_charge_amt = 0 then
            begin
              select sum(t.charge_value * case
                           when t.charge_unit_id <> pc_price_unit_id then
                            pkg_phy_pre_check_process.f_get_converted_price(pc_corporate_id,
                                                                            1,
                                                                            t.charge_unit_id,
                                                                            pc_price_unit_id,
                                                                            pd_trade_date)
                           else
                            1
                         end)
                into vn_charge_amt
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
                         and mdcd.valuation_region_id =
                             pc_valuation_point_id
                         and mdcd.internal_element_id = pc_element_id
                         and to_date('01-' || mdcbm.beyond_month || '-' ||
                                     mdcbm.beyond_year,
                                     'dd-Mon-yyyy') <
                             to_date('01-' || pc_calendar_month || '-' ||
                                     pc_calendar_year,
                                     'dd-Mon-yyyy')
                         and nvl(mdcbm.is_beyond, 'N') = 'Y'
                         and mdcbm.beyond_month is not null
                         and mdcbm.beyond_year is not null
                         and mdcd.valuation_curve_id = cur_vcs_rows.vcs_id
                         and mdcd.charge_type = pc_charge_type) t
               where t.td_rank = 1;
            end;
          end if;
        end;
        vn_total_chagre         := vn_total_chagre + vn_charge_amt;
        vn_chagre_price_unit_id := pc_price_unit_id;
      
      end if;
    end loop;
    pn_charge_amt           := vn_total_chagre;
    pc_charge_price_unit_id := vn_chagre_price_unit_id;
  
  exception
    when no_data_found then
      pn_charge_amt           := 0;
      pc_charge_price_unit_id := null;
    when others then
      dbms_output.put_line(sqlerrm);
      pn_charge_amt           := 0;
      pc_charge_price_unit_id := null;
  end;
  procedure sp_m2m_product_premimum(pc_corporate_id          varchar2,
                                    pd_trade_date            date,
                                    pc_product_id            varchar2,
                                    pc_calendar_month        varchar2,
                                    pc_calendar_year         varchar2,
                                    pc_user_id               varchar2,
                                    pd_payment_due_date      date,
                                    pc_process               varchar2,
                                    pc_premium_price_unit_id varchar2,
                                    pc_valuation_point_id    varchar2,
                                    pd_valuation_fx_date     date,
                                    pn_pp_amt                out number,
                                    pn_pp_amt_corp_fx_rate   out number,
                                    pc_exch_rate_string      out varchar2,
                                    pc_exch_rate_missing     out varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    cursor cur_data is
      select *
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
                 and pp.valuation_point_id = pc_valuation_point_id
                 and ppbm.calendar_month = pc_calendar_month
                 and ppbm.calendar_year = pc_calendar_year
                 and nvl(ppbm.is_beyond, 'N') = 'N'
                 and pp.as_on_date <= pd_trade_date) t
       where t. latest_record = 1;
    cursor cur_data_beyond is
      select *
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
                 and pp.valuation_point_id = pc_valuation_point_id
                 and pp.product_id = pc_product_id --
                 and to_date('01-' || ppbm.beyond_month || '-' ||
                             ppbm.beyond_year,
                             'dd-Mon-yyyy') <
                     to_date('01-' || pc_calendar_month || '-' ||
                             pc_calendar_year,
                             'dd-Mon-yyyy')
                 and nvl(ppbm.is_beyond, 'N') = 'Y'
                 and ppbm.beyond_month is not null
                 and ppbm.beyond_year is not null
                 and pp.as_on_date <= pd_trade_date) t
       where t. latest_record = 1;
  
    vc_premium_cur_id             varchar2(15);
    vc_premium_weight_unit_id     varchar2(15);
    vn_premium_weight             number;
    vc_premium_main_cur_id        varchar2(15);
    vc_premium_main_cur_code      varchar2(15);
    vc_premium_main_cur_factor    number;
    vn_premium                    number := 0;
    vc_base_cur_id                varchar2(15);
    vc_base_cur_code              varchar2(15);
    vc_base_weight_unit_id        varchar2(15);
    vn_fw_exch_rate_prem_to_base  number;
    vn_forward_points             number;
    vn_total_premium              number := 0;
    vc_exch_rate_string           varchar2(500);
    vc_total_exch_rate_string     varchar2(500);
    vn_exchnage_rate              number;
    vn_premium_corp_fx_rate       number;
    vn_total_premium_corp_fx_rate number := 0;
    --vc_data_missing_for          varchar2(500);
  begin
    --
    -- Premium based on the not beyond  values
    --
    pc_exch_rate_missing := 'N';
    for cur_data_rows in cur_data
    loop
      if cur_data_rows.premium_price_unit_id <> pc_premium_price_unit_id then
        --
        -- Get the Currency of the Premium Price Unit
        --
        select ppu.cur_id,
               ppu.weight_unit_id,
               nvl(ppu.weight, 1)
          into vc_premium_cur_id,
               vc_premium_weight_unit_id,
               vn_premium_weight
          from v_ppu_pum ppu
         where ppu.product_price_unit_id =
               cur_data_rows.premium_price_unit_id;
        --
        -- Get the Main Currency of the Premium Price Unit
        --   
        pkg_general.sp_get_base_cur_detail(vc_premium_cur_id,
                                           vc_premium_main_cur_id,
                                           vc_premium_main_cur_code,
                                           vc_premium_main_cur_factor);
        --
        -- Get the Details of the Base Currency
        --  
        select ppu.cur_id,
               ppu.weight_unit_id,
               cm.cur_code
          into vc_base_cur_id,
               vc_base_weight_unit_id,
               vc_base_cur_code
          from v_ppu_pum          ppu,
               cm_currency_master cm
         where ppu.product_price_unit_id = pc_premium_price_unit_id
           and ppu.cur_id = cm.cur_id;
        --
        -- Get the Exchange Rate from Premium Price Currency to Base Currency
        -- 
        /* pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
        pd_trade_date,
        pd_payment_due_date,
        vc_premium_main_cur_id,
        vc_base_cur_id,
        30,
        vn_fw_exch_rate_prem_to_base,
        vn_forward_points);*/
      
        if pd_valuation_fx_date = pd_trade_date then
          pkg_general.sp_bank_fx_rate_spot(pc_corporate_id,
                                           pd_trade_date,
                                           vc_premium_main_cur_id,
                                           vc_base_cur_id,
                                           'sp_m2m_product_premium PP to Base Spot',
                                           pc_process,
                                           vn_fw_exch_rate_prem_to_base);
        else
          pkg_general.sp_bank_fx_rate_spot_fw_points(pc_corporate_id,
                                                     pd_trade_date,
                                                     pd_valuation_fx_date,
                                                     vc_premium_main_cur_id,
                                                     vc_base_cur_id,
                                                     'sp_m2m_product_premium PP to Base No Spot',
                                                     pc_process,
                                                     vn_fw_exch_rate_prem_to_base,
                                                     vn_forward_points);
        end if;
        if vn_fw_exch_rate_prem_to_base = 0 then
          pc_exch_rate_missing := 'Y';
          /*vc_data_missing_for  := vc_premium_main_cur_code || ' / ' ||
                                  vc_base_cur_code || ' ' ||
                                  to_char(pd_payment_due_date,
                                          'dd-Mon-yyyy') || ' Trade Date ' ||
                                  to_char(pd_trade_date, 'dd-Mon-yyyy');
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
             'Physicals Pre-Check M2M Product Premium',
             'PHY-005',
             vc_data_missing_for,
             null,
             pc_process,
             systimestamp,
             pc_user_id,
             null,
             pd_trade_date);*/
        end if;
        if vc_base_cur_id <> vc_premium_main_cur_id then
          vc_exch_rate_string := '1 ' || vc_premium_main_cur_code || '=' ||
                                 vn_fw_exch_rate_prem_to_base || ' ' ||
                                 vc_base_cur_code;
          if vc_total_exch_rate_string is null then
          
            vc_total_exch_rate_string := vc_exch_rate_string;
          else
            if instr(vc_total_exch_rate_string, vc_exch_rate_string) = 0 then
              vc_total_exch_rate_string := vc_total_exch_rate_string || ',' ||
                                           vc_exch_rate_string;
            
            end if;
          end if;
        end if;
      
        if vc_premium_main_cur_id <> vc_base_cur_id then
          vn_exchnage_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                       vc_premium_main_cur_id,
                                                                       vc_base_cur_id,
                                                                       pd_trade_date,
                                                                       1);
        else
          vn_exchnage_rate := 1;
        end if;
      
        vn_premium := (cur_data_rows.premium / vn_premium_weight) *
                      vc_premium_main_cur_factor *
                      vn_fw_exch_rate_prem_to_base *
                      pkg_general.f_get_converted_quantity(pc_product_id,
                                                           vc_base_weight_unit_id,
                                                           vc_premium_weight_unit_id,
                                                           
                                                           1);
      
        vn_premium_corp_fx_rate := (cur_data_rows.premium /
                                   vn_premium_weight) *
                                   vc_premium_main_cur_factor *
                                   vn_exchnage_rate *
                                   pkg_general.f_get_converted_quantity(pc_product_id,
                                                                        vc_base_weight_unit_id,
                                                                        vc_premium_weight_unit_id,
                                                                        
                                                                        1);
      else
        vn_premium              := cur_data_rows.premium;
        vn_premium_corp_fx_rate := cur_data_rows.premium;
      end if;
    
      vn_total_premium              := vn_total_premium + vn_premium;
      vn_total_premium_corp_fx_rate := vn_total_premium_corp_fx_rate +
                                       vn_premium_corp_fx_rate;
    end loop;
    if vn_total_premium is null or vn_total_premium = 0 then
      --
      -- Premium based on the not beyond  values
      --  
      for cur_data_rows in cur_data_beyond
      loop
        if cur_data_rows.premium_price_unit_id <> pc_premium_price_unit_id then
        
          --
          -- Get the Currency of the Premium Price Unit
          --
          select ppu.cur_id,
                 ppu.weight_unit_id,
                 nvl(ppu.weight, 1)
            into vc_premium_cur_id,
                 vc_premium_weight_unit_id,
                 vn_premium_weight
            from v_ppu_pum ppu
           where ppu.product_price_unit_id =
                 cur_data_rows.premium_price_unit_id;
          --
          -- Get the Main Currency of the Premium Price Unit
          --   
          pkg_general.sp_get_base_cur_detail(vc_premium_cur_id,
                                             vc_premium_main_cur_id,
                                             vc_premium_main_cur_code,
                                             vc_premium_main_cur_factor);
          --
          -- Get the Details of the Base Currency
          --  
          select ppu.cur_id,
                 ppu.weight_unit_id
            into vc_base_cur_id,
                 vc_base_weight_unit_id
            from v_ppu_pum ppu
           where ppu.product_price_unit_id = pc_premium_price_unit_id;
          --
          -- Get the Exchange Rate from Premium Price Currency to Base Currency
          -- 
          /* pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
          pd_trade_date,
          pd_payment_due_date,
          vc_premium_main_cur_id,
          vc_base_cur_id,
          30,
          vn_fw_exch_rate_prem_to_base,
          vn_forward_points);*/
          if pd_valuation_fx_date = pd_trade_date then
            pkg_general.sp_bank_fx_rate_spot(pc_corporate_id,
                                             pd_trade_date,
                                             vc_premium_main_cur_id,
                                             vc_base_cur_id,
                                             'sp_m2m_product_premium PP to Base Spot Beyond',
                                             pc_process,
                                             vn_fw_exch_rate_prem_to_base);
          else
            pkg_general.sp_bank_fx_rate_spot_fw_points(pc_corporate_id,
                                                       pd_trade_date,
                                                       pd_valuation_fx_date,
                                                       vc_premium_main_cur_id,
                                                       vc_base_cur_id,
                                                       'sp_m2m_product_premium PP to Base No Spot Beyond',
                                                       pc_process,
                                                       vn_fw_exch_rate_prem_to_base,
                                                       vn_forward_points);
          end if;
          /* if vn_fw_exch_rate_prem_to_base = 0 then
          vc_data_missing_for := vc_premium_main_cur_code || ' / ' ||
           vc_base_cur_code || ' ' ||
           to_char(pd_payment_due_date,
                   'dd-Mon-yyyy');*/
          /*insert into eel_eod_eom_exception_log eel
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
               'Physicals Pre-Check M2M Product Premium Beyond',
               'PHY-005',
               vc_data_missing_for,
               null,
               pc_process,
               systimestamp,
               pc_user_id,
               null,
               pd_trade_date);
          end if;*/
        
          if vc_premium_main_cur_id <> vc_base_cur_id then
            vn_exchnage_rate := pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                         vc_premium_main_cur_id,
                                                                         vc_base_cur_id,
                                                                         pd_trade_date,
                                                                         1);
          else
            vn_exchnage_rate := 1;
          end if;
          --
          -- Convert Premium to Base
          --
          vn_premium              := (cur_data_rows.premium /
                                     vn_premium_weight) *
                                     vc_premium_main_cur_factor *
                                     vn_fw_exch_rate_prem_to_base *
                                     pkg_general.f_get_converted_quantity(pc_product_id,
                                                                          vc_premium_weight_unit_id,
                                                                          vc_base_weight_unit_id,
                                                                          1);
          vn_premium_corp_fx_rate := (cur_data_rows.premium /
                                     vn_premium_weight) *
                                     vc_premium_main_cur_factor *
                                     vn_exchnage_rate *
                                     pkg_general.f_get_converted_quantity(pc_product_id,
                                                                          vc_premium_weight_unit_id,
                                                                          vc_base_weight_unit_id,
                                                                          1);
        
          if vc_base_cur_id <> vc_premium_main_cur_id then
            vc_exch_rate_string := '1 ' || vc_premium_main_cur_id || '=' ||
                                   vn_fw_exch_rate_prem_to_base || ' ' ||
                                   vc_base_cur_id;
            if instr(vc_total_exch_rate_string, vc_exch_rate_string) = 0 then
              vc_total_exch_rate_string := vc_total_exch_rate_string || ',' ||
                                           vc_exch_rate_string;
            end if;
          end if;
        
        else
          vn_premium              := cur_data_rows.premium;
          vn_premium_corp_fx_rate := cur_data_rows.premium;
        end if;
        vn_total_premium              := vn_total_premium + vn_premium;
        vn_total_premium_corp_fx_rate := vn_total_premium_corp_fx_rate +
                                         vn_premium_corp_fx_rate;
      end loop;
    
    end if;
    if vn_total_premium is null then
      vn_total_premium              := 0;
      vn_total_premium_corp_fx_rate := 0;
    end if;
    pn_pp_amt              := vn_total_premium;
    pn_pp_amt_corp_fx_rate := vn_total_premium_corp_fx_rate;
    pc_exch_rate_string    := vc_total_exch_rate_string;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_m2m_product_premimum',
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
    
      select nvl((((nvl((pn_price), 0)) *
                 pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                            pum1.cur_id,
                                                            pum2.cur_id,
                                                            pd_trade_date,
                                                            1)) /
                 ((ucm.multiplication_factor * nvl(pum1.weight, 1)) /
                 nvl(pum2.weight, 1))),
                 0)
        into vn_result
        from pum_price_unit_master      pum1,
             pum_price_unit_master      pum2,
             ucm_unit_conversion_master ucm
       where pum1.price_unit_id = pc_from_price_unit_id
         and pum2.price_unit_id = pc_to_price_unit_id
         and pum1.weight_unit_id = ucm.from_qty_unit_id
         and pum2.weight_unit_id = ucm.to_qty_unit_id
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
    v_dr_id                 varchar2(15);
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
      
       -- added Suresh for NPD
        if pkg_cdc_pre_check_process.fn_is_npd(pc_corporate_id,
                                               vc_delivery_calendar_id,
                                               v_trade_date)=true then
        v_trade_date:= pkg_cdc_pre_check_process.fn_get_npd_substitute_day(pc_corporate_id,
                                                                           vc_delivery_calendar_id,
                                                                           v_trade_date);
       end if;
        -- End
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
       where /*ppu1.product_id = ppu2.product_id                                                                                                                     and */
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
  
   -- vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    --vn_eel_error_count number := 1;
  
    cursor cur_qty is
      select pci.internal_contract_item_ref_no,
             cipq.element_id,
             cipq.payable_qty,
             cipq.qty_unit_id,
             pcpq.assay_header_id,
             pqca.typical,
             rm.ratio_name,
             pci.process_id
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
         and cipq.dbd_id = pc_dbd_id
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
         dbd_id,
         process_id)
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
         pc_dbd_id,
         cur_qty_rows.process_id);
    end loop;
  end;
  procedure sp_update_tmpc_fx_date(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_dbd_id       varchar2,
                                   pc_user_id      varchar2) is
    --------------------------------------------------------------------------------------------------------------------------
    --        procedure name                            : sp_update_tmpc_fx_date
    --        author                                    : janna
    --        created date                              : 16th Nov 2012
    --        purpose                                   : Update FX Date
    --
    --        parameters
    --
    --        modification history
    --        modified date                             :
    --        modified by                               :
    --        modify description                        :
    --------------------------------------------------------------------------------------------------------------------------
    --
    -- Cursor for Variable contracts, To Update QP FX Date
    --                               
    cursor cur_temp is
      select tmpc.instrument_id,
             last_day(tmpc.qp_end_date) fx_date
        from tmpc_temp_m2m_pre_check tmpc
       where tmpc.corporate_id = pc_corporate_id
         and (tmpc.section_name not in ('Shipped IN', 'Stock IN'))
         and tmpc.qp_end_date is not null
       group by tmpc.instrument_id,
                last_day(tmpc.qp_end_date);
    --
    -- Cursor for Fixed Price contracts, To Update Valuation Date
    --                               
    cursor cur_fixed_contracts is
      select tmpc.instrument_id,
             last_day(tmpc.shipment_date) fx_date
        from tmpc_temp_m2m_pre_check tmpc
       where tmpc.corporate_id = pc_corporate_id
         and tmpc.section_name not in ('Shipped IN', 'Stock IN') -- Do not consider Inventory M2M data
         and tmpc.qp_end_date is null -- Fixed Price no QP
       group by tmpc.instrument_id,
                last_day(tmpc.shipment_date);
  
    --
    -- Cursor for Variable Price contracts, To Update Valuation Date
    --                               
    cursor cur_variable_contracts is
      select tmpc.instrument_id,
             last_day(tmpc.shipment_date) fx_date
        from tmpc_temp_m2m_pre_check tmpc
       where tmpc.corporate_id = pc_corporate_id
         and tmpc.section_name not in ('Shipped IN', 'Stock IN') -- Do not consider Inventory M2M data
         and tmpc.qp_end_date is not null -- Variable Price 
       group by tmpc.instrument_id,
                last_day(tmpc.shipment_date);
  
    vd_qp_end_date   date;
    vd_3rd_wed_of_qp date;
   -- vd_quotes_date   date;
  begin
    --
    -- 1) For below case Valuation FX Date = EOD date
    -- a) Inventory M2M 
    -- b) Non Inventory M2M records with QP End date less than Or Equal to EOD Date
    --
  
    --
    -- 2.  Variable contracts, Update QP FX Date for Contract Side
    -- 
    for cur_temp_rows in cur_temp
    loop
      vd_qp_end_date   := cur_temp_rows.fx_date;
      vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                            'Wed',
                                                            3);
      while true
      loop
        if pkg_metals_general.f_is_day_holiday(cur_temp_rows.instrument_id,
                                               vd_3rd_wed_of_qp) then
          vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
        else
          exit;
        end if;
      end loop;
      if vd_3rd_wed_of_qp < pd_trade_date then
        vd_3rd_wed_of_qp := pd_trade_date;
      end if;
      update tmpc_temp_m2m_pre_check tmpc
         set tmpc.qp_fx_date = vd_3rd_wed_of_qp
       where tmpc.corporate_id = pc_corporate_id
         and last_day(tmpc.qp_end_date) = cur_temp_rows.fx_date
         and tmpc.instrument_id = cur_temp_rows.instrument_id
         and tmpc.section_name not in ('Shipped IN', 'Stock IN')
         and tmpc.qp_end_date is not null;
      commit;
    end loop;
    --
    -- 3. Fixed Price contracts
    -- If Third Wed of Shipment Month is before EOD, No update required as it is already updated as EOD Date
    -- 
    for cur_fixed_contracts_rows in cur_fixed_contracts
    loop
      vd_qp_end_date   := cur_fixed_contracts_rows.fx_date;
      vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                            'Wed',
                                                            3);
      while true
      loop
        if pkg_metals_general.f_is_day_holiday(cur_fixed_contracts_rows.instrument_id,
                                               vd_3rd_wed_of_qp) then
          vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
        else
          exit;
        end if;
      end loop;
      if vd_3rd_wed_of_qp > pd_trade_date then
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.valuation_fx_date = vd_3rd_wed_of_qp
         where tmpc.corporate_id = pc_corporate_id
           and tmpc.instrument_id = cur_fixed_contracts_rows.instrument_id
           and last_day(tmpc.shipment_date) =
               cur_fixed_contracts_rows.fx_date
           and tmpc.section_name not in ('Shipped IN', 'Stock IN')
           and tmpc.qp_end_date is null;
        commit;
      end if;
    end loop;
    --
    -- 4. Variable Price contracts
    -- If Third Wed of Shipment Month is before EOD, No update required as it is already updated as EOD Date
    -- 
  
    for cur_fixed_contracts_rows in cur_variable_contracts
    loop
      vd_qp_end_date   := cur_fixed_contracts_rows.fx_date;
      vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(vd_qp_end_date,
                                                            'Wed',
                                                            3);
      while true
      loop
        if pkg_metals_general.f_is_day_holiday(cur_fixed_contracts_rows.instrument_id,
                                               vd_3rd_wed_of_qp) then
          vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
        else
          exit;
        end if;
      end loop;
      if vd_3rd_wed_of_qp > pd_trade_date then
        update tmpc_temp_m2m_pre_check tmpc
           set tmpc.valuation_fx_date = vd_3rd_wed_of_qp
         where tmpc.corporate_id = pc_corporate_id
           and tmpc.instrument_id = cur_fixed_contracts_rows.instrument_id
           and last_day(tmpc.shipment_date) =
               cur_fixed_contracts_rows.fx_date
           and tmpc.section_name not in ('Shipped IN', 'Stock IN')
           and tmpc.qp_end_date is not null;
        commit;
      end if;
    end loop;
  end;
  procedure sp_mbv_pre_check(pc_corporate_id varchar2,
                             pd_trade_date   date,
                             pc_process      varchar2,
                             pc_process_id   varchar2,
                             pc_user_id      varchar2,
                             pc_dbd_id       varchar2) as

    cursor cur_mar_price is
      select pcdi.pcdi_id,
             pcm.contract_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             div.price_source_id,
             ps.price_source_name,
             div.available_price_id,
             apm.available_price_name,
             div.price_unit_id,
             pum.price_unit_name,
             ppu.product_price_unit_id ppu_price_unit_id,
             (case
               when pcdi.delivery_period_type = 'Date' then
                last_day(pcdi.delivery_to_date)
               when pcdi.delivery_period_type = 'Month' then
                last_day(to_date(to_char('01-' || pcdi.delivery_to_month || ' ' ||
                                         pcdi.delivery_to_year),
                                 'dd-Mon-yyyy'))
             end) delivery_date,
             poch.element_id,
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
         and pcm.contract_status <> 'Cancelled'
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
         and dim.product_derivative_id = pdd.derivative_def_id
         and div.price_unit_id = ppu.price_unit_id
         and pdd.product_id = ppu.product_id
         and pcdi.price_option_call_off_status <> 'Not Called Off'
       group by pcdi.pcdi_id,
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
                pcdi.delivery_period_type,
                pcdi.delivery_to_date,
                pcdi.delivery_to_month,
                pcdi.delivery_to_year,
                poch.element_id,
                dim.delivery_calender_id
      union all
      select pcdi.pcdi_id,
             pcm.contract_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             div.price_source_id,
             ps.price_source_name,
             div.available_price_id,
             apm.available_price_name,
             div.price_unit_id,
             pum.price_unit_name,
             ppu.product_price_unit_id ppu_price_unit_id,
             (case
               when pcdi.delivery_period_type = 'Date' then
                last_day(pcdi.delivery_to_date)
               when pcdi.delivery_period_type = 'Month' then
                last_day(to_date(to_char('01-' || pcdi.delivery_to_month || ' ' ||
                                         pcdi.delivery_to_year),
                                 'dd-Mon-yyyy'))
             end) delivery_date,
             pcbph.element_id,
             dim.delivery_calender_id
        from pcm_physical_contract_main     pcm,
             pcdi_pc_delivery_item          pcdi,
             pci_physical_contract_item     pci,
             pcipf_pci_pricing_formula      pcipf,
             pcbph_pc_base_price_header     pcbph,
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
         and pcm.contract_status <> 'Cancelled'
         and pcdi.is_active = 'Y'
         and pcdi.process_id = pc_process_id
         and pci.pcdi_id = pcdi.pcdi_id
         and pci.process_id = pc_process_id
         and pci.is_active = 'Y'
         and pci.internal_contract_item_ref_no =
             pcipf.internal_contract_item_ref_no
         and pcipf.process_id = pc_process_id
         and pcipf.is_active = 'Y'
         and pcipf.pcbph_id = pcbph.pcbph_id
         and pcbph.process_id = pc_process_id
         and pcbph.is_active = 'Y'
         and pcbph.pcbph_id = pcbpd.pcbph_id
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
         and dim.product_derivative_id = pdd.derivative_def_id
         and div.price_unit_id = ppu.price_unit_id
         and pdd.product_id = ppu.product_id
         and pcdi.price_option_call_off_status = 'Not Called Off'
       group by pcdi.pcdi_id,
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
                pcdi.delivery_period_type,
                pcdi.delivery_to_date,
                pcdi.delivery_to_month,
                pcdi.delivery_to_year,
                pcbph.element_id,
                dim.delivery_calender_id;

    vn_price                     number;
    vc_price_unit_id             varchar2(15);
    vd_3rd_wed_of_qp             date;
    vc_price_dr_id               varchar2(15);
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vd_valid_quote_date          date;
    vd_quotes_date               date;
    workings_days                number;
    vc_price_unit_cur_id         varchar2(15);
    vc_price_unit_cur_code       varchar2(15);
    vc_price_unit_weight_unit_id varchar2(15);
    vc_price_unit_weight_unit    varchar2(15);
    vn_price_unit_weight         number;
    vc_error_msg                 varchar2(100);
    vd_prev_eom_date             date;
  begin
    for cur_mar_price_rows in cur_mar_price
    loop
      vn_price         := null;
      vd_3rd_wed_of_qp := pkg_metals_general.f_get_next_day(cur_mar_price_rows.delivery_date,
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
       -- added Suresh for NPD
       if pkg_cdc_pre_check_process.fn_is_npd(pc_corporate_id,
                                              cur_mar_price_rows.delivery_calender_id,
                                              vd_3rd_wed_of_qp)=true then
      vd_3rd_wed_of_qp:= pkg_cdc_pre_check_process.fn_get_npd_substitute_day(pc_corporate_id,
                                                                             cur_mar_price_rows.delivery_calender_id,
                                                                             vd_3rd_wed_of_qp);
       end if;
       -- End
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
                                                                 'procedure sp_calc_DI_Valuation_price',
                                                                 'PHY-002',
                                                                 'DR_ID missing for ' ||
                                                                 cur_mar_price_rows.instrument_name ||
                                                                 ',Price Source:' ||
                                                                 cur_mar_price_rows.price_source_name ||
--                                                                 ' Contract Ref No: ' ||
--                                                                 cur_mar_price_rows.contract_ref_no ||
                                                                 ',Price Unit:' ||
                                                                 cur_mar_price_rows.price_unit_name || ',' ||
                                                                 cur_mar_price_rows.available_price_name ||
                                                                 ' Price,Prompt Date:' ||
                                                                 vd_3rd_wed_of_qp,
                                                                 cur_mar_price_rows.contract_ref_no,
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
          from dq_temp        dq,
               dqd_temp dqd,
               cdim_corporate_dim          cdim
         where dq.dq_id = dqd.dq_id
           and dqd.dr_id = vc_price_dr_id
           and dq.dbd_id = pc_dbd_id
           and dqd.dbd_id = pc_dbd_id
           and dq.instrument_id = cur_mar_price_rows.instrument_id
           and dqd.available_price_id = cur_mar_price_rows.available_price_id
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
                                                               'procedure sp_calc_DI_Valuation_price',
                                                               'PHY-002', --
                                                               'Price missing for ' ||
                                                               cur_mar_price_rows.instrument_name ||
                                                               ',Price Source:' ||
                                                               cur_mar_price_rows.price_source_name || --
                                                           --    ' Contract Ref No: ' ||
                                                          --     cur_mar_price_rows.contract_ref_no ||
                                                               ',Price Unit:' ||
                                                               cur_mar_price_rows.price_unit_name || ',' ||
                                                               cur_mar_price_rows.available_price_name ||
                                                               ' Price,Prompt Date:' ||
                                                               to_char(vd_3rd_wed_of_qp,
                                                                       'dd-Mon-yyyy') ||
                                                               ' Trade Date :' ||
                                                               to_char(vd_valid_quote_date,
                                                                       'dd-Mon-yyyy'),
                                                               cur_mar_price_rows.contract_ref_no,
                                                               pc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        
      end;
      vc_price_unit_id := cur_mar_price_rows.ppu_price_unit_id;
    
      -- Get Price Unit Currency, Quantity Details
      begin
        select cm.cur_id,
               cm.cur_code,
               qum.qty_unit_id,
               qum.qty_unit,
               ppu.weight
          into vc_price_unit_cur_id,
               vc_price_unit_cur_code,
               vc_price_unit_weight_unit_id,
               vc_price_unit_weight_unit,
               vn_price_unit_weight
          from v_ppu_pum                ppu,
               cm_currency_master       cm,
               qum_quantity_unit_master qum
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.cur_id = cm.cur_id
           and ppu.weight_unit_id = qum.qty_unit_id;
      exception
        when others then
          vc_price_unit_cur_id         := null;
          vc_price_unit_cur_code       := null;
          vc_price_unit_weight_unit_id := null;
          vc_price_unit_weight_unit    := null;
          vn_price_unit_weight         := null;
      end;
    
      insert into mbv_di_valuation_price
        (process_id,
         contract_ref_no,
         pcdi_id,
         element_id,
         delivery_date,
         price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight,
         price_unit_weight_unit_id,
         price_unit_weight_unit)
      values
        (pc_process_id,
         cur_mar_price_rows.contract_ref_no,
         cur_mar_price_rows.pcdi_id,
         cur_mar_price_rows.element_id,
         cur_mar_price_rows.delivery_date,
         vn_price,
         vc_price_unit_id,
         vc_price_unit_cur_id,
         vc_price_unit_cur_code,
         vn_price_unit_weight,
         vc_price_unit_weight_unit_id,
         vc_price_unit_weight_unit);
    end loop;
    commit;
    --
    -- MBV Precheck for Missing Price For Active Fixations
    --
    -- a) Concentrate  and Base Metal Active Price Fixations
    -- 
    begin
      select tdc.trade_date
        into vd_prev_eom_date
        from tdc_trade_date_closure tdc
       where tdc.corporate_id = pc_corporate_id
         and tdc.process = pc_process
         and tdc.trade_date =
             (select max(tdc_in.trade_date)
                from tdc_trade_date_closure tdc_in
               where tdc_in.corporate_id = pc_corporate_id
                 and tdc_in.process = pc_process
                 and tdc_in.trade_date < pd_trade_date);
    exception
      when others then
        vd_prev_eom_date := to_date('01-Jan-2000', 'dd-Mon-yyyy');
    end;
    insert into eel_eod_eom_exception_log
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
      select pcm.corporate_id,
             'sp_calc_pf_data precheck',
             'PHY-105',
             'Contract Delivery No: ' || pcm.contract_ref_no || '(' ||
             pcdi.delivery_item_no || ')' || ' PF Ref No: ' ||
             axs.action_ref_no,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             null,
             pd_trade_date
        from pcm_physical_contract_main     pcm,
             pcdi_pc_delivery_item          pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pfam_price_fix_action_mapping  pfam,
             axs_action_summary             axs
       where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = poch.pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pocd_id = pofh.pocd_id
         and pofh.pofh_id = pfd.pofh_id
         and pfd.pfd_id = pfam.pfd_id
         and pfam.internal_action_ref_no = axs.internal_action_ref_no
         and pcm.dbd_id = pc_dbd_id
         and pcdi.dbd_id = pc_dbd_id
         and pcm.is_active = 'Y'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pfam.is_active = 'Y'
         and pfd.is_active = 'Y'
         and pfd.hedge_correction_date > vd_prev_eom_date
         and pfd.hedge_correction_date <= pd_trade_date
         and pcm.is_pass_through = 'N'
         and axs.process = 'EOM'
         and pocd.price_type <> 'Fixed'
         and nvl(pfd.user_price, 0) = 0
         group by pcm.corporate_id,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          axs.action_ref_no;
    commit;
    --
    -- b) Free Metal Active Price Fixations
    -- 
    insert into eel_eod_eom_exception_log
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
      select fmuh.corporate_id,
             'pkg_phy_mbv_report.sp_calc_pf_data',
             'PHY-105',
             'Free Metal PF Ref No: ' || axs.action_ref_no,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             null,
             pd_trade_date
        from fmuh_free_metal_utility_header fmuh,
             fmed_free_metal_elemt_details  fmed,
             fmpfh_price_fixation_header    fmpfh,
             fmpfd_price_fixation_details   fmpfd,
             fmpfam_price_action_mapping    fmpfam,
             axs_action_summary             axs
       where fmuh.fmuh_id = fmed.fmuh_id
         and fmed.fmed_id = fmpfh.fmed_id
         and fmed.element_id = fmpfh.element_id
         and fmpfh.fmpfh_id = fmpfd.fmpfh_id
         and fmpfd.fmpfd_id = fmpfam.fmpfd_id
         and fmpfam.is_active = 'Y'
         and fmuh.is_active = 'Y'
         and fmed.is_active = 'Y'
         and fmpfh.is_active = 'Y'
         and fmpfam.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eff_date > vd_prev_eom_date
         and axs.eff_date <= pd_trade_date
         and axs.process = 'EOM'
         and nvl(fmpfd.user_price, 0) = 0
         group by fmuh.corporate_id,axs.action_ref_no;
    commit;
    insert into eel_eod_eom_exception_log
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
      select pc_corporate_id,
             'pkg_phy_m2m_values_ppu',
             'M2M-030',
             pdm.product_desc || ': ' || pum.price_unit_name,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             null,
             pd_trade_date
        from pdd_product_derivative_def   pdd,
             pdm_productmaster            pdm,
             pum_price_unit_master        pum,
             dim_der_instrument_master    dim,
             div_der_instrument_valuation div,
             irm_instrument_type_master   irm
       where pdd.product_id = pdm.product_id
         and div.price_unit_id = pum.price_unit_id
         and pdd.is_deleted = 'N'
         and pdd.is_active = 'Y'
         and dim.product_derivative_id = pdd.derivative_def_id
         and dim.is_active = 'Y'
         and dim.is_deleted = 'N'
         and div.instrument_id = dim.instrument_id
         and div.is_deleted = 'N'
         and irm.instrument_type_id = dim.instrument_type_id
         and irm.is_active = 'Y'
         and irm.instrument_type = 'Future'
         and not exists (select *
                from ppu_product_price_units ppu
               where ppu.product_id = pdm.product_id
                 and ppu.price_unit_id = div.price_unit_id
                 and ppu.is_deleted = 'N');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_mbv_report.sp_calc_di_valuation_price',
                                                           'M2M-013',
                                                           'Code:' || sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           '  Error Msg: ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           null,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;
end pkg_phy_pre_check_process; 
/
