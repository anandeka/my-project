alter table PCBPD_PC_BASE_PRICE_DETAIL add VALUATION_PRICE_PERCENTAGE number(25,10);
alter table PCBPDUL_PC_BASE_PRICE_DTL_UL add VALUATION_PRICE_PERCENTAGE number(25,10);

begin
  for rc in (select pcbpdul_id,
                    valuation_price_percentage
               from pcbpdul_pc_base_price_dtl_ul@eka_appdb ul)
  loop
    update pcbpdul_pc_base_price_dtl_ul ul
       set ul.valuation_price_percentage = rc.valuation_price_percentage
     where ul.pcbpdul_id = rc.pcbpdul_id;
    commit;
  end loop;
end;
/

