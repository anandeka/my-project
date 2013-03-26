-- Data correction script for 'GMR-2875-BLD' &  'GMR-2512-BLD' becaz of WnS cancellation issue.
UPDATE gmr_goods_movement_record gmr
   SET gmr.current_qty = gmr.qty
 WHERE gmr.gmr_ref_no IN ('GMR-2875-BLD', 'GMR-2512-BLD');

UPDATE gmrul_gmr_ul gmrul
   SET gmrul.current_qty = 20.301
 WHERE gmrul.internal_action_ref_no = 'AXS-510695'
   AND gmrul.internal_gmr_ref_no = 'GMR-3000';


UPDATE gmrul_gmr_ul gmrul
   SET gmrul.current_qty = 37.42
 WHERE gmrul.internal_action_ref_no = 'AXS-510560'
   AND gmrul.internal_gmr_ref_no = 'GMR-2637';

ALTER TRIGGER trg_insert_grdl DISABLE;
ALTER TRIGGER trg_insert_spql DISABLE;


UPDATE grd_goods_record_detail grd
   SET grd.status = 'Active'
 WHERE grd.internal_grd_ref_no IN ('GRD-56657', 'GRD-55914');


UPDATE spq_stock_payable_qty spq
   SET spq.is_stock_split = 'N',
       spq.VERSION = 7
 WHERE spq.internal_grd_ref_no IN ('GRD-56656');

UPDATE spq_stock_payable_qty spq
   SET spq.is_stock_split = 'N',
       spq.VERSION = 7
 WHERE spq.internal_grd_ref_no IN ('GRD-55914');



UPDATE ii_invoicable_item ii
   SET ii.is_stock_split = 'N'
 WHERE ii.stock_id IN ('GRD-56657', 'GRD-55914');

ALTER TRIGGER trg_insert_grdl ENABLE;
ALTER TRIGGER trg_insert_spql ENABLE;


INSERT INTO grdl_goods_record_detail_log
            (internal_grd_ref_no, internal_action_ref_no, entry_type,
             internal_gmr_ref_no, product_id, is_afloat, status, qty_delta,
             qty_unit_id, gross_weight_delta, tare_weight_delta,
             internal_contract_item_ref_no, int_alloc_group_id,
             packing_size_id, container_no, seal_no, mark_no,
             warehouse_ref_no, no_of_units_delta, quality_id,
             warehouse_profile_id, shed_id, origin_id, crop_year_id,
             parent_id, is_released_shipped, release_shipped_no_units_delta,
             is_write_off, write_off_no_of_units_delta, is_deleted,
             is_moved_out, moved_out_no_of_units_delta,
             total_no_of_units_delta, total_qty_delta, moved_out_qty_delta,
             release_shipped_qty_delta, write_off_qty_delta,
             title_transfer_out_qty_delta, title_transfr_out_no_unt_delta,
             warehouse_receipt_no, warehouse_receipt_date, container_size,
             remarks, is_added_to_pool, loading_date, loading_country_id,
             loading_port_id, is_entire_item_loaded, is_weight_final,
             bl_number, bl_date, parent_internal_grd_ref_no,
             discharged_qty_delta, is_voyage_stock, allocated_qty_delta,
             internal_stock_ref_no, landed_no_of_units_delta,
             landed_net_qty_delta, landed_gross_qty_delta,
             shipped_no_of_units_delta, shipped_net_qty_delta,
             shipped_gross_qty_delta, current_qty_delta, stock_status,
             product_specs, source_type, source_int_stock_ref_no,
             source_int_purchase_ref_no, source_int_pool_ref_no,
             is_fulfilled, inventory_status, truck_rail_number,
             truck_rail_type, packing_type_id, handled_as,
             allocated_no_of_units_delta, current_no_of_units_delta,
             stock_condition, gravity_type_id, gravity_delta,
             density_mass_qty_unit_id, density_volume_qty_unit_id,
             gravity_type, customs_id, tax_id, duty_id, customer_seal_no,
             brand, no_of_containers_delta, no_of_bags_delta,
             no_of_pieces_delta, rail_car_no, sdcts_id, partnership_type,
             is_trans_ship, is_mark_for_tolling, tolling_qty,
             tolling_stock_type, element_id, expected_sales_ccy,
             profit_center_id, strategy_id, is_warrant, warrant_no, pcdi_id,
             supp_contract_item_ref_no, supplier_pcdi_id,
             payable_returnable_type, carry_over_qty,
             supp_internal_gmr_ref_no, utility_header_id
            )
     VALUES ('GRD-56657', 'AXS-510695', 'Update',
             'GMR-3000', 'PDM-352', 'N', 'Active', 0,
             'QUM-68', 0, 0,
             '655', NULL,
             NULL, NULL, NULL, 'Shredded CBS, NCR 043',
             NULL, 0, 'QAT-295',
             'PROFILEID-472', 'SLD-282', NULL, NULL,
             NULL, 'N', 0,
             'N', 0, 'N',
             'N', 0,
             0, 0, 0,
             0, 0,
             0, 0,
             NULL, NULL, NULL,
             NULL, 'N', NULL, NULL,
             NULL, NULL, 'N',
             NULL, NULL, NULL,
             NULL, NULL, NULL,
             'STK1', NULL,
             0, NULL,
             0, 0,
             0, 0, 'In Warehouse',
             'Electronic scrap', NULL, NULL,
             NULL, NULL,
             'N', 'In', 'B 47 SWE/ MH 15 SWE',
             NULL, NULL, NULL,
             NULL, 0,
             NULL, NULL, NULL,
             NULL, NULL,
             NULL, NULL, NULL, NULL, NULL,
             NULL, 0, 0,
             0, NULL, NULL, 'Normal',
             'N', 'N', NULL,
             'None Tolling', NULL, NULL,
             'CPC-208', 'CSS-19', 'N', NULL, '503',
             NULL, NULL,
             NULL, NULL,
             NULL, NULL
            );



