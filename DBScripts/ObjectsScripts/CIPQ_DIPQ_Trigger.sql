DROP TRIGGER TRG_INSERT_CIPQL;

CREATE OR REPLACE TRIGGER "TRG_INSERT_CIPQL" 
AFTER INSERT OR UPDATE
ON CIPQ_CONTRACT_ITEM_PAYABLE_QTY FOR EACH ROW
BEGIN
   IF UPDATING
   THEN
      IF    :NEW.IS_ACTIVE = 'Y'
      THEN
         --Qty Unit is Not Updated
         IF :NEW.QTY_UNIT_ID = :OLD.QTY_UNIT_ID
         THEN
            INSERT INTO CIPQL_CTRT_ITM_PAYABLE_QTY_LOG
                        (CIPQ_ID, 
                        INTERNAL_ACTION_REF_NO,  
                        INTERNAL_CONTRACT_ITEM_REF_NO, 
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA,
                        RETURNABLE_QTY_DELTA, 
                        QTY_UNIT_ID, 
                        QTY_TYPE,
                        VERSION,
                        ENTRY_TYPE,  
                        IS_ACTIVE
                       )
                VALUES (:NEW.CIPQ_ID, 
                        :NEW.INTERNAL_ACTION_REF_NO, 
                        :NEW.INTERNAL_CONTRACT_ITEM_REF_NO, 
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY - :OLD.PAYABLE_QTY,
                        :NEW.RETURNABLE_QTY - :OLD.RETURNABLE_QTY,
                        :NEW.QTY_UNIT_ID,
                        :NEW.QTY_TYPE,  
                        :NEW.VERSION, 
                        'Update', 'Y'
                       );
         ELSE
            --Qty Unit is Updated
            INSERT INTO CIPQL_CTRT_ITM_PAYABLE_QTY_LOG
                        (CIPQ_ID, 
                        INTERNAL_ACTION_REF_NO,  
                        INTERNAL_CONTRACT_ITEM_REF_NO, 
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA,
                        RETURNABLE_QTY_DELTA, 
                        QTY_UNIT_ID,
                        QTY_TYPE, 
                        VERSION,
                        ENTRY_TYPE,  
                        IS_ACTIVE
                        )
                VALUES (:NEW.CIPQ_ID, 
                        :NEW.INTERNAL_ACTION_REF_NO, 
                        :NEW.INTERNAL_CONTRACT_ITEM_REF_NO, 
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY
                         - pkg_general.f_get_converted_quantity
                                                            (null,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.PAYABLE_QTY
                                                            ), 
                        :NEW.RETURNABLE_QTY
                         - pkg_general.f_get_converted_quantity
                                                            (null,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.RETURNABLE_QTY
                                                            ), 
                                                            
                        :NEW.QTY_UNIT_ID,
                        :NEW.QTY_TYPE,  
                        :NEW.VERSION, 
                        'Update', 'Y'
                       );
         END IF;
      ELSE
         -- IsActive is Cancelled
           INSERT INTO  CIPQL_CTRT_ITM_PAYABLE_QTY_LOG
                        (CIPQ_ID, 
                        INTERNAL_ACTION_REF_NO,  
                        INTERNAL_CONTRACT_ITEM_REF_NO, 
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA,
                        RETURNABLE_QTY_DELTA,
                        QTY_UNIT_ID,
                        QTY_TYPE, 
                        VERSION,
                        ENTRY_TYPE,  
                        IS_ACTIVE
                       )
                VALUES (:NEW.CIPQ_ID, 
                        :NEW.INTERNAL_ACTION_REF_NO, 
                        :NEW.INTERNAL_CONTRACT_ITEM_REF_NO, 
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY - :OLD.PAYABLE_QTY, 
                        :NEW.RETURNABLE_QTY - :OLD.RETURNABLE_QTY, 
                        :NEW.QTY_UNIT_ID,
                        :NEW.QTY_TYPE,  
                        :NEW.VERSION, 
                        'Update', 'N'
                       );
      END IF;                               
   ELSE
      --
      -- New Entry ( Entry Type=Insert)
      --
           INSERT INTO  CIPQL_CTRT_ITM_PAYABLE_QTY_LOG
                        (CIPQ_ID, 
                        INTERNAL_ACTION_REF_NO,  
                        INTERNAL_CONTRACT_ITEM_REF_NO, 
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA,
                        RETURNABLE_QTY_DELTA,
                        QTY_UNIT_ID,
                        QTY_TYPE, 
                        VERSION,
                        ENTRY_TYPE,  
                        IS_ACTIVE
                       )
               VALUES (:NEW.CIPQ_ID, 
                       :NEW.INTERNAL_ACTION_REF_NO,                                     
                       :NEW.INTERNAL_CONTRACT_ITEM_REF_NO, 
                       :NEW.ELEMENT_ID, 
                       :NEW.PAYABLE_QTY, 
                       :NEW.RETURNABLE_QTY,
                       :NEW.QTY_UNIT_ID,
                       :NEW.QTY_TYPE, 
                       :NEW.VERSION,
                       'Insert', 'Y'
                      );
   END IF;
END;
/






DROP TRIGGER TRG_INSERT_DIPQL;

