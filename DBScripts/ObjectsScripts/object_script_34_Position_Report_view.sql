create or replace view v_gmr_exchange_details as
select pofh.internal_gmr_ref_no,
       ppfd.instrument_id,
       dim.instrument_name,
       pdd.derivative_def_id,
       pdd.derivative_def_name,
       emt.exchange_id,
       emt.exchange_name,
       pcbpd.element_id
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
          emt.exchange_name,pcbpd.element_id
/
CREATE OR REPLACE VIEW V_QAT_QUALITY_VALUATION
AS
select cpm.corporate_id,
       qat.quality_id,
       pdd.product_id,
       qat.quality_name,
       dim.instrument_id,
       pdd.derivative_def_id derivative_def_id,
       pdd.derivative_def_id product_derivative_id,
       nvl(qat.eval_basis,'FIXED')eval_basis,
       qat.date_type,
       qat.ship_arrival_date,
       qat.ship_arrival_days,
       nvl(qat.exch_valuation_month, cpm.exch_valuation_month) exch_valuation_month
  from qat_quality_attributes     qat,
       pdm_productmaster          pdm,
       pdtm_product_type_master   pdtm,
       pdd_product_derivative_def pdd,
       dim_der_instrument_master  dim,
       irm_instrument_type_master irm,
       cpm_corporateproductmaster cpm
 where qat.product_id = pdd.product_id
   and pdd.derivative_def_id = dim.product_derivative_id
   and pdd.product_id = cpm.product_id(+)
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
union all
select cpm.corporate_id,
       qat.quality_id,
       qat.product_id,
       qat.quality_name,
       null instrument_id,
       'OTC' derivative_def_id,
       'OTC' product_derivative_id,
       nvl(qat.eval_basis,'FIXED')eval_basis,
       qat.date_type,
       qat.ship_arrival_date,
       qat.ship_arrival_days,
       cpm.exch_valuation_month
  from qat_quality_attributes     qat,
       pdm_productmaster          pdm,
       pdtm_product_type_master   pdtm,
       cpm_corporateproductmaster cpm
 where qat.product_id = cpm.product_id
   and qat.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
  -- and pdtm.product_type_name = 'Standard'
   and qat.instrument_id is null
   and qat.is_active = 'Y'
   and qat.is_deleted = 'N'
   and cpm.is_active = 'Y'
   and cpm.is_deleted = 'N'   
