create or replace trigger "TRG_INSERT_GRDL"
/**************************************************************************************************
           Trigger Name                       : trg_insert_grdl
           Author                             : Mohit
           Created Date                       : 20th May 2011
           Purpose                            : To Insert into GRDL Table

           Modification History

           Modified Date  :
           Modified By  :
           Modify Description :

   ***************************************************************************************************/
  after insert or update on grd_goods_record_detail
  for each row
begin
  --
  -- If updating then put the delta for Quantity columns as Old - New when GRD is Active
  -- If GRD is inactive then negate all the quantity columns
  -- If inserting put the new value as is as Delta
  --
  if updating then
    if :new.is_deleted = 'N' then
      --Qty Unit is Not Updated
      if :new.qty_unit_id = :old.qty_unit_id then
        insert into grdl_goods_record_detail_log
          (internal_grd_ref_no,
           internal_gmr_ref_no,
           product_id,
           is_afloat,
           status,
           qty_delta,
           qty_unit_id,
           gross_weight_delta,
           tare_weight_delta,
           internal_contract_item_ref_no,
           int_alloc_group_id,
           packing_size_id,
           container_no,
           seal_no,
           mark_no,
           warehouse_ref_no,
           no_of_units_delta,
           quality_id,
           warehouse_profile_id,
           shed_id,
           origin_id,
           crop_year_id,
           parent_id,
           is_released_shipped,
           release_shipped_no_units_delta,
           is_write_off,
           write_off_no_of_units_delta,
           is_moved_out,
           moved_out_no_of_units_delta,
           total_no_of_units_delta,
           total_qty_delta,
           moved_out_qty_delta,
           release_shipped_qty_delta,
           write_off_qty_delta,
           title_transfer_out_qty_delta,
           title_transfr_out_no_unt_delta,
           warehouse_receipt_no,
           warehouse_receipt_date,
           container_size,
           remarks,
           is_added_to_pool,
           loading_date,
           loading_country_id,
           loading_port_id,
           is_entire_item_loaded,
           is_weight_final,
           bl_number,
           bl_date,
           parent_internal_grd_ref_no,
           discharged_qty_delta,
           is_voyage_stock,
           allocated_qty_delta,
           internal_stock_ref_no,
           landed_no_of_units_delta,
           landed_net_qty_delta,
           landed_gross_qty_delta,
           shipped_no_of_units_delta,
           shipped_net_qty_delta,
           shipped_gross_qty_delta,
           current_qty_delta,
           stock_status,
           product_specs,
           source_type,
           source_int_stock_ref_no,
           source_int_purchase_ref_no,
           source_int_pool_ref_no,
           is_fulfilled,
           inventory_status,
           truck_rail_number,
           truck_rail_type,
           packing_type_id,
           handled_as,
           allocated_no_of_units_delta,
           current_no_of_units_delta,
           stock_condition,
           gravity_type_id,
           gravity_delta,
           density_mass_qty_unit_id,
           density_volume_qty_unit_id,
           gravity_type,
           customs_id,
           tax_id,
           duty_id,
           customer_seal_no,
           brand,
           no_of_containers_delta,
           no_of_bags_delta,
           no_of_pieces_delta,
           rail_car_no,
           sdcts_id,
           partnership_type,
           is_trans_ship,
           is_mark_for_tolling,
           tolling_qty,
           tolling_stock_type,
           element_id,
           expected_sales_ccy,
           profit_center_id,
           strategy_id,
           is_warrant,
           warrant_no,
           pcdi_id,
           supp_contract_item_ref_no,
           supplier_pcdi_id,
           supp_internal_gmr_ref_no,
           utility_header_id,
           payable_returnable_type,
           carry_over_qty,
           internal_action_ref_no,
           entry_type,
           is_deleted,
           is_clone_stock_spilt,
		   cot_int_action_ref_no)
        values
          (:new.internal_grd_ref_no,
           :new.internal_gmr_ref_no,
           :new.product_id,
           :new.is_afloat,
           :new.status,
           :new.qty - :old.qty,
           :new.qty_unit_id,
           :new.gross_weight - :old.gross_weight,
           :new.tare_weight - :old.tare_weight,
           :new.internal_contract_item_ref_no,
           :new.int_alloc_group_id,
           :new.packing_size_id,
           :new.container_no,
           :new.seal_no,
           :new.mark_no,
           :new.warehouse_ref_no,
           :new.no_of_units - :old.no_of_units,
           :new.quality_id,
           :new.warehouse_profile_id,
           :new.shed_id,
           :new.origin_id,
           :new.crop_year_id,
           :new.parent_id,
           :new.is_released_shipped,
           :new.release_shipped_no_of_units -
           :old.release_shipped_no_of_units,
           :new.is_write_off,
           :new.write_off_no_of_units - :old.write_off_no_of_units,
           :new.is_moved_out,
           :new.moved_out_no_of_units - :old.moved_out_no_of_units,
           :new.total_no_of_units - :old.total_no_of_units,
           :new.total_qty - :old.total_qty,
           :new.moved_out_qty - :old.moved_out_qty,
           :new.release_shipped_qty - :old.release_shipped_qty,
           :new.write_off_qty - :old.write_off_qty,
           :new.title_transfer_out_qty - :old.title_transfer_out_qty,
           :new.title_transfer_out_no_of_units -
           :old.title_transfer_out_no_of_units,
           :new.warehouse_receipt_no,
           :new.warehouse_receipt_date,
           :new.container_size,
           :new.remarks,
           :new.is_added_to_pool,
           :new.loading_date,
           :new.loading_country_id,
           :new.loading_port_id,
           :new.is_entire_item_loaded,
           :new.is_weight_final,
           :new.bl_number,
           :new.bl_date,
           :new.parent_internal_grd_ref_no,
           :new.discharged_qty - :old.discharged_qty,
           :new.is_voyage_stock,
           :new.allocated_qty - :old.allocated_qty,
           :new.internal_stock_ref_no,
           :new.landed_no_of_units - :old.landed_no_of_units,
           :new.landed_net_qty - :old.landed_net_qty,
           :new.landed_gross_qty - :old.landed_gross_qty,
           :new.shipped_no_of_units - :old.shipped_no_of_units,
           :new.shipped_net_qty - :old.shipped_net_qty,
           :new.shipped_gross_qty - :old.shipped_gross_qty,
           :new.current_qty - :old.current_qty,
           :new.stock_status,
           :new.product_specs,
           :new.source_type,
           :new.source_int_stock_ref_no,
           :new.source_int_purchase_ref_no,
           :new.source_int_pool_ref_no,
           :new.is_fulfilled,
           :new.inventory_status,
           :new.truck_rail_number,
           :new.truck_rail_type,
           :new.packing_type_id,
           :new.handled_as,
           :new.allocated_no_of_units - :old.allocated_no_of_units,
           :new.current_no_of_units - :old.current_no_of_units,
           :new.stock_condition,
           :new.gravity_type_id,
           :new.gravity - :old.gravity,
           :new.density_mass_qty_unit_id,
           :new.density_volume_qty_unit_id,
           :new.gravity_type,
           :new.customs_id,
           :new.tax_id,
           :new.duty_id,
           :new.customer_seal_no,
           :new.brand,
           :new.no_of_containers - :old.no_of_containers,
           nvl(:new.no_of_bags, 0) - nvl(:old.no_of_bags, 0),
           nvl(:new.no_of_pieces, 0) - nvl(:old.no_of_pieces, 0),
           :new.rail_car_no,
           :new.sdcts_id,
           :new.partnership_type,
           :new.is_trans_ship,
           :new.is_mark_for_tolling,
           :new.tolling_qty - :old.tolling_qty,
           :new.tolling_stock_type,
           :new.element_id,
           :new.expected_sales_ccy,
           :new.profit_center_id,
           :new.strategy_id,
           :new.is_warrant,
           :new.warrant_no,
           :new.pcdi_id,
           :new.supp_contract_item_ref_no,
           :new.supplier_pcdi_id,
           :new.supp_internal_gmr_ref_no,
           :new.utility_header_id,
           :new.payable_returnable_type,
           :new.carry_over_qty - :old.carry_over_qty,
           :new.internal_action_ref_no,
           'Update',
           'N',
           :new.is_clone_stock_spilt,
		   :new.cot_int_action_ref_no);
      else
        --Qty Unit is Updated
        insert into grdl_goods_record_detail_log
          (internal_grd_ref_no,
           internal_gmr_ref_no,
           product_id,
           is_afloat,
           status,
           qty_delta,
           qty_unit_id,
           gross_weight_delta,
           tare_weight_delta,
           internal_contract_item_ref_no,
           int_alloc_group_id,
           packing_size_id,
           container_no,
           seal_no,
           mark_no,
           warehouse_ref_no,
           no_of_units_delta,
           quality_id,
           warehouse_profile_id,
           shed_id,
           origin_id,
           crop_year_id,
           parent_id,
           is_released_shipped,
           release_shipped_no_units_delta,
           is_write_off,
           write_off_no_of_units_delta,
           is_moved_out,
           moved_out_no_of_units_delta,
           total_no_of_units_delta,
           total_qty_delta,
           moved_out_qty_delta,
           release_shipped_qty_delta,
           write_off_qty_delta,
           title_transfer_out_qty_delta,
           title_transfr_out_no_unt_delta,
           warehouse_receipt_no,
           warehouse_receipt_date,
           container_size,
           remarks,
           is_added_to_pool,
           loading_date,
           loading_country_id,
           loading_port_id,
           is_entire_item_loaded,
           is_weight_final,
           bl_number,
           bl_date,
           parent_internal_grd_ref_no,
           discharged_qty_delta,
           is_voyage_stock,
           allocated_qty_delta,
           internal_stock_ref_no,
           landed_no_of_units_delta,
           landed_net_qty_delta,
           landed_gross_qty_delta,
           shipped_no_of_units_delta,
           shipped_net_qty_delta,
           shipped_gross_qty_delta,
           current_qty_delta,
           stock_status,
           product_specs,
           source_type,
           source_int_stock_ref_no,
           source_int_purchase_ref_no,
           source_int_pool_ref_no,
           is_fulfilled,
           inventory_status,
           truck_rail_number,
           truck_rail_type,
           packing_type_id,
           handled_as,
           allocated_no_of_units_delta,
           current_no_of_units_delta,
           stock_condition,
           gravity_type_id,
           gravity_delta,
           density_mass_qty_unit_id,
           density_volume_qty_unit_id,
           gravity_type,
           customs_id,
           tax_id,
           duty_id,
           customer_seal_no,
           brand,
           no_of_containers_delta,
           no_of_bags_delta,
           no_of_pieces_delta,
           rail_car_no,
           sdcts_id,
           partnership_type,
           is_trans_ship,
           is_mark_for_tolling,
           tolling_qty,
           tolling_stock_type,
           element_id,
           expected_sales_ccy,
           profit_center_id,
           strategy_id,
           is_warrant,
           warrant_no,
           pcdi_id,
           supp_contract_item_ref_no,
           supplier_pcdi_id,
           supp_internal_gmr_ref_no,
           utility_header_id,
           payable_returnable_type,
           carry_over_qty,
           internal_action_ref_no,
           entry_type,
           is_deleted,
           is_clone_stock_spilt,
		   cot_int_action_ref_no)
        values
          (:new.internal_grd_ref_no,
           :new.internal_gmr_ref_no,
           :new.product_id,
           :new.is_afloat,
           :new.status,
           :new.qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.qty),
           :new.qty_unit_id,
           :new.gross_weight -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.gross_weight),
           :new.tare_weight -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.tare_weight),
           :new.internal_contract_item_ref_no,
           :new.int_alloc_group_id,
           :new.packing_size_id,
           :new.container_no,
           :new.seal_no,
           :new.mark_no,
           :new.warehouse_ref_no,
           :new.no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.no_of_units),
           :new.quality_id,
           :new.warehouse_profile_id,
           :new.shed_id,
           :new.origin_id,
           :new.crop_year_id,
           :new.parent_id,
           :new.is_released_shipped,
           :new.release_shipped_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.release_shipped_no_of_units),
           :new.is_write_off,
           :new.write_off_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.write_off_no_of_units),
           :new.is_moved_out,
           :new.moved_out_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.moved_out_no_of_units),
           :new.total_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.total_no_of_units),
           :new.total_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.total_qty),
           :new.moved_out_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.moved_out_qty),
           :new.release_shipped_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.release_shipped_qty),
           :new.write_off_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.write_off_qty),
           :new.title_transfer_out_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.title_transfer_out_qty),
           :new.title_transfer_out_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.title_transfer_out_no_of_units),
           :new.warehouse_receipt_no,
           :new.warehouse_receipt_date,
           :new.container_size,
           :new.remarks,
           :new.is_added_to_pool,
           :new.loading_date,
           :new.loading_country_id,
           :new.loading_port_id,
           :new.is_entire_item_loaded,
           :new.is_weight_final,
           :new.bl_number,
           :new.bl_date,
           :new.parent_internal_grd_ref_no,
           :new.discharged_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.discharged_qty),
           :new.is_voyage_stock,
           :new.allocated_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.allocated_qty),
           :new.internal_stock_ref_no,
           :new.landed_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.landed_no_of_units),
           :new.landed_net_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.landed_net_qty),
           :new.landed_gross_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.landed_gross_qty),
           :new.shipped_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.shipped_no_of_units),
           :new.shipped_net_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.shipped_net_qty),
           :new.shipped_gross_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.shipped_gross_qty),
           :new.current_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.current_qty),
           :new.stock_status,
           :new.product_specs,
           :new.source_type,
           :new.source_int_stock_ref_no,
           :new.source_int_purchase_ref_no,
           :new.source_int_pool_ref_no,
           :new.is_fulfilled,
           :new.inventory_status,
           :new.truck_rail_number,
           :new.truck_rail_type,
           :new.packing_type_id,
           :new.handled_as,
           :new.allocated_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.allocated_no_of_units),
           :new.current_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.current_no_of_units),
           :new.stock_condition,
           :new.gravity_type_id,
           :new.gravity -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.gravity),
           :new.density_mass_qty_unit_id,
           :new.density_volume_qty_unit_id,
           :new.gravity_type,
           :new.customs_id,
           :new.tax_id,
           :new.duty_id,
           :new.customer_seal_no,
           :new.brand,
           :new.no_of_containers -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.no_of_containers),
           nvl(:new.no_of_bags, 0) -
           nvl(pkg_general.f_get_converted_quantity(:new.product_id,
                                                    :old.qty_unit_id,
                                                    :new.qty_unit_id,
                                                    nvl(:old.no_of_bags, 0)),
               0),
           nvl(:new.no_of_pieces, 0) -
           nvl(pkg_general.f_get_converted_quantity(:new.product_id,
                                                    :old.qty_unit_id,
                                                    :new.qty_unit_id,
                                                    nvl(:old.no_of_pieces, 0)),
               0),
           :new.rail_car_no,
           :new.sdcts_id,
           :new.partnership_type,
           :new.is_trans_ship,
           :new.is_mark_for_tolling,
           :new.tolling_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.tolling_qty),
           :new.tolling_stock_type,
           :new.element_id,
           :new.expected_sales_ccy,
           :new.profit_center_id,
           :new.strategy_id,
           :new.is_warrant,
           :new.warrant_no,
           :new.pcdi_id,
           :new.supp_contract_item_ref_no,
           :new.supplier_pcdi_id,
           :new.supp_internal_gmr_ref_no,
           :new.utility_header_id,
           :new.payable_returnable_type,
           :new.carry_over_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.carry_over_qty),
           :new.internal_action_ref_no,
           'Update',
           'N',
           :new.is_clone_stock_spilt,
		   :new.cot_int_action_ref_no);
      end if;
    else
      -- IsDelete is yes
      insert into grdl_goods_record_detail_log
        (internal_grd_ref_no,
         internal_gmr_ref_no,
         product_id,
         is_afloat,
         status,
         qty_delta,
         qty_unit_id,
         gross_weight_delta,
         tare_weight_delta,
         internal_contract_item_ref_no,
         int_alloc_group_id,
         packing_size_id,
         container_no,
         seal_no,
         mark_no,
         warehouse_ref_no,
         no_of_units_delta,
         quality_id,
         warehouse_profile_id,
         shed_id,
         origin_id,
         crop_year_id,
         parent_id,
         is_released_shipped,
         release_shipped_no_units_delta,
         is_write_off,
         write_off_no_of_units_delta,
         is_moved_out,
         moved_out_no_of_units_delta,
         total_no_of_units_delta,
         total_qty_delta,
         moved_out_qty_delta,
         release_shipped_qty_delta,
         write_off_qty_delta,
         title_transfer_out_qty_delta,
         title_transfr_out_no_unt_delta,
         warehouse_receipt_no,
         warehouse_receipt_date,
         container_size,
         remarks,
         is_added_to_pool,
         loading_date,
         loading_country_id,
         loading_port_id,
         is_entire_item_loaded,
         is_weight_final,
         bl_number,
         bl_date,
         parent_internal_grd_ref_no,
         discharged_qty_delta,
         is_voyage_stock,
         allocated_qty_delta,
         internal_stock_ref_no,
         landed_no_of_units_delta,
         landed_net_qty_delta,
         landed_gross_qty_delta,
         shipped_no_of_units_delta,
         shipped_net_qty_delta,
         shipped_gross_qty_delta,
         current_qty_delta,
         stock_status,
         product_specs,
         source_type,
         source_int_stock_ref_no,
         source_int_purchase_ref_no,
         source_int_pool_ref_no,
         is_fulfilled,
         inventory_status,
         truck_rail_number,
         truck_rail_type,
         packing_type_id,
         handled_as,
         allocated_no_of_units_delta,
         current_no_of_units_delta,
         stock_condition,
         gravity_type_id,
         gravity_delta,
         density_mass_qty_unit_id,
         density_volume_qty_unit_id,
         gravity_type,
         customs_id,
         tax_id,
         duty_id,
         customer_seal_no,
         brand,
         no_of_containers_delta,
         no_of_bags_delta,
         no_of_pieces_delta,
         rail_car_no,
         sdcts_id,
         partnership_type,
         is_trans_ship,
         is_mark_for_tolling,
         tolling_qty,
         tolling_stock_type,
         element_id,
         expected_sales_ccy,
         profit_center_id,
         strategy_id,
         is_warrant,
         warrant_no,
         pcdi_id,
         supp_contract_item_ref_no,
         supplier_pcdi_id,
         supp_internal_gmr_ref_no,
         utility_header_id,
         payable_returnable_type,
         carry_over_qty,
         internal_action_ref_no,
         entry_type,
         is_deleted,
         is_clone_stock_spilt,
		 cot_int_action_ref_no)
      values
        (:new.internal_grd_ref_no,
         :new.internal_gmr_ref_no,
         :new.product_id,
         :new.is_afloat,
         :new.status,
         :new.qty - :old.qty,
         :new.qty_unit_id,
         :new.gross_weight - :old.gross_weight,
         :new.tare_weight - :old.tare_weight,
         :new.internal_contract_item_ref_no,
         :new.int_alloc_group_id,
         :new.packing_size_id,
         :new.container_no,
         :new.seal_no,
         :new.mark_no,
         :new.warehouse_ref_no,
         :new.no_of_units - :old.no_of_units,
         :new.quality_id,
         :new.warehouse_profile_id,
         :new.shed_id,
         :new.origin_id,
         :new.crop_year_id,
         :new.parent_id,
         :new.is_released_shipped,
         :new.release_shipped_no_of_units -
         :old.release_shipped_no_of_units,
         :new.is_write_off,
         :new.write_off_no_of_units - :old.write_off_no_of_units,
         :new.is_moved_out,
         :new.moved_out_no_of_units - :old.moved_out_no_of_units,
         :new.total_no_of_units - :old.total_no_of_units,
         :new.total_qty - :old.total_qty,
         :new.moved_out_qty - :old.moved_out_qty,
         :new.release_shipped_qty - :old.release_shipped_qty,
         :new.write_off_qty - :old.write_off_qty,
         :new.title_transfer_out_qty - :old.title_transfer_out_qty,
         :new.title_transfer_out_no_of_units -
         :old.title_transfer_out_no_of_units,
         :new.warehouse_receipt_no,
         :new.warehouse_receipt_date,
         :new.container_size,
         :new.remarks,
         :new.is_added_to_pool,
         :new.loading_date,
         :new.loading_country_id,
         :new.loading_port_id,
         :new.is_entire_item_loaded,
         :new.is_weight_final,
         :new.bl_number,
         :new.bl_date,
         :new.parent_internal_grd_ref_no,
         :new.discharged_qty - :old.discharged_qty,
         :new.is_voyage_stock,
         :new.allocated_qty - :old.allocated_qty,
         :new.internal_stock_ref_no,
         :new.landed_no_of_units - :old.landed_no_of_units,
         :new.landed_net_qty - :old.landed_net_qty,
         :new.landed_gross_qty - :old.landed_gross_qty,
         :new.shipped_no_of_units - :old.shipped_no_of_units,
         :new.shipped_net_qty - :old.shipped_net_qty,
         :new.shipped_gross_qty - :old.shipped_gross_qty,
         :new.current_qty - :old.current_qty,
         :new.stock_status,
         :new.product_specs,
         :new.source_type,
         :new.source_int_stock_ref_no,
         :new.source_int_purchase_ref_no,
         :new.source_int_pool_ref_no,
         :new.is_fulfilled,
         :new.inventory_status,
         :new.truck_rail_number,
         :new.truck_rail_type,
         :new.packing_type_id,
         :new.handled_as,
         :new.allocated_no_of_units - :old.allocated_no_of_units,
         :new.current_no_of_units - :old.current_no_of_units,
         :new.stock_condition,
         :new.gravity_type_id,
         :new.gravity - :old.gravity,
         :new.density_mass_qty_unit_id,
         :new.density_volume_qty_unit_id,
         :new.gravity_type,
         :new.customs_id,
         :new.tax_id,
         :new.duty_id,
         :new.customer_seal_no,
         :new.brand,
         :new.no_of_containers - :old.no_of_containers,
         nvl(:new.no_of_bags, 0) - nvl(:old.no_of_bags, 0),
         nvl(:new.no_of_pieces, 0) - nvl(:old.no_of_pieces, 0),
         :new.rail_car_no,
         :new.sdcts_id,
         :new.partnership_type,
         :new.is_trans_ship,
         :new.is_mark_for_tolling,
         :new.tolling_qty - :old.tolling_qty,
         :new.tolling_stock_type,
         :new.element_id,
         :new.expected_sales_ccy,
         :new.profit_center_id,
         :new.strategy_id,
         :new.is_warrant,
         :new.warrant_no,
         :new.pcdi_id,
         :new.supp_contract_item_ref_no,
         :new.supplier_pcdi_id,
         :new.supp_internal_gmr_ref_no,
         :new.utility_header_id,
         :new.payable_returnable_type,
         :new.carry_over_qty - :old.carry_over_qty,
         :new.internal_action_ref_no,
         'Update',
         'Y',
         :new.is_clone_stock_spilt,
		 :new.cot_int_action_ref_no);
    end if;
  else
    --
    -- New Entry ( Entry Type=Insert)
    --
    insert into grdl_goods_record_detail_log
      (internal_grd_ref_no,
       internal_gmr_ref_no,
       product_id,
       is_afloat,
       status,
       qty_delta,
       qty_unit_id,
       gross_weight_delta,
       tare_weight_delta,
       internal_contract_item_ref_no,
       int_alloc_group_id,
       packing_size_id,
       container_no,
       seal_no,
       mark_no,
       warehouse_ref_no,
       no_of_units_delta,
       quality_id,
       warehouse_profile_id,
       shed_id,
       origin_id,
       crop_year_id,
       parent_id,
       is_released_shipped,
       release_shipped_no_units_delta,
       is_write_off,
       write_off_no_of_units_delta,
       is_moved_out,
       moved_out_no_of_units_delta,
       total_no_of_units_delta,
       total_qty_delta,
       moved_out_qty_delta,
       release_shipped_qty_delta,
       write_off_qty_delta,
       title_transfer_out_qty_delta,
       title_transfr_out_no_unt_delta,
       warehouse_receipt_no,
       warehouse_receipt_date,
       container_size,
       remarks,
       is_added_to_pool,
       loading_date,
       loading_country_id,
       loading_port_id,
       is_entire_item_loaded,
       is_weight_final,
       bl_number,
       bl_date,
       parent_internal_grd_ref_no,
       discharged_qty_delta,
       is_voyage_stock,
       allocated_qty_delta,
       internal_stock_ref_no,
       landed_no_of_units_delta,
       landed_net_qty_delta,
       landed_gross_qty_delta,
       shipped_no_of_units_delta,
       shipped_net_qty_delta,
       shipped_gross_qty_delta,
       current_qty_delta,
       stock_status,
       product_specs,
       source_type,
       source_int_stock_ref_no,
       source_int_purchase_ref_no,
       source_int_pool_ref_no,
       is_fulfilled,
       inventory_status,
       truck_rail_number,
       truck_rail_type,
       packing_type_id,
       handled_as,
       allocated_no_of_units_delta,
       current_no_of_units_delta,
       stock_condition,
       gravity_type_id,
       gravity_delta,
       density_mass_qty_unit_id,
       density_volume_qty_unit_id,
       gravity_type,
       customs_id,
       tax_id,
       duty_id,
       customer_seal_no,
       brand,
       no_of_containers_delta,
       no_of_bags_delta,
       no_of_pieces_delta,
       rail_car_no,
       sdcts_id,
       partnership_type,
       is_trans_ship,
       is_mark_for_tolling,
       tolling_qty,
       tolling_stock_type,
       element_id,
       expected_sales_ccy,
       profit_center_id,
       strategy_id,
       is_warrant,
       warrant_no,
       pcdi_id,
       supp_contract_item_ref_no,
       supplier_pcdi_id,
       supp_internal_gmr_ref_no,
       utility_header_id,
       payable_returnable_type,
       carry_over_qty,
       internal_action_ref_no,
       entry_type,
       is_deleted,
       is_clone_stock_spilt,
	   cot_int_action_ref_no)
    values
      (:new.internal_grd_ref_no,
       :new.internal_gmr_ref_no,
       :new.product_id,
       :new.is_afloat,
       :new.status,
       :new.qty,
       :new.qty_unit_id,
       :new.gross_weight,
       :new.tare_weight,
       :new.internal_contract_item_ref_no,
       :new.int_alloc_group_id,
       :new.packing_size_id,
       :new.container_no,
       :new.seal_no,
       :new.mark_no,
       :new.warehouse_ref_no,
       :new.no_of_units,
       :new.quality_id,
       :new.warehouse_profile_id,
       :new.shed_id,
       :new.origin_id,
       :new.crop_year_id,
       :new.parent_id,
       :new.is_released_shipped,
       :new.release_shipped_no_of_units,
       :new.is_write_off,
       :new.write_off_no_of_units,
       :new.is_moved_out,
       :new.moved_out_no_of_units,
       :new.total_no_of_units,
       :new.total_qty,
       :new.moved_out_qty,
       :new.release_shipped_qty,
       :new.write_off_qty,
       :new.title_transfer_out_qty,
       :new.title_transfer_out_no_of_units,
       :new.warehouse_receipt_no,
       :new.warehouse_receipt_date,
       :new.container_size,
       :new.remarks,
       :new.is_added_to_pool,
       :new.loading_date,
       :new.loading_country_id,
       :new.loading_port_id,
       :new.is_entire_item_loaded,
       :new.is_weight_final,
       :new.bl_number,
       :new.bl_date,
       :new.parent_internal_grd_ref_no,
       :new.discharged_qty,
       :new.is_voyage_stock,
       :new.allocated_qty,
       :new.internal_stock_ref_no,
       :new.landed_no_of_units,
       :new.landed_net_qty,
       :new.landed_gross_qty,
       :new.shipped_no_of_units,
       :new.shipped_net_qty,
       :new.shipped_gross_qty,
       :new.current_qty,
       :new.stock_status,
       :new.product_specs,
       :new.source_type,
       :new.source_int_stock_ref_no,
       :new.source_int_purchase_ref_no,
       :new.source_int_pool_ref_no,
       :new.is_fulfilled,
       :new.inventory_status,
       :new.truck_rail_number,
       :new.truck_rail_type,
       :new.packing_type_id,
       :new.handled_as,
       :new.allocated_no_of_units,
       :new.current_no_of_units,
       :new.stock_condition,
       :new.gravity_type_id,
       :new.gravity,
       :new.density_mass_qty_unit_id,
       :new.density_volume_qty_unit_id,
       :new.gravity_type,
       :new.customs_id,
       :new.tax_id,
       :new.duty_id,
       :new.customer_seal_no,
       :new.brand,
       :new.no_of_containers,
       nvl(:new.no_of_bags, 0),
       nvl(:new.no_of_pieces, 0),
       :new.rail_car_no,
       :new.sdcts_id,
       :new.partnership_type,
       :new.is_trans_ship,
       :new.is_mark_for_tolling,
       :new.tolling_qty,
       :new.tolling_stock_type,
       :new.element_id,
       :new.expected_sales_ccy,
       :new.profit_center_id,
       :new.strategy_id,
       :new.is_warrant,
       :new.warrant_no,
       :new.pcdi_id,
       :new.supp_contract_item_ref_no,
       :new.supplier_pcdi_id,
       :new.supp_internal_gmr_ref_no,
       :new.utility_header_id,
       :new.payable_returnable_type,
       :new.carry_over_qty,
       :new.internal_action_ref_no,
       'Insert',
       'N',
       :new.is_clone_stock_spilt,
	   :new.cot_int_action_ref_no);
  end if;

  insert into aci_assay_content_update_input
    (internal_grd_no, cont_type, ash_id, is_deleted)
  values
    (:new.internal_grd_ref_no, 'GRD', null, 'N');
end;
