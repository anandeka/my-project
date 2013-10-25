create or replace package pkg_phy_conc_unrealized_pnl is
  procedure sp_calc_phy_opencon_unreal_pnl(pc_corporate_id        varchar2,
                                           pd_trade_date          date,
                                           pc_process_id          varchar2,
                                           pc_dbd_id              varchar2,
                                           pc_user_id             varchar2,
                                           pc_process             varchar2,
                                           pc_previous_process_id varchar2);
  procedure sp_stock_unreal_sntt_conc(pc_corporate_id        varchar2,
                                      pd_trade_date          date,
                                      pc_process_id          varchar2,
                                      pc_dbd_id              varchar2,
                                      pc_user_id             varchar2,
                                      pc_process             varchar2,
                                      pc_previous_process_id varchar2);
  procedure sp_stock_unreal_inv_in_conc(pc_corporate_id        varchar2,
                                        pd_trade_date          date,
                                        pc_process_id          varchar2,
                                        pc_user_id             varchar2,
                                        pc_process             varchar2,
                                        pc_previous_process_id varchar2,
                                        pc_dbd_id              varchar2);

end; 
/
create or replace package body pkg_phy_conc_unrealized_pnl is
  procedure sp_calc_phy_opencon_unreal_pnl(pc_corporate_id        varchar2,
                                           pd_trade_date          date,
                                           pc_process_id          varchar2,
                                           pc_dbd_id              varchar2,
                                           pc_user_id             varchar2,
                                           pc_process             varchar2,
                                           pc_previous_process_id varchar2) is
  
    cursor cur_unrealized is
      select pcm.corporate_id,
             akc.corporate_name,
             pc_process_id,
             pcdi.pcdi_id,
             pcdi.delivery_item_no,
             pcdi.prefix,
             pcdi.middle_no,
             pcdi.suffix,
             pcdi.internal_contract_ref_no,
             pcm.contract_ref_no,
             pcm.issue_date,
             pci.internal_contract_item_ref_no,
             pci.del_distribution_item_no,
             pcdi.basis_type,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pcdi.transit_days,
             pcm.purchase_sales,
             pcm.contract_status,
             'Unrealized' unrealized_type,
             pcpd.profit_center_id,
             cpc.profit_center_name,
             cpc.profit_center_short_name,
             pcm.cp_id,
             phd_cp.companyname cp_name,
             pcm.trader_id,
             (case
               when pcm.trader_id is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook       gab,
                        ak_corporate_user@eka_appdb aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = pcm.trader_id)
               else
                ''
             end) trader_user_name,
             pcpd.product_id conc_product_id,
             pdm_conc.product_desc conc_product_name,
             aml.underlying_product_id product_id,
             pdm.product_desc product_name,
             ciqs.open_qty item_qty,
             ciqs.item_qty_unit_id qty_unit_id,
             qum.qty_unit,
             qum.decimals item_qty_decimal,
             pcpq.quality_template_id conc_quality_id,
             qat.quality_name conc_quality_name,
             qav.comp_quality_id quality_id,
             qat_und.quality_name,
             pcdb.inco_term_id,
             itm.incoterm,
             pcdb.city_id origination_city_id,
             cim1.city_name origination_city,
             pcdb.country_id origination_country_id,
             cym1.country_name origination_country,
             pcdb.city_id destination_city_id,
             cim2.city_name destination_city,
             pcdb.country_id destination_country_id,
             cym2.country_name destination_country,
             rem_cym1.region_id origination_region_id,
             rem_cym1.region_name origination_region,
             rem_cym2.region_id destination_region_id,
             rem_cym2.region_name destination_region,
             pcm.payment_term_id,
             pym.payment_term,
             cm.cur_id as base_cur_id,
             cm.cur_code as base_cur_code,
             cm.decimals as base_cur_decimal,
             gcd.groupid,
             gcd.groupname,
             cm_gcd.cur_id cur_id_gcd,
             cm_gcd.cur_code cur_code_gcd,
             qum_gcd.qty_unit_id qty_unit_id_gcd,
             qum_gcd.qty_unit qty_unit_gcd,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             qum_pdm.decimals as base_qty_decimal,
             qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
             qum_pdm_conc.qty_unit as conc_base_qty_unit,
             qum_pdm_conc.decimals as conc_base_qty_decimal,
             pcpd.strategy_id,
             css.strategy_name,
             cipde.element_id,
             aml.attribute_name,
             pcpq.assay_header_id,
             pcpq.unit_of_measure,
             ceqs.assay_qty,
             ceqs.assay_qty_unit_id,
             cipq.payable_qty,
             cipq.qty_unit_id payable_qty_unit_id,
             cipde.contract_price,
             cipde.price_unit_id,
             cipde.price_unit_cur_id,
             cipde.price_unit_cur_code,
             cipde.price_unit_weight_unit_id,
             cipde.price_unit_weight,
             cipde.price_unit_weight_unit,
             cipde.price_basis fixation_method,
             cipde.price_description,
             cipde.price_fixation_status,
             cipde.price_fixation_details,
             nvl(cipde.payment_due_date, pd_trade_date) payment_due_date,
             pci.expected_delivery_month || '-' ||
             pci.expected_delivery_year item_delivery_period_string,
             md.net_m2m_price net_m2m_price,
             md.m2m_price_unit_id,
             md.m2m_price_unit_cur_id,
             md.m2m_price_unit_cur_code,
             md.m2m_price_unit_weight,
             md.m2m_price_unit_weight_unit_id,
             md.m2m_price_unit_weight_unit,
             md.m2m_main_cur_id,
             md.m2m_main_cur_code,
             md.m2m_main_cur_decimals,
             md.main_currency_factor,
             md.md_id,
             0 m2m_amt,
             nvl(md.treatment_charge, 0) m2m_treatment_charge, -- will be in base price unit id
             nvl(md.refine_charge, 0) m2m_refining_charge, -- will be in base price unit id
             tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
             tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
             tc_ppu_pum.cur_id m2m_tc_cur_id,
             tc_ppu_pum.weight m2m_tc_weight,
             tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
             rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
             rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
             rc_ppu_pum.cur_id m2m_rc_cur_id,
             rc_ppu_pum.weight m2m_rc_weight,
             rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
             nvl(ciscs.avg_cost_fw_rate, 0) sc_in_base_cur,
             md.derivative_def_id,
             md.valuation_exchange_id,
             emt.exchange_name,
             md.valuation_dr_id,
             drm.dr_id_name,
             md.valuation_month,
             md.valuation_date,
             md.m2m_loc_incoterm_deviation,
             dense_rank() over(partition by cipde.internal_contract_item_ref_no order by cipde.element_id) ele_rank,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             pum_base_price_id.price_unit_name base_price_unit_name,
             pum_loc_base.weight_unit_id loc_qty_unit_id,
             tmpc.mvp_id,
             tmpc.shipment_month,
             tmpc.shipment_year,
             tmpc.valuation_point,
             nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying,
             ciscs.fw_rate_string accrual_to_base_fw_exch_rate,
             md.m2m_ld_fw_exch_rate,
             md.m2m_rc_fw_exch_rate,
             md.m2m_tc_fw_exch_rate,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             pcm.approval_status,
             (case
               when pcm.approval_status = 'Approved' then
                'Y'
               else
                'N'
             end) approval_flag
        from pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcdi_pc_delivery_item pcdi,
             pci_physical_contract_item pci,
             pcpd_pc_product_definition pcpd,
             cpc_corporate_profit_center cpc,
             phd_profileheaderdetails phd_cp,
             pdm_productmaster pdm,
             ciqs_contract_item_qty_status ciqs,
             qum_quantity_unit_master qum,
             pcpq_pc_product_quality pcpq,
             qat_quality_attributes qat,
             qat_quality_attributes qat_und,
             qav_quality_attribute_values qav,
             ppm_product_properties_mapping ppm,
             aml_attribute_master_list aml,
             pcdb_pc_delivery_basis pcdb,
             itm_incoterm_master itm,
             cim_citymaster cim1,
             cim_citymaster cim2,
             cym_countrymaster cym1,
             cym_countrymaster cym2,
             rem_region_master@eka_appdb rem_cym1,
             rem_region_master@eka_appdb rem_cym2,
             pym_payment_terms_master pym,
             cm_currency_master cm,
             gcd_groupcorporatedetails gcd,
             cm_currency_master cm_gcd,
             qum_quantity_unit_master qum_gcd,
             qum_quantity_unit_master qum_pdm,
             pdm_productmaster pdm_conc,
             qum_quantity_unit_master qum_pdm_conc,
             css_corporate_strategy_setup css,
             pum_price_unit_master pum_base_price_id,
             pum_price_unit_master pum_loc_base,
             cipde_cipd_element_price cipde,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type = 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'CONCENTRATES'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'CONCENTRATES'
                 and tmp.section_name = 'OPEN') tmpc,
             drm_derivative_master drm,
             emt_exchangemaster emt,
             v_ppu_pum tc_ppu_pum,
             v_ppu_pum rc_ppu_pum,
             cipq_contract_item_payable_qty cipq,
             ceqs_contract_ele_qty_status ceqs,
             ciscs_cisc_summary ciscs
       where pcm.corporate_id = akc.corporate_id
         and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpq.pcpd_id = pcpd.pcpd_id
         and pcpd.profit_center_id = cpc.profit_center_id
         and pcm.cp_id = phd_cp.profileid
         and pci.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and ciqs.item_qty_unit_id = qum.qty_unit_id
         and pci.pcpq_id = pcpq.pcpq_id
         and pcpq.quality_template_id = qat.quality_id
         and qat.quality_id = qav.quality_id
         and qav.attribute_id = ppm.property_id
         and qav.comp_quality_id = qat_und.quality_id
         and ppm.attribute_id = aml.attribute_id
         and aml.underlying_product_id = pdm.product_id
         and aml.attribute_id = cipde.element_id
         and pci.pcdb_id = pcdb.pcdb_id
         and pcdb.inco_term_id = itm.incoterm_id
         and pcdb.city_id = cim1.city_id(+)
         and pcdb.city_id = cim2.city_id(+)
         and pcdb.country_id = cym1.country_id(+)
         and pcdb.country_id = cym2.country_id(+)
         and cym1.region_id = rem_cym1.region_id(+)
         and cym2.region_id = rem_cym2.region_id(+)
         and pcm.payment_term_id = pym.payment_term_id
         and akc.base_cur_id = cm.cur_id
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id(+)
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id(+)
         and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         and pcpd.product_id = pdm_conc.product_id
         and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
         and pcpd.strategy_id = css.strategy_id
         and pci.internal_contract_item_ref_no =
             cipde.internal_contract_item_ref_no
         and pci.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.element_id = cipde.element_id
         and tmpc.internal_m2m_id = md.md_id(+)
         and md.element_id = cipde.element_id
         and md.valuation_dr_id = drm.dr_id(+)
         and md.valuation_exchange_id = emt.exchange_id(+)
         and pcm.corporate_id = pc_corporate_id
         and ciqs.open_qty > 0
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and pcpd.input_output = 'Input'
         and pcm.is_tolling_contract = 'N'
         and pcm.is_tolling_extn = 'N'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcdb.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and ciqs.is_active = 'Y'
         and ppm.is_active = 'Y'
         and ppm.is_deleted = 'N'
         and qav.is_deleted = 'N'
         and qav.is_comp_product_attribute = 'Y'
         and qat.is_active = 'Y'
         and qat.is_deleted = 'N'
         and aml.is_active = 'Y'
         and aml.is_deleted = 'N'
         and qat_und.is_active = 'Y'
         and qat_und.is_deleted = 'N'
         and md.base_price_unit_id_in_pum = pum_base_price_id.price_unit_id
         and md.base_price_unit_id_in_pum = pum_loc_base.price_unit_id
         and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
         and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
         and pci.internal_contract_item_ref_no =
             cipq.internal_contract_item_ref_no
         and aml.attribute_id = cipq.element_id
         and pci.internal_contract_item_ref_no =
             ceqs.internal_contract_item_ref_no
         and aml.attribute_id = ceqs.element_id
         and pcm.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and pcdb.process_id = pc_process_id
         and cipde.process_id = pc_process_id
         and cipq.process_id = pc_process_id
         and ceqs.process_id = pc_process_id
         and pci.internal_contract_item_ref_no =
             ciscs.internal_contract_item_ref_no(+)
         and pci.process_id = ciscs.process_id(+);
    vn_ele_qty_in_base             number;
    vn_ele_m2m_amt                 number;
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vn_ele_m2m_amount_in_base      number;
    vn_ele_m2m_total_amount        number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_ele_cont_value_in_price_cur number;
    vn_fx_price_to_base            number;
    vn_forward_exch_rate           number;
    vn_ele_cont_premium            number;
    vn_ele_cont_total_premium      number;
    vn_ele_cont_value_in_base_cur  number;
    vn_ele_exp_cog_in_base_cur     number;
    vn_ele_unreal_pnl_in_base_cur  number;
    vn_unrealized_pnl_in_m2m_unit  number;
    vc_m2m_price_unit_id           varchar2(15);
    vc_m2m_price_unit_cur_id       varchar2(15);
    vc_m2m_price_unit_cur_code     varchar2(15);
    vc_m2m_price_unit_wgt_unit_id  varchar2(15);
    vc_m2m_price_unit_wgt_unit     varchar2(15);
    vn_m2m_price_unit_wgt_unit_wt  number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_dry_qty                     number;
    vn_wet_qty                     number;
    vn_sc_in_base_cur              number;
    vn_qty_in_base                 number;
    vn_con_treatment_charge        number;
    vc_con_treatment_cur_id        varchar2(15);
    vn_base_con_treatment_charge   number;
    vn_con_refine_charge           number;
    vc_con_refine_cur_id           varchar2(15);
    vn_base_con_refine_charge      number;
    vn_con_penality_charge         number;
    vn_base_con_penality_charge    number;
    vc_con_penality_cur_id         varchar2(15);
    vn_dry_qty_in_base             number;
    vn_dry_qty_in_base_conc        number;
    vn_ele_m2m_treatment_charge    number;
    vn_ele_m2m_refine_charge       number;
    vn_loc_amount                  number;
    vn_loc_total_amount            number;
    vn_m2m_penality                number;
    vn_m2m_total_penality          number;
    vc_price_unit_id               varchar2(15);
    vc_con_tc_main_cur_id          varchar2(15);
    vc_con_tc_main_cur_code        varchar2(15);
    vc_con_tc_main_cur_factor      number;
    vn_con_tc_to_base_fw_rate      number;
    vn_forward_points              number;
    vc_contract_tc_fw_exch_rate    varchar2(50);
    vc_con_rc_main_cur_id          varchar2(15);
    vc_con_rc_main_cur_code        varchar2(15);
    vc_con_rc_main_cur_factor      number;
    vn_con_rc_to_base_fw_rate      number;
    vc_contract_rc_fw_exch_rate    varchar2(50);
    vc_con_pc_main_cur_id          varchar2(15);
    vc_con_pc_main_cur_code        varchar2(15);
    vc_con_pc_main_cur_factor      number;
    vn_con_pc_to_base_fw_rate      number;
    vc_contract_pc_fw_exch_rate    varchar2(50);
    vc_price_to_base_fw_rate       varchar2(25);
    vc_m2m_to_base_fw_rate         varchar2(25);
    vc_m2m_pc_fw_exch_rate         varchar2(50);
    vc_m2m_total_pc_fw_exch_rate   varchar2(50);
    vc_error_msg                   varchar2(100);
    -- M2M Varibles
    vc_m2m_tc_main_cur_id          varchar2(15);
    vc_m2m_tc_main_cur_code        varchar2(15);
    vc_m2m_tc_main_cur_factor      number;
    vn_m2m_tc_to_base_fw_rate      number;
    vc_m2m_rc_main_cur_id          varchar2(15);
    vc_m2m_rc_main_cur_code        varchar2(15);
    vc_m2m_rc_main_cur_factor      number;
    vn_m2m_rc_to_base_fw_rate      number;
    vn_cont_delivery_premium       number;
    vn_cont_del_premium_amt        number;
    vc_contract_pp_fw_exch_rate    varchar2(50);
    vc_base_price_unit_id          varchar2(15);
    vn_del_to_base_fw_rate         varchar2(50);
    vc_del_premium_cur_id          varchar2(15);
    vc_del_premium_cur_code        varchar2(15);
    vn_del_premium_weight          number;
    vc_del_premium_weight_unit_id  varchar2(15);
    vc_del_premium_main_cur_id     varchar2(15);
    vc_del_premium_main_cur_code   varchar2(15);
    vn_del_premium_cur_main_factor number;
  begin
    vc_error_msg := '10269';
    for cur_unrealized_rows in cur_unrealized
    loop
      vc_contract_tc_fw_exch_rate  := null;
      vc_contract_rc_fw_exch_rate  := null;
      vc_contract_pc_fw_exch_rate  := null;
      vc_price_to_base_fw_rate     := null;
      vc_contract_pp_fw_exch_rate  := null;
      vn_del_to_base_fw_rate       := null;
      vc_m2m_to_base_fw_rate       := null;
      vc_m2m_pc_fw_exch_rate       := null;
      vc_m2m_total_pc_fw_exch_rate := null;
    
      begin
        select ppu.product_price_unit_id
          into vc_base_price_unit_id
          from v_ppu_pum ppu
         where ppu.cur_id = cur_unrealized_rows.base_cur_id
           and ppu.weight_unit_id =
               cur_unrealized_rows.conc_base_qty_unit_id
           and nvl(ppu.weight, 1) = 1
           and ppu.product_id = cur_unrealized_rows.conc_product_id;
      exception
        when others then
          null;
      end;
      -- convert wet qty to dry qty
      if cur_unrealized_rows.unit_of_measure = 'Wet' then
        vn_dry_qty   := round(pkg_metals_general.fn_get_assay_dry_qty(cur_unrealized_rows.conc_product_id,
                                                                      cur_unrealized_rows.assay_header_id,
                                                                      cur_unrealized_rows.item_qty,
                                                                      cur_unrealized_rows.qty_unit_id),
                              cur_unrealized_rows.item_qty_decimal);
        vc_error_msg := '10279';
      else
        vn_dry_qty := round(cur_unrealized_rows.item_qty,
                            cur_unrealized_rows.item_qty_decimal);
      end if;
    
      vn_wet_qty := cur_unrealized_rows.item_qty;
      -- convert into dry qty to base qty element level
      vn_dry_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                       cur_unrealized_rows.qty_unit_id,
                                                                       cur_unrealized_rows.base_qty_unit_id,
                                                                       1) *
                                  vn_dry_qty,
                                  cur_unrealized_rows.base_qty_decimal);
    
      vc_error_msg := '10295';
      if cur_unrealized_rows.qty_unit_id <>
         cur_unrealized_rows.conc_base_qty_unit_id then
        vn_dry_qty_in_base_conc := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                              cur_unrealized_rows.qty_unit_id,
                                                                              cur_unrealized_rows.conc_base_qty_unit_id,
                                                                              1) *
                                         vn_dry_qty,
                                         cur_unrealized_rows.conc_base_qty_decimal);
      else
        vn_dry_qty_in_base_conc := round(vn_dry_qty,
                                         cur_unrealized_rows.conc_base_qty_decimal);
      
      end if;
    
      -- contract treatment charges
      pkg_metals_general.sp_get_treatment_charge(cur_unrealized_rows.internal_contract_item_ref_no,
                                                 cur_unrealized_rows.element_id,
                                                 pc_dbd_id,
                                                 vn_dry_qty,
                                                 vn_wet_qty,
                                                 cur_unrealized_rows.qty_unit_id,
                                                 cur_unrealized_rows.contract_price,
                                                 cur_unrealized_rows.price_unit_id,
                                                 vn_con_treatment_charge,
                                                 vc_con_treatment_cur_id);
      vc_error_msg := '10307';
      if vn_con_treatment_charge is null then
        vn_con_treatment_charge := 0;
      end if;
      -- Converted treatment charges to base currency
      if (vc_con_treatment_cur_id <> cur_unrealized_rows.base_cur_id) and
         vn_con_treatment_charge <> 0 then
        -- Bank FX Rate from TC to Base Currency
        vc_error_msg := '10311';
        pkg_general.sp_get_base_cur_detail(vc_con_treatment_cur_id,
                                           vc_con_tc_main_cur_id,
                                           vc_con_tc_main_cur_code,
                                           vc_con_tc_main_cur_factor);
        vc_error_msg := '10316';
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    cur_unrealized_rows.payment_due_date,
                                    vc_con_tc_main_cur_id,
                                    cur_unrealized_rows.base_cur_id,
                                    30,
                                    'sp_calc_phy_opencon_unreal_pnl TC to Base Currency',
                                    pc_process,
                                    vn_con_tc_to_base_fw_rate,
                                    vn_forward_points);
        vc_error_msg                 := '10325';
        vn_base_con_treatment_charge := round((vn_con_treatment_charge *
                                              vn_con_tc_to_base_fw_rate *
                                              vc_con_tc_main_cur_factor),
                                              cur_unrealized_rows.base_cur_decimal);
        vc_contract_tc_fw_exch_rate  := '1 ' || vc_con_tc_main_cur_code || '=' ||
                                        vn_con_tc_to_base_fw_rate || ' ' ||
                                        cur_unrealized_rows.base_cur_code;
      else
        vc_error_msg                 := '10334';
        vn_con_tc_to_base_fw_rate    := 1;
        vn_base_con_treatment_charge := round(vn_con_treatment_charge,
                                              cur_unrealized_rows.base_cur_decimal);
      
      end if;
      vc_error_msg := '10338';
      --- contract refine chrges
      pkg_metals_general.sp_get_refine_charge(cur_unrealized_rows.internal_contract_item_ref_no,
                                              cur_unrealized_rows.element_id,
                                              pc_dbd_id,
                                              cur_unrealized_rows.payable_qty,
                                              cur_unrealized_rows.payable_qty_unit_id,
                                              cur_unrealized_rows.contract_price,
                                              cur_unrealized_rows.price_unit_id,
                                              vn_con_refine_charge,
                                              vc_con_refine_cur_id);
      vc_error_msg := '10350';
      if vn_con_refine_charge is null then
        vn_con_refine_charge := 0;
      end if;
      --- Converted refine charges to base currency                                              
      if (vc_con_refine_cur_id <> cur_unrealized_rows.base_cur_id) and
         vn_con_refine_charge <> 0 then
        pkg_general.sp_get_base_cur_detail(vc_con_refine_cur_id,
                                           vc_con_rc_main_cur_id,
                                           vc_con_rc_main_cur_code,
                                           vc_con_rc_main_cur_factor);
      
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    cur_unrealized_rows.payment_due_date,
                                    vc_con_refine_cur_id,
                                    cur_unrealized_rows.base_cur_id,
                                    30,
                                    'sp_calc_phy_opencon_unreal_pnl RC to Base Currency',
                                    pc_process,
                                    vn_con_rc_to_base_fw_rate,
                                    vn_forward_points);
        vc_error_msg              := '10366';
        vn_base_con_refine_charge := round((vn_con_refine_charge *
                                           vn_con_rc_to_base_fw_rate *
                                           vc_con_rc_main_cur_factor),
                                           cur_unrealized_rows.base_cur_decimal);
      
        vc_contract_rc_fw_exch_rate := '1 ' || vc_con_rc_main_cur_code || '=' ||
                                       vn_con_rc_to_base_fw_rate || ' ' ||
                                       cur_unrealized_rows.base_cur_code;
      
      else
        vn_con_rc_to_base_fw_rate := 1;
        vn_base_con_refine_charge := round(vn_con_refine_charge,
                                           cur_unrealized_rows.base_cur_decimal);
      end if;
      vc_error_msg := '10380';
    
      --- contract penality charges   
      if cur_unrealized_rows.ele_rank = 1 then
        pkg_metals_general.sp_get_penalty_charge(cur_unrealized_rows.internal_contract_item_ref_no,
                                                 pc_dbd_id,
                                                 vn_dry_qty,
                                                 cur_unrealized_rows.qty_unit_id,
                                                 vn_con_penality_charge,
                                                 vc_con_penality_cur_id);
      
        -- Convert to Base with Bank FX Rate
        vc_error_msg := '10391';
        if vn_con_penality_charge <> 0 then
          vc_error_msg := '1039WWW1 ' || vc_con_penality_cur_id;
          vc_error_msg := 'vn_con_penality_charge ' ||
                          vn_con_penality_charge || ' ' ||
                          vc_con_penality_cur_id;
        
          pkg_general.sp_get_base_cur_detail(vc_con_penality_cur_id,
                                             vc_con_pc_main_cur_id,
                                             vc_con_pc_main_cur_code,
                                             vc_con_pc_main_cur_factor);
        
          if vc_con_pc_main_cur_id <> cur_unrealized_rows.base_cur_id then
          
            pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                        pd_trade_date,
                                        cur_unrealized_rows.payment_due_date,
                                        vc_con_pc_main_cur_id,
                                        cur_unrealized_rows.base_cur_id,
                                        30,
                                        'sp_calc_phy_opencon_unreal_pnl Contract Penalty to Base Currency',
                                        pc_process,
                                        vn_con_pc_to_base_fw_rate,
                                        vn_forward_points);
            vc_error_msg                := '10406';
            vn_base_con_penality_charge := round((vn_con_penality_charge *
                                                 vn_con_pc_to_base_fw_rate *
                                                 vc_con_pc_main_cur_factor),
                                                 cur_unrealized_rows.base_cur_decimal);
          
            vc_contract_pc_fw_exch_rate := '1 ' || vc_con_pc_main_cur_code || '=' ||
                                           vn_con_pc_to_base_fw_rate || ' ' ||
                                           cur_unrealized_rows.base_cur_code;
          
          else
            vn_base_con_penality_charge := round(vn_con_penality_charge,
                                                 cur_unrealized_rows.base_cur_decimal);
          
          end if;
        else
          vn_base_con_penality_charge := 0;
        end if;
      end if;
      vc_error_msg   := '10422';
      vn_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                   cur_unrealized_rows.qty_unit_id,
                                                                   cur_unrealized_rows.conc_base_qty_unit_id,
                                                                   1) *
                              vn_wet_qty,
                              cur_unrealized_rows.conc_base_qty_decimal);
    
      vn_ele_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                       cur_unrealized_rows.payable_qty_unit_id,
                                                                       cur_unrealized_rows.base_qty_unit_id,
                                                                       1) *
                                  cur_unrealized_rows.payable_qty,
                                  cur_unrealized_rows.base_qty_decimal);
      vc_error_msg       := '10435';
      if cur_unrealized_rows.valuation_against_underlying = 'Y' then
        vn_ele_m2m_amt := nvl(cur_unrealized_rows.net_m2m_price, 0) /
                          nvl(cur_unrealized_rows.m2m_price_unit_weight, 1) *
                          pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                               cur_unrealized_rows.payable_qty_unit_id,
                                                               cur_unrealized_rows.m2m_price_unit_weight_unit_id,
                                                               cur_unrealized_rows.payable_qty);
      
        pkg_general.sp_get_main_cur_detail(nvl(cur_unrealized_rows.m2m_price_unit_cur_id,
                                               cur_unrealized_rows.base_cur_id),
                                           vc_m2m_cur_id,
                                           vc_m2m_cur_code,
                                           vn_m2m_sub_cur_id_factor,
                                           vn_m2m_cur_decimals);
        vn_ele_m2m_amt := round(vn_ele_m2m_amt * vn_m2m_sub_cur_id_factor,
                                vn_m2m_cur_decimals);
        vc_error_msg   := '10453';
        pkg_general.sp_bank_fx_rate(cur_unrealized_rows.corporate_id,
                                    pd_trade_date,
                                    cur_unrealized_rows.payment_due_date,
                                    vc_m2m_cur_id,
                                    cur_unrealized_rows.base_cur_id,
                                    30,
                                    'sp_calc_phy_opencon_unreal_pnl M2M to Base Currency',
                                    pc_process,
                                    vn_m2m_base_fx_rate,
                                    vn_m2m_base_deviation);
        if vc_m2m_cur_id <> cur_unrealized_rows.base_cur_id then
          if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
            null;
          else
            vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                      vn_m2m_base_fx_rate || ' ' ||
                                      cur_unrealized_rows.base_cur_code;
          
          end if;
        else
          vn_m2m_base_fx_rate := 1;
        end if;
        vn_ele_m2m_amount_in_base := round(vn_ele_m2m_amt *
                                           vn_m2m_base_fx_rate,
                                           cur_unrealized_rows.base_cur_decimal);
      else
        vn_ele_m2m_amt := nvl(cur_unrealized_rows.net_m2m_price, 0) /
                          nvl(cur_unrealized_rows.m2m_price_unit_weight, 1) *
                          pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                               cur_unrealized_rows.conc_base_qty_unit_id,
                                                               cur_unrealized_rows.m2m_price_unit_weight_unit_id,
                                                               vn_dry_qty_in_base);
      
        pkg_general.sp_get_main_cur_detail(nvl(cur_unrealized_rows.m2m_price_unit_cur_id,
                                               cur_unrealized_rows.base_cur_id),
                                           vc_m2m_cur_id,
                                           vc_m2m_cur_code,
                                           vn_m2m_sub_cur_id_factor,
                                           vn_m2m_cur_decimals);
        vn_ele_m2m_amt := round(vn_ele_m2m_amt * vn_m2m_sub_cur_id_factor,
                                vn_m2m_cur_decimals);
      
        pkg_general.sp_bank_fx_rate(cur_unrealized_rows.corporate_id,
                                    pd_trade_date,
                                    cur_unrealized_rows.payment_due_date,
                                    vc_m2m_cur_id,
                                    cur_unrealized_rows.base_cur_id,
                                    30,
                                    'sp_calc_phy_opencon_unreal_pnl M2M to Base Currency',
                                    pc_process,
                                    vn_m2m_base_fx_rate,
                                    vn_m2m_base_deviation);
        vc_error_msg := '10513';
        if vc_m2m_cur_id <> cur_unrealized_rows.base_cur_id then
          if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
            null;
          else
            vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                      vn_m2m_base_fx_rate || ' ' ||
                                      cur_unrealized_rows.base_cur_code;
          
          end if;
        end if;
        if cur_unrealized_rows.ele_rank = 1 then
          vn_ele_m2m_amount_in_base := vn_ele_m2m_amt * vn_m2m_base_fx_rate;
        else
          vn_ele_m2m_amount_in_base := 0;
          vn_ele_m2m_amt            := 0;
        end if;
      end if;
      vc_error_msg := '10546';
    
      if cur_unrealized_rows.ele_rank = 1 then
      
        vn_cont_delivery_premium := 0;
        vn_cont_del_premium_amt  := 0;
      
        if cur_unrealized_rows.delivery_premium <> 0 then
          if cur_unrealized_rows.delivery_premium_unit_id <>
             vc_base_price_unit_id then
          
            vc_error_msg := '11';
            --
            -- Get the Delivery Premium Currency 
            --
            select ppu.cur_id,
                   cm.cur_code,
                   nvl(ppu.weight, 1),
                   ppu.weight_unit_id
              into vc_del_premium_cur_id,
                   vc_del_premium_cur_code,
                   vn_del_premium_weight,
                   vc_del_premium_weight_unit_id
              from v_ppu_pum          ppu,
                   cm_currency_master cm
             where ppu.product_price_unit_id =
                   cur_unrealized_rows.delivery_premium_unit_id
               and cm.cur_id = ppu.cur_id;
            --
            -- Get the Main Currency of the Delivery Premium Price Unit
            --
            vc_error_msg := '12';
            pkg_general.sp_get_base_cur_detail(vc_del_premium_cur_id,
                                               vc_del_premium_main_cur_id,
                                               vc_del_premium_main_cur_code,
                                               vn_del_premium_cur_main_factor);
          
            pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                        pd_trade_date,
                                        cur_unrealized_rows.payment_due_date,
                                        vc_del_premium_main_cur_id,
                                        cur_unrealized_rows.base_cur_id,
                                        30,
                                        'Sp_calc_phy_oepncon_unreal_pnl Delivery To Base Currency',
                                        pc_process,
                                        vn_del_to_base_fw_rate,
                                        vn_forward_points);
          
            vc_error_msg := '13';
          
            vn_cont_delivery_premium := (cur_unrealized_rows.delivery_premium /
                                        vn_del_premium_weight) *
                                        vn_del_premium_cur_main_factor *
                                        vn_del_to_base_fw_rate *
                                        pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                             vc_del_premium_weight_unit_id,
                                                                             cur_unrealized_rows.conc_base_qty_unit_id,
                                                                             1);
            vc_error_msg             := '14';
            if cur_unrealized_rows.base_cur_code <>
               vc_del_premium_main_cur_code then
              vc_contract_pp_fw_exch_rate := '1 ' ||
                                             vc_del_premium_main_cur_code || '=' ||
                                             vn_del_to_base_fw_rate || ' ' ||
                                             cur_unrealized_rows.base_cur_code;
            end if;
          
            if cur_unrealized_rows.base_cur_code <>
               vc_del_premium_main_cur_code then
              if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
                vobj_error_log.extend;
                vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                     'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                     'PHY-005',
                                                                     cur_unrealized_rows.base_cur_code ||
                                                                     ' to ' ||
                                                                     vc_del_premium_main_cur_code || ' (' ||
                                                                     to_char(cur_unrealized_rows.payment_due_date,
                                                                             'dd-Mon-yyyy') || ') ',
                                                                     '',
                                                                     pc_process,
                                                                     pc_user_id,
                                                                     sysdate,
                                                                     pd_trade_date);
                sp_insert_error_log(vobj_error_log);
              end if;
            end if;
          else
            vn_cont_delivery_premium := cur_unrealized_rows.delivery_premium;
          end if;
          vn_cont_del_premium_amt := round(vn_cont_delivery_premium *
                                           vn_qty_in_base,
                                           2);
        else
          vn_cont_delivery_premium := 0;
          vn_cont_del_premium_amt  := 0;
        end if;
      end if;
      -- Forward Rate from M2M Treatment Charge to Base Currency
      pkg_general.sp_get_base_cur_detail(cur_unrealized_rows.m2m_tc_cur_id,
                                         vc_m2m_tc_main_cur_id,
                                         vc_m2m_tc_main_cur_code,
                                         vc_m2m_tc_main_cur_factor);
      if vc_m2m_tc_main_cur_id <> cur_unrealized_rows.base_cur_id then
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    cur_unrealized_rows.payment_due_date,
                                    cur_unrealized_rows.m2m_tc_cur_id,
                                    cur_unrealized_rows.base_cur_id,
                                    30,
                                    'sp_calc_phy_opencon_unreal_pnl M2M TC to Base Currency',
                                    pc_process,
                                    vn_m2m_tc_to_base_fw_rate,
                                    vn_forward_points);
      else
        vn_m2m_tc_to_base_fw_rate := 1;
      end if;
    
      vn_ele_m2m_treatment_charge := round((cur_unrealized_rows.m2m_treatment_charge /
                                           nvl(cur_unrealized_rows.m2m_tc_weight,
                                                1)) *
                                           vn_m2m_tc_to_base_fw_rate *
                                           (pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                                 cur_unrealized_rows.qty_unit_id,
                                                                                 cur_unrealized_rows.m2m_tc_weight_unit_id,
                                                                                 vn_dry_qty)),
                                           cur_unrealized_rows.base_cur_decimal);
      vc_error_msg                := '10554';
      -- Forward Rate from M2M Refining Charge to Base Currency
    
      pkg_general.sp_get_base_cur_detail(cur_unrealized_rows.m2m_rc_cur_id,
                                         vc_m2m_rc_main_cur_id,
                                         vc_m2m_rc_main_cur_code,
                                         vc_m2m_rc_main_cur_factor);
      if vc_m2m_rc_main_cur_id <> cur_unrealized_rows.base_cur_id then
        pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                    pd_trade_date,
                                    cur_unrealized_rows.payment_due_date,
                                    cur_unrealized_rows.m2m_rc_cur_id,
                                    cur_unrealized_rows.base_cur_id,
                                    30,
                                    'sp_calc_phy_opencon_unreal_pnl M2M RC to Base Currency',
                                    pc_process,
                                    vn_m2m_rc_to_base_fw_rate,
                                    vn_forward_points);
      else
        vn_m2m_rc_to_base_fw_rate := 1;
      end if;
    
      vn_ele_m2m_refine_charge := round((cur_unrealized_rows.m2m_refining_charge /
                                        nvl(cur_unrealized_rows.m2m_rc_weight,
                                             1)) *
                                        vn_m2m_rc_to_base_fw_rate *
                                        (pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                              cur_unrealized_rows.payable_qty_unit_id,
                                                                              cur_unrealized_rows.m2m_rc_weight_unit_id,
                                                                              cur_unrealized_rows.payable_qty)),
                                        cur_unrealized_rows.base_cur_decimal);
    
      vn_loc_amount       := pkg_general.f_get_converted_quantity(cur_unrealized_rows.conc_product_id,
                                                                  cur_unrealized_rows.qty_unit_id,
                                                                  cur_unrealized_rows.conc_base_qty_unit_id,
                                                                  1) *
                             cur_unrealized_rows.m2m_loc_incoterm_deviation;
      vn_loc_total_amount := round(vn_loc_amount * vn_qty_in_base,
                                   cur_unrealized_rows.base_cur_decimal);
    
      vn_m2m_total_penality := 0;
      vc_error_msg          := '1074';
      if cur_unrealized_rows.ele_rank = 1 then
        begin
          select ppu.product_price_unit_id
            into vc_price_unit_id
            from v_ppu_pum         ppu,
                 pdm_productmaster pdm,
                 ak_corporate      akc
           where ppu.product_id = cur_unrealized_rows.conc_product_id
             and ppu.product_id = pdm.product_id
             and pdm.base_quantity_unit = ppu.weight_unit_id
             and ppu.cur_id = akc.base_cur_id
             and nvl(ppu.weight, 1) = 1
             and akc.corporate_id = pc_corporate_id;
        
        exception
          when no_data_found then
            vc_price_unit_id := null;
        end;
        vn_m2m_total_penality := 0;
        for cc in (select pci.internal_contract_item_ref_no,
                          pqca.element_id,
                          aml.attribute_name,
                          pcpq.quality_template_id
                     from pci_physical_contract_item  pci,
                          pcpq_pc_product_quality     pcpq,
                          ash_assay_header            ash,
                          asm_assay_sublot_mapping    asm,
                          pqca_pq_chemical_attributes pqca,
                          aml_attribute_master_list   aml
                    where pci.pcpq_id = pcpq.pcpq_id
                      and pcpq.assay_header_id = ash.ash_id
                      and ash.ash_id = asm.ash_id
                      and asm.asm_id = pqca.asm_id
                      and pqca.element_id=aml.attribute_id
                      and pci.process_id = pc_process_id
                      and pcpq.process_id = pc_process_id
                      and pci.is_active = 'Y'
                      and pcpq.is_active = 'Y'
                      and ash.is_active = 'Y'
                      and asm.is_active = 'Y'
                      and pqca.is_active = 'Y'
                      and pqca.is_elem_for_pricing = 'N'
                      and pci.internal_contract_item_ref_no =
                          cur_unrealized_rows.internal_contract_item_ref_no)
        loop
          pkg_phy_pre_check_process.sp_m2m_tc_pc_rc_charge(cur_unrealized_rows.corporate_id,
                                                           pd_trade_date,
                                                           cur_unrealized_rows.conc_product_id,
                                                           cur_unrealized_rows.conc_quality_id,
                                                           cur_unrealized_rows.mvp_id,
                                                           'Penalties',
                                                           cc.element_id,
                                                           to_char(pd_trade_date,
                                                                   'Mon'),
                                                           to_char(pd_trade_date,
                                                                   'YYYY'),
                                                           vc_price_unit_id,
                                                           cur_unrealized_rows.payment_due_date,
                                                           vn_m2m_penality,
                                                           vc_m2m_pc_fw_exch_rate);
          vc_error_msg := '10631';
          if vc_m2m_pc_fw_exch_rate is not null then
            if vc_m2m_total_pc_fw_exch_rate is null then
              vc_m2m_total_pc_fw_exch_rate := vc_m2m_pc_fw_exch_rate;
            else
              if instr(vc_m2m_total_pc_fw_exch_rate, vc_m2m_pc_fw_exch_rate) = 0 then
                vc_m2m_total_pc_fw_exch_rate := vc_m2m_total_pc_fw_exch_rate || ',' ||
                                                vc_m2m_pc_fw_exch_rate;
              end if;
            end if;
          end if;
          if nvl(vn_m2m_penality, 0) <> 0 then
            vn_m2m_total_penality := round(vn_m2m_total_penality +
                                           (vn_m2m_penality *
                                           vn_dry_qty_in_base_conc),
                                           cur_unrealized_rows.base_cur_decimal);
          else
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
             cur_unrealized_rows.conc_product_name || ',' || cur_unrealized_rows.conc_quality_name || ',' ||
             cc.attribute_name || ',' || cur_unrealized_rows.shipment_month || '-' ||
             cur_unrealized_rows.shipment_year || '-' || cur_unrealized_rows.valuation_point,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             pd_trade_date);
          end if;
        
        end loop;
      
      end if;
      vc_error_msg            := '10653';
      vn_ele_m2m_total_amount := vn_ele_m2m_amount_in_base -
                                 vn_ele_m2m_treatment_charge -
                                 vn_ele_m2m_refine_charge;
    
      pkg_general.sp_get_main_cur_detail(cur_unrealized_rows.price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);
    
      vn_ele_cont_value_in_price_cur := (cur_unrealized_rows.contract_price /
                                        nvl(cur_unrealized_rows.price_unit_weight,
                                             1)) *
                                        (pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                              cur_unrealized_rows.payable_qty_unit_id,
                                                                              cur_unrealized_rows.price_unit_weight_unit_id,
                                                                              cur_unrealized_rows.payable_qty)) *
                                        vn_cont_price_cur_id_factor;
      pkg_general.sp_bank_fx_rate(cur_unrealized_rows.corporate_id,
                                  pd_trade_date,
                                  cur_unrealized_rows.payment_due_date,
                                  vc_price_cur_id,
                                  cur_unrealized_rows.base_cur_id,
                                  30,
                                  'sp_calc_phy_opencon_unreal_pnl Price to Base Currency',
                                  pc_process,
                                  vn_fx_price_to_base,
                                  vn_forward_exch_rate);
      vc_error_msg := '10680';
      if vc_price_cur_id <> cur_unrealized_rows.base_cur_id then
        if vn_fx_price_to_base is null or vn_fx_price_to_base = 0 then
          null;
        else
          vc_price_to_base_fw_rate := '1 ' || vc_price_cur_code || '=' ||
                                      vn_fx_price_to_base || ' ' ||
                                      cur_unrealized_rows.base_cur_code;
        end if;
      end if;
    
      -- contract value in value currency will store the data in base currency
      vn_ele_cont_value_in_price_cur := round(vn_ele_cont_value_in_price_cur *
                                              nvl(vn_fx_price_to_base, 1),
                                              cur_unrealized_rows.base_cur_decimal);
    
      vn_ele_cont_premium := vn_base_con_treatment_charge +
                             vn_base_con_refine_charge;
    
      vn_ele_cont_total_premium := round((nvl(vn_ele_cont_premium, 0) *
                                         vn_ele_qty_in_base),
                                         cur_unrealized_rows.base_cur_decimal);
    
      vn_ele_cont_value_in_base_cur := vn_ele_cont_value_in_price_cur -
                                       vn_ele_cont_total_premium;
      vc_error_msg                  := '10716';
      -- secondray cost                                 
      if cur_unrealized_rows.ele_rank = 1 then
        vn_sc_in_base_cur := round(cur_unrealized_rows.sc_in_base_cur *
                                   vn_qty_in_base,
                                   cur_unrealized_rows.base_cur_decimal);
      end if;
      -- below variable set as zero as it's not used in any calculation.
      vn_unrealized_pnl_in_m2m_unit := 0;
      vc_m2m_price_unit_id          := cur_unrealized_rows.m2m_price_unit_id;
      vc_m2m_price_unit_cur_id      := cur_unrealized_rows.m2m_price_unit_cur_id;
      vc_m2m_price_unit_cur_code    := cur_unrealized_rows.m2m_price_unit_cur_code;
      vc_m2m_price_unit_wgt_unit_id := cur_unrealized_rows.m2m_price_unit_weight_unit_id;
      vc_m2m_price_unit_wgt_unit    := cur_unrealized_rows.m2m_price_unit_weight_unit;
      vn_m2m_price_unit_wgt_unit_wt := cur_unrealized_rows.m2m_price_unit_weight;
    
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
         price_to_base_fw_exch_rate)
      values
        (cur_unrealized_rows.corporate_id,
         cur_unrealized_rows.corporate_name,
         pc_process_id,
         cur_unrealized_rows.md_id,
         cur_unrealized_rows.internal_contract_item_ref_no,
         cur_unrealized_rows.element_id,
         cur_unrealized_rows.attribute_name,
         cur_unrealized_rows.assay_header_id,
         cur_unrealized_rows.assay_qty,
         cur_unrealized_rows.assay_qty_unit_id,
         cur_unrealized_rows.payable_qty,
         cur_unrealized_rows.payable_qty_unit_id,
         vn_base_con_refine_charge,
         vn_base_con_treatment_charge,
         cur_unrealized_rows.attribute_name ||
         cur_unrealized_rows.price_description, --pricing_details,
         cur_unrealized_rows.contract_price,
         cur_unrealized_rows.price_unit_id,
         cur_unrealized_rows.price_unit_cur_id,
         cur_unrealized_rows.price_unit_cur_code,
         cur_unrealized_rows.price_unit_weight_unit_id,
         cur_unrealized_rows.price_unit_weight,
         cur_unrealized_rows.price_unit_weight_unit,
         cur_unrealized_rows.net_m2m_price,
         cur_unrealized_rows.m2m_price_unit_id,
         cur_unrealized_rows.m2m_price_unit_cur_id,
         cur_unrealized_rows.m2m_price_unit_cur_code,
         decode(cur_unrealized_rows.m2m_price_unit_weight,
                1,
                null,
                cur_unrealized_rows.m2m_price_unit_weight),
         cur_unrealized_rows.m2m_price_unit_weight_unit_id,
         cur_unrealized_rows.m2m_price_unit_weight_unit,
         vn_ele_cont_value_in_price_cur, --contract_value,
         vc_price_cur_id, --contract_value_cur_id,
         vc_price_cur_code, --contract_value_cur_code,
         vn_ele_cont_value_in_price_cur, --contract_value_in_base, 
         vn_ele_cont_total_premium, -- contract_premium_value_in_base , 
         vn_ele_m2m_amount_in_base, --m2m_value,
         vc_m2m_cur_id,
         vc_m2m_cur_code,
         vn_ele_m2m_refine_charge,
         vn_ele_m2m_treatment_charge,
         cur_unrealized_rows.m2m_loc_incoterm_deviation,
         vn_ele_m2m_amount_in_base, -- updated by siva on 14sep2011 vn_ele_m2m_total_amount, --m2m_amt_in_base, ---used to sum at main table
         -- round(vn_ele_sc_in_base_cur, 3), --sc_in_base_cur,
         cur_unrealized_rows.valuation_dr_id,
         cur_unrealized_rows.dr_id_name,
         cur_unrealized_rows.valuation_month,
         cur_unrealized_rows.valuation_date,
         vn_ele_exp_cog_in_base_cur, --expected_cog_net_sale_value,
         vn_ele_unreal_pnl_in_base_cur, --unrealized_pnl_in_base_cur,
         cur_unrealized_rows.base_cur_id,
         cur_unrealized_rows.base_cur_code,
         vn_fx_price_to_base, --price_cur_to_base_cur_fx_rate,
         vn_m2m_base_fx_rate, --m2m_cur_to_base_cur_fx_rate,
         cur_unrealized_rows.derivative_def_id,
         cur_unrealized_rows.valuation_exchange_id,
         cur_unrealized_rows.exchange_name,
         vn_ele_qty_in_base,
         cur_unrealized_rows.base_price_unit_id_in_ppu,
         cur_unrealized_rows.base_price_unit_name,
         cur_unrealized_rows.valuation_against_underlying,
         vc_contract_rc_fw_exch_rate,
         vc_contract_tc_fw_exch_rate,
         cur_unrealized_rows.m2m_rc_fw_exch_rate,
         cur_unrealized_rows.m2m_tc_fw_exch_rate,
         cur_unrealized_rows.m2m_ld_fw_exch_rate,
         vc_price_to_base_fw_rate);
    
      if cur_unrealized_rows.ele_rank = 1 then
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
           m2m_loc_diff_premium,
           valuation_against_underlying,
           contract_pc_fw_exch_rate,
           accrual_to_base_fw_exch_rate,
           location_premium_per_unit,
           location_premium,
           location_premium_fw_exch_rate,
           contract_status,
           is_approved)
        values
          (cur_unrealized_rows.corporate_id,
           cur_unrealized_rows.corporate_name,
           pc_process_id,
           cur_unrealized_rows.pcdi_id,
           cur_unrealized_rows.delivery_item_no,
           cur_unrealized_rows.prefix,
           cur_unrealized_rows.middle_no,
           cur_unrealized_rows.suffix,
           cur_unrealized_rows.internal_contract_ref_no,
           cur_unrealized_rows.contract_ref_no,
           cur_unrealized_rows.issue_date,
           cur_unrealized_rows.internal_contract_item_ref_no,
           cur_unrealized_rows.basis_type,
           cur_unrealized_rows.delivery_period_type,
           cur_unrealized_rows.delivery_from_month,
           cur_unrealized_rows.delivery_from_year,
           cur_unrealized_rows.delivery_to_month,
           cur_unrealized_rows.delivery_to_year,
           cur_unrealized_rows.delivery_from_date,
           cur_unrealized_rows.delivery_to_date,
           cur_unrealized_rows.transit_days,
           cur_unrealized_rows.purchase_sales,
           cur_unrealized_rows.approval_status, --
           cur_unrealized_rows.unrealized_type,
           cur_unrealized_rows.profit_center_id,
           cur_unrealized_rows.profit_center_name,
           cur_unrealized_rows.profit_center_short_name,
           cur_unrealized_rows.cp_id,
           cur_unrealized_rows.cp_name,
           cur_unrealized_rows.trader_id,
           cur_unrealized_rows.trader_user_name,
           cur_unrealized_rows.conc_product_id,
           cur_unrealized_rows.conc_product_name,
           vn_dry_qty,
           vn_wet_qty,
           cur_unrealized_rows.qty_unit_id,
           cur_unrealized_rows.qty_unit,
           cur_unrealized_rows.conc_quality_id,
           cur_unrealized_rows.conc_quality_name,
           cur_unrealized_rows.fixation_method,
           cur_unrealized_rows.price_description,
           cur_unrealized_rows.price_fixation_status,
           cur_unrealized_rows.price_fixation_details,
           cur_unrealized_rows.item_delivery_period_string,
           cur_unrealized_rows.inco_term_id,
           cur_unrealized_rows.incoterm,
           cur_unrealized_rows.origination_city_id,
           cur_unrealized_rows.origination_city,
           cur_unrealized_rows.origination_country_id,
           cur_unrealized_rows.origination_country,
           cur_unrealized_rows.destination_city_id,
           cur_unrealized_rows.destination_city,
           cur_unrealized_rows.destination_country_id,
           cur_unrealized_rows.destination_country,
           cur_unrealized_rows.origination_region_id,
           cur_unrealized_rows.origination_region,
           cur_unrealized_rows.destination_region_id,
           cur_unrealized_rows.destination_region,
           cur_unrealized_rows.payment_term_id,
           cur_unrealized_rows.payment_term,
           null, -- contract_price_string,
           null, --contract_rc_tc_pen_string,
           null, -- m2m_price_string,
           null, -- m2m_rc_tc_pen_string,
           null, -- net_contract_value_in_base_cur,
           null, -- net_contract_prem_in_base_cur,
           null, -- net_m2m_amt_in_base_cur, 
           vn_sc_in_base_cur, -- net_sc_in_base_cur,
           null, -- expected_cog_net_sale_value,
           null, -- unrealized_pnl_in_base_cur,
           null, -- unreal_pnl_in_base_per_unit,
           null, -- prev_day_unr_pnl_in_base_cur,
           null, -- trade_day_pnl_in_base_cur,
           cur_unrealized_rows.base_cur_id,
           cur_unrealized_rows.base_cur_code,
           cur_unrealized_rows.groupid,
           cur_unrealized_rows.groupname,
           cur_unrealized_rows.cur_id_gcd,
           cur_unrealized_rows.cur_code_gcd,
           cur_unrealized_rows.qty_unit_id_gcd,
           cur_unrealized_rows.qty_unit_gcd,
           cur_unrealized_rows.base_qty_unit_id,
           cur_unrealized_rows.base_qty_unit,
           null, -- cont_unr_status,
           vn_qty_in_base,
           pd_trade_date,
           cur_unrealized_rows.strategy_id,
           cur_unrealized_rows.strategy_name,
           cur_unrealized_rows.del_distribution_item_no,
           vn_base_con_penality_charge,
           vn_m2m_total_penality,
           vn_loc_total_amount,
           cur_unrealized_rows.valuation_against_underlying,
           vc_contract_pc_fw_exch_rate,
           cur_unrealized_rows.accrual_to_base_fw_exch_rate,
           vn_cont_delivery_premium,
           vn_cont_del_premium_amt,
           vc_contract_pp_fw_exch_rate,
           cur_unrealized_rows.contract_status,
           cur_unrealized_rows.approval_flag);
      end if;
    
    end loop;
    vc_error_msg := '11066';
    for cur_update_pnl in (select poude.internal_contract_item_ref_no,
                                  sum(poude.contract_value_in_base) net_contract_value_in_base_cur,
                                  sum(poude.contract_premium_value_in_base) net_contract_prem_in_base_cur,
                                  sum(poude.m2m_amt_in_base) net_m2m_amt_in_base_cur,
                                  sum(poude.treatment_charge) net_contract_treatment_charge,
                                  sum(poude.refining_charge) net_contract_refining_charge,
                                  sum(poude.m2m_treatment_charge) net_m2m_treatment_charge,
                                  sum(poude.m2m_refining_charge) net_m2m_refining_charge,
                                  stragg(poude.element_name || '-' ||
                                         poude.contract_price || ' ' ||
                                         poude.price_unit_cur_code || '/' ||
                                         poude.price_unit_weight ||
                                         poude.price_unit_weight_unit) contract_price_string,
                                  (case
                                     when poude.valuation_against_underlying = 'N' then
                                      max((case
                                     when nvl(poude.m2m_price, 0) <> 0 then
                                      (poude.m2m_price || ' ' ||
                                      poude.m2m_price_cur_code || '/' ||
                                      poude.m2m_price_weight ||
                                      poude.m2m_price_weight_unit)
                                     else
                                      null
                                   end)) else stragg((case
                                    when nvl(poude.m2m_price,
                                             0) <> 0 then
                                     (poude.element_name || '-' ||
                                     poude.m2m_price || ' ' ||
                                     poude.m2m_price_cur_code || '/' ||
                                     poude.m2m_price_weight ||
                                     poude.m2m_price_weight_unit)
                                    else
                                     null
                                  end)) end) m2m_price_string, -- TODO if underly valuation = n, show the concentrate price
                                  stragg('TC:' || poude.element_name || '-' ||
                                         poude.treatment_charge || ' ' ||
                                         poude.base_cur_code || '  ' ||
                                         'RC:' || poude.element_name || '-' ||
                                         poude.refining_charge || ' ' ||
                                         poude.base_cur_code) contract_rc_tc_pen_string,
                                  stragg('TC:' || poude.element_name || '-' ||
                                         poude.m2m_treatment_charge || ' ' ||
                                         poude.base_cur_code || ' ' || 'RC:' ||
                                         poude.element_name || '-' ||
                                         poude.m2m_refining_charge || ' ' ||
                                         poude.base_cur_code) m2m_rc_tc_pen_string,
                                  stragg(poude.pricing_details) price_string,
                                  stragg(poude.price_to_base_fw_exch_rate) price_to_base_fw_exch_rate
                             from poued_element_details poude
                            where poude.corporate_id = pc_corporate_id
                              and poude.process_id = pc_process_id
                            group by poude.internal_contract_item_ref_no,
                                     poude.valuation_against_underlying)
    loop
      update poue_phy_open_unreal_element poue
         set poue.net_contract_value_in_base_cur = round(cur_update_pnl.net_contract_value_in_base_cur,
                                                         2),
             poue.net_contract_prem_in_base_cur  = round(cur_update_pnl.net_contract_prem_in_base_cur,
                                                         2),
             poue.net_m2m_amt_in_base_cur        = round(cur_update_pnl.net_m2m_amt_in_base_cur,
                                                         2),
             poue.net_contract_treatment_charge  = round(cur_update_pnl.net_contract_treatment_charge,
                                                         2),
             poue.net_contract_refining_charge   = round(cur_update_pnl.net_contract_refining_charge,
                                                         2),
             poue.net_m2m_treatment_charge       = round(cur_update_pnl.net_m2m_treatment_charge,
                                                         2),
             poue.net_m2m_refining_charge        = round(cur_update_pnl.net_m2m_refining_charge,
                                                         2),
             poue.contract_price_string          = cur_update_pnl.contract_price_string,
             poue.m2m_price_string               = cur_update_pnl.m2m_price_string,
             poue.contract_rc_tc_pen_string      = cur_update_pnl.contract_rc_tc_pen_string,
             poue.m2m_rc_tc_pen_string           = cur_update_pnl.m2m_rc_tc_pen_string,
             poue.price_string                   = cur_update_pnl.price_string,
             poue.price_to_base_fw_exch_rate     = cur_update_pnl.price_to_base_fw_exch_rate
       where poue.internal_contract_item_ref_no =
             cur_update_pnl.internal_contract_item_ref_no
         and poue.process_id = pc_process_id
         and poue.corporate_id = pc_corporate_id;
    end loop;
    commit;
    vc_error_msg := '11139';
    update poue_phy_open_unreal_element poue
       set poue.expected_cog_net_sale_value = poue.net_contract_value_in_base_cur +
                                              poue.location_premium -
                                              poue.net_contract_treatment_charge -
                                              poue.penalty_charge -
                                              poue.net_contract_refining_charge +
                                              poue.net_sc_in_base_cur
     where poue.corporate_id = pc_corporate_id
       and poue.process_id = pc_process_id;
    commit;
    --- Update Unrealized PNL
    update poue_phy_open_unreal_element poue
       set poue.unrealized_pnl_in_base_cur = --
            (case when poue.contract_type = 'P' then --
            (poue.net_m2m_amt_in_base_cur - poue.net_m2m_treatment_charge - poue.net_m2m_refining_charge - --
            nvl(poue.m2m_penalty_charge, 0) + poue.m2m_loc_diff_premium) - --
            (poue.expected_cog_net_sale_value) --
            else(poue.expected_cog_net_sale_value) - --
            (poue.net_m2m_amt_in_base_cur - poue.net_m2m_treatment_charge - poue.net_m2m_refining_charge - --
            nvl(poue.m2m_penalty_charge, 0) + poue.m2m_loc_diff_premium) end)
     where poue.corporate_id = pc_corporate_id
       and poue.process_id = pc_process_id;
    commit;
    -- Update PNL Per Base Unit, This should never be rounded off
    update poue_phy_open_unreal_element poue
       set poue.unreal_pnl_in_base_per_unit = poue.unrealized_pnl_in_base_cur /
                                              poue.qty_in_base_unit
     where poue.corporate_id = pc_corporate_id
       and poue.process_id = pc_process_id
       and poue.qty_in_base_unit <> 0;
  
    -- update previous eod data  
    begin
      for cur_update in (select poue_prev_day.internal_contract_item_ref_no,
                                poue_prev_day.unreal_pnl_in_base_per_unit,
                                poue_prev_day.unrealized_type
                           from poue_phy_open_unreal_element poue_prev_day
                          where poue_prev_day.process_id =
                                pc_previous_process_id
                            and corporate_id = pc_corporate_id)
      loop
        update poue_phy_open_unreal_element poue_today
           set poue_today.prev_day_unr_pnl_in_base_cur = round(cur_update.unreal_pnl_in_base_per_unit *
                                                               poue_today.qty_in_base_unit,
                                                               2),
               poue_today.cont_unr_status              = 'EXISTING_TRADE'
         where poue_today.internal_contract_item_ref_no =
               cur_update.internal_contract_item_ref_no
           and poue_today.process_id = pc_process_id
           and poue_today.unrealized_type = cur_update.unrealized_type
           and poue_today.corporate_id = pc_corporate_id;
      end loop;
    exception
      when others then
        dbms_output.put_line('SQLERRM-1' || sqlerrm);
    end;
  
    -- mark the trades came as new in this eod/eom
    update poue_phy_open_unreal_element poue
       set poue.cont_unr_status = 'NEW_TRADE'
     where poue.cont_unr_status is null
       and poue.process_id = pc_process_id
       and poue.corporate_id = pc_corporate_id;
  
    update poue_phy_open_unreal_element poue
       set poue.trade_day_pnl_in_base_cur = round(nvl(poue.unrealized_pnl_in_base_cur,
                                                      0) - nvl(poue.prev_day_unr_pnl_in_base_cur,
                                                               0),
                                                  2)
     where poue.process_id = pc_process_id
       and poue.corporate_id = pc_corporate_id
       and poue.unrealized_type = 'Unrealized';
    vc_error_msg := '11215';
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_opencon_unreal_pnl',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm ||
                                                           ' Line:' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_stock_unreal_sntt_conc(pc_corporate_id        varchar2,
                                      pd_trade_date          date,
                                      pc_process_id          varchar2,
                                      pc_dbd_id              varchar2,
                                      pc_user_id             varchar2,
                                      pc_process             varchar2,
                                      pc_previous_process_id varchar2) is
  
    cursor cur_grd is
      select tt.section_type,
             tt.profit_center,
             tt.profit_center_name,
             tt.profit_center_short_name,
             tt.process_id,
             tt.corporate_id,
             tt.corporate_name,
             tt.internal_gmr_ref_no,
             tt.internal_contract_item_ref_no,
             tt.del_distribution_item_no,
             tt.delivery_item_no,
             tt.contract_ref_no,
             tt.purchase_sales,
             tt.conc_product_id,
             tt.conc_product_name,
             tt.product_id,
             tt.product_name,
             tt.origin_id,
             tt.origin_name,
             tt.conc_quality_id,
             tt.conc_quality_name,
             tt.quality_id,
             tt.quality_name,
             tt.container_no,
             tt.stock_qty,
             tt.qty_unit_id,
             tt.gmr_qty_unit_id,
             tt.qty_unit,
             tt.stocky_qty_decimal,
             tt.no_of_units,
             tt.md_id,
             tt.m2m_price_unit_id,
             tt.net_m2m_price,
             tt.m2m_price_unit_cur_id,
             tt.m2m_price_unit_cur_code,
             tt.m2m_price_unit_weight_unit_id,
             tt.m2m_price_unit_weight_unit,
             tt.m2m_price_unit_weight,
             tt.m2m_price_unit_str,
             tt.m2m_main_cur_id,
             tt.m2m_main_cur_code,
             tt.m2m_main_cur_decimals,
             tt.main_currency_factor,
             tt.settlement_cur_id,
             tt.settlement_to_val_fx_rate,
             tt.element_id,
             tt.attribute_name,
             tt.assay_header_id,
             tt.assay_qty,
             tt.assay_qty_unit_id,
             tt.payable_qty,
             tt.payable_qty_unit_id,
             tt.payable_qty_unit,
             tt.contract_price,
             tt.price_unit_id,
             tt.price_unit_weight_unit_id,
             tt.price_unit_weight,
             tt.price_unit_cur_id,
             tt.price_unit_cur_code,
             tt.price_unit_weight_unit,
             tt.price_fixation_details,
             tt.price_description,
             tt.payment_due_date,
             tt.base_cur_id,
             tt.base_cur_code,
             tt.base_cur_decimal,
             tt.inventory_status,
             tt.shipment_status,
             tt.section_name,
             tt.price_basis,
             tt.shed_id,
             tt.destination_city_id,
             tt.price_fixation_status,
             tt.base_qty_unit_id,
             tt.conc_base_qty_unit_id,
             tt.base_qty_decimal,
             tt.strategy_id,
             tt.strategy_name,
             tt.valuation_exchange_id,
             tt.valuation_month,
             tt.derivative_def_id,
             tt.is_voyage_gmr,
             tt.gmr_contract_type,
             tt.int_alloc_group_id,
             tt.internal_grd_dgrd_ref_no,
             tt.stock_ref_no,
             tt.trader_id,
             tt.trader_user_name,
             tt.m2m_loc_incoterm_deviation,
             tt.m2m_treatment_charge,
             tt.m2m_refine_charge,
             tt.m2m_tc_price_unit_id,
             tt.m2m_tc_price_unit_name,
             tt.m2m_tc_cur_id,
             tt.m2m_tc_weight,
             tt.m2m_tc_weight_unit_id,
             tt.m2m_rc_price_unit_id,
             tt.m2m_rc_price_unit_name,
             tt.m2m_rc_cur_id,
             tt.m2m_rc_weight,
             tt.m2m_rc_weight_unit_id,
             tt.base_price_unit_id_in_ppu,
             tt.base_price_unit_id_in_pum,
             tt.eval_basis,
             dense_rank() over(partition by tt.internal_contract_item_ref_no order by tt.element_id) ele_rank,
             tt.unit_of_measure,
             tt.loc_qty_unit_id,
             tt.mvp_id,
             tt.shipment_month,
             tt.shipment_year,
             tt.valuation_point,
             tt.base_price_unit_name,
             tt.valuation_against_underlying,
             tt.m2m_rc_fw_exch_rate,
             tt.m2m_tc_fw_exch_rate,
             tt.m2m_ld_fw_exch_rate,
             tt.sc_in_base_cur,
             tt.accrual_to_base_fw_rate,
             tt.incoterm_id,
             tt.incoterm,
             tt.cp_id,
             tt.cp_name,
             tt.delivery_month,
             tt.delivery_premium,
             tt.delivery_premium_unit_id
        from (
              ----  Stock non event based GMR price using CIPDE
              select 'Purchase' section_type,
                      pcpd.profit_center_id profit_center,
                      cpc.profit_center_name,
                      cpc.profit_center_short_name,
                      pc_process_id process_id,
                      gmr.corporate_id,
                      akc.corporate_name,
                      gmr.internal_gmr_ref_no,
                      grd.internal_contract_item_ref_no,
                      pci.del_distribution_item_no,
                      pcdi.delivery_item_no,
                      pcm.contract_ref_no,
                      pcm.purchase_sales,
                      pcpd.product_id conc_product_id,
                      pdm_conc.product_desc conc_product_name,
                      aml.underlying_product_id product_id,
                      pdm.product_desc product_name,
                      grd.origin_id,
                      orm.origin_name,
                      pcpq.quality_template_id conc_quality_id,
                      qat.quality_name conc_quality_name,
                      qav.comp_quality_id quality_id,
                      qat_und.quality_name,
                      grd.container_no,
                      grd.current_qty stock_qty,
                      grd.qty_unit_id,
                      gmr.qty_unit_id gmr_qty_unit_id,
                      qum.qty_unit,
                      qum.decimals stocky_qty_decimal,
                      grd.no_of_units,
                      md.md_id,
                      md.m2m_price_unit_id,
                      md.net_m2m_price,
                      md.m2m_price_unit_cur_id,
                      md.m2m_price_unit_cur_code,
                      md.m2m_price_unit_weight_unit_id,
                      md.m2m_price_unit_weight_unit,
                      nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
                      md.m2m_price_unit_cur_code || '/' ||
                      decode(md.m2m_price_unit_weight,
                             1,
                             null,
                             md.m2m_price_unit_weight) ||
                      md.m2m_price_unit_weight_unit m2m_price_unit_str,
                      md.m2m_main_cur_id,
                      md.m2m_main_cur_code,
                      md.m2m_main_cur_decimals,
                      md.main_currency_factor,
                      md.settlement_cur_id,
                      md.settlement_to_val_fx_rate,
                      cipde.element_id,
                      aml.attribute_name,
                      --sam.ash_id assay_header_id,
                      grd.weg_avg_pricing_assay_id assay_header_id,
                      ceqs.assay_qty,
                      ceqs.assay_qty_unit_id,
                      --Added Suresh                   
                      (case
                        when rm.ratio_name = '%' then
                         ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                         (pqcapd.payable_percentage / 100))
                        else
                         ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                         pqcapd.payable_percentage)
                      end) payable_qty,
                      (case
                        when rm.ratio_name = '%' then
                         grd.qty_unit_id
                        else
                         rm.qty_unit_id_numerator
                      end) payable_qty_unit_id,
                      gmr_qum.qty_unit payable_qty_unit,
                      -----
                      cipde.contract_price,
                      cipde.price_unit_id,
                      cipde.price_unit_weight_unit_id,
                      cipde.price_unit_weight,
                      cipde.price_unit_cur_id,
                      cipde.price_unit_cur_code,
                      cipde.price_unit_weight_unit,
                      cipde.price_fixation_details,
                      cipde.price_description,
                      nvl(cipde.payment_due_date, pd_trade_date) payment_due_date,
                      akc.base_cur_id as base_cur_id,
                      akc.base_currency_name base_cur_code,
                      cm.decimals as base_cur_decimal,
                      grd.inventory_status,
                      gsm.status shipment_status,
                      (case
                        when nvl(grd.is_afloat, 'N') = 'Y' and
                             nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                         'Shipped NTT'
                        when nvl(grd.is_afloat, 'N') = 'Y' and
                             nvl(grd.inventory_status, 'NA') = 'In' then
                         'Shipped IN'
                        when nvl(grd.is_afloat, 'N') = 'Y' and
                             nvl(grd.inventory_status, 'NA') = 'Out' then
                         'Shipped TT'
                        when nvl(grd.is_afloat, 'N') = 'N' and
                             nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                         'Stock NTT'
                        when nvl(grd.is_afloat, 'N') = 'N' and
                             nvl(grd.inventory_status, 'NA') = 'In' then
                         'Stock IN'
                        when nvl(grd.is_afloat, 'N') = 'N' and
                             nvl(grd.inventory_status, 'NA') = 'Out' then
                         'Stock TT'
                        else
                         'Others'
                      end) section_name,
                      cipde.price_basis,
                      gmr.shed_id,
                      gmr.destination_city_id,
                      cipde.price_fixation_status price_fixation_status,
                      pdm.base_quantity_unit base_qty_unit_id,
                      qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
                      qum_pdm_conc.decimals as base_qty_decimal,
                      pcpd.strategy_id,
                      css.strategy_name,
                      md.valuation_exchange_id,
                      md.valuation_month,
                      md.derivative_def_id,
                      nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
                      gmr.contract_type gmr_contract_type,
                      null int_alloc_group_id,
                      grd.internal_grd_ref_no internal_grd_dgrd_ref_no,
                      grd.internal_stock_ref_no stock_ref_no,
                      pcm.trader_id,
                      (case
                        when pcm.trader_id is not null then
                         (select gab.firstname || ' ' || gab.lastname
                            from gab_globaladdressbook gab,
                                 ak_corporate_user     aku
                           where gab.gabid = aku.gabid
                             and aku.user_id = pcm.trader_id)
                        else
                         ''
                      end) trader_user_name,
                      md.m2m_loc_incoterm_deviation,
                      md.treatment_charge m2m_treatment_charge,
                      md.refine_charge m2m_refine_charge,
                      tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
                      tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
                      tc_ppu_pum.cur_id m2m_tc_cur_id,
                      tc_ppu_pum.weight m2m_tc_weight,
                      tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
                      rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
                      rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
                      rc_ppu_pum.cur_id m2m_rc_cur_id,
                      rc_ppu_pum.weight m2m_rc_weight,
                      rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
                      md.base_price_unit_id_in_ppu,
                      md.base_price_unit_id_in_pum,
                      qat.eval_basis,
                      pcpq.unit_of_measure,
                      pum_loc_base.weight_unit_id loc_qty_unit_id,
                      tmpc.mvp_id,
                      tmpc.shipment_month,
                      tmpc.shipment_year,
                      tmpc.valuation_point,
                      pum_base_price_id.price_unit_name base_price_unit_name,
                      nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying,
                      md.m2m_rc_fw_exch_rate,
                      md.m2m_tc_fw_exch_rate,
                      md.m2m_ld_fw_exch_rate,
                      nvl(gscs.avg_cost_fw_rate, 0) sc_in_base_cur,
                      gscs.fw_rate_string accrual_to_base_fw_rate,
                      itm.incoterm_id,
                      itm.incoterm,
                      phd_cp.profileid cp_id,
                      phd_cp.companyname cp_name,
                      (case
                        when pcdi.delivery_period_type = 'Month' then
                         pcdi.delivery_to_month || '-' || pcdi.delivery_to_year
                        else
                         to_char(pcdi.delivery_to_date, 'Mon-YYYY')
                      end) delivery_month,
                      nvl(pcdb.premium, 0) delivery_premium,
                      pcdb.premium_unit_id delivery_premium_unit_id
                from gmr_goods_movement_record gmr,
                      grd_goods_record_detail grd,
                      pcm_physical_contract_main pcm,
                      pcpd_pc_product_definition pcpd,
                      cpc_corporate_profit_center cpc,
                      pdm_productmaster pdm,
                      orm_origin_master orm,
                      (select tmp.*
                         from tmpc_temp_m2m_pre_check tmp
                        where tmp.corporate_id = pc_corporate_id
                          and tmp.product_type = 'CONCENTRATES'
                          and tmp.section_name <> 'OPEN') tmpc,
                      qum_quantity_unit_master qum,
                      qat_quality_attributes qat,
                      (select md1.*
                         from md_m2m_daily md1
                        where md1.rate_type <> 'OPEN'
                          and md1.corporate_id = pc_corporate_id
                          and md1.product_type = 'CONCENTRATES'
                          and md1.process_id = pc_process_id) md,
                      cipde_cipd_element_price cipde,
                      ciqs_contract_item_qty_status ciqs,
                      pci_physical_contract_item pci,
                      pcpq_pc_product_quality pcpq,
                      pcdi_pc_delivery_item pcdi,
                      qav_quality_attribute_values qav,
                      ppm_product_properties_mapping ppm,
                      qat_quality_attributes qat_und,
                      aml_attribute_master_list aml,
                      pcdb_pc_delivery_basis pcdb,
                      ak_corporate akc,
                      cm_currency_master cm,
                      gsm_gmr_stauts_master gsm,
                      css_corporate_strategy_setup css,
                      pdm_productmaster pdm_conc,
                      qum_quantity_unit_master qum_pdm_conc,
                      pum_price_unit_master pum_loc_base,
                      pum_price_unit_master pum_base_price_id,
                      -- added Suresh 
                      ash_assay_header               ash,
                      asm_assay_sublot_mapping       asm,
                      pqca_pq_chemical_attributes    pqca,
                      rm_ratio_master                rm,
                      pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
                      qum_quantity_unit_master       gmr_qum,
                      ---                                      
                      v_ppu_pum                    tc_ppu_pum,
                      v_ppu_pum                    rc_ppu_pum,
                      ceqs_contract_ele_qty_status ceqs,
                      sam_stock_assay_mapping      sam,
                      gscs_gmr_sec_cost_summary    gscs,
                      itm_incoterm_master          itm,
                      phd_profileheaderdetails     phd_cp
               where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpq.pcpd_id = pcpd.pcpd_id
                 and pcpd.profit_center_id = cpc.profit_center_id
                 and grd.origin_id = orm.origin_id(+)
                 and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
                 and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
                 and grd.internal_contract_item_ref_no =
                     tmpc.internal_contract_item_ref_no(+)
                 and tmpc.conc_quality_id = qat.quality_id
                 and grd.qty_unit_id = qum.qty_unit_id(+)
                 and tmpc.internal_m2m_id = md.md_id(+)
                 and tmpc.element_id = cipde.element_id
                 and md.element_id = cipde.element_id
                 and grd.internal_contract_item_ref_no =
                     cipde.internal_contract_item_ref_no
                 and grd.process_id = cipde.process_id
                 and cipde.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and grd.internal_contract_item_ref_no =
                     ciqs.internal_contract_item_ref_no
                 and grd.internal_contract_item_ref_no =
                     pci.internal_contract_item_ref_no
                 and pci.pcpq_id = pcpq.pcpq_id
                 and pcm.internal_contract_ref_no =
                     pcdi.internal_contract_ref_no
                 and pcdi.pcdi_id = pci.pcdi_id
                 and pcpq.quality_template_id = qat.quality_id(+)
                 and qat.quality_id = qav.quality_id
                 and qav.attribute_id = ppm.property_id
                 and qav.comp_quality_id = qat_und.quality_id
                 and ppm.attribute_id = aml.attribute_id
                 and aml.underlying_product_id = pdm.product_id(+)
                 and aml.attribute_id = cipde.element_id
                 and pci.pcdb_id = pcdb.pcdb_id
                 and gmr.corporate_id = akc.corporate_id
                 and akc.base_cur_id = cm.cur_id
                 and gmr.status_id = gsm.status_id(+)
                 and pcpd.strategy_id = css.strategy_id
                 and pcpd.product_id = pdm_conc.product_id
                 and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
                 and md.base_price_unit_id_in_pum =
                     pum_loc_base.price_unit_id
                 and md.base_price_unit_id_in_pum =
                     pum_base_price_id.price_unit_id
                 and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
                 and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
                    -- added Suresh
                 and grd.weg_avg_pricing_assay_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and pqca.is_elem_for_pricing = 'Y'
                 and pqca.element_id = aml.attribute_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr_qum.qty_unit_id =
                     (case when rm.ratio_name = '%' then grd.qty_unit_id else
                      rm.qty_unit_id_numerator end)
                 and pqca.pqca_id = pqcapd.pqca_id
                 and rm.is_active = 'Y'
                 and pqca.is_active = 'Y'
                 and pqcapd.is_active = 'Y'
                    ---
                 and pci.internal_contract_item_ref_no =
                     ceqs.internal_contract_item_ref_no
                 and aml.attribute_id = ceqs.element_id
                 and grd.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and pci.process_id = pc_process_id
                 and pcm.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and pcpq.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and ciqs.process_id = pc_process_id
                 and cipde.process_id = pc_process_id
                 and pcdb.process_id = pc_process_id
                 and ceqs.process_id = pc_process_id
                 and pcm.purchase_sales = 'P'
                 and pcm.contract_status = 'In Position'
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcpd.input_output = 'Input'
                 and pcm.is_tolling_contract = 'N'
                 and pcm.is_tolling_extn = 'N'
                 and pci.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and pcpq.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and ppm.is_active = 'Y'
                 and ppm.is_deleted = 'N'
                 and qav.is_deleted = 'N'
                 and qav.is_comp_product_attribute = 'Y'
                 and qat.is_active = 'Y'
                 and qat.is_deleted = 'N'
                 and aml.is_active = 'Y'
                 and aml.is_deleted = 'N'
                 and qat_und.is_active = 'Y'
                 and qat_und.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
                 and grd.status = 'Active'
                 and grd.is_deleted = 'N'
                 and gmr.is_deleted = 'N'
                 and nvl(grd.inventory_status, 'NA') = 'NA'
                 and pcm.purchase_sales = 'P'
                 and nvl(grd.current_qty, 0) > 0
                 and gmr.is_internal_movement = 'N'
                 and grd.internal_grd_ref_no = sam.internal_grd_ref_no
                 and sam.is_latest_position_assay = 'Y'
                 and gmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
                 and gmr.process_id = gscs.process_id(+)
                 and pcdb.inco_term_id = itm.incoterm_id
                 and pcm.cp_id = phd_cp.profileid(+)
                 and not exists
               (select gpd.process_id
                        from gpd_gmr_conc_price_daily gpd
                       where gpd.process_id = gmr.process_id
                         and gpd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                         and gpd.corporate_id = gmr.corporate_id
                         and gpd.element_id = tmpc.element_id)
              union all
              ------  Stock event based GMR price using GPD
              select 'Purchase' section_type,
                     pcpd.profit_center_id profit_center,
                     cpc.profit_center_name,
                     cpc.profit_center_short_name,
                     pc_process_id process_id,
                     gmr.corporate_id,
                     akc.corporate_name,
                     gmr.internal_gmr_ref_no,
                     grd.internal_contract_item_ref_no,
                     pci.del_distribution_item_no,
                     pcdi.delivery_item_no,
                     pcm.contract_ref_no,
                     pcm.purchase_sales,
                     pcpd.product_id conc_product_id,
                     pdm_conc.product_desc conc_product_name,
                     aml.underlying_product_id product_id,
                     pdm.product_desc product_name,
                     grd.origin_id,
                     orm.origin_name,
                     pcpq.quality_template_id conc_quality_id,
                     qat.quality_name conc_quality_name,
                     qav.comp_quality_id quality_id,
                     qat_und.quality_name,
                     grd.container_no,
                     grd.current_qty stock_qty,
                     grd.qty_unit_id,
                     gmr.qty_unit_id gmr_qty_unit_id,
                     qum.qty_unit,
                     qum.decimals stocky_qty_decimal,
                     grd.no_of_units,
                     md.md_id,
                     md.m2m_price_unit_id,
                     md.net_m2m_price,
                     md.m2m_price_unit_cur_id,
                     md.m2m_price_unit_cur_code,
                     md.m2m_price_unit_weight_unit_id,
                     md.m2m_price_unit_weight_unit,
                     nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
                     md.m2m_price_unit_cur_code || '/' ||
                     decode(md.m2m_price_unit_weight,
                            1,
                            null,
                            md.m2m_price_unit_weight) ||
                     md.m2m_price_unit_weight_unit m2m_price_unit_str,
                     md.m2m_main_cur_id,
                     md.m2m_main_cur_code,
                     md.m2m_main_cur_decimals,
                     md.main_currency_factor,
                     md.settlement_cur_id,
                     md.settlement_to_val_fx_rate,
                     ceqs.element_id,
                     aml.attribute_name,
                     sam.ash_id assay_header_id,
                     ceqs.assay_qty,
                     ceqs.assay_qty_unit_id,
                     --- added Suresh
                     (case
                       when rm.ratio_name = '%' then
                        ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                        (pqcapd.payable_percentage / 100))
                       else
                        ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                        pqcapd.payable_percentage)
                     end) payable_qty,
                     (case
                       when rm.ratio_name = '%' then
                        grd.qty_unit_id
                       else
                        rm.qty_unit_id_numerator
                     end) payable_qty_unit_id,
                     gmr_qum.qty_unit payable_qty_unit,
                     ---                                    
                     gpd.contract_price,
                     gpd.price_unit_id,
                     gpd.price_unit_weight_unit_id,
                     gpd.price_unit_weight,
                     gpd.price_unit_cur_id,
                     gpd.price_unit_cur_code,
                     gpd.price_unit_weight_unit,
                     gpd.price_fixation_details,
                     gpd.price_description price_description,
                     (case
                       when nvl(pcdi.payment_due_date, pd_trade_date) <
                            pd_trade_date then
                        pd_trade_date
                       else
                        nvl(pcdi.payment_due_date, pd_trade_date)
                     end) payment_due_date,
                     akc.base_cur_id as base_cur_id,
                     akc.base_currency_name base_cur_code,
                     cm.decimals as base_cur_decimal,
                     grd.inventory_status,
                     gsm.status shipment_status,
                     (case
                       when nvl(grd.is_afloat, 'N') = 'Y' and
                            nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                        'Shipped NTT'
                       when nvl(grd.is_afloat, 'N') = 'Y' and
                            nvl(grd.inventory_status, 'NA') = 'In' then
                        'Shipped IN'
                       when nvl(grd.is_afloat, 'N') = 'Y' and
                            nvl(grd.inventory_status, 'NA') = 'Out' then
                        'Shipped TT'
                       when nvl(grd.is_afloat, 'N') = 'N' and
                            nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                        'Stock NTT'
                       when nvl(grd.is_afloat, 'N') = 'N' and
                            nvl(grd.inventory_status, 'NA') = 'In' then
                        'Stock IN'
                       when nvl(grd.is_afloat, 'N') = 'N' and
                            nvl(grd.inventory_status, 'NA') = 'Out' then
                        'Stock TT'
                       else
                        'Others'
                     end) section_name,
                     gpd.price_basis,
                     gmr.shed_id,
                     gmr.destination_city_id,
                     gpd.price_fixation_status,
                     pdm.base_quantity_unit base_qty_unit_id,
                     qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
                     qum_pdm_conc.decimals as base_qty_decimal,
                     pcpd.strategy_id,
                     css.strategy_name,
                     md.valuation_exchange_id,
                     md.valuation_month,
                     md.derivative_def_id,
                     nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
                     gmr.contract_type gmr_contract_type,
                     null int_alloc_group_id,
                     grd.internal_grd_ref_no internal_grd_dgrd_ref_no,
                     grd.internal_stock_ref_no stock_ref_no,
                     pcm.trader_id,
                     (case
                       when pcm.trader_id is not null then
                        (select gab.firstname || ' ' || gab.lastname
                           from gab_globaladdressbook gab,
                                ak_corporate_user     aku
                          where gab.gabid = aku.gabid
                            and aku.user_id = pcm.trader_id)
                       else
                        ''
                     end) trader_user_name,
                     md.m2m_loc_incoterm_deviation,
                     md.treatment_charge m2m_treatment_charge,
                     md.refine_charge m2m_refine_charge,
                     tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
                     tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
                     tc_ppu_pum.cur_id m2m_tc_cur_id,
                     tc_ppu_pum.weight m2m_tc_weight,
                     tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
                     rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
                     rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
                     rc_ppu_pum.cur_id m2m_rc_cur_id,
                     rc_ppu_pum.weight m2m_rc_weight,
                     rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
                     md.base_price_unit_id_in_ppu,
                     md.base_price_unit_id_in_pum,
                     qat.eval_basis,
                     pcpq.unit_of_measure,
                     pum_loc_base.weight_unit_id loc_qty_unit_id,
                     tmpc.mvp_id,
                     tmpc.shipment_month,
                     tmpc.shipment_year,
                     tmpc.valuation_point,
                     pum_base_price_id.price_unit_name base_price_unit_name,
                     nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying,
                     md.m2m_rc_fw_exch_rate,
                     md.m2m_tc_fw_exch_rate,
                     md.m2m_ld_fw_exch_rate,
                     nvl(gscs.avg_cost_fw_rate, 0) sc_in_base_cur,
                     gscs.fw_rate_string accrual_to_base_fw_rate,
                     itm.incoterm_id,
                     itm.incoterm,
                     phd_cp.profileid cp_id,
                     phd_cp.companyname cp_name,
                     (case
                       when pcdi.delivery_period_type = 'Month' then
                        pcdi.delivery_to_month || '-' || pcdi.delivery_to_year
                       else
                        to_char(pcdi.delivery_to_date, 'Mon-YYYY')
                     end) delivery_month,
                     nvl(pcdb.premium, 0) delivery_premium,
                     pcdb.premium_unit_id delivery_premium_unit_id
                from gmr_goods_movement_record gmr,
                     grd_goods_record_detail grd,
                     gpd_gmr_conc_price_daily gpd,
                     pcm_physical_contract_main pcm,
                     pcpd_pc_product_definition pcpd,
                     cpc_corporate_profit_center cpc,
                     pdm_productmaster pdm,
                     orm_origin_master orm,
                     (select tmp.*
                        from tmpc_temp_m2m_pre_check tmp
                       where tmp.corporate_id = pc_corporate_id
                         and tmp.product_type = 'CONCENTRATES'
                         and tmp.section_name <> 'OPEN') tmpc,
                     qum_quantity_unit_master qum,
                     qat_quality_attributes qat,
                     (select md1.*
                        from md_m2m_daily md1
                       where md1.rate_type <> 'OPEN'
                         and md1.corporate_id = pc_corporate_id
                         and md1.product_type = 'CONCENTRATES'
                         and md1.process_id = pc_process_id) md,
                     ciqs_contract_item_qty_status ciqs,
                     pci_physical_contract_item pci,
                     pcpq_pc_product_quality pcpq,
                     pcdi_pc_delivery_item pcdi,
                     qav_quality_attribute_values qav,
                     ppm_product_properties_mapping ppm,
                     qat_quality_attributes qat_und,
                     aml_attribute_master_list aml,
                     pcdb_pc_delivery_basis pcdb,
                     ak_corporate akc,
                     cm_currency_master cm,
                     gsm_gmr_stauts_master gsm,
                     css_corporate_strategy_setup css,
                     pdm_productmaster pdm_conc,
                     qum_quantity_unit_master qum_pdm_conc,
                     pum_price_unit_master pum_loc_base,
                     pum_price_unit_master pum_base_price_id,
                     ---- Added Suresh                   
                     ash_assay_header               ash,
                     asm_assay_sublot_mapping       asm,
                     pqca_pq_chemical_attributes    pqca,
                     rm_ratio_master                rm,
                     pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
                     qum_quantity_unit_master       gmr_qum,
                     ---
                     v_ppu_pum                    tc_ppu_pum,
                     v_ppu_pum                    rc_ppu_pum,
                     ceqs_contract_ele_qty_status ceqs,
                     sam_stock_assay_mapping      sam,
                     gscs_gmr_sec_cost_summary    gscs,
                     itm_incoterm_master          itm,
                     phd_profileheaderdetails     phd_cp
               where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpq.pcpd_id = pcpd.pcpd_id
                 and pcpd.profit_center_id = cpc.profit_center_id
                 and grd.origin_id = orm.origin_id(+)
                 and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
                 and gmr.process_id = gpd.process_id(+)
                 and gpd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no
                 and gpd.element_id = tmpc.element_id
                 and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
                 and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
                 and grd.internal_contract_item_ref_no =
                     tmpc.internal_contract_item_ref_no(+)
                 and tmpc.conc_quality_id = qat.quality_id
                 and grd.qty_unit_id = qum.qty_unit_id(+)
                 and tmpc.internal_m2m_id = md.md_id(+)
                 and tmpc.element_id = gpd.element_id
                 and md.element_id = gpd.element_id
                 and grd.process_id = gpd.process_id
                 and grd.internal_contract_item_ref_no =
                     ciqs.internal_contract_item_ref_no
                 and grd.internal_contract_item_ref_no =
                     pci.internal_contract_item_ref_no
                 and pci.pcpq_id = pcpq.pcpq_id
                 and pcm.internal_contract_ref_no =
                     pcdi.internal_contract_ref_no
                 and pcdi.pcdi_id = pci.pcdi_id
                 and pcpq.quality_template_id = qat.quality_id(+)
                 and qat.quality_id = qav.quality_id
                 and qav.attribute_id = ppm.property_id
                 and qav.comp_quality_id = qat_und.quality_id
                 and ppm.attribute_id = aml.attribute_id
                 and aml.underlying_product_id = pdm.product_id(+)
                 and aml.attribute_id = gpd.element_id
                 and pci.pcdb_id = pcdb.pcdb_id
                 and gmr.corporate_id = akc.corporate_id
                 and akc.base_cur_id = cm.cur_id
                 and gmr.status_id = gsm.status_id(+)
                 and pcpd.strategy_id = css.strategy_id
                 and pcpd.product_id = pdm_conc.product_id
                 and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
                 and md.base_price_unit_id_in_pum =
                     pum_loc_base.price_unit_id
                 and md.base_price_unit_id_in_pum =
                     pum_base_price_id.price_unit_id
                 and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
                 and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
                    ---Added Suresh
                 and grd.weg_avg_pricing_assay_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and pqca.is_elem_for_pricing = 'Y'
                 and pqca.element_id = aml.attribute_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr_qum.qty_unit_id =
                     (case when rm.ratio_name = '%' then grd.qty_unit_id else
                      rm.qty_unit_id_numerator end)
                 and pqca.pqca_id = pqcapd.pqca_id
                 and rm.is_active = 'Y'
                 and pqca.is_active = 'Y'
                 and pqcapd.is_active = 'Y'
                    ----
                 and pci.internal_contract_item_ref_no =
                     ceqs.internal_contract_item_ref_no
                 and aml.attribute_id = ceqs.element_id
                 and grd.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and pci.process_id = pc_process_id
                 and pcm.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and pcpq.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and ciqs.process_id = pc_process_id
                 and gpd.process_id = pc_process_id
                 and pcdb.process_id = pc_process_id
                 and ceqs.process_id = pc_process_id
                 and pcm.purchase_sales = 'P'
                 and pcm.contract_status = 'In Position'
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcpd.input_output = 'Input'
                 and pcm.is_tolling_contract = 'N'
                 and pcm.is_tolling_extn = 'N'
                 and pci.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and pcpq.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and ppm.is_active = 'Y'
                 and ppm.is_deleted = 'N'
                 and qav.is_deleted = 'N'
                 and qav.is_comp_product_attribute = 'Y'
                 and qat.is_active = 'Y'
                 and qat.is_deleted = 'N'
                 and aml.is_active = 'Y'
                 and aml.is_deleted = 'N'
                 and qat_und.is_active = 'Y'
                 and qat_und.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
                 and grd.status = 'Active'
                 and grd.is_deleted = 'N'
                 and gmr.is_deleted = 'N'
                 and nvl(grd.inventory_status, 'NA') = 'NA'
                 and pcm.purchase_sales = 'P'
                 and nvl(grd.current_qty, 0) > 0
                 and gmr.is_internal_movement = 'N'
                 and grd.internal_grd_ref_no = sam.internal_grd_ref_no
                 and sam.is_latest_position_assay = 'Y'
                 and gmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
                 and gmr.process_id = gscs.process_id(+)
                 and pcdb.inco_term_id = itm.incoterm_id
                 and pcm.cp_id = phd_cp.profileid(+)
              
              union all
              ------  Sales non event based GMR price using CIPDE
              select 'Sales' section_type,
                     pcpd.profit_center_id profit_center,
                     cpc.profit_center_name,
                     cpc.profit_center_short_name,
                     pc_process_id process_id,
                     gmr.corporate_id,
                     akc.corporate_name,
                     gmr.internal_gmr_ref_no,
                     dgrd.internal_contract_item_ref_no,
                     pci.del_distribution_item_no,
                     pcdi.delivery_item_no,
                     pcm.contract_ref_no,
                     pcm.purchase_sales,
                     pcpd.product_id conc_product_id,
                     pdm_conc.product_desc conc_product_name,
                     aml.underlying_product_id product_id,
                     pdm.product_desc product_name,
                     dgrd.origin_id,
                     orm.origin_name,
                     pcpq.quality_template_id conc_quality_id,
                     qat.quality_name conc_quality_name,
                     qav.comp_quality_id quality_id,
                     qat_und.quality_name,
                     '' container_no,
                     dgrd.net_weight stock_qty,
                     dgrd.net_weight_unit_id qty_unit_id,
                     gmr.qty_unit_id gmr_qty_unit_id,
                     qum.qty_unit,
                     qum.decimals stocky_qty_decimal,
                     gmr.current_no_of_units no_of_units,
                     md.md_id,
                     md.m2m_price_unit_id,
                     md.net_m2m_price,
                     md.m2m_price_unit_cur_id,
                     md.m2m_price_unit_cur_code,
                     md.m2m_price_unit_weight_unit_id,
                     md.m2m_price_unit_weight_unit,
                     nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
                     md.m2m_price_unit_cur_code || '/' ||
                     decode(md.m2m_price_unit_weight,
                            1,
                            null,
                            md.m2m_price_unit_weight) ||
                     md.m2m_price_unit_weight_unit m2m_price_unit_str,
                     md.m2m_main_cur_id,
                     md.m2m_main_cur_code,
                     md.m2m_main_cur_decimals,
                     md.main_currency_factor,
                     md.settlement_cur_id,
                     md.settlement_to_val_fx_rate,
                     cipde.element_id,
                     aml.attribute_name,
                     sam.ash_id assay_header_id,
                     ceqs.assay_qty,
                     ceqs.assay_qty_unit_id,
                     --- added Suresh
                     (case
                       when rm.ratio_name = '%' then
                        ((dgrd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                        (pqcapd.payable_percentage / 100))
                       else
                        ((dgrd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                        pqcapd.payable_percentage)
                     end) payable_qty,
                     (case
                       when rm.ratio_name = '%' then
                        dgrd.net_weight_unit_id
                       else
                        rm.qty_unit_id_numerator
                     end) payable_qty_unit_id,
                     gmr_qum.qty_unit payable_qty_unit,
                     -----
                     cipde.contract_price,
                     cipde.price_unit_id,
                     cipde.price_unit_weight_unit_id,
                     cipde.price_unit_weight,
                     cipde.price_unit_cur_id,
                     cipde.price_unit_cur_code,
                     cipde.price_unit_weight_unit,
                     cipde.price_fixation_details,
                     cipde.price_description,
                     nvl(cipde.payment_due_date, pd_trade_date) payment_due_date,
                     akc.base_cur_id as base_cur_id,
                     akc.base_currency_name base_cur_code,
                     cm.decimals as base_cur_decimal,
                     gmr.inventory_status,
                     gsm.status shipment_status,
                     (case
                       when nvl(dgrd.is_afloat, 'N') = 'Y' and
                            nvl(dgrd.inventory_status, 'NA') in ('None', 'NA') then
                        'Shipped NTT'
                       when nvl(dgrd.is_afloat, 'N') = 'Y' and
                            nvl(dgrd.inventory_status, 'NA') = 'In' then
                        'Shipped IN'
                       when nvl(dgrd.is_afloat, 'N') = 'Y' and
                            nvl(dgrd.inventory_status, 'NA') = 'Out' then
                        'Shipped TT'
                       when nvl(dgrd.is_afloat, 'N') = 'N' and
                            nvl(dgrd.inventory_status, 'NA') in ('None', 'NA') then
                        'Stock NTT'
                       when nvl(dgrd.is_afloat, 'N') = 'N' and
                            nvl(dgrd.inventory_status, 'NA') = 'In' then
                        'Stock IN'
                       when nvl(dgrd.is_afloat, 'N') = 'N' and
                            nvl(dgrd.inventory_status, 'NA') = 'Out' then
                        'Stock TT'
                       else
                        'Others'
                     end) section_name,
                     cipde.price_basis,
                     gmr.shed_id,
                     gmr.destination_city_id,
                     cipde.price_fixation_status price_fixation_status,
                     pdm.base_quantity_unit base_qty_unit_id,
                     qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
                     qum_pdm_conc.decimals as base_qty_decimal,
                     pcpd.strategy_id,
                     css.strategy_name,
                     md.valuation_exchange_id,
                     md.valuation_month,
                     md.derivative_def_id,
                     nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
                     gmr.contract_type gmr_contract_type,
                     agh.int_alloc_group_id,
                     dgrd.internal_dgrd_ref_no internal_grd_dgrd_ref_no,
                     dgrd.internal_stock_ref_no stock_ref_no,
                     pcm.trader_id,
                     (case
                       when pcm.trader_id is not null then
                        (select gab.firstname || ' ' || gab.lastname
                           from gab_globaladdressbook gab,
                                ak_corporate_user     aku
                          where gab.gabid = aku.gabid
                            and aku.user_id = pcm.trader_id)
                       else
                        ''
                     end) trader_user_name,
                     md.m2m_loc_incoterm_deviation,
                     md.treatment_charge m2m_treatment_charge,
                     md.refine_charge m2m_refine_charge,
                     tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
                     tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
                     tc_ppu_pum.cur_id m2m_tc_cur_id,
                     tc_ppu_pum.weight m2m_tc_weight,
                     tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
                     rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
                     rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
                     rc_ppu_pum.cur_id m2m_rc_cur_id,
                     rc_ppu_pum.weight m2m_rc_weight,
                     rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
                     md.base_price_unit_id_in_ppu,
                     md.base_price_unit_id_in_pum,
                     qat.eval_basis,
                     pcpq.unit_of_measure,
                     pum_loc_base.weight_unit_id loc_qty_unit_id,
                     tmpc.mvp_id,
                     tmpc.shipment_month,
                     tmpc.shipment_year,
                     tmpc.valuation_point,
                     pum_base_price_id.price_unit_name base_price_unit_name,
                     nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying,
                     md.m2m_rc_fw_exch_rate,
                     md.m2m_tc_fw_exch_rate,
                     md.m2m_ld_fw_exch_rate,
                     nvl(gscs.avg_cost_fw_rate, 0) sc_in_base_cur,
                     gscs.fw_rate_string accrual_to_base_fw_rate,
                     itm.incoterm_id,
                     itm.incoterm,
                     phd_cp.profileid cp_id,
                     phd_cp.companyname cp_name,
                     (case
                       when pcdi.delivery_period_type = 'Month' then
                        pcdi.delivery_to_month || '-' || pcdi.delivery_to_year
                       else
                        to_char(pcdi.delivery_to_date, 'Mon-YYYY')
                     end) delivery_month,
                     nvl(pcdb.premium, 0) delivery_premium,
                     pcdb.premium_unit_id delivery_premium_unit_id
              
                from gmr_goods_movement_record gmr,
                     dgrd_delivered_grd dgrd,
                     agh_alloc_group_header agh,
                     pcm_physical_contract_main pcm,
                     pcpd_pc_product_definition pcpd,
                     cpc_corporate_profit_center cpc,
                     pdm_productmaster pdm,
                     orm_origin_master orm,
                     (select tmp.*
                        from tmpc_temp_m2m_pre_check tmp
                       where tmp.corporate_id = pc_corporate_id
                         and tmp.product_type = 'CONCENTRATES'
                         and tmp.section_name <> 'OPEN') tmpc,
                     qat_quality_attributes qat,
                     qum_quantity_unit_master qum,
                     (select md1.*
                        from md_m2m_daily md1
                       where md1.rate_type <> 'OPEN'
                         and md1.corporate_id = pc_corporate_id
                         and md1.product_type = 'CONCENTRATES'
                         and md1.process_id = pc_process_id) md,
                     cipde_cipd_element_price cipde,
                     pcdi_pc_delivery_item pcdi,
                     pci_physical_contract_item pci,
                     pcpq_pc_product_quality pcpq,
                     qav_quality_attribute_values qav,
                     ppm_product_properties_mapping ppm,
                     qat_quality_attributes qat_und,
                     aml_attribute_master_list aml,
                     ciqs_contract_item_qty_status ciqs,
                     ak_corporate akc,
                     cm_currency_master cm,
                     gsm_gmr_stauts_master gsm,
                     css_corporate_strategy_setup css,
                     pcdb_pc_delivery_basis pcdb,
                     pdm_productmaster pdm_conc,
                     qum_quantity_unit_master qum_pdm_conc,
                     pum_price_unit_master pum_loc_base,
                     pum_price_unit_master pum_base_price_id,
                     --- Added Suresh
                     ash_assay_header               ash,
                     asm_assay_sublot_mapping       asm,
                     pqca_pq_chemical_attributes    pqca,
                     rm_ratio_master                rm,
                     pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
                     qum_quantity_unit_master       gmr_qum,
                     ---
                     v_ppu_pum                    tc_ppu_pum,
                     v_ppu_pum                    rc_ppu_pum,
                     ceqs_contract_ele_qty_status ceqs,
                     sam_stock_assay_mapping      sam,
                     gscs_gmr_sec_cost_summary    gscs,
                     itm_incoterm_master          itm,
                     phd_profileheaderdetails     phd_cp
               where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 and dgrd.int_alloc_group_id = agh.int_alloc_group_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpq.pcpd_id = pcpd.pcpd_id
                 and pcpd.profit_center_id = cpc.profit_center_id
                 and dgrd.origin_id = orm.origin_id(+)
                 and dgrd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
                 and dgrd.internal_dgrd_ref_no = tmpc.internal_grd_ref_no(+)
                 and dgrd.internal_contract_item_ref_no =
                     tmpc.internal_contract_item_ref_no(+)
                 and tmpc.conc_quality_id = qat.quality_id
                 and dgrd.net_weight_unit_id = qum.qty_unit_id(+)
                 and tmpc.internal_m2m_id = md.md_id(+)
                 and tmpc.element_id = cipde.element_id
                 and md.element_id = cipde.element_id
                 and dgrd.internal_contract_item_ref_no =
                     cipde.internal_contract_item_ref_no
                 and cipde.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcdi.internal_contract_ref_no
                 and pcdi.pcdi_id = pci.pcdi_id
                 and pci.internal_contract_item_ref_no =
                     cipde.internal_contract_item_ref_no
                 and pci.pcpq_id = pcpq.pcpq_id
                 and qat.quality_id = qav.quality_id
                 and qav.attribute_id = ppm.property_id
                 and qav.comp_quality_id = qat_und.quality_id
                 and pcpq.quality_template_id = qat.quality_id
                 and ppm.attribute_id = aml.attribute_id(+)
                 and aml.underlying_product_id = pdm.product_id(+)
                 and aml.attribute_id = cipde.element_id
                 and pcpq.quality_template_id = qat.quality_id(+)
                 and pci.internal_contract_item_ref_no =
                     ciqs.internal_contract_item_ref_no
                 and gmr.corporate_id = akc.corporate_id
                 and akc.base_cur_id = cm.cur_id
                 and cm.cur_code = akc.base_currency_name
                 and gmr.status_id = gsm.status_id(+)
                 and pcpd.strategy_id = css.strategy_id
                 and pci.pcdb_id = pcdb.pcdb_id
                 and pcpd.product_id = pdm_conc.product_id
                 and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
                 and md.base_price_unit_id_in_pum =
                     pum_loc_base.price_unit_id
                 and md.base_price_unit_id_in_pum =
                     pum_base_price_id.price_unit_id
                 and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
                 and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
                    --- Added Suresh
                 and dgrd.weg_avg_pricing_assay_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and pqca.is_elem_for_pricing = 'Y'
                 and pqca.element_id = aml.attribute_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr_qum.qty_unit_id =
                     (case when rm.ratio_name = '%' then
                      dgrd.net_weight_unit_id else rm.qty_unit_id_numerator end)
                 and pqca.pqca_id = pqcapd.pqca_id
                 and rm.is_active = 'Y'
                 and pqca.is_active = 'Y'
                 and pqcapd.is_active = 'Y'
                    ----
                 and pci.internal_contract_item_ref_no =
                     ceqs.internal_contract_item_ref_no
                 and aml.attribute_id = ceqs.element_id
                 and pcm.purchase_sales = 'S'
                 and gsm.is_required_for_m2m = 'Y'
                 and pcm.contract_status = 'In Position'
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcpd.input_output = 'Input'
                 and pcm.is_tolling_contract = 'N'
                 and pcm.is_tolling_extn = 'N'
                 and pci.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and pcpq.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and pcdb.is_active = 'Y'
                 and gmr.is_deleted = 'N'
                 and ppm.is_active = 'Y'
                 and ppm.is_deleted = 'N'
                 and qav.is_deleted = 'N'
                 and qav.is_comp_product_attribute = 'Y'
                 and qat.is_active = 'Y'
                 and qat.is_deleted = 'N'
                 and aml.is_active = 'Y'
                 and aml.is_deleted = 'N'
                 and qat_und.is_active = 'Y'
                 and qat_und.is_deleted = 'N'
                 and pcm.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pci.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and dgrd.process_id = pc_process_id
                 and agh.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and cipde.process_id = pc_process_id
                 and pcpq.process_id = pc_process_id
                 and ciqs.process_id = pc_process_id
                 and pcdb.process_id = pc_process_id
                 and ceqs.process_id = pc_process_id
                 and upper(dgrd.realized_status) in
                     ('UNREALIZED', 'REVERSEREALIZED')
                 and dgrd.status = 'Active'
                 and nvl(dgrd.net_weight, 0) > 0
                 and agh.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
                 and gmr.is_internal_movement = 'N'
                 and dgrd.internal_dgrd_ref_no = sam.internal_dgrd_ref_no
                 and sam.is_latest_position_assay = 'Y'
                 and pcdb.inco_term_id = itm.incoterm_id
                 and not exists
               (select gpd.process_id
                        from gpd_gmr_conc_price_daily gpd
                       where gpd.process_id = gmr.process_id
                         and gpd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                         and gpd.corporate_id = gmr.corporate_id
                         and gpd.element_id = tmpc.element_id)
                 and gmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
                 and gmr.process_id = gscs.process_id(+)
                 and pcm.cp_id = phd_cp.profileid(+)
              
              union all
              ------  Sales  event based GMR price using GPE
              select 'Sales' section_type,
                     pcpd.profit_center_id profit_center,
                     cpc.profit_center_name,
                     cpc.profit_center_short_name,
                     pc_process_id process_id,
                     gmr.corporate_id,
                     akc.corporate_name,
                     gmr.internal_gmr_ref_no,
                     dgrd.internal_contract_item_ref_no,
                     pci.del_distribution_item_no,
                     pcdi.delivery_item_no,
                     pcm.contract_ref_no,
                     pcm.purchase_sales,
                     pcpd.product_id conc_product_id,
                     pdm_conc.product_desc conc_product_name,
                     aml.underlying_product_id product_id,
                     pdm.product_desc product_name,
                     dgrd.origin_id,
                     orm.origin_name,
                     pcpq.quality_template_id conc_quality_id,
                     qat.quality_name conc_quality_name,
                     qav.comp_quality_id quality_id,
                     qat_und.quality_name,
                     '' container_no,
                     dgrd.net_weight stock_qty,
                     dgrd.net_weight_unit_id qty_unit_id,
                     gmr.qty_unit_id gmr_qty_unit_id,
                     qum.qty_unit,
                     qum.decimals stocky_qty_decimal,
                     gmr.current_no_of_units no_of_units,
                     md.md_id,
                     md.m2m_price_unit_id,
                     md.net_m2m_price,
                     md.m2m_price_unit_cur_id,
                     md.m2m_price_unit_cur_code,
                     md.m2m_price_unit_weight_unit_id,
                     md.m2m_price_unit_weight_unit,
                     nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
                     md.m2m_price_unit_cur_code || '/' ||
                     decode(md.m2m_price_unit_weight,
                            1,
                            null,
                            md.m2m_price_unit_weight) ||
                     md.m2m_price_unit_weight_unit m2m_price_unit_str,
                     md.m2m_main_cur_id,
                     md.m2m_main_cur_code,
                     md.m2m_main_cur_decimals,
                     md.main_currency_factor,
                     md.settlement_cur_id,
                     md.settlement_to_val_fx_rate,
                     ceqs.element_id,
                     aml.attribute_name,
                     sam.ash_id assay_header_id,
                     ceqs.assay_qty,
                     ceqs.assay_qty_unit_id,
                     -- added Suresh
                     (case
                       when rm.ratio_name = '%' then
                        ((dgrd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                        (pqcapd.payable_percentage / 100))
                       else
                        ((dgrd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                        pqcapd.payable_percentage)
                     end) payable_qty,
                     (case
                       when rm.ratio_name = '%' then
                        dgrd.net_weight_unit_id
                       else
                        rm.qty_unit_id_numerator
                     end) payable_qty_unit_id,
                     gmr_qum.qty_unit payable_qty_unit,
                     ---
                     gpd.contract_price,
                     gpd.price_unit_id,
                     gpd.price_unit_weight_unit_id,
                     gpd.price_unit_weight,
                     gpd.price_unit_cur_id,
                     gpd.price_unit_cur_code,
                     gpd.price_unit_weight_unit,
                     gpd.price_fixation_details,
                     gpd.price_description,
                     (case
                       when nvl(pcdi.payment_due_date, pd_trade_date) <
                            pd_trade_date then
                        pd_trade_date
                       else
                        nvl(pcdi.payment_due_date, pd_trade_date)
                     end) payment_due_date,
                     akc.base_cur_id as base_cur_id,
                     akc.base_currency_name base_cur_code,
                     cm.decimals as base_cur_decimal,
                     gmr.inventory_status,
                     gsm.status shipment_status,
                     (case
                       when nvl(dgrd.is_afloat, 'N') = 'Y' and
                            nvl(dgrd.inventory_status, 'NA') in ('None', 'NA') then
                        'Shipped NTT'
                       when nvl(dgrd.is_afloat, 'N') = 'Y' and
                            nvl(dgrd.inventory_status, 'NA') = 'In' then
                        'Shipped IN'
                       when nvl(dgrd.is_afloat, 'N') = 'Y' and
                            nvl(dgrd.inventory_status, 'NA') = 'Out' then
                        'Shipped TT'
                       when nvl(dgrd.is_afloat, 'N') = 'N' and
                            nvl(dgrd.inventory_status, 'NA') in ('None', 'NA') then
                        'Stock NTT'
                       when nvl(dgrd.is_afloat, 'N') = 'N' and
                            nvl(dgrd.inventory_status, 'NA') = 'In' then
                        'Stock IN'
                       when nvl(dgrd.is_afloat, 'N') = 'N' and
                            nvl(dgrd.inventory_status, 'NA') = 'Out' then
                        'Stock TT'
                       else
                        'Others'
                     end) section_name,
                     gpd.price_basis,
                     gmr.shed_id,
                     gmr.destination_city_id,
                     gpd.price_fixation_status,
                     pdm.base_quantity_unit base_qty_unit_id,
                     qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
                     qum_pdm_conc.decimals as base_qty_decimal,
                     pcpd.strategy_id,
                     css.strategy_name,
                     md.valuation_exchange_id,
                     md.valuation_month,
                     md.derivative_def_id,
                     nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
                     gmr.contract_type gmr_contract_type,
                     agh.int_alloc_group_id,
                     dgrd.internal_dgrd_ref_no internal_grd_dgrd_ref_no,
                     dgrd.internal_stock_ref_no stock_ref_no,
                     pcm.trader_id,
                     (case
                       when pcm.trader_id is not null then
                        (select gab.firstname || ' ' || gab.lastname
                           from gab_globaladdressbook gab,
                                ak_corporate_user     aku
                          where gab.gabid = aku.gabid
                            and aku.user_id = pcm.trader_id)
                       else
                        ''
                     end) trader_user_name,
                     md.m2m_loc_incoterm_deviation,
                     md.treatment_charge m2m_treatment_charge,
                     md.refine_charge m2m_refine_charge,
                     tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
                     tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
                     tc_ppu_pum.cur_id m2m_tc_cur_id,
                     tc_ppu_pum.weight m2m_tc_weight,
                     tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
                     rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
                     rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
                     rc_ppu_pum.cur_id m2m_rc_cur_id,
                     rc_ppu_pum.weight m2m_rc_weight,
                     rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
                     md.base_price_unit_id_in_ppu,
                     md.base_price_unit_id_in_pum,
                     qat.eval_basis,
                     pcpq.unit_of_measure,
                     pum_loc_base.weight_unit_id loc_qty_unit_id,
                     tmpc.mvp_id,
                     tmpc.shipment_month,
                     tmpc.shipment_year,
                     tmpc.valuation_point,
                     pum_base_price_id.price_unit_name base_price_unit_name,
                     nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying,
                     md.m2m_rc_fw_exch_rate,
                     md.m2m_tc_fw_exch_rate,
                     md.m2m_ld_fw_exch_rate,
                     nvl(gscs.avg_cost_fw_rate, 0) sc_in_base_cur,
                     gscs.fw_rate_string accrual_to_base_fw_rate,
                     itm.incoterm_id,
                     itm.incoterm,
                     phd_cp.profileid cp_id,
                     phd_cp.companyname cp_name,
                     (case
                       when pcdi.delivery_period_type = 'Month' then
                        pcdi.delivery_to_month || '-' || pcdi.delivery_to_year
                       else
                        to_char(pcdi.delivery_to_date, 'Mon-YYYY')
                     end) delivery_month,
                     nvl(pcdb.premium, 0) delivery_premium,
                     pcdb.premium_unit_id delivery_premium_unit_id
              
                from gmr_goods_movement_record gmr,
                     gpd_gmr_conc_price_daily gpd,
                     dgrd_delivered_grd dgrd,
                     agh_alloc_group_header agh,
                     pcm_physical_contract_main pcm,
                     pcpd_pc_product_definition pcpd,
                     cpc_corporate_profit_center cpc,
                     pdm_productmaster pdm,
                     orm_origin_master orm,
                     (select tmp.*
                        from tmpc_temp_m2m_pre_check tmp
                       where tmp.corporate_id = pc_corporate_id
                         and tmp.product_type = 'CONCENTRATES'
                         and tmp.section_name <> 'OPEN') tmpc,
                     qat_quality_attributes qat,
                     qum_quantity_unit_master qum,
                     (select md1.*
                        from md_m2m_daily md1
                       where md1.rate_type <> 'OPEN'
                         and md1.corporate_id = pc_corporate_id
                         and md1.product_type = 'CONCENTRATES'
                         and md1.process_id = pc_process_id) md,
                     pcdi_pc_delivery_item pcdi,
                     pci_physical_contract_item pci,
                     pcpq_pc_product_quality pcpq,
                     qav_quality_attribute_values qav,
                     ppm_product_properties_mapping ppm,
                     qat_quality_attributes qat_und,
                     aml_attribute_master_list aml,
                     ciqs_contract_item_qty_status ciqs,
                     ak_corporate akc,
                     cm_currency_master cm,
                     gsm_gmr_stauts_master gsm,
                     css_corporate_strategy_setup css,
                     pcdb_pc_delivery_basis pcdb,
                     pdm_productmaster pdm_conc,
                     qum_quantity_unit_master qum_pdm_conc,
                     pum_price_unit_master pum_loc_base,
                     pum_price_unit_master pum_base_price_id,
                     -- Added Suresh
                     ash_assay_header               ash,
                     asm_assay_sublot_mapping       asm,
                     pqca_pq_chemical_attributes    pqca,
                     rm_ratio_master                rm,
                     pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
                     qum_quantity_unit_master       gmr_qum,
                     --
                     v_ppu_pum                    tc_ppu_pum,
                     v_ppu_pum                    rc_ppu_pum,
                     ceqs_contract_ele_qty_status ceqs,
                     sam_stock_assay_mapping      sam,
                     gscs_gmr_sec_cost_summary    gscs,
                     itm_incoterm_master          itm,
                     phd_profileheaderdetails     phd_cp
               where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 and dgrd.int_alloc_group_id = agh.int_alloc_group_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpq.pcpd_id = pcpd.pcpd_id
                 and pcpd.profit_center_id = cpc.profit_center_id
                 and dgrd.origin_id = orm.origin_id(+)
                 and dgrd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
                 and dgrd.internal_dgrd_ref_no = tmpc.internal_grd_ref_no(+)
                 and dgrd.internal_contract_item_ref_no =
                     tmpc.internal_contract_item_ref_no(+)
                 and tmpc.conc_quality_id = qat.quality_id
                 and dgrd.net_weight_unit_id = qum.qty_unit_id(+)
                 and tmpc.internal_m2m_id = md.md_id(+)
                 and tmpc.element_id = gpd.element_id
                 and md.element_id = gpd.element_id
                 and pcm.internal_contract_ref_no =
                     pcdi.internal_contract_ref_no
                 and pcdi.pcdi_id = pci.pcdi_id
                 and pci.pcpq_id = pcpq.pcpq_id
                 and qat.quality_id = qav.quality_id
                 and qav.attribute_id = ppm.property_id
                 and qav.comp_quality_id = qat_und.quality_id
                 and pcpq.quality_template_id = qat.quality_id
                 and ppm.attribute_id = aml.attribute_id(+)
                 and aml.underlying_product_id = pdm.product_id(+)
                 and aml.attribute_id = gpd.element_id
                 and pcpq.quality_template_id = qat.quality_id(+)
                 and pci.internal_contract_item_ref_no =
                     ciqs.internal_contract_item_ref_no
                 and gmr.corporate_id = akc.corporate_id
                 and akc.base_cur_id = cm.cur_id
                 and cm.cur_code = akc.base_currency_name
                 and gmr.status_id = gsm.status_id(+)
                 and pcpd.strategy_id = css.strategy_id
                 and pci.pcdb_id = pcdb.pcdb_id
                 and pcpd.product_id = pdm_conc.product_id
                 and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
                 and md.base_price_unit_id_in_pum =
                     pum_loc_base.price_unit_id
                 and md.base_price_unit_id_in_pum =
                     pum_base_price_id.price_unit_id
                 and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
                 and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
                    --- Added Suresh
                 and dgrd.weg_avg_pricing_assay_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and pqca.is_elem_for_pricing = 'Y'
                 and pqca.element_id = aml.attribute_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr_qum.qty_unit_id =
                     (case when rm.ratio_name = '%' then
                      dgrd.net_weight_unit_id else rm.qty_unit_id_numerator end)
                 and pqca.pqca_id = pqcapd.pqca_id
                 and rm.is_active = 'Y'
                 and pqca.is_active = 'Y'
                 and pqcapd.is_active = 'Y'
                    ---
                 and pci.internal_contract_item_ref_no =
                     ceqs.internal_contract_item_ref_no
                 and aml.attribute_id = ceqs.element_id
                 and pcm.purchase_sales = 'S'
                 and gsm.is_required_for_m2m = 'Y'
                 and pcm.contract_status = 'In Position'
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcpd.input_output = 'Input'
                 and pcm.is_tolling_contract = 'N'
                 and pcm.is_tolling_extn = 'N'
                 and pci.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and pcpq.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and pcdb.is_active = 'Y'
                 and gmr.is_deleted = 'N'
                 and ppm.is_active = 'Y'
                 and ppm.is_deleted = 'N'
                 and qav.is_deleted = 'N'
                 and qav.is_comp_product_attribute = 'Y'
                 and qat.is_active = 'Y'
                 and qat.is_deleted = 'N'
                 and aml.is_active = 'Y'
                 and aml.is_deleted = 'N'
                 and qat_und.is_active = 'Y'
                 and qat_und.is_deleted = 'N'
                 and pcm.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pci.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and dgrd.process_id = pc_process_id
                 and agh.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and gpd.process_id = pc_process_id
                 and pcpq.process_id = pc_process_id
                 and ciqs.process_id = pc_process_id
                 and pcdb.process_id = pc_process_id
                 and ceqs.process_id = pc_process_id
                 and upper(dgrd.realized_status) in
                     ('UNREALIZED', 'REVERSEREALIZED')
                 and dgrd.status = 'Active'
                 and nvl(dgrd.net_weight, 0) > 0
                 and agh.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
                 and gmr.is_internal_movement = 'N'
                 and dgrd.internal_dgrd_ref_no = sam.internal_dgrd_ref_no
                 and sam.is_latest_position_assay = 'Y'
                 and gmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
                 and gmr.process_id = gscs.process_id(+)
                 and pcdb.inco_term_id = itm.incoterm_id
                 and pcm.cp_id = phd_cp.profileid(+)
                 and pci.internal_contract_item_ref_no =
                     dgrd.internal_contract_item_ref_no
                 and gpd.internal_gmr_ref_no = gmr.internal_gmr_ref_no) tt;
  
    vn_cont_price                  number;
    vc_cont_price_unit_id          varchar2(15);
    vc_cont_price_unit_cur_id      varchar2(15);
    vc_cont_price_unit_cur_code    varchar2(15);
    vn_cont_price_wt               number;
    vc_cont_price_wt_unit_id       varchar2(15);
    vc_cont_price_wt_unit          varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vc_psu_id                      varchar2(500);
    vn_qty_in_base                 number;
    vn_ele_qty_in_base             number;
    vn_m2m_amt                     number;
    vc_m2m_price_unit_cur_id       varchar2(15);
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_ele_m2m_amount_in_base      number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_ele_m2m_total_amount        number;
    vn_ele_m2m_amt_per_unit        number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_contract_value_in_price_cur number;
    vn_cont_price_cur_decimals     number;
    vn_fx_price_to_base            number;
    vn_fx_price_deviation          number;
    vn_contract_value_in_val_cur   number;
    vn_contract_value_in_base_cur  number;
    vn_ele_m2m_treatment_charge    number;
    vn_dry_qty                     number;
    vn_wet_qty                     number;
    vn_dry_qty_in_base             number;
    vn_ele_m2m_refine_charge       number;
    vn_loc_amount                  number;
    vn_loc_total_amount            number;
    vn_m2m_total_penality          number;
    vn_m2m_penality                number;
    vc_penality_price_unit_id      varchar2(15);
    vc_price_unit_id               varchar2(15);
    vc_m2m_to_base_fw_rate         varchar2(50);
    vc_price_to_base_fw_rate       varchar2(50);
    vc_pc_exch_rate_string         varchar2(100);
    vc_total_pc_exch_rate_string   varchar2(100); -- Contract Penalty 
    vc_m2m_total_pc_fw_exch_rate   varchar2(100);--M2M Penality
    vc_m2m_pc_fw_exch_rate         varchar2(100);
    vn_con_treatment_charge        number;
    vn_base_con_treatment_charge   number;
    vc_con_treatment_cur_id        varchar2(15);
    vc_con_tc_main_cur_id          varchar2(15);
    vc_con_tc_main_cur_code        varchar2(15);
    vc_con_tc_main_cur_factor      number;
    vn_con_tc_to_base_fw_rate      number;
    vc_contract_tc_fw_exch_rate    varchar2(50);
    vn_forward_points              number;
    vn_con_refine_charge           number;
    vn_base_con_refine_charge      number;
    vc_con_refine_cur_id           varchar2(15);
    vc_con_rc_main_cur_id          varchar2(15);
    vc_con_rc_main_cur_code        varchar2(15);
    vc_con_rc_main_cur_factor      number;
    vn_con_rc_to_base_fw_rate      number;
    vc_contract_rc_fw_exch_rate    varchar2(50);
    vn_sc_in_base_cur              number;
    vn_con_penality_charge         number;
    vc_con_penality_cur_id         varchar2(15);
    vc_conc_pc_main_cur_id         varchar2(15);
    vc_con_pc_main_cur_code        varchar2(15);
    vc_con_pc_main_cur_factor      number;
    vn_con_pc_to_base_fw_rate      number;
    vn_base_con_penality_charge    number;
    vc_contract_pc_fw_exch_rate    varchar2(50);
    vc_error_msg                   varchar2(10);
    vc_m2m_tc_main_cur_id          varchar2(15);
    vc_m2m_tc_main_cur_code        varchar2(15);
    vc_m2m_tc_main_cur_factor      number;
    vn_m2m_tc_to_base_fw_rate      number;
    vc_m2m_rc_main_cur_id          varchar2(15);
    vc_m2m_rc_main_cur_code        varchar2(15);
    vc_m2m_rc_main_cur_factor      number;
    vn_m2m_rc_to_base_fw_rate      number;
    vn_cont_delivery_premium       number;
    vn_cont_del_premium_amt        number;
    vc_contract_pp_fw_exch_rate    varchar2(50);
    vc_base_price_unit_id          varchar2(15);
    vn_del_to_base_fw_rate         varchar2(50);
    vc_del_premium_cur_id          varchar2(15);
    vc_del_premium_cur_code        varchar2(15);
    vn_del_premium_weight          number;
    vc_del_premium_weight_unit_id  varchar2(15);
    vc_del_premium_main_cur_id     varchar2(15);
    vc_del_premium_main_cur_code   varchar2(15);
    vn_del_premium_cur_main_factor number;
  begin
    vc_error_msg := '18647';
    for cur_grd_rows in cur_grd
    loop
      vc_price_to_base_fw_rate     := null;
      vc_pc_exch_rate_string       := null;
      vc_total_pc_exch_rate_string := null;
      vc_contract_tc_fw_exch_rate  := null;
      vc_contract_rc_fw_exch_rate  := null;
      vc_contract_pc_fw_exch_rate  := null;
      vc_contract_pp_fw_exch_rate  := null;
      vc_m2m_to_base_fw_rate       := null;
    
      vn_cont_price               := cur_grd_rows.contract_price;
      vc_cont_price_unit_id       := cur_grd_rows.price_unit_id;
      vc_cont_price_unit_cur_id   := cur_grd_rows.price_unit_cur_id;
      vc_cont_price_unit_cur_code := cur_grd_rows.price_unit_cur_code;
      vn_cont_price_wt            := cur_grd_rows.price_unit_weight;
      vc_cont_price_wt_unit_id    := cur_grd_rows.price_unit_weight_unit_id;
      vc_cont_price_wt_unit       := cur_grd_rows.price_unit_weight_unit;
      vc_price_fixation_status    := cur_grd_rows.price_fixation_status;
    
      begin
        select ppu.product_price_unit_id
          into vc_base_price_unit_id
          from v_ppu_pum ppu
         where ppu.cur_id = cur_grd_rows.base_cur_id
           and ppu.weight_unit_id = cur_grd_rows.conc_base_qty_unit_id
           and nvl(ppu.weight, 1) = 1
           and ppu.product_id = cur_grd_rows.conc_product_id;
      exception
        when others then
          null;
      end;
    
      if cur_grd_rows.stock_qty <> 0 then
        vc_psu_id := cur_grd_rows.internal_gmr_ref_no || '-' ||
                     cur_grd_rows.internal_grd_dgrd_ref_no || '-' ||
                     cur_grd_rows.internal_contract_item_ref_no || '-' ||
                     cur_grd_rows.container_no;
      
        if cur_grd_rows.unit_of_measure = 'Wet' then
          vn_dry_qty := round(pkg_metals_general.fn_get_assay_dry_qty(cur_grd_rows.conc_product_id,
                                                                      cur_grd_rows.assay_header_id,
                                                                      cur_grd_rows.stock_qty,
                                                                      cur_grd_rows.qty_unit_id),
                              cur_grd_rows.stocky_qty_decimal);
        else
          vn_dry_qty := cur_grd_rows.stock_qty;
        end if;
      
        vn_wet_qty := cur_grd_rows.stock_qty;
      
        -- convert into dry qty to base qty element level
        vc_error_msg := '18677';
        if cur_grd_rows.qty_unit_id <> cur_grd_rows.base_qty_unit_id then
          vn_dry_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                           cur_grd_rows.qty_unit_id,
                                                                           cur_grd_rows.base_qty_unit_id,
                                                                           1) *
                                      vn_dry_qty,
                                      cur_grd_rows.base_qty_decimal);
        else
          vn_dry_qty_in_base := round(vn_dry_qty,
                                      cur_grd_rows.base_qty_decimal);
        end if;
        if cur_grd_rows.qty_unit_id <> cur_grd_rows.conc_base_qty_unit_id then
        
          vn_qty_in_base := round(cur_grd_rows.stock_qty *
                                  pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                       cur_grd_rows.qty_unit_id,
                                                                       cur_grd_rows.conc_base_qty_unit_id,
                                                                       1),
                                  cur_grd_rows.base_qty_decimal);
        else
          vn_qty_in_base := round(cur_grd_rows.stock_qty,
                                  cur_grd_rows.base_qty_decimal);
        end if;
      
        if cur_grd_rows.payable_qty_unit_id <>
           cur_grd_rows.base_qty_unit_id then
          vn_ele_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                           cur_grd_rows.payable_qty_unit_id,
                                                                           cur_grd_rows.base_qty_unit_id,
                                                                           1) *
                                      cur_grd_rows.payable_qty,
                                      cur_grd_rows.base_qty_decimal);
        else
          vn_ele_qty_in_base := round(cur_grd_rows.payable_qty,
                                      cur_grd_rows.base_qty_decimal);
        end if;
      
        if cur_grd_rows.valuation_against_underlying = 'Y' then
          if cur_grd_rows.eval_basis = 'FIXED' then
            vn_m2m_amt               := 0;
            vc_m2m_price_unit_cur_id := cur_grd_rows.base_cur_id;
          else
            vc_m2m_price_unit_cur_id := nvl(cur_grd_rows.m2m_price_unit_cur_id,
                                            cur_grd_rows.base_cur_id);
            vn_m2m_amt               := nvl(cur_grd_rows.net_m2m_price, 0) /
                                        nvl(cur_grd_rows.m2m_price_unit_weight,
                                            1) *
                                        pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                             cur_grd_rows.payable_qty_unit_id,
                                                                             cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                             cur_grd_rows.payable_qty);
          end if;
        
          pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                                 cur_grd_rows.base_cur_id),
                                             vc_m2m_cur_id,
                                             vc_m2m_cur_code,
                                             vn_m2m_sub_cur_id_factor,
                                             vn_m2m_cur_decimals);
        
          vn_m2m_amt := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor,
                              cur_grd_rows.base_cur_decimal);
        
          pkg_general.sp_bank_fx_rate(cur_grd_rows.corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      nvl(vc_m2m_cur_id,
                                          cur_grd_rows.base_cur_id),
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      
                                      'sp_stock_unreal_sntt_conc M2M to Base Currency',
                                      pc_process,
                                      vn_m2m_base_fx_rate,
                                      vn_m2m_base_deviation);
          vc_error_msg := '18734';
          if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
            if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
              null;
            else
              vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                        vn_m2m_base_fx_rate || ' ' ||
                                        cur_grd_rows.base_cur_code;
            end if;
          end if;
        
          vn_ele_m2m_amount_in_base := vn_m2m_amt * vn_m2m_base_fx_rate;
        else
          -- If valuation against underly is no, then use total concentrate qty and market price to calculate the
          -- Market value for the gmr level.
          if cur_grd_rows.eval_basis = 'FIXED' then
            vn_m2m_amt               := 0;
            vc_m2m_price_unit_cur_id := cur_grd_rows.base_cur_id;
          else
            vc_m2m_price_unit_cur_id := nvl(cur_grd_rows.m2m_price_unit_cur_id,
                                            cur_grd_rows.base_cur_id);
            vn_m2m_amt               := nvl(cur_grd_rows.net_m2m_price, 0) /
                                        nvl(cur_grd_rows.m2m_price_unit_weight,
                                            1) *
                                        pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                             cur_grd_rows.conc_base_qty_unit_id,
                                                                             cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                             vn_dry_qty_in_base);
          end if;
        
          pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                                 cur_grd_rows.base_cur_id),
                                             vc_m2m_cur_id,
                                             vc_m2m_cur_code,
                                             vn_m2m_sub_cur_id_factor,
                                             vn_m2m_cur_decimals);
        
          vn_m2m_amt := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor,
                              cur_grd_rows.base_cur_decimal);
        
          pkg_general.sp_bank_fx_rate(cur_grd_rows.corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      nvl(vc_m2m_cur_id,
                                          cur_grd_rows.base_cur_id),
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_sntt_conc M2M to Base Currency',
                                      pc_process,
                                      vn_m2m_base_fx_rate,
                                      vn_m2m_base_deviation);
        
          if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
            if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
              null;
            else
              vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                        vn_m2m_base_fx_rate || ' ' ||
                                        cur_grd_rows.base_cur_code;
            
            end if;
          else
            vn_m2m_base_fx_rate := 1;
          end if;
          if cur_grd_rows.ele_rank = 1 then
            vn_ele_m2m_amount_in_base := vn_m2m_amt * vn_m2m_base_fx_rate;
          else
            vn_ele_m2m_amount_in_base := 0;
            vn_m2m_amt                := 0;
          end if;
        
        end if;
        --
        -- Forward Rate from M2M Treatment Charge to Base Currency
        -- 
        pkg_general.sp_get_base_cur_detail(cur_grd_rows.m2m_tc_cur_id,
                                           vc_m2m_tc_main_cur_id,
                                           vc_m2m_tc_main_cur_code,
                                           vc_m2m_tc_main_cur_factor);
        if vc_m2m_tc_main_cur_id <> cur_grd_rows.base_cur_id then
          pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      cur_grd_rows.m2m_tc_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_sntt_conc M2M TC to Base Currency',
                                      pc_process,
                                      vn_m2m_tc_to_base_fw_rate,
                                      vn_forward_points);
        else
          vn_m2m_tc_to_base_fw_rate := 1;
        end if;
        -- dbms_output.put_line('vn_dry_qty=' || vn_dry_qty);
        vn_ele_m2m_treatment_charge := round((cur_grd_rows.m2m_treatment_charge /
                                             nvl(cur_grd_rows.m2m_tc_weight,
                                                  1)) *
                                             vn_m2m_tc_to_base_fw_rate *
                                             (pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                                   cur_grd_rows.qty_unit_id,
                                                                                   cur_grd_rows.m2m_tc_weight_unit_id,
                                                                                   vn_dry_qty)),
                                             cur_grd_rows.base_cur_decimal);
      
        -- dbms_output.put_line('Test' || vn_ele_m2m_treatment_charge);
      
        pkg_general.sp_get_base_cur_detail(cur_grd_rows.m2m_rc_cur_id,
                                           vc_m2m_rc_main_cur_id,
                                           vc_m2m_rc_main_cur_code,
                                           vc_m2m_rc_main_cur_factor);
        if vc_m2m_rc_main_cur_id <> cur_grd_rows.base_cur_id then
          pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      cur_grd_rows.m2m_rc_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_sntt_conc M2M RC to Base Currency',
                                      pc_process,
                                      vn_m2m_rc_to_base_fw_rate,
                                      vn_forward_points);
        else
          vn_m2m_rc_to_base_fw_rate := 1;
        end if;
      
        vn_ele_m2m_refine_charge := round((cur_grd_rows.m2m_refine_charge /
                                          nvl(cur_grd_rows.m2m_rc_weight,
                                               1)) *
                                          vn_m2m_rc_to_base_fw_rate *
                                          (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                                cur_grd_rows.payable_qty_unit_id,
                                                                                cur_grd_rows.m2m_rc_weight_unit_id,
                                                                                cur_grd_rows.payable_qty)),
                                          cur_grd_rows.base_cur_decimal);
      
        if cur_grd_rows.ele_rank = 1 then
          vn_loc_amount := pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                cur_grd_rows.qty_unit_id,
                                                                cur_grd_rows.conc_base_qty_unit_id,
                                                                1) *
                           cur_grd_rows.m2m_loc_incoterm_deviation;
        
          vn_loc_total_amount := round(vn_loc_amount * vn_qty_in_base,
                                       cur_grd_rows.base_cur_decimal);
          -- Contract Penalty Charge                    
          pkg_metals_general.sp_get_gmr_penalty_charge_new(cur_grd_rows.internal_gmr_ref_no,
                                                           cur_grd_rows.internal_grd_dgrd_ref_no,
                                                           pc_dbd_id,
                                                           vn_con_penality_charge,
                                                           vc_con_penality_cur_id);
        
          if vn_con_penality_charge <> 0 then
            pkg_general.sp_get_base_cur_detail(vc_con_penality_cur_id,
                                               vc_conc_pc_main_cur_id,
                                               vc_con_pc_main_cur_code,
                                               vc_con_pc_main_cur_factor);
            if vc_conc_pc_main_cur_id <> cur_grd_rows.base_cur_id then
            
              pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                          pd_trade_date,
                                          cur_grd_rows.payment_due_date,
                                          vc_conc_pc_main_cur_id,
                                          cur_grd_rows.base_cur_id,
                                          30,
                                          'sp_stock_unreal_sntt_conc Contract PC to Base Currency',
                                          pc_process,
                                          vn_con_pc_to_base_fw_rate,
                                          vn_forward_points);
              vn_base_con_penality_charge := round((vn_con_penality_charge *
                                                   vn_con_pc_to_base_fw_rate *
                                                   vc_con_pc_main_cur_factor),
                                                   cur_grd_rows.base_cur_decimal);
            
              vc_contract_pc_fw_exch_rate := '1 ' ||
                                             vc_con_pc_main_cur_code || '=' ||
                                             vn_con_pc_to_base_fw_rate || ' ' ||
                                             cur_grd_rows.base_cur_code;
            
            else
              vn_base_con_penality_charge := round(vn_con_penality_charge,
                                                   cur_grd_rows.base_cur_decimal);
            
            end if;
          else
            vn_base_con_penality_charge := 0;
          end if;
        
        end if;
        vn_m2m_total_penality := 0;
        if cur_grd_rows.ele_rank = 1 then
          begin
            select ppu.product_price_unit_id
              into vc_price_unit_id
              from v_ppu_pum         ppu,
                   pdm_productmaster pdm,
                   ak_corporate      akc
             where ppu.product_id = cur_grd_rows.conc_product_id
               and ppu.product_id = pdm.product_id
               and pdm.base_quantity_unit = ppu.weight_unit_id
               and ppu.cur_id = akc.base_cur_id
               and nvl(ppu.weight, 1) = 1
               and akc.corporate_id = pc_corporate_id;
          
          exception
            when no_data_found then
              vc_price_unit_id := null;
          end;
        
          vn_m2m_total_penality := 0;
          for cc in (select pci.internal_contract_item_ref_no,
                            pqca.element_id,
                            aml.attribute_name,
                            pcpq.quality_template_id
                       from pci_physical_contract_item  pci,
                            pcpq_pc_product_quality     pcpq,
                            ash_assay_header            ash,
                            asm_assay_sublot_mapping    asm,
                            pqca_pq_chemical_attributes pqca,
                            aml_attribute_master_list   aml
                      where pci.pcpq_id = pcpq.pcpq_id
                        and pcpq.assay_header_id = ash.ash_id
                        and ash.ash_id = asm.ash_id
                        and asm.asm_id = pqca.asm_id
                        and pqca.element_id=aml.attribute_id
                        and pci.process_id = pc_process_id
                        and pcpq.process_id = pc_process_id
                        and pci.is_active = 'Y'
                        and pcpq.is_active = 'Y'
                        and ash.is_active = 'Y'
                        and asm.is_active = 'Y'
                        and pqca.is_active = 'Y'
                        and pqca.is_elem_for_pricing = 'N'
                        and pci.internal_contract_item_ref_no =
                            cur_grd_rows.internal_contract_item_ref_no)
          loop
          
            pkg_phy_pre_check_process.sp_m2m_tc_pc_rc_charge(cur_grd_rows.corporate_id,
                                                                  pd_trade_date,
                                                                  cur_grd_rows.conc_product_id,
                                                                  cur_grd_rows.conc_quality_id,
                                                                  cur_grd_rows.mvp_id,
                                                                  'Penalties',
                                                                  cc.element_id,
                                                                  to_char(pd_trade_date,
                                                                          'Mon'),
                                                                  to_char(pd_trade_date,
                                                                          'YYYY'),
                                                                  vc_price_unit_id,
                                                                  cur_grd_rows.payment_due_date,
                                                                  vn_m2m_penality,
                                                                  vc_m2m_pc_fw_exch_rate);
            if nvl(vn_m2m_penality, 0) <> 0 then
              vn_m2m_total_penality := round(vn_m2m_total_penality +
                                             (vn_m2m_penality *
                                             vn_dry_qty_in_base),
                                             cur_grd_rows.base_cur_decimal);
            
              if vc_pc_exch_rate_string is not null then
                vc_m2m_total_pc_fw_exch_rate := vc_m2m_pc_fw_exch_rate;
              else
                if instr(vc_total_pc_exch_rate_string,
                         vc_m2m_pc_fw_exch_rate) = 0 then
                  vc_m2m_total_pc_fw_exch_rate := vc_total_pc_exch_rate_string || ',' ||
                                                  vc_m2m_pc_fw_exch_rate;
                end if;
              end if;
            else
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
             cur_grd_rows.conc_product_name || ',' || cur_grd_rows.conc_quality_name || ',' ||
             cc.attribute_name || ',' || cur_grd_rows.shipment_month || '-' ||
             cur_grd_rows.shipment_year || '-' || cur_grd_rows.valuation_point,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             pd_trade_date);
            end if;
          
          end loop;
        
        end if;
      
        vn_ele_m2m_total_amount := vn_ele_m2m_amount_in_base -
                                   vn_ele_m2m_treatment_charge -
                                   vn_ele_m2m_refine_charge;
        if vn_ele_qty_in_base <> 0 then
          vn_ele_m2m_amt_per_unit := round(vn_ele_m2m_total_amount /
                                           vn_ele_qty_in_base,
                                           cur_grd_rows.base_cur_decimal);
        else
          vn_ele_m2m_amt_per_unit := 0;
        end if;
      
        pkg_general.sp_get_main_cur_detail(nvl(vc_cont_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
      
        if nvl(vn_cont_price, 0) <> 0 and
           vc_cont_price_wt_unit_id is not null then
        
          vn_contract_value_in_price_cur := (vn_cont_price /
                                            nvl(vn_cont_price_wt, 1)) *
                                            (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                                  cur_grd_rows.payable_qty_unit_id,
                                                                                  vc_cont_price_wt_unit_id,
                                                                                  cur_grd_rows.payable_qty)) *
                                            vn_cont_price_cur_id_factor;
        else
          vn_contract_value_in_price_cur := 0;
        end if;
      
        if vc_price_cur_id <> cur_grd_rows.base_cur_id then
          pkg_general.sp_bank_fx_rate(cur_grd_rows.corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      vc_price_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_sntt_conc Price to Base Currency',
                                      pc_process,
                                      vn_fx_price_to_base,
                                      vn_fx_price_deviation);
        else
          vn_fx_price_to_base := 1;
        end if;
      
        if vc_price_cur_code <> cur_grd_rows.base_cur_code then
          if vn_fx_price_to_base <> 1 then
            vc_price_to_base_fw_rate := '1 ' || vc_price_cur_code || '=' ||
                                        vn_fx_price_to_base || ' ' ||
                                        cur_grd_rows.base_cur_code;
          end if;
        end if;
        vn_contract_value_in_price_cur := round(vn_contract_value_in_price_cur,
                                                vn_cont_price_cur_decimals);
      
        vn_contract_value_in_val_cur  := round((vn_contract_value_in_price_cur *
                                               nvl(vn_fx_price_to_base, 1)),
                                               cur_grd_rows.base_cur_decimal);
        vn_contract_value_in_base_cur := vn_contract_value_in_val_cur;
        --
        -- contract treatment charges
        --
        pkg_metals_general.sp_get_treatment_charge(cur_grd_rows.internal_contract_item_ref_no,
                                                   cur_grd_rows.element_id,
                                                   pc_dbd_id,
                                                   vn_dry_qty,
                                                   vn_wet_qty,
                                                   cur_grd_rows.qty_unit_id,
                                                   cur_grd_rows.contract_price,
                                                   cur_grd_rows.price_unit_id,
                                                   vn_con_treatment_charge,
                                                   vc_con_treatment_cur_id);
      
        -- Converted treatment charges to base currency
        if vc_con_treatment_cur_id <> cur_grd_rows.base_cur_id then
          -- Bank FX Rate from TC to Base Currency
          pkg_general.sp_get_base_cur_detail(vc_con_treatment_cur_id,
                                             vc_con_tc_main_cur_id,
                                             vc_con_tc_main_cur_code,
                                             vc_con_tc_main_cur_factor);
        
          pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      vc_con_tc_main_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_sntt_conc Contract TC to Base Currency',
                                      pc_process,
                                      vn_con_tc_to_base_fw_rate,
                                      vn_forward_points);
        
          vn_base_con_treatment_charge := round((vn_con_treatment_charge *
                                                vn_con_tc_to_base_fw_rate *
                                                vc_con_tc_main_cur_factor),
                                                cur_grd_rows.base_cur_decimal);
          vc_contract_tc_fw_exch_rate  := '1 ' || vc_con_tc_main_cur_code || '=' ||
                                          vn_con_tc_to_base_fw_rate || ' ' ||
                                          cur_grd_rows.base_cur_code;
        else
          vn_base_con_treatment_charge := round(vn_con_treatment_charge,
                                                cur_grd_rows.base_cur_decimal);
        
        end if;
      
        --
        --- contract refine chrges
        --
        pkg_metals_general.sp_get_refine_charge(cur_grd_rows.internal_contract_item_ref_no,
                                                cur_grd_rows.element_id,
                                                pc_dbd_id,
                                                cur_grd_rows.payable_qty,
                                                cur_grd_rows.payable_qty_unit_id,
                                                cur_grd_rows.contract_price,
                                                cur_grd_rows.price_unit_id,
                                                vn_con_refine_charge,
                                                vc_con_refine_cur_id);
        --- Converted refine charges to base currency                                              
        if vc_con_refine_cur_id <> cur_grd_rows.base_cur_id then
          pkg_general.sp_get_base_cur_detail(vc_con_refine_cur_id,
                                             vc_con_rc_main_cur_id,
                                             vc_con_rc_main_cur_code,
                                             vc_con_rc_main_cur_factor);
        
          pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      vc_con_refine_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_sntt_conc Contract RC to Base Currency',
                                      pc_process,
                                      vn_con_rc_to_base_fw_rate,
                                      vn_forward_points);
        
          vn_base_con_refine_charge := round((vn_con_refine_charge *
                                             vn_con_rc_to_base_fw_rate *
                                             vc_con_rc_main_cur_factor),
                                             cur_grd_rows.base_cur_decimal);
        
          vc_contract_rc_fw_exch_rate := '1 ' || vc_con_rc_main_cur_code || '=' ||
                                         vn_con_rc_to_base_fw_rate || ' ' ||
                                         cur_grd_rows.base_cur_code;
        
        else
          vn_base_con_refine_charge := round(vn_con_refine_charge,
                                             cur_grd_rows.base_cur_decimal);
        end if;
      
      end if;
    
      insert into psue_element_details
        (corporate_id,
         process_id,
         internal_contract_item_ref_no,
         psu_id,
         internal_gmr_ref_no,
         element_id,
         element_name,
         assay_header_id,
         assay_qty,
         assay_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         payable_qty_unit,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         md_id,
         m2m_price,
         m2m_price_cur_id,
         m2m_price_cur_code,
         m2m_price_weight_unit_id,
         m2m_price_weight_unit,
         m2m_price_weight_unit_weight,
         m2m_refining_charge,
         m2m_treatment_charge,
         pricing_details,
         m2m_price_unit_id,
         m2m_price_unit_str,
         m2m_amt,
         m2m_amt_cur_id,
         m2m_amt_cur_code,
         contract_value_in_price_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         material_cost_in_base_cur,
         element_qty_in_base_unit,
         total_m2m_amount,
         m2m_amt_per_unit,
         price_cur_to_base_cur_fx_rate,
         m2m_cur_to_base_cur_fx_rate,
         base_price_unit_id_in_ppu,
         base_price_unit_id_in_pum,
         valuation_against_underlying,
         internal_grd_dgrd_ref_no,
         price_to_base_fw_exch_rate,
         m2m_to_base_fw_exch_rate,
         m2m_rc_fw_exch_rate,
         m2m_tc_fw_exch_rate,
         m2m_ld_fw_exch_rate,
         contract_rc_in_base_cur,
         contract_tc_in_base_cur,
         contract_rc_fw_exch_rate,
         contract_tc_fw_exch_rate)
      values
        (cur_grd_rows.corporate_id,
         pc_process_id,
         cur_grd_rows.internal_contract_item_ref_no,
         vc_psu_id,
         cur_grd_rows.internal_gmr_ref_no,
         cur_grd_rows.element_id,
         cur_grd_rows.attribute_name,
         cur_grd_rows.assay_header_id,
         cur_grd_rows.assay_qty,
         cur_grd_rows.assay_qty_unit_id,
         cur_grd_rows.payable_qty,
         cur_grd_rows.payable_qty_unit_id,
         cur_grd_rows.payable_qty_unit,
         vn_cont_price,
         vc_cont_price_unit_id,
         vc_cont_price_unit_cur_id,
         vc_cont_price_unit_cur_code,
         vc_cont_price_wt_unit_id,
         vn_cont_price_wt,
         vc_cont_price_wt_unit,
         cur_grd_rows.md_id,
         cur_grd_rows.net_m2m_price,
         cur_grd_rows.m2m_price_unit_cur_id,
         cur_grd_rows.m2m_price_unit_cur_code,
         cur_grd_rows.m2m_price_unit_weight_unit_id,
         cur_grd_rows.m2m_price_unit_weight_unit,
         decode(cur_grd_rows.m2m_price_unit_weight,
                1,
                null,
                cur_grd_rows.m2m_price_unit_weight),
         vn_ele_m2m_refine_charge,
         vn_ele_m2m_treatment_charge,
         cur_grd_rows.price_description,
         cur_grd_rows.m2m_price_unit_id,
         cur_grd_rows.m2m_price_unit_str,
         vn_m2m_amt, --m2m_amt
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         vn_ele_qty_in_base,
         vn_ele_m2m_total_amount, --total_m2m_amount,
         vn_ele_m2m_amt_per_unit, --m2m_amt_per_unit,
         vn_fx_price_to_base, --price_cur_to_base_cur_fx_rate,   
         vn_m2m_base_fx_rate, --m2m_cur_to_base_cur_fx_rate,
         cur_grd_rows.base_price_unit_id_in_ppu, --base_price_unit_id_in_ppu,
         cur_grd_rows.base_price_unit_id_in_pum, --base_price_unit_id_in_pum)*/
         cur_grd_rows.valuation_against_underlying,
         cur_grd_rows.internal_grd_dgrd_ref_no,
         vc_price_to_base_fw_rate,
         vc_m2m_to_base_fw_rate,
         cur_grd_rows.m2m_rc_fw_exch_rate,
         cur_grd_rows.m2m_tc_fw_exch_rate,
         cur_grd_rows.m2m_ld_fw_exch_rate,
         vn_base_con_refine_charge,
         vn_base_con_treatment_charge,
         vc_contract_rc_fw_exch_rate,
         vc_contract_tc_fw_exch_rate);
    
      if cur_grd_rows.ele_rank = 1 then
        vn_sc_in_base_cur := vn_qty_in_base * cur_grd_rows.sc_in_base_cur;
      
        if cur_grd_rows.ele_rank = 1 then
        
          vn_cont_delivery_premium := 0;
          vn_cont_del_premium_amt  := 0;
        
          if cur_grd_rows.delivery_premium <> 0 then
            if cur_grd_rows.delivery_premium_unit_id <>
               vc_base_price_unit_id then
            
              vc_error_msg := '11';
              --
              -- Get the Delivery Premium Currency 
              --
              select ppu.cur_id,
                     cm.cur_code,
                     nvl(ppu.weight, 1),
                     ppu.weight_unit_id
                into vc_del_premium_cur_id,
                     vc_del_premium_cur_code,
                     vn_del_premium_weight,
                     vc_del_premium_weight_unit_id
                from v_ppu_pum          ppu,
                     cm_currency_master cm
               where ppu.product_price_unit_id =
                     cur_grd_rows.delivery_premium_unit_id
                 and cm.cur_id = ppu.cur_id;
              --
              -- Get the Main Currency of the Delivery Premium Price Unit
              --
              vc_error_msg := '12';
              pkg_general.sp_get_base_cur_detail(vc_del_premium_cur_id,
                                                 vc_del_premium_main_cur_id,
                                                 vc_del_premium_main_cur_code,
                                                 vn_del_premium_cur_main_factor);
            
              pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                          pd_trade_date,
                                          cur_grd_rows.payment_due_date,
                                          vc_del_premium_main_cur_id,
                                          cur_grd_rows.base_cur_id,
                                          30,
                                          'sp_stock_unreal_sntt_con Delivery to Base',
                                          pc_process,
                                          vn_del_to_base_fw_rate,
                                          vn_forward_points);
              vc_error_msg := '13';
            
              vn_cont_delivery_premium := (cur_grd_rows.delivery_premium /
                                          vn_del_premium_weight) *
                                          vn_del_premium_cur_main_factor *
                                          vn_del_to_base_fw_rate *
                                          pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                               vc_del_premium_weight_unit_id,
                                                                               cur_grd_rows.conc_base_qty_unit_id,
                                                                               1);
              vc_error_msg             := '14';
              if cur_grd_rows.base_cur_code <> vc_del_premium_main_cur_code then
                vc_contract_pp_fw_exch_rate := '1 ' ||
                                               vc_del_premium_main_cur_code || '=' ||
                                               vn_del_to_base_fw_rate || ' ' ||
                                               cur_grd_rows.base_cur_code;
              end if;
            
              if cur_grd_rows.base_cur_code <> vc_del_premium_main_cur_code then
                if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
                  vobj_error_log.extend;
                  vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                       'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                       'PHY-005',
                                                                       cur_grd_rows.base_cur_code ||
                                                                       ' to ' ||
                                                                       vc_del_premium_main_cur_code || ' (' ||
                                                                       to_char(cur_grd_rows.payment_due_date,
                                                                               'dd-Mon-yyyy') || ') ',
                                                                       '',
                                                                       pc_process,
                                                                       pc_user_id,
                                                                       sysdate,
                                                                       pd_trade_date);
                  sp_insert_error_log(vobj_error_log);
                end if;
              end if;
            else
              vn_cont_delivery_premium := cur_grd_rows.delivery_premium;
            end if;
            vn_cont_del_premium_amt := round(vn_cont_delivery_premium *
                                             vn_qty_in_base,
                                             2);
          else
            vn_cont_delivery_premium := 0;
            vn_cont_del_premium_amt  := 0;
          end if;
        
        end if;
      
        insert into psue_phy_stock_unrealized_ele
          (process_id,
           psu_id,
           corporate_id,
           corporate_name,
           internal_gmr_ref_no,
           internal_contract_item_ref_no,
           contract_ref_no,
           delivery_item_no,
           del_distribution_item_no,
           product_id,
           product_name,
           origin_id,
           origin_name,
           quality_id,
           quality_name,
           container_no,
           stock_wet_qty,
           stock_dry_qty,
           qty_unit_id,
           qty_unit,
           qty_in_base_unit,
           no_of_units,
           prod_base_qty_unit_id,
           prod_base_qty_unit,
           inventory_status,
           shipment_status,
           section_name,
           strategy_id,
           strategy_name,
           valuation_month,
           contract_type,
           profit_center_id,
           profit_center_name,
           profit_center_short_name,
           valuation_exchange_id,
           derivative_def_id,
           gmr_contract_type,
           is_voyage_gmr,
           gmr_ref_no,
           warehouse_id,
           warehouse_name,
           shed_id,
           shed_name,
           int_alloc_group_id,
           internal_grd_dgrd_ref_no,
           price_type_id,
           fixation_method,
           price_fixation_details,
           stock_ref_no,
           trader_name,
           trader_id,
           contract_qty_string,
           contract_price_string,
           m2m_price_string,
           m2m_rc_tc_string,
           m2m_penalty_charge,
           m2m_treatment_charge,
           m2m_refining_charge,
           m2m_loc_diff_premium,
           net_contract_value_in_base_cur,
           net_m2m_amount_in_base_cur,
           prev_net_m2m_amt_in_base_cur,
           pnl_type,
           pnl_in_base_cur,
           pnl_in_per_base_unit,
           prev_day_pnl_in_base_cur,
           prev_day_pnl_per_base_unit,
           trade_day_pnl_in_base_cur,
           trade_day_pnl_per_base_unit,
           cont_unr_status,
           prev_m2m_price_string,
           prev_m2m_rc_tc_string,
           prev_m2m_penalty_charge,
           prev_m2m_treatment_charge,
           prev_m2m_refining_charge,
           prev_m2m_loc_diff_premium,
           base_price_unit_id,
           base_price_unit_name,
           base_cur_id,
           base_cur_code,
           valuation_against_underlying,
           price_to_base_fw_exch_rate,
           m2m_to_base_fw_exch_rate,
           contract_pc_in_base_cur,
           sc_in_base_cur,
           accrual_to_base_fw_exch_rate,
           incoterm_id,
           incoterm,
           cp_id,
           cp_name,
           delivery_month,
           location_premium_per_unit,
           location_premium,
           location_premium_fw_exch_rate,
           contract_pc_fw_exch_rate)
        values
          (pc_process_id,
           vc_psu_id,
           cur_grd_rows.corporate_id,
           cur_grd_rows.corporate_name,
           cur_grd_rows.internal_gmr_ref_no,
           cur_grd_rows.internal_contract_item_ref_no,
           cur_grd_rows.contract_ref_no,
           cur_grd_rows.delivery_item_no,
           cur_grd_rows.del_distribution_item_no,
           cur_grd_rows.conc_product_id,
           cur_grd_rows.conc_product_name,
           cur_grd_rows.origin_id,
           cur_grd_rows.origin_name,
           cur_grd_rows.conc_quality_id,
           cur_grd_rows.conc_quality_name,
           cur_grd_rows.container_no,
           vn_wet_qty,
           vn_dry_qty,
           cur_grd_rows.qty_unit_id,
           cur_grd_rows.qty_unit,
           vn_qty_in_base,
           cur_grd_rows.no_of_units,
           null, --prod_base_qty_unit_id
           null, --prod_base_qty_unit
           cur_grd_rows.inventory_status,
           cur_grd_rows.shipment_status,
           cur_grd_rows.section_name,
           cur_grd_rows.strategy_id,
           cur_grd_rows.strategy_name,
           cur_grd_rows.valuation_month,
           cur_grd_rows.purchase_sales,
           cur_grd_rows.profit_center,
           cur_grd_rows.profit_center_name,
           cur_grd_rows.profit_center_short_name,
           cur_grd_rows.valuation_exchange_id,
           cur_grd_rows.derivative_def_id,
           cur_grd_rows.gmr_contract_type,
           cur_grd_rows.is_voyage_gmr,
           null, --gmr_ref_no
           null, --warehouse_id,
           null, --warehouse_name,
           null, --shed_id,
           null, --shed_name
           cur_grd_rows.int_alloc_group_id,
           cur_grd_rows.internal_grd_dgrd_ref_no,
           cur_grd_rows.price_basis,
           vc_price_fixation_status,
           cur_grd_rows.price_fixation_details,
           cur_grd_rows.stock_ref_no,
           cur_grd_rows.trader_user_name,
           cur_grd_rows.trader_id,
           null, --contract_qty_string,
           null, --contract_price_string,  
           null, --m2m_price_string,   
           null, --m2m_rc_tc_string,
           vn_m2m_total_penality, --m2m_penalty_charge,--Not sure why this is pushed here
           null, --m2m_treatment_charge,
           null, --m2m_refining_charge,
           vn_loc_total_amount, --m2m_loc_diff_premium,
           null, --net_contract_value_in_base_cur, 
           null, --net_m2m_amount_in_base_cur,
           null, --prev_net_m2m_amt_in_base_cur,
           'Unrealized',
           null, -- pnl_in_base_cur,
           null, -- pnl_in_per_base_unit,
           null, -- prev_day_pnl_in_base_cur,
           null, -- prev_day_pnl_per_base_unit,
           null, --trade_day_pnl_in_base_cur,
           null, --trade_day_pnl_per_base_unit,
           null, --cont_unr_status,
           null, --prev_m2m_price_string,    
           null, --prev_m2m_rc_tc_string,
           null, --prev_m2m_penalty_charge, 
           null, --prev_m2m_treatment_charge, 
           null, --prev_m2m_refining_charge, 
           null, --prev_m2m_loc_diff_premium,
           cur_grd_rows.base_price_unit_id_in_ppu,
           cur_grd_rows.base_price_unit_name,
           cur_grd_rows.base_cur_id,
           cur_grd_rows.base_cur_code,
           cur_grd_rows.valuation_against_underlying,
           vc_price_to_base_fw_rate,
           vc_m2m_to_base_fw_rate,
           vn_base_con_penality_charge,
           vn_sc_in_base_cur,
           cur_grd_rows.accrual_to_base_fw_rate,
           cur_grd_rows.incoterm_id,
           cur_grd_rows.incoterm,
           cur_grd_rows.cp_id,
           cur_grd_rows.cp_name,
           cur_grd_rows.delivery_month,
           vn_cont_delivery_premium,
           vn_cont_del_premium_amt,
           vc_contract_pp_fw_exch_rate,
           vc_contract_pc_fw_exch_rate);
      end if;
    end loop;
  
    for cur_update_pnl in (select psue.psu_id,
                                  sum(psue.material_cost_in_base_cur) net_contract_value_in_base_cur,
                                  sum(psue.m2m_amt) net_m2m_amt,
                                  sum(psue.m2m_treatment_charge) net_m2m_treatment_charge,
                                  sum(psue.m2m_refining_charge) net_m2m_refining_charge,
                                  stragg(psue.element_name || '-' ||
                                         psue.payable_qty || ' ' ||
                                         psue.payable_qty_unit) contract_qty_string,
                                  stragg(psue.element_name || '-' ||
                                         psue.contract_price || ' ' ||
                                         psue.price_unit_cur_code || '/' ||
                                         psue.price_unit_weight ||
                                         psue.price_unit_weight_unit) contract_price_string,
                                  (case
                                     when psue.valuation_against_underlying = 'N' then
                                      max((case
                                     when nvl(psue.m2m_price, 0) <> 0 then
                                      (psue.m2m_price || ' ' ||
                                      psue.m2m_price_cur_code || '/' ||
                                      psue.m2m_price_weight_unit_weight ||
                                      psue.m2m_price_weight_unit)
                                     else
                                      null
                                   end)) else stragg((case
                                    when nvl(psue.m2m_price,
                                             0) <> 0 then
                                     (psue.element_name || '-' ||
                                     psue.m2m_price || ' ' ||
                                     psue.m2m_price_cur_code || '/' ||
                                     psue.m2m_price_weight_unit_weight ||
                                     psue.m2m_price_weight_unit)
                                    else
                                     null
                                  end)) end) m2m_price_string, -- TODO if underly valuation = n, show the concentrate price
                                  stragg('TC:' || psue.element_name || '-' ||
                                         psue.m2m_treatment_charge || ' ' ||
                                         
                                         psue.price_unit_cur_code || ' ' ||
                                         'RC:' || psue.element_name || '-' ||
                                         psue.m2m_refining_charge || ' ' ||
                                         psue.price_unit_cur_code) m2m_rc_tc_pen_string,
                                  stragg(psue.contract_rc_fw_exch_rate) contract_rc_fw_exch_rate,
                                  stragg(psue.contract_tc_fw_exch_rate) contract_tc_fw_exch_rate,
                                  stragg(psue.pricing_details) pricing_details
                             from psue_element_details          psue,
                                  psue_phy_stock_unrealized_ele psueh
                            where psue.corporate_id = pc_corporate_id
                              and psue.process_id = pc_process_id
                              and psueh.process_id = pc_process_id
                              and psueh.psu_id = psue.psu_id
                              and psueh.section_name in
                                  ('Shipped NTT', 'Stock NTT')
                            group by psue.psu_id,
                                     psue.valuation_against_underlying)
    loop
    
      update psue_phy_stock_unrealized_ele psuee
         set psuee.net_contract_value_in_base_cur = cur_update_pnl.
                                                    net_contract_value_in_base_cur,
             psuee.net_m2m_amount                 = cur_update_pnl.net_m2m_amt,
             psuee.m2m_treatment_charge           = cur_update_pnl.net_m2m_treatment_charge,
             psuee.m2m_refining_charge            = cur_update_pnl.net_m2m_refining_charge,
             psuee.contract_price_string          = cur_update_pnl.contract_price_string,
             psuee.m2m_price_string               = cur_update_pnl.m2m_price_string,
             psuee.m2m_rc_tc_string               = cur_update_pnl.m2m_rc_tc_pen_string,
             psuee.contract_qty_string            = cur_update_pnl.contract_qty_string,
             psuee.contract_rc_fw_exch_rate       = cur_update_pnl.contract_rc_fw_exch_rate,
             psuee.contract_tc_fw_exch_rate       = cur_update_pnl.contract_tc_fw_exch_rate,
             psuee.price_description              = cur_update_pnl.pricing_details
       where psuee.psu_id = cur_update_pnl.psu_id
         and psuee.process_id = pc_process_id
         and psuee.corporate_id = pc_corporate_id
         and psuee.section_name in ('Shipped NTT', 'Stock NTT');
    end loop;
  
    -- Update Contract TC/RC/Material Cost in Header
  
    update psue_phy_stock_unrealized_ele psue
       set (psue.contract_rc_in_base_cur, psue.contract_tc_in_base_cur, psue.material_cost_in_base_cur) = --
            (select sum(psued.contract_rc_in_base_cur),
                    sum(psued.contract_tc_in_base_cur),
                    sum(psued.material_cost_in_base_cur)
               from psue_element_details psued
              where psued.process_id = pc_process_id
                and psue.psu_id = psued.psu_id
              group by psued.psu_id)
     where psue.process_id = pc_process_id
       and psue.section_name in ('Shipped NTT', 'Stock NTT');
    -- Update TC/RC/PC String    
    update psue_phy_stock_unrealized_ele psu
       set psu.contract_rc_tc_pen_string = (select stragg('TC:' ||
                                                          poude.element_name || '-' ||
                                                          poude.contract_tc_in_base_cur || ' ' ||
                                                          psu.base_cur_code || '  ' ||
                                                          'RC:' ||
                                                          poude.element_name || '-' ||
                                                          poude.contract_rc_in_base_cur || ' ' ||
                                                          psu.base_cur_code) contract_rc_tc_pen_string
                                              from psue_element_details poude
                                             where poude.process_id =
                                                   pc_process_id
                                               and psu.process_id =
                                                   pc_process_id
                                               and psu.internal_grd_dgrd_ref_no =
                                                   poude.internal_grd_dgrd_ref_no
                                               and psu.internal_contract_item_ref_no =
                                                   poude.internal_contract_item_ref_no
                                             group by psu.internal_contract_item_ref_no,
                                                      psu.internal_grd_dgrd_ref_no)
     where psu.process_id = pc_process_id
       and psu.section_name in ('Shipped NTT', 'Stock NTT');
  
    update psue_phy_stock_unrealized_ele psuee
       set psuee.net_m2m_amount_in_base_cur = (psuee.net_m2m_amount -
                                              psuee.m2m_treatment_charge -
                                              psuee.m2m_refining_charge -
                                              psuee.m2m_penalty_charge +
                                              psuee.m2m_loc_diff_premium)
     where psuee.corporate_id = pc_corporate_id
       and psuee.process_id = pc_process_id
       and psuee.section_name in ('Shipped NTT', 'Stock NTT');
    --- previous EOD Data
    for cur_update in (select psue_prev_day.net_m2m_amount_in_base_cur,
                              psue_prev_day.net_m2m_amount,
                              psue_prev_day.pnl_in_per_base_unit,
                              psue_prev_day.m2m_price_string,
                              psue_prev_day.m2m_rc_tc_string,
                              psue_prev_day.m2m_penalty_charge,
                              psue_prev_day.m2m_treatment_charge,
                              psue_prev_day.m2m_refining_charge,
                              psue_prev_day.m2m_loc_diff_premium,
                              psue_prev_day.qty_in_base_unit,
                              psue_prev_day.psu_id,
                              psue_prev_day.m_pnl_in_per_base_unit
                         from psue_phy_stock_unrealized_ele psue_prev_day
                        where process_id = pc_previous_process_id
                          and corporate_id = pc_corporate_id
                          and psue_prev_day.section_name in
                              ('Shipped NTT', 'Stock NTT'))
    loop
      update psue_phy_stock_unrealized_ele psue_today
         set psue_today.prev_net_m2m_amt_in_base_cur = cur_update.net_m2m_amount_in_base_cur,
             psue_today.m_prev_day_pnl_in_base_cur   = cur_update.m_pnl_in_per_base_unit *
                                                       psue_today.qty_in_base_unit,
             psue_today.prev_net_m2m_amount          = cur_update.net_m2m_amount,
             psue_today.prev_day_pnl_per_base_unit   = cur_update.pnl_in_per_base_unit,
             psue_today.prev_day_pnl_in_base_cur     = psue_today.qty_in_base_unit *
                                                       cur_update.pnl_in_per_base_unit, --added
             psue_today.prev_m2m_price_string        = cur_update.m2m_price_string,
             psue_today.prev_m2m_rc_tc_string        = cur_update.m2m_rc_tc_string,
             psue_today.prev_m2m_penalty_charge      = cur_update.m2m_penalty_charge,
             psue_today.prev_m2m_treatment_charge    = cur_update.m2m_treatment_charge,
             psue_today.prev_m2m_refining_charge     = cur_update.m2m_refining_charge,
             psue_today.prev_m2m_loc_diff_premium    = cur_update.m2m_loc_diff_premium,
             psue_today.cont_unr_status              = 'EXISTING_TRADE'
       where psue_today.process_id = pc_process_id
         and psue_today.corporate_id = pc_corporate_id
         and psue_today.psu_id = cur_update.psu_id
         and psue_today.section_name in ('Shipped NTT', 'Stock NTT');
    end loop;
  
    begin
      update psue_phy_stock_unrealized_ele psue
         set psue.prev_net_m2m_amt_in_base_cur = psue.net_m2m_amount_in_base_cur,
             psue.prev_day_pnl_in_base_cur     = 0,
             psue.prev_day_pnl_per_base_unit   = 0,
             psue.m_prev_day_pnl_in_base_cur   = 0,
             psue.m_prev_day_pnl_per_base_unit = 0,
             psue.prev_net_m2m_amount          = psue.net_m2m_amount,
             psue.prev_m2m_price_string        = psue.m2m_price_string,
             psue.prev_m2m_rc_tc_string        = psue.m2m_rc_tc_string,
             psue.prev_m2m_penalty_charge      = psue.m2m_penalty_charge,
             psue.prev_m2m_treatment_charge    = psue.m2m_treatment_charge,
             psue.prev_m2m_refining_charge     = psue.m2m_refining_charge,
             psue.prev_m2m_loc_diff_premium    = psue.m2m_loc_diff_premium,
             psue.cont_unr_status              = 'NEW_TRADE'
       where psue.cont_unr_status is null
         and psue.process_id = pc_process_id
         and psue.corporate_id = pc_corporate_id
         and psue.section_name in ('Shipped NTT', 'Stock NTT');
    end;
  
    update psue_phy_stock_unrealized_ele psue
       set psue.m_pnl_in_base_cur      = psue.net_m2m_amount_in_base_cur -
                                         psue.prev_net_m2m_amt_in_base_cur,
           psue.m_pnl_in_per_base_unit = (psue.net_m2m_amount_in_base_cur -
                                         psue.prev_net_m2m_amt_in_base_cur) /
                                         psue.qty_in_base_unit
     where psue.process_id = pc_process_id
       and psue.corporate_id = pc_corporate_id
       and psue.section_name in ('Shipped NTT', 'Stock NTT');
    -- Calculate PNL in Base Currency = MC - TC - RC - PC + SC ( +- M2M)
    update psue_phy_stock_unrealized_ele psue
       set psue.pnl_in_base_cur      = case when psue.contract_type = 'P' then psue.net_m2m_amount_in_base_cur - (psue.material_cost_in_base_cur + psue.location_premium - psue.contract_tc_in_base_cur - psue.contract_rc_in_base_cur - psue.contract_pc_in_base_cur + psue.sc_in_base_cur) else(psue.material_cost_in_base_cur - psue.contract_tc_in_base_cur - psue.contract_rc_in_base_cur - psue.contract_pc_in_base_cur + psue.sc_in_base_cur + psue.location_premium) - psue.net_m2m_amount_in_base_cur end,
           psue.pnl_in_per_base_unit = (case when psue.contract_type = 'P' then psue.net_m2m_amount_in_base_cur - (psue.material_cost_in_base_cur - psue.contract_tc_in_base_cur - psue.contract_rc_in_base_cur - psue.contract_pc_in_base_cur + psue.sc_in_base_cur + psue.location_premium) else(psue.material_cost_in_base_cur + psue.location_premium - psue.contract_tc_in_base_cur - psue.contract_rc_in_base_cur - psue.contract_pc_in_base_cur + psue.sc_in_base_cur) - psue.net_m2m_amount_in_base_cur end) / psue.qty_in_base_unit
     where psue.process_id = pc_process_id
       and psue.corporate_id = pc_corporate_id
       and psue.section_name in ('Shipped NTT', 'Stock NTT');
    update psue_phy_stock_unrealized_ele psue
       set m_trade_day_pnl_in_base_cur   = nvl(psue.m_pnl_in_base_cur, 0) -
                                           nvl(psue.m_prev_day_pnl_in_base_cur,
                                               0),
           trade_day_pnl_in_base_cur     = nvl(psue.pnl_in_base_cur, 0) -
                                           nvl(psue.prev_day_pnl_in_base_cur,
                                               0),
           m_trade_day_pnl_per_base_unit = (nvl(psue.m_pnl_in_base_cur, 0) -
                                           nvl(psue.m_prev_day_pnl_in_base_cur,
                                                0)) / psue.qty_in_base_unit,
           trade_day_pnl_per_base_unit   = (nvl(psue.pnl_in_base_cur, 0) -
                                           nvl(psue.prev_day_pnl_in_base_cur,
                                                0)) / psue.qty_in_base_unit
    
     where psue.process_id = pc_process_id
       and psue.corporate_id = pc_corporate_id
       and psue.section_name in ('Shipped NTT', 'Stock NTT');
  
    update psue_phy_stock_unrealized_ele psue
       set (gmr_ref_no, warehouse_id, warehouse_name, shed_id, shed_name, prod_base_qty_unit_id, prod_base_qty_unit) = --
            (select gmr.gmr_ref_no,
                    gmr.warehouse_profile_id,
                    phd_gmr.companyname as warehouse_profile_name,
                    gmr.shed_id,
                    sld.storage_location_name,
                    pdm.base_quantity_unit,
                    qum.qty_unit
               from gmr_goods_movement_record   gmr,
                    pdm_productmaster           pdm,
                    phd_profileheaderdetails    phd_gmr,
                    sld_storage_location_detail sld,
                    qum_quantity_unit_master    qum
              where gmr.internal_gmr_ref_no = psue.internal_gmr_ref_no
                and psue.product_id = pdm.product_id
                and pdm.base_quantity_unit = qum.qty_unit_id
                and gmr.warehouse_profile_id = phd_gmr.profileid(+)
                and gmr.shed_id = sld.storage_loc_id(+)
                and psue.process_id = gmr.process_id
                and psue.process_id = pc_process_id)
     where psue.process_id = pc_process_id
       and psue.section_name in ('Shipped NTT', 'Stock NTT');
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_stock_unreal_sntt_conc ',
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
  procedure sp_stock_unreal_inv_in_conc(pc_corporate_id        varchar2,
                                        pd_trade_date          date,
                                        pc_process_id          varchar2,
                                        pc_user_id             varchar2,
                                        pc_process             varchar2,
                                        pc_previous_process_id varchar2,
                                        pc_dbd_id              varchar2) is
  
    cursor cur_grd is
      select tt.section_type,
             tt.profit_center,
             tt.profit_center_name,
             tt.profit_center_short_name,
             tt.process_id,
             tt.corporate_id,
             tt.corporate_name,
             tt.internal_gmr_ref_no,
             tt.internal_contract_item_ref_no,
             tt.del_distribution_item_no,
             tt.delivery_item_no,
             tt.contract_ref_no,
             tt.purchase_sales,
             tt.conc_product_id,
             tt.conc_product_name,
             tt.product_id,
             tt.product_name,
             tt.origin_id,
             tt.origin_name,
             tt.conc_quality_id,
             tt.conc_quality_name,
             tt.quality_id,
             tt.quality_name,
             tt.container_no,
             tt.stock_qty,
             tt.qty_unit_id,
             tt.gmr_qty_unit_id,
             tt.qty_unit,
             tt.stocky_qty_decimal,
             tt.no_of_units,
             tt.md_id,
             tt.m2m_price_unit_id,
             tt.net_m2m_price,
             tt.m2m_price_unit_cur_id,
             tt.m2m_price_unit_cur_code,
             tt.m2m_price_unit_weight_unit_id,
             tt.m2m_price_unit_weight_unit,
             tt.m2m_price_unit_weight,
             tt.m2m_price_unit_str,
             tt.m2m_main_cur_id,
             tt.m2m_main_cur_code,
             tt.m2m_main_cur_decimals,
             tt.main_currency_factor,
             tt.settlement_cur_id,
             tt.settlement_to_val_fx_rate,
             tt.element_id,
             tt.attribute_name,
             tt.assay_header_id,
             tt.assay_qty,
             tt.assay_qty_unit_id,
             tt.payable_qty,
             tt.payable_qty_unit_id,
             tt.payable_qty_unit,
             tt.contract_price,
             tt.price_unit_id,
             tt.price_unit_weight_unit_id,
             tt.price_unit_weight,
             tt.price_unit_cur_id,
             tt.price_unit_cur_code,
             tt.price_unit_weight_unit,
             tt.price_fixation_details,
             tt.price_description,
             tt.payment_due_date,
             tt.base_cur_id,
             tt.base_cur_code,
             tt.base_cur_decimal,
             tt.inventory_status,
             tt.shipment_status,
             tt.section_name,
             tt.shed_id,
             tt.destination_city_id,
             tt.price_fixation_status,
             tt.base_qty_unit_id,
             tt.conc_base_qty_unit_id,
             tt.base_qty_decimal,
             tt.strategy_id,
             tt.strategy_name,
             tt.valuation_exchange_id,
             tt.valuation_month,
             tt.derivative_def_id,
             tt.is_voyage_gmr,
             tt.gmr_contract_type,
             tt.internal_grd_dgrd_ref_no,
             tt.stock_ref_no,
             tt.trader_id,
             tt.trader_user_name,
             tt.m2m_loc_incoterm_deviation,
             tt.m2m_treatment_charge,
             tt.m2m_refine_charge,
             tt.m2m_tc_price_unit_id,
             tt.m2m_tc_price_unit_name,
             tt.m2m_tc_cur_id,
             tt.m2m_tc_weight,
             tt.m2m_tc_weight_unit_id,
             tt.m2m_rc_price_unit_id,
             tt.m2m_rc_price_unit_name,
             tt.m2m_rc_cur_id,
             tt.m2m_rc_weight,
             tt.m2m_rc_weight_unit_id,
             tt.base_price_unit_id_in_ppu,
             tt.base_price_unit_id_in_pum,
             tt.eval_basis,
             dense_rank() over(partition by tt.internal_contract_item_ref_no order by tt.element_id) ele_rank,
             tt.unit_of_measure,
             tt.loc_qty_unit_id,
             tt.mvp_id,
             tt.shipment_month,
             tt.shipment_year,
             tt.valuation_point,
             tt.base_price_unit_name,
             tt.valuation_against_underlying,
             m2m_rc_fw_exch_rate,
             m2m_tc_fw_exch_rate,
             m2m_ld_fw_exch_rate,
             sc_in_base_cur,
             accrual_to_base_fw_rate,
             tt.total_sc_charges,
             tt.incoterm_id,
             tt.incoterm,
             tt.cp_id,
             tt.cp_name,
             tt.delivery_month,
             tt.mc_per_unit,
             tt.mc_price_unit_id,
             tt.mc_price_unit_name,
             tt.tc_per_unit,
             tt.tc_price_unit_id,
             tt.tc_price_unit_name,
             tt.rc_per_unit,
             tt.rc_price_unit_id,
             tt.rc_price_unit_name,
             tt.is_marked_for_consignment,
             nvl(tt.product_premium_per_unit, 0) product_premium_per_unit,
             tt.contract_pp_fw_exch_rate,
             tt.price_to_base_fw_exch_rate
        from (select 'Purchase' section_type,
                     pcpd.profit_center_id profit_center,
                     cpc.profit_center_name,
                     cpc.profit_center_short_name,
                     pc_process_id process_id,
                     gmr.corporate_id,
                     akc.corporate_name,
                     gmr.internal_gmr_ref_no,
                     grd.internal_contract_item_ref_no,
                     pci.del_distribution_item_no,
                     pcdi.delivery_item_no,
                     pcm.contract_ref_no,
                     pcm.purchase_sales,
                     pcpd.product_id conc_product_id,
                     pdm_conc.product_desc conc_product_name,
                     aml.underlying_product_id product_id,
                     pdm.product_desc product_name,
                     grd.origin_id,
                     orm.origin_name,
                     pcpq.quality_template_id conc_quality_id,
                     qat.quality_name conc_quality_name,
                     qav.comp_quality_id quality_id,
                     qat_und.quality_name,
                     grd.container_no,
                     grd.current_qty stock_qty,
                     grd.qty_unit_id,
                     gmr.qty_unit_id gmr_qty_unit_id,
                     qum.qty_unit,
                     qum.decimals stocky_qty_decimal,
                     grd.no_of_units,
                     md.md_id,
                     md.m2m_price_unit_id,
                     md.net_m2m_price,
                     md.m2m_price_unit_cur_id,
                     md.m2m_price_unit_cur_code,
                     md.m2m_price_unit_weight_unit_id,
                     md.m2m_price_unit_weight_unit,
                     nvl(md.m2m_price_unit_weight, 1) m2m_price_unit_weight,
                     md.m2m_price_unit_cur_code || '/' ||
                     decode(md.m2m_price_unit_weight,
                            1,
                            null,
                            md.m2m_price_unit_weight) ||
                     md.m2m_price_unit_weight_unit m2m_price_unit_str,
                     md.m2m_main_cur_id,
                     md.m2m_main_cur_code,
                     md.m2m_main_cur_decimals,
                     md.main_currency_factor,
                     md.settlement_cur_id,
                     md.settlement_to_val_fx_rate,
                     ceqs.element_id,
                     aml.attribute_name,
                    -- sam.ash_id assay_header_id,
                     grd.weg_avg_pricing_assay_id assay_header_id,
                     ceqs.assay_qty,
                     ceqs.assay_qty_unit_id,
                     --  added suresh                
                     (case
                       when rm.ratio_name = '%' then
                        ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                        (pqcapd.payable_percentage / 100))
                       else
                        ((grd.current_qty * (asm.dry_wet_qty_ratio / 100)) *
                        pqcapd.payable_percentage)
                     end) payable_qty,
                     (case
                       when rm.ratio_name = '%' then
                        grd.qty_unit_id
                       else
                        rm.qty_unit_id_numerator
                     end) payable_qty_unit_id,
                     gmr_qum.qty_unit payable_qty_unit,
                     ---
                     invme.mc_per_unit contract_price,
                     invme.mc_price_unit_id price_unit_id,
                     invme.mc_price_unit_weight_unit_id price_unit_weight_unit_id,
                     invme.mc_price_unit_weight price_unit_weight,
                     invme.mc_price_unit_cur_id price_unit_cur_id,
                     invme.mc_price_unit_cur_code price_unit_cur_code,
                     invme.mc_price_unit_weight_unit price_unit_weight_unit,
                     null price_fixation_details,
                     null price_description,
                     pd_trade_date payment_due_date,
                     akc.base_cur_id as base_cur_id,
                     akc.base_currency_name base_cur_code,
                     cm.decimals as base_cur_decimal,
                     grd.inventory_status,
                     gsm.status shipment_status,
                     (case
                       when nvl(grd.is_afloat, 'N') = 'Y' and
                            nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                        'Shipped NTT'
                       when nvl(grd.is_afloat, 'N') = 'Y' and
                            nvl(grd.inventory_status, 'NA') = 'In' then
                        'Shipped IN'
                       when nvl(grd.is_afloat, 'N') = 'Y' and
                            nvl(grd.inventory_status, 'NA') = 'Out' then
                        'Shipped TT'
                       when nvl(grd.is_afloat, 'N') = 'N' and
                            nvl(grd.inventory_status, 'NA') in ('None', 'NA') then
                        'Stock NTT'
                       when nvl(grd.is_afloat, 'N') = 'N' and
                            nvl(grd.inventory_status, 'NA') = 'In' then
                        'Stock IN'
                       when nvl(grd.is_afloat, 'N') = 'N' and
                            nvl(grd.inventory_status, 'NA') = 'Out' then
                        'Stock TT'
                       else
                        'Others'
                     end) section_name,
                     gmr.shed_id,
                     gmr.destination_city_id,
                     null price_fixation_status,
                     pdm.base_quantity_unit base_qty_unit_id,
                     qum_pdm_conc.qty_unit_id as conc_base_qty_unit_id,
                     qum_pdm_conc.decimals as base_qty_decimal,
                     pcpd.strategy_id,
                     css.strategy_name,
                     md.valuation_exchange_id,
                     md.valuation_month,
                     md.derivative_def_id,
                     nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
                     gmr.contract_type gmr_contract_type,
                     grd.internal_grd_ref_no internal_grd_dgrd_ref_no,
                     grd.internal_stock_ref_no stock_ref_no,
                     pcm.trader_id,
                     (case
                       when pcm.trader_id is not null then
                        (select gab.firstname || ' ' || gab.lastname
                           from gab_globaladdressbook gab,
                                ak_corporate_user     aku
                          where gab.gabid = aku.gabid
                            and aku.user_id = pcm.trader_id)
                       else
                        ''
                     end) trader_user_name,
                     md.m2m_loc_incoterm_deviation,
                     md.treatment_charge m2m_treatment_charge,
                     md.refine_charge m2m_refine_charge,
                     tc_ppu_pum.price_unit_id m2m_tc_price_unit_id,
                     tc_ppu_pum.price_unit_name m2m_tc_price_unit_name,
                     tc_ppu_pum.cur_id m2m_tc_cur_id,
                     tc_ppu_pum.weight m2m_tc_weight,
                     tc_ppu_pum.weight_unit_id m2m_tc_weight_unit_id,
                     rc_ppu_pum.price_unit_id m2m_rc_price_unit_id,
                     rc_ppu_pum.price_unit_name m2m_rc_price_unit_name,
                     rc_ppu_pum.cur_id m2m_rc_cur_id,
                     rc_ppu_pum.weight m2m_rc_weight,
                     rc_ppu_pum.weight_unit_id m2m_rc_weight_unit_id,
                     md.base_price_unit_id_in_ppu,
                     md.base_price_unit_id_in_pum,
                     qat.eval_basis,
                     pcpq.unit_of_measure,
                     pum_loc_base.weight_unit_id loc_qty_unit_id,
                     tmpc.mvp_id,
                     tmpc.shipment_month,
                     tmpc.shipment_year,
                     tmpc.valuation_point,
                     pum_base_price_id.price_unit_name base_price_unit_name,
                     nvl(pdm_conc.valuation_against_underlying, 'Y') valuation_against_underlying,
                     md.m2m_rc_fw_exch_rate,
                     md.m2m_tc_fw_exch_rate,
                     md.m2m_ld_fw_exch_rate,
                     0 sc_in_base_cur,
                     invm.accrual_to_base_fw_exch_rate accrual_to_base_fw_rate,
                     invm.total_sc_charges,
                     itm.incoterm_id,
                     itm.incoterm,
                     phd_cp.profileid cp_id,
                     phd_cp.companyname cp_name,
                     (case
                       when pcdi.delivery_period_type = 'Month' then
                        pcdi.delivery_to_month || '-' ||
                        pcdi.delivery_to_year
                       else
                        to_char(pcdi.delivery_to_date, 'Mon-YYYY')
                     end) delivery_month,
                     invme.mc_per_unit,
                     invme.mc_price_unit_id,
                     invme.mc_price_unit_name,
                     invme.tc_per_unit,
                     invme.tc_price_unit_id,
                     invme.tc_price_unit_name,
                     invme.rc_per_unit,
                     invme.rc_price_unit_id,
                     invme.rc_price_unit_name,
                     decode(grd.partnership_type, 'Consignment', 'Y', 'N') as is_marked_for_consignment,
                     invm.product_premium_per_unit,
                     invm.contract_pp_fw_exch_rate,
                     invme.price_to_base_fw_exch_rate
                from gmr_goods_movement_record gmr,
                     grd_goods_record_detail grd,
                     pcm_physical_contract_main pcm,
                     pcpd_pc_product_definition pcpd,
                     cpc_corporate_profit_center cpc,
                     pdm_productmaster pdm,
                     orm_origin_master orm,
                     (select tmp.*
                        from tmpc_temp_m2m_pre_check tmp
                       where tmp.corporate_id = pc_corporate_id
                         and tmp.product_type = 'CONCENTRATES'
                         and tmp.section_name <> 'OPEN') tmpc,
                     qum_quantity_unit_master qum,
                     qat_quality_attributes qat,
                     (select md1.*
                        from md_m2m_daily md1
                       where md1.rate_type <> 'OPEN'
                         and md1.corporate_id = pc_corporate_id
                         and md1.product_type = 'CONCENTRATES'
                         and md1.process_id = pc_process_id) md,
                     ciqs_contract_item_qty_status ciqs,
                     pci_physical_contract_item pci,
                     pcpq_pc_product_quality pcpq,
                     pcdi_pc_delivery_item pcdi,
                     qav_quality_attribute_values qav,
                     ppm_product_properties_mapping ppm,
                     qat_quality_attributes qat_und,
                     aml_attribute_master_list aml,
                     pcdb_pc_delivery_basis pcdb,
                     ak_corporate akc,
                     cm_currency_master cm,
                     gsm_gmr_stauts_master gsm,
                     css_corporate_strategy_setup css,
                     pdm_productmaster pdm_conc,
                     qum_quantity_unit_master qum_pdm_conc,
                     pum_price_unit_master pum_loc_base,
                     pum_price_unit_master pum_base_price_id,
                     --- added suresh
                     ash_assay_header               ash,
                     asm_assay_sublot_mapping       asm,
                     pqca_pq_chemical_attributes    pqca,
                     rm_ratio_master                rm,
                     pqcapd_prd_qlty_cattr_pay_dtls pqcapd,
                     qum_quantity_unit_master       gmr_qum,
                     -----
                     v_ppu_pum                    tc_ppu_pum,
                     v_ppu_pum                    rc_ppu_pum,
                     ceqs_contract_ele_qty_status ceqs,
                     sam_stock_assay_mapping      sam,
                     gscs_gmr_sec_cost_summary    gscs,
                     invm_cog                     invm,
                     itm_incoterm_master          itm,
                     phd_profileheaderdetails     phd_cp,
                     invme_cog_element            invme
               where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no
                 and pcm.internal_contract_ref_no =
                     pcpd.internal_contract_ref_no
                 and pcpq.pcpd_id = pcpd.pcpd_id
                 and pcpd.profit_center_id = cpc.profit_center_id
                 and grd.origin_id = orm.origin_id(+)
                 and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
                 and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
                 and grd.internal_contract_item_ref_no =
                     tmpc.internal_contract_item_ref_no(+)
                 and tmpc.conc_quality_id = qat.quality_id
                 and grd.qty_unit_id = qum.qty_unit_id(+)
                 and tmpc.internal_m2m_id = md.md_id(+)
                 and grd.process_id = pc_process_id
                 and grd.internal_contract_item_ref_no =
                     ciqs.internal_contract_item_ref_no
                 and grd.internal_contract_item_ref_no =
                     pci.internal_contract_item_ref_no
                 and pci.pcpq_id = pcpq.pcpq_id
                 and pcm.internal_contract_ref_no =
                     pcdi.internal_contract_ref_no
                 and pcdi.pcdi_id = pci.pcdi_id
                 and pcpq.quality_template_id = qat.quality_id(+)
                 and qat.quality_id = qav.quality_id
                 and qav.attribute_id = ppm.property_id
                 and qav.comp_quality_id = qat_und.quality_id
                 and ppm.attribute_id = aml.attribute_id
                 and aml.underlying_product_id = pdm.product_id(+)
                 and aml.attribute_id = ceqs.element_id
                 and pci.pcdb_id = pcdb.pcdb_id
                 and gmr.corporate_id = akc.corporate_id
                 and akc.base_cur_id = cm.cur_id
                 and gmr.status_id = gsm.status_id(+)
                 and pcpd.strategy_id = css.strategy_id
                 and pcpd.product_id = pdm_conc.product_id
                 and qum_pdm_conc.qty_unit_id = pdm_conc.base_quantity_unit
                 and md.base_price_unit_id_in_pum =
                     pum_loc_base.price_unit_id
                 and md.base_price_unit_id_in_pum =
                     pum_base_price_id.price_unit_id
                 and md.tc_price_unit_id = tc_ppu_pum.product_price_unit_id
                 and md.rc_price_unit_id = rc_ppu_pum.product_price_unit_id
                    -- added suresh 
                 and grd.weg_avg_pricing_assay_id = ash.ash_id
                 and ash.ash_id = asm.ash_id
                 and asm.asm_id = pqca.asm_id
                 and pqca.is_elem_for_pricing = 'Y'
                 and pqca.element_id = aml.attribute_id
                 and pqca.unit_of_measure = rm.ratio_id
                 and gmr_qum.qty_unit_id =
                     (case when rm.ratio_name = '%' then grd.qty_unit_id else
                      rm.qty_unit_id_numerator end)
                 and pqca.pqca_id = pqcapd.pqca_id
                 and rm.is_active = 'Y'
                 and pqca.is_active = 'Y'
                 and pqcapd.is_active = 'Y'
                    ---  
                 and pci.internal_contract_item_ref_no =
                     ceqs.internal_contract_item_ref_no
                 and aml.attribute_id = ceqs.element_id
                 and grd.process_id = pc_process_id
                 and gmr.process_id = pc_process_id
                 and pci.process_id = pc_process_id
                 and pcm.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and pcpq.process_id = pc_process_id
                 and pcdi.process_id = pc_process_id
                 and pcpd.process_id = pc_process_id
                 and ciqs.process_id = pc_process_id
                 and pcdb.process_id = pc_process_id
                 and ceqs.process_id = pc_process_id
                 and pcm.purchase_sales = 'P'
                 and pcm.contract_status = 'In Position'
                 and pcm.contract_type = 'CONCENTRATES'
                 and pcpd.input_output = 'Input'
                 and pcm.is_tolling_contract = 'N'
                 and pcm.is_tolling_extn = 'N'
                 and pci.is_active = 'Y'
                 and pcm.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and pcpq.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and pcpd.is_active = 'Y'
                 and ppm.is_active = 'Y'
                 and ppm.is_deleted = 'N'
                 and qav.is_deleted = 'N'
                 and qav.is_comp_product_attribute = 'Y'
                 and qat.is_active = 'Y'
                 and qat.is_deleted = 'N'
                 and aml.is_active = 'Y'
                 and aml.is_deleted = 'N'
                 and qat_und.is_active = 'Y'
                 and qat_und.is_deleted = 'N'
                 and gmr.corporate_id = pc_corporate_id
                 and grd.status = 'Active'
                 and grd.is_deleted = 'N'
                 and gmr.is_deleted = 'N'
                 and nvl(grd.inventory_status, 'NA') = 'In'
                 and pcm.purchase_sales = 'P'
                 and nvl(grd.current_qty, 0) > 0
                 and grd.internal_contract_item_ref_no is not null
                 and grd.internal_grd_ref_no = sam.internal_grd_ref_no
                 and sam.is_latest_position_assay = 'Y'
                 and gmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
                 and gmr.process_id = gscs.process_id(+)
                 and grd.internal_grd_ref_no = invm.internal_grd_ref_no
                 and grd.process_id = invm.process_id
                 and pcdb.inco_term_id = itm.incoterm_id
                 and pcm.cp_id = phd_cp.profileid(+)
                 and tmpc.element_id = ceqs.element_id
                 and invme.process_id = pc_process_id
                 and invme.internal_grd_ref_no = grd.internal_grd_ref_no
                 and invme.element_id = ceqs.element_id) tt;
  
    vn_cont_price                  number;
    vc_cont_price_unit_id          varchar2(15);
    vc_cont_price_unit_cur_id      varchar2(15);
    vc_cont_price_unit_cur_code    varchar2(15);
    vn_cont_price_wt               number;
    vc_cont_price_wt_unit_id       varchar2(15);
    vc_cont_price_wt_unit          varchar2(15);
    vc_price_fixation_status       varchar2(50);
    vc_psu_id                      varchar2(500);
    vn_qty_in_base                 number;
    vn_ele_qty_in_base             number;
    vn_m2m_amt                     number;
    vc_m2m_price_unit_cur_id       varchar2(15);
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_ele_m2m_amount_in_base      number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_ele_m2m_total_amount        number;
    vn_ele_m2m_amt_per_unit        number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_contract_value_in_price_cur number;
    vn_cont_price_cur_decimals     number;
    vn_fx_price_to_base            number;
    vn_contract_value_in_val_cur   number;
    vn_contract_value_in_base_cur  number;
    vn_ele_m2m_treatment_charge    number;
    vn_dry_qty                     number;
    vn_wet_qty                     number;
    vn_dry_qty_in_base             number;
    vn_dry_qty_in_base_conc        number;
    vn_ele_m2m_refine_charge       number;
    vn_loc_amount                  number;
    vn_loc_total_amount            number;
    vn_m2m_total_penality          number;
    vn_m2m_penality                number;
    vc_penality_price_unit_id      varchar2(15);
    vc_price_unit_id               varchar2(15);
    vc_m2m_to_base_fw_rate         varchar2(50);
    vc_price_to_base_fw_rate       varchar2(50);
    vc_m2m_pc_exch_rate_string     varchar2(100);
    vc_m2m_tot_pc_exch_rate_string varchar2(100); -- M2M Penalty 
    vn_sc_in_base_cur              number;
    --vn_base_con_penality_charge    number;
    vc_error_msg                varchar2(10);
    vn_forward_points           number;
    vc_m2m_tc_main_cur_id       varchar2(15);
    vc_m2m_tc_main_cur_code     varchar2(15);
    vn_m2m_tc_main_cur_factor   number;
    vn_m2m_tc_to_base_fw_rate   number;
    vc_m2m_rc_main_cur_id       varchar2(15);
    vc_m2m_rc_main_cur_code     varchar2(15);
    vc_m2m_rc_main_cur_factor   number;
    vn_m2m_rc_to_base_fw_rate   number;
    vn_fx_price_deviation       number;
    vn_product_premium_per_unit number;
    vn_product_premium_amt      number;
    --
    vn_ele_tc_charges number;
    vc_ele_tc_cur_id  varchar2(15);
    --  vn_ele_tc_fx_exch_rate    varchar2(50);--??
    vc_ele_tc_main_cur_id     varchar2(15);
    vc_ele_tc_main_cur_code   varchar2(15);
    vc_ele_tc_main_cur_factor number;
    vn_ele_tc_to_base_fw_rate number;
    vc_ele_tc_fw_exch_rate    varchar2(50);
    vn_base_ele_tc_charges    number;
  
    vn_ele_rc_charges number;
    vc_ele_rc_cur_id  varchar2(15);
    --  vn_ele_rc_fx_exch_rate    varchar2(50);
    vc_ele_rc_main_cur_id     varchar2(15);
    vc_ele_rc_main_cur_code   varchar2(15);
    vc_ele_rc_main_cur_factor number;
    vn_ele_rc_to_base_fw_rate number;
    vc_ele_rc_fw_exch_rate    varchar2(50);
    vn_base_ele_rc_charges    number;
  
    vn_contract_pc_charges         number;
    vc_contract_pc_cur_id          varchar2(15);
    vn_contract_pc_fx_exch_rate    varchar2(50);
    vc_contract_pc_main_cur_id     varchar2(15);
    vc_contract_pc_main_cur_code   varchar2(15);
    vc_contract_pc_main_cur_factor number;
    vn_contract_pc_to_base_fw_rate number;
    vc_contract_pc_fw_exch_rate    varchar2(50);
  
  begin
    vc_error_msg := '18647';
    for cur_grd_rows in cur_grd
    loop
      vc_m2m_to_base_fw_rate         := null;
      vc_m2m_pc_exch_rate_string     := null;
      vc_m2m_tot_pc_exch_rate_string := null;
      vc_ele_tc_fw_exch_rate         := null;
      vc_ele_rc_fw_exch_rate         := null;
      vn_contract_pc_fx_exch_rate    := null;
      vc_contract_pc_fw_exch_rate    := null;
      vn_cont_price                  := cur_grd_rows.contract_price;
      vc_cont_price_unit_id          := cur_grd_rows.price_unit_id;
      vc_cont_price_unit_cur_id      := cur_grd_rows.price_unit_cur_id;
      vc_cont_price_unit_cur_code    := cur_grd_rows.price_unit_cur_code;
      vn_cont_price_wt               := cur_grd_rows.price_unit_weight;
      vc_cont_price_wt_unit_id       := cur_grd_rows.price_unit_weight_unit_id;
      vc_cont_price_wt_unit          := cur_grd_rows.price_unit_weight_unit;
      vc_price_fixation_status       := cur_grd_rows.price_fixation_status;
    
      if cur_grd_rows.stock_qty <> 0 then
        vc_psu_id := cur_grd_rows.internal_gmr_ref_no || '-' ||
                     cur_grd_rows.internal_grd_dgrd_ref_no || '-' ||
                     cur_grd_rows.internal_contract_item_ref_no || '-' ||
                     cur_grd_rows.container_no;
      
        if cur_grd_rows.unit_of_measure = 'Wet' then
          vn_dry_qty := round(pkg_metals_general.fn_get_assay_dry_qty(cur_grd_rows.conc_product_id,
                                                                      cur_grd_rows.assay_header_id,
                                                                      cur_grd_rows.stock_qty,
                                                                      cur_grd_rows.qty_unit_id),
                              cur_grd_rows.stocky_qty_decimal);
        else
          vn_dry_qty := cur_grd_rows.stock_qty;
        end if;
      
        vn_wet_qty := cur_grd_rows.stock_qty;
      
        -- convert into dry qty to base qty element level
        vc_error_msg := '18677';
        if cur_grd_rows.qty_unit_id <> cur_grd_rows.base_qty_unit_id then
          vn_dry_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                           cur_grd_rows.qty_unit_id,
                                                                           cur_grd_rows.base_qty_unit_id,
                                                                           1) *
                                      vn_dry_qty,
                                      cur_grd_rows.base_qty_decimal);
        else
          vn_dry_qty_in_base := round(vn_dry_qty,
                                      cur_grd_rows.base_qty_decimal);
        
        end if;
        -- Convert dry qty at concentrate product level
        if cur_grd_rows.qty_unit_id <> cur_grd_rows.conc_base_qty_unit_id then
          vn_dry_qty_in_base_conc := round(pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                                cur_grd_rows.qty_unit_id,
                                                                                cur_grd_rows.conc_base_qty_unit_id,
                                                                                1) *
                                           vn_dry_qty,
                                           cur_grd_rows.base_qty_decimal);
        else
          vn_dry_qty_in_base_conc := round(vn_dry_qty,
                                           cur_grd_rows.base_qty_decimal);
        
        end if;
      
        if cur_grd_rows.qty_unit_id <> cur_grd_rows.conc_base_qty_unit_id then
          vn_qty_in_base := round(cur_grd_rows.stock_qty *
                                  pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                       cur_grd_rows.qty_unit_id,
                                                                       cur_grd_rows.conc_base_qty_unit_id,
                                                                       1),
                                  cur_grd_rows.base_qty_decimal);
        else
          vn_qty_in_base := round(cur_grd_rows.stock_qty,
                                  cur_grd_rows.base_qty_decimal);
        end if;
      
        if cur_grd_rows.payable_qty_unit_id <>
           cur_grd_rows.base_qty_unit_id then
          vn_ele_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                           cur_grd_rows.payable_qty_unit_id,
                                                                           cur_grd_rows.base_qty_unit_id,
                                                                           1) *
                                      cur_grd_rows.payable_qty,
                                      cur_grd_rows.base_qty_decimal);
        else
          vn_ele_qty_in_base := round(cur_grd_rows.payable_qty,
                                      cur_grd_rows.base_qty_decimal);
        end if;
        if cur_grd_rows.valuation_against_underlying = 'Y' then
          if cur_grd_rows.eval_basis = 'FIXED' then
            vn_m2m_amt               := 0;
            vc_m2m_price_unit_cur_id := cur_grd_rows.base_cur_id;
          else
            vc_m2m_price_unit_cur_id := nvl(cur_grd_rows.m2m_price_unit_cur_id,
                                            cur_grd_rows.base_cur_id);
            vn_m2m_amt               := nvl(cur_grd_rows.net_m2m_price, 0) /
                                        nvl(cur_grd_rows.m2m_price_unit_weight,
                                            1) *
                                        pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                             cur_grd_rows.payable_qty_unit_id,
                                                                             cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                             cur_grd_rows.payable_qty);
          end if;
        
          pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                                 cur_grd_rows.base_cur_id),
                                             vc_m2m_cur_id,
                                             vc_m2m_cur_code,
                                             vn_m2m_sub_cur_id_factor,
                                             vn_m2m_cur_decimals);
        
          vn_m2m_amt := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor,
                              cur_grd_rows.base_cur_decimal);
          pkg_general.sp_bank_fx_rate(cur_grd_rows.corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      nvl(vc_m2m_cur_id,
                                          cur_grd_rows.base_cur_id),
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_inv_in_conc M2M to Base',
                                      pc_process,
                                      vn_m2m_base_fx_rate,
                                      vn_m2m_base_deviation);
          vc_error_msg := '18734';
          if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
            if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
              null;
            else
              vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                        vn_m2m_base_fx_rate || ' ' ||
                                        cur_grd_rows.base_cur_code;
            end if;
          end if;
        
          vn_ele_m2m_amount_in_base := vn_m2m_amt * vn_m2m_base_fx_rate;
        else
          -- If valuation against underly is no, then use total concentrate qty and market price to calculate the
          -- Market value for the gmr level.
          if cur_grd_rows.eval_basis = 'FIXED' then
            vn_m2m_amt               := 0;
            vc_m2m_price_unit_cur_id := cur_grd_rows.base_cur_id;
          else
            vc_m2m_price_unit_cur_id := nvl(cur_grd_rows.m2m_price_unit_cur_id,
                                            cur_grd_rows.base_cur_id);
            vn_m2m_amt               := nvl(cur_grd_rows.net_m2m_price, 0) /
                                        nvl(cur_grd_rows.m2m_price_unit_weight,
                                            1) *
                                        pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                             cur_grd_rows.conc_base_qty_unit_id,
                                                                             cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                             vn_dry_qty_in_base);
          end if;
        
          pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                                 cur_grd_rows.base_cur_id),
                                             vc_m2m_cur_id,
                                             vc_m2m_cur_code,
                                             vn_m2m_sub_cur_id_factor,
                                             vn_m2m_cur_decimals);
        
          vn_m2m_amt := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor,
                              cur_grd_rows.base_cur_decimal);
        
          pkg_general.sp_bank_fx_rate(cur_grd_rows.corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      nvl(vc_m2m_cur_id,
                                          cur_grd_rows.base_cur_id),
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_inv_in_conc M2M to Base',
                                      pc_process,
                                      vn_m2m_base_fx_rate,
                                      vn_m2m_base_deviation);
        
          if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
            if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
              null;
            else
              vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                        vn_m2m_base_fx_rate || ' ' ||
                                        cur_grd_rows.base_cur_code;
            
            end if;
          else
            vn_m2m_base_fx_rate := 1;
          end if;
        
        end if;
        -- Element Treatment Charge        
        /* pkg_metals_general.sp_get_gmr_treatment_charge(cur_grd_rows.internal_gmr_ref_no,
        cur_grd_rows.internal_grd_dgrd_ref_no,
        cur_grd_rows.element_id,
        pc_dbd_id,
        vn_cont_price,
        vc_cont_price_unit_id,
        vn_ele_tc_charges,
        vc_ele_tc_cur_id);*/
      
        begin
          select round((case
                         when getc.weight_type = 'Dry' then
                          vn_dry_qty * ucm.multiplication_factor * getc.tc_value
                         else
                          vn_wet_qty * ucm.multiplication_factor * getc.tc_value
                       end),
                       2) * getc.currency_factor,
                 getc.tc_main_cur_id
            into vn_ele_tc_charges,
                 vc_ele_tc_cur_id
            from getc_gmr_element_tc_charges getc,
                 ucm_unit_conversion_master  ucm
           where getc.process_id = pc_process_id
             and getc.internal_gmr_ref_no =
                 cur_grd_rows.internal_gmr_ref_no
             and getc.internal_grd_ref_no =
                 cur_grd_rows.internal_grd_dgrd_ref_no
             and getc.element_id = cur_grd_rows.element_id
             and ucm.from_qty_unit_id = cur_grd_rows.qty_unit_id
             and ucm.to_qty_unit_id = getc.tc_weight_unit_id;
        exception
          when others then
            vn_ele_tc_charges := 0;
            vc_ele_tc_cur_id  := null;
        end;
      
        if vc_ele_tc_cur_id <> cur_grd_rows.base_cur_id then
          -- Bank FX Rate from TC to Base Currency
          pkg_general.sp_get_base_cur_detail(vc_ele_tc_cur_id,
                                             vc_ele_tc_main_cur_id,
                                             vc_ele_tc_main_cur_code,
                                             vc_ele_tc_main_cur_factor);
        
          pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      vc_ele_tc_main_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_inv_in_conc Contract TC to Base Currency',
                                      pc_process,
                                      vn_ele_tc_to_base_fw_rate,
                                      vn_forward_points);
        
          vn_base_ele_tc_charges := round((vn_ele_tc_charges *
                                          vn_ele_tc_to_base_fw_rate *
                                          vc_ele_tc_main_cur_factor),
                                          cur_grd_rows.base_cur_decimal);
          vc_ele_tc_fw_exch_rate := '1 ' || vc_ele_tc_main_cur_code || '=' ||
                                    vn_ele_tc_to_base_fw_rate || ' ' ||
                                    cur_grd_rows.base_cur_code;
        else
          vn_ele_tc_to_base_fw_rate := 1;
          vn_base_ele_tc_charges    := round(vn_ele_tc_charges,
                                             cur_grd_rows.base_cur_decimal);
        
        end if;
        -- Refining Changes
        /*pkg_metals_general.sp_get_gmr_refine_charge(cur_grd_rows.internal_gmr_ref_no,
        cur_grd_rows.internal_grd_dgrd_ref_no,
        cur_grd_rows.element_id,
        pc_dbd_id,
        vn_cont_price,
        vc_cont_price_unit_id,
        vn_ele_rc_charges,
        vc_ele_rc_cur_id);*/
      
        begin
          select round(gerc.rc_value * ucm.multiplication_factor *
                       cur_grd_rows.payable_qty,
                       2) * gerc.currency_factor,
                 gerc.rc_main_cur_id
            into vn_ele_rc_charges,
                 vc_ele_rc_cur_id
            from gerc_gmr_element_rc_charges gerc,
                 ucm_unit_conversion_master  ucm
           where gerc.process_id = pc_process_id
             and gerc.internal_gmr_ref_no =
                 cur_grd_rows.internal_gmr_ref_no
             and gerc.internal_grd_ref_no =
                 cur_grd_rows.internal_grd_dgrd_ref_no
             and gerc.element_id = cur_grd_rows.element_id
             and ucm.from_qty_unit_id = cur_grd_rows.payable_qty_unit_id
             and ucm.to_qty_unit_id = gerc.rc_weight_unit_id;
        exception
          when others then
            vn_ele_rc_charges := 0;
            vc_ele_rc_cur_id  := null;
        end;
      
        if vc_ele_rc_cur_id <> cur_grd_rows.base_cur_id then
          -- Bank FX Rate from RC to Base Currency
          pkg_general.sp_get_base_cur_detail(vc_ele_rc_cur_id,
                                             vc_ele_rc_main_cur_id,
                                             vc_ele_rc_main_cur_code,
                                             vc_ele_rc_main_cur_factor);
        
          pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      vc_ele_rc_main_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_inv_in_conc Contract RC to Base Currency',
                                      pc_process,
                                      vn_ele_rc_to_base_fw_rate,
                                      vn_forward_points);
        
          vn_base_ele_rc_charges := round((vn_ele_rc_charges *
                                          vn_ele_rc_to_base_fw_rate *
                                          vc_ele_rc_main_cur_factor),
                                          cur_grd_rows.base_cur_decimal);
          vc_ele_rc_fw_exch_rate := '1 ' || vc_ele_rc_main_cur_code || '=' ||
                                    vn_ele_rc_to_base_fw_rate || ' ' ||
                                    cur_grd_rows.base_cur_code;
        else
          vn_ele_rc_to_base_fw_rate := 1;
          vn_base_ele_rc_charges    := round(vn_ele_rc_charges,
                                             cur_grd_rows.base_cur_decimal);
        
        end if;
        -- Penalty Changes
        if cur_grd_rows.ele_rank = 1 then
          /*pkg_metals_general.sp_get_gmr_penalty_charge_new(cur_grd_rows.internal_gmr_ref_no,
          cur_grd_rows.internal_grd_dgrd_ref_no,
          pc_dbd_id,
          vn_contract_pc_charges,
          vc_contract_pc_cur_id);*/
        
          begin
            select round(sum(case
                               when gepc.weight_type = 'Dry' then
                                vn_dry_qty * ucm.multiplication_factor * gepc.pc_value
                               else
                                vn_wet_qty * ucm.multiplication_factor * gepc.pc_value
                             end),
                         2) * gepc.currency_factor,
                   gepc.pc_main_cur_id
              into vn_contract_pc_charges,
                   vc_contract_pc_cur_id
              from gepc_gmr_element_pc_charges gepc,
                   ucm_unit_conversion_master  ucm
             where gepc.process_id = pc_process_id
               and gepc.internal_gmr_ref_no =
                   cur_grd_rows.internal_gmr_ref_no
               and gepc.internal_grd_ref_no =
                   cur_grd_rows.internal_grd_dgrd_ref_no
               and ucm.from_qty_unit_id = cur_grd_rows.qty_unit_id
               and ucm.to_qty_unit_id = gepc.pc_weight_unit_id
             group by gepc.pc_main_cur_id,
                      gepc.currency_factor;
          exception
            when others then
              vn_contract_pc_charges := 0;
              vc_contract_pc_cur_id  := null;
          end;
        
          if vc_contract_pc_cur_id <> cur_grd_rows.base_cur_id then
            -- Bank FX Rate from Penalty to Base Currency
            pkg_general.sp_get_base_cur_detail(vc_contract_pc_cur_id,
                                               vc_contract_pc_main_cur_id,
                                               vc_contract_pc_main_cur_code,
                                               vc_contract_pc_main_cur_factor);
          
            pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                        pd_trade_date,
                                        cur_grd_rows.payment_due_date,
                                        vc_contract_pc_main_cur_id,
                                        cur_grd_rows.base_cur_id,
                                        30,
                                        'sp_stock_unreal_inv_in_conc Contract pc to Base Currency',
                                        pc_process,
                                        vn_contract_pc_to_base_fw_rate,
                                        vn_forward_points);
          
            vn_contract_pc_charges      := round((vn_contract_pc_charges *
                                                 vn_contract_pc_to_base_fw_rate *
                                                 vc_contract_pc_main_cur_factor),
                                                 cur_grd_rows.base_cur_decimal);
            vc_contract_pc_fw_exch_rate := '1 ' ||
                                           vc_contract_pc_main_cur_code || '=' ||
                                           vn_contract_pc_to_base_fw_rate || ' ' ||
                                           cur_grd_rows.base_cur_code;
          else
            vn_contract_pc_to_base_fw_rate := 1;
            vn_contract_pc_charges         := round(vn_contract_pc_charges,
                                                    cur_grd_rows.base_cur_decimal);
          
          end if;
        end if;
        --
        -- Forward Rate from M2M Treatment Charge to Base Currency
        -- 
        pkg_general.sp_get_base_cur_detail(cur_grd_rows.m2m_tc_cur_id,
                                           vc_m2m_tc_main_cur_id,
                                           vc_m2m_tc_main_cur_code,
                                           vn_m2m_tc_main_cur_factor);
        if vc_m2m_tc_main_cur_id <> cur_grd_rows.base_cur_id then
          pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      cur_grd_rows.m2m_tc_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_inv_in_conc M2M TC to Base',
                                      pc_process,
                                      vn_m2m_tc_to_base_fw_rate,
                                      vn_forward_points);
        else
          vn_m2m_tc_to_base_fw_rate := 1;
        end if;
        if cur_grd_rows.qty_unit_id <> cur_grd_rows.m2m_tc_weight_unit_id then
          vn_ele_m2m_treatment_charge := round((cur_grd_rows.m2m_treatment_charge /
                                               nvl(cur_grd_rows.m2m_tc_weight,
                                                    1)) *
                                               vn_m2m_tc_to_base_fw_rate *
                                               (pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                                     cur_grd_rows.qty_unit_id,
                                                                                     cur_grd_rows.m2m_tc_weight_unit_id,
                                                                                     vn_dry_qty)),
                                               cur_grd_rows.base_cur_decimal);
        else
          vn_ele_m2m_treatment_charge := round((cur_grd_rows.m2m_treatment_charge /
                                               nvl(cur_grd_rows.m2m_tc_weight,
                                                    1)) *
                                               vn_m2m_tc_to_base_fw_rate *
                                               vn_dry_qty,
                                               cur_grd_rows.base_cur_decimal);
        end if;
        pkg_general.sp_get_base_cur_detail(cur_grd_rows.m2m_rc_cur_id,
                                           vc_m2m_rc_main_cur_id,
                                           vc_m2m_rc_main_cur_code,
                                           vc_m2m_rc_main_cur_factor);
        if vc_m2m_rc_main_cur_id <> cur_grd_rows.base_cur_id then
          pkg_general.sp_bank_fx_rate(pc_corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      cur_grd_rows.m2m_rc_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_inv_in_conc M2M RC to Base',
                                      pc_process,
                                      vn_m2m_rc_to_base_fw_rate,
                                      vn_forward_points);
        else
          vn_m2m_rc_to_base_fw_rate := 1;
        end if;
        if cur_grd_rows.payable_qty_unit_id <>
           cur_grd_rows.m2m_rc_weight_unit_id then
          vn_ele_m2m_refine_charge := round((cur_grd_rows.m2m_refine_charge /
                                            nvl(cur_grd_rows.m2m_rc_weight,
                                                 1)) *
                                            vn_m2m_rc_to_base_fw_rate *
                                            (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                                  cur_grd_rows.payable_qty_unit_id,
                                                                                  cur_grd_rows.m2m_rc_weight_unit_id,
                                                                                  cur_grd_rows.payable_qty)),
                                            cur_grd_rows.base_cur_decimal);
        else
          vn_ele_m2m_refine_charge := round((cur_grd_rows.m2m_refine_charge /
                                            nvl(cur_grd_rows.m2m_rc_weight,
                                                 1)) *
                                            vn_m2m_rc_to_base_fw_rate *
                                            cur_grd_rows.payable_qty,
                                            cur_grd_rows.base_cur_decimal);
        end if;
      
        if cur_grd_rows.ele_rank = 1 then
          if cur_grd_rows.loc_qty_unit_id <>
             cur_grd_rows.conc_base_qty_unit_id then
            vn_loc_amount := pkg_general.f_get_converted_quantity(cur_grd_rows.conc_product_id,
                                                                  cur_grd_rows.qty_unit_id,
                                                                  cur_grd_rows.conc_base_qty_unit_id,
                                                                  1) *
                             cur_grd_rows.m2m_loc_incoterm_deviation;
          else
            vn_loc_amount := cur_grd_rows.m2m_loc_incoterm_deviation;
          
          end if;
        
          vn_loc_total_amount := round(vn_loc_amount * vn_qty_in_base,
                                       cur_grd_rows.base_cur_decimal);
        end if;
        vn_m2m_total_penality := 0;
      
        if cur_grd_rows.ele_rank = 1 then
        
          begin
            select ppu.product_price_unit_id
              into vc_price_unit_id
              from v_ppu_pum         ppu,
                   pdm_productmaster pdm,
                   ak_corporate      akc
             where ppu.product_id = cur_grd_rows.conc_product_id
               and ppu.product_id = pdm.product_id
               and pdm.base_quantity_unit = ppu.weight_unit_id
               and ppu.cur_id = akc.base_cur_id
               and nvl(ppu.weight, 1) = 1
               and akc.corporate_id = pc_corporate_id;
          
          exception
            when no_data_found then
              vc_price_unit_id := null;
          end;
        
          vn_m2m_total_penality := 0;
          for cc in (select pci.internal_contract_item_ref_no,
                            pqca.element_id,
                            aml.attribute_name,
                            pcpq.quality_template_id
                       from pci_physical_contract_item  pci,
                            pcpq_pc_product_quality     pcpq,
                            ash_assay_header            ash,
                            asm_assay_sublot_mapping    asm,
                            pqca_pq_chemical_attributes pqca,
                            aml_attribute_master_list   aml
                      where pci.pcpq_id = pcpq.pcpq_id
                        and pcpq.assay_header_id = ash.ash_id
                        and ash.ash_id = asm.ash_id
                        and asm.asm_id = pqca.asm_id
                        and pqca.element_id=aml.attribute_id
                        and pci.process_id = pc_process_id
                        and pcpq.process_id = pc_process_id
                        and pci.is_active = 'Y'
                        and pcpq.is_active = 'Y'
                        and ash.is_active = 'Y'
                        and asm.is_active = 'Y'
                        and pqca.is_active = 'Y'
                        and pqca.is_elem_for_pricing = 'N'
                        and pci.internal_contract_item_ref_no =
                            cur_grd_rows.internal_contract_item_ref_no)
          loop
          
            pkg_phy_pre_check_process.sp_m2m_tc_pc_rc_charge(cur_grd_rows.corporate_id,
                                                                  pd_trade_date,
                                                                  cur_grd_rows.conc_product_id,
                                                                  cur_grd_rows.conc_quality_id,
                                                                  cur_grd_rows.mvp_id,
                                                                  'Penalties',
                                                                  cc.element_id,
                                                                  to_char(pd_trade_date,
                                                                          'Mon'),
                                                                  to_char(pd_trade_date,
                                                                          'YYYY'),
                                                                  vc_price_unit_id,
                                                                  cur_grd_rows.payment_due_date,
                                                                  vn_m2m_penality,
                                                                  vc_m2m_pc_exch_rate_string);
            if nvl(vn_m2m_penality, 0) <> 0 then
            
              vn_m2m_total_penality := round(vn_m2m_total_penality +
                                             (vn_m2m_penality *
                                             vn_dry_qty_in_base_conc),
                                             cur_grd_rows.base_cur_decimal);
            
              if vc_m2m_pc_exch_rate_string is not null then
                vc_m2m_tot_pc_exch_rate_string := vc_m2m_pc_exch_rate_string;
              else
                if instr(vc_m2m_tot_pc_exch_rate_string,
                         vc_m2m_pc_exch_rate_string) = 0 then
                  vc_m2m_tot_pc_exch_rate_string := vc_m2m_tot_pc_exch_rate_string || ',' ||
                                                    vc_m2m_pc_exch_rate_string;
                end if;
              end if;
            else
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
             cur_grd_rows.conc_product_name || ',' || cur_grd_rows.conc_quality_name || ',' ||
             cc.attribute_name || ',' || cur_grd_rows.shipment_month || '-' ||
             cur_grd_rows.shipment_year || '-' || cur_grd_rows.valuation_point,
             null,
             pc_process,
             sysdate,
             pc_user_id,
             pd_trade_date); 
            end if;          
          end loop;
        
        end if;
      
        vn_ele_m2m_total_amount := vn_ele_m2m_amount_in_base -
                                   vn_ele_m2m_treatment_charge -
                                   vn_ele_m2m_refine_charge;
        if vn_ele_qty_in_base <> 0 then
          vn_ele_m2m_amt_per_unit := round(vn_ele_m2m_total_amount /
                                           vn_ele_qty_in_base,
                                           cur_grd_rows.base_cur_decimal);
        else
          vn_ele_m2m_amt_per_unit := 0;
        end if;
        pkg_general.sp_get_main_cur_detail(nvl(vc_cont_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
        vn_contract_value_in_price_cur := (vn_cont_price /
                                          nvl(vn_cont_price_wt, 1)) *
                                          (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                                cur_grd_rows.payable_qty_unit_id,
                                                                                vc_cont_price_wt_unit_id,
                                                                                cur_grd_rows.payable_qty)) *
                                          vn_cont_price_cur_id_factor;
      
        vn_contract_value_in_price_cur := round(vn_contract_value_in_price_cur,
                                                vn_cont_price_cur_decimals);
      
        vn_contract_value_in_val_cur := round((vn_contract_value_in_price_cur),
                                              cur_grd_rows.base_cur_decimal);
      
        if vc_price_cur_id <> cur_grd_rows.base_cur_id then
          pkg_general.sp_bank_fx_rate(cur_grd_rows.corporate_id,
                                      pd_trade_date,
                                      cur_grd_rows.payment_due_date,
                                      vc_price_cur_id,
                                      cur_grd_rows.base_cur_id,
                                      30,
                                      'sp_stock_unreal_inv_in_conc Price to Base Currency',
                                      pc_process,
                                      vn_fx_price_to_base,
                                      vn_fx_price_deviation);
        else
          vn_fx_price_to_base := 1;
        end if;
      
        vn_contract_value_in_base_cur := vn_contract_value_in_val_cur *
                                         vn_fx_price_to_base;
      end if;
      vc_price_to_base_fw_rate := cur_grd_rows.price_to_base_fw_exch_rate;
    
      insert into psue_element_details
        (corporate_id,
         process_id,
         internal_contract_item_ref_no,
         psu_id,
         internal_gmr_ref_no,
         element_id,
         element_name,
         assay_header_id,
         assay_qty,
         assay_qty_unit_id,
         payable_qty,
         payable_qty_unit_id,
         payable_qty_unit,
         contract_price,
         price_unit_id,
         price_unit_name,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         md_id,
         m2m_price,
         m2m_price_cur_id,
         m2m_price_cur_code,
         m2m_price_weight_unit_id,
         m2m_price_weight_unit,
         m2m_price_weight_unit_weight,
         m2m_refining_charge,
         m2m_treatment_charge,
         pricing_details,
         m2m_price_unit_id,
         m2m_price_unit_str,
         m2m_amt,
         m2m_amt_cur_id,
         m2m_amt_cur_code,
         contract_value_in_price_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         material_cost_in_base_cur,
         element_qty_in_base_unit,
         total_m2m_amount,
         m2m_amt_per_unit,
         price_cur_to_base_cur_fx_rate,
         m2m_cur_to_base_cur_fx_rate,
         base_price_unit_id_in_ppu,
         base_price_unit_id_in_pum,
         valuation_against_underlying,
         internal_grd_dgrd_ref_no,
         price_to_base_fw_exch_rate,
         m2m_to_base_fw_exch_rate,
         m2m_rc_fw_exch_rate,
         m2m_tc_fw_exch_rate,
         m2m_ld_fw_exch_rate,
         contract_rc_in_base_cur,
         contract_tc_in_base_cur,
         contract_rc_fw_exch_rate,
         contract_tc_fw_exch_rate)
      values
        (cur_grd_rows.corporate_id,
         pc_process_id,
         cur_grd_rows.internal_contract_item_ref_no,
         vc_psu_id,
         cur_grd_rows.internal_gmr_ref_no,
         cur_grd_rows.element_id,
         cur_grd_rows.attribute_name,
         cur_grd_rows.assay_header_id,
         cur_grd_rows.assay_qty,
         cur_grd_rows.assay_qty_unit_id,
         cur_grd_rows.payable_qty,
         cur_grd_rows.payable_qty_unit_id,
         cur_grd_rows.payable_qty_unit,
         vn_cont_price,
         vc_cont_price_unit_id,
         cur_grd_rows.mc_price_unit_name,
         vc_cont_price_unit_cur_id,
         vc_cont_price_unit_cur_code,
         vc_cont_price_wt_unit_id,
         vn_cont_price_wt,
         vc_cont_price_wt_unit,
         cur_grd_rows.md_id,
         cur_grd_rows.net_m2m_price,
         cur_grd_rows.m2m_price_unit_cur_id,
         cur_grd_rows.m2m_price_unit_cur_code,
         cur_grd_rows.m2m_price_unit_weight_unit_id,
         cur_grd_rows.m2m_price_unit_weight_unit,
         decode(cur_grd_rows.m2m_price_unit_weight,
                1,
                null,
                cur_grd_rows.m2m_price_unit_weight),
         vn_ele_m2m_refine_charge,
         vn_ele_m2m_treatment_charge,
         cur_grd_rows.price_description,
         cur_grd_rows.m2m_price_unit_id,
         cur_grd_rows.m2m_price_unit_str,
         vn_m2m_amt,
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         vn_ele_qty_in_base,
         vn_ele_m2m_total_amount,
         vn_ele_m2m_amt_per_unit,
         vn_fx_price_to_base,
         vn_m2m_base_fx_rate,
         cur_grd_rows.base_price_unit_id_in_ppu,
         cur_grd_rows.base_price_unit_id_in_pum,
         cur_grd_rows.valuation_against_underlying,
         cur_grd_rows.internal_grd_dgrd_ref_no,
         vc_price_to_base_fw_rate,
         vc_m2m_to_base_fw_rate,
         cur_grd_rows.m2m_rc_fw_exch_rate,
         cur_grd_rows.m2m_tc_fw_exch_rate,
         cur_grd_rows.m2m_ld_fw_exch_rate,
         vn_base_ele_rc_charges, -- base_con_refine_charge,
         vn_base_ele_tc_charges, -- base_con_treatment_charge,
         vc_ele_rc_fw_exch_rate, -- contract_rc_fw_exch_rate,
         vc_ele_tc_fw_exch_rate); -- contract_tc_fw_exch_rate)
    
      if cur_grd_rows.ele_rank = 1 then
        vn_sc_in_base_cur           := cur_grd_rows.total_sc_charges;
        vn_product_premium_per_unit := cur_grd_rows.product_premium_per_unit;
        vn_product_premium_amt      := cur_grd_rows.product_premium_per_unit *
                                       vn_qty_in_base;
        insert into psue_phy_stock_unrealized_ele
          (process_id,
           psu_id,
           corporate_id,
           corporate_name,
           internal_gmr_ref_no,
           internal_contract_item_ref_no,
           contract_ref_no,
           delivery_item_no,
           del_distribution_item_no,
           product_id,
           product_name,
           origin_id,
           origin_name,
           quality_id,
           quality_name,
           container_no,
           stock_wet_qty,
           stock_dry_qty,
           qty_unit_id,
           qty_unit,
           qty_in_base_unit,
           no_of_units,
           prod_base_qty_unit_id,
           prod_base_qty_unit,
           inventory_status,
           shipment_status,
           section_name,
           strategy_id,
           strategy_name,
           valuation_month,
           contract_type,
           profit_center_id,
           profit_center_name,
           profit_center_short_name,
           valuation_exchange_id,
           derivative_def_id,
           gmr_contract_type,
           is_voyage_gmr,
           gmr_ref_no,
           warehouse_id,
           warehouse_name,
           shed_id,
           shed_name,
           internal_grd_dgrd_ref_no,
           fixation_method,
           price_fixation_details,
           stock_ref_no,
           trader_name,
           trader_id,
           contract_qty_string,
           contract_price_string,
           m2m_price_string,
           m2m_rc_tc_string,
           m2m_penalty_charge,
           m2m_treatment_charge,
           m2m_refining_charge,
           m2m_loc_diff_premium,
           net_contract_value_in_base_cur,
           net_m2m_amount_in_base_cur,
           prev_net_m2m_amt_in_base_cur,
           pnl_type,
           pnl_in_base_cur,
           pnl_in_per_base_unit,
           prev_day_pnl_in_base_cur,
           prev_day_pnl_per_base_unit,
           trade_day_pnl_in_base_cur,
           trade_day_pnl_per_base_unit,
           cont_unr_status,
           prev_m2m_price_string,
           prev_m2m_rc_tc_string,
           prev_m2m_penalty_charge,
           prev_m2m_treatment_charge,
           prev_m2m_refining_charge,
           prev_m2m_loc_diff_premium,
           base_price_unit_id,
           base_price_unit_name,
           base_cur_id,
           base_cur_code,
           valuation_against_underlying,
           price_to_base_fw_exch_rate,
           m2m_to_base_fw_exch_rate,
           contract_pc_in_base_cur,
           sc_in_base_cur,
           accrual_to_base_fw_exch_rate,
           material_cost_in_base_cur,
           contract_rc_in_base_cur,
           contract_tc_in_base_cur,
           contract_rc_fw_exch_rate,
           contract_tc_fw_exch_rate,
           contract_pc_fw_exch_rate,
           incoterm_id,
           incoterm,
           cp_id,
           cp_name,
           delivery_month,
           contract_rc_tc_pen_string,
           is_marked_for_consignment,
           location_premium_per_unit,
           location_premium,
           location_premium_fw_exch_rate)
        values
          (pc_process_id,
           vc_psu_id,
           cur_grd_rows.corporate_id,
           cur_grd_rows.corporate_name,
           cur_grd_rows.internal_gmr_ref_no,
           cur_grd_rows.internal_contract_item_ref_no,
           cur_grd_rows.contract_ref_no,
           cur_grd_rows.delivery_item_no,
           cur_grd_rows.del_distribution_item_no,
           cur_grd_rows.conc_product_id,
           cur_grd_rows.conc_product_name,
           cur_grd_rows.origin_id,
           cur_grd_rows.origin_name,
           cur_grd_rows.conc_quality_id,
           cur_grd_rows.conc_quality_name,
           cur_grd_rows.container_no,
           vn_wet_qty,
           vn_dry_qty,
           cur_grd_rows.qty_unit_id,
           cur_grd_rows.qty_unit,
           vn_qty_in_base,
           cur_grd_rows.no_of_units,
           null, --prod_base_qty_unit_id
           null, --prod_base_qty_unit
           cur_grd_rows.inventory_status,
           cur_grd_rows.shipment_status,
           cur_grd_rows.section_name,
           cur_grd_rows.strategy_id,
           cur_grd_rows.strategy_name,
           cur_grd_rows.valuation_month,
           cur_grd_rows.purchase_sales,
           cur_grd_rows.profit_center,
           cur_grd_rows.profit_center_name,
           cur_grd_rows.profit_center_short_name,
           cur_grd_rows.valuation_exchange_id,
           cur_grd_rows.derivative_def_id,
           cur_grd_rows.gmr_contract_type,
           cur_grd_rows.is_voyage_gmr,
           null, --gmr_ref_no
           null, --warehouse_id,
           null, --warehouse_name,
           null, --shed_id,
           null, --shed_name
           cur_grd_rows.internal_grd_dgrd_ref_no,
           vc_price_fixation_status,
           cur_grd_rows.price_fixation_details,
           cur_grd_rows.stock_ref_no,
           cur_grd_rows.trader_user_name,
           cur_grd_rows.trader_id,
           null, --contract_qty_string,
           null, --contract_price_string,  
           null, --m2m_price_string,   
           null, --m2m_rc_tc_string,
           vn_m2m_total_penality,
           null, --m2m_treatment_charge,
           null, --m2m_refining_charge,
           vn_loc_total_amount, --m2m_loc_diff_premium,
           null, --net_contract_value_in_base_cur, 
           null, --net_m2m_amount_in_base_cur,
           null, --prev_net_m2m_amt_in_base_cur,
           'Unrealized',
           null, -- pnl_in_base_cur,
           null, -- pnl_in_per_base_unit,
           null, -- prev_day_pnl_in_base_cur,
           null, -- prev_day_pnl_per_base_unit,
           null, --trade_day_pnl_in_base_cur,
           null, --trade_day_pnl_per_base_unit,
           null, --cont_unr_status,
           null, --prev_m2m_price_string,    
           null, --prev_m2m_rc_tc_string,
           null, --prev_m2m_penalty_charge, 
           null, --prev_m2m_treatment_charge, 
           null, --prev_m2m_refining_charge, 
           null, --prev_m2m_loc_diff_premium,
           cur_grd_rows.base_price_unit_id_in_ppu,
           cur_grd_rows.base_price_unit_name,
           cur_grd_rows.base_cur_id,
           cur_grd_rows.base_cur_code,
           cur_grd_rows.valuation_against_underlying,
           vc_price_to_base_fw_rate,
           vc_m2m_to_base_fw_rate,
           vn_contract_pc_charges,
           vn_sc_in_base_cur,
           cur_grd_rows.accrual_to_base_fw_rate,
           vn_contract_value_in_base_cur,
           null, -- cur_grd_rows.total_rc_charges,
           null, -- cur_grd_rows.total_tc_charges,
           null, --cur_grd_rows.contract_rc_fw_exch_rate,
           null, -- cur_grd_rows.contract_tc_fw_exch_rate,
           vc_contract_pc_fw_exch_rate,
           cur_grd_rows.incoterm_id,
           cur_grd_rows.incoterm,
           cur_grd_rows.cp_id,
           cur_grd_rows.cp_name,
           cur_grd_rows.delivery_month,
           null, -- vc_contract_rc_tc_pc_string,
           cur_grd_rows.is_marked_for_consignment,
           vn_product_premium_per_unit,
           vn_product_premium_amt,
           cur_grd_rows.contract_pp_fw_exch_rate);
      end if;
    end loop;
    for cur_update_pnl in (select psue.psu_id,
                                  sum(psue.material_cost_in_base_cur) material_cost_in_base_cur,
                                  sum(psue.contract_tc_in_base_cur) contract_tc_in_base_cur,
                                  sum(psue.contract_rc_in_base_cur) contract_rc_in_base_cur,
                                  sum(psue.m2m_amt) net_m2m_amt,
                                  sum(psue.m2m_treatment_charge) net_m2m_treatment_charge,
                                  sum(psue.m2m_refining_charge) net_m2m_refining_charge,
                                  stragg(psue.element_name || '-' ||
                                         psue.payable_qty || ' ' ||
                                         psue.payable_qty_unit) contract_qty_string,
                                  stragg(psue.element_name || '-' ||
                                         psue.contract_price || ' ' ||
                                         psue.price_unit_name) contract_price_string,
                                  (case
                                     when psue.valuation_against_underlying = 'N' then
                                      max((case
                                     when nvl(psue.m2m_price, 0) <> 0 then
                                      (psue.m2m_price || ' ' ||
                                      psue.m2m_price_cur_code || '/' ||
                                      psue.m2m_price_weight_unit_weight ||
                                      psue.m2m_price_weight_unit)
                                     else
                                      null
                                   end)) else stragg((case
                                    when nvl(psue.m2m_price,
                                             0) <> 0 then
                                     (psue.element_name || '-' ||
                                     psue.m2m_price || ' ' ||
                                     psue.m2m_price_cur_code || '/' ||
                                     psue.m2m_price_weight_unit_weight ||
                                     psue.m2m_price_weight_unit)
                                    else
                                     null
                                  end)) end) m2m_price_string, -- TODO if underly valuation = n, show the concentrate price
                                  stragg('TC:' || psue.element_name || '-' ||
                                         psue.m2m_treatment_charge || ' ' ||
                                         akc.base_currency_name || ' ' ||
                                         'RC:' || psue.element_name || '-' ||
                                         psue.m2m_refining_charge || ' ' ||
                                         akc.base_currency_name) m2m_rc_tc_pen_string,
                                  stragg(psueh.contract_rc_fw_exch_rate) contract_rc_fw_exch_rate,
                                  stragg(psueh.contract_tc_fw_exch_rate) contract_tc_fw_exch_rate,
                                  'TC :' ||
                                  sum(psue.contract_tc_in_base_cur) || ' ' ||
                                  psueh.base_cur_code || ',RC :' ||
                                  sum(psue.contract_rc_in_base_cur) || ' ' ||
                                  psueh.base_cur_code || ',PC :' ||
                                  psueh.contract_pc_in_base_cur || ' ' ||
                                  psueh.base_cur_code contract_rc_tc_pc_string,
                                  stragg(psueh.price_to_base_fw_exch_rate) price_to_base_fw_exch_rate
                             from psue_element_details          psue,
                                  psue_phy_stock_unrealized_ele psueh,
                                  ak_corporate                  akc
                            where psue.corporate_id = pc_corporate_id
                              and psue.process_id = pc_process_id
                              and psueh.process_id = pc_process_id
                              and psueh.psu_id = psue.psu_id
                              and psueh.section_name in
                                  ('Stock IN', 'Shipped IN')
                              and akc.corporate_id = psue.corporate_id
                            group by psue.psu_id,
                                     psue.valuation_against_underlying,
                                     psueh.base_cur_code,
                                     psueh.contract_pc_in_base_cur)
    loop
    
      update psue_phy_stock_unrealized_ele psuee
         set psuee.net_m2m_amount             = cur_update_pnl.net_m2m_amt,
             psuee.m2m_treatment_charge       = cur_update_pnl.net_m2m_treatment_charge,
             psuee.m2m_refining_charge        = cur_update_pnl.net_m2m_refining_charge,
             psuee.contract_price_string      = cur_update_pnl.contract_price_string,
             psuee.m2m_price_string           = cur_update_pnl.m2m_price_string,
             psuee.m2m_rc_tc_string           = cur_update_pnl.m2m_rc_tc_pen_string,
             psuee.contract_qty_string        = cur_update_pnl.contract_qty_string,
             psuee.material_cost_in_base_cur  = cur_update_pnl.material_cost_in_base_cur,
             psuee.contract_rc_in_base_cur    = cur_update_pnl.contract_rc_in_base_cur,
             psuee.contract_tc_in_base_cur    = cur_update_pnl.contract_tc_in_base_cur,
             psuee.contract_rc_tc_pen_string  = cur_update_pnl.contract_rc_tc_pc_string,
             psuee.price_to_base_fw_exch_rate = cur_update_pnl.price_to_base_fw_exch_rate
       where psuee.psu_id = cur_update_pnl.psu_id
         and psuee.process_id = pc_process_id
         and psuee.corporate_id = pc_corporate_id
         and psuee.section_name in ('Stock IN', 'Shipped IN');
    end loop;
  
    update psue_phy_stock_unrealized_ele psuee
       set psuee.net_m2m_amount_in_base_cur = (psuee.net_m2m_amount -
                                              psuee.m2m_treatment_charge -
                                              psuee.m2m_refining_charge -
                                              psuee.m2m_penalty_charge +
                                              psuee.m2m_loc_diff_premium)
     where psuee.corporate_id = pc_corporate_id
       and psuee.process_id = pc_process_id
       and psuee.section_name in ('Stock IN', 'Shipped IN');
    --- previous EOD Data
    for cur_update in (select psue_prev_day.net_m2m_amount_in_base_cur,
                              psue_prev_day.net_m2m_amount,
                              psue_prev_day.pnl_in_per_base_unit,
                              psue_prev_day.m2m_price_string,
                              psue_prev_day.m2m_rc_tc_string,
                              psue_prev_day.m2m_penalty_charge,
                              psue_prev_day.m2m_treatment_charge,
                              psue_prev_day.m2m_refining_charge,
                              psue_prev_day.m2m_loc_diff_premium,
                              psue_prev_day.qty_in_base_unit,
                              psue_prev_day.psu_id,
                              psue_prev_day.m_pnl_in_per_base_unit,
                              psue_prev_day.section_name
                         from psue_phy_stock_unrealized_ele psue_prev_day
                        where process_id = pc_previous_process_id
                          and corporate_id = pc_corporate_id
                          and psue_prev_day.section_name in
                              ('Stock IN', 'Shipped IN'))
    loop
      update psue_phy_stock_unrealized_ele psue_today
         set psue_today.prev_net_m2m_amt_in_base_cur = cur_update.net_m2m_amount_in_base_cur,
             psue_today.m_prev_day_pnl_in_base_cur   = cur_update.m_pnl_in_per_base_unit *
                                                       psue_today.qty_in_base_unit,
             psue_today.prev_net_m2m_amount          = cur_update.net_m2m_amount,
             psue_today.prev_day_pnl_in_base_cur     = cur_update.pnl_in_per_base_unit *
                                                       psue_today.qty_in_base_unit,
             psue_today.prev_day_pnl_per_base_unit   = cur_update.pnl_in_per_base_unit,
             psue_today.prev_m2m_price_string        = cur_update.m2m_price_string,
             psue_today.prev_m2m_rc_tc_string        = cur_update.m2m_rc_tc_string,
             psue_today.prev_m2m_penalty_charge      = cur_update.m2m_penalty_charge,
             psue_today.prev_m2m_treatment_charge    = cur_update.m2m_treatment_charge,
             psue_today.prev_m2m_refining_charge     = cur_update.m2m_refining_charge,
             psue_today.prev_m2m_loc_diff_premium    = cur_update.m2m_loc_diff_premium,
             psue_today.cont_unr_status              = 'EXISTING_TRADE'
       where psue_today.process_id = pc_process_id
         and psue_today.corporate_id = pc_corporate_id
         and psue_today.psu_id = cur_update.psu_id
         and psue_today.section_name in ('Stock IN', 'Shipped IN');
    end loop;
  
    begin
      update psue_phy_stock_unrealized_ele psue
         set psue.prev_net_m2m_amt_in_base_cur = psue.net_m2m_amount_in_base_cur,
             psue.prev_day_pnl_in_base_cur     = 0,
             psue.prev_day_pnl_per_base_unit   = 0,
             psue.m_prev_day_pnl_in_base_cur   = 0,
             psue.m_prev_day_pnl_per_base_unit = 0,
             psue.prev_net_m2m_amount          = psue.net_m2m_amount,
             psue.prev_m2m_price_string        = psue.m2m_price_string,
             psue.prev_m2m_rc_tc_string        = psue.m2m_rc_tc_string,
             psue.prev_m2m_penalty_charge      = psue.m2m_penalty_charge,
             psue.prev_m2m_treatment_charge    = psue.m2m_treatment_charge,
             psue.prev_m2m_refining_charge     = psue.m2m_refining_charge,
             psue.prev_m2m_loc_diff_premium    = psue.m2m_loc_diff_premium,
             psue.cont_unr_status              = 'NEW_TRADE'
       where psue.cont_unr_status is null
         and psue.process_id = pc_process_id
         and psue.corporate_id = pc_corporate_id
         and psue.section_name in ('Stock IN', 'Shipped IN');
    end;
  
    update psue_phy_stock_unrealized_ele psue
       set psue.m_pnl_in_base_cur      = psue.net_m2m_amount_in_base_cur -
                                         psue.prev_net_m2m_amt_in_base_cur,
           psue.m_pnl_in_per_base_unit = (psue.net_m2m_amount_in_base_cur -
                                         psue.prev_net_m2m_amt_in_base_cur) /
                                         psue.qty_in_base_unit
     where psue.process_id = pc_process_id
       and psue.corporate_id = pc_corporate_id
       and psue.section_name in ('Stock IN', 'Shipped IN');
    -- Calculate PNL in Base Currency = MC - TC - RC - PC + SC ( +- M2M)
    update psue_phy_stock_unrealized_ele psue
       set psue.net_contract_value_in_base_cur = psue.material_cost_in_base_cur -
                                                 psue.contract_tc_in_base_cur -
                                                 psue.contract_rc_in_base_cur -
                                                 psue.contract_pc_in_base_cur +
                                                 psue.sc_in_base_cur +
                                                 psue.location_premium,
           psue.pnl_in_base_cur                = case when psue.contract_type = 'P' then psue.net_m2m_amount_in_base_cur - (psue.material_cost_in_base_cur + psue.location_premium - psue.contract_tc_in_base_cur - psue.contract_rc_in_base_cur - psue.contract_pc_in_base_cur + psue.sc_in_base_cur) else(psue.material_cost_in_base_cur + psue.location_premium_per_unit - psue.contract_tc_in_base_cur - psue.contract_rc_in_base_cur - psue.contract_pc_in_base_cur + psue.sc_in_base_cur) - psue.net_m2m_amount_in_base_cur end,
           psue.pnl_in_per_base_unit           = (case when psue.contract_type = 'P' then psue.net_m2m_amount_in_base_cur - (psue.material_cost_in_base_cur + psue.location_premium - psue.contract_tc_in_base_cur - psue.contract_rc_in_base_cur - psue.contract_pc_in_base_cur + psue.sc_in_base_cur) else(psue.material_cost_in_base_cur + psue.location_premium - psue.contract_tc_in_base_cur - psue.contract_rc_in_base_cur - psue.contract_pc_in_base_cur + psue.sc_in_base_cur) - psue.net_m2m_amount_in_base_cur end) / psue.qty_in_base_unit
     where psue.process_id = pc_process_id
       and psue.corporate_id = pc_corporate_id
       and psue.section_name in ('Stock IN', 'Shipped IN');
    update psue_phy_stock_unrealized_ele psue
       set m_trade_day_pnl_in_base_cur = nvl(psue.m_pnl_in_base_cur, 0) -
                                         nvl(psue.m_prev_day_pnl_in_base_cur,
                                             0),
           trade_day_pnl_in_base_cur   = nvl(psue.pnl_in_base_cur, 0) -
                                         nvl(psue.prev_day_pnl_in_base_cur,
                                             0),
           
           m_trade_day_pnl_per_base_unit = nvl(psue.m_pnl_in_base_cur, 0) -
                                           nvl(psue.m_prev_day_pnl_in_base_cur,
                                               0) / psue.qty_in_base_unit,
           trade_day_pnl_per_base_unit   = nvl(psue.pnl_in_base_cur, 0) -
                                           nvl(psue.prev_day_pnl_in_base_cur,
                                               0) / psue.qty_in_base_unit
    
     where psue.process_id = pc_process_id
       and psue.corporate_id = pc_corporate_id
       and psue.section_name in ('Stock IN', 'Shipped IN');
  
    update psue_phy_stock_unrealized_ele psue
       set (gmr_ref_no, warehouse_id, warehouse_name, shed_id, shed_name, prod_base_qty_unit_id, prod_base_qty_unit) = --
            (select gmr.gmr_ref_no,
                    gmr.warehouse_profile_id,
                    phd_gmr.companyname as warehouse_profile_name,
                    gmr.shed_id,
                    sld.storage_location_name,
                    pdm.base_quantity_unit,
                    qum.qty_unit
               from gmr_goods_movement_record   gmr,
                    pdm_productmaster           pdm,
                    phd_profileheaderdetails    phd_gmr,
                    sld_storage_location_detail sld,
                    qum_quantity_unit_master    qum
              where gmr.internal_gmr_ref_no = psue.internal_gmr_ref_no
                and psue.product_id = pdm.product_id
                and pdm.base_quantity_unit = qum.qty_unit_id
                and gmr.warehouse_profile_id = phd_gmr.profileid(+)
                and gmr.shed_id = sld.storage_loc_id(+)
                and psue.process_id = gmr.process_id
                and psue.process_id = pc_process_id)
     where psue.process_id = pc_process_id
       and psue.section_name in ('Stock IN', 'Shipped IN');
    --
    -- Update Price String from CIPDE
    --   
    for cur_price_string in (select cipde.internal_contract_item_ref_no,
                                    stragg(cipde.price_description) price_description,
                                    stragg(cipde.price_fixation_details) price_fixation_details
                               from cipde_cipd_element_price cipde
                              where cipde.process_id = pc_process_id
                              group by cipde.internal_contract_item_ref_no)
    loop
      update psue_phy_stock_unrealized_ele psu
         set psu.price_description      = cur_price_string.price_description,
             psu.price_fixation_details = cur_price_string.price_fixation_details
       where psu.process_id = pc_process_id
         and psu.internal_contract_item_ref_no =
             cur_price_string.internal_contract_item_ref_no;
    end loop;
  exception
    when others then
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_stock_unreal_inv_in_conc ',
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
end; 
/
