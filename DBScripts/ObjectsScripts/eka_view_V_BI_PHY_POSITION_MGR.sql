CREATE OR REPLACE VIEW V_BI_PHY_POSITION_MGR AS
WITH ucm_mfact AS
        (SELECT ucm.from_qty_unit_id, ucm.to_qty_unit_id,
                qum_from.qty_unit qum_from_qty_unit,
                qum_to.qty_unit qum_to_qty_unit, ucm.multiplication_factor
           FROM ucm_unit_conversion_master ucm,
                qum_quantity_unit_master qum_to,
                qum_quantity_unit_master qum_from
          WHERE ucm.from_qty_unit_id = qum_from.qty_unit_id
            AND ucm.to_qty_unit_id = qum_to.qty_unit_id
            AND ucm.is_active = 'Y'
            AND qum_from.is_deleted = 'N'
            AND qum_to.is_deleted = 'N')
-- This is for Base Metal Only
-- 1) Open Contracts
select 'Standard' product_type,
       'Base Metal Open Contracts' section_name,
       pcm.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       css.strategy_id,
       css.strategy_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id, -- Newly Added
       pgm.product_group_name product_group, -- Newly Added
       nvl(qat.product_origin_id, 'NA') origin_id,
       nvl(orm.origin_name, 'NA') origin_name,
       qat.quality_id,
       qat.quality_name,
       (case
         when pcm.purchase_sales = 'P' then
          'Physical - Open Purchase'
         else
          'Physical - Open Sales'
       end) position_type_id,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       'Open' position_type,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') position_sub_type,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no contract_ref_no,
       nvl(pcm.cp_contract_ref_no, 'NA') external_reference_no,
       pcm.issue_date,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       pcm.partnership_type execution_type,
       'NA' broker_profile_id,
       'NA' broker_name,
       itm.incoterm_id,
       itm.incoterm,
       pym.payment_term_id,
       pym.payment_term,
       case
         when itm.location_field = 'ORIGINATION' then
          pcdb.country_id
         else
          'NA'
       end origination_country_id,
       case
         when itm.location_field = 'ORIGINATION' then
          cym_pcdb.country_name
         else
          'NA'
       end origination_country,
       case
         when itm.location_field = 'ORIGINATION' then
          cim_pcdb.city_id
         else
          'NA'
       end origination_city_id,
       case
         when itm.location_field = 'ORIGINATION' then
          cim_pcdb.city_name
         else
          'NA'
       end origination_city,
       nvl(pcdi.item_price_type, 'NA') price_type_name,
       pcm.invoice_currency_id pay_in_cur_id,
       cm_invoice_cur.cur_code pay_in_cur_code,
       'NA' item_price_string,
       case
         when itm.location_field = 'DESTINATION' then
          pcdb.country_id
         else
          'NA'
       end dest_country_id,
       case
         when itm.location_field = 'DESTINATION' then
          cym_pcdb.country_name
         else
          'NA'
       end dest_country_name,
       case
         when itm.location_field = 'DESTINATION' then
          cim_pcdb.city_id
         else
          'NA'
       end dest_city_id,
       case
         when itm.location_field = 'DESTINATION' then
          cim_pcdb.city_name
         else
          'NA'
       end dest_city_name,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_id
         else
          'NA'
       end dest_state_id, -- Newly Added
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_name
         else
          'NA'
       end dest_state_name, -- Newly Added
       case
         when itm.location_field = 'DESTINATION' then
          rem_pcdb.region_name
         else
          'NA'
       end dest_loc_group_name, -- Newly Added
       pci.expected_delivery_month || '-' || pci.expected_delivery_year period_month_year,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_from_date,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_to_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_to_date,
       (case
         when pcm.purchase_sales = 'P' then
          1
         else
          -1
       end) * ciqs.open_qty * ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (case
         when pcm.purchase_sales = 'P' then
          1
         else
          -1
       end) * ciqs.open_qty qty_in_ctract_unit,
       qum_ciqs.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pcm.invoice_currency_id invoice_cur_id,
       cm_invoice_cur.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       (case
         when pcm.purchase_sales = 'P' then
          1
         else
          -1
       end) * ciqs.open_qty *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pci.item_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty_in_base_unit,
       case
         when itm.location_field = 'DESTINATION' then
          pcdb.country_id
         else
          'NA'
       end || ' - ' || case
         when itm.location_field = 'DESTINATION' then
          pcdb.city_id
         else
          'NA'
       end comb_destination_id,
       case
         when itm.location_field = 'ORIGINATION' then
          pcdb.country_id
         else
          'NA'
       end || ' - ' || case
         when itm.location_field = 'ORIGINATION' then
          pcdb.city_id
         else
          'NA'
       end comb_origination_id,
       pci.m2m_country_id || ' - ' || pci.m2m_city_id comb_valuation_loc_id,
       'NA' element_name,
       nvl(phd_wh.profileid, 'NA') warehouse_profile_id,
       nvl(phd_wh.companyname, 'NA') warehouse_name,
       nvl(sld.storage_loc_id, 'NA') shed_id,
       nvl(sld.storage_location_name, 'NA')shed_name
  from pci_physical_contract_item    pci,
       pcm_physical_contract_main    pcm,
       pcmte_pcm_tolling_ext         pcmte, -- Newly Added
       pcdi_pc_delivery_item         pcdi,
       ak_corporate                  akc,
       pcpd_pc_product_definition    pcpd,
       cpc_corporate_profit_center   cpc,
       blm_business_line_master      blm,
       css_corporate_strategy_setup  css,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm, -- Newly Added
       pcpq_pc_product_quality       pcpq,
       qat_quality_attributes        qat,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       itm_incoterm_master           itm,
       pcdb_pc_delivery_basis        pcdb,
       pym_payment_terms_master      pym,
       ciqs_contract_item_qty_status ciqs,
       cm_currency_master            cm_base_cur,
       cm_currency_master            cm_invoice_cur,
       phd_profileheaderdetails      phd_contract_cp,
       pom_product_origin_master     pom,
       orm_origin_master             orm,
       cym_countrymaster             cym_pcdb,
       rem_region_master             rem_pcdb, --Newly Added
       cim_citymaster                cim_pcdb,
       sm_state_master               sm_pcdb, -- Newly Added
       qum_quantity_unit_master      qum_ciqs,
       gcd_groupcorporatedetails     gcd,
       qum_quantity_unit_master      qum_gcd,
       ucm_unit_conversion_master    ucm,
       ucm_mfact                     ucm_base,
       phd_profileheaderdetails      phd_wh,
       sld_storage_location_detail   sld
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+) -- Newly Added
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.pcpq_id = pcpq.pcpq_id
   and pcm.contract_status = 'In Position'
   and pcm.corporate_id = akc.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id
   and pcpd.strategy_id = css.strategy_id
   and pcpd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id -- Newly Added
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.is_active = 'Y'
   and pci.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and ciqs.is_active = 'Y'
   and pcdb.is_active = 'Y'
   and pcpq.quality_template_id = qat.quality_id
   and pcm.trader_id = akcu.user_id
   and akcu.gabid = gab.gabid
   and pci.pcdb_id = pcdb.pcdb_id
   and pcdb.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdb.inco_term_id = itm.incoterm_id
   and pcm.payment_term_id = pym.payment_term_id
   and pci.internal_contract_item_ref_no =
       ciqs.internal_contract_item_ref_no
   and pci.pcpq_id = pcpq.pcpq_id
   and pci.pcdb_id = pcdb.pcdb_id
   and cm_base_cur.cur_id = akc.base_cur_id
   and cm_invoice_cur.cur_id = akc.base_cur_id
   and phd_contract_cp.profileid = pcm.cp_id
   and qat.product_origin_id = pom.product_origin_id(+)
   and pom.origin_id = orm.origin_id(+)
   and ciqs.open_qty > 0
   and cym_pcdb.country_id = pcdb.country_id
   and cym_pcdb.region_id = rem_pcdb.region_id -- Newly Added
   and cim_pcdb.city_id = pcdb.city_id
   and sm_pcdb.state_id = pcdb.state_id -- Newly Added
   and qum_ciqs.qty_unit_id = ciqs.item_qty_unit_id
   and akc.groupid = gcd.groupid
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and ucm.from_qty_unit_id = ciqs.item_qty_unit_id
   and ucm.to_qty_unit_id = gcd.group_qty_unit_id
   and pcm.contract_type = 'BASEMETAL'
   and pcpq.quality_template_id = qat.quality_id
   and ciqs.item_qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and pcdb.warehouse_id = phd_wh.profileid(+)
   and pcdb.warehouse_shed_id = sld.storage_loc_id(+)

