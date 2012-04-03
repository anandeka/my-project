create or replace view v_pci_element_qty as
select t.internal_contract_item_ref_no,
       t.element_id,
       sum(t.open_payable_qty)open_payable_qty,--open payable qty for this item
       sum(t.gmr_payable_qty)gmr_payable_qty,--gmr level payable qty for this item
       sum(t.payable_qty) payable_qty,--net payable qty for this element
       t.qty_unit_id
  from (select cipq.internal_contract_item_ref_no,
               cipq.element_id,
               sum(nvl(cipq.payable_qty,0)) open_payable_qty,
               0 gmr_payable_qty,               
               sum(nvl(cipq.payable_qty,0)) payable_qty,               
               cipq.qty_unit_id
          from cipq_contract_item_payable_qty cipq
         where cipq.is_active = 'Y'
         group by cipq.internal_contract_item_ref_no,
                  cipq.element_id,
                  cipq.qty_unit_id
        union all
        select grd.internal_contract_item_ref_no,
               spq.element_id,
               0 open_payable_qty,
               sum(spq.payable_qty) gmr_payable_qty,               
               sum(spq.payable_qty) payable_qty,
               spq.qty_unit_id
          from spq_stock_payable_qty   spq,
               grd_goods_record_detail grd
         where spq.internal_grd_ref_no = grd.internal_grd_ref_no
           and spq.is_active = 'Y'
           and spq.is_stock_split='N'
         group by grd.internal_contract_item_ref_no,
                  spq.element_id,
                  spq.qty_unit_id
        union all
        select grd.internal_contract_item_ref_no,
               spq.element_id,
               0 open_payable_qty,
               sum(spq.payable_qty) gmr_payable_qty,               
               sum(spq.payable_qty) payable_qty,
               spq.qty_unit_id
          from spq_stock_payable_qty spq,
               dgrd_delivered_grd    grd
         where spq.internal_dgrd_ref_no = grd.internal_dgrd_ref_no
           and spq.is_active = 'Y'
           and spq.is_stock_split='N'
         group by grd.internal_contract_item_ref_no,
                  spq.element_id,
                  spq.qty_unit_id) t
 group by t.internal_contract_item_ref_no,
          t.element_id,
          t.qty_unit_id;