----This correction script has 3 blocks, 
-- 1. cpname,contract ref no
-- 2. Arrival/Feed recon original data population
-- 3. GMR's element having DI price moved to GMR table from DI price table
--Correction provided till Nov-2013 EOM, 
alter table FOR_FEED_ORIGINAL_REPORT add  GMR_REF_NO VARCHAR2 (30);
alter table FOR_FEED_ORIGINAL_REPORT add  INTERNAL_GMR_REF_NO VARCHAR2 (15); 
alter table FEOR_FEED_ELE_ORIGINAL_REPORT  add INTERNAL_GMR_REF_NO VARCHAR2 (15);

CREATE INDEX IDX_AROAR_1 ON ARO_AR_ORIGINAL_REPORT(PROCESS_ID)
/
CREATE INDEX IDX_AREOAR_1 ON AREOR_AR_ELE_ORIGINAL_REPORT(PROCESS_ID)
/
CREATE INDEX IDX_FOROR_1 ON FOR_FEED_ORIGINAL_REPORT(PROCESS_ID)
/
CREATE INDEX IDX_FEOROR_1 ON FEOR_FEED_ELE_ORIGINAL_REPORT(PROCESS_ID)
/
begin
  for cc1 in (select tdc.corporate_id,
                     tdc.trade_date,
                     tdc.process_id,
                     tdc.process
                from tdc_trade_date_closure tdc
               where tdc.corporate_id = 'BLD'
                    --  and tdc.trade_date not in('31-Dec-2013')
                 and to_char(tdc.trade_date, 'yyyy') in
                     ('2011', '2012', '2013')
               order by tdc.trade_date)
  loop
    for cc in (select gmr.internal_gmr_ref_no,
                      gmr.gmr_ref_no,
                      gmr.internal_contract_ref_no,
                      pcm.contract_ref_no,
                      pcm.cp_id,
                      phd.companyname
                 from gmr_goods_movement_record  gmr,
                      pcm_physical_contract_main pcm,
                      phd_profileheaderdetails   phd
                where gmr.process_id = cc1.process_id
                  and pcm.process_id = cc1.process_id
                  and gmr.internal_contract_ref_no =
                      pcm.internal_contract_ref_no
                  and pcm.cp_id = phd.profileid)
    loop
      update aro_ar_original aro
         set aro.internal_contract_ref_no = cc.internal_contract_ref_no,
             aro.cp_id                    = cc.cp_id,
             aro.cp_name                  = cc.companyname,
             aro.contract_ref_no          = cc.contract_ref_no
       where aro.corporate_id = cc1.corporate_id
         and aro.process_id = cc1.process_id
         and aro.internal_gmr_ref_no = cc.internal_gmr_ref_no
         and aro.cp_name is null;
    end loop;
    commit;
  end loop;
end;
/

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
		   and tdc.trade_date < to_date('31-Dec-2013','dd-Mon-yyyy')
                   and to_char(tdc.trade_date, 'yyyy') in
                    ('2011', '2012', '2013')
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
    commit;
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
       cp_name)
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
             cp_name
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
       cp_name)
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
             cp_name
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
   internal_gmr_ref_no)
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
         internal_gmr_ref_no
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
            internal_gmr_ref_no;
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
   internal_gmr_ref_no)
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
         internal_gmr_ref_no
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

declare
  -- data correction for DI based GMR element population
  i                      integer;
  pc_corporate_id        varchar2(15);
  pc_process             varchar2(5); 
  pd_trade_date          date;
  pc_process_id          varchar2(15);