-- 2) Shipped But Not TT for Purchase GMRs
union all
select 'Standard' product_type,
       'Base Metal Shipped But Not TT for Purchase GMRs' section_name,
       gmr.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       grd.product_id product_id,
       pdm.product_desc product_desc,
       pgm.product_group_id, -- Newly Added
       pgm.product_group_name product_group,
       -- Newly Added
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
       'Physical - Open Purchase' position_type_id,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       'Open' position_type,
       'Purchase' position_sub_type,
       case
         when pci.contract_ref_no is not null then
          gmr.gmr_ref_no || ',' || pci.contract_ref_no || ',' ||
          pci.del_distribution_item_no
         else
          gmr.gmr_ref_no
       end contract_ref_no,
       nvl(pci.cp_contract_ref_no, 'NA') external_reference_no,
       gmr.eff_date issue_date,
       pci.cp_id counter_party_id,
       phd_pcm_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_name,
       pcm.partnership_type execution_type,
       'NA' broker_profile_id,
       'NA' broker_name,
       pci.incoterm_id incoterm_id,
       itm.incoterm incoterm,
       pci.payment_term_id payment_term_id,
       pym.payment_term payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       nvl(pci.item_price_type, 'NA') price_type_name,
       pci.invoice_currency_id pay_in_cur_id,
       cm_invoice_currency.cur_code pay_in_cur_code,
       'NA' item_price_string, -- do not need for GMR and Stocks
       nvl(cym_gmr.country_id, 'NA') dest_country_id,
       nvl(cym_gmr.country_name, 'NA') dest_country_name,
       nvl(cim_gmr.city_id, 'NA') dest_city_id,
       nvl(cim_gmr.city_name, 'NA') dest_city_name,
       nvl(sm_gmr.state_id, 'NA') dest_state_id, -- Newly Added
       nvl(sm_gmr.state_name, 'NA') dest_state_name, -- Newly Added
       nvl(rem_gmr.region_name, 'NA') dest_loc_group_name, -- Newly Added
       '' period_month_year,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_from_date,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_to_date,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) qty_in_ctract_unit,
       qum_grd.qty_unit ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * /*ucm_base.multiplication_factor qty_in_base_unit,*/
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pci.item_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty_in_base_unit,
       cym_gmr.country_id || ' - ' || cim_gmr.city_id comb_destination_id,
       'NA' comb_origination_id,
       nvl(case
             when grd.is_afloat = 'Y' then
              cym_gmr.country_id
             else
              cym_sld.country_id
           end || ' - ' || case
             when grd.is_afloat = 'Y' then
              cim_gmr.city_id
             else
              cim_sld.city_id
           end,
           'NA') comb_valuation_loc_id,
       'NA' element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       nvl(sld.storage_loc_id, 'NA'),
       nvl(sld.storage_location_name, 'NA')
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       pcm_physical_contract_main   pcm, -- Newly Added
       pcmte_pcm_tolling_ext        pcmte, -- Newly Added
       pcpd_pc_product_definition   pcpd, -- Newly Added
       sld_storage_location_detail  sld,
       cim_citymaster               cim_sld,
       cim_citymaster               cim_gmr,
       sm_state_master              sm_gmr, -- Newly Added
       cym_countrymaster            cym_sld,
       cym_countrymaster            cym_gmr,
       rem_region_master            rem_gmr, -- Newly Added
       v_pci_pcdi_details           pci,
       pdm_productmaster            pdm,
       pgm_product_group_master     pgm, -- Newly Added
       pdtm_product_type_master     pdtm,
       qum_quantity_unit_master     qum,
       itm_incoterm_master          itm,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       gcd_groupcorporatedetails    gcd,
       gab_globaladdressbook        gab,
       phd_profileheaderdetails     phd_pcm_cp,
       pym_payment_terms_master     pym,
       cm_currency_master           cm_invoice_currency,
       qum_quantity_unit_master     qum_gcd,
       ucm_unit_conversion_master   ucm,
       cm_currency_master           cm_base_currency,
       ucm_mfact                    ucm_base,
       ak_corporate_user            aku,
       qat_quality_attributes       qat,
       qum_quantity_unit_master     qum_grd,
       phd_profileheaderdetails     phd_wh
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no -- Newly Added
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+) -- Newly Added
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_group_id = pgm.product_group_id -- Newly Added
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and gmr.discharge_state_id = sm_gmr.state_id(+) -- Newly Added
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and cym_gmr.region_id = rem_gmr.region_id(+) -- Newly Added
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) > 0
   and gmr.created_by = aku.user_id
   and aku.gabid = gab.gabid(+)
   and pdtm.product_type_name = 'Standard'
   and phd_pcm_cp.profileid(+) = pci.cp_id
   and pym.payment_term_id(+) = pci.payment_term_id
   and nvl(gmr.inventory_status, 'NA') <> 'In'
   and cm_invoice_currency.cur_id(+) = pci.invoice_currency_id
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and gcd.group_qty_unit_id = ucm.to_qty_unit_id
   and cm_base_currency.cur_id = akc.base_cur_id
   and grd.qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and grd.qty_unit_id = qum_grd.qty_unit_id
   and grd.warehouse_profile_id = phd_wh.profileid(+)
   and grd.tolling_stock_type = 'None Tolling'
