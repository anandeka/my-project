create or replace view v_pci_multiple_premium as
select pcm.contract_ref_no,
       pcdi.pcdi_id,
       pcm.internal_contract_ref_no,
       pci.pcpq_id,
       stragg(distinct
              pcqpd.premium_disc_value || ' ' || pum.price_unit_name) premium
  from pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       pci_physical_contract_item     pci,
       pcqpd_pc_qual_premium_discount pcqpd,
       ppu_product_price_units        ppu,
       pum_price_unit_master          pum,
       
       pcpdqd_pd_quality_details pcpdqd
 where pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and pcdi.pcdi_id = pci.pcdi_id
   and pci.pcpq_id = pcpdqd.pcpq_id
   and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
   and pcm.internal_contract_ref_no = pcqpd.internal_contract_ref_no(+)
   and pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id(+)
   and ppu.price_unit_id = pum.price_unit_id(+)
   and pcpdqd.pcqpd_id = pcqpd.pcqpd_id
   --and pcm.contract_ref_no = 'PC-5-TrxSA'
 group by pcm.contract_ref_no,
          pcm.internal_contract_ref_no,
          pcpdqd.pcpq_id,
          pci.pcpq_id,
          pcdi.pcdi_id