/
create or replace view v_pci_exchange_details as
select tt.internal_contract_item_ref_no,
       tt.element_id,
       tt.instrument_id,
       dim.instrument_name,
       pdd.derivative_def_id,
       pdd.derivative_def_name,
       emt.exchange_id,
       emt.exchange_name
  from (select pci.internal_contract_item_ref_no,
               poch.element_id,
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
                  ppfd.instrument_id, poch.element_id
        union all
        select pci.internal_contract_item_ref_no,
               ppfd.instrument_id,pcbph.element_id
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
                  ppfd.instrument_id,pcbph.element_id) tt,
       dim_der_instrument_master dim,
       pdd_product_derivative_def pdd,
       emt_exchangemaster emt
 where tt.instrument_id = dim.instrument_id
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.exchange_id = emt.exchange_id(+)
 group by tt.internal_contract_item_ref_no,tt.element_id,
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
       pcdi.price_option_call_off_status,
       max(case
             when pcbpd.price_basis = 'Fixed' then
              'Fixed'
             else
              'Not Fixed'
           end) price_fixation_status,
       poch.element_id
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
          pci.internal_contract_item_ref_no,
          poch.element_id
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
           end)) price_fixation_status,
       pcbpd.element_id
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
          pcdi.price_option_call_off_status,
          pcbpd.element_id
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
       to_date(('01' || pci.expected_delivery_month || '-' ||
               pci.expected_delivery_year),
               'dd-Mon-yyyy') delivery_date,
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
       pdtm.product_type_name,
       pcpq.assay_header_id,
       pcpq.unit_of_measure,
       null attribute_id,
       null attribute_name,
       null element_qty_unit_id,
       null underlying_product_id,
       pcm.contract_type position_type
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
   and pcm.corporate_id = qat.corporate_id
   and qat.instrument_id = dim.instrument_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and qat.product_derivative_id = pdd.derivative_def_id
   and pcm.contract_status = 'In Position'
   and pcm.contract_type = 'BASEMETAL'
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
union all
select pcdi.pcdi_id,
       pci.internal_contract_item_ref_no,
       gcd.groupname corporate_group,
       blm.business_line_name business_line,
       akc.corporate_id,
       akc.corporate_name,
       cpc.profit_center_short_name profit_center,
       css.strategy_name strategy,
       (case
         when pdtm.product_type_name = 'Composite' then
          nvl(pdm_under.product_desc, pdm.product_desc)
         else
          pdm.product_desc
       end) product_name,
       nvl(qav_qat.quality_name, qat.quality_name) quality,
       gab.firstname || ' ' || gab.lastname trader,
       null instrument_name,
       itm.incoterm,
       cym.country_name,
       cim.city_name,
       to_date(('01' || pci.expected_delivery_month || '-' ||
               pci.expected_delivery_year),
               'dd-Mon-yyyy') delivery_date,
       pcm.purchase_sales,
       (case
         when pdtm.product_type_name = 'Composite' then
          (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
       end) else(pkg_general.f_get_converted_quantity(pcpd.product_id, pci.item_qty_unit_id, pdm.base_quantity_unit, 1)) end) baseqty_conv_rate,
       
       null price_fixation_status,
       pkg_report_general.fn_get_element_qty(pci.internal_contract_item_ref_no,
                                             ciqs.total_qty,
                                             ciqs.item_qty_unit_id,
                                             pcpq.assay_header_id,
                                             aml.attribute_id)total_qty,
       pkg_report_general.fn_get_element_qty(pci.internal_contract_item_ref_no,
                                             ciqs.open_qty,
                                             ciqs.item_qty_unit_id,
                                             pcpq.assay_header_id,
                                             aml.attribute_id)open_qty,
       0 price_fixed_qty,
       0 unfixed_qty,
       pci.item_qty_unit_id,
       nvl(qum_under.qty_unit, qum.qty_unit)qty_unit,
       pcm.contract_ref_no,
       pcm.issue_date,
       pcdi.delivery_item_no,
       pci.del_distribution_item_no,
       ---id's
       gcd.groupid,
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       (case
         when pdtm.product_type_name = 'Composite' then
          nvl(pdm_under.product_id, pdm.product_id)
         else
          pdm.product_id
       end) product_id,
       nvl(qav_qat.quality_id, qat.quality_id) quality_id,
       gab.gabid trader_id,
       null derivative_def_id,
       null instrument_id,
       itm.incoterm_id,
       cym.country_id,
       cim.city_id,
       pdtm.product_type_id,
       pdtm.product_type_name,
       pcpq.assay_header_id,
       pcpq.unit_of_measure,
       aml.attribute_id,
       aml.attribute_name,
       (case
         when rm.ratio_name = '%' then
          ciqs.item_qty_unit_id
         else
          rm.qty_unit_id_numerator
       end) element_qty_unit_id,
       aml.underlying_product_id,
       pcm.contract_type position_type
  from pcm_physical_contract_main     pcm,
       ciqs_contract_item_qty_status  ciqs,
       ak_corporate                   akc,
       ak_corporate_user              akcu,
       gab_globaladdressbook          gab,
       gcd_groupcorporatedetails      gcd,
       pcdi_pc_delivery_item          pcdi,
       pci_physical_contract_item     pci,
       pcdb_pc_delivery_basis         pcdb,
       pdm_productmaster              pdm,
       pdtm_product_type_master       pdtm,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       qat_quality_attributes         qav_qat,
       qat_quality_attributes         qat,
--       pdd_product_derivative_def     pdd,
       -- dim_der_instrument_master     dim,
       pcpq_pc_product_quality pcpq,
       ----
       ash_assay_header            ash,
       asm_assay_sublot_mapping    asm,
       aml_attribute_master_list   aml,
       pqca_pq_chemical_attributes pqca,
       rm_ratio_master             rm,
       pdm_productmaster           pdm_under,
       qum_quantity_unit_master    qum_under,
       ----              
       itm_incoterm_master           itm,
       css_corporate_strategy_setup  css,
       pcpd_pc_product_definition    pcpd,
       cpc_corporate_profit_center   cpc,
       blm_business_line_master      blm,
       qum_quantity_unit_master      qum,
       diqs_delivery_item_qty_status diqs,
       cym_countrymaster             cym,
       cim_citymaster                cim
 where pcm.corporate_id = akc.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.internal_contract_item_ref_no =
       ciqs.internal_contract_item_ref_no
   and pci.pcpq_id = pcpq.pcpq_id(+)
   and pci.pcdb_id = pcdb.pcdb_id
   and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
   and pcdb.inco_term_id = itm.incoterm_id
   and pcpq.assay_header_id = ash.ash_id
   and asm.ash_id = ash.ash_id
   and asm.asm_id = pqca.asm_id
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and pcpd.product_id = ppm.product_id
   and pqca.element_id = ppm.attribute_id
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and ppm.property_id = qav.attribute_id
   and pcpq.quality_template_id = qav.quality_id
   and qav.is_deleted = 'N'
   and qav.comp_quality_id = qav_qat.quality_id(+)
   and pcpq.quality_template_id = qat.quality_id(+)
      --   and pcm.corporate_id = qat.corporate_id
      --  and qat.instrument_id = dim.instrument_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.base_quantity_unit = qum.qty_unit_id
      -- and qat.product_derivative_id = pdd.derivative_def_id
   and pcm.contract_status = 'In Position'
   and pcm.contract_type = 'CONCENTRATES'
   and akc.groupid = gcd.groupid
   and pcm.trader_id = akcu.user_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and akcu.gabid = gab.gabid
   and pcdb.country_id = cym.country_id
   and pcdb.city_id = cim.city_id
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
       pdtm.product_type_name,
       null assay_header_id,
       null unit_of_measure,
       null attribute_id,
       null attribute_name,
       null element_qty_unit_id,
       null underlying_product_id,
       pcm.contract_type position_type
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
   and pcm.corporate_id = qat.corporate_id
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
   and pcm.contract_type = 'BASEMETAL'
   and pci.internal_contract_item_ref_no =
       pfs.internal_contract_item_ref_no
   and pfs.price_fixation_status <> 'Fixed'
