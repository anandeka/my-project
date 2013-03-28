create or replace view v_pcdi_exchange_detail as 
      select tt.corporate_id,
             tt.internal_contract_item_ref_no,
             tt.pcdi_id,
             tt.element_id,
             tt.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name
        from (select pcm.corporate_id,
                     pci.internal_contract_item_ref_no,
                     poch.element_id,
                     ppfd.instrument_id,
                     pci.pcdi_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     poch_price_opt_call_off_header poch,
                     pocd_price_option_calloff_dtls pocd,
                     pcbpd_pc_base_price_detail     pcbpd,
                     ppfh_phy_price_formula_header  ppfh,
                     ppfd_phy_price_formula_details ppfd,
                     pcm_physical_contract_main     pcm
               where pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.pcdi_id = poch.pcdi_id
                 and poch.poch_id = pocd.poch_id
                 and pocd.pcbpd_id = pcbpd.pcbpd_id
                 and pcbpd.pcbpd_id = ppfh.pcbpd_id
                 and ppfh.ppfh_id = ppfd.ppfh_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no                
                 and pcm.is_active = 'Y'
                 and pci.is_active = 'Y'
                 and pcdi.is_active = 'Y'
                 and poch.is_active = 'Y'
                 and pocd.is_active = 'Y'
                 and pcbpd.is_active = 'Y'
                 and ppfh.is_active = 'Y'
                 and ppfd.is_active = 'Y'
                 and pcm.product_group_type = 'BASEMETAL'
                 and pcdi.price_option_call_off_status in
                     ('Called Off', 'Not Applicable')
               group by pci.internal_contract_item_ref_no,
                        ppfd.instrument_id,
                        poch.element_id,
                        pci.pcdi_id,
                        pcm.corporate_id
              union all
              select pcm.corporate_id,
                     pci.internal_contract_item_ref_no,
                     pcbpd.element_id,
                     ppfd.instrument_id,
                     pci.pcdi_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     pcipf_pci_pricing_formula      pcipf,
                     pcbph_pc_base_price_header     pcbph,
                     pcbpd_pc_base_price_detail     pcbpd,
                     ppfh_phy_price_formula_header  ppfh,
                     ppfd_phy_price_formula_details ppfd,
                     pcm_physical_contract_main     pcm
               where pci.internal_contract_item_ref_no =
                     pcipf.internal_contract_item_ref_no
                 and pcipf.pcbph_id = pcbph.pcbph_id
                 and pcbph.pcbph_id = pcbpd.pcbph_id
                 and pcbpd.pcbpd_id = ppfh.pcbpd_id
                 and ppfh.ppfh_id = ppfd.ppfh_id
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no                 
                 and pcdi.is_active = 'Y'
                 and pcm.product_group_type = 'BASEMETAL'
                 and pcdi.price_option_call_off_status = 'Not Called Off'
                 and pci.is_active = 'Y'
                 and pcipf.is_active = 'Y'
                 and pcbph.is_active = 'Y'
                 and pcbpd.is_active = 'Y'
                 and ppfh.is_active = 'Y'
                 and ppfd.is_active = 'Y'
               group by pci.internal_contract_item_ref_no,
                        ppfd.instrument_id,
                        pcbpd.element_id,
                        pci.pcdi_id,
                        pcm.corporate_id
              union all
              select pcm.corporate_id,
                     pci.internal_contract_item_ref_no,
                     pcbpd.element_id,
                     ppfd.instrument_id,
                     pci.pcdi_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     poch_price_opt_call_off_header poch,
                     pocd_price_option_calloff_dtls pocd,
                     pcbpd_pc_base_price_detail     pcbpd,
                     ppfh_phy_price_formula_header  ppfh,
                     ppfd_phy_price_formula_details ppfd,
                     dipq_delivery_item_payable_qty dipq,
                     pcm_physical_contract_main     pcm
               where pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.pcdi_id = poch.pcdi_id
                 and poch.poch_id = pocd.poch_id
                 and pocd.pcbpd_id = pcbpd.pcbpd_id
                 and pcbpd.pcbpd_id = ppfh.pcbpd_id
                 and ppfh.ppfh_id = ppfd.ppfh_id
                 and pcdi.pcdi_id = dipq.pcdi_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no                
                 and dipq.element_id = pcbpd.element_id
                 and pcdi.is_active = 'Y'
                 and dipq.price_option_call_off_status in
                     ('Called Off', 'Not Applicable')
                 and pcm.product_group_type = 'CONCENTRATES'
                 and pcm.is_active = 'Y'
                 and dipq.is_active = 'Y'
                 and pci.is_active = 'Y'
                 and pcbpd.is_active = 'Y'
                 and poch.is_active = 'Y'
                 and pocd.is_active = 'Y'
                 and ppfh.is_active = 'Y'
                 and ppfd.is_active = 'Y'
               group by pci.internal_contract_item_ref_no,
                        ppfd.instrument_id,
                        pcbpd.element_id,
                        pci.pcdi_id,
                        pcm.corporate_id
              union all
              select pcm.corporate_id,
                     pci.internal_contract_item_ref_no,
                     pcbpd.element_id,
                     ppfd.instrument_id,
                     pci.pcdi_id
                from pci_physical_contract_item     pci,
                     pcdi_pc_delivery_item          pcdi,
                     pcipf_pci_pricing_formula      pcipf,
                     pcbph_pc_base_price_header     pcbph,
                     pcbpd_pc_base_price_detail     pcbpd,
                     ppfh_phy_price_formula_header  ppfh,
                     ppfd_phy_price_formula_details ppfd,
                     dipq_delivery_item_payable_qty dipq,
                     pcm_physical_contract_main     pcm
               where pci.internal_contract_item_ref_no =
                     pcipf.internal_contract_item_ref_no
                 and pcipf.pcbph_id = pcbph.pcbph_id
                 and pcbph.pcbph_id = pcbpd.pcbph_id
                 and pcbpd.pcbpd_id = ppfh.pcbpd_id
                 and ppfh.ppfh_id = ppfd.ppfh_id
                 and pci.pcdi_id = pcdi.pcdi_id
                 and pcdi.pcdi_id = dipq.pcdi_id
                 and pcdi.internal_contract_ref_no =
                     pcm.internal_contract_ref_no                 
                 and dipq.element_id = pcbpd.element_id
                 and pcdi.is_active = 'Y'
                 and dipq.price_option_call_off_status = 'Not Called Off'
                 and pcm.product_group_type = 'CONCENTRATES'
                 and pcm.is_active = 'Y'
                 and dipq.is_active = 'Y'
                 and pci.is_active = 'Y'
                 and pcipf.is_active = 'Y'
                 and pcbph.is_active = 'Y'
                 and pcbpd.is_active = 'Y'
                 and ppfh.is_active = 'Y'
                 and ppfd.is_active = 'Y'
               group by pci.internal_contract_item_ref_no,
                        ppfd.instrument_id,
                        pcbpd.element_id,
                        pci.pcdi_id,
                        pcm.corporate_id) tt,
             dim_der_instrument_master dim,
             pdd_product_derivative_def pdd,
             emt_exchangemaster emt
       where tt.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
       group by tt.internal_contract_item_ref_no,
                tt.element_id,
                tt.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                tt.pcdi_id,
                tt.corporate_id;