CREATE OR REPLACE VIEW v_contract_exchange_detail ( internal_contract_item_ref_no,
                                         element_id,
                                         instrument_id,
                                         instrument_name,
                                         derivative_def_id,
                                         derivative_def_name,
                                         exchange_id,
                                         exchange_name
                                        )
AS
   SELECT   tt.internal_contract_item_ref_no, tt.element_id,
            tt.instrument_id, dim.instrument_name, pdd.derivative_def_id,
            pdd.derivative_def_name, emt.exchange_id, emt.exchange_name
       FROM (SELECT   pci.internal_contract_item_ref_no,
                      poch.element_id, ppfd.instrument_id
                 FROM pci_physical_contract_item pci,
                      pcdi_pc_delivery_item pcdi,
                      poch_price_opt_call_off_header poch,
                      pocd_price_option_calloff_dtls pocd,
                      pcbpd_pc_base_price_detail pcbpd,
                      ppfh_phy_price_formula_header ppfh,
                      ppfd_phy_price_formula_details ppfd,
                      pcm_physical_contract_main pcm
                WHERE pci.pcdi_id = pcdi.pcdi_id
                  AND pcdi.pcdi_id = poch.pcdi_id
                  AND poch.poch_id = pocd.poch_id
                  AND pocd.pcbpd_id = pcbpd.pcbpd_id
                  AND pcbpd.pcbpd_id = ppfh.pcbpd_id
                  AND ppfh.ppfh_id = ppfd.ppfh_id
                  AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
                  AND pcm.is_active = 'Y'
                  AND pci.is_active = 'Y'
                  AND pcdi.is_active = 'Y'
                  AND poch.is_active = 'Y'
                  AND pocd.is_active = 'Y'
                  AND pcbpd.is_active = 'Y'
                  AND ppfh.is_active = 'Y'
                  AND ppfd.is_active = 'Y'
                  AND pcm.product_group_type = 'BASEMETAL'
                  AND pcdi.price_option_call_off_status IN ('Called Off', 'Not Applicable')
             GROUP BY pci.internal_contract_item_ref_no,
                      ppfd.instrument_id,
                      poch.element_id
             UNION ALL
             SELECT   pci.internal_contract_item_ref_no,
                      pcbpd.element_id, ppfd.instrument_id
                 FROM pci_physical_contract_item pci,
                      pcdi_pc_delivery_item pcdi,
                      pcipf_pci_pricing_formula pcipf,
                      pcbph_pc_base_price_header pcbph,
                      pcbpd_pc_base_price_detail pcbpd,
                      ppfh_phy_price_formula_header ppfh,
                      ppfd_phy_price_formula_details ppfd,
                      pcm_physical_contract_main pcm
                WHERE pci.internal_contract_item_ref_no =pcipf.internal_contract_item_ref_no
                  AND pcipf.pcbph_id = pcbph.pcbph_id
                  AND pcbph.pcbph_id = pcbpd.pcbph_id
                  AND pcbpd.pcbpd_id = ppfh.pcbpd_id
                  AND ppfh.ppfh_id = ppfd.ppfh_id
                  AND pci.pcdi_id = pcdi.pcdi_id
                  AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
                  AND pcdi.is_active = 'Y'
                  AND pcm.product_group_type = 'BASEMETAL'
                  AND pcdi.price_option_call_off_status = 'Not Called Off'
                  AND pcm.is_active = 'Y'
                  AND pci.is_active = 'Y'
                  AND pcipf.is_active = 'Y'
                  AND pcbph.is_active = 'Y'
                  AND pcbpd.is_active = 'Y'
                  AND ppfh.is_active = 'Y'
                  AND ppfd.is_active = 'Y'
             GROUP BY pci.internal_contract_item_ref_no,
                      ppfd.instrument_id,
                      pcbpd.element_id
             UNION ALL
             SELECT   pci.internal_contract_item_ref_no,
                      pcbpd.element_id, ppfd.instrument_id
                 FROM pci_physical_contract_item pci,
                      pcdi_pc_delivery_item pcdi,
                      poch_price_opt_call_off_header poch,
                      pocd_price_option_calloff_dtls pocd,
                      pcbpd_pc_base_price_detail pcbpd,
                      ppfh_phy_price_formula_header ppfh,
                      ppfd_phy_price_formula_details ppfd,
                      dipq_delivery_item_payable_qty dipq,
                      pcm_physical_contract_main pcm
                WHERE pci.pcdi_id = pcdi.pcdi_id
                  AND pcdi.pcdi_id = poch.pcdi_id
                  AND poch.poch_id = pocd.poch_id
                  AND pocd.pcbpd_id = pcbpd.pcbpd_id
                  AND pcbpd.pcbpd_id = ppfh.pcbpd_id
                  AND ppfh.ppfh_id = ppfd.ppfh_id
                  AND pcdi.pcdi_id = dipq.pcdi_id
                  AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
                  AND pcdi.is_active = 'Y'
                  AND dipq.price_option_call_off_status IN ('Called Off', 'Not Applicable')
                  AND pcm.product_group_type = 'CONCENTRATES'
                  AND pcm.is_active = 'Y'
                  AND dipq.is_active = 'Y'
                  AND pci.is_active = 'Y'
                  AND pcbpd.is_active = 'Y'
                  AND poch.is_active = 'Y'
                  AND pocd.is_active = 'Y'
                  AND ppfh.is_active = 'Y'
                  AND ppfd.is_active = 'Y'
             GROUP BY pci.internal_contract_item_ref_no,
                      ppfd.instrument_id,
                      pcbpd.element_id
             UNION ALL
             SELECT   pci.internal_contract_item_ref_no,
                      pcbpd.element_id, ppfd.instrument_id
                 FROM pci_physical_contract_item pci,
                      pcdi_pc_delivery_item pcdi,
                      pcipf_pci_pricing_formula pcipf,
                      pcbph_pc_base_price_header pcbph,
                      pcbpd_pc_base_price_detail pcbpd,
                      ppfh_phy_price_formula_header ppfh,
                      ppfd_phy_price_formula_details ppfd,
                      dipq_delivery_item_payable_qty dipq,
                      pcm_physical_contract_main pcm
                WHERE pci.internal_contract_item_ref_no = pcipf.internal_contract_item_ref_no
                  AND pcipf.pcbph_id = pcbph.pcbph_id
                  AND pcbph.pcbph_id = pcbpd.pcbph_id
                  AND pcbpd.pcbpd_id = ppfh.pcbpd_id
                  AND ppfh.ppfh_id = ppfd.ppfh_id
                  AND pci.pcdi_id = pcdi.pcdi_id
                  AND pcdi.pcdi_id = dipq.pcdi_id
                  AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
                  AND pcdi.is_active = 'Y'
                  AND dipq.price_option_call_off_status = 'Not Called Off'
                  AND pcm.product_group_type = 'CONCENTRATES'
                  AND pcm.is_active = 'Y'
                  AND dipq.is_active = 'Y'
                  AND pci.is_active = 'Y'
                  AND pcipf.is_active = 'Y'
                  AND pcbph.is_active = 'Y'
                  AND pcbpd.is_active = 'Y'
                  AND ppfh.is_active = 'Y'
                  AND ppfd.is_active = 'Y'
             GROUP BY pci.internal_contract_item_ref_no,
                      ppfd.instrument_id,
                      pcbpd.element_id) tt,
            dim_der_instrument_master dim,
            pdd_product_derivative_def pdd,
            emt_exchangemaster emt
      WHERE tt.instrument_id = dim.instrument_id
        AND dim.product_derivative_id = pdd.derivative_def_id
        AND pdd.exchange_id = emt.exchange_id(+)
   GROUP BY tt.internal_contract_item_ref_no,
            tt.element_id,
            tt.instrument_id,
            dim.instrument_name,
            pdd.derivative_def_id,
            pdd.derivative_def_name,
            emt.exchange_id,
            emt.exchange_name;