CREATE OR REPLACE TRIGGER "TRG_INSERT_DIPQL" 
AFTER INSERT OR UPDATE
ON DIPQ_DELIVERY_ITEM_PAYABLE_QTY FOR EACH ROW
BEGIN
   IF UPDATING
   THEN
      IF    :NEW.IS_ACTIVE = 'Y'
      THEN
         --Qty Unit is Not Updated
         IF :NEW.QTY_UNIT_ID = :OLD.QTY_UNIT_ID
         THEN
            INSERT INTO DIPQL_DEL_ITM_PAYBLE_QTY_LOG
                        (DIPQ_ID,
                        PCDI_ID,  
                        INTERNAL_ACTION_REF_NO,  
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA,
                        RETURNABLE_QTY_DELTA,
                        QTY_UNIT_ID,
                        PRICE_OPTION_CALL_OFF_STATUS, 
                        IS_PRICE_OPTIONALITY_PRESENT, 
                        QTY_TYPE, 
                        VERSION,
                        ENTRY_TYPE,  
                        IS_ACTIVE
                       )
                VALUES (:NEW.DIPQ_ID,
                        :NEW.PCDI_ID,  
                        :NEW.INTERNAL_ACTION_REF_NO,  
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY - :OLD.PAYABLE_QTY,
                        :NEW.RETURNABLE_QTY - :OLD.RETURNABLE_QTY,
                        :NEW.QTY_UNIT_ID,
                        :NEW.PRICE_OPTION_CALL_OFF_STATUS, 
                        :NEW.IS_PRICE_OPTIONALITY_PRESENT,
                        :NEW.QTY_TYPE,  
                        :NEW.VERSION, 
                        'Update', 'Y'
                       );
         ELSE
            --Qty Unit is Updated
            INSERT INTO DIPQL_DEL_ITM_PAYBLE_QTY_LOG
                        (DIPQ_ID, 
                        PCDI_ID, 
                        INTERNAL_ACTION_REF_NO,  
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA,
                        RETURNABLE_QTY_DELTA,
                        QTY_UNIT_ID, 
                        PRICE_OPTION_CALL_OFF_STATUS, 
                        IS_PRICE_OPTIONALITY_PRESENT,
                        QTY_TYPE, 
                        VERSION,
                        ENTRY_TYPE,  
                        IS_ACTIVE
                        )
                VALUES (:NEW.DIPQ_ID, 
                        :NEW.PCDI_ID, 
                        :NEW.INTERNAL_ACTION_REF_NO,  
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY
                         - pkg_general.f_get_converted_quantity
                                                            (null,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.PAYABLE_QTY
                                                            ), 
                        :NEW.RETURNABLE_QTY
                         - pkg_general.f_get_converted_quantity
                                                            (null,
                                                             :OLD.QTY_UNIT_ID,
                                                             :NEW.QTY_UNIT_ID,
                                                             :OLD.RETURNABLE_QTY
                                                            ), 
                        :NEW.QTY_UNIT_ID, 
                        :NEW.PRICE_OPTION_CALL_OFF_STATUS, 
                        :NEW.IS_PRICE_OPTIONALITY_PRESENT,
                        :NEW.QTY_TYPE,  
                        :NEW.VERSION, 
                        'Update', 'Y'
                       );
         END IF;
      ELSE
         -- IsActive is Cancelled
           INSERT INTO  DIPQL_DEL_ITM_PAYBLE_QTY_LOG
                        (DIPQ_ID, 
                        PCDI_ID, 
                        INTERNAL_ACTION_REF_NO,  
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA,
                        RETURNABLE_QTY_DELTA,
                        QTY_UNIT_ID,
                        PRICE_OPTION_CALL_OFF_STATUS, 
                        IS_PRICE_OPTIONALITY_PRESENT, 
                        QTY_TYPE, 
                        VERSION,
                        ENTRY_TYPE,  
                        IS_ACTIVE
                       )
                VALUES (:NEW.DIPQ_ID, 
                        :NEW.PCDI_ID, 
                        :NEW.INTERNAL_ACTION_REF_NO, 
                        :NEW.ELEMENT_ID, 
                        :NEW.PAYABLE_QTY - :OLD.PAYABLE_QTY,
                        :NEW.RETURNABLE_QTY - :OLD.RETURNABLE_QTY,
                        :NEW.QTY_UNIT_ID, 
                        :NEW.PRICE_OPTION_CALL_OFF_STATUS, 
                        :NEW.IS_PRICE_OPTIONALITY_PRESENT,
                        :NEW.QTY_TYPE, 
                        :NEW.VERSION, 
                        'Update', 'N'
                       );
      END IF;                               
   ELSE
      --
      -- New Entry ( Entry Type=Insert)
      --
           INSERT INTO  DIPQL_DEL_ITM_PAYBLE_QTY_LOG
                        (DIPQ_ID, 
                        PCDI_ID, 
                        INTERNAL_ACTION_REF_NO,  
                        ELEMENT_ID, 
                        PAYABLE_QTY_DELTA,
                        RETURNABLE_QTY_DELTA,
                        QTY_UNIT_ID, 
                        PRICE_OPTION_CALL_OFF_STATUS, 
                        IS_PRICE_OPTIONALITY_PRESENT, 
                        QTY_TYPE,
                        VERSION,
                        ENTRY_TYPE,  
                        IS_ACTIVE
                       )
               VALUES (:NEW.DIPQ_ID, 
                       :NEW.PCDI_ID, 
                       :NEW.INTERNAL_ACTION_REF_NO, 
                       :NEW.ELEMENT_ID, 
                       :NEW.PAYABLE_QTY,
                       :NEW.RETURNABLE_QTY,
                       :NEW.QTY_UNIT_ID, 
                       :NEW.PRICE_OPTION_CALL_OFF_STATUS, 
                       :NEW.IS_PRICE_OPTIONALITY_PRESENT,
                       :NEW.QTY_TYPE, 
                       :NEW.VERSION,
                       'Insert', 'Y'
                      );
   END IF;
END;
/