INSERT INTO grdl_goods_record_detail_log
            (internal_grd_ref_no, internal_action_ref_no, entry_type,
             internal_gmr_ref_no, product_id, is_afloat, status, qty_delta,
             qty_unit_id, gross_weight_delta, tare_weight_delta,
             internal_contract_item_ref_no, int_alloc_group_id,
             packing_size_id, container_no, seal_no, mark_no,
             warehouse_ref_no, no_of_units_delta, quality_id,
             warehouse_profile_id, shed_id, origin_id, crop_year_id,
             parent_id, is_released_shipped, release_shipped_no_units_delta,
             is_write_off, write_off_no_of_units_delta, is_deleted,
             is_moved_out, moved_out_no_of_units_delta,
             total_no_of_units_delta, total_qty_delta, moved_out_qty_delta,
             release_shipped_qty_delta, write_off_qty_delta,
             title_transfer_out_qty_delta, title_transfr_out_no_unt_delta,
             warehouse_receipt_no, warehouse_receipt_date, container_size,
             remarks, is_added_to_pool, loading_date, loading_country_id,
             loading_port_id, is_entire_item_loaded, is_weight_final,
             bl_number, bl_date, parent_internal_grd_ref_no,
             discharged_qty_delta, is_voyage_stock, allocated_qty_delta,
             internal_stock_ref_no, landed_no_of_units_delta,
             landed_net_qty_delta, landed_gross_qty_delta,
             shipped_no_of_units_delta, shipped_net_qty_delta,
             shipped_gross_qty_delta, current_qty_delta, stock_status,
             product_specs, source_type, source_int_stock_ref_no,
             source_int_purchase_ref_no, source_int_pool_ref_no,
             is_fulfilled, inventory_status, truck_rail_number,
             truck_rail_type, packing_type_id, handled_as,
             allocated_no_of_units_delta, current_no_of_units_delta,
             stock_condition, gravity_type_id, gravity_delta,
             density_mass_qty_unit_id, density_volume_qty_unit_id,
             gravity_type, customs_id, tax_id, duty_id, customer_seal_no,
             brand, no_of_containers_delta, no_of_bags_delta,
             no_of_pieces_delta, rail_car_no, sdcts_id, partnership_type,
             is_trans_ship, is_mark_for_tolling, tolling_qty,
             tolling_stock_type, element_id, expected_sales_ccy,
             profit_center_id, strategy_id, is_warrant, warrant_no, pcdi_id,
             supp_contract_item_ref_no, supplier_pcdi_id,
             payable_returnable_type, carry_over_qty,
             supp_internal_gmr_ref_no, utility_header_id
            )
     VALUES ('GRD-55914', 'AXS-510560', 'Update',
             'GMR-2637', 'PDM-352', 'N', 'Active', 0,
             'QUM-68', 0, 0,
             '501', NULL,
             NULL, 'MSCU 2489962', NULL, 'Shredded CBS',
             NULL, 0, 'QAT-295',
             'PROFILEID-472', 'SLD-282', NULL, NULL,
             NULL, 'N', 0,
             'N', 0, 'N',
             'N', 0,
             0, 0, 0,
             0, 0,
             0, 0,
             NULL, NULL, '20 Ft',
             NULL, 'N', NULL, NULL,
             NULL, NULL, 'N',
             NULL, NULL, NULL,
             NULL, NULL, NULL,
             'STK1', NULL,
             0, NULL,
             0, 0,
             0, 0, 'In Warehouse',
             'Electronic scrap', NULL, NULL,
             NULL, NULL,
             'N', 'In', 'MSCU 2489962',
             NULL, NULL, NULL,
             NULL, 0,
             NULL, NULL, NULL,
             NULL, NULL,
             NULL, NULL, NULL, NULL, NULL,
             NULL, 0, 0,
             0, NULL, NULL, 'Normal',
             'N', 'N', NULL,
             'None Tolling', NULL, NULL,
             'CPC-208', 'CSS-19', 'N', NULL, '388',
             NULL, NULL,
             NULL, NULL,
             NULL, NULL
            );



