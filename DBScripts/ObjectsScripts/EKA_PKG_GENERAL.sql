create or replace package "PKG_GENERAL" is
  -- All general packages and procedures
  function f_get_converted_currency_amt(pc_corporate_id        in varchar2,
                                        pc_from_cur_id         in varchar2,
                                        pc_to_cur_id           in varchar2,
                                        pd_cur_date            in date,
                                        pn_amt_to_be_converted in number)
    return number;

  function f_get_converted_quantity(pc_product_id          in varchar2,
                                    pc_from_qty_unit_id    in varchar2,
                                    pc_to_qty_unit_id      in varchar2,
                                    pn_qty_to_be_converted in number)
    return number;

  function f_get_round_decimels(pc_eka_type in varchar2,
                                pc_type_key in varchar2) return number;

  function f_get_quantity_unit(pc_quantity_unit_id varchar2) return varchar2;

  function f_get_currency_code(pc_cur_id varchar2) return varchar2;

  function f_get_price_unit(pc_price_unit_id varchar2) return varchar2;

  function f_get_static_list_text(pc_static_value_id varchar2)
    return varchar2;

  function f_get_country_city(pc_city_id varchar2) return varchar2;

  function f_get_company_name(pc_input_profile_id varchar2) return varchar2;

  function f_get_corporate_user_name(pc_input_user_id varchar2)
    return varchar2;

  function f_get_derivative_price_unit_id(pc_priceunit     varchar2,
                                          pc_instrument_id varchar2)
    return varchar2;

  function f_get_currency_id(pc_currencyname varchar2) return varchar2;

  function f_get_quantity_id(pc_qtyunitname varchar2) return varchar2;

  function f_get_profile_id(pc_companyname varchar2) return varchar2;

  function f_get_commission_type_id(pc_profile_id           varchar2,
                                    pc_commission_type_name varchar2)
    return varchar2;

  function f_get_trader_id(pc_tradername varchar2, pc_corporateid varchar2)
    return varchar2;

  function f_is_date(pc_input_date_string varchar2) return varchar2;

  function f_is_numeric(pc_input_number_string varchar2) return varchar2;

  function f_get_incoterm(pc_incoterm_id varchar2) return varchar2;

  function f_get_converted_price(pc_corporate_id       varchar2,
                                 pn_price              number,
                                 pc_from_price_unit_id varchar2,
                                 pc_to_price_unit_id   varchar2,
                                 pd_trade_date         date) return number;

  /*PROCEDURE acl_admin_role_access;*/

  function f_get_profit_center_name(pc_profit_center_id varchar2)
    return varchar2;

  function f_get_port_country(pc_port_id varchar2) return varchar2;

  function f_get_curr_from_price_unit_id(price_unit_id varchar2)
    return varchar2;
  function f_get_price_unit_from_ppu(pc_price_unit_id varchar2)
    return varchar2;
  function f_get_converted_ref_num_to_num(ref_no varchar2) return number;
  --Added by BabuLal
  function f_get_warehouse_shed_name(pc_input_shed_id varchar2)
    return varchar2;

  function f_get_warehouse_profile_id(pc_input_shed_id varchar2)
    return varchar2;
  --Ends here by BabuLal
