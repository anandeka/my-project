
declare
  -- Local variables here
  i                      integer;
  pc_corporate_id        varchar2(15);
  pc_process             varchar2(5);
  vc_previous_process_id varchar2(15);
  pd_trade_date          date;
  pc_process_id          varchar2(15);

begin
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
    pc_process_id   := cc.process_id;
    pc_process      := cc.process;
    pd_trade_date   := cc.trade_date;
    pc_corporate_id := cc.corporate_id;
    begin
      select tdc.process_id
        into vc_previous_process_id
        from tdc_trade_date_closure tdc
       where tdc.corporate_id = pc_corporate_id
         and process = pc_process
         and tdc.trade_date =
             (select max(trade_date)
                from tdc_trade_date_closure
               where corporate_id = pc_corporate_id
                 and trade_date < pd_trade_date
                 and process = pc_process);
    exception
      when others then
        vc_previous_process_id := null;
    end;
    delete from aro_ar_original_report where process_id = pc_process_id;
    delete from areor_ar_ele_original_report where process_id = pc_process_id;
    delete from for_feed_original_report where process_id = pc_process_id;
    delete from feor_feed_ele_original_report where process_id = pc_process_id;
    commit;
   
   
    dbms_output.put_line('Arrival / Feed populated for ' || cc.trade_date ||
                         ' :Process id : ' || cc.process_id ||
                         ' Prev Process id:' || vc_previous_process_id);
    -- GMR NEW in the EOM and  GMR Old and updated in the EOM
    insert into aro_ar_original_report
      (process_id,
       eod_trade_date,
       corporate_id,
       corporate_name,
       gmr_ref_no,
       internal_gmr_ref_no,
       product_id,
       product_name,
       quality_id,
       quality_name,
       arrival_status,
       warehouse_id,
       warehouse_name,
       shed_id,
       shed_name,
       conc_base_qty_unit_id,
       conc_base_qty_unit,
       other_charges_amt,
       pay_cur_id,
       pay_cur_code,
       pay_cur_decimal,
       arrival_or_delivery,
       freight_container_charge_amt,
       contract_ref_no,
       internal_contract_ref_no,
       cp_id,
       cp_name,
       gmr_wet_qty,
       gmr_dry_qty)
      select process_id,
             eod_trade_date,
             corporate_id,
             corporate_name,
             gmr_ref_no,
             internal_gmr_ref_no,
             product_id,
             product_name,
             quality_id,
             quality_name,
             arrival_status,
             warehouse_id,
             warehouse_name,
             shed_id,
             shed_name,
             conc_base_qty_unit_id,
             conc_base_qty_unit,
             sum(other_charges_amt),
             pay_cur_id,
             pay_cur_code,
             pay_cur_decimal,
             arrival_or_delivery,
             sum(freight_container_charge_amt),
             contract_ref_no,
             internal_contract_ref_no,
             cp_id,
             cp_name,
             sum(grd_wet_qty),
             sum(grd_dry_qty)
        from aro_ar_original aro
       where aro.process_id = pc_process_id
       group by process_id,
                eod_trade_date,
                corporate_id,
                corporate_name,
                gmr_ref_no,
                internal_gmr_ref_no,
                product_id,
                product_name,
                quality_id,
                quality_name,
                arrival_status,
                warehouse_id,
                warehouse_name,
                shed_id,
                shed_name,
                conc_base_qty_unit_id,
                conc_base_qty_unit,
                pay_cur_id,
                pay_cur_code,
                pay_cur_decimal,
                arrival_or_delivery,
                contract_ref_no,
                internal_contract_ref_no,
                cp_id,
                cp_name;
    commit;
    -- GMR OLD Not in Current Month
    insert into aro_ar_original_report
      (process_id,
       eod_trade_date,
       corporate_id,
       corporate_name,
       gmr_ref_no,
       internal_gmr_ref_no,
       product_id,
       product_name,
       quality_id,
       quality_name,
       arrival_status,
       warehouse_id,
       warehouse_name,
       shed_id,
       shed_name,
       conc_base_qty_unit_id,
       conc_base_qty_unit,
       other_charges_amt,
       pay_cur_id,
       pay_cur_code,
       pay_cur_decimal,
       arrival_or_delivery,
       freight_container_charge_amt,
       contract_ref_no,
       internal_contract_ref_no,
       cp_id,
       cp_name,
       gmr_wet_qty,
       gmr_dry_qty)
      select pc_process_id,
             pd_trade_date,
             aro_prev.corporate_id,
             aro_prev.corporate_name,
             gmr_ref_no,
             internal_gmr_ref_no,
             product_id,
             product_name,
             quality_id,
             quality_name,
             arrival_status,
             warehouse_id,
             warehouse_name,
             shed_id,
             shed_name,
             conc_base_qty_unit_id,
             conc_base_qty_unit,
             other_charges_amt,
             pay_cur_id,
             pay_cur_code,
             pay_cur_decimal,
             arrival_or_delivery,
             freight_container_charge_amt,
             contract_ref_no,
             internal_contract_ref_no,
             cp_id,
             cp_name,
             gmr_wet_qty,
             gmr_dry_qty
        from aro_ar_original_report aro_prev
       where aro_prev.process_id = vc_previous_process_id
         and not exists
       (select 1
                from aro_ar_original_report aro
               where aro.internal_gmr_ref_no = aro_prev.internal_gmr_ref_no
                 and aro.process_id = pc_process_id);
    commit;
  
    insert into areor_ar_ele_original_report
      (process_id,
       internal_gmr_ref_no,
       element_id,
       element_name,
       assay_qty,
       payable_qty,
       section_name,
       payable_amt_price_ccy,
       payable_amt_pay_ccy,
       base_tc_charges_amt,
       esc_desc_tc_charges_amt,
       rc_charges_amt,
       pc_charges_amt,
       element_base_qty_unit_id,
       element_base_qty_unit)
      select pc_process_id,
             internal_gmr_ref_no,
             element_id,
             element_name,
             sum(assay_qty),
             sum(payable_qty),
             section_name,
             sum(payable_amt_price_ccy),
             sum(payable_amt_pay_ccy),
             sum(base_tc_charges_amt),
             sum(esc_desc_tc_charges_amt),
             sum(rc_charges_amt),
             sum(pc_charges_amt),
             element_base_qty_unit_id,
             element_base_qty_unit
        from areo_ar_element_original areo
       where areo.process_id = pc_process_id
       group by process_id,
                internal_gmr_ref_no,
                element_id,
                element_name,
                section_name,
                element_base_qty_unit_id,
                element_base_qty_unit;
  
    commit;
  
    insert into areor_ar_ele_original_report
      (process_id,
       internal_gmr_ref_no,
       element_id,
       element_name,
       assay_qty,
       payable_qty,
       section_name,
       payable_amt_price_ccy,
       payable_amt_pay_ccy,
       base_tc_charges_amt,
       esc_desc_tc_charges_amt,
       rc_charges_amt,
       pc_charges_amt,
       element_base_qty_unit_id,
       element_base_qty_unit)
      select pc_process_id,
             internal_gmr_ref_no,
             element_id,
             element_name,
             assay_qty,
             payable_qty,
             section_name,
             payable_amt_price_ccy,
             payable_amt_pay_ccy,
             base_tc_charges_amt,
             esc_desc_tc_charges_amt,
             rc_charges_amt,
             pc_charges_amt,
             element_base_qty_unit_id,
             element_base_qty_unit
        from areor_ar_ele_original_report areo_prev
       where areo_prev.process_id = vc_previous_process_id
         and not exists
       (select 1
                from areor_ar_ele_original_report areo
               where areo.internal_gmr_ref_no =
                     areo_prev.internal_gmr_ref_no
                 and areo.element_id = areo_prev.element_id
                 and areo.process_id = pc_process_id);   
    commit;
    
    --------feed original data population
    insert into for_feed_original_report
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   product_id,
   product_name,
   quality_id,
   quality_name,
   parent_gmr_ref_no,
   warehouse_id,
   warehouse_name,
   conc_base_qty_unit_id,
   conc_base_qty_unit,
   pay_cur_id,
   pay_cur_code,
   pay_cur_decimal,
   parent_internal_gmr_ref_no,
   other_charges_amt,
   gmr_ref_no,
   internal_gmr_ref_no,
   gmr_wet_qty,
   gmr_dry_qty,
   feeding_point_name,
   pile_name)
  select process_id,
         eod_trade_date,
         corporate_id,
         corporate_name,
         product_id,
         product_name,
         quality_id,
         quality_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         pay_cur_decimal,
         parent_internal_gmr_ref_no,
         sum(other_charges_amt),
         gmr_ref_no,
         internal_gmr_ref_no,
         sum(grd_wet_qty),
         sum(grd_dry_qty),
         feeding_point_name,
         max(pile_name)
    from fco_feed_consumption_original fco
   where fco.process_id =pc_process_id
   group by process_id,
            eod_trade_date,
            corporate_id,
            corporate_name,
            product_id,
            product_name,
            quality_id,
            quality_name,
            parent_gmr_ref_no,
            warehouse_id,
            warehouse_name,
            conc_base_qty_unit_id,
            conc_base_qty_unit,
            pay_cur_id,
            pay_cur_code,
            pay_cur_decimal,
            parent_internal_gmr_ref_no,
            gmr_ref_no,
            internal_gmr_ref_no,
            feeding_point_name;
