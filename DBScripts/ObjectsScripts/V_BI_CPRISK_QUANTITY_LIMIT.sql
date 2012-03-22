CREATE OR REPLACE VIEW V_BI_CPRISK_QUANTITY_LIMIT AS
select tt.corporate_id,
       tt.profileid,
       tt.companyname,
       nvl(cpr.qty_exposure,0) alloted_quantity_limit,
       tt.qty_in_group_base_unit current_quantity_usage,
       tt.qty_in_group_base_unit - nvl(cpr.qty_exposure,0) breach,
       tt. base_qty_unit_id,
       tt.base_qty_unit,
       tt.order_id
  from (select t.corporate_id,
               t.profileid,
               t.companyname,
               abs(sum(t.qty_in_group_base_unit)) qty_in_group_base_unit,
               rank() over(partition by t.corporate_id order by abs(sum(t.qty_in_group_base_unit)) desc) order_id,
               --  t.product_qty_unit_id,
               -- t.product_qty_unit,
               t.group_qty_unit_id base_qty_unit_id,
               t.group_qty_unit    base_qty_unit
          from (select pcm.corporate_id,
                       phd.profileid,
                       phd.companyname,
                       sum((case
                             when pcm.purchase_sales = 'S' then
                              1 ---qty sign not added as risk limit user will enter sepeately for purchase/sales, so total limit considered
                             else
                              1
                           end) *
                           pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                ciqs.item_qty_unit_id,
                                                                pdm.base_quantity_unit,
                                                                ciqs.open_qty)) qty_in_product_base_unit,
                       sum((case
                             when pcm.purchase_sales = 'S' then
                              1 --qty sign not added as risk limit user will enter sepeately for purchase/sales, so total limit considered
                             else
                              1
                           end) *
                           pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                ciqs.item_qty_unit_id,
                                                                gcd.group_qty_unit_id,
                                                                ciqs.open_qty)) qty_in_group_base_unit,
                       qum_pdm.qty_unit_id product_qty_unit_id,
                       qum_pdm.qty_unit product_qty_unit,
                       qum_gp.qty_unit_id group_qty_unit_id,
                       qum_gp.qty_unit group_qty_unit
                  from ciqs_contract_item_qty_status ciqs,
                       pci_physical_contract_item    pci,
                       pcdi_pc_delivery_item         pcdi,
                       pcm_physical_contract_main    pcm,
                       pcpd_pc_product_definition    pcpd,
                       phd_profileheaderdetails      phd,
                       pdm_productmaster             pdm,
                       ak_corporate                  akc,
                       gcd_groupcorporatedetails     gcd,
                       cm_currency_master            cm,
                       qum_quantity_unit_master      qum_pdm,
                       qum_quantity_unit_master      qum_gp
                 where ciqs.internal_contract_item_ref_no =
                       pci.internal_contract_item_ref_no
                   and pci.pcdi_id = pcdi.pcdi_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcm.contract_status <> 'Cancelled'
                   and pcpd.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcm.cp_id = phd.profileid
                   and pcpd.product_id = pdm.product_id
                   and pcm.corporate_id = akc.corporate_id
                   and akc.groupid = gcd.groupid
                   and akc.base_cur_id = cm.cur_id
                   and pdm.base_quantity_unit = qum_pdm.qty_unit_id
                   and gcd.group_qty_unit_id = qum_gp.qty_unit_id
                 group by pcm.corporate_id,
                          phd.profileid,
                          phd.companyname,
                          qum_pdm.qty_unit_id,
                          qum_pdm.qty_unit,
                          qum_gp.qty_unit_id,
                          qum_gp.qty_unit
                union all
                select pcm.corporate_id,
                       phd.profileid,
                       phd.companyname,
                       sum((case
                             when pcm.purchase_sales = 'S' then
                              1 --qty sign not added as risk limit user will enter sepeately for purchase/sales, so total limit considered
                             else
                              1
                           end) *
                           pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                ciqs.qty_unit_id,
                                                                pdm.base_quantity_unit,
                                                                ciqs.payable_qty)) qty_in_product_base_unit,
                       sum((case
                             when pcm.purchase_sales = 'S' then
                              1 --qty sign not added as risk limit user will enter sepeately for purchase/sales, so total limit considered
                             else
                              1
                           end) *
                           pkg_general.f_get_converted_quantity(pdm.product_id,
                                                                ciqs.qty_unit_id,
                                                                gcd.group_qty_unit_id,
                                                                ciqs.payable_qty)) qty_in_group_base_unit,
                       qum_pdm.qty_unit_id product_qty_unit_id,
                       qum_pdm.qty_unit product_qty_unit,
                       qum_gp.qty_unit_id group_qty_unit_id,
                       qum_gp.qty_unit group_qty_unit
                  from cipq_contract_item_payable_qty ciqs,
                       pci_physical_contract_item     pci,
                       pcdi_pc_delivery_item          pcdi,
                       pcm_physical_contract_main     pcm,
                       pcpd_pc_product_definition     pcpd,
                       phd_profileheaderdetails       phd,
                       pdm_productmaster              pdm,
                       ak_corporate                   akc,
                       gcd_groupcorporatedetails      gcd,
                       cm_currency_master             cm,
                       qum_quantity_unit_master       qum_pdm,
                       qum_quantity_unit_master       qum_gp
                 where ciqs.internal_contract_item_ref_no =
                       pci.internal_contract_item_ref_no
                   and pci.pcdi_id = pcdi.pcdi_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcm.contract_status <> 'Cancelled'
                   and pcpd.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcm.cp_id = phd.profileid
                   and pcpd.product_id = pdm.product_id
                   and pcm.corporate_id = akc.corporate_id
                   and akc.groupid = gcd.groupid
                   and pdm.base_quantity_unit = qum_pdm.qty_unit_id
                   and gcd.group_qty_unit_id = qum_gp.qty_unit_id
                   and akc.base_cur_id = cm.cur_id
                 group by pcm.corporate_id,
                          phd.profileid,
                          phd.companyname,
                          qum_pdm.qty_unit_id,
                          qum_pdm.qty_unit,
                          qum_gp.qty_unit_id,
                          qum_gp.qty_unit) t
         group by t.corporate_id,
                  t.profileid,
                  t.companyname,
                  t.group_qty_unit_id,
                  t.group_qty_unit) tt,
       v_bi_cprisk_crc_limits cpr
 where tt.profileid = cpr.profile_id(+)
   and tt.corporate_id = cpr.corporate_id(+)
   and tt.order_id <= 5
order by tt.order_id