union all 
select tt.pcdi_id,
       tt.internal_contract_item_ref_no,
       tt.corporate_group,
       tt.business_line,
       tt.corporate_id,
       tt.corporate_name,
       tt.profit_center,
       tt.strategy,
       tt.product_name,
       tt.quality,
       tt.trader,
       tt.instrument_name,
       tt.incoterm,
       tt.country_name,
       tt.city_name,
       to_date(pkg_report_general.fn_get_element_pricing_month(tt.internal_contract_item_ref_no,
                                                       tt.attribute_id),
               'dd-Mon-yyyy') delivery_date,
       tt.purchase_sales,
       tt.baseqty_conv_rate,
       tt.price_fixation_status,
       (case
         when tt.total_qty > 0 then
          pkg_report_general.fn_get_element_qty(tt.internal_contract_item_ref_no,
                                                tt.total_qty,
                                                tt.item_qty_unit_id,
                                                tt.assay_header_id,
                                                tt.attribute_id)
         else
          0
       end) total_qty,
       (case
         when tt.open_qty > 0 then
          pkg_report_general.fn_get_element_qty(tt.internal_contract_item_ref_no,
                                                tt.open_qty,
                                                tt.item_qty_unit_id,
                                                tt.assay_header_id,
                                                tt.attribute_id)
         else
          0
       end) open_qty,
       (case
         when tt.price_fixed_qty > 0 then
          pkg_report_general.fn_get_element_qty(tt.internal_contract_item_ref_no,
                                                tt.price_fixed_qty,
                                                tt.item_qty_unit_id,
                                                tt.assay_header_id,
                                                tt.attribute_id)
         else
          0
       end) price_fixed_qty,
       (case
         when tt.unfixed_qty > 0 then
          pkg_report_general.fn_get_element_qty(tt.internal_contract_item_ref_no,
                                                tt.unfixed_qty,
                                                tt.item_qty_unit_id,
                                                tt.assay_header_id,
                                                tt.attribute_id)
         else
          0
       end) unfixed_qty,
       tt.item_qty_unit_id,
       tt.qty_unit,
       tt.contract_ref_no,
       tt.issue_date,
       tt.delivery_item_no,
       tt.del_distribution_item_no,
       ---id's
       tt.groupid,
       tt.business_line_id,
       tt.profit_center_id,
       tt.strategy_id,
       tt.product_id,
       tt.quality_id,
       tt.trader_id,
       tt.derivative_def_id,
       tt.instrument_id,
       tt.incoterm_id,
       tt.country_id,
       tt.city_id,
       tt.product_type_id,
       tt.product_type_name,
       tt.assay_header_id,
       tt.unit_of_measure,
       tt.attribute_id,
       tt.attribute_name,
       tt.element_qty_unit_id,
       tt.underlying_product_id,
       tt.position_type
  from (select pcdi.pcdi_id,
                pci.internal_contract_item_ref_no,
                gcd.groupname corporate_group,
                blm.business_line_name business_line,
                akc.corporate_id,
                akc.corporate_name,
                cpc.profit_center_short_name profit_center,
                css.strategy_name strategy,
                (case
                  when pdtm.product_type_name = 'Composite' then
                   nvl(pdm_under.product_desc, pdm.product_desc)
                  else
                   pdm.product_desc
                end) product_name,
                nvl(qav_qat.quality_name, qat.quality_name) quality,
                gab.firstname || ' ' || gab.lastname trader,
                null instrument_name,
                itm.incoterm,
                cym.country_name,
                cim.city_name,
                to_date(('01' || pci.expected_delivery_month || '-' ||
                        pci.expected_delivery_year),
                        'dd-Mon-yyyy') delivery_date,
                pcm.purchase_sales,
                (case
                  when pdtm.product_type_name = 'Composite' then
                   (case
                  when rm.ratio_name = '%' then
                   pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                            pdm.product_id),
                                                        pci.item_qty_unit_id,
                                                        nvl(pdm_under.base_quantity_unit,
                                                            pdm.base_quantity_unit),
                                                        1)
                  else
                   pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                            pdm.product_id),
                                                        rm.qty_unit_id_numerator,
                                                        nvl(pdm_under.base_quantity_unit,
                                                            pdm.base_quantity_unit),
                                                        1)
                end) else(pkg_general.f_get_converted_quantity(pcpd.product_id, pci.item_qty_unit_id, pdm.base_quantity_unit, 1)) end) baseqty_conv_rate,
                pfs.price_fixation_status,
                /*pkg_report_general.fn_get_element_qty(pci.internal_contract_item_ref_no,
                                                                                                                                                                    ciqs.total_qty,
                                                                                                                                                                    ciqs.item_qty_unit_id,
                                                                                                                                                                    pcpq.assay_header_id,
                                                                                                                                                                    aml.attribute_id) total_qty,
                                                                                                                              pkg_report_general.fn_get_element_qty(pci.internal_contract_item_ref_no,
                                                                                                                                                                    ciqs.open_qty,
                                                                                                                                                                    ciqs.item_qty_unit_id,
                                                                                                                                                                    pcpq.assay_header_id,
                                                                                                                                                                    aml.attribute_id) open_qty,*/
                ciqs.total_qty total_qty,
                ciqs.open_qty  open_qty,
                ------
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
                -------                                                          
                -- 0 price_fixed_qty,
                -- 0 unfixed_qty,
                pci.item_qty_unit_id,
                nvl(qum_under.qty_unit, qum.qty_unit) qty_unit,
                pcm.contract_ref_no,
                pcm.issue_date,
                pcdi.delivery_item_no,
                pci.del_distribution_item_no,
                ---id's
               gcd.groupid,
               blm.business_line_id,
               cpc.profit_center_id,
               css.strategy_id,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_id, pdm.product_id)
                 else
                  pdm.product_id
               end) product_id,
               nvl(qav_qat.quality_id, qat.quality_id) quality_id,
               gab.gabid trader_id,
               null derivative_def_id,
               null instrument_id,
               itm.incoterm_id,
               cym.country_id,
               cim.city_id,
               pdtm.product_type_id,
               pdtm.product_type_name,
               pcpq.assay_header_id,
               pcpq.unit_of_measure,
               aml.attribute_id,
               aml.attribute_name,
               (case
                 when rm.ratio_name = '%' then
                  ciqs.item_qty_unit_id
                 else
                  rm.qty_unit_id_numerator
               end) element_qty_unit_id,
               aml.underlying_product_id,
               pcm.contract_type position_type
          from pcm_physical_contract_main     pcm,
               ciqs_contract_item_qty_status  ciqs,
               ak_corporate                   akc,
               ak_corporate_user              akcu,
               gab_globaladdressbook          gab,
               gcd_groupcorporatedetails      gcd,
               pcdi_pc_delivery_item          pcdi,
               pci_physical_contract_item     pci,
               pcdb_pc_delivery_basis         pcdb,
               pdm_productmaster              pdm,
               pdtm_product_type_master       pdtm,
               ppm_product_properties_mapping ppm,
               qav_quality_attribute_values   qav,
               qat_quality_attributes         qav_qat,
               qat_quality_attributes         qat,
               --       pdd_product_derivative_def     pdd,
               -- dim_der_instrument_master     dim,
               pcpq_pc_product_quality pcpq,
               ----
               ash_assay_header            ash,
               asm_assay_sublot_mapping    asm,
               aml_attribute_master_list   aml,
               pqca_pq_chemical_attributes pqca,
               rm_ratio_master             rm,
               pdm_productmaster           pdm_under,
               qum_quantity_unit_master    qum_under,
               ----
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
           and pcpq.assay_header_id = ash.ash_id
           and asm.ash_id = ash.ash_id
           and asm.asm_id = pqca.asm_id
           and pqca.element_id = aml.attribute_id
           and pqca.is_elem_for_pricing = 'Y'
           and pqca.unit_of_measure = rm.ratio_id
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and pcpd.product_id = ppm.product_id
           and pqca.element_id = ppm.attribute_id
           and ppm.is_active = 'Y'
           and ppm.is_deleted = 'N'
           and ppm.property_id = qav.attribute_id
           and pcpq.quality_template_id = qav.quality_id
           and qav.is_deleted = 'N'
           and qav.comp_quality_id = qav_qat.quality_id(+)
           and pcpq.quality_template_id = qat.quality_id(+)
           and pcdi.pcdi_id = pfs.pcdi_id
           and pci.internal_contract_item_ref_no =
               pfs.internal_contract_item_ref_no
           and pqca.element_id = pfs.element_id
              --   and pcm.corporate_id = qat.corporate_id
              --  and qat.instrument_id = dim.instrument_id
           and pcm.internal_contract_ref_no =
               pcpd.internal_contract_ref_no(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and pcpd.product_id = pdm.product_id
           and pdm.product_type_id = pdtm.product_type_id
           and pcpd.strategy_id = css.strategy_id
           and pdm.base_quantity_unit = qum.qty_unit_id
              -- and qat.product_derivative_id = pdd.derivative_def_id
           and pcm.contract_status = 'In Position'
           and pcm.contract_type = 'CONCENTRATES'
           and akc.groupid = gcd.groupid
           and pcm.trader_id = akcu.user_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and pcdi.pcdi_id = diqs.pcdi_id
           and akcu.gabid = gab.gabid
           and pcdb.country_id = cym.country_id
           and pcdb.city_id = cim.city_id) tt
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
       pdtm.product_type_id,
       null assay_header_id,
       null unit_of_measure,
       null attribute_id,
       null attribute_name,
       null element_qty_unit_id,
       null underlying_product_id,
       'BASEMETAL' position_type
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
   and gmr.corporate_id = qat.corporate_id
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
       pdtm.product_type_id,
       null assay_header_id,
       null unit_of_measure,
       null attribute_id,
       null attribute_name,
       null element_qty_unit_id,
       null underlying_product_id,
       'BASEMETAL' position_type       
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
   and gmr.corporate_id = qat.corporate_id   
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
union all