commit;
insert into for_feed_original_report
  (process_id,
   eod_trade_date,
   corporate_id,
   corporate_name,
   product_id,
   product_name,
   quality_id,
   quality_name,
   parent_gmr_ref_no,
   warehouse_id,
   warehouse_name,
   conc_base_qty_unit_id,
   conc_base_qty_unit,
   pay_cur_id,
   pay_cur_code,
   pay_cur_decimal,
   parent_internal_gmr_ref_no,
   other_charges_amt,
   gmr_ref_no,
   internal_gmr_ref_no,
   gmr_wet_qty,
   gmr_dry_qty,
   feeding_point_name,
   pile_name)
  select pc_process_id,
         pd_trade_date,
         corporate_id,
         corporate_name,
         product_id,
         product_name,
         quality_id,
         quality_name,
         parent_gmr_ref_no,
         warehouse_id,
         warehouse_name,
         conc_base_qty_unit_id,
         conc_base_qty_unit,
         pay_cur_id,
         pay_cur_code,
         pay_cur_decimal,
         parent_internal_gmr_ref_no,
         other_charges_amt,
         gmr_ref_no,
         internal_gmr_ref_no,
         gmr_wet_qty,
         gmr_dry_qty,
         feeding_point_name,
         pile_name         
    from for_feed_original_report  for_prev
   where for_prev.process_id = vc_previous_process_id
     and not exists
   (select 1
            from for_feed_original_report feed
           where feed.parent_internal_gmr_ref_no = for_prev.parent_internal_gmr_ref_no
           and feed.internal_gmr_ref_no = for_prev.internal_gmr_ref_no
             and feed.process_id = pc_process_id); 
  commit;
  insert into feor_feed_ele_original_report
  (process_id,  
   element_id,
   element_name,
   assay_qty,
   payable_qty,
   payable_returnable_type,
   parent_internal_gmr_ref_no,
   section_name,
   qty_type,
   payable_amt_price_ccy,
   payable_amt_pay_ccy,
   base_tc_charges_amt,
   esc_desc_tc_charges_amt,
   rc_charges_amt,
   pc_charges_amt,
   element_base_qty_unit_id,
   element_base_qty_unit,
   internal_gmr_ref_no)
  select process_id,        
         element_id,
         element_name,
         sum(assay_qty),
         sum(payable_qty),
         payable_returnable_type,
         parent_internal_gmr_ref_no,
         section_name,
         qty_type,
         sum(payable_amt_price_ccy),
         sum(payable_amt_pay_ccy),
         sum(base_tc_charges_amt),
         sum(esc_desc_tc_charges_amt),
         sum(rc_charges_amt),
         sum(pc_charges_amt),
         element_base_qty_unit_id,
         element_base_qty_unit,
         internal_gmr_ref_no
    from fceo_feed_con_element_original fceo
   where fceo.process_id = pc_process_id
    group by process_id,            
             element_id,
             element_name,
             payable_returnable_type,
             parent_internal_gmr_ref_no,
             section_name,
             qty_type,
             element_base_qty_unit_id,
             element_base_qty_unit,
             internal_gmr_ref_no;
