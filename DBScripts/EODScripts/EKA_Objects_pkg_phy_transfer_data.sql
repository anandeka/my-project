create or replace package pkg_phy_transfer_data is

  -- Author  : SURESHGOTTIPATI
  -- Created : 5/2/2011 3:09:18 PM
  -- Purpose : 
  gvc_previous_dbd_id varchar2(15);
  gvc_process_id      varchar2(15);

  procedure sp_phy_transfer_data(pc_corporate_id       in varchar2,
                                 pt_previous_pull_date timestamp,
                                 pt_current_pull_date  timestamp,
                                 pd_trade_date         date,
                                 pc_user_id            varchar2,
                                 pc_process            varchar2,
                                 pc_dbd_id             varchar2);

  procedure sp_phy_refresh_app_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2,
                                    pc_process      varchar2);

  procedure sp_phy_insert_ul_data(pc_corporate_id       in varchar2,
                                  pt_previous_pull_date timestamp,
                                  pt_current_pull_date  timestamp,
                                  pc_user_id            varchar2,
                                  pc_process            varchar2,
                                  pc_dbd_id             varchar2,
                                  pd_trade_date         date,
                                  pc_app_eodeom_id      varchar2);

  procedure sp_phy_insert_costing_data(pc_corporate_id in varchar2,
                                       pc_user_id      varchar2,
                                       pc_process      varchar2,
                                       pc_dbd_id       varchar2,
                                       pd_trade_date   date);
  procedure sp_phy_delete_m2m_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2,
                                   pc_process      varchar2);
  procedure sp_phy_insert_m2m_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2,
                                   pc_process      varchar2);