select subsectionname,
       internal_contract_ref_no,
       inco_term_id,
       pcdi_id,
       internal_contract_item_ref_no,
       corporate_group,
       business_line,
       corporate_id,
       corporate_name,
       profit_center,
       strategy,
       product_name,
       quality,
       trader,
       instrument_name,
       incoterm,
       country_name,
       city_name,
       delivery_date,
       purchase_sales,
       baseqty_conv_rate,
       price_fixation_status,
       sum(total_qty) total_qty,
       sum(open_qty) open_qty,
       sum(price_fixed_qty) price_fixed_qty,
       sum(unfixed_qty) unfixed_qty,
       item_qty_unit_id,
       qty_unit,
       contract_ref_no,
       del_distribution_item_no,
       gmr_ref_no,
       internal_gmr_ref_no,
       country_id,
       city_id,
       product_type_name,
       groupid,
       business_line_id,
       profit_center_id,
       strategy_id,
       product_id,
       quality_id,
       trader_id,
       derivative_def_id,
       instrument_id,
       product_type_id,
       assay_header_id,
       unit_of_measure,
       attribute_id,
       attribute_name,
       element_qty_unit_id,
       underlying_product_id,
       position_type
  from (select (case
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
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_desc, pdm.product_desc)
                 else
                  pdm.product_desc
               end) product_name,
               nvl(qav_qat.quality_name, qat.quality_name) quality,
               gab.firstname || ' ' || gab.lastname trader,
               null instrument_name,
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
               (case
                 when pdtm.product_type_name = 'Composite' then
                  (case
                 when rm.ratio_name = '%' then
                  pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                           pdm.product_id),
                                                       grd.qty_unit_id,
                                                       nvl(pdm_under.base_quantity_unit,
                                                           pdm.base_quantity_unit),
                                                       1)
                 else
                  pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                           pdm.product_id),
                                                       rm.qty_unit_id_numerator,
                                                       nvl(pdm_under.base_quantity_unit,
                                                           pdm.base_quantity_unit),
                                                       1)
               end) else(pkg_general.f_get_converted_quantity(grd.product_id, grd.qty_unit_id, pdm.base_quantity_unit, 1)) end) baseqty_conv_rate,
               null price_fixation_status,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.qty,
                                                           grd.qty_unit_id) total_qty,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.current_qty,
                                                           grd.qty_unit_id) open_qty,
               0 price_fixed_qty,
               0 unfixed_qty,
               grd.qty_unit_id item_qty_unit_id,
               nvl(qum_under.qty_unit,qum.qty_unit)qty_unit,
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
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_id, pdm.product_id)
                 else
                  pdm.product_id
               end) product_id,
               nvl(qav_qat.quality_id, qat.quality_id) quality_id,
               gab.gabid trader_id,
               null derivative_def_id,
               null instrument_id,
               pdtm.product_type_id,
               sam.ash_id assay_header_id,
               'Wet' unit_of_measure,
               aml.attribute_id,
               aml.attribute_name,
               (case
                 when rm.ratio_name = '%' then
                  grd.qty_unit_id
                 else
                  rm.qty_unit_id_numerator
               end) element_qty_unit_id,
               aml.underlying_product_id,
               'CONCENTRATES' position_type
          from grd_goods_record_detail        grd,
               gmr_goods_movement_record      gmr,
               sld_storage_location_detail    sld,
               cim_citymaster                 cim_sld,
               cim_citymaster                 cim_gmr,
               cym_countrymaster              cym_sld,
               cym_countrymaster              cym_gmr,
               v_pci_pcdi_details             pci,
               pdm_productmaster              pdm,
               pdtm_product_type_master       pdtm,
               qum_quantity_unit_master       qum,
               itm_incoterm_master            itm,
               sam_stock_assay_mapping        sam,
               ash_assay_header               ash,
               asm_assay_sublot_mapping       asm,
               aml_attribute_master_list      aml,
               pqca_pq_chemical_attributes    pqca,
               rm_ratio_master                rm,
               ppm_product_properties_mapping ppm,
               qav_quality_attribute_values   qav,
               qat_quality_attributes         qav_qat,
               qat_quality_attributes         qat,
               pdm_productmaster              pdm_under,
               qum_quantity_unit_master       qum_under,
               css_corporate_strategy_setup   css,
               cpc_corporate_profit_center    cpc,
               blm_business_line_master       blm,
               ak_corporate                   akc,
               gcd_groupcorporatedetails      gcd,
               gab_globaladdressbook          gab
         where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and grd.product_id = pdm.product_id
           and pdm.product_type_id = pdtm.product_type_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and grd.shed_id = sld.storage_loc_id(+)
           and sld.city_id = cim_sld.city_id(+)
           and gmr.discharge_city_id = cim_gmr.city_id(+)
           and cim_sld.country_id = cym_sld.country_id(+)
           and cim_gmr.country_id = cym_gmr.country_id(+)
           and grd.internal_grd_ref_no = sam.internal_grd_ref_no
           and sam.stock_type = 'P'
           and sam.ash_id = ash.ash_id
           and ash.ash_id = asm.ash_id
           and ash.is_active = 'Y'
           and nvl(ash.is_delete, 'N') = 'N'
           and nvl(asm.is_active, 'Y') = 'Y'
           and sam.is_active = 'Y'
           and asm.asm_id = pqca.asm_id
           and pqca.element_id = aml.attribute_id
           and pqca.is_elem_for_pricing = 'Y'
           and pqca.unit_of_measure = rm.ratio_id
              -----
           and grd.product_id = ppm.product_id
           and aml.attribute_id = ppm.attribute_id
           and ppm.is_active = 'Y'
           and ppm.is_deleted = 'N'
           and ppm.property_id = qav.attribute_id
           and grd.quality_id = qav.quality_id
           and qav.is_deleted = 'N'
           and qav.comp_quality_id = qav_qat.quality_id(+)
           and grd.quality_id = qat.quality_id(+)
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
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
           and nvl(grd.current_qty, 0) > 0
           and gmr.created_by = gab.gabid(+)
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
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_desc, pdm.product_desc)
                 else
                  pdm.product_desc
               end) product_name,
               nvl(qav_qat.quality_name, qat.quality_name) quality,
               gab.firstname || ' ' || gab.lastname trader,
               null instrument_name,
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
               (case
                 when pdtm.product_type_name = 'Composite' then
                  (case
                 when rm.ratio_name = '%' then
                  pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                           pdm.product_id),
                                                       grd.net_weight_unit_id,
                                                       nvl(pdm_under.base_quantity_unit,
                                                           pdm.base_quantity_unit),
                                                       1)
                 else
                  pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                           pdm.product_id),
                                                       rm.qty_unit_id_numerator,
                                                       nvl(pdm_under.base_quantity_unit,
                                                           pdm.base_quantity_unit),
                                                       1)
               end) else(pkg_general.f_get_converted_quantity(grd.product_id, grd.net_weight_unit_id, pdm.base_quantity_unit, 1)) end) baseqty_conv_rate,
               null price_fixation_status,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.net_weight,
                                                           grd.net_weight_unit_id) total_qty,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.current_qty,
                                                           grd.net_weight_unit_id) open_qty,
               0 price_fixed_qty,
               0 unfixed_qty,
               grd.net_weight_unit_id item_qty_unit_id,
               nvl(qum_under.qty_unit,qum.qty_unit)qty_unit,
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
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_id, pdm.product_id)
                 else
                  pdm.product_id
               end) product_id,
               nvl(qav_qat.quality_id, qat.quality_id) quality_id,
               gab.gabid trader_id,
               null derivative_def_id,
               null instrument_id,
               pdtm.product_type_id,
               sam.ash_id assay_header_id,
               'Wet' unit_of_measure,
               aml.attribute_id,
               aml.attribute_name,
               (case
                 when rm.ratio_name = '%' then
                  grd.net_weight_unit_id
                 else
                  rm.qty_unit_id_numerator
               end) element_qty_unit_id,
               aml.underlying_product_id,
               'CONCENTRATES' position_type
          from dgrd_delivered_grd             grd,
               gmr_goods_movement_record      gmr,
               sld_storage_location_detail    sld,
               cim_citymaster                 cim_sld,
               cim_citymaster                 cim_gmr,
               cym_countrymaster              cym_sld,
               cym_countrymaster              cym_gmr,
               v_pci_pcdi_details             pci,
               pdm_productmaster              pdm,
               pdtm_product_type_master       pdtm,
               qum_quantity_unit_master       qum,
               itm_incoterm_master            itm,
               sam_stock_assay_mapping        sam,
               ash_assay_header               ash,
               asm_assay_sublot_mapping       asm,
               aml_attribute_master_list      aml,
               pqca_pq_chemical_attributes    pqca,
               rm_ratio_master                rm,
               ppm_product_properties_mapping ppm,
               qav_quality_attribute_values   qav,
               qat_quality_attributes         qav_qat,
               qat_quality_attributes         qat,
               pdm_productmaster              pdm_under,
               qum_quantity_unit_master       qum_under,
               css_corporate_strategy_setup   css,
               cpc_corporate_profit_center    cpc,
               blm_business_line_master       blm,
               ak_corporate                   akc,
               gcd_groupcorporatedetails      gcd,
               gab_globaladdressbook          gab
         where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and grd.product_id = pdm.product_id
           and pdm.product_type_id = pdtm.product_type_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and grd.shed_id = sld.storage_loc_id(+)
           and sld.city_id = cim_sld.city_id(+)
           and gmr.discharge_city_id = cim_gmr.city_id(+)
           and cim_sld.country_id = cym_sld.country_id(+)
           and cim_gmr.country_id = cym_gmr.country_id(+)
           and grd.internal_dgrd_ref_no = sam.internal_dgrd_ref_no
           and sam.stock_type = 'S'
           and sam.ash_id = ash.ash_id
           and ash.ash_id = asm.ash_id
           and ash.is_active = 'Y'
           and nvl(ash.is_delete, 'N') = 'N'
           and nvl(asm.is_active, 'Y') = 'Y'
           and sam.is_active = 'Y'
           and asm.asm_id = pqca.asm_id
           and pqca.element_id = aml.attribute_id
           and pqca.is_elem_for_pricing = 'Y'
           and pqca.unit_of_measure = rm.ratio_id
              -----
           and grd.product_id = ppm.product_id
           and aml.attribute_id = ppm.attribute_id
           and ppm.is_active = 'Y'
           and ppm.is_deleted = 'N'
           and ppm.property_id = qav.attribute_id
           and grd.quality_id = qav.quality_id
           and qav.is_deleted = 'N'
           and qav.comp_quality_id = qav_qat.quality_id(+)
           and grd.quality_id = qat.quality_id(+)
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and gmr.corporate_id = akc.corporate_id
           and akc.groupid = gcd.groupid
           and grd.status = 'Active'
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no(+)
           and pci.inco_term_id = itm.incoterm_id(+)
           and pci.strategy_id = css.strategy_id(+)
           and pci.profit_center_id = cpc.profit_center_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.is_internal_movement = 'N'
           and nvl(gmr.inventory_status, 'NA') <> 'Out'
           and nvl(grd.current_qty, 0) > 0
           and gmr.created_by = gab.gabid(+))
 group by subsectionname,
          internal_contract_ref_no,
          inco_term_id,
          pcdi_id,
          internal_contract_item_ref_no,
          corporate_group,
          business_line,
          corporate_id,
          corporate_name,
          profit_center,
          strategy,
          product_name,
          quality,
          trader,
          instrument_name,
          incoterm,
          country_name,
          city_name,
          delivery_date,
          purchase_sales,
          baseqty_conv_rate,
          price_fixation_status,
          item_qty_unit_id,
          qty_unit,
          contract_ref_no,
          del_distribution_item_no,
          gmr_ref_no,
          internal_gmr_ref_no,
          country_id,
          city_id,
          product_type_name,
          groupid,
          business_line_id,
          profit_center_id,
          strategy_id,
          product_id,
          quality_id,
          trader_id,
          derivative_def_id,
          instrument_id,
          product_type_id,
          assay_header_id,
          unit_of_measure,
          attribute_id,
          attribute_name,
          element_qty_unit_id,
          underlying_product_id,
          position_type       
