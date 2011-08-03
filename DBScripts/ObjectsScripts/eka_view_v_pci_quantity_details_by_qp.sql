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
       pcm.contract_type position_type,
       pdm.product_desc  comp_product_name,
       qat.quality_name comp_quality,
       ciqs.open_qty item_open_qty,
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pci.item_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1)compqty_base_conv_rate,
       qum.qty_unit comp_base_qty_unit,
       qum.qty_unit_id comp_base_qty_unit_id,
       1 contract_row       
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
  and nvl(pcm.is_tolling_contract,'N') = 'N'
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
       tt.position_type,
       tt.comp_product_name,
       tt.comp_quality,
       (case
         when tt.open_qty > 0 then
          pkg_report_general.fn_get_element_qty(tt.internal_contract_item_ref_no,
                                                tt.open_qty,
                                                tt.item_qty_unit_id,
                                                tt.assay_header_id,
                                                tt.attribute_id)
         else
          0
       end) item_open_qty,
       tt.baseqty_conv_rate compqty_base_conv_rate,
       tt.qty_unit comp_base_qty_unit,
       tt.qty_unit_id comp_base_qty_unit_id,
       tt.contract_row
  from (select pcdi.pcdi_id,
                pci.internal_contract_item_ref_no,
                gcd.groupname corporate_group,
                ---------
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
                ciqs.total_qty total_qty,
                ciqs.open_qty open_qty,
                ciqs.open_qty item_open_qty,
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
                pci.item_qty_unit_id,
                nvl(qum_under.qty_unit, qum.qty_unit) qty_unit,
                nvl(qum_under.qty_unit_id, qum.qty_unit_id) qty_unit_id,
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
               pcm.contract_type position_type,
               pdm.product_desc comp_product_name,
               qat.quality_name comp_quality,
               qum.qty_unit comp_base_qty_unit,
               qum.qty_unit_id comp_base_qty_unit_id,
               row_number() over(partition by pci.internal_contract_item_ref_no order by pci.internal_contract_item_ref_no, aml.attribute_id) contract_row
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
               pcpq_pc_product_quality        pcpq,
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
           and pcm.internal_contract_ref_no =
               pcpd.internal_contract_ref_no(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and pcpd.product_id = pdm.product_id
           and pdm.product_type_id = pdtm.product_type_id
           and pcpd.strategy_id = css.strategy_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and pcm.contract_status = 'In Position'
           and pcm.contract_type = 'CONCENTRATES'
           and nvl(pcm.is_tolling_contract, 'N') = 'N'
           and akc.groupid = gcd.groupid
           and pcm.trader_id = akcu.user_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and pcdi.pcdi_id = diqs.pcdi_id
           and akcu.gabid = gab.gabid
           and pcdb.country_id = cym.country_id
           and pfs.price_fixation_status <> 'Fixed'
           and pcdb.city_id = cim.city_id) tt
where tt.open_qty >0 