union all
-- 3) Shipped But Not TT for Sales GMRs
select 'Standard' product_type,
       'Base Metal Shipped But Not TT for Sales GMRs' section_name,
       akc.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       pdm.product_id product_id,
       pdm.product_desc product_desc,
       pgm.product_group_id, -- Newly Added
       pgm.product_group_name product_group,
       -- Newly Added
       'NA' origin_id,
       'NA' origin_name,
       qat.quality_id quality_id,
       qat.quality_name quality_name,
       'Physical - Open Sales' position_type_id,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       'Open' position_type,
       'Sales' position_sub_type,
       case
         when pci.contract_ref_no is not null then
          gmr.gmr_ref_no || ',' || pci.contract_ref_no || ',' ||
          pci.del_distribution_item_no
         else
          gmr.gmr_ref_no
       end contract_ref_no,
       nvl(pci.cp_contract_ref_no, 'NA') external_reference_no,
       pci.issue_date issue_date,
       pci.cp_id counter_party_id,
       phd_pcm_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_name,
       pcm.partnership_type execution_type,
       'NA' broker_profile_id,
       'NA' broker_name,
       itm.incoterm_id incoterm_id,
       itm.incoterm incoterm,
       pym.payment_term_id payment_term_id,
       pym.payment_term payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       'NA' price_type_name,
       cm_invoice_curreny.cur_id pay_in_cur_id,
       cm_invoice_curreny.cur_code pay_in_cur_code,
       pcbph.price_description item_price_string,
       nvl(case
             when itm.location_field = 'DESTINATION' then
              pcdb.country_id
             else
              'NA'
           end,
           'NA') destination_country_id,
       nvl(case
             when itm.location_field = 'DESTINATION' then
              cym_pcdb.country_name
             else
              'NA'
           end,
           'NA') destination_country,
       nvl(case
             when itm.location_field = 'DESTINATION' then
              cim_pcdb.city_id
             else
              'NA'
           end,
           'NA') destination_city_id,
       nvl(case
             when itm.location_field = 'DESTINATION' then
              cim_pcdb.city_name
             else
              'NA'
           end,
           'NA') destination_city,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_id
         else
          'NA'
       end dest_state_id, -- Newly Added
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_name
         else
          'NA'
       end dest_state_name, -- Newly Added
       case
         when itm.location_field = 'DESTINATION' then
          rem_pcdb.region_name
         else
          'NA'
       end dest_loc_group_name, -- Newly Added
       '' period_month_year,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_from_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_from_date,
       case
         when pci.delivery_period_type = 'Date' and pci.is_called_off = 'Y' then
          pci.delivery_to_date
         else
          to_date('01-' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year,
                  'dd-Mon-yyyy')
       end delivery_to_date,
       dgrd.current_qty * ucm.multiplication_factor * -1 qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       dgrd.current_qty * -1 qty_in_ctract_unit,
       qum_dgrd.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       to_char(sysdate, 'Mon-yyyy') delivery_month,
       cm_invoice_curreny.cur_id invoice_cur_id,
       cm_invoice_curreny.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       dgrd.current_qty *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pci.item_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) * -1 qty_in_base_unit,
       case
         when itm.location_field = 'DESTINATION' then
          pcdb.country_id
         else
          'NA'
       end || ' - ' || case
         when itm.location_field = 'DESTINATION' then
          pcdb.city_id
         else
          'NA'
       end comb_destination_id,
       'NA' comb_origination_id,
       '' comb_valuation_loc_id,
       'NA' element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       nvl(sld.storage_loc_id, 'NA'),
       nvl(sld.storage_location_name, 'NA')
  from dgrd_delivered_grd           dgrd,
       gmr_goods_movement_record    gmr,
       pcm_physical_contract_main   pcm, -- Newly Added
       pcmte_pcm_tolling_ext        pcmte, -- Newly Added
       pcpd_pc_product_definition   pcpd, -- Newly Added
       sld_storage_location_detail  sld,
       cim_citymaster               cim_sld,
       cim_citymaster               cim_gmr,
       cym_countrymaster            cym_sld,
       cym_countrymaster            cym_gmr,
       v_pci_pcdi_details           pci,
       pdm_productmaster            pdm,
       pgm_product_group_master     pgm, -- Newly Added
       pdtm_product_type_master     pdtm,
       qum_quantity_unit_master     qum,
       itm_incoterm_master          itm,
       qat_quality_attributes       qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       gcd_groupcorporatedetails    gcd,
       gab_globaladdressbook        gab,
       pym_payment_terms_master     pym,
       phd_profileheaderdetails     phd_pcm_cp,
       cm_currency_master           cm_invoice_curreny,
       pcbph_pc_base_price_header   pcbph,
       pcdb_pc_delivery_basis       pcdb,
       cim_citymaster               cim_pcdb,
       rem_region_master            rem_pcdb, -- Newly Added
       cym_countrymaster            cym_pcdb,
       sm_state_master              sm_pcdb, -- Newly Added
       qum_quantity_unit_master     qum_gcd,
       qum_quantity_unit_master     qum_dgrd,
       cm_currency_master           cm_base_cur,
       ucm_unit_conversion_master   ucm,
       ucm_mfact                    ucm_base,
       ak_corporate_user            aku,
       phd_profileheaderdetails     phd_wh
 where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and dgrd.product_id = pdm.product_id
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
      -- Newly Added
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
      -- Newly Added
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
      -- Newly Added
   and pdm.product_group_id = pgm.product_group_id -- Newly Added
   and pdm.product_type_id = pdtm.product_type_id
   and pdtm.product_type_name = 'Standard'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and dgrd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and dgrd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and dgrd.status = 'Active'
   and pcbph.is_active = 'Y'
   and pcdb.is_active = 'Y'
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and nvl(dgrd.current_qty, 0) > 0
   and nvl(dgrd.inventory_status, 'NA') <> 'Out'
   and aku.gabid = gab.gabid(+)
   and gmr.created_by = aku.user_id
   and phd_pcm_cp.profileid(+) = pci.cp_id
   and pym.payment_term_id(+) = pci.payment_term_id
   and pci.invoice_currency_id = cm_invoice_curreny.cur_id(+)
   and pcbph.internal_contract_ref_no(+) = pci.internal_contract_ref_no
   and pcdb.internal_contract_ref_no = pci.internal_contract_ref_no
   and pcdb.country_id = cym_pcdb.country_id(+)
   and cym_pcdb.region_id = rem_pcdb.region_id(+) -- Newly Added
   and pcdb.city_id = cim_pcdb.city_id(+)
   and pcdb.state_id = sm_pcdb.state_id(+) -- Newly Added
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id
   and cm_base_cur.cur_id = akc.base_cur_id
   and ucm.from_qty_unit_id = dgrd.net_weight_unit_id
   and ucm.to_qty_unit_id = gcd.group_qty_unit_id
   and dgrd.net_weight_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and dgrd.warehouse_profile_id = phd_wh.profileid(+)
   and dgrd.shed_id = sld.storage_loc_id(+)
   and dgrd.tolling_stock_type = 'None Tolling'
