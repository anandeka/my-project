CREATE OR REPLACE VIEW V_BI_RECENT_TRADES_BY_PRODUCT
AS 
select t2.corporate_id,
       t2.product_id,
       t2.product_name,
       t2.contract_ref_no,
       t2.trade_type,
       to_date(t2.issue_date, 'dd-Mon-yyyy') issue_date,
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
                   and pci.pcpq_id = pcpq.pcpq_id
                   and pcpq.pcpq_id = pci.pcpq_id
                   and pcpd.pcpd_id = pcpq.pcpd_id
                   and pcm.internal_contract_ref_no =
                       cqs.internal_contract_ref_no
                   and pdm.product_id = pcpd.product_id
                   and pcpd.product_id = pdm.product_id
                   and cqs.item_qty_unit_id = ucm.from_qty_unit_id
                   and pdm.base_quantity_unit = ucm.to_qty_unit_id
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
                 order by t.created_date desc) t1
         order by t1.product_id,
                  t1.created_date) t2
 where t2.order_seq < 6
 order by t2.corporate_id,
          t2.product_id
