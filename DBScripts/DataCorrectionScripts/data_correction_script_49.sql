begin
for rc in (
    select 
    pcbph.pcbph_id, pcbph.valuation_price_percentage
    from pcbph_pc_base_price_header pcbph,
    pcbpd_pc_base_price_detail pcbpd
    where pcbph.pcbph_id = pcbpd.pcbph_id
    and pcbpd.valuation_price_percentage is null
)
loop
    update pcbpd_pc_base_price_detail
    set valuation_price_percentage = rc.valuation_price_percentage
    where pcbph_id = rc.pcbph_id;
    commit;
    update pcbpdul_pc_base_price_dtl_ul
    set valuation_price_percentage = rc.valuation_price_percentage
    where pcbph_id = rc.pcbph_id;
    commit;
end loop;
end;