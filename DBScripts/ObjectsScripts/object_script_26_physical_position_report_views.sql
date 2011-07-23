create or replace view V_QAT_QUALITY_VALUATION
as
select cpm.corporate_id,
       qat.quality_id,
       pdd.product_id,
       qat.quality_name,
       dim.instrument_id,
       pdd.derivative_def_id derivative_def_id,
       dim.product_derivative_id product_derivative_id,
       qat.eval_basis,
       qat.date_type,
       qat.ship_arrival_date,
       qat.ship_arrival_days,
       cpm.exch_valuation_month
  from qat_quality_attributes     qat,
       pdm_productmaster          pdm,
       pdtm_product_type_master   pdtm,
       pdd_product_derivative_def pdd,
       dim_der_instrument_master  dim,
       irm_instrument_type_master irm,
       cpm_corporateproductmaster cpm
 where qat.product_id = pdd.product_id
   and pdd.derivative_def_id = dim.product_derivative_id
   and pdd.product_id = cpm.product_id
   and dim.instrument_type_id = irm.instrument_type_id
   and qat.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdtm.product_type_name = 'Standard'
   and irm.instrument_type = 'Future'
   and qat.instrument_id = pdd.derivative_def_id
   and qat.is_active = 'Y'
   and qat.is_deleted = 'N'
   and pdd.is_active = 'Y'
   and pdd.is_deleted = 'N'
   and dim.is_active = 'Y'
   and dim.is_deleted = 'N'
   and irm.is_active = 'Y'
   and irm.is_deleted = 'N'
   and cpm.is_active = 'Y'
   and cpm.is_deleted = 'N'
/
CREATE OR REPLACE VIEW V_CDC_DRM_VALUATION_DETAILS AS
select drm.dr_id,
       drm.instrument_id,
       pdd.derivative_def_id,
       irmf.instrument_type_id,
       emt.exchange_id,
       dim.instrument_name,
       irmf.instrument_type,
       (case
         when pdd.exchange_id is null then
          'Y'
         else
          'N'
       end) is_otc_instrument,
       emt.exchange_name,
       drm.dr_id_name contract_period,
       drm.prompt_date,
       drm.period_month,
       drm.period_year,
       nvl(drm.period_date, drm.prompt_date) period_date,
       pdd.product_id,
       pdd.derivative_def_name,
       pdd.lot_size,
       pdd.lot_size_unit_id,
       null packing_type_id,
       pdd.derivative_def_symbol derivative_symbol,
       qum.qty_unit qum_pdd_qty_unit,
       qum.decimals qum_pdd_decimals,
       drm.expiry_date
  from drm_derivative_master      drm,
       dim_der_instrument_master  dim,
       pdd_product_derivative_def pdd,
       irm_instrument_type_master irmf,
       emt_exchangemaster         emt,
       qum_quantity_unit_master   qum
 where drm.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.exchange_id = emt.exchange_id(+)
   and dim.instrument_type_id = irmf.instrument_type_id
   and pdd.lot_size_unit_id = qum.qty_unit_id(+)
 order by drm.dr_id
/
CREATE OR REPLACE VIEW V_CDC_LATEST_DERIVATIVE_QUOTES AS
select corporate_id,
       groupid,
       trade_date,
       dr_id,
       instrument_id,
       price_source_id,
       entry_type,
       available_price_id,
       settlement_price,
       strike_price,
       price_unit_id,
       strike_price_unit_id,
       publishing_frequency,
       publishing_frequency_type,
       diff_days,
       delta,
       gamma,
       theta,
       wega,
       available_price_name
  from (select dq.corporate_id,
               akc.groupid,
               dq.trade_date,
               dqd.dr_id,
               dq.instrument_id,
               dq.price_source_id,
               dq.entry_type,
               dqd.available_price_id,
               dqd.price settlement_price,
               drm.strike_price strike_price,
               dqd.price_unit_id,
               drm.strike_price_unit_id,
               ps.publishing_frequency,
               ps.publishing_frequency_type,
               to_date(sysdate, 'dd-mon-yyyy') - dq.trade_date diff_days,
               row_number() over(partition by dqd.dr_id, dqd.price_unit_id, dq.instrument_id, dq.entry_type, dq.price_source_id order by dq.trade_date desc) seq,
               nvl(dqd.delta, 0) delta,
               dqd.gamma,
               dqd.theta,
               dqd.wega,
               apm.available_price_name
          from dq_derivative_quotes        dq,
               dqd_derivative_quote_detail dqd,
               ps_price_source             ps,
               ak_corporate                akc,
               drm_derivative_master       drm,
               apm_available_price_master  apm
         where dq.dq_id = dqd.dq_id
           and dq.price_source_id = ps.price_source_id
           and dq.trade_date <= sysdate
           and dq.corporate_id = akc.corporate_id
           and dqd.dr_id = drm.dr_id
           and dq.is_deleted = 'N'
           and dqd.available_price_id = apm.available_price_id
           and dqd.is_deleted = 'N')
 where seq = 1
