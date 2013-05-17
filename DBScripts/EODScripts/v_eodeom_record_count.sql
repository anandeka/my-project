create or replace view v_eodeom_record_count as
select tdc.corporate_id,
       tdc.trade_date,
       tdc.process,
       dbd.dbd_id,
       tdc.process_id,
       dbd.start_date dump_log_from,
       dbd.end_date dump_log_to,
       (select count(*)
          from gmr_goods_movement_record gmr
         where gmr.process_id = tdc.process_id) gmr_count,
       (select count(*)
          from grd_goods_record_detail grd
         where grd.process_id = tdc.process_id) grd_count,
       (select count(*)
          from spq_stock_payable_qty spq
         where spq.process_id = tdc.process_id) spq_count,
       (select count(*)
          from pcm_physical_contract_main pcm
         where pcm.process_id = tdc.process_id) pcm_count,
       (select count(*)
          from pci_physical_contract_item pci
         where pci.process_id = tdc.process_id) pci_count,
       (select count(*)
          from pcdi_pc_delivery_item pcdi
         where pcdi.process_id = tdc.process_id) pcdi_count
  from tdc_trade_date_closure tdc,
       dbd_database_dump      dbd
 where tdc.corporate_id = dbd.corporate_id
   and tdc.trade_date = dbd.trade_date
   and tdc.process = dbd.process;