INSERT INTO spql_stock_payable_qty_log
            (spq_id, internal_action_ref_no, entry_type, internal_gmr_ref_no,
             action_no, stock_type, internal_grd_ref_no,
             internal_dgrd_ref_no, element_id, payable_qty_delta,
             qty_unit_id, VERSION, is_active, qty_type, activity_action_id,
             is_stock_split, supplier_id, smelter_id, free_metal_stock_id,
             free_metal_qty, assay_content, pledge_stock_id, gepd_id,
             assay_header_id, is_final_assay, corporate_id,
             is_pure_free_metal_elem, ext_assay_header_id, ext_assay_content,
             ext_payable_qty, weg_avg_pricing_assay_id,
             weg_avg_invoice_assay_id, cot_int_action_ref_no
            )
     VALUES ('SPQ-23097', 'AXS-510695', 'Update', 'GMR-3000',
             2, 'P', 'GRD-56656',
             NULL, 'AML-321', 0,
             'QUM-71', 7, 'Y', 'Payable', 'truckDetail',
             'N', 'PROFILEID-386', NULL, NULL,
             NULL, 0, NULL, NULL,
             '108185', NULL, 'BLD',
             'N', '108188', 0,
             0, '108186',
             '108189', NULL
            );
INSERT INTO spql_stock_payable_qty_log
            (spq_id, internal_action_ref_no, entry_type, internal_gmr_ref_no,
             action_no, stock_type, internal_grd_ref_no,
             internal_dgrd_ref_no, element_id, payable_qty_delta,
             qty_unit_id, VERSION, is_active, qty_type, activity_action_id,
             is_stock_split, supplier_id, smelter_id, free_metal_stock_id,
             free_metal_qty, assay_content, pledge_stock_id, gepd_id,
             assay_header_id, is_final_assay, corporate_id,
             is_pure_free_metal_elem, ext_assay_header_id, ext_assay_content,
             ext_payable_qty, weg_avg_pricing_assay_id,
             weg_avg_invoice_assay_id, cot_int_action_ref_no
            )
     VALUES ('SPQ-23098', 'AXS-510695', 'Update', 'GMR-3000',
             2, 'P', 'GRD-56656',
             NULL, 'AML-337', 0,
             'QUM-68', 7, 'Y', 'Payable', 'truckDetail',
             'N', 'PROFILEID-386', NULL, NULL,
             NULL, 0, NULL, NULL,
             '108185', NULL, 'BLD',
             'N', '108188', 0,
             0, '108186',
             '108189', NULL
            );