begin
  -- Test statements here
  for cc in (select tdc.corporate_id,
                    tdc.trade_date,
                    tdc.process_id,
                    tdc.process
               from tdc_trade_date_closure tdc
              where tdc.corporate_id = 'BLD'
               and tdc.trade_date < to_date('31-Dec-2013','dd-Mon-yyyy')
                and to_char(tdc.trade_date, 'yyyy') in
                    ('2011', '2012', '2013')
              order by tdc.trade_date)
  loop
    pc_process_id   := cc.process_id;
    pc_process      := cc.process;
    pd_trade_date   := cc.trade_date;
    pc_corporate_id := cc.corporate_id;
    delete from cgcp_conc_gmr_cog_price where process_id=pc_process_id and price_allocation_method = 'DI Based';
    commit;
    delete from tdige_temp_di_gmr_element t
     where t.corporate_id = pc_corporate_id;
    commit;
   
    insert into tdige_temp_di_gmr_element
      (corporate_id, internal_gmr_ref_no, element_id)
      select spq.corporate_id,
             spq.internal_gmr_ref_no,
             spq.element_id
        from spq_stock_payable_qty spq
       where spq.is_active = 'Y'
         and spq.is_stock_split = 'N'
         and spq.process_id = pc_process_id
         and not exists
       (select *
                from cgcp_conc_gmr_cog_price cgcp
               where cgcp.internal_gmr_ref_no = spq.internal_gmr_ref_no
                 and cgcp.element_id = spq.element_id
                 and cgcp.process_id = pc_process_id)
       group by spq.corporate_id,
                spq.internal_gmr_ref_no,
                spq.element_id;
    commit;
    
  
    --
    -- Update PCDI_ID from GRD table
    --      
    for cur_pcdi_id in (select grd.internal_gmr_ref_no,
                               max(grd.pcdi_id) pcdi_id
                          from grd_goods_record_detail grd
                         where grd.process_id = pc_process_id
                           and grd.is_deleted = 'N'
                           and grd.status = 'Active'
                           and grd.tolling_stock_type in ('None Tolling')
                         group by grd.internal_gmr_ref_no)
    loop
    
      update tdige_temp_di_gmr_element t
         set t.pcdi_id = cur_pcdi_id.pcdi_id
       where t.internal_gmr_ref_no = cur_pcdi_id.internal_gmr_ref_no
         and t.corporate_id = pc_corporate_id;
    
    end loop;
    commit;
    
    --
    -- Populate CGCP table for DI based GMR and Element Combination
    --
    insert into cgcp_conc_gmr_cog_price
      (process_id,
       corporate_id,
       internal_gmr_ref_no,
       gmr_ref_no,
       element_id,
       payable_qty,
       payable_qty_unit_id,
       contract_price,
       price_unit_id,
       price_unit_cur_id,
       price_unit_cur_code,
       price_unit_weight,
       price_unit_weight_unit_id,
       price_unit_weight_unit,
       fixed_qty,
       unfixed_qty,
       price_basis,
       is_final_priced,
       pay_in_price_unit_id,
       pay_in_cur_id,
       pay_in_cur_code,
       pay_in_price_unit_weight,
       pay_in_price_unit_wt_unit_id,
       pay_in_price_unit_weight_unit,
       contract_price_in_pay_in,
       pcdi_id,
       fx_price_to_pay,
       price_allocation_method)
      select cccp.process_id,
             cccp.corporate_id,
             t.internal_gmr_ref_no,
             gmr.gmr_ref_no gmr_ref_no,
             cccp.element_id,
             cccp.payable_qty,
             cccp.payable_qty_unit_id,
             cccp.contract_price,
             cccp.price_unit_id,
             cccp.price_unit_cur_id,
             cccp.price_unit_cur_code,
             cccp.price_unit_weight,
             cccp.price_unit_weight_unit_id,
             cccp.price_unit_weight_unit,
             cccp.fixed_qty,
             cccp.unfixed_qty,
             cccp.price_basis,
             cccp.is_final_priced,
             cccp.pay_in_price_unit_id,
             cccp.pay_in_cur_id,
             cccp.pay_in_cur_code,
             cccp.pay_in_price_unit_weight,
             cccp.pay_in_price_unit_wt_unit_id,
             cccp.pay_in_price_unit_weight_unit,
             cccp.contract_price_in_pay_in,
             cccp.pcdi_id,
             cccp.fx_price_to_pay,
             'DI Based'
        from cccp_conc_contract_cog_price cccp,
             tdige_temp_di_gmr_element    t,
             gmr_goods_movement_record    gmr
       where cccp.process_id = pc_process_id
         and cccp.pcdi_id = t.pcdi_id
         and cccp.element_id = t.element_id
         and t.corporate_id = pc_corporate_id
         and t.internal_gmr_ref_no = gmr.internal_gmr_ref_no
         and gmr.process_id = pc_process_id;  
    commit;    
  end loop;
end;
/
