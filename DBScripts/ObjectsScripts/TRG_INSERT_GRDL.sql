DROP TRIGGER TRG_INSERT_GRDL;

CREATE OR REPLACE TRIGGER "TRG_INSERT_GRDL" 
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
AFTER INSERT OR UPDATE
   ON GRD_GOODS_RECORD_DETAIL    FOR EACH ROW
BEGIN
   --
   -- If updating then put the delta for Quantity columns as Old - New when GRD is Active
   -- If GRD is inactive then negate all the quantity columns
   -- If inserting put the new value as is as Delta
   --
   IF UPDATING
   THEN
      IF    :NEW.IS_DELETED = 'N'
      THEN
         --Qty Unit is Not Updated
         IF :NEW.QTY_UNIT_ID = :OLD.QTY_UNIT_ID
         THEN
            INSERT INTO GRDL_GOODS_RECORD_DETAIL_LOG
                        (INTERNAL_GRD_REF_NO, INTERNAL_GMR_REF_NO,
                         PRODUCT_ID,IS_AFLOAT,STATUS,
                         QTY_DELTA,QTY_UNIT_ID,
                         GROSS_WEIGHT_DELTA,TARE_WEIGHT_DELTA,
                         INTERNAL_CONTRACT_ITEM_REF_NO,
                         INT_ALLOC_GROUP_ID,PACKING_SIZE_ID,
                         CONTAINER_NO,SEAL_NO,MARK_NO,
             WAREHOUSE_REF_NO,NO_OF_UNITS_DELTA,
             QUALITY_ID,WAREHOUSE_PROFILE_ID,
             SHED_ID,ORIGIN_ID,CROP_YEAR_ID,
             PARENT_ID,IS_RELEASED_SHIPPED,
             RELEASE_SHIPPED_NO_UNITS_DELTA,
             IS_WRITE_OFF,WRITE_OFF_NO_OF_UNITS_DELTA,
             IS_MOVED_OUT,MOVED_OUT_NO_OF_UNITS_DELTA,
             TOTAL_NO_OF_UNITS_DELTA,TOTAL_QTY_DELTA,
             MOVED_OUT_QTY_DELTA,RELEASE_SHIPPED_QTY_DELTA,
             WRITE_OFF_QTY_DELTA,TITLE_TRANSFER_OUT_QTY_DELTA,
             TITLE_TRANSFR_OUT_NO_UNT_DELTA,WAREHOUSE_RECEIPT_NO,
             WAREHOUSE_RECEIPT_DATE,CONTAINER_SIZE,REMARKS,
             IS_ADDED_TO_POOL,LOADING_DATE,LOADING_COUNTRY_ID,
             LOADING_PORT_ID,IS_ENTIRE_ITEM_LOADED,IS_WEIGHT_FINAL,
             BL_NUMBER,BL_DATE,PARENT_INTERNAL_GRD_REF_NO,
             DISCHARGED_QTY_DELTA,IS_VOYAGE_STOCK,ALLOCATED_QTY_DELTA,
             INTERNAL_STOCK_REF_NO,LANDED_NO_OF_UNITS_DELTA,
             LANDED_NET_QTY_DELTA,LANDED_GROSS_QTY_DELTA,
             SHIPPED_NO_OF_UNITS_DELTA,SHIPPED_NET_QTY_DELTA,
             SHIPPED_GROSS_QTY_DELTA,CURRENT_QTY_DELTA,STOCK_STATUS,
             PRODUCT_SPECS,SOURCE_TYPE,SOURCE_INT_STOCK_REF_NO,
             SOURCE_INT_PURCHASE_REF_NO,SOURCE_INT_POOL_REF_NO,
             IS_FULFILLED,INVENTORY_STATUS,TRUCK_RAIL_NUMBER,
             TRUCK_RAIL_TYPE,PACKING_TYPE_ID,HANDLED_AS,
             ALLOCATED_NO_OF_UNITS_DELTA,CURRENT_NO_OF_UNITS_DELTA,
             STOCK_CONDITION,GRAVITY_TYPE_ID,GRAVITY_DELTA,
             DENSITY_MASS_QTY_UNIT_ID,DENSITY_VOLUME_QTY_UNIT_ID,
             GRAVITY_TYPE,CUSTOMS_ID,TAX_ID,DUTY_ID,CUSTOMER_SEAL_NO,
             BRAND,NO_OF_CONTAINERS_DELTA,NO_OF_BAGS_DELTA,
             NO_OF_PIECES_DELTA,RAIL_CAR_NO,SDCTS_ID,PARTNERSHIP_TYPE,
             IS_TRANS_SHIP, IS_MARK_FOR_TOLLING,
             TOLLING_QTY, TOLLING_STOCK_TYPE, 
             ELEMENT_ID, EXPECTED_SALES_CCY, 
             PROFIT_CENTER_ID,STRATEGY_ID,
             IS_WARRANT, WARRANT_NO, PCDI_ID,
             SUPP_CONTRACT_ITEM_REF_NO, 
             SUPPLIER_PCDI_ID, PAYABLE_RETURNABLE_TYPE ,
             CARRY_OVER_QTY,
                         INTERNAL_ACTION_REF_NO,ENTRY_TYPE, IS_DELETED
                        )
                 VALUES (:NEW.INTERNAL_GRD_REF_NO, :NEW.INTERNAL_GMR_REF_NO,
                 :NEW.PRODUCT_ID,:NEW.IS_AFLOAT,:NEW.STATUS,
             :NEW.QTY - :OLD.QTY,:NEW.QTY_UNIT_ID,
             :NEW.GROSS_WEIGHT - :OLD.GROSS_WEIGHT,
             :NEW.TARE_WEIGHT - :OLD.TARE_WEIGHT,
             :NEW.INTERNAL_CONTRACT_ITEM_REF_NO,
             :NEW.INT_ALLOC_GROUP_ID,:NEW.PACKING_SIZE_ID,
             :NEW.CONTAINER_NO,:NEW.SEAL_NO,:NEW.MARK_NO,
             :NEW.WAREHOUSE_REF_NO,:NEW.NO_OF_UNITS - :OLD.NO_OF_UNITS,
             :NEW.QUALITY_ID,:NEW.WAREHOUSE_PROFILE_ID,:NEW.SHED_ID,
             :NEW.ORIGIN_ID,:NEW.CROP_YEAR_ID,:NEW.PARENT_ID,
             :NEW.IS_RELEASED_SHIPPED,
             :NEW.RELEASE_SHIPPED_NO_OF_UNITS - :OLD.RELEASE_SHIPPED_NO_OF_UNITS,
             :NEW.IS_WRITE_OFF,:NEW.WRITE_OFF_NO_OF_UNITS - :OLD.WRITE_OFF_NO_OF_UNITS,
             :NEW.IS_MOVED_OUT,:NEW.MOVED_OUT_NO_OF_UNITS - :OLD.MOVED_OUT_NO_OF_UNITS,
             :NEW.TOTAL_NO_OF_UNITS - :OLD.TOTAL_NO_OF_UNITS,
             :NEW.TOTAL_QTY - :OLD.TOTAL_QTY,
             :NEW.MOVED_OUT_QTY - :OLD.MOVED_OUT_QTY,
             :NEW.RELEASE_SHIPPED_QTY - :OLD.RELEASE_SHIPPED_QTY,
             :NEW.WRITE_OFF_QTY - :OLD.WRITE_OFF_QTY,
             :NEW.TITLE_TRANSFER_OUT_QTY - :OLD.TITLE_TRANSFER_OUT_QTY,
             :NEW.TITLE_TRANSFER_OUT_NO_OF_UNITS - :OLD.TITLE_TRANSFER_OUT_NO_OF_UNITS,
             :NEW.WAREHOUSE_RECEIPT_NO,:NEW.WAREHOUSE_RECEIPT_DATE,
             :NEW.CONTAINER_SIZE,:NEW.REMARKS,:NEW.IS_ADDED_TO_POOL,
             :NEW.LOADING_DATE,:NEW.LOADING_COUNTRY_ID,
             :NEW.LOADING_PORT_ID,:NEW.IS_ENTIRE_ITEM_LOADED,
             :NEW.IS_WEIGHT_FINAL,:NEW.BL_NUMBER,:NEW.BL_DATE,
             :NEW.PARENT_INTERNAL_GRD_REF_NO,:NEW.DISCHARGED_QTY - :OLD.DISCHARGED_QTY,
             :NEW.IS_VOYAGE_STOCK,:NEW.ALLOCATED_QTY - :OLD.ALLOCATED_QTY,
             :NEW.INTERNAL_STOCK_REF_NO,:NEW.LANDED_NO_OF_UNITS - :OLD.LANDED_NO_OF_UNITS,
             :NEW.LANDED_NET_QTY - :OLD.LANDED_NET_QTY,
             :NEW.LANDED_GROSS_QTY - :OLD.LANDED_GROSS_QTY,
             :NEW.SHIPPED_NO_OF_UNITS - :OLD.SHIPPED_NO_OF_UNITS,
             :NEW.SHIPPED_NET_QTY - :OLD.SHIPPED_NET_QTY,
             :NEW.SHIPPED_GROSS_QTY - :OLD.SHIPPED_GROSS_QTY,
             :NEW.CURRENT_QTY - :OLD.CURRENT_QTY,
             :NEW.STOCK_STATUS,:NEW.PRODUCT_SPECS,:NEW.SOURCE_TYPE,
             :NEW.SOURCE_INT_STOCK_REF_NO,:NEW.SOURCE_INT_PURCHASE_REF_NO,
             :NEW.SOURCE_INT_POOL_REF_NO,:NEW.IS_FULFILLED,
             :NEW.INVENTORY_STATUS,:NEW.TRUCK_RAIL_NUMBER,
             :NEW.TRUCK_RAIL_TYPE,:NEW.PACKING_TYPE_ID,:NEW.HANDLED_AS,
             :NEW.ALLOCATED_NO_OF_UNITS - :OLD.ALLOCATED_NO_OF_UNITS,
             :NEW.CURRENT_NO_OF_UNITS - :OLD.CURRENT_NO_OF_UNITS,
             :NEW.STOCK_CONDITION,:NEW.GRAVITY_TYPE_ID,
             :NEW.GRAVITY - :OLD.GRAVITY,:NEW.DENSITY_MASS_QTY_UNIT_ID,
             :NEW.DENSITY_VOLUME_QTY_UNIT_ID,:NEW.GRAVITY_TYPE,
             :NEW.CUSTOMS_ID,:NEW.TAX_ID,:NEW.DUTY_ID,:NEW.CUSTOMER_SEAL_NO,
             :NEW.BRAND,:NEW.NO_OF_CONTAINERS - :OLD.NO_OF_CONTAINERS,
             :NEW.NO_OF_BAGS - :OLD.NO_OF_BAGS,:NEW.NO_OF_PIECES - :OLD.NO_OF_PIECES,
             :NEW.RAIL_CAR_NO,:NEW.SDCTS_ID,:NEW.PARTNERSHIP_TYPE,
             :NEW.IS_TRANS_SHIP, :NEW.IS_MARK_FOR_TOLLING,
             :NEW.TOLLING_QTY - :OLD.TOLLING_QTY, :NEW.TOLLING_STOCK_TYPE, 
             :NEW.ELEMENT_ID, :NEW.EXPECTED_SALES_CCY, 
             :NEW.PROFIT_CENTER_ID,:NEW.STRATEGY_ID,
             :NEW.IS_WARRANT, :NEW.WARRANT_NO, :NEW.PCDI_ID,
             :NEW.SUPP_CONTRACT_ITEM_REF_NO, 
             :NEW.SUPPLIER_PCDI_ID, :NEW.PAYABLE_RETURNABLE_TYPE ,
             :NEW.CARRY_OVER_QTY - :OLD.CARRY_OVER_QTY,         
             :NEW.INTERNAL_ACTION_REF_NO,'Update', 'N'
                        );
         ELSE
            --Qty Unit is Updated
            INSERT INTO GRDL_GOODS_RECORD_DETAIL_LOG
                        (INTERNAL_GRD_REF_NO, INTERNAL_GMR_REF_NO,
                         PRODUCT_ID,IS_AFLOAT,STATUS,
                         QTY_DELTA,QTY_UNIT_ID,
                         GROSS_WEIGHT_DELTA,TARE_WEIGHT_DELTA,
                         INTERNAL_CONTRACT_ITEM_REF_NO,
                         INT_ALLOC_GROUP_ID,PACKING_SIZE_ID,
                         CONTAINER_NO,SEAL_NO,MARK_NO,
             WAREHOUSE_REF_NO,NO_OF_UNITS_DELTA,
             QUALITY_ID,WAREHOUSE_PROFILE_ID,
             SHED_ID,ORIGIN_ID,CROP_YEAR_ID,
             PARENT_ID,IS_RELEASED_SHIPPED,
             RELEASE_SHIPPED_NO_UNITS_DELTA,
             IS_WRITE_OFF,WRITE_OFF_NO_OF_UNITS_DELTA,
             IS_MOVED_OUT,MOVED_OUT_NO_OF_UNITS_DELTA,
             TOTAL_NO_OF_UNITS_DELTA,TOTAL_QTY_DELTA,
             MOVED_OUT_QTY_DELTA,RELEASE_SHIPPED_QTY_DELTA,
             WRITE_OFF_QTY_DELTA,TITLE_TRANSFER_OUT_QTY_DELTA,
             TITLE_TRANSFR_OUT_NO_UNT_DELTA,WAREHOUSE_RECEIPT_NO,
             WAREHOUSE_RECEIPT_DATE,CONTAINER_SIZE,REMARKS,
             IS_ADDED_TO_POOL,LOADING_DATE,LOADING_COUNTRY_ID,
             LOADING_PORT_ID,IS_ENTIRE_ITEM_LOADED,IS_WEIGHT_FINAL,
             BL_NUMBER,BL_DATE,PARENT_INTERNAL_GRD_REF_NO,
             DISCHARGED_QTY_DELTA,IS_VOYAGE_STOCK,ALLOCATED_QTY_DELTA,
             INTERNAL_STOCK_REF_NO,LANDED_NO_OF_UNITS_DELTA,
             LANDED_NET_QTY_DELTA,LANDED_GROSS_QTY_DELTA,
             SHIPPED_NO_OF_UNITS_DELTA,SHIPPED_NET_QTY_DELTA,
             SHIPPED_GROSS_QTY_DELTA,CURRENT_QTY_DELTA,STOCK_STATUS,
             PRODUCT_SPECS,SOURCE_TYPE,SOURCE_INT_STOCK_REF_NO,
             SOURCE_INT_PURCHASE_REF_NO,SOURCE_INT_POOL_REF_NO,
             IS_FULFILLED,INVENTORY_STATUS,TRUCK_RAIL_NUMBER,
             TRUCK_RAIL_TYPE,PACKING_TYPE_ID,HANDLED_AS,
             ALLOCATED_NO_OF_UNITS_DELTA,CURRENT_NO_OF_UNITS_DELTA,
             STOCK_CONDITION,GRAVITY_TYPE_ID,GRAVITY_DELTA,
             DENSITY_MASS_QTY_UNIT_ID,DENSITY_VOLUME_QTY_UNIT_ID,
             GRAVITY_TYPE,CUSTOMS_ID,TAX_ID,DUTY_ID,CUSTOMER_SEAL_NO,
             BRAND,NO_OF_CONTAINERS_DELTA,NO_OF_BAGS_DELTA,
             NO_OF_PIECES_DELTA,RAIL_CAR_NO,SDCTS_ID,PARTNERSHIP_TYPE,
             IS_TRANS_SHIP, IS_MARK_FOR_TOLLING,
             TOLLING_QTY, TOLLING_STOCK_TYPE, 
             ELEMENT_ID, EXPECTED_SALES_CCY, 
             PROFIT_CENTER_ID,STRATEGY_ID,
             IS_WARRANT, WARRANT_NO, PCDI_ID,
             SUPP_CONTRACT_ITEM_REF_NO, 
             SUPPLIER_PCDI_ID, PAYABLE_RETURNABLE_TYPE ,
             CARRY_OVER_QTY,
                         INTERNAL_ACTION_REF_NO,ENTRY_TYPE, IS_DELETED
                        )
                 VALUES (:NEW.INTERNAL_GRD_REF_NO, :NEW.INTERNAL_GMR_REF_NO,
                 :NEW.PRODUCT_ID,:NEW.IS_AFLOAT,:NEW.STATUS,
             :NEW.QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.QTY
                                                            ),
                                :NEW.QTY_UNIT_ID,
             :NEW.GROSS_WEIGHT - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.GROSS_WEIGHT
                                                            ),
             :NEW.TARE_WEIGHT - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.TARE_WEIGHT
                                                            ),
             :NEW.INTERNAL_CONTRACT_ITEM_REF_NO,
             :NEW.INT_ALLOC_GROUP_ID,:NEW.PACKING_SIZE_ID,
             :NEW.CONTAINER_NO,:NEW.SEAL_NO,:NEW.MARK_NO,
             :NEW.WAREHOUSE_REF_NO,:NEW.NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.NO_OF_UNITS
                                                            ),
             :NEW.QUALITY_ID,:NEW.WAREHOUSE_PROFILE_ID,:NEW.SHED_ID,
             :NEW.ORIGIN_ID,:NEW.CROP_YEAR_ID,:NEW.PARENT_ID,
             :NEW.IS_RELEASED_SHIPPED,
             :NEW.RELEASE_SHIPPED_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.RELEASE_SHIPPED_NO_OF_UNITS
                                                            ),
             :NEW.IS_WRITE_OFF,:NEW.WRITE_OFF_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.WRITE_OFF_NO_OF_UNITS
                                                            ),
             :NEW.IS_MOVED_OUT,:NEW.MOVED_OUT_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.MOVED_OUT_NO_OF_UNITS
                                                            ),
             :NEW.TOTAL_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.TOTAL_NO_OF_UNITS
                                                            ),
             :NEW.TOTAL_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.TOTAL_QTY
                                                            ),
             :NEW.MOVED_OUT_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.MOVED_OUT_QTY
                                                            ),
             :NEW.RELEASE_SHIPPED_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.RELEASE_SHIPPED_QTY
                                                            ),
             :NEW.WRITE_OFF_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.WRITE_OFF_QTY
                                                            ),
             :NEW.TITLE_TRANSFER_OUT_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.TITLE_TRANSFER_OUT_QTY
                                                            ),
             :NEW.TITLE_TRANSFER_OUT_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.TITLE_TRANSFER_OUT_NO_OF_UNITS
                                                            ),
             :NEW.WAREHOUSE_RECEIPT_NO,:NEW.WAREHOUSE_RECEIPT_DATE,
             :NEW.CONTAINER_SIZE,:NEW.REMARKS,:NEW.IS_ADDED_TO_POOL,
             :NEW.LOADING_DATE,:NEW.LOADING_COUNTRY_ID,
             :NEW.LOADING_PORT_ID,:NEW.IS_ENTIRE_ITEM_LOADED,
             :NEW.IS_WEIGHT_FINAL,:NEW.BL_NUMBER,:NEW.BL_DATE,
             :NEW.PARENT_INTERNAL_GRD_REF_NO,
             :NEW.DISCHARGED_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.DISCHARGED_QTY
                                                            ),
             :NEW.IS_VOYAGE_STOCK,
             :NEW.ALLOCATED_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.ALLOCATED_QTY
                                                            ),
             :NEW.INTERNAL_STOCK_REF_NO,
             :NEW.LANDED_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.LANDED_NO_OF_UNITS
                                                            ),
             :NEW.LANDED_NET_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.LANDED_NET_QTY
                                                            ),
             :NEW.LANDED_GROSS_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.LANDED_GROSS_QTY
                                                            ),
             :NEW.SHIPPED_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.SHIPPED_NO_OF_UNITS
                                                            ),
             :NEW.SHIPPED_NET_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.SHIPPED_NET_QTY
                                                            ),
             :NEW.SHIPPED_GROSS_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.SHIPPED_GROSS_QTY
                                                            ),
             :NEW.CURRENT_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.CURRENT_QTY
                                                            ),
             :NEW.STOCK_STATUS,:NEW.PRODUCT_SPECS,:NEW.SOURCE_TYPE,
             :NEW.SOURCE_INT_STOCK_REF_NO,:NEW.SOURCE_INT_PURCHASE_REF_NO,
             :NEW.SOURCE_INT_POOL_REF_NO,:NEW.IS_FULFILLED,
             :NEW.INVENTORY_STATUS,:NEW.TRUCK_RAIL_NUMBER,
             :NEW.TRUCK_RAIL_TYPE,:NEW.PACKING_TYPE_ID,:NEW.HANDLED_AS,
             :NEW.ALLOCATED_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.ALLOCATED_NO_OF_UNITS
                                                            ),
             :NEW.CURRENT_NO_OF_UNITS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.CURRENT_NO_OF_UNITS
                                                            ),
             :NEW.STOCK_CONDITION,:NEW.GRAVITY_TYPE_ID,
             :NEW.GRAVITY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.GRAVITY
                                                            ),
                                :NEW.DENSITY_MASS_QTY_UNIT_ID,
             :NEW.DENSITY_VOLUME_QTY_UNIT_ID,:NEW.GRAVITY_TYPE,
             :NEW.CUSTOMS_ID,:NEW.TAX_ID,:NEW.DUTY_ID,:NEW.CUSTOMER_SEAL_NO,
             :NEW.BRAND,
             :NEW.NO_OF_CONTAINERS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.NO_OF_CONTAINERS
                                                            ),
             :NEW.NO_OF_BAGS - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.NO_OF_BAGS
                                                            ),
                                :NEW.NO_OF_PIECES - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.NO_OF_PIECES
                                                            ),
             :NEW.RAIL_CAR_NO,:NEW.SDCTS_ID,:NEW.PARTNERSHIP_TYPE,
             :NEW.IS_TRANS_SHIP, :NEW.IS_MARK_FOR_TOLLING,
             :NEW.TOLLING_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.TOLLING_QTY
                                                            ),             
             :NEW.TOLLING_STOCK_TYPE, 
             :NEW.ELEMENT_ID, :NEW.EXPECTED_SALES_CCY, 
             :NEW.PROFIT_CENTER_ID,:NEW.STRATEGY_ID,
             :NEW.IS_WARRANT, :NEW.WARRANT_NO, :NEW.PCDI_ID,
             :NEW.SUPP_CONTRACT_ITEM_REF_NO, 
             :NEW.SUPPLIER_PCDI_ID, :NEW.PAYABLE_RETURNABLE_TYPE ,
             :NEW.CARRY_OVER_QTY - pkg_general.f_get_converted_quantity
                                                            (:NEW.product_id,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.CARRY_OVER_QTY
                                                            ),
             :NEW.INTERNAL_ACTION_REF_NO,'Update', 'N'
                        );
         END IF;
      ELSE
         -- IsDelete is yes
         INSERT INTO GRDL_GOODS_RECORD_DETAIL_LOG
                        (INTERNAL_GRD_REF_NO, INTERNAL_GMR_REF_NO,
                         PRODUCT_ID,IS_AFLOAT,STATUS,
                         QTY_DELTA,QTY_UNIT_ID,
                         GROSS_WEIGHT_DELTA,TARE_WEIGHT_DELTA,
                         INTERNAL_CONTRACT_ITEM_REF_NO,
                         INT_ALLOC_GROUP_ID,PACKING_SIZE_ID,
                         CONTAINER_NO,SEAL_NO,MARK_NO,
             WAREHOUSE_REF_NO,NO_OF_UNITS_DELTA,
             QUALITY_ID,WAREHOUSE_PROFILE_ID,
             SHED_ID,ORIGIN_ID,CROP_YEAR_ID,
             PARENT_ID,IS_RELEASED_SHIPPED,
             RELEASE_SHIPPED_NO_UNITS_DELTA,
             IS_WRITE_OFF,WRITE_OFF_NO_OF_UNITS_DELTA,
             IS_MOVED_OUT,MOVED_OUT_NO_OF_UNITS_DELTA,
             TOTAL_NO_OF_UNITS_DELTA,TOTAL_QTY_DELTA,
             MOVED_OUT_QTY_DELTA,RELEASE_SHIPPED_QTY_DELTA,
             WRITE_OFF_QTY_DELTA,TITLE_TRANSFER_OUT_QTY_DELTA,
             TITLE_TRANSFR_OUT_NO_UNT_DELTA,WAREHOUSE_RECEIPT_NO,
             WAREHOUSE_RECEIPT_DATE,CONTAINER_SIZE,REMARKS,
             IS_ADDED_TO_POOL,LOADING_DATE,LOADING_COUNTRY_ID,
             LOADING_PORT_ID,IS_ENTIRE_ITEM_LOADED,IS_WEIGHT_FINAL,
             BL_NUMBER,BL_DATE,PARENT_INTERNAL_GRD_REF_NO,
             DISCHARGED_QTY_DELTA,IS_VOYAGE_STOCK,ALLOCATED_QTY_DELTA,
             INTERNAL_STOCK_REF_NO,LANDED_NO_OF_UNITS_DELTA,
             LANDED_NET_QTY_DELTA,LANDED_GROSS_QTY_DELTA,
             SHIPPED_NO_OF_UNITS_DELTA,SHIPPED_NET_QTY_DELTA,
             SHIPPED_GROSS_QTY_DELTA,CURRENT_QTY_DELTA,STOCK_STATUS,
             PRODUCT_SPECS,SOURCE_TYPE,SOURCE_INT_STOCK_REF_NO,
             SOURCE_INT_PURCHASE_REF_NO,SOURCE_INT_POOL_REF_NO,
             IS_FULFILLED,INVENTORY_STATUS,TRUCK_RAIL_NUMBER,
             TRUCK_RAIL_TYPE,PACKING_TYPE_ID,HANDLED_AS,
             ALLOCATED_NO_OF_UNITS_DELTA,CURRENT_NO_OF_UNITS_DELTA,
             STOCK_CONDITION,GRAVITY_TYPE_ID,GRAVITY_DELTA,
             DENSITY_MASS_QTY_UNIT_ID,DENSITY_VOLUME_QTY_UNIT_ID,
             GRAVITY_TYPE,CUSTOMS_ID,TAX_ID,DUTY_ID,CUSTOMER_SEAL_NO,
             BRAND,NO_OF_CONTAINERS_DELTA,NO_OF_BAGS_DELTA,
             NO_OF_PIECES_DELTA,RAIL_CAR_NO,SDCTS_ID,PARTNERSHIP_TYPE,
             IS_TRANS_SHIP, IS_MARK_FOR_TOLLING,
             TOLLING_QTY, TOLLING_STOCK_TYPE, 
             ELEMENT_ID, EXPECTED_SALES_CCY, 
             PROFIT_CENTER_ID,STRATEGY_ID,
             IS_WARRANT, WARRANT_NO, PCDI_ID,
             SUPP_CONTRACT_ITEM_REF_NO, 
             SUPPLIER_PCDI_ID, PAYABLE_RETURNABLE_TYPE ,
             CARRY_OVER_QTY,
                         INTERNAL_ACTION_REF_NO,ENTRY_TYPE, IS_DELETED
                        )
                 VALUES (:NEW.INTERNAL_GRD_REF_NO, :NEW.INTERNAL_GMR_REF_NO,
                 :NEW.PRODUCT_ID,:NEW.IS_AFLOAT,:NEW.STATUS,
             :NEW.QTY - :OLD.QTY,:NEW.QTY_UNIT_ID,
             :NEW.GROSS_WEIGHT - :OLD.GROSS_WEIGHT,
             :NEW.TARE_WEIGHT - :OLD.TARE_WEIGHT,
             :NEW.INTERNAL_CONTRACT_ITEM_REF_NO,
             :NEW.INT_ALLOC_GROUP_ID,:NEW.PACKING_SIZE_ID,
             :NEW.CONTAINER_NO,:NEW.SEAL_NO,:NEW.MARK_NO,
             :NEW.WAREHOUSE_REF_NO,:NEW.NO_OF_UNITS - :OLD.NO_OF_UNITS,
             :NEW.QUALITY_ID,:NEW.WAREHOUSE_PROFILE_ID,:NEW.SHED_ID,
             :NEW.ORIGIN_ID,:NEW.CROP_YEAR_ID,:NEW.PARENT_ID,
             :NEW.IS_RELEASED_SHIPPED,
             :NEW.RELEASE_SHIPPED_NO_OF_UNITS - :OLD.RELEASE_SHIPPED_NO_OF_UNITS,
             :NEW.IS_WRITE_OFF,:NEW.WRITE_OFF_NO_OF_UNITS - :OLD.WRITE_OFF_NO_OF_UNITS,
             :NEW.IS_MOVED_OUT,:NEW.MOVED_OUT_NO_OF_UNITS - :OLD.MOVED_OUT_NO_OF_UNITS,
             :NEW.TOTAL_NO_OF_UNITS - :OLD.TOTAL_NO_OF_UNITS,
             :NEW.TOTAL_QTY - :OLD.TOTAL_QTY,
             :NEW.MOVED_OUT_QTY - :OLD.MOVED_OUT_QTY,
             :NEW.RELEASE_SHIPPED_QTY - :OLD.RELEASE_SHIPPED_QTY,
             :NEW.WRITE_OFF_QTY - :OLD.WRITE_OFF_QTY,
             :NEW.TITLE_TRANSFER_OUT_QTY - :OLD.TITLE_TRANSFER_OUT_QTY,
             :NEW.TITLE_TRANSFER_OUT_NO_OF_UNITS - :OLD.TITLE_TRANSFER_OUT_NO_OF_UNITS,
             :NEW.WAREHOUSE_RECEIPT_NO,:NEW.WAREHOUSE_RECEIPT_DATE,
             :NEW.CONTAINER_SIZE,:NEW.REMARKS,:NEW.IS_ADDED_TO_POOL,
             :NEW.LOADING_DATE,:NEW.LOADING_COUNTRY_ID,
             :NEW.LOADING_PORT_ID,:NEW.IS_ENTIRE_ITEM_LOADED,
             :NEW.IS_WEIGHT_FINAL,:NEW.BL_NUMBER,:NEW.BL_DATE,
             :NEW.PARENT_INTERNAL_GRD_REF_NO,:NEW.DISCHARGED_QTY - :OLD.DISCHARGED_QTY,
             :NEW.IS_VOYAGE_STOCK,:NEW.ALLOCATED_QTY - :OLD.ALLOCATED_QTY,
             :NEW.INTERNAL_STOCK_REF_NO,:NEW.LANDED_NO_OF_UNITS - :OLD.LANDED_NO_OF_UNITS,
             :NEW.LANDED_NET_QTY - :OLD.LANDED_NET_QTY,
             :NEW.LANDED_GROSS_QTY - :OLD.LANDED_GROSS_QTY,
             :NEW.SHIPPED_NO_OF_UNITS - :OLD.SHIPPED_NO_OF_UNITS,
             :NEW.SHIPPED_NET_QTY - :OLD.SHIPPED_NET_QTY,
             :NEW.SHIPPED_GROSS_QTY - :OLD.SHIPPED_GROSS_QTY,
             :NEW.CURRENT_QTY - :OLD.CURRENT_QTY,
             :NEW.STOCK_STATUS,:NEW.PRODUCT_SPECS,:NEW.SOURCE_TYPE,
             :NEW.SOURCE_INT_STOCK_REF_NO,:NEW.SOURCE_INT_PURCHASE_REF_NO,
             :NEW.SOURCE_INT_POOL_REF_NO,:NEW.IS_FULFILLED,
             :NEW.INVENTORY_STATUS,:NEW.TRUCK_RAIL_NUMBER,
             :NEW.TRUCK_RAIL_TYPE,:NEW.PACKING_TYPE_ID,:NEW.HANDLED_AS,
             :NEW.ALLOCATED_NO_OF_UNITS - :OLD.ALLOCATED_NO_OF_UNITS,
             :NEW.CURRENT_NO_OF_UNITS - :OLD.CURRENT_NO_OF_UNITS,
             :NEW.STOCK_CONDITION,:NEW.GRAVITY_TYPE_ID,
             :NEW.GRAVITY - :OLD.GRAVITY,:NEW.DENSITY_MASS_QTY_UNIT_ID,
             :NEW.DENSITY_VOLUME_QTY_UNIT_ID,:NEW.GRAVITY_TYPE,
             :NEW.CUSTOMS_ID,:NEW.TAX_ID,:NEW.DUTY_ID,:NEW.CUSTOMER_SEAL_NO,
             :NEW.BRAND,:NEW.NO_OF_CONTAINERS - :OLD.NO_OF_CONTAINERS,
             :NEW.NO_OF_BAGS - :OLD.NO_OF_BAGS,:NEW.NO_OF_PIECES - :OLD.NO_OF_PIECES,
             :NEW.RAIL_CAR_NO,:NEW.SDCTS_ID,:NEW.PARTNERSHIP_TYPE,
             :NEW.IS_TRANS_SHIP, :NEW.IS_MARK_FOR_TOLLING,
             :NEW.TOLLING_QTY - :OLD.TOLLING_QTY, :NEW.TOLLING_STOCK_TYPE, 
             :NEW.ELEMENT_ID, :NEW.EXPECTED_SALES_CCY, 
             :NEW.PROFIT_CENTER_ID,:NEW.STRATEGY_ID,
             :NEW.IS_WARRANT, :NEW.WARRANT_NO, :NEW.PCDI_ID,
             :NEW.SUPP_CONTRACT_ITEM_REF_NO, 
             :NEW.SUPPLIER_PCDI_ID, :NEW.PAYABLE_RETURNABLE_TYPE ,
             :NEW.CARRY_OVER_QTY - :OLD.CARRY_OVER_QTY, 
             :NEW.INTERNAL_ACTION_REF_NO,'Update', 'Y'
                        );
      END IF;
   ELSE
      --
      -- New Entry ( Entry Type=Insert)
      --
      INSERT INTO GRDL_GOODS_RECORD_DETAIL_LOG
                        (INTERNAL_GRD_REF_NO, INTERNAL_GMR_REF_NO,
                         PRODUCT_ID,IS_AFLOAT,STATUS,
                         QTY_DELTA,QTY_UNIT_ID,
                         GROSS_WEIGHT_DELTA,TARE_WEIGHT_DELTA,
                         INTERNAL_CONTRACT_ITEM_REF_NO,
                         INT_ALLOC_GROUP_ID,PACKING_SIZE_ID,
                         CONTAINER_NO,SEAL_NO,MARK_NO,
             WAREHOUSE_REF_NO,NO_OF_UNITS_DELTA,
             QUALITY_ID,WAREHOUSE_PROFILE_ID,
             SHED_ID,ORIGIN_ID,CROP_YEAR_ID,
             PARENT_ID,IS_RELEASED_SHIPPED,
             RELEASE_SHIPPED_NO_UNITS_DELTA,
             IS_WRITE_OFF,WRITE_OFF_NO_OF_UNITS_DELTA,
             IS_MOVED_OUT,MOVED_OUT_NO_OF_UNITS_DELTA,
             TOTAL_NO_OF_UNITS_DELTA,TOTAL_QTY_DELTA,
             MOVED_OUT_QTY_DELTA,RELEASE_SHIPPED_QTY_DELTA,
             WRITE_OFF_QTY_DELTA,TITLE_TRANSFER_OUT_QTY_DELTA,
             TITLE_TRANSFR_OUT_NO_UNT_DELTA,WAREHOUSE_RECEIPT_NO,
             WAREHOUSE_RECEIPT_DATE,CONTAINER_SIZE,REMARKS,
             IS_ADDED_TO_POOL,LOADING_DATE,LOADING_COUNTRY_ID,
             LOADING_PORT_ID,IS_ENTIRE_ITEM_LOADED,IS_WEIGHT_FINAL,
             BL_NUMBER,BL_DATE,PARENT_INTERNAL_GRD_REF_NO,
             DISCHARGED_QTY_DELTA,IS_VOYAGE_STOCK,ALLOCATED_QTY_DELTA,
             INTERNAL_STOCK_REF_NO,LANDED_NO_OF_UNITS_DELTA,
             LANDED_NET_QTY_DELTA,LANDED_GROSS_QTY_DELTA,
             SHIPPED_NO_OF_UNITS_DELTA,SHIPPED_NET_QTY_DELTA,
             SHIPPED_GROSS_QTY_DELTA,CURRENT_QTY_DELTA,STOCK_STATUS,
             PRODUCT_SPECS,SOURCE_TYPE,SOURCE_INT_STOCK_REF_NO,
             SOURCE_INT_PURCHASE_REF_NO,SOURCE_INT_POOL_REF_NO,
             IS_FULFILLED,INVENTORY_STATUS,TRUCK_RAIL_NUMBER,
             TRUCK_RAIL_TYPE,PACKING_TYPE_ID,HANDLED_AS,
             ALLOCATED_NO_OF_UNITS_DELTA,CURRENT_NO_OF_UNITS_DELTA,
             STOCK_CONDITION,GRAVITY_TYPE_ID,GRAVITY_DELTA,
             DENSITY_MASS_QTY_UNIT_ID,DENSITY_VOLUME_QTY_UNIT_ID,
             GRAVITY_TYPE,CUSTOMS_ID,TAX_ID,DUTY_ID,CUSTOMER_SEAL_NO,
             BRAND,NO_OF_CONTAINERS_DELTA,NO_OF_BAGS_DELTA,
             NO_OF_PIECES_DELTA,RAIL_CAR_NO,SDCTS_ID,PARTNERSHIP_TYPE,
             IS_TRANS_SHIP, IS_MARK_FOR_TOLLING,
             TOLLING_QTY, TOLLING_STOCK_TYPE, 
             ELEMENT_ID, EXPECTED_SALES_CCY, 
             PROFIT_CENTER_ID,STRATEGY_ID,
             IS_WARRANT, WARRANT_NO, PCDI_ID,
             SUPP_CONTRACT_ITEM_REF_NO, 
             SUPPLIER_PCDI_ID, PAYABLE_RETURNABLE_TYPE ,
             CARRY_OVER_QTY,
                         INTERNAL_ACTION_REF_NO,ENTRY_TYPE, IS_DELETED
                        )
                 VALUES (:NEW.INTERNAL_GRD_REF_NO, :NEW.INTERNAL_GMR_REF_NO,
                 :NEW.PRODUCT_ID,:NEW.IS_AFLOAT,:NEW.STATUS,
             :NEW.QTY ,:NEW.QTY_UNIT_ID,
             :NEW.GROSS_WEIGHT ,
             :NEW.TARE_WEIGHT ,
             :NEW.INTERNAL_CONTRACT_ITEM_REF_NO,
             :NEW.INT_ALLOC_GROUP_ID,:NEW.PACKING_SIZE_ID,
             :NEW.CONTAINER_NO,:NEW.SEAL_NO,:NEW.MARK_NO,
             :NEW.WAREHOUSE_REF_NO,:NEW.NO_OF_UNITS ,
             :NEW.QUALITY_ID,:NEW.WAREHOUSE_PROFILE_ID,:NEW.SHED_ID,
             :NEW.ORIGIN_ID,:NEW.CROP_YEAR_ID,:NEW.PARENT_ID,
             :NEW.IS_RELEASED_SHIPPED,
             :NEW.RELEASE_SHIPPED_NO_OF_UNITS ,
             :NEW.IS_WRITE_OFF,:NEW.WRITE_OFF_NO_OF_UNITS ,
             :NEW.IS_MOVED_OUT,:NEW.MOVED_OUT_NO_OF_UNITS ,
             :NEW.TOTAL_NO_OF_UNITS ,
             :NEW.TOTAL_QTY ,
             :NEW.MOVED_OUT_QTY ,
             :NEW.RELEASE_SHIPPED_QTY ,
             :NEW.WRITE_OFF_QTY ,
             :NEW.TITLE_TRANSFER_OUT_QTY ,
             :NEW.TITLE_TRANSFER_OUT_NO_OF_UNITS ,
             :NEW.WAREHOUSE_RECEIPT_NO,:NEW.WAREHOUSE_RECEIPT_DATE,
             :NEW.CONTAINER_SIZE,:NEW.REMARKS,:NEW.IS_ADDED_TO_POOL,
             :NEW.LOADING_DATE,:NEW.LOADING_COUNTRY_ID,
             :NEW.LOADING_PORT_ID,:NEW.IS_ENTIRE_ITEM_LOADED,
             :NEW.IS_WEIGHT_FINAL,:NEW.BL_NUMBER,:NEW.BL_DATE,
             :NEW.PARENT_INTERNAL_GRD_REF_NO,:NEW.DISCHARGED_QTY ,
             :NEW.IS_VOYAGE_STOCK,:NEW.ALLOCATED_QTY ,
             :NEW.INTERNAL_STOCK_REF_NO,:NEW.LANDED_NO_OF_UNITS ,
             :NEW.LANDED_NET_QTY ,
             :NEW.LANDED_GROSS_QTY ,
             :NEW.SHIPPED_NO_OF_UNITS ,
             :NEW.SHIPPED_NET_QTY ,
             :NEW.SHIPPED_GROSS_QTY ,
             :NEW.CURRENT_QTY ,
             :NEW.STOCK_STATUS,:NEW.PRODUCT_SPECS,:NEW.SOURCE_TYPE,
             :NEW.SOURCE_INT_STOCK_REF_NO,:NEW.SOURCE_INT_PURCHASE_REF_NO,
             :NEW.SOURCE_INT_POOL_REF_NO,:NEW.IS_FULFILLED,
             :NEW.INVENTORY_STATUS,:NEW.TRUCK_RAIL_NUMBER,
             :NEW.TRUCK_RAIL_TYPE,:NEW.PACKING_TYPE_ID,:NEW.HANDLED_AS,
             :NEW.ALLOCATED_NO_OF_UNITS ,
             :NEW.CURRENT_NO_OF_UNITS ,
             :NEW.STOCK_CONDITION,:NEW.GRAVITY_TYPE_ID,
             :NEW.GRAVITY ,:NEW.DENSITY_MASS_QTY_UNIT_ID,
             :NEW.DENSITY_VOLUME_QTY_UNIT_ID,:NEW.GRAVITY_TYPE,
             :NEW.CUSTOMS_ID,:NEW.TAX_ID,:NEW.DUTY_ID,:NEW.CUSTOMER_SEAL_NO,
             :NEW.BRAND,:NEW.NO_OF_CONTAINERS ,
             :NEW.NO_OF_BAGS ,:NEW.NO_OF_PIECES ,
             :NEW.RAIL_CAR_NO,:NEW.SDCTS_ID,:NEW.PARTNERSHIP_TYPE,
             :NEW.IS_TRANS_SHIP, :NEW.IS_MARK_FOR_TOLLING,
             :NEW.TOLLING_QTY, :NEW.TOLLING_STOCK_TYPE, 
             :NEW.ELEMENT_ID, :NEW.EXPECTED_SALES_CCY, 
             :NEW.PROFIT_CENTER_ID,:NEW.STRATEGY_ID,
             :NEW.IS_WARRANT, :NEW.WARRANT_NO, :NEW.PCDI_ID,
             :NEW.SUPP_CONTRACT_ITEM_REF_NO, 
             :NEW.SUPPLIER_PCDI_ID, :NEW.PAYABLE_RETURNABLE_TYPE ,
             :NEW.CARRY_OVER_QTY,         
             :NEW.INTERNAL_ACTION_REF_NO,'Insert', 'N'
                        );
   END IF;
   
   INSERT INTO ACI_ASSAY_CONTENT_UPDATE_INPUT
			(INTERNAL_GRD_NO,CONT_TYPE, 
			ASH_ID, IS_DELETED) 
		VALUES (:NEW.INTERNAL_GRD_REF_NO,
			'GRD',NULL, 'N'
		       );	
END;
/

