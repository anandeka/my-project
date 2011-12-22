CREATE OR REPLACE VIEW v_der_instrument_price_unit (instrument_id,
                                                          instrument_name,
                                                          instrument_type_id,
                                                          instrument_type,
                                                          product_id,
                                                          traded_on,
                                                          price_unit_id,
                                                          price_unit_name,
                                                          price_unit_cur_id,
                                                          price_unit_weight,
                                                          price_unit_weight_unit_id,
                                                          ppu_price_unit_id,
                                                          ppu_price_unit_name,
                                                          ppu_price_unit_cur_id,
                                                          ppu_price_unit_weight,
                                                          ppu_price_unit_weight_unit_id
                                                         )
AS
   SELECT t.instrument_id, t.instrument_name, t.instrument_type_id,
          t.instrument_type, t.product_id, t.traded_on, t.price_unit_id,
          pum.price_unit_name, pum.cur_id price_unit_cur_id,
          pum.weight price_unit_weight,
          pum.weight_unit_id price_unit_weight_unit_id,
          ppu.internal_price_unit_id ppu_price_unit_id,
          ppu_pum.price_unit_name ppu_price_unit_name,
          ppu_pum.cur_id ppu_price_unit_cur_id,
          ppu_pum.weight ppu_price_unit_weight,
          ppu_pum.weight_unit_id ppu_price_unit_weight_unit_id
     FROM (SELECT dim.instrument_id, dim.instrument_name,
                  dim.instrument_type_id, irm.instrument_type, pdd.product_id,
                  pdd.traded_on, dpu.price_unit_id,
                  ROW_NUMBER () OVER (PARTITION BY dim.instrument_id, irm.instrument_type ORDER BY dpu.ROWID DESC)
                                                                          seq
             FROM div_der_instrument_valuation dpu,
                  dim_der_instrument_master dim,
                  irm_instrument_type_master irm,
                  pdd_product_derivative_def pdd
            WHERE dpu.instrument_id = dim.instrument_id
              AND dpu.is_deleted = 'N'
              AND dim.is_deleted = 'N'
              AND dim.instrument_type_id = irm.instrument_type_id
              AND dim.product_derivative_id = pdd.derivative_def_id) t,
          pum_price_unit_master pum,
          ppu_product_price_units ppu,
          pum_price_unit_master ppu_pum
    WHERE t.seq = 1
      AND t.price_unit_id = pum.price_unit_id(+)
      AND t.price_unit_id = ppu.price_unit_id(+)
      AND t.product_id = ppu.product_id(+)
      AND ppu.price_unit_id = ppu_pum.price_unit_id(+);

