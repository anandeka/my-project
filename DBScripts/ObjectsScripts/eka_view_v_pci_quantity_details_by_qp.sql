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
	         and pcm.corporate_id = qat.corporate_id
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
