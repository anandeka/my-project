begin
  for cc1 in (select dbd.dbd_id,
                     dbd.process,
                     dbd.trade_date
                from dbd_database_dump dbd
               where dbd.corporate_id = 'TST'
               order by dbd.trade_date,
                        dbd.process)
  loop
    for cur_update in (select eod_eom.internal_derivative_ref_no,
                            dt_ref.derivative_ref_no
                       from eod_eom_derivative_journal    eod_eom,
                            dt_derivative_trade@eka_appdb dt,
                            dt_derivative_trade@eka_appdb dt_ref
                      where eod_eom.internal_derivative_ref_no =
                            dt.internal_derivative_ref_no
                        and dt.underlying_instr_ref_no =
                            dt_ref.internal_derivative_ref_no
                        and eod_eom.dbd_id =cc1.dbd_id
                        and dt.underlying_instr_ref_no is not null)
  
  loop
    update eod_eom_derivative_journal eod_eom
       set eod_eom.underlying_derivative_ref_no = cur_update.derivative_ref_no
     where eod_eom.internal_derivative_ref_no =
           cur_update.internal_derivative_ref_no
       and eod_eom.dbd_id = cc1.dbd_id;
  end loop;
  commit;
  end loop;
end;
/

