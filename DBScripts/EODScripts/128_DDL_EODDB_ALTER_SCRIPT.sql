DROP TABLE TEMP_GMR_INVOICE;
ALTER TABLE TGI_TEMP_GMR_INVOICE DROP COLUMN NEW_INVOICE_PRICE_UNIT_ID;
ALTER TABLE TGI_TEMP_GMR_INVOICE DROP COLUMN INVOICE_CURRENCY_ID;
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD IS_NEW_FINAL_INVOICE VARCHAR2(1) DEFAULT 'N';
ALTER TABLE ISR_INTRASTAT_GRD ADD IS_NEW_FINAL_INVOICE VARCHAR2(1) DEFAULT 'N';
ALTER TABLE ISR2_ISR_INVOICE ADD IS_NEW_FINAL_INVOICE VARCHAR2(1) DEFAULT 'N';
ALTER TABLE TGI_TEMP_GMR_INVOICE DROP COLUMN INVOICE_CUR_CODE;
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD BASE_CONC_MIX_TYPE VARCHAR2(30);
ALTER TABLE GMRUL_GMR_UL ADD BASE_CONC_MIX_TYPE VARCHAR2(30);


begin
for cur_gmr_invoice in(        
SELECT   iid.internal_gmr_ref_no,
         CASE
            WHEN (SUM (CASE
                          WHEN is1.invoice_type_name = 'Final'
                           OR is1.invoice_type_name = 'DirectFinal'
                             THEN 1
                          ELSE 0
                       END
                      )
                 ) = 0
               THEN 'N'
            ELSE 'Y'
         END fi_done,
         is1.is_invoice_new,
         is1.dbd_id,
         is1.process_id
    FROM is_invoice_summary is1,
         iid_invoicable_item_details iid,
         iam_invoice_action_mapping@eka_appdb iam,
         axs_action_summary axs
   WHERE is1.is_active = 'Y'
     AND is1.invoice_type_name IN ('Final', 'Provisional', 'DirectFinal')
     AND is1.internal_invoice_ref_no = iid.internal_invoice_ref_no
     AND iam.internal_invoice_ref_no = is1.internal_invoice_ref_no
     AND iam.invoice_action_ref_no = axs.internal_action_ref_no
     AND NVL (is1.is_free_metal, 'N') <> 'Y'
GROUP BY iid.internal_gmr_ref_no,is1.is_invoice_new,is1.dbd_id,is1.process_id)loop
update gmr_goods_movement_record gmr
   set  gmr.is_new_final_invoice           = case when cur_gmr_invoice.fi_done = 'Y' and cur_gmr_invoice.is_invoice_new = 'Y' then 'Y' else 'N' end
 where gmr.dbd_id = cur_gmr_invoice.dbd_id
   and gmr.internal_gmr_ref_no = cur_gmr_invoice.internal_gmr_ref_no;
update isr_intrastat_grd isr
   set  isr.is_new_final_invoice           = case when cur_gmr_invoice.fi_done = 'Y' and cur_gmr_invoice.is_invoice_new = 'Y' then 'Y' else 'N' end
 where isr.process_id = cur_gmr_invoice.process_id
   and isr.internal_gmr_ref_no = cur_gmr_invoice.internal_gmr_ref_no;   
   
end loop;
commit;
end;
/

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD(
GMR_SHIPMENT_DATE             DATE,
GMR_LANDED_DATE               DATE);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD IS_NEW_LANDING VARCHAR2(1) DEFAULT 'N';
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD IS_NEW_SHIPMENT VARCHAR2(1) DEFAULT 'N';

ALTER TABLE ISR_INTRASTAT_GRD ADD(
GMR_SHIPMENT_DATE             DATE,
GMR_LANDED_DATE               DATE,
IS_NEW_SHIPMENT               VARCHAR2(1) DEFAULT 'N',
IS_NEW_LANDING                VARCHAR2(1) DEFAULT 'N');

ALTER TABLE ISR1_ISR_INVENTORY ADD(
GMR_SHIPMENT_DATE             DATE,
GMR_LANDED_DATE               DATE,
IS_NEW_SHIPMENT               VARCHAR2(1) DEFAULT 'N',
IS_NEW_LANDING                VARCHAR2(1) DEFAULT 'N');

ALTER TABLE ISR2_ISR_INVOICE ADD(
GMR_SHIPMENT_DATE             DATE,
GMR_LANDED_DATE               DATE,
IS_NEW_SHIPMENT               VARCHAR2(1) DEFAULT 'N',
IS_NEW_LANDING                VARCHAR2(1) DEFAULT 'N');


--
-- GMR Shipment Date
--   
begin                       
for cur_gmr_sd in(
select t.internal_gmr_ref_no,
       t.eff_date gmr_shipment_date
  from agmr_action_gmr t
 where action_no = 1
   and is_deleted = 'N') loop
Update gmr_goods_movement_record gmr
set gmr.gmr_shipment_date =cur_gmr_sd.gmr_shipment_date
where gmr.internal_gmr_ref_no = cur_gmr_sd.internal_gmr_ref_no
and gmr.is_deleted ='N';
end loop;
end;
/
commit;

