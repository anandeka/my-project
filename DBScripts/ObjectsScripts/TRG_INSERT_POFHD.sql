create or replace trigger trg_pop_pofh_price

  after insert or update on pofh_price_opt_fixation_header
  for each row
declare
  -- local variables here

  vd_from_date          date;
  vd_to_date            date;
  vd_instrument_id      varchar2(30);
  vc_is_any_day_pricing varchar2(1);

begin

  if inserting then
    begin
      select ppfd.instrument_id,
             pocd.is_any_day_pricing
        into vd_instrument_id,
             vc_is_any_day_pricing
        from pcm_physical_contract_main     pcm,
             pcdi_pc_delivery_item          pcdi,
             poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd
       where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         and pcdi.pcdi_id = poch.pcdi_id
         and pcm.contract_status = 'In Position'
         and pcdi.is_active = 'Y'
         and pocd.pocd_id = :new.pocd_id
         and poch.is_active = 'Y'
         and pocd.poch_id = poch.poch_id
         and pocd.is_active = 'Y'
         and :new.is_active = 'Y'
         and pcbpd.pcbpd_id = pocd.pcbpd_id
         and pcbpd.is_active = 'Y'
         and ppfh.pcbpd_id = pcbpd.pcbpd_id
         and ppfd.ppfh_id = ppfh.ppfh_id
         and ppfh.is_active = 'Y'
         and ppfd.is_active = 'Y';
    exception
      when no_data_found then
        vd_instrument_id      := null;
        vc_is_any_day_pricing := null;
    end;
  end if;
  if vc_is_any_day_pricing = 'N' then
    vd_from_date := :new.qp_start_date;
    vd_to_date   := :new.qp_end_date;
    while vd_from_date <= vd_to_date
    
    loop
      -- Here need to find holiday and insert
      begin
        if f_is_day_holiday(vd_instrument_id, vd_from_date) = 'false' then
          insert into pofhd_pofh_daily
            (pofh_id,
             pocd_id,
             internal_gmr_ref_no,
             qp_start_date,
             qp_end_date,
             priced_date,
             qty_to_be_fixed,
             priced_qty,
             no_of_prompt_days,
             per_day_pricing_qty,
             final_price,
             finalize_date,
             version,
             is_active,
             avg_price_in_price_in_cur,
             avg_fx,
             no_of_prompt_days_fixed,
             event_name,
             delta_priced_qty,
             final_price_in_pricing_cur)
          values
            (:new.pofh_id,
             :new.pocd_id,
             :new.internal_gmr_ref_no,
             :new.qp_start_date,
             :new.qp_end_date,
             vd_from_date,
             :new.qty_to_be_fixed,
             :new.priced_qty,
             :new.no_of_prompt_days,
             :new.per_day_pricing_qty,
             :new.final_price,
             :new.finalize_date,
             :new.version,
             :new.is_active,
             :new.avg_price_in_price_in_cur,
             :new.avg_fx,
             :new.no_of_prompt_days_fixed,
             :new.event_name,
             :new.delta_priced_qty,
             :new.final_price_in_pricing_cur);
        end if;
      exception
        when others then
          null;
          dbms_output.put_line(' ERROR ' || sqlerrm);
      end;
      vd_from_date := vd_from_date + 1;
    end loop;
  
  elsif vc_is_any_day_pricing = 'Y' then
  
    vd_to_date := :new.qp_end_date;
    while f_is_day_holiday(vd_instrument_id, vd_to_date) = 'true'
    loop
      vd_to_date := vd_to_date - 1;
    end loop;
    -- Here need to find holiday and insert
    begin
      insert into pofhd_pofh_daily
        (pofh_id,
         pocd_id,
         internal_gmr_ref_no,
         qp_start_date,
         qp_end_date,
         priced_date,
         qty_to_be_fixed,
         priced_qty,
         no_of_prompt_days,
         per_day_pricing_qty,
         final_price,
         finalize_date,
         version,
         is_active,
         avg_price_in_price_in_cur,
         avg_fx,
         no_of_prompt_days_fixed,
         event_name,
         delta_priced_qty,
         final_price_in_pricing_cur)
      values
        (:new.pofh_id,
         :new.pocd_id,
         :new.internal_gmr_ref_no,
         :new.qp_start_date,
         :new.qp_end_date,
         vd_to_date,
         :new.qty_to_be_fixed,
         :new.priced_qty,
         :new.no_of_prompt_days,
         -- :new.per_day_pricing_qty,
         :new.qty_to_be_fixed,
         :new.final_price,
         :new.finalize_date,
         :new.version,
         :new.is_active,
         :new.avg_price_in_price_in_cur,
         :new.avg_fx,
         :new.no_of_prompt_days_fixed,
         :new.event_name,
         :new.delta_priced_qty,
         :new.final_price_in_pricing_cur);
    
    exception
      when others then
        null;
        dbms_output.put_line(' ERROR ' || sqlerrm);
    end;
  end if;

  if updating then
    if :new.is_active = 'N' then
      update pofhd_pofh_daily
         set is_active = 'N'
       where pofh_id = :new.pofh_id;
    
    elsif :new.per_day_pricing_qty <> :old.per_day_pricing_qty or
          :new.qty_to_be_fixed <> :old.qty_to_be_fixed then
      update pofhd_pofh_daily pofhd
         set pofhd.per_day_pricing_qty = (:new.qty_to_be_fixed /
                                         :old.no_of_prompt_days),
             pofhd.qty_to_be_fixed     = :new.qty_to_be_fixed
       where pofh_id = :new.pofh_id;
    end if;
  
  end if;

exception
  when others then
    null;
    dbms_output.put_line(' ERROR ' || sqlerrm);
  
end;
/
