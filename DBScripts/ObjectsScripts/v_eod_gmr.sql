create or replace view v_eod_gmr as
select internal_gmr_ref_no,
       gmr_ref_no,
       gmr_first_int_action_ref_no,
       internal_contract_ref_no,
       gmr_latest_action_action_id,
       corporate_id,
       created_by,
       created_date,
       contract_type,
       status_id,
       qty,
       current_qty,
       qty_unit_id,
       no_of_units,
       current_no_of_units,
       shipped_qty,
       landed_qty,
       weighed_qty,
       plan_ship_qty,
       released_qty,
       bl_no,
       trucking_receipt_no,
       rail_receipt_no,
       bl_date,
       trucking_receipt_date,
       rail_receipt_date,
       warehouse_receipt_no,
       origin_city_id,
       origin_country_id,
       destination_city_id,
       destination_country_id,
       loading_country_id,
       loading_port_id,
       discharge_country_id,
       discharge_port_id,
       trans_port_id,
       trans_country_id,
       warehouse_profile_id,
       shed_id,
       shipping_line_profile_id,
       controller_profile_id,
       vessel_name,
       eff_date,
       inventory_no,
       inventory_status,
       inventory_in_date,
       inventory_out_date,
       is_final_weight,
       final_weight,
       sales_int_alloc_group_id,
       is_internal_movement,
       is_deleted,
       is_voyage_gmr,
       loaded_qty,
       discharged_qty,
       voyage_alloc_qty,
       fulfilled_qty,
       voyage_status,
       tt_in_qty,
       tt_out_qty,
       tt_under_cma_qty,
       tt_none_qty,
       moved_out_qty,
       is_settlement_gmr,
       write_off_qty,
       internal_action_ref_no,
       gravity_type_id,
       gravity,
       density_mass_qty_unit_id,
       density_volume_qty_unit_id,
       gravity_type,
       loading_state_id,
       loading_city_id,
       trans_state_id,
       trans_city_id,
       discharge_state_id,
       discharge_city_id,
       place_of_receipt_country_id,
       place_of_receipt_state_id,
       place_of_receipt_city_id,
       place_of_delivery_country_id,
       place_of_delivery_state_id,
       place_of_delivery_city_id,
       total_gross_weight,
       total_tare_weight,
       dbd_id,
       process_id,
       tolling_qty,
       tolling_gmr_type,
       pool_id,
       is_warrant,
       is_pass_through,
       pledge_input_gmr,
       is_apply_freight_allowance,
       is_final_invoiced,
       is_provisional_invoiced,
       product_id,
       latest_internal_invoice_ref_no,
       carry_over_qty,
       mode_of_transport,
       arrival_date,
       wns_status,
       is_apply_container_charge,
       loading_date,
       no_of_containers,
       0 no_of_bags,
       0 no_of_sublots,
       gmr_type,
       contract_ref_no,
       cp_id,
       cp_name,
       stock_current_qty,
       dry_qty,
       wet_qty,
       invoice_ref_no,
       warehouse_name,
       is_new_mtd,
       is_new_ytd,
       is_assay_updated_mtd,
       is_assay_updated_ytd,
       assay_final_status,
       quality_name,
       invoice_cur_id,
       invoice_cur_code,
       invoice_cur_decimals,
       gmr_status,
       shed_name,
       loading_country_name,
       loading_city_name,
       loading_state_name,
       loading_region_id,
       loading_region_name,
       discharge_country_name,
       discharge_city_name,
       discharge_state_name,
       discharge_region_id,
       discharge_region_name,
       loading_country_cur_id,
       loading_country_cur_code,
       discharge_country_cur_id,
       discharge_country_cur_code,
       tolling_service_type,
       gmr_arrival_status,
       feeding_point_id,
       feeding_point_name,
       0 no_of_stocks_wns_done,
       is_new_mtd_ar,
       is_new_ytd_ar,
       is_assay_updated_mtd_ar,
       is_assay_updated_ytd_ar
  from gmr_goods_movement_record@eka_eoddb
/