ALTER TABLE PATD_PA_TEMP_DATA ADD(
GMR_QTY_UNIT_ID              VARCHAR2(15),
GRD_TO_GMR_QTY_FACTOR        NUMBER);

ALTER TABLE TGOC_TEMP_GMR_OTHER_CHARGE ADD(
GMR_QTY_UNIT_ID                        VARCHAR2(15));

update pcdiul_pc_delivery_item_ul pcdiul
   set pcdiul.price_allocation_method = (select pcdiul_app.price_allocation_method from pcdiul_pc_delivery_item_ul@eka_appdb  pcdiul_app
                                          where pcdiul_app.pcdiul_id =
                                                pcdiul.pcdiul_id)
 where pcdiul.price_allocation_method is null;
 commit;
 