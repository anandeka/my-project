/* Formatted on 2013/04/22 12:55 (Formatter Plus v4.8.8) */

alter trigger TRG_INSERT_GRDL disable;

ALTER TABLE grd_goods_record_detail
 ADD (cot_int_action_ref_no  VARCHAR2(30));
 
ALTER TABLE grdul_goods_record_detail_ul
 ADD (cot_int_action_ref_no  VARCHAR2(30));
 
alter trigger TRG_INSERT_GRDL enable;

ALTER  TABLE grdl_goods_record_detail_log
 ADD (cot_int_action_ref_no  VARCHAR2(30));