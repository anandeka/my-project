delete from cpe_corp_penality_element;
begin
  for cc in (select * from ak_corporate akc)
  loop
    for cc1 in (select *
                  from (select aml.attribute_id element_id,
                               (case when aml.attribute_name in('As', 'Sb', 'Pb', 'Cl', 'Hg')
                               then aml.attribute_name
                               else 'Others' end)element_name,
                               case
                                 when aml.attribute_name = 'As' then
                                  1
                                 when aml.attribute_name = 'Sb' then
                                  2
                                 when aml.attribute_name = 'Pb' then
                                  3
                                 when aml.attribute_name = 'Cl' then
                                  4
                                 when aml.attribute_name = 'Hg' then
                                  5
                                 else 6
                               end order_num
                          from aml_attribute_master_list aml)
                 order by order_num)
    loop
    
      insert into cpe_corp_penality_element
        (corporate_id, element_id, element_name, order_id)
      values
        (cc.corporate_id, cc1.element_id, cc1.element_name, cc1.order_num);
    end loop;
  end loop;
  commit;
end;
/

delete from cpe_corp_payble_element;
begin
 for cc in (select *
               from ak_corporate akc)
  loop  
for cc1 in 
(select * from ( 
select aml.attribute_id element_id,
       aml.attribute_name element_name,
       case
         when aml.attribute_name = 'Cu' then
          1
         when aml.attribute_name = 'Au' then
          2
         when aml.attribute_name = 'Ag' then
          3
         when aml.attribute_name = 'Pd' then
          4
         when aml.attribute_name = 'Pt' then
          5
         when aml.attribute_name = 'Zn' then
          6
         when aml.attribute_name = 'Pb' then
          7
       end order_num
  from aml_attribute_master_list aml
 where aml.attribute_name in ('Cu', 'Au', 'Ag', 'Pd', 'Pt', 'Zn', 'Pb')) order by order_num) loop
  
insert into cpe_corp_payble_element
  (corporate_id, element_id, element_name, order_id)
values
  (cc.corporate_id, cc1.element_id, cc1.element_name, cc1.order_num);
end loop;
end loop;
commit;
end;
/
