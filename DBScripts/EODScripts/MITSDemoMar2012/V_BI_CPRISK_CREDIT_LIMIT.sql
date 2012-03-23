CREATE OR REPLACE VIEW V_BI_CPRISK_CREDIT_LIMIT AS
select tt.corporate_id,
       tt.profileid,
       tt.companyname,
       nvl(cpr.net_exposure_limit, 0) alloted_credit_limit,
       tt.current_credit_usage,
       tt.current_credit_usage - nvl(cpr.net_exposure_limit, 0) breach,
       tt.order_id,
       tt.base_cur_id,
       tt.base_cur_code
  from (select t.corporate_id,
               t.profileid,
               t.companyname,
               0 alloted_credit_limit,
               sum(t.current_credit_usage) current_credit_usage,
               rank() over(partition by t.corporate_id order by abs(sum(t.current_credit_usage)) desc) order_id,
               base_cur_id,
               base_cur_code
          from (select iss.corporate_id,
                       pcm.cp_id profileid,
                       phd_contract_cp.companyname companyname,
                       0 alloted_credit_limit,
                       round(iss.total_amount_to_pay, 4) *
                       nvl(iss.fx_to_base, 1) *
                       (case
                          when nvl(iss.payable_receivable, 'NA') = 'Payable' then
                           -1
                          when nvl(iss.payable_receivable, 'NA') = 'Receivable' then
                           1
                          when nvl(iss.payable_receivable, 'NA') = 'NA' then
                           (case
                          when nvl(iss.invoice_type_name, 'NA') =
                               'ServiceInvoiceReceived' then
                           -1
                          when nvl(iss.invoice_type_name, 'NA') =
                               'ServiceInvoiceRaised' then
                           1
                          else
                           (case
                          when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
                           1
                          when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
                           -1
                          else
                           1
                        end) end) else 1 end) current_credit_usage,
                       cm_akc_base_cur.cur_id base_cur_id,
                       cm_akc_base_cur.cur_code base_cur_code
                  from is_invoice_summary            iss,
                       cm_currency_master            cm_p,
                       incm_invoice_contract_mapping incm,
                       pcm_physical_contract_main    pcm,
                       ak_corporate                  akc,
                       cpc_corporate_profit_center   cpc,
                       cpc_corporate_profit_center   cpc1,
                       pcpd_pc_product_definition    pcpd,
                       cm_currency_master            cm_akc_base_cur,
                       css_corporate_strategy_setup  css,
                       blm_business_line_master      blm,
                       pdm_productmaster             pdm,
                       pgm_product_group_master      pgm,
                       phd_profileheaderdetails      phd_contract_cp,
                       ak_corporate_user             akcu,
                       gab_globaladdressbook         gab
                 where iss.is_active = 'Y'
                   and iss.corporate_id is not null
                   and iss.internal_invoice_ref_no =
                       incm.internal_invoice_ref_no(+)
                   and incm.internal_contract_ref_no =
                       pcm.internal_contract_ref_no(+)
                   and iss.corporate_id = akc.corporate_id
                   and iss.internal_contract_ref_no =
                       pcpd.internal_contract_ref_no
                   and iss.profit_center_id = cpc.profit_center_id(+)
                   and pcpd.profit_center_id = cpc1.profit_center_id(+)
                   and iss.invoice_cur_id = cm_p.cur_id(+)
                   and cpc.business_line_id = blm.business_line_id(+)
                   and pcpd.product_id = pdm.product_id(+)
                   and pdm.product_group_id = pgm.product_group_id
                   and phd_contract_cp.profileid(+) = pcm.cp_id
                   and pcm.trader_id = akcu.user_id(+)
                   and akcu.gabid = gab.gabid(+)
                   and nvl(pgm.is_active, 'Y') = 'Y'
                   and nvl(gab.is_active, 'Y') = 'Y'
                   and nvl(pcm.partnership_type, 'Normal') = 'Normal'
                   and iss.is_inv_draft = 'N'
                   and iss.invoice_type_name <> 'Profoma'
                   and cm_akc_base_cur.cur_id = akc.base_cur_id
                   and pcpd.strategy_id = css.strategy_id(+)
                   and iss.total_amount_to_pay <> 0
                union all
                -- Taken from Cash Flow 'Fixed Price GMRs Base Metal' section,
                select akc.corporate_id,
                       pcm.cp_id profileid,
                       phd_contract_cp.companyname companyname,
                       0 alloted_credit_limit,
                       round((pcdi.item_price / nvl(pum.weight, 1)) *
                             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                                      pum.cur_id,
                                                                      akc.base_cur_id,
                                                                      gmr.eff_date,
                                                                      1) *
                             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                   grd.qty_unit_id,
                                                                   pum.weight_unit_id,
                                                                   ((nvl(grd.current_qty,
                                                                         0) +
                                                                   nvl(grd.release_shipped_qty,
                                                                         0) -
                                                                   nvl(grd.title_transfer_out_qty,
                                                                         0))))),
                             2) * (case
                                     when pcm.purchase_sales = 'P' then
                                      -1
                                     else
                                      1
                                   end) current_credit_usage,
                       cm_base.cur_id,
                       cm_base.cur_code
                  from gmr_goods_movement_record    gmr,
                       pcm_physical_contract_main   pcm,
                       pcdi_pc_delivery_item        pcdi,
                       pci_physical_contract_item   pci,
                       ak_corporate                 akc,
                       grd_goods_record_detail      grd,
                       pdm_productmaster            pdm,
                       ppu_product_price_units      ppu,
                       pum_price_unit_master        pum,
                       cpc_corporate_profit_center  cpc,
                       css_corporate_strategy_setup css,
                       cm_currency_master           cm_base,
                       cm_currency_master           cm_pum,
                       pcpd_pc_product_definition   pcpd,
                       blm_business_line_master     blm,
                       pgm_product_group_master     pgm,
                       phd_profileheaderdetails     phd_contract_cp,
                       ak_corporate_user            akcu,
                       gab_globaladdressbook        gab,
                       qum_quantity_unit_master     qum
                 where not exists -- Not Invoiced Check
                 (select iss.corporate_id,
                               iss.internal_invoice_ref_no,
                               iid.internal_gmr_ref_no,
                               gmr.gmr_ref_no
                          from is_invoice_summary          iss,
                               iid_invoicable_item_details iid
                         where iss.internal_invoice_ref_no =
                               iid.internal_invoice_ref_no
                           and iss.is_active='Y'
                           and iid.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no)
                   and grd.internal_contract_item_ref_no =
                       pci.internal_contract_item_ref_no
                   and pci.pcdi_id = pcdi.pcdi_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcdi.item_price_type = 'Fixed'
                   and gmr.corporate_id = akc.corporate_id
                   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and grd.product_id = pdm.product_id
                   and ppu.internal_price_unit_id = pcdi.item_price_unit
                   and ppu.price_unit_id = pum.price_unit_id
                   and grd.profit_center_id = cpc.profit_center_id
                   and grd.strategy_id = css.strategy_id
                   and grd.inventory_status = 'In'
                   and akc.base_cur_id = cm_base.cur_id
                   and (nvl(grd.current_qty, 0) +
                       nvl(grd.release_shipped_qty, 0) -
                       nvl(grd.title_transfer_out_qty, 0)) > 0
                   and cm_pum.cur_id = pum.cur_id
                   and pcm.contract_type = 'BASEMETAL'
                   and pcm.internal_contract_ref_no =
                       pcpd.internal_contract_ref_no
                   and cpc.business_line_id = blm.business_line_id(+)
                   and pcpd.product_id = pdm.product_id(+)
                   and pdm.product_group_id = pgm.product_group_id
                   and phd_contract_cp.profileid(+) = pcm.cp_id
                   and pcm.trader_id = akcu.user_id(+)
                   and akcu.gabid = gab.gabid(+)
                   and grd.qty_unit_id = qum.qty_unit_id(+)
                   and nvl(pgm.is_active, 'Y') = 'Y'
                   and nvl(gab.is_active, 'Y') = 'Y'
                union all
                --------gmr unfixed price
                select mvf.corporate_id,
                       mvf.cp_id profileid,
                       phd_contract_cp.companyname,
                       0 alloted_credit_limit,
                       sum(nvl(mvf.net_contract_value, 0)) current_credit_usage,
                       mvf.base_cur_id,
                       mvf.base_cur_code
                  from mv_fact_phy_unreal_fixed_price mvf,
                       phd_profileheaderdetails       phd_contract_cp,
                       gmr_goods_movement_record      gmr
                 where instr(mvf.contract_ref_no, gmr.gmr_ref_no, 1) = 1
                   and gmr.inventory_status = 'In'
                   and (mvf.corporate_id, mvf.eod_date) in
                       (select eod.corporate_id,
                               max(eod.as_of_date)
                          from eod_end_of_day_details eod
                         where eod.processing_status in
                               ('EOD Processed Successfully',
                                'EOD Process Success,Awaiting Cost Entry')
                         group by eod.corporate_id)
                   and not exists -- Not Invoiced Check
                 (select iss.corporate_id,
                               iss.internal_invoice_ref_no,
                               iid.internal_gmr_ref_no,
                               gmr.gmr_ref_no
                          from is_invoice_summary          iss,
                               iid_invoicable_item_details iid,
                               gmr_goods_movement_record   gmr
                         where iss.internal_invoice_ref_no =
                               iid.internal_invoice_ref_no
                           and iss.is_active='Y'
                           and iid.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                           and iss.corporate_id = mvf.corporate_id
                           and iss.is_inv_draft = 'N'
                           and instr(mvf.contract_ref_no, gmr.gmr_ref_no, 1) = 1)
                   and mvf.cp_id = phd_contract_cp.profileid(+)
                 group by mvf.corporate_id,
                          mvf.cp_id,
                          phd_contract_cp.companyname,
                          mvf.base_cur_id,
                          mvf.base_cur_code) t
         group by t.corporate_id,
                  t.profileid,
                  t.companyname,
                  t.base_cur_id,
                  t.base_cur_code) tt,
       v_bi_cprisk_crc_limits cpr
 where tt.profileid = cpr.profile_id(+)
   and tt.corporate_id = cpr.corporate_id(+)
   and tt.order_id <= 5
 order by tt.order_id