--
-- GMR Landing Date Update
--
begin
for cur_eod in (select * from dbd_database_dump dbd order by trade_date) loop
for cur_gmr_ld in(
select agmr.internal_gmr_ref_no,
       agmr.eff_date gmr_landing_date
  from agmr_action_gmr agmr
 where (agmr.internal_gmr_ref_no, agmr.action_no) in
       (select agmr.internal_gmr_ref_no,
               max(agmr.action_no) action_no
          from agmr_action_gmr agmr
         where agmr.eff_date <= cur_eod.trade_date
           and agmr.is_deleted = 'N'
         group by agmr.internal_gmr_ref_no)) loop
update gmr_goods_movement_record gmr
   set gmr.gmr_landed_date = cur_gmr_ld.gmr_landing_date
 where gmr.dbd_id = cur_eod.dbd_id
   and gmr.is_deleted = 'N'
   and gmr.internal_gmr_ref_no = cur_gmr_ld.internal_gmr_ref_no
   and gmr.gmr_status in ('In Warehouse', 'Landed', 'Released');
end loop;
end loop;
end;
/
commit;

begin
for cur_corporates in (select * from ak_corporate ) loop
for cur_eods in(
select trade_date,
       previos_process_id,
       current_process_id
  from (select tdc.trade_date,
               tdc.process_id previos_process_id,
               lag(tdc.process_id, 1) over(order by trade_date) current_process_id
          from tdc_trade_date_closure tdc
         where tdc.corporate_id = 'BLD')
 where current_process_id is not null) loop
 --
-- Update GMR Is New Landing Flag
--  
-- a) When GMR is landed in this EOD
--

 update gmr_goods_movement_record gmr
     set gmr.is_new_landing = 'Y'
   where gmr.process_id = cur_eods.current_process_id
     and gmr.is_deleted = 'N'
     and gmr.gmr_status in ('In Warehouse', 'Landed','Released')
     and not exists
   (select *
            from gmr_goods_movement_record gmr_prev
           where gmr_prev.process_id = cur_eods.previos_process_id
             and gmr_prev.internal_gmr_ref_no = gmr.internal_gmr_ref_no);
 
--             
-- b) When GMR Landing is recreated this EOM and Landing Date MOnth are different(i.e. Previous Data and Current EOM Date)
--
 update gmr_goods_movement_record gmr
     set gmr.is_new_landing = 'Y'
   where gmr.process_id = cur_eods.current_process_id
     and gmr.is_deleted = 'N'
     and gmr.gmr_status in ('In Warehouse', 'Landed','Released')
     and exists
   (select *
            from gmr_goods_movement_record gmr_prev
           where gmr_prev.process_id = cur_eods.previos_process_id
             and gmr_prev.internal_gmr_ref_no = gmr.internal_gmr_ref_no
             and gmr_prev.gmr_status = gmr.gmr_status
             and trunc(gmr.gmr_landed_date) <> trunc(gmr_prev.gmr_landed_date));

 --             
-- c) When GMR Landing is created this EOM, Last EOM only shipment was done
--
 update gmr_goods_movement_record gmr
     set gmr.is_new_landing = 'Y'
   where gmr.process_id = cur_eods.current_process_id
     and gmr.is_deleted = 'N'
     and gmr.gmr_status in ('In Warehouse', 'Landed','Released')
     and exists
   (select *
            from gmr_goods_movement_record gmr_prev
           where gmr_prev.process_id = cur_eods.previos_process_id
             and gmr_prev.internal_gmr_ref_no = gmr.internal_gmr_ref_no
             and gmr_prev.gmr_status <> gmr.gmr_status);
 
 end loop;
 end loop;
end;
/
commit;
-- GMR Is New Shipment Month
Update gmr_goods_movement_record gmr
set gmr.is_new_shipment = 'Y'
where gmr.is_new_mtd ='Y';
commit;

-- ISR Old data Update

begin
  for cur_gmr in (select gmr.process_id,
                         gmr.internal_gmr_ref_no,
                         gmr.gmr_shipment_date,
                         gmr.gmr_landed_date,
                         gmr.is_new_shipment,
                         gmr.is_new_landing
                    from gmr_goods_movement_record gmr)
  loop
    update isr_intrastat_grd isr
       set isr.gmr_landed_date   = cur_gmr.gmr_landed_date,
           isr.gmr_shipment_date = cur_gmr.gmr_shipment_date,
           isr.is_new_shipment   = cur_gmr.is_new_shipment,
           isr.is_new_landing    = cur_gmr.is_new_landing
     where isr.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no
       and isr.process_id = cur_gmr.process_id;
  end loop;
end;
/
commit;


ALTER TABLE ISR1_ISR_INVENTORY ADD PURCHASE_SALES VARCHAR2(10) DEFAULT 'Purchase' not null;
ALTER TABLE ISR2_ISR_INVOICE ADD PURCHASE_SALES VARCHAR2(10) DEFAULT 'Purchase' not null;
ALTER TABLE ISR_INTRASTAT_GRD ADD PURCHASE_SALES VARCHAR2(10) DEFAULT 'Purchase' not null;

ALTER TABLE ISR_INTRASTAT_GRD DROP COLUMN IS_NEW;


