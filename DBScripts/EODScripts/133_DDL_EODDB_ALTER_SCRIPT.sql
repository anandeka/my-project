ALTER TABLE GETC_GMR_ELEMENT_TC_CHARGES ADD(
GRD_QTY_UNIT_ID				VARCHAR2(15),
GRD_DRY_QTY					NUMBER(35,10),
GRD_WET_QTY					NUMBER(35,10),
GRD_TO_TC_WEIGHT_FACTOR		NUMBER DEFAULT 1,
TC_AMT						NUMBER(35,10),
BASE_TC_AMT					NUMBER(35,10),
ESC_DESC_AMT				NUMBER(35,10),
PAY_CUR_DECIMALS			NUMBER(2));

ALTER TABLE GEPC_GMR_ELEMENT_PC_CHARGES ADD(
GRD_QTY_UNIT_ID				VARCHAR2(15),
GRD_DRY_QTY					NUMBER(35,10),
GRD_WET_QTY					NUMBER(35,10),
GRD_TO_PC_WEIGHT_FACTOR		NUMBER DEFAULT 1,
PC_AMT						NUMBER(35,10),
PAY_CUR_DECIMALS			NUMBER(2));

ALTER TABLE GERC_GMR_ELEMENT_RC_CHARGES ADD(
PAYABLE_QTY					NUMBER(35,10),
PAYABLE_QTY_UNIT_ID			VARCHAR2(15),
PAYABLE_TO_RC_WEIGHT_FACTOR NUMBER DEFAULT 1,
RC_AMT						NUMBER(35,10),
PAY_CUR_DECIMALS			NUMBER(2));

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD(
IS_PAYABLE_QTY_CHANGED_MTD            VARCHAR2(1) DEFAULT 'N',
IS_TC_CHANGED_MTD                     VARCHAR2(1) DEFAULT 'N',
IS_RC_CHANGED_MTD                     VARCHAR2(1) DEFAULT 'N',
IS_PC_CHANGED_MTD                     VARCHAR2(1) DEFAULT 'N',
IS_PAYABLE_QTY_CHANGED_YTD            VARCHAR2(1) DEFAULT 'N',
IS_TC_CHANGED_YTD                     VARCHAR2(1) DEFAULT 'N',
IS_RC_CHANGED_YTD                     VARCHAR2(1) DEFAULT 'N',
IS_PC_CHANGED_YTD                     VARCHAR2(1) DEFAULT 'N');

begin
  for cur_grd in (select grd.qty_unit_id grd_qty_unit_id,
                         grd.dry_qty grd_dry_qty,
                         grd.qty grd_wet_qty,
                         grd.process_id,
                         grd.internal_grd_ref_no
                    from grd_goods_record_detail grd)
  loop
    update getc_gmr_element_tc_charges getc
       set getc.grd_qty_unit_id = cur_grd.grd_qty_unit_id,
           getc.grd_dry_qty     = cur_grd.grd_dry_qty,
           getc.grd_wet_qty     = cur_grd.grd_wet_qty
     where getc.internal_grd_ref_no = cur_grd.internal_grd_ref_no
       and getc.process_id = cur_grd.process_id;
    update gepc_gmr_element_pc_charges gepc
       set gepc.grd_qty_unit_id = cur_grd.grd_qty_unit_id,
           gepc.grd_dry_qty     = cur_grd.grd_dry_qty,
           gepc.grd_wet_qty     = cur_grd.grd_wet_qty
     where gepc.internal_grd_ref_no = cur_grd.internal_grd_ref_no
       and gepc.process_id = cur_grd.process_id;
  end loop;
   commit;
for cur_spq in (select spq.process_id,
                         spq.internal_grd_ref_no,
                         spq.payable_qty,
                         spq.qty_unit_id payable_qty_unit_id,
                         spq.element_id
                    from spq_stock_payable_qty spq)
  loop
  
    update gerc_gmr_element_rc_charges gerc
       set gerc.payable_qty         = cur_spq.payable_qty,
           gerc.payable_qty_unit_id = cur_spq.payable_qty_unit_id
     where gerc.internal_grd_ref_no = cur_spq.internal_grd_ref_no
     and gerc.element_id = cur_spq.element_id
       and gerc.process_id = cur_spq.process_id;
  end loop;

   commit;
  for cur_gmr in (select gmr.internal_gmr_ref_no,
                         gmr.invoice_cur_decimals pay_cur_decimal
                    from gmr_goods_movement_record gmr)
  loop
    update getc_gmr_element_tc_charges t
       set t.pay_cur_decimals = cur_gmr.pay_cur_decimal
     where t.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no;
    update gerc_gmr_element_rc_charges t
       set t.pay_cur_decimals = cur_gmr.pay_cur_decimal
     where t.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no;
    update gepc_gmr_element_pc_charges t
       set t.pay_cur_decimals = cur_gmr.pay_cur_decimal
     where t.internal_gmr_ref_no = cur_gmr.internal_gmr_ref_no;
  end loop;
   commit;
  Update getc_gmr_element_tc_charges getc
  set getc.grd_to_tc_weight_factor =
  (select ucm.multiplication_factor from ucm_unit_conversion_master ucm
  where ucm.from_qty_unit_id = getc.grd_qty_unit_id
  and ucm.to_qty_unit_id = getc.tc_weight_unit_id);
   commit;
    Update gepc_gmr_element_pc_charges gepc
  set gepc.grd_to_pc_weight_factor =
  (select ucm.multiplication_factor from ucm_unit_conversion_master ucm
  where ucm.from_qty_unit_id = gepc.grd_qty_unit_id
  and ucm.to_qty_unit_id = gepc.pc_weight_unit_id);     
   commit;
  
    Update gerc_gmr_element_rc_charges gerc
  set gerc.payable_to_rc_weight_factor =
  (select ucm.multiplication_factor from ucm_unit_conversion_master ucm
  where ucm.from_qty_unit_id = gerc.payable_qty_unit_id
  and ucm.to_qty_unit_id = gerc.rc_weight_unit_id);     
  -- commit;
 update getc_gmr_element_tc_charges getc
   set getc.base_tc_amt  = round((case when getc.weight_type = 'Dry' then getc.grd_dry_qty * getc.grd_to_tc_weight_factor * getc.base_tc_value else getc.grd_wet_qty * getc.grd_to_tc_weight_factor * getc.base_tc_value end * getc.currency_factor), getc.pay_cur_decimals),
       getc.esc_desc_amt = round((case when getc.weight_type = 'Dry' then getc.grd_dry_qty * getc.grd_to_tc_weight_factor * getc.esc_desc_tc_value else getc.grd_wet_qty * getc.grd_to_tc_weight_factor * getc.esc_desc_tc_value end * getc.currency_factor), getc.pay_cur_decimals);
commit;
-- to avoid round off issue below update separately
update getc_gmr_element_tc_charges getc
set getc.tc_amt = round(getc.base_tc_amt + getc.esc_desc_amt,2);
commit;
    

 Update gerc_gmr_element_rc_charges gerc
set gerc.rc_amt =  round((gerc.rc_value * gerc.payable_to_rc_weight_factor *
               gerc.payable_qty * gerc.currency_factor),gerc.pay_cur_decimals);
    commit;               
update gepc_gmr_element_pc_charges gepc
   set gepc.pc_amt = round((case when gepc.weight_type = 'Dry' then gepc.grd_dry_qty * gepc.grd_to_pc_weight_factor * gepc.pc_value else gepc.grd_wet_qty * gepc.grd_to_pc_weight_factor * gepc.pc_value end * gepc.currency_factor), gepc.pay_cur_decimals);
commit;
end;
/
