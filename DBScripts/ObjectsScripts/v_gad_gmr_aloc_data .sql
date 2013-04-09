create or replace view v_gad_gmr_aloc_data as
select gpah.internal_gmr_ref_no,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis,
             gpah.gpah_id,
             nvl(gpah.final_price_in_pricing_cur, 0) final_price,
             gpah.finalize_date,
             pocd.final_price_unit_id,
             nvl(pcbph.valuation_price_percentage,100) / 100 valuation_price_percentage,
             pocd.final_price_unit_id pay_in_price_unit_id
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             gpah_gmr_price_alloc_header    gpah,
             gpad_gmr_price_alloc_dtls      gpad,
             pcdi_pc_delivery_item          pcdi
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
         and nvl(gpah.element_id,'NA') = nvl(poch.element_id,'NA')-- Accommodate Base Metals
         and gpad.gpah_id = gpah.gpah_id
       group by gpah.internal_gmr_ref_no,
                pcbpd.element_id,
                pcbpd.pcbpd_id,
                pcbpd.qty_to_be_priced,
                pcbpd.price_basis,
                gpah.gpah_id,
                nvl(gpah.final_price_in_pricing_cur, 0),
                gpah.finalize_date,
                pocd.final_price_unit_id,
                nvl(pcbph.valuation_price_percentage,100) / 100
  union all

      select
             grd.internal_gmr_ref_no,
             pcbpd.element_id,
             pcbpd.pcbpd_id,
             pcbpd.qty_to_be_priced,
             pcbpd.price_basis,
             null gpah_id,
             0 final_price,
             null finalize_date,
             pocd.final_price_unit_id final_price_unit_id,
             nvl(pcbph.valuation_price_percentage,100) / 100 valuation_price_percentage,
             pocd.final_price_unit_id pay_in_price_unit_id
        from poch_price_opt_call_off_header poch,
             pocd_price_option_calloff_dtls pocd,
             pofh_price_opt_fixation_header pofh,
             pfd_price_fixation_details     pfd,
             pcbpd_pc_base_price_detail     pcbpd,
             pcbph_pc_base_price_header     pcbph,
             pcdi_pc_delivery_item          pcdi,
             grd_goods_record_detail        grd
       where poch.poch_id = pocd.poch_id
         and pcdi.pcdi_id = poch.pcdi_id
         and pocd.pocd_id = pofh.pocd_id
         and pcbpd.pcbpd_id = pocd.pcbpd_id
         and pofh.pofh_id = pfd.pofh_id(+)
         and pfd.is_active(+) = 'Y'
         and pofh.is_active(+) = 'Y'
         and pcbpd.pcbph_id = pcbph.pcbph_id
         and pocd.is_active = 'Y'
         and poch.is_active = 'Y'
         and pcdi.price_allocation_method = 'Price Allocation'
         and nvl(pocd.is_any_day_pricing, 'N') = 'Y'
         and grd.pcdi_id = pcdi.pcdi_id
            -- Though DI is Price Allocation, there could be some elements with Event Based Pricing
            -- For Which Price is Already Calcualted  in sp_conc_gmr_cog_price
         and pocd.qp_period_type <> 'Event'
         and not exists
       (select *
                from gpah_gmr_price_alloc_header gpah
               where gpah.is_active = 'Y'
                 and gpah.internal_gmr_ref_no = grd.internal_gmr_ref_no
                 and nvl(gpah.element_id,'NA') =  nvl(pcbpd.element_id,'NA'))-- Accommodate Base Metals
       group by grd.internal_gmr_ref_no,
                pofh.pofh_id,
                pcbpd.element_id,
                pcbpd.pcbpd_id,
                pcbpd.qty_to_be_priced,
                pcbpd.price_basis,
                nvl(pcbph.valuation_price_percentage,100) / 100 ,
                pocd.final_price_unit_id;
