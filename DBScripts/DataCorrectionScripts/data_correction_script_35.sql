/* Formatted on 2013/01/07 16:53 (Formatter Plus v4.8.8) */
UPDATE pcbph_pc_base_price_header pcbph
   SET pcbph.price_description = (SELECT stragg (pcbpd.description)
                                    FROM pcbpd_pc_base_price_detail pcbpd
                                   WHERE pcbpd.pcbph_id = pcbph.pcbph_id);


UPDATE pcbphul_pc_base_prc_header_ul pcbph
   SET pcbph.price_description = (SELECT stragg (pcbpd.description)
                                    FROM pcbpd_pc_base_price_detail pcbpd
                                   WHERE pcbpd.pcbph_id = pcbph.pcbph_id);