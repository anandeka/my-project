ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
   FIRST_INT_ACTION_REF_NO VARCHAR2(15),
   CONSTRAINT FK_GRD_FIRST_ACTION_REF_NO FOREIGN KEY (FIRST_INT_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD
(
   FIRST_INT_ACTION_REF_NO VARCHAR2(15)
);

ALTER TABLE AGRD_ACTION_GRD ADD
(
   FIRST_INT_ACTION_REF_NO VARCHAR2(15),
   CONSTRAINT FK_AGRD_FIRST_ACTION_REF_NO FOREIGN KEY (FIRST_INT_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);



UPDATE grd_goods_record_detail grd
   SET grd.first_int_action_ref_no = grd.internal_action_ref_no
 WHERE grd.tolling_stock_type IN
          ('MFT In Process Stock', 'Delta MFT IP Stock',
           'Free Material Stock', 'Free Metal IP Stock', 'Delta FM IP Stock');
           

UPDATE AGRD_ACTION_GRD agrd
   SET agrd.first_int_action_ref_no = (select grd.internal_action_ref_no
   from GRD_GOODS_RECORD_DETAIL grd
 WHERE AGRD.INTERNAL_GRD_REF_NO = GRD.INTERNAL_GRD_REF_NO
 and AGRD.TOLLING_STOCK_TYPE = GRD.TOLLING_STOCK_TYPE
 and agrd.tolling_stock_type IN
          ('MFT In Process Stock', 'Delta MFT IP Stock',
           'Free Material Stock', 'Free Metal IP Stock', 'Delta FM IP Stock'));