INSERT INTO spql_stock_payable_qty_log
            (spq_id, internal_action_ref_no, entry_type, internal_gmr_ref_no,
             action_no, stock_type, internal_grd_ref_no,
             internal_dgrd_ref_no, element_id, payable_qty_delta,
             qty_unit_id, VERSION, is_active, qty_type, activity_action_id,
             is_stock_split, supplier_id, smelter_id, free_metal_stock_id,
             free_metal_qty, assay_content, pledge_stock_id, gepd_id,
             assay_header_id, is_final_assay, corporate_id,
             is_pure_free_metal_elem, ext_assay_header_id, ext_assay_content,
             ext_payable_qty, weg_avg_pricing_assay_id,
             weg_avg_invoice_assay_id, cot_int_action_ref_no
            )
     VALUES ('SPQ-23099', 'AXS-510695', 'Update', 'GMR-3000',
             2, 'P', 'GRD-56656',
             NULL, 'AML-325', 0,
             'QUM-71', 7, 'Y', 'Payable', 'truckDetail',
             'N', 'PROFILEID-386', NULL, NULL,
             NULL, 0, NULL, NULL,
             '108185', NULL, 'BLD',
             'N', '108188', 0,
             0, '108186',
             '108189', NULL
            );
INSERT INTO spql_stock_payable_qty_log
            (spq_id, internal_action_ref_no, entry_type, internal_gmr_ref_no,
             action_no, stock_type, internal_grd_ref_no,
             internal_dgrd_ref_no, element_id, payable_qty_delta,
             qty_unit_id, VERSION, is_active, qty_type, activity_action_id,
             is_stock_split, supplier_id, smelter_id, free_metal_stock_id,
             free_metal_qty, assay_content, pledge_stock_id, gepd_id,
             assay_header_id, is_final_assay, corporate_id,
             is_pure_free_metal_elem, ext_assay_header_id, ext_assay_content,
             ext_payable_qty, weg_avg_pricing_assay_id,
             weg_avg_invoice_assay_id, cot_int_action_ref_no
            )
     VALUES ('SPQ-23100', 'AXS-510695', 'Update', 'GMR-3000',
             2, 'P', 'GRD-56656',
             NULL, 'AML-365', 0,
             'QUM-71', 7, 'Y', 'Payable', 'truckDetail',
             'N', 'PROFILEID-386', NULL, NULL,
             NULL, 0, NULL, NULL,
             '108185', NULL, 'BLD',
             'N', '108188', 0,
             0, '108186',
             '108189', NULL
            );



-- GMR  2512


INSERT INTO spql_stock_payable_qty_log
            (spq_id, internal_action_ref_no, entry_type, internal_gmr_ref_no,
             action_no, stock_type, internal_grd_ref_no,
             internal_dgrd_ref_no, element_id, payable_qty_delta,
             qty_unit_id, VERSION, is_active, qty_type, activity_action_id,
             is_stock_split, supplier_id, smelter_id, free_metal_stock_id,
             free_metal_qty, assay_content, pledge_stock_id, gepd_id,
             assay_header_id, is_final_assay, corporate_id,
             is_pure_free_metal_elem, ext_assay_header_id, ext_assay_content,
             ext_payable_qty, weg_avg_pricing_assay_id,
             weg_avg_invoice_assay_id, cot_int_action_ref_no
            )
     VALUES ('SPQ-20730', 'AXS-510560', 'Update', 'GMR-2637',
             2, 'P', 'GRD-55914',
             NULL, 'AML-321', 0,
             'QUM-71', 7, 'Y', 'Payable', 'railDetail',
             'N', 'PROFILEID-436', NULL, NULL,
             NULL, 0, NULL, NULL,
             '103343', NULL, 'BLD',
             'N', '103346', 0,
             0, '103344',
             '103347', NULL
            );