/
create or replace view v_gmr_exchange_details as
select pofh.internal_gmr_ref_no,
       ppfd.instrument_id,
       dim.instrument_name,
       pdd.derivative_def_id,
       pdd.derivative_def_name,
       emt.exchange_id,
       emt.exchange_name
  from pofh_price_opt_fixation_header pofh,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       ppfd_phy_price_formula_details ppfd,
       dim_der_instrument_master      dim,
       pdd_product_derivative_def     pdd,
       emt_exchangemaster             emt
 where pofh.pocd_id = pocd.pocd_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and ppfd.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.exchange_id = emt.exchange_id(+)
   and pofh.internal_gmr_ref_no is not null
   and pofh.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and ppfd.is_active = 'Y'
 group by pofh.internal_gmr_ref_no,
          ppfd.instrument_id,
          dim.instrument_name,
          pdd.derivative_def_id,
          pdd.derivative_def_name,
          emt.exchange_id,
          emt.exchange_name
/
create or replace view v_pci_exchange_details as
select tt.internal_contract_item_ref_no,
       tt.instrument_id,
       dim.instrument_name,
       pdd.derivative_def_id,
       pdd.derivative_def_name,
       emt.exchange_id,
       emt.exchange_name
  from (select pci.internal_contract_item_ref_no,
               ppfd.instrument_id
          from pci_physical_contract_item     pci,
               pcdi_pc_delivery_item          pcdi,
               poch_price_opt_call_off_header poch,
               pocd_price_option_calloff_dtls pocd,
               pcbpd_pc_base_price_detail     pcbpd,
               ppfh_phy_price_formula_header  ppfh,
               ppfd_phy_price_formula_details ppfd
         where pci.pcdi_id = pcdi.pcdi_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.poch_id = pocd.poch_id
           and pocd.pcbpd_id = pcbpd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id
           and pci.is_active = 'Y'
           and pcdi.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and pcbpd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and ppfd.is_active = 'Y'
           and pcdi.price_option_call_off_status in
               ('Called Off', 'Not Applicable')
         group by pci.internal_contract_item_ref_no,
                  ppfd.instrument_id
        union all
        select pci.internal_contract_item_ref_no,
               ppfd.instrument_id
          from pci_physical_contract_item     pci,
               pcdi_pc_delivery_item          pcdi,
               pcipf_pci_pricing_formula      pcipf,
               pcbph_pc_base_price_header     pcbph,
               pcbpd_pc_base_price_detail     pcbpd,
               ppfh_phy_price_formula_header  ppfh,
               ppfd_phy_price_formula_details ppfd
         where pci.internal_contract_item_ref_no =
               pcipf.internal_contract_item_ref_no
           and pcipf.pcbph_id = pcbph.pcbph_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id
           and pci.pcdi_id = pcdi.pcdi_id
           and pcdi.is_active = 'Y'
           and pcdi.price_option_call_off_status = 'Not Called Off'
           and pci.is_active = 'Y'
           and pcipf.is_active = 'Y'
           and pcbph.is_active = 'Y'
           and pcbpd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and ppfd.is_active = 'Y'
         group by pci.internal_contract_item_ref_no,
                  ppfd.instrument_id) tt,
       dim_der_instrument_master dim,
       pdd_product_derivative_def pdd,
       emt_exchangemaster emt
 where tt.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.exchange_id = emt.exchange_id(+)
 group by tt.internal_contract_item_ref_no,
          tt.instrument_id,
          dim.instrument_name,
          pdd.derivative_def_id,
          pdd.derivative_def_name,
          emt.exchange_id,
          emt.exchange_name
/
create or replace view v_pcdi_price_fixation_status as
select pcdi.pcdi_id,
       pci.internal_contract_item_ref_no,
       price_option_call_off_status,
       max(case
             when pcbpd.price_basis = 'Fixed' then
              'Fixed'
             else
              'Not Fixed'
           end) price_fixation_status
  from pcdi_pc_delivery_item          pcdi,
       pci_physical_contract_item     pci,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail     pcbpd,
       pcbph_pc_base_price_header     pcbph
 where poch.poch_id = pocd.poch_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and poch.pcdi_id = pcdi.pcdi_id
   and pci.pcdi_id = pcdi.pcdi_id
   and pci.is_active = 'Y'
   and pcdi.price_option_call_off_status in
       ('Called Off', 'Not Applicable')
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and pcbph.is_active = 'Y'
 group by price_option_call_off_status,
          pcdi.pcdi_id,
          pci.internal_contract_item_ref_no
-------
union all
select pci.pcdi_id,
       pci.internal_contract_item_ref_no,
       pcdi.price_option_call_off_status,
       max((case
             when pcbpd.price_basis = 'Fixed' then
              'Fixed'
             else
              'Not Fixed'
           end)) price_fixation_status
  from pci_physical_contract_item pci,
       pcdi_pc_delivery_item      pcdi,
       pcipf_pci_pricing_formula  pcipf,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd
 where pci.internal_contract_item_ref_no =
       pcipf.internal_contract_item_ref_no
   and pcipf.pcbph_id = pcbph.pcbph_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.price_option_call_off_status in ('Not Called Off')
   and pci.is_active = 'Y'
   and pcipf.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and pcbph.is_active = 'Y'
 group by pci.pcdi_id,
          pci.internal_contract_item_ref_no,
          pcdi.price_option_call_off_status
