create or replace package pkg_phy_populate_data is

  -- Author  : SURESHGOTTIPATI
  -- Created : 5/2/2011 5:33:53 PM
  -- Purpose : 
  gvc_dbd_id varchar2(15);

  gvc_process     varchar2(15);
  gvc_process_id  varchar2(15);
  gvn_log_counter number := 750;
  procedure sp_phy_populate_table_data(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_user_id      varchar2,
                                       pc_dbd_id       varchar2,
                                       pc_process      varchar2);
  procedure sp_phy_create_agd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_agh_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_cigc_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_cs_data(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_user_id      varchar2);
  procedure sp_phy_create_dgrd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);

  procedure sp_phy_create_gmr_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2,
                                   pc_previous_year_eom_id varchar2);
  procedure sp_phy_create_mogrd_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);

  procedure sp_phy_create_pcad_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);

  procedure sp_phy_create_pcbpd_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);

  procedure sp_phy_create_pcbph_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_pcdb_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pcdd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);

  procedure sp_phy_create_pcdiob_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2);
  procedure sp_phy_create_pcdipe_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2);
  procedure sp_phy_create_pcdiqd_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2);
  procedure sp_phy_create_pcdi_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pcipf_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_pci_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_pcjv_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pcm_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_pcpdqd_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2);
  procedure sp_phy_create_pcpd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pcpq_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pcqpd_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_pffxd_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_pfqpp_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_ppfd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_ppfh_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_ciqs_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_diqs_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_cqs_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_grd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_vd_data(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_user_id      varchar2);
  procedure sp_phy_create_pcpch_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_pqd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_pcepc_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_pcth_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_ted_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_tqd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_pcetc_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_pcar_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pcaesl_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2);
  procedure sp_phy_create_arqd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pcaph_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_pcap_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pqdp_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_pad_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_pcrh_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_rqd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_red_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_pcerc_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_dith_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_dirh_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_diph_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_cipq_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_dipq_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2);
  procedure sp_phy_create_spq_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);

  procedure sp_phy_create_dipch_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2);
  procedure sp_phy_create_invs(pc_corporate_id varchar2,
                               pd_trade_date   date,
                               pc_user_id      varchar2);
  procedure sp_phy_update_contract_details(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_dbd_id       varchar2,
                                           pc_process      varchar2,
                                           pc_user_id      varchar2);
  procedure sp_create_exchange_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2,
                                    pc_dbd_id       varchar2,
                                    pc_process      varchar2);
  procedure sp_phy_create_gth_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_grh_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);
  procedure sp_phy_create_gph_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2);

end pkg_phy_populate_data; 
/
create or replace package body pkg_phy_populate_data is

 procedure sp_phy_populate_table_data
 /*******************************************************************************************************************************************
   procedure name                           : sp_populate_table_data
   author                                   : 
   created date                             : 12TH JAN 2011
   purpose                                  : populate transfer transaction data
   parameters
   pc_corporate_id                          : corporate id
   pt_previous_pull_date                    : last dump date
   pt_current_pull_date                     : current sys time(when called)
   pd_trade_date                            : eod data
   pc_user_id                               : user id
   pc_process                               : process = 'eod'
   modified date  :
   modify description :
   ******************************************************************************************************************************************/
 (pc_corporate_id varchar2,
  pd_trade_date   date,
  pc_user_id      varchar2,
  pc_dbd_id       varchar2,
  pc_process      varchar2) is
   vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
   vn_eel_error_count number := 1;
   vc_previous_year_eom_id varchar2(15);
 begin
 
   gvc_dbd_id  := pc_dbd_id;
   gvc_process := pc_process;
   select tdc.process_id
     into gvc_process_id
     from tdc_trade_date_closure tdc
    where tdc.corporate_id = pc_corporate_id
      and tdc.trade_date = pd_trade_date
      and tdc.process = pc_process;
      
      -- Added Suresh
       begin
    select tdc.process_id
      into vc_previous_year_eom_id
      from tdc_trade_date_closure tdc
     where tdc.corporate_id = pc_corporate_id
       and tdc.process = pc_process
       and tdc.trade_date =
           (select max(tdc_in.trade_date)
              from tdc_trade_date_closure tdc_in
             where tdc_in.corporate_id = pc_corporate_id
               and tdc_in.process = pc_process
               and tdc_in.trade_date < trunc(pd_trade_date, 'yyyy'));
  exception
    when no_data_found then
      vc_previous_year_eom_id := null;
  end;
  
  
 
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_agd_data');
   sp_phy_create_agd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_agh_data');
   sp_phy_create_agh_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_cigc_data');
   sp_phy_create_cigc_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_cs_data');
   sp_phy_create_cs_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_dgrd_data');
   sp_phy_create_dgrd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_gmr_data');
   sp_phy_create_gmr_data(pc_corporate_id, pd_trade_date, pc_user_id,vc_previous_year_eom_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_mogrd_data');
   sp_phy_create_mogrd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcad_data');
   sp_phy_create_pcad_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcbpd_data');
   sp_phy_create_pcbpd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcbph_data');
   sp_phy_create_pcbph_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcdb_data');
   sp_phy_create_pcdb_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcdd_data');
   sp_phy_create_pcdd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcdiob_data');
   sp_phy_create_pcdiob_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcdipe_data');
   sp_phy_create_pcdipe_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcdiqd_data');
   sp_phy_create_pcdiqd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcdi_data');
   sp_phy_create_pcdi_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcipf_data');
   sp_phy_create_pcipf_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pci_data');
   sp_phy_create_pci_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcjv_data');
   sp_phy_create_pcjv_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcm_data');
   sp_phy_create_pcm_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcpdqd_data');
   sp_phy_create_pcpdqd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcpd_data');
   sp_phy_create_pcpd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcpq_data');
   sp_phy_create_pcpq_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcqpd_data');
   sp_phy_create_pcqpd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pffxd_data');
   sp_phy_create_pffxd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pfqpp_data');
   sp_phy_create_pfqpp_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_ppfd_data');
   sp_phy_create_ppfd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_ppfh_data');
   sp_phy_create_ppfh_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_ciqs_data');
   sp_phy_create_ciqs_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_diqs_data');
   sp_phy_create_diqs_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_cqs_data');
   sp_phy_create_cqs_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_grd_data');
   sp_phy_create_grd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_vd_data');
   sp_phy_create_vd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcpch_data');
   sp_phy_create_pcpch_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pqd_data');
   sp_phy_create_pqd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcepc_data');
   sp_phy_create_pcepc_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcth_data');
   sp_phy_create_pcth_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_ted_data');
   sp_phy_create_ted_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_tqd_data');
   sp_phy_create_tqd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcetc_data');
   sp_phy_create_pcetc_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcar_data');
   sp_phy_create_pcar_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcaesl_data');
   sp_phy_create_pcaesl_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_arqd_data');
   sp_phy_create_arqd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcaph_data');
   sp_phy_create_pcaph_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcap_data');
   sp_phy_create_pcap_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pqdp_data');
   sp_phy_create_pqdp_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pad_data');
   sp_phy_create_pad_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcrh_data');
   sp_phy_create_pcrh_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_rqd_data');
   sp_phy_create_rqd_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_red_data');
   sp_phy_create_red_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_pcerc_data');
   sp_phy_create_pcerc_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_dith_data');
   sp_phy_create_dith_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
 
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_dirh_data');
   sp_phy_create_dirh_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
 
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_diph_data');
   sp_phy_create_diph_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
 
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_cipq_data');
   sp_phy_create_cipq_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
 
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_dipq_data');
   sp_phy_create_dipq_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
 
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_spq_data');
   sp_phy_create_spq_data(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
 
   if pkg_process_status.sp_get(pc_corporate_id, gvc_process, pd_trade_date) =
      'Cancel' then
     goto cancel_process;
   end if;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_dipch_data');
   sp_phy_create_dipch_data(pc_corporate_id, pd_trade_date, pc_user_id);
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_invs');
   sp_phy_create_invs(pc_corporate_id, pd_trade_date, pc_user_id);
   commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_gth_data');
 
   sp_phy_create_gth_data(pc_corporate_id, pd_trade_date, pc_user_id);
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_grh_data');
   sp_phy_create_grh_data(pc_corporate_id, pd_trade_date, pc_user_id);
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_create_gph_data');
   sp_phy_create_gph_data(pc_corporate_id, pd_trade_date, pc_user_id);
 
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'sp_phy_update_contract_details');
   sp_phy_update_contract_details(pc_corporate_id,
                                  pd_trade_date,
                                  pc_dbd_id,
                                  pc_process,
                                  pc_user_id);
   commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           pc_dbd_id,
                           gvn_log_counter,
                           'End of Populate Data');
 
   <<cancel_process>>
   dbms_output.put_line('EOD/EOM Process Cancelled while populate table data');
 exception
   when others then
     vobj_error_log.extend;
     vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                          'procedure sp_Phy_populate_table_data',
                                                          'M2M-013',
                                                          'Code:' || sqlcode ||
                                                          'Message:' ||
                                                          sqlerrm,
                                                          '',
                                                          gvc_process,
                                                          pc_user_id,
                                                          sysdate,
                                                          pd_trade_date);
     sp_insert_error_log(vobj_error_log);
 end;


  procedure sp_phy_create_agd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcm_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    insert into agd_alloc_group_detail
      (int_alloc_group_detail_id,
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
       internal_action_ref_no,
       no_of_units,
       packing_size_id,
       handled_as,
       dbd_id,
       process_id)
      select decode(int_alloc_group_detail_id,
                    'Empty_String',
                    null,
                    int_alloc_group_detail_id),
             decode(int_alloc_group_id,
                    'Empty_String',
                    null,
                    int_alloc_group_id),
             decode(internal_contract_item_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_item_ref_no),
             decode(qty, 'Empty_String', null, qty),
             decode(qty_unit_id, 'Empty_String', null, qty_unit_id),
             decode(alloc_type, 'Empty_String', null, alloc_type),
             decode(created_by, 'Empty_String', null, created_by),
             to_timestamp(decode(created_date,
                                 'Empty_String',
                                 null,
                                 created_date),
                          'yyyy-mm-dd hh24:mi:ss.FF'),
             decode(updated_by, 'Empty_String', null, updated_by),
             to_timestamp(decode(updated_date,
                                 'Empty_String',
                                 null,
                                 updated_date),
                          'yyyy-mm-dd hh24:mi:ss.FF'),
             decode(cancelled_by, 'Empty_String', null, cancelled_by),
             to_timestamp(decode(cancelled_date,
                                 'Empty_String',
                                 null,
                                 cancelled_date),
                          'yyyy-mm-dd hh24:mi:ss.FF'),
             decode(qty_in_sales_unit,
                    'Empty_String',
                    null,
                    qty_in_sales_unit),
             decode(internal_stock_ref_no,
                    'Empty_String',
                    null,
                    internal_stock_ref_no),
             decode(sales_qty_unit_id,
                    'Empty_String',
                    null,
                    sales_qty_unit_id),
             decode(is_deleted, 'Empty_String', null, is_deleted),
             decode(internal_action_ref_no,
                    'Empty_String',
                    null,
                    internal_action_ref_no),
             decode(no_of_units, 'Empty_String', null, no_of_units),
             decode(packing_size_id, 'Empty_String', null, packing_size_id),
             decode(handled_as, 'Empty_String', null, handled_as),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select agdul.int_alloc_group_detail_id,
                     substr(max(case
                                  when agdul.int_alloc_group_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.int_alloc_group_id
                                end),
                            24) int_alloc_group_id,
                     
                     substr(max(case
                                  when agdul.internal_contract_item_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.internal_contract_item_ref_no
                                end),
                            24) internal_contract_item_ref_no,
                     substr(max(case
                                  when agdul.qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.qty
                                end),
                            24) qty,
                     substr(max(case
                                  when agdul.qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.qty_unit_id
                                end),
                            24) qty_unit_id,
                     substr(max(case
                                  when agdul.alloc_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.alloc_type
                                end),
                            24) alloc_type,
                     substr(max(case
                                  when agdul.created_by is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.created_by
                                end),
                            24) created_by,
                     substr(max(case
                                  when agdul.created_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.created_date
                                end),
                            24) created_date,
                     substr(max(case
                                  when agdul.updated_by is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.updated_by
                                end),
                            24) updated_by,
                     substr(max(case
                                  when agdul.updated_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.updated_date
                                end),
                            24) updated_date,
                     substr(max(case
                                  when agdul.cancelled_by is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.cancelled_by
                                end),
                            24) cancelled_by,
                     substr(max(case
                                  when agdul.cancelled_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.cancelled_date
                                end),
                            24) cancelled_date,
                     substr(max(case
                                  when agdul.qty_in_sales_unit is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.qty_in_sales_unit
                                end),
                            24) qty_in_sales_unit,
                     substr(max(case
                                  when agdul.internal_stock_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.internal_stock_ref_no
                                end),
                            24) internal_stock_ref_no,
                     substr(max(case
                                  when agdul.sales_qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.sales_qty_unit_id
                                end),
                            24) sales_qty_unit_id,
                     substr(max(case
                                  when agdul.is_deleted is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.is_deleted
                                end),
                            24) is_deleted,
                     substr(max(case
                                  when agdul.internal_action_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.internal_action_ref_no
                                end),
                            24) internal_action_ref_no,
                     substr(max(case
                                  when agdul.no_of_units is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.no_of_units
                                end),
                            24) no_of_units,
                     substr(max(case
                                  when agdul.packing_size_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.packing_size_id
                                end),
                            24) packing_size_id,
                     substr(max(case
                                  when agdul.handled_as is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   agdul.handled_as
                                end),
                            24) handled_as,
                     gvc_dbd_id
                from agdul_alloc_group_detail_ul agdul,
                     axs_action_summary          axs,
                     dbd_database_dump           dbd_ul
               where axs.process = gvc_process
                 and agdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and agdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by agdul.int_alloc_group_detail_id) t;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_agd_data',
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
  procedure sp_phy_create_agh_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcm_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    insert into agh_alloc_group_header
      (int_alloc_group_id,
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
       internal_action_ref_no,
       partnership_type,
       dbd_id)
      select decode(int_alloc_group_id,
                    'Empty_String',
                    null,
                    int_alloc_group_id),
             decode(int_sales_contract_item_ref_no,
                    'Empty_String',
                    null,
                    int_sales_contract_item_ref_no),
             decode(alloc_group_name,
                    'Empty_String',
                    null,
                    alloc_group_name),
             decode(alloc_date, 'Empty_String', null, alloc_date),
             decode(alloc_remarks, 'Empty_String', null, alloc_remarks),
             decode(alloc_item_qty, 'Empty_String', null, alloc_item_qty),
             decode(alloc_item_qty_unit_id,
                    'Empty_String',
                    null,
                    alloc_item_qty_unit_id),
             decode(execution_status,
                    'Empty_String',
                    null,
                    execution_status),
             decode(created_by, 'Empty_String', null, created_by),
             to_timestamp(decode(created_date,
                                 'Empty_String',
                                 null,
                                 created_date),
                          'yyyy-mm-dd hh24:mi:ss.FF'),
             decode(updated_by, 'Empty_String', null, updated_by),
             to_timestamp(decode(updated_date,
                                 'Empty_String',
                                 null,
                                 updated_date),
                          'yyyy-mm-dd hh24:mi:ss.FF'),
             decode(cancelled_by, 'Empty_String', null, cancelled_by),
             to_timestamp(decode(cancelled_date,
                                 'Empty_String',
                                 null,
                                 cancelled_date),
                          'yyyy-mm-dd hh24:mi:ss.FF'),
             decode(is_deleted, 'Empty_String', null, is_deleted),
             decode(group_type, 'Empty_String', null, group_type),
             decode(realized_status, 'Empty_String', null, realized_status),
             decode(realized_date, 'Empty_String', null, realized_date),
             to_timestamp(decode(realized_creation_date,
                                 'Empty_String',
                                 null,
                                 realized_creation_date),
                          'yyyy-mm-dd hh24:mi:ss.FF'),
             decode(internal_action_ref_no,
                    'Empty_String',
                    null,
                    internal_action_ref_no),
             decode(partnership_type,
                    'Empty_String',
                    null,
                    partnership_type),
             gvc_dbd_id
        from (select aghul.int_alloc_group_id,
                     substr(max(case
                                  when aghul.int_sales_contract_item_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.int_sales_contract_item_ref_no
                                end),
                            24) int_sales_contract_item_ref_no,
                     
                     substr(max(case
                                  when aghul.alloc_group_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.alloc_group_name
                                end),
                            24) alloc_group_name,
                     substr(max(case
                                  when aghul.alloc_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.alloc_date
                                end),
                            24) alloc_date,
                     substr(max(case
                                  when aghul.alloc_remarks is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.alloc_remarks
                                end),
                            24) alloc_remarks,
                     substr(max(case
                                  when aghul.alloc_item_qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.alloc_item_qty
                                end),
                            24) alloc_item_qty,
                     substr(max(case
                                  when aghul.alloc_item_qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.alloc_item_qty_unit_id
                                end),
                            24) alloc_item_qty_unit_id,
                     substr(max(case
                                  when aghul.execution_status is not null then
                                 case when aghul.entry_type='Insert' then '1' else '2' end ||  to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.execution_status
                                end),
                            25) execution_status,
                     substr(max(case
                                  when aghul.created_by is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.created_by
                                end),
                            24) created_by,
                     substr(max(case
                                  when aghul.created_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.created_date
                                end),
                            24) created_date,
                     substr(max(case
                                  when aghul.updated_by is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.updated_by
                                end),
                            24) updated_by,
                     substr(max(case
                                  when aghul.updated_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.updated_date
                                end),
                            24) updated_date,
                     substr(max(case
                                  when aghul.cancelled_by is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.cancelled_by
                                end),
                            24) cancelled_by,
                     substr(max(case
                                  when aghul.cancelled_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.cancelled_date
                                end),
                            24) cancelled_date,
                     substr(max(case
                                  when aghul.is_deleted is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.is_deleted
                                end),
                            24) is_deleted,
                     substr(max(case
                                  when aghul.group_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.group_type
                                end),
                            24) group_type,
                     substr(max(case
                                  when aghul.realized_status is not null then
                                  case when aghul.entry_type='Insert' then '1' else '2' end || to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.realized_status
                                end),
                            25) realized_status,
                     substr(max(case
                                  when aghul.realized_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.realized_date
                                end),
                            24) realized_date,
                     substr(max(case
                                  when aghul.realized_creation_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.realized_creation_date
                                end),
                            24) realized_creation_date,
                     substr(max(case
                                  when aghul.internal_action_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.internal_action_ref_no
                                end),
                            24) internal_action_ref_no,
                     
                     substr(max(case
                                  when aghul.partnership_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   aghul.partnership_type
                                end),
                            24) partnership_type,
                     gvc_dbd_id
                from aghul_alloc_group_header_ul aghul,
                     axs_action_summary          axs,
                     dbd_database_dump           dbd_ul
               where axs.process = gvc_process
                 and aghul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and aghul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by aghul.int_alloc_group_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_agh_data',
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

  procedure sp_phy_create_cigc_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcm_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
  
    insert into cigc_contract_item_gmr_cost
      (cog_ref_no,
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
       dbd_id,
       process_id)
      select decode(cog_ref_no, 'Empty_String', null, cog_ref_no),
             decode(internal_gmr_ref_no,
                    'Empty_String',
                    null,
                    internal_gmr_ref_no),
             decode(int_contract_item_ref_no,
                    'Empty_String',
                    null,
                    int_contract_item_ref_no),
             decode(internal_grd_ref_no,
                    'Empty_String',
                    null,
                    internal_grd_ref_no),
             decode(qty, 'Empty_String', null, qty),
             decode(qty_unit_id, 'Empty_String', null, qty_unit_id),
             decode(qty_in_base_qty_unit,
                    'Empty_String',
                    null,
                    qty_in_base_qty_unit),
             decode(corporate_qty_unit_id,
                    'Empty_String',
                    null,
                    corporate_qty_unit_id),
             decode(is_deleted, 'Empty_String', null, is_deleted),
             decode(version, 'Empty_String', null, version),
             decode(gmr_activity_type,
                    'Empty_String',
                    null,
                    gmr_activity_type),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select cigcul.cog_ref_no,
                     substr(max(case
                                  when cigcul.internal_gmr_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.internal_gmr_ref_no
                                end),
                            24) internal_gmr_ref_no,
                     
                     substr(max(case
                                  when cigcul.int_contract_item_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.int_contract_item_ref_no
                                end),
                            24) int_contract_item_ref_no,
                     substr(max(case
                                  when cigcul.internal_grd_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.internal_grd_ref_no
                                end),
                            24) internal_grd_ref_no,
                     substr(max(case
                                  when cigcul.qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.qty
                                end),
                            24) qty,
                     substr(max(case
                                  when cigcul.qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.qty_unit_id
                                end),
                            24) qty_unit_id,
                     substr(max(case
                                  when cigcul.qty_in_base_qty_unit is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.qty_in_base_qty_unit
                                end),
                            24) qty_in_base_qty_unit,
                     substr(max(case
                                  when cigcul.corporate_qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.corporate_qty_unit_id
                                end),
                            24) corporate_qty_unit_id,
                     substr(max(case
                                  when cigcul.is_deleted is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.is_deleted
                                end),
                            24) is_deleted,
                     substr(max(case
                                  when cigcul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.version
                                end),
                            24) version,
                     substr(max(case
                                  when cigcul.gmr_activity_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   cigcul.gmr_activity_type
                                end),
                            24) gmr_activity_type,
                     gvc_dbd_id
                from cigcul_contrct_itm_gmr_cost_ul cigcul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and cigcul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and cigcul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by cigcul.cog_ref_no) t;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_cigc_data',
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
  procedure sp_phy_create_cs_data(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcm_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
insert into cs_cost_store
  (internal_cost_id,
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
   dbd_id,
   is_actual_posted_in_cog,
   acc_direct_actual,
   acc_original_accrual,
   acc_over_accrual,
   acc_under_accrual,
   delta_cost_in_base_price_id,
   reversal_type,
   process_id)
  select decode(internal_cost_id, 'Empty_String', null, internal_cost_id),
         decode(internal_action_ref_no,
                'Empty_String',
                null,
                internal_action_ref_no),
         decode(cog_ref_no, 'Empty_String', null, cog_ref_no),
         decode(cost_ref_no, 'Empty_String', null, cost_ref_no),
         decode(cost_type, 'Empty_String', null, cost_type),
         decode(cost_component_id, 'Empty_String', null, cost_component_id),
         decode(rate_type, 'Empty_String', null, rate_type),
         decode(cost_value, 'Empty_String', null, cost_value),
         decode(rate_price_unit_id,
                'Empty_String',
                null,
                rate_price_unit_id),
         decode(transaction_amt, 'Empty_String', null, transaction_amt),
         decode(transaction_amt_cur_id,
                'Empty_String',
                null,
                transaction_amt_cur_id),
         decode(fx_to_base, 'Empty_String', null, fx_to_base),
         decode(transact_amt_sign, 'Empty_String', null, transact_amt_sign),
         decode(cost_acc_type, 'Empty_String', null, cost_acc_type),
         decode(base_amt, 'Empty_String', null, base_amt),
         decode(base_amt_cur_id, 'Empty_String', null, base_amt_cur_id),
         decode(cost_in_base_price_unit_id,
                'Empty_String',
                null,
                cost_in_base_price_unit_id),
         decode(base_price_unit_id,
                'Empty_String',
                null,
                base_price_unit_id),
         decode(cost_in_transact_price_unit_id,
                'Empty_String',
                null,
                cost_in_transact_price_unit_id),
         decode(counter_party_id, 'Empty_String', null, counter_party_id),
         decode(parent_estimated_cost_ref_no,
                'Empty_String',
                null,
                parent_estimated_cost_ref_no),
         decode(estimated_amt, 'Empty_String', null, estimated_amt),
         decode(is_inv_possible, 'Empty_String', null, is_inv_possible),
         decode(version, 'Empty_String', null, version),
         decode(is_deleted, 'Empty_String', null, is_deleted),
         decode(effective_date, 'Empty_String', null, effective_date),
         decode(income_expense, 'Empty_String', null, income_expense),
         decode(est_payment_due_date,
                'Empty_String',
                null,
                est_payment_due_date),
         decode(inv_to_accrual_curr_fx,
                'Empty_String',
                null,
                inv_to_accrual_curr_fx),
         gvc_dbd_id,
         nvl(is_actual_posted_in_cog, 'Y'),
         nvl(acc_direct_actual, 'N'),
         nvl(acc_original_accrual, 'N'),
         nvl(acc_over_accrual, 'N'),
         nvl(acc_under_accrual, 'N'),
         delta_cost_in_base_price_id,
         nvl(reversal_type, 'N'),
         pkg_phy_populate_data.gvc_process_id
    from (select csul.internal_cost_id,
                 substr(max(case
                              when csul.internal_action_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.internal_action_ref_no
                            end),
                        24) internal_action_ref_no,
                 substr(max(case
                              when csul.cog_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.cog_ref_no
                            end),
                        24) cog_ref_no,
                 
                 substr(max(case
                              when csul.cost_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.cost_ref_no
                            end),
                        24) cost_ref_no,
                 substr(max(case
                              when csul.cost_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.cost_type
                            end),
                        24) cost_type,
                 substr(max(case
                              when csul.cost_component_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.cost_component_id
                            end),
                        24) cost_component_id,
                 substr(max(case
                              when csul.rate_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.rate_type
                            end),
                        24) rate_type,
                 substr(max(case
                              when csul.cost_value is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.cost_value
                            end),
                        24) cost_value,
                 substr(max(case
                              when csul.rate_price_unit_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.rate_price_unit_id
                            end),
                        24) rate_price_unit_id,
                 substr(max(case
                              when csul.transaction_amt is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.transaction_amt
                            end),
                        24) transaction_amt,
                 substr(max(case
                              when csul.transaction_amt_cur_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.transaction_amt_cur_id
                            end),
                        24) transaction_amt_cur_id,
                 substr(max(case
                              when csul.fx_to_base is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.fx_to_base
                            end),
                        24) fx_to_base,
                 
                 substr(max(case
                              when csul.transact_amt_sign is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.transact_amt_sign
                            end),
                        24) transact_amt_sign,
                 substr(max(case
                              when csul.cost_acc_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.cost_acc_type
                            end),
                        24) cost_acc_type,
                 substr(max(case
                              when csul.base_amt is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.base_amt
                            end),
                        24) base_amt,
                 substr(max(case
                              when csul.base_amt_cur_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.base_amt_cur_id
                            end),
                        24) base_amt_cur_id,
                 substr(max(case
                              when csul.cost_in_base_price_unit_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.cost_in_base_price_unit_id
                            end),
                        24) cost_in_base_price_unit_id,
                 substr(max(case
                              when csul.base_price_unit_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.base_price_unit_id
                            end),
                        24) base_price_unit_id,
                 substr(max(case
                              when csul.cost_in_transact_price_unit_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.cost_in_transact_price_unit_id
                            end),
                        24) cost_in_transact_price_unit_id,
                 substr(max(case
                              when csul.counter_party_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.counter_party_id
                            end),
                        24) counter_party_id,
                 substr(max(case
                              when csul.parent_estimated_cost_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.parent_estimated_cost_ref_no
                            end),
                        24) parent_estimated_cost_ref_no,
                 
                 substr(max(case
                              when csul.estimated_amt is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.estimated_amt
                            end),
                        24) estimated_amt,
                 substr(max(case
                              when csul.is_inv_possible is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.is_inv_possible
                            end),
                        24) is_inv_possible,
                 substr(max(case
                              when csul.version is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.version
                            end),
                        24) version,
                 substr(max(case
                              when csul.is_deleted is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.is_deleted
                            end),
                        24) is_deleted,
                 substr(max(case
                              when csul.effective_date is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.effective_date
                            end),
                        24) effective_date,
                 substr(max(case
                              when csul.income_expense is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.income_expense
                            end),
                        24) income_expense,
                 substr(max(case
                              when csul.est_payment_due_date is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.est_payment_due_date
                            end),
                        24) est_payment_due_date,
                 substr(max(case
                              when csul.inv_to_accrual_curr_fx is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.inv_to_accrual_curr_fx
                            end),
                        24) inv_to_accrual_curr_fx,
                 gvc_dbd_id,
                 substr(max(case
                              when csul.is_actual_posted_in_cog is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.is_actual_posted_in_cog
                            end),
                        24) is_actual_posted_in_cog,
                 substr(max(case
                              when csul.acc_direct_actual is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.acc_direct_actual
                            end),
                        24) acc_direct_actual,
                 substr(max(case
                              when csul.acc_original_accrual is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.acc_original_accrual
                            end),
                        24) acc_original_accrual,
                 substr(max(case
                              when csul.acc_over_accrual is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.acc_over_accrual
                            end),
                        24) acc_over_accrual,
                 substr(max(case
                              when csul.acc_under_accrual is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.acc_under_accrual
                            end),
                        24) acc_under_accrual,
                 substr(max(case
                              when csul.delta_cost_in_base_price_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.delta_cost_in_base_price_id
                            end),
                        24) delta_cost_in_base_price_id,
                 substr(max(case
                              when csul.reversal_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               csul.reversal_type
                            end),
                        24) reversal_type
            from csul_cost_store_ul csul,
                 axs_action_summary axs,
                 dbd_database_dump  dbd_ul
           where axs.process = gvc_process
             and csul.internal_action_ref_no = axs.internal_action_ref_no
             and axs.eff_date <= pd_trade_date
             and axs.corporate_id = pc_corporate_id
             and csul.dbd_id = dbd_ul.dbd_id
             and dbd_ul.corporate_id = pc_corporate_id
             and dbd_ul.process = gvc_process
           group by csul.internal_cost_id) t;           
          insert into ecs_element_cost_store
            (element_cost_id,
             internal_cost_id,
             element_id,
             payable_qty,
             payable_qty_in_base_qty_unit,
             qty_unit_id,
             cost_value,
             rate_price_unit_id,
             transaction_amt,
             transaction_amt_cur_id,
             fx_to_base,
             base_amt,
             base_amt_cur_id,
             cost_in_base_price_unit_id,
             cost_in_transact_price_unit_id,
             version,
             cost_ref_no,
             is_deleted,
             rate_price_unit_id_in_pum,
             dbd_id,
             process_id)
            select element_cost_id,
                   internal_cost_id,
                   element_id,
                   payable_qty,
                   payable_qty_in_base_qty_unit,
                   qty_unit_id,
                   cost_value,
                   rate_price_unit_id,
                   transaction_amt,
                   transaction_amt_cur_id,
                   fx_to_base,
                   base_amt,
                   base_amt_cur_id,
                   cost_in_base_price_unit_id,
                   cost_in_transact_price_unit_id,
                   ecs.version,
                   cost_ref_no,
                   ecs.is_deleted,
                   ppu.price_unit_id,-- PUM ID
                   gvc_dbd_id,
                   pkg_phy_populate_data.gvc_process_id
              from ecs_element_cost_store@eka_appdb ecs,
              ppu_product_price_units ppu
              where ecs.internal_cost_id in
                   (select internal_cost_id
                      from cs_cost_store cs
                     where cs.dbd_id = gvc_dbd_id)
                     and ppu.internal_price_unit_id = ecs.rate_price_unit_id;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_cs_data',
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

  procedure sp_phy_create_dgrd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    insert into dgrd_delivered_grd
      (internal_dgrd_ref_no,
       action_no,
       internal_gmr_ref_no,
       int_alloc_group_id,
       container_no,
       seal_no,
       mark_no,
       release_shipped_no_of_units,
       status,
       old_net_weight,
       gross_weight,
       tare_weight,
       net_weight,
       net_weight_unit_id,
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
       crop_year_id,
       current_qty,
       internal_contract_item_ref_no,
       is_weight_final,
       origin_id,
       packing_size_id,
       product_id,
       product_specs,
       quality_id,
       write_off_qty,
       is_write_off,
       internal_action_ref_no,
       realized_status,
       realized_date,
       realized_creation_date,
       stock_status,
       item_price,
       item_price_unit,
       current_no_of_units,
       total_no_of_units,
       no_of_units,
       total_qty,
       packing_type_id,
       write_off_no_of_units,
       handled_as,
       internal_grd_ref_no,
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
       pcdi_id,
       process_id)
      select decode(internal_dgrd_ref_no,
                    'Empty_String',
                    null,
                    internal_dgrd_ref_no),
             decode(action_no, 'Empty_String', null, action_no),
             decode(internal_gmr_ref_no,
                    'Empty_String',
                    null,
                    internal_gmr_ref_no),
             decode(int_alloc_group_id,
                    'Empty_String',
                    null,
                    int_alloc_group_id),
             decode(container_no, 'Empty_String', null, container_no),
             decode(seal_no, 'Empty_String', null, seal_no),
             decode(mark_no, 'Empty_String', null, mark_no),
             decode(release_shipped_no_of_units,
                    'Empty_String',
                    null,
                    release_shipped_no_of_units),
             decode(status, 'Empty_String', null, status),
             decode(old_net_weight, 'Empty_String', null, old_net_weight),
             decode(gross_weight, 'Empty_String', null, gross_weight),
             decode(tare_weight, 'Empty_String', null, tare_weight),
             decode(net_weight, 'Empty_String', null, net_weight),
             decode(net_weight_unit_id,
                    'Empty_String',
                    null,
                    net_weight_unit_id),
             decode(bl_date, 'Empty_String', null, bl_date),
             decode(bl_number, 'Empty_String', null, bl_number),
             decode(shed_id, 'Empty_String', null, shed_id),
             decode(realized_qty, 'Empty_String', null, realized_qty),
             decode(parent_dgrd_ref_no,
                    'Empty_String',
                    null,
                    parent_dgrd_ref_no),
             decode(internal_stock_ref_no,
                    'Empty_String',
                    null,
                    internal_stock_ref_no),
             decode(warehouse_profile_id,
                    'Empty_String',
                    null,
                    warehouse_profile_id),
             decode(warehouse_receipt_no,
                    'Empty_String',
                    null,
                    warehouse_receipt_no),
             decode(warehouse_receipt_date,
                    'Empty_String',
                    null,
                    warehouse_receipt_date),
             decode(is_final_weight, 'Empty_String', null, is_final_weight),
             decode(bank_id, 'Empty_String', null, bank_id),
             decode(bank_account_id, 'Empty_String', null, bank_account_id),
             decode(inventory_status,
                    'Empty_String',
                    null,
                    inventory_status),
             decode(is_afloat, 'Empty_String', null, is_afloat),
             decode(crop_year_id, 'Empty_String', null, crop_year_id),
             decode(current_qty, 'Empty_String', null, current_qty),
             decode(internal_contract_item_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_item_ref_no),
             decode(is_weight_final, 'Empty_String', null, is_weight_final),
             decode(origin_id, 'Empty_String', null, origin_id),
             decode(packing_size_id, 'Empty_String', null, packing_size_id),
             decode(product_id, 'Empty_String', null, product_id),
             decode(product_specs, 'Empty_String', null, product_specs),
             decode(quality_id, 'Empty_String', null, quality_id),
             decode(write_off_qty, 'Empty_String', null, write_off_qty),
             decode(is_write_off, 'Empty_String', null, is_write_off),
             decode(internal_action_ref_no,
                    'Empty_String',
                    null,
                    internal_action_ref_no),
             decode(realized_status, 'Empty_String', null, realized_status),
             decode(realized_date, 'Empty_String', null, realized_date),
             to_timestamp(decode(realized_creation_date,
                                 'Empty_String',
                                 null,
                                 realized_creation_date),
                          'yyyy-mm-dd hh24:mi:ss.FF'),
             decode(stock_status, 'Empty_String', null, stock_status),
             decode(item_price, 'Empty_String', null, item_price),
             decode(item_price_unit, 'Empty_String', null, item_price_unit),
             decode(current_no_of_units,
                    'Empty_String',
                    null,
                    current_no_of_units),
             decode(total_no_of_units,
                    'Empty_String',
                    null,
                    total_no_of_units),
             decode(no_of_units, 'Empty_String', null, no_of_units),
             decode(total_qty, 'Empty_String', null, total_qty),
             decode(packing_type_id, 'Empty_String', null, packing_type_id),
             decode(write_off_no_of_units,
                    'Empty_String',
                    null,
                    write_off_no_of_units),
             decode(handled_as, 'Empty_String', null, handled_as),
             decode(internal_grd_ref_no,
                    'Empty_String',
                    null,
                    internal_grd_ref_no),
             decode(stock_condition, 'Empty_String', null, stock_condition),
             decode(gravity_type_id, 'Empty_String', null, gravity_type_id),
             
             decode(gravity, 'Empty_String', null, gravity),
             decode(density_mass_qty_unit_id,
                    'Empty_String',
                    null,
                    density_mass_qty_unit_id),
             decode(density_volume_qty_unit_id,
                    'Empty_String',
                    null,
                    density_volume_qty_unit_id),
             decode(gravity_type, 'Empty_String', null, gravity_type),
             decode(customs_id, 'Empty_String', null, customs_id),
             decode(tax_id, 'Empty_String', null, tax_id),
             decode(duty_id, 'Empty_String', null, duty_id),
             decode(phy_attribute_group_no,
                    'Empty_String',
                    null,
                    phy_attribute_group_no),
             decode(assay_header_id, 'Empty_String', null, assay_header_id),
             decode(customer_seal_no,
                    'Empty_String',
                    null,
                    customer_seal_no),
             decode(brand, 'Empty_String', null, brand),
             decode(no_of_bags, 'Empty_String', null, no_of_bags),
             decode(no_of_containers,
                    'Empty_String',
                    null,
                    no_of_containers),
             decode(no_of_pieces, 'Empty_String', null, no_of_pieces),
             decode(p_shipped_net_weight,
                    'Empty_String',
                    null,
                    p_shipped_net_weight),
             decode(p_shipped_gross_weight,
                    'Empty_String',
                    null,
                    p_shipped_gross_weight),
             decode(p_shipped_tare_weight,
                    'Empty_String',
                    null,
                    p_shipped_tare_weight),
             decode(sdcts_id, 'Empty_String', null, sdcts_id),
             decode(partnership_type,
                    'Empty_String',
                    null,
                    partnership_type),
             decode(profit_center_id,
                    'Empty_String',
                    null,
                    profit_center_id),
             decode(strategy_id, 'Empty_String', null, strategy_id),
             decode(is_warrant, 'Empty_String', null, is_warrant),
             decode(warrant_no, 'Empty_String', null, warrant_no),
             gvc_dbd_id,
             decode(tolling_stock_type, 'Empty_String', null, tolling_stock_type),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             pkg_phy_populate_data.gvc_process_id
        from (select dgrdul.internal_dgrd_ref_no,
                     substr(max(case
                                  when dgrdul.action_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.action_no
                                end),
                            24) action_no,
                     substr(max(case
                                  when dgrdul.internal_gmr_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.internal_gmr_ref_no
                                end),
                            24) internal_gmr_ref_no,
                     substr(max(case
                                  when dgrdul.int_alloc_group_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.int_alloc_group_id
                                end),
                            24) int_alloc_group_id,
                     substr(max(case
                                  when dgrdul.container_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.container_no
                                end),
                            24) container_no,
                     substr(max(case
                                  when dgrdul.seal_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.seal_no
                                end),
                            24) seal_no,
                     substr(max(case
                                  when dgrdul.mark_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.mark_no
                                end),
                            24) mark_no,
                     substr(max(case
                                  when dgrdul.release_shipped_no_of_units is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.release_shipped_no_of_units
                                end),
                            24) release_shipped_no_of_units,
                     substr(max(case
                                  when dgrdul.status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.status
                                end),
                            24) status,
                     substr(max(case
                                  when dgrdul.old_net_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.old_net_weight
                                end),
                            24) old_net_weight,
                     substr(max(case
                                  when dgrdul.gross_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.gross_weight
                                end),
                            24) gross_weight,
                     substr(max(case
                                  when dgrdul.tare_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.tare_weight
                                end),
                            24) tare_weight,
                     substr(max(case
                                  when dgrdul.net_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.net_weight
                                end),
                            24) net_weight,
                     substr(max(case
                                  when dgrdul.net_weight_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.net_weight_unit_id
                                end),
                            24) net_weight_unit_id,
                     substr(max(case
                                  when dgrdul.bl_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.bl_date
                                end),
                            24) bl_date,
                     substr(max(case
                                  when dgrdul.bl_number is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.bl_number
                                end),
                            24) bl_number,
                     substr(max(case
                                  when dgrdul.shed_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.shed_id
                                end),
                            24) shed_id,
                     substr(max(case
                                  when dgrdul.realized_qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.realized_qty
                                end),
                            24) realized_qty,
                     substr(max(case
                                  when dgrdul.parent_dgrd_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.parent_dgrd_ref_no
                                end),
                            24) parent_dgrd_ref_no,
                     substr(max(case
                                  when dgrdul.internal_stock_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.internal_stock_ref_no
                                end),
                            24) internal_stock_ref_no,
                     substr(max(case
                                  when dgrdul.warehouse_profile_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.warehouse_profile_id
                                end),
                            24) warehouse_profile_id,
                     substr(max(case
                                  when dgrdul.warehouse_receipt_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.warehouse_receipt_no
                                end),
                            24) warehouse_receipt_no,
                     substr(max(case
                                  when dgrdul.warehouse_receipt_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.warehouse_receipt_date
                                end),
                            24) warehouse_receipt_date,
                     substr(max(case
                                  when dgrdul.is_final_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.is_final_weight
                                end),
                            24) is_final_weight,
                     substr(max(case
                                  when dgrdul.bank_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.bank_id
                                end),
                            24) bank_id,
                     substr(max(case
                                  when dgrdul.bank_account_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.bank_account_id
                                end),
                            24) bank_account_id,
                     
                     substr(max(case
                                  when dgrdul.inventory_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.inventory_status
                                end),
                            24) inventory_status,
                     substr(max(case
                                  when dgrdul.is_afloat is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.is_afloat
                                end),
                            24) is_afloat,
                     
                     substr(max(case
                                  when dgrdul.crop_year_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.crop_year_id
                                end),
                            24) crop_year_id,
                     substr(max(case
                                  when dgrdul.current_qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.current_qty
                                end),
                            24) current_qty,
                     
                     substr(max(case
                                  when dgrdul.internal_contract_item_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.internal_contract_item_ref_no
                                end),
                            24) internal_contract_item_ref_no,
                     substr(max(case
                                  when dgrdul.is_weight_final is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.is_weight_final
                                end),
                            24) is_weight_final,
                     substr(max(case
                                  when dgrdul.origin_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.origin_id
                                end),
                            24) origin_id,
                     substr(max(case
                                  when dgrdul.packing_size_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.packing_size_id
                                end),
                            24) packing_size_id,
                     substr(max(case
                                  when dgrdul.product_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.product_id
                                end),
                            24) product_id,
                     substr(max(case
                                  when dgrdul.product_specs is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.product_specs
                                end),
                            24) product_specs,
                     substr(max(case
                                  when dgrdul.quality_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.quality_id
                                end),
                            24) quality_id,
                     substr(max(case
                                  when dgrdul.write_off_qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.write_off_qty
                                end),
                            24) write_off_qty,
                     substr(max(case
                                  when dgrdul.is_write_off is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.is_write_off
                                end),
                            24) is_write_off,
                     substr(max(case
                                  when dgrdul.internal_action_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.internal_action_ref_no
                                end),
                            24) internal_action_ref_no,
                     substr(max(case
                                  when dgrdul.realized_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.realized_status
                                end),
                            24) realized_status,
                     substr(max(case
                                  when dgrdul.realized_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.realized_date
                                end),
                            24) realized_date,
                     substr(max(case
                                  when dgrdul.realized_creation_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.realized_creation_date
                                end),
                            24) realized_creation_date,
                     substr(max(case
                                  when dgrdul.stock_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.stock_status
                                end),
                            24) stock_status,
                     substr(max(case
                                  when dgrdul.item_price is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.item_price
                                end),
                            24) item_price,
                     substr(max(case
                                  when dgrdul.item_price_unit is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.item_price_unit
                                end),
                            24) item_price_unit,
                     substr(max(case
                                  when dgrdul.current_no_of_units is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.current_no_of_units
                                end),
                            24) current_no_of_units,
                     substr(max(case
                                  when dgrdul.total_no_of_units is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.total_no_of_units
                                end),
                            24) total_no_of_units,
                     substr(max(case
                                  when dgrdul.no_of_units is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.no_of_units
                                end),
                            24) no_of_units,
                     substr(max(case
                                  when dgrdul.total_qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.total_qty
                                end),
                            24) total_qty,
                     substr(max(case
                                  when dgrdul.packing_type_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.packing_type_id
                                end),
                            24) packing_type_id,
                     substr(max(case
                                  when dgrdul.write_off_no_of_units is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.write_off_no_of_units
                                end),
                            24) write_off_no_of_units,
                     substr(max(case
                                  when dgrdul.handled_as is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.handled_as
                                end),
                            24) handled_as,
                     substr(max(case
                                  when dgrdul.internal_grd_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.internal_grd_ref_no
                                end),
                            24) internal_grd_ref_no,
                     substr(max(case
                                  when dgrdul.stock_condition is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.stock_condition
                                end),
                            24) stock_condition,
                     substr(max(case
                                  when dgrdul.gravity_type_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.gravity_type_id
                                end),
                            24) gravity_type_id,
                     substr(max(case
                                  when dgrdul.gravity is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.gravity
                                end),
                            24) gravity,
                     substr(max(case
                                  when dgrdul.density_mass_qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.density_mass_qty_unit_id
                                end),
                            24) density_mass_qty_unit_id,
                     substr(max(case
                                  when dgrdul.density_volume_qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.density_volume_qty_unit_id
                                end),
                            24) density_volume_qty_unit_id,
                     substr(max(case
                                  when dgrdul.gravity_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.gravity_type
                                end),
                            24) gravity_type,
                     substr(max(case
                                  when dgrdul.customs_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.customs_id
                                end),
                            24) customs_id,
                     substr(max(case
                                  when dgrdul.tax_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.tax_id
                                end),
                            24) tax_id,
                     substr(max(case
                                  when dgrdul.duty_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.duty_id
                                end),
                            24) duty_id,
                     substr(max(case
                                  when dgrdul.phy_attribute_group_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.phy_attribute_group_no
                                end),
                            24) phy_attribute_group_no,
                     substr(max(case
                                  when dgrdul.assay_header_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.assay_header_id
                                end),
                            24) assay_header_id,
                     substr(max(case
                                  when dgrdul.customer_seal_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.customer_seal_no
                                end),
                            24) customer_seal_no,
                     substr(max(case
                                  when dgrdul.brand is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.brand
                                end),
                            24) brand,
                     substr(max(case
                                  when dgrdul.no_of_bags is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.no_of_bags
                                end),
                            24) no_of_bags,
                     substr(max(case
                                  when dgrdul.no_of_containers is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.no_of_containers
                                end),
                            24) no_of_containers,
                     substr(max(case
                                  when dgrdul.no_of_pieces is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.no_of_pieces
                                end),
                            24) no_of_pieces,
                     substr(max(case
                                  when dgrdul.p_shipped_net_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.p_shipped_net_weight
                                end),
                            24) p_shipped_net_weight,
                     substr(max(case
                                  when dgrdul.p_shipped_gross_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.p_shipped_gross_weight
                                end),
                            24) p_shipped_gross_weight,
                     substr(max(case
                                  when dgrdul.p_shipped_tare_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.p_shipped_tare_weight
                                end),
                            24) p_shipped_tare_weight,
                     substr(max(case
                                  when dgrdul.sdcts_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.sdcts_id
                                end),
                            24) sdcts_id,
                     substr(max(case
                                  when dgrdul.partnership_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.partnership_type
                                end),
                            24) partnership_type,
                     substr(max(case
                                  when dgrdul.profit_center_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.profit_center_id
                                end),
                            24) profit_center_id,
                     substr(max(case
                                  when dgrdul.strategy_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.strategy_id
                                end),
                            24) strategy_id,
                     substr(max(case
                                  when dgrdul.is_warrant is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.is_warrant
                                end),
                            24) is_warrant,
                     substr(max(case
                                  when dgrdul.warrant_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.warrant_no
                                end),
                            24) warrant_no,
                     gvc_dbd_id,
                     substr(max(case
                                  when dgrdul.tolling_stock_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.tolling_stock_type
                                end),
                            24) tolling_stock_type,
                     substr(max(case
                                  when dgrdul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dgrdul.pcdi_id
                                end),
                            24) pcdi_id
                from dgrdul_delivered_grd_ul dgrdul,
                     axs_action_summary      axs,
                     dbd_database_dump       dbd_ul
               where axs.process = gvc_process
                 and dgrdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and dgrdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by dgrdul.internal_dgrd_ref_no) t;
    --
    -- Update Payment Due Date From Contract
    --
    update dgrd_delivered_grd dgrd
       set dgrd.payment_due_date = (select pcdi.payment_due_date
                                      from pci_physical_contract_item pci,
                                           pcdi_pc_delivery_item      pcdi
                                     where pcdi.pcdi_id = pci.pcdi_id
                                       and pcdi.dbd_id = pci.dbd_id
                                       and pcdi.dbd_id = gvc_dbd_id
                                       and pci.internal_contract_item_ref_no =
                                           dgrd.internal_contract_item_ref_no
                                       and dgrd.dbd_id = gvc_dbd_id)
     where dgrd.dbd_id = gvc_dbd_id;
    update dgrd_delivered_grd dgrd
       set dgrd.payment_due_date = pd_trade_date
     where dgrd.dbd_id = gvc_dbd_id
       and dgrd.payment_due_date is null;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_dgrd_data',
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

  procedure sp_phy_create_gmr_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2,
                                   pc_previous_year_eom_id varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
  delete from process_gmr where corporate_id = pc_corporate_id;
  commit;
insert into process_gmr
  (internal_gmr_ref_no,
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
   internal_action_ref_no,
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
   wns_status,
   base_conc_mix_type,
   dbd_id,
   process_id)
  select decode(internal_gmr_ref_no,
                'Empty_String',
                null,
                internal_gmr_ref_no),
         decode(gmr_ref_no, 'Empty_String', null, gmr_ref_no),
         decode(gmr_first_int_action_ref_no,
                'Empty_String',
                null,
                gmr_first_int_action_ref_no),
         decode(internal_contract_ref_no,
                'Empty_String',
                null,
                internal_contract_ref_no),
         decode(gmr_latest_action_action_id,
                'Empty_String',
                null,
                gmr_latest_action_action_id),
         decode(corporate_id, 'Empty_String', null, corporate_id),
         decode(created_by, 'Empty_String', null, created_by),
         decode(created_date, 'Empty_String', null, created_date),
         decode(contract_type, 'Empty_String', null, contract_type),
         decode(status_id, 'Empty_String', null, status_id),
         decode(qty, 'Empty_String', null, qty),
         decode(current_qty, 'Empty_String', null, current_qty),
         decode(qty_unit_id, 'Empty_String', null, qty_unit_id),
         decode(no_of_units, 'Empty_String', null, no_of_units),
         decode(current_no_of_units,
                'Empty_String',
                null,
                current_no_of_units),
         decode(shipped_qty,
                'Empty_String',
                null,
                shipped_qty),
         decode(landed_qty, 'Empty_String', null, landed_qty),
         decode(weighed_qty, 'Empty_String', null, weighed_qty),
         decode(plan_ship_qty, 'Empty_String', null, plan_ship_qty),
         decode(released_qty, 'Empty_String', null, released_qty),
         decode(bl_no, 'Empty_String', null, bl_no),
         decode(trucking_receipt_no,
                'Empty_String',
                null,
                trucking_receipt_no),
         decode(rail_receipt_no, 'Empty_String', null, rail_receipt_no),
         decode(bl_date, 'Empty_String', null, bl_date),
         decode(trucking_receipt_date,
                'Empty_String',
                null,
                trucking_receipt_date),
         decode(rail_receipt_date, 'Empty_String', null, rail_receipt_date),
         decode(warehouse_receipt_no,
                'Empty_String',
                null,
                warehouse_receipt_no),
         decode(origin_city_id, 'Empty_String', null, origin_city_id),
         decode(origin_country_id, 'Empty_String', null, origin_country_id),
         decode(destination_city_id,
                'Empty_String',
                null,
                destination_city_id),
         decode(destination_country_id,
                'Empty_String',
                null,
                destination_country_id),
         decode(loading_country_id,
                'Empty_String',
                null,
                loading_country_id),
         decode(loading_port_id, 'Empty_String', null, loading_port_id),
         decode(discharge_country_id,
                'Empty_String',
                null,
                discharge_country_id),
         decode(discharge_port_id, 'Empty_String', null, discharge_port_id),
         decode(trans_port_id, 'Empty_String', null, trans_port_id),
         decode(trans_country_id, 'Empty_String', null, trans_country_id),
         decode(warehouse_profile_id,
                'Empty_String',
                null,
                warehouse_profile_id),
         decode(shed_id, 'Empty_String', null, shed_id),
         decode(shipping_line_profile_id,
                'Empty_String',
                null,
                shipping_line_profile_id),
         decode(controller_profile_id,
                'Empty_String',
                null,
                controller_profile_id),
         decode(vessel_name, 'Empty_String', null, vessel_name),
         decode(eff_date, 'Empty_String', null, eff_date),
         decode(inventory_no, 'Empty_String', null, inventory_no),
         decode(inventory_status, 'Empty_String', null, inventory_status),
         decode(inventory_in_date, 'Empty_String', null, inventory_in_date),
         decode(inventory_out_date,
                'Empty_String',
                null,
                inventory_out_date),
         decode(is_final_weight, 'Empty_String', null, is_final_weight),
         decode(final_weight, 'Empty_String', null, final_weight),
         decode(sales_int_alloc_group_id,
                'Empty_String',
                null,
                sales_int_alloc_group_id),
         decode(is_internal_movement,
                'Empty_String',
                null,
                is_internal_movement),
         decode(is_deleted, 'Empty_String', null, is_deleted),
         decode(is_voyage_gmr, 'Empty_String', null, is_voyage_gmr),
         decode(loaded_qty, 'Empty_String', null, loaded_qty),
         decode(discharged_qty, 'Empty_String', null, discharged_qty),
         decode(voyage_alloc_qty, 'Empty_String', null, voyage_alloc_qty),
         decode(fulfilled_qty, 'Empty_String', null, fulfilled_qty),
         decode(voyage_status, 'Empty_String', null, voyage_status),
         decode(tt_in_qty, 'Empty_String', null, tt_in_qty),
         decode(tt_out_qty, 'Empty_String', null, tt_out_qty),
         decode(tt_under_cma_qty, 'Empty_String', null, tt_under_cma_qty),
         decode(tt_none_qty, 'Empty_String', null, tt_none_qty),
         decode(moved_out_qty, 'Empty_String', null, moved_out_qty),
         decode(is_settlement_gmr, 'Empty_String', null, is_settlement_gmr),
         decode(write_off_qty, 'Empty_String', null, write_off_qty),
         decode(internal_action_ref_no,
                'Empty_String',
                null,
                internal_action_ref_no),
         decode(gravity_type_id, 'Empty_String', null, gravity_type_id),
         decode(gravity, 'Empty_String', null, gravity),
         decode(density_mass_qty_unit_id,
                'Empty_String',
                null,
                density_mass_qty_unit_id),
         decode(density_volume_qty_unit_id,
                'Empty_String',
                null,
                density_volume_qty_unit_id),
         decode(gravity_type, 'Empty_String', null, gravity_type),
         decode(loading_state_id, 'Empty_String', null, loading_state_id),
         decode(loading_city_id, 'Empty_String', null, loading_city_id),
         decode(trans_state_id, 'Empty_String', null, trans_state_id),
         decode(trans_city_id, 'Empty_String', null, trans_city_id),
         decode(discharge_state_id,
                'Empty_String',
                null,
                discharge_state_id),
         decode(discharge_city_id, 'Empty_String', null, discharge_city_id),
         decode(place_of_receipt_country_id,
                'Empty_String',
                null,
                place_of_receipt_country_id),
         decode(place_of_receipt_state_id,
                'Empty_String',
                null,
                place_of_receipt_state_id),
         decode(place_of_receipt_city_id,
                'Empty_String',
                null,
                place_of_receipt_city_id),
         decode(place_of_delivery_country_id,
                'Empty_String',
                null,
                place_of_delivery_country_id),
         decode(place_of_delivery_state_id,
                'Empty_String',
                null,
                place_of_delivery_state_id),
         decode(place_of_delivery_city_id,
                'Empty_String',
                null,
                place_of_delivery_city_id),
         decode(tolling_qty, 'Empty_String', null, tolling_qty),
         decode(tolling_gmr_type, 'Empty_String', null, tolling_gmr_type),
         decode(pool_id, 'Empty_String', null, pool_id),
         decode(is_warrant, 'Empty_String', null, is_warrant),
         decode(is_pass_through, 'Empty_String', null, is_pass_through),
         decode(pledge_input_gmr, 'Empty_String', null, pledge_input_gmr),
         decode(is_apply_freight_allowance,
                'Empty_String',
                null,
                is_apply_freight_allowance),
         decode(is_apply_container_charge,
                'Empty_String',
                null,
                is_apply_container_charge),
         decode(mode_of_transport, 'Empty_String', null, mode_of_transport) mode_of_transport,
         decode(wns_status, 'Empty_String', null, wns_status) wns_status,
         decode(base_conc_mix_type, 'Empty_String', null, base_conc_mix_type) base_conc_mix_type,
         gvc_dbd_id,
         gvc_process_id
    from (select gmrul.internal_gmr_ref_no,
                 substr(max(case
                              when gmrul.gmr_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.gmr_ref_no
                            end),
                        24) gmr_ref_no,
                 substr(max(case
                              when gmrul.gmr_first_int_action_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.gmr_first_int_action_ref_no
                            end),
                        24) gmr_first_int_action_ref_no,
                 substr(max(case
                              when gmrul.internal_contract_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.internal_contract_ref_no
                            end),
                        24) internal_contract_ref_no,
                 substr(max(case
                              when gmrul.gmr_latest_action_action_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.gmr_latest_action_action_id
                            end),
                        24) gmr_latest_action_action_id,
                 substr(max(case
                              when gmrul.corporate_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.corporate_id
                            end),
                        24) corporate_id,
                 substr(max(case
                              when gmrul.created_by is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.created_by
                            end),
                        24) created_by,
                 
                 pd_trade_date created_date,
                 substr(max(case
                              when gmrul.contract_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.contract_type
                            end),
                        24) contract_type,
                 substr(max(case
                              when gmrul.status_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.status_id
                            end),
                        24) status_id,
                 substr(max(case
                              when gmrul.qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.qty
                            end),
                        24) qty,
                 substr(max(case
                              when gmrul.current_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.current_qty
                            end),
                        24) current_qty,
                 substr(max(case
                              when gmrul.qty_unit_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.qty_unit_id
                            end),
                        24) qty_unit_id,
                 substr(max(case
                              when gmrul.no_of_units is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.no_of_units
                            end),
                        24) no_of_units,
                 substr(max(case
                              when gmrul.current_no_of_units is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.current_no_of_units
                            end),
                        24) current_no_of_units,
                 substr(max(case
                              when gmrul.shipped_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.shipped_qty
                            end),
                        24) shipped_qty,
                 substr(max(case
                              when gmrul.landed_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.landed_qty
                            end),
                        24) landed_qty,
                 substr(max(case
                              when gmrul.weighed_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.weighed_qty
                            end),
                        24) weighed_qty,
                 substr(max(case
                              when gmrul.plan_ship_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.plan_ship_qty
                            end),
                        24) plan_ship_qty,
                 substr(max(case
                              when gmrul.released_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.released_qty
                            end),
                        24) released_qty,
                 substr(max(case
                              when gmrul.bl_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.bl_no
                            end),
                        24) bl_no,
                 substr(max(case
                              when gmrul.trucking_receipt_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.trucking_receipt_no
                            end),
                        24) trucking_receipt_no,
                 substr(max(case
                              when gmrul.rail_receipt_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.rail_receipt_no
                            end),
                        24) rail_receipt_no,
                 substr(max(case
                              when gmrul.bl_date is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.bl_date
                            end),
                        24) bl_date,
                 substr(max(case
                              when gmrul.trucking_receipt_date is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.trucking_receipt_date
                            end),
                        24) trucking_receipt_date,
                 substr(max(case
                              when gmrul.rail_receipt_date is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.rail_receipt_date
                            end),
                        24) rail_receipt_date,
                 substr(max(case
                              when gmrul.warehouse_receipt_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.warehouse_receipt_no
                            end),
                        24) warehouse_receipt_no,
                 substr(max(case
                              when gmrul.origin_city_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.origin_city_id
                            end),
                        24) origin_city_id,
                 substr(max(case
                              when gmrul.origin_country_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.origin_country_id
                            end),
                        24) origin_country_id,
                 substr(max(case
                              when gmrul.destination_city_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.destination_city_id
                            end),
                        24) destination_city_id,
                 substr(max(case
                              when gmrul.destination_country_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.destination_country_id
                            end),
                        24) destination_country_id,
                 substr(max(case
                              when gmrul.loading_country_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.loading_country_id
                            end),
                        24) loading_country_id,
                 substr(max(case
                              when gmrul.loading_port_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.loading_port_id
                            end),
                        24) loading_port_id,
                 substr(max(case
                              when gmrul.discharge_country_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.discharge_country_id
                            end),
                        24) discharge_country_id,
                 substr(max(case
                              when gmrul.discharge_port_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.discharge_port_id
                            end),
                        24) discharge_port_id,
                 substr(max(case
                              when gmrul.trans_port_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.trans_port_id
                            end),
                        24) trans_port_id,
                 substr(max(case
                              when gmrul.trans_country_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.trans_country_id
                            end),
                        24) trans_country_id,
                 substr(max(case
                              when gmrul.warehouse_profile_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.warehouse_profile_id
                            end),
                        24) warehouse_profile_id,
                 substr(max(case
                              when gmrul.shed_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.shed_id
                            end),
                        24) shed_id,
                 substr(max(case
                              when gmrul.shipping_line_profile_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.shipping_line_profile_id
                            end),
                        24) shipping_line_profile_id,
                 substr(max(case
                              when gmrul.controller_profile_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.controller_profile_id
                            end),
                        24) controller_profile_id,
                 substr(max(case
                              when gmrul.vessel_name is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.vessel_name
                            end),
                        24) vessel_name,
                 substr(max(case
                              when gmrul.eff_date is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.eff_date
                            end),
                        24) eff_date,
                 substr(max(case
                              when gmrul.inventory_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.inventory_no
                            end),
                        24) inventory_no,
                 substr(max(case
                              when gmrul.inventory_status is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.inventory_status
                            end),
                        24) inventory_status,
                 substr(max(case
                              when gmrul.inventory_in_date is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.inventory_in_date
                            end),
                        24) inventory_in_date,
                 substr(max(case
                              when gmrul.inventory_out_date is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.inventory_out_date
                            end),
                        24) inventory_out_date,
                 substr(max(case
                              when gmrul.is_final_weight is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_final_weight
                            end),
                        24) is_final_weight,
                 substr(max(case
                              when gmrul.final_weight is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.final_weight
                            end),
                        24) final_weight,
                 substr(max(case
                              when gmrul.sales_int_alloc_group_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.sales_int_alloc_group_id
                            end),
                        24) sales_int_alloc_group_id,
                 substr(max(case
                              when gmrul.is_internal_movement is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_internal_movement
                            end),
                        24) is_internal_movement,
                 substr(max(case
                              when gmrul.is_deleted is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_deleted
                            end),
                        24) is_deleted,
                 substr(max(case
                              when gmrul.is_voyage_gmr is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_voyage_gmr
                            end),
                        24) is_voyage_gmr,
                 substr(max(case
                              when gmrul.loaded_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.loaded_qty
                            end),
                        24) loaded_qty,
                 substr(max(case
                              when gmrul.discharged_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.discharged_qty
                            end),
                        24) discharged_qty,
                 substr(max(case
                              when gmrul.voyage_alloc_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.voyage_alloc_qty
                            end),
                        24) voyage_alloc_qty,
                 substr(max(case
                              when gmrul.fulfilled_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.fulfilled_qty
                            end),
                        24) fulfilled_qty,
                 substr(max(case
                              when gmrul.voyage_status is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.voyage_status
                            end),
                        24) voyage_status,
                 substr(max(case
                              when gmrul.tt_in_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.tt_in_qty
                            end),
                        24) tt_in_qty,
                 substr(max(case
                              when gmrul.tt_out_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.tt_out_qty
                            end),
                        24) tt_out_qty,
                 substr(max(case
                              when gmrul.tt_under_cma_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.tt_under_cma_qty
                            end),
                        24) tt_under_cma_qty,
                 substr(max(case
                              when gmrul.tt_none_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.tt_none_qty
                            end),
                        24) tt_none_qty,
                 substr(max(case
                              when gmrul.moved_out_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.moved_out_qty
                            end),
                        24) moved_out_qty,
                 substr(max(case
                              when gmrul.is_settlement_gmr is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_settlement_gmr
                            end),
                        24) is_settlement_gmr,
                 substr(max(case
                              when gmrul.write_off_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.write_off_qty
                            end),
                        24) write_off_qty,
                 substr(max(case
                              when gmrul.internal_action_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.internal_action_ref_no
                            end),
                        24) internal_action_ref_no,
                 substr(max(case
                              when gmrul.gravity_type_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.gravity_type_id
                            end),
                        24) gravity_type_id,
                 substr(max(case
                              when gmrul.gravity is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.gravity
                            end),
                        24) gravity,
                 substr(max(case
                              when gmrul.density_mass_qty_unit_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.density_mass_qty_unit_id
                            end),
                        24) density_mass_qty_unit_id,
                 substr(max(case
                              when gmrul.density_volume_qty_unit_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.density_volume_qty_unit_id
                            end),
                        24) density_volume_qty_unit_id,
                 substr(max(case
                              when gmrul.gravity_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.gravity_type
                            end),
                        24) gravity_type,
                 substr(max(case
                              when gmrul.loading_state_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.loading_state_id
                            end),
                        24) loading_state_id,
                 substr(max(case
                              when gmrul.loading_city_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.loading_city_id
                            end),
                        24) loading_city_id,
                 substr(max(case
                              when gmrul.trans_state_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.trans_state_id
                            end),
                        24) trans_state_id,
                 substr(max(case
                              when gmrul.trans_city_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.trans_city_id
                            end),
                        24) trans_city_id,
                 substr(max(case
                              when gmrul.discharge_state_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.discharge_state_id
                            end),
                        24) discharge_state_id,
                 substr(max(case
                              when gmrul.discharge_city_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.discharge_city_id
                            end),
                        24) discharge_city_id,
                 substr(max(case
                              when gmrul.place_of_receipt_country_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.place_of_receipt_country_id
                            end),
                        24) place_of_receipt_country_id,
                 substr(max(case
                              when gmrul.place_of_receipt_state_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.place_of_receipt_state_id
                            end),
                        24) place_of_receipt_state_id,
                 substr(max(case
                              when gmrul.place_of_receipt_city_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.place_of_receipt_city_id
                            end),
                        24) place_of_receipt_city_id,
                 substr(max(case
                              when gmrul.place_of_delivery_country_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.place_of_delivery_country_id
                            end),
                        24) place_of_delivery_country_id,
                 substr(max(case
                              when gmrul.place_of_delivery_state_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.place_of_delivery_state_id
                            end),
                        24) place_of_delivery_state_id,
                 substr(max(case
                              when gmrul.place_of_delivery_city_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.place_of_delivery_city_id
                            end),
                        24) place_of_delivery_city_id,
                 substr(max(case
                              when gmrul.tolling_qty is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.tolling_qty
                            end),
                        24) tolling_qty,
                 substr(max(case
                              when gmrul.tolling_gmr_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.tolling_gmr_type
                            end),
                        24) tolling_gmr_type,
                 substr(max(case
                              when gmrul.pool_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.pool_id
                            end),
                        24) pool_id,
                 substr(max(case
                              when gmrul.is_warrant is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_warrant
                            end),
                        24) is_warrant,
                 substr(max(case
                              when gmrul.is_pass_through is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_pass_through
                            end),
                        24) is_pass_through,
                 substr(max(case
                              when gmrul.pledge_input_gmr is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.pledge_input_gmr
                            end),
                        24) pledge_input_gmr,
                 substr(max(case
                              when gmrul.is_apply_freight_allowance is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_apply_freight_allowance
                            end),
                        24) is_apply_freight_allowance,
                 substr(max(case
                              when gmrul.is_apply_container_charge is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.is_apply_container_charge
                            end),
                        24) is_apply_container_charge,
                 substr(max(case
                              when gmrul.mode_of_transport is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.mode_of_transport
                            end),
                        24) mode_of_transport,
                 substr(max(case
                              when gmrul.wns_status is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.wns_status
                            end),
                        24) wns_status,
                 substr(max(case
                              when gmrul.base_conc_mix_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               gmrul.base_conc_mix_type
                            end),
                        24) base_conc_mix_type,                        
                 gvc_dbd_id
            from gmrul_gmr_ul       gmrul,
                 axs_action_summary axs,
                 dbd_database_dump  dbd_ul
           where axs.process = gvc_process
             and gmrul.internal_action_ref_no = axs.internal_action_ref_no
             and axs.eff_date <= pd_trade_date
             and axs.corporate_id = pc_corporate_id
             and gmrul.dbd_id = dbd_ul.dbd_id
             and dbd_ul.corporate_id = pc_corporate_id
             and dbd_ul.process = gvc_process
           group by gmrul.internal_gmr_ref_no) t;
--
-- Update FI AND PI Flag
--  
for cur_gmr_invoice in(        
SELECT   iid.internal_gmr_ref_no,
         CASE
            WHEN (SUM (CASE
                          WHEN is1.invoice_type_name = 'Final'
                           OR is1.invoice_type_name = 'DirectFinal'
                             THEN 1
                          ELSE 0
                       END
                      )
                 ) = 0
               THEN 'N'
            ELSE 'Y'
         END fi_done,
         CASE
            WHEN (SUM (CASE
                          WHEN is1.invoice_type_name = 'Provisional'
                             THEN 1
                          ELSE 0
                       END
                      )
                 ) = 0
               THEN 'N'
            ELSE 'Y'
         END pi_done,
         SUBSTR
            (MAX (   TO_CHAR (axs.created_date, 'yyyymmddhh24missff9')
                  || iam.internal_invoice_ref_no
                 ),
             24
            ) latest_internal_invoice_ref_no,
            SUBSTR
            (MAX (   TO_CHAR (axs.created_date, 'yyyymmddhh24missff9')
                  || is1.invoice_ref_no
                 ),
             24
            ) invoice_ref_no,
            SUBSTR
            (MAX (   TO_CHAR (axs.created_date, 'yyyymmddhh24missff9')
                  || is1.is_invoice_new
                 ),
             24
            ) is_invoice_new            
    FROM is_invoice_summary is1,
         iid_invoicable_item_details iid,
         iam_invoice_action_mapping@eka_appdb iam,
         axs_action_summary axs
   WHERE is1.is_active = 'Y'
     AND is1.invoice_type_name IN ('Final', 'Provisional', 'DirectFinal')
     AND is1.dbd_id = gvc_dbd_id
     AND is1.internal_invoice_ref_no = iid.internal_invoice_ref_no
     AND iam.internal_invoice_ref_no = is1.internal_invoice_ref_no
     AND iam.invoice_action_ref_no = axs.internal_action_ref_no
     AND NVL (is1.is_free_metal, 'N') <> 'Y'
GROUP BY iid.internal_gmr_ref_no)loop
update process_gmr gmr
   set gmr.is_provisional_invoiced        = cur_gmr_invoice.pi_done,
       gmr.is_final_invoiced              = cur_gmr_invoice.fi_done,
       gmr.latest_internal_invoice_ref_no = cur_gmr_invoice.latest_internal_invoice_ref_no,
       gmr.invoice_ref_no                 = cur_gmr_invoice.invoice_ref_no,
       gmr.is_new_final_invoice           = case when cur_gmr_invoice.fi_done = 'Y' and cur_gmr_invoice.is_invoice_new = 'Y' then 'Y' else 'N' end,
       gmr.is_new_invoice                 =  cur_gmr_invoice.is_invoice_new
 where gmr.dbd_id = gvc_dbd_id
   and gmr.internal_gmr_ref_no = cur_gmr_invoice.internal_gmr_ref_no;
end loop;
commit;
--- update debit credit note invoice details

for cur_gmr_invoice in(        
SELECT   iid.internal_gmr_ref_no,
        
         SUBSTR
            (MAX (   TO_CHAR (axs.created_date, 'yyyymmddhh24missff9')
                  || iam.internal_invoice_ref_no
                 ),
             24
            ) latest_internal_invoice_ref_no,           
         SUBSTR
            (MAX (   TO_CHAR (axs.created_date, 'yyyymmddhh24missff9')
                  || is1.is_invoice_new
                 ),
             24
            ) is_invoice_new           
    FROM is_invoice_summary is1,
         iid_invoicable_item_details iid,
         iam_invoice_action_mapping@eka_appdb iam,
         axs_action_summary axs
   WHERE is1.is_active = 'Y'
     AND is1.invoice_type_name ='DebitCredit'
     AND is1.dbd_id = gvc_dbd_id
     AND is1.internal_invoice_ref_no = iid.internal_invoice_ref_no
     AND iam.internal_invoice_ref_no = is1.internal_invoice_ref_no
     AND iam.invoice_action_ref_no = axs.internal_action_ref_no
     AND NVL (is1.is_free_metal, 'N') <> 'Y'
GROUP BY iid.internal_gmr_ref_no)loop
update process_gmr gmr   set 
       gmr.debit_credit_invoice_no = cur_gmr_invoice.latest_internal_invoice_ref_no,
       gmr.is_new_debit_credit_invoice=cur_gmr_invoice.is_invoice_new
 where gmr.dbd_id = gvc_dbd_id
   and gmr.internal_gmr_ref_no = cur_gmr_invoice.internal_gmr_ref_no;
end loop;
commit;
--- Added Suresh
   for cur_update in (select gmr.internal_gmr_ref_no,
                            gmr.is_final_invoiced
                       from gmr_goods_movement_record gmr
                      where gmr.process_id = pc_previous_year_eom_id
                        and gmr.is_final_invoiced = 'N')
  loop
    update process_gmr gmr
       set gmr.is_new_fi_ytd = 'Y'
     where gmr.is_final_invoiced = 'Y'
       and gmr.internal_gmr_ref_no = cur_update.internal_gmr_ref_no
       and gmr.corporate_id = pc_corporate_id;
  end loop;                   
commit;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_gmr_data',
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

  procedure sp_phy_create_mogrd_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    insert into mogrd_moved_out_grd
      (internal_gmr_ref_no,
       internal_grd_ref_no,
       pool_id,
       action_no,
       moved_out_qty,
       qty_unit_id,
       moved_out_no_of_units,
       status,
       tare_weight,
       gross_weight,
       dbd_id,
       process_id)
      select decode(internal_gmr_ref_no,
                    'Empty_String',
                    null,
                    internal_gmr_ref_no),
             decode(internal_grd_ref_no,
                    'Empty_String',
                    null,
                    internal_grd_ref_no),
             decode(pool_id, 'Empty_String', null, pool_id),
             decode(action_no, 'Empty_String', null, action_no),
             decode(moved_out_qty, 'Empty_String', null, moved_out_qty),
             decode(qty_unit_id, 'Empty_String', null, qty_unit_id),
             decode(moved_out_no_of_units,
                    'Empty_String',
                    null,
                    moved_out_no_of_units),
             decode(status, 'Empty_String', null, status),
             decode(tare_weight, 'Empty_String', null, tare_weight),
             decode(gross_weight, 'Empty_String', null, gross_weight),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select substr(max(case
                                  when mogrdul.internal_gmr_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.internal_gmr_ref_no
                                end),
                            24) internal_gmr_ref_no,
                     mogrdul.internal_grd_ref_no,
                     substr(max(case
                                  when mogrdul.pool_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.pool_id
                                end),
                            24) pool_id,
                     substr(max(case
                                  when mogrdul.action_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.action_no
                                end),
                            24) action_no,
                     substr(max(case
                                  when mogrdul.moved_out_qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.moved_out_qty
                                end),
                            24) moved_out_qty,
                     substr(max(case
                                  when mogrdul.qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.qty_unit_id
                                end),
                            24) qty_unit_id,
                     substr(max(case
                                  when mogrdul.moved_out_no_of_units is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.moved_out_no_of_units
                                end),
                            24) moved_out_no_of_units,
                     substr(max(case
                                  when mogrdul.status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.status
                                end),
                            24) status,
                     substr(max(case
                                  when mogrdul.tare_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.tare_weight
                                end),
                            24) tare_weight,
                     substr(max(case
                                  when mogrdul.gross_weight is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   mogrdul.gross_weight
                                end),
                            24) gross_weight,
                     gvc_dbd_id
                from mogrdul_moved_out_grd_ul mogrdul,
                     axs_action_summary       axs,
                     dbd_database_dump        dbd_ul
               where axs.process = gvc_process
                 and mogrdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and mogrdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by mogrdul.internal_grd_ref_no) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_mogrd_data',
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

  procedure sp_phy_create_pcad_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcad_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into pcad_pc_agency_detail
      (pcad_id,
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
       is_active,
       dbd_id,
       process_id)
      select decode(pcad_id, 'Empty_String', null, pcad_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(agency_cp_id, 'Empty_String', null, agency_cp_id),
             decode(commission_type, 'Empty_String', null, commission_type),
             decode(commission_value,
                    'Empty_String',
                    null,
                    commission_value),
             decode(commission_unit_id,
                    'Empty_String',
                    null,
                    commission_unit_id),
             decode(commission_formula_id,
                    'Empty_String',
                    null,
                    commission_formula_id),
             decode(basis_incoterm_id,
                    'Empty_String',
                    null,
                    basis_incoterm_id),
             decode(basis_country_id,
                    'Empty_String',
                    null,
                    basis_country_id),
             decode(basis_state_id, 'Empty_String', null, basis_state_id),
             decode(basis_city_id, 'Empty_String', null, basis_city_id),
             decode(is_parity_required,
                    'Empty_String',
                    null,
                    is_parity_required),
             decode(parity_value, 'Empty_String', null, parity_value),
             decode(comments, 'Empty_String', null, comments),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcadul.pcad_id,
                     substr(max(case
                                  when pcadul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcadul.agency_cp_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.agency_cp_id
                                end),
                            24) agency_cp_id,
                     substr(max(case
                                  when pcadul.commission_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.commission_type
                                end),
                            24) commission_type,
                     substr(max(case
                                  when pcadul.commission_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.commission_value
                                end),
                            24) commission_value,
                     substr(max(case
                                  when pcadul.commission_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.commission_unit_id
                                end),
                            24) commission_unit_id,
                     substr(max(case
                                  when pcadul.commission_formula_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.commission_formula_id
                                end),
                            24) commission_formula_id,
                     substr(max(case
                                  when pcadul.basis_incoterm_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.basis_incoterm_id
                                end),
                            24) basis_incoterm_id,
                     substr(max(case
                                  when pcadul.basis_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.basis_country_id
                                end),
                            24) basis_country_id,
                     substr(max(case
                                  when pcadul.basis_state_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.basis_state_id
                                end),
                            24) basis_state_id,
                     substr(max(case
                                  when pcadul.basis_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.basis_city_id
                                end),
                            24) basis_city_id,
                     substr(max(case
                                  when pcadul.is_parity_required is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.is_parity_required
                                end),
                            24) is_parity_required,
                     substr(max(case
                                  when pcadul.parity_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.parity_value
                                end),
                            24) parity_value,
                     substr(max(case
                                  when pcadul.comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.comments
                                end),
                            24) comments,
                     substr(max(case
                                  when pcadul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcadul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcadul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcadul_pc_agency_detail_ul pcadul,
                     axs_action_summary         axs,
                     dbd_database_dump          dbd_ul
               where axs.process = gvc_process
                 and pcadul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcadul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcadul.pcad_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcad_data',
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

  procedure sp_phy_create_pcbpd_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcbpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcbpd_pc_base_price_detail
      (pcbpd_id,
       element_id,
       price_basis,
       price_value,
       price_unit_id,
       tonnage_basis,
       pffxd_id,
       version,
       is_active,
       fx_to_base,
       qty_to_be_priced,
       pcbph_id,
       valuation_price_percentage,
       dbd_id,
       process_id)
      select decode(pcbpd_id, 'Empty_String', null, pcbpd_id),
             decode(element_id, 'Empty_String', null, element_id),
             decode(price_basis, 'Empty_String', null, price_basis),
             decode(price_value, 'Empty_String', null, price_value),
             decode(price_unit_id, 'Empty_String', null, price_unit_id),
             decode(tonnage_basis, 'Empty_String', null, tonnage_basis),
             decode(pffxd_id, 'Empty_String', null, pffxd_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(fx_to_base, 'Empty_String', null, fx_to_base),
             decode(qty_to_be_priced,
                    'Empty_String',
                    null,
                    qty_to_be_priced),
             decode(pcbph_id, 'Empty_String', null, pcbph_id),
             decode(valuation_price_percentage, 'Empty_String', null, valuation_price_percentage),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcbpdul.pcbpd_id,
                     substr(max(case
                                  when pcbpdul.element_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.element_id
                                end),
                            24) element_id,
                     substr(max(case
                                  when pcbpdul.price_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.price_basis
                                end),
                            24) price_basis,
                     substr(max(case
                                  when pcbpdul.price_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.price_value
                                end),
                            24) price_value,
                     substr(max(case
                                  when pcbpdul.price_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.price_unit_id
                                end),
                            24) price_unit_id,
                     substr(max(case
                                  when pcbpdul.tonnage_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.tonnage_basis
                                end),
                            24) tonnage_basis,
                     substr(max(case
                                  when pcbpdul.pffxd_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.pffxd_id
                                end),
                            24) pffxd_id,
                     substr(max(case
                                  when pcbpdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcbpdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcbpdul.fx_to_base is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.fx_to_base
                                end),
                            24) fx_to_base,
                     substr(max(case
                                  when pcbpdul.qty_to_be_priced is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.qty_to_be_priced
                                end),
                            24) qty_to_be_priced,
                     substr(max(case
                                  when pcbpdul.pcbph_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.pcbph_id
                                end),
                            24) pcbph_id,
                      substr(max(case
                                  when pcbpdul.valuation_price_percentage is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbpdul.valuation_price_percentage
                                end),
                            24) valuation_price_percentage,       
                     gvc_dbd_id
                from pcbpdul_pc_base_price_dtl_ul pcbpdul,
                     axs_action_summary           axs,
                     dbd_database_dump            dbd_ul
               where axs.process = gvc_process
                 and pcbpdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcbpdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcbpdul.pcbpd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcbpd_data',
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

  procedure sp_phy_create_pcbph_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcbpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcbph_pc_base_price_header
      (pcbph_id,
       version,
       is_active,
       internal_contract_ref_no,
       price_description,
       element_id,
       is_free_metal_applicable,
       valuation_price_percentage,
       is_balance_pricing,
       dbd_id,
       process_id)
      select decode(pcbph_id, 'Empty_String', null, pcbph_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(price_description,
                    'Empty_String',
                    null,
                    price_description),
             decode(element_id, 'Empty_String', null, element_id),
             decode(is_free_metal_applicable,
                    'Empty_String',
                    null,
                    is_free_metal_applicable),
                    nvl(valuation_price_percentage,100), 
                    nvl(is_balance_pricing,'N'), 
                    gvc_dbd_id,
                    pkg_phy_populate_data.gvc_process_id
        from (select pcbphul.pcbph_id,
                     substr(max(case
                                  when pcbphul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbphul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcbphul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbphul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcbphul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbphul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcbphul.price_description is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbphul.price_description
                                end),
                            24) price_description,
                     substr(max(case
                                  when pcbphul.element_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbphul.element_id
                                end),
                            24) element_id,
                     substr(max(case
                                  when pcbphul.is_free_metal_applicable is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbphul.is_free_metal_applicable
                                end),
                            24) is_free_metal_applicable,
                     substr(max(case
                                  when pcbphul.valuation_price_percentage is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbphul.valuation_price_percentage
                                end),
                            24) valuation_price_percentage,
                     substr(max(case
                                  when pcbphul.is_balance_pricing is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcbphul.is_balance_pricing
                                end),
                            24) is_balance_pricing,
                     gvc_dbd_id
                from pcbphul_pc_base_prc_header_ul pcbphul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pcbphul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcbphul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcbphul.pcbph_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcbph_data',
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

  procedure sp_phy_create_pcdb_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcdb_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcdb_pc_delivery_basis
      (pcdb_id,
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
       is_active,
       pffxd_id,
       dbd_id,
       process_id)
      select decode(pcdb_id, 'Empty_String', null, pcdb_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(inco_term_id, 'Empty_String', null, inco_term_id),
             decode(warehouse_id, 'Empty_String', null, warehouse_id),
             decode(warehouse_shed_id,
                    'Empty_String',
                    null,
                    warehouse_shed_id),
             decode(country_id, 'Empty_String', null, country_id),
             decode(state_id, 'Empty_String', null, state_id),
             decode(city_id, 'Empty_String', null, city_id),
             decode(port_id, 'Empty_String', null, port_id),
             decode(customs, 'Empty_String', null, customs),
             decode(premium, 'Empty_String', null, premium),
             decode(premium_unit_id, 'Empty_String', null, premium_unit_id),
             decode(duty_status, 'Empty_String', null, duty_status),
             decode(tax_status, 'Empty_String', null, tax_status),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(pffxd_id, 'Empty_String', null, pffxd_id),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcdbul.pcdb_id,
                     substr(max(case
                                  when pcdbul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     
                     substr(max(case
                                  when pcdbul.inco_term_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.inco_term_id
                                end),
                            24) inco_term_id,
                     substr(max(case
                                  when pcdbul.warehouse_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.warehouse_id
                                end),
                            24) warehouse_id,
                     substr(max(case
                                  when pcdbul.warehouse_shed_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.warehouse_shed_id
                                end),
                            24) warehouse_shed_id,
                     substr(max(case
                                  when pcdbul.country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.country_id
                                end),
                            24) country_id,
                     substr(max(case
                                  when pcdbul.state_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.state_id
                                end),
                            24) state_id,
                     substr(max(case
                                  when pcdbul.city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.city_id
                                end),
                            24) city_id,
                     substr(max(case
                                  when pcdbul.port_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.port_id
                                end),
                            24) port_id,
                     substr(max(case
                                  when pcdbul.customs is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.customs
                                end),
                            24) customs,
                     substr(max(case
                                  when pcdbul.premium is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.premium
                                end),
                            24) premium,
                     substr(max(case
                                  when pcdbul.premium_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.premium_unit_id
                                end),
                            24) premium_unit_id,
                     substr(max(case
                                  when pcdbul.duty_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.duty_status
                                end),
                            24) duty_status,
                     substr(max(case
                                  when pcdbul.tax_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.tax_status
                                end),
                            24) tax_status,
                     substr(max(case
                                  when pcdbul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcdbul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcdbul.pffxd_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdbul.pffxd_id
                                end),
                            24) pffxd_id,       
                     gvc_dbd_id
                from pcdbul_pc_delivery_basis_ul pcdbul,
                     axs_action_summary          axs,
                     dbd_database_dump           dbd_ul
               where axs.process = gvc_process
                 and pcdbul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcdbul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcdbul.pcdb_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcdb_data',
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

  procedure sp_phy_create_pcdd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcdb_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcdd_document_details
      (pcdd_id,
       doc_id,
       doc_type,
       version,
       is_active,
       internal_contract_ref_no,
       dbd_id,
       process_id)
      select decode(pcdd_id, 'Empty_String', null, pcdd_id),
             decode(doc_id, 'Empty_String', null, doc_id),
             decode(doc_type, 'Empty_String', null, doc_type),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcddul.pcdd_id,
                     substr(max(case
                                  when pcddul.doc_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcddul.doc_id
                                end),
                            24) doc_id,
                     substr(max(case
                                  when pcddul.doc_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcddul.doc_type
                                end),
                            24) doc_type,
                     substr(max(case
                                  when pcddul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcddul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcddul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcddul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcddul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcddul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     gvc_dbd_id
                from pcddul_document_details_ul pcddul,
                     axs_action_summary         axs,
                     dbd_database_dump          dbd_ul
               where axs.process = gvc_process
                 and pcddul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcddul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcddul.pcdd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcdd_data',
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

  procedure sp_phy_create_pcdiob_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcdiob_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcdiob_di_optional_basis
      (pcdiob_id, pcdi_id, pcdb_id, version, is_active, dbd_id, process_id)
      select decode(pcdiob_id, 'Empty_String', null, pcdiob_id),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(pcdb_id, 'Empty_String', null, pcdb_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcdiobul.pcdiob_id,
                     substr(max(case
                                  when pcdiobul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiobul.pcdi_id
                                end),
                            24) pcdi_id,
                     substr(max(case
                                  when pcdiobul.pcdb_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiobul.pcdb_id
                                end),
                            24) pcdb_id,
                     
                     substr(max(case
                                  when pcdiobul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiobul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcdiobul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiobul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcdiobul_di_optional_basis_ul pcdiobul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pcdiobul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcdiobul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcdiobul.pcdiob_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcdiob_data',
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
  procedure sp_phy_create_pcdipe_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcdipe_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcdipe_di_pricing_elements
      (pcdipe_id, pcdi_id, pcbph_id, version, is_active, dbd_id, process_id)
      select decode(pcdipe_id, 'Empty_String', null, pcdipe_id),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(pcbph_id, 'Empty_String', null, pcbph_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcdipeul.pcdipe_id,
                     substr(max(case
                                  when pcdipeul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdipeul.pcdi_id
                                end),
                            24) pcdi_id,
                     substr(max(case
                                  when pcdipeul.pcbph_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdipeul.pcbph_id
                                end),
                            24) pcbph_id,
                     substr(max(case
                                  when pcdipeul.entry_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdipeul.entry_type
                                end),
                            24) entry_type,
                     substr(max(case
                                  when pcdipeul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdipeul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcdipeul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdipeul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcdipeul_di_pricing_elemnt_ul pcdipeul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pcdipeul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcdipeul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcdipeul.pcdipe_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcdipe_data',
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

  procedure sp_phy_create_pcdiqd_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcdiqd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcdiqd_di_quality_details
      (pcdiqd_id, pcdi_id, pcpq_id, version, is_active, dbd_id, process_id)
      select decode(pcdiqd_id, 'Empty_String', null, pcdiqd_id),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select substr(max(case
                                  when pcdiqdul.internal_action_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiqdul.internal_action_ref_no
                                end),
                            24) internal_action_ref_no,
                     pcdiqdul.pcdiqd_id,
                     substr(max(case
                                  when pcdiqdul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiqdul.pcdi_id
                                end),
                            24) pcdi_id,
                     substr(max(case
                                  when pcdiqdul.pcpq_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiqdul.pcpq_id
                                end),
                            24) pcpq_id,
                     substr(max(case
                                  when pcdiqdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiqdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcdiqdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiqdul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcdiqdul_di_quality_detail_ul pcdiqdul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pcdiqdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcdiqdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcdiqdul.pcdiqd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcdiqd_data',
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

  procedure sp_phy_create_pcdi_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcdi_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcdi_pc_delivery_item
      (pcdi_id,
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
       is_phy_optionality_present,
       item_price_type,
       item_price,
       item_price_unit,
       qty_declaration_date,
       quality_declaration_date,
       inco_location_declaration_date,
       price_allocation_method,
       dbd_id,
       process_id)
      select decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(delivery_item_no,
                    'Empty_String',
                    null,
                    delivery_item_no),
             decode(prefix, 'Empty_String', null, prefix),
             decode(middle_no, 'Empty_String', null, middle_no),
             decode(suffix, 'Empty_String', null, suffix),
             decode(basis_type, 'Empty_String', null, basis_type),
             decode(delivery_period_type,
                    'Empty_String',
                    null,
                    delivery_period_type),
             decode(delivery_from_month,
                    'Empty_String',
                    null,
                    delivery_from_month),
             decode(delivery_from_year,
                    'Empty_String',
                    null,
                    delivery_from_year),
             decode(delivery_to_month,
                    'Empty_String',
                    null,
                    delivery_to_month),
             decode(delivery_to_year,
                    'Empty_String',
                    null,
                    delivery_to_year),
             decode(delivery_from_date,
                    'Empty_String',
                    null,
                    delivery_from_date),
             decode(delivery_to_date,
                    'Empty_String',
                    null,
                    delivery_to_date),
             decode(transit_days, 'Empty_String', null, transit_days),
             decode(qty_min_operator,
                    'Empty_String',
                    null,
                    qty_min_operator),
             decode(qty_min_val, 'Empty_String', null, qty_min_val),
             decode(qty_max_operator,
                    'Empty_String',
                    null,
                    qty_max_operator),
             decode(qty_max_val, 'Empty_String', null, qty_max_val),
             decode(unit_of_measure, 'Empty_String', null, unit_of_measure),
             decode(qty_unit_id, 'Empty_String', null, qty_unit_id),
             decode(trader_option, 'Empty_String', null, trader_option),
             decode(tolerance_type, 'Empty_String', null, tolerance_type),
             decode(min_tolerance, 'Empty_String', null, min_tolerance),
             decode(max_tolerance, 'Empty_String', null, max_tolerance),
             decode(tolerance_unit_id,
                    'Empty_String',
                    null,
                    tolerance_unit_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(qp_declaration_date,
                    'Empty_String',
                    null,
                    qp_declaration_date),
             decode(quality_option_type,
                    'Empty_String',
                    null,
                    quality_option_type),
             decode(pricing_option_type,
                    'Empty_String',
                    null,
                    pricing_option_type),
             decode(is_optionality_present,
                    'Empty_String',
                    null,
                    is_optionality_present),
             decode(payment_due_date,
                    'Empty_String',
                    null,
                    payment_due_date),
             decode(price_option_call_off_status,
                    'Empty_String',
                    null,
                    price_option_call_off_status),
             decode(is_price_optionality_present,
                    'Empty_String',
                    null,
                    is_price_optionality_present),
             decode(is_phy_optionality_present,
                    'Empty_String',
                    null,
                    is_phy_optionality_present),
             decode(item_price_type, 'Empty_String', null, item_price_type),
             decode(item_price, 'Empty_String', null, item_price),
             decode(item_price_unit, 'Empty_String', null, item_price_unit),
             decode(qty_declaration_date,
                    'Empty_String',
                    null,
                    qty_declaration_date),
             decode(quality_declaration_date,
                    'Empty_String',
                    null,
                    quality_declaration_date),
             decode(inco_location_declaration_date,
                    'Empty_String',
                    null,
                    inco_location_declaration_date),
             decode(price_allocation_method,
                    'Empty_String',
                    null,
                    price_allocation_method),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcdiul.pcdi_id,
                     substr(max(case
                                  when pcdiul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     
                     substr(max(case
                                  when pcdiul.delivery_item_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.delivery_item_no
                                end),
                            24) delivery_item_no,
                     substr(max(case
                                  when pcdiul.prefix is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.prefix
                                end),
                            24) prefix,
                     substr(max(case
                                  when pcdiul.middle_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.middle_no
                                end),
                            24) middle_no,
                     substr(max(case
                                  when pcdiul.suffix is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.suffix
                                end),
                            24) suffix,
                     substr(max(case
                                  when pcdiul.basis_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.basis_type
                                end),
                            24) basis_type,
                     substr(max(case
                                  when pcdiul.delivery_period_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.delivery_period_type
                                end),
                            24) delivery_period_type,
                     substr(max(case
                                  when pcdiul.delivery_from_month is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.delivery_from_month
                                end),
                            24) delivery_from_month,
                     substr(max(case
                                  when pcdiul.delivery_from_year is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.delivery_from_year
                                end),
                            24) delivery_from_year,
                     substr(max(case
                                  when pcdiul.delivery_to_month is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.delivery_to_month
                                end),
                            24) delivery_to_month,
                     substr(max(case
                                  when pcdiul.delivery_to_year is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.delivery_to_year
                                end),
                            24) delivery_to_year,
                     substr(max(case
                                  when pcdiul.delivery_from_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.delivery_from_date
                                end),
                            24) delivery_from_date,
                     substr(max(case
                                  when pcdiul.delivery_to_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.delivery_to_date
                                end),
                            24) delivery_to_date,
                     substr(max(case
                                  when pcdiul.transit_days is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.transit_days
                                end),
                            24) transit_days,
                     substr(max(case
                                  when pcdiul.qty_min_operator is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.qty_min_operator
                                end),
                            24) qty_min_operator,
                     substr(max(case
                                  when pcdiul.qty_min_val is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.qty_min_val
                                end),
                            24) qty_min_val,
                     substr(max(case
                                  when pcdiul.qty_max_operator is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.qty_max_operator
                                end),
                            24) qty_max_operator,
                     substr(max(case
                                  when pcdiul.qty_max_val is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.qty_max_val
                                end),
                            24) qty_max_val,
                     substr(max(case
                                  when pcdiul.unit_of_measure is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.unit_of_measure
                                end),
                            24) unit_of_measure,
                     substr(max(case
                                  when pcdiul.qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.qty_unit_id
                                end),
                            24) qty_unit_id,
                     substr(max(case
                                  when pcdiul.trader_option is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.trader_option
                                end),
                            24) trader_option,
                     substr(max(case
                                  when pcdiul.tolerance_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.tolerance_type
                                end),
                            24) tolerance_type,
                     substr(max(case
                                  when pcdiul.min_tolerance is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.min_tolerance
                                end),
                            24) min_tolerance,
                     substr(max(case
                                  when pcdiul.max_tolerance is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.max_tolerance
                                end),
                            24) max_tolerance,
                     substr(max(case
                                  when pcdiul.tolerance_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.tolerance_unit_id
                                end),
                            24) tolerance_unit_id,
                     substr(max(case
                                  when pcdiul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcdiul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcdiul.qp_declaration_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.qp_declaration_date
                                end),
                            24) qp_declaration_date,
                     substr(max(case
                                  when pcdiul.quality_option_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.quality_option_type
                                end),
                            24) quality_option_type,
                     substr(max(case
                                  when pcdiul.pricing_option_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.pricing_option_type
                                end),
                            24) pricing_option_type,
                     substr(max(case
                                  when pcdiul.is_optionality_present is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.is_optionality_present
                                end),
                            24) is_optionality_present,
                     substr(max(case
                                  when pcdiul.payment_due_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.payment_due_date
                                end),
                            24) payment_due_date,
                     substr(max(case
                                  when pcdiul.price_option_call_off_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.price_option_call_off_status
                                end),
                            24) price_option_call_off_status,
                     substr(max(case
                                  when pcdiul.is_price_optionality_present is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.is_price_optionality_present
                                end),
                            24) is_price_optionality_present,
                     substr(max(case
                                  when pcdiul.is_phy_optionality_present is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.is_phy_optionality_present
                                end),
                            24) is_phy_optionality_present,
                     substr(max(case
                                  when pcdiul.item_price_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.item_price_type
                                end),
                            24) item_price_type,
                     substr(max(case
                                  when pcdiul.item_price is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.item_price
                                end),
                            24) item_price,
                     substr(max(case
                                  when pcdiul.item_price_unit is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.item_price_unit
                                end),
                            24) item_price_unit,
                     substr(max(case
                                  when pcdiul.qty_declaration_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.qty_declaration_date
                                end),
                            24) qty_declaration_date,
                     substr(max(case
                                  when pcdiul.quality_declaration_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.quality_declaration_date
                                end),
                            24) quality_declaration_date,
                     substr(max(case
                                  when pcdiul.inco_location_declaration_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.inco_location_declaration_date
                                end),
                            24) inco_location_declaration_date,
                     substr(max(case
                                  when pcdiul.price_allocation_method is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdiul.price_allocation_method
                                end),
                            24) price_allocation_method,
                     gvc_dbd_id
                from pcdiul_pc_delivery_item_ul pcdiul,
                     axs_action_summary         axs,
                     dbd_database_dump          dbd_ul
               where axs.process = gvc_process
                 and pcdiul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcdiul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcdiul.pcdi_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcdi_data',
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

  procedure sp_phy_create_pcipf_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcipf_pci_pricing_formula
      (pcipf_id,
       internal_contract_item_ref_no,
       pcbph_id,
       version,
       is_active,
       dbd_id, 
       process_id)
      select decode(pcipf_id, 'Empty_String', null, pcipf_id),
             decode(internal_contract_item_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_item_ref_no),
             decode(pcbph_id, 'Empty_String', null, pcbph_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcipful.pcipf_id,
                     substr(max(case
                                  when pcipful.internal_contract_item_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcipful.internal_contract_item_ref_no
                                end),
                            24) internal_contract_item_ref_no,
                     
                     substr(max(case
                                  when pcipful.pcbph_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcipful.pcbph_id
                                end),
                            24) pcbph_id,
                     
                     substr(max(case
                                  when pcipful.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcipful.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcipful.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcipful.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcipful_pci_pricing_formula_ul pcipful,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and pcipful.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcipful.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcipful.pcipf_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcipf_data',
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
  procedure sp_phy_create_pci_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pci_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pci_physical_contract_item
      (internal_contract_item_ref_no,
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
       dbd_id,
       process_id)
      select decode(internal_contract_item_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_item_ref_no),
             decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(pcdb_id, 'Empty_String', null, pcdb_id),
             decode(item_qty, 'Empty_String', null, item_qty),
             decode(item_qty_unit_id,
                    'Empty_String',
                    null,
                    item_qty_unit_id),
             decode(delivery_from_month,
                    'Empty_String',
                    null,
                    delivery_from_month),
             decode(delivery_from_year,
                    'Empty_String',
                    null,
                    delivery_from_year),
             decode(delivery_to_month,
                    'Empty_String',
                    null,
                    delivery_to_month),
             decode(delivery_to_year,
                    'Empty_String',
                    null,
                    delivery_to_year),
             decode(delivery_period_type,
                    'Empty_String',
                    null,
                    delivery_period_type),
             decode(delivery_from_date,
                    'Empty_String',
                    null,
                    delivery_from_date),
             decode(delivery_to_date,
                    'Empty_String',
                    null,
                    delivery_to_date),
             decode(del_distribution_item_no,
                    'Empty_String',
                    null,
                    del_distribution_item_no),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(expected_delivery_month,
                    'Empty_String',
                    null,
                    expected_delivery_month),
             decode(expected_delivery_year,
                    'Empty_String',
                    null,
                    expected_delivery_year),
             decode(m2m_inco_term, 'Empty_String', null, m2m_inco_term),
             decode(m2m_country_id, 'Empty_String', null, m2m_country_id),
             decode(m2m_state_id, 'Empty_String', null, m2m_state_id),
             decode(m2m_city_id, 'Empty_String', null, m2m_city_id),
             decode(m2m_region_id, 'Empty_String', null, m2m_region_id),
             decode(is_called_off, 'Empty_String', null, is_called_off),
             decode(expected_qp_start_date,
                    'Empty_String',
                    null,
                    expected_qp_start_date),
             decode(expected_qp_end_date,
                    'Empty_String',
                    null,
                    expected_qp_end_date),
             decode(item_status,
                    'Empty_String',
                    null,
                    item_status),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pciul.internal_contract_item_ref_no,
                     substr(max(case
                                  when pciul.pcpq_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.pcpq_id
                                end),
                            24) pcpq_id,
                     substr(max(case
                                  when pciul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.pcdi_id
                                end),
                            24) pcdi_id,
                     substr(max(case
                                  when pciul.pcdb_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.pcdb_id
                                end),
                            24) pcdb_id,
                     substr(max(case
                                  when pciul.item_qty is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.item_qty
                                end),
                            24) item_qty,
                     substr(max(case
                                  when pciul.item_qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.item_qty_unit_id
                                end),
                            24) item_qty_unit_id,
                     substr(max(case
                                  when pciul.delivery_from_month is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.delivery_from_month
                                end),
                            24) delivery_from_month,
                     substr(max(case
                                  when pciul.delivery_from_year is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.delivery_from_year
                                end),
                            24) delivery_from_year,
                     substr(max(case
                                  when pciul.delivery_to_month is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.delivery_to_month
                                end),
                            24) delivery_to_month,
                     substr(max(case
                                  when pciul.delivery_to_year is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.delivery_to_year
                                end),
                            24) delivery_to_year,
                     substr(max(case
                                  when pciul.delivery_period_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.delivery_period_type
                                end),
                            24) delivery_period_type,
                     substr(max(case
                                  when pciul.delivery_from_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.delivery_from_date
                                end),
                            24) delivery_from_date,
                     
                     substr(max(case
                                  when pciul.delivery_to_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.delivery_to_date
                                end),
                            24) delivery_to_date,
                     substr(max(case
                                  when pciul.del_distribution_item_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.del_distribution_item_no
                                end),
                            24) del_distribution_item_no,
                     substr(max(case
                                  when pciul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pciul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pciul.expected_delivery_month is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.expected_delivery_month
                                end),
                            24) expected_delivery_month,
                     substr(max(case
                                  when pciul.expected_delivery_year is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.expected_delivery_year
                                end),
                            24) expected_delivery_year,
                     substr(max(case
                                  when pciul.m2m_inco_term is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.m2m_inco_term
                                end),
                            24) m2m_inco_term,
                     substr(max(case
                                  when pciul.m2m_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.m2m_country_id
                                end),
                            24) m2m_country_id,
                     substr(max(case
                                  when pciul.m2m_state_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.m2m_state_id
                                end),
                            24) m2m_state_id,
                     substr(max(case
                                  when pciul.m2m_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.m2m_city_id
                                end),
                            24) m2m_city_id,
                     substr(max(case
                                  when pciul.m2m_region_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.m2m_region_id
                                end),
                            24) m2m_region_id,
                     substr(max(case
                                  when pciul.is_called_off is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.is_called_off
                                end),
                            24) is_called_off,
                     substr(max(case
                                  when pciul.expected_qp_start_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.expected_qp_start_date
                                end),
                            24) expected_qp_start_date,
                     substr(max(case
                                  when pciul.expected_qp_end_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.expected_qp_end_date
                                end),
                            24) expected_qp_end_date,
                     substr(max(case
                                  when pciul.item_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pciul.item_status
                                end),
                            24) item_status,
                     gvc_dbd_id
                from pciul_phy_contract_item_ul pciul,
                     axs_action_summary         axs,
                     dbd_database_dump          dbd_ul
               where axs.process = gvc_process
                 and pciul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pciul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pciul.internal_contract_item_ref_no) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pci_data',
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

  procedure sp_phy_create_pcjv_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcjv_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into pcjv_pc_jv_detail
      (pcjv_id,
       internal_contract_ref_no,
       cp_id,
       profit_share_percentage,
       loss_share_percentage,
       comments,
       version,
       is_active,
       dbd_id,
       process_id)
      select decode(pcjv_id, 'Empty_String', null, pcjv_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(cp_id, 'Empty_String', null, cp_id),
             decode(profit_share_percentage,
                    'Empty_String',
                    null,
                    profit_share_percentage),
             decode(loss_share_percentage,
                    'Empty_String',
                    null,
                    loss_share_percentage),
             decode(comments, 'Empty_String', null, comments),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcjvul.pcjv_id,
                     substr(max(case
                                  when pcjvul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcjvul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     
                     substr(max(case
                                  when pcjvul.cp_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcjvul.cp_id
                                end),
                            24) cp_id,
                     substr(max(case
                                  when pcjvul.profit_share_percentage is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcjvul.profit_share_percentage
                                end),
                            24) profit_share_percentage,
                     substr(max(case
                                  when pcjvul.loss_share_percentage is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcjvul.loss_share_percentage
                                end),
                            24) loss_share_percentage,
                     substr(max(case
                                  when pcjvul.comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcjvul.comments
                                end),
                            24) comments,
                     substr(max(case
                                  when pcjvul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcjvul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcjvul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcjvul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcjvul_pc_jv_detail_ul pcjvul,
                     axs_action_summary     axs,
                     dbd_database_dump      dbd_ul
               where axs.process = gvc_process
                 and pcjvul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcjvul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcjvul.pcjv_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcjv_data',
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

  procedure sp_phy_create_pcm_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcm_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
    insert into pcm_physical_contract_main
      (internal_contract_ref_no,
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
       unit_of_measure,
       is_tolling_contract,
       approval_status,
       cp_address_id,
       is_lot_level_invoice,
       dbd_id,
       process_id)
      select decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(contract_ref_no, 'Empty_String', null, contract_ref_no),
             decode(issue_date, 'Empty_String', null, issue_date),
             decode(prefix, 'Empty_String', null, prefix),
             decode(middle_no, 'Empty_String', null, middle_no),
             decode(suffix, 'Empty_String', null, suffix),
             decode(our_person_in_charge_id,
                    'Empty_String',
                    null,
                    our_person_in_charge_id),
             decode(trader_id, 'Empty_String', null, trader_id),
             decode(cp_id, 'Empty_String', null, cp_id),
             decode(cp_person_in_charge_id,
                    'Empty_String',
                    null,
                    cp_person_in_charge_id),
             decode(cp_contract_ref_no,
                    'Empty_String',
                    null,
                    cp_contract_ref_no),
             decode(partnership_type,
                    'Empty_String',
                    null,
                    partnership_type),
             decode(invoice_currency_id,
                    'Empty_String',
                    null,
                    invoice_currency_id),
             decode(is_inter_company_deal,
                    'Empty_String',
                    null,
                    is_inter_company_deal),
             decode(is_draft, 'Empty_String', null, is_draft),
             decode(cancellation_date,
                    'Empty_String',
                    null,
                    cancellation_date),
             decode(reason_to_cancel,
                    'Empty_String',
                    null,
                    reason_to_cancel),
             decode(product_group_type,
                    'Empty_String',
                    null,
                    product_group_type),
             decode(contract_type, 'Empty_String', null, contract_type),
             decode(purchase_sales, 'Empty_String', null, purchase_sales),
             decode(corporate_id, 'Empty_String', null, corporate_id),
             decode(contract_status, 'Empty_String', null, contract_status),
             decode(prod_qual_comments,
                    'Empty_String',
                    null,
                    prod_qual_comments),
             decode(base_price_comments,
                    'Empty_String',
                    null,
                    base_price_comments),
             decode(trtmt_charge_comments,
                    'Empty_String',
                    null,
                    trtmt_charge_comments),
             decode(del_basis_comments,
                    'Empty_String',
                    null,
                    del_basis_comments),
             decode(del_schedule_comments,
                    'Empty_String',
                    null,
                    del_schedule_comments),
             decode(umpire_rule_id, 'Empty_String', null, umpire_rule_id),
             decode(sampling_rules, 'Empty_String', null, sampling_rules),
             decode(cost_basis_id, 'Empty_String', null, cost_basis_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(is_optionality_contract,
                    'Empty_String',
                    null,
                    is_optionality_contract),
             decode(payment_term_id, 'Empty_String', null, payment_term_id),
             decode(provisional_pymt_pctg,
                    'Empty_String',
                    null,
                    provisional_pymt_pctg),
             decode(provisional_pymt_at,
                    'Empty_String',
                    null,
                    provisional_pymt_at),
             decode(payment_text, 'Empty_String', null, payment_text),
             decode(insurance, 'Empty_String', null, insurance),
             decode(taxes, 'Empty_String', null, taxes),
             decode(gen_sale_condition,
                    'Empty_String',
                    null,
                    gen_sale_condition),
             decode(other_terms, 'Empty_String', null, other_terms),
             decode(internal_comments,
                    'Empty_String',
                    null,
                    internal_comments),
             decode(weight_allowance,
                    'Empty_String',
                    null,
                    weight_allowance),
             decode(weight_allowance_unit_id,
                    'Empty_String',
                    null,
                    weight_allowance_unit_id),
             decode(unit_of_measure, 'Empty_String', null, unit_of_measure),
             decode(is_tolling_contract,
                    'Empty_String',
                    null,
                    is_tolling_contract),
             decode(approval_status, 'Empty_String', null, approval_status),
             decode(cp_address_id, 'Empty_String', null, cp_address_id),
             decode(is_lot_level_invoice,
                    'Empty_String',
                    null,
                    is_lot_level_invoice),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcmul.internal_contract_ref_no,
                     substr(max(case
                                  when pcmul.contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.contract_ref_no
                                end),
                            24) contract_ref_no,
                     
                     substr(max(case
                                  when pcmul.issue_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.issue_date
                                end),
                            24) issue_date,
                     substr(max(case
                                  when pcmul.prefix is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.prefix
                                end),
                            24) prefix,
                     substr(max(case
                                  when pcmul.middle_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.middle_no
                                end),
                            24) middle_no,
                     substr(max(case
                                  when pcmul.suffix is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.suffix
                                end),
                            24) suffix,
                     substr(max(case
                                  when pcmul.our_person_in_charge_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.our_person_in_charge_id
                                end),
                            24) our_person_in_charge_id,
                     substr(max(case
                                  when pcmul.trader_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.trader_id
                                end),
                            24) trader_id,
                     substr(max(case
                                  when pcmul.cp_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.cp_id
                                end),
                            24) cp_id,
                     substr(max(case
                                  when pcmul.cp_person_in_charge_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.cp_person_in_charge_id
                                end),
                            24) cp_person_in_charge_id,
                     substr(max(case
                                  when pcmul.cp_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.cp_contract_ref_no
                                end),
                            24) cp_contract_ref_no,
                     substr(max(case
                                  when pcmul.partnership_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.partnership_type
                                end),
                            24) partnership_type,
                     substr(max(case
                                  when pcmul.invoice_currency_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.invoice_currency_id
                                end),
                            24) invoice_currency_id,
                     substr(max(case
                                  when pcmul.is_inter_company_deal is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.is_inter_company_deal
                                end),
                            24) is_inter_company_deal,
                     substr(max(case
                                  when pcmul.is_draft is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.is_draft
                                end),
                            24) is_draft,
                     substr(max(case
                                  when pcmul.cancellation_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.cancellation_date
                                end),
                            24) cancellation_date,
                     substr(max(case
                                  when pcmul.reason_to_cancel is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.reason_to_cancel
                                end),
                            24) reason_to_cancel,
                     substr(max(case
                                  when pcmul.product_group_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.product_group_type
                                end),
                            24) product_group_type,
                     substr(max(case
                                  when pcmul.contract_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.contract_type
                                end),
                            24) contract_type,
                     substr(max(case
                                  when pcmul.purchase_sales is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.purchase_sales
                                end),
                            24) purchase_sales,
                     substr(max(case
                                  when pcmul.corporate_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.corporate_id
                                end),
                            24) corporate_id,
                     substr(max(case
                                  when pcmul.contract_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.contract_status
                                end),
                            24) contract_status,
                     substr(max(case
                                  when pcmul.prod_qual_comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.prod_qual_comments
                                end),
                            24) prod_qual_comments,
                     substr(max(case
                                  when pcmul.base_price_comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.base_price_comments
                                end),
                            24) base_price_comments,
                     substr(max(case
                                  when pcmul.trtmt_charge_comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.trtmt_charge_comments
                                end),
                            24) trtmt_charge_comments,
                     substr(max(case
                                  when pcmul.del_basis_comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.del_basis_comments
                                end),
                            24) del_basis_comments,
                     substr(max(case
                                  when pcmul.del_schedule_comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.del_schedule_comments
                                end),
                            24) del_schedule_comments,
                     substr(max(case
                                  when pcmul.umpire_rule_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.umpire_rule_id
                                end),
                            24) umpire_rule_id,
                     substr(max(case
                                  when pcmul.sampling_rules is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.sampling_rules
                                end),
                            24) sampling_rules,
                     substr(max(case
                                  when pcmul.cost_basis_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.cost_basis_id
                                end),
                            24) cost_basis_id,
                     substr(max(case
                                  when pcmul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcmul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcmul.is_optionality_contract is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.is_optionality_contract
                                end),
                            24) is_optionality_contract,
                     substr(max(case
                                  when pcmul.payment_term_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.payment_term_id
                                end),
                            24) payment_term_id,
                     substr(max(case
                                  when pcmul.provisional_pymt_pctg is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.provisional_pymt_pctg
                                end),
                            24) provisional_pymt_pctg,
                     substr(max(case
                                  when pcmul.provisional_pymt_at is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.provisional_pymt_at
                                end),
                            24) provisional_pymt_at,
                     substr(max(case
                                  when pcmul.payment_text is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.payment_text
                                end),
                            24) payment_text,
                     substr(max(case
                                  when pcmul.insurance is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.insurance
                                end),
                            24) insurance,
                     substr(max(case
                                  when pcmul.taxes is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.taxes
                                end),
                            24) taxes,
                     substr(max(case
                                  when pcmul.gen_sale_condition is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.gen_sale_condition
                                end),
                            24) gen_sale_condition,
                     substr(max(case
                                  when pcmul.other_terms is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.other_terms
                                end),
                            24) other_terms,
                     substr(max(case
                                  when pcmul.internal_comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.internal_comments
                                end),
                            24) internal_comments,
                     substr(max(case
                                  when pcmul.weight_allowance is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.weight_allowance
                                end),
                            24) weight_allowance,
                     substr(max(case
                                  when pcmul.weight_allowance_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.weight_allowance_unit_id
                                end),
                            24) weight_allowance_unit_id,
                     substr(max(case
                                  when pcmul.unit_of_measure is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.unit_of_measure
                                end),
                            24) unit_of_measure,
                     substr(max(case
                                  when pcmul.is_tolling_contract is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.is_tolling_contract
                                end),
                            24) is_tolling_contract,
                     substr(max(case
                                  when pcmul.approval_status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.approval_status
                                end),
                            24) approval_status,
                     substr(max(case
                                  when pcmul.cp_address_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.cp_address_id
                                end),
                            24) cp_address_id,
                     substr(max(case
                                  when pcmul.is_lot_level_invoice is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcmul.is_lot_level_invoice
                                end),
                            24) is_lot_level_invoice,
                     gvc_dbd_id
                from pcmul_phy_contract_main_ul pcmul,
                     axs_action_summary         axs,
                     dbd_database_dump          dbd_ul
               where axs.process = gvc_process
                 and pcmul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcmul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcmul.internal_contract_ref_no) t;
  
    update pcm_physical_contract_main pcm
       set pcm.is_tolling_extn = 'Y'
     where pcm.corporate_id = pc_corporate_id
       and pcm.dbd_id = gvc_dbd_id
       and exists
     (select pcmte.int_contract_ref_no
              from pcmte_pcm_tolling_ext pcmte
             where pcmte.int_contract_ref_no = pcm.internal_contract_ref_no);
  update pcm_physical_contract_main pcm
       set pcm.is_pass_through ='Y'
       
       where exists
       ( select pcmte.int_contract_ref_no
              from pcmte_pcm_tolling_ext pcmte
             where pcmte.int_contract_ref_no = pcm.internal_contract_ref_no
             and pcmte.is_pass_through ='Y')
             and pcm.dbd_id = gvc_dbd_id;
       
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcm_data',
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

  procedure sp_phy_create_pcpdqd_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcpdqd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcpdqd_pd_quality_details
      (pcpdqd_id,
       pcqpd_id,
       pcpq_id,
       version,
       is_active,
       quality_name,
       dbd_id,
       process_id)
      select decode(pcpdqd_id, 'Empty_String', null, pcpdqd_id),
             decode(pcqpd_id, 'Empty_String', null, pcqpd_id),
             decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(quality_name, 'Empty_String', null, quality_name),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcpdqdul.pcpdqd_id,
                     substr(max(case
                                  when pcpdqdul.pcqpd_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdqdul.pcqpd_id
                                end),
                            24) pcqpd_id,
                     substr(max(case
                                  when pcpdqdul.pcpq_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdqdul.pcpq_id
                                end),
                            24) pcpq_id,
                     substr(max(case
                                  when pcpdqdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdqdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcpdqdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdqdul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcpdqdul.quality_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdqdul.quality_name
                                end),
                            24) quality_name,
                     gvc_dbd_id
                from pcpdqdul_pd_quality_dtl_ul pcpdqdul,
                     axs_action_summary         axs,
                     dbd_database_dump          dbd_ul
               where axs.process = gvc_process
                 and pcpdqdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcpdqdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcpdqdul.pcpdqd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcpdqd_data',
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

  procedure sp_phy_create_pcpd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcpd_pc_product_definition
      (pcpd_id,
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
       quality_print_name,
       input_output,
       dbd_id,
       process_id)
      select decode(pcpd_id, 'Empty_String', null, pcpd_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(product_id, 'Empty_String', null, product_id),
             decode(profit_center_id,
                    'Empty_String',
                    null,
                    profit_center_id),
             decode(qty_type, 'Empty_String', null, qty_type),
             decode(qty_min_operator,
                    'Empty_String',
                    null,
                    qty_min_operator),
             decode(qty_min_val, 'Empty_String', null, qty_min_val),
             decode(qty_max_operator,
                    'Empty_String',
                    null,
                    qty_max_operator),
             decode(qty_max_val, 'Empty_String', null, qty_max_val),
             decode(unit_of_measure, 'Empty_String', null, unit_of_measure),
             decode(qty_unit_id, 'Empty_String', null, qty_unit_id),
             decode(is_metal_content,
                    'Empty_String',
                    null,
                    is_metal_content),
             decode(metal_content_elm_id,
                    'Empty_String',
                    null,
                    metal_content_elm_id),
             decode(tolerance_type, 'Empty_String', null, tolerance_type),
             decode(min_tolerance, 'Empty_String', null, min_tolerance),
             decode(max_tolerance, 'Empty_String', null, max_tolerance),
             decode(tolerance_unit_id,
                    'Empty_String',
                    null,
                    tolerance_unit_id),
             decode(comments, 'Empty_String', null, comments),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(strategy_id, 'Empty_String', null, strategy_id),
             decode(is_quality_print_name_req,
                    'Empty_String',
                    null,
                    is_quality_print_name_req),
             decode(quality_print_name,
                    'Empty_String',
                    null,
                    quality_print_name),
             decode(input_output, 'Empty_String', null, input_output),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcpdul.pcpd_id,
                     substr(max(case
                                  when pcpdul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcpdul.product_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.product_id
                                end),
                            24) product_id,
                     substr(max(case
                                  when pcpdul.profit_center_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.profit_center_id
                                end),
                            24) profit_center_id,
                     substr(max(case
                                  when pcpdul.qty_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.qty_type
                                end),
                            24) qty_type,
                     substr(max(case
                                  when pcpdul.qty_min_operator is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.qty_min_operator
                                end),
                            24) qty_min_operator,
                     substr(max(case
                                  when pcpdul.qty_min_val is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.qty_min_val
                                end),
                            24) qty_min_val,
                     substr(max(case
                                  when pcpdul.qty_max_operator is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.qty_max_operator
                                end),
                            24) qty_max_operator,
                     substr(max(case
                                  when pcpdul.qty_max_val is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.qty_max_val
                                end),
                            24) qty_max_val,
                     substr(max(case
                                  when pcpdul.unit_of_measure is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.unit_of_measure
                                end),
                            24) unit_of_measure,
                     substr(max(case
                                  when pcpdul.qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.qty_unit_id
                                end),
                            24) qty_unit_id,
                     substr(max(case
                                  when pcpdul.is_metal_content is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.is_metal_content
                                end),
                            24) is_metal_content,
                     substr(max(case
                                  when pcpdul.metal_content_elm_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.metal_content_elm_id
                                end),
                            24) metal_content_elm_id,
                     substr(max(case
                                  when pcpdul.tolerance_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.tolerance_type
                                end),
                            24) tolerance_type,
                     substr(max(case
                                  when pcpdul.min_tolerance is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.min_tolerance
                                end),
                            24) min_tolerance,
                     substr(max(case
                                  when pcpdul.max_tolerance is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.max_tolerance
                                end),
                            24) max_tolerance,
                     substr(max(case
                                  when pcpdul.tolerance_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.tolerance_unit_id
                                end),
                            24) tolerance_unit_id,
                     substr(max(case
                                  when pcpdul.comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.comments
                                end),
                            24) comments,
                     substr(max(case
                                  when pcpdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcpdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcpdul.strategy_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.strategy_id
                                end),
                            24) strategy_id,
                     substr(max(case
                                  when pcpdul.is_quality_print_name_req is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.is_quality_print_name_req
                                end),
                            24) is_quality_print_name_req,
                     substr(max(case
                                  when pcpdul.quality_print_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.quality_print_name
                                end),
                            24) quality_print_name,
                     substr(max(case
                                  when pcpdul.input_output is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpdul.input_output
                                end),
                            24) input_output,
                     gvc_dbd_id
                from pcpdul_pc_product_defintn_ul pcpdul,
                     axs_action_summary           axs,
                     dbd_database_dump            dbd_ul
               where axs.process = gvc_process
                 and pcpdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcpdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcpdul.pcpd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcpd_data',
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

  procedure sp_phy_create_pcpq_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcpq_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcpq_pc_product_quality
      (pcpq_id,
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
       comments,
       dbd_id,
       process_id)
      select decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(pcpd_id, 'Empty_String', null, pcpd_id),
             decode(quality_template_id,
                    'Empty_String',
                    null,
                    quality_template_id),
             decode(phy_attribute_group_no,
                    'Empty_String',
                    null,
                    phy_attribute_group_no),
             decode(assay_header_id, 'Empty_String', null, assay_header_id),
             decode(qty_type, 'Empty_String', null, qty_type),
             decode(qty_min_op, 'Empty_String', null, qty_min_op),
             decode(qty_min_val, 'Empty_String', null, qty_min_val),
             decode(qty_max_op, 'Empty_String', null, qty_max_op),
             decode(qty_max_val, 'Empty_String', null, qty_max_val),
             decode(unit_of_measure, 'Empty_String', null, unit_of_measure),
             decode(qty_unit_id, 'Empty_String', null, qty_unit_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(is_quality_print_name_req,
                    'Empty_String',
                    null,
                    is_quality_print_name_req),
             decode(quality_print_name,
                    'Empty_String',
                    null,
                    quality_print_name),
             decode(comments, 'Empty_String', null, comments),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcpqul.pcpq_id,
                     substr(max(case
                                  when pcpqul.pcpd_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.pcpd_id
                                end),
                            24) pcpd_id,
                     
                     substr(max(case
                                  when pcpqul.quality_template_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.quality_template_id
                                end),
                            24) quality_template_id,
                     substr(max(case
                                  when pcpqul.phy_attribute_group_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.phy_attribute_group_no
                                end),
                            24) phy_attribute_group_no,
                     substr(max(case
                                  when pcpqul.assay_header_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.assay_header_id
                                end),
                            24) assay_header_id,
                     substr(max(case
                                  when pcpqul.qty_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.qty_type
                                end),
                            24) qty_type,
                     substr(max(case
                                  when pcpqul.qty_min_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.qty_min_op
                                end),
                            24) qty_min_op,
                     substr(max(case
                                  when pcpqul.qty_min_val is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.qty_min_val
                                end),
                            24) qty_min_val,
                     substr(max(case
                                  when pcpqul.qty_max_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.qty_max_op
                                end),
                            24) qty_max_op,
                     substr(max(case
                                  when pcpqul.qty_max_val is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.qty_max_val
                                end),
                            24) qty_max_val,
                     substr(max(case
                                  when pcpqul.unit_of_measure is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.unit_of_measure
                                end),
                            24) unit_of_measure,
                     substr(max(case
                                  when pcpqul.qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.qty_unit_id
                                end),
                            24) qty_unit_id,
                     substr(max(case
                                  when pcpqul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcpqul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcpqul.is_quality_print_name_req is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.is_quality_print_name_req
                                end),
                            24) is_quality_print_name_req,
                     substr(max(case
                                  when pcpqul.quality_print_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.quality_print_name
                                end),
                            24) quality_print_name,
                     substr(max(case
                                  when pcpqul.comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpqul.comments
                                end),
                            24) comments,
                     gvc_dbd_id
                from pcpqul_pc_product_quality_ul pcpqul,
                     axs_action_summary           axs,
                     dbd_database_dump            dbd_ul
               where axs.process = gvc_process
                 and pcpqul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcpqul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcpqul.pcpq_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcpq_data',
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

  procedure sp_phy_create_pcqpd_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcqpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcqpd_pc_qual_premium_discount
      (pcqpd_id,
       internal_contract_ref_no,
       premium_disc_name,
       premium_disc_type,
       premium_disc_value,
       premium_disc_unit_id,
       pffxd_id,
       version,
       is_active,
       dbd_id,
       process_id)
      select decode(pcqpd_id, 'Empty_String', null, pcqpd_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(premium_disc_name,
                    'Empty_String',
                    null,
                    premium_disc_name),
             decode(premium_disc_type,
                    'Empty_String',
                    null,
                    premium_disc_type),
             decode(premium_disc_value,
                    'Empty_String',
                    null,
                    premium_disc_value),
             decode(premium_disc_unit_id,
                    'Empty_String',
                    null,
                    premium_disc_unit_id),
             decode(pffxd_id, 'Empty_String', null, pffxd_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcqpdul.pcqpd_id,
                     substr(max(case
                                  when pcqpdul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcqpdul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcqpdul.premium_disc_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcqpdul.premium_disc_name
                                end),
                            24) premium_disc_name,
                     substr(max(case
                                  when pcqpdul.premium_disc_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcqpdul.premium_disc_type
                                end),
                            24) premium_disc_type,
                     substr(max(case
                                  when pcqpdul.premium_disc_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcqpdul.premium_disc_value
                                end),
                            24) premium_disc_value,
                     substr(max(case
                                  when pcqpdul.premium_disc_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcqpdul.premium_disc_unit_id
                                end),
                            24) premium_disc_unit_id,
                     substr(max(case
                                  when pcqpdul.pffxd_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcqpdul.pffxd_id
                                end),
                            24) pffxd_id,
                     substr(max(case
                                  when pcqpdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcqpdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcqpdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcqpdul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcqpdul_pc_qual_prm_discnt_ul pcqpdul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pcqpdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcqpdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcqpdul.pcqpd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcqpd_data',
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

  procedure sp_phy_create_pffxd_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcqpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pffxd_phy_formula_fx_details
      (pffxd_id,
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
       dbd_id,
       process_id)
      select decode(pffxd_id, 'Empty_String', null, pffxd_id),
             decode(fx_rate_type, 'Empty_String', null, fx_rate_type),
             decode(fixed_fx_rate, 'Empty_String', null, fixed_fx_rate),
             decode(currency_pair_instrument,
                    'Empty_String',
                    null,
                    currency_pair_instrument),
             decode(price_source_id, 'Empty_String', null, price_source_id),
             decode(off_day_price, 'Empty_String', null, off_day_price),
             decode(fx_period_from_date,
                    'Empty_String',
                    null,
                    fx_period_from_date),
             decode(fx_period_to_date,
                    'Empty_String',
                    null,
                    fx_period_to_date),
             decode(fx_month, 'Empty_String', null, fx_month),
             decode(fx_year, 'Empty_String', null, fx_year),
             decode(fx_date, 'Empty_String', null, fx_date),
             decode(fx_event_from, 'Empty_String', null, fx_event_from),
             decode(fx_event_period_type,
                    'Empty_String',
                    null,
                    fx_event_period_type),
             decode(fx_event_from_type,
                    'Empty_String',
                    null,
                    fx_event_from_type),
             decode(fx_event_from_shipment_type,
                    'Empty_String',
                    null,
                    fx_event_from_shipment_type),
             decode(fx_event_to, 'Empty_String', null, fx_event_to),
             decode(fx_event_to_type,
                    'Empty_String',
                    null,
                    fx_event_to_type),
             decode(fx_event_to_shipment_type,
                    'Empty_String',
                    null,
                    fx_event_to_shipment_type),
             decode(is_fx_any_day_basis,
                    'Empty_String',
                    null,
                    is_fx_any_day_basis),
             decode(fx_conversion_method,
                    'Empty_String',
                    null,
                    fx_conversion_method),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pffxdul.pffxd_id,
                     substr(max(case
                                  when pffxdul.fx_rate_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_rate_type
                                end),
                            24) fx_rate_type,
                     substr(max(case
                                  when pffxdul.fixed_fx_rate is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fixed_fx_rate
                                end),
                            24) fixed_fx_rate,
                     substr(max(case
                                  when pffxdul.currency_pair_instrument is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.currency_pair_instrument
                                end),
                            24) currency_pair_instrument,
                     substr(max(case
                                  when pffxdul.price_source_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.price_source_id
                                end),
                            24) price_source_id,
                     substr(max(case
                                  when pffxdul.off_day_price is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.off_day_price
                                end),
                            24) off_day_price,
                     substr(max(case
                                  when pffxdul.fx_period_from_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_period_from_date
                                end),
                            24) fx_period_from_date,
                     substr(max(case
                                  when pffxdul.fx_period_to_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_period_to_date
                                end),
                            24) fx_period_to_date,
                     substr(max(case
                                  when pffxdul.fx_month is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_month
                                end),
                            24) fx_month,
                     substr(max(case
                                  when pffxdul.fx_year is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_year
                                end),
                            24) fx_year,
                     substr(max(case
                                  when pffxdul.fx_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_date
                                end),
                            24) fx_date,
                     substr(max(case
                                  when pffxdul.fx_event_from is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_event_from
                                end),
                            24) fx_event_from,
                     substr(max(case
                                  when pffxdul.fx_event_period_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_event_period_type
                                end),
                            24) fx_event_period_type,
                     substr(max(case
                                  when pffxdul.fx_event_from_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_event_from_type
                                end),
                            24) fx_event_from_type,
                     substr(max(case
                                  when pffxdul.fx_event_from_shipment_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_event_from_shipment_type
                                end),
                            24) fx_event_from_shipment_type,
                     substr(max(case
                                  when pffxdul.fx_event_to is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_event_to
                                end),
                            24) fx_event_to,
                     substr(max(case
                                  when pffxdul.fx_event_to_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_event_to_type
                                end),
                            24) fx_event_to_type,
                     substr(max(case
                                  when pffxdul.fx_event_to_shipment_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_event_to_shipment_type
                                end),
                            24) fx_event_to_shipment_type,
                     substr(max(case
                                  when pffxdul.is_fx_any_day_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.is_fx_any_day_basis
                                end),
                            24) is_fx_any_day_basis,
                     substr(max(case
                                  when pffxdul.fx_conversion_method is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.fx_conversion_method
                                end),
                            24) fx_conversion_method,
                     substr(max(case
                                  when pffxdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pffxdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pffxdul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pffxdul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     
                     gvc_dbd_id
                from pffxdul_phy_formula_fx_dtl_ul pffxdul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pffxdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pffxdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pffxdul.pffxd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pffxd_data',
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

  procedure sp_phy_create_pfqpp_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcqpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into pfqpp_phy_formula_qp_pricing
      (pfqpp_id,
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
       dbd_id,
       process_id)
      select decode(pfqpp_id, 'Empty_String', null, pfqpp_id),
             decode(ppfh_id, 'Empty_String', null, ppfh_id),
             decode(qp_pricing_period_type,
                    'Empty_String',
                    null,
                    qp_pricing_period_type),
             decode(qp_period_from_date,
                    'Empty_String',
                    null,
                    qp_period_from_date),
             decode(qp_period_to_date,
                    'Empty_String',
                    null,
                    qp_period_to_date),
             decode(qp_month, 'Empty_String', null, qp_month),
             decode(qp_year, 'Empty_String', null, qp_year),
             decode(qp_date, 'Empty_String', null, qp_date),
             decode(qp_event_from, 'Empty_String', null, qp_event_from),
             decode(qp_event_period_type,
                    'Empty_String',
                    null,
                    qp_event_period_type),
             decode(qp_event_from_type,
                    'Empty_String',
                    null,
                    qp_event_from_type),
             decode(qp_event_from_shipment_type,
                    'Empty_String',
                    null,
                    qp_event_from_shipment_type),
             decode(qp_event_to, 'Empty_String', null, qp_event_to),
             decode(qp_event_to_type,
                    'Empty_String',
                    null,
                    qp_event_to_type),
             decode(qp_event_to_shipment_type,
                    'Empty_String',
                    null,
                    qp_event_to_shipment_type),
             decode(is_qp_any_day_basis,
                    'Empty_String',
                    null,
                    is_qp_any_day_basis),
             decode(qty_to_be_priced,
                    'Empty_String',
                    null,
                    qty_to_be_priced),
             decode(qp_pricing_type, 'Empty_String', null, qp_pricing_type),
             decode(qp_optionality, 'Empty_String', null, qp_optionality),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(event_name, 'Empty_String', null, event_name),
             decode(no_of_event_months,
                    'Empty_String',
                    null,
                    no_of_event_months),
             decode(is_spot_pricing, 'Empty_String', null, is_spot_pricing),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pfqppul.pfqpp_id,
                     substr(max(case
                                  when pfqppul.ppfh_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.ppfh_id
                                end),
                            24) ppfh_id,
                     substr(max(case
                                  when pfqppul.qp_pricing_period_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_pricing_period_type
                                end),
                            24) qp_pricing_period_type,
                     substr(max(case
                                  when pfqppul.qp_period_from_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_period_from_date
                                end),
                            24) qp_period_from_date,
                     substr(max(case
                                  when pfqppul.qp_period_to_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_period_to_date
                                end),
                            24) qp_period_to_date,
                     substr(max(case
                                  when pfqppul.qp_month is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_month
                                end),
                            24) qp_month,
                     substr(max(case
                                  when pfqppul.qp_year is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_year
                                end),
                            24) qp_year,
                     substr(max(case
                                  when pfqppul.qp_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_date
                                end),
                            24) qp_date,
                     substr(max(case
                                  when pfqppul.qp_event_from is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_event_from
                                end),
                            24) qp_event_from,
                     substr(max(case
                                  when pfqppul.qp_event_period_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_event_period_type
                                end),
                            24) qp_event_period_type,
                     substr(max(case
                                  when pfqppul.qp_event_from_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_event_from_type
                                end),
                            24) qp_event_from_type,
                     substr(max(case
                                  when pfqppul.qp_event_from_shipment_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_event_from_shipment_type
                                end),
                            24) qp_event_from_shipment_type,
                     substr(max(case
                                  when pfqppul.qp_event_to is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_event_to
                                end),
                            24) qp_event_to,
                     substr(max(case
                                  when pfqppul.qp_event_to_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_event_to_type
                                end),
                            24) qp_event_to_type,
                     substr(max(case
                                  when pfqppul.qp_event_to_shipment_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_event_to_shipment_type
                                end),
                            24) qp_event_to_shipment_type,
                     substr(max(case
                                  when pfqppul.is_qp_any_day_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.is_qp_any_day_basis
                                end),
                            24) is_qp_any_day_basis,
                     substr(max(case
                                  when pfqppul.qty_to_be_priced is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qty_to_be_priced
                                end),
                            24) qty_to_be_priced,
                     substr(max(case
                                  when pfqppul.qp_pricing_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_pricing_type
                                end),
                            24) qp_pricing_type,
                     substr(max(case
                                  when pfqppul.qp_optionality is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.qp_optionality
                                end),
                            24) qp_optionality,
                     substr(max(case
                                  when pfqppul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pfqppul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pfqppul.event_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.event_name
                                end),
                            24) event_name,
                     substr(max(case
                                  when pfqppul.no_of_event_months is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.no_of_event_months
                                end),
                            24) no_of_event_months,
                     substr(max(case
                                  when pfqppul.is_spot_pricing is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pfqppul.is_spot_pricing
                                end),
                            24) is_spot_pricing,
                     gvc_dbd_id
                from pfqppul_phy_formula_qp_prc_ul pfqppul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pfqppul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pfqppul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pfqppul.pfqpp_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pfqpp_data',
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

  procedure sp_phy_create_ppfd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcqpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into ppfd_phy_price_formula_details
      (ppfd_id,
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
       dbd_id,
       process_id)
      select decode(ppfd_id, 'Empty_String', null, ppfd_id),
             decode(ppfh_id, 'Empty_String', null, ppfh_id),
             decode(instrument_id, 'Empty_String', null, instrument_id),
             decode(price_source_id, 'Empty_String', null, price_source_id),
             decode(price_point_id, 'Empty_String', null, price_point_id),
             decode(available_price_type_id,
                    'Empty_String',
                    null,
                    available_price_type_id),
             decode(value_date_type, 'Empty_String', null, value_date_type),
             decode(value_date, 'Empty_String', null, value_date),
             decode(value_month, 'Empty_String', null, value_month),
             decode(value_year, 'Empty_String', null, value_year),
             decode(off_day_price, 'Empty_String', null, off_day_price),
             decode(basis, 'Empty_String', null, basis),
             decode(basis_price_unit_id,
                    'Empty_String',
                    null,
                    basis_price_unit_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select ppfdul.ppfd_id,
                     substr(max(case
                                  when ppfdul.ppfh_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.ppfh_id
                                end),
                            24) ppfh_id,
                     substr(max(case
                                  when ppfdul.instrument_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.instrument_id
                                end),
                            24) instrument_id,
                     substr(max(case
                                  when ppfdul.price_source_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.price_source_id
                                end),
                            24) price_source_id,
                     substr(max(case
                                  when ppfdul.price_point_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.price_point_id
                                end),
                            24) price_point_id,
                     substr(max(case
                                  when ppfdul.available_price_type_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.available_price_type_id
                                end),
                            24) available_price_type_id,
                     substr(max(case
                                  when ppfdul.value_date_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.value_date_type
                                end),
                            24) value_date_type,
                     substr(max(case
                                  when ppfdul.value_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.value_date
                                end),
                            24) value_date,
                     substr(max(case
                                  when ppfdul.value_month is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.value_month
                                end),
                            24) value_month,
                     substr(max(case
                                  when ppfdul.value_year is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.value_year
                                end),
                            24) value_year,
                     substr(max(case
                                  when ppfdul.off_day_price is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.off_day_price
                                end),
                            24) off_day_price,
                     substr(max(case
                                  when ppfdul.basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.basis
                                end),
                            24) basis,
                     substr(max(case
                                  when ppfdul.basis_price_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.basis_price_unit_id
                                end),
                            24) basis_price_unit_id,
                     substr(max(case
                                  when ppfdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when ppfdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfdul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from ppfdul_phy_price_frmula_dtl_ul ppfdul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and ppfdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and ppfdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by ppfdul.ppfd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_ppfd_data',
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

  procedure sp_phy_create_ppfh_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcqpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into ppfh_phy_price_formula_header
      (ppfh_id,
       pcbpd_id,
       formula_name,
       formula_id,
       formula_description,
       internal_formula_desc,
       version,
       is_active,
       price_unit_id,
       dbd_id,
       process_id)
      select decode(ppfh_id, 'Empty_String', null, ppfh_id),
             decode(pcbpd_id, 'Empty_String', null, pcbpd_id),
             decode(formula_name, 'Empty_String', null, formula_name),
             decode(formula_id, 'Empty_String', null, formula_id),
             decode(formula_description,
                    'Empty_String',
                    null,
                    formula_description),
             decode(internal_formula_desc,
                    'Empty_String',
                    null,
                    internal_formula_desc),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(price_unit_id, 'Empty_String', null, price_unit_id),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select ppfhul.ppfh_id,
                     substr(max(case
                                  when ppfhul.pcbpd_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfhul.pcbpd_id
                                end),
                            24) pcbpd_id,
                     substr(max(case
                                  when ppfhul.formula_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfhul.formula_name
                                end),
                            24) formula_name,
                     substr(max(case
                                  when ppfhul.formula_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfhul.formula_id
                                end),
                            24) formula_id,
                     substr(max(case
                                  when ppfhul.formula_description is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfhul.formula_description
                                end),
                            24) formula_description,
                     substr(max(case
                                  when ppfhul.internal_formula_desc is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfhul.internal_formula_desc
                                end),
                            24) internal_formula_desc,
                     substr(max(case
                                  when ppfhul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfhul.version
                                end),
                            24) version,
                     substr(max(case
                                  when ppfhul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfhul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when ppfhul.price_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   ppfhul.price_unit_id
                                end),
                            24) price_unit_id,
                     gvc_dbd_id
                from ppfhul_phy_price_frmla_hdr_ul ppfhul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and ppfhul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and ppfhul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by ppfhul.ppfh_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_ppfh_data',
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

  procedure sp_phy_create_ciqs_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcqpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into ciqs_contract_item_qty_status
      (ciqs_id,
       internal_contract_item_ref_no,
       total_qty,
       item_qty_unit_id,
       open_qty,
       gmr_qty,
       title_transferred_qty,
       price_fixed_qty,
       allocated_qty,
       prov_invoiced_qty,
       final_invoiced_qty,
       advance_payment_qty,
       fulfilled_qty,
       shipped_qty,
       fin_swap_invoice_qty,
       unallocated_qty,
       version,
       is_active,
       dbd_id,
       process_id)
      select ciqsul.ciqs_id,
             substr(max(case
                          when ciqsul.internal_contract_item_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           ciqsul.internal_contract_item_ref_no
                        end),
                    24) internal_contract_item_ref_no,
             round(sum(nvl(ciqsul.total_qty_delta, 0)), 10),
             substr(max(case
                          when ciqsul.item_qty_unit_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           ciqsul.item_qty_unit_id
                        end),
                    24) item_qty_unit_id,
             round(sum(nvl(ciqsul.open_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.gmr_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.title_transferred_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.price_fixed_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.allocated_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.prov_invoiced_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.final_invoiced_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.advance_payment_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.fulfilled_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.shipped_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.fin_swap_invoice_qty_delta, 0)), 10),
             round(sum(nvl(ciqsul.unallocated_qty_delta, 0)), 10),
             substr(max(case
                          when ciqsul.version is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           ciqsul.version
                        end),
                    24) version,
             substr(max(case
                          when ciqsul.is_active is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           ciqsul.is_active
                        end),
                    24) is_active,
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from ciqsl_contract_itm_qty_sts_log ciqsul,
             axs_action_summary             axs,
             dbd_database_dump              dbd_ul
       where axs.process = gvc_process
         and ciqsul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.eff_date <= pd_trade_date
         and axs.corporate_id = pc_corporate_id
         and ciqsul.dbd_id = dbd_ul.dbd_id
         and dbd_ul.corporate_id = pc_corporate_id
         and dbd_ul.process = gvc_process
       group by ciqsul.ciqs_id;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_ciqs_data',
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
  procedure sp_phy_create_diqs_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcqpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into diqs_delivery_item_qty_status
      (diqs_id,
       pcdi_id,
       total_qty,
       item_qty_unit_id,
       open_qty,
       gmr_qty,
       title_transferred_qty,
       price_fixed_qty,
       allocated_qty,
       prov_invoiced_qty,
       final_invoiced_qty,
       advance_payment_qty,
       fulfilled_qty,
       shipped_qty,
       fin_swap_invoice_qty,
       unallocated_qty,
       version,
       is_active,
       called_off_qty,
       dbd_id,
       process_id)
      select diqsul.diqs_id,
             substr(max(case
                          when diqsul.pcdi_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           diqsul.pcdi_id
                        end),
                    24) pcdi_id,
             round(sum(nvl(diqsul.total_qty_delta, 0)), 10),
             substr(max(case
                          when diqsul.item_qty_unit_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           diqsul.item_qty_unit_id
                        end),
                    24) item_qty_unit_id,
             round(sum(nvl(diqsul.open_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.gmr_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.title_transferred_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.price_fixed_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.allocated_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.prov_invoiced_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.final_invoiced_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.advance_payment_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.fulfilled_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.shipped_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.fin_swap_invoice_qty_delta, 0)), 10),
             round(sum(nvl(diqsul.unallocated_qty_delta, 0)), 10),
             substr(max(case
                          when diqsul.version is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           diqsul.version
                        end),
                    24) version,
             substr(max(case
                          when diqsul.is_active is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           diqsul.is_active
                        end),
                    24) is_active,
             round(sum(nvl(diqsul.called_off_qty_delta, 0)), 10),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from diqsl_delivery_itm_qty_sts_log diqsul,
             axs_action_summary             axs,
             dbd_database_dump              dbd_ul
       where axs.process = gvc_process
         and diqsul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.eff_date <= pd_trade_date
         and axs.corporate_id = pc_corporate_id
         and diqsul.dbd_id = dbd_ul.dbd_id
         and dbd_ul.corporate_id = pc_corporate_id
         and dbd_ul.process = gvc_process
       group by diqsul.diqs_id;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_diqs_data',
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

  procedure sp_phy_create_cqs_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcqpd_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into cqs_contract_qty_status
      (cqs_id,
       internal_contract_ref_no,
       total_qty,
       item_qty_unit_id,
       open_qty,
       gmr_qty,
       title_transferred_qty,
       price_fixed_qty,
       allocated_qty,
       prov_invoiced_qty,
       final_invoiced_qty,
       advance_payment_qty,
       fulfilled_qty,
       shipped_qty,
       fin_swap_invoice_qty,
       unallocated_qty,
       version,
       is_active,
       called_off_qty,
       dbd_id,
       process_id)
      select cqsul.cqs_id,
             substr(max(case
                          when cqsul.internal_contract_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cqsul.internal_contract_ref_no
                        end),
                    24) internal_contract_ref_no,
             round(sum(nvl(cqsul.total_qty_delta, 0)), 10),
             substr(max(case
                          when cqsul.item_qty_unit_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cqsul.item_qty_unit_id
                        end),
                    24) item_qty_unit_id,
             round(sum(nvl(cqsul.open_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.gmr_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.title_transferred_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.price_fixed_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.allocated_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.prov_invoiced_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.final_invoiced_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.advance_payment_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.fulfilled_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.shipped_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.fin_swap_invoice_qty_delta, 0)), 10),
             round(sum(nvl(cqsul.unallocated_qty_delta, 0)), 10),
             substr(max(case
                          when cqsul.version is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cqsul.version
                        end),
                    24) version,
             substr(max(case
                          when cqsul.is_active is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cqsul.is_active
                        end),
                    24) is_active,
             round(sum(nvl(cqsul.called_off_qty_delta, 0)), 10),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from cqsl_contract_qty_status_log cqsul,
             axs_action_summary           axs,
             dbd_database_dump            dbd_ul
       where axs.process = gvc_process
         and cqsul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.eff_date <= pd_trade_date
         and axs.corporate_id = pc_corporate_id
         and cqsul.dbd_id = dbd_ul.dbd_id
         and dbd_ul.corporate_id = pc_corporate_id
         and dbd_ul.process = gvc_process
       group by cqsul.cqs_id;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_cqs_data',
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

  procedure sp_phy_create_grd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vn_row_cnt number;
  
  begin
  vn_row_cnt := 0;
  delete from process_grd where corporate_id = pc_corporate_id;
  commit;
    insert into process_grd
      (corporate_id,
       internal_grd_ref_no,
       internal_gmr_ref_no,
       product_id,
       is_afloat,
       status,
       qty,
       qty_unit_id,
       gmr_qty_unit_id,
       gross_weight,
       tare_weight,
       internal_contract_item_ref_no,
       int_alloc_group_id,
       packing_size_id,
       container_no,
       seal_no,
       mark_no,
       warehouse_ref_no,
       no_of_units,
       quality_id,
       warehouse_profile_id,
       shed_id,
       origin_id,
       parent_id,
       is_released_shipped,
       release_shipped_no_of_units,
       is_write_off,
       write_off_no_of_units,
       is_deleted,
       is_moved_out,
       moved_out_no_of_units,
       total_no_of_units,
       total_qty,
       moved_out_qty,
       release_shipped_qty,
       write_off_qty,
       title_transfer_out_qty,
       title_transfer_out_no_of_units,
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
       bl_date,
       bl_number,
       parent_internal_grd_ref_no,
       discharged_qty,
       is_voyage_stock,
       allocated_qty,
       internal_stock_ref_no,
       landed_no_of_units,
       landed_net_qty,
       landed_gross_qty,
       shipped_no_of_units,
       shipped_net_qty,
       shipped_gross_qty,
       current_qty,
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
       internal_action_ref_no,
       packing_type_id,
       handled_as,
       allocated_no_of_units,
       current_no_of_units,
       stock_condition,
       customs_id,
       tax_id,
       duty_id,
       customer_seal_no,
       brand,
       no_of_containers,
       no_of_bags,
       no_of_pieces,
       rail_car_no,
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
       process_id)
      select pc_corporate_id,
             grdul.internal_grd_ref_no,
             substr(max(case
                          when grdul.internal_gmr_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.internal_gmr_ref_no
                        end),
                    24) internal_gmr_ref_no,
             substr(max(case
                          when grdul.product_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.product_id
                        end),
                    24) product_id,
             substr(max(case
                          when grdul.is_afloat is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_afloat
                        end),
                    24) is_afloat,
             substr(max(case
                          when grdul.status is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.status
                        end),
                    24) status,
             round(sum(nvl(grdul.qty_delta, 0)), 10),
             substr(max(case
                          when grdul.qty_unit_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.qty_unit_id
                        end),
                    24) qty_unit_id,
             substr(max(case
                          when grdul.qty_unit_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.qty_unit_id
                        end),
                    24) gmr_qty_unit_id,
             round(sum(nvl(grdul.gross_weight_delta, 0)), 10),
             round(sum(nvl(grdul.tare_weight_delta, 0)), 10),
             substr(max(case
                          when grdul.internal_contract_item_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.internal_contract_item_ref_no
                        end),
                    24) internal_contract_item_ref_no,
             substr(max(case
                          when grdul.int_alloc_group_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.int_alloc_group_id
                        end),
                    24) int_alloc_group_id,
             substr(max(case
                          when grdul.packing_size_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.packing_size_id
                        end),
                    24) packing_size_id,
             substr(max(case
                          when grdul.container_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.container_no
                        end),
                    24) container_no,
             substr(max(case
                          when grdul.seal_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.seal_no
                        end),
                    24) seal_no,
             substr(max(case
                          when grdul.mark_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.mark_no
                        end),
                    24) mark_no,
             substr(max(case
                          when grdul.warehouse_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.warehouse_ref_no
                        end),
                    24) warehouse_ref_no,
             round(sum(nvl(grdul.no_of_units_delta, 0)), 10),
             substr(max(case
                          when grdul.quality_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.quality_id
                        end),
                    24) quality_id,
             substr(max(case
                          when grdul.warehouse_profile_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.warehouse_profile_id
                        end),
                    24) warehouse_profile_id,
             substr(max(case
                          when grdul.shed_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.shed_id
                        end),
                    24) shed_id,
             substr(max(case
                          when grdul.origin_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.origin_id
                        end),
                    24) origin_id,
             substr(max(case
                          when grdul.parent_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.parent_id
                        end),
                    24) parent_id,
             substr(max(case
                          when grdul.is_released_shipped is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_released_shipped
                        end),
                    24) is_released_shipped,
             round(sum(nvl(grdul.release_shipped_no_units_delta, 0)), 10),
             substr(max(case
                          when grdul.is_write_off is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_write_off
                        end),
                    24) is_write_off,
             round(sum(nvl(grdul.write_off_no_of_units_delta, 0)), 10),
             substr(max(case
                          when grdul.is_deleted is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_deleted
                        end),
                    24) is_deleted,
             substr(max(case
                          when grdul.is_moved_out is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_moved_out
                        end),
                    24) is_moved_out,
             round(sum(nvl(grdul.moved_out_no_of_units_delta, 0)), 10),
             round(sum(nvl(grdul.total_no_of_units_delta, 0)), 10),
             round(sum(nvl(grdul.total_qty_delta, 0)), 10),
             round(sum(nvl(grdul.moved_out_qty_delta, 0)), 10),
             round(sum(nvl(grdul.release_shipped_qty_delta, 0)), 10),
             round(sum(nvl(grdul.write_off_qty_delta, 0)), 10),
             round(sum(nvl(grdul.title_transfer_out_qty_delta, 0)), 10),
             round(sum(nvl(grdul.title_transfr_out_no_unt_delta, 0)), 10),
             substr(max(case
                          when grdul.warehouse_receipt_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.warehouse_receipt_no
                        end),
                    24) warehouse_receipt_no,
             substr(max(case
                          when grdul.warehouse_receipt_date is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.warehouse_receipt_date
                        end),
                    24) warehouse_receipt_date,
             substr(max(case
                          when grdul.container_size is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.container_size
                        end),
                    24) container_size,
             substr(max(case
                          when grdul.remarks is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.remarks
                        end),
                    24) remarks,
             substr(max(case
                          when grdul.is_added_to_pool is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_added_to_pool
                        end),
                    24) is_added_to_pool,
             substr(max(case
                          when grdul.loading_date is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.loading_date
                        end),
                    24) loading_date,
             substr(max(case
                          when grdul.loading_country_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.loading_country_id
                        end),
                    24) loading_country_id,
             substr(max(case
                          when grdul.loading_port_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.loading_port_id
                        end),
                    24) loading_port_id,
             substr(max(case
                          when grdul.is_entire_item_loaded is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_entire_item_loaded
                        end),
                    24) is_entire_item_loaded,
             substr(max(case
                          when grdul.is_weight_final is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_weight_final
                        end),
                    24) is_weight_final,
             substr(max(case
                          when grdul.bl_date is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.bl_date
                        end),
                    24) bl_date,
             substr(max(case
                          when grdul.bl_number is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.bl_number
                        end),
                    24) bl_number,
             substr(max(case
                          when grdul.parent_internal_grd_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.parent_internal_grd_ref_no
                        end),
                    24) parent_internal_grd_ref_no,
             round(sum(nvl(grdul.discharged_qty_delta, 0)), 10),
             substr(max(case
                          when grdul.is_voyage_stock is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_voyage_stock
                        end),
                    24) is_voyage_stock,
             round(sum(nvl(grdul.allocated_qty_delta, 0)), 10),
             substr(max(case
                          when grdul.internal_stock_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.internal_stock_ref_no
                        end),
                    24) internal_stock_ref_no,
             round(sum(nvl(grdul.landed_no_of_units_delta, 0)), 10),
             round(sum(nvl(grdul.landed_net_qty_delta, 0)), 10),
             round(sum(nvl(grdul.landed_gross_qty_delta, 0)), 10),
             round(sum(nvl(grdul.shipped_no_of_units_delta, 0)), 10),
             round(sum(nvl(grdul.shipped_net_qty_delta, 0)), 10),
             round(sum(nvl(grdul.shipped_gross_qty_delta, 0)), 10),
             round(sum(nvl(grdul.current_qty_delta, 0)), 10),
             substr(max(case
                          when grdul.stock_status is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.stock_status
                        end),
                    24) stock_status,
             substr(max(case
                          when grdul.product_specs is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.product_specs
                        end),
                    24) product_specs,
             substr(max(case
                          when grdul.source_type is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.source_type
                        end),
                    24) source_type,
             substr(max(case
                          when grdul.source_int_stock_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.source_int_stock_ref_no
                        end),
                    24) source_int_stock_ref_no,
             substr(max(case
                          when grdul.source_int_purchase_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.source_int_purchase_ref_no
                        end),
                    24) source_int_purchase_ref_no,
             substr(max(case
                          when grdul.source_int_pool_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.source_int_pool_ref_no
                        end),
                    24) source_int_pool_ref_no,
             
             substr(max(case
                          when grdul.is_fulfilled is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_fulfilled
                        end),
                    24) is_fulfilled,
             substr(max(case
                          when grdul.inventory_status is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.inventory_status
                        end),
                    24) inventory_status,
             substr(max(case
                          when grdul.truck_rail_number is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.truck_rail_number
                        end),
                    24) truck_rail_number,
             substr(max(case
                          when grdul.truck_rail_type is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.truck_rail_type
                        end),
                    24) truck_rail_type,
             substr(max(case
                          when grdul.internal_action_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.internal_action_ref_no
                        end),
                    24) internal_action_ref_no,
             substr(max(case
                          when grdul.packing_type_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.packing_type_id
                        end),
                    24) packing_type_id,
             substr(max(case
                          when grdul.handled_as is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.handled_as
                        end),
                    24) handled_as,
             round(sum(nvl(grdul.allocated_no_of_units_delta, 0)), 10),
             round(sum(nvl(grdul.current_no_of_units_delta, 0)), 10),
             substr(max(case
                          when grdul.stock_condition is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.stock_condition
                        end),
                    24) stock_condition,
             substr(max(case
                          when grdul.customs_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.customs_id
                        end),
                    24) customs_id,
             substr(max(case
                          when grdul.tax_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.tax_id
                        end),
                    24) tax_id,
             substr(max(case
                          when grdul.duty_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.duty_id
                        end),
                    24) duty_id,
             substr(max(case
                          when grdul.customer_seal_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.customer_seal_no
                        end),
                    24) customer_seal_no,
             substr(max(case
                          when grdul.brand is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.brand
                        end),
                    24) brand,
             round(sum(nvl(grdul.no_of_containers_delta, 0)), 10),
             round(sum(nvl(grdul.no_of_bags_delta, 0)), 10),
             substr(max(case
                          when grdul.no_of_pieces_delta is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.no_of_pieces_delta
                        end),
                    24) no_of_pieces_delta,
             substr(max(case
                          when grdul.rail_car_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.rail_car_no
                        end),
                    24) rail_car_no,
             substr(max(case
                          when grdul.partnership_type is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.partnership_type
                        end),
                    24) partnership_type,
             substr(max(case
                          when grdul.is_trans_ship is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_trans_ship
                        end),
                    24) is_trans_ship,
             substr(max(case
                          when grdul.is_mark_for_tolling is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_mark_for_tolling
                        end),
                    24) is_mark_for_tolling,
             substr(max(case
                          when grdul.tolling_qty is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.tolling_qty
                        end),
                    24) tolling_qty,
             substr(max(case
                          when grdul.tolling_stock_type is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.tolling_stock_type
                        end),
                    24) tolling_stock_type,
             substr(max(case
                          when grdul.element_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.element_id
                        end),
                    24) element_id,
             substr(max(case
                          when grdul.expected_sales_ccy is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.expected_sales_ccy
                        end),
                    24) expected_sales_ccy,
             substr(max(case
                          when grdul.profit_center_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.profit_center_id
                        end),
                    24) profit_center_id,
             substr(max(case
                          when grdul.strategy_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.strategy_id
                        end),
                    24) strategy_id,
             substr(max(case
                          when grdul.is_warrant is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.is_warrant
                        end),
                    24) is_warrant,
             substr(max(case
                          when grdul.warrant_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.warrant_no
                        end),
                    24) warrant_no,
             substr(max(case
                          when grdul.pcdi_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.pcdi_id
                        end),
                    24) pcdi_id,
             substr(max(case
                          when grdul.supp_contract_item_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.supp_contract_item_ref_no
                        end),
                    24) supp_contract_item_ref_no,
             substr(max(case
                          when grdul.supplier_pcdi_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.supplier_pcdi_id
                        end),
                    24) supplier_pcdi_id,
                                 
             substr(max(case
                          when grdul.payable_returnable_type is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.payable_returnable_type
                        end),
                    24) payable_returnable_type,
             substr(max(case
                          when grdul.carry_over_qty is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.carry_over_qty
                        end),
                    24) carry_over_qty,
              substr(max(case
                          when grdul.supp_internal_gmr_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           grdul.supp_internal_gmr_ref_no
                        end),
                    24) supp_internal_gmr_ref_no,        
                    gvc_dbd_id,
                    pkg_phy_populate_data.gvc_process_id
        from grdl_goods_record_detail_log grdul,
             axs_action_summary           axs
       where axs.process = gvc_process
         and grdul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.eff_date <= pd_trade_date
         and axs.corporate_id = pc_corporate_id
         and grdul.process = gvc_process
       group by grdul.internal_grd_ref_no;
       commit;

   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'process_grd populated..');          
   sp_gather_stats('process_gmr');   
   sp_gather_stats('process_grd');     
   sp_gather_stats('pci_physical_contract_item');   
   sp_gather_stats('pcdi_pc_delivery_item');     
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside grd_data payment_due_date update');       
    --
    -- Update Payment Due Date From Contract
    --
    update process_grd grd
       set grd.payment_due_date = (select pcdi.payment_due_date
                                     from pci_physical_contract_item pci,
                                          pcdi_pc_delivery_item      pcdi
                                    where pcdi.pcdi_id = pci.pcdi_id
                                      and pcdi.dbd_id = pci.dbd_id
                                      and pcdi.dbd_id = gvc_dbd_id
                                      and pci.internal_contract_item_ref_no =
                                          grd.internal_contract_item_ref_no
                                      and grd.dbd_id = gvc_dbd_id)
     where grd.dbd_id = gvc_dbd_id
     and grd.corporate_id = pc_corporate_id;
   commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside grd_data payment_due_date update1');       
   
  update process_grd grd
     set grd.payment_due_date = pd_trade_date
   where grd.dbd_id = gvc_dbd_id
     and grd.corporate_id = pc_corporate_id
     and grd.payment_due_date is null;
   commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside grd_data product_id update');       
       
 -- Purchase from GRD      
 
  for cur_grd in (select grd.internal_gmr_ref_no,
                         grd.product_id,
                         pdm.product_desc
                    from process_grd       grd,
                         pdm_productmaster pdm
                   where element_id is null
                     and grd.corporate_id = pc_corporate_id
                     and grd.product_id = pdm.product_id
                     and pdm.product_type_id = 'Standard'
                   group by grd.internal_gmr_ref_no,
                            grd.product_id,
                            pdm.product_desc)
  loop
    update process_gmr gmr
       set gmr.product_id = cur_grd.product_id,
           gmr.product_name=cur_grd.product_desc
     where gmr.corporate_id = pc_corporate_id
       and gmr.internal_gmr_ref_no = cur_grd.internal_gmr_ref_no;
       vn_row_cnt := vn_row_cnt + 1;
       if vn_row_cnt>=500 then
          commit;
          vn_row_cnt := 0;
        end if;
  end loop;
  commit; 
   --sp_gather_stats('process_gmr');   
   --sp_gather_stats('process_grd');     
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside grd_data product_id update1');
-- Sales from DGRD
  for cur_dgrd in (select dgrd.internal_gmr_ref_no,
                          dgrd.product_id,
                          dgrd.product_name
                     from dgrd_delivered_grd dgrd
                    where dgrd.dbd_id = gvc_dbd_id)
  loop
    update process_gmr gmr
       set gmr.product_id = cur_dgrd.product_id,
           gmr.product_name=cur_dgrd.product_name
     where gmr.dbd_id = gvc_dbd_id
       and gmr.internal_gmr_ref_no = cur_dgrd.internal_gmr_ref_no
       and gmr.corporate_id = pc_corporate_id;
       vn_row_cnt := vn_row_cnt + 1;
       if vn_row_cnt>=500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
  commit;
--
-- For concentrates GMRs for which we are calcualting GMR Price
--
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside grd_data product_id update2');
  for cur_grd in (select grd.internal_gmr_ref_no,
                         grd.product_id,
                         pdm.product_desc
                    from process_grd              grd,
                         pdm_productmaster        pdm,
                         pdtm_product_type_master pdtm
                   where grd.tolling_stock_type in ('None Tolling','Clone Stock')
                     and grd.product_id = pdm.product_id
                     and pdm.product_type_id = pdtm.product_type_id
                     and pdtm.product_type_name = 'Composite'
                     and grd.dbd_id = gvc_dbd_id
                   group by grd.internal_gmr_ref_no,
                            grd.product_id,
                            pdm.product_desc)
  loop
    update process_gmr gmr
       set gmr.product_id = cur_grd.product_id,
           gmr.product_name=cur_grd.product_desc
     where gmr.internal_gmr_ref_no = cur_grd.internal_gmr_ref_no
       and gmr.dbd_id = gvc_dbd_id
       and gmr.corporate_id = pc_corporate_id;
       vn_row_cnt := vn_row_cnt + 1;
       if vn_row_cnt>=500 then
          commit;
          vn_row_cnt := 0;
        end if;
  end loop;
  commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside grd_data product_id update3');
  for cur_grd in (select grd.internal_gmr_ref_no,
                         grd.product_id,
                         pdm.product_desc
                    from dgrd_delivered_grd       grd,
                         pdm_productmaster        pdm,
                         pdtm_product_type_master pdtm
                   where grd.tolling_stock_type in ('None Tolling')
                     and grd.product_id = pdm.product_id
                     and pdm.product_type_id = pdtm.product_type_id
                     and pdtm.product_type_name = 'Composite'
                     and grd.dbd_id = gvc_dbd_id
                   group by grd.internal_gmr_ref_no,
                            grd.product_id,
                            pdm.product_desc)
  loop
    update process_gmr gmr
       set gmr.product_id = cur_grd.product_id,
           gmr.product_name=cur_grd.product_desc
     where gmr.internal_gmr_ref_no = cur_grd.internal_gmr_ref_no
       and gmr.dbd_id = gvc_dbd_id;
       vn_row_cnt := vn_row_cnt + 1;
       if vn_row_cnt>=500 then
          commit;
          vn_row_cnt := 0;
        end if;
  end loop;       
  commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside grd_data grd current_qty update');
--
-- Added on 1st Aug 2012 By janna
-- We have to nake sure that no where else we are using the below logic as
-- we are updating the current qty to the exact value expected
--
  update process_grd grd
     set grd.current_qty = (nvl(grd.current_qty, 0) +
                           nvl(grd.release_shipped_qty, 0) -
                           nvl(grd.title_transfer_out_qty, 0))
   where grd.dbd_id = gvc_dbd_id
     and grd.corporate_id = pc_corporate_id;
   commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside grd_data gmr stock_current_qty update');
  /*update process_gmr gmr
     set gmr.stock_current_qty = (select nvl(sum(nvl(grd.current_qty, 0)), 0)
                                    from grd_goods_record_detail grd
                                   where grd.dbd_id = gmr.dbd_id
                                     and grd.internal_gmr_ref_no =
                                         gmr.internal_gmr_ref_no
                                     and grd.is_deleted = 'N'
                                     and grd.status = 'Active')
   where gmr.dbd_id = gvc_dbd_id
   and gmr.corporate_id = pc_corporate_id;*/
    for cc in (select grd.internal_gmr_ref_no,
                      nvl(sum(nvl(grd.current_qty, 0)), 0) current_qty
                 from process_grd grd
                where grd.is_deleted = 'N'
                  and grd.status = 'Active'
                  and grd.corporate_id = pc_corporate_id
                  and grd.dbd_id = gvc_dbd_id
                group by grd.internal_gmr_ref_no)
    loop
      update process_gmr gmr
         set gmr.stock_current_qty = cc.current_qty
       where gmr.dbd_id = gvc_dbd_id
         and gmr.corporate_id = pc_corporate_id
         and gmr.internal_gmr_ref_no = cc.internal_gmr_ref_no;
         vn_row_cnt := vn_row_cnt + 1;
         if vn_row_cnt>=500 then
             commit;
             vn_row_cnt := 0;
          end if;         
    end loop;
    commit;
 --  sp_gather_stats('process_gmr');   
  -- sp_gather_stats('process_grd');     
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_grd_data',
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
  procedure sp_phy_create_vd_data(pc_corporate_id varchar2,
                                  pd_trade_date   date,
                                  pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into vd_voyage_detail
      (internal_gmr_ref_no,
       action_no,
       shipping_line_profile_id,
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
       shipping_agent_profile_id,
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
       dbd_id,
       process_id)
      select decode(internal_gmr_ref_no,
                    'Empty_String',
                    null,
                    internal_gmr_ref_no),
             decode(action_no, 'Empty_String', null, action_no),
             decode(shipping_line_profile_id,
                    'Empty_String',
                    null,
                    shipping_line_profile_id),
             decode(loading_port_id, 'Empty_String', null, loading_port_id),
             decode(discharge_port_id,
                    'Empty_String',
                    null,
                    discharge_port_id),
             decode(trans_shipment_port_id,
                    'Empty_String',
                    null,
                    trans_shipment_port_id),
             decode(trans_shipment_country_id,
                    'Empty_String',
                    null,
                    trans_shipment_country_id),
             decode(destination_city_id,
                    'Empty_String',
                    null,
                    destination_city_id),
             decode(destination_country_id,
                    'Empty_String',
                    null,
                    destination_country_id),
             decode(origination_city_id,
                    'Empty_String',
                    null,
                    origination_city_id),
             decode(origination_country_id,
                    'Empty_String',
                    null,
                    origination_country_id),
             decode(booking_ref_no, 'Empty_String', null, booking_ref_no),
             decode(voyage_ref_no, 'Empty_String', null, voyage_ref_no),
             decode(shipping_agent_profile_id,
                    'Empty_String',
                    null,
                    shipping_agent_profile_id),
             decode(etd, 'Empty_String', null, etd),
             decode(eta, 'Empty_String', null, eta),
             decode(cut_off_date, 'Empty_String', null, cut_off_date),
             decode(voyage_quantity, 'Empty_String', null, voyage_quantity),
             decode(voyage_qty_type, 'Empty_String', null, voyage_qty_type),
             decode(voyage_qty_unit_id,
                    'Empty_String',
                    null,
                    voyage_qty_unit_id),
             decode(vessel_voyage_name,
                    'Empty_String',
                    null,
                    vessel_voyage_name),
             decode(vessel_id, 'Empty_String', null, vessel_id),
             decode(status, 'Empty_String', null, status),
             decode(voyage_number, 'Empty_String', null, voyage_number),
             decode(loading_date, 'Empty_String', null, loading_date),
             decode(shippers_ref_no, 'Empty_String', null, shippers_ref_no),
             decode(shipper_address, 'Empty_String', null, shipper_address),
             decode(loading_country_id,
                    'Empty_String',
                    null,
                    loading_country_id),
             decode(loading_state_id,
                    'Empty_String',
                    null,
                    loading_state_id),
             decode(loading_city_id, 'Empty_String', null, loading_city_id),
             decode(trans_shipment_state_id,
                    'Empty_String',
                    null,
                    trans_shipment_state_id),
             decode(trans_shipment_city_id,
                    'Empty_String',
                    null,
                    trans_shipment_city_id),
             decode(discharge_country_id,
                    'Empty_String',
                    null,
                    discharge_country_id),
             decode(discharge_state_id,
                    'Empty_String',
                    null,
                    discharge_state_id),
             decode(discharge_city_id,
                    'Empty_String',
                    null,
                    discharge_city_id),
             decode(place_of_receipt_country_id,
                    'Empty_String',
                    null,
                    place_of_receipt_country_id),
             decode(place_of_receipt_state_id,
                    'Empty_String',
                    null,
                    place_of_receipt_state_id),
             decode(place_of_receipt_city_id,
                    'Empty_String',
                    null,
                    place_of_receipt_city_id),
             decode(place_of_delivery_country_id,
                    'Empty_String',
                    null,
                    place_of_delivery_country_id),
             decode(place_of_delivery_state_id,
                    'Empty_String',
                    null,
                    place_of_delivery_state_id),
             decode(place_of_delivery_city_id,
                    'Empty_String',
                    null,
                    place_of_delivery_city_id),
             decode(notes, 'Empty_String', null, notes),
             decode(shippers_instructions,
                    'Empty_String',
                    null,
                    shippers_instructions),
             decode(special_instructions,
                    'Empty_String',
                    null,
                    special_instructions),
             decode(carriers_agents_endorsements,
                    'Empty_String',
                    null,
                    carriers_agents_endorsements),
             decode(comments, 'Empty_String', null, comments),
             decode(agents_data_code,
                    'Empty_String',
                    null,
                    agents_data_code),
             decode(airport_of_destination_code,
                    'Empty_String',
                    null,
                    airport_of_destination_code),
             decode(airport_of_departure_code,
                    'Empty_String',
                    null,
                    airport_of_departure_code),
             decode(declared_value_customs,
                    'Empty_String',
                    null,
                    declared_value_customs),
             decode(declared_value_customs_cur_id,
                    'Empty_String',
                    null,
                    declared_value_customs_cur_id),
             decode(no_of_pieces, 'Empty_String', null, no_of_pieces),
             decode(nature_of_goods, 'Empty_String', null, nature_of_goods),
             decode(dimensions, 'Empty_String', null, dimensions),
             decode(handling_instructions,
                    'Empty_String',
                    null,
                    handling_instructions),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select vdul.internal_gmr_ref_no,
                     substr(max(case
                                  when vdul.action_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.action_no
                                end),
                            24) action_no,
                     substr(max(case
                                  when vdul.shipping_line_profile_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.shipping_line_profile_id
                                end),
                            24) shipping_line_profile_id,
                     substr(max(case
                                  when vdul.loading_port_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.loading_port_id
                                end),
                            24) loading_port_id,
                     substr(max(case
                                  when vdul.discharge_port_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.discharge_port_id
                                end),
                            24) discharge_port_id,
                     substr(max(case
                                  when vdul.trans_shipment_port_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.trans_shipment_port_id
                                end),
                            24) trans_shipment_port_id,
                     substr(max(case
                                  when vdul.trans_shipment_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.trans_shipment_country_id
                                end),
                            24) trans_shipment_country_id,
                     substr(max(case
                                  when vdul.destination_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.destination_city_id
                                end),
                            24) destination_city_id,
                     substr(max(case
                                  when vdul.destination_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.destination_country_id
                                end),
                            24) destination_country_id,
                     substr(max(case
                                  when vdul.origination_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.origination_city_id
                                end),
                            24) origination_city_id,
                     substr(max(case
                                  when vdul.origination_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.origination_country_id
                                end),
                            24) origination_country_id,
                     substr(max(case
                                  when vdul.booking_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.booking_ref_no
                                end),
                            24) booking_ref_no,
                     substr(max(case
                                  when vdul.voyage_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.voyage_ref_no
                                end),
                            24) voyage_ref_no,
                     substr(max(case
                                  when vdul.shipping_agent_profile_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.shipping_agent_profile_id
                                end),
                            24) shipping_agent_profile_id,
                     substr(max(case
                                  when vdul.etd is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.etd
                                end),
                            24) etd,
                     substr(max(case
                                  when vdul.eta is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.eta
                                end),
                            24) eta,
                     substr(max(case
                                  when vdul.cut_off_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.cut_off_date
                                end),
                            24) cut_off_date,
                     substr(max(case
                                  when vdul.voyage_quantity is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.voyage_quantity
                                end),
                            24) voyage_quantity,
                     substr(max(case
                                  when vdul.voyage_qty_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.voyage_qty_type
                                end),
                            24) voyage_qty_type,
                     substr(max(case
                                  when vdul.voyage_qty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.voyage_qty_unit_id
                                end),
                            24) voyage_qty_unit_id,
                     substr(max(case
                                  when vdul.vessel_voyage_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.vessel_voyage_name
                                end),
                            24) vessel_voyage_name,
                     substr(max(case
                                  when vdul.vessel_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.vessel_id
                                end),
                            24) vessel_id,
                     substr(max(case
                                  when vdul.status is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.status
                                end),
                            24) status,
                     substr(max(case
                                  when vdul.voyage_number is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.voyage_number
                                end),
                            24) voyage_number,
                     substr(max(case
                                  when vdul.loading_date is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.loading_date
                                end),
                            24) loading_date,
                     substr(max(case
                                  when vdul.shippers_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.shippers_ref_no
                                end),
                            24) shippers_ref_no,
                     substr(max(case
                                  when vdul.shipper_address is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.shipper_address
                                end),
                            24) shipper_address,
                     substr(max(case
                                  when vdul.loading_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.loading_country_id
                                end),
                            24) loading_country_id,
                     substr(max(case
                                  when vdul.loading_state_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.loading_state_id
                                end),
                            24) loading_state_id,
                     substr(max(case
                                  when vdul.loading_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.loading_city_id
                                end),
                            24) loading_city_id,
                     substr(max(case
                                  when vdul.trans_shipment_state_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.trans_shipment_state_id
                                end),
                            24) trans_shipment_state_id,
                     substr(max(case
                                  when vdul.trans_shipment_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.trans_shipment_city_id
                                end),
                            24) trans_shipment_city_id,
                     substr(max(case
                                  when vdul.discharge_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.discharge_country_id
                                end),
                            24) discharge_country_id,
                     substr(max(case
                                  when vdul.discharge_state_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.discharge_state_id
                                end),
                            24) discharge_state_id,
                     substr(max(case
                                  when vdul.discharge_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.discharge_city_id
                                end),
                            24) discharge_city_id,
                     substr(max(case
                                  when vdul.place_of_receipt_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.place_of_receipt_country_id
                                end),
                            24) place_of_receipt_country_id,
                     substr(max(case
                                  when vdul.place_of_receipt_state_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.place_of_receipt_state_id
                                end),
                            24) place_of_receipt_state_id,
                     substr(max(case
                                  when vdul.place_of_receipt_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.place_of_receipt_city_id
                                end),
                            24) place_of_receipt_city_id,
                     substr(max(case
                                  when vdul.place_of_delivery_country_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.place_of_delivery_country_id
                                end),
                            24) place_of_delivery_country_id,
                     substr(max(case
                                  when vdul.place_of_delivery_state_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.place_of_delivery_state_id
                                end),
                            24) place_of_delivery_state_id,
                     substr(max(case
                                  when vdul.place_of_delivery_city_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.place_of_delivery_city_id
                                end),
                            24) place_of_delivery_city_id,
                     substr(max(case
                                  when vdul.notes is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.notes
                                end),
                            24) notes,
                     substr(max(case
                                  when vdul.shippers_instructions is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.shippers_instructions
                                end),
                            24) shippers_instructions,
                     substr(max(case
                                  when vdul.special_instructions is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.special_instructions
                                end),
                            24) special_instructions,
                     substr(max(case
                                  when vdul.carriers_agents_endorsements is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.carriers_agents_endorsements
                                end),
                            24) carriers_agents_endorsements,
                     substr(max(case
                                  when vdul.comments is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.comments
                                end),
                            24) comments,
                     substr(max(case
                                  when vdul.agents_data_code is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.agents_data_code
                                end),
                            24) agents_data_code,
                     substr(max(case
                                  when vdul.airport_of_destination_code is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.airport_of_destination_code
                                end),
                            24) airport_of_destination_code,
                     substr(max(case
                                  when vdul.airport_of_departure_code is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.airport_of_departure_code
                                end),
                            24) airport_of_departure_code,
                     substr(max(case
                                  when vdul.declared_value_customs is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.declared_value_customs
                                end),
                            24) declared_value_customs,
                     substr(max(case
                                  when vdul.declared_value_customs_cur_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.declared_value_customs_cur_id
                                end),
                            24) declared_value_customs_cur_id,
                     substr(max(case
                                  when vdul.no_of_pieces is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.no_of_pieces
                                end),
                            24) no_of_pieces,
                     substr(max(case
                                  when vdul.nature_of_goods is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.nature_of_goods
                                end),
                            24) nature_of_goods,
                     substr(max(case
                                  when vdul.dimensions is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.dimensions
                                end),
                            24) dimensions,
                     substr(max(case
                                  when vdul.handling_instructions is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   vdul.handling_instructions
                                end),
                            24) handling_instructions,
                     gvc_dbd_id
                from vdul_voyage_detail_ul vdul,
                     axs_action_summary    axs,
                     dbd_database_dump     dbd_ul
               where axs.process = gvc_process
                 and vdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and vdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by vdul.internal_gmr_ref_no) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_vd_data',
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

  procedure sp_phy_create_pcpch_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcpch_pc_payble_content_header
      (pcpch_id,
       internal_contract_ref_no,
       range_type,
       range_unit_id,
       element_id,
       slab_tier,
       version,
       is_active,
       payable_type,
       dbd_id,
       process_id)
      select decode(pcpch_id, 'Empty_String', null, pcpch_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(range_type, 'Empty_String', null, range_type),
             decode(range_unit_id, 'Empty_String', null, range_unit_id),
             decode(element_id, 'Empty_String', null, element_id),
             decode(slab_tier, 'Empty_String', null, slab_tier),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(payable_type, 'Empty_String', null, payable_type),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcpchul.pcpch_id,
                     substr(max(case
                                  when pcpchul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpchul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcpchul.range_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpchul.range_type
                                end),
                            24) range_type,
                     substr(max(case
                                  when pcpchul.range_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpchul.range_unit_id
                                end),
                            24) range_unit_id,
                     substr(max(case
                                  when pcpchul.element_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpchul.element_id
                                end),
                            24) element_id,
                     substr(max(case
                                  when pcpchul.slab_tier is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpchul.slab_tier
                                end),
                            24) slab_tier,
                     substr(max(case
                                  when pcpchul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpchul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcpchul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpchul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcpchul.payable_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcpchul.payable_type
                                end),
                            24) payable_type,
                     gvc_dbd_id
                from pcpchul_payble_contnt_headr_ul pcpchul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and pcpchul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcpchul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcpchul.pcpch_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcpch_data',
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

  procedure sp_phy_create_pqd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pqd_payable_quality_details
      (pqd_id, pcpch_id, pcpq_id, version, is_active, quality_name, dbd_id,process_id)
      select decode(pqd_id, 'Empty_String', null, pqd_id),
             decode(pcpch_id, 'Empty_String', null, pcpch_id),
             decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(quality_name, 'Empty_String', null, quality_name),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pqdul.pqd_id,
                     substr(max(case
                                  when pqdul.pcpch_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pqdul.pcpch_id
                                end),
                            24) pcpch_id,
                     substr(max(case
                                  when pqdul.pcpq_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pqdul.pcpq_id
                                end),
                            24) pcpq_id,
                     substr(max(case
                                  when pqdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pqdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pqdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pqdul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pqdul.quality_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pqdul.quality_name
                                end),
                            24) quality_name,
                     gvc_dbd_id
                from pqdul_payable_quality_dtl_ul pqdul,
                     axs_action_summary           axs,
                     dbd_database_dump            dbd_ul
               where axs.process = gvc_process
                 and pqdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pqdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pqdul.pqd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pqd_data',
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
  procedure sp_phy_create_pcepc_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcepc_pc_elem_payable_content
      (pcepc_id,
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
       dbd_id,
       process_id)
      select decode(pcepc_id, 'Empty_String', null, pcepc_id),
             decode(range_min_op, 'Empty_String', null, range_min_op),
             decode(range_min_value, 'Empty_String', null, range_min_value),
             decode(range_max_op, 'Empty_String', null, range_max_op),
             decode(range_max_value, 'Empty_String', null, range_max_value),
             decode(payable_formula_id,
                    'Empty_String',
                    null,
                    payable_formula_id),
             decode(payable_content_value,
                    'Empty_String',
                    null,
                    payable_content_value),
             decode(payable_content_unit_id,
                    'Empty_String',
                    null,
                    payable_content_unit_id),
             decode(assay_deduction, 'Empty_String', null, assay_deduction),
             decode(assay_deduction_unit_id,
                    'Empty_String',
                    null,
                    assay_deduction_unit_id),
             decode(include_ref_charges,
                    'Empty_String',
                    null,
                    include_ref_charges),
             decode(refining_charge_value,
                    'Empty_String',
                    null,
                    refining_charge_value),
             decode(refining_charge_unit_id,
                    'Empty_String',
                    null,
                    refining_charge_unit_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(pcpch_id, 'Empty_String', null, pcpch_id),
             decode(position, 'Empty_String', null, position),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcepcul.pcepc_id,
                     substr(max(case
                                  when pcepcul.range_min_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.range_min_op
                                end),
                            24) range_min_op,
                     substr(max(case
                                  when pcepcul.range_min_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.range_min_value
                                end),
                            24) range_min_value,
                     substr(max(case
                                  when pcepcul.range_max_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.range_max_op
                                end),
                            24) range_max_op,
                     substr(max(case
                                  when pcepcul.range_max_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.range_max_value
                                end),
                            24) range_max_value,
                     substr(max(case
                                  when pcepcul.payable_formula_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.payable_formula_id
                                end),
                            24) payable_formula_id,
                     substr(max(case
                                  when pcepcul.payable_content_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.payable_content_value
                                end),
                            24) payable_content_value,
                     substr(max(case
                                  when pcepcul.payable_content_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.payable_content_unit_id
                                end),
                            24) payable_content_unit_id,
                     substr(max(case
                                  when pcepcul.assay_deduction is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.assay_deduction
                                end),
                            24) assay_deduction,
                     substr(max(case
                                  when pcepcul.assay_deduction_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.assay_deduction_unit_id
                                end),
                            24) assay_deduction_unit_id,
                     substr(max(case
                                  when pcepcul.include_ref_charges is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.include_ref_charges
                                end),
                            24) include_ref_charges,
                     substr(max(case
                                  when pcepcul.refining_charge_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.refining_charge_value
                                end),
                            24) refining_charge_value,
                     substr(max(case
                                  when pcepcul.refining_charge_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.refining_charge_unit_id
                                end),
                            24) refining_charge_unit_id,
                     substr(max(case
                                  when pcepcul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcepcul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcepcul.pcpch_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.pcpch_id
                                end),
                            24) pcpch_id,
                     substr(max(case
                                  when pcepcul.position is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcepcul.position
                                end),
                            24) position,
                     gvc_dbd_id
                from pcepcul_elem_payble_content_ul pcepcul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and pcepcul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcepcul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcepcul.pcepc_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcepc_data',
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
  procedure sp_phy_create_pcth_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into pcth_pc_treatment_header
      (pcth_id,
       internal_contract_ref_no,
       range_type,
       range_unit_id,
       price_unit_id,
       slab_tier,
       version,
       is_active,
       dbd_id,
       process_id)
      select decode(pcth_id, 'Empty_String', null, pcth_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(range_type, 'Empty_String', null, range_type),
             decode(range_unit_id, 'Empty_String', null, range_unit_id),
             decode(price_unit_id, 'Empty_String', null, price_unit_id),
             decode(slab_tier, 'Empty_String', null, slab_tier),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcthul.pcth_id,
                     substr(max(case
                                  when pcthul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcthul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcthul.range_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcthul.range_type
                                end),
                            24) range_type,
                     substr(max(case
                                  when pcthul.range_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcthul.range_unit_id
                                end),
                            24) range_unit_id,
                     
                     substr(max(case
                                  when pcthul.price_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcthul.price_unit_id
                                end),
                            24) price_unit_id,
                     substr(max(case
                                  when pcthul.slab_tier is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcthul.slab_tier
                                end),
                            24) slab_tier,
                     substr(max(case
                                  when pcthul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcthul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcthul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcthul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcthul_treatment_header_ul pcthul,
                     axs_action_summary         axs,
                     dbd_database_dump          dbd_ul
               where axs.process = gvc_process
                 and pcthul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcthul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcthul.pcth_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcth_data',
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

  procedure sp_phy_create_ted_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert all into ted_treatment_element_details
      (ted_id,
       pcth_id,
       element_id,
       version,
       is_active,
       element_name,
       dbd_id,
       process_id)
      select decode(ted_id, 'Empty_String', null, ted_id),
             decode(pcth_id, 'Empty_String', null, pcth_id),
             decode(element_id, 'Empty_String', null, element_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(element_name, 'Empty_String', null, element_name),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select tedul.ted_id,
                     substr(max(case
                                  when tedul.pcth_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tedul.pcth_id
                                end),
                            24) pcth_id,
                     substr(max(case
                                  when tedul.element_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tedul.element_id
                                end),
                            24) element_id,
                     substr(max(case
                                  when tedul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tedul.version
                                end),
                            24) version,
                     
                     substr(max(case
                                  when tedul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tedul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when tedul.element_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tedul.element_name
                                end),
                            24) element_name,
                     gvc_dbd_id
                from tedul_treatment_element_dtl_ul tedul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and tedul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and tedul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by tedul.ted_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_ted_data',
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
  procedure sp_phy_create_tqd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into tqd_treatment_quality_details
      (tqd_id, pcth_id, pcpq_id, version, is_active, quality_name, dbd_id,process_id)
      select decode(tqd_id, 'Empty_String', null, tqd_id),
             decode(pcth_id, 'Empty_String', null, pcth_id),
             decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(quality_name, 'Empty_String', null, quality_name),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select tqdul.tqd_id,
                     substr(max(case
                                  when tqdul.pcth_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tqdul.pcth_id
                                end),
                            24) pcth_id,
                     substr(max(case
                                  when tqdul.pcpq_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tqdul.pcpq_id
                                end),
                            24) pcpq_id,
                     substr(max(case
                                  when tqdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tqdul.version
                                end),
                            24) version,
                     
                     substr(max(case
                                  when tqdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tqdul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when tqdul.quality_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   tqdul.quality_name
                                end),
                            24) quality_name,
                     gvc_dbd_id
                from tqdul_treatment_quality_dtl_ul tqdul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and tqdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and tqdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by tqdul.tqd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_tqd_data',
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

  procedure sp_phy_create_pcetc_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcetc_pc_elem_treatment_charge
      (pcetc_id,
       pcth_id,
       range_min_op,
       range_min_value,
       range_max_op,
       range_max_value,
       charge_type,
       position,
       treatment_charge,
       treatment_charge_unit_id,
       weight_type,
       charge_basis,
       esc_desc_value,
       esc_desc_unit_id,
       version,
       is_active,
       dbd_id,
       process_id)
      select decode(pcetc_id, 'Empty_String', null, pcetc_id),
             decode(pcth_id, 'Empty_String', null, pcth_id),
             decode(range_min_op, 'Empty_String', null, range_min_op),
             decode(range_min_value, 'Empty_String', null, range_min_value),
             decode(range_max_op, 'Empty_String', null, range_max_op),
             decode(range_max_value, 'Empty_String', null, range_max_value),
             decode(charge_type, 'Empty_String', null, charge_type),
             decode(position, 'Empty_String', null, position),
             decode(treatment_charge,
                    'Empty_String',
                    null,
                    treatment_charge),
             decode(treatment_charge_unit_id,
                    'Empty_String',
                    null,
                    treatment_charge_unit_id),
             decode(weight_type, 'Empty_String', null, weight_type),
             decode(charge_basis, 'Empty_String', null, charge_basis),
             decode(esc_desc_value, 'Empty_String', null, esc_desc_value),
             decode(esc_desc_unit_id,
                    'Empty_String',
                    null,
                    esc_desc_unit_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcetcul.pcetc_id,
                     substr(max(case
                                  when pcetcul.pcth_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.pcth_id
                                end),
                            24) pcth_id,
                     substr(max(case
                                  when pcetcul.range_min_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.range_min_op
                                end),
                            24) range_min_op,
                     substr(max(case
                                  when pcetcul.range_min_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.range_min_value
                                end),
                            24) range_min_value,
                     
                     substr(max(case
                                  when pcetcul.range_max_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.range_max_op
                                end),
                            24) range_max_op,
                     substr(max(case
                                  when pcetcul.range_max_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.range_max_value
                                end),
                            24) range_max_value,
                     substr(max(case
                                  when pcetcul.charge_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.charge_type
                                end),
                            24) charge_type,
                     substr(max(case
                                  when pcetcul.position is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.position
                                end),
                            24) position,
                     
                     substr(max(case
                                  when pcetcul.treatment_charge is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.treatment_charge
                                end),
                            24) treatment_charge,
                     substr(max(case
                                  when pcetcul.treatment_charge_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.treatment_charge_unit_id
                                end),
                            24) treatment_charge_unit_id,
                     substr(max(case
                                  when pcetcul.weight_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.weight_type
                                end),
                            24) weight_type,
                     substr(max(case
                                  when pcetcul.charge_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.charge_basis
                                end),
                            24) charge_basis,
                     
                     substr(max(case
                                  when pcetcul.esc_desc_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.esc_desc_value
                                end),
                            24) esc_desc_value,
                     substr(max(case
                                  when pcetcul.esc_desc_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.esc_desc_unit_id
                                end),
                            24) esc_desc_unit_id,
                     substr(max(case
                                  when pcetcul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcetcul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcetcul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcetcul_elem_treatmnt_chrg_ul pcetcul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pcetcul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcetcul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcetcul.pcetc_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcetc_data',
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
  procedure sp_phy_create_pcar_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into pcar_pc_assaying_rules
      (pcar_id,
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
       dbd_id,
       process_id)
      select decode(pcar_id, 'Empty_String', null, pcar_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(element_id, 'Empty_String', null, element_id),
             decode(final_assay_basis_id,
                    'Empty_String',
                    null,
                    final_assay_basis_id),
             decode(comparision, 'Empty_String', null, comparision),
             decode(split_limit_basis,
                    'Empty_String',
                    null,
                    split_limit_basis),
             decode(split_limit, 'Empty_String', null, split_limit),
             decode(split_limit_unit_id,
                    'Empty_String',
                    null,
                    split_limit_unit_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(element_name, 'Empty_String', null, element_name),
             decode(quality_id, 'Empty_String', null, quality_id),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcarul.pcar_id,
                     substr(max(case
                                  when pcarul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcarul.element_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.element_id
                                end),
                            24) element_id,
                     substr(max(case
                                  when pcarul.final_assay_basis_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.final_assay_basis_id
                                end),
                            24) final_assay_basis_id,
                     
                     substr(max(case
                                  when pcarul.comparision is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.comparision
                                end),
                            24) comparision,
                     substr(max(case
                                  when pcarul.split_limit_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.split_limit_basis
                                end),
                            24) split_limit_basis,
                     substr(max(case
                                  when pcarul.split_limit is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.split_limit
                                end),
                            24) split_limit,
                     substr(max(case
                                  when pcarul.split_limit_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.split_limit_unit_id
                                end),
                            24) split_limit_unit_id,
                     
                     substr(max(case
                                  when pcarul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcarul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcarul.element_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.element_name
                                end),
                            24) element_name,
                     substr(max(case
                                  when pcarul.quality_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcarul.quality_id
                                end),
                            24) quality_id,
                     gvc_dbd_id
                from pcarul_assaying_rules_ul pcarul,
                     axs_action_summary       axs,
                     dbd_database_dump        dbd_ul
               where axs.process = gvc_process
                 and pcarul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcarul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcarul.pcar_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcar_data',
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

  procedure sp_phy_create_pcaesl_data(pc_corporate_id varchar2,
                                      pd_trade_date   date,
                                      pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcaesl_assay_elem_split_limits
      (pcaesl_id,
       pcar_id,
       assay_min_op,
       assay_min_value,
       assay_max_op,
       assay_max_value,
       applicable_value,
       version,
       is_active,
       dbd_id,
       process_id)
      select decode(pcaesl_id, 'Empty_String', null, pcaesl_id),
             decode(pcar_id, 'Empty_String', null, pcar_id),
             decode(assay_min_op, 'Empty_String', null, assay_min_op),
             decode(assay_min_value, 'Empty_String', null, assay_min_value),
             decode(assay_max_op, 'Empty_String', null, assay_max_op),
             decode(assay_max_value, 'Empty_String', null, assay_max_value),
             decode(applicable_value,
                    'Empty_String',
                    null,
                    applicable_value),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcaeslul.pcaesl_id,
                     substr(max(case
                                  when pcaeslul.pcar_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaeslul.pcar_id
                                end),
                            24) pcar_id,
                     substr(max(case
                                  when pcaeslul.assay_min_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaeslul.assay_min_op
                                end),
                            24) assay_min_op,
                     substr(max(case
                                  when pcaeslul.assay_min_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaeslul.assay_min_value
                                end),
                            24) assay_min_value,
                     
                     substr(max(case
                                  when pcaeslul.assay_max_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaeslul.assay_max_op
                                end),
                            24) assay_max_op,
                     substr(max(case
                                  when pcaeslul.assay_max_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaeslul.assay_max_value
                                end),
                            24) assay_max_value,
                     substr(max(case
                                  when pcaeslul.applicable_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaeslul.applicable_value
                                end),
                            24) applicable_value,
                     
                     substr(max(case
                                  when pcaeslul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaeslul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcaeslul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaeslul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcaeslul_assay_elm_splt_lmt_ul pcaeslul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and pcaeslul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcaeslul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcaeslul.pcaesl_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcaesl_data',
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
  procedure sp_phy_create_arqd_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into arqd_assay_quality_details
      (arqd_id, pcar_id, pcpq_id, version, is_active, quality_name, dbd_id,process_id)
      select decode(arqd_id, 'Empty_String', null, arqd_id),
             decode(pcar_id, 'Empty_String', null, pcar_id),
             decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(quality_name, 'Empty_String', null, quality_name),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select arqdul.arqd_id,
                     substr(max(case
                                  when arqdul.pcar_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   arqdul.pcar_id
                                end),
                            24) pcar_id,
                     substr(max(case
                                  when arqdul.pcpq_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   arqdul.pcpq_id
                                end),
                            24) pcpq_id,
                     substr(max(case
                                  when arqdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   arqdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when arqdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   arqdul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when arqdul.quality_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   arqdul.quality_name
                                end),
                            24) quality_name,
                     gvc_dbd_id
                from arqdul_assay_quality_dtl_ul arqdul,
                     axs_action_summary          axs,
                     dbd_database_dump           dbd_ul
               where axs.process = gvc_process
                 and arqdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and arqdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by arqdul.arqd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_arqd_data',
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
  procedure sp_phy_create_pcaph_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcaph_pc_attr_penalty_header
      (pcaph_id,
       internal_contract_ref_no,
       attribute_type,
       range_unit_id,
       slab_tier,
       version,
       is_active,
       dbd_id,
       process_id)
      select decode(pcaph_id, 'Empty_String', null, pcaph_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(attribute_type, 'Empty_String', null, attribute_type),
             decode(range_unit_id, 'Empty_String', null, range_unit_id),
             decode(slab_tier, 'Empty_String', null, slab_tier),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcaphul.pcaph_id,
                     substr(max(case
                                  when pcaphul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaphul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcaphul.attribute_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaphul.attribute_type
                                end),
                            24) attribute_type,
                     substr(max(case
                                  when pcaphul.range_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaphul.range_unit_id
                                end),
                            24) range_unit_id,
                     substr(max(case
                                  when pcaphul.slab_tier is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaphul.slab_tier
                                end),
                            24) slab_tier,
                     substr(max(case
                                  when pcaphul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaphul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcaphul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcaphul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcaphul_attr_penalty_header_ul pcaphul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and pcaphul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcaphul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcaphul.pcaph_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcaph_data',
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
  procedure sp_phy_create_pcap_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into pcap_pc_attribute_penalty
      (pcap_id,
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
       dbd_id,
       process_id)
      select decode(pcap_id, 'Empty_String', null, pcap_id),
             decode(range_min_op, 'Empty_String', null, range_min_op),
             decode(range_min_value, 'Empty_String', null, range_min_value),
             decode(range_max_op, 'Empty_String', null, range_max_op),
             decode(range_max_value, 'Empty_String', null, range_max_value),
             decode(penalty_charge_type,
                    'Empty_String',
                    null,
                    penalty_charge_type),
             decode(penalty_basis, 'Empty_String', null, penalty_basis),
             decode(penalty_amount, 'Empty_String', null, penalty_amount),
             decode(penalty_unit_id, 'Empty_String', null, penalty_unit_id),
             decode(penalty_weight_type,
                    'Empty_String',
                    null,
                    penalty_weight_type),
             decode(per_increase_value,
                    'Empty_String',
                    null,
                    per_increase_value),
             decode(per_increase_unit_id,
                    'Empty_String',
                    null,
                    per_increase_unit_id),
             decode(deducted_payable_element,
                    'Empty_String',
                    null,
                    deducted_payable_element),
             decode(deducted_payable_value,
                    'Empty_String',
                    null,
                    deducted_payable_value),
             decode(deducted_payable_unit_id,
                    'Empty_String',
                    null,
                    deducted_payable_unit_id),
             decode(charge_basis, 'Empty_String', null, charge_basis),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(pcaph_id, 'Empty_String', null, pcaph_id),
             decode(position, 'Empty_String', null, position),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcapul.pcap_id,
                     substr(max(case
                                  when pcapul.range_min_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.range_min_op
                                end),
                            24) range_min_op,
                     substr(max(case
                                  when pcapul.range_min_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.range_min_value
                                end),
                            24) range_min_value,
                     substr(max(case
                                  when pcapul.range_max_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.range_max_op
                                end),
                            24) range_max_op,
                     substr(max(case
                                  when pcapul.range_max_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.range_max_value
                                end),
                            24) range_max_value,
                     substr(max(case
                                  when pcapul.penalty_charge_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.penalty_charge_type
                                end),
                            24) penalty_charge_type,
                     substr(max(case
                                  when pcapul.penalty_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.penalty_basis
                                end),
                            24) penalty_basis,
                     substr(max(case
                                  when pcapul.penalty_amount is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.penalty_amount
                                end),
                            24) penalty_amount,
                     substr(max(case
                                  when pcapul.penalty_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.penalty_unit_id
                                end),
                            24) penalty_unit_id,
                     substr(max(case
                                  when pcapul.penalty_weight_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.penalty_weight_type
                                end),
                            24) penalty_weight_type,
                     substr(max(case
                                  when pcapul.per_increase_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.per_increase_value
                                end),
                            24) per_increase_value,
                     substr(max(case
                                  when pcapul.per_increase_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.per_increase_unit_id
                                end),
                            24) per_increase_unit_id,
                     substr(max(case
                                  when pcapul.deducted_payable_element is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.deducted_payable_element
                                end),
                            24) deducted_payable_element,
                     substr(max(case
                                  when pcapul.deducted_payable_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.deducted_payable_value
                                end),
                            24) deducted_payable_value,
                     substr(max(case
                                  when pcapul.deducted_payable_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.deducted_payable_unit_id
                                end),
                            24) deducted_payable_unit_id,
                     substr(max(case
                                  when pcapul.charge_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.charge_basis
                                end),
                            24) charge_basis,
                     substr(max(case
                                  when pcapul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcapul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when pcapul.pcaph_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.pcaph_id
                                end),
                            24) pcaph_id,
                     substr(max(case
                                  when pcapul.position is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcapul.position
                                end),
                            24) position,
                     gvc_dbd_id
                from pcapul_attribute_penalty_ul pcapul,
                     axs_action_summary          axs,
                     dbd_database_dump           dbd_ul
               where axs.process = gvc_process
                 and pcapul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcapul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcapul.pcap_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcap_data',
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

  procedure sp_phy_create_pqdp_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pqd_penalty_quality_details
      (pqd_id, pcaph_id, pcpq_id, version, is_active, dbd_id,process_id)
      select decode(pqd_id, 'Empty_String', null, pqd_id),
             decode(pcaph_id, 'Empty_String', null, pcaph_id),
             decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcdul.pqd_id,
                     substr(max(case
                                  when pcdul.pcaph_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdul.pcaph_id
                                end),
                            24) pcaph_id,
                     substr(max(case
                                  when pcdul.pcpq_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdul.pcpq_id
                                end),
                            24) pcpq_id,
                     
                     substr(max(case
                                  when pcdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcdul.is_active
                                end),
                            24) is_active,
                     
                     gvc_dbd_id
                from pqdul_penalty_quality_dtl_ul pcdul,
                     axs_action_summary           axs,
                     dbd_database_dump            dbd_ul
               where axs.process = gvc_process
                 and pcdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcdul.pqd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pqdp_data',
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
  procedure sp_phy_create_pad_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into pad_penalty_attribute_details
      (pad_id, pcaph_id, element_id, pqpa_id, version, is_active, dbd_id, process_id)
      select decode(pad_id, 'Empty_String', null, pad_id),
             decode(pcaph_id, 'Empty_String', null, pcaph_id),
             decode(element_id, 'Empty_String', null, element_id),
             decode(pqpa_id, 'Empty_String', null, pqpa_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select padul.pad_id,
                     substr(max(case
                                  when padul.pcaph_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   padul.pcaph_id
                                end),
                            24) pcaph_id,
                     substr(max(case
                                  when padul.element_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   padul.element_id
                                end),
                            24) element_id,
                     substr(max(case
                                  when padul.pqpa_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   padul.pqpa_id
                                end),
                            24) pqpa_id,
                     
                     substr(max(case
                                  when padul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   padul.version
                                end),
                            24) version,
                     substr(max(case
                                  when padul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   padul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from padul_penalty_attribute_dtl_ul padul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and padul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and padul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by padul.pad_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pad_data',
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
  procedure sp_phy_create_pcrh_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into pcrh_pc_refining_header
      (pcrh_id,
       internal_contract_ref_no,
       range_type,
       range_unit_id,
       price_unit_id,
       slab_tier,
       version,
       is_active,
       dbd_id,
       process_id)
      select decode(pcrh_id, 'Empty_String', null, pcrh_id),
             decode(internal_contract_ref_no,
                    'Empty_String',
                    null,
                    internal_contract_ref_no),
             decode(range_type, 'Empty_String', null, range_type),
             decode(range_unit_id, 'Empty_String', null, range_unit_id),
             decode(price_unit_id, 'Empty_String', null, price_unit_id),
             decode(slab_tier, 'Empty_String', null, slab_tier),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcrhul.pcrh_id,
                     substr(max(case
                                  when pcrhul.internal_contract_ref_no is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcrhul.internal_contract_ref_no
                                end),
                            24) internal_contract_ref_no,
                     substr(max(case
                                  when pcrhul.range_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcrhul.range_type
                                end),
                            24) range_type,
                     substr(max(case
                                  when pcrhul.range_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcrhul.range_unit_id
                                end),
                            24) range_unit_id,
                     substr(max(case
                                  when pcrhul.price_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcrhul.price_unit_id
                                end),
                            24) price_unit_id,
                     substr(max(case
                                  when pcrhul.slab_tier is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcrhul.slab_tier
                                end),
                            24) slab_tier,
                     
                     substr(max(case
                                  when pcrhul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcrhul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcrhul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcrhul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcrhul_refining_header_ul pcrhul,
                     axs_action_summary        axs,
                     dbd_database_dump         dbd_ul
               where axs.process = gvc_process
                 and pcrhul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcrhul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcrhul.pcrh_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcrh_data',
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
  procedure sp_phy_create_rqd_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into rqd_refining_quality_details
      (rqd_id, pcrh_id, pcpq_id, version, is_active, quality_name, dbd_id,process_id)
      select decode(rqd_id, 'Empty_String', null, rqd_id),
             decode(pcrh_id, 'Empty_String', null, pcrh_id),
             decode(pcpq_id, 'Empty_String', null, pcpq_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(quality_name, 'Empty_String', null, quality_name),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select rqdul.rqd_id,
                     substr(max(case
                                  when rqdul.pcrh_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   rqdul.pcrh_id
                                end),
                            24) pcrh_id,
                     substr(max(case
                                  when rqdul.pcpq_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   rqdul.pcpq_id
                                end),
                            24) pcpq_id,
                     
                     substr(max(case
                                  when rqdul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   rqdul.version
                                end),
                            24) version,
                     substr(max(case
                                  when rqdul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   rqdul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when rqdul.quality_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   rqdul.quality_name
                                end),
                            24) quality_name,
                     gvc_dbd_id
                from rqdul_refining_quality_dtl_ul rqdul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and rqdul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and rqdul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by rqdul.rqd_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_rqd_data',
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

  procedure sp_phy_create_red_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into red_refining_element_details
      (red_id,
       pcrh_id,
       element_id,
       version,
       is_active,
       element_name,
       dbd_id,
       process_id)
      select decode(red_id, 'Empty_String', null, red_id),
             decode(pcrh_id, 'Empty_String', null, pcrh_id),
             decode(element_id, 'Empty_String', null, element_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             decode(element_name, 'Empty_String', null, element_name),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select redul.red_id,
                     substr(max(case
                                  when redul.pcrh_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   redul.pcrh_id
                                end),
                            24) pcrh_id,
                     substr(max(case
                                  when redul.element_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   redul.element_id
                                end),
                            24) element_id,
                     
                     substr(max(case
                                  when redul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   redul.version
                                end),
                            24) version,
                     substr(max(case
                                  when redul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   redul.is_active
                                end),
                            24) is_active,
                     substr(max(case
                                  when redul.element_name is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   redul.element_name
                                end),
                            24) element_name,
                     gvc_dbd_id
                from redul_refining_element_dtl_ul redul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and redul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and redul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by redul.red_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_red_data',
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
  procedure sp_phy_create_pcerc_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
    procedure name                                           : sp_create_pcipf_data
    author                                                   : 
    created date                                             : 12TH JAN 2011
    purpose                                                  : populate pcm table data for day end processing
    parameters
                                                             : pc_corporate_id - corporate id
                                                             : pd_trade_date    - day end date
    modified date  :
    modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    insert into pcerc_pc_elem_refining_charge
      (pcerc_id,
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
       dbd_id,
       process_id)
      select decode(pcerc_id, 'Empty_String', null, pcerc_id),
             decode(pcrh_id, 'Empty_String', null, pcrh_id),
             decode(range_min_op, 'Empty_String', null, range_min_op),
             decode(range_min_value, 'Empty_String', null, range_min_value),
             decode(range_max_op, 'Empty_String', null, range_max_op),
             decode(range_max_value, 'Empty_String', null, range_max_value),
             decode(charge_type, 'Empty_String', null, charge_type),
             decode(position, 'Empty_String', null, position),
             decode(refining_charge, 'Empty_String', null, refining_charge),
             decode(refining_charge_unit_id,
                    'Empty_String',
                    null,
                    refining_charge_unit_id),
             decode(weight_type, 'Empty_String', null, weight_type),
             decode(charge_basis, 'Empty_String', null, charge_basis),
             decode(esc_desc_value, 'Empty_String', null, esc_desc_value),
             decode(esc_desc_unit_id,
                    'Empty_String',
                    null,
                    esc_desc_unit_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select pcercul.pcerc_id,
                     substr(max(case
                                  when pcercul.pcrh_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.pcrh_id
                                end),
                            24) pcrh_id,
                     substr(max(case
                                  when pcercul.range_min_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.range_min_op
                                end),
                            24) range_min_op,
                     substr(max(case
                                  when pcercul.range_min_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.range_min_value
                                end),
                            24) range_min_value,
                     substr(max(case
                                  when pcercul.range_max_op is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.range_max_op
                                end),
                            24) range_max_op,
                     substr(max(case
                                  when pcercul.range_max_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.range_max_value
                                end),
                            24) range_max_value,
                     substr(max(case
                                  when pcercul.charge_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.charge_type
                                end),
                            24) charge_type,
                     substr(max(case
                                  when pcercul.position is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.position
                                end),
                            24) position,
                     substr(max(case
                                  when pcercul.refining_charge is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.refining_charge
                                end),
                            24) refining_charge,
                     substr(max(case
                                  when pcercul.refining_charge_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.refining_charge_unit_id
                                end),
                            24) refining_charge_unit_id,
                     substr(max(case
                                  when pcercul.weight_type is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.weight_type
                                end),
                            24) weight_type,
                     substr(max(case
                                  when pcercul.charge_basis is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.charge_basis
                                end),
                            24) charge_basis,
                     substr(max(case
                                  when pcercul.esc_desc_value is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.esc_desc_value
                                end),
                            24) esc_desc_value,
                     substr(max(case
                                  when pcercul.esc_desc_unit_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.esc_desc_unit_id
                                end),
                            24) esc_desc_unit_id,
                     substr(max(case
                                  when pcercul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.version
                                end),
                            24) version,
                     substr(max(case
                                  when pcercul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   pcercul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from pcercul_elem_refing_charge_ul pcercul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and pcercul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and pcercul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by pcercul.pcerc_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_pcerc_data',
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
  procedure sp_phy_create_dith_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
        procedure name                                           : sp_create_dith_data
        author                                                   : 
        created date                                             : 12TH JAN 2011
        purpose                                                  : populate pcm table data for day end processing
        parameters
                                                                 : pc_corporate_id - corporate id
                                                                 : pd_trade_date    - day end date
        modified date  :
        modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into dith_di_treatment_header
      (dith_id, pcdi_id, pcth_id, version, is_active, dbd_id, process_id)
      select decode(dith_id, 'Empty_String', null, dith_id),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(pcth_id, 'Empty_String', null, pcth_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select dithul.dith_id,
                     substr(max(case
                                  when dithul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dithul.pcdi_id
                                end),
                            24) pcdi_id,
                     substr(max(case
                                  when dithul.pcth_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dithul.pcth_id
                                end),
                            24) pcth_id,
                     substr(max(case
                                  when dithul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dithul.version
                                end),
                            24) version,
                     substr(max(case
                                  when dithul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dithul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from dithul_di_treatment_header_ul dithul,
                     axs_action_summary            axs,
                     dbd_database_dump             dbd_ul
               where axs.process = gvc_process
                 and dithul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and dithul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by dithul.dith_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_dith_data',
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
  procedure sp_phy_create_dirh_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
        procedure name                                           : sp_create_dirh_data
        author                                                   : 
        created date                                             : 12TH JAN 2011
        purpose                                                  : populate pcm table data for day end processing
        parameters
                                                                 : pc_corporate_id - corporate id
                                                                 : pd_trade_date    - day end date
        modified date  :
        modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into dirh_di_refining_header
      (dirh_id, pcdi_id, pcrh_id, version, is_active, dbd_id, process_id)
      select decode(dirh_id, 'Empty_String', null, dirh_id),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(pcrh_id, 'Empty_String', null, pcrh_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select dirhul.dirh_id,
                     substr(max(case
                                  when dirhul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dirhul.pcdi_id
                                end),
                            24) pcdi_id,
                     substr(max(case
                                  when dirhul.pcrh_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dirhul.pcrh_id
                                end),
                            24) pcrh_id,
                     substr(max(case
                                  when dirhul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dirhul.version
                                end),
                            24) version,
                     substr(max(case
                                  when dirhul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dirhul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from dirhul_di_refining_header_ul dirhul,
                     axs_action_summary           axs,
                     dbd_database_dump            dbd_ul
               where axs.process = gvc_process
                 and dirhul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and dirhul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by dirhul.dirh_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_dirh_data',
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

  procedure sp_phy_create_diph_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
        procedure name                                           : sp_create_diph_data
        author                                                   : 
        created date                                             : 12TH JAN 2011
        purpose                                                  : populate pcm table data for day end processing
        parameters
                                                                 : pc_corporate_id - corporate id
                                                                 : pd_trade_date    - day end date
        modified date  :
        modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into diph_di_penalty_header
      (diph_id, pcdi_id, pcaph_id, version, is_active, dbd_id, process_id)
      select decode(diph_id, 'Empty_String', null, diph_id),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(pcaph_id, 'Empty_String', null, pcaph_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select diphul.diph_id,
                     substr(max(case
                                  when diphul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   diphul.pcdi_id
                                end),
                            24) pcdi_id,
                     substr(max(case
                                  when diphul.pcaph_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   diphul.pcaph_id
                                end),
                            24) pcaph_id,
                     substr(max(case
                                  when diphul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   diphul.version
                                end),
                            24) version,
                     substr(max(case
                                  when diphul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   diphul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from diphul_di_penalty_header_ul diphul,
                     axs_action_summary          axs,
                     dbd_database_dump           dbd_ul
               where axs.process = gvc_process
                 and diphul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and diphul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by diphul.diph_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_diph_data',
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
  procedure sp_phy_create_cipq_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
        procedure name                                           : sp_create_cipq_data
        author                                                   : 
        created date                                             : 12TH OCT 2011
        purpose                                                  : populate CIPQ table data for day end processing
        parameters
                                                                 : pc_corporate_id - corporate id
                                                                 : pd_trade_date    - day end date
        modified date  :
        modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into cipq_contract_item_payable_qty
      (cipq_id,
       internal_contract_item_ref_no,
       element_id,
       payable_qty,
       qty_unit_id,
       version,
       is_active,
       qty_type,
       internal_action_ref_no,
       dbd_id,
       process_id)
      select cipqul.cipq_id,
             substr(max(case
                          when cipqul.internal_contract_item_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cipqul.internal_contract_item_ref_no
                        end),
                    24) internal_contract_item_ref_no,
             substr(max(case
                          when cipqul.element_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cipqul.element_id
                        end),
                    24) element_id,
             round(sum(nvl(cipqul.payable_qty_delta, 0)), 10),
             substr(max(case
                          when cipqul.qty_unit_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cipqul.qty_unit_id
                        end),
                    24) qty_unit_id,
             substr(max(case
                          when cipqul.version is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cipqul.version
                        end),
                    24) version,
             substr(max(case
                          when cipqul.is_active is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cipqul.is_active
                        end),
                    24) is_active,
             substr(max(case
                          when cipqul.qty_type is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cipqul.qty_type
                        end),
                    24) qty_type,
             substr(max(case
                          when cipqul.internal_action_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           cipqul.internal_action_ref_no
                        end),
                    24) internal_action_ref_no,
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from cipql_ctrt_itm_payable_qty_log cipqul,
             axs_action_summary             axs,
             dbd_database_dump              dbd_ul
       where axs.process = gvc_process
         and cipqul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.eff_date <= pd_trade_date
         and axs.corporate_id = pc_corporate_id
         and cipqul.dbd_id = dbd_ul.dbd_id
         and dbd_ul.corporate_id = pc_corporate_id
         and dbd_ul.process = gvc_process
       group by cipqul.cipq_id;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_cipq_data',
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

  procedure sp_phy_create_dipq_data(pc_corporate_id varchar2,
                                    pd_trade_date   date,
                                    pc_user_id      varchar2)
  /******************************************************************************************************************************************
        procedure name                                           : sp_create_dipq_data
        author                                                   : 
        created date                                             : 12TH JAN 2011
        purpose                                                  : populate DIPQ table data for day end processing
        parameters
                                                                 : pc_corporate_id - corporate id
                                                                 : pd_trade_date    - day end date
        modified date  :
        modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into dipq_delivery_item_payable_qty
      (dipq_id,
       pcdi_id,
       element_id,
       payable_qty,
       qty_unit_id,
       price_option_call_off_status,
       version,
       is_active,
       is_price_optionality_present,
       qty_type,
       internal_action_ref_no,
       dbd_id,
       process_id)
      select dipqul.dipq_id,
             substr(max(case
                          when dipqul.pcdi_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.pcdi_id
                        end),
                    24) pcdi_id,
             substr(max(case
                          when dipqul.element_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.element_id
                        end),
                    24) element_id,
             round(sum(nvl(dipqul.payable_qty_delta, 0)), 10),
             substr(max(case
                          when dipqul.qty_unit_id is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.qty_unit_id
                        end),
                    24) qty_unit_id,
             substr(max(case
                          when dipqul.price_option_call_off_status is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.price_option_call_off_status
                        end),
                    24) price_option_call_off_status,
             substr(max(case
                          when dipqul.version is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.version
                        end),
                    24) version,
             substr(max(case
                          when dipqul.is_active is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.is_active
                        end),
                    24) is_active,
             substr(max(case
                          when dipqul.is_price_optionality_present is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.is_price_optionality_present
                        end),
                    24) is_price_optionality_present,
             substr(max(case
                          when dipqul.qty_type is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.qty_type
                        end),
                    24) qty_type,
             substr(max(case
                          when dipqul.internal_action_ref_no is not null then
                           to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                           dipqul.internal_action_ref_no
                        end),
                    24) internal_action_ref_no,
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from dipql_del_itm_payble_qty_log dipqul,
             axs_action_summary           axs,
             dbd_database_dump            dbd_ul
       where axs.process = gvc_process
         and dipqul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.eff_date <= pd_trade_date
         and axs.corporate_id = pc_corporate_id
         and dipqul.dbd_id = dbd_ul.dbd_id
         and dbd_ul.corporate_id = pc_corporate_id
         and dbd_ul.process = gvc_process
       group by dipqul.dipq_id;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_dipq_data',
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

  procedure sp_phy_create_spq_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
  /******************************************************************************************************************************************
        procedure name                                           : sp_create_spq_data
        author                                                   : 
        created date                                             : 28TH OCT 2011
        purpose                                                  : populate SPQ table data for day end processing
        parameters
                                                                 : pc_corporate_id - corporate id
                                                                 : pd_trade_date    - day end date
        modified date  :
        modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  begin
  delete from process_spq where corporate_id = pc_corporate_id;
  commit;
insert into process_spq
  (spq_id,
   internal_gmr_ref_no,
   action_no,
   stock_type,
   internal_grd_ref_no,
   internal_dgrd_ref_no,
   element_id,
   payable_qty,
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
   internal_action_ref_no,
   weg_avg_pricing_assay_id,
   weg_avg_invoice_assay_id,
   dbd_id,
   process_id)
  select spq_id,
         internal_gmr_ref_no,
         action_no,
         stock_type,
         internal_grd_ref_no,
         internal_dgrd_ref_no,
         element_id,
         payable_qty,
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
         decode(pledge_stock_id, 'Empty_String', null, pledge_stock_id) pledge_stock_id,
         decode(gepd_id, 'Empty_String', null, gepd_id) gepd_id,
         assay_header_id,
         is_final_assay,
         pc_corporate_id,
         internal_action_ref_no,
         weg_avg_pricing_assay_id,
         weg_avg_invoice_assay_id,
         gvc_dbd_id,
         gvc_process_id
    from (select spqul.spq_id,
                 substr(max(case
                              when spqul.internal_gmr_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.internal_gmr_ref_no
                            end),
                        24) internal_gmr_ref_no,
                 substr(max(case
                              when spqul.action_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.action_no
                            end),
                        24) action_no,
                 substr(max(case
                              when spqul.stock_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.stock_type
                            end),
                        24) stock_type,
                 substr(max(case
                              when spqul.internal_grd_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.internal_grd_ref_no
                            end),
                        24) internal_grd_ref_no,
                 substr(max(case
                              when spqul.internal_dgrd_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.internal_dgrd_ref_no
                            end),
                        24) internal_dgrd_ref_no,
                 substr(max(case
                              when spqul.element_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.element_id
                            end),
                        24) element_id,
                 round(sum(nvl(spqul.payable_qty_delta, 0)), 10) payable_qty,
                 substr(max(case
                              when spqul.qty_unit_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.qty_unit_id
                            end),
                        24) qty_unit_id,
                 substr(max(case
                              when spqul.version is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.version
                            end),
                        24) version,
                 substr(max(case
                              when spqul.is_active is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.is_active
                            end),
                        24) is_active,
                 substr(max(case
                              when spqul.qty_type is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.qty_type
                            end),
                        24) qty_type,
                 substr(max(case
                              when spqul.activity_action_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.activity_action_id
                            end),
                        24) activity_action_id,
                 substr(max(case
                              when spqul.is_stock_split is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.is_stock_split
                            end),
                        24) is_stock_split,
                 substr(max(case
                              when spqul.supplier_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.supplier_id
                            end),
                        24) supplier_id,
                 substr(max(case
                              when spqul.smelter_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.smelter_id
                            end),
                        24) smelter_id,
                 substr(max(case
                              when spqul.in_process_stock_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.in_process_stock_id
                            end),
                        24) in_process_stock_id,
                 substr(max(case
                              when spqul.free_metal_stock_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.free_metal_stock_id
                            end),
                        24) free_metal_stock_id,
                 round(sum(nvl(spqul.free_metal_qty, 0)), 10) free_metal_qty,
                 round(sum(nvl(spqul.assay_content, 0)), 10) assay_content,
                 substr(max(case
                              when spqul.pledge_stock_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.pledge_stock_id
                            end),
                        24) pledge_stock_id,
                 substr(max(case
                              when spqul.gepd_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.gepd_id
                            end),
                        24) gepd_id,
                 substr(max(case
                              when spqul.assay_header_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.assay_header_id
                            end),
                        24) assay_header_id,
                 substr(max(case
                              when spqul.is_final_assay is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.is_final_assay
                            end),
                        24) is_final_assay,
                 substr(max(case
                              when spqul.corporate_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.corporate_id
                            end),
                        24) corporate_id,
                 substr(max(case
                              when spqul.internal_action_ref_no is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.internal_action_ref_no
                            end),
                        24) internal_action_ref_no,
                 substr(max(case
                              when spqul.weg_avg_pricing_assay_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.weg_avg_pricing_assay_id
                            end),
                        24) weg_avg_pricing_assay_id,
                 substr(max(case
                              when spqul.weg_avg_invoice_assay_id is not null then
                               to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                               spqul.weg_avg_invoice_assay_id
                            end),
                        24) weg_avg_invoice_assay_id,
                 gvc_dbd_id
            from spql_stock_payable_qty_log spqul,
                 axs_action_summary         axs
           where axs.process = gvc_process
             and spqul.internal_action_ref_no = axs.internal_action_ref_no
             and axs.eff_date <= pd_trade_date
             and axs.corporate_id = pc_corporate_id
             and spqul.process = gvc_process
           group by spqul.spq_id);
   commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside process_spq complited');
   sp_gather_stats('process_spq');                           
   /*for cur_spq_update in (select grd.internal_grd_ref_no
                             from process_grd grd
                            where grd.dbd_id = gvc_dbd_id
                            and grd.corporate_id = pc_corporate_id
                              and grd.status = 'Inactive'
                              group by grd.internal_grd_ref_no)
    loop
    vn_row_cnt := vn_row_cnt + 1;
      update process_spq spq
         set spq.is_active = 'N'
       where spq.dbd_id = gvc_dbd_id
       and spq.corporate_id = pc_corporate_id
         and spq.internal_grd_ref_no = cur_spq_update.internal_grd_ref_no;
      if vn_row_cnt >= 500 then
         commit;
         vn_row_cnt := 0;
       end if;
    end loop;*/
    update process_spq spq
     set spq.is_active = 'N'
   where spq.dbd_id = gvc_dbd_id
     and not exists (select 1
            from process_grd grd
           where grd.internal_grd_ref_no = spq.internal_grd_ref_no
             and grd.corporate_id = pc_corporate_id
             and grd.dbd_id = gvc_dbd_id
             and grd.status = 'Active')
             and spq.internal_dgrd_ref_no is null;
 commit;            
update process_spq spq
     set spq.is_active = 'N'
   where spq.dbd_id = gvc_dbd_id
     and not exists (select 1
            from dgrd_delivered_grd grd
           where grd.internal_dgrd_ref_no = spq.internal_dgrd_ref_no
             and grd.dbd_id = gvc_dbd_id
             and grd.status = 'Active')
             and spq.internal_grd_ref_no is null;             
  commit;
   gvn_log_counter := gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                           pd_trade_date,
                           gvc_dbd_id,
                           gvn_log_counter,
                           'inside process_spq is_active updated');        
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_spq_data',
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

  procedure sp_phy_create_dipch_data(pc_corporate_id varchar2,
                                     pd_trade_date   date,
                                     pc_user_id      varchar2)
  /******************************************************************************************************************************************
        procedure name                                           : sp_create_spq_data
        author                                                   : 
        created date                                             : 28TH OCT 2011
        purpose                                                  : populate SPQ table data for day end processing
        parameters
                                                                 : pc_corporate_id - corporate id
                                                                 : pd_trade_date    - day end date
        modified date  :
        modify description :
    ******************************************************************************************************************************************/
   is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into dipch_di_payablecontent_header
      (dipch_id, pcdi_id, pcpch_id, version, is_active, dbd_id, process_id)
      select decode(dipch_id, 'Empty_String', null, dipch_id),
             decode(pcdi_id, 'Empty_String', null, pcdi_id),
             decode(pcpch_id, 'Empty_String', null, pcpch_id),
             decode(version, 'Empty_String', null, version),
             decode(is_active, 'Empty_String', null, is_active),
             gvc_dbd_id,
             pkg_phy_populate_data.gvc_process_id
        from (select dipchul.dipch_id,
                     substr(max(case
                                  when dipchul.pcdi_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dipchul.pcdi_id
                                end),
                            24) pcdi_id,
                     substr(max(case
                                  when dipchul.pcpch_id is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dipchul.pcpch_id
                                end),
                            24) pcpch_id,
                     substr(max(case
                                  when dipchul.version is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dipchul.version
                                end),
                            24) version,
                     
                     substr(max(case
                                  when dipchul.is_active is not null then
                                   to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                   dipchul.is_active
                                end),
                            24) is_active,
                     gvc_dbd_id
                from dipchul_di_payblecon_header_ul dipchul,
                     axs_action_summary             axs,
                     dbd_database_dump              dbd_ul
               where axs.process = gvc_process
                 and dipchul.internal_action_ref_no =
                     axs.internal_action_ref_no
                 and axs.eff_date <= pd_trade_date
                 and axs.corporate_id = pc_corporate_id
                 and dipchul.dbd_id = dbd_ul.dbd_id
                 and dbd_ul.corporate_id = pc_corporate_id
                 and dbd_ul.process = gvc_process
               group by dipchul.dipch_id) t;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_spq_data',
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
  procedure sp_phy_create_invs(pc_corporate_id varchar2,
                               pd_trade_date   date,
                               pc_user_id      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
    insert into invs_inventory_sales
      (internal_inv_id,
       inv_ref_no,
       internal_gmr_ref_no,
       sales_internal_gmr_ref_no,
       internal_grd_ref_no,
       internal_dgrd_ref_no,
       internal_contract_item_ref_no,
       inv_in_action_ref_no,
       inv_status,
       original_inv_qty,
       current_inv_qty,
       inv_qty_id,
       is_active,
       dbd_id,
       product_premium,
       quality_premium,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       price_unit_weight_unit_id,
       price_unit_weight_unit,
       price_unit_weight,
       material_cost_per_unit,
       secondary_cost_per_unit,
       product_premium_per_unit,
       quality_premium_per_unit,
       process_id,
       stock_qty)
      select t.inv_id,
             invm.inv_ref_no,
             null, -- Purchase gmr
             invm.internal_gmr_ref_no, -- Sales gmr
             null, -- Purchase GRD
             dgrd.internal_dgrd_ref_no internal_dgrd_ref_no,
             invm.internal_contract_item_ref_no,
             invm.inv_in_action_ref_no,
             invm.inv_status,
             invm.original_inv_qty,
             t.cur_inv_qty current_inv_qty,
             invm.inv_qty_id,
             invm.is_active,
             gvc_dbd_id,
             t.total_product_premium,
             t.total_quality_premium,
             pum.price_unit_id,
             pum.cur_id,
             cm.cur_code,
             pum.weight_unit_id,
             qum.qty_unit,
             pum.weight,
             case
               when t.cur_inv_qty <> 0 then
                (t.total_mc / t.cur_inv_qty)
             
               else
                0
             end as material_cost_per_unit,
             case
               when t.cur_inv_qty <> 0 then
                (t.total_sc / t.cur_inv_qty)
               else
                0
             end as secondary_cost_per_unit,
             case
               when t.cur_inv_qty <> 0 then
                (t.total_product_premium / t.cur_inv_qty)
               else
                0
             end as product_premium_per_unit,
             case
               when t.cur_inv_qty <> 0 then
                (t.total_quality_premium / t.cur_inv_qty)
               else
                0
             end as quality_premium_per_unit,
             pkg_phy_populate_data.gvc_process_id,
             null --agd.qty
        from (select invd.inv_id,
                     nvl(sum(invd.transaction_qty), 0) cur_inv_qty,
                     nvl(sum(case
                               when invd.is_direct_cost = 'Y' and
                                    scm.cost_component_name = 'Material Cost' then
                                invd.transaction_cost
                               else
                                0
                             end),
                         0) as total_mc,
                     nvl(sum(case
                               when scm.cost_type = 'SECONDARY_COST' then
                                invd.transaction_cost
                               else
                                0
                             end),
                         0) as total_sc,
                     nvl(sum(case
                               when scm.cost_component_name = 'Location Premium' then
                                invd.transaction_cost
                               else
                                0
                             end),
                         0) as total_product_premium,
                     nvl(sum(case
                               when scm.cost_component_name = 'Quality Premium' then
                                invd.transaction_cost
                               else
                                0
                             end),
                         0) as total_quality_premium
                from invd_inventory_detail     invd,
                     scm_service_charge_master scm
               where invd.transaction_date <= pd_trade_date
                 and invd.dbd_id = gvc_dbd_id
                 and invd.cost_component_id = scm.cost_id
               group by invd.inv_id) t,
             invm_inventory_master@eka_appdb invm,
             dgrd_delivered_grd dgrd,
             agh_alloc_group_header agh,
             pum_price_unit_master pum,
             cm_currency_master cm,
             qum_quantity_unit_master qum
       where t.inv_id = invm.internal_inv_id
         and invm.cog_cur_id = pum.cur_id
         and invm.inv_qty_id = pum.weight_unit_id
         and nvl(pum.weight, 1) = 1
         and pum.cur_id = cm.cur_id
         and pum.weight_unit_id = qum.qty_unit_id
         and invm.internal_dgrd_ref_no = dgrd.internal_dgrd_ref_no
         and dgrd.int_alloc_group_id = agh.int_alloc_group_id
         and dgrd.dbd_id = agh.dbd_id
         and agh.dbd_id = gvc_dbd_id;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_create_invs',
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
  procedure sp_phy_update_contract_details(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_dbd_id       varchar2,
                                           pc_process      varchar2,
                                           pc_user_id      varchar2) is
  vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count number := 1;
  vn_row_cnt number;
  begin
  vn_row_cnt:=0;
  delete from cqpd_contract_qp_detail where corporate_id = pc_corporate_id;
  commit;
   gvn_log_counter :=  gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_dbd_id,
                        gvn_log_counter,
                        'Delete CQPD Over ');
  
   -- Called off 
  insert into cqpd_contract_qp_detail
    (corporate_id,
     pcdi_id,
     internal_contract_item_ref_no,
     qp_start_date,
     qp_end_date)
    select pc_corporate_id,
           pcdi.pcdi_id,
           pci.internal_contract_item_ref_no,
           pofh.qp_start_date,
           pofh.qp_end_date
      from pcm_physical_contract_main     pcm,
           pcdi_pc_delivery_item          pcdi,
           pci_physical_contract_item     pci,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id
       and pci.pcdi_id = pcdi.pcdi_id
       and pocd.qp_period_type <> 'Event'
       and pcdi.is_active = 'Y'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcm.dbd_id = pc_dbd_id
       and pcm.contract_type = 'BASEMETAL'
       and pcdi.dbd_id = pc_dbd_id
       and pci.dbd_id = pc_dbd_id
       and pcdi.price_option_call_off_status in
           ('Called Off', 'Not Applicable');
commit;
 gvn_log_counter :=  gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_dbd_id,
                        gvn_log_counter,
                        'Insert CQPD Called Off Over ');  
  -- All with Event Based
  insert into cqpd_contract_qp_detail
    (corporate_id,
     pcdi_id,
     internal_contract_item_ref_no,
     qp_start_date,
     qp_end_date)
    select pc_corporate_id,
           pcdi.pcdi_id,
           pci.internal_contract_item_ref_no,
           di.expected_qp_start_date qp_start_date,
           di.expected_qp_end_date qp_end_date
      from pcm_physical_contract_main pcm,
           pcdi_pc_delivery_item      pcdi,
           di_del_item_exp_qp_details di,
           pci_physical_contract_item pci
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pcdi.pcdi_id = di.pcdi_id
       and pci.pcdi_id = pcdi.pcdi_id
       and di.is_active = 'Y'
       and pcdi.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcm.dbd_id = pc_dbd_id
       and pcm.contract_type = 'BASEMETAL'
       and pcdi.dbd_id = pc_dbd_id
       and pci.dbd_id = pc_dbd_id;
commit; 
 gvn_log_counter :=  gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_dbd_id,
                        gvn_log_counter,
                        'Insert CQPD Event Based Over ');                                   
 -- not called off
  insert into cqpd_contract_qp_detail
    (corporate_id,
     pcdi_id,
     internal_contract_item_ref_no,
     qp_start_date,
     qp_end_date)
    select pc_corporate_id,
           pci.pcdi_id,
           pci.internal_contract_item_ref_no,
           (case
             when pfqpp.qp_pricing_period_type = 'Period' then
              pfqpp.qp_period_from_date
             when pfqpp.qp_pricing_period_type = 'Month' then
              to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year,
                      'dd-Mon-yyyy')
             when pfqpp.qp_pricing_period_type = 'Date' then
              pfqpp.qp_date
           end) qp_start_date,
           (case
             when pfqpp.qp_pricing_period_type = 'Period' then
              pfqpp.qp_period_to_date
             when pfqpp.qp_pricing_period_type = 'Month' then
              last_day(to_date('01-' || pfqpp.qp_month || '-' ||
                               pfqpp.qp_year,
                               'dd-Mon-yyyy'))
             when pfqpp.qp_pricing_period_type = 'Date' then
              pfqpp.qp_date
           end) qp_end_date
      from pcm_physical_contract_main    pcm,
           pci_physical_contract_item    pci,
           pcdi_pc_delivery_item         pcdi,
           pcipf_pci_pricing_formula     pcipf,
           pcbph_pc_base_price_header    pcbph,
           pcbpd_pc_base_price_detail    pcbpd,
           ppfh_phy_price_formula_header ppfh,
           pfqpp_phy_formula_qp_pricing  pfqpp
     where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
       and pci.internal_contract_item_ref_no =
           pcipf.internal_contract_item_ref_no
       and pci.pcdi_id = pcdi.pcdi_id
       and pcipf.pcbph_id = pcbph.pcbph_id
       and pcbph.pcbph_id = pcbpd.pcbph_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id
       and ppfh.ppfh_id = pfqpp.ppfh_id
       and pfqpp.qp_pricing_period_type <> 'Event'
       and pci.is_active = 'Y'
       and pcipf.is_active = 'Y'
       and pcbph.is_active = 'Y'
       and pcbpd.is_active = 'Y'
       and ppfh.is_active = 'Y'
       and pfqpp.is_active = 'Y'
       and pcdi.is_active = 'Y'
       and pcm.dbd_id = pc_dbd_id
       and pcm.contract_type = 'BASEMETAL'
       and pci.dbd_id = pc_dbd_id
       and pcdi.dbd_id = pc_dbd_id
       and pcipf.dbd_id = pc_dbd_id
       and pcbph.dbd_id = pc_dbd_id
       and pcbpd.dbd_id = pc_dbd_id
       and ppfh.dbd_id = pc_dbd_id
       and pfqpp.dbd_id = pc_dbd_id
       and pcdi.price_option_call_off_status = 'Not Called Off';

commit;
 gvn_log_counter :=  gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_dbd_id,
                        gvn_log_counter,
                        'Insert CQPD Not Called Off Over ');                                          
    -- Update Pricing QP Start Date and End Date in PCI
   for cur_price_qp in (select t.pcdi_id,
                              t.internal_contract_item_ref_no,
                              min(qp_start_date) qp_start_date,
                              min(qp_end_date) qp_end_date
                         from cqpd_contract_qp_detail t
                        where t.corporate_id = pc_corporate_id
                        group by t.pcdi_id,
                                 t.internal_contract_item_ref_no)
  loop
    update pci_physical_contract_item pci
       set pci.qp_start_date = cur_price_qp.qp_start_date,
           pci.qp_end_date   = cur_price_qp.qp_end_date
     where pci.internal_contract_item_ref_no =
           cur_price_qp.internal_contract_item_ref_no
       and pci.dbd_id = pc_dbd_id;
    vn_row_cnt := vn_row_cnt + 1;
    if vn_row_cnt >= 500 then
      commit;
      vn_row_cnt := 0;
    end if;
  end loop;
   commit;
   gvn_log_counter :=  gvn_log_counter + 1;
   sp_precheck_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_dbd_id,
                        gvn_log_counter,
                        'Updated Pricing QP Start Date and End Date in PCI');

    --added by siva
    update pcdi_pc_delivery_item pcdi
       set pcdi.shipment_date = (case when pcdi.basis_type = 'Shipment' then(case when pcdi.delivery_period_type = 'Month' then last_day('01-' || pcdi.delivery_to_month || '-' || pcdi.delivery_to_year) when pcdi.delivery_period_type = 'Date' then pcdi.delivery_to_date end) when pcdi.basis_type = 'Arrival' then(case when pcdi.delivery_period_type = 'Month' then last_day('01-' || pcdi.delivery_to_month || '-' || pcdi.delivery_to_year) - nvl(pcdi.transit_days, 0) when pcdi.delivery_period_type = 'Date' then pcdi.delivery_to_date - nvl(pcdi.transit_days, 0) end) end),
           pcdi.arrival_date  = (case when pcdi.basis_type = 'Shipment' then(case when pcdi.delivery_period_type = 'Month' then last_day('01-' || pcdi.delivery_to_month || '-' || pcdi.delivery_to_year) when pcdi.delivery_period_type = 'Date' then pcdi.delivery_to_date end) + nvl(pcdi.transit_days, 0) when pcdi.basis_type = 'Arrival' then(case when pcdi.delivery_period_type = 'Month' then last_day('01-' || pcdi.delivery_to_month || '-' || pcdi.delivery_to_year) when pcdi.delivery_period_type = 'Date' then pcdi.delivery_to_date end) end)
     where pcdi.dbd_id = pc_dbd_id
       and pcdi.is_active = 'Y';
    commit;
     gvn_log_counter :=  gvn_log_counter + 1;
  
   sp_precheck_process_log(pc_corporate_id,
                        pd_trade_date,
                        pc_dbd_id,
                        gvn_log_counter,
                        'Updated shipment date,arrival date for PCDI table');

 --
 -- Update Loading Date for GMR
 --
  for cur_loading_date in (select vd.internal_gmr_ref_no,
                                  max(vd.loading_date) loading_date
                             from vd_voyage_detail vd
                            where vd.dbd_id = pc_dbd_id
                              and nvl(vd.status, 'Active') = 'Active'
                            group by vd.internal_gmr_ref_no)
  loop
    update process_gmr gmr
       set gmr.loading_date = cur_loading_date.loading_date
     where gmr.dbd_id = pc_dbd_id
       and gmr.internal_gmr_ref_no = cur_loading_date.internal_gmr_ref_no;
    vn_row_cnt := vn_row_cnt + 1;
    if vn_row_cnt >= 500 then
      commit;
      vn_row_cnt := 0;
    end if;
       
  end loop;
  commit;
   gvn_log_counter :=  gvn_log_counter + 1;
  
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Loading Date Update');
 --
  -- Update Contract Details and CP for GMR
  --
  sp_gather_stats('process_gmr');   
  --sp_gather_stats('grd_goods_record_detail');
  sp_gather_stats('process_spq');
  sp_gather_stats('pci_physical_contract_item');
  sp_gather_stats('pcdi_pc_delivery_item');
  sp_gather_stats('pcm_physical_contract_main');
  sp_gather_stats('phd_profileheaderdetails');
  gvn_log_counter :=  gvn_log_counter + 1;
  
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Loading Date stats');
  /*for cur_gmr in (select gmr.internal_gmr_ref_no,
                         pcm.contract_ref_no,
                         pcm.internal_contract_ref_no,
                         pcm.contract_type,
                         pcm.cp_id,
                         phd.companyname cp_name,
                         cm.cur_id,
                         cm.cur_code,
                         cm.decimals,
                         pcm.is_tolling_contract,
                         decode(pcm.purchase_sales,'P','Purchase', 'Sales') pcm_contract_type,
                         gmr.qty_unit_id
                    from process_gmr  gmr,
                         process_grd    grd,
                         pci_physical_contract_item pci,
                         pcdi_pc_delivery_item      pcdi,
                         pcm_physical_contract_main pcm,
                         phd_profileheaderdetails   phd,
                         cm_currency_master cm
                   where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                     and grd.internal_contract_item_ref_no =
                         pci.internal_contract_item_ref_no
                     and pci.pcdi_id = pcdi.pcdi_id
                     and pcdi.internal_contract_ref_no =
                         pcm.internal_contract_ref_no
                     and gmr.dbd_id = pc_dbd_id
                     and grd.dbd_id = pc_dbd_id
                     and pci.dbd_id = pc_dbd_id
                     and pcdi.dbd_id = pc_dbd_id
                     and pcm.dbd_id = pc_dbd_id
                     and pcm.cp_id = phd.profileid
                     and pcm.invoice_currency_id = cm.cur_id
                   group by gmr.internal_gmr_ref_no,
                            pcm.contract_ref_no,
                            pcm.internal_contract_ref_no,
                            pcm.contract_type,
                            pcm.cp_id,
                            phd.companyname,
                            cm.cur_id,
                            cm.cur_code,
                            cm.decimals,
                            pcm.is_tolling_contract,
                            decode(pcm.purchase_sales,'P','Purchase', 'Sales'),
                            gmr.qty_unit_id)
  loop
    update process_gmr gmr
       set gmr.contract_ref_no          = cur_gmr.contract_ref_no,
           gmr.gmr_type                 = cur_gmr.contract_type,
           gmr.cp_id                    = cur_gmr.cp_id,
           gmr.cp_name                  = cur_gmr.cp_name,
           gmr.invoice_cur_id           = cur_gmr.cur_id,
           gmr.invoice_cur_code         = cur_gmr.cur_code,
           gmr.invoice_cur_decimals     = cur_gmr.decimals,
           gmr.internal_contract_ref_no = decode(gmr.internal_contract_ref_no,
                                                 null,
                                                 cur_gmr.internal_contract_ref_no,
                                                 gmr.internal_contract_ref_no),
          gmr.is_tolling_contract       = cur_gmr.is_tolling_contract,
          gmr.pcm_contract_type = cur_gmr.pcm_contract_type
     where gmr.dbd_id = pc_dbd_id
       and gmr.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no;
       Update process_grd grd
       set grd.gmr_qty_unit_id = cur_gmr.qty_unit_id
       where grd.dbd_id = pc_dbd_id
       and grd.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no
       and grd.status ='Active';
  end loop;*/
 /* gvn_log_counter := gvn_log_counter +1;
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'GMR Contract Details Update process_gmr 1');  */
  /*for cur_gmr in (select grd.internal_gmr_ref_no,
                         pcm.contract_ref_no,
                         pcm.internal_contract_ref_no,
                         pcm.contract_type,
                         pcm.cp_id,
                         phd.companyname cp_name,
                         cm.cur_id,
                         cm.cur_code,
                         cm.decimals,
                         pcm.is_tolling_contract,
                         decode(pcm.purchase_sales,'P','Purchase', 'Sales') pcm_contract_type
                    from process_grd                grd,
                         pci_physical_contract_item pci,
                         pcdi_pc_delivery_item      pcdi,
                         pcm_physical_contract_main pcm,
                         phd_profileheaderdetails   phd,
                         cm_currency_master cm
                   where grd.internal_contract_item_ref_no =
                         pci.internal_contract_item_ref_no
                     and pci.pcdi_id = pcdi.pcdi_id
                     and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
                     and pcm.cp_id = phd.profileid
                     and pcm.invoice_currency_id = cm.cur_id
                     and grd.dbd_id = pc_dbd_id
                     and grd.corporate_id = pc_corporate_id
                     and pci.dbd_id = pc_dbd_id
                     and pcdi.dbd_id = pc_dbd_id
                     and pcm.dbd_id = pc_dbd_id
                   group by grd.internal_gmr_ref_no,
                            pcm.contract_ref_no,
                            pcm.internal_contract_ref_no,
                            pcm.contract_type,
                            pcm.cp_id,
                            phd.companyname,
                            cm.cur_id,
                            cm.cur_code,
                            cm.decimals,
                            pcm.is_tolling_contract,
                            decode(pcm.purchase_sales,'P','Purchase', 'Sales'))
  loop
    update process_gmr gmr
       set gmr.contract_ref_no          = cur_gmr.contract_ref_no,
           gmr.gmr_type                 = cur_gmr.contract_type,
           gmr.cp_id                    = cur_gmr.cp_id,
           gmr.cp_name                  = cur_gmr.cp_name,
           gmr.invoice_cur_id           = cur_gmr.cur_id,
           gmr.invoice_cur_code         = cur_gmr.cur_code,
           gmr.invoice_cur_decimals     = cur_gmr.decimals,
           gmr.internal_contract_ref_no = decode(gmr.internal_contract_ref_no,
                                                 null,
                                                 cur_gmr.internal_contract_ref_no,
                                                 gmr.internal_contract_ref_no),
          gmr.is_tolling_contract       = cur_gmr.is_tolling_contract,
          gmr.pcm_contract_type = cur_gmr.pcm_contract_type
     where gmr.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no
     and gmr.dbd_id = pc_dbd_id
     and gmr.corporate_id = pc_corporate_id;
    vn_row_cnt := vn_row_cnt + 1;
    if vn_row_cnt >= 500 then
      commit;
      vn_row_cnt := 0;
    end if;
     
  end loop;*/
  
  delete from tgmrc_gmr_contract_details
   where corporate_id = pc_corporate_id;
  commit;
  insert into tgmrc_gmr_contract_details
    (corporate_id,
     internal_gmr_ref_no,
     contract_ref_no,
     internal_contract_ref_no,
     contract_type,
     cp_id,
     cp_name,
     invoice_cur_id,
     invoice_cur_code,
     invoice_cur_decimals,
     is_tolling_contract,
     pcm_contract_type)
    select pc_corporate_id,
           grd.internal_gmr_ref_no,
           pcm.contract_ref_no,
           pcm.internal_contract_ref_no,
           pcm.contract_type,
           pcm.cp_id,
           phd.companyname cp_name,
           cm.cur_id,
           cm.cur_code,
           cm.decimals,
           pcm.is_tolling_contract,
           decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') pcm_contract_type
      from process_grd                grd,
           pci_physical_contract_item pci,
           pcdi_pc_delivery_item      pcdi,
           pcm_physical_contract_main pcm,
           phd_profileheaderdetails   phd,
           cm_currency_master         cm
     where grd.internal_contract_item_ref_no =
           pci.internal_contract_item_ref_no
       and pci.pcdi_id = pcdi.pcdi_id
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcm.cp_id = phd.profileid
       and pcm.invoice_currency_id = cm.cur_id
       and grd.dbd_id = pc_dbd_id
       and grd.corporate_id = pc_corporate_id
       and pci.dbd_id = pc_dbd_id
       and pcdi.dbd_id = pc_dbd_id
       and pcm.dbd_id = pc_dbd_id
     group by grd.internal_gmr_ref_no,
              pcm.contract_ref_no,
              pcm.internal_contract_ref_no,
              pcm.contract_type,
              pcm.cp_id,
              phd.companyname,
              cm.cur_id,
              cm.cur_code,
              cm.decimals,
              pcm.is_tolling_contract,
              decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales');
  commit;
  for cur_gmr in (
  select * from tgmrc_gmr_contract_details 
  where corporate_id = pc_corporate_id) loop
  update process_gmr gmr
       set gmr.contract_ref_no          = cur_gmr.contract_ref_no,
           gmr.gmr_type                 = cur_gmr.contract_type,
           gmr.cp_id                    = cur_gmr.cp_id,
           gmr.cp_name                  = cur_gmr.cp_name,
           gmr.invoice_cur_id           = cur_gmr.invoice_cur_id,
           gmr.invoice_cur_code         = cur_gmr.invoice_cur_code,
           gmr.invoice_cur_decimals     = cur_gmr.invoice_cur_decimals,
           gmr.internal_contract_ref_no = decode(gmr.internal_contract_ref_no,
                                                 null,
                                                 cur_gmr.internal_contract_ref_no,
                                                 gmr.internal_contract_ref_no),
          gmr.is_tolling_contract       = cur_gmr.is_tolling_contract,
          gmr.pcm_contract_type = cur_gmr.pcm_contract_type
     where gmr.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no
     and gmr.dbd_id = pc_dbd_id
     and gmr.corporate_id = pc_corporate_id;
    vn_row_cnt := vn_row_cnt + 1;
    if vn_row_cnt >= 500 then
      commit;
      vn_row_cnt := 0;
    end if;
  end loop;
  commit;
  gvn_log_counter := gvn_log_counter +1;
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'GMR Contract Details Update process_grd 1');  
 /*Update process_grd grd
     set grd.gmr_qty_unit_id = (select gmr.qty_unit_id
     from process_gmr gmr
          where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
          and gmr.corporate_id = pc_corporate_id
          and gmr.dbd_id = pc_dbd_id)
     where grd.status ='Active'
     and grd.corporate_id = pc_corporate_id
     and grd.dbd_id = pc_dbd_id;
  commit;
  gvn_log_counter :=  gvn_log_counter + 1;
  
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Contract Details Update');*/
                          
  for cur_gmr in (select gmr.internal_gmr_ref_no,
                           pcm.contract_ref_no,
                           pcm.internal_contract_ref_no,
                           pcm.contract_type,
                           pcm.cp_id,
                           phd.companyname cp_name,
                           cm.cur_id,
                           cm.cur_code,
                           cm.decimals,
                           pcm.is_tolling_contract,
                           decode(pcm.purchase_sales,'P','Purchase', 'Sales') pcm_contract_type,
                           gmr.qty_unit_id
                      from process_gmr  gmr,
                           dgrd_delivered_grd         grd,
                           pci_physical_contract_item pci,
                           pcdi_pc_delivery_item      pcdi,
                           pcm_physical_contract_main pcm,
                           phd_profileheaderdetails   phd,
                           cm_currency_master cm
                     where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                       and grd.internal_contract_item_ref_no =
                           pci.internal_contract_item_ref_no
                       and pci.pcdi_id = pcdi.pcdi_id
                       and pcdi.internal_contract_ref_no =
                           pcm.internal_contract_ref_no
                       and gmr.dbd_id = pc_dbd_id
                       and grd.dbd_id = pc_dbd_id
                       and pci.dbd_id = pc_dbd_id
                       and pcdi.dbd_id = pc_dbd_id
                       and pcm.dbd_id = pc_dbd_id
                       and pcm.cp_id = phd.profileid
                       and pcm.invoice_currency_id = cm.cur_id
                     group by gmr.internal_gmr_ref_no,
                              pcm.contract_ref_no,
                              pcm.internal_contract_ref_no,
                              pcm.contract_type,
                              pcm.cp_id,
                              phd.companyname,
                              cm.cur_id,
                              cm.cur_code,
                              cm.decimals,
                              pcm.is_tolling_contract,
                              decode(pcm.purchase_sales,'P','Purchase', 'Sales'),
                              gmr.qty_unit_id)
    loop
      update process_gmr gmr
         set gmr.contract_ref_no          = cur_gmr.contract_ref_no,
             gmr.gmr_type                 = cur_gmr.contract_type,
             gmr.cp_id                    = cur_gmr.cp_id,
             gmr.cp_name                  = cur_gmr.cp_name,
             gmr.invoice_cur_id           = cur_gmr.cur_id,
             gmr.invoice_cur_code         = cur_gmr.cur_code,
             gmr.invoice_cur_decimals     = cur_gmr.decimals,
             gmr.is_tolling_contract       = cur_gmr.is_tolling_contract,
             gmr.pcm_contract_type = cur_gmr.pcm_contract_type
       where gmr.dbd_id = pc_dbd_id
         and gmr.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no;
          Update dgrd_delivered_grd grd
         set grd.gmr_qty_unit_id = cur_gmr.qty_unit_id
         where grd.dbd_id = pc_dbd_id
         and grd.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no
         and grd.status ='Active';

        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
         
    end loop;
commit;
  gvn_log_counter :=  gvn_log_counter + 1;
  
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Contract Details Update Sales');                            

--
-- GRD to GMR Conversion Factor
--
/*for cur_grd_convert in(
select grd.internal_gmr_ref_no,
       grd.qty_unit_id grd_qty_unit_id,
       grd.gmr_qty_unit_id gmr_qty_unit_id,
       ucm.multiplication_factor
  from process_grd    grd,
       ucm_unit_conversion_master ucm
 where grd.status = 'Active'
   and grd.is_deleted = 'N'
   and grd.dbd_id = pc_dbd_id
   and ucm.from_qty_unit_id = grd.qty_unit_id
   and ucm.to_qty_unit_id = grd.gmr_qty_unit_id
   and grd.qty_unit_id <> grd.gmr_qty_unit_id
   and grd.tolling_stock_type in ('None Tolling','Clone Stock')) loop
   
update process_grd grd
   set grd.grd_to_gmr_qty_factor = cur_grd_convert.multiplication_factor
 where grd.internal_gmr_ref_no = cur_grd_convert.internal_gmr_ref_no
   and grd.qty_unit_id = cur_grd_convert.grd_qty_unit_id
   and grd.dbd_id = pc_dbd_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
   
end loop;*/   
   delete from temp_grd_qtyconv where corporate_id = pc_corporate_id;
    commit;
    insert into temp_grd_qtyconv
      (corporate_id,
       internal_grd_ref_no,
       internal_gmr_ref_no,
       grd_qty_unit_id,
       gmr_qty_unit_id,
       multiplication_factor)
      select gmr.corporate_id,
             grd.internal_grd_ref_no,
             grd.internal_gmr_ref_no,
             grd.qty_unit_id grd_qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             ucm.multiplication_factor
        from process_grd                grd,
             process_gmr                gmr,
             ucm_unit_conversion_master ucm
       where grd.status = 'Active'
         and grd.is_deleted = 'N'
         and grd.dbd_id = pc_dbd_id
         and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.dbd_id = pc_dbd_id
         and gmr.corporate_id = pc_corporate_id
         and ucm.from_qty_unit_id = grd.qty_unit_id
         and ucm.to_qty_unit_id = gmr.qty_unit_id
         and grd.qty_unit_id <> gmr.qty_unit_id
         and grd.tolling_stock_type in ('None Tolling', 'Clone Stock');
    commit;
    for cur_grd_convert in (select corporate_id,
                                   internal_grd_ref_no,
                                   internal_gmr_ref_no,
                                   grd_qty_unit_id,
                                   gmr_qty_unit_id,
                                   multiplication_factor
                              from temp_grd_qtyconv
                             where corporate_id = pc_corporate_id)
    loop
    
      update process_grd grd
         set grd.grd_to_gmr_qty_factor = cur_grd_convert.multiplication_factor,
             grd.gmr_qty_unit_id       = cur_grd_convert.gmr_qty_unit_id
       where grd.internal_gmr_ref_no = cur_grd_convert.internal_gmr_ref_no
         and grd.internal_grd_ref_no = cur_grd_convert.internal_grd_ref_no
         and grd.dbd_id = pc_dbd_id;
      vn_row_cnt := vn_row_cnt + 1;
      if vn_row_cnt >= 500 then
        commit;
        vn_row_cnt := 0;
      end if;
    end loop;
    commit;
    gvn_log_counter := gvn_log_counter + 1;
    sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            gvn_log_counter,
                            'End of Update GRD GMR Factor');
  
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Update GRD GMR Factor');
                          
--
-- DGRD to GMR Conversion Factor
--
for cur_grd_convert in(
select dgrd.internal_gmr_ref_no,
       dgrd.net_weight_unit_id grd_qty_unit_id,
       dgrd.gmr_qty_unit_id gmr_qty_unit_id,
       ucm.multiplication_factor
  from dgrd_delivered_grd         dgrd,
       ucm_unit_conversion_master ucm
 where dgrd.status = 'Active'
   and dgrd.dbd_id = pc_dbd_id
   and ucm.from_qty_unit_id = dgrd.net_weight_unit_id
   and ucm.to_qty_unit_id = dgrd.gmr_qty_unit_id
   and dgrd.net_weight_unit_id <> dgrd.gmr_qty_unit_id) loop
update dgrd_delivered_grd dgrd
   set dgrd.dgrd_to_gmr_qty_factor = cur_grd_convert.multiplication_factor
 where dgrd.internal_gmr_ref_no = cur_grd_convert.internal_gmr_ref_no
   and dgrd.net_weight_unit_id = cur_grd_convert.grd_qty_unit_id
   and dgrd.dbd_id = pc_dbd_id;

        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
   
end loop;   
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Update DGRD GMR Factor');                          
  --
  -- Update Dry Qty in GRD
  --
 sp_gather_stats('process_spq');
 sp_gather_stats('process_grd');
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of spq,grd stats');  
  /*for cur_grd_dry_qty in (select spq.internal_grd_ref_no,
                                 min((nvl(asm.dry_wet_qty_ratio, 100) / 100)) dry_wet_qty_ratio,
                                 max(spq.assay_header_id) assay_header_id,
                                 max(spq.weg_avg_pricing_assay_id) weg_avg_pricing_assay_id
                            from process_spq    spq,
                                 asm_assay_sublot_mapping asm
                           where spq.is_stock_split = 'N'
                             and spq.weg_avg_pricing_assay_id = asm.ash_id
                             and spq.is_active ='Y'
                             and spq.dbd_id = pc_dbd_id
                             and spq.corporate_id = pc_corporate_id
                           group by spq.internal_grd_ref_no)
  loop
    update process_grd grd
       set grd.dry_qty = cur_grd_dry_qty.dry_wet_qty_ratio * grd.qty,
           grd.dry_wet_ratio = cur_grd_dry_qty.dry_wet_qty_ratio,
           grd.assay_header_id = cur_grd_dry_qty.assay_header_id,
           grd.weg_avg_pricing_assay_id = cur_grd_dry_qty.weg_avg_pricing_assay_id
     where grd.internal_grd_ref_no = cur_grd_dry_qty.internal_grd_ref_no
       and grd.dbd_id = pc_dbd_id
       and grd.corporate_id = pc_corporate_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
  end loop;*/
  delete tspq_temp_spq_asm where corporate_id = pc_corporate_id;
  commit;
  insert into tspq_temp_spq_asm
    (corporate_id,
     internal_grd_ref_no,
     dry_wet_qty_ratio,
     assay_header_id,
     weg_avg_pricing_assay_id)
    select pc_corporate_id,
           spq.internal_grd_ref_no,
           min((nvl(asm.dry_wet_qty_ratio, 100) / 100)) dry_wet_qty_ratio,
           max(spq.assay_header_id) assay_header_id,
           max(spq.weg_avg_pricing_assay_id) weg_avg_pricing_assay_id
      from process_spq              spq,
           asm_assay_sublot_mapping asm
     where spq.is_stock_split = 'N'
       and spq.weg_avg_pricing_assay_id = asm.ash_id
       and spq.is_active = 'Y'
       and spq.dbd_id = pc_dbd_id
       and spq.corporate_id = pc_corporate_id
       and spq.internal_grd_ref_no is not null
     group by spq.internal_grd_ref_no;
  commit;
   gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of insert tspq for grd');  

/*update process_grd grd
   set (grd.dry_qty, grd.dry_wet_ratio, grd.assay_header_id, grd.weg_avg_pricing_assay_id) = --
        (select tspq.dry_wet_qty_ratio * grd.qty,
                tspq.dry_wet_qty_ratio,
                tspq.assay_header_id,
                tspq.weg_avg_pricing_assay_id
           from tspq_temp_spq_asm tspq
          where tspq.corporate_id = pc_corporate_id
          and tspq.internal_grd_ref_no = grd.internal_grd_ref_no)
 where grd.corporate_id = pc_corporate_id;*/
  for cc in (select tspq.internal_grd_ref_no,
                    tspq.dry_wet_qty_ratio,
                    tspq.assay_header_id,
                    tspq.weg_avg_pricing_assay_id
               from tspq_temp_spq_asm tspq
              where tspq.corporate_id = pc_corporate_id)
  loop
    update process_grd grd
       set grd.dry_qty                  = cc.dry_wet_qty_ratio * grd.qty,
           grd.dry_wet_ratio            = cc.dry_wet_qty_ratio,
           grd.assay_header_id          = cc.assay_header_id,
           grd.weg_avg_pricing_assay_id = cc.weg_avg_pricing_assay_id
     where grd.corporate_id = pc_corporate_id
       and grd.internal_grd_ref_no = cc.internal_grd_ref_no;
  end loop;
  commit;
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Update GRD Dry Qty');
 delete tspq_temp_spq_asm where corporate_id = pc_corporate_id;
  commit;
  insert into tspq_temp_spq_asm
    (corporate_id,
     internal_grd_ref_no,
     dry_wet_qty_ratio,
     assay_header_id,
     weg_avg_pricing_assay_id)
    select pc_corporate_id,
           spq.internal_dgrd_ref_no,
           min((nvl(asm.dry_wet_qty_ratio, 100) / 100)) dry_wet_qty_ratio,
           max(spq.assay_header_id) assay_header_id,
           max(spq.weg_avg_pricing_assay_id) weg_avg_pricing_assay_id
      from process_spq              spq,
           asm_assay_sublot_mapping asm
     where spq.is_stock_split = 'N'
       and spq.weg_avg_pricing_assay_id = asm.ash_id
       and spq.is_active = 'Y'
       and spq.dbd_id = pc_dbd_id
       and spq.corporate_id = pc_corporate_id
       and spq.internal_dgrd_ref_no is not null
     group by spq.internal_dgrd_ref_no;
  commit;
   gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of insert tspq for dgrd');  
update dgrd_delivered_grd dgrd
   set (dgrd.dry_qty,dgrd.weg_avg_pricing_assay_id) = --
        (select tspq.dry_wet_qty_ratio * dgrd.net_weight,
                tspq.weg_avg_pricing_assay_id
           from tspq_temp_spq_asm tspq
          where tspq.corporate_id = pc_corporate_id
          and tspq.internal_grd_ref_no = dgrd.internal_dgrd_ref_no)
 where dgrd.dbd_id = pc_dbd_id;
  commit;
  gvn_log_counter :=  gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Update DGRD Weighted Avg Assay');
                          
                          
  for cur_grd_quality in(
  select qat.quality_id,
         qat.quality_name
    from qat_quality_attributes qat) loop
  update process_grd grd
     set grd.quality_name = cur_grd_quality.quality_name
   where grd.dbd_id = pc_dbd_id
     and grd.quality_id = cur_grd_quality.quality_id;
  update dgrd_delivered_grd dgrd
     set dgrd.quality_name = cur_grd_quality.quality_name
   where dgrd.dbd_id = pc_dbd_id
     and dgrd.quality_id = cur_grd_quality.quality_id;   
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
     
  end loop;
 commit;
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Update GRD Quality');
  FOR cur_profit_center in(
  select *
    from cpc_corporate_profit_center cpc
   where cpc.corporateid = pc_corporate_id) loop
  update process_grd grd
     set grd.profit_center_short_name = cur_profit_center.profit_center_short_name,
         grd.profit_center_name       = cur_profit_center.profit_center_name
   where grd.profit_center_id = cur_profit_center.profit_center_id
     and grd.dbd_id = pc_dbd_id;
  update dgrd_delivered_grd dgrd
     set dgrd.profit_center_short_name = cur_profit_center.profit_center_short_name,
         dgrd.profit_center_name       = cur_profit_center.profit_center_name
   where dgrd.profit_center_id = cur_profit_center.profit_center_id
     and dgrd.dbd_id = pc_dbd_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
     
  end loop;
  commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Update GRD Profit Center');
                         
  for cur_containers in (
  select grd.internal_gmr_ref_no,
       sum(nvl(grd.no_of_containers, 0)) no_of_containers,
       sum(grd.qty * nvl(grd.grd_to_gmr_qty_factor, 1)) wet_qty,
       sum(grd.dry_qty * nvl(grd.grd_to_gmr_qty_factor, 1)) dry_qty,
       max(grd.quality_name) quality_name,
       max(grd.quality_id)quality_id,
       max(grd.pcdi_id) pcdi_id
  from process_grd grd
 where grd.dbd_id = pc_dbd_id
   and grd.status = 'Active'
   and grd.is_deleted = 'N'
   and grd.tolling_stock_type in ('Clone Stock','None Tolling')
 group by grd.internal_gmr_ref_no)
  loop
    update process_gmr gmr
       set gmr.no_of_containers = cur_containers.no_of_containers,
           gmr.dry_qty          = cur_containers.dry_qty,
           gmr.wet_qty          = cur_containers.wet_qty,
           gmr.quality_id       = cur_containers.quality_id,
           gmr.quality_name     = cur_containers.quality_name,
           gmr.pcdi_id          = cur_containers.pcdi_id
     where gmr.dbd_id = pc_dbd_id
       and gmr.internal_gmr_ref_no = cur_containers.internal_gmr_ref_no;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
  commit;
  gvn_log_counter :=  gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Containers ');
                          
for cur_dgrd in (
  select dgrd.internal_gmr_ref_no,
       sum(nvl(dgrd.no_of_containers, 0)) no_of_containers,
       sum(dgrd.net_weight * nvl(dgrd.dgrd_to_gmr_qty_factor, 1)) wet_qty,
       sum(dgrd.dry_qty * nvl(dgrd.dgrd_to_gmr_qty_factor, 1)) dry_qty,
       max(dgrd.pcdi_id) pcdi_id
  from dgrd_delivered_grd dgrd
 where dgrd.dbd_id = pc_dbd_id
   and dgrd.status = 'Active'
 group by dgrd.internal_gmr_ref_no)
  loop
    update process_gmr gmr
       set gmr.no_of_containers = cur_dgrd.no_of_containers,
           gmr.dry_qty          = cur_dgrd.dry_qty,
           gmr.wet_qty          = cur_dgrd.wet_qty,
           gmr.pcdi_id          = cur_dgrd.pcdi_id
     where gmr.dbd_id = pc_dbd_id
       and gmr.internal_gmr_ref_no = cur_dgrd.internal_gmr_ref_no;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
  commit;
  gvn_log_counter :=  gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Sales GMR Qty Update');
for cur_gmr_whname in(
select phd.* from phd_profileheaderdetails phd) loop
update process_gmr gmr
   set gmr.warehouse_name = cur_gmr_whname.companyname
 where gmr.dbd_id = pc_dbd_id
   and gmr.warehouse_profile_id = cur_gmr_whname.profileid;
   Update gepd_gmr_element_pledge_detail gepd
   set gepd.pledge_cp_name = cur_gmr_whname.companyname
   where gepd.dbd_id= pc_dbd_id
   and gepd.pledge_cp_id = cur_gmr_whname.profileid;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
   
end loop; 
gvn_log_counter :=  gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Warehouse Name Update');
commit;                          

--
-- Update Assay Final Status for Arrived Report
--    
sp_gather_stats('process_gmr');   
--sp_gather_stats('grd_goods_record_detail');   
--sp_gather_stats('ash_assay_header');
                 
    for cur_assay in (select grd.internal_gmr_ref_no,
                             count(distinct grd.internal_grd_ref_no) stock_count,
                             sum(case
                                   when ash.is_final_assay_fully_finalized = 'Y' then
                                    1
                                   else
                                    0
                                 end) finalized_assay_count,
                             sum(case
                                   when ash.assay_type = 'Final Assay' and
                                        (nvl(ash.is_final_assay_fully_finalized,
                                             'N') = 'N') then
                                    1
                                   else
                                    0
                                 end) final_assay_count
                        from process_grd      grd,
                             ash_assay_header ash
                       where grd.internal_gmr_ref_no = ash.internal_gmr_ref_no
                         and grd.internal_grd_ref_no = ash.internal_grd_ref_no
                         and grd.status = 'Active'
                         and ash.is_active = 'Y'
                         and grd.corporate_id = pc_corporate_id
                         and grd.dbd_id = pc_dbd_id
                       group by grd.internal_gmr_ref_no)
    loop
      update process_gmr gmr
         set gmr.assay_final_status = (case when cur_assay.stock_count = cur_assay.finalized_assay_count and cur_assay.stock_count <> 0 then 'Assay Finalized' else(case when cur_assay.finalized_assay_count <> 0 or cur_assay.final_assay_count <> 0 then 'Partial Assay Finalized' else 'Not Assay Finalized' end) end)
       where gmr.internal_gmr_ref_no = cur_assay.internal_gmr_ref_no
         and gmr.dbd_id = pc_dbd_id
         and gmr.corporate_id = pc_corporate_id;
      vn_row_cnt := vn_row_cnt + 1;
      if vn_row_cnt >= 500 then
        commit;
        vn_row_cnt := 0;
      end if;
    end loop;
  commit; 
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Update GMR Assay Status For GRD');

    for cur_assay in (select dgrd.internal_gmr_ref_no,
                             count(distinct dgrd.internal_dgrd_ref_no) stock_count,
                             sum(case
                                   when ash.is_final_assay_fully_finalized = 'Y' then
                                    1
                                   else
                                    0
                                 end) finalized_assay_count,
                             sum(case
                                   when ash.assay_type = 'Final Assay' and
                                        (nvl(ash.is_final_assay_fully_finalized,
                                             'N') = 'N') then
                                    1
                                   else
                                    0
                                 end) final_assay_count
                        from dgrd_delivered_grd dgrd,
                             ash_assay_header   ash
                       where dgrd.internal_gmr_ref_no =
                             ash.internal_gmr_ref_no
                         and dgrd.internal_dgrd_ref_no =
                             ash.internal_grd_ref_no
                         and dgrd.status = 'Active'
                         and ash.is_active = 'Y'
                         and dgrd.dbd_id = pc_dbd_id
                       group by dgrd.internal_gmr_ref_no)
    loop
      update process_gmr gmr
         set gmr.assay_final_status = (case when cur_assay.stock_count = cur_assay.finalized_assay_count and cur_assay.stock_count <> 0 then 'Assay Finalized' else(case when cur_assay.finalized_assay_count <> 0 or cur_assay.final_assay_count <> 0 then 'Partial Assay Finalized' else 'Not Assay Finalized' end) end)
       where gmr.internal_gmr_ref_no = cur_assay.internal_gmr_ref_no
         and gmr.dbd_id = pc_dbd_id
         and gmr.corporate_id = pc_corporate_id;
      vn_row_cnt := vn_row_cnt + 1;
      if vn_row_cnt >= 500 then
        commit;
        vn_row_cnt := 0;
      end if;
    end loop;
    commit;
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Update GMR Assay Status For DGRD');
                         
Update process_gmr gmr
set gmr.gmr_arrival_status = (case
                     when (decode(gmr.is_final_weight,'Y','Completed', gmr.wns_status) = 'Completed' and
                          gmr.assay_final_status = 'Assay Finalized') then
                      'Assay Finalized'
                     when (decode(gmr.is_final_weight,'Y','Completed', gmr.wns_status) = 'Completed' and
                          gmr.assay_final_status = 'Partial Assay Finalized') then
                      'Partial Assay Finalized'
                     when (decode(gmr.is_final_weight,'Y','Completed', gmr.wns_status) = 'Completed' and
                          nvl(gmr.assay_final_status,'Not Assay Finalized') = 'Not Assay Finalized') then
                      'Weight Finalized'
                     when (gmr.wns_status = 'Partial') then
                      'Partial Weight Finalized'
                     else
                     case when gmr.pcm_contract_type ='Purchase' then 'Arrived'
                     else
                     'Delivered'
                     end 
                   end)
where gmr.dbd_id = pc_dbd_id
and gmr.corporate_id = pc_corporate_id;
commit;   
sp_gather_stats('pcdi_pc_delivery_item');
sp_gather_stats('pcpd_pc_product_definition');
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Arrival Status Update');
  /*for cur_pcdi in (select pcdi.pcdi_id,
                          pcpd.product_id,
                          pdm.product_desc
                     from pcdi_pc_delivery_item      pcdi,
                          pcpd_pc_product_definition pcpd,
                          pdm_productmaster          pdm
                    where pcdi.internal_contract_ref_no =
                          pcpd.internal_contract_ref_no
                      and pcpd.product_id = pdm.product_id
                      and pcdi.dbd_id = gvc_dbd_id
                      and pcpd.dbd_id = gvc_dbd_id
                      and pcpd.input_output = 'Input'
                      and pcpd.is_active = 'Y'
                      and pcdi.is_active = 'Y'
                    group by pcdi.pcdi_id,
                             pcpd.product_id,
                             pdm.product_desc)
  loop
    update process_grd grd
       set grd.conc_product_id   = cur_pcdi.product_id,
           grd.conc_product_name = cur_pcdi.product_desc
     where grd.pcdi_id = cur_pcdi.pcdi_id
      and grd.status ='Active'
      and grd.dbd_id = gvc_dbd_id
      and grd.corporate_id = pc_corporate_id;
 update dgrd_delivered_grd dgrd
       set dgrd.conc_product_id   = cur_pcdi.product_id,
           dgrd.conc_product_name = cur_pcdi.product_desc
     where dgrd.dbd_id = gvc_dbd_id
     and dgrd.status ='Active'
      and dgrd.pcdi_id = cur_pcdi.pcdi_id;    
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
        
  end loop;*/
  update process_grd grd
   set (grd.conc_product_id, grd.conc_product_name) = (select pcpd.product_id,
                                                              pdm.product_desc
                                                         from pcdi_pc_delivery_item      pcdi,
                                                              pcpd_pc_product_definition pcpd,
                                                              pdm_productmaster          pdm
                                                        where pcdi.internal_contract_ref_no =
                                                              pcpd.internal_contract_ref_no
                                                          and pcpd.product_id =
                                                              pdm.product_id
                                                          and pcdi.dbd_id =pc_dbd_id
                                                          and pcpd.dbd_id =pc_dbd_id
                                                          and pcpd.input_output =
                                                              'Input'
                                                          and pcpd.is_active = 'Y'
                                                          and pcdi.is_active = 'Y'
                                                          and pcdi.pcdi_id =
                                                              grd.pcdi_id
                                                        group by pcdi.pcdi_id,
                                                                 pcpd.product_id,
                                                                 pdm.product_desc)
 where grd.dbd_id = pc_dbd_id
   and grd.corporate_id = pc_corporate_id;
 commit;
 update dgrd_delivered_grd dgrd
   set (dgrd.conc_product_id, dgrd.conc_product_name) = (select pcpd.product_id,
                                                                pdm.product_desc
                                                           from pcdi_pc_delivery_item      pcdi,
                                                                pcpd_pc_product_definition pcpd,
                                                                pdm_productmaster          pdm
                                                          where pcdi.internal_contract_ref_no =
                                                                pcpd.internal_contract_ref_no
                                                            and pcpd.product_id =
                                                                pdm.product_id
                                                            and pcdi.dbd_id =pc_dbd_id
                                                            and pcpd.dbd_id =pc_dbd_id
                                                            and pcpd.input_output = 'Input'
                                                            and pcpd.is_active = 'Y'
                                                            and pcdi.is_active = 'Y'
                                                            and pcdi.pcdi_id =
                                                                dgrd.pcdi_id
                                                          group by pcdi.pcdi_id,
                                                                   pcpd.product_id,
                                                                   pdm.product_desc)
 where dgrd.dbd_id = pc_dbd_id
   and dgrd.status = 'Active';
commit;   
gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GRD Concentrate Product Update'); 
update gepd_gmr_element_pledge_detail gepd
   set (gepd.pledge_input_gmr_ref_no, gepd.pledge_input_gmr_wh_profile_id, gepd.pledge_input_gmr_wh_name) = --
   (select gmr.gmr_ref_no, gmr.warehouse_profile_id, gmr.warehouse_name from process_gmr gmr
                                        where gmr.internal_gmr_ref_no =
                                              gepd.pledge_input_gmr
                                          and gmr.dbd_id = pc_dbd_id)
 where gepd.dbd_id = pc_dbd_id;
 gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GEPD GMR ref No Update'); 
update gepd_gmr_element_pledge_detail gepd
   set gepd.supplier_cp_name = (select phd.companyname
                                  from phd_profileheaderdetails phd
                                 where phd.profileid = gepd.supplier_cp_id)
 where gepd.dbd_id = pc_dbd_id;
commit;
 gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GEPD Profie Name Update'); 
  for cur_aml in (select * from aml_attribute_master_list)
  loop
    update gepd_gmr_element_pledge_detail gepd
       set gepd.element_name = cur_aml.attribute_name
     where gepd.dbd_id = pc_dbd_id
       and gepd.element_id = cur_aml.attribute_id;
  end loop;
commit;
 gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GEPD Element Name Update'); 
  for cur_qum in (select qum.qty_unit_id,
                         qum.qty_unit
                    from qum_quantity_unit_master qum)
  loop
    update process_grd grd
       set grd.qty_unit = cur_qum.qty_unit
     where grd.dbd_id = pc_dbd_id
     and grd.corporate_id = pc_corporate_id
       and grd.qty_unit_id = cur_qum.qty_unit_id;
    update process_spq spq
    set spq.qty_unit = cur_qum.qty_unit
    where spq.dbd_id = pc_dbd_id
    and spq.corporate_id = pc_corporate_id
    and spq.qty_unit_id = cur_qum.qty_unit_id;
 update dgrd_delivered_grd dgrd
       set dgrd.net_weight_unit = cur_qum.qty_unit
     where dgrd.dbd_id = pc_dbd_id
       and dgrd.net_weight_unit_id = cur_qum.qty_unit_id; 
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
          
  end loop;
  commit;
   gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GRD Quantity Unit Update'); 
  for cur_grd_pdm in (select pdm.product_id,
                             pdm.product_desc product_name,
                             pdm.base_quantity_unit base_qty_unit_id,
                             qum.qty_unit base_qty_unit
                        from pdm_productmaster pdm,qum_quantity_unit_master qum
                        where pdm.base_quantity_unit = qum.qty_unit_id)
  loop
    update process_grd grd
       set grd.product_name = cur_grd_pdm.product_name,
       grd.base_qty_unit_id = cur_grd_pdm.base_qty_unit_id,
       grd.base_qty_unit = cur_grd_pdm.base_qty_unit 
     where grd.product_id = cur_grd_pdm.product_id
     and grd.dbd_id = pc_dbd_id
     and grd.corporate_id = pc_corporate_id;
      update pcpd_pc_product_definition pcpd
       set pcpd.product_name = cur_grd_pdm.product_name
     where pcpd.dbd_id = pc_dbd_id
       and pcpd.product_id = cur_grd_pdm.product_id;
      update dgrd_delivered_grd dgrd
       set dgrd.product_name = cur_grd_pdm.product_name,
       dgrd.base_qty_unit_id = cur_grd_pdm.base_qty_unit_id,
       dgrd.base_qty_unit = cur_grd_pdm.base_qty_unit 
     where dgrd.dbd_id = pc_dbd_id
       and dgrd.product_id = cur_grd_pdm.product_id; 
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
  end loop;
commit;
   gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GRD Product Update'); 
  for cur_gsm in (select * from gsm_gmr_stauts_master gsm)
  loop
    update process_gmr gmr
       set gmr.gmr_status = cur_gsm.status
     where gmr.status_id = cur_gsm.status_id
     and  gmr.dbd_id = pc_dbd_id
     and gmr.corporate_id = pc_corporate_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
 commit; 
    gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Status From GSM Update');  
  for cur_sld in (select sld.storage_loc_id,
                         sld.storage_location_name
                    from sld_storage_location_detail sld)
  loop
    update process_gmr gmr
       set gmr.shed_name = cur_sld.storage_location_name
     where gmr.shed_id = cur_sld.storage_loc_id
     and gmr.dbd_id = pc_dbd_id
       and gmr.corporate_id = pc_corporate_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
commit;
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Shed Name Update');  
  for cur_itm in (select * from itm_incoterm_master itm)
  loop
    update pci_physical_contract_item pci
       set pci.m2m_incoterm_desc = cur_itm.incoterm
     where pci.dbd_id = pc_dbd_id
       and pci.m2m_inco_term = cur_itm.incoterm_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
commit; 
 gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of PCI Incoterm Update'); 
---
-- GMR Discharge and Loading Details
--
begin
  for cur_city in (select cim.city_id,
                          cim.city_name,
                          sm.state_name,
                          cym.country_name,
                          cym.region_id,
                          rem.region_name,
                          cm.cur_id,
                          cm.cur_code
                     from cim_citymaster     cim,
                          sm_state_master    sm,
                          cym_countrymaster  cym,
                          rem_region_master  rem,
                          cm_currency_master cm
                    where cim.state_id = sm.state_id(+)
                      and cim.country_id = cym.country_id(+)
                      and cym.region_id = rem.region_id(+)
                      and cym.national_currency = cm.cur_id(+))
  loop
    update process_gmr gmr
       set gmr.discharge_city_name        = cur_city.city_name,
           gmr.discharge_state_name       = cur_city.state_name,
           gmr.discharge_country_name     = cur_city.country_name,
           gmr.discharge_region_id        = cur_city.region_id,
           gmr.discharge_region_name      = cur_city.region_name,
           gmr.discharge_country_cur_id   = cur_city.cur_id,
           gmr.discharge_country_cur_code = cur_city.cur_code
     where gmr.discharge_city_id = cur_city.city_id
       and gmr.dbd_id = pc_dbd_id
       and gmr.corporate_id = pc_corporate_id;
    update process_gmr gmr
       set gmr.loading_city_name        = cur_city.city_name,
           gmr.loading_state_name       = cur_city.state_name,
           gmr.loading_country_name     = cur_city.country_name,
           gmr.loading_region_id        = cur_city.region_id,
           gmr.loading_region_name      = cur_city.region_name,
           gmr.loading_country_cur_id   = cur_city.cur_id,
           gmr.loading_country_cur_code = cur_city.cur_code
     where gmr.loading_city_id = cur_city.city_id
       and gmr.dbd_id = pc_dbd_id
       and gmr.corporate_id = pc_corporate_id;

        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
end;
  
commit; 
 gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Load and Discharge Update'); 

  for cur_pcm_cur in (select * from cm_currency_master)
  loop
    update pcm_physical_contract_main pcm
       set pcm.invoice_cur_code = cur_pcm_cur.cur_code,
       pcm.invoice_cur_decimals = cur_pcm_cur.decimals
     where pcm.invoice_currency_id = cur_pcm_cur.cur_id
       and pcm.dbd_id = pc_dbd_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
commit;
 gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of PCM Currency Update'); 

for cur_pcm_cp in(select * from phd_profileheaderdetails phd) loop
    update pcm_physical_contract_main pcm
       set pcm.cp_name = cur_pcm_cp.companyname
     where pcm.cp_id = cur_pcm_cp.profileid
       and pcm.dbd_id = pc_dbd_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;
commit;
 gvn_log_counter :=  gvn_log_counter + 1;

sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of PCM CP Update'); 

for cur_ucm in
(select * from ucm_unit_conversion_master ucm) loop
update process_grd grd
set grd.base_qty_conv_factor =  cur_ucm.multiplication_factor
where grd.qty_unit_id = cur_ucm.from_qty_unit_id
and grd.base_qty_unit_id = cur_ucm.to_qty_unit_id
and grd.dbd_id = pc_dbd_id;
update dgrd_delivered_grd dgrd
set dgrd.base_qty_conv_factor =  cur_ucm.multiplication_factor
where dgrd.net_weight_unit_id = cur_ucm.from_qty_unit_id
and dgrd.base_qty_unit_id = cur_ucm.to_qty_unit_id
and dgrd.dbd_id = pc_dbd_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;

end loop;
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GRD Qty Unit Update'); 

for cur_pcmte in
(select * from pcmte_pcm_tolling_ext pcmte) loop
Update process_gmr gmr
set gmr.tolling_service_type = cur_pcmte.tolling_service_type
where gmr.dbd_id = pc_dbd_id
and gmr.internal_contract_ref_no = cur_pcmte.int_contract_ref_no;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;

end loop;
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Tolling Service Type Update'); 
/*update process_grd grd
   set grd.supp_gmr_ref_no = (select gmr_supp.gmr_ref_no
                                from process_gmr gmr_supp
                               where gmr_supp.internal_gmr_ref_no = grd.supp_internal_gmr_ref_no
                               and gmr_supp.dbd_id = pc_dbd_id
                               and gmr_supp.corporate_id = pc_corporate_id )
 where grd.dbd_id = pc_dbd_id
 and grd.corporate_id = pc_corporate_id;*/

delete from tgg_temp_grd_gmr where corporate_id = pc_corporate_id;
 commit;
 insert into tgg_temp_grd_gmr
   (corporate_id, supp_internal_gmr_ref_no, supp_gmr_ref_no)
   select pc_corporate_id,
          grd.supp_internal_gmr_ref_no,
          gmr_supp.gmr_ref_no supp_gmr_ref_no
     from process_gmr gmr_supp,
          process_grd grd
    where gmr_supp.internal_gmr_ref_no = grd.supp_internal_gmr_ref_no
      and gmr_supp.corporate_id = pc_corporate_id
      and grd.corporate_id = pc_corporate_id
    group by grd.supp_internal_gmr_ref_no,
             gmr_supp.gmr_ref_no;
commit; 
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of tgg_temp_grd_gmr Insert'); 

update process_grd grd
       set grd.supp_gmr_ref_no = (select t1.supp_gmr_ref_no from tgg_temp_grd_gmr t1
                                   where t1.supp_internal_gmr_ref_no = grd.supp_internal_gmr_ref_no
                                         and t1.corporate_id = pc_corporate_id)
     where grd.corporate_id = pc_corporate_id;
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GRD.SUPP_GMR_REF_NO Update'); 
delete  eud_element_underlying_details where corporate_id = pc_corporate_id;
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Delete EUD'); 
insert into eud_element_underlying_details
  select pc_corporate_id,
         aml.attribute_id element_id,
         aml.attribute_name element_name,
         pdm_und.product_id underlying_product_id,
         pdm_und.product_desc underlying_product_name,
         qum_und.qty_unit_id underlying_base_qty_unit_id,
         qum_und.qty_unit underlying_base_qty_unit
    from aml_attribute_master_list aml,
         pdm_productmaster         pdm_und,
         qum_quantity_unit_master  qum_und
   where aml.underlying_product_id = pdm_und.product_id
     and pdm_und.base_quantity_unit = qum_und.qty_unit_id;
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Insert EUD'); 
--sp_gather_stats('psr_pool_stock_register');
--sp_gather_stats('pm_pool_master');
--sp_gather_stats('grd_goods_record_detail');
--sp_gather_stats('process_grd');
--sp_gather_stats('process_gmr');
--sp_gather_stats('process_spq');
update process_grd grd
   set (grd.parent_grd_pool_id, grd.parent_grd_pool_name) = --
        (select pm.pool_id,
                pm.pool_name
           from psr_pool_stock_register psr,
                pm_pool_master          pm
          where psr.pool_id = pm.pool_id
            and grd.parent_internal_grd_ref_no = psr.internal_grd_ref_no
            and grd.dbd_id = pc_dbd_id)
 where grd.dbd_id = pc_dbd_id
 and grd.corporate_id = pc_corporate_id;

commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GRD.POOL_ID Update 1'); 
update process_grd grd
   set (grd.pool_id, grd.pool_name) = --
        (select pm.pool_id,
                pm.pool_name
           from psr_pool_stock_register psr,
                pm_pool_master          pm
          where psr.pool_id = pm.pool_id
            and grd.internal_grd_ref_no = psr.internal_grd_ref_no
            and grd.dbd_id = pc_dbd_id)
 where grd.dbd_id = pc_dbd_id
 and grd.corporate_id = pc_corporate_id;
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GRD.POOL_ID Update 2')  ; 
    delete from temp_gmr_fpn where corporate_id = pc_corporate_id;
    commit;
    insert into temp_gmr_fpn
      (corporate_id,
       internal_gmr_ref_no,
       feeding_point_id,
       feeding_point_name)
      select pc_corporate_id corporate_id,
             wrd.internal_gmr_ref_no,
             sfp.feeding_point_id,
             sfp.feeding_point_name
        from wrd_warehouse_receipt_detail@eka_appdb wrd,
             sfp_smelter_feeding_point@eka_appdb    sfp
       where wrd.feeding_point_id = sfp.feeding_point_id
         and wrd.action_no = 1;
    commit;
    update process_gmr gmr
       set (gmr.feeding_point_id, gmr.feeding_point_name) = (select t.feeding_point_id,
                                                                    t.feeding_point_name
                                                               from temp_gmr_fpn t
                                                              where t.internal_gmr_ref_no =
                                                                    gmr.internal_gmr_ref_no
                                                                and t.corporate_id =
                                                                    pc_corporate_id)
     where gmr.is_deleted = 'N'
       and gmr.dbd_id = pc_dbd_id
       and gmr.corporate_id = pc_corporate_id;
commit;                                 
/*for cur_fp in(
select wrd.internal_gmr_ref_no,
       sfp.feeding_point_id,
       sfp.feeding_point_name
  from wrd_warehouse_receipt_detail@eka_appdb wrd,
       sfp_smelter_feeding_point@eka_appdb    sfp
 where wrd.feeding_point_id = sfp.feeding_point_id
  and wrd.action_no = 1) loop
Update process_gmr gmr
set gmr.feeding_point_id = cur_fp.feeding_point_id,
gmr.feeding_point_name = cur_fp.feeding_point_name
where gmr.internal_gmr_ref_no = cur_fp.internal_gmr_ref_no
and gmr.is_deleted ='N'
and gmr.dbd_id = pc_dbd_id
and gmr.corporate_id = pc_corporate_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;

end loop;*/ 
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR.FEEDING_POINT_ID  Update'); 
sp_gather_stats('process_grd');
--sp_gather_stats('process_gmr');
--sp_gather_stats('process_spq');
                          
--
-- For MFT Stocks Update the Supplier GMR Invoice Currency Details
--
  /*for cur_mft_grd in (select gmr.internal_gmr_ref_no,
                             gmr.invoice_cur_id supp_invoice_cur_id,
                             gmr.invoice_cur_code supp_invoice_cur_code,
                             gmr.invoice_cur_decimals supp_invoice_cur_decimals
                        from process_gmr gmr
                       where gmr.dbd_id = pc_dbd_id
                       and gmr.corporate_id = pc_corporate_id
                       --  and gmr.internal_gmr_ref_no =   grd.supp_internal_gmr_ref_no
                      )
  loop
    update process_grd grd
       set grd.invoice_cur_id       = cur_mft_grd.supp_invoice_cur_id,
           grd.invoice_cur_code     = cur_mft_grd.supp_invoice_cur_code,
           grd.invoice_cur_decimals = cur_mft_grd.supp_invoice_cur_decimals
     where grd.dbd_id = pc_dbd_id
       and grd.corporate_id = pc_corporate_id
       and grd.status = 'Active'
       and grd.tolling_stock_type = 'Clone Stock'
       and grd.supp_internal_gmr_ref_no = cur_mft_grd.internal_gmr_ref_no ;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;
       
  end loop;*/
  update process_grd grd
     set (grd.invoice_cur_id, grd.invoice_cur_code, grd.invoice_cur_decimals) = (select gmr.invoice_cur_id,
                                                                                        gmr.invoice_cur_code,
                                                                                        gmr.invoice_cur_decimals
                                                                                   from process_gmr gmr
                                                                                  where gmr.dbd_id =
                                                                                        pc_dbd_id
                                                                                    and gmr.corporate_id =
                                                                                        pc_corporate_id
                                                                                    and gmr.internal_gmr_ref_no =
                                                                                        grd.supp_internal_gmr_ref_no)
   where grd.status = 'Active'
     and grd.tolling_stock_type = 'Clone Stock'
     and grd.dbd_id = pc_dbd_id
     and grd.corporate_id = pc_corporate_id
      and exists    
   (select g.internal_gmr_ref_no
            from process_gmr g
           where g.internal_gmr_ref_no = grd.internal_gmr_ref_no
             and g.dbd_id = pc_dbd_id
             and g.contract_type='Tolling');  
  commit;

gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of MFT Stock Invoice Currency Update'); 
--
-- GMR Shipment Date
--                          
for cur_gmr_sd in(
select t.internal_gmr_ref_no,
       t.eff_date gmr_shipment_date
  from agmr_action_gmr t
 where action_no = 1
   and is_deleted = 'N') loop
Update process_gmr gmr
set gmr.gmr_shipment_date =cur_gmr_sd.gmr_shipment_date
where gmr.internal_gmr_ref_no = cur_gmr_sd.internal_gmr_ref_no
and gmr.is_deleted ='N'
and  gmr.dbd_id = pc_dbd_id
and gmr.corporate_id = pc_corporate_id;
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;

end loop;
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Shipment Date Update');     
--
-- GMR Landing Date Update
--
for cur_gmr_ld in(
select agmr.internal_gmr_ref_no,
       agmr.eff_date gmr_landing_date
  from agmr_action_gmr agmr
 where (agmr.internal_gmr_ref_no, agmr.action_no) in
       (select agmr.internal_gmr_ref_no,
               max(agmr.action_no) action_no
          from agmr_action_gmr agmr
         where agmr.eff_date <= pd_trade_date
           and agmr.is_deleted = 'N'
         group by agmr.internal_gmr_ref_no)) loop
 Update process_gmr gmr
set gmr.gmr_landed_date =cur_gmr_ld.gmr_landing_date
where gmr.is_deleted ='N'
and gmr.internal_gmr_ref_no = cur_gmr_ld.internal_gmr_ref_no
and gmr.gmr_status in ('In Warehouse', 'Landed','Released')
and gmr.dbd_id = pc_dbd_id
and gmr.corporate_id = pc_corporate_id;        
        vn_row_cnt := vn_row_cnt + 1;
        if vn_row_cnt >= 500 then
          commit;
          vn_row_cnt := 0;
        end if;

end loop;
commit;
gvn_log_counter :=  gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of GMR Landing Date Update');     
 delete from temp_grd_intstock_inv where corporate_id = pc_corporate_id;
  commit;
  gvn_log_counter := gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            gvn_log_counter,
                            'update invoice currency details for internal moved stocks startes..');
  insert into temp_grd_intstock_inv
  (corporate_id,
   internal_gmr_ref_no,
   internal_grd_ref_no,
   parent_internal_grd_ref_no)
  select gmr1.corporate_id,
         gmr1.internal_gmr_ref_no,
         grd1.internal_grd_ref_no,
         grd1.parent_internal_grd_ref_no
    from process_gmr gmr1,
         process_grd grd1
   where gmr1.dbd_id = pc_dbd_id
     and gmr1.corporate_id = pc_corporate_id
     and grd1.dbd_id = pc_dbd_id
     and gmr1.is_internal_movement = 'Y'
     and gmr1.internal_gmr_ref_no = grd1.internal_gmr_ref_no;
commit;   
 gvn_log_counter := gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            gvn_log_counter,
                            'insert into temp_grd_intstock_inv completed..');   
-------
delete from temp_grd_intstock_inv1 t where t.corporate_id = pc_corporate_id;
commit;
insert into temp_grd_intstock_inv1
  (corporate_id,
   internal_grd_ref_no,
   parent_internal_grd_ref_no,
   parent_internal_gmr_ref_no,
   parent_gmr_ref_no,
   invoice_cur_id,
   invoice_cur_code,
   invoice_cur_decimals)
  select ct.corporate_id,
         ct.internal_grd_ref_no,
         ct.parent_internal_grd_ref_no,
         max(gmr.internal_gmr_ref_no) parent_internal_gmr_ref_no,
         max(gmr.gmr_ref_no) parent_gmr_ref_no,
         max(gmr.invoice_cur_id)invoice_cur_id,
         max(gmr.invoice_cur_code)invoice_cur_code,
         max(gmr.invoice_cur_decimals)invoice_cur_decimals
    from process_grd           grd,
         process_gmr           gmr,
         temp_grd_intstock_inv ct
   where grd.internal_grd_ref_no = ct.parent_internal_grd_ref_no
     and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     and grd.dbd_id = pc_dbd_id
     and gmr.dbd_id = pc_dbd_id
     and ct.corporate_id = pc_corporate_id
     group by ct.corporate_id,
         ct.internal_grd_ref_no,
         ct.parent_internal_grd_ref_no;
commit;         
----------   
 gvn_log_counter := gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            gvn_log_counter,
                            'insert into temp_grd_intstock_inv1 completed..');  
 sp_gather_stats('temp_grd_intstock_inv1');
 sp_gather_stats('process_gmr');
 sp_gather_stats('process_grd');                             
  update process_grd grd
     set (grd.invoice_cur_id, grd.invoice_cur_code, grd.invoice_cur_decimals) = (select gmr.invoice_cur_id,
                                                                                        gmr.invoice_cur_code,
                                                                                        gmr.invoice_cur_decimals
                                                                                   from temp_grd_intstock_inv1 gmr
                                                                                  where gmr.corporate_id =
                                                                                        pc_corporate_id
                                                                                    and gmr.internal_grd_ref_no =
                                                                                        grd.internal_grd_ref_no)
   where grd.status = 'Active'
     and grd.tolling_stock_type = 'None Tolling'
     and grd.dbd_id = pc_dbd_id
     and grd.corporate_id = pc_corporate_id
     and exists
   (select g.internal_gmr_ref_no
            from process_gmr g
           where g.internal_gmr_ref_no = grd.internal_gmr_ref_no
             and g.dbd_id = pc_dbd_id
             and g.is_internal_movement = 'Y');
    commit;    
  gvn_log_counter := gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                            pd_trade_date,
                            pc_dbd_id,
                            gvn_log_counter,
                            'update invoice currency details for internal moved stocks ends..');                                    
  sp_gather_stats('process_grd');
  sp_gather_stats('process_gmr');
  sp_gather_stats('process_spq');
  sp_gather_stats('EUD_ELEMENT_UNDERLYING_DETAILS');
  -- insert GRD/GMR/SPQ table Data from process GRD/GMR/SPQ tables
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'insert grd_goods_record_detail from process_grd'); 
  insert into grd_goods_record_detail
  (internal_grd_ref_no,
   internal_gmr_ref_no,
   product_id,
   is_afloat,
   status,
   qty,
   qty_unit_id,
   gross_weight,
   tare_weight,
   internal_contract_item_ref_no,
   int_alloc_group_id,
   packing_size_id,
   container_no,
   seal_no,
   mark_no,
   warehouse_ref_no,
   no_of_units,
   quality_id,
   warehouse_profile_id,
   shed_id,
   origin_id,
   crop_year_id,
   parent_id,
   is_released_shipped,
   release_shipped_no_of_units,
   is_write_off,
   write_off_no_of_units,
   is_deleted,
   is_moved_out,
   moved_out_no_of_units,
   total_no_of_units,
   total_qty,
   moved_out_qty,
   release_shipped_qty,
   write_off_qty,
   title_transfer_out_qty,
   title_transfer_out_no_of_units,
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
   discharged_qty,
   is_voyage_stock,
   allocated_qty,
   internal_stock_ref_no,
   landed_no_of_units,
   landed_net_qty,
   landed_gross_qty,
   shipped_no_of_units,
   shipped_net_qty,
   shipped_gross_qty,
   current_qty,
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
   internal_action_ref_no,
   packing_type_id,
   handled_as,
   allocated_no_of_units,
   current_no_of_units,
   stock_condition,
   gravity_type_id,
   gravity,
   density_mass_qty_unit_id,
   density_volume_qty_unit_id,
   gravity_type,
   customs_id,
   tax_id,
   duty_id,
   customer_seal_no,
   brand,
   no_of_containers,
   no_of_bags,
   no_of_pieces,
   rail_car_no,
   sdcts_id,
   partnership_type,
   dbd_id,
   process_id,
   payment_due_date,
   profit_center_id,
   strategy_id,
   is_warrant,
   warrant_no,
   pcdi_id,
   supp_contract_item_ref_no,
   supplier_pcdi_id,
   payable_returnable_type,
   is_trans_ship,
   is_mark_for_tolling,
   tolling_qty,
   tolling_stock_type,
   element_id,
   expected_sales_ccy,
   carry_over_qty,
   supp_internal_gmr_ref_no,
   dry_qty,
   qty_unit,
   dry_wet_ratio,
   grd_to_gmr_qty_factor,
   quality_name,
   profit_center_short_name,
   profit_center_name,
   assay_header_id,
   weg_avg_pricing_assay_id,
   conc_product_id,
   conc_product_name,
   product_name,
   base_qty_unit_id,
   base_qty_unit,
   base_qty_conv_factor,
   supp_gmr_ref_no,
   parent_grd_pool_id,
   parent_grd_pool_name,
   pool_id,
   pool_name,
   invoice_cur_id,
   invoice_cur_code,
   invoice_cur_decimals,
   gmr_qty_unit_id,
   cot_int_action_ref_no)
  select internal_grd_ref_no,
         internal_gmr_ref_no,
         product_id,
         is_afloat,
         status,
         qty,
         qty_unit_id,
         gross_weight,
         tare_weight,
         internal_contract_item_ref_no,
         int_alloc_group_id,
         packing_size_id,
         container_no,
         seal_no,
         mark_no,
         warehouse_ref_no,
         no_of_units,
         quality_id,
         warehouse_profile_id,
         shed_id,
         origin_id,
         crop_year_id,
         parent_id,
         is_released_shipped,
         release_shipped_no_of_units,
         is_write_off,
         write_off_no_of_units,
         is_deleted,
         is_moved_out,
         moved_out_no_of_units,
         total_no_of_units,
         total_qty,
         moved_out_qty,
         release_shipped_qty,
         write_off_qty,
         title_transfer_out_qty,
         title_transfer_out_no_of_units,
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
         discharged_qty,
         is_voyage_stock,
         allocated_qty,
         internal_stock_ref_no,
         landed_no_of_units,
         landed_net_qty,
         landed_gross_qty,
         shipped_no_of_units,
         shipped_net_qty,
         shipped_gross_qty,
         current_qty,
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
         internal_action_ref_no,
         packing_type_id,
         handled_as,
         allocated_no_of_units,
         current_no_of_units,
         stock_condition,
         gravity_type_id,
         gravity,
         density_mass_qty_unit_id,
         density_volume_qty_unit_id,
         gravity_type,
         customs_id,
         tax_id,
         duty_id,
         customer_seal_no,
         brand,
         no_of_containers,
         no_of_bags,
         no_of_pieces,
         rail_car_no,
         sdcts_id,
         partnership_type,
         dbd_id,
         process_id,
         payment_due_date,
         profit_center_id,
         strategy_id,
         is_warrant,
         warrant_no,
         pcdi_id,
         supp_contract_item_ref_no,
         supplier_pcdi_id,
         payable_returnable_type,
         is_trans_ship,
         is_mark_for_tolling,
         tolling_qty,
         tolling_stock_type,
         element_id,
         expected_sales_ccy,
         carry_over_qty,
         supp_internal_gmr_ref_no,
         dry_qty,
         qty_unit,
         dry_wet_ratio,
         grd_to_gmr_qty_factor,
         quality_name,
         profit_center_short_name,
         profit_center_name,
         assay_header_id,
         weg_avg_pricing_assay_id,
         conc_product_id,
         conc_product_name,
         product_name,
         base_qty_unit_id,
         base_qty_unit,
         base_qty_conv_factor,
         supp_gmr_ref_no,
         parent_grd_pool_id,
         parent_grd_pool_name,
         pool_id,
         pool_name,
         invoice_cur_id,
         invoice_cur_code,
         invoice_cur_decimals,
         gmr_qty_unit_id,
         cot_int_action_ref_no
    from process_grd
    where corporate_id = pc_corporate_id;
    commit;
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'insert spq_stock_payable_qty from process_spq'); 
  insert into spq_stock_payable_qty
    (spq_id,
     internal_gmr_ref_no,
     action_no,
     stock_type,
     internal_grd_ref_no,
     internal_dgrd_ref_no,
     element_id,
     payable_qty,
     qty_unit_id,
     version,
     is_active,
     dbd_id,
     process_id,
     qty_type,
     activity_action_id,
     is_stock_split,
     supplier_id,
     smelter_id,
     in_process_stock_id,
     free_metal_stock_id,
     free_metal_qty,
     internal_action_ref_no,
     assay_content,
     pledge_stock_id,
     gepd_id,
     assay_header_id,
     is_final_assay,
     corporate_id,
     weg_avg_pricing_assay_id,
     weg_avg_invoice_assay_id,
     qty_unit)
    select spq_id,
           internal_gmr_ref_no,
           action_no,
           stock_type,
           internal_grd_ref_no,
           internal_dgrd_ref_no,
           element_id,
           payable_qty,
           qty_unit_id,
           version,
           is_active,
           dbd_id,
           process_id,
           qty_type,
           activity_action_id,
           is_stock_split,
           supplier_id,
           smelter_id,
           in_process_stock_id,
           free_metal_stock_id,
           free_metal_qty,
           internal_action_ref_no,
           assay_content,
           pledge_stock_id,
           gepd_id,
           assay_header_id,
           is_final_assay,
           corporate_id,
           weg_avg_pricing_assay_id,
           weg_avg_invoice_assay_id,
           qty_unit
      from process_spq
      where corporate_id = pc_corporate_id;
      commit;                              
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'insert gmr_goods_movement_record from process_gmr'); 
insert into gmr_goods_movement_record
  (internal_gmr_ref_no,
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
   internal_action_ref_no,
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
   total_gross_weight,
   total_tare_weight,
   dbd_id,
   process_id,
   tolling_qty,
   tolling_gmr_type,
   pool_id,
   is_warrant,
   is_pass_through,
   pledge_input_gmr,
   is_apply_freight_allowance,
   is_final_invoiced,
   is_provisional_invoiced,
   product_id,
   latest_internal_invoice_ref_no,
   carry_over_qty,
   mode_of_transport,
   arrival_date,
   wns_status,
   is_apply_container_charge,
   loading_date,
   no_of_containers,
   gmr_type,
   contract_ref_no,
   cp_id,
   cp_name,
   stock_current_qty,
   dry_qty,
   wet_qty,
   invoice_ref_no,
   warehouse_name,
   is_new_mtd,
   is_new_ytd,
   is_assay_updated_mtd,
   is_assay_updated_ytd,
   assay_final_status,
   quality_name,
   invoice_cur_id,
   invoice_cur_code,
   invoice_cur_decimals,
   gmr_status,
   shed_name,
   loading_country_name,
   loading_city_name,
   loading_state_name,
   loading_region_id,
   loading_region_name,
   discharge_country_name,
   discharge_city_name,
   discharge_state_name,
   discharge_region_id,
   discharge_region_name,
   loading_country_cur_id,
   loading_country_cur_code,
   discharge_country_cur_id,
   discharge_country_cur_code,
   tolling_service_type,
   gmr_arrival_status,
   feeding_point_id,
   feeding_point_name,
   is_new_mtd_ar,
   is_new_ytd_ar,
   is_assay_updated_mtd_ar,
   is_assay_updated_ytd_ar,
   is_tolling_contract,
   pcm_contract_type,
   is_new_final_invoice,
   base_conc_mix_type,
   gmr_shipment_date,
   gmr_landed_date,
   is_new_landing,
   is_new_shipment,
   is_payable_qty_changed_mtd,
   is_tc_changed_mtd,
   is_rc_changed_mtd,
   is_pc_changed_mtd,
   is_payable_qty_changed_ytd,
   is_tc_changed_ytd,
   is_rc_changed_ytd,
   is_pc_changed_ytd,
   is_new_debit_credit_invoice,
   debit_credit_invoice_no,
   pcdi_id,
   product_name,
   quality_id,
   is_new_invoice,
   is_new_fi_ytd)
  select internal_gmr_ref_no,
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
         internal_action_ref_no,
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
         total_gross_weight,
         total_tare_weight,
         dbd_id,
         process_id,
         tolling_qty,
         tolling_gmr_type,
         pool_id,
         is_warrant,
         is_pass_through,
         pledge_input_gmr,
         is_apply_freight_allowance,
         is_final_invoiced,
         is_provisional_invoiced,
         product_id,
         latest_internal_invoice_ref_no,
         carry_over_qty,
         mode_of_transport,
         arrival_date,
         wns_status,
         is_apply_container_charge,
         loading_date,
         no_of_containers,
         gmr_type,
         contract_ref_no,
         cp_id,
         cp_name,
         stock_current_qty,
         dry_qty,
         wet_qty,
         invoice_ref_no,
         warehouse_name,
         is_new_mtd,
         is_new_ytd,
         is_assay_updated_mtd,
         is_assay_updated_ytd,
         assay_final_status,
         quality_name,
         invoice_cur_id,
         invoice_cur_code,
         invoice_cur_decimals,
         gmr_status,
         shed_name,
         loading_country_name,
         loading_city_name,
         loading_state_name,
         loading_region_id,
         loading_region_name,
         discharge_country_name,
         discharge_city_name,
         discharge_state_name,
         discharge_region_id,
         discharge_region_name,
         loading_country_cur_id,
         loading_country_cur_code,
         discharge_country_cur_id,
         discharge_country_cur_code,
         tolling_service_type,
         gmr_arrival_status,
         feeding_point_id,
         feeding_point_name,
         is_new_mtd_ar,
         is_new_ytd_ar,
         is_assay_updated_mtd_ar,
         is_assay_updated_ytd_ar,
         is_tolling_contract,
         pcm_contract_type,
         is_new_final_invoice,
         base_conc_mix_type,
         gmr_shipment_date,
         gmr_landed_date,
         is_new_landing,
         is_new_shipment,
         is_payable_qty_changed_mtd,
         is_tc_changed_mtd,
         is_rc_changed_mtd,
         is_pc_changed_mtd,
         is_payable_qty_changed_ytd,
         is_tc_changed_ytd,
         is_rc_changed_ytd,
         is_pc_changed_ytd,
         is_new_debit_credit_invoice,
         debit_credit_invoice_no,
         pcdi_id,
         product_name,
         quality_id,
         is_new_invoice,
         is_new_fi_ytd
    from process_gmr
    where corporate_id = pc_corporate_id;    
 commit;
/* delete from process_grd grd where grd.status <> 'Active' and grd.corporate_id = pc_corporate_id;
 commit;
 delete from process_spq spq where spq.is_active = 'N' and spq.corporate_id = pc_corporate_id;
 commit;
 delete from process_gmr gmr where gmr.is_deleted = 'Y' and gmr.corporate_id = pc_corporate_id;
 commit;*/
 
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'Start sp_gather_stats for GMR,GRD,SPQ');  
  sp_gather_stats('gmr_goods_movement_record');
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'stats GMR Completed');    
  sp_gather_stats('spq_stock_payable_qty');
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'stats SPQ Completed');    

  sp_gather_stats('grd_goods_record_detail');
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'stats GRD Completed');    
  
  sp_gather_stats('process_gmr');
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'stats P GMR Completed');    
  
  sp_gather_stats('process_grd');
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'stats P GRD Completed');    
  
  sp_gather_stats('process_spq');
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'stats P SPG Completed');      
 gvn_log_counter :=  gvn_log_counter + 1;
 sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'Start of sp_create_exchange_data'); 
  sp_create_exchange_data(pc_corporate_id,
                          pd_trade_date,
                          pc_user_id,
                          gvc_dbd_id,
                          pc_process);
 gvn_log_counter :=  gvn_log_counter + 1;
  sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'End of Populate Exchange Data');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_phy_update_contract_details',
                                                           'M2M-013',
                                                           'Code:' || sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
procedure sp_create_exchange_data(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_user_id      varchar2,
                                       pc_dbd_id       varchar2,
                                       pc_process      varchar2)
is
  vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
  vn_eel_error_count number := 1;
  
begin
gvn_log_counter := gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'stats for contract tables started');
sp_gather_stats('pci_physical_contract_item');
sp_gather_stats('pcm_physical_contract_main');
sp_gather_stats('dipq_delivery_item_payable_qty');
sp_gather_stats('pcbpd_pc_base_price_detail');
sp_gather_stats('pcbph_pc_base_price_header');
sp_gather_stats('pcdi_pc_delivery_item');
sp_gather_stats('pcipf_pci_pricing_formula');
sp_gather_stats('pocd_price_option_calloff_dtls');
sp_gather_stats('poch_price_opt_call_off_header');
sp_gather_stats('ppfd_phy_price_formula_details');
sp_gather_stats('ppfh_phy_price_formula_header');
commit;
gvn_log_counter := gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'stats for contract tables end');

delete from ced_contract_exchange_detail ced
where ced.corporate_id = pc_corporate_id;
commit;
gvn_log_counter := gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'Delete from ced over');
commit;
  delete from cec_contract_exchange_child
   where corporate_id = pc_corporate_id;
  commit;
  sp_write_log(pc_corporate_id,
               pd_trade_date,
               'Populate cec',
               'Delete CEC_CONTRACT_EXCHANGE_CHILD');
  insert into cec_contract_exchange_child
    (corporate_id,
     internal_contract_item_ref_no,
     element_id,
     instrument_id,
     pcdi_id)
    select /*+ ordered */
           pc_corporate_id,
           pci.internal_contract_item_ref_no,
           poch.element_id,
           ppfd.instrument_id,
           pci.pcdi_id
      from pci_physical_contract_item     pci,
           pcdi_pc_delivery_item          pcdi,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           ppfd_phy_price_formula_details ppfd,
           pcm_physical_contract_main     pcm
     where pci.pcdi_id = pcdi.pcdi_id
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pcbpd_id = pcbpd.pcbpd_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id
       and ppfh.ppfh_id = ppfd.ppfh_id
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pci.dbd_id = pc_dbd_id
       and pcdi.dbd_id = pc_dbd_id
       and pcbpd.dbd_id = pc_dbd_id
       and ppfh.dbd_id = pc_dbd_id
       and ppfd.dbd_id = pc_dbd_id
       and pcm.dbd_id = pc_dbd_id
       and pcm.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcdi.is_active = 'Y'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pcbpd.is_active = 'Y'
       and ppfh.is_active = 'Y'
       and ppfd.is_active = 'Y'
       and pcm.product_group_type = 'BASEMETAL'
       and pcdi.price_option_call_off_status in
           ('Called Off', 'Not Applicable')
     group by pci.internal_contract_item_ref_no,
              ppfd.instrument_id,
              poch.element_id,
              pci.pcdi_id;
  commit;
  sp_write_log(pc_corporate_id,
               pd_trade_date,
               'Populate cec',
               'BM Called Off');
  insert into cec_contract_exchange_child
    (corporate_id,
     internal_contract_item_ref_no,
     element_id,
     instrument_id,
     pcdi_id)
    select /*+ ordered */
           pc_corporate_id,
           pci.internal_contract_item_ref_no,
           pcbpd.element_id,
           ppfd.instrument_id,
           pci.pcdi_id
      from pci_physical_contract_item     pci,
           pcdi_pc_delivery_item          pcdi,
           pcipf_pci_pricing_formula      pcipf,
           pcbph_pc_base_price_header     pcbph,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           ppfd_phy_price_formula_details ppfd,
           pcm_physical_contract_main     pcm
     where pci.internal_contract_item_ref_no =
           pcipf.internal_contract_item_ref_no
       and pcipf.pcbph_id = pcbph.pcbph_id
       and pcbph.pcbph_id = pcbpd.pcbph_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id
       and ppfh.ppfh_id = ppfd.ppfh_id
       and pci.pcdi_id = pcdi.pcdi_id
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pci.dbd_id = pc_dbd_id
       and pcdi.dbd_id = pc_dbd_id
       and pcipf.dbd_id = pc_dbd_id
       and pcbph.dbd_id = pc_dbd_id
       and ppfh.dbd_id = pc_dbd_id
       and ppfd.dbd_id = pc_dbd_id
       and pcbpd.dbd_id = pc_dbd_id
       and pcm.dbd_id = pc_dbd_id
       and pcdi.is_active = 'Y'
       and pcm.product_group_type = 'BASEMETAL'
       and pcdi.price_option_call_off_status = 'Not Called Off'
       and pci.is_active = 'Y'
       and pcipf.is_active = 'Y'
       and pcbph.is_active = 'Y'
       and pcbpd.is_active = 'Y'
       and ppfh.is_active = 'Y'
       and ppfd.is_active = 'Y'
     group by pci.internal_contract_item_ref_no,
              ppfd.instrument_id,
              pcbpd.element_id,
              pci.pcdi_id;
  commit;
  sp_write_log(pc_corporate_id,
               pd_trade_date,
               'Populate cec',
               'BM Not Called Off');
  
  
  insert into cec_contract_exchange_child
    (corporate_id,
     internal_contract_item_ref_no,
     element_id,
     instrument_id,
     pcdi_id)
    select /*+ ordered */
     pc_corporate_id,
     pci.internal_contract_item_ref_no,
     pcbpd.element_id,
     ppfd.instrument_id,
     pci.pcdi_id
      from pci_physical_contract_item     pci,
           pcdi_pc_delivery_item          pcdi,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           ppfd_phy_price_formula_details ppfd,
           dipq_delivery_item_payable_qty dipq,
           pcm_physical_contract_main     pcm
     where pci.pcdi_id = pcdi.pcdi_id
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pcbpd_id = pcbpd.pcbpd_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id
       and ppfh.ppfh_id = ppfd.ppfh_id
       and pcdi.pcdi_id = dipq.pcdi_id
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pci.dbd_id = pc_dbd_id
       and pcdi.dbd_id = pc_dbd_id
       and pcbpd.dbd_id = pc_dbd_id
       and ppfh.dbd_id = pc_dbd_id
       and ppfd.dbd_id = pc_dbd_id
       and dipq.dbd_id = pc_dbd_id
       and pcbpd.dbd_id = pc_dbd_id
       and pcm.dbd_id = pc_dbd_id
       and dipq.element_id = pcbpd.element_id
       and pcdi.is_active = 'Y'
       and dipq.price_option_call_off_status in
           ('Called Off', 'Not Applicable')
       and pcm.product_group_type = 'CONCENTRATES'
       and pcm.is_active = 'Y'
       and dipq.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcbpd.is_active = 'Y'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and ppfh.is_active = 'Y'
       and ppfd.is_active = 'Y'
     group by pci.internal_contract_item_ref_no,
              ppfd.instrument_id,
              pcbpd.element_id,
              pci.pcdi_id;

  commit;
  sp_write_log(pc_corporate_id,
               pd_trade_date,
               'Populate cec',
               'Concentrates Called Off');
  
  
  insert into cec_contract_exchange_child
    (corporate_id,
     internal_contract_item_ref_no,
     element_id,
     instrument_id,
     pcdi_id)
    select /*+ ordered */
     pc_corporate_id,
     pci.internal_contract_item_ref_no,
     pcbpd.element_id,
     ppfd.instrument_id,
     pci.pcdi_id
      from pci_physical_contract_item     pci,
           pcdi_pc_delivery_item          pcdi,
           pcipf_pci_pricing_formula      pcipf,
           pcbph_pc_base_price_header     pcbph,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           ppfd_phy_price_formula_details ppfd,
           dipq_delivery_item_payable_qty dipq,
           pcm_physical_contract_main     pcm
     where pci.internal_contract_item_ref_no =
           pcipf.internal_contract_item_ref_no
       and pcipf.pcbph_id = pcbph.pcbph_id
       and pcbph.pcbph_id = pcbpd.pcbph_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id
       and ppfh.ppfh_id = ppfd.ppfh_id
       and pci.pcdi_id = pcdi.pcdi_id
       and pcdi.pcdi_id = dipq.pcdi_id
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pci.dbd_id = pc_dbd_id
       and pcdi.dbd_id = pc_dbd_id
       and pcipf.dbd_id = pc_dbd_id
       and pcbph.dbd_id = pc_dbd_id
       and ppfh.dbd_id = pc_dbd_id
       and ppfd.dbd_id = pc_dbd_id
       and dipq.dbd_id = pc_dbd_id
       and pcm.dbd_id = pc_dbd_id
       and dipq.element_id = pcbpd.element_id
       and pcdi.is_active = 'Y'
       and dipq.price_option_call_off_status = 'Not Called Off'
       and pcm.product_group_type = 'CONCENTRATES'
       and pcm.is_active = 'Y'
       and dipq.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcipf.is_active = 'Y'
       and pcbph.is_active = 'Y'
       and pcbpd.is_active = 'Y'
       and ppfh.is_active = 'Y'
       and ppfd.is_active = 'Y'
     group by pci.internal_contract_item_ref_no,
              ppfd.instrument_id,
              pcbpd.element_id,
              pci.pcdi_id;
  commit;
  sp_write_log(pc_corporate_id,
               pd_trade_date,
               'Populate cec',
               'Concentrates Not Called Off');

  insert into ced_contract_exchange_detail
    (corporate_id,
     internal_contract_item_ref_no,
     pcdi_id,
     element_id,
     instrument_id,
     instrument_name,
     derivative_def_id,
     derivative_def_name,
     exchange_id,
     exchange_name)
    select pc_corporate_id,
           tt.internal_contract_item_ref_no,
           tt.pcdi_id,
           tt.element_id,
           tt.instrument_id,
           dim.instrument_name,
           pdd.derivative_def_id,
           pdd.derivative_def_name,
           emt.exchange_id,
           emt.exchange_name
      from (select internal_contract_item_ref_no,
                   element_id,
                   instrument_id,
                   pcdi_id
              from cec_contract_exchange_child
             where corporate_id = pc_corporate_id) tt,
           dim_der_instrument_master dim,
           pdd_product_derivative_def pdd,
           emt_exchangemaster emt
     where tt.instrument_id = dim.instrument_id
       and dim.product_derivative_id = pdd.derivative_def_id
       and pdd.exchange_id = emt.exchange_id(+)
     group by tt.internal_contract_item_ref_no,
              tt.element_id,
              tt.instrument_id,
              dim.instrument_name,
              pdd.derivative_def_id,
              pdd.derivative_def_name,
              emt.exchange_id,
              emt.exchange_name,
              tt.pcdi_id;
  commit;
  sp_write_log(pc_corporate_id,
               pd_trade_date,
               'Populate cec',
               'End of CED Population');
gvn_log_counter := gvn_log_counter + 1;
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'Insert ced over');
    
    delete from ged_gmr_exchange_detail ged
     where ged.corporate_id = pc_corporate_id;
    commit;
gvn_log_counter := gvn_log_counter + 1;    
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'delete from ged over');
    insert into ged_gmr_exchange_detail
      (corporate_id,
       internal_gmr_ref_no,
       instrument_id,
       instrument_name,
       derivative_def_id,
       derivative_def_name,
       exchange_id,
       exchange_name,
       element_id,
       price_source_id,
       price_source_name,
       available_price_id,
       available_price_name,
       price_unit_name,
       ppu_price_unit_id,
       price_unit_id,
       delivery_calender_id,
       is_daily_cal_applicable,
       is_monthly_cal_applicable)
      select pc_corporate_id,
             pofh.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name,
             pcbpd.element_id,
             ps.price_source_id,
             ps.price_source_name,
             apm.available_price_id,
             apm.available_price_name,
             pum.price_unit_name,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd,
             dim_der_instrument_master      dim,
             pdd_product_derivative_def     pdd,
             emt_exchangemaster             emt,
             div_der_instrument_valuation   div,
             ps_price_source                ps,
             apm_available_price_master     apm,
             pum_price_unit_master          pum,
             v_der_instrument_price_unit    vdip,
             pdc_prompt_delivery_calendar   pdc
       where pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.ppfh_id = ppfd.ppfh_id
         and pcbpd.dbd_id = ppfh.dbd_id
         and ppfh.dbd_id = ppfd.dbd_id
         and ppfd.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
         and pofh.internal_gmr_ref_no is not null
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and ppfh.is_active = 'Y'
         and ppfd.is_active = 'Y'
         and ppfd.dbd_id = pc_dbd_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
       group by pofh.internal_gmr_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                pcbpd.element_id,
                ps.price_source_id,
                ps.price_source_name,
                apm.available_price_id,
                apm.available_price_name,
                pum.price_unit_name,
                vdip.ppu_price_unit_id,
                div.price_unit_id,
                dim.delivery_calender_id,
                pdc.is_daily_cal_applicable,
                pdc.is_monthly_cal_applicable;
commit;
gvn_log_counter := gvn_log_counter + 1;  
sp_precheck_process_log(pc_corporate_id,
                          pd_trade_date,
                          pc_dbd_id,
                          gvn_log_counter,
                          'Insert into ged over');                

sp_gather_stats('ged_gmr_exchange_detail');
sp_gather_stats('ced_contract_exchange_detail');
 exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_create_exchange_data',
                                                           'M2M-013',
                                                           'Code:' || sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);                
end;  

procedure sp_phy_create_gth_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
is 
begin 
insert into gth_gmr_treatment_header
  (gth_id,
   internal_gmr_ref_no,
   pcdi_id,
   pcth_id,
   is_active,
   internal_action_ref_no,
   dbd_id,
   process_id)
  select gthul.gth_id,
         substr(max(case
                      when gthul.internal_gmr_ref_no is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gthul.internal_gmr_ref_no
                    end),
                24) internal_gmr_ref_no,
         substr(max(case
                      when gthul.pcdi_id is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gthul.pcdi_id
                    end),
                24) pcdi_id,
         substr(max(case
                      when gthul.pcth_id is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gthul.pcth_id
                    end),
                24) pcth_id,
         substr(max(case
                      when gthul.is_active is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gthul.is_active
                    end),
                24) is_active,
         substr(max(case
                      when gthul.internal_action_ref_no is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gthul.internal_action_ref_no
                    end),
                24) internal_action_ref_no,
         gvc_dbd_id,
         pkg_phy_populate_data.gvc_process_id
 from gthul_gmr_treatment_header_ul gthul,
         axs_action_summary            axs
   where axs.process = gvc_process
     and gthul.internal_action_ref_no = axs.internal_action_ref_no
     and axs.eff_date <= pd_trade_date
     and axs.corporate_id = pc_corporate_id
     and gthul.process = gvc_process
   group by gthul.gth_id;
commit;      
end;
procedure sp_phy_create_grh_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
is 
begin 
insert into grh_gmr_refining_header
  (grh_id,
   internal_gmr_ref_no,
   pcdi_id,
   pcrh_id,
   is_active,
   internal_action_ref_no,
   dbd_id,
   process_id)
  select grhul.grh_id,
         substr(max(case
                      when grhul.internal_gmr_ref_no is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       grhul.internal_gmr_ref_no
                    end),
                24) internal_gmr_ref_no,
         substr(max(case
                      when grhul.pcdi_id is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       grhul.pcdi_id
                    end),
                24) pcdi_id,
         substr(max(case
                      when grhul.pcrh_id is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       grhul.pcrh_id
                    end),
                24) pcth_id,
         substr(max(case
                      when grhul.is_active is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       grhul.is_active
                    end),
                24) is_active,
         substr(max(case
                      when grhul.internal_action_ref_no is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       grhul.internal_action_ref_no
                    end),
                24) internal_action_ref_no,
         gvc_dbd_id,
         pkg_phy_populate_data.gvc_process_id
 from grhul_gmr_refining_header_ul grhul,
         axs_action_summary            axs
   where axs.process = gvc_process
     and grhul.internal_action_ref_no = axs.internal_action_ref_no
     and axs.eff_date <= pd_trade_date
     and axs.corporate_id = pc_corporate_id
     and grhul.process = gvc_process
   group by grhul.grh_id;
   commit;
end;
procedure sp_phy_create_gph_data(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_user_id      varchar2)
is 
begin 
insert into gph_gmr_penalty_header
  (gph_id,
   internal_gmr_ref_no,
   pcdi_id,
   pcaph_id,
   is_active,
   internal_action_ref_no,
   dbd_id,
   process_id)
  select gphul.gph_id,
         substr(max(case
                      when gphul.internal_gmr_ref_no is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gphul.internal_gmr_ref_no
                    end),
                24) internal_gmr_ref_no,
         substr(max(case
                      when gphul.pcdi_id is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gphul.pcdi_id
                    end),
                24) pcdi_id,
         substr(max(case
                      when gphul.pcaph_id is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gphul.pcaph_id
                    end),
                24) pcaph_id,
         substr(max(case
                      when gphul.is_active is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gphul.is_active
                    end),
                24) is_active,
         substr(max(case
                      when gphul.internal_action_ref_no is not null then
                       to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                       gphul.internal_action_ref_no
                    end),
                24) internal_action_ref_no,
         gvc_dbd_id,
         pkg_phy_populate_data.gvc_process_id
 from gphul_gmr_penalty_header_ul gphul,
         axs_action_summary            axs
   where axs.process = gvc_process
     and gphul.internal_action_ref_no = axs.internal_action_ref_no
     and axs.eff_date <= pd_trade_date
     and axs.corporate_id = pc_corporate_id
     and gphul.process = gvc_process
   group by gphul.gph_id;
end;
end pkg_phy_populate_data; 
/
