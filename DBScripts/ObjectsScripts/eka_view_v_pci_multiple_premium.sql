create or replace view v_pci_multiple_premium as
select pcm.contract_ref_no,
       pcm.internal_contract_ref_no,
       stragg(pcqpd.premium_disc_value || ' ' || pum.price_unit_name)premium
from
    pcm_physical_contract_main pcm,
    pcqpd_pc_qual_premium_discount pcqpd,
    ppu_product_price_units        ppu,
    pum_price_unit_master          pum
where
    pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
and ppu.price_unit_id = pum.price_unit_id(+)
group by pcm.contract_ref_no,
         pcm.internal_contract_ref_no

