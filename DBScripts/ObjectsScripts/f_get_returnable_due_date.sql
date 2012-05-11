create or replace function f_get_returnable_due_date(pc_activity_action_id varchar2,
                                                     pc_stock_id           varchar2,
                                                     pc_element_id         varchar2)
  return date is
  returnable_due_date   date;
  v_activity_date       date;
  v_due_date_days       number(25, 10);
  v_due_date_activity   varchar2(20);
  v_internal_gmr_ref_no varchar2(15);
begin
  --dbms_output.put_line('hello');
  begin
    --To get Event Details & Internal_GMR_Ref_No of Passed Stock & Element
    select pcpch.due_date_days,
           pcpch.due_date_activity,
           grd.internal_gmr_ref_no
      into v_due_date_days,
           v_due_date_activity,
           v_internal_gmr_ref_no
      from grd_goods_record_detail        grd,
           pci_physical_contract_item     pci,
           pcdi_pc_delivery_item          pcdi,
           dipch_di_payablecontent_header dipch,
           pcpch_pc_payble_content_header pcpch
     where grd.internal_contract_item_ref_no =
           pci.internal_contract_item_ref_no
       and pci.pcdi_id = pcdi.pcdi_id
       and pcdi.pcdi_id = dipch.pcdi_id
       and pcpch.pcpch_id = dipch.pcpch_id
       and pcpch.payable_type = 'Returnable'
       and dipch.is_active = 'Y'
       and pcpch.is_active = 'Y'
       and pcpch.element_id = pc_element_id
       and grd.internal_grd_ref_no = pc_stock_id;
  
    if v_due_date_activity = 'Shipment' then
      select axs.eff_date
        into v_activity_date
        from agmr_action_gmr        agmr,
             gam_gmr_action_mapping gam,
             axs_action_summary     axs
       where gam.internal_gmr_ref_no = agmr.internal_gmr_ref_no
         and gam.action_no = agmr.action_no
         and axs.internal_action_ref_no = gam.internal_action_ref_no
         and axs.action_id = agmr.gmr_latest_action_action_id
         and axs.status = 'Active'
         and agmr.gmr_latest_action_action_id in
             ('shipmentDetail', 'railDetail', 'truckDetail', 'airDetail',
              'warehouseReceipt')
         and agmr.internal_gmr_ref_no = v_internal_gmr_ref_no;
    end if;
  
    if v_due_date_activity = 'Landing' then
      select axs.eff_date
        into v_activity_date
        from agmr_action_gmr        agmr,
             gam_gmr_action_mapping gam,
             axs_action_summary     axs
       where gam.internal_gmr_ref_no = agmr.internal_gmr_ref_no
         and gam.action_no = agmr.action_no
         and axs.internal_action_ref_no = gam.internal_action_ref_no
         and axs.action_id = agmr.gmr_latest_action_action_id
         and axs.status = 'Active'
         and agmr.gmr_latest_action_action_id in
             ('landingDetail', 'warehouseReceipt')
         and agmr.internal_gmr_ref_no = v_internal_gmr_ref_no;
    end if;
  
    if v_due_date_activity = 'Sampling' then
      select axs.eff_date
        into v_activity_date
        from ash_assay_header   ash,
             axs_action_summary axs
       where axs.internal_action_ref_no = ash.internal_action_ref_no
         and ash.assay_type = 'Weighing and Sampling Assay'
         and ash.is_active = 'Y'
         and nvl(ash.is_delete, 'N') = 'N'
         and axs.action_id = 'CREATE_WNS_ASSAY'
         and axs.status = 'Active'
         and ash.internal_gmr_ref_no = v_internal_gmr_ref_no
         and ash.internal_grd_ref_no = pc_stock_id;
    end if;
  
    /*if v_due_date_activity = 'Assay Finalization' then
    
    end if;*/
  
    returnable_due_date := v_activity_date + nvl(v_due_date_days, 0);
  
    --print msg start
    /*dbms_output.put_line(v_due_date_days);
    dbms_output.put_line(v_due_date_activity);
    dbms_output.put_line(v_internal_gmr_ref_no);
    dbms_output.put_line(v_activity_date);
    dbms_output.put_line(returnable_due_date);*/
    --print msg end
  
  exception
    when others then
      returnable_due_date := null;
  end;
  return returnable_due_date;
end f_get_returnable_due_date;
/
