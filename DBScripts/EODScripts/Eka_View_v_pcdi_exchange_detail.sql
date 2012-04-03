create or replace view v_pcdi_exchange_detail as 
select t.process_id,
       pci.pcdi_id,
       t.element_id,
       t.instrument_id,
       t.instrument_name,
       t.derivative_def_id,
       t.derivative_def_name,
       t.exchange_id,
       t.exchange_name
  from v_contract_exchange_detail t,
       pci_physical_contract_item pci
 where pci.process_id = t.process_id
   and pci.internal_contract_item_ref_no = t.internal_contract_item_ref_no
 group by t.process_id,
          pci.pcdi_id,
          t.element_id,
          t.instrument_id,
          t.instrument_name,
          t.derivative_def_id,
          t.derivative_def_name,
          t.exchange_id,
          t.exchange_name
