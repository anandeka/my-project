create or replace view v_bi_mb_recent5_by_debt as
select corporate_id,
       product_id,
       product_name,
       reference_no,
       activity,
       cp_id,
       cp_name,
       quantity,
       base_qty_unit_id,
       base_qty_unit,
       order_id
  from (select prr.corporate_id,
               pdm.product_id,
               pdm.product_desc product_name,
               axs.action_ref_no reference_no,
               axm.action_name activity,
               phd.profileid cp_id,
               phd.companyname cp_name,
               prr.qty quantity,
               qum.qty_unit_id base_qty_unit_id,
               qum.qty_unit base_qty_unit,
               row_number() over(partition by prr.corporate_id, prr.product_id order by axs.created_date desc) order_id
          from prrqs_prr_qty_status     prr,
               axs_action_summary       axs,
               axm_action_master        axm,
               phd_profileheaderdetails phd,
               qum_quantity_unit_master qum,
               pdm_productmaster        pdm
         where prr.internal_action_ref_no = axs.internal_action_ref_no
           and axs.action_id = axm.action_id
           and prr.cp_id = phd.profileid
           and prr.qty_unit_id = qum.qty_unit_id
           and prr.product_id = pdm.product_id
           and axs.action_ref_no is not null)
 where order_id < 6
