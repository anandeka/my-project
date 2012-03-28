create or replace view v_bi_mb_recent5_by_stock as
select t2.corporate_id,
       t2.product_id,
       t2.product_desc product_name,
       t2.action_ref_no reference_no,
       t2.activity,
       t2.cp_id,
       t2.cpname cp_name,--Bug 63266 Fix added alias name
       t2.qty quantity,
       t2.qty_unit_id base_qty_unit_id,
       t2.qty_unit base_qty_unit,
       t2.order_seq order_id--Bug 63266 Fix added column
  from (select t1.product_id,
               t1.corporate_id,
               t1.internal_grd_ref_no,
               t1.activity,
               t1.action_ref_no,
               t1.qty,
               t1.qty_unit_id,
               t1.created_date,
               t1.product_desc,
               t1.qty_unit,
               t1.cp_id,
               t1.cpname,
               row_number() over(partition by t1.corporate_id, t1.product_id order by t1.created_date desc) order_seq
          from (select t.product_id,
                       t.internal_grd_ref_no,
                       t.corporate_id,
                       axm.action_name activity,
                       t.action_ref_no,
                       t.qty,
                       t.qty_unit_id,
                       t.created_date,
                       pdm.product_desc,
                       qum.qty_unit,
                       phd.profileid cp_id,
                       phd.companyname cpname
                  from (select substr(max(case
                                            when dgrdul.internal_dgrd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.internal_dgrd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,
                               substr(max(case
                                            when dgrdul.pcdi_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.pcdi_id
                                          end),
                                      24) pcdi_id,
                               substr(max(case
                                            when dgrdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             dgrdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when dgrdul.qty is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || dgrdul.qty
                                          end),
                                      24) qty,
                               substr(max(case
                                            when gmr.qty_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.qty_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from dgrdul_delivered_grd_ul   dgrdul,
                               gmr_goods_movement_record gmr,
                               axs_action_summary        axs
                         where dgrdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and dgrdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                         group by dgrdul.internal_dgrd_ref_no) t,
                       dgrd_delivered_grd dgrd,
                       axm_action_master axm,
                       pdm_productmaster pdm,
                       qum_quantity_unit_master qum,
                       pcdi_pc_delivery_item pcdi,
                       pcm_physical_contract_main pcm,
                       phd_profileheaderdetails phd
                 where t.internal_grd_ref_no = dgrd.internal_dgrd_ref_no
                   and t.pcdi_id = pcdi.pcdi_id
                   and t.action_id = axm.action_id
                   and t.product_id = pdm.product_id
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and t.qty_unit_id = qum.qty_unit_id
                   and pcm.cp_id = phd.profileid
                union all
                select t.product_id,
                       t.internal_grd_ref_no,
                       t.corporate_id,
                       axm.action_name activity,
                       t.action_ref_no,
                       t.qty,
                       t.qty_unit_id,
                       t.created_date,
                       pdm.product_desc,
                       qum.qty_unit,
                       phd.profileid cp_id,
                       phd.companyname cpname
                  from (select substr(max(case
                                            when grdul.internal_grd_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.internal_grd_ref_no
                                          end),
                                      24) internal_grd_ref_no,
                               substr(max(case
                                            when gmr.corporate_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             gmr.corporate_id
                                          end),
                                      24) corporate_id,
                               
                               substr(max(case
                                            when grdul.pcdi_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.pcdi_id
                                          end),
                                      24) pcdi_id,
                               substr(max(case
                                            when grdul.product_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.product_id
                                          end),
                                      24) product_id,
                               substr(max(case
                                            when grdul.qty is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') || grdul.qty
                                          end),
                                      24) qty,
                               substr(max(case
                                            when grdul.qty_unit_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             grdul.qty_unit_id
                                          end),
                                      24) qty_unit_id,
                               substr(max(case
                                            when axs.action_id is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_id
                                          end),
                                      24) action_id,
                               substr(max(case
                                            when axs.action_ref_no is not null then
                                             to_char(axs.created_date,
                                                     'yyyymmddhh24missff9') ||
                                             axs.action_ref_no
                                          end),
                                      24) action_ref_no,
                               max(case
                                     when axs.created_date is not null then
                                      axs.created_date
                                   end) created_date
                          from grdul_goods_record_detail_ul grdul,
                               gmr_goods_movement_record    gmr,
                               axs_action_summary           axs
                         where grdul.internal_action_ref_no =
                               axs.internal_action_ref_no
                           and grdul.internal_gmr_ref_no =
                               gmr.internal_gmr_ref_no
                         group by grdul.internal_grd_ref_no) t,
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
                   and pcdi.internal_contract_ref_no =
                       pcm.internal_contract_ref_no
                   and pcm.cp_id = phd.profileid
                   and t.qty_unit_id = qum.qty_unit_id) t1) t2
 where t2.order_seq < 6 
/
