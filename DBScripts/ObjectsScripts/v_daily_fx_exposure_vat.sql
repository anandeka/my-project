create or replace view v_daily_fx_exposure_vat as
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       null sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.vat_parent_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       iis.payable_receivable,
       (decode(iis.payable_receivable, 'Payable', -1, 'Receivable', 1) *
       ivd.vat_amount_in_vat_cur) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       iis.invoice_issue_date correction_date,
       null activity_type,
       null activity_date,
       null cpname
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty) invoiced_qty
          from iid_invoicable_item_details iid
         where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       is_invoice_summary iis1,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iis.vat_parent_ref_no = iis1.invoice_ref_no
   and iis1.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and ivd.is_separate_invoice = 'Y'
   and pcm.purchase_sales = 'P'
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.input_output = 'Input'
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and ivd.vat_remit_cur_id = cm_pay.cur_id
   and akc.base_cur_id = cm_base.cur_id
   and nvl(ivd.vat_amount_in_vat_cur, 0) <> 0
   and iis.is_active = 'Y'
   and iis1.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       null sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.invoice_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       iis.payable_receivable,
       (decode(iis.payable_receivable, 'Payable', -1, 'Receivable', 1) *
       (case
         when pcm.purchase_sales = 'S' then
          ivd.vat_amount_in_inv_cur
         else
          nvl(ivd.vat_amount_in_vat_cur, ivd.vat_amount_in_inv_cur)
       end)) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       iis.invoice_issue_date correction_date,
       null activity_type,
       null activity_date,
       null cpname
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty) invoiced_qty
          from iid_invoicable_item_details iid
         where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.input_output = 'Input'
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and (case when pcm.purchase_sales = 'S' then ivd.invoice_cur_id else
        nvl(ivd.vat_remit_cur_id, ivd.invoice_cur_id) end) = cm_pay.cur_id --for purchase exposure in vat cur and
      --     for sales  eposure in invoice cur
   and akc.base_cur_id = cm_base.cur_id
   and iis.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all ---for sales contract when invoice cur and vat cur are not same   outflow
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       '' sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm.product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       iis.invoice_issue_date trade_date, --pcm.issue_date trade_date,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                cm_base.cur_id,
                                                cm_pay.cur_id,
                                                iis.invoice_issue_date,
                                                1) fx_rate,
       pcm.contract_ref_no,
       iis.invoice_ref_no,
       iis.invoice_ref_no parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       iis.payment_due_date expected_payment_due_date,
       null qp_start_date,
       null qp_end_date,
       null qp,
       null delivery_month,
       pym.payment_term payment_terms,
       null qty,
       null qty_unit,
       null qty_unit_id,
       null qty_decimals,
       null price,
       null price_unit_id,
       null price_unit,
       'Payable' payable_receivable,
       (decode(iis.payable_receivable, 'Payable', 1, 'Receivable', -1) * ---for make outflow sales amount
       ivd.vat_amount_in_vat_cur) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       iis.invoice_issue_date correction_date,
       null activity_type,
       null activity_date,
       null cpname
  from ivd_invoice_vat_details ivd,
       (select iid.internal_contract_item_ref_no,
               iid.internal_contract_ref_no,
               iid.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               sum(iid.invoiced_qty)
          from iid_invoicable_item_details iid
         where iid.is_active = 'Y'
         group by iid.internal_contract_item_ref_no,
                  iid.internal_contract_ref_no,
                  iid.internal_gmr_ref_no,
                  iid.internal_invoice_ref_no) iid,
       is_invoice_summary iis,
       gmr_goods_movement_record gmr,
       pcdi_pc_delivery_item pcdi,
       pcm_physical_contract_main pcm,
       ak_corporate akc,
       ak_corporate_user akcu,
       gab_globaladdressbook gab,
       pcpd_pc_product_definition pcpd,
       pym_payment_terms_master pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster pdm,
       cm_currency_master cm_base,
       cm_currency_master cm_pay
 where ivd.internal_invoice_ref_no = iid.internal_invoice_ref_no
   and iid.internal_invoice_ref_no = iis.internal_invoice_ref_no
   and iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and ivd.vat_remit_cur_id <> ivd.invoice_cur_id --for invoice exposure of sales
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.input_output = 'Input'
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and ivd.vat_remit_cur_id = cm_pay.cur_id
   and pcm.purchase_sales = 'S'
   and akc.base_cur_id = cm_base.cur_id
   and iis.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all --- Free Metal
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Price Fixation' section,
       (case
         when pfqpp.is_qp_any_day_basis = 'Y' then
          'Spot Fixations'
         else
          'Average Fixations'
       end) sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       pfd.as_of_date trade_date, --pcm.issue_date trade_date,
       /* pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                                     cm_base.cur_id,
                                                                     cm_pay.cur_id,
                                                                     pfd.as_of_date,
                                                                     1) fx_rate,*/
       (case
         when pffxd.fx_rate_type = 'Fixed' then
          pffxd.fixed_fx_rate
         else
          pfd.fx_rate
       end) fx_rate,
       pcm.contract_ref_no,
       '' invoice_ref_no,
       '' parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       aml.attribute_name element_name,
       null currency_pair,
       pcdi.payment_due_date expected_payment_due_date,
       pfqpp.qp_period_from_date qp_start_date,
       pfqpp.qp_period_to_date qp_end_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
       end) qp,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) delivery_month,
       pym.payment_term payment_terms,
       pfd.qty_fixed qty,
       qum.qty_unit,
       qum.qty_unit_id,
       qum.decimals qty_decimals,
       (nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) price,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       null payable_receivable,
       (case
         when pfd.hedge_amount is null then
          decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
          ((nvl(pfd.user_price, 0) + nvl(pfd.adjustment_price, 0)) /
           nvl(ppu.weight, 1)) *
         /*(round(pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                                              ppu.cur_id,
                                                                              cm_pay.cur_id,
                                                                              pfd.as_of_date,
                                                                              1),
                                     5) **/
          (case
         when pffxd.fx_rate_type = 'Fixed' then
          pffxd.fixed_fx_rate
         else
          pfd.fx_rate
       end) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            pum.weight_unit_id,
                                            pofh.per_day_pricing_qty) else pfd.hedge_amount end) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       decode(pocd.fx_conversion_method,
              null,
              pfd.hedge_correction_date,
              pfd.fx_correction_date) correction_date,
       null activity_type,
       null activity_date,
       null cpname
  from pcdi_pc_delivery_item          pcdi,
       pcm_physical_contract_main     pcm,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       qum_quantity_unit_master       qum_under,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details     pfd,
       pcbpd_pc_base_price_detail     pcbpd,
       ppfh_phy_price_formula_header  ppfh,
       pfqpp_phy_formula_qp_pricing   pfqpp,
       gmr_goods_movement_record      gmr,
       -- pcpch_pc_payble_content_header pcpch,
       ak_corporate                 akc,
       ak_corporate_user            akcu,
       gab_globaladdressbook        gab,
       pcpd_pc_product_definition   pcpd,
       pym_payment_terms_master     pym,
       cpc_corporate_profit_center  cpc,
       pdm_productmaster            pdm,
       cm_currency_master           cm_base,
       cm_currency_master           cm_pay,
       v_ppu_pum                    ppu,
       pum_price_unit_master        pum,
       qum_quantity_unit_master     qum,
       pffxd_phy_formula_fx_details pffxd
 where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.is_free_metal_pricing = 'Y'
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and pofh.pofh_id = pfd.pofh_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   and ppfh.ppfh_id = pfqpp.ppfh_id(+)
      --and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
      /* and pcpch.internal_contract_ref_no = pcm.internal_contract_ref_no
                                 and nvl(pcpch.payable_type, 'Payable') = 'Payable'
                                 and poch.element_id = pcpch.element_id*/
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.input_output = 'Input'
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and pocd.pay_in_cur_id = cm_pay.cur_id
   and pfd.price_unit_id = ppu.product_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
   and pcbpd.price_basis <> 'Fixed'
   and pcm.contract_type = 'CONCENTRATES'
      -- and pcm.approval_status = 'Approved'
   and (case when pcm.is_tolling_contract = 'Y' then
        nvl(pcm.approval_status, 'Approved') else pcm.approval_status end) =
       'Approved'
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and nvl(gmr.is_deleted, 'N') = 'N'
   and pcm.contract_status <> 'Cancelled'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active(+) = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active(+) = 'Y'
   and pfqpp.is_active(+) = 'Y'
   and pym.is_active = 'Y'
   and pym.is_deleted = 'N'
   and pcbpd.pffxd_id = pffxd.pffxd_id -- Newly Added
   and pffxd.is_active = 'Y' -- Newly Added
   and nvl(pfd.is_hedge_correction, 'N') = 'N'