union all
-- 4) Stocks
select 'Standard' product_type,
       'Base Metal Stocks' section_name,
       gmr.corporate_id corporate_id,
       akc.corporate_name corporate_name,
       blm.business_line_id business_line_id,
       blm.business_line_name business_line_name,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center_short_name,
       cpc.profit_center_name profit_center_name,
       css.strategy_id strategy_id,
       css.strategy_name strategy_name,
       grd.product_id product_id,
       pdm.product_desc product_desc,
       pgm.product_group_id, -- Newly Added
       pgm.product_group_name product_group,
       -- Newly Added
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
       'Stocks -  Actual Stocks' position_type_id,
       (case
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'N' then
          'Purchase Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'N' then
          'Sales Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'Y' then
          'Internal Buy Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through = 'N' then
          'Buy Tolling Service Contract'
         when pcm.purchase_sales = 'S' and pcm.is_tolling_contract = 'Y' then
          'Sell Tolling Service Contract'
         when pcm.purchase_sales = 'P' and pcm.is_tolling_contract = 'Y' and
              pcmte.is_pass_through is null then
          'Tolling Service Contract'
       end) contract_type,
       'Inventory' position_type,
       'Stocks' position_sub_type,
       grd.internal_grd_ref_no contract_ref_no,
       'NA' external_reference_no,
       gmr.inventory_in_date issue_date,
       'NA' counter_party_id,
       'NA' counter_party_name,
       'NA',
       'NA' trader_name,
       pcm.partnership_type execution_type,
       'NA' broker_profile_id,
       'NA' broker_name,
       'NA' incoterm_id,
       'NA' incoterm,
       'NA' payment_term_id,
       'NA' payment_term,
       'NA' origination_country_id,
       'NA' origination_country,
       'NA' origination_city_id,
       'NA' origination_city,
       'NA' price_type_name,
       'NA' pay_in_cur_id,
       'NA' pay_in_cur_code,
       'NA' item_price_string, -- do not need for GMR and Stocks
       cym_gmr_dest_country.country_id dest_country_id,
       cym_gmr_dest_country.country_name dest_country_name,
       cim_gmr_dest_city.city_id dest_city_id,
       cim_gmr_dest_city.city_name dest_city_name,
       sm_gmr_dest_state.state_id dest_state_id, -- Newly Added
       sm_gmr_dest_state.state_name dest_state_name, -- Newly Added
       rem_dest.region_name dest_loc_group_name, -- Newly Added
       to_char(sysdate, 'Mon-yyyy') period_month_year,
       trunc(sysdate) delivery_from_date,
       trunc(sysdate) delivery_to_date,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) * ucm.multiplication_factor qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) qty_in_ctract_unit,
       grd.qty_unit_id ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       to_char(sysdate, 'Mon-yyyy') delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       ucm_base.qum_to_qty_unit base_qty_unit,
       (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pci.item_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) qty_in_base_unit,
       cym_gmr_dest_country.country_id || ' - ' ||
       cim_gmr_dest_city.city_id comb_destination_id,
       'NA' comb_origination_id,
       case
         when grd.is_afloat = 'Y' then
          cym_gmr.country_id
         else
          cym_sld.country_id
       end || ' - ' || case
         when grd.is_afloat = 'Y' then
          cim_gmr.country_id
         else
          cim_sld.country_id
       end comb_valuation_loc_id,
       'NA' element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       sld.storage_loc_id,
       sld.storage_location_name
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       pcm_physical_contract_main   pcm, -- Newly Added
       pcmte_pcm_tolling_ext        pcmte, -- Newly Added
       pcpd_pc_product_definition   pcpd, -- Newly Added
       sld_storage_location_detail  sld,
       cim_citymaster               cim_sld,
       cim_citymaster               cim_gmr,
       cym_countrymaster            cym_sld,
       cym_countrymaster            cym_gmr,
       v_pci_pcdi_details           pci,
       pdm_productmaster            pdm,
       pgm_product_group_master     pgm, -- Newly Added
       pdtm_product_type_master     pdtm,
       qum_quantity_unit_master     qum,
       itm_incoterm_master          itm,
       qat_quality_attributes       qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       gcd_groupcorporatedetails    gcd,
       phd_profileheaderdetails     phd_pcm_cp,
       cm_currency_master           cm_invoice_currency,
       cim_citymaster               cim_gmr_dest_city,
       cym_countrymaster            cym_gmr_dest_country,
       rem_region_master            rem_dest, -- Newly Added
       sm_state_master              sm_gmr_dest_state, -- Newly Added
       qum_quantity_unit_master     qum_gcd,
       ucm_unit_conversion_master   ucm,
       cm_currency_master           cm_base_currency,
       ucm_mfact                    ucm_base,
       phd_profileheaderdetails     phd_wh
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
      -- Newly Added
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
      -- Newly Added
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id -- Newly Added
   and pdm.product_type_id = pdtm.product_type_id
   and pdtm.product_type_name = 'Standard'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) > 0
   and phd_pcm_cp.profileid(+) = pci.cp_id
   and nvl(grd.inventory_status, 'NA') = 'In'
   and cm_invoice_currency.cur_id(+) = pci.invoice_currency_id
   and cym_gmr_dest_country.country_id(+) = gmr.discharge_country_id
      -- Modified
   and cim_gmr_dest_city.city_id(+) = gmr.discharge_city_id -- Modified
   and cim_gmr_dest_city.state_id = sm_gmr_dest_state.state_id(+)
      -- Newly Added
   and cym_gmr_dest_country.region_id = rem_dest.region_id(+)
      -- Newly Added
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and gcd.group_qty_unit_id = ucm.to_qty_unit_id
   and cm_base_currency.cur_id = akc.base_cur_id
   and grd.qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and grd.warehouse_profile_id = phd_wh.profileid(+)
   and grd.tolling_stock_type = 'None Tolling'
