create or replace view v_pcdi_exchange_detail as
   SELECT   t.corporate_id, t.pcdi_id, t.element_id, t.instrument_id,
            t.instrument_name, t.derivative_def_id, t.derivative_def_name,
            t.exchange_id, t.exchange_name
       FROM ced_contract_exchange_detail t
   GROUP BY t.corporate_id,
            t.pcdi_id,
            t.element_id,
            t.instrument_id,
            t.instrument_name,
            t.derivative_def_id,
            t.derivative_def_name,
            t.exchange_id,
            t.exchange_name;