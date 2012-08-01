create or replace trigger "TRG_INSERT_DT_QTY_LOG"
/**************************************************************************************************
           Trigger Name                       : TRG_INSERT_DT_QTY_LOG
           Author                             : Venu
           Created Date                       : 17th May 2012
           Purpose                            : To Insert into DT_QTY_LOG Table

           Modification History

           Modified Date  :
           Modified By  :
           Modify Description :

   ***************************************************************************************************/
  after insert or update or delete on dt_derivative_trade
  for each row
declare
  v_total_qty      number(25, 4);
  v_open_qty       number(25, 4);
  v_closed_qty     number(25, 4);
  v_exercised_qty  number(25, 4);
  v_expired_qty    number(25, 4);
  v_total_lots     number(5);
  v_open_lots      number(5);
  v_closed_lots    number(5);
  v_exercised_lots number(5);
  v_expired_lots   number(5);
begin
  --
  -- If updating then put the delta for Quantity columns as Old - New
  -- If inserting put the new value as is as Delta
  --
  if updating then
    --Qty Unit is Not Updated
    if (:new.quantity_unit_id = :old.quantity_unit_id) then
    
      v_total_qty      := nvl(:new.total_quantity, 0) -
                          nvl(:old.total_quantity, 0);
      v_open_qty       := nvl(:new.open_quantity, 0) -
                          nvl(:old.open_quantity, 0);
      v_closed_qty     := nvl(:new.closed_quantity, 0) -
                          nvl(:old.closed_quantity, 0);
      v_exercised_qty  := nvl(:new.exercised_quantity, 0) -
                          nvl(:old.exercised_quantity, 0);
      v_expired_qty    := nvl(:new.expired_quantity, 0) -
                          nvl(:old.expired_quantity, 0);
      v_total_lots     := nvl(:new.total_lots, 0) - nvl(:old.total_lots, 0);
      v_open_lots      := nvl(:new.open_lots, 0) - nvl(:old.open_lots, 0);
      v_closed_lots    := nvl(:new.closed_lots, 0) -
                          nvl(:old.closed_lots, 0);
      v_exercised_lots := nvl(:new.exercised_lots, 0) -
                          nvl(:old.exercised_lots, 0);
      v_expired_lots   := nvl(:new.expired_lots, 0) -
                          nvl(:old.expired_lots, 0);
    
      if nvl(:new.status, 'XXX') = 'Delete' then
        v_total_qty  := 0 - nvl(:old.total_quantity, 0);
        v_open_qty   := (-1) * nvl(:old.open_quantity, 0);
        v_total_lots := (-1) * nvl(:old.total_lots, 0);
        v_open_lots  := (-1) * nvl(:old.open_lots, 0);
      end if;
    
      if v_total_qty <> 0 or v_open_qty <> 0 or v_closed_qty <> 0 or
         v_exercised_qty <> 0 or v_expired_qty <> 0 or v_total_lots <> 0 or
         v_open_lots <> 0 or v_closed_lots <> 0 or v_exercised_lots <> 0 or
         v_expired_lots <> 0 then
        insert into dt_qty_log
          (internal_derivative_ref_no,
           derivative_ref_no,
           internal_action_ref_no,
           dr_id,
           corporate_id,
           status,
           quantity_unit_id,
           total_quantity_delta,
           open_quantity_delta,
           closed_quantity_delta,
           exercised_quantity_delta,
           expired_quantity_delta,
           total_lots_delta,
           open_lots_delta,
           closed_lots_delta,
           exercised_lots_delta,
           expired_lots_delta,
           entry_type)
        values
          (:new.internal_derivative_ref_no,
           :new.derivative_ref_no,
           :new.latest_internal_action_ref_no,
           :new.dr_id,
           :new.corporate_id,
           :new.status,
           :new.quantity_unit_id,
           v_total_qty,
           v_open_qty,
           v_closed_qty,
           v_exercised_qty,
           v_expired_qty,
           v_total_lots,
           v_open_lots,
           v_closed_lots,
           v_exercised_lots,
           v_expired_lots,
           'Update');
      end if;
    elsif deleting then
      insert into dt_qty_log
        (internal_derivative_ref_no,
         derivative_ref_no,
         internal_action_ref_no,
         dr_id,
         corporate_id,
         status,
         quantity_unit_id,
         total_quantity_delta,
         open_quantity_delta,
         closed_quantity_delta,
         exercised_quantity_delta,
         expired_quantity_delta,
         total_lots_delta,
         open_lots_delta,
         closed_lots_delta,
         exercised_lots_delta,
         expired_lots_delta,
         entry_type)
      values
        (:new.internal_derivative_ref_no,
         :new.derivative_ref_no,
         :new.latest_internal_action_ref_no,
         :new.dr_id,
         :new.corporate_id,
         :new.status,
         :new.quantity_unit_id,
         :new.total_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.total_quantity),
         :new.open_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.open_quantity),
         :new.closed_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.closed_quantity),
         :new.exercised_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.exercised_quantity),
         :new.expired_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.expired_quantity),
         :new.total_lots - :old.total_lots,
         :new.open_lots - :old.open_lots,
         :new.closed_lots - :old.closed_lots,
         :new.exercised_lots - :old.exercised_lots,
         :new.expired_lots - :old.expired_lots,
         'Delete');
    else
      --Qty Unit is Updated
      insert into dt_qty_log
        (internal_derivative_ref_no,
         derivative_ref_no,
         internal_action_ref_no,
         dr_id,
         corporate_id,
         status,
         quantity_unit_id,
         total_quantity_delta,
         open_quantity_delta,
         closed_quantity_delta,
         exercised_quantity_delta,
         expired_quantity_delta,
         total_lots_delta,
         open_lots_delta,
         closed_lots_delta,
         exercised_lots_delta,
         expired_lots_delta,
         entry_type)
      values
        (:new.internal_derivative_ref_no,
         :new.derivative_ref_no,
         :new.latest_internal_action_ref_no,
         :new.dr_id,
         :new.corporate_id,
         :new.status,
         :new.quantity_unit_id,
         :new.total_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.total_quantity),
         :new.open_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.open_quantity),
         :new.closed_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.closed_quantity),
         :new.exercised_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.exercised_quantity),
         :new.expired_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.expired_quantity),
         :new.total_lots - :old.total_lots,
         :new.open_lots - :old.open_lots,
         :new.closed_lots - :old.closed_lots,
         :new.exercised_lots - :old.exercised_lots,
         :new.expired_lots - :old.expired_lots,
         'Update');
    
    end if;
  
  else
    --
    -- New Entry ( Entry Type=Insert)
    --
    insert into dt_qty_log
      (internal_derivative_ref_no,
       derivative_ref_no,
       internal_action_ref_no,
       dr_id,
       corporate_id,
       status,
       quantity_unit_id,
       total_quantity_delta,
       open_quantity_delta,
       closed_quantity_delta,
       exercised_quantity_delta,
       expired_quantity_delta,
       total_lots_delta,
       open_lots_delta,
       closed_lots_delta,
       exercised_lots_delta,
       expired_lots_delta,
       entry_type)
    values
      (:new.internal_derivative_ref_no,
       :new.derivative_ref_no,
       :new.latest_internal_action_ref_no,
       :new.dr_id,
       :new.corporate_id,
       :new.status,
       :new.quantity_unit_id,
       :new.total_quantity,
       :new.open_quantity,
       :new.closed_quantity,
       :new.exercised_quantity,
       :new.expired_quantity,
       :new.total_lots,
       :new.open_lots,
       :new.closed_lots,
       :new.exercised_lots,
       :new.expired_lots,
       'Insert');
  
  end if;
end;
/
