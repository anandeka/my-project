CREATE TABLE TEMP_FCR
(
  CORPORATE_ID         VARCHAR2(15),
  CORPORATE_NAME       VARCHAR2(15),
  INTERNAL_GMR_REF_NO           VARCHAR2(15),
  GMR_REF_NO           VARCHAR2(15),
  PRODUCT_ID           VARCHAR2(15),
  PRODUCT_NAME         VARCHAR2(50),
  QUALITY_ID           VARCHAR2(15),
  QUALITY_NAME         VARCHAR2(50),
  INTERNAL_GRD_REF_NO  VARCHAR2(50),
  CP_ID                VARCHAR2(15),
  CP_NAME              VARCHAR2(65),
  ELEMENT_ID           VARCHAR2(15),
  ELEMENT_NAME         VARCHAR2(15),
  IAM_ASH_ID           VARCHAR2(15),
  SPQ_ASH_ID           VARCHAR2(15),
  GMR_QTY              NUMBER(25,5),
  GMR_QTY_UNIT_ID      VARCHAR2(15),
  GMR_QTY_UNIT         VARCHAR2(15),
  ASSAY_QTY            NUMBER(25,5),
  ASAAY_QTY_UNIT_ID    VARCHAR2(15),
  ASAAY_QTY_UNIT       VARCHAR2(15),
  PAYABLE_QTY          VARCHAR2(15),
  PAYABLE_QTY_UNIT_ID  VARCHAR2(15),
  PAYABLE_QTY_UNIT     VARCHAR2(15),
  INVOICE_CUR_ID       VARCHAR2(15),
  INVOICE_CUR_CODE     VARCHAR2(15),
  BASE_CUR_ID          VARCHAR2(15),
  BASE_CUR_CODE        VARCHAR2(15),
  INTERNAL_INVOICE_REF_NO VARCHAR2(15)   );

ALTER TABLE FCR_FEED_CONSUMPTION_REPORT ADD INTERNAL_GMR_REF_NO VARCHAR2(15);
ALTER TABLE FCR_FEED_CONSUMPTION_REPORT ADD INTERNAL_INVOICE_REF_NO VARCHAR2(15);
UPDATE FCR_FEED_CONSUMPTION_REPORT SET PAYABLE_QTY = NULL;
ALTER TABLE FCR_FEED_CONSUMPTION_REPORT MODIFY PAYABLE_QTY NUMBER(25,5);
ALTER TABLE FCR_FEED_CONSUMPTION_REPORT MODIFY GMR_REF_NO VARCHAR2(30);
ALTER TABLE FCR_FEED_CONSUMPTION_REPORT MODIFY PRODUCT_NAME VARCHAR2(200);

delete from cpe_corp_penality_element;
begin
  for cc in (select * from ak_corporate akc)
  loop
    for cc1 in (select *
                  from (select aml.attribute_id element_id,
                               aml.attribute_name element_name,
                               case
                                 when aml.attribute_name = 'Sb' then
                                  1
                                 when aml.attribute_name = 'As' then
                                  2
                                 when aml.attribute_name = 'Cl' then
                                  3
                                 when aml.attribute_name = 'Hg' then
                                  4
                                 when aml.attribute_name = 'Bi' then
                                  5
                               end order_num
                          from aml_attribute_master_list aml
                         where aml.attribute_name in
                               ('Sb', 'As', 'Cl', 'Hg', 'Bi'))
                 order by order_num)
    loop
    
      insert into cpe_corp_penality_element
        (corporate_id, element_id, element_name, order_id)
      values
        (cc.corporate_id, cc1.element_id, cc1.element_name, 1);
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
         when aml.attribute_name = 'Zn' then
          4
         when aml.attribute_name = 'Pb' then
          5
         when aml.attribute_name = 'Mo' then
          6
         when aml.attribute_name = 'Coal' then
          7
       end order_num
  from aml_attribute_master_list aml
 where aml.attribute_name in ('Cu', 'Au', 'Ag', 'Zn', 'Pb', 'Mo', 'Coal')) order by order_num) loop
  
insert into cpe_corp_payble_element
  (corporate_id, element_id, element_name, order_id)
values
  (cc.corporate_id, cc1.element_id, cc1.element_name, cc1.order_num);
end loop;
end loop;
commit;
end;
/

