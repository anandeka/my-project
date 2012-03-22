CREATE OR REPLACE PROCEDURE "SP_SPOT_CUR_EXCHANGE_RATE"
/**************************************************************************************************
  Function Name                       : sp_spot_cur_exchange
  Author                              :Ashok
  Created Date                        : 24 Sep 2011
  Purpose                             : To get Spot Price
  Parameters                          :Corporateid,Trade Date ,Currency Pair
  Returns                             : Spot Rate
  Number                              : Converted Qty
  Modification History
  Modified Date			:
  Modified By  :
  Modify Description :
  ***************************************************************************************************/
(pc_corporate_id     in varchar2,
 pc_currency_pair    in varchar2,
 pc_fx_off_day_price in varchar2,
 pd_qp_start_date    in date,
 pd_qp_end_date      in date,
 pc_price_source_id  in varchar2,
 pobj_formula        out tp_tbl_formula) is
  vn_row_count          number;
  vd_sdate              date;
  vd_edate              date;
  vd_prev_working_date  date;
  vd_next_working_date  date;
  vd_first_working_date date;
  vd_last_working_date  date;
  vn_prev_working_day_price number;
  vn_next_working_day_price number;
  k                         number;
  j                         number := 1;
  vc_instrument_id          varchar2(15);
  vc_direct_pair            varchar2(1);
  --vn_last_day               number;
  vtp_tbl_formula      tp_tbl_formula := tp_tbl_formula();
  vtp_tbl_temp_formula tp_tbl_formula := tp_tbl_formula();
  