/
create or replace view v_pci_pcdi_details as
select pcdi.pcdi_id,
       pci.internal_contract_item_ref_no,
       pcdi.internal_contract_ref_no,
       pcdi.delivery_item_no,
       pcm.purchase_sales,
       pcm.contract_ref_no,
       pci.del_distribution_item_no,
       pcdb.inco_term_id,
       pcdb.country_id,
       pcdb.city_id,
       pcpd.strategy_id,
       pcpd.product_id,
       pcpd.profit_center_id,
       pcpq.quality_template_id,
       pcpq.assay_header_id,
       pcm.trader_id,
       pcm.cp_id,
       pcm.product_group_type,
       pcm.payment_term_id,
       pcdi.payment_due_date
  from pci_physical_contract_item pci,
       pcdi_pc_delivery_item      pcdi,
       pcdb_pc_delivery_basis     pcdb,
       pcm_physical_contract_main pcm,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality    pcpq
 where pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pci.pcdb_id = pcdb.pcdb_id
   and pcdi.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pci.pcpq_id = pcpq.pcpq_id
   and pci.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and pcm.contract_status <> 'Cancelled'
   and pcm.is_active = 'Y'
/
create or replace view v_pci_quantity_details as
select pcdi.pcdi_id,
       pci.internal_contract_item_ref_no,
       gcd.groupname corporate_group,
       blm.business_line_name business_line,
       akc.corporate_id,
       akc.corporate_name,
       cpc.profit_center_short_name profit_center,
       css.strategy_name strategy,
       pdm.product_desc product_name,
       qat.quality_name quality,
       gab.firstname || ' ' || gab.lastname trader,
       pdd.derivative_def_name instrument_name,
       itm.incoterm,
       cym.country_name,
       cim.city_name,
       (case
         when pci.delivery_period_type = 'Date' then
          pci.delivery_to_date
         when pci.delivery_period_type = 'Month' then
          to_date(('01' ||
                  nvl(pci.delivery_to_month, pci.expected_delivery_month) || '-' ||
                  nvl(pci.delivery_to_year, pci.expected_delivery_year)),
                  'dd-Mon-yyyy')
         when pci.delivery_period_type is null then
          to_date(('01' || pci.expected_delivery_month || '-' ||
                  pci.expected_delivery_year),
                  'dd-Mon-yyyy')
       end) delivery_date,
       pcm.purchase_sales,
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pci.item_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       pfs.price_fixation_status,
       ciqs.total_qty,
       ciqs.open_qty,
       (case
         when pfs.price_fixation_status = 'Fixed' then
          ciqs.total_qty
         else
          (case
         when nvl(diqs.price_fixed_qty, 0) <> 0 then
          ciqs.total_qty * (diqs.price_fixed_qty / diqs.total_qty)
         else
          0
       end) end) price_fixed_qty,
       ciqs.total_qty - (case
         when pfs.price_fixation_status = 'Fixed' then
          ciqs.total_qty
         else
          (case
         when nvl(diqs.price_fixed_qty, 0) <> 0 then
          ciqs.total_qty * (diqs.price_fixed_qty / diqs.total_qty)
         else
          0
       end) end) unfixed_qty,
       pci.item_qty_unit_id,
       qum.qty_unit,
       pcm.contract_ref_no,
       pcm.issue_date,
       pcdi.delivery_item_no,
       pci.del_distribution_item_no,
       ---id's
       gcd.groupid,
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       pdm.product_id,
       qat.quality_id,
       gab.gabid trader_id,
       pdd.derivative_def_id,
       qat.instrument_id,
       itm.incoterm_id,
       cym.country_id,
       cim.city_id,
       pdtm.product_type_id,
       pdtm.product_type_name
  from pcm_physical_contract_main    pcm,
       ciqs_contract_item_qty_status ciqs,
       ak_corporate                  akc,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       gcd_groupcorporatedetails     gcd,
       pcdi_pc_delivery_item         pcdi,
       pci_physical_contract_item    pci,
       pcdb_pc_delivery_basis        pcdb,
       pdm_productmaster             pdm,
       pdtm_product_type_master      pdtm,
       v_qat_quality_valuation       qat,
       pdd_product_derivative_def    pdd,
       dim_der_instrument_master     dim,
       pcpq_pc_product_quality       pcpq,
       itm_incoterm_master           itm,
       css_corporate_strategy_setup  css,
       pcpd_pc_product_definition    pcpd,
       cpc_corporate_profit_center   cpc,
       blm_business_line_master      blm,
       qum_quantity_unit_master      qum,
       diqs_delivery_item_qty_status diqs,
       cym_countrymaster             cym,
       cim_citymaster                cim,
       v_pcdi_price_fixation_status  pfs
 where pcm.corporate_id = akc.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.internal_contract_item_ref_no =
       ciqs.internal_contract_item_ref_no
   and pci.pcpq_id = pcpq.pcpq_id(+)
   and pci.pcdb_id = pcdb.pcdb_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcdb.inco_term_id = itm.incoterm_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.instrument_id = dim.instrument_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and qat.product_derivative_id = pdd.derivative_def_id
   and pcm.contract_status = 'In Position'
   and akc.groupid = gcd.groupid
   and pcm.trader_id = akcu.user_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and akcu.gabid = gab.gabid
   and pcdb.country_id = cym.country_id
   and pcdb.city_id = cim.city_id
   and pci.pcdi_id = pfs.pcdi_id
   and pci.internal_contract_item_ref_no =
       pfs.internal_contract_item_ref_no
