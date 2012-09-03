declare
  cursor gmr_frist_Int_Action_No is
  
    SELECT distinct ASH.ASH_ID  shipmentAshId,
                    gmr.gmr_first_int_action_ref_no gmr_first_int_action_ref_no
      FROM ash_assay_header ash, gmr_goods_movement_record gmr
     WHERE ash.internal_gmr_ref_no = gmr.internal_gmr_ref_no
       AND ash.assay_type = 'Shipment Assay'
       AND gmr.is_deleted = 'N'
       AND ash.is_active = 'Y'
       AND NVL(ash.is_delete, 'N') = 'N';

begin

  for gmr_frist_Int_Action_No_Rows in gmr_frist_Int_Action_No loop
  
    update ASH_ASSAY_HEADER ash
       set ASH.INTERNAL_ACTION_REF_NO = gmr_frist_Int_Action_No_Rows.gmr_first_int_action_ref_no
     where ASH.ASH_ID = gmr_frist_Int_Action_No_Rows.shipmentAshId
       and ASH.ASSAY_TYPE = 'Shipment Assay';
  end loop;
end;