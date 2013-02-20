begin
for rc in (select akc.corporate_id corp_id, akc.corporate_name 
        from ak_corporate akc where akc.is_internal_corporate = 'N') 
loop
    update cdc_corporate_doc_config 
    set doc_template_name = 'Warehouse Receipt Output Document',
    doc_rpt_file_name = 'Warehouse_Receipt.rpt',
    is_active = 'Y'
    where doc_id = 'warehouseReceipt'
    and corporate_id = rc.corp_id;
end loop;    
commit;
end ;  
/