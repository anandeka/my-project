---------------------------------------------------------------------------
--- INSERT INTO CHILD TABLE (SADC_CHILD_DGRD_D)
--- ADDED SOME EXTRA COLUMN
----------------------------------------------------------------------------

declare
fetchqry clob := 'INSERT INTO sadc_child_dgrd_d
            (internal_gmr_ref_no, internal_dgrd_ref_no,
             internal_contract_item_ref_no, internal_doc_ref_no, stock_ref_no,
             net_weight, tare_weight, gross_weight, p_shipped_net_weight,
             p_shipped_gross_weight, p_shipped_tare_weight, landed_net_qty,
             landed_gross_qty, current_qty, net_weight_unit,
             net_weight_unit_id, container_no, container_size, no_of_bags,
             no_of_containers, no_of_pieces, brand, mark_no, seal_no,
             customer_seal_no, stock_status, remarks,duty_status,custom_status,tax_status)
 SELECT gmr.internal_gmr_ref_no internal_gmr_ref_no,
          agrd.internal_grd_ref_no internal_grd_ref_no,
          agrd.internal_contract_item_ref_no internal_contract_item_ref_no,
          ?,agrd.internal_stock_ref_no internal_stock_ref_no,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.net_weight
                                                    )
              ),
              4
             ) net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.tare_weight
                                                    )
              ),
              4
             ) tare_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.gross_weight
                                                    )
              ),
              4
             ) gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.p_shipped_net_weight
                                                    )
              ),
              4
             ) p_shipped_net_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity
                                                  (agrd.product_id,
                                                   agrd.net_weight_unit_id,
                                                   qum_bl.qty_unit_id,
                                                   agrd.p_shipped_gross_weight
                                                  )
              ),
              4
             ) p_shipped_gross_weight,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity
                                                   (agrd.product_id,
                                                    agrd.net_weight_unit_id,
                                                    qum_bl.qty_unit_id,
                                                    agrd.p_shipped_tare_weight
                                                   )
              ),
              4
             ) p_shipped_tare_weight,
          '''' landed_net_qty, '''' landed_gross_qty,
          f_format_to_char
             ((pkg_general.f_get_converted_quantity (agrd.product_id,
                                                     agrd.net_weight_unit_id,
                                                     qum_bl.qty_unit_id,
                                                     agrd.current_qty
                                                    )
              ),
              4
             ) current_qty,
          qum_bl.qty_unit net_weight_unit,
          qum_bl.qty_unit_id net_weight_unit_id,
          agrd.container_no container_no, agrd.container_size container_size,
          agrd.no_of_bags no_of_bags, agrd.no_of_containers no_of_containers,
          agrd.no_of_pieces no_of_pieces, agrd.brand brand,
          agrd.mark_no mark_no, agrd.seal_no seal_no,
          agrd.customer_seal_no customer_seal_no,
          agrd.stock_status stock_status, agrd.remarks remarks,
          slv_duty.value_text dutystatus,
          slv_cust.value_text customstatus,
          slv_tax.value_text taxstatus
     FROM adgrd_action_dgrd agrd,
          gmr_goods_movement_record gmr,
          agmr_action_gmr agmr,
          qum_quantity_unit_master qum_bl,
          slv_static_list_value slv_duty,
          slv_static_list_value slv_cust,
          slv_static_list_value slv_tax
    WHERE gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agrd.customs_id = slv_duty.value_id(+)
      AND agrd.duty_id = slv_cust.value_id(+)
      AND agrd.tax_id = slv_tax.value_id(+)
      AND agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
      AND agmr.action_no = agrd.action_no
      AND qum_bl.qty_unit_id = agrd.net_weight_unit_id
      AND agmr.gmr_latest_action_action_id IN
                 (''releaseOrder'')
      AND agmr.is_deleted = ''N''
      AND agrd.status = ''Active''
      AND gmr.internal_gmr_ref_no = ?  ' ;

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry where DGM_ID = 'DGM_RO_CHILD_SAD_D';
  
end;