/
---
create or replace view v_gmr_pfc_details as
select gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       nvl(blm.business_line_name, 'NA') business_line,
       gmr.corporate_id,
       nvl(cpc.profit_center_short_name, 'NA') profit_center,
       nvl(css.strategy_name, 'NA') strategy,
       pdm.product_desc product_name,
       qat.quality_name quality,
       (case
         when grd.is_afloat = 'Y' then
          cym_gmr.country_name
         else
          cym_sld.country_name
       end) country_name,
       (case
         when grd.is_afloat = 'Y' then
          cim_gmr.city_name
         else
          cim_sld.city_name
       end) city_name,
       to_date('01-Feb-1900', 'dd-Mon-yyyy') delivery_date,
       (case
         when nvl(gmr.contract_type, 'NA') = 'Purchase' then
          'P'
         when nvl(gmr.contract_type, 'NA') = 'Sales' then
          'S'
         when nvl(gmr.contract_type, 'NA') = 'B2B' then
          nvl(pci.purchase_sales, 'P')
       end) purchase_sales,
       gmr.qty gmr_qty,
       gmr_pfc.qty_to_be_fixed,
       gmr_pfc.priced_qty,
       gmr_pfc.unpriced_qty,
       gmr_pfc.qp_start_date,
       gmr_pfc.qp_end_date,
       pkg_general.f_get_converted_quantity(grd.product_id,
                                            gmr.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       sum(nvl(grd.qty, 0)) total_qty,
       sum(nvl(grd.current_qty, 0)) open_qty,
       grd.qty_unit_id item_qty_unit_id,
       qum.qty_unit,
       (case
         when grd.is_afloat = 'Y' then
          cym_gmr.country_id
         else
          cym_sld.country_id
       end) country_id,
       (case
         when grd.is_afloat = 'Y' then
          cim_gmr.city_id
         else
          cim_sld.city_id
       end) city_id,
       pdtm.product_type_name,
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       pdm.product_id,
       qat.quality_id,
       pdtm.product_type_id,
       v_gmr.instrument_id,
       v_gmr.instrument_name,
       v_gmr.derivative_def_id,
       v_gmr.derivative_def_name,
       v_gmr.exchange_id,
       v_gmr.exchange_name
  from grd_goods_record_detail grd,
       gmr_goods_movement_record gmr,
       v_gmr_exchange_details v_gmr,
       (select pofh.internal_gmr_ref_no,
               pofh.qty_to_be_fixed,
               round(nvl(pofh.priced_qty, 0), 5) priced_qty,
               round(pofh.qty_to_be_fixed -
                     round(nvl(pofh.priced_qty, 0), 5),
                     5) unpriced_qty,
               pofh.qp_start_date,
               pofh.qp_end_date
          from pofh_price_opt_fixation_header pofh
         where pofh.is_active = 'Y'
           and pofh.internal_gmr_ref_no is not null) gmr_pfc,
       sld_storage_location_detail sld,
       cim_citymaster cim_sld,
       cim_citymaster cim_gmr,
       cym_countrymaster cym_sld,
       cym_countrymaster cym_gmr,
       v_pci_pcdi_details pci,
       pdm_productmaster pdm,
       pdtm_product_type_master pdtm,
       qum_quantity_unit_master qum,
       itm_incoterm_master itm,
       qat_quality_attributes qat,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center cpc,
       blm_business_line_master blm,
       ak_corporate akc
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and gmr.internal_gmr_ref_no = gmr_pfc.internal_gmr_ref_no
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and gmr.internal_gmr_ref_no = v_gmr.internal_gmr_ref_no
 group by gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          nvl(blm.business_line_name, 'NA'),
          gmr.corporate_id,
          nvl(cpc.profit_center_short_name, 'NA'),
          nvl(css.strategy_name, 'NA'),
          gmr.qty_unit_id,
          pdm.product_desc,
          qat.quality_name,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_name
            else
             cym_sld.country_name
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
          gmr.contract_type,
          pci.purchase_sales,
          grd.product_id,
          grd.qty_unit_id,
          pdm.base_quantity_unit,
          grd.qty_unit_id,
          qum.qty_unit,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_id
            else
             cym_sld.country_id
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_id
            else
             cim_sld.city_id
          end),
          pdtm.product_type_name,
          blm.business_line_id,
          cpc.profit_center_id,
          css.strategy_id,
          pdm.product_id,
          gmr.qty,
          gmr_pfc.qty_to_be_fixed,
          gmr_pfc.priced_qty,
          gmr_pfc.unpriced_qty,
          gmr_pfc.qp_start_date,
          gmr_pfc.qp_end_date,
          qat.quality_id,
          pdtm.product_type_id,
          v_gmr.instrument_id,
          v_gmr.instrument_name,
          v_gmr.derivative_def_id,
          v_gmr.derivative_def_name,
          v_gmr.exchange_id,
          v_gmr.exchange_name