end pkg_phy_transfer_data; 
/
create or replace package body pkg_phy_transfer_data is

  procedure sp_phy_transfer_data(pc_corporate_id       in varchar2,
                                 pt_previous_pull_date timestamp,
                                 pt_current_pull_date  timestamp,
                                 pd_trade_date         date,
                                 pc_user_id            varchar2,
                                 pc_process            varchar2,
                                 pc_dbd_id             varchar2)
  --*****************************************************************************************************************************************
    --                    procedure name                           : sp_cdc_transfer_data
    --                    author                                   : siva
    --                    created date                             : 09th jan 2009
    --                    purpose                                  : transfer transaction data into eod database
    --                    parameters
    --
    --                    pc_corporate_id                          corporate id
    --                    pt_previous_pull_date                    last dump date
    --                    pt_current_pull_date                     current sys time(when called)
    --                    pd_trade_date                            eod data
    --                    pc_user_id                               user id
    --                    pc_process                               process = 'eod'
    --
    --                    modification history
    --                    modified by                              :
    --                    modified date                            :
    --                    modify description                       :
    --*****************************************************************************************************************************************
   is
    vc_dbd_id          varchar2(15);
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_logno           number := 25;
    vc_app_eodeom_id   varchar2(15);
    vc_err_msg         varchar2(10);
  begin
    vc_err_msg := '1';
    begin
      select tdc.process_id
        into gvc_process_id
        from tdc_trade_date_closure tdc
       where tdc.process = pc_process
         and tdc.trade_date = pd_trade_date
         and tdc.corporate_id = pc_corporate_id;
    exception
      when others then
        null;
    end;
  
    begin
      select dbd.dbd_id
        into gvc_previous_dbd_id
        from dbd_database_dump dbd
       where dbd.corporate_id = pc_corporate_id
         and dbd.process = pc_process
         and dbd.trade_date =
             (select max(dbd.trade_date)
                from dbd_database_dump dbd
               where dbd.corporate_id = pc_corporate_id
                 and dbd.trade_date < pd_trade_date
                 and dbd.process = pc_process);
    exception
      when no_data_found then
        gvc_previous_dbd_id := null;
    end;
    --Get the Latest EOD/EOM Table id from app schema which is used for Transfering AXS data
    begin
      if pc_process = 'EOD' then
        select eod.eod_id
          into vc_app_eodeom_id
          from eod_end_of_day_details@eka_appdb eod
         where eod.corporate_id = pc_corporate_id
           and eod.as_of_date = pd_trade_date;
      
      else
        select eom.eom_id
          into vc_app_eodeom_id
          from eom_end_of_month_details@eka_appdb eom
         where eom.corporate_id = pc_corporate_id
           and eom.as_of_date = pd_trade_date;
      end if;
    exception
      when no_data_found then
        vc_app_eodeom_id := null;
    end;
  
    vc_dbd_id := pc_dbd_id;
    vn_logno  := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'Data Transfer Started ...');
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
    vn_logno   := vn_logno + 1;
    vc_err_msg := '2';
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'sp_phy_refresh_app_data');
    sp_phy_refresh_app_data(pc_corporate_id,
                            pd_trade_date,
                            pc_user_id,
                            pc_process);
  
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
    vn_logno := vn_logno + 1;
  
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'sp_phy_insert_ul_data');
    vc_err_msg := '3';
    sp_phy_insert_ul_data(pc_corporate_id,
                          pt_previous_pull_date,
                          pt_current_pull_date,
                          pc_user_id,
                          pc_process,
                          pc_dbd_id,
                          pd_trade_date,
                          vc_app_eodeom_id);
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'sp_phy_insert_costing_data');
    vc_err_msg := '4';
    sp_phy_insert_costing_data(pc_corporate_id,
                               pc_user_id,
                               pc_process,
                               pc_dbd_id,
                               pd_trade_date);
    if pkg_process_status.sp_get(pc_corporate_id, pc_process, pd_trade_date) =
       'Cancel' then
      goto cancel_process;
    end if;
  
    vc_err_msg := '5';
    sp_phy_delete_m2m_data(pc_corporate_id,
                           pd_trade_date,
                           pc_user_id,
                           pc_process);
    vc_err_msg := '6';
    sp_phy_insert_m2m_data(pc_corporate_id,
                           pd_trade_date,
                           pc_user_id,
                           pc_process);
  
    <<cancel_process>>
    dbms_output.put_line('EOD/EOM Process Cancelled while transafer data');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'Procedure sp_phy_transfer_data',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_err_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;
  procedure sp_phy_delete_m2m_data
  --*****************************************************************************************************************************************
    --                Procedure Name                           : sp_delete_m2m_data
    --                Author                                   : 
    --                Created Date                             : 12th jan 2011
    --                Purpose                                  : To delete M2M data From EOD database
    --                Parameters
    --
    --                pc_corporate_id                          Corporate ID
    --                pd_trade_date                            EOD Data
    --                pc_user_id                               User ID
    --                pc_process                               Process = 'EOD'
    --
    --                Modification History
    --                Modified By                              :
    --                Modified Date                            :
    --                Modify Description                       :
    --*****************************************************************************************************************************************
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_process      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    delete from ldc_location_diff_cost
     where loc_diff_id in
           (select loc_diff_id
              from lds_location_diff_setup
             where corporate_id = pc_corporate_id);
    delete from lds_location_diff_setup
     where corporate_id = pc_corporate_id;
    commit;
    --Moved 
    delete from mvpl_m2m_valuation_point_loc
     where mvp_id in (select mvp_id
                        from mvp_m2m_valuation_point
                       where corporate_id = pc_corporate_id);
    commit;
    delete from mvp_m2m_valuation_point
     where corporate_id = pc_corporate_id;
    --ends here
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'Procedure sp_phy_delete_m2m_data',
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
  procedure sp_phy_insert_m2m_data
  --*****************************************************************************************************************************************
    --                Procedure Name                           : sp_insert_m2m_data
    --                Author                                   : 
    --                Created Date                             : 12th jan 2011
    --                Purpose                                  : Transfer transaction M2M data into EOD database
    --                Parameters
    --
    --                pc_corporate_id                          : Corporate ID
    --                pd_trade_date                            : EOD Data
    --                pc_user_id                               : User ID
    --                pc_process                               : Process = 'EOD'
    --
    --                Modification History
    --                Modified By                              :
    --                Modified Date                            :
    --                Modify Description                       :
    --*****************************************************************************************************************************************
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_process      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
  
    insert into mvp_m2m_valuation_point
      (mvp_id,
       corporate_id,
       product_id,
       origin_group_id,
       valuation_region,
       valuation_point,
       valuation_point_desc,
       valuation_basis,
       benchmark_city_id,
       valuation_incoterm_id,
       -- valuation_cur_id,
       --valuation_price_unit_id,
       remarks,
       in_transit_incoterm_id,
       in_store_incoterm_id)
      select mvp_id,
             corporate_id,
             product_id,
             origin_group_id,
             valuation_region,
             valuation_point,
             valuation_point_desc,
             valuation_basis,
             benchmark_city_id,
             valuation_incoterm_id,
             --   valuation_cur_id,
             -- valuation_price_unit_id,
             remarks,
             in_transit_incoterm_id,
             in_store_incoterm_id
        from mvp_m2m_valuation_point@eka_appdb
       where corporate_id = pc_corporate_id
         and is_deleted = 'N'
         and is_active = 'Y';
    commit;
    insert into mvpl_m2m_valuation_point_loc
      (mvpl_id, mvp_id, loc_city_id)
      select mvpl_id,
             mvp_id,
             loc_city_id
        from mvpl_m2m_valuation_point_loc@eka_appdb
       where mvp_id in (select mvp_id
                          from mvp_m2m_valuation_point
                         where corporate_id = pc_corporate_id)
         and is_deleted = 'N';
    commit;
    /*INSERT INTO mmv_m2m_market_values
    (mmv_id,
     as_on_date,
     product_id,
     valuation_point_id,
     exchange_id,
     price_type,
     created_by,
     created_date,
     updated_by,
     updated_date)
    SELECT mmv_id,
           as_on_date,
           product_id,
           valuation_point_id,
           derivative_def_id,
           value_type,
           created_by,
           created_date,
           updated_by,
           updated_date
    FROM   mmv_m2m_market_values@eka_appdb
    WHERE  valuation_point_id IN
           (SELECT mvp_id
            FROM   mvp_m2m_valuation_point
            WHERE  corporate_id = pc_corporate_id);*/
    /*INSERT INTO mvbm_market_value_by_month
    (mvbm_id,
     mmv_id,
     quality_id,
     calendar_month,
     calendar_year,
     market_value,
     market_value_price_unit_id,
     is_beyond,
     beyond_month,
     beyond_year)
    SELECT mvbm_id,
           mmv_id,
           quality_id,
           calendar_month,
           calendar_year,
           market_value,
           market_value_price_unit_id,
           is_beyond,
           beyond_month,
           beyond_year
    FROM   mvbm_market_value_by_month@eka_appdb
    WHERE  mmv_id IN
           (SELECT mmv_id
            FROM   mmv_m2m_market_values
            WHERE  valuation_point_id IN
                   (SELECT mvp_id
                    FROM   mvp_m2m_valuation_point
                    WHERE  corporate_id = pc_corporate_id));*/
  
    insert into lds_location_diff_setup
      (loc_diff_id,
       corporate_id,
       product_id,
       as_on_date,
       inco_term_id,
       created_by,
       created_date,
       updated_by,
       updated_date,
       valuation_point_id,
       valuation_city_id)
      select loc_diff_id,
             corporate_id,
             product_id,
             as_on_date,
             inco_term_id,
             created_by,
             created_date,
             updated_by,
             updated_date,
             valuation_point_id,
             valuation_city_id
        from lds_location_diff_setup@eka_appdb ldh
       where corporate_id = pc_corporate_id;
    commit;
    insert into ldc_location_diff_cost
      (loc_diff_id, cost_component_id, cost_value, cost_price_unit_id)
      select loc_diff_id,
             cost_component_id,
             cost_value,
             cost_price_unit_id
        from ldc_location_diff_cost@eka_appdb
       where loc_diff_id in
             (select loc_diff_id
                from lds_location_diff_setup
               where corporate_id = pc_corporate_id);
    commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'Procedure sp_phy_insert_m2m_data',
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
  procedure sp_phy_refresh_app_data
  --*****************************************************************************************************************************************
    --                Procedure Name                           : sp_refresh_app_data
    --                Author                                   : 
    --                Created Date                             : 12th jan 2011
    --                Purpose                                  : To refresh application data(Materialized View)
    --                Parameters
    --
    --                pc_corporate_id                          : Corporate ID
    --                pd_trade_date                            : EOD Data
    --                pc_user_id                               : User ID
    --                pc_process                               : Process = 'EOD'
    --
    --                Modification History
    --                Modified By                              :
    --                Modified Date                            :
    --                Modify Description                       :
    --*****************************************************************************************************************************************
  (pc_corporate_id varchar2,
   pd_trade_date   date,
   pc_user_id      varchar2,
   pc_process      varchar2) is
    vobj_error_log          tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count      number := 1;
    vc_other_process_status number := 0;
  begin
    begin
      if pc_process = 'EOD' then
        select count(*)
          into vc_other_process_status
          from eod_end_of_day_details@eka_appdb eod
         where eod.corporate_id <> pc_corporate_id
           and eod.as_of_date <> pd_trade_date
           and eod.processing_status = 'Running';
      else
        select count(*)
          into vc_other_process_status
          from eom_end_of_month_details@eka_appdb eom
         where eom.corporate_id <> pc_corporate_id
           and eom.as_of_date <> pd_trade_date
           and eom.processing_status = 'Running';
      end if;
    exception
      when others then
        vc_other_process_status := 1;
    end;
    if vc_other_process_status = 0 then
      dbms_mview.refresh('BGM_BP_GROUP_MASTER', 'f');
      dbms_mview.refresh('BPC_BP_CORPORATES', 'f');
      dbms_mview.refresh('BPSLD_BP_STORAGE_LOC_DET', 'f');
      dbms_mview.refresh('CGM_COST_GROUP_MASTER', 'f');
      dbms_mview.refresh('CPOG_CORP_PRODUCT_ORIGIN_GROUP', 'f');
      dbms_mview.refresh('CPPM_COR_PRODUCT_PDD_MAPPING', 'f');
      dbms_mview.refresh('GSM_GMR_STAUTS_MASTER', 'f');
      dbms_mview.refresh('ITM_INCOTERM_MASTER', 'f');
      dbms_mview.refresh('ORM_ORIGIN_MASTER', 'f');
      dbms_mview.refresh('POG_PRODUCT_ORIGIN_GROUP', 'f');
      dbms_mview.refresh('POM_PRODUCT_ORIGIN_MASTER', 'f');
      dbms_mview.refresh('PPS_PRODUCT_PACKING_SIZE', 'f');
      dbms_mview.refresh('PSM_PACKING_SIZE_MASTER', 'f');
      dbms_mview.refresh('PTM_PACKING_TYPE_MASTER', 'f');
      dbms_mview.refresh('SLD_STORAGE_LOCATION_DETAIL', 'f');
      dbms_mview.refresh('POCH_PRICE_OPT_CALL_OFF_HEADER', 'f');
      dbms_mview.refresh('POCD_PRICE_OPTION_CALLOFF_DTLS', 'f');
      dbms_mview.refresh('pofh_price_opt_fixation_header', 'f');
      dbms_mview.refresh('PPS_PRODUCT_PREMIUM_SETUP', 'f');
      dbms_mview.refresh('VCS_VALUATION_CURVE_SETUP', 'f');
      dbms_mview.refresh('VCA_VALUATION_CURVE_ATTRIBUTE', 'f');
      dbms_mview.refresh('PFD_PRICE_FIXATION_DETAILS', 'f');
      dbms_mview.refresh('PP_PRODUCT_PREMIUM', 'f');
      dbms_mview.refresh('PPBM_PRODUCT_PREMIUM_BY_MONTH', 'f');
      dbms_mview.refresh('QP_QUALITY_PREMIUM', 'f');
      dbms_mview.refresh('QPBM_QUALITY_PREMIUM_BY_MONTH', 'f');
      dbms_mview.refresh('ASH_ASSAY_HEADER', 'f');
      dbms_mview.refresh('ASM_ASSAY_SUBLOT_MAPPING', 'f');
      dbms_mview.refresh('PQCA_PQ_CHEMICAL_ATTRIBUTES', 'f');
      dbms_mview.refresh('PQPA_PQ_PHYSICAL_ATTRIBUTES', 'f');
      dbms_mview.refresh('RM_RATIO_MASTER', 'f');
      dbms_mview.refresh('AML_ATTRIBUTE_MASTER_LIST', 'f');
      dbms_mview.refresh('PPM_PRODUCT_PROPERTIES_MAPPING', 'f');
      dbms_mview.refresh('QAV_QUALITY_ATTRIBUTE_VALUES', 'f');
      dbms_mview.refresh('MDCD_M2M_DED_CHARGE_DETAILS', 'f');
      dbms_mview.refresh('MDCBM_DED_CHARGES_BY_MONTH', 'f');
      dbms_mview.refresh('MNM_MONTH_NAME_MASTER', 'f');
      dbms_mview.refresh('MV_QAT_QUALITY_VALUATION', 'c');
      dbms_mview.refresh('MV_CONC_QAT_QUALITY_VALUATION', 'c');
      dbms_mview.refresh('DI_DEL_ITEM_EXP_QP_DETAILS', 'f');
      dbms_mview.refresh('PCMTE_PCM_TOLLING_EXT', 'f');
      dbms_mview.refresh('PQDT_PAYABLE_EXT_TOLLING', 'f');
      dbms_mview.refresh('PQCAPD_PRD_QLTY_CATTR_PAY_DTLS', 'f');
      dbms_mview.refresh('SAM_STOCK_ASSAY_MAPPING', 'f');
      dbms_mview.refresh('II_INVOICABLE_ITEM', 'f');
      dbms_mview.refresh('IID_INVOICABLE_ITEM_DETAILS', 'f');
      dbms_mview.refresh('SCM_STOCK_COST_MAPPING', 'f');
      dbms_mview.refresh('SAC_STOCK_ASSAY_CONTENT', 'f');
      dbms_mview.refresh('IIED_INV_ITEM_ELEMENT_DETAILS', 'f');
      dbms_mview.refresh('INTC_INV_TREATMENT_CHARGES', 'f');
      dbms_mview.refresh('INRC_INV_REFINING_CHARGES', 'f');
      dbms_mview.refresh('IEPD_INV_EPENALTY_DETAILS', 'f');
      dbms_mview.refresh('IAM_INVOICE_ASSAY_MAPPING', 'f');
      dbms_mview.refresh('IAM_INVOICE_ACTION_MAPPING', 'f');
      dbms_mview.refresh('AGMR_ACTION_GMR', 'f');
      dbms_mview.refresh('REM_REGION_MASTER', 'f');
      dbms_mview.refresh('BVD_BP_VAT_DETAILS', 'f');
      dbms_mview.refresh('IOC_INVOICE_OTHER_CHARGE', 'f');
      dbms_mview.refresh('YPD_YIELD_PCT_DETAIL', 'f');
      dbms_mview.refresh('SBS_SMELTER_BASE_STOCK', 'f');
      dbms_mview.refresh('PRRQS_PRR_QTY_STATUS', 'f');
      dbms_mview.refresh('PSR_POOL_STOCK_REGISTER', 'f');
      dbms_mview.refresh('PM_POOL_MASTER', 'f');
      dbms_mview.refresh('GPAD_GMR_PRICE_ALLOC_DTLS', 'f');
      dbms_mview.refresh('GPAH_GMR_PRICE_ALLOC_HEADER', 'f');
      dbms_mview.refresh('FMUH_FREE_METAL_UTILITY_HEADER', 'f');
      dbms_mview.refresh('FMED_FREE_METAL_ELEMT_DETAILS', 'f');
      dbms_mview.refresh('FMPFH_PRICE_FIXATION_HEADER', 'f');
      dbms_mview.refresh('PFAM_PRICE_FIX_ACTION_MAPPING', 'f');
      dbms_mview.refresh('IVD_INVOICE_VAT_DETAILS', 'f');
      dbms_mview.refresh('FMPFD_PRICE_FIXATION_DETAILS', 'f');
      dbms_mview.refresh('FMPFAM_PRICE_ACTION_MAPPING', 'f');
    end if;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'Procedure sp_phy_refresh_app_data',
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
  procedure sp_phy_insert_ul_data
  --*****************************************************************************************************************************************
    --                procedure name                           : sp_insert_ul_data
    --                author                                   : siva
    --                created date                             : 09th jan 2009
    --                purpose                                  : transfer transaction data into eod database
    --                parameters
    --
    --                pc_corporate_id                          corporate id
    --                pd_trade_date                            eod data
    --                pc_user_id                               user id
    --                pc_process                               process = 'eod'
    --
    --                modification history
    --                modified by                              :
    --                modified date                            :
    --                modify description                       :
    --*****************************************************************************************************************************************
  (pc_corporate_id       in varchar2,
   pt_previous_pull_date timestamp,
   pt_current_pull_date  timestamp,
   pc_user_id            varchar2,
   pc_process            varchar2,
   pc_dbd_id             varchar2,
   pd_trade_date         date,
   pc_app_eodeom_id      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_logno           number;
    vc_dbd_id          varchar2(15);
  begin
    vn_logno  := 0;
    vc_dbd_id := pc_dbd_id;
    insert into agdul_alloc_group_detail_ul
      (internal_action_ref_no,
       int_alloc_group_detail_id,
       entry_type,
       int_alloc_group_id,
       internal_contract_item_ref_no,
       qty,
       qty_unit_id,
       alloc_type,
       created_by,
       created_date,
       updated_by,
       updated_date,
       cancelled_by,
       cancelled_date,
       qty_in_sales_unit,
       internal_stock_ref_no,
       sales_qty_unit_id,
       is_deleted,
       no_of_units,
       packing_size_id,
       handled_as,
       dbd_id)
      select ul.internal_action_ref_no,
             ul.int_alloc_group_detail_id,
             ul.entry_type,
             ul.int_alloc_group_id,
             ul.internal_contract_item_ref_no,
             ul.qty,
             ul.qty_unit_id,
             ul.alloc_type,
             ul.created_by,
             ul.created_date,
             ul.updated_by,
             ul.updated_date,
             ul.cancelled_by,
             ul.cancelled_date,
             ul.qty_in_sales_unit,
             ul.internal_stock_ref_no,
             ul.sales_qty_unit_id,
             ul.is_deleted,
             ul.no_of_units,
             ul.packing_size_id,
             ul.handled_as,
             pc_dbd_id
        from agdul_alloc_group_detail_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb             axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:agdul_alloc_group_detail_ul');
    insert into aghul_alloc_group_header_ul
      (internal_action_ref_no,
       int_alloc_group_id,
       entry_type,
       int_sales_contract_item_ref_no,
       alloc_group_name,
       alloc_date,
       alloc_remarks,
       alloc_item_qty,
       alloc_item_qty_unit_id,
       execution_status,
       created_by,
       created_date,
       updated_by,
       updated_date,
       cancelled_by,
       cancelled_date,
       is_deleted,
       group_type,
       realized_status,
       realized_date,
       realized_creation_date,
       partnership_type,
       dbd_id)
      select ul.internal_action_ref_no,
             ul.int_alloc_group_id,
             ul.entry_type,
             ul.int_sales_contract_item_ref_no,
             ul.alloc_group_name,
             ul.alloc_date,
             ul.alloc_remarks,
             ul.alloc_item_qty,
             ul.alloc_item_qty_unit_id,
             ul.execution_status,
             ul.created_by,
             ul.created_date,
             ul.updated_by,
             ul.updated_date,
             ul.cancelled_by,
             ul.cancelled_date,
             ul.is_deleted,
             ul.group_type,
             ul.realized_status,
             ul.realized_date,
             ul.realized_creation_date,
             ul.partnership_type,
             pc_dbd_id
        from aghul_alloc_group_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb             axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:aghul_alloc_group_header_ul');
  
    insert into cigcul_contrct_itm_gmr_cost_ul
      (cogul_ref_no,
       internal_action_ref_no,
       entry_type,
       cog_ref_no,
       internal_gmr_ref_no,
       int_contract_item_ref_no,
       internal_grd_ref_no,
       qty,
       qty_unit_id,
       qty_in_base_qty_unit,
       corporate_qty_unit_id,
       is_deleted,
       version,
       gmr_activity_type,
       dbd_id)
      select ul.cogul_ref_no,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.cog_ref_no,
             ul.internal_gmr_ref_no,
             ul.int_contract_item_ref_no,
             ul.internal_grd_ref_no,
             ul.qty,
             ul.qty_unit_id,
             ul.qty_in_base_qty_unit,
             ul.corporate_qty_unit_id,
             ul.is_deleted,
             ul.version,
             ul.gmr_activity_type,
             pc_dbd_id
        from cigcul_contrct_itm_gmr_cost_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:cigcul_contrct_itm_gmr_cost_ul');
  
    insert into csul_cost_store_ul
      (internal_cost_ul_id,
       internal_cost_id,
       entry_type,
       internal_action_ref_no,
       cog_ref_no,
       cost_ref_no,
       cost_type,
       cost_component_id,
       rate_type,
       cost_value,
       rate_price_unit_id,
       transaction_amt,
       transaction_amt_cur_id,
       fx_to_base,
       transact_amt_sign,
       cost_acc_type,
       base_amt,
       base_amt_cur_id,
       cost_in_base_price_unit_id,
       base_price_unit_id,
       cost_in_transact_price_unit_id,
       counter_party_id,
       parent_estimated_cost_ref_no,
       estimated_amt,
       is_inv_possible,
       version,
       is_deleted,
       effective_date,
       income_expense,
       est_payment_due_date,
       inv_to_accrual_curr_fx,
       is_actual_posted_in_cog,
       dbd_id,
       acc_direct_actual,
       acc_original_accrual,
       acc_over_accrual,
       acc_under_accrual,
       delta_cost_in_base_price_id,
       reversal_type)
      select ul.internal_cost_ul_id,
             ul.internal_cost_id,
             ul.entry_type,
             ul.internal_action_ref_no,
             ul.cog_ref_no,
             ul.cost_ref_no,
             ul.cost_type,
             ul.cost_component_id,
             ul.rate_type,
             ul.cost_value,
             ul.rate_price_unit_id,
             ul.transaction_amt,
             ul.transaction_amt_cur_id,
             ul.fx_to_base,
             ul.transact_amt_sign,
             ul.cost_acc_type,
             ul.base_amt,
             ul.base_amt_cur_id,
             ul.cost_in_base_price_unit_id,
             ul.base_price_unit_id,
             ul.cost_in_transact_price_unit_id,
             ul.counter_party_id,
             ul.parent_estimated_cost_ref_no,
             ul.estimated_amt,
             ul.is_inv_possible,
             ul.version,
             ul.is_deleted,
             ul.effective_date,
             ul.income_expense,
             ul.est_payment_due_date,
             ul.inv_to_accrual_curr_fx,
             ul.is_actual_posted_in_cog,
             pc_dbd_id,
             ul.acc_direct_actual,
             ul.acc_original_accrual,
             ul.acc_over_accrual,
             ul.acc_under_accrual,
             ul.delta_cost_in_base_price_id,
             ul.reversal_type
        from csul_cost_store_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb    axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:csul_cost_store_ul');
  
    insert into cdl_cost_delta_log
      (cdl_id,
       internal_action_ref_no,
       cost_ref_no,
       delta_cost,
       version,
       dbd_id)
      select ul.cdl_id,
             ul.internal_action_ref_no,
             ul.cost_ref_no,
             ul.delta_cost,
             ul.version,
             pc_dbd_id
        from cdl_cost_delta_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb    axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:cdl_cost_delta_log');
  
    insert into dgrdul_delivered_grd_ul
      (internal_action_ref_no,
       internal_dgrd_ref_no,
       entry_type,
       internal_grd_ref_no,
       action_no,
       internal_gmr_ref_no,
       qty,
       int_alloc_group_id,
       bale_batch_ref_no,
       container_no,
       seal_no,
       mark_no,
       release_shipped_no_of_units,
       status,
       old_net_weight,
       gross_weight,
       tare_weight,
       bl_date,
       bl_number,
       shed_id,
       realized_qty,
       parent_dgrd_ref_no,
       internal_stock_ref_no,
       warehouse_profile_id,
       warehouse_receipt_no,
       warehouse_receipt_date,
       is_final_weight,
       bank_id,
       bank_account_id,
       inventory_status,
       is_afloat,
       is_write_off,
       write_off_qty,
       crop_year_id,
       current_qty,
       internal_contract_item_ref_no,
       is_weight_final,
       origin_id,
       packing_size_id,
       product_id,
       product_specs,
       quality_id,
       net_weight,
       net_weight_unit_id,
       realized_status,
       realized_date,
       realized_creation_date,
       stock_status,
       item_price,
       item_price_unit,
       packing_type_id,
       write_off_no_of_units,
       handled_as,
       current_no_of_units,
       total_no_of_units,
       no_of_units,
       total_qty,
       stock_condition,
       gravity_type_id,
       gravity,
       density_mass_qty_unit_id,
       density_volume_qty_unit_id,
       gravity_type,
       customs_id,
       tax_id,
       duty_id,
       phy_attribute_group_no,
       assay_header_id,
       customer_seal_no,
       brand,
       no_of_bags,
       no_of_containers,
       no_of_pieces,
       p_shipped_net_weight,
       p_shipped_gross_weight,
       p_shipped_tare_weight,
       sdcts_id,
       partnership_type,
       profit_center_id,
       strategy_id,
       is_warrant,
       warrant_no,
       dbd_id,
       tolling_stock_type,
       pcdi_id)
      select ul.internal_action_ref_no,
             ul.internal_dgrd_ref_no,
             ul.entry_type,
             ul.internal_grd_ref_no,
             ul.action_no,
             ul.internal_gmr_ref_no,
             ul.qty,
             ul.int_alloc_group_id,
             ul.bale_batch_ref_no,
             ul.container_no,
             ul.seal_no,
             ul.mark_no,
             ul.release_shipped_no_of_units,
             ul.status,
             ul.old_net_weight,
             ul.gross_weight,
             ul.tare_weight,
             ul.bl_date,
             ul.bl_number,
             ul.shed_id,
             ul.realized_qty,
             ul.parent_dgrd_ref_no,
             ul.internal_stock_ref_no,
             ul.warehouse_profile_id,
             ul.warehouse_receipt_no,
             ul.warehouse_receipt_date,
             ul.is_final_weight,
             ul.bank_id,
             ul.bank_account_id,
             ul.inventory_status,
             ul.is_afloat,
             ul.is_write_off,
             ul.write_off_qty,
             ul.crop_year_id,
             ul.current_qty,
             ul.internal_contract_item_ref_no,
             ul.is_weight_final,
             ul.origin_id,
             ul.packing_size_id,
             ul.product_id,
             ul.product_specs,
             ul.quality_id,
             ul.net_weight,
             ul.net_weight_unit_id,
             ul.realized_status,
             ul.realized_date,
             ul.realized_creation_date,
             ul.stock_status,
             ul.item_price,
             ul.item_price_unit,
             ul.packing_type_id,
             ul.write_off_no_of_units,
             ul.handled_as,
             ul.current_no_of_units,
             ul.total_no_of_units,
             ul.no_of_units,
             ul.total_qty,
             ul.stock_condition,
             ul.gravity_type_id,
             ul.gravity,
             ul.density_mass_qty_unit_id,
             ul.density_volume_qty_unit_id,
             ul.gravity_type,
             ul.customs_id,
             ul.tax_id,
             ul.duty_id,
             ul.phy_attribute_group_no,
             ul.assay_header_id,
             ul.customer_seal_no,
             ul.brand,
             ul.no_of_bags,
             ul.no_of_containers,
             ul.no_of_pieces,
             ul.p_shipped_net_weight,
             ul.p_shipped_gross_weight,
             ul.p_shipped_tare_weight,
             ul.sdcts_id,
             ul.partnership_type,
             ul.profit_center_id,
             ul.strategy_id,
             ul.is_warrant,
             ul.warrant_no,
             pc_dbd_id,
             ul.tolling_stock_type,
             ul.pcdi_id
        from dgrdul_delivered_grd_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb         axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:dgrdul_delivered_grd_ul');
  
    insert into gmrul_gmr_ul
      (internal_action_ref_no,
       internal_gmr_ref_no,
       entry_type,
       gmr_ref_no,
       gmr_first_int_action_ref_no,
       internal_contract_ref_no,
       gmr_latest_action_action_id,
       corporate_id,
       created_by,
       created_date,
       contract_type,
       status_id,
       qty,
       current_qty,
       qty_unit_id,
       no_of_units,
       current_no_of_units,
       shipped_qty,
       landed_qty,
       weighed_qty,
       plan_ship_qty,
       released_qty,
       bl_no,
       trucking_receipt_no,
       rail_receipt_no,
       bl_date,
       trucking_receipt_date,
       rail_receipt_date,
       warehouse_receipt_no,
       origin_city_id,
       origin_country_id,
       destination_city_id,
       destination_country_id,
       loading_country_id,
       loading_port_id,
       discharge_country_id,
       discharge_port_id,
       trans_port_id,
       trans_country_id,
       warehouse_profile_id,
       shed_id,
       shipping_line_profile_id,
       controller_profile_id,
       vessel_name,
       eff_date,
       inventory_no,
       inventory_status,
       inventory_in_date,
       inventory_out_date,
       is_final_weight,
       final_weight,
       sales_int_alloc_group_id,
       is_internal_movement,
       is_deleted,
       is_voyage_gmr,
       loaded_qty,
       discharged_qty,
       voyage_alloc_qty,
       fulfilled_qty,
       voyage_status,
       tt_in_qty,
       tt_out_qty,
       tt_under_cma_qty,
       tt_none_qty,
       moved_out_qty,
       is_settlement_gmr,
       write_off_qty,
       gravity_type_id,
       gravity,
       density_mass_qty_unit_id,
       density_volume_qty_unit_id,
       gravity_type,
       loading_state_id,
       loading_city_id,
       trans_state_id,
       trans_city_id,
       discharge_state_id,
       discharge_city_id,
       place_of_receipt_country_id,
       place_of_receipt_state_id,
       place_of_receipt_city_id,
       place_of_delivery_country_id,
       place_of_delivery_state_id,
       place_of_delivery_city_id,
       tolling_qty,
       tolling_gmr_type,
       pool_id,
       is_warrant,
       is_pass_through,
       pledge_input_gmr,
       is_apply_freight_allowance,
       is_apply_container_charge,
       mode_of_transport,
       arrival_date,
       wns_status,
       base_conc_mix_type,
       dbd_id)
      select ul.internal_action_ref_no,
             ul.internal_gmr_ref_no,
             ul.entry_type,
             ul.gmr_ref_no,
             ul.gmr_first_int_action_ref_no,
             ul.internal_contract_ref_no,
             ul.gmr_latest_action_action_id,
             ul.corporate_id,
             ul.created_by,
             ul.created_date,
             ul.contract_type,
             ul.status_id,
             ul.qty,
             ul.current_qty,
             ul.qty_unit_id,
             ul.no_of_units,
             ul.current_no_of_units,
             ul.shipped_qty,
             ul.landed_qty,
             ul.weighed_qty,
             ul.plan_ship_qty,
             ul.released_qty,
             ul.bl_no,
             ul.trucking_receipt_no,
             ul.rail_receipt_no,
             ul.bl_date,
             ul.trucking_receipt_date,
             ul.rail_receipt_date,
             ul.warehouse_receipt_no,
             ul.origin_city_id,
             ul.origin_country_id,
             ul.destination_city_id,
             ul.destination_country_id,
             ul.loading_country_id,
             ul.loading_port_id,
             ul.discharge_country_id,
             ul.discharge_port_id,
             ul.trans_port_id,
             ul.trans_country_id,
             ul.warehouse_profile_id,
             ul.shed_id,
             ul.shipping_line_profile_id,
             ul.controller_profile_id,
             ul.vessel_name,
             ul.eff_date,
             ul.inventory_no,
             ul.inventory_status,
             ul.inventory_in_date,
             ul.inventory_out_date,
             ul.is_final_weight,
             ul.final_weight,
             ul.sales_int_alloc_group_id,
             ul.is_internal_movement,
             ul.is_deleted,
             ul.is_voyage_gmr,
             ul.loaded_qty,
             ul.discharged_qty,
             ul.voyage_alloc_qty,
             ul.fulfilled_qty,
             ul.voyage_status,
             ul.tt_in_qty,
             ul.tt_out_qty,
             ul.tt_under_cma_qty,
             ul.tt_none_qty,
             ul.moved_out_qty,
             ul.is_settlement_gmr,
             ul.write_off_qty,
             ul.gravity_type_id,
             ul.gravity,
             ul.density_mass_qty_unit_id,
             ul.density_volume_qty_unit_id,
             ul.gravity_type,
             ul.loading_state_id,
             ul.loading_city_id,
             ul.trans_state_id,
             ul.trans_city_id,
             ul.discharge_state_id,
             ul.discharge_city_id,
             ul.place_of_receipt_country_id,
             ul.place_of_receipt_state_id,
             ul.place_of_receipt_city_id,
             ul.place_of_delivery_country_id,
             ul.place_of_delivery_state_id,
             ul.place_of_delivery_city_id,
             ul.tolling_qty,
             ul.tolling_gmr_type,
             ul.pool_id,
             ul.is_warrant,
             ul.is_pass_through,
             ul.pledge_input_gmr,
             ul.is_apply_freight_allowance,
             ul.is_apply_container_charge,
             ul.mode_of_transport,
             ul.arrival_date,
             ul.wns_status,
             ul.base_conc_mix_type,
             pc_dbd_id
        from gmrul_gmr_ul@eka_appdb    ul,
             eod_eom_axsdata@eka_appdb axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:gmrul_gmr_ul');
    insert into mogrdul_moved_out_grd_ul
      (internal_action_ref_no,
       entry_type,
       internal_grd_ref_no,
       pool_id,
       action_no,
       internal_gmr_ref_no,
       moved_out_qty,
       qty_unit_id,
       moved_out_no_of_units,
       status,
       tare_weight,
       gross_weight,
       dbd_id)
      select ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_grd_ref_no,
             ul.pool_id,
             ul.action_no,
             ul.internal_gmr_ref_no,
             ul.moved_out_qty,
             ul.qty_unit_id,
             ul.moved_out_no_of_units,
             ul.status,
             ul.tare_weight,
             ul.gross_weight,
             pc_dbd_id
        from mogrdul_moved_out_grd_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb          axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:mogrdul_moved_out_grd_ul');
  
    insert into pcadul_pc_agency_detail_ul
      (pcadul_id,
       internal_action_ref_no,
       pcad_id,
       internal_contract_ref_no,
       agency_cp_id,
       commission_type,
       commission_value,
       commission_unit_id,
       commission_formula_id,
       basis_incoterm_id,
       basis_country_id,
       basis_state_id,
       basis_city_id,
       is_parity_required,
       parity_value,
       comments,
       version,
       entry_type,
       is_active,
       dbd_id)
      select ul.pcadul_id,
             ul.internal_action_ref_no,
             ul.pcad_id,
             ul.internal_contract_ref_no,
             ul.agency_cp_id,
             ul.commission_type,
             ul.commission_value,
             ul.commission_unit_id,
             ul.commission_formula_id,
             ul.basis_incoterm_id,
             ul.basis_country_id,
             ul.basis_state_id,
             ul.basis_city_id,
             ul.is_parity_required,
             ul.parity_value,
             ul.comments,
             ul.version,
             ul.entry_type,
             ul.is_active,
             pc_dbd_id
        from pcadul_pc_agency_detail_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcadul_pc_agency_detail_ul');
  
    insert into pcbpdul_pc_base_price_dtl_ul
      (pcbpdul_id,
       internal_action_ref_no,
       pcbpd_id,
       element_id,
       price_basis,
       price_value,
       price_unit_id,
       tonnage_basis,
       pffxd_id,
       version,
       is_active,
       entry_type,
       fx_to_base,
       qty_to_be_priced,
       pcbph_id,
       description,
       valuation_price_percentage,
       dbd_id)
      select ul.pcbpdul_id,
             ul.internal_action_ref_no,
             ul.pcbpd_id,
             ul.element_id,
             ul.price_basis,
             ul.price_value,
             ul.price_unit_id,
             ul.tonnage_basis,
             ul.pffxd_id,
             ul.version,
             ul.is_active,
             ul.entry_type,
             ul.fx_to_base,
             ul.qty_to_be_priced,
             ul.pcbph_id,
             ul.description,
             ul.valuation_price_percentage,
             pc_dbd_id
        from pcbpdul_pc_base_price_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcbpdul_pc_base_price_dtl_ul');
  
    insert into pcbphul_pc_base_prc_header_ul
      (pcbphul_id,
       internal_action_ref_no,
       entry_type,
       pcbph_id,
       optionality_desc,
       version,
       is_active,
       internal_contract_ref_no,
       price_description,
       element_id,
       is_free_metal_applicable,
       valuation_price_percentage,
       is_balance_pricing,
       dbd_id)
      select ul.pcbphul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcbph_id,
             ul.optionality_desc,
             ul.version,
             ul.is_active,
             ul.internal_contract_ref_no,
             ul.price_description,
             ul.element_id,
             ul. is_free_metal_applicable,
             ul.valuation_price_percentage,
             is_balance_pricing,
             pc_dbd_id
        from pcbphul_pc_base_prc_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcbphul_pc_base_prc_header_ul');
  
    insert into pcdbul_pc_delivery_basis_ul
      (pcdbul_id,
       internal_action_ref_no,
       pcdb_id,
       internal_contract_ref_no,
       inco_term_id,
       warehouse_id,
       warehouse_shed_id,
       country_id,
       state_id,
       city_id,
       port_id,
       customs,
       premium,
       premium_unit_id,
       duty_status,
       tax_status,
       version,
       entry_type,
       is_active,
       pffxd_id,
       dbd_id)
      select ul.pcdbul_id,
             ul.internal_action_ref_no,
             ul.pcdb_id,
             ul.internal_contract_ref_no,
             ul.inco_term_id,
             ul.warehouse_id,
             ul.warehouse_shed_id,
             ul.country_id,
             ul.state_id,
             ul.city_id,
             ul.port_id,
             ul.customs,
             ul.premium,
             ul.premium_unit_id,
             ul.duty_status,
             ul.tax_status,
             ul.version,
             ul.entry_type,
             ul.is_active,
             ul.pffxd_id,
             pc_dbd_id
        from pcdbul_pc_delivery_basis_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb             axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcdbul_pc_delivery_basis_ul');
  
    insert into pcddul_document_details_ul
      (pcddul_id,
       internal_action_ref_no,
       entry_type,
       pcdd_id,
       doc_id,
       doc_type,
       version,
       is_active,
       internal_contract_ref_no,
       dbd_id)
      select ul.pcddul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcdd_id,
             ul.doc_id,
             ul.doc_type,
             ul.version,
             ul.is_active,
             ul.internal_contract_ref_no,
             pc_dbd_id
        from pcddul_document_details_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcddul_document_details_ul');
  
    insert into pcdiobul_di_optional_basis_ul
      (pcdiobul_id,
       internal_action_ref_no,
       entry_type,
       pcdiob_id,
       pcdi_id,
       pcdb_id,
       version,
       is_active,
       dbd_id)
      select ul.pcdiobul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcdiob_id,
             ul.pcdi_id,
             ul.pcdb_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcdiobul_di_optional_basis_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcdiobul_di_optional_basis_ul');
  
    insert into pcdipeul_di_pricing_elemnt_ul
      (pcdipeul_id,
       internal_action_ref_no,
       entry_type,
       pcdipe_id,
       pcdi_id,
       pcbph_id,
       version,
       is_active,
       dbd_id)
      select ul.pcdipeul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcdipe_id,
             ul.pcdi_id,
             ul.pcbph_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcdipeul_di_pricing_elemnt_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcdipeul_di_pricing_elemnt_ul');
  
    insert into pcdiqdul_di_quality_detail_ul
      (pcdiqdul_id,
       internal_action_ref_no,
       entry_type,
       pcdiqd_id,
       pcdi_id,
       pcpq_id,
       version,
       is_active,
       dbd_id)
      select ul.pcdiqdul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcdiqd_id,
             ul.pcdi_id,
             ul.pcpq_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcdiqdul_di_quality_detail_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcdiqdul_di_quality_detail_ul');
  
    insert into pcdiul_pc_delivery_item_ul
      (pcdiul_id,
       internal_action_ref_no,
       pcdi_id,
       internal_contract_ref_no,
       delivery_item_no,
       prefix,
       middle_no,
       suffix,
       basis_type,
       delivery_period_type,
       delivery_from_month,
       delivery_from_year,
       delivery_to_month,
       delivery_to_year,
       delivery_from_date,
       delivery_to_date,
       transit_days,
       qty_min_operator,
       qty_min_val,
       qty_max_operator,
       qty_max_val,
       unit_of_measure,
       qty_unit_id,
       trader_option,
       tolerance_type,
       min_tolerance,
       max_tolerance,
       tolerance_unit_id,
       version,
       is_active,
       qp_declaration_date,
       quality_option_type,
       pricing_option_type,
       is_optionality_present,
       payment_due_date,
       price_option_call_off_status,
       is_price_optionality_present,
       entry_type,
       is_phy_optionality_present,
       item_price_type,
       item_price,
       item_price_unit,
       qty_declaration_date,
       quality_declaration_date,
       inco_location_declaration_date,
       price_allocation_method,
       dbd_id)
      select ul.pcdiul_id,
             ul.internal_action_ref_no,
             ul.pcdi_id,
             ul.internal_contract_ref_no,
             ul.delivery_item_no,
             ul.prefix,
             ul.middle_no,
             ul.suffix,
             ul.basis_type,
             ul.delivery_period_type,
             ul.delivery_from_month,
             ul.delivery_from_year,
             ul.delivery_to_month,
             ul.delivery_to_year,
             ul.delivery_from_date,
             ul.delivery_to_date,
             ul.transit_days,
             ul.qty_min_operator,
             ul.qty_min_val,
             ul.qty_max_operator,
             ul.qty_max_val,
             ul.unit_of_measure,
             ul.qty_unit_id,
             ul.trader_option,
             ul.tolerance_type,
             ul.min_tolerance,
             ul.max_tolerance,
             ul.tolerance_unit_id,
             ul.version,
             ul.is_active,
             ul.qp_declaration_date,
             ul.quality_option_type,
             ul.pricing_option_type,
             ul.is_optionality_present,
             ul.payment_due_date,
             ul.price_option_call_off_status,
             ul.is_price_optionality_present,
             ul.entry_type,
             ul.is_phy_optionality_present,
             ul.item_price_type,
             ul.item_price,
             ul.item_price_unit,
             ul.qty_declaration_date,
             ul.quality_declaration_date,
             ul.inco_location_declaration_date,
             ul.price_allocation_method,
             pc_dbd_id
        from pcdiul_pc_delivery_item_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcdiul_pc_delivery_item_ul');
  
    insert into pcipful_pci_pricing_formula_ul
      (pcipful_id,
       internal_action_ref_no,
       entry_type,
       pcipf_id,
       internal_contract_item_ref_no,
       pcbph_id,
       version,
       is_active,
       dbd_id)
      select ul.pcipful_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcipf_id,
             ul.internal_contract_item_ref_no,
             ul.pcbph_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcipful_pci_pricing_formula_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcipful_pci_pricing_formula_ul');
  
    insert into pciul_phy_contract_item_ul
      (pciul_id,
       internal_action_ref_no,
       entry_type,
       internal_contract_item_ref_no,
       pcpq_id,
       pcdi_id,
       pcdb_id,
       item_qty,
       item_qty_unit_id,
       delivery_from_month,
       delivery_from_year,
       delivery_to_month,
       delivery_to_year,
       delivery_period_type,
       delivery_from_date,
       delivery_to_date,
       del_distribution_item_no,
       version,
       is_active,
       expected_delivery_month,
       expected_delivery_year,
       m2m_inco_term,
       m2m_country_id,
       m2m_state_id,
       m2m_city_id,
       m2m_region_id,
       is_called_off,
       expected_qp_start_date,
       expected_qp_end_date,
       item_status,
       dbd_id)
      select ul.pciul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_contract_item_ref_no,
             ul.pcpq_id,
             ul.pcdi_id,
             ul.pcdb_id,
             ul.item_qty,
             ul.item_qty_unit_id,
             ul.delivery_from_month,
             ul.delivery_from_year,
             ul.delivery_to_month,
             ul.delivery_to_year,
             ul.delivery_period_type,
             ul.delivery_from_date,
             ul.delivery_to_date,
             ul.del_distribution_item_no,
             ul.version,
             ul.is_active,
             ul.expected_delivery_month,
             ul.expected_delivery_year,
             ul.m2m_inco_term,
             ul.m2m_country_id,
             ul.m2m_state_id,
             ul.m2m_city_id,
             ul.m2m_region_id,
             ul.is_called_off,
             ul.expected_qp_start_date,
             ul.expected_qp_end_date,
             ul.item_status,
             pc_dbd_id
        from pciul_phy_contract_item_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pciul_phy_contract_item_ul');
  
    insert into pcjvul_pc_jv_detail_ul
      (pcjvul_id,
       internal_action_ref_no,
       pcjv_id,
       internal_contract_ref_no,
       cp_id,
       profit_share_percentage,
       loss_share_percentage,
       comments,
       version,
       entry_type,
       is_active,
       dbd_id)
      select ul.pcjvul_id,
             ul.internal_action_ref_no,
             ul.pcjv_id,
             ul.internal_contract_ref_no,
             ul.cp_id,
             ul.profit_share_percentage,
             ul.loss_share_percentage,
             ul.comments,
             ul.version,
             ul.entry_type,
             ul.is_active,
             pc_dbd_id
        from pcjvul_pc_jv_detail_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb        axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcjvul_pc_jv_detail_ul');
  
    insert into pcmul_phy_contract_main_ul
      (pcmul_id,
       internal_action_ref_no,
       internal_contract_ref_no,
       contract_ref_no,
       issue_date,
       prefix,
       middle_no,
       suffix,
       our_person_in_charge_id,
       trader_id,
       cp_id,
       cp_person_in_charge_id,
       cp_contract_ref_no,
       partnership_type,
       invoice_currency_id,
       is_inter_company_deal,
       is_draft,
       cancellation_date,
       reason_to_cancel,
       product_group_type,
       contract_type,
       purchase_sales,
       corporate_id,
       contract_status,
       prod_qual_comments,
       base_price_comments,
       trtmt_charge_comments,
       del_basis_comments,
       del_schedule_comments,
       umpire_rule_id,
       sampling_rules,
       cost_basis_id,
       version,
       is_active,
       is_optionality_contract,
       payment_term_id,
       provisional_pymt_pctg,
       provisional_pymt_at,
       payment_text,
       insurance,
       taxes,
       gen_sale_condition,
       other_terms,
       internal_comments,
       weight_allowance,
       weight_allowance_unit_id,
       entry_type,
       unit_of_measure,
       approval_status,
       is_tolling_contract,
       cp_address_id,
       is_lot_level_invoice,
       dbd_id)
      select ul.pcmul_id,
             ul.internal_action_ref_no,
             ul.internal_contract_ref_no,
             ul.contract_ref_no,
             ul.issue_date,
             ul.prefix,
             ul.middle_no,
             ul.suffix,
             ul.our_person_in_charge_id,
             ul.trader_id,
             ul.cp_id,
             ul.cp_person_in_charge_id,
             ul.cp_contract_ref_no,
             ul.partnership_type,
             ul.invoice_currency_id,
             ul.is_inter_company_deal,
             ul.is_draft,
             ul.cancellation_date,
             ul.reason_to_cancel,
             ul.product_group_type,
             ul.contract_type,
             ul.purchase_sales,
             ul.corporate_id,
             ul.contract_status,
             ul.prod_qual_comments,
             ul.base_price_comments,
             ul.trtmt_charge_comments,
             ul.del_basis_comments,
             ul.del_schedule_comments,
             ul.umpire_rule_id,
             ul.sampling_rules,
             ul.cost_basis_id,
             ul.version,
             ul.is_active,
             ul.is_optionality_contract,
             ul.payment_term_id,
             ul.provisional_pymt_pctg,
             ul.provisional_pymt_at,
             ul.payment_text,
             ul.insurance,
             ul.taxes,
             ul.gen_sale_condition,
             ul.other_terms,
             ul.internal_comments,
             ul.weight_allowance,
             ul.weight_allowance_unit_id,
             ul.entry_type,
             ul.unit_of_measure,
             ul.approval_status,
             ul.is_tolling_contract,
             ul.cp_address_id,
             ul.is_lot_level_invoice,
             pc_dbd_id
        from pcmul_phy_contract_main_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcmul_phy_contract_main_ul');
  
    insert into pcpdqdul_pd_quality_dtl_ul
      (pcpdqdul_id,
       internal_action_ref_no,
       pcpdqd_id,
       pcqpd_id,
       pcpq_id,
       version,
       entry_type,
       is_active,
       quality_name,
       dbd_id)
      select ul.pcpdqdul_id,
             ul.internal_action_ref_no,
             ul.pcpdqd_id,
             ul.pcqpd_id,
             ul.pcpq_id,
             ul.version,
             ul.entry_type,
             ul.is_active,
             ul.quality_name,
             pc_dbd_id
        from pcpdqdul_pd_quality_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcpdqdul_pd_quality_dtl_ul');
  
    insert into pcpdul_pc_product_defintn_ul
      (pcpdul_id,
       internal_action_ref_no,
       pcpd_id,
       internal_contract_ref_no,
       product_id,
       profit_center_id,
       qty_type,
       qty_min_operator,
       qty_min_val,
       qty_max_operator,
       qty_max_val,
       unit_of_measure,
       qty_unit_id,
       is_metal_content,
       metal_content_elm_id,
       tolerance_type,
       min_tolerance,
       max_tolerance,
       tolerance_unit_id,
       comments,
       version,
       is_active,
       strategy_id,
       is_quality_print_name_req,
       entry_type,
       quality_print_name,
       input_output,
       dbd_id)
      select ul.pcpdul_id,
             ul.internal_action_ref_no,
             ul.pcpd_id,
             ul.internal_contract_ref_no,
             ul.product_id,
             ul.profit_center_id,
             ul.qty_type,
             ul.qty_min_operator,
             ul.qty_min_val,
             ul.qty_max_operator,
             ul.qty_max_val,
             ul.unit_of_measure,
             ul.qty_unit_id,
             ul.is_metal_content,
             ul.metal_content_elm_id,
             ul.tolerance_type,
             ul.min_tolerance,
             ul.max_tolerance,
             ul.tolerance_unit_id,
             ul.comments,
             ul.version,
             ul.is_active,
             ul.strategy_id,
             ul.is_quality_print_name_req,
             ul.entry_type,
             ul.quality_print_name,
             ul.input_output,
             pc_dbd_id
        from pcpdul_pc_product_defintn_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcpdul_pc_product_defintn_ul');
  
    insert into pcpqul_pc_product_quality_ul
      (pcpqul_id,
       internal_action_ref_no,
       pcpq_id,
       pcpd_id,
       quality_template_id,
       phy_attribute_group_no,
       assay_header_id,
       qty_type,
       qty_min_op,
       qty_min_val,
       qty_max_op,
       qty_max_val,
       unit_of_measure,
       qty_unit_id,
       version,
       is_active,
       is_quality_print_name_req,
       quality_print_name,
       entry_type,
       comments,
       dbd_id)
      select ul.pcpqul_id,
             ul.internal_action_ref_no,
             ul.pcpq_id,
             ul.pcpd_id,
             ul.quality_template_id,
             ul.phy_attribute_group_no,
             ul.assay_header_id,
             ul.qty_type,
             ul.qty_min_op,
             ul.qty_min_val,
             ul.qty_max_op,
             ul.qty_max_val,
             ul.unit_of_measure,
             ul.qty_unit_id,
             ul.version,
             ul.is_active,
             ul.is_quality_print_name_req,
             ul.quality_print_name,
             ul.entry_type,
             ul.comments,
             pc_dbd_id
        from pcpqul_pc_product_quality_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcpqul_pc_product_quality_ul');
  
    insert into pcqpdul_pc_qual_prm_discnt_ul
      (pcqpdul_id,
       internal_action_ref_no,
       pcqpd_id,
       internal_contract_ref_no,
       premium_disc_name,
       premium_disc_type,
       premium_disc_value,
       premium_disc_unit_id,
       pffxd_id,
       version,
       entry_type,
       is_active,
       dbd_id)
      select ul.pcqpdul_id,
             ul.internal_action_ref_no,
             ul.pcqpd_id,
             ul.internal_contract_ref_no,
             ul.premium_disc_name,
             ul.premium_disc_type,
             ul.premium_disc_value,
             ul.premium_disc_unit_id,
             ul.pffxd_id,
             ul.version,
             ul.entry_type,
             ul.is_active,
             pc_dbd_id
        from pcqpdul_pc_qual_prm_discnt_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcqpdul_pc_qual_prm_discnt_ul');
  
    insert into pffxdul_phy_formula_fx_dtl_ul
      (pffxdul_id,
       internal_action_ref_no,
       entry_type,
       pffxd_id,
       fx_rate_type,
       fixed_fx_rate,
       currency_pair_instrument,
       price_source_id,
       off_day_price,
       fx_period_from_date,
       fx_period_to_date,
       fx_month,
       fx_year,
       fx_date,
       fx_event_from,
       fx_event_period_type,
       fx_event_from_type,
       fx_event_from_shipment_type,
       fx_event_to,
       fx_event_to_type,
       fx_event_to_shipment_type,
       is_fx_any_day_basis,
       fx_conversion_method,
       version,
       is_active,
       internal_contract_ref_no,
       dbd_id)
      select ul.pffxdul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pffxd_id,
             ul.fx_rate_type,
             ul.fixed_fx_rate,
             ul.currency_pair_instrument,
             ul.price_source_id,
             ul.off_day_price,
             ul.fx_period_from_date,
             ul.fx_period_to_date,
             ul.fx_month,
             ul.fx_year,
             ul.fx_date,
             ul.fx_event_from,
             ul.fx_event_period_type,
             ul.fx_event_from_type,
             ul.fx_event_from_shipment_type,
             ul.fx_event_to,
             ul.fx_event_to_type,
             ul.fx_event_to_shipment_type,
             ul.is_fx_any_day_basis,
             ul.fx_conversion_method,
             ul.version,
             ul.is_active,
             ul.internal_contract_ref_no,
             pc_dbd_id
        from pffxdul_phy_formula_fx_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pffxdul_phy_formula_fx_dtl_ul');
  
    insert into pfqppul_phy_formula_qp_prc_ul
      (pfqppul_id,
       internal_action_ref_no,
       entry_type,
       pfqpp_id,
       ppfh_id,
       qp_pricing_period_type,
       qp_period_from_date,
       qp_period_to_date,
       qp_month,
       qp_year,
       qp_date,
       qp_event_from,
       qp_event_period_type,
       qp_event_from_type,
       qp_event_from_shipment_type,
       qp_event_to,
       qp_event_to_type,
       qp_event_to_shipment_type,
       is_qp_any_day_basis,
       qty_to_be_priced,
       qp_pricing_type,
       qp_optionality,
       version,
       is_active,
       event_name,
       no_of_event_months,
       is_spot_pricing,
       dbd_id)
      select ul.pfqppul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pfqpp_id,
             ul.ppfh_id,
             ul.qp_pricing_period_type,
             ul.qp_period_from_date,
             ul.qp_period_to_date,
             ul.qp_month,
             ul.qp_year,
             ul.qp_date,
             ul.qp_event_from,
             ul.qp_event_period_type,
             ul.qp_event_from_type,
             ul.qp_event_from_shipment_type,
             ul.qp_event_to,
             ul.qp_event_to_type,
             ul.qp_event_to_shipment_type,
             ul.is_qp_any_day_basis,
             ul.qty_to_be_priced,
             ul.qp_pricing_type,
             ul.qp_optionality,
             ul.version,
             ul.is_active,
             ul.event_name,
             ul.no_of_event_months,
             ul.is_spot_pricing,
             pc_dbd_id
        from pfqppul_phy_formula_qp_prc_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pfqppul_phy_formula_qp_prc_ul');
  
    insert into ppfdul_phy_price_frmula_dtl_ul
      (ppfdul_id,
       internal_action_ref_no,
       entry_type,
       ppfd_id,
       ppfh_id,
       instrument_id,
       price_source_id,
       price_point_id,
       available_price_type_id,
       value_date_type,
       value_date,
       value_month,
       value_year,
       off_day_price,
       basis,
       basis_price_unit_id,
       version,
       is_active,
       dbd_id)
      select ul.ppfdul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.ppfd_id,
             ul.ppfh_id,
             ul.instrument_id,
             ul.price_source_id,
             ul.price_point_id,
             ul.available_price_type_id,
             ul.value_date_type,
             ul.value_date,
             ul.value_month,
             ul.value_year,
             ul.off_day_price,
             ul.basis,
             ul.basis_price_unit_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from ppfdul_phy_price_frmula_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:ppfdul_phy_price_frmula_dtl_ul');
  
    insert into ppfhul_phy_price_frmla_hdr_ul
      (ppfhul_id,
       internal_action_ref_no,
       entry_type,
       ppfh_id,
       pcbpd_id,
       formula_name,
       formula_id,
       formula_description,
       internal_formula_desc,
       version,
       is_active,
       price_unit_id,
       dbd_id)
      select ul.ppfhul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.ppfh_id,
             ul.pcbpd_id,
             ul.formula_name,
             ul.formula_id,
             ul.formula_description,
             ul.internal_formula_desc,
             ul.version,
             ul.is_active,
             ul.price_unit_id,
             pc_dbd_id
        from ppfhul_phy_price_frmla_hdr_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:ppfhul_phy_price_frmla_hdr_ul');
  
    insert into ciqsl_contract_itm_qty_sts_log
      (ciqs_id,
       internal_action_ref_no,
       entry_type,
       internal_contract_item_ref_no,
       total_qty_delta,
       item_qty_unit_id,
       open_qty_delta,
       gmr_qty_delta,
       title_transferred_qty_delta,
       price_fixed_qty_delta,
       allocated_qty_delta,
       prov_invoiced_qty_delta,
       final_invoiced_qty_delta,
       advance_payment_qty_delta,
       fulfilled_qty_delta,
       shipped_qty_delta,
       fin_swap_invoice_qty_delta,
       unallocated_qty_delta,
       version,
       is_active,
       dbd_id)
      select ul.ciqs_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_contract_item_ref_no,
             ul.total_qty_delta,
             ul.item_qty_unit_id,
             ul.open_qty_delta,
             ul.gmr_qty_delta,
             ul.title_transferred_qty_delta,
             ul.price_fixed_qty_delta,
             ul.allocated_qty_delta,
             ul.prov_invoiced_qty_delta,
             ul.final_invoiced_qty_delta,
             ul.advance_payment_qty_delta,
             ul.fulfilled_qty_delta,
             ul.shipped_qty_delta,
             ul.fin_swap_invoice_qty_delta,
             ul.unallocated_qty_delta,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from ciqsl_contract_itm_qty_sts_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:ciqsl_contract_itm_qty_sts_log');
  
    insert into ciqsl_contract_itm_qty_sts_log
      (ciqs_id,
       internal_action_ref_no,
       entry_type,
       internal_contract_item_ref_no,
       total_qty_delta,
       item_qty_unit_id,
       open_qty_delta,
       gmr_qty_delta,
       title_transferred_qty_delta,
       price_fixed_qty_delta,
       allocated_qty_delta,
       prov_invoiced_qty_delta,
       final_invoiced_qty_delta,
       advance_payment_qty_delta,
       fulfilled_qty_delta,
       shipped_qty_delta,
       fin_swap_invoice_qty_delta,
       unallocated_qty_delta,
       version,
       is_active,
       dbd_id)
      select ul.ciqs_id,
             ul.pciul_internal_action_ref_no,
             ul.entry_type,
             ul.internal_contract_item_ref_no,
             ul.total_qty_delta,
             ul.item_qty_unit_id,
             ul.open_qty_delta,
             ul.gmr_qty_delta,
             ul.title_transferred_qty_delta,
             ul.price_fixed_qty_delta,
             ul.allocated_qty_delta,
             ul.prov_invoiced_qty_delta,
             ul.final_invoiced_qty_delta,
             ul.advance_payment_qty_delta,
             ul.fulfilled_qty_delta,
             ul.shipped_qty_delta,
             ul.fin_swap_invoice_qty_delta,
             ul.unallocated_qty_delta,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from (select pciul.internal_action_ref_no pciul_internal_action_ref_no,
                     ciqs.*
                from ciqsl_contract_itm_qty_sts_log@eka_appdb ciqs,
                     (select pci.internal_action_ref_no,
                             pci.internal_contract_item_ref_no
                        from pciul_phy_contract_item_ul@eka_appdb pci
                       where pci.entry_type = 'Insert') pciul
               where ciqs.internal_action_ref_no is null
                 and ciqs.entry_type = 'Insert'
                 and ciqs.internal_contract_item_ref_no =
                     pciul.internal_contract_item_ref_no) ul,
             eod_eom_axsdata@eka_appdb axs
       where ul.pciul_internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:ciqsl_contract_itm_qty_sts_log');
  
    insert into diqsl_delivery_itm_qty_sts_log
      (diqs_id,
       internal_action_ref_no,
       entry_type,
       pcdi_id,
       total_qty_delta,
       item_qty_unit_id,
       open_qty_delta,
       gmr_qty_delta,
       title_transferred_qty_delta,
       price_fixed_qty_delta,
       allocated_qty_delta,
       prov_invoiced_qty_delta,
       final_invoiced_qty_delta,
       advance_payment_qty_delta,
       fulfilled_qty_delta,
       shipped_qty_delta,
       fin_swap_invoice_qty_delta,
       unallocated_qty_delta,
       version,
       is_active,
       called_off_qty_delta,
       dbd_id)
      select ul.diqs_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcdi_id,
             ul.total_qty_delta,
             ul.item_qty_unit_id,
             ul.open_qty_delta,
             ul.gmr_qty_delta,
             ul.title_transferred_qty_delta,
             ul.price_fixed_qty_delta,
             ul.allocated_qty_delta,
             ul.prov_invoiced_qty_delta,
             ul.final_invoiced_qty_delta,
             ul.advance_payment_qty_delta,
             ul.fulfilled_qty_delta,
             ul.shipped_qty_delta,
             ul.fin_swap_invoice_qty_delta,
             ul.unallocated_qty_delta,
             ul.version,
             ul.is_active,
             ul.called_off_qty_delta,
             pc_dbd_id
        from diqsl_delivery_itm_qty_sts_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:diqsl_delivery_itm_qty_sts_log');
  
    insert into cqsl_contract_qty_status_log
      (cqs_id,
       internal_action_ref_no,
       entry_type,
       internal_contract_ref_no,
       total_qty_delta,
       item_qty_unit_id,
       open_qty_delta,
       gmr_qty_delta,
       title_transferred_qty_delta,
       price_fixed_qty_delta,
       allocated_qty_delta,
       prov_invoiced_qty_delta,
       final_invoiced_qty_delta,
       advance_payment_qty_delta,
       fulfilled_qty_delta,
       shipped_qty_delta,
       fin_swap_invoice_qty_delta,
       unallocated_qty_delta,
       version,
       is_active,
       called_off_qty_delta,
       dbd_id)
      select ul.cqs_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_contract_ref_no,
             ul.total_qty_delta,
             ul.item_qty_unit_id,
             ul.open_qty_delta,
             ul.gmr_qty_delta,
             ul.title_transferred_qty_delta,
             ul.price_fixed_qty_delta,
             ul.allocated_qty_delta,
             ul.prov_invoiced_qty_delta,
             ul.final_invoiced_qty_delta,
             ul.advance_payment_qty_delta,
             ul.fulfilled_qty_delta,
             ul.shipped_qty_delta,
             ul.fin_swap_invoice_qty_delta,
             ul.unallocated_qty_delta,
             ul.version,
             ul.is_active,
             ul.called_off_qty_delta,
             pc_dbd_id
        from cqsl_contract_qty_status_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:cqsl_contract_qty_status_log');
  
    insert into grdl_goods_record_detail_log
      (internal_grd_ref_no,
       internal_action_ref_no,
       entry_type,
       internal_gmr_ref_no,
       product_id,
       is_afloat,
       status,
       qty_delta,
       qty_unit_id,
       gross_weight_delta,
       tare_weight_delta,
       internal_contract_item_ref_no,
       int_alloc_group_id,
       packing_size_id,
       container_no,
       seal_no,
       mark_no,
       warehouse_ref_no,
       no_of_units_delta,
       quality_id,
       warehouse_profile_id,
       shed_id,
       origin_id,
       crop_year_id,
       parent_id,
       is_released_shipped,
       release_shipped_no_units_delta,
       is_write_off,
       write_off_no_of_units_delta,
       is_deleted,
       is_moved_out,
       moved_out_no_of_units_delta,
       total_no_of_units_delta,
       total_qty_delta,
       moved_out_qty_delta,
       release_shipped_qty_delta,
       write_off_qty_delta,
       title_transfer_out_qty_delta,
       title_transfr_out_no_unt_delta,
       warehouse_receipt_no,
       warehouse_receipt_date,
       container_size,
       remarks,
       is_added_to_pool,
       loading_date,
       loading_country_id,
       loading_port_id,
       is_entire_item_loaded,
       is_weight_final,
       bl_number,
       bl_date,
       parent_internal_grd_ref_no,
       discharged_qty_delta,
       is_voyage_stock,
       allocated_qty_delta,
       internal_stock_ref_no,
       landed_no_of_units_delta,
       landed_net_qty_delta,
       landed_gross_qty_delta,
       shipped_no_of_units_delta,
       shipped_net_qty_delta,
       shipped_gross_qty_delta,
       current_qty_delta,
       stock_status,
       product_specs,
       source_type,
       source_int_stock_ref_no,
       source_int_purchase_ref_no,
       source_int_pool_ref_no,
       is_fulfilled,
       inventory_status,
       truck_rail_number,
       truck_rail_type,
       packing_type_id,
       handled_as,
       allocated_no_of_units_delta,
       current_no_of_units_delta,
       stock_condition,
       gravity_type_id,
       gravity_delta,
       density_mass_qty_unit_id,
       density_volume_qty_unit_id,
       gravity_type,
       customs_id,
       tax_id,
       duty_id,
       customer_seal_no,
       brand,
       no_of_containers_delta,
       no_of_bags_delta,
       no_of_pieces_delta,
       rail_car_no,
       sdcts_id,
       partnership_type,
       is_trans_ship,
       is_mark_for_tolling,
       tolling_qty,
       tolling_stock_type,
       element_id,
       expected_sales_ccy,
       profit_center_id,
       strategy_id,
       is_warrant,
       warrant_no,
       pcdi_id,
       supp_contract_item_ref_no,
       supplier_pcdi_id,
       payable_returnable_type,
       carry_over_qty,
       supp_internal_gmr_ref_no,
       dbd_id,
       process)
      select ul.internal_grd_ref_no,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.product_id,
             ul.is_afloat,
             ul.status,
             ul.qty_delta,
             ul.qty_unit_id,
             ul.gross_weight_delta,
             ul.tare_weight_delta,
             ul.internal_contract_item_ref_no,
             ul.int_alloc_group_id,
             ul.packing_size_id,
             ul.container_no,
             ul.seal_no,
             ul.mark_no,
             ul.warehouse_ref_no,
             ul.no_of_units_delta,
             ul.quality_id,
             ul.warehouse_profile_id,
             ul.shed_id,
             ul.origin_id,
             ul.crop_year_id,
             ul.parent_id,
             ul.is_released_shipped,
             ul.release_shipped_no_units_delta,
             ul.is_write_off,
             ul.write_off_no_of_units_delta,
             ul.is_deleted,
             ul.is_moved_out,
             ul.moved_out_no_of_units_delta,
             ul.total_no_of_units_delta,
             ul.total_qty_delta,
             ul.moved_out_qty_delta,
             ul.release_shipped_qty_delta,
             ul.write_off_qty_delta,
             ul.title_transfer_out_qty_delta,
             ul.title_transfr_out_no_unt_delta,
             ul.warehouse_receipt_no,
             ul.warehouse_receipt_date,
             ul.container_size,
             ul.remarks,
             ul.is_added_to_pool,
             ul.loading_date,
             ul.loading_country_id,
             ul.loading_port_id,
             ul.is_entire_item_loaded,
             ul.is_weight_final,
             ul.bl_number,
             ul.bl_date,
             ul.parent_internal_grd_ref_no,
             ul.discharged_qty_delta,
             ul.is_voyage_stock,
             ul.allocated_qty_delta,
             ul.internal_stock_ref_no,
             ul.landed_no_of_units_delta,
             ul.landed_net_qty_delta,
             ul.landed_gross_qty_delta,
             ul.shipped_no_of_units_delta,
             ul.shipped_net_qty_delta,
             ul.shipped_gross_qty_delta,
             ul.current_qty_delta,
             ul.stock_status,
             ul.product_specs,
             ul.source_type,
             ul.source_int_stock_ref_no,
             ul.source_int_purchase_ref_no,
             ul.source_int_pool_ref_no,
             ul.is_fulfilled,
             ul.inventory_status,
             ul.truck_rail_number,
             ul.truck_rail_type,
             ul.packing_type_id,
             ul.handled_as,
             ul.allocated_no_of_units_delta,
             ul.current_no_of_units_delta,
             ul.stock_condition,
             ul.gravity_type_id,
             ul.gravity_delta,
             ul.density_mass_qty_unit_id,
             ul.density_volume_qty_unit_id,
             ul.gravity_type,
             ul.customs_id,
             ul.tax_id,
             ul.duty_id,
             ul.customer_seal_no,
             ul.brand,
             ul.no_of_containers_delta,
             ul.no_of_bags_delta,
             ul.no_of_pieces_delta,
             ul.rail_car_no,
             ul.sdcts_id,
             ul.partnership_type,
             ul.is_trans_ship,
             ul.is_mark_for_tolling,
             ul.tolling_qty,
             ul.tolling_stock_type,
             ul.element_id,
             ul.expected_sales_ccy,
             ul.profit_center_id,
             ul.strategy_id,
             ul.is_warrant,
             ul.warrant_no,
             ul.pcdi_id,
             ul.supp_contract_item_ref_no,
             ul.supplier_pcdi_id,
             ul.payable_returnable_type,
             ul.carry_over_qty,
             ul.supp_internal_gmr_ref_no,
             pc_dbd_id,
             pc_process
        from grdl_goods_record_detail_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process
         and ul.cot_int_action_ref_no is null;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:grdl_goods_record_detail_log');
  
    insert into grdl_goods_record_detail_log
      (internal_grd_ref_no,
       internal_action_ref_no,
       entry_type,
       internal_gmr_ref_no,
       product_id,
       is_afloat,
       status,
       qty_delta,
       qty_unit_id,
       gross_weight_delta,
       tare_weight_delta,
       internal_contract_item_ref_no,
       int_alloc_group_id,
       packing_size_id,
       container_no,
       seal_no,
       mark_no,
       warehouse_ref_no,
       no_of_units_delta,
       quality_id,
       warehouse_profile_id,
       shed_id,
       origin_id,
       crop_year_id,
       parent_id,
       is_released_shipped,
       release_shipped_no_units_delta,
       is_write_off,
       write_off_no_of_units_delta,
       is_deleted,
       is_moved_out,
       moved_out_no_of_units_delta,
       total_no_of_units_delta,
       total_qty_delta,
       moved_out_qty_delta,
       release_shipped_qty_delta,
       write_off_qty_delta,
       title_transfer_out_qty_delta,
       title_transfr_out_no_unt_delta,
       warehouse_receipt_no,
       warehouse_receipt_date,
       container_size,
       remarks,
       is_added_to_pool,
       loading_date,
       loading_country_id,
       loading_port_id,
       is_entire_item_loaded,
       is_weight_final,
       bl_number,
       bl_date,
       parent_internal_grd_ref_no,
       discharged_qty_delta,
       is_voyage_stock,
       allocated_qty_delta,
       internal_stock_ref_no,
       landed_no_of_units_delta,
       landed_net_qty_delta,
       landed_gross_qty_delta,
       shipped_no_of_units_delta,
       shipped_net_qty_delta,
       shipped_gross_qty_delta,
       current_qty_delta,
       stock_status,
       product_specs,
       source_type,
       source_int_stock_ref_no,
       source_int_purchase_ref_no,
       source_int_pool_ref_no,
       is_fulfilled,
       inventory_status,
       truck_rail_number,
       truck_rail_type,
       packing_type_id,
       handled_as,
       allocated_no_of_units_delta,
       current_no_of_units_delta,
       stock_condition,
       gravity_type_id,
       gravity_delta,
       density_mass_qty_unit_id,
       density_volume_qty_unit_id,
       gravity_type,
       customs_id,
       tax_id,
       duty_id,
       customer_seal_no,
       brand,
       no_of_containers_delta,
       no_of_bags_delta,
       no_of_pieces_delta,
       rail_car_no,
       sdcts_id,
       partnership_type,
       is_trans_ship,
       is_mark_for_tolling,
       tolling_qty,
       tolling_stock_type,
       element_id,
       expected_sales_ccy,
       profit_center_id,
       strategy_id,
       is_warrant,
       warrant_no,
       pcdi_id,
       supp_contract_item_ref_no,
       supplier_pcdi_id,
       payable_returnable_type,
       carry_over_qty,
       supp_internal_gmr_ref_no,
       dbd_id,
       process)
      select ul.internal_grd_ref_no,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.product_id,
             ul.is_afloat,
             ul.status,
             ul.qty_delta,
             ul.qty_unit_id,
             ul.gross_weight_delta,
             ul.tare_weight_delta,
             ul.internal_contract_item_ref_no,
             ul.int_alloc_group_id,
             ul.packing_size_id,
             ul.container_no,
             ul.seal_no,
             ul.mark_no,
             ul.warehouse_ref_no,
             ul.no_of_units_delta,
             ul.quality_id,
             ul.warehouse_profile_id,
             ul.shed_id,
             ul.origin_id,
             ul.crop_year_id,
             ul.parent_id,
             ul.is_released_shipped,
             ul.release_shipped_no_units_delta,
             ul.is_write_off,
             ul.write_off_no_of_units_delta,
             ul.is_deleted,
             ul.is_moved_out,
             ul.moved_out_no_of_units_delta,
             ul.total_no_of_units_delta,
             ul.total_qty_delta,
             ul.moved_out_qty_delta,
             ul.release_shipped_qty_delta,
             ul.write_off_qty_delta,
             ul.title_transfer_out_qty_delta,
             ul.title_transfr_out_no_unt_delta,
             ul.warehouse_receipt_no,
             ul.warehouse_receipt_date,
             ul.container_size,
             ul.remarks,
             ul.is_added_to_pool,
             ul.loading_date,
             ul.loading_country_id,
             ul.loading_port_id,
             ul.is_entire_item_loaded,
             ul.is_weight_final,
             ul.bl_number,
             ul.bl_date,
             ul.parent_internal_grd_ref_no,
             ul.discharged_qty_delta,
             ul.is_voyage_stock,
             ul.allocated_qty_delta,
             ul.internal_stock_ref_no,
             ul.landed_no_of_units_delta,
             ul.landed_net_qty_delta,
             ul.landed_gross_qty_delta,
             ul.shipped_no_of_units_delta,
             ul.shipped_net_qty_delta,
             ul.shipped_gross_qty_delta,
             ul.current_qty_delta,
             ul.stock_status,
             ul.product_specs,
             ul.source_type,
             ul.source_int_stock_ref_no,
             ul.source_int_purchase_ref_no,
             ul.source_int_pool_ref_no,
             ul.is_fulfilled,
             ul.inventory_status,
             ul.truck_rail_number,
             ul.truck_rail_type,
             ul.packing_type_id,
             ul.handled_as,
             ul.allocated_no_of_units_delta,
             ul.current_no_of_units_delta,
             ul.stock_condition,
             ul.gravity_type_id,
             ul.gravity_delta,
             ul.density_mass_qty_unit_id,
             ul.density_volume_qty_unit_id,
             ul.gravity_type,
             ul.customs_id,
             ul.tax_id,
             ul.duty_id,
             ul.customer_seal_no,
             ul.brand,
             ul.no_of_containers_delta,
             ul.no_of_bags_delta,
             ul.no_of_pieces_delta,
             ul.rail_car_no,
             ul.sdcts_id,
             ul.partnership_type,
             ul.is_trans_ship,
             ul.is_mark_for_tolling,
             ul.tolling_qty,
             ul.tolling_stock_type,
             ul.element_id,
             ul.expected_sales_ccy,
             ul.profit_center_id,
             ul.strategy_id,
             ul.is_warrant,
             ul.warrant_no,
             ul.pcdi_id,
             ul.supp_contract_item_ref_no,
             ul.supplier_pcdi_id,
             ul.payable_returnable_type,
             ul.carry_over_qty,
             ul.supp_internal_gmr_ref_no,
             pc_dbd_id,
             pc_process
        from grdl_goods_record_detail_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.cot_int_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process
         and ul.cot_int_action_ref_no is not null;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:grdl_goods_record_detail_log');
  
    insert into vdul_voyage_detail_ul
      (internal_gmr_ref_no,
       internal_action_ref_no,
       action_no,
       entry_type,
       shipping_line_profile_id,
       shipping_agent_profile_id,
       loading_port_id,
       discharge_port_id,
       trans_shipment_port_id,
       trans_shipment_country_id,
       destination_city_id,
       destination_country_id,
       origination_city_id,
       origination_country_id,
       booking_ref_no,
       voyage_ref_no,
       etd,
       eta,
       cut_off_date,
       voyage_quantity,
       voyage_qty_type,
       voyage_qty_unit_id,
       vessel_voyage_name,
       vessel_id,
       status,
       voyage_number,
       loading_date,
       shippers_ref_no,
       shipper_address,
       loading_country_id,
       loading_state_id,
       loading_city_id,
       trans_shipment_state_id,
       trans_shipment_city_id,
       discharge_country_id,
       discharge_state_id,
       discharge_city_id,
       place_of_receipt_country_id,
       place_of_receipt_state_id,
       place_of_receipt_city_id,
       place_of_delivery_country_id,
       place_of_delivery_state_id,
       place_of_delivery_city_id,
       notes,
       shippers_instructions,
       special_instructions,
       carriers_agents_endorsements,
       comments,
       agents_data_code,
       airport_of_destination_code,
       airport_of_departure_code,
       declared_value_customs,
       declared_value_customs_cur_id,
       no_of_pieces,
       nature_of_goods,
       dimensions,
       handling_instructions,
       dbd_id)
      select ul.internal_gmr_ref_no,
             ul.internal_action_ref_no,
             ul.action_no,
             ul.entry_type,
             ul.shipping_line_profile_id,
             ul.shipping_agent_profile_id,
             ul.loading_port_id,
             ul.discharge_port_id,
             ul.trans_shipment_port_id,
             ul.trans_shipment_country_id,
             ul.destination_city_id,
             ul.destination_country_id,
             ul.origination_city_id,
             ul.origination_country_id,
             ul.booking_ref_no,
             ul.voyage_ref_no,
             ul.etd,
             ul.eta,
             ul.cut_off_date,
             ul.voyage_quantity,
             ul.voyage_qty_type,
             ul.voyage_qty_unit_id,
             ul.vessel_voyage_name,
             ul.vessel_id,
             ul.status,
             ul.voyage_number,
             ul.loading_date,
             ul.shippers_ref_no,
             ul.shipper_address,
             ul.loading_country_id,
             ul.loading_state_id,
             ul.loading_city_id,
             ul.trans_shipment_state_id,
             ul.trans_shipment_city_id,
             ul.discharge_country_id,
             ul.discharge_state_id,
             ul.discharge_city_id,
             ul.place_of_receipt_country_id,
             ul.place_of_receipt_state_id,
             ul.place_of_receipt_city_id,
             ul.place_of_delivery_country_id,
             ul.place_of_delivery_state_id,
             ul.place_of_delivery_city_id,
             ul.notes,
             ul.shippers_instructions,
             ul.special_instructions,
             ul.carriers_agents_endorsements,
             ul.comments,
             ul.agents_data_code,
             ul.airport_of_destination_code,
             ul.airport_of_departure_code,
             ul.declared_value_customs,
             ul.declared_value_customs_cur_id,
             ul.no_of_pieces,
             ul.nature_of_goods,
             ul.dimensions,
             ul.handling_instructions,
             pc_dbd_id
        from vdul_voyage_detail_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb       axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:vdul_voyage_detail_ul');
  
    insert into pcpchul_payble_contnt_headr_ul
      (pcpchul_id,
       internal_action_ref_no,
       entry_type,
       pcpch_id,
       internal_contract_ref_no,
       range_type,
       range_unit_id,
       element_id,
       slab_tier,
       version,
       is_active,
       payable_type,
       dbd_id)
      select ul.pcpchul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcpch_id,
             ul.internal_contract_ref_no,
             ul.range_type,
             ul.range_unit_id,
             ul.element_id,
             ul.slab_tier,
             ul.version,
             ul.is_active,
             ul.payable_type,
             pc_dbd_id
        from pcpchul_payble_contnt_headr_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcpchul_payble_contnt_headr_ul');
  
    insert into pqdul_payable_quality_dtl_ul
      (pqdul_id,
       internal_action_ref_no,
       entry_type,
       pqd_id,
       pcpch_id,
       pcpq_id,
       version,
       is_active,
       quality_name,
       dbd_id)
      select ul.pqdul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pqd_id,
             ul.pcpch_id,
             ul.pcpq_id,
             ul.version,
             ul.is_active,
             ul.quality_name,
             pc_dbd_id
        from pqdul_payable_quality_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pqdul_payable_quality_dtl_ul');
  
    insert into pcepcul_elem_payble_content_ul
      (pcepcul_id,
       internal_action_ref_no,
       entry_type,
       pcepc_id,
       range_min_op,
       range_min_value,
       range_max_op,
       range_max_value,
       payable_formula_id,
       payable_content_value,
       payable_content_unit_id,
       assay_deduction,
       assay_deduction_unit_id,
       include_ref_charges,
       refining_charge_value,
       refining_charge_unit_id,
       version,
       is_active,
       pcpch_id,
       position,
       dbd_id)
      select ul.pcepcul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcepc_id,
             ul.range_min_op,
             ul.range_min_value,
             ul.range_max_op,
             range_max_value,
             ul.payable_formula_id,
             ul.payable_content_value,
             ul.payable_content_unit_id,
             ul.assay_deduction,
             ul.assay_deduction_unit_id,
             ul.include_ref_charges,
             ul.refining_charge_value,
             ul.refining_charge_unit_id,
             ul.version,
             ul.is_active,
             ul.pcpch_id,
             ul.position,
             pc_dbd_id
        from pcepcul_elem_payble_content_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcepcul_elem_payble_content_ul');
  
    insert into pcthul_treatment_header_ul
      (pcthul_id,
       internal_action_ref_no,
       entry_type,
       pcth_id,
       internal_contract_ref_no,
       range_type,
       range_unit_id,
       price_unit_id,
       slab_tier,
       version,
       is_active,
       dbd_id)
      select ul.pcthul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcth_id,
             ul.internal_contract_ref_no,
             ul.range_type,
             ul.range_unit_id,
             ul.price_unit_id,
             ul.slab_tier,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcthul_treatment_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcthul_treatment_header_ul');
  
    insert into tedul_treatment_element_dtl_ul
      (tedul_id,
       internal_action_ref_no,
       entry_type,
       ted_id,
       pcth_id,
       element_id,
       version,
       is_active,
       element_name,
       dbd_id)
      select ul.tedul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.ted_id,
             ul.pcth_id,
             ul.element_id,
             ul.version,
             ul.is_active,
             ul.element_name,
             pc_dbd_id
        from tedul_treatment_element_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:tedul_treatment_element_dtl_ul');
  
    insert into tqdul_treatment_quality_dtl_ul
      (tqdul_id,
       internal_action_ref_no,
       entry_type,
       tqd_id,
       pcth_id,
       pcpq_id,
       version,
       is_active,
       quality_name,
       dbd_id)
      select ul.tqdul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.tqd_id,
             ul.pcth_id,
             ul.pcpq_id,
             ul.version,
             ul.is_active,
             ul.quality_name,
             pc_dbd_id
        from tqdul_treatment_quality_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:tqdul_treatment_quality_dtl_ul');
  
    insert into pcetcul_elem_treatmnt_chrg_ul
      (pcetcul_id,
       internal_action_ref_no,
       entry_type,
       pcetc_id,
       pcth_id,
       range_min_op,
       range_min_value,
       range_max_op,
       range_max_value,
       position,
       treatment_charge,
       treatment_charge_unit_id,
       weight_type,
       charge_basis,
       esc_desc_value,
       esc_desc_unit_id,
       version,
       is_active,
       charge_type,
       dbd_id)
      select ul.pcetcul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcetc_id,
             ul.pcth_id,
             ul.range_min_op,
             ul.range_min_value,
             ul.range_max_op,
             ul.range_max_value,
             ul.position,
             ul.treatment_charge,
             ul.treatment_charge_unit_id,
             ul.weight_type,
             ul.charge_basis,
             ul.esc_desc_value,
             ul.esc_desc_unit_id,
             ul.version,
             ul.is_active,
             ul.charge_type,
             pc_dbd_id
        from pcetcul_elem_treatmnt_chrg_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcetcul_elem_treatmnt_chrg_ul');
  
    insert into pcarul_assaying_rules_ul
      (pcarul_id,
       internal_action_ref_no,
       entry_type,
       pcar_id,
       internal_contract_ref_no,
       element_id,
       final_assay_basis_id,
       comparision,
       split_limit_basis,
       split_limit,
       split_limit_unit_id,
       version,
       is_active,
       element_name,
       quality_id,
       dbd_id)
      select ul.pcarul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcar_id,
             ul.internal_contract_ref_no,
             ul.element_id,
             ul.final_assay_basis_id,
             ul.comparision,
             ul.split_limit_basis,
             ul.split_limit,
             ul.split_limit_unit_id,
             ul.version,
             ul.is_active,
             ul.element_name,
             ul.quality_id,
             pc_dbd_id
        from pcarul_assaying_rules_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb          axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcarul_assaying_rules_ul');
  
    insert into pcaeslul_assay_elm_splt_lmt_ul
      (pcaeslul_id,
       internal_action_ref_no,
       entry_type,
       pcaesl_id,
       pcar_id,
       assay_min_op,
       assay_min_value,
       assay_max_op,
       assay_max_value,
       applicable_value,
       version,
       is_active,
       dbd_id)
      select ul.pcaeslul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcaesl_id,
             ul.pcar_id,
             ul.assay_min_op,
             ul.assay_min_value,
             ul.assay_max_op,
             ul.assay_max_value,
             ul.applicable_value,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcaeslul_assay_elm_splt_lmt_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcaeslul_assay_elm_splt_lmt_ul');
  
    insert into arqdul_assay_quality_dtl_ul
      (arqdul_id,
       internal_action_ref_no,
       entry_type,
       arqd_id,
       pcar_id,
       pcpq_id,
       version,
       is_active,
       quality_name,
       dbd_id)
      select ul.arqdul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.arqd_id,
             ul.pcar_id,
             ul.pcpq_id,
             ul.version,
             ul.is_active,
             ul.quality_name,
             pc_dbd_id
        from arqdul_assay_quality_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb             axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:arqdul_assay_quality_dtl_ul');
  
    insert into pcaphul_attr_penalty_header_ul
      (pcaphul_id,
       internal_action_ref_no,
       entry_type,
       pcaph_id,
       internal_contract_ref_no,
       attribute_type,
       range_unit_id,
       slab_tier,
       version,
       is_active,
       dbd_id)
      select ul.pcaphul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcaph_id,
             ul.internal_contract_ref_no,
             ul.attribute_type,
             ul.range_unit_id,
             ul.slab_tier,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcaphul_attr_penalty_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcaphul_attr_penalty_header_ul');
  
    insert into pcapul_attribute_penalty_ul
      (pcapul_id,
       internal_action_ref_no,
       entry_type,
       pcap_id,
       range_min_op,
       range_min_value,
       range_max_op,
       range_max_value,
       penalty_charge_type,
       penalty_basis,
       penalty_amount,
       penalty_unit_id,
       penalty_weight_type,
       per_increase_value,
       per_increase_unit_id,
       deducted_payable_element,
       deducted_payable_value,
       deducted_payable_unit_id,
       charge_basis,
       version,
       is_active,
       pcaph_id,
       position,
       dbd_id)
      select ul.pcapul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcap_id,
             ul.range_min_op,
             ul.range_min_value,
             ul.range_max_op,
             ul.range_max_value,
             ul.penalty_charge_type,
             ul.penalty_basis,
             ul.penalty_amount,
             ul.penalty_unit_id,
             ul.penalty_weight_type,
             ul.per_increase_value,
             ul.per_increase_unit_id,
             ul.deducted_payable_element,
             ul.deducted_payable_value,
             ul.deducted_payable_unit_id,
             ul.charge_basis,
             ul.version,
             ul.is_active,
             ul.pcaph_id,
             ul.position,
             pc_dbd_id
        from pcapul_attribute_penalty_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb             axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcapul_attribute_penalty_ul');
  
    insert into pqdul_penalty_quality_dtl_ul
      (pqdul_id,
       internal_action_ref_no,
       entry_type,
       pqd_id,
       pcaph_id,
       pcpq_id,
       version,
       is_active,
       dbd_id)
      select ul.pqdul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pqd_id,
             ul.pcaph_id,
             ul.pcpq_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pqdul_penalty_quality_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pqdul_penalty_quality_dtl_ul');
  
    insert into padul_penalty_attribute_dtl_ul
      (padul_id,
       internal_action_ref_no,
       entry_type,
       pad_id,
       pcaph_id,
       element_id,
       pqpa_id,
       version,
       is_active,
       dbd_id)
      select ul.padul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pad_id,
             ul.pcaph_id,
             ul.element_id,
             ul.pqpa_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from padul_penalty_attribute_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:padul_penalty_attribute_dtl_ul');
  
    insert into pcrhul_refining_header_ul
      (pcrhul_id,
       internal_action_ref_no,
       entry_type,
       pcrh_id,
       internal_contract_ref_no,
       range_type,
       range_unit_id,
       price_unit_id,
       slab_tier,
       version,
       is_active,
       dbd_id)
      select ul.pcrhul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcrh_id,
             ul.internal_contract_ref_no,
             ul.range_type,
             ul.range_unit_id,
             ul.price_unit_id,
             ul.slab_tier,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcrhul_refining_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb           axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcrhul_refining_header_ul');
  
    insert into rqdul_refining_quality_dtl_ul
      (rqdul_id,
       internal_action_ref_no,
       entry_type,
       rqd_id,
       pcrh_id,
       pcpq_id,
       version,
       is_active,
       quality_name,
       dbd_id)
      select ul.rqdul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.rqd_id,
             ul.pcrh_id,
             ul.pcpq_id,
             ul.version,
             ul.is_active,
             ul.quality_name,
             pc_dbd_id
        from rqdul_refining_quality_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:rqdul_refining_quality_dtl_ul');
  
    insert into redul_refining_element_dtl_ul
      (redul_id,
       internal_action_ref_no,
       entry_type,
       red_id,
       pcrh_id,
       element_id,
       version,
       is_active,
       element_name,
       dbd_id)
      select ul.redul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.red_id,
             ul.pcrh_id,
             ul.element_id,
             ul.version,
             ul.is_active,
             ul.element_name,
             pc_dbd_id
        from redul_refining_element_dtl_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:redul_refining_element_dtl_ul');
  
    insert into pcercul_elem_refing_charge_ul
      (pcercul_id,
       internal_action_ref_no,
       entry_type,
       pcerc_id,
       pcrh_id,
       range_min_op,
       range_min_value,
       range_max_op,
       range_max_value,
       charge_type,
       position,
       refining_charge,
       refining_charge_unit_id,
       weight_type,
       charge_basis,
       esc_desc_value,
       esc_desc_unit_id,
       version,
       is_active,
       dbd_id)
      select ul.pcercul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcerc_id,
             ul.pcrh_id,
             ul.range_min_op,
             ul.range_min_value,
             ul.range_max_op,
             ul.range_max_value,
             ul.charge_type,
             ul.position,
             ul.refining_charge,
             ul.refining_charge_unit_id,
             ul.weight_type,
             ul.charge_basis,
             ul.esc_desc_value,
             ul.esc_desc_unit_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from pcercul_elem_refing_charge_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pcercul_elem_refing_charge_ul');
  
    insert into dithul_di_treatment_header_ul
      (dithul_id,
       internal_action_ref_no,
       entry_type,
       dith_id,
       pcdi_id,
       pcth_id,
       version,
       is_active,
       dbd_id)
      select ul.dithul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.dith_id,
             ul.pcdi_id,
             ul.pcth_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from dithul_di_treatment_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:dithul_di_treatment_header_ul');
  
    insert into dirhul_di_refining_header_ul
      (dirhul_id,
       internal_action_ref_no,
       entry_type,
       dirh_id,
       pcdi_id,
       pcrh_id,
       version,
       is_active,
       dbd_id)
      select ul.dirhul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.dirh_id,
             ul.pcdi_id,
             ul.pcrh_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from dirhul_di_refining_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:dirhul_di_refining_header_ul');
  
    insert into diphul_di_penalty_header_ul
      (diphul_id,
       internal_action_ref_no,
       entry_type,
       diph_id,
       pcdi_id,
       pcaph_id,
       version,
       is_active,
       dbd_id)
      select ul.diphul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.diph_id,
             ul.pcdi_id,
             ul.pcaph_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from diphul_di_penalty_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb             axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:diphul_di_penalty_header_ul');
  
    insert into cipql_ctrt_itm_payable_qty_log
      (cipq_id,
       internal_action_ref_no,
       entry_type,
       internal_contract_item_ref_no,
       element_id,
       payable_qty_delta,
       qty_unit_id,
       version,
       is_active,
       qty_type,
       dbd_id)
      select ul.cipq_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_contract_item_ref_no,
             ul.element_id,
             ul.payable_qty_delta,
             ul.qty_unit_id,
             ul.version,
             ul.is_active,
             ul.qty_type,
             pc_dbd_id
        from cipql_ctrt_itm_payable_qty_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:cipql_ctrt_itm_payable_qty_log');
  
    insert into dipql_del_itm_payble_qty_log
      (dipq_id,
       internal_action_ref_no,
       entry_type,
       pcdi_id,
       element_id,
       payable_qty_delta,
       qty_unit_id,
       price_option_call_off_status,
       version,
       is_active,
       is_price_optionality_present,
       qty_type,
       dbd_id)
      select ul.dipq_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.pcdi_id,
             ul.element_id,
             ul.payable_qty_delta,
             ul.qty_unit_id,
             ul.price_option_call_off_status,
             ul.version,
             ul.is_active,
             ul.is_price_optionality_present,
             ul.qty_type,
             pc_dbd_id
        from dipql_del_itm_payble_qty_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:dipql_del_itm_payble_qty_log');
  
    insert into spql_stock_payable_qty_log
      (spq_id,
       internal_action_ref_no,
       entry_type,
       internal_gmr_ref_no,
       action_no,
       stock_type,
       internal_grd_ref_no,
       internal_dgrd_ref_no,
       element_id,
       payable_qty_delta,
       qty_unit_id,
       version,
       is_active,
       qty_type,
       activity_action_id,
       is_stock_split,
       supplier_id,
       smelter_id,
       in_process_stock_id,
       free_metal_stock_id,
       free_metal_qty,
       assay_content,
       pledge_stock_id,
       gepd_id,
       assay_header_id,
       is_final_assay,
       corporate_id,
       weg_avg_pricing_assay_id,
       weg_avg_invoice_assay_id,
       cot_int_action_ref_no,
       orig_internal_action_ref_no,
       dbd_id,
       process)
      select ul.spq_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.action_no,
             ul.stock_type,
             ul.internal_grd_ref_no,
             ul.internal_dgrd_ref_no,
             ul.element_id,
             ul.payable_qty_delta,
             ul.qty_unit_id,
             ul.version,
             ul.is_active,
             ul.qty_type,
             ul.activity_action_id,
             ul.is_stock_split,
             ul.supplier_id,
             ul.smelter_id,
             null, -- ul.in_process_stock_id,
             ul.free_metal_stock_id,
             ul.free_metal_qty,
             ul.assay_content,
             ul.pledge_stock_id,
             ul.gepd_id,
             ul.assay_header_id,
             ul.is_final_assay,
             ul.corporate_id,
             ul.weg_avg_pricing_assay_id,
             ul.weg_avg_invoice_assay_id,
             null, -- ul.cot_int_action_ref_no,
             null, -- Original internal action ref no, only if toggle case, for reference only
             pc_dbd_id,
             pc_process
        from spql_stock_payable_qty_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and ul.cot_int_action_ref_no is null
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:spql_stock_payable_qty_log');
  
    insert into spql_stock_payable_qty_log
      (spq_id,
       internal_action_ref_no,
       entry_type,
       internal_gmr_ref_no,
       action_no,
       stock_type,
       internal_grd_ref_no,
       internal_dgrd_ref_no,
       element_id,
       payable_qty_delta,
       qty_unit_id,
       version,
       is_active,
       qty_type,
       activity_action_id,
       is_stock_split,
       supplier_id,
       smelter_id,
       in_process_stock_id,
       free_metal_stock_id,
       free_metal_qty,
       assay_content,
       pledge_stock_id,
       gepd_id,
       assay_header_id,
       is_final_assay,
       corporate_id,
       weg_avg_pricing_assay_id,
       weg_avg_invoice_assay_id,
       cot_int_action_ref_no,
       orig_internal_action_ref_no,
       dbd_id,
       process)
      select ul.spq_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.action_no,
             ul.stock_type,
             ul.internal_grd_ref_no,
             ul.internal_dgrd_ref_no,
             ul.element_id,
             ul.payable_qty_delta,
             ul.qty_unit_id,
             ul.version,
             ul.is_active,
             ul.qty_type,
             ul.activity_action_id,
             ul.is_stock_split,
             ul.supplier_id,
             ul.smelter_id,
             null, -- ul.in_process_stock_id,
             ul.free_metal_stock_id,
             ul.free_metal_qty,
             ul.assay_content,
             ul.pledge_stock_id,
             ul.gepd_id,
             ul.assay_header_id,
             ul.is_final_assay,
             ul.corporate_id,
             ul.weg_avg_pricing_assay_id,
             ul.weg_avg_invoice_assay_id,
             ul.cot_int_action_ref_no,
             ul.internal_action_ref_no, -- Original internal action ref no, only if toggle case, for reference only
             pc_dbd_id,
             pc_process
        from spql_stock_payable_qty_log@eka_appdb ul,
             eod_eom_axsdata@eka_appdb            axs
       where ul.cot_int_action_ref_no = axs.internal_action_ref_no
         and ul.cot_int_action_ref_no is not null
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:spql_stock_payable_qty_log');
  
    insert into dipchul_di_payblecon_header_ul
      (dipchul_id,
       internal_action_ref_no,
       entry_type,
       dipch_id,
       pcdi_id,
       pcpch_id,
       version,
       is_active,
       dbd_id)
      select ul.dipchul_id,
             ul.internal_action_ref_no,
             ul.entry_type,
             ul.dipch_id,
             ul.pcdi_id,
             ul.pcpch_id,
             ul.version,
             ul.is_active,
             pc_dbd_id
        from dipchul_di_payblecon_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb                axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:dipchul_di_payblecon_header_ul');
  
    insert into sswh_spe_settle_washout_header
      (sswh_id,
       internal_action_ref_no,
       settlement_qty,
       settlement_qty_unit_id,
       settlement_date,
       purchase_amt,
       sale_amt,
       pay_in_curr_id,
       remarks,
       is_active,
       internal_gmr_ref_no,
       dbd_id,
       activity_ref_no,
       activity_type,
       cancellation_date)
      select sswh_id,
             sswh.internal_action_ref_no,
             settlement_qty,
             settlement_qty_unit_id,
             settlement_date,
             purchase_amt,
             sale_amt,
             pay_in_curr_id,
             remarks,
             is_active,
             internal_gmr_ref_no,
             pc_dbd_id,
             activity_ref_no,
             activity_type,
             cancellation_date
        from sswh_spe_settle_washout_header@eka_appdb sswh,
             eod_eom_axsdata@eka_appdb                axs
       where sswh.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:sswh_spe_settle_washout_header');
  
    insert into sswd_spe_settle_washout_detail
      (sswd_id,
       sswh_id,
       contract_type,
       internal_contract_item_ref_no,
       contract_item_ref_no,
       product_id,
       quality_id,
       price,
       price_unit_id,
       qty,
       qty_unit_id,
       is_active,
       dbd_id,
       price_fixed,
       price_type,
       price_desc)
      select sswd_id,
             sswh_id,
             contract_type,
             internal_contract_item_ref_no,
             contract_item_ref_no,
             product_id,
             quality_id,
             price,
             price_unit_id,
             qty,
             qty_unit_id,
             is_active,
             pc_dbd_id,
             price_fixed,
             price_type,
             price_desc
        from sswd_spe_settle_washout_detail@eka_appdb sswd
       where sswd.sswh_id in
             (select sswh_id
                from sswh_spe_settle_washout_header sswh
               where sswh.dbd_id = pc_dbd_id);
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:sswd_spe_settle_washout_detail');
  
    --- Added Suresh 
    insert into pca_physical_contract_action
      (pca_id,
       internal_contract_ref_no,
       internal_action_ref_no,
       version,
       is_active,
       dbd_id)
      select pca.pca_id,
             pca.internal_contract_ref_no,
             pca.internal_action_ref_no,
             pca.version,
             pca.is_active,
             pc_dbd_id
        from pca_physical_contract_action@eka_appdb pca,
             eod_eom_axsdata@eka_appdb              axs
       where pca.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:pca_physical_contract_action');
  
    insert into cod_call_off_details
      (cod_id,
       contract_ref_no,
       pcdi_id,
       internal_action_ref_no,
       called_off_qty,
       unit_of_measure,
       pcpq_id,
       quality_name,
       inco_term_location,
       incoterm_id,
       internal_contract_item_ref_no,
       version,
       is_active,
       call_off_date,
       dbd_id)
      select cod.cod_id,
             cod.contract_ref_no,
             cod.pcdi_id,
             cod.internal_action_ref_no,
             cod.called_off_qty,
             cod.unit_of_measure,
             cod.pcpq_id,
             cod.quality_name,
             cod.inco_term_location,
             cod.incoterm_id,
             cod.internal_contract_item_ref_no,
             cod.version,
             cod.is_active,
             cod.call_off_date,
             pc_dbd_id
        from cod_call_off_details@eka_appdb cod,
             eod_eom_axsdata@eka_appdb      axs
       where cod.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:cod_call_off_details');
  
    insert into gthul_gmr_treatment_header_ul
      (gthul_id,
       gth_id,
       entry_type,
       internal_gmr_ref_no,
       pcdi_id,
       pcth_id,
       internal_action_ref_no,
       is_active,
       process,
       dbd_id)
      select ul.gthul_id,
             ul.gth_id,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.pcdi_id,
             ul.pcth_id,
             ul.internal_action_ref_no,
             ul.is_active,
             pc_process,
             pc_dbd_id
        from gthul_gmr_treatment_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb               axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:gthul_gmr_treatment_header_ul');
  
    insert into grhul_gmr_refining_header_ul
      (grhul_id,
       grh_id,
       entry_type,
       internal_gmr_ref_no,
       pcdi_id,
       pcrh_id,
       internal_action_ref_no,
       is_active,
       process,
       dbd_id)
      select ul.grhul_id,
             ul.grh_id,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.pcdi_id,
             ul.pcrh_id,
             ul.internal_action_ref_no,
             ul.is_active,
             pc_process,
             pc_dbd_id
        from grhul_gmr_refining_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb              axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:grhul_gmr_refining_header_ul');
  
    insert into gphul_gmr_penalty_header_ul
      (gphul_id,
       gph_id,
       entry_type,
       internal_gmr_ref_no,
       pcdi_id,
       pcaph_id,
       internal_action_ref_no,
       is_active,
       process,
       dbd_id)
      select ul.gphul_id,
             ul.gph_id,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.pcdi_id,
             ul.pcaph_id,
             ul.internal_action_ref_no,
             ul.is_active,
             pc_process,
             pc_dbd_id
        from gphul_gmr_penalty_header_ul@eka_appdb ul,
             eod_eom_axsdata@eka_appdb             axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.eodeom_id = pc_app_eodeom_id
         and axs.process = pc_process;
    commit;
    vn_logno := vn_logno + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            vc_dbd_id,
                            vn_logno,
                            'D:gphul_gmr_penalty_header_ul');
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_insert_ul_data',
                                                           'M2M-013',
                                                           'code:' ||
                                                           sqlcode ||
                                                           'message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;

  procedure sp_phy_insert_costing_data
  --*****************************************************************************************************************************************
    --                procedure name                           : sp_insert_ul_data
    --                author                                   : siva
    --                created date                             : 09th jan 2009
    --                purpose                                  : transfer transaction data into eod database
    --                parameters
    --
    --                pc_corporate_id                          corporate id
    --                pd_trade_date                            eod data
    --                pc_user_id                               user id
    --                pc_process                               process = 'eod'
    --
    --                modification history
    --                modified by                              :
    --                modified date                            :
    --                modify description                       :
    --*****************************************************************************************************************************************
  (pc_corporate_id in varchar2,
   pc_user_id      varchar2,
   pc_process      varchar2,
   pc_dbd_id       varchar2,
   pd_trade_date   date) is
  
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_no              number;
    vn_logno           number;
  begin
   vn_logno := 1;
   vn_no := 1;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'invd_inventory_detail transfer started..');
    insert into invd_inventory_detail
      (inv_detail_id,
       inv_id,
       internal_action_ref_no,
       event_seq,
       inv_event,
       cost_type,
       transaction_date,
       transaction_cost,
       transaction_qty,
       is_direct_cost,
       is_secondary_cost,
       account_type,
       is_active,
       is_inventory_out,
       is_propogated_cost,
       cost_ref_no,
       cost_component_id,
       cost_component_name,
       is_cancelled,
       version,
       dbd_id)
      select inv_detail_id,
             inv_id,
             invd.internal_action_ref_no,
             event_seq,
             inv_event,
             cost_type,
             transaction_date,
             transaction_cost,
             transaction_qty,
             is_direct_cost,
             is_secondary_cost,
             account_type,
             is_active,
             is_inventory_out,
             is_propogated_cost,
             cost_ref_no,
             cost_component_id,
             cost_component_name,
             is_cancelled,
             version,
             pc_dbd_id
        from invd_inventory_detail@eka_appdb invd,
             axs_action_summary              axs,
             dbd_database_dump               dbd
       where axs.internal_action_ref_no = invd.internal_action_ref_no
         and axs.corporate_id = pc_corporate_id
         and axs.dbd_id = dbd.dbd_id
         and dbd.process = pc_process
         and dbd.corporate_id = pc_corporate_id
         and axs.eff_date <= pd_trade_date;
    commit;
    vn_no := 2;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'invm_inventory_master populate started..');
    insert into invm_inventory_master
      (internal_inv_id,
       inv_ref_no,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       internal_dgrd_ref_no,
       internal_contract_item_ref_no,
       inv_in_action_ref_no,
       inv_status,
       original_inv_qty,
       current_inv_qty,
       inv_qty_id,
       cog_cur_id,
       is_active,
       version,
       dbd_id,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       price_unit_weight_unit_id,
       price_unit_weight_unit,
       price_unit_weight,
       process_id)
      select t.inv_id,
             invm.inv_ref_no,
             invm.internal_gmr_ref_no,
             invm.internal_grd_ref_no,
             internal_dgrd_ref_no,
             invm.internal_contract_item_ref_no,
             invm.inv_in_action_ref_no,
             invm.inv_status,
             invm.original_inv_qty,
             t.cur_inv_qty current_inv_qty,
             invm.inv_qty_id,
             invm.cog_cur_id,
             invm.is_active,
             invm.version,
             pc_dbd_id,
             pum.price_unit_id,
             pum.cur_id,
             cm.cur_code,
             pum.weight_unit_id,
             qum.qty_unit,
             pum.weight,
             gvc_process_id
        from (select invd.inv_id,
                     nvl(sum(invd.transaction_qty), 0) cur_inv_qty
                from invd_inventory_detail     invd,
                     scm_service_charge_master scm
               where invd.transaction_date <= pd_trade_date
                 and invd.dbd_id = pc_dbd_id
                 and invd.cost_component_id = scm.cost_id
                 and invd.account_type = 'COG'
               group by invd.inv_id) t,
             invm_inventory_master@eka_appdb invm,
             pum_price_unit_master pum,
             cm_currency_master cm,
             qum_quantity_unit_master qum
       where t.inv_id = invm.internal_inv_id
         and invm.cog_cur_id = pum.cur_id
         and invm.inv_qty_id = pum.weight_unit_id
         and nvl(pum.weight, 1) = 1
         and pum.cur_id = cm.cur_id
         and pum.weight_unit_id = qum.qty_unit_id
         and invm.internal_dgrd_ref_no is null;
    commit;
    vn_no := 3;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'is_invoice_summary transfer started..');    
    insert into is_invoice_summary
      (internal_invoice_ref_no,
       invoice_type,
       invoice_type_name,
       total_invoice_item_amount,
       total_tax_amount,
       total_item_amount_cur_id,
       tax_amount_cur_id,
       total_other_charge_amount,
       other_charge_amount_cur_id,
       payment_due_date,
       invoice_issue_date,
       cp_ref_no,
       recieved_raised_type,
       invoice_created_date,
       profit_center_id,
       total_amount_to_pay,
       posting_status,
       amount_paid,
       invoice_status,
       is_dc_created_oncancel,
       cancel_invoice_ref_no,
       cancelled_debit_credit_ref_no,
       created_from,
       invoiced_qty,
       approval_status,
       internal_contract_ref_no,
       is_active,
       invoice_ref_no,
       api_adjusted_amount,
       is_considered_for_final,
       amount_to_pay_before_adj,
       new_fx_rate,
       invoiced_price_unit_id,
       invoiced_price,
       new_invoiced_qty_unit_id,
       new_invoiced_qty,
       corporate_id,
       internal_comments,
       bill_to_address,
       cp_id,
       fx_to_base,
       bill_to_cp_id,
       reason_for_modification,
       is_dc_created,
       credit_term,
       provisional_pymt_pctg,
       invoice_cur_id,
       is_prov_created,
       cancelled_invoice_int_ref_no,
       vat_parent_ref_no,
       is_free_metal,
       is_inv_draft,
       dbd_id,
       is_cancelled_today,
       is_invoice_new,
       is_pledge,
       is_receive_material,
       payable_receivable,
       invoiced_qty_unit_id,
       freight_allowance_amt,
       process_id)
      select internal_invoice_ref_no,
             invoice_type,
             invoice_type_name,
             total_invoice_item_amount,
             total_tax_amount,
             total_item_amount_cur_id,
             tax_amount_cur_id,
             total_other_charge_amount,
             other_charge_amount_cur_id,
             payment_due_date,
             invoice_issue_date,
             cp_ref_no,
             recieved_raised_type,
             invoice_created_date,
             profit_center_id,
             abs(total_amount_to_pay),
             posting_status,
             amount_paid,
             invoice_status,
             is_dc_created_oncancel,
             cancel_invoice_ref_no,
             cancelled_debit_credit_ref_no,
             created_from,
             invoiced_qty,
             approval_status,
             internal_contract_ref_no,
             is_active,
             invoice_ref_no,
             api_adjusted_amount,
             is_considered_for_final,
             amount_to_pay_before_adj,
             new_fx_rate,
             invoiced_price_unit_id,
             invoiced_price,
             new_invoiced_qty_unit_id,
             new_invoiced_qty,
             corporate_id,
             internal_comments,
             bill_to_address,
             cp_id,
             fx_to_base,
             bill_to_cp_id,
             reason_for_modification,
             is_dc_created,
             credit_term,
             provisional_pymt_pctg,
             invoice_cur_id,
             is_prov_created,
             cancelled_invoice_int_ref_no,
             vat_parent_ref_no,
             is_free_metal,
             is_inv_draft,
             pc_dbd_id,
             'N',
             'N',
             is_pledge,
             is_receive_material,
             payable_receivable,
             invoiced_qty_unit_id,
             freight_allowance_amt,
             gvc_process_id
        from is_invoice_summary@eka_appdb is1
       where is1.invoice_issue_date <= pd_trade_date
         and is1.corporate_id = pc_corporate_id;
    commit;
    vn_no := 4;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'update invoiced cancelled today..');       
    /*update is_invoice_summary is1
      set is1.is_cancelled_today = 'Y'
    where is1.is_active = 'N'
      and is1.dbd_id = pc_dbd_id
      and is1.internal_invoice_ref_no in
          (select is1.internal_invoice_ref_no
             from is_invoice_summary is2
            where is2.dbd_id = gvc_previous_dbd_id
              and is2.is_active = 'Y');*/
    update is_invoice_summary is1
       set is1.is_cancelled_today = 'Y'
     where is1.is_active = 'N'
       and is1.dbd_id = pc_dbd_id
       and exists
     (select is2.internal_invoice_ref_no
              from is_invoice_summary is2
             where is2.dbd_id = gvc_previous_dbd_id
               and is2.internal_invoice_ref_no = is1.internal_invoice_ref_no
               and is2.is_active = 'Y');
    commit;
    vn_no := 5;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'update new invoice today..');      
    update is_invoice_summary is1
       set is1.is_invoice_new = 'Y'
     where is1.dbd_id = pc_dbd_id
       and not exists
     (select is2.internal_invoice_ref_no
              from is_invoice_summary is2
             where is2.dbd_id = gvc_previous_dbd_id
               and is2.internal_invoice_ref_no = is1.internal_invoice_ref_no);
  
    /*update is_invoice_summary is1
      set is1.is_invoice_new = 'Y'
    where is1.is_active = 'Y'
      and is1.dbd_id = pc_dbd_id
      and is1.internal_invoice_ref_no not in
          (select is2.internal_invoice_ref_no
             from is_invoice_summary is2
            where is2.dbd_id = gvc_previous_dbd_id);*/
    vn_no := 6;
    commit;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'update modified invoice today..');  
    for cc in (select is1.internal_invoice_ref_no,
                      is1.corporate_id,
                      is1.payment_due_date,
                      nvl(is1.cp_ref_no, 'NA') cp_ref_no,
                      nvl(is1.bill_to_address, 'NA') bill_to_address
                 from is_invoice_summary is1
                where is1.dbd_id = gvc_previous_dbd_id
                  and is1.is_active = 'Y')
    loop
      update is_invoice_summary is2
         set is2.is_modified_today = 'Y'
       where is2.internal_invoice_ref_no = cc.internal_invoice_ref_no
         and is2.dbd_id = pc_dbd_id
         and (is2.payment_due_date <> cc.payment_due_date or
             nvl(is2.cp_ref_no, 'NA') <> cc.cp_ref_no or
             nvl(is2.bill_to_address, 'NA') <> cc.bill_to_address)
         and is2.is_active = 'Y'
         and is2.is_invoice_new = 'N'
         and is2.is_cancelled_today = 'N';
    end loop;
    vn_no := 7;
    commit;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'transfer plege gmr elements..');  
    
    delete from gepd_gmr_element_pledge_detail
     where corporate_id = pc_corporate_id;
    commit;
    insert into gepd_gmr_element_pledge_detail
      (gepd_id,
       corporate_id,
       activity_action_id,
       activity_ref_no,
       activity_date,
       internal_gmr_ref_no,
       pledge_input_gmr,
       supplier_cp_id,
       pledge_cp_id,
       product_id,
       element_id,
       element_type,
       pledge_qty,
       pledge_qty_unit_id,
       internal_action_ref_no,
       version,
       is_active,
       quality_id,
       due_date,
       dbd_id,
       process_id)
      select gepd.gepd_id,
             gepd.corporate_id,
             gepd.activity_action_id,
             gepd.activity_ref_no,
             gepd.activity_date,
             gepd.internal_gmr_ref_no,
             gepd.pledge_input_gmr,
             gepd.supplier_cp_id,
             gepd.pledge_cp_id,
             gepd.product_id,
             gepd.element_id,
             gepd.element_type,
             gepd.pledge_qty,
             gepd.pledge_qty_unit_id,
             gepd.internal_action_ref_no,
             gepd.version,
             gepd.is_active,
             gepd.quality_id,
             gepd.due_date,
             pc_dbd_id,
             gvc_process_id
        from gepd_gmr_element_pledge_detail@eka_appdb gepd
       where gepd.corporate_id = pc_corporate_id
         and gepd.activity_date <= pd_trade_date;
    commit;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'transfer pcmac_pcm_addn_charges..');      
    delete from pcmac_pcm_addn_charges pcmac
     where pcmac.corporate_id = pc_corporate_id;
    insert into pcmac_pcm_addn_charges
      (corporate_id,
       pcmac_id,
       int_contract_ref_no,
       addn_charge_id,
       addn_charge_name,
       charge_type,
       position,
       range_min_op,
       range_min_value,
       range_max_op,
       range_max_value,
       range_unit_id,
       charge,
       charge_cur_id,
       charge_rate_basis,
       container_size,
       fx_rate,
       is_active,
       qty_unit_id,
       version,
       is_automatic_charge)
      select pc_corporate_id,
             pcmac_id,
             int_contract_ref_no,
             addn_charge_id,
             addn_charge_name,
             charge_type,
             position,
             range_min_op,
             range_min_value,
             range_max_op,
             range_max_value,
             range_unit_id,
             charge,
             charge_cur_id,
             charge_rate_basis,
             container_size,
             nvl(fx_rate, 1),
             pcmac.is_active,
             qty_unit_id,
             pcmac.version,
             is_automatic_charge
        from pcmac_pcm_addn_charges@eka_appdb     pcmac,
             pcm_physical_contract_main@eka_appdb pcm
       where pcm.corporate_id = pc_corporate_id
         and pcm.internal_contract_ref_no = pcmac.int_contract_ref_no;
    commit;
   vn_logno := vn_logno + 1;
   sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            vn_logno,
                            'Physical table data transfer completed...');    
  exception
    when others then
      sp_precheck_process_log(pc_corporate_id,
                              pd_trade_date,
                              00000,
                              00000,
                              'code:' || sqlcode || 'message:' || sqlerrm ||
                              'at ' || vn_no);
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_insert_costing_data',
                                                           'M2M-013',
                                                           'code:' ||
                                                           sqlcode ||
                                                           'message:' ||
                                                           sqlerrm || 'at ' ||
                                                           vn_no,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;

end pkg_phy_transfer_data; 
/