/
--------
create or replace view v_gmr_concentrate_details as
select max(case
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
       (case
         when pdtm.product_type_name = 'Composite' then
          nvl(pdm_under.product_desc, pdm.product_desc)
         else
          pdm.product_desc
       end) product_name,
       nvl(qav_qat.quality_name, qat.quality_name) quality,
       gab.firstname || ' ' || gab.lastname trader,
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
       max(case
         when nvl(gmr.contract_type, 'NA') = 'Purchase' then
          'P'
         when nvl(gmr.contract_type, 'NA') = 'Sales' then
          'S'
         when nvl(gmr.contract_type, 'NA') = 'B2B' then
          nvl(pci.purchase_sales, 'P')
       end) purchase_sales,
       max(case
         when pdtm.product_type_name = 'Composite' then
          (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               grd.qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
       end) else(pkg_general.f_get_converted_quantity(grd.product_id, grd.qty_unit_id, pdm.base_quantity_unit, 1)) end) baseqty_conv_rate,
       sam.ash_id,
       sum(grd.qty)qty,
       sum(grd.current_qty)current_qty,
       grd.qty_unit_id item_qty_unit_id,
       nvl(qum_under.qty_unit, qum.qty_unit) qty_unit,
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
       (case
         when pdtm.product_type_name = 'Composite' then
          nvl(pdm_under.product_id, pdm.product_id)
         else
          pdm.product_id
       end) product_id,
       nvl(qav_qat.quality_id, qat.quality_id) quality_id,
       gab.gabid trader_id,
       null derivative_def_id,
       null instrument_id,
       pdtm.product_type_id,
       sam.ash_id assay_header_id,
       'Wet' unit_of_measure,
       aml.attribute_id,
       aml.attribute_name,
       (case
         when rm.ratio_name = '%' then
          grd.qty_unit_id
         else
          rm.qty_unit_id_numerator
       end) element_qty_unit_id,
       aml.underlying_product_id,
       'CONCENTRATES' position_type
  from grd_goods_record_detail        grd,
       gmr_goods_movement_record      gmr,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       v_pci_pcdi_details             pci,
       pdm_productmaster              pdm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       itm_incoterm_master            itm,
       sam_stock_assay_mapping        sam,
       ash_assay_header               ash,
       asm_assay_sublot_mapping       asm,
       aml_attribute_master_list      aml,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       qat_quality_attributes         qav_qat,
       qat_quality_attributes         qat,
       pdm_productmaster              pdm_under,
       qum_quantity_unit_master       qum_under,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       gab_globaladdressbook          gab
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and grd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.internal_grd_ref_no = sam.internal_grd_ref_no
   and sam.stock_type = 'P'
   and sam.ash_id = ash.ash_id
   and ash.ash_id = asm.ash_id
   and ash.is_active = 'Y'
   and nvl(ash.is_delete, 'N') = 'N'
   and nvl(asm.is_active, 'Y') = 'Y'
   and sam.is_active = 'Y'
   and asm.asm_id = pqca.asm_id
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id
      -----
   and grd.product_id = ppm.product_id
   and aml.attribute_id = ppm.attribute_id
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and ppm.property_id = qav.attribute_id
   and grd.quality_id = qav.quality_id
   and qav.is_deleted = 'N'
   and qav.comp_quality_id = qav_qat.quality_id(+)
   and grd.quality_id = qat.quality_id(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
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
   and nvl(grd.current_qty, 0) > 0
   and gmr.created_by = gab.gabid(+)
group by 
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
       (case
         when pdtm.product_type_name = 'Composite' then
          nvl(pdm_under.product_desc, pdm.product_desc)
         else
          pdm.product_desc
       end),
       nvl(qav_qat.quality_name, qat.quality_name) ,
       gab.firstname || ' ' || gab.lastname,
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
       sam.ash_id,
       grd.qty_unit_id,
       nvl(qum_under.qty_unit, qum.qty_unit),
       pci.contract_ref_no,
       pci.del_distribution_item_no,
       gmr.gmr_ref_no,
       gmr.internal_gmr_ref_no,
       (case
         when grd.is_afloat = 'Y' then
          cym_gmr.country_id
         else
          cym_sld.country_id
       end) ,
       (case
         when grd.is_afloat = 'Y' then
          cim_gmr.city_id
         else
          cim_sld.city_id
       end) ,
       pdtm.product_type_name,
       gcd.groupid,
       blm.business_line_id,
       cpc.profit_center_id,
       css.strategy_id,
       (case
         when pdtm.product_type_name = 'Composite' then
          nvl(pdm_under.product_id, pdm.product_id)
         else
          pdm.product_id
       end) ,
       nvl(qav_qat.quality_id, qat.quality_id) ,
       gab.gabid,
       pdtm.product_type_id,
       sam.ash_id,
       aml.attribute_id,
       aml.attribute_name,
       (case
         when rm.ratio_name = '%' then
          grd.qty_unit_id
         else
          rm.qty_unit_id_numerator
       end) ,
       aml.underlying_product_id
/