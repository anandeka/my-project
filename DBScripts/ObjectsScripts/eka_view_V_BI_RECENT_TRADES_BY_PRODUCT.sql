CREATE OR REPLACE VIEW V_BI_RECENT_TRADES_BY_PRODUCT AS
select t2.corporate_id,
       t2.product_id,
       t2.product_name,
       t2.contract_ref_no,
       t2.trade_type,
       to_date(t2.issue_date, 'dd-Mon-RRRR') issue_date,
       t2.item_qty position_quantity,
       t2.base_quantity_unit qty_unit_id,
       t2.qty_unit base_qty_unit
  from (select t1.contract_ref_no,
               t1.corporate_id,
               t1.created_date,
               t1.product_id,
               t1.product_name,
               t1.trade_type,
               t1.base_quantity_unit,
               t1.item_qty,
               t1.qty_unit,
               t1.issue_date,
               row_number() over(partition by t1.corporate_id, t1.product_id order by t1.created_date desc) order_seq
        --  row_number() over(partition by t1.corporate_id, t1.product_id order by t1.created_date desc) seq
          from (select t.contract_ref_no,
                       t.corporate_id,
                       t.created_date,
                       t.issue_date,
                       (case
                         when pcm.contract_type = 'BASEMETAL' and
                              pcm.purchase_sales = 'P' and
                              pcm.is_tolling_contract = 'N' then
                          'Physical Purchase'
                         when pcm.contract_type = 'BASEMETAL' and
                              pcm.purchase_sales = 'S' and
                              pcm.is_tolling_contract = 'N' then
                          'Physical Sales'
                         when pcm.contract_type = 'CONCENTRATES' and
                              pcm.purchase_sales = 'P' and
                              pcm.is_tolling_contract = 'N' then
                          'Physical Purchase'
                         when pcm.contract_type = 'CONCENTRATES' and
                              pcm.purchase_sales = 'S' and
                              pcm.is_tolling_contract = 'N' then
                          'Physical Sales'
                         when pcm.contract_type = 'CONCENTRATES' and
                              pcm.purchase_sales = 'P' and
                              pcm.is_tolling_contract = 'Y' then
                          'Sell Tolling'
                         when pcm.contract_type = 'CONCENTRATES' and
                              pcm.purchase_sales = 'S' and
                              pcm.is_tolling_contract = 'Y' then
                          'Buy Tolling'
                         else
                          'NA'
                       end) trade_type,
                       pdm.product_id,
                       pdm.product_desc product_name,
                       pdm.base_quantity_unit,
                       (cqs.total_qty * ucm.multiplication_factor) item_qty,
                       qum.qty_unit
                  from (select substr(max(case
                                            when pcmul.contract_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             pcmul.contract_ref_no
                                          end),
                                      24) contract_ref_no,
                               substr(max(case
                                            when pcmul.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             pcmul.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when pcmul.internal_contract_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             pcmul.internal_contract_ref_no
                                          end),
                                      24) internal_contract_ref_no,
                               substr(max(case
                                            when pcmul.issue_date is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             pcmul.issue_date
                                          end),
                                      24) issue_date,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from pcmul_phy_contract_main_ul pcmul,
                               axs_action_summary         axs
                         where pcmul.internal_action_ref_no =
                               axs.internal_action_ref_no
                         group by pcmul.internal_contract_ref_no) t,
                       pdm_productmaster pdm,
                       pcm_physical_contract_main pcm,
                       pci_physical_contract_item pci,
                       pcdi_pc_delivery_item pcdi,
                       pcpd_pc_product_definition pcpd,
                       pcpq_pc_product_quality pcpq,
                       cqs_contract_qty_status cqs,
                       ucm_unit_conversion_master ucm,
                       qum_quantity_unit_master qum
                 where pcdi.internal_contract_ref_no =
                       t.internal_contract_ref_no
                   and pci.pcdi_id = pcdi.pcdi_id
                   and pcm.internal_contract_ref_no =
                       pcdi.internal_contract_ref_no
                   and pcm.approval_status <> 'Rejected' ----added for 78648
                   and pci.pcpq_id = pcpq.pcpq_id
                   and pcpq.pcpq_id = pci.pcpq_id
                   and pcpd.pcpd_id = pcpq.pcpd_id
                   and pcm.internal_contract_ref_no =
                       cqs.internal_contract_ref_no
                   and pdm.product_id = pcpd.product_id
                   and pcpd.product_id = pdm.product_id
                   and cqs.item_qty_unit_id = ucm.from_qty_unit_id
                   and pdm.base_quantity_unit = ucm.to_qty_unit_id
                      --AND    pcm.contract_type = 'BASEMETAL' --Bug 63238 fix-11-May-2012 commented
                   and pcm.contract_status in
                       ('In Position', 'Pending Approval')
                   and pci.is_active = 'Y'
                   and pdm.base_quantity_unit = qum.qty_unit_id
                   and pdm.is_deleted = 'N'
                 group by t.contract_ref_no,
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
                union all
                select tab.contract_ref_no || '-' ||
                       pci.del_distribution_item_no contract_ref_no,
                       tab.corporate_id,
                       tab.created_date,
                       tab.issue_date,
                       (case
                         when pcm.contract_type = 'BASEMETAL' and
                              pcm.purchase_sales = 'P' and
                              pcm.is_tolling_contract = 'N' then
                          'Physical Purchase'
                         when pcm.contract_type = 'BASEMETAL' and
                              pcm.purchase_sales = 'S' and
                              pcm.is_tolling_contract = 'N' then
                          'Physical Sales'
                         when pcm.contract_type = 'CONCENTRATES' and
                              pcm.purchase_sales = 'P' and
                              pcm.is_tolling_contract = 'N' then
                          'Physical Purchase'
                         when pcm.contract_type = 'CONCENTRATES' and
                              pcm.purchase_sales = 'S' and
                              pcm.is_tolling_contract = 'N' then
                          'Physical Sales'
                         when pcm.contract_type = 'CONCENTRATES' and
                              pcm.purchase_sales = 'P' and
                              pcm.is_tolling_contract = 'Y' then
                          'Sell Tolling'
                         when pcm.contract_type = 'CONCENTRATES' and
                              pcm.purchase_sales = 'S' and
                              pcm.is_tolling_contract = 'Y' then
                          'Buy Tolling'
                         else
                          'NA'
                       end) trade_type,
                       pdm.product_id,
                       pdm.product_desc product_name,
                       pdm.base_quantity_unit,
                       (pcieq.payable_qty * ucm.multiplication_factor) item_qty,
                       qum.qty_unit
                  from v_pci_element_qty pcieq,
                       pci_physical_contract_item pci,
                       pcdi_pc_delivery_item pcdi,
                       pcm_physical_contract_main pcm,
                       aml_attribute_master_list aml,
                       ucm_unit_conversion_master ucm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       (select substr(max(case
                                            when pcmul.contract_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             pcmul.contract_ref_no
                                          end),
                                      24) contract_ref_no,
                               substr(max(case
                                            when pcmul.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             pcmul.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when pcmul.internal_contract_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             pcmul.internal_contract_ref_no
                                          end),
                                      24) internal_contract_ref_no,
                               substr(max(case
                                            when pcmul.issue_date is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             pcmul.issue_date
                                          end),
                                      24) issue_date,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from pcmul_phy_contract_main_ul pcmul,
                               axs_action_summary         axs
                         where pcmul.internal_action_ref_no =
                               axs.internal_action_ref_no
                         group by pcmul.internal_contract_ref_no) tab
                 where pcieq.internal_contract_item_ref_no =
                       pci.internal_contract_item_ref_no
                   and tab.contract_ref_no = pcm.contract_ref_no
                   and pcdi.pcdi_id = pci.pcdi_id
                   and pcm.internal_contract_ref_no =
                       pcdi.internal_contract_ref_no
                   and pcm.approval_status <> 'Rejected' ---added for 78648
                   and aml.attribute_id = pcieq.element_id
                   and aml.underlying_product_id = pdm.product_id
                   and pdm.base_quantity_unit = qum.qty_unit_id
                   and pcieq.qty_unit_id = ucm.from_qty_unit_id
                   and pdm.base_quantity_unit = ucm.to_qty_unit_id
                   and pcm.contract_type = 'CONCENTRATES'
                   and pcm.contract_status in
                       ('In Position', 'Pending Approval')
                   and pci.is_active = 'Y'
                   and pdm.is_deleted = 'N'
                   and (pcieq.payable_qty * ucm.multiplication_factor) <> 0
                --Bug 63238 fix end
                --derivatives start
                --Bug 63342 fix start
                union all
                select dt.derivative_ref_no contract_ref_no,
                       dt.corporate_id,
                       tab.created_date,
                       tab.trade_date issue_date,
                       decode(dt.trade_type,
                              'Buy',
                              'Derivative Buy',
                              'Sell',
                              'Derivative Sell',
                              null) trade_type,
                       pdm.product_id,
                       pdm.product_desc product_name,
                       pdm.base_quantity_unit,
                       round(dt.open_quantity * ucm.multiplication_factor, 5) item_qty,
                       qum.qty_unit
                  from dt_derivative_trade dt,
                       drm_derivative_master drm,
                       dim_der_instrument_master dim,
                       irm_instrument_type_master irm,
                       pdd_product_derivative_def pdd,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       ucm_unit_conversion_master ucm,
                       (select substr(max(case
                                            when dtul.derivative_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dtul.derivative_ref_no
                                          end),
                                      24) derivative_ref_no,
                               substr(max(case
                                            when dtul.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dtul.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when dtul.internal_derivative_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dtul.internal_derivative_ref_no
                                          end),
                                      24) internal_derivative_ref_no,
                               substr(max(case
                                            when dtul.trade_date is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dtul.trade_date
                                          end),
                                      24) trade_date,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from dtul_derivative_trade_ul dtul,
                               axs_action_summary       axs
                         where dtul.internal_action_ref_no =
                               axs.internal_action_ref_no
                         group by dtul.internal_derivative_ref_no) tab
                 where dt.dr_id = drm.dr_id
                   and tab.internal_derivative_ref_no =
                       dt.internal_derivative_ref_no
                   and dt.approval_status <> 'Rejected' ----added for 78648
                   and drm.instrument_id = dim.instrument_id
                   and dim.instrument_type_id = irm.instrument_type_id
                   and dim.product_derivative_id = pdd.derivative_def_id
                   and pdd.product_id = pdm.product_id
                   and dt.status = 'Verified'
                   and dt.quantity_unit_id = ucm.from_qty_unit_id
                   and pdm.base_quantity_unit = ucm.to_qty_unit_id
                   and pdm.base_quantity_unit = qum.qty_unit_id
                   and dt.open_quantity <> 0
                --Bug 63342 fix end        
                ) t1
         order by t1.product_id,
                  t1.created_date) t2
 where t2.order_seq < 6
 order by t2.corporate_id,
          t2.product_id
/