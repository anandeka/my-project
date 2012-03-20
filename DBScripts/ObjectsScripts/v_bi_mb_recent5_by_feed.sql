create or replace view v_bi_mb_recent5_by_feed as
select tt.corporate_id,
       tt.product_id,
       tt.product_name,
       tt.reference_no,
       tt.activity,
       tt.cp_id,
       tt.cpname,
       tt.quantity,
       tt.base_qty_unit_id,
       tt.base_qty_unit,
       tt.internal_grd_ref_no,
       tt.created_date,
       tt.order_id
  from (select t.corporate_id,
               t.product_id,
               pdm.product_desc product_name,
               t.action_ref_no reference_no,
               axm.action_name activity,
               phd.profileid cp_id,
               phd.companyname cpname,
               t.qty quantity,
               t.qty_unit_id base_qty_unit_id,
               qum.qty_unit base_qty_unit,
               t.internal_grd_ref_no,
               t.created_date,
               row_number() over(partition by t.corporate_id, t.product_id order by t.created_date desc) order_id
          from (select grd.internal_grd_ref_no,
                       substr(max(case
                                    when gmr.corporate_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     gmr.corporate_id
                                  end),
                              24) corporate_id,
                       substr(max(case
                                    when grdul.pcdi_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     grdul.pcdi_id
                                  end),
                              24) pcdi_id,
                       substr(max(case
                                    when grdul.product_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     grdul.product_id
                                  end),
                              24) product_id,
                       substr(max(case
                                    when grdul.qty is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     grdul.qty
                                  end),
                              24) qty,
                       substr(max(case
                                    when grdul.qty_unit_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     grdul.qty_unit_id
                                  end),
                              24) qty_unit_id,
                       substr(max(case
                                    when axs.action_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     axs.action_id
                                  end),
                              24) action_id,
                       substr(max(case
                                    when axs.action_ref_no is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     axs.action_ref_no
                                  end),
                              24) action_ref_no,
                       max(case
                             when axs.created_date is not null then
                              axs.created_date
                           end) created_date
                  from grdul_goods_record_detail_ul grdul,
                       grd_goods_record_detail      grd,
                       gmr_goods_movement_record    gmr,
                       axs_action_summary           axs
                 where grdul.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and grdul.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = grdul.internal_grd_ref_no
                   and grd.tolling_stock_type = 'MFT In Process Stock'
                 group by grdul.internal_grd_ref_no,
                          grd.internal_grd_ref_no) t,
               grd_goods_record_detail grd,
               axm_action_master axm,
               pdm_productmaster pdm,
               qum_quantity_unit_master qum,
               pcdi_pc_delivery_item pcdi,
               pcm_physical_contract_main pcm,
               phd_profileheaderdetails phd
         where t.internal_grd_ref_no = grd.internal_grd_ref_no
           and t.action_id = axm.action_id
           and t.pcdi_id = pcdi.pcdi_id
           and t.product_id = pdm.product_id
           and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.cp_id = phd.profileid
           and t.qty_unit_id = qum.qty_unit_id) tt
 where tt.order_id <= 5