INSERT INTO spql_stock_payable_qty_log
            (spq_id, internal_action_ref_no, entry_type, internal_gmr_ref_no,
             action_no, stock_type, internal_grd_ref_no,
             internal_dgrd_ref_no, element_id, payable_qty_delta,
             qty_unit_id, VERSION, is_active, qty_type, activity_action_id,
             is_stock_split, supplier_id, smelter_id, free_metal_stock_id,
             free_metal_qty, assay_content, pledge_stock_id, gepd_id,
             assay_header_id, is_final_assay, corporate_id,
             is_pure_free_metal_elem, ext_assay_header_id, ext_assay_content,
             ext_payable_qty, weg_avg_pricing_assay_id,
             weg_avg_invoice_assay_id, cot_int_action_ref_no
            )
     VALUES ('SPQ-20731', 'AXS-510560', 'Update', 'GMR-2637',
             2, 'P', 'GRD-55914',
             NULL, 'AML-337', 0,
             'QUM-68', 7, 'Y', 'Payable', 'railDetail',
             'N', 'PROFILEID-436', NULL, NULL,
             NULL, 0, NULL, NULL,
             '103343', NULL, 'BLD',
             'N', '103346', 0,
             0, '103344',
             '103347', NULL
            );
INSERT INTO spql_stock_payable_qty_log
            (spq_id, internal_action_ref_no, entry_type, internal_gmr_ref_no,
             action_no, stock_type, internal_grd_ref_no,
             internal_dgrd_ref_no, element_id, payable_qty_delta,
             qty_unit_id, VERSION, is_active, qty_type, activity_action_id,
             is_stock_split, supplier_id, smelter_id, free_metal_stock_id,
             free_metal_qty, assay_content, pledge_stock_id, gepd_id,
             assay_header_id, is_final_assay, corporate_id,
             is_pure_free_metal_elem, ext_assay_header_id, ext_assay_content,
             ext_payable_qty, weg_avg_pricing_assay_id,
             weg_avg_invoice_assay_id, cot_int_action_ref_no
            )
     VALUES ('SPQ-20732', 'AXS-510560', 'Update', 'GMR-2637',
             2, 'P', 'GRD-55914',
             NULL, 'AML-325', 0,
             'QUM-71', 7, 'Y', 'Payable', 'railDetail',
             'N', 'PROFILEID-436', NULL, NULL,
             NULL, 0, NULL, NULL,
             '103343', NULL, 'BLD',
             'N', '103346', 0,
             0, '103344',
             '103347', NULL
            );
INSERT INTO spql_stock_payable_qty_log
            (spq_id, internal_action_ref_no, entry_type, internal_gmr_ref_no,
             action_no, stock_type, internal_grd_ref_no,
             internal_dgrd_ref_no, element_id, payable_qty_delta,
             qty_unit_id, VERSION, is_active, qty_type, activity_action_id,
             is_stock_split, supplier_id, smelter_id, free_metal_stock_id,
             free_metal_qty, assay_content, pledge_stock_id, gepd_id,
             assay_header_id, is_final_assay, corporate_id,
             is_pure_free_metal_elem, ext_assay_header_id, ext_assay_content,
             ext_payable_qty, weg_avg_pricing_assay_id,
             weg_avg_invoice_assay_id, cot_int_action_ref_no
            )
     VALUES ('SPQ-20733', 'AXS-510560', 'Update', 'GMR-2637',
             2, 'P', 'GRD-55914',
             NULL, 'AML-365', 0,
             'QUM-71', 7, 'Y', 'Payable', 'railDetail',
             'N', 'PROFILEID-436', NULL, NULL,
             NULL, 0, NULL, NULL,
             '103343', NULL, 'BLD',
             'N', '103346', 0,
             0, '103344',
             '103347', NULL
            );