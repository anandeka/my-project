create or replace view v_bi_fwd_position_by_product as
select t.corporate_id,
       t.product_id,
       t.product_desc,
       t.forward_month,
       t.forward_month_order,
       sum(nvl(t.net_qty_online, 0)) online_qty,
       sum(nvl(t.net_qty_eod, 0)) eod_qty,
       t.base_qty_unit_id,
       t.base_qty_unit
  from (select cpm.corporate_id,
               'Dummy' section_name,
               pdm.product_id,
               pdm.product_desc,
               (case
                 when dpm.month_count <= 4 then
                  to_char(add_months(sysdate, dpm.month_count), 'Mon')
                 else
                  'Beyond'
               end) forward_month,
               (dpm.month_count + 1) forward_month_order,
               0               net_qty_online,
               0               net_qty_eod,
               qum.qty_unit_id base_qty_unit_id,
               qum.qty_unit    base_qty_unit
          from pdm_productmaster pdm,
               qum_quantity_unit_master qum,
               cpm_corporateproductmaster cpm,
               ak_corporate akc,
               (select (rownum - 1) month_count
                  from user_objects
                 where rownum < 7) dpm
         where pdm.base_quantity_unit = qum.qty_unit_id
           and cpm.product_id = pdm.product_id
           and cpm.corporate_id = akc.corporate_id
          -- and cpm.corporate_id = 'EKA'
        --   and cpm.product_id = 'PDM-161'
         group by dpm.month_count,
                  cpm.corporate_id,
                  pdm.product_id,
                  pdm.product_desc,
                  qum.qty_unit_id,
                  qum.qty_unit
        union all
        select temp.corporate_id,
               temp.section_name,
               temp.product_id,
               temp.product_desc,
               (case
                 when temp.delivery_date <= last_day(trunc(sysdate)) then
                  to_char(sysdate, 'Mon')
                 else
                  (case
                 when to_char(temp.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 1), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 1), 'Mon')
                 when to_char(temp.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 2), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 2), 'Mon')
                 when to_char(temp.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 3), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 3), 'Mon')
                 when to_char(temp.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 4), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 4), 'Mon')
                 else
                  'Beyond'
               end) end) forward_month,
               (case
                 when temp.delivery_date <= last_day(trunc(sysdate)) then
                  1
                 else
                  (case
                 when to_char(temp.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 1), 'Mon-yyyy') then
                  2
                 when to_char(temp.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 2), 'Mon-yyyy') then
                  3
                 when to_char(temp.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 3), 'Mon-yyyy') then
                  4
                 when to_char(temp.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 4), 'Mon-yyyy') then
                  5
                 else
                  6
               end) end) forward_month_order,
               temp.net_qty_online,
               temp.net_qty_eod,
               temp.base_qty_unit_id,
               temp.base_qty_unit
          from (select pcm.corporate_id,
                       'EOD' section_name,
                       pcpd.product_id,
                       pdm.product_desc,
                       (case
                         when pci.expected_delivery_month is not null and
                              pci.expected_delivery_year is not null then
                          to_date('01-' || pci.expected_delivery_month || '-' ||
                                  pci.expected_delivery_year,
                                  'dd-Mon-yyyy')
                         else
                          trunc(sysdate)
                       end) delivery_date,
                       0 net_qty_online,
                       sum((case
                             when pcm.purchase_sales = 'P' then
                              1
                             else
                              -1
                           end) *
                           pkg_general.f_get_converted_quantity(pcpd.product_id,
                                                                ciqs.item_qty_unit_id,
                                                                pdm.base_quantity_unit,
                                                                ciqs.open_qty)) net_qty_eod,
                       pdm.base_quantity_unit base_qty_unit_id,
                       qum.qty_unit base_qty_unit
                  from pcdi_pc_delivery_item@eka_eoddb pcdi,
                       tdc_trade_date_closure@eka_eoddb tdc,
                       pcm_physical_contract_main@eka_eoddb pcm,
                       pcpd_pc_product_definition@eka_eoddb pcpd,
                       pdm_productmaster@eka_eoddb pdm,
                       pci_physical_contract_item@eka_eoddb pci,
                       ciqs_contract_item_qty_status@eka_eoddb ciqs,
                       qum_quantity_unit_master@eka_eoddb qum,
                       (select max(tdc.trade_date) trade_date,
                               akc.corporate_id
                          from tdc_trade_date_closure@eka_eoddb tdc,
                               ak_corporate@eka_eoddb           akc
                         where tdc.corporate_id = akc.corporate_id
                         group by akc.corporate_id) tdc_latest
                 where pcdi.process_id = tdc.process_id
                   and tdc.trade_date = tdc_latest.trade_date
                   and tdc.corporate_id = tdc_latest.corporate_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcdi.process_id = pcm.process_id
                   and pcm.internal_contract_ref_no =
                       pcpd.internal_contract_ref_no
                   and pcm.process_id = pcpd.process_id
                   and pcpd.input_output = 'Input'
                   and pcpd.product_id = pdm.product_id
                   and pcdi.pcdi_id = pci.pcdi_id
                   and pcdi.process_id = pci.process_id
                   and pci.internal_contract_item_ref_no =
                       ciqs.internal_contract_item_ref_no
                   and pci.process_id = ciqs.process_id
                   and pdm.base_quantity_unit = qum.qty_unit_id
                   and pcdi.is_active = 'Y'
                   and pcm.is_active = 'Y'
                   and pcpd.is_active = 'Y'
                   and pdm.is_active = 'Y'
                   and ciqs.is_active = 'Y'
                   and qum.is_active = 'Y'
                 group by pcm.corporate_id,
                          pcpd.product_id,
                          pdm.product_desc,
                          pci.expected_delivery_month,
                          pci.expected_delivery_year,
                          pdm.base_quantity_unit,
                          qum.qty_unit) temp
        union all
        select pci.corporate_id,
               'Online' section_name,
               pci.product_id,
               pci.product_name product_desc,
               (case
                 when pci.delivery_date <= last_day(trunc(sysdate)) then
                  to_char(sysdate, 'Mon')
                 else
                  (case
                 when to_char(pci.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 1), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 1), 'Mon')
                 when to_char(pci.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 2), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 2), 'Mon')
                 when to_char(pci.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 3), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 3), 'Mon')
                 when to_char(pci.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 4), 'Mon-yyyy') then
                  to_char(add_months(sysdate, 4), 'Mon')
                 else
                  'Beyond'
               end) end) forward_month,
               (case
                 when pci.delivery_date <= last_day(trunc(sysdate)) then
                  1
                 else
                  (case
                 when to_char(pci.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 1), 'Mon-yyyy') then
                  2
                 when to_char(pci.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 2), 'Mon-yyyy') then
                  3
                 when to_char(pci.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 3), 'Mon-yyyy') then
                  4
                 when to_char(pci.delivery_date, 'Mon-yyyy') =
                      to_char(add_months(sysdate, 4), 'Mon-yyyy') then
                  5
                 else
                  6
               end) end) forward_month_order,
               sum(pci.open_qty * pci.qty_conv * pci.pos_sign) net_qty_online,
               0 net_qty_eod,
               pci.base_qty_unit_id,
               pci.base_qty_unit
          from v_bi_contract_open_position pci
         group by pci.corporate_id,
                  pci.product_id,
                  pci.product_name,
                  pci.delivery_date,
                  pci.base_qty_unit_id,
                  pci.base_qty_unit) t
 group by t.corporate_id,
          t.product_id,
          t.product_desc,
          t.forward_month,
          t.forward_month_order,
          t.base_qty_unit_id,
          t.base_qty_unit