/
create or replace view v_gmr_stock_details as
select (case
         when grd.is_afloat = 'Y' then
          'Afloat'
         else
          'Stock'
       end) subsectionname,
       pci.internal_contract_ref_no,
       pci.inco_term_id,
       pci.pcdi_id,
       pci.internal_contract_item_ref_no,
       gcd.groupname corporate_group,
       nvl(blm.business_line_name, 'NA') business_line,
       gmr.corporate_id,
       akc.corporate_name,
       nvl(cpc.profit_center_short_name, 'NA') profit_center,
       nvl(css.strategy_name, 'NA') strategy,
       pdm.product_desc product_name,
       qat.quality_name quality,
       gab.firstname || ' ' || gab.lastname trader,
       pdd.derivative_def_name instrument_name,
       itm.incoterm,
       (case
         when grd.is_afloat = 'Y' then
          cym_gmr.country_name
         else
          cym_sld.country_name
       end) country_name,
       (case
         when grd.is_afloat = 'Y' then
          cim_gmr.city_name
         else
          cim_sld.city_name
       end) city_name,
       to_date('01-Feb-1900', 'dd-Mon-yyyy') delivery_date,
       (case
         when nvl(gmr.contract_type, 'NA') = 'Purchase' then
          'P'
         when nvl(gmr.contract_type, 'NA') = 'Sales' then
          'S'
         when nvl(gmr.contract_type, 'NA') = 'B2B' then
          nvl(pci.purchase_sales, 'P')
       end) purchase_sales,
       pkg_general.f_get_converted_quantity(grd.product_id,
                                            grd.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       null price_fixation_status,
       sum(nvl(grd.qty, 0)) total_qty,
       sum(nvl(grd.current_qty, 0)) open_qty,
       0 price_fixed_qty,
       0 unfixed_qty,
       grd.qty_unit_id item_qty_unit_id,
       qum.qty_unit,
       pci.contract_ref_no,
       pci.del_distribution_item_no,
       gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       (case
         when grd.is_afloat = 'Y' then
          cym_gmr.country_id
         else
          cym_sld.country_id
       end) country_id,
       (case
         when grd.is_afloat = 'Y' then
          cim_gmr.city_id
         else
          cim_sld.city_id
       end) city_id,
       pdtm.product_type_name,
       gcd.groupid,
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       pdm.product_id,
       qat.quality_id,
       gab.gabid trader_id,
       pdd.derivative_def_id,
       qat.instrument_id,
       pdtm.product_type_id
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       sld_storage_location_detail  sld,
       cim_citymaster               cim_sld,
       cim_citymaster               cim_gmr,
       cym_countrymaster            cym_sld,
       cym_countrymaster            cym_gmr,
       v_pci_pcdi_details           pci,
       pdm_productmaster            pdm,
       pdtm_product_type_master     pdtm,
       qum_quantity_unit_master     qum,
       itm_incoterm_master          itm,
       v_qat_quality_valuation      qat,
       pdd_product_derivative_def   pdd,
       dim_der_instrument_master    dim,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       gcd_groupcorporatedetails    gcd,
       gab_globaladdressbook        gab
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and qat.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
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
   and gmr.is_internal_movement = 'N'
   and nvl(grd.current_qty,0)>0
   and gmr.created_by = gab.gabid(+)
 group by pci.internal_contract_ref_no,
          (case
            when grd.is_afloat = 'Y' then
             'Afloat'
            else
             'Stock'
          end),
          pci.internal_contract_ref_no,
          pci.inco_term_id,
          pci.pcdi_id,
          pci.internal_contract_item_ref_no,
          gcd.groupname,
          nvl(blm.business_line_name, 'NA'),
          gmr.corporate_id,
          akc.corporate_name,
          nvl(cpc.profit_center_short_name, 'NA'),
          nvl(css.strategy_name, 'NA'),
          pdm.product_desc,
          qat.quality_name,
          gab.firstname || ' ' || gab.lastname,
          pdd.derivative_def_name,
          itm.incoterm,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_name
            else
             cym_sld.country_name
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
          (case
            when nvl(gmr.contract_type, 'NA') = 'Purchase' then
             'P'
            when nvl(gmr.contract_type, 'NA') = 'Sales' then
             'S'
            when nvl(gmr.contract_type, 'NA') = 'B2B' then
             nvl(pci.purchase_sales, 'P')
          end),
          grd.product_id,
          grd.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          pci.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_id
            else
             cym_sld.country_id
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_id
            else
             cim_sld.city_id
          end),pdtm.product_type_name,
       gcd.groupid,
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       pdm.product_id,
       qat.quality_id,
       gab.gabid,
       pdd.derivative_def_id,
       qat.instrument_id,
       pdtm.product_type_id
