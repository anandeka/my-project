ALTER TABLE spql_stock_payable_qty_log ADD 
(ASSAY_CONTENT NUMBER(25,10), PLEDGE_STOCK_ID VARCHAR2(20), GEPD_ID VARCHAR2(15), 
ASSAY_HEADER_ID VARCHAR2(15), IS_FINAL_ASSAY CHAR(1) DEFAULT 'N',CORPORATE_ID  VARCHAR2(15));



DROP TRIGGER TRG_INSERT_SPQL;

CREATE OR REPLACE TRIGGER "TRG_INSERT_SPQL" 
AFTER INSERT OR UPDATE
ON SPQ_STOCK_PAYABLE_QTY FOR EACH ROW
BEGIN
   IF UPDATING
   THEN
      IF    :NEW.IS_ACTIVE = 'Y'
      THEN
         --Qty Unit is Not Updated
         IF :NEW.QTY_UNIT_ID = :OLD.QTY_UNIT_ID
         THEN
            INSERT INTO SPQL_STOCK_PAYABLE_QTY_LOG
                        (SPQ_ID,
                        INTERNAL_GMR_REF_NO, 
                        STOCK_TYPE, 
                        INTERNAL_GRD_REF_NO, 
                        INTERNAL_DGRD_REF_NO,  
                        ACTION_NO, 
                        INTERNAL_ACTION_REF_NO,   
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA, 
                        QTY_UNIT_ID,
                        QTY_TYPE,
                        ACTIVITY_ACTION_ID,
                        IS_STOCK_SPLIT,
                        SUPPLIER_ID,
                        SMELTER_ID,
                        FREE_METAL_STOCK_ID,
                        FREE_METAL_QTY,
                        ASSAY_CONTENT,
                        PLEDGE_STOCK_ID,
                        GEPD_ID,
                        ASSAY_HEADER_ID,
                        IS_FINAL_ASSAY,
                        CORPORATE_ID, 
                        VERSION, 
                        ENTRY_TYPE, 
                        IS_ACTIVE                          
                       )
                VALUES (:NEW.SPQ_ID,
                        :NEW.INTERNAL_GMR_REF_NO,
                        :NEW.STOCK_TYPE, 
                        :NEW.INTERNAL_GRD_REF_NO, 
                        :NEW.INTERNAL_DGRD_REF_NO, 
                        :NEW.ACTION_NO,   
                        :NEW.INTERNAL_ACTION_REF_NO,  
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY - :OLD.PAYABLE_QTY, 
                        :NEW.QTY_UNIT_ID,
                        :NEW.QTY_TYPE,
                        :NEW.ACTIVITY_ACTION_ID,
                        :NEW.IS_STOCK_SPLIT,
                        :NEW.SUPPLIER_ID,
                        :NEW.SMELTER_ID,
                        :NEW.FREE_METAL_STOCK_ID,
                        :NEW.FREE_METAL_QTY - nvl(:OLD.FREE_METAL_QTY,0),
                        :NEW.ASSAY_CONTENT - :OLD.ASSAY_CONTENT,
                        :NEW.PLEDGE_STOCK_ID,
                        :NEW.GEPD_ID,
                        :NEW.ASSAY_HEADER_ID,
                        :NEW.IS_FINAL_ASSAY,
                        :NEW.CORPORATE_ID,  
                        :NEW.VERSION, 
                        'Update', 'Y'
                       );
         ELSE
            --Qty Unit is Updated
            INSERT INTO SPQL_STOCK_PAYABLE_QTY_LOG
                        (SPQ_ID,
                        INTERNAL_GMR_REF_NO, 
                        STOCK_TYPE, 
                        INTERNAL_GRD_REF_NO, 
                        INTERNAL_DGRD_REF_NO,  
                        ACTION_NO, 
                        INTERNAL_ACTION_REF_NO,   
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA, 
                        QTY_UNIT_ID,
                        QTY_TYPE,
                        ACTIVITY_ACTION_ID,
                        IS_STOCK_SPLIT,
                        SUPPLIER_ID,
                        SMELTER_ID,
                        FREE_METAL_STOCK_ID,
                        FREE_METAL_QTY,
                        ASSAY_CONTENT,
                        PLEDGE_STOCK_ID,
                        GEPD_ID,
                        ASSAY_HEADER_ID,
                        IS_FINAL_ASSAY,
                        CORPORATE_ID, 
                        VERSION, 
                        ENTRY_TYPE,   
                        IS_ACTIVE 
                       )
                VALUES (:NEW.SPQ_ID,
                        :NEW.INTERNAL_GMR_REF_NO,
                        :NEW.STOCK_TYPE, 
                        :NEW.INTERNAL_GRD_REF_NO, 
                        :NEW.INTERNAL_DGRD_REF_NO, 
                        :NEW.ACTION_NO,
                        :NEW.INTERNAL_ACTION_REF_NO,  
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY
                         - pkg_general.f_get_converted_quantity
                                                            (null,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.PAYABLE_QTY
                                                            ), 
                        :NEW.QTY_UNIT_ID, 
                        :NEW.QTY_TYPE,
                        :NEW.ACTIVITY_ACTION_ID,
                        :NEW.IS_STOCK_SPLIT,
                        :NEW.SUPPLIER_ID,
                        :NEW.SMELTER_ID,
                        :NEW.FREE_METAL_STOCK_ID,
                        :NEW.FREE_METAL_QTY
                        - pkg_general.f_get_converted_quantity
                                                            (null,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             nvl(:OLD.FREE_METAL_QTY,0)
                                                            ), 
                        :NEW.ASSAY_CONTENT 
                        - pkg_general.f_get_converted_quantity
                                                            (null,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.ASSAY_CONTENT
                                                            ), 
                        :NEW.PLEDGE_STOCK_ID,
                        :NEW.GEPD_ID,
                        :NEW.ASSAY_HEADER_ID,
                        :NEW.IS_FINAL_ASSAY,
                        :NEW.CORPORATE_ID, 
                        :NEW.VERSION, 
                        'Update', 'Y'
                       );
         END IF;
      ELSE
         -- IsActive is Cancelled
           INSERT INTO  SPQL_STOCK_PAYABLE_QTY_LOG
                        (SPQ_ID,
                        INTERNAL_GMR_REF_NO, 
                        STOCK_TYPE, 
                        INTERNAL_GRD_REF_NO, 
                        INTERNAL_DGRD_REF_NO,  
                        ACTION_NO, 
                        INTERNAL_ACTION_REF_NO,   
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA, 
                        QTY_UNIT_ID,
                        QTY_TYPE,
                        ACTIVITY_ACTION_ID,
                        IS_STOCK_SPLIT,
                        SUPPLIER_ID,
                        SMELTER_ID,
                        FREE_METAL_STOCK_ID,
                        FREE_METAL_QTY, 
                        ASSAY_CONTENT,
                        PLEDGE_STOCK_ID,
                        GEPD_ID,
                        ASSAY_HEADER_ID,
                        IS_FINAL_ASSAY,
                        CORPORATE_ID, 
                        VERSION, 
                        ENTRY_TYPE,   
                        IS_ACTIVE 
                       )
                VALUES (:NEW.SPQ_ID,
                        :NEW.INTERNAL_GMR_REF_NO,
                        :NEW.STOCK_TYPE, 
                        :NEW.INTERNAL_GRD_REF_NO, 
                        :NEW.INTERNAL_DGRD_REF_NO, 
                        :NEW.ACTION_NO,   
                        :NEW.INTERNAL_ACTION_REF_NO,  
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY - :OLD.PAYABLE_QTY, 
                        :NEW.QTY_UNIT_ID, 
                        :NEW.QTY_TYPE,
                        :NEW.ACTIVITY_ACTION_ID,
                        :NEW.IS_STOCK_SPLIT,
                        :NEW.SUPPLIER_ID,
                        :NEW.SMELTER_ID,
                        :NEW.FREE_METAL_STOCK_ID,
                        :NEW.FREE_METAL_QTY - nvl(:OLD.FREE_METAL_QTY,0),
                        :NEW.ASSAY_CONTENT - :OLD.ASSAY_CONTENT,
                        :NEW.PLEDGE_STOCK_ID,
                        :NEW.GEPD_ID,
                        :NEW.ASSAY_HEADER_ID,
                        :NEW.IS_FINAL_ASSAY,
                        :NEW.CORPORATE_ID,  
                        :NEW.VERSION, 
                        'Update', 'N'
                       );
      END IF;                               
   ELSE
      --
      -- New Entry ( Entry Type=Insert)
      --
           INSERT INTO  SPQL_STOCK_PAYABLE_QTY_LOG
                        (SPQ_ID,
                        INTERNAL_GMR_REF_NO, 
                        STOCK_TYPE, 
                        INTERNAL_GRD_REF_NO, 
                        INTERNAL_DGRD_REF_NO,  
                        ACTION_NO, 
                        INTERNAL_ACTION_REF_NO,   
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA, 
                        QTY_UNIT_ID,
                        QTY_TYPE,
                        ACTIVITY_ACTION_ID,
                        IS_STOCK_SPLIT,
                        SUPPLIER_ID,
                        SMELTER_ID,
                        FREE_METAL_STOCK_ID,
                        FREE_METAL_QTY, 
                        ASSAY_CONTENT,
                        PLEDGE_STOCK_ID,
                        GEPD_ID,
                        ASSAY_HEADER_ID,
                        IS_FINAL_ASSAY,
                        CORPORATE_ID,
                        VERSION, 
                        ENTRY_TYPE,   
                        IS_ACTIVE 
                       )
               VALUES (:NEW.SPQ_ID,
                       :NEW.INTERNAL_GMR_REF_NO,
                       :NEW.STOCK_TYPE, 
                       :NEW.INTERNAL_GRD_REF_NO, 
                       :NEW.INTERNAL_DGRD_REF_NO, 
                       :NEW.ACTION_NO,   
                       :NEW.INTERNAL_ACTION_REF_NO,  
                       :NEW.ELEMENT_ID, 
                       :NEW.PAYABLE_QTY, 
                       :NEW.QTY_UNIT_ID,
                       :NEW.QTY_TYPE,
                       :NEW.ACTIVITY_ACTION_ID,
                       :NEW.IS_STOCK_SPLIT,
                       :NEW.SUPPLIER_ID,
                       :NEW.SMELTER_ID,
                       :NEW.FREE_METAL_STOCK_ID,
                       :NEW.FREE_METAL_QTY,
                       :NEW.ASSAY_CONTENT,
                       :NEW.PLEDGE_STOCK_ID,
                       :NEW.GEPD_ID,
                       :NEW.ASSAY_HEADER_ID,
                       :NEW.IS_FINAL_ASSAY,
                       :NEW.CORPORATE_ID,  
                       :NEW.VERSION, 
                       'Insert', 'Y'
                      );
   END IF;
END;
/
