CREATE OR REPLACE VIEW V_RPT_YEARLY_PRICE_EXP_BM AS
WITH pofh_header_data AS
        (SELECT *
           FROM pofh_price_opt_fixation_header pofh
          WHERE pofh.internal_gmr_ref_no IS NULL
            AND pofh.qty_to_be_fixed IS NOT NULL
            AND pofh.is_active = 'Y'),
        pfd_fixation_data AS
        (SELECT   pfd.pofh_id,
                  ROUND (SUM (NVL (pfd.qty_fixed, 0)), 5) qty_fixed
             FROM pfd_price_fixation_details pfd
            WHERE pfd.is_active = 'Y'
         GROUP BY pfd.pofh_id)
--Any Day/Average Pricing Base Metal +Contract
select 1 section_id,
       'BM-CON-UNFIXED' section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       nvl(f_get_pricing_month(pocd.pcbpd_id), to_char(last_day(sysdate),'dd-Mon-yyyy')) qp_end_date,
       ppfd.instrument_id,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       qat.quality_name quality,
       round((decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (case when nvl(pfqpp.is_qp_any_day_basis, 'N')='N' then
            (pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0))
        else

       ((case
          when pfqpp.qp_pricing_period_type = 'Event' then
           (diqs.total_qty - diqs.gmr_qty - diqs.fulfilled_qty)
          else
           pofh.qty_to_be_fixed
        end) - nvl(pfd.qty_fixed, 0)) end) *
        pkg_general.f_get_converted_quantity(pcpd.product_id,pocd.qty_to_be_fixed_unit_id,
                                             pdm.base_quantity_unit,
                                             1)),5) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       (select tt.pcdi_id,
               max(tt.pcpq_id) pcpq_id
          from pcdiqd_di_quality_details tt
         where tt.is_active = 'Y'
         group by tt.pcdi_id) pcdiqd,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       pofh_header_data pofh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and pcdi.pcdi_id = diqs.pcdi_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pofh_id = pfd.pofh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
union all
--Any Day Pricing Base Metal +GMR
select 2 section_id,
       'BM-GMR-UNFIXED' section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       qat.quality_name quality,
       round(decode(pcm.purchase_sales, 'P', 1, 'S', -1) * pofh.qty_to_be_fixed -
       (nvl(pfd.qty_fixed, 0)) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1),5) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
        qum_quantity_unit_master qum
 where ak.corporate_id = pcm.corporate_id
 and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
 and pcdi.pcdi_id = pcdiqd.pcdi_id
 and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
 and pcpd.pcpd_id = pcpq.pcpd_id
 and pcdiqd.pcpq_id = pcpq.pcpq_id
 and pcpd.strategy_id = css.strategy_id
 and pdm.product_id = pcpd.product_id
 and pcpq.quality_template_id = qat.quality_id
 and qat.product_id = pdm.product_id
 and pcdi.pcdi_id = poch.pcdi_id
 and pocd.poch_id = poch.poch_id
 and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
 and pcbph.pcbph_id = pcbpd.pcbph_id
 and pcbpd.pcbpd_id = pocd.pcbpd_id
 and pcbpd.pcbpd_id = ppfh.pcbpd_id
 and pofh.pocd_id = pocd.pocd_id(+)
 and pofh.pofh_id = pfd.pofh_id(+)
 and pofh.internal_gmr_ref_no is not null
 and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
 and pcpd.profit_center_id = cpc.profit_center_id
 and ppfh.ppfh_id = pfqpp.ppfh_id
 and ppfh.ppfh_id = ppfd.ppfh_id
--  and pcm.internal_contract_ref_no = vp.internal_contract_ref_no
 and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
 and pdm.base_quantity_unit = qum.qty_unit_id
 and pcm.is_active = 'Y'
 and pcm.contract_type = 'BASEMETAL'
 and pcm.approval_status = 'Approved'
 and pcdi.is_active = 'Y'
 and gmr.is_deleted = 'N'
 and pdm.is_active = 'Y'
 and qum.is_active = 'Y'
 and qat.is_active = 'Y'
 and pofh.is_active = 'Y'
 and poch.is_active = 'Y'
 and pocd.is_active = 'Y'
 and ppfh.is_active = 'Y'
