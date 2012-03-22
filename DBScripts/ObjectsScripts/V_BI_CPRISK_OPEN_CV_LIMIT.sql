CREATE OR REPLACE VIEW V_BI_CPRISK_OPEN_CV_LIMIT AS
select tt.corporate_id,
       tt.profileid,
       tt.companyname,
       nvl(cpr.value_exposure, 0) alloted_open_cv_limit,
       tt.current_open_cv_usage,
       tt.current_open_cv_usage - nvl(cpr.value_exposure, 0) breach,
       tt.order_id,
       tt.base_cur_id,
       tt.base_cur_code
  from (select t.corporate_id,
               t.profileid,
               t.companyname,
               --       0 alloted_open_cv_limit,
               sum(t.current_open_cv_usage) current_open_cv_usage,
               t.base_cur_id,
               t.base_cur_code,
               rank() over(partition by t.corporate_id order by sum(t.current_open_cv_usage) desc) order_id
          from (select akc.corporate_id,
                       pcm.cp_id profileid,
                       phd_contract_cp.companyname companyname,
                       round((pcdi.item_price / nvl(pum.weight, 1)) *
                             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                                      pum.cur_id,
                                                                      akc.base_cur_id,
                                                                      pcm.issue_date,
                                                                      1) *
                             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                   ciqs.item_qty_unit_id,
                                                                   pum.weight_unit_id,
                                                                   ciqs.open_qty)),
                             2) * (case
                                     when pcm.purchase_sales = 'P' then
                                      -1
                                     else
                                      1
                                   end) current_open_cv_usage,
                       cm_base.cur_id base_cur_id,
                       cm_base.cur_code base_cur_code
                  from pcm_physical_contract_main    pcm,
                       pcdi_pc_delivery_item         pcdi,
                       pci_physical_contract_item    pci,
                       ciqs_contract_item_qty_status ciqs,
                       ak_corporate                  akc,
                       cpc_corporate_profit_center   cpc,
                       pcpd_pc_product_definition    pcpd,
                       cm_currency_master            cm_base,
                       css_corporate_strategy_setup  css,
                       pdm_productmaster             pdm,
                       ppu_product_price_units       ppu,
                       pum_price_unit_master         pum,
                       blm_business_line_master      blm,
                       pgm_product_group_master      pgm,
                       phd_profileheaderdetails      phd_contract_cp,
                       ak_corporate_user             akcu,
                       gab_globaladdressbook         gab,
                       qum_quantity_unit_master      qum
                 where pcm.internal_contract_ref_no =
                       pcdi.internal_contract_ref_no
                   and pcdi.pcdi_id = pci.pcdi_id
                   and pcdi.item_price_type = 'Fixed'
                   and pci.internal_contract_item_ref_no =
                       ciqs.internal_contract_item_ref_no
                   and ciqs.open_qty > 0
                   and pcm.corporate_id = akc.corporate_id
                   and pcm.internal_contract_ref_no =
                       pcpd.internal_contract_ref_no
                   and pcpd.profit_center_id = cpc.profit_center_id
                   and akc.base_cur_id = cm_base.cur_id
                   and pcpd.strategy_id = css.strategy_id
                   and pcpd.product_id = pdm.product_id
                   and ppu.internal_price_unit_id = pcdi.item_price_unit
                   and ppu.price_unit_id = pum.price_unit_id
                   and pcm.contract_type = 'BASEMETAL'
                   and cpc.business_line_id = blm.business_line_id(+)
                   and pcpd.product_id = pdm.product_id(+)
                   and pdm.product_group_id = pgm.product_group_id
                   and phd_contract_cp.profileid(+) = pcm.cp_id
                   and pcm.trader_id = akcu.user_id(+)
                   and akcu.gabid = gab.gabid(+)
                   and ciqs.item_qty_unit_id = qum.qty_unit_id(+)
                   and nvl(pgm.is_active, 'Y') = 'Y'
                   and nvl(gab.is_active, 'Y') = 'Y'
                -- Price Basis Index or Formula from EOD
                union all
                select t.corporate_id,
                       t.cp_id,
                       t.cp_name,
                       sum( (case
                             when t.position_sub_type = 'Open Purchase' then
                              -1
                             else
                              1
                           end) * t.net_contract_value),
                       t.base_cur_id,
                       t.base_cur_code
                  from mv_fact_phy_unreal_fixed_price t
                 where t.position_sub_type in ('Open Purchase', 'Open Sales')
                 group by t.corporate_id,
                          t.cp_id,
                          t.cp_name,
                          t.base_cur_id,
                          t.base_cur_code) t
         group by t.corporate_id,
                  t.profileid,
                  t.companyname,
                  t.base_cur_id,
                  t.base_cur_code) tt,
       v_bi_cprisk_crc_limits cpr
 where tt.profileid = cpr.profile_id(+)
   and tt.corporate_id = cpr.corporate_id(+)
   and tt.order_id <= 5