union all
select (case
         when grd.is_afloat = 'Y' then
          'Afloat'
         else
          'Stock'
       end) subsectionname,
       pci.internal_contract_ref_no,
       pci.inco_term_id,
       pci.pcdi_id,
       pci.internal_contract_item_ref_no,
       gcd.groupname corporate_group,
       nvl(blm.business_line_name, 'NA') business_line,
       gmr.corporate_id,
       akc.corporate_name,
       nvl(cpc.profit_center_short_name, 'NA') profit_center,
       nvl(css.strategy_name, 'NA') strategy,
       pdm.product_desc product_name,
       qat.quality_name quality,
       gab.firstname || ' ' || gab.lastname trader,
       pdd.derivative_def_name instrument_name,
       itm.incoterm,
       (case
         when grd.is_afloat = 'Y' then
          cym_gmr.country_name
         else
          cym_sld.country_name
       end) country_name,
       (case
         when grd.is_afloat = 'Y' then
          cim_gmr.city_name
         else
          cim_sld.city_name
       end) city_name,
       to_date('01-Feb-1900', 'dd-Mon-yyyy') delivery_date,
       (case
         when nvl(gmr.contract_type, 'NA') = 'Purchase' then
          'P'
         when nvl(gmr.contract_type, 'NA') = 'Sales' then
          'S'
         when nvl(gmr.contract_type, 'NA') = 'B2B' then
          nvl(pci.purchase_sales, 'P')
       end) purchase_sales,
       pkg_general.f_get_converted_quantity(grd.product_id,
                                            grd.qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) baseqty_conv_rate,
       null price_fixation_status,
       sum(nvl(grd.qty, 0)) total_qty,
       sum(nvl(grd.current_qty, 0)) open_qty,
       0 price_fixed_qty,
       0 unfixed_qty,
       grd.qty_unit_id item_qty_unit_id,
       qum.qty_unit,
       pci.contract_ref_no,
       pci.del_distribution_item_no,
       gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       (case
         when grd.is_afloat = 'Y' then
          cym_gmr.country_id
         else
          cym_sld.country_id
       end) country_id,
       (case
         when grd.is_afloat = 'Y' then
          cim_gmr.city_id
         else
          cim_sld.city_id
       end) city_id,
       pdtm.product_type_name,
       gcd.groupid,
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       pdm.product_id,
       qat.quality_id,
       gab.gabid trader_id,
       pdd.derivative_def_id,
       qat.instrument_id,
       pdtm.product_type_id
  from grd_goods_record_detail      grd,
       gmr_goods_movement_record    gmr,
       sld_storage_location_detail  sld,
       cim_citymaster               cim_sld,
       cim_citymaster               cim_gmr,
       cym_countrymaster            cym_sld,
       cym_countrymaster            cym_gmr,
       v_pci_pcdi_details           pci,
       pdm_productmaster            pdm,
       pdtm_product_type_master     pdtm,
       qum_quantity_unit_master     qum,
       itm_incoterm_master          itm,
       v_qat_quality_valuation      qat,
       pdd_product_derivative_def   pdd,
       dim_der_instrument_master    dim,
       css_corporate_strategy_setup css,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       ak_corporate                 akc,
       gcd_groupcorporatedetails    gcd,
       gab_globaladdressbook        gab
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and qat.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
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
   and gmr.is_internal_movement = 'Y'
   and nvl(grd.current_qty,0)>0
   and gmr.created_by = gab.gabid(+)
 group by pci.internal_contract_ref_no,
          (case
            when grd.is_afloat = 'Y' then
             'Afloat'
            else
             'Stock'
          end),
          pci.internal_contract_ref_no,
          pci.inco_term_id,
          pci.pcdi_id,
          pci.internal_contract_item_ref_no,
          gcd.groupname,
          nvl(blm.business_line_name, 'NA'),
          gmr.corporate_id,
          akc.corporate_name,
          nvl(cpc.profit_center_short_name, 'NA'),
          nvl(css.strategy_name, 'NA'),
          pdm.product_desc,
          qat.quality_name,
          gab.firstname || ' ' || gab.lastname,
          pdd.derivative_def_name,
          itm.incoterm,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_name
            else
             cym_sld.country_name
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_name
            else
             cim_sld.city_name
          end),
          (case
            when nvl(gmr.contract_type, 'NA') = 'Purchase' then
             'P'
            when nvl(gmr.contract_type, 'NA') = 'Sales' then
             'S'
            when nvl(gmr.contract_type, 'NA') = 'B2B' then
             nvl(pci.purchase_sales, 'P')
          end),
          grd.product_id,
          grd.qty_unit_id,
          pdm.base_quantity_unit,
          pdtm.product_type_name,
          qum.qty_unit,
          pci.contract_ref_no,
          pci.del_distribution_item_no,
          pci.internal_contract_item_ref_no,
          gmr.gmr_ref_no,
          gmr.internal_gmr_ref_no,
          (case
            when grd.is_afloat = 'Y' then
             cym_gmr.country_id
            else
             cym_sld.country_id
          end),
          (case
            when grd.is_afloat = 'Y' then
             cim_gmr.city_id
            else
             cim_sld.city_id
          end),pdtm.product_type_name,
       gcd.groupid,
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       pdm.product_id,
       qat.quality_id,
       gab.gabid,
       pdd.derivative_def_id,
       qat.instrument_id,
       pdtm.product_type_id
