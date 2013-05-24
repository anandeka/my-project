CREATE OR REPLACE VIEW V_PPU_PUM AS
select ppu.internal_price_unit_id product_price_unit_id,
       ppu.product_id,
       ppu.price_unit_id,
       pum.price_unit_name,
       pum.cur_id,
       pum.weight,
       pum.weight_unit_id,
       ppu.decimals
  from ppu_product_price_units ppu,
       pum_price_unit_master   pum
 where ppu.price_unit_id = pum.price_unit_id
  -- and ppu.is_active = 'Y' -- removed, as inactive id's will be used in trades, deleted id will not be used in trades
   and ppu.is_deleted = 'N'
 --  and pum.is_active = 'Y'
   and pum.is_deleted = 'N';