--  and akc.corporate_id = '{?CorporateID}'
--  and to_char(pfd.as_of_date, 'dd-Mon-yyyy') = '{?AsOfDate}'
union all
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Hedge Corrections' section,
       (case
         when pfd.is_hedge_correction_during_qp = 'Y' then
          'Within QP'
         else
          'After QP'
       end) sub_section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       aml.underlying_product_id product_id,
       pdm.product_desc product,
       pcm.trader_id trader_id,
       gab.firstname || ' ' || gab.lastname trader,
       cm_pay.cur_id exposure_cur_id,
       cm_pay.cur_code exposure_currency,
       pfd.as_of_date trade_date,
       (case
         when pffxd.fx_rate_type = 'Fixed' then
          pffxd.fixed_fx_rate
         else
          pfd.fx_rate
       end) fx_rate,
       pcm.contract_ref_no,
       null invoice_ref_no,
       null parent_invoice_no,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       pcm.contract_ref_no || ' Item No. ' || pcdi.delivery_item_no contract_item_ref_no,
       gmr.gmr_ref_no gmr_ref_no,
       null element_name,
       null currency_pair,
       pcdi.payment_due_date expected_payment_due_date,
       pfqpp.qp_period_from_date qp_start_date,
       pfqpp.qp_period_to_date qp_end_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
       end) qp,
       (case
          when pcdi.basis_type = 'Arrival' then
           (case
          when pcdi.delivery_period_type = 'Date' then
           pcdi.delivery_to_date
          else
           last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                            pcdi.delivery_to_year,
                            'dd-Mon-yyyy'))
        end) else(case
         when pcdi.delivery_period_type = 'Date' then
          pcdi.delivery_to_date
         else
          last_day(to_date('01-' || pcdi.delivery_to_month || '-' ||
                           pcdi.delivery_to_year,
                           'dd-Mon-yyyy'))
       end) + pcdi.transit_days end) delivery_month,
       pym.payment_term payment_terms,
       pfd.qty_fixed qty,
       qum.qty_unit,
       qum.qty_unit_id,
       qum.decimals qty_decimals,
       pfd.user_price price,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       null payable_receivable,
       pfd.hedge_amount hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date,
       decode(pocd.fx_conversion_method,
              null,
              pfd.hedge_correction_date,
              pfd.fx_correction_date) correction_date,
       axs.action_id activity_type,
       axs.eff_date activity_date,
       phd.companyname cpname
  from pcdi_pc_delivery_item          pcdi,
       pcm_physical_contract_main     pcm,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details     pfd,
       pcbpd_pc_base_price_detail     pcbpd,
       pffxd_phy_formula_fx_details   pffxd, -- Newly Added
       ppfh_phy_price_formula_header  ppfh,
       pfqpp_phy_formula_qp_pricing   pfqpp,
       gmr_goods_movement_record      gmr,
       ak_corporate                   akc,
       ak_corporate_user              akcu,
       gab_globaladdressbook          gab,
       pcpd_pc_product_definition     pcpd,
       pym_payment_terms_master       pym,
       cpc_corporate_profit_center    cpc,
       pdm_productmaster              pdm,
       cm_currency_master             cm_base,
       cm_currency_master             cm_pay,
       v_ppu_pum                      ppu,
       pum_price_unit_master          pum,
       qum_quantity_unit_master       qum,
       axs_action_summary             axs,
       phd_profileheaderdetails       phd,
       aml_attribute_master_list      aml
 where pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pocd.pocd_id = pofh.pocd_id(+)
   and pofh.pofh_id = pfd.pofh_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pffxd_id = pffxd.pffxd_id -- Newly Added
   and pffxd.is_active = 'Y' -- Newly Added
   and pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   and ppfh.ppfh_id = pfqpp.ppfh_id(+)
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no(+)
   and pcm.corporate_id = akc.corporate_id
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcm.payment_term_id = pym.payment_term_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and poch.element_id=aml.attribute_id
   and aml.underlying_product_id = pdm.product_id
   and akc.base_cur_id = cm_base.cur_id
   and pocd.pay_in_cur_id = cm_pay.cur_id
   and pfd.price_unit_id = ppu.product_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
   and pfd.hedge_correction_action_ref_no = axs.internal_action_ref_no
   and pcm.cp_id = phd.profileid
   and pcbpd.price_basis <> 'Fixed'
      --and pcm.approval_status = 'Approved'
   and pcpd.input_output = 'Input'
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and nvl(gmr.is_deleted, 'N') = 'N'
   and pcm.contract_status <> 'Cancelled'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pofh.is_active(+) = 'Y'
   and pcbpd.is_active = 'Y'
   and ppfh.is_active(+) = 'Y'
   and pfqpp.is_active(+) = 'Y'
   and pym.is_active = 'Y'
   and pym.is_deleted = 'N'
   and pfd.is_hedge_correction = 'Y'
-- and akc.corporate_id = '{?CorporateID}'
-- and to_char(pfd.as_of_date, 'dd-Mon-yyyy') = '{?AsOfDate}'
