UPDATE pcbph_pc_base_price_header pcbph
   SET pcbph.element_name = (SELECT aml.attribute_name
                               FROM aml_attribute_master_list aml
                              WHERE pcbph.element_id = aml.attribute_id)
 WHERE pcbph.element_name IS NULL;