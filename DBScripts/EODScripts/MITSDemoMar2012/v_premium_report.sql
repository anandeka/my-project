create or replace view v_premium_report (
corporate_id,
product_id,
product_name,
base_qty_unit_id,
base_qty_unit,
base_cur_id,
base_cur_code,
month_1_name,
month_2_name,
month_3_name,
month_4_name,
month_5_name,
month_6_name,
p_month_1_qty,
p_month_2_qty,
p_month_3_qty,
p_month_4_qty,
p_month_5_qty,
p_month_6_qty,
s_month_1_qty,
s_month_2_qty,
s_month_3_qty,
s_month_4_qty,
s_month_5_qty,
s_month_6_qty,
p_month_1_premium,
p_month_2_premium,
p_month_3_premium,
p_month_4_premium,
p_month_5_premium,
p_month_6_premium,
s_month_1_premium,
s_month_2_premium,
s_month_3_premium,
s_month_4_premium,
s_month_5_premium,
s_month_6_premium,
net_month_1_qty,
net_month_2_qty,
net_month_3_qty,
net_month_4_qty,
net_month_5_qty,
net_month_6_qty,
net_month_1_premium,
net_month_2_premium,
net_month_3_premium,
net_month_4_premium,
net_month_5_premium,
net_month_6_premium)
AS
select corporate_id,
       product_id,
       product_name,
       base_qty_unit_id,
       base_qty_unit,
       base_cur_id,
       base_cur_code,
       month_1_name,
       month_2_name,
       month_3_name,
       month_4_name,
       month_5_name,
       month_6_name,
       p_month_1_qty,
       p_month_2_qty,
       p_month_3_qty,
       p_month_4_qty,
       p_month_5_qty,
       p_month_6_qty,
       s_month_1_qty,
       s_month_2_qty,
       s_month_3_qty,
       s_month_4_qty,
       s_month_5_qty,
       s_month_6_qty,
       nvl(p_month_1_premium_value /
           decode(p_month_1_qty, 0, null, p_month_1_qty),
           0) p_month_1_premium,
       nvl(p_month_2_premium_value /
           decode(p_month_2_qty, 0, null, p_month_2_qty),
           0) p_month_2_premium,
       nvl(p_month_3_premium_value /
           decode(p_month_3_qty, 0, null, p_month_3_qty),
           0) p_month_3_premium,
       nvl(p_month_4_premium_value /
           decode(p_month_4_qty, 0, null, p_month_4_qty),
           0) p_month_4_premium,
       nvl(p_month_5_premium_value /
           decode(p_month_5_qty, 0, null, p_month_5_qty),
           0) p_month_5_premium,
       nvl(p_month_6_premium_value /
           decode(p_month_6_qty, 0, null, p_month_6_qty),
           0) p_month_6_premium,
       nvl(s_month_1_premium_value /
           decode(s_month_1_qty, 0, null, s_month_1_qty),
           0) s_month_1_premium,
       nvl(s_month_2_premium_value /
           decode(s_month_2_qty, 0, null, s_month_2_qty),
           0) s_month_2_premium,
       nvl(s_month_3_premium_value /
           decode(s_month_3_qty, 0, null, s_month_3_qty),
           0) s_month_3_premium,
       nvl(s_month_4_premium_value /
           decode(s_month_4_qty, 0, null, s_month_4_qty),
           0) s_month_4_premium,
       nvl(s_month_5_premium_value /
           decode(s_month_5_qty, 0, null, s_month_5_qty),
           0) s_month_5_premium,
       nvl(s_month_6_premium_value /
           decode(s_month_6_qty, 0, null, s_month_6_qty),
           0) s_month_6_premium,
       p_month_1_qty - s_month_1_qty net_month_1_qty,
       p_month_2_qty - s_month_2_qty net_month_2_qty,
       p_month_3_qty - s_month_3_qty net_month_3_qty,
       p_month_4_qty - s_month_4_qty net_month_4_qty,
       p_month_5_qty - s_month_5_qty net_month_5_qty,
       p_month_6_qty - s_month_6_qty net_month_6_qty,
       decode(sign(p_month_1_qty - s_month_1_qty),
              -1,
              nvl(s_month_1_premium_value /
                  decode(s_month_1_qty, 0, null, s_month_1_qty),
                  0),
              nvl(p_month_1_premium_value /
                  decode(p_month_1_qty, 0, null, p_month_1_qty),
                  0)) net_month_1_premium,
       decode(sign(p_month_2_qty - s_month_2_qty),
              -1,
              nvl(s_month_2_premium_value /
                  decode(s_month_2_qty, 0, null, s_month_2_qty),
                  0),
              nvl(p_month_2_premium_value /
                  decode(p_month_2_qty, 0, null, p_month_2_qty),
                  0)) net_month_2_premium,
       decode(sign(p_month_3_qty - s_month_3_qty),
              -1,
              nvl(s_month_3_premium_value /
                  decode(s_month_3_qty, 0, null, s_month_3_qty),
                  0),
              nvl(p_month_3_premium_value /
                  decode(p_month_3_qty, 0, null, p_month_3_qty),
                  0)) net_month_3_premium,
       decode(sign(p_month_4_qty - s_month_4_qty),
              -1,
              nvl(s_month_4_premium_value /
                  decode(s_month_4_qty, 0, null, s_month_4_qty),
                  0),
              nvl(p_month_4_premium_value /
                  decode(p_month_4_qty, 0, null, p_month_4_qty),
                  0)) net_month_4_premium,
       decode(sign(p_month_5_qty - s_month_5_qty),
              -1,
              nvl(s_month_5_premium_value /
                  decode(s_month_5_qty, 0, null, s_month_5_qty),
                  0),
              nvl(p_month_5_premium_value /
                  decode(p_month_5_qty, 0, null, p_month_5_qty),
                  0)) net_month_5_premium,
       decode(sign(p_month_6_qty - s_month_6_qty),
              -1,
              nvl(s_month_6_premium_value /
                  decode(s_month_6_qty, 0, null, s_month_6_qty),
                  0),
              nvl(p_month_6_premium_value /
                  decode(p_month_6_qty, 0, null, p_month_6_qty),
                  0)) net_month_6_premium
  from (select t.corporate_id,
               t.product_id,
               t.product_name,
               t.base_qty_unit_id,
               t.base_qty_unit,
               t.base_cur_id,
               t.base_cur_code,
               to_char(sysdate, 'Mon-YYYY') month_1_name,
               to_char(add_months(sysdate, 1), 'Mon-yyyy') month_2_name,
               to_char(add_months(sysdate, 2), 'Mon-yyyy') month_3_name,
               to_char(add_months(sysdate, 3), 'Mon-yyyy') month_4_name,
               to_char(add_months(sysdate, 4), 'Mon-yyyy') month_5_name,
               to_char(add_months(sysdate, 5), 'Mon-yyyy') month_6_name,
               sum(case
                     when t.no_of_months = 0 and t.purchase_sales = 'P' then
                      qty
                     else
                      0
                   end) p_month_1_qty,
               sum(case
                     when t.no_of_months = 0 and t.purchase_sales = 'S' then
                      qty
                     else
                      0
                   end) s_month_1_qty,
               sum(case
                     when t.no_of_months = 1 and t.purchase_sales = 'P' then
                      qty
                     else
                      0
                   end) p_month_2_qty,
               sum(case
                     when t.no_of_months = 1 and t.purchase_sales = 'S' then
                      qty
                     else
                      0
                   end) s_month_2_qty,
               sum(case
                     when t.no_of_months = 2 and t.purchase_sales = 'P' then
                      qty
                     else
                      0
                   end) p_month_3_qty,
               sum(case
                     when t.no_of_months = 2 and t.purchase_sales = 'S' then
                      qty
                     else
                      0
                   end) s_month_3_qty,
               sum(case
                     when t.no_of_months = 3 and t.purchase_sales = 'P' then
                      qty
                     else
                      0
                   end) p_month_4_qty,
               sum(case
                     when t.no_of_months = 3 and t.purchase_sales = 'S' then
                      qty
                     else
                      0
                   end) s_month_4_qty,
               sum(case
                     when t.no_of_months = 4 and t.purchase_sales = 'P' then
                      qty
                     else
                      0
                   end) p_month_5_qty,
               sum(case
                     when t.no_of_months = 4 and t.purchase_sales = 'S' then
                      qty
                     else
                      0
                   end) s_month_5_qty,
               sum(case
                     when t.no_of_months = 5 and t.purchase_sales = 'P' then
                      qty
                     else
                      0
                   end) p_month_6_qty,
               sum(case
                     when t.no_of_months = 5 and t.purchase_sales = 'S' then
                      qty
                     else
                      0
                   end) s_month_6_qty,
               sum(case
                     when t.no_of_months = 0 and t.purchase_sales = 'P' then
                      qty * premium
                     else
                      0
                   end) as p_month_1_premium_value,
               sum(case
                     when t.no_of_months = 1 and t.purchase_sales = 'P' then
                      qty * premium
                     else
                      0
                   end) as p_month_2_premium_value,
               sum(case
                     when t.no_of_months = 2 and t.purchase_sales = 'P' then
                      qty * premium
                     else
                      0
                   end) as p_month_3_premium_value,
               sum(case
                     when t.no_of_months = 3 and t.purchase_sales = 'P' then
                      qty * premium
                     else
                      0
                   end) as p_month_4_premium_value,
               sum(case
                     when t.no_of_months = 4 and t.purchase_sales = 'P' then
                      qty * premium
                     else
                      0
                   end) as p_month_5_premium_value,
               sum(case
                     when t.no_of_months = 5 and t.purchase_sales = 'P' then
                      qty * premium
                     else
                      0
                   end) as p_month_6_premium_value,
               sum(case
                     when t.no_of_months = 0 and t.purchase_sales = 'S' then
                      qty * premium
                     else
                      0
                   end) as s_month_1_premium_value,
               sum(case
                     when t.no_of_months = 1 and t.purchase_sales = 'S' then
                      qty * premium
                     else
                      0
                   end) as s_month_2_premium_value,
               sum(case
                     when t.no_of_months = 2 and t.purchase_sales = 'S' then
                      qty * premium
                     else
                      0
                   end) as s_month_3_premium_value,
               sum(case
                     when t.no_of_months = 3 and t.purchase_sales = 'S' then
                      qty * premium
                     else
                      0
                   end) as s_month_4_premium_value,
               sum(case
                     when t.no_of_months = 4 and t.purchase_sales = 'S' then
                      qty * premium
                     else
                      0
                   end) as s_month_5_premium_value,
               sum(case
                     when t.no_of_months = 5 and t.purchase_sales = 'S' then
                      qty * premium
                     else
                      0
                   end) as s_month_6_premium_value
          from (select pcm.corporate_id,
                       pcm.purchase_sales,
                       pdm.product_id,
                       pdm.product_desc product_name,
                       qum.qty_unit_id base_qty_unit_id,
                       qum.qty_unit base_qty_unit,
                       cm.cur_id base_cur_id,
                       cm.cur_code base_cur_code,
                       pkg_general.f_get_converted_quantity(pdm.product_id,
                                                            pci.item_qty_unit_id,
                                                            pdm.base_quantity_unit,
                                                            pci.item_qty) qty,
                       pcqpd.premium_disc_value * nvl(pffxd.fixed_fx_rate, 1) premium,
                       months_between(trunc((case
                                              when pcbpd.price_basis = 'Fixed' then
                                               pcm.issue_date
                                              else
                                               pofh.qp_end_date
                                            end),
                                            'mm'),
                                      trunc(sysdate, 'mm')) no_of_months
                  from pci_physical_contract_item pci,
                       pcm_physical_contract_main pcm,
                       pcdi_pc_delivery_item pcdi,
                       ak_corporate akc,
                       pcpd_pc_product_definition pcpd,
                       pdm_productmaster pdm,
                       pcpq_pc_product_quality pcpq,
                       pcdb_pc_delivery_basis pcdb,
                       pcqpd_pc_qual_premium_discount pcqpd,
                       v_ppu_pum ppu,
                       poch_price_opt_call_off_header poch,
                       pocd_price_option_calloff_dtls pocd,
                       pcbpd_pc_base_price_detail pcbpd,
                       pcbph_pc_base_price_header pcbph,
                       (select *
                          from pofh_price_opt_fixation_header pfh
                         where pfh.internal_gmr_ref_no is null
                           and pfh.is_active = 'Y') pofh,
                       qum_quantity_unit_master qum,
                       cm_currency_master cm,
                       pffxd_phy_formula_fx_details pffxd
                 where pcm.internal_contract_ref_no =
                       pcdi.internal_contract_ref_no
                   and pcdi.pcdi_id = pci.pcdi_id
                   and pci.pcpq_id = pcpq.pcpq_id
                   and pcm.contract_status = 'In Position'
                   and pcm.corporate_id = akc.corporate_id
                   and pcm.internal_contract_ref_no =
                       pcpd.internal_contract_ref_no
                   and pcpd.product_id = pdm.product_id
                   and pcpd.pcpd_id = pcpq.pcpd_id
                   and pcpq.is_active = 'Y'
                   and pci.is_active = 'Y'
                   and pcdi.is_active = 'Y'
                   and pcdb.is_active = 'Y'
                   and pcqpd.is_active = 'Y'
                   and pci.pcdb_id = pcdb.pcdb_id
                   and pcdb.internal_contract_ref_no =
                       pcdi.internal_contract_ref_no
                   and pci.pcpq_id = pcpq.pcpq_id
                   and pci.pcdb_id = pcdb.pcdb_id
                   and pcm.contract_type = 'BASEMETAL'
                   and pcqpd.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and ppu.cur_id = akc.base_cur_id
                   and ppu.weight_unit_id = pdm.base_quantity_unit
                   and nvl(ppu.weight, 1) = 1
                   and ppu.product_id = pdm.product_id
                   and poch.pcdi_id = pcdi.pcdi_id
                   and poch.poch_id = pocd.poch_id
                   and pocd.pcbpd_id = pcbpd.pcbpd_id
                   and pcbpd.pcbph_id = pcbph.pcbph_id
                   and poch.is_active = 'Y'
                   and pocd.is_active = 'Y'
                   and pcbpd.is_active = 'Y'
                   and pcbph.is_active = 'Y'
                   and pocd.pocd_id = pofh.pocd_id(+)
                   and pdm.base_quantity_unit = qum.qty_unit_id
                   and cm.cur_id = akc.base_cur_id
                   and pffxd.pffxd_id = pcqpd.pffxd_id
                   and pffxd.is_active = 'Y'
                union all
                select pcm.corporate_id,
                       pcm.purchase_sales,
                       pdm.product_id,
                       pdm.product_desc product_name,
                       qum.qty_unit_id base_qty_unit_id,
                       qum.qty_unit base_qty_unit,
                       cm.cur_id base_cur_id,
                       cm.cur_code base_cur_code,
                       pkg_general.f_get_converted_quantity(pdm.product_id,
                                                            pci.item_qty_unit_id,
                                                            pdm.base_quantity_unit,
                                                            pci.item_qty) qty,
                       pcqpd.premium_disc_value * nvl(pffxd.fixed_fx_rate, 1) premium,
                       months_between(trunc((case
                                              when pcbpd.price_basis = 'Fixed' then
                                               pcm.issue_date
                                              else
                                               pfqpp.qp_period_to_date
                                            end),
                                            'mm'),
                                      trunc(sysdate, 'mm')) no_of_months
                  from pci_physical_contract_item     pci,
                       pcm_physical_contract_main     pcm,
                       pcdi_pc_delivery_item          pcdi,
                       ak_corporate                   akc,
                       pcpd_pc_product_definition     pcpd,
                       pdm_productmaster              pdm,
                       pcpq_pc_product_quality        pcpq,
                       pcdb_pc_delivery_basis         pcdb,
                       pcqpd_pc_qual_premium_discount pcqpd,
                       qum_quantity_unit_master       qum,
                       cm_currency_master             cm,
                       v_ppu_pum                      ppu,
                       pcipf_pci_pricing_formula      pcipf,
                       pcbph_pc_base_price_header     pcbph,
                       pcbpd_pc_base_price_detail     pcbpd,
                       ppfh_phy_price_formula_header  ppfh,
                       pfqpp_phy_formula_qp_pricing   pfqpp,
                       pffxd_phy_formula_fx_details   pffxd
                 where pcm.internal_contract_ref_no =
                       pcdi.internal_contract_ref_no
                   and pcdi.pcdi_id = pci.pcdi_id
                   and pci.pcpq_id = pcpq.pcpq_id
                   and pcm.contract_status = 'In Position'
                   and pcm.corporate_id = akc.corporate_id
                   and pcm.internal_contract_ref_no =
                       pcpd.internal_contract_ref_no
                   and pcpd.product_id = pdm.product_id
                   and pcpd.pcpd_id = pcpq.pcpd_id
                   and pcpq.is_active = 'Y'
                   and pci.is_active = 'Y'
                   and pcdi.is_active = 'Y'
                   and pcdb.is_active = 'Y'
                   and pcqpd.is_active = 'Y'
                   and pci.pcdb_id = pcdb.pcdb_id
                   and pcdb.internal_contract_ref_no =
                       pcdi.internal_contract_ref_no
                   and pci.pcpq_id = pcpq.pcpq_id
                   and pci.pcdb_id = pcdb.pcdb_id
                   and pcm.contract_type = 'BASEMETAL'
                   and pcqpd.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and ppu.cur_id = akc.base_cur_id
                   and ppu.weight_unit_id = pdm.base_quantity_unit
                   and nvl(ppu.weight, 1) = 1
                   and ppu.product_id = pdm.product_id
                   and pdm.base_quantity_unit = qum.qty_unit_id
                   and cm.cur_id = akc.base_cur_id
                   and pci.internal_contract_item_ref_no =
                       pcipf.internal_contract_item_ref_no
                   and pcipf.pcbph_id = pcbph.pcbph_id
                   and pcbph.pcbph_id = pcbpd.pcbph_id
                   and pci.is_active = 'Y'
                   and pcipf.is_active = 'Y'
                   and pcbpd.is_active = 'Y'
                   and pcbph.is_active = 'Y'
                   and ppfh.ppfh_id = pfqpp.ppfh_id
                   and ppfh.pcbpd_id = pcbpd.pcbpd_id
                   and ppfh.is_active = 'Y'
                   and pfqpp.is_active = 'Y'
                   and pffxd.pffxd_id = pcqpd.pffxd_id
                   and pffxd.is_active = 'Y') t
         group by t.product_id,
                  t.product_name,
                  t.base_qty_unit_id,
                  t.base_qty_unit,
                  t.base_cur_id,
                  t.base_cur_code,
                  t.corporate_id) tt;