begin

  vc_direct_pair := 'Y';
  vn_row_count   := 1;
  begin
    select max(dim.instrument_id)
      into vc_instrument_id
      from cci_corp_currency_instrument cci,
           dim_der_instrument_master    dim,
           pdd_product_derivative_def   pdd,
           pdm_productmaster            pdm,
           pdm_productmaster            pdm_dir
     where cci.instrument_id = dim.instrument_id
       and dim.product_derivative_id = pdd.derivative_def_id
       and pdd.product_id = pdm.product_id
       and cci.corporate_id = pc_corporate_id
       and cci.is_deleted = 'N'
       and dim.is_active = 'Y'
       and pdd.is_active = 'Y'
       and pdm.is_active = 'Y'
       and pdm.base_cur_id = pdm_dir.base_cur_id
       and pdm.quote_cur_id = pdm_dir.quote_cur_id
       and pdm_dir.product_id = pc_currency_pair;
    vc_direct_pair := 'Y';
  exception
    when no_data_found then
      vc_direct_pair := 'N';
      select max(dim.instrument_id)
        into vc_instrument_id
        from cci_corp_currency_instrument cci,
             dim_der_instrument_master    dim,
             pdd_product_derivative_def   pdd,
             pdm_productmaster            pdm,
             pdm_productmaster            pdm_dir
       where cci.instrument_id = dim.instrument_id
         and dim.product_derivative_id = pdd.derivative_def_id
         and pdd.product_id = pdm.product_id
         and cci.corporate_id = pc_corporate_id
         and cci.is_deleted = 'N'
         and dim.is_active = 'Y'
         and pdd.is_active = 'Y'
         and pdm.is_active = 'Y'
         and pdm.base_cur_id = pdm_dir.quote_cur_id
         and pdm.quote_cur_id = pdm_dir.base_cur_id
         and pdm_dir.product_id = pc_currency_pair;
  end;
  --loop will run from first working day to last working day ,
  --but the return 
  vd_first_working_date := pd_qp_start_date;
  loop
    if pkg_cdc_formula_builder.f_is_day_holiday(vc_instrument_id,
                                                vd_first_working_date) then
      vd_first_working_date := vd_first_working_date - 1;
    else
      exit;
    end if;
  end loop;
  vd_last_working_date := pd_qp_end_date;
  loop
    if pkg_cdc_formula_builder.f_is_day_holiday(vc_instrument_id,
                                                vd_last_working_date) then
      vd_last_working_date := vd_last_working_date + 1;
    else
      exit;
    end if;
  end loop;
  vd_sdate := vd_first_working_date;
  vd_edate := vd_last_working_date;
  while vd_edate >= vd_sdate loop
    vtp_tbl_formula.extend;
    /*Check for the if trade_date is Holiday*/
    vtp_tbl_formula(vn_row_count) := tp_obj_formula(vd_sdate,
                                                    null, --instrument_id
                                                    null, --is_holiday
                                                    null, --DR_ID
                                                    null, --Price
                                                    null, --avl_price_date
                                                    null, --fx_rate
                                                    pc_fx_off_day_price,
                                                    null, --price_unit
                                                    null, --vag_fx_rate
                                                    null, --price_expo_status
                                                    null, --expo_qty
                                                    null, --expo_qty_unit_id
                                                    null, --expo_val
                                                    null); --expo_cur_id
    begin
      select cfqd.rate, cfqd.dr_id, dim.instrument_id
        into vtp_tbl_formula(vn_row_count) .price,
             vtp_tbl_formula(vn_row_count) .drid,
             vtp_tbl_formula(vn_row_count) .instrumentid
        from cfqd_currency_fwd_quote_detail cfqd,
             cfq_currency_forward_quotes    cfq,
             pdd_product_derivative_def     pdd,
             dim_der_instrument_master      dim
       where cfq.cfq_id = cfqd.cfq_id
         and cfq.instrument_id = dim.instrument_id
         and pdd.derivative_def_id = dim.product_derivative_id
         and cfq.corporate_id = pc_corporate_id
         and cfq.trade_date = vd_sdate
         and dim.instrument_id = vc_instrument_id
            -- and pdd.product_id = pc_currency_pair
         and cfqd.is_deleted = 'N'
         and cfq.price_source_id = pc_price_source_id
         and cfqd.is_spot = 'Y'
         and cfq.is_deleted = 'N'
         and dim.is_active = 'Y'
         and pdd.is_active = 'Y';
    exception
      when no_data_found then
        vtp_tbl_formula(vn_row_count).price := null;
        vtp_tbl_formula(vn_row_count).drid := null;
        begin
          select dim.instrument_id
            into vtp_tbl_formula(vn_row_count) .instrumentid
            from pdd_product_derivative_def pdd,
                 dim_der_instrument_master  dim
           where dim.product_derivative_id = pdd.derivative_def_id
                -- and pdd.product_id = pc_currency_pair
             and dim.instrument_id = vc_instrument_id
             and pdd.is_active = 'Y'
             and pdd.is_deleted = 'N'
             and dim.is_currency_curve = 'Y'
             and dim.is_deleted = 'N'
             and dim.is_active = 'Y';
        exception
          when no_data_found then
            null;
          when others then
            null;
        end;
    end;
    vd_sdate     := vd_sdate + 1;
    vn_row_count := vn_row_count + 1;  
  end loop; /*End of pricing*/
  /*Setting the holiday status*/
  for i in vtp_tbl_formula.first .. vtp_tbl_formula.last loop
    if pkg_cdc_formula_builder.f_is_day_holiday(vtp_tbl_formula(i)
                                                .instrumentid,
                                                vtp_tbl_formula(i).tradedate) then
      vtp_tbl_formula(i).isholiday := 'Y';
    else
      vtp_tbl_formula(i).isholiday := 'N';
    end if;
  end loop; /*End of setting holiday*/
  /*Setting the price for the off_day_price*/
  for i in vtp_tbl_formula.first .. vtp_tbl_formula.last loop
    if vtp_tbl_formula(i).isholiday = 'Y' then
      if vtp_tbl_formula(i).fb_off_day_price = 'Skip' then
        vtp_tbl_formula(i).price := null;
      elsif vtp_tbl_formula(i).fb_off_day_price = 'First Day Repeat' then
        if vtp_tbl_formula(vtp_tbl_formula.first).isholiday = 'Y' then
          vd_prev_working_date := vtp_tbl_formula(1).tradedate;
          --Get Previous working day
          loop
            if pkg_cdc_formula_builder.f_is_day_holiday(vtp_tbl_formula(i)
                                                        .instrumentid,
                                                        vd_prev_working_date) then
              vd_prev_working_date := vd_prev_working_date - 1;
            else
              exit;
            end if;
          end loop;
          --Get the prev working day Price
          begin
            select (case
                     when vc_direct_pair = 'Y' then
                      cfqd.rate
                     else
                      1 / cfqd.rate
                   end)
              into vn_prev_working_day_price
              from cfqd_currency_fwd_quote_detail cfqd,
                   cfq_currency_forward_quotes    cfq,
                   pdd_product_derivative_def     pdd,
                   dim_der_instrument_master      dim
             where cfq.cfq_id = cfqd.cfq_id
               and cfq.instrument_id = dim.instrument_id
               and pdd.derivative_def_id = dim.product_derivative_id
               and cfq.corporate_id = pc_corporate_id
               and cfq.trade_date = vd_prev_working_date
                  --   and pdd.product_id = pc_currency_pair
               and dim.instrument_id = vc_instrument_id
               and cfqd.is_deleted = 'N'
               and cfq.price_source_id = pc_price_source_id
               and cfqd.is_spot = 'Y'
               and cfq.is_deleted = 'N'
               and dim.is_active = 'Y'
               and pdd.is_active = 'Y';
          exception
            when no_data_found then
              vn_prev_working_day_price := null;
          end;
          for i in vtp_tbl_formula.first .. vtp_tbl_formula.last loop
            if vtp_tbl_formula(i).isholiday = 'Y' then
              vtp_tbl_formula(i).price := vn_prev_working_day_price;
            end if;
          end loop;
        else
          vtp_tbl_formula(i).price := vtp_tbl_formula(vtp_tbl_formula.first)
                                     .price;
        end if;
      elsif vtp_tbl_formula(i).fb_off_day_price = 'Last Day Repeat' then
        ---
        if vtp_tbl_formula(vtp_tbl_formula.last).isholiday = 'Y' then
          vd_next_working_date := vtp_tbl_formula(vtp_tbl_formula.last)
                                 .tradedate;
          --Get the Next working day
          loop
            if pkg_cdc_formula_builder.f_is_day_holiday(vtp_tbl_formula(i)
                                                        .instrumentid,
                                                        vd_next_working_date) then
              vd_next_working_date := vd_next_working_date + 1;
            else
              exit;
            end if;
          end loop;
          --Find  the Next working day price
          begin
            select (case
                     when vc_direct_pair = 'Y' then
                      cfqd.rate
                     else
                      1 / cfqd.rate
                   end) --cfqd.rate
              into vn_next_working_day_price
              from cfqd_currency_fwd_quote_detail cfqd,
                   cfq_currency_forward_quotes    cfq,
                   pdd_product_derivative_def     pdd,
                   dim_der_instrument_master      dim
             where cfq.cfq_id = cfqd.cfq_id
               and cfq.instrument_id = dim.instrument_id
               and pdd.derivative_def_id = dim.product_derivative_id
               and cfq.corporate_id = pc_corporate_id
               and cfq.trade_date = vd_next_working_date
                  --   and pdd.product_id = pc_currency_pair
               and dim.instrument_id = vc_instrument_id
               and cfqd.is_deleted = 'N'
               and cfq.price_source_id = pc_price_source_id
               and cfqd.is_spot = 'Y'
               and cfq.is_deleted = 'N'
               and dim.is_active = 'Y'
               and pdd.is_active = 'Y';
          exception
            when no_data_found then
              vn_next_working_day_price := null;
          end;
          k := vtp_tbl_formula.last;
          --Set the Next working day price
          for i in vtp_tbl_formula.first .. vtp_tbl_formula.last loop
            if vtp_tbl_formula(i).isholiday = 'Y' then
              vtp_tbl_formula(i).price := vn_next_working_day_price;
            end if;
          end loop;
        else
          vtp_tbl_formula(i).price := vtp_tbl_formula(vtp_tbl_formula.last)
                                     .price;
        end if;
        ---
      elsif vtp_tbl_formula(i).fb_off_day_price = 'Previous Day Repeat' then
        if i = 1 and vtp_tbl_formula(1).isholiday = 'Y' then
          vd_prev_working_date := vtp_tbl_formula(i).tradedate;
          --Get Previous working day
          loop
            if pkg_cdc_formula_builder.f_is_day_holiday(vtp_tbl_formula(i)
                                                        .instrumentid,
                                                        vd_prev_working_date) then
              vd_prev_working_date := vd_prev_working_date - 1;
            else
              exit;
            end if;
          end loop;
          --Get the prev working day Price
          begin
            select (case
                     when vc_direct_pair = 'Y' then
                      cfqd.rate
                     else
                      1 / cfqd.rate
                   end)
              into vn_prev_working_day_price
              from cfqd_currency_fwd_quote_detail cfqd,
                   cfq_currency_forward_quotes    cfq,
                   pdd_product_derivative_def     pdd,
                   dim_der_instrument_master      dim
             where cfq.cfq_id = cfqd.cfq_id
               and cfq.instrument_id = dim.instrument_id
               and pdd.derivative_def_id = dim.product_derivative_id
               and cfq.corporate_id = pc_corporate_id
               and cfq.trade_date = vd_prev_working_date
                  -- and pdd.product_id = pc_currency_pair
               and dim.instrument_id = vc_instrument_id
               and cfqd.is_deleted = 'N'
               and cfq.price_source_id = pc_price_source_id
               and cfqd.is_spot = 'Y'
               and cfq.is_deleted = 'N'
               and dim.is_active = 'Y'
               and pdd.is_active = 'Y';
          exception
            when no_data_found then
              vn_prev_working_day_price := null;
          end;
          --Set  the price  to the formula
          for i in vtp_tbl_formula.first .. vtp_tbl_formula.last loop
            if vtp_tbl_formula(i).isholiday = 'Y' then
              vtp_tbl_formula(i).price := vn_prev_working_day_price;
            else
              exit;
            end if;
          end loop;
        else
          if vtp_tbl_formula(i).price is null then
            for j in vtp_tbl_formula.first .. i loop
              if vtp_tbl_formula(i - j).isholiday = 'N' then
                vtp_tbl_formula(i).price := vtp_tbl_formula(i - j).price;
                exit;
              end if;
            end loop;
          end if;
        end if;
      elsif vtp_tbl_formula(i).fb_off_day_price = 'Next Day Repeat' then
        for j in i + 1 .. vtp_tbl_formula.last loop
          if vtp_tbl_formula(j).isholiday = 'N' then
            vtp_tbl_formula(i).price := vtp_tbl_formula(j).price;
            exit;
          end if;
        end loop;
        if vtp_tbl_formula(vtp_tbl_formula.last).isholiday = 'Y' then
          vd_next_working_date := vtp_tbl_formula(vtp_tbl_formula.last)
                                 .tradedate;
          --Get the Next working day
          loop
            if pkg_cdc_formula_builder.f_is_day_holiday(vtp_tbl_formula(i)
                                                        .instrumentid,
                                                        vd_next_working_date) then
              vd_next_working_date := vd_next_working_date + 1;
            else
              exit;
            end if;
          end loop;
          --Find  the Next working day price
          begin
            select (case
                     when vc_direct_pair = 'Y' then
                      cfqd.rate
                     else
                      1 / cfqd.rate
                   end)
              into vn_next_working_day_price
              from cfqd_currency_fwd_quote_detail cfqd,
                   cfq_currency_forward_quotes    cfq,
                   pdd_product_derivative_def     pdd,
                   dim_der_instrument_master      dim
             where cfq.cfq_id = cfqd.cfq_id
               and cfq.instrument_id = dim.instrument_id
               and pdd.derivative_def_id = dim.product_derivative_id
               and cfq.corporate_id = pc_corporate_id
               and cfq.trade_date = vd_next_working_date
                  --  and pdd.product_id = pc_currency_pair
               and dim.instrument_id = vc_instrument_id
               and cfqd.is_deleted = 'N'
               and cfq.price_source_id = pc_price_source_id
               and cfqd.is_spot = 'Y'
               and cfq.is_deleted = 'N'
               and dim.is_active = 'Y'
               and pdd.is_active = 'Y';
          exception
            when no_data_found then
              vn_next_working_day_price := null;
          end;
          k := vtp_tbl_formula.last;
          --Set the Next working day price
          loop
            if vtp_tbl_formula(k).isholiday = 'Y' then
              vtp_tbl_formula(k).price := vn_next_working_day_price;
              k := k - 1;
            else
              exit;
            end if;
          end loop;
        end if;
      end if;
    end if;
  end loop;
  /*for displayig the value in the type  */
  /*for i in vtp_tbl_formula.first .. vtp_tbl_formula.last
  loop
    dbms_output.put_line('Trade Date- ' || vtp_tbl_formula(i)
                         .tradedate || ' Instrument id - ' ||
                         vtp_tbl_formula(i)
                         .instrumentid || ' Is holiday - ' ||
                         vtp_tbl_formula(i)
                         .isholiday || ' Drid - ' || vtp_tbl_formula(i)
                         .drid || ' Price - ' || vtp_tbl_formula(i)
                         .price || ' Off day Price - ' ||
                         vtp_tbl_formula(i).fb_off_day_price);
  end loop;*/
  --setting to the out put of the type according to the qp period
  for i in vtp_tbl_formula.first .. vtp_tbl_formula.last loop
    if vtp_tbl_formula(i) .tradedate >= pd_qp_start_date and
     vtp_tbl_formula(i) .tradedate <= pd_qp_end_date then
      vtp_tbl_temp_formula.extend;
      -- vtp_tbl_temp_formula(j).tradedate:=vtp_tbl_formula(i).tradedate;
      vtp_tbl_temp_formula(j) := tp_obj_formula(vtp_tbl_formula(i)
                                                .tradedate,
                                                vtp_tbl_formula(i)
                                                .instrumentid,
                                                vtp_tbl_formula(i).isholiday,
                                                vtp_tbl_formula(i).drid,
                                                vtp_tbl_formula(i).price,
                                                vtp_tbl_formula(i)
                                                .vd_avl_price_date,
                                                vtp_tbl_formula(i).fx_rate,
                                                vtp_tbl_formula(i)
                                                .fb_off_day_price,
                                                vtp_tbl_formula(i)
                                                .price_unit_id,
                                                vtp_tbl_formula(i)
                                                .avg_fx_rate,
                                                vtp_tbl_formula(i)
                                                .price_exp_status,
                                                vtp_tbl_formula(i)
                                                .exp_quantity,
                                                vtp_tbl_formula(i)
                                                .exp_quantity_unit_id,
                                                vtp_tbl_formula(i).exp_value,
                                                vtp_tbl_formula(i)
                                                .exp_cur_id);
      j := j + 1;
    end if;
  end loop;
  pobj_formula := tp_tbl_formula();
  pobj_formula.extend;
  pobj_formula := vtp_tbl_temp_formula;
exception
  when others then
    dbms_output.put_line(sqlerrm);
end;
/
