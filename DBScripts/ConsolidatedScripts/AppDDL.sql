set define off;

ALTER TABLE SPQ_STOCK_PAYABLE_QTY ADD DUE_DATE DATE;
ALTER TABLE PRRQS_PRR_QTY_STATUS ADD DUE_DATE DATE;
ALTER TABLE PCPCH_PC_PAYBLE_CONTENT_HEADER
 ADD (DUE_DATE_DAYS  NUMBER(25,10));
ALTER TABLE PCPCH_PC_PAYBLE_CONTENT_HEADER
 ADD (DUE_DATE_ACTIVITY  VARCHAR2(20 CHAR));

ALTER TABLE PCPCHUL_PAYBLE_CONTNT_HEADR_UL
 ADD (DUE_DATE_DAYS  VARCHAR2(30 CHAR));
ALTER TABLE PCPCHUL_PAYBLE_CONTNT_HEADR_UL
 ADD (DUE_DATE_ACTIVITY  VARCHAR2(20 CHAR));

CREATE OR REPLACE VIEW V_BI_HEDGED_UNHEDGED_POSITION AS
with tad_data as(select t.internal_derivative_ref_no,
       sum(t.allocated_qty) allocated_qty,
       t.allocated_qty_unit_id
  from tad_trade_allocation_details t
 where t.is_active = 'Y'
 group by t.internal_derivative_ref_no, t.allocated_qty_unit_id)
select 'Price Fixations' section_type,
       akc.corporate_id,
       akc.corporate_name,
       aml.attribute_id element_id,
       aml.attribute_name element_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       pcm.internal_contract_ref_no,
       axs.action_ref_no derivative_ref_no,
      round(pfd.qty_fixed * ucm.multiplication_factor,5)  fixation_qty,
      round( (nvl(pfd.qty_fixed, 0) * ucm.multiplication_factor )  -
      (NVL(tad.allocated_qty, 0) * pkg_general.f_get_converted_quantity(pdm.product_id,
                                                    nvl(tad.allocated_qty_unit_id,
                                                        pdm.base_quantity_unit),
                                                    pocd.Qty_To_Be_Fixed_Unit_Id,
                                                    1) * ucm.multiplication_factor                                                    
                                                    ),5)  un_allocated_qty,
     round( nvl(tad.allocated_qty, 0) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pocd.Qty_To_Be_Fixed_Unit_Id,
                                            1) * ucm.multiplication_factor,5) allocated_qty,
       qum_ucm.qty_unit_id,
       qum_ucm.qty_unit allocated_qty_unit,
       '' instrument_name,
       pcm.purchase_sales trade_type,
       to_char(pfd.as_of_date, 'dd-Mon-yyyy') prompt_date,
       nvl(pdm.product_id, pdm_under.product_id) product_id,
       nvl(pdm.product_desc, pdm_under.product_desc) product_desc,
       css.strategy_id,
       css.strategy_name,
       to_char(pfd.as_of_date, 'Mon-yyyy') prompt_month
  FROM pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details     pfd,
       pfam_price_fix_action_mapping  pfam,
       axs_action_summary             axs,
       (select t.price_fixation_id,
                 sum(t.allocated_qty) allocated_qty,
                 t.allocated_qty_unit_id
            from tad_trade_allocation_details t
           where t.is_active = 'Y'
           group by t.price_fixation_id, t.allocated_qty_unit_id)   tad,
       ak_corporate                   akc,
       pcpd_pc_product_definition     pcpd,
       cpc_corporate_profit_center    cpc,
       pdm_productmaster              pdm,
       css_corporate_strategy_setup   css,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       ucm_unit_conversion_master ucm,
       qum_quantity_unit_master qum_ucm,
       qum_quantity_unit_master       qum_qty_unit
 WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   AND poch.pcdi_id = pcdi.pcdi_id
   AND poch.poch_id = pocd.poch_id(+)
   AND pocd.pocd_id = pofh.pocd_id(+)
   AND pofh.pofh_id = pfd.pofh_id(+)
   and pfd.pfd_id = pfam.pfd_id(+)
   and pfam.internal_action_ref_no = axs.internal_action_ref_no(+)
   AND pfd.pfd_id = tad.price_fixation_id(+)
   AND pcm.corporate_id = akc.corporate_id
   AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   AND pcpd.profit_center_id = cpc.profit_center_id
   AND pcpd.product_id = pdm.product_id(+)
   AND pcpd.strategy_id = css.strategy_id
   AND poch.element_id = aml.attribute_id(+)
   AND aml.underlying_product_id = pdm_under.product_id(+)
   AND pocd.Qty_To_Be_Fixed_Unit_Id = qum_qty_unit.qty_unit_id
   and pocd.qty_to_be_fixed_unit_id = ucm.from_qty_unit_id
   and pdm_under.base_quantity_unit = ucm.to_qty_unit_id
   and ucm.to_qty_unit_id = qum_ucm.qty_unit_id
   AND pfd.qty_fixed - nvl(tad.allocated_qty, 0)<>0
   and pcpd.input_output = 'Input' 
   AND pofh.is_active = 'Y'
   AND pocd.is_active = 'Y'   
UNION ALL
select 'Derivative' section_type,
       akc.corporate_id,
       akc.corporate_name,
       null element_id,
       null element_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       null internal_contract_ref_no,
       dt_int.derivative_ref_no,
       dt_int.total_quantity fixation_qty,
       dt_int.total_quantity -
       (nvl(tad_int.allocated_qty, 0) + NVL(tad.allocated_qty, 0)) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pdm.base_quantity_unit,
                                            1) un_allocated_qty,
       (nvl(tad_int.allocated_qty, 0) + NVL(tad.allocated_qty, 0)) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pdm.base_quantity_unit,
                                            1) allocated_qty,
       qum.qty_unit_id,
       qum.qty_unit,
       dim.instrument_name,
       dt_int.trade_type,
       to_char(drm.prompt_date, 'dd-Mon-YYYY') prompt_date,
       pdm.product_id,
       pdm.product_desc,
       css.strategy_id,
       css.strategy_name,
       to_char(drm.prompt_date, 'Mon-YYYY') prompt_month
  FROM dt_derivative_trade          dt_int,
       dt_derivative_trade          dt,
       ak_corporate                 akc,
       cpc_corporate_profit_center  cpc,
       tad_data                      tad,
       tad_data                       tad_int,
       drm_derivative_master        drm,
       dim_der_instrument_master    dim,
       pdm_productmaster            pdm,
       css_corporate_strategy_setup css,
       qum_quantity_unit_master     qum
 WHERE dt_int.internal_derivative_ref_no =
       tad_int.internal_derivative_ref_no(+)
   AND dt.corporate_id = akc.corporate_id
   AND dt.profit_center_id = cpc.profit_center_id
   AND dt_int.dr_id = drm.dr_id
   AND drm.instrument_id = dim.instrument_id
   AND dt.product_id = pdm.product_id
   AND dt_int.is_internal_trade = 'Y'
   AND dt_int.int_trade_parent_der_ref_no =
       dt.internal_derivative_ref_no(+)
   AND dt.internal_derivative_ref_no = tad.internal_derivative_ref_no
   AND dt_int.total_quantity <>
       (NVL(tad_int.allocated_qty, 0) + NVL(tad.allocated_qty, 0))
   AND dt.strategy_id = css.strategy_id
   AND pdm.base_quantity_unit = qum.qty_unit_id
   AND dt_int.status = 'Verified'
   AND dt.status = 'Verified'
   AND drm.is_deleted = 'N'
   AND dim.is_active = 'Y'
UNION ALL
SELECT 'Derivative' section_type,
       akc.corporate_id,
       akc.corporate_name,
       NULL element_id,
       NULL element_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       NULL internal_contract_ref_no,
       dt.derivative_ref_no,
       dt.total_quantity,
       dt.total_quantity -
       NVL(tad.allocated_qty, 0) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pdm.base_quantity_unit,
                                            1) un_allocated_qty,
       NVL(tad.allocated_qty, 0) *
       pkg_general.f_get_converted_quantity(pdm.product_id,
                                            nvl(tad.allocated_qty_unit_id,
                                                pdm.base_quantity_unit),
                                            pdm.base_quantity_unit,
                                            1) allocated_qty,
       qum.qty_unit_id,
       qum.qty_unit,
       dim.instrument_name,
       dt.trade_type,
       TO_CHAR(drm.prompt_date, 'dd-Mon-YYYY') prompt_date,
       pdm.product_id,
       pdm.product_desc,
       css.strategy_id,
       css.strategy_name,
       TO_CHAR(drm.prompt_date, 'Mon-YYYY') prompt_month
  FROM dt_derivative_trade          dt,
       tad_data tad,
       ak_corporate                 akc,
       cpc_corporate_profit_center  cpc,
       drm_derivative_master        drm,
       dim_der_instrument_master    dim,
       pdm_productmaster            pdm,
       css_corporate_strategy_setup css,
       qum_quantity_unit_master     qum
 WHERE dt.internal_derivative_ref_no = tad.internal_derivative_ref_no(+)
   AND dt.corporate_id = akc.corporate_id
   AND dt.profit_center_id = cpc.profit_center_id
   AND dt.dr_id = drm.dr_id
   AND drm.instrument_id = dim.instrument_id
   AND dt.product_id = pdm.product_id
   AND dt.is_internal_trade IS NULL
   AND dt.internal_derivative_ref_no NOT IN
       (SELECT dt_in.internal_derivative_ref_no
          FROM dt_derivative_trade dt_in
         WHERE dt_in.is_internal_trade = 'Y'
           AND dt_in.status = 'Verified')
   AND dt.strategy_id = css.strategy_id
   AND pdm.base_quantity_unit = qum.qty_unit_id
   AND dt.total_quantity <> NVL(tad.allocated_qty, 0)
   AND dt.status = 'Verified';
/
drop materialized view mv_bi_hedged_unhedged_position;
/
create materialized view mv_bi_hedged_unhedged_position
build immediate
refresh force  
on demand
START WITH TO_DATE('01-Feb-2012 16:57:03','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE+10/1440   
WITH PRIMARY KEY
as select * from v_bi_hedged_unhedged_position;
/
-- This is used only for Cash Flow Doamin
CREATE OR REPLACE VIEW V_BI_CASH_FLOW AS
with costtypewithoutaccrual as
     (select   cs.cost_ref_no,
               sum((case
                       when cs.cost_type in ('Reversal')
                       then cs.transact_amt_sign * cs.transaction_amt
                       else 0
                       end
                   )) reversal,
               sum((case
                       when cs.cost_type in ('Actual', 'Direct Actual')
                       then cs.transact_amt_sign * cs.transaction_amt
                       else 0
                       end
                   )) actual
          from cigc_contract_item_gmr_cost cigc,
               cs_cost_store               cs,
               scm_service_charge_master   scm
         where cs.cost_component_id = scm.cost_id
           and cigc.cog_ref_no = cs.cog_ref_no
           and not cs.cost_type in ('Accrual', 'Estimate')
           and cigc.is_deleted = 'N'
           and cs.is_deleted = 'N'
      group by cs.cost_ref_no)
      --1 Invoices
select 'Invoices to extent not paid' section_name,
       iss.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       iss.invoiced_qty weight,
       'MT' weight_unit,
       nvl(iss.fx_to_base, 1) fx_base,
       iss.invoice_created_date effective_date,
       nvl(cpc.profit_center_id, cpc1.profit_center_id) profit_center_id,
       nvl(cpc.profit_center_short_name, cpc1.profit_center_short_name) profit_center,
       akc.base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       (case
         when nvl(pcm.purchase_sales, 'NA') = 'P' then
          'Purchase'
         when nvl(pcm.purchase_sales, 'NA') = 'S' then
          'Sales'
         else
          'NA'
       end) contract_type,
       'Invoices' position_type,
       (case
         when nvl(iss.payable_receivable, 'NA') = 'Payable' then
          'Outflow'
         when nvl(iss.payable_receivable, 'NA') = 'Receivable' then
          'Inflow'
         when nvl(iss.payable_receivable, 'NA') = 'NA' then
          (case
         when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
          'Outflow'
         when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' then
          'Inflow'
         else
          (case
         when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          'Inflow'
         when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          'Outflow'
         else
          'Inflow'
       end) end) else 'Inflow' end) payable_receivable,
       nvl(iss.invoice_ref_no, 'NA') as contract_ref_no,
       (case
         when iss.invoice_type_name = 'AdvancePayment' then
          'Commercial'
         else
          nvl(iss.invoice_type, 'NA')
       end) invoice_type,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code invoice_cur_code,
       round(iss.total_amount_to_pay, 4) * nvl(iss.fx_to_base, 1) *
       (case
          when nvl(iss.payable_receivable, 'NA') = 'Payable' then
           -1
          when nvl(iss.payable_receivable, 'NA') = 'Receivable' then
           1
          when nvl(iss.payable_receivable, 'NA') = 'NA' then
           (case
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
           -1
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' then
           1
          else
           (case
          when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
           1
          when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
           -1
          else
           1
        end) end) else 1 end) invoice_amount_in_base_cur,
       round(iss.total_amount_to_pay, 4) * case
         when (iss.invoice_type = 'Commercial' or
              iss.invoice_type = 'DebitCredit') then
          1
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          -1
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          1
         when nvl(iss.invoice_type_name, 'NA') = 'AdvancePayment' and
              pcm.purchase_sales = 'P' then
          -1
         when nvl(iss.invoice_type_name, 'NA') = 'AdvancePayment' and
              pcm.purchase_sales = 'S' then
          1
       end invoice_amt,
       iss.invoice_issue_date activity_date,
       iss.payment_due_date cash_flow_date,
       iss.invoice_type_name invoice_name
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
   and iss.internal_invoice_ref_no = incm.internal_invoice_ref_no(+)
   and incm.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and iss.corporate_id = akc.corporate_id
   and iss.internal_contract_ref_no = pcpd.internal_contract_ref_no
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
   and pcpd.input_output = 'Input'
   and pcpd.strategy_id = css.strategy_id(+)
   and iss.total_amount_to_pay <> 0
union all
--- 2 Service invoices
select 'Invoices to extent not paid' section_name,
       iss.corporate_id,
       ak.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       'NA' product_id,
       'NA' product_desc,
       'NA' product_group_id,
       'NA' product_group,
       iss.cp_id  counter_party_id,
       phd_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       iss.invoiced_qty weight,
       'MT' weight_unit,
       nvl(iss.fx_to_base, 1) fx_base,
       iss.invoice_created_date effective_date,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_short_name profit_center,
       ak.base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       (case
         when nvl(pcm.purchase_sales, 'NA') = 'P' then
          'Purchase'
         when nvl(pcm.purchase_sales, 'NA') = 'S' then
          'Sales'
         else
          'NA'
       end) contract_type,
       'Invoices' position_type,
       (case
         when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
          'Outflow'
         when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' then
          'Inflow'
         else
          (case
         when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          'Inflow'
         when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          'Outflow'
         else
          'Inflow'
       end) end) payable_receivable,
       nvl(iss.invoice_ref_no, 'NA') as contract_ref_no,
       (case
         when iss.invoice_type_name = 'AdvancePayment' then
          'Commercial'
         else
          nvl(iss.invoice_type, 'NA')
       end) invoice_type,
       iss.invoice_cur_id invoice_cur_id,
       cm_p.cur_code invoice_cur_code,
       round(iss.total_amount_to_pay, 4) * nvl(iss.fx_to_base, 1) *
       (case
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceReceived' then
           -1
          when nvl(iss.invoice_type_name, 'NA') = 'ServiceInvoiceRaised' then
           1
          else
           (case
          when nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
           1
          when nvl(iss.recieved_raised_type, 'NA') = 'Received' then
           -1
          else
           1
        end) end) invoice_amount_in_base_cur,
       round(iss.total_amount_to_pay, 4) * case
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Received' then
          -1
         when nvl(iss.invoice_type, 'NA') = 'Service' and
              nvl(iss.recieved_raised_type, 'NA') = 'Raised' then
          1
       end invoice_amt,
       iss.invoice_issue_date activity_date,
       iss.payment_due_date cash_flow_date,
       iss.invoice_type_name invoice_name
       
  from is_invoice_summary           iss,
       iam_invoice_action_mapping   iam,
       iid_invoicable_item_details  iid,
       axs_action_summary           axs,
       cs_cost_store                cs,
       cigc_contract_item_gmr_cost  cigc,
       gmr_goods_movement_record    gmr,
       pcpd_pc_product_definition   pcpd,
       pcm_physical_contract_main   pcm,
       css_corporate_strategy_setup css,
       ak_corporate                 ak,
       ak_corporate_user            akcu,
       gab_globaladdressbook        gab,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       phd_profileheaderdetails     phd_cp,
       cm_currency_master           cm_akc_base_cur,
       cm_currency_master           cm_p
 where iss.internal_contract_ref_no is null
   and iss.is_active = 'Y'
   and iss.internal_invoice_ref_no = iam.internal_invoice_ref_no
   and iss.internal_invoice_ref_no = iid.internal_invoice_ref_no(+)
   and iam.invoice_action_ref_no = axs.internal_action_ref_no
   and iam.invoice_action_ref_no = cs.internal_action_ref_no(+)
   and cs.cog_ref_no = cigc.cog_ref_no(+)
   and cigc.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
   and gmr.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no(+)
   and pcm.trader_id = akcu.user_id(+)
   and akcu.gabid = gab.gabid(+)
   and pcpd.input_output(+) = 'Input'
   and pcpd.strategy_id = css.strategy_id(+)
   and iss.corporate_id = ak.corporate_id
   and iss.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and iss.cp_id = phd_cp.profileid
   and cm_akc_base_cur.cur_id = ak.base_cur_id
   and iss.invoice_cur_id = cm_p.cur_id(+)
 group by iss.corporate_id,
          iss.cp_id,
          iss.invoiced_qty,
          iss.fx_to_base,
          iss.invoice_created_date,
          iss.recieved_raised_type,
          iss.invoice_type,
          iss.invoice_ref_no,
          iss.total_amount_to_pay,
          iss.recieved_raised_type,
          iss.invoice_cur_id,
          iss.invoice_issue_date,
          iss.payment_due_date,
          iss.invoice_type_name,
          ak.corporate_name,
          ak.base_cur_id,
          blm.business_line_id,
          blm.business_line_name,
          phd_cp.companyname,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          cm_akc_base_cur.cur_code,
          cm_p.cur_code,
          css.strategy_id,
          css.strategy_name,
          gab.gabid,
          gab.firstname || ' ' || gab.lastname,
          pcm.purchase_sales
-- 3. OTC invoices
UNION ALL
SELECT 'OTC invoices',
       dt.corporate_id,
       ak.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       dt.cp_profile_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       dt.broker_profile_id,
       '' broker,
       'NA' cost_type_name,
       dt.total_quantity weight,
       qum.qty_unit weight_unit,
       pkg_general.f_get_converted_currency_amt(dis.corporate_id,
                                                dis.invoice_cur_id,
                                                ak.base_cur_id,
                                                dis.issue_date,
                                                1) FX_Base,
       null effective_date,
       dt.profit_center_id,
       cpc.profit_center_short_name,
       cm_akc_base_cur.cur_id base_cur_id,
       cm_akc_base_cur.cur_code base_cur_code,
       dt.strategy_id strategy_id,
       css.strategy_name,
       (CASE
           WHEN dt.trade_type LIKE '%Buy%' THEN
            'Purchase'
           ELSE
            'Sales'
       END) contract_type,
       'Invoices' position_type,
       (CASE
           WHEN dt.trade_type LIKE '%Buy%' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) inflow_outflow,
       dt.derivative_ref_no ref_no,
       nvl(dis.invoice_type,'NA') invoice_type,
       inv_cur.cur_id invoice_cur_id,
       inv_cur.cur_code invoice_cur_code,
       round((CASE
                 WHEN ak.base_cur_id = dis.invoice_cur_id THEN
                  1
                 ELSE
                  pkg_general.f_get_converted_currency_amt(dis.corporate_id,
                                                           dis.invoice_cur_id,
                                                           ak.base_cur_id,
                                                           dis.issue_date,
                                                           1)
             END) * round(dis.amt_to_pay, 4) * (CASE
                 WHEN nvl(dis.received_raised_type, 'NA') = 'Raised' THEN
                  1
                 WHEN nvl(dis.received_raised_type, 'NA') = 'Received' THEN
                  -1
                 ELSE
                  1
             END),
             4) invoice_amount_in_base_cur,
       round(dis.amt_to_pay, 4) * (CASE
                                       WHEN nvl(dis.received_raised_type, 'NA') = 'Raised' THEN
                                        1
                                       WHEN nvl(dis.received_raised_type, 'NA') = 'Received' THEN
                                        -1
                                       ELSE
                                        1
                                   END),
       dis.issue_date activity_date,
       dis.payment_due_date cash_flow_date,
       nvl(dis.invoice_type_name,'NA') invoice_name
FROM   dt_derivative_trade            dt,
       ak_corporate                   ak,
       cpc_corporate_profit_center    cpc,
       css_corporate_strategy_setup   css,
       cm_currency_master             inv_cur,
       dis_derivative_invoice_summary dis,
       fsh_fin_settlement_header      fsh,
       cm_currency_master             cm_akc_base_cur,
       blm_business_line_master      blm,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       qum_quantity_unit_master      qum
WHERE  ak.corporate_id = dt.corporate_id
AND    cpc.profit_center_id = dt.profit_center_id
AND    css.strategy_id = dt.strategy_id
AND    inv_cur.cur_id = dis.invoice_cur_id
AND    dt.internal_derivative_ref_no = fsh.internal_derivative_ref_no
AND    fsh.fsh_id = dis.internal_settlement_ref_no
AND    dis.invoice_status = 'Active'
AND    fsh.is_deleted = 'N'
AND    dt.is_what_if = 'N'
AND    inv_cur.is_active = 'Y'
AND    css.is_active = 'Y'
AND    cpc.is_active = 'Y'
AND    ak.is_active = 'Y'
AND    cm_akc_base_cur.cur_id = ak.base_cur_id
AND    cpc.business_line_id = blm.business_line_id(+)
AND    dt.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = dt.cp_profile_id
AND    dt.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    dt.quantity_unit_id = qum.qty_unit_id(+)
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y'
-- 4. Currency Trades
UNION ALL
SELECT 'Currency Trades',
       ct.corporate_id,
       ak.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       ct.counter_party_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       0 weight,
       '' weight_unit,
       ct.exchange_rate FX_Base,
       null effective_date,
       ct.profit_center_id,
       cpc.profit_center_short_name,
       akc_cm.cur_id base_cur_id,
       akc_cm.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       crtd.trade_type contract_type,
       'Currency Trades' position_type,
       (CASE
           WHEN upper(crtd.trade_type) = 'BUY' THEN
            'Inflow'
           ELSE
            'Outflow'
       END) inflow_outflow,
       nvl(crtd.internal_treasury_ref_no,'NA') contract_ref_no,
       'NA' invoice_type,
       crtd.cur_id invoice_cur_id,
       crtd_cm.cur_code invoice_cur_code,
       round(crtd.amount, 4) * (CASE
                                    WHEN upper(crtd.trade_type) = 'BUY' THEN
                                     1
                                    ELSE
                                     -1
                                END) * ct.exchange_rate cash_flow_amount,
       round(crtd.amount, 4) * (CASE
                                    WHEN upper(crtd.trade_type) = 'BUY' THEN
                                     1
                                    ELSE
                                     -1
                                END),
       ct.trade_date activity_date,
       ct.payment_due_date cash_flow_date,
       'NA' invoice_name
FROM   ct_currency_trade            ct,
       ak_corporate                 ak,
       cm_currency_master           akc_cm,
       cpc_corporate_profit_center  cpc,
       cm_currency_master           cpc_cm,
       css_corporate_strategy_setup css,
       crtd_cur_trade_details       crtd,
       cm_currency_master           crtd_cm,
       blm_business_line_master      blm,
       drm_derivative_master        drm,
       dim_der_instrument_master    dim,
       pdd_product_derivative_def   pdd,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab
WHERE  ct.corporate_id = ak.corporate_id
AND    ak.base_cur_id = akc_cm.cur_id
AND    ct.profit_center_id = cpc.profit_center_id
AND    ct.strategy_id = css.strategy_id(+)
AND    ct.internal_treasury_ref_no = crtd.internal_treasury_ref_no
AND    crtd.cur_id = crtd_cm.cur_id(+)
AND    cpc.profit_center_cur_id = cpc_cm.cur_id(+)
AND    upper(ct.status) = 'VERIFIED'
and cpc.business_line_id = blm.business_line_id
and    ct.dr_id = drm.dr_id
and    drm.instrument_id = dim.instrument_id
and    dim.product_derivative_id = pdd.derivative_def_id
and    pdd.product_id = pdm.product_id
and    pdm.product_group_id = pgm.product_group_id(+)
AND    phd_contract_cp.profileid(+) = ct.counter_party_id
AND    ct.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y'

-- 5. Accruals - Expense accruals (remaining), income accrual (remaining)

UNION ALL
SELECT 'Accruals ',
       akc.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       scm.cost_component_name cost_type_name,
       cigc.qty weight,
       qum.qty_unit weight_unit,
       nvl(cs.fx_to_base,1) FX_Base,
       cs.effective_date,
       cpc.profit_center_id profit_center_id,
       cpc.profit_center_name profit_center_name,
       akc.base_cur_id,
       cm_base_cur.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       cs.income_expense contract_type,
       'Accruals' position_type,
       (CASE
           WHEN cs.income_expense = 'Expense' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) payable_receivable,
       gmr.gmr_ref_no ref_no,
       'NA' invoice_type,
       cs.transaction_amt_cur_id invoice_cur_id,
       cm_cs_cur.cur_code invoice_cur_code,
       nvl(cs.fx_to_base,1) */* round(nvl(cs.transaction_amt, 0), 4)*/
       (case
           when   cs.transaction_amt - nvl (cs_act.actual, 0)- nvl (cs_act.reversal, 0) > 0
           then   cs.transaction_amt - nvl (cs_act.actual, 0)- nvl (cs_act.reversal, 0)
           else 0
           end
       ) * (CASE
           WHEN cs.income_expense = 'Expense' THEN
            -1
           ELSE
            1
       END) invoice_amount_in_base_cur,
       /*round(nvl(cs.transaction_amt, 0), 4)*/
       (case
           when   cs.transaction_amt - nvl (cs_act.actual, 0)- nvl (cs_act.reversal, 0) > 0
           then   cs.transaction_amt - nvl (cs_act.actual, 0)- nvl (cs_act.reversal, 0)
           else 0
           end
       ) *
       (CASE
            WHEN cs.income_expense = 'Expense' THEN
             -1
            ELSE
             1
        END) invoice_amount,
       cs.effective_date activity_date,
       cs.effective_date cash_flow_date,
       'NA' invoice_name
FROM   cigc_contract_item_gmr_cost  cigc,
       cs_cost_store                cs,
       gmr_goods_movement_record    gmr,
       ak_corporate                 akc,
       cm_currency_master           cm_base_cur,
       pcpd_pc_product_definition pcpd,
       cpc_corporate_profit_center  cpc,
       css_corporate_strategy_setup css,
       cm_currency_master           cm_cs_cur,
       scm_service_charge_master scm,
       pcm_physical_contract_main    pcm,
       blm_business_line_master      blm,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       qum_quantity_unit_master      qum,
       costtypewithoutaccrual      cs_act,
       (select grd.internal_gmr_ref_no,
        pcdi.internal_contract_ref_no
   from grd_goods_record_detail    grd,
        pci_physical_contract_item pci,
        pcdi_pc_delivery_item      pcdi
  where grd.internal_contract_item_ref_no =
        pci.internal_contract_item_ref_no
    and pci.pcdi_id = pcdi.pcdi_id
    and grd.is_deleted = 'N'
    and pci.is_active = 'Y'
    and pcdi.is_active = 'Y'
  group by grd.internal_gmr_ref_no,
           pcdi.internal_contract_ref_no) contract
WHERE  cs.cog_ref_no = cigc.cog_ref_no
AND    cs.cost_type = 'Accrual'
AND    cigc.internal_gmr_ref_no = gmr.internal_gmr_ref_no
AND    gmr.corporate_id = akc.corporate_id
AND    akc.base_cur_id = cm_base_cur.cur_id
and gmr.internal_gmr_ref_no=contract.internal_gmr_ref_no
and contract.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    pcpd.strategy_id = css.strategy_id
AND    cm_cs_cur.cur_id = cs.transaction_amt_cur_id
and    scm.cost_id = cs.cost_component_id
and    scm.cost_type ='SECONDARY_COST'
and    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    cpc.business_line_id = blm.business_line_id(+)
AND    pcpd.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = pcm.cp_id
AND    pcm.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    cigc.qty_unit_id = qum.qty_unit_id(+)
and    cs_act.cost_ref_no(+) = cs.cost_ref_no
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y'
and    cs.is_deleted='N'
and    cigc.is_deleted='N'
and    gmr.is_deleted='N'
and    pcm.is_active='Y'
and    pcpd.is_active='Y'

-- 6. Open Contracts(includes shipped title not transferred), title transferrred but not invoiced

UNION ALL
SELECT 'Open Contracts',
       mvf.corporate_id,
       mvf.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       mvf.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       mvf.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       mvf.contract_quantity weight,
       mvf.contract_quantity_uom weight_unit,
       pkg_general.f_get_converted_currency_amt(mvf.corporate_id,
                                                           mvf.market_value_cur_id,
                                                           mvf.base_cur_id,
                                                           mvf.eod_date,
                                                           1) FX_Base,
       null effective_date,
       mvf.profit_center_id,
       mvf.profit_center,
       mvf.base_cur_id,
       mvf.base_cur_code,
       mvf.strategy_id,
       mvf.strategy_name,
       (CASE
           WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
            'Purchase'
           ELSE
            'Sales'
       END) contract_type,
       nvl(mvf.contract_ref_no,'NA') ref_no,
       'Open Contracts' position_type,
       (CASE
           WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) inflow_outflow,
       'NA' invoice_type,
       NULL invoice_cur_id,
       mvf.m2m_currency invoice_cur_code,
       round((CASE
                 WHEN nvl(cm.cur_code, mvf.base_cur_code) = mvf.m2m_currency THEN
                  1
                 ELSE
                  pkg_general.f_get_converted_currency_amt(mvf.corporate_id,
                                                           mvf.market_value_cur_id,
                                                           mvf.base_cur_id,
                                                           mvf.eod_date,
                                                           1)
             END) * round(mvf.total_cost_in_m2m_currency, 4) * (CASE
                 WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
                  -1
                 ELSE
                  1
             END),
             4),
       round(mvf.total_cost_in_m2m_currency, 4) *
       (CASE
            WHEN mvf.position_sub_type LIKE '%Purchase%' THEN
             -1
            ELSE
             1
        END),
       mvf.issue_trade_date activity_date,
       mvf.eod_date cash_flow_date,
       'NA' invoice_name
FROM   mv_fact_phy_unreal_fixed_price mvf,
       cpc_corporate_profit_center cpc,
       cm_currency_master          cm,
       blm_business_line_master      blm,
       pdm_productmaster             pdm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab
WHERE  mvf.profit_center_id = cpc.profit_center_id
AND    mvf.base_cur_id = cm.cur_id(+)
AND    (mvf.corporate_id, mvf.eod_date) IN
       (SELECT eod.corporate_id,
                MAX(eod.as_of_date)
         FROM   eod_end_of_day_details eod
         WHERE  eod.processing_status IN
                ('EOD Processed Successfully',
                 'EOD Process Success,Awaiting Cost Entry')
         GROUP  BY eod.corporate_id)
AND    NOT EXISTS -- Not Invoiced Check
 (SELECT iss.corporate_id,
               iss.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               gmr.gmr_ref_no
        FROM   is_invoice_summary          iss,
               iid_invoicable_item_details iid,
               gmr_goods_movement_record   gmr
        WHERE  iss.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    iss.is_active ='Y'
        AND    iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
        AND    iss.corporate_id = mvf.corporate_id
        and    iss.is_inv_draft = 'N'
        AND    instr(mvf.contract_ref_no, gmr.gmr_ref_no, 1) = 1)

AND    cpc.business_line_id = blm.business_line_id(+)
AND    mvf.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = mvf.cp_id
AND    mvf.trader_user_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    nvl(pgm.is_active,'Y') = 'Y'

-- 7. Base Metal Open Uninvoiced GMRs with Fixed Price (Base Metal)

UNION ALL
SELECT 'Fixed Price GMRs Base Metal' section_name,
       akc.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
        nvl(grd.title_transfer_out_qty,0))) weight,
       qum.qty_unit weight_unit,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      gmr.eff_date,
                                                      1) FX_Base,
       null effective_date,
       cpc.profit_center_id,
       cpc.profit_center_name,
       akc.base_cur_id base_cur_id,
       cm_base.cur_code base_cur_code,
       css.strategy_id,
       css.strategy_name,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') contract_type,
       'Open Contracts' position_type,
       (CASE
           WHEN pcm.purchase_sales = 'P' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) recievable_payable,
       gmr.internal_gmr_ref_no,
       'NA' invoice_type,
       pum.cur_id invoice_cur_id,
       cm_pum.cur_code invoice_cur_code,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      SYSDATE,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   grd.qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ((nvl(grd.current_qty, 0) +
                                                   nvl(grd.release_shipped_qty,
                                                         0) -
                                                   nvl(grd.title_transfer_out_qty,
                                                         0))))),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) cashflow_amt_in_base_cur,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      gmr.eff_date,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   grd.qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ((nvl(grd.current_qty, 0) +
                                                   nvl(grd.release_shipped_qty,
                                                         0) -
                                                   nvl(grd.title_transfer_out_qty,
                                                         0))))),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) invoice_amt,
       pcm.issue_date activity_date,
       gmr.eff_date cashflow_date,
       'NA' invoice_name
FROM   gmr_goods_movement_record    gmr,
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
       cm_currency_master cm_pum,
       pcpd_pc_product_definition   pcpd,
        blm_business_line_master      blm,
       pgm_product_group_master      pgm,
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       qum_quantity_unit_master      qum
WHERE  NOT EXISTS -- Not Invoiced Check
 (SELECT iss.corporate_id,
               iss.internal_invoice_ref_no,
               iid.internal_gmr_ref_no,
               gmr.gmr_ref_no
        FROM   is_invoice_summary          iss,
               iid_invoicable_item_details iid
        WHERE  iss.internal_invoice_ref_no = iid.internal_invoice_ref_no
        AND    iss.is_active ='Y'
        AND    iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
AND    grd.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
AND    pci.pcdi_id = pcdi.pcdi_id
AND    pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
AND    pcdi.item_price_type = 'Fixed'
AND    gmr.corporate_id = akc.corporate_id
AND    gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
AND    grd.product_id = pdm.product_id
AND    ppu.internal_price_unit_id = pcdi.item_price_unit
AND    ppu.price_unit_id = pum.price_unit_id
AND    grd.profit_center_id = cpc.profit_center_id
AND    grd.strategy_id = css.strategy_id
AND    akc.base_cur_id = cm_base.cur_id
AND    (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -   nvl(grd.title_transfer_out_qty, 0)) > 0
and    cm_pum.cur_id = pum.cur_id
and    pcm.contract_type ='BASEMETAL'
and    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    cpc.business_line_id = blm.business_line_id(+)
aND    pcpd.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = pcm.cp_id
AND    pcm.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    grd.qty_unit_id = qum.qty_unit_id(+)
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y'

-- 8. Open Contracts Fixed Price Basis (Base Metal)

UNION ALL
SELECT 'Fixed Price Contracts Base Metal' section_name,
       akc.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       pdm.product_id,
       pdm.product_desc,
       pgm.product_group_id,
       pgm.product_group_name product_group,
       pcm.cp_id counter_party_id,
       phd_contract_cp.companyname counter_party_name,
       gab.gabid trader_user_id,
       gab.firstname || ' ' || gab.lastname trader_user_name,
       'NA' broker_profile_id,
       'NA' broker,
       'NA' cost_type_name,
       ciqs.open_qty weight,
       qum.qty_unit weight_unit,
       pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      pcm.issue_date,
                                                      1) FX_Base,
       null effective_date,
       cpc.profit_center_id,
       cpc.profit_center_name,
       cm_base.cur_id,
       cm_base.cur_code,
       css.strategy_id,
       css.strategy_name,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') contract_type,
       'Open Contracts' position_type,
       (CASE
           WHEN pcm.purchase_sales = 'P' THEN
            'Outflow'
           ELSE
            'Inflow'
       END) recievable_payable,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no,
       'NA' invoice_type,
       NULL invoice_cur_id,
       cm_base.cur_code invoice_cur_code,
       round((pcdi.item_price / nvl(pum.weight, 1)) *
             pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                      pum.cur_id,
                                                      akc.base_cur_id,
                                                      SYSDATE,
                                                      1) *
             (pkg_general.f_get_converted_quantity(pdm.product_id,
                                                   ciqs.item_qty_unit_id,
                                                   pum.weight_unit_id,
                                                   ciqs.open_qty)),
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END) cashflow_amt_in_base_cur,
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
             2) * (CASE
                       WHEN pcm.purchase_sales = 'P' THEN
                        -1
                       ELSE
                        1
                   END)  invoice_amt,
       pcm.issue_date activity_date,
       pcm.issue_date cashflow_date,
       'NA' invoice_name
FROM   pcm_physical_contract_main    pcm,
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
       phd_profileheaderdetails phd_contract_cp,
       ak_corporate_user             akcu,
       gab_globaladdressbook         gab,
       qum_quantity_unit_master      qum
WHERE  pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
AND    pcdi.pcdi_id = pci.pcdi_id
AND    pcdi.item_price_type = 'Fixed'
AND    pci.internal_contract_item_ref_no = ciqs.internal_contract_item_ref_no
AND    ciqs.open_qty > 0
AND    pcm.corporate_id = akc.corporate_id
AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
AND    pcpd.profit_center_id = cpc.profit_center_id
AND    akc.base_cur_id = cm_base.cur_id
AND    pcpd.strategy_id = css.strategy_id
AND    pcpd.product_id = pdm.product_id
AND    ppu.internal_price_unit_id = pcdi.item_price_unit
AND    ppu.price_unit_id = pum.price_unit_id
AND    pcm.contract_type ='BASEMETAL'
AND    cpc.business_line_id = blm.business_line_id(+)
aND    pcpd.product_id = pdm.product_id(+)
and    pdm.product_group_id = pgm.product_group_id
AND    phd_contract_cp.profileid(+) = pcm.cp_id
AND    pcm.trader_id = akcu.user_id(+)
AND    akcu.gabid = gab.gabid(+)
and    ciqs.item_qty_unit_id = qum.qty_unit_id(+)
and    nvl(pgm.is_active,'Y') = 'Y'
and    nvl(gab.is_active,'Y') = 'Y';
/
create or replace view v_bi_apf_not_applied_shipment as
select pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       pcm.cp_id,
       phd.companyname cpname,
       pcpd.product_id,
       pdm.product_desc product,
       --pcdi.pcdi_id, --Bug 64413
       pcm.contract_ref_no||'-'||pcdi.delivery_item_no pcdi_id,
       pcpq.quality_template_id,
       qat.quality_name,
       diqs.total_qty delivery_item_qty,
       diqs.item_qty_unit_id delivery_item_qty_unit_id,
       diqs_qum.qty_unit delivery_item_qty_unit,
       diqs.gmr_qty arrived_qty,
       dipq.element_id,
       aml.attribute_name element_name,
       dipq.payable_qty,
       dipq.qty_unit_id payable_qty_unit_id,
       dipq_qum.qty_unit payable_qty_unit,
       pcbph.price_description,
       pofh.qp_start_date || ' to ' || pofh.qp_end_date qpperiod,
       pofh.pofh_id,
       axs.action_ref_no price_fixation_no,
       pfd.qty_fixed price_fixed_qty,
       pfd.as_of_date price_fixation_date,
       nvl(pfd.user_price, 0) user_price,
       pfd.price_unit_id,
       ppu.price_unit_name,
       nvl(gpad.allocated_qty, 0) quantity_applied_gmr,
       (pfd.qty_fixed - nvl(gpad.allocated_qty, 0)) quantity_not_applied_gmr,
       sum(pfd.qty_fixed) over(partition by dipq.element_id order by dipq.element_id) total_price_fixed_qty,
       sum(pfd.qty_fixed - nvl(gpad.allocated_qty, 0)) over(partition by dipq.element_id order by dipq.element_id) qty_not_applied_for_shipment,
       nvl((sum(pfd.qty_fixed * pfd.user_price)
            over(partition by dipq.element_id order by dipq.element_id) /
            sum(pfd.qty_fixed)
            over(partition by dipq.element_id order by dipq.element_id)),
           0) weighted_avg_price
  from pcm_physical_contract_main pcm,
       pcmte_pcm_tolling_ext pcmte,
       phd_profileheaderdetails phd,
       pcpd_pc_product_definition pcpd,
       pdm_productmaster pdm,
       pcpq_pc_product_quality pcpq,
       qat_quality_attributes qat,
       pcdi_pc_delivery_item pcdi,
       diqs_delivery_item_qty_status diqs,
       qum_quantity_unit_master diqs_qum,
       dipq_delivery_item_payable_qty dipq,
       qum_quantity_unit_master dipq_qum,
       poch_price_opt_call_off_header poch,
       pocd_price_option_calloff_dtls pocd,
       pcbpd_pc_base_price_detail pcbpd,
       pcbph_pc_base_price_header pcbph,
       pofh_price_opt_fixation_header pofh,
       pfd_price_fixation_details pfd,
       pfam_price_fix_action_mapping pfam,
       axs_action_summary axs,
       (select gpad.pfd_id,
               sum(gpad.allocated_qty) allocated_qty
          from gpad_gmr_price_alloc_dtls gpad
         where gpad.is_active = 'Y'
         group by gpad.pfd_id) gpad,
       v_ppu_pum ppu,
       aml_attribute_master_list aml
 where pcm.cp_id = phd.profileid
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.input_output = 'Input'
   and pcpd.product_id = pdm.product_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pfd.pfd_id = pfam.pfd_id
   and pfam.internal_action_ref_no = axs.internal_action_ref_no
   and pcpq.quality_template_id = qat.quality_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = diqs.pcdi_id
   and diqs.item_qty_unit_id = diqs_qum.qty_unit_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and dipq.qty_unit_id = dipq_qum.qty_unit_id
   and dipq.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and dipq.element_id = poch.element_id
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbph_id = pcbph.pcbph_id
   and poch.element_id = pcbph.element_id
   and pocd.pocd_id = pofh.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pfd.pfd_id = gpad.pfd_id(+)
   and pfd.price_unit_id = ppu.product_price_unit_id
   and dipq.element_id = aml.attribute_id
   and pcdi.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcpq.is_active = 'Y'
   and pcpd.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and pcbpd.is_active = 'Y'
   and pcbph.is_active = 'Y'
   and pofh.is_active = 'Y'
   and pfd.is_active = 'Y'
   and diqs.is_active = 'Y'
   and dipq.is_active = 'Y'
   and pcm.purchase_sales = 'P'
   and pcdi.price_allocation_method = 'Price Allocation'
   and pocd.is_any_day_pricing = 'Y';
/
create or replace view v_projected_price_exp_conc as
with pofh_header_data as( select *
  from pofh_price_opt_fixation_header pofh
 where pofh.internal_gmr_ref_no is null
   and pofh.qty_to_be_fixed is not null
   and pofh.is_active = 'Y'),
pfd_fixation_data as(
select pfd.pofh_id, round(sum(nvl(pfd.qty_fixed, 0)), 5) qty_fixed
  from pfd_price_fixation_details pfd
where pfd.is_active = 'Y'
 --and nvl(pfd.is_price_request,'N') ='N'
-- and  pfd.as_of_date > trunc(sysdate)
 group by pfd.pofh_id)
 
 --- not called off immediate pricing (any day pricing)
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
        (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)
         when (pfqpp.qp_pricing_period_type = 'Date') then
          (pfqpp.qp_date)
         else
          qp_period_from_date
       end) qp_start_date,
       
       (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_to_date,'dd-Mon-YYYY')
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_char(last_day(to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)),'dd-Mon-YYYY')
         when (pfqpp.qp_pricing_period_type = 'Date') then
          to_char(pfqpp.qp_date,'dd-Mon-YYYY')
         else
          to_char(qp_period_to_date,'dd-Mon-YYYY')
       end) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
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
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (PCI.ITEM_QTY  ) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            --pdm.base_quantity_unit,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       PCIPF_PCI_PRICING_FORMULA pcipf,
       PCI_PHYSICAL_CONTRACT_ITEM pci,
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
       
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and dipq.price_option_call_off_status = 'Not Called Off'
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcbph.element_id = aml.attribute_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = pcbph.element_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.internal_contract_item_ref_no = pcipf.internal_contract_item_ref_no
   and pcipf.pcbph_id = pcbph.pcbph_id 
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pci.item_qty_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and pcipf.is_active = 'Y'
 union all
 ---not called off immediate pricing (average pricing)
 select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
        (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          pfqpp.qp_period_from_date
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)
         when (pfqpp.qp_pricing_period_type = 'Date') then
          (pfqpp.qp_date)
         else
          qp_period_from_date
       end) qp_start_date,
       
       (case
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_to_date,'dd-Mon-YYYY')
         when (pfqpp.qp_pricing_period_type = 'Month') then
          to_char(last_day(to_date('01-' || pfqpp.qp_month || '-' || pfqpp.qp_year)),'dd-Mon-YYYY')
         when (pfqpp.qp_pricing_period_type = 'Date') then
          to_char(pfqpp.qp_date,'dd-Mon-YYYY')
         else
          to_char(qp_period_to_date,'dd-Mon-YYYY')
       end) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
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
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       PCI.ITEM_QTY *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       PCIPF_PCI_PRICING_FORMULA pcipf,
       PCI_PHYSICAL_CONTRACT_ITEM pci,
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
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and dipq.price_option_call_off_status = 'Not Called Off'
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcbph.element_id = aml.attribute_id
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.internal_contract_item_ref_no = pcipf.internal_contract_item_ref_no
   and pcipf.pcbph_id = pcbph.pcbph_id 
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = pcbph.element_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = PCI.ITEM_QTY_UNIT_ID
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id   
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and pcipf.is_active = 'Y'
--and ak.corporate_id = '{?CorporateID}'  
union all
--- for event bases  not called off
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       dieqp.expected_qp_start_date qp_start_date,
       to_char(dieqp.expected_qp_end_date,'dd-Mon-YYYY') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
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
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (PCI.ITEM_QTY  ) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            --pdm.base_quantity_unit,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pcbph_pc_base_price_header pcbph,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       PCIPF_PCI_PRICING_FORMULA pcipf,
       PCI_PHYSICAL_CONTRACT_ITEM pci,
       di_del_item_exp_qp_details dieqp,
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
       
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and dipq.price_option_call_off_status = 'Not Called Off'
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcbph.element_id = aml.attribute_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = pcbph.element_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and dieqp.pcdi_id = pcdi.pcdi_id
   and dieqp.pcbpd_id = pcbpd.pcbpd_id
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.internal_contract_item_ref_no = pcipf.internal_contract_item_ref_no
   and pcipf.pcbph_id = pcbph.pcbph_id 
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pci.item_qty_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pfqpp.qp_pricing_period_type = 'Event' 
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and dieqp.is_active = 'Y'
   and pcipf.is_active = 'Y'
 union all
 ------ for not called off event based
 select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       dieqp.expected_qp_start_date qp_start_date,
       to_char(dieqp.expected_qp_end_date,'dd-Mon-YYYY') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       pcbph.element_id,
       aml.attribute_name element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
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
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       PCI.ITEM_QTY *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       aml_attribute_master_list aml,
       pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       PCIPF_PCI_PRICING_FORMULA pcipf,
       PCI_PHYSICAL_CONTRACT_ITEM pci,
        di_del_item_exp_qp_details dieqp,
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
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and dipq.price_option_call_off_status = 'Not Called Off'
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcbph.element_id = aml.attribute_id
   and dieqp.pcdi_id = pcdi.pcdi_id
   and dieqp.pcbpd_id = pcbpd.pcbpd_id
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.internal_contract_item_ref_no = pcipf.internal_contract_item_ref_no
   and pcipf.pcbph_id = pcbph.pcbph_id 
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = pcbph.element_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = PCI.ITEM_QTY_UNIT_ID
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pfqpp.qp_pricing_period_type = 'Event' 
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pcbph.element_id = dipq.element_id   
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and ppfh.is_active = 'Y'
   and dieqp.is_active = 'Y'
   and pcipf.is_active = 'Y'
-- and ak.corporate_id = '{?CorporateID}'  
   
   union all
--Any Day Pricing Concentrate +Contract
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
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
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (pofh.qty_to_be_fixed - (nvl(pfd.qty_fixed, 0))) *
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            qum.qty_unit_id,
                                            --pdm.base_quantity_unit,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
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
       pofh_header_data pofh,
       pfd_fixation_data pfd,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pocd_id = pocd.pocd_id(+)
   and pofh.pofh_id = pfd.pofh_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
--and ak.corporate_id = '{?CorporateID}'
union all
--Any Day Pricing Concentrate +GMR
select ak.corporate_id,
       ak.corporate_name,
       'Any Day Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pcm.issue_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       (pofh.qty_to_be_fixed - nvl(sum(pfd.qty_fixed), 0)) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
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
       pfd_price_fixation_details pfd,
       cpc_corporate_profit_center cpc,
       vd_voyage_detail vd,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pdm.product_id = pcpd.product_id
   and pcpq.quality_template_id = qat.quality_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and pocd.poch_id = poch.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pofh.pocd_id = pocd.pocd_id(+)
   and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
   and pofh.pofh_id = pfd.pofh_id(+)
   and pofh.internal_gmr_ref_no is not null
   and pcpd.profit_center_id = cpc.profit_center_id
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and nvl(vd.status,'NA') in('NA','Active')
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and nvl(gmr.is_deleted, 'N') = 'N'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
--and ak.corporate_id = '{?CorporateID}'
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm_under.product_id,
          pdm_under.product_desc,
          pcm.contract_type,
          pofh.qp_start_date,
          to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy'),
          ppfd.instrument_id,
          pocd.pcbpd_id,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcm.contract_type,
          css.strategy_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          aml.attribute_name,
          pcm.issue_date,
          ppfh.formula_description,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month || ' - ' || pfqpp.qp_year,
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          pcm.contract_ref_no,
          pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no,
          gmr.gmr_ref_no,
          vd.eta,
          pofh.qty_to_be_fixed,
          pdm_under.product_id,
          pdm.product_id,
          qum.qty_unit_id,
          pum.price_unit_name,
          pdm_under.base_quantity_unit,
          pdm.base_quantity_unit,
          qum_under.qty_unit_id,
          qum_under.qty_unit,
          qum_under.decimals,
          to_char(pcqpd.premium_disc_value),
          pcqpd.premium_disc_unit_id,
          dipq.is_price_optionality_present,
          dipq.price_option_call_off_status,
          qat.quality_name
union all
--Average Pricing Concentrate+Contract
select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
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
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       pcdiqd_di_quality_details pcdiqd,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
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
       pofh_header_data pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and poch.element_id = aml.attribute_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = poch.element_id
   and pofh.pocd_id = pocd.pocd_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id   
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
--and ak.corporate_id = '{?CorporateID}'
union all
--Average Pricing Concentrate +GMR
select ak.corporate_id,
       ak.corporate_name,
       'Average Pricing' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       null trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no gmr_no,
       vd.eta expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
       pofh.per_day_pricing_qty *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
  from pcm_physical_contract_main pcm,
       gmr_goods_movement_record gmr,
       ak_corporate ak,
       pcdi_pc_delivery_item pcdi,
       pcdiqd_di_quality_details pcdiqd,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum,
       qum_quantity_unit_master qum_under,
       pcpd_pc_product_definition pcpd,
       css_corporate_strategy_setup css,
       pcpq_pc_product_quality pcpq,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list aml,
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
       vd_voyage_detail vd,
       pofh_price_opt_fixation_header pofh,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.strategy_id = css.strategy_id
   and pdm.product_id = pcpd.product_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcpq.quality_template_id = qat.quality_id
   and qat.product_id = pdm.product_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and poch.element_id = aml.attribute_id
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pcbph.element_id = poch.element_id
   and pofh.pocd_id = pocd.pocd_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
--   and pcm.internal_contract_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and nvl(vd.status,'NA') in('NA','Active')
   and pofh.internal_gmr_ref_no is not null
   and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcm.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id   
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcdi.is_active = 'Y'
   and pdm.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and pofh.is_active = 'Y'
   and poch.is_active = 'Y'
   and pocd.is_active = 'Y'
   and ppfh.is_active = 'Y'
--and ak.corporate_id = '{?CorporateID}'         
-----siva
union all
----Fixed by Price Request Concentrate+Contact
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       f_get_pricing_month_start_date(pocd.pcbpd_id) qp_start_date,
       f_get_pricing_month(pocd.pcbpd_id) qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       null gmr_no,
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
       end) + pcdi.transit_days end) expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
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
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum_under,
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
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       cpc_corporate_profit_center cpc,
       pfqpp_phy_formula_qp_pricing pfqpp,
       cipq_contract_item_payable_qty cipq,
       dipq_delivery_item_payable_qty dipq
 where ak.corporate_id = pcm.corporate_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pdm.product_id = pcpd.product_id
   and pcpd.strategy_id = css.strategy_id
   and qat.product_id = pdm.product_id
   and pcpq.quality_template_id = qat.quality_id
   and pcdi.pcdi_id = poch.pcdi_id
   and pocd.poch_id = poch.poch_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
   and pcbpd.pcbpd_id = pocd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pofh.pocd_id = pocd.pocd_id
   and pofh.qty_to_be_fixed is not null
   and pofh.internal_gmr_ref_no is null
   and pofh.pofh_id = pfd.pofh_id
   and ppfh.ppfh_id = ppfd.ppfh_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and poch.element_id = dipq.element_id   
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcm.contract_status <> 'Cancelled'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N'
   and cipq.element_id = poch.element_id
   and cipq.qty_unit_id = qum.qty_unit_id
      --and ak.corporate_id = '{?CorporateID}'
      --  and  pfd.as_of_date >= sysdate
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate)
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm_under.product_id,
          pdm_under.product_desc,
          css.strategy_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          aml.attribute_name,
          qat.quality_name,
          pfd.as_of_date,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pdm_under.product_id,
          pdm.product_id,
          qum.qty_unit_id,
          pdm_under.base_quantity_unit,
          pdm.base_quantity_unit,
          qum_under.qty_unit,
          qum_under.qty_unit_id,
          qum_under.decimals,
          ppfh.formula_description,
          to_char(pcqpd.premium_disc_value),
          pcqpd.premium_disc_unit_id,
          pum.price_unit_name,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pocd.pcbpd_id,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          ppfd.instrument_id,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          pcdi.transit_days,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          dipq.is_price_optionality_present,
          dipq.price_option_call_off_status,
          qat.quality_name
union all
----Fixed by Price Request Concentrate+GMR
select ak.corporate_id,
       ak.corporate_name,
       'Fixed by Price Request' section,
       cpc.profit_center_id,
       cpc.profit_center_short_name profit_center,
       pdm_under.product_id,
       pdm_under.product_desc product,
       pcm.contract_type product_type,
       pofh.qp_start_date,
       to_char(last_day(pofh.qp_end_date), 'dd-Mon-yyyy') qp_end_date,
       ppfd.instrument_id,
       0 pricing_days,
       'N' is_base_metal,
       'Y' is_concentrate,
       ppfd.exchange_id,
       ppfd.exchange_name exchange,
       css.strategy_id,
       css.strategy_name strategy,
       decode(pcm.purchase_sales, 'P', 'Purchase', 'Sales') purchase_sales,
       poch.element_id,
       aml.attribute_name element_name,
       pfd.as_of_date trade_date,
       (case
         when pfqpp.qp_pricing_period_type = 'Month' then
          pfqpp.qp_month || ' - ' || pfqpp.qp_year
         when pfqpp.qp_pricing_period_type = 'Event' then
          pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         when pfqpp.qp_pricing_period_type = 'Period' then
          to_char(pfqpp.qp_period_from_date, 'dd-Mon-yyyy') || ' to ' ||
          to_char(pfqpp.qp_period_to_date, 'dd-Mon-yyyy')
         when pfqpp.qp_pricing_period_type = 'Date' then
          to_char(pfqpp.qp_date, 'dd-Mon-yyyy')
       end) qp_options,
       pcm.contract_ref_no,
       pcm.contract_type,
       pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no delivery_item_ref_no,
       gmr.gmr_ref_no,
       vd.eta expected_delivery,
       qat.quality_name quality,
       ppfh.formula_description formula,
       to_char(pcqpd.premium_disc_value) premimum,
       pcqpd.premium_disc_unit_id price_unit_id,
       pum.price_unit_name price_unit,
       decode(pcm.purchase_sales, 'P', 1, 'S', -1) * sum(pfd.qty_fixed) *
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                pdm.product_id),
                                            qum.qty_unit_id,
                                            nvl(pdm_under.base_quantity_unit,
                                                pdm.base_quantity_unit),
                                            1) qty,
       qum_under.qty_unit_id,
       qum_under.qty_unit,
       qum_under.decimals qty_decimals,
       null instrument,
       null prompt_date,
       null lots,
       (case
         when dipq.is_price_optionality_present = 'Y' and
              dipq.price_option_call_off_status <> 'Called Off' then
          'Y'
         else
          (case
         when dipq.price_option_call_off_status = 'Not Applicable' then
          null
         else
          'N'
       end) end) pending_calloff
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
       aml_attribute_master_list aml,
       pdm_productmaster pdm_under,
       qum_quantity_unit_master qum_under,
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
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum,
       cpc_corporate_profit_center cpc,
       vd_voyage_detail vd,
       pfqpp_phy_formula_qp_pricing pfqpp,
       cipq_contract_item_payable_qty cipq,
       dipq_delivery_item_payable_qty dipq
 where pcm.internal_contract_ref_no = gmr.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pcdiqd.pcdi_id
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pcdiqd.pcpq_id = pcpq.pcpq_id
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.poch_id = pocd.poch_id
   and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pocd.pcbpd_id = pcbpd.pcbpd_id
   and pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and ppfh.ppfh_id = ppfd.ppfh_id(+)
   and pcbph.element_id = poch.element_id
   and pcbph.pcbph_id = pcbpd.pcbph_id
   and pofh.pocd_id = pocd.pocd_id
   and pofh.pofh_id = pfd.pofh_id
   and pofh.internal_gmr_ref_no is not null
   and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
      and nvl(vd.status,'NA') in('NA','Active')
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and ppfh.is_active = 'Y'
   and pcdi.pcdi_id = dipq.pcdi_id
   and pfqpp.is_qp_any_day_basis = 'Y'
   and pcm.contract_type = 'CONCENTRATES'
   and (case when pcm.is_tolling_contract ='Y' then 'Approved' else   pcm.approval_status end) = 'Approved'
   and pcm.contract_status <> 'Cancelled'
   and nvl(pfqpp.is_spot_pricing, 'N') = 'N' --added to handle spot as separate
   and cipq.element_id = poch.element_id
   and poch.element_id = dipq.element_id   
   and cipq.qty_unit_id = qum.qty_unit_id
   and ak.corporate_id = pcm.corporate_id
   and pcpd.product_id = pdm.product_id
   and pcpd.strategy_id = css.strategy_id
   and qat.product_id = pdm.product_id
   and pcpq.quality_template_id = qat.quality_id
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id(+)
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
      --and ak.corporate_id = '{?CorporateID}'
      --  and  pfd.as_of_date >= sysdate
   and pfd.is_price_request = 'Y'
   and pfd.as_of_date > trunc(sysdate)
 group by ak.corporate_id,
          ak.corporate_name,
          cpc.profit_center_id,
          cpc.profit_center_short_name,
          pdm_under.product_id,
          pdm_under.product_desc,
          css.strategy_id,
          css.strategy_name,
          pcm.purchase_sales,
          poch.element_id,
          aml.attribute_name,
          qat.quality_name,
          pfd.as_of_date,
          pcm.contract_ref_no,
          pcm.contract_type,
          pcm.contract_ref_no,
          pcdi.delivery_item_no,
          pdm_under.product_id,
          pdm.product_id,
          qum.qty_unit_id,
          pdm_under.base_quantity_unit,
          pdm.base_quantity_unit,
          qum_under.qty_unit,
          qum_under.qty_unit_id,
          qum_under.decimals,
          ppfh.formula_description,
          to_char(pcqpd.premium_disc_value),
          pcqpd.premium_disc_unit_id,
          pum.price_unit_name,
          ppfd.exchange_id,
          ppfd.exchange_name,
          pcdi.basis_type,
          pocd.pcbpd_id,
          pcdi.delivery_period_type,
          pcdi.delivery_to_date,
          ppfd.instrument_id,
          pcdi.delivery_to_month,
          pcdi.delivery_to_year,
          pcdi.transit_days,
          pfqpp.qp_pricing_period_type,
          pfqpp.qp_month,
          pfqpp.qp_year,
          pfqpp.qp_pricing_period_type,
          pfqpp.no_of_event_months,
          pfqpp.event_name,
          pfqpp.qp_period_from_date,
          pofh.qp_start_date,
          gmr.gmr_ref_no,
          pofh.qp_end_date,
          vd.eta,
          pfqpp.qp_period_to_date,
          pfqpp.qp_date,
          dipq.is_price_optionality_present,
          dipq.price_option_call_off_status,
          qat.quality_name ;
/
CREATE OR REPLACE VIEW V_DAT_DERIVATIVE_AGG_TRADE
AS 
SELECT dat.aggregate_trade_id, dat.aggregate_trade_ref_no,
          dat.leg_1_int_der_ref_no, dat.leg_1_trade_type,
          dat.leg_2_int_der_ref_no, dat.leg_2_trade_type,
          DECODE (dt1.status, 'Settled', 'Closed out', dt1.status) status,
          pkg_general.f_get_corporate_user_name (dt1.created_by) created_by,
          TO_CHAR (dt1.created_date, 'DD-Mon-YYYY') created_date
     FROM dat_derivative_aggregate_trade dat,
          dt_derivative_trade dt1,
          dt_derivative_trade dt2,
          drm_derivative_master drm,
          dim_der_instrument_master dim,
          pm_period_master pm,
          dtm_deal_type_master dtm
    WHERE dat.leg_1_int_der_ref_no = dt1.internal_derivative_ref_no
      AND dat.leg_2_int_der_ref_no = dt2.internal_derivative_ref_no
      AND dt1.is_internal_trade = 'Y'
      AND dt2.is_internal_trade = 'Y'
      AND dt1.status <> 'Delete'
      AND dt2.status <> 'Delete'
      AND dt1.dr_id = drm.dr_id
      AND drm.instrument_id = dim.instrument_id
      AND drm.period_type_id = pm.period_type_id
      AND dtm.deal_type_id = dt1.deal_type_id;

/
CREATE OR REPLACE VIEW V_BI_METAL_ACC_TRANSACTIONS AS
select mat_temp.ACTION_REF_NO unique_id,
       mat_temp.unique_id unique_id_internal,
       mat_temp.corporate,
       mat_temp.internal_contract_ref_no,
       mat_temp.contract_ref_no,
       mat_temp.internal_contract_item_ref_no,
       mat_temp.contract_item_ref_no,
       mat_temp.pcdi_id,
       mat_temp.delivery_item_ref_no,
       mat_temp.profit_center,
       mat_temp.stock_id,
       mat_temp.stock_ref_no,
       mat_temp.internal_gmr_ref_no,
       mat_temp.gmr_ref_no,
       mat_temp.activity_action_id,
       axm.action_name activity_action_name,
       mat_temp.supplier_id cp_id,
       phd.companyname cp_name,
       mat_temp.debt_supplier_id,
       phd_debt.companyname debt_supplier_name,
       mat_temp.product_id,
       mat_temp.product_name,
       mat_temp.product_name attribute_name,
       mat_temp.debt_qty,
       qum.qty_unit debt_qty_unit,
       --Bug Fix start
       --mat_temp.debt_qty_unit_id debt_qty_unit_id,
       qum.qty_unit debt_qty_unit_id, -- this is done due to the BI Manager schema refered ID as UOM, now we can't change this in jasper.
       --Bug Fix end
       mat_temp.internal_action_ref_no,
       mat_temp.ACTION_REF_NO,
       to_char(mat_temp.activity_date, 'dd-Mon-yyyy') activity_date,
       'NA' assay_type,
       decode(nvl(mat_temp.is_final_assay, 'N'), 'N', 'No', 'Yes') IS_FINAL_ASSAY
  FROM (SELECT retn_temp.unique_id,
               retn_temp.corporate_id corporate,
               retn_temp.internal_contract_ref_no,
               retn_temp.contract_ref_no,
               retn_temp.internal_contract_item_ref_no,
               retn_temp.contract_item_ref_no,
               retn_temp.pcdi_id,
               retn_temp.delivery_item_ref_no,
               retn_temp.profit_center,
               retn_temp.stock_id,
               retn_temp.stock_ref_no,
               retn_temp.internal_gmr_ref_no,
               retn_temp.gmr_ref_no,
               retn_temp.activity_action_id,
               retn_temp.supplier_id,
               retn_temp.to_supplier_id debt_supplier_id,
               retn_temp.product_id,
               retn_temp.product_name,
               retn_temp.element_name,
               (-1 * retn_temp.qty) debt_qty,
               retn_temp.qty_unit_id debt_qty_unit_id,
               retn_temp.internal_action_ref_no,
               retn_temp.activity_date,
               retn_temp.ACTION_REF_NO,
               retn_temp. is_final_assay
          FROM (SELECT spq.spq_id unique_id,
                       axs.corporate_id,
                       pci.internal_contract_ref_no,
                       pci.contract_ref_no,
                       pci.internal_contract_item_ref_no,
                       pci.contract_item_ref_no,
                       pci.pcdi_id,
                       pci.delivery_item_ref_no,
                       pci.profit_center_name profit_center,
                       spq.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       spq.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       spq.activity_action_id,
                       spq.supplier_id,
                       '' to_supplier_id,
                       bvc_product.base_product_id product_id,
                       bvc_product.base_product_name product_name,
                       bvc_product.element_name,
                       spq.payable_qty qty,
                       spq.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       axs.ACTION_REF_NO,
                       spq.is_final_assay
                  FROM spq_stock_payable_qty       spq,
                       grd_goods_record_detail     grd,
                       v_pci                       pci,
                       gmr_goods_movement_record   gmr,
                       axs_action_summary          axs,
                       v_list_base_vs_conc_product bvc_product
                 WHERE spq.internal_action_ref_no =
                       axs.internal_action_ref_no
                   AND spq.smelter_id IS NULL
                   AND spq.is_active = 'Y'
                   AND spq.is_stock_split = 'N'
                   AND spq.qty_type = 'Returnable'
                   AND bvc_product.element_id = spq.element_id
                   AND bvc_product.product_id = grd.product_id
                   AND bvc_product.quality_id = grd.quality_id
                   AND grd.internal_grd_ref_no = spq.internal_grd_ref_no
                   AND gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
                      --and gmr.inventory_status = 'In'
                   AND pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                   and grd.is_deleted = 'N'
                UNION
                SELECT prrqs.prrqs_id unique_id,
                       axs.corporate_id,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       grd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       pci.profit_center_name profit_center,
                       prrqs.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       aml.attribute_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       axs.action_ref_no,
                       null is_final_assay
                  FROM prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       grd_goods_record_detail   grd,
                       gmr_goods_movement_record gmr,
                       aml_attribute_master_list aml,
                       v_pci                     pci
                 WHERE prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   AND gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and aml.attribute_id = grd.element_id
                   AND grd.internal_grd_ref_no = prrqs.internal_grd_ref_no
                   AND grd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   AND pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                   AND prrqs.cp_type = 'Supplier'
                   AND prrqs.is_active = 'Y'
                   AND prrqs.qty_type = 'Returnable'
                   AND pdm.product_id = prrqs.product_id
                   AND prrqs.activity_action_id in
                       ('pledgeTransfer', 'financialSettlement')
                UNION
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       dgrd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       pci.profit_center_name profit_center,
                       prrqs.internal_grd_ref_no stock_id,
                       dgrd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       null element_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       axs.action_ref_no,
                       null is_final_assay
                  from prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       dgrd_delivered_grd        dgrd,
                       gmr_goods_movement_record gmr,
                       v_pci                     pci
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
                   and dgrd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       dgrd.internal_contract_item_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'financialSettlement'
                union all
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       '' internal_contract_ref_no,
                       '' contract_ref_no,
                       '' internal_contract_item_ref_no,
                       '' contract_item_ref_no,
                       '' pcdi_id,
                       '' delivery_item_ref_no,
                       '' profit_center,
                       prrqs.internal_grd_ref_no stock_id,
                       '' stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       '' gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       null element_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       axs.action_ref_no,
                       null is_final_assay
                  from prrqs_prr_qty_status prrqs,
                       axs_action_summary   axs,
                       pdm_productmaster    pdm
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'metalBalanceTransfer') retn_temp
        union all
        SELECT prrqs.prrqs_id unique_id,
               axs.corporate_id corporate,
               '' internal_contract_ref_no,
               '' contract_ref_no,
               '' internal_contract_item_ref_no,
               '' contract_item_ref_no,
               '' pcdi_id,
               '' delivery_item_ref_no,
               '' profit_center,
               dgrd.internal_dgrd_ref_no stock_id,
               dgrd.internal_stock_ref_no stock_ref_no,
               prrqs.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               prrqs.activity_action_id,
               prrqs.cp_id supplier_id,
               prrqs.to_cp_id debt_supplier_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               null element,
               (prrqs.qty_sign * prrqs.qty) debt_qty,
               prrqs.qty_unit_id debt_qty_unit_id,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               axs.action_ref_no,
               null is_final_assay
          FROM prrqs_prr_qty_status      prrqs,
               axs_action_summary        axs,
               pdm_productmaster         pdm,
               dgrd_delivered_grd        dgrd,
               gmr_goods_movement_record gmr
         WHERE prrqs.internal_action_ref_no = axs.internal_action_ref_no
           AND prrqs.cp_type = 'Supplier'
           AND prrqs.is_active = 'Y'
           AND prrqs.qty_type = 'Returned'
           AND pdm.product_id = prrqs.product_id
           AND dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
           AND gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no) mat_temp,
       axm_action_master axm,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_debt,
       qum_quantity_unit_master qum /*,
       (SELECT ash.is_final_assay_fully_finalized,
       ash.assay_type,
       ash.internal_grd_ref_no
            FROM ash_assay_header ash
           WHERE ash.assay_type = 'Final Assay' AND ash.is_active = 'Y') ash_temp*/
 WHERE axm.action_id = mat_temp.activity_action_id
   AND mat_temp.supplier_id = phd.profileid
   AND mat_temp.debt_supplier_id = phd_debt.profileid(+)   
/* AND mat_temp.stock_id = ash_temp.internal_grd_ref_no(+)*/
   AND mat_temp.debt_qty_unit_id = qum.qty_unit_id;
/
create or replace view v_gmr_concentrate_details as
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
       comp_product_name,
       comp_quality,
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
       compqty_base_conv_rate,
       comp_base_qty_unit,
       comp_base_qty_unit_id,
       price_fixation_status,
       sum(total_qty) total_qty,
       sum(item_open_qty) item_open_qty,
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
       base_quantity_unit_id,
       position_type,
       assay_convertion_rate
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
               pdm.product_desc comp_product_name,
               qat.quality_name comp_quality,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_desc, pdm.product_desc)
                 else
                  pdm.product_desc
               end) product_name,
               nvl(qat.quality_name, qav_qat.quality_name) quality,
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
               (pkg_general.f_get_converted_quantity(grd.product_id,
                                                     grd.qty_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1)) compqty_base_conv_rate,
               qum.qty_unit comp_base_qty_unit,
               qum.qty_unit_id comp_base_qty_unit_id,
               null price_fixation_status,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.qty,
                                                           grd.qty_unit_id) total_qty,
               (case when pcpq.unit_of_measure = 'Dry'
               then (nvl(grd.current_qty,
                                                            0) +
                                                       nvl(grd.release_shipped_qty,
                                                            0) -
                                                       nvl(grd.title_transfer_out_qty,
                                                            0))
                else
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                       sam.ash_id,
                                                       (nvl(grd.current_qty,
                                                            0) +
                                                       nvl(grd.release_shipped_qty,
                                                            0) -
                                                       nvl(grd.title_transfer_out_qty,
                                                            0)),
                                                       grd.qty_unit_id)
                                                       end) item_open_qty,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           (nvl(grd.current_qty,
                                                                0) +
                                                           nvl(grd.release_shipped_qty,
                                                                0) -
                                                           nvl(grd.title_transfer_out_qty,
                                                                0)),
                                                           grd.qty_unit_id) open_qty,
               0 price_fixed_qty,
               0 unfixed_qty,
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
               nvl(qat.quality_id, qav_qat.quality_id) quality_id,
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
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_quantity_unit_id,
               'CONCENTRATES' position_type,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           1,
                                                           grd.qty_unit_id) assay_convertion_rate
          from grd_goods_record_detail        grd,
               gmr_goods_movement_record      gmr,
               sld_storage_location_detail    sld,
               cim_citymaster                 cim_sld,
               cim_citymaster                 cim_gmr,
               cym_countrymaster              cym_sld,
               cym_countrymaster              cym_gmr,
               v_pci_pcdi_details             pci,
               pcpq_pc_product_quality        pcpq,
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
           and pci.pcpq_id = pcpq.pcpq_id(+)
           and pci.inco_term_id = itm.incoterm_id(+)
           and pci.strategy_id = css.strategy_id(+)
           and pci.profit_center_id = cpc.profit_center_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.is_internal_movement = 'N'
           and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
               nvl(grd.title_transfer_out_qty, 0)) > 0
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
               pdm.product_desc comp_product_name,
               qat.quality_name comp_quality,
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
               (pkg_general.f_get_converted_quantity(grd.product_id,
                                                     grd.net_weight_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1)) compqty_base_conv_rate,
               qum.qty_unit comp_base_qty_unit,
               qum.qty_unit_id comp_base_qty_unit_id,
               null price_fixation_status,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.net_weight,
                                                           grd.net_weight_unit_id) total_qty,
               (case when pcpq.unit_of_measure = 'Dry'
               then grd.current_qty
               else
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                       sam.ash_id,
                                                       grd.current_qty,
                                                       grd.net_weight_unit_id)
                                                       end) item_open_qty,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.current_qty,
                                                           grd.net_weight_unit_id) open_qty,
               0 price_fixed_qty,
               0 unfixed_qty,
               grd.net_weight_unit_id item_qty_unit_id,
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
                  grd.net_weight_unit_id
                 else
                  rm.qty_unit_id_numerator
               end) element_qty_unit_id,
               aml.underlying_product_id,
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_quantity_unit_id,
               'CONCENTRATES' position_type,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           1,
                                                           grd.net_weight_unit_id) assay_convertion_rate
          from dgrd_delivered_grd             grd,
               gmr_goods_movement_record      gmr,
               sld_storage_location_detail    sld,
               cim_citymaster                 cim_sld,
               cim_citymaster                 cim_gmr,
               cym_countrymaster              cym_sld,
               cym_countrymaster              cym_gmr,
               v_pci_pcdi_details             pci,
               pcpq_pc_product_quality        pcpq,
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
           and pci.pcpq_id = pcpq.pcpq_id(+)
           and pci.inco_term_id = itm.incoterm_id(+)
           and pci.strategy_id = css.strategy_id(+)
           and pci.profit_center_id = cpc.profit_center_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.is_internal_movement = 'N'
           and nvl(grd.inventory_status, 'NA') <> 'Out'
              -- and nvl(gmr.inventory_status, 'NA') <> 'Out'
           and nvl(grd.current_qty, 0) > 0
           and gmr.created_by = gab.gabid(+)
        union all
        --for internal moment
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
               pdm.product_desc comp_product_name,
               qat.quality_name comp_quality,
               (case
                 when pdtm.product_type_name = 'Composite' then
                  nvl(pdm_under.product_desc, pdm.product_desc)
                 else
                  pdm.product_desc
               end) product_name,
               nvl(qat.quality_name, qav_qat.quality_name) quality,
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
               (pkg_general.f_get_converted_quantity(grd.product_id,
                                                     grd.qty_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1)) compqty_base_conv_rate,
               qum.qty_unit comp_base_qty_unit,
               qum.qty_unit_id comp_base_qty_unit_id,
               null price_fixation_status,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.qty,
                                                           grd.qty_unit_id) total_qty,
              (case when pcpq.unit_of_measure = 'Dry'
              then (nvl(grd.current_qty,
                                                            0) +
                                                       nvl(grd.release_shipped_qty,
                                                            0) -
                                                       nvl(grd.title_transfer_out_qty,
                                                            0))
               else
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                       sam.ash_id,
                                                       (nvl(grd.current_qty,
                                                            0) +
                                                       nvl(grd.release_shipped_qty,
                                                            0) -
                                                       nvl(grd.title_transfer_out_qty,
                                                            0)),
                                                       grd.qty_unit_id)
                                                       end) item_open_qty,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           (nvl(grd.current_qty,
                                                                0) +
                                                           nvl(grd.release_shipped_qty,
                                                                0) -
                                                           nvl(grd.title_transfer_out_qty,
                                                                0)),
                                                           grd.qty_unit_id) open_qty,
               0 price_fixed_qty,
               0 unfixed_qty,
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
               nvl(qat.quality_id, qav_qat.quality_id) quality_id,
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
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_quantity_unit_id,
               'CONCENTRATES' position_type,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           1,
                                                           grd.qty_unit_id) assay_convertion_rate
          from grd_goods_record_detail        grd,
               gmr_goods_movement_record      gmr,
               sld_storage_location_detail    sld,
               cim_citymaster                 cim_sld,
               cim_citymaster                 cim_gmr,
               cym_countrymaster              cym_sld,
               cym_countrymaster              cym_gmr,
               v_pci_pcdi_details             pci,
               pcpq_pc_product_quality        pcpq,
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
           and pci.pcpq_id = pcpq.pcpq_id(+)
           and pci.inco_term_id = itm.incoterm_id(+)
           and grd.strategy_id = css.strategy_id(+)
           and grd.profit_center_id = cpc.profit_center_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.is_internal_movement = 'Y'
           and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
               nvl(grd.title_transfer_out_qty, 0)) > 0
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
               pdm.product_desc comp_product_name,
               qat.quality_name comp_quality,
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
               (pkg_general.f_get_converted_quantity(grd.product_id,
                                                     grd.net_weight_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1)) compqty_base_conv_rate,
               qum.qty_unit comp_base_qty_unit,
               qum.qty_unit_id comp_base_qty_unit_id,
               null price_fixation_status,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.net_weight,
                                                           grd.net_weight_unit_id) total_qty,
               (case when pcpq.unit_of_measure = 'Dry'
               then grd.current_qty
               else
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                       sam.ash_id,
                                                       grd.current_qty,
                                                       grd.net_weight_unit_id)
                                                       end) item_open_qty,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           grd.current_qty,
                                                           grd.net_weight_unit_id) open_qty,
               0 price_fixed_qty,
               0 unfixed_qty,
               grd.net_weight_unit_id item_qty_unit_id,
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
                  grd.net_weight_unit_id
                 else
                  rm.qty_unit_id_numerator
               end) element_qty_unit_id,
               aml.underlying_product_id,
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_quantity_unit_id,
               'CONCENTRATES' position_type,
               pkg_report_general.fn_get_element_assay_qty(aml.attribute_id,
                                                           sam.ash_id,
                                                           'Wet',
                                                           1,
                                                           grd.net_weight_unit_id) assay_convertion_rate
          from dgrd_delivered_grd             grd,
               gmr_goods_movement_record      gmr,
               sld_storage_location_detail    sld,
               cim_citymaster                 cim_sld,
               cim_citymaster                 cim_gmr,
               cym_countrymaster              cym_sld,
               cym_countrymaster              cym_gmr,
               v_pci_pcdi_details             pci,
               pcpq_pc_product_quality        pcpq,
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
           and pci.pcpq_id = pcpq.pcpq_id(+)
           and pci.inco_term_id = itm.incoterm_id(+)
           and grd.strategy_id = css.strategy_id(+)
           and grd.profit_center_id = cpc.profit_center_id(+)
           and cpc.business_line_id = blm.business_line_id(+)
           and gmr.is_internal_movement = 'Y'
           and nvl(grd.inventory_status, 'NA') <> 'Out'
              -- and nvl(gmr.inventory_status, 'NA') <> 'Out'
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
          compqty_base_conv_rate,
          comp_base_qty_unit,
          comp_base_qty_unit_id,
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
          comp_product_name,
          comp_quality,
          attribute_name,
          element_qty_unit_id,
          underlying_product_id,
          base_quantity_unit_id,
          position_type,
          assay_convertion_rate;
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
       pdm.product_desc comp_product_name,
       qat.quality_name comp_quality,
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
       ciqs.open_qty item_open_qty,
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
       pcm.contract_type position_type,
       1 contract_row,
       pkg_general.f_get_converted_quantity(pcpd.product_id,
                                            pci.item_qty_unit_id,
                                            pdm.base_quantity_unit,
                                            1) compqty_base_conv_rate,
       qum.qty_unit comp_base_qty_unit,
       qum.qty_unit_id comp_base_qty_unit_id
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
   and nvl(pcm.is_tolling_contract, 'N') = 'N'
   and akcu.gabid = gab.gabid
   and pcdb.country_id = cym.country_id
   and pcdb.city_id = cim.city_id
   and pci.pcdi_id = pfs.pcdi_id
   and pci.internal_contract_item_ref_no =
       pfs.internal_contract_item_ref_no
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and ciqs.is_active = 'Y'
   and pcdb.is_active = 'Y'
union all
select pcdi.pcdi_id,
       pci.internal_contract_item_ref_no,
       gcd.groupname corporate_group,
       blm.business_line_name business_line,
       akc.corporate_id,
       akc.corporate_name,
       cpc.profit_center_short_name profit_center,
       css.strategy_name strategy,
       pdm.product_desc comp_product_name,
       qat.quality_name comp_quality,
       (case
         when pdtm.product_type_name = 'Composite' then
          nvl(pdm_under.product_desc, pdm.product_desc)
         else
          pdm.product_desc
       end) product_name,
       nvl(qat.quality_name, qav_qat.quality_name) quality,
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
                                             aml.attribute_id) total_qty,
       (case when pcpq.unit_of_measure = 'Dry'
       then ciqs.open_qty
       else
       pkg_report_general.fn_get_assay_dry_qty(pdm.product_id,
                                               pcpq.assay_header_id,
                                               ciqs.open_qty,
                                               ciqs.item_qty_unit_id)
                                               end) item_open_qty,
       pkg_report_general.fn_get_element_qty(pci.internal_contract_item_ref_no,
                                             ciqs.open_qty,
                                             ciqs.item_qty_unit_id,
                                             pcpq.assay_header_id,
                                             aml.attribute_id) open_qty,
       0 price_fixed_qty,
       0 unfixed_qty,
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
       nvl(qat.quality_id, qav_qat.quality_id) quality_id,
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
       row_number() over(partition by pci.internal_contract_item_ref_no order by pci.internal_contract_item_ref_no, aml.attribute_id) contract_row,
       (pkg_general.f_get_converted_quantity(pcpd.product_id,
                                             pci.item_qty_unit_id,
                                             pdm.base_quantity_unit,
                                             1)) compqty_base_conv_rate,
       qum.qty_unit comp_base_qty_unit,
       qum.qty_unit_id comp_base_qty_unit_id
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
  --- and nvl(pcm.is_tolling_contract, 'N') = 'N'
   and qav.comp_quality_id = qav_qat.quality_id(+)
   and pcpq.quality_template_id = qat.quality_id(+)
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no(+)
   and pcpd.profit_center_id = cpc.profit_center_id
   and pcpd.product_id = pdm.product_id
   and pdm.product_type_id = pdtm.product_type_id
   and pcpd.strategy_id = css.strategy_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pcm.contract_status = 'In Position'
   and pcm.contract_type = 'CONCENTRATES'
   and akc.groupid = gcd.groupid
   and pcm.trader_id = akcu.user_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and pcdi.pcdi_id = diqs.pcdi_id
   and akcu.gabid = gab.gabid
   and pcdb.country_id = cym.country_id
   and pcdb.city_id = cim.city_id
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and ciqs.is_active = 'Y'
   and pcdb.is_active = 'Y';
/

alter table PCIUL_PHY_CONTRACT_ITEM_UL add SPE_SETTLEMENT_STATUS VARCHAR2 (15 Char);
alter table PCIUL_PHY_CONTRACT_ITEM_UL add ITEM_STATUS VARCHAR2 (15 Char);

create or replace view v_daily_fx_exposure_vat as
select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       NULL sub_section,
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
                                                iis.invoice_issue_date ,
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
       ivd.vat_amount_in_vat_cur ) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date
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
   and nvl(ivd.vat_amount_in_vat_cur,0) <> 0
   and iis.is_active = 'Y'
   and iis1.is_active = 'Y'
   and gmr.is_deleted = 'N'
union all
 select akc.corporate_id,
       akc.corporate_name,
       cm_base.cur_code base_currency,
       'Physicals' main_section,
       'Vat' section,
       NULL sub_section,
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
                                                iis.invoice_issue_date ,
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
     (case when PCM.PURCHASE_SALES = 'S' then ivd.vat_amount_in_inv_cur else nvl(IVD.VAT_AMOUNT_IN_VAT_CUR,ivd.vat_amount_in_inv_cur) end) ) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date
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
   and (case when PCM.PURCHASE_SALES = 'S' then ivd.invoice_cur_id else nvl(IVD.VAT_REMIT_CUR_ID,ivd.invoice_cur_id) end ) = cm_pay.cur_id --for purchase exposure in vat cur and
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
                                                iis.invoice_issue_date ,
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
       (decode(iis.payable_receivable, 'Payable', 1, 'Receivable', -1) *  ---for make outflow sales amount
      ivd.vat_amount_in_vat_cur ) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date
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
   and ivd.vat_remit_cur_id =  cm_pay.cur_id
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
        (case when pfqpp.is_qp_any_day_basis = 'Y' then
          'Spot Fixations'
          else
          'Average Fixations'
          end)sub_section,
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
       (case when pffxd.fx_rate_type='Fixed' then
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
       pofh.per_day_pricing_qty qty,
       qum.qty_unit,
       qum.qty_unit_id,
       qum.decimals qty_decimals,
       (nvl(pfd.user_price,0)+nvl(pfd.adjustment_price,0)) price,
       pum.price_unit_id,
       pum.price_unit_name price_unit,
       null payable_receivable,
       decode(pcm.purchase_sales, 'P', -1, 'S', 1) *
       ((nvl(pfd.user_price,0)+nvl(pfd.adjustment_price,0)) / nvl(ppu.weight, 1)) *
       /*(round(pkg_general.f_get_converted_currency_amt(akc.corporate_id,
                                                       ppu.cur_id,
                                                       cm_pay.cur_id,
                                                       pfd.as_of_date,
                                                       1),
              5) **/
      (case when pffxd.fx_rate_type='Fixed' then
       pffxd.fixed_fx_rate
       else
       pfd.fx_rate
       end)*    
       pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                 pdm.product_id),
                                             qum.qty_unit_id,
                                             pum.weight_unit_id,
                                             pofh.per_day_pricing_qty) hedging_amount,
       '' cost_type,
       null effective_date,
       '' buy_sell,
       null value_date
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
       ak_corporate                akc,
       ak_corporate_user           akcu,
       gab_globaladdressbook       gab,
       pcpd_pc_product_definition  pcpd,
       pym_payment_terms_master    pym,
       cpc_corporate_profit_center cpc,
       pdm_productmaster           pdm,
       cm_currency_master          cm_base,
       cm_currency_master          cm_pay,
       v_ppu_pum                   ppu,
       pum_price_unit_master       pum,
       qum_quantity_unit_master    qum,
       pffxd_phy_formula_fx_details   pffxd
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
   and pffxd.is_active = 'Y' -- Newly Added;
/
ALTER TABLE DHD_DOCUMENT_HEADER_DETAILS
MODIFY(DOC_NAME VARCHAR2(100 CHAR));
CREATE OR REPLACE PROCEDURE  "GENERATECONTRACTOUTPUTDOC" (
   p_contractno    VARCHAR2,
   p_docrefno      VARCHAR2,
   p_activity_id   VARCHAR2
)
IS
   docid                      VARCHAR2 (15);
   contractsection            VARCHAR2 (50)   := 'Contract Buyer Section';
   issuedate                  VARCHAR2 (50);
   contractrefno              VARCHAR2 (50);
   cpcontractrefno            VARCHAR2 (50);
   corporateid                VARCHAR2 (20);
   corporatename              VARCHAR2 (100);
   contracttype               VARCHAR2 (20);
   cpid                       VARCHAR2 (20);
   counterparty               VARCHAR2 (200);
   traxystrader               VARCHAR2 (200);
   cpcontactpersoson          VARCHAR2 (200);
   buyer                      VARCHAR2 (200);
   seller                     VARCHAR2 (200);
   cpaddress                  VARCHAR2 (4000);
   executiontype              VARCHAR2 (20);
   agencydetails              VARCHAR2 (4000);
   jvdetails                  VARCHAR2 (4000);
   productdef                 VARCHAR2 (4000);
   display_order              NUMBER (10)     := 1;
   pcdi_count                 NUMBER (10)     := 1;
   deliveryschedulecomments   VARCHAR2 (4000) := '';
   paymentdetails             VARCHAR2 (4000) := '';
   paymenttext                VARCHAR2 (4000) := '';
   taxes                      VARCHAR2 (4000) := '';
   insuranceterms             VARCHAR2 (4000) := '';
   otherterms                 VARCHAR2 (4000) := '';
   product_group_type         VARCHAR2 (50)   := '';
   qualityprintnamereq        VARCHAR2 (15)   := '';
   qualityprintname           VARCHAR2 (1000) := '';
   istollingcontract          VARCHAR2 (1);
   agreementnumber            VARCHAR2 (50);
   contractservicetype        VARCHAR2 (50);
   passthrough                VARCHAR2 (10);
   passthroughdetails         VARCHAR2 (10);
   inputoutputproduct         VARCHAR2 (50);
   inputoutputquality         VARCHAR2 (50);
   iscommercialfeeapplied     VARCHAR2 (1);
   amendmentdate              VARCHAR2 (50);
   amendmentreason            VARCHAR2 (4000);



   CURSOR cr_delivery
   IS
      SELECT   pcdi.pcdi_id pcdi_id,
               (pcm.contract_ref_no || '-' || pcdi.delivery_item_no
               ) AS delivery_item_ref_no
          FROM pcdi_pc_delivery_item pcdi, pcm_physical_contract_main pcm
         WHERE pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           AND pcm.internal_contract_ref_no = p_contractno
           AND pcdi.is_active = 'Y'
      ORDER BY TO_NUMBER (pcdi.delivery_item_no);
BEGIN
   SELECT seq_cont_op.NEXTVAL
     INTO docid
     FROM DUAL;

   BEGIN
      SELECT TO_CHAR (pcm.issue_date, 'dd-Mon-YYYY'), pcm.contract_ref_no,
             NVL (pcm.cp_contract_ref_no, 'NA'), ak.corporate_name,
             ak.corporate_id, pcm.purchase_sales, phd.companyname,
             pcm.cp_id, pcm.product_group_type, pcm.partnership_type, pcm.is_tolling_contract,pcm.is_commercial_fee_applied
        INTO issuedate, contractrefno,
             cpcontractrefno, corporatename,
             corporateid, contracttype, counterparty,
             cpid, product_group_type, executiontype, istollingcontract,iscommercialfeeapplied
        FROM pcm_physical_contract_main pcm,
             ak_corporate ak,
             phd_profileheaderdetails phd
       WHERE pcm.corporate_id = ak.corporate_id
         AND phd.profileid = pcm.cp_id
         AND pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         issuedate := '';
         contractrefno := '';
         cpcontractrefno := '';
         corporatename := '';
         corporateid := '';
         contracttype := '';
         counterparty := '';
         cpid := '';
         product_group_type := '';
         istollingcontract :='';
         iscommercialfeeapplied :='';
   END;

   IF (contracttype = 'P')
   THEN
      buyer := corporatename;
      seller := counterparty;
      contractsection := 'Contract Buyer Section';
   ELSE
      buyer := counterparty;
      seller := corporatename;
      contractsection := 'Contract Seller Section';
   END IF;

   INSERT INTO cos_contract_output_summary
               (doc_id, doc_type, template_type, template_name,
                internal_doc_ref_no, ver_no, issue_date, is_amendment,
                status, created_by, created_date, updated_by, updated_date,
                cancelled_by, cancelled_date, send_date, received_date,
                internal_contract_ref_no, contract_ref_no, contract_type,
                corporate_id, contract_signing_date, approval_type,
                amendment_no, watermark, amendment_date, document_print_type
               )
        VALUES (docid, 'ORIGINAL', NULL, NULL,
                p_docrefno, 1, issuedate, 'N',
                'Active', NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL,
                p_contractno, contractrefno, contracttype,
                corporateid, NULL, NULL,
                NULL, NULL, NULL, 'Full Contract'
               );

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Contract Ref No', 'Y', NULL,
                NULL, contractrefno, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

  IF(istollingcontract = 'Y')
   THEN
    BEGIN
        SELECT pcmte.agreement_number
            INTO agreementnumber
                FROM pcmte_pcm_tolling_ext pcmte
                    WHERE pcmte.int_contract_ref_no =
                                  (SELECT pcm.internal_contract_ref_no
                                     FROM pcm_physical_contract_main pcm
                                    WHERE pcm.contract_ref_no = contractrefno);
    EXCEPTION
            WHEN NO_DATA_FOUND
                THEN
                agreementnumber := NULL;
    END;

    display_order := display_order + 1;

    INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Agreement No', 'Y', NULL,
                NULL, agreementnumber, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

    END IF;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Counterparty Contract Ref No', 'Y', NULL,
                NULL, cpcontractrefno, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

 


   BEGIN
      SELECT NVL ((gab.firstname || ' ' || gab.lastname), 'NA')
        INTO traxystrader
        FROM ak_corporate_user aku, gab_globaladdressbook gab
       WHERE gab.gabid = aku.gabid
         AND aku.user_id IN (
                             SELECT pcm.trader_id
                               FROM pcm_physical_contract_main pcm
                              WHERE pcm.internal_contract_ref_no =
                                                                  p_contractno);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         traxystrader := NULL;
   END;

   BEGIN
      SELECT gab.firstname || ' ' || gab.lastname
        INTO cpcontactpersoson
        FROM gab_globaladdressbook gab
       WHERE gab.gabid = (SELECT pcm.cp_person_in_charge_id
                            FROM pcm_physical_contract_main pcm
                           WHERE pcm.internal_contract_ref_no = p_contractno);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         cpcontactpersoson := NULL;
   END;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Trader', 'Y', NULL,
                NULL, traxystrader, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'CP Trader name', 'Y', NULL,
                NULL, cpcontactpersoson, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Contract Issue Date', 'Y', NULL,
                NULL, issuedate, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );
            
    BEGIN
     SELECT TO_CHAR (par.amendment_date, 'dd-Mon-YYYY'), par.amendment_reason
        INTO amendmentdate, amendmentreason
         FROM par_physical_amend_reason par
        WHERE par.internal_contract_ref_no = p_contractno
         AND par.amendment_type = 'Amend'
         AND par.is_active = 'Y';
    EXCEPTION
        WHEN NO_DATA_FOUND
       THEN
      amendmentdate := '';
      amendmentreason := '';
    END;
    
    display_order := display_order + 1;
   
  INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Amendment Date', 'Y', NULL,
                NULL, amendmentdate, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );
  
  display_order := display_order + 1;
   
  INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Amendment Reason', 'Y', NULL,
                NULL, amendmentreason, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Buyer', 'Y', NULL,
                NULL, buyer, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Seller', 'Y', NULL,
                NULL, seller, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT    pad.address
             || ','
             || cim.city_name
             || ','
             || sm.state_name
             || ','
             || cym.country_name
        INTO cpaddress
        FROM pad_profile_addresses pad,
             cym_countrymaster cym,
             cim_citymaster cim,
             sm_state_master sm
       WHERE pad.address_type = 'Main'
         AND pad.country_id = cym.country_id
         AND pad.city_id(+) = cim.city_id
         AND cim.state_id(+) = sm.state_id
         AND pad.profile_id = cpid
         AND pad.is_deleted = 'N';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         cpaddress := NULL;
   END;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Counter Party',
                'CP Address', 'Y', NULL,
                NULL, cpaddress, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   IF (executiontype = 'Joint Venture')
   THEN
      IF (contracttype = 'P')
      THEN
         jvdetails := getjvdetails (p_contractno);
      ELSE
         jvdetails := 'JV Contract';
      END IF;

      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'JV',
                   'JV Details', 'Y', NULL,
                   NULL, jvdetails, NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   ELSIF (executiontype = 'Agency')
   THEN
      IF (contracttype = 'P')
      THEN
         BEGIN
            SELECT (   'Agency Counter Party :'
                    || phd.company_long_name1
                    || CHR (10)
                    || 'Commission Details :'
                    || (CASE
                           WHEN pcad.commission_type = 'Fixed'
                              THEN    pcad.commission_value
                                   || ' '
                                   || pum.price_unit_name
                           WHEN pcad.commission_type = 'Formula'
                              THEN pacf.external_formula
                        END
                       )
                    || CHR (10)
                    || 'Basis :'
                    || (itm.incoterm || '-' || cim.city_name)
                   )
              INTO agencydetails
              FROM pcad_pc_agency_detail pcad,
                   phd_profileheaderdetails phd,
                   ppu_product_price_units ppu,
                   pum_price_unit_master pum,
                   pacf_phy_agency_comm_formula pacf,
                   itm_incoterm_master itm,
                   cim_citymaster cim
             WHERE pcad.agency_cp_id = phd.profileid
               AND pcad.commission_unit_id = ppu.internal_price_unit_id(+)
               AND ppu.price_unit_id = pum.price_unit_id(+)
               AND pcad.commission_formula_id = pacf.pacf_id(+)
               AND pcad.basis_incoterm_id = itm.incoterm_id
               AND pcad.basis_city_id = cim.city_id
               AND pcad.internal_contract_ref_no = p_contractno;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               agencydetails := '';
         END;
      ELSE
         agencydetails := 'Agency Contract';
      END IF;

      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Agency',
                   'Agency', 'Y', NULL,
                   NULL, agencydetails, NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   END IF;
   
    IF(istollingcontract = 'Y')
     THEN
      IF (contracttype = 'P')
        THEN
            contractservicetype :='Sell Tolling Services';
        ELSE
            contractservicetype :='Buy Tolling Services';
        END IF;

    display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Contract Type', 'Y', NULL,
                NULL, contractservicetype, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );
 
     BEGIN
        SELECT pcmte.is_pass_through
            INTO passthrough
                FROM pcmte_pcm_tolling_ext pcmte
                    WHERE pcmte.int_contract_ref_no =
                                  (SELECT pcm.internal_contract_ref_no
                                     FROM pcm_physical_contract_main pcm
                                    WHERE pcm.contract_ref_no = contractrefno);
    EXCEPTION
            WHEN NO_DATA_FOUND
                THEN
                passthrough := NULL;
    END;
    
    IF(passthrough='Y')
    THEN 
        passthroughdetails:= 'Yes';
        ELSE
        passthroughdetails:= 'No';
    END IF;

    display_order := display_order + 1;

    INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, contractsection,
                'Pass Through', 'Y', NULL,
                NULL, passthroughdetails, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );
   END IF;

   BEGIN
      SELECT    pdm.product_desc
             || CHR (10)
             || (CASE
                    WHEN pcpd.qty_type = 'Fixed'
                       THEN    f_format_to_char (pcpd.qty_max_val, 4)
                            || ' '
                            || qum.qty_unit_desc
                    ELSE    pcpd.qty_min_operator
                         || ' '
                         || f_format_to_char (pcpd.qty_min_val, 4)
                         || ' '
                         || pcpd.qty_max_operator
                         || ' '
                         || f_format_to_char (pcpd.qty_max_val, 4)
                         || ' '
                         || qum.qty_unit_desc
                 END
                )
        INTO productdef
        FROM pcpd_pc_product_definition pcpd,
             pdm_productmaster pdm,
             qum_quantity_unit_master qum
       WHERE pcpd.product_id = pdm.product_id
         AND pcpd.qty_unit_id = qum.qty_unit_id
         and pcpd.input_output = 'Input'
         AND pcpd.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         productdef := '';
   END;

    IF(istollingcontract = 'Y')
    THEN
    inputoutputproduct := 'Input Product and Quantity';
    inputoutputquality := 'Input Quality/Qualities';
    ELSE
    inputoutputproduct := 'Product and Quantity';
    inputoutputquality := 'Quality/Qualities';
    END IF;
    
   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, inputoutputproduct,
                inputoutputproduct, 'Y', NULL,
                NULL, productdef, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;

   BEGIN
      SELECT pcpd.is_quality_print_name_req, pcpd.quality_print_name
        INTO qualityprintnamereq, qualityprintname
        FROM pcpd_pc_product_definition pcpd, pcm_physical_contract_main pcm
       WHERE pcpd.internal_contract_ref_no = pcm.internal_contract_ref_no
         AND pcpd.input_output = 'Input'
         AND pcpd.internal_contract_ref_no = p_contractno;
   END;

   IF (qualityprintnamereq = 'Y')
   THEN
      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, inputoutputquality,
                   inputoutputquality, 'Y', NULL,
                   NULL, qualityprintname, NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   ELSE
      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, inputoutputquality,
                   inputoutputquality, 'Y', NULL,
                   NULL, getcontractqualitydetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   END IF;
   
   
   IF(istollingcontract = 'Y')
        THEN
   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Output Product and Qualities',
                'Output Product and Qualities', 'Y', NULL,
                NULL, getoutputproductdetails (p_contractno), NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );
   END IF;
   
   IF (iscommercialfeeapplied = 'Y')
    THEN
        FOR delivery_rec IN cr_delivery
       LOOP
          display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name,
                   is_print_reqd, pre_content_text_id, post_content_text_id,
                   contract_content,
                   pre_content_text, post_content_text, is_custom_section,
                   is_footer_section, is_amend_section, print_type,
                   is_changed
                  )
           VALUES (docid, display_order, NULL, 'Time of Shipment',
                   'Delivery Item:' || delivery_rec.delivery_item_ref_no,
                   'Y', NULL, NULL,
                   getdeliverydetailswithcomfee (p_contractno,
                                             delivery_rec.pcdi_id,
                                             cpid
                                            ),
                   NULL, NULL, 'N',
                   'N', 'N', 'FULL',
                   'N'
                  );
    END LOOP;
   
   ELSE

    FOR delivery_rec IN cr_delivery
        LOOP
         
      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name,
                   is_print_reqd, pre_content_text_id, post_content_text_id,
                   contract_content,
                   pre_content_text, post_content_text, is_custom_section,
                   is_footer_section, is_amend_section, print_type,
                   is_changed
                  )
           VALUES (docid, display_order, NULL, 'Time of Shipment',
                   'Delivery Item:' || delivery_rec.delivery_item_ref_no,
                   'Y', NULL, NULL,
                   getdeliveryperioddetails (p_contractno,
                                             delivery_rec.pcdi_id
                                            ),
                   NULL, NULL, 'N',
                   'N', 'N', 'FULL',
                   'N'
                  );
    END LOOP;
   
   END IF;

   BEGIN
      SELECT pcm.del_schedule_comments
        INTO deliveryschedulecomments
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         deliveryschedulecomments := '';
   END;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Time of Shipment',
                'Other Terms', 'Y', NULL,
                NULL, deliveryschedulecomments, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT    cm.cur_code
             || ' ,'
             || pym.payterm_long_name
             || (CASE
                    WHEN pcm.provisional_pymt_pctg IS NULL
                       THEN ''
                    ELSE    ', '
                         || pcm.provisional_pymt_pctg
                         || ' % of Provisional Invoice Amount'
                 END
                )
        INTO paymentdetails
        FROM pcm_physical_contract_main pcm,
             pym_payment_terms_master pym,
             cm_currency_master cm
       WHERE pcm.payment_term_id = pym.payment_term_id
         AND cm.cur_id = pcm.invoice_currency_id
         AND pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         paymentdetails := '';
   END;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Payment Terms',
                'Payment Terms', 'Y', NULL,
                NULL, paymentdetails, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   IF (product_group_type = 'CONCENTRATES')
   THEN
   IF(istollingcontract = 'N')
   THEN
      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Payable Content',
                   'Payable Content', 'Y', NULL,
                   NULL, getpayablecontentdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   
   ELSE
   
       display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Payable Content',
                   'Payable Content', 'Y', NULL,
                   NULL, gettolpayablecontentdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Returnable Content',
                   'Returnable Content', 'Y', NULL,
                   NULL, getreturnablecontentdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
    END IF;
    

      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Treatment Charges',
                   'Treatment Charges', 'Y', NULL,
                   NULL, gettcdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );

      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Refining Charges',
                   'Refining Charges', 'Y', NULL,
                   NULL, getrcdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );

      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Penalties',
                   'Penalties', 'Y', NULL,
                   NULL, getpenaltydetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
                  
       IF(istollingcontract = 'Y')
        THEN
        display_order := display_order + 1;

        INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Small Lot Charges',
                   'Small Lot Charges', 'Y', NULL,
                   NULL, getslcdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
                  
        display_order := display_order + 1;

        INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Container Charges',
                   'Container Charges', 'Y', NULL,
                   NULL, getccdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
                  
        display_order := display_order + 1;

        INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Other Charges',
                   'Other Charges', 'Y', NULL,
                   NULL, getocdetails (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
                          
       END IF;
                   

      display_order := display_order + 1;

      INSERT INTO cod_contract_output_detail
                  (doc_id, display_order, field_layout_id, section_name,
                   field_name, is_print_reqd, pre_content_text_id,
                   post_content_text_id, contract_content, pre_content_text,
                   post_content_text, is_custom_section, is_footer_section,
                   is_amend_section, print_type, is_changed
                  )
           VALUES (docid, display_order, NULL, 'Assaying Rules',
                   'Assaying Rules', 'Y', NULL,
                   NULL, getassayinrules (p_contractno), NULL,
                   NULL, 'N', 'N',
                   'N', 'FULL', 'N'
                  );
   END IF;


   BEGIN
      SELECT pcm.payment_text
        INTO paymenttext
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         paymenttext := '';
   END;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Payment Text',
                'Payment Text', 'Y', NULL,
                NULL, paymenttext, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT pcm.taxes
        INTO taxes
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         taxes := '';
   END;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Taxes, Tarrifs and Duties',
                'Terms ', 'Y', NULL,
                NULL, taxes, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT pcm.insurance
        INTO insuranceterms
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         insuranceterms := '';
   END;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Insurance',
                'Insurance Terms ', 'Y', NULL,
                NULL, insuranceterms, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   BEGIN
      SELECT pcm.other_terms
        INTO otherterms
        FROM pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = p_contractno;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         otherterms := '';
   END;

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'Other Terms',
                'Other Terms ', 'Y', NULL,
                NULL, otherterms, NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );

   display_order := display_order + 1;

   INSERT INTO cod_contract_output_detail
               (doc_id, display_order, field_layout_id, section_name,
                field_name, is_print_reqd, pre_content_text_id,
                post_content_text_id, contract_content, pre_content_text,
                post_content_text, is_custom_section, is_footer_section,
                is_amend_section, print_type, is_changed
               )
        VALUES (docid, display_order, NULL, 'List of Documents',
                'List of Documents', 'Y', NULL,
                NULL, getcontractdocuments (p_contractno), NULL,
                NULL, 'N', 'N',
                'N', 'FULL', 'N'
               );
END;
/
CREATE OR REPLACE FUNCTION GETCONTRACTQUALITYDETAILS (
p_contractNo VARCHAR2 
)
return VARCHAR2 is

    cursor cr_quality 
    IS
          Select QAT.QUALITY_NAME ||':'|| (CASE
              WHEN PCPQ.QTY_TYPE ='Fixed'
                 THEN f_format_to_char(PCPQ.QTY_MAX_VAL,4) || ' '|| QUM.QTY_UNIT_DESC 
              ELSE PCPQ.QTY_MIN_OP ||' '||  f_format_to_char(PCPQ.QTY_MIN_VAL,4) ||' '||  PCPQ.QTY_MAX_OP ||' '||  f_format_to_char(PCPQ.QTY_MAX_VAL,4) || ' '|| QUM.QTY_UNIT_DESC 
              END
              ) quality_details,ORM.ORIGIN_NAME as origin_name,
         (CASE
              WHEN PCPQ.ASSAY_HEADER_ID IS NOT NULL
                 THEN getChemicalAttributes(PCPQ.ASSAY_HEADER_ID)
          END) CHEM_ATTR,
          (CASE
              WHEN PCPQ.PHY_ATTRIBUTE_GROUP_NO IS NOT NULL
                 THEN getPhysicalAttributes(PCPQ.PHY_ATTRIBUTE_GROUP_NO)
          END) PHY_ATTR             
          
    from PCPQ_PC_PRODUCT_QUALITY PCPQ, PCPD_PC_PRODUCT_DEFINITION PCPD, QAT_QUALITY_ATTRIBUTES QAT,
    QUM_QUANTITY_UNIT_MASTER QUM,POM_PRODUCT_ORIGIN_MASTER pom,ORM_ORIGIN_MASTER orm
    Where PCPQ.QTY_UNIT_ID = QUM.QTY_UNIT_ID 
     AND PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID 
     AND PCPD.PCPD_ID = PCPQ.PCPD_ID
     AND QAT.PRODUCT_ORIGIN_ID = POM.PRODUCT_ORIGIN_ID(+)
     AND POM.ORIGIN_ID = ORM.ORIGIN_ID(+)
     AND PCPQ.IS_ACTIVE = 'Y'
     AND PCPD.INTERNAL_CONTRACT_REF_NO =p_contractNo;   
    
    qualityDescription VARCHAR2(4000) :='';  
    begin
            for quality_rec in cr_quality
            loop
            if(qualityDescription is not null) then
            qualityDescription:=qualityDescription ||chr(10)||quality_rec.quality_details ||chr(10);
            else
            qualityDescription:=quality_rec.quality_details ||chr(10);
            end if;
                        
            if (quality_rec.origin_name is not null) then
                qualityDescription:=qualityDescription ||'Origin :' || quality_rec.origin_name || chr(10);
            end if;
            
            if (quality_rec.CHEM_ATTR is not null) then
                qualityDescription:=qualityDescription ||'Chemical Composition :' || chr(10)|| quality_rec.CHEM_ATTR ;
            end if;
            
            if (quality_rec.PHY_ATTR is not null) then
                qualityDescription:=qualityDescription ||'Physical Specifications :'|| chr(10)|| quality_rec.PHY_ATTR;
            end if;
           
            end loop;
            return  qualityDescription;
    end;
/
CREATE OR REPLACE FUNCTION "GETOUTPUTPRODUCTDETAILS" (
   p_contractno   VARCHAR2
)
   RETURN VARCHAR2
IS
   CURSOR cr_output_products
   IS
      SELECT pcpd.pcpd_id AS pcpd_id, pdm.product_desc AS productdesc
        FROM pcpd_pc_product_definition pcpd, pdm_productmaster pdm
       WHERE pcpd.product_id = pdm.product_id
         AND pcpd.input_output = 'Output'
         AND pcpd.internal_contract_ref_no = p_contractno;

   productdescription   VARCHAR2 (4000) := '';
   i                           NUMBER (5)      := 1;
BEGIN
   FOR product_rec IN cr_output_products
   LOOP
      productdescription := productdescription || 'Product '
         || i
         || ': '
         || product_rec.productdesc;
      productdescription :=
            productdescription
         || CHR (10)
         || getoutputqualitydetails (product_rec.pcpd_id)
         || CHR (10);
      i := i + 1;
   END LOOP;

   RETURN productdescription;
END;
/
CREATE OR REPLACE FUNCTION "GETOUTPUTQUALITYDETAILS" (c_pcpd_id VARCHAR2)
   RETURN VARCHAR2
IS
   CURSOR cr_quality
   IS
      SELECT qat.quality_name AS quality_details,
             (CASE
                 WHEN pcpq.assay_header_id IS NOT NULL
                    THEN getchemicalattributes (pcpq.assay_header_id)
              END
             ) chem_attr,
             (CASE
                 WHEN pcpq.phy_attribute_group_no IS NOT NULL
                    THEN getphysicalattributes (pcpq.phy_attribute_group_no)
              END
             ) phy_attr
        FROM pcpq_pc_product_quality pcpq,
             pcpd_pc_product_definition pcpd,
             qat_quality_attributes qat
       WHERE pcpq.quality_template_id = qat.quality_id
         AND pcpd.pcpd_id = pcpq.pcpd_id
         AND pcpq.is_active = 'Y'
         AND pcpd.pcpd_id = c_pcpd_id;

   qualitydescription   VARCHAR2 (2000) := '';
   i                    NUMBER (5)      := 1;
   
BEGIN
   FOR quality_rec IN cr_quality
   LOOP
   
      qualitydescription :=
            qualitydescription ||  'Quality '
         || i
         || ': '
         || quality_rec.quality_details || CHR(10) ;
   
      
      IF (quality_rec.chem_attr IS NOT NULL)
      THEN
         qualitydescription :=
               qualitydescription
            || 'Chemical Composition :'
            || CHR (10)
            || quality_rec.chem_attr;
      END IF;

      IF (quality_rec.phy_attr IS NOT NULL)
      THEN
         qualitydescription :=
               qualitydescription
            || 'Physical Specifications :'
            || CHR (10)
            || quality_rec.phy_attr;
      END IF;
      
      i := i+1;
      
   END LOOP;

   RETURN qualitydescription;
END;
/
create or replace view v_metal_accounts_transactions as
select mat_temp.unique_id,
       mat_temp.corporate_id,
       mat_temp.contract_type,
       mat_temp.internal_contract_ref_no,
       mat_temp.contract_ref_no,
       mat_temp.contract_middle_no,
       mat_temp.internal_contract_item_ref_no,
       mat_temp.contract_item_ref_no,
       mat_temp.pcdi_id,
       mat_temp.delivery_item_no,
       mat_temp.del_distribution_item_no,
       mat_temp.delivery_item_ref_no,
       mat_temp.stock_id,
       mat_temp.stock_ref_no,
       mat_temp.internal_gmr_ref_no,
       mat_temp.gmr_ref_no,
       mat_temp.activity_action_id,
       axm.action_name activity_action_name,
       mat_temp.supplier_id,
       phd.companyname supplier_name,
       mat_temp.debt_supplier_id,
       phd_debt.companyname debt_supplier_name,
       mat_temp.product_id,
       mat_temp.product_name,
       mat_temp.debt_qty,
       nvl(mat_temp.ext_debt_qty, 0) ext_debt_qty,
       mat_temp.debt_qty_unit_id,
       qum.qty_unit debt_qty_unit,
       mat_temp.internal_action_ref_no,
       to_char(mat_temp.activity_date, 'dd-Mon-yyyy') activity_date,
       mat_temp.assay_content,
       nvl(mat_temp.ext_assay_content, 0) ext_assay_content,
       nvl(mat_temp.assay_finalized, 'N') assay_finalized,
       mat_temp.due_date
  from (select retn_temp.unique_id,
               retn_temp.corporate_id,
               retn_temp.contract_type,
               retn_temp.internal_contract_ref_no,
               retn_temp.contract_ref_no,
               retn_temp.contract_middle_no,
               retn_temp.internal_contract_item_ref_no,
               retn_temp.contract_item_ref_no,
               retn_temp.pcdi_id,
               retn_temp.delivery_item_no,
               retn_temp.del_distribution_item_no,
               retn_temp.delivery_item_ref_no,
               retn_temp.stock_id,
               retn_temp.stock_ref_no,
               retn_temp.internal_gmr_ref_no,
               retn_temp.gmr_ref_no,
               retn_temp.activity_action_id,
               retn_temp.supplier_id,
               retn_temp.to_supplier_id debt_supplier_id,
               retn_temp.product_id,
               retn_temp.product_name,
               (-1 * retn_temp.qty) debt_qty,
               (-1 * retn_temp.ext_qty) ext_debt_qty,
               retn_temp.qty_unit_id debt_qty_unit_id,
               retn_temp.internal_action_ref_no,
               retn_temp.activity_date,
               retn_temp.assay_content,
               retn_temp.ext_assay_content,
               retn_temp.assay_finalized,
               retn_temp.due_date
          from (select spq.spq_id unique_id,
                       spq.corporate_id,
                       pci.contract_type,
                       pci.internal_contract_ref_no,
                       pci.contract_ref_no,
                       pci.middle_no contract_middle_no,
                       pci.internal_contract_item_ref_no,
                       pci.contract_item_ref_no,
                       pci.pcdi_id,
                       pci.delivery_item_no,
                       pci.del_distribution_item_no,
                       pci.delivery_item_ref_no,
                       spq.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       spq.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       spq.activity_action_id,
                       spq.supplier_id,
                       '' to_supplier_id,
                       bvc_product.base_product_id product_id,
                       bvc_product.base_product_name product_name,
                       spq.payable_qty qty,
                       spq.ext_payable_qty ext_qty,
                       spq.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       spq.assay_content,
                       spq.ext_assay_content ext_assay_content,
                       spq.is_final_assay assay_finalized,
                       spq.due_date
                  from spq_stock_payable_qty       spq,
                       grd_goods_record_detail     grd,
                       v_pci                       pci,
                       gmr_goods_movement_record   gmr,
                       axs_action_summary          axs,
                       v_list_base_vs_conc_product bvc_product
                 where spq.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and spq.smelter_id is null
                   and spq.is_active = 'Y'
                   and spq.is_stock_split = 'N'
                   and spq.qty_type = 'Returnable'
                   and bvc_product.element_id = spq.element_id
                   and bvc_product.product_id = grd.product_id
                   and bvc_product.quality_id = grd.quality_id
                   and grd.internal_grd_ref_no = spq.internal_grd_ref_no
                   and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                union
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       pci.contract_type,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       pci.middle_no contract_middle_no,
                       grd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_no,
                       pci.del_distribution_item_no,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       prrqs.assay_content,
                       0 ext_assay_content,
                       '' assay_finalized,
                       prrqs.due_date
                  from prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       grd_goods_record_detail   grd,
                       gmr_goods_movement_record gmr,
                       v_pci                     pci
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = prrqs.internal_grd_ref_no
                   and grd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id in
                       ('pledgeTransfer', 'financialSettlement')
                union
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       pci.contract_type,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       pci.middle_no contract_middle_no,
                       dgrd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_no,
                       pci.del_distribution_item_no,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       dgrd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       prrqs.assay_content,
                       0 ext_assay_content,
                       '' assay_finalized,
                       prrqs.due_date
                  from prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       dgrd_delivered_grd        dgrd,
                       gmr_goods_movement_record gmr,
                       v_pci                     pci
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
                   and dgrd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       dgrd.internal_contract_item_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'financialSettlement'
                union
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       '' contract_type,
                       '' internal_contract_ref_no,
                       '' contract_ref_no,
                       0 contract_middle_no,
                       '' internal_contract_item_ref_no,
                       '' contract_item_ref_no,
                       '' pcdi_id,
                       '' delivery_item_no,
                       0 del_distribution_item_no,
                       '' delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       '' stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       '' gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       prrqs.assay_content,
                       0 ext_assay_content,
                       '' assay_finalized,
                       prrqs.due_date
                  from prrqs_prr_qty_status prrqs,
                       axs_action_summary   axs,
                       pdm_productmaster    pdm
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'metalBalanceTransfer') retn_temp
        union
        select prrqs.prrqs_id unique_id,
               prrqs.corporate_id,
               '' contract_type,
               '' internal_contract_ref_no,
               '' contract_ref_no,
               0 contract_middle_no,
               '' internal_contract_item_ref_no,
               '' contract_item_ref_no,
               '' pcdi_id,
               '' delivery_item_no,
               0 del_distribution_item_no,
               '' delivery_item_ref_no,
               dgrd.internal_dgrd_ref_no stock_id,
               dgrd.internal_stock_ref_no stock_ref_no,
               prrqs.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               prrqs.activity_action_id,
               prrqs.cp_id supplier_id,
               prrqs.to_cp_id debt_supplier_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               (prrqs.qty_sign * prrqs.qty) debt_qty,
               (prrqs.qty_sign * prrqs.ext_qty) ext_debt_qty,
               prrqs.qty_unit_id debt_qty_unit_id,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               prrqs.assay_content,
               0 ext_assay_content,
               '' assay_finalized,
               prrqs.due_date
          from prrqs_prr_qty_status      prrqs,
               axs_action_summary        axs,
               pdm_productmaster         pdm,
               dgrd_delivered_grd        dgrd,
               gmr_goods_movement_record gmr
         where prrqs.internal_action_ref_no = axs.internal_action_ref_no
           and prrqs.cp_type = 'Supplier'
           and prrqs.is_active = 'Y'
           and prrqs.qty_type = 'Returned'
           and pdm.product_id = prrqs.product_id
           and dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
           and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no) mat_temp,
       axm_action_master axm,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_debt,
       qum_quantity_unit_master qum
 where axm.action_id = mat_temp.activity_action_id
   and phd.profileid = mat_temp.supplier_id
   and phd_debt.profileid(+) = mat_temp.debt_supplier_id
   and qum.qty_unit_id = mat_temp.debt_qty_unit_id
 order by mat_temp.activity_date desc;
/

 CREATE OR REPLACE FUNCTION "GETRETURNABLECONTENTDETAILS" (pContractNo number)
   RETURN VARCHAR2
IS
    
    cursor cr_pc_quality          
    IS
    
    SELECT distinct qat.quality_name           
    FROM pcpch_pc_payble_content_header pcpch,
         pqd_payable_quality_details pqd,
         pcm_physical_contract_main pcm,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat      
    WHERE pcpch.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pqd.pcpch_id = pcpch.pcpch_id
     AND pcpq.pcpq_id = pqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND pqd.is_active = 'Y'
     AND pcpch.is_active = 'Y'
     AND pcpch.payable_type = 'Returnable'
     AND pcm.internal_contract_ref_no = pContractNo;

    cursor cr_pc          
    IS

    SELECT  qat.quality_name ,
          (aml.attribute_name || ' :' || 
         (CASE
             WHEN pcepc.range_min_op IS NULL
                THEN    ' '
                     || pcepc.range_max_op
                     || ' '
                     || pcepc.range_max_value
                     || ' '
                     || rm.ratio_name
             WHEN pcepc.range_max_op IS NULL
                THEN    ' '
                     || pcepc.range_min_op
                     || ' '
                     || pcepc.range_min_value
                     || ' '
                     || rm.ratio_name
             ELSE    pcepc.range_min_op
                  || ' '
                  || pcepc.range_min_value
                  || ' to '
                  || pcepc.range_max_op
                  || ' '
                  || pcepc.range_max_value
                  || ' '
                  || rm.ratio_name
          END
         ) ||' ,Formula : '||   
         (   ppf.external_formula
          || ' where payable content = '
          || pcepc.payable_content_value
          || ' % and assay deduction = '
          || pcepc.assay_deduction
          || ' '
          || rm.ratio_name
         ) ||' '||   
         (CASE
             WHEN pcepc.include_ref_charges = 'Y'
                THEN  ',Refining Charges : ' ||  f_format_to_char(pcepc.refining_charge_value,4) || ' ' || pum.price_unit_name
          END
         )|| ', '
          || pcpch.due_date_days
          || ' days from '
          || pcpch.due_date_activity) AS payable_content
    FROM pcpch_pc_payble_content_header pcpch,
         pqd_payable_quality_details pqd,
         pcepc_pc_elem_payable_content pcepc,
         pcm_physical_contract_main pcm,
         ppu_product_price_units ppu,
         pum_price_unit_master pum,
         aml_attribute_master_list aml,
         pcpq_pc_product_quality pcpq,
         qat_quality_attributes qat,
         ppf_phy_payable_formula ppf,
         rm_ratio_master rm
   WHERE pcpch.pcpch_id = pcepc.pcpch_id
     AND pcpch.internal_contract_ref_no = pcm.internal_contract_ref_no
     AND pqd.pcpch_id = pcpch.pcpch_id
     AND pcpq.pcpq_id = pqd.pcpq_id
     AND pcpq.quality_template_id = qat.quality_id
     AND pcpch.element_id = aml.attribute_id
     AND pcepc.refining_charge_unit_id = ppu.internal_price_unit_id(+)
     AND ppu.price_unit_id = pum.price_unit_id(+)
     AND rm.ratio_id = pcpch.range_unit_id
     AND ppf.ppf_id = pcepc.payable_formula_id
     AND pcepc.is_active = 'Y'
     AND pcpch.is_active = 'Y'
     AND pqd.is_active = 'Y'
     AND pcpch.payable_type = 'Returnable'
     AND pcm.internal_contract_ref_no = pContractNo;
 
   PC_DETAILS   VARCHAR2(4000) :='';     
    begin
            for pc_quality_rec in cr_pc_quality
            loop
                
                 PC_DETAILS:= PC_DETAILS ||''|| pc_quality_rec.quality_name ||chr(10);    
            
                 for pc_rec in cr_pc
                 loop
                    
                    if (pc_quality_rec.quality_name = pc_rec.quality_name) then 
                        PC_DETAILS:= PC_DETAILS ||''|| pc_rec.payable_content ||' '|| chr(10);
                    end if;
                    
                 end loop;
            
            end loop;
           
            return  PC_DETAILS;
    end;
/
create or replace function f_get_returnable_due_date(pc_activity_action_id varchar2,
                                                     pc_stock_id           varchar2,
                                                     pc_element_id         varchar2)
  return date is
  returnable_due_date   date;
  v_activity_date       date;
  v_due_date_days       number(25, 10);
  v_due_date_activity   varchar2(20);
  v_internal_gmr_ref_no varchar2(15);
begin
  --dbms_output.put_line('hello');
  begin
    --To get Event Details & Internal_GMR_Ref_No of Passed Stock & Element
    select pcpch.due_date_days,
           pcpch.due_date_activity,
           grd.internal_gmr_ref_no
      into v_due_date_days,
           v_due_date_activity,
           v_internal_gmr_ref_no
      from grd_goods_record_detail        grd,
           pci_physical_contract_item     pci,
           pcdi_pc_delivery_item          pcdi,
           dipch_di_payablecontent_header dipch,
           pcpch_pc_payble_content_header pcpch
     where grd.internal_contract_item_ref_no =
           pci.internal_contract_item_ref_no
       and pci.pcdi_id = pcdi.pcdi_id
       and pcdi.pcdi_id = dipch.pcdi_id
       and pcpch.pcpch_id = dipch.pcpch_id
       and pcpch.payable_type = 'Returnable'
       and dipch.is_active = 'Y'
       and pcpch.is_active = 'Y'
       and pcpch.element_id = pc_element_id
       and grd.internal_grd_ref_no = pc_stock_id;
  
    if v_due_date_activity = 'Shipment' then
      select axs.eff_date
        into v_activity_date
        from agmr_action_gmr        agmr,
             gam_gmr_action_mapping gam,
             axs_action_summary     axs
       where gam.internal_gmr_ref_no = agmr.internal_gmr_ref_no
         and gam.action_no = agmr.action_no
         and axs.internal_action_ref_no = gam.internal_action_ref_no
         and axs.action_id = agmr.gmr_latest_action_action_id
         and axs.status = 'Active'
         and agmr.gmr_latest_action_action_id in
             ('shipmentDetail', 'railDetail', 'truckDetail', 'airDetail',
              'warehouseReceipt')
         and agmr.internal_gmr_ref_no = v_internal_gmr_ref_no;
    end if;
  
    if v_due_date_activity = 'Landing' then
      select axs.eff_date
        into v_activity_date
        from agmr_action_gmr        agmr,
             gam_gmr_action_mapping gam,
             axs_action_summary     axs
       where gam.internal_gmr_ref_no = agmr.internal_gmr_ref_no
         and gam.action_no = agmr.action_no
         and axs.internal_action_ref_no = gam.internal_action_ref_no
         and axs.action_id = agmr.gmr_latest_action_action_id
         and axs.status = 'Active'
         and agmr.gmr_latest_action_action_id in
             ('landingDetail', 'warehouseReceipt')
         and agmr.internal_gmr_ref_no = v_internal_gmr_ref_no;
    end if;
  
    if v_due_date_activity = 'Sampling' then
      select axs.eff_date
        into v_activity_date
        from ash_assay_header   ash,
             axs_action_summary axs
       where axs.internal_action_ref_no = ash.internal_action_ref_no
         and ash.assay_type = 'Weighing and Sampling Assay'
         and ash.is_active = 'Y'
         and nvl(ash.is_delete, 'N') = 'N'
         and axs.action_id = 'CREATE_WNS_ASSAY'
         and axs.status = 'Active'
         and ash.internal_gmr_ref_no = v_internal_gmr_ref_no
         and ash.internal_grd_ref_no = pc_stock_id;
    end if;
  
    /*if v_due_date_activity = 'Assay Finalization' then
    
    end if;*/
  
    returnable_due_date := v_activity_date + nvl(v_due_date_days, 0);
  
    --print msg start
    /*dbms_output.put_line(v_due_date_days);
    dbms_output.put_line(v_due_date_activity);
    dbms_output.put_line(v_internal_gmr_ref_no);
    dbms_output.put_line(v_activity_date);
    dbms_output.put_line(returnable_due_date);*/
    --print msg end
  
  exception
    when others then
      returnable_due_date := null;
  end;
  return returnable_due_date;
end f_get_returnable_due_date;
/
CREATE OR REPLACE VIEW V_BI_RECENT_TRADES_BY_PRODUCT 
AS
SELECT t2.corporate_id,
	 t2.product_id,
	 t2.product_name,
	 t2.contract_ref_no,
	 t2.trade_type,
	 to_date(t2.issue_date, 'dd-Mon-RRRR') issue_date,
	 t2.item_qty position_quantity,
	 t2.base_quantity_unit qty_unit_id,
	 t2.qty_unit base_qty_unit
FROM   (SELECT t1.contract_ref_no,
		   t1.corporate_id,
		   t1.created_date,
		   t1.product_id,
		   t1.product_name,
		   t1.trade_type,
		   t1.base_quantity_unit,
		   t1.item_qty,
		   t1.qty_unit,
		   t1.issue_date,
		   row_number() over(PARTITION BY t1.corporate_id, t1.product_id ORDER BY t1.created_date DESC) order_seq
	  --  row_number() over(partition by t1.corporate_id, t1.product_id order by t1.created_date desc) seq
	  FROM   (SELECT t.contract_ref_no,
			     t.corporate_id,
			     t.created_date,
			     t.issue_date,
			     (CASE
				     WHEN pcm.contract_type = 'BASEMETAL' AND pcm.purchase_sales = 'P' AND
					    pcm.is_tolling_contract = 'N' THEN
					'Physical Purchase'
				     WHEN pcm.contract_type = 'BASEMETAL' AND pcm.purchase_sales = 'S' AND
					    pcm.is_tolling_contract = 'N' THEN
					'Physical Sales'
				     WHEN pcm.contract_type = 'CONCENTRATES' AND pcm.purchase_sales = 'P' AND
					    pcm.is_tolling_contract = 'N' THEN
					'Physical Purchase'
				     WHEN pcm.contract_type = 'CONCENTRATES' AND pcm.purchase_sales = 'S' AND
					    pcm.is_tolling_contract = 'N' THEN
					'Physical Sales'
				     WHEN pcm.contract_type = 'CONCENTRATES' AND pcm.purchase_sales = 'P' AND
					    pcm.is_tolling_contract = 'Y' THEN
					'Sell Tolling'
				     WHEN pcm.contract_type = 'CONCENTRATES' AND pcm.purchase_sales = 'S' AND
					    pcm.is_tolling_contract = 'Y' THEN
					'Buy Tolling'
				     ELSE
					'NA'
			     END) trade_type,
			     pdm.product_id,
			     pdm.product_desc product_name,
			     pdm.base_quantity_unit,
			     (cqs.total_qty * ucm.multiplication_factor) item_qty,
			     qum.qty_unit
		    FROM   (SELECT substr(MAX(CASE
								WHEN pcmul.contract_ref_no IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || pcmul.contract_ref_no
							END)
						 ,24) contract_ref_no,
					 substr(MAX(CASE
								WHEN pcmul.corporate_id IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || pcmul.corporate_id
							END)
						 ,24) corporate_id,
					 substr(MAX(CASE
								WHEN pcmul.internal_contract_ref_no IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || pcmul.internal_contract_ref_no
							END)
						 ,24) internal_contract_ref_no,
					 substr(MAX(CASE
								WHEN pcmul.issue_date IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || pcmul.issue_date
							END)
						 ,24) issue_date,
					 MAX(CASE
						     WHEN axs.created_date IS NOT NULL THEN
							axs.created_date
					     END) created_date
				FROM   pcmul_phy_contract_main_ul pcmul,
					 axs_action_summary         axs
				WHERE  pcmul.internal_action_ref_no = axs.internal_action_ref_no
				GROUP  BY pcmul.internal_contract_ref_no) t,
			     pdm_productmaster pdm,
			     pcm_physical_contract_main pcm,
			     pci_physical_contract_item pci,
			     pcdi_pc_delivery_item pcdi,
			     pcpd_pc_product_definition pcpd,
			     pcpq_pc_product_quality pcpq,
			     cqs_contract_qty_status cqs,
			     ucm_unit_conversion_master ucm,
			     qum_quantity_unit_master qum
		    WHERE  pcdi.internal_contract_ref_no = t.internal_contract_ref_no
		    AND    pci.pcdi_id = pcdi.pcdi_id
		    AND    pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
		    AND    pci.pcpq_id = pcpq.pcpq_id
		    AND    pcpq.pcpq_id = pci.pcpq_id
		    AND    pcpd.pcpd_id = pcpq.pcpd_id
		    AND    pcm.internal_contract_ref_no = cqs.internal_contract_ref_no
		    AND    pdm.product_id = pcpd.product_id
		    AND    pcpd.product_id = pdm.product_id
		    AND    cqs.item_qty_unit_id = ucm.from_qty_unit_id
		    AND    pdm.base_quantity_unit = ucm.to_qty_unit_id
		    --AND    pcm.contract_type = 'BASEMETAL' --Bug 63238 fix-11-May-2012 commented
		    AND    pcm.contract_status IN ('In Position', 'Pending Approval')
		    AND    pci.is_active = 'Y'
		    AND    pdm.base_quantity_unit = qum.qty_unit_id
		    AND    pdm.is_deleted = 'N'
		    GROUP  BY t.contract_ref_no,
				  t.corporate_id,
				  t.created_date,
				  pdm.product_id,
				  t.issue_date,
				  pdm.product_desc,
				  cqs.total_qty,
				  ucm.multiplication_factor,
				  pcm.contract_type,
				  pcm.is_tolling_contract,
				  pdm.base_quantity_unit,
				  pcm.purchase_sales,
				  qum.qty_unit
		    --Bug 63238 fix start
		    --order by t.created_date desc
		    UNION ALL
		    SELECT tab.contract_ref_no || '-' || pci.del_distribution_item_no contract_ref_no,
			     tab.corporate_id,
			     tab.created_date,
			     tab.issue_date,
			     (CASE
				     WHEN pcm.contract_type = 'BASEMETAL' AND pcm.purchase_sales = 'P' AND
					    pcm.is_tolling_contract = 'N' THEN
					'Physical Purchase'
				     WHEN pcm.contract_type = 'BASEMETAL' AND pcm.purchase_sales = 'S' AND
					    pcm.is_tolling_contract = 'N' THEN
					'Physical Sales'
				     WHEN pcm.contract_type = 'CONCENTRATES' AND pcm.purchase_sales = 'P' AND
					    pcm.is_tolling_contract = 'N' THEN
					'Physical Purchase'
				     WHEN pcm.contract_type = 'CONCENTRATES' AND pcm.purchase_sales = 'S' AND
					    pcm.is_tolling_contract = 'N' THEN
					'Physical Sales'
				     WHEN pcm.contract_type = 'CONCENTRATES' AND pcm.purchase_sales = 'P' AND
					    pcm.is_tolling_contract = 'Y' THEN
					'Sell Tolling'
				     WHEN pcm.contract_type = 'CONCENTRATES' AND pcm.purchase_sales = 'S' AND
					    pcm.is_tolling_contract = 'Y' THEN
					'Buy Tolling'
				     ELSE
					'NA'
			     END) trade_type,
			     pdm.product_id,
			     pdm.product_desc product_name,
			     pdm.base_quantity_unit,
			     (pcieq.payable_qty * ucm.multiplication_factor) item_qty,
			     qum.qty_unit
		    FROM   v_pci_element_qty pcieq,
			     pci_physical_contract_item pci,
			     pcdi_pc_delivery_item pcdi,
			     pcm_physical_contract_main pcm,
			     aml_attribute_master_list aml,
			     ucm_unit_conversion_master ucm,
			     pdm_productmaster pdm,
			     qum_quantity_unit_master qum,
			     (SELECT substr(MAX(CASE
								WHEN pcmul.contract_ref_no IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || pcmul.contract_ref_no
							END)
						 ,24) contract_ref_no,
					 substr(MAX(CASE
								WHEN pcmul.corporate_id IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || pcmul.corporate_id
							END)
						 ,24) corporate_id,
					 substr(MAX(CASE
								WHEN pcmul.internal_contract_ref_no IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || pcmul.internal_contract_ref_no
							END)
						 ,24) internal_contract_ref_no,
					 substr(MAX(CASE
								WHEN pcmul.issue_date IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || pcmul.issue_date
							END)
						 ,24) issue_date,
					 MAX(CASE
						     WHEN axs.created_date IS NOT NULL THEN
							axs.created_date
					     END) created_date
				FROM   pcmul_phy_contract_main_ul pcmul,
					 axs_action_summary         axs
				WHERE  pcmul.internal_action_ref_no = axs.internal_action_ref_no
				GROUP  BY pcmul.internal_contract_ref_no) tab
		    WHERE  pcieq.internal_contract_item_ref_no = pci.internal_contract_item_ref_no
		    AND    tab.contract_ref_no = pcm.contract_ref_no
		    AND    pcdi.pcdi_id = pci.pcdi_id
		    AND    pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
		    AND    aml.attribute_id = pcieq.element_id
		    AND    aml.underlying_product_id = pdm.product_id
		    AND    pdm.base_quantity_unit = qum.qty_unit_id
		    AND    pcieq.qty_unit_id = ucm.from_qty_unit_id
		    AND    pdm.base_quantity_unit = ucm.to_qty_unit_id
		    AND    pcm.contract_type = 'CONCENTRATES'
		    AND    pcm.contract_status IN ('In Position', 'Pending Approval')
		    AND    pci.is_active = 'Y'
		    AND    pdm.is_deleted = 'N'
		    AND    (pcieq.payable_qty * ucm.multiplication_factor) <> 0
		    --Bug 63238 fix end
		    --derivatives start
                --Bug 63342 fix start
		    UNION ALL
		    SELECT dt.derivative_ref_no contract_ref_no,
			     dt.corporate_id,
			     tab.created_date,
			     tab.trade_date issue_date,
			     decode(dt.trade_type, 'Buy', 'Derivative Buy', 'Sell', 'Derivative Sell', NULL) trade_type,
			     pdm.product_id,
			     pdm.product_desc product_name,
			     pdm.base_quantity_unit,
			     round(dt.open_quantity * ucm.multiplication_factor, 5) item_qty,
			     qum.qty_unit
		    FROM   dt_derivative_trade dt,
			     drm_derivative_master drm,
			     dim_der_instrument_master dim,
			     irm_instrument_type_master irm,
			     pdd_product_derivative_def pdd,
			     pdm_productmaster pdm,
			     qum_quantity_unit_master qum,
			     ucm_unit_conversion_master ucm,
			     (SELECT substr(MAX(CASE
								WHEN dtul.derivative_ref_no IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || dtul.derivative_ref_no
							END)
						 ,24) derivative_ref_no,
					 substr(MAX(CASE
								WHEN dtul.corporate_id IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || dtul.corporate_id
							END)
						 ,24) corporate_id,
					 substr(MAX(CASE
								WHEN dtul.internal_derivative_ref_no IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || dtul.internal_derivative_ref_no
							END)
						 ,24) internal_derivative_ref_no,
					 substr(MAX(CASE
								WHEN dtul.trade_date IS NOT NULL THEN
								 to_char(axs.created_date, 'yyyymmddhh24missff9') || dtul.trade_date
							END)
						 ,24) trade_date,
					 MAX(CASE
						     WHEN axs.created_date IS NOT NULL THEN
							axs.created_date
					     END) created_date
				FROM   dtul_derivative_trade_ul dtul,
					 axs_action_summary       axs
				WHERE  dtul.internal_action_ref_no = axs.internal_action_ref_no
				GROUP  BY dtul.internal_derivative_ref_no) tab
		    WHERE  dt.dr_id = drm.dr_id
		    AND    tab.internal_derivative_ref_no = dt.internal_derivative_ref_no
		    AND    drm.instrument_id = dim.instrument_id
		    AND    dim.instrument_type_id = irm.instrument_type_id
		    AND    dim.product_derivative_id = pdd.derivative_def_id
		    AND    pdd.product_id = pdm.product_id
		    AND    dt.status = 'Verified'
		    AND    dt.quantity_unit_id = ucm.from_qty_unit_id
		    AND    pdm.base_quantity_unit = ucm.to_qty_unit_id
		    AND    pdm.base_quantity_unit = qum.qty_unit_id
		    AND    dt.open_quantity <> 0	    
		    --Bug 63342 fix end		    
		    ) t1
	  ORDER  BY t1.product_id,
			t1.created_date) t2
WHERE  t2.order_seq < 6
ORDER  BY t2.corporate_id,
	    t2.product_id;

/
ALTER TABLE GRD_GOODS_RECORD_DETAIL
 ADD (PQPA_PHY_ATTRIBUTE_GROUP_NO  VARCHAR2(15));
 
ALTER TABLE AGRD_ACTION_GRD
 ADD (PQPA_PHY_ATTRIBUTE_GROUP_NO  VARCHAR2(15));
 
ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL
 ADD (PQPA_PHY_ATTRIBUTE_GROUP_NO  VARCHAR2(15));
/
create or replace package "PKG_REPORT_GENERAL" is
  -- All general packages and procedures
  function fn_get_item_dry_qty(pc_internal_cont_item_ref_no varchar2,
                               pn_item_qty                  number)
    return number;
  procedure sp_element_position_qty(pc_internal_contract_ref_no varchar2,
                                    pn_qty                      number,
                                    pc_qty_unit_id              varchar2,
                                    pc_assay_header_id          varchar2,
                                    pc_element_id               varchar2,
                                    pc_ele_qty_string           out varchar2);
  function fn_get_element_qty(pc_internal_contract_ref_no varchar2,
                              pn_qty                      number,
                              pc_qty_unit_id              varchar2,
                              pc_assay_header_id          varchar2,
                              pc_element_id               varchar2)
    return number;
  function fn_get_element_assay_qty(pc_element_id      varchar2,
                                    pc_assay_header_id varchar2,
                                    pc_wet_dry_type    varchar2,
                                    pn_qty             number,
                                    pc_qty_unit_id     varchar2)
    return number;
  function fn_get_element_qty_unit_id(pc_internal_contract_ref_no varchar2,
                                      pc_item_qty_unit_id         varchar2,
                                      pc_assay_header_id          varchar2,
                                      pc_element_id               varchar2)
    return varchar2;
  function fn_get_element_pricing_month(pc_pcbpd_id   in varchar2,
                                        pc_element_id varchar2)
    return varchar2;
  function fn_get_assay_dry_qty(pc_product_id      varchar2,
                                pc_assay_header_id varchar2,
                                pn_qty             number,
                                pc_qty_unit_id     varchar2) return number;
  function fn_deduct_wet_to_dry_qty(pc_product_id                varchar2,
                                    pc_internal_cont_item_ref_no varchar2,
                                    pn_item_qty                  number)
    return number;
  function fn_get_elmt_assay_content_qty(pc_element_id      varchar2,
                                         pc_assay_header_id varchar2,
                                         pn_qty             number,
                                         pc_qty_unit_id     varchar2)
    return number;

end; 
/
create or replace package body "PKG_REPORT_GENERAL" is
  function fn_get_item_dry_qty(pc_internal_cont_item_ref_no varchar2,
                               pn_item_qty                  number)
    return number is
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_item_qty         := pn_item_qty;
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select aml.attribute_id,
                                  rm.ratio_name,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  pqca.typical,
                                  ppm.product_id,
                                  pci.item_qty_unit_id
                             from ppm_product_properties_mapping ppm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  asm_assay_sublot_mapping       asm,
                                  ash_assay_header               ash,
                                  pcdi_pc_delivery_item          pcdi,
                                  pci_physical_contract_item     pci,
                                  pcpq_pc_product_quality        pcpq,
                                  pcpd_pc_product_definition     pcpd
                            where ppm.attribute_id = aml.attribute_id
                              and aml.attribute_id = pqca.element_id
                              and pqca.asm_id = asm.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and asm.ash_id = ash.ash_id
                              and ash.internal_contract_ref_no =
                                  pcdi.internal_contract_ref_no
                              and pcdi.pcdi_id = pci.pcdi_id
                              and pci.pcpq_id = pcpq.pcpq_id
                              and pcpq.pcpd_id = pcpd.pcpd_id
                              and ppm.product_id = pcpd.product_id
                              and pci.internal_contract_item_ref_no =
                                  pc_internal_cont_item_ref_no
                              and pcpq.assay_header_id = ash.ash_id
                              and ppm.deduct_for_wet_to_dry = 'Y')
    loop
    
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 vn_converted_qty);
      
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    
    end loop;
    return vn_deduct_total_qty;
  end;
  --
  procedure sp_element_position_qty(pc_internal_contract_ref_no varchar2,
                                    pn_qty                      number,
                                    pc_qty_unit_id              varchar2,
                                    pc_assay_header_id          varchar2,
                                    pc_element_id               varchar2,
                                    pc_ele_qty_string           out varchar2) is
  
    cursor cur_element is
      select pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpq.unit_of_measure item_unit_of_measure,
             pqca.element_id,
             pcpq.assay_header_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from pci_physical_contract_item  pci,
             pcpq_pc_product_quality     pcpq,
             ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
      
       where pci.pcpq_id = pcpq.pcpq_id
         and pcpq.assay_header_id = ash.ash_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pci.internal_contract_item_ref_no =
             pc_internal_contract_ref_no
         and pcpq.assay_header_id = pc_assay_header_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
  
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.item_unit_of_measure = 'Wet' then
        vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
                                             cur_element_rows.item_qty);
        vn_item_qty   := cur_element_rows.item_qty - vn_deduct_qty;
      else
        vn_item_qty := cur_element_rows.item_qty;
      end if;
    
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.item_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.item_qty_unit_id;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 cur_element_rows.item_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
      
        vn_element_qty := vn_converted_qty * cur_element_rows.typical;
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
      
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      end if;
    end loop;
  end;
  function fn_get_element_qty(pc_internal_contract_ref_no varchar2,
                              pn_qty                      number,
                              pc_qty_unit_id              varchar2,
                              pc_assay_header_id          varchar2,
                              pc_element_id               varchar2)
    return number is
    cursor cur_element is
      select pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpq.unit_of_measure item_unit_of_measure,
             pqca.element_id,
             pcpq.assay_header_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from pci_physical_contract_item  pci,
             pcpq_pc_product_quality     pcpq,
             ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where pci.pcpq_id = pcpq.pcpq_id
         and pcpq.assay_header_id = ash.ash_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pci.internal_contract_item_ref_no =
             pc_internal_contract_ref_no
         and pcpq.assay_header_id = pc_assay_header_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    pc_ele_qty_string      varchar2(100);
    vn_ele_qty             number;
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.item_unit_of_measure = 'Wet' then
        vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
                                             pn_qty);
        vn_item_qty   := pn_qty - vn_deduct_qty;
      else
        vn_item_qty := pn_qty;
      end if;
    
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.item_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
      
        vn_element_qty := vn_converted_qty * cur_element_rows.typical;
      
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
      
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      
        pc_ele_qty_string := vn_element_qty || '&' || vc_element_qty_unit || '&' ||
                             vc_element_qty_unit_id;
      
      end if;
      vn_ele_qty := vn_element_qty;
    end loop;
    return(vn_ele_qty);
  end;
  function fn_get_element_assay_qty(pc_element_id      varchar2,
                                    pc_assay_header_id varchar2,
                                    pc_wet_dry_type    varchar2,
                                    pn_qty             number,
                                    pc_qty_unit_id     varchar2)
    return number is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id;
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    --pc_ele_qty_string      varchar2(100);
    vn_ele_qty number;
  begin
    for cur_element_rows in cur_element
    loop
      vn_deduct_qty := 0;
      if pc_wet_dry_type = 'Wet' then
        /*vn_deduct_qty := fn_get_item_dry_qty(cur_element_rows.internal_contract_item_ref_no,
        pn_qty);*/
        vn_item_qty := pn_qty - vn_deduct_qty;
      else
        vn_item_qty := pn_qty;
      end if;
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = pc_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
        vn_element_qty   := vn_converted_qty * cur_element_rows.typical;
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;
      vn_ele_qty := vn_element_qty;
    end loop;
    return(vn_ele_qty);
  end;
  function fn_get_element_qty_unit_id(pc_internal_contract_ref_no varchar2,
                                      pc_item_qty_unit_id         varchar2,
                                      pc_assay_header_id          varchar2,
                                      pc_element_id               varchar2)
    return varchar2 is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id;
  
    vc_element_qty_unit_id varchar2(15);
  begin
    for cur_element_rows in cur_element
    loop
      if cur_element_rows.ratio_name = '%' then
        vc_element_qty_unit_id := pc_item_qty_unit_id;
      else
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;
    end loop;
    return(vc_element_qty_unit_id);
  end;
  function fn_get_element_pricing_month(pc_pcbpd_id   in varchar2,
                                        pc_element_id varchar2)
    return varchar2 is
    cursor cur_qp_end_date is
      select pcm.contract_ref_no,
             pcdi.pcdi_id,
             pcbpd.pcbpd_id,
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
            --  and pcm.contract_type = 'BASEMETAL'
         and pcbpd.price_basis <> 'Fixed'
         and pci.item_qty > 0
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.is_active = 'Y'
         and poch.element_id = pc_element_id
            --and pci.internal_contract_item_ref_no = pc_Int_contract_Item_Ref_No Commented
         and pocd.pcbpd_id = pc_pcbpd_id; -- Newly Added
    --and pfqpp.is_active = 'Y'
    --and pofh.is_active(+) = 'Y';
  
    vd_qp_start_date date;
    vd_qp_end_date   date;
    vd_shipment_date date;
    vd_arrival_date  date;
    vd_evevnt_date   date;
  
  begin
  
    for cur_rows in cur_qp_end_date
    loop
      if cur_rows.price_basis in ('Index', 'Formula') then
      
        if cur_rows.basis_type = 'Shipment' then
          if cur_rows.delivery_period_type = 'Month' then
            vd_shipment_date := last_day('01-' ||
                                         cur_rows.delivery_to_month || '-' ||
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
          begin
            select dieqp.expected_qp_start_date,
                   dieqp.expected_qp_end_date
              into vd_qp_start_date,
                   vd_qp_end_date
              from di_del_item_exp_qp_details dieqp
             where dieqp.pcdi_id = cur_rows.pcdi_id
               and dieqp.pcbpd_id = cur_rows.pcbpd_id
               and dieqp.is_active = 'Y';
          exception
            when no_data_found then
              vd_qp_start_date := cur_rows.qp_start_date;
              vd_qp_end_date   := cur_rows.qp_end_date;
            when others then
              vd_qp_start_date := cur_rows.qp_end_date;
              vd_qp_end_date   := cur_rows.qp_end_date;
          end;
          /*if cur_rows.event_name = 'Month After Month Of Shipment' then
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
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := to_date('15-' ||
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
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
                                        to_char(vd_shipment_date,
                                                'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          elsif cur_rows.event_name = 'Second Half Of Arrival Month' then
            vd_qp_start_date := to_date('16-' ||
                                        to_char(vd_arrival_date, 'Mon-yyyy'),
                                        'dd-mon-yyyy');
            vd_qp_end_date   := last_day(vd_qp_start_date);
          end if;*/
        end if;
      
      end if;
    end loop;
  
    return to_char(last_day(vd_qp_end_date), 'dd-Mon-yyyy');
  end;
  function fn_get_assay_dry_qty(pc_product_id      varchar2,
                                pc_assay_header_id varchar2,
                                pn_qty             number,
                                pc_qty_unit_id     varchar2) return number is
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select ash.ash_id,
                                  (case
                                    when ash.ash_id =
                                         (select ash_new.pricing_assay_ash_id
                                            from ash_assay_header ash_new
                                           where ash_new.assay_type =
                                                 'Provisional Assay'
                                             and ash_new.is_active = 'Y'
                                             and ash_new.internal_grd_ref_no =
                                                 ash.internal_grd_ref_no) then
                                     pn_qty                                    
                                    when ash.ash_id =
                                         (select ash_new.ash_id
                                            from ash_assay_header ash_new
                                           where ash_new.assay_type =
                                                 'Shipment Assay'
                                             and ash_new.is_active = 'Y'
                                             and ash_new.internal_grd_ref_no =
                                                 ash.internal_grd_ref_no) then
                                     pn_qty
                                    else
                                     asm.net_weight
                                  end) net_weight,
                                  pqca.element_id,
                                  pqca.is_elem_for_pricing,
                                  pqca.unit_of_measure,
                                  pqca.payable_percentage,
                                  pqca.typical,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  rm.ratio_name,
                                  aml.attribute_name,
                                  aml.attribute_desc,
                                  ppm.product_id,
                                  aml.underlying_product_id
                             from ash_assay_header               ash,
                                  asm_assay_sublot_mapping       asm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  ppm_product_properties_mapping ppm
                            where ash.ash_id = pc_assay_header_id
                              and ash.ash_id = asm.ash_id
                              and asm.asm_id = pqca.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and pqca.element_id = aml.attribute_id
                              and ppm.attribute_id = aml.attribute_id
                              and ppm.product_id = pc_product_id
                              and nvl(ppm.deduct_for_wet_to_dry, 'N') = 'Y')
    loop
      vn_item_qty := nvl(cur_deduct_qty.net_weight, pn_qty);
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(pc_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(pc_product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 pc_qty_unit_id,
                                                                 vn_converted_qty);
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    end loop;
    return(pn_qty - vn_deduct_total_qty);
  end;

  function fn_deduct_wet_to_dry_qty(pc_product_id                varchar2,
                                    pc_internal_cont_item_ref_no varchar2,
                                    pn_item_qty                  number)
    return number is
  
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_item_qty         := pn_item_qty;
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (select rm.ratio_name,
                                  rm.qty_unit_id_numerator,
                                  rm.qty_unit_id_denominator,
                                  pqca.typical,
                                  ppm.product_id,
                                  pci.item_qty_unit_id
                             from ppm_product_properties_mapping ppm,
                                  aml_attribute_master_list      aml,
                                  pqca_pq_chemical_attributes    pqca,
                                  rm_ratio_master                rm,
                                  asm_assay_sublot_mapping       asm,
                                  ash_assay_header               ash,
                                  pcdi_pc_delivery_item          pcdi,
                                  pci_physical_contract_item     pci,
                                  pcpq_pc_product_quality        pcpq
                            where ppm.attribute_id = aml.attribute_id
                              and aml.attribute_id = pqca.element_id
                              and pqca.asm_id = asm.asm_id
                              and pqca.unit_of_measure = rm.ratio_id
                              and asm.ash_id = ash.ash_id
                              and ash.internal_contract_ref_no =
                                  pcdi.internal_contract_ref_no
                              and pcdi.pcdi_id = pci.pcdi_id
                              and pci.pcpq_id = pcpq.pcpq_id
                              and pci.internal_contract_item_ref_no =
                                  pc_internal_cont_item_ref_no
                              and ppm.product_id = pc_product_id
                              and pcpq.assay_header_id = ash.ash_id
                              and ppm.deduct_for_wet_to_dry = 'Y')
    loop
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 vn_converted_qty);
      
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    
    end loop;
    return vn_deduct_total_qty;
  end;
  function fn_get_elmt_assay_content_qty(pc_element_id      varchar2,
                                         pc_assay_header_id varchar2,
                                         pn_qty             number,
                                         pc_qty_unit_id     varchar2)
    return number is
    cursor cur_element is
      select pqca.element_id,
             pqca.is_elem_for_pricing,
             pqca.unit_of_measure,
             pqca.payable_percentage,
             pqca.typical,
             rm.qty_unit_id_numerator,
             rm.qty_unit_id_denominator,
             rm.ratio_name,
             ash.ash_id,
             aml.attribute_name,
             aml.attribute_desc,
             aml.underlying_product_id,
             asm.asm_id,
             asm.dry_weight,
             pcpd.product_id,
             pcpq.unit_of_measure contract_unit_of_measure
        from ash_assay_header            ash,
             asm_assay_sublot_mapping    asm,
             aml_attribute_master_list   aml,
             pqca_pq_chemical_attributes pqca,
             rm_ratio_master             rm,
             pcpd_pc_product_definition  pcpd,
             pcpq_pc_product_quality     pcpq
       where ash.ash_id = pc_assay_header_id
         and ash.ash_id = asm.ash_id
         and asm.asm_id = pqca.asm_id
         and pqca.unit_of_measure = rm.ratio_id
         and pqca.element_id = aml.attribute_id
         and pqca.element_id = pc_element_id
         and ash.internal_contract_ref_no=pcpd.internal_contract_ref_no
         and pcpd.pcpd_id = pcpq.pcpd_id
         and pcpd.input_output = 'Input'
         and ash.is_active = 'Y'
         and asm.is_active = 'Y'
         and pqca.is_active = 'Y'
         and aml.is_active = 'Y'
         and rm.is_active = 'Y'
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y';
  
    vn_element_qty         number;
    vn_converted_qty       number;
    vc_element_qty_unit    varchar2(15);
    vc_element_qty_unit_id varchar2(15);
    vn_deduct_qty          number;
    vn_item_qty            number;
    vn_ele_assay_value number :=0;   
  begin
    for cur_element_rows in cur_element
    loop
      vn_deduct_qty := 0;      
      vn_item_qty := nvl(cur_element_rows.dry_weight,pn_qty);
      if cur_element_rows.ratio_name = '%' then
        vn_element_qty := vn_item_qty * (cur_element_rows.typical / 100);
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = pc_qty_unit_id;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := pc_qty_unit_id;
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_element_rows.underlying_product_id,
                                                                 pc_qty_unit_id,
                                                                 cur_element_rows.qty_unit_id_denominator,
                                                                 vn_item_qty);
        vn_element_qty   := vn_converted_qty * cur_element_rows.typical;
        begin
          select qum.qty_unit
            into vc_element_qty_unit
            from qum_quantity_unit_master qum
           where qum.qty_unit_id = cur_element_rows.qty_unit_id_numerator;
        exception
          when no_data_found then
            vc_element_qty_unit := null;
        end;
        vc_element_qty_unit_id := cur_element_rows.qty_unit_id_numerator;
      end if;     
      vn_ele_assay_value :=vn_ele_assay_value+vn_element_qty;     
    end loop;
    return(vn_ele_assay_value);
  end;
end; 
/
create or replace view v_bi_tc_rc_distribution_report as
select supplier.supplier_invoive_no,
       supplier.supplier_invoice_date,
       supplier.supplier_contract_ref_no,
       supplier.supplier_gmr_ref_no,
       supplier.supplier,
       supplier.charges_to_supplier,
       supplier.add_charges_to_supplier,
       supplier.invoice_currency_id,
       supplier.invoice_currency_code,
       smelter.smelter_invoive_no,
       smelter.smelter_invoice_date,
       smelter.smelter_gmr_ref_no,
       smelter.smelter_contract_ref_no,
       smelter.smelter,
       smelter.charges_to_smelter
  from (select test.supplier_gmr_ref_no,
               test.supplier_internal_gmr_ref_no,
               test.supplier_invoive_no,
               test.supplier_invoice_date,
               test.supplier_contract_ref_no,
               test.supplier,
               sum(test.tc_amount + test.rc_amount + test.penality_amount) charges_to_supplier,
               test.invoice_currency_id,
               test.invoice_currency_code,
               nvl(iss.total_other_charge_amount,0) add_charges_to_supplier
          from (select pcm.contract_ref_no supplier_contract_ref_no,
                       gmr.gmr_ref_no supplier_gmr_ref_no,
                       gmr.internal_gmr_ref_no supplier_internal_gmr_ref_no,
                       grd.internal_grd_ref_no,
                       phd.companyname supplier,
                       nvl(intc.tc_amount, 0) tc_amount,
                       nvl(inrc.rc_amount, 0) rc_amount,
                       nvl(iepd.penality_amount, 0) penality_amount,
                       iss.invoice_ref_no supplier_invoive_no,
                       iss.invoice_issue_date supplier_invoice_date,
                       iid.invoice_currency_id,
                       cm.cur_code invoice_currency_code,
                       iss.internal_invoice_ref_no
                  from pcm_physical_contract_main pcm,
                       phd_profileheaderdetails phd,
                       gmr_goods_movement_record gmr,
                       grd_goods_record_detail grd,
                       iid_invoicable_item_details iid,
                       is_invoice_summary iss,
                       (select intc.grd_id,
                               intc.internal_invoice_ref_no,
                               sum(intc.tcharges_amount) tc_amount
                          from intc_inv_treatment_charges intc
                         group by intc.grd_id,
                                  intc.internal_invoice_ref_no) intc,
                       (select inrc.grd_id,
                               inrc.internal_invoice_ref_no,
                               sum(inrc.rcharges_amount) rc_amount
                          from inrc_inv_refining_charges inrc
                         group by inrc.grd_id,
                                  inrc.internal_invoice_ref_no) inrc,
                       (select iepd.stock_id,
                               iepd.internal_invoice_ref_no,
                               sum(iepd.element_penalty_amount) penality_amount
                          from iepd_inv_epenalty_details iepd
                         group by iepd.stock_id,
                                  iepd.internal_invoice_ref_no) iepd,
                       v_bi_latest_gmr_invoice invoice,
                       ii_invoicable_item ii,
                       cm_currency_master cm
                 where pcm.internal_contract_ref_no =
                       gmr.internal_contract_ref_no
                   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = iid.stock_id
                   and iid.internal_invoice_ref_no =
                       iss.internal_invoice_ref_no
                   and iss.is_active = 'Y'
                   and pcm.is_active = 'Y'
                   and gmr.is_deleted = 'N'
                   and grd.is_deleted = 'N'
                   and iid.invoicable_item_id = ii.invoicable_item_id
                      --   and nvl(ii.is_pass_through,'N') = 'Y'
                   and pcm.is_tolling_contract = 'Y'
                   and pcm.purchase_sales = 'P'
                   and iid.stock_id = intc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       intc.internal_invoice_ref_no(+)
                   and iid.stock_id = inrc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       inrc.internal_invoice_ref_no(+)
                   and iid.stock_id = iepd.stock_id(+)
                   and iid.internal_invoice_ref_no =
                       iepd.internal_invoice_ref_no(+)
                   and iss.internal_invoice_ref_no =
                       invoice.internal_invoice_ref_no
                   and iid.invoice_currency_id = cm.cur_id
                   and pcm.cp_id = phd.profileid
                union all
                select pcm.contract_ref_no supplier_contract_ref_no,
                       gmr.gmr_ref_no supplier_gmr_ref_no,
                       gmr.internal_gmr_ref_no supplier_internal_gmr_ref_no,
                       grd.internal_grd_ref_no,
                       phd.companyname supplier,
                       0 tc_amount,
                       0 rc_amount,
                       0 penality_amount,
                       'NA' supplier_invoive_no,
                       null supplier_invoice_date,
                       iid.invoice_currency_id,
                       -- iid.*,
                       cm.cur_code invoice_currency_code,
                       null internal_invoice_ref_no
                  from pcm_physical_contract_main pcm,
                       phd_profileheaderdetails   phd,
                       gmr_goods_movement_record  gmr,
                       grd_goods_record_detail    grd,
                       ii_invoicable_item         iid,
                       cm_currency_master         cm
                 where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = iid.stock_id
                   and iid.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and iid.is_pass_through = 'Y'
                   and not exists
                 (select *
                          from iid_invoicable_item_details iid1
                         where iid1.invoicable_item_id =
                               iid.invoicable_item_id)
                   and pcm.is_active = 'Y'
                   and gmr.is_deleted = 'N'
                   and grd.is_deleted = 'N'
                   and pcm.is_tolling_contract = 'Y'
                   and pcm.purchase_sales = 'P'
                   and iid.invoice_currency_id = cm.cur_id(+)
                   and pcm.cp_id = phd.profileid
                ) test,
                is_invoice_summary iss
                where test.internal_invoice_ref_no=iss.internal_invoice_ref_no(+)
         group by test.supplier_invoive_no,
                  test.supplier_invoice_date,
                  test.supplier_contract_ref_no,
                  test.supplier,
                  test.invoice_currency_id,
                  test.invoice_currency_code,
                  test.supplier_gmr_ref_no,
                  test.supplier_internal_gmr_ref_no,
                  iss.total_other_charge_amount) supplier,
       (select test.smelter_gmr_ref_no,
               test.smelter_internal_gmr_ref_no,
               test.supp_internal_gmr_ref_no,
               test.smelter_invoive_no,
               test.smelter_invoice_date,
               test.smelter_contract_ref_no,
               test.smelter,
               sum(test.tc_amount + test.rc_amount + test.penality_amount) charges_to_smelter,
               test.invoice_currency_id,
               test.invoice_currency_code
          from (select pcm.contract_ref_no smelter_contract_ref_no,
                       gmr.internal_gmr_ref_no smelter_internal_gmr_ref_no,
                       gmr.gmr_ref_no smelter_gmr_ref_no,
                       grd.internal_grd_ref_no,
                       grd.supp_internal_gmr_ref_no,
                       phd.companyname smelter,
                       nvl(intc.tc_amount, 0) tc_amount,
                       nvl(inrc.rc_amount, 0) rc_amount,
                       nvl(iepd.penality_amount, 0) penality_amount,
                       iss.invoice_ref_no smelter_invoive_no,
                       iss.invoice_issue_date smelter_invoice_date,
                       iid.invoice_currency_id,
                       cm.cur_code invoice_currency_code,
                       iss.internal_invoice_ref_no
                  from pcm_physical_contract_main pcm,
                       phd_profileheaderdetails phd,
                       gmr_goods_movement_record gmr,
                       grd_goods_record_detail grd,
                       iid_invoicable_item_details iid,
                       is_invoice_summary iss,
                       (select intc.grd_id,
                               intc.internal_invoice_ref_no,
                               sum(intc.tcharges_amount) tc_amount
                          from intc_inv_treatment_charges intc
                         group by intc.grd_id,
                                  intc.internal_invoice_ref_no) intc,
                       (select inrc.grd_id,
                               inrc.internal_invoice_ref_no,
                               sum(inrc.rcharges_amount) rc_amount
                          from inrc_inv_refining_charges inrc
                         group by inrc.grd_id,
                                  inrc.internal_invoice_ref_no) inrc,
                       (select iepd.stock_id,
                               iepd.internal_invoice_ref_no,
                               sum(iepd.element_penalty_amount) penality_amount
                          from iepd_inv_epenalty_details iepd
                         group by iepd.stock_id,
                                  iepd.internal_invoice_ref_no) iepd,
                       v_bi_latest_gmr_invoice invoice,
                       cm_currency_master cm
                 where pcm.internal_contract_ref_no =
                       gmr.internal_contract_ref_no
                   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
                   and gmr.internal_gmr_ref_no = iid.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = iid.stock_id
                   and iid.internal_invoice_ref_no =
                       iss.internal_invoice_ref_no
                   and iss.is_active = 'Y'
                   and pcm.is_active = 'Y'
                   and gmr.is_deleted = 'N'
                   and grd.is_deleted = 'N'
                   and pcm.is_tolling_contract = 'Y'
                   and pcm.purchase_sales = 'S'
                   and iid.stock_id = intc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       intc.internal_invoice_ref_no(+)
                   and iid.stock_id = inrc.grd_id(+)
                   and iid.internal_invoice_ref_no =
                       inrc.internal_invoice_ref_no(+)
                   and iid.stock_id = iepd.stock_id(+)
                   and iid.internal_invoice_ref_no =
                       iepd.internal_invoice_ref_no(+)
                   and iss.internal_invoice_ref_no =
                       invoice.internal_invoice_ref_no
                   and iid.invoice_currency_id = cm.cur_id
                   and pcm.cp_id = phd.profileid) test
         group by test.smelter_invoive_no,
                  test.smelter_invoice_date,
                  test.smelter_contract_ref_no,
                  test.smelter,
                  test.invoice_currency_id,
                  test.invoice_currency_code,
                  test.smelter_gmr_ref_no,
                  test.supp_internal_gmr_ref_no,
                  test.smelter_internal_gmr_ref_no) smelter
 where supplier.supplier_internal_gmr_ref_no =
       smelter.supp_internal_gmr_ref_no(+);
/
create or replace view v_wighted_asssy_details as
select ash.internal_grd_ref_no,
       ash.internal_gmr_ref_no,
       ash.ash_id,
       ash.assay_type,
       sum(asm.dry_weight) dry_weight,
       sum(asm.net_weight) net_weight,
       asm.net_weight_unit,
       pqca.element_id,
       rm.ratio_id,
       rm.ratio_name,
       pqca.is_deductible,
       pqca.is_elem_for_pricing,
       sum(asm.dry_weight * pqca.typical) / sum(asm.dry_weight) avg_typical
  from ash_assay_header            ash,
       asm_assay_sublot_mapping    asm,
       pqca_pq_chemical_attributes pqca,
       rm_ratio_master             rm
 where ash.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pqca.unit_of_measure = ratio_id
   and asm.is_active = 'Y'
   and ash.is_active = 'Y'
   and rm.is_active = 'Y'
   and pqca.is_active = 'Y'
    group by ash.internal_grd_ref_no,
          ash.internal_gmr_ref_no,
          pqca.element_id,
          ash.ash_id,
          ash.assay_type,
          asm.net_weight_unit,
          pqca.is_elem_for_pricing,
          rm.ratio_id,
           rm.ratio_name,
           pqca.is_deductible;
/
ALTER TABLE ASH_ASSAY_HEADER ADD (IS_SUBLOT_AS_SUBLOT_REARRANGE  CHAR(1)   DEFAULT 'N');
CREATE OR REPLACE VIEW V_BI_LOGISTICS as
with v_ash as(select ash.ash_id,
       sum(asm.net_weight) wet_weight,
       sum(asm.dry_weight)dry_weight
  from ash_assay_header         ash,
       asm_assay_sublot_mapping asm
 where ash.ash_id = asm.ash_id
   and ash.is_active = 'Y'
   and asm.is_active = 'Y'
 group by ash.ash_id)
select gcd.groupid,
       gcd.groupname corporate_group,
       gmr.corporate_id,
       akc.corporate_name,
       pcpd.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       css.strategy_id,
       css.strategy_name,
       pdm.product_id,
       pdm.product_desc,
       qat.quality_id,
       qat.quality_name,
       gmr.contract_type,
       phd.companyname counterparty,
       pcm.contract_ref_no,
       pcm.contract_ref_no || '-' || pci.del_distribution_item_no delivery_item_ref_no,
       pcm.contract_ref_no || '-' ||
       substr(pci.del_distribution_item_no, 1, 1) internal_contract_item_ref_no,
       gmr.gmr_ref_no,
       (case
         when gmr.gmr_latest_action_action_id = 'landingDetail' then
          'Landed'
         when gmr.gmr_latest_action_action_id = 'shipmentDetail' then
          'Shipped'
         else
          ''
       end) gmr_type,
       axs.eff_date shipment_activity_date,
       agmr.eff_date landing_activity_date,
       wrd.activity_ref_no arrival_no,
       iss.invoice_type_name invoice_status,
       gmr.mode_of_transport,
       agmr.bl_no trip_vehicle,
       gmr.vessel_name,
       cim_load.city_id loading_city_id,
       cim_load.city_name loading_city_name,
       sm_load.state_id loading_state_id,
       sm_load.state_name loading_state_name,
       cym_load.country_id loading_country_id,
       cym_load.country_name loading_country_name,
       cim_discharge.city_id discharge_city_id,
       cim_discharge.city_name discharge_city_name,
       sm_discharge.state_id discharge_state_id,
       sm_discharge.state_name discharge_state_name,
       cym_discharge.country_id discharge_country_id,
       cym_discharge.country_name discharge_country_name,
       sld.storage_loc_id warehouse_location_id,
       sld.storage_location_name warehouse_location,
       sld.country_id warehouse_country_id,
       cym_sld.country_name warehouse_country_name,
       sld.state_id warehouse_state_id,
       sm_sld.state_name warehouse_state_name,
       sld.city_id warehouse_city_id,
       cim_sld.city_name warehouse_city_name,
       ash.assay_type assay_status,
       qum.qty_unit bl_product_base_uom,
       sum(nvl(grd.total_qty, 0)) bl_wet_weight,
       sum(case
             when pcpq.unit_of_measure = 'Wet' then
              pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                      sam.ash_id,
                                                      nvl(grd.total_qty, 0),
                                                      grd.qty_unit_id)
             else
              nvl(grd.total_qty, 0)
           end) bl_dry_weight,
       qum.qty_unit actual_product_base_uom,
       sum(asm.wet_weight) actual_wet_weight,
       sum(asm.dry_weight) actual_dry_weight,
       (sum(case
              when pcpq.unit_of_measure = 'Wet' then
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                       sam.ash_id,
                                                       nvl(grd.total_qty,0),
                                                       grd.qty_unit_id)
              else
               nvl(grd.total_qty, 0)
            end) - sum(asm.dry_weight)) dry_qty_diff,
       sum(nvl(grd.total_qty, 0)) - sum(asm.wet_weight) wet_qty_diff,
       (sum(nvl(grd.total_qty, 0)) - sum(asm.wet_weight)) /
       sum(nvl(grd.total_qty, 0)) * 100 wet_ratio,
       (sum(case
              when pcpq.unit_of_measure = 'Wet' then
               pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                       sam.ash_id,
                                                       nvl(grd.total_qty, 0),
                                                       grd.qty_unit_id)
              else
               nvl(grd.total_qty, 0)
            end) - sum(asm.dry_weight)) /
       sum(case
             when pcpq.unit_of_measure = 'Wet' then
              pkg_report_general.fn_get_assay_dry_qty(grd.product_id,
                                                      sam.ash_id,
                                                      nvl(grd.total_qty, 0),
                                                      grd.qty_unit_id)
             else
              nvl(grd.total_qty, 0)
           end) * 100 dry_ratio
  from gmr_goods_movement_record gmr,
       ak_corporate akc,
       grd_goods_record_detail grd,
       gcd_groupcorporatedetails gcd,
       pcpd_pc_product_definition pcpd,
       cpc_corporate_profit_center cpc,
       (select gmr.internal_gmr_ref_no,
               agmr.eff_date,
               agmr.bl_no
          from gmr_goods_movement_record gmr,
               agmr_action_gmr           agmr
         where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
           and agmr.gmr_latest_action_action_id = 'landingDetail'
           and agmr.is_deleted = 'N') agmr,
       pcm_physical_contract_main pcm,
       v_bi_latest_gmr_invoice iis,
       is_invoice_summary iss,
       css_corporate_strategy_setup css,
       pcdi_pc_delivery_item pcdi,
       pci_physical_contract_item pci,
       pcpq_pc_product_quality pcpq,
       phd_profileheaderdetails phd,
       (select wrd.internal_gmr_ref_no,
               wrd.activity_ref_no,
               wrd.shed_id
          from wrd_warehouse_receipt_detail wrd
         where (wrd.internal_gmr_ref_no, wrd.action_no) in
               (select wrd.internal_gmr_ref_no,
                       max(action_no)
                  from wrd_warehouse_receipt_detail wrd
                 group by wrd.internal_gmr_ref_no)) wrd,
       sld_storage_location_detail sld,
       sm_state_master sm_sld,
       cim_citymaster cim_sld,
       cym_countrymaster cym_sld,
       pdm_productmaster pdm,
       qat_quality_attributes qat,
       qum_quantity_unit_master qum,
       sm_state_master sm_load,
       cim_citymaster cim_load,
       cym_countrymaster cym_load,
       sm_state_master sm_discharge,
       cim_citymaster cim_discharge,
       cym_countrymaster cym_discharge,
       ash_assay_header ash,
       v_ash asm,
       sam_stock_assay_mapping sam,
       axs_action_summary axs
 where gmr.corporate_id = akc.corporate_id
   and gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
   and akc.groupid = gcd.groupid
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.profit_center_id = cpc.profit_center_id
   and gmr.gmr_first_int_action_ref_no = axs.internal_action_ref_no
   and gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no(+)
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and gmr.internal_gmr_ref_no = iis.internal_gmr_ref_no(+)
   and iis.internal_invoice_ref_no = iss.internal_invoice_ref_no(+)
   and pcpd.strategy_id = css.strategy_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pcpd.pcpd_id = pcpq.pcpd_id
   and pci.pcpq_id = pcpq.pcpq_id
   and pcm.cp_id = phd.profileid
   and gmr.internal_gmr_ref_no = wrd.internal_gmr_ref_no(+)
   and wrd.shed_id = sld.storage_loc_id(+)
   and sld.state_id = sm_sld.state_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and sld.country_id = cym_sld.country_id(+)
   and pcpd.product_id = pdm.product_id
   and pcpq.quality_template_id = qat.quality_id
   and pcpd.qty_unit_id = qum.qty_unit_id
   and gmr.loading_state_id = sm_load.state_id(+)
   and gmr.loading_city_id = cim_load.city_id(+)
   and gmr.loading_country_id = cym_load.country_id(+)
   and gmr.discharge_state_id = sm_discharge.state_id(+)
   and gmr.discharge_city_id = cim_discharge.city_id(+)
   and gmr.discharge_country_id = cym_discharge.country_id(+)
   and grd.internal_grd_ref_no = sam.internal_grd_ref_no
   and sam.ash_id = ash.ash_id
   and ash.ash_id = asm.ash_id   
   and nvl(ash.is_active, 'Y') = 'Y'
   and grd.is_afloat = 'N'
   and gmr.is_deleted = 'N'
   and gmr.is_internal_movement = 'N'
   and pci.is_active = 'Y'
   and pcm.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and pcpq.is_active = 'Y'
   and phd.is_active = 'Y'
   and qum.is_active = 'Y'
   and qat.is_active = 'Y'
   and gcd.is_active = 'Y'
   and sam.is_latest_pricing_assay = 'Y'
   and pcpd.input_output = 'Input'
   and grd.status = 'Active'
   and grd.tolling_stock_type = 'None Tolling'
 group by gcd.groupid,
          gcd.groupname,
          gmr.corporate_id,
          akc.corporate_name,
          pcpd.profit_center_id,
          cpc.profit_center_name,
          cpc.profit_center_short_name,
          css.strategy_id,
          css.strategy_name,
          pdm.product_id,
          pdm.product_desc,
          qat.quality_id,
          qat.quality_name,
          gmr.contract_type,
          phd.companyname,
          pcm.contract_ref_no,
          pci.del_distribution_item_no,
          gmr.gmr_ref_no,
          gmr.gmr_latest_action_action_id,
          axs.eff_date,
          agmr.eff_date,
          wrd.activity_ref_no,
          iss.invoice_type_name,
          gmr.mode_of_transport,
          agmr.bl_no,
          gmr.vessel_name,
          cim_load.city_id,
          cim_load.city_name,
          sm_load.state_id,
          sm_load.state_name,
          cym_load.country_id,
          cym_load.country_name,
          cim_discharge.city_id,
          cim_discharge.city_name,
          sm_discharge.state_id,
          sm_discharge.state_name,
          cym_discharge.country_id,
          cym_discharge.country_name,
          sld.storage_loc_id,
          sld.storage_location_name,
          sld.country_id,
          cym_sld.country_name,
          sld.state_id,
          sm_sld.state_name,
          sld.city_id,
          cim_sld.city_name,
          ash.assay_type,
          qum.qty_unit,
          pcpq.unit_of_measure,
          qum.qty_unit
/
drop MATERIALIZED VIEW MV_BI_LOGISTICS;
CREATE MATERIALIZED VIEW MV_BI_LOGISTICS
REFRESH FORCE ON DEMAND
START WITH TO_DATE('16-05-2012 16:33:41', 'DD-MM-YYYY HH24:MI:SS') NEXT SYSDATE+5/1440 
AS
SELECT * FROM V_BI_LOGISTICS;
/
CREATE OR REPLACE VIEW V_BI_CONC_PHY_POSITION AS
select 'Composite' product_type,
       'Concentrates Open Contracts' section_name,
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
       pgm.product_group_id,
       pgm.product_group_name product_group,
       nvl(qat.product_origin_id, 'NA') origin_id,
       nvl(orm.origin_name, 'NA') origin_name,
       qat.quality_id,
       qat.quality_name,
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
       case
         when pcm.purchase_sales = 'P' then
          'Physical - Open Purchase'
         else
          'Physical - Open Sales'
       end as position_type_id,
       'Physical' as position_type,
       case
         when pcm.purchase_sales = 'P' then
          'Open Purchase'
         else
          'Open Sales'
       end as position_sub_type,
       pcm.contract_ref_no || ',' || pci.del_distribution_item_no contract_ref_no,
       nvl(pcm.cp_contract_ref_no, 'NA') cp_contract_ref_no,
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
       end dest_state_id,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_name
         else
          'NA'
       end dest_state_name,
       case
         when itm.location_field = 'DESTINATION' then
          rem_pcdb.region_name
         else
          'NA'
       end dest_loc_group_name,
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
       (ciqs.open_qty -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    ciqs.open_qty)) * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               gcd.group_qty_unit_id,
                                               1) / 100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               rm.qty_unit_id_denominator,
                                               1) *
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               gcd.group_qty_unit_id,
                                               1)
       end) * pqcapd.payable_percentage qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (ciqs.open_qty -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    ciqs.open_qty)) * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               ciqs.item_qty_unit_id,
                                               1) / 100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               rm.qty_unit_id_denominator,
                                               1) *
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               ciqs.item_qty_unit_id,
                                               1)
       end) * pqcapd.payable_percentage qty_in_ctract_unit,
       qum_ciqs.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pcm.invoice_currency_id invoice_cur_id,
       cm_invoice_cur.cur_code invoice_cur_code,
       qum_under.qty_unit base_qty_unit,
       (ciqs.open_qty -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    ciqs.open_qty)) * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1) / 100
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               ciqs.item_qty_unit_id,
                                               nvl(rm.qty_unit_id_denominator,
                                                   pdm.base_quantity_unit),
                                               1) *
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               nvl(pdm_under.base_quantity_unit,
                                                   pdm.base_quantity_unit),
                                               1)
       end) * pqcapd.payable_percentage qty_in_base_unit,
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
       pdm_under.product_desc element_name,
       nvl(phd_wh.profileid, 'NA') warehouse_profile_id,
       nvl(phd_wh.companyname, 'NA') warehouse_name,
       nvl(sld.storage_loc_id, 'NA') shed_id,
       nvl(sld.storage_location_name, 'NA') shed_name
  from pcdi_pc_delivery_item          pcdi,
       pcm_physical_contract_main     pcm,
       pci_physical_contract_item     pci,
       pcmte_pcm_tolling_ext          pcmte,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       ciqs_contract_item_qty_status  ciqs,
       pcpd_pc_product_definition     pcpd,
       pcpq_pc_product_quality        pcpq,
       pcdb_pc_delivery_basis         pcdb,
       ak_corporate                   akc,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       css_corporate_strategy_setup   css,
       pdm_productmaster              pdm,
       pgm_product_group_master       pgm,
       qat_quality_attributes         qat,
       ak_corporate_user              akcu,
       gab_globaladdressbook          gab,
       itm_incoterm_master            itm,
       pym_payment_terms_master       pym,
       cm_currency_master             cm_base_cur,
       cm_currency_master             cm_invoice_cur,
       phd_profileheaderdetails       phd_contract_cp,
       pom_product_origin_master      pom,
       orm_origin_master              orm,
       cym_countrymaster              cym_pcdb,
       cim_citymaster                 cim_pcdb,
       rem_region_master              rem_pcdb,
       sm_state_master                sm_pcdb,
       qum_quantity_unit_master       qum_ciqs,
       gcd_groupcorporatedetails      gcd,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       v_ucm_conversion               ucm_base,
       ash_assay_header               vsh,
       qum_quantity_unit_master       qum_under,
       pdtm_product_type_master       pdtm,
       asm_assay_sublot_mapping       asm,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       phd_profileheaderdetails       phd_wh,
       sld_storage_location_detail    sld,
       pqcapd_prd_qlty_cattr_pay_dtls pqcapd
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and poch.is_active = 'Y'
   and aml.underlying_product_id = pdm_under.product_id
   and pcm.contract_status = 'In Position'
   and pcm.contract_type = 'CONCENTRATES'
   and pci.internal_contract_item_ref_no =
       ciqs.internal_contract_item_ref_no
   and pci.is_active = 'Y'
   and pcdi.is_active = 'Y'
   and ciqs.is_active = 'Y'
   and ciqs.open_qty > 0
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.is_active = 'Y'
   and pci.pcpq_id = pcpq.pcpq_id
   and pcpq.is_active = 'Y'
   and pci.pcdb_id = pcdb.pcdb_id
   and pcdb.is_active = 'Y'
   and pcm.corporate_id = akc.corporate_id
   and pcpd.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id
   and pcpd.strategy_id = css.strategy_id
   and pcpd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id
   and pcpq.quality_template_id = qat.quality_id
   and pcm.trader_id = akcu.user_id
   and akcu.gabid = gab.gabid
   and pcdb.inco_term_id = itm.incoterm_id
   and pcm.payment_term_id = pym.payment_term_id
   and cm_base_cur.cur_id = akc.base_cur_id
   and akc.base_cur_id = cm_invoice_cur.cur_id
   and pcm.cp_id = phd_contract_cp.profileid
   and qat.product_origin_id = pom.product_origin_id(+)
   and pcpq.assay_header_id = vsh.ash_id
   and pom.origin_id = orm.origin_id(+)
   and cym_pcdb.country_id = pcdb.country_id
   and cim_pcdb.city_id = pcdb.city_id
   and sm_pcdb.state_id = pcdb.state_id
   and cym_pcdb.region_id = rem_pcdb.region_id
   and ciqs.item_qty_unit_id = qum_ciqs.qty_unit_id
   and akc.groupid = gcd.groupid
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and ucm.from_qty_unit_id = ciqs.item_qty_unit_id
   and ucm.to_qty_unit_id = gcd.group_qty_unit_id
   and ciqs.item_qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id
   and pcpq.quality_template_id = qat.quality_id
   and pdm.product_type_id = pdtm.product_type_id
   and vsh.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pcpd.input_output = 'Input'
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id(+)
   and pcdb.warehouse_id = phd_wh.profileid(+)
   and pcdb.warehouse_shed_id = sld.storage_loc_id(+)
   and pqca.pqca_id = pqcapd.pqca_id
union all
-- 2. shipped but not tt for purchase gmrs
select 'Composite' product_type,
       'Concentrates Shipped But Not TT for Purchase GMRs' section_name,
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
       pgm.product_group_id,
       pgm.product_group_name product_group,
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
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
       case
         when pci.purchase_sales = 'P' then
          'Physical - Open Purchase'
         else
          'Physical - Open Sales'
       end position_type_id,
       'Physical' position_type,
       case
         when pci.purchase_sales = 'P' then
          'Open Purchase'
         else
          'Open Sales'
       end position_sub_type,
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
       nvl(pcdi.item_price_type, 'NA') price_type_name,
       pci.invoice_currency_id pay_in_cur_id,
       cm_invoice_currency.cur_code pay_in_cur_code,
       'NA' item_price_string,
       nvl(cym_gmr_dest_country.country_id, 'NA') dest_country_id,
       nvl(cym_gmr_dest_country.country_name, 'NA') dest_country_name,
       nvl(cim_gmr_dest_city.city_id, 'NA') dest_city_id,
       nvl(cim_gmr_dest_city.city_name, 'NA') dest_city_name,
       nvl(sm_gmr.state_id, 'NA') dest_state_id,
       nvl(sm_gmr.state_name, 'NA') dest_state_name,
       nvl(rem_gmr_dest_region.region_name, 'NA') dest_loc_group_name,
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
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    (nvl(grd.current_qty, 0) +
                                                    nvl(grd.release_shipped_qty,
                                                         0) -
                                                    nvl(grd.title_transfer_out_qty,
                                                         0)))) *
       ucm_base.multiplication_factor * (case
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
                                               qum_gcd.qty_unit_id,
                                               1)
       end) * pqcapd.payable_percentage qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    (nvl(grd.current_qty, 0) +
                                                    nvl(grd.release_shipped_qty,
                                                         0) -
                                                    nvl(grd.title_transfer_out_qty,
                                                         0)))) *
       ucm.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   grd.qty_unit_id),
                                               1)
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               grd.qty_unit_id,
                                               1)
       end) * pqcapd.payable_percentage qty_in_ctract_unit,
       grd.qty_unit_id ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       qum_under.qty_unit base_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    (nvl(grd.current_qty, 0) +
                                                    nvl(grd.release_shipped_qty,
                                                         0) -
                                                    nvl(grd.title_transfer_out_qty,
                                                         0)))) *
       ucm_base.multiplication_factor * (case
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
       end) * pqcapd.payable_percentage qty_in_base_unit,
       nvl(cym_gmr_dest_country.country_id, 'NA') || ' - ' ||
       nvl(cim_gmr_dest_city.city_id, 'NA') comb_destination_id,
       'NA-NA' comb_origination_id,
       nvl(case
             when grd.is_afloat = 'Y' then
              cym_gmr.country_id
             else
              cym_sld.country_id
           end,
           'NA') || ' - ' || nvl(case
                                   when grd.is_afloat = 'Y' then
                                    cim_gmr.city_id
                                   else
                                    cim_sld.city_id
                                 end,
                                 'NA') comb_valuation_loc_id,
       pdm_under.product_desc element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       nvl(sld.storage_loc_id, 'NA'),
       nvl(sld.storage_location_name, 'NA')
  from grd_goods_record_detail        grd,
       gmr_goods_movement_record      gmr,
       pcm_physical_contract_main     pcm,
       pcmte_pcm_tolling_ext          pcmte,
       pcpd_pc_product_definition     pcpd,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       pcpq_pc_product_quality        pcpq,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       sm_state_master                sm_gmr,
       v_pci_pcdi_details             pci,
       pdm_productmaster              pdm,
       pgm_product_group_master       pgm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       itm_incoterm_master            itm,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       gab_globaladdressbook          gab,
       phd_profileheaderdetails       phd_pcm_cp,
       pym_payment_terms_master       pym,
       cm_currency_master             cm_invoice_currency,
       cim_citymaster                 cim_gmr_dest_city,
       cym_countrymaster              cym_gmr_dest_country,
       rem_region_master              rem_gmr_dest_region,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       cm_currency_master             cm_base_currency,
       pcdi_pc_delivery_item          pcdi,
       qum_quantity_unit_master       qum_under,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       v_ucm_conversion               ucm_base,
       -- v_stock_position_assay_id      vsp,
       sam_stock_assay_mapping        vsp,
       ash_assay_header               vdc,
       ak_corporate_user              aku,
       qat_quality_attributes         qat,
       asm_assay_sublot_mapping       asm,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       phd_profileheaderdetails       phd_wh,
       pqcapd_prd_qlty_cattr_pay_dtls pqcapd
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id = ppm.product_id
   and pqca.element_id = ppm.attribute_id
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and ppm.property_id = qav.attribute_id
   and pci.pcpq_id = pcpq.pcpq_id(+)
   and pcpq.quality_template_id = qav.quality_id
   and qav.is_deleted = 'N'
   and grd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and cim_gmr_dest_city.state_id = sm_gmr.state_id(+)
   and grd.quality_id = qat.quality_id(+)
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
   and pdtm.product_type_name = 'Composite'
   and pci.cp_id = phd_pcm_cp.profileid(+)
   and pci.payment_term_id = pym.payment_term_id(+)
   and nvl(gmr.inventory_status, 'NA') = 'In'
   and pci.invoice_currency_id = cm_invoice_currency.cur_id(+)
   and cym_gmr_dest_country.country_id(+) = gmr.discharge_country_id
   and cym_gmr_dest_country.region_id = rem_gmr_dest_region.region_id(+)
   and cim_gmr_dest_city.city_id(+) = gmr.discharge_city_id
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and gcd.group_qty_unit_id = ucm.to_qty_unit_id
   and cm_base_currency.cur_id = akc.base_cur_id
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pci.internal_contract_ref_no
   and pcdi.pcdi_id = poch.pcdi_id
   and poch.element_id = aml.attribute_id
   and poch.is_active = 'Y'
   and aml.underlying_product_id = pdm_under.product_id
   and grd.qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and grd.internal_grd_ref_no = vsp.internal_grd_ref_no
   and vsp.is_latest_position_assay = 'Y'
   and vsp.ash_id = vdc.ash_id
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id
   and vdc.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pcpd.input_output = 'Input'
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id(+)
   and grd.warehouse_profile_id = phd_wh.profileid(+)
   and pqca.pqca_id = pqcapd.pqca_id
-- 3. shipped but not tt sales gmrs
union all
select 'Composite' product_type,
       'Concentrates Shipped But Not TT for Sales GMRs' section_name,
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
       pgm.product_group_id,
       pgm.product_group_name product_group,
       'NA' origin_id,
       'NA' origin_name,
       qat.quality_id quality_id,
       qat.quality_name quality_name,
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
       'Physical - Open Sales' position_type_id,
       'Physical' position_type,
       'Open Sales' position_sub_type,
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
       'NA' item_price_string,
       case
         when itm.location_field = 'DESTINATION' then
          pcdb.country_id
         else
          'NA'
       end destination_country_id,
       case
         when itm.location_field = 'DESTINATION' then
          cym_pcdb.country_name
         else
          'NA'
       end destination_country,
       case
         when itm.location_field = 'DESTINATION' then
          cim_pcdb.city_id
         else
          'NA'
       end destination_city_id,
       case
         when itm.location_field = 'DESTINATION' then
          cim_pcdb.city_name
         else
          'NA'
       end destination_city,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_id
         else
          'NA'
       end dest_state_id,
       case
         when itm.location_field = 'DESTINATION' then
          sm_pcdb.state_name
         else
          'NA'
       end dest_state_name,
       case
         when itm.location_field = 'DESTINATION' then
          rem_gmr.region_name
         else
          'NA'
       end dest_loc_group_name,
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
       (dgrd.current_qty -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    dgrd.current_qty)) *
       ucm_base.multiplication_factor * (case
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
                                               qum_gcd.qty_unit_id,
                                               1)
       end) * pqcapd.payable_percentage qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       (dgrd.current_qty -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    dgrd.current_qty)) *
       ucm.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   dgrd.net_weight_unit_id),
                                               1)
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               dgrd.net_weight_unit_id,
                                               1)
       end) * pqcapd.payable_percentage qty_in_ctract_unit,
       qum_dgrd.qty_unit ctract_qty_unit,
       cm_base_cur.cur_code corp_base_cur,
       to_char(sysdate, 'Mon-yyyy') delivery_month,
       cm_invoice_curreny.cur_id invoice_cur_id,
       cm_invoice_curreny.cur_code invoice_cur_code,
       qum_under.qty_unit base_qty_unit,
       (dgrd.current_qty -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    dgrd.current_qty)) *
       ucm_base.multiplication_factor *
       
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
       end) * pqcapd.payable_percentage qty_in_base_unit,
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
       pdm_under.product_desc element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       nvl(sld.storage_loc_id, 'NA'),
       nvl(sld.storage_location_name, 'NA')
  from dgrd_delivered_grd             dgrd,
       gmr_goods_movement_record      gmr,
       pcm_physical_contract_main     pcm,
       pcmte_pcm_tolling_ext          pcmte,
       pcpd_pc_product_definition     pcpd,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       pcpq_pc_product_quality        pcpq,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_sld,
       cym_countrymaster              cym_gmr,
       rem_region_master              rem_gmr,
       v_pci_pcdi_details             pci,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       pdm_productmaster              pdm,
       pgm_product_group_master       pgm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       itm_incoterm_master            itm,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       gab_globaladdressbook          gab,
       ak_corporate_user              aku,
       pym_payment_terms_master       pym,
       phd_profileheaderdetails       phd_pcm_cp,
       cm_currency_master             cm_invoice_curreny,
       pcdb_pc_delivery_basis         pcdb,
       cim_citymaster                 cim_pcdb,
       cym_countrymaster              cym_pcdb,
       sm_state_master                sm_pcdb,
       qum_quantity_unit_master       qum_gcd,
       qum_quantity_unit_master       qum_dgrd,
       cm_currency_master             cm_base_cur,
       ucm_unit_conversion_master     ucm,
       v_ucm_conversion               ucm_base,
       qat_quality_attributes         qat,
       --  v_stock_position_assay_id      vsp,
       sam_stock_assay_mapping        vsp,
       ash_assay_header               vdc,
       qum_quantity_unit_master       qum_under,
       asm_assay_sublot_mapping       asm,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       phd_profileheaderdetails       phd_wh,
       pqcapd_prd_qlty_cattr_pay_dtls pqcapd
 where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id = ppm.product_id
   and pqca.element_id = ppm.attribute_id
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and ppm.property_id = qav.attribute_id
   and pci.pcpq_id = pcpq.pcpq_id(+)
   and pcpq.quality_template_id = qav.quality_id
   and qav.is_deleted = 'N'
   and dgrd.shed_id = sld.storage_loc_id(+)
   and sld.city_id = cim_sld.city_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_sld.country_id = cym_sld.country_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and cym_gmr.region_id = rem_gmr.region_id(+)
   and dgrd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and dgrd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdtm.product_type_name = 'Composite'
   and pdm.base_quantity_unit = qum.qty_unit_id
   and pci.inco_term_id = itm.incoterm_id(+)
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and nvl(dgrd.current_qty, 0) > 0
   and nvl(dgrd.inventory_status, 'NA') <> 'Out'
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and dgrd.status = 'Active'
   and gmr.created_by = aku.user_id
   and aku.gabid = gab.gabid(+)
   and pci.payment_term_id = pym.payment_term_id(+)
   and pci.cp_id = phd_pcm_cp.profileid(+)
   and pci.invoice_currency_id = cm_invoice_curreny.cur_id(+)
   and pcdb.internal_contract_ref_no = pci.internal_contract_ref_no
   and pci.pcdb_id = pcdb.pcdb_id
   and pcdb.is_active = 'Y'
   and pci.pcdi_id = poch.pcdi_id
   and poch.is_active = 'Y'
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id
   and pcdb.city_id = cim_pcdb.city_id(+)
   and pcdb.state_id = sm_pcdb.state_id(+)
   and pcdb.country_id = cym_pcdb.country_id(+)
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and ucm.from_qty_unit_id = dgrd.net_weight_unit_id
   and ucm.to_qty_unit_id = gcd.group_qty_unit_id
   and cm_base_cur.cur_id = akc.base_cur_id
   and qum_dgrd.qty_unit_id = dgrd.net_weight_unit_id
   and dgrd.net_weight_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
   and qat.quality_id = dgrd.quality_id
   and dgrd.internal_dgrd_ref_no = vsp.internal_dgrd_ref_no
   and vsp.is_latest_pricing_assay = 'Y'
   and vsp.ash_id = vdc.ash_id
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id
   and vdc.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pcpd.input_output = 'Input'
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id(+)
   and dgrd.warehouse_profile_id = phd_wh.profileid(+)
   and pqca.pqca_id = pqcapd.pqca_id
union all
--4
select 'Composite' product_type,
       'Concentrates TT out for Purchase  GMRs' section_name,
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
       pgm.product_group_id,
       pgm.product_group_name product_group,
       'NA' origin_id,
       'NA' origin_name,
       grd.quality_id quality_id,
       qat.quality_name quality_name,
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
       'Stocks -  Actual Stocks' position_type_id,
       'Stocks' position_type,
       'Actual Stocks' position_sub_type,
       grd.internal_grd_ref_no contract_ref_no,
       'NA' external_reference_no,
       gmr.eff_date issue_date,
       'NA' counter_party_id,
       'NA' counter_party_name,
       'NA' trader_user_id,
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
       'NA' item_price_string,
       cym_gmr_dest_country.country_id dest_country_id,
       cym_gmr_dest_country.country_name dest_country_name,
       cim_gmr_dest_city.city_id dest_city_id,
       cim_gmr_dest_city.city_name dest_city_name,
       sm_gmr_dest_state.state_id dest_state_id,
       sm_gmr_dest_state.state_name dest_state_name,
       rem_gmr_dest_region.region_name dest_loc_group_name,
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
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    (nvl(grd.current_qty, 0) +
                                                    nvl(grd.release_shipped_qty,
                                                         0) -
                                                    nvl(grd.title_transfer_out_qty,
                                                         0)))) *
       ucm_base.multiplication_factor *
       
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
                                               qum_gcd.qty_unit_id,
                                               1)
       end) * pqcapd.payable_percentage qty_in_group_unit,
       qum_gcd.qty_unit group_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    (nvl(grd.current_qty, 0) +
                                                    nvl(grd.release_shipped_qty,
                                                         0) -
                                                    nvl(grd.title_transfer_out_qty,
                                                         0)))) *
       ucm.multiplication_factor * (case
         when rm.ratio_name = '%' then
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               pci.item_qty_unit_id,
                                               nvl(pdm_under.base_quantity_unit,
                                                   grd.qty_unit_id),
                                               1)
         else
          pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                   pdm.product_id),
                                               rm.qty_unit_id_numerator,
                                               grd.qty_unit_id,
                                               1)
       end) * pqcapd.payable_percentage qty_in_ctract_unit,
       grd.qty_unit_id ctract_qty_unit,
       cm_base_currency.cur_code corp_base_cur,
       pci.expected_delivery_month || '-' || pci.expected_delivery_year delivery_month,
       pci.invoice_currency_id invoice_cur_id,
       cm_invoice_currency.cur_code invoice_cur_code,
       qum_under.qty_unit base_qty_unit,
       ((nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) -
       pkg_report_general.fn_deduct_wet_to_dry_qty(pdm.product_id,
                                                    pci.internal_contract_item_ref_no,
                                                    (nvl(grd.current_qty, 0) +
                                                    nvl(grd.release_shipped_qty,
                                                         0) -
                                                    nvl(grd.title_transfer_out_qty,
                                                         0)))) *
       
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
       end) * pqcapd.payable_percentage qty_in_base_unit,
       cym_gmr_dest_country.country_id || ' - ' ||
       cim_gmr_dest_city.city_id comb_destination_id,
       'NA' comb_origination_id,
       '' comb_valuation_loc_id,
       pdm_under.product_desc element_name,
       nvl(phd_wh.profileid, 'NA'),
       nvl(phd_wh.companyname, 'NA'),
       nvl(sld.storage_loc_id, 'NA'),
       nvl(sld.storage_location_name, 'NA')
  from grd_goods_record_detail        grd,
       gmr_goods_movement_record      gmr,
       pcm_physical_contract_main     pcm,
       pcmte_pcm_tolling_ext          pcmte,
       pcpd_pc_product_definition     pcpd,
       ppm_product_properties_mapping ppm,
       qav_quality_attribute_values   qav,
       pcpq_pc_product_quality        pcpq,
       sld_storage_location_detail    sld,
       cim_citymaster                 cim_gmr,
       cym_countrymaster              cym_gmr,
       v_pci_pcdi_details             pci,
       poch_price_opt_call_off_header poch,
       aml_attribute_master_list      aml,
       pdm_productmaster              pdm_under,
       pdm_productmaster              pdm,
       pgm_product_group_master       pgm,
       pdtm_product_type_master       pdtm,
       qum_quantity_unit_master       qum,
       qat_quality_attributes         qat,
       css_corporate_strategy_setup   css,
       cpc_corporate_profit_center    cpc,
       blm_business_line_master       blm,
       ak_corporate                   akc,
       gcd_groupcorporatedetails      gcd,
       cm_currency_master             cm_invoice_currency,
       cim_citymaster                 cim_gmr_dest_city,
       cym_countrymaster              cym_gmr_dest_country,
       rem_region_master              rem_gmr_dest_region,
       sm_state_master                sm_gmr_dest_state,
       qum_quantity_unit_master       qum_gcd,
       ucm_unit_conversion_master     ucm,
       cm_currency_master             cm_base_currency,
       pcdi_pc_delivery_item          pcdi,
       v_ucm_conversion               ucm_base,
       -- v_stock_position_assay_id      vsp,
       sam_stock_assay_mapping        vsp,
       ash_assay_header               vdc,
       qum_quantity_unit_master       qum_under,
       asm_assay_sublot_mapping       asm,
       pqca_pq_chemical_attributes    pqca,
       rm_ratio_master                rm,
       phd_profileheaderdetails       phd_wh,
       pqcapd_prd_qlty_cattr_pay_dtls pqcapd
 where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and pcm.internal_contract_ref_no = pcmte.int_contract_ref_no(+)
   and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   and pcpd.product_id = ppm.product_id
   and pqca.element_id = ppm.attribute_id
   and ppm.is_active = 'Y'
   and ppm.is_deleted = 'N'
   and ppm.property_id = qav.attribute_id
   and pci.pcpq_id = pcpq.pcpq_id(+)
   and pcpq.quality_template_id = qav.quality_id
   and qav.is_deleted = 'N'
   and grd.product_id = pdm.product_id
   and pdm.product_group_id = pgm.product_group_id
   and pdm.product_type_id = pdtm.product_type_id
   and pdm.base_quantity_unit = qum.qty_unit_id
   and grd.shed_id = sld.storage_loc_id(+)
   and gmr.discharge_city_id = cim_gmr.city_id(+)
   and cim_gmr.country_id = cym_gmr.country_id(+)
   and grd.quality_id = qat.quality_id
   and gmr.corporate_id = akc.corporate_id
   and akc.groupid = gcd.groupid
   and grd.is_deleted = 'N'
   and grd.status = 'Active'
   and grd.internal_contract_item_ref_no =
       pci.internal_contract_item_ref_no(+)
   and pci.pcdi_id = poch.pcdi_id
   and poch.is_active = 'Y'
   and poch.element_id = aml.attribute_id
   and aml.underlying_product_id = pdm_under.product_id
   and pci.strategy_id = css.strategy_id(+)
   and pci.profit_center_id = cpc.profit_center_id(+)
   and cpc.business_line_id = blm.business_line_id(+)
   and (nvl(grd.current_qty, 0) + nvl(grd.release_shipped_qty, 0) -
       nvl(grd.title_transfer_out_qty, 0)) > 0
   and pdtm.product_type_name = 'Composite'
   and pci.invoice_currency_id = cm_invoice_currency.cur_id(+)
   and cym_gmr_dest_country.country_id(+) = gmr.discharge_country_id
   and cym_gmr_dest_country.region_id = rem_gmr_dest_region.region_id(+)
   and cim_gmr_dest_city.city_id(+) = gmr.discharge_city_id
   and cim_gmr_dest_city.state_id = sm_gmr_dest_state.state_id(+)
   and qum_gcd.qty_unit_id = gcd.group_qty_unit_id
   and grd.qty_unit_id = ucm.from_qty_unit_id
   and gcd.group_qty_unit_id = ucm.to_qty_unit_id
   and cm_base_currency.cur_id = akc.base_cur_id
   and pci.pcdi_id = pcdi.pcdi_id
   and pcdi.internal_contract_ref_no = pci.internal_contract_ref_no
   and grd.qty_unit_id = ucm_base.from_qty_unit_id
   and pdm.base_quantity_unit = ucm_base.to_qty_unit_id
      -- and grd.internal_grd_ref_no = vsp.internal_grd_ref_no
   and grd.internal_grd_ref_no = vsp.internal_grd_ref_no
   and vsp.is_latest_position_assay = 'Y'
   and vsp.ash_id = vdc.ash_id
   and nvl(gmr.inventory_status, 'NA') = 'Out'
   and pdm_under.base_quantity_unit = qum_under.qty_unit_id
   and vdc.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pcpd.input_output = 'Input'
   and pqca.element_id = aml.attribute_id
   and pqca.is_elem_for_pricing = 'Y'
   and pqca.unit_of_measure = rm.ratio_id(+)
   and grd.warehouse_profile_id = phd_wh.profileid(+)
   and pqca.pqca_id = pqcapd.pqca_id;
/
CREATE OR REPLACE PACKAGE "PKG_PRICE" is

  -- Author  : JANARDHANA
  -- Created : 12/8/2011 2:34:26 PM
  -- Purpose : Online Price Calculation for Contracts and GMRs
  procedure sp_calc_contract_price(pc_int_contract_item_ref_no varchar2,
                                   pd_trade_date               date,
                                   pn_price                    out number,
                                   pc_price_unit_id            out varchar2);

  procedure sp_calc_gmr_price(pc_internal_gmr_ref_no varchar2,
                              pd_trade_date          date,
                              pn_price               out number,
                              pc_price_unit_id       out varchar2);

  procedure sp_calc_contract_conc_price(pc_int_contract_item_ref_no varchar2,
                                        pc_element_id               varchar2,
                                        pd_trade_date               date,
                                        pn_price                    out number,
                                        pc_price_unit_id            out varchar2);

  procedure sp_calc_conc_gmr_price(pc_internal_gmr_ref_no varchar2,
                                   pc_element_id          varchar2,
                                   pd_trade_date          date,
                                   pn_price               out number,
                                   pc_price_unit_id       out varchar2);

  function f_get_next_day(pd_date     in date,
                          pc_day      in varchar2,
                          pn_position in number) return date;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean;

  function f_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                        pd_trade_date       date) return date;

end;
/
CREATE OR REPLACE PACKAGE BODY "PKG_PRICE" is

  procedure sp_calc_contract_price(pc_int_contract_item_ref_no varchar2,
                                   pd_trade_date               date,
                                   pn_price                    out number,
                                   pc_price_unit_id            out varchar2) is
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pd_trade_date eod_trade_date,
             pcdi.basis_type,
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.price_option_call_off_status,
             pci.internal_contract_item_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable,
             akc.corporate_id
        from pcdi_pc_delivery_item        pcdi,
             pci_physical_contract_item   pci,
             pcm_physical_contract_main   pcm,
             ak_corporate                 akc,
             pcpd_pc_product_definition   pcpd,
             pcpq_pc_product_quality      pcpq,
             v_contract_exchange_detail   qat,
             dim_der_instrument_master    dim,
             div_der_instrument_valuation div,
             ps_price_source              ps,
             apm_available_price_master   apm,
             pum_price_unit_master        pum,
             v_der_instrument_price_unit  vdip,
             pdc_prompt_delivery_calendar pdc
       where pcdi.pcdi_id = pci.pcdi_id
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'BASEMETAL'
         and pci.internal_contract_item_ref_no =
             qat.internal_contract_item_ref_no(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and pci.item_qty > 0
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no;
    cursor cur_called_off(pc_pcdi_id varchar2) is
      select poch.poch_id,
             poch.internal_action_ref_no,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where poch.pcdi_id = pc_pcdi_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    cursor cur_not_called_off(pc_pcdi_id varchar2, pc_int_cont_item_ref_no varchar2) is
      select pcbpd.pcbpd_id,
             pcbph.internal_contract_ref_no,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced
        from pci_physical_contract_item pci,
             pcipf_pci_pricing_formula  pcipf,
             pcbph_pc_base_price_header pcbph,
             pcbpd_pc_base_price_detail pcbpd
       where pci.internal_contract_item_ref_no =
             pcipf.internal_contract_item_ref_no
         and pcipf.pcbph_id = pcbph.pcbph_id
         and pcbph.pcbph_id = pcbpd.pcbph_id
         and pci.pcdi_id = pc_pcdi_id
         and pci.internal_contract_item_ref_no = pc_int_cont_item_ref_no
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vn_total_quantity              number;
    vn_qty_to_be_priced            number;
    vn_total_contract_value        number;
    vn_average_price               number;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(15);
    vd_shipment_date               date;
    vd_arrival_date                date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vd_3rd_wed_of_qp               date;
    vc_holiday                     char(1);
    vn_after_qp_price              number;
    vc_after_qp_price_unit_id      varchar2(10);
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_set_price      number;
    vn_during_total_val_price      number;
    vn_count_set_qp                number;
    vn_count_val_qp                number;
    vn_workings_days               number;
    vd_quotes_date                 date;
    vn_after_count                 number;
    vn_after_price                 number;
    vn_during_qp_price             number;
    vc_after_price_dr_id           varchar2(15);
    vc_during_price_dr_id          varchar2(15);
    vc_during_qp_price_unit_id     varchar2(15);
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value  number;
    vn_anyday_price_ufix_qty_value number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_no_of_trading_days          number;
  begin
    for cur_pcdi_rows in cur_pcdi
    loop
      vn_total_contract_value := 0;
      if cur_pcdi_rows.price_option_call_off_status in
         ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id)
        loop
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_called_off_rows.price_value;
            vn_total_quantity       := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_called_off_rows.price_unit_id;
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.is_qp_any_day_basis,
                               pofh.qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id,
                               pofh.no_of_prompt_days
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail     pcbpd,
                               ppfh_phy_price_formula_header  ppfh,
                               pfqpp_phy_formula_qp_pricing   pfqpp,
                               pofh_price_opt_fixation_header pofh,
                               v_ppu_pum                      ppu
                         where poch.poch_id = pocd.poch_id
                           and pocd.pcbpd_id = pcbpd.pcbpd_id
                           and pcbpd.pcbpd_id = ppfh.pcbpd_id
                           and ppfh.ppfh_id = pfqpp.ppfh_id
                           and pocd.pocd_id = pofh.pocd_id(+)
                           and pcbpd.pcbpd_id = cur_called_off_rows.pcbpd_id
                           and poch.poch_id = cur_called_off_rows.poch_id
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and poch.is_active = 'Y'
                           and pocd.is_active = 'Y'
                           and pcbpd.is_active = 'Y'
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                        -- and pofh.is_active(+) = 'Y'
                        )
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
              if cc1.qp_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Month' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                  when others then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                end;
              else
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'After QP' then
                vn_after_price := 0;
                vn_after_count := 0;
                for pfd_price in (select pfd.user_price,
                                         pfd.price_unit_id
                                    from poch_price_opt_call_off_header poch,
                                         pocd_price_option_calloff_dtls pocd,
                                         pofh_price_opt_fixation_header pofh,
                                         pfd_price_fixation_details     pfd
                                   where poch.poch_id = pocd.poch_id
                                     and pocd.pocd_id = pofh.pocd_id
                                     and pfd.pofh_id = cc1.pofh_id
                                     and pofh.pofh_id = pfd.pofh_id
                                     and poch.is_active = 'Y'
                                     and pocd.is_active = 'Y'
                                     and pofh.is_active = 'Y'
                                     and pfd.is_active = 'Y')
                loop
                  vn_after_price            := vn_after_price +
                                               pfd_price.user_price;
                  vn_after_count            := vn_after_count + 1;
                  vc_after_qp_price_unit_id := pfd_price.price_unit_id;
                end loop;
                if vn_after_count = 0 then
                  vn_after_qp_price       := 0;
                  vn_total_contract_value := 0;
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                else
                  vn_after_qp_price       := vn_after_price /
                                             vn_after_count;
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_after_qp_price;
                  vc_price_unit_id        := vc_after_qp_price_unit_id;
                end if;
              elsif vc_period = 'During QP' then
                vd_dur_qp_start_date          := vd_qp_start_date;
                vd_dur_qp_end_date            := vd_qp_end_date;
                vn_during_total_set_price     := 0;
                vn_count_set_qp               := 0;
                vn_any_day_price_fix_qty_value := 0;
                vn_any_day_fixed_qty          := 0;
                for cc in (select pfd.user_price,
                                  pfd.qty_fixed
                             from poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd
                            where poch.poch_id = pocd.poch_id
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.pofh_id = cc1.pofh_id
                              and pofh.pofh_id = pfd.pofh_id
                              and pfd.as_of_date >= vd_dur_qp_start_date
                              and pfd.as_of_date <= pd_trade_date
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pofh.is_active = 'Y'
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price     := vn_during_total_set_price +
                                                   cc.user_price;
                  vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                                   (cc.user_price *
                                                   cc.qty_fixed);
                  vn_any_day_fixed_qty          := vn_any_day_fixed_qty +
                                                   cc.qty_fixed;
                  vn_count_set_qp               := vn_count_set_qp + 1;
                end loop;
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_val_price,
                         vc_during_val_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_during_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                              and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_during_val_price         := 0;
                    vc_during_val_price_unit_id := null;
                end;
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
                if vn_market_flag = 'N' then
                  vn_during_total_val_price      := vn_during_total_val_price +
                                                    vn_during_val_price;
                  vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                else
                  /*  WHILE vd_dur_qp_start_date <=
                        vd_dur_qp_end_date LOOP
                      IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_dur_qp_start_date) THEN
                          vc_holiday := 'Y';
                      ELSE
                          vc_holiday := 'N';
                      END IF;
                      IF vc_holiday = 'N' THEN
                          vn_during_total_val_price := vn_during_total_val_price +
                                                       vn_during_val_price;
                          vn_count_val_qp           := vn_count_val_qp + 1;
                      END IF;
                      vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                  END LOOP;*/
                  vn_no_of_trading_days:=pkg_general.f_get_instrument_trading_days(cur_pcdi_rows.instrument_id,
                                                                                   vd_qp_start_date,
                                                                                   vd_qp_end_date);


                  vn_count_val_qp           := vn_no_of_trading_days -
                                               vn_count_set_qp;
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price *
                                               vn_count_val_qp;

                end if;
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                          vn_anyday_price_ufix_qty_value) /
                                          cc1.qty_to_be_fixed;
                  else
                    vn_during_qp_price := (vn_during_total_set_price +
                                          vn_during_total_val_price) /
                                          (vn_count_set_qp +
                                          vn_count_val_qp);
                  end if;
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_during_qp_price;
                else
                  vn_total_quantity       := cur_pcdi_rows.item_qty;
                  vn_total_contract_value := 0;
                end if;
                vc_price_unit_id := cc1.ppu_price_unit_id;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      elsif cur_pcdi_rows.price_option_call_off_status = 'Not Called Off' then
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.internal_contract_item_ref_no)
        loop
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_not_called_off_rows.price_value;
            vn_total_quantity       := cur_pcdi_rows.item_qty;
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id --pum price unit id, as quoted available in this unit only
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id)
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
              if cc1.qp_pricing_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              elsif cc1.qp_pricing_period_type = 'Month' then
                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                    cc1.qp_year;
                vd_qp_end_date   := last_day(vd_qp_start_date);
              elsif cc1.qp_pricing_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_date;
                vd_qp_end_date   := cc1.qp_date;
              elsif cc1.qp_pricing_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_not_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                  when others then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                end;
              else
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                ---- get third wednesday of QP period
                --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'After QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_after_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_after_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_after_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_after_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_after_qp_price,
                         vc_after_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_after_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_after_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_after_qp_price         := 0;
                    vc_after_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_after_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'During QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_qp_price,
                         vc_during_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                      and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_during_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_during_qp_price         := 0;
                    vc_during_qp_price_unit_id := null;
                end;
                vn_total_quantity       := cur_pcdi_rows.item_qty;
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_during_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      end if;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;

  procedure sp_calc_gmr_price(pc_internal_gmr_ref_no varchar2,
                              pd_trade_date          date,
                              pn_price               out number,
                              pc_price_unit_id       out varchar2) is
    cursor cur_gmr is
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.status = 'Active'
                 and grd.is_deleted = 'N'
               --and nvl(grd.inventory_status, 'NA') <> 'Out'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             v_gmr_exchange_details qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Standard'
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and gmr.is_deleted = 'N'
         and pofh.is_active = 'Y'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
      union all
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.pofh_id,
             pd_trade_date eod_trade_date,
             qat.instrument_id,
             ps.price_source_id,
             apm.available_price_id,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             pocd.is_any_day_pricing,
             pofh.qty_to_be_fixed,
             round(pofh.priced_qty, 4) priced_qty,
             pofh.no_of_prompt_days,
             pocd.pcbpd_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.status = 'Active'
              --  and nvl(grd.inventory_status, 'NA') <> 'Out'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             v_gmr_exchange_details qat,
             dim_der_instrument_master dim,
             div_der_instrument_valuation div,
             ps_price_source ps,
             apm_available_price_master apm,
             pum_price_unit_master pum,
             v_der_instrument_price_unit vdip,
             pdc_prompt_delivery_calendar pdc
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Standard'
         and gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
         and qat.instrument_id = dim.instrument_id(+)
         and dim.instrument_id = div.instrument_id(+)
         and div.is_deleted(+) = 'N'
         and div.price_source_id = ps.price_source_id(+)
         and div.available_price_id = apm.available_price_id(+)
         and div.price_unit_id = pum.price_unit_id(+)
         and dim.instrument_id = vdip.instrument_id(+)
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id(+)
         and gmr.is_deleted = 'N'
         and pofh.is_active = 'Y'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(50);
    vd_3rd_wed_of_qp               date;
    workings_days                  number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_total_contract_value        number;
    vn_after_price                 number;
    vn_after_count                 number;
    vn_after_qp_price              number;
    vc_after_qp_price_unit_id      varchar2(15);
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vc_holiday                     char(1);
    vn_during_qp_price             number;
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value  number;
    vn_anyday_price_ufix_qty_value number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_pcbpd_id                    varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value        := 0;
      vn_market_flag                 := null;
      vn_any_day_price_fix_qty_value  := 0;
      vn_anyday_price_ufix_qty_value := 0;
      vn_any_day_unfixed_qty         := 0;
      vn_any_day_fixed_qty           := 0;
      vc_pcbpd_id                    := cur_gmr_rows.pcbpd_id;
      vc_price_unit_id               := null;
      vc_ppu_price_unit_id           := null;
      vd_qp_start_date               := cur_gmr_rows.qp_start_date;
      vd_qp_end_date                 := cur_gmr_rows.qp_end_date;
      if cur_gmr_rows.eod_trade_date >= vd_qp_start_date and
         cur_gmr_rows.eod_trade_date <= vd_qp_end_date then
        vc_period := 'During QP';
      elsif cur_gmr_rows.eod_trade_date < vd_qp_start_date and
            cur_gmr_rows.eod_trade_date < vd_qp_end_date then
        vc_period := 'Before QP';
      elsif cur_gmr_rows.eod_trade_date > vd_qp_start_date and
            cur_gmr_rows.eod_trade_date > vd_qp_end_date then
        vc_period := 'After QP';
      end if;
      begin
        select ppu.product_price_unit_id,
               ppu.price_unit_id
          into vc_ppu_price_unit_id,
               vc_price_unit_id
          from ppfh_phy_price_formula_header ppfh,
               v_ppu_pum                     ppu
         where ppfh.pcbpd_id = vc_pcbpd_id
           and ppfh.price_unit_id = ppu.product_price_unit_id
           and rownum <= 1;
      exception
        when no_data_found then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
        when others then
          vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
          vc_price_unit_id     := cur_gmr_rows.price_unit_id;
      end;
      if vc_period = 'Before QP' then
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
          while true
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
          --- get 3rd wednesday  before QP period
          -- Get the quotation date = Trade Date +2 working Days
          if vd_3rd_wed_of_qp <= pd_trade_date then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_quotes_date) then
                vd_quotes_date := vd_quotes_date + 1;
              else
                workings_days := workings_days + 1;
                if workings_days <> 2 then
                  vd_quotes_date := vd_quotes_date + 1;
                end if;
              end if;
            end loop;
            vd_3rd_wed_of_qp := vd_quotes_date;
          end if;
          begin
            select drm.dr_id
              into vc_before_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vc_before_price_dr_id := null;
          end;
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                          vd_qp_end_date);
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
          begin
            select drm.dr_id
              into vc_before_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vc_before_price_dr_id := null;
          end;
        end if;
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_before_qp_price,
                 vc_before_qp_price_unit_id
            from dq_derivative_quotes        dq,
                 v_dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_before_price_dr_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = vc_price_unit_id
             and dq.corporate_id=cur_gmr_rows.corporate_id
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N'
             and dq.trade_date =
                 (select max(dq.trade_date)
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_gmr_rows.instrument_id
                     and dqd.available_price_id =
                         cur_gmr_rows.available_price_id
                     and dq.price_source_id = cur_gmr_rows.price_source_id
                     and dqd.price_unit_id = vc_price_unit_id
                     and dq.corporate_id=cur_gmr_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date <= pd_trade_date);
        exception
          when no_data_found then
            vn_before_qp_price         := 0;
            vc_before_qp_price_unit_id := null;
        end;
        vn_total_contract_value := vn_total_contract_value +
                                   vn_before_qp_price;
      elsif vc_period = 'After QP' then
        vn_after_price := 0;
        vn_after_count := 0;
        for pfd_price in (select pfd.user_price,
                                 pfd.price_unit_id
                            from poch_price_opt_call_off_header poch,
                                 pocd_price_option_calloff_dtls pocd,
                                 pofh_price_opt_fixation_header pofh,
                                 pfd_price_fixation_details     pfd
                           where poch.poch_id = pocd.poch_id
                             and pocd.pocd_id = pofh.pocd_id
                             and pfd.pofh_id = cur_gmr_rows.pofh_id
                             and pofh.pofh_id = pfd.pofh_id
                             and poch.is_active = 'Y'
                             and pocd.is_active = 'Y'
                             and pofh.is_active = 'Y'
                             and pfd.is_active = 'Y')
        loop
          vn_after_price := vn_after_price + pfd_price.user_price;
          vn_after_count := vn_after_count + 1;
        end loop;
        if vn_after_count = 0 then
          vn_after_qp_price         := 0;
          vn_total_contract_value   := 0;
          vc_after_qp_price_unit_id := null;
        else
          vn_after_qp_price       := vn_after_price / vn_after_count;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_after_qp_price;
        end if;
      elsif vc_period = 'During QP' then
        vd_dur_qp_start_date      := vd_qp_start_date;
        vd_dur_qp_end_date        := vd_qp_end_date;
        vn_during_total_set_price := 0;
        vn_count_set_qp           := 0;
        for cc in (select pfd.user_price,
                          pfd.as_of_date,
                          pfd.qty_fixed,
                          pofh.final_price,
                          pocd.is_any_day_pricing
                     from poch_price_opt_call_off_header poch,
                          pocd_price_option_calloff_dtls pocd,
                          pofh_price_opt_fixation_header pofh,
                          pfd_price_fixation_details     pfd
                    where poch.poch_id = pocd.poch_id
                      and pocd.pocd_id = pofh.pocd_id
                      and pofh.pofh_id = cur_gmr_rows.pofh_id
                      and pofh.pofh_id = pfd.pofh_id
                      and pfd.as_of_date >= vd_dur_qp_start_date
                      and pfd.as_of_date <= pd_trade_date
                      and poch.is_active = 'Y'
                      and pocd.is_active = 'Y'
                      and pofh.is_active = 'Y'
                      and pfd.is_active = 'Y')
        loop
          vn_during_total_set_price := vn_during_total_set_price +
                                       cc.user_price;
          vn_count_set_qp           := vn_count_set_qp + 1;
          vn_any_day_fixed_qty      := vn_any_day_fixed_qty + cc.qty_fixed;
        end loop;
        if cur_gmr_rows.is_any_day_pricing = 'Y' then
          vn_market_flag := 'N';
        else
          vn_market_flag := 'Y';
        end if;
        -- get the third wednes day
        if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
          vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date, 'Wed', 3);
          while true
          loop
            if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                vd_3rd_wed_of_qp) then
              vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
            else
              exit;
            end if;
          end loop;
          --- get 3rd wednesday  before QP period
          -- Get the quotation date = Trade Date +2 working Days
          if vd_3rd_wed_of_qp <= pd_trade_date then
            workings_days  := 0;
            vd_quotes_date := pd_trade_date + 1;
            while workings_days <> 2
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_quotes_date) then
                vd_quotes_date := vd_quotes_date + 1;
              else
                workings_days := workings_days + 1;
                if workings_days <> 2 then
                  vd_quotes_date := vd_quotes_date + 1;
                end if;
              end if;
            end loop;
            vd_3rd_wed_of_qp := vd_quotes_date;
          end if;
          begin
            select drm.dr_id
              into vc_during_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.prompt_date = vd_3rd_wed_of_qp
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vc_during_price_dr_id := null;
          end;
        elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
              cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
          vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                          vd_qp_end_date);
          vc_prompt_month := to_char(vc_prompt_date, 'Mon');
          vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
          begin
            select drm.dr_id
              into vc_during_price_dr_id
              from drm_derivative_master drm
             where drm.instrument_id = cur_gmr_rows.instrument_id
               and drm.period_month = vc_prompt_month
               and drm.period_year = vc_prompt_year
               and rownum <= 1
               and drm.price_point_id is null
               and drm.is_deleted = 'N';
          exception
            when no_data_found then
              vc_during_price_dr_id := null;
          end;
        end if;
        begin
          select dqd.price,
                 dqd.price_unit_id
            into vn_during_val_price,
                 vc_during_val_price_unit_id
            from dq_derivative_quotes        dq,
                 v_dqd_derivative_quote_detail dqd
           where dq.dq_id = dqd.dq_id
             and dqd.dr_id = vc_during_price_dr_id
             and dq.instrument_id = cur_gmr_rows.instrument_id
             and dqd.available_price_id = cur_gmr_rows.available_price_id
             and dq.price_source_id = cur_gmr_rows.price_source_id
             and dqd.price_unit_id = vc_price_unit_id
             and dq.corporate_id=cur_gmr_rows.corporate_id
             and dq.is_deleted = 'N'
             and dqd.is_deleted = 'N'
             and dq.trade_date =
                 (select max(dq.trade_date)
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_gmr_rows.instrument_id
                     and dqd.available_price_id =
                         cur_gmr_rows.available_price_id
                     and dq.price_source_id = cur_gmr_rows.price_source_id
                     and dqd.price_unit_id = vc_price_unit_id
                      and dq.corporate_id=cur_gmr_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date <= pd_trade_date);
        exception
          when no_data_found then
            vn_during_val_price         := 0;
            vc_during_val_price_unit_id := null;
        end;
        vn_during_total_val_price := 0;
        vn_count_val_qp           := 0;
        vd_dur_qp_start_date      := pd_trade_date + 1;
        if vn_market_flag = 'N' then
          vn_during_total_val_price      := vn_during_total_val_price +
                                            vn_during_val_price;
          vn_any_day_unfixed_qty         := cur_gmr_rows.qty_to_be_fixed -
                                            vn_any_day_fixed_qty;
          vn_count_val_qp                := vn_count_val_qp + 1;
          vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                            vn_during_total_val_price);
        else
          /*WHILE vd_dur_qp_start_date <= vd_dur_qp_end_date LOOP
              IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_dur_qp_start_date) THEN
                  vc_holiday := 'Y';
              ELSE
                  vc_holiday := 'N';
              END IF;
              IF vc_holiday = 'N' THEN
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price;
                  vn_count_val_qp           := vn_count_val_qp + 1;
              END IF;
              vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
          END LOOP;*/
          vn_count_val_qp           := cur_gmr_rows.no_of_prompt_days -
                                       vn_count_set_qp;
          vn_during_total_val_price := vn_during_total_val_price +
                                       vn_during_val_price *
                                       vn_count_val_qp;

        end if;
        if (vn_count_val_qp + vn_count_set_qp) <> 0 then
          if vn_market_flag = 'N' then
            vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                  vn_anyday_price_ufix_qty_value) /
                                  cur_gmr_rows.qty_to_be_fixed;
          else
            vn_during_qp_price := (vn_during_total_set_price +
                                  vn_during_total_val_price) /
                                  (vn_count_set_qp + vn_count_val_qp);
          end if;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_during_qp_price;
        else
          vn_total_contract_value := 0;
        end if;
      end if;
    end loop;
    pn_price         := vn_total_contract_value;
    pc_price_unit_id := vc_ppu_price_unit_id;
  end;

  procedure sp_calc_contract_conc_price(pc_int_contract_item_ref_no varchar2,
                                        pc_element_id               varchar2,
                                        pd_trade_date               date,
                                        pn_price                    out number,
                                        pc_price_unit_id            out varchar2) is
    cursor cur_pcdi is
      select pcdi.pcdi_id,
             pcm.corporate_id,
             pcdi.internal_contract_ref_no,
             ceqs.element_id,
             ceqs.payable_qty,
             ceqs.payable_qty_unit_id,
             pcdi.delivery_item_no,
             pcdi.delivery_period_type,
             pcdi.delivery_from_month,
             pcdi.delivery_from_year,
             pcdi.delivery_to_month,
             pcdi.delivery_to_year,
             pcdi.delivery_from_date,
             pcdi.delivery_to_date,
             pd_trade_date eod_trade_date,
             pcdi.basis_type,
             nvl(pcdi.transit_days, 0) transit_days,
             pcdi.qp_declaration_date,
             pci.internal_contract_item_ref_no,
             pcm.contract_ref_no,
             pci.item_qty,
             pci.item_qty_unit_id,
             pcpd.qty_unit_id,
             pcpd.product_id,
             aml.underlying_product_id,
             tt.instrument_id,
             akc.base_cur_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable
        from pcdi_pc_delivery_item pcdi,
             v_contract_payable_qty ceqs,
             pci_physical_contract_item pci,
             pcm_physical_contract_main pcm,
             ak_corporate akc,
             pcpd_pc_product_definition pcpd,
             pcpq_pc_product_quality pcpq,
             aml_attribute_master_list aml,
             (select qat.internal_contract_item_ref_no,
                     qat.element_id,
                     qat.instrument_id,
                     dim.instrument_name,
                     ps.price_source_id,
                     ps.price_source_name,
                     apm.available_price_id,
                     apm.available_price_name,
                     pum.price_unit_name,
                     vdip.ppu_price_unit_id,
                     div.price_unit_id,
                     dim.delivery_calender_id,
                     pdc.is_daily_cal_applicable,
                     pdc.is_monthly_cal_applicable
                from v_contract_exchange_detail   qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id) tt
       where pcdi.pcdi_id = pci.pcdi_id
         and pci.internal_contract_item_ref_no =
             ceqs.internal_contract_item_ref_no
         and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
         and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
         and pci.pcpq_id = pcpq.pcpq_id
         and pcm.corporate_id = akc.corporate_id
         and pcm.contract_status = 'In Position'
         and pcm.contract_type = 'CONCENTRATES'
         and ceqs.element_id = aml.attribute_id
         and ceqs.internal_contract_item_ref_no =
             tt.internal_contract_item_ref_no(+)
         and ceqs.element_id = tt.element_id(+)
         and pci.item_qty > 0
         and ceqs.payable_qty > 0
         and pcpd.is_active = 'Y'
         and pcpq.is_active = 'Y'
         and pcdi.is_active = 'Y'
         and pci.is_active = 'Y'
         and pcm.is_active = 'Y'
         and pci.internal_contract_item_ref_no =
             pc_int_contract_item_ref_no
         and ceqs.element_id = pc_element_id;
    cursor cur_called_off(pc_pcdi_id varchar2, pc_element_id varchar2) is
      select poch.poch_id,
             poch.internal_action_ref_no,
             pocd.pricing_formula_id,
             pcbpd.pcbpd_id,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where poch.pcdi_id = pc_pcdi_id
         and pcbpd.element_id = pc_element_id
         and poch.poch_id = pocd.poch_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and poch.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    cursor cur_not_called_off(pc_pcdi_id varchar2, pc_element_id varchar2, pc_int_cont_item_ref_no varchar2) is
      select pcbpd.pcbpd_id,
             pcbph.internal_contract_ref_no,
             pcbpd.price_basis,
             pcbpd.price_value,
             pcbpd.price_unit_id,
             pcbpd.tonnage_basis,
             pcbpd.fx_to_base,
             pcbpd.qty_to_be_priced,
             pcbph.price_description
        from pci_physical_contract_item pci,
             pcipf_pci_pricing_formula  pcipf,
             pcbph_pc_base_price_header pcbph,
             pcbpd_pc_base_price_detail pcbpd
       where pci.internal_contract_item_ref_no =
             pcipf.internal_contract_item_ref_no
         and pcipf.pcbph_id = pcbph.pcbph_id
         and pcbph.pcbph_id = pcbpd.pcbph_id
         and pci.pcdi_id = pc_pcdi_id
         and pcbpd.element_id = pc_element_id
         and pci.internal_contract_item_ref_no = pc_int_cont_item_ref_no
         and pci.is_active = 'Y'
         and pcipf.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    vn_contract_price              number;
    vc_price_unit_id               varchar2(15);
    vn_total_quantity              number;
    vn_total_contract_value        number;
    vd_shipment_date               date;
    vd_arrival_date                date;
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(20);
    vd_3rd_wed_of_qp               date;
    vn_workings_days               number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_qty_to_be_priced            number;
    vn_after_price                 number;
    vn_after_count                 number;
    vc_after_qp_price_unit_id      varchar2(15);
    vn_after_qp_price              number;
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vn_any_day_price_fix_qty_value  number;
    vn_any_day_fixed_qty           number;
    vn_market_flag                 char(1);
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vn_any_day_unfixed_qty         number;
    vn_anyday_price_ufix_qty_value number;
    vc_holiday                     char(10);
    vn_during_qp_price             number;
    vn_average_price               number;
    vc_after_price_dr_id           varchar2(15);
    vc_during_qp_price_unit_id     varchar2(15);
    vc_price_option_call_off_sts   varchar2(50);
    vc_pcdi_id                     varchar2(15);
    vc_element_id                  varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_no_of_trading_days          number;
  begin
    for cur_pcdi_rows in cur_pcdi
    loop
      vc_pcdi_id    := cur_pcdi_rows.pcdi_id;
      vc_element_id := cur_pcdi_rows.element_id;
      begin
        select dipq.price_option_call_off_status
          into vc_price_option_call_off_sts
          from dipq_delivery_item_payable_qty dipq
         where dipq.pcdi_id = vc_pcdi_id
           and dipq.element_id = vc_element_id
           and dipq.is_active = 'Y';
      exception
        when no_data_found then
          vc_price_option_call_off_sts := null;
      end;
      vn_total_contract_value := 0;
      vd_qp_start_date        := null;
      vd_qp_end_date          := null;
      if vc_price_option_call_off_sts in ('Called Off', 'Not Applicable') then
        for cur_called_off_rows in cur_called_off(cur_pcdi_rows.pcdi_id,
                                                  cur_pcdi_rows.element_id)
        loop
          if cur_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_called_off_rows.price_value;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                            cur_pcdi_rows.payable_qty_unit_id,
                                                                            cur_pcdi_rows.item_qty_unit_id,
                                                                            cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_called_off_rows.price_unit_id;
          elsif cur_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select ppfh.ppfh_id,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id,
                               pocd.qp_period_type,
                               pofh.qp_start_date,
                               pofh.qp_end_date,
                               pfqpp.event_name,
                               pfqpp.no_of_event_months,
                               pfqpp.is_qp_any_day_basis,
                               pofh.qty_to_be_fixed,
                               pofh.priced_qty,
                               pofh.pofh_id,
                               pofh.no_of_prompt_days
                          from poch_price_opt_call_off_header poch,
                               pocd_price_option_calloff_dtls pocd,
                               pcbpd_pc_base_price_detail     pcbpd,
                               ppfh_phy_price_formula_header  ppfh,
                               pfqpp_phy_formula_qp_pricing   pfqpp,
                               pofh_price_opt_fixation_header pofh,
                               v_ppu_pum                      ppu
                         where poch.poch_id = pocd.poch_id
                           and pocd.pcbpd_id = pcbpd.pcbpd_id
                           and pcbpd.pcbpd_id = ppfh.pcbpd_id
                           and ppfh.ppfh_id = pfqpp.ppfh_id
                           and pocd.pocd_id = pofh.pocd_id(+)
                           and pcbpd.pcbpd_id = cur_called_off_rows.pcbpd_id
                           and poch.poch_id = cur_called_off_rows.poch_id
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id
                           and poch.is_active = 'Y'
                           and pocd.is_active = 'Y'
                           and pcbpd.is_active = 'Y'
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                        -- and pofh.is_active(+) = 'Y'
                        )
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
              if cc1.qp_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Month' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              elsif cc1.qp_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                  when others then
                    vd_qp_start_date := cc1.qp_start_date;
                    vd_qp_end_date   := cc1.qp_end_date;
                end;
              else
                vd_qp_start_date := cc1.qp_start_date;
                vd_qp_end_date   := cc1.qp_end_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                              and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'After QP' then
                vn_after_price := 0;
                vn_after_count := 0;
                for pfd_price in (select pfd.user_price,
                                         pfd.price_unit_id
                                    from poch_price_opt_call_off_header poch,
                                         pocd_price_option_calloff_dtls pocd,
                                         pofh_price_opt_fixation_header pofh,
                                         pfd_price_fixation_details     pfd
                                   where poch.poch_id = pocd.poch_id
                                     and pocd.pocd_id = pofh.pocd_id
                                     and pfd.pofh_id = cc1.pofh_id
                                     and pofh.pofh_id = pfd.pofh_id
                                     and poch.is_active = 'Y'
                                     and pocd.is_active = 'Y'
                                     and pofh.is_active = 'Y'
                                     and pfd.is_active = 'Y')
                loop
                  vn_after_price            := vn_after_price +
                                               pfd_price.user_price;
                  vn_after_count            := vn_after_count + 1;
                  vc_after_qp_price_unit_id := pfd_price.price_unit_id;
                end loop;
                if vn_after_count = 0 then
                  vn_after_qp_price       := 0;
                  vn_total_contract_value := 0;
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                else
                  vn_after_qp_price       := vn_after_price /
                                             vn_after_count;
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_after_qp_price;
                  vc_price_unit_id        := vc_after_qp_price_unit_id;
                end if;
              elsif vc_period = 'During QP' then
                vd_dur_qp_start_date          := vd_qp_start_date;
                vd_dur_qp_end_date            := vd_qp_end_date;
                vn_during_total_set_price     := 0;
                vn_count_set_qp               := 0;
                vn_any_day_price_fix_qty_value := 0;
                vn_any_day_fixed_qty          := 0;
                for cc in (select pfd.user_price,
                                  pfd.as_of_date,
                                  pfd.qty_fixed
                             from poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd
                            where poch.poch_id = pocd.poch_id
                              and pocd.pocd_id = pofh.pocd_id
                              and pofh.pofh_id = cc1.pofh_id
                              and pofh.pofh_id = pfd.pofh_id
                              and pfd.as_of_date >= vd_dur_qp_start_date
                              and pfd.as_of_date <= pd_trade_date
                              and poch.is_active = 'Y'
                              and pocd.is_active = 'Y'
                              and pofh.is_active = 'Y'
                              and pfd.is_active = 'Y')
                loop
                  vn_during_total_set_price     := vn_during_total_set_price +
                                                   cc.user_price;
                  vn_any_day_price_fix_qty_value := vn_any_day_price_fix_qty_value +
                                                   (cc.user_price *
                                                   cc.qty_fixed);
                  vn_any_day_fixed_qty          := vn_any_day_fixed_qty +
                                                   cc.qty_fixed;
                  vn_count_set_qp               := vn_count_set_qp + 1;
                end loop;
                if cc1.is_qp_any_day_basis = 'Y' then
                  vn_market_flag := 'N';
                else
                  vn_market_flag := 'Y';
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  -- get the third wednes day
                  vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and rownum <= 1
                       and drm.price_point_id is null
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_val_price,
                         vc_during_val_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_during_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_during_val_price         := 0;
                    vc_during_val_price_unit_id := null;
                end;
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
                if vn_market_flag = 'N' then
                  vn_during_total_val_price      := vn_during_total_val_price +
                                                    vn_during_val_price;
                  vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                    vn_any_day_fixed_qty;
                  vn_count_val_qp                := vn_count_val_qp + 1;
                  vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                                    vn_during_total_val_price);
                else
                  /*WHILE vd_dur_qp_start_date <=
                        vd_dur_qp_end_date LOOP
                      IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_dur_qp_start_date) THEN
                          vc_holiday := 'Y';
                      ELSE
                          vc_holiday := 'N';
                      END IF;
                      IF vc_holiday = 'N' THEN
                          vn_during_total_val_price := vn_during_total_val_price +
                                                       vn_during_val_price;
                          vn_count_val_qp           := vn_count_val_qp + 1;
                      END IF;
                      vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                  END LOOP;*/
                  vn_no_of_trading_days:=pkg_general.f_get_instrument_trading_days(cur_pcdi_rows.instrument_id,
                                                                                   vd_qp_start_date,
                                                                                   vd_qp_end_date);
                  vn_count_val_qp           := vn_no_of_trading_days -
                                               vn_count_set_qp;
                  vn_during_total_val_price := vn_during_total_val_price +
                                               vn_during_val_price *
                                               vn_count_val_qp;

                end if;
                if (vn_count_val_qp + vn_count_set_qp) <> 0 then
                  if vn_market_flag = 'N' then
                    vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                          vn_anyday_price_ufix_qty_value) /
                                          cc1.qty_to_be_fixed;
                  else
                    vn_during_qp_price := (vn_during_total_set_price +
                                          vn_during_total_val_price) /
                                          (vn_count_set_qp +
                                          vn_count_val_qp);
                  end if;
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                  vn_total_contract_value := vn_total_contract_value +
                                             vn_total_quantity *
                                             (vn_qty_to_be_priced / 100) *
                                             vn_during_qp_price;
                  vc_price_unit_id        := cc1.ppu_price_unit_id;
                else
                  vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                  cur_pcdi_rows.payable_qty_unit_id,
                                                                                  cur_pcdi_rows.item_qty_unit_id,
                                                                                  cur_pcdi_rows.payable_qty);
                  vn_total_contract_value := 0;
                  vc_price_unit_id        := cc1.ppu_price_unit_id;
                end if;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      elsif vc_price_option_call_off_sts = 'Not Called Off' then
        for cur_not_called_off_rows in cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.element_id,
                                                          cur_pcdi_rows.internal_contract_item_ref_no)
        loop
          if cur_not_called_off_rows.price_basis = 'Fixed' then
            vn_contract_price       := cur_not_called_off_rows.price_value;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                            cur_pcdi_rows.payable_qty_unit_id,
                                                                            cur_pcdi_rows.item_qty_unit_id,
                                                                            cur_pcdi_rows.payable_qty);
            vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_contract_price;
            vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
          elsif cur_not_called_off_rows.price_basis in ('Index', 'Formula') then
            for cc1 in (select pfqpp.qp_pricing_period_type,
                               pfqpp.qp_period_from_date,
                               pfqpp.qp_period_to_date,
                               pfqpp.qp_month,
                               pfqpp.qp_year,
                               pfqpp.qp_date,
                               ppfh.price_unit_id ppu_price_unit_id,
                               ppu.price_unit_id --pum price unit id, as quoted available in this unit only
                          from ppfh_phy_price_formula_header ppfh,
                               pfqpp_phy_formula_qp_pricing  pfqpp,
                               v_ppu_pum                     ppu
                         where ppfh.ppfh_id = pfqpp.ppfh_id
                           and ppfh.pcbpd_id =
                               cur_not_called_off_rows.pcbpd_id
                           and ppfh.is_active = 'Y'
                           and pfqpp.is_active = 'Y'
                           and ppfh.price_unit_id =
                               ppu.product_price_unit_id)
            loop
              if cur_pcdi_rows.basis_type = 'Shipment' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_shipment_date := last_day('01-' ||
                                               cur_pcdi_rows.delivery_to_month || '-' ||
                                               cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_arrival_date := vd_shipment_date +
                                   cur_pcdi_rows.transit_days;
              elsif cur_pcdi_rows.basis_type = 'Arrival' then
                if cur_pcdi_rows.delivery_period_type = 'Month' then
                  vd_arrival_date := last_day('01-' ||
                                              cur_pcdi_rows.delivery_to_month || '-' ||
                                              cur_pcdi_rows.delivery_to_year);
                elsif cur_pcdi_rows.delivery_period_type = 'Date' then
                  vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                end if;
                vd_shipment_date := vd_arrival_date -
                                    cur_pcdi_rows.transit_days;
              end if;
              if cc1.qp_pricing_period_type = 'Period' then
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              elsif cc1.qp_pricing_period_type = 'Month' then
                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                    cc1.qp_year;
                vd_qp_end_date   := last_day(vd_qp_start_date);
              elsif cc1.qp_pricing_period_type = 'Date' then
                vd_qp_start_date := cc1.qp_date;
                vd_qp_end_date   := cc1.qp_date;
              elsif cc1.qp_pricing_period_type = 'Event' then
                begin
                  select dieqp.expected_qp_start_date,
                         dieqp.expected_qp_end_date
                    into vd_qp_start_date,
                         vd_qp_end_date
                    from di_del_item_exp_qp_details dieqp
                   where dieqp.pcdi_id = cur_pcdi_rows.pcdi_id
                     and dieqp.pcbpd_id = cur_not_called_off_rows.pcbpd_id
                     and dieqp.is_active = 'Y';
                exception
                  when no_data_found then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                  when others then
                    vd_qp_start_date := cc1.qp_period_from_date;
                    vd_qp_end_date   := cc1.qp_period_to_date;
                end;
              else
                vd_qp_start_date := cc1.qp_period_from_date;
                vd_qp_end_date   := cc1.qp_period_to_date;
              end if;
              if cur_pcdi_rows.eod_trade_date >= vd_qp_start_date and
                 cur_pcdi_rows.eod_trade_date <= vd_qp_end_date then
                vc_period := 'During QP';
              elsif cur_pcdi_rows.eod_trade_date < vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date < vd_qp_end_date then
                vc_period := 'Before QP';
              elsif cur_pcdi_rows.eod_trade_date > vd_qp_start_date and
                    cur_pcdi_rows.eod_trade_date > vd_qp_end_date then
                vc_period := 'After QP';
              end if;
              if vc_period = 'Before QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  ---- get third wednesday of QP period
                  --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_before_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_before_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_before_qp_price,
                         vc_before_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_before_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_before_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                              and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_before_qp_price         := 0;
                    vc_before_qp_price_unit_id := null;
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_before_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'After QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_after_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_after_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_after_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_after_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_after_qp_price,
                         vc_after_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_after_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                     and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_after_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_after_qp_price         := 0;
                    vc_after_qp_price_unit_id := null;
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_after_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              elsif vc_period = 'During QP' then
                if cur_pcdi_rows.is_daily_cal_applicable = 'Y' then
                  vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                     'Wed',
                                                     3);
                  while true
                  loop
                    if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                        vd_3rd_wed_of_qp) then
                      vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                    else
                      exit;
                    end if;
                  end loop;
                  --- get 3rd wednesday  before QP period
                  -- Get the quotation date = Trade Date +2 working Days
                  if vd_3rd_wed_of_qp <= pd_trade_date then
                    vn_workings_days := 0;
                    vd_quotes_date   := pd_trade_date + 1;
                    while vn_workings_days <> 2
                    loop
                      if f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                          vd_quotes_date) then
                        vd_quotes_date := vd_quotes_date + 1;
                      else
                        vn_workings_days := vn_workings_days + 1;
                        if vn_workings_days <> 2 then
                          vd_quotes_date := vd_quotes_date + 1;
                        end if;
                      end if;
                    end loop;
                    vd_3rd_wed_of_qp := vd_quotes_date;
                  end if;
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.prompt_date = vd_3rd_wed_of_qp
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                if cur_pcdi_rows.is_daily_cal_applicable = 'N' and
                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' then
                  vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                  vd_qp_end_date);
                  vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                  vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                  begin
                    select drm.dr_id
                      into vc_during_price_dr_id
                      from drm_derivative_master drm
                     where drm.instrument_id = cur_pcdi_rows.instrument_id
                       and drm.period_month = vc_prompt_month
                       and drm.period_year = vc_prompt_year
                       and drm.price_point_id is null
                       and rownum <= 1
                       and drm.is_deleted = 'N';
                  exception
                    when no_data_found then
                      vc_during_price_dr_id := null;
                  end;
                end if;
                begin
                  select dqd.price,
                         dqd.price_unit_id
                    into vn_during_qp_price,
                         vc_during_qp_price_unit_id
                    from dq_derivative_quotes        dq,
                         v_dqd_derivative_quote_detail dqd
                   where dq.dq_id = dqd.dq_id
                     and dqd.dr_id = vc_during_price_dr_id
                     and dq.instrument_id = cur_pcdi_rows.instrument_id
                     and dqd.available_price_id =
                         cur_pcdi_rows.available_price_id
                     and dq.price_source_id = cur_pcdi_rows.price_source_id
                     and dqd.price_unit_id = cc1.price_unit_id
                      and dq.corporate_id=cur_pcdi_rows.corporate_id
                     and dq.is_deleted = 'N'
                     and dqd.is_deleted = 'N'
                     and dq.trade_date =
                         (select max(dq.trade_date)
                            from dq_derivative_quotes        dq,
                                 v_dqd_derivative_quote_detail dqd
                           where dq.dq_id = dqd.dq_id
                             and dqd.dr_id = vc_during_price_dr_id
                             and dq.instrument_id =
                                 cur_pcdi_rows.instrument_id
                             and dqd.available_price_id =
                                 cur_pcdi_rows.available_price_id
                             and dq.price_source_id =
                                 cur_pcdi_rows.price_source_id
                             and dqd.price_unit_id = cc1.price_unit_id
                             and dq.corporate_id=cur_pcdi_rows.corporate_id
                             and dq.is_deleted = 'N'
                             and dqd.is_deleted = 'N'
                             and dq.trade_date <= pd_trade_date);
                exception
                  when no_data_found then
                    vn_during_qp_price         := 0;
                    vc_during_qp_price_unit_id := null;
                end;
                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                cur_pcdi_rows.payable_qty);
                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_total_quantity *
                                           (vn_qty_to_be_priced / 100) *
                                           vn_during_qp_price;
                vc_price_unit_id        := cc1.ppu_price_unit_id;
              end if;
            end loop;
          end if;
        end loop;
        vn_average_price := round(vn_total_contract_value /
                                  vn_total_quantity,
                                  3);
      end if;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_price_unit_id;
  end;

  procedure sp_calc_conc_gmr_price(pc_internal_gmr_ref_no varchar2,
                                   pc_element_id          varchar2,
                                   pd_trade_date          date,
                                   pn_price               out number,
                                   pc_price_unit_id       out varchar2) is
    cursor cur_gmr is
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             gmr.qty_unit_id,
             grd.product_id,
             pd_trade_date eod_trade_date,
             tt.instrument_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable,
             spq.element_id,
             spq.payable_qty,
             spq.qty_unit_id payable_qty_unit_id
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from grd_goods_record_detail grd
               where grd.status = 'Active'
                 and grd.is_deleted = 'N'
                -- and nvl(grd.inventory_status, 'NA') <> 'Out'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             V_GMR_PAYABLE_QTY spq,
             (select qat.internal_gmr_ref_no,
                     qat.instrument_id,
                     qat.element_id,
                     dim.instrument_name,
                     ps.price_source_id,
                     ps.price_source_name,
                     apm.available_price_id,
                     apm.available_price_name,
                     pum.price_unit_name,
                     vdip.ppu_price_unit_id,
                     div.price_unit_id,
                     dim.delivery_calender_id,
                     pdc.is_daily_cal_applicable,
                     pdc.is_monthly_cal_applicable
                from v_gmr_exchange_details       qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id) tt
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdtm.product_type_name = 'Composite'
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.is_deleted = 'N'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and spq.element_id = pc_element_id
      union all
      select gmr.corporate_id,
             gmr.internal_gmr_ref_no,
             gmr.gmr_ref_no,
             gmr.current_qty,
             gmr.qty_unit_id,
             grd.product_id,
             pd_trade_date eod_trade_date,
             tt.instrument_id,
             tt.instrument_name,
             tt.price_source_id,
             tt.price_source_name,
             tt.available_price_id,
             tt.available_price_name,
             tt.price_unit_name,
             tt.ppu_price_unit_id,
             tt.price_unit_id,
             tt.delivery_calender_id,
             tt.is_daily_cal_applicable,
             tt.is_monthly_cal_applicable,
             spq.element_id,
             spq.payable_qty,
             spq.qty_unit_id payable_qty_unit_id
        from gmr_goods_movement_record gmr,
             (select grd.internal_gmr_ref_no,
                     grd.quality_id,
                     grd.product_id
                from dgrd_delivered_grd grd
               where grd.status = 'Active'
                -- and nvl(grd.inventory_status, 'NA') <> 'Out'
               group by grd.internal_gmr_ref_no,
                        grd.quality_id,
                        grd.product_id) grd,
             pdm_productmaster pdm,
             pdtm_product_type_master pdtm,
             V_GMR_PAYABLE_QTY spq,
             (select qat.internal_gmr_ref_no,
                     qat.instrument_id,
                     qat.element_id,
                     dim.instrument_name,
                     ps.price_source_id,
                     ps.price_source_name,
                     apm.available_price_id,
                     apm.available_price_name,
                     pum.price_unit_name,
                     vdip.ppu_price_unit_id,
                     div.price_unit_id,
                     dim.delivery_calender_id,
                     pdc.is_daily_cal_applicable,
                     pdc.is_monthly_cal_applicable
                from v_gmr_exchange_details       qat,
                     dim_der_instrument_master    dim,
                     div_der_instrument_valuation div,
                     ps_price_source              ps,
                     apm_available_price_master   apm,
                     pum_price_unit_master        pum,
                     v_der_instrument_price_unit  vdip,
                     pdc_prompt_delivery_calendar pdc
               where qat.instrument_id = dim.instrument_id
                 and dim.instrument_id = div.instrument_id
                 and div.is_deleted = 'N'
                 and div.price_source_id = ps.price_source_id
                 and div.available_price_id = apm.available_price_id
                 and div.price_unit_id = pum.price_unit_id
                 and dim.instrument_id = vdip.instrument_id
                 and dim.delivery_calender_id =
                     pdc.prompt_delivery_calendar_id) tt
       where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
         and grd.product_id = pdm.product_id
         and pdm.product_type_id = pdtm.product_type_id
         and pdm.product_type_id = 'Composite'
         and tt.element_id = spq.element_id
         and tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
         and gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
         and gmr.is_deleted = 'N'
         and gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and spq.element_id = pc_element_id;
    cursor cur_gmr_ele(pc_internal_gmr_ref_no varchar2, pc_element_id varchar2) is
      select pofh.internal_gmr_ref_no,
             pofh.pofh_id,
             pofh.qp_start_date,
             pofh.qp_end_date,
             pofh.qty_to_be_fixed,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pocd.is_any_day_pricing,
             pcbpd.price_basis,
             pcbph.price_description,
             pofh.no_of_prompt_days
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph
       where pofh.internal_gmr_ref_no = pc_internal_gmr_ref_no
         and pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pcbpd.element_id = pc_element_id
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and pcbph.is_active = 'Y';
    vd_qp_start_date               date;
    vd_qp_end_date                 date;
    vc_period                      varchar2(50);
    vd_3rd_wed_of_qp               date;
    vn_workings_days               number;
    vd_quotes_date                 date;
    vc_before_price_dr_id          varchar2(15);
    vn_before_qp_price             number;
    vc_before_qp_price_unit_id     varchar2(15);
    vn_total_contract_value        number;
    vn_after_price                 number;
    vn_after_count                 number;
    vn_after_qp_price              number;
    vc_after_qp_price_unit_id      varchar2(15);
    vd_dur_qp_start_date           date;
    vd_dur_qp_end_date             date;
    vn_during_total_set_price      number;
    vn_count_set_qp                number;
    vc_during_price_dr_id          varchar2(15);
    vn_during_val_price            number;
    vc_during_val_price_unit_id    varchar2(15);
    vn_during_total_val_price      number;
    vn_count_val_qp                number;
    vc_holiday                     char(1);
    vn_during_qp_price             number;
    vn_market_flag                 char(1);
    vn_any_day_price_fix_qty_value  number;
    vn_anyday_price_ufix_qty_value number;
    vn_any_day_unfixed_qty         number;
    vn_any_day_fixed_qty           number;
    vc_price_unit_id               varchar2(15);
    vc_ppu_price_unit_id           varchar2(15);
    vc_price_name                  varchar2(100);
    vc_pcbpd_id                    varchar2(15);
    vc_prompt_month                varchar2(15);
    vc_prompt_year                 number;
    vc_prompt_date                 date;
    vn_qty_to_be_priced            number;
    vn_total_quantity              number;
    vn_average_price               number;
  begin
    for cur_gmr_rows in cur_gmr
    loop
      vn_total_contract_value := 0;
      for cur_gmr_ele_rows in cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                          cur_gmr_rows.element_id)
      loop
        vn_market_flag                 := null;
        vn_any_day_price_fix_qty_value  := 0;
        vn_anyday_price_ufix_qty_value := 0;
        vn_any_day_unfixed_qty         := 0;
        vn_any_day_fixed_qty           := 0;
        vc_pcbpd_id                    := cur_gmr_ele_rows.pcbpd_id;
        vc_price_unit_id               := null;
        vc_ppu_price_unit_id           := null;
        vd_qp_start_date               := cur_gmr_ele_rows.qp_start_date;
        vd_qp_end_date                 := cur_gmr_ele_rows.qp_end_date;
        if cur_gmr_rows.eod_trade_date >= vd_qp_start_date and
           cur_gmr_rows.eod_trade_date <= vd_qp_end_date then
          vc_period := 'During QP';
        elsif cur_gmr_rows.eod_trade_date < vd_qp_start_date and
              cur_gmr_rows.eod_trade_date < vd_qp_end_date then
          vc_period := 'Before QP';
        elsif cur_gmr_rows.eod_trade_date > vd_qp_start_date and
              cur_gmr_rows.eod_trade_date > vd_qp_end_date then
          vc_period := 'After QP';
        end if;
        begin
          select ppu.product_price_unit_id,
                 ppu.price_unit_id,
                 ppu.price_unit_name
            into vc_ppu_price_unit_id,
                 vc_price_unit_id,
                 vc_price_name
            from ppfh_phy_price_formula_header ppfh,
                 v_ppu_pum                     ppu
           where ppfh.pcbpd_id = vc_pcbpd_id
             and ppfh.price_unit_id = ppu.product_price_unit_id
             and rownum <= 1;
        exception
          when no_data_found then
            vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
            vc_price_unit_id     := cur_gmr_rows.price_unit_id;
            vc_price_name        := cur_gmr_rows.price_unit_name;
          when others then
            vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
            vc_price_unit_id     := cur_gmr_rows.price_unit_id;
            vc_price_name        := cur_gmr_rows.price_unit_name;
        end;
        if vc_period = 'Before QP' then
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
            while true
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_3rd_wed_of_qp) then
                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
              else
                exit;
              end if;
            end loop;
            --- get 3rd wednesday  before QP period
            -- Get the quotation date = Trade Date +2 working Days
            if vd_3rd_wed_of_qp <= pd_trade_date then
              vn_workings_days := 0;
              vd_quotes_date   := pd_trade_date + 1;
              while vn_workings_days <> 2
              loop
                if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                    vd_quotes_date) then
                  vd_quotes_date := vd_quotes_date + 1;
                else
                  vn_workings_days := vn_workings_days + 1;
                  if vn_workings_days <> 2 then
                    vd_quotes_date := vd_quotes_date + 1;
                  end if;
                end if;
              end loop;
              vd_3rd_wed_of_qp := vd_quotes_date;
            end if;
            ---- get the dr_id
            begin
              select drm.dr_id
                into vc_before_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.prompt_date = vd_3rd_wed_of_qp
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vc_before_price_dr_id := null;
            end;
          elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
                cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                            vd_qp_end_date);
            vc_prompt_month := to_char(vc_prompt_date, 'Mon');
            vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
            ---- get the dr_id
            begin
              select drm.dr_id
                into vc_before_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.period_month = vc_prompt_month
                 and drm.period_year = vc_prompt_year
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vc_before_price_dr_id := null;
            end;
          end if;
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_before_qp_price,
                   vc_before_qp_price_unit_id
              from dq_derivative_quotes        dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_before_price_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = vc_price_unit_id
               and dq.corporate_id=cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes        dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_before_price_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = vc_price_unit_id
                       and dq.corporate_id=cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_before_qp_price         := 0;
              vc_before_qp_price_unit_id := null;
          end;
          vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                          cur_gmr_rows.payable_qty_unit_id,
                                                                          cur_gmr_rows.qty_unit_id,
                                                                          cur_gmr_rows.payable_qty);
          vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
          vn_total_contract_value := vn_total_contract_value +
                                     vn_total_quantity *
                                     (vn_qty_to_be_priced / 100) *
                                     vn_before_qp_price;
        elsif vc_period = 'After QP' then
          vn_after_price := 0;
          vn_after_count := 0;
          for pfd_price in (select pfd.user_price,
                                   pfd.price_unit_id,
                                   pofh.final_price
                              from poch_price_opt_call_off_header poch,
                                   pocd_price_option_calloff_dtls pocd,
                                   pofh_price_opt_fixation_header pofh,
                                   pfd_price_fixation_details     pfd
                             where poch.poch_id = pocd.poch_id
                               and pocd.pocd_id = pofh.pocd_id
                               and pfd.pofh_id = cur_gmr_ele_rows.pofh_id
                               and pofh.pofh_id = pfd.pofh_id
                               and poch.is_active = 'Y'
                               and pocd.is_active = 'Y'
                               and pofh.is_active = 'Y'
                               and pfd.is_active = 'Y')
          loop
            vn_after_price := vn_after_price + pfd_price.user_price;
            vn_after_count := vn_after_count + 1;
          end loop;
          if vn_after_count = 0 then
            vn_after_qp_price         := 0;
            vn_total_contract_value   := 0;
            vc_after_qp_price_unit_id := null;
            vn_total_quantity         := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                              cur_gmr_rows.payable_qty_unit_id,
                                                                              cur_gmr_rows.qty_unit_id,
                                                                              cur_gmr_rows.payable_qty);
          else
            vn_after_qp_price       := vn_after_price / vn_after_count;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                            cur_gmr_rows.payable_qty_unit_id,
                                                                            cur_gmr_rows.qty_unit_id,
                                                                            cur_gmr_rows.payable_qty);
            vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_after_price;
          end if;
        elsif vc_period = 'During QP' then
          vd_dur_qp_start_date      := vd_qp_start_date;
          vd_dur_qp_end_date        := vd_qp_end_date;
          vn_during_total_set_price := 0;
          vn_count_set_qp           := 0;
          for cc in (select pfd.user_price,
                            pfd.as_of_date,
                            pfd.qty_fixed,
                            pofh.final_price,
                            pocd.is_any_day_pricing
                       from poch_price_opt_call_off_header poch,
                            pocd_price_option_calloff_dtls pocd,
                            pofh_price_opt_fixation_header pofh,
                            pfd_price_fixation_details     pfd
                      where poch.poch_id = pocd.poch_id
                        and pocd.pocd_id = pofh.pocd_id
                        and pofh.pofh_id = cur_gmr_ele_rows.pofh_id
                        and pofh.pofh_id = pfd.pofh_id
                        and pfd.as_of_date >= vd_dur_qp_start_date
                        and pfd.as_of_date <= pd_trade_date
                        and poch.is_active = 'Y'
                        and pocd.is_active = 'Y'
                        and pofh.is_active = 'Y'
                        and pfd.is_active = 'Y')
          loop
            vn_during_total_set_price := vn_during_total_set_price +
                                         cc.user_price;
            vn_count_set_qp           := vn_count_set_qp + 1;
            vn_any_day_fixed_qty      := vn_any_day_fixed_qty +
                                         cc.qty_fixed;
          end loop;
          if cur_gmr_ele_rows.is_any_day_pricing = 'Y' then
            vn_market_flag := 'N';
          else
            vn_market_flag := 'Y';
          end if;
          if cur_gmr_rows.is_daily_cal_applicable = 'Y' then
            -- get the third wednes day
            vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date, 'Wed', 3);
            while true
            loop
              if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                  vd_3rd_wed_of_qp) then
                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
              else
                exit;
              end if;
            end loop;
            --- get 3rd wednesday  before QP period
            -- Get the quotation date = Trade Date +2 working Days
            if vd_3rd_wed_of_qp <= pd_trade_date then
              vn_workings_days := 0;
              vd_quotes_date   := pd_trade_date + 1;
              while vn_workings_days <> 2
              loop
                if f_is_day_holiday(cur_gmr_rows.instrument_id,
                                    vd_quotes_date) then
                  vd_quotes_date := vd_quotes_date + 1;
                else
                  vn_workings_days := vn_workings_days + 1;
                  if vn_workings_days <> 2 then
                    vd_quotes_date := vd_quotes_date + 1;
                  end if;
                end if;
              end loop;
              vd_3rd_wed_of_qp := vd_quotes_date;
            end if;
            begin
              select drm.dr_id
                into vc_during_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.prompt_date = vd_3rd_wed_of_qp
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vc_during_price_dr_id := null;
            end;
          elsif cur_gmr_rows.is_daily_cal_applicable = 'N' and
                cur_gmr_rows.is_monthly_cal_applicable = 'Y' then
            vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                            vd_qp_end_date);
            vc_prompt_month := to_char(vc_prompt_date, 'Mon');
            vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
            ---- get the dr_id
            begin
              select drm.dr_id
                into vc_during_price_dr_id
                from drm_derivative_master drm
               where drm.instrument_id = cur_gmr_rows.instrument_id
                 and drm.period_month = vc_prompt_month
                 and drm.period_year = vc_prompt_year
                 and rownum <= 1
                 and drm.price_point_id is null
                 and drm.is_deleted = 'N';
            exception
              when no_data_found then
                vc_during_price_dr_id := null;
            end;
          end if;
          begin
            select dqd.price,
                   dqd.price_unit_id
              into vn_during_val_price,
                   vc_during_val_price_unit_id
              from dq_derivative_quotes        dq,
                   v_dqd_derivative_quote_detail dqd
             where dq.dq_id = dqd.dq_id
               and dqd.dr_id = vc_during_price_dr_id
               and dq.instrument_id = cur_gmr_rows.instrument_id
               and dqd.available_price_id = cur_gmr_rows.available_price_id
               and dq.price_source_id = cur_gmr_rows.price_source_id
               and dqd.price_unit_id = vc_price_unit_id
               and dq.corporate_id=cur_gmr_rows.corporate_id
               and dq.is_deleted = 'N'
               and dqd.is_deleted = 'N'
               and dq.trade_date =
                   (select max(dq.trade_date)
                      from dq_derivative_quotes        dq,
                           v_dqd_derivative_quote_detail dqd
                     where dq.dq_id = dqd.dq_id
                       and dqd.dr_id = vc_during_price_dr_id
                       and dq.instrument_id = cur_gmr_rows.instrument_id
                       and dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                       and dq.price_source_id = cur_gmr_rows.price_source_id
                       and dqd.price_unit_id = vc_price_unit_id
                       and dq.corporate_id=cur_gmr_rows.corporate_id
                       and dq.is_deleted = 'N'
                       and dqd.is_deleted = 'N'
                       and dq.trade_date <= pd_trade_date);
          exception
            when no_data_found then
              vn_during_val_price         := 0;
              vc_during_val_price_unit_id := null;
          end;
          vn_during_total_val_price := 0;
          vn_count_val_qp           := 0;
          vd_dur_qp_start_date      := pd_trade_date + 1;
          if vn_market_flag = 'N' then
            vn_during_total_val_price      := vn_during_total_val_price +
                                              vn_during_val_price;
            vn_any_day_unfixed_qty         := cur_gmr_ele_rows.qty_to_be_fixed -
                                              vn_any_day_fixed_qty;
            vn_count_val_qp                := vn_count_val_qp + 1;
            vn_anyday_price_ufix_qty_value := (vn_any_day_unfixed_qty *
                                              vn_during_total_val_price);
          else
            /*WHILE vd_dur_qp_start_date <= vd_dur_qp_end_date LOOP
                IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                    vd_dur_qp_start_date) THEN
                    vc_holiday := 'Y';
                ELSE
                    vc_holiday := 'N';
                END IF;
                IF vc_holiday = 'N' THEN
                    vn_during_total_val_price := vn_during_total_val_price +
                                                 vn_during_val_price;
                    vn_count_val_qp           := vn_count_val_qp + 1;
                END IF;
                vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
            END LOOP;*/
            vn_count_val_qp           := cur_gmr_ele_rows.no_of_prompt_days -
                                         vn_count_set_qp;
            vn_during_total_val_price := vn_during_total_val_price +
                                         vn_during_val_price *
                                         vn_count_val_qp;

          end if;
          if (vn_count_val_qp + vn_count_set_qp) <> 0 then
            if vn_market_flag = 'N' then
              vn_during_qp_price := (vn_any_day_price_fix_qty_value +
                                    vn_anyday_price_ufix_qty_value) /
                                    cur_gmr_ele_rows.qty_to_be_fixed;
            else
              vn_during_qp_price := (vn_during_total_set_price +
                                    vn_during_total_val_price) /
                                    (vn_count_set_qp + vn_count_val_qp);
            end if;
            vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                            cur_gmr_rows.payable_qty_unit_id,
                                                                            cur_gmr_rows.qty_unit_id,
                                                                            cur_gmr_rows.payable_qty);
            vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
            vn_total_contract_value := vn_total_contract_value +
                                       vn_total_quantity *
                                       (vn_qty_to_be_priced / 100) *
                                       vn_during_qp_price;
          else
            vn_total_contract_value := 0;
          end if;
        end if;
      end loop;
      DBMS_OUTPUT.put_line('cur_gmr_rows.payable_qty '||cur_gmr_rows.payable_qty || ' cont value ' || vn_total_contract_value ||' qty '|| vn_total_quantity);
    IF vn_total_quantity=0 THEN
      vn_average_price := 0;
     ELSE
     vn_average_price := round(vn_total_contract_value / vn_total_quantity,
                                3);
     END IF;
    end loop;
    pn_price         := vn_average_price;
    pc_price_unit_id := vc_ppu_price_unit_id;
  end;

  function f_get_next_day(pd_date     in date,
                          pc_day      in varchar2,
                          pn_position in number) return date is
    vd_position_date date;
  begin
    select next_day((trunc(pd_date, 'Mon') - 1), pc_day) +
           ((pn_position * 7) - 7)
      into vd_position_date
      from dual;
    return vd_position_date;
  end;

  function f_is_day_holiday(pc_instrumentid in varchar2,
                            pc_trade_date   date) return boolean is
    vn_counter    number(1);
    vb_result_val boolean;
  begin
    --Checking the Week End Holiday List
    begin
      select count(*)
        into vn_counter
        from dual
       where to_char(pc_trade_date, 'Dy') in
             (select clwh.holiday
                from dim_der_instrument_master    dim,
                     clm_calendar_master          clm,
                     clwh_calendar_weekly_holiday clwh
               where dim.holiday_calender_id = clm.calendar_id
                 and clm.calendar_id = clwh.calendar_id
                 and dim.instrument_id = pc_instrumentid
                 and clm.is_deleted = 'N'
                 and clwh.is_deleted = 'N');
      if (vn_counter = 1) then
        vb_result_val := true;
      else
        vb_result_val := false;
      end if;
      if (vb_result_val = false) then
        --Checking Other Holiday List
        select count(*)
          into vn_counter
          from dual
         where trim(pc_trade_date) in
               (select trim(hl.holiday_date)
                  from hm_holiday_master         hm,
                       hl_holiday_list           hl,
                       dim_der_instrument_master dim,
                       clm_calendar_master       clm
                 where hm.holiday_id = hl.holiday_id
                   and dim.holiday_calender_id = clm.calendar_id
                   and clm.calendar_id = hm.calendar_id
                   and dim.instrument_id = pc_instrumentid
                   and hm.is_deleted = 'N'
                   and hl.is_deleted = 'N');
        if (vn_counter = 1) then
          vb_result_val := true;
        else
          vb_result_val := false;
        end if;
      end if;
    end;
    return vb_result_val;
  end;

  function f_get_next_month_prompt_date(pc_promp_del_cal_id varchar2,
                                        pd_trade_date       date) return date is
    cursor cur_monthly_prompt_rule is
      select mpc.*
        from mpc_monthly_prompt_calendar mpc
       where mpc.prompt_delivery_calendar_id = pc_promp_del_cal_id;
    cursor cr_applicable_months is
      select mpcm.*
        from mpcm_monthly_prompt_cal_month mpcm,
             mnm_month_name_master         mnm
       where mpcm.prompt_delivery_calendar_id = pc_promp_del_cal_id
         and mpcm.applicable_month = mnm.month_name_id
       order by mnm.display_order;
    vc_pdc_period_type_id      varchar2(15);
    vc_month_prompt_start_date date;
    vc_equ_period_type         number;
    cr_monthly_prompt_rule_rec cur_monthly_prompt_rule%rowtype;
    vc_period_to               number;
    vd_start_date              date;
    vd_end_date                date;
    vc_month                   varchar2(15);
    vn_year                    number;
    vn_month_count             number(5);
    vd_prompt_date             date;
  begin
    vc_month_prompt_start_date := pd_trade_date;
    vn_month_count             := 0;
    begin
      select pm.period_type_id
        into vc_pdc_period_type_id
        from pm_period_master pm
       where pm.period_type_name = 'Month';
    end;
    open cur_monthly_prompt_rule;
    fetch cur_monthly_prompt_rule
      into cr_monthly_prompt_rule_rec;
    vc_period_to := cr_monthly_prompt_rule_rec.period_for; --no of forward months required
    begin
      select pm.equivalent_days
        into vc_equ_period_type
        from pm_period_master pm
       where pm.period_type_id = cr_monthly_prompt_rule_rec.period_type_id;
    end;
    vd_start_date := vc_month_prompt_start_date;
    vd_end_date   := vc_month_prompt_start_date +
                     (vc_period_to * vc_equ_period_type);
    for cr_applicable_months_rec in cr_applicable_months
    loop
      vc_month_prompt_start_date := to_date(('01-' ||
                                            cr_applicable_months_rec.applicable_month || '-' ||
                                            to_char(vd_start_date, 'YYYY')),
                                            'dd/mm/yyyy');
      --------------------
      if (vc_month_prompt_start_date >=
         to_date(('01-' || to_char(vd_start_date, 'Mon-YYYY')),
                  'dd/mm/yyyy') and
         vc_month_prompt_start_date <= vd_end_date) then
        vn_month_count := vn_month_count + 1;
        if vn_month_count = 1 then
          vc_month := to_char(vc_month_prompt_start_date, 'Mon');
          vn_year  := to_char(vc_month_prompt_start_date, 'YYYY');
        end if;
      end if;
      exit when vn_month_count > 1;
      ---------------
    end loop;
    close cur_monthly_prompt_rule;
    if vc_month is not null and vn_year is not null then
      vd_prompt_date := to_date('01-' || vc_month || '-' || vn_year,
                                'dd-Mon-yyyy');
    end if;
    return vd_prompt_date;
  end;

end;
/

CREATE TABLE IEPD_D
(
  INTERNAL_INVOICE_REF_NO  VARCHAR2(30 CHAR),
  INVOICE_AMOUNT           NUMBER(25,10),
  DELIVERY_ITEM_REF_NO     VARCHAR2(50 CHAR),
  INTERNAL_GMR_REF_NO      VARCHAR2(30 CHAR),
  ELEMENT_ID               VARCHAR2(30 CHAR),
  ELEMENT_NAME             VARCHAR2(30 CHAR),
  FX_RATE                  NUMBER(25,10),
  GMR_REF_NO               VARCHAR2(50 CHAR),
  INVOICE_CUR_NAME         VARCHAR2(15 CHAR),
  INVOICE_PRICE_UNIT_NAME  VARCHAR2(50 CHAR),
  ADJUSTMENT               NUMBER(25,10),
  PRICE                    NUMBER(25,10),
  PRICE_FIXATION_DATE      DATE,
  PRICE_FIXATION_REF_NO    VARCHAR2(50 CHAR),
  PRICE_IN_PAY_IN_CUR      NUMBER(25,10),
  PRICING_CUR_NAME         VARCHAR2(15 CHAR),
  PRICING_PRICE_UNIT_NAME  VARCHAR2(50 CHAR),
  PRICING_TYPE             VARCHAR2(50 CHAR),
  PRODUCT_NAME             VARCHAR2(50 CHAR),
  QTY_PRICED               NUMBER(25,10),
  QTY_UNIT_NAME            VARCHAR2(15 CHAR),
  QP_START_DATE            DATE,
  QP_END_DATE              DATE,
  QP_PERIOD_TYPE           VARCHAR2(50 CHAR),
  INTERNAL_DOC_REF_NO      VARCHAR2(30 CHAR)
);

CREATE TABLE IEFPD_D
(
  INTERNAL_INVOICE_REF_NO      VARCHAR2(15 CHAR),
  INTERNAL_GMR_REF_NO          VARCHAR2(30 CHAR),
  GMR_REF_NO                   VARCHAR2(15 CHAR),
  ELEMENT_NAME                 VARCHAR2(30 CHAR),
  ELEMENT_ID                   VARCHAR2(30 CHAR),
  QTY_UNIT_NAME                VARCHAR2(15 CHAR),
  TOTAL_QTY_PRICED             NUMBER(25,10),
  WT_AVG_FX_RATE               NUMBER(25,10),
  WT_AVG_PRICE_IN_PRICING_CUR  NUMBER(25,10),
  PRICING_CUR_NAME             VARCHAR2(15 CHAR),
  WT_AVG_PRICE_IN_PAY_IN_CUR   NUMBER(25,10),
  PAY_IN_CUR_NAME              VARCHAR2(15 CHAR),
  INTERNAL_DOC_REF_NO          VARCHAR2(30 CHAR)
);

DROP SEQUENCE SEQ_IEFPD;

CREATE SEQUENCE SEQ_IEFPD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;
  
DROP SEQUENCE SEQ_INVEPD;

CREATE SEQUENCE SEQ_INVEPD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;  

CREATE TABLE IEFPD_IEF_PRICING_DETAIL
(
  IEFPD_ID                     VARCHAR2(15 CHAR),
  INTERNAL_INVOICE_REF_NO      VARCHAR2(15 CHAR),
  ELEMENT_ID                   VARCHAR2(15 CHAR),
  INTERNAL_GMR_REF_NO          VARCHAR2(15 CHAR),
  PCDI_ID                      VARCHAR2(15 CHAR),
  PRODUCT_ID                   VARCHAR2(15 CHAR),
  ELEMENT_NAME                 VARCHAR2(30 CHAR),
  QTY_UNIT_ID                  VARCHAR2(15 CHAR),
  QTY_UNIT_NAME                VARCHAR2(15 CHAR),
  TOTAL_QTY_PRICED             NUMBER(25,10),
  WT_AVG_FX_RATE               NUMBER(25,10),
  WT_AVG_PRICE_IN_PRICING_CUR  NUMBER(25,10),
  PRICING_CUR_ID               VARCHAR2(15 CHAR),
  PRICING_CUR_NAME             VARCHAR2(15 CHAR),
  WT_AVG_PRICE_IN_PAY_IN_CUR   NUMBER(25,10),
  PAY_IN_CUR_ID                VARCHAR2(15 CHAR),
  PAY_IN_CUR_NAME              VARCHAR2(15 CHAR),
  POFH_ID                      VARCHAR2(50 CHAR)
);

CREATE TABLE IEPD_INV_ELE_PRICING_DETAIL
(
  INVEPD_ID                VARCHAR2(15 CHAR),
  INTERNAL_INVOICE_REF_NO  VARCHAR2(15 CHAR),
  ELEMENT_ID               VARCHAR2(15 CHAR),
  INTERNAL_GMR_REF_NO      VARCHAR2(15 CHAR),
  PCDI_ID                  VARCHAR2(15 CHAR),
  PRODUCT_ID               VARCHAR2(15 CHAR),
  ELEMENT_NAME             VARCHAR2(30 CHAR),
  GMR_REF_NO               VARCHAR2(50 CHAR),
  PRICE_FIXATION_REF_NO    VARCHAR2(50 CHAR),
  PRICING_TYPE             VARCHAR2(50 CHAR),
  DELIVERY_ITEM_REF_NO     VARCHAR2(50 CHAR),
  PRICE_FIXATION_DATE      DATE,
  QTY_UNIT_ID              VARCHAR2(15 CHAR),
  QTY_UNIT_NAME            VARCHAR2(15 CHAR),
  QTY_PRICED               NUMBER(25,10),
  ADJUSTMENT               NUMBER(25,10),
  PRICE                    NUMBER(25,10),
  PRICING_CUR_ID           VARCHAR2(15 CHAR),
  PRICING_CUR_NAME         VARCHAR2(15 CHAR),
  FX_RATE                  NUMBER(25,10),
  PRICE_IN_PAY_IN_CUR      NUMBER(25,10),
  AMOUNT_IN_PAY_IN_CUR     NUMBER(25,10),
  PAY_IN_CUR_ID            VARCHAR2(15 CHAR),
  PAY_IN_CUR_NAME          VARCHAR2(15 CHAR),
  PAY_IN_PRICE_UNIT_ID     VARCHAR2(15 CHAR),
  PAY_IN_PRICE_UNIT_NAME   VARCHAR2(50 CHAR),
  PRICING_PRICE_UNIT_NAME  VARCHAR2(50 CHAR),
  PRICING_PRICE_UNIT_ID    VARCHAR2(15 CHAR),
  POFH_ID                  VARCHAR2(15 CHAR)
);
/
create or replace view V_BI_DAILY_PRICE_EXPOSURE AS
with main_q as (
        -- Average Pricing for the  base 
        select ak.corporate_id,
                pdm.product_id,
                pdm.product_desc product_name,
                1 dispay_order,
                'Average Exposure' pricing_by,
                decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
                pofh.per_day_pricing_qty *
                pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                     qum.qty_unit_id,
                                                     pdm.base_quantity_unit,
                                                     1) to_be_fixed_or_fixed_qty,
                'N' font_bold,
                pdm.base_quantity_unit base_qty_unit_id,
                qum_pdm.qty_unit base_qty_unit
          from pcm_physical_contract_main pcm,
                pcdi_pc_delivery_item pcdi,
                ak_corporate ak,
                gmr_goods_movement_record gmr,
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
                vd_voyage_detail vd,
                pfqpp_phy_formula_qp_pricing pfqpp,
                v_pci_multiple_premium vp,
                qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.product_id = pdm.product_id
           and pcpd.strategy_id = css.strategy_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pcpq.quality_template_id = qat.quality_id
           and pcpq.pcpq_id = vp.pcpq_id(+)
           and pdm.product_id = qat.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.poch_id = pocd.poch_id
           and pcm.internal_contract_ref_no = pcbph.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pocd.pocd_id = pofh.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and nvl(vd.status, 'Active') = 'Active'
           and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'BASEMETAL'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pofh.qp_start_date <= trunc(sysdate)
           and pofh.qp_end_date >= trunc(sysdate)
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
        union all
        -- Average Pricing for the  Concentrate  
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc,
               1 section_id,
               'Average Exposure',
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               pofh.per_day_pricing_qty *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               qum_quantity_unit_master qum,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               pcpq_pc_product_quality pcpq,
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
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pcpd.product_id = pdm.product_id
           and pcpq.quality_template_id = qat.quality_id
           and pdm.product_id = qat.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.poch_id = pocd.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and poch.pcbph_id = pcbph.pcbph_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pocd.pocd_id = pofh.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pocd_id = pocd.pocd_id
           and poch.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbph.element_id = poch.element_id
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and nvl(pfqpp.is_qp_any_day_basis, 'N') <> 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'CONCENTRATES'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pofh.qp_start_date <= trunc(sysdate)
           and pofh.qp_end_date >= trunc(sysdate)
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
        
        --Fixed by Price Request base
        union all
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product,
               2 display_order,
               'Fixed by Price Request',
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed) *
               pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                    qum.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    1) qty,
               'N',
               pdm.base_quantity_unit,
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               qum_quantity_unit_master qum,
               pcdi_pc_delivery_item pcdi,
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
               v_pci_multiple_premium vp,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpd.strategy_id = css.strategy_id
           and pcpq.quality_template_id = qat.quality_id
           and pcpq.pcpq_id = vp.pcpq_id(+)
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pofh.pocd_id = pocd.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and pfqpp.ppfh_id = ppfh.ppfh_id
           and pcm.contract_type = 'BASEMETAL'
           and pfqpp.is_qp_any_day_basis = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'N' --added to handle spot as separate
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and pfd.is_price_request = 'Y'
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  pcpd.product_id,
                  qum.qty_unit_id,
                  pdm.base_quantity_unit,
                  pdm.base_quantity_unit,
                  qum_pdm.qty_unit
        union all
        --Fixed by Price Request Concentrates
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product,
               2 section_id,
               'Fixed by Price Request' section,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               ak_corporate ak,
               qum_quantity_unit_master qum,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               css_corporate_strategy_setup css,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
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
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               cpc_corporate_profit_center cpc,
               pfqpp_phy_formula_qp_pricing pfqpp,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpd.strategy_id = css.strategy_id
           and qat.product_id = pdm.product_id
           and pcpq.quality_template_id = qat.quality_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and poch.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.element_id = poch.element_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pofh.pocd_id = pocd.pocd_id
           and pofh.pofh_id = pfd.pofh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and pfqpp.ppfh_id = ppfh.ppfh_id
           and ppfh.is_active = 'Y'
           and pfqpp.is_qp_any_day_basis = 'Y'
           and pcm.contract_type = 'CONCENTRATES'
           and pcm.contract_status <> 'Cancelled'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'N' --added to handle spot as separate
           and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and pfd.is_price_request = 'Y'
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  qum_pdm.qty_unit
        -- Spot base metal
        union all
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product,
               3 section_id,
               'Spot Exposure' section,
               (decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed)) qty,
               'N',
               qum.qty_unit_id,
               qum.qty_unit
          from pcm_physical_contract_main pcm,
               pcdi_pc_delivery_item pcdi,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               pcpq_pc_product_quality pcpq,
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
               pfd_price_fixation_details pfd,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.pcpd_id = pcpq.pcpd_id
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
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'Y'
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcm.contract_type = 'BASEMETAL'
           and pcdi.qty_unit_id = qum.qty_unit_id
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and pfd.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date = trunc(sysdate)
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  qum.qty_unit_id,
                  qum.qty_unit
        
        union all --spot concentrate
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product,
               3 section_id,
               'Spot Exposure' section,
               ((decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               sum(pfd.qty_fixed)) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                         pdm.product_id),
                                                     qum.qty_unit_id,
                                                     nvl(pdm_under.base_quantity_unit,
                                                         pdm.base_quantity_unit),
                                                     1)) qty,
               'N',
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
               qum_pdm.qty_unit
          from pcm_physical_contract_main pcm,
               pcdi_pc_delivery_item pcdi,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
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
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
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
               pfd_price_fixation_details pfd,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master qum_pdm
         where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.contract_type = 'CONCENTRATES'
           and ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pcpd.strategy_id = css.strategy_id
           and pdm.product_id = pcpd.product_id
           and pcpq.quality_template_id = qat.quality_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.element_id = poch.element_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pofh.pocd_id = pocd.pocd_id
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and nvl(pfqpp.is_spot_pricing, 'N') = 'Y'
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and pfd.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pcbph.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id
           and pfd.as_of_date = trunc(sysdate)
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit),
                  qum_pdm.qty_unit
        
        union all
        --any day base metal
        select ak.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               5 display_order,
               'Any Day Exposure' pricing_by,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               (pofh.qty_to_be_fixed - nvl(sum(pfd.qty_fixed), 0)) *
               pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                    qum.qty_unit_id,
                                                    pdm.base_quantity_unit,
                                                    1) to_be_fixed_or_fixed_qty,
               'N' font_bold,
               pdm.base_quantity_unit base_qty_unit_id,
               qum_pdm.qty_unit base_qty_unit
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               pcpq_pc_product_quality pcpq,
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
               pfd_price_fixation_details pfd,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               v_pci_multiple_premium vp,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpq.quality_template_id = qat.quality_id
           and pcpq.pcpq_id = vp.pcpq_id(+)
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pofh.pocd_id = pocd.pocd_id(+)
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'BASEMETAL'
           and pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) > 0
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date(+) <= sysdate
           and trunc(sysdate) between pofh.qp_start_date and pofh.qp_end_date
           and qum_pdm.qty_unit_id = pdm.base_quantity_unit
         group by ak.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  pcm.purchase_sales,
                  pofh.qty_to_be_fixed,
                  pcpd.product_id,
                  qum.qty_unit_id,
                  pdm.base_quantity_unit,
                  pdm.base_quantity_unit,
                  qum_pdm.qty_unit
        union all
        --any day concentrate
        select ak.corporate_id,
               pdm_under.product_id,
               pdm_under.product_desc product_name,
               5 display_order,
               'Any Day Exposure' pricing_by,
               decode(pcm.purchase_sales, 'P', 1, 'S', -1) *
               (pofh.qty_to_be_fixed - nvl(sum(pfd.qty_fixed), 0)) *
               pkg_general.f_get_converted_quantity(nvl(pdm_under.product_id,
                                                        pdm.product_id),
                                                    qum.qty_unit_id,
                                                    nvl(pdm_under.base_quantity_unit,
                                                        pdm.base_quantity_unit),
                                                    1) qty,
               'N' font_bold,
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit) base_qty_unit_id,
               /*qum_pdm.qty_unit_id*/qum_pdm.qty_unit base_qty_unit--fix 18-May-2012
          from pcm_physical_contract_main pcm,
               gmr_goods_movement_record gmr,
               ak_corporate ak,
               pcdi_pc_delivery_item pcdi,
               pcpd_pc_product_definition pcpd,
               css_corporate_strategy_setup css,
               pcpq_pc_product_quality pcpq,
               pdm_productmaster pdm,
               qat_quality_attributes qat,
               poch_price_opt_call_off_header poch,
               aml_attribute_master_list aml,
               pdm_productmaster pdm_under,
               qum_quantity_unit_master qum_under,
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
               pfd_price_fixation_details pfd,
               cpc_corporate_profit_center cpc,
               vd_voyage_detail vd,
               pfqpp_phy_formula_qp_pricing pfqpp,
               pcqpd_pc_qual_premium_discount pcqpd,
               qum_quantity_unit_master qum,
               ppu_product_price_units ppu,
               pum_price_unit_master pum,
               qum_quantity_unit_master qum_pdm
         where ak.corporate_id = pcm.corporate_id
           and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
           and pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
           and pcpd.strategy_id = css.strategy_id
           and pcpd.pcpd_id = pcpq.pcpd_id
           and pdm.product_id = pcpd.product_id
           and pcpq.quality_template_id = qat.quality_id
           and qat.product_id = pdm.product_id
           and pcdi.pcdi_id = poch.pcdi_id
           and poch.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm_under.product_id(+)
           and pdm_under.base_quantity_unit = qum_under.qty_unit_id(+)
           and pocd.poch_id = poch.poch_id
           and pcbph.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcbph.element_id = poch.element_id
           and pcbph.pcbph_id = pcbpd.pcbph_id
           and pcbpd.pcbpd_id = pocd.pcbpd_id
           and pcbpd.pcbpd_id = ppfh.pcbpd_id
           and pofh.pocd_id = pocd.pocd_id(+)
           and pofh.internal_gmr_ref_no = gmr.internal_gmr_ref_no(+)
           and pofh.pofh_id = pfd.pofh_id(+)
           and ppfh.ppfh_id = ppfd.ppfh_id(+)
           and pcpd.profit_center_id = cpc.profit_center_id
           and gmr.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
           and nvl(vd.status, 'Active') = 'Active'
           and ppfh.ppfh_id = pfqpp.ppfh_id
           and nvl(pfqpp.is_qp_any_day_basis, 'N') = 'Y'
           and pcm.internal_contract_ref_no =
               pcqpd.internal_contract_ref_no(+)
           and qum.qty_unit_id = pocd.qty_to_be_fixed_unit_id
           and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
           and ppu.price_unit_id = pum.price_unit_id(+)
           and pcm.is_active = 'Y'
           and pcm.contract_status <> 'Cancelled'
           and pcm.contract_type = 'CONCENTRATES'
           and pofh.qty_to_be_fixed - nvl(pofh.priced_qty, 0) > 0
           and pcdi.is_active = 'Y'
           and nvl(gmr.is_deleted, 'N') = 'N'
           and pdm.is_active = 'Y'
           and qum.is_active = 'Y'
           and qat.is_active = 'Y'
           and pofh.is_active = 'Y'
           and poch.is_active = 'Y'
           and pocd.is_active = 'Y'
           and ppfh.is_active = 'Y'
           and pfd.as_of_date(+) <= sysdate
           and trunc(sysdate) between pofh.qp_start_date and pofh.qp_end_date
           and qum_pdm.qty_unit_id =
               nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
         group by ak.corporate_id,
                  pdm_under.product_id,
                  pdm_under.product_desc,
                  pcm.purchase_sales,
                  pofh.qty_to_be_fixed,
                  nvl(pdm_under.product_id, pdm.product_id),
                  qum.qty_unit_id,
                  /*qum_pdm.qty_unit_id*/qum_pdm.qty_unit,--Fix 18-May-2012
                  nvl(pdm_under.base_quantity_unit, pdm.base_quantity_unit)
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               1 dispay_order,
               'Average Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               2 dispay_order,
               'Fixed by Price Request',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               3 dispay_order,
               'Spot Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
        union all
        select akc.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               5 dispay_order,
               'Any Day Exposure',
               0,
               'N',
               pdm.base_quantity_unit,
               qum.qty_unit
          from ak_corporate             akc,
               pdm_productmaster        pdm,
               qum_quantity_unit_master qum
         where pdm.base_quantity_unit = qum.qty_unit_id
           and akc.corporate_id <> 'EKA-SYS'
         ) 
select corporate_id,
       product_id,
       product_name,
       dispay_order,
       pricing_by,
       to_be_fixed_or_fixed_qty,
       font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
union all
select corporate_id,
       product_id,
       product_name,
       4 dispay_order,
       'Total Exposure' pricing_by,
       sum(to_be_fixed_or_fixed_qty),
       'Y' font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
 where dispay_order in (1, 2, 3)
 group by corporate_id,
          product_id,
          product_name,
          base_qty_unit_id,
          base_qty_unit
union all
select corporate_id,
       product_id,
       product_name,
       6 dispay_order,
       'Total Exposure With Any Day' pricing_by,
       sum(to_be_fixed_or_fixed_qty),
       'Y' font_bold,
       base_qty_unit_id,
       base_qty_unit
  from main_q
 group by corporate_id,
          product_id,
          product_name,
          base_qty_unit_id,
          base_qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       7 dispay_order,
       'Net Hedge Exposure' pricing_by,
       sum(drt.hedge_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       8 dispay_order,
       'Net Strategic Exposure' pricing_by,
       sum(drt.strategic_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit
union all
select drt.corporate_id,
       drt.product_id,
       drt.product_desc product_name,
       9 dispay_order,
       'Net Derivative' pricing_by,
       sum(drt.trade_qty * drt.qty_sign) to_be_fixed_or_fixed_qty,
       'Y' font_bold,
       drt.qty_unit_id base_qty_unit_id,
       drt.qty_unit base_qty_unit
  from v_bi_derivative_trades drt
where drt.trade_date =  trunc(sysdate)
 group by drt.corporate_id,
          drt.product_id,
          drt.product_desc,
          drt.qty_unit_id,
          drt.qty_unit;
/
DROP TRIGGER TRG_INSERT_POFHL;
CREATE OR REPLACE TRIGGER "TRG_INSERT_POFHL"
   AFTER INSERT OR UPDATE
   ON pofh_price_opt_fixation_header
   FOR EACH ROW
BEGIN
   --
   IF UPDATING
   THEN
      INSERT INTO pofhl_price_opt_fixat_head_log
                  (pofh_id, pocd_id, internal_gmr_ref_no,
                   entry_type, qp_start_date, qp_end_date,
                   qty_to_be_fixed_delta,
                   priced_qty_delta,
                   no_of_prompt_days_delta,
                   per_day_pricing_qty_delta,
                   final_price_delta,
                   finalize_date,
                   VERSION, is_active, avg_pri_in_pri_in_cur_delta,
                   avg_fx_delta,
                   no_of_prompt_days_fixed,
                   event_name,
                   delta_priced_qty_delta,
                   final_pri_in_pric_cur_delta,
                   internal_action_ref_no
                  )
           VALUES ( :NEW.pofh_id, :NEW.pocd_id,
                   :NEW.internal_gmr_ref_no, 'Update', :NEW.qp_start_date,
                   :NEW.qp_end_date,
                   :NEW.qty_to_be_fixed - :OLD.qty_to_be_fixed,
                   NVL(:NEW.priced_qty,0) - NVL(:OLD.priced_qty,0),
                   :NEW.no_of_prompt_days - :OLD.no_of_prompt_days,
                     :NEW.per_day_pricing_qty
                   - :OLD.per_day_pricing_qty,
                   NVL(:NEW.final_price,0) - NVL(:OLD.final_price,0),
                   :NEW.finalize_date, :NEW.VERSION, :NEW.is_active,
                    NVL( :NEW.AVG_PRICE_IN_PRICE_IN_CUR,0)
                   - NVL(:OLD.AVG_PRICE_IN_PRICE_IN_CUR,0),
                   NVL(:NEW.avg_fx,0) - NVL(:OLD.avg_fx,0),
                   NVL(:NEW.no_of_prompt_days_fixed,0) - NVL(:OLD.no_of_prompt_days_fixed,0),
                   :NEW.event_name,
                   NVL(:NEW.delta_priced_qty,0) - NVL(:OLD.delta_priced_qty,0),
                    NVL( :NEW.FINAL_PRICE_IN_PRICING_CUR,0)
                   - NVL(:OLD.FINAL_PRICE_IN_PRICING_CUR,0),
                   :NEW.internal_action_ref_no
                  );
   ELSE
      --
      -- New Entry ( Entry Type=Insert)
      --
      INSERT INTO pofhl_price_opt_fixat_head_log
                  (pofh_id, pocd_id, internal_gmr_ref_no,
                   entry_type, qp_start_date, qp_end_date,
                   qty_to_be_fixed_delta,
                   priced_qty_delta,
                   no_of_prompt_days_delta,
                   per_day_pricing_qty_delta,
                   final_price_delta,
                   finalize_date,
                   VERSION, is_active, avg_pri_in_pri_in_cur_delta,
                   avg_fx_delta,
                   no_of_prompt_days_fixed,
                   event_name,
                   delta_priced_qty_delta,
                   final_pri_in_pric_cur_delta,
                   internal_action_ref_no
                  )
           VALUES ( :NEW.pofh_id, :NEW.pocd_id,
                   :NEW.internal_gmr_ref_no, 'Insert', :NEW.qp_start_date,
                   :NEW.qp_end_date,
                   :NEW.qty_to_be_fixed ,
                   :NEW.priced_qty ,
                   :NEW.no_of_prompt_days ,
                     :NEW.per_day_pricing_qty,
                   :NEW.final_price ,
                   :NEW.finalize_date, :NEW.VERSION, :NEW.is_active,
                     :NEW.AVG_PRICE_IN_PRICE_IN_CUR,
                   :NEW.avg_fx ,
                   :NEW.no_of_prompt_days_fixed ,
                   :NEW.event_name,
                   :NEW.delta_priced_qty ,
                     :NEW.FINAL_PRICE_IN_PRICING_CUR,
                   :NEW.internal_action_ref_no
                   );
   END IF;
END;
/

create or replace view v_invoice_doc as
select        'Invoice' section_name,
              'Invoice' sub_section,
               rownum record_no,
               akc.corporate_id,
               akc.corporate_name,
               akc.address1,
               akc.address2,
               akc.city,
               akc.state,
               akc.country,
               akc.logo_path,
               akc.phone_no,
               akc.fax_no,
               isd.internal_doc_ref_no,
               isd.due_date,
               isd.sales_purchase,
               isd.cp_name,
               isd.supplire_invoice_no cp_item_stock_ref_no,
               '' business_unit,
               isd.self_item_stock_ref_no,
               isd.inco_term_location,
               isd.contract_ref_no self_contract_item_no,
               isd.contract_date,
               isd.notify_party,
               isd.org_name,
               isd.cp_contract_ref_no,
               isd.productandquality_name,
               isd.contract_tolerance,
               isd.contract_quantity,
               isd.contract_qty_unit,
               isd.invoice_ref_no provisional_invoice_no,
               isd.internal_invoice_ref_no,
               isd.product,
               isd.quality,
               isd.invoice_amount amount,
               isd.invoice_amount_unit,
               isd.payment_term,
               isd.invoice_creation_date,
               null invoice_issue_date,
               isd.invoice_quantity,
               isd.invoice_dry_quantity,
               isd.invoice_wet_quantity,
               isd.invoiced_qty_unit,
               isd.moisture,
               isd.invoice_type_name invoice_type,
               isd.stock_size,
               isd.packing,
               isd.provisional_price,
               isd.origin,
               isd.tarriff,
               '' final_qty,
               isd.material_cost final_amount,
               ispcd.invoice_ref_no pi_number,
               ispcd.invoice_amount provisional_amount,
               '' amount_due,
               isd.addditional_charges,
               isd.taxes,
               isd.contract_type product_type,
               isd.Invoice_Status,
               isd.gmr_ref_no pledge_gmr_ref_no,
               isd.gmr_quality pledge_gmr_qty,
               isd.stock_ref_no pledge_stock_ref_no,
               isd.stock_quantity pledge_stock_qty,
               isc.internal_doc_ref_no internal_doc_ref_no0,
               isc.stock_ref_no,
               isc.stock_qty || '' || isc.invoiced_qty_unit stock_qty,
               isc.gmr_ref_no,
               isc.gmr_quality,
               isc.gmr_quantity,
               isc.price_as_per_defind_uom,
               isc.item_amount_in_inv_cur,
               isc.invoiced_price_unit,
               null element_price_unit,
               isc.total_price_qty total_quantity,
               isc.gmr_qty_unit,
               isp_c1.internal_doc_ref_no internal_doc_ref_no1,
               isp_c1.beneficiary_name benificiary_name_c1,
               isp_c1.bank_name bank_name_c1,
               isp_c1.account_no account_no_c1,
               isp_c1.iban iban_c1,
               isp_c1.aba_rtn aba_rtn_c1,
               isp_c1.instruction instruction_c1,
               isp_c2.internal_doc_ref_no internal_doc_ref_no2,
               isp_c2.beneficiary_name benificiary_name_c2,
               isp_c2.bank_name bank_name_c2,
               isp_c2.account_no account_no_c2,
               isp_c2.iban iban_c2,
               isp_c2.aba_rtn aba_rtn_c2,
               isp_c2.instruction instruction_c2,
               is_cp.internal_doc_ref_no internal_doc_ref_no3,
               is_cp.stock_ref_no stock_ref_no1,
               is_cp.gmr_ref_no stock_gmr_ref_no,
               is_cp.gmr_quantity cp_gmr_quantity,
               is_cp.stock_qty stock_qty1,
               is_cp.gmr_qty_unit gmr_qty_unit1,
               is_cp.element_id payable_element_id,
               is_cp.element_name payable_element,
               is_cp.assay_content analysis,
               is_cp.assay_content_unit analysis_unit,
               is_cp.invoice_price element_price,
               is_cp.invoiced_price_unit invoiced_price_unit1,
               is_cp.element_price_unit element_price_unit1,
               is_cp.sub_lot_no,
               is_cp.element_inv_amount,
               is_cp.element_invoiced_qty,
               is_cp.element_invoiced_qty_unit,
               null internal_doc_ref_no4,
               null tc_element_id,
               null element_name,
               null tc_rc_sub_lot_no,
               null tc_amount,
               null tc_amount_unit,
               null internal_doc_ref_no5,
               null rc_element_id,
               null element_name1,
               null rc_amount,
               null rc_amount_unit,
               null internal_doc_ref_no6,
               null pen_element_id,
               null element_name2,
               null pen_amount,
               null pen_amount_unit,
               vat.vat_no,
               vat.cp_vat_no,
               vat.vat_code,
               vat.vat_rate,
               vat.vat_rate_unit,
               vat.vat_amount,
               isd.invoice_amount_unit vat_amount_cur,
               isd.is_inv_draft,
               null cost_name,
               null charge_type,
               null charge_amount_rate,
               null charge_amount_rate_unit,
               null fx_rate,
               null charges_quantity,
               null charges_qty_unit,
               null charges_amount,
               null charge_amount_unit,
               null charges_invoice_amount,
               null charges_invoice_cur_name,
               null tax_code,
               null tax_rate,
               null tax_currency,
               null taxes_fx_rate,
               null Applicable_on,
               null taxes_amount,
               null taxes_amount_unit,
               null taxes_invoice_amount,
               null taxes_invoice_amount_cur,
               isd.is_free_metal,
               isd.is_pledge,
               isd.internal_comments,
               (case when  isd.sales_purchase='P' then
                        isp_c1.remarks
                        when isd.sales_purchase='S' then
                        isp_c2.remarks end) remarks,
                isc.yield,
                isc.product gmr_product,
                isc.invoiced_qty_unit child_qty_unit,
                isd.iban,
                api_d.internal_doc_ref_no api_internal_doc_ref_no,
                api_d.api_invoice_ref_no,
                api_d.api_amount_adjusted,
                api_d.invoice_currency api_invoice_currency
  from is_d isd,
       is_child_d isc,
       is_bdp_child_d isp_c1,
       is_bds_child_d isp_c2,
       is_conc_payable_child is_cp,
       is_parent_child_d ispcd,
       api_details_d api_d,
       ds_document_summary ds,
       v_ak_corporate akc,
        (select vat.internal_invoice_ref_no,
                       vat.our_vat_no vat_no,
                       vat.cp_vat_no,
                       vat.vat_code,
                       vat.vat_rate,
                       vat.vat_rate_unit,
                       vat.vat_amount_in_inv_cur vat_amount
                  from ivd_invoice_vat_details vat
                 where vat.is_separate_invoice = 'N')vat
         where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
           and ds.corporate_id = akc.corporate_id(+)
           and isd.internal_doc_ref_no = isc.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = ispcd.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = api_d.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isp_c1.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isp_c2.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = is_cp.internal_doc_ref_no(+)
           and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
union all
select        'Invoice' section_name,
              'Treatment Charge' sub_section,
               rownum record_no,
               akc.corporate_id,
               akc.corporate_name,
               akc.address1,
               akc.address2,
               akc.city,
               akc.state,
               akc.country,
               akc.logo_path,
               akc.phone_no,
               akc.fax_no,
               isd.internal_doc_ref_no,
               isd.due_date,
               isd.sales_purchase,
               isd.cp_name,
               isd.supplire_invoice_no cp_item_stock_ref_no,
               '' business_unit,
               isd.self_item_stock_ref_no,
               isd.inco_term_location,
               isd.contract_ref_no self_contract_item_no,
               isd.contract_date,
               isd.notify_party,
               isd.org_name,
               isd.cp_contract_ref_no,
               isd.productandquality_name,
               isd.contract_tolerance,
               isd.contract_quantity,
               isd.contract_qty_unit,
               isd.invoice_ref_no provisional_invoice_no,
               isd.internal_invoice_ref_no,
               isd.product,
               isd.quality,
               isd.invoice_amount amount,
               isd.invoice_amount_unit,
               isd.payment_term,
               isd.invoice_creation_date,
               null invoice_issue_date,
               isd.invoice_quantity,
               isd.invoice_dry_quantity,
               isd.invoice_wet_quantity,
               isd.invoiced_qty_unit,
               isd.moisture,
               isd.invoice_type_name invoice_type,
               isd.stock_size,
               isd.packing,
               isd.provisional_price,
               isd.origin,
               isd.tarriff,
               '' final_qty,
               isd.material_cost final_amount,
               '' pi_number,
               '' provisional_amount,
               '' amount_due,
               isd.addditional_charges,
               isd.taxes,
               isd.contract_type product_type,
               isd.Invoice_Status,
               isd.gmr_ref_no pledge_gmr_ref_no,
               isd.gmr_quality pledge_gmr_qty,
               isd.stock_ref_no pledge_stock_ref_no,
               isd.stock_quantity pledge_stock_qty,
               null internal_doc_ref_no0,
               null stock_ref_no1,
               null stock_qty,
               null gmr_ref_no,
               null gmr_quality,
               null gmr_quantity,
               null price_as_per_defind_uom,
               null item_amount_in_inv_cur,
               null invoiced_price_unit,
               null element_price_unit,
               null total_quantity,
               null gmr_qty_unit,
               isp_c1.internal_doc_ref_no internal_doc_ref_no1,
               isp_c1.beneficiary_name benificiary_name_c1,
               isp_c1.bank_name bank_name_c1,
               isp_c1.account_no account_no_c1,
               isp_c1.iban iban_c1,
               isp_c1.aba_rtn aba_rtn_c1,
               isp_c1.instruction instruction_c1,
               isp_c2.internal_doc_ref_no internal_doc_ref_no2,
               isp_c2.beneficiary_name benificiary_name_c2,
               isp_c2.bank_name bank_name_c2,
               isp_c2.account_no account_no_c2,
               isp_c2.iban iban_c2,
               isp_c2.aba_rtn aba_rtn_c2,
               isp_c2.instruction instruction_c2,
               null internal_doc_ref_no3,
               null stock_ref_no1,
               null stock_gmr_ref_no,
               null cp_gmr_quantity,
               null stock_qty1,
               null gmr_qty_unit1,
               null payable_element_id,
               null payable_element,
               null analysis,
               null analysis_unit,
               null element_price,
               null invoiced_price_unit1,
               null element_price_unit1,
               null sub_lot_no,
               null element_inv_amount,
               null element_invoiced_qty,
               null element_invoiced_qty_unit,
               istc.internal_doc_ref_no internal_doc_ref_no4,
               istc.tc_element_id,
               istc.element_name,
               istc.sub_lot_no tc_rc_sub_lot_no,
               istc.tc_amount,
               istc.tc_amount_unit,
               null internal_doc_ref_no5,
               null rc_element_id,
               null element_name1,
               null rc_amount,
               null rc_amount_unit,
               null internal_doc_ref_no6,
               null pen_element_id,
               null element_name2,
               null pen_amount,
               null pen_amount_unit,
               vat.vat_no,
               vat.cp_vat_no,
               vat.vat_code,
               vat.vat_rate,
               vat.vat_rate_unit,
               vat.vat_amount,
               isd.invoice_amount_unit vat_amount_cur,
               isd.is_inv_draft,
               null cost_name,
               null charge_type,
               null charge_amount_rate,
               null charge_amount_rate_unit,
               null fx_rate,
               null charges_quantity,
               null charges_qty_unit,
               null charges_amount,
               null charge_amount_unit,
               null charges_invoice_amount,
               null charges_invoice_cur_name,
               null tax_code,
               null tax_rate,
               null tax_currency,
               null taxes_fx_rate,
               null Applicable_on,
               null taxes_amount,
               null taxes_amount_unit,
               null taxes_invoice_amount,
               null taxes_invoice_amount_cur,
               isd.is_free_metal,
               isd.is_pledge,
               isd.internal_comments,
               (case when  isd.sales_purchase='P' then
                        isp_c1.remarks
                        when isd.sales_purchase='S' then
                        isp_c2.remarks end) remarks,
                null yield,
                null gmr_product,
                null child_qty_unit,
                isd.iban,
                null api_internal_doc_ref_no,
                null api_invoice_ref_no,
                null api_amount_adjusted,
                null api_invoice_currency
  from is_d isd,
       is_bdp_child_d isp_c1,
       is_bds_child_d isp_c2,
       ds_document_summary ds,
       v_ak_corporate akc,
       (select istc.internal_doc_ref_no,
               istc.element_id tc_element_id,
               istc.element_name,
               istc.sub_lot_no ||(case when istc.assay_detail is null then ''
                                      else ' : '|| istc.assay_detail end) sub_lot_no,
              istc.tc_amount,
               istc.amount_unit tc_amount_unit
          from is_conc_tc_child istc) istc,
        (select vat.internal_invoice_ref_no,
                       vat.our_vat_no vat_no,
                       vat.cp_vat_no,
                       vat.vat_code,
                       vat.vat_rate,
                       vat.vat_rate_unit,
                       vat.vat_amount_in_inv_cur vat_amount
                  from ivd_invoice_vat_details vat
                 where vat.is_separate_invoice = 'N')vat
         where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
           and ds.corporate_id = akc.corporate_id(+)
           and isd.internal_doc_ref_no = isp_c1.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isp_c2.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = istc.internal_doc_ref_no(+)
           and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
Union all
select        'Invoice' section_name,
              'Refining Charge' sub_section,
               rownum record_no,
               akc.corporate_id,
               akc.corporate_name,
               akc.address1,
               akc.address2,
               akc.city,
               akc.state,
               akc.country,
               akc.logo_path,
               akc.phone_no,
               akc.fax_no,
               isd.internal_doc_ref_no,
               isd.due_date,
               isd.sales_purchase,
               isd.cp_name,
               isd.supplire_invoice_no cp_item_stock_ref_no,
               '' business_unit,
               isd.self_item_stock_ref_no,
               isd.inco_term_location,
               isd.contract_ref_no self_contract_item_no,
               isd.contract_date,
               isd.notify_party,
               isd.org_name,
               isd.cp_contract_ref_no,
               isd.productandquality_name,
               isd.contract_tolerance,
               isd.contract_quantity,
               isd.contract_qty_unit,
               isd.invoice_ref_no provisional_invoice_no,
               isd.internal_invoice_ref_no,
               isd.product,
               isd.quality,
               isd.invoice_amount amount,
               isd.invoice_amount_unit,
               isd.payment_term,
               isd.invoice_creation_date,
               null invoice_issue_date,
               isd.invoice_quantity,
               isd.invoice_dry_quantity,
               isd.invoice_wet_quantity,
               isd.invoiced_qty_unit,
               isd.moisture,
               isd.invoice_type_name invoice_type,
               isd.stock_size,
               isd.packing,
               isd.provisional_price,
               isd.origin,
               isd.tarriff,
               '' final_qty,
               isd.material_cost final_amount,
               '' pi_number,
               '' provisional_amount,
               '' amount_due,
               isd.addditional_charges,
               isd.taxes,
               isd.contract_type product_type,
               isd.Invoice_Status,
               isd.gmr_ref_no pledge_gmr_ref_no,
               isd.gmr_quality pledge_gmr_qty,
               isd.stock_ref_no pledge_stock_ref_no,
               isd.stock_quantity pledge_stock_qty,
               null internal_doc_ref_no0,
               null stock_ref_no,
               null stock_qty,
               null gmr_ref_no,
               null gmr_quality,
               null gmr_quantity,
               null price_as_per_defind_uom,
               null item_amount_in_inv_cur,
               null invoiced_price_unit,
               null element_price_unit,
               null total_quantity,
               null gmr_qty_unit,
               isp_c1.internal_doc_ref_no internal_doc_ref_no1,
               isp_c1.beneficiary_name benificiary_name_c1,
               isp_c1.bank_name bank_name_c1,
               isp_c1.account_no account_no_c1,
               isp_c1.iban iban_c1,
               isp_c1.aba_rtn aba_rtn_c1,
               isp_c1.instruction instruction_c1,
               isp_c2.internal_doc_ref_no internal_doc_ref_no2,
               isp_c2.beneficiary_name benificiary_name_c2,
               isp_c2.bank_name bank_name_c2,
               isp_c2.account_no account_no_c2,
               isp_c2.iban iban_c2,
               isp_c2.aba_rtn aba_rtn_c2,
               isp_c2.instruction instruction_c2,
               null internal_doc_ref_no3,
               null stock_ref_no1,
               null stock_gmr_ref_no,
               null cp_gmr_quantity,
               null stock_qty1,
               null gmr_qty_unit1,
               null payable_element_id,
               null payable_element,
               null analysis,
               null analysis_unit,
               null element_price,
               null invoiced_price_unit1,
               null element_price_unit1,
               null sub_lot_no,
               null element_inv_amount,
               null element_invoiced_qty,
               null element_invoiced_qty_unit,
               null internal_doc_ref_no4,
               null tc_element_id,
               null element_name,
               isrc.sub_lot_no tc_rc_sub_lot_no,
               null tc_amount,
               null tc_amount_unit,
               isrc.internal_doc_ref_no internal_doc_ref_no5,
               isrc.rc_element_id,
               isrc.element_name element_name1,
               isrc.rc_amount,
               isrc.rc_amount_unit,
               null internal_doc_ref_no6,
               null pen_element_id,
               null element_name2,
               null pen_amount,
               null pen_amount_unit,
               vat.vat_no,
               vat.cp_vat_no,
               vat.vat_code,
               vat.vat_rate,
               vat.vat_rate_unit,
               vat.vat_amount,
               isd.invoice_amount_unit vat_amount_cur,
               isd.is_inv_draft,
               null cost_name,
               null charge_type,
               null charge_amount_rate,
               null charge_amount_rate_unit,
               null fx_rate,
               null charges_quantity,
               null charges_qty_unit,
               null charges_amount,
               null charge_amount_unit,
               null charges_invoice_amount,
               null charges_invoice_cur_name,
               null tax_code,
               null tax_rate,
               null tax_currency,
               null taxes_fx_rate,
               null Applicable_on,
               null taxes_amount,
               null taxes_amount_unit,
               null taxes_invoice_amount,
               null taxes_invoice_amount_cur,
               isd.is_free_metal,
               isd.is_pledge,
               isd.internal_comments,
               (case when  isd.sales_purchase='P' then
                        isp_c1.remarks
                        when isd.sales_purchase='S' then
                        isp_c2.remarks end) remarks,
                null yield,
                null  gmr_product,
                null child_qty_unit,
                isd.iban,
                null api_internal_doc_ref_no,
                null api_invoice_ref_no,
                null api_amount_adjusted,
                null api_invoice_currency
  from is_d isd,
       is_bdp_child_d isp_c1,
       is_bds_child_d isp_c2,
       ds_document_summary ds,
       v_ak_corporate akc,
       (select isrc.internal_doc_ref_no,
               isrc.element_id rc_element_id,
               isrc.element_name,
               isrc.sub_lot_no ||(case when isrc.assay_content is null then ''
                                      else ' : '|| isrc.assay_content end) sub_lot_no,
               isrc.rc_amount,
               isrc.amount_unit rc_amount_unit
          from is_conc_rc_child isrc) isrc,
        (select vat.internal_invoice_ref_no,
                       vat.our_vat_no vat_no,
                       vat.cp_vat_no,
                       vat.vat_code,
                       vat.vat_rate,
                       vat.vat_rate_unit,
                       vat.vat_amount_in_inv_cur vat_amount
                  from ivd_invoice_vat_details vat
                 where vat.is_separate_invoice = 'N')vat
         where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
           and ds.corporate_id = akc.corporate_id(+)
           and isd.internal_doc_ref_no = isp_c1.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isp_c2.internal_doc_ref_no(+)
           and isd.internal_doc_ref_no = isrc.internal_doc_ref_no(+)
           and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
union all
select 'Invoice' section_name,
       'Penality' sub_section,
       rownum record_no,
       akc.corporate_id,
       akc.corporate_name,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.logo_path,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.due_date,
       isd.sales_purchase,
       isd.cp_name,
       isd.supplire_invoice_no cp_item_stock_ref_no,
       '' business_unit,
       isd.self_item_stock_ref_no,
       isd.inco_term_location,
       isd.contract_ref_no self_contract_item_no,
       isd.contract_date,
       isd.notify_party,
       isd.org_name,
       isd.cp_contract_ref_no,
       isd.productandquality_name,
       isd.contract_tolerance,
       isd.contract_quantity,
       isd.contract_qty_unit,
       isd.invoice_ref_no provisional_invoice_no,
       isd.internal_invoice_ref_no,
       isd.product,
       isd.quality,
       isd.invoice_amount amount,
       isd.invoice_amount_unit,
       isd.payment_term,
       isd.invoice_creation_date,
       null invoice_issue_date,
       isd.invoice_quantity,
       isd.invoice_dry_quantity,
       isd.invoice_wet_quantity,
       isd.invoiced_qty_unit,
       isd.moisture,
       isd.invoice_type_name invoice_type,
       isd.stock_size,
       isd.packing,
       isd.provisional_price,
       isd.origin,
       isd.tarriff,
       isd.material_cost final_qty,
       '' final_amount,
       '' pi_number,
       '' provisional_amount,
       null amount_due,
       isd.addditional_charges,
       isd.taxes,
       isd.contract_type product_type,
       isd.Invoice_Status,
       null pledge_gmr_ref_no,
       null  pledge_gmr_qty,
       null  pledge_stock_ref_no,
       null  pledge_stock_qty,
       null internal_doc_ref_no0,
       null stock_ref_no,
       null stock_qty,
       null gmr_ref_no,
       null gmr_quality,
       null gmr_quantity,
       null price_as_per_defind_uom,
       null item_amount_in_inv_cur,
       null invoiced_price_unit,
       null element_price_unit,
       null total_quantity,
       null gmr_qty_unit,
       isp_c1.internal_doc_ref_no internal_doc_ref_no1,
       isp_c1.beneficiary_name benificiary_name_c1,
       isp_c1.bank_name bank_name_c1,
       isp_c1.account_no account_no_c1,
       isp_c1.iban iban_c1,
       isp_c1.aba_rtn aba_rtn_c1,
       isp_c1.instruction instruction_c1,
       isp_c2.internal_doc_ref_no internal_doc_ref_no2,
       isp_c2.beneficiary_name benificiary_name_c2,
       isp_c2.bank_name bank_name_c2,
       isp_c2.account_no account_no_c2,
       isp_c2.iban iban_c2,
       isp_c2.aba_rtn aba_rtn_c2,
       isp_c2.instruction instruction_c2,
       null internal_doc_ref_no3,
       null stock_ref_no1,
       null stock_gmr_ref_no,
       null cp_gmr_quantity,
       null stock_qty1,
       null gmr_qty_unit1,
       null payable_element_id,
       null payable_element,
       null analysis,
       null analysis_unit,
       null element_price,
       null invoiced_price_unit1,
       null element_price_unit1,
       null sub_lot_no,
       null element_inv_amount,
       null element_invoiced_qty,
       null element_invoiced_qty_unit,
       null internal_doc_ref_no4,
       null tc_element_id,
       null element_name,
       null tc_rc_sub_lot_no,
       null tc_amount,
       null tc_amount_unit,
       null internal_doc_ref_no5,
       null rc_element_id,
       null element_name1,
       null rc_amount,
       null rc_amount_unit,
       isp.internal_doc_ref_no internal_doc_ref_no6,
       isp.pen_element_id,
       isp.element_name element_name2,
       isp.pen_amount,
       isp.pen_amount_unit,
       vat.vat_no,
       vat.cp_vat_no,
       vat.vat_code,
       vat.vat_rate,
       vat.vat_rate_unit,
       vat.vat_amount,
       isd.invoice_amount_unit vat_amount_cur,
       isd.is_inv_draft,
       null cost_name,
       null charge_type,
       null charge_amount_rate,
       null charge_amount_rate_unit,
       null fx_rate,
       null charges_quantity,
       null charges_qty_unit,
       null charges_amount,
       null charge_amount_unit,
       null charges_invoice_amount,
       null charges_invoice_cur_name,
       null tax_code,
       null tax_rate,
       null tax_currency,
       null taxes_fx_rate,
       null Applicable_on,
       null taxes_amount,
       null taxes_amount_unit,
       null taxes_invoice_amount,
       null taxes_invoice_amount_cur,
       isd. is_free_metal,
       isd. is_pledge,
       isd. internal_comments,
       null remarks,
       null yield,
       null gmr_product,
       null child_qty_unit,
       null iban,
       null api_internal_doc_ref_no,
       null api_invoice_ref_no,
       null api_amount_adjusted,
       null api_invoice_currency
  from is_d isd,
       ds_document_summary ds,
       v_ak_corporate akc,
       is_bdp_child_d isp_c1,
       is_bds_child_d isp_c2,
       (select isp.internal_doc_ref_no,
               isp.element_id pen_element_id,
               isp.element_name,
               sum(isp.penalty_amount) pen_amount,
               isp.amount_unit pen_amount_unit
          from is_conc_penalty_child isp
         group by isp.internal_doc_ref_no,
                  isp.element_id,
                  isp.element_name,
                  isp.amount_unit) isp,
        (select vat.internal_invoice_ref_no,
                       vat.our_vat_no vat_no,
                       vat.cp_vat_no,
                       vat.vat_code,
                       vat.vat_rate,
                       vat.vat_rate_unit,
                       vat.vat_amount_in_inv_cur vat_amount
                  from ivd_invoice_vat_details vat
                 where vat.is_separate_invoice = 'N')vat
 where isd.internal_doc_ref_no = ds.internal_doc_ref_no(+)
   and ds.corporate_id = akc.corporate_id(+)
   and isd.internal_doc_ref_no = isp_c1.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = isp_c2.internal_doc_ref_no(+)
   and isd.internal_doc_ref_no = isp.internal_doc_ref_no(+)
   and isd.internal_invoice_ref_no = vat.internal_invoice_ref_no(+)
union all
select         'Other Charges' section_name,
               'Other Charges' sub_section,
               rownum record_no,
               akc.corporate_id,
               akc.corporate_name,
               akc.address1,
               akc.address2,
               akc.city,
               akc.state,
               akc.country,
               akc.logo_path,
               akc.phone_no,
               akc.fax_no,
               isd.internal_doc_ref_no,
               isd.due_date,
               isd.sales_purchase,
               isd.cp_name,
               isd.supplire_invoice_no cp_item_stock_ref_no,
               '' business_unit,
               isd.self_item_stock_ref_no,
               isd.inco_term_location,
               isd.contract_ref_no self_contract_item_no,
               isd.contract_date,
               isd.notify_party,
               isd.org_name,
               isd.cp_contract_ref_no,
               isd.productandquality_name,
               isd.contract_tolerance,
               isd.contract_quantity,
               isd.contract_qty_unit,
               isd.invoice_ref_no provisional_invoice_no,
               isd.internal_invoice_ref_no,
               isd.product,
               isd.quality,
               isd.invoice_amount amount,
               isd.invoice_amount_unit,
               isd.payment_term,
               isd.invoice_creation_date,
               null invoice_issue_date,
               isd.invoice_quantity,
               isd.invoice_dry_quantity,
               isd.invoice_wet_quantity,
               isd.invoiced_qty_unit,
               isd.moisture,
               isd.invoice_type_name invoice_type,
               isd.stock_size,
               isd.packing,
               isd.provisional_price,
               isd.origin,
               isd.tarriff,
               '' final_qty,
               isd.material_cost final_amount,
               '' pi_number,
               '' provisional_amount,
               '' amount_due,
               isd.addditional_charges,
               isd.taxes,
               isd.contract_type product_type,
               isd.Invoice_Status,
               null pledge_gmr_ref_no,
               null  pledge_gmr_qty,
               null  pledge_stock_ref_no,
               null  pledge_stock_qty,
               null internal_doc_ref_no0,
               null stock_ref_no,
               null stock_qty,
               null gmr_ref_no,
               null gmr_quality,
               null gmr_quantity,
               null price_as_per_defind_uom,
               null item_amount_in_inv_cur,
               null invoiced_price_unit,
               null element_price_unit,
               null total_quantity,
               null gmr_qty_unit,
               null internal_doc_ref_no1,
               null benificiary_name_c1,
               null bank_name_c1,
               null account_no_c1,
               null iban_c1,
               null aba_rtn_c1,
               null instruction_c1,
               null internal_doc_ref_no2,
               null benificiary_name_c2,
               null bank_name_c2,
               null account_no_c2,
               null iban_c2,
               null aba_rtn_c2,
               null instruction_c2,
               null internal_doc_ref_no3,
               null stock_ref_no1,
               null stock_gmr_ref_no,
               null cp_gmr_quantity,
               null stock_qty1,
               null gmr_qty_unit1,
               null payable_element_id,
               null payable_element,
               null analysis,
               null analysis_unit,
               null element_price,
               null invoiced_price_unit1,
               null element_price_unit1,
               null sub_lot_no,
               null element_inv_amount,
               null element_invoiced_qty,
               null element_invoiced_qty_unit,
               null internal_doc_ref_no4,
               null tc_element_id,
               null element_name,
               null tc_rc_sub_lot_no,
               null tc_amount,
               null tc_amount_unit,
               null internal_doc_ref_no5,
               null rc_element_id,
               null element_name1,
               null rc_amount,
               null rc_amount_unit,
               null internal_doc_ref_no6,
               null pen_element_id,
               null element_name2,
               null pen_amount,
               null pen_amount_unit,
               null vat_no,
               null cp_vat_no,
               null vat_code,
               null vat_rate,
               null vat_rate_unit,
               null vat_amount,
               null vat_amount_cur,
               isd.is_inv_draft,
               ioc.other_charge_cost_name cost_name,
               ioc.charge_type,
               ioc.charge_amount_rate,
               ioc.rate_price_unit_name charge_amount_rate_unit,
               ioc.fx_rate,
               ioc.quantity charges_quantity,
               ioc.quantity_unit charges_qty_unit,
               ioc.amount charges_amount,
               ioc.amount_unit charge_amount_unit,
               ioc.invoice_amount charges_invoice_amount,
               ioc.invoice_cur_name charges_invoice_cur_name,
               null tax_code,
               null tax_rate,
               null tax_currency,
               null taxes_fx_rate,
               null Applicable_on,
               null taxes_amount,
               null taxes_amount_unit,
               null taxes_invoice_amount,
               null taxes_invoice_amount_cur,
               isd. is_free_metal,
               isd. is_pledge,
               isd. internal_comments,
               null remarks,
               null yield,
               null gmr_product,
               null child_qty_unit,
               null iban,
               null api_internal_doc_ref_no,
               null api_invoice_ref_no,
               null api_amount_adjusted,
               null api_invoice_currency
       from ioc_d ioc,
            is_d isd,
            ds_document_summary ds,
            v_ak_corporate akc
     where ioc.internal_doc_ref_no = ds.internal_doc_ref_no
              and isd.internal_doc_ref_no = ioc.internal_doc_ref_no
              and ds.corporate_id = akc.corporate_id(+)
union all
select 'Other Taxes' section_name,
       'Other Taxes' sub_section,
       rownum record_no,
       akc.corporate_id,
       akc.corporate_name,
       akc.address1,
       akc.address2,
       akc.city,
       akc.state,
       akc.country,
       akc.logo_path,
       akc.phone_no,
       akc.fax_no,
       isd.internal_doc_ref_no,
       isd.due_date,
       isd.sales_purchase,
       isd.cp_name,
       isd.supplire_invoice_no cp_item_stock_ref_no,
       '' business_unit,
       isd.self_item_stock_ref_no,
       isd.inco_term_location,
       isd.contract_ref_no self_contract_item_no,
       isd.contract_date,
       isd.notify_party,
       isd.org_name,
       isd.cp_contract_ref_no,
       isd.productandquality_name,
       isd.contract_tolerance,
       isd.contract_quantity,
       isd.contract_qty_unit,
       isd.invoice_ref_no provisional_invoice_no,
       isd.internal_invoice_ref_no,
       isd.product,
       isd.quality,
       isd.invoice_amount amount,
       isd.invoice_amount_unit,
       isd.payment_term,
       isd.invoice_creation_date,
       null invoice_issue_date,
       isd.invoice_quantity,
       isd.invoice_dry_quantity,
       isd.invoice_wet_quantity,
       isd.invoiced_qty_unit,
       isd.moisture,
       isd.invoice_type_name invoice_type,
       isd.stock_size,
       isd.packing,
       isd.provisional_price,
       isd.origin,
       isd.tarriff,
       '' final_qty,
       isd.material_cost final_amount,
       '' pi_number,
       '' provisional_amount,
       '' amount_due,
       isd.addditional_charges,
       isd.taxes,
       isd.contract_type product_type,
       isd.Invoice_Status,
       null pledge_gmr_ref_no,
       null  pledge_gmr_qty,
       null  pledge_stock_ref_no,
       null  pledge_stock_qty,
       null internal_doc_ref_no0,
       null stock_ref_no,
       null stock_qty,
       null gmr_ref_no,
       null gmr_quality,
       null gmr_quantity,
       null price_as_per_defind_uom,
       null item_amount_in_inv_cur,
       null invoiced_price_unit,
       null element_price_unit,
       null total_quantity,
       null gmr_qty_unit,
       null internal_doc_ref_no1,
       null benificiary_name_c1,
       null bank_name_c1,
       null account_no_c1,
       null iban_c1,
       null aba_rtn_c1,
       null instruction_c1,
       null internal_doc_ref_no2,
       null benificiary_name_c2,
       null bank_name_c2,
       null account_no_c2,
       null iban_c2,
       null aba_rtn_c2,
       null instruction_c2,
       null internal_doc_ref_no3,
       null stock_ref_no1,
       null stock_gmr_ref_no,
       null cp_gmr_quantity,
       null stock_qty1,
       null gmr_qty_unit1,
       null payable_element_id,
       null payable_element,
       null analysis,
       null analysis_unit,
       null element_price,
       null invoiced_price_unit1,
       null element_price_unit1,
       null sub_lot_no,
       null element_inv_amount,
       null element_invoiced_qty,
       null element_invoiced_qty_unit,
       null internal_doc_ref_no4,
       null tc_element_id,
       null element_name,
       null tc_rc_sub_lot_no,
       null tc_amount,
       null tc_amount_unit,
       null internal_doc_ref_no5,
       null rc_element_id,
       null element_name1,
       null rc_amount,
       null rc_amount_unit,
       null internal_doc_ref_no6,
       null pen_element_id,
       null element_name2,
       null pen_amount,
       null pen_amount_unit,
       null vat_no,
       null cp_vat_no,
       null vat_code,
       null vat_rate,
       null vat_rate_unit,
       null vat_amount,
       null vat_amount_cur,
       isd.is_inv_draft,
       null cost_name,
       null charge_type,
       null charge_amount_rate,
       null charge_amount_rate_unit,
       null fx_rate,
       null charges_quantity,
       null charges_qty_unit,
       null charges_amount,
       null charge_amount_unit,
       null charges_invoice_amount,
       null charges_invoice_cur_name,
       itd.tax_code,
       itd.tax_rate,
       itd.tax_currency,
       itd.fx_rate taxes_fx_rate,
       '' Applicable_on,
       itd.amount taxes_amount,
       itd.tax_currency taxes_amount_unit,
       itd.invoice_amount taxes_invoice_amount,
       itd.invoice_currency taxes_invoice_amount_cur,
       isd.is_free_metal,
       isd.is_pledge,
       isd.internal_comments,
       null remarks,
       null yield,
       null gmr_product,
       null child_qty_unit,
       null iban,
       null api_internal_doc_ref_no,
       null api_invoice_ref_no,
       null api_amount_adjusted,
       null api_invoice_currency
     from itd_d itd,
         is_d isd,
         ds_document_summary ds,
         v_ak_corporate akc
        where itd.internal_doc_ref_no = ds.internal_doc_ref_no
          and isd.internal_doc_ref_no = itd.internal_doc_ref_no
          and ds.corporate_id = akc.corporate_id(+) ;
/
CREATE TABLE IUS_INVOICE_UTILITY_SUMMARY
(
  IUS_ID                         VARCHAR2(15),
  INTERNAL_ACTION_REF_NO         VARCHAR2(15) NOT NULL,    
  SMELTER_ID                     VARCHAR2(15) NOT NULL,
  UTILITY_REF_NO                 VARCHAR2(15) NOT NULL,
  STATUS                         VARCHAR2(15),
  IS_ACTIVE                      CHAR(1)
);



ALTER TABLE IUS_INVOICE_UTILITY_SUMMARY ADD (
  CONSTRAINT PK_IUS PRIMARY KEY (IUS_ID)
);

ALTER TABLE IUS_INVOICE_UTILITY_SUMMARY ADD (
  CONSTRAINT FK_IUS_INTERNAL_ACTION_REF_NO FOREIGN KEY (INTERNAL_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
  CONSTRAINT FK_IUS_SMELTER_ID FOREIGN KEY (SMELTER_ID) REFERENCES PHD_PROFILEHEADERDETAILS (PROFILEID)
);

CREATE SEQUENCE SEQ_IUS
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


alter table IS_INVOICE_SUMMARY add UTILITY_REF_NO varchar2(15);





