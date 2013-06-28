alter table PCBPD_PC_BASE_PRICE_DETAIL add VALUATION_PRICE_PERCENTAGE number(25,10);
alter table PCBPDUL_PC_BASE_PRICE_DTL_UL add VALUATION_PRICE_PERCENTAGE number(25,10);


begin
  for rc in (select pcbph.dbd_id, 
                    pcbph.pcbph_id,
                    pcbph.valuation_price_percentage
               from pcbph_pc_base_price_header pcbph,
                    pcbpd_pc_base_price_detail pcbpd
              where pcbph.pcbph_id = pcbpd.pcbph_id
                and pcbph.process_id=pcbpd.process_id
                and pcbpd.valuation_price_percentage is null)
  loop
    update pcbpd_pc_base_price_detail
       set valuation_price_percentage = rc.valuation_price_percentage
     where pcbph_id = rc.pcbph_id
      and  dbd_id=rc.dbd_id;
    commit;
    update pcbpdul_pc_base_price_dtl_ul ul
       set ul.valuation_price_percentage = rc.valuation_price_percentage
     where ul.pcbph_id = rc.pcbph_id
      and  ul.dbd_id=rc.dbd_id;
    commit;
  end loop;
end;
/