commit;
       
insert into feor_feed_ele_original_report
  (process_id,
   element_id,
   element_name,
   assay_qty,
   payable_qty,
   payable_returnable_type,
   parent_internal_gmr_ref_no,
   section_name,
   qty_type,
   payable_amt_price_ccy,
   payable_amt_pay_ccy,
   base_tc_charges_amt,
   esc_desc_tc_charges_amt,
   rc_charges_amt,
   pc_charges_amt,
   element_base_qty_unit_id,
   element_base_qty_unit,
   internal_gmr_ref_no)
  select pc_process_id,         
         element_id,
         element_name,
         assay_qty,
         payable_qty,
         payable_returnable_type,
         parent_internal_gmr_ref_no,
         section_name,
         qty_type,
         payable_amt_price_ccy,
         payable_amt_pay_ccy,
         base_tc_charges_amt,
         esc_desc_tc_charges_amt,
         rc_charges_amt,
         pc_charges_amt,
         element_base_qty_unit_id,
         element_base_qty_unit,
         internal_gmr_ref_no
    from feor_feed_ele_original_report fceo_prev
    where fceo_prev.process_id = vc_previous_process_id
     and not exists
   (select 1
            from feor_feed_ele_original_report feed
           where feed.parent_internal_gmr_ref_no = fceo_prev.parent_internal_gmr_ref_no
             and feed.internal_gmr_ref_no = fceo_prev.internal_gmr_ref_no
             and feed.element_id=fceo_prev.element_id
             and feed.process_id = pc_process_id); 
    commit;
  end loop;
end;
/
