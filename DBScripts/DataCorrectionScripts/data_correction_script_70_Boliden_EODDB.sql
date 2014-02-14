 begin
execute immediate 'truncate table gpq_gmr_payable_qty';
  for cc in (select tdc.corporate_id,
                    tdc.trade_date,
                    tdc.process_id,
                    tdc.process
               from tdc_trade_date_closure tdc
              where tdc.corporate_id = 'BLD'
       and tdc.trade_date <= to_date('31-Jan-2014','dd-Mon-yyyy')
                   and to_char(tdc.trade_date, 'yyyy') in
                    ('2011', '2012', '2013','2014')
              order by tdc.trade_date)
  loop
   

insert into gpq_gmr_payable_qty
    (process_id, internal_gmr_ref_no, element_id, payable_qty, assay_qty,qty_unit_id)
    select cc.process_id,
           spq.internal_gmr_ref_no,
           spq.element_id,
           sum(nvl(spq.payable_qty, 0)) payable_qty,
           sum(nvl(spq.assay_content, 0)) assay_qty,
           spq.qty_unit_id
      from SPQ_STOCK_PAYABLE_QTY spq
     where spq.is_active = 'Y'
       and spq.is_stock_split = 'N'      
       and spq.process_id = cc.process_id
     group by spq.process_id,
              spq.internal_gmr_ref_no,
              spq.element_id,
              spq.qty_unit_id;

commit;
end loop;
end;
              