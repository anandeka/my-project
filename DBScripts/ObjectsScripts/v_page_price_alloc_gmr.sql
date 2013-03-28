 create or replace view v_page_price_alloc_gmr as     
      select gpah.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name,
             pcbpd.element_id,
             ps.price_source_id,
             ps.price_source_name,
             apm.available_price_id,
             apm.available_price_name,
             pum.price_unit_name,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             gpah_gmr_price_alloc_header    gpah,
             gpad_gmr_price_alloc_dtls      gpad,
             pcdi_pc_delivery_item          pcdi,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd,
             dim_der_instrument_master      dim,
             pdd_product_derivative_def     pdd,
             emt_exchangemaster             emt,
             div_der_instrument_valuation   div,
             ps_price_source                ps,
             apm_available_price_master     apm,
             pum_price_unit_master          pum,
             v_der_instrument_price_unit    vdip,
             pdc_prompt_delivery_calendar   pdc
       where poch.poch_id = pocd.poch_id
         and gpad.pfd_id = pfd.pfd_id
         and pcdi.pcdi_id = poch.pcdi_id
         and pocd.pocd_id = pofh.pocd_id(+)
         and pcbpd.pcbpd_id = pocd.pcbpd_id
         and pofh.pofh_id = pfd.pofh_id(+)
         and pfd.is_active(+) = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.pocd_id = gpah.pocd_id
         and pocd.is_active = 'Y'
         and poch.is_active = 'Y'
         and gpah.is_active = 'Y'
         and gpad.is_active = 'Y'
         and pcdi.price_allocation_method = 'Price Allocation'
         and nvl(pocd.is_any_day_pricing, 'N') = 'Y'
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.ppfh_id = ppfd.ppfh_id
         and ppfd.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
         and gpad.gpah_id = gpah.gpah_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
       group by gpah.internal_gmr_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                pcbpd.element_id,
                ps.price_source_id,
                ps.price_source_name,
                apm.available_price_id,
                apm.available_price_name,
                pum.price_unit_name,
                vdip.ppu_price_unit_id,
                div.price_unit_id,
                dim.delivery_calender_id,
                pdc.is_daily_cal_applicable,
                pdc.is_monthly_cal_applicable
      union all
      
      select grd.internal_gmr_ref_no,
             ppfd.instrument_id,
             dim.instrument_name,
             pdd.derivative_def_id,
             pdd.derivative_def_name,
             emt.exchange_id,
             emt.exchange_name,
             pcbpd.element_id,
             ps.price_source_id,
             ps.price_source_name,
             apm.available_price_id,
             apm.available_price_name,
             pum.price_unit_name,
             vdip.ppu_price_unit_id,
             div.price_unit_id,
             dim.delivery_calender_id,
             pdc.is_daily_cal_applicable,
             pdc.is_monthly_cal_applicable
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             pcdi_pc_delivery_item          pcdi,
             ppfh_phy_price_formula_header  ppfh,
             ppfd_phy_price_formula_details ppfd,
             dim_der_instrument_master      dim,
             pdd_product_derivative_def     pdd,
             emt_exchangemaster             emt,
             grd_goods_record_detail        grd,
             div_der_instrument_valuation   div,
             ps_price_source                ps,
             apm_available_price_master     apm,
             pum_price_unit_master          pum,
             v_der_instrument_price_unit    vdip,
             pdc_prompt_delivery_calendar   pdc
       where poch.poch_id = pocd.poch_id
         and pcdi.pcdi_id = poch.pcdi_id
         and pocd.pocd_id = pofh.pocd_id(+)
         and pcbpd.pcbpd_id = pocd.pcbpd_id
         and pofh.pofh_id = pfd.pofh_id(+)
         and pfd.is_active(+) = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.is_active = 'Y'
         and poch.is_active = 'Y'
         and pcdi.price_allocation_method = 'Price Allocation'
         and nvl(pocd.is_any_day_pricing, 'N') = 'Y'
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.ppfh_id = ppfd.ppfh_id
         and ppfd.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
         and grd.pcdi_id = pcdi.pcdi_id
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
            -- Though DI is Price Allocation, there could be some elements with Event Based Pricing
            -- For Which Price is Already Calcualted  in sp_conc_gmr_cog_price       
         and pocd.qp_period_type <> 'Event'
         and not exists
       (select *
                from gpah_gmr_price_alloc_header gpah
               where gpah.is_active = 'Y'
                 and gpah.element_id = poch.element_id
                 and gpah.internal_gmr_ref_no = grd.internal_gmr_ref_no)
       group by grd.internal_gmr_ref_no,
                ppfd.instrument_id,
                dim.instrument_name,
                pdd.derivative_def_id,
                pdd.derivative_def_name,
                emt.exchange_id,
                emt.exchange_name,
                pcbpd.element_id,
                ps.price_source_id,
                ps.price_source_name,
                apm.available_price_id,
                apm.available_price_name,
                pum.price_unit_name,
                vdip.ppu_price_unit_id,
                div.price_unit_id,
                dim.delivery_calender_id,
                pdc.is_daily_cal_applicable,
                pdc.is_monthly_cal_applicable
