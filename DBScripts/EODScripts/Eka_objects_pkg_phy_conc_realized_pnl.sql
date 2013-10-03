create or replace package pkg_phy_conc_realized_pnl is
  procedure sp_calc_phy_conc_realize_today(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_dbd_id       varchar2,
                                           pc_user_id      varchar2,
                                           pc_process      varchar2);
  procedure sp_calc_phy_conc_reverse_rlzed(pc_corporate_id        varchar2,
                                           pd_trade_date          date,
                                           pc_process_id          varchar2,
                                           pc_previous_process_id varchar2,
                                           pc_user_id             varchar2,
                                           pc_process             varchar2);
  procedure sp_calc_conc_rlzed_not_fixed(pc_corporate_id        varchar2,
                                         pd_trade_date          date,
                                         pc_process_id          varchar2,
                                         pc_previous_process_id varchar2,
                                         pc_user_id             varchar2,
                                         pc_process             varchar2);
  procedure sp_calc_phy_conc_pnl_change(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process      varchar2,
                                        pc_process_id   varchar2,
                                        pc_dbd_id       varchar2,
                                        pc_user_id      varchar2);

end;
/
create or replace package body pkg_phy_conc_realized_pnl is
  procedure sp_calc_phy_conc_realize_today(pc_corporate_id varchar2,
                                           pd_trade_date   date,
                                           pc_process_id   varchar2,
                                           pc_dbd_id       varchar2,
                                           pc_user_id      varchar2,
                                           pc_process      varchar2) is
    vn_dry_qty                     number;
    vn_wet_qty                     number;
    vn_dry_qty_in_base             number;
    vn_ele_qty_in_base             number;
    vn_contract_value_in_price_cur number;
    vn_contract_value_in_base_cur  number;
    vn_price_to_base_fw_rate       number;
    vn_forward_points              number;
    vc_price_to_base_fw_rate       varchar2(25);
    vn_con_treatment_charge        number;
    vc_con_treatment_cur_id        varchar2(15);
    vn_base_con_treatment_charge   number;
    vn_con_refine_charge           number;
    vc_con_refine_cur_id           varchar2(15);
    vn_base_con_refine_charge      number;
    vc_con_tc_main_cur_id          varchar2(15);
    vc_con_tc_main_cur_code        varchar2(15);
    vc_con_tc_main_cur_factor      number;
    vn_con_tc_to_base_fw_rate      number;
    vc_contract_tc_fw_exch_rate    varchar2(50);
    vc_con_rc_main_cur_id          varchar2(15);
    vc_con_rc_main_cur_code        varchar2(15);
    vc_con_rc_main_cur_factor      number;
    vn_con_rc_to_base_fw_rate      number;
    vc_contract_rc_fw_exch_rate    varchar2(50);
    vn_con_penality_charge         number;
    vn_base_con_penality_charge    number;
    vc_con_penality_cur_id         varchar2(15);
    vc_con_pc_main_cur_id          varchar2(15);
    vc_con_pc_main_cur_code        varchar2(15);
    vn_con_pc_main_cur_factor      number;
    vn_con_pc_to_base_fw_rate      number;
    vc_contract_pc_fw_exch_rate    varchar2(50);
    vn_tc_charges_per_unit         number;
    vn_rc_charges_per_unit         number;
    vn_pc_charges_per_unit         number;
    vc_del_premium_main_cur_id     varchar2(15);
    vc_del_premium_main_cur_code   varchar2(15);
    vn_del_premium_cur_main_factor number;
    vn_fw_exch_rate_del_to_base    number;
    vc_contract_pp_fw_exch_rate    varchar2(100);
    vn_location_premium_per_unit   number;
    vn_location_premium            number;
    vc_del_premium_cur_id          varchar2(15);
    vn_del_premium_weight          number;
    vc_del_premium_weight_unit_id  varchar2(15);
    vn_dummy                       number;
  
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
             aml.attribute_id element_id,
             aml.attribute_name element_name,
             dense_rank() over(partition by pci.internal_contract_item_ref_no order by aml.attribute_id) ele_rank,
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
             cipde.price_fixation_details price_fixation_details,
             cipde.price_fixation_status price_fixation_status,
             'Realized Today' realized_type,
             agh.realized_date realized_date,
             dgrd.container_no,
             dgrd.current_qty item_qty,
             dgrd.net_weight_unit_id qty_unit_id,
             qum_dgrd.qty_unit,
             nvl(gpd.contract_price, cipde.contract_price) contract_price,
             nvl(gpd.price_unit_id, cipde.price_unit_id) price_unit_id,
             nvl(gpd.price_unit_cur_id, cipde.price_unit_cur_id) price_unit_cur_id,
             nvl(gpd.price_unit_cur_code, cipde.price_unit_cur_code) price_unit_cur_code,
             nvl(gpd.price_unit_weight_unit_id,
                 cipde.price_unit_weight_unit_id) price_unit_weight_unit_id,
             nvl(gpd.price_unit_weight_unit, cipde.price_unit_weight_unit) price_unit_weight_unit,
             nvl(gpd.price_unit_weight, cipde.price_unit_weight) price_unit_weight,
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
             pci.price_description,
             pcdi.delivery_item_no,
             pd_trade_date payment_due_date,
             null accrual_to_base_fw_exch_rate,
             gscs.fw_rate_string sales_sc_exch_rate_string,
             null price_to_base_fw_exch_rate_act,
             null price_to_base_fw_exch_rate,
             gmr.latest_internal_invoice_ref_no,
             gmr.gmr_ref_no sales_gmr_ref_no,
             pcpq.unit_of_measure,
             gmr_qty.payable_qty,
             gmr_qty.qty_unit_id payable_qty_unit_id,
             pdm_qum.decimals base_qty_decimals,
             sam.ash_id assay_header_id,
             cm.decimals base_cur_decimal,
             null rc_charges_per_unit,
             null total_rc_charges,
             null pc_charges_per_unit,
             null total_pc_charges,
             null tc_to_base_fw_exch_rate,
             null rc_to_base_fw_exch_rate,
             null pc_to_base_fw_exch_rate,
             null total_mc_charges,
             pdm_under.product_id underlying_product_id,
             pdm_under.base_quantity_unit underlying_product_qty_unit,
             qum_under.decimals as under_base_qty_unit_id,
             qum_payable.qty_unit payable_qty_unit,
             pcdb.premium location_premium_per_unit,
             pcdb.premium_unit_id location_premium_unit_id,
             null location_premium_fw_exch_rate
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
             cipde_cipd_element_price           cipde,
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
             gpd_gmr_conc_price_daily           gpd,
             aml_attribute_master_list          aml,
             v_gmr_stockpayable_qty             gmr_qty,
             qum_quantity_unit_master           pdm_qum,
             sam_stock_assay_mapping            sam,
             cm_currency_master                 cm,
             pdm_productmaster                  pdm_under,
             qum_quantity_unit_master           qum_under,
             qum_quantity_unit_master           qum_payable
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
         and pcm.contract_type = 'CONCENTRATES'
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
             cipde.internal_contract_item_ref_no
         and agh.process_id = cipde.process_id
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
         and gmr_qty.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr_qty.process_id = gpd.process_id(+)
         and gmr_qty.element_id = gpd.element_id(+)
         and cipde.element_id = aml.attribute_id
         and gmr_qty.process_id = pc_process_id
         and gmr_qty.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr_qty.element_id = aml.attribute_id
         and pdm_qum.qty_unit_id = pdm.base_quantity_unit
         and dgrd.internal_dgrd_ref_no = sam.internal_dgrd_ref_no
         and sam.is_latest_position_assay = 'Y'
         and akc.base_cur_id = cm.cur_id
         and aml.underlying_product_id = pdm_under.product_id
         and pdm_under.base_quantity_unit = qum_under.qty_unit_id
         and gmr_qty.qty_unit_id = qum_payable.qty_unit_id
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
             aml.attribute_id element_id,
             aml.attribute_name element_name,
             dense_rank() over(partition by pci.internal_contract_item_ref_no order by aml.attribute_id) ele_rank,
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
             invme.mc_per_unit contract_price,
             invme.mc_price_unit_id price_unit_id,
             invme.mc_price_unit_cur_id price_unit_cur_id,
             invme.mc_price_unit_cur_code price_unit_cur_code,
             invme.mc_price_unit_weight_unit_id price_unit_weight_unit_id,
             invme.mc_price_unit_weight_unit price_unit_weight_unit,
             invme.mc_price_unit_weight price_unit_weight,
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
             pci.price_description,
             pcdi.delivery_item_no,
             pd_trade_date payment_due_date,
             invs.accrual_to_base_fw_exch_rate,
             null sales_sc_exch_rate_string,
             invs.price_to_base_fw_exch_rate_act,
             invs.price_to_base_fw_exch_rate,
             gmr.latest_internal_invoice_ref_no,
             gmr_sales.gmr_ref_no,
             pcpq.unit_of_measure,
             invme.payable_qty *
             (agd.qty / (grd.qty * ucm.multiplication_factor)) payable_qty, -- Convert stock to realized qty 
             invme.payable_qty_unit_id payable_qty_unit_id,
             pdm_qum.decimals base_qty_decimals,
             sam.ash_id assay_header_id,
             cm.decimals base_cur_decimal,
             invs.rc_charges_per_unit,
             invs.total_rc_charges,
             invs.pc_charges_per_unit,
             invs.total_pc_charges,
             invs.tc_to_base_fw_exch_rate,
             invs.pc_to_base_fw_exch_rate,
             invs.pc_to_base_fw_exch_rate,
             invs.total_mc_charges,
             pdm_under.product_id underlying_product_id,
             pdm_under.base_quantity_unit underlying_product_qty_unit,
             qum_under.decimals as under_base_qty_unit_id,
             qum_payable.qty_unit payable_qty_unit,
             invs.product_premium_per_unit location_premium_per_unit,
             invs.price_unit_id location_premium_price_unit_id,
             invs.contract_pp_fw_exch_rate location_premium_fw_exch_rate
        from agh_alloc_group_header       agh,
             agd_alloc_group_detail       agd,
             grd_goods_record_detail      grd,
             pci_physical_contract_item   pci,
             pcdi_pc_delivery_item        pcdi,
             pcm_physical_contract_main   pcm,
             ak_corporate                 akc,
             gmr_goods_movement_record    gmr,
             pdm_productmaster            pdm,
             qat_quality_attributes       qat,
             pom_product_origin_master    pom,
             orm_origin_master            orm,
             pcpd_pc_product_definition   pcpd,
             cpc_corporate_profit_center  cpc,
             phd_profileheaderdetails     phd_cp,
             ak_corporate_user            akcu,
             gab_globaladdressbook        gab,
             pcdb_pc_delivery_basis       pcdb,
             itm_incoterm_master          itm,
             pym_payment_terms_master     pym,
             qum_quantity_unit_master     qum_agd,
             phd_profileheaderdetails     phd_wh,
             sld_storage_location_detail  sld,
             cim_citymaster               cim_sld,
             gcd_groupcorporatedetails    gcd,
             cm_currency_master           cm_gcd,
             qum_quantity_unit_master     qum_gcd,
             qum_quantity_unit_master     qum_pdm,
             cym_countrymaster            cym_gmr_dest,
             cim_citymaster               cim_gmr_dest,
             invm_cogs                    invs,
             dgrd_delivered_grd           dgrd,
             pci_physical_contract_item   pci_sales,
             pcdi_pc_delivery_item        pcdi_sales,
             pcm_physical_contract_main   pcm_sales,
             pt_price_type                pt,
             css_corporate_strategy_setup css,
             gmr_goods_movement_record    gmr_sales,
             invme_cogs_element           invme,
             aml_attribute_master_list    aml,
             pcpq_pc_product_quality      pcpq,
             -- v_gmr_stockpayable_qty       gmr_qty,
             qum_quantity_unit_master   pdm_qum,
             sam_stock_assay_mapping    sam,
             cm_currency_master         cm,
             pdm_productmaster          pdm_under,
             qum_quantity_unit_master   qum_under,
             qum_quantity_unit_master   qum_payable,
             ucm_unit_conversion_master ucm
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
         and pcm.contract_type = 'CONCENTRATES'
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
         and dgrd.process_id = agh.process_id
         and dgrd.status = 'Active'
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
         and invme.process_id = pc_process_id
         and invme.internal_grd_ref_no = grd.internal_grd_ref_no
         and invme.element_id = aml.attribute_id
         and invme.sales_internal_gmr_ref_no = dgrd.internal_gmr_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcpq.process_id = pc_process_id
         and invme.element_id = aml.attribute_id
         and invme.internal_grd_ref_no = grd.internal_grd_ref_no
         and pdm_qum.qty_unit_id = pdm.base_quantity_unit
         and grd.internal_grd_ref_no = sam.internal_grd_ref_no
         and sam.is_latest_position_assay = 'Y'
         and akc.base_cur_id = cm.cur_id
         and pdm_under.product_id = aml.underlying_product_id
         and pdm_under.base_quantity_unit = qum_under.qty_unit_id
         and invme.payable_qty_unit_id = qum_payable.qty_unit_id
         and gmr_sales.process_id = pc_process_id
         and ucm.from_qty_unit_id = grd.qty_unit_id
         and ucm.to_qty_unit_id = agd.qty_unit_id
         and ucm.is_active = 'Y';
  
    cursor cur_update_pnl is
      select prch.corporate_id,
             prch.sales_internal_gmr_ref_no,
             prch.process_id,
             prch.int_alloc_group_id,
             nvl(sum(prch.cog_net_sale_value), 0) net_value
        from prch_phy_realized_conc_header prch
       where prch.process_id = pc_process_id
         and prch.corporate_id = pc_corporate_id
         and prch.realized_type = 'Realized Today'
       group by prch.corporate_id,
                prch.sales_internal_gmr_ref_no,
                prch.process_id,
                prch.int_alloc_group_id;
  
    vobj_error_log               tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count           number := 1;
    vc_error_msg                 varchar2(10);
    vn_contract_price            number;
    vc_price_unit_id             varchar2(15);
    vc_price_unit_cur_id         varchar2(15);
    vc_price_unit_cur_code       varchar2(15);
    vc_price_unit_weight_unit_id varchar2(15);
    vc_price_unit_weight_unit    varchar2(15);
    vn_price_unit_weight         number;
    vc_sc_to_base_fw_exch_rate   varchar2(50);
    vc_base_price_unit_id        varchar2(15);
    vc_base_price_unit_name      varchar2(15);
    vc_price_cur_id              varchar2(15);
    vc_price_cur_code            varchar2(15);
    vn_cont_price_cur_id_factor  number;
    vn_cont_price_cur_decimals   number;
    vn_qty_in_base_qty_unit_id   number;
    vn_sc_in_base_cur            number;
    vn_sc_per_unit               number;
  
  begin
    for cur_realized_rows in cur_realized
    loop
      vc_price_to_base_fw_rate     := null;
      vc_contract_tc_fw_exch_rate  := null;
      vc_contract_rc_fw_exch_rate  := null;
      vc_contract_pc_fw_exch_rate  := null;
      vc_contract_pp_fw_exch_rate  := null;
      vn_location_premium_per_unit := 0;
      vn_location_premium          := 0;
      if cur_realized_rows.contract_type = 'S' then
        if cur_realized_rows.latest_internal_invoice_ref_no is null then
          vc_error_msg                 := '590';
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
          vc_error_msg := '605';
        
          begin
            select iied.element_payable_price,
                   iied.element_payable_price_unit_id,
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
              from iid_invoicable_item_details   iid,
                   iied_inv_item_element_details iied,
                   v_ppu_pum                     ppu,
                   cm_currency_master            cm,
                   qum_quantity_unit_master      qum
             where iid.internal_invoice_ref_no =
                   cur_realized_rows.latest_internal_invoice_ref_no
               and iied.element_payable_price_unit_id =
                   ppu.product_price_unit_id
               and ppu.cur_id = cm.cur_id
               and ppu.weight_unit_id = qum.qty_unit_id
               and iid.internal_gmr_ref_no =
                   cur_realized_rows.internal_gmr_ref_no
               and iid.internal_invoice_ref_no =
                   iied.internal_invoice_ref_no
               and iied.element_id = cur_realized_rows.element_id
               and iied.grd_id = iid.stock_id
               and iid.stock_id = cur_realized_rows.internal_grd_ref_no
               and rownum < 2; -- Because IIED data at sub lots with same price, different quantity
          exception
            when others then
              vc_error_msg := '639';
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
      vc_error_msg := '661';
      if cur_realized_rows.contract_type = 'P' then
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
      pkg_general.sp_get_main_cur_detail(vc_price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
    
      vc_error_msg := '702';
    
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
      -- Calcualte the Location Premium
      if cur_realized_rows.contract_type = 'P' then
        vn_location_premium := vn_qty_in_base_qty_unit_id *
                               cur_realized_rows.location_premium_per_unit;
      
        vc_contract_pp_fw_exch_rate := cur_realized_rows.location_premium_fw_exch_rate;
      else
        --Sales Get Currency and Weight Details
        if cur_realized_rows.location_premium_per_unit <> 0 then
          if cur_realized_rows.location_premium_unit_id <>
             vc_base_price_unit_id then
            begin
              select ppu.cur_id,
                     nvl(ppu.weight, 1),
                     ppu.weight_unit_id
                into vc_del_premium_cur_id,
                     vn_del_premium_weight,
                     vc_del_premium_weight_unit_id
                from v_ppu_pum ppu
               where ppu.product_price_unit_id =
                     cur_realized_rows.location_premium_unit_id;
            exception
              when others then
                null;
            end;
            --
            -- Get the Main Currency of the Delivery Premium Price Unit
            --
            pkg_general.sp_get_base_cur_detail(vc_del_premium_cur_id,
                                               vc_del_premium_main_cur_id,
                                               vc_del_premium_main_cur_code,
                                               vn_del_premium_cur_main_factor);
            pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                        pd_trade_date,
                                        cur_realized_rows.payment_due_date,
                                        vc_del_premium_main_cur_id,
                                        cur_realized_rows.base_cur_id,
                                        30,
                                        'Sp_calc_phy_conc_realized_today Delivery Premium to Base',
                                        pc_process,
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
          
            vn_location_premium_per_unit := (cur_realized_rows.location_premium_per_unit /
                                            vn_del_premium_weight) *
                                            vn_del_premium_cur_main_factor *
                                            vn_fw_exch_rate_del_to_base *
                                            pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                                 vc_del_premium_weight_unit_id,
                                                                                 cur_realized_rows.base_qty_unit_id,
                                                                                 1);
          
          else
            vn_location_premium_per_unit := cur_realized_rows.location_premium_per_unit;
          end if;
          vn_location_premium := round(vn_location_premium_per_unit *
                                       vn_qty_in_base_qty_unit_id,
                                       2);
        else
          vn_location_premium_per_unit := 0;
          vn_location_premium          := 0;
        end if;
      end if;
      --
      -- Total Secondary Cost Value = Avg Seconadry Cost * Realized Qty in Product Base Unit
      --
      if cur_realized_rows.ele_rank = 1 then
        vn_sc_in_base_cur := cur_realized_rows.secondary_cost_per_unit *
                             vn_qty_in_base_qty_unit_id;
      
        vn_sc_per_unit := cur_realized_rows.secondary_cost_per_unit;
      end if;
      vc_error_msg := '727';
      if cur_realized_rows.unit_of_measure = 'Wet' then
        vn_dry_qty := round(pkg_metals_general.fn_get_assay_dry_qty(cur_realized_rows.product_id,
                                                                    cur_realized_rows.assay_header_id,
                                                                    cur_realized_rows.item_qty,
                                                                    cur_realized_rows.qty_unit_id),
                            cur_realized_rows.base_qty_decimals);
      else
        vn_dry_qty := cur_realized_rows.item_qty;
      end if;
    
      vn_wet_qty := cur_realized_rows.item_qty;
      --
      -- Convert into dry qty to base qty element level
      --
      vc_error_msg := '742';
      if cur_realized_rows.qty_unit_id <>
         cur_realized_rows.base_qty_unit_id then
        vn_dry_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                         cur_realized_rows.qty_unit_id,
                                                                         cur_realized_rows.base_qty_unit_id,
                                                                         1) *
                                    vn_dry_qty,
                                    cur_realized_rows.base_qty_decimals);
      else
        vn_dry_qty_in_base := round(vn_dry_qty,
                                    cur_realized_rows.base_qty_decimals);
      
      end if;
      vc_error_msg := '756';
      if cur_realized_rows.payable_qty_unit_id <>
         cur_realized_rows.underlying_product_qty_unit then
        vn_ele_qty_in_base := pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                   cur_realized_rows.payable_qty_unit_id,
                                                                   cur_realized_rows.underlying_product_qty_unit,
                                                                   1) *
                             
                              cur_realized_rows.payable_qty;
      else
        vn_ele_qty_in_base := cur_realized_rows.payable_qty;
      end if;
      vc_error_msg := '769';
      -- Get the payable element value in base currency
      vn_contract_value_in_price_cur := round((vn_contract_price /
                                              nvl(vn_price_unit_weight, 1)) *
                                              cur_realized_rows.payable_qty *
                                              vn_cont_price_cur_id_factor *
                                              pkg_general.f_get_converted_quantity(cur_realized_rows.underlying_product_id,
                                                                                   cur_realized_rows.payable_qty_unit_id,
                                                                                   cur_realized_rows.price_unit_weight_unit_id,
                                                                                   1),
                                              cur_realized_rows.base_cur_decimal);
      vc_error_msg                   := '777';
      if vc_price_cur_id <> cur_realized_rows.base_cur_id then
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    pd_trade_date,
                                    vc_price_cur_id,
                                    cur_realized_rows.base_cur_id,
                                    30,
                                    'Concentrate Realized PNL',
                                    pc_process,
                                    vn_price_to_base_fw_rate,
                                    vn_forward_points);
      
      else
        vn_price_to_base_fw_rate := 1;
      end if;
      vn_contract_value_in_base_cur := vn_contract_value_in_price_cur *
                                       vn_price_to_base_fw_rate;
    
      vn_contract_value_in_base_cur := round(vn_contract_value_in_base_cur,
                                             cur_realized_rows.base_cur_decimal);
      --
      -- Calcualte the TC, RC and Penalty
      --
      -- contract treatment charges
      --
      vc_error_msg := '799';
    
      begin
        select round((case
                       when getc.weight_type = 'Dry' then
                        vn_dry_qty * ucm.multiplication_factor * getc.tc_value
                       else
                        vn_wet_qty * ucm.multiplication_factor * getc.tc_value
                     end),
                     2) * getc.currency_factor,
               getc.tc_main_cur_id
          into vn_con_treatment_charge,
               vc_con_treatment_cur_id
          from getc_gmr_element_tc_charges getc,
               ucm_unit_conversion_master  ucm
         where getc.process_id = pc_process_id
           and getc.internal_gmr_ref_no =
               cur_realized_rows.internal_gmr_ref_no
           and getc.internal_grd_ref_no =
               cur_realized_rows.internal_grd_ref_no
           and getc.element_id = cur_realized_rows.element_id
           and ucm.from_qty_unit_id = cur_realized_rows.qty_unit_id
           and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
      exception
        when others then
          vn_con_treatment_charge := 0;
          vc_con_treatment_cur_id := null;
      end;
    
      vn_con_treatment_charge := vn_con_treatment_charge;
      -- Converted treatment charges to base currency
      if vc_con_treatment_cur_id <> cur_realized_rows.base_cur_id then
        -- Bank FX Rate from TC to Base Currency
        pkg_general.sp_get_base_cur_detail(vc_con_treatment_cur_id,
                                           vc_con_tc_main_cur_id,
                                           vc_con_tc_main_cur_code,
                                           vc_con_tc_main_cur_factor);
      
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    cur_realized_rows.payment_due_date,
                                    vc_con_tc_main_cur_id,
                                    cur_realized_rows.base_cur_id,
                                    30,
                                    'sp_phy_conc_realized_pnl Contract TC to Base Currency',
                                    pc_process,
                                    vn_con_tc_to_base_fw_rate,
                                    vn_forward_points);
      
        vn_base_con_treatment_charge := round((vn_con_treatment_charge *
                                              vn_con_tc_to_base_fw_rate *
                                              vc_con_tc_main_cur_factor),
                                              cur_realized_rows.base_cur_decimal);
        vc_contract_tc_fw_exch_rate  := '1 ' || vc_con_tc_main_cur_code || '=' ||
                                        vn_con_tc_to_base_fw_rate || ' ' ||
                                        cur_realized_rows.base_cur_code;
      else
        vn_base_con_treatment_charge := round(vn_con_treatment_charge,
                                              cur_realized_rows.base_cur_decimal);
      
      end if;
    
      vc_error_msg := '852';
      --
      --- Contract Refine Charges
      --
      begin
        select round(gerc.rc_value * ucm.multiplication_factor *
                     cur_realized_rows.payable_qty,
                     2) * gerc.currency_factor,
               gerc.rc_main_cur_id
          into vn_con_refine_charge,
               vc_con_refine_cur_id
          from gerc_gmr_element_rc_charges gerc,
               ucm_unit_conversion_master  ucm
         where gerc.process_id = pc_process_id
           and gerc.internal_gmr_ref_no =
               cur_realized_rows.internal_gmr_ref_no
           and gerc.internal_grd_ref_no =
               cur_realized_rows.internal_grd_ref_no
           and gerc.element_id = cur_realized_rows.element_id
           and ucm.from_qty_unit_id = cur_realized_rows.payable_qty_unit_id
           and ucm.to_qty_unit_id = gerc.rc_weight_unit_id;
      exception
        when others then
          vn_con_refine_charge := 0;
          vc_con_refine_cur_id := null;
      end;
    
      vn_con_refine_charge := vn_con_refine_charge;
    
      --- Converted Refine Charges To Base Currency                                              
      if vc_con_refine_cur_id <> cur_realized_rows.base_cur_id then
        pkg_general.sp_get_base_cur_detail(vc_con_refine_cur_id,
                                           vc_con_rc_main_cur_id,
                                           vc_con_rc_main_cur_code,
                                           vc_con_rc_main_cur_factor);
      
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    cur_realized_rows.payment_due_date,
                                    vc_con_refine_cur_id,
                                    cur_realized_rows.base_cur_id,
                                    30,
                                    'sp_phy_conc_realized_pnl Contract RC to Base Currency',
                                    pc_process,
                                    vn_con_rc_to_base_fw_rate,
                                    vn_forward_points);
      
        vn_base_con_refine_charge := round((vn_con_refine_charge *
                                           vn_con_rc_to_base_fw_rate *
                                           vc_con_rc_main_cur_factor),
                                           cur_realized_rows.base_cur_decimal);
      
        vc_contract_rc_fw_exch_rate := '1 ' || vc_con_rc_main_cur_code || '=' ||
                                       vn_con_rc_to_base_fw_rate || ' ' ||
                                       cur_realized_rows.base_cur_code;
      
      else
        vn_base_con_refine_charge := round(vn_con_refine_charge,
                                           cur_realized_rows.base_cur_decimal);
      end if;
    
      vc_error_msg := '906';
    
      -- Contract penalty
    
      if cur_realized_rows.ele_rank = 1 then
        vc_error_msg := '911';
        vc_error_msg := '913';
      
        begin
          select round(sum(case
                             when gepc.weight_type = 'Dry' then
                              vn_dry_qty * ucm.multiplication_factor * gepc.pc_value
                             else
                              vn_wet_qty * ucm.multiplication_factor * gepc.pc_value
                           end),
                       2) * gepc.currency_factor,
                 gepc.pc_main_cur_id
            into vn_con_penality_charge,
                 vc_con_penality_cur_id
            from gepc_gmr_element_pc_charges gepc,
                 ucm_unit_conversion_master  ucm
           where gepc.process_id = pc_process_id
             and gepc.internal_gmr_ref_no =
                 cur_realized_rows.internal_gmr_ref_no
             and gepc.internal_grd_ref_no =
                 cur_realized_rows.internal_grd_ref_no
             and ucm.from_qty_unit_id = cur_realized_rows.qty_unit_id
             and ucm.to_qty_unit_id = gepc.pc_weight_unit_id
           group by gepc.pc_main_cur_id,
                    gepc.currency_factor;
        exception
          when others then
            vn_con_penality_charge := 0;
            vc_con_penality_cur_id := null;
        end;
      
        -- Convert to Base with Bank FX Rate
        vc_error_msg           := '914';
        vn_con_penality_charge := vn_con_penality_charge;
        if vn_con_penality_charge <> 0 then
          pkg_general.sp_get_base_cur_detail(vc_con_penality_cur_id,
                                             vc_con_pc_main_cur_id,
                                             vc_con_pc_main_cur_code,
                                             vn_con_pc_main_cur_factor);
          if vc_con_pc_main_cur_id <> cur_realized_rows.base_cur_id then
          
            pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                        pd_trade_date,
                                        cur_realized_rows.payment_due_date,
                                        vc_con_pc_main_cur_id,
                                        cur_realized_rows.base_cur_id,
                                        30,
                                        'sp_calc_phy_opencon_unreal_pnl Contract Penalty to Base Currency',
                                        pc_process,
                                        vn_con_pc_to_base_fw_rate,
                                        vn_forward_points);
            vc_error_msg                := '933';
            vn_base_con_penality_charge := round((vn_con_penality_charge *
                                                 vn_con_pc_to_base_fw_rate *
                                                 vn_con_pc_main_cur_factor),
                                                 cur_realized_rows.base_cur_decimal);
          
            vc_contract_pc_fw_exch_rate := '1 ' || vc_con_pc_main_cur_code || '=' ||
                                           vn_con_pc_to_base_fw_rate || ' ' ||
                                           cur_realized_rows.base_cur_code;
          
          else
            vn_base_con_penality_charge := round(vn_con_penality_charge,
                                                 cur_realized_rows.base_cur_decimal);
          
          end if;
        else
          vn_base_con_penality_charge := 0;
        end if;
      end if;
      if cur_realized_rows.ele_rank = 1 then
        insert into prch_phy_realized_conc_header
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
           price_fixation_status,
           realized_type,
           realized_sub_type,
           realized_date,
           container_no,
           item_qty,
           unit_of_measure,
           ash_id,
           dry_qty,
           wet_qty,
           dry_qty_in_base,
           qty_unit_id,
           qty_unit,
           contract_value_in_price_cur,
           contract_invoice_value,
           tc_cost_per_unit,
           tc_cost_value,
           rc_cost_per_unit,
           rc_cost_value,
           pc_cost_per_unit,
           pc_cost_value,
           secondary_cost_per_unit,
           secondary_cost_value,
           cog_net_sale_value,
           realized_pnl,
           prev_real_qty,
           prev_real_qty_id,
           prev_real_qty_unit,
           prev_cont_value_in_price_cur,
           prev_real_contract_value,
           prev_real_secondary_cost,
           prev_real_cog_net_sale_value,
           prev_real_pnl,
           prev_tc_per_unit,
           prev_rc_per_unit,
           prev_pc_per_unit,
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
           sales_gmr_ref_no,
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
           accrual_to_base_fw_exch_rate,
           tc_to_base_fw_exch_rate,
           rc_to_base_fw_exch_rate,
           pc_to_base_fw_exch_rate,
           is_tolling_contract,
           is_tolling_extn,
           location_premium_per_unit,
           location_premium,
           location_premium_fw_exch_rate)
        values
          (pc_process_id,
           pd_trade_date,
           pc_corporate_id,
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
           null, -- 'v_price_fixation_details',
           cur_realized_rows.realized_type,
           null, --'v_realized_sub_type',
           cur_realized_rows.realized_date,
           cur_realized_rows.container_no,
           cur_realized_rows.item_qty,
           cur_realized_rows.unit_of_measure,
           cur_realized_rows.assay_header_id,
           vn_dry_qty,
           vn_wet_qty,
           vn_dry_qty_in_base,
           cur_realized_rows.qty_unit_id,
           cur_realized_rows.qty_unit,
           vn_contract_value_in_price_cur,
           null, -- contract_invoice_value update from pree,
           null, -- vn_tc_charges_per_unit,
           0, --vn_base_con_treatment_charge,
           null, -- vn_rc_charges_per_unit,
           0, --vn_base_con_refine_charge,
           null, -- vn_pc_charges_per_unit,
           vn_base_con_penality_charge,
           vn_sc_per_unit,
           vn_sc_in_base_cur,
           null, --'v_cog_net_sale_value',
           null, --realized_pnl,
           null, --prev_real_qty,
           null, --prev_real_qty_id,
           null, --prev_real_qty_unit,
           null, --prev_cont_value_in_price_cur,
           null, --prev_real_contract_value,
           null, --prev_real_secondary_cost,
           null, --prev_real_cog_net_sale_value,
           null, --prev_real_pnl,
           null, --prev_tc_per_unit,
           null, --prev_rc_per_unit,
           null, --prev_pc_per_unit,
           null, --prev_secondary_cost_per_unit,
           null, --change_in_pnl,
           null, --'v_cfx_price_cur_to_base_cur',
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
           vc_base_price_unit_id,
           vc_base_price_unit_name,
           cur_realized_rows.sales_profit_center_id,
           cur_realized_rows.sales_profit_center_name,
           cur_realized_rows.sales_profit_center_short_name,
           cur_realized_rows.sales_strategy_id,
           cur_realized_rows.sales_strategy_name,
           cur_realized_rows.sales_business_line_id,
           cur_realized_rows.sales_business_line_name,
           cur_realized_rows.sales_internal_gmr_ref_no,
           cur_realized_rows.sales_gmr_ref_no,
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
           null, -- Agggegate from child and update later
           vc_sc_to_base_fw_exch_rate,
           null, --  vc_contract_tc_fw_exch_rate,
           null, -- vc_contract_rc_fw_exch_rate,
           vc_contract_pc_fw_exch_rate,
           'N', -- is_tolling_contract,
           'N', -- is_tolling_extn
           vn_location_premium_per_unit,
           vn_location_premium,
           vc_contract_pp_fw_exch_rate);
      
      end if;
      insert into prce_phy_realized_conc_element
        (process_id,
         trade_date,
         int_alloc_group_id,
         sales_internal_gmr_ref_no,
         internal_contract_item_ref_no,
         del_distribution_item_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         underlying_product_id,
         underling_prod_qty_unit_id,
         underling_base_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         payable_qty_unit,
         payable_qty_in_base_unit,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         price_unit_weight,
         contract_value_in_price_cur,
         contract_value_in_base_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         price_to_base_fw_exch_rate,
         prev_real_price,
         prev_real_price_id,
         prev_real_price_cur_id,
         prev_real_price_cur_code,
         prev_real_price_weight_unit_id,
         prev_real_price_weight_unit,
         prev_real_price_weight,
         prev_contract_price_cur_id,
         prev_contract_price_cur_code,
         tc_in_base_cur,
         rc_in_base_cur,
         tc_to_base_fw_exch_rate,
         rc_to_base_fw_exch_rate)
      values
        (pc_process_id,
         pd_trade_date,
         cur_realized_rows.int_alloc_group_id,
         cur_realized_rows.sales_internal_gmr_ref_no,
         cur_realized_rows.internal_contract_item_ref_no,
         cur_realized_rows.del_distribution_item_no,
         cur_realized_rows.internal_gmr_ref_no,
         cur_realized_rows.internal_grd_ref_no,
         cur_realized_rows.element_id,
         cur_realized_rows.element_name,
         cur_realized_rows.underlying_product_id,
         cur_realized_rows.underlying_product_qty_unit,
         cur_realized_rows.under_base_qty_unit_id,
         cur_realized_rows.payable_qty,
         cur_realized_rows.payable_qty_unit_id,
         cur_realized_rows.payable_qty_unit,
         vn_ele_qty_in_base,
         vn_contract_price,
         vc_price_unit_id,
         vc_price_unit_cur_id,
         vc_price_unit_cur_code,
         vc_price_unit_weight_unit_id,
         vc_price_unit_weight_unit,
         vn_price_unit_weight,
         vn_contract_value_in_price_cur,
         vn_contract_value_in_base_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_price_to_base_fw_rate,
         null, -- prev_real_price,
         null, -- prev_real_price_id,
         null, -- prev_real_price_cur_id,
         null, -- prev_real_price_cur_code,
         null, -- prev_real_price_weight_unit_id,
         null, -- prev_real_price_weight_unit,
         null, -- prev_real_price_weight,
         null, -- _prev_contract_price_cur_id,
         null, --prev_contract_price_cur_code,
         vn_base_con_treatment_charge,
         vn_base_con_refine_charge,
         vc_contract_tc_fw_exch_rate,
         vc_contract_rc_fw_exch_rate);
    end loop;
    -- Update Contract Value in Header
    update prch_phy_realized_conc_header prch
       set (prch.contract_invoice_value, --
           prch.elment_qty_details, --
           prch.elment_price_details, --
           prch.price_to_base_fw_exch_rate, --
           prch.tc_to_base_fw_exch_rate, --
           prch.rc_to_base_fw_exch_rate, prch.tc_cost_value, prch.rc_cost_value) = --
            (select sum(prce.contract_value_in_base_cur),
                    stragg(prce.element_name || '-' || prce.payable_qty || ' ' ||
                           qum.qty_unit),
                    stragg(prce.element_name || '-' || prce.contract_price || ' ' ||
                           ppu.price_unit_name),
                    stragg(prce.price_to_base_fw_exch_rate),
                    stragg(prce.tc_to_base_fw_exch_rate) tc_to_base_fw_exch_rate,
                    stragg(prce.rc_to_base_fw_exch_rate) rc_to_base_fw_exch_rate,
                    sum(prce.tc_in_base_cur),
                    sum(prce.rc_in_base_cur)
               from prce_phy_realized_conc_element prce,
                    qum_quantity_unit_master       qum,
                    v_ppu_pum                      ppu
              where prce.process_id = pc_process_id
                and prce.internal_contract_item_ref_no =
                    prch.internal_contract_item_ref_no
                and prce.internal_grd_ref_no = prch.internal_grd_ref_no
                and prce.payable_qty_unit_id = qum.qty_unit_id
                and prce.price_unit_id = ppu.product_price_unit_id
                and prch.int_alloc_group_id = prce.int_alloc_group_id
                and prch.process_id = prce.process_id
                and prch.sales_internal_gmr_ref_no =
                    prce.sales_internal_gmr_ref_no)
     where prch.process_id = pc_process_id;
    update prch_phy_realized_conc_header prch
       set prch.cog_net_sale_value = decode(prch.contract_type, 'P', -1, 1) *
                                     (prch.contract_invoice_value -
                                      nvl(prch.tc_cost_value, 0) -
                                      nvl(prch.rc_cost_value, 0) -
                                      nvl(prch.pc_cost_value, 0) +
                                      (decode(prch.contract_type, 'P', 1, -1) *
                                      nvl(abs(prch.secondary_cost_value), 0)) +
                                      nvl(prch.location_premium, 0))
     where prch.process_id = pc_process_id;
  
    for cur_update in (select prd.sales_internal_gmr_ref_no,
                              prd.profit_center_id,
                              prd.profit_center_short_name,
                              prd.profit_center_name,
                              prd.strategy_id,
                              prd.strategy_name,
                              prd.business_line_id,
                              prd.business_line_name
                         from prch_phy_realized_conc_header prd
                        where prd.process_id = pc_process_id
                          and prd.contract_type = 'S')
    loop
      update prch_phy_realized_conc_header prch
         set prch.sales_profit_center_id         = cur_update.profit_center_id,
             prch.sales_profit_center_name       = cur_update.profit_center_name,
             prch.sales_profit_center_short_name = cur_update.profit_center_short_name,
             prch.sales_strategy_id              = cur_update.strategy_id,
             prch.sales_strategy_name            = cur_update.strategy_name,
             prch.sales_business_line_id         = cur_update.business_line_id,
             prch.sales_business_line_name       = cur_update.business_line_name
       where prch.contract_type = 'P'
         and prch.sales_internal_gmr_ref_no = sales_internal_gmr_ref_no
         and prch.process_id = pc_process_id;
    
    end loop;
    --
    -- Update Realized PNL for Sales Contract
    --
    for cur_update_pnl_rows in cur_update_pnl
    loop
    
      dbms_output.put_line('cur_update_pnl_rows.net_value ' ||
                           cur_update_pnl_rows.net_value);
      vn_dummy := cur_update_pnl_rows.net_value;
      update prch_phy_realized_conc_header prch
         set prch.realized_pnl = cur_update_pnl_rows.net_value
       where prch.corporate_id = cur_update_pnl_rows.corporate_id
         and prch.contract_type = 'S'
         and prch.realized_type = 'Realized Today'
         and prch.sales_internal_gmr_ref_no =
             cur_update_pnl_rows.sales_internal_gmr_ref_no
         and prch.int_alloc_group_id =
             cur_update_pnl_rows.int_alloc_group_id
         and prch.process_id = pc_process_id
         and rownum < 2;
    end loop;
    dbms_output.put_line('vn_dummy ' || vn_dummy);
    --
    -- Update Price String from CIPDE
    --   
    for cur_price_string in (select cipde.internal_contract_item_ref_no,
                                    stragg(cipde.price_description) price_description,
                                    stragg(cipde.price_fixation_details) price_fixation_details,
                                    stragg(cipde.price_basis) price_basis,
                                    stragg(cipde.price_fixation_status) price_fixation_status
                               from cipde_cipd_element_price      cipde,
                                    prch_phy_realized_conc_header prch
                              where cipde.process_id = pc_process_id
                                and cipde.internal_contract_item_ref_no =
                                    prch.internal_contract_item_ref_no
                              group by cipde.internal_contract_item_ref_no)
    loop
      update prch_phy_realized_conc_header prch
         set prch.price_description     = cur_price_string.price_description,
             prch.price_fixation_status = cur_price_string.price_fixation_details,
             prch.price_type_id         = cur_price_string.price_basis,
             prch.price_type_name       = cur_price_string.price_basis
       where prch.process_id = pc_process_id
         and prch.internal_contract_item_ref_no =
             cur_price_string.internal_contract_item_ref_no;
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_conc_realize_today ',
                                                           'M2M-013',
                                                           ' Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm || '- ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
    
  end;
  procedure sp_calc_phy_conc_reverse_rlzed(pc_corporate_id        varchar2,
                                           pd_trade_date          date,
                                           pc_process_id          varchar2,
                                           pc_previous_process_id varchar2,
                                           pc_user_id             varchar2,
                                           pc_process             varchar2) is
    vobj_error_log     tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count number := 1;
  
  begin
  
    --
    -- GMRs which are cancelled in this EOD but active in previous EOD
    --
    insert into rgmrc_realized_gmr_conc
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
  
    insert into prch_phy_realized_conc_header
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
       price_fixation_status,
       realized_type,
       realized_sub_type,
       realized_date,
       container_no,
       dry_qty,
       wet_qty,
       dry_qty_in_base,
       item_qty,
       qty_unit_id,
       qty_unit,
       contract_value_in_price_cur,
       contract_invoice_value,
       tc_cost_per_unit,
       tc_cost_value,
       rc_cost_per_unit,
       rc_cost_value,
       pc_cost_per_unit,
       pc_cost_value,
       secondary_cost_per_unit,
       secondary_cost_value,
       cog_net_sale_value,
       realized_pnl,
       prev_real_qty,
       prev_real_qty_id,
       prev_real_qty_unit,
       prev_cont_value_in_price_cur,
       prev_real_contract_value,
       prev_real_secondary_cost,
       prev_real_cog_net_sale_value,
       prev_real_pnl,
       prev_tc_per_unit,
       prev_rc_per_unit,
       prev_pc_per_unit,
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
       sales_gmr_ref_no,
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
       accrual_to_base_fw_exch_rate,
       tc_to_base_fw_exch_rate,
       rc_to_base_fw_exch_rate,
       pc_to_base_fw_exch_rate,
       elment_qty_details,
       elment_price_details,
       location_premium_per_unit,
       location_premium,
       prev_location_premium_per_unit,
       prev_location_premium,
       location_premium_fw_exch_rate,
       p_loc_premium_fw_exch_rate)
      select pc_process_id,
             pd_trade_date,
             prch.corporate_id,
             prch.corporate_name,
             prch.internal_contract_ref_no,
             prch.contract_ref_no,
             prch.internal_contract_item_ref_no,
             prch.del_distribution_item_no,
             prch.contract_issue_date,
             prch.contract_type,
             prch.contract_status,
             prch.int_alloc_group_id,
             prch.alloc_group_name,
             prch.internal_gmr_ref_no,
             prch.gmr_ref_no,
             prch.internal_grd_ref_no,
             prch.internal_stock_ref_no,
             prch.product_id,
             prch.product_name,
             prch.origin_id,
             prch.origin_name,
             prch.quality_id,
             prch.quality_name,
             prch.profit_center_id,
             prch.profit_center_name,
             prch.profit_center_short_name,
             prch.cp_profile_id,
             prch.cp_name,
             prch.trade_user_id,
             prch.trade_user_name,
             prch.price_type_id,
             prch.price_type_name,
             prch.incoterm_id,
             prch.incoterm,
             prch.payment_term_id,
             prch.payment_term,
             prch.price_fixation_status,
             'Reverse Realized',
             prch.realized_sub_type,
             prch.realized_date,
             prch.container_no,
             prch.dry_qty,
             prch.wet_qty,
             prch.dry_qty_in_base,
             prch.item_qty,
             prch.qty_unit_id,
             prch.qty_unit,
             prch.contract_value_in_price_cur,
             prch.contract_invoice_value,
             prch.tc_cost_per_unit,
             prch.tc_cost_value,
             prch.rc_cost_per_unit,
             prch.rc_cost_value,
             prch.pc_cost_per_unit,
             prch.pc_cost_value,
             prch.secondary_cost_per_unit,
             prch.secondary_cost_value,
             prch.cog_net_sale_value,
             -1 * prch.realized_pnl,
             prch.prev_real_qty,
             prch.prev_real_qty_id,
             prch.prev_real_qty_unit,
             prch.prev_cont_value_in_price_cur,
             prch.prev_real_contract_value,
             prch.prev_real_secondary_cost,
             prch.prev_real_cog_net_sale_value,
             prch.prev_real_pnl,
             prch.prev_tc_per_unit,
             prch.prev_rc_per_unit,
             prev_pc_per_unit,
             prch.prev_secondary_cost_per_unit,
             -1 * prch.change_in_pnl,
             prch.cfx_price_cur_to_base_cur,
             prch.warehouse_id,
             prch.warehouse_name,
             prch.shed_id,
             prch.shed_name,
             prch.group_id,
             prch.group_name,
             prch.group_cur_id,
             prch.group_cur_code,
             prch.group_qty_unit_id,
             prch.group_qty_unit,
             prch.item_qty_in_base_qty_unit,
             prch.base_qty_unit_id,
             prch.base_qty_unit,
             prch.base_cur_id,
             prch.base_cur_code,
             prch.base_price_unit_id,
             prch.base_price_unit_name,
             prch.sales_profit_center_id,
             prch.sales_profit_center_name,
             prch.sales_profit_center_short_name,
             prch.sales_strategy_id,
             prch.sales_strategy_name,
             prch.sales_business_line_id,
             prch.sales_business_line_name,
             prch.sales_internal_gmr_ref_no,
             prch.sales_gmr_ref_no,
             prch.sales_contract_ref_no,
             prch.origination_city_id,
             prch.origination_city_name,
             prch.origination_country_id,
             prch.origination_country_name,
             prch.destination_city_id,
             prch.destination_city_name,
             prch.destination_country_id,
             prch.destination_country_name,
             prch.pool_id,
             prch.strategy_id,
             prch.strategy_name,
             prch.business_line_id,
             prch.business_line_name,
             prch.bl_number,
             prch.bl_date,
             prch.seal_no,
             prch.mark_no,
             prch.warehouse_ref_no,
             prch.warehouse_receipt_no,
             prch.warehouse_receipt_date,
             prch.is_warrant,
             prch.warrant_no,
             prch.pcdi_id,
             prch.supp_contract_item_ref_no,
             prch.supplier_pcdi_id,
             prch.payable_returnable_type,
             prch.price_description,
             prch.delivery_item_no,
             prch.price_to_base_fw_exch_rate,
             prch.accrual_to_base_fw_exch_rate,
             prch.tc_to_base_fw_exch_rate,
             prch.rc_to_base_fw_exch_rate,
             prch.pc_to_base_fw_exch_rate,
             prch.elment_qty_details,
             prch.elment_price_details,
             prch.location_premium_per_unit,
             prch.location_premium,
             prch.prev_location_premium_per_unit,
             prch.prev_location_premium,
             prch.location_premium_fw_exch_rate,
             prch.p_loc_premium_fw_exch_rate
        from prch_phy_realized_conc_header prch,
             tdc_trade_date_closure tdc,
             (select prch.sales_internal_gmr_ref_no,
                     max(prch.trade_date) trade_date
                from prch_phy_realized_conc_header prch,
                     tdc_trade_date_closure        tdc
               where prch.corporate_id = tdc.corporate_id
                 and tdc.corporate_id = pc_corporate_id
                 and prch.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
                 and prch.trade_date < pd_trade_date
                 and prch.trade_date = tdc.trade_date
                 and tdc.process = pc_process
               group by prch.sales_internal_gmr_ref_no) max_eod -- PRD Realized Date and Allocated Sales
       where (prch.int_alloc_group_id, prch.sales_internal_gmr_ref_no) in
             (select rgmrc.int_alloc_group_id,
                     rgmrc.internal_gmr_ref_no
                from rgmrc_realized_gmr_conc rgmrc
               where rgmrc.process_id = pc_process_id
                 and rgmrc.realized_status = 'Reverse Realized') -- Records to be considered for Reverse Realization
         and prch.trade_date = tdc.trade_date
         and tdc.trade_date = max_eod.trade_date
         and prch.sales_internal_gmr_ref_no =
             max_eod.sales_internal_gmr_ref_no
         and tdc.corporate_id = pc_corporate_id
         and prch.realized_type in
             ('Realized Today', 'Previously Realized PNL Change')
         and tdc.process = pc_process
         and tdc.process_id = prch.process_id;
  
    insert into prce_phy_realized_conc_element
      (process_id,
       int_alloc_group_id,
       sales_internal_gmr_ref_no,
       internal_contract_item_ref_no,
       del_distribution_item_no,
       internal_gmr_ref_no,
       internal_grd_ref_no,
       element_id,
       element_name,
       payable_qty,
       payable_qty_unit_id,
       payable_qty_unit,
       payable_qty_in_base_unit,
       contract_price,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       price_unit_weight_unit_id,
       price_unit_weight_unit,
       price_unit_weight,
       price_to_base_fw_exch_rate,
       contract_value_in_price_cur,
       contract_value_in_base_cur,
       contract_price_cur_id,
       contract_price_cur_code,
       prev_real_price,
       prev_real_price_id,
       prev_real_price_cur_id,
       prev_real_price_cur_code,
       prev_real_price_weight_unit_id,
       prev_real_price_weight_unit,
       prev_real_price_weight,
       prev_contract_price_cur_id,
       prev_contract_price_cur_code,
       tc_in_base_cur,
       rc_in_base_cur,
       tc_to_base_fw_exch_rate,
       rc_to_base_fw_exch_rate,
       prev_tc_in_base_cur,
       prev_rc_in_base_cur,
       prev_tc_to_base_fw_exch_rate,
       prev_rc_to_base_fw_exch_rate)
      select pc_process_id,
             prce.int_alloc_group_id,
             prce.sales_internal_gmr_ref_no,
             internal_contract_item_ref_no,
             del_distribution_item_no,
             internal_gmr_ref_no,
             internal_grd_ref_no,
             element_id,
             element_name,
             payable_qty,
             payable_qty_unit_id,
             payable_qty_unit,
             payable_qty_in_base_unit,
             contract_price,
             price_unit_id,
             price_unit_cur_id,
             price_unit_cur_code,
             price_unit_weight_unit_id,
             price_unit_weight_unit,
             price_unit_weight,
             price_to_base_fw_exch_rate,
             contract_value_in_price_cur,
             contract_value_in_base_cur,
             contract_price_cur_id,
             contract_price_cur_code,
             prev_real_price,
             prev_real_price_id,
             prev_real_price_cur_id,
             prev_real_price_cur_code,
             prev_real_price_weight_unit_id,
             prev_real_price_weight_unit,
             prev_real_price_weight,
             prev_contract_price_cur_id,
             prev_contract_price_cur_code,
             tc_in_base_cur,
             rc_in_base_cur,
             tc_to_base_fw_exch_rate,
             rc_to_base_fw_exch_rate,
             prev_tc_in_base_cur,
             prev_rc_in_base_cur,
             prev_tc_to_base_fw_exch_rate,
             prev_rc_to_base_fw_exch_rate
        from prce_phy_realized_conc_element prce,
             tdc_trade_date_closure tdc,
             (select prch.sales_internal_gmr_ref_no,
                     max(prch.trade_date) trade_date
                from prch_phy_realized_conc_header prch,
                     tdc_trade_date_closure        tdc
               where prch.corporate_id = tdc.corporate_id
                 and tdc.corporate_id = pc_corporate_id
                 and prch.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
                 and prch.trade_date < pd_trade_date
                 and prch.trade_date = tdc.trade_date
                 and tdc.process = pc_process
               group by prch.sales_internal_gmr_ref_no) max_eod -- PRD Realized Date and Allocated Sales
       where prce.trade_date = tdc.trade_date
         and tdc.trade_date = max_eod.trade_date
         and prce.sales_internal_gmr_ref_no =
             max_eod.sales_internal_gmr_ref_no
         and tdc.corporate_id = pc_corporate_id
         and (prce.sales_internal_gmr_ref_no, prce.sales_internal_gmr_ref_no) in
             (select prch.sales_internal_gmr_ref_no,
                     prch.sales_internal_gmr_ref_no
                from prch_phy_realized_conc_header prch
               where prch.realized_type = 'Reverse Realized'
                 and prch.process_id = pc_process_id) -- Header already contains reverse realized in this EOD
         and tdc.process = pc_process
         and tdc.process_id = prce.process_id;
  
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_conc_reverse_rlzed ',
                                                           'M2M-013',
                                                           ' Code:' ||
                                                           sqlcode ||
                                                           ' Message:' ||
                                                           sqlerrm,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_calc_conc_rlzed_not_fixed(pc_corporate_id        varchar2,
                                         pd_trade_date          date,
                                         pc_process_id          varchar2,
                                         pc_previous_process_id varchar2,
                                         pc_user_id             varchar2,
                                         pc_process             varchar2) is
    cursor cur_not_fixed is
    -- Sales Non Event Based Contracts
      select prch.corporate_id,
             prch.corporate_name,
             prch.pcdi_id,
             prch.delivery_item_no,
             prch.internal_contract_ref_no,
             prch.contract_ref_no,
             prch.contract_issue_date,
             prch.internal_contract_item_ref_no,
             prch.contract_type,
             'Realized Not Final Invoiced' unrealized_type,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             cp_profile_id,
             gmr.cp_name,
             trade_user_id,
             trade_user_name,
             prch.product_id,
             gmr.product_name,
             prch.dry_qty,
             prch.wet_qty wet_qty,
             prch.qty_unit_id,
             qty_unit,
             gmr.quality_id,
             prch.quality_name,
             prch.price_description price_string,
             prch.price_fixation_status,
             incoterm_id,
             incoterm,
             origination_city_id,
             prch.origination_city_name origination_city,
             origination_country_id,
             prch.origination_country_name origination_country,
             prch.destination_city_id,
             prch.destination_city_name destination_city,
             prch.destination_country_id destination_country_id,
             prch.destination_country_name destination_country,
             payment_term_id,
             payment_term,
             prch.price_description contract_price_string,
             null contract_rc_tc_pen_string,
             prch.secondary_cost_value net_sc_in_base_cur,
             base_cur_id,
             base_cur_code,
             group_id,
             group_name,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             base_qty_unit_id,
             base_qty_unit,
             null cont_unr_status,
             prch.item_qty_in_base_qty_unit qty_in_base_unit,
             strategy_id,
             strategy_name,
             prch.del_distribution_item_no,
             prch.pc_cost_value penalty_charge,
             null valuation_against_underlying,
             prch.price_to_base_fw_exch_rate contract_pc_fw_exch_rate,
             accrual_to_base_fw_exch_rate,
             prch.price_to_base_fw_exch_rate,
             cipde.contract_price contract_price,
             cipde.price_unit_id price_unit_id,
             cipde.price_unit_cur_id price_unit_cur_id,
             cipde.price_unit_cur_code price_unit_cur_code,
             cipde.price_unit_weight_unit_id price_unit_weight_unit_id,
             cipde.price_unit_weight_unit price_unit_weight_unit,
             cipde.price_unit_weight price_unit_weight,
             prce.payable_qty,
             prce.payable_qty_unit_id,
             prce.payable_qty_unit,
             prce.underlying_product_id,
             prce.underling_prod_qty_unit_id,
             prce.underling_base_qty_unit_id,
             prch.internal_grd_ref_no,
             prch.sales_internal_gmr_ref_no,
             prch.sales_gmr_ref_no,
             dense_rank() over(partition by prch.internal_contract_item_ref_no order by prce.element_id) ele_rank,
             prch.sales_profit_center_id,
             prch.sales_profit_center_name,
             prch.sales_profit_center_short_name,
             prce.element_id,
             prce.element_name,
             prch.ash_id,
             prce.contract_price real_contract_price,
             prce.price_unit_id real_price_unit_id,
             prce.price_unit_cur_id real_price_unit_cur_id,
             prce.price_unit_cur_code real_price_unit_cur_code,
             prce.price_unit_weight_unit_id real_price_unit_weight_unit_id,
             prce.price_unit_weight_unit real_price_unit_weight_unit,
             nvl(prce.price_unit_weight, 1) real_price_unit_weight,
             prce.contract_value_in_base_cur prev_element_value_in_base,
             cipde.price_fixation_details
        from prch_phy_realized_conc_header  prch,
             cipde_cipd_element_price       cipde,
             agh_alloc_group_header         agh,
             gmr_goods_movement_record      gmr,
             prce_phy_realized_conc_element prce
       where (prch.sales_internal_gmr_ref_no, prch.int_alloc_group_id,
              prch.trade_date) in
             (select prd.sales_internal_gmr_ref_no,
                     prd.int_alloc_group_id,
                     max(prd.trade_date) trade_date
                from prch_phy_realized_conc_header prd,
                     tdc_trade_date_closure        tdc
               where prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and prd.corporate_id = pc_corporate_id
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prd.sales_internal_gmr_ref_no,
                        prd.int_alloc_group_id)
         and prch.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
         and cipde.process_id = pc_process_id
         and agh.int_alloc_group_id = prch.int_alloc_group_id
         and agh.process_id = pc_process_id
         and agh.is_deleted = 'N' -- Allocation is Active 
         and gmr.internal_gmr_ref_no = prch.sales_internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and nvl(gmr.is_final_invoiced, 'N') = 'N' -- As of today FI is not done
         and prch.contract_type = 'S'
         and cipde.price_basis <> 'Fixed'
         and agh.realized_status = 'Realized'
         and prch.realized_type in
             ('Realized Today', 'Previously Realized PNL Change')
         and prch.process_id = prce.process_id
         and prch.int_alloc_group_id = prce.int_alloc_group_id
         and prch.sales_internal_gmr_ref_no =
             prce.sales_internal_gmr_ref_no
         and prce.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
         and prce.element_id = cipde.element_id
      union all -- Sales Event Based
      select prch.corporate_id,
             prch.corporate_name,
             prch.pcdi_id,
             prch.delivery_item_no,
             prch.internal_contract_ref_no,
             prch.contract_ref_no,
             prch.contract_issue_date,
             prch.internal_contract_item_ref_no,
             prch.contract_type,
             'Realized Not Final Invoiced' unrealized_type,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             cp_profile_id,
             gmr.cp_name,
             trade_user_id,
             trade_user_name,
             prch.product_id,
             gmr.product_name,
             prch.dry_qty,
             prch.wet_qty wet_qty,
             prch.qty_unit_id,
             qty_unit,
             gmr.quality_id,
             prch.quality_name,
             prch.price_description price_string,
             prch.price_fixation_status,
             incoterm_id,
             incoterm,
             origination_city_id,
             prch.origination_city_name origination_city,
             origination_country_id,
             prch.origination_country_name origination_country,
             prch.destination_city_id,
             prch.destination_city_name destination_city,
             prch.destination_country_id destination_country_id,
             prch.destination_country_name destination_country,
             payment_term_id,
             payment_term,
             prch.price_description contract_price_string,
             null contract_rc_tc_pen_string,
             prch.secondary_cost_value net_sc_in_base_cur,
             base_cur_id,
             base_cur_code,
             group_id,
             group_name,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             base_qty_unit_id,
             base_qty_unit,
             null cont_unr_status,
             prch.item_qty_in_base_qty_unit qty_in_base_unit,
             strategy_id,
             strategy_name,
             prch.del_distribution_item_no,
             prch.pc_cost_value penalty_charge,
             null valuation_against_underlying,
             prch.price_to_base_fw_exch_rate contract_pc_fw_exch_rate,
             accrual_to_base_fw_exch_rate,
             prch.price_to_base_fw_exch_rate,
             gpd.contract_price contract_price,
             gpd.price_unit_id price_unit_id,
             gpd.price_unit_cur_id price_unit_cur_id,
             gpd.price_unit_cur_code price_unit_cur_code,
             gpd.price_unit_weight_unit_id price_unit_weight_unit_id,
             gpd.price_unit_weight_unit price_unit_weight_unit,
             gpd.price_unit_weight price_unit_weight,
             prce.payable_qty,
             prce.payable_qty_unit_id,
             prce.payable_qty_unit,
             prce.underlying_product_id,
             prce.underling_prod_qty_unit_id,
             prce.underling_base_qty_unit_id,
             prch.internal_grd_ref_no,
             prch.sales_internal_gmr_ref_no,
             prch.sales_gmr_ref_no,
             dense_rank() over(partition by prch.internal_contract_item_ref_no order by prce.element_id) ele_rank,
             prch.sales_profit_center_id,
             prch.sales_profit_center_name,
             prch.sales_profit_center_short_name,
             prce.element_id,
             prce.element_name,
             prch.ash_id,
             prce.contract_price real_contract_price,
             prce.price_unit_id real_price_unit_id,
             prce.price_unit_cur_id real_price_unit_cur_id,
             prce.price_unit_cur_code real_price_unit_cur_code,
             prce.price_unit_weight_unit_id real_price_unit_weight_unit_id,
             prce.price_unit_weight_unit real_price_unit_weight_unit,
             nvl(prce.price_unit_weight, 1) real_price_unit_weight,
             prce.contract_value_in_base_cur,
             gpd.price_fixation_details
        from prch_phy_realized_conc_header  prch,
             agh_alloc_group_header         agh,
             gmr_goods_movement_record      gmr,
             gpd_gmr_conc_price_daily       gpd,
             prce_phy_realized_conc_element prce
       where (prch.sales_internal_gmr_ref_no, prch.int_alloc_group_id,
              prch.trade_date) in
             (select prd.sales_internal_gmr_ref_no,
                     prd.int_alloc_group_id,
                     max(prd.trade_date) trade_date
                from prch_phy_realized_conc_header prd,
                     tdc_trade_date_closure        tdc
               where prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and prd.corporate_id = pc_corporate_id
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prd.sales_internal_gmr_ref_no,
                        prd.int_alloc_group_id)
         and agh.int_alloc_group_id = prch.int_alloc_group_id
         and agh.process_id = pc_process_id
         and agh.is_deleted = 'N' -- Allocation is Active 
         and gmr.internal_gmr_ref_no = prch.sales_internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and nvl(gmr.is_final_invoiced, 'N') = 'N' -- As of today FI is not done
         and prch.contract_type = 'S'
         and gpd.price_basis <> 'Fixed'
         and agh.realized_status = 'Realized'
         and prch.realized_type in
             ('Realized Today', 'Previously Realized PNL Change')
         and prch.process_id = prce.process_id
         and prch.int_alloc_group_id = prce.int_alloc_group_id
         and prch.sales_internal_gmr_ref_no =
             prce.sales_internal_gmr_ref_no
         and prce.element_id = gpd.element_id
         and prce.sales_internal_gmr_ref_no = gpd.internal_gmr_ref_no
         and prce.process_id = gpd.process_id
      
      union all -- Purchase Non Event Based Contracts
      select prch.corporate_id,
             prch.corporate_name,
             prch.pcdi_id,
             prch.delivery_item_no,
             prch.internal_contract_ref_no,
             prch.contract_ref_no,
             prch.contract_issue_date,
             prch.internal_contract_item_ref_no,
             prch.contract_type,
             'Realized Not Final Invoiced' unrealized_type,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             cp_profile_id,
             gmr.cp_name,
             trade_user_id,
             trade_user_name,
             prch.product_id,
             gmr.product_name,
             prch.dry_qty,
             prch.wet_qty wet_qty,
             prch.qty_unit_id,
             qty_unit,
             gmr.quality_id,
             prch.quality_name,
             prch.price_description price_string,
             prch.price_fixation_status,
             incoterm_id,
             incoterm,
             origination_city_id,
             prch.origination_city_name origination_city,
             origination_country_id,
             prch.origination_country_name origination_country,
             prch.destination_city_id,
             prch.destination_city_name destination_city,
             prch.destination_country_id destination_country_id,
             prch.destination_country_name destination_country,
             payment_term_id,
             payment_term,
             prch.price_description contract_price_string,
             null contract_rc_tc_pen_string,
             prch.secondary_cost_value net_sc_in_base_cur,
             base_cur_id,
             base_cur_code,
             group_id,
             group_name,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             base_qty_unit_id,
             base_qty_unit,
             null cont_unr_status,
             prch.item_qty_in_base_qty_unit qty_in_base_unit,
             strategy_id,
             strategy_name,
             prch.del_distribution_item_no,
             prch.pc_cost_value penalty_charge,
             null valuation_against_underlying,
             prch.price_to_base_fw_exch_rate contract_pc_fw_exch_rate,
             accrual_to_base_fw_exch_rate,
             prch.price_to_base_fw_exch_rate,
             cipde.contract_price contract_price,
             cipde.price_unit_id price_unit_id,
             cipde.price_unit_cur_id price_unit_cur_id,
             cipde.price_unit_cur_code price_unit_cur_code,
             cipde.price_unit_weight_unit_id price_unit_weight_unit_id,
             cipde.price_unit_weight_unit price_unit_weight_unit,
             cipde.price_unit_weight price_unit_weight,
             prce.payable_qty,
             prce.payable_qty_unit_id,
             prce.payable_qty_unit,
             prce.underlying_product_id,
             prce.underling_prod_qty_unit_id,
             prce.underling_base_qty_unit_id,
             prch.internal_grd_ref_no,
             prch.sales_internal_gmr_ref_no,
             prch.sales_gmr_ref_no,
             dense_rank() over(partition by prch.internal_contract_item_ref_no order by prce.element_id) ele_rank,
             prch.sales_profit_center_id,
             prch.sales_profit_center_name,
             prch.sales_profit_center_short_name,
             prce.element_id,
             prce.element_name,
             prch.ash_id,
             prce.contract_price real_contract_price,
             prce.price_unit_id real_price_unit_id,
             prce.price_unit_cur_id real_price_unit_cur_id,
             prce.price_unit_cur_code real_price_unit_cur_code,
             prce.price_unit_weight_unit_id real_price_unit_weight_unit_id,
             prce.price_unit_weight_unit real_price_unit_weight_unit,
             nvl(prce.price_unit_weight, 1) real_price_unit_weight,
             prce.contract_value_in_base_cur,
             cipde.price_fixation_details
        from prch_phy_realized_conc_header  prch,
             cipde_cipd_element_price       cipde,
             agh_alloc_group_header         agh,
             gmr_goods_movement_record      gmr,
             prce_phy_realized_conc_element prce
       where (prch.sales_internal_gmr_ref_no, prch.int_alloc_group_id,
              prch.trade_date) in
             (select prd.sales_internal_gmr_ref_no,
                     prd.int_alloc_group_id,
                     max(prd.trade_date) trade_date
                from prch_phy_realized_conc_header prd,
                     tdc_trade_date_closure        tdc
               where prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and prd.corporate_id = pc_corporate_id
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prd.sales_internal_gmr_ref_no,
                        prd.int_alloc_group_id)
         and prch.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
         and cipde.process_id = pc_process_id
         and agh.int_alloc_group_id = prch.int_alloc_group_id
         and agh.process_id = pc_process_id
         and agh.is_deleted = 'N' -- Allocation is Active 
         and gmr.internal_gmr_ref_no = prch.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and nvl(gmr.is_final_invoiced, 'N') = 'N' -- As of today FI is not done
         and prch.contract_type = 'P'
         and cipde.price_basis <> 'Fixed'
         and agh.realized_status = 'Realized'
         and prch.realized_type in
             ('Realized Today', 'Previously Realized PNL Change')
         and prch.process_id = prce.process_id
         and prch.int_alloc_group_id = prce.int_alloc_group_id
         and prch.sales_internal_gmr_ref_no =
             prce.sales_internal_gmr_ref_no
         and cipde.internal_contract_item_ref_no =
             prce.internal_contract_item_ref_no
         and cipde.element_id = prce.element_id
         and cipde.process_id = pc_process_id
      union all -- Purchase Event Based Contracts
      select prch.corporate_id,
             prch.corporate_name,
             prch.pcdi_id,
             prch.delivery_item_no,
             prch.internal_contract_ref_no,
             prch.contract_ref_no,
             prch.contract_issue_date,
             prch.internal_contract_item_ref_no,
             prch.contract_type,
             'Realized Not Final Invoiced' unrealized_type,
             profit_center_id,
             profit_center_name,
             profit_center_short_name,
             cp_profile_id,
             gmr.cp_name,
             trade_user_id,
             trade_user_name,
             prch.product_id,
             gmr.product_name,
             prch.dry_qty,
             prch.wet_qty wet_qty,
             prch.qty_unit_id,
             qty_unit,
             gmr.quality_id,
             prch.quality_name,
             prch.price_description price_string,
             prch.price_fixation_status,
             incoterm_id,
             incoterm,
             origination_city_id,
             prch.origination_city_name origination_city,
             origination_country_id,
             prch.origination_country_name origination_country,
             prch.destination_city_id,
             prch.destination_city_name destination_city,
             prch.destination_country_id destination_country_id,
             prch.destination_country_name destination_country,
             payment_term_id,
             payment_term,
             prch.price_description contract_price_string,
             null contract_rc_tc_pen_string,
             prch.secondary_cost_value net_sc_in_base_cur,
             base_cur_id,
             base_cur_code,
             group_id,
             group_name,
             group_cur_id,
             group_cur_code,
             group_qty_unit_id,
             group_qty_unit,
             base_qty_unit_id,
             base_qty_unit,
             null cont_unr_status,
             prch.item_qty_in_base_qty_unit qty_in_base_unit,
             strategy_id,
             strategy_name,
             prch.del_distribution_item_no,
             prch.pc_cost_value penalty_charge,
             null valuation_against_underlying,
             prch.price_to_base_fw_exch_rate contract_pc_fw_exch_rate,
             accrual_to_base_fw_exch_rate,
             prch.price_to_base_fw_exch_rate,
             gpd.contract_price contract_price,
             gpd.price_unit_id price_unit_id,
             gpd.price_unit_cur_id price_unit_cur_id,
             gpd.price_unit_cur_code price_unit_cur_code,
             gpd.price_unit_weight_unit_id price_unit_weight_unit_id,
             gpd.price_unit_weight_unit price_unit_weight_unit,
             gpd.price_unit_weight price_unit_weight,
             prce.payable_qty,
             prce.payable_qty_unit_id,
             prce.payable_qty_unit,
             prce.underlying_product_id,
             prce.underling_prod_qty_unit_id,
             prce.underling_base_qty_unit_id,
             prch.internal_grd_ref_no,
             prch.sales_internal_gmr_ref_no,
             prch.sales_gmr_ref_no,
             dense_rank() over(partition by prch.internal_contract_item_ref_no order by prce.element_id) ele_rank,
             prch.sales_profit_center_id,
             prch.sales_profit_center_name,
             prch.sales_profit_center_short_name,
             prce.element_id,
             prce.element_name,
             prch.ash_id,
             prce.contract_price real_contract_price,
             prce.price_unit_id real_price_unit_id,
             prce.price_unit_cur_id real_price_unit_cur_id,
             prce.price_unit_cur_code real_price_unit_cur_code,
             prce.price_unit_weight_unit_id real_price_unit_weight_unit_id,
             prce.price_unit_weight_unit real_price_unit_weight_unit,
             nvl(prce.price_unit_weight, 1) real_price_unit_weight,
             prce.contract_value_in_base_cur,
             gpd.price_fixation_details
        from prch_phy_realized_conc_header  prch,
             agh_alloc_group_header         agh,
             gmr_goods_movement_record      gmr,
             gpd_gmr_conc_price_daily       gpd,
             prce_phy_realized_conc_element prce
       where (prch.sales_internal_gmr_ref_no, prch.int_alloc_group_id,
              prch.trade_date) in
             (select prd.sales_internal_gmr_ref_no,
                     prd.int_alloc_group_id,
                     max(prd.trade_date) trade_date
                from prch_phy_realized_conc_header prd,
                     tdc_trade_date_closure        tdc
               where prd.trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and prd.corporate_id = pc_corporate_id
                 and prd.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prd.sales_internal_gmr_ref_no,
                        prd.int_alloc_group_id)
         and agh.int_alloc_group_id = prch.int_alloc_group_id
         and agh.process_id = pc_process_id
         and agh.is_deleted = 'N' -- Allocation is Active 
         and gmr.internal_gmr_ref_no = prch.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and nvl(gmr.is_final_invoiced, 'N') = 'N' -- As of today FI is not done
         and prch.contract_type = 'P'
         and gpd.price_basis <> 'Fixed'
         and agh.realized_status = 'Realized'
         and prch.realized_type in
             ('Realized Today', 'Previously Realized PNL Change')
         and prch.process_id = prce.process_id
         and prch.int_alloc_group_id = prce.int_alloc_group_id
         and prch.sales_internal_gmr_ref_no =
             prce.sales_internal_gmr_ref_no
         and prce.process_id = gpd.process_id
         and prce.internal_gmr_ref_no = gpd.internal_gmr_ref_no
         and prce.element_id = gpd.element_id;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vc_error_msg                   varchar2(10);
    vn_ele_qty_in_base             number;
    vn_contract_price              number;
    vn_contract_value_in_price_cur number;
    vn_contract_value_in_base_cur  number;
    vc_price_unit_id               varchar2(15);
    vc_price_unit_cur_id           varchar2(15);
    vc_price_unit_cur_code         varchar2(15);
    vc_price_unit_weight_unit_id   varchar2(15);
    vc_price_unit_weight_unit      varchar2(15);
    vn_price_unit_weight           number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_price_to_base_fw_rate       number;
    vn_forward_points              number;
    vc_price_to_base_fw_rate       varchar2(100);
    vn_realized_amount_in_base_cur number;
    vn_prev_unr_pnl                number;
    vn_pnl_in_base_cur             number;
    vn_trade_day_pnl               number;
    vn_unreal_pnl_in_base_per_unit number;
  begin
    for cur_not_fixed_rows in cur_not_fixed
    loop
      vc_price_to_base_fw_rate     := null;
      vn_contract_price            := cur_not_fixed_rows.contract_price;
      vc_price_unit_id             := cur_not_fixed_rows.price_unit_id;
      vc_price_unit_cur_id         := cur_not_fixed_rows.price_unit_cur_id;
      vc_price_unit_cur_code       := cur_not_fixed_rows.price_unit_cur_code;
      vc_price_unit_weight_unit_id := cur_not_fixed_rows.price_unit_weight_unit_id;
      vc_price_unit_weight_unit    := cur_not_fixed_rows.price_unit_weight_unit;
      vn_price_unit_weight         := cur_not_fixed_rows.price_unit_weight;
      if vn_price_unit_weight is null then
        vn_price_unit_weight := 1;
      end if;
    
      -- Pricing Main Currency Details
      --
      pkg_general.sp_get_main_cur_detail(vc_price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
    
      vc_error_msg := '2249';
      --
      -- Calculate the Current contract value in Price Currency
      --
      --
    
      if cur_not_fixed_rows.payable_qty_unit_id <>
         cur_not_fixed_rows.underling_prod_qty_unit_id then
        vn_ele_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_not_fixed_rows.product_id,
                                                                         cur_not_fixed_rows.payable_qty_unit_id,
                                                                         cur_not_fixed_rows.underling_prod_qty_unit_id,
                                                                         1) *
                                    cur_not_fixed_rows.payable_qty,
                                    cur_not_fixed_rows.underling_base_qty_unit_id);
      else
        vn_ele_qty_in_base := round(cur_not_fixed_rows.payable_qty,
                                    cur_not_fixed_rows.underling_base_qty_unit_id);
      end if;
      vc_error_msg := '2267';
      -- Get the payable element value in base currency
      vn_contract_value_in_price_cur := (vn_contract_price /
                                        nvl(vn_price_unit_weight, 1)) *
                                        vn_ele_qty_in_base *
                                        vn_cont_price_cur_id_factor *
                                        pkg_general.f_get_converted_quantity(cur_not_fixed_rows.underlying_product_id,
                                                                             cur_not_fixed_rows.payable_qty_unit_id,
                                                                             cur_not_fixed_rows.underling_base_qty_unit_id,
                                                                             cur_not_fixed_rows.payable_qty);
      vc_error_msg                   := '2277';
      if vc_price_cur_id <> cur_not_fixed_rows.base_cur_id then
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    pd_trade_date,
                                    vc_price_cur_id,
                                    cur_not_fixed_rows.base_cur_id,
                                    30,
                                    'Concentrate Realized Not Fixed PNL',
                                    pc_process,
                                    vn_price_to_base_fw_rate,
                                    vn_forward_points);
      else
        vn_price_to_base_fw_rate := 1;
      end if;
      vn_contract_value_in_base_cur := vn_contract_value_in_price_cur *
                                       vn_price_to_base_fw_rate;
    
      if cur_not_fixed_rows.ele_rank = 1 then
      
        insert into poue_phy_open_unreal_element
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
           item_dry_qty,
           item_wet_qty,
           qty_unit_id,
           qty_unit,
           quality_id,
           quality_name,
           fixation_method,
           price_string,
           price_fixation_status,
           price_fixation_details,
           item_delivery_period_string,
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
           contract_price_string,
           contract_rc_tc_pen_string,
           m2m_price_string,
           m2m_rc_tc_pen_string,
           net_contract_value_in_base_cur,
           net_contract_prem_in_base_cur,
           net_m2m_amt_in_base_cur,
           net_sc_in_base_cur,
           expected_cog_net_sale_value,
           unrealized_pnl_in_base_cur,
           unreal_pnl_in_base_per_unit,
           prev_day_unr_pnl_in_base_cur,
           trade_day_pnl_in_base_cur,
           base_cur_id,
           base_cur_code,
           group_id,
           group_name,
           group_cur_id,
           group_cur_code,
           group_qty_unit_id,
           group_qty_unit,
           base_qty_unit_id,
           base_qty_unit,
           cont_unr_status,
           qty_in_base_unit,
           process_trade_date,
           strategy_id,
           strategy_name,
           del_distribution_item_no,
           penalty_charge,
           m2m_penalty_charge,
           net_contract_treatment_charge,
           net_contract_refining_charge,
           net_m2m_treatment_charge,
           net_m2m_refining_charge,
           m2m_loc_diff_premium,
           valuation_against_underlying,
           contract_pc_fw_exch_rate,
           accrual_to_base_fw_exch_rate,
           price_to_base_fw_exch_rate,
           m2m_to_base_fw_exch_rate,
           is_tolling_contract,
           is_tolling_extn,
           sales_internal_gmr_ref_no,
           sales_gmr_ref_no,
           internal_grd_ref_no,
           realized_amount_in_base_cur)
        values
          (cur_not_fixed_rows.corporate_id,
           cur_not_fixed_rows.corporate_name,
           pc_process_id,
           cur_not_fixed_rows.pcdi_id,
           cur_not_fixed_rows.delivery_item_no,
           null, --prefix,
           null, --'v_middle_no',
           null, --'v_suffix',
           cur_not_fixed_rows.internal_contract_ref_no,
           cur_not_fixed_rows.contract_ref_no,
           cur_not_fixed_rows.contract_issue_date,
           cur_not_fixed_rows.internal_contract_item_ref_no,
           null, --'v_basis_type',
           null, --'v_delivery_period_type',
           null, --'v_delivery_from_month',
           null, --'v_delivery_from_year',
           null, --'v_delivery_to_month',
           null, --'v_delivery_to_year',
           null, --'v_delivery_from_date',
           null, --'v_delivery_to_date',
           null, --'v_transit_days',
           cur_not_fixed_rows.contract_type,
           null, --'v_approval_status',
           cur_not_fixed_rows.unrealized_type,
           cur_not_fixed_rows.sales_profit_center_id,
           cur_not_fixed_rows.sales_profit_center_name,
           cur_not_fixed_rows.sales_profit_center_short_name,
           cur_not_fixed_rows.cp_profile_id,
           cur_not_fixed_rows.cp_name,
           cur_not_fixed_rows.trade_user_id,
           cur_not_fixed_rows.trade_user_name,
           cur_not_fixed_rows.product_id,
           cur_not_fixed_rows.product_name,
           cur_not_fixed_rows.dry_qty,
           cur_not_fixed_rows.wet_qty,
           cur_not_fixed_rows.qty_unit_id,
           cur_not_fixed_rows.qty_unit,
           cur_not_fixed_rows.quality_id,
           cur_not_fixed_rows.quality_name,
           null, --'v_fixation_method',
           cur_not_fixed_rows.price_string,
           cur_not_fixed_rows.price_fixation_status,
           cur_not_fixed_rows.price_fixation_details,
           null, --'v_item_delivery_period_string',
           cur_not_fixed_rows.incoterm_id,
           cur_not_fixed_rows.incoterm,
           cur_not_fixed_rows.origination_city_id,
           cur_not_fixed_rows.origination_city,
           cur_not_fixed_rows.origination_country_id,
           cur_not_fixed_rows.origination_country,
           cur_not_fixed_rows.destination_city_id,
           cur_not_fixed_rows.destination_city,
           cur_not_fixed_rows.destination_country_id,
           cur_not_fixed_rows.destination_country,
           null, --'v_origination_region_id',
           null, --'v_origination_region',
           null, --'v_destination_region_id',
           null, --'v_destination_region',
           cur_not_fixed_rows.payment_term_id,
           cur_not_fixed_rows.payment_term,
           null, --'v_contract_price_string',
           null, --'v_contract_rc_tc_pen_string',
           null, --'v_m2m_price_string',
           null, --'v_m2m_rc_tc_pen_string',
           null, -- 'v_net_contract_value_in_base_cur',
           null, -- 'v_net_contract_prem_in_base_cur',
           null, -- 'v_net_m2m_amt_in_base_cur',
           null, --  'v_net_sc_in_base_cur',
           null, -- 'v_expected_cog_net_sale_value',
           null, --   'v_unrealized_pnl_in_base_cur',
           null, --  'v_unreal_pnl_in_base_per_unit',
           null, -- 'v_prev_day_unr_pnl_in_base_cur',
           null, -- 'v_trade_day_pnl_in_base_cur',
           cur_not_fixed_rows.base_cur_id,
           cur_not_fixed_rows.base_cur_code,
           cur_not_fixed_rows.group_id,
           cur_not_fixed_rows.group_name,
           cur_not_fixed_rows.group_cur_id,
           cur_not_fixed_rows.group_cur_code,
           cur_not_fixed_rows.group_qty_unit_id,
           cur_not_fixed_rows.group_qty_unit,
           cur_not_fixed_rows.base_qty_unit_id,
           cur_not_fixed_rows.base_qty_unit,
           null, -- 'v_cont_unr_status',
           cur_not_fixed_rows.qty_in_base_unit,
           pd_trade_date,
           cur_not_fixed_rows.strategy_id,
           cur_not_fixed_rows.strategy_name,
           cur_not_fixed_rows.del_distribution_item_no,
           cur_not_fixed_rows.penalty_charge,
           null, --'v_m2m_penalty_charge',
           null, --'v_net_contract_treatment_charge',
           null, --'v_net_contract_refining_charge',
           null, --'v_net_m2m_treatment_charge',
           null, -- 'v_net_m2m_refining_charge',
           null, --  'v_m2m_loc_diff_premium',
           null, --'v_valuation_against_underlying',
           null, --    'v_contract_pc_fw_exch_rate',
           null, --  'v_accrual_to_base_fw_exch_rate',
           null, --   'v_price_to_base_fw_exch_rate',
           null, --   'v_m2m_to_base_fw_exch_rate',
           'N', --   'v_is_tolling_contract',
           'N', --   'v_is_tolling_extn',
           cur_not_fixed_rows.sales_internal_gmr_ref_no,
           cur_not_fixed_rows.sales_gmr_ref_no,
           cur_not_fixed_rows.internal_grd_ref_no,
           0); -- Update later
      end if;
      insert into poued_element_details
        (corporate_id,
         corporate_name,
         process_id,
         md_id,
         internal_contract_item_ref_no,
         element_id,
         element_name,
         assay_header_id,
         assay_qty,
         assay_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         refining_charge,
         treatment_charge,
         pricing_details,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         m2m_price,
         m2m_price_unit_id,
         m2m_price_cur_id,
         m2m_price_cur_code,
         m2m_price_weight,
         m2m_price_weght_unit_id,
         m2m_price_weight_unit,
         contract_value,
         contract_value_cur_id,
         contract_value_cur_code,
         contract_value_in_base,
         contract_premium_value_in_base,
         m2m_value,
         m2m_value_cur_id,
         m2m_value_cur_code,
         m2m_refining_charge,
         m2m_treatment_charge,
         m2m_loc_diff,
         m2m_amt_in_base,
         valuation_dr_id,
         valuation_dr_id_name,
         valuation_month,
         valuation_date,
         expected_cog_net_sale_value,
         unrealized_pnl_in_base_cur,
         base_cur_id,
         base_cur_code,
         price_cur_to_base_cur_fx_rate,
         m2m_cur_to_base_cur_fx_rate,
         derivative_def_id,
         valuation_exchange_id,
         valuation_exchange,
         element_qty_in_base_unit,
         base_price_unit_id_ppu,
         base_price_unit_name,
         valuation_against_underlying,
         contract_rc_fw_exch_rate,
         contract_tc_fw_exch_rate,
         m2m_rc_fw_exch_rate,
         m2m_tc_fw_exch_rate,
         m2m_ld_fw_exch_rate,
         is_tolling_contract,
         is_tolling_extn,
         sales_internal_gmr_ref_no,
         sales_gmr_ref_no,
         internal_grd_ref_no,
         real_contract_price,
         real_price_unit_id,
         real_price_unit_cur_id,
         real_price_unit_cur_code,
         real_price_unit_weight_unit_id,
         real_price_unit_weight,
         real_price_unit_weight_unit,
         prev_contract_value_in_base)
      values
        (cur_not_fixed_rows.corporate_id,
         cur_not_fixed_rows.corporate_name,
         pc_process_id,
         null, --'v_md_id',
         cur_not_fixed_rows.internal_contract_item_ref_no,
         cur_not_fixed_rows.element_id,
         cur_not_fixed_rows.element_name,
         cur_not_fixed_rows.ash_id,
         null, -- 'v_assay_qty',
         null, -- 'v_assay_qty_unit_id',
         cur_not_fixed_rows.payable_qty,
         cur_not_fixed_rows.payable_qty_unit_id,
         null, -- 'v_refining_charge',
         null, --  'v_treatment_charge',
         null, -- 'v_pricing_details',
         vn_contract_price,
         vc_price_unit_id,
         vc_price_unit_cur_id,
         vc_price_unit_cur_code,
         vc_price_unit_weight_unit_id,
         vn_price_unit_weight,
         vc_price_unit_weight_unit,
         null, -- 'v_m2m_price',
         null, -- 'v_m2m_price_unit_id',
         null, -- 'v_m2m_price_cur_id',
         null, -- 'v_m2m_price_cur_code',
         null, -- 'v_m2m_price_weight',
         null, -- 'v_m2m_price_weght_unit_id',
         null, -- 'v_m2m_price_weight_unit',
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         null, --'v_contract_premium_value_in_base',
         null, --'v_m2m_value',
         null, -- 'v_m2m_value_cur_id',
         null, --'v_m2m_value_cur_code',
         null, -- 'v_m2m_refining_charge',
         null, --'v_m2m_treatment_charge',
         null, -- 'v_m2m_loc_diff',
         null, -- 'v_m2m_amt_in_base',
         null, --'v_valuation_dr_id',
         null, --'v_valuation_dr_id_name',
         null, -- 'v_valuation_month',
         null, --'v_valuation_date',
         null, -- 'v_expected_cog_net_sale_value',
         null, -- 'v_unrealized_pnl_in_base_cur',
         cur_not_fixed_rows.base_cur_id,
         cur_not_fixed_rows.base_cur_code,
         vn_price_to_base_fw_rate,
         null, --'v_m2m_cur_to_base_cur_fx_rate',
         null, --'v_derivative_def_id',
         null, -- 'v_valuation_exchange_id',
         null, -- 'v_valuation_exchange',
         vn_ele_qty_in_base, -- 'v_element_qty_in_base_unit',
         null, --  'v_base_price_unit_id_ppu',
         null, --   'v_base_price_unit_name',
         null, --  'v_valuation_against_underlying',
         null, --  'v_contract_rc_fw_exch_rate',
         null, --  'v_contract_tc_fw_exch_rate',
         null, --   'v_m2m_rc_fw_exch_rate',
         null, --  'v_m2m_tc_fw_exch_rate',
         null, --  'v_m2m_ld_fw_exch_rate',
         'N', --is_tolling_contract',
         'N', --'v_is_tolling_extn',
         cur_not_fixed_rows.sales_internal_gmr_ref_no,
         cur_not_fixed_rows.sales_gmr_ref_no,
         cur_not_fixed_rows.internal_grd_ref_no,
         cur_not_fixed_rows.real_contract_price,
         cur_not_fixed_rows.real_price_unit_id,
         cur_not_fixed_rows.real_price_unit_cur_id,
         cur_not_fixed_rows.real_price_unit_cur_code,
         cur_not_fixed_rows.real_price_unit_weight_unit_id,
         cur_not_fixed_rows.real_price_unit_weight,
         cur_not_fixed_rows.real_price_unit_weight_unit,
         cur_not_fixed_rows.prev_element_value_in_base);
    end loop;
    --
    -- Update Contract Value in Header
    --
  
    update poue_phy_open_unreal_element poue
       set (poue.realized_amount_in_base_cur, poue.net_contract_value_in_base_cur) = --
            (select sum(poued.prev_contract_value_in_base),
                    sum(poued.contract_value_in_base)
               from poued_element_details poued
              where poued.process_id = pc_process_id
                and poued.internal_contract_item_ref_no =
                    poue.internal_contract_item_ref_no
                and poued.internal_grd_ref_no = poue.internal_grd_ref_no
                and poued.sales_internal_gmr_ref_no =
                    poue.sales_internal_gmr_ref_no)
     where poue.process_id = pc_process_id
       and poue.unrealized_type = 'Realized Not Final Invoiced';
  
    -- Calcualte the PNL in base
    --
    for cur_update in (select *
                         from poue_phy_open_unreal_element poue
                        where poue.process_id = pc_process_id
                          and poue.unrealized_type =
                              'Realized Not Final Invoiced')
    loop
      --
      -- Get the Previous Unrealized PNL
      --
      begin
        select poud_prev_day.unrealized_pnl_in_base_cur
          into vn_prev_unr_pnl
          from poue_phy_open_unreal_element poud_prev_day
         where poud_prev_day.process_id = pc_previous_process_id
           and poud_prev_day.unrealized_type =
               'Realized Not Final Invoiced'
           and corporate_id = pc_corporate_id
           and poud_prev_day.sales_internal_gmr_ref_no =
               cur_update.sales_internal_gmr_ref_no
           and poud_prev_day.internal_contract_item_ref_no =
               cur_update.internal_contract_item_ref_no
           and poud_prev_day.contract_type = cur_update.contract_type
           and poud_prev_day.internal_grd_ref_no =
               cur_update.internal_grd_ref_no;
      exception
        when no_data_found then
          vn_prev_unr_pnl := 0;
        when others then
          vn_prev_unr_pnl := 0; -- Issue in POUD 
      end;
      vn_realized_amount_in_base_cur := cur_update.realized_amount_in_base_cur;
      vn_contract_value_in_base_cur  := cur_update.net_contract_value_in_base_cur;
      if cur_update.contract_type = 'S' then
        vn_pnl_in_base_cur := vn_contract_value_in_base_cur -
                              vn_realized_amount_in_base_cur;
      else
        vn_pnl_in_base_cur := vn_realized_amount_in_base_cur -
                              vn_contract_value_in_base_cur;
      end if;
      vn_pnl_in_base_cur             := round(vn_pnl_in_base_cur, 2);
      vc_error_msg                   := '5';
      vn_trade_day_pnl               := vn_pnl_in_base_cur -
                                        vn_prev_unr_pnl;
      vn_unreal_pnl_in_base_per_unit := vn_pnl_in_base_cur /
                                        cur_update.qty_in_base_unit;
    
      -- Update Unrealized Header
      update poue_phy_open_unreal_element poue
         set poue.unrealized_pnl_in_base_cur  = vn_pnl_in_base_cur,
             poue.unreal_pnl_in_base_per_unit = vn_unreal_pnl_in_base_per_unit,
             poue.trade_day_pnl_in_base_cur   = vn_trade_day_pnl
       where poue.process_id = pc_process_id
         and poue.unrealized_type = 'Realized Not Final Invoiced'
         and poue.corporate_id = pc_corporate_id
         and poue.sales_internal_gmr_ref_no =
             cur_update.sales_internal_gmr_ref_no
         and poue.internal_contract_item_ref_no =
             cur_update.internal_contract_item_ref_no
         and poue.contract_type = cur_update.contract_type
         and poue.internal_grd_ref_no = cur_update.internal_grd_ref_no;
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
                                                           dbms_utility.format_error_backtrace || ' ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;
  procedure sp_calc_phy_conc_pnl_change(pc_corporate_id varchar2,
                                        pd_trade_date   date,
                                        pc_process      varchar2,
                                        pc_process_id   varchar2,
                                        pc_dbd_id       varchar2,
                                        pc_user_id      varchar2) as
  
    cursor cur_realized is
      select pd_trade_date trade_date,
             prch.corporate_id,
             prch.corporate_name,
             prch.internal_contract_ref_no,
             prch.contract_ref_no,
             prch.internal_contract_item_ref_no,
             prch.del_distribution_item_no,
             prch.contract_issue_date,
             prch.contract_type,
             prch.contract_status,
             prch.int_alloc_group_id,
             prch.alloc_group_name,
             prch.internal_gmr_ref_no,
             prch.gmr_ref_no,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                dgrd.internal_dgrd_ref_no
               else
                prch.internal_grd_ref_no
             end internal_grd_ref_no,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                dgrd.internal_stock_ref_no
               else
                prch.internal_stock_ref_no
             end internal_stock_ref_no,
             prch.product_id,
             prch.product_name,
             prch.origin_id,
             prch.origin_name,
             prch.quality_id,
             prch.quality_name,
             prch.profit_center_id,
             prch.profit_center_name,
             prch.profit_center_short_name,
             prch.cp_profile_id,
             prch.cp_name,
             prch.trade_user_id,
             prch.trade_user_name,
             prch.price_type_id,
             prch.price_type_name,
             prch.incoterm_id,
             prch.incoterm,
             prch.payment_term_id,
             prch.payment_term,
             prch.price_fixation_status,
             'Previously Realized PNL Change' as realized_type,
             prch.realized_date,
             prch.container_no,
             prce.contract_price,
             prce.price_unit_id,
             prce.price_unit_cur_id,
             prce.price_unit_cur_code,
             prce.price_unit_weight_unit_id,
             prce.price_unit_weight_unit,
             prce.price_unit_weight,
             prce.contract_price as prev_real_price,
             prce.price_unit_id prev_real_price_id,
             prce.price_unit_cur_id prev_real_price_cur_id,
             prce.price_unit_cur_code prev_real_price_cur_code,
             prce.price_unit_weight_unit_id prev_real_price_weight_unit_id,
             prce.price_unit_weight_unit prev_real_price_weight_unit,
             prce.price_unit_weight prev_real_price_weight,
             prch.item_qty prev_real_qty,
             prch.qty_unit_id prev_real_qty_id,
             prch.qty_unit prev_real_qty_unit,
             prch.contract_value_in_price_cur prev_cont_value_in_price_cur,
             prce.contract_price_cur_id prev_contract_price_cur_id,
             prce.contract_price_cur_code prev_contract_price_cur_code,
             prch.contract_invoice_value as prev_real_contract_value,
             prch.secondary_cost_value prev_real_secondary_cost,
             prch.cog_net_sale_value prev_real_cog_net_sale_value,
             prch.realized_pnl prev_real_pnl,
             prch.tc_cost_per_unit prev_tc_cost_per_unit,
             prch.tc_cost_value prev_tc_cost_value,
             prch.rc_cost_per_unit prev_rc_cost_per_unit,
             prch.rc_cost_value prev_rc_cost_value,
             prch.pc_cost_per_unit prev_pc_cost_per_unit,
             prch.pc_cost_value prev_pc_cost_value,
             prch.secondary_cost_per_unit prev_secondary_cost_per_unit,
             prch.warehouse_id,
             prch.warehouse_name,
             prch.shed_id,
             prch.shed_name,
             prch.group_id,
             prch.group_name,
             prch.group_cur_id,
             prch.group_cur_code,
             prch.group_qty_unit_id,
             prch.group_qty_unit,
             prch.base_qty_unit_id,
             prch.base_qty_unit,
             prch.base_cur_id,
             prch.base_cur_code,
             prch.base_price_unit_id,
             prch.base_price_unit_name,
             prch.sales_profit_center_id,
             prch.sales_profit_center_name,
             prch.sales_profit_center_short_name,
             prch.sales_strategy_id,
             prch.sales_strategy_name,
             prch.sales_business_line_id,
             prch.sales_business_line_name,
             prch.sales_internal_gmr_ref_no,
             prch.sales_contract_ref_no,
             prch.origination_city_id,
             prch.origination_city_name,
             prch.origination_country_id,
             prch.origination_country_name,
             prch.destination_city_id,
             prch.destination_city_name,
             prch.destination_country_id,
             prch.destination_country_name,
             prch.pool_id,
             prch.strategy_id,
             prch.strategy_name,
             prch.business_line_id,
             prch.business_line_name,
             prch.bl_number,
             prch.bl_date,
             prch.seal_no,
             prch.mark_no,
             prch.warehouse_ref_no,
             prch.warehouse_receipt_no,
             prch.warehouse_receipt_date,
             prch.is_warrant,
             prch.warrant_no,
             prch.pcdi_id,
             prch.supp_contract_item_ref_no,
             prch.supplier_pcdi_id,
             prch.payable_returnable_type,
             prch.price_description,
             nvl(gscs.avg_cost_fw_rate, 0) secondary_cost_per_unit,
             prce.element_id,
             prce.element_name,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                dgrd.current_qty
               else
                prch.item_qty
             end item_qty,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                dgrd.net_weight_unit_id
               else
                prch.qty_unit_id
             end qty_unit_id,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                qum_dgrd.qty_unit
               else
                prch.qty_unit
             end qty_unit,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                spq.payable_qty
               else
                prce.payable_qty
             end payable_qty,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                spq.qty_unit_id
               else
                prce.payable_qty_unit_id
             end payable_qty_unit_id,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                qum_spq.qty_unit
               else
                prce.payable_qty_unit
             end payable_qty_unit,
             prch.delivery_item_no,
             rgmr.is_qty_change_for_sales,
             prch.item_qty_in_base_qty_unit,
             cm_ppu.cur_id del_premium_cur_id,
             cm_ppu.cur_code del_premium_cur_code,
             ppu.weight del_premium_weight,
             ppu.weight_unit_id del_premium_weight_unit_id,
             pd_trade_date payment_due_date,
             prch.sales_gmr_ref_no,
             gmr.latest_internal_invoice_ref_no,
             null accrual_to_base_fw_exch_rate,
             gscs.fw_rate_string sales_sc_exch_rate_string,
             dense_rank() over(partition by prch.internal_contract_item_ref_no order by prce.element_id) ele_rank,
             prch.unit_of_measure,
             case
               when rgmr.is_qty_change_for_sales = 'Y' then
                spq.assay_header_id
               else
                prch.ash_id
             end ash_id,
             prce.underlying_product_id,
             prce.underling_prod_qty_unit_id,
             prce.underling_base_qty_unit_id,
             null tc_charges_per_unit,
             null total_tc_charges,
             null tc_to_base_fw_exch_rate,
             null rc_charges_per_unit,
             null total_rc_charges,
             null rc_to_base_fw_exch_rate,
             null pc_charges_per_unit,
             null total_pc_charges,
             null pc_to_base_fw_exch_rate,
             prch.price_description prev_price_description,
             prch.elment_qty_details prev_elment_qty_details,
             prch.elment_price_details prev_elment_price_details,
             prch.dry_qty prev_dry_qty,
             prch.wet_qty prev_wet_qty,
             pcdb.premium location_premium_per_unit,
             pcdb.premium_unit_id location_premium_unit_id,
             null location_premium_fw_exch_rate,
             prch.location_premium_per_unit prev_location_premium_per_unit,
             prch.location_premium prev_location_premium,
             prch.location_premium_fw_exch_rate as p_loc_premium_fw_exch_rate,
             prce.prev_tc_to_base_fw_exch_rate pd_tc_to_base_fw_exch_rate,
             prce.prev_rc_to_base_fw_exch_rate pd_rc_to_base_fw_exch_rate,
             prce.tc_in_base_cur pd_tc_in_base_cur, -- D for detail
             prce.rc_in_base_cur pd_rc_in_base_cur,
             prce.price_to_base_fw_exch_rate pd_price_to_base_fw_exch_rate,
             prch.price_to_base_fw_exch_rate p_price_to_base_fw_exch_rate,
             prch.tc_to_base_fw_exch_rate p_tc_to_base_fw_exch_rate,
             prch.rc_to_base_fw_exch_rate p_rc_to_base_fw_exch_rate,
             prch.pc_to_base_fw_exch_rate p_pc_to_base_fw_exch_rate,
             prch.accrual_to_base_fw_exch_rate p_accrual_to_base_fw_exch_rate
        from prch_phy_realized_conc_header  prch,
             prce_phy_realized_conc_element prce,
             rgmrc_realized_gmr_conc        rgmr,
             gscs_gmr_sec_cost_summary      gscs,
             pcdb_pc_delivery_basis         pcdb,
             dgrd_delivered_grd             dgrd,
             qum_quantity_unit_master       qum_dgrd,
             v_ppu_pum                      ppu,
             cm_currency_master             cm_ppu,
             pcdi_pc_delivery_item          pcdi,
             spq_stock_payable_qty          spq,
             qum_quantity_unit_master       qum_spq,
             gmr_goods_movement_record      gmr
       where prch.internal_contract_item_ref_no =
             prce.internal_contract_item_ref_no
         and prch.internal_gmr_ref_no = prce.internal_gmr_ref_no
         and prch.process_id = rgmr.realized_process_id
         and prce.process_id = rgmr.realized_process_id
         and prch.contract_type = 'S'
         and rgmr.process_id = pc_process_id
         and prch.int_alloc_group_id = rgmr.int_alloc_group_id
         and prch.sales_internal_gmr_ref_no = rgmr.internal_gmr_ref_no
         and rgmr.realized_status = 'Previously Realized PNL Change'
         and rgmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
         and rgmr.process_id = gscs.process_id(+)
         and prch.internal_contract_ref_no = pcdb.internal_contract_ref_no
         and pcdb.process_id = pc_process_id
         and dgrd.int_alloc_group_id = prch.int_alloc_group_id
            --  and dgrd.internal_dgrd_ref_no = prch.internal_grd_ref_no
         and dgrd.process_id = pc_process_id
         and dgrd.status = 'Active'
         and dgrd.internal_dgrd_ref_no = spq.internal_dgrd_ref_no
         and prce.element_id = spq.element_id
         and spq.process_id = pc_process_id
         and qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id
         and qum_spq.qty_unit_id = dgrd.net_weight_unit_id
         and ppu.product_price_unit_id(+) = pcdb.premium_unit_id
         and ppu.cur_id = cm_ppu.cur_id(+)
         and prch.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.process_id = pc_process_id
         and dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and gmr.is_deleted = 'N'
         and spq.is_active = 'Y'
      union
      select pd_trade_date trade_date,
             prch.corporate_id,
             prch.corporate_name,
             prch.internal_contract_ref_no,
             prch.contract_ref_no,
             prch.internal_contract_item_ref_no,
             prch.del_distribution_item_no,
             prch.contract_issue_date,
             prch.contract_type,
             prch.contract_status,
             prch.int_alloc_group_id,
             prch.alloc_group_name,
             prch.internal_gmr_ref_no,
             prch.gmr_ref_no,
             prch.internal_grd_ref_no,
             prch.internal_stock_ref_no,
             prch.product_id,
             prch.product_name,
             prch.origin_id,
             prch.origin_name,
             prch.quality_id,
             prch.quality_name,
             prch.profit_center_id,
             prch.profit_center_name,
             prch.profit_center_short_name,
             prch.cp_profile_id,
             prch.cp_name,
             prch.trade_user_id,
             prch.trade_user_name,
             prch.price_type_id,
             prch.price_type_name,
             prch.incoterm_id,
             prch.incoterm,
             prch.payment_term_id,
             prch.payment_term,
             prch.price_fixation_status,
             'Previously Realized PNL Change' as realized_type,
             prch.realized_date,
             prch.container_no,
             invme.mc_per_unit contract_price,
             invme.mc_price_unit_id price_unit_id,
             invme.mc_price_unit_cur_id,
             invme.mc_price_unit_cur_code,
             invme.mc_price_unit_weight_unit_id,
             invme.mc_price_unit_weight_unit,
             invme.mc_price_unit_weight,
             prce.contract_price as prev_real_price,
             prce.price_unit_id prev_real_price_id,
             prce.price_unit_cur_id prev_real_price_cur_id,
             prce.price_unit_cur_code prev_real_price_cur_code,
             prce.price_unit_weight_unit_id prev_real_price_weight_unit_id,
             prce.price_unit_weight_unit prev_real_price_weight_unit,
             prce.price_unit_weight prev_real_price_weight,
             prch.item_qty prev_real_qty,
             prch.qty_unit_id prev_real_qty_id,
             prch.qty_unit prev_real_qty_unit,
             prch.contract_value_in_price_cur prev_cont_value_in_price_cur,
             prce.contract_price_cur_id prev_contract_price_cur_id,
             prce.contract_price_cur_code prev_contract_price_cur_code,
             prch.contract_invoice_value as prev_real_contract_value,
             prch.secondary_cost_value prev_real_secondary_cost,
             prch.cog_net_sale_value prev_real_cog_net_sale_value,
             prch.realized_pnl prev_real_pnl,
             prch.tc_cost_per_unit prev_tc_cost_per_unit,
             prch.tc_cost_value prev_tc_cost_value,
             prch.rc_cost_per_unit prev_rc_cost_per_unit,
             prch.rc_cost_value prev_rc_cost_value,
             prch.pc_cost_per_unit prev_pc_cost_per_unit,
             prch.pc_cost_value prev_pc_cost_value,
             prch.secondary_cost_per_unit prev_secondary_cost_per_unit,
             prch.warehouse_id,
             prch.warehouse_name,
             prch.shed_id,
             prch.shed_name,
             prch.group_id,
             prch.group_name,
             prch.group_cur_id,
             prch.group_cur_code,
             prch.group_qty_unit_id,
             prch.group_qty_unit,
             prch.base_qty_unit_id,
             prch.base_qty_unit,
             prch.base_cur_id,
             prch.base_cur_code,
             prch.base_price_unit_id,
             prch.base_price_unit_name,
             prch.sales_profit_center_id,
             prch.sales_profit_center_name,
             prch.sales_profit_center_short_name,
             prch.sales_strategy_id,
             prch.sales_strategy_name,
             prch.sales_business_line_id,
             prch.sales_business_line_name,
             prch.sales_internal_gmr_ref_no,
             prch.sales_contract_ref_no,
             prch.origination_city_id,
             prch.origination_city_name,
             prch.origination_country_id,
             prch.origination_country_name,
             prch.destination_city_id,
             prch.destination_city_name,
             prch.destination_country_id,
             prch.destination_country_name,
             prch.pool_id,
             prch.strategy_id,
             prch.strategy_name,
             prch.business_line_id,
             prch.business_line_name,
             prch.bl_number,
             prch.bl_date,
             prch.seal_no,
             prch.mark_no,
             prch.warehouse_ref_no,
             prch.warehouse_receipt_no,
             prch.warehouse_receipt_date,
             prch.is_warrant,
             prch.warrant_no,
             prch.pcdi_id,
             prch.supp_contract_item_ref_no,
             prch.supplier_pcdi_id,
             prch.payable_returnable_type,
             prch.price_description,
             invm.secondary_cost_per_unit secondary_cost_per_unit,
             prce.element_id,
             prce.element_name,
             prch.item_qty,
             prch.qty_unit_id,
             prch.qty_unit,
             prce.payable_qty,
             prce.payable_qty_unit_id,
             prce.payable_qty_unit,
             prch.delivery_item_no,
             rgmr.is_qty_change_for_sales,
             prch.item_qty_in_base_qty_unit,
             null del_premium_cur_id,
             null del_premium_cur_code,
             null del_premium_weight,
             null del_premium_weight_unit_id,
             pd_trade_date payment_due_date,
             prch.sales_gmr_ref_no,
             gmr.latest_internal_invoice_ref_no,
             invm.accrual_to_base_fw_exch_rate,
             null sales_sc_exch_rate_string,
             dense_rank() over(partition by prch.internal_contract_item_ref_no order by prce.element_id) ele_rank,
             prch.unit_of_measure,
             prch.ash_id,
             prce.underlying_product_id,
             prce.underling_prod_qty_unit_id,
             prce.underling_base_qty_unit_id,
             invm.tc_charges_per_unit,
             invm.total_tc_charges,
             invm.tc_to_base_fw_exch_rate,
             invm.rc_charges_per_unit,
             invm.total_rc_charges,
             invm.rc_to_base_fw_exch_rate,
             invm.pc_charges_per_unit,
             invm.total_pc_charges,
             invm.pc_to_base_fw_exch_rate,
             prch.price_description prev_price_description,
             prch.elment_qty_details prev_elment_qty_details,
             prch.elment_price_details prev_elment_price_details,
             prch.dry_qty prev_dry_qty,
             prch.wet_qty prev_wet_qty,
             invm.product_premium_per_unit location_premium_per_unit,
             invm.price_unit_id location_premium_price_unit_id,
             invm.contract_pp_fw_exch_rate location_premium_fw_exch_rate,
             prch.location_premium_per_unit prev_location_premium_per_unit,
             prch.location_premium prev_location_premium,
             prch.location_premium_fw_exch_rate as p_loc_premium_fw_exch_rate,
             prce.prev_tc_to_base_fw_exch_rate pd_tc_to_base_fw_exch_rate,
             prce.prev_rc_to_base_fw_exch_rate pd_rc_to_base_fw_exch_rate,
             prce.tc_in_base_cur pd_tc_in_base_cur, -- D for detail
             prce.rc_in_base_cur pd_rc_in_base_cur,
             prce.price_to_base_fw_exch_rate pd_price_to_base_fw_exch_rate,
             prch.price_to_base_fw_exch_rate p_price_to_base_fw_exch_rate,
             prch.tc_to_base_fw_exch_rate p_tc_to_base_fw_exch_rate,
             prch.rc_to_base_fw_exch_rate p_rc_to_base_fw_exch_rate,
             prch.pc_to_base_fw_exch_rate p_pc_to_base_fw_exch_rate,
             prch.accrual_to_base_fw_exch_rate p_accrual_to_base_fw_exch_rate
        from prch_phy_realized_conc_header  prch,
             prce_phy_realized_conc_element prce,
             rgmrc_realized_gmr_conc        rgmr,
             invm_cogs                      invm,
             invme_cogs_element             invme,
             grd_goods_record_detail        grd,
             agh_alloc_group_header         agh,
             agd_alloc_group_detail         agd,
             qum_quantity_unit_master       qum_agd,
             gmr_goods_movement_record      gmr
       where prch.internal_contract_item_ref_no =
             prce.internal_contract_item_ref_no
         and prch.internal_gmr_ref_no = prce.internal_gmr_ref_no
         and prch.process_id = rgmr.realized_process_id
         and prce.process_id = rgmr.realized_process_id
         and rgmr.process_id = pc_process_id
         and prch.int_alloc_group_id = rgmr.int_alloc_group_id
         and prch.sales_internal_gmr_ref_no = rgmr.internal_gmr_ref_no
         and prch.process_id = rgmr.realized_process_id
         and rgmr.realized_status = 'Previously Realized PNL Change'
         and prch.contract_type = 'P'
         and prch.internal_grd_ref_no = invme.internal_grd_ref_no
         and invme.sales_internal_gmr_ref_no =
             prch.sales_internal_gmr_ref_no
         and prce.element_id = invme.element_id
         and invm.sales_internal_gmr_ref_no =
             prch.sales_internal_gmr_ref_no
         and invm.internal_grd_ref_no = prch.internal_grd_ref_no
         and invm.process_id = pc_process_id
         and invme.process_id = pc_process_id
         and grd.internal_grd_ref_no = prch.internal_grd_ref_no
         and grd.process_id = pc_process_id
         and agd.internal_stock_ref_no = grd.internal_grd_ref_no
         and agd.process_id = pc_process_id
         and agh.int_alloc_group_id = agd.int_alloc_group_id
         and agh.process_id = pc_process_id
         and qum_agd.qty_unit_id = agd.qty_unit_id
         and grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.process_id = pc_process_id
         and gmr.is_deleted = 'N';
  
    cursor cur_update_pnl is
      select prch.corporate_id,
             prch.sales_internal_gmr_ref_no,
             prch.process_id,
             prch.int_alloc_group_id,
             nvl(sum(prch.cog_net_sale_value), 0) net_value
        from prch_phy_realized_conc_header prch
       where prch.process_id = pc_process_id
         and prch.corporate_id = pc_corporate_id
         and prch.realized_type = 'Previously Realized PNL Change'
       group by prch.corporate_id,
                prch.sales_internal_gmr_ref_no,
                prch.process_id,
                prch.int_alloc_group_id;
  
    vc_error_msg                   varchar2(10);
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vc_price_unit_cur_id           varchar2(15);
    vc_price_unit_cur_code         varchar2(15);
    vc_price_unit_weight_unit_id   varchar2(15);
    vc_price_unit_weight_unit      varchar2(15);
    vn_price_unit_weight           number;
    vn_qty_in_base_qty_unit_id     number;
    vn_sc_in_base_cur              number;
    vn_sc_per_unit                 number;
    vc_sc_to_base_fw_exch_rate     varchar2(50);
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_dry_qty                     number;
    vn_wet_qty                     number;
    vn_dry_qty_in_base             number;
    vn_ele_qty_in_base             number;
    vn_contract_value_in_price_cur number;
    vn_contract_value_in_base_cur  number;
    vn_price_to_base_fw_rate       number;
    vn_forward_points              number;
    vc_price_to_base_fw_rate       varchar2(25);
    vn_con_treatment_charge        number;
    vc_con_treatment_cur_id        varchar2(15);
    vn_base_con_treatment_charge   number;
    vn_con_refine_charge           number;
    vc_con_refine_cur_id           varchar2(15);
    vn_base_con_refine_charge      number;
    vc_con_tc_main_cur_id          varchar2(15);
    vc_con_tc_main_cur_code        varchar2(15);
    vc_con_tc_main_cur_factor      number;
    vn_con_tc_to_base_fw_rate      number;
    vc_contract_tc_fw_exch_rate    varchar2(50);
    vc_con_rc_main_cur_id          varchar2(15);
    vc_con_rc_main_cur_code        varchar2(15);
    vc_con_rc_main_cur_factor      number;
    vn_con_rc_to_base_fw_rate      number;
    vc_contract_rc_fw_exch_rate    varchar2(50);
    vn_con_penality_charge         number;
    vn_base_con_penality_charge    number;
    vc_con_penality_cur_id         varchar2(15);
    vc_con_pc_main_cur_id          varchar2(15);
    vc_con_pc_main_cur_code        varchar2(15);
    vn_con_pc_main_cur_factor      number;
    vn_con_pc_to_base_fw_rate      number;
    vc_contract_pc_fw_exch_rate    varchar2(50);
    vn_tc_charges_per_unit         number;
    vn_rc_charges_per_unit         number;
    vn_pc_charges_per_unit         number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vc_del_premium_main_cur_id     varchar2(15);
    vc_del_premium_main_cur_code   varchar2(15);
    vn_del_premium_cur_main_factor number;
    vn_fw_exch_rate_del_to_base    number;
    vc_contract_pp_fw_exch_rate    varchar2(100);
    vn_location_premium_per_unit   number;
    vn_location_premium            number;
    vc_del_premium_cur_id          varchar2(15);
    vn_del_premium_weight          number;
    vc_del_premium_weight_unit_id  varchar2(15);
    vc_base_price_unit_id          varchar2(15);
  begin
    --
    -- PNL Change for Quantity Change
    --
    delete from trgmrc_temp_rgmr_conc where corporate_id = pc_corporate_id;
    vc_error_msg := '1';
  
    insert into trgmrc_temp_rgmr_conc
      (corporate_id,
       int_alloc_group_id,
       internal_gmr_ref_no,
       realized_status,
       realized_process_id,
       realized_process_date,
       section_name,
       is_qty_change_for_sales)
      select pc_corporate_id,
             t.int_alloc_group_id,
             t.sales_internal_gmr_ref_no,
             'Previously Realized PNL Change',
             tdc.process_id,
             t.trade_date,
             t.section_name,
             is_qty_change_for_sales
        from (
              --
              -- Get the 'Realized Today', 'Previously Realized PNL Change' data for EOD/EOM
              --
              select prch.sales_internal_gmr_ref_no,
                      prch.int_alloc_group_id,
                      max(prch.trade_date) trade_date,
                      'Qty Change for Sales' section_name,
                      'Y' is_qty_change_for_sales
                from dgrdul_delivered_grd_ul       dgrdul,
                      dgrd_delivered_grd            dgrd,
                      prch_phy_realized_conc_header prch,
                      tdc_trade_date_closure        tdc,
                      agh_alloc_group_header        agh
               where dgrdul.internal_dgrd_ref_no = dgrd.internal_dgrd_ref_no
                 and dgrdul.process_id = pc_process_id
                 and dgrd.process_id = pc_process_id
                 and prch.corporate_id = pc_corporate_id
                 and prch.process_id = tdc.process_id
                 and tdc.process = pc_process
                 and prch.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
                 and prch.trade_date < pd_trade_date
                 and agh.int_alloc_group_id = prch.int_alloc_group_id
                 and agh.process_id = pc_process_id
                 and agh.realized_status = 'Realized'
                 and prch.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prch.sales_internal_gmr_ref_no,
                         prch.int_alloc_group_id) t,
             tdc_trade_date_closure tdc
       where tdc.corporate_id = pc_corporate_id
         and tdc.trade_date = t.trade_date
         and tdc.process = pc_process;
    vc_error_msg := '2';
    --
    -- PNL Change For Secondary Cost / Material Cost Change
    --                   
    insert into trgmrc_temp_rgmr_conc
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
             'Cost Change'
        from (select prch.sales_internal_gmr_ref_no,
                     prch.int_alloc_group_id,
                     max(prch.trade_date) trade_date
                from cdl_cost_delta_log            cdl,
                     cs_cost_store                 cs,
                     cigc_contract_item_gmr_cost   cigc,
                     prch_phy_realized_conc_header prch,
                     tdc_trade_date_closure        tdc,
                     scm_service_charge_master     scm,
                     agh_alloc_group_header        agh
               where cdl.process_id = pc_process_id
                 and cdl.cost_ref_no = cs.cost_ref_no
                 and cs.internal_cost_id = cs.internal_cost_id
                 and cs.cog_ref_no = cigc.cog_ref_no
                 and cs.process_id = cigc.process_id
                 and cigc.process_id = pc_process_id
                 and scm.cost_id = cs.cost_component_id
                 and scm.cost_type in ('DIRECT_COST', 'SECONDARY_COST')
                 and cigc.internal_gmr_ref_no = prch.internal_gmr_ref_no
                 and prch.trade_date = tdc.trade_date
                 and tdc.process = pc_process
                 and prch.trade_date < pd_trade_date
                 and agh.int_alloc_group_id = prch.int_alloc_group_id
                 and agh.process_id = pc_process_id
                 and agh.realized_status = 'Realized'
                 and prch.realized_type in
                     ('Realized Today', 'Previously Realized PNL Change')
               group by prch.sales_internal_gmr_ref_no,
                        prch.int_alloc_group_id) t,
             tdc_trade_date_closure tdc
       where tdc.corporate_id = pc_corporate_id
         and tdc.trade_date = t.trade_date
         and tdc.process = pc_process;
  
    vc_error_msg := '3';
  
    insert into rgmrc_realized_gmr_conc
      (process_id,
       int_alloc_group_id,
       internal_gmr_ref_no,
       realized_status,
       realized_process_id,
       realized_process_date,
       is_qty_change_for_sales)
      select pc_process_id,
             int_alloc_group_id,
             internal_gmr_ref_no,
             realized_status,
             realized_process_id,
             realized_process_date,
             max(is_qty_change_for_sales)
        from trgmrc_temp_rgmr_conc t
       where t.corporate_id = pc_corporate_id
       group by int_alloc_group_id,
                internal_gmr_ref_no,
                realized_status,
                realized_process_id,
                realized_process_date;
  
    for cur_realized_rows in cur_realized
    loop
      vc_sc_to_base_fw_exch_rate   := null;
      vc_price_to_base_fw_rate     := null;
      vc_contract_tc_fw_exch_rate  := null;
      vc_contract_rc_fw_exch_rate  := null;
      vc_contract_pc_fw_exch_rate  := null;
      vc_contract_pp_fw_exch_rate  := null;
      vn_location_premium_per_unit := 0;
      vn_location_premium          := 0;
      begin
        select ppu.product_price_unit_id
          into vc_base_price_unit_id
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
    
      if cur_realized_rows.contract_type = 'S' then
        if cur_realized_rows.latest_internal_invoice_ref_no is null then
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
              from iid_invoicable_item_details   iid,
                   iied_inv_item_element_details iied,
                   v_ppu_pum                     ppu,
                   cm_currency_master            cm,
                   qum_quantity_unit_master      qum
             where iid.internal_invoice_ref_no =
                   cur_realized_rows.latest_internal_invoice_ref_no
               and iid.new_invoice_price_unit_id =
                   ppu.product_price_unit_id
               and ppu.cur_id = cm.cur_id
               and ppu.weight_unit_id = qum.qty_unit_id
               and iid.internal_gmr_ref_no =
                   cur_realized_rows.internal_gmr_ref_no
               and iid.internal_invoice_ref_no =
                   iied.internal_invoice_ref_no
               and iied.element_id = cur_realized_rows.element_id
               and iied.grd_id = iid.stock_id
               and iid.stock_id = cur_realized_rows.internal_grd_ref_no
               and rownum < 2; -- Because IIED data at sub lots with same price, different quantity;
          exception
            when others then
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
    
      if cur_realized_rows.contract_type = 'P' then
        vc_sc_to_base_fw_exch_rate := cur_realized_rows.accrual_to_base_fw_exch_rate;
      else
        vc_sc_to_base_fw_exch_rate := cur_realized_rows.sales_sc_exch_rate_string;
      end if;
    
      --
      -- Pricing Main Currency Details
      --
      pkg_general.sp_get_main_cur_detail(vc_price_unit_cur_id,
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
      --
      -- Total Secondary Cost Value = Avg Seconadry Cost * Realized Qty in Product Base Unit
      --
      if cur_realized_rows.ele_rank = 1 then
        vn_sc_in_base_cur := cur_realized_rows.secondary_cost_per_unit *
                             vn_qty_in_base_qty_unit_id;
      
        vn_sc_per_unit := cur_realized_rows.secondary_cost_per_unit;
      end if;
    
      if cur_realized_rows.unit_of_measure = 'Wet' then
        vn_dry_qty := round(pkg_metals_general.fn_get_assay_dry_qty(cur_realized_rows.product_id,
                                                                    cur_realized_rows.ash_id,
                                                                    cur_realized_rows.item_qty,
                                                                    cur_realized_rows.qty_unit_id),
                            4);
      else
        vn_dry_qty := cur_realized_rows.item_qty;
      end if;
    
      vn_wet_qty := cur_realized_rows.item_qty;
    
      if cur_realized_rows.qty_unit_id <>
         cur_realized_rows.base_qty_unit_id then
        vn_dry_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                         cur_realized_rows.qty_unit_id,
                                                                         cur_realized_rows.base_qty_unit_id,
                                                                         1) *
                                    vn_dry_qty,
                                    4);
      else
        vn_dry_qty_in_base := round(vn_dry_qty, 4);
      
      end if;
    
      if cur_realized_rows.payable_qty_unit_id <>
         cur_realized_rows.underling_prod_qty_unit_id then
        vn_ele_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                         cur_realized_rows.payable_qty_unit_id,
                                                                         cur_realized_rows.underling_prod_qty_unit_id,
                                                                         1) *
                                    cur_realized_rows.payable_qty,
                                    cur_realized_rows.underling_base_qty_unit_id);
      else
        vn_ele_qty_in_base := round(cur_realized_rows.payable_qty,
                                    cur_realized_rows.underling_base_qty_unit_id);
      end if;
    
      vn_contract_value_in_price_cur := (vn_contract_price /
                                        nvl(vn_price_unit_weight, 1)) *
                                        vn_ele_qty_in_base *
                                        vn_cont_price_cur_id_factor *
                                        pkg_general.f_get_converted_quantity(cur_realized_rows.underlying_product_id,
                                                                             cur_realized_rows.payable_qty_unit_id,
                                                                             cur_realized_rows.underling_base_qty_unit_id,
                                                                             cur_realized_rows.item_qty);
    
      if vc_price_cur_id <> cur_realized_rows.base_cur_id then
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    pd_trade_date,
                                    vc_price_cur_id,
                                    cur_realized_rows.base_cur_id,
                                    30,
                                    'Concentrate Realized PNL Change Price to Base',
                                    pc_process,
                                    vn_price_to_base_fw_rate,
                                    vn_forward_points);
      
      else
        vn_price_to_base_fw_rate := 1;
      end if;
      vn_contract_value_in_base_cur := vn_contract_value_in_price_cur *
                                       vn_price_to_base_fw_rate;
    
      --
      -- Calcualte the TC, RC and Penalty
      --
      --
      --- contract refine chrges
      --
      begin
        select round((case
                       when getc.weight_type = 'Dry' then
                        vn_dry_qty * ucm.multiplication_factor * getc.tc_value
                       else
                        vn_wet_qty * ucm.multiplication_factor * getc.tc_value
                     end) * getc.currency_factor,
                     2),
               getc.tc_main_cur_id
          into vn_con_treatment_charge,
               vc_con_treatment_cur_id
          from getc_gmr_element_tc_charges getc,
               ucm_unit_conversion_master  ucm
         where getc.process_id = pc_process_id
           and getc.internal_gmr_ref_no =
               cur_realized_rows.internal_gmr_ref_no
           and getc.internal_grd_ref_no =
               cur_realized_rows.internal_grd_ref_no
           and getc.element_id = cur_realized_rows.element_id
           and ucm.from_qty_unit_id = cur_realized_rows.qty_unit_id
           and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
      exception
        when others then
          vn_con_treatment_charge := 0;
          vc_con_treatment_cur_id := null;
      end;
      vn_con_treatment_charge := vn_con_treatment_charge;
    
      -- Converted treatment charges to base currency
      if vc_con_treatment_cur_id <> cur_realized_rows.base_cur_id then
        -- Bank FX Rate from TC to Base Currency
        pkg_general.sp_get_base_cur_detail(vc_con_treatment_cur_id,
                                           vc_con_tc_main_cur_id,
                                           vc_con_tc_main_cur_code,
                                           vc_con_tc_main_cur_factor);
      
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    cur_realized_rows.payment_due_date,
                                    vc_con_tc_main_cur_id,
                                    cur_realized_rows.base_cur_id,
                                    30,
                                    'sp_phy_conc_realized_pnl Contract TC to Base Currency',
                                    pc_process,
                                    vn_con_tc_to_base_fw_rate,
                                    vn_forward_points);
      
        vn_base_con_treatment_charge := round((vn_con_treatment_charge *
                                              vn_con_tc_to_base_fw_rate *
                                              vc_con_tc_main_cur_factor),
                                              2);
        vc_contract_tc_fw_exch_rate  := '1 ' || vc_con_tc_main_cur_code || '=' ||
                                        vn_con_tc_to_base_fw_rate || ' ' ||
                                        cur_realized_rows.base_cur_code;
      else
        vn_base_con_treatment_charge := round(vn_con_treatment_charge, 2);
      
      end if;
    
      vc_error_msg := '852';
      --
      --- contract refine chrges
      --
    
      begin
        select round(gerc.rc_value * ucm.multiplication_factor *
                     cur_realized_rows.payable_qty,
                     2) * gerc.currency_factor,
               gerc.rc_main_cur_id
          into vn_con_refine_charge,
               vc_con_refine_cur_id
          from gerc_gmr_element_rc_charges gerc,
               ucm_unit_conversion_master  ucm
         where gerc.process_id = pc_process_id
           and gerc.internal_gmr_ref_no =
               cur_realized_rows.internal_gmr_ref_no
           and gerc.internal_grd_ref_no =
               cur_realized_rows.internal_grd_ref_no
           and gerc.element_id = cur_realized_rows.element_id
           and ucm.from_qty_unit_id = cur_realized_rows.payable_qty_unit_id
           and ucm.to_qty_unit_id = gerc.rc_weight_unit_id;
      exception
        when others then
          vn_con_refine_charge := 0;
          vc_con_refine_cur_id := null;
      end;
      vn_con_refine_charge := vn_con_refine_charge;
      --- Converted refine charges to base currency                                              
      if vc_con_refine_cur_id <> cur_realized_rows.base_cur_id then
        pkg_general.sp_get_base_cur_detail(vc_con_refine_cur_id,
                                           vc_con_rc_main_cur_id,
                                           vc_con_rc_main_cur_code,
                                           vc_con_rc_main_cur_factor);
      
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    cur_realized_rows.payment_due_date,
                                    vc_con_refine_cur_id,
                                    cur_realized_rows.base_cur_id,
                                    30,
                                    'sp_phy_conc_realized_pnl Contract RC to Base Currency',
                                    pc_process,
                                    vn_con_rc_to_base_fw_rate,
                                    vn_forward_points);
      
        vn_base_con_refine_charge := round((vn_con_refine_charge *
                                           vn_con_rc_to_base_fw_rate *
                                           vc_con_rc_main_cur_factor),
                                           2);
      
        vc_contract_rc_fw_exch_rate := '1 ' || vc_con_rc_main_cur_code || '=' ||
                                       vn_con_rc_to_base_fw_rate || ' ' ||
                                       cur_realized_rows.base_cur_code;
      
      else
        vn_base_con_refine_charge := round(vn_con_refine_charge, 2);
      end if;
      vc_error_msg := '906';
    
      -- Location Premium Current (I think it is unncecessary as premium cannot be changed from the app!!!!(Janna)
    
      if cur_realized_rows.contract_type = 'P' then
        vn_location_premium := vn_qty_in_base_qty_unit_id *
                               cur_realized_rows.location_premium_per_unit;
      
        vc_contract_pp_fw_exch_rate := cur_realized_rows.location_premium_fw_exch_rate;
      else
        --Sales Get Currency and Weight Details
        if cur_realized_rows.location_premium_per_unit <> 0 then
          if cur_realized_rows.location_premium_unit_id <>
             vc_base_price_unit_id then
            begin
              select ppu.cur_id,
                     nvl(ppu.weight, 1),
                     ppu.weight_unit_id
                into vc_del_premium_cur_id,
                     vn_del_premium_weight,
                     vc_del_premium_weight_unit_id
                from v_ppu_pum ppu
               where ppu.product_price_unit_id =
                     cur_realized_rows.location_premium_unit_id;
            exception
              when others then
                null;
            end;
            --
            -- Get the Main Currency of the Delivery Premium Price Unit
            --
            pkg_general.sp_get_base_cur_detail(vc_del_premium_cur_id,
                                               vc_del_premium_main_cur_id,
                                               vc_del_premium_main_cur_code,
                                               vn_del_premium_cur_main_factor);
            pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                        pd_trade_date,
                                        cur_realized_rows.payment_due_date,
                                        vc_del_premium_main_cur_id,
                                        cur_realized_rows.base_cur_id,
                                        30,
                                        'sp_calc_phy_conc_pnl_change Delivery to base',
                                        pc_process,
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
          
            vn_location_premium_per_unit := (cur_realized_rows.location_premium_per_unit /
                                            vn_del_premium_weight) *
                                            vn_del_premium_cur_main_factor *
                                            vn_fw_exch_rate_del_to_base *
                                            pkg_general.f_get_converted_quantity(cur_realized_rows.product_id,
                                                                                 vc_del_premium_weight_unit_id,
                                                                                 cur_realized_rows.base_qty_unit_id,
                                                                                 1);
          
          else
            vn_location_premium_per_unit := cur_realized_rows.location_premium_per_unit;
          end if;
          vn_location_premium := round(vn_location_premium_per_unit *
                                       vn_qty_in_base_qty_unit_id,
                                       2);
        else
          vn_location_premium_per_unit := 0;
          vn_location_premium          := 0;
        end if;
      end if;
      -- Contract penalty
      if cur_realized_rows.ele_rank = 1 then
        vc_error_msg := '911';
        vc_error_msg := '913';
        begin
          select round(sum(case
                             when gepc.weight_type = 'Dry' then
                              vn_dry_qty * ucm.multiplication_factor * gepc.pc_value
                             else
                              vn_wet_qty * ucm.multiplication_factor * gepc.pc_value
                           end),
                       2) * gepc.currency_factor,
                 gepc.pc_main_cur_id
            into vn_con_penality_charge,
                 vc_con_penality_cur_id
            from gepc_gmr_element_pc_charges gepc,
                 ucm_unit_conversion_master  ucm
           where gepc.process_id = pc_process_id
             and gepc.internal_gmr_ref_no =
                 cur_realized_rows.internal_gmr_ref_no
             and gepc.internal_grd_ref_no =
                 cur_realized_rows.internal_grd_ref_no
             and ucm.from_qty_unit_id = cur_realized_rows.qty_unit_id
             and ucm.to_qty_unit_id = gepc.pc_weight_unit_id
           group by gepc.pc_main_cur_id,
                    gepc.currency_factor;
        exception
          when others then
            vn_con_penality_charge := 0;
            vc_con_penality_cur_id := null;
        end;
      
        -- Convert to Base with Bank FX Rate
        vc_error_msg           := '914';
        vn_con_penality_charge := vn_con_penality_charge;
        if vn_con_penality_charge <> 0 then
          pkg_general.sp_get_base_cur_detail(vc_con_penality_cur_id,
                                             vc_con_pc_main_cur_id,
                                             vc_con_pc_main_cur_code,
                                             vn_con_pc_main_cur_factor);
          if vc_con_pc_main_cur_id <> cur_realized_rows.base_cur_id then
          
            pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                        pd_trade_date,
                                        cur_realized_rows.payment_due_date,
                                        vc_con_pc_main_cur_id,
                                        cur_realized_rows.base_cur_id,
                                        30,
                                        'sp_calc_phy_opencon_unreal_pnl Contract Penalty to Base Currency',
                                        pc_process,
                                        vn_con_pc_to_base_fw_rate,
                                        vn_forward_points);
            vc_error_msg                := '933';
            vn_base_con_penality_charge := round((vn_con_penality_charge *
                                                 vn_con_pc_to_base_fw_rate *
                                                 vn_con_pc_main_cur_factor),
                                                 2);
          
            vc_contract_pc_fw_exch_rate := '1 ' || vc_con_pc_main_cur_code || '=' ||
                                           vn_con_pc_to_base_fw_rate || ' ' ||
                                           cur_realized_rows.base_cur_code;
          
          else
            vn_base_con_penality_charge := round(vn_con_penality_charge, 2);
          
          end if;
        else
          vn_base_con_penality_charge := 0;
        end if;
      end if;
      if cur_realized_rows.ele_rank = 1 then
        insert into prch_phy_realized_conc_header
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
           price_fixation_status,
           realized_type,
           realized_sub_type,
           realized_date,
           container_no,
           item_qty,
           unit_of_measure,
           ash_id,
           dry_qty,
           wet_qty,
           dry_qty_in_base,
           qty_unit_id,
           qty_unit,
           contract_value_in_price_cur,
           contract_invoice_value,
           tc_cost_per_unit,
           tc_cost_value,
           rc_cost_per_unit,
           rc_cost_value,
           pc_cost_per_unit,
           pc_cost_value,
           secondary_cost_per_unit,
           secondary_cost_value,
           cog_net_sale_value,
           realized_pnl,
           prev_real_qty,
           prev_real_qty_id,
           prev_real_qty_unit,
           prev_cont_value_in_price_cur,
           prev_real_contract_value,
           prev_real_secondary_cost,
           prev_real_cog_net_sale_value,
           prev_real_pnl,
           prev_tc_per_unit,
           prev_rc_per_unit,
           prev_pc_per_unit,
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
           sales_gmr_ref_no,
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
           accrual_to_base_fw_exch_rate,
           tc_to_base_fw_exch_rate,
           rc_to_base_fw_exch_rate,
           pc_to_base_fw_exch_rate,
           prev_price_description,
           prev_elment_qty_details,
           prev_elment_price_details,
           prev_dry_qty,
           prev_wet_qty,
           prev_tc_cost_value,
           prev_rc_cost_value,
           prev_pc_cost_value,
           location_premium_per_unit,
           location_premium,
           location_premium_fw_exch_rate,
           prev_location_premium_per_unit,
           prev_location_premium,
           p_loc_premium_fw_exch_rate,
           p_price_to_base_fw_exch_rate,
           p_tc_to_base_fw_exch_rate,
           p_rc_to_base_fw_exch_rate,
           p_pc_to_base_fw_exch_rate,
           p_accrual_to_base_fw_exch_rate)
        values
          (pc_process_id,
           pd_trade_date,
           pc_corporate_id,
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
           null,
           cur_realized_rows.realized_type,
           null, --'v_realized_sub_type',
           cur_realized_rows.realized_date,
           cur_realized_rows.container_no,
           cur_realized_rows.item_qty,
           cur_realized_rows.unit_of_measure,
           cur_realized_rows.ash_id,
           vn_dry_qty,
           vn_wet_qty,
           vn_dry_qty_in_base,
           cur_realized_rows.qty_unit_id,
           cur_realized_rows.qty_unit,
           vn_contract_value_in_price_cur,
           null, -- contract_invoice_value update from pree,
           vn_tc_charges_per_unit,
           vn_base_con_treatment_charge,
           vn_rc_charges_per_unit,
           vn_base_con_refine_charge,
           vn_pc_charges_per_unit,
           vn_base_con_penality_charge,
           vn_sc_per_unit,
           vn_sc_in_base_cur,
           null, --'v_cog_net_sale_value',           
           null, --realized_pnl,          
           cur_realized_rows.prev_real_qty,
           cur_realized_rows.prev_real_qty_id,
           cur_realized_rows.prev_real_qty_unit,
           cur_realized_rows.prev_cont_value_in_price_cur,
           cur_realized_rows.prev_real_contract_value,
           cur_realized_rows.prev_real_secondary_cost,
           cur_realized_rows.prev_real_cog_net_sale_value,
           cur_realized_rows.prev_real_pnl,
           cur_realized_rows.prev_tc_cost_per_unit,
           cur_realized_rows.prev_rc_cost_per_unit,
           cur_realized_rows.prev_pc_cost_per_unit,
           cur_realized_rows.prev_secondary_cost_per_unit,
           null, --change_in_pnl,
           null, --'v_cfx_price_cur_to_base_cur',
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
           cur_realized_rows.sales_gmr_ref_no,
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
           vc_sc_to_base_fw_exch_rate,
           vc_contract_tc_fw_exch_rate,
           vc_contract_rc_fw_exch_rate,
           vc_contract_pc_fw_exch_rate,
           cur_realized_rows.prev_price_description,
           cur_realized_rows.prev_elment_qty_details,
           cur_realized_rows.prev_elment_price_details,
           cur_realized_rows.prev_dry_qty,
           cur_realized_rows.prev_wet_qty,
           cur_realized_rows.prev_tc_cost_value,
           cur_realized_rows.prev_rc_cost_value,
           cur_realized_rows.prev_pc_cost_value,
           vn_location_premium_per_unit,
           vn_location_premium,
           vc_contract_pp_fw_exch_rate,
           cur_realized_rows.prev_location_premium_per_unit,
           cur_realized_rows.prev_location_premium,
           cur_realized_rows.p_loc_premium_fw_exch_rate,
           cur_realized_rows.p_price_to_base_fw_exch_rate,
           cur_realized_rows.p_tc_to_base_fw_exch_rate,
           cur_realized_rows.p_rc_to_base_fw_exch_rate,
           cur_realized_rows.p_pc_to_base_fw_exch_rate,
           cur_realized_rows.p_accrual_to_base_fw_exch_rate);
      end if;
      insert into prce_phy_realized_conc_element
        (process_id,
         trade_date,
         int_alloc_group_id,
         sales_internal_gmr_ref_no,
         internal_contract_item_ref_no,
         del_distribution_item_no,
         internal_gmr_ref_no,
         internal_grd_ref_no,
         element_id,
         element_name,
         underlying_product_id,
         underling_prod_qty_unit_id,
         underling_base_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         payable_qty_unit,
         payable_qty_in_base_unit,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight_unit,
         price_unit_weight,
         price_to_base_fw_exch_rate,
         contract_value_in_price_cur,
         contract_value_in_base_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         prev_real_price,
         prev_real_price_id,
         prev_real_price_cur_id,
         prev_real_price_cur_code,
         prev_real_price_weight_unit_id,
         prev_real_price_weight_unit,
         prev_real_price_weight,
         prev_contract_price_cur_id,
         prev_contract_price_cur_code,
         tc_in_base_cur,
         rc_in_base_cur,
         tc_to_base_fw_exch_rate,
         rc_to_base_fw_exch_rate,
         prev_tc_in_base_cur,
         prev_rc_in_base_cur,
         prev_tc_to_base_fw_exch_rate,
         prev_rc_to_base_fw_exch_rate,
         p_price_to_base_fw_exch_rate)
      values
        (pc_process_id,
         pd_trade_date,
         cur_realized_rows.int_alloc_group_id,
         cur_realized_rows.sales_internal_gmr_ref_no,
         cur_realized_rows.internal_contract_item_ref_no,
         cur_realized_rows.del_distribution_item_no,
         cur_realized_rows.internal_gmr_ref_no,
         cur_realized_rows.internal_grd_ref_no,
         cur_realized_rows.element_id,
         cur_realized_rows.element_name,
         cur_realized_rows.underlying_product_id,
         cur_realized_rows.underling_prod_qty_unit_id,
         cur_realized_rows.underling_base_qty_unit_id,
         cur_realized_rows.payable_qty,
         cur_realized_rows.payable_qty_unit_id,
         cur_realized_rows.payable_qty_unit,
         vn_ele_qty_in_base,
         vn_contract_price,
         vc_price_unit_id,
         vc_price_unit_cur_id,
         vc_price_unit_cur_code,
         vc_price_unit_weight_unit_id,
         vc_price_unit_weight_unit,
         vn_price_unit_weight,
         vc_price_to_base_fw_rate,
         vn_contract_value_in_price_cur,
         vn_contract_value_in_base_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         cur_realized_rows.prev_real_price,
         cur_realized_rows.prev_real_price_id,
         cur_realized_rows.prev_real_price_cur_id,
         cur_realized_rows.prev_real_price_cur_code,
         cur_realized_rows.prev_real_price_weight_unit_id,
         cur_realized_rows.prev_real_price_weight_unit,
         cur_realized_rows.prev_real_price_weight,
         cur_realized_rows.prev_contract_price_cur_id,
         cur_realized_rows.prev_contract_price_cur_code,
         vn_con_treatment_charge,
         vn_con_refine_charge,
         vc_contract_tc_fw_exch_rate,
         vc_contract_rc_fw_exch_rate,
         cur_realized_rows.pd_tc_in_base_cur,
         cur_realized_rows.pd_rc_in_base_cur,
         cur_realized_rows.pd_tc_to_base_fw_exch_rate,
         cur_realized_rows.pd_rc_to_base_fw_exch_rate,
         cur_realized_rows.pd_price_to_base_fw_exch_rate);
    end loop;
    update prch_phy_realized_conc_header prch
       set (prch.contract_invoice_value, --
           prch.elment_qty_details, --
           prch.elment_price_details, prch.tc_cost_value, --
           prch.rc_cost_value) = --
            (select sum(prce.contract_value_in_base_cur),
                    stragg(prce.element_name || '-' || prce.payable_qty || ' ' ||
                           qum.qty_unit),
                    stragg(prce.element_name || '-' || prce.contract_price || ' ' ||
                           ppu.price_unit_name),
                    sum(prce.tc_in_base_cur),
                    sum(prce.rc_in_base_cur)
               from prce_phy_realized_conc_element prce,
                    qum_quantity_unit_master       qum,
                    v_ppu_pum                      ppu
              where prce.process_id = pc_process_id
                and prce.internal_contract_item_ref_no =
                    prch.internal_contract_item_ref_no
                and prce.internal_grd_ref_no = prch.internal_grd_ref_no
                and prce.payable_qty_unit_id = qum.qty_unit_id
                and prce.price_unit_id = ppu.product_price_unit_id
                and prch.int_alloc_group_id = prce.int_alloc_group_id
                and prch.sales_internal_gmr_ref_no =
                    prce.sales_internal_gmr_ref_no)
     where prch.process_id = pc_process_id;
    update prch_phy_realized_conc_header prch
       set prch.cog_net_sale_value = decode(prch.contract_type, 'P', -1, 1) *
                                     (prch.contract_invoice_value -
                                      nvl(prch.tc_cost_value, 0) -
                                      nvl(prch.rc_cost_value, 0) -
                                      nvl(prch.pc_cost_value, 0) +
                                      (decode(prch.contract_type, 'P', 1, -1) *
                                      nvl(abs(prch.secondary_cost_value), 0)) +
                                      nvl(prch.location_premium, 0))
     where prch.process_id = pc_process_id;
  
    --
    -- Update Realized PNL for Sales Contract
    --
    for cur_update_pnl_rows in cur_update_pnl
    loop
      update prch_phy_realized_conc_header prch
         set prch.realized_pnl  = cur_update_pnl_rows.net_value,
             prch.change_in_pnl = cur_update_pnl_rows.net_value -
                                  prch.prev_real_pnl
       where prch.corporate_id = cur_update_pnl_rows.corporate_id
         and prch.contract_type = 'S'
         and prch.realized_type = 'Previously Realized PNL Change'
         and prch.sales_internal_gmr_ref_no =
             cur_update_pnl_rows.sales_internal_gmr_ref_no
         and prch.int_alloc_group_id =
             cur_update_pnl_rows.int_alloc_group_id
         and prch.process_id = pc_process_id
         and prch.prev_real_pnl is not null;
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_conc_pnl_change Realized Today',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           dbms_utility.format_error_backtrace || ' ' ||
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
