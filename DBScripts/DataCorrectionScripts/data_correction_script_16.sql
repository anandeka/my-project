DECLARE
  CURSOR cr_pcbph_elements IS
    SELECT aml.attribute_name, pcbph.pcbph_id
      FROM pcbph_pc_base_price_header pcbph, aml_attribute_master_list aml
     WHERE pcbph.element_id = aml.attribute_id
       AND pcbph.is_active = 'Y'
       AND pcbph.element_name IS NULL;
BEGIN
  FOR cur_pcbph IN cr_pcbph_elements LOOP
    UPDATE pcbph_pc_base_price_header pcbph
       SET element_name = cur_pcbph.attribute_name
     WHERE pcbph.pcbph_id = cur_pcbph.pcbph_id;
  
    DBMS_OUTPUT.put_line('Record updated for corporate ' ||
                         cur_pcbph.pcbph_id);
  END LOOP;
END;