union all
--Average Pricing Base Metal+GMR
select 3 section_id,
       'BM-GMR-UNFIXED' section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       null trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       qat.quality_name quality,
       round(decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.qty_to_be_fixed - nvl(pofh.priced_qty,0) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1),5) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       qum_quantity_unit_master qum,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pofh.internal_gmr_ref_no is not null
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all
--Fixed by price fixation date Base Metal +Contract
select 4 section_id,
       'BM-CON-FIXED' section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       to_char(last_day(pfd.as_of_date),'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       last_day(pfd.as_of_date) trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
       qat.quality_name quality,
       round(decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                        pocd.qty_to_be_fixed_unit_id,
                                            pdm.base_quantity_unit,
                                            1),5) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       qum_quantity_unit_master qum,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pofh.pocd_id = pocd.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is null
   and pofh.qty_to_be_fixed is not null
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pdm.base_quantity_unit = qum.qty_unit_id
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,pocd.qty_to_be_fixed_unit_id,
          pdm.product_id,
          pdm.product_desc,
          css.strategy_id,
          ppfd.instrument_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          qat.quality_name,
        --  pocd.pcbpd_id,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,to_char(last_day(pfd.as_of_date),'dd-Mon-yyyy'),
          pcpd.product_id,last_day(pfd.as_of_date),
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          qum.qty_unit_id,
          qum.decimals,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          qat.quality_name
union all
----Fixed by Price by fixation date Base Metal +GMR or free metal fixed
select (case when nvl(poch.is_free_metal_pricing,'NA') = 'Y' then
            6 else 5  end)section_id,
       (case when nvl(poch.is_free_metal_pricing,'NA') = 'Y' then
            'BM-FM-FIXED' else 'BM-GMR-FIXED'  end)  section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       to_char(last_day(pfd.as_of_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       null element_name,
       last_day(pfd.as_of_date) trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       qat.quality_name quality,
       round(decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
             sum(pfd.qty_fixed) *
             pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                  pocd.qty_to_be_fixed_unit_id,
                                                  pdm.base_quantity_unit,
                                                  1),
             5) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       qum_quantity_unit_master qum,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       css_corporate_strategy_setup css,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pcbph_pc_base_price_header pcbph,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pofh.pocd_id = pocd.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is not null
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and pdm.base_quantity_unit = qum.qty_unit_id
 group by ak.corporate_id,
          ak.corporate_name,poch.is_free_metal_pricing,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pocd.qty_to_be_fixed_unit_id,
          pdm.product_id,
          pdm.product_desc,
          css.strategy_id,
          ppfd.instrument_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          qat.quality_name,
          pocd.pcbpd_id,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          to_char(last_day(pfd.as_of_date), 'dd-Mon-yyyy'),
          last_day(pfd.as_of_date),
          pcpd.product_id,
          qum.qty_unit_id,
          pdm.base_quantity_unit,
          qum.qty_unit,
          qum.qty_unit_id,
          qum.decimals,
          ppfh.formula_description,
          ppfd.exchange_id,
          pofh.qp_start_date,
          pofh.qp_end_date,
          gmr.gmr_ref_no,
          ppfd.exchange_name,
          pcdi.basis_type,
          pcdi.transit_days,
          pcdi.is_price_optionality_present,
          pcdi.price_option_call_off_status,
          qat.quality_name
union all
--free metal unpriced
select 7 section_id,
       'BM-FM-UNFIXED' section_name,
       ak.corporate_id,
       ak.corporate_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.contract_type product_type,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       'Y' is_base_metal,
       'N' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       null element_id,
       null element_name,
       pcm.issue_date trade_date,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       qat.quality_name quality,
       round(decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
             (pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0)) *
             pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                  pocd.qty_to_be_fixed_unit_id,
                                                  pdm.base_quantity_unit,
                                                  1),
             5) qty,
       qum.qty_unit_id,
       qum.qty_unit,
       qum.decimals qty_decimals
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       pcpq_pc_product_quality pcpq,
       css_corporate_strategy_setup css,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       (select ppfd.ppfh_id,
               ppfd.instrument_id,
               emt.exchange_id,
               emt.exchange_name
          from ppfd_phy_price_formula_details ppfd,
               dim_der_instrument_master      dim,
               pdd_product_derivative_def     pdd,
               emt_exchangemaster             emt
         where ppfd.is_active = 'Y'
           and ppfd.instrument_id = dim.instrument_id
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.exchange_id = emt.exchange_id
         group by ppfd.ppfh_id,
                  ppfd.instrument_id,
                  emt.exchange_id,
                  emt.exchange_name) ppfd,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       qum_quantity_unit_master qum
 where gmr.corporate_id = ak.corporate_id
   and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
   and pofh.pocd_id = pocd.pocd_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'BASEMETAL'
   and pcm.approval_status = 'Approved'
   and nvl(poch.is_free_metal_pricing,'NA') = 'Y'
   and pcdi.is_active = 'Y'
   and gmr.is_deleted = 'N'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'

