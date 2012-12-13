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
 
 declare
  cursor cur_spql is
    select spql_app.weg_avg_pricing_assay_id,
           spql_app.spq_id,
           spql_app.internal_action_ref_no,
           spql_app.entry_type,
           spql_app.version
      from spql_stock_payable_qty_log@eka_appdb spql_app;
begin

  for cur_spql_rows in cur_spql
  loop
    update spql_stock_payable_qty_log spql
       set spql.weg_avg_pricing_assay_id = cur_spql_rows.weg_avg_pricing_assay_id
     where spql.spq_id = cur_spql_rows.spq_id
       and spql.internal_action_ref_no =
           cur_spql_rows.internal_action_ref_no
       and spql.entry_type = cur_spql_rows.entry_type
       and spql.version = cur_spql_rows.version;
  end loop;
  commit;
end;
/
