  create or replace view V_ged_gmr_exchange_detail as     
      select gmr.corporate_id,
             pofh.internal_gmr_ref_no,
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
        from pofh_price_opt_fixation_header pofh,
             pocd_price_option_calloff_dtls pocd,
             pcbpd_pc_base_price_detail     pcbpd,
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
             pdc_prompt_delivery_calendar   pdc,
             gmr_goods_movement_record      gmr
       where pofh.pocd_id = pocd.pocd_id
         and pocd.pcbpd_id = pcbpd.pcbpd_id
         and pcbpd.pcbpd_id = ppfh.pcbpd_id
         and ppfh.ppfh_id = ppfd.ppfh_id        
         and ppfd.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.exchange_id = emt.exchange_id(+)
         and pofh.internal_gmr_ref_no is not null
         and pofh.is_active = 'Y'
         and pocd.is_active = 'Y'
         and pcbpd.is_active = 'Y'
         and ppfh.is_active = 'Y'
         and ppfd.is_active = 'Y'         
         and dim.instrument_id = div.instrument_id
         and div.is_deleted = 'N'
         and div.price_source_id = ps.price_source_id
         and div.available_price_id = apm.available_price_id
         and div.price_unit_id = pum.price_unit_id
         and dim.instrument_id = vdip.instrument_id
         and dim.delivery_calender_id = pdc.prompt_delivery_calendar_id
         and pofh.internal_gmr_ref_no=gmr.internal_gmr_ref_no
       group by pofh.internal_gmr_ref_no,
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
                pdc.is_monthly_cal_applicable,
                gmr.corporate_id;
