create or replace view v_bi_strategy_attribute as
select tt.corporate_startegy_id startegy_id,
       tt.strategy_name,
       max(case
             when tt.order_seq = 1 then
              tt.attribute_name
             else
              null
           end) attribute_name_1,
       max(case
             when tt.order_seq = 1 then
              tt.attribute_value
             else
              null
           end) attribute_value_1,
       ----------            
       max(case
             when tt.order_seq = 2 then
              tt.attribute_name
             else
              null
           end) attribute_name_2,
       max(case
             when tt.order_seq = 2 then
              tt.attribute_value
             else
              null
           end) attribute_value_2,
       ---------
       max(case
             when tt.order_seq = 3 then
              tt.attribute_name
             else
              null
           end) attribute_name_3,
       max(case
             when tt.order_seq = 3 then
              tt.attribute_value
             else
              null
           end) attribute_value_3,
       ----
       max(case
             when tt.order_seq = 4 then
              tt.attribute_name
             else
              null
           end) attribute_name_4,
       max(case
             when tt.order_seq = 4 then
              tt.attribute_value
             else
              null
           end) attribute_value_4,
       max(case
             when tt.order_seq = 5 then
              tt.attribute_name
             else
              null
           end) attribute_name_5,
       max(case
             when tt.order_seq = 5 then
              tt.attribute_value
             else
              null
           end) attribute_value_5
  from (select eam.entity_value_id corporate_startegy_id,
               css.strategy_name,
               etm.entity_type_name,
               adm.attribute_def_id,
               adm.attribute_name,
               avm.attribute_value,
               nvl(avm.attribute_value_desc, avm.attribute_value) attribute_value_desc,
               rank() over(partition by eam.entity_value_id order by adm.attribute_name asc) order_seq
          from eam_entity_attribute_mapping eam,
               etm_entity_type_master       etm,
               adm_attribute_def_master     adm,
               avm_attribute_value_master   avm,
               css_corporate_strategy_setup css
         where upper(etm.entity_type_name) = 'STRATEGY'
           and eam.attribute_value_id = avm.attribute_value_id
           and eam.attribute_def_id = adm.attribute_def_id
           and eam.entity_type_id = etm.entity_type_id
           and eam.entity_value_id = css.strategy_id
           and css.is_active = 'Y'
           and css.is_deleted = 'N'
           and eam.is_deleted = 'N') tt
 where tt.order_seq <= 5
 group by tt.corporate_startegy_id,
          tt.strategy_name 
