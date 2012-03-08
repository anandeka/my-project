create or replace package pkg_phy_bm_washout_pnl is

  procedure sp_calc_washout_realized_today(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2,
                                           pc_process      varchar2);
  procedure sp_washout_reverse_realized(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_dbd_id       varchar2,
                                        pc_process      varchar2);
  procedure sp_washout_realize_pnl_change(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process      varchar2,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2);

end;
/
create or replace package body pkg_phy_bm_washout_pnl is

  procedure sp_calc_washout_realized_today(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2,
                                           pc_process      varchar2) is
    cursor cur_realized is
    
    --------for sales contract Washouts 
      select pc_process_id process_id,
             akc.corporate_id,
             akc.corporate_name,
             pcm.internal_contract_ref_no,
             pcm.contract_ref_no,
             pci.internal_contract_item_ref_no,
             pci.del_distribution_item_no,
             pcm.issue_date,
             pcm.purchase_sales contract_type,
             pcm.contract_status,
             axs.action_ref_no int_alloc_group_id,
             '' alloc_group_name,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             dgrd.internal_dgrd_ref_no internal_grd_ref_no,
             dgrd.internal_stock_ref_no,
             pdm.product_id,
             pdm.product_desc,
             orm.origin_id,
             orm.origin_name,
             qat.quality_id,
             qat.quality_name,
             cpc.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             phd_cp.profileid cp_profile_id,
             phd_cp.company_long_name1 cp_name,
             gab.gabid trade_user_id,
             gab.firstname || ' ' || gab.lastname trade_user_name,
             pt.price_type_id price_type_id,
             pt.price_type_name price_type_name,
             itm.incoterm_id,
             itm.incoterm,
             pym.payment_term_id,
             pym.payment_term,
             '' price_fixation_details,
             'Fixed' price_fixation_status,
             'Realized Today' realized_type,
             sswh.settlement_date realized_date,
             dgrd.container_no,
             dgrd.current_qty item_qty,
             dgrd.net_weight_unit_id qty_unit_id,
             qum_dgrd.qty_unit,
             sswd.price contract_price, ---cipd.contract_price,
             sswd.price_unit_id,
             vppu.cur_id price_unit_cur_id,
             cm_pric.cur_code price_unit_cur_code,
             vppu.weight_unit_id price_unit_weight_unit_id,
             qum_pric.qty_unit price_unit_weight_unit,
             vppu.weight price_unit_weight,
             phd_wh.profileid warehouse_id,
             phd_wh.companyname warehouse_name,
             cim_sld.city_id shed_id,
             cim_sld.city_name shed_name,
             gcd.groupid group_id,
             gcd.groupname group_name,
             cm_gcd.cur_id group_cur_id,
             cm_gcd.cur_code group_cur_code,
             qum_gcd.qty_unit_id group_qty_unit_id,
             qum_gcd.qty_unit group_qty_unit,
             qum_pdm.qty_unit_id base_qty_unit_id,
             qum_pdm.qty_unit base_qty_unit,
             akc.base_cur_id,
             akc.base_currency_name base_cur_code,
             cpc.profit_center_id sales_profit_center_id,
             cpc.profit_center_name sales_profit_center_name,
             cpc.profit_center_short_name sales_profit_center_short_name,
             css.strategy_id as sales_strategy_id,
             css.strategy_name as sales_strategy_name,
             blm.business_line_id as sales_business_line_id,
             blm.business_line_name as sales_business_line_name,
             gmr.internal_gmr_ref_no sales_internal_gmr_ref_no,
             pcm.contract_ref_no sales_contract_ref_no,
             case
               when itm.location_field = 'ORIGINATION' then
                pcdb.country_id
             end origination_city_id,
             case
               when itm.location_field = 'ORIGINATION' then
                cim_pcdb.city_name
             end origination_city_name,
             case
               when itm.location_field = 'ORIGINATION' then
                cym_pcdb.country_id
             end origination_country_id,
             case
               when itm.location_field = 'ORIGINATION' then
                cym_pcdb.country_name
             end origination_country_name,
             case
               when itm.location_field = 'DESTINATION' then
                pcdb.country_id
             end destination_country_id,
             case
               when itm.location_field = 'DESTINATION' then
                cym_pcdb.country_name
             end destination_country_name,
             case
               when itm.location_field = 'DESTINATION' then
                cim_pcdb.city_id
             end destination_city_id,
             case
               when itm.location_field = 'DESTINATION' then
                cim_pcdb.city_name
             end destination_city_name,
             null pool_id, -- get from dgrd -- check
             css.strategy_id,
             css.strategy_name,
             blm.business_line_id,
             blm.business_line_name,
             dgrd.bl_number,
             dgrd.bl_date,
             dgrd.seal_no,
             dgrd.mark_no,
             dgrd.warehouse_ref_no,
             dgrd.warehouse_receipt_no,
             dgrd.warehouse_receipt_date,
             dgrd.is_warrant is_warrant,
             dgrd.warrant_no warrant_no,
             pcdi.pcdi_id,
             null supp_contract_item_ref_no, -- get from dgrd
             null supplier_pcdi_id, -- get from dgrd
             null payable_returnable_type, -- get from dgrd
             nvl(gscs.avg_cost_fw_rate, 0) secondary_cost_per_unit,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             null cog_product_premium_per_unit,
             null cog_quality_premium_per_unit,
             pci.price_description,
             pcdi.delivery_item_no,
             cm_ppu.cur_id del_premium_cur_id,
             cm_ppu.cur_code del_premium_cur_code,
             nvl(ppu_prm.weight, 1) del_premium_weight,
             ppu_prm.weight_unit_id del_premium_weight_unit_id,
             pcdi.payment_due_date,
             null contract_qp_fw_exch_rate,
             null contract_pp_fw_exch_rate,
             null accrual_to_base_fw_exch_rate,
             gscs.fw_rate_string sales_sc_exch_rate_string,
             null price_to_base_fw_exch_rate_act,
             null price_to_base_fw_exch_rate
        from sswh_spe_settle_washout_header     sswh,
             sswd_spe_settle_washout_detail     sswd,
             dgrd_delivered_grd                 dgrd,
             gmr_goods_movement_record          gmr,
             pci_physical_contract_item         pci,
             pcdi_pc_delivery_item              pcdi,
             pcm_physical_contract_main         pcm,
             ak_corporate                       akc,
             axs_action_summary                 axs,
             pcpd_pc_product_definition         pcpd,
             pdm_productmaster                  pdm,
             pcpq_pc_product_quality            pcpq,
             qat_quality_attributes             qat,
             pom_product_origin_master          pom,
             orm_origin_master                  orm,
             cpc_corporate_profit_center        cpc,
             phd_profileheaderdetails           phd_cp,
             ak_corporate_user                  akcu,
             gab_globaladdressbook              gab,
             pcdb_pc_delivery_basis             pcdb,
             itm_incoterm_master                itm,
             pym_payment_terms_master           pym,
             v_ppu_pum                          vppu,
             qum_quantity_unit_master           qum_dgrd,
             phd_profileheaderdetails           phd_wh,
             gcd_groupcorporatedetails          gcd,
             cm_currency_master                 cm_gcd,
             sld_storage_location_detail        sld,
             cim_citymaster                     cim_sld,
             cm_currency_master                 cm_pric,
             qum_quantity_unit_master           qum_pric,
             qum_quantity_unit_master           qum_gcd,
             qum_quantity_unit_master           qum_pdm,
             css_corporate_strategy_setup       css,
             blm_business_line_master@eka_appdb blm,
             cym_countrymaster                  cym_pcdb,
             cim_citymaster                     cim_pcdb,
             pt_price_type                      pt,
             v_ppu_pum                          ppu_prm,
             gscs_gmr_sec_cost_summary          gscs,
             cm_currency_master                 cm_ppu
       where sswd.sswh_id = sswh.sswh_id
         and sswh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and sswd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.pcdi_id = pcdi.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.corporate_id = akc.corporate_id
         and sswh.internal_action_ref_no = axs.internal_action_ref_no
         and sswh.dbd_id = axs.dbd_id
         and sswd.process_id = sswh.process_id
         and sswh.process_id = pc_process_id
         and sswh.is_active = 'Y'
         and sswh.process_id = gmr.process_id
         and sswd.process_id = pci.process_id
         and sswd.process_id = pcdi.process_id
         and sswd.process_id = pcm.process_id
         and sswd.contract_type = 'S'
         and pcm.contract_type = 'BASEMETAL'
         and gmr.is_deleted = 'N'
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and sswh.process_id = pcdb.process_id
         and sswd.process_id = pcpd.process_id
         and pcpd.is_active = 'Y'
         and pcpd.product_id = pdm.product_id
         and pcpd.pcpd_id = pcpq.pcpd_id
         and sswd.process_id = pcpq.process_id
         and pcpq.quality_template_id = qat.quality_id
         and pcpq.is_active = 'Y'
         and qat.product_origin_id = pom.product_origin_id(+)
         and pom.origin_id = orm.origin_id(+)
         and pcpd.profit_center_id = cpc.profit_center_id
         and pcm.cp_id = phd_cp.profileid
         and pcm.trader_id = akcu.user_id
         and akcu.gabid = gab.gabid
         and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
         and pcdb.inco_term_id = itm.incoterm_id
         and pcdi.item_price_type = pt.price_type_id(+)
         and pcm.payment_term_id = pym.payment_term_id
         and sswd.price_unit_id = vppu.product_price_unit_id
         and vppu.cur_id = cm_pric.cur_id
         and vppu.weight_unit_id = qum_pric.qty_unit_id
         and dgrd.net_weight_unit_id = qum_dgrd.qty_unit_id
         and dgrd.warehouse_profile_id = phd_wh.profileid(+)
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id
         and dgrd.shed_id = sld.storage_loc_id(+)
         and sld.city_id = cim_sld.city_id(+)
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
         and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         and pcpd.strategy_id = css.strategy_id
         and cpc.business_line_id = blm.business_line_id
         and pcdb.country_id = cym_pcdb.country_id
         and pcdb.city_id = cim_pcdb.city_id
         and ppu_prm.product_price_unit_id(+) = pcdb.premium_unit_id
         and dgrd.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
         and dgrd.process_id = gscs.process_id(+)
         and ppu_prm.cur_id = cm_ppu.cur_id(+)
      
      union all
      --------For purchase contract Washouts
      select pc_process_id process_id,
             akc.corporate_id corporate_id,
             akc.corporate_name corporate_name,
             pcm.internal_contract_ref_no internal_contract_ref_no,
             pcm.contract_ref_no contract_ref_no,
             pci.internal_contract_item_ref_no internal_contract_item_ref_no,
             pci.del_distribution_item_no del_distribution_item_no,
             pcm.issue_date issue_date,
             pcm.purchase_sales purchase_sales,
             pcm.contract_status contract_status,
             axs.action_ref_no int_alloc_group_id,
             null alloc_group_name,
             gmr.internal_gmr_ref_no internal_gmr_ref_no,
             gmr.gmr_ref_no gmr_ref_no,
             grd.internal_grd_ref_no internal_grd_ref_no,
             grd.internal_stock_ref_no internal_stock_ref_no,
             pdm.product_id product_id,
             pdm.product_desc product_desc,
             orm.origin_id origin_id,
             orm.origin_name origin_name,
             qat.quality_id quality_id,
             qat.quality_name quality_name,
             cpc.profit_center_id profit_center_id,
             cpc.profit_center_name profit_center_name,
             cpc.profit_center_short_name profit_center_short_name,
             phd_cp.profileid cp_profile_id,
             phd_cp.companyname cp_name,
             gab.gabid trade_user_id,
             gab.firstname || ' ' || gab.lastname trade_user_name,
             pt.price_type_id price_type_id,
             pt.price_type_name price_type_name,
             itm.incoterm_id incoterm_id,
             itm.incoterm incoterm,
             pym.payment_term_id payment_term_id,
             pym.payment_term payment_term,
             null price_fixation_details,
             null price_fixation_status,
             'Realized Today' realized_type,
             sswh.settlement_date realized_date,
             grd.container_no container_no,
             grd.qty item_qty,
             vppu.weight_unit_id qty_unit_id,
             qum_pric.qty_unit qty_unit,
             sswd.price contract_price,
             sswd.price_unit_id price_unit_id,
             vppu.cur_id price_unit_cur_id,
             cm_pric.cur_code price_unit_cur_code,
             qum_pric.qty_unit_id price_unit_weight_unit_id,
             qum_pric.qty_unit price_unit_weight_unit,
             vppu.weight price_unit_weight,
             phd_wh.profileid warehouse_id,
             phd_wh.companyname warehouse_name,
             cim_sld.city_id shed_id,
             cim_sld.city_name shed_name,
             gcd.groupid group_id,
             gcd.groupname group_name,
             cm_gcd.cur_id group_cur_id,
             cm_gcd.cur_code group_cur_code,
             qum_gcd.qty_unit_id group_qty_unit_id,
             qum_gcd.qty_unit group_qty_unit,
             qum_pdm.qty_unit_id base_qty_unit_id,
             qum_pdm.qty_unit base_qty_unit,
             akc.base_cur_id base_cur_id,
             akc.base_currency_name base_cur_code,
             null sales_profit_center_id,
             null sales_profit_center_name,
             null sales_profit_center_short_name,
             null sales_strategy_id,
             null sales_strategy_name,
             null sales_business_line_id,
             null sales_business_line_name,
             dgrd.internal_gmr_ref_no sales_internal_gmr_ref_no,
             pcm_sales.contract_ref_no sales_contract_ref_no,
             null origination_city_id,
             null origination_city_name,
             null origination_country_id,
             null origination_country_name,
             cym_gmr_dest.country_id destination_country_id,
             cym_gmr_dest.country_name destination_country,
             cim_gmr_dest.city_id destination_city_id,
             cim_gmr_dest.city_name destination_city,
             null pool_id, -- get from grd
             grd.status strategy_id,
             css.strategy_name strategy_name,
             null business_line_id, -- get from grd
             null business_line_name, -- get from grd
             grd.bl_number bl_number,
             grd.bl_date bl_date,
             grd.seal_no seal_no,
             grd.mark_no mark_no,
             grd.warehouse_ref_no warehouse_ref_no,
             grd.warehouse_receipt_no warehouse_receipt_no,
             grd.warehouse_receipt_date warehouse_receipt_date,
             grd.is_warrant is_warrant,
             grd.warrant_no warrant_no,
             grd.pcdi_id pcdi_id,
             grd.supp_contract_item_ref_no supp_contract_item_ref_no,
             grd.supplier_pcdi_id supplier_pcdi_id,
             grd.payable_returnable_type payable_returnable_type,
             null secondary_cost_per_unit,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             null cog_product_premium_per_unit,
             null cog_quality_premium_per_unit,
             pci.price_description,
             pcdi.delivery_item_no,
             null del_premium_cur_id,
             null del_premium_cur_code,
             null del_premium_weight,
             null del_premium_weight_unit_id,
             pcdi.payment_due_date,
             --pd_trade_date payment_due_date,
             null contract_qp_fw_exch_rate,
             null contract_pp_fw_exch_rate,
             null accrual_to_base_fw_exch_rate,
             null sales_sc_exch_rate_string,
             null price_to_base_fw_exch_rate_act,
             null price_to_base_fw_exch_rate
        from sswh_spe_settle_washout_header sswh,
             sswd_spe_settle_washout_detail sswd,
             sswd_spe_settle_washout_detail sswd_sales,
             grd_goods_record_detail        grd,
             pci_physical_contract_item     pci,
             pcdi_pc_delivery_item          pcdi,
             pcm_physical_contract_main     pcm,
             ak_corporate                   akc,
             axs_action_summary             axs,
             gmr_goods_movement_record      gmr,
             pdm_productmaster              pdm,
             qat_quality_attributes         qat,
             pom_product_origin_master      pom,
             orm_origin_master              orm,
             pcpd_pc_product_definition     pcpd,
             cpc_corporate_profit_center    cpc,
             phd_profileheaderdetails       phd_cp,
             ak_corporate_user              akcu,
             gab_globaladdressbook          gab,
             pcdb_pc_delivery_basis         pcdb,
             itm_incoterm_master            itm,
             pym_payment_terms_master       pym,
             v_ppu_pum                      vppu,
             qum_quantity_unit_master       qum_pric,
             phd_profileheaderdetails       phd_wh,
             sld_storage_location_detail    sld,
             cim_citymaster                 cim_sld,
             gcd_groupcorporatedetails      gcd,
             cm_currency_master             cm_gcd,
             cm_currency_master             cm_pric,
             qum_quantity_unit_master       qum_gcd,
             qum_quantity_unit_master       qum_pdm,
             cym_countrymaster              cym_gmr_dest,
             cim_citymaster                 cim_gmr_dest,
             dgrd_delivered_grd             dgrd,
             pci_physical_contract_item     pci_sales,
             pcdi_pc_delivery_item          pcdi_sales,
             pcm_physical_contract_main     pcm_sales,
             pt_price_type                  pt,
             css_corporate_strategy_setup   css
       where sswd.process_id = pc_process_id
         and sswh.process_id = sswd.process_id
         and sswd_sales.process_id = sswh.process_id
         and sswd.sswh_id = sswh.sswh_id
         and sswd_sales.sswh_id = sswh.sswh_id
         and sswd.contract_type = 'P'
         and sswd_sales.contract_type = 'S'
         and sswh.is_active = 'Y'
         and sswh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and sswd.process_id = grd.process_id
         and grd.is_deleted = 'N'
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and sswd.process_id = pci.process_id
         and pci.is_active = 'Y'
         and pci.pcdi_id = pcdi.pcdi_id
         and sswd.process_id = pcdi.process_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and sswd.process_id = pcm.process_id
         and pcdi.is_active = 'Y'
         and pcm.contract_status in ('In Position', 'Pending Approval')
         and pcm.contract_type = 'BASEMETAL'
         and pcm.corporate_id = akc.corporate_id
         and sswh.internal_action_ref_no = axs.internal_action_ref_no
         and sswh.dbd_id = axs.dbd_id
         and sswd.price_unit_id = vppu.product_price_unit_id
         and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and sswh.process_id = gmr.process_id
         and gmr.is_deleted = 'N'
         and grd.product_id = pdm.product_id
         and grd.quality_id = qat.quality_id
         and qat.product_origin_id = pom.product_origin_id(+)
         and pom.origin_id = orm.origin_id(+)
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and sswh.process_id = pcpd.process_id
         and pcpd.profit_center_id = cpc.profit_center_id
         and pcm.cp_id = phd_cp.profileid
         and pcm.trader_id = akcu.user_id
         and akcu.gabid = gab.gabid
         and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
         and sswh.process_id = pcdb.process_id
         and pci.pcdb_id = pcdb.pcdb_id
         and pcdb.is_active = 'Y'
         and pcdb.inco_term_id = itm.incoterm_id
         and pcm.payment_term_id = pym.payment_term_id
         and vppu.weight_unit_id = qum_pric.qty_unit_id
         and vppu.cur_id = cm_pric.cur_id
         and grd.warehouse_profile_id = phd_wh.profileid(+)
         and grd.shed_id = sld.storage_loc_id(+)
         and sld.city_id = cim_sld.city_id(+)
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id
         and gmr.destination_country_id = cym_gmr_dest.country_id(+)
         and gmr.destination_city_id = cim_gmr_dest.city_id(+)
         and sswh.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
         and dgrd.process_id = sswh.process_id
         and dgrd.status = 'Active'
         and case when sswd_sales.contract_type = 'S' then sswd_sales.internal_contract_item_ref_no end = pci_sales.internal_contract_item_ref_no and pci_sales.process_id = sswd_sales.process_id and pci_sales.pcdi_id = pcdi_sales.pcdi_id and pcdi_sales.internal_contract_ref_no = pcm_sales.internal_contract_ref_no and pcdi_sales.process_id = sswd_sales.process_id and pcm_sales.process_id = sswd_sales.process_id and pcdi.item_price_type = pt.price_type_id(+) and grd.strategy_id = css.strategy_id(+);
  
    ---------
  
    cursor cur_update_pnl is
      select prd.corporate_id,
             prd.sales_internal_gmr_ref_no,
             prd.process_id,
             prd.int_alloc_group_id,
             nvl(sum(prd.cog_net_sale_value), 0) net_value
        from prd_physical_realized_daily prd
       where prd.process_id = pc_process_id
         and prd.corporate_id = pc_corporate_id
         and prd.realized_type = 'Realized Today'
       group by prd.corporate_id,
                prd.sales_internal_gmr_ref_no,
                prd.process_id,
                prd.int_alloc_group_id;
  
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vc_error_msg                   varchar2(10);
    vn_qty_in_base_qty_unit_id     number;
    vn_sc_in_base_cur              number;
    vc_base_price_unit_id          varchar2(15);
    vc_base_price_unit_name        varchar2(15);
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_cog_net_sale_value          number;
    vn_contract_value_in_base_cur  number;
    vn_contract_value_in_price_cur number;
    vn_cfx_price_cur_to_base_cur   number;
    vc_contract_price_unit_id      varchar2(15);
    vn_forward_points              number;
    vn_price_to_base_fw_exch_rate  number;
    vc_price_to_base_fw_rate       varchar2(100);
    vc_sc_to_base_fw_exch_rate     varchar2(500);
  
  begin
    vc_error_msg := '1';
    for cur_realized_rows in cur_realized
    loop
      if cur_realized_rows.contract_type = 'S' then
        vc_sc_to_base_fw_exch_rate := cur_realized_rows.accrual_to_base_fw_exch_rate;
      else
        vc_sc_to_base_fw_exch_rate := cur_realized_rows.sales_sc_exch_rate_string;
      end if;
      begin
        select ppu.product_price_unit_id,
               ppu.price_unit_name
          into vc_base_price_unit_id,
               vc_base_price_unit_name
          from v_ppu_pum ppu
         where ppu.cur_id = cur_realized_rows.base_cur_id
           and ppu.weight_unit_id = cur_realized_rows.base_qty_unit_id
           and nvl(ppu.weight, 1) = 1
           and ppu.product_id = cur_realized_rows.product_id;
      exception
        when others then
          sp_write_log(pc_corporate_id,
                       pd_trade_date,
                       'sp_calc_realized_today',
                       'vc_base_price_unit is not available' || ' For' ||
                       cur_realized_rows.contract_ref_no);
      end;
      --
      -- Pricing Main Currency Details
      --
    
      pkg_general.sp_get_main_cur_detail(cur_realized_rows.price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
    
      --
      -- Quantity in Product Base Unit
      --
      if cur_realized_rows.qty_unit_id <>
         cur_realized_rows.base_qty_unit_id then
        select pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                    cur_realized_rows.qty_unit_id,
                                                    cur_realized_rows.base_qty_unit_id,
                                                    cur_realized_rows.item_qty)
          into vn_qty_in_base_qty_unit_id
          from dual;
      else
        vn_qty_in_base_qty_unit_id := cur_realized_rows.item_qty;
      end if;
    
      vc_error_msg              := '6';
      vc_contract_price_unit_id := cur_realized_rows.price_unit_id;
      --
      -- Contract Value in Price Currency
      -- 
      vn_contract_value_in_price_cur := (cur_realized_rows.contract_price /
                                        nvl(cur_realized_rows.price_unit_weight,
                                             1)) *
                                        vn_cont_price_cur_id_factor *
                                        pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                             cur_realized_rows.qty_unit_id,
                                                                             cur_realized_rows.base_qty_unit_id,
                                                                             cur_realized_rows.item_qty);
      --
      -- Get the Contract Value in Base Currency
      --
      vc_error_msg := '7';
      pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                              pd_trade_date,
                                              cur_realized_rows.payment_due_date,
                                              vc_price_cur_id,
                                              cur_realized_rows.base_cur_id,
                                              30,
                                              vn_price_to_base_fw_exch_rate,
                                              vn_forward_points);
    
      if vc_price_cur_id <> cur_realized_rows.base_cur_id then
        if vn_price_to_base_fw_exch_rate is null or
           vn_price_to_base_fw_exch_rate = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process-sp_calc_washout_open_unrealized ',
                                                               'PHY-005',
                                                               cur_realized_rows.base_cur_code ||
                                                               ' to ' ||
                                                               vc_price_cur_code || ' (' ||
                                                               to_char(pd_trade_date,
                                                                       'dd-Mon-yyyy') || ') ',
                                                               '',
                                                               pc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        end if;
      end if;
    
      if vn_price_to_base_fw_exch_rate is not null and
         vn_price_to_base_fw_exch_rate <> 1 then
        vc_price_to_base_fw_rate := '1 ' || vc_price_cur_code || '=' ||
                                    vn_price_to_base_fw_exch_rate || ' ' ||
                                    cur_realized_rows.base_cur_code;
      end if;
      vn_contract_value_in_base_cur := (cur_realized_rows.contract_price /
                                       nvl(cur_realized_rows.price_unit_weight,
                                            1)) *
                                       vn_cont_price_cur_id_factor *
                                       vn_price_to_base_fw_exch_rate *
                                       pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                            cur_realized_rows.qty_unit_id,
                                                                            cur_realized_rows.base_qty_unit_id,
                                                                            cur_realized_rows.item_qty);
    
      vc_error_msg := '8';
      --
      -- Total COG or Sale Value = Contract Value (Qty * Price)  (+ for Purchase Contracts and - for Sales Contracts)
      --
      vn_cog_net_sale_value := vn_contract_value_in_base_cur;
    
      if cur_realized_rows.contract_type = 'P' then
        vn_cog_net_sale_value := -1 * (vn_cog_net_sale_value +
                                 abs(nvl(vn_sc_in_base_cur, 0)));
      else
        vn_cog_net_sale_value := vn_cog_net_sale_value -
                                 abs(nvl(vn_sc_in_base_cur, 0));
      end if;
      vc_error_msg := '9';
      insert into prd_physical_realized_daily
        (process_id,
         trade_date,
         corporate_id,
         corporate_name,
         internal_contract_ref_no,
         contract_ref_no,
         internal_contract_item_ref_no,
         del_distribution_item_no,
         contract_issue_date,
         contract_type,
         contract_status,
         int_alloc_group_id,
         alloc_group_name,
         internal_gmr_ref_no,
         gmr_ref_no,
         internal_grd_ref_no,
         internal_stock_ref_no,
         product_id,
         product_name,
         origin_id,
         origin_name,
         quality_id,
         quality_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         cp_profile_id,
         cp_name,
         trade_user_id,
         trade_user_name,
         price_type_id,
         price_type_name,
         incoterm_id,
         incoterm,
         payment_term_id,
         payment_term,
         price_fixation_details,
         price_fixation_status,
         realized_type,
         realized_date,
         container_no,
         item_qty,
         qty_unit_id,
         qty_unit,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         price_unit_weight,
         contract_value_in_price_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         contract_invoice_value,
         secondary_cost_per_unit,
         secondary_cost_value,
         cog_net_sale_value,
         realized_pnl,
         cfx_price_cur_to_base_cur,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         group_id,
         group_name,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         item_qty_in_base_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         base_cur_id,
         base_cur_code,
         sales_profit_center_id,
         sales_profit_center_name,
         sales_profit_center_short_name,
         sales_strategy_id,
         sales_strategy_name,
         sales_business_line_id,
         sales_business_line_name,
         sales_internal_gmr_ref_no,
         sales_contract_ref_no,
         origination_city_id,
         origination_city_name,
         origination_country_id,
         origination_country_name,
         destination_city_id,
         destination_city_name,
         destination_country_id,
         destination_country_name,
         pool_id,
         strategy_id,
         strategy_name,
         business_line_id,
         business_line_name,
         bl_number,
         bl_date,
         seal_no,
         mark_no,
         warehouse_ref_no,
         warehouse_receipt_no,
         warehouse_receipt_date,
         is_warrant,
         warrant_no,
         pcdi_id,
         supp_contract_item_ref_no,
         supplier_pcdi_id,
         payable_returnable_type,
         quality_premium,
         quality_premium_per_unit,
         product_premium,
         product_premium_per_unit,
         base_price_unit_id,
         base_price_unit_name,
         price_description,
         delivery_item_no,
         price_to_base_fw_exch_rate,
         contract_qp_fw_exch_rate,
         contract_pp_fw_exch_rate,
         accrual_to_base_fw_exch_rate,
         realized_sub_type)
      values
        (pc_process_id,
         pd_trade_date,
         cur_realized_rows.corporate_id,
         cur_realized_rows.corporate_name,
         cur_realized_rows.internal_contract_ref_no,
         cur_realized_rows.contract_ref_no,
         cur_realized_rows.internal_contract_item_ref_no,
         cur_realized_rows.del_distribution_item_no,
         cur_realized_rows.issue_date,
         cur_realized_rows.contract_type,
         cur_realized_rows.contract_status,
         cur_realized_rows.int_alloc_group_id,
         cur_realized_rows.alloc_group_name,
         cur_realized_rows.internal_gmr_ref_no,
         cur_realized_rows.gmr_ref_no,
         cur_realized_rows.internal_grd_ref_no,
         cur_realized_rows.internal_stock_ref_no,
         cur_realized_rows.product_id,
         cur_realized_rows.product_desc,
         cur_realized_rows.origin_id,
         cur_realized_rows.origin_name,
         cur_realized_rows.quality_id,
         cur_realized_rows.quality_name,
         cur_realized_rows.profit_center_id,
         cur_realized_rows.profit_center_name,
         cur_realized_rows.profit_center_short_name,
         cur_realized_rows.cp_profile_id,
         cur_realized_rows.cp_name,
         cur_realized_rows.trade_user_id,
         cur_realized_rows.trade_user_name,
         cur_realized_rows.price_type_id,
         cur_realized_rows.price_type_name,
         cur_realized_rows.incoterm_id,
         cur_realized_rows.incoterm,
         cur_realized_rows.payment_term_id,
         cur_realized_rows.payment_term,
         cur_realized_rows.price_fixation_details,
         cur_realized_rows.price_fixation_status,
         cur_realized_rows.realized_type,
         cur_realized_rows.realized_date,
         cur_realized_rows.container_no,
         cur_realized_rows.item_qty,
         cur_realized_rows.qty_unit_id,
         cur_realized_rows.qty_unit,
         cur_realized_rows.contract_price,
         vc_contract_price_unit_id,
         cur_realized_rows.price_unit_cur_id,
         cur_realized_rows.price_unit_cur_code,
         cur_realized_rows.price_unit_weight_unit_id,
         cur_realized_rows.price_unit_weight_unit,
         cur_realized_rows.price_unit_weight,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         cur_realized_rows.secondary_cost_per_unit,
         0,
         vn_cog_net_sale_value,
         null, -- Realized_pnl Updated Below
         vn_cfx_price_cur_to_base_cur,
         cur_realized_rows.warehouse_id,
         cur_realized_rows.warehouse_name,
         cur_realized_rows.shed_id,
         cur_realized_rows.shed_name,
         cur_realized_rows.group_id,
         cur_realized_rows.group_name,
         cur_realized_rows.group_cur_id,
         cur_realized_rows.group_cur_code,
         cur_realized_rows.group_qty_unit_id,
         cur_realized_rows.group_qty_unit,
         vn_qty_in_base_qty_unit_id,
         cur_realized_rows.base_qty_unit_id,
         cur_realized_rows.base_qty_unit,
         cur_realized_rows.base_cur_id,
         cur_realized_rows.base_cur_code,
         cur_realized_rows.sales_profit_center_id,
         cur_realized_rows.sales_profit_center_name,
         cur_realized_rows.sales_profit_center_short_name,
         cur_realized_rows.sales_strategy_id,
         cur_realized_rows.sales_strategy_name,
         cur_realized_rows.sales_business_line_id,
         cur_realized_rows.sales_business_line_name,
         cur_realized_rows.sales_internal_gmr_ref_no,
         cur_realized_rows.sales_contract_ref_no,
         cur_realized_rows.origination_city_id,
         cur_realized_rows.origination_city_name,
         cur_realized_rows.origination_country_id,
         cur_realized_rows.origination_country_name,
         cur_realized_rows.destination_city_id,
         cur_realized_rows.destination_city_name,
         cur_realized_rows.destination_country_id,
         cur_realized_rows.destination_country_name,
         cur_realized_rows.pool_id,
         cur_realized_rows.strategy_id,
         cur_realized_rows.strategy_name,
         cur_realized_rows.business_line_id,
         cur_realized_rows.business_line_name,
         cur_realized_rows.bl_number,
         cur_realized_rows.bl_date,
         cur_realized_rows.seal_no,
         cur_realized_rows.mark_no,
         cur_realized_rows.warehouse_ref_no,
         cur_realized_rows.warehouse_receipt_no,
         cur_realized_rows.warehouse_receipt_date,
         cur_realized_rows.is_warrant,
         cur_realized_rows.warrant_no,
         cur_realized_rows.pcdi_id,
         cur_realized_rows.supp_contract_item_ref_no,
         cur_realized_rows.supplier_pcdi_id,
         cur_realized_rows.payable_returnable_type,
         0,
         0,
         0,
         0,
         vc_base_price_unit_id,
         vc_base_price_unit_name,
         cur_realized_rows.price_description,
         cur_realized_rows.delivery_item_no,
         vc_price_to_base_fw_rate,
         null,
         null,
         null,
         'Washout');
    end loop;
    commit;
    vc_error_msg := '10';
    --
    -- Update Realized PNL for Sales Contract
    --
    for cur_update_pnl_rows in cur_update_pnl
    loop
      update prd_physical_realized_daily prd
         set prd.realized_pnl = cur_update_pnl_rows.net_value
       where prd.corporate_id = cur_update_pnl_rows.corporate_id
         and prd.contract_type = 'S'
         and prd.realized_type = 'Realized Today'
         and prd.sales_internal_gmr_ref_no =
             cur_update_pnl_rows.sales_internal_gmr_ref_no
         and prd.int_alloc_group_id =
             cur_update_pnl_rows.int_alloc_group_id
         and prd.process_id = pc_process_id
         and rownum < 2;
    end loop;
    vc_error_msg := '11';
    --
    -- Update Sales Profit Center, Strategy and Business Line For Purchase Contracts
    --
    for cur_update_cpc in (select prd.sales_internal_gmr_ref_no,
                                  prd.profit_center_id,
                                  prd.profit_center_short_name,
                                  prd.profit_center_name,
                                  prd.strategy_id,
                                  prd.strategy_name,
                                  prd.business_line_id,
                                  prd.business_line_name
                             from prd_physical_realized_daily prd
                            where prd.process_id = pc_process_id
                              and prd.contract_type = 'S')
    loop
      update prd_physical_realized_daily prd
         set prd.sales_profit_center_id         = cur_update_cpc.profit_center_id,
             prd.sales_profit_center_short_name = cur_update_cpc.profit_center_short_name,
             prd.sales_profit_center_name       = cur_update_cpc.profit_center_name,
             prd.sales_strategy_id              = cur_update_cpc.strategy_id,
             prd.sales_strategy_name            = cur_update_cpc.strategy_name,
             prd.sales_business_line_id         = cur_update_cpc.business_line_id,
             prd.sales_business_line_name       = cur_update_cpc.business_line_name
       where prd.contract_type = 'P'
         and prd.sales_internal_gmr_ref_no =
             cur_update_cpc.sales_internal_gmr_ref_no
         and prd.process_id = pc_process_id;
    end loop;
    commit;
    vc_error_msg := '12';
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process Realized Today',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace ||
                                                           'No ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  ------------------
  procedure sp_washout_reverse_realized(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process_id   varchar2,
                                        pc_user_id      varchar2,
                                        pc_dbd_id       varchar2,
                                        pc_process      varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_error_msg       varchar2(10);
  begin
  
    --  get it from dbd for trade date
    /*select
    dbd.start_date, dbd.end_date
     from dbd_database_dump dbd
    where dbd.trade_date = pd_trade_date
    and dbd.corporate_id = pc_corporate_id;
    */
  
    for cur_update in (select sswh.cancellation_date,
                              sswh.sswh_id
                         from sswh_spe_settle_washout_header@eka_appdb sswh,
                              dbd_database_dump                        dbd
                        where sswh.cancellation_date > dbd.start_date
                          and sswh.cancellation_date <= dbd.end_date
                          and dbd.dbd_id = pc_dbd_id)
    loop
      update sswh_spe_settle_washout_header sswh_in
         set sswh_in.cancelled_process_id = pc_process_id,
             sswh_in.cancellation_date    = cur_update.cancellation_date
       where sswh_in.sswh_id = cur_update.sswh_id;
    end loop;
  
    insert into prd_physical_realized_daily
      (process_id,
       trade_date,
       corporate_id,
       corporate_name,
       internal_contract_ref_no,
       contract_ref_no,
       internal_contract_item_ref_no,
       del_distribution_item_no,
       contract_issue_date,
       contract_type,
       contract_status,
       int_alloc_group_id,
       alloc_group_name,
       internal_gmr_ref_no,
       gmr_ref_no,
       internal_grd_ref_no,
       internal_stock_ref_no,
       product_id,
       product_name,
       origin_id,
       origin_name,
       quality_id,
       quality_name,
       profit_center_id,
       profit_center_name,
       profit_center_short_name,
       cp_profile_id,
       cp_name,
       trade_user_id,
       trade_user_name,
       price_type_id,
       price_type_name,
       incoterm_id,
       incoterm,
       payment_term_id,
       payment_term,
       price_fixation_details,
       price_fixation_status,
       realized_type,
       realized_date,
       container_no,
       item_qty,
       qty_unit_id,
       qty_unit,
       contract_price,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       price_unit_weight_unit_id,
       price_unit_weight_unit,
       price_unit_weight,
       contract_value_in_price_cur,
       contract_price_cur_id,
       contract_price_cur_code,
       contract_invoice_value,
       secondary_cost_per_unit,
       product_premium_per_unit,
       product_premium,
       quality_premium_per_unit,
       quality_premium,
       secondary_cost_value,
       cog_net_sale_value,
       realized_pnl,
       prev_real_price,
       prev_real_price_id,
       prev_real_price_cur_id,
       prev_real_price_cur_code,
       prev_real_price_weight_unit_id,
       prev_real_price_weight_unit,
       prev_real_price_weight,
       prev_real_qty,
       prev_real_qty_id,
       prev_real_qty_unit,
       prev_cont_value_in_price_cur,
       prev_contract_price_cur_id,
       prev_contract_price_cur_code,
       prev_real_contract_value,
       prev_real_secondary_cost,
       prev_real_cog_net_sale_value,
       prev_real_pnl,
       prev_product_premium_per_unit,
       prev_product_premium,
       prev_quality_premium_per_unit,
       prev_quality_premium,
       prev_secondary_cost_per_unit,
       change_in_pnl,
       cfx_price_cur_to_base_cur,
       warehouse_id,
       warehouse_name,
       shed_id,
       shed_name,
       group_id,
       group_name,
       group_cur_id,
       group_cur_code,
       group_qty_unit_id,
       group_qty_unit,
       item_qty_in_base_qty_unit,
       base_qty_unit_id,
       base_qty_unit,
       base_cur_id,
       base_cur_code,
       base_price_unit_id,
       base_price_unit_name,
       sales_profit_center_id,
       sales_profit_center_name,
       sales_profit_center_short_name,
       sales_internal_gmr_ref_no,
       sales_contract_ref_no,
       origination_city_id,
       origination_city_name,
       origination_country_id,
       origination_country_name,
       destination_city_id,
       destination_city_name,
       destination_country_id,
       destination_country_name,
       pool_id,
       strategy_id,
       strategy_name,
       business_line_id,
       business_line_name,
       bl_number,
       bl_date,
       seal_no,
       mark_no,
       warehouse_ref_no,
       warehouse_receipt_no,
       warehouse_receipt_date,
       is_warrant,
       warrant_no,
       pcdi_id,
       supp_contract_item_ref_no,
       supplier_pcdi_id,
       payable_returnable_type,
       delivery_item_no,
       realized_sub_type,
       price_description)
      select pc_process_id,
             pd_trade_date,
             prd.corporate_id,
             prd.corporate_name,
             prd.internal_contract_ref_no,
             prd.contract_ref_no,
             prd.internal_contract_item_ref_no,
             prd.del_distribution_item_no,
             prd.contract_issue_date,
             prd.contract_type,
             prd.contract_status,
             prd.int_alloc_group_id,
             prd.alloc_group_name,
             prd.internal_gmr_ref_no,
             prd.gmr_ref_no,
             prd.internal_grd_ref_no,
             prd.internal_stock_ref_no,
             prd.product_id,
             prd.product_name,
             prd.origin_id,
             prd.origin_name,
             prd.quality_id,
             prd.quality_name,
             prd.profit_center_id,
             prd.profit_center_name,
             prd.profit_center_short_name,
             prd.cp_profile_id,
             prd.cp_name,
             prd.trade_user_id,
             prd.trade_user_name,
             prd.price_type_id,
             prd.price_type_name,
             prd.incoterm_id,
             prd.incoterm,
             prd.payment_term_id,
             prd.payment_term,
             prd.price_fixation_details,
             prd.price_fixation_status,
             'Reverse Realized',
             prd.realized_date,
             prd.container_no,
             prd.item_qty,
             prd.qty_unit_id,
             prd.qty_unit,
             prd.contract_price,
             prd.price_unit_id,
             prd.price_unit_cur_id,
             prd.price_unit_cur_code,
             prd.price_unit_weight_unit_id,
             prd.price_unit_weight_unit,
             prd.price_unit_weight,
             prd.contract_value_in_price_cur,
             prd.contract_price_cur_id,
             prd.contract_price_cur_code,
             -1 * prd.contract_invoice_value,
             prd.secondary_cost_per_unit,
             prd.product_premium_per_unit,
             prd.product_premium,
             prd.quality_premium_per_unit,
             prd.quality_premium,
             0,
             -1 * prd.cog_net_sale_value,
             -1 * prd.realized_pnl,
             prd.prev_real_price,
             prd.prev_real_price_id,
             prd.prev_real_price_cur_id,
             prd.prev_real_price_cur_code,
             prd.prev_real_price_weight_unit_id,
             prd.prev_real_price_weight_unit,
             prd.prev_real_price_weight,
             prd.prev_real_qty,
             prd.prev_real_qty_id,
             prd.prev_real_qty_unit,
             prev_cont_value_in_price_cur,
             prd.prev_contract_price_cur_id,
             prd.prev_contract_price_cur_code,
             prd.prev_real_contract_value,
             prd.prev_real_secondary_cost,
             prd.prev_real_cog_net_sale_value,
             prd.prev_real_pnl,
             prd.prev_product_premium_per_unit,
             prd.prev_product_premium,
             prd.prev_quality_premium_per_unit,
             prd.prev_quality_premium,
             prd.prev_secondary_cost_per_unit,
             prd.change_in_pnl,
             prd.cfx_price_cur_to_base_cur,
             prd.warehouse_id,
             prd.warehouse_name,
             prd.shed_id,
             prd.shed_name,
             prd.group_id,
             prd.group_name,
             prd.group_cur_id,
             prd.group_cur_code,
             prd.group_qty_unit_id,
             prd.group_qty_unit,
             prd.item_qty_in_base_qty_unit,
             prd.base_qty_unit_id,
             prd.base_qty_unit,
             prd.base_cur_id,
             prd.base_cur_code,
             prd.base_price_unit_id,
             prd.base_price_unit_name,
             prd.sales_profit_center_id,
             prd.sales_profit_center_name,
             prd.sales_profit_center_short_name,
             prd.sales_internal_gmr_ref_no,
             prd.sales_contract_ref_no,
             prd.origination_city_id,
             prd.origination_city_name,
             prd.origination_country_id,
             prd.origination_country_name,
             prd.destination_city_id,
             prd.destination_city_name,
             prd.destination_country_id,
             prd.destination_country_name,
             prd.pool_id,
             prd.strategy_id,
             prd.strategy_name,
             prd.business_line_id,
             prd.business_line_name,
             prd.bl_number,
             prd.bl_date,
             prd.seal_no,
             prd.mark_no,
             prd.warehouse_ref_no,
             prd.warehouse_receipt_no,
             prd.warehouse_receipt_date,
             prd.is_warrant,
             prd.warrant_no,
             prd.pcdi_id,
             prd.supp_contract_item_ref_no,
             prd.supplier_pcdi_id,
             prd.payable_returnable_type,
             prd.delivery_item_no,
             prd.realized_sub_type,
             prd.price_description
        from prd_physical_realized_daily prd,
             tdc_trade_date_closure tdc,
             (select prd.sales_internal_gmr_ref_no,
                     max(prd.trade_date) trade_date
                from prd_physical_realized_daily prd,
                     tdc_trade_date_closure      tdc
               where prd.corporate_id = tdc.corporate_id
                 and tdc.corporate_id = pc_corporate_id
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
                 and prd.trade_date <= pd_trade_date
                 and prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
               group by prd.sales_internal_gmr_ref_no) max_eod -- PRD Realized Date and Allocated Sales
       where (prd.int_alloc_group_id, prd.sales_internal_gmr_ref_no) in
             (select sswh.activity_ref_no,
                     sswh.internal_gmr_ref_no
                from sswh_spe_settle_washout_header sswh
               where sswh.cancelled_process_id = pc_process_id
              
              ) -- Records to be considered for Reverse Realization
         and prd.trade_date = tdc.trade_date
         and tdc.trade_date = max_eod.trade_date
         and prd.sales_internal_gmr_ref_no =
             max_eod.sales_internal_gmr_ref_no
         and tdc.corporate_id = pc_corporate_id
         and tdc.process = pc_process
         and tdc.process_id = prd.process_id;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure pkg_phy_physical_process Realized Today',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace ||
                                                           'No ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  -------------------

  ------------------------------------------
  --_realized PNL_Change
  procedure sp_washout_realize_pnl_change(pc_corporate_id varchar2,
                                          pd_trade_date   date,
                                          pc_process      varchar2,
                                          pc_process_id   varchar2,
                                          pc_user_id      varchar2) is
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vc_error_msg                   varchar2(10);
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_contract_value_in_price_cur number;
    vn_contract_value_in_base_cur  number;
    vn_cog_net_sale_value          number;
    vn_forward_points              number;
    vn_price_to_base_fw_exch_rate  number;
    vc_price_to_base_fw_rate       varchar2(100);
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vc_price_unit_cur_id           varchar2(15);
    vc_price_unit_cur_code         varchar2(15);
    vc_price_unit_weight_unit_id   varchar2(15);
    vc_price_unit_weight_unit      varchar2(15);
    vn_price_unit_weight           number;
  
    cursor cur_realized is
      select pd_trade_date trade_date,
             prd.corporate_id,
             prd.corporate_name,
             prd.internal_contract_ref_no,
             prd.contract_ref_no,
             prd.internal_contract_item_ref_no,
             prd.del_distribution_item_no,
             prd.contract_issue_date,
             prd.contract_type,
             prd.contract_status,
             prd.int_alloc_group_id,
             prd.alloc_group_name,
             prd.internal_gmr_ref_no,
             prd.gmr_ref_no,
             prd.internal_grd_ref_no,
             prd.internal_stock_ref_no,
             prd.product_id,
             prd.product_name,
             prd.origin_id,
             prd.origin_name,
             prd.quality_id,
             prd.quality_name,
             prd.profit_center_id,
             prd.profit_center_name,
             prd.profit_center_short_name,
             prd.cp_profile_id,
             prd.cp_name,
             prd.trade_user_id,
             prd.trade_user_name,
             prd.price_type_id,
             prd.price_type_name,
             prd.incoterm_id,
             prd.incoterm,
             prd.payment_term_id,
             prd.payment_term,
             prd.price_fixation_details,
             prd.price_fixation_status,
             'Previously Realized PNL Change' as realized_type,
             prd.realized_date,
             prd.container_no,
             iid.new_invoice_price contract_price,
             iid.new_invoice_price_unit_id price_unit_id,
             ppu.cur_id price_unit_cur_id,
             cm_ppu.cur_code price_unit_cur_code,
             ppu.weight_unit_id price_unit_weight_unit_id,
             qum.qty_unit price_unit_weight_unit,
             ppu.weight price_unit_weight,
             prd.contract_invoice_value,
             prd.contract_price as prev_real_price,
             prd.price_unit_id prev_real_price_id,
             prd.price_unit_cur_id prev_real_price_cur_id,
             prd.price_unit_cur_code prev_real_price_cur_code,
             prd.price_unit_weight_unit_id prev_real_price_weight_unit_id,
             prd.price_unit_weight_unit prev_real_price_weight_unit,
             prd.price_unit_weight prev_real_price_weight,
             prd.item_qty prev_real_qty,
             prd.qty_unit_id prev_real_qty_id,
             prd.qty_unit prev_real_qty_unit,
             prd.contract_value_in_price_cur prev_cont_value_in_price_cur,
             prd.contract_price_cur_id prev_contract_price_cur_id,
             prd.contract_price_cur_code prev_contract_price_cur_code,
             prd.contract_invoice_value as prev_real_contract_value,
             prd.secondary_cost_value prev_real_secondary_cost,
             prd.cog_net_sale_value prev_real_cog_net_sale_value,
             prd.realized_pnl prev_real_pnl,
             prd.product_premium_per_unit prev_product_premium_per_unit,
             prd.product_premium prev_product_premium,
             prd.quality_premium_per_unit prev_quality_premium_per_unit,
             prd.quality_premium prev_quality_premium,
             prd.secondary_cost_per_unit prev_secondary_cost_per_unit,
             prd.warehouse_id,
             prd.warehouse_name,
             prd.shed_id,
             prd.shed_name,
             prd.group_id,
             prd.group_name,
             prd.group_cur_id,
             prd.group_cur_code,
             prd.group_qty_unit_id,
             prd.group_qty_unit,
             prd.base_qty_unit_id,
             prd.base_qty_unit,
             prd.base_cur_id,
             prd.base_cur_code,
             prd.base_price_unit_id,
             prd.base_price_unit_name,
             prd.sales_profit_center_id,
             prd.sales_profit_center_name,
             prd.sales_profit_center_short_name,
             prd.sales_strategy_id,
             prd.sales_strategy_name,
             prd.sales_business_line_id,
             prd.sales_business_line_name,
             prd.sales_internal_gmr_ref_no,
             prd.sales_contract_ref_no,
             prd.origination_city_id,
             prd.origination_city_name,
             prd.origination_country_id,
             prd.origination_country_name,
             prd.destination_city_id,
             prd.destination_city_name,
             prd.destination_country_id,
             prd.destination_country_name,
             prd.pool_id,
             prd.strategy_id,
             prd.strategy_name,
             prd.business_line_id,
             prd.business_line_name,
             prd.bl_number,
             prd.bl_date,
             prd.seal_no,
             prd.mark_no,
             prd.warehouse_ref_no,
             prd.warehouse_receipt_no,
             prd.warehouse_receipt_date,
             prd.is_warrant,
             prd.warrant_no,
             prd.pcdi_id,
             prd.supp_contract_item_ref_no,
             prd.supplier_pcdi_id,
             prd.payable_returnable_type,
             prd.price_description,
             null avg_secondary_cost,
             null product_premium_per_unit,
             null quality_premium_per_unit,
             prd.product_premium product_premium,
             null product_premium_unit_id,
             prd.item_qty,
             prd.qty_unit qty_unit,
             prd.qty_unit_id,
             prd.delivery_item_no,
             prd.item_qty_in_base_qty_unit,
             null del_premium_cur_id,
             null del_premium_cur_code,
             ppu.weight del_premium_weight,
             ppu.weight_unit_id del_premium_weight_unit_id,
             pd_trade_date payment_due_date,
             null as price_to_base_fw_exch_rate_act,
             null as price_to_base_fw_exch_rate,
             null as contract_qp_fw_exch_rate,
             null as contract_pp_fw_exch_rate,
             null accrual_to_base_fw_exch_rate,
             prd.price_to_base_fw_exch_rate p_price_to_base_fw_exch_rate,
             prd.contract_qp_fw_exch_rate p_contract_qp_fw_exch_rate,
             prd.contract_pp_fw_exch_rate p_contract_pp_fw_exch_rate,
             prd.accrual_to_base_fw_exch_rate p_accrual_to_base_fw_exch_rate,
             iis.internal_invoice_ref_no latest_internal_invoice_ref_no,
             prd.sales_gmr_ref_no,
             prd.realized_sub_type,
             iis.is_cancelled_today,
             iis.is_invoice_new
        from prd_physical_realized_daily prd,
             iid_invoicable_item_details iid,
             is_invoice_summary          iis,
             v_ppu_pum                   ppu,
             cm_currency_master          cm_ppu,
             qum_quantity_unit_master    qum
       where iis.process_id = pc_process_id
         and prd.internal_gmr_ref_no = iid.internal_gmr_ref_no
         and iid.internal_contract_ref_no = iis.internal_contract_ref_no
         and prd.process_id <= pc_process_id
         and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
         and (iis.is_invoice_new = 'Y' or iis.is_cancelled_today = 'Y')
         and iid.new_invoice_price_unit_id = ppu.product_price_unit_id
         and ppu.cur_id = cm_ppu.cur_id(+)
         and ppu.weight_unit_id = qum.qty_unit_id(+)
         and 'TRUE' =
             (case
              when(iis.is_cancelled_today = 'Y' and
                   prd.realized_type = 'Previously Realized PNL Change') then
              'TRUE' when(iis.is_invoice_new = 'Y' and
                          prd.realized_type = 'Realized Today') then 'TRUE' else
              'FALSE' end);
  
    cursor cur_update_pnl is
      select prd.corporate_id,
             prd.int_alloc_group_id,
             prd.sales_internal_gmr_ref_no,
             prd.process_id,
             sum(prd.cog_net_sale_value) net_value
        from prd_physical_realized_daily prd
       where prd.process_id = pc_process_id
         and prd.corporate_id = pc_corporate_id
         and prd.realized_type = 'Previously Realized PNL Change'
       group by prd.corporate_id,
                prd.int_alloc_group_id,
                prd.sales_internal_gmr_ref_no,
                prd.process_id;
  begin
  
    for cur_realized_rows in cur_realized
    loop
    
      -- Contract Price Details
    
      vc_error_msg := '7';
      if (cur_realized_rows.is_invoice_new = 'Y' and
         cur_realized_rows.contract_type = 'P') then
        vn_contract_price            := cur_realized_rows.contract_price;
        vc_price_unit_id             := cur_realized_rows.price_unit_id;
        vc_price_unit_cur_id         := cur_realized_rows.price_unit_cur_id;
        vc_price_unit_cur_code       := cur_realized_rows.price_unit_cur_code;
        vc_price_unit_weight_unit_id := cur_realized_rows.price_unit_weight_unit_id;
        vc_price_unit_weight_unit    := cur_realized_rows.price_unit_weight_unit;
        vn_price_unit_weight         := cur_realized_rows.price_unit_weight;
        if vn_price_unit_weight is null then
          vn_price_unit_weight := 1;
        end if;
      else
        if (cur_realized_rows.is_cancelled_today = 'Y' or
           cur_realized_rows.contract_type = 'S') then
          vn_contract_price            := cur_realized_rows.prev_real_price;
          vc_price_unit_id             := cur_realized_rows.prev_real_price_id;
          vc_price_unit_cur_id         := cur_realized_rows.prev_real_price_cur_id;
          vc_price_unit_cur_code       := cur_realized_rows.prev_real_price_cur_code;
          vc_price_unit_weight_unit_id := cur_realized_rows.prev_real_price_weight_unit_id;
          vc_price_unit_weight_unit    := cur_realized_rows.prev_real_price_weight_unit;
          vn_price_unit_weight         := nvl(cur_realized_rows.prev_real_price_weight,
                                              1);
        end if;
      end if;
      -- Pricing Main Currency Details
      --
      pkg_general.sp_get_main_cur_detail(vc_price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
    
      -- Contratc value in base cur = Price Per Unit in Base * Qty in Base
      -- 
    
      -- Contract Value in Price Currency
      -- 
      vn_contract_value_in_price_cur := (vn_contract_price /
                                        nvl(vn_price_unit_weight, 1)) *
                                        vn_cont_price_cur_id_factor *
                                        cur_realized_rows.item_qty_in_base_qty_unit;
      --
      -- Get the Contract Value in Base Currency
      --
    
      pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                              pd_trade_date,
                                              cur_realized_rows.payment_due_date,
                                              vc_price_cur_id,
                                              cur_realized_rows.base_cur_id,
                                              30,
                                              vn_price_to_base_fw_exch_rate,
                                              vn_forward_points);
    
      if vc_price_cur_id <> cur_realized_rows.base_cur_id then
        if vn_price_to_base_fw_exch_rate is null or
           vn_price_to_base_fw_exch_rate = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process-sp_ realized_pnl_change ',
                                                               'PHY-005',
                                                               cur_realized_rows.base_cur_code ||
                                                               ' to ' ||
                                                               vc_price_cur_code || ' (' ||
                                                               to_char(pd_trade_date,
                                                                       'dd-Mon-yyyy') || ') ',
                                                               '',
                                                               pc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        end if;
      end if;
    
      if vn_price_to_base_fw_exch_rate is not null and
         vn_price_to_base_fw_exch_rate <> 1 then
        vc_price_to_base_fw_rate := '1 ' || cur_realized_rows.base_cur_code || '=' ||
                                    vn_price_to_base_fw_exch_rate || ' ' ||
                                    vc_price_cur_code;
      end if;
    
      vc_error_msg := '18';
    
      vn_contract_value_in_base_cur := (vn_contract_price /
                                       nvl(vn_price_unit_weight, 1)) *
                                       vn_cont_price_cur_id_factor *
                                       vn_price_to_base_fw_exch_rate *
                                       cur_realized_rows.item_qty_in_base_qty_unit;
    
      --
      -- Total COG/Sale Value = Contract Value 
    
      --invoice only create corresponding to purchase side
      if cur_realized_rows.contract_type = 'P' then
        vn_cog_net_sale_value := (-1) * vn_contract_value_in_base_cur;
      else
        vn_contract_value_in_base_cur := cur_realized_rows.contract_invoice_value;
        vn_cog_net_sale_value         := cur_realized_rows.prev_real_cog_net_sale_value;
      end if;
    
      vc_error_msg := '20';
      insert into prd_physical_realized_daily
        (process_id,
         trade_date,
         corporate_id,
         corporate_name,
         internal_contract_ref_no,
         contract_ref_no,
         internal_contract_item_ref_no,
         del_distribution_item_no,
         contract_issue_date,
         contract_type,
         contract_status,
         int_alloc_group_id,
         alloc_group_name,
         internal_gmr_ref_no,
         gmr_ref_no,
         internal_grd_ref_no,
         internal_stock_ref_no,
         product_id,
         product_name,
         origin_id,
         origin_name,
         quality_id,
         quality_name,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         cp_profile_id,
         cp_name,
         trade_user_id,
         trade_user_name,
         price_type_id,
         price_type_name,
         incoterm_id,
         incoterm,
         payment_term_id,
         payment_term,
         price_fixation_details,
         price_fixation_status,
         realized_type,
         realized_date,
         container_no,
         item_qty,
         qty_unit_id,
         qty_unit,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         price_unit_weight,
         contract_value_in_price_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         contract_invoice_value,
         secondary_cost_per_unit,
         product_premium_per_unit,
         product_premium,
         quality_premium_per_unit,
         quality_premium,
         secondary_cost_value,
         cog_net_sale_value,
         realized_pnl,
         prev_real_price,
         prev_real_price_id,
         prev_real_price_cur_id,
         prev_real_price_cur_code,
         prev_real_price_weight_unit_id,
         prev_real_price_weight_unit,
         prev_real_price_weight,
         prev_real_qty,
         prev_real_qty_id,
         prev_real_qty_unit,
         prev_cont_value_in_price_cur,
         prev_contract_price_cur_id,
         prev_contract_price_cur_code,
         prev_real_contract_value,
         prev_real_secondary_cost,
         prev_real_cog_net_sale_value,
         prev_real_pnl,
         prev_product_premium_per_unit,
         prev_product_premium,
         prev_quality_premium_per_unit,
         prev_quality_premium,
         prev_secondary_cost_per_unit,
         change_in_pnl,
         cfx_price_cur_to_base_cur,
         warehouse_id,
         warehouse_name,
         shed_id,
         shed_name,
         group_id,
         group_name,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         item_qty_in_base_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         base_cur_id,
         base_cur_code,
         base_price_unit_id,
         base_price_unit_name,
         sales_profit_center_id,
         sales_profit_center_name,
         sales_profit_center_short_name,
         sales_strategy_id,
         sales_strategy_name,
         sales_business_line_id,
         sales_business_line_name,
         sales_internal_gmr_ref_no,
         sales_contract_ref_no,
         origination_city_id,
         origination_city_name,
         origination_country_id,
         origination_country_name,
         destination_city_id,
         destination_city_name,
         destination_country_id,
         destination_country_name,
         pool_id,
         strategy_id,
         strategy_name,
         business_line_id,
         business_line_name,
         bl_number,
         bl_date,
         seal_no,
         mark_no,
         warehouse_ref_no,
         warehouse_receipt_no,
         warehouse_receipt_date,
         is_warrant,
         warrant_no,
         pcdi_id,
         supp_contract_item_ref_no,
         supplier_pcdi_id,
         payable_returnable_type,
         price_description,
         delivery_item_no,
         price_to_base_fw_exch_rate,
         contract_qp_fw_exch_rate,
         contract_pp_fw_exch_rate,
         accrual_to_base_fw_exch_rate,
         p_price_to_base_fw_exch_rate,
         p_contract_qp_fw_exch_rate,
         p_contract_pp_fw_exch_rate,
         p_accrual_to_base_fw_exch_rate,
         sales_gmr_ref_no,
         realized_sub_type)
      values
        (pc_process_id,
         pd_trade_date,
         cur_realized_rows.corporate_id,
         cur_realized_rows.corporate_name,
         cur_realized_rows.internal_contract_ref_no,
         cur_realized_rows.contract_ref_no,
         cur_realized_rows.internal_contract_item_ref_no,
         cur_realized_rows.del_distribution_item_no,
         cur_realized_rows.contract_issue_date,
         cur_realized_rows.contract_type,
         cur_realized_rows.contract_status,
         cur_realized_rows.int_alloc_group_id,
         cur_realized_rows.alloc_group_name,
         cur_realized_rows.internal_gmr_ref_no,
         cur_realized_rows.gmr_ref_no,
         cur_realized_rows.internal_grd_ref_no,
         cur_realized_rows.internal_stock_ref_no,
         cur_realized_rows.product_id,
         cur_realized_rows.product_name,
         cur_realized_rows.origin_id,
         cur_realized_rows.origin_name,
         cur_realized_rows.quality_id,
         cur_realized_rows.quality_name,
         cur_realized_rows.profit_center_id,
         cur_realized_rows.profit_center_name,
         cur_realized_rows.profit_center_short_name,
         cur_realized_rows.cp_profile_id,
         cur_realized_rows.cp_name,
         cur_realized_rows.trade_user_id,
         cur_realized_rows.trade_user_name,
         cur_realized_rows.price_type_id,
         cur_realized_rows.price_type_name,
         cur_realized_rows.incoterm_id,
         cur_realized_rows.incoterm,
         cur_realized_rows.payment_term_id,
         cur_realized_rows.payment_term,
         cur_realized_rows.price_fixation_details,
         cur_realized_rows.price_fixation_status,
         cur_realized_rows.realized_type,
         cur_realized_rows.realized_date,
         cur_realized_rows.container_no,
         cur_realized_rows.item_qty,
         cur_realized_rows.qty_unit_id,
         cur_realized_rows.qty_unit,
         vn_contract_price,
         vc_price_unit_id,
         vc_price_unit_cur_id,
         vc_price_unit_cur_code,
         vc_price_unit_weight_unit_id,
         vc_price_unit_weight_unit,
         vn_price_unit_weight,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         null,
         null,
         null,
         null,
         null,
         null,
         vn_cog_net_sale_value,
         null, --realized_pnl,
         cur_realized_rows.prev_real_price,
         cur_realized_rows.prev_real_price_id,
         cur_realized_rows.prev_real_price_cur_id,
         cur_realized_rows.prev_real_price_cur_code,
         cur_realized_rows.prev_real_price_weight_unit_id,
         cur_realized_rows.prev_real_price_weight_unit,
         cur_realized_rows.prev_real_price_weight,
         cur_realized_rows.prev_real_qty,
         cur_realized_rows.prev_real_qty_id,
         cur_realized_rows.prev_real_qty_unit,
         cur_realized_rows.prev_cont_value_in_price_cur,
         cur_realized_rows.prev_contract_price_cur_id,
         cur_realized_rows.prev_contract_price_cur_code,
         cur_realized_rows.prev_real_contract_value,
         cur_realized_rows.prev_real_secondary_cost,
         cur_realized_rows.prev_real_cog_net_sale_value,
         cur_realized_rows.prev_real_pnl,
         cur_realized_rows.prev_product_premium_per_unit,
         cur_realized_rows.prev_product_premium,
         cur_realized_rows.prev_quality_premium_per_unit,
         cur_realized_rows.prev_quality_premium,
         cur_realized_rows.prev_secondary_cost_per_unit,
         null, -- change_in_pnl,
         null, -- cfx_price_cur_to_base_cur,
         cur_realized_rows.warehouse_id,
         cur_realized_rows.warehouse_name,
         cur_realized_rows.shed_id,
         cur_realized_rows.shed_name,
         cur_realized_rows.group_id,
         cur_realized_rows.group_name,
         cur_realized_rows.group_cur_id,
         cur_realized_rows.group_cur_code,
         cur_realized_rows.group_qty_unit_id,
         cur_realized_rows.group_qty_unit,
         cur_realized_rows.item_qty_in_base_qty_unit,
         cur_realized_rows.base_qty_unit_id,
         cur_realized_rows.base_qty_unit,
         cur_realized_rows.base_cur_id,
         cur_realized_rows.base_cur_code,
         cur_realized_rows.base_price_unit_id,
         cur_realized_rows.base_price_unit_name,
         cur_realized_rows.sales_profit_center_id,
         cur_realized_rows.sales_profit_center_name,
         cur_realized_rows.sales_profit_center_short_name,
         cur_realized_rows.sales_strategy_id,
         cur_realized_rows.sales_strategy_name,
         cur_realized_rows.sales_business_line_id,
         cur_realized_rows.sales_business_line_name,
         cur_realized_rows.sales_internal_gmr_ref_no,
         cur_realized_rows.sales_contract_ref_no,
         cur_realized_rows.origination_city_id,
         cur_realized_rows.origination_city_name,
         cur_realized_rows.origination_country_id,
         cur_realized_rows.origination_country_name,
         cur_realized_rows.destination_city_id,
         cur_realized_rows.destination_city_name,
         cur_realized_rows.destination_country_id,
         cur_realized_rows.destination_country_name,
         cur_realized_rows.pool_id,
         cur_realized_rows.strategy_id,
         cur_realized_rows.strategy_name,
         cur_realized_rows.business_line_id,
         cur_realized_rows.business_line_name,
         cur_realized_rows.bl_number,
         cur_realized_rows.bl_date,
         cur_realized_rows.seal_no,
         cur_realized_rows.mark_no,
         cur_realized_rows.warehouse_ref_no,
         cur_realized_rows.warehouse_receipt_no,
         cur_realized_rows.warehouse_receipt_date,
         cur_realized_rows.is_warrant,
         cur_realized_rows.warrant_no,
         cur_realized_rows.pcdi_id,
         cur_realized_rows.supp_contract_item_ref_no,
         cur_realized_rows.supplier_pcdi_id,
         cur_realized_rows.payable_returnable_type,
         cur_realized_rows.price_description,
         cur_realized_rows.delivery_item_no,
         vc_price_to_base_fw_rate,
         null,
         null,
         null,
         cur_realized_rows.p_price_to_base_fw_exch_rate,
         cur_realized_rows.p_contract_qp_fw_exch_rate,
         cur_realized_rows.p_contract_pp_fw_exch_rate,
         cur_realized_rows.p_accrual_to_base_fw_exch_rate,
         cur_realized_rows.sales_gmr_ref_no,
         cur_realized_rows.realized_sub_type);
    end loop;
    --
    -- Update Realized PNL Value
    --
    vc_error_msg := '21';
    for cur_update_pnl_rows in cur_update_pnl
    loop
      update prd_physical_realized_daily prd
         set prd.realized_pnl  = cur_update_pnl_rows.net_value,
             prd.change_in_pnl = cur_update_pnl_rows.net_value -
                                 prd.prev_real_pnl
       where prd.corporate_id = cur_update_pnl_rows.corporate_id
         and prd.contract_type = 'S'
         and prd.int_alloc_group_id =
             cur_update_pnl_rows.int_alloc_group_id
         and prd.sales_internal_gmr_ref_no =
             cur_update_pnl_rows.sales_internal_gmr_ref_no
         and prd.process_id = pc_process_id
         and prd.prev_real_pnl is not null;
      --
    -- Let it update the same row where Realized Today was updated 
    -- In Case Sales GMR has more than one record
    --
    end loop;
    vc_error_msg := '22';
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_realize_pnl_change',
                                                           'M2M-013',
                                                           ' Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace ||
                                                           'No:' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

end;

------------------------------------------------------------------
/