end; 
/
create or replace package body "PKG_GENERAL" is
  function f_get_converted_currency_amt
  /**************************************************************************************************
    Function Name                       : f_get_converted_currency_amt
    Author                              : Janna
    Created Date                        : 19th Aug 2008
    Purpose                             : To convert a given amount between two currencies as on a given date
    
    Parameters                          :
    
    pc_corporate_id                     : Corporate ID
    pc_from_cur_id                      : From Currency
    pc_to_cur_id                        : To Currency
    pd_cur_date                         : Currency Date
    pn_amt_to_be_converted              : Amount to be converted
    
    Returns                             :
    
    Number                              : Converted amount
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_corporate_id        in varchar2,
   pc_from_cur_id         in varchar2,
   pc_to_cur_id           in varchar2,
   pd_cur_date            in date,
   pn_amt_to_be_converted in number) return number is
    vn_result                    number;
    vc_base_cur_id               varchar2(30);
    vc_from_main_cur_id          varchar2(30);
    vc_to_main_cur_id            varchar2(30);
    vn_from_rate                 number;
    vn_from_main_currency_factor number := 1;
    vn_to_main_currency_factor   number := 1;
    vn_to_rate                   number;
  begin
    vn_from_rate        := 1;
    vn_to_rate          := 1;
    vc_from_main_cur_id := pc_from_cur_id;
    vc_to_main_cur_id   := pc_to_cur_id;
  
    -- Get the Base Currency ID of the corporate
    -- This is used to determine if one of the currencies given is the base currency itself
    -- Since AK_CORPORATE is not having Currency ID column and we are not changing it now
    -- We are joining CUR_CODE of CM with BASE_CURRENCY_NAME of AK_CORPORATE
    -- When AK_CORPORATE table is revamped change this code
    begin
      select akc.base_cur_id
        into vc_base_cur_id
        from ak_corporate akc
       where akc.corporate_id = pc_corporate_id;
    
    exception
      when no_data_found then
        return - 1;
    end;
  
    -- Check if the currency passed is a sub-currency if yes take into account
    -- the sub currency factor...
    begin
      select scd.cur_id,
             scd.factor
        into vc_from_main_cur_id,
             vn_from_main_currency_factor
        from cm_currency_master      cm,
             scd_sub_currency_detail scd
       where cm.cur_id = scd.cur_id
         and scd.sub_cur_id = pc_from_cur_id
         and cm.is_deleted = 'N'
         and scd.is_deleted = 'N';
    exception
      when no_data_found then
        vn_from_main_currency_factor := 1;
        vc_from_main_cur_id          := pc_from_cur_id;
    end;
  
    begin
      select scd.cur_id,
             scd.factor
        into vc_to_main_cur_id,
             vn_to_main_currency_factor
        from cm_currency_master      cm,
             scd_sub_currency_detail scd
       where cm.cur_id = scd.cur_id
         and scd.sub_cur_id = pc_to_cur_id
         and cm.is_deleted = 'N'
         and scd.is_deleted = 'N';
    exception
      when no_data_found then
        vn_to_main_currency_factor := 1;
        vc_to_main_cur_id          := pc_to_cur_id;
    end;
  
    if vc_base_cur_id = vc_from_main_cur_id and
       vc_base_cur_id = vc_to_main_cur_id then
      vn_from_rate := 1;
      vn_to_rate   := 1;
    else
      begin
        -- Get the From Currency Exchange rate
        if vc_from_main_cur_id != vc_base_cur_id then
          select cq.close_rate
            into vn_from_rate
            from cq_currency_quote cq
           where cq.cur_id = vc_from_main_cur_id
             and cq.corporate_id = pc_corporate_id
             and cq.cur_date =
                 (select max(cq1.cur_date)
                    from cq_currency_quote cq1
                   where cq1.cur_id = vc_from_main_cur_id
                     and cq1.corporate_id = pc_corporate_id
                     and cq1.cur_date <= pd_cur_date);
        end if;
      
        -- Get the To Currency Exchange rate
        if vc_to_main_cur_id != vc_base_cur_id then
          select cq.close_rate
            into vn_to_rate
            from cq_currency_quote cq
           where cq.cur_id = upper(vc_to_main_cur_id)
             and cq.corporate_id = pc_corporate_id
             and cq.cur_date =
                 (select max(cq1.cur_date)
                    from cq_currency_quote cq1
                   where cq1.cur_id = upper(vc_to_main_cur_id)
                     and cq1.corporate_id = pc_corporate_id
                     and cq1.cur_date <= pd_cur_date);
        end if;
      exception
        when no_data_found then
          return - 1;
      end;
    end if;
  
    vn_result := pn_amt_to_be_converted *
                 ((vn_to_rate / vn_to_main_currency_factor) /
                 (vn_from_rate / vn_from_main_currency_factor));
    return(vn_result);
  end;

  function f_get_is_derived_qty_unit(pc_qty_unit_id in varchar2)
    return varchar2 is
    vc_is_derived_unit varchar2(1);
  begin
    select qum.is_derrived
      into vc_is_derived_unit
      from qum_quantity_unit_master qum
     where qum.qty_unit_id = pc_qty_unit_id
       and qum.is_deleted = 'N';
  
    return vc_is_derived_unit;
  end;

  function f_get_converted_quantity(pc_product_id          in varchar2,
                                    pc_from_qty_unit_id    in varchar2,
                                    pc_to_qty_unit_id      in varchar2,
                                    pn_qty_to_be_converted in number)
    return number is
    vn_conv_factor             number;
    vn_converted_qty           number;
    vc_is_from_der_qty_unit_id varchar2(1);
    vc_is_to_der_qty_unit_id   varchar2(1);
    vc_base_form_qty_unit_id   varchar2(15) := pc_from_qty_unit_id;
    vn_from_der_to_base_conv   number(20, 5) := 1;
    vc_base_to_qty_unit_id     varchar2(15) := pc_to_qty_unit_id;
    vn_to_der_to_base_conv     number(20, 5) := 1;
  begin
    begin
      vc_is_from_der_qty_unit_id := f_get_is_derived_qty_unit(pc_from_qty_unit_id);
      vc_is_to_der_qty_unit_id   := f_get_is_derived_qty_unit(pc_to_qty_unit_id);
    
      if (vc_is_from_der_qty_unit_id = 'Y') then
        select dqu.qty_unit_id,
               dqu.qty
          into vc_base_form_qty_unit_id,
               vn_from_der_to_base_conv
          from dqu_derived_quantity_unit dqu
         where dqu.derrived_qty_unit_id = pc_from_qty_unit_id
           and dqu.product_id = pc_product_id
           and dqu.is_deleted = 'N';
      end if;
    
      if (vc_is_to_der_qty_unit_id = 'Y') then
        select dqu.qty_unit_id,
               dqu.qty
          into vc_base_to_qty_unit_id,
               vn_to_der_to_base_conv
          from dqu_derived_quantity_unit dqu
         where dqu.derrived_qty_unit_id = pc_to_qty_unit_id
           and dqu.product_id = pc_product_id
           and dqu.is_deleted = 'N';
      end if;
    
      select ucm.multiplication_factor
        into vn_conv_factor
        from ucm_unit_conversion_master ucm
       where ucm.from_qty_unit_id = vc_base_form_qty_unit_id
         and ucm.to_qty_unit_id = vc_base_to_qty_unit_id;
    
      vn_converted_qty := round(vn_from_der_to_base_conv /
                                vn_to_der_to_base_conv * vn_conv_factor *
                                pn_qty_to_be_converted,
                                10);
      return vn_converted_qty;
    exception
      when no_data_found then
        dbms_output.put_line('exception');
        return - 1;
    end;
  end;

  function f_get_round_decimels(pc_eka_type in varchar2,
                                pc_type_key in varchar2) return number is
    vn_round_decimels number;
  begin
    begin
      select vrp.no_of_decimals
        into vn_round_decimels
        from v_round_parameters vrp
       where vrp.eka_type = pc_eka_type
         and vrp.type_key = pc_type_key;
    exception
      when no_data_found then
        return - 1;
    end;
  
    return vn_round_decimels;
  end;

  function f_get_quantity_unit(pc_quantity_unit_id varchar2) return varchar2 is
    vc_qty_unit_id varchar2(15);
  begin
    select qum.qty_unit
      into vc_qty_unit_id
      from qum_quantity_unit_master qum
     where qum.qty_unit_id = pc_quantity_unit_id
       and qum.is_deleted = 'N';
  
    return(vc_qty_unit_id);
  end;

  function f_get_currency_code(pc_cur_id varchar2) return varchar2 is
    vc_currency_code varchar2(15);
  begin
    select cm.cur_code
      into vc_currency_code
      from cm_currency_master cm
     where cm.cur_id = pc_cur_id
       and cm.is_deleted = 'N';
  
    return(vc_currency_code);
  end;

  function f_get_price_unit(pc_price_unit_id varchar2) return varchar2 is
    vc_price_unit varchar2(50);
  begin
    select f_get_currency_code(pum.cur_id) || ' / ' || pum.weight || ' ' ||
           f_get_quantity_unit(pum.weight_unit_id)
      into vc_price_unit
      from pum_price_unit_master pum
     where pum.price_unit_id = pc_price_unit_id
       and pum.is_deleted = 'N';
  
    return(vc_price_unit);
  end;

  function f_get_static_list_text(pc_static_value_id varchar2)
    return varchar2 is
    vc_value_text varchar2(50);
  begin
    select slv.value_text
      into vc_value_text
      from slv_static_list_value slv
     where slv.value_id = pc_static_value_id;
  
    return(vc_value_text);
  end;

  function f_get_country_city(pc_city_id varchar2) return varchar2 is
    vc_city_country_name varchar2(100);
  begin
    select cim.city_name || ', ' || cym.country_name
      into vc_city_country_name
      from cim_citymaster    cim,
           cym_countrymaster cym
     where cim.country_id = cym.country_id
       and cim.city_id = pc_city_id
       and cim.is_deleted = 'N'
       and cym.is_deleted = 'N';
  
    return(vc_city_country_name);
  end;

  function f_get_company_name(pc_input_profile_id varchar2) return varchar2 is
    vc_company_name varchar2(50);
  begin
    select phd.companyname
      into vc_company_name
      from phd_profileheaderdetails phd
     where phd.profileid = pc_input_profile_id;
  
    return(vc_company_name);
  end;

  function f_get_corporate_user_name(pc_input_user_id varchar2)
    return varchar2 is
    vc_user_name varchar2(50);
  begin
    select gab.firstname || ' ' || gab.lastname
      into vc_user_name
      from ak_corporate_user     aku,
           gab_globaladdressbook gab
     where aku.gabid = gab.gabid
       and aku.user_id = pc_input_user_id;
  
    return(vc_user_name);
  end;

  function f_get_derivative_price_unit_id(pc_priceunit     varchar2,
                                          pc_instrument_id varchar2)
    return varchar2 is
    vc_price_unit_id varchar2(50);
  begin
    select vpui.price_unit_id
      into vc_price_unit_id
      from v_price_units_id          vpui,
           dim_der_instrument_master dim
     where upper(vpui.price_unit) = upper(trim(pc_priceunit))
       and dim.instrument_id = vpui.instrument_id
       and vpui.instrument_id = pc_instrument_id
       and dim.is_deleted = 'N';
  
    return(vc_price_unit_id);
  end;

  function f_get_currency_id(pc_currencyname varchar2) return varchar2 is
    vc_cur_id varchar2(50);
  begin
    select cm.cur_id
      into vc_cur_id
      from cm_currency_master cm
     where upper(cm.cur_code) = upper(trim(pc_currencyname))
       and cm.is_deleted = 'N';
  
    return(vc_cur_id);
  end;

  function f_get_quantity_id(pc_qtyunitname varchar2) return varchar2 is
    vc_qty_unit_id varchar2(50);
  begin
    select qum.qty_unit_id
      into vc_qty_unit_id
      from qum_quantity_unit_master qum
     where upper(qum.qty_unit) = upper(trim(pc_qtyunitname))
       and qum.is_deleted = 'N';
  
    return(vc_qty_unit_id);
  end;

  function f_get_profile_id(pc_companyname varchar2) return varchar2 is
    vc_profile_id varchar2(50);
  begin
    select phd.profileid
      into vc_profile_id
      from phd_profileheaderdetails phd
     where upper(phd.companyname) = upper(trim(pc_companyname));
  
    return(vc_profile_id);
  end;

  function f_get_commission_type_id(pc_profile_id           varchar2,
                                    pc_commission_type_name varchar2)
    return varchar2 is
    vc_commission_type_id varchar2(15);
  begin
    select bct.commission_type_id
      into vc_commission_type_id
      from phd_profileheaderdetails    phd,
           bct_broker_commission_types bct
     where phd.profileid = pc_profile_id
       and phd.profileid = bct.profile_id
       and upper(bct.commission_type_name) = upper(pc_commission_type_name)
       and bct.is_deleted = 'N';
  
    return(vc_commission_type_id);
  end;

  function f_get_trader_id(pc_tradername varchar2, pc_corporateid varchar2)
    return varchar2 is
    vc_trader_id varchar2(50);
  begin
    select max(aku.user_id) user_id
      into vc_trader_id
      from ak_corporate_user         aku,
           gab_globaladdressbook     gab,
           uca_user_corporate_access uca
     where aku.gabid = gab.gabid
       and upper(gab.firstname || ' ' || gab.lastname) =
           upper(trim(pc_tradername))
          
       and uca.user_id = aku.user_id
       and uca.is_deleted = 'N'
       and uca.is_default = 'Y'
       and uca.corporate_id = pc_corporateid;
  
    return(vc_trader_id);
  end;

  function f_is_date
  /**************************************************************************************************
    Function Name                       : f_is_date
    Author                              : Janna
    Created Date                        : 3rd Apr 2008
    Purpose                             : Checks whether a given string is valid date or not
    Parameters                          : pc_input_date_string -> String to be validated for date value
    Returns                             : Y when given string is valid date else returns N
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_input_date_string varchar2) return varchar2 is
    vd_temp_date date;
  begin
    begin
      select to_date(pc_input_date_string, 'dd/Mon/yy')
        into vd_temp_date
        from dual;
    exception
      when others then
        vd_temp_date := null;
    end;
  
    if vd_temp_date is null then
      return 'N';
    else
      return 'Y';
    end if;
  end;

  function f_is_numeric
  /**************************************************************************************************
    Function Name                       : f_is_numeric
    Author                              : Janna
    Created Date                        : 3rd Apr 2008
    Purpose                             : Checks whether a given string is valid number or not
    Parameters                          : pc_input_number_string -> String to be validated for numeric value
    Returns                             : Y when valid number else N
    
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_input_number_string varchar2) return varchar2 is
    vd_temp_number number;
  begin
    vd_temp_number := pc_input_number_string;
    return 'Y';
  exception
    when others then
      return 'N';
  end;

  function f_get_incoterm
  /**************************************************************************************************
    Function Name                       : f_get_incoterm
    Author                              : Sachin
    Created Date                        : 16-jan-2009
    Purpose                             : returnns
    Parameters                          : pc_incoterm_id -> incoterm id
    Returns                             : return the incoterm description
    Modification History
    
    Modified Date  :
    Modified By  :
    Modify Description :
    ***************************************************************************************************/
  (pc_incoterm_id varchar2) return varchar2 is
    vd_incoterm_string varchar2(20);
  begin
    begin
      select itm.incoterm
        into vd_incoterm_string
        from itm_incoterm_master itm
       where itm.incoterm_id = pc_incoterm_id
         and itm.is_deleted = 'N';
    exception
      when others then
        vd_incoterm_string := null;
    end;
  
    return vd_incoterm_string;
  end;

  function f_get_converted_price
  --------------------------------------------------------------------------------------------------------------------------
    --        Function Name                             : sp_run_eod
    --        Author                                    : Siva
    --        Created Date                              : 18th Jan 2009
    --        Purpose                                   : Converts a price between two given price units
    --
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pn_price                                  : Price to be converted
    --        pc_from_price_unit_id                     : From Price Unit ID
    --        pc_to_price_unit_id                       : From Price Unit ID
    --        pd_trade_date                             : Trade date to get the exchange price
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pc_corporate_id       in varchar2,
   pn_price              in number,
   pc_from_price_unit_id in varchar2,
   pc_to_price_unit_id   in varchar2,
   pd_trade_date         in date) return number is
    vn_result number;
  begin
    if pc_from_price_unit_id = pc_to_price_unit_id then
      return pn_price;
    else
      select nvl(round(((((nvl((pn_price), 0)) *
                       pkg_general.f_get_converted_currency_amt(pc_corporate_id,
                                                                   pum1.cur_id,
                                                                   pum2.cur_id,
                                                                   pd_trade_date,
                                                                   1)) /
                       ((ucm.multiplication_factor * nvl(pum1.weight, 1)) /
                       nvl(pum2.weight, 1)))),
                       5),
                 0)
        into vn_result
        from pum_price_unit_master      pum1,
             pum_price_unit_master      pum2,
             ucm_unit_conversion_master ucm
       where
      /*Commented by Anu K for enabling the price conversions across products*/
      -- ppu1.product_id = ppu2.product_id
      --AND
       pum1.price_unit_id = pc_from_price_unit_id
       and pum2.price_unit_id = pc_to_price_unit_id
       and pum1.weight_unit_id = ucm.from_qty_unit_id
       and pum2.weight_unit_id = ucm.to_qty_unit_id;
    
      return(vn_result);
    end if;
  end;
  /*
     PROCEDURE acl_admin_role_access
     IS
        CURSOR role_list
        IS
           SELECT rod.role_id, rod.corporate_id
             FROM rod_role_details rod
            WHERE rod.role_id LIKE 'ROD%' AND rod.is_deleted = 'N';
  
        CURSOR acl_list
        IS
           SELECT acl.acl_id
             FROM acl_access_control_list acl
            WHERE acl.acl_check_flag = 'Y';
     BEGIN
        FOR cur_role IN role_list
        LOOP
           IF cur_role.role_id IS NOT NULL
              AND cur_role.corporate_id IS NOT NULL
           THEN
              DELETE FROM rad_role_access_details rad
                    WHERE rad.role_id = cur_role.role_id
                      AND rad.corporate_id = cur_role.corporate_id;
  
              FOR cur_acl IN acl_list
              LOOP
                 INSERT INTO rad_role_access_details
                             (corporate_id, role_id,
                              acl_id
                             )
                      VALUES (cur_role.corporate_id, cur_role.role_id,
                              cur_acl.acl_id
                             );
              END LOOP;
           END IF;
        END LOOP;
     EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
           DBMS_OUTPUT.put_line ('Unable to insert data into RAD Table');
     END;
  */
  function f_get_profit_center_name(pc_profit_center_id varchar2)
    return varchar2 is
    vc_profit_center_name varchar2(50);
  begin
    select cpc.profit_center_name
      into vc_profit_center_name
      from cpc_corporate_profit_center cpc
     where cpc.profit_center_id = pc_profit_center_id
       and cpc.is_deleted = 'N';
  
    return(vc_profit_center_name);
  end;

  function f_get_port_country(pc_port_id varchar2) return varchar2 is
    vc_port_country varchar2(50);
  begin
    select pmt.port_name || ', ' || cym.country_name
      into vc_port_country
      from pmt_portmaster    pmt,
           cym_countrymaster cym,
           cim_citymaster    cim
     where pmt.port_city_id = cim.city_id
       and cim.country_id = cym.country_id
       and pmt.port_id = pc_port_id
       and pmt.is_deleted = 'N'
       and cym.is_deleted = 'N'
       and cim.is_deleted = 'N';
  
    return(vc_port_country);
  end;
  function f_get_curr_from_price_unit_id(price_unit_id varchar2)
    return varchar2 is
    curr_code        varchar2(100) := '';
    vc_price_unit_id varchar2(100) := price_unit_id;
  begin
    select cm.cur_code
      into curr_code
      from pum_price_unit_master pum,
           cm_currency_master    cm
     where pum.cur_id = cm.cur_id
       and pum.price_unit_id = vc_price_unit_id;
  
    return curr_code;
  end;
  function f_get_converted_ref_num_to_num(ref_no varchar2) return number is
    int_ref_no number;
  begin
    select substr(ref_no,
                  instr(ref_no, '-', 1, 1) + 1,
                  (decode(instr(ref_no, '-', 1, 2),
                          0,
                          length(ref_no),
                          instr(ref_no, '-', 1, 2) - 1) -
                  instr(ref_no, '-', 1, 1)))
      into int_ref_no
      from dual;
  
    return int_ref_no;
  end;
  function f_get_price_unit_from_ppu(pc_price_unit_id varchar2)
    return varchar2 is
    vc_price_unit varchar2(50);
  begin
    select pum.price_unit_name
      into vc_price_unit
      from ppu_product_price_units ppu,
           pum_price_unit_master   pum
     where ppu.internal_price_unit_id = pc_price_unit_id
       and ppu.price_unit_id = pum.price_unit_id
       and pum.is_deleted = 'N';
  
    return(vc_price_unit);
  end;
  --Added by BabuLal
  function f_get_warehouse_shed_name(pc_input_shed_id varchar2)
    return varchar2 is
    vc_warehouse_shed_name varchar2(150);
  begin
    select phd.companyname || ', ' || sld.storage_location_name
      into vc_warehouse_shed_name
      from phd_profileheaderdetails    phd,
           bpsld_bp_storage_loc_det    bpsld,
           sld_storage_location_detail sld
     where phd.profileid = bpsld.profile_id
       and bpsld.storage_loc_id = sld.storage_loc_id
       and sld.storage_loc_id = pc_input_shed_id
       and rownum < 2;
    return(vc_warehouse_shed_name);
  end;

  function f_get_warehouse_profile_id(pc_input_shed_id varchar2)
    return varchar2 is
    vc_warehouse_name varchar2(50);
  begin
    select phd.profileid
      into vc_warehouse_name
      from phd_profileheaderdetails    phd,
           bpsld_bp_storage_loc_det    bpsld,
           sld_storage_location_detail sld
     where phd.profileid = bpsld.profile_id
       and bpsld.storage_loc_id = sld.storage_loc_id
       and sld.storage_loc_id = pc_input_shed_id
       and rownum < 2;
    return(vc_warehouse_name);
  end;

--Ends here by BabuLal
end; 
/
