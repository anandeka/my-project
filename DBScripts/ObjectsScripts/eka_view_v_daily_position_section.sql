create or replace view v_daily_position_section as
select s1.section_name,
       null contract_ref_no,
       akc.corporate_id,
       akc.corporate_name,
       blm.business_line_id,
       blm.business_line_name,
       cpc.profit_center_id,
       cpc.profit_center_short_name,
       cpc.profit_center_name,
       cpm.product_id,
       pdm.product_desc product_name,
       null issue_date,
       0 fixed_qty,
       0 quotational_qty,
       qum.qty_unit_id,
       qum.qty_unit base_qty_unit,
       0 open_fixed_qty,
       0 open_quotational_qty
  from ak_corporate akc,
       cpc_corporate_profit_center cpc,
       blm_business_line_master blm,
       cpm_corporateproductmaster cpm,
       pdm_productmaster pdm,
       qum_quantity_unit_master qum,
       (select (case
                 when rownum = 1 then
                  'Physicals'
                 when rownum = 2 then
                  'Any one day price fix'
                 when rownum = 3 then
                  'Average price fix'
                 when rownum = 4 then
                  'Futures'
               end) section_name
          from rml_report_master_list
         where rownum < 5) s1
 where cpc.corporateid = akc.corporate_id 
   and akc.corporate_id = cpm.corporate_id
   and blm.business_line_id(+) = cpc.business_line_id
   and cpm.product_id = pdm.product_id
   and pdm.base_quantity_unit = qum.qty_unit_id
