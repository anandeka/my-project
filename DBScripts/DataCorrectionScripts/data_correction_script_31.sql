
update PCBPH_PC_BASE_PRICE_HEADER pcbph
set pcbph.valuation_price_percentage=100;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph
set pcbph.valuation_price_percentage='100';


update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =30
   where PCBPH.PCBPH_ID=763;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =30
   where PCBPH.PCBPH_ID=775;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =30
   where PCBPH.PCBPH_ID=814;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =92
   where PCBPH.PCBPH_ID=1006;
   
update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =92
   where PCBPH.PCBPH_ID=1007;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =92
   where PCBPH.PCBPH_ID=232;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =92
   where PCBPH.PCBPH_ID=399;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =95
   where PCBPH.PCBPH_ID=483;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =98
   where PCBPH.PCBPH_ID=1004;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =98
   where PCBPH.PCBPH_ID=1009;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =98
   where PCBPH.PCBPH_ID=161;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =98
   where PCBPH.PCBPH_ID=162;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =98
   where PCBPH.PCBPH_ID=233;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =98
   where PCBPH.PCBPH_ID=397;

update PCBPHUL_PC_BASE_PRC_HEADER_UL pcbph 
   set pcbph.valuation_price_percentage =98
   where PCBPH.PCBPH_ID=485;

UPDATE sam_stock_assay_mapping
   SET sam.is_output_assay = 'Y'
 WHERE sam.ash_id IN (
             SELECT ash.ash_id
               FROM ash_assay_header ash, sam_stock_assay_mapping sam1
              WHERE ash.assay_type = 'Output Assay'
                    AND ash.ash_id = sam1.ash_id);