-- This is for Concentrate Only(1.Open Contracts,2.Shipped But Not TT,3.Stocks)
union all
select product_type,
       section_name,
       corporate_id,
       corporate_name,
       business_line_id,
       business_line_name,
       profit_center_id,
       profit_center_short_name,
       profit_center_name,
       strategy_id,
       strategy_name,
       product_id,
       product_desc,
       product_group_id,
       -- Newly Added
       product_group, -- Newly Added
       origin_id,
       origin_name,
       quality_id,
       quality_name,
       contract_type,
       position_type_id,
       position_type,
       position_sub_type,
       contract_ref_no,
       cp_contract_ref_no,
       issue_date,
       counter_party_id,
       counter_party_name,
       trader_user_id,
       trader_user_name,
       execution_type,
       broker_profile_id,
       broker_name,
       incoterm_id,
       incoterm,
       payment_term_id,
       payment_term,
       origination_country_id,
       origination_country,
       origination_city_id,
       origination_city,
       price_type_name,
       pay_in_cur_id,
       pay_in_cur_code,
       item_price_string,
       dest_country_id,
       dest_country_name,
       dest_city_id,
       dest_city_name,
       dest_state_id, -- Newly Added
       dest_state_name, -- Newly Added
       dest_loc_group_name, -- Newly Added
       period_month_year,
       delivery_from_date,
       delivery_to_date,
       qty_in_group_unit,
       group_qty_unit,
       qty_in_ctract_unit,
       ctract_qty_unit,
       corp_base_cur,
       delivery_month,
       invoice_cur_id,
       invoice_cur_code,
       base_qty_unit,
       qty_in_base_unit,
       comb_destination_id,
       comb_origination_id,
       comb_valuation_loc_id,
       element_name,
       warehouse_profile_id,
       warehouse_name,
       shed_id,
       shed_name
  from v_bi_conc_phy_position
