create or replace package "PKG_PHY_BM_REALIZED_PNL" is
  procedure sp_calc_phy_realized_today(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_process      varchar2);

  procedure sp_calc_reverse_realized(pc_corporate_id        varchar2,
                                     pd_trade_date          date,
                                     pc_process_id          varchar2,
                                     pc_user_id             varchar2,
                                     pc_process             varchar2,
                                     pc_previous_process_id varchar2);
  procedure sp_calc_phy_realize_pnl_change(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process      varchar2,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2);
  procedure sp_calc_realized_not_fixed(pc_corporate_id        varchar2,
                                       pd_trade_date          date,
                                       pc_process             varchar2,
                                       pc_process_id          varchar2,
                                       pc_user_id             varchar2,
                                       pc_previous_process_id varchar2);
end; 
/
create or replace package body "PKG_PHY_BM_REALIZED_PNL" is
  procedure sp_calc_phy_realized_today(pc_corporate_id varchar2,
                                       pd_trade_date   date,
                                       pc_process_id   varchar2,
                                       pc_user_id      varchar2,
                                       pc_process      varchar2) is
    cursor cur_realized is
    --
    -- 1. Sales Contracts
    --
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
             agh.int_alloc_group_id,
             agh.alloc_group_name,
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
             cipd.price_fixation_details price_fixation_details,
             cipd.price_fixation_status price_fixation_status,
             'Realized Today' realized_type,
             agh.realized_date realized_date,
             dgrd.container_no,
             dgrd.current_qty item_qty,
             dgrd.net_weight_unit_id qty_unit_id,
             qum_dgrd.qty_unit,
             nvl(gpd.contract_price, cipd.contract_price) contract_price,
             nvl(gpd.price_unit_id, cipd.price_unit_id) price_unit_id,
             nvl(gpd.price_unit_cur_id, cipd.price_unit_cur_id) price_unit_cur_id,
             nvl(gpd.price_unit_cur_code, cipd.price_unit_cur_code) price_unit_cur_code,
             nvl(gpd.price_unit_weight_unit_id,
                 cipd.price_unit_weight_unit_id) price_unit_weight_unit_id,
             nvl(gpd.price_unit_weight_unit, cipd.price_unit_weight_unit) price_unit_weight_unit,
             nvl(gpd.price_unit_weight, cipd.price_unit_weight) price_unit_weight,
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
             nvl(ppu.weight, 1) del_premium_weight,
             ppu.weight_unit_id del_premium_weight_unit_id,
             pd_trade_date payment_due_date,
             null contract_qp_fw_exch_rate,
             null contract_pp_fw_exch_rate,
             null accrual_to_base_fw_exch_rate,
             gscs.fw_rate_string sales_sc_exch_rate_string,
             null price_to_base_fw_exch_rate_act,
             null price_to_base_fw_exch_rate,
             gmr.latest_internal_invoice_ref_no,
             gmr.gmr_ref_no sales_gmr_ref_no
        from agh_alloc_group_header             agh,
             dgrd_delivered_grd                 dgrd,
             pci_physical_contract_item         pci,
             pcdi_pc_delivery_item              pcdi,
             pcm_physical_contract_main         pcm,
             ak_corporate                       akc,
             gmr_goods_movement_record          gmr,
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
             qum_quantity_unit_master           qum_dgrd,
             cipd_contract_item_price_daily     cipd,
             phd_profileheaderdetails           phd_wh,
             gcd_groupcorporatedetails          gcd,
             cm_currency_master                 cm_gcd,
             qum_quantity_unit_master           qum_gcd,
             qum_quantity_unit_master           qum_pdm,
             cym_countrymaster                  cym_pcdb,
             cim_citymaster                     cim_pcdb,
             css_corporate_strategy_setup       css,
             blm_business_line_master@eka_appdb blm,
             sld_storage_location_detail        sld,
             cim_citymaster                     cim_sld,
             gscs_gmr_sec_cost_summary          gscs,
             pt_price_type                      pt,
             v_ppu_pum                          ppu,
             cm_currency_master                 cm_ppu,
             gpd_gmr_price_daily                gpd
       where agh.process_id = pc_process_id
         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
         and dgrd.status = 'Active'
         and agh.process_id = dgrd.process_id
         and agh.int_sales_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and agh.process_id = pci.process_id
         and pci.is_active = 'Y'
         and pcdi.pcdi_id = pci.pcdi_id
         and agh.process_id = pcdi.process_id
         and pcdi.is_active = 'Y'
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and agh.process_id = pcm.process_id
         and pcm.contract_status in ('In Position', 'Pending Approval')
         and pcm.contract_type = 'BASEMETAL'
         and pcm.corporate_id = akc.corporate_id
         and gmr.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
         and agh.process_id = gmr.process_id
         and gmr.is_deleted = 'N'
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and agh.process_id = pcpd.process_id
         and pcpd.is_active = 'Y'
         and pcpd.product_id = pdm.product_id
         and pcpd.pcpd_id = pcpq.pcpd_id
         and agh.process_id = pcpq.process_id
         and pcpq.quality_template_id = qat.quality_id
         and pcpq.is_active = 'Y'
         and qat.product_origin_id = pom.product_origin_id(+)
         and pom.origin_id = orm.origin_id(+)
         and pcpd.profit_center_id = cpc.profit_center_id
         and pcm.cp_id = phd_cp.profileid
         and pcm.trader_id = akcu.user_id
         and akcu.gabid = gab.gabid
         and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
         and agh.process_id = pcdb.process_id
         and pcm.payment_term_id = pym.payment_term_id
         and pcdb.inco_term_id = itm.incoterm_id
         and dgrd.net_weight_unit_id = qum_dgrd.qty_unit_id
         and pci.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and agh.process_id = cipd.process_id
         and dgrd.warehouse_profile_id = phd_wh.profileid(+)
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
         and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         and pcdb.country_id = cym_pcdb.country_id
         and pcdb.city_id = cim_pcdb.city_id
         and pcpd.strategy_id = css.strategy_id
         and cpc.business_line_id = blm.business_line_id(+)
         and dgrd.shed_id = sld.storage_loc_id(+)
         and sld.city_id = cim_sld.city_id(+)
         and agh.realized_status = 'Realized'
         and agh.today_status = 'Realized Today'
         and dgrd.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
         and dgrd.process_id = gscs.process_id(+)
         and pcdi.item_price_type = pt.price_type_id(+)
         and ppu.product_price_unit_id(+) = pcdb.premium_unit_id
         and ppu.cur_id = cm_ppu.cur_id(+)
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
      -- 
      -- 2.  Purchase contracts With Contract Ref Numbers
      -- 
      union all
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
             agh.int_alloc_group_id int_alloc_group_id,
             agh.alloc_group_name alloc_group_name,
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
             agh.realized_date realized_date,
             grd.container_no container_no,
             agd.qty item_qty,
             agd.qty_unit_id qty_unit_id,
             qum_agd.qty_unit qty_unit,
             invs.material_cost_per_unit contract_price,
             invs.price_unit_id price_unit_id,
             invs.price_unit_cur_id price_unit_cur_id,
             invs.price_unit_cur_code price_unit_cur_code,
             invs.price_unit_weight_unit_id price_unit_weight_unit_id,
             invs.price_unit_weight_unit price_unit_weight_unit,
             invs.price_unit_weight price_unit_weight,
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
             nvl(invs.secondary_cost_per_unit, 0) secondary_cost_per_unit,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             nvl(invs.product_premium_per_unit, 0) cog_product_premium_per_unit,
             nvl(invs.quality_premium_per_unit, 0) cog_quality_premium_per_unit,
             pci.price_description,
             pcdi.delivery_item_no,
             null del_premium_cur_id,
             null del_premium_cur_code,
             null del_premium_weight,
             null del_premium_weight_unit_id,
             pd_trade_date payment_due_date,
             invs.contract_qp_fw_exch_rate,
             invs.contract_pp_fw_exch_rate,
             invs.accrual_to_base_fw_exch_rate,
             null sales_sc_exch_rate_string,
             invs.price_to_base_fw_exch_rate_act,
             invs.price_to_base_fw_exch_rate,
             gmr.latest_internal_invoice_ref_no,
             gmr_sales.gmr_ref_no
        from agh_alloc_group_header agh,
             agd_alloc_group_detail agd,
             grd_goods_record_detail grd,
             pci_physical_contract_item pci,
             pcdi_pc_delivery_item pcdi,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             gmr_goods_movement_record gmr,
             pdm_productmaster pdm,
             qat_quality_attributes qat,
             pom_product_origin_master pom,
             orm_origin_master orm,
             pcpd_pc_product_definition pcpd,
             cpc_corporate_profit_center cpc,
             phd_profileheaderdetails phd_cp,
             ak_corporate_user akcu,
             gab_globaladdressbook gab,
             pcdb_pc_delivery_basis pcdb,
             itm_incoterm_master itm,
             pym_payment_terms_master pym,
             qum_quantity_unit_master qum_agd,
             phd_profileheaderdetails phd_wh,
             sld_storage_location_detail sld,
             cim_citymaster cim_sld,
             gcd_groupcorporatedetails gcd,
             cm_currency_master cm_gcd,
             qum_quantity_unit_master qum_gcd,
             qum_quantity_unit_master qum_pdm,
             cym_countrymaster cym_gmr_dest,
             cim_citymaster cim_gmr_dest,
             invm_cogs invs,
             (select dgrd.internal_gmr_ref_no,
                     int_alloc_group_id
                from dgrd_delivered_grd dgrd
               where dgrd.process_id = pc_process_id
                 and dgrd.status = 'Active'
               group by dgrd.internal_gmr_ref_no,
                        int_alloc_group_id) dgrd,
             pci_physical_contract_item pci_sales,
             pcdi_pc_delivery_item pcdi_sales,
             pcm_physical_contract_main pcm_sales,
             pt_price_type pt,
             css_corporate_strategy_setup css,
             gmr_goods_movement_record gmr_sales
       where agh.process_id = pc_process_id
         and agh.process_id = agd.process_id
         and agh.int_alloc_group_id = agd.int_alloc_group_id
         and agd.internal_stock_ref_no = grd.internal_grd_ref_no
         and agh.process_id = grd.process_id
         and grd.is_deleted = 'N'
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and agh.process_id = pci.process_id
         and pci.is_active = 'Y'
         and pci.pcdi_id = pcdi.pcdi_id
         and agh.process_id = pcdi.process_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and agh.process_id = pcm.process_id
         and pcdi.is_active = 'Y'
         and pcm.contract_status in ('In Position', 'Pending Approval')
         and pcm.contract_type = 'BASEMETAL'
         and pcm.corporate_id = akc.corporate_id
         and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and agh.process_id = gmr.process_id
         and gmr.is_deleted = 'N'
         and grd.product_id = pdm.product_id
         and grd.quality_id = qat.quality_id
         and qat.product_origin_id = pom.product_origin_id(+)
         and pom.origin_id = orm.origin_id(+)
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and agh.process_id = pcpd.process_id
         and pcpd.profit_center_id = cpc.profit_center_id
         and pcm.cp_id = phd_cp.profileid
         and pcm.trader_id = akcu.user_id
         and akcu.gabid = gab.gabid
         and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
         and agh.process_id = pcdb.process_id
         and pci.pcdb_id = pcdb.pcdb_id
         and pcdb.is_active = 'Y'
         and pcdb.inco_term_id = itm.incoterm_id
         and pcm.payment_term_id = pym.payment_term_id
         and agd.qty_unit_id = qum_agd.qty_unit_id
         and grd.warehouse_profile_id = phd_wh.profileid(+)
         and grd.shed_id = sld.storage_loc_id(+)
         and sld.city_id = cim_sld.city_id(+)
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id
         and pdm.base_quantity_unit = qum_pdm.qty_unit_id
         and gmr.destination_country_id = cym_gmr_dest.country_id(+)
         and gmr.destination_city_id = cim_gmr_dest.city_id(+)
         and agh.realized_status = 'Realized'
         and agh.today_status = 'Realized Today'
         and invs.internal_grd_ref_no = grd.internal_grd_ref_no
         and invs.process_id = grd.process_id
         and invs.sales_internal_gmr_ref_no = dgrd.internal_gmr_ref_no
         and agh.int_alloc_group_id = dgrd.int_alloc_group_id
         and agh.int_sales_contract_item_ref_no =
             pci_sales.internal_contract_item_ref_no
         and pci_sales.process_id = agh.process_id
         and pci_sales.pcdi_id = pcdi_sales.pcdi_id
         and pcdi_sales.internal_contract_ref_no =
             pcm_sales.internal_contract_ref_no
         and pcdi_sales.process_id = agh.process_id
         and pcm_sales.process_id = agh.process_id
         and pcdi.item_price_type = pt.price_type_id(+)
         and grd.strategy_id = css.strategy_id(+)
         and dgrd.internal_gmr_ref_no = gmr_sales.internal_gmr_ref_no
         and gmr_sales.process_id = pc_process_id;
  
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
    vn_quality_premium_per_unit    number;
    vn_quality_premium             number;
    vn_product_premium_per_unit    number;
    vn_product_premium             number;
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
    vc_del_premium_main_cur_id     varchar2(15);
    vc_del_premium_main_cur_code   varchar2(15);
    vn_del_premium_cur_main_factor number;
    vn_fw_exch_rate_del_to_base    number;
    vn_forward_points              number;
    vc_contract_qp_fw_exch_rate    varchar2(100);
    vc_contract_pp_fw_exch_rate    varchar2(100);
    vc_qual_prem_exch_rate_string  varchar2(100);
    vn_price_to_base_fw_exch_rate  number;
    vc_price_to_base_fw_rate       varchar2(100);
    vc_sc_to_base_fw_exch_rate     varchar2(500);
    --
    vn_contract_price            number;
    vc_price_unit_id             varchar2(15);
    vc_price_unit_cur_id         varchar2(15);
    vc_price_unit_cur_code       varchar2(15);
    vc_price_unit_weight_unit_id varchar2(15);
    vc_price_unit_weight_unit    varchar2(15);
    vn_price_unit_weight         number;
  begin
    vc_error_msg := '1';
    for cur_realized_rows in cur_realized
    loop
    
      if cur_realized_rows.contract_type = 'S' then
        if cur_realized_rows.latest_internal_invoice_ref_no is null then
          vc_error_msg                 := '7';
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
          -- Invoice Present
          vc_error_msg := '8';
          begin
            select iid.new_invoice_price,
                   iid.new_invoice_price_unit_id,
                   ppu.cur_id,
                   cm.cur_code,
                   ppu.weight_unit_id,
                   qum.qty_unit,
                   nvl(ppu.weight, 1) weight
              into vn_contract_price,
                   vc_price_unit_id,
                   vc_price_unit_cur_id,
                   vc_price_unit_cur_code,
                   vc_price_unit_weight_unit_id,
                   vc_price_unit_weight_unit,
                   vn_price_unit_weight
              from iid_invoicable_item_details iid,
                   v_ppu_pum                   ppu,
                   cm_currency_master          cm,
                   qum_quantity_unit_master    qum
             where iid.internal_invoice_ref_no =
                   cur_realized_rows.latest_internal_invoice_ref_no
               and iid.new_invoice_price_unit_id =
                   ppu.product_price_unit_id
               and ppu.cur_id = cm.cur_id
               and ppu.weight_unit_id = qum.qty_unit_id
               and iid.internal_gmr_ref_no =
                   cur_realized_rows.internal_gmr_ref_no;
          
          exception
            when others then
              vc_error_msg := '9';
              -- REMOVE THIS LATER, NOT SURE HOW INVOICE IS WORKING
              vn_contract_price            := cur_realized_rows.contract_price;
              vc_price_unit_id             := cur_realized_rows.price_unit_id;
              vc_price_unit_cur_id         := cur_realized_rows.price_unit_cur_id;
              vc_price_unit_cur_code       := cur_realized_rows.price_unit_cur_code;
              vc_price_unit_weight_unit_id := cur_realized_rows.price_unit_weight_unit_id;
              vc_price_unit_weight_unit    := cur_realized_rows.price_unit_weight_unit;
              vn_price_unit_weight         := cur_realized_rows.price_unit_weight;
            
          end;
        end if;
      else
        -- Purchase We don't need to look at invoice as COG contains latest price 
        vn_contract_price            := cur_realized_rows.contract_price;
        vc_price_unit_id             := cur_realized_rows.price_unit_id;
        vc_price_unit_cur_id         := cur_realized_rows.price_unit_cur_id;
        vc_price_unit_cur_code       := cur_realized_rows.price_unit_cur_code;
        vc_price_unit_weight_unit_id := cur_realized_rows.price_unit_weight_unit_id;
        vc_price_unit_weight_unit    := cur_realized_rows.price_unit_weight_unit;
        vn_price_unit_weight         := cur_realized_rows.price_unit_weight;
      
      end if;
    
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
      if cur_realized_rows.contract_type = 'S' then
        pkg_general.sp_get_main_cur_detail(vc_price_unit_cur_id,
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
      
      else
        -- It is from COG and has to be in Base Currency
        vc_price_cur_id             := cur_realized_rows.base_cur_id;
        vc_price_cur_code           := cur_realized_rows.base_cur_code;
        vn_cont_price_cur_id_factor := 1;
        vn_cont_price_cur_decimals  := 2;
      end if;
      vc_error_msg := '2';
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
      --
      -- Total Secondary Cost Value = Avg Seconadry Cost * Realized Qty in Product Base Unit
      --
      vn_sc_in_base_cur := cur_realized_rows.secondary_cost_per_unit *
                           vn_qty_in_base_qty_unit_id;
      vc_error_msg      := '3';
      --
      -- Calculate Product Premium, Purchase Contracts from INVM else from Contract
      -- 
      if cur_realized_rows.contract_type = 'P' then
        vn_product_premium := vn_qty_in_base_qty_unit_id *
                              cur_realized_rows.cog_product_premium_per_unit;
      
        vc_contract_pp_fw_exch_rate := cur_realized_rows.contract_pp_fw_exch_rate;
      else
        if cur_realized_rows.delivery_premium <> 0 then
          if cur_realized_rows.delivery_premium_unit_id <>
             vc_base_price_unit_id then
            --
            -- Get the Main Currency of the Delivery Premium Price Unit
            --
            pkg_general.sp_get_base_cur_detail(cur_realized_rows.del_premium_cur_id,
                                               vc_del_premium_main_cur_id,
                                               vc_del_premium_main_cur_code,
                                               vn_del_premium_cur_main_factor);
          
            pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                    pd_trade_date,
                                                    cur_realized_rows.payment_due_date,
                                                    vc_del_premium_main_cur_id,
                                                    cur_realized_rows.base_cur_id,
                                                    30,
                                                    vn_fw_exch_rate_del_to_base,
                                                    vn_forward_points);
          
            if vc_del_premium_main_cur_id <> cur_realized_rows.base_cur_id then
              if vn_fw_exch_rate_del_to_base is null or
                 vn_fw_exch_rate_del_to_base = 0 then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure pkg_phy_physical_process-sp_physical_realized_today ',
                                                                     'PHY-005',
                                                                     cur_realized_rows.base_cur_code ||
                                                                     ' to ' ||
                                                                     vc_del_premium_main_cur_id || ' (' ||
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
            if vn_fw_exch_rate_del_to_base <> 1 then
              vc_contract_pp_fw_exch_rate := '1 ' ||
                                             vc_del_premium_main_cur_code || '=' ||
                                             vn_fw_exch_rate_del_to_base || ' ' ||
                                             cur_realized_rows.base_cur_code;
            end if;
          
            vn_product_premium_per_unit := (cur_realized_rows.delivery_premium /
                                           cur_realized_rows.del_premium_weight) *
                                           vn_del_premium_cur_main_factor *
                                           vn_fw_exch_rate_del_to_base *
                                           pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                                cur_realized_rows.del_premium_weight_unit_id,
                                                                                cur_realized_rows.base_qty_unit_id,
                                                                                1);
          
          else
            vn_product_premium_per_unit := cur_realized_rows.delivery_premium;
          end if;
          vn_product_premium := round(vn_product_premium_per_unit *
                                      vn_qty_in_base_qty_unit_id,
                                      2);
        else
          vn_product_premium_per_unit := 0;
          vn_product_premium          := 0;
        end if;
      end if;
      vc_error_msg := '4';
      --
      -- Calculate Contract Quality Premium, Purchase Contracts from COG Sales COntracts from Contract
      -- 
      if cur_realized_rows.contract_type = 'P' then
        vn_quality_premium            := round(cur_realized_rows.cog_quality_premium_per_unit *
                                               vn_qty_in_base_qty_unit_id,
                                               2);
        vc_qual_prem_exch_rate_string := cur_realized_rows.contract_qp_fw_exch_rate;
      else
        pkg_metals_general.sp_quality_premium_fw_rate(cur_realized_rows.internal_contract_item_ref_no,
                                                      pc_corporate_id,
                                                      pd_trade_date,
                                                      vc_base_price_unit_id,
                                                      cur_realized_rows.base_cur_id,
                                                      cur_realized_rows.payment_due_date,
                                                      cur_realized_rows.product_id,
                                                      cur_realized_rows.base_qty_unit_id,
                                                      pc_process_id,
                                                      vn_quality_premium_per_unit,
                                                      vc_qual_prem_exch_rate_string);
        if vc_qual_prem_exch_rate_string is not null then
          vc_contract_qp_fw_exch_rate := vc_qual_prem_exch_rate_string;
        end if;
      
        vn_quality_premium := round((vn_quality_premium_per_unit *
                                    vn_qty_in_base_qty_unit_id),
                                    2);
      end if;
      vc_error_msg := '5';
      --  
      -- Contratc value in base cur = Price Per Unit in Base * Qty in Base
      -- 
      vc_error_msg := '5.1';
      if cur_realized_rows.contract_type = 'P' then
       /* vn_contract_value_in_base_cur  := vn_qty_in_base_qty_unit_id *
                                          vn_contract_price;
        vn_contract_value_in_price_cur := vn_contract_value_in_base_cur;*/
        vc_price_to_base_fw_rate       := cur_realized_rows.price_to_base_fw_exch_rate;
        vn_price_to_base_fw_exch_rate  := cur_realized_rows.price_to_base_fw_exch_rate_act;
        select ppu.product_price_unit_id
          into vc_contract_price_unit_id
          from v_ppu_pum ppu
         where ppu.product_price_unit_id = vc_price_unit_id
           and ppu.product_id = cur_realized_rows.product_id;  
       
        vn_contract_value_in_price_cur := (vn_contract_price /
                                          nvl(vn_price_unit_weight, 1)) *
                                          vn_cont_price_cur_id_factor *
                                          pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                               cur_realized_rows.qty_unit_id,
                                                                               cur_realized_rows.base_qty_unit_id,
                                                                               cur_realized_rows.item_qty);  
      
        vn_contract_value_in_base_cur := (vn_contract_price /
                                         nvl(vn_price_unit_weight, 1)) *
                                         vn_cont_price_cur_id_factor *
                                         vn_price_to_base_fw_exch_rate *
                                         pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                              cur_realized_rows.qty_unit_id,
                                                                              cur_realized_rows.base_qty_unit_id,
                                                                              cur_realized_rows.item_qty);       
                                
      else
        vc_error_msg              := '6';
        vc_contract_price_unit_id := vc_price_unit_id;
        --
        -- Contract Value in Price Currency
        -- 
        vn_contract_value_in_price_cur := (vn_contract_price /
                                          nvl(vn_price_unit_weight, 1)) *
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
                                                                 'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
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
        vn_contract_value_in_base_cur := (vn_contract_price /
                                         nvl(vn_price_unit_weight, 1)) *
                                         vn_cont_price_cur_id_factor *
                                         vn_price_to_base_fw_exch_rate *
                                         pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                              cur_realized_rows.qty_unit_id,
                                                                              cur_realized_rows.base_qty_unit_id,
                                                                              cur_realized_rows.item_qty);
      end if;
      vc_error_msg := '8';
      --
      -- Total COG or Sale Value = Contract Value (Qty * Price) + Quality Premium + Product Premium
      --  +- Secondary Cost (+ for Purchase Contracts and - for Sales Contracts)
      --
      vn_cog_net_sale_value := vn_contract_value_in_base_cur +
                               vn_quality_premium + vn_product_premium;
      if cur_realized_rows.contract_type = 'P' then
        vn_cog_net_sale_value := -1 * (vn_cog_net_sale_value +
                                 abs(vn_sc_in_base_cur));
      else
        vn_cog_net_sale_value := vn_cog_net_sale_value -
                                 abs(vn_sc_in_base_cur);
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
         sales_gmr_ref_no)
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
         vn_contract_price,
         vc_contract_price_unit_id,
         vc_price_unit_cur_id,
         vc_price_unit_cur_code,
         vc_price_unit_weight_unit_id,
         vc_price_unit_weight_unit,
         vn_price_unit_weight,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         cur_realized_rows.secondary_cost_per_unit,
         vn_sc_in_base_cur,
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
         vn_quality_premium,
         vn_quality_premium_per_unit,
         vn_product_premium,
         vn_product_premium_per_unit,
         vc_base_price_unit_id,
         vc_base_price_unit_name,
         cur_realized_rows.price_description,
         cur_realized_rows.delivery_item_no,
         vc_price_to_base_fw_rate,
         vc_contract_qp_fw_exch_rate,
         vc_contract_pp_fw_exch_rate,
         vc_sc_to_base_fw_exch_rate,
         cur_realized_rows.sales_gmr_ref_no);
    end loop;
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

  procedure sp_calc_reverse_realized(pc_corporate_id        varchar2,
                                     pd_trade_date          date,
                                     pc_process_id          varchar2,
                                     pc_user_id             varchar2,
                                     pc_process             varchar2,
                                     pc_previous_process_id varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
    vc_error_msg       varchar2(10);
  begin
    --
    -- GMRs which are cancelled in this EOD but active in previous EOD
    --
    insert into rgmr_realized_gmr
      (process_id,
       int_alloc_group_id,
       internal_gmr_ref_no,
       realized_status)
      select pc_process_id,
             agh_prev.int_alloc_group_id,
             dgrd_prev.internal_gmr_ref_no,
             'Reverse Realized'
        from agh_alloc_group_header agh_prev,
             dgrd_delivered_grd     dgrd_prev
       where agh_prev.int_alloc_group_id = dgrd_prev.int_alloc_group_id
         and agh_prev.process_id = dgrd_prev.process_id
         and agh_prev.process_id = pc_previous_process_id
         and agh_prev.realized_status = 'Realized'
         and agh_prev.int_alloc_group_id in
             (select agh_curr.int_alloc_group_id
                from agh_alloc_group_header agh_curr,
                     dgrd_delivered_grd     dgrd_curr
               where agh_curr.process_id = pc_process_id
                 and agh_curr.process_id = dgrd_curr.process_id
                 and agh_curr.int_alloc_group_id =
                     dgrd_curr.int_alloc_group_id
                 and agh_curr.realized_status = 'ReverseRealized');
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
             -1 * prd.secondary_cost_value,
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
                 and prd.trade_date < pd_trade_date
                 and prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
               group by prd.sales_internal_gmr_ref_no) max_eod -- PRD Realized Date and Allocated Sales
       where (prd.int_alloc_group_id, prd.sales_internal_gmr_ref_no) in
             (select rgmr.int_alloc_group_id,
                     rgmr.internal_gmr_ref_no
                from rgmr_realized_gmr rgmr
               where rgmr.process_id = pc_process_id
                 and rgmr.realized_status = 'Reverse Realized') -- Records to be considered for Reverse Realization
         and prd.trade_date = tdc.trade_date
         and tdc.trade_date = max_eod.trade_date
         and prd.sales_internal_gmr_ref_no =
             max_eod.sales_internal_gmr_ref_no
         and tdc.corporate_id = pc_corporate_id
         and prd.realized_type in
             ('Realized Today', 'Previously Realized PNL Change')
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
  procedure sp_calc_phy_realize_pnl_change(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process      varchar2,
                                           pc_process_id   varchar2,
                                           pc_user_id      varchar2) is
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vc_error_msg                   varchar2(10);
    vn_quality_premium             number;
    vn_quality_premium_per_unit    number;
    vn_product_premium             number;
    vn_product_premium_per_unit    number;
    vn_qty_in_base_qty_unit_id     number;
    vn_sc_in_base_cur              number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_contract_value_in_price_cur number;
    vn_contract_value_in_base_cur  number;
    vn_cog_net_sale_value          number;
    vc_del_premium_main_cur_id     varchar2(15);
    vc_del_premium_main_cur_code   varchar2(15);
    vn_del_premium_cur_main_factor number;
    vn_fw_exch_rate_del_to_base    number;
    vn_forward_points              number;
    vc_contract_qp_fw_exch_rate    varchar2(100);
    vc_contract_pp_fw_exch_rate    varchar2(100);
    vc_qual_prem_exch_rate_string  varchar2(100);
    vn_price_to_base_fw_exch_rate  number;
    vc_price_to_base_fw_rate       varchar2(100);
    vc_sc_to_base_fw_rate          varchar2(500);
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
             prd.contract_price,
             prd.price_unit_id,
             prd.price_unit_cur_id,
             prd.price_unit_cur_code,
             prd.price_unit_weight_unit_id,
             prd.price_unit_weight_unit,
             prd.price_unit_weight,
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
             nvl(gscs.avg_cost_fw_rate, 0) avg_secondary_cost,
             null product_premium_per_unit,
             null quality_premium_per_unit,
             pcdb.premium product_premium,
             pcdb.premium_unit_id product_premium_unit_id,
             case
               when rgmr.is_mc_change_for_sales = 'Y' then
                dgrd.current_qty
               else
                prd.item_qty
             end item_qty,
             case
               when rgmr.is_mc_change_for_sales = 'Y' then
                dgrd.net_weight_unit_id
               else
                prd.qty_unit_id
             end qty_unit_id,
             case
               when rgmr.is_mc_change_for_sales = 'Y' then
                qum_dgrd.qty_unit
               else
                prd.qty_unit
             end qty_unit,
             prd.delivery_item_no,
             rgmr.is_mc_change_for_sales,
             prd.item_qty_in_base_qty_unit,
             cm_ppu.cur_id del_premium_cur_id,
             cm_ppu.cur_code del_premium_cur_code,
             ppu.weight del_premium_weight,
             ppu.weight_unit_id del_premium_weight_unit_id,
             pd_trade_date payment_due_date,
             null as price_to_base_fw_exch_rate_act,
             null as price_to_base_fw_exch_rate,
             null as contract_qp_fw_exch_rate,
             null as contract_pp_fw_exch_rate,
             gscs.fw_rate_string as accrual_to_base_fw_exch_rate,
             prd.price_to_base_fw_exch_rate p_price_to_base_fw_exch_rate,
             prd.contract_qp_fw_exch_rate p_contract_qp_fw_exch_rate,
             prd.contract_pp_fw_exch_rate p_contract_pp_fw_exch_rate,
             prd.accrual_to_base_fw_exch_rate p_accrual_to_base_fw_exch_rate,
             rgmrd.latest_internal_invoice_ref_no,
             prd.sales_gmr_ref_no
        from prd_physical_realized_daily    prd,
             rgmr_realized_gmr              rgmr,
             cipd_contract_item_price_daily cipd,
             gscs_gmr_sec_cost_summary      gscs,
             pcdb_pc_delivery_basis         pcdb,
             dgrd_delivered_grd             dgrd,
             qum_quantity_unit_master       qum_dgrd,
             v_ppu_pum                      ppu,
             cm_currency_master             cm_ppu,
             pcdi_pc_delivery_item          pcdi,
             rgmrd_realized_gmr_detail      rgmrd
       where rgmr.process_id = pc_process_id
         and prd.int_alloc_group_id = rgmr.int_alloc_group_id
         and prd.sales_internal_gmr_ref_no = rgmr.internal_gmr_ref_no
         and prd.process_id = rgmr.realized_process_id
         and rgmr.realized_status = 'Previously Realized PNL Change'
         and prd.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and cipd.process_id = pc_process_id
         and rgmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
         and rgmr.process_id = gscs.process_id(+)
         and prd.contract_type = 'S'
         and prd.internal_contract_ref_no = pcdb.internal_contract_ref_no
         and pcdb.process_id = pc_process_id
         and dgrd.internal_dgrd_ref_no = prd.internal_grd_ref_no
         and dgrd.process_id = pc_process_id
         and qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id
         and ppu.product_price_unit_id(+) = pcdb.premium_unit_id
         and ppu.cur_id = cm_ppu.cur_id(+)
         and prd.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.process_id = pc_process_id
         and rgmrd.realized_internal_gmr_ref_no =
             prd.sales_internal_gmr_ref_no
         and rgmrd.contract_type = 'S'
         and rgmrd.process_id = pc_process_id
      union
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
             invs.material_cost_per_unit contract_price,
             invs.price_unit_id price_unit_id,
             invs.price_unit_cur_id,
             invs.price_unit_cur_code,
             invs.price_unit_weight_unit_id,
             invs.price_unit_weight_unit,
             invs.price_unit_weight,
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
             invs.secondary_cost_per_unit avg_secondary_cost,
             invs.product_premium_per_unit,
             invs.quality_premium_per_unit,
             null product_premium,
             null product_premium_unit_id,
             prd.item_qty item_qty,
             prd.qty_unit_id,
             prd.qty_unit,
             prd.delivery_item_no,
             rgmr.is_mc_change_for_sales,
             prd.item_qty_in_base_qty_unit,
             null del_premium_cur_id,
             null del_premium_cur_code,
             null del_premium_weight,
             null del_premium_weight_unit_id,
             pd_trade_date payment_due_date,
             invs.price_to_base_fw_exch_rate_act,
             invs.price_to_base_fw_exch_rate,
             invs.contract_qp_fw_exch_rate,
             invs.contract_pp_fw_exch_rate,
             invs.accrual_to_base_fw_exch_rate,
             prd.price_to_base_fw_exch_rate p_price_to_base_fw_exch_rate,
             prd.contract_qp_fw_exch_rate p_contract_qp_fw_exch_rate,
             prd.contract_pp_fw_exch_rate p_contract_pp_fw_exch_rate,
             prd.accrual_to_base_fw_exch_rate p_accrual_to_base_fw_exch_rate,
             rgmrd.latest_internal_invoice_ref_no,
             prd.sales_gmr_ref_no
        from prd_physical_realized_daily prd,
             rgmr_realized_gmr           rgmr,
             invm_cogs                   invs,
             qum_quantity_unit_master    qum_agd,
             rgmrd_realized_gmr_detail   rgmrd
       where rgmr.process_id = pc_process_id
         and prd.int_alloc_group_id = rgmr.int_alloc_group_id
         and prd.sales_internal_gmr_ref_no = rgmr.internal_gmr_ref_no
         and prd.process_id = rgmr.realized_process_id
         and rgmr.realized_status = 'Previously Realized PNL Change'
         and prd.internal_grd_ref_no = invs.internal_grd_ref_no
         and invs.sales_internal_gmr_ref_no = prd.sales_internal_gmr_ref_no
         and invs.process_id = pc_process_id
         and prd.contract_type = 'P'
         and qum_agd.qty_unit_id = prd.qty_unit_id
         and rgmrd.realized_internal_gmr_ref_no =
             prd.sales_internal_gmr_ref_no
         and rgmrd.purchase_internal_gmr_ref_no = prd.internal_gmr_ref_no
         and rgmrd.contract_type = 'P'
         and rgmrd.process_id = pc_process_id;
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
    --
    -- PNL Change for Quantity Change
    --
    delete from trgmr_temp_rgmr where corporate_id = pc_corporate_id;
    vc_error_msg := '1';
  
    insert into trgmr_temp_rgmr
      (corporate_id,
       int_alloc_group_id,
       internal_gmr_ref_no,
       realized_status,
       realized_process_id,
       realized_process_date,
       section_name,
       is_mc_change_for_sales)
      select pc_corporate_id,
             t.int_alloc_group_id,
             t.sales_internal_gmr_ref_no,
             'Previously Realized PNL Change',
             tdc.process_id,
             t.trade_date,
             t.section_name,
             is_mc_change_for_sales
        from (
              --
              -- Get the 'Realized Today', 'Previously Realized PNL Change' data for EOD/EOM
              --
              select prd.sales_internal_gmr_ref_no,
                      prd.int_alloc_group_id,
                      max(prd.trade_date) trade_date,
                      'Material Cost Change Sales' section_name,
                      'Y' is_mc_change_for_sales
                from dgrdul_delivered_grd_ul     dgrdul,
                      dgrd_delivered_grd          dgrd,
                      prd_physical_realized_daily prd,
                      tdc_trade_date_closure      tdc,
                      agh_alloc_group_header      agh
               where dgrdul.internal_dgrd_ref_no = dgrd.internal_dgrd_ref_no
                 and dgrdul.process_id = pc_process_id
                 and dgrd.process_id = pc_process_id
                 and prd.corporate_id = pc_corporate_id
                 and prd.process_id = tdc.process_id
                 and tdc.process = pc_process
                 and prd.item_qty<>dgrdul.current_qty
                 and prd.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
                 and prd.trade_date < pd_trade_date
                 and agh.int_alloc_group_id = prd.int_alloc_group_id
                 and agh.process_id = pc_process_id
                 and agh.realized_status = 'Realized'
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prd.sales_internal_gmr_ref_no,
                         prd.int_alloc_group_id) t,
             tdc_trade_date_closure tdc
       where tdc.corporate_id = pc_corporate_id
         and tdc.trade_date = t.trade_date
         and tdc.process = pc_process;
    vc_error_msg := '2';
    --
    -- PNL Change For Secondary Cost / Material Cost Change
    --                   
    insert into trgmr_temp_rgmr
      (corporate_id,
       int_alloc_group_id,
       internal_gmr_ref_no,
       realized_status,
       realized_process_id,
       realized_process_date,
       section_name)
      select pc_corporate_id,
             t.int_alloc_group_id,
             t.sales_internal_gmr_ref_no,
             'Previously Realized PNL Change',
             tdc.process_id,
             t.trade_date,
             'Secondary Cost Change'
        from (select prd.sales_internal_gmr_ref_no,
                     prd.int_alloc_group_id,
                     max(prd.trade_date) trade_date
                from cdl_cost_delta_log          cdl,
                     cs_cost_store               cs,
                     cigc_contract_item_gmr_cost cigc,
                     prd_physical_realized_daily prd,
                     tdc_trade_date_closure      tdc,
                     scm_service_charge_master   scm,
                     agh_alloc_group_header      agh
               where cdl.process_id = pc_process_id
                 and cdl.cost_ref_no = cs.cost_ref_no
                 and cs.internal_cost_id = cs.internal_cost_id
                 and cs.cog_ref_no = cigc.cog_ref_no
                 and cs.process_id = cigc.process_id
                 and cigc.process_id = pc_process_id
                 and scm.cost_id = cs.cost_component_id
                 and scm.cost_type in ('DIRECT_COST', 'SECONDARY_COST')
                 and cigc.internal_gmr_ref_no = prd.internal_gmr_ref_no
                 and prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and prd.trade_date < pd_trade_date
                 and agh.int_alloc_group_id = prd.int_alloc_group_id
                 and agh.process_id = pc_process_id
                 and agh.realized_status = 'Realized'
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prd.sales_internal_gmr_ref_no,
                        prd.int_alloc_group_id) t,
             tdc_trade_date_closure tdc
       where tdc.corporate_id = pc_corporate_id
         and tdc.trade_date = t.trade_date
         and tdc.process = pc_process;
    vc_error_msg := '3';
  
    insert into rgmr_realized_gmr
      (process_id,
       int_alloc_group_id,
       internal_gmr_ref_no,
       realized_status,
       realized_process_id,
       realized_process_date,
       is_mc_change_for_sales)
      select pc_process_id,
             int_alloc_group_id,
             internal_gmr_ref_no,
             realized_status,
             realized_process_id,
             realized_process_date,
             max(is_mc_change_for_sales)
        from trgmr_temp_rgmr t
       where t.corporate_id = pc_corporate_id
       group by int_alloc_group_id,
                internal_gmr_ref_no,
                realized_status,
                realized_process_id,
                realized_process_date;
    vc_error_msg := '4';
  
    --
    -- If PI / FI created mark them as we need to use this price and amount
    --
    insert into rgmrd_realized_gmr_detail
      (process_id,
       realized_internal_gmr_ref_no,
       purchase_internal_gmr_ref_no,
       internal_contract_item_ref_no,
       price_type_id,
       contract_type,
       price_fixation_status,
       is_invoiced,
       corporate_id)
      select pc_process_id,
             prd.sales_internal_gmr_ref_no,
             decode(prd.contract_type, 'P', prd.internal_gmr_ref_no, null) internal_gmr_ref_no,
             prd.internal_contract_item_ref_no,
             prd.price_type_id,
             prd.contract_type,
             prd.price_fixation_status,
             'N',
             prd.corporate_id
        from rgmr_realized_gmr           rgmr,
             prd_physical_realized_daily prd
       where rgmr.process_id = pc_process_id
         and rgmr.int_alloc_group_id = prd.int_alloc_group_id
         and rgmr.internal_gmr_ref_no = prd.sales_internal_gmr_ref_no
         and prd.process_id = rgmr.realized_process_id
         group by pc_process_id,
             prd.sales_internal_gmr_ref_no,
             decode(prd.contract_type, 'P', prd.internal_gmr_ref_no, null),
             prd.internal_contract_item_ref_no,
             prd.price_type_id,
             prd.contract_type,
             prd.price_fixation_status,
             'N',
             prd.corporate_id;
    vc_error_msg := '5';
  
    update rgmrd_realized_gmr_detail t
       set (t.is_invoiced, t.latest_internal_invoice_ref_no) = --
            (select decode(gmr.latest_internal_invoice_ref_no, null, 'N', 'Y'),
                    gmr.latest_internal_invoice_ref_no
               from gmr_goods_movement_record gmr
              where gmr.process_id = pc_process_id
                and gmr.internal_gmr_ref_no = t.realized_internal_gmr_ref_no)
     where t.process_id = pc_process_id
       and t.contract_type = 'S';
    update rgmrd_realized_gmr_detail t
       set (t.is_invoiced, t.latest_internal_invoice_ref_no) = --
            (select decode(gmr.latest_internal_invoice_ref_no, null, 'N', 'Y'),
                    gmr.latest_internal_invoice_ref_no
               from gmr_goods_movement_record gmr
              where gmr.process_id = pc_process_id
                and gmr.internal_gmr_ref_no = t.purchase_internal_gmr_ref_no)
     where t.process_id = pc_process_id
       and t.contract_type = 'P';
  
    --        
    -- update Price Data in RGMRD
    -- 
    update rgmrd_realized_gmr_detail rgmrd
       set (rgmrd.price_type_id, rgmrd.price_fixation_status) = --
            (select cipd.price_basis,
                    cipd.price_fixation_status
               from cipd_contract_item_price_daily cipd
              where cipd.process_id = pc_process_id
                and cipd.internal_contract_item_ref_no =
                    rgmrd.internal_contract_item_ref_no)
     where rgmrd.process_id = pc_process_id;
    vc_error_msg := '6';
  
    for cur_realized_rows in cur_realized
    loop
    
      -- Contract Price Details  
      if cur_realized_rows.contract_type = 'S' then
        if cur_realized_rows.latest_internal_invoice_ref_no is null then
          vc_error_msg                 := '7';
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
          -- Invoice Present
          vc_error_msg := '8';
          begin
            select iid.new_invoice_price,
                   iid.new_invoice_price_unit_id,
                   ppu.cur_id,
                   cm.cur_code,
                   ppu.weight_unit_id,
                   qum.qty_unit,
                   nvl(ppu.weight, 1) weight
              into vn_contract_price,
                   vc_price_unit_id,
                   vc_price_unit_cur_id,
                   vc_price_unit_cur_code,
                   vc_price_unit_weight_unit_id,
                   vc_price_unit_weight_unit,
                   vn_price_unit_weight
              from iid_invoicable_item_details iid,
                   v_ppu_pum                   ppu,
                   cm_currency_master          cm,
                   qum_quantity_unit_master    qum
             where iid.internal_invoice_ref_no =
                   cur_realized_rows.latest_internal_invoice_ref_no
               and iid.new_invoice_price_unit_id =
                   ppu.product_price_unit_id
               and ppu.cur_id = cm.cur_id
               and ppu.weight_unit_id = qum.qty_unit_id
               and iid.internal_gmr_ref_no =
                   cur_realized_rows.internal_gmr_ref_no;
          
          exception
            when others then
              vc_error_msg := '9';
              -- REMOVE THIS LATER, NOT SURE HOW INVOICE IS WORKING
              vn_contract_price            := cur_realized_rows.contract_price;
              vc_price_unit_id             := cur_realized_rows.price_unit_id;
              vc_price_unit_cur_id         := cur_realized_rows.price_unit_cur_id;
              vc_price_unit_cur_code       := cur_realized_rows.price_unit_cur_code;
              vc_price_unit_weight_unit_id := cur_realized_rows.price_unit_weight_unit_id;
              vc_price_unit_weight_unit    := cur_realized_rows.price_unit_weight_unit;
              vn_price_unit_weight         := cur_realized_rows.price_unit_weight;
            
          end;
        end if;
      else
        -- Purchase We don't need to look at invoice as COG contains latest price
        vn_contract_price            := cur_realized_rows.contract_price;
        vc_price_unit_id             := cur_realized_rows.price_unit_id;
        vc_price_unit_cur_id         := cur_realized_rows.price_unit_cur_id;
        vc_price_unit_cur_code       := cur_realized_rows.price_unit_cur_code;
        vc_price_unit_weight_unit_id := cur_realized_rows.price_unit_weight_unit_id;
        vc_price_unit_weight_unit    := cur_realized_rows.price_unit_weight_unit;
        vn_price_unit_weight         := cur_realized_rows.price_unit_weight;
      
      end if;
      vc_error_msg := '10';
    
      vc_sc_to_base_fw_rate := cur_realized_rows.accrual_to_base_fw_exch_rate;
    
      --
      -- If there is quantity change, this qty is used in this EOD
      --
      if cur_realized_rows.contract_type = 'S' and
         cur_realized_rows.is_mc_change_for_sales = 'Y' then
        vc_error_msg := '11';
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
      else
        vn_qty_in_base_qty_unit_id := cur_realized_rows.item_qty_in_base_qty_unit;
      end if;
      --
      -- Calcualte the New Quality Premium (Sales from Contract and Purchase from INVS)
      --
      vc_error_msg := '12';
    
      if cur_realized_rows.contract_type = 'S' then
        pkg_metals_general.sp_quality_premium_fw_rate(cur_realized_rows.internal_contract_item_ref_no,
                                                      pc_corporate_id,
                                                      pd_trade_date,
                                                      cur_realized_rows.base_price_unit_id,
                                                      cur_realized_rows.base_cur_id,
                                                      cur_realized_rows.payment_due_date,
                                                      cur_realized_rows.product_id,
                                                      cur_realized_rows.base_qty_unit_id,
                                                      pc_process_id,
                                                      vn_quality_premium_per_unit,
                                                      vc_qual_prem_exch_rate_string);
        if vc_qual_prem_exch_rate_string is not null then
          vc_contract_qp_fw_exch_rate := vc_qual_prem_exch_rate_string;
        end if;
      
        vn_quality_premium := round((vn_quality_premium_per_unit *
                                    vn_qty_in_base_qty_unit_id),
                                    2);
      else
        vn_quality_premium_per_unit := cur_realized_rows.quality_premium_per_unit;
        vn_quality_premium          := vn_quality_premium_per_unit *
                                       vn_qty_in_base_qty_unit_id;
        vc_contract_qp_fw_exch_rate := cur_realized_rows.contract_qp_fw_exch_rate;
      end if;
      vc_error_msg := '13';
    
      --
      -- Calcualte the new  Product Premium (Sales from Contract and Purchase from INVS)
      --
      if cur_realized_rows.contract_type = 'S' then
        if cur_realized_rows.product_premium <> 0 then
          if cur_realized_rows.product_premium_unit_id <>
             cur_realized_rows.base_price_unit_id then
          
            --
            -- Get the Main Currency of the Delivery Premium Price Unit
            --
            pkg_general.sp_get_base_cur_detail(cur_realized_rows.del_premium_cur_id,
                                               vc_del_premium_main_cur_id,
                                               vc_del_premium_main_cur_code,
                                               vn_del_premium_cur_main_factor);
          
            pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                    pd_trade_date,
                                                    cur_realized_rows.payment_due_date,
                                                    vc_del_premium_main_cur_id,
                                                    cur_realized_rows.base_cur_id,
                                                    30,
                                                    vn_fw_exch_rate_del_to_base,
                                                    vn_forward_points);
          
            if vc_del_premium_main_cur_id <> cur_realized_rows.base_cur_id then
              if vn_fw_exch_rate_del_to_base is null or
                 vn_fw_exch_rate_del_to_base = 0 then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure pkg_phy_physical_process-sp_calc_realized_pnl_change ',
                                                                     'PHY-005',
                                                                     cur_realized_rows.base_cur_code ||
                                                                     ' to ' ||
                                                                     vc_del_premium_main_cur_code || ' (' ||
                                                                     to_char(pd_trade_date,
                                                                             'dd-Mon-yyyy') || ') ',
                                                                     '',
                                                                     pc_process,
                                                                     null, --pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              end if;
            end if;
            if vn_fw_exch_rate_del_to_base <> 1 then
              vc_contract_pp_fw_exch_rate := '1 ' ||
                                             vc_del_premium_main_cur_code || '=' ||
                                             vn_fw_exch_rate_del_to_base || ' ' ||
                                             cur_realized_rows.base_cur_code;
            end if;
          
            vn_product_premium_per_unit := (cur_realized_rows.product_premium /
                                           nvl(cur_realized_rows.del_premium_weight,
                                                1)) *
                                           vn_del_premium_cur_main_factor *
                                           vn_fw_exch_rate_del_to_base;
          else
            vn_product_premium_per_unit := cur_realized_rows.product_premium;
          end if;
          vn_product_premium := round(vn_product_premium_per_unit *
                                      vn_qty_in_base_qty_unit_id,
                                      2);
        else
          vn_product_premium          := 0;
          vn_product_premium_per_unit := 0;
        end if;
      else
        vn_product_premium_per_unit := cur_realized_rows.product_premium_per_unit;
        vn_product_premium          := vn_product_premium_per_unit *
                                       vn_qty_in_base_qty_unit_id;
        vc_contract_pp_fw_exch_rate := cur_realized_rows.contract_pp_fw_exch_rate;
      end if;
    
      vc_error_msg := '14';
    
      --
      -- Secondary Cost in Base
      --
      vn_sc_in_base_cur := cur_realized_rows.avg_secondary_cost *
                           vn_qty_in_base_qty_unit_id;
    
      --
      -- Pricing Main Currency Details
      --
      if cur_realized_rows.contract_type = 'S' then
        pkg_general.sp_get_main_cur_detail(vc_price_unit_cur_id,
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
      else
        -- It is from COG and has to be in Base Currency
        vc_price_cur_id             := cur_realized_rows.base_cur_id;
        vc_price_cur_code           := cur_realized_rows.base_cur_code;
        vn_cont_price_cur_id_factor := 1;
        vn_cont_price_cur_decimals  := 2;
      end if;
      vc_error_msg := '15';
      --  
      -- Contratc value in base cur = Price Per Unit in Base * Qty in Base
      -- 
      if cur_realized_rows.contract_type = 'P' then
        vn_contract_value_in_price_cur := vn_qty_in_base_qty_unit_id *
                                          vn_contract_price;
        vn_contract_value_in_base_cur  := vn_contract_value_in_price_cur;
      
      else
        vc_error_msg := '16';
        --
        -- Contract Value in Price Currency
        -- 
        vn_contract_value_in_price_cur := (vn_contract_price /
                                          nvl(vn_price_unit_weight, 1)) *
                                          vn_cont_price_cur_id_factor *
                                          vn_qty_in_base_qty_unit_id;
        --
        -- Get the Contract Value in Base Currency
        --
        vc_error_msg := '17';
        if cur_realized_rows.contract_type = 'P' then
          vc_price_to_base_fw_rate      := cur_realized_rows.price_to_base_fw_exch_rate;
          vn_price_to_base_fw_exch_rate := cur_realized_rows.price_to_base_fw_exch_rate_act;
        else
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
            vc_price_to_base_fw_rate := '1 ' ||
                                        cur_realized_rows.base_cur_code || '=' ||
                                        vn_price_to_base_fw_exch_rate || ' ' ||
                                        vc_price_cur_code;
          end if;
        
        end if;
      
        vc_error_msg := '18';
      
        vn_contract_value_in_base_cur := (vn_contract_price /
                                         nvl(vn_price_unit_weight, 1)) *
                                         vn_cont_price_cur_id_factor *
                                         vn_price_to_base_fw_exch_rate *
                                         vn_qty_in_base_qty_unit_id;
      
      end if;
      vc_error_msg := '19';
      --
      -- Total COG/Sale Value = Contract Value + Quality Premium + Product Premium + Secondary Cost
      --
      vn_cog_net_sale_value := vn_contract_value_in_base_cur +
                               vn_quality_premium + vn_product_premium;
      if cur_realized_rows.contract_type = 'P' then
        vn_cog_net_sale_value := -1 * (vn_cog_net_sale_value +
                                 abs(vn_sc_in_base_cur));
      else
        vn_cog_net_sale_value := vn_cog_net_sale_value -
                                 abs(vn_sc_in_base_cur);
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
         sales_gmr_ref_no)
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
         vn_sc_in_base_cur / vn_qty_in_base_qty_unit_id, -- secondary_cost_per_unit,
         vn_product_premium_per_unit,
         vn_product_premium,
         vn_quality_premium_per_unit,
         vn_quality_premium,
         vn_sc_in_base_cur,
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
         vn_qty_in_base_qty_unit_id,
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
         vc_contract_qp_fw_exch_rate,
         vc_contract_pp_fw_exch_rate,
         vc_sc_to_base_fw_rate,
         cur_realized_rows.p_price_to_base_fw_exch_rate,
         cur_realized_rows.p_contract_qp_fw_exch_rate,
         cur_realized_rows.p_contract_pp_fw_exch_rate,
         cur_realized_rows.p_accrual_to_base_fw_exch_rate,
         cur_realized_rows.sales_gmr_ref_no);
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
  procedure sp_calc_realized_not_fixed(pc_corporate_id        varchar2,
                                       pd_trade_date          date,
                                       pc_process             varchar2,
                                       pc_process_id          varchar2,
                                       pc_user_id             varchar2,
                                       pc_previous_process_id varchar2) is
    cursor cur_not_fixed is
      select prd.corporate_id,
             prd.corporate_name,
             pc_process_id,
             prd.pcdi_id,
             prd.del_distribution_item_no,
             prd.internal_contract_ref_no,
             prd.contract_ref_no,
             prd.contract_issue_date,
             prd.internal_contract_item_ref_no,
             prd.contract_type,
             'Realized Not Final Invoiced' unrealized_type,
             prd.profit_center_id,
             prd.profit_center_name,
             prd.profit_center_short_name,
             prd.cp_profile_id cp_id,
             prd.cp_name,
             prd.trade_user_id,
             prd.trade_user_name,
             prd.product_id,
             prd.product_name,
             prd.item_qty,
             prd.qty_unit_id,
             prd.qty_unit,
             prd.quality_id,
             prd.quality_name,
             prd.product_name product_desc,
             prd.price_type_id,
             prd.price_type_name,
             prd.price_description price_string,
             null as delivery_period_string,
             null fixation_method,
             cipd.price_fixation_status price_fixation_status,
             prd.incoterm_id,
             prd.incoterm,
             prd.origination_city_id,
             prd.origination_city_name,
             prd.origination_country_id,
             prd.origination_country_name,
             prd.destination_city_id,
             prd.destination_city_name,
             prd.destination_country_id,
             prd.destination_country_name,
             prd.payment_term_id,
             prd.payment_term,
             prd.price_fixation_details,
             nvl(gpd.contract_price, cipd.contract_price) contract_price,
             nvl(gpd.price_unit_id, cipd.price_unit_id) price_unit_id,
             nvl(gpd.price_unit_cur_id, cipd.price_unit_cur_id) price_unit_cur_id,
             nvl(gpd.price_unit_cur_code, cipd.price_unit_cur_code) price_unit_cur_code,
             nvl(gpd.price_unit_weight_unit_id,
                 cipd.price_unit_weight_unit_id) price_unit_weight_unit_id,
             nvl(gpd.price_unit_weight_unit, cipd.price_unit_weight_unit) price_unit_weight_unit,
             nvl(gpd.price_unit_weight, cipd.price_unit_weight) price_unit_weight,
             prd.base_cur_id,
             prd.base_cur_code,
             prd.realized_date,
             prd.contract_price realized_price,
             prd.price_unit_id realized_price_id,
             prd.price_unit_cur_id realized_price_cur_id,
             prd.price_unit_cur_code realized_price_cur_code,
             prd.price_unit_weight_unit_id realized_price_weight_unit,
             prd.price_unit_weight realized_price_weight,
             prd.item_qty as realized_qty,
             prd.qty_unit_id realized_qty_unit_id,
             prd.group_id,
             prd.group_name,
             prd.group_cur_id,
             prd.group_cur_code,
             prd.group_qty_unit_id,
             prd.group_qty_unit,
             prd.base_qty_unit_id,
             prd.base_qty_unit,
             prd.item_qty_in_base_qty_unit qty_in_base_unit,
             prd.strategy_id,
             prd.strategy_name,
             prd.internal_grd_ref_no as realized_internal_stock_ref_no,
             prd.sales_internal_gmr_ref_no,
             prd.base_price_unit_id,
             prd.internal_grd_ref_no,
             prd.internal_gmr_ref_no,
             prd.delivery_item_no,
             prd.contract_invoice_value,
             prd.internal_stock_ref_no,
             prd.sales_gmr_ref_no
        from prd_physical_realized_daily    prd,
             cipd_contract_item_price_daily cipd,
             agh_alloc_group_header         agh,
             gmr_goods_movement_record      gmr,
             gpd_gmr_price_daily            gpd
       where (prd.sales_internal_gmr_ref_no, prd.int_alloc_group_id,
              prd.trade_date) in
             (select prd.sales_internal_gmr_ref_no,
                     prd.int_alloc_group_id,
                     max(prd.trade_date) trade_date
                from prd_physical_realized_daily prd,
                     tdc_trade_date_closure      tdc
               where prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and prd.corporate_id = pc_corporate_id
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prd.sales_internal_gmr_ref_no,
                        prd.int_alloc_group_id)
         and prd.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and cipd.process_id = pc_process_id
         and agh.int_alloc_group_id = prd.int_alloc_group_id
         and agh.process_id = pc_process_id
         and agh.is_deleted = 'N' -- Allocation is Active 
         and gmr.internal_gmr_ref_no = prd.sales_internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and nvl(gmr.is_final_invoiced, 'N') = 'N' -- As of today FI is not done
         and prd.contract_type = 'S'
         and cipd.price_basis <> 'Fixed'
         and agh.realized_status = 'Realized'
         and prd.realized_type in
             ('Realized Today', 'Previously Realized PNL Change')
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
      -- For Variable contracts only
      union
      select prd.corporate_id,
             prd.corporate_name,
             pc_process_id,
             prd.pcdi_id,
             prd.del_distribution_item_no,
             prd.internal_contract_ref_no,
             prd.contract_ref_no,
             prd.contract_issue_date,
             prd.internal_contract_item_ref_no,
             prd.contract_type,
             'Realized Not Final Invoiced' unrealized_type,
             prd.profit_center_id,
             prd.profit_center_name,
             prd.profit_center_short_name,
             prd.cp_profile_id cp_id,
             prd.cp_name,
             prd.trade_user_id,
             prd.trade_user_name,
             prd.product_id,
             prd.product_name,
             prd.item_qty,
             prd.qty_unit_id,
             prd.qty_unit,
             prd.quality_id,
             prd.quality_name,
             prd.product_name product_desc,
             prd.price_type_id,
             prd.price_type_name,
             prd.price_description price_string,
             null as delivery_period_string,
             null fixation_method,
             cipd.price_fixation_status price_fixation_status,
             prd.incoterm_id,
             prd.incoterm,
             prd.origination_city_id,
             prd.origination_city_name,
             prd.origination_country_id,
             prd.origination_country_name,
             prd.destination_city_id,
             prd.destination_city_name,
             prd.destination_country_id,
             prd.destination_country_name,
             prd.payment_term_id,
             prd.payment_term,
             prd.price_fixation_details,
             nvl(gpd.contract_price, cipd.contract_price) contract_price,
             nvl(gpd.price_unit_id, cipd.price_unit_id) price_unit_id,
             nvl(gpd.price_unit_cur_id, cipd.price_unit_cur_id) price_unit_cur_id,
             nvl(gpd.price_unit_cur_code, cipd.price_unit_cur_code) price_unit_cur_code,
             nvl(gpd.price_unit_weight_unit_id,
                 cipd.price_unit_weight_unit_id) price_unit_weight_unit_id,
             nvl(gpd.price_unit_weight_unit, cipd.price_unit_weight_unit) price_unit_weight_unit,
             nvl(gpd.price_unit_weight, cipd.price_unit_weight) price_unit_weight,
             prd.base_cur_id,
             prd.base_cur_code,
             prd.realized_date,
             prd.contract_price realized_price,
             prd.price_unit_id realized_price_id,
             prd.price_unit_cur_id realized_price_cur_id,
             prd.price_unit_cur_code realized_price_cur_code,
             prd.price_unit_weight_unit_id realized_price_weight_unit,
             prd.price_unit_weight realized_price_weight,
             prd.item_qty as realized_qty,
             prd.qty_unit_id realized_qty_unit_id,
             prd.group_id,
             prd.group_name,
             prd.group_cur_id,
             prd.group_cur_code,
             prd.group_qty_unit_id,
             prd.group_qty_unit,
             prd.base_qty_unit_id,
             prd.base_qty_unit,
             prd.item_qty_in_base_qty_unit qty_in_base_unit,
             prd.strategy_id,
             prd.strategy_name,
             prd.internal_grd_ref_no as realized_internal_stock_ref_no,
             prd.sales_internal_gmr_ref_no,
             prd.base_price_unit_id,
             prd.internal_grd_ref_no,
             prd.internal_gmr_ref_no,
             prd.delivery_item_no,
             prd.contract_invoice_value,
             prd.internal_stock_ref_no,
             prd.sales_gmr_ref_no
        from prd_physical_realized_daily    prd,
             cipd_contract_item_price_daily cipd,
             agh_alloc_group_header         agh,
             gmr_goods_movement_record      gmr,
             gpd_gmr_price_daily            gpd
       where (prd.sales_internal_gmr_ref_no, prd.int_alloc_group_id,
              prd.trade_date) in
             (select prd.sales_internal_gmr_ref_no,
                     prd.int_alloc_group_id,
                     max(prd.trade_date) trade_date
                from prd_physical_realized_daily prd,
                     tdc_trade_date_closure      tdc
               where prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and prd.corporate_id = pc_corporate_id
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prd.sales_internal_gmr_ref_no,
                        prd.int_alloc_group_id)
         and prd.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and cipd.process_id = pc_process_id
         and agh.int_alloc_group_id = prd.int_alloc_group_id
         and agh.process_id = pc_process_id
         and agh.is_deleted = 'N' -- Allocation is Active 
         and gmr.internal_gmr_ref_no = prd.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and nvl(gmr.is_final_invoiced, 'N') = 'N' -- As of today FI is not done
         and prd.contract_type = 'P'
         and cipd.price_basis <> 'Fixed'
         and agh.realized_status = 'Realized'
         and prd.realized_type in
             ('Realized Today', 'Previously Realized PNL Change')
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+);
  
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vc_error_msg                   varchar2(10);
    vn_contract_value_in_price_cur number;
    vn_contract_value_in_base_cur  number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_pnl_in_base_cur             number;
    vn_realized_amount_in_base_cur number;
    vn_prev_unr_pnl                number;
    vn_trade_day_pnl               number;
    vn_unreal_pnl_in_base_per_unit number;
    vn_price_to_base_fw_rate       number;
    vc_price_to_base_fw_rate       varchar2(100);
    vn_forward_points              number;
  begin
    vc_error_msg := '1';
    for cur_not_fixed_rows in cur_not_fixed
    loop
      --
      -- Calculate the Current contract value in Price Currency
      --
      pkg_general.sp_get_main_cur_detail(cur_not_fixed_rows.price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
      vc_error_msg                   := '2';
      vn_contract_value_in_price_cur := (cur_not_fixed_rows.contract_price /
                                        nvl(cur_not_fixed_rows.price_unit_weight,
                                             1)) *
                                        (pkg_general.f_get_converted_quantity(cur_not_fixed_rows.product_id,
                                                                              cur_not_fixed_rows.realized_qty_unit_id,
                                                                              cur_not_fixed_rows.price_unit_weight_unit_id,
                                                                              cur_not_fixed_rows.realized_qty)) *
                                        vn_cont_price_cur_id_factor;
      vn_contract_value_in_price_cur := round(vn_contract_value_in_price_cur,
                                              vn_cont_price_cur_decimals);
      --
      -- Convert contract value in Price Currency to Base Currency
      --
      vc_error_msg := '3';
      pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                              pd_trade_date,
                                              pd_trade_date,
                                              vc_price_cur_id,
                                              cur_not_fixed_rows.base_cur_id,
                                              30,
                                              vn_price_to_base_fw_rate,
                                              vn_forward_points);
      if vc_price_cur_id <> cur_not_fixed_rows.base_cur_id then
        if vn_price_to_base_fw_rate is null or vn_price_to_base_fw_rate = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure pkg_phy_physical_process-sp_calc_realized not fixed ',
                                                               'PHY-005',
                                                               cur_not_fixed_rows.base_cur_code ||
                                                               ' to ' ||
                                                               vc_price_cur_code || ' (' ||
                                                               to_char(pd_trade_date,
                                                                       'dd-Mon-yyyy') || ') ',
                                                               '',
                                                               pc_process,
                                                               null, -- pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        end if;
      end if;
    
      if vn_price_to_base_fw_rate <> 0 or vn_price_to_base_fw_rate <> 1 or
         vn_price_to_base_fw_rate is not null then
        vc_price_to_base_fw_rate := '1 ' || vc_price_cur_code || '=' ||
                                    vn_price_to_base_fw_rate || ' ' ||
                                    cur_not_fixed_rows.base_cur_code;
      else
        vc_price_to_base_fw_rate := null;
      end if;
      vn_contract_value_in_base_cur := round((vn_contract_value_in_price_cur *
                                             vn_price_to_base_fw_rate),
                                             2);
    
      --
      -- Value in Base Price Currency
      --
    
      vn_realized_amount_in_base_cur := cur_not_fixed_rows.contract_invoice_value;
    
      vc_error_msg := '4';
      --
      -- Calcualte the PNL in base
      --
    
      if cur_not_fixed_rows.contract_type = 'S' then
        vn_pnl_in_base_cur := vn_contract_value_in_base_cur -
                              vn_realized_amount_in_base_cur;
      else
        vn_pnl_in_base_cur := vn_realized_amount_in_base_cur -
                              vn_contract_value_in_base_cur;
      end if;
      vn_pnl_in_base_cur := round(vn_pnl_in_base_cur, 2);
      --
      -- Get the Previous Unrealized PNL
      --
      begin
        select poud_prev_day.unrealized_pnl_in_base_cur
          into vn_prev_unr_pnl
          from poud_phy_open_unreal_daily poud_prev_day
         where poud_prev_day.process_id = pc_previous_process_id
           and poud_prev_day.unrealized_type =
               'Realized Not Final Invoiced'
           and corporate_id = pc_corporate_id
           and poud_prev_day.sales_internal_gmr_ref_no =
               cur_not_fixed_rows.sales_internal_gmr_ref_no
           and poud_prev_day.internal_contract_item_ref_no =
               cur_not_fixed_rows.internal_contract_item_ref_no
           and poud_prev_day.contract_type =
               cur_not_fixed_rows.contract_type
           and poud_prev_day.realized_internal_stock_ref_no =
               cur_not_fixed_rows.internal_grd_ref_no;
      exception
        when no_data_found then
          vn_prev_unr_pnl := 0;
        when others then
          vn_prev_unr_pnl := 0; -- Issue in POUD 
      end;
    
      vc_error_msg                   := '5';
      vn_trade_day_pnl               := vn_pnl_in_base_cur -
                                        vn_prev_unr_pnl;
      vn_unreal_pnl_in_base_per_unit := vn_pnl_in_base_cur /
                                        cur_not_fixed_rows.qty_in_base_unit;
    
      vc_error_msg := '2';
      insert into poud_phy_open_unreal_daily
        (corporate_id,
         corporate_name,
         process_id,
         pcdi_id,
         delivery_item_no,
         prefix,
         middle_no,
         suffix,
         internal_contract_ref_no,
         contract_ref_no,
         contract_issue_date,
         internal_contract_item_ref_no,
         basis_type,
         delivery_period_type,
         delivery_from_month,
         delivery_from_year,
         delivery_to_month,
         delivery_to_year,
         delivery_from_date,
         delivery_to_date,
         transit_days,
         contract_type,
         approval_status,
         unrealized_type,
         profit_center_id,
         profit_center_name,
         profit_center_short_name,
         cp_profile_id,
         cp_name,
         trade_user_id,
         trade_user_name,
         product_id,
         product_name,
         item_qty,
         qty_unit_id,
         qty_unit,
         quality_id,
         quality_name,
         product_desc,
         price_type_id,
         price_type_name,
         price_string,
         item_delivery_period_string,
         fixation_method,
         price_fixation_status,
         incoterm_id,
         incoterm,
         origination_city_id,
         origination_city,
         origination_country_id,
         origination_country,
         destination_city_id,
         destination_city,
         destination_country_id,
         destination_country,
         origination_region_id,
         origination_region,
         destination_region_id,
         destination_region,
         payment_term_id,
         payment_term,
         price_fixation_details,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         net_m2m_price,
         m2m_price_unit_id,
         m2m_price_cur_id,
         m2m_price_cur_code,
         m2m_price_weight,
         m2m_price_weght_unit_id,
         m2m_price_weight_unit,
         contract_value_in_price_cur,
         contract_value_in_val_cur,
         price_main_cur_id,
         price_main_cur_code,
         valualtion_cur_id,
         valualtion_cur_code,
         m2m_amt,
         m2m_amt_cur_id,
         m2m_amt_cur_code,
         sc_in_valuation_cur,
         sc_in_base_cur,
         contract_premium_value,
         premium_cur_id,
         premium_cur_code,
         expected_cog_net_sale_value,
         unrealized_pnl_in_val_cur,
         unrealized_pnl_in_base_cur,
         prev_day_unr_pnl_in_val_cur,
         prev_day_unr_pnl_in_base_cur,
         trade_day_pnl_in_val_cur,
         trade_day_pnl_in_base_cur,
         base_cur_id,
         base_cur_code,
         expected_cog_in_val_cur,
         price_cur_to_val_cur_fx_rate,
         price_cur_to_base_cur_fx_rate,
         base_cur_to_val_cur_fx_rate,
         val_to_base_corp_fx_rate,
         spot_rate_val_cur_to_base_cur,
         unrealized_pnl_in_m2m_price_id,
         prev_unr_pnl_in_m2m_price_id,
         trade_day_pnl_in_m2m_price_id,
         realized_date,
         realized_price,
         realized_price_id,
         realized_price_cur_id,
         realized_price_cur_code,
         realized_price_weight,
         realized_price_weight_unit,
         realized_qty,
         realized_qty_id,
         realized_qty_unit,
         md_id,
         group_id,
         group_name,
         group_cur_id,
         group_cur_code,
         group_qty_unit_id,
         group_qty_unit,
         base_qty_unit_id,
         base_qty_unit,
         prev_item_qty,
         prev_qty_unit_id,
         cont_unr_status,
         unfxd_qty,
         fxd_qty,
         qty_in_base_unit,
         eod_trade_date,
         strategy_id,
         strategy_name,
         derivative_def_id,
         valuation_exchange_id,
         valuation_dr_id,
         valuation_dr_id_name,
         valuation_month,
         price_month,
         pay_in_cur_id,
         pay_in_cur_code,
         unreal_pnl_in_base_per_unit,
         unreal_pnl_in_val_cur_per_unit,
         realized_internal_stock_ref_no,
         sales_internal_gmr_ref_no,
         sales_gmr_ref_no,
         price_to_base_fw_exch_rate,
         internal_stock_ref_no)
      values
        (pc_corporate_id,
         cur_not_fixed_rows.corporate_name,
         pc_process_id,
         cur_not_fixed_rows.pcdi_id,
         cur_not_fixed_rows.delivery_item_no,
         null, -- prefix
         null, -- middle_no
         null, -- suffix
         cur_not_fixed_rows.internal_contract_ref_no,
         cur_not_fixed_rows.contract_ref_no,
         cur_not_fixed_rows.contract_issue_date,
         cur_not_fixed_rows.internal_contract_item_ref_no,
         null, --basis_type
         null, --delivery_period_type
         null, --delivery_from_month
         null, --delivery_from_year
         null, --delivery_to_month
         null, --delivery_to_year
         null, --delivery_from_date
         null, --delivery_to_date
         null, --transit_days
         cur_not_fixed_rows.contract_type,
         null, --approval_status
         cur_not_fixed_rows.unrealized_type,
         cur_not_fixed_rows.profit_center_id,
         cur_not_fixed_rows.profit_center_name,
         cur_not_fixed_rows.profit_center_short_name,
         cur_not_fixed_rows.cp_id,
         cur_not_fixed_rows.cp_name,
         cur_not_fixed_rows.trade_user_id,
         cur_not_fixed_rows.trade_user_name,
         cur_not_fixed_rows.product_id,
         cur_not_fixed_rows.product_name,
         cur_not_fixed_rows.item_qty,
         cur_not_fixed_rows.qty_unit_id,
         cur_not_fixed_rows.qty_unit,
         cur_not_fixed_rows.quality_id,
         cur_not_fixed_rows.quality_name,
         cur_not_fixed_rows.product_desc,
         cur_not_fixed_rows.price_type_id,
         cur_not_fixed_rows.price_type_name,
         null, -- price_string
         null, -- item_delivery_period_string
         null, -- fixation_method
         null, -- price_fixation_status
         cur_not_fixed_rows.incoterm_id,
         cur_not_fixed_rows.incoterm,
         cur_not_fixed_rows.origination_city_id,
         cur_not_fixed_rows.origination_city_name,
         cur_not_fixed_rows.origination_country_id,
         cur_not_fixed_rows.origination_country_name,
         cur_not_fixed_rows.destination_city_id,
         cur_not_fixed_rows.destination_city_name,
         cur_not_fixed_rows.destination_country_id,
         cur_not_fixed_rows.destination_country_name,
         null, --origination_region_id
         null, --origination_region
         null, --destination_region_id
         null, --destination_region
         cur_not_fixed_rows.payment_term_id,
         cur_not_fixed_rows.payment_term,
         cur_not_fixed_rows.price_fixation_details,
         cur_not_fixed_rows.contract_price,
         cur_not_fixed_rows.price_unit_id,
         cur_not_fixed_rows.price_unit_cur_id,
         cur_not_fixed_rows.price_unit_cur_code,
         cur_not_fixed_rows.price_unit_weight_unit_id,
         cur_not_fixed_rows.price_unit_weight,
         cur_not_fixed_rows.price_unit_weight_unit,
         null, -- net_m2m_price
         null, -- m2m_price_unit_id
         null, -- m2m_price_cur_id
         null, -- m2m_price_cur_code
         null, -- m2m_price_weight
         null, -- m2m_price_weght_unit_id
         null, -- m2m_price_weight_unit
         vn_contract_value_in_price_cur, --contract_value_in_price_cur
         vn_contract_value_in_base_cur, --contract_value_in_val_cur
         cur_not_fixed_rows.price_unit_cur_id,
         cur_not_fixed_rows.price_unit_cur_code,
         null, --valualtion_cur_id
         null, --valualtion_cur_code
         null, --m2m_amt
         null, --2m_amt_cur_id
         null, --m2m_amt_cur_code
         null, --sc_in_valuation_cur
         null, --sc_in_base_cur
         null, --contract_premium_value
         null, --premium_cur_id
         null, -- premium_cur_code
         null, --expected_cog_net_sale_value
         vn_pnl_in_base_cur, -- unrealized_pnl_in_val_cur
         vn_pnl_in_base_cur, -- unrealized_pnl_in_base_cur
         vn_prev_unr_pnl, -- prev_day_unr_pnl_in_val_cur
         vn_prev_unr_pnl, -- prev_day_unr_pnl_in_base_cur
         vn_trade_day_pnl, -- trade_day_pnl_in_val_cur
         vn_trade_day_pnl, -- trade_day_pnl_in_base_cur
         cur_not_fixed_rows.base_cur_id,
         cur_not_fixed_rows.base_cur_code,
         null, -- expected_cog_in_val_cur
         null, -- price_cur_to_val_cur_fx_rate
         null, -- price_cur_to_base_cur_fx_rate
         null, -- base_cur_to_val_cur_fx_rate
         null, -- val_to_base_corp_fx_rate
         null, -- spot_rate_val_cur_to_base_cur
         null, -- unrealized_pnl_in_m2m_price_id
         null, -- prev_unr_pnl_in_m2m_price_id
         null, -- trade_day_pnl_in_m2m_price_id
         cur_not_fixed_rows.realized_date,
         cur_not_fixed_rows.realized_price,
         cur_not_fixed_rows.realized_price_id,
         cur_not_fixed_rows.realized_price_cur_id,
         cur_not_fixed_rows.realized_price_cur_code,
         cur_not_fixed_rows.realized_price_weight,
         cur_not_fixed_rows.realized_price_weight_unit,
         cur_not_fixed_rows.realized_qty,
         cur_not_fixed_rows.realized_qty_unit_id,
         cur_not_fixed_rows.realized_qty_unit_id, -- realized_qty_unit,
         null, -- md_id
         cur_not_fixed_rows.group_id,
         cur_not_fixed_rows.group_name,
         cur_not_fixed_rows.group_cur_id,
         cur_not_fixed_rows.group_cur_code,
         cur_not_fixed_rows.group_qty_unit_id,
         cur_not_fixed_rows.group_qty_unit,
         cur_not_fixed_rows.base_qty_unit_id,
         cur_not_fixed_rows.base_qty_unit,
         null, -- prev_item_qty
         null, -- prev_qty_unit_id
         null, -- cont_unr_status 
         null, -- unfxd_qty
         null, -- fxd_qty
         cur_not_fixed_rows.qty_in_base_unit, -- qty_in_base_unit
         pd_trade_date, --eod_trade_date,
         cur_not_fixed_rows.strategy_id,
         cur_not_fixed_rows.strategy_name,
         null, --derivative_def_id
         null, --valuation_exchange_id
         null, --valuation_dr_id
         null, --valuation_dr_id_name
         null, --valuation_month
         null, --price_month
         null, --pay_in_cur_id
         null, --pay_in_cur_code
         vn_unreal_pnl_in_base_per_unit, --unreal_pnl_in_base_per_unit
         vn_unreal_pnl_in_base_per_unit, --unreal_pnl_in_val_cur_per_unit
         cur_not_fixed_rows.internal_grd_ref_no, --realized_internal_stock_ref_no
         cur_not_fixed_rows.sales_internal_gmr_ref_no,
         cur_not_fixed_rows.sales_gmr_ref_no,
         vc_price_to_base_fw_rate,
         cur_not_fixed_rows.internal_stock_ref_no);
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_realized_not_fixed Realized Today',
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
end; 
/
