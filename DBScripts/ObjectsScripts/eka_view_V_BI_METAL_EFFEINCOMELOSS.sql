CREATE OR REPLACE VIEW V_BI_METAL_EFFEINCOMELOSS AS
SELECT axs.action_ref_no AS pricefixationrefno, pfd.pfd_id,
          pcm.contract_ref_no, aml.attribute_name element_name,
          (CASE
              WHEN pcm.purchase_sales = 'P'
                 THEN 'Buy'
              ELSE 'Sell'
           END
          ) fixation_type,
          pcdi.delivery_period_type,
          (pcm.contract_ref_no || ' - ' || pcdi.delivery_item_no) di_ref_no,
          (CASE
              WHEN pcdi.delivery_period_type = 'Date'
                 THEN TO_CHAR (pcdi.delivery_to_date, 'Mon-YYYY')
              ELSE (pcdi.delivery_to_month || '-' || pcdi.delivery_to_year)
           END
          ) delivery_period,
          TO_CHAR (pfd.as_of_date, 'dd-Mon-YYYY') price_fixation_date,
          (   TO_CHAR (pofh.qp_start_date, 'dd-Mon-yyyy')
           || ' to '
           || TO_CHAR (pofh.qp_end_date, 'dd-Mon-yyyy')
          ) AS qpperiod,
          phd.companyname cp_name, pum.price_unit_name,
          ppu.decimals price_decimal, pfd.user_price,
          pkg_general.f_get_converted_price
                         (base_cur_tab.corporate_id,
                          pfd.user_price,
                          pum.price_unit_id,
                          base_cur_tab.base_price_unit_id,
                          SYSDATE
                         ) price_in_base_unit,
          dt.derivative_ref_no internal_trade_ref_no,
          (  tad.allocated_qty
           * pkg_general.f_get_converted_quantity (pdm.product_id,
                                                   tad.allocated_qty_unit_id,
                                                   pdm.base_quantity_unit,
                                                   1
                                                  )
          ) allocated_qty,
          qum.qty_unit allocated_qty_unit,
            pfd.qty_fixed
          * pkg_general.f_get_converted_quantity (pdm.product_id,
                                                  pcdi.qty_unit_id,
                                                  pdm.base_quantity_unit,
                                                  1
                                                 ) price_fixation_qty,
          qum.qty_unit price_fixation_qty_unit,
          dim.instrument_name exchange_instrument_name, dt.trade_type,
          TO_CHAR (drm.prompt_date, 'dd-Mon-YYYY') prompt_date,
          dt.trade_price, pum_dt.price_unit_name trade_price_unit,
          base_cur_tab.base_price_unit,
          f_get_converted_price
             (base_cur_tab.corporate_id,
              dt.trade_price,
              dt.trade_price_unit_id,
              base_cur_tab.base_price_unit_id,
              SYSDATE
             ) trade_price_in_base_price_unit,
          (  (  pkg_general.f_get_converted_price
                                             (base_cur_tab.corporate_id,
                                              dt.trade_price,
                                              dt.trade_price_unit_id,
                                              base_cur_tab.base_price_unit_id,
                                              SYSDATE
                                             )
              - pkg_general.f_get_converted_price
                                             (base_cur_tab.corporate_id,
                                              pfd.user_price,
                                              pum.price_unit_id,
                                              base_cur_tab.base_price_unit_id,
                                              SYSDATE
                                             )
             )
           * tad.allocated_qty
           * pkg_general.f_get_converted_quantity (pdm.product_id,
                                                   tad.allocated_qty_unit_id,
                                                   pdm.base_quantity_unit,
                                                   1
                                                  )
          ) value_difference
     FROM pfd_price_fixation_details pfd,
          pfam_price_fix_action_mapping pfam,
          tad_trade_allocation_details tad,
          axs_action_summary axs,
          pofh_price_opt_fixation_header pofh,
          pocd_price_option_calloff_dtls pocd,
          poch_price_opt_call_off_header poch,
          pcdi_pc_delivery_item pcdi,
          pcm_physical_contract_main pcm,
          phd_profileheaderdetails phd,
          ppu_product_price_units ppu,
          pum_price_unit_master pum,
          aml_attribute_master_list aml,
          dt_derivative_trade dt,
          drm_derivative_master drm,
          dim_der_instrument_master dim,
          pum_price_unit_master pum_dt,
          qum_quantity_unit_master qum,
          pdm_productmaster pdm,
          (SELECT pum.price_unit_id base_price_unit_id,
                  pum.price_unit_name base_price_unit,
                  pdm.product_id product_id, ppu.cur_id base_cur_id,
                  ppu.weight_unit_id weight_unit_id, akc.corporate_id
             FROM v_ppu_pum ppu,
                  pdm_productmaster pdm,
                  ak_corporate akc,
                  qum_quantity_unit_master qum,
                  pum_price_unit_master pum
            WHERE ppu.product_id = pdm.product_id
              AND ppu.cur_id = akc.base_cur_id
              AND ppu.weight_unit_id = qum.qty_unit_id
              AND ppu.price_unit_id = pum.price_unit_id) base_cur_tab
    WHERE tad.price_fixation_id = pfd.pfd_id
      AND pfd.pfd_id = pfam.pfd_id
      AND pfam.internal_action_ref_no = axs.internal_action_ref_no
      AND pfd.pofh_id = pofh.pofh_id
      AND pofh.pocd_id = pocd.pocd_id
      AND pocd.poch_id = poch.poch_id
      AND poch.pcdi_id = pcdi.pcdi_id
      AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND pcm.cp_id = phd.profileid
      AND pfd.price_unit_id = ppu.internal_price_unit_id
      AND ppu.price_unit_id = pum.price_unit_id
      AND poch.element_id = aml.attribute_id
      AND tad.internal_derivative_ref_no = dt.internal_derivative_ref_no
      AND dt.dr_id = drm.dr_id
      AND drm.instrument_id = dim.instrument_id
      AND dt.trade_price_unit_id = pum_dt.price_unit_id
      AND pdm.base_quantity_unit = qum.qty_unit_id
      AND aml.underlying_product_id = pdm.product_id(+)
      AND pcm.corporate_id = base_cur_tab.corporate_id
      AND base_cur_tab.product_id = pdm.product_id
      AND base_cur_tab.weight_unit_id = qum.qty_unit_id
      AND pfd.is_active = 'Y'
      AND tad.is_active = 'Y'
      AND pofh.is_active = 'Y'
      AND pocd.is_active = 'Y'
      AND poch.is_active = 'Y'
      AND pcdi.is_active = 'Y'
      AND pcm.is_active = 'Y'
      AND phd.is_active = 'Y'
      AND ppu.is_active = 'Y'
      AND pum.is_active = 'Y'
      AND drm.is_deleted = 'N'
      AND dim.is_active = 'Y' 