/
create or replace function f_get_pricing_month
(pc_Int_contract_Item_Ref_No in varchar2) return varchar2 is
  cursor cur_qp_end_date is
    select pcm.contract_ref_no,
           pcdi.pcdi_id,
           pcdi.internal_contract_ref_no,
           pci.internal_contract_item_ref_no,
           pcdi.delivery_item_no,
           pcdi.delivery_period_type,
           pcdi.delivery_from_month,
           pcdi.delivery_from_year,
           pcdi.delivery_to_month,
           pcdi.delivery_to_year,
           pcdi.delivery_from_date,
           pcdi.delivery_to_date,
           pcdi.basis_type,
           nvl(pcdi.transit_days, 0) transit_days,
           pcdi.qp_declaration_date,
           ppfh.ppfh_id,
           ppfh.price_unit_id,
           pocd.qp_period_type,
           pofh.qp_start_date,
           pofh.qp_end_date,
           pfqpp.event_name,
           pfqpp.no_of_event_months,
           pofh.pofh_id,
           pcbpd.price_basis    
      from pcdi_pc_delivery_item          pcdi,
           pci_physical_contract_item     pci,
           pcm_physical_contract_main     pcm,
           poch_price_opt_call_off_header poch,
           pocd_price_option_calloff_dtls pocd,
           pofh_price_opt_fixation_header pofh,
           pcbpd_pc_base_price_detail     pcbpd,
           ppfh_phy_price_formula_header  ppfh,
           pfqpp_phy_formula_qp_pricing   pfqpp    
     where pcdi.pcdi_id = pci.pcdi_id
       and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
       and pcdi.pcdi_id = poch.pcdi_id
       and poch.poch_id = pocd.poch_id
       and pocd.pocd_id = pofh.pocd_id(+)
       and pocd.pcbpd_id = pcbpd.pcbpd_id
       and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
       and ppfh.ppfh_id = pfqpp.ppfh_id(+)
       and pcm.contract_status = 'In Position'
       and pcm.contract_type = 'BASEMETAL'
       and pcbpd.price_basis <> 'Fixed'
       and pci.item_qty > 0
       and pcdi.is_active = 'Y'
       and pci.is_active = 'Y'
       and pcm.is_active = 'Y'
       and poch.is_active = 'Y'
       and pocd.is_active = 'Y'
       and pofh.is_active(+) = 'Y'
       and pcbpd.is_active = 'Y'
       and pci.internal_contract_item_ref_no = pc_Int_contract_Item_Ref_No;
  --and pfqpp.is_active = 'Y'
  --and pofh.is_active(+) = 'Y';

  vd_qp_start_date date;
  vd_qp_end_date   date;
  vd_shipment_date date;
  vd_arrival_date  date;
  vd_evevnt_date   date;

