create or replace function fn_get_stock_deductable_qty(pc_grd_id          varchar2,
                                                       pn_grd_qty         number,
                                                       pc_grd_qty_unit_id varchar2)
  return number is
  vn_deduct_qty           number(25, 10);
  vn_deduct_total_qty     number(25, 10);
  vn_converted_qty        number(25, 10);
  vc_ash_id               varchar2(15);
  vc_internal_gmr_ref_no  varchar2(30);
  vc_gmr_action_id        varchar2(30);
  vc_is_pass_through      varchar2(1);
  vc_is_internal_movement varchar2(1);
  vc_product_id           varchar2(30);

  /* To get GMR details based on stock */
  cursor cur_gmr_detail is
    select gmr.internal_gmr_ref_no,
           gmr.gmr_latest_action_action_id,
           gmr.is_pass_through,
           gmr.is_internal_movement,
           grd.product_id
      from gmr_goods_movement_record gmr,
           grd_goods_record_detail   grd
     where gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
       and grd.internal_grd_ref_no = pc_grd_id;

begin
  vn_deduct_qty       := 0;
  vn_deduct_total_qty := 0;

  for cur_gmr in cur_gmr_detail
  loop
  
    vc_internal_gmr_ref_no  := cur_gmr.internal_gmr_ref_no;
    vc_gmr_action_id        := cur_gmr.gmr_latest_action_action_id;
    vc_is_pass_through      := cur_gmr.is_pass_through;
    vc_is_internal_movement := cur_gmr.is_internal_movement;
    vc_product_id           := cur_gmr.product_id;
  end loop;

  dbms_output.put_line('pc_grd_id:' || pc_grd_id);
  dbms_output.put_line('internal_gmr_ref_no:' || vc_internal_gmr_ref_no);
  dbms_output.put_line('vc_gmr_action_id :' || vc_gmr_action_id);
  dbms_output.put_line('vc_is_pass_through :' || vc_is_pass_through);
  dbms_output.put_line('vc_is_internal_movement :' ||
                       vc_is_internal_movement);
  dbms_output.put_line('vc_product_id :' || vc_product_id);

  /* To get assay details */

  if vc_is_internal_movement = 'Y' then
    /*
    (1) To get latest weighted avg pricing assay or output assay(Receive material Stock assay) for
           internal movement stock 
    */
    for cur_im in (select sam.internal_grd_ref_no stock_id,
                          sam.ash_id              ash_id
                     from sam_stock_assay_mapping sam
                    where sam.is_latest_weighted_avg_pricing = 'Y'
                         -- and nvl(sam.is_propagated_assay, 'N') = 'Y'
                      and sam.is_active = 'Y'
                      and sam.internal_grd_ref_no = pc_grd_id
                   
                   union all
                   select sam.internal_grd_ref_no stock_id,
                          sam.ash_id              ash_id
                     from sam_stock_assay_mapping sam
                    where sam.is_output_assay = 'Y'
                         -- and nvl(sam.is_propagated_assay, 'N') = 'Y'
                      and sam.is_active = 'Y'
                      and sam.internal_grd_ref_no = pc_grd_id)
    loop
      vc_ash_id := cur_im.ash_id;
      dbms_output.put_line(' vc_ash_id:' || vc_ash_id || ' cur_im.ash_id:' ||
                           cur_im.ash_id);
    end loop;
    dbms_output.put_line('internal movement' || ' vc_ash_id:' || vc_ash_id);
  else
    if vc_gmr_action_id = 'MARK_FOR_TOLLING' and vc_is_pass_through = 'Y' then
      /* (2) To get latest weighted avg pricing assay for internal MFT 'Cloned Stock' */
      for cur_mft in (select sam.internal_grd_ref_no stock_id,
                             sam.ash_id              ash_id
                        from sam_stock_assay_mapping sam
                       where sam.is_latest_weighted_avg_pricing = 'Y'
                         and nvl(sam.is_propagated_assay, 'N') = 'Y'
                         and sam.is_active = 'Y'
                         and sam.internal_grd_ref_no = pc_grd_id)
      loop
        vc_ash_id := cur_mft.ash_id;
        dbms_output.put_line(' vc_ash_id:' || vc_ash_id ||
                             ' cur_mft.ash_id:' || cur_mft.ash_id);
      end loop;
      dbms_output.put_line('MARK_FOR_TOLLING' || ' vc_is_pass_through:' ||
                           vc_is_pass_through || ' vc_ash_id:' ||
                           vc_ash_id);
    end if;
    if vc_gmr_action_id = 'MARK_FOR_TOLLING' and vc_is_pass_through = 'N' then
      /* (3) To get latest weighted avg pricing assay for external MFT 'Clone Stock' */
      for cur_mft in (select sam.internal_grd_ref_no stock_id,
                             sam.ash_id              ash_id
                        from sam_stock_assay_mapping sam
                       where sam.is_latest_weighted_avg_pricing = 'Y'
                         and nvl(sam.is_propagated_assay, 'N') = 'N'
                         and sam.is_active = 'Y'
                         and sam.internal_grd_ref_no = pc_grd_id)
      loop
        vc_ash_id := cur_mft.ash_id;
      
      end loop;
    
    end if;
    if vc_gmr_action_id = 'RECORD_OUT_PUT_TOLLING' then
      /*(4) To get output assay for receive material 'RM Out Process Stock' */
      for cur_rm in (select sam.internal_grd_ref_no stock_id,
                            sam.ash_id              ash_id
                       from sam_stock_assay_mapping sam
                      where sam.is_output_assay = 'Y'
                        and nvl(sam.is_propagated_assay, 'N') = 'N'
                        and sam.is_active = 'Y'
                        and sam.internal_grd_ref_no = pc_grd_id)
      loop
        vc_ash_id := cur_rm.ash_id;
      end loop;
    end if;
  end if;

  /*
    NOTE:- Assumption is, Only one sub-lot exist into assay('Weight Avg Assay'/'Output Assay')
  */
  for cur_deduct_qty in (select pqca.element_id            element_id,
                                pqca.unit_of_measure       unit_of_measure,
                                rm.ratio_name              ratio_name,
                                rm.qty_unit_id_numerator   qty_unit_id_numerator,
                                rm.qty_unit_id_denominator qty_unit_id_denominator,
                                pqca.typical               typical
                           from asm_assay_sublot_mapping    asm,
                                pqca_pq_chemical_attributes pqca,
                                rm_ratio_master             rm,
                                ash_assay_header            ash
                          where ash.ash_id = vc_ash_id
                            and pqca.asm_id = asm.asm_id
                            and pqca.unit_of_measure = rm.ratio_id
                            and asm.ash_id = ash.ash_id
                            and pqca.is_deductible = 'Y')
  loop
  
    if cur_deduct_qty.ratio_name = '%' then
      vn_deduct_qty := pn_grd_qty * (cur_deduct_qty.typical / 100);
    else
      vn_converted_qty := pkg_general.f_get_converted_quantity(vc_product_id,
                                                               pc_grd_qty_unit_id,
                                                               cur_deduct_qty.qty_unit_id_denominator,
                                                               pn_grd_qty) *
                          cur_deduct_qty.typical;
      vn_deduct_qty    := pkg_general.f_get_converted_quantity(vc_product_id,
                                                               cur_deduct_qty.qty_unit_id_numerator,
                                                               pc_grd_qty_unit_id,
                                                               vn_converted_qty);
    
    end if;
    vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
  
  end loop;

  return vn_deduct_total_qty;
exception
  when others then
    return 0;
end fn_get_stock_deductable_qty;
/
