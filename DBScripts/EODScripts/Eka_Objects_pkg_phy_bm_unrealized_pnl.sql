CREATE OR REPLACE PACKAGE "PKG_PHY_BM_UNREALIZED_PNL" is

  procedure sp_calc_phy_open_unreal_pnl(pc_corporate_id        varchar2,
                                        pd_trade_date          date,
                                        pc_process_id          varchar2,
                                        pc_user_id             varchar2,
                                        pc_process             varchar2,
                                        pc_previous_process_id varchar2);

  procedure sp_stock_unreal_sntt_bm(pc_corporate_id        varchar2,
                                    pd_trade_date          date,
                                    pc_process_id          varchar2,
                                    pc_user_id             varchar2,
                                    pc_process             varchar2,
                                    pc_previous_process_id varchar2);
  procedure sp_stock_unreal_inv_in_bm(pc_corporate_id        varchar2,
                                      pd_trade_date          date,
                                      pc_process_id          varchar2,
                                      pc_user_id             varchar2,
                                      pc_process             varchar2,
                                      pc_previous_process_id varchar2);

end;
/
CREATE OR REPLACE PACKAGE BODY "PKG_PHY_BM_UNREALIZED_PNL" is
  procedure sp_calc_phy_open_unreal_pnl(pc_corporate_id        varchar2,
                                        pd_trade_date          date,
                                        pc_process_id          varchar2,
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
             pcpd.product_id,
             pdm.product_desc product_name,
             ciqs.open_qty item_qty,
             ciqs.item_qty_unit_id qty_unit_id,
             qum.qty_unit,
             pcpq.quality_template_id,
             qat.quality_name,
             pdm.product_desc,
             cipd.price_basis,
             pt.price_type_name,
             cipd.price_description price_description,
             pci.expected_delivery_month || '-' ||
             pci.expected_delivery_year item_delivery_period_string,
             cipd.price_basis fixation_method,
             cipd.price_fixation_status,
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
             cipd.price_fixation_details as price_fixation_details,
             cipd.contract_price as contract_price,
             cipd.price_unit_id price_unit_id,
             cipd.price_unit_cur_id price_unit_cur_id,
             cipd.price_unit_cur_code price_unit_cur_code,
             cipd.price_unit_weight_unit_id,
             cipd.price_unit_weight price_unit_weight,
             cipd.price_unit_weight_unit price_unit_weight_unit,
             nvl(cipd.payment_due_date, pd_trade_date) payment_due_date,
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
             0 m2m_amt,
             nvl(ciscs.avg_cost_fw_rate, 0) sc_in_base_cur,
             ciscs.fw_rate_string accrual_to_base_fw_exch_rate,
             cm.cur_id as base_cur_id,
             cm.cur_code as base_cur_code,
             md.md_id md_id,
             pd_trade_date eod_trade_date,
             gcd.groupid,
             gcd.groupname,
             cm_gcd.cur_id cur_id_gcd,
             cm_gcd.cur_code cur_code_gcd,
             qum_gcd.qty_unit_id qty_unit_id_gcd,
             qum_gcd.qty_unit qty_unit_gcd,
             qum_pdm.qty_unit_id as base_qty_unit_id,
             qum_pdm.qty_unit as base_qty_unit,
             pcpd.strategy_id,
             css.strategy_name,
             (ciqs.total_qty - nvl(ciqs.price_fixed_qty, 0)) unfxd_qty,
             ciqs.price_fixed_qty fxd_qty,
             md.derivative_def_id,
             md.valuation_exchange_id,
             md.valuation_dr_id,
             drm.dr_id_name,
             md.valuation_month,
             md.m2m_loc_incoterm_deviation,
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             akc.base_currency_name,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             md.m2m_pp_fw_exch_rate,
             md.m2m_ld_fw_exch_rate,
             md.m2m_qp_fw_exch_rate,
             qat.eval_basis,
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
             qum_quantity_unit_master qum,
             pcpq_pc_product_quality pcpq,
             pt_price_type pt,
             qat_quality_attributes qat,
             pcdb_pc_delivery_basis pcdb,
             itm_incoterm_master itm,
             cim_citymaster cim1,
             cim_citymaster cim2,
             cym_countrymaster cym1,
             cym_countrymaster cym2,
             rem_region_master@eka_appdb rem_cym1,
             rem_region_master@eka_appdb rem_cym2,
             pym_payment_terms_master pym,
             cipd_contract_item_price_daily cipd,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type = 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             drm_derivative_master drm,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name = 'OPEN') tmpc,
             cm_currency_master cm,
             gcd_groupcorporatedetails gcd,
             cm_currency_master cm_gcd,
             qum_quantity_unit_master qum_gcd,
             qum_quantity_unit_master qum_pdm,
             css_corporate_strategy_setup css,
             ciqs_contract_item_qty_status ciqs,
             ciscs_cisc_summary ciscs
       where pcm.corporate_id = akc.corporate_id
         and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pcpd.profit_center_id = cpc.profit_center_id
         and pcm.cp_id = phd_cp.profileid
         and pcpd.product_id = pdm.product_id
         and pci.item_qty_unit_id = qum.qty_unit_id
         and pci.pcpq_id = pcpq.pcpq_id
         and pcpq.quality_template_id = qat.quality_id
         and cipd.price_basis = pt.price_type_id
         and pcdi.internal_contract_ref_no = pcdb.internal_contract_ref_no
         and pcdb.inco_term_id = itm.incoterm_id
         and pcdb.city_id = cim1.city_id(+)
         and pcdb.city_id = cim2.city_id(+)
         and pcdb.country_id = cym1.country_id(+)
         and pcdb.country_id = cym2.country_id(+)
         and cym1.region_id = rem_cym1.region_id(+)
         and cym2.region_id = rem_cym2.region_id(+)
         and pcm.payment_term_id = pym.payment_term_id
         and pci.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and akc.base_cur_id = cm.cur_id
         and akc.groupid = gcd.groupid
         and gcd.group_cur_id = cm_gcd.cur_id(+)
         and gcd.group_qty_unit_id = qum_gcd.qty_unit_id(+)
         and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         and pcpd.strategy_id = css.strategy_id
         and ciqs.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.pcdb_id = pcdb.pcdb_id
         and pcm.corporate_id = pc_corporate_id
         and pcm.contract_status = 'In Position'
         and pcpd.input_output = 'Input'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pcdb.is_active = 'Y'
         and ciqs.is_active = 'Y'
         and pcm.contract_type = 'BASEMETAL'
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and pcdi.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and pcdb.process_id = pc_process_id
         and pcpq.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and cipd.process_id = pc_process_id
         and ciqs.open_qty > 0
         and pci.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and md.valuation_dr_id = drm.dr_id(+)
         and ciqs.internal_contract_item_ref_no =
             ciscs.internal_contract_item_ref_no(+)
         and ciqs.process_id = ciscs.process_id(+);

    vn_m2m_amt                     number;
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vn_cont_price_cur_id_factor    number;
    vn_cont_price_cur_decimals     number;
    vn_contract_value_in_price_cur number;
    vn_forward_exch_rate           number;
    vn_contract_value_in_val_cur   number;
    vn_sc_in_base_cur              number;
    vn_sc_in_valuation_cur         number;
    vn_expected_cog_in_val_cur     number;
    vn_unrealized_pnl_in_val_cur   number;
    vn_unrealized_pnl_in_base_cur  number;
    vc_base_price_unit             varchar2(15);
    vn_qty_in_base                 number;
    vn_unrealized_pnl_in_m2m_unit  number;
    vc_m2m_price_unit_id           varchar2(15);
    vc_m2m_price_unit_cur_id       varchar2(15);
    vc_m2m_price_unit_cur_code     varchar2(15);
    vc_m2m_price_unit_wgt_unit_id  varchar2(15);
    vc_m2m_price_unit_wgt_unit     varchar2(15);
    vn_m2m_price_unit_wgt_unit_wt  number;
    vn_contract_premium            number;
    vn_contract_premium_value      number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_m2m_amount_in_base          number;
    vn_m2m_total_amount            number;
    vn_m2m_total_premium_amt       number;
    vn_fx_price_to_base            number;
    vn_cont_delivery_premium       number;
    vn_cont_del_premium_amt        number;
    vn_contract_value_in_base_cur  number;
    vc_del_premium_cur_id          varchar2(15);
    vc_del_premium_cur_code        varchar2(15);
    vc_del_premium_main_cur_id     varchar2(15);
    vc_del_premium_main_cur_code   varchar2(15);
    vn_del_premium_cur_main_factor number;
    vc_del_premium_weight_unit_id  varchar2(15);
    vn_del_premium_weight          number;
    vn_del_to_base_fw_rate         number;
    vn_forward_points              number;
    vc_qual_prem_exch_rate_string  varchar2(500);
    vc_error_msg                   varchar2(100);
    -- Variable for all exchange rate string start
    vc_price_to_base_fw_rate    varchar2(100);
    vc_m2m_to_base_fw_rate      varchar2(100);
    vc_m2m_ld_fw_exch_rate      varchar2(100);
    vc_m2m_qp_fw_exch_rate      varchar2(100);
    vc_m2m_pp_fw_exch_rate      varchar2(100);
    vc_contract_qp_fw_exch_rate varchar2(100);
    vc_contract_pp_fw_exch_rate varchar2(100);
    -- Variable for all exchange rate string end
  begin
    for cur_unrealized_rows in cur_unrealized
    loop
      vc_price_to_base_fw_rate    := null;
      vc_m2m_to_base_fw_rate      := null;
      vc_contract_qp_fw_exch_rate := null;
      vc_contract_pp_fw_exch_rate := null;
      vc_m2m_ld_fw_exch_rate      := cur_unrealized_rows.m2m_ld_fw_exch_rate;
      vc_m2m_qp_fw_exch_rate      := cur_unrealized_rows.m2m_qp_fw_exch_rate;
      vc_m2m_pp_fw_exch_rate      := cur_unrealized_rows.m2m_pp_fw_exch_rate;
      vc_error_msg                := '1';
      vn_cont_delivery_premium    := 0;
      vn_cont_del_premium_amt     := 0;
      vn_contract_premium         := 0;
      vn_contract_premium_value   := 0;

      vn_qty_in_base := round(pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                   cur_unrealized_rows.qty_unit_id,
                                                                   cur_unrealized_rows.base_qty_unit_id,
                                                                   1) *
                              cur_unrealized_rows.item_qty,
                              8);
      vn_m2m_amt     := nvl(cur_unrealized_rows.net_m2m_price, 0) /
                        nvl(cur_unrealized_rows.m2m_price_unit_weight, 1) *
                        pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                             cur_unrealized_rows.qty_unit_id,
                                                             cur_unrealized_rows.m2m_price_unit_weight_unit_id,
                                                             cur_unrealized_rows.item_qty);
      pkg_general.sp_get_main_cur_detail(nvl(cur_unrealized_rows.m2m_price_unit_cur_id,
                                             cur_unrealized_rows.base_cur_id),
                                         vc_m2m_cur_id,
                                         vc_m2m_cur_code,
                                         vn_m2m_sub_cur_id_factor,
                                         vn_m2m_cur_decimals);
      vn_m2m_amt   := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor, 2);
      vc_error_msg := '2';
      if cur_unrealized_rows.eval_basis <> 'FIXED' then
        pkg_general.sp_forward_cur_exchange_new(cur_unrealized_rows.corporate_id,
                                                pd_trade_date,
                                                cur_unrealized_rows.payment_due_date,
                                                vc_m2m_cur_id,
                                                cur_unrealized_rows.base_cur_id,
                                                30,
                                                vn_m2m_base_fx_rate,
                                                vn_m2m_base_deviation);

        if vc_m2m_cur_id <> cur_unrealized_rows.base_cur_id then
          if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
            vc_error_msg := '3';
            vobj_error_log.extend;
            vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                 'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                 'PHY-005',
                                                                 cur_unrealized_rows.base_cur_code ||
                                                                 ' to ' ||
                                                                 vc_m2m_cur_code || ' (' ||
                                                                 to_char(cur_unrealized_rows.payment_due_date,
                                                                         'dd-Mon-yyyy') || ') ',
                                                                 '',
                                                                 pc_process,
                                                                 pc_user_id,
                                                                 sysdate,
                                                                 pd_trade_date);
            sp_insert_error_log(vobj_error_log);
          else
            vc_error_msg := '4';
            if vn_m2m_base_fx_rate <> 1 then
              vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                        vn_m2m_base_fx_rate || ' ' ||
                                        cur_unrealized_rows.base_cur_code;
            end if;
          end if;

        else
          vn_m2m_base_fx_rate := 1;
        end if;
      else
        vn_m2m_amt          := 0;
        vn_m2m_base_fx_rate := 1;
      end if;
      vn_m2m_amount_in_base    := vn_m2m_amt * vn_m2m_base_fx_rate;
      vn_m2m_total_premium_amt := vn_qty_in_base *
                                  cur_unrealized_rows.total_premium;
      vn_m2m_total_amount      := vn_m2m_amount_in_base +
                                  vn_m2m_total_premium_amt;
      vc_error_msg             := '5';
      pkg_general.sp_get_main_cur_detail(cur_unrealized_rows.price_unit_cur_id,
                                         vc_price_cur_id,
                                         vc_price_cur_code,
                                         vn_cont_price_cur_id_factor,
                                         vn_cont_price_cur_decimals);

      vc_error_msg                   := '6';
      vn_contract_value_in_price_cur := (cur_unrealized_rows.contract_price /
                                        nvl(cur_unrealized_rows.price_unit_weight,
                                             1)) *
                                        (pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                              cur_unrealized_rows.qty_unit_id,
                                                                              cur_unrealized_rows.price_unit_weight_unit_id,
                                                                              cur_unrealized_rows.item_qty)) *
                                        vn_cont_price_cur_id_factor;

      pkg_general.sp_forward_cur_exchange_new(cur_unrealized_rows.corporate_id,
                                              pd_trade_date,
                                              cur_unrealized_rows.payment_due_date,
                                              vc_price_cur_id,
                                              cur_unrealized_rows.base_cur_id,
                                              30,
                                              vn_fx_price_to_base,
                                              vn_forward_exch_rate);
      vc_error_msg := '7';

      if vc_price_cur_id <> cur_unrealized_rows.base_cur_id then
        if vn_fx_price_to_base is null or vn_fx_price_to_base = 0 then
          vobj_error_log.extend;
          vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                               'procedure sp_calc_phy_open_unreal_pnl',
                                                               'PHY-005',
                                                               cur_unrealized_rows.base_cur_code ||
                                                               ' to ' ||
                                                               vc_price_cur_code || ' (' ||
                                                               to_char(cur_unrealized_rows.payment_due_date,
                                                                       'dd-Mon-yyyy') || ')',
                                                               '',
                                                               pc_process,
                                                               pc_user_id,
                                                               sysdate,
                                                               pd_trade_date);
          sp_insert_error_log(vobj_error_log);
        else
          vc_price_to_base_fw_rate := '1 ' || vc_price_cur_code || '=' ||
                                      vn_fx_price_to_base || ' ' ||
                                      cur_unrealized_rows.base_cur_code;
        end if;

      else
        vn_fx_price_to_base := 1;
      end if;

      vc_error_msg := '8';
      -- contract value in value currency will store the data in base currency
      vn_contract_value_in_price_cur := round(vn_contract_value_in_price_cur,
                                              2);

      vn_contract_value_in_val_cur := round(vn_contract_value_in_price_cur *
                                            nvl(vn_fx_price_to_base, 1),
                                            2);
      begin
        select ppu.product_price_unit_id
          into vc_base_price_unit
          from v_ppu_pum ppu
         where ppu.cur_id = cur_unrealized_rows.base_cur_id
           and ppu.weight_unit_id = cur_unrealized_rows.base_qty_unit_id
           and nvl(ppu.weight, 1) = 1
           and ppu.product_id = cur_unrealized_rows.product_id;
      exception
        when others then
          sp_write_log(pc_corporate_id,
                       pd_trade_date,
                       'sp_open_phy_unreal',
                       'vc_base_price_unit' || vc_base_price_unit || ' For' ||
                       cur_unrealized_rows.contract_ref_no);
      end;
      vn_contract_premium := 0;

      vc_error_msg := '9';
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_open_phy_unreal',
                   'QP in ' || vc_base_price_unit || ' For' ||
                   cur_unrealized_rows.contract_ref_no ||
                   cur_unrealized_rows.internal_contract_item_ref_no || ' ' ||
                   pd_trade_date || ' ' || cur_unrealized_rows.product_id ||
                   ' pc_process_id ' || pc_process_id);
      ------------------******** Premium Calculations starts here ******-------------------

      pkg_metals_general.sp_quality_premium_fw_rate(cur_unrealized_rows.internal_contract_item_ref_no,
                                                    pc_corporate_id,
                                                    pd_trade_date,
                                                    vc_base_price_unit,
                                                    cur_unrealized_rows.base_cur_id,
                                                    cur_unrealized_rows.payment_due_date,
                                                    cur_unrealized_rows.product_id,
                                                    cur_unrealized_rows.base_qty_unit_id,
                                                    pc_process_id,
                                                    vn_contract_premium,
                                                    vc_qual_prem_exch_rate_string);
      vc_error_msg                := '10';
      vc_contract_qp_fw_exch_rate := vc_qual_prem_exch_rate_string;

      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_open_phy_unreal',
                   'premium' || vc_base_price_unit || ' For' ||
                   cur_unrealized_rows.contract_ref_no ||
                   cur_unrealized_rows.internal_contract_item_ref_no ||
                   vn_contract_premium);
      -- Calculate contract delivery premium from pcdb
      if cur_unrealized_rows.delivery_premium <> 0 then
        if cur_unrealized_rows.delivery_premium_unit_id <>
           vc_base_price_unit then

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

          pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                  pd_trade_date,
                                                  cur_unrealized_rows.payment_due_date,
                                                  vc_del_premium_main_cur_id,
                                                  cur_unrealized_rows.base_cur_id,
                                                  30,
                                                  vn_del_to_base_fw_rate,
                                                  vn_forward_points);
          vc_error_msg := '13';

          vn_cont_delivery_premium := (cur_unrealized_rows.delivery_premium /
                                      vn_del_premium_weight) *
                                      vn_del_premium_cur_main_factor *
                                      vn_del_to_base_fw_rate *
                                      pkg_general.f_get_converted_quantity(cur_unrealized_rows.product_id,
                                                                           vc_del_premium_weight_unit_id,
                                                                           cur_unrealized_rows.base_qty_unit_id,
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

      vc_error_msg              := '15';
      vn_contract_premium_value := round((vn_contract_premium *
                                         vn_qty_in_base) +
                                         vn_cont_del_premium_amt,
                                         2);
      sp_write_log(pc_corporate_id,
                   pd_trade_date,
                   'sp_open_phy_unreal',
                   'vn_contract_premium_value ' || vc_base_price_unit ||
                   ' For' || cur_unrealized_rows.contract_ref_no ||
                   cur_unrealized_rows.internal_contract_item_ref_no ||
                   ' =  ' || vn_contract_premium_value);
      ------------------******** Premium Calculations ends here ******-------------------
      ---- Add premium to contract value,as vn_contract_value_in_val_cur is in base currency and vn_contract_premium_value also in base currency
      vn_contract_value_in_base_cur := vn_contract_value_in_val_cur;
      vn_contract_value_in_val_cur  := vn_contract_value_in_val_cur +
                                       vn_contract_premium_value;
      vn_sc_in_base_cur             := round(cur_unrealized_rows.sc_in_base_cur *
                                             vn_qty_in_base,
                                             2);
      vn_sc_in_valuation_cur        := vn_sc_in_base_cur;

      -- as per the current implementation in basemetals, there is not Income/expense accruals separately
      -- so we need to ass conract value + SC  - done as on 05-Jul-2011, once we implement the
      -- Income/expense accruals separately, we have to remove the abs from SC.
      -- vn_contract_value_in_val_cur := vn_contract_value_in_val_cur;
      vn_expected_cog_in_val_cur := round((abs(vn_contract_value_in_val_cur) +
                                          abs(vn_sc_in_valuation_cur)),
                                          2);

      if cur_unrealized_rows.purchase_sales = 'P' then
        vn_unrealized_pnl_in_val_cur := round((vn_m2m_total_amount -
                                              vn_expected_cog_in_val_cur),
                                              2);
      else
        vn_unrealized_pnl_in_val_cur := round((vn_expected_cog_in_val_cur -
                                              vn_m2m_total_amount),
                                              2);
      end if;
      vc_error_msg                  := '16';
      vn_unrealized_pnl_in_base_cur := vn_unrealized_pnl_in_val_cur;

      -- below variable set as zero as it's not used in any calculation.
      vn_unrealized_pnl_in_m2m_unit := 0;
      vc_m2m_price_unit_id          := cur_unrealized_rows.m2m_price_unit_id;
      vc_m2m_price_unit_cur_id      := cur_unrealized_rows.m2m_price_unit_cur_id;
      vc_m2m_price_unit_cur_code    := cur_unrealized_rows.m2m_price_unit_cur_code;
      vc_m2m_price_unit_wgt_unit_id := cur_unrealized_rows.m2m_price_unit_weight_unit_id;
      vc_m2m_price_unit_wgt_unit    := cur_unrealized_rows.m2m_price_unit_weight_unit;
      vn_m2m_price_unit_wgt_unit_wt := cur_unrealized_rows.m2m_price_unit_weight;

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
         m2m_to_base_fw_exch_rate,
         m2m_ld_fw_exch_rate,
         m2m_qp_fw_exch_rate,
         m2m_pp_fw_exch_rate,
         contract_qp_fw_exch_rate,
         contract_pp_fw_exch_rate,
         accrual_to_base_fw_exch_rate,
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
         cur_unrealized_rows.approval_status, ----
         cur_unrealized_rows.unrealized_type,
         cur_unrealized_rows.profit_center_id,
         cur_unrealized_rows.profit_center_name,
         cur_unrealized_rows.profit_center_short_name,
         cur_unrealized_rows.cp_id,
         cur_unrealized_rows.cp_name,
         cur_unrealized_rows.trader_id,
         cur_unrealized_rows.trader_user_name,
         cur_unrealized_rows.product_id,
         cur_unrealized_rows.product_name,
         cur_unrealized_rows.item_qty,
         cur_unrealized_rows.qty_unit_id,
         cur_unrealized_rows.qty_unit,
         cur_unrealized_rows.quality_template_id,
         cur_unrealized_rows.quality_name,
         cur_unrealized_rows.product_desc,
         cur_unrealized_rows.price_basis,
         cur_unrealized_rows.price_type_name,
         cur_unrealized_rows.price_description,
         cur_unrealized_rows.item_delivery_period_string,
         cur_unrealized_rows.fixation_method,
         cur_unrealized_rows.price_fixation_status,
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
         cur_unrealized_rows.price_fixation_details,
         cur_unrealized_rows.contract_price,
         cur_unrealized_rows.price_unit_id,
         cur_unrealized_rows.price_unit_cur_id,
         cur_unrealized_rows.price_unit_cur_code,
         cur_unrealized_rows.price_unit_weight_unit_id,
         cur_unrealized_rows.price_unit_weight,
         cur_unrealized_rows.price_unit_weight_unit,
         cur_unrealized_rows.net_m2m_price,
         vc_m2m_price_unit_id,
         vc_m2m_price_unit_cur_id,
         vc_m2m_price_unit_cur_code,
         vn_m2m_price_unit_wgt_unit_wt,
         vc_m2m_price_unit_wgt_unit_id,
         vc_m2m_price_unit_wgt_unit,
         vn_contract_value_in_price_cur,
         vn_contract_value_in_val_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vc_m2m_price_unit_cur_id, -- valuation cur_id
         vc_m2m_price_unit_cur_code, -- valuation cur_code
         vn_m2m_total_amount,
         cur_unrealized_rows.base_cur_id,
         cur_unrealized_rows.base_cur_code,
         --  vc_m2m_cur_id,
         -- vc_m2m_cur_id,
         vn_sc_in_base_cur,
         vn_sc_in_valuation_cur,
         vn_contract_premium_value, -- contract premium value
         cur_unrealized_rows.base_cur_id, -- premium cur_id
         cur_unrealized_rows.base_cur_code, --premium cur_code
         vn_expected_cog_in_val_cur, -- expected_cog_net_sale_value
         vn_unrealized_pnl_in_val_cur,
         vn_unrealized_pnl_in_base_cur,
         0, --prev_day_unr_pnl_in_val_cur
         0, --prev_day_unr_pnl_in_base_cur
         0, --trade_day_pnl_in_val_cur
         0, --trade_day_pnl_in_base_cur
         cur_unrealized_rows.base_cur_id,
         cur_unrealized_rows.base_cur_code,
         vn_expected_cog_in_val_cur,
         null, -- vn_fw_fx_price_cur_to_m2m_cur,
         vn_fx_price_to_base, --price_cur_to_base_cur_fx_rate
         null, -- vn_base_to_val_fx_rate, --base_cur_to_val_cur_fx_rate
         null, --vn_val_to_base_corp_fx_rate, --val_to_base_corp_fx_rate
         vn_m2m_base_fx_rate, --spot_rate_val_cur_to_base_cur
         vn_unrealized_pnl_in_m2m_unit, --unrealized_pnl_in_m2m_price_id
         0, --prev_unr_pnl_in_m2m_price_id
         0, --trade_day_pnl_in_m2m_price_id
         null, --realized_date
         null, --realized_price
         null, --realized_price_id
         null, --realized_price_cur_id
         null, --realized_price_cur_code
         null, --realized_price_weight
         null, --realized_price_weight_unit
         null, --realized_qty
         null, --realized_qty_id
         null, --realized_qty_unit
         cur_unrealized_rows.md_id,
         cur_unrealized_rows.groupid,
         cur_unrealized_rows.groupname,
         cur_unrealized_rows.cur_id_gcd,
         cur_unrealized_rows.cur_code_gcd,
         cur_unrealized_rows.qty_unit_id_gcd,
         cur_unrealized_rows.qty_unit_gcd,
         cur_unrealized_rows.base_qty_unit_id,
         cur_unrealized_rows.base_qty_unit,
         null, --prev_item_qty
         null, --prev_qty_unit_id
         null, --cont_unr_status
         cur_unrealized_rows.unfxd_qty,
         cur_unrealized_rows.fxd_qty,
         vn_qty_in_base,
         cur_unrealized_rows.eod_trade_date,
         cur_unrealized_rows.strategy_id,
         cur_unrealized_rows.strategy_name,
         cur_unrealized_rows.derivative_def_id,
         cur_unrealized_rows.valuation_exchange_id,
         cur_unrealized_rows.valuation_dr_id,
         cur_unrealized_rows.dr_id_name,
         cur_unrealized_rows.valuation_month,
         null, --price_month
         null, --pay_in_cur_id
         null, --pay_in_cur_code
         vn_unrealized_pnl_in_base_cur /
         decode(vn_qty_in_base, 0, 1, vn_qty_in_base), --unreal_pnl_in_base_per_unit
         vn_unrealized_pnl_in_val_cur /
         decode(vn_qty_in_base, 0, 1, vn_qty_in_base), --unreal_pnl_in_val_cur_per_unit
         null, --realized_internal_stock_ref_no
         null, --sales_internal_gmr_ref_no
         null, -- sales_gmr_ref_no
         vc_price_to_base_fw_rate,
         vc_m2m_to_base_fw_rate,
         vc_m2m_ld_fw_exch_rate,
         vc_m2m_qp_fw_exch_rate,
         vc_m2m_pp_fw_exch_rate,
         vc_contract_qp_fw_exch_rate,
         vc_contract_pp_fw_exch_rate,
         cur_unrealized_rows.accrual_to_base_fw_exch_rate,
         cur_unrealized_rows.contract_status,
         cur_unrealized_rows.approval_flag);
      dbms_output.put_line('vc_price_to_base_fw_rate' ||
                           vc_price_to_base_fw_rate);
    end loop;
    ---------
    commit;
    sp_gather_stats('poud_phy_open_unreal_daily');

    vc_error_msg := '17';
    begin
      -- update previous eod data
      for cur_update in (select poud_prev_day.internal_contract_item_ref_no,
                                poud_prev_day.unreal_pnl_in_base_per_unit,
                                poud_prev_day.unreal_pnl_in_val_cur_per_unit,
                                poud_prev_day.unrealized_pnl_in_m2m_price_id,
                                poud_prev_day.item_qty,
                                poud_prev_day.qty_unit_id,
                                poud_prev_day.unrealized_type,
                                poud_prev_day.m2m_amt_cur_id
                           from poud_phy_open_unreal_daily poud_prev_day
                          where poud_prev_day.process_id =
                                pc_previous_process_id
                            and corporate_id = pc_corporate_id)
      loop
        update poud_phy_open_unreal_daily poud_today
           set poud_today.prev_day_unr_pnl_in_base_cur = cur_update.unreal_pnl_in_base_per_unit *
                                                         poud_today.qty_in_base_unit,
               poud_today.prev_day_unr_pnl_in_val_cur  = pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                                                  cur_update.m2m_amt_cur_id,
                                                                                                  poud_today.m2m_amt_cur_id,
                                                                                                  pd_trade_date,
                                                                                                  cur_update.unreal_pnl_in_val_cur_per_unit),
               poud_today.prev_unr_pnl_in_m2m_price_id = cur_update.unrealized_pnl_in_m2m_price_id,
               poud_today.prev_item_qty                = cur_update.item_qty,
               poud_today.prev_qty_unit_id             = cur_update.qty_unit_id,
               poud_today.cont_unr_status              = 'EXISTING_TRADE'
         where poud_today.internal_contract_item_ref_no =
               cur_update.internal_contract_item_ref_no
           and poud_today.process_id = pc_process_id
           and poud_today.unrealized_type = cur_update.unrealized_type
           and poud_today.corporate_id = pc_corporate_id;
      end loop;
    exception
      when others then
        dbms_output.put_line('SQLERRM-1' || sqlerrm);
    end;

    vc_error_msg := '18';
    -- mark the trades came as new in this eod/eom
    begin
      update poud_phy_open_unreal_daily poud
         set poud.cont_unr_status = 'NEW_TRADE'
       where poud.cont_unr_status is null
         and poud.process_id = pc_process_id
         and poud.corporate_id = pc_corporate_id;
    exception
      when others then
        dbms_output.put_line('SQLERRM-2' || sqlerrm);
    end;
    vc_error_msg := '19';
    update poud_phy_open_unreal_daily poud
       set poud.trade_day_pnl_in_val_cur  = nvl(poud.unrealized_pnl_in_val_cur,
                                                0) - nvl(poud.prev_day_unr_pnl_in_val_cur,
                                                         0),
           poud.trade_day_pnl_in_base_cur = nvl(poud.unrealized_pnl_in_base_cur,
                                                0) - nvl(poud.prev_day_unr_pnl_in_base_cur,
                                                         0)
     where poud.process_id = pc_process_id
       and poud.corporate_id = pc_corporate_id
       and poud.unrealized_type = 'Unrealized';
  exception
    when others then
      dbms_output.put_line('failed with ' || sqlerrm);
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_calc_phy_open_unreal_pnl',
                                                           'M2M-013',
                                                           'Code:' ||
                                                           sqlcode ||
                                                           'Message:' ||
                                                           sqlerrm || ' ' ||
                                                           vc_error_msg,
                                                           '',
                                                           pc_process,
                                                           pc_user_id,
                                                           sysdate,
                                                           pd_trade_date);
      sp_insert_error_log(vobj_error_log);
  end;

  procedure sp_stock_unreal_sntt_bm(pc_corporate_id        varchar2,
                                    pd_trade_date          date,
                                    pc_process_id          varchar2,
                                    pc_user_id             varchar2,
                                    pc_process             varchar2,
                                    pc_previous_process_id varchar2) as
    cursor cur_grd is
    -- Purchase Shipped But Not TT
      select 'Purchase' section_type,
             pcpd.profit_center_id profit_center,
             pc_process_id process_id,
             gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             grd.internal_contract_item_ref_no,
             pcm.purchase_sales,
             grd.product_id,
             pdm.product_desc product_name,
             grd.origin_id,
             orm.origin_name,
             qat.quality_id,
             qat.quality_name,
             grd.container_no,
             grd.current_qty stock_qty,
             grd.qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
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
             nvl(gpd.contract_price, spd.stock_price) contract_price,
             nvl(gpd.price_unit_id, spd.price_unit_id) price_unit_id,
             nvl(gpd.price_unit_weight_unit_id,
                 spd.price_unit_weight_unit_id) price_unit_weight_unit_id,
             nvl(gpd.price_unit_weight, spd.price_unit_weight) price_unit_weight,
             nvl(gpd.price_unit_cur_id, spd.price_unit_cur_id) price_unit_cur_id,
             nvl(gpd.price_unit_cur_code, spd.price_unit_cur_code) price_unit_cur_code,
             nvl(gpd.price_unit_weight_unit, spd.price_unit_weight_unit) price_unit_weight_unit,
             nvl(gpd.price_fixation_status, cipd.price_fixation_details) price_fixation_details,
             nvl(cipd.payment_due_date, pd_trade_date) payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
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
             cipd.price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             cipd.price_fixation_status price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             pcpd.strategy_id,
             css.strategy_name,
             (ciqs.total_qty - nvl(ciqs.price_fixed_qty, 0)) unfxd_qty,
             ciqs.price_fixed_qty fxd_qty,
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
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             qat.eval_basis,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             gpd.price_fixation_status gmr_price_fixation_status,
             nvl(gscs.avg_cost_fw_rate, 0) noncog_secondary_cost_per_unit,
             cipd.price_description cipd_price_description,
             null as gpd_price_description,
             pci.expected_delivery_month || '-' ||
             pci.expected_delivery_year item_delivery_period_string,
             decode(grd.partnership_type, 'Consignment', 'Y', 'N') as is_marked_for_consignment,
             gmr.vessel_name,
             md.m2m_pp_fw_exch_rate,
             md.m2m_ld_fw_exch_rate,
             md.m2m_qp_fw_exch_rate,
             gscs.fw_rate_string accrual_to_base_fw_exch_rate,
             pcm.cp_id,
             phd_cp.companyname cp_name
        from gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             gpd_gmr_price_daily gpd,
             pcm_physical_contract_main pcm,
             pcpd_pc_product_definition pcpd,
             pdm_productmaster pdm,
             orm_origin_master orm,
             qat_quality_attributes qat,
             qum_quantity_unit_master qum,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name <> 'OPEN') tmpc,
             cipd_contract_item_price_daily cipd,
             ak_corporate akc,
             cm_currency_master cm,
             gsm_gmr_stauts_master gsm,
             pci_physical_contract_item pci,
             pcdb_pc_delivery_basis pcdb,
             ciqs_contract_item_qty_status ciqs,
             css_corporate_strategy_setup css,
             gscs_gmr_sec_cost_summary gscs,
             phd_profileheaderdetails phd_cp,
             spd_stock_price_daily spd
       where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and grd.product_id = pdm.product_id
         and grd.origin_id = orm.origin_id(+)
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
         and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
         and grd.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.quality_id = qat.quality_id(+)
         and grd.qty_unit_id = qum.qty_unit_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and grd.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and grd.process_id = cipd.process_id
         and cipd.internal_contract_ref_no = pcm.internal_contract_ref_no
         and grd.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.pcdb_id = pcdb.pcdb_id
         and pci.process_id = pcdb.process_id
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.status_id = gsm.status_id(+)
         and pcpd.strategy_id = css.strategy_id
         and grd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and cipd.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and spd.process_id = pc_process_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and gmr.corporate_id = pc_corporate_id
         and grd.status = 'Active'
         and grd.is_deleted = 'N'
         and gmr.is_deleted = 'N'
         and nvl(grd.inventory_status, 'NA') = 'NA'
         and pcm.purchase_sales = 'P'
         and nvl(grd.current_qty, 0) > 0
         and gmr.is_internal_movement = 'N'
         and pcm.cp_id = phd_cp.profileid
         and gmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
         and gmr.process_id = gscs.process_id(+)
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and grd.process_id = pci.process_id
         and spd.internal_drg_dgrd_ref_no = grd.internal_grd_ref_no
      union all
      select 'Sales' section_type,
             pcpd.profit_center_id profit_center,
             pc_process_id process_id,
             gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             dgrd.internal_contract_item_ref_no,
             pcm.purchase_sales,
             dgrd.product_id,
             pdm.product_desc product_name,
             dgrd.origin_id,
             orm.origin_name,
             tmpc.quality_id,
             qat.quality_name,
             '' container_no,
             dgrd.net_weight stock_qty,
             dgrd.net_weight_unit_id qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
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
             nvl(gpd.contract_price, spd.stock_price) contract_price,
             nvl(gpd.price_unit_id, spd.price_unit_id) price_unit_id,
             nvl(gpd.price_unit_weight_unit_id,
                 spd.price_unit_weight_unit_id) price_unit_weight_unit_id,
             nvl(gpd.price_unit_weight, spd.price_unit_weight) price_unit_weight,
             nvl(gpd.price_unit_cur_id, spd.price_unit_cur_id) price_unit_cur_id,
             nvl(gpd.price_unit_cur_code, spd.price_unit_cur_code) price_unit_cur_code,
             nvl(gpd.price_unit_weight_unit, spd.price_unit_weight_unit) price_unit_weight_unit,
             nvl(gpd.price_fixation_status, cipd.price_fixation_details) price_fixation_details,
             nvl(cipd.payment_due_date, pd_trade_date) payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
             gmr.inventory_status,
             gsm.status shipment_status,
             (case
               when nvl(dgrd.inventory_status, 'NA') = 'Under CMA' then
                'UnderCMA NTT'
               when nvl(dgrd.is_afloat, 'N') = 'Y' and
                    nvl(dgrd.inventory_status, 'NA') in ('In', 'None', 'NA') then
                'Shipped NTT'
               when nvl(dgrd.is_afloat, 'N') = 'Y' and
                    nvl(dgrd.inventory_status, 'NA') = 'Out' then
                'Shipped TT'
               when nvl(dgrd.is_afloat, 'N') = 'N' and
                    nvl(dgrd.inventory_status, 'NA') in ('In', 'None', 'NA') then
                'Stock NTT'
               when nvl(dgrd.is_afloat, 'N') = 'N' and
                    nvl(dgrd.inventory_status, 'NA') = 'Out' then
                'Stock TT'
               else
                'Others'
             end) section_name,
             cipd.price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             cipd.price_fixation_status price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             pcpd.strategy_id,
             css.strategy_name,
             (ciqs.total_qty - nvl(ciqs.price_fixed_qty, 0)) unfxd_qty,
             ciqs.price_fixed_qty fxd_qty,
             md.valuation_exchange_id,
             md.valuation_month,
             md.derivative_def_id,
             nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
             gmr.contract_type gmr_contract_type,
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
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             qat.eval_basis,
             nvl(pcdb.premium, 0) delivery_premium,
             pcdb.premium_unit_id delivery_premium_unit_id,
             gpd.price_fixation_status gmr_price_fixation_status,
             nvl(gscs.avg_cost_fw_rate, 0) noncog_secondary_cost_per_unit,
             cipd.price_description cipd_price_description,
             null as gpd_price_description,
             pci.expected_delivery_month || '-' ||
             pci.expected_delivery_year item_delivery_period_string,
             decode(dgrd.partnership_type, 'Consignment', 'Y', 'N') as is_marked_for_consignment,
             gmr.vessel_name,
             md.m2m_pp_fw_exch_rate,
             md.m2m_ld_fw_exch_rate,
             md.m2m_qp_fw_exch_rate,
             gscs.fw_rate_string accrual_to_base_fw_exch_rate,
             pcm.cp_id,
             phd_cp.companyname cp_name
        from gmr_goods_movement_record gmr,
             gpd_gmr_price_daily gpd,
             dgrd_delivered_grd dgrd,
             agh_alloc_group_header agh,
             pcm_physical_contract_main pcm,
             pcpd_pc_product_definition pcpd,
             pdm_productmaster pdm,
             orm_origin_master orm,
             qat_quality_attributes qat,
             qum_quantity_unit_master qum,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name <> 'OPEN') tmpc,
             cipd_contract_item_price_daily cipd,
             ak_corporate akc,
             gsm_gmr_stauts_master gsm,
             ciqs_contract_item_qty_status ciqs,
             pci_physical_contract_item pci,
             pcdb_pc_delivery_basis pcdb,
             cm_currency_master cm,
             css_corporate_strategy_setup css,
             spd_stock_price_daily spd,
             phd_profileheaderdetails phd_cp,
             gscs_gmr_sec_cost_summary gscs
       where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
         and dgrd.product_id = pdm.product_id
         and dgrd.origin_id = orm.origin_id(+)
         and dgrd.int_alloc_group_id = agh.int_alloc_group_id
         and dgrd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and dgrd.internal_dgrd_ref_no = tmpc.internal_grd_ref_no(+)
         and dgrd.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.quality_id = qat.quality_id(+)
         and dgrd.net_weight_unit_id = qum.qty_unit_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and dgrd.internal_contract_item_ref_no =
             cipd.internal_contract_item_ref_no
         and dgrd.process_id = cipd.process_id
         and cipd.internal_contract_ref_no = pcm.internal_contract_ref_no
         and cipd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and pci.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and cm.cur_code = akc.base_currency_name
         and gmr.status_id = gsm.status_id(+)
         and pcpd.strategy_id = css.strategy_id
         and pci.pcdb_id = pcdb.pcdb_id
         and pci.process_id = pcdb.process_id
         and pcm.purchase_sales = 'S'
         and pcm.cp_id = phd_cp.profileid
         and gsm.is_required_for_m2m = 'Y'
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and gmr.is_deleted = 'N'
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and upper(dgrd.realized_status) in
             ('UNREALIZED', 'UNDERCMA', 'REVERSEREALIZED', 'REVERSEUNDERCMA')
         and dgrd.status = 'Active'
         and nvl(dgrd.net_weight, 0) > 0
         and dgrd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and cipd.process_id = pc_process_id
         and agh.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and agh.is_deleted = 'N'
         and gmr.corporate_id = pc_corporate_id
         and gmr.is_internal_movement = 'N'
         and nvl(gmr.inventory_status, 'NA') <> 'Out'
         and spd.internal_drg_dgrd_ref_no = dgrd.internal_dgrd_ref_no
         and spd.process_id = pc_process_id
         and dgrd.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
         and dgrd.process_id = gscs.process_id(+)
      union all
      -- Internal Movement Shipped But Not TT
      select 'Internal Movement' section_type,
             grd.profit_center_id profit_center,
             pc_process_id process_id,
             gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             grd.internal_contract_item_ref_no,
             (case
               when gmr.contract_type = 'Purchase' then
                'P'
               when gmr.contract_type = 'Sales' then
                'S'
               else
                'P'
             end) purchase_sales,
             grd.product_id,
             pdm.product_desc product_name,
             grd.origin_id,
             orm.origin_name,
             qat.quality_id,
             qat.quality_name,
             grd.container_no,
             grd.current_qty stock_qty,
             grd.qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
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
             nvl(gpd.contract_price, spd.stock_price) contract_price,
             nvl(gpd.price_unit_id, spd.price_unit_id) price_unit_id,
             nvl(gpd.price_unit_weight_unit_id,
                 spd.price_unit_weight_unit_id) price_unit_weight_unit_id,
             nvl(gpd.price_unit_weight, spd.price_unit_weight) price_unit_weight,
             nvl(gpd.price_unit_cur_id, spd.price_unit_cur_id) price_unit_cur_id,
             nvl(gpd.price_unit_cur_code, spd.price_unit_cur_code) price_unit_cur_code,
             nvl(gpd.price_unit_weight_unit, spd.price_unit_weight_unit) price_unit_weight_unit,
             null price_fixation_details,
             pd_trade_date payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
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
             null price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             null price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             grd.strategy_id strategy_id,
             css.strategy_name strategy_name,
             null unfxd_qty,
             null fxd_qty,
             md.valuation_exchange_id,
             md.valuation_month,
             md.derivative_def_id,
             nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
             gmr.contract_type gmr_contract_type,
             grd.internal_grd_ref_no internal_grd_dgrd_ref_no,
             grd.internal_stock_ref_no stock_ref_no,
             gmr.created_by trader_id,
             (case
               when gmr.created_by is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook gab,
                        ak_corporate_user     aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = gmr.created_by)
               else
                ''
             end) trader_user_name,
             md.m2m_loc_incoterm_deviation,
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             qat.eval_basis,
             null delivery_premium,
             null delivery_premium_unit_id,
             gpd.price_fixation_status gmr_price_fixation_status,
             nvl(gscs.avg_cost_fw_rate, 0) noncog_secondary_cost_per_unit,
             null cipd_price_description,
             null as gpd_price_description,
             null item_delivery_period_string,
             decode(grd.partnership_type, 'Consignment', 'Y', 'N') as is_marked_for_consignment,
             gmr.vessel_name,
             md.m2m_pp_fw_exch_rate,
             md.m2m_ld_fw_exch_rate,
             md.m2m_qp_fw_exch_rate,
             gscs.fw_rate_string accrual_to_base_fw_exch_rate,
             null cp_id,
             null cp_name
        from gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             gpd_gmr_price_daily gpd,
             pdm_productmaster pdm,
             orm_origin_master orm,
             qum_quantity_unit_master qum,
             qat_quality_attributes qat,
             ak_corporate akc,
             cm_currency_master cm,
             gsm_gmr_stauts_master gsm,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name <> 'OPEN') tmpc,
             gscs_gmr_sec_cost_summary gscs,
             spd_stock_price_daily spd,
             css_corporate_strategy_setup css
       where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.process_id = gpd.process_id(+)
         and grd.origin_id = orm.origin_id(+)
         and grd.qty_unit_id = qum.qty_unit_id(+)
         and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
         and tmpc.quality_id = qat.quality_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.status_id = gsm.status_id(+)
         and grd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and gmr.corporate_id = pc_corporate_id
         and grd.status = 'Active'
         and grd.is_deleted = 'N'
         and gmr.is_deleted = 'N'
         and nvl(grd.inventory_status, 'NA') = 'NA'
         and nvl(grd.current_qty, 0) > 0
         and gmr.is_internal_movement = 'Y'
         and gmr.internal_gmr_ref_no = gscs.internal_gmr_ref_no(+)
         and gmr.process_id = gscs.process_id(+)
         and spd.internal_drg_dgrd_ref_no = grd.internal_grd_ref_no
         and spd.process_id = pc_process_id
         and grd.strategy_id = css.strategy_id(+);
    vn_qty_in_base                 number;
    vn_m2m_amt                     number;
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_contract_value_in_price_cur number;
    vn_cont_price_cur_decimals     number;
    vn_contract_value_in_val_cur   number;
    vn_contract_value_in_base_cur  number;
    vc_m2m_price_unit_str          varchar2(100);
    vc_m2m_price_unit_id           varchar2(15);
    vc_m2m_price_unit_cur_id       varchar2(15);
    vn_ratio                       number;
    vn_corp_rate_val_to_base_cur   number;
    vn_spot_rate_base_to_val_cur   number;
    vn_expected_cog_net_sale_value number;
    vn_expected_cog_in_val_cur     number;
    vn_pnl_in_val_cur              number;
    vn_pnl_in_base_cur             number;
    vn_pnl_per_base_unit           number;
    vc_psu_id                      varchar2(500);
    vn_pnl_in_exch_price_unit      number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_m2m_amount_in_base          number;
    vn_m2m_total_amount            number;
    vn_m2m_total_premium_amt       number;
    vn_fx_price_to_base            number;
    vn_fx_price_deviation          number;
    vn_total_premium_value         number;
    vn_quality_premium             number;
    vn_product_premium             number;
    vn_product_premium_amt         number;
    vc_base_price_unit_id          varchar2(20);
    vn_m2m_amt_per_unit            number;
    vn_cont_price                  number;
    vc_cont_price_unit_id          varchar2(15);
    vc_cont_price_unit_cur_id      varchar2(15);
    vc_cont_price_unit_cur_code    varchar2(15);
    vn_cont_price_wt               number;
    vc_cont_price_wt_unit_id       varchar2(15);
    vc_cont_price_wt_unit          varchar2(15);
    vn_sc_in_base_cur              number;
    vc_price_fixation_status       varchar2(50);
    vc_error_msg                   varchar2(100);
    vn_trade_day_pnl_per_base_unit number;
    vc_price_string                varchar2(500);
    vc_del_premium_cur_id          varchar2(15);
    vc_del_premium_cur_code        varchar2(15);
    vc_del_premium_main_cur_id     varchar2(15);
    vc_del_premium_main_cur_code   varchar2(15);
    vn_del_premium_cur_main_factor number;
    vc_del_premium_weight_unit_id  varchar2(15);
    vn_del_premium_weight          number;
    vn_del_to_base_fw_rate         number;
    vn_forward_points              number;
    vc_qual_prem_exch_rate_string  varchar2(500);
    -- Variable for all exchange rate string start
    vc_price_to_base_fw_rate    varchar2(100);
    vc_m2m_to_base_fw_rate      varchar2(100);
    vc_m2m_ld_fw_exch_rate      varchar2(100);
    vc_m2m_qp_fw_exch_rate      varchar2(100);
    vc_m2m_pp_fw_exch_rate      varchar2(100);
    vc_contract_qp_fw_exch_rate varchar2(100);
    vc_contract_pp_fw_exch_rate varchar2(100);
    -- Variable for all exchange rate string end
  begin
    for cur_grd_rows in cur_grd
    loop
      vc_price_to_base_fw_rate    := null;
      vc_m2m_to_base_fw_rate      := null;
      vc_contract_qp_fw_exch_rate := null;
      vc_contract_pp_fw_exch_rate := null;

      vc_m2m_ld_fw_exch_rate := cur_grd_rows.m2m_ld_fw_exch_rate;
      vc_m2m_qp_fw_exch_rate := cur_grd_rows.m2m_qp_fw_exch_rate;
      vc_m2m_pp_fw_exch_rate := cur_grd_rows.m2m_pp_fw_exch_rate;

      vn_product_premium            := 0;
      vn_product_premium_amt        := 0;
      vn_quality_premium            := 0;
      vn_contract_value_in_base_cur := 0;
      vn_total_premium_value        := 0;
      vn_cont_price                 := 0;
      vc_cont_price_unit_id         := null;
      vc_cont_price_unit_cur_id     := null;
      vc_cont_price_unit_cur_code   := null;
      vn_cont_price_wt              := 1;
      vc_cont_price_wt_unit_id      := null;
      vc_cont_price_wt_unit         := null;
      vc_price_fixation_status      := null;
      if cur_grd_rows.gpd_price_description is null then
        vc_price_string := cur_grd_rows.cipd_price_description;
      else
        vc_price_string := cur_grd_rows.gpd_price_description;
      end if;
      if cur_grd_rows.gmr_price_fixation_status is null then
        vc_price_fixation_status := cur_grd_rows.price_fixation_status;
      else
        vc_price_fixation_status := cur_grd_rows.gmr_price_fixation_status;
      end if;
      vn_cont_price               := cur_grd_rows.contract_price;
      vc_cont_price_unit_id       := cur_grd_rows.price_unit_id;
      vc_cont_price_unit_cur_id   := cur_grd_rows.price_unit_cur_id;
      vc_cont_price_unit_cur_code := cur_grd_rows.price_unit_cur_code;
      vn_cont_price_wt            := cur_grd_rows.price_unit_weight;
      vc_cont_price_wt_unit_id    := cur_grd_rows.price_unit_weight_unit_id;
      vc_cont_price_wt_unit       := cur_grd_rows.price_unit_weight_unit;

      vc_error_msg := vn_cont_price || vc_cont_price_unit_id;
      if cur_grd_rows.stock_qty <> 0 then
        vc_psu_id      := cur_grd_rows.internal_gmr_ref_no || '-' ||
                          cur_grd_rows.internal_grd_dgrd_ref_no || '-' ||
                          cur_grd_rows.internal_contract_item_ref_no || '-' ||
                          cur_grd_rows.container_no;
        vc_error_msg   := '1';
        vn_qty_in_base := cur_grd_rows.stock_qty *
                          pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                               cur_grd_rows.qty_unit_id,
                                                               cur_grd_rows.base_qty_unit_id,
                                                               1);
        vc_error_msg   := '2';
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
                                                                           cur_grd_rows.qty_unit_id,
                                                                           cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                           cur_grd_rows.stock_qty);
        end if;
        vc_error_msg := '3';
        pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_m2m_cur_id,
                                           vc_m2m_cur_code,
                                           vn_m2m_sub_cur_id_factor,
                                           vn_m2m_cur_decimals);
        vn_m2m_amt   := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor, 2);
        vc_error_msg := '4';
        if cur_grd_rows.eval_basis <> 'FIXED' then
          --
          -- Forwad Rate from Valuation to Base Currency
          --
          pkg_general.sp_forward_cur_exchange_new(cur_grd_rows.corporate_id,
                                                  pd_trade_date,
                                                  cur_grd_rows.payment_due_date,
                                                  nvl(vc_m2m_cur_id,
                                                      cur_grd_rows.base_cur_id),
                                                  cur_grd_rows.base_cur_id,
                                                  30,
                                                  vn_m2m_base_fx_rate,
                                                  vn_m2m_base_deviation);
          vc_error_msg := '5';
          if (vn_m2m_base_fx_rate <> 0 or vn_m2m_base_fx_rate <> 1 or
             vn_m2m_base_fx_rate is not null) then
            if vc_m2m_cur_code <> cur_grd_rows.base_cur_code then
              vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                        vn_m2m_base_fx_rate || ' ' ||
                                        cur_grd_rows.base_cur_code;
            end if;
          end if;
          if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
            if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                   'PHY-005',
                                                                   cur_grd_rows.base_cur_code ||
                                                                   ' to ' ||
                                                                   vc_m2m_cur_code || ' (' ||
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
          vn_m2m_base_fx_rate := 1;
        end if;
        vn_m2m_amount_in_base    := vn_m2m_amt * vn_m2m_base_fx_rate;
        vn_m2m_total_premium_amt := vn_qty_in_base *
                                    cur_grd_rows.total_premium;
        vn_m2m_total_amount      := vn_m2m_amount_in_base +
                                    vn_m2m_total_premium_amt;
        vc_error_msg             := '6';
        vn_m2m_amt_per_unit      := round(vn_m2m_total_amount /
                                          vn_qty_in_base,
                                          8);
        pkg_general.sp_get_main_cur_detail(nvl(vc_cont_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
        vc_error_msg := '7';
        if nvl(vn_cont_price, 0) <> 0 and
           vc_cont_price_wt_unit_id is not null then
          vc_error_msg                   := '8';
          vn_contract_value_in_price_cur := (vn_cont_price /
                                            nvl(vn_cont_price_wt, 1)) *
                                            (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                                  cur_grd_rows.qty_unit_id,
                                                                                  vc_cont_price_wt_unit_id,
                                                                                  cur_grd_rows.stock_qty)) *
                                            vn_cont_price_cur_id_factor;
        else
          vn_contract_value_in_price_cur := 0;
        end if;
        vc_error_msg := '9';
        --
        -- Forward FX Rate from Price to Base Currency
        --
        pkg_general.sp_forward_cur_exchange_new(cur_grd_rows.corporate_id,
                                                pd_trade_date,
                                                cur_grd_rows.payment_due_date,
                                                vc_price_cur_id,
                                                cur_grd_rows.base_cur_id,
                                                30,
                                                vn_fx_price_to_base,
                                                vn_fx_price_deviation);

        if vn_fx_price_to_base <> 0 or vn_fx_price_to_base <> 1 or
           vn_fx_price_to_base is not null then

          if vc_price_cur_code <> cur_grd_rows.base_cur_code then
            vc_price_to_base_fw_rate := '1 ' || vc_price_cur_code || '=' ||
                                        vn_fx_price_to_base || ' ' ||
                                        cur_grd_rows.base_cur_code;
          end if;
        end if;

        vn_contract_value_in_price_cur := round(vn_contract_value_in_price_cur,
                                                vn_cont_price_cur_decimals);
        --
        -- Contract Value in Base Currency
        --
        vn_contract_value_in_base_cur := round((vn_contract_value_in_price_cur *
                                               nvl(vn_fx_price_to_base, 1)),
                                               2);
      end if;
      vc_error_msg          := '10';
      vc_m2m_price_unit_str := cur_grd_rows.m2m_price_unit_str;
      vc_m2m_price_unit_id  := cur_grd_rows.m2m_price_unit_id;
      begin
        select ppu.product_price_unit_id
          into vc_base_price_unit_id
          from v_ppu_pum ppu
         where ppu.cur_id = cur_grd_rows.base_cur_id
           and ppu.weight_unit_id = cur_grd_rows.base_qty_unit_id
           and nvl(ppu.weight, 1) = 1
           and ppu.product_id = cur_grd_rows.product_id;
      exception
        when others then
          sp_write_log(pc_corporate_id,
                       pd_trade_date,
                       'sp_open_phy_unreal',
                       'vc_base_price_unit' || vc_base_price_unit_id ||
                       ' For' || cur_grd_rows.internal_contract_item_ref_no);
      end;
      vc_error_msg := '11';
      ------------------******** Premium Calculations starts here ******-------------------
      --
      -- Quality Premium
      --
      --
      -- Cannot calculate if Stock is internal movement and not having Contract Item #
      --
      if cur_grd_rows.internal_contract_item_ref_no is not null and
         cur_grd_rows.payment_due_date is not null then
        pkg_metals_general.sp_quality_premium_fw_rate(cur_grd_rows.internal_contract_item_ref_no,
                                                      pc_corporate_id,
                                                      pd_trade_date,
                                                      vc_base_price_unit_id,
                                                      cur_grd_rows.base_cur_id,
                                                      cur_grd_rows.payment_due_date,
                                                      cur_grd_rows.product_id,
                                                      cur_grd_rows.base_qty_unit_id,
                                                      pc_process_id,
                                                      vn_quality_premium,
                                                      vc_qual_prem_exch_rate_string);
        vc_contract_qp_fw_exch_rate := vc_qual_prem_exch_rate_string;
      else
        vn_quality_premium := 0;
      end if;

      if cur_grd_rows.delivery_premium <> 0 then
        if cur_grd_rows.delivery_premium_unit_id <> vc_base_price_unit_id then
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
          pkg_general.sp_get_base_cur_detail(vc_del_premium_cur_id,
                                             vc_del_premium_main_cur_id,
                                             vc_del_premium_main_cur_code,
                                             vn_del_premium_cur_main_factor);

          pkg_general.sp_forward_cur_exchange_new(pc_corporate_id,
                                                  pd_trade_date,
                                                  cur_grd_rows.payment_due_date,
                                                  vc_del_premium_main_cur_id,
                                                  cur_grd_rows.base_cur_id,
                                                  30,
                                                  vn_del_to_base_fw_rate,
                                                  vn_forward_points);

          vn_product_premium := (cur_grd_rows.delivery_premium /
                                vn_del_premium_weight) *
                                vn_del_premium_cur_main_factor *
                                vn_del_to_base_fw_rate *
                                pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                     vc_del_premium_weight_unit_id,
                                                                     cur_grd_rows.base_qty_unit_id,
                                                                     1);
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
                                                                   vc_del_premium_main_cur_code ||
                                                                   ' to ' ||
                                                                   cur_grd_rows.base_cur_code || ' (' ||
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
          vn_product_premium := cur_grd_rows.delivery_premium;
        end if;
        vn_product_premium_amt := round(vn_product_premium * vn_qty_in_base,
                                        2);
      else
        vn_product_premium     := 0;
        vn_product_premium_amt := 0;
      end if;
      vc_error_msg           := '13';
      vn_total_premium_value := round((vn_quality_premium * vn_qty_in_base) +
                                      vn_product_premium_amt,
                                      2);
      --
      -- Secondary Cost in Base
      --
      vn_sc_in_base_cur := cur_grd_rows.noncog_secondary_cost_per_unit *
                           vn_qty_in_base;

      --------------------------------------------------------------------------
      vc_error_msg               := '14';
      vn_expected_cog_in_val_cur := round(vn_contract_value_in_base_cur, 2);

      --
      -- Total COG = Contract Value (Qty*Price) + Quality Premium + Delivery Premium + Secondary Cost
      --

      vn_expected_cog_in_val_cur := vn_expected_cog_in_val_cur +
                                    vn_total_premium_value +
                                    abs(vn_sc_in_base_cur);

      if cur_grd_rows.purchase_sales = 'P' then
        vn_contract_value_in_val_cur := (-1) * vn_contract_value_in_val_cur;
        vn_expected_cog_in_val_cur   := (-1) * vn_expected_cog_in_val_cur;
      else
        vn_contract_value_in_val_cur := vn_contract_value_in_val_cur;
        vn_expected_cog_in_val_cur   := vn_expected_cog_in_val_cur;
      end if;
      vn_expected_cog_net_sale_value := round(vn_expected_cog_in_val_cur, 2);
      if cur_grd_rows.purchase_sales = 'P' then
        vn_pnl_in_val_cur := (vn_m2m_total_amount -
                             (nvl(vn_expected_cog_in_val_cur, 0) * (-1)));
      else
        vn_pnl_in_val_cur := (nvl(vn_expected_cog_in_val_cur, 0) -
                             vn_m2m_total_amount);
      end if;
      vc_error_msg              := '15';
      vn_pnl_in_val_cur         := round(vn_pnl_in_val_cur, 2);
      vn_pnl_in_base_cur        := round(vn_pnl_in_val_cur, 2);
      vn_pnl_per_base_unit      := round(vn_pnl_in_base_cur /
                                         nvl(vn_qty_in_base, 1),
                                         5);
      vc_error_msg              := '16';
      vc_error_msg              := '17';
      vn_pnl_in_exch_price_unit := 0;

      vn_trade_day_pnl_per_base_unit := vn_pnl_in_base_cur / vn_qty_in_base;
      vc_error_msg                   := '18';

      insert into psu_phy_stock_unrealized
        (process_id,
         psu_id,
         corporate_id,
         internal_gmr_ref_no,
         internal_contract_item_ref_no,
         product_id,
         product_name,
         origin_id,
         origin_name,
         quality_id,
         quality_name,
         container_no,
         stock_qty,
         qty_unit_id,
         qty_unit,
         no_of_units,
         md_id,
         m2m_price_unit_id,
         m2m_price_unit_str,
         m2m_amt,
         m2m_amt_cur_id,
         m2m_amt_cur_code,
         contract_value_in_price_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         material_cost_in_base_cur,
         material_cost_in_val_cur,
         sc_in_base_cur,
         sc_in_valuation_cur,
         expected_cog_in_base_cur,
         expected_cog_in_val_cur,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_val_cur,
         prev_day_pnl_in_base_cur,
         prev_day_pnl_in_val_cur,
         trade_day_pnl_in_base_cur,
         trade_day_pnl_in_val_cur,
         pnl_in_exch_price_unit,
         prev_pnl_in_exch_price_unit,
         day_pnl_in_exch_price_unit,
         pnl_per_base_unit,
         trade_day_pnl_per_base_unit,
         fw_fx_price_cur_to_m2m_cur,
         fw_fx_base_cur_to_m2m_cur,
         spot_rate_m2m_cur_to_base_cur,
         base_cur_id,
         base_cur_code,
         inventory_status,
         shipment_status,
         section_name,
         base_price_unit_id,
         qty_in_base_unit,
         m2m_price_unit_cur_id,
         m2m_price_unit_cur_code,
         m2m_price_unit_qty_unit_id,
         m2m_price_unit_qty_unit,
         m2m_price_unit_qty_unit_weight,
         spot_price_cur_to_base_cur,
         invm_inventory_status,
         strategy_id,
         strategy_name,
         valuation_month,
         contract_type,
         profit_center_id,
         net_m2m_price,
         unfxd_qty,
         fxd_qty,
         valuation_exchange_id,
         derivative_def_id,
         price_to_val_rate,
         val_to_base_rate,
         base_to_val_rate,
         sec_cost_ratio,
         gmr_contract_type,
         is_voyage_gmr,
         sc_to_val_fx_rate,
         sc_to_val_fx_rate_cur_id,
         sc_to_val_fx_rate_cur_code,
         int_alloc_group_id,
         internal_grd_dgrd_ref_no,
         vessel_id,
         charter_voyage_id,
         vessel_voyage_name,
         price_type_id,
         price_type_name,
         price_string,
         item_delivery_period_string,
         fixation_method,
         price_fixation_details,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         voyage_ref_no,
         stock_ref_no,
         trader_name,
         trader_id,
         unreal_pnl_in_base_per_unit,
         unreal_pnl_in_val_cur_per_unit,
         contract_premium_value,
         m2m_quality_premium,
         m2m_product_premium,
         m2m_loc_diff_premium,
         base_price_unit_id_in_ppu,
         base_price_unit_id_in_pum,
         market_premimum_amt,
         m2m_amt_per_unit,
         is_marked_for_consignment,
         price_to_base_fw_exch_rate,
         m2m_to_base_fw_exch_rate,
         m2m_ld_fw_exch_rate,
         m2m_qp_fw_exch_rate,
         m2m_pp_fw_exch_rate,
         contract_qp_fw_exch_rate,
         contract_pp_fw_exch_rate,
         accrual_to_base_fw_exch_rate,
         cp_profile_id,
         cp_name)
      values
        (pc_process_id,
         vc_psu_id,
         pc_corporate_id,
         cur_grd_rows.internal_gmr_ref_no,
         cur_grd_rows.internal_contract_item_ref_no,
         cur_grd_rows.product_id,
         cur_grd_rows.product_name,
         cur_grd_rows.origin_id,
         cur_grd_rows.origin_name,
         cur_grd_rows.quality_id,
         cur_grd_rows.quality_name,
         cur_grd_rows.container_no,
         cur_grd_rows.stock_qty,
         cur_grd_rows.qty_unit_id,
         cur_grd_rows.qty_unit,
         cur_grd_rows.no_of_units,
         cur_grd_rows.md_id,
         vc_m2m_price_unit_id,
         vc_m2m_price_unit_str,
         vn_m2m_total_amount,
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         vn_contract_value_in_base_cur,
         vn_sc_in_base_cur,
         vn_sc_in_base_cur,
         vn_expected_cog_net_sale_value,
         vn_expected_cog_in_val_cur,
         'Unrealized',
         vn_pnl_in_base_cur,
         vn_pnl_in_val_cur,
         null, --prev_day_pnl_in_base_cur
         null, -- prev_day_pnl_in_val_cur
         null, -- trade_day_pnl_in_base_cur
         null, --  trade_day_pnl_in_val_cur
         vn_pnl_in_exch_price_unit,
         null, --   prev_pnl_in_exch_price_unit
         null, --  day_pnl_in_exch_price_unit
         vn_pnl_per_base_unit, --  v_pnl_per_base_unit
         vn_trade_day_pnl_per_base_unit,
         null, --fw_fx_price_cur_to_m2m_cur
         null, --fw_fx_base_cur_to_m2m_cur
         vn_corp_rate_val_to_base_cur,
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         cur_grd_rows.inventory_status,
         cur_grd_rows.shipment_status,
         cur_grd_rows.section_name,
         vc_base_price_unit_id,
         vn_qty_in_base,
         cur_grd_rows.m2m_price_unit_cur_id,
         cur_grd_rows.m2m_price_unit_cur_code,
         cur_grd_rows.m2m_price_unit_weight_unit_id,
         cur_grd_rows.m2m_price_unit_weight_unit,
         cur_grd_rows.m2m_price_unit_weight,
         vn_fx_price_to_base, --vn_corp_rate_price_to_base_cur,
         null, --cur_grd_rows.invm_inventory_status,
         cur_grd_rows.strategy_id,
         cur_grd_rows.strategy_name,
         cur_grd_rows.valuation_month,
         cur_grd_rows.purchase_sales,
         cur_grd_rows.profit_center,
         cur_grd_rows.net_m2m_price,
         cur_grd_rows.unfxd_qty,
         cur_grd_rows.fxd_qty,
         cur_grd_rows.valuation_exchange_id,
         cur_grd_rows.derivative_def_id,
         null, --vn_spot_rate_price_to_val_cur,
         vn_m2m_base_fx_rate, --vn_corp_rate_val_to_base_cur,
         null, --vn_spot_rate_base_to_val_cur,
         vn_ratio,
         cur_grd_rows.gmr_contract_type,
         cur_grd_rows.is_voyage_gmr,
         vn_spot_rate_base_to_val_cur,
         null, --sc_to_val_fx_rate_cur_id
         null, --sc_to_val_fx_rate_cur_code
         null, -- cur_grd_rows.int_alloc_group_id,
         cur_grd_rows.internal_grd_dgrd_ref_no,
         null, --cur_grd_rows.vessel_id,
         null, --cur_grd_rows.voyage_number,
         cur_grd_rows.vessel_name,
         cur_grd_rows.price_basis,
         null, --cur_grd_rows.price_type_name,
         vc_price_string,
         null, -- cur_grd_rows.item_delivery_period_string
         vc_price_fixation_status,
         cur_grd_rows.price_fixation_details,
         vn_cont_price,
         vc_cont_price_unit_id,
         vc_cont_price_unit_cur_id,
         vc_cont_price_unit_cur_code,
         vc_cont_price_wt_unit_id,
         vn_cont_price_wt,
         vc_cont_price_wt_unit,
         null, --cur_grd_rows.voyage_ref_no,
         cur_grd_rows.stock_ref_no,
         cur_grd_rows.trader_user_name,
         cur_grd_rows.trader_id,
         vn_pnl_in_base_cur / decode(vn_qty_in_base, 0, 1, vn_qty_in_base),
         vn_pnl_in_val_cur / decode(vn_qty_in_base, 0, 1, vn_qty_in_base),
         vn_total_premium_value,
         cur_grd_rows.m2m_quality_premium,
         cur_grd_rows.m2m_product_premium,
         cur_grd_rows.m2m_loc_incoterm_deviation,
         cur_grd_rows.base_price_unit_id_in_ppu,
         cur_grd_rows.base_price_unit_id_in_pum,
         vn_m2m_total_premium_amt,
         vn_m2m_amt_per_unit,
         cur_grd_rows.is_marked_for_consignment,
         vc_price_to_base_fw_rate,
         vc_m2m_to_base_fw_rate,
         vc_m2m_ld_fw_exch_rate,
         vc_m2m_qp_fw_exch_rate,
         vc_m2m_pp_fw_exch_rate,
         vc_contract_qp_fw_exch_rate,
         vc_contract_pp_fw_exch_rate,
         cur_grd_rows.accrual_to_base_fw_exch_rate,
         cur_grd_rows.cp_id,
         cur_grd_rows.cp_name);
    end loop;
    -----------
    vc_error_msg := '19';
    commit;
    sp_gather_stats('psu_phy_stock_unrealized');
    sp_gather_stats('pcm_physical_contract_main');
    sp_gather_stats('pci_physical_contract_item');
    sp_gather_stats('cipd_contract_item_price_daily');
    dbms_output.put_line('finsihed loop');
    vc_error_msg := '20';
    begin
      --
      -- update previous eod data
      --
      for cur_update in (select psu_prev_day.unreal_pnl_in_base_per_unit,
                                psu_prev_day.unreal_pnl_in_val_cur_per_unit,
                                psu_prev_day.pnl_in_exch_price_unit,
                                psu_prev_day.m2m_quality_premium,
                                psu_prev_day.m2m_product_premium,
                                psu_prev_day.m2m_loc_diff_premium,
                                psu_prev_day.market_premimum_amt,
                                psu_prev_day.net_m2m_price,
                                psu_prev_day.m2m_price_unit_id,
                                psu_prev_day.m2m_amt,
                                psu_prev_day.m2m_amt_cur_id,
                                psu_prev_day.m2m_amt_cur_code,
                                psu_prev_day.psu_id,
                                psu_prev_day.m2m_amt_per_unit,
                                psu_prev_day.prev_market_value,
                                psu_prev_day.m_pnl_in_base_cur
                           from psu_phy_stock_unrealized psu_prev_day
                          where process_id = pc_previous_process_id
                            and corporate_id = pc_corporate_id)
      loop
        vc_error_msg := '21';
        update psu_phy_stock_unrealized psu_today
           set psu_today.prev_day_pnl_in_val_cur       = cur_update.unreal_pnl_in_val_cur_per_unit *
                                                         psu_today.qty_in_base_unit,
               psu_today.prev_day_pnl_in_base_cur      = cur_update.unreal_pnl_in_base_per_unit *
                                                         psu_today.qty_in_base_unit,
               psu_today.prev_pnl_in_exch_price_unit   = cur_update.pnl_in_exch_price_unit,
               psu_today.prev_m2m_quality_premium      = cur_update.m2m_quality_premium,
               psu_today.prev_m2m_product_premium      = cur_update.m2m_product_premium,
               psu_today.prev_m2m_loc_diff_premium     = cur_update.m2m_loc_diff_premium,
               psu_today.prev_market_premimum_amt      = cur_update.market_premimum_amt,
               psu_today.prev_market_price             = cur_update.net_m2m_price,
               psu_today.prev_market_price_unit_id     = cur_update.m2m_price_unit_id,
               psu_today.prev_market_value             = round(nvl(cur_update.m2m_amt_per_unit,
                                                                   0) *
                                                               psu_today.qty_in_base_unit,
                                                               4),
               psu_today.prev_market_value_cur_id      = cur_update.m2m_amt_cur_id,
               psu_today.prev_market_value_cur_code    = cur_update.m2m_amt_cur_code,
               psu_today.prev_m2m_amt_per_unit         = cur_update.m2m_amt_per_unit,
               psu_today.m_prev_day_pnl_in_base_cur    = (cur_update.m2m_amt -
                                                         cur_update.prev_market_value),
               psu_today.m_prev_day_pnl_in_val_cur     = (cur_update.m2m_amt -
                                                         cur_update.prev_market_value),
               psu_today.m_trade_day_pnl_per_base_unit = (psu_today.m_pnl_in_base_cur -
                                                         cur_update.m_pnl_in_base_cur) /
                                                         psu_today.qty_in_base_unit,
               psu_today.cont_unr_status               = 'EXISTING_TRADE'
         where psu_today.psu_id = cur_update.psu_id
           and psu_today.process_id = pc_process_id
           and psu_today.corporate_id = pc_corporate_id;
      end loop;
    exception
      when others then
        dbms_output.put_line('SQLERRM-1' || sqlerrm);
    end;
    vc_error_msg := '22';
    --
    -- mark the trades came as new in this eod/eom
    --
    begin
      update psu_phy_stock_unrealized psu
         set psu.prev_day_pnl_in_val_cur     = 0,
             psu.prev_day_pnl_in_base_cur    = 0,
             psu.prev_pnl_in_exch_price_unit = 0,
             psu.m_prev_day_pnl_in_base_cur  = 0,
             psu.m_prev_day_pnl_in_val_cur   = 0,
             psu.m_pnl_in_base_cur           = 0,
             psu.m_trade_day_pnl_in_base_cur = 0,
             psu.prev_m2m_quality_premium    = psu.m2m_quality_premium,
             psu.prev_m2m_product_premium    = psu.m2m_product_premium,
             psu.prev_m2m_loc_diff_premium   = psu.m2m_loc_diff_premium,
             psu.prev_market_premimum_amt    = psu.market_premimum_amt,
             psu.prev_market_price           = psu.net_m2m_price,
             psu.prev_market_price_unit_id   = psu.m2m_price_unit_id,
             psu.prev_market_value           = psu.m2m_amt,
             psu.prev_market_value_cur_id    = psu.m2m_amt_cur_id,
             psu.prev_market_value_cur_code  = psu.m2m_amt_cur_code,
             psu.prev_m2m_amt_per_unit       = psu.m2m_amt_per_unit,
             psu.cont_unr_status             = 'NEW_TRADE'
       where psu.cont_unr_status is null
         and psu.process_id = pc_process_id
         and psu.corporate_id = pc_corporate_id;
    exception
      when others then
        dbms_output.put_line('SQLERRM-2' || sqlerrm);
    end;
    vc_error_msg := '23';
    update psu_phy_stock_unrealized psu
       set psu.m_pnl_in_val_cur          = (psu.m2m_amt -
                                           psu.prev_market_value),
           psu.m_pnl_in_base_cur         = (psu.m2m_amt -
                                           psu.prev_market_value),
           psu.m_pnl_in_base_per_unit    = (psu.m2m_amt -
                                           psu.prev_market_value) /
                                           psu.qty_in_base_unit,
           psu.m_pnl_in_val_cur_per_unit = (psu.m2m_amt -
                                           psu.prev_market_value) /
                                           psu.qty_in_base_unit
     where psu.process_id = pc_process_id
       and psu.corporate_id = pc_corporate_id;
    --
    -- update trade day pnl values
    -- It is difference of unrealized pnl on trade date and previous eod For M2M PNL
    -- Else it is same as PNL as on Today
    --
    vc_error_msg := '24';
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Phy Stock Unrlzd',
                 'after loop' || vc_error_msg);
    update psu_phy_stock_unrealized psu
       set m_trade_day_pnl_in_val_cur    = nvl(psu.m_pnl_in_val_cur, 0) -
                                           nvl(psu.m_prev_day_pnl_in_val_cur,
                                               0),
           m_trade_day_pnl_in_base_cur   = nvl(psu.m_pnl_in_base_cur, 0) -
                                           nvl(psu.m_prev_day_pnl_in_base_cur,
                                               0),
           psu.trade_day_pnl_in_base_cur = psu.pnl_in_base_cur -
                                           psu.prev_day_pnl_in_base_cur,
           psu.trade_day_pnl_in_val_cur  = psu.pnl_in_val_cur -
                                           psu.prev_day_pnl_in_val_cur
     where psu.process_id = pc_process_id;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Phy Stock Unrlzd',
                 'after update' || vc_error_msg);
    --
    -- Insert into contract and price data for the contract items that are in pss
    --
    vc_error_msg := '25';
    update psu_phy_stock_unrealized pss
       set (gmr_ref_no, origination_city_id, --
           origination_country_id, --
           destination_city_id, --
           destination_country_id, --
           origination_city, --
           origination_country, --
           destination_city, --
           destination_country, --
           warehouse_id, --
           warehouse_name, --
           shed_id, --
           shed_name, --
           product_id, --
           prod_base_unit_id, --
           prod_base_unit) = --
            (select gmr.gmr_ref_no,
                    gmr.origin_city_id,
                    gmr.origin_country_id,
                    gmr.destination_city_id,
                    gmr.destination_country_id,
                    cim_orig.city_name as origin_city_name,
                    cym_orig.country_name origin_country_name,
                    cim_dest.city_name as destination_city_name,
                    cym_dest.country_name destination_country_name,
                    gmr.warehouse_profile_id,
                    phd_gmr.companyname as warehouse_profile_name,
                    gmr.shed_id,
                    sld.storage_location_name,
                    pss.product_id,
                    pdm.base_quantity_unit,
                    qum.qty_unit
               from gmr_goods_movement_record   gmr,
                    pdm_productmaster           pdm,
                    phd_profileheaderdetails    phd_gmr,
                    sld_storage_location_detail sld,
                    cim_citymaster              cim_orig,
                    cym_countrymaster           cym_orig,
                    cim_citymaster              cim_dest,
                    cym_countrymaster           cym_dest,
                    qum_quantity_unit_master    qum
              where gmr.internal_gmr_ref_no = pss.internal_gmr_ref_no
                and pss.product_id = pdm.product_id
                and pdm.base_quantity_unit = qum.qty_unit_id
                and gmr.warehouse_profile_id = phd_gmr.profileid(+)
                and gmr.shed_id = sld.storage_loc_id(+)
                and gmr.origin_city_id = cim_orig.city_id(+)
                and gmr.origin_country_id = cym_orig.country_id(+)
                and gmr.destination_city_id = cim_dest.city_id(+)
                and gmr.destination_country_id = cym_dest.country_id(+)
                and pss.process_id = gmr.process_id
                and pss.process_id = pc_process_id)
     where pss.process_id = pc_process_id;
    --
    --
    --
    vc_error_msg := '26';
    update md_m2m_daily md
       set md.m2m_price_unit_weight = null
     where md.m2m_price_unit_weight = 1
       and md.process_id = pc_process_id;
    vc_error_msg := '27';
  exception
    when others then
      dbms_output.put_line('failed with ' || sqlerrm);
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_stock_unreal_sntt_bm ',
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
  procedure sp_stock_unreal_inv_in_bm(pc_corporate_id        varchar2,
                                      pd_trade_date          date,
                                      pc_process_id          varchar2,
                                      pc_user_id             varchar2,
                                      pc_process             varchar2,
                                      pc_previous_process_id varchar2) as
    cursor cur_grd is
    -- Purchase Inventory In
      select 'Purchase' section_type,
             pcpd.profit_center_id profit_center,
             pc_process_id process_id,
             gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             grd.internal_contract_item_ref_no,
             pcm.purchase_sales,
             grd.product_id,
             pdm.product_desc product_name,
             grd.origin_id,
             orm.origin_name,
             qat.quality_id,
             qat.quality_name,
             grd.container_no,
             grd.current_qty stock_qty,
             grd.qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
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
             pd_trade_date payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
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
             null price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             cipd.price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             pcpd.strategy_id,
             css.strategy_name,
             (ciqs.total_qty - nvl(ciqs.price_fixed_qty, 0)) unfxd_qty,
             ciqs.price_fixed_qty fxd_qty,
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
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             qat.eval_basis,
             invm.material_cost_per_unit,
             invm.secondary_cost_per_unit,
             invm.product_premium_per_unit,
             invm.quality_premium_per_unit,
             invm.price_unit_id cog_price_unit_id,
             invm.price_unit_cur_id cog_price_unit_cur_id,
             invm.price_unit_cur_code cog_price_unit_cur_code,
             invm.price_unit_weight_unit_id cog_price_unit_weight_unit_id,
             invm.price_unit_weight_unit cog_price_unit_weight_unit,
             invm.price_unit_weight cog_price_unit_weight,
             null invm_inventory_status,
             gmr.vessel_name,
             decode(grd.partnership_type, 'Consignment', 'Y', 'N') as is_marked_for_consignment,
             md.m2m_pp_fw_exch_rate,
             md.m2m_ld_fw_exch_rate,
             md.m2m_qp_fw_exch_rate,
             invm.price_to_base_fw_exch_rate,
             invm.contract_qp_fw_exch_rate,
             invm.contract_pp_fw_exch_rate,
             invm.accrual_to_base_fw_exch_rate,
             invm.price_to_base_fw_exch_rate_act,
             pcm.cp_id,
             phd_cp.companyname cp_name,
             gpd.price_fixation_status gmr_price_fixation_status
        from gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             pcm_physical_contract_main pcm,
             pcpd_pc_product_definition pcpd,
             gpd_gmr_price_daily gpd,
             cipd_contract_item_price_daily cipd,
             pdm_productmaster pdm,
             orm_origin_master orm,
             qat_quality_attributes qat,
             qum_quantity_unit_master qum,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name <> 'OPEN') tmpc,
             ak_corporate akc,
             phd_profileheaderdetails phd_cp,
             cm_currency_master cm,
             gsm_gmr_stauts_master gsm,
             pci_physical_contract_item pci,
             pcdi_pc_delivery_item pcdi,
             ciqs_contract_item_qty_status ciqs,
             css_corporate_strategy_setup css,
             invm_cog invm
       where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and grd.product_id = pdm.product_id
         and grd.origin_id = orm.origin_id(+)
         and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
         and grd.internal_contract_item_ref_no =
             tmpc.internal_contract_item_ref_no(+)
         and tmpc.quality_id = qat.quality_id(+)
         and grd.qty_unit_id = qum.qty_unit_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and grd.process_id = pci.process_id
         and pci.pcdi_id = pcdi.pcdi_id
         and pcdi.process_id = pc_process_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and grd.internal_contract_item_ref_no =
             ciqs.internal_contract_item_ref_no
         and grd.internal_contract_item_ref_no =
             pci.internal_contract_item_ref_no
         and grd.internal_contract_item_ref_no = cipd.internal_contract_item_ref_no 
          and cipd.internal_contract_ref_no = pcm.internal_contract_ref_no
         and gmr.internal_gmr_ref_no = gpd.internal_gmr_ref_no(+)
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.status_id = gsm.status_id(+)
         and pcpd.strategy_id = css.strategy_id
         and pcm.cp_id = phd_cp.profileid
         and gmr.process_id = gpd.process_id(+)
         and grd.process_id = cipd.process_id 
         and grd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and pcpd.process_id = pc_process_id
         and ciqs.process_id = pc_process_id
         and pcm.process_id = pc_process_id
         and pci.process_id = pc_process_id
         and cipd.process_id = pc_process_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pcm.is_active = 'Y'
         and pci.is_active = 'Y'
         and gmr.corporate_id = pc_corporate_id
         and grd.status = 'Active'
         and grd.is_deleted = 'N'
         and gmr.is_deleted = 'N'
         and nvl(grd.inventory_status, 'NA') = 'In'
         and pcm.purchase_sales = 'P'
         and nvl(grd.current_qty, 0) > 0
         and gmr.is_internal_movement = 'N'
         and grd.internal_grd_ref_no = invm.internal_grd_ref_no
         and grd.process_id = invm.process_id
      union all
      -- Internal Movement Inventory In
      select 'Internal Movement' section_type,
             null profit_center, --get it FROM grd
             pc_process_id process_id,
             gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             grd.internal_contract_item_ref_no,
             decode(gmr.contract_type, 'Purchase', 'P', 'S') purchase_sales,
             grd.product_id,
             pdm.product_desc product_name,
             grd.origin_id,
             orm.origin_name,
             qat.quality_id,
             qat.quality_name,
             grd.container_no,
             grd.current_qty stock_qty,
             grd.qty_unit_id,
             gmr.qty_unit_id gmr_qty_unit_id,
             qum.qty_unit,
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
             pd_trade_date payment_due_date,
             akc.base_cur_id as base_cur_id,
             akc.base_currency_name base_cur_code,
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
             null price_basis,
             gmr.shed_id,
             gmr.destination_city_id,
             'NA'  price_fixation_status,
             pdm.base_quantity_unit base_qty_unit_id,
             css.strategy_id strategy_id,
             css.strategy_name strategy_name,
             null unfxd_qty,
             null fxd_qty,
             md.valuation_exchange_id,
             md.valuation_month,
             md.derivative_def_id,
             nvl(gmr.is_voyage_gmr, 'N') is_voyage_gmr,
             gmr.contract_type gmr_contract_type,
             grd.internal_grd_ref_no internal_grd_dgrd_ref_no,
             grd.internal_stock_ref_no stock_ref_no,
             gmr.created_by trader_id,
             (case
               when gmr.created_by is not null then
                (select gab.firstname || ' ' || gab.lastname
                   from gab_globaladdressbook gab,
                        ak_corporate_user     aku
                  where gab.gabid = aku.gabid
                    and aku.user_id = gmr.created_by)
               else
                ''
             end) trader_user_name,
             md.m2m_loc_incoterm_deviation,
             md.m2m_quality_premium,
             md.m2m_product_premium,
             md.base_price_unit_id_in_ppu,
             md.base_price_unit_id_in_pum,
             nvl(md.m2m_loc_incoterm_deviation, 0) +
             nvl(md.m2m_quality_premium, 0) +
             nvl(md.m2m_product_premium, 0) total_premium,
             qat.eval_basis,
             invm.material_cost_per_unit,
             invm.secondary_cost_per_unit,
             invm.product_premium_per_unit,
             invm.quality_premium_per_unit,
             invm.price_unit_id cog_price_unit_id,
             invm.price_unit_cur_id cog_price_unit_cur_id,
             invm.price_unit_cur_code cog_price_unit_cur_code,
             invm.price_unit_weight_unit_id cog_price_unit_weight_unit_id,
             invm.price_unit_weight_unit cog_price_unit_weight_unit,
             invm.price_unit_weight cog_price_unit_weight,
             null, -- invm.inv_status invm_inventory_status,
             gmr.vessel_name,
             decode(grd.partnership_type, 'Consignment', 'Y', 'N') as is_marked_for_consignment,
             md.m2m_pp_fw_exch_rate,
             md.m2m_ld_fw_exch_rate,
             md.m2m_qp_fw_exch_rate,
             invm.price_to_base_fw_exch_rate,
             invm.contract_qp_fw_exch_rate,
             invm.contract_pp_fw_exch_rate,
             invm.accrual_to_base_fw_exch_rate,
             invm.price_to_base_fw_exch_rate_act,
             null cp_id,
             null cp_name,
             'NA' gmr_price_fixation_status
        from gmr_goods_movement_record gmr,
             grd_goods_record_detail grd,
             pdm_productmaster pdm,
             orm_origin_master orm,
             qum_quantity_unit_master qum,
             qat_quality_attributes qat,
             ak_corporate akc,
             cm_currency_master cm,
             gsm_gmr_stauts_master gsm,
             (select md1.*
                from md_m2m_daily md1
               where md1.rate_type <> 'OPEN'
                 and md1.corporate_id = pc_corporate_id
                 and md1.product_type = 'BASEMETAL'
                 and md1.process_id = pc_process_id) md,
             (select tmp.*
                from tmpc_temp_m2m_pre_check tmp
               where tmp.corporate_id = pc_corporate_id
                 and tmp.product_type = 'BASEMETAL'
                 and tmp.section_name <> 'OPEN') tmpc,
             invm_cog invm,
             css_corporate_strategy_setup css
       where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and grd.origin_id = orm.origin_id(+)
         and grd.qty_unit_id = qum.qty_unit_id(+)
         and grd.internal_gmr_ref_no = tmpc.internal_gmr_ref_no(+)
         and grd.internal_grd_ref_no = tmpc.internal_grd_ref_no(+)
         and tmpc.quality_id = qat.quality_id(+)
         and tmpc.internal_m2m_id = md.md_id(+)
         and gmr.corporate_id = akc.corporate_id
         and akc.base_cur_id = cm.cur_id
         and gmr.status_id = gsm.status_id(+)
         and grd.process_id = pc_process_id
         and gmr.process_id = pc_process_id
         and gmr.corporate_id = pc_corporate_id
         and grd.status = 'Active'
         and grd.is_deleted = 'N'
         and gmr.is_deleted = 'N'
         and nvl(grd.inventory_status, 'NA') = 'In'
         and nvl(grd.current_qty, 0) > 0
         and gmr.is_internal_movement = 'Y'
         and grd.internal_grd_ref_no = invm.internal_grd_ref_no
         and grd.process_id = invm.process_id
         and grd.strategy_id = css.strategy_id(+);
    vn_qty_in_base                 number;
    vn_m2m_amt                     number;
    vc_m2m_cur_id                  varchar2(15);
    vc_m2m_cur_code                varchar2(15);
    vn_m2m_sub_cur_id_factor       number;
    vn_m2m_cur_decimals            number;
    vc_price_cur_id                varchar2(15);
    vc_price_cur_code              varchar2(15);
    vn_cont_price_cur_id_factor    number;
    vn_contract_value_in_price_cur number;
    vn_cont_price_cur_decimals     number;
    vn_contract_value_in_val_cur   number;
    vn_contract_value_in_base_cur  number;
    vc_m2m_price_unit_str          varchar2(100);
    vc_m2m_price_unit_id           varchar2(15);
    vc_m2m_price_unit_cur_id       varchar2(15);
    vn_ratio                       number;
    vn_corp_rate_val_to_base_cur   number;
    vn_spot_rate_base_to_val_cur   number;
    vn_expected_cog_net_sale_value number;
    vn_expected_cog_in_val_cur     number;
    vn_pnl_in_val_cur              number;
    vn_pnl_in_base_cur             number;
    vn_pnl_per_base_unit           number;
    vc_psu_id                      varchar2(500);
    vn_pnl_in_exch_price_unit      number;
    vobj_error_log                 tableofpelerrorlog := tableofpelerrorlog();
    vn_eel_error_count             number := 1;
    vn_m2m_base_fx_rate            number;
    vn_m2m_base_deviation          number;
    vn_m2m_amount_in_base          number;
    vn_m2m_total_amount            number;
    vn_m2m_total_premium_amt       number;
    vn_total_premium_value         number;
    vn_quality_premium_amt         number;
    vn_product_premium_amt         number;
    vc_base_price_unit_id          varchar2(20);
    vn_m2m_amt_per_unit            number;
    vn_cont_price                  number;
    vc_cont_price_unit_id          varchar2(15);
    vc_cont_price_unit_cur_id      varchar2(15);
    vc_cont_price_unit_cur_code    varchar2(15);
    vn_cont_price_wt               number;
    vc_cont_price_wt_unit_id       varchar2(15);
    vc_cont_price_wt_unit          varchar2(15);
    vn_sc_in_base_cur              number;
    vc_price_fixation_status       varchar2(50);
    vc_error_msg                   varchar2(100);
    vn_trade_day_pnl_per_base_unit number;
    -- All variable for exchange rate string start
    vc_price_to_base_fw_rate    varchar2(100);
    vc_m2m_to_base_fw_rate      varchar2(100);
    vc_m2m_ld_fw_exch_rate      varchar2(100);
    vc_m2m_qp_fw_exch_rate      varchar2(100);
    vc_m2m_pp_fw_exch_rate      varchar2(100);
    vc_contract_qp_fw_exch_rate varchar2(100);
    vc_contract_pp_fw_exch_rate varchar2(100);
    vc_sc_fw_exch_rate          varchar2(100);
    -- All variable for exchange rate string end
  begin
    for cur_grd_rows in cur_grd
    loop
      vc_sc_fw_exch_rate            := cur_grd_rows.accrual_to_base_fw_exch_rate;
      vc_m2m_ld_fw_exch_rate        := cur_grd_rows.m2m_ld_fw_exch_rate;
      vc_m2m_qp_fw_exch_rate        := cur_grd_rows.m2m_qp_fw_exch_rate;
      vc_m2m_pp_fw_exch_rate        := cur_grd_rows.m2m_pp_fw_exch_rate;
      vc_contract_qp_fw_exch_rate   := cur_grd_rows.contract_qp_fw_exch_rate;
      vc_contract_pp_fw_exch_rate   := cur_grd_rows.contract_pp_fw_exch_rate;
      vc_price_to_base_fw_rate      := cur_grd_rows.price_to_base_fw_exch_rate;
      vc_m2m_to_base_fw_rate        := null;
      vn_product_premium_amt        := 0;
      vn_quality_premium_amt        := 0;
      vn_contract_value_in_base_cur := 0;
      vn_total_premium_value        := 0;
      vn_cont_price                 := 0;
      vc_cont_price_unit_id         := null;
      vc_cont_price_unit_cur_id     := null;
      vc_cont_price_unit_cur_code   := null;
      vn_cont_price_wt              := 1;
      vc_cont_price_wt_unit_id      := null;
      vc_cont_price_wt_unit         := null;
      vc_price_fixation_status      := null;
      vn_cont_price                 := cur_grd_rows.material_cost_per_unit;
      vc_cont_price_unit_id         := cur_grd_rows.cog_price_unit_id;
      vc_cont_price_unit_cur_id     := cur_grd_rows.cog_price_unit_cur_id;
      vc_cont_price_unit_cur_code   := cur_grd_rows.cog_price_unit_cur_code;
      vn_cont_price_wt              := cur_grd_rows.cog_price_unit_weight;
      vc_cont_price_wt_unit_id      := cur_grd_rows.cog_price_unit_weight_unit_id;
      vc_cont_price_wt_unit         := cur_grd_rows.cog_price_unit_weight_unit;
      vc_error_msg                  := vn_cont_price ||
                                       vc_cont_price_unit_id;
      if cur_grd_rows.stock_qty <> 0 then
        vc_psu_id    := cur_grd_rows.internal_gmr_ref_no || '-' ||
                        cur_grd_rows.internal_grd_dgrd_ref_no || '-' ||
                        cur_grd_rows.internal_contract_item_ref_no || '-' ||
                        cur_grd_rows.container_no;
     if cur_grd_rows.gmr_price_fixation_status is null then
        vc_price_fixation_status := cur_grd_rows.price_fixation_status;
      else
        vc_price_fixation_status := cur_grd_rows.gmr_price_fixation_status;
      end if;                
        vc_error_msg := '1';
        if cur_grd_rows.qty_unit_id <> cur_grd_rows.base_qty_unit_id then
          vn_qty_in_base := cur_grd_rows.stock_qty *
                            pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                 cur_grd_rows.qty_unit_id,
                                                                 cur_grd_rows.base_qty_unit_id,
                                                                 1);
        else
          vn_qty_in_base := cur_grd_rows.stock_qty;
        end if;
        vc_error_msg := '2';
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
                                                                           cur_grd_rows.qty_unit_id,
                                                                           cur_grd_rows.m2m_price_unit_weight_unit_id,
                                                                           cur_grd_rows.stock_qty);
        end if;
        vc_error_msg := '3';
        pkg_general.sp_get_main_cur_detail(nvl(vc_m2m_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_m2m_cur_id,
                                           vc_m2m_cur_code,
                                           vn_m2m_sub_cur_id_factor,
                                           vn_m2m_cur_decimals);
        vn_m2m_amt   := round(vn_m2m_amt * vn_m2m_sub_cur_id_factor, 2);
        vc_error_msg := '4';
        if cur_grd_rows.eval_basis <> 'FIXED' then
          --
          -- Forwad Rate from Valuation to Base Currency
          --
          pkg_general.sp_forward_cur_exchange_new(cur_grd_rows.corporate_id,
                                                  pd_trade_date,
                                                  cur_grd_rows.payment_due_date,
                                                  nvl(vc_m2m_cur_id,
                                                      cur_grd_rows.base_cur_id),
                                                  cur_grd_rows.base_cur_id,
                                                  30,
                                                  vn_m2m_base_fx_rate,
                                                  vn_m2m_base_deviation);
          vc_error_msg := '5';

          if vc_m2m_cur_id <> cur_grd_rows.base_cur_id then
            if vn_m2m_base_fx_rate is null or vn_m2m_base_fx_rate = 0 then
              vobj_error_log.extend;
              vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                                   'procedure pkg_phy_physical_process-sp_calc_phy_open_unrealized ',
                                                                   'PHY-005',
                                                                   vc_m2m_cur_code ||
                                                                   ' to ' ||
                                                                   cur_grd_rows.base_cur_code || ' (' ||
                                                                   to_char(cur_grd_rows.payment_due_date,
                                                                           'dd-Mon-yyyy') || ') ',
                                                                   '',
                                                                   pc_process,
                                                                   pc_user_id,
                                                                   sysdate,
                                                                   pd_trade_date);
              sp_insert_error_log(vobj_error_log);
            else
              vc_m2m_to_base_fw_rate := '1 ' || vc_m2m_cur_code || '=' ||
                                        vn_m2m_base_fx_rate || ' ' ||
                                        cur_grd_rows.base_cur_code;

            end if;
          end if;
        else
          vn_m2m_base_fx_rate := 1;
        end if;
        vn_m2m_amount_in_base    := vn_m2m_amt * vn_m2m_base_fx_rate;
        vn_m2m_total_premium_amt := vn_qty_in_base *
                                    cur_grd_rows.total_premium;
        vn_m2m_total_amount      := vn_m2m_amount_in_base +
                                    vn_m2m_total_premium_amt;
        vc_error_msg             := '6';
        vn_m2m_amt_per_unit      := round(vn_m2m_total_amount /
                                          vn_qty_in_base,
                                          8);
        pkg_general.sp_get_main_cur_detail(nvl(vc_cont_price_unit_cur_id,
                                               cur_grd_rows.base_cur_id),
                                           vc_price_cur_id,
                                           vc_price_cur_code,
                                           vn_cont_price_cur_id_factor,
                                           vn_cont_price_cur_decimals);
        vc_error_msg := '7';

        vc_error_msg                   := '8';
        vn_contract_value_in_price_cur := vn_cont_price *
                                          (pkg_general.f_get_converted_quantity(cur_grd_rows.product_id,
                                                                                cur_grd_rows.qty_unit_id,
                                                                                vc_cont_price_wt_unit_id,
                                                                                cur_grd_rows.stock_qty));

        vc_error_msg := '9';

        --
        -- Contract Value in Base Currency
        --
        vn_contract_value_in_base_cur := round((vn_cont_price *
                                               vn_qty_in_base),
                                               2);

      end if;
      vc_error_msg          := '10';
      vc_m2m_price_unit_str := cur_grd_rows.m2m_price_unit_str;
      vc_m2m_price_unit_id  := cur_grd_rows.m2m_price_unit_id;
      begin
        select ppu.product_price_unit_id
          into vc_base_price_unit_id
          from v_ppu_pum ppu
         where ppu.cur_id = cur_grd_rows.base_cur_id
           and ppu.weight_unit_id = cur_grd_rows.base_qty_unit_id
           and nvl(ppu.weight, 1) = 1
           and ppu.product_id = cur_grd_rows.product_id;
      exception
        when others then
          sp_write_log(pc_corporate_id,
                       pd_trade_date,
                       'sp_open_phy_unreal',
                       'vc_base_price_unit' || vc_base_price_unit_id ||
                       ' For' || cur_grd_rows.internal_contract_item_ref_no);
      end;
      vc_error_msg := '11';
      --
      -- Quality Premium Amount in Base
      --
      vn_quality_premium_amt := cur_grd_rows.quality_premium_per_unit *
                                vn_qty_in_base;
      vc_error_msg           := '12';
      --
      -- Product Premium Amount in Base
      --
      vn_product_premium_amt := cur_grd_rows.product_premium_per_unit *
                                vn_qty_in_base;

      vc_error_msg           := '13';
      vn_total_premium_value := round((vn_quality_premium_amt +
                                      vn_product_premium_amt),
                                      2);
      --
      -- Secondary Cost in Base
      --
      vn_sc_in_base_cur := cur_grd_rows.secondary_cost_per_unit *
                           vn_qty_in_base;

      --------------------------------------------------------------------------
      vc_error_msg               := '14';
      vn_expected_cog_in_val_cur := round(vn_contract_value_in_base_cur, 2);

      --
      -- Total COG = Contract Value (Qty*Price) + Quality Premium + Delivery Premium + Secondary Cost
      --

      vn_expected_cog_in_val_cur := vn_expected_cog_in_val_cur +
                                    vn_total_premium_value +
                                    abs(vn_sc_in_base_cur);

      if cur_grd_rows.purchase_sales = 'P' then
        vn_contract_value_in_val_cur := (-1) * vn_contract_value_in_val_cur;
        vn_expected_cog_in_val_cur   := (-1) * vn_expected_cog_in_val_cur;
      else
        vn_contract_value_in_val_cur := vn_contract_value_in_val_cur;
        vn_expected_cog_in_val_cur   := vn_expected_cog_in_val_cur;
      end if;
      vn_expected_cog_net_sale_value := round(vn_expected_cog_in_val_cur, 2);
      if cur_grd_rows.purchase_sales = 'P' then
        vn_pnl_in_val_cur := (vn_m2m_total_amount -
                             (nvl(vn_expected_cog_in_val_cur, 0) * (-1)));
      else
        vn_pnl_in_val_cur := (nvl(vn_expected_cog_in_val_cur, 0) -
                             vn_m2m_total_amount);
      end if;
      vc_error_msg              := '15';
      vn_pnl_in_val_cur         := round(vn_pnl_in_val_cur, 2);
      vn_pnl_in_base_cur        := round(vn_pnl_in_val_cur, 2);
      vn_pnl_per_base_unit      := round(vn_pnl_in_base_cur /
                                         nvl(vn_qty_in_base, 1),
                                         5);
      vc_error_msg              := '16';
      vn_pnl_in_exch_price_unit := 0;

      vn_trade_day_pnl_per_base_unit := vn_pnl_in_base_cur / vn_qty_in_base;
     

      insert into psu_phy_stock_unrealized
        (process_id,
         psu_id,
         corporate_id,
         internal_gmr_ref_no,
         internal_contract_item_ref_no,
         product_id,
         product_name,
         origin_id,
         origin_name,
         quality_id,
         quality_name,
         container_no,
         stock_qty,
         qty_unit_id,
         qty_unit,
         no_of_units,
         md_id,
         m2m_price_unit_id,
         m2m_price_unit_str,
         m2m_amt,
         m2m_amt_cur_id,
         m2m_amt_cur_code,
         contract_value_in_price_cur,
         contract_price_cur_id,
         contract_price_cur_code,
         material_cost_in_base_cur,
         material_cost_in_val_cur,
         sc_in_base_cur,
         sc_in_valuation_cur,
         expected_cog_in_base_cur,
         expected_cog_in_val_cur,
         pnl_type,
         pnl_in_base_cur,
         pnl_in_val_cur,
         prev_day_pnl_in_base_cur,
         prev_day_pnl_in_val_cur,
         trade_day_pnl_in_base_cur,
         trade_day_pnl_in_val_cur,
         pnl_in_exch_price_unit,
         prev_pnl_in_exch_price_unit,
         day_pnl_in_exch_price_unit,
         pnl_per_base_unit,
         trade_day_pnl_per_base_unit,
         fw_fx_price_cur_to_m2m_cur,
         fw_fx_base_cur_to_m2m_cur,
         spot_rate_m2m_cur_to_base_cur,
         base_cur_id,
         base_cur_code,
         inventory_status,
         shipment_status,
         section_name,
         base_price_unit_id,
         qty_in_base_unit,
         m2m_price_unit_cur_id,
         m2m_price_unit_cur_code,
         m2m_price_unit_qty_unit_id,
         m2m_price_unit_qty_unit,
         m2m_price_unit_qty_unit_weight,
         spot_price_cur_to_base_cur,
         invm_inventory_status,
         strategy_id,
         strategy_name,
         valuation_month,
         contract_type,
         profit_center_id,
         net_m2m_price,
         unfxd_qty,
         fxd_qty,
         valuation_exchange_id,
         derivative_def_id,
         price_to_val_rate,
         val_to_base_rate,
         base_to_val_rate,
         sec_cost_ratio,
         gmr_contract_type,
         is_voyage_gmr,
         sc_to_val_fx_rate,
         sc_to_val_fx_rate_cur_id,
         sc_to_val_fx_rate_cur_code,
         int_alloc_group_id,
         internal_grd_dgrd_ref_no,
         vessel_id,
         charter_voyage_id,
         vessel_voyage_name,
         price_type_id,
         price_type_name,
         price_string,
         item_delivery_period_string,
         fixation_method,
         price_fixation_details,
         contract_price,
         price_unit_id,
         price_unit_cur_id,
         price_unit_cur_code,
         price_unit_weight_unit_id,
         price_unit_weight,
         price_unit_weight_unit,
         voyage_ref_no,
         stock_ref_no,
         trader_name,
         trader_id,
         unreal_pnl_in_base_per_unit,
         unreal_pnl_in_val_cur_per_unit,
         contract_premium_value,
         m2m_quality_premium,
         m2m_product_premium,
         m2m_loc_diff_premium,
         base_price_unit_id_in_ppu,
         base_price_unit_id_in_pum,
         market_premimum_amt,
         m2m_amt_per_unit,
         is_marked_for_consignment,
         price_to_base_fw_exch_rate,
         m2m_to_base_fw_exch_rate,
         m2m_ld_fw_exch_rate,
         m2m_qp_fw_exch_rate,
         m2m_pp_fw_exch_rate,
         contract_qp_fw_exch_rate,
         contract_pp_fw_exch_rate,
         accrual_to_base_fw_exch_rate,
         cp_profile_id,
         cp_name)
      values
        (pc_process_id,
         vc_psu_id,
         pc_corporate_id,
         cur_grd_rows.internal_gmr_ref_no,
         cur_grd_rows.internal_contract_item_ref_no,
         cur_grd_rows.product_id,
         cur_grd_rows.product_name,
         cur_grd_rows.origin_id,
         cur_grd_rows.origin_name,
         cur_grd_rows.quality_id,
         cur_grd_rows.quality_name,
         cur_grd_rows.container_no,
         cur_grd_rows.stock_qty,
         cur_grd_rows.qty_unit_id,
         cur_grd_rows.qty_unit,
         cur_grd_rows.no_of_units,
         cur_grd_rows.md_id,
         vc_m2m_price_unit_id,
         vc_m2m_price_unit_str,
         vn_m2m_total_amount,
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         vn_contract_value_in_price_cur,
         vc_price_cur_id,
         vc_price_cur_code,
         vn_contract_value_in_base_cur,
         vn_contract_value_in_base_cur,
         vn_sc_in_base_cur,
         vn_sc_in_base_cur,
         vn_expected_cog_net_sale_value,
         vn_expected_cog_in_val_cur,
         'Unrealized',
         vn_pnl_in_base_cur,
         vn_pnl_in_val_cur,
         null, -- prev_day_pnl_in_base_cur
         null, -- prev_day_pnl_in_val_cur
         null, -- trade_day_pnl_in_base_cur
         null, --  trade_day_pnl_in_val_cur
         vn_pnl_in_exch_price_unit,
         null, --   prev_pnl_in_exch_price_unit
         null, --  day_pnl_in_exch_price_unit
         vn_pnl_per_base_unit, --  v_pnl_per_base_unit
         vn_trade_day_pnl_per_base_unit,
         null, --fw_fx_price_cur_to_m2m_cur
         null, --fw_fx_base_cur_to_m2m_cur
         vn_corp_rate_val_to_base_cur,
         cur_grd_rows.base_cur_id,
         cur_grd_rows.base_cur_code,
         cur_grd_rows.inventory_status,
         cur_grd_rows.shipment_status,
         cur_grd_rows.section_name,
         vc_base_price_unit_id,
         vn_qty_in_base,
         cur_grd_rows.m2m_price_unit_cur_id, --   vc_m2m_price_unit_cur_id,
         cur_grd_rows.m2m_price_unit_cur_code, -- vc_m2m_price_unit_cur_code,
         cur_grd_rows.m2m_price_unit_weight_unit_id, -- vc_m2m_price_unit_qty_unit_id,
         cur_grd_rows.m2m_price_unit_weight_unit, --vc_m2m_price_unit_qty_unit,
         cur_grd_rows.m2m_price_unit_weight, --vn_m2m_price_unit_qty_unit_wt,
         null, --vn_fx_price_to_base, --vn_corp_rate_price_to_base_cur,
         cur_grd_rows.invm_inventory_status,
         cur_grd_rows.strategy_id,
         cur_grd_rows.strategy_name,
         cur_grd_rows.valuation_month,
         cur_grd_rows.purchase_sales,
         cur_grd_rows.profit_center,
         cur_grd_rows.net_m2m_price,
         cur_grd_rows.unfxd_qty,
         cur_grd_rows.fxd_qty,
         cur_grd_rows.valuation_exchange_id,
         cur_grd_rows.derivative_def_id,
         null, --vn_spot_rate_price_to_val_cur,
         vn_m2m_base_fx_rate, --vn_corp_rate_val_to_base_cur,
         null, --vn_spot_rate_base_to_val_cur,
         vn_ratio,
         cur_grd_rows.gmr_contract_type,
         cur_grd_rows.is_voyage_gmr,
         vn_spot_rate_base_to_val_cur,
         null, --sc_to_val_fx_rate_cur_id
         null, --sc_to_val_fx_rate_cur_code
         null, -- cur_grd_rows.int_alloc_group_id,
         cur_grd_rows.internal_grd_dgrd_ref_no,
         null, --cur_grd_rows.vessel_id,
         null, --cur_grd_rows.voyage_number,
         cur_grd_rows.vessel_name,
         null, -- cur_grd_rows.price_basis,
         null, --cur_grd_rows.price_type_name,
         null, --vc_price_string,
         null, -- cur_grd_rows.item_delivery_period_string
         vc_price_fixation_status,
         null, -- cur_grd_rows.price_fixation_details,
         vn_cont_price,
         vc_cont_price_unit_id,
         vc_cont_price_unit_cur_id,
         vc_cont_price_unit_cur_code,
         vc_cont_price_wt_unit_id,
         vn_cont_price_wt,
         vc_cont_price_wt_unit,
         null, --cur_grd_rows.voyage_ref_no,
         cur_grd_rows.stock_ref_no,
         cur_grd_rows.trader_user_name,
         cur_grd_rows.trader_id,
         vn_pnl_in_base_cur / decode(vn_qty_in_base, 0, 1, vn_qty_in_base),
         vn_pnl_in_val_cur / decode(vn_qty_in_base, 0, 1, vn_qty_in_base),
         vn_total_premium_value,
         cur_grd_rows.m2m_quality_premium,
         cur_grd_rows.m2m_product_premium,
         cur_grd_rows.m2m_loc_incoterm_deviation,
         cur_grd_rows.base_price_unit_id_in_ppu,
         cur_grd_rows.base_price_unit_id_in_pum,
         vn_m2m_total_premium_amt,
         vn_m2m_amt_per_unit,
         cur_grd_rows.is_marked_for_consignment,
         vc_price_to_base_fw_rate,
         vc_m2m_to_base_fw_rate,
         vc_m2m_ld_fw_exch_rate,
         vc_m2m_qp_fw_exch_rate,
         vc_m2m_pp_fw_exch_rate,
         vc_contract_qp_fw_exch_rate,
         vc_contract_pp_fw_exch_rate,
         cur_grd_rows.accrual_to_base_fw_exch_rate,
         cur_grd_rows.cp_id,
         cur_grd_rows.cp_name);
    end loop;
    -----------
    vc_error_msg := '17';
    commit;
    sp_gather_stats('psu_phy_stock_unrealized');
    sp_gather_stats('pcm_physical_contract_main');
    sp_gather_stats('pci_physical_contract_item');
    sp_gather_stats('cipd_contract_item_price_daily');
    dbms_output.put_line('finsihed loop');
    vc_error_msg := '18';
    begin
      --
      -- update previous eod data
      --
      for cur_update in (select psu_prev_day.unreal_pnl_in_base_per_unit,
                                psu_prev_day.unreal_pnl_in_val_cur_per_unit,
                                psu_prev_day.pnl_in_exch_price_unit,
                                psu_prev_day.m2m_quality_premium,
                                psu_prev_day.m2m_product_premium,
                                psu_prev_day.m2m_loc_diff_premium,
                                psu_prev_day.market_premimum_amt,
                                psu_prev_day.net_m2m_price,
                                psu_prev_day.m2m_price_unit_id,
                                psu_prev_day.m2m_amt,
                                psu_prev_day.m2m_amt_cur_id,
                                psu_prev_day.m2m_amt_cur_code,
                                psu_prev_day.psu_id,
                                psu_prev_day.m2m_amt_per_unit,
                                psu_prev_day.prev_market_value,
                                psu_prev_day.m_pnl_in_base_cur
                           from psu_phy_stock_unrealized psu_prev_day
                          where process_id = pc_previous_process_id
                            and corporate_id = pc_corporate_id)
      loop
        vc_error_msg := '19';
        update psu_phy_stock_unrealized psu_today
           set psu_today.prev_day_pnl_in_val_cur       = cur_update.unreal_pnl_in_val_cur_per_unit *
                                                         psu_today.qty_in_base_unit,
               psu_today.prev_day_pnl_in_base_cur      = cur_update.unreal_pnl_in_base_per_unit *
                                                         psu_today.qty_in_base_unit,
               psu_today.prev_pnl_in_exch_price_unit   = cur_update.pnl_in_exch_price_unit,
               psu_today.prev_m2m_quality_premium      = cur_update.m2m_quality_premium,
               psu_today.prev_m2m_product_premium      = cur_update.m2m_product_premium,
               psu_today.prev_m2m_loc_diff_premium     = cur_update.m2m_loc_diff_premium,
               psu_today.prev_market_premimum_amt      = cur_update.market_premimum_amt,
               psu_today.prev_market_price             = cur_update.net_m2m_price,
               psu_today.prev_market_price_unit_id     = cur_update.m2m_price_unit_id,
               psu_today.prev_market_value             = round(nvl(cur_update.m2m_amt_per_unit,
                                                                   0) *
                                                               psu_today.qty_in_base_unit,
                                                               4),
               psu_today.prev_market_value_cur_id      = cur_update.m2m_amt_cur_id,
               psu_today.prev_market_value_cur_code    = cur_update.m2m_amt_cur_code,
               psu_today.prev_m2m_amt_per_unit         = cur_update.m2m_amt_per_unit,
               psu_today.m_prev_day_pnl_in_base_cur    = (cur_update.m2m_amt -
                                                         cur_update.prev_market_value),
               psu_today.m_prev_day_pnl_in_val_cur     = (cur_update.m2m_amt -
                                                         cur_update.prev_market_value),
               psu_today.m_trade_day_pnl_per_base_unit = (psu_today.m_pnl_in_base_cur -
                                                         cur_update.m_pnl_in_base_cur) /
                                                         psu_today.qty_in_base_unit,
               psu_today.cont_unr_status               = 'EXISTING_TRADE'
         where psu_today.psu_id = cur_update.psu_id
           and psu_today.process_id = pc_process_id
           and psu_today.corporate_id = pc_corporate_id;
      end loop;
    exception
      when others then
        dbms_output.put_line('SQLERRM-1' || sqlerrm);
    end;
    vc_error_msg := '20';
    --
    -- mark the trades came as new in this eod/eom
    --
    begin
      update psu_phy_stock_unrealized psu
         set psu.prev_day_pnl_in_val_cur     = 0,
             psu.prev_day_pnl_in_base_cur    = 0,
             psu.prev_pnl_in_exch_price_unit = 0,
             psu.m_prev_day_pnl_in_base_cur  = 0,
             psu.m_prev_day_pnl_in_val_cur   = 0,
             psu.m_pnl_in_base_cur           = 0,
             psu.m_trade_day_pnl_in_base_cur = 0,
             psu.prev_m2m_quality_premium    = psu.m2m_quality_premium,
             psu.prev_m2m_product_premium    = psu.m2m_product_premium,
             psu.prev_m2m_loc_diff_premium   = psu.m2m_loc_diff_premium,
             psu.prev_market_premimum_amt    = psu.market_premimum_amt,
             psu.prev_market_price           = psu.net_m2m_price,
             psu.prev_market_price_unit_id   = psu.m2m_price_unit_id,
             psu.prev_market_value           = psu.m2m_amt,
             psu.prev_market_value_cur_id    = psu.m2m_amt_cur_id,
             psu.prev_market_value_cur_code  = psu.m2m_amt_cur_code,
             psu.prev_m2m_amt_per_unit       = psu.m2m_amt_per_unit,
             psu.cont_unr_status             = 'NEW_TRADE'
       where psu.cont_unr_status is null
         and psu.process_id = pc_process_id
         and psu.corporate_id = pc_corporate_id;
    exception
      when others then
        dbms_output.put_line('SQLERRM-2' || sqlerrm);
    end;
    vc_error_msg := '21';
    update psu_phy_stock_unrealized psu
       set psu.m_pnl_in_val_cur          = (psu.m2m_amt -
                                           psu.prev_market_value),
           psu.m_pnl_in_base_cur         = (psu.m2m_amt -
                                           psu.prev_market_value),
           psu.m_pnl_in_base_per_unit    = (psu.m2m_amt -
                                           psu.prev_market_value) /
                                           psu.qty_in_base_unit,
           psu.m_pnl_in_val_cur_per_unit = (psu.m2m_amt -
                                           psu.prev_market_value) /
                                           psu.qty_in_base_unit
     where psu.process_id = pc_process_id
       and psu.corporate_id = pc_corporate_id;
    --
    -- update trade day pnl values
    -- It is difference of unrealized pnl on trade date and previous eod For M2M PNL
    -- Else it is same as PNL as on Today
    --
    vc_error_msg := '22';
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Phy Stock Unrlzd',
                 'after loop' || vc_error_msg);
    update psu_phy_stock_unrealized psu
       set m_trade_day_pnl_in_val_cur    = nvl(psu.m_pnl_in_val_cur, 0) -
                                           nvl(psu.m_prev_day_pnl_in_val_cur,
                                               0),
           m_trade_day_pnl_in_base_cur   = nvl(psu.m_pnl_in_base_cur, 0) -
                                           nvl(psu.m_prev_day_pnl_in_base_cur,
                                               0),
           psu.trade_day_pnl_in_base_cur = psu.pnl_in_base_cur -
                                           psu.prev_day_pnl_in_base_cur,
           psu.trade_day_pnl_in_val_cur  = psu.pnl_in_val_cur -
                                           psu.prev_day_pnl_in_val_cur
     where psu.process_id = pc_process_id;
    sp_write_log(pc_corporate_id,
                 pd_trade_date,
                 'Phy Stock Unrlzd',
                 'after update' || vc_error_msg);
    --
    -- Insert into contract and price data for the contract items that are in pss
    --
    vc_error_msg := '23';
    update psu_phy_stock_unrealized pss
       set (gmr_ref_no, origination_city_id, --
           origination_country_id, --
           destination_city_id, --
           destination_country_id, --
           origination_city, --
           origination_country, --
           destination_city, --
           destination_country, --
           warehouse_id, --
           warehouse_name, --
           shed_id, --
           shed_name, --
           product_id, --
           prod_base_unit_id, --
           prod_base_unit) = --
            (select gmr.gmr_ref_no,
                    gmr.origin_city_id,
                    gmr.origin_country_id,
                    gmr.destination_city_id,
                    gmr.destination_country_id,
                    cim_orig.city_name as origin_city_name,
                    cym_orig.country_name origin_country_name,
                    cim_dest.city_name as destination_city_name,
                    cym_dest.country_name destination_country_name,
                    gmr.warehouse_profile_id,
                    phd_gmr.companyname as warehouse_profile_name,
                    gmr.shed_id,
                    sld.storage_location_name,
                    pss.product_id,
                    pdm.base_quantity_unit,
                    qum.qty_unit
               from gmr_goods_movement_record   gmr,
                    pdm_productmaster           pdm,
                    phd_profileheaderdetails    phd_gmr,
                    sld_storage_location_detail sld,
                    cim_citymaster              cim_orig,
                    cym_countrymaster           cym_orig,
                    cim_citymaster              cim_dest,
                    cym_countrymaster           cym_dest,
                    qum_quantity_unit_master    qum
              where gmr.internal_gmr_ref_no = pss.internal_gmr_ref_no
                and pss.product_id = pdm.product_id
                and pdm.base_quantity_unit = qum.qty_unit_id
                and gmr.warehouse_profile_id = phd_gmr.profileid(+)
                and gmr.shed_id = sld.storage_loc_id(+)
                and gmr.origin_city_id = cim_orig.city_id(+)
                and gmr.origin_country_id = cym_orig.country_id(+)
                and gmr.destination_city_id = cim_dest.city_id(+)
                and gmr.destination_country_id = cym_dest.country_id(+)
                and pss.process_id = gmr.process_id
                and pss.process_id = pc_process_id)
     where pss.process_id = pc_process_id;
    --
    --
    --
    vc_error_msg := '24';
    update md_m2m_daily md
       set md.m2m_price_unit_weight = null
     where md.m2m_price_unit_weight = 1
       and md.process_id = pc_process_id;
    vc_error_msg := '25';
    --
    -- Update Price_String from CIPD
    --
    for cur_price_string in (select cipd.internal_contract_item_ref_no,
                                    cipd.price_description,
                                    cipd.price_fixation_details
                               from cipd_contract_item_price_daily cipd
                              where cipd.process_id = pc_process_id)
    loop
      update psu_phy_stock_unrealized psu
         set psu.price_string           = cur_price_string.price_description,
             psu.price_fixation_details = cur_price_string.price_fixation_details
       where psu.process_id = pc_process_id
         and psu.internal_contract_item_ref_no =
             cur_price_string.internal_contract_item_ref_no;
    end loop;
  exception
    when others then
      dbms_output.put_line('failed with ' || sqlerrm);
      vobj_error_log.extend;
      vobj_error_log(vn_eel_error_count) := pelerrorlogobj(pc_corporate_id,
                                                           'procedure sp_stock_unreal_inv_in_bm ',
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