begin

  for cur_rows in cur_qp_end_date loop
    if cur_rows.price_basis in ('Index', 'Formula') then
    
      if cur_rows.basis_type = 'Shipment' then
        if cur_rows.delivery_period_type = 'Month' then
          vd_shipment_date := last_day('01-' || cur_rows.delivery_to_month || '-' ||
                                       cur_rows.delivery_to_year);
        elsif cur_rows.delivery_period_type = 'Date' then
          vd_shipment_date := cur_rows.delivery_to_date;
        end if;
        vd_arrival_date := vd_shipment_date + cur_rows.transit_days;
      
      elsif cur_rows.basis_type = 'Arrival' then
        if cur_rows.delivery_period_type = 'Month' then
          vd_arrival_date := last_day('01-' || cur_rows.delivery_to_month || '-' ||
                                      cur_rows.delivery_to_year);
        elsif cur_rows.delivery_period_type = 'Date' then
          vd_arrival_date := cur_rows.delivery_to_date;
        end if;
        vd_shipment_date := vd_arrival_date - cur_rows.transit_days;
      end if;
    
      if cur_rows.qp_period_type = 'Period' then
        vd_qp_start_date := cur_rows.qp_start_date;
        vd_qp_end_date   := cur_rows.qp_end_date;
      elsif cur_rows.qp_period_type = 'Month' then
        vd_qp_start_date := cur_rows.qp_start_date;
        vd_qp_end_date   := cur_rows.qp_end_date;
      elsif cur_rows.qp_period_type = 'Date' then
        vd_qp_start_date := cur_rows.qp_start_date;
        vd_qp_end_date   := cur_rows.qp_end_date;
      elsif cur_rows.qp_period_type = 'Event' then
        if cur_rows.event_name = 'Month After Month Of Shipment' then
          vd_evevnt_date   := add_months(vd_shipment_date,
                                         cur_rows.no_of_event_months);
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_evevnt_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'Month After Month Of Arrival' then
          vd_evevnt_date   := add_months(vd_arrival_date,
                                         cur_rows.no_of_event_months);
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_evevnt_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'Month Before Month Of Shipment' then
          vd_evevnt_date   := add_months(vd_shipment_date,
                                         -1 * cur_rows.no_of_event_months);
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_evevnt_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'Month Before Month Of Arrival' then
          vd_evevnt_date   := add_months(vd_arrival_date,
                                         -1 * cur_rows.no_of_event_months);
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_evevnt_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'First Half Of Shipment Month' then
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_shipment_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := to_date('15-' ||
                                      to_char(vd_shipment_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
        elsif cur_rows.event_name = 'First Half Of Arrival Month' then
          vd_qp_start_date := to_date('01-' ||
                                      to_char(vd_arrival_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := to_date('15-' ||
                                      to_char(vd_arrival_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
        elsif cur_rows.event_name = 'First Half Of Shipment Month' then
          vd_qp_start_date := to_date('16-' ||
                                      to_char(vd_shipment_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        elsif cur_rows.event_name = 'Second Half Of Arrival Month' then
          vd_qp_start_date := to_date('16-' ||
                                      to_char(vd_arrival_date, 'Mon-yyyy'),
                                      'dd-mon-yyyy');
          vd_qp_end_date   := last_day(vd_qp_start_date);
        end if;
      end if;
    
    end if;
  end loop;

  return to_char(last_day(vd_qp_end_date), 'dd-Mon-yyyy');
end f_get_pricing_month;
/
create or replace view v_pci_quantity_details_by_qp as
select pcdi.pcdi_id,
                pci.internal_contract_item_ref_no,
                gcd.groupname corporate_group,
                blm.business_line_name business_line,
                akc.corporate_id,
                akc.corporate_name,
                cpc.profit_center_short_name profit_center,
                css.strategy_name strategy,
                pdm.product_desc product_name,
                qat.quality_name quality,
                gab.firstname || ' ' || gab.lastname trader,
                pdd.derivative_def_name instrument_name,
                itm.incoterm,
                cym.country_name,
                cim.city_name,
                to_date(f_get_pricing_month(pci.internal_contract_item_ref_no),
                        'dd-Mon-yyyy') delivery_date,
                pcm.purchase_sales,
                pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                     pci.item_qty_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1) baseqty_conv_rate,
                pfs.price_fixation_status,
                ciqs.total_qty,
                ciqs.open_qty,
                round((case
                        when pfs.price_fixation_status = 'Fixed' then
                         ciqs.total_qty
                        else
                         (case
                        when nvl(diqs.price_fixed_qty, 0) <> 0 then
                         ciqs.total_qty * (diqs.price_fixed_qty / diqs.total_qty)
                        else
                         0
                      end) end), 4) price_fixed_qty,
                round(ciqs.total_qty - (case
                        when pfs.price_fixation_status = 'Fixed' then
                         ciqs.total_qty
                        else
                         (case
                        when nvl(diqs.price_fixed_qty, 0) <> 0 then
                         ciqs.total_qty * (diqs.price_fixed_qty / diqs.total_qty)
                        else
                         0
                      end) end), 4) unfixed_qty,
                pci.item_qty_unit_id,
                qum.qty_unit,
                pcm.contract_ref_no,
                pcm.issue_date,
                pcdi.delivery_item_no,
                pci.del_distribution_item_no,
                ---id's
               gcd.groupid,
               blm.business_line_id,
               cpc.profit_center_id,
               css.strategy_id,
               pdm.product_id,
               qat.quality_id,
               gab.gabid trader_id,
               pdd.derivative_def_id,
               qat.instrument_id,
               itm.incoterm_id,
               cym.country_id,
               cim.city_id,
               pdtm.product_type_id,
               pdtm.product_type_name
          from pcm_physical_contract_main    pcm,
               ciqs_contract_item_qty_status ciqs,
               ak_corporate                  akc,
               ak_corporate_user             akcu,
               gab_globaladdressbook         gab,
               gcd_groupcorporatedetails     gcd,
               pcdi_pc_delivery_item         pcdi,
               pci_physical_contract_item    pci,
               pcdb_pc_delivery_basis        pcdb,
               pdm_productmaster             pdm,
               pdtm_product_type_master      pdtm,
               v_qat_quality_valuation       qat,
               pdd_product_derivative_def    pdd,
               dim_der_instrument_master     dim,
               pcpq_pc_product_quality       pcpq,
               itm_incoterm_master           itm,
               css_corporate_strategy_setup  css,
               pcpd_pc_product_definition    pcpd,
               cpc_corporate_profit_center   cpc,
               blm_business_line_master      blm,
               qum_quantity_unit_master      qum,
               diqs_delivery_item_qty_status diqs,
               cym_countrymaster             cym,
               cim_citymaster                cim,
               v_pcdi_price_fixation_status  pfs
         where pcm.corporate_id = akc.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcdi.pcdi_id = pci.pcdi_id
           and pci.internal_contract_item_ref_no =
               ciqs.internal_contract_item_ref_no
           and pci.pcpq_id = pcpq.pcpq_id(+)
           and pci.pcdb_id = pcdb.pcdb_id
           and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
           and pcdb.inco_term_id = itm.incoterm_id
           and pcpq.quality_template_id = qat.quality_id
           and qat.instrument_id = dim.instrument_id
           and pcm.internal_contract_ref_no =
               pcpd.internal_contract_ref_no(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and pcpd.product_id = pdm.product_id
           and pdm.product_type_id = pdtm.product_type_id
           and pcpd.strategy_id = css.strategy_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and qat.product_derivative_id = pdd.derivative_def_id
           and pcm.contract_status = 'In Position'
           and akc.groupid = gcd.groupid
           and pcm.trader_id = akcu.user_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and pcdi.pcdi_id = diqs.pcdi_id
           and akcu.gabid = gab.gabid
           and pcdb.country_id = cym.country_id
           and pcdb.city_id = cim.city_id
           and pci.pcdi_id = pfs.pcdi_id
           and pci.internal_contract_item_ref_no =
               pfs.internal_contract_item_ref_no
           and pfs.price_fixation_status <> 'Fixed'
/