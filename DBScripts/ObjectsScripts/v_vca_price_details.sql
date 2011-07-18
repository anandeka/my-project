CREATE OR REPLACE FORCE VIEW v_vca_price_details (vcs_id,price_details)
AS
   SELECT   vca.vcs_id,
            stragg
               ((CASE
                    WHEN vca.attribute_id IS NULL
                       THEN pum.price_unit_name
                    ELSE aml.attribute_name || ' : ' || pum.price_unit_name
                 END
                )
               ) price_details
       FROM vca_valuation_curve_attribute vca,
            ppu_product_price_units ppu,
            pum_price_unit_master pum,
            aml_attribute_master_list aml
      WHERE vca.attribute_id = aml.attribute_id(+)
        AND vca.price_unit_id = ppu.internal_price_unit_id
        AND ppu.price_unit_id = pum.price_unit_id
        AND ppu.is_active = 'Y'
        AND ppu.is_deleted = 'N'
   GROUP BY vca.vcs_id;
